USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[WF_Leaves2TimeLogItem_Insertion]    Script Date: 16-12-2024 9.20.11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


      
--EXEC [dbo].[WF_Leaves2TimeLogItem_Insertion] '2023-10-16','2023-10-16','CE84C3EC-B9C9-40C9-87C3-B54499B372B1',1,'64DA2A40-B502-E354-1E9D-C352C4B444F1','Full','Full',''      
      
CREATE   Procedure [dbo].[WF_Leaves2TimeLogItem_Insertion]      
@FromDate datetime2,      
@ToDate datetime2,      
@LeaveApplicationId uniqueidentifier,      
@CompanyId Int,      
@EmployeeId uniqueidentifier,      
@Startdatetype nvarchar(10),      
@EnddateType nvarchar(10),      
@SystemSubTypeStatus nvarchar(20)      
AS      
BEGIN      
Begin Transaction      
Begin Try      
      
      
      
 INSERT INTO dbo.TimeLogHistory (Id, ExecutionTime, LineNumber, LineText)      
    VALUES (NEWID(), GETDATE(), 1, 'Stored Procedure Execution Started')      
  print 'Stored Procedure Execution Started'    
  Declare @Date Date,      
    @NewId Uniqueidentifier,      
    @SubType NVARCHAR(100),      
    @LeaveType nvarchar(10),      
    @LeaveApplicationHours float,      
    @TimelogitemHours float,--priyanka      
    @Employeename NVARCHAR(1000),      
    @DepartmentId Uniqueidentifier,      
    @DesignationId Uniqueidentifier,      
    @EntityId bigint,      
    @IsWFSync Bit,        
                @IsAttendanceSync Bit       
      
  select @SubType=Name,@LeaveType=lt.EntitlementType,@LeaveApplicationHours=Cast(Replace(FORMAT(FLOOR(LA.Hours)*100 + (LA.Hours-FLOOR(LA.Hours))*60,'00:00'),':','.') As Decimal(17,2))/*LA.Hours*/,        
  @Employeename=ce.FirstName,@DepartmentId=ce.DepartmentId,@DesignationId=ce.DesignationId,@EntityId=ce.CurrentServiceEnittyId,      
  @IsWFSync=Lt.IsNotSynctoWorkflow,@IsAttendanceSync=Lt.IsNotSynctoAttendance from HR.LeaveType LT (NOLOCK)        
  join HR.LeaveApplication LA (NOLOCK) on LA.LeaveTypeId = LT.Id join Common.Employee ce (NOLOCK) on LA.EmployeeId=ce.Id  where LA.Id =@LeaveApplicationId      
      
DECLARE @LineText2 NVARCHAR(MAX);      
SET @LineText2 = CONCAT(@SubType , ', ',@LeaveType,  ', '  ,@LeaveApplicationHours , ', '  ,@Employeename , ', ' ,@DepartmentId, ', ' , @DesignationId , ', '      ,@EntityId , ', ' ,@IsWFSync, ', ' ,@IsAttendanceSync)      
  print @LineText2    
  print '@LineText2'
INSERT INTO dbo.TimeLogHistory (Id, ExecutionTime, LineNumber, LineText)      
VALUES (NEWID(), GETDATE(), 2, @LineText2);      
      
  --Select @IsWFSync,@IsAttendanceSync      
-- // Check leavetypeid is exist or not if it is exist delete leavetypeid data from tables      
Declare @IsTimeLogInsert bit=0,@IsAttendanceInsert Bit=0      
If( IsNULL(@IsWFSync,0)=0 )        
    SET @IsTimeLogInsert=1       
If( IsNULL(@IsAttendanceSync,0)=0 )        
    SET @IsAttendanceInsert=1       
If Exists (Select id From Common.TimeLogItem (NOLOCK) Where SystemId=@LeaveApplicationId)   

    
      
