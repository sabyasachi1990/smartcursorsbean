USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[HR_Holiday_Migration]    Script Date: 16-12-2024 9.20.10 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE PROCEDURE [dbo].[HR_Holiday_Migration] (@CompanyId BIGINT, @month INT, @year INT)
AS
BEGIN
	BEGIN TRANSACTION

	BEGIN TRY
		DECLARE @CalanderId UNIQUEIDENTIFIER;
		DECLARE @status INT
		CREATE TABLE #CalanderData_Tbl  (S_No INT Identity(1, 1), TimelogItemId UNIQUEIDENTIFIER, SubType NVARCHAR(500), ChargeType NVARCHAR(100), TimeType NVARCHAR(100), StartDate DATETIME2(7), ApplyTo NVARCHAR(50))
		CREATE TABLE #Employeetable  (S_No INT Identity(1, 1), EmployeeId UNIQUEIDENTIFIER, FirstName NVARCHAR(500), DepartmentId UNIQUEIDENTIFIER, DesignationId UNIQUEIDENTIFIER, EntityId BIGINT)
		DECLARE Calander_cursor CURSOR
		FOR
		SELECT Id, STATUS
		FROM Common.Calender
		WHERE CompanyId = @CompanyId AND STATUS = 1 AND month(FromDateTime) = @month AND YEAR(FromDateTime) = @year and CalendarType='Holidays'

		OPEN Calander_cursor

		FETCH NEXT
		FROM Calander_cursor
		INTO @CalanderId, @status

		WHILE @@FETCH_STATUS = 0
		BEGIN --m1
		print 'Calender loop'
		 
			
			DECLARE @TotalCount INT
			DECLARE @LoopCount INT = 1
			DECLARE @StartDate DATETIME2(7)
			DECLARE @SubType NVARCHAR(500)
			DECLARE @ChargeType NVARCHAR(100)
			DECLARE @TimeType NVARCHAR(100)
			DECLARE @ApplyTo NVARCHAR(200)
			--delete @CalanderData_Tbl
			INSERT INTO #CalanderData_Tbl
			SELECT DISTINCT TL1.Id, TL1.SubType, TL1.ChargeType, TL1.TimeType, TL1.StartDate, CA.ApplyTo
			FROM Common.TimeLogItem TL
			JOIN Common.TimeLogItem TL1 ON TL.Id = TL1.SystemId
			JOIN Common.Calender CA ON TL.SystemId = CA.Id
			WHERE TL.SystemId = @CalanderId /*AND CA.STATUS = 1*/ AND CA.Id = @CalanderId AND TL1.Type = 'Holidays'
			 
			IF (@status = 1)
			BEGIN --1
				
				--delete #Employeetable
				SET @TotalCount = (
						SELECT count(*)
						FROM #CalanderData_Tbl
						)

				IF (@TotalCount > 0)
				BEGIN --k
					SET @ApplyTo = (
							SELECT ApplyTo
							FROM #CalanderData_Tbl
							WHERE S_No = 1
							)
							print @ApplyTo
					IF (@ApplyTo = 'All')
					BEGIN --i
						INSERT INTO #Employeetable
						SELECT CE.Id, CE.FirstName, CE.DepartmentId, CE.DesignationId, CE.CurrentServiceEnittyId
						FROM Common.Employee CE
						JOIN HR.Employment HE ON CE.Id = HE.EmployeeId
						WHERE CE.CompanyId = @CompanyId AND (CE.STATUS = 1 OR YEAR(HE.EndDate) = @year)
					END --i
					ELSE
					BEGIN --j
						INSERT INTO #Employeetable
						SELECT CE.Id, CE.FirstName, CE.DepartmentId, CE.DesignationId, CE.CurrentServiceEnittyId
						FROM Common.Employee CE
						JOIN HR.Employment HE ON CE.Id = HE.EmployeeId
						WHERE CE.CompanyId = @CompanyId AND (CE.STATUS = 1 OR YEAR(HE.EndDate) = @year )AND CE.Id IN (
								SELECT EmployeeId
								FROM Common.CalenderDetails
								WHERE MasterId = @CalanderId
								)
					END --j
				END --k

				WHILE @TotalCount >= @LoopCount
				BEGIN --2
				print 'while'
					SELECT @SubType = SubType, @ChargeType = ChargeType, @TimeType = TimeType, @StartDate = StartDate
					FROM #CalanderData_Tbl
					WHERE S_No = @LoopCount
					print @StartDate
					IF (CONVERT(DATE, @StartDate) > CONVERT(DATE, GETUTCDATE()))
					BEGIN --3
						IF EXISTS (
								SELECT id
								FROM [Common].[Attendance]
								WHERE convert(DATE, [Date]) = convert(DATE, @StartDate) AND CompanyId = @CompanyId
								)
						BEGIN --4
						print '@StartDate > todayDate'
							DECLARE @attendanceId UNIQUEIDENTIFIER = (
									SELECT id
									FROM [Common].[Attendance]
									WHERE convert(DATE, [Date]) = convert(DATE, @StartDate) AND CompanyId = @CompanyId
									)

							INSERT INTO [Common].[AttendanceDetails] (Id, EmployeeId, AttendenceId, UserCreated, CreatedDate, STATUS, EmployeeName, DepartmentId, DesignationId, ServiceEntityId, AttendanceType, CalanderId,CompanyId,AttendanceDate,DateValue)
							SELECT NEWID(), EmployeeId, @attendanceId, 'System', GETUTCDATE(), 1, FirstName, DepartmentId, DesignationId, EntityId, @ChargeType, @CalanderId,@CompanyId,@StartDate,(cast ((replace(convert(varchar, @StartDate,102),'.','')) as bigint))
							FROM #Employeetable
						END --4
						ELSE
						BEGIN --5
							DECLARE @AttendanceMasterId2 UNIQUEIDENTIFIER = newid();

							INSERT INTO Common.Attendance (Id, CompanyId, DATE, STATUS)
							VALUES (@AttendanceMasterId2, @CompanyId, convert(DATE, @StartDate), 1)

							INSERT INTO [Common].[AttendanceDetails] (Id, EmployeeId, AttendenceId, UserCreated, CreatedDate, STATUS, EmployeeName, DepartmentId, DesignationId, ServiceEntityId, AttendanceType, CalanderId,CompanyId,AttendanceDate,DateValue)
							SELECT NEWID(), EmployeeId, @AttendanceMasterId2, 'System', GETUTCDATE(), 1, FirstName, DepartmentId, DesignationId, EntityId, @ChargeType, @CalanderId,@CompanyId,@StartDate,(cast ((replace(convert(varchar, @StartDate,102),'.','')) as bigint))
							FROM #Employeetable
						END --5
					END --3
					ELSE
					BEGIN --6
					print '@StartDate < todayDate'
						IF EXISTS (
								SELECT id
								FROM [Common].[Attendance]
								WHERE convert(DATE, [Date]) = convert(DATE, @StartDate) AND CompanyId = @CompanyId
								)
						BEGIN --7
						print 'master exist'
							DECLARE @attendanceId1 UNIQUEIDENTIFIER = (
									SELECT id
									FROM [Common].[Attendance]
									WHERE convert(DATE, [Date]) = convert(DATE, @StartDate) AND CompanyId = @CompanyId
									)
									
							UPDATE [Common].[AttendanceDetails]
							SET CalanderId = @CalanderId, AttendanceType = @ChargeType
							WHERE AttendenceId = @attendanceId1 AND EmployeeId IN (
									SELECT EmployeeId
									FROM #Employeetable
									)
									print 'insert start'

							INSERT INTO [Common].[AttendanceDetails] (Id, EmployeeId, AttendenceId, UserCreated, CreatedDate, STATUS, EmployeeName, DepartmentId, DesignationId, ServiceEntityId, AttendanceType, CalanderId,CompanyId,AttendanceDate,DateValue)
							SELECT NEWID(), EmployeeId, @attendanceId1, 'System', GETUTCDATE(), 1, FirstName, DepartmentId, DesignationId, EntityId, @ChargeType, @CalanderId,@CompanyId,@StartDate,(cast ((replace(convert(varchar, @StartDate,102),'.','')) as bigint))
							FROM #Employeetable
							WHERE EmployeeId NOT IN (
									SELECT EmployeeId
									FROM Common.AttendanceDetails
									WHERE AttendenceId = @attendanceId1
									)
						END --7
						else 
						begin --mid
						print 'master not exist' 
						DECLARE @AttendanceMasterId5 UNIQUEIDENTIFIER = newid();

							INSERT INTO Common.Attendance (Id, CompanyId, DATE, STATUS)
							VALUES (@AttendanceMasterId5, @CompanyId, convert(DATE, @StartDate), 1)

							INSERT INTO [Common].[AttendanceDetails] (Id, EmployeeId, AttendenceId, UserCreated, CreatedDate, STATUS, EmployeeName, DepartmentId, DesignationId, ServiceEntityId, AttendanceType, CalanderId,CompanyId,AttendanceDate,DateValue)
							SELECT NEWID(), EmployeeId, @AttendanceMasterId5, 'System', GETUTCDATE(), 1, FirstName, DepartmentId, DesignationId, EntityId, @ChargeType, @CalanderId,@CompanyId,@StartDate,(cast ((replace(convert(varchar, @StartDate,102),'.','')) as bigint))
							FROM #Employeetable
						end--mid
					END --6

					SET @LoopCount = @LoopCount + 1
				END --2
				TRUNCATE TABLE #Employeetable
			END --1
			ELSE
			BEGIN --8
				PRINT 'InActive'

				SET @LoopCount = 1
				SET @TotalCount = (
						SELECT count(*)
						FROM #CalanderData_Tbl
						)

				PRINT @TotalCount

				WHILE @TotalCount >= @LoopCount
				BEGIN --9
					SELECT @SubType = SubType, @ChargeType = ChargeType, @TimeType = TimeType, @StartDate = StartDate
					FROM #CalanderData_Tbl
					WHERE S_No = @LoopCount

					PRINT 'In'

					IF (CONVERT(DATE, @StartDate) > CONVERT(DATE, GETUTCDATE()))
					BEGIN --10
						DELETE
						FROM Common.AttendanceDetails
						WHERE CalanderId = @CalanderId
					END --10
					ELSE
					BEGIN --11
						PRINT 'Update'

						DECLARE @attendanceIdnew UNIQUEIDENTIFIER = (
								SELECT id
								FROM [Common].[Attendance]
								WHERE convert(DATE, [Date]) = convert(DATE, @StartDate) AND CompanyId = @CompanyId
								)

						UPDATE Common.AttendanceDetails
						SET AttendanceType = NULL
						WHERE CalanderId = @CalanderId AND AttendenceId = @attendanceIdnew
					END --11

					SET @LoopCount = @LoopCount + 1
				END --9
			END --8
			TRUNCATE TABLE #CalanderData_Tbl			
			FETCH NEXT
			FROM Calander_cursor
			INTO @CalanderId, @status
		END --m1
		IF OBJECT_ID(N'tempdb..#CalanderData_Tbl') IS NOT NULL
BEGIN
DROP TABLE #CalanderData_Tbl
END
IF OBJECT_ID(N'tempdb..#Employeetable') IS NOT NULL
BEGIN
DROP TABLE #Employeetable
END
		CLOSE Calander_cursor

		DEALLOCATE Calander_cursor

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
