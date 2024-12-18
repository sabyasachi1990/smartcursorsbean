USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[WF_TrainingAttendence2TimeLogItem_Insertion]    Script Date: 16-12-2024 9.20.11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE 
 Procedure [dbo].[WF_TrainingAttendence2TimeLogItem_Insertion]
 @TrainingId uniqueIdentifier
 AS
BEGIN
Begin Transaction
Begin Try

		declare @EmployeeId uniqueIdentifier,
		@AttendanceDate DateTime
		         select @EmployeeId=EmployeeId,@AttendanceDate=AttendanceDate from HR.TrainingAttendance (NOLOCK) where TrainingId=@TrainingId
			  Declare Trainer_Cursor Cursor for select EmployeeId,AttendanceDate from Hr.TrainingAttendance (NOLOCK) where TrainingId=@TrainingId		

		open Trainer_Cursor
		fetch next from Trainer_Cursor into @EmployeeId, @AttendanceDate
		while @@FETCH_STATUS=0
		Begin

		 Declare 
	           @Date DateTime,
			   @hours decimal(17,2),
			   @newId UniqueIdentifier,
	           @FirstHalfFromTime Time(7),
				@FirstHalfToTime Time(7),
				@FirstHalfTotalHours time(7),
				@SecondHalfFromTime time(7),
				@SecondHalfToTime time(7),
				@SecondHalfTotalHours time(7),	
				@FirstHalfTotalHours1 decimal(17,2),
				@SecondHalfTotalHours1 decimal(17,2),
				@totalhours time(7),
                @sethours nvarchar(50),
				@setFirsthours nvarchar(50),
				@setSecondhours nvarchar(50)
		
                
		select @FirstHalfFromTime= FirstHalfFromTime,@FirstHalfToTime=FirstHalfToTime ,@FirstHalfTotalHours=FirstHalfTotalHours ,@SecondHalfFromTime= SecondHalfFromTime ,@SecondHalfToTime= SecondHalfToTime ,@SecondHalfTotalHours = SecondHalfTotalHours  from Hr.TrainingSchedule as TS (NOLOCK) join Hr.Training as TR (NOLOCK) on TS.TrainingId=TR.Id where TS.TrainingId=@TrainingId and TrainingDate=@AttendanceDate

				Declare   @AmAttended bit,
		          @PmAttended bit 
		      select @AmAttended= AMAttended ,@PmAttended=PMAttended From HR.TrainingAttendance as TA (NOLOCK) Join HR.Training as TR (NOLOCK) on Ta.TrainingId=TR.Id Where Ta.TrainingId=@TrainingId and AttendanceDate=@AttendanceDate and EmployeeId=@EmployeeId

	--	Declare @firstminutes decimal(17,2)= Datepart(mi,@FirstHalfTotalHours)
 --set  @firstminutes=@firstminutes/60
	--	Declare @secondminutes decimal(17,2)=Datepart(mi,@SecondHalfTotalHours)
 --set  @secondminutes=@secondminutes/60 

 --set @FirstHalfTotalHours1=Datepart(HH,@FirstHalfTotalHours)+@firstminutes
 --set @SecondHalfTotalHours1=Datepart(HH,@SecondHalfTotalHours)+@secondminutes

	--	set @hours=Datepart(HH,@FirstHalfTotalHours)+Datepart(HH,@SecondHalfTotalHours)+@firstminutes+@secondminutes

			set @totalhours =dateadd(second,datediff(second,0,@FirstHalfTotalHours),@SecondHalfTotalHours)

	 set @sethours=LEFT(@totalhours, 5)
set @sethours=REPLACE(@sethours, ':', '.' )
set @hours =CONVERT(DECIMAL(17,2),@sethours)
set @setFirsthours=LEFT(@FirstHalfTotalHours, 5)
set @setFirsthours=REPLACE(@setFirsthours, ':', '.' )
set @FirstHalfTotalHours1=CONVERT(DECIMAL(17,2),@setFirsthours)
set @setSecondhours=LEFT(@SecondHalfTotalHours, 5)
set @setSecondhours=REPLACE(@setSecondhours, ':', '.' )
set @SecondHalfTotalHours1=CONVERT(DECIMAL(17,2),@setSecondhours)


		set @Date=@AttendanceDate
	
			Set @NewId=NEWID()
			Begin
			If (@AmAttended=1 and (@PmAttended=0 or @PmAttended is null))

					BEGIN
					
						update Common.TimeLogItem set FirstHalfToTime=@FirstHalfToTime ,FirstHalfFromTime=@FirstHalffromTime ,FirstHalfTotalHours=@FirstHalfTotalHours,Hours=@FirstHalfTotalHours1  from common.TimeLogItem as TL (NOLOCK) join Common.TimeLogItemDetail as TLD (NOLOCK) on TL.Id=TLD.TimeLogItemId  where TL.SystemId=@TrainingId and TLD.EmployeeId=@EmployeeId and TL.StartDate=@Date
						
					End

				else	If (@AmAttended=1 and @PmAttended=1)
					BEGIn
						
						update Common.TimeLogItem set FirstHalfToTime=@FirstHalfToTime ,FirstHalfFromTime=@FirstHalffromTime ,FirstHalfTotalHours=@FirstHalfTotalHours,
						SecondHalfFromTime= @SecondHalfFromTime,SecondHalfToTime=@SecondHalfToTime,SecondHalfTotalHours=@SecondHalfTotalHours,Hours=@hours  from common.TimeLogItem as TL (NOLOCK) join Common.TimeLogItemDetail as TLD (NOLOCK) on TL.Id=TLD.TimeLogItemId  where TL.SystemId=@TrainingId and TLD.EmployeeId=@EmployeeId and TL.StartDate=@Date
					End
					
			   else   If ((@AmAttended=0 or @AmAttended is null) and @PmAttended=1)
					BEGIN
						update Common.TimeLogItem set SecondHalfToTime=@SecondHalfToTime ,SecondHalfFromTime=@SecondHalffromTime ,SecondHalfTotalHours=@secondHalfTotalHours,Hours=@SecondHalfTotalHours1
 from common.TimeLogItem as TL (NOLOCK) join Common.TimeLogItemDetail as TLD (NOLOCK) on TL.Id=TLD.TimeLogItemId  where TL.SystemId=@TrainingId and TLD.EmployeeId=@EmployeeId and TL.StartDate=@Date
						
					End
			End

		fetch next from Trainer_Cursor into @EmployeeId,@AttendanceDate
		end
		Close Trainer_Cursor
		Deallocate Trainer_Cursor

Commit Transaction
End Try
Begin Catch
	Rollback;

	Print 'In Catch Block';

	Throw:

End Catch 
End



GO
