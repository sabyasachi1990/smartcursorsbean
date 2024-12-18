USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[Proc_ProratedJob_HR]    Script Date: 16-12-2024 9.20.11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[Proc_ProratedJob_HR]  
AS  
BEGIN --1  
  
 DECLARE @Id UNIQUEIDENTIFIER 
 DECLARE @STARTDATE DATETIME2(7)   
 DECLARE @EMPSTARTDATE DATETIME2(7)  
 DECLARE @LeaveTypeCreatedDate DATETIME2(7)  
 DECLARE @ACCURALDAYS FLOAT  
 DECLARE @ENTITLEMENT FLOAT  
 DECLARE @RESETDATE DATETIME2(7) 
 DECLARE @BroughtForward FLOAT  
 DECLARE @Adjustment FLOAT  
 DECLARE @ApprovedAndNotTaken FLOAT  
 DECLARE @ApprovedAndTaken FLOAT  
 DECLARE @ACCURALTYPE NVARCHAR(100)  
 DECLARE @Prorated FLOAT  
 DECLARE @RemainingProrated FLOAT  
 Declare @StartTime Datetime2(7)=(getdate())  
 Declare @CurrentDay Int = DAY(GETDATE())  
 Declare @DayInAMonth Int  
 Declare @TrueFalse Int  = 0  
 Declare @IsMonthlyProration Bit
 DECLARE @ACCURALLEAVE INT = 0  
 DECLARE @DIFFMONTH FLOAT = 0.0  
 DECLARE @TestPRORATED decimal(18,2) = 0.00  
 DECLARE @PRORATED1 FLOAT = 0  
 DECLARE @REMAININGPRORATED1 FLOAT = 0  
 DECLARE @FuturePRORATED FLOAT = 0  
 DECLARE @YearDate DATETIME2(7)  
  
 BEGIN TRANSACTION --2  
 BEGIN TRY --3  
  

  CREATE TABLE #ProrateTemp (
  SNo int identity(1,1),
    Id UNIQUEIDENTIFIER,
    StartDate DATETIME2(7),
    EmpStartDate DATETIME2(7),
    LeaveTypeCreatedDate DATETIME2(7),
    AccuralDays FLOAT,
    AnnualLeaveEntitlement FLOAT,
    EndDate DATETIME2(7),
    BroughtForward FLOAT,
    Adjustment FLOAT,
    ApprovedAndNotTaken FLOAT,
    ApprovedAndTaken FLOAT,
    LeaveAccuralType NVARCHAR(100),
    Prorated FLOAT,
    RemainingProrated FLOAT,
    DayInAMonth INT,
    IsMonthlyProration BIT
  )


  INSERT INTO #ProrateTemp
    SELECT   
   LE.Id AS EntitlementId, HRSD.[StartDate], EMP.Startdate AS EmpStartDate, LT.[CreatedDate], isnull(LT.[AccuralDays], 0) AS AccuralDays,   
   LE.[AnnualLeaveEntitlement], HRSD.[EndDate], LE.[BroughtForward], convert(FLOAT, isnull(LE.[Adjustment], 0)) Adjustment ,   
   LE.[ApprovedAndNotTaken], LE.[ApprovedAndTaken], LT.[LeaveAccuralType], LE.Prorated, LE.[RemainingProrated],  
   ISNULL(LT.DayInMonth,1) AS DayInAMonth,ISNULL(LE.IsMonthlyProration,0) as IsMonthlyProration
  FROM [HR].[LeaveType] LT (NOLOCK)
  JOIN [HR].[LeaveEntitlement] LE (NOLOCK) ON LE.[LeaveTypeId] = LT.Id  
  JOIN [Common].[HRSettings] HRS (NOLOCK) ON HRS.CompanyID = LT.CompanyID  
  JOIN [Common].[HRSettingdetails] HRSD (NOLOCK) ON HRSD.[MasterId] = HRS.Id  
  JOIN [Common].[Employee] CE (NOLOCK) ON CE.Id = LE.EmployeeId  
  JOIN [HR].[Employment] EMP (NOLOCK) ON EMP.EmployeeId = CE.Id  
  WHERE Convert(DATE, HRSD.EndDate) = Convert(DATE, HRS.[ResetLeaveBalanceDate]) AND LT.[LeaveAccuralType] = 'Monthly' AND CE.STATUS = 1 AND 
  LE.[HrSettingDetaiId] = HRSD.ID and (LT.IsMOM is null or LT.IsMOM=0) AND LT.DayInMonth = @CurrentDay
  ORDER BY LT.Companyid  
  

  DECLARE @RowNumber INT = 1
  DECLARE @TotalRows INT
  SELECT @TotalRows = COUNT(*) FROM #ProrateTemp

  WHILE @RowNumber <= @TotalRows
  BEGIN --4
    SELECT 
      @Id = Id, 
      @STARTDATE = StartDate, 
      @EMPSTARTDATE = EmpStartDate, 
      @LeaveTypeCreatedDate = LeaveTypeCreatedDate, 
      @ACCURALDAYS = AccuralDays, 
      @ENTITLEMENT = AnnualLeaveEntitlement, 
      @RESETDATE = EndDate, 
      @BroughtForward = BroughtForward, 
      @Adjustment = Adjustment, 
      @ApprovedAndNotTaken = ApprovedAndNotTaken, 
      @ApprovedAndTaken = ApprovedAndTaken, 
      @ACCURALTYPE = LeaveAccuralType, 
      @Prorated = Prorated, 
      @RemainingProrated = RemainingProrated, 
      @DayInAMonth = DayInAMonth, 
      @IsMonthlyProration = IsMonthlyProration
    FROM #ProrateTemp
    WHERE SNo= @RowNumber
  
     DECLARE @DaysDiff Int = (DATEDIFF(DD,@EMPSTARTDATE,GETDATE()))  
  
  SET @TrueFalse =  CASE WHEN (@DaysDiff >= @ACCURALDAYS) OR @ACCURALDAYS IS NULL THEN 1  
           ELSE 0  
         END  
  
   IF (@ACCURALTYPE = 'Monthly'  AND  CONVERT(DATE, @EMPSTARTDATE) < CONVERT(DATE, @RESETDATE)   
    AND @ENTITLEMENT IS NOT NULL  AND  @ENTITLEMENT != 0 AND @DayInAMonth = @CurrentDay AND @TrueFalse = 1 AND @IsMonthlyProration = 0
    /*AND @DaysDiff >= @ACCURALDAYS*/)  
  
    
	 BEGIN --5  
         
    SET @TestPRORATED = (@ENTITLEMENT) / 12.0;  
    SET @TestPRORATED = @TestPRORATED + isnull(@Prorated, 0) + isnull(@RemainingProrated, 0)  
  
    SELECT @PRORATED1 = value1, @REMAININGPRORATED1 = value2  
    FROM SplitDecimalValue(@TestPRORATED) 
  
     IF (CONVERT(DATE, @STARTDATE) <= CONVERT(DATE, @EMPSTARTDATE) AND CONVERT(DATE, @EMPSTARTDATE) <= CONVERT(DATE, @RESETDATE))  
    BEGIN --6  
     IF (year(@EMPSTARTDATE) = year(getdate()) AND month(@EMPSTARTDATE) > month(getdate()))  
     BEGIN --7  
      SET @PRORATED1 =@Prorated  
      SET @REMAININGPRORATED1 = @RemainingProrated  
     END --7  
  
         IF (year(@EMPSTARTDATE) = year(getdate()) AND month(@EMPSTARTDATE) = month(getdate()))  
     BEGIN --8  
      IF ((DAY(EOMONTH(@EMPSTARTDATE)) - DATEPART(DAY, @EMPSTARTDATE) + 1) < @ACCURALDAYS)  
           BEGIN --9  
       SET @PRORATED1 = @Prorated  
       SET @REMAININGPRORATED1 = @RemainingProrated  
      END --9      
        END --8  
      END --6  
  
     UPDATE [HR].[LeaveEntitlement]  
     SET [Prorated] = @PRORATED1,   
     [Current] = (isnull(@PRORATED1, 0) + isnull(@BroughtForward, 0) + @Adjustment),  
     [LeaveBalance] = ((isnull(@PRORATED1, 0) + isnull(@BroughtForward, 0) + @Adjustment) - (isnull(@ApprovedAndNotTaken, 0) + isnull(@ApprovedAndTaken, 0))),   
     [CompletedMonth] =month(getdate()),   
     [RemainingProrated] = @REMAININGPRORATED1,  
     [Total]=(isnull(@ENTITLEMENT, 0) + isnull(@BroughtForward, 0) + @Adjustment),
	 IsMonthlyProration = 1
    WHERE id = @Id  
    END --5  

    SET @RowNumber = @RowNumber + 1
  END --4  
  

  DROP TABLE #ProrateTemp
  
  INSERT INTO Common.JobStatus  (Id ,Module ,Jobname ,[Type] ,[Purpose] ,[StartDate] ,[EndDate] ,RecordsEffeted ,Remarks ,JobStatus )   VALUES (NEWID(),'HRCursor','ProratedJob','Job','ProratedJob',@StartTime,GETDATE(),NULL,NULL,'Completed')  

    
  COMMIT TRANSACTION --2  
 END TRY --3  
  
 BEGIN CATCH  
  ROLLBACK TRANSACTION  
  
  DECLARE @ErrorMessage NVARCHAR(4000)  
  
  SELECT @ErrorMessage = ERROR_MESSAGE() 
  
  RAISERROR (@ErrorMessage, 16, 1);  
 END CATCH  
  
