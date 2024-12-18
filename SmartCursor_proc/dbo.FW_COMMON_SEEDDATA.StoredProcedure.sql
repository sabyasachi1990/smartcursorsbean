USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[FW_COMMON_SEEDDATA]    Script Date: 16-12-2024 9.20.10 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE   PROC [dbo].[FW_COMMON_SEEDDATA] @UNIQUE_COMPANY_ID bigint, @NEW_COMPANY_ID bigint, @UNIQUE_Id uniqueidentifier
AS
BEGIN
BEGIN TRY
DECLARE @IN_PROGRESS nvarchar(20) = 'In-Progress'
DECLARE @COMPLETED nvarchar(20) = 'Completed'
DECLARE @CREATED_DATE DATETIME
Declare @CompanyFeatures_Cnt int
DECLARE @MODULE_NAME varchar(20) = 'Admin Cursor' 
DECLARE @MODULE_ID bigint =  (select Id from Common.ModuleMaster where Name = @MODULE_NAME)
Set @CREATED_DATE = GETUTCDATE()
--================================================================
--ControlCodeCategory, ControlCode and ControlCodeCategoryModule  Insertion
DECLARE @ControlCode_Unique_Identifier uniqueidentifier = NEWID()
--INSERT INTO Common.DetailLog values(@ControlCode_Unique_Identifier, @UNIQUE_Id , 'FW_COMMON_SEEDDATA - ControlCodes Execution Started', GETUTCDATE() , '1.1' , NULL , @IN_PROGRESS )
 
 EXEC [dbo].[FW_CONTROL_CODE_INSERTION] @UNIQUE_COMPANY_ID, @NEW_COMPANY_ID, @MODULE_NAME

-- Update Common.DetailLog set Status = @COMPLETED where Id = @ControlCode_Unique_Identifier
 --===============================================================
 --ModuleDetail Insertion
DECLARE @ModuleDetail_Unique_Identifier uniqueidentifier = NEWID()
 --INSERT INTO Common.DetailLog values(@ModuleDetail_Unique_Identifier, @UNIQUE_Id , 'FW_COMMON_SEEDDATA - ModuleDetail Execution Started', GETUTCDATE() , '1.2' , NULL , @IN_PROGRESS )

 EXEC [dbo].[FW_MODULE_DETAIL_INSERTION] @UNIQUE_COMPANY_ID, @NEW_COMPANY_ID, @MODULE_ID

 -- Update Common.DetailLog set Status = @COMPLETED where Id = @ModuleDetail_Unique_Identifier
 --================================================================
 --InitialCursor Setup Insertion
 DECLARE @InitialCursorSetup_Unique_Identifier uniqueidentifier = NEWID()
-- INSERT INTO Common.DetailLog values(@InitialCursorSetup_Unique_Identifier, @UNIQUE_Id , 'FW_COMMON_SEEDDATA - InitialCursorSetup Execution Started', GETUTCDATE() , '1.3' , NULL , @IN_PROGRESS )

 EXEC [dbo].[FW_INITIAL_CURSOR_SETUP_SEED] @UNIQUE_COMPANY_ID, @NEW_COMPANY_ID, @MODULE_ID

 --Update Common.DetailLog set Status = @COMPLETED where Id = @InitialCursorSetup_Unique_Identifier
 --=================================================================
 DECLARE @gridmetadata_Unique_Identifier uniqueidentifier = NEWID()
 --INSERT INTO Common.DetailLog values(@gridmetadata_Unique_Identifier, @UNIQUE_Id , 'FW_COMMON_SEEDDATA - GridMetaData Execution Started', GETUTCDATE() , '1.4' , NULL , @IN_PROGRESS )

 EXEC [dbo].[FW_GRIDMETADATA_SEED_INSERTION] @UNIQUE_COMPANY_ID, @NEW_COMPANY_ID, @MODULE_ID

-- Update Common.DetailLog set Status = @COMPLETED where Id = @gridmetadata_Unique_Identifier
 --=================================================================
