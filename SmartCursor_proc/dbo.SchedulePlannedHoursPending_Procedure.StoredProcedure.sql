USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[SchedulePlannedHoursPending_Procedure]    Script Date: 16-12-2024 9.20.11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE   PROCEDURE [dbo].[SchedulePlannedHoursPending_Procedure]
@Fromdate date,
 @ToDate date,
 @DesignationId uniqueidentifier,
 @DepartmentId uniqueidentifier,
 @EmployeeId  uniqueidentifier, 
 @CompanyId int
 
 AS
 BEGIN

DECLARE @WorkWeekHours Decimal(17,2) = (SELECT CAST(SUM(DATEDIFF(MINUTE, 0, WorkingHours)) / 60.0  AS DECIMAL(20,2)) AS TotalHours FROM Common.WorkWeekSetUp WHERE CompanyId = @CompanyId AND EmployeeId IS NULL AND IsWorkingDay!=0)

DECLARE @OUTPUT TABLE 
( 
	EMPLOYEENAME NVARCHAR (1000),STARTDATE DATE, ENDDATE DATE,TOATLHOURS varchar(max),ISOVERRUNHOURS varchar(max),
	EMPLOYEEID UNIQUEIDENTIFIER,EMPLOYEEAUTONUMBER NVARCHAR(100),PHOTOURL NVARCHAR(1000),SystemId UNIQUEIDENTIFIER NULL,SystemType NVARCHAR(50), IsType int,STStartDate Date		  
)

  DECLARE @Temp TABLE (StartDate date,Enddate date)


;WITH CTE AS
  (
    SELECT @FROMDATE StartDate, DATEADD(wk, DATEDIFF(wk, 0, @FROMDATE), 5) EndDate
    UNION ALL
    SELECT dateadd(ww, 1, StartDate),dateadd(ww, 1, EndDate)
    FROM cte WHERE dateadd(ww, 1, StartDate)<=  @TODATE
  )

  INSERT INTO @Temp
  SELECT StartDate,EndDate
  FROM cte

 ---SELECT * FROM @Temp
INSERT INTO @OUTPUT
SELECT EMPLOYEENAME,B.StartDate AS CsrSdate,B.Enddate AS csrEdate,TOATLHOURS,ISOVERRUNHOURS,EMPLOYEEID,EMPLOYEEAUTONUMBER,
PHOTOURL, SystemId,SystemType,IsType,STStartDate
FROM
(
	SELECT A.FirstName AS EMPLOYEENAME,NULL AS Title,NULL AS CsrSdate,NULL AS csrEdate,NULL AS TOATLHOURS,
	NULL AS ISOVERRUNHOURS,A.Id AS EMPLOYEEID,A.EmployeeId AS EMPLOYEEAUTONUMBER,MR.Small as PHOTOURL,NULL AS SystemId,NULL AS SystemType,NULL AS IsType,NULL AS STStartDate 
	FROM Common.Employee AS A
	LEFT JOIN Common.MediaRepository as MR  ON MR.Id=A.PhotoId	
	WHERE A.Id=@EmployeeId
)AS A
CROSS JOIN @Temp AS B

INSERT INTO @OUTPUT
SELECT
  EMPLOYEENAME,CsrSdate,csrEdate,CAST(CAST(SUM(TOATLHOURS) / 60.0 AS DECIMAL(28, 2)) AS VARCHAR) AS TOATLHOURS,
  CAST(CAST(SUM(ISOVERRUNHOURS) / 60.0 AS DECIMAL(28, 2)) AS VARCHAR) AS ISOVERRUNHOURS,
  EMPLOYEEID, EMPLOYEEAUTONUMBER, PHOTOURL, SystemId, SystemType,IsType,STStartDate
FROM(
		SELECT 
			E.FirstName as EMPLOYEENAME,st.Title,T.StartDate as CsrSdate,T.Enddate as csrEdate,((DATEPART(HOUR,st.Hours)*60)+((DATEPART(MINUTE,st.Hours))))As TOATLHOURS ,
			((DATEPART(HOUR,st.IsOverRunHours)*60)+((DATEPART(MINUTE,st.IsOverRunHours))))As  ISOVERRUNHOURS,E.Id AS EMPLOYEEID,
			e.EmployeeId AS EMPLOYEEAUTONUMBER,MR.Small as PHOTOURL,ST.CaseId AS SystemId, 'CaseGroup'AS SystemType, 0 as  IsType, CAST(ST.StartDate AS Date) as STStartDate 
		FROM WorkFlow.ScheduleTask ST 
				INNER JOIN WorkFlow.CaseGroup CG  ON ST.CaseId = CG.Id
				INNER JOIN ClientCursor.Opportunity o  ON o.Id=cg.OpportunityId
				INNER JOIN Common.Employee E  ON ST.EmployeeId = E.Id  
				INNER JOIN [HR].[EmployeeDepartment] as HR  ON HR.EmployeeId = E.Id
				INNER JOIN @TEMP AS T ON ST.StartDate BETWEEN T.StartDate AND T.Enddate 
				INNER JOIN dbo.DateRange_Function (@CompanyId,@Fromdate ,@ToDate) AS F ON F.DateValue BETWEEN CAST(EffectiveFrom as date) AND CAST(CASE WHEN EffectiveTo IS NULL THEN dateadd(d,-1,Convert(date,Convert(varchar(100),Year(GETDATE())+2)+'-'+'01'+'-'+'01'))  ELSE EffectiveTo END AS date) 
				LEFT JOIN Common.MediaRepository as MR  ON MR.Id=E.PhotoId		
		WHERE  st.Status=1 AND st.CompanyId = @CompanyId AND  o.Stage='Pending' 
			AND @EmployeeId IS NULL AND @DepartmentId IS NULL AND @DesignationId IS NULL
		GROUP BY  E.FirstName,st.Title,ST.StartDate,ST.Enddate,E.Id,e.EmployeeId, ST.CaseId, ST.SystemType,MR.Small ,st.Hours ,st.IsOverRunHours,T.StartDate ,T.Enddate, CAST(ST.StartDate AS Date)
  )kk
