USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[FW_SEED_DATA_TAX]    Script Date: 16-12-2024 9.20.10 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


----------------------
CREATE   PROC [dbo].[FW_SEED_DATA_TAX] (@UNIQUE_COMPANY_ID bigint, @NEW_COMPANY_ID bigint, @UNIQUE_ID uniqueidentifier)
AS
BEGIN
DECLARE @STATUS INT = 1
DECLARE @CREATED_DATE DATETIME = GETUTCDATE()
DECLARE @IN_PROGRESS nvarchar(20) = 'In-Progress'
DECLARE @COMPLETED nvarchar(20) = 'Completed'
DECLARE @CompanyType Bit
DECLARE @MODULE_NAME varchar(20) = 'Tax Cursor' 
DECLARE @MODULE_ID bigint =  (select Id from Common.ModuleMaster where Name = @MODULE_NAME)
DECLARE @IS_ACCOUNTING_FIRM bit = (select IsAccountingFirm  from Common.Company where Id=@NEW_COMPANY_ID)


--BEGIN TRANSACTION
BEGIN TRY
	--================================================================
	--ControlCodeCategory, ControlCode and ControlCodeCategoryModule  Insertion
	DECLARE @ControlCode_Unique_Identifier uniqueidentifier = NEWID()
	INSERT INTO Common.DetailLog values(@ControlCode_Unique_Identifier, @UNIQUE_Id , 'FW_SEED_DATA_TAX - ControlCodes Execution Started', GETUTCDATE() , '7.1' , NULL , @IN_PROGRESS )

	EXEC [dbo].[FW_CONTROL_CODE_INSERTION] @UNIQUE_COMPANY_ID, @NEW_COMPANY_ID, @MODULE_NAME

	Update Common.DetailLog set Status = @COMPLETED where Id = @ControlCode_Unique_Identifier
	--===============================================================
	--ModuleDetail Insertion
	DECLARE @ModuleDetail_Unique_Identifier uniqueidentifier = NEWID()
	INSERT INTO Common.DetailLog values(@ModuleDetail_Unique_Identifier, @UNIQUE_Id , 'FW_SEED_DATA_TAX - ModuleDetail Execution Started', GETUTCDATE() , '7.2' , NULL , @IN_PROGRESS )

	EXEC [dbo].[FW_MODULE_DETAIL_INSERTION] @UNIQUE_COMPANY_ID, @NEW_COMPANY_ID, @MODULE_ID

	Update Common.DetailLog set Status = @COMPLETED where Id = @ModuleDetail_Unique_Identifier
	--================================================================
	--InitialCursor Setup Insertion
	DECLARE @InitialCursorSetup_Unique_Identifier uniqueidentifier = NEWID()
	INSERT INTO Common.DetailLog values(@InitialCursorSetup_Unique_Identifier, @UNIQUE_Id , 'FW_SEED_DATA_TAX - InitialCursorSetup Execution Started', GETUTCDATE() , '7.3' , NULL , @IN_PROGRESS )

	EXEC [dbo].[FW_INITIAL_CURSOR_SETUP_SEED] @UNIQUE_COMPANY_ID, @NEW_COMPANY_ID, @MODULE_ID

	Update Common.DetailLog set Status = @COMPLETED where Id = @InitialCursorSetup_Unique_Identifier
	--============ Auto number insertion===============================================================
	DECLARE @autoNumber_Unique_Identifier uniqueidentifier = NEWID()
	INSERT INTO Common.DetailLog values(@autoNumber_Unique_Identifier, @UNIQUE_Id , 'FW_SEED_DATA_TAX - AutoNumber Execution Started', GETUTCDATE() , '7.4' , NULL , @IN_PROGRESS )

	EXEC [dbo].[FW_AUTO_NUMBER_SEED_DATA] @UNIQUE_COMPANY_ID, @NEW_COMPANY_ID, @MODULE_ID

	Update Common.DetailLog set Status = @COMPLETED where Id = @autoNumber_Unique_Identifier
	--============================ GridMetaData ===============================================
	DECLARE @gridmetadata_Unique_Identifier uniqueidentifier = NEWID()
	INSERT INTO Common.DetailLog values(@gridmetadata_Unique_Identifier, @UNIQUE_Id , 'FW_SEED_DATA_TAX - GridMetaData Execution Started', GETUTCDATE() , '7.5' , NULL , @IN_PROGRESS )

	EXEC [dbo].[FW_GRIDMETADATA_SEED_INSERTION] @UNIQUE_COMPANY_ID, @NEW_COMPANY_ID, @MODULE_ID

	Update Common.DetailLog set Status = @COMPLETED where Id = @gridmetadata_Unique_Identifier
	--=============================================================================================

	------------------------for new tax user roles
	DECLARE @taxRoles_Unique_Identifier uniqueidentifier = NEWID()
	INSERT INTO Common.DetailLog values(@taxRoles_Unique_Identifier, @UNIQUE_Id , 'FW_SEED_DATA_TAX - Tax Roles Execution Started', GETUTCDATE() , '7.6' , NULL , @IN_PROGRESS )
	IF NOT EXISTS (SELECT * FROM [Auth].[Role] where Name='TX User' and [ModuleMasterId]=(select Id from Common.ModuleMaster where CompanyId=0 and Heading='Tax Cursor') and CompanyId=@NEW_COMPANY_ID) 
	BEGIN
	INSERT [Auth].[Role] ([Id], [CompanyId], [Name], [Remarks], [ModuleMasterId], [Status], [ModifiedBy], [ModifiedDate], [UserCreated], [CreatedDate],[IsSystem],[BackgroundColor],[CursorIcon],[IsPartner])
	VALUES (newid(),@NEW_COMPANY_ID, N'TX User', NULL,(select Id from Common.ModuleMaster where CompanyId=0 and Heading='Tax Cursor'), 1, NULL, NULL, NULL, GETUTCDATE(),1,N'#67acda',N'role-taxuser',0)
	END
	Update Common.DetailLog set Status = @COMPLETED where Id = @taxRoles_Unique_Identifier

	--role permission--
	DECLARE @taxRolePermission_Unique_Identifier uniqueidentifier = NEWID()
	INSERT INTO Common.DetailLog values(@taxRolePermission_Unique_Identifier, @UNIQUE_Id , 'FW_SEED_DATA_TAX - Tax Role Permission Execution Started', GETUTCDATE() , '7.7' , NULL , @IN_PROGRESS )

	IF NOT EXISTS (SELECT * FROM Auth.RolePermission where RoleId=(select Id from Auth.Role where CompanyId=@NEW_COMPANY_ID and Name='TX User')) 
	BEGIN
		Insert into Auth.RolePermission (ID, RoleID, ModuleDetailPermissionID)
		Select NEWID(), R.ID as RoleID,  MDP.ID ModulePermissionDetailID
		From Auth.Role R Inner Join Common.ModuleMaster MM on MM.ID = R.ModuleMasterId 
		Inner Join Common.ModuleDetail MD on MD.ModuleMasterId = MM.ID Inner Join AUTH.ModuleDetailPermission MDP on MDP.ModuleDetailId = MD.ID
		Where R.Name = 'TX User' And R.CompanyId=@NEW_COMPANY_ID and MD.IsPartner=0 and MD.GroupName in ('Client','Summary') and  MD.ModuleMasterId=(select Id from Common.ModuleMaster where Name='Tax Cursor' and CompanyId=0) and MDP.PermissionName='View'
	END
	Update Common.DetailLog set Status = @COMPLETED where Id = @taxRolePermission_Unique_Identifier

	--tax seed data
	----Tax Manual--------
	if not exists(select * from Tax.TaxManual where Name='Custom' and CompanyId=@NEW_COMPANY_ID)        
	begin
		insert into Tax.TaxManual(Id,Name,CompanyId,Version,Description,Status,UserCreated,CreatedDate,ModifiedBy,ModifiedDate)
		values(NEWID(),'Custom',@NEW_COMPANY_ID,'V1','',1,'system',GETDATE(),NULL,NULL)
	end

	IF NOT EXISTS(select * from Tax.PlanningAndCompletionSetUpMaster where TaxManualId=(select id from Tax.TaxManual where CompanyId=@NEW_COMPANY_ID and Name='Custom') and CompanyId=@NEW_COMPANY_ID)        
	Begin
		INSERT INTO Tax.PlanningAndCompletionSetUpMaster(Id,CompanyId,Status,UserCreated,CreatedDate,ModifiedBy,ModifiedDate,TaxManualId)
		values(NEWID(),@NEW_COMPANY_ID,1,'system',GETDATE(),NULL,NULL,(select id from Tax.TaxManual where CompanyId=@NEW_COMPANY_ID and Name='Custom'))
	End

	IF NOT EXISTS(select * from Tax.TaxClassificationMaster where TaxManualId=(select id from Tax.TaxManual where CompanyId=@NEW_COMPANY_ID and Name='Custom') and CompanyId=@NEW_COMPANY_ID)        
	Begin
		INSERT INTO Tax.TaxClassificationMaster(Id,CompanyId,Status,UserCreated,CreatedDate,ModifiedBy,ModifiedDate,TaxManualId)
		values(NEWID(),@NEW_COMPANY_ID,1,'system',GETDATE(),NULL,NULL,(select id from Tax.TaxManual where CompanyId=@NEW_COMPANY_ID and Name='Custom'))
	End
	IF NOT EXISTS(select * from Tax.CheckListMaster where TaxManual='Custom' and CompanyId=@NEW_COMPANY_ID)        
	Begin
		INSERT INTO Tax.CheckListMaster(Id,CompanyId,Status,UserCreated,CreatedDate,ModifiedBy,ModifiedDate,TaxManual,Year)
		values(NEWID(),@NEW_COMPANY_ID,1,'system',GETDATE(),NULL,NULL,'Custom',YEAR(GETDATE()))
	End
	
	--[Tax].[Classification]
	DECLARE @classification_Unique_Identifier uniqueidentifier = NEWID()
	INSERT INTO Common.DetailLog values(@classification_Unique_Identifier, @UNIQUE_Id , 'FW_SEED_DATA_TAX - Classification Execution Started', GETUTCDATE() , '7.8' , NULL , @IN_PROGRESS )
	Declare @Classification_Cnt bigint;
	select @Classification_Cnt=Count (*) from 	[Tax].[Classification] where companyid=@NEW_COMPANY_ID	
	IF @Classification_Cnt=0
	-- Begin
	BEGIN
		IF NOT EXISTS (SELECT * FROM [Tax].[Classification] WHERE  [CompanyId] = @NEW_COMPANY_ID)
		BEGIN   
			INSERT INTO  [Tax].[Classification] (Id, CompanyId,  [Index], ClassificationType, AccountClass, IsSystem, ClassificationName, FinancialStatementTemplate, Remarks, RecOrder, UserCreated, CreatedDate, ModifiedBy, ModifiedDate, Version, Status ,Disclosure,typeId)
			SELECT NEWID(),@NEW_COMPANY_ID,[Index], ClassificationType, AccountClass, 1, ClassificationName, FinancialStatementTemplate, Remarks, RecOrder, 'System', CreatedDate, null, null, Version, Status ,Disclosure,Id FROM [Tax].[Classification] WHERE COMPANYID=@UNIQUE_COMPANY_ID	      
		END
	END;

	Update Common.DetailLog set Status = @COMPLETED where Id = @classification_Unique_Identifier

	---[Tax].[ClassificationCategories]-----
	DECLARE @classificationCategories_Unique_Identifier uniqueidentifier = NEWID()
	INSERT INTO Common.DetailLog values(@classificationCategories_Unique_Identifier, @UNIQUE_Id , 'FW_SEED_DATA_TAX - Classification Categories Execution Started', GETUTCDATE() , '7.9' , NULL , @IN_PROGRESS )
	Insert Into [Tax].[ClassificationCategories]
	([Id],[ClassificationId],[Name],[RecOrder],[Status])
	SELECT newid() as Id,(select ID FROM [Tax].[Classification] where CompanyId = @NEW_COMPANY_ID and ClassificationName = (select ClassificationName FROM  [Tax].[Classification] where Id = cat.[ClassificationId] and CompanyId = @UNIQUE_COMPANY_ID))   as [LeadsheetID],cat.[Name],@NEW_COMPANY_ID,cat.[Status]
	FROM [Tax].[ClassificationCategories] cat inner join [Tax].[Classification] ld
	on ld.Id = cat.ClassificationId 
	where ld.CompanyId = @UNIQUE_COMPANY_ID

	Update Common.DetailLog set Status = @COMPLETED where Id = @classificationCategories_Unique_Identifier

	----------====================== Template ==================================

	DECLARE @template_Unique_Identifier uniqueidentifier = NEWID()
	INSERT INTO Common.DetailLog values(@template_Unique_Identifier, @UNIQUE_Id , 'FW_SEED_DATA_TAX - Template Execution Started', GETUTCDATE() , '7.10' , NULL , @IN_PROGRESS )
	Declare @Template_Cnt bigint;
	select @Template_Cnt=Count(*) from	[Common].[Template] where companyid=@NEW_COMPANY_ID	
	IF @Template_Cnt=0
	Begin	
		INSERT INTO [Common].[Template] (Id, Name, Code, CompanyId, FromEmailId, CCEmailIds, BCCEmailIds, TemplateType, TempletContent, RecOrder,
		Remarks, UserCreated, CreatedDate, ModifiedBy, ModifiedDate, Version, Status, Subject, TemplateMenu, ToEmailId, IsUnique,CursorName)		    
		SELECT (NEWID()), Name, Code, @NEW_COMPANY_ID, FromEmailId, CCEmailIds, BCCEmailIds, TemplateType, TempletContent, RecOrder,
		Remarks, UserCreated, GETUTCDATE(), null, null, Version, status, Subject, TemplateMenu, ToEmailId, IsUnique,CursorName
		FROM [Common].[Template] WHERE COMPANYID=@UNIQUE_COMPANY_ID AND IsUnique=@STATUS;
	End

	Update Common.DetailLog set Status = @COMPLETED where Id = @template_Unique_Identifier

	
	print @IS_ACCOUNTING_FIRM;
	If(@IS_ACCOUNTING_FIRM = 1)
	Begin 
	    
		-----------------------------PlannigAndCompletionSetUp-----------------------
		DECLARE @Planning_And_Completion_Unique_Identifier uniqueidentifier = NEWID()
		INSERT INTO Common.DetailLog values(@Planning_And_Completion_Unique_Identifier, @UNIQUE_Id , 'FW_SEED_DATA_TAX - Planning and Completion Execution Started', GETUTCDATE() , '7.11' , NULL , @IN_PROGRESS )
		Declare @PartnerCompany_Cnt int;
		select @PartnerCompany_Cnt=COUNT(*)  from [Common].[Company] where id=@NEW_COMPANY_ID and ParentId is null and IsAccountingFirm=1
		IF @PartnerCompany_Cnt!=0
		BEGIN
		Declare @PandCSetup_Cnt int;
		select @PandCSetup_Cnt=Count(*) from [Tax].[PlanningAndCompletionSetUp] where companyid=@NEW_COMPANY_ID 
		IF @PandCSetup_Cnt=0
		Begin
		--1 Tax.PlanningAndCompletionSetUp
		DECLARE @PAC_UNQC TABLE(ID UNIQUEIDENTIFIER,COMPANYID BIGINT,CODE NVARCHAR(MAX))
		DECLARE @PAC_ID_FOR_UNQC UNIQUEIDENTIFIER
		DECLARE @PAC_UNQCID BIGINT
		DECLARE @PAC_MCODE NVARCHAR(MAX)
		DECLARE @PAC_NEWID UNIQUEIDENTIFIER

		INSERT INTO @PAC_UNQC 
		SELECT ID,COMPANYID,MenuCode FROM Tax.PlanningAndCompletionSetUp WHERE COMPANYID=@UNIQUE_COMPANY_ID

		--2 Tax.PAndCSections

		DECLARE @SEC_UNQC TABLE(ID UNIQUEIDENTIFIER,PAC_ID UNIQUEIDENTIFIER,SECTION NVARCHAR(MAX),DESCRIPTION NVARCHAR(MAX))

		DECLARE @SEC_ID UNIQUEIDENTIFIER
		DECLARE @SEC_PAC_ID UNIQUEIDENTIFIER
		DECLARE @SECTION NVARCHAR(MAX)
		DECLARE @DESCRIPTION NVARCHAR(MAX)
		DECLARE @SEC_NEWID UNIQUEIDENTIFIER

		-- CURSOR FOR PAC TABLE
		DECLARE PAC CURSOR FOR SELECT * FROM @PAC_UNQC 
		OPEN PAC
		FETCH NEXT FROM PAC INTO @PAC_ID_FOR_UNQC,@PAC_UNQCID,@PAC_MCODE 
		WHILE (@@FETCH_STATUS=0)
		BEGIN
		SELECT @PAC_NEWID =NEWID()
		INSERT INTO Tax.PlanningAndCompletionSetUp(ID, CompanyId, TaxCompanyId,EngagementId,ModuleDetailId,Type,MenuCode,MenuName,Description,FormType,Remarks,UserCreated,CreatedDate,ModifiedBy,ModifiedDate,status,Recorder,EngagementType,Conclusion,IsMigrated,ConclusionLable,TypeId)
		SELECT @PAC_NEWID,@NEW_COMPANY_ID,TaxCompanyId,EngagementId,ModuleDetailId,Type,MenuCode,MenuName,Description,FormType,Remarks,'System',GETUTCDATE(),NULL,NULL,Status,Recorder,EngagementType,Conclusion,IsMigrated,ConclusionLable,Id
		FROM Tax.PlanningAndCompletionSetUp WHERE ID=@PAC_ID_FOR_UNQC

		IF EXISTS(SELECT * FROM @SEC_UNQC)
		BEGIN
		DELETE FROM @SEC_UNQC 
		END

		INSERT INTO @SEC_UNQC 
		SELECT ID,PlanningAndCompletionSetUpId,Heading,DESCRIPTION FROM Tax.PAndCSections WHERE PlanningAndCompletionSetUpId=@PAC_ID_FOR_UNQC

		-- CURSOR FOR PAndCSections TABLE and PAndCSectionQuestions
		DECLARE SECTION CURSOR FOR SELECT * FROM @SEC_UNQC 
		OPEN SECTION
		FETCH NEXT FROM SECTION INTO @SEC_ID,@SEC_PAC_ID,@SECTION,@DESCRIPTION
		WHILE (@@FETCH_STATUS=0)
		BEGIN
			SELECT @SEC_NEWID =NEWID()
			INSERT INTO Tax.PAndCSections(Id,PlanningAndCompletionSetUpId,Heading,Description,CommentLable,CommentDescription,Remarks,UserCreated,CreatedDate,ModifiedBy,ModifiedDate,Status,Recorder)
			SELECT @SEC_NEWID,@PAC_NEWID,Heading,DESCRIPTION,CommentLable,[CommentDescription],Remarks,UserCreated,GETUTCDATE(),NULL,NULL,Status,Recorder
			FROM Tax.PAndCSections WHERE ID=@SEC_ID --AND PlanningAndCompletionSetUpId=@SEC_PAC_ID AND Heading=@SECTION AND DESCRIPTION=@DESCRIPTION

			INSERT INTO Tax.PAndCSectionQuestions(Id,PAndCSectionId,Question,QuestionOptions,Answer,IsComment,Comment,IsAttachement,AttachmentsCount,Remarks,UserCreated,CreatedDate,ModifiedBy,ModifiedDate,Status,Recorder,AttachmentName)
			SELECT NEWID(),@SEC_NEWID,Question,QuestionOptions,Answer,IsComment,Comment,IsAttachement,AttachmentsCount,Remarks,UserCreated,GETUTCDATE(),NULL,NULL,Status,Recorder,AttachmentName
			FROM Tax.PAndCSectionQuestions WHERE PAndCSectionId=@SEC_ID
			FETCH NEXT FROM SECTION INTO @SEC_ID,@SEC_PAC_ID,@SECTION,@DESCRIPTION
		END
		CLOSE SECTION
		DEALLOCATE SECTION
		
		FETCH NEXT FROM PAC INTO @PAC_ID_FOR_UNQC,@PAC_UNQCID,@PAC_MCODE 
		END
		CLOSE PAC
		DEALLOCATE PAC
		end
		END
		Update Common.DetailLog set Status = @COMPLETED where Id = @Planning_And_Completion_Unique_Identifier

		------added for super admin level foreign exchange--26th Jun---
		------for Foreign Exchange  seed data at super user level to insert into patner level company's
		--[Tax].[MonthlyForeignExchange]
		DECLARE @monthlyForeignExchange_Unique_Identifier uniqueidentifier = NEWID()
		INSERT INTO Common.DetailLog values(@monthlyForeignExchange_Unique_Identifier, @UNIQUE_Id , 'FW_SEED_DATA_TAX - Monthly Foreign Exchange Execution Started', GETUTCDATE() , '7.12' , NULL , @IN_PROGRESS )
		SET @CompanyType = (select IsAccountingFirm from Common.Company  where  IsAccountingFirm=1 and  id=@NEW_COMPANY_ID)
		DECLARE @MonthlyForeignExchange_Cnt bigint;
		select @MonthlyForeignExchange_Cnt=Count (*) from  [Tax].[MonthlyForeignExchange] where companyid=@NEW_COMPANY_ID 
		IF @MonthlyForeignExchange_Cnt=0
		-- Begin

		BEGIN
		IF NOT EXISTS (SELECT * FROM [Tax].[MonthlyForeignExchange] WHERE  [CompanyId] = @NEW_COMPANY_ID)
			IF(@CompanyType=1)
			BEGIN   
				INSERT INTO  [Tax].[MonthlyForeignExchange] (Id, CompanyId, [Month], [Year], BaseCurrency, BaseToFunctionalCurrency, CreatedDate, FunctionalCurrency, FunctionalToBaseCurrency, Remarks, RecOrder, UserCreated, ModifiedBy, ModifiedDate, Version, Status)
				SELECT NEWID(),@NEW_COMPANY_ID,[Month], [Year], [BaseCurrency], [BaseToFunctionalCurrency], [CreatedDate], [FunctionalCurrency], [FunctionalToBaseCurrency], [Remarks], [RecOrder], [UserCreated], null, null, [Version], [Status]  FROM [Tax].[MonthlyForeignExchange] WHERE COMPANYID=@UNIQUE_COMPANY_ID
			END
		END;

		Update Common.DetailLog set Status = @COMPLETED where Id = @monthlyForeignExchange_Unique_Identifier
		-----------------------Added for [AccountPolicy] for partner level company------------------------
 
		DECLARE @accountpolicy_Unique_Identifier uniqueidentifier = NEWID()
		INSERT INTO Common.DetailLog values(@accountpolicy_Unique_Identifier, @UNIQUE_Id , 'FW_SEED_DATA_TAX - Account Policy Execution Started', GETUTCDATE() , '7.12' , NULL , @IN_PROGRESS )
		SET @CompanyType = (select IsAccountingFirm from Common.Company  where  IsAccountingFirm=1 and  id=@NEW_COMPANY_ID)
		DECLARE @AccountPolicy_Cnt bigint;
		select  @AccountPolicy_Cnt=Count (*) from  [Tax].[AccountPolicy] where companyid=@NEW_COMPANY_ID 
		IF  @AccountPolicy_Cnt=0
		BEGIN
			IF NOT EXISTS (SELECT * FROM [Tax].[AccountPolicy] WHERE  [CompanyId] = @NEW_COMPANY_ID)
			if(@CompanyType=1)
			BEGIN
				insert into [Tax].[AccountPolicy](Id,CompanyId,EngagementId,PolicyName,PolicyTemplate,IsChecked,IsSytem,Remarks,RecOrder,UserCreated,CreatedDate,ModifiedBy,ModifiedDate,Version,Status,Section)
				select NEWID(),@NEW_COMPANY_ID,null,PolicyName,PolicyTemplate,IsChecked,IsSytem,Remarks,RecOrder,'System',GETUTCDate(),null,null,Version,Status,Section from [Tax].[AccountPolicy] where CompanyId=0
			END
		END
		Update Common.DetailLog set Status = @COMPLETED where Id = @accountpolicy_Unique_Identifier

		--** Exemptions
		print 'test';
		IF NOT EXISTS (select * from TAX.EXEMPTION where companyid=@NEW_COMPANY_ID)
		Begin
			Insert into  TAX.EXEMPTION (Id,CompanyId,ExemptionType,EffectiveFromYA,EffectiveToYA,EffectiveFromDate,EffectiveToDate,UserCreated,CreatedDate,ModifiedBy,ModifiedDate,Status,PartnerId) 
			select Newid(),@NEW_COMPANY_ID,ExemptionType,EffectiveFromYA,EffectiveToYA,EffectiveFromDate,EffectiveToDate,UserCreated,CreatedDate,ModifiedBy,ModifiedDate,Status,Id
			from  TAX.EXEMPTION  where companyid=0
		End


		DECLARE @Id UNIQUEIDENTIFIER;
		DECLARE @ExemptionId UNIQUEIDENTIFIER;
		DECLARE exemption CURSOR FOR SELECT ED.ID,ED.EXEMPTIONID FROM  TAX.EXEMPTION  E JOIN  TAX.EXEMPTIONDETAILS  ED ON E.ID=ED.EXEMPTIONID WHERE E.COMPANYID=0
		OPEN exemption
		FETCH NEXT FROM exemption INTO @Id,@ExemptionId
		WHILE (@@FETCH_STATUS=0)
		BEGIN
		Print @ExemptionId
		   INSERT INTO TAX.EXEMPTIONDETAILS (Id,ExemptionId,FromValue,ToValue,ExemptedRate,RecOrder)
		   SELECT NewId(),(select Id from TAX.EXEMPTION where PartnerId=@ExemptionId and CompanyId=@NEW_COMPANY_ID ),FromValue,ToValue,ExemptedRate,RecOrder from TAX.EXEMPTIONDETAILS where id=@Id
 
			FETCH NEXT FROM exemption INTO @Id,@ExemptionId
		END
		CLOSE exemption
		DEALLOCATE exemption

		print 'test1';
		--** Rebates

		IF NOT EXISTS (select * from tax.rebates where companyid=@NEW_COMPANY_ID)
		Begin
			Insert into tax.rebates (Id,CompanyId,RebatesType,MaximumCapable,CorporateIncome,EffectiveFromYA,EffectiveToYA,UserCreated,CreatedDate,ModifiedBy,ModifiedDate,Status,RecOrder) 
			select Newid(),@NEW_COMPANY_ID,RebatesType,MaximumCapable,CorporateIncome,EffectiveFromYA,EffectiveToYA,UserCreated,CreatedDate,ModifiedBy,ModifiedDate,Status,RecOrder  from tax.rebates  where companyid=0
		End

		--** Capital Allownces

		IF NOT EXISTS (select * from Tax.CapitalAllowance where companyid=@NEW_COMPANY_ID)
		Begin
			Insert into Tax.CapitalAllowance (Id,CompanyId,TypeOfClaim,LifeofYears,IntialAllowance,EffectiveFromDate,EffectiveToDate,UserCreated,CreatedDate,ModifiedBy,ModifiedDate,Recorder,Status,EffectiveType,EffectiveFromYA,EffectiveToYA,PICQualified)
			select Newid(),@NEW_COMPANY_ID,TypeOfClaim,LifeofYears,IntialAllowance,EffectiveFromDate,EffectiveToDate,UserCreated,CreatedDate,ModifiedBy,ModifiedDate,Recorder,Status,EffectiveType,EffectiveFromYA,EffectiveToYA,PICQualified
			 from Tax.CapitalAllowance  Where Companyid=0
		End


		--** Nature

		IF NOT EXISTS (select * from Tax.Nature where companyid=@NEW_COMPANY_ID)
		Begin
			Insert into Tax.Nature (Id,CompanyId,NatureType,Section,Name,Status,EffectiveType,EffectiveFromYA,EffectiveToYA,EffectiveToDate,EffectiveFromDate,UserCreated,CreatedDate,ModifiedBy,ModifiedDate,Percentage)
			select Newid(),@NEW_COMPANY_ID,NatureType,Section,Name,Status,EffectiveType,EffectiveFromYA,EffectiveToYA,EffectiveToDate,EffectiveFromDate,UserCreated,CreatedDate,ModifiedBy,ModifiedDate,Percentage
			 from Tax.Nature  where Companyid=0
		End

			print 'test2';
		--** Section14QSetUp

		IF NOT EXISTS (select * from Tax.Section14QSetUp where companyid=@NEW_COMPANY_ID)
		Begin
			Insert into Tax.Section14QSetUp (Id,CompanyId,OutstandingTaxLife,NumberOfYA,TotalAmount,EffectiveFromYA,EffectiveToYA,EffectiveFromDate,EffectiveToDate,Status,UserCreated,CreatedDate,ModifiedBy,ModifiedDate)
			select Newid(),@NEW_COMPANY_ID,OutstandingTaxLife,NumberOfYA,TotalAmount,EffectiveFromYA,EffectiveToYA,EffectiveFromDate,EffectiveToDate,Status,UserCreated,CreatedDate,ModifiedBy,ModifiedDate
			 from Tax.Section14QSetUp  where Companyid=0
		End

		--** IPC Multipliers

	
		IF NOT EXISTS (select * from Tax.IPCMultipliers where companyid=@NEW_COMPANY_ID)
		Begin
			Insert into Tax.IPCMultipliers (Id,CompanyId,IPCMultiplierPercentage,EffectiveFromDate,EffectiveToDate,RecOrder,Remarks,UserCreated,CreatedDate,ModifiedBy,ModifiedDate,Version,Status,EffectiveFromYA,EffectiveToYA)
			select Newid(),@NEW_COMPANY_ID,IPCMultiplierPercentage,EffectiveFromDate,EffectiveToDate,RecOrder,Remarks,UserCreated,CreatedDate,ModifiedBy,ModifiedDate,Version,Status,EffectiveFromYA,EffectiveToYA
			 from Tax.IPCMultipliers  where Companyid=0
		End

