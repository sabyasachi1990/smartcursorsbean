USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[HR_Calander_AttendanceSync]    Script Date: 16-12-2024 9.20.10 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
  
CREATE PROCEDURE [dbo].[HR_Calander_AttendanceSync] (@CompanyId BIGINT, @CalanderId UNIQUEIDENTIFIER)  
AS  
BEGIN  
 BEGIN TRANSACTION  
  
 BEGIN TRY  
  DECLARE @CalanderData_Tbl TABLE (S_No INT Identity(1, 1), TimelogItemId UNIQUEIDENTIFIER, SubType NVARCHAR(500), ChargeType NVARCHAR(100), TimeType NVARCHAR(100), StartDate DATETIME2(7),ApplyTo NVARCHAR(50))  
  declare @Employeetable table (S_No INT Identity(1, 1),EmployeeId uniqueidentifier,FirstName NVARCHAR(500),DepartmentId uniqueidentifier,DesignationId uniqueidentifier,EntityId Bigint)  
  Declare @TotalCount int   
  declare @LoopCount int=1  
  declare @SubType NVARCHAR(500)  
  declare @ChargeType NVARCHAR(100)  
  declare @TimeType NVARCHAR(100)  
  declare @StartDate DATETIME2(7)  
  declare @ApplyTo NVARCHAR(200)  
  DECLARE @Weekends TABLE (Weekends NVARCHAR(20))  
  INSERT INTO @Weekends  
  SELECT WeekDay  
  FROM common.WorkWeekSetUp  
  WHERE EmployeeId IS NULL AND CompanyId = @CompanyId AND IsWorkingDay = 0  
  
  update Common.AttendanceDetails set AttendanceType =null  WHERE CalanderId = @CalanderId  
  
  INSERT INTO @CalanderData_Tbl  
  SELECT distinct TL1.Id, TL1.SubType, TL1.ChargeType, TL1.TimeType, TL1.StartDate,CA.ApplyTo   
  FROM Common.TimeLogItem TL  
  JOIN Common.TimeLogItem TL1 ON TL.Id = TL1.SystemId  
  JOIN Common.Calender CA ON TL.SystemId = CA.Id  
  WHERE TL.SystemId = @CalanderId AND CA.STATUS = 1 AND CA.Id = @CalanderId AND TL1.Type = 'Holidays'  
  set @TotalCount=(  
    SELECT count(*)  
    FROM @CalanderData_Tbl  
    )  
      if(@TotalCount>0)  
   begin--k  
   set @ApplyTo=(select ApplyTo from @CalanderData_Tbl where S_No=1)  
   if(@ApplyTo='All')  
   begin --i  
   insert into @Employeetable   
   select Id,FirstName,DepartmentId,DesignationId,CurrentServiceEnittyId from Common.Employee where CompanyId=@CompanyId and Status=1  
   end--i  
   else  
   begin --j  
   insert into @Employeetable   
   select Id,FirstName,DepartmentId,DesignationId,CurrentServiceEnittyId from Common.Employee where CompanyId=@CompanyId and Status=1 and Id in (select EmployeeId from Common.CalenderDetails where MasterId=@CalanderId)  
   end --j  
   end--k  
  
  while @TotalCount>=@LoopCount  
  begin--1  
  select @SubType=SubType,@ChargeType=ChargeType,@TimeType=TimeType,@StartDate=StartDate from @CalanderData_Tbl where S_No=@LoopCount  
  if  ( datename(dw, @StartDate)not IN (  
    SELECT *  
    FROM @Weekends  
    ))  
    begin--mm  
 IF  EXISTS (  
  SELECT id  
  FROM [Common].[Attendance]  
  WHERE convert(DATE, [Date]) = convert(DATE, @StartDate) AND CompanyId = @CompanyId  
  )  
  begin --2  
  declare @attendanceId uniqueidentifier=(SELECT id  
  FROM [Common].[Attendance]  
  WHERE convert(DATE, [Date]) = convert(DATE, @StartDate) AND CompanyId = @CompanyId)  
  update [Common].[AttendanceDetails] set AttendanceType=@ChargeType,CalanderId=@CalanderId where  AttendenceId= @attendanceId  and employeeId in (select EmployeeId from @Employeetable) and CalanderId is  null

    update [Common].[AttendanceDetails] set AttendanceType=null,CalanderId=null where  AttendenceId= @attendanceId  and employeeId not in (select EmployeeId from @Employeetable) and CalanderId is not null
  
  INSERT INTO [Common].[AttendanceDetails] (Id, EmployeeId, AttendenceId, UserCreated, CreatedDate, STATUS, EmployeeName, DepartmentId, DesignationId, ServiceEntityId, AttendanceType,CalanderId,CompanyId,AttendanceDate,DateValue)  
  select NEWID(),EmployeeId,@attendanceId,'System',GETUTCDATE(),1 ,FirstName ,DepartmentId ,DesignationId ,EntityId ,@ChargeType,@CalanderId,@CompanyId,convert(DATE, @StartDate),(cast ((replace(convert(varchar, @StartDate,102),'.','')) as bigint)) from @Employeetable where EmployeeId not in (select EmployeeId from [Common].[AttendanceDetails] where  AttendenceId= @attendanceId)  
  end--2  
  else  
  begin--3  
  DECLARE @AttendanceMasterId2 UNIQUEIDENTIFIER = newid();  
  
 INSERT INTO Common.Attendance (Id, CompanyId, DATE, STATUS)  
 VALUES (@AttendanceMasterId2, @CompanyId, convert(DATE, @StartDate), 1)  
 INSERT INTO [Common].[AttendanceDetails] (Id, EmployeeId, AttendenceId, UserCreated, CreatedDate, STATUS, EmployeeName, DepartmentId, DesignationId, ServiceEntityId, AttendanceType,CalanderId,CompanyId,AttendanceDate,DateValue)  
  select NEWID(),EmployeeId,@AttendanceMasterId2,'System',GETUTCDATE(),1 ,FirstName ,DepartmentId ,DesignationId ,EntityId ,@ChargeType,@CalanderId,@CompanyId,convert(DATE, @StartDate),(cast ((replace(convert(varchar, @StartDate,102),'.','')) as bigint)) 
from @Employeetable   
  end--3  
  end--mm  
  set @LoopCount=@LoopCount+1  
  
  end--1  
  
  
  
  
  COMMIT TRANSACTION  
 END TRY  
  
 BEGIN CATCH  
  ROLLBACK TRANSACTION  
  
  DECLARE @ErrorMessage NVARCHAR(4000) --, @ErrorSeverity INT, @ErrorState INT;  
  
  SELECT @ErrorMessage = ERROR_MESSAGE() --, @ErrorSeverity = ERROR_SEVERITY(), @ErrorState = ERROR_STATE();    
  
  RAISERROR (@ErrorMessage, 16, 1)  
 END CATCH  
END  
GO
