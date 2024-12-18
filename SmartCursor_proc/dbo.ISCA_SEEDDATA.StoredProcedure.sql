USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[ISCA_SEEDDATA]    Script Date: 16-12-2024 9.20.10 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

 
CREATE PROC [dbo].[ISCA_SEEDDATA](@NEW_COMPANY_ID bigint,@UNIQUE_COMPANY_ID bigint)
AS
BEGIN
BEGIN TRY

Declare @Is_ISCA_Enable Int;
Set @Is_ISCA_Enable=(select Status from Common.companyfeatures where FeatureId in (select Id from Common.feature  where moduleid=3 and Name='ISCA Manual') and CompanyId=@NEW_COMPANY_ID)

IF (@Is_ISCA_Enable = 1)
	BEGIN
		--Audit Manual
		IF NOT EXISTS(select * from Audit.AuditManual where Name='ISCA' and CompanyId=@NEW_COMPANY_ID)        
		BEGIN
			INSERT INTO Audit.AuditManual(Id,Name,CompanyId,Version,Description,Status,UserCreated,CreatedDate,ModifiedBy,ModifiedDate)
			values(NEWID(),'ISCA',@NEW_COMPANY_ID,'V1','',1,'system',GETDATE(),NULL,NULL)
		END
		
		-- WP Setup
			
		IF NOT EXISTS(select * from Audit.WPSetupMaster where AuditManualId=(select id from Audit.AuditManual where CompanyId=@NEW_COMPANY_ID and Name='ISCA') and EngagementTypeId=(select id from Audit.EngagementType where Name='Statutory Audit' and CompanyId=@NEW_COMPANY_ID) and CompanyId=@NEW_COMPANY_ID)        
		BEGIN
			insert into Audit.WPSetupMaster(Id,CompanyId,AuditManualId,EngagementTypeId,Status,UserCreated,CreatedDate,ModifiedBy,ModifiedDate)
			values(NEWID(),@NEW_COMPANY_ID,(select id from Audit.AuditManual where CompanyId=@NEW_COMPANY_ID and Name='ISCA'),(select id from Audit.EngagementType where Name='Statutory Audit' and CompanyId=@NEW_COMPANY_ID),1,'system',GETDATE(),NULL,NULL)
		END

		--LeadSheet Setup
			
		IF NOT EXISTS(select * from Audit.LeadSheetSetupMaster where AuditManual='ISCA' and CompanyId=@NEW_COMPANY_ID)        
		Begin
			INSERT INTO Audit.LeadSheetSetupMaster(Id,CompanyId,AuditManual,Status,UserCreated,CreatedDate,ModifiedBy,ModifiedDate,AuditManualId)
			values(NEWID(),@NEW_COMPANY_ID,'ISCA',1,'system',GETDATE(),NULL,NULL,(select id from Audit.AuditManual where CompanyId=@NEW_COMPANY_ID and Name='ISCA') )
		End

		--P and L
		
		IF NOT EXISTS(select * from Audit.PlanningAndCompletionSetUpMaster where AuditManualId=(select id from Audit.AuditManual where CompanyId=@NEW_COMPANY_ID and Name='ISCA') and EngagementTypeId=(select id from Audit.EngagementType where Name='Statutory Audit' and CompanyId=@NEW_COMPANY_ID) and CompanyId=@NEW_COMPANY_ID)        
		BEGIN
			insert into Audit.PlanningAndCompletionSetUpMaster(Id,CompanyId,AuditManualId,EngagementTypeId,Status,UserCreated,CreatedDate,ModifiedBy,ModifiedDate)
			values(NEWID(),@NEW_COMPANY_ID,(select id from Audit.AuditManual where CompanyId=@NEW_COMPANY_ID and Name='ISCA'),(select id from Audit.EngagementType where Name='Statutory Audit' and CompanyId=@NEW_COMPANY_ID),1,'system',GETDATE(),NULL,NULL)
		END

		-- FS Templates

		IF NOT EXISTS(select * from Audit.FSTemplates where AuditManual='ISCA' and Year=YEAR(GETDATE()) and CompanyId=@NEW_COMPANY_ID)        
		BEGIN
			insert into Audit.FSTemplates(Id,CompanyId,AuditManual,Year,Status,UserCreated,CreatedDate,ModifiedBy,ModifiedDate)
			values(NEWID(),@NEW_COMPANY_ID,'ISCA',YEAR(GETDATE()),1,'system',GETDATE(),NULL,NULL)
		END

		print 1

