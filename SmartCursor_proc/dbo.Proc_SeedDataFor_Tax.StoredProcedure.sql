USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[Proc_SeedDataFor_Tax]    Script Date: 16-12-2024 9.20.11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[Proc_SeedDataFor_Tax](@UNIQUE_COMPANY_ID BIGINT,@NEW_COMPANY_ID BIGINT)
AS
BEGIN         
	DECLARE @STATUS   INT
	DECLARE @CREATED_DATE DATETIME	
	DECLARE @CONTROLCODECATEGORY_ID_MODULE_MASTER_ID BIGINT
	DECLARE @MODULE_MASTER_ID_CONTROLCODECATEGORY_ID BIGINT
	DECLARE @ACCOUNTYPE_ID_ID_TYPE_ID BIGINT
	DECLARE @ID_TYPE_ACCOUNTYPE_ID_ID BIGINT
	DECLARE @CompanyType Bit 	
	SET @STATUS = 1    
	SET @CREATED_DATE =GETUTCDATE()  		
	BEGIN TRANSACTION
	BEGIN TRY

	------------------------for new tax user roles

	IF NOT EXISTS (SELECT * FROM [Auth].[Role] where Name='TX User' and [ModuleMasterId]=(select Id from Common.ModuleMaster where CompanyId=0 and Heading='Tax Cursor') and CompanyId=@NEW_COMPANY_ID) 
   BEGIN
       INSERT [Auth].[Role] ([Id], [CompanyId], [Name], [Remarks], [ModuleMasterId], [Status], [ModifiedBy], [ModifiedDate], [UserCreated], [CreatedDate],[IsSystem],[BackgroundColor],[CursorIcon],[IsPartner])
       VALUES (newid(),@NEW_COMPANY_ID, N'TX User', NULL,(select Id from Common.ModuleMaster where CompanyId=0 and Heading='Tax Cursor'), 1, NULL, NULL, NULL, GETdate(),1,N'#67acda',N'role-taxuser',0)
   END

--role permission--

IF NOT EXISTS (SELECT * FROM Auth.RolePermission where RoleId=(select Id from Auth.Role where CompanyId=@NEW_COMPANY_ID and Name='TX User')) 
   BEGIN
			Insert into Auth.RolePermission (ID, RoleID, ModuleDetailPermissionID)
			Select NEWID(), R.ID as RoleID,  MDP.ID ModulePermissionDetailID
			From Auth.Role R Inner Join Common.ModuleMaster MM on MM.ID = R.ModuleMasterId 
			Inner Join Common.ModuleDetail MD on MD.ModuleMasterId = MM.ID Inner Join AUTH.ModuleDetailPermission MDP on MDP.ModuleDetailId = MD.ID
			Where R.Name = 'TX User' And R.CompanyId=@NEW_COMPANY_ID and MD.IsPartner=0 and MD.GroupName in ('Client','Summary') and  MD.ModuleMasterId=(select Id from Common.ModuleMaster where Name='Tax Cursor' and CompanyId=0) and MDP.PermissionName='View'
   END



		--TAX control codes

			--------EngagementType
--Declare @ControlCodeCategoryModuleEngagementType_Cnt bigint
-- select @ControlCodeCategoryModuleEngagementType_Cnt=Count(*) from [Common].[ControlCodeCategoryModule] where companyid=@NEW_COMPANY_ID 
--and controlcategoryId in(SELECT  ID FROM [Common].[ControlCodeCategory] WHERE COMPANYID=@NEW_COMPANY_ID AND CONTROLCODECATEGORYCODE='EngagementType') 
         
-- IF @ControlCodeCategoryModuleEngagementType_Cnt=0
-- Begin
--  	  SET @CONTROLCODECATEGORY_ID_MODULE_MASTER_ID = (SELECT top 1 ID FROM [Common].[ControlCodeCategory] WHERE COMPANYID=@NEW_COMPANY_ID AND CONTROLCODECATEGORYCODE='EngagementType')
--  SET @MODULE_MASTER_ID_CONTROLCODECATEGORY_ID = (SELECT Id FROM [Common].[ModuleMaster]  WHERE COMPANYID=@UNIQUE_COMPANY_ID AND NAME='Tax Cursor')
--  INSERT INTO [Common].[ControlCodeCategoryModule] (Id, CompanyId, ControlCategoryId, ModuleMasterId) VALUES ((SELECT MAX(Id) + 1 FROM [Common].[ControlCodeCategoryModule]),
--  @NEW_COMPANY_ID,@CONTROLCODECATEGORY_ID_MODULE_MASTER_ID,@MODULE_MASTER_ID_CONTROLCODECATEGORY_ID);
--  end
--		------------------------------------------Additionallevels For Tax-----------------------------------

