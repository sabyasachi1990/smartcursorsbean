USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[HR_NewEmployee_HolidaysNonWorking_Insert_Migration]    Script Date: 16-12-2024 9.20.10 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

--Exec [dbo].[HR_NewEmployee_HolidaysNonWorking_Insert_Migration] 1,'d2f79ca6-b375-8ac0-71cf-71c02fec2b79'
--Exec [dbo].[HR_NewEmployee_HolidaysNonWorking_Insert_Migration] 256,'4293C0C6-E93B-48B0-9C26-6BB2757D1327'

CREATE PROCEDURE [dbo].[HR_NewEmployee_HolidaysNonWorking_Insert_Migration] (@CompanyId BIGINT, @EmployeeId UNIQUEIDENTIFIER)
AS
BEGIN
	BEGIN TRANSACTION

	BEGIN TRY

		DECLARE @CalanderData_Tbl TABLE 
				(S_No INT Identity(1, 1), TimelogItemId UNIQUEIDENTIFIER, SubType NVARCHAR(500), ChargeType NVARCHAR(100), 
				TimeType NVARCHAR(100), StartDate DATETIME2(7), ApplyTo NVARCHAR(50), CalanderId UNIQUEIDENTIFIER)
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
		DECLARE @YearEndDate DATETIME2(7) = (SELECT DATEADD(yy, DATEDIFF(yy, 0, GETDATE()) + 1, - 1) AS LastDayOfYear)
		DECLARE @RemainingDatesTable TABLE (Dates DATETIME2(2))
		DECLARE @Weekends TABLE (Weekends NVARCHAR(20))
		DECLARE @DateL DATETIME2(7)

-----====================================================== INSERTING SATURDAY AND SUNDAY ======================================================------
		INSERT INTO @Weekends   
			SELECT WeekDay
			FROM common.WorkWeekSetUp
				WHERE EmployeeId IS NULL AND CompanyId = @CompanyId AND IsWorkingDay = 0


-----====================================================== INSERTING HOLIDAYS INTO TEMP TABLE ======================================================----
		INSERT INTO @CalanderData_Tbl 

			SELECT DISTINCT TL1.Id, TL1.SubType, TL1.ChargeType, TL1.TimeType, TL1.StartDate, CA.ApplyTo, CA.Id
			FROM Common.TimeLogItem TL
				JOIN Common.TimeLogItem TL1 ON TL.Id = TL1.SystemId
				JOIN Common.Calender CA ON TL.SystemId = CA.Id
					WHERE TL.SystemId = CA.Id AND CA.STATUS = 1 AND TL1.Type = 'Holidays' AND CA.CompanyId = @CompanyId and year(TL1.StartDate)=year(GETUTCDATE())


-----====================================================== COUNT OF RECORDS IN HOLIDAYS TEMP TABLE ======================================================----
		SET @TotalCount = (SELECT count(*)FROM @CalanderData_Tbl) 

-----====================================================== VALUES FOR DECLARED VARIABLES ======================================================----
		SELECT @FirstName = FirstName, @DepartmentId = DepartmentId, @DesignationId = DesignationId, @EntityId = CurrentServiceEnittyId
		FROM Common.Employee	
			WHERE id = @EmployeeId; 



-----====================================================== ALL DATES IN YEAR ======================================================----

	;WITH date_range (calc_date)
	AS (
		SELECT DATEADD(DAY, DATEDIFF(DAY, 0, @YearEndDate) - DATEDIFF(DAY, '2022-02-01', @YearEndDate), 0)--GETUTCDATE()
	
		UNION ALL
	
		SELECT DATEADD(DAY, 1, calc_date)
		FROM date_range
			WHERE DATEADD(DAY, 1, calc_date) <= @YearEndDate
		) 
	--SELECT calc_date FROM date_range		option (maxrecursion 365);


-----====================================================== INSERTING ALL DATES INTO TEMP TABLE ======================================================----
		INSERT INTO @RemainingDatesTable 
			SELECT calc_date
			FROM date_range
			OPTION (MAXRECURSION 400);

		---SELECT * FROM @RemainingDatesTable


-----====================================================== WHILE LOOP ======================================================----

WHILE @TotalCount >= @LoopCount
	BEGIN --1
		SELECT @SubType = SubType, @ChargeType = ChargeType, @TimeType = TimeType, @StartDate = StartDate, @CalanderId = CalanderId, @ApplyTo = ApplyTo
		FROM @CalanderData_Tbl
			WHERE S_No = @LoopCount

-----=================================== DECLARING ATTENDANCE ID ===================================----

			DECLARE @AttendanceId UNIQUEIDENTIFIER =  ( SELECT id
														FROM [Common].[Attendance]
														WHERE convert(DATE, [Date]) = convert(DATE, @StartDate) AND CompanyId = @CompanyId
													  )

			---SELECT @AttendanceId

