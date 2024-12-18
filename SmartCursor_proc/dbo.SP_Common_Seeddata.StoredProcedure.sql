USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[SP_Common_Seeddata]    Script Date: 16-12-2024 9.20.11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[SP_Common_Seeddata](@UNIQUE_COMPANY_ID BIGINT,@NEW_COMPANY_ID BIGINT)
AS
BEGIN

    DECLARE @CREATED_DATE DATETIME	 
    DECLARE @CONTROLCODECATEGORY_ID_MODULE_MASTER_ID BIGINT
	DECLARE @MODULE_MASTER_ID_CONTROLCODECATEGORY_ID BIGINT
	DECLARE @ACCOUNTYPE_ID_ID_TYPE_ID BIGINT
	DECLARE @ID_TYPE_ACCOUNTYPE_ID_ID BIGINT
	Declare @CompanyFeatures_Cnt int
		Declare @CompanyType Bit   --1:Parner,2:Parent,3:Subsidiary  

	Declare @AuditModule int = 3
	Declare @TaxModule int = 7
	Declare @BRModule int = 9
	Set @CREATED_DATE = GETUTCDATE()
	Select @CompanyType=IsAccountingFirm from Common.Company  where  IsAccountingFirm=1 and  id=@NEW_COMPANY_ID
	select 	@CompanyFeatures_Cnt=Count(*) from common.CompanyFeatures where companyid=@NEW_COMPANY_ID	
	IF @CompanyFeatures_Cnt=0
	Begin
INSERT INTO common.CompanyFeatures( Id, CompanyId, FeatureId, Status,  Remarks,IsChecked)
		select  NEWID(),@NEW_COMPANY_ID,b.FeatureId,b.Status,b.Remarks,b.IsChecked from [Common].[Feature] a join [Common].[CompanyFeatures] b on a.Id=b.FeatureId where a.VisibleStyle <> 'SuperUser-CheckBox' and a.VisibleStyle <> 'HRCursor-CheckBox' and CompanyId=0
 End

END;

Declare @ControlCodeCategory_cnt bigint
select @ControlCodeCategory_cnt=count(*) from [Common].[ControlCodeCategory] where companyid=@NEW_COMPANY_ID
IF @ControlCodeCategory_cnt=0
Begin
DECLARE @CONTROL_ID BIGINT,@NEW_CONTROL_ID BIGINT
		DECLARE CONTROL_CURSOR CURSOR FOR 
		SELECT  Id FROM [Common].[ControlCodeCategory] where companyid=0 
		OPEN CONTROL_CURSOR
		FETCH NEXT FROM CONTROL_CURSOR INTO @CONTROL_ID
		WHILE @@FETCH_STATUS=0
		BEGIN   
			SET @NEW_CONTROL_ID = (SELECT MAX(ID) +1 FROM [Common].[ControlCodeCategory])
			INSERT INTO [Common].[ControlCodeCategory] (Id, CompanyId, ControlCodeCategoryCode, ControlCodeCategoryDescription, DataType,
			Format, RecOrder, Remarks, UserCreated, CreatedDate, ModifiedBy, ModifiedDate, Version, Status, ModuleNamesUsing, DefaultValue)
			SELECT @NEW_CONTROL_ID, @NEW_COMPANY_ID, ControlCodeCategoryCode, ControlCodeCategoryDescription, DataType, Format, RecOrder, Remarks, UserCreated,
				GETUTCDATE(), null, null, Version, status, ModuleNamesUsing, DefaultValue FROM [Common].[ControlCodeCategory] WHERE ID=@CONTROL_ID 
			INSERT INTO [Common].[ControlCode] (Id, ControlCategoryId, CodeKey, CodeValue, IsSystem, RecOrder, Remarks, UserCreated, CreatedDate, 
				ModifiedBy, ModifiedDate, Version, Status, IsDefault)
			SELECT ROW_NUMBER() OVER(ORDER BY a.ID) + (SELECT MAX(Id) + 1 FROM [Common].[ControlCode]) AS Id,@NEW_CONTROL_ID, a.CodeKey, a.CodeValue,
				a.IsSystem, a.RecOrder, a.Remarks, a.UserCreated, GETUTCDATE(), null,null, a.Version, a.Status, a.IsDefault 
				from  [Common].[ControlCode] a join [Common].[ControlCodeCategory] b on a.controlcategoryid=b.id where b.companyid=0 
				and a.controlcategoryid=@CONTROL_ID
							  			
			FETCH NEXT FROM CONTROL_CURSOR INTO @CONTROL_ID      
		END	
		End
------SP For CompanyModuleSetUp---

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

Declare @Localization_Cnt int
select 	@Localization_Cnt=Count(*) from [Common].[Localization] where companyid=@NEW_COMPANY_ID	
	IF @Localization_Cnt=0
	Begin
INSERT INTO [Common].[Localization] (Id, CompanyId, LongDateFormat, ShortDateFormat, TimeFormat, BaseCurrency, BusinessYearEnd, Status,
			UserCreated, CreatedDate, ModifiedBy, ModifiedDate, TimeZone)
			SELECT (SELECT MAX(id) +1  FROM [Common].[Localization]), @NEW_COMPANY_ID, LongDateFormat, ShortDateFormat,
			TimeFormat, BaseCurrency, BusinessYearEnd, status, UserCreated, @CREATED_DATE, null, null, TimeZone FROM [Common].[Localization]
			WHERE COMPANYID=@UNIQUE_COMPANY_ID;
			End

			--	Declare @InitialCursorSetup_Cnt int
			--select 	@InitialCursorSetup_Cnt=Count(*) from [Common].[InitialCursorSetup] where companyid=@NEW_COMPANY_ID	
			--IF @InitialCursorSetup_Cnt=0
			--Begin
			--	INSERT INTO [Common].[InitialCursorSetup] ([Id], [CompanyId], [ModuleId], [ModuleDetailId], [IsSetUpDone],[MainModuleId],[Status],[MasterModuleId],[IsCommonModule])		
			--	SELECT ROW_NUMBER() OVER(ORDER BY ID) + (SELECT MAX(ID)  FROM [Common].[InitialCursorSetup]), @NEW_COMPANY_ID, [ModuleId], [ModuleDetailId], [IsSetUpDone],[MainModuleId],[Status],[MasterModuleId],[IsCommonModule] 
			--	FROM [Common].[InitialCursorSetup] 
			--	WHERE CompanyId=@UNIQUE_COMPANY_ID and MasterModuleId in 
			--	(SELECT moduleid FROM common.companyModule WHERE companyid=@NEW_COMPANY_ID AND status=1)
			--	And MasterModuleId not in (@AuditModule, @TaxModule,@BRModule);
			--	IF(@CompanyType=1)
			--	BEGIN
			--		INSERT INTO [Common].[InitialCursorSetup] ([Id], [CompanyId], [ModuleId], [ModuleDetailId], [IsSetUpDone],[MainModuleId],[Status],[MasterModuleId],[IsCommonModule])		
			--		SELECT ROW_NUMBER() OVER(ORDER BY ID) + (SELECT MAX(ID)  FROM [Common].[InitialCursorSetup]), @NEW_COMPANY_ID, [ModuleId], [ModuleDetailId], [IsSetUpDone],[MainModuleId],[Status],[MasterModuleId],[IsCommonModule] 
			--		FROM [Common].[InitialCursorSetup] 
			--		WHERE CompanyId=@UNIQUE_COMPANY_ID and MasterModuleId in 
			--		(SELECT moduleid FROM common.companyModule WHERE companyid=@NEW_COMPANY_ID AND status=1)
			--		And MasterModuleId in (@AuditModule, @TaxModule,@BRModule);
			--	END
			--End

			
       --Fee Type
--       Declare @ControlCodeCategoryModule_FeeType_Cnt bigint
--	   Select @ControlCodeCategoryModule_FeeType_Cnt =count(*) from [Common].[ControlCodeCategoryModule] WHERE COMPANYID=@NEW_COMPANY_ID
--	   AND controlcategoryId  in (SELECT  ID FROM [Common].[ControlCodeCategory] WHERE COMPANYID=@NEW_COMPANY_ID AND CONTROLCODECATEGORYCODE='Fee Type')
--	   If @ControlCodeCategoryModule_FeeType_Cnt =0
--		Begin
--		SET @CONTROLCODECATEGORY_ID_MODULE_MASTER_ID = (SELECT top 1 ID FROM [Common].[ControlCodeCategory] WHERE COMPANYID=@NEW_COMPANY_ID AND CONTROLCODECATEGORYCODE='Fee Type')
--		SET @MODULE_MASTER_ID_CONTROLCODECATEGORY_ID = (SELECT Id FROM [Common].[ModuleMaster]  WHERE COMPANYID=@UNIQUE_COMPANY_ID AND NAME='Admin Cursor')
--		INSERT INTO [Common].[ControlCodeCategoryModule] (Id, CompanyId, ControlCategoryId, ModuleMasterId) VALUES ((SELECT MAX(Id) + 1 FROM [Common].[ControlCodeCategoryModule]),
--		@NEW_COMPANY_ID,@CONTROLCODECATEGORY_ID_MODULE_MASTER_ID,@MODULE_MASTER_ID_CONTROLCODECATEGORY_ID);
--		End

