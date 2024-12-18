USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[TimeLogDashBoardNotifications]    Script Date: 16-12-2024 9.20.11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE Procedure [dbo].[TimeLogDashBoardNotifications] ---->> EXEC [dbo].[TimeLogDashBoardNotifications] 2050,'MONTH','2024-04-12' 
@companyId BigInt,@type nvarchar(20),@date date,@employeeName Varchar(max)   
  
AS  
BEGIN  
  

 DECLARE  
	--@CompanyId BigInt = 2058,
	--@type nvarchar(20)= 'Month',
	--@date date = '2023-04-10',
	@WorkWeekHours DECIMAL (20,2),
	@StartDate date,
	@EndDate date

DECLARE @OUTPUT TABLE (EMPLOYEEID Uniqueidentifier,EMPLOYEENAME NVARCHAR (1000),PHOTOURL NVARCHAR (Max),EmpNotBookedHours varchar(max),TOATLHOURS varchar(max),STARTDATE DATE,ENDDATE DATE,WeekNumber NVARCHAR (20))

SET @StartDate =
CASE 
	WHEN @type = 'Month' THEN (SELECT  DATEADD(mm, DATEDiff(mm,0, @date),0))
	WHEN @type = 'Week' THEN (DATEADD(DAY, 2 - DATEPART(WEEKDAY, @date), CAST(@date AS DATE)))
	WHEN @type = 'Day' THEN @date
END 
SET @EndDate =
CASE 
	WHEN @type = 'Month' THEN (DATEADD (dd, -1, DATEADD(mm, DATEDIFF(mm, 0, @date) + 1, 0)))
	WHEN @type = 'Week' THEN (DATEADD(DAY, 8 - DATEPART(WEEKDAY, @date), CAST(@date AS DATE)))
	WHEN @type = 'Day' THEN @date
END 

;WITH ListDates(AllDates) AS 
(   SELECT @StartDate AS DATE
    UNION ALL
    SELECT DATEADD(DAY,1,AllDates)
    FROM ListDates 
    WHERE AllDates < @EndDate
)

SELECT @WorkWeekHours = (
							SELECT SUM(TotalHours) 
							FROM(
									SELECT WeekDay,WorkingHours, CNT, (CNT *(CAST (SUM(DATEDIFF(MINUTE,0,WorkingHours))/60.0  AS DECIMAL (20,2)))) AS TotalHours
									FROM Common.Workweeksetup AS a(NOLOCK)
									INNER JOIN  (SELECT DATENAME(DW,AllDates) as [Day], COUNT(DATENAME(DW,AllDates)) AS CNT FROM ListDates GROUP BY DATENAME(DW,AllDates)) AS B
									ON B.[Day] = A.WeekDay 
									WHERE  a.CompanyId =  @CompanyId  AND IsWorkingday=1 AND a.EmployeeId IS NULL		
									GROUP BY CNT,WeekDay,WorkingHours
								) AS A
						)

SELECT * INTO #Employee
FROM (
		SELECT emp.Id as EmployeeId,emp.FirstName as EmployeeName, emp.PhotoId,cu.Username,emp.CompanyId,cu.Id AS CompanyUserId
		FROM Common.Employee AS emp (NOLOCK)
			INNER JOIN Common.CompanyUser AS cu (NOLOCK) ON emp.Username = cu.Username AND emp.CompanyId = cu.CompanyId
			LEFT JOIN Common.TimeLogSetup AS tls (NOLOCK) ON emp.Id = tls.EmployeeId
		WHERE emp.CompanyId= @CompanyId  AND emp.IsHronly=1  AND(( tls.StartDate <= @StartDate  OR tls.StartDate BETWEEN @StartDate AND @EndDate) 
			AND  ((ISNULL( tls.EndDate ,@EndDate ) >= @EndDate) OR ISNULL( tls.EndDate ,@EndDate ) BETWEEN @StartDate AND @EndDate )) AND emp.Status=1
	) AS A

