USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[SP_HR_LeaveRuleEngineDailyJob]    Script Date: 16-12-2024 9.20.11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[SP_HR_LeaveRuleEngineDailyJob]
AS
BEGIN --s1	
	DECLARE @LeaveRuleEngineEmployeeTable TABLE (S_No INT Identity(1, 1), LeaveTypeId UNIQUEIDENTIFIER, CompanyId BIGINT, EmployeeId UNIQUEIDENTIFIER, HRsettingDetailId UNIQUEIDENTIFIER, LeaveEntitlementId UNIQUEIDENTIFIER, NoOfDays FLOAT, MaxLimit FLOAT, AnnualLeaveEntitlement FLOAT, Prorated FLOAT, Taken FLOAT, NotTaken FLOAT, BroughtForward FLOAT, Total FLOAT, Current1 FLOAT, LeaveBalance FLOAT, YTDBalance FLOAT, EmployeeStartDate DATETIME2(7), AccuralType NVARCHAR(50), PeriodStartDate DATETIME2(7), LeaveTyepCreateDate DATETIME2(7), PeriodEndDate DATETIME2(7))
	DECLARE @Count INT
	DECLARE @ReCount INT
	Declare @StartTime Datetime2(7)=(getdate())
	--select LT.[CompanyId],LR.[Value],LR.[NoOfDays],LR.[MaxLimit] from [HR].[LeaveType] LT join [HR].[LeaveRuleEngine] LR on  LT.Id=LR.[LeaveTypeId] where LT.[ApplyToAll]='Rule Based'and LR.[Condition]='Join year' 
	BEGIN TRANSACTION --s2

	BEGIN TRY --s3
		INSERT INTO @LeaveRuleEngineEmployeeTable
		SELECT Distinct LT.Id, CE.CompanyId, CE.Id, LE.[HrSettingDetaiId], LE.Id, LRE.[NoOfDays], LRE.[MaxLimit], LE.[AnnualLeaveEntitlement], LE.[Prorated], LE.[ApprovedAndTaken], LE.[ApprovedAndNotTaken], LE.[BroughtForward], LE.[Total], LE.[Current], LE.[LeaveBalance], LE.[YTDLeaveBalance], EH.[StartDate], LT.[LeaveAccuralType], HRSD.[StartDate], LT.[CreatedDate], HRSD.[EndDate]
		FROM [Common].[Employee] CE (NOLOCK)
		JOIN [HR].[EmployeeHistory] EH (NOLOCK) ON CE.Id = EH.EmployeeId
		JOIN [Common].[HRSettings] HRS (NOLOCK) ON CE.CompanyId = HRS.CompanyId
		JOIN [Common].[HRSettingdetails] HRSD (NOLOCK) ON HRS.Id = HRSD.MasterId
		JOIN [HR].[LeaveEntitlement] LE (NOLOCK) ON LE.Employeeid = CE.Id AND LE.[HrSettingDetaiId] = HRSD.Id
		JOIN [HR].[LeaveType] LT (NOLOCK) ON LT.Id = LE.[LeaveTypeId] AND LT.CompanyId = CE.CompanyId
		JOIN [HR].[LeaveRuleEngine] LRE (NOLOCK) ON LRE.[LeaveTypeId] = LT.Id
		WHERE CE.STATUS = 1 AND CE.IdType IS NOT NULL AND CE.[IsWorkflowOnly] = 0 AND EH.[EndDate] IS NULL AND day(EH.[StartDate]) = day(getdate()) AND month(EH.[StartDate]) = month(getdate()) AND Convert(DATE, HRSD.StartDate) <= Convert(DATE, getdate()) AND Convert(DATE, HRSD.EndDate) >= Convert(DATE, getdate()) AND LRE.[Condition] = 'Employment Start Date' AND LRE.[Value] = 'Years' and (LT.IsMOM is null or LT.IsMOM=0)
		ORDER BY CE.CompanyId

		SET @Count = (
				SELECT count(*)
				FROM @LeaveRuleEngineEmployeeTable
				)
		SET @ReCount = 1

		WHILE @Count >= @ReCount
		BEGIN --1
			DECLARE @LeaveEntitlementId1 UNIQUEIDENTIFIER
			DECLARE @EmployeeStartDate1 DATETIME2(7)
			DECLARE @EntitlementDays FLOAT
			DECLARE @Prorated1 FLOAT
			DECLARE @ApproveAndTaken1 FLOAT
			DECLARE @ApproveAndNotTaken1 FLOAT
			DECLARE @BroughtForward1 FLOAT
			DECLARE @Total1 FLOAT
			DECLARE @Current1 FLOAT
			DECLARE @LeaveBalance1 FLOAT
			DECLARE @YTDBalance1 FLOAT
			DECLARE @RuleDays FLOAT
			DECLARE @MaxLimit1 FLOAT
			DECLARE @AccuralType NVARCHAR(50)
			DECLARE @PeriodStartDate DATETIME2(7)
			DECLARE @LeaveTypeCreatedDate DATETIME2(7)
			DECLARE @PeriodEndDate DATETIME2(7)
			DECLARE @DiffMonth INT = 0
			DECLARE @RemainingProrated FLOAT
			DECLARE @FutureProrated FLOAT

			SELECT @LeaveEntitlementId1 = LeaveEntitlementId, @EmployeeStartDate1 = EmployeeStartDate, @EntitlementDays = AnnualLeaveEntitlement, @Prorated1 = Prorated, @ApproveAndTaken1 = Taken, @ApproveAndNotTaken1 = NotTaken, @BroughtForward1 = BroughtForward, @Total1 = Total, @Current1 = CURRENT1, @LeaveBalance1 = LeaveBalance, @YTDBalance1 = YTDBalance, @MaxLimit1 = MaxLimit, @AccuralType = AccuralType, @PeriodStartDate = PeriodStartDate, @LeaveTypeCreatedDate = LeaveTyepCreateDate, @PeriodEndDate = PeriodEndDate
			FROM @LeaveRuleEngineEmployeeTable
			WHERE S_No = @recount

			SET @RuleDays = (
					SELECT DATEDIFF(year, Convert(DATE, @EmployeeStartDate1), getdate())
					)

			IF (@RuleDays IS NOT NULL AND @RuleDays != 0 AND @RuleDays > @MaxLimit1)
			BEGIN --2
				SET @RuleDays = @MaxLimit1
			END --2
			ELSE
			BEGIN --3
				SET @RuleDays = @RuleDays
			END --3

			IF (@RuleDays IS NOT NULL AND @RuleDays != 0)
			BEGIN --4
				SET @EntitlementDays = isnull(@EntitlementDays, 0) + @RuleDays

				IF (@AccuralType = 'Monthly')
				BEGIN --5	
					DECLARE @STARTDATE DATETIME2(7)
					DECLARE @YearDate DATETIME2(7)

					SET @STARTDATE = @PeriodStartDate;
					SET @YearDate = CASE WHEN CONVERT(DATE, @STARTDATE) < CONVERT(DATE, @LeaveTypeCreatedDate) THEN @LeaveTypeCreatedDate ELSE @STARTDATE END;
					SET @DIFFMONTH = CASE WHEN CONVERT(DATE, getdate()) < CONVERT(DATE, @YearDate) THEN 0 ELSE (
									SELECT DBO.GETDATEDIFFERENCE(CONVERT(DATE, @YearDate), CONVERT(DATE, GETDATE()))
									) END;
					SET @DIFFMONTH = @DIFFMONTH

					IF (@DiffMonth IS NOT NULL AND @DiffMonth != 0)
					BEGIN --11
						DECLARE @TestPRORATED FLOAT = (@DIFFMONTH * @EntitlementDays) / 12.0;

						SELECT @Prorated1 = value1, @RemainingProrated = value2
						FROM SplitDecimalValue(@TestPRORATED)

						SELECT @FutureProrated = value1
						FROM SplitDecimalValue(@TestPRORATED)
					END --11
				END --5

				IF (@AccuralType = 'Yearly with proration' OR @AccuralType = 'Yearly without proration')
				BEGIN --6
					SET @Prorated1 = @EntitlementDays
					SET @FutureProrated = @EntitlementDays
				END --6

				UPDATE [HR].[LeaveEntitlement]
				SET [AnnualLeaveEntitlement] = @EntitlementDays, [Prorated] = @Prorated1, [FutureProrated] = @FutureProrated, [Current] = (isnull(@Prorated1, 0) + isnull(@BroughtForward1, 0) + convert(FLOAT, isnull([Adjustment], 0))), [LeaveBalance] = ((isnull(@Prorated1, 0) + isnull(@BroughtForward1, 0) + convert(FLOAT, isnull([Adjustment], 0))) - (isnull(@ApproveAndTaken1, 0) + isnull(@ApproveAndNotTaken1, 0))), [Total] = (isnull(@EntitlementDays, 0) + isnull(@BroughtForward1, 0) + convert(FLOAT, isnull([Adjustment], 0))), [YTDLeaveBalance] = ((isnull(@FutureProrated, 0) + isnull(@BroughtForward1, 0) + convert(FLOAT, isnull([Adjustment], 0))) - (isnull(@ApproveAndTaken1, 0) + isnull(@ApproveAndNotTaken1, 0)))
				WHERE id = @LeaveEntitlementId1
			END --4

			SET @ReCount = @ReCount + 1
		END --1
		Insert into Common.JobStatus  (Id ,Module ,Jobname ,[Type] ,[Purpose] ,[StartDate] ,[EndDate] ,RecordsEffeted ,Remarks ,JobStatus )
values (newid(),'HRCursor','RuleBasedDailyJob','Job','RuleBasedDailyJob',@StartTime,getdate(),null,null,'Completed')
		COMMIT TRANSACTION --s2
	END TRY --s3

	BEGIN CATCH
		ROLLBACK TRANSACTION

		DECLARE @ErrorMessage NVARCHAR(4000) --, @ErrorSeverity INT, @ErrorState INT;

		SELECT @ErrorMessage = ERROR_MESSAGE() --, @ErrorSeverity = ERROR_SEVERITY(), @ErrorState = ERROR_STATE();

		RAISERROR (@ErrorMessage, 16, 1);
	END CATCH
END
	--select * from [Common].[Employee] CE join [HR].[EmployeeHistory]  EH on CE.Id=EH.EmployeeId where CE.status=1 and CE.IdType is not null and [IsWorkflowOnly]=0 and Eh.[EndDate] is null and day(EH.[StartDate])=day(getdate()) and month(EH.[StartDate])=month(getdate())
GO