-- DECLARE @CompanyFeatures_Unique_Identifier uniqueidentifier = NEWID()
--  INSERT INTO Common.DetailLog values(@CompanyFeatures_Unique_Identifier, @UNIQUE_Id , 'CompanyFeatures Execution Started', GETUTCDATE() , '1.4' , NULL , @IN_PROGRESS )
-- select @CompanyFeatures_Cnt=Count(*) from common.CompanyFeatures where companyid=@NEW_COMPANY_ID	
--	IF @CompanyFeatures_Cnt=0
--	Begin

--INSERT INTO common.CompanyFeatures( Id, CompanyId, FeatureId, Status,  Remarks,IsChecked)
--		select  NEWID(),@NEW_COMPANY_ID,b.FeatureId,b.Status,b.Remarks,b.IsChecked from [Common].[Feature] a join [Common].[CompanyFeatures] b on a.Id=b.FeatureId where a.VisibleStyle <> 'SuperUser-CheckBox' and a.VisibleStyle <> 'HRCursor-CheckBox' and CompanyId=@UNIQUE_COMPANY_ID
-- End
--    Update Common.DetailLog set Status = @COMPLETED where Id = @CompanyFeatures_Unique_Identifier
--===================================================================
DECLARE @CompanyModuleSetUp_unique_identifier uniqueidentifier = NEWID() 
 --INSERT INTO Common.DetailLog values(@CompanyModuleSetUp_unique_identifier, @UNIQUE_Id , 'CompanyModuleSetUp Execution Started', GETUTCDATE() , '1.5' , NULL , @IN_PROGRESS )
BEGIN

   IF NOT EXISTS (SELECT * FROM [Common].[CompanyFeatures] 
                   WHERE  [CompanyId] = @NEW_COMPANY_ID)
				   Declare @CompanyModuleSetUp_Cnt int
				   select 	@CompanyModuleSetUp_Cnt=Count(*) from 	[Common].[CompanyModuleSetUp] where companyid=@NEW_COMPANY_ID	
	               IF @CompanyModuleSetUp_Cnt=0
   BEGIN   
 INSERT INTO  [Common].[CompanyModuleSetUp] (Id, CompanyId,ModuleId,ModuleDetailUrl, Heading,SetUpOrder,IsMandatory,IsSetUpDone)  
       SELECT (NEWID()),@NEW_COMPANY_ID,ModuleId,ModuleDetailUrl, Heading,SetUpOrder,IsMandatory,IsSetUpDone FROM [Common].[CompanyModuleSetUp] WHERE COMPANYID=0	     
   END

END;
   -- Update Common.DetailLog set Status = @COMPLETED where Id = @CompanyModuleSetUp_unique_identifier

--===================================================================
--Id Type
DECLARE @IdTypes_unique_identifier uniqueidentifier = NEWID() 
-- INSERT INTO Common.DetailLog values(@IdTypes_unique_identifier, @UNIQUE_Id , 'IdTypes Execution Started', GETUTCDATE() , '1.6' , NULL , @IN_PROGRESS )
DECLARE @IDTYPE_CNT INT;
	SELECT @IDTYPE_CNT=COUNT(*) FROM [COMMON].[IDTYPE] WHERE COMPANYID=@NEW_COMPANY_ID 
	IF @IDTYPE_CNT=0
	BEGIN
	
		UPDATE [Common].[IdType] SET[TempIdTypeId] = NULL;
		--================================================
		INSERT INTO [Common].[IdType] (Id, Name, CompanyId, RecOrder, Remarks, UserCreated, CreatedDate, ModifiedBy, ModifiedDate, Version, Status,TempIdTypeId) 
		SELECT ROW_NUMBER() OVER(ORDER BY ID) + (SELECT MAX(id) + 1 FROM [Common].[IdType]), Name, @NEW_COMPANY_ID, RecOrder, Remarks,
		UserCreated, @CREATED_DATE, null, null, Version, status, Id FROM [Common].[IdType] WHERE COMPANYID=@UNIQUE_COMPANY_ID	
	END
	  --  Update Common.DetailLog set Status = @COMPLETED where Id = @IdTypes_unique_identifier
