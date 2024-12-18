USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[HR_NewEmployee_HolidaysNonWorking_Insert]    Script Date: 16-12-2024 9.20.10 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[HR_NewEmployee_HolidaysNonWorking_Insert] (@CompanyId BIGINT, @EmployeeId UNIQUEIDENTIFIER)
AS
BEGIN
	BEGIN TRANSACTION

	BEGIN TRY
		DECLARE @CalanderData_Tbl TABLE (S_No INT Identity(1, 1), TimelogItemId UNIQUEIDENTIFIER, SubType NVARCHAR(500), ChargeType NVARCHAR(100), TimeType NVARCHAR(100), StartDate DATETIME2(7), ApplyTo NVARCHAR(50), CalanderId UNIQUEIDENTIFIER)
		DECLARE @TotalCount INT
		DECLARE @LoopCount INT = 1
		DECLARE @SubType NVARCHAR(500)
		DECLARE @ChargeType NVARCHAR(100)
		DECLARE @TimeType NVARCHAR(100)
		DECLARE @StartDate DATETIME2(7)
		DECLARE @ApplyTo NVARCHAR(200)
		DECLARE @FirstName NVARCHAR(1000)
		DECLARE @DepartmentId UNIQUEIDENTIFIER
		DECLARE @DesignationId UNIQUEIDENTIFIER
		DECLARE @EntityId BIGINT
		DECLARE @CalanderId UNIQUEIDENTIFIER
		DECLARE @YearEndDate DATETIME2(7) = (
				SELECT DATEADD(yy, DATEDIFF(yy, 0, GETDATE()) + 1, - 1) AS LastDayOfYear
				)
		DECLARE @RemainingDatesTable TABLE (Dates DATETIME2(2))
		DECLARE @Weekends TABLE (Weekends NVARCHAR(20))
		DECLARE @DateL DATETIME2(7)

		--print @YearEndDate
		INSERT INTO @Weekends
		SELECT WeekDay
		FROM common.WorkWeekSetUp (NOLOCK)
		WHERE EmployeeId IS NULL AND CompanyId = @CompanyId AND IsWorkingDay = 0

		INSERT INTO @CalanderData_Tbl
		SELECT DISTINCT TL1.Id, TL1.SubType, TL1.ChargeType, TL1.TimeType, TL1.StartDate, CA.ApplyTo, CA.Id
		FROM Common.TimeLogItem TL (NOLOCK)
		JOIN Common.TimeLogItem TL1 (NOLOCK) ON TL.Id = TL1.SystemId
		JOIN Common.Calender CA (NOLOCK) ON TL.SystemId = CA.Id
		WHERE TL.SystemId = CA.Id AND CA.STATUS = 1 AND TL1.Type = 'Holidays' AND CA.CompanyId = @CompanyId and year(TL1.StartDate)=year(GETUTCDATE())

		SET @TotalCount = (
				SELECT count(*)
				FROM @CalanderData_Tbl
				)

		SELECT @FirstName = FirstName, @DepartmentId = DepartmentId, @DesignationId = DesignationId, @EntityId = CurrentServiceEnittyId
		FROM Common.Employee (NOLOCK) WHERE id = @EmployeeId;

		
	WITH date_range (calc_date)
