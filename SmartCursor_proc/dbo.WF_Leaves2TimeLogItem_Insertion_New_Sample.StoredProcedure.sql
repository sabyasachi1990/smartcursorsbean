USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[WF_Leaves2TimeLogItem_Insertion_New_Sample]    Script Date: 16-12-2024 9.20.11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


-- Exec [dbo].[WF_Leaves2TimeLogItem_Insertion_New_Sample] 1

CREATE Procedure [dbo].[WF_Leaves2TimeLogItem_Insertion_New_Sample]

@CompanyId Int

AS
BEGIN
Begin Transaction
Begin Try

Declare @LeaveApplicationId uniqueidentifier,
		@EmployeeId uniqueidentifier,
		@Startdatetype nvarchar(10),
		@EnddateType nvarchar(10),
		@FromDate datetime2,
		@ToDate datetime2


--Declare @TimeLogItem Table (Id	uniqueidentifier,CompanyId	bigint,Type	nVARCHAR(80),SubType nVARCHAR(508),
--							ChargeType	nVARCHAR(40),SystemType	nVARCHAR(40),SystemId	uniqueidentifier,IsSystem	bit,ApplyToAll	bit,
--							StartDate	datetime2,EndDate datetime2,Remarks	nVARCHAR(4000),RecOrder int,UserCreated NVARCHAR(508),
--							CreatedDate	datetime2,ModifiedBy NVARCHAR(508),ModifiedDate	datetime2,Version smallint,
--							Status int,Hours decimal,Days decimal,FirstHalfFromTime	time,FirstHalfToTime time,
--							SecondHalfFromTime time,SecondHalfToTime time,IsMain bit,SecondHalfTotalHours time,FirstHalfTotalHours time)

--Declare @TimeLogItemDetail Table(Id	uniqueidentifier,TimeLogItemId	uniqueidentifier,EmployeeId	uniqueidentifier,isnew int)


Declare Csr_csr Cursor For
		SeleCt lp.Id as LeaveApplicationId,lp.EmployeeId,lp.StartDateType,lp.EndDateType,lp.StartDateTime,lp.EndDateTime 
		From hr.leavetype as lt 
		inner join Hr.LeaveApplication as LP on lt.id=lp.leavetypeid 
		where lt.EntitlementType!='Hours' and lp.CompanyId=@CompanyId and lp.LeaveStatus not in ('Cancelled','Rejected')

	Open Csr_csr 
	Fetch Next From Csr_csr Into @LeaveApplicationId,@EmployeeId,@Startdatetype,@EnddateType,@FromDate,@ToDate
	While @@FETCH_STATUS=0
	Begin
-- // Variables
		Declare	@Date Date,
				@NewId Uniqueidentifier,
				@SubType NVARCHAR(100)
		select @SubType=Name from HR.LeaveType LT join HR.LeaveApplication LA on LA.LeaveTypeId = LT.Id where LA.Id = @LeaveApplicationId