-----=================================== IF ATTENDANCE ID NOT EXISTS IN ATTENDANCE DETAILS FOR WEEK DAYS ===================================----
IF (DATENAME(dw, @StartDate) NOT IN (SELECT * FROM @Weekends))
	BEGIN

	IF EXISTS (SELECT Id FROM Common.Attendance  WHERE ID = @AttendanceId AND convert(DATE, [Date]) = convert(DATE, @StartDate) AND CompanyId = @CompanyId)

		BEGIN
		
			IF (@ApplyTo = 'All') ---LOOP1

				BEGIN
					IF NOT EXISTS (SELECT Id FROM Common.AttendanceDetails WHERE AttendenceId = @AttendanceId AND AttendanceDate = @StartDate AND EmployeeId = @EmployeeId)

						BEGIN

							INSERT INTO [Common].[AttendanceDetails] (Id, EmployeeId, AttendenceId, UserCreated, CreatedDate, STATUS, EmployeeName, DepartmentId, DesignationId, ServiceEntityId, AttendanceType, CalanderId,CompanyId,AttendanceDate,DateValue)
							VALUES (NEWID(), @EmployeeId, @attendanceId, 'System', GETUTCDATE(), 1, @FirstName, @DepartmentId, @DesignationId, @EntityId, @ChargeType, @CalanderId,@CompanyId,convert(DATE, @StartDate),(cast ((replace(convert(varchar, @StartDate,102),'.','')) as bigint)))

						END

					ELSE
						BEGIN
							
							UPDATE Common.AttendanceDetails SET AttendanceType = @ChargeType, CalanderId = @CalanderId WHERE  AttendenceId = @attendanceId AND EmployeeId = @EmployeeId AND CONVERT(DATE,AttendanceDate) = CONVERT(DATE, @StartDate)
						
						END																		
				 END	

			ELSE
				BEGIN

					IF EXISTS (SELECT Id FROM Common.CalenderDetails WHERE MasterId = @CalanderId AND EmployeeId = @EmployeeId)
						BEGIN

							IF NOT EXISTS (SELECT Id FROM Common.AttendanceDetails WHERE AttendenceId = @AttendanceId AND AttendanceDate = @StartDate AND EmployeeId = @EmployeeId)

								BEGIN

									INSERT INTO [Common].[AttendanceDetails] (Id, EmployeeId, AttendenceId, UserCreated, CreatedDate, STATUS, EmployeeName, DepartmentId, DesignationId, ServiceEntityId, AttendanceType, CalanderId,CompanyId,AttendanceDate,DateValue)
									VALUES (NEWID(), @EmployeeId, @attendanceId, 'System', GETUTCDATE(), 1, @FirstName, @DepartmentId, @DesignationId, @EntityId, @ChargeType, @CalanderId,@CompanyId,convert(DATE, @StartDate),(cast ((replace(convert(varchar, @StartDate,102),'.','')) as bigint)))

								END

							ELSE
								BEGIN
									UPDATE Common.AttendanceDetails SET AttendanceType = @ChargeType, CalanderId = @CalanderId WHERE  AttendenceId = @attendanceId AND EmployeeId = @EmployeeId AND CONVERT(DATE,AttendanceDate) = CONVERT(DATE, @StartDate)
								END
						END

					------ELSE
					------	BEGIN
					------		IF NOT EXISTS (SELECT Id FROM Common.AttendanceDetails WHERE AttendenceId = @AttendanceId AND AttendanceDate = @StartDate AND EmployeeId = @EmployeeId)

					------			BEGIN

					------				SELECT @AttendanceId AS 'Attendance Id', 'ALL' AS TEST
					------				SELECT Id, AttendenceId,DATENAME(dw, @StartDate) FROM Common.AttendanceDetails WHERE AttendenceId = @AttendanceId AND AttendanceDate = @StartDate AND EmployeeId = @EmployeeId


					------				SELECT NEWID() as Id, @EmployeeId as EmpId, @AttendanceId AS AttendanceId, 'System' as CreatedBy, GETUTCDATE() as Date, 1, @FirstName as Name, 
					------					   @DepartmentId as Dept, @DesignationId as Desg, @EntityId as EntityId, @ChargeType as HolidayType, @CalanderId as CalanderId, @CompanyId as CompanyId,
					------					   convert(DATE, @StartDate) as StartDate, (cast ((replace(convert(varchar, @StartDate,102),'.','')) as bigint)) as [Day], @SubType as HolidayName,DATENAME(dw, @StartDate)

					------			END

					------		ELSE
					------			IF EXISTS (SELECT Id FROM Common.AttendanceDetails WHERE AttendenceId = @AttendanceId AND AttendanceDate = @StartDate AND EmployeeId = @EmployeeId)
					------			BEGIN
					------				SELECT @AttendanceId, @ChargeType, @StartDate, DATENAME(dw, @StartDate),@CalanderId, 'ALL' AS tEST
					------				SELECT CalanderId,DATENAME(dw, @StartDate) FROM Common.AttendanceDetails WHERE CompanyId = 256 AND EmployeeId = @EmployeeId AND AttendenceId = @AttendanceId
					------			END
						
					------	END
				END ---END OF LOOP1
	   END	

	ELSE
		BEGIN
			DECLARE @AttendanceMasterId2 uniqueidentifier = NEWID();

				INSERT INTO Common.Attendance (Id, CompanyId, DATE, STATUS)
				VALUES (@AttendanceMasterId2, @CompanyId, convert(DATE, @StartDate), 1)

			IF (@ApplyTo = 'All')
			BEGIN 
				IF NOT EXISTS ( SELECT id FROM Common.AttendanceDetails WHERE AttendenceId = @AttendanceMasterId2 AND EmployeeId = @EmployeeId AND CONVERT(date, AttendanceDate) = CONVERT(date, @StartDate))
				BEGIN

					INSERT INTO [Common].[AttendanceDetails] (Id, EmployeeId, AttendenceId, UserCreated, CreatedDate, STATUS, EmployeeName, DepartmentId, DesignationId, ServiceEntityId, AttendanceType, CalanderId,CompanyId,AttendanceDate,DateValue)
					VALUES (NEWID(), @EmployeeId, @AttendanceMasterId2, 'System', GETUTCDATE(), 1, @FirstName, @DepartmentId, @DesignationId, @EntityId, @ChargeType, @CalanderId,@CompanyId,convert(DATE, @StartDate),(cast ((replace(convert(varchar, @StartDate,102),'.','')) as bigint)))

				END

				ELSE				
					BEGIN
							
						UPDATE Common.AttendanceDetails SET AttendanceType = @ChargeType, CalanderId = @CalanderId WHERE  AttendenceId = @attendanceId AND EmployeeId = @EmployeeId AND CONVERT(DATE,AttendanceDate) = CONVERT(DATE, @StartDate)
					
					END					
			END

			ELSE
				BEGIN

					IF EXISTS (SELECT Id FROM Common.CalenderDetails WHERE MasterId = @CalanderId AND EmployeeId = @EmployeeId)
						BEGIN

							IF NOT EXISTS (SELECT Id FROM Common.AttendanceDetails WHERE AttendenceId = @AttendanceMasterId2 AND AttendanceDate = @StartDate AND EmployeeId = @EmployeeId)

								BEGIN

									INSERT INTO [Common].[AttendanceDetails] (Id, EmployeeId, AttendenceId, UserCreated, CreatedDate, STATUS, EmployeeName, DepartmentId, DesignationId, ServiceEntityId, AttendanceType, CalanderId,CompanyId,AttendanceDate,DateValue)
									VALUES (NEWID(), @EmployeeId, @AttendanceMasterId2, 'System', GETUTCDATE(), 1, @FirstName, @DepartmentId, @DesignationId, @EntityId, @ChargeType, @CalanderId,@CompanyId,convert(DATE, @StartDate),(cast ((replace(convert(varchar, @StartDate,102),'.','')) as bigint)))

								END

							ELSE
								BEGIN

									UPDATE Common.AttendanceDetails SET AttendanceType = @ChargeType, CalanderId = @CalanderId WHERE  AttendenceId = @attendanceId AND EmployeeId = @EmployeeId AND CONVERT(DATE,AttendanceDate) = CONVERT(DATE, @StartDate)

								END
						END
				 END
		
		END
	END