END --1  








---------------------------->>> OLD Job-----------------------------------------------------------
  
--ALTER PROCEDURE [dbo].[Proc_ProratedJob_HR]  ---->> EXEC [dbo].[Proc_ProratedJob_HR]  
--AS  
--BEGIN --1  
  
-- DECLARE @Id UNIQUEIDENTIFIER --leave entitlement id  
-- DECLARE @STARTDATE DATETIME2(7) --HR setting start date   
-- DECLARE @EMPSTARTDATE DATETIME2(7)  
-- DECLARE @LeaveTypeCreatedDate DATETIME2(7)  
-- DECLARE @ACCURALDAYS FLOAT  
-- DECLARE @ENTITLEMENT FLOAT  
-- DECLARE @RESETDATE DATETIME2(7) --HR setting end date   
-- DECLARE @BroughtForward FLOAT  
-- DECLARE @Adjustment FLOAT  
-- DECLARE @ApprovedAndNotTaken FLOAT  
-- DECLARE @ApprovedAndTaken FLOAT  
-- DECLARE @ACCURALTYPE NVARCHAR(100)  
-- DECLARE @Prorated FLOAT  
-- DECLARE @RemainingProrated FLOAT  
-- Declare @StartTime Datetime2(7)=(getdate())  
-- Declare @CurrentDay Int = DAY(GETDATE())  
-- Declare @DayInAMonth Int  
-- Declare @TrueFalse Int  = 0  
-- Declare @IsMonthlyProration Bit
  
  
-- DECLARE @ACCURALLEAVE INT = 0  
-- DECLARE @DIFFMONTH FLOAT = 0.0  
-- DECLARE @TestPRORATED decimal(18,2) = 0.00  
-- DECLARE @PRORATED1 FLOAT = 0  
-- DECLARE @REMAININGPRORATED1 FLOAT = 0  
-- DECLARE @FuturePRORATED FLOAT = 0  
-- DECLARE @YearDate DATETIME2(7)  
   
  
-- BEGIN TRANSACTION --2  
-- BEGIN TRY --3  
  
