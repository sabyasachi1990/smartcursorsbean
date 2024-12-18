USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[SP_DeleteCaseMembers]    Script Date: 16-12-2024 9.20.11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE Procedure [dbo].[SP_DeleteCaseMembers] @ID NVARCHAR(MAX), @CaseId uniqueidentifier,@EmployeeIds NVARCHAR(MAX)  
  
AS BEGIN  
BEGIN TRANSACTION  
   BEGIN TRY   
DECLARE @valueList Nvarchar(max)  
SET @valueList = @ID  
declare @Temp1 Table (Id uniqueidentifier);  
declare @Temp2 Table (EmployeeId uniqueidentifier,MasterId uniqueidentifier);  
  
  insert into @Temp2   
  SELECT  Distinct EmployeeId,MasterId  
  FROM Common.TimeLog L  
  INNER JOIN Common.TimeLogDetail tld ON tld.MasterId=L.Id  
  WHERE TimeLogItemId in(select Id from Common.TimeLogItem where SystemId=@CaseId and SystemType='CaseGroup')  
  AND EmployeeId  in (select Cast(items As uniqueidentifier) from SplitToTable(@EmployeeIds,','))  
  GROUP BY EmployeeId,MasterId  
  having  RIGHT('0' + CAST(   isnull(sum(DATEPART(SECOND, tld.Duration) + 60 *  DATEPART(MINUTE, tld.Duration) + 3600 * DATEPART(HOUR, tld.Duration )),0) / 3600 AS VARCHAR),2) + '.' +  
  RIGHT('0' + CAST((   isnull(sum(DATEPART(SECOND, tld.Duration) + 60 *  DATEPART(MINUTE, tld.Duration) + 3600 * DATEPART(HOUR, tld.Duration )),0) / 60) % 60 AS VARCHAR),2)='00.00'  
  ORDER BY MasterId  
  
  insert into @Temp1   
  select distinct(Id) from WorkFlow.ScheduleDetailNew where Id in ((Select Cast(items As uniqueidentifier) From SplitToTable(@valueList,',')))  
  
 --set @ScheduleDetailId = (select distinct(ScheduleDetailId) from WorkFlow.ScheduleTaskNew where EmployeeId in ((Select Cast(items As uniqueidentifier) From SplitToTable(@valueList,','))) and CaseId=@CaseId)  
  
delete  WorkFlow.ScheduleTaskNew where ScheduleDetailId in (select Id from @Temp1) and CaseId=@CaseId  
  
delete  WorkFlow.ScheduleDetailNew where Id in (select Id from @Temp1)  
delete  Common.TimeLogItemDetail where EmployeeId in (select Cast(items As uniqueidentifier) from SplitToTable(@EmployeeIds,','))  
and TimeLogItemId in(select Id from Common.TimeLogItem where SystemId=@CaseId and SystemType='CaseGroup')  
  
delete from Common.TimeLogDetailSplit where TimelogDetailId in   
   (  
   select Distinct Id from Common.TimeLogDetail where MasterId in ( select Distinct  MasterId  from @Temp2)  
   )  
  
delete from Common.TimeLogDetail where  MasterId in ( select Distinct  MasterId  from @Temp2)  
IF EXISTS(Select 1 from WorkFlow.TimeLogTasks where TimeLogId in (Select Id from Common.TimeLog where id in ( select Distinct  MasterId  from @Temp2)  
and EmployeeId in ( select Distinct  EmployeeId  from @Temp2)))
BEGIN
	Delete from WorkFlow.TimeLogTasks 
	where TimeLogId in (Select Id from Common.TimeLog where id in ( select Distinct  MasterId  from @Temp2)  
and EmployeeId in ( select Distinct  EmployeeId  from @Temp2)) 
END
delete from Common.TimeLog where id in ( select Distinct  MasterId  from @Temp2)  
and EmployeeId in ( select Distinct  EmployeeId  from @Temp2)  
  
 Exec [dbo].[sp_updateEmployeedeptIsLockLogFlag] @EmployeeIds  
  
BEGIN   
      COMMIT TRANSACTION  
    END  
   END TRY  
  
   BEGIN CATCH  
        DECLARE  
        @ErrorMessage NVARCHAR(4000),  
        @ErrorSeverity INT,  
        @ErrorState INT;  
        SELECT  
        @ErrorMessage = ERROR_MESSAGE(),  
        @ErrorSeverity = ERROR_SEVERITY(),  
        @ErrorState = ERROR_STATE();  
        RAISERROR (@ErrorMessage,@ErrorSeverity,@ErrorState);  
    ROLLBACK TRANSACTION  
    END CATCH  
  
end 
GO
