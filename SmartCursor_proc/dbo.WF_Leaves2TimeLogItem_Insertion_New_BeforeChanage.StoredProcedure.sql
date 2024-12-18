USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[WF_Leaves2TimeLogItem_Insertion_New_BeforeChanage]    Script Date: 16-12-2024 9.20.11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE Procedure [dbo].[WF_Leaves2TimeLogItem_Insertion_New_BeforeChanage]
( @FromDate Date,
 @ToDate Date,
 @LeaveApplicationId Uniqueidentifier,
 @CompanyId Int,
 @EmployeeId Uniqueidentifier,
 @Startdatetype nVARCHAR(30),
 @EnddateType nVARCHAR(30)
)
As
Begin

--Exec [dbo].[WF_Leaves2TimeLogItem_Insertion_New] '2018-08-09','2018-08-09','C6170843-9552-4ED4-80F6-94FE8FA3BEFD',10,'0A98DD80-2C3F-355D-5524-FFE82CC37315','AM','AM'


--Exec [dbo].[WF_Leaves2TimeLogItem_Insertion] '2019-02-05 00:00:00.0000000','2019-02-05 00:00:00.0000000','702C8621-3C29-4AB0-AC9C-C9B1A2F87E14',291,'{3f6f347c-4d50-b31f-a65b-c2852b85ff77}','Full','Full'

--Declare  @FromDate Date='2019-02-05 00:00:00.0000000',
--@ToDate Date='2019-02-07 00:00:00.0000000',
--@LeaveApplicationId Uniqueidentifier='1835B5F8-F885-4A5B-80D7-A40A77D778F7',
--@CompanyId Int=291,
--@EmployeeId Uniqueidentifier='3f6f347c-4d50-b31f-a65b-c2852b85ff77',
--@Startdatetype nVARCHAR(20)='FULL',--8
--@EnddateType nVARCHAR(20)='AM'--4,8

--Declare @TimeLogItem Table (Id	uniqueidentifier,CompanyId	bigint,Type	nVARCHAR(80),SubType nVARCHAR(508),
--ChargeType	nVARCHAR(40),SystemType	nVARCHAR(40),SystemId	uniqueidentifier,IsSystem	bit,ApplyToAll	bit,
--StartDate	datetime2,EndDate datetime2,Remarks	nVARCHAR(4000),RecOrder int,UserCreated nVARCHAR(508),
--CreatedDate	datetime2,ModifiedBy nVARCHAR(508),ModifiedDate	datetime2,Version smallint,
--Status int,Hours decimal,Days decimal,FirstHalfFromTime	time,FirstHalfToTime time,
--SecondHalfFromTime time,SecondHalfToTime time,IsMain bit,SecondHalfTotalHours time,FirstHalfTotalHours time)

--Declare @TimeLogItemDetail Table(Id	uniqueidentifier,TimeLogItemId	uniqueidentifier,EmployeeId	uniqueidentifier,isnew int)



-- // Variables
 Declare	@Date Date,
			@NewId Uniqueidentifier,
			@SubType nVARCHAR(100)
 select @SubType=Name from HR.LeaveType LT join HR.LeaveApplication LA on LA.LeaveTypeId = LT.Id where LA.Id = @LeaveApplicationId
-- // Check leavetypeid is exist or not if it is exist delete leavetypeid data from tables
 If Exists (Select id From Common.TimeLogItem Where SystemId=@LeaveApplicationId)
  Begin
  Delete From Common.TimeLogItemDetail Where TimeLogItemId in (Select id From Common.TimeLogItem Where SystemId=@LeaveApplicationId)
  Delete From Common.TimeLogItem Where SystemId=@LeaveApplicationId
  End


