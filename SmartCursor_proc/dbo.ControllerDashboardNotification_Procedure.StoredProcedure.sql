USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[ControllerDashboardNotification_Procedure]    Script Date: 16-12-2024 9.20.10 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE   PROCEDURE [dbo].[ControllerDashboardNotification_Procedure] @companyId BigInt,@type nvarchar(20),@date date 
AS
BEGIN

DECLARE  
	--@CompanyId BigInt = 2058,
	--@type nvarchar(20)= 'Month',
	--@date date = '2024-03-10',
	@WorkWeekHours DECIMAL (20,2),
	@StartDate date,
	@EndDate date

CREATE TABLE #Employees (S_No BigInt Identity(1,1),EmployeeId Uniqueidentifier,EmployeeName NVARCHAR (1000),PhotoId uniqueidentifier)
CREATE TABLE #OutPut  (EmployeeId Uniqueidentifier NULL,EmployeeName NVARCHAR (1000)NULL, PhotoId UniqueIdentifier NULL,StartDate DATE NULL,EndDate DATE NULL,Hours BigInt NULL)

SELECT 
@StartDate =
		(CASE 
			WHEN @type = 'Week' THEN (DATEADD(DAY, 2 - DATEPART(WEEKDAY, @date), CAST(@date AS DATE)))
			WHEN @type = 'Month' THEN (SELECT  DATEADD(mm, DATEDiff(mm,0, @date),0))			
			WHEN @type = 'Day' THEN @date
		END) ,
@EndDate=
	(CASE 
		WHEN @type = 'Week' THEN (DATEADD(DAY, 8 - DATEPART(WEEKDAY, @date), CAST(@date AS DATE)))
		WHEN @type = 'Month' THEN (DATEADD (dd, -1, DATEADD(mm, DATEDIFF(mm, 0, @date) + 1, 0)))
		WHEN @type = 'Day' THEN @date
	END )

SELECT @WorkWeekHours = SUM(WorkHours) FROM [dbo].[DateRange_Function] (@CompanyId,@StartDate,@EndDate)

INSERT INTO #Employees (EmployeeId,EmployeeName,PhotoId)
SELECT DISTINCT 
	emp.Id AS EmployeeId, emp.FirstName AS EmployeeName, emp.PhotoId
FROM Common.Employee AS emp (NOLOCK)
	LEFT JOIN Common.TimeLogSetup AS tls (NOLOCK) ON emp.Id = tls.EmployeeId
WHERE emp.CompanyId= @CompanyId AND emp.Status=1 AND emp.IsHronly=1 
	AND(( tls.StartDate <= @StartDate  OR tls.StartDate BETWEEN @StartDate AND @EndDate)
	AND  ((ISNULL( tls.EndDate ,@EndDate ) >= @EndDate) OR tls.EndDate BETWEEN @StartDate AND @EndDate )) 

-------->>> TimeLogs
INSERT INTO #OutPut
SELECT A.EmployeeId,A.EmployeeName,A.PhotoId,@StartDate AS StartDate, @EndDate as EndDate,[Hours]
FROM #Employees AS A
LEFT JOIN 
(
	SELECT 
		B.EmployeeId, SUM(DATEPART(HOUR, Duration) * 60) + SUM((DATEPART(MINUTE, Duration))) AS [Hours]
	FROM  Common.TimeLog AS B (NOLOCK)
	JOIN   Common.TimeLogDetail AS C (NOLOCK) ON C.MasterId = B.Id
	WHERE  B.CompanyId = @companyId  AND CAST(C.Date AS DATE) BETWEEN @StartDate AND @EndDate
	GROUP BY EmployeeId
) AS B  ON B.EmployeeId = A.EmployeeId
GROUP BY A.EmployeeId,A.EmployeeName,A.PhotoId

