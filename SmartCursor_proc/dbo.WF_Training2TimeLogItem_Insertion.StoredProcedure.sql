USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[WF_Training2TimeLogItem_Insertion]    Script Date: 16-12-2024 9.20.11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE 
 Procedure [dbo].[WF_Training2TimeLogItem_Insertion]
@TrainingId Uniqueidentifier,
@EmployeeId Uniqueidentifier,
@CompanyId bigint,
@EmployeeTrainngStatus nvarchar(20)
AS
BEGIN
Begin Transaction
Begin Try
if(@EmployeeTrainngStatus ='Registered')
		Begin

		Declare 
		        @Date Date,
				@TrainingDate Date,
                @NewId Uniqueidentifier,
				@CourseName nvarchar(20)
                
		select @TrainingDate=TrainingDate,@CourseName=CL.CourseName from Hr.TrainingSchedule as TS join Hr.Training as TR on TS.TrainingId=TR.Id join HR.CourseLibrary as CL on TR.CourseLibraryId=CL.Id  where TS.TrainingId=@TrainingId

		--Declare   @AmAttended bit,
		--          @PmAttended bit 
		--      select @AmAttended= AMAttended ,@PmAttended=PMAttended From HR.TrainingAttendance  Where TrainingId=@TrainingId and EmployeeId=@EmployeeId


		Declare Training_Cursor Cursor for select TrainingDate from Hr.TrainingSchedule where TrainingId=@TrainingId
		open Training_Cursor
		fetch next from Training_Cursor into @TrainingDate
		while @@FETCH_STATUS=0
		Begin
				
		set @Date=@TrainingDate
			Set @NewId=NEWID()

					BEGIN
						Insert Into Common.TimeLogItem --@TimeLogItem 
								(Id,CompanyId,Type,SubType,ChargeType,SystemType,SystemId,IsSystem,StartDate,EndDate,CreatedDate,ApplyToAll, Days)
							Values(@NewId,@CompanyId,'Training',@CourseName ,'Non-Chargable','Training',@TrainingId,1,@Date,@Date,GETDATE(),0,1)
						Insert Into Common.TimeLogItemDetail -- @TimeLogItemDetail 
								(Id,TimeLogItemId,EmployeeId)
						Values(NewId(),@NewId,@EmployeeId)
					End

					fetch next from Training_Cursor into @TrainingDate
		end
		Close Training_Cursor
		Deallocate Training_Cursor
end

			else 
					if(@EmployeeTrainngStatus = 'Withdrawn')
				Begin
				   Delete From Common.TimeLogItemDetail Where TimeLogItemId in (Select id From Common.TimeLogItem Where SystemId=@TrainingId) and EmployeeId=@EmployeeId
                   Delete From Common.TimeLogItem Where SystemId=@TrainingId and Id in(select Id from Common.TimeLogItemDetail where EmployeeId=@EmployeeId)
				   --if((@AmAttended=1 and @PmAttended=1) or (@AmAttended=0 and @PmAttended=1) or (@AmAttended=1 and @PmAttended=0))
				   --begin
				   update Hr.TrainingAttendance set AmAttended=0,PmAttended=0 where EmployeeId=@EmployeeId and TrainingId=@TrainingId
				   --end
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