Begin    
Delete From Common.TimeLogItemDetail WITH (ROWLOCK) Where TimeLogItemId in (Select id From Common.TimeLogItem (NOLOCK) Where SystemId=@LeaveApplicationId)      
Delete From Common.TimeLogItem WITH (ROWLOCK) Where SystemId=@LeaveApplicationId      
update [Common].[AttendanceDetails] WITH (UPDLOCK) set AttendanceType=null,LeaveApplicationId=null where LeaveApplicationId=@LeaveApplicationId       
End      
      
  If @FromDate=@ToDate      
  Begin      
   Set @Date = @FromDate      
   If Not Exists (Select Id from Common.WorkWeekSetUp (NOLOCK) Where CompanyId=@CompanyId And IsWorkingDay=0 And WeekDay=DATENAME(WEEKDAY,@Date) and EmployeeId IS NULL)      
      
    DECLARE @LineText4 NVARCHAR(MAX);      
    SET @LineText4 = (Select Id from Common.WorkWeekSetUp (NOLOCK) Where CompanyId=@CompanyId And IsWorkingDay=0 And WeekDay=DATENAME(WEEKDAY,@Date) and EmployeeId IS NULL);      
  print @LineText4    
    INSERT INTO dbo.TimeLogHistory (Id, ExecutionTime, LineNumber, LineText)      
    VALUES (NEWID(), GETDATE(), 4, @LineText4);      
      
   Begin      
    If Not Exists (Select TL2.Id from Common.Calender C (NOLOCK) left join Common.CalenderDetails CL (NOLOCK) on C.Id = CL.MasterId left join Common.TimelogItem TL1 (NOLOCK) on TL1.SystemID=c.ID  left join Common.TimelogItem TL2 (NOLOCK) on TL1.ID=TL2.SystemId Where c.Status=1 and (CL.EmployeeId = @EmployeeId or C.ApplyTo='All')and  C.CompanyId=@CompanyId And C.ChargeType='Non-Working' AND (convert(Date,@Date) Between CONVERT    (Date,C.FromDateTime) And Convert (Date,C.ToDateTime)) AND (convert(Date,@Date) Between CONVERT(Date,TL2.StartDate) And Convert(Date,TL2.EndDate)) AND TL2.TimeType='Full')--priyanka      
      
      
     DECLARE @LineText5 NVARCHAR(MAX);      
    SET @LineText5 = (Select TL2.Id from Common.Calender C (NOLOCK) left join Common.CalenderDetails CL (NOLOCK) on C.Id = CL.MasterId left join Common.TimelogItem TL1 (NOLOCK) on TL1.SystemID=c.ID  left join Common.TimelogItem TL2 (NOLOCK) on TL1.ID=TL2.
  
SystemId Where c.Status=1 and (CL.EmployeeId = @EmployeeId or C.ApplyTo='All')and  C.CompanyId=@CompanyId And C.ChargeType='Non-Working' AND (convert(Date,@Date) Between CONVERT    (Date,C.FromDateTime) And Convert (Date,C.ToDateTime)) AND (convert(Date,@Date) Between CONVERT(Date,TL2.StartDate) And Convert(Date,TL2.EndDate)) AND TL2.TimeType='Full');      
  print @LineText5    
    INSERT INTO dbo.TimeLogHistory (Id, ExecutionTime, LineNumber, LineText)      
    VALUES (NEWID(), GETDATE(), 5, @LineText5);      
      
      
    Begin      
 print @IsTimeLogInsert    
     If (@IsTimeLogInsert=1)      
       Begin      
     If @Startdatetype='AM' And @EnddateType='AM' -- 4hrs      
     BEGIN      
      Set @NewId=NEWID()      
      Insert Into Common.TimeLogItem --@TimeLogItem       
        (Id,CompanyId,Type,SubType,ChargeType,SystemType,SystemId,IsSystem,StartDate,EndDate,CreatedDate,Hours, ApplyToAll, Days,UserCreated,SystemSubTypeStatus)      
       Values(@NewId,@CompanyId,'Leaves',@SubType,'Non-Available','LeaveApplication',@LeaveApplicationId,1,@Date,@Date,GETDATE(),      
       (select  DATEDIFF(HH,AMFromTime,AMToTime) from Common.WorkWeekSetUp (NOLOCK) where Companyid=@CompanyId and EmployeeId is null AND WeekDay=DATENAME(WEEKDAY,@Date)), 0, 1,'System',@SystemSubTypeStatus)      
      Insert Into Common.TimeLogItemDetail -- @TimeLogItemDetail       
        (Id,TimeLogItemId,EmployeeId)      
      Values(NewId(),@NewId,@EmployeeId)      
      
       INSERT INTO dbo.TimeLogHistory (Id, ExecutionTime, LineNumber, LineText)      
       VALUES (NEWID(), GETDATE(), 6, 'IF Start Datetype and EnddateType is AM')      
            
     End      
     IF @Startdatetype= 'PM' AND @EnddateType='PM' -- 4 Hrs      
     BEGIN      
       Set @NewId=NEWID()      
       Insert Into Common.TimeLogItem -- @TimeLogItem      
       (Id,CompanyId,Type,SubType,ChargeType,SystemType,SystemId,IsSystem,StartDate,EndDate,CreatedDate,Hours, ApplyToAll, Days,UserCreated,SystemSubTypeStatus)      
       Values(@NewId,@CompanyId,'Leaves',@SubType,'Non-Available','LeaveApplication',@LeaveApplicationId,1,@Date,@Date,GETDATE(),      
       (select  DATEDIFF(HH,PMFromTime,PMToTime) from Common.WorkWeekSetUp (NOLOCK) where Companyid=@CompanyId and EmployeeId is null AND WeekDay=DATENAME(WEEKDAY,@Date)), 0, 1,'System',@SystemSubTypeStatus)      
       Insert Into Common.TimeLogItemDetail --@TimeLogItemDetail      
       (Id,TimeLogItemId,EmployeeId)      
       Values(NewId(),@NewId,@EmployeeId)      
      
        INSERT INTO dbo.TimeLogHistory (Id, ExecutionTime, LineNumber, LineText)      
    VALUES (NEWID(), GETDATE(), 7, 'IF Start Datetype and EnddateType is PM')      
     End      
     IF @Startdatetype='Full' AND (@EnddateType='Full' Or @EnddateType='AM' Or  @EnddateType='PM')-- 8 Hrs      
     BEGIN      
        IF(@LeaveType='Hours')      
        BEGIN      
         Set @NewId=NEWID()      
         Insert Into Common.TimeLogItem --@TimeLogItem      
          (Id,CompanyId,Type,SubType,ChargeType,SystemType,SystemId,IsSystem,StartDate,EndDate,CreatedDate,Hours, ApplyToAll, Days,UserCreated,SystemSubTypeStatus)      
         Values(@NewId,@CompanyId,'Leaves',@SubType,'Non-Available','LeaveApplication',@LeaveApplicationId,1,@Date,@Date,GETDATE(),      
         @LeaveApplicationHours, 0, 0,'System',@SystemSubTypeStatus)      
         Insert Into Common.TimeLogItemDetail --@TimeLogItemDetail      
          (Id,TimeLogItemId,EmployeeId)      
         Values(NewId(),@NewId,@EmployeeId)      
          INSERT INTO dbo.TimeLogHistory (Id, ExecutionTime, LineNumber, LineText)      
    VALUES (NEWID(), GETDATE(), 8, 'Leavetype is Hours')      
        END      
      ELSE      
              BEGIN     
  If  Exists (Select TL2.Id from Common.Calender C (NOLOCK) left join Common.CalenderDetails CL (NOLOCK) on C.Id = CL.MasterId left join Common.TimelogItem TL1 (NOLOCK) on TL1.SystemID=c.ID  left join Common.TimelogItem TL2 (NOLOCK) on TL1.ID=TL2.SystemId
  
    
 Where c.status=1 and (CL.EmployeeId = @EmployeeId or C.ApplyTo='All')and  C.CompanyId=@CompanyId And C.ChargeType='Non-Working' AND (convert(Date,@Date) Between CONVERT    (Date,C.FromDateTime) And Convert (Date,C.ToDateTime)) AND (convert(Date,@Date) Between CONVERT(Date,TL2.StartDate) And Convert(Date,TL2.EndDate)) AND TL2.TimeType!='Full')--priyanka      
      
       
      
      
      begin      
      set @TimelogitemHours=(select  Datepart(HH,WorkingHours) from Common.WorkWeekSetUp (NOLOCK) where Companyid=@CompanyId and EmployeeId is null AND WeekDay=DATENAME(WEEKDAY,@Date))/2      
      
    DECLARE @LineText9 NVARCHAR(MAX);      
    SET @LineText9 = ((select  Datepart(HH,WorkingHours) from Common.WorkWeekSetUp (NOLOCK) where Companyid=@CompanyId and EmployeeId is null AND WeekDay=DATENAME(WEEKDAY,@Date))/2)      
      
    INSERT INTO dbo.TimeLogHistory (Id, ExecutionTime, LineNumber, LineText)      
    VALUES (NEWID(), GETDATE(), 9, @LineText9);      
      end      
    ELSE      
      begin      
      set @TimelogitemHours=(select  Datepart(HH,WorkingHours) from Common.WorkWeekSetUp (NOLOCK) where Companyid=@CompanyId and EmployeeId is null AND WeekDay=DATENAME(WEEKDAY,@Date))      
      
         DECLARE @LineText10 NVARCHAR(MAX);      
    SET @LineText10 = ((select  Datepart(HH,WorkingHours) from Common.WorkWeekSetUp (NOLOCK) where Companyid=@CompanyId and EmployeeId is null AND WeekDay=DATENAME(WEEKDAY,@Date))/2)      
      
    INSERT INTO dbo.TimeLogHistory (Id, ExecutionTime, LineNumber, LineText)      
    VALUES (NEWID(), GETDATE(), 10, @LineText10);      
      
      
      end      
         Set @NewId=NEWID()      
         Insert Into Common.TimeLogItem --@TimeLogItem      
          (Id,CompanyId,Type,SubType,ChargeType,SystemType,SystemId,IsSystem,StartDate,EndDate,CreatedDate,Hours, ApplyToAll, Days,UserCreated,SystemSubTypeStatus)      
         Values(@NewId,@CompanyId,'Leaves',@SubType,'Non-Available','LeaveApplication',@LeaveApplicationId,1,@Date,@Date,GETDATE(),      
         @TimelogitemHours, 0, 1,'System',@SystemSubTypeStatus)      
         Insert Into Common.TimeLogItemDetail --@TimeLogItemDetail      
          (Id,TimeLogItemId,EmployeeId)      
         Values(NewId(),@NewId,@EmployeeId)      
      
          INSERT INTO dbo.TimeLogHistory (Id, ExecutionTime, LineNumber, LineText)      
    VALUES (NEWID(), GETDATE(), 11, 'Stored Procedure Execution Started1')      
        END      
     End      
     IF @Startdatetype='AM' AND @EnddateType='PM' -->8 Hrs      
     BEGIN      
      Set @NewId=NEWID()      
      Insert Into Common.TimeLogItem --@TimeLogItem      
       (Id,CompanyId,Type,SubType,ChargeType,SystemType,SystemId,IsSystem,StartDate,EndDate,CreatedDate,Hours, ApplyToAll, Days,UserCreated,SystemSubTypeStatus)      
      Values(@NewId,@CompanyId,'Leaves',@SubType,'Non-Available','LeaveApplication',@LeaveApplicationId,1,@Date,@Date,GETDATE(),      
      @TimelogitemHours, 0, 1,'System',@SystemSubTypeStatus)      
      Insert Into Common.TimeLogItemDetail -- @TimeLogItemDetail      
       (Id,TimeLogItemId,EmployeeId)      
      Values(NewId(),@NewId,@EmployeeId)      
    
       INSERT INTO dbo.TimeLogHistory (Id, ExecutionTime, LineNumber, LineText)      
    VALUES (NEWID(), GETDATE(), 12, '@Startdatetype=AM AND @EnddateType=PM')     
     End      
     IF @Startdatetype='AM' AND @EnddateType='Full' -->8 Hrs      
     BEGIN      
      Set @NewId=NEWID()      
      Insert Into Common.TimeLogItem --@TimeLogItem      
       (Id,CompanyId,Type,SubType,ChargeType,SystemType,SystemId,IsSystem,StartDate,EndDate,CreatedDate,Hours, ApplyToAll, Days,UserCreated,SystemSubTypeStatus)      
      Values(@NewId,@CompanyId,'Leaves',@SubType,'Non-Available','LeaveApplication',@LeaveApplicationId,1,@Date,@Date,GETDATE(),      
      @TimelogitemHours, 0, 1,'System',@SystemSubTypeStatus)      
      Insert Into Common.TimeLogItemDetail --@TimeLogItemDetail      
       (Id,TimeLogItemId,EmployeeId)      
      Values(NewId(),@NewId,@EmployeeId)      
      
       INSERT INTO dbo.TimeLogHistory (Id, ExecutionTime, LineNumber, LineText)      
    VALUES (NEWID(), GETDATE(), 13, '@Startdatetype=AM AND @EnddateType=Full')      
     End      
     IF @Startdatetype='PM' AND @EnddateType='Full' -->4 Hrs      
     BEGIN      
      Set @NewId=NEWID()      
      Insert Into Common.TimeLogItem -- @TimeLogItem      
       (Id,CompanyId,Type,SubType,ChargeType,SystemType,SystemId,IsSystem,StartDate,EndDate,CreatedDate,Hours, ApplyToAll, Days,UserCreated,SystemSubTypeStatus)      
      Values(@NewId,@CompanyId,'Leaves',@SubType,'Non-Available','LeaveApplication',@LeaveApplicationId,1,@Date,@Date,GETDATE(),      
      @TimelogitemHours, 0, 1,'System',@SystemSubTypeStatus)      
      Insert Into Common.TimeLogItemDetail --@TimeLogItemDetail      
       (Id,TimeLogItemId,EmployeeId)      
      Values(NewId(),@NewId,@EmployeeId)      
      
       INSERT INTO dbo.TimeLogHistory (Id, ExecutionTime, LineNumber, LineText)      
    VALUES (NEWID(), GETDATE(), 14, '@Startdatetype=PM AND @EnddateType=Full')     
     End      
     End      
      
     --======================================Attendance==================================================      
