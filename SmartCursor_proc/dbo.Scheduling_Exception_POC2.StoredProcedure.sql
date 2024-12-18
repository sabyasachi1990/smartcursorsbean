USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[Scheduling_Exception_POC2]    Script Date: 16-12-2024 9.20.11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE   PROCEDURE [dbo].[Scheduling_Exception_POC2]       
--(@CompanyId Int,@EmployeeId Uniqueidentifier,@hours int ,@TaskDate Datetime,@TaskId uniqueIdentifier,@RecordStatus nvarchar(15))
(@SchedulingExceptions SchedulingExcpTempTable READONLY)

AS      
BEGIN      

DECLARE             
@ScheduleStartDate Date,            
@ScheduleEndDate Date ,            
@24hrsStatus Nvarchar(20),            
@WeeklyWorkHours  decimal(15,2),                  
@ErrorMsg Nvarchar(500),             
@fromEmployeePlannedhours bigint,        
@toEmployeePlannedhours Bigint,        
@workweekdays int  ,    
@PlannedHours  decimal(15,2) ,    
@OverRunHours  decimal(15,2) ,    
@WeekStartDate DateTime2(7),    
@WeekEnddate DateTime2(7),    
@dateTimeNow DATETIME,
@CompanyId Int,@EmployeeId Uniqueidentifier,@hours int ,@TaskDate Datetime,@TaskId uniqueIdentifier,@RecordStatus nvarchar(15)

CREATE TABLE #TempRead  (CompanyId Int,EmployeeId Uniqueidentifier,hours int ,TaskDate Datetime,TaskId uniqueIdentifier,RecordStatus nvarchar(15))

INSERT INTO #TempRead
SELECT * FROM @SchedulingExceptions

BEGIN TRAN      

BEGIN TRY  

WHILE (SELECT COUNT(*) FROM #TempRead) > 0
BEGIN
  SELECT TOP 1 @CompanyId = CompanyId,@EmployeeId = EmployeeId,@hours = hours,@TaskDate = TaskDate,@TaskId = TaskId, @RecordStatus = RecordStatus
  FROM #TempRead;

DECLARE @EmpName Nvarchar(200),@StartDate DateTime2, @EndDate DateTime2,  @TotalHours  decimal(15,2)

SET @ScheduleStartDate = CAST(@TaskDate as Date)         
SET @24hrsStatus = (SELECT IsAllowTwentyFourHours FROM common.FeeRecoverySetting (NOLOCK) WHERE CompanyId = @CompanyId)       
SET @workweekdays=(Select COUNT(Id) from Common.WorkWeekSetUp (NOLOCK) where CompanyId=@CompanyId and IsWorkingDay=1 and EmployeeId is null)      
SET @WeeklyWorkHours =            
       (            
        SELECT                
      SUM(WorkingHoursMinutes) as WeeklyWorkingHours            
        FROM            
        (            
        SELECT  Id,(DATEPART(HOUR, WorkingHours)*60) + (DATEPART(MINUTE, WorkingHours)) as WorkingHoursMinutes             
        FROM             
      Common.WorkWeekSetUp (NOLOCK)          
        WHERE CompanyId = @CompanyId and IsWorkingDay=1     and EmployeeId is null      
        ) A   )     
  
set @EmpName = (Select FirstName from common.Employee (NOLOCK) where Id=@EmployeeId)    
    
set @dateTimeNow = CAST(@TaskDate as Date) 
set @WeekStartDate = DATEADD(DAY, 2 - DATEPART(WEEKDAY, @dateTimeNow), CAST(@dateTimeNow AS DATE)) 
set @WeekEnddate = DATEADD(DAY, @workweekdays-1,@WeekStartDate)

if(@RecordStatus='Added')    
begin  
  
set @PlannedHours= (SELECT                
      SUM(PlannedHours)             
        FROM            
        (select PlannedHours from WorkFlow.ScheduleNew as sch (NOLOCK) join WorkFlow.ScheduleDetailNew as schd (NOLOCK) on sch.Id=schd.MasterId   
      join WorkFlow.ScheduleTaskNew as scht (NOLOCK) on schd.Id=scht.ScheduleDetailId where scht.StartDate>=@WeekStartDate and   
   scht.EndDate<=@WeekEnddate and scht.EmployeeId=@EmployeeId and sch.companyId=@CompanyId)A )    
end    
else if(@RecordStatus='Modified')    
begin    
set @PlannedHours= (SELECT                
      SUM(PlannedHours)             
        FROM            
        (select PlannedHours from WorkFlow.ScheduleNew as sch (NOLOCK) join WorkFlow.ScheduleDetailNew as schd (NOLOCK) on sch.Id=schd.MasterId join WorkFlow.ScheduleTaskNew as scht (NOLOCK) on schd.Id=scht.ScheduleDetailId where scht.StartDate>=@WeekStartDate and scht.EndDate<=@WeekEnddate and scht.EmployeeId=@EmployeeId and sch.companyId=@CompanyId and scht.Id!=@TaskId)A )    
end    

SET @TotalHours= IsNull(@PlannedHours,0)+ @hours   
    
-------=============================================== EXCEPTION THROWING ===============================================-----      
   --BEGIN TRAN      

   --BEGIN TRY      
     IF (@24hrsStatus = 1 AND  @TotalHours > @WeeklyWorkHours)       
     BEGIN      
        
     SET @ErrorMsg = CONCAT('Planned weekly hours are greater than ',CAST(@WeeklyWorkHours/60 AS decimal(5,2)) ,' hours (',@EmpName,'). Do you Want to Continue?')           
     RAISERROR(@ErrorMsg,16,1);            
     END      
     IF (@24hrsStatus != 1 AND ((@hours) > 1439))           
        BEGIN            
         SET @ErrorMsg = CONCAT('Invalid time records as daily hours (',@EmpName, ') have exceeded 24 hours ')            
         RAISERROR(@ErrorMsg,16,1);            
        END     
 IF (@24hrsStatus != 1 AND  @TotalHours > @WeeklyWorkHours)       
     BEGIN      
        
     SET @ErrorMsg = CONCAT('Invalid time records as hours (',@EmpName,') have exceeded ', CAST(@WeeklyWorkHours/60 AS decimal(5,2)),' hours')           
     RAISERROR(@ErrorMsg,16,1);            
     END     
   --COMMIT TRAN      
   --END TRY      
   --BEGIN CATCH          
   --ROLLBACK TRANSACTION       
   -- RAISERROR(@ErrorMsg, 16,1);      
   --END CATCH      

DELETE FROM #TempRead WHERE 
CompanyId = @CompanyId AND EmployeeId = @EmployeeId AND hours = @hours AND TaskDate = @TaskDate AND TaskId = @TaskId AND  RecordStatus = @RecordStatus
-------==================================================================================================================-----   

END
   COMMIT TRAN      
   END TRY      
   BEGIN CATCH          
   ROLLBACK TRANSACTION       
    RAISERROR(@ErrorMsg, 16,1);      
   END CATCH 

DROP TABLE #TempRead

END
GO