--  DECLARE ProrateCursor CURSOR  
--  FOR  

--  SELECT   
--   LE.Id AS EntitlementId, HRSD.[StartDate], EMP.Startdate AS EmpStartDate, LT.[CreatedDate], isnull(LT.[AccuralDays], 0) AS AccuralDays,   
--   LE.[AnnualLeaveEntitlement], HRSD.[EndDate], LE.[BroughtForward], convert(FLOAT, isnull(LE.[Adjustment], 0)) Adjustment ,   
--   LE.[ApprovedAndNotTaken], LE.[ApprovedAndTaken], LT.[LeaveAccuralType], LE.Prorated, LE.[RemainingProrated],  
--   LT.DayInMonth AS DayInAMonth,ISNULL(LE.IsMonthlyProration,0) as IsMonthlyProration
--  FROM [HR].[LeaveType] LT (NOLOCK)
--  JOIN [HR].[LeaveEntitlement] LE (NOLOCK) ON LE.[LeaveTypeId] = LT.Id  
--  JOIN [Common].[HRSettings] HRS (NOLOCK) ON HRS.CompanyID = LT.CompanyID  
--  JOIN [Common].[HRSettingdetails] HRSD (NOLOCK) ON HRSD.[MasterId] = HRS.Id  
--  JOIN [Common].[Employee] CE (NOLOCK) ON CE.Id = LE.EmployeeId  
--  JOIN [HR].[Employment] EMP (NOLOCK) ON EMP.EmployeeId = CE.Id  
--  WHERE Convert(DATE, HRSD.EndDate) = Convert(DATE, HRS.[ResetLeaveBalanceDate]) AND LT.[LeaveAccuralType] = 'Monthly' AND CE.STATUS = 1 AND 
--  LE.[HrSettingDetaiId] = HRSD.ID and (LT.IsMOM is null or LT.IsMOM=0)  
--  --and Lt.CompanyId=1 and CE.FirstName='Proration2'
--  --and LT.CompanyId = 2058 AND LT.Id='AF53D442-6A64-495D-8BFF-F264E79504AE'  
--  ORDER BY LT.Companyid  
  
