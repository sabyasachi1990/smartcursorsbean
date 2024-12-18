USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [WorkFlow].[ScheduleDetailPlannedHours]    Script Date: 16-12-2024 9.20.11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE   PROCEDURE [WorkFlow].[ScheduleDetailPlannedHours]
@FROMDATE DATE, 
@TODATE DATE, 
@EMPLOYEEID UNIQUEIDENTIFIER, 
@COMPANYID BIGINT 

AS
BEGIN

DECLARE @Temp TABLE ( StartDate DATE, Enddate DATE)

DECLARE @WorkWeekHours Decimal(17,2) = (SELECT CAST(SUM(DATEDIFF(MINUTE, 0, WorkingHours)) / 60.0  AS DECIMAL(20,2)) AS TotalHours FROM Common.WorkWeekSetUp WHERE CompanyId = @CompanyId AND EmployeeId IS NULL AND IsWorkingDay!=0)

DECLARE @OutPut_Tbl TABLE
	( 
		EMPLOYEENAME NVARCHAR (1000),EMPLOYEEID UNIQUEIDENTIFIER,EMPLOYEENUMBER NVARCHAR(100),  
		CLIENTNAME NVARCHAR(1000),CASENUMBER NVARCHAR(100),CASENAME NVARCHAR(1000), STARTDATE DATE,  
		ENDDATE DATE,TOATLHOURS varchar(max),IsOverRunHours varchar(max),CASEID UNIQUEIDENTIFIER,PHOTOURL NVARCHAR(1000),  
		SCHEDULETYPEID UNIQUEIDENTIFIER NULL,SUBTYPE NVARCHAR(1000), OppSTAGE NVARCHAR(50), SCHEDULETYPE NVARCHAR(100), IsType bit,  
		LeaveStatus NVARCHAR(100),TimeType Nvarchar(20),TaskDate Date
	)  

;WITH CTE AS
 (
	SELECT @FROMDATE StartDate ,CAST(DATEADD(wk, DATEDIFF(wk, 0, @FROMDATE), 5) AS Date)EndDate
	UNION ALL
	SELECT DATEADD(ww, 1, StartDate),DATEADD(ww, 1, Enddate)
	FROM cte
	WHERE DATEADD(ww, 1, StartDate) <= @TODATE 
 )

INSERT INTO @Temp  
SELECT StartDate,Enddate FROM CTE  




INSERT INTO @OutPut_Tbl
------>>>> Task
SELECT
	EMPLOYEENAME,EMPLOYEEID,EMPLOYEENUMBER,CLIENTNAME,CASENUMBER,CASENAME,CsrSdate,csrEdate,cast(cast (sum(TOATLHOURS ) / 60 + (sum(TOATLHOURS ) % 60) / 100.0  as decimal(28,2)) as  varchar(max)) As TOATLHOURS,  
	cast(cast (sum(ISOVERRUNHOURS ) / 60 + (sum(ISOVERRUNHOURS ) % 60) / 100.0  as decimal(28,2)) as  varchar(max)) As ISOVERRUNHOURS,  
	CASEID,PHOTOURL,SCHEDULETYPEID,SUBTYPE,OppSTAGE,SCHEDULETYPE,IsType,LeaveStatus,NULL AS TimeType, NULL AS TaskDate
FROM   
	( 
		SELECT 
			E.FirstName as EMPLOYEENAME,E.Id AS EMPLOYEEID,e.EmployeeId AS EMPLOYEENUMBER,st.Task,  
			Cg.NAME AS CLIENTNAME ,CG.SYSTEMREFNO AS CASENUMBER, Cg.NAME AS CASENAME,T.StartDate as CsrSdate,T.Enddate as csrEdate,st.PlannedHours TOATLHOURS ,  
			OverRunHours As  ISOVERRUNHOURS,CG.ID AS CASEID,  
			MR.Small as PHOTOURL,ST.CaseId AS SCHEDULETYPEID, NULL AS SUBTYPE,o.stage as OppSTAGE,'CaseGroup' AS  SCHEDULETYPE, 0 as  IsType,Null as LeaveStatus    
		FROM WorkFlow.ScheduleTaskNew ST (NOLOCK)   
			INNER JOIN WorkFlow.CaseGroup CG (NOLOCK)  on ST.CaseId = CG.Id  
			LEFT JOIN ClientCursor.Opportunity o (NOLOCK)  on o.Id=cg.OpportunityId 
			INNER JOIN Common.Employee E (NOLOCK)  on ST.EmployeeId = E.Id    
			LEFT JOIN Common.MediaRepository as MR (NOLOCK)  ON MR.Id=E.PhotoId  
			INNER JOIN @Temp AS T ON CAST(ST.StartDate AS Date) BETWEEN T.StartDate AND T.Enddate 
		WHERE st.CompanyId = @CompanyId and ST.EmployeeId = @EmployeeId  and st.Status=1    
		GROUP BY E.FirstName,st.Task,st.PlannedHours,st.OverRunHours,ST.StartDate,o.stage,ST.Enddate,E.Id,e.EmployeeId, ST.CaseId,MR.Small, CG.ID,Cg.NAME,CG.SYSTEMREFNO,
		T.StartDate,T.Enddate
	 )kk  
