USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[Sp_CaseSchedulingTransfer]    Script Date: 16-12-2024 9.20.11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE Procedure [dbo].[Sp_CaseSchedulingTransfer]
@FromCaseId Uniqueidentifier,
@ToCaseId Uniqueidentifier
As
Begin
Declare @ScheduleTaskId Uniqueidentifier,
		@EmployeeId Uniqueidentifier,
		@ST_Hours Time(7),
		@ST_IsOverRunHours Time(7),
		@ST_StartDate Datetime2,
		@ST_EndDate Datetime2,
		@DepartmentId Uniqueidentifier,
		@DesignationId Uniqueidentifier,
		@ChargeOutRate nvarchar(max),
		@LevelRank Int,
		@ScheduleId Uniqueidentifier,
		@ScheduleDetailId Uniqueidentifier,
		@From_STHours_Ticks Bigint,
		@From_IsOvrRunHours_Tics Bigint,
		@PlanedCost_Hours Bigint,
		@PlanedCost Decimal(18,7),
		@To_ScheduledetailId Uniqueidentifier,
		@Org_STHours_Tics  BigInt,
		@Org_IsOvrRunHours_Tics Bigint,
		@Updt_ST_Hours time(7),
		@Updt_ST_IsovrRunHrs time(7),
		@Title nvarchar(max),
		@precision Binary(1)=7

--// check Case is saved in schedule or not
	IF Exists (Select * from WorkFlow.Schedule where CaseId=@ToCaseId)
	Begin
--// Get Startdate & Completiondate From ScheduleTask table based on FromCaseid And ToCaseid
Declare @ToCase_StartDate Datetime2,
		@ToCase_CompleteDate Datetime2
Select @ToCase_StartDate=StartDate,@ToCase_CompleteDate=CompletionDate From WorkFlow.Schedule Where CaseId=@FromCaseId
--// Declare the cursor to get employees with in the Fromcaseid	--// Cursor 1
 Declare ScheduleTask_FromCaseid Cursor For
	Select Id,EmployeeId,Hours,IsOverRunHours,StartDate,EndDate,Title from WorkFlow.ScheduleTask Where CaseId=@FromCaseId
	Open ScheduleTask_FromCaseid
	Fetch Next From ScheduleTask_FromCaseid Into @ScheduleTaskId,@EmployeeId,@ST_Hours,@ST_IsOverRunHours,@ST_StartDate,@ST_EndDate,@Title
	While @@FETCH_STATUS=0
	Begin	--// Cursor 1
		Set @ST_StartDate=CONVERT(date,@ST_StartDate)
		Set @From_STHours_Ticks = Cast(SUBSTRING(CAST(REVERSE(CAST(Isnull(@ST_Hours,'00:00:00.0000000') as BINARY(6))) as binary(6)), 1, 5) As bigint)
		Set @From_IsOvrRunHours_Tics=Cast(SUBSTRING(CAST(REVERSE(CAST(Isnull(@ST_IsOverRunHours,'00:00:00.0000000') as BINARY(6))) as binary(6)), 1, 5) As bigint)
		Set @PlanedCost_Hours=@From_STHours_Ticks+@From_IsOvrRunHours_Tics
--// Check the employee exist or not in 
	IF Exists (Select * From HR.EmployeeDepartment Where EmployeeId=@EmployeeId And EffectiveFrom <= @ST_StartDate and (@ST_StartDate <= EffectiveTo  or EffectiveTo is null) )
	Begin	--//Exists Employee  
		Select @DepartmentId=DepartmentId,@DesignationId=DepartmentDesignationId,@ChargeOutRate=ChargeOutRate,@LevelRank=LevelRank
		From HR.EmployeeDepartment 
		Where EmployeeId=@EmployeeId And EffectiveFrom <= @ST_StartDate and (@ST_StartDate <= EffectiveTo  or EffectiveTo is null) 