if(@IsAttendanceInsert=1)      
Begin      
IF NOT EXISTS (      
  SELECT id      
  FROM [Common].[Attendance] (NOLOCK)      
  WHERE convert(DATE, [Date]) = convert(DATE, @Date) AND CompanyId = @CompanyId      
  )      
BEGIN --mm      
 DECLARE @type NVARCHAR(200)      
      
 IF (@LeaveType = 'Hours')      
 BEGIN --ms      
  SET @type = @SubType      
 END --ms      
 ELSE      
 BEGIN --ms2      
  SET @type = (@SubType + '(' + @EnddateType + ')');      
 END --ms2      
      
 DECLARE @AttendanceMasterId UNIQUEIDENTIFIER = newid();      
      
 INSERT INTO Common.Attendance (Id, CompanyId, DATE, STATUS)      
 VALUES (@AttendanceMasterId, @CompanyId, convert(DATE, @Date), 1)      
      
 INSERT INTO [Common].[AttendanceDetails] (Id, EmployeeId, AttendenceId, UserCreated, CreatedDate, STATUS, EmployeeName, DepartmentId, DesignationId, ServiceEntityId, LeaveApplicationId, AttendanceType,CompanyId,AttendanceDate,DateValue)      
 VALUES (NEWID(), @EmployeeId, @AttendanceMasterId, 'System', GETutcDATE(), 1, @Employeename, @DepartmentId, @DesignationId, @EntityId, @LeaveApplicationId, @type,@CompanyId,convert(DATE, @Date),(cast ((replace(convert(varchar, @Date,102),'.','')) as bigint)))      
