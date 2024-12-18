USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[LeavestoAttendanceSync_Procedure]    Script Date: 16-12-2024 9.20.10 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE     PROCEDURE [dbo].[LeavestoAttendanceSync_Procedure](@LeaveApplicationId Nvarchar(Max), @CompanyId BigInt)
AS
BEGIN
Begin Transaction
BEGIN TRY


DECLARE @LeaveApplicationIdAttendanceTable Table (Sno int, LeaveApplicationId Uniqueidentifier)

INSERT INTO @LeaveApplicationIdAttendanceTable
SELECT ROW_NUMBER() OVER (ORDER BY TRIM(value)) as SNo,TRIM(value) AS LeaveApplicationId FROM STRING_SPLIT(@LeaveApplicationId, ',') WHERE LTRIM(RTRIM(value)) <> ''

------>>> Variables to Capture data to insert and make calculations
DECLARE
@Counter Int = 1,@MaxLimit Int, @SubType NVARCHAR(100), @LeaveId Uniqueidentifier,      
@LeaveType nvarchar(10),@LeaveApplicationHours float,@Employeename NVARCHAR(200), 
@DepartmentId Uniqueidentifier,@DesignationId Uniqueidentifier, @EntityId bigint,
@IsTimeLogInsert bit = 0,@IsAttendanceInsert Bit = 0,@SystemSubTypeStatus nvarchar(20) ,
@FromDate datetime2, @ToDate datetime2, @EmployeeId uniqueidentifier, @Startdatetype nvarchar(10), @EnddateType nvarchar(10)

SELECT @MaxLimit = COUNT(SNo) FROM @LeaveApplicationIdAttendanceTable;

