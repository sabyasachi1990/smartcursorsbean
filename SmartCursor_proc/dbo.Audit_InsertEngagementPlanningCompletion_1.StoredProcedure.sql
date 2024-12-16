USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[Audit_InsertEngagementPlanningCompletion_1]    Script Date: 16-12-2024 9.20.10 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   Procedure [dbo].[Audit_InsertEngagementPlanningCompletion_1](@NEW_COMPANY_ID Bigint,@auditCompanyId uniqueidentifier,@engagementid uniqueidentifier,@engagementtypeId uniqueidentifier,@auditManualId uniqueidentifier)
AS Begin
-- need to check previous question id and conclusion
		 Declare @UNIQUE_or_Partner_COMPANY_ID Bigint=0;
		 declare @Parent_CompantId BigInt;
		 -----------------------------PlannigAndCompletionSetUp-----------------------      
		 
		 Set @Parent_CompantId=(select AccountingFirmId from Common.Company where Id=@NEW_COMPANY_ID)
	     IF @Parent_CompantId IS NULL 
			BEGIN 
				set @UNIQUE_or_Partner_COMPANY_ID =@NEW_COMPANY_ID;
			END
		 else
			Begin
		       set @UNIQUE_or_Partner_COMPANY_ID =@Parent_CompantId;
			End

		
		    
