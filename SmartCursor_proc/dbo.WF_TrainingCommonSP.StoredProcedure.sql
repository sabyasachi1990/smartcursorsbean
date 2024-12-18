USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[WF_TrainingCommonSP]    Script Date: 16-12-2024 9.20.11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   Procedure [dbo].[WF_TrainingCommonSP]
@TrainerId uniqueIdentifier,
@TrainingId UniqueIdentifier,
@CompanyId bigint,
@CourseName nvarchar(200),
@TrainerIds nvarchar(max),
@IsTraining nvarchar(250)

AS
BEGIN

--Begin Transaction
--Begin Try

--EXEC  [dbo].[WF_TrainerSchedule2TimeLogItem_Insertion] @TrainerId,@TrainingId,@CompanyId,@CourseName,@TrainerIds

--EXEC  [dbo].[WF_TrainingAttendences12TimeLogItem_Insertion] @TrainingId

--EXEC [dbo].[Attendee Reg and Con PlnHrs] @TrainingId

--Commit Transaction--s2
--	End try --s3
--	Begin Catch
--	ROLLBACK TRANSACTION
--		DECLARE
--				@ErrorMessage NVARCHAR(4000),
--				@ErrorSeverity INT,
--				@ErrorState INT;
--		SELECT
--				@ErrorMessage = ERROR_MESSAGE(),
--				@ErrorSeverity = ERROR_SEVERITY(),
--				@ErrorState = ERROR_STATE();
--		RAISERROR (@ErrorMessage,@ErrorSeverity,@ErrorState);
--	End Catch


DECLARE @StartDate Date, @EndDate Date, @ErrorId UniqueIdentifier

SELECT @StartDate = StartDate, @EndDate = EndDate FROM HR.Training WHERE Id = @TrainingId

SELECT * INTO #OldTrainingData
FROM (
		SELECT A.Id as TimeLogItemId,B.Id AS TimeLogItemDeatilId,A.SystemId,B.EmployeeId,A.StartDate,CompanyId
		FROM Common.TimeLogItem AS A (NOLOCK)
		INNER JOIN Common.TimeLogItemDetail AS B (NOLOCK) ON B.TimeLogItemId = A.Id
		WHERE SystemId = @TrainingId AND CompanyId = @CompanyId
	 ) AS A

SELECT * INTO #NewTrainingData 
FROM (
		SELECT 
			T.Id AS TrainingId, StartDate,EndDate,CourseLibraryId,CL.CourseName,T.Status,T.TrainingStatus,TD.DateValue AS TaskDate,Totalhours as TotalTrainingHours,
			TS.Id AS TrainingScheduleId,TS.FirstHalfFromTime,FirstHalfToTime, FirstHalfTotalHours,SecondHalfFromTime,SecondHalfToTime,SecondHalfTotalHours,
			CAST(REPLACE(LEFT(TS.FirstHalfTotalHours, 5), ':', '.' ) AS Decimal(17,2)) as FirstHalfHours,
			CAST(REPLACE(LEFT(TS.SecondHalfTotalHours, 5), ':', '.' ) AS Decimal(17,2)) as SecondHalfHours,
			CAST(ISNULL(REPLACE(LEFT(dateadd(second, datediff(second, 0, TS.FirstHalfTotalHours), TS.SecondHalfTotalHours ),5), ':', '.'),0)as decimal(17,2)) AS [PerDayTotalHours],
			T.TrainerIds
		FROM HR.Training AS T (NOLOCK)
		INNER JOIN HR.CourseLibrary AS CL (NOLOCK)ON CL.Id = T.CourseLibraryId
		INNER JOIN Hr.TrainingSchedule as TS (NOLOCK) ON TS.TrainingId = T.Id 
		INNER JOIN [dbo].[DateRange_Function] (@CompanyId,@StartDate,@EndDate) AS TD on td.DateValue BETWEEN T.StartDate AND T.EndDate
		WHERE T.Id = @TrainingId AND TS.TrainingDate = TD.DateValue
) AS A