-----=================================== IF ATTENDANCE ID NOT EXISTS IN ATTENDANCE DETAILS FOR WEEKEND DAYS ===================================----

ELSE
	BEGIN

	IF EXISTS (SELECT Id FROM Common.Attendance  WHERE ID = @AttendanceId AND convert(DATE, [Date]) = convert(DATE, @StartDate) AND CompanyId = @CompanyId)

		BEGIN
		
			IF (@ApplyTo = 'All') ---LOOP1

				BEGIN
					IF NOT EXISTS (SELECT Id FROM Common.AttendanceDetails WHERE AttendenceId = @AttendanceId AND AttendanceDate = @StartDate AND EmployeeId = @EmployeeId)

						BEGIN

							INSERT INTO [Common].[AttendanceDetails] (Id, EmployeeId, AttendenceId, UserCreated, CreatedDate, STATUS, EmployeeName, DepartmentId, DesignationId, ServiceEntityId, AttendanceType, CalanderId,CompanyId,AttendanceDate,DateValue)
							VALUES (NEWID(), @EmployeeId, @attendanceId, 'System', GETUTCDATE(), 1, @FirstName, @DepartmentId, @DesignationId, @EntityId, @ChargeType, @CalanderId,@CompanyId,convert(DATE, @StartDate),(cast ((replace(convert(varchar, @StartDate,102),'.','')) as bigint)))

						END

					ELSE
						BEGIN
							
							UPDATE Common.AttendanceDetails SET AttendanceType = @ChargeType, CalanderId = @CalanderId WHERE  AttendenceId = @attendanceId AND EmployeeId = @EmployeeId AND CONVERT(DATE,AttendanceDate) = CONVERT(DATE, @StartDate)
						
						END																		
				 END	

			ELSE
				BEGIN

					IF EXISTS (SELECT Id FROM Common.CalenderDetails WHERE MasterId = @CalanderId AND EmployeeId = @EmployeeId)
						BEGIN

							IF NOT EXISTS (SELECT Id FROM Common.AttendanceDetails WHERE AttendenceId = @AttendanceId AND AttendanceDate = @StartDate AND EmployeeId = @EmployeeId)

								BEGIN

									INSERT INTO [Common].[AttendanceDetails] (Id, EmployeeId, AttendenceId, UserCreated, CreatedDate, STATUS, EmployeeName, DepartmentId, DesignationId, ServiceEntityId, AttendanceType, CalanderId,CompanyId,AttendanceDate,DateValue)
									VALUES (NEWID(), @EmployeeId, @attendanceId, 'System', GETUTCDATE(), 1, @FirstName, @DepartmentId, @DesignationId, @EntityId, @ChargeType, @CalanderId,@CompanyId,convert(DATE, @StartDate),(cast ((replace(convert(varchar, @StartDate,102),'.','')) as bigint)))

								END

							ELSE
								BEGIN

									UPDATE Common.AttendanceDetails SET AttendanceType = @ChargeType, CalanderId = @CalanderId WHERE  AttendenceId = @attendanceId AND EmployeeId = @EmployeeId AND CONVERT(DATE,AttendanceDate) = CONVERT(DATE, @StartDate)

								END
						END

					------ELSE
					------	BEGIN
					------		IF NOT EXISTS (SELECT Id FROM Common.AttendanceDetails WHERE AttendenceId = @AttendanceId AND AttendanceDate = @StartDate AND EmployeeId = @EmployeeId)

					------			BEGIN

					------				SELECT @AttendanceId AS 'Attendance Id', 'ALL' AS TEST
					------				SELECT Id, AttendenceId,DATENAME(dw, @StartDate) FROM Common.AttendanceDetails WHERE AttendenceId = @AttendanceId AND AttendanceDate = @StartDate AND EmployeeId = @EmployeeId


					------				SELECT NEWID() as Id, @EmployeeId as EmpId, @AttendanceId AS AttendanceId, 'System' as CreatedBy, GETUTCDATE() as Date, 1, @FirstName as Name, 
					------					   @DepartmentId as Dept, @DesignationId as Desg, @EntityId as EntityId, @ChargeType as HolidayType, @CalanderId as CalanderId, @CompanyId as CompanyId,
					------					   convert(DATE, @StartDate) as StartDate, (cast ((replace(convert(varchar, @StartDate,102),'.','')) as bigint)) as [Day], @SubType as HolidayName,DATENAME(dw, @StartDate)

					------			END

					------		ELSE
					------			IF EXISTS (SELECT Id FROM Common.AttendanceDetails WHERE AttendenceId = @AttendanceId AND AttendanceDate = @StartDate AND EmployeeId = @EmployeeId)
					------			BEGIN
					------				SELECT @AttendanceId, @ChargeType, @StartDate, DATENAME(dw, @StartDate),@CalanderId, 'ALL' AS tEST
					------				SELECT CalanderId,DATENAME(dw, @StartDate) FROM Common.AttendanceDetails WHERE CompanyId = 256 AND EmployeeId = @EmployeeId AND AttendenceId = @AttendanceId
					------			END
						
					------	END
				END ---END OF LOOP1
	   END	

	ELSE
		BEGIN
			DECLARE @AttendanceMasterId3 uniqueidentifier = NEWID();

				INSERT INTO Common.Attendance (Id, CompanyId, DATE, STATUS)
				VALUES (@AttendanceMasterId3, @CompanyId, convert(DATE, @StartDate), 1)

			IF (@ApplyTo = 'All')
			BEGIN --m1
				IF NOT EXISTS ( SELECT id FROM Common.AttendanceDetails WHERE AttendenceId = @AttendanceMasterId3 AND EmployeeId = @EmployeeId AND CONVERT(date, AttendanceDate) = CONVERT(date, @StartDate))
				BEGIN

							INSERT INTO [Common].[AttendanceDetails] (Id, EmployeeId, AttendenceId, UserCreated, CreatedDate, STATUS, EmployeeName, DepartmentId, DesignationId, ServiceEntityId, AttendanceType, CalanderId,CompanyId,AttendanceDate,DateValue)
							VALUES (NEWID(), @EmployeeId, @AttendanceMasterId3, 'System', GETUTCDATE(), 1, @FirstName, @DepartmentId, @DesignationId, @EntityId, @ChargeType, @CalanderId,@CompanyId,convert(DATE, @StartDate),(cast ((replace(convert(varchar, @StartDate,102),'.','')) as bigint)))

				END

				ELSE				
					BEGIN
							
						UPDATE Common.AttendanceDetails SET AttendanceType = @ChargeType, CalanderId = @CalanderId WHERE  AttendenceId = @attendanceId AND EmployeeId = @EmployeeId AND CONVERT(DATE,AttendanceDate) = CONVERT(DATE, @StartDate)
					
					END					
			END

			ELSE
				BEGIN

					IF EXISTS (SELECT Id FROM Common.CalenderDetails WHERE MasterId = @CalanderId AND EmployeeId = @EmployeeId)
						BEGIN

							IF NOT EXISTS (SELECT Id FROM Common.AttendanceDetails WHERE AttendenceId = @AttendanceMasterId3 AND AttendanceDate = @StartDate AND EmployeeId = @EmployeeId)

								BEGIN

									INSERT INTO [Common].[AttendanceDetails] (Id, EmployeeId, AttendenceId, UserCreated, CreatedDate, STATUS, EmployeeName, DepartmentId, DesignationId, ServiceEntityId, AttendanceType, CalanderId,CompanyId,AttendanceDate,DateValue)
									VALUES (NEWID(), @EmployeeId, @AttendanceMasterId3, 'System', GETUTCDATE(), 1, @FirstName, @DepartmentId, @DesignationId, @EntityId, @ChargeType, @CalanderId,@CompanyId,convert(DATE, @StartDate),(cast ((replace(convert(varchar, @StartDate,102),'.','')) as bigint)))

								END

							ELSE
								BEGIN

									UPDATE Common.AttendanceDetails SET AttendanceType = @ChargeType, CalanderId = @CalanderId WHERE  AttendenceId = @attendanceId AND EmployeeId = @EmployeeId AND CONVERT(DATE,AttendanceDate) = CONVERT(DATE, @StartDate)
								
								END
						END
				 END
		
		END
	END

	SET @LoopCount = @LoopCount + 1;

	END