--=====================================================================
--Account Type and 
--DECLARE @AccountTypes_unique_identifier uniqueidentifier = NEWID() 
	-- INSERT INTO Common.DetailLog values(@AccountTypes_unique_identifier, @UNIQUE_Id , 'AccountTypes Execution Started', GETUTCDATE() , '1.7' , NULL , @IN_PROGRESS )
Declare @AccountType_Cnt int;
	select @AccountType_Cnt=Count(*) from [Common].[AccountType] where companyid=@NEW_COMPANY_ID 
	IF @AccountType_Cnt=0
	Begin
	--UPDATE [Common].[AccountType] SET [TempAccountTypeId] = NULL;
	--================================================================
INSERT INTO [Common].[AccountType] (Id, Name, CompanyId, RecOrder, Remarks, UserCreated, CreatedDate, ModifiedBy, ModifiedDate, Version, Status,TempAccountTypeId)
	SELECT ROW_NUMBER() OVER(ORDER BY ID) + (SELECT MAX(Id) + 1 FROM [Common].[AccountType]), Name, @NEW_COMPANY_ID, RecOrder, Remarks, UserCreated,
	@CREATED_DATE, null, null, Version, status,Id FROM [Common].[AccountType]  WHERE COMPANYID=@UNIQUE_COMPANY_ID;

	-- Update Common.DetailLog set Status = @COMPLETED where Id = @AccountTypes_unique_identifier
	--Added by Nagendra 
	--====================================================================
--AccountTypeIdType
DECLARE @AccountTypeIdType_unique_identifier uniqueidentifier = NEWID() 
--INSERT INTO Common.DetailLog values(@AccountTypeIdType_unique_identifier, @UNIQUE_Id , 'AccountTypeIdType Execution Started', GETUTCDATE() , '1.8' , NULL , @IN_PROGRESS )
	INSERT INTO  [Common].[AccountTypeIdType] (Id, AccountTypeId, IdTypeId, RecOrder)		
		SELECT ROW_NUMBER() OVER(ORDER BY A.ID) + (SELECT MAX(ID) + 1 FROM [Common].[AccountTypeIdType]) ,B.Id AS ACCOUNTTYPEID,C.Id AS IDTYPEID,
		A.RecOrder FROM [Common].[AccountTypeIdType] A JOIN [Common].[AccountType] B ON A.AccountTypeId = B.TempAccountTypeId JOIN [Common].[IdType] C 
		ON C.TempIdTypeId = A.IdTypeId	WHERE B.CompanyId=@NEW_COMPANY_ID AND C.CompanyId=@NEW_COMPANY_ID;
	End
	-- Update Common.DetailLog set Status = @COMPLETED where Id = @AccountTypeIdType_unique_identifier
--==========================================================================
-- Configuration (Currently only WF but in Future few cursors might use this)

DECLARE @CommonConfiguration_unique_identifier uniqueidentifier = NEWID() 
--INSERT INTO Common.DetailLog values(@CommonConfiguration_unique_identifier, @UNIQUE_Id , 'Common.Configuration Execution Started', GETUTCDATE() , '1.9' , NULL , @IN_PROGRESS )
BEGIN
   --IF NOT EXISTS (SELECT * FROM [Common].[Configuration]   ------ Commented by harish
   --                WHERE  [CompanyId] = @NEW_COMPANY_ID)
			--	   Declare @Configuration_Cnt int
			--	   select 	@Configuration_Cnt=Count(*) from 	[Common].[Configuration] where companyid=@NEW_COMPANY_ID	
	  --             IF @Configuration_Cnt=0
	  IF NOT EXISTS (SELECT * FROM [Common].[Configuration]  -- New Code
                   WHERE  [CompanyId] = @NEW_COMPANY_ID)
   BEGIN    
 Insert into  [Common].[Configuration](Id, CompanyId, [Key], [Value], Formate, CreatedDate,UserCreated, ModifiedBy, ModifiedDate, Status)  
       SELECT (NEWID()),@NEW_COMPANY_ID, [Key],Value, Formate,CreatedDate,UserCreated,null,null, Status  FROM [Common].[Configuration] WHERE COMPANYID=0	     
   END