--  OPEN ProrateCursor  
  
--  FETCH NEXT  
--  FROM ProrateCursor  
  
--  INTO @Id, @STARTDATE, @EMPSTARTDATE, @LeaveTypeCreatedDate, @ACCURALDAYS, @ENTITLEMENT, @RESETDATE, @BroughtForward,   
--    @Adjustment, @ApprovedAndNotTaken, @ApprovedAndTaken, @ACCURALTYPE, @Prorated, @RemainingProrated,@DayInAMonth,@IsMonthlyProration 
  
--  WHILE @@FETCH_STATUS = 0  
--  BEGIN --4  
  
--  DECLARE @DaysDiff Int = (DATEDIFF(DD,@EMPSTARTDATE,GETDATE()))  
  
--  SET @TrueFalse =  CASE WHEN (@DaysDiff >= @ACCURALDAYS) OR @ACCURALDAYS IS NULL THEN 1  
--           ELSE 0  
--         END  
  
--   IF (@ACCURALTYPE = 'Monthly'  AND  CONVERT(DATE, @EMPSTARTDATE) < CONVERT(DATE, @RESETDATE)   
--    AND @ENTITLEMENT IS NOT NULL  AND  @ENTITLEMENT != 0 AND @DayInAMonth = @CurrentDay AND @TrueFalse = 1 AND @IsMonthlyProration = 0
--    /*AND @DaysDiff >= @ACCURALDAYS*/)  
  
--   BEGIN --5  
         
--    SET @TestPRORATED = (@ENTITLEMENT) / 12.0;  
--    SET @TestPRORATED = @TestPRORATED + isnull(@Prorated, 0) + isnull(@RemainingProrated, 0)  
  
--    SELECT @PRORATED1 = value1, @REMAININGPRORATED1 = value2  
--    FROM SplitDecimalValue(@TestPRORATED)  
  