Begin Transaction
BEGIN TRY 		 
		 BEGIN      
		 Declare @PandCSetup_Cnt int;  
		 set @PandCSetup_Cnt =5;
		 select @PandCSetup_Cnt=Count(*) from [Audit].[PlanningAndCompletionSetUp]  where EngagementId=@engagementid
		 IF @PandCSetup_Cnt=5    
		 Begin      
		--1 Audit.PlanningAndCompletionSetUp      
		 DECLARE @PAC_UNQC TABLE(ID UNIQUEIDENTIFIER,COMPANYID BIGINT,CODE NVARCHAR(MAX))      
		 DECLARE @PAC_ID_FOR_UNQC UNIQUEIDENTIFIER      
		 DECLARE @PAC_UNQCID BIGINT      
		 DECLARE @PAC_MCODE NVARCHAR(MAX)      
		 DECLARE @PAC_NEWID UNIQUEIDENTIFIER      
      
		 INSERT INTO @PAC_UNQC       
		 SELECT ID,COMPANYID,MenuCode FROM Audit.PlanningAndCompletionSetUp  WHERE COMPANYID=@UNIQUE_or_Partner_COMPANY_ID and EngagementId Is null and AuditCompanyId is null   and AuditManualId=@auditManualId and EngagementTypeId=@engagementtypeId        
      and MenuCode not in ('AP-9','AP-7','AC-2','AC-1','AC-6')
		 --2 Audit.PAndCSections      
      
		 DECLARE @SEC_UNQC TABLE(ID UNIQUEIDENTIFIER,PAC_ID UNIQUEIDENTIFIER,SECTION NVARCHAR(MAX),DESCRIPTION NVARCHAR(MAX))      
      
		 DECLARE @SEC_ID UNIQUEIDENTIFIER      
		 DECLARE @SEC_PAC_ID UNIQUEIDENTIFIER      
		 DECLARE @SECTION NVARCHAR(MAX)      
		 DECLARE @DESCRIPTION NVARCHAR(MAX)      
		 DECLARE @SEC_NEWID UNIQUEIDENTIFIER      
      
		  --2 Audit.DirectorRemuneration       
      
		 DECLARE @SEC_UNQC1 TABLE(ID UNIQUEIDENTIFIER,PAC_ID UNIQUEIDENTIFIER)      
      
		 DECLARE @SEC_ID1 UNIQUEIDENTIFIER      
		 DECLARE @SEC_PAC_ID1 UNIQUEIDENTIFIER      
		 DECLARE @SEC_NEWID1 UNIQUEIDENTIFIER      
      
  
    
		 -- CURSOR FOR PAC TABLE      
		 DECLARE PAC CURSOR FOR SELECT * FROM @PAC_UNQC       
		 OPEN PAC      
		   FETCH NEXT FROM PAC INTO @PAC_ID_FOR_UNQC,@PAC_UNQCID,@PAC_MCODE       
		   WHILE (@@FETCH_STATUS=0)      
		   BEGIN      
		  SELECT @PAC_NEWID =NEWID()      
		  INSERT INTO Audit.PlanningAndCompletionSetUp(Id,CompanyId,AuditCompanyId,EngagementId,ModuleDetailId,Type,MenuCode,MenuName,Description,FormType,Remarks,UserCreated,CreatedDate,ModifiedBy,ModifiedDate,Status,Recorder,EngagementType,Conclusion,IsMigrated,ConclusionLable,EngagementTypeId,IsSignPartner,Title,EnableDescription,TypeId)      
		  SELECT @PAC_NEWID,@NEW_COMPANY_ID,@auditCompanyId,@engagementid,ModuleDetailId,Type,MenuCode,MenuName,Description,FormType,Remarks,UserCreated,GETDATE(),NULL,NULL,Status,Recorder,EngagementType,Conclusion,IsMigrated,ConclusionLable,EngagementTypeId,IsSignPartner,Title,EnableDescription,@PAC_ID_FOR_UNQC
		  FROM Audit.PlanningAndCompletionSetUp  WHERE ID=@PAC_ID_FOR_UNQC --AND COMPANYID=@PAC_UNQCID AND MenuCode=@PAC_MCODE      
      
		  IF EXISTS(SELECT * FROM @SEC_UNQC)      
		  BEGIN      
		   DELETE FROM @SEC_UNQC       
		  END      
      
		  INSERT INTO @SEC_UNQC       
		  SELECT ID,PlanningAndCompletionSetUpId,Heading,DESCRIPTION FROM Audit.PAndCSections  WHERE  PlanningAndCompletionSetUpId=@PAC_ID_FOR_UNQC      
      
		  -- CURSOR FOR PAndCSections TABLE and PAndCSectionQuestions      
		  DECLARE SECTION CURSOR FOR SELECT * FROM @SEC_UNQC       
		  OPEN SECTION      
			 FETCH NEXT FROM SECTION INTO @SEC_ID,@SEC_PAC_ID,@SECTION,@DESCRIPTION      
			 WHILE (@@FETCH_STATUS=0)      
			 BEGIN      
		   SELECT @SEC_NEWID =NEWID()      
      
		   INSERT INTO Audit.PAndCSections(Id,PlanningAndCompletionSetUpId,Heading,Description,CommentLable,CommentDescription,Remarks,UserCreated,CreatedDate,ModifiedBy,ModifiedDate,Status,Recorder)      
		   SELECT @SEC_NEWID,@PAC_NEWID,Heading,DESCRIPTION,CommentLable,CommentDescription,Remarks,UserCreated,GETDATE(),NULL,NULL,Status,Recorder      
		   FROM Audit.PAndCSections  WHERE ID=@SEC_ID --AND PlanningAndCompletionSetUpId=@SEC_PAC_ID AND Heading=@SECTION AND DESCRIPTION=@DESCRIPTION      
      
         
		   INSERT INTO Audit.PAndCSectionQuestions (Id,PAndCSectionId,Question,QuestionOptions,Answer,IsComment,Comment,IsAttachement,AttachmentsCount,Remarks,UserCreated,CreatedDate,ModifiedBy,ModifiedDate,Status,Recorder,AttachmentName,PreviousQuestionId
		   )      
		   SELECT NEWID(),@SEC_NEWID,Question,QuestionOptions,Answer,IsComment,Comment,IsAttachement,AttachmentsCount,Remarks,UserCreated,GETDATE(),NULL,NULL,Status,Recorder,AttachmentName,Id    
		   FROM Audit.PAndCSectionQuestions  WHERE PAndCSectionId=@SEC_ID      
      
      
      
		   FETCH NEXT FROM SECTION INTO @SEC_ID,@SEC_PAC_ID,@SECTION,@DESCRIPTION      
			 END      
		  CLOSE SECTION      
		  DEALLOCATE SECTION      
      
		  --renumaration and renumaration details      
		   IF EXISTS(SELECT * FROM @SEC_UNQC1)      
		  BEGIN      
		   DELETE FROM @SEC_UNQC1       
		  END      
      
		  INSERT INTO @SEC_UNQC1       
		  SELECT ID,PlanningAndCompletionSetUpId FROM Audit.DirectorRemuneration  WHERE PlanningAndCompletionSetUpId=@PAC_ID_FOR_UNQC      
      
		  -- CURSOR FOR Audit.DirectorRemuneration TABLE and Audit.DirectorRemuneration      
		  DECLARE SECTION1 CURSOR FOR SELECT * FROM @SEC_UNQC1       
		  OPEN SECTION1      
			 FETCH NEXT FROM SECTION1 INTO @SEC_ID1,@SEC_PAC_ID1      
			 WHILE (@@FETCH_STATUS=0)      
			 BEGIN      
		   SELECT @SEC_NEWID1 =NEWID()      
      
		   INSERT INTO Audit.DirectorRemuneration (Id,PlanningAndCompletionSetUpId,AuditCompanyContactId,EngagementId,UserCreated,CreatedDate,ModifiedBy,ModifiedDate,Status,Recorder,Description--,Conclusion
		   )      
		   SELECT @SEC_NEWID1,@PAC_NEWID,AuditCompanyContactId,@engagementid,UserCreated,GETDATE(),NULL,NULL,Status,Recorder,[Description]--,Conclusion      
		   FROM Audit.DirectorRemuneration  WHERE ID=@SEC_ID1 --AND PlanningAndCompletionSetUpId=@SEC_PAC_ID AND Heading=@SECTION AND DESCRIPTION=@DESCRIPTION      
		   INSERT INTO Audit.DirectorRemunerationDetails (Id,DirectorRemunerationId,Heading,HeadingRecorder,LineItemName,LineItemAmount,UserCreated,CreatedDate,ModifiedBy,ModifiedDate,Status,Recorder)      
		   SELECT NEWID(),@SEC_NEWID1,Heading,HeadingRecorder,LineItemName,LineItemAmount,UserCreated,GETDATE(),NULL,NULL,Status,Recorder      
		   FROM Audit.DirectorRemunerationDetails  WHERE DirectorRemunerationId=@SEC_ID1      
      
		   FETCH NEXT FROM SECTION1 INTO @SEC_ID1,@SEC_PAC_ID1      
			 END      
		  CLOSE SECTION1      
		  DEALLOCATE SECTION1      
      
		  FETCH NEXT FROM PAC INTO @PAC_ID_FOR_UNQC,@PAC_UNQCID,@PAC_MCODE       
		   END      
		 CLOSE PAC      
		 DEALLOCATE PAC      
		 end      
		 END
		 insert into Audit.EngagementHistory (Id,EngagementId,SeedDataType,SeedDataStatus,Recorder)  Values (NewId(),@engagementid,'PandLInserted','Success',8)
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
End
GO