END --mm      
ELSE      
BEGIN --mm2      
 DECLARE @AttendanceMasterId1 UNIQUEIDENTIFIER = (      
   SELECT top 1 id      
 FROM [Common].[Attendance] (NOLOCK)      
   WHERE convert(DATE, [Date]) = convert(DATE, @Date) AND CompanyId = @CompanyId      
   );      
 DECLARE @type1 NVARCHAR(200)      
      
 IF (@LeaveType = 'Hours')      
 BEGIN --ms      
  SET @type1 = @SubType      
 END --ms      
 ELSE      
 BEGIN --ms2      
  SET @type1 = (@SubType + '(' + @EnddateType + ')');      
 END --ms2      
 if not exists (select * from Common.AttendanceDetails (NOLOCK) where AttendenceId=@AttendanceMasterId1 and EmployeeId=@EmployeeId)      
 begin --mm    
 INSERT INTO [Common].[AttendanceDetails] (Id, EmployeeId, AttendenceId, UserCreated, CreatedDate, STATUS, EmployeeName, DepartmentId, DesignationId, ServiceEntityId, LeaveApplicationId, AttendanceType,CompanyId,AttendanceDate,DateValue)      
 VALUES (NEWID(), @EmployeeId, @AttendanceMasterId1, 'System', GETutcDATE(), 1, @Employeename, @DepartmentId, @DesignationId, @EntityId, @LeaveApplicationId, @type1,@CompanyId,convert(DATE, @Date),(cast ((replace(convert(varchar, @Date,102),'.','')) as bigint)))      
 end --mm      
 else      
 begin--mm      
 update Common.AttendanceDetails WITH (UPDLOCK) set AttendanceType=@type1,LeaveApplicationId=@LeaveApplicationId where AttendenceId=@AttendanceMasterId1 and EmployeeId=@EmployeeId       
 end--mm      
       