--    IF (CONVERT(DATE, @STARTDATE) <= CONVERT(DATE, @EMPSTARTDATE) AND CONVERT(DATE, @EMPSTARTDATE) <= CONVERT(DATE, @RESETDATE))  
--    BEGIN --6  
--     IF (year(@EMPSTARTDATE) = year(getdate()) AND month(@EMPSTARTDATE) > month(getdate()))  
--     BEGIN --7  
--      SET @PRORATED1 =@Prorated  
--      SET @REMAININGPRORATED1 = @RemainingProrated  
--     END --7  
  
--     IF (year(@EMPSTARTDATE) = year(getdate()) AND month(@EMPSTARTDATE) = month(getdate()))  
--     BEGIN --8  
--      IF ((DAY(EOMONTH(@EMPSTARTDATE)) - DATEPART(DAY, @EMPSTARTDATE) + 1) < @ACCURALDAYS)  
--      BEGIN --9  
--       SET @PRORATED1 = @Prorated  
--       SET @REMAININGPRORATED1 = @RemainingProrated  
--      END --9    
--     END --8  
--    END --6  
      
--    --SELECT @PRORATED1 AS Prorated, @REMAININGPRORATED1 AS RemainingProrated  
  
--    --SELECT @PRORATED1 AS [Prorated],(isnull(@PRORATED1, 0) + isnull(@BroughtForward, 0) + @Adjustment) AS [Current],  
--    --((isnull(@PRORATED1, 0) + isnull(@BroughtForward, 0) + @Adjustment) - (isnull(@ApprovedAndNotTaken, 0) + isnull(@ApprovedAndTaken, 0))) AS [LeaveBalance],   
--    --month(getdate()) AS [CompletedMonth],   
--    --@REMAININGPRORATED1 AS [RemainingProrated],  
--    --(isnull(@ENTITLEMENT, 0) + isnull(@BroughtForward, 0) + @Adjustment) AS [Total]   
--    --FROM [HR].[LeaveEntitlement]  
--    --WHERE id = @Id  
  
  
--    UPDATE [HR].[LeaveEntitlement]  
--    SET [Prorated] = @PRORATED1,   
--     [Current] = (isnull(@PRORATED1, 0) + isnull(@BroughtForward, 0) + @Adjustment),  
--     [LeaveBalance] = ((isnull(@PRORATED1, 0) + isnull(@BroughtForward, 0) + @Adjustment) - (isnull(@ApprovedAndNotTaken, 0) + isnull(@ApprovedAndTaken, 0))),   
--     [CompletedMonth] =month(getdate()),   
--     [RemainingProrated] = @REMAININGPRORATED1,  
--     [Total]=(isnull(@ENTITLEMENT, 0) + isnull(@BroughtForward, 0) + @Adjustment),
--	 IsMonthlyProration = 1
--    WHERE id = @Id  
   
--   END --5  
  
--   FETCH NEXT  
--   FROM ProrateCursor  
--   INTO @Id, @STARTDATE, @EMPSTARTDATE, @LeaveTypeCreatedDate, @ACCURALDAYS, @ENTITLEMENT, @RESETDATE, @BroughtForward,   
--     @Adjustment, @ApprovedAndNotTaken, @ApprovedAndTaken, @ACCURALTYPE, @Prorated, @RemainingProrated,@DayInAMonth, @IsMonthlyProration 
--  END --4  
  
--  CLOSE ProrateCursor  
--  DEALLOCATE ProrateCursor  
  
--  INSERT INTO Common.JobStatus  (Id ,Module ,Jobname ,[Type] ,[Purpose] ,[StartDate] ,[EndDate] ,RecordsEffeted ,Remarks ,JobStatus )   VALUES (NEWID(),'HRCursor','ProratedJob','Job','ProratedJob',@StartTime,GETDATE(),NULL,NULL,'Completed')  
    
--  COMMIT TRANSACTION --2  
-- END TRY --3  
  
-- BEGIN CATCH  
--  ROLLBACK TRANSACTION  
  
--  DECLARE @ErrorMessage NVARCHAR(4000) --, @ErrorSeverity INT, @ErrorState INT;  
  
--  SELECT @ErrorMessage = ERROR_MESSAGE() --, @ErrorSeverity = 16, @ErrorState = 1;    
  