--		--CommunicationType
--		 Declare @ControlCodeCategoryModule_CommunicationType_Cnt bigint
--	   Select @ControlCodeCategoryModule_CommunicationType_Cnt =count(*) from [Common].[ControlCodeCategoryModule] WHERE COMPANYID=@NEW_COMPANY_ID
--	   AND controlcategoryId  in (SELECT  ID FROM [Common].[ControlCodeCategory] WHERE COMPANYID=@NEW_COMPANY_ID AND CONTROLCODECATEGORYCODE='CommunicationType')
--	   If @ControlCodeCategoryModule_CommunicationType_Cnt =0
--		Begin
--		SET @CONTROLCODECATEGORY_ID_MODULE_MASTER_ID = (SELECT top 1 ID FROM [Common].[ControlCodeCategory] WHERE COMPANYID=@NEW_COMPANY_ID AND CONTROLCODECATEGORYCODE='CommunicationType')
--		SET @MODULE_MASTER_ID_CONTROLCODECATEGORY_ID = (SELECT Id FROM [Common].[ModuleMaster]  WHERE COMPANYID=@UNIQUE_COMPANY_ID AND NAME='Admin Cursor')
--		INSERT INTO [Common].[ControlCodeCategoryModule] (Id, CompanyId, ControlCategoryId, ModuleMasterId) VALUES ((SELECT MAX(Id) + 1 FROM [Common].[ControlCodeCategoryModule]),
--		@NEW_COMPANY_ID,@CONTROLCODECATEGORY_ID_MODULE_MASTER_ID,@MODULE_MASTER_ID_CONTROLCODECATEGORY_ID);
--		End

--		--Short date Format
--		 Declare @ControlCodeCategoryModule_ShortdateFormat_Cnt bigint
--	     Select @ControlCodeCategoryModule_ShortdateFormat_Cnt =count(*) from [Common].[ControlCodeCategoryModule] WHERE COMPANYID=@NEW_COMPANY_ID
--	     AND controlcategoryId  in (SELECT  ID FROM [Common].[ControlCodeCategory] WHERE COMPANYID=@NEW_COMPANY_ID AND CONTROLCODECATEGORYCODE='Short date Format')
--	     If @ControlCodeCategoryModule_ShortdateFormat_Cnt =0
--		Begin
--		SET @CONTROLCODECATEGORY_ID_MODULE_MASTER_ID = (SELECT top 1 ID FROM [Common].[ControlCodeCategory] WHERE COMPANYID=@NEW_COMPANY_ID AND CONTROLCODECATEGORYCODE='Short date Format')
--		SET @MODULE_MASTER_ID_CONTROLCODECATEGORY_ID = (SELECT Id FROM [Common].[ModuleMaster]  WHERE COMPANYID=@UNIQUE_COMPANY_ID AND NAME='Admin Cursor')
--		INSERT INTO [Common].[ControlCodeCategoryModule] (Id, CompanyId, ControlCategoryId, ModuleMasterId) VALUES ((SELECT MAX(Id) + 1 FROM [Common].[ControlCodeCategoryModule]),
--		@NEW_COMPANY_ID,@CONTROLCODECATEGORY_ID_MODULE_MASTER_ID,@MODULE_MASTER_ID_CONTROLCODECATEGORY_ID);
--		End

--		--Time Format
--		 Declare @ControlCodeCategoryModule_TimeFormat_Cnt bigint
--	     Select @ControlCodeCategoryModule_TimeFormat_Cnt =count(*) from [Common].[ControlCodeCategoryModule] WHERE COMPANYID=@NEW_COMPANY_ID
--	     AND controlcategoryId  in (SELECT  ID FROM [Common].[ControlCodeCategory] WHERE COMPANYID=@NEW_COMPANY_ID AND CONTROLCODECATEGORYCODE='Time Format')
--	     If @ControlCodeCategoryModule_TimeFormat_Cnt =0
--		Begin
--			SET @CONTROLCODECATEGORY_ID_MODULE_MASTER_ID = (SELECT top 1 ID FROM [Common].[ControlCodeCategory] WHERE COMPANYID=@NEW_COMPANY_ID AND CONTROLCODECATEGORYCODE='Time Format')
--		SET @MODULE_MASTER_ID_CONTROLCODECATEGORY_ID = (SELECT Id FROM [Common].[ModuleMaster]  WHERE COMPANYID=@UNIQUE_COMPANY_ID AND NAME='Admin Cursor')
--		INSERT INTO [Common].[ControlCodeCategoryModule] (Id, CompanyId, ControlCategoryId, ModuleMasterId) VALUES ((SELECT MAX(Id) + 1 FROM [Common].[ControlCodeCategoryModule]),
--		@NEW_COMPANY_ID,@CONTROLCODECATEGORY_ID_MODULE_MASTER_ID,@MODULE_MASTER_ID_CONTROLCODECATEGORY_ID);
--		End

--		--Time Zone
--		 Declare @ControlCodeCategoryModule_TimeZone_Cnt bigint
--	     Select @ControlCodeCategoryModule_TimeZone_Cnt =count(*) from [Common].[ControlCodeCategoryModule] WHERE COMPANYID=@NEW_COMPANY_ID
--	     AND controlcategoryId  in (SELECT  ID FROM [Common].[ControlCodeCategory] WHERE COMPANYID=@NEW_COMPANY_ID AND CONTROLCODECATEGORYCODE='Time Zone')
--	     If @ControlCodeCategoryModule_TimeZone_Cnt =0
--		Begin
--		SET @CONTROLCODECATEGORY_ID_MODULE_MASTER_ID = (SELECT top 1 ID FROM [Common].[ControlCodeCategory] WHERE COMPANYID=@NEW_COMPANY_ID AND CONTROLCODECATEGORYCODE='Time Zone')
--		SET @MODULE_MASTER_ID_CONTROLCODECATEGORY_ID = (SELECT Id FROM [Common].[ModuleMaster]  WHERE COMPANYID=@UNIQUE_COMPANY_ID AND NAME='Admin Cursor')
--		INSERT INTO [Common].[ControlCodeCategoryModule] (Id, CompanyId, ControlCategoryId, ModuleMasterId) VALUES ((SELECT MAX(Id) + 1 FROM [Common].[ControlCodeCategoryModule]),
--		@NEW_COMPANY_ID,@CONTROLCODECATEGORY_ID_MODULE_MASTER_ID,@MODULE_MASTER_ID_CONTROLCODECATEGORY_ID);
--		End

--		--AutoNumber Type
--		 Declare @ControlCodeCategoryModule_AutoNumberType_Cnt bigint
--	     Select @ControlCodeCategoryModule_AutoNumberType_Cnt =count(*) from [Common].[ControlCodeCategoryModule] WHERE COMPANYID=@NEW_COMPANY_ID
--	     AND controlcategoryId  in (SELECT  ID FROM [Common].[ControlCodeCategory] WHERE COMPANYID=@NEW_COMPANY_ID AND CONTROLCODECATEGORYCODE='AutoNumber Type')
--	     If @ControlCodeCategoryModule_AutoNumberType_Cnt =0
--		Begin
--		SET @CONTROLCODECATEGORY_ID_MODULE_MASTER_ID = (SELECT top 1 ID FROM [Common].[ControlCodeCategory] WHERE COMPANYID=@NEW_COMPANY_ID AND CONTROLCODECATEGORYCODE='AutoNumber Type')
--		SET @MODULE_MASTER_ID_CONTROLCODECATEGORY_ID = (SELECT Id FROM [Common].[ModuleMaster]  WHERE COMPANYID=@UNIQUE_COMPANY_ID AND NAME='Admin Cursor')
--		INSERT INTO [Common].[ControlCodeCategoryModule] (Id, CompanyId, ControlCategoryId, ModuleMasterId) VALUES ((SELECT MAX(Id) + 1 FROM [Common].[ControlCodeCategoryModule]),
--		@NEW_COMPANY_ID,@CONTROLCODECATEGORY_ID_MODULE_MASTER_ID,@MODULE_MASTER_ID_CONTROLCODECATEGORY_ID);
--		End