-----=================================================== CURSOR FOR INSERTING WEEK ENDS ===================================================------FOR TIME BEING COMMENTED BELOW CONDITION, REQUIRED PLEASE UN-COMMENT

	--	DECLARE Employee_cursor CURSOR
	--	FOR
	--	SELECT dates FROM @RemainingDatesTable WHERE datename(dw, dates) IN (SELECT * FROM @Weekends)

	--	OPEN Employee_cursor

	--	FETCH NEXT
	--	FROM Employee_cursor
	--	INTO @DateL

	--	WHILE @@FETCH_STATUS = 0
	--	BEGIN

	--	DECLARE @attendanceIdnew UNIQUEIDENTIFIER = (SELECT Id FROM Common.Attendance  WHERE ID = @AttendanceId AND convert(DATE, [Date]) = convert(DATE, @StartDate) AND CompanyId = @CompanyId)

	--	 IF EXISTS (SELECT id FROM [Common].[Attendance] WHERE convert(DATE, [Date]) = convert(DATE, @DateL) AND CompanyId = @CompanyId)

	--		BEGIN --21

	--			IF NOT EXISTS (SELECT ID FROM Common.AttendanceDetails WHERE AttendenceId = @attendanceIdnew AND CompanyId = @CompanyId AND EmployeeId =@EmployeeId)

	--				BEGIN

	--					INSERT INTO [Common].[AttendanceDetails] (Id, EmployeeId, AttendenceId, UserCreated, CreatedDate, STATUS, EmployeeName, DepartmentId, DesignationId, ServiceEntityId, AttendanceType,CompanyId,AttendanceDate,DateValue)
	--					VALUES (NEWID(), @EmployeeId, @attendanceIdnew, 'System', GETUTCDATE(), 1, @FirstName, @DepartmentId, @DesignationId, @EntityId, 'Non-Working',@CompanyId,convert(DATE, @DateL),(cast ((replace(convert(varchar, @DateL,102),'.','')) as bigint)))
					
	--				END --21


	--				ELSE IF EXISTS (SELECT ID FROM Common.AttendanceDetails WHERE AttendenceId = @attendanceIdnew AND CompanyId = @CompanyId AND EmployeeId =@EmployeeId)
					
	--				BEGIN
					
	--				SELECT @ChargeType
					
	--				END

	--	ELSE

	--		BEGIN --22

	--			DECLARE @AttendanceMasterIdNew1 UNIQUEIDENTIFIER = Newid(); --- FOR ATTENDANCE

	--			INSERT INTO Common.Attendance (Id, CompanyId, DATE, STATUS)
	--			VALUES (@AttendanceMasterIdNew1, @CompanyId, convert(DATE, @DateL), 1)

	--			--- INSERT INTO ATTENDANCEDETAILS

	--			INSERT INTO [Common].[AttendanceDetails] (Id, EmployeeId, AttendenceId, UserCreated, CreatedDate, STATUS, EmployeeName, DepartmentId, DesignationId, ServiceEntityId, AttendanceType,CompanyId,AttendanceDate,DateValue)
	--			VALUES (NEWID(), @EmployeeId, @AttendanceMasterIdNew1, 'System', GETUTCDATE(), 1, @FirstName, @DepartmentId, @DesignationId, @EntityId, 'Non-Working',@CompanyId,convert(DATE, @DateL),(cast ((replace(convert(varchar, @DateL,102),'.','')) as bigint)))


	--		END --22

	--		FETCH NEXT FROM Employee_cursor INTO @DateL
	--	END

	--END

	--	CLOSE Employee_cursor

	--	DEALLOCATE Employee_cursor;



	COMMIT TRANSACTION
	END TRY

	BEGIN CATCH
		ROLLBACK TRANSACTION

		DECLARE @ErrorMessage NVARCHAR(4000) --, @ErrorSeverity INT, @ErrorState INT;

		SELECT @ErrorMessage = ERROR_MESSAGE() --, @ErrorSeverity = ERROR_SEVERITY(), @ErrorState = ERROR_STATE();		

		RAISERROR (@ErrorMessage, 16, 1)
	END CATCH
