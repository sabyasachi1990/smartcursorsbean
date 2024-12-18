USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[Proc_YearlyLeavesEntitlementJob_HR_MIG]    Script Date: 16-12-2024 9.20.11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


Create PROCEDURE [dbo].[Proc_YearlyLeavesEntitlementJob_HR_MIG]    
AS    
BEGIN --s1    
 DECLARE @CompanyId BIGINT    
 DECLARE @HrsettingDetailId UNIQUEIDENTIFIER    
 DECLARE @HrsettingId UNIQUEIDENTIFIER    
 DECLARE @StartDate DATETIME    
 DECLARE @EndDate DATETIME    
 DECLARE @Prorated DECIMAL    
 DECLARE @RemainingProrated DECIMAL    
 DECLARE @TestPRORATED DECIMAL    
 DECLARE @AccuralLeave INT    
 DECLARE @DIFFMONTH INT    
 Declare @StartTime Datetime2(7)=(getdate())    
 DECLARE @EmptyGuid UNIQUEIDENTIFIER = (    
   SELECT CAST(0x0 AS UNIQUEIDENTIFIER)    
   )    
 DECLARE @AllCompany_Tbl TABLE (S_No INT Identity(1, 1), CompanyId BIGINT, HrsettingId UNIQUEIDENTIFIER, HrsettingDetailId UNIQUEIDENTIFIER, StartDate DATETIME, EndDate DATETIME)    
    
 CREATE TABLE #AllEmployee_Tbl (S_No INT Identity(1, 1), EmployeeID UNIQUEIDENTIFIER, DepartmentId UNIQUEIDENTIFIER NULL, Designationid UNIQUEIDENTIFIER NULL,StartDate DateTime)    
    
 CREATE TABLE #Leaves_Tbl (S_No INT Identity(1, 1), LeaveTypeId UNIQUEIDENTIFIER, LeaveAccuralType NVARCHAR(200), LeaveType NVARCHAR(200), EntitlementType NVARCHAR(200), EntitlementDays INT, ApplyToAll NVARCHAR(200), AccuralDays FLOAT, DepartmentId UNIQUEIDENTIFIER NULL, DesignationId UNIQUEIDENTIFIER NULL, CarryForwardDays FLOAT,CreatedDate Datetime)    
    
 CREATE TABLE #AllDesignation_Tb (Designationid UNIQUEIDENTIFIER NULL)    
    
 DECLARE @AllPreviousPeriodEmployees_Tbl TABLE (S_No INT Identity(1, 1), EmpId UNIQUEIDENTIFIER, LTypeId UNIQUEIDENTIFIER, IsEnableLeaveRecommender BIT NULL, [IsNotRequiredRecommender] BIT NULL, [IsNotRequiredApprover] BIT NULL)    
 DECLARE @CompanyCount INT    
 DECLARE @RecCount INT    
 DECLARE @CategoryCount INT    
    
 BEGIN TRANSACTION --s2    
    
 BEGIN TRY --s3    
  UPDATE [HR].[LeaveEntitlement]    
  SET STATUS = 2    
  --, [EntitlementStatus] = 2    
  WHERE [HrSettingDetaiId] IN (    
    SELECT Id    
    FROM [Common].[HRSettingdetails] (NOLOCK)    
    WHERE convert(DATE, [EndDate]) = dateadd(day, datediff(day, 4, GETDATE()), 0) 
	and MasterId in (select Id from Common.HRSettings where  CompanyId=1437)
    )    
    
  INSERT INTO @AllPreviousPeriodEmployees_Tbl    
  SELECT [EmployeeId], [LeaveTypeId], [IsEnableLeaveRecommender], [IsNotRequiredRecommender], [IsNotRequiredApprover]    
  FROM [HR].[LeaveEntitlement] (NOLOCK)    
  WHERE [HrSettingDetaiId] IN (    
    SELECT Id   
    FROM [Common].[HRSettingdetails] (NOLOCK)    
    WHERE convert(DATE, [EndDate]) = dateadd(day, datediff(day, 4, GETDATE()), 0) 
		and MasterId in (select Id from Common.HRSettings where  CompanyId=1437)
    )    
    
  INSERT INTO @AllCompany_Tbl    
  SELECT HRS.CompanyId, HRS.Id, HRSD.ID, HRSD.StartDate, HRSD.EndDate    
  FROM [Common].[HRSettings] HRS (NOLOCK)    
  INNER JOIN [Common].[HRSettingdetails] HRSD (NOLOCK) ON HRS.Id = HRSD.[MasterId]    
  --WHERE convert(DATE, HRSD.[StartDate]) = convert(DATE, GETDATE())   
  WHERE (select year(convert(DATE, HRSD.[StartDate] ))) = (select Year(convert(DATE, GETDATE()))) and CompanyId=1437  
    
  SET @CompanyCount = (    
    SELECT Count(*)    
    FROM @AllCompany_Tbl    
    )    
  SET @RecCount = 1    
    
  WHILE @CompanyCount >= @RecCount    
  BEGIN --1    
   SELECT @CompanyId = CompanyId, @HrsettingDetailId = HrsettingDetailId, @HrsettingId = HrsettingId, @StartDate = StartDate, @EndDate = EndDate    
   FROM @AllCompany_Tbl    
   WHERE S_No = @RecCount    
    
   INSERT INTO #Leaves_Tbl    
   SELECT DISTINCT LT.ID, LT.LeaveAccuralType, LT.Name, LT.EntitlementType, LTD.Entitlement, LT.[ApplyToAll], LT.AccuralDays, LTD.[DepartmentId], LTD.[DesignationId], LTD.[CarryForwardDays]  ,LT.CreatedDate  
   FROM [HR].[LeaveType] LT (NOLOCK)    
   FULL OUTER JOIN [HR].[LeaveTypeDetails] LTD (NOLOCK) ON LT.[Id] = LTD.[LeaveTypeId]    
   WHERE LT.STATUS = 1 AND   LT.CompanyId = 1437    AND (LT.[ApplyToAll] = 'All' OR LT.[ApplyToAll] = 'Selected') and 
   (LT.IsMOM is null or LT.IsMOM=0)    
    
   SET @CategoryCount = (    
     SELECT Count(*)    
     FROM #Leaves_Tbl    
     )    
    
   DECLARE @RecCount1 INT = 1    
    
   WHILE @CategoryCount >= @RecCount1    
   BEGIN --2       
    DECLARE @LeaveTypeId_New UNIQUEIDENTIFIER    
    DECLARE @LeaveAccuralType_New NVARCHAR(200)    
    DECLARE @LeaveType_New NVARCHAR(200)    
    DECLARE @EntitlementType_New NVARCHAR(200)    
    DECLARE @Entitlement_New FLOAT    
    DECLARE @Applyto_new NVARCHAR(200)    
    DECLARE @DepartmentId_New UNIQUEIDENTIFIER    
    DECLARE @DesignationId_New UNIQUEIDENTIFIER    
    DECLARE @AccuralDays FLOAT    
    DECLARE @BroughtForward FLOAT   
 declare @EMPSTARTDATE DateTime  
 declare @YearDate DateTime  
 declare @FuturePRORATED DECIMAL  
 Declare @CreatedDate Datetime  
    
    --PRINT @CompanyId    
    
    SELECT @LeaveTypeId_New = LeaveTypeId, @LeaveAccuralType_New = LeaveAccuralType, @LeaveType_New = LeaveType, @EntitlementType_New = EntitlementType, @Entitlement_New = EntitlementDays, @Applyto_new = ApplyToAll, @DepartmentId_New = [DepartmentId], @DesignationId_New = DesignationId, @AccuralDays = AccuralDays, @BroughtForward = CarryForwardDays ,@CreatedDate = CreatedDate   
    FROM #Leaves_Tbl    
    WHERE S_No = @RecCount1    
    
   exec [dbo].[SP_HR_Leavetype_2_Entitlement] @LeaveTypeId_New,@companyId ,@Applyto_new ,0,null  

   --sp_helptext [SP_HR_Leavetype_2_Entitlement]
  
    
  --  IF (@Applyto_new = 'All')    
  --  BEGIN --6    
  --   --PRINT 'All'    
    
  --   INSERT INTO #AllEmployee_Tbl    
  --   SELECT e.Id, NULL, NULL,ment.StartDate    
  --   from Common.Employee  as e (NOLOCK) join HR.Employment as ment (NOLOCK) on ment.EmployeeId=e.Id   
  --   WHERE e.CompanyId = @CompanyId AND IdType IS NOT NULL and (Convert(Date,ment.StartDate) < Convert(date,@EndDate)) AND e.STATUS = 1 and e.Id='62f35317-d210-4b85-9246-ae226bfc3a9c'   
    
  --   DECLARE @EmployeeCount INT = (    
  --     SELECT Count(*)    
  --     FROM #AllEmployee_Tbl    
  --     )    
  --   DECLARE @EmpRecCount INT = 1    
    
  --   WHILE @EmployeeCount >= @EmpRecCount    
  --   BEGIN --7    
  --SELECT @EMPSTARTDATE = StartDate    
  --    FROM #AllEmployee_Tbl    
  --    WHERE S_No = @EmpRecCount  
  
  --If(@LeaveAccuralType_New = 'Yearly with proration')      
  --        BEGIN    --3  
  --         -- for future prorated    
  --         SET @STARTDATE=CASE WHEN CONVERT(DATE,@EMPSTARTDATE) < CONVERT(DATE,@STARTDATE)  THEN @STARTDATE ELSE @EMPSTARTDATE END;       
  --         --SET @YearDate =CASE WHEN CONVERT(DATE,@STARTDATE) < CONVERT(DATE,@createdDate)  THEN @createdDate ELSE @STARTDATE END;      
  --         SET @YearDate =@STARTDATE;  
  --         SET @ACCURALLEAVE= CASE WHEN (DAY(EOMONTH(@YearDate)) -DATEPART(DAY,@YearDate) +1) >= @ACCURALDAYS THEN 0 ELSE -1 END;      
  --         SET @DIFFMONTH =(SELECT DBO.GETDATEDIFFERENCE (CONVERT(DATE,@YearDate),CONVERT(DATE,@EndDate)));   
  
  --         SET @DIFFMONTH=@DIFFMONTH+(@ACCURALLEAVE);  
  --         SET @TestPRORATED=(@DIFFMONTH*@Entitlement_New)/12.0;     
  --         Select @PRORATED=value1 From SplitDecimalValue(@TestPRORATED);  
  --         Select @FuturePRORATED=@PRORATED;  
  --        END    --3  
  --      ELSE If(@LeaveAccuralType_New = 'Yearly without proration')      
  --        BEGIN   --4   
  --         Select @prorated=@Entitlement_New;  
  --         Select @FuturePRORATED=@PRORATED;  
  --        END  --4  
  --      ELSE If(@LeaveAccuralType_New = 'Monthly' )      
  --        BEGIN   --5   
  --         SET @STARTDATE=CASE WHEN CONVERT(DATE,@EMPSTARTDATE) < CONVERT(DATE,@STARTDATE)  THEN @STARTDATE ELSE @EMPSTARTDATE END;       
  --         SET @YearDate =CASE WHEN CONVERT(DATE,@STARTDATE) < CONVERT(DATE,@createdDate)  THEN @createdDate ELSE @STARTDATE END;      
  --         SET @ACCURALLEAVE= CASE WHEN (DAY(EOMONTH(@YearDate)) -DATEPART(DAY,@YearDate) +1) >= @ACCURALDAYS THEN 0 ELSE -1 END;      
  --         --SET @DIFFMONTH =(SELECT DBO.GETDATEDIFFERENCE (CONVERT(DATE,@YearDate),CONVERT(DATE,GETDATE())));   
  --         if(MONTH(GETDATE())=month(@YearDate) and @ACCURALLEAVE<0 and CONVERT(date,GETDATE())<CONVERT(date,@YearDate))  
  -- begin  
  -- set @ACCURALLEAVE=0  
  -- end   
  
  
  --         SET @DIFFMONTH =CASE WHEN CONVERT(DATE,getdate()) < CONVERT(DATE,@YearDate) Then 0 else  (SELECT DBO.GETDATEDIFFERENCE (CONVERT(DATE,@YearDate),CONVERT(DATE,GETDATE()))) END;   
             
  
  
  --         SET @DIFFMONTH=@DIFFMONTH+(@ACCURALLEAVE);     
  --         SET @TestPRORATED=(@DIFFMONTH*@Entitlement_New)/12.0;                   
  --         Select @PRORATED=value1,@REMAININGPRORATED=value2 From SplitDecimalValue(@TestPRORATED)         
  --        -- for future prorated  
  --         SET @DIFFMONTH =(SELECT DBO.GETDATEDIFFERENCE (CONVERT(DATE,@YearDate),CONVERT(DATE,@EndDate)));   
  --         SET @DIFFMONTH=@DIFFMONTH+(@ACCURALLEAVE);     
  --         SET @TestPRORATED=(@DIFFMONTH*@Entitlement_New)/12.0;     
  --         Select @FuturePRORATED=value1 From SplitDecimalValue(@TestPRORATED)    
  --        END  --5  
  --    --DECLARE @EntitlementId_New UNIQUEIDENTIFIER    
  --    DECLARE @EmployeeId_New UNIQUEIDENTIFIER    
  --    DECLARE @IsEnabledLeaveRecommender BIT    
  --    DECLARE @IsRequiredeLeaveRecommneder BIT    
  --    DECLARE @IsRequiredeLeaveApprover BIT    
    
  --    SELECT @EmployeeId_New = EmployeeID    
  --    FROM #AllEmployee_Tbl    
  --    WHERE S_No = @EmpRecCount    
    
  --    SELECT @IsEnabledLeaveRecommender = IsEnableLeaveRecommender, @IsRequiredeLeaveRecommneder = [IsNotRequiredRecommender], @IsRequiredeLeaveApprover = [IsNotRequiredApprover]    
  --    FROM @AllPreviousPeriodEmployees_Tbl    
  --    WHERE EmpId = @EmployeeId_New    
    
  --    --AND LTypeId = @LeaveTypeId_New    
  -- if not exists(select * from [HR].[LeaveEntitlement] where EmployeeID=@EmployeeId_New and LeaveTypeId=@LeaveTypeId_New and HrSettingDetaiId=@HrsettingDetailId and StartDate=@StartDate and EndDate=@EndDate)  
  -- begin  
  
  -- INSERT INTO  HR.LeaveEntitlement (Id,EmployeeId,LeaveTypeId,IsApplicable,AnnualLeaveEntitlement,LeaveApprovers, LeaveRecommenders,Prorated,ApprovedAndTaken,ApprovedAndNotTaken,Remarks,RecOrder,UserCreated,CreatedDate, ModifiedBy,ModifiedDate,Version
--,Status,StartDate,EndDate,BroughtForward,IsEnableLeaveRecommender,Adjustment,  
  --              Adjusted,CompletedMonth,RemainingProrated,[Current],LeaveBalance,Total,CarryForwardDays,Entitlementstatus,YTDLeaveBalance,FutureProrated,HrSettingDetaiId,IsNotRequiredApprover,IsNotRequiredRecommender)   
  --              VALUES   
  --              (NEWID(),@EmployeeId_New,@LeaveTypeId_New,1,@Entitlement_New,null,null,@prorated,0,0,null,1,  
  --              'system',GETUTCDATE(),null,null,2,1,@startDate,@enddate,0,0,null,null,(DATEPART(m, GETUTCDATE())),@remainingProrated,  
  --              @prorated, @prorated,@futureprorated,@BroughtForward,1,@futureprorated,@futureprorated,@HrSettingDetailId,@IsRequiredeLeaveApprover,@IsRequiredeLeaveRecommneder)         
      
  --    --INSERT [HR].[LeaveEntitlement] ([Id], [EmployeeId], [LeaveTypeId], [AnnualleaveEntitlement], [Prorated], [UserCreated], [CreatedDate], [status], [startdate], [EndDate], [HRSettingDetaiId], [EntitlementStatus], [YTDLeaveBalance], [Current], [LeaveBalance], [CarryForwardDays], [IsEnableLeaveRecommender], [IsNotRequiredRecommender], [IsNotRequiredApprover], [FutureProrated])    
  --    --VALUES (NewId(), @EmployeeId_New, @LeaveTypeId_New, @Entitlement_New, @Prorated, 'system', GetDate(), 1, @StartDate, @EndDate, @HrsettingDetailId, 1, @Entitlement_New, @Prorated, @Prorated, @BroughtForward, @IsEnabledLeaveRecommender, @IsRequiredeLeaveRecommneder, @IsRequiredeLeaveApprover, @Entitlement_New)    
  --    end  
  --    SET @EmpRecCount = @EmpRecCount + 1    
  --   END --7    
  --  END --6    
    
  --  TRUNCATE TABLE #AllEmployee_Tbl    
    
  --  IF (@Applyto_new = 'Selected')    
  --  BEGIN --8    
  --   PRINT 'SELECTED'    
    
  --   IF ((@DepartmentId_New IS NULL OR @DepartmentId_New = @EmptyGuid) AND (@DesignationId_New IS NOT NULL AND @DesignationId_New != @EmptyGuid))    
  --   BEGIN --m1    
  --    print 'Dept null all desig single'    
  --    --select @DesignationId_New    
  --    INSERT INTO #AllDesignation_Tb    
  --    SELECT DISTINCT dd.Id    
  --    FROM [Common].[Department] d (NOLOCK)    
  --    INNER JOIN [Common].[DepartmentDesignation] dd (NOLOCK) ON d.id = dd.[DepartmentId]    
  --    WHERE d.[CompanyId] = @CompanyId AND dd.code = (    
  --      SELECT code    
  --      FROM common.DepartmentDesignation (NOLOCK)    
  --      WHERE Id = @DesignationId_New    
  --      )    
  --      --select * from #AllDesignation_Tb    
  --   END --m1    
    
  --   IF ((@DepartmentId_New IS NOT NULL AND @DepartmentId_New != @EmptyGuid))    
  --   BEGIN --mid    
  --    PRINT 'Dept id exist'    
    
  --    INSERT INTO #AllEmployee_Tbl    
  --    SELECT DISTINCT CE.Id, HED.[DepartmentId], HED.[DepartmentDesignationId],ment.StartDate    
  --    FROM Common.Employee CE (NOLOCK)  join HR.Employment as ment (NOLOCK) on ment.EmployeeId=CE.Id   
  --    INNER JOIN [HR].[EmployeeDepartment] HED (NOLOCK) ON HED.EmployeeId = CE.Id    
  --    WHERE CE.CompanyId = @CompanyId AND CE.IdType IS NOT NULL AND CE.STATUS = 1 AND (Convert(DATE, HED.EffectiveFrom) <= Convert(DATE, GetDate()) AND (Convert(DATE, HED.EffectiveTo) >= Convert(DATE, GetDate()) OR HED.EffectiveTo IS NULL)) AND HED.DepartmentId = @DepartmentId_New AND CE.IdType IS NOT NULL AND CE.STATUS = 1    
  --   and (Convert(Date,ment.StartDate) < Convert(date,@EndDate)) and (Convert(Date,ment.StartDate) <= Convert(date,GETDATE())) and CE.Id='62f35317-d210-4b85-9246-ae226bfc3a9c'  
  --END --mid    
  --   ELSE    
  --   BEGIN --mid2    
  --    --PRINT 'Dept id not exist'    
    
  --    INSERT INTO #AllEmployee_Tbl    
  --    SELECT DISTINCT CE.Id, HED.[DepartmentId], HED.[DepartmentDesignationId] , ment.StartDate  
  --    FROM Common.Employee CE (NOLOCK)  join HR.Employment as ment (NOLOCK) on ment.EmployeeId=CE.Id   
  --    INNER JOIN [HR].[EmployeeDepartment] HED (NOLOCK) ON HED.EmployeeId = CE.Id    
  --    WHERE CE.CompanyId = @CompanyId AND CE.IdType IS NOT NULL AND CE.STATUS = 1  and CE.Id = '62f35317-d210-4b85-9246-ae226bfc3a9c' and (Convert(DATE, HED.EffectiveFrom) <= Convert(DATE, GetDate()) AND (Convert(DATE, HED.EffectiveTo) >= Convert(DATE, GetDate()) OR HED.EffectiveTo IS NULL)) AND HED.DepartmentDesignationId IN (    
  --      SELECT Designationid    
  --      FROM #AllDesignation_Tb    
  --      ) AND CE.IdType IS NOT NULL AND CE.STATUS = 1  and (Convert(Date,ment.StartDate) < Convert(date,@EndDate)) and (Convert(Date,ment.StartDate) <= Convert(date,GETDATE()))  
  --      --select * from #AllEmployee_Tbl    
  --   END --mid2    
    
  --   DECLARE @Count INT    
    
         
    
  --   SET @Count = (    
  --     SELECT Count(*)    
  --     FROM #AllEmployee_Tbl    
  --     )    
    
  --     PRINT @Count    
  --   DECLARE @rec INT = 1    
    
  --   --DECLARE @EntitlementId_New1 UNIQUEIDENTIFIER    
  --   WHILE @Count >= @rec    
  --   BEGIN --9    
  --SELECT @EMPSTARTDATE = StartDate    
  --    FROM #AllEmployee_Tbl    
  --    WHERE S_No = @rec  
  
  --If(@LeaveAccuralType_New = 'Yearly with proration')      
  --         BEGIN --18     
  --          -- for future prorated    
  --          SET @STARTDATE=CASE WHEN CONVERT(DATE,@EMPSTARTDATE) < CONVERT(DATE,@STARTDATE)  THEN @STARTDATE ELSE @EMPSTARTDATE END;       
  --          --SET @YearDate =CASE WHEN CONVERT(DATE,@STARTDATE) < CONVERT(DATE,@createdDate)  THEN @createdDate ELSE @STARTDATE END;      
  --          SET @YearDate =@STARTDATE;  
  --          SET @ACCURALLEAVE= CASE WHEN (DAY(EOMONTH(@YearDate)) -DATEPART(DAY,@YearDate) +1) >= @ACCURALDAYS THEN 0 ELSE -1 END;      
  --          SET @DIFFMONTH =(SELECT DBO.GETDATEDIFFERENCE (CONVERT(DATE,@YearDate),CONVERT(DATE,@EndDate)));   
  
  --          SET @DIFFMONTH=@DIFFMONTH+(@ACCURALLEAVE);  
  --          SET @TestPRORATED=(@DIFFMONTH*@Entitlement_New)/12.0;     
  --          Select @PRORATED=value1 From SplitDecimalValue(@TestPRORATED);  
  --          Select @FuturePRORATED=@PRORATED;  
  --         END   --18   
  --       Else If(@LeaveAccuralType_New = 'Yearly without proration')      
  --         BEGIN    --19  
  --          Select @PRORATED=@Entitlement_New;  
  --          Select @FuturePRORATED=@PRORATED;   
  --         END    --19  
  --       ELSE If(@LeaveAccuralType_New = 'Monthly')      
  --         BEGIN    --20  
  --          SET @STARTDATE=CASE WHEN CONVERT(DATE,@EMPSTARTDATE) < CONVERT(DATE,@STARTDATE)  THEN @STARTDATE ELSE @EMPSTARTDATE END;       
  --          SET @YearDate =CASE WHEN CONVERT(DATE,@STARTDATE) < CONVERT(DATE,@createdDate)  THEN @createdDate ELSE @STARTDATE END;      
  --          SET @ACCURALLEAVE= CASE WHEN (DAY(EOMONTH(@YearDate)) -DATEPART(DAY,@YearDate) +1) >= @ACCURALDAYS THEN 0 ELSE -1 END;      
  --          --SET @DIFFMONTH =(SELECT DBO.GETDATEDIFFERENCE (CONVERT(DATE,@YearDate),CONVERT(DATE,GETDATE())));  
  --          if(MONTH(GETDATE())=month(@YearDate) and @ACCURALLEAVE<0 and CONVERT(date,GETDATE())<CONVERT(date,@YearDate))  
  -- begin  
  -- set @ACCURALLEAVE=0  
  -- end   
  --          SET @DIFFMONTH =CASE WHEN CONVERT(DATE,getdate()) < CONVERT(DATE,@YearDate) Then 0 else  (SELECT DBO.GETDATEDIFFERENCE (CONVERT(DATE,@YearDate),CONVERT(DATE,GETDATE()))) END;   
  --          SET @DIFFMONTH=@DIFFMONTH+(@ACCURALLEAVE);     
  --          SET @TestPRORATED=(@DIFFMONTH*@Entitlement_New)/12.0;                   
  --          Select @PRORATED=value1,@REMAININGPRORATED=value2 From SplitDecimalValue(@TestPRORATED)         
  --         -- for future prorated  
  --          --SET @MONTHSTARTDATE=(SELECT DateAdd(MONTH,1,DATEADD(month, DATEDIFF(month, 0, GETDATE()), 0)));  
  --          SET @DIFFMONTH =(SELECT DBO.GETDATEDIFFERENCE (CONVERT(DATE,@YearDate),CONVERT(DATE,@EndDate)));   
  --          SET @DIFFMONTH=@DIFFMONTH+(@ACCURALLEAVE);     
  --          SET @TestPRORATED=(@DIFFMONTH*@Entitlement_New)/12.0;     
  --          Select @FuturePRORATED=value1 From SplitDecimalValue(@TestPRORATED)    
  --         END    --20  
  
  --    --IF EXISTS (    
  --    --  SELECT EmployeeID    
  --    --  FROM #AllEmployee_Tbl    
  --    --  WHERE S_No = @rec AND DepartmentId = @Departmentid_New    
  --    --  )    
  --    --BEGIN --10    
  --     --PRINT 'yes'    
    
  --     DECLARE @EmployeeId_New1 UNIQUEIDENTIFIER    
  --     DECLARE @EmpDepartmentid_New UNIQUEIDENTIFIER    
  --     DECLARE @EmpDesignationId_New UNIQUEIDENTIFIER    
  --     DECLARE @IsEnabledLeaveRecommender1 BIT    
  --     DECLARE @IsRequiredeLeaveRecommneder1 BIT    
  --     DECLARE @IsRequiredeLeaveApprover1 BIT    
    
  --     SELECT @EmployeeId_New1 = EmployeeID, @EmpDepartmentid_New = DepartmentId, @EmpDesignationId_New = Designationid    
  --     FROM #AllEmployee_Tbl    
  --     WHERE S_No = @rec     
  --     --AND DepartmentId = @Departmentid_New    
    
  --     SELECT @IsEnabledLeaveRecommender1 = IsEnableLeaveRecommender, @IsRequiredeLeaveRecommneder1 = [IsNotRequiredRecommender], @IsRequiredeLeaveApprover1 = [IsNotRequiredApprover]    
  --     FROM @AllPreviousPeriodEmployees_Tbl    
  --     WHERE EmpId = @EmployeeId_New1    
    
  --     --AND LTypeId = @LeaveTypeId_New    
  --     IF ((@DepartmentId_New IS NOT NULL AND @DepartmentId_New != @EmptyGuid) AND (@DesignationId_New IS NOT NULL AND @DesignationId_New != @EmptyGuid))    
  --     BEGIN --11    
  --      IF (@EmpDesignationId_New = @DesignationId_New and @EmpDepartmentid_New=@DepartmentId_New)    
  --      BEGIN --12    
  --if not exists(select * from [HR].[LeaveEntitlement] where EmployeeID=@EmployeeId_New and LeaveTypeId=@LeaveTypeId_New and HrSettingDetaiId=@HrsettingDetailId and StartDate=@StartDate and EndDate=@EndDate)  
  -- begin  
  --      print 'Dept exist and desig exist'   
  --INSERT INTO  HR.LeaveEntitlement (Id,EmployeeId,LeaveTypeId,IsApplicable,AnnualLeaveEntitlement,LeaveApprovers, LeaveRecommenders,Prorated,ApprovedAndTaken,ApprovedAndNotTaken,Remarks,RecOrder,UserCreated,CreatedDate, ModifiedBy,ModifiedDate,Version,Status,StartDate,EndDate,BroughtForward,IsEnableLeaveRecommender,Adjustment,  
  --              Adjusted,CompletedMonth,RemainingProrated,[Current],LeaveBalance,Total,CarryForwardDays,Entitlementstatus,YTDLeaveBalance,FutureProrated,HrSettingDetaiId,IsNotRequiredApprover,IsNotRequiredRecommender)   
  --              VALUES   
  --              (NEWID(),@EmployeeId_New1,@LeaveTypeId_New,1,@Entitlement_New,null,null,@prorated,0,0,null,1,  
  --              'system',GETUTCDATE(),null,null,2,1,@startDate,@enddate,0,0,null,null,(DATEPART(m, GETUTCDATE())),@remainingProrated,  
  --              @prorated, @prorated,@futureprorated,@BroughtForward,1,@futureprorated,@futureprorated,@HrSettingDetailId,@IsRequiredeLeaveApprover1,@IsRequiredeLeaveRecommneder1)         
                 
  --     --  INSERT [HR].[LeaveEntitlement] ([Id], [EmployeeId], [LeaveTypeId], [AnnualleaveEntitlement], [Prorated], [UserCreated], [CreatedDate], [status], [startdate], [EndDate], [HRSettingDetaiId], [EntitlementStatus], [YTDLeaveBalance], [Current], [LeaveBalance], [CarryForwardDays], [IsEnableLeaveRecommender], [IsNotRequiredRecommender], [IsNotRequiredApprover], [FutureProrated])    
  --     --  VALUES (NewId(), @EmployeeId_New1, @LeaveTypeId_New, @Entitlement_New, @Prorated, 'system', GetDate(), 1, @StartDate, @EndDate, @HrsettingDetailId, 1, @Entitlement_New, @Prorated, @Prorated, @BroughtForward, @IsEnabledLeaveRecommender1, @IsRequiredeLeaveRecommneder1, @IsRequiredeLeaveApprover1, @Entitlement_New)    
  --     end  
  --  END --12    
  --     END --11    
  --     ELSE IF ((@DepartmentId_New IS NOT NULL AND @DepartmentId_New != @EmptyGuid) AND (@DesignationId_New IS NULL OR @DesignationId_New = @EmptyGuid))    
  --     BEGIN --13    
  --     IF (@EmpDepartmentid_New=@DepartmentId_New)    
  --     begin --mid   
  --  if not exists(select * from [HR].[LeaveEntitlement] where EmployeeID=@EmployeeId_New and LeaveTypeId=@LeaveTypeId_New and HrSettingDetaiId=@HrsettingDetailId and StartDate=@StartDate and EndDate=@EndDate)  
  -- begin  
  --     print 'Dept exist and desig not exist'   
  --  INSERT INTO  HR.LeaveEntitlement (Id,EmployeeId,LeaveTypeId,IsApplicable,AnnualLeaveEntitlement,LeaveApprovers, LeaveRecommenders,Prorated,ApprovedAndTaken,ApprovedAndNotTaken,Remarks,RecOrder,UserCreated,CreatedDate, ModifiedBy,ModifiedDate,Version,Status,StartDate,EndDate,BroughtForward,IsEnableLeaveRecommender,Adjustment,  
  --              Adjusted,CompletedMonth,RemainingProrated,[Current],LeaveBalance,Total,CarryForwardDays,Entitlementstatus,YTDLeaveBalance,FutureProrated,HrSettingDetaiId,IsNotRequiredApprover,IsNotRequiredRecommender)   
  --              VALUES   
  --              (NEWID(),@EmployeeId_New1,@LeaveTypeId_New,1,@Entitlement_New,null,null,@prorated,0,0,null,1,  
  --              'system',GETUTCDATE(),null,null,2,1,@startDate,@enddate,0,0,null,null,(DATEPART(m, GETUTCDATE())),@remainingProrated,  
  --              @prorated, @prorated,@futureprorated,@BroughtForward,1,@futureprorated,@futureprorated,@HrSettingDetailId,@IsRequiredeLeaveApprover1,@IsRequiredeLeaveRecommneder1)         
      
  --      --INSERT [HR].[LeaveEntitlement] ([Id], [EmployeeId], [LeaveTypeId], [AnnualleaveEntitlement], [Prorated], [UserCreated], [CreatedDate], [status], [startdate], [EndDate], [HRSettingDetaiId], [EntitlementStatus], [YTDLeaveBalance], [Current], [LeaveBalance], [CarryForwardDays], [IsEnableLeaveRecommender], [IsNotRequiredRecommender], [IsNotRequiredApprover], [FutureProrated])    
  --      --VALUES (NewId(), @EmployeeId_New1, @LeaveTypeId_New, @Entitlement_New, @Prorated, 'system', GetDate(), 1, @StartDate, @EndDate, @HrsettingDetailId, 1, @Entitlement_New, @Prorated, @Prorated, @BroughtForward, @IsEnabledLeaveRecommender1, @IsRequiredeLeaveRecommneder1, @IsRequiredeLeaveApprover1, @Entitlement_New)    
  --      end  
  --end --mid    
  --     END --13    
  --     ELSE IF ((@DepartmentId_New IS NULL OR @DepartmentId_New = @EmptyGuid) AND (@DesignationId_New IS NOT NULL AND @DesignationId_New != @EmptyGuid))    
  --     BEGIN --14    
  --      --PRINT 'Yes desig all'    
  --      --SELECT Designationid    
  --      --  FROM #AllDesignation_Tb    
  --        --select 'dept null all  desig '    
  --        --select @EmpDesignationId_New    
  --        --select Designationid from #AllDesignation_Tb where Designationid=@EmpDesignationId_New    
  --      IF exists (    
  --        --@EmpDesignationId_New = @DesignationId_New    
  --        select Designationid from #AllDesignation_Tb where Designationid=@EmpDesignationId_New    
  --       )    
  --      BEGIN --15    
  --       print 'Yes desig all'    
  --if not exists(select * from [HR].[LeaveEntitlement] where EmployeeID=@EmployeeId_New and LeaveTypeId=@LeaveTypeId_New and HrSettingDetaiId=@HrsettingDetailId and StartDate=@StartDate and EndDate=@EndDate)  
  -- begin  
  -- INSERT INTO  HR.LeaveEntitlement (Id,EmployeeId,LeaveTypeId,IsApplicable,AnnualLeaveEntitlement,LeaveApprovers, LeaveRecommenders,Prorated,ApprovedAndTaken,ApprovedAndNotTaken,Remarks,RecOrder,UserCreated,CreatedDate, ModifiedBy,ModifiedDate,Version,Status,StartDate,EndDate,BroughtForward,IsEnableLeaveRecommender,Adjustment,  
  --              Adjusted,CompletedMonth,RemainingProrated,[Current],LeaveBalance,Total,CarryForwardDays,Entitlementstatus,YTDLeaveBalance,FutureProrated,HrSettingDetaiId,IsNotRequiredApprover,IsNotRequiredRecommender)   
  --              VALUES   
  --              (NEWID(),@EmployeeId_New1,@LeaveTypeId_New,1,@Entitlement_New,null,null,@prorated,0,0,null,1,  
  --              'system',GETUTCDATE(),null,null,2,1,@startDate,@enddate,0,0,null,null,(DATEPART(m, GETUTCDATE())),@remainingProrated,  
  --              @prorated, @prorated,@futureprorated,@BroughtForward,1,@futureprorated,@futureprorated,@HrSettingDetailId,@IsRequiredeLeaveApprover1,@IsRequiredeLeaveRecommneder1)         
      
  --       --INSERT [HR].[LeaveEntitlement] ([Id], [EmployeeId], [LeaveTypeId], [AnnualleaveEntitlement], [Prorated], [UserCreated], [CreatedDate], [status], [startdate], [EndDate], [HRSettingDetaiId], [EntitlementStatus], [YTDLeaveBalance], [Current], [LeaveBalance], [CarryForwardDays], [IsEnableLeaveRecommender], [IsNotRequiredRecommender], [IsNotRequiredApprover], [FutureProrated])    
  --       --VALUES (NewId(), @EmployeeId_New1, @LeaveTypeId_New, @Entitlement_New, @Prorated, 'system', GetDate(), 1, @StartDate, @EndDate, @HrsettingDetailId, 1, @Entitlement_New, @Prorated, @Prorated, @BroughtForward, @IsEnabledLeaveRecommender1, @IsRequiredeLeaveRecommneder1, @IsRequiredeLeaveApprover1, @Entitlement_New)    
  --      end  
  --END --15    
  --     END --14    
  --    --END --10    
    
  --    SET @rec = @rec + 1    
  --   END --9         
  --  END --8    
    
  --  TRUNCATE TABLE #AllEmployee_Tbl    
    
  --  TRUNCATE TABLE #AllDesignation_Tb    
    
    SET @RecCount1 = @RecCount1 + 1    
   END --2    
    
   TRUNCATE TABLE #Leaves_Tbl    
   update HR.LeaveApplication set HRSettingDetailId=@HrsettingDetailId  where convert(date,StartDateTime)>=@StartDate and CompanyId=@CompanyId    
   SET @RecCount = @RecCount + 1    
  END --1    
    --END --M1    
    
  IF OBJECT_ID(N'tempdb..#AllEmployee_Tbl') IS NOT NULL    
  BEGIN    
   DROP TABLE #AllEmployee_Tbl    
  END    
    
  IF OBJECT_ID(N'tempdb..#Leaves_Tbl') IS NOT NULL    
  BEGIN    
   DROP TABLE #Leaves_Tbl    
  END    
    
  IF OBJECT_ID(N'tempdb..#AllDesignation_Tb') IS NOT NULL    
  BEGIN    
   DROP TABLE #AllDesignation_Tb    
  END    
  Insert into Common.JobStatus  (Id ,Module ,Jobname ,[Type] ,[Purpose] ,[StartDate] ,[EndDate] ,RecordsEffeted ,Remarks ,JobStatus )    
values (newid(),'HRCursor','Leave Entitlement Insertion','Job','New LeaveEntitlement Insert',@StartTime,getdate(),null,null,'Completed')    
  COMMIT TRANSACTION --s2    
 END TRY --s3    
    
 BEGIN CATCH    
  ROLLBACK TRANSACTION    
    DECLARE @ErrorMessage NVARCHAR(4000) --, @ErrorSeverity INT, @ErrorState INT;    
    
  SELECT @ErrorMessage = ERROR_MESSAGE() --, @ErrorSeverity = ERROR_SEVERITY(), @ErrorState = ERROR_STATE();    
    
  RAISERROR (@ErrorMessage, 16, 1);    
 END CATCH    
END 
GO
