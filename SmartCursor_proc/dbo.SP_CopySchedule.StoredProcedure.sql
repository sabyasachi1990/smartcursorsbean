USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[SP_CopySchedule]    Script Date: 16-12-2024 9.20.11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE Procedure [dbo].[SP_CopySchedule] 
@CompanyId BIGINT,
@FromCaseId Uniqueidentifier,
@ToCaseId Uniqueidentifier,
@FromEmpId Uniqueidentifier,
@ToEmpId Uniqueidentifier,
@FromEmpStartDate  DateTime	
--@ToEmpStartDate DateTime
As
Begin
Declare @ErrMsg Nvarchar(250),
		@EmpName Nvarchar(500)

Begin Transaction
Begin Try
Declare @FromScheduleDtlId Uniqueidentifier,
		@PlanedHours BigInt,
		@ScheduleTaskId Uniqueidentifier,
		@ScheduletaskStartdate DateTime2,
		@From_STHours Time(7),
		@From_IsOvrRunHours Time(7),
		@IsOverRun Int,
		@FirstTime Int,
		@ExistDate DateTime,
		@FromScheduleId Uniqueidentifier,	
		@ScheduleId Uniqueidentifier,
		@Title nvarchar(500),
		@FirstFromEmpStartDate DateTime
		Set @ScheduleId=(Select Id From WorkFlow.Schedule where CaseId=@ToCaseId) -- ToCaseId  Based On ToCaseId
		Set @FromScheduleId=(Select Id From WorkFlow.Schedule where CaseId=@FromCaseId) --- From ScheduleId Based On FromCaseId
		Set @FirstFromEmpStartDate=@FromEmpStartDate
		Set @FirstTime=1
			Set @FromEmpStartDate=CONVERT(date,@FromEmpStartDate)
--//Declare First Cursor to Get ScheduledetailId Of From Employee
	Declare ScheduleDtlId_FromEmpidCsr Cursor For
			Select Id,PlanedHours 
			From WorkFlow.ScheduleDetail Where MasterId=@FromScheduleId And EmployeeId=@FromEmpId
	Open ScheduleDtlId_FromEmpidCsr
	Fetch Next From ScheduleDtlId_FromEmpidCsr Into @FromScheduleDtlId,@PlanedHours
		While @@FETCH_STATUS=0
			Begin  ----1
--//Declare Second Cursor To get Schedule Tasks Of From Employee
	Declare ScheduleTaskCsr Cursor For
			Select Id,StartDate,Hours,IsOverRunHours,IsOverRun,Title From WorkFlow.ScheduleTask Where ScheduleDetailId=@FromScheduleDtlId order by StartDate
			--And StartDate >= @FromEmpStartDate  //Commented by Nagendra
			--set @ScheduletaskStartdate=@FromEmpStartDate
	Open ScheduleTaskCsr
	Fetch Next From ScheduleTaskCsr Into @ScheduleTaskId,@ScheduletaskStartdate,@From_STHours,@From_IsOvrRunHours,@IsOverRun,@Title
		While @@FETCH_STATUS=0
			Begin ----2
			Declare @DepartMentId Uniqueidentifier,
					@DeptDesgId Uniqueidentifier,
					@LevelRank Int,
					@ChargeOutRate Nvarchar(50),
					@ToScheduleDtlId Uniqueidentifier,
					@SDId_ST Uniqueidentifier,
					@To_STHours Time(7),
					@To_STIsOvrRunHours Time(7),
					@Count Int,
					@From_STHours_Ticks Bigint,
					@To_STHours_Tics Bigint,
					@From_IsOvrRunHours_Tics Bigint,
					@To_STIsOvrRunHours_Tics Bigint,
					@Updt_ST_Hours Time(7),
					@Updt_ST_IsovrRunHrs Time(7),
					@precision binary(1)=7,
					@TaskFirstDate datetime,
					@PreviousTaskDate datetime,
					@DayCount int

					if(@FirstTime=1)
					begin
				 Set @TaskFirstDate=@ScheduletaskStartdate
				 	Set @DayCount = DATEDIFF(dd,@TaskFirstDate,@ScheduletaskStartdate)
					end

					 if(@FirstTime=0)
						 Set @DayCount = DATEDIFF(dd,@PreviousTaskDate,@ScheduletaskStartdate)

						 set @FirstTime=0
				 Set @PreviousTaskDate=@ScheduletaskStartdate

				set @FromEmpStartDate = @FirstFromEmpStartDate + @DayCount
					--if(@FirstTime=1)	-- Added By Nagendra For First Time we Should take From date // next Time onwords we taken as scheduler task date 
        set @ScheduletaskStartdate =  [dbo].[CheckDateAvalibility](@FromEmpStartDate,@ToCaseId,@CompanyId,@ToEmpId) 
		Set	@FirstFromEmpStartDate=@ScheduletaskStartdate
		   Set @FromEmpStartDate=DATEADD(dd,1,@ScheduletaskStartdate)
												   
		--								   else    
		--								                       ---@FromEmpStartDate
		--			-- Dates Are availible or not Checking Based on this funcations   --@ScheduletaskStartdate == @FromEmpStartDate
  --      set @ScheduletaskStartdate =  [dbo].[CheckDateAvalibility](@ScheduletaskStartdate,@ToCaseId,@CompanyId,@ToEmpId)      -- With in this Function Recursive Function is Exist

		--set @FirstTime=0

