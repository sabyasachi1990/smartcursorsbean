USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[HR_Employee_NonWorking_Insert]    Script Date: 16-12-2024 9.20.10 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE PROCEDURE [dbo].[HR_Employee_NonWorking_Insert] (@CompanyId BIGINT,@month int,@year int)
AS
BEGIN
	BEGIN TRANSACTION

	BEGIN TRY
		DECLARE @CalanderData_Tbl TABLE (S_No INT Identity(1, 1), TimelogItemId UNIQUEIDENTIFIER, SubType NVARCHAR(500), ChargeType NVARCHAR(100), TimeType NVARCHAR(100), StartDate DATETIME2(7), ApplyTo NVARCHAR(50), CalanderId UNIQUEIDENTIFIER)
		

		DECLARE @MonthStartDate DATETIME2(7) = (select CAST(CAST(@year AS VARCHAR(4)) + '/' + CAST(@month AS VARCHAR(2)) + '/01' AS DATETIME2(7)));
				DECLARE @MonthEndDate DATETIME2(7) = dateadd(day,-1,dateadd(month,1,@MonthStartDate))
		DECLARE @RemainingDatesTable TABLE (Dates DATETIME2(2))
		DECLARE @Weekends TABLE (Weekends NVARCHAR(20))
		DECLARE @DateL DATETIME2(7)

		--print @MonthEndDate
		INSERT INTO @Weekends
		SELECT WeekDay
		FROM common.WorkWeekSetUp
		WHERE EmployeeId IS NULL AND CompanyId = @CompanyId AND IsWorkingDay = 0;

		WITH date_range(calc_date) AS (
				SELECT DATEADD(DAY, DATEDIFF(DAY, 0, @MonthEndDate) - DATEDIFF(DAY, @MonthStartDate, @MonthEndDate), 0)
				
				UNION ALL
				
				SELECT DATEADD(DAY, 1, calc_date)
				FROM date_range
				WHERE DATEADD(DAY, 1, calc_date) <= @MonthEndDate
				)

		--SELECT calc_date FROM date_range		option (maxrecursion 365);
		INSERT INTO @RemainingDatesTable
		SELECT calc_date
		FROM date_range
		OPTION (MAXRECURSION 400);

		--select * from @RemainingDatesTable
		DECLARE @Employeetable TABLE (S_No INT Identity(1, 1), EmployeeId UNIQUEIDENTIFIER, FirstName NVARCHAR(500), DepartmentId UNIQUEIDENTIFIER, DesignationId UNIQUEIDENTIFIER, EntityId BIGINT)

		INSERT INTO @Employeetable
		SELECT CE.Id, CE.FirstName, CE.DepartmentId, CE.DesignationId, CE.CurrentServiceEnittyId
		FROM Common.Employee CE
		JOIN HR.Employment HE ON CE.Id = HE.EmployeeId
		WHERE CE.CompanyId = @CompanyId AND (CE.STATUS = 1 OR YEAR(HE.EndDate) = @year)

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
		print @DateL
			IF EXISTS (
					SELECT id
					FROM [Common].[Attendance]
					WHERE convert(DATE, [Date]) = convert(DATE, @DateL) AND CompanyId = @CompanyId
					)
			BEGIN --21
				DECLARE @attendanceIdnew UNIQUEIDENTIFIER = (
						SELECT id
						FROM [Common].[Attendance]
						WHERE convert(DATE, [Date]) = convert(DATE, @DateL) AND CompanyId = @CompanyId
						)

				--print datename(dw, @DateL)
				INSERT INTO [Common].[AttendanceDetails] (Id, EmployeeId, AttendenceId, UserCreated, CreatedDate, STATUS, EmployeeName, DepartmentId, DesignationId, ServiceEntityId, AttendanceType,CompanyId,AttendanceDate,DateValue)
				SELECT NEWID(), EmployeeId, @attendanceIdnew, 'System', GETUTCDATE(), 1, FirstName, DepartmentId, DesignationId, EntityId, 'Non-Working',@CompanyId,convert(DATE, @DateL),(cast ((replace(convert(varchar, @DateL,102),'.','')) as bigint))
						FROM @Employeetable where EmployeeId not in (select EmployeeId from Common.AttendanceDetails where AttendenceId=@attendanceIdnew)
			END --21
			ELSE
			BEGIN --22
				DECLARE @AttendanceMasterIdNew1 UNIQUEIDENTIFIER = newid();

				INSERT INTO Common.Attendance (Id, CompanyId, DATE, STATUS)
				VALUES (@AttendanceMasterIdNew1, @CompanyId, convert(DATE, @DateL), 1)

				INSERT INTO [Common].[AttendanceDetails] (Id, EmployeeId, AttendenceId, UserCreated, CreatedDate, STATUS, EmployeeName, DepartmentId, DesignationId, ServiceEntityId, AttendanceType,CompanyId,AttendanceDate,DateValue)
				SELECT NEWID(), EmployeeId, @AttendanceMasterIdNew1, 'System', GETUTCDATE(), 1, FirstName, DepartmentId, DesignationId, EntityId, 'Non-Working',@CompanyId,convert(DATE, @DateL),(cast ((replace(convert(varchar, @DateL,102),'.','')) as bigint))
						FROM @Employeetable
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