-- Declare @ControlCodeCategoryModule_Additionallevels_Cnt bigint
-- select @ControlCodeCategoryModule_Additionallevels_Cnt=Count(*) from [Common].[ControlCodeCategoryModule] where companyid=@NEW_COMPANY_ID 
--and controlcategoryId in(SELECT ID FROM [Common].[ControlCodeCategory] WHERE COMPANYID=@NEW_COMPANY_ID AND CONTROLCODECATEGORYCODE='Additionallevels') 
         
-- IF @ControlCodeCategoryModule_Additionallevels_Cnt=0
-- Begin

--  SET @CONTROLCODECATEGORY_ID_MODULE_MASTER_ID = (SELECT top 1 ID FROM [Common].[ControlCodeCategory] WHERE COMPANYID=@NEW_COMPANY_ID AND CONTROLCODECATEGORYCODE='Additionallevels')
--  SET @MODULE_MASTER_ID_CONTROLCODECATEGORY_ID = (SELECT Id FROM [Common].[ModuleMaster]  WHERE COMPANYID=@UNIQUE_COMPANY_ID AND NAME='Tax Cursor')
--  INSERT INTO [Common].[ControlCodeCategoryModule] (Id, CompanyId, ControlCategoryId, ModuleMasterId) VALUES ((SELECT MAX(Id) + 1 FROM [Common].[ControlCodeCategoryModule]),
--  @NEW_COMPANY_ID,@CONTROLCODECATEGORY_ID_MODULE_MASTER_ID,@MODULE_MASTER_ID_CONTROLCODECATEGORY_ID);
--  END
--    ---------------------------------------AccountClass For Tax----------------------

--Declare @ControlCodeCategoryModule_AccountClass_Cnt bigint
-- select @ControlCodeCategoryModule_AccountClass_Cnt=Count(*) from [Common].[ControlCodeCategoryModule] where companyid=@NEW_COMPANY_ID 
--and controlcategoryId in(SELECT  ID FROM [Common].[ControlCodeCategory] WHERE COMPANYID=@NEW_COMPANY_ID AND CONTROLCODECATEGORYCODE='Account Class') 
-- IF @ControlCodeCategoryModule_AccountClass_Cnt=0
-- Begin


--  SET @CONTROLCODECATEGORY_ID_MODULE_MASTER_ID = (SELECT top 1 ID FROM [Common].[ControlCodeCategory] WHERE COMPANYID=@NEW_COMPANY_ID AND CONTROLCODECATEGORYCODE='Account Class')
--  SET @MODULE_MASTER_ID_CONTROLCODECATEGORY_ID = (SELECT Id FROM [Common].[ModuleMaster]  WHERE COMPANYID=@UNIQUE_COMPANY_ID AND NAME='Tax Cursor')
--  INSERT INTO [Common].[ControlCodeCategoryModule] (Id, CompanyId, ControlCategoryId, ModuleMasterId) VALUES ((SELECT MAX(Id) + 1 FROM [Common].[ControlCodeCategoryModule]),
--  @NEW_COMPANY_ID,@CONTROLCODECATEGORY_ID_MODULE_MASTER_ID,@MODULE_MASTER_ID_CONTROLCODECATEGORY_ID);

--  END
    
--	----------------------------- Classification Type ------------------------------

-- Declare @ControlCodeCategoryModule_Classificationtype_Cnt bigint
-- select @ControlCodeCategoryModule_Classificationtype_Cnt=Count(*) from [Common].[ControlCodeCategoryModule] where companyid=@NEW_COMPANY_ID 
--and controlcategoryId in(SELECT ID FROM [Common].[ControlCodeCategory] WHERE COMPANYID=@NEW_COMPANY_ID AND CONTROLCODECATEGORYCODE='Classification type') 
-- IF @ControlCodeCategoryModule_Classificationtype_Cnt=0
-- Begin

