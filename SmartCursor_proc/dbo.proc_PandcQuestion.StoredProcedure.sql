USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[proc_PandcQuestion]    Script Date: 16-12-2024 9.20.11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

--exec proc_PandcQuestion

CREATE PROCEDURE [dbo].[proc_PandcQuestion]
As begin 

 BEGIN TRANSACTION
 BEGIN TRY 

Declare @EngagementId uniqueidentifier;
DECLARE PAC CURSOR FOR SELECT Id FROM  Audit.AuditCompanyEngagement where AuditCompanyId in (select Id from audit.AuditCompany where CompanyId in (select Id from common.Company where Name In(
       'HONAV SINGAPORE PTE. LTD.',
       'VUNGLE SEA PTE. LTD.',
       'TAXUMO PTE. LTD.',
       'IIC INTERNATIONAL INVESTMENT COMPANY PTE. LTD.',
       'ITLINK BUSINESS SOLUTIONS (S) PTE LTD',
       'NEXPERIA SINGAPORE PTE. LTD.',
       'DATABRICKS ASIAPAC UNIFIED ANALYTICS PTE. LTD.',
       'MALAYAN RACING ASSOCIATION BENEVOLENT FUND',
       'VICTOR BUCK SERVICES ASIA PTE. LTD.',
       'PXG ASIA PTE. LTD.',
       'ASTON AGRO INDUSTRIAL PTE. LTD.',
       'BOILN PLASTICS (SINGAPORE) PTE. LTD.',
       'JBC ASIA PTE. LTD.',
       'FUTURTECH SG PTE. LTD.',
       'RUTRONIK ELECTRONICS SINGAPORE PTE. LTD.') and ParentId is null))        
   OPEN PAC      
   FETCH NEXT FROM PAC INTO @EngagementId
   WHILE (@@FETCH_STATUS=0)      
   BEGIN 
  --   select * from audit.PlanningAndCompletionSetUp where   menucode='AP-2' and engagementType='Statutory Audit' and EngagementId=@EngagementId
	 --select * from audit.PAndCSections where PlanningAndCompletionSetUpId in (select id from Audit.PlanningAndCompletionSetUp where EngagementId=@EngagementId and menucode='AP-2' and engagementType='Statutory Audit') and Heading ='A) Client’s Characteristic and Integrity.'

     declare @pandcsectionId uniqueidentifier=((select Id from audit.PAndCSections where PlanningAndCompletionSetUpId in (select id from Audit.PlanningAndCompletionSetUp where EngagementId=@EngagementId and menucode='AP-2' and engagementType='Statutory Audit' and EngagementId=@EngagementId) and Heading ='A) Client’s Characteristic and Integrity.'));
   print @pandcsectionId;
   if not exists(select * from Audit.PAndCSectionQuestions where PreviousQuestionId='AC6D9BE1-D050-126A-4820-C472483064BB' and PAndCSectionId=@pandcsectionId)         
       begin
   Insert Into Audit.PAndCSectionQuestions (Id,PAndCSectionId,Question,QuestionOptions,IsComment,IsAttachement,AttachmentsCount,UserCreated,CreatedDate,ModifiedDate,Status,Recorder,PreviousQuestionId) select NEWID (),@pandcsectionId,Question,QuestionOptions,IsComment,IsAttachement,AttachmentsCount,UserCreated,CreatedDate,ModifiedDate,Status,Recorder,PreviousQuestionId from Audit.PAndCSectionQuestions where id='AC6D9BE1-D050-126A-4820-C472483064BB'
   End
    if not exists(select * from Audit.PAndCSectionQuestions where PreviousQuestionId='9AD02A14-8D29-ED71-EA02-AEABD4C97FC3' and PAndCSectionId=@pandcsectionId)         
       begin
   Insert Into Audit.PAndCSectionQuestions (Id,PAndCSectionId,Question,QuestionOptions,IsComment,IsAttachement,AttachmentsCount,UserCreated,CreatedDate,ModifiedDate,Status,Recorder,PreviousQuestionId) select NEWID (),@pandcsectionId,Question,QuestionOptions,IsComment,IsAttachement,AttachmentsCount,UserCreated,CreatedDate,ModifiedDate,Status,Recorder,PreviousQuestionId from Audit.PAndCSectionQuestions where id='9AD02A14-8D29-ED71-EA02-AEABD4C97FC3'

end

if not exists(select * from Audit.PAndCSectionQuestions where PreviousQuestionId='C1C9D613-0E6F-3B95-45B2-CD37764B96B9' and PAndCSectionId=@pandcsectionId)         
       begin
   Insert Into Audit.PAndCSectionQuestions (Id,PAndCSectionId,Question,QuestionOptions,IsComment,IsAttachement,AttachmentsCount,UserCreated,CreatedDate,ModifiedDate,Status,Recorder,PreviousQuestionId) select NEWID (),@pandcsectionId,Question,QuestionOptions,IsComment,IsAttachement,AttachmentsCount,UserCreated,CreatedDate,ModifiedDate,Status,Recorder,PreviousQuestionId from Audit.PAndCSectionQuestions where id='C1C9D613-0E6F-3B95-45B2-CD37764B96B9'

end

  FETCH NEXT FROM PAC INTO @EngagementId      
		   END      
		 CLOSE PAC      
		 DEALLOCATE PAC 
		 COMMIT TRANSACTION
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

End
GO