--  RAISERROR (@ErrorMessage, 16, 1);  
-- END CATCH  
  
--END --1  
  
  
  
  
  
  
  
----============================================================================================================================----  
  
---- DECLARE @Id UNIQUEIDENTIFIER --leave entitlement id  
---- DECLARE @STARTDATE DATETIME2(7) --HR setting start date   
---- DECLARE @EMPSTARTDATE DATETIME2(7)  
---- DECLARE @LeaveTypeCreatedDate DATETIME2(7)  
---- DECLARE @ACCURALDAYS FLOAT  
---- DECLARE @ENTITLEMENT FLOAT  
---- DECLARE @RESETDATE DATETIME2(7) --HR setting end date   
---- DECLARE @BroughtForward FLOAT  
---- DECLARE @Adjustment FLOAT  
---- DECLARE @ApprovedAndNotTaken FLOAT  
---- DECLARE @ApprovedAndTaken FLOAT  
---- DECLARE @ACCURALTYPE NVARCHAR(100)  
---- DECLARE @Prorated FLOAT  
---- DECLARE @RemainingProrated FLOAT  
---- Declare @StartTime Datetime2(7)=(getdate())  
---- BEGIN TRANSACTION --2  
  
---- BEGIN TRY --3  
----  DECLARE ProrateCursor CURSOR  
----  FOR  
----  SELECT LE.Id, HRSD.[StartDate], EMP.Startdate, LT.[CreatedDate], isnull(LT.[AccuralDays], 0), LE.[AnnualLeaveEntitlement], HRSD.[EndDate], LE.[BroughtForward], convert(FLOAT, isnull(LE.[Adjustment], 0)), LE.[ApprovedAndNotTaken], LE.[ApprovedAndTaken], LT.[LeaveAccuralType], LE.Prorated, LE.[RemainingProrated]  
----  FROM [HR].[LeaveType] LT  
----  JOIN [HR].[LeaveEntitlement] LE ON LE.[LeaveTypeId] = LT.Id  
----  JOIN [Common].[HRSettings] HRS ON HRS.CompanyID = LT.CompanyID  
----  JOIN [Common].[HRSettingdetails] HRSD ON HRSD.[MasterId] = HRS.Id  
----  JOIN [Common].[Employee] CE ON CE.Id = LE.EmployeeId  
----  JOIN [HR].[Employment] EMP ON EMP.EmployeeId = CE.Id  
----  --Join [Common].[Company] c on c.id=Lt.companyid  
----  WHERE Convert(DATE, HRSD.EndDate) = Convert(DATE, HRS.[ResetLeaveBalanceDate]) AND LT.[LeaveAccuralType] = 'Monthly' AND CE.STATUS = 1 AND LE.[HrSettingDetaiId] = HRSD.ID and (LT.IsMOM is null or LT.IsMOM=0)    
----  --and LT.CompanyId=932 and LT.Id='68e7139e-ee42-4955-8d86-809170865791'  
----  ORDER BY LT.Companyid  
  
----  OPEN ProrateCursor  
  
----  FETCH NEXT  
----  FROM ProrateCursor  
----  INTO @Id, @STARTDATE, @EMPSTARTDATE, @LeaveTypeCreatedDate, @ACCURALDAYS, @ENTITLEMENT, @RESETDATE, @BroughtForward, @Adjustment, @ApprovedAndNotTaken, @ApprovedAndTaken, @ACCURALTYPE, @Prorated, @RemainingProrated  
  
----  WHILE @@FETCH_STATUS = 0  
----  BEGIN --4  
----   IF (@ACCURALTYPE = 'Monthly' AND CONVERT(DATE, @EMPSTARTDATE) < CONVERT(DATE, @RESETDATE) AND @ENTITLEMENT IS NOT NULL AND @ENTITLEMENT != 0)  
----   BEGIN --5  
----    DECLARE @ACCURALLEAVE INT = 0  
----    DECLARE @DIFFMONTH FLOAT = 0.0  
----    DECLARE @TestPRORATED decimal(18,2) = 0.00  
----    DECLARE @PRORATED1 FLOAT = 0  
----    DECLARE @REMAININGPRORATED1 FLOAT = 0  
----    DECLARE @FuturePRORATED FLOAT = 0  
----    DECLARE @YearDate DATETIME2(7)  
  
      
----    SET @TestPRORATED = (@ENTITLEMENT) / 12.0;  
----    SET @TestPRORATED = @TestPRORATED + isnull(@Prorated, 0) + isnull(@RemainingProrated, 0)  
  