END









-----======================================================= OLD =======================================================----


--------		DECLARE @CalanderData_Tbl TABLE (S_No INT Identity(1, 1), TimelogItemId UNIQUEIDENTIFIER, SubType NVARCHAR(500), ChargeType NVARCHAR(100), TimeType NVARCHAR(100), StartDate DATETIME2(7), ApplyTo NVARCHAR(50), CalanderId UNIQUEIDENTIFIER)
--------		DECLARE @TotalCount INT
--------		DECLARE @LoopCount INT = 1
--------		DECLARE @SubType NVARCHAR(500)
--------		DECLARE @ChargeType NVARCHAR(100)
--------		DECLARE @TimeType NVARCHAR(100)
--------		DECLARE @StartDate DATETIME2(7)
--------		DECLARE @ApplyTo NVARCHAR(200)
--------		DECLARE @FirstName NVARCHAR(1000)
--------		DECLARE @DepartmentId UNIQUEIDENTIFIER
--------		DECLARE @DesignationId UNIQUEIDENTIFIER
--------		DECLARE @EntityId BIGINT
--------		DECLARE @CalanderId UNIQUEIDENTIFIER
--------		DECLARE @YearEndDate DATETIME2(7) = (
--------				SELECT DATEADD(yy, DATEDIFF(yy, 0, GETDATE()) + 1, - 1) AS LastDayOfYear
--------				)
--------		DECLARE @RemainingDatesTable TABLE (Dates DATETIME2(2))
--------		DECLARE @Weekends TABLE (Weekends NVARCHAR(20))
--------		DECLARE @DateL DATETIME2(7)