--		--AutoNumberTypes

--		 Declare @ControlCodeCategoryModule_AutoNumberTypes_Cnt bigint
--	 --    Select @ControlCodeCategoryModule_AutoNumberTypes_Cnt =count(*) from [Common].[ControlCodeCategoryModule] WHERE COMPANYID=@NEW_COMPANY_ID
--	 --    AND controlcategoryId  in (SELECT  ID FROM [Common].[ControlCodeCategory] WHERE COMPANYID=@NEW_COMPANY_ID AND CONTROLCODECATEGORYCODE='AutoNumber Types')
--	 --    If @ControlCodeCategoryModule_AutoNumberTypes_Cnt =0
--		--Begin
--		--SET @CONTROLCODECATEGORY_ID_MODULE_MASTER_ID = (SELECT top 1 ID FROM [Common].[ControlCodeCategory] WHERE COMPANYID=@NEW_COMPANY_ID AND CONTROLCODECATEGORYCODE='AutoNumber Types')
--		--SET @MODULE_MASTER_ID_CONTROLCODECATEGORY_ID = (SELECT Id FROM [Common].[ModuleMaster]  WHERE COMPANYID=@UNIQUE_COMPANY_ID AND NAME='Admin Cursor')
--		--INSERT INTO [Common].[ControlCodeCategoryModule] (Id, CompanyId, ControlCategoryId, ModuleMasterId) VALUES ((SELECT MAX(Id) + 1 FROM [Common].[ControlCodeCategoryModule]),
--		--@NEW_COMPANY_ID,@CONTROLCODECATEGORY_ID_MODULE_MASTER_ID,@MODULE_MASTER_ID_CONTROLCODECATEGORY_ID);
--		--End

--		--Employee Designation
--		 Declare @ControlCodeCategoryModule_EmployeeDesignation_Cnt bigint
--	     Select @ControlCodeCategoryModule_EmployeeDesignation_Cnt =count(*) from [Common].[ControlCodeCategoryModule] WHERE COMPANYID=@NEW_COMPANY_ID
--	     AND controlcategoryId  in (SELECT  ID FROM [Common].[ControlCodeCategory] WHERE COMPANYID=@NEW_COMPANY_ID AND CONTROLCODECATEGORYCODE='Employee Designation')
--	     If @ControlCodeCategoryModule_EmployeeDesignation_Cnt =0
--		Begin
--		SET @CONTROLCODECATEGORY_ID_MODULE_MASTER_ID = (SELECT top 1 ID FROM [Common].[ControlCodeCategory] WHERE COMPANYID=@NEW_COMPANY_ID AND CONTROLCODECATEGORYCODE='Employee Designation')
--		SET @MODULE_MASTER_ID_CONTROLCODECATEGORY_ID = (SELECT Id FROM [Common].[ModuleMaster]  WHERE COMPANYID=@UNIQUE_COMPANY_ID AND NAME='Admin Cursor')
--		INSERT INTO [Common].[ControlCodeCategoryModule] (Id, CompanyId, ControlCategoryId, ModuleMasterId) VALUES ((SELECT MAX(Id) + 1 FROM [Common].[ControlCodeCategoryModule]),
--		@NEW_COMPANY_ID,@CONTROLCODECATEGORY_ID_MODULE_MASTER_ID,@MODULE_MASTER_ID_CONTROLCODECATEGORY_ID);
--		End

--		--VendorType
--		 Declare @ControlCodeCategoryModule_VendorType_Cnt bigint
--	     Select @ControlCodeCategoryModule_VendorType_Cnt =count(*) from [Common].[ControlCodeCategoryModule] WHERE COMPANYID=@NEW_COMPANY_ID
--	     AND controlcategoryId  in (SELECT  ID FROM [Common].[ControlCodeCategory] WHERE COMPANYID=@NEW_COMPANY_ID AND CONTROLCODECATEGORYCODE='VendorType')
--	     If @ControlCodeCategoryModule_VendorType_Cnt =0
--		Begin
--		SET @CONTROLCODECATEGORY_ID_MODULE_MASTER_ID = (SELECT top 1 ID FROM [Common].[ControlCodeCategory] WHERE COMPANYID=@NEW_COMPANY_ID AND CONTROLCODECATEGORYCODE='VendorType')
--		SET @MODULE_MASTER_ID_CONTROLCODECATEGORY_ID = (SELECT Id FROM [Common].[ModuleMaster]  WHERE COMPANYID=@UNIQUE_COMPANY_ID AND NAME='Admin Cursor')
--		INSERT INTO [Common].[ControlCodeCategoryModule] (Id, CompanyId, ControlCategoryId, ModuleMasterId) VALUES ((SELECT MAX(Id) + 1 FROM [Common].[ControlCodeCategoryModule]),
--		@NEW_COMPANY_ID,@CONTROLCODECATEGORY_ID_MODULE_MASTER_ID,@MODULE_MASTER_ID_CONTROLCODECATEGORY_ID);
--		End

--		--Source Type
--		 Declare @ControlCodeCategoryModule_SourceType_Cnt bigint
--	     Select @ControlCodeCategoryModule_SourceType_Cnt =count(*) from [Common].[ControlCodeCategoryModule] WHERE COMPANYID=@NEW_COMPANY_ID
--	     AND controlcategoryId  in (SELECT  ID FROM [Common].[ControlCodeCategory] WHERE COMPANYID=@NEW_COMPANY_ID AND CONTROLCODECATEGORYCODE='Source Type')
--	     If @ControlCodeCategoryModule_SourceType_Cnt =0
--		Begin
--		SET @CONTROLCODECATEGORY_ID_MODULE_MASTER_ID = (SELECT top 1 ID FROM [Common].[ControlCodeCategory] WHERE COMPANYID=@NEW_COMPANY_ID AND CONTROLCODECATEGORYCODE='Source Type')
--		SET @MODULE_MASTER_ID_CONTROLCODECATEGORY_ID = (SELECT Id FROM [Common].[ModuleMaster]  WHERE COMPANYID=@UNIQUE_COMPANY_ID AND NAME='Admin Cursor')
--		INSERT INTO [Common].[ControlCodeCategoryModule] (Id, CompanyId, ControlCategoryId, ModuleMasterId) VALUES ((SELECT MAX(Id) + 1 FROM [Common].[ControlCodeCategoryModule]),
--		@NEW_COMPANY_ID,@CONTROLCODECATEGORY_ID_MODULE_MASTER_ID,@MODULE_MASTER_ID_CONTROLCODECATEGORY_ID);				
--		End
		
--		--Industries
--		 Declare @ControlCodeCategoryModule_Industries_Cnt bigint
--	     Select @ControlCodeCategoryModule_Industries_Cnt =count(*) from [Common].[ControlCodeCategoryModule] WHERE COMPANYID=@NEW_COMPANY_ID
--	     AND controlcategoryId  in (SELECT  ID FROM [Common].[ControlCodeCategory] WHERE COMPANYID=@NEW_COMPANY_ID AND CONTROLCODECATEGORYCODE='Industries')
--	     If @ControlCodeCategoryModule_Industries_Cnt =0
--		Begin
--		SET @CONTROLCODECATEGORY_ID_MODULE_MASTER_ID = (SELECT top 1 ID FROM [Common].[ControlCodeCategory] WHERE COMPANYID=@NEW_COMPANY_ID AND CONTROLCODECATEGORYCODE='Industries')
--		SET @MODULE_MASTER_ID_CONTROLCODECATEGORY_ID = (SELECT Id FROM [Common].[ModuleMaster]  WHERE COMPANYID=@UNIQUE_COMPANY_ID AND NAME='Admin Cursor')
--		INSERT INTO [Common].[ControlCodeCategoryModule] (Id, CompanyId, ControlCategoryId, ModuleMasterId) VALUES ((SELECT MAX(Id) + 1 FROM [Common].[ControlCodeCategoryModule]),
--		@NEW_COMPANY_ID,@CONTROLCODECATEGORY_ID_MODULE_MASTER_ID,@MODULE_MASTER_ID_CONTROLCODECATEGORY_ID);
--		End