-- // Check leavetypeid is exist or not if it is exist delete leavetypeid data from tables
If Exists (Select id From Common.TimeLogItem Where SystemId=@LeaveApplicationId)
Begin
Delete From Common.TimeLogItemDetail Where TimeLogItemId in (Select id From Common.TimeLogItem Where SystemId=@LeaveApplicationId)
Delete From Common.TimeLogItem Where SystemId=@LeaveApplicationId
End


		If @FromDate=@ToDate
		Begin
			Set @Date = @FromDate
			If Not Exists (Select Id from Common.WorkWeekSetUp Where CompanyId=@CompanyId And IsWorkingDay=0 And WeekDay=DATENAME(WEEKDAY,@Date) and EmployeeId IS NULL)
			Begin
				If Not Exists (Select Id from Common.Calender Where CompanyId=@CompanyId And ChargeType='Non-Working' And convert(Date,@Date) Between CONVERT(Date,FromDateTime) And Convert (Date,ToDateTime))
				Begin
					If @Startdatetype='AM' And @EnddateType='AM' -- 4hrs
					BEGIN
						Set @NewId=NEWID()
						Insert Into Common.TimeLogItem --@TimeLogItem 
								(Id,CompanyId,Type,SubType,ChargeType,SystemType,SystemId,IsSystem,StartDate,EndDate,CreatedDate,Hours, ApplyToAll, Days)
							Values(@NewId,@CompanyId,'Leaves',@SubType,'Non-Available','LeaveApplication',@LeaveApplicationId,1,@Date,@Date,GETDATE(),4, 0, 1)
						Insert Into Common.TimeLogItemDetail -- @TimeLogItemDetail 
								(Id,TimeLogItemId,EmployeeId)
						Values(NewId(),@NewId,@EmployeeId)
					End
					IF @Startdatetype= 'PM' AND @EnddateType='PM' -- 4 Hrs
					BEGIN
							Set @NewId=NEWID()
							Insert Into Common.TimeLogItem -- @TimeLogItem
							(Id,CompanyId,Type,SubType,ChargeType,SystemType,SystemId,IsSystem,StartDate,EndDate,CreatedDate,Hours, ApplyToAll, Days)
							Values(@NewId,@CompanyId,'Leaves',@SubType,'Non-Available','LeaveApplication',@LeaveApplicationId,1,@Date,@Date,GETDATE(),4, 0, 1)
							Insert Into Common.TimeLogItemDetail --@TimeLogItemDetail
							(Id,TimeLogItemId,EmployeeId)
							Values(NewId(),@NewId,@EmployeeId)
					End
					IF @Startdatetype='Full' AND (@EnddateType='Full' Or @EnddateType='AM' Or  @EnddateType='PM')-- 8 Hrs
					BEGIN
						Set @NewId=NEWID()
						Insert Into Common.TimeLogItem --@TimeLogItem
							(Id,CompanyId,Type,SubType,ChargeType,SystemType,SystemId,IsSystem,StartDate,EndDate,CreatedDate,Hours, ApplyToAll, Days)
						Values(@NewId,@CompanyId,'Leaves',@SubType,'Non-Available','LeaveApplication',@LeaveApplicationId,1,@Date,@Date,GETDATE(),8, 0, 1)
						Insert Into Common.TimeLogItemDetail --@TimeLogItemDetail
							(Id,TimeLogItemId,EmployeeId)
						Values(NewId(),@NewId,@EmployeeId)
					End
					IF @Startdatetype='AM' AND @EnddateType='PM' -->8 Hrs
					BEGIN
						Set @NewId=NEWID()
						Insert Into Common.TimeLogItem --@TimeLogItem
							(Id,CompanyId,Type,SubType,ChargeType,SystemType,SystemId,IsSystem,StartDate,EndDate,CreatedDate,Hours, ApplyToAll, Days)
						Values(@NewId,@CompanyId,'Leaves',@SubType,'Non-Available','LeaveApplication',@LeaveApplicationId,1,@Date,@Date,GETDATE(),8, 0, 1)
						Insert Into Common.TimeLogItemDetail -- @TimeLogItemDetail
							(Id,TimeLogItemId,EmployeeId)
						Values(NewId(),@NewId,@EmployeeId)
					End
					IF @Startdatetype='AM' AND @EnddateType='Full' -->8 Hrs
					BEGIN
						Set @NewId=NEWID()
						Insert Into Common.TimeLogItem --@TimeLogItem
							(Id,CompanyId,Type,SubType,ChargeType,SystemType,SystemId,IsSystem,StartDate,EndDate,CreatedDate,Hours, ApplyToAll, Days)
						Values(@NewId,@CompanyId,'Leaves',@SubType,'Non-Available','LeaveApplication',@LeaveApplicationId,1,@Date,@Date,GETDATE(),8, 0, 1)
						Insert Into Common.TimeLogItemDetail --@TimeLogItemDetail
							(Id,TimeLogItemId,EmployeeId)
						Values(NewId(),@NewId,@EmployeeId)
					End
					IF @Startdatetype='PM' AND @EnddateType='Full' -->4 Hrs
					BEGIN
						Set @NewId=NEWID()
						Insert Into Common.TimeLogItem -- @TimeLogItem
							(Id,CompanyId,Type,SubType,ChargeType,SystemType,SystemId,IsSystem,StartDate,EndDate,CreatedDate,Hours, ApplyToAll, Days)
						Values(@NewId,@CompanyId,'Leaves',@SubType,'Non-Available','LeaveApplication',@LeaveApplicationId,1,@Date,@Date,GETDATE(),4, 0, 1)
						Insert Into Common.TimeLogItemDetail --@TimeLogItemDetail
							(Id,TimeLogItemId,EmployeeId)
						Values(NewId(),@NewId,@EmployeeId)
					End
				End
			END
		END

-- // Getting the dates between Fromdate and Todate
		ELSE 
		BEGIN

			Set @Date=@FromDate
			While @Date<=@ToDate
			Begin

				If Not Exists (Select Id from Common.WorkWeekSetUp Where CompanyId=@CompanyId And IsWorkingDay=0 and CompanyId=@CompanyId 
						And WeekDay=DATENAME(WEEKDAY,@Date)	and EmployeeId IS NULL)
				Begin
					If Not Exists (Select Id from Common.Calender Where CompanyId=@CompanyId And ChargeType='Non-Working' 
							And convert(Date,@Date) Between CONVERT		(Date,FromDateTime)	And	Convert (Date,ToDateTime))
					Begin
						Declare @Hours Decimal(17,2)

						If @FromDate<>@ToDate
						Begin
							Set @Hours = CASE WHEN @FromDate =@Date THEN 
																	(CASE WHEN @Startdatetype='AM' THEN 8
																		WHEN @Startdatetype='FUll' THEN 8
																		WHEN @Startdatetype='PM' THEN 4 end
																	)
											WHEN @ToDate=@Date THEN 
																(CASE WHEN @EnddateType='PM' THEN 8
																	WHEN @EnddateType='FUll' THEN 8
																	WHEN @EnddateType='AM' THEN 4 end 
																)
																else 8 end 

							Set @NewId=NEWID()

							Insert Into Common.TimeLogItem --- @TimeLogItem
								(Id,CompanyId,Type,SubType,ChargeType,SystemType,SystemId,IsSystem,StartDate,EndDate,CreatedDate,Hours, ApplyToAll, Days)
							Values(@NewId,@CompanyId,'Leaves',@SubType,'Non-Available','LeaveApplication',@LeaveApplicationId,1,@Date,@Date,GETDATE(),@Hours, 0, 1)
							Insert Into Common.TimeLogItemDetail --@TimeLogItemDetail
									(Id,TimeLogItemId,EmployeeId)
							Values(NewId(),@NewId,@EmployeeId)
						End
					END

				END

			Set @Date=dateadd(d,1,@Date)
			END
		END
---------===========================
	Fetch Next From Csr_csr Into @LeaveApplicationId,@EmployeeId,@Startdatetype,@EnddateType,@FromDate,@ToDate

	End 
Close Csr_csr
Deallocate Csr_csr

Commit Transaction

End Try

Begin Catch
	Rollback;

	Print 'In Catch Block';

	Throw:

End Catch 

End
GO