-------->>> Trainer
SELECT * INTO #NewTrainerAndAttendeeData 
FROM (
		SELECT 
			'Trainer' as [Type],NEWID() AS NewTimeLogItemId,NEWID() as NewAttendanceId,
			TrainingId, StartDate,EndDate,CourseLibraryId,CourseName,T.Status,TrainingStatus,TaskDate,FirstHalfFromTime,FirstHalfToTime,
			FirstHalfTotalHours,SecondHalfFromTime,SecondHalfToTime,SecondHalfTotalHours,FirstHalfHours,SecondHalfHours,
			E.Id AS EmployeeId,E.FirstName as EmployeeName,'ALL' AS AttendeeTrainingStatus,1 as AMAttended,1 as PMAttended,/*TR.IsExternalTrainer,TR.CompanyUserId,*/
			[PerDayTotalHours] as PlannedHours,
			CASE 
				WHEN TrainingStatus IN ( 'Confirmed','Completed') THEN [PerDayTotalHours]
				ELSE 0.00
			END AS ActualHours
		FROM #NewTrainingData AS T
		CROSS APPLY STRING_SPLIT(T.TrainerIds, ',') AS A
		INNER JOIN HR.Trainer AS TR (NOLOCK)ON TR.Id = A.value
		LEFT JOIN Common.CompanyUser AS CU (NOLOCK)ON CU.Id = TR.CompanyUserId AND CU.CompanyId = @CompanyId
		INNER JOIN Common.Employee AS E (NOLOCK) ON E.Username = CU.Username AND E.CompanyId = @CompanyId
		WHERE  ISNULL(TR.IsExternalTrainer,0) = 0

		UNION ALL

		-------->>> Attendee
		SELECT 
			'Attendee' as [Type], NEWID() AS NewTimeLogItemId,NEWID() as NewAttendanceId,
			T.TrainingId, T.StartDate,T.EndDate,CourseLibraryId,CourseName,T.Status,TrainingStatus,TAT.AttendanceDate AS TaskDate, 
			CASE WHEN ISNULL(TAT.AMAttended,0) = 1 THEN FirstHalfFromTime ELSE NULL END AS FirstHalfFromTime,
			CASE WHEN ISNULL(TAT.AMAttended,0) = 1 THEN FirstHalfToTime ELSE NULL END AS FirstHalfToTime,
			CASE WHEN ISNULL(TAT.AMAttended,0) = 1 THEN FirstHalfTotalHours ELSE NULL END AS FirstHalfTotalHours,
			CASE WHEN ISNULL(TAT.PMAttended,0) = 1 THEN SecondHalfFromTime ELSE NULL END AS SecondHalfFromTime,
			CASE WHEN ISNULL(TAT.PMAttended,0) = 1 THEN SecondHalfToTime ELSE NULL END AS SecondHalfToTime,
			CASE WHEN ISNULL(TAT.PMAttended,0) = 1 THEN SecondHalfTotalHours ELSE NULL END AS SecondHalfTotalHours,
			FirstHalfHours,SecondHalfHours,
			E.Id as AttendeeId, E.FirstName AS AttendeeName, EmployeeTrainigStatus as AttendeeTrainingStatus,TAT.AMAttended,
			TAT.PMAttended,
			CASE 
				WHEN EmployeeTrainigStatus = 'Registered'AND TrainingStatus = 'Tentative' THEN 0.00
				ELSE ISNULL([PerDayTotalHours],0) 
			END as PlannedHours,
			CASE 
				WHEN ISNULL(TAT.AMAttended,0) = 1 AND ISNULL(TAT.PMAttended,0) = 1 THEN T.PerDayTotalHours
				WHEN ISNULL(TAT.AMAttended,0) = 1 AND ISNULL(TAT.PMAttended,0) = 0 THEN T.FirstHalfHours
				WHEN ISNULL(TAT.AMAttended,0) = 0 AND ISNULL(TAT.PMAttended,0) = 1 THEN T.SecondHalfHours
				ELSE 0.00
			END AS ActualHours
		FROM #NewTrainingData AS T
		INNER JOIN Hr.TrainingAttendee AS TA (NOLOCK) ON TA.TrainingId = T.TrainingId
		LEFT JOIN Hr.TrainingAttendance AS TAT (NOLOCK) ON TAT.TrainingId = T.TrainingId AND TAT.TrainingScheduleId = T.TrainingScheduleId AND TA.EmployeeId = TAT.EmployeeId
		INNER JOIN Common.Employee AS E (NOLOCK) ON E.Id = TA.EmployeeId
		WHERE T.TrainingId = @TrainingId AND TA.TrainingId = @TrainingId AND TA.EmployeeTrainigStatus != 'Cancelled' 

) AS A