END;
--Update Common.DetailLog set Status = @COMPLETED where Id = @CommonConfiguration_unique_identifier
--=================================================================================
--Reports	--HariBabu Seed Data from 0 Company to New Company
IF NOT EXISTS (SELECT * FROM [Report].[Report]  
                   WHERE  [CompanyId] = @NEW_COMPANY_ID)
				   BEGIN
DECLARE @AnalyticsReport_unique_identifier uniqueidentifier = NEWID() 
--INSERT INTO Common.DetailLog values(@AnalyticsReport_unique_identifier, @UNIQUE_Id , 'SP_Report_Category_Report Execution Entered', GETUTCDATE() , '1.10' , NULL , @IN_PROGRESS )
BEGIN
EXEC [dbo].[SP_Report_Category_Report] @UNIQUE_COMPANY_ID,@CREATED_DATE,@NEW_COMPANY_ID
END
--Update Common.DetailLog set Status = @COMPLETED where Id = @AnalyticsReport_unique_identifier
END
--====================================================
BEGIN
	Declare @CompanyType Bit 
	Select @CompanyType=IsAccountingFirm from Common.Company where  id=@NEW_COMPANY_ID
		IF(@CompanyType=1)
	BEGIN
	
	UPDATE [Common].[CompanyModule] SET [SetupDone]= 1 WHERE [ModuleId] = (select Id from common.modulemaster where Name='Knowledge Cursor') AND [CompanyId] = @NEW_COMPANY_ID
	UPDATE [Common].[CompanyModule] SET [SetupDone]= 1 WHERE [ModuleId] = (select Id from common.modulemaster where Name='Doc Cursor') AND [CompanyId] = @NEW_COMPANY_ID
	UPDATE [Common].[CompanyModule] SET [SetupDone]= 1 WHERE [ModuleId] = (select Id from common.modulemaster where Name='Audit Cursor') AND [CompanyId] = @NEW_COMPANY_ID
	UPDATE [Common].[CompanyModule] SET [SetupDone]= 1 WHERE [ModuleId] = (select Id from common.modulemaster where Name='Tax Cursor') AND [CompanyId] = @NEW_COMPANY_ID
	UPDATE [Common].[CompanyModule] SET [SetupDone]= 1 WHERE [ModuleId] = (select Id from common.modulemaster where Name='BR Cursor') AND [CompanyId] = @NEW_COMPANY_ID
	UPDATE [Common].[CompanyModule] SET [SetupDone]= 1 WHERE [ModuleId] = (select Id from common.modulemaster where Name='Partner Cursor') AND [CompanyId] = @NEW_COMPANY_ID
	END

	ELSE
	BEGIN

	UPDATE [Common].[CompanyModule] SET [SetupDone]= 1 WHERE [ModuleId] = (select Id from common.modulemaster where Name='Audit Cursor') AND [CompanyId] = @NEW_COMPANY_ID
	UPDATE [Common].[CompanyModule] SET [SetupDone]= 1 WHERE [ModuleId] = (select Id from common.modulemaster where Name='Knowledge Cursor') AND [CompanyId] = @NEW_COMPANY_ID
	UPDATE [Common].[CompanyModule] SET [SetupDone]= 1 WHERE [ModuleId] = (select Id from common.modulemaster where Name='Doc Cursor') AND [CompanyId] = @NEW_COMPANY_ID
	UPDATE [Common].[CompanyModule] SET [SetupDone]= 1 WHERE [ModuleId] = (select Id from common.modulemaster where Name='Tax Cursor') AND [CompanyId] = @NEW_COMPANY_ID
	UPDATE [Common].[CompanyModule] SET [SetupDone]= 1 WHERE [ModuleId] = (select Id from common.modulemaster where Name='BR Cursor') AND [CompanyId] = @NEW_COMPANY_ID
	UPDATE [Common].[CompanyModule] SET [SetupDone]= 1 WHERE [ModuleId] = (select Id from common.modulemaster where Name='Partner Cursor') AND [CompanyId] = @NEW_COMPANY_ID

	END
	END