--------		--print @YearEndDate
--------		INSERT INTO @Weekends
--------		SELECT WeekDay
--------		FROM common.WorkWeekSetUp
--------		WHERE EmployeeId IS NULL AND CompanyId = @CompanyId AND IsWorkingDay = 0

--------		INSERT INTO @CalanderData_Tbl
--------		SELECT DISTINCT TL1.Id, TL1.SubType, TL1.ChargeType, TL1.TimeType, TL1.StartDate, CA.ApplyTo, CA.Id
--------		FROM Common.TimeLogItem TL
--------		JOIN Common.TimeLogItem TL1 ON TL.Id = TL1.SystemId
--------		JOIN Common.Calender CA ON TL.SystemId = CA.Id
--------		WHERE TL.SystemId = CA.Id AND CA.STATUS = 1 AND TL1.Type = 'Holidays' AND CA.CompanyId = @CompanyId and year(TL1.StartDate)=year(GETUTCDATE())

--------		SET @TotalCount = (
--------				SELECT count(*)
--------				FROM @CalanderData_Tbl
--------				)

--------		SELECT @FirstName = FirstName, @DepartmentId = DepartmentId, @DesignationId = DesignationId, @EntityId = CurrentServiceEnittyId
--------		FROM Common.Employee	WHERE id = @EmployeeId;

		
--------	WITH date_range (calc_date)
--------AS (
--------	SELECT DATEADD(DAY, DATEDIFF(DAY, 0, @YearEndDate) - DATEDIFF(DAY, '2022-02-01', @YearEndDate), 0)--GETUTCDATE()
	
--------	UNION ALL
	
--------	SELECT DATEADD(DAY, 1, calc_date)
--------	FROM date_range
--------	WHERE DATEADD(DAY, 1, calc_date) <= @YearEndDate
--------	) 
--------	--SELECT calc_date FROM date_range		option (maxrecursion 365);