--// Checking ToEmployee Is Active or not in From Employee task satrt date
	--Begin Try
	Select @Count=COUNT(*) From HR.EmployeeDepartment --Where EmployeeId=@ToEmpId --And EffectiveFrom >= @ScheduletaskStartdate 
			--And @ScheduletaskStartdate between EffectiveFrom And Isnull(EffectiveTo,EffectiveFrom)
			Where EmployeeId=@ToEmpId And EffectiveFrom <= @ScheduletaskStartdate and (@ScheduletaskStartdate <= EffectiveTo  or EffectiveTo is null) 

	If @Count<>0
		Begin -- Count
		Select @DepartMentId=DepartmentId,@DeptDesgId=DepartmentDesignationId,@LevelRank=LevelRank,@ChargeOutRate=ChargeOutRate 
		From HR.EmployeeDepartment 
		Where EmployeeId=@ToEmpId And EffectiveFrom <= @ScheduletaskStartdate and (@ScheduletaskStartdate <= EffectiveTo  or EffectiveTo is null) 
			--And @ScheduletaskStartdate between EffectiveFrom And Isnull(EffectiveTo,EffectiveFrom)

--// If to Employee is active at task start date
--// Checking the Toemployee has task on that date
    
		If Exists (Select * from WorkFlow.ScheduleDetail Where EmployeeId=@ToEmpId And DepartmentId=@DepartMentId And ChargeoutRate=@ChargeOutRate
					And DesignationId=@DeptDesgId And Level=@LevelRank And MasterId = @ScheduleId)
			Begin -- IF Exists SD
			Select @ToScheduleDtlId=Id From WorkFlow.ScheduleDetail Where EmployeeId=@ToEmpId And DepartmentId=@DepartMentId 
						And DesignationId=@DeptDesgId And Level=@LevelRank And MasterId = @ScheduleId and ChargeoutRate=@ChargeOutRate
			 