--// Employee details Match with scheduledetail table data
		Set @ScheduleId=(Select Id from WorkFlow.Schedule where CaseId=@ToCaseId)
		If Exists (Select * From WorkFlow.ScheduleDetail As SD
							Inner Join WorkFlow.Schedule As SC On SC.Id=SD.MasterId
						Where SC.CaseId=@ToCaseId And DepartmentId=@DepartmentId And EmployeeId=@EmployeeId And DesignationId=@DesignationId And Level=@LevelRank And ChargeoutRate=@ChargeOutRate)
		
		Begin	--// Exists SD
		
		Select @To_ScheduledetailId=SD.Id From WorkFlow.ScheduleDetail As SD
							Inner Join WorkFlow.Schedule As SC On SC.Id=SD.MasterId
			Where SC.CaseId=@ToCaseId And DepartmentId=@DepartmentId And EmployeeId=@EmployeeId And DesignationId=@DesignationId And Level=@LevelRank And ChargeoutRate=@ChargeOutRate
		Update WorkFlow.ScheduleDetail Set PlanedHours=PlanedHours+@From_STHours_Ticks,
											IsLocked=Case When (PlanedHours+@From_STHours_Ticks) > 0 Then 1 End,
											PlannedCost=CASE WHEN Cast((PlanedHours+@PlanedCost_Hours)/600000000 As int) >= 60 THEN
	                                               Cast(Cast((PlanedHours+@PlanedCost_Hours)/600000000 As int) / 60 As Varchar) + '.' +
			                                       Case When (Cast((PlanedHours+@PlanedCost_Hours)/600000000 As int) % 60) < 10 Then
				                                   '0'+Cast (Cast ((PlanedHours+@PlanedCost_Hours)/600000000 As int) % 60 As varchar) 
				                                   Else
													Cast(Cast((PlanedHours+@PlanedCost_Hours)/600000000 As int) % 60 As varchar)
													End
													Else
													Cast( Cast ((PlanedHours+@PlanedCost_Hours)/600000000 As int) % 60  As varchar) End * ChargeoutRate,
											StartDate= Case When StartDate Is null Then @ST_StartDate Else Case When StartDate <= @ST_StartDate then StartDate Else @ST_StartDate End End,
											EndDate= Case When EndDate Is null Then @ST_EndDate Else Case When EndDate >= @ST_EndDate then EndDate Else @ST_EndDate End End
											Where Id=@To_ScheduledetailId
--//  Employee details match with scheduletask table data		
		IF Exists (Select * From WorkFlow.ScheduleTask Where CaseId=@ToCaseId And EmployeeId=@EmployeeId And Title=@Title And StartDate=@ST_StartDate)
		Begin	--// Exists ST
		Select @Updt_ST_Hours=Hours,@Updt_ST_IsovrRunHrs=IsOverRunHours From WorkFlow.ScheduleTask Where CaseId=@ToCaseId And EmployeeId=@EmployeeId And StartDate=@ST_StartDate
			--Set @precision=7
			Set @From_STHours_Ticks=Cast(SUBSTRING(CAST(REVERSE(CAST(Isnull(@ST_Hours,'00:00:00.0000000') as BINARY(6))) as binary(6)), 1, 5) As bigint)
			Set @From_IsOvrRunHours_Tics=Cast(SUBSTRING(CAST(REVERSE(CAST(Isnull(@ST_IsOverRunHours,'00:00:00.0000000') as BINARY(6))) as binary(6)), 1, 5) As bigint)
			Set @Org_STHours_Tics=Cast(SUBSTRING(CAST(REVERSE(CAST(Isnull(@Updt_ST_Hours,'00:00:00.0000000') as BINARY(6))) as binary(6)), 1, 5) As bigint)
			Set @Org_IsOvrRunHours_Tics=Cast(SUBSTRING(CAST(REVERSE(CAST(Isnull(@Updt_ST_IsovrRunHrs,'00:00:00.0000000') as BINARY(6))) as binary(6)), 1, 5) As bigint)
			Set @Updt_ST_Hours=CAST(CAST(@precision + CAST(REVERSE(CONVERT(binary(5), (@From_STHours_Ticks+@Org_STHours_Tics))) as binary(5)) as binary(6)) as time(7)) 
			Set @Updt_ST_IsovrRunHrs=CAST(CAST(@precision + CAST(REVERSE(CONVERT(binary(5), (@From_IsOvrRunHours_Tics+@Org_IsOvrRunHours_Tics))) as binary(5)) as binary(6)) as time(7)) 
		Update WorkFlow.ScheduleTask Set Hours=@Updt_ST_Hours, IsOverRunHours=@Updt_ST_IsovrRunHrs,
											IsOverRun=case When @From_IsOvrRunHours_Tics Is not Null Then 1 end
										Where CaseId=@ToCaseId And EmployeeId=@EmployeeId And StartDate=@ST_StartDate
		End	--// Exists ST
