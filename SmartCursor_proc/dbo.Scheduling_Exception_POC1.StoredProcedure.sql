USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[Scheduling_Exception_POC1]    Script Date: 16-12-2024 9.20.11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
  

----============================================= EXECUTE STATEMENT ============================================-----
--DECLARE @PHours decimal(15,2) ,@THours decimal(15,2),@WeekHours decimal(15,2)

--EXEC [dbo].[Scheduling_Exception_POC1] 1,'b4c63660-d5c6-4198-b760-d562876badcc',8.00,'2023-04-03',
--'ea7653d8-8e12-44f9-81fa-ef71dba393e7','Added'
--,@PHours output,@THours output,@WeekHours output


--SELECT @PHours AS [Planned Hours],@THours as [Total Hours],@WeekHours as [Weekly Hours]

----============================================================================================================-----

CREATE PROCEDURE [dbo].[Scheduling_Exception_POC1]       
(@CompanyId Int,@EmployeeId Uniqueidentifier,@hours int ,@TaskDate Datetime,@TaskId uniqueIdentifier,@RecordStatus nvarchar(15))
--,@PHours decimal(15,2) OUTPUT,@THours decimal(15,2) OUTPUT,@WeekHours decimal(15,2) OUTPUT)      

AS      
BEGIN      
    
 --Declare @CompanyId Int=2095,  
 --@EmployeeId Uniqueidentifier='1bb19f43-1e9e-8009-8b2f-a31ae64701a1',  
 --@hours Decimal=10.00,  
 --@TaskDate Datetime='2023-02-02',  
 --@TaskId uniqueIdentifier='f275be52-bab2-41df-bd13-d1e85ad7aff0',  
 --@RecordStatus nvarchar(15)='Added'  
     
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
@dateTimeNow DATETIME    


DECLARE @EmpName Nvarchar(200),@StartDate DateTime2, @EndDate DateTime2,  @TotalHours  decimal(15,2)

SET @ScheduleStartDate = @TaskDate            
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
    
set @dateTimeNow = @TaskDate  
set @WeekStartDate = DATEADD(DAY, 2 - DATEPART(WEEKDAY, @dateTimeNow), CAST(@dateTimeNow AS DATE)) 
set @WeekEnddate = DATEADD(DAY, @workweekdays-1,@WeekStartDate)

----set @WeekStartDate = DATEADD(DAY, -(DATEPART(WEEKDAY, @dateTimeNow)-1),     
----                      DATEADD(DAY, DATEDIFF(DAY, 0, @dateTimeNow), 0))    
----   set @WeekEnddate = DATEADD(DAY, 7-(DATEPART(WEEKDAY, @dateTimeNow)),     
----                    DATEADD(SECOND, -1, DATEADD(DAY, DATEDIFF(DAY, 0, @dateTimeNow) + 1, 0))) 
					

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
    
--SELECT  @PHours = @PlannedHours,@THours = @TotalHours,@WeekHours = @WeeklyWorkHours
-------=============================================== EXCEPTION THROWING ===============================================-----      
   BEGIN TRAN      
----Select @PlannedHours  
----Select @TotalHours  
----Select @hours  
   BEGIN TRY      
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
   COMMIT TRAN      
   END TRY      
   BEGIN CATCH          
   ROLLBACK TRANSACTION       
    RAISERROR(@ErrorMsg, 16,1);      
   END CATCH      
-------==================================================================================================================-----   
  
END
GO