--// If To Employee having task on that date update details with from employee
		
			If Exists (Select * from WorkFlow.ScheduleTask Where EmployeeId=@ToEmpId And StartDate=@ScheduletaskStartdate and CaseId = @ToCaseId and Title=@Title)
				Begin -- IF Exists ST

				Select @SDId_ST=ScheduleDetailId,@To_STHours=Hours,@To_STIsOvrRunHours=IsOverRunHours From WorkFlow.ScheduleTask Where EmployeeId=@ToEmpId And StartDate=@ScheduletaskStartdate and CaseId = @ToCaseId And Title=@Title
				Set @From_STHours_Ticks = Cast(SUBSTRING(CAST(REVERSE(CAST(Isnull(@From_STHours,'00:00:00.0000000') as BINARY(6))) as binary(6)), 1, 5) As bigint)
				Set @From_IsOvrRunHours_Tics=Cast(SUBSTRING(CAST(REVERSE(CAST(Isnull(@From_IsOvrRunHours,'00:00:00.0000000') as BINARY(6))) as binary(6)), 1, 5) As bigint)
				Set @To_STHours_Tics=Cast(SUBSTRING(CAST(REVERSE(CAST(Isnull(@To_STHours,'00:00:00.0000000') as BINARY(6))) as binary(6)), 1, 5) As bigint)
				Set @To_STIsOvrRunHours_Tics=Cast(SUBSTRING(CAST(REVERSE(CAST(Isnull(@To_STIsOvrRunHours,'00:00:00.0000000') as BINARY(6))) as binary(6)), 1, 5) As bigint)
					Begin
					Select @EmpName=FirstName From Common.Employee Where Id=@ToEmpId
					Set @ErrMsg = Concat(@EmpName,' Hours Exceeded ','On ',convert(date,@ScheduletaskStartdate))
					--RAISERROR(@ErrMsg,16,1);

					Set @Updt_ST_Hours=CAST(CAST(@precision + CAST(REVERSE(CONVERT(binary(5), (@From_STHours_Ticks+@To_STHours_Tics))) as binary(5)) as binary(6)) as time(7)) 
					End
				--Set @Updt_ST_Hours=CAST(CAST(@precision + CAST(REVERSE(CONVERT(binary(5), (@From_STHours_Ticks+@To_STHours_Tics))) as binary(5)) as binary(6)) as time(7)) 
				Set @Updt_ST_IsovrRunHrs=CAST(CAST(@precision + CAST(REVERSE(CONVERT(binary(5), (@From_IsOvrRunHours_Tics+@To_STIsOvrRunHours_Tics))) as binary(5)) as binary(6)) as time(7)) 
--// Update Schedule Task table based on conditions 
					
				Update  WorkFlow.ScheduleTask Set Hours=@Updt_ST_Hours,IsOverRunHours=Case When @IsOverRun=1 Then 
														Case When @Updt_ST_IsovrRunHrs Is not null Then @Updt_ST_IsovrRunHrs Else Null End 
														Else Null End,
													ScheduleDetailId=@ToScheduleDtlId,
													IsOverRun=Case When @IsOverRun = 1 Then 1 Else Null End
						Where EmployeeId=@ToEmpId And  StartDate=@ScheduletaskStartdate and CaseId = @ToCaseId and Title=@Title
					
				End -- IF Exists ST
--// If To Employee Doesn't have task on that date update details with from employee
				Else
				Insert Into WorkFlow.ScheduleTask (Id,CompanyId,EmployeeId,CaseId,Title,StartDate,EndDate,Hours,IsOverRun,Remarks,RecOrder,UserCreated,CreatedDate,ModifiedBy,ModifiedDate,
											Status,IsOverRunHours,PBIName,ScheduleDetailId,IsNew,OldId)
				Select NEWID(),CompanyId,@ToEmpId,@ToCaseId,Title,@ScheduletaskStartdate,@ScheduletaskStartdate,Hours,Case When @IsOverRun =1 then 1 End,Remarks,RecOrder,UserCreated,GETDATE(),Null,Null,
											1,Case When @IsOverRun = 1 Then IsOverRunHours Else null End,PBIName,@ToScheduleDtlId,Null,Null
				From WorkFlow.ScheduleTask Where Id=@ScheduleTaskId
			End -- IF Exists SD 
		
--// If To Employee Doesn't have task on that date insert new records in ScheduleDetail 
		 
		
		If Not Exists (Select * from WorkFlow.ScheduleDetail Where EmployeeId=@ToEmpId And DepartmentId=@DepartMentId 
					And DesignationId=@DeptDesgId And Level=@LevelRank And MasterId=@ScheduleId and ChargeoutRate = @ChargeOutRate)
		Begin -- IF Not Exists SD
		Declare @NewSchedId UniqueIdentifier=Newid()
		Insert Into WorkFlow.ScheduleDetail(Id, MasterId, DepartmentId, DesignationId, EmployeeId, Level, StartDate, EndDate, PlanedHours, ChargeoutRate, FeeAllocationPercentage, FeeAllocation, [Fee RecoveryPercentage],
											ActualStartDate, ActualEndDate, ActualHours, Remarks, RecOrder, UserCreated, CreatedDate, ModifiedBy, ModifiedDate, Version, Status, IsLocked, ActualDepartmentId, ActualDesignationId,
											ActualLevel, ActualChargeOutRate, IsPrimaryIncharge, PlannedCost, ActualCost, IsSystem)	
				Select @NewSchedId, @ScheduleId, @DepartMentId, @DeptDesgId, @ToEmpId, @LevelRank, StartDate, EndDate, PlanedHours, @ChargeOutRate, Null, Null, Null,
							Null, Null, Null,Null, Null, UserCreated, GETDATE(), Null, Null, Null, 1, Null, Null, Null,
							Null, Null, Null, Isnull(PlannedCost,0), 0, Null
						From WorkFlow.ScheduleDetail Where Id=@FromScheduleDtlId 
