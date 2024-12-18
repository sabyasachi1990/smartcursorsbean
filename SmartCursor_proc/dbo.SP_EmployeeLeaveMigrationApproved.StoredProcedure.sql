USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[SP_EmployeeLeaveMigrationApproved]    Script Date: 16-12-2024 9.20.11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[SP_EmployeeLeaveMigrationApproved] (@CompanyId BIGINT, @month INT, @year INT)
AS
BEGIN --s1	
	BEGIN TRANSACTION --s2

	BEGIN TRY --s3
		DECLARE @EmployeeId UNIQUEIDENTIFIER
		DECLARE @LeaveApplicationId UNIQUEIDENTIFIER
		DECLARE @EnddateType NVARCHAR(10)
		DECLARE @Date DATETIME2(7)
		DECLARE @LeaveType NVARCHAR(20)
		DECLARE @SubType NVARCHAR(200)
		DECLARE @Employeename NVARCHAR(500)
		DECLARE @DepartmentId UNIQUEIDENTIFIER
		DECLARE @DesignationId UNIQUEIDENTIFIER
		DECLARE @EntityId BIGINT

		DECLARE Leave_cursor CURSOR
		FOR
		SELECT LA.EmployeeId, LA.Id, LA.EndDateType, TL.StartDate, LT.EntitlementType, LT.Name, CE.FirstName, CE.DepartmentId, CE.DesignationId, CE.CurrentServiceEnittyId
		FROM hr.LeaveApplication LA
		JOIN Common.TimeLogItem TL ON LA.Id = TL.SystemId
		JOIN Common.Employee CE ON LA.EmployeeId = CE.Id
		JOIN HR.LeaveType LT ON LA.LeaveTypeId = LT.Id
		WHERE LA.CompanyId = @CompanyId AND TL.CompanyId = @CompanyId AND CE.CompanyId = @CompanyId AND LA.LeaveStatus = 'Approved' AND month(TL.StartDate) = @month AND YEAR(TL.StartDate) = @year

		OPEN Leave_cursor

		FETCH NEXT
		FROM Leave_cursor
		INTO @EmployeeId, @LeaveApplicationId, @EnddateType, @Date, @LeaveType, @SubType, @Employeename, @DepartmentId, @DesignationId, @EntityId

		WHILE @@FETCH_STATUS = 0
		BEGIN
			--middile 
			--======================================Attendance==================================================
			IF NOT EXISTS (
					SELECT id
					FROM [Common].[Attendance]
					WHERE convert(DATE, [Date]) = convert(DATE, @Date) AND CompanyId = @CompanyId
					)
			BEGIN --mm
				PRINT 'not exist attendance'

				DECLARE @type NVARCHAR(200)

				IF (@LeaveType = 'Hours')
				BEGIN --ms
					SET @type = @SubType
				END --ms
				ELSE
				BEGIN --ms2
					SET @type = (@SubType + '(' + @EnddateType + ')');
				END --ms2

				DECLARE @AttendanceMasterId UNIQUEIDENTIFIER = newid();

				INSERT INTO Common.Attendance (Id, CompanyId, DATE, STATUS)
				VALUES (@AttendanceMasterId, @CompanyId, convert(DATE, @Date), 1)

				INSERT INTO [Common].[AttendanceDetails] (Id, EmployeeId, AttendenceId, UserCreated, CreatedDate, STATUS, EmployeeName, DepartmentId, DesignationId, ServiceEntityId, LeaveApplicationId, AttendanceType)
				VALUES (NEWID(), @EmployeeId, @AttendanceMasterId, 'System', GETutcDATE(), 1, @Employeename, @DepartmentId, @DesignationId, @EntityId, @LeaveApplicationId, @type)
			END --mm
			ELSE
			BEGIN --mm2
				PRINT 'exist attendance'

				DECLARE @AttendanceMasterId1 UNIQUEIDENTIFIER = (
						SELECT id
						FROM [Common].[Attendance]
						WHERE convert(DATE, [Date]) = convert(DATE, @Date) AND CompanyId = @CompanyId
						);
				DECLARE @type1 NVARCHAR(200)

				IF (@LeaveType = 'Hours')
				BEGIN --ms
					SET @type1 = @SubType
				END --ms
				ELSE
				BEGIN --ms2
					SET @type1 = (@SubType + '(' + @EnddateType + ')');
				END --ms2

				IF NOT EXISTS (
						SELECT *
						FROM Common.AttendanceDetails
						WHERE AttendenceId = @AttendanceMasterId1 AND EmployeeId = @EmployeeId
						)
				BEGIN --mm
					INSERT INTO [Common].[AttendanceDetails] (Id, EmployeeId, AttendenceId, UserCreated, CreatedDate, STATUS, EmployeeName, DepartmentId, DesignationId, ServiceEntityId, LeaveApplicationId, AttendanceType)
					VALUES (NEWID(), @EmployeeId, @AttendanceMasterId1, 'System', GETutcDATE(), 1, @Employeename, @DepartmentId, @DesignationId, @EntityId, @LeaveApplicationId, @type1)
				END --mm
				ELSE
				BEGIN --mm
					UPDATE Common.AttendanceDetails
					SET AttendanceType = @type1, LeaveApplicationId = @LeaveApplicationId
					WHERE AttendenceId = @AttendanceMasterId1 AND EmployeeId = @EmployeeId
				END --mm
			END --mm2
					----========================Attendance============================================================

			FETCH NEXT
			FROM Leave_cursor
			INTO @EmployeeId, @LeaveApplicationId, @EnddateType, @Date, @LeaveType, @SubType, @Employeename, @DepartmentId, @DesignationId, @EntityId
		END

		CLOSE Leave_cursor

		DEALLOCATE Leave_cursor

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