--=======================================================================
DECLARE @TermsOfPayment_unique_identifier uniqueidentifier = NEWID() 
BEGIN
SET @CREATED_DATE =GETUTCDATE()
Declare @TermsOfPayment_Cnt int
Select @TermsOfPayment_Cnt = count(*) from [Common].[TermsOfPayment] where CompanyId = @NEW_COMPANY_ID
If @TermsOfPayment_Cnt =0
BEGIN
	--INSERT INTO Common.DetailLog values(@TermsOfPayment_unique_identifier, @UNIQUE_Id , 'Terms Of Payment Execution Started', GETUTCDATE() , '1.11' , NULL , @IN_PROGRESS )
		INSERT INTO [Common].[TermsOfPayment] (Id, Name, CompanyId, TermsType, TOPValue, RecOrder, Remarks, UserCreated, CreatedDate, ModifiedBy, 
			ModifiedDate, Version, Status, IsVendor, IsCustomer)
			SELECT ROW_NUMBER() OVER(ORDER BY ID) + (SELECT MAX(id) + 1 FROM [Common].[TermsOfPayment] ), Name, @NEW_COMPANY_ID, TermsType, TOPValue, 
			RecOrder, Remarks, UserCreated, @CREATED_DATE, null, null, Version, status, IsVendor, IsCustomer FROM [Common].[TermsOfPayment] 
			WHERE COMPANYID=@UNIQUE_COMPANY_ID;
			END
END 
--Update Common.DetailLog set Status = @COMPLETED where Id = @TermsOfPayment_unique_identifier
--========================================================================
-----------CURRENCY --------------------
DECLARE @Currency_unique_identifier uniqueidentifier = NEWID() 
Declare @Currency_Cnt int;
 select @Currency_Cnt=Count(*) from [Bean].[Currency] where companyid=@NEW_COMPANY_ID 
 IF @Currency_Cnt=0
 BEGIN
 --INSERT INTO Common.DetailLog values(@Currency_unique_identifier, @UNIQUE_Id , 'Terms Of Payment Execution Started', GETUTCDATE() , '1.12' , NULL , @IN_PROGRESS )
        INSERT INTO  [Bean].[Currency] (Id, Code, CompanyId, Name, RecOrder, Status, UserCreated, CreatedDate, ModifiedBy, ModifiedDate, DefaultValue)
   SELECT ROW_NUMBER() OVER(ORDER BY ID) + (SELECT MAX(id) + 1 FROM [Bean].[Currency]), Code, @NEW_COMPANY_ID, Name, RecOrder, STATUS,
   UserCreated, GETUTCDATE(), null, null, DefaultValue FROM [Bean].[Currency] WHERE COMPANYID=@UNIQUE_COMPANY_ID AND [Status] = 1 ;

END
--Update Common.DetailLog set Status = @COMPLETED where Id = @Currency_unique_identifier
--==========================================================================

	-----------GST CompanyFeature --------------------

DECLARE @GstCompanyFeature_Unique_Identifier uniqueidentifier = NEWID()
	--INSERT INTO Common.DetailLog values(@GstCompanyFeature_Unique_Identifier, @UNIQUE_Id , 'GST CompanyFeature Execution Started', GETUTCDATE() , '5.8' , NULL , @IN_PROGRESS )
