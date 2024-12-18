USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[SP_MoveSchedule]    Script Date: 16-12-2024 9.20.11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


    --CREATE TYPE [dbo].[TempMoveEmployees] AS TABLE(
    --[FromEmployeeId] uniqueIdentifier NOT NULL,
    --[ToEmpStartDate] Datetime NOT NULL)

CREATE PROCEDURE [dbo].[SP_MoveSchedule]  
@CaseId Uniqueidentifier,           
@TempMoveEmployees TempMoveEmployees ReadOnly

AS          
BEGIN           

Declare @ErrMsg Nvarchar(250), 
@EmpName Nvarchar(500) 

BEGIN TRANSACTION
BEGIN TRY
      
DECLARE @TempMoveEmployees2 TABLE( S_NO INT IDENTITY(1,1), [FromEmployeeId] uniqueIdentifier NOT NULL, [ToEmpStartDate] Datetime NOT NULL)

INSERT INTO @TempMoveEmployees2
SELECT * FROM @TempMoveEmployees

DECLARE
	@FromScheduleDtlId Uniqueidentifier, @PlanedHours int, @ScheduleTaskId Uniqueidentifier, @ScheduletaskStartdate DateTime2, @ScheduletaskEnddate DateTime2, 
	@From_STHours int, @From_IsOvrRunHours int, @From_TotalHours int, @IsOverRun Int, @FirstTime Int, @ExistDate DateTime2, @ScheduleId Uniqueidentifier, 
	@Title nvarchar(500), @FirstFromEmpStartDate DateTime2, @DetailStartDate datetime2, @DetailEndDate datetime2, @DetailPlanedhous int, 
	@DetailOverRunhous int, @DetailTotalHours int, @sDetailPlanedhous int, @sDetailOverRunhous int, @sDetailTotalHours int, @CompanyId bigint ,@FromEmpStartDate  DateTime2,  
	@EmpId Uniqueidentifier

Declare
	@DepartMentId Uniqueidentifier, @DeptDesgId Uniqueidentifier, @LevelRank Int,@ChargeOutRate Nvarchar(50),@sdDepartMentId Uniqueidentifier, 
	@sdDeptDesgId Uniqueidentifier,@sdLevelRank Int,@sdChargeOutRate Nvarchar(50), @ToScheduleDtlId Uniqueidentifier, 
	@SDId_ST Uniqueidentifier, @To_STHours int, @To_STIsOvrRunHours int, @To_TotalHours int, @Count Int, @From_STHours_Ticks int, 
	@To_STHours_Tics int, @To_TotalHours_Tics int, @From_IsOvrRunHours_Tics int, @To_STIsOvrRunHours_Tics int, @From_TotalHours_Tics int, 
	@Updt_ST_Hours int, @Updt_ST_IsovrRunHrs int, @Updt_ST_TotalHours int, @precision int=7, @TaskFirstDate datetime2, @PreviousTaskDate datetime2, 
	@DayCount int, @ToCaseScheduleDtlId Uniqueidentifier 

DECLARE @Table  TABLE 
(S_No Int ,FromEmpId uniqueidentifier,Id uniqueidentifier,ScheduleDetailId	uniqueidentifier,StartDate	datetime2,EndDate datetime2,PlannedHours int,
 OverRunHours int, IsOverRun	bit,Task	nvarchar(500), CompanyId BigInt
)

-------================================================== Loop1
DECLARE @EmployeeCount  Int = (SELECT COUNT(*) FROM @TempMoveEmployees2 )
DECLARE @Recount INT = 1

WHILE  @EmployeeCount >= @Recount
BEGIN

SELECT @EmpId = FromEmployeeId, @FromEmpStartDate = ToEmpStartDate
FROM @TempMoveEmployees2 
WHERE S_NO = @Recount 

SET @ScheduleId = (SELECT Id FROM WorkFlow.ScheduleNew (NOLOCK) WHERE CaseId = @CaseId)     
SET @FirstTime = 1
SET @FromEmpStartDate = CONVERT(date,@FromEmpStartDate) ----->> Get @@FromEmpStartDate FROM  @FromEmpStartDate Parameter AND convert date formart 
SET @FirstFromEmpStartDate = @FromEmpStartDate ----->> Get @FirstFromEmpStartDate FROM  @FromEmpStartDate Parameter 

INSERT INTO @Table
	SELECT ROW_NUMBER() OVER (PARTITION BY EmployeeId ORDER BY convert(date,StartDate) ) AS [S_No],
		   EmployeeId,Id,ScheduleDetailId,convert(date,StartDate),convert( date,EndDate),PlannedHours,OverrunHours,IsOverRun,Task,CompanyId
	FROM(
			SELECT DISTINCT 
			EmployeeId,Id,ScheduleDetailId,convert(date,StartDate) AS StartDate,convert( date,EndDate) AS EndDate,PlannedHours,OverrunHours,IsOverRun,Task,CompanyId 
			FROM WorkFlow.ScheduleTaskNew  AS A(NOLOCK)
			INNER JOIN @TempMoveEmployees2 AS B
				ON B.FromEmployeeId = A.EmployeeId
			WHERE caseId = @CaseId AND  
			EmployeeId = @EmpId   AND ScheduleDetailId in ( SELECT id FROM  WorkFlow.ScheduleDetailNew (NOLOCK) WHERE MasterId = @ScheduleId)
		) AS A