if @FromDate=@ToDate
    Begin
	If Not Exists (Select Id from Common.WorkWeekSetUp Where CompanyId=@CompanyId And IsWorkingDay=0 and CompanyId=@CompanyId And WeekDay=DATENAME(WEEKDAY,@Date) and EmployeeId IS NULL)
   Begin
   If Not Exists (Select Id from Common.Calender Where CompanyId=@CompanyId And ChargeType='Non-Working' And convert(Date,@Date) Between CONVERT(Date,FromDateTime) And  Convert (Date,ToDateTime))
    Begin
	 If @Startdatetype='AM' And @EnddateType='AM' -- 4hrs

	BEGIN
    Set @NewId=NEWID()
    Insert Into Common.TimeLogItem  --@TimeLogItem 
	(Id,CompanyId,Type,SubType,ChargeType,SystemType,SystemId,IsSystem,StartDate,EndDate,CreatedDate,Hours, ApplyToAll, Days)
       Values(@NewId,@CompanyId,'Leaves',@SubType,'Non-Available','LeaveApplication',@LeaveApplicationId,1,@Date,@Date,GETDATE(),
       4, 0, 1)
    Insert Into Common.TimeLogItemDetail
	 (Id,TimeLogItemId,EmployeeId)
      Values(NewId(),@NewId,@EmployeeId)
    End
   End
   Begin
	
   IF @Startdatetype= 'PM' AND  @EnddateType='PM' -- 4 Hrs
	BEGIN
    Set @NewId=NEWID()
    Insert Into Common.TimeLogItem  -- @TimeLogItem
	(Id,CompanyId,Type,SubType,ChargeType,SystemType,SystemId,IsSystem,StartDate,EndDate,CreatedDate,Hours, ApplyToAll, Days)
       Values(@NewId,@CompanyId,'Leaves',@SubType,'Non-Available','LeaveApplication',@LeaveApplicationId,1,@Date,@Date,GETDATE(),
       4, 0, 1)
    Insert Into Common.TimeLogItemDetail
	 (Id,TimeLogItemId,EmployeeId)
      Values(NewId(),@NewId,@EmployeeId)
    End
   End

    Begin
	
  IF @Startdatetype='Full' AND @EnddateType='Full' -- 8 Hrs
	BEGIN
    Set @NewId=NEWID()
    Insert Into  Common.TimeLogItem --@TimeLogItem
	 (Id,CompanyId,Type,SubType,ChargeType,SystemType,SystemId,IsSystem,StartDate,EndDate,CreatedDate,Hours, ApplyToAll, Days)
       Values(@NewId,@CompanyId,'Leaves',@SubType,'Non-Available','LeaveApplication',@LeaveApplicationId,1,@Date,@Date,GETDATE(),
       8, 0, 1)
    Insert Into Common.TimeLogItemDetail
	 (Id,TimeLogItemId,EmployeeId)
      Values(NewId(),@NewId,@EmployeeId)
    End
   End

   Begin
	IF @Startdatetype='AM' AND @EnddateType='PM' -->8 Hrs
   BEGIN
    Set @NewId=NEWID()
    Insert Into  Common.TimeLogItem --@TimeLogItem
	(Id,CompanyId,Type,SubType,ChargeType,SystemType,SystemId,IsSystem,StartDate,EndDate,CreatedDate,Hours, ApplyToAll, Days)
       Values(@NewId,@CompanyId,'Leaves',@SubType,'Non-Available','LeaveApplication',@LeaveApplicationId,1,@Date,@Date,GETDATE(),
       8, 0, 1)
    Insert Into Common.TimeLogItemDetail 
	(Id,TimeLogItemId,EmployeeId)
      Values(NewId(),@NewId,@EmployeeId)
    End
   End

    Begin
	
  IF @Startdatetype='AM' AND @EnddateType='Full' -->8 Hrs
  BEGIN
    Set @NewId=NEWID()
    Insert Into  Common.TimeLogItem  --@TimeLogItem
	(Id,CompanyId,Type,SubType,ChargeType,SystemType,SystemId,IsSystem,StartDate,EndDate,CreatedDate,Hours, ApplyToAll, Days)
       Values(@NewId,@CompanyId,'Leaves',@SubType,'Non-Available','LeaveApplication',@LeaveApplicationId,1,@Date,@Date,GETDATE(),
       8, 0, 1)
    Insert Into Common.TimeLogItemDetail 
	(Id,TimeLogItemId,EmployeeId)
      Values(NewId(),@NewId,@EmployeeId)
    End
   End

   Begin
	IF @Startdatetype='PM' AND @EnddateType='Full' -->4 Hrs
   BEGIN
    Set @NewId=NEWID()
    Insert Into  Common.TimeLogItem -- @TimeLogItem
	(Id,CompanyId,Type,SubType,ChargeType,SystemType,SystemId,IsSystem,StartDate,EndDate,CreatedDate,Hours, ApplyToAll, Days)
       Values(@NewId,@CompanyId,'Leaves',@SubType,'Non-Available','LeaveApplication',@LeaveApplicationId,1,@Date,@Date,GETDATE(),
       4, 0, 1)
    Insert Into Common.TimeLogItemDetail
	 (Id,TimeLogItemId,EmployeeId)
      Values(NewId(),@NewId,@EmployeeId)
    End
   End

    Begin
	IF @Startdatetype='Full' AND @EnddateType IN ('Full','Am','PM ')--> 8hrs
   BEGIN
    Set @NewId=NEWID()
    Insert Into Common.TimeLogItem  --@TimeLogItem
	(Id,CompanyId,Type,SubType,ChargeType,SystemType,SystemId,IsSystem,StartDate,EndDate,CreatedDate,Hours, ApplyToAll, Days)
       Values(@NewId,@CompanyId,'Leaves',@SubType,'Non-Available','LeaveApplication',@LeaveApplicationId,1,@Date,@Date,GETDATE(),
       8, 0, 1)
    Insert Into Common.TimeLogItemDetail 
	(Id,TimeLogItemId,EmployeeId)
      Values(NewId(),@NewId,@EmployeeId)
    End
   End
   END
   END
 