BEGIN
	If Not Exists (Select Id From Common.CompanyFeatures WHere CompanyId=@NEW_COMPANY_ID And FeatureId=(select Id from Common.Feature where Name='GST'))
	BEGIN
		INSERT INTO Common.CompanyFeatures( Id, CompanyId, FeatureId, Status,  Remarks,IsChecked,UserCreated,CreatedDate)
		select  NEWID(),@NEW_COMPANY_ID,b.FeatureId,1,b.Remarks,b.IsChecked,'System',GETUTCDATE() from [Common].[Feature] a join [Common].[CompanyFeatures] b on a.Id=b.FeatureId where a.Name='GST' and CompanyId=@UNIQUE_COMPANY_ID
 
	END
	END
	--Update Common.DetailLog set Status = @COMPLETED where Id = @GstCompanyFeature_Unique_Identifier
	--==========================================================================

--	-----------Multi Currency CompanyFeature --------------------

--DECLARE @MultiCurrency_Unique_Identifier uniqueidentifier = NEWID()
--	INSERT INTO Common.DetailLog values(@MultiCurrency_Unique_Identifier, @UNIQUE_Id , 'Multi Currency Execution Started', GETUTCDATE() , '5.9' , NULL , @IN_PROGRESS )
--BEGIN
--	If Not Exists (Select Id From Common.CompanyFeatures WHere CompanyId=@NEW_COMPANY_ID And FeatureId=(select Id from Common.Feature where Name='Multi-Currency' and VisibleStyle='SuperUser-CheckBox'))
--	BEGIN
--		INSERT INTO Common.CompanyFeatures( Id, CompanyId, FeatureId, Status,  Remarks,IsChecked,UserCreated,CreatedDate)
--		select  NEWID(),@NEW_COMPANY_ID,b.FeatureId,1,b.Remarks,b.IsChecked,'System',GETUTCDATE() from [Common].[Feature] a join [Common].[CompanyFeatures] b on a.Id=b.FeatureId where a.Name='Multi-Currency' and a.VisibleStyle='SuperUser-CheckBox' and CompanyId=@UNIQUE_COMPANY_ID
 
--	END
--	END
--	Update Common.DetailLog set Status = @COMPLETED where Id = @MultiCurrency_Unique_Identifier
--	--==========================================================================


	-----------Inter-Company CompanyFeature --------------------

DECLARE @InterCompany_Unique_Identifier uniqueidentifier = NEWID()
	--INSERT INTO Common.DetailLog values(@InterCompany_Unique_Identifier, @UNIQUE_Id , 'Inter Company Execution Started', GETUTCDATE() , '6.0' , NULL , @IN_PROGRESS )
BEGIN
	If Not Exists (Select Id From Common.CompanyFeatures WHere CompanyId=@NEW_COMPANY_ID And FeatureId=(select Id from Common.Feature where Name='Inter-Company' and VisibleStyle='SuperUser-CheckBox'))
	BEGIN
		INSERT INTO Common.CompanyFeatures( Id, CompanyId, FeatureId, Status,  Remarks,IsChecked,UserCreated,CreatedDate)
		select  NEWID(),@NEW_COMPANY_ID,b.FeatureId,2,b.Remarks,b.IsChecked,'System',GETUTCDATE() from [Common].[Feature] a join [Common].[CompanyFeatures] b on a.Id=b.FeatureId where a.Name='Inter-Company' and a.VisibleStyle='SuperUser-CheckBox' and CompanyId=@UNIQUE_COMPANY_ID
 
	END
	END
	--Update Common.DetailLog set Status = @COMPLETED where Id = @InterCompany_Unique_Identifier
	--==========================================================================
	-- Taxcode Seed data

	Declare @CompanyGSTFeatures_Cnt BIGINT
	Declare @Jurisdiction NVARCHAR(100)
		select 	@CompanyGSTFeatures_Cnt=Count(*) from [Common].[Feature] a join [Common].[CompanyFeatures] b on a.Id=b.FeatureId where 
		a.Name='GST' and
		a.VisibleStyle ='SuperUser-CheckBox' and a.ModuleId is null and CompanyId=@NEW_COMPANY_ID and b.Status=1

		Set @Jurisdiction = (select Jurisdiction from Common.Company Where Id = @NEW_COMPANY_ID)

	IF @CompanyGSTFeatures_Cnt=1