--//  Employee details doesn't match with scheduletask table data	
		Else --//	If Not Exist ST
		Insert Into WorkFlow.ScheduleTask(Id,CompanyId,EmployeeId,CaseId,Title,StartDate,EndDate,Hours,IsOverRunHours,IsOverRun,CreatedDate,ScheduleDetailId,Status)
				Select NEWID(),CompanyId,EmployeeId,@ToCaseId,Title,@ST_StartDate,@ST_EndDate,Hours,IsOverRunHours,Case When IsOverRunHours Is not null then 1 End,GETDATE(),@To_ScheduledetailId,Status 
				From WorkFlow.ScheduleTask 
				Where Id=@ScheduleTaskId
		End --// Exists SD
--// Employee details doesn't match with scheduledetail table data
		Else	--//	If Not Exist SD
		Begin --//	If Not Exist SD
		Declare @NewId Uniqueidentifier=Newid()
			Set @ScheduleDetailId=(Select ScheduleDetailId From WorkFlow.ScheduleTask Where Id=@ScheduleTaskId)
			Set @From_STHours_Ticks=Cast(SUBSTRING(CAST(REVERSE(CAST(Isnull(@ST_Hours,'00:00:00.0000000') as BINARY(6))) as binary(6)), 1, 5) As bigint)
			Set @From_IsOvrRunHours_Tics=Cast(SUBSTRING(CAST(REVERSE(CAST(Isnull(@ST_IsOverRunHours,'00:00:00.0000000') as BINARY(6))) as binary(6)), 1, 5) As bigint)
			Set @PlanedCost_Hours=@From_STHours_Ticks+@From_IsOvrRunHours_Tics
			Set @PlanedCost=CASE WHEN Cast(@PlanedCost_Hours/600000000 As int) >= 60 THEN
	                                               Cast(Cast(@PlanedCost_Hours/600000000 As int) / 60 As Varchar) + '.' +
			                                       Case When (Cast(@PlanedCost_Hours/600000000 As int) % 60) < 10 Then
				                                   '0'+Cast (Cast (@PlanedCost_Hours/600000000 As int) % 60 As varchar) 
				                                   Else
													Cast(Cast(@PlanedCost_Hours/600000000 As int) % 60 As varchar)
													End
													Else
													Cast( Cast (@PlanedCost_Hours/600000000 As int) % 60  As varchar) End * cast(@ChargeOutRate As decimal)
		Insert Into WorkFlow.ScheduleDetail (Id,MasterId,DepartmentId,DesignationId,EmployeeId,Level,StartDate,EndDate,PlanedHours,IsLocked,ChargeoutRate,CreatedDate,Status,PlannedCost,ActualCost,IsSystem)
				Select @NewId,@ScheduleId,@DepartmentId,@DesignationId,@EmployeeId,@LevelRank,
				Case When StartDate IS null Then @ST_StartDate Else Case When StartDate<=@ST_StartDate Then StartDate Else @ST_StartDate End End,
				Case When EndDate IS null Then @ST_EndDate Else Case When EndDate>=@ST_EndDate Then EndDate Else @ST_EndDate End End,
				@From_STHours_Ticks,Case When PlanedHours > 0 Then 1 End,@ChargeOutRate,GETDATE(),1,isnull(@PlanedCost,0),0,IsSystem
				From WorkFlow.ScheduleDetail
				Where Id=@ScheduleDetailId
