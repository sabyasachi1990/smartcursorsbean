USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [HR].[Delete_Appraisee_Apraisal]    Script Date: 16-12-2024 9.20.11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

   
    
CREATE Proc [HR].[Delete_Appraisee_Apraisal]         
@AppraisalId uniqueidentifier,        
@appraiseeIds nvarchar(Max)        
AS                  
Begin--s1                  
                  
BEGIN TRANSACTION--s2                  
 BEGIN TRY--s3                  
      DECLARE @ErrMessage Nvarchar(max)          
        
        
      Delete HR.AppraiseAppraisers where AppraisalDetailId in        
   (Select Id from HR.AppraisalAppraiseeDetails where AppraisalId in (@AppraisalId) and EmployeeId in (      
   (SELECT CAST([value] AS uniqueidentifier) as AppraiseeId from STRING_SPLIT(@appraiseeIds, ','))))      

    Delete HR.AppraiserIncharge where AppraisalDetailId in        
   (Select Id from HR.AppraisalAppraiseeDetails where AppraisalId in (@AppraisalId) and EmployeeId in (      
   (SELECT CAST([value] AS uniqueidentifier) as AppraiseeId from STRING_SPLIT(@appraiseeIds, ','))))      
      
      Delete HR.AppraisalAppraiseeDetails where AppraisalId in (@appraisalId) and EmployeeId in         
     (SELECT CAST([value] AS uniqueidentifier) as AppraiseeId from STRING_SPLIT(@appraiseeIds, ','))        
      
    If((Select AppraiserList from HR.Appraisal where Id=@AppraisalId)='Selected')  
   Begin  
         Update HR.Appraisal set       
         AppraiseesCount=(Select Count(Id) from HR.AppraisalAppraiseeDetails where AppraisalId in (@AppraisalId) and IsSelected=1)      
         where Id=@AppraisalId          
              
         Update HR.Appraisal set AppraisersCount =(Select Count(Distinct(AppraiserId)) From Hr.AppraiseAppraisers (NoLock) where AppraisalDetailId in           
         (Select Id from hr.AppraisalAppraiseeDetails (NoLock) where AppraisalId =@AppraisalId and IsSelected=1))       
         where Id=@AppraisalId    
  End  
 Else  
   Begin  
         Update HR.Appraisal set       
         AppraiseesCount=(Select Count(Id) from HR.AppraisalAppraiseeDetails where AppraisalId in (@AppraisalId))      
         where Id=@AppraisalId          
              
         Update HR.Appraisal set AppraisersCount =(Select Count(Distinct(AppraiserId)) From Hr.AppraiseAppraisers (NoLock) where AppraisalDetailId in           
         (Select Id from hr.AppraisalAppraiseeDetails (NoLock) where AppraisalId =@AppraisalId))       
         where Id=@AppraisalId    
  End  
  
      
  Select AppraisersCount as AppraisersCount,AppraiseesCount as AppraiseesCount from Hr.Appraisal where Id=@AppraisalId      
        
 COMMIT TRAN          
END TRY          
           
BEGIN CATCH          
    ROLLBACK          
    SET @ErrMessage = ERROR_MESSAGE()          
    RAISERROR(@ErrMessage, 16,1);              
          
      
          
END CATCH          
  End
GO
