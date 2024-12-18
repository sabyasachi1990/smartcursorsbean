USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[ScheduleDetailPlannedHoursPending_Procedure]    Script Date: 16-12-2024 9.20.11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

---->>> EXEC [dbo].[ScheduleDetailPlannedHoursPending_Procedure] '2023-01-01','2023-01-31', '54EB3FE5-2147-4243-BE51-B591F7596672',2050

Create   PROCEDURE [dbo].[ScheduleDetailPlannedHoursPending_Procedure]  
@FROMDATE DATE,  
@TODATE DATE,   
@EMPLOYEEID UNIQUEIDENTIFIER,  
@COMPANYID BIGINT  

AS
BEGIN

--DECLARE 
--	@FROMDATE DATE = '2022-05-30',
--	@TODATE DATE = '2022-06-30',
--	@EMPLOYEEID UNIQUEIDENTIFIER = 'E33C3D29-C93F-49F5-A6C2-9E82C36BD3F6',
--	@COMPANYID BIGINT = 2050  
  
DECLARE @OUTPUT TABLE 
	( 
		EMPLOYEENAME NVARCHAR (1000),EMPLOYEEID UNIQUEIDENTIFIER,EMPLOYEENUMBER NVARCHAR(100),CLIENTNAME NVARCHAR(1000),CASENUMBER NVARCHAR(100),
		CASENAME NVARCHAR(1000), STARTDATE DATE,ENDDATE DATE,TOATLHOURS varchar(max),IsOverRunHours varchar(max),CASEID UNIQUEIDENTIFIER,
		PHOTOURL NVARCHAR(1000),SCHEDULETYPEID UNIQUEIDENTIFIER NULL,SUBTYPE NVARCHAR(1000), OppSTAGE NVARCHAR(50), SCHEDULETYPE NVARCHAR(100), IsType bit,
		STStartDate Date
	 )  
  
Declare @Temp table (StartDate date,Enddate date)  
    
;with cte as  
(   
  select @FROMDATE StartDate, DATEADD(wk, DATEDIFF(wk, 0, @FROMDATE), 5) EndDate  
  union all   
  select dateadd(ww, 1, StartDate),dateadd(ww, 1, EndDate)  
  from cte where dateadd(ww, 1, StartDate)<=  @TODATE  
) 

INSERT INTO @Temp  
SELECT StartDate,EndDate  FROM cte  
  
DECLARE @WorkWeekHours Decimal(17,2) = (SELECT CAST(SUM(DATEDIFF(MINUTE, 0, WorkingHours)) / 60.0  AS DECIMAL(20,2)) AS TotalHours FROM Common.WorkWeekSetUp WHERE CompanyId = @CompanyId AND EmployeeId IS NULL AND IsWorkingDay!=0)

INSERT INTO @OUTPUT
SELECT  
	E.FirstName as EMPLOYEENAME,E.Id AS EMPLOYEEID,e.EmployeeId AS EMPLOYEENUMBER,  
	Cg.NAME AS CLIENTNAME ,CG.SYSTEMREFNO AS CASENUMBER, Cg.NAME AS CASENAME,T.StartDate,T.Enddate ,
	RIGHT('0' + CAST(   isnull(sum(DATEPART(SECOND, st.Hours) + 60 *  DATEPART(MINUTE, st.Hours) + 3600 * DATEPART(HOUR, st.Hours )),0) / 3600 AS VARCHAR),2) + '.' +  
	RIGHT('0' + CAST((   isnull(sum(DATEPART(SECOND, st.Hours) + 60 *  DATEPART(MINUTE, st.Hours) + 3600 * DATEPART(HOUR, st.Hours )),0) / 60) % 60 AS VARCHAR),2)As TOATLHOURS ,  
	RIGHT('0' + CAST(   isnull(sum(DATEPART(SECOND, ST.IsOverRunHours) + 60 *  DATEPART(MINUTE, ST.IsOverRunHours) + 3600 * DATEPART(HOUR, ST.IsOverRunHours )),0) / 3600 AS VARCHAR),2) + '.' +  
	RIGHT('0' + CAST(( isnull(sum(DATEPART(SECOND, ST.IsOverRunHours) + 60 *  DATEPART(MINUTE, ST.IsOverRunHours) + 3600 * DATEPART(HOUR, ST.IsOverRunHours )),0) / 60) % 60 AS VARCHAR),2)As IsOverRunHours,
	CG.ID AS CASEID,  
	MR.Small as PHOTOURL,ST.CaseId AS SCHEDULETYPEID, NULL AS SUBTYPE,o.stage as OppSTAGE,'CaseGroup' AS  SCHEDULETYPE, 0 as  IsType, CAST(ST.StartDate AS Date) AS STStartDate
FROM WorkFlow.ScheduleTask ST (Nolock)  
	INNER JOIN WorkFlow.CaseGroup CG (Nolock) on ST.CaseId = CG.Id  
	INNER JOIN ClientCursor.Opportunity o (Nolock) on o.CaseId=cg.Id  
	INNER JOIN Common.Employee E (Nolock) on ST.EmployeeId = E.Id    
	INNER JOIN @Temp AS T ON CAST(ST.StartDate AS Date) BETWEEN T.StartDate AND T.Enddate
	LEFT JOIN Common.MediaRepository as MR (Nolock) ON MR.Id=E.PhotoId  
WHERE st.Status=1  AND st.CompanyId = @CompanyId and ST.EmployeeId = @EmployeeId AND o.Stage='Pending'  
	AND CAST(ST.StartDate AS Date) BETWEEN @FROMDATE AND @TODATE
GROUP BY E.FirstName,ST.StartDate,o.stage,ST.Enddate,E.Id,e.EmployeeId, ST.CaseId, ST.SystemType,MR.Small, CG.ID,Cg.NAME,CG.SYSTEMREFNO,
	T.StartDate,T.Enddate,CAST(ST.StartDate AS Date)


------>>>> OutPut 
SELECT EMPLOYEENAME,a.EMPLOYEEID, EMPLOYEENUMBER, CLIENTNAME ,CASENUMBER,CASENAME , STARTDATE,ENDDATE,TOATLHOURS,IsOverRunHours,CASEID,
	PHOTOURL ,SCHEDULETYPEID,SUBTYPE , OppSTAGE, SCHEDULETYPE, IsType, B.DepartmentCode,B.DesignationName,B.LevelRank,@WorkWeekHours AS WorkWeekHours 
FROM @OUTPUT AS A
LEFT JOIN
(
    SELECT CompanyId,A.EmployeeId,A.DepartmentId, DepartmentCode, DepartmentDesignationId, DesignationName,LevelRank,  EffectiveFrom,
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
			WHERE E.Id = @EMPLOYEEID
    ) AS A
) AS B ON B.EmployeeId = A.EMPLOYEEID
WHERE CAST(STStartDate AS Date) BETWEEN b.EffectiveFrom AND b.EffectiveTo

END
GO