--		----Type
--		-- Declare @ControlCodeCategoryModule_Type_Cnt bigint
--	 --    Select @ControlCodeCategoryModule_Type_Cnt =count(*) from [Common].[ControlCodeCategoryModule] WHERE COMPANYID=@NEW_COMPANY_ID
--	 --    AND controlcategoryId  in (SELECT  ID FROM [Common].[ControlCodeCategory] WHERE COMPANYID=@NEW_COMPANY_ID AND CONTROLCODECATEGORYCODE='Type')
--	 --    If @ControlCodeCategoryModule_Type_Cnt =0
--		--  Begin
--		--  SET @CONTROLCODECATEGORY_ID_MODULE_MASTER_ID = (SELECT top 1 ID FROM [Common].[ControlCodeCategory] WHERE COMPANYID=@NEW_COMPANY_ID AND CONTROLCODECATEGORYCODE='Type')
--		--  SET @MODULE_MASTER_ID_CONTROLCODECATEGORY_ID = (SELECT Id FROM [Common].[ModuleMaster]  WHERE COMPANYID=@UNIQUE_COMPANY_ID AND NAME='Workflow Cursor')
--		--  INSERT INTO [Common].[ControlCodeCategoryModule] (Id, CompanyId, ControlCategoryId, ModuleMasterId) VALUES ((SELECT MAX(Id) + 1 FROM [Common].[ControlCodeCategoryModule]),
--		--  @NEW_COMPANY_ID,@CONTROLCODECATEGORY_ID_MODULE_MASTER_ID,@MODULE_MASTER_ID_CONTROLCODECATEGORY_ID);
--		--  End

--		 -- --Reason
--		 --Declare @ControlCodeCategoryModule_Reason_Cnt bigint
--	  --   Select @ControlCodeCategoryModule_Reason_Cnt =count(*) from [Common].[ControlCodeCategoryModule] WHERE COMPANYID=@NEW_COMPANY_ID
--	  --   AND controlcategoryId  in (SELECT  ID FROM [Common].[ControlCodeCategory] WHERE COMPANYID=@NEW_COMPANY_ID AND CONTROLCODECATEGORYCODE='Reason')
--	  --   If @ControlCodeCategoryModule_Reason_Cnt =0
--		 -- Begin
--		 --SET @CONTROLCODECATEGORY_ID_MODULE_MASTER_ID = (SELECT top 1 ID FROM [Common].[ControlCodeCategory] WHERE COMPANYID=@NEW_COMPANY_ID AND CONTROLCODECATEGORYCODE='Reason')
--		 -- SET @MODULE_MASTER_ID_CONTROLCODECATEGORY_ID = (SELECT Id FROM [Common].[ModuleMaster]  WHERE COMPANYID=@UNIQUE_COMPANY_ID AND NAME='Workflow Cursor')
--		 -- INSERT INTO [Common].[ControlCodeCategoryModule] (Id, CompanyId, ControlCategoryId, ModuleMasterId) VALUES ((SELECT MAX(Id) + 1 FROM [Common].[ControlCodeCategoryModule]),
--		 -- @NEW_COMPANY_ID,@CONTROLCODECATEGORY_ID_MODULE_MASTER_ID,@MODULE_MASTER_ID_CONTROLCODECATEGORY_ID);
--		 -- End

--		  --IncidentalClaimUnit
--		   Declare @ControlCodeCategoryModule_IncidentalClaimUnit_Cnt bigint
--	     Select @ControlCodeCategoryModule_IncidentalClaimUnit_Cnt =count(*) from [Common].[ControlCodeCategoryModule] WHERE COMPANYID=@NEW_COMPANY_ID
--	     AND controlcategoryId  in (SELECT  ID FROM [Common].[ControlCodeCategory] WHERE COMPANYID=@NEW_COMPANY_ID AND CONTROLCODECATEGORYCODE='IncidentalClaimUnit')
--	     If @ControlCodeCategoryModule_IncidentalClaimUnit_Cnt =0
--		  Begin
--		   SET @CONTROLCODECATEGORY_ID_MODULE_MASTER_ID = (SELECT top 1 ID FROM [Common].[ControlCodeCategory] WHERE COMPANYID=@NEW_COMPANY_ID AND CONTROLCODECATEGORYCODE='IncidentalClaimUnit')
--		  SET @MODULE_MASTER_ID_CONTROLCODECATEGORY_ID = (SELECT Id FROM [Common].[ModuleMaster]  WHERE COMPANYID=@UNIQUE_COMPANY_ID AND NAME='Admin Cursor')
--		  INSERT INTO [Common].[ControlCodeCategoryModule] (Id, CompanyId, ControlCategoryId, ModuleMasterId) VALUES ((SELECT MAX(Id) + 1 FROM [Common].[ControlCodeCategoryModule]),
--		  @NEW_COMPANY_ID,@CONTROLCODECATEGORY_ID_MODULE_MASTER_ID,@MODULE_MASTER_ID_CONTROLCODECATEGORY_ID);
--		  End

--		 -- --EntityAddress
--			--Declare @ControlCodeCategoryModule_EntityAddress_Cnt bigint
--			--Select @ControlCodeCategoryModule_EntityAddress_Cnt =count(*) from [Common].[ControlCodeCategoryModule] WHERE COMPANYID=@NEW_COMPANY_ID
--			--AND controlcategoryId  in (SELECT  ID FROM [Common].[ControlCodeCategory] WHERE COMPANYID=@NEW_COMPANY_ID AND CONTROLCODECATEGORYCODE='EntityAddress')
--			--If @ControlCodeCategoryModule_EntityAddress_Cnt =0
--		 -- Begin
--			--  SET @CONTROLCODECATEGORY_ID_MODULE_MASTER_ID = (SELECT top 1 ID FROM [Common].[ControlCodeCategory] WHERE COMPANYID=@NEW_COMPANY_ID AND CONTROLCODECATEGORYCODE='EntityAddress')
--			--  SET @MODULE_MASTER_ID_CONTROLCODECATEGORY_ID = (SELECT Id FROM [Common].[ModuleMaster]  WHERE COMPANYID=@UNIQUE_COMPANY_ID AND NAME='Workflow Cursor')
--			--  INSERT INTO [Common].[ControlCodeCategoryModule] (Id, CompanyId, ControlCategoryId, ModuleMasterId) VALUES ((SELECT MAX(Id) + 1 FROM [Common].[ControlCodeCategoryModule]),
--			--  @NEW_COMPANY_ID,@CONTROLCODECATEGORY_ID_MODULE_MASTER_ID,@MODULE_MASTER_ID_CONTROLCODECATEGORY_ID);
--	  --    End

--		--  --IndividualAddress
--		--	Declare @ControlCodeCategoryModule_IndividualAddress_Cnt bigint
--		--	Select @ControlCodeCategoryModule_IndividualAddress_Cnt =count(*) from [Common].[ControlCodeCategoryModule] WHERE COMPANYID=@NEW_COMPANY_ID
--		--	AND controlcategoryId  in (SELECT  ID FROM [Common].[ControlCodeCategory] WHERE COMPANYID=@NEW_COMPANY_ID AND CONTROLCODECATEGORYCODE='IndividualAddress')
--		--	If @ControlCodeCategoryModule_IndividualAddress_Cnt =0
--		--  Begin
--  -- SET @CONTROLCODECATEGORY_ID_MODULE_MASTER_ID = (SELECT top 1 ID FROM [Common].[ControlCodeCategory] WHERE COMPANYID=@NEW_COMPANY_ID AND CONTROLCODECATEGORYCODE='IndividualAddress')
--  --SET @MODULE_MASTER_ID_CONTROLCODECATEGORY_ID = (SELECT Id FROM [Common].[ModuleMaster]  WHERE COMPANYID=@UNIQUE_COMPANY_ID AND NAME='Workflow Cursor')
--  --INSERT INTO [Common].[ControlCodeCategoryModule] (Id, CompanyId, ControlCategoryId, ModuleMasterId) VALUES ((SELECT MAX(Id) + 1 FROM [Common].[ControlCodeCategoryModule]),
--  --@NEW_COMPANY_ID,@CONTROLCODECATEGORY_ID_MODULE_MASTER_ID,@MODULE_MASTER_ID_CONTROLCODECATEGORY_ID);
--  --End

--  ----ReasonForCancel
--  --Declare @ControlCodeCategoryModule_ReasonForCancel_Cnt bigint
--		--	Select @ControlCodeCategoryModule_ReasonForCancel_Cnt =count(*) from [Common].[ControlCodeCategoryModule] WHERE COMPANYID=@NEW_COMPANY_ID
--		--	AND controlcategoryId  in (SELECT  ID FROM [Common].[ControlCodeCategory] WHERE COMPANYID=@NEW_COMPANY_ID AND CONTROLCODECATEGORYCODE='ReasonForCancel')
--		--	If @ControlCodeCategoryModule_ReasonForCancel_Cnt =0
--		--  Begin
--  --   SET @CONTROLCODECATEGORY_ID_MODULE_MASTER_ID = (SELECT top 1 ID FROM [Common].[ControlCodeCategory] WHERE COMPANYID=@NEW_COMPANY_ID AND CONTROLCODECATEGORYCODE='ReasonForCancel')
--  --SET @MODULE_MASTER_ID_CONTROLCODECATEGORY_ID = (SELECT Id FROM [Common].[ModuleMaster]  WHERE COMPANYID=@UNIQUE_COMPANY_ID AND NAME='Workflow Cursor')
--  --INSERT INTO [Common].[ControlCodeCategoryModule] (Id, CompanyId, ControlCategoryId, ModuleMasterId) VALUES ((SELECT MAX(Id) + 1 FROM [Common].[ControlCodeCategoryModule]),
--  --@NEW_COMPANY_ID,@CONTROLCODECATEGORY_ID_MODULE_MASTER_ID,@MODULE_MASTER_ID_CONTROLCODECATEGORY_ID);
--  --End

