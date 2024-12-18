USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[WF_Taining_Timelog_Migration]    Script Date: 16-12-2024 9.20.11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



Create  
 Procedure [dbo].[WF_Taining_Timelog_Migration]
@TrainerId uniqueIdentifier,
@TrainingId UniqueIdentifier,
@CompanyId bigint,
@CourseName nvarchar(500),
@TrainerIds nvarchar(max)
AS
BEGIN
Begin Transaction
Begin Try

create table #Companyuser_Tbl(S_No INT Identity(1, 1),IsExternalTrainer bit,CompanyUserId bigint)
if(@TrainerId is null or @TrainerId = (select CAST(0x0 AS UNIQUEIDENTIFIER)))
Begin
set @TrainerId = (select T.TrainerId from HR.Training as T join HR.Trainer as TR on T.TrainerId=TR.Id where T.Id = @TrainingId)
End
if(@CourseName is null or @CourseName = '')
Begin
set @CourseName = (select c.CourseName from HR.Training as T join HR.CourseLibrary as c on T.CourseLibraryId=c.Id  where T.Id = @TrainingId)
End
Declare @StartDate Date
select @StartDate=StartDate from common.TimeLogItem where SystemId=@TrainingId and CompanyId=@CompanyId
 begin
	Declare TImeLog_Cursor Cursor for select StartDate from Common.TimeLogItem where SystemId=@TrainingId /*and SubType=@CourseName*/

		open TImeLog_Cursor
		fetch next from TImeLog_Cursor into @StartDate
		while @@FETCH_STATUS=0
		Begin
		update common.Attendancedetails set trainingid= null where trainingid in (Select id From Common.TimeLogItem Where SystemId=@TrainingId and StartDate=@StartDate)

		Delete From Common.TimeLogItemDetail Where TimeLogItemId in (Select id From Common.TimeLogItem Where SystemId=@TrainingId and Convert (date,StartDate)= Convert (date,@StartDate))
Delete From Common.TimeLogItem Where SystemId=@TrainingId and Convert (date,StartDate)= Convert (date,@StartDate)

fetch next from TImeLog_Cursor into @StartDate
		end
		Close TImeLog_Cursor
		Deallocate TImeLog_Cursor
end

Begin

Declare @TrainingStatus nvarchar(20)
select @TrainingStatus=TrainingStatus from Hr.Training where Id=@TrainingId

   if(@TrainingStatus='Tentative' or @TrainingStatus='Confirmed' or @TrainingStatus='Completed' or @TrainingStatus='Cancelled')
		Begin
		