END --mm2      
END      
  ----========================Attendance============================================================      
    End      
        
   END      
      
  END      
       
      
-- // Getting the dates between Fromdate and Todate      
  ELSE       
  BEGIN      
   Set @Date=@FromDate      
   While @Date<=@ToDate      
   Begin      
    If Not Exists (Select Id from Common.WorkWeekSetUp (NOLOCK) Where CompanyId=@CompanyId And IsWorkingDay=0 and CompanyId=@CompanyId       
      And WeekDay=DATENAME(WEEKDAY,@Date) and EmployeeId IS NULL)      
    Begin     
     If Not Exists (Select C.Id from Common.Calender C (NOLOCK) left join Common.CalenderDetails CL (NOLOCK) on C.Id = CL.MasterId left join Common.TimelogItem TL1 (NOLOCK) on TL1.SystemID=c.ID  left join Common.TimelogItem TL2 (NOLOCK) on TL1.ID=TL2.SystemId Where c.Status=1 and (CL.EmployeeId = @EmployeeId or C.ApplyTo='All')and  C.CompanyId=@CompanyId And C.ChargeType='Non-Working'       
       And (convert(Date,@Date) Between CONVERT (Date,C.FromDateTime) And Convert (Date,C.ToDateTime)) AND (convert(Date,@Date) Between CONVERT (Date,TL2.StartDate) And Convert (Date,TL2.EndDate)) and TL2.TimeType='Full' )      
     Begin      
      Declare @Hours Decimal(17,2)      
      
      If @FromDate<>@ToDate      
      Begin      
   print @IsTimeLogInsert    
         If(@IsTimeLogInsert=1)      
         Begin      
          If(@LeaveType='Hours')      
        Begin     
         Set @Hours =@LeaveApplicationHours;      
        End      
       Else      
        Begin    
       Set @Hours = CASE WHEN @FromDate =@Date THEN       
                 (CASE WHEN @Startdatetype='AM' THEN (select  Datepart(HH,WorkingHours) from Common.WorkWeekSetUp (NOLOCK)      
                     where Companyid=@CompanyId and EmployeeId is null AND WeekDay=DATENAME(WEEKDAY,@Date)) --8      
                  WHEN @Startdatetype='FUll' THEN (select  Datepart(HH,WorkingHours) from Common.WorkWeekSetUp (NOLOCK)      
                  where Companyid=@CompanyId and EmployeeId is null AND WeekDay=DATENAME(WEEKDAY,@Date)) -- 8      
                  WHEN @Startdatetype='PM' THEN (select  DATEDIFF(HH,PMFromTime,PMToTime) from Common.WorkWeekSetUp (NOLOCK)       
                  where Companyid=@CompanyId and EmployeeId is null AND WeekDay=DATENAME(WEEKDAY,@Date))       
                  end      
                 )      
         WHEN @ToDate=@Date THEN       
                (CASE WHEN @EnddateType='PM' THEN (select  Datepart(HH,WorkingHours) from Common.WorkWeekSetUp (NOLOCK)      
                      where Companyid=@CompanyId and EmployeeId is null AND WeekDay=DATENAME(WEEKDAY,@Date)) -- 8      
                 WHEN @EnddateType='FUll' THEN (select  Datepart(HH,WorkingHours) from Common.WorkWeekSetUp (NOLOCK)      
                 where Companyid=@CompanyId and EmployeeId is null AND WeekDay=DATENAME(WEEKDAY,@Date)) -- 8      
                 WHEN @EnddateType='AM' THEN (select  DATEDIFF(HH,AMFromTime,AMToTime) from Common.WorkWeekSetUp (NOLOCK)      
                  where Companyid=@CompanyId and EmployeeId is null AND WeekDay=DATENAME(WEEKDAY,@Date)) end       
                )      
                else 8 end       
        End      
        If  Exists (Select TL2.Id from Common.Calender C (NOLOCK) left join Common.CalenderDetails CL (NOLOCK) on C.Id = CL.MasterId left join Common.TimelogItem TL1 (NOLOCK) on TL1.SystemID=c.ID  left join Common.TimelogItem TL2 (NOLOCK) on TL1.ID=TL2.SystemId Where c.Status=1 and (CL.EmployeeId = @EmployeeId or C.ApplyTo='All')and  C.CompanyId=@CompanyId And C.ChargeType='Non-Working' AND (convert(Date,@Date) Between CONVERT    (Date,C.FromDateTime) And Convert (Date,C.ToDateTime)) AND (convert(Date,@Date) Between CONVERT(Date,TL2.StartDate) And Convert(Date,TL2.EndDate)) AND TL2.TimeType!='Full')      
      begin     
        If(@LeaveType='Hours')      
        Begin      
         Set @Hours =@LeaveApplicationHours;      
        End      
        else      
        Begin    
         Set @Hours =(select  Datepart(HH,WorkingHours) from Common.WorkWeekSetUp (NOLOCK) where Companyid=@CompanyId and EmployeeId is null AND WeekDay=DATENAME(WEEKDAY,@Date))/2;      
        End      
      end      
       Set @NewId=NEWID()      
       Insert Into Common.TimeLogItem --- @TimeLogItem      
        (Id,CompanyId,Type,SubType,ChargeType,SystemType,SystemId,IsSystem,StartDate,EndDate,CreatedDate,Hours, ApplyToAll, Days,UserCreated,SystemSubTypeStatus)      
       Values(@NewId,@CompanyId,'Leaves',@SubType,'Non-Available','LeaveApplication',@LeaveApplicationId,1,@Date,@Date,GETDATE(),@Hours, 0, 1,'System',@SystemSubTypeStatus)      
       Insert Into Common.TimeLogItemDetail --@TimeLogItemDetail      
         (Id,TimeLogItemId,EmployeeId)      
       Values(NewId(),@NewId,@EmployeeId)      
        INSERT INTO dbo.TimeLogHistory (Id, ExecutionTime, LineNumber, LineText)      
    VALUES (NEWID(), GETDATE(), 15, '@LeaveType=Hours')      
      END      
       --======================================Attendance==================================================      