--SET @CONTROLCODECATEGORY_ID_MODULE_MASTER_ID = (SELECT top 1 ID FROM [Common].[ControlCodeCategory] WHERE COMPANYID=@NEW_COMPANY_ID AND CONTROLCODECATEGORYCODE='Classification type')
--  SET @MODULE_MASTER_ID_CONTROLCODECATEGORY_ID = (SELECT Id FROM [Common].[ModuleMaster]  WHERE COMPANYID=@UNIQUE_COMPANY_ID AND NAME='Tax Cursor')
--  INSERT INTO [Common].[ControlCodeCategoryModule] (Id, CompanyId, ControlCategoryId, ModuleMasterId) VALUES ((SELECT MAX(Id) + 1 FROM [Common].[ControlCodeCategoryModule]),
--  @NEW_COMPANY_ID,@CONTROLCODECATEGORY_ID_MODULE_MASTER_ID,@MODULE_MASTER_ID_CONTROLCODECATEGORY_ID);

--  END
  
--  Declare @ControlCodeCategoryModule_TypeOfEntity_Cnt bigint
-- select @ControlCodeCategoryModule_TypeOfEntity_Cnt=Count(*) from [Common].[ControlCodeCategoryModule] where companyid=@NEW_COMPANY_ID 
--and controlcategoryId in(SELECT  ID FROM [Common].[ControlCodeCategory] WHERE COMPANYID=@NEW_COMPANY_ID AND CONTROLCODECATEGORYCODE='TypeOfEntity') 
-- IF @ControlCodeCategoryModule_TypeOfEntity_Cnt=0
-- Begin

--	  SET @CONTROLCODECATEGORY_ID_MODULE_MASTER_ID = (SELECT top 1 ID FROM [Common].[ControlCodeCategory] WHERE COMPANYID=@NEW_COMPANY_ID AND CONTROLCODECATEGORYCODE='TypeOfEntity')
--  SET @MODULE_MASTER_ID_CONTROLCODECATEGORY_ID = (SELECT Id FROM [Common].[ModuleMaster]  WHERE COMPANYID=@UNIQUE_COMPANY_ID AND NAME='Tax Cursor')
--  INSERT INTO [Common].[ControlCodeCategoryModule] (Id, CompanyId, ControlCategoryId, ModuleMasterId) VALUES ((SELECT MAX(Id) + 1 FROM [Common].[ControlCodeCategoryModule]),
--  @NEW_COMPANY_ID,@CONTROLCODECATEGORY_ID_MODULE_MASTER_ID,@MODULE_MASTER_ID_CONTROLCODECATEGORY_ID);
--  END
--    ------------------------------------------------TaxPrimaryRole--------------------------------------------------
-- Declare @ControlCodeCategoryModule_TaxPrimaryRole_Cnt bigint
-- select @ControlCodeCategoryModule_TaxPrimaryRole_Cnt=Count(*) from [Common].[ControlCodeCategoryModule] where companyid=@NEW_COMPANY_ID 
--and controlcategoryId in(SELECT  ID FROM [Common].[ControlCodeCategory] WHERE COMPANYID=@NEW_COMPANY_ID AND CONTROLCODECATEGORYCODE='TaxPrimaryRole') 
-- IF @ControlCodeCategoryModule_TaxPrimaryRole_Cnt=0
-- Begin

--     SET @CONTROLCODECATEGORY_ID_MODULE_MASTER_ID = (SELECT top 1 ID FROM [Common].[ControlCodeCategory] WHERE COMPANYID=@NEW_COMPANY_ID AND CONTROLCODECATEGORYCODE='TaxPrimaryRole')
--  SET @MODULE_MASTER_ID_CONTROLCODECATEGORY_ID = (SELECT Id FROM [Common].[ModuleMaster]  WHERE COMPANYID=@UNIQUE_COMPANY_ID AND NAME='Tax Cursor')
--  INSERT INTO [Common].[ControlCodeCategoryModule] (Id, CompanyId, ControlCategoryId, ModuleMasterId) VALUES ((SELECT MAX(Id) + 1 FROM [Common].[ControlCodeCategoryModule]),
--  @NEW_COMPANY_ID,@CONTROLCODECATEGORY_ID_MODULE_MASTER_ID,@MODULE_MASTER_ID_CONTROLCODECATEGORY_ID);
--  END
--   -------------------------------16-11-2017----Type of Claim-----------------------------------------------
--    Declare @ControlCodeCategoryModule_TypeOfClaim_Cnt bigint
-- select @ControlCodeCategoryModule_TypeOfClaim_Cnt=Count(*) from [Common].[ControlCodeCategoryModule] where companyid=@NEW_COMPANY_ID 
--and controlcategoryId in(SELECT  ID FROM [Common].[ControlCodeCategory] WHERE COMPANYID=@NEW_COMPANY_ID AND CONTROLCODECATEGORYCODE='Type of Claim') 
-- IF @ControlCodeCategoryModule_TypeOfClaim_Cnt=0
-- Begin
 