Declare @IsExternal bit,
              @CompanyUserId bigint,
			  @CompanyUserCount int,
			  @Recount int

			  insert into #Companyuser_Tbl
			  select IsExternalTrainer,CompanyUserId from HR.Trainer where (CAST (Id  AS NVARCHAR(max)) in ( select items from dbo.SplitToTable(@TrainerIds,',')))
			  set @CompanyUserCount = (SELECT Count(*)
		FROM #Companyuser_Tbl)
		set @Recount=1
		WHILE @CompanyUserCount >= @Recount--parvathi
		begin


		select  @IsExternal=IsExternalTrainer,@CompanyUserId=CompanyUserId from #Companyuser_Tbl where S_No=@Recount
		if(@IsExternal=0) 
		Begin
		 If  Exists (Select Id From Common.Employee Where  CompanyId=@CompanyId and UserName in (select UserName from Common.CompanyUser where Id=@CompanyUserId))
		 
		 Begin

		Declare @TrainingDate Date
		select @TrainingDate=TrainingDate from Hr.TrainingSchedule where TrainingId=@TrainingId
      
				Declare 
				   @EmployeeId UniqueIdentifier
				  select @EmployeeId=Id from common.Employee where CompanyId=@CompanyId and UserName in (select UserName from Common.CompanyUser as CU join Hr.Trainer as t on CU.Id=t.CompanyUserId where CU.Id=@CompanyUserId)

        Begin
		Declare Trainer_Cursor Cursor for select TrainingDate from Hr.TrainingSchedule where TrainingId=@TrainingId

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
                @sethours nvarchar(50),
				@Aid uniqueidentifier
				--@TrainingDate datetime2
                
		select @FirstHalfFromTime= FirstHalfFromTime,@FirstHalfToTime=FirstHalfToTime ,@FirstHalfTotalHours=FirstHalfTotalHours ,@SecondHalfFromTime= SecondHalfFromTime ,@SecondHalfToTime= SecondHalfToTime ,@SecondHalfTotalHours = SecondHalfTotalHours from Hr.TrainingSchedule as TS join Hr.Training as TR on TS.TrainingId=TR.Id where TR.Id=@TrainingId and TS.TrainingDate=@TrainingDate
		 
	--			Declare @firstminutes decimal(17,2)= Datepart(mi,@FirstHalfTotalHours)
 --set  @firstminutes=@firstminutes/60
	--	Declare @secondminutes decimal(17,2)=Datepart(mi,@SecondHalfTotalHours)
 --set  @secondminutes=@secondminutes/60 

	--	set @hours=Datepart(HH,@FirstHalfTotalHours)+Datepart(HH,@SecondHalfTotalHours)+@firstminutes+@secondminutes 
		set @totalhours =dateadd(second,datediff(second,0,@FirstHalfTotalHours),@SecondHalfTotalHours)

	 set @sethours=LEFT(@totalhours, 5)
set @sethours=REPLACE(@sethours, ':', '.' )
set @hours =CONVERT(DECIMAL(17,2),@sethours)
		set @Date=@TrainingDate
	
			Set @NewId=NEWID()
			set @Aid=NEWID()
			Begin
			Insert Into Common.TimeLogItem --@TimeLogItem 
								(Id,CompanyId,Type,SubType,ChargeType,SystemType,SystemId,IsSystem,StartDate,EndDate,CreatedDate,Hours, ApplyToAll, Days,FirstHalfFromTime,FirstHalfToTime,FirstHalfTotalHours,SecondHalfFromTime,SecondHalfToTime,SecondHalfTotalHours)
							Values(@NewId,@CompanyId,'Training',@CourseName ,'Non-Chargable','Training',@TrainingId,1,@Date,@Date,GETDATE(),@hours,0,1,@FirstHalfFromTime,@FirstHalfToTime,@FirstHalfTotalHours,@SecondHalfFromTime,@SecondHalfToTime,@SecondHalfTotalHours)
						Insert Into Common.TimeLogItemDetail -- @TimeLogItemDetail 
								(Id,TimeLogItemId,EmployeeId)
						Values(NewId(),@NewId,@EmployeeId)
						if exists (select * from common.Attendancedetails as ad join common.Attendance as a on a.id = ad.AttendenceId where a.date = @Date and employeeid=@EmployeeId)
		BEGIN
			update ad set ad.TrainingId=@NewId from common.Attendancedetails as ad join common.Attendance as a on a.id = ad.AttendenceId where a.date = @Date and employeeid=@EmployeeId
		END
		ELSE
		Begin 
			if exists (select * from common.Attendance where companyid=@companyid and date =@Date)
			BEGIN
				insert common.AttendanceDetails(id,AttendenceId,EmployeeId,EmployeeName,TrainingId,CompanyId,AttendanceDate,DateValue)
				values(NEWID(),(select id from common.Attendance where companyid=@companyid and date =@Date),@EmployeeId,(select FirstName from Common.Employee where id=@EmployeeId),@NewId,@CompanyId,@Date,(cast ((replace(convert(varchar, @Date,102),'.','')) as bigint)))
			END
			ELSE
			BEGIN

				insert Common.Attendance(id,CompanyId,Date,Status)
				VALUES (@Aid,@CompanyId,@Date,1)

				insert common.AttendanceDetails(id,AttendenceId,EmployeeId,EmployeeName,TrainingId,CompanyId,AttendanceDate,DateValue)
				values(NEWID(),@Aid,@EmployeeId,(select FirstName from Common.Employee where id=@EmployeeId),@NewId,@CompanyId,@Date,(cast ((replace(convert(varchar, @Date,102),'.','')) as bigint)))
			END
			END
						end
			fetch next from Trainer_Cursor into @TrainingDate
		end
		Close Trainer_Cursor
		Deallocate Trainer_Cursor
		end
	end
end

set @Recount=@Recount+1
--truncate table Companyuser_Tbl
end

IF OBJECT_ID(N'tempdb..#Companyuser_Tbl') IS NOT NULL
BEGIN
DROP TABLE #Companyuser_Tbl
END

end
end

Begin

		Begin

		Declare 
		        @Date1 Date,
				@EmployeeId1 uniqueIdentifier,
                @NewId1 Uniqueidentifier,
				@AttendanceDate date,
				@Aid1 uniqueidentifier
                
		select @EmployeeId1=TS.EmployeeId,@AttendanceDate=TS.AttendanceDate from Hr.TrainingAttendance as TS join Hr.Training as TR  on TS.TrainingId=TR.Id  where TS.TrainingId=@TrainingId
		Declare Training_Cursor Cursor for select TS.EmployeeId,TS.AttendanceDate from Hr.TrainingAttendance as TS join Hr.Training as TR  on TS.TrainingId=TR.Id  where TS.TrainingId=@TrainingId

		open Training_Cursor
		fetch next from Training_Cursor into @EmployeeId1,@AttendanceDate
		while @@FETCH_STATUS=0
		Begin		
declare @EmployeeTrainingStatus nvarchar(20)
select @EmployeeTrainingStatus=EmployeeTrainigStatus from Hr.TrainingAttendee where TrainingId=@TrainingId and EmployeeId=@EmployeeId1

if(@EmployeeTrainingStatus ='Registered' or @EmployeeTrainingStatus ='Completed' or @EmployeeTrainingStatus ='Incompleted' or @EmployeeTrainingStatus ='Absent' or @EmployeeTrainingStatus = 'Cancelled')
 begin
		set @Date1=@AttendanceDate
			Set @NewId1=NEWID()
			Set @Aid1=NEWID()

					BEGIN
						Insert Into Common.TimeLogItem --@TimeLogItem 
								(Id,CompanyId,Type,SubType,ChargeType,SystemType,SystemId,IsSystem,StartDate,EndDate,CreatedDate,ApplyToAll, Days)
							Values(@NewId1,@CompanyId,'Training',@CourseName ,'Non-Chargable','Training',@TrainingId,1,@Date1,@Date1,GETDATE(),0,1)
						Insert Into Common.TimeLogItemDetail -- @TimeLogItemDetail 
								(Id,TimeLogItemId,EmployeeId)
						Values(NewId(),@NewId1,@EmployeeId1)
						if exists (select * from common.Attendancedetails as ad join common.Attendance as a on a.id = ad.AttendenceId where a.date = @Date1 and employeeid=@EmployeeId1)
		BEGIN
			update ad set ad.TrainingId=@NewId1 from common.Attendancedetails as ad join common.Attendance as a on a.id = ad.AttendenceId where a.date = @Date1 and employeeid=@EmployeeId1
		END
		ELSE
		Begin 
			if exists (select * from common.Attendance where companyid=@companyid and date =@Date1)
			BEGIN
				insert common.AttendanceDetails(id,AttendenceId,EmployeeId,EmployeeName,TrainingId,CompanyId,AttendanceDate,DateValue)
				values(NEWID(),(select id from common.Attendance where companyid=@companyid and date =@Date1),@EmployeeId1,(select FirstName from Common.Employee where id=@EmployeeId1),@NewId1,@CompanyId,@Date1,(cast ((replace(convert(varchar, @Date1,102),'.','')) as bigint)))
			END
			ELSE
			BEGIN

				insert Common.Attendance(id,CompanyId,Date,Status)
				VALUES (@Aid1,@CompanyId,@Date1,1)

				insert common.AttendanceDetails(id,AttendenceId,EmployeeId,EmployeeName,TrainingId,CompanyId,AttendanceDate,DateValue)
				values(NEWID(),@Aid1,@EmployeeId1,(select FirstName from Common.Employee where id=@EmployeeId1),@NewId1,@CompanyId,@Date1,(cast ((replace(convert(varchar, @Date1,102),'.','')) as bigint)))
			END
					End
					End
		end
if(@EmployeeTrainingStatus = 'Withdrawn')
		Begin
		update Hr.TrainingAttendance set AmAttended=0,PmAttended=0 where EmployeeId=@EmployeeId1 and TrainingId=@TrainingId
		End
					fetch next from Training_Cursor into @EmployeeId1,@AttendanceDate
		end
		Close Training_Cursor
		Deallocate Training_Cursor
end
end



Commit Transaction--s2
	End try --s3
	Begin Catch
	ROLLBACK TRANSACTION
		DECLARE
				@ErrorMessage NVARCHAR(4000),
				@ErrorSeverity INT,
				@ErrorState INT;
		SELECT
				@ErrorMessage = ERROR_MESSAGE(),
				@ErrorSeverity = ERROR_SEVERITY(),
				@ErrorState = ERROR_STATE();
		RAISERROR (@ErrorMessage,@ErrorSeverity,@ErrorState);
	End Catch
	end--1


GO
