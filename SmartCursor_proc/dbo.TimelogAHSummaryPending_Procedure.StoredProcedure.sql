USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[TimelogAHSummaryPending_Procedure]    Script Date: 16-12-2024 9.20.11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

--->> EXEC [dbo].[TimelogAHSummaryPending_Procedure] '2019-01-06','2019-01-12',null,null,null,1

CREATE        PROCEDURE [dbo].[TimelogAHSummaryPending_Procedure]
 @Fromdate date, 
 @ToDate date,
 @DepartmentId uniqueidentifier,
 @DesignationId uniqueidentifier,
 @EmployeeId  uniqueidentifier, 
 @CompanyId int

AS
BEGIN

DECLARE @OUTPUT TABLE
( 
	EMPLOYEENAME NVARCHAR (1000),STARTDATE DATE,ENDDATE DATE,TOTALHOURS varchar(max),ISOVERRUNHOURS varchar(max),
	EMPLOYEEID UNIQUEIDENTIFIER,EMPLOYEEAUTONUMBER NVARCHAR(100),PHOTOURL NVARCHAR(1000),SystemId UNIQUEIDENTIFIER NULL,
	SystemType NVARCHAR(50), IsType int
)


Declare @Temp table (StartDate date,Enddate date)


;with cte as
  (
    select @FROMDATE StartDate, DATEADD(wk, DATEDIFF(wk, 0, @FROMDATE), 5) EndDate
    union all
    select dateadd(ww, 1, StartDate),dateadd(ww, 1, EndDate)
    from cte where dateadd(ww, 1, StartDate)<=  @TODATE
  )

Insert Into @Temp
select StartDate,EndDate from cte

Insert Into @OUTPUT
--======================================  Pending STEP 1  ====================================
SELECT 
	E.FirstName as EMPLOYEENAME,A.StartDate,A.Enddate,
	RIGHT('0' + CAST(   isnull(sum(DATEPART(SECOND, tld.Duration) + 60 *  DATEPART(MINUTE, tld.Duration) + 3600 * DATEPART(HOUR, tld.Duration )),0) / 3600 AS VARCHAR),2) + '.' +
	RIGHT('0' + CAST((   isnull(sum(DATEPART(SECOND, tld.Duration) + 60 *  DATEPART(MINUTE, tld.Duration) + 3600 * DATEPART(HOUR, tld.Duration )),0) / 60) % 60 AS VARCHAR),2) As TOTALHOURS,'00.00' AS IsOverRunHours,E.Id AS EMPLOYEEID,
	e.EmployeeId AS EMPLOYEEAUTONUMBER,MR.Small as PHOTOURL,TLI.SystemId,TLI.SystemType ,0 as IsType
FROM Common.TimeLog T (NOLOCK)
	INNER JOIN Common.TimeLogDetail TLD (NOLOCK) ON T.Id=TLD.MasterId
	INNER JOIN Common.TimeLogItem TLI (NOLOCK) ON TLI.Id=T.TimeLogItemId
	LEFT JOIN WorkFlow.CaseGroup CG (NOLOCK) on TLI.SystemId = CG.Id
    left Join ClientCursor.Opportunity o (NOLOCK) on o.Id=cg.OpportunityId
	INNER JOIN Common.Employee E (NOLOCK) on T.EmployeeId = E.Id  
	INNER JOIN [HR].[EmployeeDepartment] as HR (NOLOCK) on HR.EmployeeId = E.Id
	LEFT JOIN Common.MediaRepository as MR (NOLOCK) ON MR.Id=E.PhotoId
	INNER JOIN @Temp AS A ON T.StartDate >= A.StartDate And T.EndDate <= A.Enddate 
WHERE T.CompanyId = @CompanyId and t.Status=1 AND o.Stage='Pending' 
        AND   ((A.StartDate between cast(EffectiveFrom as date) and cast(case when EffectiveTo is null then dateadd(d,-1,Convert(date,Convert(varchar(100),Year(GETDATE())+1)+'-'+'01'+'-'+'01')) 
            else EffectiveTo end  as Date)) or (A.Enddate between cast(EffectiveFrom as date) 
		AND cast(case when EffectiveTo is null then dateadd(d,-1,Convert(date,Convert(varchar(100),Year(GETDATE())+1)+'-'+'01'+'-'+'01')) else EffectiveTo end  as Date)))
		AND T.StartDate >= A.StartDate And T.EndDate <= A.Enddate
		AND (@EmployeeId IS NULL AND @DepartmentId IS NULL  AND @DesignationId IS NULL)