--------		INSERT INTO @RemainingDatesTable
--------		SELECT calc_date
--------		FROM date_range
--------		OPTION (MAXRECURSION 400);
--------		--select * from @RemainingDatesTable
--------		WHILE @TotalCount >= @LoopCount
--------		BEGIN --1
--------			SELECT @SubType = SubType, @ChargeType = ChargeType, @TimeType = TimeType, @StartDate = StartDate, @CalanderId = CalanderId, @ApplyTo = ApplyTo
--------			FROM @CalanderData_Tbl
--------			WHERE S_No = @LoopCount
--------			if  ( datename(dw, @StartDate)not IN (
--------				SELECT *
--------				FROM @Weekends
--------				))
--------				begin --11
--------			IF EXISTS (
--------					SELECT id
--------					FROM [Common].[Attendance]
--------					WHERE convert(DATE, [Date]) = convert(DATE, @StartDate) AND CompanyId = @CompanyId
--------					)
--------			BEGIN --2
--------				DECLARE @attendanceId UNIQUEIDENTIFIER = (
--------						SELECT id
--------						FROM [Common].[Attendance]
--------						WHERE convert(DATE, [Date]) = convert(DATE, @StartDate) AND CompanyId = @CompanyId
--------						)

--------				IF (@ApplyTo = 'All')
--------				BEGIN --m1
--------				if not exists(select id from Common.AttendanceDetails where AttendenceId=@attendanceId and EmployeeId=@EmployeeId and convert(DATE,AttendanceDate)=convert(DATE, @StartDate))
--------				begin 
--------				INSERT INTO [Common].[AttendanceDetails] (Id, EmployeeId, AttendenceId, UserCreated, CreatedDate, STATUS, EmployeeName, DepartmentId, DesignationId, ServiceEntityId, AttendanceType, CalanderId,CompanyId,AttendanceDate,DateValue)
--------					VALUES (NEWID(), @EmployeeId, @attendanceId, 'System', GETUTCDATE(), 1, @FirstName, @DepartmentId, @DesignationId, @EntityId, @ChargeType, @CalanderId,@CompanyId,convert(DATE, @StartDate),(cast ((replace(convert(varchar, @StartDate,102),'.','')) as bigint)))
--------				end
--------					else
--------					begin
--------					update Common.AttendanceDetails set AttendanceType=@ChargeType where  AttendenceId=@attendanceId and EmployeeId=@EmployeeId and convert(DATE,AttendanceDate)=convert(DATE, @StartDate)
--------					end
					
--------				END --m1
--------				ELSE IF EXISTS (
--------						SELECT id
--------						FROM Common.CalenderDetails
--------						WHERE MasterId = @CalanderId AND EmployeeId = @EmployeeId
--------						)
--------				BEGIN --m2
--------				if not exists(select id from Common.AttendanceDetails where AttendenceId=@attendanceId and EmployeeId=@EmployeeId and convert(DATE,AttendanceDate)=convert(DATE, @StartDate))
--------				begin 
--------					INSERT INTO [Common].[AttendanceDetails] (Id, EmployeeId, AttendenceId, UserCreated, CreatedDate, STATUS, EmployeeName, DepartmentId, DesignationId, ServiceEntityId, AttendanceType, CalanderId,CompanyId,AttendanceDate,DateValue)
--------					VALUES (NEWID(), @EmployeeId, @attendanceId, 'System', GETUTCDATE(), 1, @FirstName, @DepartmentId, @DesignationId, @EntityId, @ChargeType, @CalanderId,@CompanyId,convert(DATE, @StartDate),(cast ((replace(convert(varchar, @StartDate,102),'.','')) as bigint)))
--------				end
--------					else
--------					begin
--------					update Common.AttendanceDetails set AttendanceType=@ChargeType where  AttendenceId=@attendanceId and EmployeeId=@EmployeeId and convert(DATE,AttendanceDate)=convert(DATE, @StartDate)
--------					end
				
--------				END --m2
--------			END --2
--------			ELSE
--------			BEGIN --3
--------				DECLARE @AttendanceMasterId2 UNIQUEIDENTIFIER = newid();

--------				INSERT INTO Common.Attendance (Id, CompanyId, DATE, STATUS)
--------				VALUES (@AttendanceMasterId2, @CompanyId, convert(DATE, @StartDate), 1)

--------				IF (@ApplyTo = 'All')
--------				BEGIN --m1
--------				if not exists(select id from Common.AttendanceDetails where AttendenceId=@AttendanceMasterId2 and EmployeeId=@EmployeeId and convert(DATE,AttendanceDate)=convert(DATE, @StartDate))
--------				begin 
--------					INSERT INTO [Common].[AttendanceDetails] (Id, EmployeeId, AttendenceId, UserCreated, CreatedDate, STATUS, EmployeeName, DepartmentId, DesignationId, ServiceEntityId, AttendanceType, CalanderId,CompanyId,AttendanceDate,DateValue)
--------					VALUES (NEWID(), @EmployeeId, @AttendanceMasterId2, 'System', GETUTCDATE(), 1, @FirstName, @DepartmentId, @DesignationId, @EntityId, @ChargeType, @CalanderId,@CompanyId,convert(DATE, @StartDate),(cast ((replace(convert(varchar, @StartDate,102),'.','')) as bigint)))
--------				end
--------					else
--------					begin
--------					update Common.AttendanceDetails set AttendanceType=@ChargeType where  AttendenceId=@attendanceId and EmployeeId=@EmployeeId and convert(DATE,AttendanceDate)=convert(DATE, @StartDate)
--------					end
				
