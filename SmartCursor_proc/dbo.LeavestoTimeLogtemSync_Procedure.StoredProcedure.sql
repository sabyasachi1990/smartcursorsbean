USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[LeavestoTimeLogtemSync_Procedure]    Script Date: 16-12-2024 9.20.10 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE  PROCEDURE [dbo].[LeavestoTimeLogtemSync_Procedure] (@LeaveApplicationId Nvarchar(Max), @CompanyId BigInt)

AS
BEGIN

Begin Transaction
BEGIN TRY


DECLARE @LeaveApplicationIdTable Table (Sno int, LeaveApplicationId Uniqueidentifier)

INSERT INTO @LeaveApplicationIdTable
SELECT ROW_NUMBER() OVER (ORDER BY TRIM(value)) as SNo,TRIM(value) AS LeaveApplicationId FROM STRING_SPLIT(@LeaveApplicationId, ',') WHERE LTRIM(RTRIM(value)) <> ''

	------>>> Variables to Capture data to insert and make calculations
	DECLARE
	@Counter Int = 1,@MaxLimit Int,@NewId Uniqueidentifier, @SubType NVARCHAR(100), @LeaveId Uniqueidentifier,      
	@LeaveType nvarchar(10),@LeaveApplicationHours float,@TimelogitemHours float, @Employeename NVARCHAR(200), 
	@DepartmentId Uniqueidentifier,@DesignationId Uniqueidentifier, @EntityId bigint,@IsWFSync Bit,
	@IsAttendanceSync Bit,@IsTimeLogInsert bit = 0,@IsAttendanceInsert Bit = 0,@SystemSubTypeStatus nvarchar(20) ,
	@FromDate datetime2, @ToDate datetime2, @EmployeeId uniqueidentifier, @Startdatetype nvarchar(10), @EnddateType nvarchar(10)

	CREATE TABLE #NewRecords 
	( 
		Id	uniqueidentifier, CompanyId	bigint, [Type] nvarchar(40), SubType nvarchar(100), ChargeType	nvarchar(20),
		SystemType	nvarchar(20), SystemId	uniqueidentifier, IsSystem	bit, StartDate	datetime2, EndDate	datetime2,
		CreatedDate	datetime2, [Hours] decimal(17,2), ApplyToAll bit, [Days] decimal(17,2), UserCreated	nvarchar(254), 
		SystemSubTypeStatus	nvarchar(20),HolidayDate date,TimeType nvarchar(10),NewRankOrder Int,
		AttendanceId uniqueidentifier
	);


SELECT @MaxLimit = COUNT(SNo) FROM @LeaveApplicationIdTable;

WHILE @Counter <= @MaxLimit
BEGIN

