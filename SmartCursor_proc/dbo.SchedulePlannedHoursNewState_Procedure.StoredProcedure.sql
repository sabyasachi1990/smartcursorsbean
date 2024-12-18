USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[SchedulePlannedHoursNewState_Procedure]    Script Date: 16-12-2024 9.20.11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   Procedure [dbo].[SchedulePlannedHoursNewState_Procedure]
 @Fromdate date,  
 @ToDate date,  
 @DesignationName nvarchar (max),  
 @DepartmentId nvarchar (max),  
 @EmployeeId nvarchar (max),   
 @CompanyId int  
  
 AS  
 BEGIN  
  
--DECLARE 
--	@Fromdate date = '2023-01-02', 
--	@ToDate date = '2023-01-31',  
--	@DesignationName nvarchar (max)='Senior',  
--	@DepartmentId nvarchar (max)= 'A7256B56-9B23-4EAE-9A77-86E7AD7EEC7E', 
--	@EmployeeId nvarchar (max)='6F88A5D2-57BA-4AC4-B664-1C81C32C92B2,54EB3FE5-2147-4243-BE51-B591F7596672',   
--	@CompanyId int = 2050  
DECLARE @WorkWeekHours Decimal(17,2) = (SELECT CAST(SUM(DATEDIFF(MINUTE, 0, WorkingHours)) / 60.0  AS DECIMAL(20,2)) AS TotalHours FROM Common.WorkWeekSetUp WHERE CompanyId = @CompanyId AND EmployeeId IS NULL AND IsWorkingDay!=0)

CREATE TABLE  #Temp  (StartDate date,Enddate date) 

DECLARE @OutPut TABLE 
(
EmployeeName Nvarchar(400),StartDate Date,EndDate Date,TOATLHOURS Decimal(17,2), IsOverRunHours Decimal(17,2),EmployeeId UniqueIdentifier,EmployeeAutoNumber varchar(200),
PhotoURL Nvarchar(Max),SystemId UniqueIdentifier,SystemType Nvarchar(40), IsType Int, ClientName Nvarchar(400), CaseState Nvarchar(50), CaseNumber Nvarchar(200), OppState Nvarchar(20),
ServiceGroup Nvarchar(40), ServiceCode Nvarchar(40), Likelihood  Nvarchar(40),  CaseId UniqueIdentifier NULL, TaskDate Date,Task Nvarchar(100), ClientId UniqueIdentifier NULL,IsOverRun Decimal(17,2), 
LeaveStatus Nvarchar(40), TimeType Nvarchar(50) 

)
;WITH CTE AS
(
	SELECT @FROMDATE StartDate, CAST(DATEADD(wk, DATEDIFF(wk, 0, @FROMDATE), 5) AS Date) EndDate  
    UNION ALL	
	SELECT DATEADD(ww, 1, StartDate),DATEADD(ww, 1, EndDate) FROM cte
	WHERE DATEADD(ww, 1, StartDate) <= @TODATE
)

INSERT INTO #Temp
SELECT * FROM cte
   
-------->>> Spliting The EmployeeId's
SELECT * INTO #EmployeeIdTable FROM (
SELECT 	TRIM(value) AS EmployeeId FROM STRING_SPLIT(@EmployeeId, ',')
WHERE LTRIM(RTRIM(value)) <> ''
) AS A

-------->>> Concatinating The Task Names Of Employees Based on CaseId, EmployeeId, Date	
SELECT * INTO #Task FROM (
SELECT DISTINCT AA.CaseId AS AACaseId, AA.EmployeeId AS AAEmployeeId, CONVERT(DATE, AA.StartDate) AS AATaskDate,
	STRING_AGG(A.Task, ', ') WITHIN GROUP (ORDER BY A.Task) AS AATask
FROM  WorkFlow.ScheduleTaskNew AA  
INNER JOIN  WorkFlow.ScheduleTaskNew A   
	ON A.CaseId = AA.CaseId  AND A.EmployeeId = AA.EmployeeId   AND CONVERT(DATE, A.StartDate) = CONVERT(DATE, AA.StartDate)