GROUP BY EMPLOYEENAME,EMPLOYEEID,EMPLOYEENUMBER,CLIENTNAME,CASENUMBER,CASENAME,CsrSdate,csrEdate, CASEID,PHOTOURL,SCHEDULETYPEID,SUBTYPE,OppSTAGE,SCHEDULETYPE,IsType,LeaveStatus   


INSERT INTO @OutPut_Tbl
------>>>> Calendar
SELECT * 
FROM (
		SELECT DISTINCT 
			E.FirstName as EMPLOYEENAME,CASE WHEN A.ApplyToAll = 1 THEN E.Id ELSE C.EmployeeId END AS EmployeeId, e.EmployeeId AS  EMPLOYEEAUTONUMBER,ca.Name as CLIENTNAME, ca.Name as CASENUMBER,
			NULL AS CASENAME,TEP.StartDate,TEP.EndDate,CAST(CAST(SUM(ISNULL(a.Hours,0)) AS Decimal(17,2)) AS Varchar(30)) As TOATLHOURS,'00.00' AS IsOverRunHours, 
			'00000000-0000-0000-0000-000000000000' AS CASEID, MR.Small as PHOTOURL, ca.Id AS SCHEDULETYPEID,ca.Name as SUBTYPE,NULL as OppSTAGE, 'Calender' as SCHEDULETYPE,
			 2 as IsType,Null as LeaveStatus,A.TimeType,CAST(A.StartDate AS DATE) TaskDate
		FROM  Common.CalenderSchedule AS A  (NOLOCK)
			INNER JOIN Common.Calender AS CA (NOLOCK) ON CA.Id = A.CalenderId
			INNER JOIN Common.Employee AS E (NOLOCK) ON E.CompanyId = A.CompanyId AND E.CompanyId = @CompanyId
			LEFT JOIN Common.CalenderDetails AS C (NOLOCK) ON C.MasterId = A.CalenderId AND E.Id = C.EmployeeId
			LEFT JOIN Common.MediaRepository as MR (NOLOCK) ON MR.Id=E.PhotoId  
			INNER JOIN @Temp TEP ON CAST(A.StartDate AS date) >= TEP.StartDate AND CAST(A.StartDate AS date) <= TEP.EndDate
		WHERE A.CompanyId = @CompanyId AND CA.Status = 1
		GROUP BY  E.FirstName,E.Id,A.ApplyToAll,C.EmployeeId,E.Id,e.EmployeeId, ca.Name, TEP.StartDate,TEP.EndDate,MR.Small,ca.Id,ca.Name,A.TimeType,A.StartDate
	) AS A
WHERE A.EmployeeId = @EMPLOYEEID


INSERT INTO @OutPut_Tbl
-------->>> LeaveApplication
SELECT
	EMPLOYEENAME, EMPLOYEEID, EMPLOYEENUMBER,CLIENTNAME, CASENUMBER, CASENAME,  StartDate, EndDate,SUM(TOATLHOURS) AS TOATLHOURS,ISOVERRUNHOURS, 
	CASEID, PHOTOURL,SCHEDULETYPEID,SUBTYPE,OppSTAGE, SCHEDULETYPE, IsType,LeaveStatus, TimeType, TaskDate
