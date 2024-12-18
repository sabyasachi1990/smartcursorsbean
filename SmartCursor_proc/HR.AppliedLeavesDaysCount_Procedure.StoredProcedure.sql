USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [HR].[AppliedLeavesDaysCount_Procedure]    Script Date: 16-12-2024 9.20.11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

----->>> If removing non working days  from workweek setup by calculating the days count, how can we know there are sat and sun between the applied days.

CREATE     PROCEDURE [HR].[AppliedLeavesDaysCount_Procedure] 
(@FromDate Date, @ToDate DATE,@StartDateType Nvarchar(10), @EndDateType Nvarchar(10), @EmployeeId UniqueIdentifier,@CompanyId BigInt)
AS
BEGIN


DECLARE @DateRange Table (DateValue Date);

--------------Holidays
SELECT * INTO #HolidayDates FROM
(
SELECT A.CompanyId,CAST(A.StartDate AS Date) as [Date],A.TimeType,A.Hours--'AM' AS TimeType, 4.00 AS [Hours]
FROM Common.CalenderSchedule AS A (NOLOCK)
INNER JOIN Common.Calender AS C ON C.Id = A.CalenderId
LEFT JOIN Common.CalenderDetails AS B (NOLOCK) ON B.MasterId = A.CalenderId
WHERE  C.Status = 1 AND CAST(A.StartDate AS Date) BETWEEN @FromDate AND @ToDate AND ( B.EmployeeId = @EmployeeId OR A.ApplyToAll = 1)
	AND A.CompanyId = @CompanyId
) AS B

-------------- All Dates between StartDate and EndDate
;WITH DateRange AS (
    SELECT @FromDate AS DateValue
	WHERE @FromDate <= @ToDate 
    UNION ALL
    SELECT DATEADD(DAY, 1, DateValue)
    FROM DateRange
    WHERE DateValue < @ToDate AND @FromDate <= @ToDate
)

INSERT INTO @DateRange
SELECT DateValue
FROM DateRange
OPTION (MAXRECURSION 0)


-------------- Days Calculation
SELECT CAST(ISNULL(SUM(Days),0)AS Decimal(10,1)) as [Days] 
FROM (
		SELECT B.CompanyId, A.DateValue, C.Date,C.TimeType,C.Hours,DATENAME(DW,DateValue) AS Day,
		CASE 
			 WHEN A.DateValue = @FromDate AND A.DateValue = @ToDate  AND @StartDateType = 'AM' AND @EndDateType = 'AM' THEN (CASE WHEN A.DateValue = c.Date AND C.TimeType = 'AM' THEN 0.5-(C.Hours/8) ELSE 0.5  END)
			 WHEN A.DateValue = @FromDate AND A.DateValue = @ToDate  AND @StartDateType = 'PM' AND @EndDateType = 'PM' THEN (CASE WHEN A.DateValue = c.Date AND C.TimeType = 'PM' THEN 0.5-(C.Hours/8) ELSE 0.5  END)
			 WHEN A.DateValue = @FromDate AND A.DateValue = @ToDate  AND @StartDateType = 'Full' AND @EndDateType = 'Full' THEN (CASE WHEN A.DateValue = c.Date THEN 1-(C.Hours/8) ELSE 1  END)
			 WHEN A.DateValue = @FromDate AND A.DateValue = @ToDate  AND @StartDateType = 'Full' AND @EndDateType IN ('AM','PM') THEN 0
			 WHEN A.DateValue = @FromDate AND A.DateValue = @ToDate  AND @StartDateType = 'PM' AND @EndDateType IN ('AM','Full') THEN 0
			 WHEN A.DateValue = @FromDate AND A.DateValue = @ToDate  AND @StartDateType = 'AM' AND @EndDateType IN ('PM','Full') THEN 0
			 WHEN A.DateValue = @FromDate AND A.DateValue != @ToDate AND @StartDateType = 'AM' THEN (CASE WHEN A.DateValue = c.Date THEN 1-(C.Hours/8) ELSE 1  END)
			 WHEN A.DateValue = @FromDate AND A.DateValue != @ToDate AND @StartDateType = 'Full' THEN (CASE WHEN A.DateValue = c.Date THEN 1-(C.Hours/8) ELSE 1  END)
			 WHEN A.DateValue = @FromDate AND A.DateValue != @ToDate AND @StartDateType = 'PM' THEN (CASE WHEN A.DateValue = c.Date AND C.TimeType = 'PM' THEN 0.5-(C.Hours/8) ELSE 0.5  END)
			 WHEN A.DateValue != @FromDate AND A.DateValue = @ToDate AND @EndDateType = 'AM' THEN (CASE WHEN A.DateValue = c.Date AND C.TimeType = 'AM' THEN 0.5-(C.Hours/8) ELSE 0.5  END)
			 WHEN A.DateValue != @FromDate AND A.DateValue = @ToDate AND @EndDateType = 'Full' THEN (CASE WHEN A.DateValue = c.Date THEN 1-(C.Hours/8) ELSE 1  END)
			 WHEN A.DateValue != @FromDate AND A.DateValue = @ToDate AND @EndDateType = 'PM' THEN (CASE WHEN A.DateValue = c.Date AND C.TimeType = 'PM' THEN 1-(C.Hours/8) ELSE 1  END)
			 WHEN A.DateValue != @FromDate AND A.DateValue != @ToDate THEN (CASE WHEN A.DateValue = c.Date THEN 1-(C.Hours/8) ELSE 1  END)
			 ELSE 1
		END AS Days
		FROM @DateRange AS A 
		 JOIN Common.WorkWeekSetUp AS B (NOLOCK) ON WeekDay  = DATENAME(DW,DateValue) AND B.CompanyId = @CompanyId AND B.EmployeeId IS NULL
		LEFT JOIN #HolidayDates AS C ON C.CompanyId = @CompanyId AND C.Date = A.DateValue 
		WHERE B.IsWorkingDay != 0 AND B.CompanyId = @CompanyId AND 
		A.DateValue NOT IN (SELECT Date FROM #HolidayDates WHERE TimeType = 'Full')
) AS A


DROP TABLE #HolidayDates
END
------------------------------------------------------------------------------

 --EXECUTE  HR.AppliedLeavesDaysCount_Procedure '2024-01-01', '2024-05-30','PM','PM', '44DE0FF9-562F-4ACA-B046-6E06CF95DBD7',2058
GO
