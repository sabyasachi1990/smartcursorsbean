USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[TimeLogAHDetail_Procedure]    Script Date: 16-12-2024 9.20.11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE     Procedure [dbo].[TimeLogAHDetail_Procedure] 
@FROMDATE DATE ,   
@TODATE DATE ,  
@EMPLOYEEID  UNIQUEIDENTIFIER ,  
@COMPANYID INT   
  
 AS  
 BEGIN  
 
 --DECLARE 
 --@Fromdate date = '2023-01-01',  
 --@ToDate date = '2023-01-31',  
 --@EmployeeId  uniqueIdentifier ='54EB3FE5-2147-4243-BE51-B591F7596672',
 --@CompanyId int = 2050

DECLARE @OUTPUT TABLE 
( 
	EMPLOYEENAME NVARCHAR (1000),EMPLOYEEID UNIQUEIDENTIFIER,EMPLOYEENUMBER NVARCHAR(100),  CLIENTNAME NVARCHAR(1000),CASENUMBER NVARCHAR(100),
	CASENAME NVARCHAR(1000), STARTDATE DATE,  ENDDATE DATE,TOATLHOURS varchar(max),IsOverRunHours varchar(max),CASEID UNIQUEIDENTIFIER,PHOTOURL NVARCHAR(1000),  
	SCHEDULETYPEID UNIQUEIDENTIFIER NULL ,SUBTYPE NVARCHAR(1000), OppSTAGE NVARCHAR(50) ,SCHEDULETYPE NVARCHAR(100), IsType bit,  LeaveStatus NVARCHAR(100)
)  

CREATE TABLE #Temp (StartDate date,Enddate date)

;WITH CTE AS  
	(  
		SELECT @FROMDATE StartDate, DATEADD(wk, DATEDIFF(wk, 0, @FROMDATE), 5) EndDate  
		UNION ALL
		SELECT dateadd(ww, 1, StartDate),dateadd(ww, 1, EndDate)  
		FROM cte WHERE dateadd(ww, 1, StartDate)<=  @TODATE  
	) 
	
INSERT INTO #Temp  
SELECT StartDate,EndDate  FROM cte  



	


DECLARE @MinDate Date,@MaxDate date  
SELECT @MinDate = MIN(StartDate), @MaxDate = MAX(Enddate) FROM #Temp 

------>>>> CaseGroup TimeLog Hours & Time Log Item TimeLog Hours
SELECT * INTO #CaseGroupTimeLogItemTimeLogHours 
FROM (
SELECT TLI.Id,E.FirstName as EMPLOYEENAME,TEP.StartDate,TEP.EndDate, tld.Date, tld.Duration,t.Status AS TimeLogStatus, TLI.Status as TimeLogItemStatus,TLI.ApplyToAll,
'00.00' AS IsOverRunHours,E.Id AS EMPLOYEEID,e.EmployeeId AS EMPLOYEEAUTONUMBER,MR.Small as PHOTOURL,TLI.Id AS SystemId,TLI.SystemType,TLI.SystemId AS CaseGroupId,TLD.DesignationId,
CASE WHEN SystemType = 'CaseGroup' THEN 0 WHEN SystemType = 'Time Log Item' THEN 4 END AS IsType, TLI.SubType AS SUBTYPE, TLI.SystemType AS  SCHEDULETYPE,
TLI.SubType AS CLIENTNAME,TLI.Type
FROM Common.TimeLog AS T
	INNER JOIN Common.TimeLogDetail TLD (NOLOCK) ON T.Id = TLD.MasterId
	INNER JOIN Common.TimeLogItem TLI (NOLOCK) ON TLI.Id = T.TimeLogItemId 
	INNER JOIN Common.Employee E (NOLOCK) on T.EmployeeId = E.Id
	INNER JOIN #Temp TEP ON CAST(tld.Date AS date) >= TEP.StartDate AND CAST(tld.Date AS date) <= TEP.EndDate  
	LEFT JOIN Common.MediaRepository as MR (NOLOCK) ON MR.Id = E.PhotoId
WHERE TLI.CompanyId = @CompanyId AND E.Id = @EmployeeId
	AND tld.Duration <> '00:00:00.0000000' AND cast(tld.Date AS date) >= TEP.StartDate And cast(tld.Date AS date)<= TEP.EndDate
) AS A

