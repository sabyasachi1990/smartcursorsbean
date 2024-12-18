USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[SP_CREATE_SEED_DATA_INT]    Script Date: 16-12-2024 9.20.11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/****** Object:  StoredProcedure [dbo].[SP_UAT_CREATE_SEED_DATA]    Script Date: 17-06-2016 07:49:03 PM ******/


CREATE PROCEDURE [dbo].[SP_CREATE_SEED_DATA_INT](@UNIQUE_COMPANY_ID BIGINT,@NEW_COMPANY_ID BIGINT,@DOC_STATUS INT,@TAX_STATUS INT,@CS_STATUS INT,@KNOWLEDGE_STATUS INT,@BEAN_STATUS INT, @AUDIT_STATUS INT,@WORKFLOW_STATUS INT,@CLIENT_STATUS INT,@HR_STATUS INT)
AS
BEGIN    

	--------------PARA METERS ---------------------------------------------        
	DECLARE @STATUS   INT
	DECLARE @CREATED_DATE DATETIME	
	DECLARE @CONTROLCODECATEGORY_ID_MODULE_MASTER_ID BIGINT
	DECLARE @MODULE_MASTER_ID_CONTROLCODECATEGORY_ID BIGINT
	DECLARE @ACCOUNTYPE_ID_ID_TYPE_ID BIGINT
	DECLARE @ID_TYPE_ACCOUNTYPE_ID_ID BIGINT	
	SET @STATUS = 1    
	SET @CREATED_DATE =GETDATE()   	
	BEGIN TRANSACTION
	BEGIN TRY

		-----------------------------------------------------Create CompanyModules-----------------------------------------------

		INSERT INTO [Common].[CompanyModule] ([Id],[CompanyId], [ModuleId],[Status])
		SELECT ROW_NUMBER() OVER(ORDER BY ID) + (SELECT MAX(id) + 1 FROM [Common].[CompanyModule]), @NEW_COMPANY_ID,[ModuleId],[Status]
		FROM [Common].[CompanyModule] WHERE COMPANYID=@UNIQUE_COMPANY_ID;

		-------------------------------------------------------Create Roles And Permissions-----------------------------------------------
		--UPDATE [Auth].[Role] SET [TempId] = NULL;


		--INSERT INTO [Auth].[Role] ([Id],[CompanyId],[Name],[Remarks],[ModuleMasterId],[Status],[ModifiedBy],[ModifiedDate],[UserCreated],[CreatedDate],[IsSystem],[TempId])
		--SELECT NEWID(),@NEW_COMPANY_ID,[Name],[Remarks],[ModuleMasterId],[Status],[ModifiedBy],[ModifiedDate],[UserCreated],[CreatedDate],[IsSystem],[Id]
		--FROM [Auth].[Role] WHERE companyid = @UNIQUE_COMPANY_ID;

		--INSERT INTO [Auth].[RolePermission] ([Id],[RoleId],[ModuleDetailPermissionId])
		--SELECT NEWID(), R.Id,RP.ModuleDetailPermissionId FROM [Auth].[RolePermission] RP
		--inner join [Auth].[Role] R ON RP.RoleId = R.TempId 
		--WHERE R.CompanyId = @NEW_COMPANY_ID;

		
		IF(@CLIENT_STATUS = 2)
		BEGIN 
			--UPDATE [Auth].[Role] SET [Status] = 2 WHERE [Name] = 'CC Admin' AND [CompanyId] = @NEW_COMPANY_ID;
			UPDATE [Common].[CompanyModule] SET [Status] = 2 WHERE [ModuleId] = 1 AND [CompanyId] = @NEW_COMPANY_ID;
		END

		IF(@WORKFLOW_STATUS = 2)
		BEGIN 
			--UPDATE [Auth].[Role] SET [Status] = 2 WHERE [Name] = 'WF Admin' AND [CompanyId] = @NEW_COMPANY_ID;
			UPDATE [Common].[CompanyModule] SET [Status] = 2 WHERE [ModuleId] = 2 AND [CompanyId] = @NEW_COMPANY_ID;
		END

		IF(@AUDIT_STATUS = 2)
		BEGIN 
			--UPDATE [Auth].[Role] SET [Status] = 2 WHERE [Name] = 'AU Admin' AND [CompanyId] = @NEW_COMPANY_ID;
			UPDATE [Common].[CompanyModule] SET [Status] = 2 WHERE [ModuleId] = 3 AND [CompanyId] = @NEW_COMPANY_ID;
		END

		IF(@BEAN_STATUS = 2)
		BEGIN 
			--UPDATE [Auth].[Role] SET [Status] = 2 WHERE [Name] = 'BC Admin' AND [CompanyId] = @NEW_COMPANY_ID;
			UPDATE [Common].[CompanyModule] SET [Status] = 2 WHERE [ModuleId] = 4 AND [CompanyId] = @NEW_COMPANY_ID;
		END

		IF(@KNOWLEDGE_STATUS = 2)
		BEGIN 
			--UPDATE [Auth].[Role] SET [Status] = 2 WHERE [Name] = 'KB Admin' AND [CompanyId] = @NEW_COMPANY_ID;
			UPDATE [Common].[CompanyModule] SET [Status] = 2 WHERE [ModuleId] = 5 AND [CompanyId] = @NEW_COMPANY_ID;
		END

		IF(@DOC_STATUS = 2)
		BEGIN 
			--UPDATE [Auth].[Role] SET [Status] = 2 WHERE [Name] = 'DC Admin' AND [CompanyId] = @NEW_COMPANY_ID;
			UPDATE [Common].[CompanyModule] SET [Status] = 2 WHERE [ModuleId] = 6 AND [CompanyId] = @NEW_COMPANY_ID;
		END

		IF(@TAX_STATUS = 2)
		BEGIN 
			--UPDATE [Auth].[Role] SET [Status] = 2 WHERE [Name] = 'TX Admin' AND [CompanyId] = @NEW_COMPANY_ID;
			UPDATE [Common].[CompanyModule] SET [Status] = 2 WHERE [ModuleId] = 7 AND [CompanyId] = @NEW_COMPANY_ID;
		END

		IF(@CS_STATUS = 2)
		BEGIN 
			--UPDATE [Auth].[Role] SET [Status] = 2 WHERE [Name] = 'CS Admin' AND [CompanyId] = @NEW_COMPANY_ID;
			UPDATE [Common].[CompanyModule] SET [Status] = 2 WHERE [ModuleId] = 9 AND [CompanyId] = @NEW_COMPANY_ID;
		END

		IF(@HR_STATUS = 2)
		BEGIN 
			--UPDATE [Auth].[Role] SET [Status] = 2 WHERE [Name] = 'HR Admin' AND [CompanyId] = @NEW_COMPANY_ID;
			UPDATE [Common].[CompanyModule] SET [Status] = 2 WHERE [ModuleId] = 8 AND [CompanyId] = @NEW_COMPANY_ID;
		END

		-----------------------------------------------------Create Temp Tables-----------------------------------------------
		TRUNCATE TABLE UAT_JobRisk_Temp

  	    ---------------TRUNCATE JOB HOURS LEVEL TEMP TABLE-------------------------------
		TRUNCATE TABLE UAT_JobHoursLevel__Temp        
		
		-----------------------------------------GRID META DATA------------------------------------------------------------------------------------------
		INSERT INTO [Auth].[GridMetaData] (Id,ModuleDetailId, UserName, Url, GridMetaData, CompanyId, APIMethod, ActionURL, TableName, Class, Title, Params, Options, StreamName, ViewModelName)
			SELECT (NEWID()), ModuleDetailId, UserName, Url, GridMetaData, @NEW_COMPANY_ID, APIMethod, ActionURL, TableName, Class, Title, Params, Options, StreamName, ViewModelName  FROM 
			[Auth].[GridMetaData]  WHERE COMPANYID=@UNIQUE_COMPANY_ID;

		-------------------------------------------------EMPLOYEE RANK------------------------------------------------------
        INSERT INTO [ClientCursor].[EmployeeRank](Id, Rank, Category, RatePerHour, Designation, DefaultCategory, CompanyId,
			UserCreated, CreatedDate, ModifiedBy, ModifiedDate, Status)
			SELECT (NEWID()), Rank, Category, RatePerHour, Designation, DefaultCategory, @NEW_COMPANY_ID, UserCreated,
			@CREATED_DATE, ModifiedBy, ModifiedDate, status FROM [ClientCursor].[EmployeeRank]  WHERE COMPANYID=@UNIQUE_COMPANY_ID;

		------------------------------------------------AUTO NUMBER------------------------------------------------------
        INSERT INTO [Common].[AutoNumber] (Id, CompanyId, ModuleMasterId, EntityType, Description, Format, GeneratedNumber, CounterLength,
			MaxLength, StartNumber, Reset, Preview, IsResetbySubsidary, Status, UserCreated, CreatedDate, ModifiedBy, ModifiedDate, Variables)
			SELECT (NEWID()), @NEW_COMPANY_ID, ModuleMasterId, EntityType, Description, Format, GeneratedNumber, CounterLength, 
			MaxLength, StartNumber, Reset, Preview, IsResetbySubsidary, status, UserCreated, @CREATED_DATE, ModifiedBy, ModifiedDate, Variables 
			FROM [Common].[AutoNumber] WHERE COMPANYID=@UNIQUE_COMPANY_ID;

		-------------------------------------------------TEMPLATE------------------------------------------------------
		INSERT INTO [Common].[Template] (Id, Name, Code, CompanyId, FromEmailId, CCEmailIds, BCCEmailIds, TemplateType, TempletContent, RecOrder,
			Remarks, UserCreated, CreatedDate, ModifiedBy, ModifiedDate, Version, Status, Subject, TemplateMenu, ToEmailId, IsUnique)		    
			SELECT (NEWID()), Name, Code, @NEW_COMPANY_ID, FromEmailId, CCEmailIds, BCCEmailIds, TemplateType, TempletContent, RecOrder,
			Remarks, UserCreated, GETUTCDATE(), ModifiedBy, ModifiedDate, Version, status, Subject, TemplateMenu, ToEmailId, IsUnique
			FROM [Common].[Template] WHERE COMPANYID=@UNIQUE_COMPANY_ID AND IsUnique=@STATUS;

		----------------------------------------------------BEAN ACCOUNT TYPE AND BEAN CHART OF ACCOUNT---------------------------------------------------
		DECLARE @ACCOUNTTYPE_ID BIGINT,@NEW_aCCOUNTTYPE_ID BIGINT
		DECLARE ACCOUNT_CURSOR CURSOR FOR 
		SELECT iD FROM [Bean].[AccountType] WHERE COMPANYiD=0			
		OPEN ACCOUNT_CURSOR
		FETCH NEXT FROM ACCOUNT_CURSOR INTO @ACCOUNTTYPE_ID
		WHILE @@FETCH_STATUS=0
		BEGIN   
			SET @NEW_aCCOUNTTYPE_ID=(SELECT MAX(id) + 1 FROM [Bean].[AccountType])
								
			INSERT INTO [Bean].[AccountType] (Id, CompanyId, Name, Class, Category, SubCategory, Nature, AppliesTo, IsSystem, ShowCurrency, RecOrder,
				Remarks, UserCreated, CreatedDate, ModifiedBy, ModifiedDate, Version, Status, ShowCashflowType, ShowAllowable, ShowRevaluation, Indexs, ModuleType)
			SELECT @NEW_aCCOUNTTYPE_ID, @NEW_COMPANY_ID, Name, Class, Category, SubCategory, Nature, AppliesTo, IsSystem, ShowCurrency, RecOrder, Remarks, UserCreated, 
			@CREATED_DATE, ModifiedBy, ModifiedDate, Version, status, ShowCashflowType, ShowAllowable, ShowRevaluation, Indexs, ModuleType 
			FROM [Bean].[AccountType]  WHERE COMPANYID=0 AND ID=@ACCOUNTTYPE_ID
				   	             
			INSERT INTO   [Bean].[ChartOfAccount] (Id, CompanyId, Code, Name, AccountTypeId, Class, Category, SubCategory, Nature, Currency, ShowRevaluation, CashflowType,
			AppliesTo, IsSystem, IsShowforCOA, RecOrder, Remarks, UserCreated, CreatedDate, ModifiedBy, ModifiedDate, Version, Status, IsSubLedger, IsCodeEditable,
			ShowCurrency, ShowCashFlow, ShowAllowable, IsRevaluation, Revaluation, DisAllowable, RealisedExchangeGainOrLoss, UnrealisedExchangeGainOrLoss, ModuleType)	
			SELECT ROW_NUMBER() OVER(ORDER BY ID) + (SELECT MAX(Id) FROM [Bean].[ChartOfAccount]) AS Id, @NEW_COMPANY_ID,Code, Name, @NEW_aCCOUNTTYPE_ID, Class, Category, SubCategory,
			Nature, Currency, ShowRevaluation, CashflowType, AppliesTo, IsSystem, IsShowforCOA, RecOrder, Remarks,
            UserCreated, @CREATED_DATE, ModifiedBy, ModifiedDate, Version, status, IsSubLedger, IsCodeEditable, ShowCurrency, ShowCashFlow, ShowAllowable, IsRevaluation, Revaluation, 
            DisAllowable, RealisedExchangeGainOrLoss, UnrealisedExchangeGainOrLoss, ModuleType FROM [Bean].[ChartOfAccount] WHERE COMPANYID=0 AND AccountTypeId = @ACCOUNTTYPE_ID
			FETCH NEXT FROM ACCOUNT_CURSOR INTO @ACCOUNTTYPE_ID
		END	
		CLOSE ACCOUNT_CURSOR
		Deallocate ACCOUNT_CURSOR				

		------------------------------------------------------CURRENCY ------------------------------------------------------------------------
        INSERT INTO  [Bean].[Currency] (Id, Code, CompanyId, Name, RecOrder, Status, UserCreated, CreatedDate, ModifiedBy, ModifiedDate, DefaultValue)
			SELECT ROW_NUMBER() OVER(ORDER BY ID) + (SELECT MAX(id) + @STATUS FROM [Bean].[Currency]), Code, @NEW_COMPANY_ID, Name, RecOrder, STATUS,
			UserCreated, @CREATED_DATE, ModifiedBy, ModifiedDate, DefaultValue FROM [Bean].[Currency] WHERE COMPANYID=@UNIQUE_COMPANY_ID;		  
		   
		------------------------------------------------------LOCALIZATION  ------------------------------------------------------------------------
		INSERT INTO [Common].[Localization] (Id, CompanyId, LongDateFormat, ShortDateFormat, TimeFormat, BaseCurrency, BusinessYearEnd, Status,
			UserCreated, CreatedDate, ModifiedBy, ModifiedDate, TimeZone)
			SELECT ROW_NUMBER() OVER(ORDER BY ID) + (SELECT MAX(id) + @STATUS FROM [Common].[Localization]), @NEW_COMPANY_ID, LongDateFormat, ShortDateFormat,
			TimeFormat, BaseCurrency, BusinessYearEnd, status, UserCreated, @CREATED_DATE, ModifiedBy, ModifiedDate, TimeZone FROM [Common].[Localization]
			WHERE COMPANYID=(SELECT MAX(COMPANYID) FROM [Common].[Localization]);

		------------------------------------------------------COMPANY SETTING  ------------------------------------------------------------------------
		INSERT INTO [Common].[CompanySetting] (Id, CompanyId, CursorName, ModuleName, UserCreated, CreatedDate, ModifiedBy, ModifiedDate, IsEnabled)
			SELECT ROW_NUMBER() OVER(ORDER BY ID) + (SELECT MAX(id) + @STATUS FROM [Common].[CompanySetting]), @NEW_COMPANY_ID, CursorName, ModuleName, UserCreated,
			@CREATED_DATE, ModifiedBy, ModifiedDate, IsEnabled FROM [Common].[CompanySetting] WHERE COMPANYID=@UNIQUE_COMPANY_ID;  		  
		
		------------------------------------------------------------CONTROL CODE ------------------------------------------------------
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
				GETDATE(), ModifiedBy, ModifiedDate, Version, status, ModuleNamesUsing, DefaultValue FROM [Common].[ControlCodeCategory] WHERE ID=@CONTROL_ID
			INSERT INTO [Common].[ControlCode] (Id, ControlCategoryId, CodeKey, CodeValue, IsSystem, RecOrder, Remarks, UserCreated, CreatedDate, 
				ModifiedBy, ModifiedDate, Version, Status, IsDefault)
			SELECT ROW_NUMBER() OVER(ORDER BY a.ID) + (SELECT MAX(Id) + 1 FROM [Common].[ControlCode]) AS Id,@NEW_CONTROL_ID, a.CodeKey, a.CodeValue,
				a.IsSystem, a.RecOrder, a.Remarks, a.UserCreated, GETDATE(), a.ModifiedBy,a.ModifiedDate, a.Version, a.Status, a.IsDefault 
				from  [Common].[ControlCode] a join [Common].[ControlCodeCategory] b on a.controlcategoryid=b.id where b.companyid=0 
				and a.controlcategoryid=@CONTROL_ID
							  			
			FETCH NEXT FROM CONTROL_CURSOR INTO @CONTROL_ID
		END	
		close CONTROL_CURSOR
		Deallocate CONTROL_CURSOR
		
		-------------------------------------------------------------JOB TYPE-----------------------------------------------------------------------------------------
		INSERT INTO [ClientCursor].[JobType]  (Id, JobType, Description, CompanyId, UserCreated, CreatedDate, ModifiedBy, ModifiedDate, Status)
			SELECT (NEWID()), JobType, Description, @NEW_COMPANY_ID, UserCreated, GETDATE(), ModifiedBy, ModifiedDate, status FROM [ClientCursor].[JobType] 
			WHERE CompanyId=@UNIQUE_COMPANY_ID;	   
		                                 
		------------------------------------------------------CURSOR FOR FILLING JOB HOURS LEVEL AND JOB RISK -----------------------------------------------------------
		DECLARE @Id UNIQUEIDENTIFIER,@JOB_TYPE VARCHAR(100),@DESCRIPTION VARCHAR(2000)
		DECLARE INSERT_CURSOR CURSOR FOR 
		SELECT  Id,JobType,Description FROM  [ClientCursor].[JobType] WHERE CompanyId=@NEW_COMPANY_ID  ORDER BY jobtype,Description
		OPEN INSERT_CURSOR
		FETCH NEXT FROM INSERT_CURSOR INTO @Id,@JOB_TYPE,@DESCRIPTION
		WHILE @@FETCH_STATUS=0
		BEGIN   
			INSERT INTO UAT_JobHoursLevel__Temp ( JobTypeId, Hours, Level, UserCreated,  ModifiedBy, ModifiedDate, Status)
			SELECT DISTINCT @Id,b.Hours , b.Level, b.UserCreated,  b.ModifiedBy, b.ModifiedDate, b.status FROM [ClientCursor].[JobType] a join [ClientCursor].[JobHoursLevel] b  ON  
				a.id=b.JobTypeId WHERE a.CompanyId=@UNIQUE_COMPANY_ID  AND a.JobType=@JOB_TYPE AND a.Description=@DESCRIPTION
			INSERT INTO UAT_JobRisk_Temp (JobTypeId, Risk, RiskPartner, RiskManager, RiskSenior, RiskSeniorAssociate, RiskJuniorAssociate, VolPartner, 
				VolManager, VolSenior, VolSeniorAssociate, VolJuniorAssociate, UserCreated,  ModifiedBy, ModifiedDate, Status)
			SELECT  DISTINCT @Id, b.Risk, b.RiskPartner, b.RiskManager, b.RiskSenior,b.RiskSeniorAssociate, b.RiskJuniorAssociate, b.VolPartner, b.VolManager, b.VolSenior, 
				b.VolSeniorAssociate, b.VolJuniorAssociate, b.UserCreated,  b.ModifiedBy, b.ModifiedDate, b.status FROM [ClientCursor].[JobType] a join [ClientCursor].[JobRisk] b  ON  
				a.id=b.JobTypeId WHERE a.CompanyId=@UNIQUE_COMPANY_ID  AND a.JobType=@JOB_TYPE AND a.Description=@DESCRIPTION 
		FETCH NEXT FROM INSERT_CURSOR INTO @Id,@JOB_TYPE,@DESCRIPTION
		END								
		close INSERT_CURSOR
		Deallocate INSERT_CURSOR

        ---------------------------------------------------------------------JOB HOURS LEVEL -------------------------------------------------------------------
		INSERT INTO [ClientCursor].[JobRisk]  (Id, JobTypeId, Risk, RiskPartner, RiskManager, RiskSenior, RiskSeniorAssociate, RiskJuniorAssociate, VolPartner, 
			VolManager, VolSenior, VolSeniorAssociate, VolJuniorAssociate, UserCreated, CreatedDate, ModifiedBy, ModifiedDate, Status)
			SELECT (NEWID()), JobTypeId, Risk, RiskPartner, RiskManager, RiskSenior, RiskSeniorAssociate, RiskJuniorAssociate, VolPartner, 
			VolManager, VolSenior, VolSeniorAssociate, VolJuniorAssociate, UserCreated, GETDATE(), ModifiedBy, ModifiedDate,status FROM UAT_JobRisk_Temp; 
				TRUNCATE TABLE UAT_JobRisk_Temp

		 ---------------------------------------------------------------------JOB RISK -------------------------------------------------------------------
		INSERT INTO [ClientCursor].[JobHoursLevel] (Id, JobTypeId, Hours, Level, UserCreated, CreatedDate, ModifiedBy, ModifiedDate, Status)
			SELECT (NEWID()), JobTypeId, Hours, Level, UserCreated, GETDATE(), ModifiedBy, ModifiedDate, status FROM UAT_JobHoursLevel__Temp ;
			TRUNCATE TABLE UAT_JobHoursLevel__Temp;


			
		 ----------------------------------------------------------------------CONTROL CODE CATEGORY MODULE------------------------------------------------------
       	SET @CONTROLCODECATEGORY_ID_MODULE_MASTER_ID = (SELECT top 1 ID FROM [Common].[ControlCodeCategory] WHERE COMPANYID=@NEW_COMPANY_ID AND CONTROLCODECATEGORYCODE='Fee Type')
		SET @MODULE_MASTER_ID_CONTROLCODECATEGORY_ID = (SELECT Id FROM [Common].[ModuleMaster]  WHERE COMPANYID=@UNIQUE_COMPANY_ID AND NAME='Client Cursor')
		INSERT INTO [Common].[ControlCodeCategoryModule] (Id, CompanyId, ControlCategoryId, ModuleMasterId) VALUES ((SELECT MAX(Id) + 1 FROM [Common].[ControlCodeCategoryModule]),
		@NEW_COMPANY_ID,@CONTROLCODECATEGORY_ID_MODULE_MASTER_ID,@MODULE_MASTER_ID_CONTROLCODECATEGORY_ID);

		SET @CONTROLCODECATEGORY_ID_MODULE_MASTER_ID = (SELECT top 1 ID FROM [Common].[ControlCodeCategory] WHERE COMPANYID=@NEW_COMPANY_ID AND CONTROLCODECATEGORYCODE='CommunicationType')
		SET @MODULE_MASTER_ID_CONTROLCODECATEGORY_ID = (SELECT Id FROM [Common].[ModuleMaster]  WHERE COMPANYID=@UNIQUE_COMPANY_ID AND NAME='Client Cursor')
		INSERT INTO [Common].[ControlCodeCategoryModule] (Id, CompanyId, ControlCategoryId, ModuleMasterId) VALUES ((SELECT MAX(Id) + 1 FROM [Common].[ControlCodeCategoryModule]),
		@NEW_COMPANY_ID,@CONTROLCODECATEGORY_ID_MODULE_MASTER_ID,@MODULE_MASTER_ID_CONTROLCODECATEGORY_ID);

		SET @CONTROLCODECATEGORY_ID_MODULE_MASTER_ID = (SELECT top 1 ID FROM [Common].[ControlCodeCategory] WHERE COMPANYID=@NEW_COMPANY_ID AND CONTROLCODECATEGORYCODE='Matters')
		SET @MODULE_MASTER_ID_CONTROLCODECATEGORY_ID = (SELECT top 1  Id FROM [Common].[ModuleMaster]  WHERE COMPANYID=@UNIQUE_COMPANY_ID AND NAME='Client Cursor')
		INSERT INTO [Common].[ControlCodeCategoryModule] (Id, CompanyId, ControlCategoryId, ModuleMasterId) VALUES ((SELECT MAX(Id) + 1 FROM [Common].[ControlCodeCategoryModule]),
		@NEW_COMPANY_ID,@CONTROLCODECATEGORY_ID_MODULE_MASTER_ID,@MODULE_MASTER_ID_CONTROLCODECATEGORY_ID);
				
		SET @CONTROLCODECATEGORY_ID_MODULE_MASTER_ID = (SELECT top 1 ID FROM [Common].[ControlCodeCategory] WHERE COMPANYID=@NEW_COMPANY_ID AND CONTROLCODECATEGORYCODE='Source')
		SET @MODULE_MASTER_ID_CONTROLCODECATEGORY_ID = (SELECT top 1 Id FROM [Common].[ModuleMaster]  WHERE COMPANYID=@UNIQUE_COMPANY_ID AND NAME='Client Cursor')
		INSERT INTO [Common].[ControlCodeCategoryModule] (Id, CompanyId, ControlCategoryId, ModuleMasterId) VALUES ((SELECT MAX(Id) + 1 FROM [Common].[ControlCodeCategoryModule]),
		@NEW_COMPANY_ID,@CONTROLCODECATEGORY_ID_MODULE_MASTER_ID,@MODULE_MASTER_ID_CONTROLCODECATEGORY_ID);
				
		SET @CONTROLCODECATEGORY_ID_MODULE_MASTER_ID = (SELECT top 1 ID FROM [Common].[ControlCodeCategory] WHERE COMPANYID=@NEW_COMPANY_ID AND CONTROLCODECATEGORYCODE='Lead Status')
		SET @MODULE_MASTER_ID_CONTROLCODECATEGORY_ID = (SELECT top 1 Id FROM [Common].[ModuleMaster]  WHERE COMPANYID=@UNIQUE_COMPANY_ID AND NAME='Client Cursor')
		INSERT INTO [Common].[ControlCodeCategoryModule] (Id, CompanyId, ControlCategoryId, ModuleMasterId) VALUES ((SELECT MAX(Id) + 1 FROM [Common].[ControlCodeCategoryModule]),
		@NEW_COMPANY_ID,@CONTROLCODECATEGORY_ID_MODULE_MASTER_ID,@MODULE_MASTER_ID_CONTROLCODECATEGORY_ID);

		SET @CONTROLCODECATEGORY_ID_MODULE_MASTER_ID = (SELECT top 1 ID FROM [Common].[ControlCodeCategory] WHERE COMPANYID=@NEW_COMPANY_ID AND CONTROLCODECATEGORYCODE='Salutation')
		SET @MODULE_MASTER_ID_CONTROLCODECATEGORY_ID = (SELECT top 1 Id FROM [Common].[ModuleMaster]  WHERE COMPANYID=@UNIQUE_COMPANY_ID AND NAME='Client Cursor')
		INSERT INTO [Common].[ControlCodeCategoryModule] (Id, CompanyId, ControlCategoryId, ModuleMasterId) VALUES ((SELECT MAX(Id) + 1 FROM [Common].[ControlCodeCategoryModule]),
		@NEW_COMPANY_ID,@CONTROLCODECATEGORY_ID_MODULE_MASTER_ID,@MODULE_MASTER_ID_CONTROLCODECATEGORY_ID);

		SET @CONTROLCODECATEGORY_ID_MODULE_MASTER_ID = (SELECT top 1 ID FROM [Common].[ControlCodeCategory] WHERE COMPANYID=@NEW_COMPANY_ID AND CONTROLCODECATEGORYCODE='Campaign Type')
		SET @MODULE_MASTER_ID_CONTROLCODECATEGORY_ID = (SELECT top 1 Id FROM [Common].[ModuleMaster]  WHERE COMPANYID=@UNIQUE_COMPANY_ID AND NAME='Client Cursor')
		INSERT INTO [Common].[ControlCodeCategoryModule] (Id, CompanyId, ControlCategoryId, ModuleMasterId) VALUES ((SELECT MAX(Id) + 1 FROM [Common].[ControlCodeCategoryModule]),
		@NEW_COMPANY_ID,@CONTROLCODECATEGORY_ID_MODULE_MASTER_ID,@MODULE_MASTER_ID_CONTROLCODECATEGORY_ID);
				
		SET @CONTROLCODECATEGORY_ID_MODULE_MASTER_ID = (SELECT top 1 ID FROM [Common].[ControlCodeCategory] WHERE COMPANYID=@NEW_COMPANY_ID AND CONTROLCODECATEGORYCODE='Campaign Status')
		SET @MODULE_MASTER_ID_CONTROLCODECATEGORY_ID = (SELECT top 1 Id FROM [Common].[ModuleMaster]  WHERE COMPANYID=@UNIQUE_COMPANY_ID AND NAME='Client Cursor')
		INSERT INTO [Common].[ControlCodeCategoryModule] (Id, CompanyId, ControlCategoryId, ModuleMasterId) VALUES ((SELECT MAX(Id) + 1 FROM [Common].[ControlCodeCategoryModule]),
		@NEW_COMPANY_ID,@CONTROLCODECATEGORY_ID_MODULE_MASTER_ID,@MODULE_MASTER_ID_CONTROLCODECATEGORY_ID);
				
		SET @CONTROLCODECATEGORY_ID_MODULE_MASTER_ID = (SELECT top 1 ID FROM [Common].[ControlCodeCategory] WHERE COMPANYID=@NEW_COMPANY_ID AND CONTROLCODECATEGORYCODE='Opportunity Type')
		SET @MODULE_MASTER_ID_CONTROLCODECATEGORY_ID = (SELECT Id FROM [Common].[ModuleMaster]  WHERE COMPANYID=@UNIQUE_COMPANY_ID AND NAME='Client Cursor')
		INSERT INTO [Common].[ControlCodeCategoryModule] (Id, CompanyId, ControlCategoryId, ModuleMasterId) VALUES ((SELECT MAX(Id) + 1 FROM [Common].[ControlCodeCategoryModule]),
		@NEW_COMPANY_ID,@CONTROLCODECATEGORY_ID_MODULE_MASTER_ID,@MODULE_MASTER_ID_CONTROLCODECATEGORY_ID);
				
		SET @CONTROLCODECATEGORY_ID_MODULE_MASTER_ID = (SELECT top 1 ID FROM [Common].[ControlCodeCategory] WHERE COMPANYID=@NEW_COMPANY_ID AND CONTROLCODECATEGORYCODE='Service Nature')
		SET @MODULE_MASTER_ID_CONTROLCODECATEGORY_ID = (SELECT Id FROM [Common].[ModuleMaster]  WHERE COMPANYID=@UNIQUE_COMPANY_ID AND NAME='Client Cursor')
		INSERT INTO [Common].[ControlCodeCategoryModule] (Id, CompanyId, ControlCategoryId, ModuleMasterId) VALUES ((SELECT MAX(Id) + 1 FROM [Common].[ControlCodeCategoryModule]),
		@NEW_COMPANY_ID,@CONTROLCODECATEGORY_ID_MODULE_MASTER_ID,@MODULE_MASTER_ID_CONTROLCODECATEGORY_ID);
				
		SET @CONTROLCODECATEGORY_ID_MODULE_MASTER_ID = (SELECT top 1 ID FROM [Common].[ControlCodeCategory] WHERE COMPANYID=@NEW_COMPANY_ID AND CONTROLCODECATEGORYCODE='Frequency')
		SET @MODULE_MASTER_ID_CONTROLCODECATEGORY_ID = (SELECT Id FROM [Common].[ModuleMaster]  WHERE COMPANYID=@UNIQUE_COMPANY_ID AND NAME='Client Cursor')
		INSERT INTO [Common].[ControlCodeCategoryModule] (Id, CompanyId, ControlCategoryId, ModuleMasterId) VALUES ((SELECT MAX(Id) + 1 FROM [Common].[ControlCodeCategoryModule]),
		@NEW_COMPANY_ID,@CONTROLCODECATEGORY_ID_MODULE_MASTER_ID,@MODULE_MASTER_ID_CONTROLCODECATEGORY_ID);
				
		SET @CONTROLCODECATEGORY_ID_MODULE_MASTER_ID = (SELECT top 1 ID FROM [Common].[ControlCodeCategory] WHERE COMPANYID=@NEW_COMPANY_ID AND CONTROLCODECATEGORYCODE='Designation')
		SET @MODULE_MASTER_ID_CONTROLCODECATEGORY_ID = (SELECT Id FROM [Common].[ModuleMaster]  WHERE COMPANYID=@UNIQUE_COMPANY_ID AND NAME='Client Cursor')
		INSERT INTO [Common].[ControlCodeCategoryModule] (Id, CompanyId, ControlCategoryId, ModuleMasterId) VALUES ((SELECT MAX(Id) + 1 FROM [Common].[ControlCodeCategoryModule]),
		@NEW_COMPANY_ID,@CONTROLCODECATEGORY_ID_MODULE_MASTER_ID,@MODULE_MASTER_ID_CONTROLCODECATEGORY_ID);

		SET @CONTROLCODECATEGORY_ID_MODULE_MASTER_ID = (SELECT top 1 ID FROM [Common].[ControlCodeCategory] WHERE COMPANYID=@NEW_COMPANY_ID AND CONTROLCODECATEGORYCODE='LeadCategory')
		SET @MODULE_MASTER_ID_CONTROLCODECATEGORY_ID = (SELECT Id FROM [Common].[ModuleMaster]  WHERE COMPANYID=@UNIQUE_COMPANY_ID AND NAME='Client Cursor')
		INSERT INTO [Common].[ControlCodeCategoryModule] (Id, CompanyId, ControlCategoryId, ModuleMasterId) VALUES ((SELECT MAX(Id) + 1 FROM [Common].[ControlCodeCategoryModule]),
		@NEW_COMPANY_ID,@CONTROLCODECATEGORY_ID_MODULE_MASTER_ID,@MODULE_MASTER_ID_CONTROLCODECATEGORY_ID);

		SET @CONTROLCODECATEGORY_ID_MODULE_MASTER_ID = (SELECT top 1 ID FROM [Common].[ControlCodeCategory] WHERE COMPANYID=@NEW_COMPANY_ID AND CONTROLCODECATEGORYCODE='Fee Type')
		SET @MODULE_MASTER_ID_CONTROLCODECATEGORY_ID = (SELECT Id FROM [Common].[ModuleMaster]  WHERE COMPANYID=@UNIQUE_COMPANY_ID AND NAME='Bean Cursor')
		INSERT INTO [Common].[ControlCodeCategoryModule] (Id, CompanyId, ControlCategoryId, ModuleMasterId) VALUES ((SELECT MAX(Id) + 1 FROM [Common].[ControlCodeCategoryModule]),
		@NEW_COMPANY_ID,@CONTROLCODECATEGORY_ID_MODULE_MASTER_ID,@MODULE_MASTER_ID_CONTROLCODECATEGORY_ID);

		SET @CONTROLCODECATEGORY_ID_MODULE_MASTER_ID = (SELECT top 1 ID FROM [Common].[ControlCodeCategory] WHERE COMPANYID=@NEW_COMPANY_ID AND CONTROLCODECATEGORYCODE='CommunicationType')
		SET @MODULE_MASTER_ID_CONTROLCODECATEGORY_ID = (SELECT Id FROM [Common].[ModuleMaster]  WHERE COMPANYID=@UNIQUE_COMPANY_ID AND NAME='Bean Cursor')
		INSERT INTO [Common].[ControlCodeCategoryModule] (Id, CompanyId, ControlCategoryId, ModuleMasterId) VALUES ((SELECT MAX(Id) + 1 FROM [Common].[ControlCodeCategoryModule]),
		@NEW_COMPANY_ID,@CONTROLCODECATEGORY_ID_MODULE_MASTER_ID,@MODULE_MASTER_ID_CONTROLCODECATEGORY_ID);

		SET @CONTROLCODECATEGORY_ID_MODULE_MASTER_ID = (SELECT top 1 ID FROM [Common].[ControlCodeCategory] WHERE COMPANYID=@NEW_COMPANY_ID AND CONTROLCODECATEGORYCODE='Cashflow Type')
		SET @MODULE_MASTER_ID_CONTROLCODECATEGORY_ID = (SELECT Id FROM [Common].[ModuleMaster]  WHERE COMPANYID=@UNIQUE_COMPANY_ID AND NAME='Bean Cursor')
		INSERT INTO [Common].[ControlCodeCategoryModule] (Id, CompanyId, ControlCategoryId, ModuleMasterId) VALUES ((SELECT MAX(Id) + 1 FROM [Common].[ControlCodeCategoryModule]),
		@NEW_COMPANY_ID,@CONTROLCODECATEGORY_ID_MODULE_MASTER_ID,@MODULE_MASTER_ID_CONTROLCODECATEGORY_ID);

		SET @CONTROLCODECATEGORY_ID_MODULE_MASTER_ID = (SELECT top 1 ID FROM [Common].[ControlCodeCategory] WHERE COMPANYID=@NEW_COMPANY_ID AND CONTROLCODECATEGORYCODE='AllowableNonalowabl')
		SET @MODULE_MASTER_ID_CONTROLCODECATEGORY_ID = (SELECT Id FROM [Common].[ModuleMaster]  WHERE COMPANYID=@UNIQUE_COMPANY_ID AND NAME='Bean Cursor')
		INSERT INTO [Common].[ControlCodeCategoryModule] (Id, CompanyId, ControlCategoryId, ModuleMasterId) VALUES ((SELECT MAX(Id) + 1 FROM [Common].[ControlCodeCategoryModule]),
		@NEW_COMPANY_ID,@CONTROLCODECATEGORY_ID_MODULE_MASTER_ID,@MODULE_MASTER_ID_CONTROLCODECATEGORY_ID);

		SET @CONTROLCODECATEGORY_ID_MODULE_MASTER_ID = (SELECT top 1 ID FROM [Common].[ControlCodeCategory] WHERE COMPANYID=@NEW_COMPANY_ID AND CONTROLCODECATEGORYCODE='Tax Type')
		SET @MODULE_MASTER_ID_CONTROLCODECATEGORY_ID = (SELECT Id FROM [Common].[ModuleMaster]  WHERE COMPANYID=@UNIQUE_COMPANY_ID AND NAME='Bean Cursor')
		INSERT INTO [Common].[ControlCodeCategoryModule] (Id, CompanyId, ControlCategoryId, ModuleMasterId) VALUES ((SELECT MAX(Id) + 1 FROM [Common].[ControlCodeCategoryModule]),
		@NEW_COMPANY_ID,@CONTROLCODECATEGORY_ID_MODULE_MASTER_ID,@MODULE_MASTER_ID_CONTROLCODECATEGORY_ID);

		SET @CONTROLCODECATEGORY_ID_MODULE_MASTER_ID = (SELECT top 1 ID FROM [Common].[ControlCodeCategory] WHERE COMPANYID=@NEW_COMPANY_ID AND CONTROLCODECATEGORYCODE='AppliesTo')
		SET @MODULE_MASTER_ID_CONTROLCODECATEGORY_ID = (SELECT Id FROM [Common].[ModuleMaster]  WHERE COMPANYID=@UNIQUE_COMPANY_ID AND NAME='Bean Cursor')
		INSERT INTO [Common].[ControlCodeCategoryModule] (Id, CompanyId, ControlCategoryId, ModuleMasterId) VALUES ((SELECT MAX(Id) + 1 FROM [Common].[ControlCodeCategoryModule]),
		@NEW_COMPANY_ID,@CONTROLCODECATEGORY_ID_MODULE_MASTER_ID,@MODULE_MASTER_ID_CONTROLCODECATEGORY_ID);

		SET @CONTROLCODECATEGORY_ID_MODULE_MASTER_ID = (SELECT top 1 ID FROM [Common].[ControlCodeCategory] WHERE COMPANYID=@NEW_COMPANY_ID AND CONTROLCODECATEGORYCODE='Units')
		SET @MODULE_MASTER_ID_CONTROLCODECATEGORY_ID = (SELECT Id FROM [Common].[ModuleMaster]  WHERE COMPANYID=@UNIQUE_COMPANY_ID AND NAME='Bean Cursor')
		INSERT INTO [Common].[ControlCodeCategoryModule] (Id, CompanyId, ControlCategoryId, ModuleMasterId) VALUES ((SELECT MAX(Id) + 1 FROM [Common].[ControlCodeCategoryModule]),
		@NEW_COMPANY_ID,@CONTROLCODECATEGORY_ID_MODULE_MASTER_ID,@MODULE_MASTER_ID_CONTROLCODECATEGORY_ID);

		SET @CONTROLCODECATEGORY_ID_MODULE_MASTER_ID = (SELECT top 1 ID FROM [Common].[ControlCodeCategory] WHERE COMPANYID=@NEW_COMPANY_ID AND CONTROLCODECATEGORYCODE='Nature')
		SET @MODULE_MASTER_ID_CONTROLCODECATEGORY_ID = (SELECT Id FROM [Common].[ModuleMaster]  WHERE COMPANYID=@UNIQUE_COMPANY_ID AND NAME='Bean Cursor')
		INSERT INTO [Common].[ControlCodeCategoryModule] (Id, CompanyId, ControlCategoryId, ModuleMasterId) VALUES ((SELECT MAX(Id) + 1 FROM [Common].[ControlCodeCategoryModule]),
		@NEW_COMPANY_ID,@CONTROLCODECATEGORY_ID_MODULE_MASTER_ID,@MODULE_MASTER_ID_CONTROLCODECATEGORY_ID);
	          			
		SET @CONTROLCODECATEGORY_ID_MODULE_MASTER_ID = (SELECT top 1 ID FROM [Common].[ControlCodeCategory] WHERE COMPANYID=@NEW_COMPANY_ID AND CONTROLCODECATEGORYCODE='Fee Type')
		SET @MODULE_MASTER_ID_CONTROLCODECATEGORY_ID = (SELECT Id FROM [Common].[ModuleMaster]  WHERE COMPANYID=@UNIQUE_COMPANY_ID AND NAME='Admin Cursor')
		INSERT INTO [Common].[ControlCodeCategoryModule] (Id, CompanyId, ControlCategoryId, ModuleMasterId) VALUES ((SELECT MAX(Id) + 1 FROM [Common].[ControlCodeCategoryModule]),
		@NEW_COMPANY_ID,@CONTROLCODECATEGORY_ID_MODULE_MASTER_ID,@MODULE_MASTER_ID_CONTROLCODECATEGORY_ID);

		SET @CONTROLCODECATEGORY_ID_MODULE_MASTER_ID = (SELECT top 1 ID FROM [Common].[ControlCodeCategory] WHERE COMPANYID=@NEW_COMPANY_ID AND CONTROLCODECATEGORYCODE='CommunicationType')
		SET @MODULE_MASTER_ID_CONTROLCODECATEGORY_ID = (SELECT Id FROM [Common].[ModuleMaster]  WHERE COMPANYID=@UNIQUE_COMPANY_ID AND NAME='Admin Cursor')
		INSERT INTO [Common].[ControlCodeCategoryModule] (Id, CompanyId, ControlCategoryId, ModuleMasterId) VALUES ((SELECT MAX(Id) + 1 FROM [Common].[ControlCodeCategoryModule]),
		@NEW_COMPANY_ID,@CONTROLCODECATEGORY_ID_MODULE_MASTER_ID,@MODULE_MASTER_ID_CONTROLCODECATEGORY_ID);

		SET @CONTROLCODECATEGORY_ID_MODULE_MASTER_ID = (SELECT top 1 ID FROM [Common].[ControlCodeCategory] WHERE COMPANYID=@NEW_COMPANY_ID AND CONTROLCODECATEGORYCODE='Long date Format')
		SET @MODULE_MASTER_ID_CONTROLCODECATEGORY_ID = (SELECT Id FROM [Common].[ModuleMaster]  WHERE COMPANYID=@UNIQUE_COMPANY_ID AND NAME='Admin Cursor')
		INSERT INTO [Common].[ControlCodeCategoryModule] (Id, CompanyId, ControlCategoryId, ModuleMasterId) VALUES ((SELECT MAX(Id) + 1 FROM [Common].[ControlCodeCategoryModule]),
		@NEW_COMPANY_ID,@CONTROLCODECATEGORY_ID_MODULE_MASTER_ID,@MODULE_MASTER_ID_CONTROLCODECATEGORY_ID);

		SET @CONTROLCODECATEGORY_ID_MODULE_MASTER_ID = (SELECT top 1 ID FROM [Common].[ControlCodeCategory] WHERE COMPANYID=@NEW_COMPANY_ID AND CONTROLCODECATEGORYCODE='Short date Format')
		SET @MODULE_MASTER_ID_CONTROLCODECATEGORY_ID = (SELECT Id FROM [Common].[ModuleMaster]  WHERE COMPANYID=@UNIQUE_COMPANY_ID AND NAME='Admin Cursor')
		INSERT INTO [Common].[ControlCodeCategoryModule] (Id, CompanyId, ControlCategoryId, ModuleMasterId) VALUES ((SELECT MAX(Id) + 1 FROM [Common].[ControlCodeCategoryModule]),
		@NEW_COMPANY_ID,@CONTROLCODECATEGORY_ID_MODULE_MASTER_ID,@MODULE_MASTER_ID_CONTROLCODECATEGORY_ID);

		SET @CONTROLCODECATEGORY_ID_MODULE_MASTER_ID = (SELECT top 1 ID FROM [Common].[ControlCodeCategory] WHERE COMPANYID=@NEW_COMPANY_ID AND CONTROLCODECATEGORYCODE='Time Format')
		SET @MODULE_MASTER_ID_CONTROLCODECATEGORY_ID = (SELECT Id FROM [Common].[ModuleMaster]  WHERE COMPANYID=@UNIQUE_COMPANY_ID AND NAME='Admin Cursor')
		INSERT INTO [Common].[ControlCodeCategoryModule] (Id, CompanyId, ControlCategoryId, ModuleMasterId) VALUES ((SELECT MAX(Id) + 1 FROM [Common].[ControlCodeCategoryModule]),
		@NEW_COMPANY_ID,@CONTROLCODECATEGORY_ID_MODULE_MASTER_ID,@MODULE_MASTER_ID_CONTROLCODECATEGORY_ID);

		SET @CONTROLCODECATEGORY_ID_MODULE_MASTER_ID = (SELECT top 1 ID FROM [Common].[ControlCodeCategory] WHERE COMPANYID=@NEW_COMPANY_ID AND CONTROLCODECATEGORYCODE='Time Zone')
		SET @MODULE_MASTER_ID_CONTROLCODECATEGORY_ID = (SELECT Id FROM [Common].[ModuleMaster]  WHERE COMPANYID=@UNIQUE_COMPANY_ID AND NAME='Admin Cursor')
		INSERT INTO [Common].[ControlCodeCategoryModule] (Id, CompanyId, ControlCategoryId, ModuleMasterId) VALUES ((SELECT MAX(Id) + 1 FROM [Common].[ControlCodeCategoryModule]),
		@NEW_COMPANY_ID,@CONTROLCODECATEGORY_ID_MODULE_MASTER_ID,@MODULE_MASTER_ID_CONTROLCODECATEGORY_ID);

		SET @CONTROLCODECATEGORY_ID_MODULE_MASTER_ID = (SELECT top 1 ID FROM [Common].[ControlCodeCategory] WHERE COMPANYID=@NEW_COMPANY_ID AND CONTROLCODECATEGORYCODE='AutoNumber Type')
		SET @MODULE_MASTER_ID_CONTROLCODECATEGORY_ID = (SELECT Id FROM [Common].[ModuleMaster]  WHERE COMPANYID=@UNIQUE_COMPANY_ID AND NAME='Admin Cursor')
		INSERT INTO [Common].[ControlCodeCategoryModule] (Id, CompanyId, ControlCategoryId, ModuleMasterId) VALUES ((SELECT MAX(Id) + 1 FROM [Common].[ControlCodeCategoryModule]),
		@NEW_COMPANY_ID,@CONTROLCODECATEGORY_ID_MODULE_MASTER_ID,@MODULE_MASTER_ID_CONTROLCODECATEGORY_ID);

		SET @CONTROLCODECATEGORY_ID_MODULE_MASTER_ID = (SELECT top 1 ID FROM [Common].[ControlCodeCategory] WHERE COMPANYID=@NEW_COMPANY_ID AND CONTROLCODECATEGORYCODE='Designation')
		SET @MODULE_MASTER_ID_CONTROLCODECATEGORY_ID = (SELECT Id FROM [Common].[ModuleMaster]  WHERE COMPANYID=@UNIQUE_COMPANY_ID AND NAME='Admin Cursor')
		INSERT INTO [Common].[ControlCodeCategoryModule] (Id, CompanyId, ControlCategoryId, ModuleMasterId) VALUES ((SELECT MAX(Id) + 1 FROM [Common].[ControlCodeCategoryModule]),
		@NEW_COMPANY_ID,@CONTROLCODECATEGORY_ID_MODULE_MASTER_ID,@MODULE_MASTER_ID_CONTROLCODECATEGORY_ID);

		SET @CONTROLCODECATEGORY_ID_MODULE_MASTER_ID = (SELECT top 1 ID FROM [Common].[ControlCodeCategory] WHERE COMPANYID=@NEW_COMPANY_ID AND CONTROLCODECATEGORYCODE='AutoNumberTypes')
		SET @MODULE_MASTER_ID_CONTROLCODECATEGORY_ID = (SELECT Id FROM [Common].[ModuleMaster]  WHERE COMPANYID=@UNIQUE_COMPANY_ID AND NAME='Admin Cursor')
		INSERT INTO [Common].[ControlCodeCategoryModule] (Id, CompanyId, ControlCategoryId, ModuleMasterId) VALUES ((SELECT MAX(Id) + 1 FROM [Common].[ControlCodeCategoryModule]),
		@NEW_COMPANY_ID,@CONTROLCODECATEGORY_ID_MODULE_MASTER_ID,@MODULE_MASTER_ID_CONTROLCODECATEGORY_ID);

		SET @CONTROLCODECATEGORY_ID_MODULE_MASTER_ID = (SELECT top 1 ID FROM [Common].[ControlCodeCategory] WHERE COMPANYID=@NEW_COMPANY_ID AND CONTROLCODECATEGORYCODE='Rank')
		SET @MODULE_MASTER_ID_CONTROLCODECATEGORY_ID = (SELECT Id FROM [Common].[ModuleMaster]  WHERE COMPANYID=@UNIQUE_COMPANY_ID AND NAME='Admin Cursor')
		INSERT INTO [Common].[ControlCodeCategoryModule] (Id, CompanyId, ControlCategoryId, ModuleMasterId) VALUES ((SELECT MAX(Id) + 1 FROM [Common].[ControlCodeCategoryModule]),
		@NEW_COMPANY_ID,@CONTROLCODECATEGORY_ID_MODULE_MASTER_ID,@MODULE_MASTER_ID_CONTROLCODECATEGORY_ID);

		SET @CONTROLCODECATEGORY_ID_MODULE_MASTER_ID = (SELECT top 1 ID FROM [Common].[ControlCodeCategory] WHERE COMPANYID=@NEW_COMPANY_ID AND CONTROLCODECATEGORYCODE='VendorType')
		SET @MODULE_MASTER_ID_CONTROLCODECATEGORY_ID = (SELECT Id FROM [Common].[ModuleMaster]  WHERE COMPANYID=@UNIQUE_COMPANY_ID AND NAME='Admin Cursor')
		INSERT INTO [Common].[ControlCodeCategoryModule] (Id, CompanyId, ControlCategoryId, ModuleMasterId) VALUES ((SELECT MAX(Id) + 1 FROM [Common].[ControlCodeCategoryModule]),
		@NEW_COMPANY_ID,@CONTROLCODECATEGORY_ID_MODULE_MASTER_ID,@MODULE_MASTER_ID_CONTROLCODECATEGORY_ID);

		SET @CONTROLCODECATEGORY_ID_MODULE_MASTER_ID = (SELECT top 1 ID FROM [Common].[ControlCodeCategory] WHERE COMPANYID=@NEW_COMPANY_ID AND CONTROLCODECATEGORYCODE='VendorType')
		SET @MODULE_MASTER_ID_CONTROLCODECATEGORY_ID = (SELECT Id FROM [Common].[ModuleMaster]  WHERE COMPANYID=@UNIQUE_COMPANY_ID AND NAME='Admin Cursor')
		INSERT INTO [Common].[ControlCodeCategoryModule] (Id, CompanyId, ControlCategoryId, ModuleMasterId) VALUES ((SELECT MAX(Id) + 1 FROM [Common].[ControlCodeCategoryModule]),
		@NEW_COMPANY_ID,@CONTROLCODECATEGORY_ID_MODULE_MASTER_ID,@MODULE_MASTER_ID_CONTROLCODECATEGORY_ID);

		SET @CONTROLCODECATEGORY_ID_MODULE_MASTER_ID = (SELECT top 1 ID FROM [Common].[ControlCodeCategory] WHERE COMPANYID=@NEW_COMPANY_ID AND CONTROLCODECATEGORYCODE='Source Type')
		SET @MODULE_MASTER_ID_CONTROLCODECATEGORY_ID = (SELECT Id FROM [Common].[ModuleMaster]  WHERE COMPANYID=@UNIQUE_COMPANY_ID AND NAME='Admin Cursor')
		INSERT INTO [Common].[ControlCodeCategoryModule] (Id, CompanyId, ControlCategoryId, ModuleMasterId) VALUES ((SELECT MAX(Id) + 1 FROM [Common].[ControlCodeCategoryModule]),
		@NEW_COMPANY_ID,@CONTROLCODECATEGORY_ID_MODULE_MASTER_ID,@MODULE_MASTER_ID_CONTROLCODECATEGORY_ID);				
				
		SET @CONTROLCODECATEGORY_ID_MODULE_MASTER_ID = (SELECT top 1 ID FROM [Common].[ControlCodeCategory] WHERE COMPANYID=@NEW_COMPANY_ID AND CONTROLCODECATEGORYCODE='Industries')
		SET @MODULE_MASTER_ID_CONTROLCODECATEGORY_ID = (SELECT Id FROM [Common].[ModuleMaster]  WHERE COMPANYID=@UNIQUE_COMPANY_ID AND NAME='Admin Cursor')
		INSERT INTO [Common].[ControlCodeCategoryModule] (Id, CompanyId, ControlCategoryId, ModuleMasterId) VALUES ((SELECT MAX(Id) + 1 FROM [Common].[ControlCodeCategoryModule]),
		@NEW_COMPANY_ID,@CONTROLCODECATEGORY_ID_MODULE_MASTER_ID,@MODULE_MASTER_ID_CONTROLCODECATEGORY_ID);
		SET @CONTROLCODECATEGORY_ID_MODULE_MASTER_ID = (SELECT top 1 ID FROM [Common].[ControlCodeCategory] WHERE COMPANYID=@NEW_COMPANY_ID AND CONTROLCODECATEGORYCODE='ActivitySubject')
		SET @MODULE_MASTER_ID_CONTROLCODECATEGORY_ID = (SELECT Id FROM [Common].[ModuleMaster]  WHERE COMPANYID=@UNIQUE_COMPANY_ID AND NAME='Client Cursor')
		INSERT INTO [Common].[ControlCodeCategoryModule] (Id, CompanyId, ControlCategoryId, ModuleMasterId) VALUES ((SELECT MAX(Id) + 1 FROM [Common].[ControlCodeCategoryModule]),
		@NEW_COMPANY_ID,@CONTROLCODECATEGORY_ID_MODULE_MASTER_ID,@MODULE_MASTER_ID_CONTROLCODECATEGORY_ID);

		SET @CONTROLCODECATEGORY_ID_MODULE_MASTER_ID = (SELECT top 1 ID FROM [Common].[ControlCodeCategory] WHERE COMPANYID=@NEW_COMPANY_ID AND CONTROLCODECATEGORYCODE='Relation')
		SET @MODULE_MASTER_ID_CONTROLCODECATEGORY_ID = (SELECT Id FROM [Common].[ModuleMaster]  WHERE COMPANYID=@UNIQUE_COMPANY_ID AND NAME='HR Cursor')
		INSERT INTO [Common].[ControlCodeCategoryModule] (Id, CompanyId, ControlCategoryId, ModuleMasterId) VALUES ((SELECT MAX(Id) + 1 FROM [Common].[ControlCodeCategoryModule]),
		@NEW_COMPANY_ID,@CONTROLCODECATEGORY_ID_MODULE_MASTER_ID,@MODULE_MASTER_ID_CONTROLCODECATEGORY_ID); 

		SET @CONTROLCODECATEGORY_ID_MODULE_MASTER_ID = (SELECT top 1 ID FROM [Common].[ControlCodeCategory] WHERE COMPANYID=@NEW_COMPANY_ID AND CONTROLCODECATEGORYCODE='Gender')
		SET @MODULE_MASTER_ID_CONTROLCODECATEGORY_ID = (SELECT Id FROM [Common].[ModuleMaster]  WHERE COMPANYID=@UNIQUE_COMPANY_ID AND NAME='HR Cursor')
		INSERT INTO [Common].[ControlCodeCategoryModule] (Id, CompanyId, ControlCategoryId, ModuleMasterId) VALUES ((SELECT MAX(Id) + 1 FROM [Common].[ControlCodeCategoryModule]),
		@NEW_COMPANY_ID,@CONTROLCODECATEGORY_ID_MODULE_MASTER_ID,@MODULE_MASTER_ID_CONTROLCODECATEGORY_ID); 				
				
		SET @CONTROLCODECATEGORY_ID_MODULE_MASTER_ID = (SELECT top 1 ID FROM [Common].[ControlCodeCategory] WHERE COMPANYID=@NEW_COMPANY_ID AND CONTROLCODECATEGORYCODE='Nationality')
		SET @MODULE_MASTER_ID_CONTROLCODECATEGORY_ID = (SELECT Id FROM [Common].[ModuleMaster]  WHERE COMPANYID=@UNIQUE_COMPANY_ID AND NAME='HR Cursor')
		INSERT INTO [Common].[ControlCodeCategoryModule] (Id, CompanyId, ControlCategoryId, ModuleMasterId) VALUES ((SELECT MAX(Id) + 1 FROM [Common].[ControlCodeCategoryModule]),
		@NEW_COMPANY_ID,@CONTROLCODECATEGORY_ID_MODULE_MASTER_ID,@MODULE_MASTER_ID_CONTROLCODECATEGORY_ID); 
						
	    SET @CONTROLCODECATEGORY_ID_MODULE_MASTER_ID = (SELECT top 1 ID FROM [Common].[ControlCodeCategory] WHERE COMPANYID=@NEW_COMPANY_ID AND CONTROLCODECATEGORYCODE='CountryOfOrigin')
		SET @MODULE_MASTER_ID_CONTROLCODECATEGORY_ID = (SELECT Id FROM [Common].[ModuleMaster]  WHERE COMPANYID=@UNIQUE_COMPANY_ID AND NAME='HR Cursor')
		INSERT INTO [Common].[ControlCodeCategoryModule] (Id, CompanyId, ControlCategoryId, ModuleMasterId) VALUES ((SELECT MAX(Id) + 1 FROM [Common].[ControlCodeCategoryModule]),
		@NEW_COMPANY_ID,@CONTROLCODECATEGORY_ID_MODULE_MASTER_ID,@MODULE_MASTER_ID_CONTROLCODECATEGORY_ID); 
				
	    SET @CONTROLCODECATEGORY_ID_MODULE_MASTER_ID = (SELECT top 1 ID FROM [Common].[ControlCodeCategory] WHERE COMPANYID=@NEW_COMPANY_ID AND CONTROLCODECATEGORYCODE='MaritalStatus')
		SET @MODULE_MASTER_ID_CONTROLCODECATEGORY_ID = (SELECT Id FROM [Common].[ModuleMaster]  WHERE COMPANYID=@UNIQUE_COMPANY_ID AND NAME='HR Cursor')
		INSERT INTO [Common].[ControlCodeCategoryModule] (Id, CompanyId, ControlCategoryId, ModuleMasterId) VALUES ((SELECT MAX(Id) + 1 FROM [Common].[ControlCodeCategoryModule]),
		@NEW_COMPANY_ID,@CONTROLCODECATEGORY_ID_MODULE_MASTER_ID,@MODULE_MASTER_ID_CONTROLCODECATEGORY_ID);				  	   
				
	    SET @CONTROLCODECATEGORY_ID_MODULE_MASTER_ID = (SELECT top 1 ID FROM [Common].[ControlCodeCategory] WHERE COMPANYID=@NEW_COMPANY_ID AND CONTROLCODECATEGORYCODE='Race')
		SET @MODULE_MASTER_ID_CONTROLCODECATEGORY_ID = (SELECT Id FROM [Common].[ModuleMaster]  WHERE COMPANYID=@UNIQUE_COMPANY_ID AND NAME='HR Cursor')
		INSERT INTO [Common].[ControlCodeCategoryModule] (Id, CompanyId, ControlCategoryId, ModuleMasterId) VALUES ((SELECT MAX(Id) + 1 FROM [Common].[ControlCodeCategoryModule]),
		@NEW_COMPANY_ID,@CONTROLCODECATEGORY_ID_MODULE_MASTER_ID,@MODULE_MASTER_ID_CONTROLCODECATEGORY_ID); 
					   
		SET @CONTROLCODECATEGORY_ID_MODULE_MASTER_ID = (SELECT top 1 ID FROM [Common].[ControlCodeCategory] WHERE COMPANYID=@NEW_COMPANY_ID AND CONTROLCODECATEGORYCODE='Religion')
		SET @MODULE_MASTER_ID_CONTROLCODECATEGORY_ID = (SELECT Id FROM [Common].[ModuleMaster]  WHERE COMPANYID=@UNIQUE_COMPANY_ID AND NAME='HR Cursor')
		INSERT INTO [Common].[ControlCodeCategoryModule] (Id, CompanyId, ControlCategoryId, ModuleMasterId) VALUES ((SELECT MAX(Id) + 1 FROM [Common].[ControlCodeCategoryModule]),
		@NEW_COMPANY_ID,@CONTROLCODECATEGORY_ID_MODULE_MASTER_ID,@MODULE_MASTER_ID_CONTROLCODECATEGORY_ID);					   
					   
		SET @CONTROLCODECATEGORY_ID_MODULE_MASTER_ID = (SELECT top 1 ID FROM [Common].[ControlCodeCategory] WHERE COMPANYID=@NEW_COMPANY_ID AND CONTROLCODECATEGORYCODE='MemberShip')
		SET @MODULE_MASTER_ID_CONTROLCODECATEGORY_ID = (SELECT Id FROM [Common].[ModuleMaster]  WHERE COMPANYID=@UNIQUE_COMPANY_ID AND NAME='HR Cursor')
		INSERT INTO [Common].[ControlCodeCategoryModule] (Id, CompanyId, ControlCategoryId, ModuleMasterId) VALUES ((SELECT MAX(Id) + 1 FROM [Common].[ControlCodeCategoryModule]),
		@NEW_COMPANY_ID,@CONTROLCODECATEGORY_ID_MODULE_MASTER_ID,@MODULE_MASTER_ID_CONTROLCODECATEGORY_ID);					   
					   
		SET @CONTROLCODECATEGORY_ID_MODULE_MASTER_ID = (SELECT top 1 ID FROM [Common].[ControlCodeCategory] WHERE COMPANYID=@NEW_COMPANY_ID AND CONTROLCODECATEGORYCODE='IdType')
		SET @MODULE_MASTER_ID_CONTROLCODECATEGORY_ID = (SELECT Id FROM [Common].[ModuleMaster]  WHERE COMPANYID=@UNIQUE_COMPANY_ID AND NAME='HR Cursor')
		INSERT INTO [Common].[ControlCodeCategoryModule] (Id, CompanyId, ControlCategoryId, ModuleMasterId) VALUES ((SELECT MAX(Id) + 1 FROM [Common].[ControlCodeCategoryModule]),
		@NEW_COMPANY_ID,@CONTROLCODECATEGORY_ID_MODULE_MASTER_ID,@MODULE_MASTER_ID_CONTROLCODECATEGORY_ID); 
				
		SET @CONTROLCODECATEGORY_ID_MODULE_MASTER_ID = (SELECT top 1 ID FROM [Common].[ControlCodeCategory] WHERE COMPANYID=@NEW_COMPANY_ID AND CONTROLCODECATEGORYCODE='Level')
		SET @MODULE_MASTER_ID_CONTROLCODECATEGORY_ID = (SELECT Id FROM [Common].[ModuleMaster]  WHERE COMPANYID=@UNIQUE_COMPANY_ID AND NAME='HR Cursor')
		INSERT INTO [Common].[ControlCodeCategoryModule] (Id, CompanyId, ControlCategoryId, ModuleMasterId) VALUES ((SELECT MAX(Id) + 1 FROM [Common].[ControlCodeCategoryModule]),
		@NEW_COMPANY_ID,@CONTROLCODECATEGORY_ID_MODULE_MASTER_ID,@MODULE_MASTER_ID_CONTROLCODECATEGORY_ID); 

		SET @CONTROLCODECATEGORY_ID_MODULE_MASTER_ID = (SELECT top 1 ID FROM [Common].[ControlCodeCategory] WHERE COMPANYID=@NEW_COMPANY_ID AND CONTROLCODECATEGORYCODE='HireReason')
		SET @MODULE_MASTER_ID_CONTROLCODECATEGORY_ID = (SELECT Id FROM [Common].[ModuleMaster]  WHERE COMPANYID=@UNIQUE_COMPANY_ID AND NAME='HR Cursor')
		INSERT INTO [Common].[ControlCodeCategoryModule] (Id, CompanyId, ControlCategoryId, ModuleMasterId) VALUES ((SELECT MAX(Id) + 1 FROM [Common].[ControlCodeCategoryModule]),
		@NEW_COMPANY_ID,@CONTROLCODECATEGORY_ID_MODULE_MASTER_ID,@MODULE_MASTER_ID_CONTROLCODECATEGORY_ID); 				
				
		SET @CONTROLCODECATEGORY_ID_MODULE_MASTER_ID = (SELECT top 1 ID FROM [Common].[ControlCodeCategory] WHERE COMPANYID=@NEW_COMPANY_ID AND CONTROLCODECATEGORYCODE='LeaveType')
		SET @MODULE_MASTER_ID_CONTROLCODECATEGORY_ID = (SELECT Id FROM [Common].[ModuleMaster]  WHERE COMPANYID=@UNIQUE_COMPANY_ID AND NAME='HR Cursor')
		INSERT INTO [Common].[ControlCodeCategoryModule] (Id, CompanyId, ControlCategoryId, ModuleMasterId) VALUES ((SELECT MAX(Id) + 1 FROM [Common].[ControlCodeCategoryModule]),
		@NEW_COMPANY_ID,@CONTROLCODECATEGORY_ID_MODULE_MASTER_ID,@MODULE_MASTER_ID_CONTROLCODECATEGORY_ID); 				
				
		SET @CONTROLCODECATEGORY_ID_MODULE_MASTER_ID = (SELECT top 1 ID FROM [Common].[ControlCodeCategory] WHERE COMPANYID=@NEW_COMPANY_ID AND CONTROLCODECATEGORYCODE='LeaveStatus')
		SET @MODULE_MASTER_ID_CONTROLCODECATEGORY_ID = (SELECT Id FROM [Common].[ModuleMaster]  WHERE COMPANYID=@UNIQUE_COMPANY_ID AND NAME='HR Cursor')
		INSERT INTO [Common].[ControlCodeCategoryModule] (Id, CompanyId, ControlCategoryId, ModuleMasterId) VALUES ((SELECT MAX(Id) + 1 FROM [Common].[ControlCodeCategoryModule]),
		@NEW_COMPANY_ID,@CONTROLCODECATEGORY_ID_MODULE_MASTER_ID,@MODULE_MASTER_ID_CONTROLCODECATEGORY_ID);

		SET @CONTROLCODECATEGORY_ID_MODULE_MASTER_ID = (SELECT top 1 ID FROM [Common].[ControlCodeCategory] WHERE COMPANYID=@NEW_COMPANY_ID AND CONTROLCODECATEGORYCODE='BankNames')
		SET @MODULE_MASTER_ID_CONTROLCODECATEGORY_ID = (SELECT Id FROM [Common].[ModuleMaster]  WHERE COMPANYID=@UNIQUE_COMPANY_ID AND NAME='HR Cursor')
		INSERT INTO [Common].[ControlCodeCategoryModule] (Id, CompanyId, ControlCategoryId, ModuleMasterId) VALUES ((SELECT MAX(Id) + 1 FROM [Common].[ControlCodeCategoryModule]),
		@NEW_COMPANY_ID,@CONTROLCODECATEGORY_ID_MODULE_MASTER_ID,@MODULE_MASTER_ID_CONTROLCODECATEGORY_ID); 	

		SET @CONTROLCODECATEGORY_ID_MODULE_MASTER_ID = (SELECT top 1 ID FROM [Common].[ControlCodeCategory] WHERE COMPANYID=@NEW_COMPANY_ID AND CONTROLCODECATEGORYCODE='WorkProfile')
		SET @MODULE_MASTER_ID_CONTROLCODECATEGORY_ID = (SELECT Id FROM [Common].[ModuleMaster]  WHERE COMPANYID=@UNIQUE_COMPANY_ID AND NAME='HR Cursor')
		INSERT INTO [Common].[ControlCodeCategoryModule] (Id, CompanyId, ControlCategoryId, ModuleMasterId) VALUES ((SELECT MAX(Id) + 1 FROM [Common].[ControlCodeCategoryModule]),
		@NEW_COMPANY_ID,@CONTROLCODECATEGORY_ID_MODULE_MASTER_ID,@MODULE_MASTER_ID_CONTROLCODECATEGORY_ID); 

		SET @CONTROLCODECATEGORY_ID_MODULE_MASTER_ID = (SELECT top 1 ID FROM [Common].[ControlCodeCategory] WHERE COMPANYID=@NEW_COMPANY_ID AND CONTROLCODECATEGORYCODE='Period')
		SET @MODULE_MASTER_ID_CONTROLCODECATEGORY_ID = (SELECT Id FROM [Common].[ModuleMaster]  WHERE COMPANYID=@UNIQUE_COMPANY_ID AND NAME='HR Cursor')
		INSERT INTO [Common].[ControlCodeCategoryModule] (Id, CompanyId, ControlCategoryId, ModuleMasterId) VALUES ((SELECT MAX(Id) + 1 FROM [Common].[ControlCodeCategoryModule]),
		@NEW_COMPANY_ID,@CONTROLCODECATEGORY_ID_MODULE_MASTER_ID,@MODULE_MASTER_ID_CONTROLCODECATEGORY_ID); 

		SET @CONTROLCODECATEGORY_ID_MODULE_MASTER_ID = (SELECT top 1 ID FROM [Common].[ControlCodeCategory] WHERE COMPANYID=@NEW_COMPANY_ID AND CONTROLCODECATEGORYCODE='Reason For Leaving')
		SET @MODULE_MASTER_ID_CONTROLCODECATEGORY_ID = (SELECT Id FROM [Common].[ModuleMaster]  WHERE COMPANYID=@UNIQUE_COMPANY_ID AND NAME='HR Cursor')
		INSERT INTO [Common].[ControlCodeCategoryModule] (Id, CompanyId, ControlCategoryId, ModuleMasterId) VALUES ((SELECT MAX(Id) + 1 FROM [Common].[ControlCodeCategoryModule]),
		@NEW_COMPANY_ID,@CONTROLCODECATEGORY_ID_MODULE_MASTER_ID,@MODULE_MASTER_ID_CONTROLCODECATEGORY_ID);				



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