Begin
	If Not Exists(select CompanyId from bean.taxcode where companyid=@NEW_COMPANY_ID)
		Begin
			Insert into bean.taxcode (Id,CompanyId,Code,Name,Description,AppliesTo,TaxType,TaxRate,EffectiveFrom,
			IsSystem,RecOrder,Remarks,UserCreated,CreatedDate,ModifiedBy,ModifiedDate,Version,Status,TaxRateFormula,
			IsApplicable,EffectiveTo,XeroTaxName,XeroTaxType,XeroTaxComponentName,XeroTaxRate,IsFromXero,IsSeedData,Jurisdiction)
			select (ROW_NUMBER() OVER (ORDER BY Id)+(select max(id) from bean.taxcode)),@NEW_COMPANY_ID as CompanyId,Code,Name,
			Description,AppliesTo,TaxType,TaxRate,EffectiveFrom,IsSystem,RecOrder,
			Remarks,UserCreated,GETUTCDATE(),ModifiedBy,ModifiedDate,Version,Status,TaxRateFormula,IsApplicable,EffectiveTo,
			XeroTaxName,XeroTaxType,XeroTaxComponentName,XeroTaxRate,IsFromXero,IsSeedData,Jurisdiction
			from bean.taxcode where companyid=0 and IsSeedData = 1 and Jurisdiction = @Jurisdiction
		End