WHILE @Counter <= @MaxLimit
BEGIN

		SELECT @LeaveId = LeaveApplicationId FROM @LeaveApplicationIdAttendanceTable WHERE Sno = @Counter

		------->>> Assigning Data to Variables
		SELECT 
			@SubType=Name, @LeaveType=lt.EntitlementType, @Employeename=ce.FirstName, @DepartmentId=ce.DepartmentId, @DesignationId=ce.DesignationId,
			@LeaveApplicationHours = Cast(Replace(FORMAT(FLOOR(LA.Hours)*100 + (LA.Hours-FLOOR(LA.Hours))*60,'00:00'),':','.') As Decimal(17,2)),        
			@EntityId=ce.CurrentServiceEnittyId, 
			@IsTimeLogInsert = (CASE WHEN ISNULL(Lt.IsNotSynctoWorkflow,0) = 0 THEN  1 ELSE Lt.IsNotSynctoWorkflow END),
			@IsAttendanceInsert = (CASE WHEN ISNULL(Lt.IsNotSynctoAttendance,0) = 0 THEN  1 ELSE Lt.IsNotSynctoAttendance END),
			@SystemSubTypeStatus = LeaveStatus,@FromDate = LA.StartDateTime, @ToDate = LA.EndDateTime,@Startdatetype =LA.StartDateType,
			@EnddateType = LA.EndDateType, @EmployeeId = LA.EmployeeId
		FROM HR.LeaveType LT (NOLOCK)        
			INNER JOIN HR.LeaveApplication LA (NOLOCK) ON LA.LeaveTypeId = LT.Id 
			INNER JOIN Common.Employee ce (NOLOCK) ON LA.EmployeeId=ce.Id  
		WHERE LA.Id = @LeaveId;

		IF @IsAttendanceInsert = 1
		BEGIN
			----->>> Existing Id's in TimeLogItem table to update, delete and insert
			SELECT * INTO #ExistingRecords 
			FROM(
					SELECT Id,SystemId,StartDate,EndDate,ROW_NUMBER()OVER (ORDER BY StartDate ASC,EndDate DESC) AS ExistingRankOrder
					FROM Common.TimeLogItem (NOLOCK) WHERE SystemId = @LeaveId
				) AS A
			ORDER BY StartDate

			------------------------------------------- Attendance -------------------------------------------
			UPDATE [Common].[AttendanceDetails] SET AttendanceType=NULL,LeaveApplicationId=NULL 
			WHERE LeaveApplicationId=@LeaveId 

			SELECT * INTO #AttendanceDates 
			FROM(
					SELECT DISTINCT @EmployeeId as EmployeeId,CAST(A.[Date] AS Date) as [Date],B.Date AS AttendanceDate,  
						B.Id AS OldAttendanceId,NewId() as NewAttendanceId,C.Id AS AttendanceDetailsId,
						CASE 
							WHEN @LeaveType = 'Hours' THEN @SubType
							WHEN @LeaveType != 'Hours' AND CAST(A.[Date] AS Date) = @FromDate AND CAST(A.[Date] AS Date) = @ToDate AND CAST(A.[Date] AS Date) != ISNULL(A.HolidayDate,'') THEN @EnddateType
							WHEN @LeaveType != 'Hours' AND CAST(A.[Date] AS Date) = @FromDate AND CAST(A.[Date] AS Date) = @ToDate AND CAST(A.[Date] AS Date) = ISNULL(A.HolidayDate,'') THEN (CASE WHEN A.TimeType = 'AM' THEN 'PM' ELSE 'AM' END)
							WHEN @LeaveType != 'Hours' AND CAST(A.[Date] AS Date) = @FromDate AND CAST(A.[Date] AS Date) != @ToDate AND CAST(A.[Date] AS Date) != ISNULL(A.HolidayDate,'') THEN @Startdatetype
							WHEN @LeaveType != 'Hours' AND CAST(A.[Date] AS Date) = @FromDate AND CAST(A.[Date] AS Date) != @ToDate AND CAST(A.[Date] AS Date) = ISNULL(A.HolidayDate,'') THEN (CASE WHEN A.TimeType = 'AM' THEN 'PM' ELSE 'AM' END)
							WHEN @LeaveType != 'Hours' AND CAST(A.[Date] AS Date) != @FromDate AND CAST(A.[Date] AS Date) = @ToDate AND CAST(A.[Date] AS Date) != ISNULL(A.HolidayDate,'') THEN @EnddateType
							WHEN @LeaveType != 'Hours' AND CAST(A.[Date] AS Date) != @FromDate AND CAST(A.[Date] AS Date) = @ToDate AND CAST(A.[Date] AS Date) = ISNULL(A.HolidayDate,'') THEN (CASE WHEN A.TimeType = 'AM' THEN 'PM' ELSE 'AM' END)
							WHEN @LeaveType != 'Hours' AND CAST(A.[Date] AS Date) = @FromDate AND CAST(A.[Date] AS Date) != @ToDate AND CAST(A.[Date] AS Date) = ISNULL(A.HolidayDate,'') THEN (CASE WHEN A.TimeType = 'AM' THEN 'PM' ELSE 'AM' END)
							WHEN @LeaveType != 'Hours' AND CAST(A.[Date] AS Date) != @FromDate AND CAST(A.[Date] AS Date) != @ToDate AND CAST(A.[Date] AS Date) != ISNULL(A.HolidayDate,'') THEN 'Full'
							WHEN @LeaveType != 'Hours' AND CAST(A.[Date] AS Date) != @FromDate AND CAST(A.[Date] AS Date) != @ToDate  AND CAST(A.[Date] AS Date) = ISNULL(A.HolidayDate,'') THEN (CASE WHEN A.TimeType = 'AM' THEN 'PM' ELSE 'AM' END)
							ELSE 'Full'
						END AS [Type]
					FROM (SELECT CAST([Date] AS Date) as [Date],HolidayDate,TimeType FROM [dbo].[GetDateRange] (@FromDate,@ToDate,@CompanyId,@EmployeeId)) AS A
					LEFT JOIN [Common].[Attendance] AS B (NOLOCK) ON CAST(A.[Date] as Date) = CAST(B.[Date] AS Date)  AND B.CompanyId = @CompanyId
					LEFT JOIN [Common].[AttendanceDetails] AS C (NOLOCK) ON C.AttendenceId = B.Id AND C.EmployeeId = @EmployeeId
				) AS A
			ORDER BY [Date]
			OPTION (MAXRECURSION 0);
			----------------------------------------------- INSERT UPDATE AND DELETE -----------------------------------------------
			INSERT INTO Common.Attendance (Id, CompanyId, DATE, STATUS) 
			SELECT DISTINCT A.NewAttendanceId,@CompanyId,CAST(A.Date AS Date) as [Date],1
			FROM #AttendanceDates AS A
			WHERE A.AttendanceDate IS NULL AND @IsAttendanceInsert = 1

			INSERT INTO [Common].[AttendanceDetails] (Id, EmployeeId, AttendenceId, UserCreated, CreatedDate, STATUS, EmployeeName, DepartmentId, DesignationId, ServiceEntityId, LeaveApplicationId, AttendanceType,CompanyId,AttendanceDate,DateValue)      
			SELECT DISTINCT NEWID() AS Id,@EmployeeId,A.NewAttendanceId,'System', GETutcDATE(), 1, @Employeename, @DepartmentId, @DesignationId, @EntityId,@LeaveId, 
				CASE 
					WHEN @LeaveType = 'Hours' THEN @SubType 
					WHEN @LeaveType != 'Hours' THEN (@SubType + '(' + [Type] + ')')
				END,
			@CompanyId,convert(DATE, a.Date),(cast ((replace(convert(varchar, a.Date,102),'.','')) as bigint))  
			FROM #AttendanceDates AS A
			WHERE A.AttendanceDate IS NULL AND A.AttendanceDetailsId IS NULL AND @IsAttendanceInsert = 1 AND A.EmployeeId = @EmployeeId

			INSERT INTO [Common].[AttendanceDetails] (Id, EmployeeId, AttendenceId, UserCreated, CreatedDate, STATUS, EmployeeName, DepartmentId, DesignationId, ServiceEntityId, LeaveApplicationId, AttendanceType,CompanyId,AttendanceDate,DateValue)      
			SELECT DISTINCT NEWID() AS Id,@EmployeeId,A.OldAttendanceId,'System', GETutcDATE(), 1, @Employeename, @DepartmentId, @DesignationId, @EntityId,@LeaveId, 
				CASE 
					WHEN @LeaveType = 'Hours' THEN @SubType 
					WHEN @LeaveType != 'Hours' THEN (@SubType + '(' + [Type] + ')')
				END,
			@CompanyId,convert(DATE, a.Date),(cast ((replace(convert(varchar, a.Date,102),'.','')) as bigint))  
			FROM #AttendanceDates AS A
			WHERE A.AttendanceDate IS NOT NULL AND A.AttendanceDetailsId IS NULL AND @IsAttendanceInsert = 1 AND A.EmployeeId = @EmployeeId

			UPDATE A SET 
				A.AttendanceType = B.AttendanceType, 
				A.LeaveApplicationId = B.LeaveApplicationId
			FROM Common.AttendanceDetails AS A
			INNER JOIN(
						SELECT DISTINCT EmployeeId,OldAttendanceId, 
						CASE 
							WHEN @LeaveType = 'Hours' THEN @SubType 
							WHEN @LeaveType != 'Hours' THEN (@SubType + '(' + [Type] + ')')
						END as AttendanceType,
						@LeaveId AS LeaveApplicationId 
						FROM #AttendanceDates AS A
						WHERE  @IsAttendanceInsert = 1
			) AS B ON B.OldAttendanceId = A.AttendenceId AND A.EmployeeId = B.EmployeeId AND A.EmployeeId = @EmployeeId

			DROP TABLE #ExistingRecords
			DROP TABLE #AttendanceDates
		END
	SET @Counter = @Counter+1
END
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
