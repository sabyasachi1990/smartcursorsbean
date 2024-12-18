USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [HR].[TeamCalendar_Procedure]    Script Date: 16-12-2024 9.20.11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE     PROCEDURE [HR].[TeamCalendar_Procedure] (@companyId nvarchar(10), @companyUserId nvarchar(10), @startDate nvarchar(50), @endDate nvarchar(50),@employeId nvarchar(250),@userId uniqueIdentifier)
AS
BEGIN

--DECLARE 
--@companyId nvarchar(10) =1, 
--@companyUserId nvarchar(10)=12,
--@startDate nvarchar(50)='2024-02-01', 
--@endDate nvarchar(50)='2024-02-29',
--@employeId nvarchar(250)='6ab61d88-d2a5-4073-ab2e-82ef5e37b4f1',
--@userId uniqueIdentifier='0234b324-956c-4df7-876c-7f70cee71d1a'


DECLARE  @TeamCalendarId uniqueidentifier = (SELECT Id FROM hr.TeamCalendar (NOLOCK) WHERE CompanyUserId = @companyUserId)
DECLARE  @DynSQl Nvarchar(Max)
SET @employeId = ISNULL(@employeId,'00000000-0000-0000-0000-000000000000')

DECLARE @TeamCalendarDetailCount nvarchar(20) = (SELECT count(TCD.EmployeeId) FROM hr.TeamCalendar TC (NOLOCK) INNER JOIN hr.TeamCalendarDetail  TCD (NOLOCK) ON TC.Id = TCD.MasterId WHERE TC.CompanyUserId = @CompanyUserId)

SELECT * INTO #Employees 
FROM (
		SELECT  CASE WHEN  @TeamCalendarDetailCount <> 0 THEN A.EmployeeId ELSE B.EmployeeId END AS EmployeeId
		FROM (
				SELECT TCD.EmployeeId 
				FROM hr.TeamCalendar TC (NOLOCK)
				INNER JOIN hr.TeamCalendarDetail  TCD (NOLOCK) ON TC.Id = TCD.MasterId
				WHERE TC.CompanyUserId=@companyUserId
			) AS A
		FULL OUTER JOIN
			(
				SELECT Id as EmployeeId  FROM Common.Employee (NOLOCK) WHERE Id = @employeId
				
				UNION ALL

				SELECT ED.ReportingManagerId as EmployeeId FROM Common.Employee E (NOLOCK)
				INNER JOIN hr.EmployeeDepartment ED (NOLOCK) ON E.Id = ED.EmployeeId
				WHERE E.Id=@employeId AND E.Status=1 AND (CONvert(date,ED.EffectiveFROM) <= CONVERT(date,GETDATE())
				AND (ED.EffectiveTo IS NULL or CONVERT(date,ED.EffectiveTo) >= CONVERT(date,GETDATE())))
				--And E.Status=1
				
				UNION ALL

				SELECT DISTINCT ED.EmployeeId as EmployeeId FROM Common.Employee E (NOLOCK)
				INNER JOIN hr.EmployeeDepartment ED (NOLOCK) ON E.Id = ED.EmployeeId
				WHERE ED.ReportingManagerId = @employeId AND 
				E.Status=1 AND (CONvert(date,ED.EffectiveFROM) <= CONVERT(date,GETDATE()) AND 
				(ED.EffectiveTo IS NULL or CONVERT(date,ED.EffectiveTo) >= CONVERT(date,GETDATE())))
				--AND e.Status=1
			) AS B
			ON B.EmployeeId = A.EmployeeId
	) AS A
