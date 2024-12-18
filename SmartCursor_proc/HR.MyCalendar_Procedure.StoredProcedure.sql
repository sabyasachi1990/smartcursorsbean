USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [HR].[MyCalendar_Procedure]    Script Date: 16-12-2024 9.20.11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE       PROCEDURE [HR].[MyCalendar_Procedure] (@companyId nvarchar(10), @startDate nvarchar(50), @endDate nvarchar(50),@employeId nvarchar(250))
AS
BEGIN
Begin Transaction
		BEGIN TRY
--DECLARE 
--@companyId nvarchar(10) =1, 
--@startDate nvarchar(50)='2024-02-01', 
--@endDate nvarchar(50)='2024-02-29',
--@employeId nvarchar(250)='cc51ac0e-6226-4965-a22f-40ffc6f43d43'

------>> Holidays

	SELECT DISTINCT cal.Id as Id, CS.StartDate AS Fromdate, CS.EndDate AS Todate, CONVERT(VARCHAR(500),CS.Hours) AS Hours, CONCAT('(',Timetype, ')') AS TrainerName,
	cal.CalendarType AS TrainingStatus, NULL AS CourseCategory, NULL AS CourseCode, CS.Name AS CourseName, CONVERT(VARCHAR(500),FORMAT(CS.StartDate, 'M/d/yyyy h:mm:ss tt')) AS FromTime, 
	CONVERT(VARCHAR(500),FORMAT(CS.EndDate, 'M/d/yyyy h:mm:ss tt')) AS ToTime,CS.TimeType as TimeType, 0 AS IsSystem, 0 AS IsLeave, 1 AS IsHoliday, 0 AS IsTraining, Null as NoOfDays
	FROM  common.Calender as cal join  Common.CalenderSchedule AS CS (NOLOCK) on cal.Id= CS.CalenderId	
	LEFT JOIN Common.CalenderDetails AS C (NOLOCK) ON C.MasterId = CS.CalenderId 	
	WHERE CS.CompanyId = @CompanyId AND  CS.StartDate BETWEEN @startDate AND @endDate  AND (C.EmployeeId IS NULL OR C.EmployeeId = @employeId)

	UNION ALL


---------->> Leaves
	SELECT  DISTINCT LA.id as Id, DateValue AS Fromdate, DateValue AS Todate, null AS Hours, 
        CASE WHEN la.Hours IS NOT NULL AND la.Hours <> 0 THEN lt.Name + ' (' + CONVERT(VARCHAR, la.StartDateTime, 100) + ')'
        WHEN CONVERT(DATE, DateValue) = la.EndDateTime AND la.EndDateType IS NOT NULL THEN lt.Name + ' (' + la.EndDateType + ')'
        WHEN CONVERT(DATE, DateValue) = la.StartDateTime AND la.StartDateType IS NOT NULL THEN lt.Name + ' (' + la.StartDateType + ')'
        WHEN CONVERT(DATE, DateValue) <> la.EndDateTime AND la.StartDateType IS NOT NULL THEN lt.Name + ' (Full)'
        ELSE lt.Name END + ' ' + CONVERT(VARCHAR, la.LeaveStatus) AS TrainerName, LA.LeaveStatus AS TrainingStatus, NULL AS CourseCategory,
		NULL AS CourseCode, LT.name AS CourseName, Null AS FromTime, Null AS ToTime, Null as TimeType, 0 AS IsSystem, 1 AS IsLeave, 0 AS IsHoliday, 
		0 AS IsTraining, CASE WHEN lt.EntitlementType = 'Days' THEN '(' + CONVERT(VARCHAR, la.Days) + ' Days)' ELSE '(' + CONVERT(VARCHAR, la.Hours) + ' Hours)' END AS NoOfDays
	FROM  Hr.LeaveApplication LA (NOLOCK) 
		INNER JOIN hr.LeaveType LT (NOLOCK) on LT.Id = LA.LeaveTypeId
		INNER JOIN Common.Employee AS B (NOLOCK) ON la.EmployeeId = b.Id
		INNER JOIN dbo.DateRange_Function (@CompanyId,@startDate,@endDate) AS A ON A.DateValue BETWEEN LA.StartDateTime AND LA.EndDateTime
	WHERE LA.EmployeeId =@employeId 
		AND (LA.LeaveStatus = 'Approved' OR LA.LeaveStatus='For Cancellation'  )
	
	UNION ALL