update Tax.PlanningAndCompletionSetUp set TaxManualId=(select id from Tax.TaxManual where Name='Custom' and CompanyId=@NEW_COMPANY_ID),MasterId=(select Id from Tax.PlanningAndCompletionSetUpMaster where TaxManualId=(select id from Tax.TaxManual where CompanyId=@NEW_COMPANY_ID and Name='Custom') and CompanyId=@NEW_COMPANY_ID) where CompanyId=@NEW_COMPANY_ID and EngagementId is null 
update Tax.Classification set MasterId=(select Id from Tax.TaxClassificationMaster where TaxManualId=(select id from Tax.TaxManual where Name='Custom' and CompanyId=@NEW_COMPANY_ID) and CompanyId=@NEW_COMPANY_ID),TaxManualId=(select id from Tax.TaxManual where Name='Custom' and CompanyId=@NEW_COMPANY_ID) where CompanyId=@NEW_COMPANY_ID and EngagementId is null
update Tax.AccountPolicy set TaxManual='Custom',CheckListId =(select id from tax.CheckListMaster where TaxManual='Custom' and YEAR=YEAR(GETDATE()) and  CompanyId=@NEW_COMPANY_ID) where CompanyId=@NEW_COMPANY_ID and EngagementId is null

	End  -- start from is accounting form

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
--COMMIT TRANSACTION
	Print 'Tax Seed Data Execution Completed'		
END
GO