GROUP BY E.FirstName,T.StartDate,T.Enddate,E.Id,e.EmployeeId,TLI.SystemId, TLI.SystemType,MR.Small,A.StartDate,A.Enddate  
 

Insert Into @OUTPUT
--======================================  Pending STEP 1  ====================================
SELECT 
	E.FirstName as EMPLOYEENAME,A.StartDate,A.Enddate,
	RIGHT('0' + CAST(   isnull(sum(DATEPART(SECOND, tld.Duration) + 60 *  DATEPART(MINUTE, tld.Duration) + 3600 * DATEPART(HOUR, tld.Duration )),0) / 3600 AS VARCHAR),2) + '.' +
	RIGHT('0' + CAST((   isnull(sum(DATEPART(SECOND, tld.Duration) + 60 *  DATEPART(MINUTE, tld.Duration) + 3600 * DATEPART(HOUR, tld.Duration )),0) / 60) % 60 AS VARCHAR),2) As TOTALHOURS,'00.00' AS IsOverRunHours,E.Id AS EMPLOYEEID,
	e.EmployeeId AS EMPLOYEEAUTONUMBER,MR.Small as PHOTOURL,TLI.SystemId,TLI.SystemType ,0 as IsType
FROM Common.TimeLog T (NOLOCK)
	INNER JOIN Common.TimeLogDetail TLD (NOLOCK) ON T.Id=TLD.MasterId
	INNER JOIN Common.TimeLogItem TLI (NOLOCK) ON TLI.Id=T.TimeLogItemId
	LEFT JOIN WorkFlow.CaseGroup CG (NOLOCK) on TLI.SystemId = CG.Id
    left Join ClientCursor.Opportunity o (NOLOCK) on o.Id=cg.OpportunityId
	INNER JOIN Common.Employee E (NOLOCK) on T.EmployeeId = E.Id  
	INNER JOIN [HR].[EmployeeDepartment] as HR (NOLOCK) on HR.EmployeeId = E.Id
	LEFT JOIN Common.MediaRepository as MR (NOLOCK) ON MR.Id=E.PhotoId
	INNER JOIN @Temp AS A ON T.StartDate >= A.StartDate And T.EndDate <= A.Enddate 
WHERE T.CompanyId = @CompanyId and t.Status=1 AND o.Stage='Pending' 
		AND CAST (T.EmployeeId  AS NVARCHAR(50)) LIKE ISNULL(CAST(@EmployeeId  as NVARCHAR(50)),'%%') 
        AND   ((A.StartDate between cast(EffectiveFrom as date) and cast(case when EffectiveTo is null then dateadd(d,-1,Convert(date,Convert(varchar(100),Year(GETDATE())+1)+'-'+'01'+'-'+'01')) 
            else EffectiveTo end  as Date)) or (A.Enddate between cast(EffectiveFrom as date) 
		AND cast(case when EffectiveTo is null then dateadd(d,-1,Convert(date,Convert(varchar(100),Year(GETDATE())+1)+'-'+'01'+'-'+'01')) else EffectiveTo end  as Date)))
		AND T.StartDate >= A.StartDate And T.EndDate <= A.Enddate
		AND (@EmployeeId IS NOT NULL OR @DepartmentId IS NOT NULL  OR @DesignationId IS NOT NULL)
GROUP BY E.FirstName,T.StartDate,T.Enddate,E.Id,e.EmployeeId,TLI.SystemId, TLI.SystemType,MR.Small,A.StartDate,A.Enddate  


---------->>>> OutPut
DECLARE @WorkWeekHours Decimal(17,2) = (SELECT CAST(SUM(DATEDIFF(MINUTE, 0, WorkingHours)) / 60.0  AS DECIMAL(20,2)) AS TotalHours FROM Common.WorkWeekSetUp WHERE CompanyId = @CompanyId AND EmployeeId IS NULL AND IsWorkingDay!=0)

SELECT EMPLOYEENAME ,STARTDATE ,ENDDATE ,TOTALHOURS ,ISOVERRUNHOURS ,A.EMPLOYEEID ,EMPLOYEEAUTONUMBER , PHOTOURL ,SystemId ,SystemType , IsType,
	B.DepartmentCode, B.DesignationName,B.LevelRank, @WorkWeekHours AS WorkWeekHours     
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
 

END
GO