--  --MileStone
--  Declare @ControlCodeCategoryModule_MileStone_Cnt bigint
--			Select @ControlCodeCategoryModule_MileStone_Cnt =count(*) from [Common].[ControlCodeCategoryModule] WHERE COMPANYID=@NEW_COMPANY_ID
--			AND controlcategoryId  in (SELECT  ID FROM [Common].[ControlCodeCategory] WHERE COMPANYID=@NEW_COMPANY_ID AND CONTROLCODECATEGORYCODE='MileStone')
--			If @ControlCodeCategoryModule_MileStone_Cnt =0
--		  Begin
--  SET @CONTROLCODECATEGORY_ID_MODULE_MASTER_ID = (SELECT top 1 ID FROM [Common].[ControlCodeCategory] WHERE COMPANYID=@NEW_COMPANY_ID AND CONTROLCODECATEGORYCODE='MileStone')
--  SET @MODULE_MASTER_ID_CONTROLCODECATEGORY_ID = (SELECT Id FROM [Common].[ModuleMaster]  WHERE COMPANYID=@UNIQUE_COMPANY_ID AND NAME='Admin Cursor')
--  INSERT INTO [Common].[ControlCodeCategoryModule] (Id, CompanyId, ControlCategoryId, ModuleMasterId) VALUES ((SELECT MAX(Id) + 1 FROM [Common].[ControlCodeCategoryModule]),
--  @NEW_COMPANY_ID,@CONTROLCODECATEGORY_ID_MODULE_MASTER_ID,@MODULE_MASTER_ID_CONTROLCODECATEGORY_ID);
--  End

--  --Task
--   Declare @ControlCodeCategoryModule_Task_Cnt bigint
--			Select @ControlCodeCategoryModule_Task_Cnt =count(*) from [Common].[ControlCodeCategoryModule] WHERE COMPANYID=@NEW_COMPANY_ID
--			AND controlcategoryId  in (SELECT  ID FROM [Common].[ControlCodeCategory] WHERE COMPANYID=@NEW_COMPANY_ID AND CONTROLCODECATEGORYCODE='Task')
--			If @ControlCodeCategoryModule_Task_Cnt =0
--		  Begin
--  SET @CONTROLCODECATEGORY_ID_MODULE_MASTER_ID = (SELECT top 1 ID FROM [Common].[ControlCodeCategory] WHERE COMPANYID=@NEW_COMPANY_ID AND CONTROLCODECATEGORYCODE='Task')
--  SET @MODULE_MASTER_ID_CONTROLCODECATEGORY_ID = (SELECT Id FROM [Common].[ModuleMaster]  WHERE COMPANYID=@UNIQUE_COMPANY_ID AND NAME='Admin Cursor')
--  INSERT INTO [Common].[ControlCodeCategoryModule] (Id, CompanyId, ControlCategoryId, ModuleMasterId) VALUES ((SELECT MAX(Id) + 1 FROM [Common].[ControlCodeCategoryModule]),
--  @NEW_COMPANY_ID,@CONTROLCODECATEGORY_ID_MODULE_MASTER_ID,@MODULE_MASTER_ID_CONTROLCODECATEGORY_ID);
--  End

--  ----Designation
--  -- Declare @ControlCodeCategoryModule_Designation_Cnt bigint
--		--	Select @ControlCodeCategoryModule_Designation_Cnt =count(*) from [Common].[ControlCodeCategoryModule] WHERE COMPANYID=@NEW_COMPANY_ID
--		--	AND controlcategoryId  in (SELECT  ID FROM [Common].[ControlCodeCategory] WHERE COMPANYID=@NEW_COMPANY_ID AND CONTROLCODECATEGORYCODE='Designation')
--		--	If @ControlCodeCategoryModule_Designation_Cnt =0
--		--  Begin
--  -- 	SET @CONTROLCODECATEGORY_ID_MODULE_MASTER_ID = (SELECT top 1 ID FROM [Common].[ControlCodeCategory] WHERE COMPANYID=@NEW_COMPANY_ID AND CONTROLCODECATEGORYCODE='Designation')
--		--SET @MODULE_MASTER_ID_CONTROLCODECATEGORY_ID = (SELECT Id FROM [Common].[ModuleMaster]  WHERE COMPANYID=@UNIQUE_COMPANY_ID AND NAME='Workflow Cursor')
--		--INSERT INTO [Common].[ControlCodeCategoryModule] (Id, CompanyId, ControlCategoryId, ModuleMasterId) VALUES ((SELECT MAX(Id) + 1 FROM [Common].[ControlCodeCategoryModule]),
--		--@NEW_COMPANY_ID,@CONTROLCODECATEGORY_ID_MODULE_MASTER_ID,@MODULE_MASTER_ID_CONTROLCODECATEGORY_ID);
--		--End

--		--TimeLogPeriod
--		Declare @ControlCodeCategoryModule_TimeLogPeriod_Cnt bigint
--			Select @ControlCodeCategoryModule_TimeLogPeriod_Cnt =count(*) from [Common].[ControlCodeCategoryModule] WHERE COMPANYID=@NEW_COMPANY_ID
--			AND controlcategoryId  in (SELECT  ID FROM [Common].[ControlCodeCategory] WHERE COMPANYID=@NEW_COMPANY_ID AND CONTROLCODECATEGORYCODE='TimeLogPeriod')
--			If @ControlCodeCategoryModule_TimeLogPeriod_Cnt =0
--		  Begin
-- SET @CONTROLCODECATEGORY_ID_MODULE_MASTER_ID = (SELECT top 1 ID FROM [Common].[ControlCodeCategory] WHERE COMPANYID=@NEW_COMPANY_ID AND CONTROLCODECATEGORYCODE='TimeLogPeriod')
--  SET @MODULE_MASTER_ID_CONTROLCODECATEGORY_ID = (SELECT Id FROM [Common].[ModuleMaster]  WHERE COMPANYID=@UNIQUE_COMPANY_ID AND NAME='Admin Cursor')
--  INSERT INTO [Common].[ControlCodeCategoryModule] (Id, CompanyId, ControlCategoryId, ModuleMasterId) VALUES ((SELECT MAX(Id) + 1 FROM [Common].[ControlCodeCategoryModule]),
--  @NEW_COMPANY_ID,@CONTROLCODECATEGORY_ID_MODULE_MASTER_ID,@MODULE_MASTER_ID_CONTROLCODECATEGORY_ID);
--  End

--  ----WorkType
--  --	Declare @ControlCodeCategoryModule_WorkType_Cnt bigint
--		--	Select @ControlCodeCategoryModule_WorkType_Cnt =count(*) from [Common].[ControlCodeCategoryModule] WHERE COMPANYID=@NEW_COMPANY_ID
--		--	AND controlcategoryId  in (SELECT  ID FROM [Common].[ControlCodeCategory] WHERE COMPANYID=@NEW_COMPANY_ID AND CONTROLCODECATEGORYCODE='WorkType')
--		--	If @ControlCodeCategoryModule_WorkType_Cnt =0
--		--  Begin
--  -- SET @CONTROLCODECATEGORY_ID_MODULE_MASTER_ID = (SELECT top 1 ID FROM [Common].[ControlCodeCategory] WHERE COMPANYID=@NEW_COMPANY_ID AND CONTROLCODECATEGORYCODE='WorkType')
--  --SET @MODULE_MASTER_ID_CONTROLCODECATEGORY_ID = (SELECT Id FROM [Common].[ModuleMaster]  WHERE COMPANYID=@UNIQUE_COMPANY_ID AND NAME='Admin Cursor')
--  --INSERT INTO [Common].[ControlCodeCategoryModule] (Id, CompanyId, ControlCategoryId, ModuleMasterId) VALUES ((SELECT MAX(Id) + 1 FROM [Common].[ControlCodeCategoryModule]),
--  --@NEW_COMPANY_ID,@CONTROLCODECATEGORY_ID_MODULE_MASTER_ID,@MODULE_MASTER_ID_CONTROLCODECATEGORY_ID);
--  --End