-- SET @CONTROLCODECATEGORY_ID_MODULE_MASTER_ID = (SELECT top 1 ID FROM [Common].[ControlCodeCategory] WHERE COMPANYID=@NEW_COMPANY_ID AND CONTROLCODECATEGORYCODE='Type of Claim')
--  SET @MODULE_MASTER_ID_CONTROLCODECATEGORY_ID = (SELECT Id FROM [Common].[ModuleMaster]  WHERE COMPANYID=@UNIQUE_COMPANY_ID AND NAME='Tax Cursor')
--  INSERT INTO [Common].[ControlCodeCategoryModule] (Id, CompanyId, ControlCategoryId, ModuleMasterId) VALUES ((SELECT MAX(Id) + 1 FROM [Common].[ControlCodeCategoryModule]),
--  @NEW_COMPANY_ID,@CONTROLCODECATEGORY_ID_MODULE_MASTER_ID,@MODULE_MASTER_ID_CONTROLCODECATEGORY_ID);

--  END
--    -------------------------------16-11-2017----Asset Classification-----------------------------------------------
--    Declare @ControlCodeCategoryModule_AssetClassification_Cnt bigint
-- select  @ControlCodeCategoryModule_AssetClassification_Cnt=Count(*) from [Common].[ControlCodeCategoryModule] where companyid=@NEW_COMPANY_ID 
--and controlcategoryId in(SELECT  ID FROM [Common].[ControlCodeCategory] WHERE COMPANYID=@NEW_COMPANY_ID AND CONTROLCODECATEGORYCODE='Asset Classification') 
-- IF  @ControlCodeCategoryModule_AssetClassification_Cnt=0
-- Begin
 
-- SET @CONTROLCODECATEGORY_ID_MODULE_MASTER_ID = (SELECT top 1 ID FROM [Common].[ControlCodeCategory] WHERE COMPANYID=@NEW_COMPANY_ID AND CONTROLCODECATEGORYCODE='Asset Classification')
--  SET @MODULE_MASTER_ID_CONTROLCODECATEGORY_ID = (SELECT Id FROM [Common].[ModuleMaster]  WHERE COMPANYID=@UNIQUE_COMPANY_ID AND NAME='Tax Cursor')
--  INSERT INTO [Common].[ControlCodeCategoryModule] (Id, CompanyId, ControlCategoryId, ModuleMasterId) VALUES ((SELECT MAX(Id) + 1 FROM [Common].[ControlCodeCategoryModule]),
--  @NEW_COMPANY_ID,@CONTROLCODECATEGORY_ID_MODULE_MASTER_ID,@MODULE_MASTER_ID_CONTROLCODECATEGORY_ID);
--  END
--    -------------------------------Appendix

--	    Declare @ControlCodeCategoryModule_Appendix_Cnt bigint
-- select @ControlCodeCategoryModule_Appendix_Cnt=Count(*) from [Common].[ControlCodeCategoryModule] where companyid=@NEW_COMPANY_ID 
--and controlcategoryId in(SELECT  ID FROM [Common].[ControlCodeCategory] WHERE COMPANYID=@NEW_COMPANY_ID AND CONTROLCODECATEGORYCODE='Appendix') 
-- IF  @ControlCodeCategoryModule_Appendix_Cnt=0
-- Begin

-- SET @CONTROLCODECATEGORY_ID_MODULE_MASTER_ID = (SELECT top 1 ID FROM [Common].[ControlCodeCategory] WHERE COMPANYID=@NEW_COMPANY_ID AND CONTROLCODECATEGORYCODE='Appendix')
--  SET @MODULE_MASTER_ID_CONTROLCODECATEGORY_ID = (SELECT Id FROM [Common].[ModuleMaster]  WHERE COMPANYID=@UNIQUE_COMPANY_ID AND NAME='Tax Cursor')
--  INSERT INTO [Common].[ControlCodeCategoryModule] (Id, CompanyId, ControlCategoryId, ModuleMasterId) VALUES ((SELECT MAX(Id) + 1 FROM [Common].[ControlCodeCategoryModule]), @NEW_COMPANY_ID,@CONTROLCODECATEGORY_ID_MODULE_MASTER_ID,@MODULE_MASTER_ID_CONTROLCODECATEGORY_ID);
-- END
-- ----------------------------------------Appendix-1-Medical Exp

