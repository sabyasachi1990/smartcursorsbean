USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[WF_Trainer2TimeLogItem_Insertion]    Script Date: 16-12-2024 9.20.11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE 
   Procedure [dbo].[WF_Trainer2TimeLogItem_Insertion]
@TrainerId Uniqueidentifier,
@TrainingId UniqueIdentifier,
@CompanyId bigint,
@CourseName nvarchar(20),
@TrainingStatus nvarchar(20),
@OldTrainerId uniqueIdentifier
AS
BEGIN
Begin Transaction
Begin Try
if(@OldTrainerId!=@TrainerId)
begin
Declare 
              @CompanyUserId1 bigint
		select  @CompanyUserId1=CompanyUserId from HR.Trainer (NOLOCK) where Id=@OldTrainerId

	 Declare 
				   @EmployeeId1 UniqueIdentifier
				  select @EmployeeId1=Id from common.Employee (NOLOCK) where CompanyId=@CompanyId and UserName in (select UserName from Common.CompanyUser as CU (NOLOCK) join Hr.Trainer as t (NOLOCK) on CU.Id=t.CompanyUserId where CU.Id=@CompanyUserId1)
		 Begin

		Delete From Common.TimeLogItemDetail Where EmployeeId=@EmployeeId1
Delete From Common.TimeLogItem Where SystemId=@TrainingId and Id in (select Id from common.TimeLogItemDetail (NOLOCK) where EmployeeId=@EmployeeId1)
end
end
if(@TrainingStatus='Tentative')
		Begin

Declare @IsExternal bit,
              @CompanyUserId bigint
		select  @IsExternal=IsExternalTrainer,@CompanyUserId=CompanyUserId from HR.Trainer (NOLOCK) where Id=@TrainerId
		if(@IsExternal=0) 
		Begin
		 If  Exists (Select Id From Common.Employee (NOLOCK) Where  CompanyId=@CompanyId and UserName in (select UserName from Common.CompanyUser (NOLOCK) where Id=@CompanyUserId))
		 
		 Begin

		Declare @TrainingDate Date
		select @TrainingDate=TrainingDate from Hr.TrainingSchedule (NOLOCK) where TrainingId=@TrainingId
      
				Declare 
				   @EmployeeId UniqueIdentifier
				  select @EmployeeId=Id from common.Employee (NOLOCK) where CompanyId=@CompanyId and UserName in (select UserName from Common.CompanyUser as CU (NOLOCK) join Hr.Trainer as t (NOLOCK) on CU.Id=t.CompanyUserId where CU.Id=@CompanyUserId)

        Begin
		Declare Trainer_Cursor Cursor for select TrainingDate from Hr.TrainingSchedule (NOLOCK) where TrainingId=@TrainingId

		open Trainer_Cursor
		fetch next from Trainer_Cursor into @TrainingDate
		while @@FETCH_STATUS=0
		Begin
		Declare 
		        @Date Date,
                @NewId Uniqueidentifier,
			   @hours decimal(17,2),
			    @FirstHalfFromTime Time(7),
				@FirstHalfToTime Time(7),
				@FirstHalfTotalHours time(7),
				@SecondHalfFromTime time(7),
				@SecondHalfToTime time(7),
				@SecondHalfTotalHours time(7),
				@totalhours time(7),
                @sethours nvarchar(50)
		select @FirstHalfFromTime= FirstHalfFromTime,@FirstHalfToTime=FirstHalfToTime ,@FirstHalfTotalHours=FirstHalfTotalHours ,@SecondHalfFromTime= SecondHalfFromTime ,@SecondHalfToTime= SecondHalfToTime ,@SecondHalfTotalHours = SecondHalfTotalHours from Hr.TrainingSchedule as TS (NOLOCK) join Hr.Training as TR (NOLOCK) on TS.TrainingId=TR.Id where TR.Id=@TrainingId and TS.TrainingDate=@TrainingDate
		 
	--			Declare @firstminutes decimal(17,2)= Datepart(mi,@FirstHalfTotalHours)
 --set  @firstminutes=@firstminutes/60
	--	Declare @secondminutes decimal(17,2)=Datepart(mi,@SecondHalfTotalHours)
 --set  @secondminutes=@secondminutes/60 

	--	set @hours=Datepart(HH,@FirstHalfTotalHours)+Datepart(HH,@SecondHalfTotalHours)+@firstminutes+@secondminutes

	if(@FirstHalfTotalHours is not null and @SecondHalfTotalHours is not null)
				begin 
	set @totalhours =dateadd(second,datediff(second,0,@FirstHalfTotalHours),@SecondHalfTotalHours)
	end 
	if(@FirstHalfTotalHours is not null and @SecondHalfTotalHours is null)
				begin 
	set @totalhours =@FirstHalfTotalHours
	end 
	if(@FirstHalfTotalHours is null and @SecondHalfTotalHours is not null)
				begin 
	set @totalhours =@SecondHalfTotalHours
	end 

	 set @sethours=LEFT(@totalhours, 5)
set @sethours=REPLACE(@sethours, ':', '.' )
set @hours =CONVERT(DECIMAL(17,2),@sethours)


		
		set @Date=@TrainingDate
	
			Set @NewId=NEWID()
			Begin
			Insert Into Common.TimeLogItem --@TimeLogItem 
								(Id,CompanyId,Type,SubType,ChargeType,SystemType,SystemId,IsSystem,StartDate,EndDate,CreatedDate,Hours, ApplyToAll, Days,FirstHalfFromTime,FirstHalfToTime,FirstHalfTotalHours,SecondHalfFromTime,SecondHalfToTime,SecondHalfTotalHours)
							Values(@NewId,@CompanyId,'Training',@CourseName ,'Non-Chargable','Training',@TrainingId,1,@Date,@Date,GETDATE(),@hours,0,1,@FirstHalfFromTime,@FirstHalfToTime,@FirstHalfTotalHours,@SecondHalfFromTime,@SecondHalfToTime,@SecondHalfTotalHours)
						Insert Into Common.TimeLogItemDetail -- @TimeLogItemDetail 
								(Id,TimeLogItemId,EmployeeId)
						Values(NewId(),@NewId,@EmployeeId)
						end
			fetch next from Trainer_Cursor into @TrainingDate
		end
		Close Trainer_Cursor
		Deallocate Trainer_Cursor
		end
	end
end
end

   else if(@TrainingStatus='Cancelled')
				Begin
				 Delete From Common.TimeLogItemDetail Where TimeLogItemId in (Select id From Common.TimeLogItem (NOLOCK) Where SystemId=@TrainingId)and EmployeeId=@EmployeeId
                   Delete From Common.TimeLogItem Where SystemId=@TrainingId and Id in(select Id from Common.TimeLogItemDetail (NOLOCK) where EmployeeId=@EmployeeId)
				   end
	
Commit Transaction
End Try
Begin Catch
	Rollback;
	Print 'In Catch Block';
	Throw:
End Catch 
End

GO