--  --Claims Category
--  Declare @ControlCodeCategoryModule_ClaimsCategory_Cnt bigint
--			Select @ControlCodeCategoryModule_ClaimsCategory_Cnt =count(*) from [Common].[ControlCodeCategoryModule] WHERE COMPANYID=@NEW_COMPANY_ID
--			AND controlcategoryId  in (SELECT  ID FROM [Common].[ControlCodeCategory] WHERE COMPANYID=@NEW_COMPANY_ID AND CONTROLCODECATEGORYCODE='Claims Category')
--			If @ControlCodeCategoryModule_ClaimsCategory_Cnt =0
--		  Begin
--   SET @CONTROLCODECATEGORY_ID_MODULE_MASTER_ID = (SELECT top 1 ID FROM [Common].[ControlCodeCategory] WHERE COMPANYID=@NEW_COMPANY_ID AND CONTROLCODECATEGORYCODE='Claims Category')
--  SET @MODULE_MASTER_ID_CONTROLCODECATEGORY_ID = (SELECT Id FROM [Common].[ModuleMaster]  WHERE COMPANYID=@UNIQUE_COMPANY_ID AND NAME='Admin Cursor')
--  INSERT INTO [Common].[ControlCodeCategoryModule] (Id, CompanyId, ControlCategoryId, ModuleMasterId) VALUES ((SELECT MAX(Id) + 1 FROM [Common].[ControlCodeCategoryModule]),
--  @NEW_COMPANY_ID,@CONTROLCODECATEGORY_ID_MODULE_MASTER_ID,@MODULE_MASTER_ID_CONTROLCODECATEGORY_ID);
--  End


-- -- --Assets
-- -- Declare @ControlCodeCategoryModule_Assets_Cnt bigint
--	--		Select @ControlCodeCategoryModule_Assets_Cnt =count(*) from [Common].[ControlCodeCategoryModule] WHERE COMPANYID=@NEW_COMPANY_ID
--	--		AND controlcategoryId  in (SELECT  ID FROM [Common].[ControlCodeCategory] WHERE COMPANYID=@NEW_COMPANY_ID AND CONTROLCODECATEGORYCODE='Assets')
--	--		If @ControlCodeCategoryModule_Assets_Cnt =0
--	--	  Begin
-- --SET @CONTROLCODECATEGORY_ID_MODULE_MASTER_ID = (SELECT top 1 ID FROM [Common].[ControlCodeCategory] WHERE COMPANYID=@NEW_COMPANY_ID AND CONTROLCODECATEGORYCODE='Assets')
-- -- SET @MODULE_MASTER_ID_CONTROLCODECATEGORY_ID = (SELECT Id FROM [Common].[ModuleMaster]  WHERE COMPANYID=@UNIQUE_COMPANY_ID AND NAME='Admin Cursor')
-- -- INSERT INTO [Common].[ControlCodeCategoryModule] (Id, CompanyId, ControlCategoryId, ModuleMasterId) VALUES ((SELECT MAX(Id) + 1 FROM [Common].[ControlCodeCategoryModule]),
-- -- @NEW_COMPANY_ID,@CONTROLCODECATEGORY_ID_MODULE_MASTER_ID,@MODULE_MASTER_ID_CONTROLCODECATEGORY_ID);
-- -- End

-- --   --Liabilities
--	-- Declare @ControlCodeCategoryModule_Liabilities_Cnt bigint
--	--		Select @ControlCodeCategoryModule_Liabilities_Cnt =count(*) from [Common].[ControlCodeCategoryModule] WHERE COMPANYID=@NEW_COMPANY_ID
--	--		AND controlcategoryId  in (SELECT  ID FROM [Common].[ControlCodeCategory] WHERE COMPANYID=@NEW_COMPANY_ID AND CONTROLCODECATEGORYCODE='Liabilities')
--	--		If @ControlCodeCategoryModule_Liabilities_Cnt =0
--	--	  Begin
-- --SET @CONTROLCODECATEGORY_ID_MODULE_MASTER_ID = (SELECT top 1 ID FROM [Common].[ControlCodeCategory] WHERE COMPANYID=@NEW_COMPANY_ID AND CONTROLCODECATEGORYCODE='Liabilities')
-- -- SET @MODULE_MASTER_ID_CONTROLCODECATEGORY_ID = (SELECT Id FROM [Common].[ModuleMaster]  WHERE COMPANYID=@UNIQUE_COMPANY_ID AND NAME='Admin Cursor')
-- -- INSERT INTO [Common].[ControlCodeCategoryModule] (Id, CompanyId, ControlCategoryId, ModuleMasterId) VALUES ((SELECT MAX(Id) + 1 FROM [Common].[ControlCodeCategoryModule]),
-- -- @NEW_COMPANY_ID,@CONTROLCODECATEGORY_ID_MODULE_MASTER_ID,@MODULE_MASTER_ID_CONTROLCODECATEGORY_ID);
-- -- End

----  --Income
----  Declare @ControlCodeCategoryModule_Income_Cnt bigint
----			Select @ControlCodeCategoryModule_Income_Cnt =count(*) from [Common].[ControlCodeCategoryModule] WHERE COMPANYID=@NEW_COMPANY_ID
----			AND controlcategoryId  in (SELECT  ID FROM [Common].[ControlCodeCategory] WHERE COMPANYID=@NEW_COMPANY_ID AND CONTROLCODECATEGORYCODE='Income')
----			If @ControlCodeCategoryModule_Income_Cnt =0
----		  Begin
---- SET @CONTROLCODECATEGORY_ID_MODULE_MASTER_ID = (SELECT top 1 ID FROM [Common].[ControlCodeCategory] WHERE COMPANYID=@NEW_COMPANY_ID AND CONTROLCODECATEGORYCODE='Income')
----  SET @MODULE_MASTER_ID_CONTROLCODECATEGORY_ID = (SELECT Id FROM [Common].[ModuleMaster]  WHERE COMPANYID=@UNIQUE_COMPANY_ID AND NAME='Admin Cursor')
----  INSERT INTO [Common].[ControlCodeCategoryModule] (Id, CompanyId, ControlCategoryId, ModuleMasterId) VALUES ((SELECT MAX(Id) + 1 FROM [Common].[ControlCodeCategoryModule]),
----  @NEW_COMPANY_ID,@CONTROLCODECATEGORY_ID_MODULE_MASTER_ID,@MODULE_MASTER_ID_CONTROLCODECATEGORY_ID);
----  End

   
----   --Expenses
----   Declare @ControlCodeCategoryModule_Expenses_Cnt bigint
----			Select @ControlCodeCategoryModule_Expenses_Cnt =count(*) from [Common].[ControlCodeCategoryModule] WHERE COMPANYID=@NEW_COMPANY_ID
----			AND controlcategoryId  in (SELECT  ID FROM [Common].[ControlCodeCategory] WHERE COMPANYID=@NEW_COMPANY_ID AND CONTROLCODECATEGORYCODE='Expenses')
----			If @ControlCodeCategoryModule_Expenses_Cnt =0
----		  Begin
---- SET @CONTROLCODECATEGORY_ID_MODULE_MASTER_ID = (SELECT top 1 ID FROM [Common].[ControlCodeCategory] WHERE COMPANYID=@NEW_COMPANY_ID AND CONTROLCODECATEGORYCODE='Expenses')
----  SET @MODULE_MASTER_ID_CONTROLCODECATEGORY_ID = (SELECT Id FROM [Common].[ModuleMaster]  WHERE COMPANYID=@UNIQUE_COMPANY_ID AND NAME='Admin Cursor')
----  INSERT INTO [Common].[ControlCodeCategoryModule] (Id, CompanyId, ControlCategoryId, ModuleMasterId) VALUES ((SELECT MAX(Id) + 1 FROM [Common].[ControlCodeCategoryModule]),
----  @NEW_COMPANY_ID,@CONTROLCODECATEGORY_ID_MODULE_MASTER_ID,@MODULE_MASTER_ID_CONTROLCODECATEGORY_ID);
----  End


  
------------------------------ Equity ---------------------------------------------
------Equity
----            Declare @ControlCodeCategoryModule_Equity_Cnt bigint
----			Select @ControlCodeCategoryModule_Equity_Cnt =count(*) from [Common].[ControlCodeCategoryModule] WHERE COMPANYID=@NEW_COMPANY_ID
----			AND controlcategoryId  in (SELECT  ID FROM [Common].[ControlCodeCategory] WHERE COMPANYID=@NEW_COMPANY_ID AND CONTROLCODECATEGORYCODE='Equity')
----			If @ControlCodeCategoryModule_Equity_Cnt =0
----		  Begin
---- SET @CONTROLCODECATEGORY_ID_MODULE_MASTER_ID = (SELECT top 1 ID FROM [Common].[ControlCodeCategory] WHERE COMPANYID=@NEW_COMPANY_ID AND CONTROLCODECATEGORYCODE='Equity')
----  SET @MODULE_MASTER_ID_CONTROLCODECATEGORY_ID = (SELECT Id FROM [Common].[ModuleMaster]  WHERE COMPANYID=@UNIQUE_COMPANY_ID AND NAME='Admin Cursor')
----  INSERT INTO [Common].[ControlCodeCategoryModule] (Id, CompanyId, ControlCategoryId, ModuleMasterId) VALUES ((SELECT MAX(Id) + 1 FROM [Common].[ControlCodeCategoryModule]),
----  @NEW_COMPANY_ID,@CONTROLCODECATEGORY_ID_MODULE_MASTER_ID,@MODULE_MASTER_ID_CONTROLCODECATEGORY_ID);
----  End

