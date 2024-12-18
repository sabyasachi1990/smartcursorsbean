USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[Proc_YearlyLeavesRuleReset_HR]    Script Date: 16-12-2024 9.20.11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[Proc_YearlyLeavesRuleReset_HR]
AS
BEGIN --s1
	DECLARE @CompanyId BIGINT
	DECLARE @HrsettingDetailId UNIQUEIDENTIFIER
	DECLARE @HrsettingId UNIQUEIDENTIFIER
	DECLARE @StartDate DATETIME
	DECLARE @EndDate DATETIME
	DECLARE @Prorated FLOAT
	Declare @StartTime Datetime2(7)=(getdate())
	DECLARE @AllCompany_Tbl TABLE (S_No INT Identity(1, 1), CompanyId BIGINT, HrsettingId UNIQUEIDENTIFIER, HrsettingDetailId UNIQUEIDENTIFIER, StartDate DATETIME, EndDate DATETIME)

	CREATE TABLE #AllEmployee_Tbl (S_No INT Identity(1, 1), EmployeeID UNIQUEIDENTIFIER)

	CREATE TABLE #Leaves_Tbl (S_No INT Identity(1, 1), LeaveTypeId UNIQUEIDENTIFIER, LeaveAccuralType NVARCHAR(200), LeaveType NVARCHAR(200), Condition NVARCHAR(30), Value NVARCHAR(30), NoOfDays FLOAT, MaxLimit FLOAT, EmpCount INT, LeaveRuleEngineId UNIQUEIDENTIFIER)

	DECLARE @AllPreviousPeriodEmployees_Tbl TABLE (S_No INT Identity(1, 1), EmpId UNIQUEIDENTIFIER, LTypeId UNIQUEIDENTIFIER, IsEnableLeaveRecommender BIT NULL, [IsNotRequiredRecommender] BIT NULL, [IsNotRequiredApprover] BIT NULL)

	CREATE TABLE #AllLeaveRuleEmployees_Tbl (S_No INT Identity(1, 1), EmployeeId UNIQUEIDENTIFIER)

	DECLARE @CompanyCount INT
	DECLARE @RecCount INT
	DECLARE @CategoryCount INT

	BEGIN TRANSACTION --s2

	BEGIN TRY --s3
		UPDATE [HR].[LeaveEntitlement]
		SET STATUS = 2 
		--[EntitlementStatus] = 2
		WHERE [HrSettingDetaiId] IN (
				SELECT Id
				FROM [Common].[HRSettingdetails] (NOLOCK)
				WHERE convert(DATE, [EndDate]) = dateadd(day, datediff(day, 1, GETDATE()), 0)
				)

		INSERT INTO @AllPreviousPeriodEmployees_Tbl
		SELECT [EmployeeId], [LeaveTypeId], [IsEnableLeaveRecommender], [IsNotRequiredRecommender], [IsNotRequiredApprover]
		FROM [HR].[LeaveEntitlement] (NOLOCK)
		WHERE [HrSettingDetaiId] IN (
				SELECT Id
				FROM [Common].[HRSettingdetails] (NOLOCK)
				WHERE convert(DATE, [EndDate]) = dateadd(day, datediff(day, 1, GETDATE()), 0)
				)

		INSERT INTO @AllCompany_Tbl
		SELECT HRS.CompanyId, HRS.Id, HRSD.ID, HRSD.StartDate, HRSD.EndDate
		FROM [Common].[HRSettings] HRS (NOLOCK)
		INNER JOIN [Common].[HRSettingdetails] HRSD (NOLOCK) ON HRS.Id = HRSD.[MasterId]
		WHERE convert(DATE, HRSD.[StartDate]) = convert(DATE, GETDATE())

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
			SELECT DISTINCT LT.ID, LT.LeaveAccuralType, LT.Name, LR.[Condition], LR.[Value], LR.[NoOfDays], LR.[MaxLimit], LR.[EmpCount], LR.Id
			FROM [HR].[LeaveType] LT (NOLOCK)
			JOIN [HR].[LeaveRuleEngine] LR (NOLOCK) ON LR.[LeaveTypeId] = LT.Id
			WHERE LT.STATUS = 1 AND LT.CompanyId = @CompanyId AND LT.[ApplyToAll] = 'Rule Based' and (LT.IsMOM is null or LT.IsMOM=0)

			SET @CategoryCount = (
					SELECT Count(*)
					FROM #Leaves_Tbl
					)

			DECLARE @RecCount1 INT = 1

			WHILE @CategoryCount >= @RecCount1
			BEGIN --2			
				DECLARE @LeaveTypeId_New UNIQUEIDENTIFIER
				DECLARE @LeaveAccuralType_New NVARCHAR(50)
				DECLARE @LeaveType_New NVARCHAR(200)
				DECLARE @Entitlement_New FLOAT
				DECLARE @MaxLimit FLOAT
				DECLARE @Condition NVARCHAR(30)
				DECLARE @Value NVARCHAR(30)
				DECLARE @EmployeeCount INT
				DECLARE @TotalCount INT
				DECLARE @LeaveRuleEngineId UNIQUEIDENTIFIER
				DECLARE @AllLeaveRuleEmployees_Tbl TABLE (S_No INT Identity(1, 1), EmployeeId UNIQUEIDENTIFIER)

				SELECT @LeaveTypeId_New = LeaveTypeId, @LeaveAccuralType_New = LeaveAccuralType, @LeaveType_New = LeaveType, @Condition = Condition, @Value = Value, @Entitlement_New = NoOfDays, @MaxLimit = MaxLimit, @TotalCount = [EmpCount], @LeaveRuleEngineId = LeaveRuleEngineId
				FROM #Leaves_Tbl
				WHERE S_No = @RecCount1

				INSERT INTO #AllLeaveRuleEmployees_Tbl
				SELECT [EmployeeId]
				FROM [HR].[LeaveRuleEngineEmployee] (NOLOCK)
				WHERE [LeaveRuleEngineId] = @LeaveRuleEngineId

				IF (@LeaveAccuralType_New = 'Monthly')
				BEGIN --3
					SET @PRORATED = 0;
				END --3

				IF (@LeaveAccuralType_New = 'Yearly with proration')
				BEGIN --4
					SET @PRORATED = @Entitlement_New;
				END --4

				IF (@LeaveAccuralType_New = 'Yearly without proration')
				BEGIN --5
					SET @PRORATED = @Entitlement_New;
				END --5

				IF (@Condition = 'Employment Start Date' OR @Condition = 'Date Of Birth')
				BEGIN --6
					INSERT INTO #AllEmployee_Tbl
					SELECT Id
					FROM Common.Employee (NOLOCK)
					WHERE CompanyId = @CompanyId AND IdType IS NOT NULL AND STATUS = 1
				END --6
				ELSE
				BEGIN --7
					IF (@Value != 'All')
					BEGIN --8
						INSERT INTO #AllEmployee_Tbl
						SELECT Id
						FROM Common.Employee (NOLOCK)
						WHERE CompanyId = @CompanyId AND IdType IS NOT NULL AND STATUS = 1 AND IdType = @Condition AND gender = @Value
					END --8
					ELSE
					BEGIN --9
						INSERT INTO #AllEmployee_Tbl
						SELECT Id
						FROM Common.Employee (NOLOCK)
						WHERE CompanyId = @CompanyId AND IdType IS NOT NULL AND STATUS = 1 AND IdType = @Condition
					END --9
				END --7

				DECLARE @TotalEmployeeCount INT = (
						SELECT count(*)
						FROM #AllEmployee_Tbl
						)
				DECLARE @EmpCount INT = 1

				WHILE @TotalEmployeeCount >= @EmpCount
				BEGIN --10
					DECLARE @EmpId UNIQUEIDENTIFIER
					DECLARE @IsEnabledLeaveRecommender BIT
					DECLARE @IsRequiredeLeaveRecommneder BIT
					DECLARE @IsRequiredeLeaveApprover BIT

					SELECT @EmpId = EmployeeID
					FROM #AllEmployee_Tbl
					WHERE S_No = @EmpCount

					IF NOT EXISTS (
							SELECT EmployeeId
							FROM #AllLeaveRuleEmployees_Tbl
							WHERE EmployeeId = @EmpId
							)
					BEGIN --11
						INSERT INTO [HR].[LeaveRuleEngineEmployee] ([Id], [EmployeeId], [LeaveRuleEngineId], [NoOfDays])
						VALUES (newid(), @EmpId, @LeaveRuleEngineId, @Entitlement_New)

						UPDATE [HR].[LeaveRuleEngine]
						SET [EmpCount] = isnull(@TotalCount, 0) + 1
						WHERE [Id] = @LeaveRuleEngineId
					END --11

					SELECT @IsEnabledLeaveRecommender = IsEnableLeaveRecommender, @IsRequiredeLeaveRecommneder = [IsNotRequiredRecommender], @IsRequiredeLeaveApprover = [IsNotRequiredApprover]
					FROM @AllPreviousPeriodEmployees_Tbl
					WHERE EmpId = @EmpId

					INSERT [HR].[LeaveEntitlement] ([Id], [EmployeeId], [LeaveTypeId], [AnnualleaveEntitlement], [Prorated], [UserCreated], [CreatedDate], [status], [startdate], [EndDate], [HRSettingDetaiId], [EntitlementStatus], [YTDLeaveBalance], [Current], [LeaveBalance], [IsEnableLeaveRecommender], [IsNotRequiredRecommender], [IsNotRequiredApprover], [FutureProrated])
					VALUES (NewId(), @EmpId, @LeaveTypeId_New, @Entitlement_New, @Prorated, 'system', GetDate(), 1, @StartDate, @EndDate, @HrsettingDetailId, 1, @Entitlement_New, @Prorated, @Prorated, @IsEnabledLeaveRecommender, @IsRequiredeLeaveRecommneder, @IsRequiredeLeaveApprover, @Entitlement_New)

					SET @EmpCount = @EmpCount + 1
				END --10	

				TRUNCATE TABLE #AllEmployee_Tbl;

				TRUNCATE TABLE #AllLeaveRuleEmployees_Tbl;

				SET @RecCount1 = @RecCount1 + 1
			END --2

			TRUNCATE TABLE #Leaves_Tbl;

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

		IF OBJECT_ID(N'tempdb..#AllLeaveRuleEmployees_Tbl') IS NOT NULL
		BEGIN
			DROP TABLE #AllLeaveRuleEmployees_Tbl
		END
		Insert into Common.JobStatus  (Id ,Module ,Jobname ,[Type] ,[Purpose] ,[StartDate] ,[EndDate] ,RecordsEffeted ,Remarks ,JobStatus )
values (newid(),'HRCursor','Rule Based YearlyJob','Job','Rule Based YearlyJob',@StartTime,getdate(),null,null,'Completed')
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