If(@IsAttendanceInsert=1)      
Begin      
IF NOT EXISTS (      
  SELECT id      
  FROM [Common].[Attendance] (NOLOCK)      
  WHERE convert(DATE, [Date]) = convert(DATE, @Date) AND CompanyId = @CompanyId      
  )      
BEGIN --mm      
 DECLARE @type3 NVARCHAR(200)      
      
 IF (@LeaveType = 'Hours')      
 BEGIN --ms      
  SET @type3 = @SubType      
 END --ms      
 ELSE      
 BEGIN --ms2      
  SET @type3 = (@SubType + '(' + @EnddateType + ')');      
 END --ms2      
      
 DECLARE @AttendanceMasterId2 UNIQUEIDENTIFIER = newid();      
      
 INSERT INTO Common.Attendance (Id, CompanyId, DATE, STATUS)      
 VALUES (@AttendanceMasterId2, @CompanyId, convert(DATE, @Date), 1)      
      
 INSERT INTO [Common].[AttendanceDetails] (Id, EmployeeId, AttendenceId, UserCreated, CreatedDate, STATUS, EmployeeName, DepartmentId, DesignationId, ServiceEntityId, LeaveApplicationId, AttendanceType,CompanyId,AttendanceDate,DateValue)      
 VALUES (NEWID(), @EmployeeId, @AttendanceMasterId2, 'System', GETutcDATE(), 1, @Employeename, @DepartmentId, @DesignationId, @EntityId, @LeaveApplicationId, @type3,@CompanyId,convert(DATE, @Date),(cast ((replace(convert(varchar, @Date,102),'.','')) as bigint)))      