--  --Country
--   Declare @ControlCodeCategoryModule_Country_Cnt bigint
--			Select @ControlCodeCategoryModule_Country_Cnt =count(*) from [Common].[ControlCodeCategoryModule] WHERE COMPANYID=@NEW_COMPANY_ID
--			AND controlcategoryId  in (SELECT  ID FROM [Common].[ControlCodeCategory] WHERE COMPANYID=@NEW_COMPANY_ID AND CONTROLCODECATEGORYCODE='Country')
--			If @ControlCodeCategoryModule_Country_Cnt =0
--		  Begin
--   SET @CONTROLCODECATEGORY_ID_MODULE_MASTER_ID = (SELECT top 1 ID FROM [Common].[ControlCodeCategory] WHERE COMPANYID=@NEW_COMPANY_ID AND CONTROLCODECATEGORYCODE='Country')
--  SET @MODULE_MASTER_ID_CONTROLCODECATEGORY_ID = (SELECT Id FROM [Common].[ModuleMaster]  WHERE COMPANYID=@UNIQUE_COMPANY_ID AND NAME='Admin Cursor')
--  INSERT INTO [Common].[ControlCodeCategoryModule] (Id, CompanyId, ControlCategoryId, ModuleMasterId) VALUES ((SELECT MAX(Id) + 1 FROM [Common].[ControlCodeCategoryModule]),
--  @NEW_COMPANY_ID,@CONTROLCODECATEGORY_ID_MODULE_MASTER_ID,@MODULE_MASTER_ID_CONTROLCODECATEGORY_ID);
--  End
  
--  --Question Category
--   Declare @ControlCodeCategoryModule_QuestionCategory_Cnt bigint
--			Select @ControlCodeCategoryModule_QuestionCategory_Cnt =count(*) from [Common].[ControlCodeCategoryModule] WHERE COMPANYID=@NEW_COMPANY_ID
--			AND controlcategoryId  in (SELECT  ID FROM [Common].[ControlCodeCategory] WHERE COMPANYID=@NEW_COMPANY_ID AND CONTROLCODECATEGORYCODE='Question Category')
--			If @ControlCodeCategoryModule_QuestionCategory_Cnt =0
--		  Begin
--   SET @CONTROLCODECATEGORY_ID_MODULE_MASTER_ID = (SELECT top 1 ID FROM [Common].[ControlCodeCategory] WHERE COMPANYID=@NEW_COMPANY_ID AND CONTROLCODECATEGORYCODE='Question Category')
--  SET @MODULE_MASTER_ID_CONTROLCODECATEGORY_ID = (SELECT Id FROM [Common].[ModuleMaster]  WHERE COMPANYID=@UNIQUE_COMPANY_ID AND NAME='Admin Cursor')
--  INSERT INTO [Common].[ControlCodeCategoryModule] (Id, CompanyId, ControlCategoryId, ModuleMasterId) VALUES ((SELECT MAX(Id) + 1 FROM [Common].[ControlCodeCategoryModule]),
--  @NEW_COMPANY_ID,@CONTROLCODECATEGORY_ID_MODULE_MASTER_ID,@MODULE_MASTER_ID_CONTROLCODECATEGORY_ID);
--  End

--  --Suggestion Screenname
--  Declare @ControlCodeCategoryModule_SuggestionScreenname_Cnt bigint
--			Select @ControlCodeCategoryModule_SuggestionScreenname_Cnt =count(*) from [Common].[ControlCodeCategoryModule] WHERE COMPANYID=@NEW_COMPANY_ID
--			AND controlcategoryId  in (SELECT  ID FROM [Common].[ControlCodeCategory] WHERE COMPANYID=@NEW_COMPANY_ID AND CONTROLCODECATEGORYCODE='Suggestion Screenname')
--			If @ControlCodeCategoryModule_SuggestionScreenname_Cnt =0
--		  Begin
--    SET @CONTROLCODECATEGORY_ID_MODULE_MASTER_ID = (SELECT top 1 ID FROM [Common].[ControlCodeCategory] WHERE COMPANYID=@NEW_COMPANY_ID AND CONTROLCODECATEGORYCODE='Suggestion Screenname')
--  SET @MODULE_MASTER_ID_CONTROLCODECATEGORY_ID = (SELECT Id FROM [Common].[ModuleMaster]  WHERE COMPANYID=@UNIQUE_COMPANY_ID AND NAME='Admin Cursor')
--  INSERT INTO [Common].[ControlCodeCategoryModule] (Id, CompanyId, ControlCategoryId, ModuleMasterId) VALUES ((SELECT MAX(Id) + 1 FROM [Common].[ControlCodeCategoryModule]),
--  @NEW_COMPANY_ID,@CONTROLCODECATEGORY_ID_MODULE_MASTER_ID,@MODULE_MASTER_ID_CONTROLCODECATEGORY_ID);
--  End

--  --Foreign Exchange Analysis
--  Declare @ControlCodeCategoryModule_ForeignExchangeAnalysis_Cnt bigint
--			Select @ControlCodeCategoryModule_ForeignExchangeAnalysis_Cnt =count(*) from [Common].[ControlCodeCategoryModule] WHERE COMPANYID=@NEW_COMPANY_ID
--			AND controlcategoryId  in (SELECT  ID FROM [Common].[ControlCodeCategory] WHERE COMPANYID=@NEW_COMPANY_ID AND CONTROLCODECATEGORYCODE='Foreign Exchange Analysis')
--			If @ControlCodeCategoryModule_ForeignExchangeAnalysis_Cnt =0
--		  Begin
--        SET @CONTROLCODECATEGORY_ID_MODULE_MASTER_ID = (SELECT top 1 ID FROM [Common].[ControlCodeCategory] WHERE COMPANYID=@NEW_COMPANY_ID AND CONTROLCODECATEGORYCODE='Foreign Exchange Analysis')
--  SET @MODULE_MASTER_ID_CONTROLCODECATEGORY_ID = (SELECT Id FROM [Common].[ModuleMaster]  WHERE COMPANYID=@UNIQUE_COMPANY_ID AND NAME='Admin Cursor')
--  INSERT INTO [Common].[ControlCodeCategoryModule] (Id, CompanyId, ControlCategoryId, ModuleMasterId) VALUES ((SELECT MAX(Id) + 1 FROM [Common].[ControlCodeCategoryModule]),
--  @NEW_COMPANY_ID,@CONTROLCODECATEGORY_ID_MODULE_MASTER_ID,@MODULE_MASTER_ID_CONTROLCODECATEGORY_ID);
--  End

--  --Functional Currency Analysis
--  Declare @ControlCodeCategoryModule_FunctionalCurrencyAnalysis_Cnt bigint
--			Select @ControlCodeCategoryModule_FunctionalCurrencyAnalysis_Cnt =count(*) from [Common].[ControlCodeCategoryModule] WHERE COMPANYID=@NEW_COMPANY_ID
--			AND controlcategoryId  in (SELECT  ID FROM [Common].[ControlCodeCategory] WHERE COMPANYID=@NEW_COMPANY_ID AND CONTROLCODECATEGORYCODE='Functional Currency Analysis')
--			If @ControlCodeCategoryModule_FunctionalCurrencyAnalysis_Cnt = 0
--		  Begin
--     SET @CONTROLCODECATEGORY_ID_MODULE_MASTER_ID = (SELECT top 1 ID FROM [Common].[ControlCodeCategory] WHERE COMPANYID=@NEW_COMPANY_ID AND CONTROLCODECATEGORYCODE='Functional Currency Analysis')
--  SET @MODULE_MASTER_ID_CONTROLCODECATEGORY_ID = (SELECT Id FROM [Common].[ModuleMaster]  WHERE COMPANYID=@UNIQUE_COMPANY_ID AND NAME='Admin Cursor')
--  INSERT INTO [Common].[ControlCodeCategoryModule] (Id, CompanyId, ControlCategoryId, ModuleMasterId) VALUES ((SELECT MAX(Id) + 1 FROM [Common].[ControlCodeCategoryModule]),
--  @NEW_COMPANY_ID,@CONTROLCODECATEGORY_ID_MODULE_MASTER_ID,@MODULE_MASTER_ID_CONTROLCODECATEGORY_ID);
--  End