------>>>> Leaves & Trainings
SELECT * INTO #LeavesAndTrainingHours 
FROM (
	SELECT  
		E.FirstName as EMPLOYEENAME,E.Id AS EMPLOYEEID, e.EmployeeId AS  EMPLOYEEAUTONUMBER, TLI.SubType,TEP.StartDate,TEP.EndDate, CAST(SUM(distinct TLI.Hours) AS VARCHAR(max)) As LeaveHours,
		ISNULL(CAST(SUM(distinct TLI.ActualHours) AS VARCHAR(max)),'0.00') As TrainingHours,'00.00' AS IsOverRunHours, 
		MR.Small as PHOTOURL,TLI.SystemId AS SystemId, TLI.SystemType,  TLI.SystemSubTypeStatus,
		CASE WHEN SystemType = 'LeaveApplication' THEN 1 WHEN SystemType = 'Training' THEN 5 END AS IsType
	FROM  Common.TimeLogItem TLI (NOLOCK)  
		INNER JOIN Common.TimeLogItemDetail TLD (NOLOCK) on TLD.TimelogitemId=TLI.Id  
		INNER JOIN Common.Employee E (NOLOCK) on E.Id = TLD.EmployeeId   
		LEFT JOIN Common.MediaRepository as MR (NOLOCK) ON MR.Id=E.PhotoId  
		INNER JOIN #Temp TEP ON cast(TLI.StartDate AS date) >= TEP.StartDate And cast(TLI.EndDate AS date) <=TEP.EndDate  
	WHERE TLI.CompanyId = @CompanyId AND TLI.IsSystem = 1    
		AND E.Id = @EmployeeId
		AND CAST(TLI.StartDate AS DATE) >= TEP.StartDate And CAST(TLI.EndDate AS DATE) <= TEP.EndDate AND TLI.Status=1  
	GROUP BY E.FirstName,TLI.StartDate,TLI.Enddate,E.Id,e.EmployeeId, TLI.SystemId, TLI.SystemType,MR.Small   ,TEP.StartDate,TEP.EndDate, SystemSubTypeStatus,TLI.SubType 
	) AS B

INSERT INTO @OUTPUT
------>>>> CaseGroup TimeLog Hours 
SELECT 
	EMPLOYEENAME,EMPLOYEEID, EMPLOYEEAUTONUMBER,CLIENTNAME ,CG.SYSTEMREFNO AS CASENUMBER, Cg.NAME AS CASENAME,StartDate,EndDate,
	RIGHT('0' + CAST(   isnull(sum(DATEPART(SECOND, A.Duration) + 60 *  DATEPART(MINUTE, A.Duration) + 3600 * DATEPART(HOUR, A.Duration )),0) / 3600 AS VARCHAR),2) + '.' +  
	RIGHT('0' + CAST((   isnull(sum(DATEPART(SECOND, A.Duration) + 60 *  DATEPART(MINUTE, A.Duration) + 3600 * DATEPART(HOUR, A.Duration )),0) / 60) % 60 AS VARCHAR),2)As TOTALHOURS,
	IsOverRunHours, CG.Id as CASEID, PHOTOURL, CG.id AS SCHEDULETYPEID,SUBTYPE, o.stage as OppSTAGE,SCHEDULETYPE,IsType,Null as LeaveStatus  
FROM #CaseGroupTimeLogItemTimeLogHours AS A
	LEFT JOIN WorkFlow.CaseGroup CG (NOLOCK) on A.CaseGroupId = CG.Id
	LEFT JOIN  ClientCursor.Opportunity o (NOLOCK) on o.CaseId = cg.Id 
WHERE TimeLogStatus = 1 AND SystemType = 'CaseGroup'
GROUP BY EMPLOYEENAME,StartDate,EndDate,IsOverRunHours, EMPLOYEEID, EMPLOYEEAUTONUMBER, PHOTOURL, SystemId, SystemType ,IsType, CG.Id,A.Date,
CLIENTNAME, CG.SYSTEMREFNO, Cg.NAME,CG.Id,o.stage, SUBTYPE, SCHEDULETYPE