-------->>>> Inserts For TimeLogItem
SELECT * INTO #InsertIntoTimeLogItem 
FROM (
	SELECT 
		NewTimeLogItemId AS Id,@CompanyId as CompanyId,'Training' as [Type], CourseName as SubType, 'Non-Chargable' as ChargeType, 
		'Training' as SystemType, A.TrainingId as SystemId, 1 as IsSystem,TaskDate as StartDate,TaskDate as EndDate,GETDATE() as CreatedDate,PlannedHours,0 as ApplyToAll,1 as Days,FirstHalfFromTime,FirstHalfToTime,FirstHalfTotalHours,
		SecondHalfFromTime,SecondHalfToTime,SecondHalfTotalHours,A.ActualHours,EmployeeId,EmployeeName,NewAttendanceId
	FROM #NewTrainerAndAttendeeData AS A
	WHERE AttendeeTrainingStatus IN (SELECT TRIM(value) AS AttendeeTrainingStatus 
									 FROM STRING_SPLIT( (CASE 
															 WHEN TrainingStatus = 'Tentative'  THEN 'Registered,ALL' 
															 WHEN TrainingStatus = 'Confirmed'  THEN 'Registered,ALL,Absent,Incompleted,Completed'
															 WHEN TrainingStatus = 'Completed'  THEN 'Registered,ALL,Absent,Incompleted,Completed'
														  END),',')
									)
 ) AS A

SELECT * INTO #TimeLogItem 
FROM (
	SELECT 
		Id, A.CompanyId, Type, A.SubType, ChargeType, A.SystemType, A.SystemId, IsSystem, A.StartDate, EndDate, CreatedDate, PlannedHours, ApplyToAll, Days, 
		FirstHalfFromTime, FirstHalfToTime, FirstHalfTotalHours, SecondHalfFromTime, SecondHalfToTime, SecondHalfTotalHours,A.ActualHours,
		B.TimeLogItemId,TimeLogItemDeatilId,A.EmployeeId,A.EmployeeName,NewAttendanceId
	FROM #InsertIntoTimeLogItem AS A
	FULL JOIN #OldTrainingData AS B ON B.EmployeeId = A.EmployeeId AND B.SystemId = A.SystemId AND A.StartDate = B.StartDate 
) AS A


BEGIN TRANSACTION
BEGIN TRY