WHERE  AA.Status = 1  AND AA.CompanyId = @CompanyId AND AA.EmployeeId IN (SELECT * FROM #EmployeeIdTable)
GROUP BY  AA.CaseId, AA.EmployeeId, CONVERT(DATE, AA.StartDate), AA.Task
) AS A



INSERT INTO @OutPut
------->>> Employee Details for fetching data when no there is no data from the output
	SELECT 
		EMPLOYEENAME,B.StartDate AS CsrSdate,B.Enddate AS csrEdate,0.00 as TOATLHOURS, ISOVERRUNHOURS, EMPLOYEEID ,EMPLOYEEAUTONUMBER,PHOTOURL,SystemId, 
		SystemType, 0 as IsType,ClientName, CaseState,CaseNumber, OppState, ServiceGroup, ServiceCode ,Likelihood ,  CaseId,TaskDate, Task , ClientId, 
		0.00 as IsOverRun,LeaveStatus, TimeType
	FROM
		(
			SELECT 
				A.FirstName as EMPLOYEENAME,NULL AS CsrSdate,NULL AS csrEdate, NULL AS TOATLHOURS, NULL AS ISOVERRUNHOURS, A.Id AS EMPLOYEEID ,
				a.EmployeeId as EMPLOYEEAUTONUMBER,mr.Small as PHOTOURL,Null as SystemId, Null as  SystemType, Null as IsType,Null as ClientName, 
				Null as CaseState,Null as CaseNumber, Null as OppState, Null as ServiceGroup, Null as ServiceCode ,  
				NULL as Likelihood ,  NULL as CaseId,NULL as TaskDate,NULL as  Task ,NULL as  ClientId, NULL as IsOverRun,NULL as LeaveStatus, NULL AS TimeType
			FROM Common.Employee AS A
			INNER JOIN #EmployeeIdTable AS B ON B.EmployeeId = A.Id
			LEFT JOIN Common.MediaRepository as MR  ON MR.Id = A.PhotoId 		
		) AS A
		CROSS JOIN #Temp AS B

INSERT INTO @OutPut
----->> Schedule Task
SELECT 
	EMPLOYEENAME,CsrSdate,csrEdate,cast(cast (sum(TOATLHOURS ) / 60 + (sum(TOATLHOURS ) % 60) / 100.0  as decimal(28,2)) as  varchar(max))  As TOATLHOURS,  
	cast(cast (sum(ISOVERRUNHOURS ) / 60 + (sum(ISOVERRUNHOURS ) % 60) / 100.0  as decimal(28,2)) as  varchar(max))  As ISOVERRUNHOURS,EMPLOYEEID,  
	EMPLOYEEAUTONUMBER, PHOTOURL, SystemId,  SystemType, IsType,ClientName, CaseState,CaseNumber, OppState, ServiceGroup, ServiceCode ,  
	Likelihood ,  CaseId,TaskDate,REPLACE(AATask, '&amp;', '&') as Task ,ClientId, sum(IsOverRun) as IsOverRun,LeaveStatus,NULL AS TimeType