SELECT @LeaveId = LeaveApplicationId FROM @LeaveApplicationIdTable WHERE Sno = @Counter

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

	IF @IsTimeLogInsert = 1
	BEGIN
		----->>> Existing Id's in TimeLogItem table to update, delete and insert
		SELECT * INTO #ExistingRecords 
		FROM(
				SELECT Id,SystemId,StartDate,EndDate,ROW_NUMBER()OVER (ORDER BY StartDate ASC,EndDate DESC) AS ExistingRankOrder
				FROM Common.TimeLogItem (NOLOCK) WHERE SystemId = @LeaveId
			) AS A
		ORDER BY StartDate

		INSERT INTO #NewRecords
		SELECT DISTINCT Id,CompanyId,Type,SubType,ChargeType,SystemType,SystemId,IsSystem,StartDate,EndDate,CreatedDate,Hours, ApplyToAll, ISNULL((Hours/8),0) as Days,
		UserCreated,SystemSubTypeStatus,HolidayDate,TimeType,NewRankOrder,AttendanceId 
		FROM (
			SELECT DISTINCT @EmployeeId AS EmployeeId,NEWID() AS Id,@CompanyId as CompanyId,'Leaves' as Type,@SubType as SubType,'Non-Available' as  ChargeType,
			'LeaveApplication' as SystemType,@LeaveId as SystemId,1 as IsSystem,A.Date as StartDate,A.Date as EndDate,GETDATE()CreatedDate,
					CASE 
						 WHEN @LeaveType ='Hours' THEN @LeaveApplicationHours
						 WHEN A.[Date] = @FromDate AND A.[Date] = @ToDate  AND @StartDateType = 'AM' AND @EndDateType = 'AM' THEN (CASE WHEN A.[Date] = ISNULL(A.HolidayDate,'') AND A.TimeType = 'AM' THEN (4-A.Hours) ELSE 4  END)
						 WHEN A.[Date] = @FromDate AND A.[Date] = @ToDate  AND @StartDateType = 'PM' AND @EndDateType = 'PM' THEN (CASE WHEN A.[Date] = ISNULL(A.HolidayDate,'') AND A.TimeType = 'PM' THEN (4-A.Hours) ELSE 4  END)
						 WHEN A.[Date] = @FromDate AND A.[Date] = @ToDate  AND @StartDateType = 'Full' AND @EndDateType = 'Full' THEN (CASE WHEN A.[Date] = ISNULL(A.HolidayDate,'') THEN 8-A.Hours ELSE 8  END)
						 WHEN A.[Date] = @FromDate AND A.[Date] = @ToDate  AND @StartDateType = 'Full' AND @EndDateType IN ('AM','PM') THEN 0
						 WHEN A.[Date] = @FromDate AND A.[Date] = @ToDate  AND @StartDateType = 'PM' AND @EndDateType IN ('AM','Full') THEN 0
						 WHEN A.[Date] = @FromDate AND A.[Date] = @ToDate  AND @StartDateType = 'AM' AND @EndDateType IN ('PM','Full') THEN 0
						 WHEN A.[Date] = @FromDate AND A.[Date] != @ToDate AND @StartDateType = 'AM' THEN (CASE WHEN A.[Date] = ISNULL(A.HolidayDate,'') THEN 8-A.Hours ELSE 8  END)
						 WHEN A.[Date] = @FromDate AND A.[Date] != @ToDate AND @StartDateType = 'Full' THEN (CASE WHEN A.[Date] = ISNULL(A.HolidayDate,'') THEN 8-A.Hours ELSE 8  END)
						 WHEN A.[Date] = @FromDate AND A.[Date] != @ToDate AND @StartDateType = 'PM' THEN (CASE WHEN A.[Date] = ISNULL(A.HolidayDate,'') AND A.TimeType = 'PM' THEN 4-(A.Hours/8) ELSE 4 END)
						 WHEN A.[Date] != @FromDate AND A.[Date] = @ToDate AND @EndDateType = 'AM' THEN (CASE WHEN A.[Date] = ISNULL(A.HolidayDate,'') AND A.TimeType = 'AM' THEN 4-A.Hours ELSE 4  END)
						 WHEN A.[Date] != @FromDate AND A.[Date] = @ToDate AND @EndDateType = 'Full' THEN (CASE WHEN A.[Date] = ISNULL(A.HolidayDate,'') THEN 8-A.Hours ELSE 8  END)
						 WHEN A.[Date] != @FromDate AND A.[Date] = @ToDate AND @EndDateType = 'PM' THEN (CASE WHEN A.[Date] = ISNULL(A.HolidayDate,'') AND A.TimeType = 'PM' THEN 8-A.Hours ELSE 8  END)
						 WHEN A.[Date] != @FromDate AND A.[Date] != @ToDate THEN (CASE WHEN A.[Date] = ISNULL(A.HolidayDate,'') THEN 8-A.Hours ELSE 8  END)
						 ELSE 8
					END AS [Hours],
					0 as ApplyToAll, 
					'System' UserCreated,@SystemSubTypeStatus as SystemSubTypeStatus,HolidayDate,TimeType,ROW_NUMBER()OVER (ORDER BY A.[Date] ASC) AS NewRankOrder,
					NEWID() AS AttendanceId
			FROM (SELECT CAST([Date] AS Date) as [Date], HolidayDate,TimeType,ISNULL([Hours],0.00) AS [Hours] FROM [dbo].[GetDateRange] (@FromDate,@ToDate,@CompanyId,@EmployeeId)) AS A
			) AS A
			OPTION (MAXRECURSION 0);

		------------------------------------------- TimeLogItem -------------------------------------------
		----->>> Insert Into TimeLogITem
		INSERT INTO Common.TimeLogItem (Id,CompanyId,Type,SubType,ChargeType,SystemType,SystemId,IsSystem,StartDate,EndDate,CreatedDate,Hours, ApplyToAll, Days,UserCreated,SystemSubTypeStatus)
		SELECT DISTINCT 
			A.Id, A.CompanyId, A.[Type] ,A.SubType, A.ChargeType, A.SystemType, A.SystemId	,A. IsSystem, A.StartDate, A.EndDate, 
			A.CreatedDate, A. [Hours], A.ApplyToAll, A.[Days], A.UserCreated, A.SystemSubTypeStatus
		FROM #NewRecords AS A
		FULL JOIN  #ExistingRecords AS B
		ON B.ExistingRankOrder = A.NewRankOrder
		WHERE B.ExistingRankOrder IS NULL AND @IsTimeLogInsert=1

		----->>> Update TimeLogITem
		UPDATE A SET
			A.Type = B.Type, A.SubType = B.SubType, A.ChargeType = B.ChargeType, A.SystemType = B.SystemType, A.SystemId = B.SystemId ,
			A.IsSystem = B.IsSystem, A.ApplyToAll = B.ApplyToAll, A.StartDate = B.StartDate , A.EndDate = B.EndDate ,
			A.Hours = B.Hours, A.Days = B.Days, A.SystemSubTypeStatus = B.SystemSubTypeStatus
		FROM Common.TimeLogItem AS A
		JOIN (
				SELECT DISTINCT B.Id, A.CompanyId, A.[Type] ,A.SubType, A.ChargeType, A.SystemType, A.SystemId	,A.IsSystem, A.StartDate, A.EndDate, 
					A.CreatedDate,A.[Hours], A.ApplyToAll, A.[Days], A.UserCreated, A.SystemSubTypeStatus
				FROM #NewRecords AS A
				 JOIN  #ExistingRecords AS B
				ON B.ExistingRankOrder = A.NewRankOrder AND @IsTimeLogInsert=1  
		) AS B ON B.Id = A.Id

		----->>> Delete TimeLogItemDetail Records
		DELETE FROM Common.TimeLogItemDetail
		WHERE TimeLogItemId IN(
									SELECT DISTINCT B.Id
									FROM #NewRecords AS A
									FULL JOIN  #ExistingRecords AS B
									ON B.ExistingRankOrder = A.NewRankOrder
									WHERE A.Id IS NULL  AND @IsTimeLogInsert=1
								)

		----->>> Delete TimeLogItem Records
		DELETE FROM Common.TimeLogItem
		WHERE Id IN(
						SELECT B.Id
						FROM #NewRecords AS A
						FULL JOIN  #ExistingRecords AS B
						ON B.ExistingRankOrder = A.NewRankOrder
						WHERE A.Id IS NULL  AND @IsTimeLogInsert=1
					)

		----->>> Insert Into TimeLogITemDetail
		INSERT INTO Common.TimeLogItemDetail  (Id, TimeLogItemId, EmployeeId)
		SELECT DISTINCT NEWID() AS Id,A.Id as TimeLogItemId, @EmployeeId as EmployeeId
		FROM #NewRecords AS A
		FULL JOIN  #ExistingRecords AS B
		ON B.ExistingRankOrder = A.NewRankOrder
		WHERE B.ExistingRankOrder IS NULL AND @IsTimeLogInsert=1   
	
