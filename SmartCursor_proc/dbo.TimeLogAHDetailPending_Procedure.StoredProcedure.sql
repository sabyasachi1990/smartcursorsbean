USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[TimeLogAHDetailPending_Procedure]    Script Date: 16-12-2024 9.20.11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
 
--->> EXEC [dbo].[TimeLogAHDetailPending_Procedure] '2023-01-01', '2023-01-31', '54EB3FE5-2147-4243-BE51-B591F7596672', 2050 

Create     PROCEDURE [dbo].[TimeLogAHDetailPending_Procedure]  
 @FROMDATE DATE,   
 @TODATE DATE,  
 @EMPLOYEEID  UNIQUEIDENTIFIER,  
 @COMPANYID INT  
   
 AS  
 BEGIN   
 
--DECLARE 
-- @Fromdate date = '2023-01-01',  
-- @ToDate date = '2023-01-31',  
-- @EmployeeId  uniqueIdentifier ='54EB3FE5-2147-4243-BE51-B591F7596672',
-- @CompanyId int = 2050

     
DECLARE @OUTPUT TABLE
(
	EMPLOYEENAME NVARCHAR (1000),EMPLOYEEID UNIQUEIDENTIFIER,EMPLOYEENUMBER NVARCHAR(100), CLIENTNAME NVARCHAR(1000),CASENUMBER NVARCHAR(100),CASENAME NVARCHAR(1000), STARTDATE DATE,  
	ENDDATE DATE,TOATLHOURS varchar(max),IsOverRunHours varchar(max),CASEID UNIQUEIDENTIFIER,PHOTOURL NVARCHAR(1000),SCHEDULETYPEID UNIQUEIDENTIFIER NULL,SUBTYPE NVARCHAR(1000), 
	OppSTAGE NVARCHAR(50) ,SCHEDULETYPE NVARCHAR(100), IsType bit
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

INSERT INTO @OUTPUT
 SELECT DISTINCT EMPLOYEENAME,EMPLOYEEID,EMPLOYEEAUTONUMBER,CLIENTNAME,CASENUMBER,CASENAME,SDate as StartDate,EDate as Enddate,  
 TOATLHOURS As TOTALHOURS,'00.00' AS IsOverRunHours, CASEID,PHOTOURL,SCHEDULETYPEID,NUll AS SUBTYPE,OppSTAGE,SCHEDULETYPE, 0 as IsType   
 FROM  
 (  
	SELECT 
		E.FirstName as EMPLOYEENAME,E.Id AS EMPLOYEEID,e.EmployeeId AS EMPLOYEEAUTONUMBER,  
		Cg.NAME AS CLIENTNAME ,CG.SYSTEMREFNO AS CASENUMBER, Cg.NAME AS CASENAME,T.StartDate as STARTDATE,T.Enddate AS ENDDATE,  
		RIGHT('0' + CAST(   isnull(sum(DATEPART(SECOND, tld.Duration) + 60 *  DATEPART(MINUTE, tld.Duration) + 3600 * DATEPART(HOUR, tld.Duration )),0) / 3600 AS VARCHAR),2) + '.' +  
		RIGHT('0' + CAST((   isnull(sum(DATEPART(SECOND, tld.Duration) + 60 *  DATEPART(MINUTE, tld.Duration) + 3600 * DATEPART(HOUR, tld.Duration )),0) / 60) % 60 AS VARCHAR),2) As TOATLHOURS,CG.ID AS CASEID,MR.Small as PHOTOURL,  
		CG.id AS SCHEDULETYPEID,o.stage as OppSTAGE,'CaseGroup' AS  SCHEDULETYPE,TEP.StartDate AS SDate, TEP.Enddate as EDate
	FROM Common.TimeLog T (NOLOCK) 
		INNER JOIN Common.TimeLogDetail TLD (NOLOCK) ON T.Id=TLD.MasterId  
		INNER JOIN Common.TimeLogItem TLI (NOLOCK) ON TLI.Id=T.TimeLogItemId  
		LEFT JOIN WorkFlow.CaseGroup CG (NOLOCK) on TLI.SystemId = CG.Id  
		LEFT JOIN ClientCursor.Opportunity o (NOLOCK) on o.CaseId = cg.Id  
		INNER JOIN Common.Employee E (NOLOCK) on T.EmployeeId = E.Id    
		INNER JOIN [HR].[EmployeeDepartment] as HR (NOLOCK) on HR.EmployeeId = E.Id  
		INNER JOIN #Temp AS TEP ON CAST(T.Startdate AS Date) BETWEEN TEP.StartDate AND TEP.Enddate
		LEFT JOIN Common.MediaRepository as MR (NOLOCK) ON MR.Id=E.PhotoId  
	  WHERE T.CompanyId = @CompanyId AND T.EmployeeId = @EmployeeId AND t.Status=1 And o.Stage='Pending'
	   AND CAST(T.Startdate AS Date) >= TEP.StartDate And CAST(T.Enddate AS Date) <= TEP.Enddate
	   AND ((TEP.StartDate BETWEEN cast(EffectiveFrom as date) and cast(case when EffectiveTo is null  
			then dateadd(d,-1,Convert(date,Convert(varchar(100),Year(GETDATE())+2)+'-'+'01'+'-'+'01'))   
			else EffectiveTo end  as Date)) or (TEP.Enddate BETWEEN cast(EffectiveFrom as date) and   
		   cast(case when EffectiveTo is null then dateadd(d,-1,Convert(date,Convert(varchar(100),  
		   Year(GETDATE())+2)+'-'+'01'+'-'+'01')) else EffectiveTo end  as Date)))   
	  GROUP BY E.FirstName,T.StartDate,T.Enddate,E.Id,e.EmployeeId,TLI.SystemId, TLI.SystemType,MR.Small,Cg.NAME,CG.Id,cg.ClientId,CG.SYSTEMREFNO,o.stage,
	  TEP.StartDate, TEP.Enddate
)AS AA  

---------->>>> OutPut
DECLARE @WorkWeekHours Decimal(17,2) = (SELECT CAST(SUM(DATEDIFF(MINUTE, 0, WorkingHours)) / 60.0  AS DECIMAL(20,2)) AS TotalHours FROM Common.WorkWeekSetUp WHERE CompanyId = @CompanyId AND EmployeeId IS NULL AND IsWorkingDay!=0)

SELECT 
	EMPLOYEENAME ,A.EMPLOYEEID ,EMPLOYEENUMBER , CLIENTNAME ,CASENUMBER ,CASENAME , STARTDATE , ENDDATE ,TOATLHOURS ,IsOverRunHours ,CASEID ,PHOTOURL ,SCHEDULETYPEID,
	SUBTYPE , OppSTAGE , SCHEDULETYPE , IsType, B.DepartmentCode, B.DesignationName,B.LevelRank, @WorkWeekHours AS WorkWeekHours    
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

END
GO