--------				END --m1
--------				ELSE IF EXISTS (
--------						SELECT id
--------						FROM Common.CalenderDetails
--------						WHERE MasterId = @CalanderId AND EmployeeId = @EmployeeId
--------						)
--------				BEGIN --m2
--------				if not exists(select id from Common.AttendanceDetails where AttendenceId=@AttendanceMasterId2 and EmployeeId=@EmployeeId and convert(DATE,AttendanceDate)=convert(DATE, @StartDate))
--------				begin 
--------					INSERT INTO [Common].[AttendanceDetails] (Id, EmployeeId, AttendenceId, UserCreated, CreatedDate, STATUS, EmployeeName, DepartmentId, DesignationId, ServiceEntityId, AttendanceType, CalanderId,CompanyId,AttendanceDate,DateValue)
--------					VALUES (NEWID(), @EmployeeId, @AttendanceMasterId2, 'System', GETUTCDATE(), 1, @FirstName, @DepartmentId, @DesignationId, @EntityId, @ChargeType, @CalanderId,@CompanyId,convert(DATE, @StartDate),(cast ((replace(convert(varchar, @StartDate,102),'.','')) as bigint)))
--------				end
--------					else
--------					begin
--------					update Common.AttendanceDetails set AttendanceType=@ChargeType where  AttendenceId=@attendanceId and EmployeeId=@EmployeeId and convert(DATE,AttendanceDate)=convert(DATE, @StartDate)
--------					end
				 
--------				END --m2
--------			END --3
--------			end--11
--------			SET @LoopCount = @LoopCount + 1;
			
--------		END --1
			

--------		DECLARE Employee_cursor CURSOR
--------		FOR
--------		SELECT dates
--------		FROM @RemainingDatesTable
--------		WHERE datename(dw, dates) IN (
--------				SELECT *
--------				FROM @Weekends
--------				)

--------		OPEN Employee_cursor

--------		FETCH NEXT
--------		FROM Employee_cursor
--------		INTO @DateL

--------		WHILE @@FETCH_STATUS = 0
--------		BEGIN
--------			IF EXISTS (
--------					SELECT id
--------					FROM [Common].[Attendance]
--------					WHERE convert(DATE, [Date]) = convert(DATE, @DateL) AND CompanyId = @CompanyId
--------					)
--------			BEGIN --21
--------				DECLARE @attendanceIdnew UNIQUEIDENTIFIER = (
--------						SELECT id
--------						FROM [Common].[Attendance]
--------						WHERE convert(DATE, [Date]) = convert(DATE, @DateL) AND CompanyId = @CompanyId
--------						)
--------						--print datename(dw, @DateL)
--------				INSERT INTO [Common].[AttendanceDetails] (Id, EmployeeId, AttendenceId, UserCreated, CreatedDate, STATUS, EmployeeName, DepartmentId, DesignationId, ServiceEntityId, AttendanceType,CompanyId,AttendanceDate,DateValue)
--------				VALUES (NEWID(), @EmployeeId, @attendanceIdnew, 'System', GETUTCDATE(), 1, @FirstName, @DepartmentId, @DesignationId, @EntityId, 'Non-Working',@CompanyId,convert(DATE, @DateL),(cast ((replace(convert(varchar, @DateL,102),'.','')) as bigint)))
--------			END --21
--------			ELSE
--------			BEGIN --22
--------				DECLARE @AttendanceMasterIdNew1 UNIQUEIDENTIFIER = newid();

--------				INSERT INTO Common.Attendance (Id, CompanyId, DATE, STATUS)
--------				VALUES (@AttendanceMasterIdNew1, @CompanyId, convert(DATE, @DateL), 1)

--------				INSERT INTO [Common].[AttendanceDetails] (Id, EmployeeId, AttendenceId, UserCreated, CreatedDate, STATUS, EmployeeName, DepartmentId, DesignationId, ServiceEntityId, AttendanceType,CompanyId,AttendanceDate,DateValue)
--------				VALUES (NEWID(), @EmployeeId, @AttendanceMasterIdNew1, 'System', GETUTCDATE(), 1, @FirstName, @DepartmentId, @DesignationId, @EntityId, 'Non-Working',@CompanyId,convert(DATE, @DateL),(cast ((replace(convert(varchar, @DateL,102),'.','')) as bigint)))
--------			END --22

--------			FETCH NEXT
--------			FROM Employee_cursor
--------			INTO @DateL
--------		END

--------		CLOSE Employee_cursor

--------		DEALLOCATE Employee_cursor
GO