------>> Trainings
	SELECT tr.id as Id, tr.TrainingDate AS Fromdate, tr.TrainingDate AS Todate, CONVERT(VARCHAR(500), tr.FirstHalfTotalHours, 108) AS Hours, t.TrainerNames AS TrainerName,    t.TrainingStatus AS TrainingStatus,
    cl.CourseCategory, cl.CourseCode, cl.CourseName, CONVERT(VARCHAR(5), FORMAT(DATEADD(SECOND, DATEDIFF(SECOND, '00:00:00', tr.FirstHalfFromTime), '1900-01-01'), 'hh:mm tt')) AS FromTime,
    CONVERT(VARCHAR(500), FORMAT(DATEADD(SECOND, DATEDIFF(SECOND, '00:00:00', tr.FirstHalfToTime), '1900-01-01'), 'hh:mm tt')) AS ToTime, Null as TimeType,
    0 AS IsSystem, 0 AS IsLeave, 0 AS IsHoliday, 1 AS IsTraining, Null as NoOfDays
	FROM   
    hr.TrainingSchedule tr (NOLOCK)
	INNER JOIN dbo.DateRange_Function (@CompanyId,@startDate,@endDate) AS A ON A.DateValue BETWEEN tr.TrainingDate AND tr.TrainingDate
	JOIN Hr.TrainingAttendee ta (NOLOCK) ON tr.TrainingId = ta.TrainingId
	JOIN Hr.Training t (NOLOCK) ON tr.TrainingId = t.Id
	JOIN HR.CourseLibrary cl (NOLOCK) ON t.CourseLibraryId = cl.Id
	WHERE
		t.CompanyId = @companyId AND ta.EmployeeId = @employeId AND tr.FirstHalfTotalHours IS NOT NULL AND tr.FirstHalfTotalHours <> '00:00:00'

UNION all

SELECT tr.id as Id,
   tr.TrainingDate AS Fromdate,
    tr.TrainingDate AS Todate,
    CONVERT(VARCHAR(500),tr.SecondHalfTotalHours ,108) AS Hours,
    t.TrainerNames AS TrainerName,
    t.TrainingStatus AS TrainingStatus,
    cl.CourseCategory,
    cl.CourseCode,
    cl.CourseName,
    CONVERT(VARCHAR(500),FORMAT(DATEADD(SECOND, DATEDIFF(SECOND, '00:00:00', tr.SecondHalfFromTime), '1900-01-01'), 'hh:mm tt') )AS FromTime,
   CONVERT(VARCHAR(500),FORMAT(DATEADD(SECOND, DATEDIFF(SECOND, '00:00:00', tr.SecondHalfToTime), '1900-01-01'), 'hh:mm tt')) AS ToTime ,
	Null as TimeType,
    0 AS IsSystem,
    0 AS IsLeave,
    0 AS IsHoliday,
    1 AS IsTraining	,
	Null as NoOfDays
FROM
      hr.TrainingSchedule tr (NOLOCK)
	INNER JOIN dbo.DateRange_Function (@CompanyId,@startDate,@endDate) AS A ON A.DateValue BETWEEN tr.TrainingDate AND tr.TrainingDate
	JOIN Hr.TrainingAttendee ta (NOLOCK) ON tr.TrainingId = ta.TrainingId
	JOIN Hr.Training t (NOLOCK) ON tr.TrainingId = t.Id
	JOIN HR.CourseLibrary cl (NOLOCK) ON t.CourseLibraryId = cl.Id
WHERE
    t.CompanyId = @companyId
    AND ta.EmployeeId = @employeId
    AND YEAR(tr.TrainingDate) = YEAR(@startDate)
    AND MONTH(tr.TrainingDate) = MONTH(@startDate)
    AND tr.SecondHalfTotalHours IS NOT NULL AND tr.SecondHalfTotalHours <> '00:00:00';

Commit Transaction;
		END TRY
		BEGIN CATCH
			RollBack Transaction;
			DECLARE
			@ErrorMessage NVARCHAR(4000),
			@ErrorSeverity INT,
			@ErrorState INT;
			SELECT
			@ErrorMessage = ERROR_MESSAGE(),
			@ErrorSeverity = ERROR_SEVERITY(),
			@ErrorState = ERROR_STATE();
			RAISERROR (@ErrorMessage,@ErrorSeverity,@ErrorState);
		END CATCH
	END
GO
