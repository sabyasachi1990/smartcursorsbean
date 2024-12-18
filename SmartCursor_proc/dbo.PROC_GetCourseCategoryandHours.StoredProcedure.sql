USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[PROC_GetCourseCategoryandHours]    Script Date: 16-12-2024 9.20.11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[PROC_GetCourseCategoryandHours]
 @EmpId NVARCHAR(50)
,@DeptId NVARCHAR(50)
,@DesigId NVARCHAR(50)
,@CompanyId BIGINT
,@Year INT 
AS 
BEGIN

--UPDATED ONE

DECLARE 
@FromDate DATETIME2(7) 
,@ToDate DATETIME2(7)

SELECT @FromDate  = CreatedDate FROM Common.Company (NOLOCK) WHERE Id = @CompanyId

SET @ToDate = DATEADD(Y,1,GETDATE());

	SELECT T.Id, E.FirstName , E.Id AS EmployeeId, CL.CourseCategory ,  REPLACE(T.Totalhours, ':', '.') Totalhours,
	FORMAT(DATEADD(MINUTE,DATEDIFF(MINUTE, '0:00:00', FirstHalfTotalHours) + DATEDIFF(MINUTE, '0:00:00', TS.SecondHalfTotalHours),'0:00:00'), 'HH:mm') AS Total, MR.Small
	--SELECT *
	FROM 
	 Common.Employee  E (NOLOCK) INNER JOIN 
	 HR.TrainingAttendee TA (NOLOCK) ON E.Id = TA.EmployeeId INNER JOIN
	 HR.Training T (NOLOCK) ON T.Id = TA.TrainingId INNER JOIN 
     HR.TrainingSchedule as TS (NOLOCK) on T.Id=TS.TrainingId INNER JOIN  
	 HR.CourseLibrary CL (NOLOCK) ON T.CourseLibraryId = CL.Id LEFT JOIN
	 Common.MediaRepository MR (NOLOCK) ON E.PhotoId = MR.Id INNER JOIN 
	 (
		SELECT A.TrainingId ,A.EmployeeId FROM 
			( SELECT TrainingId,EmployeeId,COUNT(*) AttendedCount FROM HR.TrainingAttendance (NOLOCK) WHERE ISNULL(AMAttended,0) = IsAMRequried AND ISNULL(PMAttended,0) = IsPMRequired  GROUP BY TrainingId,EmployeeId )A JOIN 
			( SELECT TrainingId,EmployeeId,COUNT(*) FullCount FROM HR.TrainingAttendance (NOLOCK)  GROUP BY TrainingId,EmployeeId )F ON A.TrainingId = F.TrainingId AND A.EmployeeId = F.EmployeeId
			WHERE AttendedCount = FullCount  
	 )TAD ON TAD.TrainingId = T.Id AND E.Id = TAD.EmployeeId
	WHERE E.CompanyId = @CompanyId
	 AND TA.DepartmentId LIKE CONCAT('%',@DeptId,'%')
	 AND TA.DesignationId LIKE CONCAT('%',@DesigId,'%')
	 AND E.Id LIKE CONCAT('%',@EmpId,'%')
	 --AND T.CreatedDate >= @FromDate AND T.CreatedDate <= @ToDate
	 AND YEAR(T.CreatedDate) = @Year
	 AND T.TrainingStatus = 'Completed'

END

		--SELECT TrainingId,EmployeeId,COUNT(*) AttendedCount FROM HR.TrainingAttendance WHERE ISNULL(AMAttended,1) = 1 AND ISNULL(PMAttended,1) = 1  GROUP BY TrainingId,EmployeeId

		--SELECT * FROM HR.TrainingAttendance WHERE ISNULL(AMAttended,0) = IsAMRequried AND ISNULL(PMAttended,0) = IsPMRequired


		--SELECT A.TrainingId ,A.EmployeeId FROM 
		--	( SELECT TrainingId,EmployeeId,COUNT(*) AttendedCount FROM HR.TrainingAttendance WHERE ISNULL(AMAttended,0) = IsAMRequried AND ISNULL(PMAttended,0) = IsPMRequired  GROUP BY TrainingId,EmployeeId )A JOIN 
		--	( SELECT TrainingId,EmployeeId,COUNT(*) FullCount FROM HR.TrainingAttendance   GROUP BY TrainingId,EmployeeId )F ON A.TrainingId = F.TrainingId AND A.EmployeeId = F.EmployeeId
		--	WHERE AttendedCount = FullCount  
  --          and  a.EmployeeId = 'a7722c9f-2740-7a54-ef5c-d98b116755e8'

		--	select * from HR.TrainingAttendance where TrainingId='C3E08C13-C6B1-420D-B102-044FE2A32C19' and EmployeeId = '65F05496-E2E7-E06B-6AB1-1116B579261D'
GO
