USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[WF_TrainerSchedule2TimeLogItem_Insertion]    Script Date: 16-12-2024 9.20.11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

--->> EXEC [dbo].[WF_TrainerSchedule2TimeLogItem_Insertion] '00000000-0000-0000-0000-000000000000','96acf49d-0d2c-4542-ad69-2c6b93c95580',2058,'',NULL

CREATE PROCEDURE [dbo].[WF_TrainerSchedule2TimeLogItem_Insertion] @TrainerId UNIQUEIDENTIFIER, @TrainingId UNIQUEIDENTIFIER, @CompanyId BIGINT, @CourseName NVARCHAR(200), @TrainerIds NVARCHAR(max)
AS
BEGIN

----DECLARE 
----@TrainerId UNIQUEIDENTIFIER = NULL,--'5F1FB832-50A0-4955-AD5D-9DE07AB99779', 
----@TrainingId UNIQUEIDENTIFIER = '902433B6-302A-45C5-A05B-CFA5B4222348', 
----@CompanyId BIGINT = 1, 
----@CourseName NVARCHAR(20) = NULL, 
----@TrainerIds NVARCHAR(max) = 'CC51AC0E-6226-4965-A22F-40FFC6F43D43'
 
 
BEGIN TRANSACTION
BEGIN TRY
		CREATE TABLE #Companyuser_Tbl (S_No INT Identity(1, 1), IsExternalTrainer BIT, CompanyUserId BIGINT)

		IF (
				@TrainerId IS NULL OR @TrainerId = (
					SELECT CAST(0x0 AS UNIQUEIDENTIFIER)
					)
				)
		BEGIN

				--DECLARE @Trainers NVARCHAR(max)
				--SELECT @Trainers = COALESCE(@Trainers + ', ' + CAST(Id AS NVARCHAR(50)),CAST(Id AS NVARCHAR(50))) 					
				--		FROM 
				--		(SELECT TR.Id
				--		FROM HR.Training AS T (NOLOCK)
				--		JOIN HR.CourseLibrary AS c (NOLOCK) ON T.CourseLibraryId = c.Id
				--		JOIN HR.TrainerCourse AS TC (NOLOCK) ON TC.CourseLibraryId = C.Id
				--		JOIN HR.Trainer AS TR (NOLOCK) ON TC.TrainerId = TR.Id -- AND T.TrainerIds = TR.Id
				--		WHERE T.Id = @TrainingId
				--		) AS A


				DECLARE @Trainers NVARCHAR(max)
				SELECT @Trainers = COALESCE(@Trainers + ', ' + CAST(Id AS NVARCHAR(50)),CAST(Id AS NVARCHAR(50)))                     
						FROM 
						(SELECT TR.Id
							FROM HR.Training AS T (NOLOCK)
							JOIN HR.CourseLibrary AS c (NOLOCK) ON T.CourseLibraryId = c.Id
							JOIN HR.TrainerCourse AS TC (NOLOCK) ON TC.CourseLibraryId = C.Id
							JOIN HR.Trainer AS TR (NOLOCK) ON TC.TrainerId = TR.Id
							INNER JOIN (SELECT LTRIM(value) AS [Value]FROM HR.Training(NOLOCK) CROSS APPLY STRING_SPLIT(TrainerIds, ',') WHERE Id = @TrainingId) AS A
								ON A.value = TR.Id
							WHERE T.Id = @TrainingId
						) AS A
		END

SET @TrainerIds = @Trainers

		IF (@CourseName IS NULL OR @CourseName = '')
		BEGIN
			SET @CourseName = (
					SELECT c.CourseName
					FROM HR.Training AS T(NOLOCK)
					JOIN HR.CourseLibrary AS c(NOLOCK) ON T.CourseLibraryId = c.Id
					WHERE T.Id = @TrainingId
					)
		END

		DECLARE @StartDate DATE
		DECLARE @TrainingStatus NVARCHAR(20),@SystemId Uniqueidentifier

		SELECT @StartDate = StartDate
		FROM common.TimeLogItem(NOLOCK)
		WHERE SystemId = @TrainingId AND CompanyId = @CompanyId

-----=================================================== Cursor 1 =================================================================----
		DECLARE @FirstTimeLogItemId UniqueIdentifier
		BEGIN
			DECLARE TImeLog_Cursor CURSOR
			FOR
			
			SELECT StartDate,Id,SystemId FROM Common.TimeLogItem(NOLOCK)
			WHERE SystemId = @TrainingId AND SubType = @CourseName

			OPEN TImeLog_Cursor

			FETCH NEXT
			FROM TimeLog_Cursor INTO @StartDate,@FirstTimeLogItemId,@SystemId

			WHILE @@FETCH_STATUS = 0
			BEGIN

					SELECT @TrainingStatus = TrainingStatus
					FROM Hr.Training(NOLOCK)
					WHERE Id = @SystemId

					

					UPDATE Common.Attendancedetails SET TrainingId = NULL
					WHERE TrainingId IN (SELECT id FROM Common.TimeLogItem(NOLOCK) WHERE SystemId = @TrainingId AND StartDate = @StartDate )
						
					DELETE FROM Common.TimeLogItemDetail
					WHERE TimeLogItemId IN (@FirstTimeLogItemId)
						
					DELETE FROM Common.TimeLogItem WHERE Id = @FirstTimeLogItemId



				FETCH NEXT
				FROM TImeLog_Cursor INTO @StartDate,@FirstTimeLogItemId,@SystemId
			END

			CLOSE TImeLog_Cursor
			DEALLOCATE TImeLog_Cursor
		END