INSERT INTO @OUTPUT
SELECT EmployeeId,EmployeeName,PhotoURL,(CAST(DiffHours / 60 + (DiffHours % 60) / 100.0 AS decimal(20, 2))) AS TotalHours,WorkWeekHours,StartDate,EndDate,WeekNumber
FROM (
		SELECT EmployeeId,EmployeeName,(SELECT Medium FROM Common.MediaRepository (NOLOCK) WHERE Id = PhotoId) as PhotoURL,EmpOverAllHours,WorkWeekHours,
		([dbo].[UFN_Decimal_Into_Minutes](WorkWeekHours) - [dbo].[UFN_Decimal_Into_Minutes](EmpOverAllHours)) AS DiffHours,StartDate,EndDate, 1 AS WeekNumber
		FROM (     ------------->>>>> Commented calculation code at bottom and Written the calculations from sub query
			SELECT EmployeeId,EmployeeName,PhotoId,StartDate,EndDate,SUM( [Hours]) AS [Hours],(CAST(SUM( [Hours]) / 60 + (SUM( [Hours]) % 60) / 100.0 AS decimal(20, 2))) AS EmpOverAllHours,@WorkWeekHours  AS WorkWeekHours
			FROM (
					----------->>> Employees
					SELECT C.EmployeeId,C.EmployeeName,C.PhotoId,@StartDate as StartDate,@EndDate as EndDate,0 AS [Hours]
					FROM #Employee AS C

					UNION ALL
					----------->>> EmpBookedHours (TimeLogHous)
					SELECT DISTINCT 
						E.EmployeeId,E.EmployeeName,E.PhotoId,@StartDate as StartDate,@EndDate as EndDate,SUM(DATEPART(HOUR, tld.Duration) * 60) + SUM((DATEPART(MINUTE, tld.Duration))) AS [Hours]
					FROM #Employee AS E
					LEFT JOIN Common.TimeLog AS TL (NOLOCK) ON TL.EmployeeId = E.EmployeeId AND TL.CompanyId = @CompanyId
					LEFT JOIN Common.TimeLogDetail AS TLD (NOLOCK) ON TL.Id = TLD.MasterId AND CAST(TLD.Date AS date) >= @StartDate  AND CAST(TLD.Date AS date) <= @EndDate  AND TLD.Duration <> '00:00:00.0000000'
					WHERE TL.CompanyId = @CompanyId AND CAST(TLD.Date AS date) <= @EndDate  AND TLD.Duration <> '00:00:00.0000000'
					GROUP BY E.EmployeeId,E.EmployeeName,E.PhotoId

					UNION ALL
					----------->>> Leaves
					SELECT L.EmployeeId,E.EmployeeName,E.PhotoId,@StartDate as StartDate,@EndDate as EndDate,SUM([dbo].[UFN_Decimal_Into_Minutes](T.Hours)) AS [Hours] 
					FROM #Employee AS E
					LEFT JOIN HR.LeaveApplication AS L (NOLOCK) ON E.EmployeeId = L.EmployeeId 
					LEFT JOIN Common.TimeLogItem AS T (NOLOCK) ON T.SystemId = L.Id AND T.CompanyId = @CompanyId AND CAST(T.StartDate AS Date) >= @StartDate  AND CAST(T.EndDate AS Date) <= @EndDate
					WHERE T.SystemType = 'LeaveApplication' AND T.IsSystem = 1  AND T.ApplyToAll != 1 AND (L.LeaveStatus = 'Approved'  OR L.LeaveStatus = 'For Cancellation' ) 
						AND CAST(T.StartDate AS Date) >= @StartDate  AND CAST(T.EndDate AS Date) <= @EndDate
					GROUP BY L.EmployeeId,E.EmployeeName,E.PhotoId

					UNION ALL

					----------->>> Calendar
					SELECT A.EmployeeId, EmployeeName,PhotoId,@StartDate,@EndDate,sum(calenderHrs) as [hours]
					FROM (
						SELECT DISTINCT  A.CompanyId, A.Name,ApplyToAll,CASE WHEN A.ApplyToAll = 1 THEN B.EmployeeId ELSE C.EmployeeId END AS EmployeeId,
						CASE WHEN A.ApplyToAll = 1 THEN B.EmployeeName ELSE (CASE WHEN C.EmployeeId = B.EmployeeId THEN B.EmployeeName END) END AS EmployeeName,
						CASE WHEN A.ApplyToAll = 1 THEN B.PhotoId ELSE (CASE WHEN C.EmployeeId = B.EmployeeId THEN B.PhotoId END) END AS PhotoId,
						[dbo].[UFN_Decimal_Into_Minutes](Hours) as calenderHrs
						FROM Common.CalenderSchedule AS A (NOLOCK)
						INNER JOIN Common.Calender AS D ON D.Id = A.CalenderId
						INNER JOIN #Employee AS B ON B.CompanyId = A.CompanyId AND B.CompanyId = @CompanyId
						LEFT JOIN Common.CalenderDetails AS C (NOLOCK) ON C.MasterId = A.CalenderId AND B.EmployeeId = C.EmployeeId
						WHERE  A.CompanyId = @CompanyId AND CAST(A.StartDate AS Date) BETWEEN @StartDate AND @EndDate AND B.CompanyId = @CompanyId AND D.Status = 1
					) AS A
					WHERE A.EmployeeId IS NOT NULL
					GROUP BY A.EmployeeId, EmployeeName,PhotoId

					UNION ALL

					----------->>> Trainings
					SELECT TLD.EmployeeId,E.EmployeeName,E.PhotoId,@StartDate as StartDate,@EndDate as EndDate,SUM([dbo].[UFN_Decimal_Into_Minutes](tli.Hours)) AS [Hours]
					FROM #Employee AS E
					INNER JOIN Common.TimeLogItemDetail AS TLD (NOLOCK) ON E.EmployeeId = TLD.EmployeeId
					INNER JOIN Common.TimeLogItem AS TLI (NOLOCK) ON TLI.Id = TLD.TimeLogItemId AND tli.CompanyId = @CompanyId AND tli.ApplyToAll = 0 AND tli.IsSystem = 1 
					WHERE tli.SystemType = 'Training'AND tli.IsSystem = 1 AND tli.ApplyToAll = 0 AND tli.StartDate >= @StartDate AND tli.EndDate <= @EndDate 
					AND tli.CompanyId = @CompanyId
					GROUP BY TLD.EmployeeId,E.EmployeeName,E.PhotoId

				) AS AD
			 GROUP BY EmployeeId,EmployeeName,PhotoId,StartDate,EndDate
			)AS VD
		WHERE EmpOverAllHours < WorkWeekHours
	 ) AS CV

DROP TABLE #Employee

END

SELECT * FROM @OUTPUT WHERE EMPLOYEENAME IS NOT NULL ORDER BY EMPLOYEENAME
GO