UNION ALL
------>>>> Time Log Item TimeLog Hours
SELECT 
	EMPLOYEENAME,EMPLOYEEID, EMPLOYEEAUTONUMBER,A.Type AS CLIENTNAME ,A.Type AS CASENUMBER,  NULL AS  CASENAME,StartDate,EndDate,
	RIGHT('0' + CAST(   isnull(sum(DATEPART(SECOND, A.Duration) + 60 *  DATEPART(MINUTE, A.Duration) + 3600 * DATEPART(HOUR, A.Duration )),0) / 3600 AS VARCHAR),2) + '.' +  
	RIGHT('0' + CAST((   isnull(sum(DATEPART(SECOND, A.Duration) + 60 *  DATEPART(MINUTE, A.Duration) + 3600 * DATEPART(HOUR, A.Duration )),0) / 60) % 60 AS VARCHAR),2)As TOTALHOURS,
	IsOverRunHours, '00000000-0000-0000-0000-000000000000'  as CASEID, PHOTOURL, A.Id AS SCHEDULETYPEID,SUBTYPE, NULL as OppSTAGE,SystemType AS SCHEDULETYPE,IsType,Null as LeaveStatus  
FROM #CaseGroupTimeLogItemTimeLogHours AS A
WHERE TimeLogItemStatus = 1 AND SystemType = 'Time Log Item'  AND ApplyToAll IS NULL
GROUP BY EMPLOYEENAME,StartDate,EndDate,IsOverRunHours, EMPLOYEEID, EMPLOYEEAUTONUMBER, PHOTOURL, SystemId, SystemType ,IsType,A.Date,A.Type,A.Id,SUBTYPE
  
UNION ALL
-------->>>> Calendar
SELECT EMPLOYEENAME, EmployeeId, EMPLOYEEAUTONUMBER, Name AS CLIENTNAME,Name AS CASENUMBER, NULL AS CASENAME,StartDate, EndDate, 
TOATLHOURS, IsOverRunHours, '00000000-0000-0000-0000-000000000000' AS CASEID, PHOTOURL,CalendarId AS SCHEDULETYPEID, Name AS SUBTYPE,NULL as OppSTAGE,
SystemType AS SCHEDULETYPE,2 as IsType,Null as LeaveStatus 
FROM (
		SELECT DISTINCT 
			E.FirstName as EMPLOYEENAME,TEP.StartDate,Tep.EndDate,CAST(CAST(SUM(ISNULL(a.Hours,0))AS Decimal(17,2)) AS Nvarchar(30)) As TOATLHOURS,'00.00' AS IsOverRunHours,
			CASE WHEN A.ApplyToAll = 1 THEN E.Id ELSE C.EmployeeId END AS EmployeeId, e.EmployeeId AS  EMPLOYEEAUTONUMBER,MR.Small as PHOTOURL,'Calender' as SystemType,
			CASE WHEN A.ApplyToAll = 1 THEN 3 ELSE 2 END IsType,CA.Id as SystemId, NULL AS CASEID ,CA.Name,CA.Id AS CalendarId 
		FROM  Common.CalenderSchedule AS A  (NOLOCK)
			INNER JOIN Common.Calender AS CA (NOLOCK) ON CA.Id = A.CalenderId
			INNER JOIN Common.Employee AS E (NOLOCK) ON E.CompanyId = A.CompanyId AND E.CompanyId = @CompanyId
			LEFT JOIN Common.CalenderDetails AS C (NOLOCK) ON C.MasterId = A.CalenderId AND E.Id = C.EmployeeId
			LEFT JOIN Common.MediaRepository as MR (NOLOCK) ON MR.Id=E.PhotoId  
			INNER JOIN #Temp TEP ON CAST(A.StartDate AS date) >= TEP.StartDate AND CAST(A.StartDate AS date) <= TEP.EndDate  
		WHERE A.CompanyId = @CompanyId AND CA.Status = 1 AND  CAST(A.StartDate AS date) >= TEP.StartDate AND CAST(A.StartDate AS date) <= TEP.EndDate
		AND ( E.Id = @EmployeeId OR C.EmployeeId =  @EmployeeId)
		GROUP BY  E.FirstName,E.Id,A.ApplyToAll,C.EmployeeId,E.Id,e.EmployeeId, ca.Name, MR.Small,ca.Id,TEP.StartDate,Tep.EndDate,CA.Name,CA.Id
	) AS A
WHERE EmployeeId = @EmployeeId

UNION ALL
------>>>> Leaves

