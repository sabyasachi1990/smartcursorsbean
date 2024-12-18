USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[Proc_AppraiseeInsertSelected]    Script Date: 16-12-2024 9.20.11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
                
                    
CREATE procedure [dbo].[Proc_AppraiseeInsertSelected]  (@AppraisalId uniqueidentifier,@EmployeeIds TempAppraisalAppraisees readonly,@IsEdit bit ,@CompanyId bigint, @IsSelectionChanged bit,                   
@TempApprisers TempAppraisers Readonly,@IsFirstSave bit,@questionarieId uniqueidentifier)                        
AS                        
Begin--s1                        
                        
BEGIN TRANSACTION--s2                        
 BEGIN TRY--s3             
        declare @casemeberonly bit = (select CaseMembersOnly from hr.Appraisal where id=@AppraisalId and CompanyId=@CompanyId)  
      
 If(@IsFirstSave=0)          
  Begin          
    
    
   if(@casemeberonly=1)  
  begin  
    
          insert into [HR].[AppraisalAppraiseeDetails] ( [Id],[AppraisalId],[EmployeeId],[DepartmentId],[DesignationId],[Level],          
                                                        [Recorder],[AppraiserIds],[RepliedCount],[AppraiserCount],[IsSelected] )                       
         select NEWID(),@AppraisalId,Id,DepartmentId,DesignationId,null,null,null,null,0,0 from                    
         Common.Employee          
         WHERE  IdType is not null and Status=1 and CompanyId=@CompanyId            
            AND Id IN (SELECT EmployeeId FROM @EmployeeIds WHERE  EmployeeId NOT IN          
                            (SELECT DISTINCT EmployeeId FROM [HR].[AppraisalAppraiseeDetails] WHERE AppraisalId = @AppraisalId)and EmployeeId in (select distinct EmployeeId from WorkFlow.ScheduleDetailNew))          
            
  End  
  else  
  begin  
  insert into [HR].[AppraisalAppraiseeDetails] ( [Id],[AppraisalId],[EmployeeId],[DepartmentId],[DesignationId],[Level],          
                                                        [Recorder],[AppraiserIds],[RepliedCount],[AppraiserCount],[IsSelected] )                       
         select NEWID(),@AppraisalId,Id,DepartmentId,DesignationId,null,null,null,null,0,0 from                    
         Common.Employee          
         WHERE  IdType is not null and Status=1 and CompanyId=@CompanyId            
            AND Id IN (SELECT EmployeeId FROM @EmployeeIds WHERE  EmployeeId NOT IN          
                            (SELECT DISTINCT EmployeeId FROM [HR].[AppraisalAppraiseeDetails] WHERE AppraisalId = @AppraisalId))    
  end  
  end  
  
  Else          
          
  Begin     
    
  
  
    
   if(@casemeberonly=1)  
  begin  
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
                           APPRAISALQUE.QuestionarieId=@questionarieId and E.Status=1 and E.IdType is not null and CompanyId=@CompanyId and id in (select EmployeeId from Workflow.ScheduleDetailnew)  
 end  
 else  
 begin  
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
                           APPRAISALQUE.QuestionarieId=@questionarieId and E.Status=1 and E.IdType is not null and CompanyId=@CompanyId   
  End          
                  
   end                 
        
 Update [HR].[AppraisalAppraiseeDetails] set IsSelected=1 where EmployeeId in (Select EmployeeId from @EmployeeIds where RecordStatus='Added')                
      and AppraisalId=@AppraisalId              
              
       Update [HR].[AppraisalAppraiseeDetails] set IsSelected=0 where EmployeeId not in (Select EmployeeId from @EmployeeIds where RecordStatus='Added')                
       and AppraisalId=@AppraisalId           
    Update Hr.Appraisal set AppraiseesCount= (Select Count(EmployeeId) from HR.AppraisalAppraiseeDetails where AppraisalId in (@AppraisalId) and IsSelected=1)           
   where Id=@AppraisalId       
            
   If(@IsSelectionChanged=1)            
      Begin            
            
   Delete HR.AppraiseAppraisers where AppraisalDetailId in (Select Id from HR.AppraisalAppraiseeDetails where AppraisalId in (@AppraisalId))            
   Update Hr.Appraisal set AppraisersCount=(Select Count(Distinct(AppraiserId)) from HR.AppraiseAppraisers             
   where AppraisalDetailId in (Select Id from HR.AppraisalAppraiseeDetails where AppraisalId in (@AppraisalId)))            
   where Id=@AppraisalId            
            
   End            
                  
              
    IF((Select COUNT(AppraiseeId) from  @TempApprisers)>0)              
  BEGIN              
     EXEC HR.AppraiseAppraisersInsertDelete_Proc @AppraisalId,@TempApprisers                 
 END              
                                 
 --select * from [HR].[AppraisalAppraiseeDetails]                        
 --if exists (select  EmployeeId from @EmployeeIds where RecordStatus='Deleted' )                        
 --begin                        
 -- delete HR.AppraiseAppraisers where AppraisalDetailId in (select [Id ] from HR.AppraisalAppraiseeDetails where AppraisalId=@AppraisalId and EmployeeId in (select  EmployeeId from @EmployeeIds where RecordStatus='Deleted'))                        
 -- delete HR.AppraisalResult where AppraisalId=@AppraisalId and AppraiseeId in (select  EmployeeId from @EmployeeIds where RecordStatus='Deleted')                        
 -- Delete HR.AppraisalAppraiseeDetails where AppraisalId=@AppraisalId and EmployeeId in (select  EmployeeId from @EmployeeIds where RecordStatus='Deleted')                        
 --end                        
                        
                   
                        
 --update HR.Appraisal set AppraiseesCount =(select count(Id) from [HR].[AppraisalAppraiseeDetails] where [AppraisalId]=@AppraisalId) where id=@AppraisalId                        
Commit Transaction--s2                        
 End try --s3                        
 Begin Catch                        
  ROLLBACK TRANSACTION                        
  DECLARE                        
    @ErrorMessage NVARCHAR(4000),                        
    @ErrorSeverity INT,                
    @ErrorState INT;                        
  SELECT                        
    @ErrorMessage = ERROR_MESSAGE(),                        
    @ErrorSeverity = ERROR_SEVERITY(),                        
    @ErrorState = ERROR_STATE();                        
  RAISERROR (@ErrorMessage,@ErrorSeverity,@ErrorState);                        
 End Catch                        
End   
  
  
  
  
  
  
--insert into common.TimeLogItem values(NewId(),1,'Leaves','Annual','Non-Available','LeaveApplication','78d671ce-e8ab-4069-be02-375f87771648',1,0,'2023-06-09 00:00:00.0000000','2023-06-09 00:00:00.0000000',null,null,'System',GetDate(),null,null,null,1,'8.00','1.00',null,null,null,null,null,null,null,null,'0.00')     --insert into common.TimeLogItemDetail values (newId(),(select Id from common.TimeLogItem where SystemId='78d671ce-e8ab-4069-be02-375f87771648' and  startDate='2023-06-09 00:00:00.0000000'),'2a7ca6a7-f0a8-4c1b-88a3-b57b61bb1abf',null)  
GO