AS (
	SELECT DATEADD(DAY, DATEDIFF(DAY, 0, @YearEndDate) - DATEDIFF(DAY, GETUTCDATE(), @YearEndDate), 0)
	
	UNION ALL
	
	SELECT DATEADD(DAY, 1, calc_date)
	FROM date_range
	WHERE DATEADD(DAY, 1, calc_date) <= @YearEndDate
	) 
	--SELECT calc_date FROM date_range		option (maxrecursion 365);

		INSERT INTO @RemainingDatesTable
		SELECT calc_date
		FROM date_range
		OPTION (MAXRECURSION 400);
		--select * from @RemainingDatesTable
		WHILE @TotalCount >= @LoopCount
		BEGIN --1
			SELECT @SubType = SubType, @ChargeType = ChargeType, @TimeType = TimeType, @StartDate = StartDate, @CalanderId = CalanderId, @ApplyTo = ApplyTo
			FROM @CalanderData_Tbl
			WHERE S_No = @LoopCount
			if  ( datename(dw, @StartDate)not IN (
				SELECT *
				FROM @Weekends
				))
				begin --11
			IF EXISTS (
					SELECT id
					FROM [Common].[Attendance] (NOLOCK)
					WHERE convert(DATE, [Date]) = convert(DATE, @StartDate) AND CompanyId = @CompanyId
					)
			BEGIN --2
				DECLARE @attendanceId UNIQUEIDENTIFIER = (
						SELECT id
						FROM [Common].[Attendance] (NOLOCK)
						WHERE convert(DATE, [Date]) = convert(DATE, @StartDate) AND CompanyId = @CompanyId
						)

				IF (@ApplyTo = 'All')
				BEGIN --m1
					INSERT INTO [Common].[AttendanceDetails] (Id, EmployeeId, AttendenceId, UserCreated, CreatedDate, STATUS, EmployeeName, DepartmentId, DesignationId, ServiceEntityId, AttendanceType, CalanderId,CompanyId,AttendanceDate,DateValue)
					VALUES (NEWID(), @EmployeeId, @attendanceId, 'System', GETUTCDATE(), 1, @FirstName, @DepartmentId, @DesignationId, @EntityId, @ChargeType, @CalanderId,@CompanyId,convert(DATE, @StartDate),(cast ((replace(convert(varchar, @StartDate,102),'.','')) as bigint)))
				END --m1
				ELSE IF EXISTS (
						SELECT id
						FROM Common.CalenderDetails (NOLOCK)
						WHERE MasterId = @CalanderId AND EmployeeId = @EmployeeId
						)
				BEGIN --m2
					INSERT INTO [Common].[AttendanceDetails] (Id, EmployeeId, AttendenceId, UserCreated, CreatedDate, STATUS, EmployeeName, DepartmentId, DesignationId, ServiceEntityId, AttendanceType, CalanderId,CompanyId,AttendanceDate,DateValue)
					VALUES (NEWID(), @EmployeeId, @attendanceId, 'System', GETUTCDATE(), 1, @FirstName, @DepartmentId, @DesignationId, @EntityId, @ChargeType, @CalanderId,@CompanyId,convert(DATE, @StartDate),(cast ((replace(convert(varchar, @StartDate,102),'.','')) as bigint)))
				END --m2
			END --2
			ELSE
			BEGIN --3
				DECLARE @AttendanceMasterId2 UNIQUEIDENTIFIER = newid();

				INSERT INTO Common.Attendance (Id, CompanyId, DATE, STATUS)
				VALUES (@AttendanceMasterId2, @CompanyId, convert(DATE, @StartDate), 1)

				IF (@ApplyTo = 'All')
				BEGIN --m1
					INSERT INTO [Common].[AttendanceDetails] (Id, EmployeeId, AttendenceId, UserCreated, CreatedDate, STATUS, EmployeeName, DepartmentId, DesignationId, ServiceEntityId, AttendanceType, CalanderId,CompanyId,AttendanceDate,DateValue)
					VALUES (NEWID(), @EmployeeId, @AttendanceMasterId2, 'System', GETUTCDATE(), 1, @FirstName, @DepartmentId, @DesignationId, @EntityId, @ChargeType, @CalanderId,@CompanyId,convert(DATE, @StartDate),(cast ((replace(convert(varchar, @StartDate,102),'.','')) as bigint)))
				END --m1
				ELSE IF EXISTS (
						SELECT id
						FROM Common.CalenderDetails (NOLOCK)
						WHERE MasterId = @CalanderId AND EmployeeId = @EmployeeId
						)
				BEGIN --m2
					INSERT INTO [Common].[AttendanceDetails] (Id, EmployeeId, AttendenceId, UserCreated, CreatedDate, STATUS, EmployeeName, DepartmentId, DesignationId, ServiceEntityId, AttendanceType, CalanderId,CompanyId,AttendanceDate,DateValue)
					VALUES (NEWID(), @EmployeeId, @AttendanceMasterId2, 'System', GETUTCDATE(), 1, @FirstName, @DepartmentId, @DesignationId, @EntityId, @ChargeType, @CalanderId,@CompanyId,convert(DATE, @StartDate),(cast ((replace(convert(varchar, @StartDate,102),'.','')) as bigint)))
				END --m2
			END --3
			end--11
			SET @LoopCount = @LoopCount + 1;
			
		END --1
			

		DECLARE Employee_cursor CURSOR
		FOR
		SELECT dates
		FROM @RemainingDatesTable
		WHERE datename(dw, dates) IN (
				SELECT *
				FROM @Weekends
				)

		OPEN Employee_cursor

		FETCH NEXT
		FROM Employee_cursor
		INTO @DateL

		WHILE @@FETCH_STATUS = 0
		BEGIN
			IF EXISTS (
					SELECT id
					FROM [Common].[Attendance] (NOLOCK)
					WHERE convert(DATE, [Date]) = convert(DATE, @DateL) AND CompanyId = @CompanyId
					)
			BEGIN --21
				DECLARE @attendanceIdnew UNIQUEIDENTIFIER = (
						SELECT id
						FROM [Common].[Attendance] (NOLOCK)
						WHERE convert(DATE, [Date]) = convert(DATE, @DateL) AND CompanyId = @CompanyId
						)
						--print datename(dw, @DateL)
				INSERT INTO [Common].[AttendanceDetails] (Id, EmployeeId, AttendenceId, UserCreated, CreatedDate, STATUS, EmployeeName, DepartmentId, DesignationId, ServiceEntityId, AttendanceType,CompanyId,AttendanceDate,DateValue)
				VALUES (NEWID(), @EmployeeId, @attendanceIdnew, 'System', GETUTCDATE(), 1, @FirstName, @DepartmentId, @DesignationId, @EntityId, 'Non-Working',@CompanyId,convert(DATE, @DateL),(cast ((replace(convert(varchar, @DateL,102),'.','')) as bigint)))
			END --21
			ELSE
			BEGIN --22
				DECLARE @AttendanceMasterIdNew1 UNIQUEIDENTIFIER = newid();

				INSERT INTO Common.Attendance (Id, CompanyId, DATE, STATUS)
				VALUES (@AttendanceMasterIdNew1, @CompanyId, convert(DATE, @DateL), 1)

				INSERT INTO [Common].[AttendanceDetails] (Id, EmployeeId, AttendenceId, UserCreated, CreatedDate, STATUS, EmployeeName, DepartmentId, DesignationId, ServiceEntityId, AttendanceType,CompanyId,AttendanceDate,DateValue)
				VALUES (NEWID(), @EmployeeId, @AttendanceMasterIdNew1, 'System', GETUTCDATE(), 1, @FirstName, @DepartmentId, @DesignationId, @EntityId, 'Non-Working',@CompanyId,convert(DATE, @DateL),(cast ((replace(convert(varchar, @DateL,102),'.','')) as bigint)))
			END --22

			FETCH NEXT
			FROM Employee_cursor
			INTO @DateL
		END

		CLOSE Employee_cursor

		DEALLOCATE Employee_cursor

		COMMIT TRANSACTION
	END TRY

	BEGIN CATCH
		ROLLBACK TRANSACTION

		DECLARE @ErrorMessage NVARCHAR(4000) --, @ErrorSeverity INT, @ErrorState INT;

		SELECT @ErrorMessage = ERROR_MESSAGE() --, @ErrorSeverity = ERROR_SEVERITY(), @ErrorState = ERROR_STATE();		

		RAISERROR (@ErrorMessage, 16, 1)
	END CATCH
END
GO