-- // Declare table variable to store the dates between fromdate & Todate
 --Declare @DateTbl table (Dates date,hours decimal(10,2))
-- // Getting the dates between Fromdate and Todate
  ELSE BEGIN
  
 Set @Date=@FromDate
 While @Date<=@ToDate
 Begin

 If Not Exists (Select Id from Common.WorkWeekSetUp Where CompanyId=@CompanyId And IsWorkingDay=0 and CompanyId=@CompanyId And WeekDay=DATENAME(WEEKDAY,@Date) and EmployeeId IS NULL)
   Begin
   If Not Exists (Select Id from Common.Calender Where CompanyId=@CompanyId And ChargeType='Non-Working' And convert(Date,@Date) Between CONVERT(Date,FromDateTime) And  Convert (Date,ToDateTime))
    Begin
	Declare @Hours Decimal(17,2)
	  
  if @FromDate<>@ToDate
  Begin
	Set @Hours =  CASE WHEN   @FromDate =@Date 
					THEN (
							CASE WHEN @Startdatetype='AM' THEN 8
							  WHEN   @Startdatetype='FUll' THEN 8
							  WHEN @Startdatetype='PM' THEN 4 end
					   )
				  WHEN @ToDate=@Date 
				  THEN (
						CASE WHEN @EnddateType='PM' THEN 8
						 WHEN  @EnddateType='FUll' THEN 8
						 WHEN @EnddateType='AM' THEN 4 end 
					  )
				else 8 end 	
	
	
	BEGIN
    Set @NewId=NEWID()
    Insert Into  Common.TimeLogItem --- @TimeLogItem
	(Id,CompanyId,Type,SubType,ChargeType,SystemType,SystemId,IsSystem,StartDate,EndDate,CreatedDate,Hours, ApplyToAll, Days)
       Values(@NewId,@CompanyId,'Leaves',@SubType,'Non-Available','LeaveApplication',@LeaveApplicationId,1,@Date,@Date,GETDATE(),
       @Hours, 0, 1)
    Insert Into Common.TimeLogItemDetail
	 (Id,TimeLogItemId,EmployeeId)
      Values(NewId(),@NewId,@EmployeeId)
    End
   End
   END

   END
 
   Set @Date=dateadd(d,1,@Date)
   END
   END

   END


GO