---- Seed data Dumping  start here

      --WP Set Up

		DECLARE @workProgramSetup_Unique_Identifier uniqueidentifier = NEWID()
		Declare @WPSetup_Cnt int;      
		select @WPSetup_Cnt=Count(*) from [Audit].[WPSetup] where companyid=@NEW_COMPANY_ID and Remarks='ISCA'      
		IF @WPSetup_Cnt=0      
		BEGIN
			INSERT INTO [Audit].[WPSetup] (Id,CompanyId,Code,[Description],Remarks,RecOrder,UserCreated,CreatedDate,ModifiedBy,ModifiedDate,[Version],[Status],ShortCode,IsPartner,ReferenceId)      
			select NewID(),@NEW_COMPANY_ID as CompanyId,[Code],[Description],[Remarks],[RecOrder],[UserCreated],GETUTCDATE() as [CreatedDate],NULL as[ModifiedBy],NULL as [ModifiedDate],[Version],[Status],[ShortCode],1,[Id]      
			From [Audit].[WPSetup] Where CompanyId = @UNIQUE_COMPANY_ID and Remarks='ISCA';
		END 
		 
		 print 2
	 -- LeadSheet SP

		DECLARE @leadSheetSetup_Unique_Identifier uniqueidentifier = NEWID()
		Declare @Leadsheet_Cnt bigint; 
		Declare @LeadsheetID uniqueidentifier,@WorkprogramId uniqueidentifier     
		select @Leadsheet_Cnt=Count(*) from [Audit].[Leadsheet] where companyid=@NEW_COMPANY_ID and AuditManualId=(select id from Audit.AuditManual where CompanyId=@NEW_COMPANY_ID and Name='ISCA') 
		If @Leadsheet_Cnt=0      
			BEGIN
				Insert Into [Audit].[Leadsheet] (Id, CompanyId, WorkProgramId, [Index], LeadsheetType, AccountClass, IsSystem, LeadSheetName, FinancialStatementTemplate, Remarks, RecOrder, UserCreated, CreatedDate, ModifiedBy, ModifiedDate, Version,WorkProgramName, Status,IsPartner,ReferenceId,Disclosure ,AuditManual,AuditManualId)      
							select Newid() as leadsheetid, @NEW_COMPANY_ID as newcompanyid,pp.Newcompanyid, [Index], LeadsheetType, AccountClass, IsSystem, LeadSheetName, FinancialStatementTemplate, Remarks, RecOrder, UserCreated, GETUTCDATE(),NULL AS ModifiedBy,NULL AS ModifiedDate, Version,WorkProgramName ,Status ,1,   
								[ReferenceId],Disclosure,L.AuditManual,(select id from Audit.AuditManual where CompanyId=@NEW_COMPANY_ID and Name='ISCA')  from  [Audit].[LeadSheet]  as L      
								INNER JOIN      
								(      
								select P.Id as 'Newcompanyid',w.Id as 'Oldcompanyid' from audit.WPSetup as w      
								INNER JOIN       
								(      
								select id,code,Description from audit.WPSetup where companyid =@NEW_COMPANY_ID and Remarks='ISCA'     
								) as p ON P.Code=w.Code and P.Description=w.Description      
                        
								where companyid in (@UNIQUE_COMPANY_ID)      
								) as PP On PP.Oldcompanyid=WorkProgramId      
                        
								where CompanyId=@UNIQUE_COMPANY_ID and AuditManualId='599B2756-0095-4FF0-ACC0-72AA325B9DBD'  and Engagementid is null
			END

		DECLARE @leadSheetCategories_Unique_Identifier uniqueidentifier = NEWID()
		Declare @LeadSheetCategories_Cnt bigint;      
		select @LeadSheetCategories_Cnt=Count(*) from [Audit].[LeadSheetCategories] where LeadsheetId in (select Id from audit.leadsheet where CompanyId= @NEW_COMPANY_ID and auditManualid in (select id from Audit.AuditManual where CompanyId=@NEW_COMPANY_ID and Name='ISCA') and Engagementid is null)      
		If @LeadSheetCategories_Cnt=0 
			Begin
				Insert Into [Audit].[LeadSheetCategories] ([Id],[LeadsheetID],[Name],[RecOrder],[Status],IsSystem) 
				SELECT newid() as Id ,(select ID FROM [Audit].[LeadSheet] where CompanyId = @NEW_COMPANY_ID and 
				   AuditManualId=(select id from Audit.AuditManual where CompanyId=@NEW_COMPANY_ID and Name='ISCA') 
				   and Engagementid is null and 
				   LeadSheetName = (select LeadSheetName FROM [Audit].[LeadSheet] where Id = cat.[LeadsheetID] and 
				   CompanyId = @UNIQUE_COMPANY_ID and AuditManualId='599B2756-0095-4FF0-ACC0-72AA325B9DBD' and Engagementid is null))   as [LeadsheetID]  ,
				   cat.[Name] ,cat.[RecOrder]  ,cat.[Status] ,cat.IsSystem FROM [Audit].[LeadSheetCategories] cat inner join 
				   [Audit].[LeadSheet] ld  on ld.Id = cat.LeadsheetID  where ld.CompanyId = @UNIQUE_COMPANY_ID 
				   and  ld.AuditManualId='599B2756-0095-4FF0-ACC0-72AA325B9DBD'  and ld.Engagementid is null
			END

		print 3

      -- P and L


	Declare @PartnerCompany_Cnt int;      
	select @PartnerCompany_Cnt=COUNT(*)  from audit.PlanningAndCompletionSetup where companyid=@NEW_COMPANY_ID and AuditManualid=(select id from audit.auditmanual where Companyid=@NEW_COMPANY_ID and Name='ISCA');
	IF @PartnerCompany_Cnt=0      
	BEGIN  

		Declare @OldCompanyId Bigint=@UNIQUE_COMPANY_ID;
		Declare @NewCompanyId Bigint=@NEW_COMPANY_ID;
		Declare @EngagementId Uniqueidentifier
		Declare @AuditManualId Uniqueidentifier
		Declare @System Nvarchar(54)='System'
		Declare @MasterId Uniqueidentifier
		Declare @OldMasterId Uniqueidentifier
		Declare @GetDate Datetime2(7)=GetUTCDAte()
		Set @EngagementId=(Select Id from audit.engagementtype where companyid=@NewCompanyId And Name='Statutory Audit')
		Set @AuditManualId=(Select Id from audit.auditmanual where companyid=@NewCompanyId and Name='ISCA') 
		Set @MasterId=(Select Id from audit.planningandcompletionsetupmaster Where AuditManualId=@AuditManualId And EngagementTypeId=@EngagementId And CompanyId=@NewCompanyId)
		Set @OldMasterId=(select id from Audit.PlanningAndCompletionSetUpMaster where companyid=0 and auditmanualid= (select id from audit.auditmanual where companyid=0 and name='ISCA'))

 

		Declare @TempTbl Table (New_Id Uniqueidentifier,Old_Id Uniqueidentifier)
		Declare @TempPlanQ Table (New_Id Uniqueidentifier,Old_Id Uniqueidentifier)
		Insert Into @TempTbl
			Select NEWID(),Id From audit.planningandcompletionsetup 
				where companyid=@OldCompanyId and engagementid is null and masterid=(select id from audit.PlanningAndCompletionSetUpmaster where companyid=0)

 
		Insert into audit.planningandcompletionsetup  
		select B.New_Id As Id,@NewCompanyId As CompanyId,AuditCompanyId,EngagementId,ModuleDetailId,Type,MenuCode,MenuName,Description,FormType,Remarks,@System As UserCreated,@GetDate As CreatedDate
				,Null As ModifiedBy,Null As ModifiedDate,Status,Recorder,EngagementType,Conclusion,IsMigrated,ConclusionLable,SelectedDirectors,TypeId,@EngagementId As EngagementTypeId
				,IsSignPartner,@AuditManualId As AuditManualId,@MasterId As MasterId,Title,EnableDescription
		From audit.planningandcompletionsetup As A
		Inner Join @TempTbl As B On A.Id=B.Old_Id
		where companyid=@OldCompanyId and engagementid is null and masterid=@OldMasterId

 

		Insert Into @TempPlanQ
		Select NEWID(),Id From audit.PAndCSections As A
		Inner Join @TempTbl B On A.PlanningAndCompletionSetUpId=B.Old_Id

 
  
		Insert into audit.PAndCSections  
		select C.New_Id,B.New_Id As PlanningAndCompletionSetUpId,Heading,Description,CommentLable,CommentDescription,Remarks,@System As UserCreated,@GetDate As CreatedDate,Null As ModifiedBy,Null As ModifiedDate
				,Status,Recorder 
		From audit.PAndCSections As A
		Inner Join @TempPlanQ As C On A.Id=C.Old_Id
		Inner Join @TempTbl B On A.PlanningAndCompletionSetUpId=B.Old_Id

 
   
		Insert into audit.PAndCSectionQuestions  
		select Newid(),B.New_Id As PAndCSectionId,Question,QuestionOptions,Answer,IsComment,Comment,IsAttachement,AttachmentsCount,Remarks,@System As UserCreated,@GetDate As CreatedDate,Null As ModifiedBy
				,Null As ModifiedDate,Status,Recorder,AttachmentName,PreviousQuestionId 
		From  Audit.PAndCSectionQuestions As A
		Inner Join @TempPlanQ As B On A.PAndCSectionId=B.Old_Id
	
	End
	print 4

	--Account policy

		DECLARE @accountPolicy_Unique_Identifier uniqueidentifier = NEWID()
		Declare @AccountPolicy_Cnt bigint;
		Select @AccountPolicy_Cnt=Count(*) from Audit.AccountPolicy where CompanyId =@NEW_COMPANY_ID and Remarks='ISCA'
		 If @AccountPolicy_Cnt=0
			Begin 
				Declare @PolicyId uniqueidentifier;
				Declare @NewPolicyId uniqueidentifier;
				Declare @PolicyDetailId uniqueidentifier;

					DECLARE AccountpolicyCSR cursor for select id from Audit.AccountPolicy where CompanyId=0   and Remarks='ISCA'
					OPEN AccountpolicyCSR
					FETCH NEXT FROM   AccountpolicyCSR into @PolicyId
					WHILE (@@FETCH_STATUS=0)
					BEGIN
						set @NewPolicyId=NEWID();
						 Insert Into Audit.AccountPolicy (Id,CompanyId,EngagementId,PolicyName,PolicyTemplate,IsChecked,IsSytem,Remarks,RecOrder,UserCreated,CreatedDate,ModifiedBy,ModifiedDate,Version,Status,Section,PolicyNameId,IsRollForward,SectionName,EffectiveFrom,EffectiveTo)
						 Select @NewPolicyId,@NEW_COMPANY_ID,EngagementId,PolicyName,PolicyTemplate,IsChecked,IsSytem,Remarks,RecOrder,UserCreated,GETUTCDATE(),null,null,Version,Status,Section,@PolicyId,IsRollForward,SectionName,EffectiveFrom,EffectiveTo  from Audit.AccountPolicy where Id=@PolicyId
		    
							  DECLARE AccountpolicyDetailCSR cursor for select id from Audit.AccountPolicyDetail where MasterId=@PolicyId
							  OPEN AccountpolicyDetailCSR
							  FETCH NEXT FROM   AccountpolicyDetailCSR into @PolicydetailId
							  WHILE (@@FETCH_STATUS=0)
							  BEGIN
								  Insert Into Audit.AccountPolicyDetail (Id,MasterId,PolicyName,PolicyTemplate,IsChecked,IsSytem,RecOrder,Status,PolicyNameId)
								  select NEWID(),@NewPolicyId,PolicyName,PolicyTemplate,IsChecked,IsSytem,RecOrder,Status,@PolicyDetailId  from Audit.AccountPolicyDetail where id=@PolicyDetailId
							  FETCH NEXT FROM   AccountpolicyDetailCSR into @PolicydetailId
							  END
							  CLOSE AccountpolicyDetailCSR
							  DEALLOCATE AccountpolicyDetailCSR
					FETCH NEXT FROM   AccountpolicyCSR into @PolicyId
					END
					CLOSE AccountpolicyCSR
					DEALLOCATE AccountpolicyCSR
			END  

	print 5
	-- Directors Statement  and  Auditors

		DECLARE @directorsStatement_Auditors_Unique_Identifier uniqueidentifier = NEWID()
		BEGIN 
			Declare @Template_Cnt bigint;
			Select @Template_Cnt=Count(*) from Audit.Template where CompanyId =@NEW_COMPANY_ID and FSTemplateId=(select Id from Audit.FsTemplates where AuditManual='ISCA' and CompanyId=0)
			If @Template_Cnt=0
			Begin
				Insert Into Audit.Template (id,Name,Code,CompanyId,EngagementId,FromEmailId,CcEmailIds,BccEmailIds,ToEmailId,Subject,TempletContent,Remarks,UserCreated,CreatedDate,ModifiedBy,ModifiedDate,RecOrder,Version,Status,ScreenName,GenericTemplateId,IsTemplate,IsMaster,IsRollForward,AuditCompanyId,EngagementType,EngagementName,EffectiveFrom,EffectiveTo,SectionName,IsFinancialsTemplate,ReferenceId,FSTemplateId)
				Select  NEWID(),Name,Code,@NEW_COMPANY_ID,EngagementId,FromEmailId,CcEmailIds,BccEmailIds,ToEmailId,Subject,TempletContent,Remarks,UserCreated,GETUTCDATE(),null,null,RecOrder,Version,Status,ScreenName,GenericTemplateId,IsTemplate,IsMaster,IsRollForward,AuditCompanyId,EngagementType,EngagementName,EffectiveFrom,EffectiveTo,SectionName,IsFinancialsTemplate,ReferenceId,
				(select Id from Audit.FsTemplates where AuditManual='ISCA' and CompanyId=@NEW_COMPANY_ID) from Audit.Template where CompanyId=@UNIQUE_COMPANY_ID and FsTemplateId is null and Remarks='ISCA'
			END
		End

	print 6

	--- Reporting templates
	
		DECLARE @reportingTemplates_Unique_Identifier uniqueidentifier = NEWID()
		Declare @ReportingTemplates_Cnt bigint;
		Select @ReportingTemplates_Cnt=COUNT(*) from Audit.ReportingTemplates where PartnerCompanyId=@NEW_COMPANY_ID and FSTemplateId=(select Id from Audit.FsTemplates where AuditManual='ISCA' and CompanyId=@NEW_COMPANY_ID)
		IF @ReportingTemplates_Cnt=0
		Begin
			declare @companyCreationdate datetime2(7)=(select CreatedDate  from Common.Company where id=@NEW_COMPANY_ID);
			 BEGIN 
				  Insert into Audit.ReportingTemplates (Id,PartnerCompanyId,EngagementId,TemplateName,UserCreated,CreatedDate,ModifiedBy,ModifiedDate,Status,EffectiveFrom,FSTemplateId)
				 Select Newid(),@NEW_COMPANY_ID,EngagementId,TemplateName,'Sysytem',GETUTCDATE(),null,Null,Status,@companyCreationdate,(select Id from Audit.FsTemplates where AuditManual='ISCA' and CompanyId=@NEW_COMPANY_ID) from Audit.ReportingTemplates where PartnerCompanyId=@UNIQUE_COMPANY_ID and EngagementId Is Null and FSTemplateId is null
			 END
		END

	print 7
	----- Manual Id Updates
 
	Update Audit.AccountPolicy  set FSTemplateId =(select Id from Audit.FSTemplates where AuditManual='ISCA' and Year=YEAR(GETDATE()) and CompanyId=@NEW_COMPANY_ID)  where CompanyId=@NEW_COMPANY_ID and Remarks='ISCA'

	update audit.WPSetup set EngagementTypeId=(select id from Audit.EngagementType where CompanyId=@NEW_COMPANY_ID and Name='Statutory Audit'),AuditManualId=(select id from audit.AuditManual where Name='ISCA' and CompanyId=@NEW_COMPANY_ID),WpsetupMasterId=(select Id from Audit.WPSetupMaster where AuditManualId=(select id from Audit.AuditManual where CompanyId=@NEW_COMPANY_ID and Name='ISCA') and EngagementTypeId=(select id from Audit.EngagementType where Name='Statutory Audit' and CompanyId=@NEW_COMPANY_ID)and CompanyId=@NEW_COMPANY_ID) where CompanyId=@NEW_COMPANY_ID and EngagementId is null and Remarks='ISCA'

	update Audit.LeadSheet set AuditManual='ISCA',MasterId=(select Id from Audit.LeadSheetSetupMaster where AuditManual='ISCA' and CompanyId=@NEW_COMPANY_ID)where CompanyId=@NEW_COMPANY_ID and EngagementId is null and Auditmanualid=(select id from Audit.AuditManual where CompanyId=@NEW_COMPANY_ID and Name='ISCA')
 
 	print 'completed';

	

	End	
 

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
  --ROLLBACK TRANSACTION      
 END CATCH      
END
GO