SELECT 
	EMPLOYEENAME, EMPLOYEEID, EMPLOYEEAUTONUMBER, SubType AS  CLIENTNAME, SubType AS CASENUMBER, NULL AS CASENAME , StartDate, EndDate, 
	LeaveHours AS TOTALHOURS, IsOverRunHours, '00000000-0000-0000-0000-000000000000' AS CASEID, PHOTOURL, 
	SystemId AS SCHEDULETYPEID, SubType AS SUBTYPE,NULL as OppSTAGE, SystemType AS SCHEDULETYPE, IsType, SystemSubTypeStatus
FROM #LeavesAndTrainingHours
WHERE SystemType='LeaveApplication' AND SystemSubTypeStatus in ('Approved','For Cancellation') 

UNION ALL
-------->>>> Trainings
SELECT 
	EMPLOYEENAME, EMPLOYEEID, EMPLOYEEAUTONUMBER,  SubType AS  CLIENTNAME, SubType AS CASENUMBER, Null AS CASENAME, StartDate, EndDate, 
	TrainingHours AS TOTALHOURS, IsOverRunHours, '00000000-0000-0000-0000-000000000000' AS CASEID, PHOTOURL, 
	SystemId AS SCHEDULETYPEID, SubType AS SUBTYPE,NULL as OppSTAGE, SystemType AS SCHEDULETYPE, IsType, Null as LeaveStatus  
FROM #LeavesAndTrainingHours
WHERE SystemType='Training' 

if not exists (select * from @OUTPUT)
begin
INSERT INTO @OUTPUT
------->>> Employee Details for fetching data when no there is no data from the output
	SELECT 
		EMPLOYEENAME,EMPLOYEEID, EMPLOYEENUMBER, ClientName, CaseNumber,NULL AS CASENAME,B.StartDate ,B.Enddate,TOATLHOURS, ISOVERRUNHOURS,CaseId,PHOTOURL,NULL AS SCHEDULETYPEID,
		NULL AS SUBTYPE, NULL AS OppSTAGE, NULL AS SCHEDULETYPE,0 as IsType,LeaveStatus
	FROM
		(
			SELECT 
				A.FirstName as EMPLOYEENAME,a.EmployeeId AS EMPLOYEENUMBER,NULL AS CsrSdate,NULL AS csrEdate, NULL AS TOATLHOURS, NULL AS ISOVERRUNHOURS, A.Id AS EMPLOYEEID ,
				a.EmployeeId as EMPLOYEEAUTONUMBER,mr.Small as PHOTOURL,Null as SystemId, Null as  SystemType, Null as IsType,Null as ClientName, 
				Null as CaseState, Null as CaseNumber, Null as OppState, Null as ServiceGroup, Null as ServiceCode ,  
				NULL as Likelihood ,  NULL as CaseId,NULL as  Task ,NULL as  ClientId, NULL as IsOverRun,NULL as LeaveStatus
			FROM Common.Employee AS A
			LEFT JOIN Common.MediaRepository as MR  ON MR.Id = A.PhotoId 	
			WHERE a.Id = @EMPLOYEEID
		) AS A
		CROSS JOIN #Temp AS B
		End
---------->>>> OutPut
DECLARE @WorkWeekHours Decimal(17,2) = (SELECT CAST(SUM(DATEDIFF(MINUTE, 0, WorkingHours)) / 60.0  AS DECIMAL(20,2)) AS TotalHours FROM Common.WorkWeekSetUp WHERE CompanyId = @CompanyId AND EmployeeId IS NULL AND IsWorkingDay!=0)

SELECT EMPLOYEENAME ,A.EMPLOYEEID ,EMPLOYEENUMBER , CLIENTNAME ,CASENUMBER ,CASENAME , STARTDATE , ENDDATE ,TOATLHOURS ,IsOverRunHours ,CASEID ,PHOTOURL ,
SCHEDULETYPEID,SUBTYPE , OppSTAGE , SCHEDULETYPE , IsType, LeaveStatus, B.DepartmentCode, B.DesignationName,B.LevelRank, @WorkWeekHours AS WorkWeekHours 
FROM @OUTPUT AS A 
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
			WHERE E.Id = @EmployeeId
    ) AS A
    WHERE LD = 1
) AS B ON B.EmployeeId = A.EmployeeId


DROP TABLE #Temp
DROP TABLE #CaseGroupTimeLogItemTimeLogHours
DROP TABLE #LeavesAndTrainingHours

END
GO