--//Set Islocked to true when inserting a new row into scheduledetail table
		Update HR.EmployeeDepartment Set IsLocked=1 Where EmployeeId=@ToEmpId And DepartmentId=@DepartMentId 
				And DepartmentDesignationId=@DeptDesgId And LevelRank=@LevelRank and ChargeOutRate = @ChargeOutRate

		If Exists (Select * from WorkFlow.ScheduleTask Where EmployeeId=@ToEmpId  And StartDate=@ScheduletaskStartdate and CaseId = @ToCaseId and Title=@Title) 
		
		Begin -- IF Exists ST
			
			Select @SDId_ST=ScheduleDetailId,@To_STHours=Hours,@To_STIsOvrRunHours=IsOverRunHours From WorkFlow.ScheduleTask Where EmployeeId=@ToEmpId And StartDate=@ScheduletaskStartdate and CaseId = @ToCaseId and Title=@Title
				
				Set @From_STHours_Ticks = Cast(SUBSTRING(CAST(REVERSE(CAST(Isnull(@From_STHours,'00:00:00.0000000') as BINARY(6))) as binary(6)), 1, 5) As bigint)
				Set @From_IsOvrRunHours_Tics=Cast(SUBSTRING(CAST(REVERSE(CAST(Isnull(@From_IsOvrRunHours,'00:00:00.0000000') as BINARY(6))) as binary(6)), 1, 5) As bigint)
				Set @To_STHours_Tics=Cast(SUBSTRING(CAST(REVERSE(CAST(Isnull(@To_STHours,'00:00:00.0000000') as BINARY(6))) as binary(6)), 1, 5) As bigint)
				Set @To_STIsOvrRunHours_Tics=Cast(SUBSTRING(CAST(REVERSE(CAST(Isnull(@To_STIsOvrRunHours,'00:00:00.0000000') as BINARY(6))) as binary(6)), 1, 5) As bigint)
					Begin
					Select @EmpName=FirstName From Common.Employee Where Id=@ToEmpId
					Set @ErrMsg = Concat(@EmpName,' Hours Exceeded ','On ',convert(date,@ScheduletaskStartdate))
					--RAISERROR(@ErrMsg,16,1);

					Set @Updt_ST_Hours=CAST(CAST(@precision + CAST(REVERSE(CONVERT(binary(5), (@From_STHours_Ticks+@To_STHours_Tics))) as binary(5)) as binary(6)) as time(7)) 
					End
				--Set @Updt_ST_Hours=CAST(CAST(@precision + CAST(REVERSE(CONVERT(binary(5), (@From_STHours_Ticks+@To_STHours_Tics))) as binary(5)) as binary(6)) as time(7)) 
				Set @Updt_ST_IsovrRunHrs=CAST(CAST(@precision + CAST(REVERSE(CONVERT(binary(5), (@From_IsOvrRunHours_Tics+@To_STIsOvrRunHours_Tics))) as binary(5)) as binary(6)) as time(7)) 
				
				Update  WorkFlow.ScheduleTask Set Hours=@Updt_ST_Hours,IsOverRunHours=Case When @IsOverRun=1 Then 
														Case When @Updt_ST_IsovrRunHrs Is not null Then @Updt_ST_IsovrRunHrs Else Null End 
														Else Null End,
													ScheduleDetailId=@ToScheduleDtlId,
													IsOverRun=Case When @IsOverRun = 1 Then 1 Else Null End
						Where EmployeeId=@ToEmpId And  StartDate=@ScheduletaskStartdate and CaseId = @ToCaseId and Title=@Title
											
		End -- IF Exists ST
		
        Else -- IF Not Exists ST
		Begin -- IF Not Exists ST
		--Nagendra // verify Calenders is *Exists* or *Not*
		--Select @CanlenderDate=   from  Common.Calender   where CompanyId=1091

		--declare @ExistDate as dbo.ChechDateAvalibility(@ScheduletaskStartdate Datetime,@CaseId Uniqueidentifier,@CompanyId BIGINT)

		Insert Into WorkFlow.ScheduleTask (Id,CompanyId,EmployeeId,CaseId,Title,StartDate,EndDate,Hours,IsOverRun,Remarks,RecOrder,UserCreated,CreatedDate,ModifiedBy,ModifiedDate,
											Status,IsOverRunHours,PBIName,ScheduleDetailId,IsNew,OldId)
				Select NEWID(),CompanyId,@ToEmpId,@ToCaseId,Title,StartDate,EndDate,Hours,Case When @IsOverRun = 1 then 1 Else null End,Remarks,RecOrder,UserCreated,GETDATE(),Null,Null,
											1,Case When @IsOverRun = 1 Then IsOverRunHours Else null End,PBIName,@NewSchedId,Null,Null
				From WorkFlow.ScheduleTask Where Id=@ScheduleTaskId
		End -- IF Not Exists ST
		End -- IF Not Exists SD

		End --Count
 --- //// Error throw while exeed day hours
		Begin

		Declare @HT bigint,
				@Exd_Hours Varchar(25),
				@THrs float,
				@ExdHrsDate date
				--@ErrMsg Nvarchar(250),
				--@EmpName Nvarchar(500)
		Declare ExdHrs_CSR Cursor For
		Select Sum(cast(SUBSTRING(CAST(REVERSE(CAST(Isnull(Hours,'00:00:00.0000000') as BINARY(6))) as binary(6)), 1, 5) As bigint)),StartDate From WorkFlow.ScheduleTask 
		Where CaseId=@ToCaseId And EmployeeId=@ToEmpId Group by StartDate order by StartDate
		Open ExdHrs_CSR
		Fetch Next From ExdHrs_CSR Into @HT,@ExdHrsDate
		While @@FETCH_STATUS=0
		Begin
		Select @Exd_Hours=CASE WHEN Cast((@HT)/600000000 As int) >= 60 THEN
	                                               Cast(Cast((@HT)/600000000 As int) / 60 As Varchar) + '.' +
			                                       Case When (Cast((@HT)/600000000 As int) % 60) < 10 Then
				                                   '0'+Cast (Cast ((@HT)/600000000 As int) % 60 As varchar) 
				                                   Else
													Cast(Cast((@HT)/600000000 As int) % 60 As varchar)
													End
													Else
													Cast( Cast ((@HT)/600000000 As int) % 60  As varchar) End
		
		Set @THrs= cast(Substring(@Exd_Hours,1,Isnull(CHARINDEX('.',@Exd_Hours),len(@Exd_Hours)-1)) As float)

		If @THrs>24
		Begin
		Select @EmpName=FirstName From Common.Employee Where Id=@ToEmpId
		 Set @ErrMsg = Concat(@EmpName,' Hours Exceeded ','On ',Convert(Date,@ExdHrsDate))
		 RAISERROR(@ErrMsg,16,1);

		End
		Fetch Next From ExdHrs_CSR Into @HT,@ExdHrsDate
		End
		Close ExdHrs_CSR
		Deallocate ExdHrs_CSR

		End

    Fetch Next From ScheduleTaskCsr Into @ScheduleTaskId,@ScheduletaskStartdate,@From_STHours,@From_IsOvrRunHours,@IsOverRun,@Title

	End ----2