FROM (
SELECT  
	E.FirstName as EMPLOYEENAME,E.Id AS EMPLOYEEID, e.EmployeeId AS  EMPLOYEENUMBER,LT.Name AS CLIENTNAME, LT.Name AS CASENUMBER, NULL AS CASENAME,  TEP.StartDate,TEP.EndDate,
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
					END AS Decimal(17,2)) AS TOATLHOURS,
	'00.00' AS ISOVERRUNHOURS, '00000000-0000-0000-0000-000000000000' AS CASEID, MR.Small as PHOTOURL,LA.Id AS SCHEDULETYPEID,
	LT.Name AS SUBTYPE,NULL as OppSTAGE, 'LeaveApplication' AS SCHEDULETYPE, 1 as IsType,LA.LeaveStatus, NULL AS TimeType, NULL AS TaskDate
FROM Hr.LeaveApplication AS LA 
INNER JOIN hr.LeaveType LT  on LT.Id = LA.LeaveTypeId
INNER JOIN Common.Employee AS E ON E.Id = LA.EmployeeId AND E.Id = @EMPLOYEEID
INNER JOIN dbo.DateRange_Function (@CompanyId,@Fromdate ,@ToDate) AS A ON A.DateValue >= CAST(LA.StartDateTime AS Date) AND A.DateValue <= CAST(LA.EndDateTime AS Date) 
INNER JOIN @Temp as TEP ON CAST(A.DateValue AS DATE) BETWEEN  TEP.StartDate AND TEP.EndDate
LEFT JOIN Common.MediaRepository as MR  ON MR.Id=E.PhotoId  
LEFT JOIN  (SELECT EmployeeId,TaskDate, TimeType, CAST(TOATLHOURS AS Float) as TOATLHOURS  FROM @OutPut_Tbl WHERE  SCHEDULETYPE = 'Calender' AND TimeType != 'Full') AS H ON H.EmployeeId = LA.EmployeeId  
WHERE LA.EmployeeId = @EMPLOYEEID AND LA.LeaveStatus IN ('Submitted','Recommended','Approved','For Cancellation')
) AS A
GROUP BY 	EMPLOYEENAME, EMPLOYEEID, EMPLOYEENUMBER,CLIENTNAME, CASENUMBER, CASENAME,  StartDate, EndDate,ISOVERRUNHOURS,
	CASEID, PHOTOURL,SCHEDULETYPEID,SUBTYPE,OppSTAGE, SCHEDULETYPE, IsType,LeaveStatus, TimeType, TaskDate


INSERT INTO @OutPut_Tbl
---------->>> Training Of Trainer and Attendee
SELECT EMPLOYEENAME, EMPLOYEEID, EMPLOYEENUMBER,CLIENTNAME, CASENUMBER, CASENAME, StartDate,EndDate ,SUM(TOATLHOURS) AS TOATLHOURS,ISOVERRUNHOURS,  	
	CASEID, PHOTOURL,SCHEDULETYPEID,SUBTYPE,OppSTAGE, SCHEDULETYPE,IsType,LeaveStatus,TimeType,TaskDate 