WHERE EmployeeId IS NOT NULL

	select  distinct id as EmployeeId, FirstName as EmployeeName,null as ItemName,null as Itemtype, null as StartDate, null as EndDate,null as ItemStatus , null as ColorOrder, null as TeamCalendarDetailId, null  as TeamCalendarId,
 null as CourseCode, null as CourseName, null as CourseCategory, null as FirstHalfFromTime, null as FirstHalfToTime, null as SecondHalfFromTime, null as SecondHalfToTime, null as FirstHalfTotalHours, null as SecondHalfTotalHours,
 null as EntitlementType,null  as StartDateType,null as EndDateType , null as LeaveHours  ,
 null as PhotoURL
	from  common.Employee as emp (NOLOCK) where emp.Id in (Select Distinct EmployeeId from 	#Employees) 

	Union All
-------->> Holidays
	SELECT  DISTINCT * 
	FROM (
			SELECT DISTINCT 
				CASE WHEN A.ApplyToAll = 1 THEN B.Id ELSE C.EmployeeId END AS EmployeeId,B.FirstName AS EmployeeName,
				'Holidays' as ItemName, A.Name as ItemType, A.StartDate,A.EndDate,'Holiday' as ItemStatus, TCD.[Order] AS ColorOrder, 
				TCD.Id AS TeamCalendarDetailId, TCD.MasterId AS TeamCalendarId,NULL AS CourseCode, NULL AS CourseName, NULL AS CourseCategory,
				 NULL AS FirstHalfFromTime, NULL AS FirstHalfToTime, NULL AS SecondHalfFromTime, NULL AS SecondHalfToTime, NULL AS FirstHalfTotalHours , 
				 NULL AS SecondHalfTotalHours, NULL AS EntitlementType, A.TimeType AS StartDateType,A.TimeType AS EndDateType,A.[Hours] AS LeaveHours,
				 (SELECT mr.Small FROM Common.MediaRepository AS mr (NOLOCK) JOIN common.Employee AS e (NOLOCK) ON mr.id = e.PhotoId WHERE e.id = B.Id) AS PhotoURL
			FROM  Common.CalenderSchedule AS A (NOLOCK) 
				-----INNER JOIN Common.WorkWeekSetUp AS W (NOLOCK) ON W.WeekDay = DATENAME(WEEKDAY,A.StartDate) AND W.CompanyId = @CompanyId AND W.EmployeeId IS NULL 
				INNER JOIN Common.Employee AS B (NOLOCK) ON B.CompanyId = A.CompanyId AND B.CompanyId = @CompanyId
				LEFT JOIN Common.CalenderDetails AS C (NOLOCK) ON C.MasterId = A.CalenderId AND B.Id = C.EmployeeId
				LEFT JOIN hr.TeamCalendarDetail TCD  (NOLOCK) on TCD.EmployeeId = B.Id and TCD.MasterId = @TeamCalendarId 
			WHERE A.CompanyId = @CompanyId AND B.CompanyId = @CompanyId /*AND W.IsWorkingDay!=0*/ AND A.StartDate BETWEEN @startDate AND @endDate
		) AS A 
	WHERE A.EmployeeId IN (SELECT EmployeeId FROM #Employees)

	UNION ALL

-------->> Leaves
	SELECT  DISTINCT
		LA.EmployeeId,B.FirstName AS EmployeeName,'Leaves' as ItemName, LT.Name as ItemType, DateValue as StartDate, 
		DateValue as EndDate, LA.LeaveStatus as ItemStatus,TCD.[Order] AS ColorOrder,TCD.Id AS TeamCalendarDetailId ,
		TCD.MasterId AS TeamCalendarId ,NULL AS CourseCode ,NULL AS CourseName ,NULL AS CourseCategory, NULL AS FirstHalfFromTime ,
		NULL AS FirstHalfToTime ,NULL AS SecondHalfFromTime ,NULL AS SecondHalfToTime ,NULL AS FirstHalfTotalHours ,NULL AS SecondHalfTotalHours,
		EntitlementType AS EntitlementType ,StartDateType AS StartDateType ,EndDateType AS EndDateType ,CONVERT(NVARCHAR(100), LA.Hours) AS LeaveHours,
		(SELECT mr.Small FROM Common.MediaRepository AS mr (NOLOCK) JOIN common.Employee AS e (NOLOCK) ON mr.id = e.PhotoId WHERE e.id = LA.EmployeeId) AS PhotoURL
	FROM  Hr.LeaveApplication LA (NOLOCK) 
		INNER JOIN hr.LeaveType LT (NOLOCK) on LT.Id = LA.LeaveTypeId
		INNER JOIN Common.Employee AS B (NOLOCK) ON la.EmployeeId = b.Id
		INNER JOIN dbo.DateRange_Function (@CompanyId,@startDate,@endDate) AS A ON A.DateValue BETWEEN LA.StartDateTime AND LA.EndDateTime
		LEFT JOIN hr.TeamCalendarDetail TCD  (NOLOCK) on TCD.EmployeeId = LA.EmployeeId and TCD.MasterId = @TeamCalendarId 
	WHERE LA.EmployeeId IN (SELECT EmployeeId FROM #Employees) --AND CAST(LA.StartDateTime AS DATE) != CAST(LA.EndDateTime AS Date)
		AND (LA.LeaveStatus='Submitted' or LA.LeaveStatus = 'Approved' OR LA.LeaveStatus='Recommended'  )
	
	UNION ALL

------>> Trainings
	SELECT  DISTINCT  
		E.Id as EmployeeId,E.FirstName AS EmployeeName, 'Training' AS ItemName, CL.CourseName AS Itemtype, A.DateValue AS StartDate , A.DateValue AS EndDate,
		TA.EmployeeTrainigStatus AS ItemStatus ,TCD.[Order] AS ColorOrder, TCD.Id AS TeamCalendarDetailId, TCD.MASterId AS TeamCalendarId,
		CL.CourseCode AS CourseCode, CL.CourseName AS CourseName, CL.CourseCategory AS CourseCategory, TS.FirstHalfFromTime, TS.FirstHalfToTime, 
		TS.SecondHalfFromTime, TS.SecondHalfToTime, TS.FirstHalfTotalHours, TS.SecondHalfTotalHours, NULL AS EntitlementType, NULL AS StartDateType,
		NULL AS EndDateType,NULL AS LeaveHours,
		(SELECT mr.Small FROM Common.MediaRepository AS mr (NOLOCK) JOIN common.Employee AS e (NOLOCK) ON mr.id = e.PhotoId WHERE e.id = TA.EmployeeId) AS PhotoURL
	FROM Hr.Training AS TR (NOLOCK) 
		INNER JOIN hr.TrainingSchedule TS (NOLOCK) on TR.Id=TS.TrainingId
		INNER JOIN HR.CourseLibrary AS CL (NOLOCK) ON CL.Id = TR.CourseLibraryId
		INNER JOIN dbo.DateRange_Function (@CompanyId,@startDate,@endDate) AS A ON A.DateValue BETWEEN TR.StartDate AND TR.EndDate
		INNER JOIN 
			(
				SELECT 'Attendee'AS Type,TrainingId,EmployeeId,EmployeeTrainigStatus FROM Hr.TrainingAttendee AS TA  --WHERE TrainingId = '22826FD1-50D7-45E4-8400-70666D2ACE80'
				UNION ALL
				SELECT A.Type,a.Id as TrainingId,E.Id as EmployeeId,NULL AS EmployeeTrainingStatus FROM 
					(
					  SELECT Id,'Trainer' AS Type,LTRIM(value) AS [Value],CourseLibraryId
					  FROM HR.Training CROSS APPLY STRING_SPLIT(TrainerIds, ',') 
					) as a
					INNER JOIN HR.CourseLibrary AS CL  ON CL.Id = A.CourseLibraryId
					INNER JOIN HR.TrainerCourse AS TC  ON TC.CourseLibraryId = CL.Id
					INNER JOIN HR.Trainer AS Tra  ON TC.TrainerId = Tra.Id
					LEFT JOIN  Common.CompanyUser AS CU  ON CU.Id = Tra.CompanyUserId 
					LEFT JOIN Common.Employee AS E ON E.Username = CU.Username  AND E.CompanyId = CU.CompanyId
				--WHERE a.Id = '22826FD1-50D7-45E4-8400-70666D2ACE80'
			)AS TA  ON TA.TrainingId = TR.Id 	
		INNER JOIN Common.Employee AS E (NOLOCK) ON E.Id = TA.EmployeeId AND TR.CompanyId = @companyId
		LEFT JOIN hr.TeamCalendarDetail TCD  (NOLOCK) on TCD.EmployeeId = TA.EmployeeId AND TCD.MasterId = @TeamCalendarId 
	WHERE TA.EmployeeId IN (SELECT EmployeeId FROM #Employees) AND
	(TA.EmployeeTrainigStatus='Registered' or TA.EmployeeTrainigStatus='Completed'  OR TA.EmployeeTrainigStatus='Absent' OR TA.EmployeeTrainigStatus='Incomplete') AND CL.CourseName  IS NOT NULL
	OPTION (MAXRECURSION 0)

DROP TABLE #Employees

END
GO