--     Declare @ControlCodeCategoryModule_Appendix1MedicalExp_Cnt bigint
-- select @ControlCodeCategoryModule_Appendix1MedicalExp_Cnt=Count(*) from [Common].[ControlCodeCategoryModule] where companyid=@NEW_COMPANY_ID 
--and controlcategoryId in(SELECT  ID FROM [Common].[ControlCodeCategory] WHERE COMPANYID=@NEW_COMPANY_ID AND CONTROLCODECATEGORYCODE='Appendix-1-Medical Exp') 
-- IF @ControlCodeCategoryModule_Appendix1MedicalExp_Cnt=0
-- Begin
--   SET @CONTROLCODECATEGORY_ID_MODULE_MASTER_ID = (SELECT top 1 ID FROM [Common].[ControlCodeCategory] WHERE COMPANYID=@NEW_COMPANY_ID AND CONTROLCODECATEGORYCODE='Appendix-1-Medical Exp')
--  SET @MODULE_MASTER_ID_CONTROLCODECATEGORY_ID = (SELECT Id FROM [Common].[ModuleMaster]  WHERE COMPANYID=@UNIQUE_COMPANY_ID AND NAME='Tax Cursor')
--  INSERT INTO [Common].[ControlCodeCategoryModule] (Id, CompanyId, ControlCategoryId, ModuleMasterId) VALUES ((SELECT MAX(Id) + 1 FROM [Common].[ControlCodeCategoryModule]), @NEW_COMPANY_ID,@CONTROLCODECATEGORY_ID_MODULE_MASTER_ID,@MODULE_MASTER_ID_CONTROLCODECATEGORY_ID);

--  END
--  ---------------------SP-------------------Appendix-9-PIC Summary

  
--     Declare @ControlCodeCategoryModule_Appendix_9_PICSummary_Cnt bigint
-- select @ControlCodeCategoryModule_Appendix_9_PICSummary_Cnt=Count(*) from [Common].[ControlCodeCategoryModule] where companyid=@NEW_COMPANY_ID 
--and controlcategoryId in(SELECT  ID FROM [Common].[ControlCodeCategory] WHERE COMPANYID=@NEW_COMPANY_ID AND CONTROLCODECATEGORYCODE='Appendix-9-PIC Summary') 
-- IF @ControlCodeCategoryModule_Appendix_9_PICSummary_Cnt=0
-- Begin
--	SET @CONTROLCODECATEGORY_ID_MODULE_MASTER_ID = (SELECT top 1 ID FROM [Common].[ControlCodeCategory] WHERE COMPANYID=@NEW_COMPANY_ID AND CONTROLCODECATEGORYCODE='Appendix-9-PIC Summary')
--	SET @MODULE_MASTER_ID_CONTROLCODECATEGORY_ID = (SELECT Id FROM [Common].[ModuleMaster]  WHERE COMPANYID=@UNIQUE_COMPANY_ID AND NAME='Tax Cursor')
--	INSERT INTO [Common].[ControlCodeCategoryModule] (Id, CompanyId, ControlCategoryId, ModuleMasterId) VALUES ((SELECT MAX(Id) + 1 FROM [Common].[ControlCodeCategoryModule]), @NEW_COMPANY_ID,@CONTROLCODECATEGORY_ID_MODULE_MASTER_ID,@MODULE_MASTER_ID_CONTROLCODECATEGORY_ID);

--	END
--	---------------------SP-------------------Appendix-2-Interest Restriction
-- Declare @ControlCodeCategoryModule_Appendix_2_InterestRestriction_Cnt bigint
-- select @ControlCodeCategoryModule_Appendix_2_InterestRestriction_Cnt =Count(*) from [Common].[ControlCodeCategoryModule] where companyid=@NEW_COMPANY_ID 
--and controlcategoryId in(SELECT  ID FROM [Common].[ControlCodeCategory] WHERE COMPANYID=@NEW_COMPANY_ID AND CONTROLCODECATEGORYCODE='Appendix-2-Interest Restriction') 
-- IF @ControlCodeCategoryModule_Appendix_2_InterestRestriction_Cnt =0
-- Begin