FROM (
SELECT  DISTINCT 
	A.DateValue,E.FirstName as EMPLOYEENAME, E.Id AS EMPLOYEEID, e.EmployeeId AS  EMPLOYEENUMBER,CL.CourseName AS CLIENTNAME, CL.CourseName AS CASENUMBER, null AS CASENAME, 
	TEP.StartDate,TEP.EndDate ,ISNULL(CONVERT(DECIMAL(17, 2), REPLACE(LEFT(DATEADD(SECOND, DATEDIFF(SECOND, 0, TS.FirstHalfTotalHours), TS.SecondHalfTotalHours ), 5), ':', '.')),'0.00' )As TOATLHOURS,'00.00' AS ISOVERRUNHOURS,  	
	'00000000-0000-0000-0000-000000000000' AS CASEID, MR.Small as PHOTOURL,
	TR.Id AS SCHEDULETYPEID,CL.CourseName as SUBTYPE,NULL as OppSTAGE, 'Training' AS SCHEDULETYPE,2 as IsType,Null as LeaveStatus, NULL AS TimeType,NULL AS TaskDate
FROM Hr.Training AS TR  
	INNER JOIN hr.TrainingSchedule TS  on TR.Id=TS.TrainingId
	INNER JOIN HR.CourseLibrary AS CL  ON CL.Id = TR.CourseLibraryId
	INNER JOIN dbo.DateRange_Function (@CompanyId,@Fromdate,@ToDate) AS A ON A.DateValue BETWEEN CAST(TR.StartDate AS Date) AND CAST(TR.EndDate AS Date)
	INNER JOIN @Temp as TEP ON CAST(A.DateValue AS DATE) BETWEEN  TEP.StartDate AND TEP.EndDate
	INNER JOIN 
		(
			SELECT 'Attendee'AS Type,TrainingId,EmployeeId,EmployeeTrainigStatus FROM Hr.TrainingAttendee AS TA --WHERE TrainingId = '22826FD1-50D7-45E4-8400-70666D2ACE80'
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
		)AS TA  ON TA.TrainingId = TR.Id 	AND TA.EmployeeId = @EMPLOYEEID
	INNER JOIN Common.Employee AS E  ON E.Id = TA.EmployeeId AND TR.CompanyId = @companyId AND E.Id = @EMPLOYEEID
	LEFT JOIN Common.MediaRepository as MR  ON MR.Id = E.PhotoId
	WHERE TR.CompanyId = @COMPANYID AND E.Id = @EMPLOYEEID AND TR.Status = 1 AND A.DateValue BETWEEN CAST(TR.StartDate AS Date) AND CAST(TR.EndDate AS Date) 
) AS A
GROUP BY EMPLOYEENAME, EMPLOYEEID, EMPLOYEENUMBER,CLIENTNAME, CASENUMBER, CASENAME, StartDate,EndDate ,ISOVERRUNHOURS,  	
	CASEID, PHOTOURL,SCHEDULETYPEID,SUBTYPE,OppSTAGE, SCHEDULETYPE,IsType,LeaveStatus,TimeType,TaskDate 

	if not exists (select * from @OutPut_Tbl)
	begin
	INSERT INTO @OutPut_Tbl
------->>> Employee Details for fetching data when no there is no data from the output
	SELECT 
		EMPLOYEENAME,EMPLOYEEID, EMPLOYEENUMBER, ClientName, CaseNumber,NULL AS CASENAME,B.StartDate ,B.Enddate,TOATLHOURS, ISOVERRUNHOURS,CaseId,PHOTOURL,NULL AS SCHEDULETYPEID,
		NULL AS SUBTYPE, NULL AS OppSTAGE, NULL AS SCHEDULETYPE,0 as IsType,LeaveStatus, TimeType ,  TaskDate
	FROM
		(
			SELECT 
				A.FirstName as EMPLOYEENAME,a.EmployeeId AS EMPLOYEENUMBER,NULL AS CsrSdate,NULL AS csrEdate, NULL AS TOATLHOURS, NULL AS ISOVERRUNHOURS, A.Id AS EMPLOYEEID ,
				a.EmployeeId as EMPLOYEEAUTONUMBER,mr.Small as PHOTOURL,Null as SystemId, Null as  SystemType, Null as IsType,Null as ClientName, 
				Null as CaseState, Null as CaseNumber, Null as OppState, Null as ServiceGroup, Null as ServiceCode ,  
				NULL as Likelihood ,  NULL as CaseId,NULL as TaskDate,NULL as  Task ,NULL as  ClientId, NULL as IsOverRun,NULL as LeaveStatus, NULL AS TimeType
			FROM Common.Employee AS A
			LEFT JOIN Common.MediaRepository as MR  ON MR.Id = A.PhotoId 	
			WHERE a.Id = @EMPLOYEEID
		) AS A
		CROSS JOIN @Temp AS B
		end
------>>> OutuPut
SELECT EMPLOYEENAME ,A.EMPLOYEEID ,EMPLOYEENUMBER , CLIENTNAME ,CASENUMBER ,CASENAME , STARTDATE , ENDDATE ,TOATLHOURS ,IsOverRunHours ,CASEID ,PHOTOURL ,SCHEDULETYPEID ,SUBTYPE , OppSTAGE, SCHEDULETYPE , IsType,LeaveStatus,
B.DepartmentCode,B.DesignationName,B.LevelRank,@WorkWeekHours AS WorkWeekHours
 FROM @OutPut_Tbl AS A
LEFT JOIN
(
    SELECT * 
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
			WHERE E.Id = @EMPLOYEEID
    ) AS A
    WHERE LD = 1
) AS B ON B.EmployeeId = A.EMPLOYEEID

END
GO