-----===========================================================================================================================-----

BEGIN ---->> 0

		SELECT @TrainingStatus = TrainingStatus
		FROM Hr.Training
		WHERE Id = @TrainingId


	IF (@TrainingStatus = 'Tentative' OR @TrainingStatus = 'Confirmed' OR @TrainingStatus = 'Completed' OR @TrainingStatus = 'Cancelled' OR @TrainingStatus = 'Registered')
	BEGIN ---->> 1
		DECLARE @IsExternal BIT, @CompanyUserId BIGINT, @CompanyUserCount INT, @Recount INT


		INSERT INTO #Companyuser_Tbl
		SELECT IsExternalTrainer, CompanyUserId
		FROM HR.Trainer(NOLOCK)
		WHERE (
				CAST(Id AS NVARCHAR(max)) IN (
					SELECT LTRIM(Items) AS Items
					FROM dbo.SplitToTable(@TrainerIds, ',')
					)
				)

				SET @CompanyUserCount = (SELECT Count(*) FROM #Companyuser_Tbl )
				SET @Recount = 1

		WHILE @CompanyUserCount >= @Recount --parvathi
		BEGIN ---->> 2
			SELECT @IsExternal = IsExternalTrainer, @CompanyUserId = CompanyUserId
			FROM #Companyuser_Tbl
			WHERE S_No = @Recount

			IF (@IsExternal = 0)
			BEGIN ---->> 3
				IF EXISTS (
						SELECT Id FROM Common.Employee (NOLOCK)
						WHERE CompanyId = @CompanyId AND UserName IN ( SELECT UserName FROM Common.CompanyUser(NOLOCK) WHERE Id = @CompanyUserId )
							)
					BEGIN---->> 4
							DECLARE @TrainingDate DATE, @EmployeeId UNIQUEIDENTIFIER

							SELECT @TrainingDate = TrainingDate
							FROM Hr.TrainingSchedule(NOLOCK)
							WHERE TrainingId = @TrainingId

							SELECT @EmployeeId = Id
							FROM common.Employee(NOLOCK)
							WHERE CompanyId = @CompanyId AND UserName IN ( SELECT UserName FROM Common.CompanyUser AS CU (NOLOCK)
																			JOIN Hr.Trainer AS t ON CU.Id = t.CompanyUserId WHERE CU.Id = @CompanyUserId )

-----===========================================================================================================----

                            BEGIN   ---->> 5 
                                DECLARE Trainer_Cursor CURSOR FOR
                                
								SELECT TrainingDate FROM Hr.TrainingSchedule(NOLOCK)
                                WHERE TrainingId = @TrainingId

                                OPEN Trainer_Cursor

                                FETCH NEXT FROM Trainer_Cursor  INTO @TrainingDate

                                WHILE @@FETCH_STATUS = 0
                                BEGIN  ---->> Cursor While Start
                                    DECLARE @Date DATE,  @NewId UNIQUEIDENTIFIER,  @hours DECIMAL(17, 2),  @FirstHalfFromTime TIME(7), @FirstHalfToTime TIME(7),
									@FirstHalfTotalHours TIME(7),  @SecondHalfFromTime TIME(7), @SecondHalfToTime TIME(7), @SecondHalfTotalHours TIME(7),
                                    @totalhours TIME(7), @sethours NVARCHAR(50),  @Aid UNIQUEIDENTIFIER

                                    SET @hours = 0

                                    IF (@TrainingStatus != 'Cancelled' /*AND @TrainingStatus != 'Completed'*/)
										BEGIN ----->> If @TrainingStatus != Cancelled Begin
											SELECT @FirstHalfFromTime = FirstHalfFromTime,
												   @FirstHalfToTime = FirstHalfToTime,
												   @FirstHalfTotalHours = FirstHalfTotalHours,
												   @SecondHalfFromTime = SecondHalfFromTime,
												   @SecondHalfToTime = SecondHalfToTime,
												   @SecondHalfTotalHours = SecondHalfTotalHours
											FROM Hr.TrainingSchedule AS TS(NOLOCK)
												JOIN Hr.Training AS TR(NOLOCK)
													ON TS.TrainingId = TR.Id
											WHERE TR.Id = @TrainingId
												  AND TS.TrainingDate = @TrainingDate

											SET @totalhours
												= dateadd(second, datediff(second, 0, @FirstHalfTotalHours), @SecondHalfTotalHours )
											SET @sethours = LEFT(@totalhours, 5)
											SET @sethours = REPLACE(@sethours, ':', '.')
											SET @hours = CONVERT(DECIMAL(17, 2), @sethours)
											SET @Date = @TrainingDate
											SET @NewId = NEWID()
											SET @Aid = NEWID()

											BEGIN   ----->> Cursor 2
												INSERT INTO Common.TimeLogItem --@TimeLogItem 
													(Id, CompanyId, Type, SubType, ChargeType, SystemType, SystemId, IsSystem, StartDate, EndDate, CreatedDate, Hours, ApplyToAll, Days, FirstHalfFromTime, FirstHalfToTime, FirstHalfTotalHours, SecondHalfFromTime, SecondHalfToTime, SecondHalfTotalHours,ActualHours) --->> Actual Hours added by Rambabu
												VALUES (@NewId, @CompanyId, 'Training', @CourseName, 'Non-Chargable', 'Training', @TrainingId, 1, @Date, @Date, GETDATE(), @hours, 0, 1, @FirstHalfFromTime, @FirstHalfToTime, @FirstHalfTotalHours, @SecondHalfFromTime, @SecondHalfToTime, @SecondHalfTotalHours,0.00)

												INSERT INTO Common.TimeLogItemDetail -- @TimeLogItemDetail 
													(Id, TimeLogItemId, EmployeeId)
												VALUES (NewId(), @NewId, @EmployeeId)


													IF EXISTS  ------>> If Else Start 1
													(SELECT * FROM common.Attendancedetails AS ad(NOLOCK) JOIN common.Attendance AS a(NOLOCK)  ON a.id = ad.AttendenceId
														WHERE a.DATE = @Date   AND employeeid = @EmployeeId
													)
														BEGIN  ----->> Cursor 3
															UPDATE ad SET ad.TrainingId = @NewId FROM common.Attendancedetails AS ad 
															JOIN common.Attendance AS a (NOLOCK)ON a.id = ad.AttendenceId
															WHERE a.DATE = @Date AND employeeid = @EmployeeId
														END	 ----->> Cursor 3
															ELSE
																BEGIN  ----->> Cursor 4
																	IF EXISTS ( SELECT * FROM common.Attendance(NOLOCK)  WHERE companyid = @companyid  AND DATE = @Date )
																		BEGIN
																			INSERT common.AttendanceDetails (id, AttendenceId, EmployeeId, EmployeeName, TrainingId, CompanyId, AttendanceDate, DateValue)
																			VALUES (
																				NEWID(), (
																					SELECT id
																					FROM common.Attendance (NOLOCK)
																					WHERE companyid = @companyid AND DATE = @Date
																					), @EmployeeId, (
																					SELECT FirstName
																					FROM Common.Employee (NOLOCK)
																					WHERE id = @EmployeeId
																					), @NewId, @CompanyId, @Date, (cast((replace(convert(VARCHAR, @Date, 102), '.', '')) AS BIGINT))
																					)
																		  END
																	ELSE IF NOT EXISTS ( SELECT * FROM common.Attendance(NOLOCK)  WHERE companyid = @companyid  AND DATE = @Date )
																		BEGIN
																			INSERT Common.Attendance (id, CompanyId, DATE, STATUS)
																			VALUES (@Aid, @CompanyId, @Date, 1)

																			INSERT common.AttendanceDetails (id, AttendenceId, EmployeeId, EmployeeName, TrainingId, CompanyId, AttendanceDate, DateValue)
																			VALUES (
																				NEWID(), @Aid, @EmployeeId, (
																					SELECT FirstName
																					FROM Common.Employee (NOLOCK)
																					WHERE id = @EmployeeId
																					), @NewId, @CompanyId, @Date, (cast((replace(convert(VARCHAR, @Date, 102), '.', '')) AS BIGINT))
																				)
																		END
																END  ----->> Cursor 4   ------>> If Else End 1
											END  ----->> Cursor 2
										END   ----->> If @TrainingStatus != Cancelled End                           
								   IF @TrainingStatus = 'Cancelled'
									BEGIN 

										UPDATE common.Attendancedetails  SET trainingid = NULL
										WHERE trainingid IN (SELECT id FROM Common.TimeLogItem(NOLOCK) WHERE SystemId = @TrainingId AND StartDate = @StartDate )
						
										DELETE FROM Common.TimeLogItemDetail
										WHERE TimeLogItemId IN (SELECT id FROM Common.TimeLogItem(NOLOCK) WHERE SystemId = @TrainingId AND StartDate = @StartDate)
						
										DELETE FROM Common.TimeLogItem WHERE SystemId = @TrainingId AND StartDate = @StartDate

									END
                                  FETCH NEXT FROM Trainer_Cursor INTO @TrainingDate
                                END  ---->> Cursor While Start
                                CLOSE Trainer_Cursor
                                DEALLOCATE Trainer_Cursor
                            END ---->> 5
-----===========================================================================================================----

				END ---->>4
			END ---->> 3
			SET @Recount = @Recount + 1
		END ---->> 2		
	END ---->> 1
END  ---->> 0

DROP TABLE #Companyuser_Tbl
-----===========================================================================================================----
		BEGIN
			BEGIN
				DECLARE @Date1 DATE, @EmployeeId1 UNIQUEIDENTIFIER, @NewId1 UNIQUEIDENTIFIER, @AttendanceDate DATE, @Aid1 UNIQUEIDENTIFIER

				SELECT @EmployeeId1 = TS.EmployeeId, @AttendanceDate = TS.AttendanceDate
				FROM Hr.TrainingAttendance AS TS(NOLOCK)
				JOIN Hr.Training AS TR(NOLOCK) ON TS.TrainingId = TR.Id
				WHERE TS.TrainingId = @TrainingId
-----=================================================== Cursor 3 =================================================================----

				DECLARE Training_Cursor CURSOR
				FOR

				SELECT TS.EmployeeId, TS.AttendanceDate
				FROM Hr.TrainingAttendance AS TS(NOLOCK)
				JOIN Hr.Training AS TR(NOLOCK) ON TS.TrainingId = TR.Id
				WHERE TS.TrainingId = @TrainingId

				OPEN Training_Cursor

				FETCH NEXT
				FROM Training_Cursor
				INTO @EmployeeId1, @AttendanceDate

				WHILE @@FETCH_STATUS = 0
				BEGIN
					DECLARE @EmployeeTrainingStatus NVARCHAR(20)

					SELECT @EmployeeTrainingStatus = EmployeeTrainigStatus
					FROM Hr.TrainingAttendee(NOLOCK)
					WHERE TrainingId = @TrainingId AND EmployeeId = @EmployeeId1

--SELECT @EmployeeTrainingStatus AS EmployeeTrainingStatus,@EmployeeId1 AS EmployeeId

											SELECT @FirstHalfFromTime = FirstHalfFromTime,
												   @FirstHalfToTime = FirstHalfToTime,
												   @FirstHalfTotalHours = FirstHalfTotalHours,
												   @SecondHalfFromTime = SecondHalfFromTime,
												   @SecondHalfToTime = SecondHalfToTime,
												   @SecondHalfTotalHours = SecondHalfTotalHours
											FROM Hr.TrainingSchedule AS TS(NOLOCK)
												JOIN Hr.Training AS TR(NOLOCK)
													ON TS.TrainingId = TR.Id
											WHERE TR.Id = @TrainingId
												  AND TS.TrainingDate = @TrainingDate

											SET @totalhours
												= dateadd(second, datediff(second, 0, @FirstHalfTotalHours), @SecondHalfTotalHours )
											SET @sethours = LEFT(@totalhours, 5)
											SET @sethours = REPLACE(@sethours, ':', '.')
											SET @hours = CONVERT(DECIMAL(17, 2), @sethours)
											SET @Date = @TrainingDate
											SET @NewId = NEWID()
											SET @Aid = NEWID()

					IF (@EmployeeTrainingStatus = 'Registered' OR @EmployeeTrainingStatus = 'Completed' OR @EmployeeTrainingStatus = 'Incompleted' OR @EmployeeTrainingStatus = 'Absent' OR @EmployeeTrainingStatus = 'Cancelled')
					BEGIN
						SET @Date1 = @AttendanceDate
						SET @NewId1 = NEWID()
						SET @Aid1 = NEWID()

						BEGIN
							IF (@EmployeeTrainingStatus = 'Registered'  OR @EmployeeTrainingStatus = 'Confirmed' OR @EmployeeTrainingStatus = 'Completed' OR @EmployeeTrainingStatus = 'Incompleted' OR @EmployeeTrainingStatus = 'Absent')
							BEGIN
							INSERT INTO Common.TimeLogItem --@TimeLogItem 
								(Id, CompanyId, Type, SubType, ChargeType, SystemType, SystemId, IsSystem, StartDate, EndDate, CreatedDate, ApplyToAll, Days)
							VALUES (@NewId1, @CompanyId, 'Training', @CourseName, 'Non-Chargable', 'Training', @TrainingId, 1, @Date1, @Date1, GETDATE(), 0, 1)

							INSERT INTO Common.TimeLogItemDetail -- @TimeLogItemDetail 
								(Id, TimeLogItemId, EmployeeId)
							VALUES (NewId(), @NewId1, @EmployeeId1)
							END
----==================================================================================================================----ADDED NEWLY BY RAMBABU ON 05-06-2023
							IF (@EmployeeTrainingStatus != 'Absent')
							BEGIN
							IF EXISTS (
									SELECT * FROM common.Attendancedetails AS ad(NOLOCK)
									JOIN common.Attendance AS a(NOLOCK) ON a.id = ad.AttendenceId
									WHERE a.DATE = @Date1 AND employeeid = @EmployeeId1
									)
								BEGIN
									UPDATE ad SET ad.TrainingId = @NewId1 FROM common.Attendancedetails AS ad 
									JOIN common.Attendance AS a (NOLOCK) ON a.id = ad.AttendenceId
									WHERE a.DATE = @Date1 AND employeeid = @EmployeeId1
								END							
							ELSE
								BEGIN
									IF EXISTS (
											SELECT * FROM common.Attendance(NOLOCK)
											WHERE companyid = @companyid AND DATE = @Date1
											)
									BEGIN
										INSERT common.AttendanceDetails (id, AttendenceId, EmployeeId, EmployeeName, TrainingId, CompanyId, AttendanceDate, DateValue)
										VALUES (
											NEWID(), (
												SELECT id
												FROM common.Attendance(NOLOCK)
												WHERE companyid = @companyid AND DATE = @Date1
												), @EmployeeId1, (
												SELECT FirstName
												FROM Common.Employee(NOLOCK)
												WHERE id = @EmployeeId1
												), @NewId1, @CompanyId, @Date1, (cast((replace(convert(VARCHAR, @Date1, 102), '.', '')) AS BIGINT))
											)

									END
										ELSE IF NOT EXISTS ( SELECT * FROM common.Attendance  WHERE companyid = @companyid  AND DATE = @Date )
											BEGIN

												INSERT Common.Attendance (id, CompanyId, DATE, STATUS)
												VALUES (@Aid1, @CompanyId, @Date1, 1)

												INSERT common.AttendanceDetails (id, AttendenceId, EmployeeId, EmployeeName, TrainingId, CompanyId, AttendanceDate, DateValue)
												VALUES (
													NEWID(), @Aid1, @EmployeeId1, (
														SELECT FirstName
														FROM Common.Employee(NOLOCK)
														WHERE id = @EmployeeId1
														), @NewId1, @CompanyId, @Date1, (cast((replace(convert(VARCHAR, @Date1, 102), '.', '')) AS BIGINT))
													)

											END
								END
							END
----==================================================================================================================----

							IF (@EmployeeTrainingStatus = 'Cancelled')
							BEGIN

								DECLARE @TimeLogItemId Uniqueidentifier = (SELECT TimeLogItemId FROM Common.TimeLogItemDetail
								WHERE TimeLogItemId IN (SELECT id FROM Common.TimeLogItem WHERE SystemId = @TrainingId AND StartDate = @StartDate )
								AND EmployeeId = @EmployeeId1)

								UPDATE common.Attendancedetails  SET trainingid = NULL
								WHERE trainingid IN (@TimeLogItemId )
						
								DELETE FROM Common.TimeLogItemDetail
								WHERE TimeLogItemId  IN (@TimeLogItemId)
													
								DELETE FROM Common.TimeLogItem WHERE  Id = @TimeLogItemId


							END


							--IF EXISTS (
							--		SELECT * FROM common.Attendancedetails AS ad(NOLOCK)
							--		JOIN common.Attendance AS a(NOLOCK) ON a.id = ad.AttendenceId
							--		WHERE a.DATE = @Date1 AND employeeid = @EmployeeId1
							--		)
							--	BEGIN
							--		UPDATE ad SET ad.TrainingId = @NewId1 FROM common.Attendancedetails AS ad
							--		JOIN common.Attendance AS a ON a.id = ad.AttendenceId
							--		WHERE a.DATE = @Date1 AND employeeid = @EmployeeId1
							--	END							
							--ELSE
							--	BEGIN
							--		IF EXISTS (
							--				SELECT * FROM common.Attendance(NOLOCK)
							--				WHERE companyid = @companyid AND DATE = @Date1
							--				)
							--		BEGIN
							--			INSERT common.AttendanceDetails (id, AttendenceId, EmployeeId, EmployeeName, TrainingId, CompanyId, AttendanceDate, DateValue)
							--			VALUES (
							--				NEWID(), (
							--					SELECT id
							--					FROM common.Attendance
							--					WHERE companyid = @companyid AND DATE = @Date1
							--					), @EmployeeId1, (
							--					SELECT FirstName
							--					FROM Common.Employee
							--					WHERE id = @EmployeeId1
							--					), @NewId1, @CompanyId, @Date1, (cast((replace(convert(VARCHAR, @Date1, 102), '.', '')) AS BIGINT))
							--				)

							--		END
							--			ELSE IF NOT EXISTS ( SELECT * FROM common.Attendance  WHERE companyid = @companyid  AND DATE = @Date )
							--				BEGIN

							--					INSERT Common.Attendance (id, CompanyId, DATE, STATUS)
							--					VALUES (@Aid1, @CompanyId, @Date1, 1)

							--					INSERT common.AttendanceDetails (id, AttendenceId, EmployeeId, EmployeeName, TrainingId, CompanyId, AttendanceDate, DateValue)
							--					VALUES (
							--						NEWID(), @Aid1, @EmployeeId1, (
							--							SELECT FirstName
							--							FROM Common.Employee
							--							WHERE id = @EmployeeId1
							--							), @NewId1, @CompanyId, @Date1, (cast((replace(convert(VARCHAR, @Date1, 102), '.', '')) AS BIGINT))
							--						)

							--				END
							--	END
						 END
					END

					IF (@EmployeeTrainingStatus = 'Withdrawn')
					BEGIN
						UPDATE Hr.TrainingAttendance  SET AmAttended = 0, PmAttended = 0 WHERE EmployeeId = @EmployeeId1 AND TrainingId = @TrainingId
					END

					FETCH NEXT
					FROM Training_Cursor
					INTO @EmployeeId1, @AttendanceDate
				END

				CLOSE Training_Cursor
				DEALLOCATE Training_Cursor
			END
		END
COMMIT TRANSACTION 
END TRY 

BEGIN CATCH
	ROLLBACK TRANSACTION
	DECLARE @ErrorMessage NVARCHAR(4000), @ErrorSeverity INT, @ErrorState INT;
	SELECT @ErrorMessage = ERROR_MESSAGE(), @ErrorSeverity = ERROR_SEVERITY(), @ErrorState = ERROR_STATE();
	RAISERROR (@ErrorMessage, @ErrorSeverity, @ErrorState);
END CATCH

END



----USE [SmartCursorSTG]
----GO
----/****** Object:  StoredProcedure [dbo].[WF_TrainerSchedule2TimeLogItem_Insertion]    Script Date: 13-05-2023 16:16:11 ******/
----SET ANSI_NULLS ON
----GO
----SET QUOTED_IDENTIFIER ON
----GO



----ALTER PROCEDURE [dbo].[WF_TrainerSchedule2TimeLogItem_Insertion] @TrainerId UNIQUEIDENTIFIER, @TrainingId UNIQUEIDENTIFIER, @CompanyId BIGINT, @CourseName NVARCHAR(20), @TrainerIds NVARCHAR(max)
----AS
----BEGIN
----	BEGIN TRANSACTION

----	BEGIN TRY
----		CREATE TABLE #Companyuser_Tbl (S_No INT Identity(1, 1), IsExternalTrainer BIT, CompanyUserId BIGINT)

----		IF (
----				@TrainerId IS NULL OR @TrainerId = (
----					SELECT CAST(0x0 AS UNIQUEIDENTIFIER)
----					)
----				)
----		BEGIN
----			SET @TrainerId = (
----					SELECT T.TrainerId
----					FROM HR.Training AS T
----					JOIN HR.Trainer AS TR ON T.TrainerId = TR.Id
----					WHERE T.Id = @TrainingId
----					)
----		END

----		IF (@CourseName IS NULL OR @CourseName = '')
----		BEGIN
----			SET @CourseName = (
----					SELECT c.CourseName
----					FROM HR.Training AS T
----					JOIN HR.CourseLibrary AS c ON T.CourseLibraryId = c.Id
----					WHERE T.Id = @TrainingId
----					)
----		END

----		DECLARE @StartDate DATE

----		SELECT @StartDate = StartDate
----		FROM common.TimeLogItem
----		WHERE SystemId = @TrainingId AND CompanyId = @CompanyId

----		BEGIN
----			DECLARE TImeLog_Cursor CURSOR
----			FOR
----			SELECT StartDate
----			FROM Common.TimeLogItem
----			WHERE SystemId = @TrainingId AND SubType = @CourseName

----			OPEN TImeLog_Cursor

----			FETCH NEXT
----			FROM TImeLog_Cursor
----			INTO @StartDate

----			WHILE @@FETCH_STATUS = 0
----			BEGIN
----				UPDATE common.Attendancedetails
----				SET trainingid = NULL
----				WHERE trainingid IN (
----						SELECT id
----						FROM Common.TimeLogItem
----						WHERE SystemId = @TrainingId AND StartDate = @StartDate
----						)

----				DELETE
----				FROM Common.TimeLogItemDetail
----				WHERE TimeLogItemId IN (
----						SELECT id
----						FROM Common.TimeLogItem
----						WHERE SystemId = @TrainingId AND StartDate = @StartDate
----						)

----				DELETE
----				FROM Common.TimeLogItem
----				WHERE SystemId = @TrainingId AND StartDate = @StartDate

----				FETCH NEXT
----				FROM TImeLog_Cursor
----				INTO @StartDate
----			END

----			CLOSE TImeLog_Cursor

----			DEALLOCATE TImeLog_Cursor
----		END

----		BEGIN
----			DECLARE @TrainingStatus NVARCHAR(20)

----			SELECT @TrainingStatus = TrainingStatus
----			FROM Hr.Training
----			WHERE Id = @TrainingId

----			IF (@TrainingStatus = 'Tentative' OR @TrainingStatus = 'Confirmed' OR @TrainingStatus = 'Completed' OR @TrainingStatus = 'Cancelled')
----			BEGIN
----				DECLARE @IsExternal BIT, @CompanyUserId BIGINT, @CompanyUserCount INT, @Recount INT

----				INSERT INTO #Companyuser_Tbl
----				SELECT IsExternalTrainer, CompanyUserId
----				FROM HR.Trainer
----				WHERE (
----						CAST(Id AS NVARCHAR(max)) IN (
----							SELECT items
----							FROM dbo.SplitToTable(@TrainerIds, ',')
----							)
----						)

----				SET @CompanyUserCount = (
----						SELECT Count(*)
----						FROM #Companyuser_Tbl
----						)
----				SET @Recount = 1

----				WHILE @CompanyUserCount >= @Recount --parvathi
----				BEGIN
----					SELECT @IsExternal = IsExternalTrainer, @CompanyUserId = CompanyUserId
----					FROM #Companyuser_Tbl
----					WHERE S_No = @Recount

----					IF (@IsExternal = 0)
----					BEGIN
----						IF EXISTS (
----								SELECT Id
----								FROM Common.Employee
----								WHERE CompanyId = @CompanyId AND UserName IN (
----										SELECT UserName
----										FROM Common.CompanyUser
----										WHERE Id = @CompanyUserId
----										)
----								)
----						BEGIN
----							DECLARE @TrainingDate DATE

----							SELECT @TrainingDate = TrainingDate
----							FROM Hr.TrainingSchedule
----							WHERE TrainingId = @TrainingId

----							DECLARE @EmployeeId UNIQUEIDENTIFIER

----							SELECT @EmployeeId = Id
----							FROM common.Employee
----							WHERE CompanyId = @CompanyId AND UserName IN (
----									SELECT UserName
----									FROM Common.CompanyUser AS CU
----									JOIN Hr.Trainer AS t ON CU.Id = t.CompanyUserId
----									WHERE CU.Id = @CompanyUserId
----									)

----							BEGIN
----								DECLARE Trainer_Cursor CURSOR
----								FOR
----								SELECT TrainingDate
----								FROM Hr.TrainingSchedule
----								WHERE TrainingId = @TrainingId

----								OPEN Trainer_Cursor

----								FETCH NEXT
----								FROM Trainer_Cursor
----								INTO @TrainingDate

----								WHILE @@FETCH_STATUS = 0
----								BEGIN
----									DECLARE @Date DATE, @NewId UNIQUEIDENTIFIER, @hours DECIMAL(17, 2), @FirstHalfFromTime TIME(7), @FirstHalfToTime TIME(7), @FirstHalfTotalHours TIME(7), @SecondHalfFromTime TIME(7), @SecondHalfToTime TIME(7), @SecondHalfTotalHours TIME(7), @totalhours TIME(7), @sethours NVARCHAR(50), @Aid UNIQUEIDENTIFIER						


----									set @hours=0


----									if(@TrainingStatus != 'Cancelled')
----									begin
----									SELECT @FirstHalfFromTime = FirstHalfFromTime, @FirstHalfToTime = FirstHalfToTime, @FirstHalfTotalHours = FirstHalfTotalHours, @SecondHalfFromTime = SecondHalfFromTime, @SecondHalfToTime = SecondHalfToTime, @SecondHalfTotalHours = SecondHalfTotalHours
----									FROM Hr.TrainingSchedule AS TS
----									JOIN Hr.Training AS TR ON TS.TrainingId = TR.Id
----									WHERE TR.Id = @TrainingId AND TS.TrainingDate = @TrainingDate

----									SET @totalhours = dateadd(second, datediff(second, 0, @FirstHalfTotalHours), @SecondHalfTotalHours)
----									SET @sethours = LEFT(@totalhours, 5)
----									SET @sethours = REPLACE(@sethours, ':', '.')
----									SET @hours = CONVERT(DECIMAL(17, 2), @sethours)
									
----									--end

----									--			Declare @firstminutes decimal(17,2)= Datepart(mi,@FirstHalfTotalHours)
----									--set  @firstminutes=@firstminutes/60
----									--	Declare @secondminutes decimal(17,2)=Datepart(mi,@SecondHalfTotalHours)
----									--set  @secondminutes=@secondminutes/60 
----									--	set @hours=Datepart(HH,@FirstHalfTotalHours)+Datepart(HH,@SecondHalfTotalHours)+@firstminutes+@secondminutes 
----									SET @Date = @TrainingDate
----									SET @NewId = NEWID()
----									SET @Aid = NEWID()

----									BEGIN
----										INSERT INTO Common.TimeLogItem --@TimeLogItem 
----											(Id, CompanyId, Type, SubType, ChargeType, SystemType, SystemId, IsSystem, StartDate, EndDate, CreatedDate, Hours, ApplyToAll, Days, FirstHalfFromTime, FirstHalfToTime, FirstHalfTotalHours, SecondHalfFromTime, SecondHalfToTime, SecondHalfTotalHours)
----										VALUES (@NewId, @CompanyId, 'Training', @CourseName, 'Non-Chargable', 'Training', @TrainingId, 1, @Date, @Date, GETDATE(), @hours, 0, 1, @FirstHalfFromTime, @FirstHalfToTime, @FirstHalfTotalHours, @SecondHalfFromTime, @SecondHalfToTime, @SecondHalfTotalHours)

----										INSERT INTO Common.TimeLogItemDetail -- @TimeLogItemDetail 
----											(Id, TimeLogItemId, EmployeeId)
----										VALUES (NewId(), @NewId, @EmployeeId)

----										IF EXISTS (
----												SELECT *
----												FROM common.Attendancedetails AS ad
----												JOIN common.Attendance AS a ON a.id = ad.AttendenceId
----												WHERE a.DATE = @Date AND employeeid = @EmployeeId
----												)
----										BEGIN
----											UPDATE ad
----											SET ad.TrainingId = @NewId
----											FROM common.Attendancedetails AS ad
----											JOIN common.Attendance AS a ON a.id = ad.AttendenceId
----											WHERE a.DATE = @Date AND employeeid = @EmployeeId
----										END
----										ELSE
----										BEGIN
----											IF EXISTS (
----													SELECT *
----													FROM common.Attendance
----													WHERE companyid = @companyid AND DATE = @Date
----													)
----											BEGIN
----												INSERT common.AttendanceDetails (id, AttendenceId, EmployeeId, EmployeeName, TrainingId, CompanyId, AttendanceDate, DateValue)
----												VALUES (
----													NEWID(), (
----														SELECT id
----														FROM common.Attendance
----														WHERE companyid = @companyid AND DATE = @Date
----														), @EmployeeId, (
----														SELECT FirstName
----														FROM Common.Employee
----														WHERE id = @EmployeeId
----														), @NewId, @CompanyId, @Date, (cast((replace(convert(VARCHAR, @Date, 102), '.', '')) AS BIGINT))
----													)
----											END
----											ELSE
----											BEGIN
----												INSERT Common.Attendance (id, CompanyId, DATE, STATUS)
----												VALUES (@Aid, @CompanyId, @Date, 1)

----												INSERT common.AttendanceDetails (id, AttendenceId, EmployeeId, EmployeeName, TrainingId, CompanyId, AttendanceDate, DateValue)
----												VALUES (
----													NEWID(), @Aid, @EmployeeId, (
----														SELECT FirstName
----														FROM Common.Employee
----														WHERE id = @EmployeeId
----														), @NewId, @CompanyId, @Date, (cast((replace(convert(VARCHAR, @Date, 102), '.', '')) AS BIGINT))
----													)
----											END
----										END
----									END
----									END

----									ELSE IF @TrainingStatus = 'Cancelled' ------>> Added On '2023-05-13' --->> Start
----									BEGIN 
----										UPDATE Common.TimeLogItem SET Hours = 0.00
----										WHERE SystemId = @TrainingId
----									END  --->> End

----									FETCH NEXT
----									FROM Trainer_Cursor
----									INTO @TrainingDate
----								END

----								CLOSE Trainer_Cursor

----								DEALLOCATE Trainer_Cursor
----							END
----						END
----					END

----					SET @Recount = @Recount + 1
----						--truncate table Companyuser_Tbl
----				END

----				IF OBJECT_ID(N'tempdb..#Companyuser_Tbl') IS NOT NULL
----				BEGIN
----					DROP TABLE #Companyuser_Tbl
----				END
----			END
----		END

----		BEGIN
----			BEGIN
----				DECLARE @Date1 DATE, @EmployeeId1 UNIQUEIDENTIFIER, @NewId1 UNIQUEIDENTIFIER, @AttendanceDate DATE, @Aid1 UNIQUEIDENTIFIER

----				SELECT @EmployeeId1 = TS.EmployeeId, @AttendanceDate = TS.AttendanceDate
----				FROM Hr.TrainingAttendance AS TS
----				JOIN Hr.Training AS TR ON TS.TrainingId = TR.Id
----				WHERE TS.TrainingId = @TrainingId

----				DECLARE Training_Cursor CURSOR
----				FOR
----				SELECT TS.EmployeeId, TS.AttendanceDate
----				FROM Hr.TrainingAttendance AS TS
----				JOIN Hr.Training AS TR ON TS.TrainingId = TR.Id
----				WHERE TS.TrainingId = @TrainingId

----				OPEN Training_Cursor

----				FETCH NEXT
----				FROM Training_Cursor
----				INTO @EmployeeId1, @AttendanceDate

----				WHILE @@FETCH_STATUS = 0
----				BEGIN
----					DECLARE @EmployeeTrainingStatus NVARCHAR(20)

----					SELECT @EmployeeTrainingStatus = EmployeeTrainigStatus
----					FROM Hr.TrainingAttendee
----					WHERE TrainingId = @TrainingId AND EmployeeId = @EmployeeId1

----					IF (@EmployeeTrainingStatus = 'Registered' OR @EmployeeTrainingStatus = 'Completed' OR @EmployeeTrainingStatus = 'Incompleted' OR @EmployeeTrainingStatus = 'Absent' OR @EmployeeTrainingStatus = 'Cancelled')
----					BEGIN
----						SET @Date1 = @AttendanceDate
----						SET @NewId1 = NEWID()
----						SET @Aid1 = NEWID()

----						BEGIN
----							INSERT INTO Common.TimeLogItem --@TimeLogItem 
----								(Id, CompanyId, Type, SubType, ChargeType, SystemType, SystemId, IsSystem, StartDate, EndDate, CreatedDate, ApplyToAll, Days)
----							VALUES (@NewId1, @CompanyId, 'Training', @CourseName, 'Non-Chargable', 'Training', @TrainingId, 1, @Date1, @Date1, GETDATE(), 0, 1)

----							INSERT INTO Common.TimeLogItemDetail -- @TimeLogItemDetail 
----								(Id, TimeLogItemId, EmployeeId)
----							VALUES (NewId(), @NewId1, @EmployeeId1)

----							IF EXISTS (
----									SELECT *
----									FROM common.Attendancedetails AS ad
----									JOIN common.Attendance AS a ON a.id = ad.AttendenceId
----									WHERE a.DATE = @Date1 AND employeeid = @EmployeeId1
----									)
----							BEGIN
----								UPDATE ad
----								SET ad.TrainingId = @NewId1
----								FROM common.Attendancedetails AS ad
----								JOIN common.Attendance AS a ON a.id = ad.AttendenceId
----								WHERE a.DATE = @Date1 AND employeeid = @EmployeeId1
----							END
----							ELSE
----							BEGIN
----								IF EXISTS (
----										SELECT *
----										FROM common.Attendance
----										WHERE companyid = @companyid AND DATE = @Date1
----										)
----								BEGIN
----									INSERT common.AttendanceDetails (id, AttendenceId, EmployeeId, EmployeeName, TrainingId, CompanyId, AttendanceDate, DateValue)
----									VALUES (
----										NEWID(), (
----											SELECT id
----											FROM common.Attendance
----											WHERE companyid = @companyid AND DATE = @Date1
----											), @EmployeeId1, (
----											SELECT FirstName
----											FROM Common.Employee
----											WHERE id = @EmployeeId1
----											), @NewId1, @CompanyId, @Date1, (cast((replace(convert(VARCHAR, @Date1, 102), '.', '')) AS BIGINT))
----										)
----								END
----								ELSE
----								BEGIN
----									INSERT Common.Attendance (id, CompanyId, DATE, STATUS)
----									VALUES (@Aid1, @CompanyId, @Date1, 1)

----									INSERT common.AttendanceDetails (id, AttendenceId, EmployeeId, EmployeeName, TrainingId, CompanyId, AttendanceDate, DateValue)
----									VALUES (
----										NEWID(), @Aid1, @EmployeeId1, (
----											SELECT FirstName
----											FROM Common.Employee
----											WHERE id = @EmployeeId1
----											), @NewId1, @CompanyId, @Date1, (cast((replace(convert(VARCHAR, @Date1, 102), '.', '')) AS BIGINT))
----										)
----								END
----							END
----						END
----					END

----					IF (@EmployeeTrainingStatus = 'Withdrawn')
----					BEGIN
----						UPDATE Hr.TrainingAttendance
----						SET AmAttended = 0, PmAttended = 0
----						WHERE EmployeeId = @EmployeeId1 AND TrainingId = @TrainingId
----					END

----					FETCH NEXT
----					FROM Training_Cursor
----					INTO @EmployeeId1, @AttendanceDate
----				END

----				CLOSE Training_Cursor

----				DEALLOCATE Training_Cursor
----			END
----		END

----		COMMIT TRANSACTION --s2
----	END TRY --s3

----	BEGIN CATCH
----		ROLLBACK TRANSACTION

----		DECLARE @ErrorMessage NVARCHAR(4000), @ErrorSeverity INT, @ErrorState INT;

----		SELECT @ErrorMessage = ERROR_MESSAGE(), @ErrorSeverity = ERROR_SEVERITY(), @ErrorState = ERROR_STATE();

----		RAISERROR (@ErrorMessage, @ErrorSeverity, @ErrorState);
----	END CATCH
----END --1
GO