----    SELECT @PRORATED1 = value1, @REMAININGPRORATED1 = value2  
----    FROM SplitDecimalValue(@TestPRORATED)  
  
----    IF (CONVERT(DATE, @STARTDATE) <= CONVERT(DATE, @EMPSTARTDATE) AND CONVERT(DATE, @EMPSTARTDATE) <= CONVERT(DATE, @RESETDATE))  
----    BEGIN --6  
----     IF (year(@EMPSTARTDATE) = year(getdate()) AND month(@EMPSTARTDATE) > month(getdate()))  
----     BEGIN --7  
----      SET @PRORATED1 =@Prorated  
----      SET @REMAININGPRORATED1 = @RemainingProrated  
----     END --7  
  
----     IF (year(@EMPSTARTDATE) = year(getdate()) AND month(@EMPSTARTDATE) = month(getdate()))  
----     BEGIN --8  
----      IF ((DAY(EOMONTH(@EMPSTARTDATE)) - DATEPART(DAY, @EMPSTARTDATE) + 1) < @ACCURALDAYS)  
----      BEGIN --9  
----       SET @PRORATED1 = @Prorated  
----       SET @REMAININGPRORATED1 = @RemainingProrated  
----      END --9    
----     END --8  
----    END --6  
      
----    --select @PRORATED1,@REMAININGPRORATED1  
----    UPDATE [HR].[LeaveEntitlement]  
----    SET [Prorated] = @PRORATED1, [Current] = (isnull(@PRORATED1, 0) + isnull(@BroughtForward, 0) + @Adjustment), [LeaveBalance] = ((isnull(@PRORATED1, 0) + isnull(@BroughtForward, 0) + @Adjustment) - (isnull(@ApprovedAndNotTaken, 0) + isnull(@ApprovedAndTaken, 0))), [CompletedMonth] =month(getdate()), [RemainingProrated] = @REMAININGPRORATED1,[Total]=(isnull(@ENTITLEMENT, 0) + isnull(@BroughtForward, 0) + @Adjustment) WHERE id = @Id  
      
----   END --5  
  
----   FETCH NEXT  
----   FROM ProrateCursor  
----   INTO @Id, @STARTDATE, @EMPSTARTDATE, @LeaveTypeCreatedDate, @ACCURALDAYS, @ENTITLEMENT, @RESETDATE, @BroughtForward, @Adjustment, @ApprovedAndNotTaken, @ApprovedAndTaken, @ACCURALTYPE, @Prorated, @RemainingProrated  
----  END --4  
  
----  CLOSE ProrateCursor  
  
----  DEALLOCATE ProrateCursor  
----  Insert into Common.JobStatus  (Id ,Module ,Jobname ,[Type] ,[Purpose] ,[StartDate] ,[EndDate] ,RecordsEffeted ,Remarks ,JobStatus ) ----values (newid(),'HRCursor','ProratedJob','Job','ProratedJob',@StartTime,getdate(),null,null,'Completed')  
----  COMMIT TRANSACTION --2  
---- END TRY --3  
  
---- BEGIN CATCH  
----  ROLLBACK TRANSACTION  
  
----  DECLARE @ErrorMessage NVARCHAR(4000) --, @ErrorSeverity INT, @ErrorState INT;  
  
----  SELECT @ErrorMessage = ERROR_MESSAGE() --, @ErrorSeverity = 16, @ErrorState = 1;    
  
----  RAISERROR (@ErrorMessage, 16, 1);  
---- END CATCH  
GO