End


	--====================== Pertner - Generic Templates Seed data ================================

 DECLARE @genericTemplates_Partner_Unique_Identifier uniqueidentifier = NEWID()
	--	INSERT INTO Common.DetailLog values(@genericTemplates_Partner_Unique_Identifier, @UNIQUE_Id , 'FW_COMMON_SEEDDATA - Generic Templates Execution Started', GETUTCDATE() , '5.10' , NULL , @IN_PROGRESS )

	declare @cnt bigint = (select Count(GT.Id) from Common.GenericTemplate GT
							Join Common.TemplateType TT on TT.Id = GT.TemplateTypeId
							where TT.ModuleMasterId = (select Id from Common.ModuleMaster where Name='Partner Cursor') and GT.CompanyId=@NEW_COMPANY_ID)
	If(@cnt = 0)
	BEGIN
		INSERT INTO Common.GenericTemplate ([Id],[CompanyId],[TemplateTypeId],[Name],[Code],[TempletContent],[IsSystem],[IsFooterExist],[IsHeaderExist],[RecOrder],[Remarks],[UserCreated],[CreatedDate],[ModifiedBy],[ModifiedDate],[Version],[Status],[Category],[IsPartnerTemplate],[CursorName],[TemplateType])

		SELECT NEWID(),@NEW_COMPANY_ID,GT.[TemplateTypeId],GT.[Name],GT.[Code],GT.[TempletContent],GT.[IsSystem],GT.[IsFooterExist],GT.[IsHeaderExist],GT.[RecOrder],GT.[Remarks],GT.[UserCreated],GETUTCDATE(),null,null,GT.[Version],1,GT.[Category],GT.[IsPartnerTemplate],GT.[CursorName],GT.[TemplateType]
		FROM Common.GenericTemplate GT
		Join Common.TemplateType TT on TT.Id = GT.TemplateTypeId 
		WHERE GT.CompanyId=@UNIQUE_COMPANY_ID and TT.ModuleMasterId = (select Id from Common.ModuleMaster where Name='Partner Cursor') and  GT.IsPartnerTemplate=1 and TemplateType not in (select ISNULL(TemplateType,' ') from Common.GenericTemplate where CompanyId=@NEW_COMPANY_ID)
	END

 --Update Common.DetailLog set Status = @COMPLETED where Id = @genericTemplates_Partner_Unique_Identifier
 ----==================





 --============ Partner Module details insertion ==============

	declare @PTRModuleId bigint = (select Id from common.ModuleMaster where name='Partner Cursor')
	IF exists (select * from common.companymodule where status=1 and moduleId=@PTRModuleId and companyId=@NEW_COMPANY_ID)
	Begin
		DECLARE @ModuleDetailPTR_Unique_Identifier uniqueidentifier = NEWID()
		--INSERT INTO Common.MasterLog values(@ModuleDetailPTR_Unique_Identifier, @NEW_COMPANY_ID , 'Partner Modulde detail Execution Started', 13, NULL, GETUTCDATE(), @IN_PROGRESS )
		EXEC [dbo].[FW_MODULE_DETAIL_INSERTION] @UNIQUE_COMPANY_ID, @NEW_COMPANY_ID, @PTRModuleId
		--Update Common.MasterLog set Status= @COMPLETED where Id=@ModuleDetailPTR_Unique_Identifier

		declare @moduleMasterId bigint = (select Id from Common.ModuleMaster where Name='Partner Cursor')
		declare @templateTypeId uniqueidentifier = (select Id from Common.TemplateType where name='PartnerLicenseInvoice' and CompanyId=0 and ModuleMasterId=@moduleMasterId)
		declare @companyId bigint = 0
		If exists(select * from common.GenericTemplate where CompanyId=0 and Name='LicensesInvoice' and Code='LicensesInvoice' and TemplateType='LicensesInvoice')
		BEGIN
			if not exists (select * from common.GenericTemplate where CompanyId=@NEW_COMPANY_ID and Name='PartnerLicenseInvoice' and Code='PartnerLicenseInvoice' and TemplateType='PartnerLicenseInvoice')
			BEGIN
				insert into Common.GenericTemplate (Id,CompanyId,TemplateTypeId,Name,Code,TempletContent,IsSystem,IsFooterExist,IsHeaderExist,RecOrder,Remarks,UserCreated,CreatedDate,ModifiedBy,ModifiedDate,Version,Status,Category,Conditions,IsUsed,FromEmailId,ToEmailId,CCEmailIds,BCCEmailIds,TemplateType,Subject,IsPartnerTemplate,IsDefultTemplate,Isthisemailtemplate,IsLandscape,CursorName,ServiceCompanyIds,ServiceCompanyNames,IsEnableServiceEntities,ISAllowDuplicates) 
				select  NewID(),@NEW_COMPANY_ID,@templateTypeId,Name,Code,TempletContent,IsSystem,IsFooterExist,IsHeaderExist,RecOrder,Remarks,'System',GETUTCDATE(),NULL,NULL,Version,1,Category,Conditions,IsUsed,FromEmailId,ToEmailId,CCEmailIds,BCCEmailIds,TemplateType,[Subject],1,IsDefultTemplate,Isthisemailtemplate,IsLandscape,CursorName,ServiceCompanyIds,ServiceCompanyNames,IsEnableServiceEntities,ISAllowDuplicates
				from Common.GenericTemplate where CompanyId=0 and Name='PartnerLicenseInvoice' and Code='PartnerLicenseInvoice' and TemplateType='PartnerLicenseInvoice'
			END
		END

	END


END TRY
 BEGIN CATCH
    PRINT 'FAILED..!'
	DECLARE      
     @ErrorMessage NVARCHAR(4000),      
     @ErrorSeverity INT,      
     @ErrorState INT;      
SELECT      
     @ErrorMessage = ERROR_MESSAGE(),      
     @ErrorSeverity = ERROR_SEVERITY(),      
     @ErrorState = ERROR_STATE();      
   RAISERROR (@ErrorMessage,@ErrorSeverity,@ErrorState);
	--ROLLBACK;
END CATCH
END
GO