--// Closing Second Cursor
Close ScheduleTaskCsr -- Second Cursor
Deallocate ScheduleTaskCsr -- Second Cursor

	Fetch Next From ScheduleDtlId_FromEmpidCsr Into @FromScheduleDtlId,@PlanedHours

	End ----1
--// Closing First Cursor
Close ScheduleDtlId_FromEmpidCsr -- First Cursor
Deallocate ScheduleDtlId_FromEmpidCsr -- First Cursor

--// Update Islocked Column in ScheduleDetail Table 
Begin
Update WorkFlow.ScheduleDetail Set IsLocked=0 Where PlanedHours=0 or PlanedHours is null
End

--//Declare cursor for calculate planned cost in scheduledetail table 
Declare @SchDtlId Uniqueidentifier,
		--@HourSeconds BigInt,
		--@IsOvrrunSeconds BigInt,
		@StartDate Datetime,
		@EndDate Datetime,
		@HourTics Bigint,
		@IsovrrunTics BigInt

Declare ScheduleDetailTable_Csr Cursor For
		Select distinct sd.Id From WorkFlow.ScheduleDetail As Sd
		Inner Join WorkFlow.ScheduleTask As St on St.ScheduleDetailId=Sd.Id Where Sd.MasterId=@ScheduleId
	Open ScheduleDetailTable_Csr
	Fetch Next From ScheduleDetailTable_Csr Into @SchDtlId
	While @@FETCH_STATUS=0
	Begin

	Select @HourTics=Sum(cast(SUBSTRING(CAST(REVERSE(CAST(Isnull(Hours,'00:00:00.0000000') as BINARY(6))) as binary(6)), 1, 5) As bigint)),
			@IsovrrunTics=Sum(cast(SUBSTRING(CAST(REVERSE(CAST(Isnull(IsOverRunHours,'00:00:00.0000000') as BINARY(6))) as binary(6)), 1, 5) As bigint)),
			@StartDate=MIN(StartDate),@EndDate=MAX(EndDate)
	From WorkFlow.ScheduleTask Where ScheduleDetailId=@SchDtlId
	--Set @HourTics=cast(SUBSTRING(CAST(REVERSE(CAST(@time as BINARY(6))) as binary(6)), 1, 5) As bigint)
	--Set @IsovrrunTics=@IsOvrrunSeconds*1000*10000
	Update WorkFlow.ScheduleDetail Set PlanedHours=@HourTics,
										StartDate=@StartDate,
										EndDate=@EndDate,
										IsLocked=1,
										PlannedCost=CASE WHEN Cast((@HourTics+@IsovrrunTics)/600000000 As int) >= 60 THEN
	                                               Cast(Cast((@HourTics+@IsovrrunTics)/600000000 As int) / 60 As Varchar) + '.' +
			                                       Case When (Cast((@HourTics+@IsovrrunTics)/600000000 As int) % 60) < 10 Then
				                                   '0'+Cast (Cast ((@HourTics+@IsovrrunTics)/600000000 As int) % 60 As varchar) 
				                                   Else
													Cast(Cast((@HourTics+@IsovrrunTics)/600000000 As int) % 60 As varchar)
													End
													Else
													Cast( Cast ((@HourTics+@IsovrrunTics)/600000000 As int) % 60  As varchar) End * ChargeoutRate
													Where Id=@SchDtlId
												

	Fetch Next From ScheduleDetailTable_Csr Into @SchDtlId
	End
	Close ScheduleDetailTable_Csr
	Deallocate ScheduleDetailTable_Csr
	
	Begin
	Exec [dbo].[SD_Fee_Calculation] @ScheduleId,@ToCaseId
	End

	Commit Transaction
	End Try
	Begin Catch
	Rollback
	 RAISERROR(@ErrMsg,16,1);
	 --Select ERROR_MESSAGE()
	End Catch
	update  WorkFlow.scheduletask set  IsOverRunHours='00:00:00.0000000' where IsOverRun =1 and IsOverRunHours is null
	update  workFlow.scheduleDetail   set planedHours=0 where  PlanedHours is null
	update workFlow.scheduleDetail   set FeeAllocationPercentage=0 where  FeeAllocationPercentage is null 
	update workFlow.scheduleDetail   set FeeAllocation=0 where  FeeAllocation is null 
	update workFlow.scheduleDetail   set [Fee RecoveryPercentage] =0 where  [Fee RecoveryPercentage]  is null 
End
GO