END --mm      
ELSE      
BEGIN --mm2      
 DECLARE @AttendanceMasterId3 UNIQUEIDENTIFIER = (      
   SELECT top 1 id      
   FROM [Common].[Attendance] (NOLOCK)      
   WHERE convert(DATE, [Date]) = convert(DATE, @Date) AND CompanyId = @CompanyId      
   );      
 DECLARE @type4 NVARCHAR(200)      
      
 IF (@LeaveType = 'Hours')      
 BEGIN --ms      
  SET @type4 = @SubType      
 END --ms      
 ELSE      
 BEGIN --ms2      
  SET @type4 = (@SubType + '(' + @EnddateType + ')');      
 END --ms2      
 if not exists (select * from Common.AttendanceDetails (NOLOCK) where AttendenceId=@AttendanceMasterId3 and EmployeeId=@EmployeeId)      
 begin--mm      
 INSERT INTO [Common].[AttendanceDetails] (Id, EmployeeId, AttendenceId, UserCreated, CreatedDate, STATUS, EmployeeName, DepartmentId, DesignationId, ServiceEntityId, LeaveApplicationId, AttendanceType,CompanyId,AttendanceDate,DateValue)      
 VALUES (NEWID(), @EmployeeId, @AttendanceMasterId3, 'System', GETutcDATE(), 1, @Employeename, @DepartmentId, @DesignationId, @EntityId, @LeaveApplicationId, @type4,@CompanyId,convert(DATE, @Date),(cast ((replace(convert(varchar, @Date,102),'.','')) as bigint)))      
 end--mm      
 else      
 begin--mm      
 print @type4  
 print @LeaveApplicationId  
 print @AttendanceMasterId3  
 print @EmployeeId  
 update Common.AttendanceDetails WITH (UPDLOCK) set AttendanceType=@type4,LeaveApplicationId=@LeaveApplicationId where AttendenceId=@AttendanceMasterId3 and EmployeeId=@EmployeeId       
 end--mm      
END --mm2      
END      
  ----========================Attendance============================================================      
      END      
     END      
      
    END      
      
   Set @Date=dateadd(d,1,@Date)      
   END      
  END      
      
Commit Transaction      
      
 INSERT INTO dbo.TimeLogHistory (Id, ExecutionTime, LineNumber, LineText)      
    VALUES (NEWID(), GETDATE(), 16, 'Stored Procedure Execution Completed')      
      
End Try      
      
Begin Catch      
 Rollback;      
      
 Print 'In Catch Block';      
      
    SELECT
ERROR_MESSAGE()
AS
ErrorMessage, ERROR_NUMBER()
AS
ErrorNumber;   
 INSERT INTO dbo.TimeLogHistory (Id, ExecutionTime, LineNumber, LineText)      
    VALUES (NEWID(), GETDATE(), 16, 'Stored Procedure Execution Error')      
 Throw:      
      
End Catch       
      
End 
GO