--	SET @CONTROLCODECATEGORY_ID_MODULE_MASTER_ID = (SELECT top 1 ID FROM [Common].[ControlCodeCategory] WHERE COMPANYID=@NEW_COMPANY_ID AND CONTROLCODECATEGORYCODE='Appendix-2-Interest Restriction')
--	SET @MODULE_MASTER_ID_CONTROLCODECATEGORY_ID = (SELECT Id FROM [Common].[ModuleMaster]  WHERE COMPANYID=@UNIQUE_COMPANY_ID AND NAME='Tax Cursor')
--	INSERT INTO [Common].[ControlCodeCategoryModule] (Id, CompanyId, ControlCategoryId, ModuleMasterId) VALUES ((SELECT MAX(Id) + 1 FROM [Common].[ControlCodeCategoryModule]), @NEW_COMPANY_ID,@CONTROLCODECATEGORY_ID_MODULE_MASTER_ID,@MODULE_MASTER_ID_CONTROLCODECATEGORY_ID);
--	END
--	---statement A--
--		   Declare @ControlCodeCategoryModule_StatementA_Cnt bigint
-- select  @ControlCodeCategoryModule_StatementA_Cnt =Count(*) from [Common].[ControlCodeCategoryModule] where companyid=@NEW_COMPANY_ID 
--and controlcategoryId in(SELECT  ID FROM [Common].[ControlCodeCategory] WHERE COMPANYID=@NEW_COMPANY_ID AND CONTROLCODECATEGORYCODE='StatementA') 
-- IF  @ControlCodeCategoryModule_StatementA_Cnt =0
-- Begin

--	SET @CONTROLCODECATEGORY_ID_MODULE_MASTER_ID = (SELECT top 1 ID FROM [Common].[ControlCodeCategory] WHERE COMPANYID=@NEW_COMPANY_ID AND CONTROLCODECATEGORYCODE='StatementA')
--	SET @MODULE_MASTER_ID_CONTROLCODECATEGORY_ID = (SELECT Id FROM [Common].[ModuleMaster]  WHERE COMPANYID=@UNIQUE_COMPANY_ID AND NAME='Tax Cursor')
--	INSERT INTO [Common].[ControlCodeCategoryModule] (Id, CompanyId, ControlCategoryId, ModuleMasterId) VALUES ((SELECT MAX(Id) + 1 FROM [Common].[ControlCodeCategoryModule]), @NEW_COMPANY_ID,@CONTROLCODECATEGORY_ID_MODULE_MASTER_ID,@MODULE_MASTER_ID_CONTROLCODECATEGORY_ID);
--	END


Exec [dbo].[ControlCodeCategoryModule_SP_New] @NEW_COMPANY_ID,7



	--tax seed data

	
--[Tax].[Classification]

   Declare @Classification_Cnt bigint;
   select @Classification_Cnt=Count (*) from 	[Tax].[Classification] where companyid=@NEW_COMPANY_ID	
   IF @Classification_Cnt=0
  -- Begin

	BEGIN
	   IF NOT EXISTS (SELECT * FROM [Tax].[Classification] WHERE  [CompanyId] = @NEW_COMPANY_ID)
   BEGIN   
 INSERT INTO  [Tax].[Classification] (Id, CompanyId, WorkProgramId, [Index], ClassificationType, AccountClass, IsSystem, ClassificationName, FinancialStatementTemplate, Remarks, RecOrder, UserCreated, CreatedDate, ModifiedBy, ModifiedDate, Version, Status ,Disclosure)
       SELECT NEWID(),@NEW_COMPANY_ID,null,[Index], ClassificationType, AccountClass, IsSystem, ClassificationName, FinancialStatementTemplate, Remarks, RecOrder, UserCreated, CreatedDate, null, null, Version, Status ,Disclosure FROM [Tax].[Classification] WHERE COMPANYID=@UNIQUE_COMPANY_ID	     
   
   END
END;

  ---[Tax].[ClassificationCategories]-----

 Insert Into [Tax].[ClassificationCategories]
  ([Id],[ClassificationId],[Name],[RecOrder],[Status])
  SELECT newid() as Id
,(select ID FROM [Tax].[Classification] where CompanyId = @NEW_COMPANY_ID and ClassificationName = (select ClassificationName FROM  [Tax].[Classification] where Id = 
 cat.[ClassificationId] and CompanyId = @UNIQUE_COMPANY_ID))   as [LeadsheetID]
	  ,cat.[Name]	 
	  ,@NEW_COMPANY_ID
	  ,cat.[Status]
  FROM [Tax].[ClassificationCategories] cat inner join [Tax].[Classification] ld
  on ld.Id = cat.ClassificationId 
  where ld.CompanyId = @UNIQUE_COMPANY_ID