-------->>> Holidays
INSERT INTO #OutPut
SELECT A.EmployeeId,A.EmployeeName,A.PhotoId,@StartDate as StartDate,@EndDate as EndDate, SUM(B.[Minutes]) AS [Hours] 
FROM #Employees AS A
LEFT JOIN 
	(
		SELECT EmployeeId, [Minutes]
		FROM (
				SELECT CASE WHEN A.ApplyToAll = 1 THEN B.Id WHEN A.ApplyToAll = 0 THEN C.EmployeeId END AS EmployeeId, [dbo].[UFN_Decimal_Into_Minutes](Hours) AS [Minutes]
				FROM Common.CalenderSchedule AS A (NOLOCK)
				INNER JOIN Common.Calender AS D ON D.Id = A.CalenderId
				INNER JOIN Common.Employee AS B (NOLOCK) ON B.CompanyId = A.CompanyId AND B.CompanyId = @CompanyId
				LEFT JOIN Common.CalenderDetails AS C (NOLOCK) ON C.MasterId = A.CalenderId AND B.Id = C.EmployeeId
				WHERE d.Status = 1 AND A.CompanyId = @CompanyId AND CAST(A.StartDate AS Date) BETWEEN @StartDate AND @EndDate AND B.Status = 1
			) AS A
		WHERE EmployeeId IS NOT NULL
	)
AS B  ON B.EmployeeId = A.EmployeeId
GROUP BY A.EmployeeId,A.EmployeeName,A.PhotoId

-------->>> Leaves 
INSERT INTO #OutPut
SELECT A.EmployeeId,A.EmployeeName,A.PhotoId,@StartDate as StartDate,@EndDate as EndDate,
SUM([dbo].[UFN_Decimal_Into_Minutes](B.[Hours])) AS [Hours] 
FROM #Employees AS A
LEFT JOIN dbo.TimeLogItemLeavesTrainingsData (@companyId,@StartDate,@EndDate) AS B  ON B.EmployeeId = A.EmployeeId AND B.SystemType = 'LeaveApplication' 
LEFT JOIN HR.LeaveApplication AS la (NOLOCK) ON B.SystemId = la.Id AND ( la.LeaveStatus = 'Approved'  OR la.LeaveStatus = 'For Cancellation' )
GROUP BY A.EmployeeId,A.EmployeeName,A.PhotoId

-------->>> Trainings 
INSERT INTO #OutPut
SELECT A.EmployeeId,A.EmployeeName,A.PhotoId,@StartDate as StartDate,@EndDate as EndDate,
SUM([dbo].[UFN_Decimal_Into_Minutes](ISNULL(B.[Hours],0))) AS [Hours] 
FROM #Employees AS A
LEFT JOIN dbo.TimeLogItemLeavesTrainingsData (@companyId,@StartDate,@EndDate) AS B  ON B.EmployeeId = A.EmployeeId AND B.SystemType = 'Training' 
GROUP BY A.EmployeeId,A.EmployeeName,A.PhotoId, SystemType

------->>>> OUTPUT
SELECT EMPLOYEEID,EMPLOYEENAME,PHOTOURL,(CAST(DiffHours / 60 + (DiffHours % 60) / 100.0 AS decimal(20, 2))) AS EmpNotBookedHours,
	WorkWeekHours AS TOATLHOURS,STARTDATE AS STARTDATE, ENDDATE AS ENDDATE,WeekNumber
FROM (
		SELECT 
			EmployeeId,EmployeeName,PhotoURL,EmpOverAllHours,WorkWeekHours,@StartDate AS StartDate,@EndDate AS EndDate, 1 AS WeekNumber,
			([dbo].[UFN_Decimal_Into_Minutes](WorkWeekHours) - [dbo].[UFN_Decimal_Into_Minutes](EmpOverAllHours)) AS DiffHours			
		FROM(
			SELECT 
				E.EmployeeId, EmployeeName, PhotoId,(SELECT Medium FROM Common.MediaRepository (NOLOCK) WHERE Id = PhotoId) as PhotoURL, 
				SUM(Hours) as [Minutes],(CAST(SUM( [Hours]) / 60 + (SUM( [Hours]) % 60) / 100.0 AS decimal(20, 2))) AS EmpOverAllHours,
				@WorkWeekHours  AS WorkWeekHours
			FROM #OutPut AS E
			GROUP BY E.EmployeeId, EmployeeName, PhotoId
			) AS A
			WHERE EmpOverAllHours < WorkWeekHours
	) AS A
WHERE EmployeeName IS NOT NULL
ORDER BY EmployeeName


DROP TABLE #Employees
DROP TABLE #OutPut

END
GO