---------================================================== Loop2
		DECLARE @EmployeeCount2  Int = (SELECT COUNT(*) FROM @Table )
		DECLARE @Recount2 INT = 1

		WHILE  @EmployeeCount2 >= @Recount2
		BEGIN

		SELECT 
			@EmpId = FromEmpId,@ScheduleTaskId = Id,@FromScheduleDtlId = ScheduleDetailId,@ScheduletaskStartdate = StartDate,
			@ScheduletaskEnddate = EndDate,@From_STHours = PlannedHours,@From_IsOvrRunHours = OverrunHours,@IsOverRun = IsOverRun,@Title = Task,
			@CompanyId = CompanyId
		FROM @Table 
		WHERE S_No = @Recount2

		  IF(@FirstTime=1)
			BEGIN
				SET @TaskFirstDate=@ScheduletaskStartdate 
				SET @DayCount = DATEDIFF(dd,@TaskFirstDate,@ScheduletaskStartdate) 
			 END  
			 IF(@FirstTime=0)
				SET @DayCount = DATEDIFF(dd,@PreviousTaskDate,@ScheduletaskStartdate) 
				SET @FirstTime=0 
				SET @PreviousTaskDate=@ScheduletaskStartdate 
				SET @FromEmpStartDate = DATEADD(dd,@DayCount,@FirstFromEmpStartDate)  
				SET @ScheduletaskStartdate =  [dbo].[CheckDateAvalibility](@FromEmpStartDate,@CaseId,@CompanyId,@EmpId)  
				SET @FirstFromEmpStartDate=@ScheduletaskStartdate 
				SET @FromEmpStartDate=DATEADD(dd,1,@ScheduletaskStartdate)    
  
		------==================================== Checking ToEmployee Is Active or NOT in FROM Employee task satrt date ===================================== 
 
			 SELECT @Count=COUNT(*) FROM HR.EmployeeDepartment (NOLOCK) --WHERE EmployeeId=@ToEmpId --AND EffectiveFrom >= @ScheduletaskStartdate  
			 WHERE EmployeeId=@EmpId AND EffectiveFrom <= @ScheduletaskStartdate AND (@ScheduletaskStartdate <= EffectiveTo  or EffectiveTo is null)  
    
			IF @Count<>0 
			BEGIN 
			 SELECT @DepartMentId=DepartmentId,@DeptDesgId=DepartmentDesignationId,@LevelRank=LevelRank,@ChargeOutRate=ChargeOutRate  
			 FROM HR.EmployeeDepartment (NOLOCK) 
			 WHERE EmployeeId=@EmpId AND EffectiveFrom <= @ScheduletaskStartdate AND (@ScheduletaskStartdate <= EffectiveTo  or EffectiveTo is null)  
  
		------=============================== IF to Employee is active at task start date AND Checking the Toemployee has task on that date ======================================    
			 IF NOT EXISTS (SELECT * FROM WorkFlow.ScheduleTaskNew (NOLOCK) WHERE EmployeeId = @EmpId AND StartDate = @ScheduletaskStartdate  
			 AND Task = @Title AND ScheduleDetailId = @FromScheduleDtlId AND CaseId = @CaseId AND Id = @ScheduleTaskId ) 
		  BEGIN  
		------===================================== IF To Employee Doesn't have task on that date update details with FROM employee ================================= 
			INSERT INTO WorkFlow.ScheduleTaskNew 
			(Id,CompanyId,CaseId,ScheduleDetailId,DepartmentId,DesignationId,EmployeeId,StartDate,EndDate, 
			IsOverRun,PlannedHours,OverRunHours,Task,ChargeoutRate,Remarks,Status,Level,WeekNumber) 
			SELECT 
				NEWID(),CompanyId,@CaseId,@FromScheduleDtlId,@DepartMentId,@DeptDesgId,@EmpId,@ScheduletaskStartdate,@ScheduletaskStartdate, 
				@IsOverRun,PlannedHours,OverrunHours,Task,@ChargeOutRate,Remarks,Status,@LevelRank,DATENAME(WW,@ScheduletaskStartdate)      
			FROM WorkFlow.ScheduleTaskNew (NOLOCK) WHERE Id = @ScheduleTaskId 
 
			DELETE FROM WorkFlow.ScheduleTaskNew WHERE id = @ScheduleTaskId ---AND convert(date,StartDate)<>@ScheduletaskStartdate 
		   END 

		 END 
		  SET @Recount2 = @Recount2 + 1
		END
		---------================================================== Loop2 CLOSE
DELETE FROM @Table

    SET @Recount = @Recount + 1
END

BEGIN 
	DECLARE  @EmpId1 nvarchar(max)	
	SET @EmpId1 = (SELECT STRING_AGG(cast([FromEmployeeId] AS nvarchar(200)), ', ' ) FROM @TempMoveEmployees)     
	Exec [dbo].[SP_UpdateScheduleDetailStartandendDate]   @CaseId,@EmpId1
	Exec [sp_updateIslockFlag] @CaseId 
	Exec [dbo].[sp_updateEmployeedeptIsLockLogFlag] @EmpId1
END 

COMMIT TRANSACTION 
END TRY  


BEGIN CATCH          
	ROLLBACK          
	RAISERROR(@ErrMsg,16,1);                    
END CATCH  


END
GO