--//  Employee details match with scheduletask table data
		IF Exists (Select * From WorkFlow.ScheduleTask Where CaseId=@ToCaseId And EmployeeId=@EmployeeId And Title=@Title And StartDate=@ST_StartDate)
		Begin	--// Exists ST
		Select @Updt_ST_Hours=Hours,@Updt_ST_IsovrRunHrs=IsOverRunHours From WorkFlow.ScheduleTask Where CaseId=@ToCaseId And EmployeeId=@EmployeeId And StartDate=@ST_StartDate
			Set @From_STHours_Ticks=Cast(SUBSTRING(CAST(REVERSE(CAST(Isnull(@ST_Hours,'00:00:00.0000000') as BINARY(6))) as binary(6)), 1, 5) As bigint)
			Set @From_IsOvrRunHours_Tics=Cast(SUBSTRING(CAST(REVERSE(CAST(Isnull(@ST_IsOverRunHours,'00:00:00.0000000') as BINARY(6))) as binary(6)), 1, 5) As bigint)
			Set @Org_STHours_Tics=Cast(SUBSTRING(CAST(REVERSE(CAST(Isnull(@Updt_ST_Hours,'00:00:00.0000000') as BINARY(6))) as binary(6)), 1, 5) As bigint)
			Set @Org_IsOvrRunHours_Tics=Cast(SUBSTRING(CAST(REVERSE(CAST(Isnull(@Updt_ST_IsovrRunHrs,'00:00:00.0000000') as BINARY(6))) as binary(6)), 1, 5) As bigint)
			Set @Updt_ST_Hours=CAST(CAST(@precision + CAST(REVERSE(CONVERT(binary(5), (@From_STHours_Ticks+@Org_STHours_Tics))) as binary(5)) as binary(6)) as time(7))
			Set @Updt_ST_IsovrRunHrs=CAST(CAST(@precision + CAST(REVERSE(CONVERT(binary(5), (@From_IsOvrRunHours_Tics+@Org_IsOvrRunHours_Tics))) as binary(5)) as binary(6)) as time(7)) 
		Update WorkFlow.ScheduleTask Set Hours=@Updt_ST_Hours, IsOverRunHours=case When @From_IsOvrRunHours_Tics IS NULL Then IsOverRunHours Else @Updt_ST_IsovrRunHrs End,
											IsOverRun=case When @From_IsOvrRunHours_Tics Is not Null Then 1 end
										Where CaseId=@ToCaseId And EmployeeId=@EmployeeId And StartDate=@ST_StartDate
		End	--// Exists ST
--//  Employee details doesn't match with scheduletask table data
		Else --//	IF Not Exist ST
		Insert Into WorkFlow.ScheduleTask(Id,CompanyId,EmployeeId,CaseId,Title,StartDate,EndDate,Hours,IsOverRunHours,IsOverRun,CreatedDate,ScheduleDetailId,Status)
				Select NEWID(),CompanyId,EmployeeId,@ToCaseId,Title,@ST_StartDate,@ST_EndDate,Hours,IsOverRunHours,Case When IsOverRunHours Is not null then 1 End,GETDATE(),@NewId,1 
				From WorkFlow.ScheduleTask 
				Where Id=@ScheduleTaskId
		End --//	If Not Exist SD
--// Removing Tasks of existing caseid
		--Begin --//	Removing Task

		--	Set @From_STHours_Ticks=Cast(SUBSTRING(CAST(REVERSE(CAST(Isnull(@ST_Hours,'00:00:00.0000000') as BINARY(6))) as binary(6)), 1, 5) As bigint)
		--	Set @From_IsOvrRunHours_Tics=Cast(SUBSTRING(CAST(REVERSE(CAST(Isnull(@ST_IsOverRunHours,'00:00:00.0000000') as BINARY(6))) as binary(6)), 1, 5) As bigint)
		--Update WorkFlow.ScheduleDetail Set PlanedHours=PlanedHours-@From_STHours_Ticks,
		--									PlannedCost=CASE WHEN Cast(@PlanedCost_Hours/600000000 As int) >= 60 THEN
	 --                                              Cast(Cast(@PlanedCost_Hours/600000000 As int) / 60 As Varchar) + '.' +
		--	                                       Case When (Cast(@PlanedCost_Hours/600000000 As int) % 60) < 10 Then
		--		                                   '0'+Cast (Cast (@PlanedCost_Hours/600000000 As int) % 60 As varchar) 
		--		                                   Else
		--											Cast(Cast(@PlanedCost_Hours/600000000 As int) % 60 As varchar)
		--											End
		--											Else
		--											Cast( Cast (@PlanedCost_Hours/600000000 As int) % 60  As varchar) End * ChargeoutRate
		--								Where Id=(Select ScheduleDetailId From WorkFlow.ScheduleTask Where Id=@ScheduleTaskId)
		--Delete From WorkFlow.ScheduleTask Where Id=@ScheduleTaskId
		 
		--End --//	Removing Task
	
	End --// Exists Employee 
	Fetch Next From ScheduleTask_FromCaseid Into @ScheduleTaskId,@EmployeeId,@ST_Hours,@ST_IsOverRunHours,@ST_StartDate,@ST_EndDate,@Title
	End	--// Cursor 1 
	Close ScheduleTask_FromCaseid	--// Cursor 1
	Deallocate ScheduleTask_FromCaseid	--// Cursor 1

