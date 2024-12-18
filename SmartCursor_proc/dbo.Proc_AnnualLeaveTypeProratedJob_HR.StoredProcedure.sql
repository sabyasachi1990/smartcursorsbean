USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[Proc_AnnualLeaveTypeProratedJob_HR]    Script Date: 16-12-2024 9.20.11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[Proc_AnnualLeaveTypeProratedJob_HR]
AS
BEGIN
    DECLARE @Id UNIQUEIDENTIFIER --leave entitlement id
    DECLARE @STARTDATE DATETIME2(7) --HR setting start date 
    DECLARE @EMPSTARTDATE DATETIME2(7)
    DECLARE @LeaveTypeCreatedDate DATETIME2(7)
    DECLARE @ACCURALDAYS FLOAT
    DECLARE @ENTITLEMENT FLOAT
    DECLARE @RESETDATE DATETIME2(7) --HR setting end date 
    DECLARE @BroughtForward FLOAT
    DECLARE @Adjustment FLOAT
    DECLARE @ApprovedAndNotTaken FLOAT
    DECLARE @ApprovedAndTaken FLOAT
    DECLARE @ACCURALTYPE NVARCHAR(100)
    DECLARE @Prorated FLOAT
    DECLARE @RemainingProrated FLOAT
    DECLARE @EmployeeId UNIQUEIDENTIFIER 
    DECLARE @YTDbalance FLOAT
    DECLARE @StartTime DATETIME2(7) = GETDATE()

    BEGIN TRANSACTION

    BEGIN TRY
        CREATE TABLE #TempTableProratedLeaves (
			SNo int identity(1,1), 
            Id UNIQUEIDENTIFIER,
            STARTDATE DATETIME2(7),
            EMPSTARTDATE DATETIME2(7),
            LeaveTypeCreatedDate DATETIME2(7),
            ACCURALDAYS FLOAT,
            ENTITLEMENT FLOAT,
            RESETDATE DATETIME2(7),
            BroughtForward FLOAT,
            Adjustment FLOAT,
            ApprovedAndNotTaken FLOAT,
            ApprovedAndTaken FLOAT,
            ACCURALTYPE NVARCHAR(100),
            Prorated FLOAT,
            RemainingProrated FLOAT,
            EmployeeId UNIQUEIDENTIFIER,
            YTDbalance FLOAT
        )

        INSERT INTO #TempTableProratedLeaves (Id, STARTDATE, EMPSTARTDATE, LeaveTypeCreatedDate, ACCURALDAYS, ENTITLEMENT, RESETDATE, BroughtForward, Adjustment, ApprovedAndNotTaken, ApprovedAndTaken, ACCURALTYPE, Prorated, RemainingProrated, EmployeeId, YTDbalance)
        SELECT LE.Id, HRSD.[StartDate], EMP.Startdate, LT.[CreatedDate], ISNULL(LT.[AccuralDays], 0), LE.[AnnualLeaveEntitlement], HRSD.[EndDate], LE.[BroughtForward], CONVERT(FLOAT, ISNULL(LE.[Adjustment], 0)), LE.[ApprovedAndNotTaken], LE.[ApprovedAndTaken], LT.[LeaveAccuralType], LE.Prorated, LE.[RemainingProrated], LE.EmployeeId, ISNULL(LE.YTDLeaveBalance, 0)
        FROM [HR].[LeaveType] LT (NOLOCK)
        JOIN [HR].[LeaveEntitlement] LE (NOLOCK) ON LE.[LeaveTypeId] = LT.Id
        JOIN [Common].[HRSettings] HRS (NOLOCK) ON HRS.CompanyID = LT.CompanyID
        JOIN [Common].[HRSettingdetails] HRSD (NOLOCK) ON HRSD.[MasterId] = HRS.Id
        JOIN [Common].[Employee] CE (NOLOCK) ON CE.Id = LE.EmployeeId
        JOIN [HR].[Employment] EMP (NOLOCK) ON EMP.EmployeeId = CE.Id
        WHERE Convert(DATE, HRSD.EndDate) = Convert(DATE, HRS.[ResetLeaveBalanceDate]) AND LT.Name = 'Annual Leave'   and CE.STATUS = 1 AND LE.[HrSettingDetaiId] = HRSD.ID and (LT.IsMOM is null or IsMOM=0)
		ORDER BY LT.Companyid


        DECLARE @RowCount INT = (SELECT COUNT(*) FROM #TempTableProratedLeaves)
        DECLARE @Index INT = 1

        WHILE @Index <= @RowCount
        BEGIN
            SELECT @Id = Id,
                   @STARTDATE = STARTDATE,
                   @EMPSTARTDATE = EMPSTARTDATE,
                   @LeaveTypeCreatedDate = LeaveTypeCreatedDate,
                   @ACCURALDAYS = ACCURALDAYS,
                   @ENTITLEMENT = ENTITLEMENT,
                   @RESETDATE = RESETDATE,
                   @BroughtForward = BroughtForward,
                   @Adjustment = Adjustment,
                   @ApprovedAndNotTaken = ApprovedAndNotTaken,
                   @ApprovedAndTaken = ApprovedAndTaken,
                   @ACCURALTYPE = ACCURALTYPE,
                   @Prorated = Prorated,
                   @RemainingProrated = RemainingProrated,
                   @EmployeeId = EmployeeId,
                   @YTDbalance = YTDbalance
            FROM #TempTableProratedLeaves
            WHERE SNo = @Index

        IF (  CONVERT(DATE, @EMPSTARTDATE) < CONVERT(DATE, @RESETDATE) AND @ENTITLEMENT IS NOT NULL AND @ENTITLEMENT != 0)
			BEGIN --5
			DECLARE @ACCURALLEAVE INT = 0
			DECLARE @DIFFMONTH FLOAT = 0.0
			DECLARE @TestPRORATED FLOAT = 0
			set @PRORATED = 0
			set @REMAININGPRORATED = 0
			--DECLARE @FuturePRORATED FLOAT = 0
			declare @YearDate datetime2(7)

			SET @STARTDATE = CASE WHEN CONVERT(DATE, @EMPSTARTDATE) < CONVERT(DATE, @STARTDATE) THEN @STARTDATE ELSE @EMPSTARTDATE END;
			SET @YearDate = CASE WHEN CONVERT(DATE, @STARTDATE) < CONVERT(DATE, @LeaveTypeCreatedDate) THEN @LeaveTypeCreatedDate ELSE @STARTDATE END;
			SET @ACCURALLEAVE = CASE WHEN (DAY(EOMONTH(@YearDate)) - DATEPART(DAY, @YearDate) + 1) >= @ACCURALDAYS THEN 0 ELSE - 1 END;
			--SET @DIFFMONTH =(SELECT DBO.GETDATEDIFFERENCE (CONVERT(DATE,@YearDate),CONVERT(DATE,GETDATE()))); 
			SET @DIFFMONTH = CASE WHEN CONVERT(DATE, getdate()) < CONVERT(DATE, @YearDate) THEN 0 ELSE (
							SELECT DBO.GETDATEDIFFERENCE(CONVERT(DATE, @YearDate), CONVERT(DATE, GETDATE()))
							) END;
			SET @DIFFMONTH = @DIFFMONTH + (@ACCURALLEAVE);
			SET @TestPRORATED = (@DIFFMONTH * @ENTITLEMENT) / 12.0;

			SELECT @PRORATED = value1, @REMAININGPRORATED = value2
			FROM SplitDecimalValue(@TestPRORATED)

			

				UPDATE Common.Employee WITH (ROWLOCK)
				SET  AnnualPTDBalance = ((isnull(@PRORATED, 0) + isnull(@BroughtForward, 0) + @Adjustment) - (isnull(@ApprovedAndNotTaken, 0) + isnull(@ApprovedAndTaken, 0))),AnnualYTDBalance=@YTDbalance where id=@EmployeeId
				
			END --5

            SET @Index = @Index + 1
        END

      
        DROP TABLE #TempTableProratedLeaves

        -- Insert job status
        INSERT INTO Common.JobStatus (Id, Module, Jobname, [Type], [Purpose], [StartDate], [EndDate], RecordsEffeted, Remarks, JobStatus)
        VALUES (NEWID(), 'HRCursor', 'Annual Leave Proration Job', 'Job', 'Annual Leave Proration Job', @StartTime, GETDATE(), NULL, NULL, 'Completed')

        COMMIT TRANSACTION
    END TRY

    BEGIN CATCH
        ROLLBACK TRANSACTION

        DECLARE @ErrorMessage NVARCHAR(4000)
        SELECT @ErrorMessage = ERROR_MESSAGE()

        RAISERROR (@ErrorMessage, 16, 1)
    END CATCH
END
GO
