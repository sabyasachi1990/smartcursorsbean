USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[Tax_ResetPlanningAndCompletion]    Script Date: 16-12-2024 9.20.11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-------------------------------------

--Planing Reset SP
CREATE PROCEDURE [dbo].[Tax_ResetPlanningAndCompletion] (@engagementId UNIQUEIDENTIFIER,@CompanyId Bigint,@ScreenName nvarchar(100))
	As Begin
		Begin Transaction
		BEGIN TRY
			DECLARE @PAC_NEWID UNIQUEIDENTIFIER
			Declare @Count1 int
			Declare @RecCunt1 Int 	
			DECLARE @SEC_ID UNIQUEIDENTIFIER      
			DECLARE @SEC_PAC_ID UNIQUEIDENTIFIER      
			DECLARE @SECTION NVARCHAR(MAX)      
			DECLARE @DESCRIPTION NVARCHAR(MAX)      
			DECLARE @SEC_NEWID UNIQUEIDENTIFIER
			Declare @Partner_COMPANYID Bigint=0;
			Declare @taxManualId uniqueidentifier
			Set @Partner_COMPANYID=(select AccountingFirmId from Common.Company where Id=@CompanyId)
			IF @Partner_COMPANYID IS NULL 
				BEGIN 
					set @Partner_COMPANYID =@CompanyId;
				END

			Delete from Tax.PAndCSectionQuestions where PAndCSectionId in (select Id from Tax.PAndCSections where PlanningAndCompletionSetUpId in (select id from Tax.PlanningAndCompletionSetUp   where EngagementId=@engagementId and menuname=@ScreenName))

			Delete from Tax.PAndCSections where PlanningAndCompletionSetUpId in (select id from Tax.PlanningAndCompletionSetUp   where EngagementId=@engagementId and menuname=@ScreenName)				

			Delete from Tax.PlanningAndCompletionSetUp   where EngagementId=@engagementId and menuname=@ScreenName
			Set @taxManualId=(select TaxManualId from tax.TaxCompanyEngagement where id=@engagementId)

			SELECT @PAC_NEWID =NEWID();

			INSERT INTO Tax.PlanningAndCompletionSetUp(Id,CompanyId,EngagementId,ModuleDetailId,Type,MenuCode,MenuName,Description,FormType,Remarks,UserCreated,CreatedDate,ModifiedBy,ModifiedDate,Status,Recorder,EngagementType,Conclusion,IsMigrated,ConclusionLable) 
			SELECT @PAC_NEWID,@CompanyId,@engagementid,ModuleDetailId,Type,MenuCode,MenuName,Description,FormType,Remarks,UserCreated,GETDATE(),NULL,NULL,Status,Recorder,EngagementType,Conclusion,IsMigrated,ConclusionLable 
			FROM Tax.PlanningAndCompletionSetUp WHERE EngagementId is null and CompanyId=@Partner_COMPANYID and MenuName=@ScreenName and TaxManualId=@taxManualId	

			IF OBJECT_ID('tempdb..#SEC_UNQC') IS NOT NULL
				Begin
					Drop Table #SEC_UNQC
				End
      		Create Table #SEC_UNQC (S_no Int Identity(1,1),ID UNIQUEIDENTIFIER,PAC_ID UNIQUEIDENTIFIER,SECTION NVARCHAR(MAX),DESCRIPTION NVARCHAR(MAX)) 
			IF EXISTS(SELECT ID FROM #SEC_UNQC)      
				BEGIN      
					Truncate Table #SEC_UNQC       
				END      
			INSERT INTO #SEC_UNQC SELECT ID,PlanningAndCompletionSetUpId,Heading,DESCRIPTION FROM Tax.PAndCSections WHERE PlanningAndCompletionSetUpId=(SELECT Id FROM Tax.PlanningAndCompletionSetUp WHERE EngagementId is null and CompanyId=@Partner_COMPANYID and MenuName=@ScreenName and TaxManualId=@taxManualId)    
			Set @Count1=(Select Count(*) From #SEC_UNQC)
			Set @RecCunt1=1
			While @Count1>=@RecCunt1
			    BEGIN 
					Set @SEC_ID=(Select ID From #SEC_UNQC Where S_no=@RecCunt1)
					Set @SEC_PAC_ID=(Select PAC_ID From #SEC_UNQC Where S_no=@RecCunt1)
					Set @SECTION=(Select SECTION From #SEC_UNQC Where S_no=@RecCunt1)
					Set @DESCRIPTION =(Select DESCRIPTION From #SEC_UNQC Where S_no=@RecCunt1)
					SELECT @SEC_NEWID =NEWID()     
      
					INSERT INTO Tax.PAndCSections(Id,PlanningAndCompletionSetUpId,Heading,Description,CommentLable,CommentDescription,Remarks,UserCreated,CreatedDate,ModifiedBy,ModifiedDate,Status,Recorder) SELECT @SEC_NEWID,@PAC_NEWID,Heading,DESCRIPTION,CommentLable,CommentDescription,Remarks,UserCreated,GETDATE(),NULL,NULL,Status,Recorder FROM Tax.PAndCSections WHERE ID=@SEC_ID      
      
					INSERT INTO Tax.PAndCSectionQuestions (Id,PAndCSectionId,Question,QuestionOptions,Answer,IsComment,Comment,IsAttachement,AttachmentsCount,Remarks,UserCreated,CreatedDate,ModifiedBy,ModifiedDate,Status,Recorder,AttachmentName,PreviousQuestionId) SELECT NEWID(),@SEC_NEWID,Question,QuestionOptions,Answer,IsComment,Comment,IsAttachement,AttachmentsCount,Remarks,UserCreated,GETDATE(),NULL,NULL,Status,Recorder,AttachmentName,id FROM Tax.PAndCSectionQuestions WHERE PAndCSectionId=@SEC_ID      
					Set @RecCunt1=@RecCunt1+1
				END  
			IF OBJECT_ID('tempdb..#SEC_UNQC') IS NOT NULL
				Begin
					Drop Table #SEC_UNQC
				End		   
			Update common.DocRepository set Type='Tails' where grouptypeid=@engagementid and screenname=@ScreenName
			Commit Transaction;
		END TRY
		BEGIN CATCH
			RollBack Transaction;
			DECLARE
			@ErrorMessage NVARCHAR(4000),
			@ErrorSeverity INT,
			@ErrorState INT;
			SELECT
			@ErrorMessage = ERROR_MESSAGE(),
			@ErrorSeverity = ERROR_SEVERITY(),
			@ErrorState = ERROR_STATE();
			RAISERROR (@ErrorMessage,@ErrorSeverity,@ErrorState);
		END CATCH
	END
GO
