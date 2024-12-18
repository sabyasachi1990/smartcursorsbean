USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[SchedulerValidationBasedOnEmployee_proc]    Script Date: 16-12-2024 9.20.11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
    
    
                
CREATE PROCEDURE [dbo].[SchedulerValidationBasedOnEmployee_proc] (                    
  @CompanyId INT = 0      
 ,@CaseId Uniqueidentifier      
 ,@EmployeeId VARCHAR(Max)                    
 ,@Workweek VARCHAR(20),  
 @FromDate DateTime2(7),  
 @ToDate DateTime2(7),  
 @IsCopyorMove Bit  
 )                    
AS                    
BEGIN                    
 BEGIN TRY                    
  BEGIN TRAN                    
 Declare @CaseFromDate Datetime2(7),      
   @CaseToDate datetime2(7)    
   If (@IsCopyorMove=0)  
   Begin  
   IF EXISTS (Select 1 from WorkFlow.CaseGroup where Id=@CaseId)      
   BEGIN      
    SET @CaseFromDate=(Select FromDate from WorkFlow.CaseGroup where Id=@CaseId and CompanyId=@CompanyId)      
    SET @CaseToDate=(Select ToDate from WorkFlow.CaseGroup where Id=@CaseId and CompanyId=@CompanyId)      
    Select ST.EmployeeId,SUM(ISNULL(ST.PlannedHours,0))/60 as PlannedHours       
    from WorkFlow.ScheduleTaskNew ST      
    inner join WorkFlow.CaseGroup CG      
    on CG.Id=ST.CaseId and ST.CompanyId=@CompanyId      
    where (ST.StartDate between @CaseFromDate and @CaseToDate)      
    AND ST.EmployeeId in (Select items from SplitToTable(@EmployeeId,','))      
    AND (DATENAME(WW,ST.StartDate))=CONVERT(int,ISNULL(@Workweek,0))      
    group by ST.EmployeeId      
   END      
   End  
   Else  
      Begin  
  
  Select ST.EmployeeId,SUM(ISNULL(ST.PlannedHours,0))/60 as PlannedHours       
    from WorkFlow.ScheduleTaskNew ST      
    inner join WorkFlow.CaseGroup CG      
    on CG.Id=ST.CaseId and ST.CompanyId=@CompanyId      
    where (ST.StartDate between @FromDate and @ToDate)   
 AND ST.EmployeeId in (Select items from SplitToTable(@EmployeeId,','))      
    AND (DATENAME(WW,ST.StartDate))=CONVERT(int,ISNULL(@Workweek,0))      
    group by ST.EmployeeId      
  
  
  
   End  
  
  
  COMMIT TRAN                    
 END TRY                    
                    
 BEGIN CATCH                    
  SELECT ERROR_NUMBER() AS ErrorNumber                    
   ,ERROR_SEVERITY() AS ErrorSeverity                    
   ,ERROR_STATE() AS ErrorState                    
   ,ERROR_PROCEDURE() AS ErrorProcedure                    
   ,ERROR_LINE() AS ErrorLine                    
   ,ERROR_MESSAGE() AS ErrorMessage;                    
  ROLLBACK TRAN;                    
 END CATCH;                    
END 
GO