GROUP BY EMPLOYEENAME,CsrSdate,csrEdate,EMPLOYEEID,EMPLOYEEAUTONUMBER,PHOTOURL,SystemId,SystemType,IsType,STStartDate

INSERT INTO @OUTPUT
SELECT
  EMPLOYEENAME,CsrSdate,csrEdate,CAST(CAST(SUM(TOATLHOURS) / 60.0 AS DECIMAL(28, 2)) AS VARCHAR) AS TOATLHOURS,
  CAST(CAST(SUM(ISOVERRUNHOURS) / 60.0 AS DECIMAL(28, 2)) AS VARCHAR) AS ISOVERRUNHOURS,
  EMPLOYEEID, EMPLOYEEAUTONUMBER, PHOTOURL, SystemId, SystemType,IsType,STStartDate
FROM(
		SELECT 
			E.FirstName as EMPLOYEENAME,st.Title,T.StartDate as CsrSdate,T.Enddate as csrEdate,((DATEPART(HOUR,st.Hours)*60)+((DATEPART(MINUTE,st.Hours))))As TOATLHOURS ,
			((DATEPART(HOUR,st.IsOverRunHours)*60)+((DATEPART(MINUTE,st.IsOverRunHours))))As  ISOVERRUNHOURS,E.Id AS EMPLOYEEID,
			e.EmployeeId AS EMPLOYEEAUTONUMBER,MR.Small as PHOTOURL,ST.CaseId AS SystemId, 'CaseGroup'AS SystemType, 0 as  IsType, CAST(ST.StartDate AS Date) as STStartDate
		FROM WorkFlow.ScheduleTask ST 
				INNER JOIN WorkFlow.CaseGroup CG  ON ST.CaseId = CG.Id
				INNER JOIN ClientCursor.Opportunity o  ON o.Id=cg.OpportunityId
				INNER JOIN Common.Employee E  ON ST.EmployeeId = E.Id  
				INNER JOIN [HR].[EmployeeDepartment] as HR  ON HR.EmployeeId = E.Id
				INNER JOIN @TEMP AS T ON CAST(ST.StartDate AS Date) BETWEEN T.StartDate AND T.Enddate 
				INNER JOIN dbo.DateRange_Function (@CompanyId,@Fromdate ,@ToDate) AS F ON F.DateValue BETWEEN CAST(EffectiveFrom as date) AND CAST(CASE WHEN EffectiveTo IS NULL THEN dateadd(d,-1,Convert(date,Convert(varchar(100),Year(GETDATE())+2)+'-'+'01'+'-'+'01'))  ELSE EffectiveTo END AS date) 
				LEFT JOIN Common.MediaRepository as MR  ON MR.Id=E.PhotoId		
		WHERE  st.Status=1 AND st.CompanyId = @CompanyId AND  o.Stage='Pending' AND ST.EmployeeId  = @EmployeeId
			AND ( @EmployeeId IS NOT NULL OR @DepartmentId IS NOT NULL AND @DesignationId IS NOT NULL)
		GROUP BY  E.FirstName,st.Title,ST.StartDate,ST.Enddate,E.Id,e.EmployeeId, ST.CaseId, ST.SystemType,MR.Small ,st.Hours ,st.IsOverRunHours,T.StartDate ,T.Enddate,CAST(ST.StartDate AS Date)
  )kk
GROUP BY EMPLOYEENAME,CsrSdate,csrEdate,EMPLOYEEID,EMPLOYEEAUTONUMBER,PHOTOURL,SystemId,SystemType,IsType,STStartDate


------------>>>> OutPut
SELECT EMPLOYEENAME,STARTDATE, ENDDATE,TOATLHOURS ,ISOVERRUNHOURS,a.EMPLOYEEID,EMPLOYEEAUTONUMBER,PHOTOURL,SystemId,SystemType, IsType,
	b.DepartmentCode,b.DesignationName,b.LevelRank, @WorkWeekHours as WorkWeekHours 
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
	WHERE LD = 1
) AS B ON B.EmployeeId = A.EMPLOYEEID
--WHERE CAST(STStartDate AS Date) BETWEEN b.EffectiveFrom AND b.EffectiveTo

END
GO