----------====================== Template ==================================

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



--    -----------------------SP--------------------Appendix-5 Rental Income

--SET @CONTROLCODECATEGORY_ID_MODULE_MASTER_ID = (SELECT top 1 ID FROM [Common].[ControlCodeCategory] WHERE COMPANYID=@NEW_COMPANY_ID AND CONTROLCODECATEGORYCODE='Appendix-5 Rental Income')
--SET @MODULE_MASTER_ID_CONTROLCODECATEGORY_ID = (SELECT Id FROM [Common].[ModuleMaster]  WHERE COMPANYID=@UNIQUE_COMPANY_ID AND NAME='Tax Cursor')
--INSERT INTO [Common].[ControlCodeCategoryModule] (Id, CompanyId, ControlCategoryId, ModuleMasterId) VALUES ((SELECT MAX(Id) + 1 FROM [Common].[ControlCodeCategoryModule]), @NEW_COMPANY_ID,@CONTROLCODECATEGORY_ID_MODULE_MASTER_ID,@MODULE_MASTER_ID_CONTROLCODECATEGORY_ID);

 -----------------------------PlannigAndCompletionSetUp-----------------------

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


	
 ---------------no need--------------------------ID TYPE------------------------------------
	DECLARE @IDTYPE_CNT INT;
	SELECT @IDTYPE_CNT=COUNT(*) FROM [COMMON].[IDTYPE] WHERE COMPANYID=@NEW_COMPANY_ID 
	IF @IDTYPE_CNT=0
	BEGIN
	
		UPDATE [Common].[IdType] SET[TempIdTypeId] = NULL;
		--ALTER TABLE [Common].[IdType] ADD [TempIdTypeId] BIGINT NULL;
		INSERT INTO [Common].[IdType] (Id, Name, CompanyId, RecOrder, Remarks, UserCreated, CreatedDate, ModifiedBy, ModifiedDate, Version, Status,TempIdTypeId) 
		SELECT ROW_NUMBER() OVER(ORDER BY ID) + (SELECT MAX(id) + 1 FROM [Common].[IdType]), Name, @NEW_COMPANY_ID, RecOrder, Remarks,
		UserCreated, @CREATED_DATE, null, null, Version, status, Id FROM [Common].[IdType] WHERE COMPANYID=@UNIQUE_COMPANY_ID	
	END

  	---------------ACCOUNT TYPE ----------------------
	Declare @AccountType_Cnt int;
	select @AccountType_Cnt=Count(*) from [Common].[AccountType] where companyid=@NEW_COMPANY_ID 
	IF @AccountType_Cnt=0
	Begin
	UPDATE [Common].[AccountType] SET [TempAccountTypeId] = NULL;
	INSERT INTO [Common].[AccountType] (Id, Name, CompanyId, RecOrder, Remarks, UserCreated, CreatedDate, ModifiedBy, ModifiedDate, Version, Status,TempAccountTypeId)
	SELECT ROW_NUMBER() OVER(ORDER BY ID) + (SELECT MAX(Id) + 1 FROM [Common].[AccountType]), Name, @NEW_COMPANY_ID, RecOrder, Remarks, UserCreated,
	@CREATED_DATE, null, null, Version, status,Id FROM [Common].[AccountType]  WHERE COMPANYID=@UNIQUE_COMPANY_ID;
	--Added by Nagendra 

	INSERT INTO  [Common].[AccountTypeIdType] (Id, AccountTypeId, IdTypeId, RecOrder)		
		SELECT ROW_NUMBER() OVER(ORDER BY A.ID) + (SELECT MAX(ID) + 1 FROM [Common].[AccountTypeIdType]) ,B.Id AS ACCOUNTTYPEID,C.Id AS IDTYPEID,
		A.RecOrder FROM [Common].[AccountTypeIdType] A JOIN [Common].[AccountType] B ON A.AccountTypeId = B.TempAccountTypeId JOIN [Common].[IdType] C 
		ON C.TempIdTypeId = A.IdTypeId	WHERE B.CompanyId=@NEW_COMPANY_ID AND C.CompanyId=@NEW_COMPANY_ID;
  
	End


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
		INSERT INTO Tax.PlanningAndCompletionSetUp
		SELECT @PAC_NEWID,@NEW_COMPANY_ID,TaxCompanyId,EngagementId,ModuleDetailId,Type,MenuCode,MenuName,Description,FormType,Remarks,UserCreated,GETDATE(),NULL,NULL,Status,Recorder,EngagementType,Conclusion,IsMigrated,ConclusionLable
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
			SELECT @SEC_NEWID,@PAC_NEWID,Heading,DESCRIPTION,CommentLable,[CommentDescription],Remarks,UserCreated,GETDATE(),NULL,NULL,Status,Recorder
			FROM Tax.PAndCSections WHERE ID=@SEC_ID --AND PlanningAndCompletionSetUpId=@SEC_PAC_ID AND Heading=@SECTION AND DESCRIPTION=@DESCRIPTION

			INSERT INTO Tax.PAndCSectionQuestions
			SELECT NEWID(),@SEC_NEWID,Question,QuestionOptions,Answer,IsComment,Comment,IsAttachement,AttachmentsCount,Remarks,UserCreated,GETDATE(),NULL,NULL,Status,Recorder,AttachmentName
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