--  --------Designation
--Declare @ControlCodeCategoryModuleDesignation_Cnt bigint
-- select @ControlCodeCategoryModuleDesignation_Cnt=Count(*) from [Common].[ControlCodeCategoryModule] where companyid=@NEW_COMPANY_ID 
--and controlcategoryId in(SELECT  ID FROM [Common].[ControlCodeCategory] WHERE COMPANYID=@NEW_COMPANY_ID AND CONTROLCODECATEGORYCODE='Designation') 
         
-- IF @ControlCodeCategoryModuleDesignation_Cnt=0
-- Begin
--  	  SET @CONTROLCODECATEGORY_ID_MODULE_MASTER_ID = (SELECT top 1 ID FROM [Common].[ControlCodeCategory] WHERE COMPANYID=@NEW_COMPANY_ID AND CONTROLCODECATEGORYCODE='Designation')
--  SET @MODULE_MASTER_ID_CONTROLCODECATEGORY_ID = (SELECT Id FROM [Common].[ModuleMaster]  WHERE COMPANYID=@UNIQUE_COMPANY_ID AND NAME='Audit Cursor')
--  INSERT INTO [Common].[ControlCodeCategoryModule] (Id, CompanyId, ControlCategoryId, ModuleMasterId) VALUES ((SELECT MAX(Id) + 1 FROM [Common].[ControlCodeCategoryModule]),
--  @NEW_COMPANY_ID,@CONTROLCODECATEGORY_ID_MODULE_MASTER_ID,@MODULE_MASTER_ID_CONTROLCODECATEGORY_ID);
--  end

Exec [dbo].[ControlCodeCategoryModule_SP_New] @NEW_COMPANY_ID,10


  	-----------------------------------------ID TYPE------------------------------------
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

		Begin

  ----------for commmon------------------------------------WorkWeekSetup-------------------------------------------------------------------------------------------------------------------------		
		
--INSERT INTO [Common].[WorkWeekSetUp](Id,CompanyId,WeekDay,AMFromTime,AMToTime,PMFromTime,PMToTime,WorkingHours,UserCreated,CreatedDate,ModifiedBy,ModifiedDate,Remarks,Status,IsWorkingDay,RecOrder)
--SELECT (NEWID()),@NEW_COMPANY_ID,WeekDay,AMFromTime,AMToTime,PMFromTime,PMToTime,WorkingHours,UserCreated,GETUTCDATE(),ModifiedBy,ModifiedDate,Remarks,Status,IsWorkingDay,RecOrder
--FROM [Common].[WorkWeekSetUp] WHERE COMPANYID=@UNIQUE_COMPANY_ID;	

if not exists (select * from [Common].[WorkWeekSetUp] where companyId = @NEW_COMPANY_ID)
BEGIN
	INSERT INTO [Common].[WorkWeekSetUp]([Id],[CompanyId],[WeekDay],[AMFromTime] ,[AMToTime],[PMFromTime],[PMToTime],[WorkingHours],[UserCreated],[CreatedDate],[ModifiedBy],[ModifiedDate],[Remarks],[Status],[IsWorkingDay],[RecOrder])
	VALUES(NEWID(),@NEW_COMPANY_ID,'Monday','09:00:00','13:00:00','14:00:00','18:00:00','08:00:00','System',GETUTCDATE(),null,null,null,1,1,1)

	INSERT INTO [Common].[WorkWeekSetUp]([Id],[CompanyId],[WeekDay],[AMFromTime] ,[AMToTime],[PMFromTime],[PMToTime],[WorkingHours],[UserCreated],[CreatedDate],[ModifiedBy],[ModifiedDate],[Remarks],[Status],[IsWorkingDay],[RecOrder])
	VALUES(NEWID(),@NEW_COMPANY_ID,'Tuesday','09:00:00','13:00:00','14:00:00','18:00:00','08:00:00','System',GETUTCDATE(),null,null,null,1,1,2)

	INSERT INTO [Common].[WorkWeekSetUp]([Id],[CompanyId],[WeekDay],[AMFromTime] ,[AMToTime],[PMFromTime],[PMToTime],[WorkingHours],[UserCreated],[CreatedDate],[ModifiedBy],[ModifiedDate],[Remarks],[Status],[IsWorkingDay],[RecOrder])
	VALUES(NEWID(),@NEW_COMPANY_ID,'Wednesday','09:00:00','13:00:00','14:00:00','18:00:00','08:00:00','System',GETUTCDATE(),null,null,null,1,1,3)

	INSERT INTO [Common].[WorkWeekSetUp]([Id],[CompanyId],[WeekDay],[AMFromTime] ,[AMToTime],[PMFromTime],[PMToTime],[WorkingHours],[UserCreated],[CreatedDate],[ModifiedBy],[ModifiedDate],[Remarks],[Status],[IsWorkingDay],[RecOrder])
	VALUES(NEWID(),@NEW_COMPANY_ID,'Thursday','09:00:00','13:00:00','14:00:00','18:00:00','08:00:00','System',GETUTCDATE(),null,null,null,1,1,4)

	INSERT INTO [Common].[WorkWeekSetUp]([Id],[CompanyId],[WeekDay],[AMFromTime] ,[AMToTime],[PMFromTime],[PMToTime],[WorkingHours],[UserCreated],[CreatedDate],[ModifiedBy],[ModifiedDate],[Remarks],[Status],[IsWorkingDay],[RecOrder])
	VALUES(NEWID(),@NEW_COMPANY_ID,'Friday','09:00:00','13:00:00','14:00:00','18:00:00','08:00:00','System',GETUTCDATE(),null,null,null,1,1,5)

	DECLARE @IDs UNIQUEIDENTIFIER
	SET @IDs=NEWID()
	INSERT INTO [Common].[WorkWeekSetUp]([Id],[CompanyId],[WeekDay],[AMFromTime] ,[AMToTime],[PMFromTime],[PMToTime],[WorkingHours],[UserCreated],[CreatedDate],[ModifiedBy],[ModifiedDate],[Remarks],[Status],[IsWorkingDay],[RecOrder])
	VALUES(@IDs,@NEW_COMPANY_ID,'Saturday','00:00:00','00:00:00','00:00:00','00:00:00','00:00:00','System',GETUTCDATE(),null,null,null,1,0,6)


	DECLARE @NewID UNIQUEIDENTIFIER
	SET  @NewID = NEWID()
	INSERT INTO [Common].[WorkWeekSetUp]([Id],[CompanyId],[WeekDay],[AMFromTime] ,[AMToTime],[PMFromTime],[PMToTime],[WorkingHours],[UserCreated],[CreatedDate],[ModifiedBy],[ModifiedDate],[Remarks],[Status],[IsWorkingDay],[RecOrder])
	VALUES(@NewID,@NEW_COMPANY_ID,'Sunday','00:00:00','00:00:00','00:00:00','00:00:00','00:00:00','System',GETUTCDATE(),null,null,null,1,0,7)
    
end
	End 
	
--Sp For Configuration table Nagendra

	BEGIN
   IF NOT EXISTS (SELECT * FROM [Common].[Configuration] 
                   WHERE  [CompanyId] = @NEW_COMPANY_ID)
				   Declare @Configuration_Cnt int
				   select 	@Configuration_Cnt=Count(*) from 	[Common].[Configuration] where companyid=@NEW_COMPANY_ID	
	               IF @Configuration_Cnt=0
   BEGIN   
 Insert into  [Common].[Configuration](Id, CompanyId, [Key], [Value], Formate, CreatedDate,UserCreated, ModifiedBy, ModifiedDate, Status)  
       SELECT (NEWID()),@NEW_COMPANY_ID, [Key],Value, Formate,CreatedDate,UserCreated,null,null, Status  FROM [Common].[Configuration] WHERE COMPANYID=0	     
   END
END;

	
BEGIN

EXEC [dbo].[SP_Report_Category_Report] @UNIQUE_COMPANY_ID,@CREATED_DATE,@NEW_COMPANY_ID
END
GO
