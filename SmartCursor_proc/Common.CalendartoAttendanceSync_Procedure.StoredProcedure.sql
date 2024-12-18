USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [Common].[CalendartoAttendanceSync_Procedure]    Script Date: 16-12-2024 9.20.10 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



 CREATE     PROCEDURE [Common].[CalendartoAttendanceSync_Procedure] (@CalanderId UniqueIdentifier,  @CompanyId BigInt)

 AS
 BEGIN
 Begin Transaction
BEGIN TRY


SELECT * INTO #InsertAttendance 
	FROM (
select cs.id,cs.StartDate ,a.id as AttendanceId , NEWID() AS NewAttendanceId from Common.CalenderSchedule as cs left join Common.Attendance as a  ON CAST(cs.StartDate  AS Date) = CAST(a.Date AS Date) and cs.CompanyId=a.CompanyId
			where cs.CompanyId =@CompanyId  and cs.CalenderId=@CalanderId    ) as A

	INSERT INTO Common.Attendance (Id, CompanyId, Date, Status) 
	SELECT NewAttendanceId,@CompanyId,StartDate,1 
	FROM #InsertAttendance
	WHERE AttendanceId IS NULL

	SELECT * INTO #CalendarToAttendance 
	FROM (
			SELECT A.*,D.Id as AttendanceId,E.Id AS AttendanceDetailId,NEWID() AS NewAttendanceId
			FROM (
					SELECT 
						A.CalenderId,O.Name,O.ChargeType,A.StartDate,Hours,A.TimeType,CASE WHEN A.ApplyToAll = 1 THEN B.Id ELSE C.EmployeeId END AS EmployeeId,
						B.DepartmentId, B.DesignationId,B.FirstName,B.CurrentServiceEnittyId AS EntityId
					FROM Common.Calender AS O (NOLOCK)
					INNER JOIN Common.CalenderSchedule AS A (NOLOCK) ON O.Id = A.CalenderId
					INNER JOIN Common.WorkWeekSetUp AS W (NOLOCK) ON W.WeekDay = DATENAME(WEEKDAY,A.StartDate) AND W.CompanyId = @CompanyId AND W.EmployeeId IS NULL 
					INNER JOIN Common.Employee AS B (NOLOCK) ON B.CompanyId = A.CompanyId AND B.CompanyId = @CompanyId
					LEFT JOIN Common.CalenderDetails AS C (NOLOCK) ON C.MasterId = A.CalenderId AND B.Id = C.EmployeeId
					WHERE CalenderId = @CalanderId AND A.CompanyId = @CompanyId AND B.CompanyId = @CompanyId AND W.IsWorkingDay!=0
				) AS A
			LEFT JOIN Common.Attendance AS D (NOLOCK) ON CAST(D.Date AS Date) = CAST(A.StartDate AS Date) AND D.CompanyId =@CompanyId
			LEFT JOIN Common.AttendanceDetails AS E (NOLOCK) ON E.AttendenceId = D.Id AND E.EmployeeId = A.EmployeeId
			WHERE A.EmployeeId IS NOT NULL
	) AS A




	--SELECT * FROM #CalendarToAttendance
	------------------------------------------------------------------ Inserts and Updates ----------------------------------------------------------------
	UPDATE A SET
		A.AttendanceType=NULL, CalanderId = NULL
	FROM [Common].[AttendanceDetails] AS A
	INNER JOIN #CalendarToAttendance AS B ON B.AttendanceId = A.AttendenceId 
	WHERE A.EmployeeId != B.EmployeeId AND A.CalanderId IS NOT NULL 

	UPDATE A SET
		A.AttendanceType=B.ChargeType, CalanderId = @CalanderId
	FROM [Common].[AttendanceDetails] AS A
	INNER JOIN 
	(
	 SELECT * FROM #CalendarToAttendance
	) AS B  ON B.AttendanceId = A.AttendenceId AND A.CalanderId IS NULL AND A.EmployeeId = B.EmployeeId

	--INSERT INTO Common.Attendance (Id, CompanyId, Date, Status) 
	--SELECT NewAttendanceId,@CompanyId,StartDate,1 
	--FROM #CalendarToAttendance
	--WHERE AttendanceId IS NULL

	INSERT INTO [Common].[AttendanceDetails] (Id, EmployeeId, AttendenceId, UserCreated, CreatedDate, STATUS, EmployeeName, DepartmentId, DesignationId, ServiceEntityId, AttendanceType,CalanderId,CompanyId,AttendanceDate,DateValue)  
	SELECT NEWID(),EmployeeId,NewAttendanceId,'System',GETUTCDATE(),1 ,FirstName ,DepartmentId ,DesignationId ,EntityId ,ChargeType,@CalanderId,@CompanyId,convert(DATE, StartDate),(cast ((replace(convert(varchar, StartDate,102),'.','')) as bigint)) 
	FROM #CalendarToAttendance
	WHERE AttendanceId IS NULL AND AttendanceDetailId IS NULL

	INSERT INTO [Common].[AttendanceDetails] (Id, EmployeeId, AttendenceId, UserCreated, CreatedDate, STATUS, EmployeeName, DepartmentId, DesignationId, ServiceEntityId, AttendanceType,CalanderId,CompanyId,AttendanceDate,DateValue)  
	SELECT NEWID(),EmployeeId,AttendanceId,'System',GETUTCDATE(),1 ,FirstName ,DepartmentId ,DesignationId ,EntityId ,ChargeType,@CalanderId,@CompanyId,convert(DATE, StartDate),(cast ((replace(convert(varchar, StartDate,102),'.','')) as bigint)) 
	FROM #CalendarToAttendance
	WHERE AttendanceId IS NOT NULL AND AttendanceDetailId IS NULL


	DROP TABLE #CalendarToAttendance


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
		End
GO
