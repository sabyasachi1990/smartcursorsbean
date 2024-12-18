USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[Proc_AppraiseeInsertAll]    Script Date: 16-12-2024 9.20.11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

          
CREATE PROCEDURE [dbo].[Proc_AppraiseeInsertAll]                    
( @AppraisalId uniqueidentifier,  @IsEdit bit, @CompanyId bigint, @appraiseeIds TempAppraisalAppraisees READONLY,@isSelectionChanged bit          
,@TempApprisers TempAppraisers Readonly,@questionarieId  uniqueidentifier)          
          
                    
AS                    
BEGIN --s1                      
                    
                    
                    
                    
    BEGIN TRANSACTION --s2                      
                    
    BEGIN TRY --s3                      
                
                          
                
              If Not Exists((Select Id from Hr.AppraisalAppraiseeDetails where AppraisalId=@AppraisalId))          
     Begin          
                 IF((Select COUNT(EmployeeId) from @appraiseeIds)=0)           
                     Begin              
                           
                            ; WITH CTE  
                           AS  
                           (  
                           SELECT   
                               QuestionarieId = col1.value,   
                               DepartmentId = col2.value,   
                               DesignationId = col3.value  
                           FROM   
                               (SELECT @questionarieId as value) col1  
                           CROSS JOIN   
                               (SELECT value FROM (Select DepartmentId from HR.Questionnaire where Id=@questionarieId) A CROSS APPLY STRING_SPLIT(DepartmentId, ',')) col2  
                           CROSS JOIN   
                               (SELECT value FROM (Select DesignationId from HR.Questionnaire where Id=@questionarieId) A CROSS APPLY STRING_SPLIT(DesignationId, ',')) col3  
                           --ORDER BY   
                           --    col1.value, col2.value, col3.value  
                           ) --SELECT * FROM CTE ----  
         INSERT INTO [HR].[AppraisalAppraiseeDetails] ([Id], [AppraisalId], [EmployeeId], [DepartmentId], [DesignationId], [Level], [Recorder], [AppraiserIds], [RepliedCount], [AppraiserCount],[IsSelected])                      
                           SELECT NEWID(), @AppraisalId, E.Id, E.DepartmentId,  E.DesignationId, NULL,  NULL, NULL, NULL, 0 ,1                   
                           FROM Common.Employee  as E                                         
                           JOIN CTE as APPRAISALQUE on E.DepartmentId=APPRAISALQUE.DepartmentId and E.DesignationId=APPRAISALQUE.DesignationId   
                           WHERE   
                           APPRAISALQUE.QuestionarieId=@questionarieId  
         
  
  
  
                           
                   End             
    End          
               
  If ((Select Count(EmployeeId) from @appraiseeIds)>0)          
    Begin          
          Update [HR].[AppraisalAppraiseeDetails] set IsSelected=1 where EmployeeId in (Select EmployeeId From @appraiseeIds where IsChecked=1) and AppraisalId=@AppraisalId           
          Update [HR].[AppraisalAppraiseeDetails] set IsSelected=0 where EmployeeId in (Select EmployeeId From @appraiseeIds where IsChecked=0) and AppraisalId=@AppraisalId          
    End          
  Else if ((Select Count(EmployeeId) from @appraiseeIds)=0)          
   Begin          
          
          Update [HR].[AppraisalAppraiseeDetails] set IsSelected=1 where  AppraisalId=@AppraisalId          
                      
    End          
                         
  IF((Select COUNT(AppraiseeId) from  @TempApprisers)>0)          
   BEGIN          
     EXEC HR.AppraiseAppraisersInsertDelete_Proc @AppraisalId,@TempApprisers             
   END          
        
   If(@isSelectionChanged=1)        
      Begin        
        
   Delete HR.AppraiseAppraisers where AppraisalDetailId in (Select Id from HR.AppraisalAppraiseeDetails where AppraisalId in (@AppraisalId))        
    Update Hr.Appraisal set AppraisersCount=(Select Count(Distinct(AppraiserId)) from HR.AppraiseAppraisers         
   where AppraisalDetailId in (Select Id from HR.AppraisalAppraiseeDetails where AppraisalId in (@AppraisalId)))        
   where Id=@AppraisalId        
   End        
                        
                    
                    
                           
          If((Select COUNT(EmployeeId) From @appraiseeIds)=0)          
    Begin          
             UPDATE HR.Appraisal                    
             SET AppraiseesCount = ( SELECT COUNT(Id) FROM [HR].[AppraisalAppraiseeDetails] WHERE [AppraisalId] = @AppraisalId )                    
             WHERE id = @AppraisalId                
  End          
                    
        COMMIT TRANSACTION --s2                      
    END TRY --s3                      
                    
    BEGIN CATCH                    
        ROLLBACK TRANSACTION                    
                    
        DECLARE @ErrorMessage nvarchar(4000),                    
                @ErrorSeverity int,                    
                @ErrorState int;                    
                    
        SELECT @ErrorMessage = ERROR_MESSAGE(),                    
               @ErrorSeverity = ERROR_SEVERITY(),                    
               @ErrorState = ERROR_STATE();                    
                    
        RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState);                    
    END CATCH                 
                    
                    
                    
                    
END
GO