------added for super admin level foreign exchange--26th Jun---
------for Foreign Exchange  seed data at super user level to insert into patner level company's
 --[Tax].[MonthlyForeignExchange]

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


  -----------------------Added for [AccountPolicy] for partner level company------------------------
 
     SET @CompanyType = (select IsAccountingFirm from Common.Company  where  IsAccountingFirm=1 and  id=@NEW_COMPANY_ID)
	  DECLARE @AccountPolicy_Cnt bigint;
     select  @AccountPolicy_Cnt=Count (*) from  [Tax].[AccountPolicy] where companyid=@NEW_COMPANY_ID 
    IF  @AccountPolicy_Cnt=0
      BEGIN
    IF NOT EXISTS (SELECT * FROM [Tax].[AccountPolicy] WHERE  [CompanyId] = @NEW_COMPANY_ID)
    if(@CompanyType=1)
	  BEGIN
	   insert into [Tax].[AccountPolicy](Id,CompanyId,EngagementId,PolicyName,PolicyTemplate,IsChecked,IsSytem,Remarks,RecOrder,UserCreated,CreatedDate,ModifiedBy,ModifiedDate,Version,Status,Section)
       select NEWID(),@NEW_COMPANY_ID,null,PolicyName,PolicyTemplate,IsChecked,IsSytem,Remarks,RecOrder,null,GETUTCDate(),null,null,Version,Status,Section from [Tax].[AccountPolicy] where CompanyId=0
		END
        END





 ------Recently Added---june 14th--
 
         ------------AuditPrimaryRole
Declare @ControlCodeCategoryModuleAuditPrimaryRole_Cnt bigint
 select @ControlCodeCategoryModuleAuditPrimaryRole_Cnt=Count(*) from [Common].[ControlCodeCategoryModule] where companyid=@NEW_COMPANY_ID 
and controlcategoryId in(SELECT  ID FROM [Common].[ControlCodeCategory] WHERE COMPANYID=@NEW_COMPANY_ID AND CONTROLCODECATEGORYCODE='AuditPrimaryRole') 
         
 IF @ControlCodeCategoryModuleAuditPrimaryRole_Cnt=0
 Begin
      SET @CONTROLCODECATEGORY_ID_MODULE_MASTER_ID = (SELECT top 1 ID FROM [Common].[ControlCodeCategory] WHERE COMPANYID=@NEW_COMPANY_ID AND CONTROLCODECATEGORYCODE='AuditPrimaryRole')
  SET @MODULE_MASTER_ID_CONTROLCODECATEGORY_ID = (SELECT Id FROM [Common].[ModuleMaster]  WHERE COMPANYID=@UNIQUE_COMPANY_ID AND NAME='Tax Cursor')
  INSERT INTO [Common].[ControlCodeCategoryModule] (Id, CompanyId, ControlCategoryId, ModuleMasterId) VALUES ((SELECT MAX(Id) + 1 FROM [Common].[ControlCodeCategoryModule]),
  @NEW_COMPANY_ID,@CONTROLCODECATEGORY_ID_MODULE_MASTER_ID,@MODULE_MASTER_ID_CONTROLCODECATEGORY_ID);
  end




  	--end
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

		BEGIN
			COMMIT TRANSACTION
		END


	
END
GO