--// Update Schedule table for Tocaseid
		Begin
		Update WorkFlow.Schedule set StartDate= Case when StartDate IS NULL Then @ToCase_StartDate Else
												Case when StartDate<=@ToCase_StartDate then startdate else @ToCase_StartDate End End,
										CompletionDate=Case when CompletionDate IS NULL Then @ToCase_CompleteDate Else
												Case when CompletionDate>=@ToCase_CompleteDate then startdate else @ToCase_CompleteDate End End
							Where CaseId=@ToCaseId
		
		End

	Declare @From_ScheduleId Uniqueidentifier,
			@To_ScheduleId Uniqueidentifier
	Select @From_ScheduleId=Id from WorkFlow.Schedule where CaseId=@FromCaseId
	Select @To_ScheduleId=Id From WorkFlow.Schedule Where CaseId=@ToCaseId
--// Declare cursor to get scheduledetailid based on from caseid
	Declare @SD_Id Uniqueidentifier,
			@DeptId Uniqueidentifier,
			@DesgId Uniqueidentifier,
			@EmpID Uniqueidentifier,
			@Lvl int,
			@COR decimal(10,2), 
			@StDate datetime2
	Declare ScheduleDtl_CSR cursor For 
			Select Id,DepartmentId,DesignationId,EmployeeId,Level,ChargeoutRate,StartDate 
			From WorkFlow.ScheduleDetail Where MasterId=@From_ScheduleId
	Open ScheduleDtl_CSR
	Fetch next from ScheduleDtl_CSR into @SD_Id,@DeptId,@DesgId,@EmpID,@Lvl,@COR,@StDate
	While @@FETCH_STATUS=0
	Begin
	IF Not Exists (Select * From WorkFlow.ScheduleDetail Where MasterId=@To_ScheduleId And DepartmentId=@DeptId And DesignationId=@DesgId And EmployeeId=@EmpID And Level=@Lvl And ChargeoutRate=@COR ) 
	--Declare @New_Id Uniqueidentifier=newid()
	Insert into WorkFlow.ScheduleDetail (Id,MasterId,DepartmentId,DesignationId,EmployeeId,Level,StartDate,EndDate,PlanedHours,ChargeoutRate,
										FeeAllocationPercentage,FeeAllocation,[Fee RecoveryPercentage],IsLocked,
										Remarks,CreatedDate,Status,PlannedCost,ActualCost,IsSystem)
	Select NEWID(),@To_ScheduleId,@DeptId,@DesgId,@EmpID,@Lvl,@StDate,EndDate,PlanedHours,ChargeoutRate,FeeAllocationPercentage,FeeAllocation,
			[Fee RecoveryPercentage],Case When PlanedHours > 0 then 1 End,Remarks,GETDATE(),Status,Isnull(PlannedCost,0),Isnull(ActualCost,0),IsSystem
	From WorkFlow.ScheduleDetail Where Id=@SD_Id

	Fetch next from ScheduleDtl_CSR into @SD_Id,@DeptId,@DesgId,@EmpID,@Lvl,@COR,@StDate
	End
	Close ScheduleDtl_CSR
	Deallocate ScheduleDtl_CSR

--// Calculating FeeAllocation,Recovery	
	Begin
	Exec [dbo].[SD_Fee_Calculation] @From_ScheduleId,@FromCaseId
	Exec [dbo].[SD_Fee_Calculation] @To_ScheduleId,@ToCaseId
	End
End
Else 
begin
	THROW 50000, 'Please Save Selected Case Schedule',1
End
update WorkFlow.ScheduleDetail  set PlannedCost=0  where PlannedCost is null 
update WorkFlow.ScheduleDetail  set ActualCost=0  where ActualCost is null 
End
GO