DECLARE @TimeLogItemIds Nvarchar(max)

SET @TimeLogItemIds = (	
						SELECT STRING_AGG ( id, ',' ) 
						FROM (
							SELECT DISTINCT CAST(A.Id AS NVARCHAR(100)) AS Id
							FROM #NewRecords AS A
							FULL JOIN  #ExistingRecords AS B
							ON B.ExistingRankOrder = A.NewRankOrder
							WHERE B.ExistingRankOrder IS NULL AND @IsTimeLogInsert=1

							UNION ALL

							SELECT DISTINCT CAST(B.Id AS NVARCHAR(100)) AS Id
							FROM #NewRecords AS A
								JOIN  #ExistingRecords AS B
							ON B.ExistingRankOrder = A.NewRankOrder AND @IsTimeLogInsert=1 
							) AS S
						)

--PRINT @TimeLogItemIds
	Exec [dbo].[UpdateAuditSyncing] @LeaveId, @TimeLogItemIds,'Success',@SystemSubTypeStatus,null,null,null,null,null,'HR Leaves','WF TimeLog'

SET @TimeLogItemIds = NULL

		DROP TABLE #ExistingRecords
		TRUNCATE TABLE #NewRecords
	END
	SET @Counter = @Counter+1

	TRUNCATE TABLE #NewRecords
END 

DROP TABLE #NewRecords

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

	    Exec [dbo].[UpdateAuditSyncing] @LeaveApplicationId, null,'Failed',@SystemSubTypeStatus,'Critical',null,'TimeLog Syncing Failed',@ErrorMessage,@LeaveApplicationId,'HR Leaves','WF TimeLog'
			RAISERROR (@ErrorMessage,@ErrorSeverity,@ErrorState);
		END CATCH
END
GO