FROM  ( 
		SELECT
			E.FirstName AS EMPLOYEENAME,ST.Task,TEP.StartDate AS CsrSdate,TEP.EndDate AS csrEdate,ST.PlannedHours AS TOATLHOURS,ST.OverRunHours AS ISOVERRUNHOURS,
			E.ID AS EMPLOYEEID,e.EmployeeId AS  EMPLOYEEAUTONUMBER,MR.Small as PHOTOURL,
			ST.CaseId AS SystemId,'CaseGroup' AS 'SystemType',0 AS IsType,
			CG.Name AS ClientName,CG.Stage AS CaseState,CG.CaseNumber,o.Stage AS OppState,sg.Code AS ServiceGroup,ss.Code AS ServiceCode,CG.Likelihood,
			CG.Id AS CaseId,CONVERT(DATE, ST.StartDate) TaskDate,CG.ClientId AS ClientId,
			ISNULL(CASE WHEN IsOverRun = 1 THEN CONVERT(INT, IsOverRun)END, 0) AS IsOverRun,NULL AS LeaveStatus,GG.AATask 
		FROM  WorkFlow.ScheduleTaskNew ST  
		INNER JOIN WorkFlow.CaseGroup CG  ON ST.CaseId = CG.Id
		LEFT JOIN ClientCursor.Opportunity o   ON o.Id = CG.OpportunityId
		INNER JOIN Common.ServiceGroup sg  ON sg.id = CG.ServiceGroupId
		INNER JOIN Common.[Service] ss  ON ss.id = CG.ServiceId
		INNER JOIN Common.Employee E  ON ST.EMPLOYEEID = E.Id AND E.DepartmentId = ST.DepartmentId AND E.DesignationId = ST.DesignationId
		INNER JOIN #Temp TEP ON CAST(ST.StartDate AS DATE) >= TEP.StartDate AND CAST(ST.EndDate AS DATE) <= TEP.EndDate
		LEFT JOIN Common.MediaRepository as MR  ON MR.Id=E.PhotoId  
		LEFT JOIN  #Task AS GG ON GG.aaCaseId = ST.CaseId AND  GG.aaEmployeeId = ST.EMPLOYEEID AND GG.aaTaskDate = ST.StartDate 
		WHERE ST.CompanyId = @CompanyId AND ST.EmployeeId IN (SELECT * FROM #EmployeeIdTable) AND ST.Status = 1 
		AND CAST(ST.StartDate AS DATE) >= TEP.StartDate AND CAST(ST.EndDate AS DATE) <= TEP.EndDate 
	) AS A
GROUP BY EMPLOYEENAME,CsrSdate,csrEdate,EMPLOYEEID,EMPLOYEEAUTONUMBER,PHOTOURL,SystemId,  SystemType, IsType,  
ClientName, CaseState,CaseNumber, OppState, ServiceGroup, ServiceCode ,Likelihood ,  CaseId,TaskDate,AATask,ClientId,LeaveStatus


--SELECT 
--	EMPLOYEENAME,CsrSdate,csrEdate,cast(cast (sum(TOATLHOURS ) / 60 + (sum(TOATLHOURS ) % 60) / 100.0  as decimal(28,2)) as  varchar(max))  As TOATLHOURS,  
--	cast(cast (sum(ISOVERRUNHOURS ) / 60 + (sum(ISOVERRUNHOURS ) % 60) / 100.0  as decimal(28,2)) as  varchar(max))  As ISOVERRUNHOURS,EMPLOYEEID,  
--	EMPLOYEEAUTONUMBER, PHOTOURL, SystemId,  SystemType, IsType,ClientName, CaseState,CaseNumber, OppState, ServiceGroup, ServiceCode ,  
--	Likelihood ,  CaseId,TaskDate,REPLACE(Task, '&amp;', '&') as Task ,ClientId, sum(IsOverRun) as IsOverRun,LeaveStatus,NULL AS TimeType
--FROM  ( 
--		SELECT
--			E.FirstName AS EMPLOYEENAME,ST.Task,T.StartDate AS CsrSdate,T.EndDate AS csrEdate,ST.PlannedHours AS TOATLHOURS,ST.OverRunHours AS ISOVERRUNHOURS,
--			E.ID AS EMPLOYEEID,e.EmployeeId AS  EMPLOYEEAUTONUMBER,MR.Small as PHOTOURL,
--			ST.CaseId AS SystemId,'CaseGroup' AS 'SystemType',0 AS IsType,
--			CG.Name AS ClientName,CG.Stage AS CaseState,CG.CaseNumber,o.Stage AS OppState,sg.Code AS ServiceGroup,ss.Code AS ServiceCode,CG.Likelihood,
--			CG.Id AS CaseId,CONVERT(DATE, ST.StartDate) TaskDate,CG.ClientId AS ClientId,
--			ISNULL(CASE WHEN IsOverRun = 1 THEN CONVERT(INT, IsOverRun)END, 0) AS IsOverRun,NULL AS LeaveStatus
--		FROM WorkFlow.ScheduleTaskNew ST (NOLOCK)   
--			INNER JOIN WorkFlow.CaseGroup CG (NOLOCK)  on ST.CaseId = CG.Id  
--			LEFT JOIN ClientCursor.Opportunity o (NOLOCK)  on o.Id=cg.OpportunityId 
--			INNER JOIN Common.ServiceGroup sg  ON sg.id = CG.ServiceGroupId
--			INNER JOIN Common.[Service] ss  ON ss.id = CG.ServiceId
--			INNER JOIN Common.Employee E (NOLOCK)  on ST.EmployeeId = E.Id    
--			LEFT JOIN Common.MediaRepository as MR (NOLOCK)  ON MR.Id=E.PhotoId  
--			INNER JOIN #Temp AS T ON CAST(ST.StartDate AS Date) BETWEEN T.StartDate AND T.Enddate 
--			WHERE st.CompanyId = @CompanyId and ST.EmployeeId = @EmployeeId  and st.Status=1   
--	) AS A
--GROUP BY EMPLOYEENAME,CsrSdate,csrEdate,EMPLOYEEID,EMPLOYEEAUTONUMBER,PHOTOURL,SystemId,  SystemType, IsType,  
--ClientName, CaseState,CaseNumber, OppState, ServiceGroup, ServiceCode ,Likelihood ,  CaseId,TaskDate,Task ,ClientId,LeaveStatus

INSERT INTO @OutPut
-------->>> Calendar
SELECT  DISTINCT EMPLOYEENAME,StartDate,EndDate ,TOATLHOURS,ISOVERRUNHOURS, EmployeeId, EMPLOYEEAUTONUMBER, PhotoURL,SystemId, [System Type],IsType,  
ClientName, CaseState, CaseNumber, OppState, ServiceGroup, ServiceCode, Likelihood, NULL as CaseId, TaskDate, Task, 
NULL as ClientId, CAST(IsOverRun AS decimal(17,2)),  LeaveStatus,TimeType 
FROM (
		SELECT DISTINCT E.FirstName as EMPLOYEENAME,TEP.StartDate,TEP.EndDate ,CAST(ISNULL(a.Hours,0) AS Decimal(17,2)) As TOATLHOURS,'00.00' AS ISOVERRUNHOURS, 
		CASE WHEN A.ApplyToAll = 1 THEN E.Id ELSE C.EmployeeId END AS EmployeeId, e.EmployeeId AS  EMPLOYEEAUTONUMBER, MR.Small as PHOTOURL,
		CA.Id AS SystemId, 'Calender' AS 'System Type', 2 as IsType,  
		ca.[Name] as ClientName,null as CaseState,null as CaseNumber,NULL as OppState,NULL as ServiceGroup,null as ServiceCode,null as Likelihood  , NULL AS CaseId, 
		CONVERT( date, A.StartDate) TaskDate ,NULL as Task,NULL AS ClientId ,0 as IsOverRun, NULL AS LeaveStatus,A.TimeType
		FROM  Common.CalenderSchedule AS A  
			INNER JOIN Common.Calender AS CA ON CA.Id = A.CalenderId
			INNER JOIN Common.Employee AS E  ON E.CompanyId = A.CompanyId AND E.CompanyId = @CompanyId
			LEFT JOIN Common.CalenderDetails AS C  ON C.MasterId = A.CalenderId AND E.Id = C.EmployeeId
			LEFT JOIN Common.MediaRepository as MR  ON MR.Id=E.PhotoId  
			INNER JOIN #Temp as TEP ON CAST(A.StartDate AS DATE) BETWEEN  TEP.StartDate AND TEP.EndDate
		WHERE CAST(A.StartDate AS date) BETWEEN @Fromdate AND @ToDate AND A.CompanyId = @CompanyId AND A.CompanyId = @CompanyId AND CA.Status = 1
	) AS A 
WHERE A.EmployeeId IN (SELECT EmployeeId FROM #EmployeeIdTable) 


INSERT INTO @OutPut
--------->>> Leaves
SELECT  EMPLOYEENAME, StartDate, EndDate , SUM([TOATLHOURS]) AS [TOATLHOURS], ISOVERRUNHOURS,  EMPLOYEEID, EMPLOYEEAUTONUMBER, PHOTOURL,SystemId, [System Type], IsType,  ClientName,CaseState,CaseNumber, OppState, ServiceGroup, ServiceCode , Likelihood ,  CaseId,  TaskDate, Task, ClientId, IsOverRun, LeaveStatus, TimeType
FROM (
SELECT DISTINCT 
	E.FirstName as EMPLOYEENAME,TEP.StartDate,TEP.EndDate ,
				CAST(CASE 
						 WHEN LT.Name LIKE 'Time%' THEN Cast(Replace(FORMAT(FLOOR(LA.Hours)*100 + (LA.Hours-FLOOR(LA.Hours))*60,'00:00'),':','.') As Decimal(17,2))
						 WHEN LT.Name NOT LIKE 'Time%' AND A.DateValue = CAST(LA.StartDateTime as Date) AND A.DateValue = CAST(LA.EndDateTime as Date)  AND LA.StartDateType = 'AM' AND LA.EndDateType = 'AM' THEN (CASE WHEN A.DateValue = H.TaskDate AND H.TimeType = 'AM' THEN (4-H.TOATLHOURS) ELSE 4  END)
						 WHEN LT.Name NOT LIKE 'Time%' AND A.DateValue = CAST(LA.StartDateTime as Date) AND A.DateValue = CAST(LA.EndDateTime as Date)  AND LA.StartDateType = 'PM' AND LA.EndDateType = 'PM' THEN (CASE WHEN A.DateValue = H.TaskDate AND H.TimeType = 'PM' THEN (4-H.TOATLHOURS) ELSE 4  END)
						 WHEN LT.Name NOT LIKE 'Time%' AND A.DateValue = CAST(LA.StartDateTime as Date) AND A.DateValue = CAST(LA.EndDateTime as Date)  AND LA.StartDateType = 'Full' AND LA.EndDateType = 'Full' THEN (CASE WHEN A.DateValue = H.TaskDate THEN 8-H.TOATLHOURS ELSE 8  END)
						 WHEN LT.Name NOT LIKE 'Time%' AND A.DateValue = CAST(LA.StartDateTime as Date) AND A.DateValue = CAST(LA.EndDateTime as Date)  AND LA.StartDateType = 'Full' AND LA.EndDateType IN ('AM','PM') THEN 0
						 WHEN LT.Name NOT LIKE 'Time%' AND A.DateValue = CAST(LA.StartDateTime as Date) AND A.DateValue = CAST(LA.EndDateTime as Date)  AND LA.StartDateType = 'PM' AND LA.EndDateType IN ('AM','Full') THEN 0
						 WHEN LT.Name NOT LIKE 'Time%' AND A.DateValue = CAST(LA.StartDateTime as Date) AND A.DateValue = CAST(LA.EndDateTime as Date)  AND LA.StartDateType = 'AM' AND LA.EndDateType IN ('PM','Full') THEN 0
						 WHEN LT.Name NOT LIKE 'Time%' AND A.DateValue = CAST(LA.StartDateTime as Date) AND A.DateValue != CAST(LA.EndDateTime as Date) AND LA.StartDateType = 'AM' THEN (CASE WHEN A.DateValue = H.TaskDate THEN 8-H.TOATLHOURS ELSE 8  END)
						 WHEN LT.Name NOT LIKE 'Time%' AND A.DateValue = CAST(LA.StartDateTime as Date) AND A.DateValue != CAST(LA.EndDateTime as Date) AND LA.StartDateType = 'Full' THEN (CASE WHEN A.DateValue = H.TaskDate THEN 8-H.TOATLHOURS ELSE 8  END)
						 WHEN LT.Name NOT LIKE 'Time%' AND A.DateValue = CAST(LA.StartDateTime as Date) AND A.DateValue != CAST(LA.EndDateTime as Date) AND LA.StartDateType = 'PM' THEN (CASE WHEN A.DateValue = H.TaskDate AND H.TimeType = 'PM' THEN 4-(H.TOATLHOURS/8) ELSE 4 END)
						 WHEN LT.Name NOT LIKE 'Time%' AND A.DateValue != CAST(LA.StartDateTime as Date) AND A.DateValue = CAST(LA.EndDateTime as Date) AND LA.EndDateType = 'AM' THEN (CASE WHEN A.DateValue = H.TaskDate AND H.TimeType = 'AM' THEN 4-H.TOATLHOURS ELSE 4  END)
						 WHEN LT.Name NOT LIKE 'Time%' AND A.DateValue != CAST(LA.StartDateTime as Date) AND A.DateValue = CAST(LA.EndDateTime as Date) AND LA.EndDateType = 'Full' THEN (CASE WHEN A.DateValue = H.TaskDate THEN 8-H.TOATLHOURS ELSE 8  END)
						 WHEN LT.Name NOT LIKE 'Time%' AND A.DateValue != CAST(LA.StartDateTime as Date) AND A.DateValue = CAST(LA.EndDateTime as Date) AND LA.EndDateType = 'PM' THEN (CASE WHEN A.DateValue = H.TaskDate AND H.TimeType = 'PM' THEN 8-H.TOATLHOURS ELSE 8  END)
						 WHEN LT.Name NOT LIKE 'Time%' AND A.DateValue != CAST(LA.StartDateTime as Date) AND A.DateValue != CAST(LA.EndDateTime as Date) THEN (CASE WHEN A.DateValue = H.TaskDate THEN 8-H.TOATLHOURS ELSE 8  END)
						 ELSE 8
					END AS Decimal(17,2)) AS [TOATLHOURS],
	'00.00' AS ISOVERRUNHOURS,  
	E.Id AS EMPLOYEEID, e.EmployeeId AS  EMPLOYEEAUTONUMBER, 
	MR.Small as PHOTOURL,
	LA.Id AS SystemId, 'LeaveApplication' AS 'System Type', 1 as IsType,   
	LT.[Name] as ClientName,null as CaseState,null as CaseNumber,null as OppState,null as ServiceGroup,null as ServiceCode ,null as Likelihood , null as CaseId,  
	CONVERT( date, A.DateValue) TaskDate,null as Task,null as ClientId,0 as IsOverRun,LA.LeaveStatus AS LeaveStatus,NULL AS TimeType
FROM Hr.LeaveApplication AS LA 
INNER JOIN hr.LeaveType LT  on LT.Id = LA.LeaveTypeId
INNER JOIN Common.Employee AS E ON E.Id = LA.EmployeeId
INNER JOIN dbo.DateRange_Function (@CompanyId,@Fromdate ,@ToDate) AS A ON A.DateValue >= CAST(LA.StartDateTime AS Date) AND A.DateValue <= CAST(LA.EndDateTime AS Date) 
LEFT JOIN Common.MediaRepository as MR  ON MR.Id=E.PhotoId  
INNER JOIN #Temp as TEP ON CAST(A.DateValue AS DATE) BETWEEN  TEP.StartDate AND TEP.EndDate
LEFT JOIN (SELECT EmployeeId,TaskDate,TimeType,CAST(TOATLHOURS AS float) as TOATLHOURS  FROM @OutPut WHERE TimeType != 'Full') AS H ON H.EmployeeId = LA.EmployeeId  
WHERE LA.EmployeeId IN (SELECT EmployeeId FROM #EmployeeIdTable) AND LA.LeaveStatus IN ('Submitted','Recommended','Approved','For Cancellation')
) AS A
GROUP BY EMPLOYEENAME, StartDate, EndDate , ISOVERRUNHOURS,  EMPLOYEEID, EMPLOYEEAUTONUMBER, PHOTOURL,SystemId, [System Type], IsType,  ClientName,CaseState,
	CaseNumber, OppState, ServiceGroup, ServiceCode , Likelihood ,  CaseId,  TaskDate, Task, ClientId, IsOverRun, LeaveStatus, TimeType

INSERT INTO @OutPut
------>>> Training Of Trainer and Attendee
SELECT  DISTINCT  
	E.FirstName as EMPLOYEENAME,TEP.StartDate,TEP.EndDate ,ISNULL(CONVERT(DECIMAL(17, 2), REPLACE(LEFT(DATEADD(SECOND, DATEDIFF(SECOND, 0, TS.FirstHalfTotalHours), TS.SecondHalfTotalHours ), 5), ':', '.')),'0.00' )As TOATLHOURS,'00.00' AS ISOVERRUNHOURS,  
	E.Id AS EMPLOYEEID, e.EmployeeId AS  EMPLOYEEAUTONUMBER, MR.Small as PHOTOURL,
	TR.Id AS SystemId, 'Training' AS 'System Type', 2 as IsType,  
	CL.CourseName as ClientName,null as CaseState,null as CaseNumber,null as OppState,null as ServiceGroup,null as ServiceCode,null as Likelihood  , null as CaseId,  
	CAST(a.DateValue AS Date) TaskDate ,null as Task,null as ClientId ,0 as IsOverRun, NULL AS LeaveStatus, NULL AS TimeType 
FROM Hr.Training AS TR  
	INNER JOIN hr.TrainingSchedule TS  on TR.Id=TS.TrainingId
	INNER JOIN HR.CourseLibrary AS CL  ON CL.Id = TR.CourseLibraryId
	INNER JOIN dbo.DateRange_Function (@CompanyId,@Fromdate,@ToDate) AS A ON A.DateValue BETWEEN CAST(TR.StartDate AS Date) AND CAST(TR.EndDate AS Date)
	INNER JOIN #Temp as TEP ON CAST(A.DateValue AS DATE) BETWEEN  TEP.StartDate AND TEP.EndDate
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
	INNER JOIN Common.Employee AS E  ON E.Id = TA.EmployeeId AND TR.CompanyId = @companyId
	LEFT JOIN Common.MediaRepository as MR  ON MR.Id = E.PhotoId
WHERE TA.EmployeeId IN (SELECT EmployeeId FROM #EmployeeIdTable) AND TS.TrainingDate = A.DateValue AND TR.Status = 1


-------------------->>> OUTPUT
SELECT DISTINCT 
	EMPLOYEENAME,StartDate,EndDate ,A.TOATLHOURS,A.ISOVERRUNHOURS, a.EmployeeId, EMPLOYEEAUTONUMBER, a.PhotoURL,A.SystemId, A.SystemType,A.IsType,  
	A.ClientName, A.CaseState, A.CaseNumber, A.OppState, A.ServiceGroup, A.ServiceCode, A.Likelihood, A.CaseId, a.TaskDate, A.Task, A.ClientId,
	CAST(A.IsOverRun AS decimal(17,2)) AS IsOverRun, A.LeaveStatus, B.DepartmentCode, B.DesignationName,B.LevelRank, @WorkWeekHours AS WorkWeekHours 
FROM @OutPut AS A 
LEFT JOIN
(
    SELECT DISTINCT CompanyId,A.EmployeeId,A.DepartmentId, DepartmentCode, DepartmentDesignationId, DesignationName,LevelRank,  EffectiveFrom,
	CAST(EffectiveTo AS Date) EffectiveTo
    FROM (
			SELECT 
			ROW_NUMBER() OVER (PARTITION BY A.EmployeeId, E.CompanyId ORDER BY A.EffectiveFrom DESC, 
			CAST(CASE WHEN EffectiveTo IS NULL THEN dateadd(d,-1,Convert(date,Convert(varchar(100),Year(GETDATE())+1)+'-'+'01'+'-'+'01')) ELSE EffectiveTo END  AS Date) DESC, A.CreatedDate DESC) AS LD,
			 E.CompanyId,A.EmployeeId,A.DepartmentId, B.Code AS DepartmentCode, A.DepartmentDesignationId, C.Name AS DesignationName, A.LevelRank,  CAST(A.EffectiveFrom AS Date) EffectiveFrom, 
			 CAST(CASE WHEN EffectiveTo IS NULL THEN dateadd(d,-1,Convert(date,Convert(varchar(100),Year(GETDATE())+1)+'-'+'01'+'-'+'01')) ELSE EffectiveTo END  AS Date) EffectiveTo
			FROM HR.EmployeeDepartment AS A WITH (NOLOCK)
			INNER JOIN Common.Department AS B WITH (NOLOCK) ON B.Id = A.DepartmentId
			INNER JOIN Common.DepartmentDesignation AS C WITH (NOLOCK) ON C.Id = A.DepartmentDesignationId 
			JOIN Common.Employee AS E ON E.Id = A.EmployeeId
			JOIN #EmployeeIdTable AS F ON F.EmployeeId = E.Id
    ) AS A
	WHERE LD = 1
) AS B ON B.EmployeeId = A.EMPLOYEEID
--WHERE CAST(TaskDate AS Date) BETWEEN b.EffectiveFrom AND b.EffectiveTo

DROP TABLE #Temp
DROP TABLE #EmployeeIdTable
DROP TABLE #task

END
GO