SELECT @ErrorId = @TrainingId

	------>>> Update TimeLogItem
	UPDATE A SET
		 A.SubType = B.SubType, 
		 A.StartDate = B.StartDate, 
		 A.EndDate = B.EndDate, 
		 A.Hours = B.PlannedHours,
		 A.Days = B.Days, 
		 A.FirstHalfFromTime = B.FirstHalfFromTime, 
		 A.FirstHalfToTime = B.FirstHalfToTime, 
		 A.FirstHalfTotalHours = B.FirstHalfTotalHours, 
		 A.SecondHalfFromTime = B.SecondHalfFromTime, 
		 A.SecondHalfToTime = B.SecondHalfToTime, 
		 A.SecondHalfTotalHours = B.SecondHalfTotalHours,
		 A.ActualHours = B.ActualHours
	 FROM Common.TimeLogItem as A
	 INNER JOIN #TimeLogItem AS B ON B.TimeLogItemId = A.Id AND A.SystemId = B.SystemId
	WHERE TimeLogItemId IS NOT NULL AND B.Id IS NOT NULL

	------>>> Insert Into TimeLogItem
	INSERT INTO Common.TimeLogItem (Id, CompanyId, Type, SubType, ChargeType, SystemType, SystemId, IsSystem, StartDate, EndDate, CreatedDate, Hours, ApplyToAll, Days, FirstHalfFromTime, FirstHalfToTime, FirstHalfTotalHours, SecondHalfFromTime, SecondHalfToTime, SecondHalfTotalHours,ActualHours)
	 SELECT Id, CompanyId, Type, SubType, ChargeType, SystemType, SystemId, IsSystem, StartDate, EndDate, CreatedDate, PlannedHours, ApplyToAll, Days, FirstHalfFromTime, FirstHalfToTime, FirstHalfTotalHours, SecondHalfFromTime, SecondHalfToTime, SecondHalfTotalHours,ActualHours
	FROM #TimeLogItem
	WHERE TimeLogItemId IS NULL

	------>>> Insert Into TimeLogItemDetail
	INSERT INTO Common.TimeLogItemDetail (Id, TimeLogItemId, EmployeeId)
	SELECT NewId(), Id,EmployeeId FROM #TimeLogItem
	WHERE TimeLogItemId IS NULL

	------>>> Delete From TimeLogItemDetail
	DELETE A FROM Common.TimeLogItemDetail AS A
	INNER JOIN #TimeLogItem AS B ON B.TimeLogItemDeatilId = A.Id
	WHERE B.Id IS NULL

	---------->>>>> AuditLogSYnc
	DECLARE @TimeLogItemIds Nvarchar(max)
	DECLARE @status Nvarchar(max)
	SET @status = (SELECT TOP 1 S.TrainingStatus  FROM  #NewTrainingData  as S)
	
	SET @TimeLogItemIds = (
								SELECT STRING_AGG(Id,',')
								FROM (
								SELECT DISTINCT CAST(A.Id AS nvarchar(50)) as Id
								FROM Common.TimeLogItem as A
								 INNER JOIN #TimeLogItem AS B ON B.TimeLogItemId = A.Id AND A.SystemId = B.SystemId
								WHERE TimeLogItemId IS NOT NULL AND B.Id IS NOT NULL

								UNION ALL

								SELECT DISTINCT CAST(Id AS nvarchar(50)) as Id
								FROM #TimeLogItem
								WHERE TimeLogItemId IS NULL
								) AS A
							)

	PRINT @TimeLogItemIds;
    Exec [dbo].[UpdateAuditSyncing] @TrainingId,@TimeLogItemIds,'Success',@status,null,null,null,null,null,'HR Trainings','WF TimeLog'

	------>>> Delete From TimeLogItem
	DELETE A FROM Common.TimeLogItem AS A
	INNER JOIN #TimeLogItem AS B ON B.TimeLogItemId = A.Id
	WHERE B.Id IS NULL

COMMIT TRANSACTION
END TRY

--BEGIN CATCH     
--	ROLLBACK;               
--	SELECT @ErrorId AS ErrorId,ERROR_MESSAGE() AS ErrorMessage, ERROR_NUMBER() AS ErrorNumber;  
--END CATCH 
	BEGIN CATCH
			RollBack Transaction;
			DECLARE
			@ErrorMessage NVARCHAR(4000),
			@ErrorSeverity INT,
			@ErrorState INT;
			SELECT
			@ErrorMessage = ERROR_MESSAGE(),
			@ErrorSeverity = ERROR_SEVERITY(),
			@ErrorState = ERROR_STATE();

	    Exec [dbo].[UpdateAuditSyncing] @TrainingId, null,'Failed',@status,'Critical',null,'TimeLog Syncing Failed',@ErrorMessage,@TrainingId,'HR Trainings','WF TimeLog'
			RAISERROR (@ErrorMessage,@ErrorSeverity,@ErrorState);
		END CATCH

----Code Commentedby Lakshmi on 23-05-2023------------------------
--SELECT * INTO #Attendance 
--FROM (
--		SELECT 
--			A.CompanyId,NEWID() AS NewAttendanceId,B.EmployeeId,E.FirstName AS EmployeeName,A.StartDate AS Date,
--			A.Id AS TrainingId,(cast((replace(convert(VARCHAR, StartDate, 102), '.', '')) AS BIGINT)) AS DateValue,AC.Id AS OldAttendanceId, C.Id as AttendanceDetailsId
--		FROM Common.TimeLogItem AS A
--		INNER JOIN Common.TimeLogItemDetail as b on b.TimeLogItemId = a.Id
--		INNER JOIN Common.Employee AS E ON E.Id = B.EmployeeId
--		LEFT JOIN Common.Attendance AS AC ON CAST(AC.Date AS Date) = CAST(A.StartDate AS Date) AND AC.CompanyId = A.CompanyId
--		LEFT JOIN Common.AttendanceDetails  AS C ON C.TrainingId = A.Id
--		WHERE A.SystemId = @TrainingId AND A.CompanyId = @CompanyId
--) AS A

--BEGIN TRANSACTION
--BEGIN TRY
--	-------->>> Updating Null Values Where TrainingId matches
--	UPDATE A SET TrainingId = NULL 
--	FROM Common.Attendancedetails AS A
--	INNER JOIN #OldTrainingData AS B ON B.TimeLogItemId = A.TrainingId 

--	-------->>> Insert Into Attendance
--	INSERT Common.Attendance (id, CompanyId, DATE, STATUS)
--	SELECT NewAttendanceId,CompanyId,Date,1
--	FROM #Attendance
--	WHERE OldAttendanceId IS NULL

--	-------->>> Insert Into AttendanceDetails 
--	INSERT common.AttendanceDetails (id, AttendenceId, EmployeeId, EmployeeName, TrainingId, CompanyId, AttendanceDate, DateValue)
--	SELECT NEWID(),NewAttendanceId,EmployeeId,EmployeeName,TrainingId,CompanyId,Date,DateValue
--	FROM #Attendance
--	WHERE OldAttendanceId IS NULL AND AttendanceDetailsId IS NULL

--	-------->>> Insert Into AttendanceDetails 
--	INSERT Common.AttendanceDetails (id, AttendenceId, EmployeeId, EmployeeName, TrainingId, CompanyId, AttendanceDate, DateValue)
--	SELECT 
--		NEWID(),OldAttendanceId,EmployeeId,EmployeeName, TrainingId,CompanyId,Date,DateValue
--	FROM #Attendance
--	WHERE OldAttendanceId IS NOT NULL AND AttendanceDetailsId IS NULL

--	-------->>> Update Attendance Details
--	UPDATE A SET TrainingId = B.TrainingId
--	FROM Common.Attendancedetails AS A
--	INNER JOIN #Attendance AS B ON B.AttendanceDetailsId = A.Id 
--	WHERE OldAttendanceId IS NOT NULL AND AttendanceDetailsId IS NOT NULL

--COMMIT TRANSACTION
--END TRY

--BEGIN CATCH     
--	ROLLBACK;               
--	SELECT @ErrorId AS ErrorId,ERROR_MESSAGE() AS ErrorMessage, ERROR_NUMBER() AS ErrorNumber;            
--END CATCH 

DROP TABLE #OldTrainingData
DROP TABLE #InsertIntoTimeLogItem
DROP TABLE #TimeLogItem
DROP TABLE #NewTrainingData
DROP TABLE #NewTrainerAndAttendeeData
--DROP TABLE #Attendance

END--1
GO
