USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[SP_UAT_CREATE_SEED_DATA]    Script Date: 16-12-2024 9.20.11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




/****** Object:  StoredProcedure [dbo].[SP_UAT_CREATE_SEED_DATA]    Script Date: 17-06-2016 07:49:03 PM ******/


CREATE PROCEDURE [dbo].[SP_UAT_CREATE_SEED_DATA](@UNIQUE_COMPANY_ID BIGINT,@NEW_COMPANY_ID BIGINT,@DOC_STATUS INT,@TAX_STATUS INT,@CS_STATUS INT,@KNOWLEDGE_STATUS INT,@BEAN_STATUS INT, @AUDIT_STATUS INT,@WORKFLOW_STATUS INT,@CLIENT_STATUS INT,@HR_STATUS INT)
AS
BEGIN    
	/* 
	AUTHOR           : SREENIVASULU G
	DATE OF CREATION : 16 - FEBRUARY - 2016
	REQUIREMENT      : TO CREATE SEED DATA FOR COMPANY CREATION
	*/ 
	--------------PARA METERS ---------------------------------------------        
	DECLARE @STATUS   INT
	DECLARE @CREATED_DATE DATETIME	
	DECLARE @CONTROLCODECATEGORY_ID_MODULE_MASTER_ID BIGINT
	DECLARE @MODULE_MASTER_ID_CONTROLCODECATEGORY_ID BIGINT
	DECLARE @ACCOUNTYPE_ID_ID_TYPE_ID BIGINT
	DECLARE @ID_TYPE_ACCOUNTYPE_ID_ID BIGINT	
	SET @STATUS = 1    
	SET @CREATED_DATE =GETUTCDATE()   	
	BEGIN TRANSACTION
	BEGIN TRY

		-------------------------------------------------------Create CompanyModules-----------------------------------------------

		--INSERT INTO [Common].[CompanyModule] ([Id],[CompanyId], [ModuleId],[Status])
		--SELECT ROW_NUMBER() OVER(ORDER BY ID) + (SELECT MAX(id) + 1 FROM [Common].[CompanyModule]), @NEW_COMPANY_ID,[ModuleId],[Status]
		--FROM [Common].[CompanyModule] WHERE COMPANYID=@UNIQUE_COMPANY_ID;

		---------------------------------------------------------Create Roles And Permissions-----------------------------------------------
		----UPDATE [Auth].[Role] SET [TempId] = NULL;


		----INSERT INTO [Auth].[Role] ([Id],[CompanyId],[Name],[Remarks],[ModuleMasterId],[Status],[ModifiedBy],[ModifiedDate],[UserCreated],[CreatedDate],[IsSystem],[TempId])
		----SELECT NEWID(),@NEW_COMPANY_ID,[Name],[Remarks],[ModuleMasterId],[Status],[ModifiedBy],[ModifiedDate],[UserCreated],[CreatedDate],[IsSystem],[Id]
		----FROM [Auth].[Role] WHERE companyid = @UNIQUE_COMPANY_ID;

		----INSERT INTO [Auth].[RolePermission] ([Id],[RoleId],[ModuleDetailPermissionId])
		----SELECT NEWID(), R.Id,RP.ModuleDetailPermissionId FROM [Auth].[RolePermission] RP
		----inner join [Auth].[Role] R ON RP.RoleId = R.TempId 
		----WHERE R.CompanyId = @NEW_COMPANY_ID;

		
		--IF(@CLIENT_STATUS = 2)
		--BEGIN 
		--	--UPDATE [Auth].[Role] SET [Status] = 2 WHERE [Name] = 'CC Admin' AND [CompanyId] = @NEW_COMPANY_ID;
		--	UPDATE [Common].[CompanyModule] SET [Status] = 2 WHERE [ModuleId] = 1 AND [CompanyId] = @NEW_COMPANY_ID;
		--END

		--IF(@WORKFLOW_STATUS = 2)
		--BEGIN 
		--	--UPDATE [Auth].[Role] SET [Status] = 2 WHERE [Name] = 'WF Admin' AND [CompanyId] = @NEW_COMPANY_ID;
		--	UPDATE [Common].[CompanyModule] SET [Status] = 2 WHERE [ModuleId] = 2 AND [CompanyId] = @NEW_COMPANY_ID;
		--END

		--IF(@AUDIT_STATUS = 2)
		--BEGIN 
		--	--UPDATE [Auth].[Role] SET [Status] = 2 WHERE [Name] = 'AU Admin' AND [CompanyId] = @NEW_COMPANY_ID;
		--	UPDATE [Common].[CompanyModule] SET [Status] = 2 WHERE [ModuleId] = 3 AND [CompanyId] = @NEW_COMPANY_ID;
		--END

		--IF(@BEAN_STATUS = 2)
		--BEGIN 
		--	--UPDATE [Auth].[Role] SET [Status] = 2 WHERE [Name] = 'BC Admin' AND [CompanyId] = @NEW_COMPANY_ID;
		--	UPDATE [Common].[CompanyModule] SET [Status] = 2 WHERE [ModuleId] = 4 AND [CompanyId] = @NEW_COMPANY_ID;
		--END

		--IF(@KNOWLEDGE_STATUS = 2)
		--BEGIN 
		--	--UPDATE [Auth].[Role] SET [Status] = 2 WHERE [Name] = 'KB Admin' AND [CompanyId] = @NEW_COMPANY_ID;
		--	UPDATE [Common].[CompanyModule] SET [Status] = 2 WHERE [ModuleId] = 5 AND [CompanyId] = @NEW_COMPANY_ID;
		--END

		--IF(@DOC_STATUS = 2)
		--BEGIN 
		--	--UPDATE [Auth].[Role] SET [Status] = 2 WHERE [Name] = 'DC Admin' AND [CompanyId] = @NEW_COMPANY_ID;
		--	UPDATE [Common].[CompanyModule] SET [Status] = 2 WHERE [ModuleId] = 6 AND [CompanyId] = @NEW_COMPANY_ID;
		--END

		--IF(@TAX_STATUS = 2)
		--BEGIN 
		--	--UPDATE [Auth].[Role] SET [Status] = 2 WHERE [Name] = 'TX Admin' AND [CompanyId] = @NEW_COMPANY_ID;
		--	UPDATE [Common].[CompanyModule] SET [Status] = 2 WHERE [ModuleId] = 7 AND [CompanyId] = @NEW_COMPANY_ID;
		--END

		--IF(@CS_STATUS = 2)
		--BEGIN 
		--	--UPDATE [Auth].[Role] SET [Status] = 2 WHERE [Name] = 'CS Admin' AND [CompanyId] = @NEW_COMPANY_ID;
		--	UPDATE [Common].[CompanyModule] SET [Status] = 2 WHERE [ModuleId] = 9 AND [CompanyId] = @NEW_COMPANY_ID;
		--END

		--IF(@HR_STATUS = 2)
		--BEGIN 
		--	--UPDATE [Auth].[Role] SET [Status] = 2 WHERE [Name] = 'HR Admin' AND [CompanyId] = @NEW_COMPANY_ID;
		--	UPDATE [Common].[CompanyModule] SET [Status] = 2 WHERE [ModuleId] = 8 AND [CompanyId] = @NEW_COMPANY_ID;
		--END

		-----------------------------------------------------Create Temp Tables-----------------------------------------------
		TRUNCATE TABLE UAT_JobRisk_Temp

  	    ---------------TRUNCATE JOB HOURS LEVEL TEMP TABLE-------------------------------
		TRUNCATE TABLE UAT_JobHoursLevel__Temp        
		
		-----------------------------------------ID TYPE------------------------------------------------------------------------------------------
		UPDATE [Common].[IdType] SET[TempIdTypeId] = NULL;
	    	
		
		--ALTER TABLE [Common].[IdType] ADD [TempIdTypeId] BIGINT NULL;
        INSERT INTO [Common].[IdType] (Id, Name, CompanyId, RecOrder, Remarks, UserCreated, CreatedDate, ModifiedBy, ModifiedDate, Version, Status,TempIdTypeId) 
			SELECT ROW_NUMBER() OVER(ORDER BY ID) + (SELECT MAX(id) + @STATUS FROM [Common].[IdType]), Name, @NEW_COMPANY_ID, RecOrder, Remarks,
			UserCreated, @CREATED_DATE, ModifiedBy, ModifiedDate, Version, status, Id FROM [Common].[IdType] WHERE COMPANYID=@UNIQUE_COMPANY_ID;
		

		-----------------------------------------GRID META DATA------------------------------------------------------------------------------------------
		INSERT INTO [Auth].[GridMetaData] (Id,ModuleDetailId, UserName, Url, GridMetaData, CompanyId, APIMethod, ActionURL, TableName, Class, Title, Params, Options, StreamName, ViewModelName,PopupOptions,ActionType)
			SELECT (NEWID()), ModuleDetailId, UserName, Url, GridMetaData, @NEW_COMPANY_ID, APIMethod, ActionURL, TableName, Class, Title, Params, Options, StreamName, ViewModelName,PopupOptions,ActionType  FROM 
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
			Remarks, UserCreated, CreatedDate, ModifiedBy, ModifiedDate, Version, Status, Subject, TemplateMenu, ToEmailId, IsUnique,CursorName)		    
			SELECT (NEWID()), Name, Code, @NEW_COMPANY_ID, FromEmailId, CCEmailIds, BCCEmailIds, TemplateType, TempletContent, RecOrder,
			Remarks, UserCreated, GETUTCDATE(), ModifiedBy, ModifiedDate, Version, status, Subject, TemplateMenu, ToEmailId, IsUnique,CursorName
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
			ShowCurrency, ShowCashFlow, ShowAllowable, IsRevaluation, Revaluation, DisAllowable, RealisedExchangeGainOrLoss, UnrealisedExchangeGainOrLoss, ModuleType,IsSeedData,IsDebt,IsLinkedAccount,IsRealCOA)	
			SELECT ROW_NUMBER() OVER(ORDER BY ID) + (SELECT MAX(Id) FROM [Bean].[ChartOfAccount]) AS Id, @NEW_COMPANY_ID,Code, Name, @NEW_aCCOUNTTYPE_ID, Class, Category, SubCategory,
			Nature, Currency, ShowRevaluation, CashflowType, AppliesTo, IsSystem, IsShowforCOA, RecOrder, Remarks,
            UserCreated, @CREATED_DATE, ModifiedBy, ModifiedDate, Version, status, IsSubLedger, IsCodeEditable, ShowCurrency, ShowCashFlow, ShowAllowable, IsRevaluation, Revaluation, 
            DisAllowable, RealisedExchangeGainOrLoss, UnrealisedExchangeGainOrLoss, ModuleType,IsSeedData,IsDebt,IsLinkedAccount,IsRealCOA FROM [Bean].[ChartOfAccount] WHERE COMPANYID=0 AND AccountTypeId = @ACCOUNTTYPE_ID
			FETCH NEXT FROM ACCOUNT_CURSOR INTO @ACCOUNTTYPE_ID
		END	
		CLOSE ACCOUNT_CURSOR
		Deallocate ACCOUNT_CURSOR				

		------------------------------------------------------ACCOUNT TYPE ------------------------------------------------------------------------
		UPDATE [Common].[AccountType] SET [TempAccountTypeId] = NULL;
		--ALTER TABLE [Common].[AccountType] ADD [TempAccountTypeId] BIGINT NULL;
		INSERT INTO [Common].[AccountType] (Id, Name, CompanyId, RecOrder, Remarks, UserCreated, CreatedDate, ModifiedBy, ModifiedDate, Version, Status,TempAccountTypeId)
			SELECT ROW_NUMBER() OVER(ORDER BY ID) + (SELECT MAX(Id) + @STATUS FROM [Common].[AccountType]), Name, @NEW_COMPANY_ID, RecOrder, Remarks, UserCreated,
			@CREATED_DATE, ModifiedBy, ModifiedDate, Version, status,Id FROM [Common].[AccountType]  WHERE COMPANYID=@UNIQUE_COMPANY_ID;

		------------------------------------------------------CURRENCY ------------------------------------------------------------------------
        INSERT INTO  [Bean].[Currency] (Id, Code, CompanyId, Name, RecOrder, Status, UserCreated, CreatedDate, ModifiedBy, ModifiedDate, DefaultValue)
			SELECT ROW_NUMBER() OVER(ORDER BY ID) + (SELECT MAX(id) + @STATUS FROM [Bean].[Currency]), Code, @NEW_COMPANY_ID, Name, RecOrder, STATUS,
			UserCreated, @CREATED_DATE, ModifiedBy, ModifiedDate, DefaultValue FROM [Bean].[Currency] WHERE COMPANYID=@UNIQUE_COMPANY_ID;		  
		   
		------------------------------------------------------TERMS OF PAYMENT  ------------------------------------------------------------------------
		INSERT INTO [Common].[TermsOfPayment] (Id, Name, CompanyId, TermsType, TOPValue, RecOrder, Remarks, UserCreated, CreatedDate, ModifiedBy, 
			ModifiedDate, Version, Status, IsVendor, IsCustomer)
			SELECT ROW_NUMBER() OVER(ORDER BY ID) + (SELECT MAX(id) + @STATUS FROM [Common].[TermsOfPayment] ), Name, @NEW_COMPANY_ID, TermsType, TOPValue, 
			RecOrder, Remarks, UserCreated, @CREATED_DATE, ModifiedBy, ModifiedDate, Version, status, IsVendor, IsCustomer FROM [Common].[TermsOfPayment] 
			WHERE COMPANYID=@UNIQUE_COMPANY_ID;

		------------------------------------------------------LOCALIZATION  ------------------------------------------------------------------------
		--INSERT INTO [Common].[Localization] (Id, CompanyId, LongDateFormat, ShortDateFormat, TimeFormat, BaseCurrency, BusinessYearEnd, Status,
		--	UserCreated, CreatedDate, ModifiedBy, ModifiedDate, TimeZone)
		--	SELECT ROW_NUMBER() OVER(ORDER BY ID) + (SELECT MAX(id) + @STATUS FROM [Common].[Localization]), @NEW_COMPANY_ID, LongDateFormat, ShortDateFormat,
		--	TimeFormat, BaseCurrency, BusinessYearEnd, status, UserCreated, @CREATED_DATE, ModifiedBy, ModifiedDate, TimeZone FROM [Common].[Localization]
		--	WHERE COMPANYID=(SELECT MAX(COMPANYID) FROM [Common].[Localization]);



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
				GETUTCDATE(), ModifiedBy, ModifiedDate, Version, status, ModuleNamesUsing, DefaultValue FROM [Common].[ControlCodeCategory] WHERE ID=@CONTROL_ID
			INSERT INTO [Common].[ControlCode] (Id, ControlCategoryId, CodeKey, CodeValue, IsSystem, RecOrder, Remarks, UserCreated, CreatedDate, 
				ModifiedBy, ModifiedDate, Version, Status, IsDefault,ModuleNamesUsing)
			SELECT ROW_NUMBER() OVER(ORDER BY a.ID) + (SELECT MAX(Id) + 1 FROM [Common].[ControlCode]) AS Id,@NEW_CONTROL_ID, a.CodeKey, a.CodeValue,
				a.IsSystem, a.RecOrder, a.Remarks, a.UserCreated, GETUTCDATE(), a.ModifiedBy,a.ModifiedDate, a.Version, a.Status, a.IsDefault,a.ModuleNamesUsing
				from  [Common].[ControlCode] a join [Common].[ControlCodeCategory] b on a.controlcategoryid=b.id where b.companyid=0 
				and a.controlcategoryid=@CONTROL_ID
							  			
			FETCH NEXT FROM CONTROL_CURSOR INTO @CONTROL_ID      
		END	
		close CONTROL_CURSOR
		Deallocate CONTROL_CURSOR
		
		-------------------------------------------------------------JOB TYPE-----------------------------------------------------------------------------------------
		INSERT INTO [ClientCursor].[JobType]  (Id, JobType, Description, CompanyId, UserCreated, CreatedDate, ModifiedBy, ModifiedDate, Status)
			SELECT (NEWID()), JobType, Description, @NEW_COMPANY_ID, UserCreated, GETUTCDate(), ModifiedBy, ModifiedDate, status FROM [ClientCursor].[JobType] 
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
			VolManager, VolSenior, VolSeniorAssociate, VolJuniorAssociate, UserCreated, GETUTCDATE(), ModifiedBy, ModifiedDate,status FROM UAT_JobRisk_Temp; 
				TRUNCATE TABLE UAT_JobRisk_Temp

		 ---------------------------------------------------------------------JOB RISK -------------------------------------------------------------------
		INSERT INTO [ClientCursor].[JobHoursLevel] (Id, JobTypeId, Hours, Level, UserCreated, CreatedDate, ModifiedBy, ModifiedDate, Status)
			SELECT (NEWID()), JobTypeId, Hours, Level, UserCreated, GETUTCDATE(), ModifiedBy, ModifiedDate, status FROM UAT_JobHoursLevel__Temp ;
			TRUNCATE TABLE UAT_JobHoursLevel__Temp;

		-------------------------------------------------------------------------ACCOUNT TYPE ID TYPE----------------------------------------------------------
		INSERT INTO  [Common].[AccountTypeIdType] (Id, AccountTypeId, IdTypeId, RecOrder)		
			SELECT ROW_NUMBER() OVER(ORDER BY A.ID) + (SELECT MAX(ID) + 1 FROM [Common].[AccountTypeIdType]) ,B.Id AS ACCOUNTTYPEID,C.Id AS IDTYPEID,
			A.RecOrder FROM [Common].[AccountTypeIdType] A JOIN [Common].[AccountType] B ON A.AccountTypeId = B.TempAccountTypeId JOIN [Common].[IdType] C 
			ON C.TempIdTypeId = A.IdTypeId	WHERE B.CompanyId=@NEW_COMPANY_ID AND C.CompanyId=@NEW_COMPANY_ID;

			----------------------------------------------------------Evaluation Details-------------------------------------------------------------------------
       INSERT INTO  [HR].[EvaluationDetails] (Id, CompanyId, Name, Type, Value, Status,RecOrder)  
       SELECT (NEWID()), @NEW_COMPANY_ID,Name, Type, Value, Status,RecOrder FROM [HR].[EvaluationDetails] WHERE COMPANYID=0


	     
	   -----------------------------------------------------AGMSetting (BRC) ---------------------------- 
--			 INSERT INTO Common.AGMSetting
--Select Newid(),@NEW_COMPANY_ID,Name,BasedOn,Year,Formula,CreatedDate,UserCreated,ModifiedBy,ModifiedDate,Version,
--Status,RecOrder, Newid(),Period,NoOfDays,Duration From Common.AGMSetting where CompanyId=0


--update Common.AGMSetting set DocId=(
--select Id from  Common.AGMSetting where name='Next FYE' and  CompanyId=@NEW_COMPANY_ID and Year='Subsequent' ) where name='Next FYE' and  CompanyId=@NEW_COMPANY_ID and Year='1st Year'  
--update Common.AGMSetting set DocId=(select Id from  Common.AGMSetting where name='Next FYE' and  CompanyId=@NEW_COMPANY_ID and Year='1st Year' ) where name='Next FYE' and  CompanyId=@NEW_COMPANY_ID and Year='Subsequent'

--update Common.AGMSetting set DocId=(select Id from  Common.AGMSetting where name='Section 175' and  CompanyId=@NEW_COMPANY_ID and Year='Subsequent') where name='Section 175' and  CompanyId=@NEW_COMPANY_ID and Year='1st Year'
--update Common.AGMSetting set DocId=(select Id from  Common.AGMSetting where name='Section 175' and  CompanyId=@NEW_COMPANY_ID and Year='1st Year' ) where name='Section 175' and  CompanyId=@NEW_COMPANY_ID and Year='Subsequent'

--update Common.AGMSetting set DocId=(select Id from  Common.AGMSetting where name='Section 201 (Private)' and  CompanyId=@NEW_COMPANY_ID and Year='Subsequent') where name='Section 201 (Private)' and  CompanyId=@NEW_COMPANY_ID and Year='1st Year'
--update Common.AGMSetting set DocId=(select Id from  Common.AGMSetting where name='Section 201 (Private)' and  CompanyId=@NEW_COMPANY_ID and Year='1st Year' ) where name='Section 201 (Private)' and  CompanyId=@NEW_COMPANY_ID and Year='Subsequent'

--update Common.AGMSetting set DocId=(select Id from  Common.AGMSetting where name='Section 201 (Public)' and  CompanyId=@NEW_COMPANY_ID and Year='Subsequent') where name='Section 201 (Public)' and  CompanyId=@NEW_COMPANY_ID and Year='1st Year'
--update Common.AGMSetting set DocId=(select Id from  Common.AGMSetting where name='Section 201 (Public)' and  CompanyId=@NEW_COMPANY_ID and Year='1st Year' ) where name='Section 201 (Public)' and  CompanyId=@NEW_COMPANY_ID and Year='Subsequent'

--update Common.AGMSetting set DocId=(select Id from  Common.AGMSetting where name='Section 197' and  CompanyId=@NEW_COMPANY_ID and Year='Subsequent') where name='Section 197' and  CompanyId=@NEW_COMPANY_ID and Year='1st Year'
--update Common.AGMSetting set DocId=(select Id from  Common.AGMSetting where name='Section 197' and  CompanyId=@NEW_COMPANY_ID and Year='1st Year' ) where name='Section 197' and  CompanyId=@NEW_COMPANY_ID and Year='Subsequent'









			
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

	    SET @CONTROLCODECATEGORY_ID_MODULE_MASTER_ID = (SELECT top 1 ID FROM [Common].[ControlCodeCategory] WHERE COMPANYID=@NEW_COMPANY_ID AND CONTROLCODECATEGORYCODE='Relationship')
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

		--SET @CONTROLCODECATEGORY_ID_MODULE_MASTER_ID = (SELECT top 1 ID FROM [Common].[ControlCodeCategory] WHERE COMPANYID=@NEW_COMPANY_ID AND CONTROLCODECATEGORYCODE='Cashflow Type')
		--SET @MODULE_MASTER_ID_CONTROLCODECATEGORY_ID = (SELECT Id FROM [Common].[ModuleMaster]  WHERE COMPANYID=@UNIQUE_COMPANY_ID AND NAME='Bean Cursor')
		--INSERT INTO [Common].[ControlCodeCategoryModule] (Id, CompanyId, ControlCategoryId, ModuleMasterId) VALUES ((SELECT MAX(Id) + 1 FROM [Common].[ControlCodeCategoryModule]),
		--@NEW_COMPANY_ID,@CONTROLCODECATEGORY_ID_MODULE_MASTER_ID,@MODULE_MASTER_ID_CONTROLCODECATEGORY_ID);

		--SET @CONTROLCODECATEGORY_ID_MODULE_MASTER_ID = (SELECT top 1 ID FROM [Common].[ControlCodeCategory] WHERE COMPANYID=@NEW_COMPANY_ID AND CONTROLCODECATEGORYCODE='AllowableNonalowabl')
		--SET @MODULE_MASTER_ID_CONTROLCODECATEGORY_ID = (SELECT Id FROM [Common].[ModuleMaster]  WHERE COMPANYID=@UNIQUE_COMPANY_ID AND NAME='Bean Cursor')
		--INSERT INTO [Common].[ControlCodeCategoryModule] (Id, CompanyId, ControlCategoryId, ModuleMasterId) VALUES ((SELECT MAX(Id) + 1 FROM [Common].[ControlCodeCategoryModule]),
		--@NEW_COMPANY_ID,@CONTROLCODECATEGORY_ID_MODULE_MASTER_ID,@MODULE_MASTER_ID_CONTROLCODECATEGORY_ID);

		--SET @CONTROLCODECATEGORY_ID_MODULE_MASTER_ID = (SELECT top 1 ID FROM [Common].[ControlCodeCategory] WHERE COMPANYID=@NEW_COMPANY_ID AND CONTROLCODECATEGORYCODE='Tax Type')
		--SET @MODULE_MASTER_ID_CONTROLCODECATEGORY_ID = (SELECT Id FROM [Common].[ModuleMaster]  WHERE COMPANYID=@UNIQUE_COMPANY_ID AND NAME='Bean Cursor')
		--INSERT INTO [Common].[ControlCodeCategoryModule] (Id, CompanyId, ControlCategoryId, ModuleMasterId) VALUES ((SELECT MAX(Id) + 1 FROM [Common].[ControlCodeCategoryModule]),
		--@NEW_COMPANY_ID,@CONTROLCODECATEGORY_ID_MODULE_MASTER_ID,@MODULE_MASTER_ID_CONTROLCODECATEGORY_ID);

		--SET @CONTROLCODECATEGORY_ID_MODULE_MASTER_ID = (SELECT top 1 ID FROM [Common].[ControlCodeCategory] WHERE COMPANYID=@NEW_COMPANY_ID AND CONTROLCODECATEGORYCODE='AppliesTo')
		--SET @MODULE_MASTER_ID_CONTROLCODECATEGORY_ID = (SELECT Id FROM [Common].[ModuleMaster]  WHERE COMPANYID=@UNIQUE_COMPANY_ID AND NAME='Bean Cursor')
		--INSERT INTO [Common].[ControlCodeCategoryModule] (Id, CompanyId, ControlCategoryId, ModuleMasterId) VALUES ((SELECT MAX(Id) + 1 FROM [Common].[ControlCodeCategoryModule]),
		--@NEW_COMPANY_ID,@CONTROLCODECATEGORY_ID_MODULE_MASTER_ID,@MODULE_MASTER_ID_CONTROLCODECATEGORY_ID);

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

		--SET @CONTROLCODECATEGORY_ID_MODULE_MASTER_ID = (SELECT top 1 ID FROM [Common].[ControlCodeCategory] WHERE COMPANYID=@NEW_COMPANY_ID AND CONTROLCODECATEGORYCODE='Long date Format')
		--SET @MODULE_MASTER_ID_CONTROLCODECATEGORY_ID = (SELECT Id FROM [Common].[ModuleMaster]  WHERE COMPANYID=@UNIQUE_COMPANY_ID AND NAME='Admin Cursor')
		--INSERT INTO [Common].[ControlCodeCategoryModule] (Id, CompanyId, ControlCategoryId, ModuleMasterId) VALUES ((SELECT MAX(Id) + 1 FROM [Common].[ControlCodeCategoryModule]),
		--@NEW_COMPANY_ID,@CONTROLCODECATEGORY_ID_MODULE_MASTER_ID,@MODULE_MASTER_ID_CONTROLCODECATEGORY_ID);

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


		SET @CONTROLCODECATEGORY_ID_MODULE_MASTER_ID = (SELECT top 1 ID FROM [Common].[ControlCodeCategory] WHERE COMPANYID=@NEW_COMPANY_ID AND CONTROLCODECATEGORYCODE='AutoNumberTypes')
		SET @MODULE_MASTER_ID_CONTROLCODECATEGORY_ID = (SELECT Id FROM [Common].[ModuleMaster]  WHERE COMPANYID=@UNIQUE_COMPANY_ID AND NAME='Admin Cursor')
		INSERT INTO [Common].[ControlCodeCategoryModule] (Id, CompanyId, ControlCategoryId, ModuleMasterId) VALUES ((SELECT MAX(Id) + 1 FROM [Common].[ControlCodeCategoryModule]),
		@NEW_COMPANY_ID,@CONTROLCODECATEGORY_ID_MODULE_MASTER_ID,@MODULE_MASTER_ID_CONTROLCODECATEGORY_ID);

		SET @CONTROLCODECATEGORY_ID_MODULE_MASTER_ID = (SELECT top 1 ID FROM [Common].[ControlCodeCategory] WHERE COMPANYID=@NEW_COMPANY_ID AND CONTROLCODECATEGORYCODE='Employee Designation')
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
		
						
		SET @CONTROLCODECATEGORY_ID_MODULE_MASTER_ID = (SELECT top 1 ID FROM [Common].[ControlCodeCategory] WHERE COMPANYID=@NEW_COMPANY_ID AND CONTROLCODECATEGORYCODE='Task Subject')
		SET @MODULE_MASTER_ID_CONTROLCODECATEGORY_ID = (SELECT Id FROM [Common].[ModuleMaster]  WHERE COMPANYID=@UNIQUE_COMPANY_ID AND NAME='Client Cursor')
		INSERT INTO [Common].[ControlCodeCategoryModule] (Id, CompanyId, ControlCategoryId, ModuleMasterId) VALUES ((SELECT MAX(Id) + 1 FROM [Common].[ControlCodeCategoryModule]),
		@NEW_COMPANY_ID,@CONTROLCODECATEGORY_ID_MODULE_MASTER_ID,@MODULE_MASTER_ID_CONTROLCODECATEGORY_ID);

		SET @CONTROLCODECATEGORY_ID_MODULE_MASTER_ID = (SELECT top 1 ID FROM [Common].[ControlCodeCategory] WHERE COMPANYID=@NEW_COMPANY_ID AND CONTROLCODECATEGORYCODE='Event Subject')
		SET @MODULE_MASTER_ID_CONTROLCODECATEGORY_ID = (SELECT Id FROM [Common].[ModuleMaster]  WHERE COMPANYID=@UNIQUE_COMPANY_ID AND NAME='Client Cursor')
		INSERT INTO [Common].[ControlCodeCategoryModule] (Id, CompanyId, ControlCategoryId, ModuleMasterId) VALUES ((SELECT MAX(Id) + 1 FROM [Common].[ControlCodeCategoryModule]),
		@NEW_COMPANY_ID,@CONTROLCODECATEGORY_ID_MODULE_MASTER_ID,@MODULE_MASTER_ID_CONTROLCODECATEGORY_ID);

		SET @CONTROLCODECATEGORY_ID_MODULE_MASTER_ID = (SELECT top 1 ID FROM [Common].[ControlCodeCategory] WHERE COMPANYID=@NEW_COMPANY_ID AND CONTROLCODECATEGORYCODE='Note Subject')
		SET @MODULE_MASTER_ID_CONTROLCODECATEGORY_ID = (SELECT Id FROM [Common].[ModuleMaster]  WHERE COMPANYID=@UNIQUE_COMPANY_ID AND NAME='Client Cursor')
		INSERT INTO [Common].[ControlCodeCategoryModule] (Id, CompanyId, ControlCategoryId, ModuleMasterId) VALUES ((SELECT MAX(Id) + 1 FROM [Common].[ControlCodeCategoryModule]),
		@NEW_COMPANY_ID,@CONTROLCODECATEGORY_ID_MODULE_MASTER_ID,@MODULE_MASTER_ID_CONTROLCODECATEGORY_ID);	
		
		 SET @CONTROLCODECATEGORY_ID_MODULE_MASTER_ID = (SELECT top 1 ID FROM [Common].[ControlCodeCategory] WHERE COMPANYID=@NEW_COMPANY_ID AND CONTROLCODECATEGORYCODE='Source')
		SET @MODULE_MASTER_ID_CONTROLCODECATEGORY_ID = (SELECT Id FROM [Common].[ModuleMaster]  WHERE COMPANYID=@UNIQUE_COMPANY_ID AND NAME='HR Cursor')
		INSERT INTO [Common].[ControlCodeCategoryModule] (Id, CompanyId, ControlCategoryId, ModuleMasterId) VALUES ((SELECT MAX(Id) + 1 FROM [Common].[ControlCodeCategoryModule]),
		@NEW_COMPANY_ID,@CONTROLCODECATEGORY_ID_MODULE_MASTER_ID,@MODULE_MASTER_ID_CONTROLCODECATEGORY_ID);	
		
				 
		 SET @CONTROLCODECATEGORY_ID_MODULE_MASTER_ID = (SELECT top 1 ID FROM [Common].[ControlCodeCategory] WHERE COMPANYID=@NEW_COMPANY_ID AND CONTROLCODECATEGORYCODE='JobPostingStatus')
		SET @MODULE_MASTER_ID_CONTROLCODECATEGORY_ID = (SELECT Id FROM [Common].[ModuleMaster]  WHERE COMPANYID=@UNIQUE_COMPANY_ID AND NAME='HR Cursor')
		INSERT INTO [Common].[ControlCodeCategoryModule] (Id, CompanyId, ControlCategoryId, ModuleMasterId) VALUES ((SELECT MAX(Id) + 1 FROM [Common].[ControlCodeCategoryModule]),
		@NEW_COMPANY_ID,@CONTROLCODECATEGORY_ID_MODULE_MASTER_ID,@MODULE_MASTER_ID_CONTROLCODECATEGORY_ID);		
		 		

		 SET @CONTROLCODECATEGORY_ID_MODULE_MASTER_ID = (SELECT top 1 ID FROM [Common].[ControlCodeCategory] WHERE COMPANYID=@NEW_COMPANY_ID AND CONTROLCODECATEGORYCODE='ApplicationStatus')
		SET @MODULE_MASTER_ID_CONTROLCODECATEGORY_ID = (SELECT Id FROM [Common].[ModuleMaster]  WHERE COMPANYID=@UNIQUE_COMPANY_ID AND NAME='HR Cursor')
		INSERT INTO [Common].[ControlCodeCategoryModule] (Id, CompanyId, ControlCategoryId, ModuleMasterId) VALUES ((SELECT MAX(Id) + 1 FROM [Common].[ControlCodeCategoryModule]),
		@NEW_COMPANY_ID,@CONTROLCODECATEGORY_ID_MODULE_MASTER_ID,@MODULE_MASTER_ID_CONTROLCODECATEGORY_ID);	
			
		
		 SET @CONTROLCODECATEGORY_ID_MODULE_MASTER_ID = (SELECT top 1 ID FROM [Common].[ControlCodeCategory] WHERE COMPANYID=@NEW_COMPANY_ID AND CONTROLCODECATEGORYCODE='CalenderSetUpTypes')
		SET @MODULE_MASTER_ID_CONTROLCODECATEGORY_ID = (SELECT Id FROM [Common].[ModuleMaster]  WHERE COMPANYID=@UNIQUE_COMPANY_ID AND NAME='HR Cursor')
		INSERT INTO [Common].[ControlCodeCategoryModule] (Id, CompanyId, ControlCategoryId, ModuleMasterId) VALUES ((SELECT MAX(Id) + 1 FROM [Common].[ControlCodeCategoryModule]),
		@NEW_COMPANY_ID,@CONTROLCODECATEGORY_ID_MODULE_MASTER_ID,@MODULE_MASTER_ID_CONTROLCODECATEGORY_ID);	
			
		
		 SET @CONTROLCODECATEGORY_ID_MODULE_MASTER_ID = (SELECT top 1 ID FROM [Common].[ControlCodeCategory] WHERE COMPANYID=@NEW_COMPANY_ID AND CONTROLCODECATEGORYCODE='LeaveAccural')
		SET @MODULE_MASTER_ID_CONTROLCODECATEGORY_ID = (SELECT Id FROM [Common].[ModuleMaster]  WHERE COMPANYID=@UNIQUE_COMPANY_ID AND NAME='HR Cursor')
		INSERT INTO [Common].[ControlCodeCategoryModule] (Id, CompanyId, ControlCategoryId, ModuleMasterId) VALUES ((SELECT MAX(Id) + 1 FROM [Common].[ControlCodeCategoryModule]),
		@NEW_COMPANY_ID,@CONTROLCODECATEGORY_ID_MODULE_MASTER_ID,@MODULE_MASTER_ID_CONTROLCODECATEGORY_ID);	
		
		
		 SET @CONTROLCODECATEGORY_ID_MODULE_MASTER_ID = (SELECT top 1 ID FROM [Common].[ControlCodeCategory] WHERE COMPANYID=@NEW_COMPANY_ID AND CONTROLCODECATEGORYCODE='ResetLeaveBalance')
		SET @MODULE_MASTER_ID_CONTROLCODECATEGORY_ID = (SELECT Id FROM [Common].[ModuleMaster]  WHERE COMPANYID=@UNIQUE_COMPANY_ID AND NAME='HR Cursor')
		INSERT INTO [Common].[ControlCodeCategoryModule] (Id, CompanyId, ControlCategoryId, ModuleMasterId) VALUES ((SELECT MAX(Id) + 1 FROM [Common].[ControlCodeCategoryModule]),
		@NEW_COMPANY_ID,@CONTROLCODECATEGORY_ID_MODULE_MASTER_ID,@MODULE_MASTER_ID_CONTROLCODECATEGORY_ID);	
		
		
		
	SET @CONTROLCODECATEGORY_ID_MODULE_MASTER_ID = (SELECT top 1 ID FROM [Common].[ControlCodeCategory] WHERE COMPANYID=@NEW_COMPANY_ID AND CONTROLCODECATEGORYCODE='WorkingHours')
	 SET @MODULE_MASTER_ID_CONTROLCODECATEGORY_ID = (SELECT Id FROM [Common].[ModuleMaster]  WHERE COMPANYID=@UNIQUE_COMPANY_ID AND NAME='HR Cursor')
  INSERT INTO [Common].[ControlCodeCategoryModule] (Id, CompanyId, ControlCategoryId, ModuleMasterId) VALUES ((SELECT MAX(Id) + 1 FROM [Common].[ControlCodeCategoryModule]),
  @NEW_COMPANY_ID,@CONTROLCODECATEGORY_ID_MODULE_MASTER_ID,@MODULE_MASTER_ID_CONTROLCODECATEGORY_ID); 

  
   SET @CONTROLCODECATEGORY_ID_MODULE_MASTER_ID = (SELECT top 1 ID FROM [Common].[ControlCodeCategory] WHERE COMPANYID=@NEW_COMPANY_ID AND CONTROLCODECATEGORYCODE='AttendenceType')
  SET @MODULE_MASTER_ID_CONTROLCODECATEGORY_ID = (SELECT Id FROM [Common].[ModuleMaster]  WHERE COMPANYID=@UNIQUE_COMPANY_ID AND NAME='HR Cursor')
  INSERT INTO [Common].[ControlCodeCategoryModule] (Id, CompanyId, ControlCategoryId, ModuleMasterId) VALUES ((SELECT MAX(Id) + 1 FROM [Common].[ControlCodeCategoryModule]),
  @NEW_COMPANY_ID,@CONTROLCODECATEGORY_ID_MODULE_MASTER_ID,@MODULE_MASTER_ID_CONTROLCODECATEGORY_ID); 

  
   SET @CONTROLCODECATEGORY_ID_MODULE_MASTER_ID = (SELECT top 1 ID FROM [Common].[ControlCodeCategory] WHERE COMPANYID=@NEW_COMPANY_ID AND CONTROLCODECATEGORYCODE='WorkingType')
  SET @MODULE_MASTER_ID_CONTROLCODECATEGORY_ID = (SELECT Id FROM [Common].[ModuleMaster]  WHERE COMPANYID=@UNIQUE_COMPANY_ID AND NAME='HR Cursor')
  INSERT INTO [Common].[ControlCodeCategoryModule] (Id, CompanyId, ControlCategoryId, ModuleMasterId) VALUES ((SELECT MAX(Id) + 1 FROM [Common].[ControlCodeCategoryModule]),
  
  @NEW_COMPANY_ID,@CONTROLCODECATEGORY_ID_MODULE_MASTER_ID,@MODULE_MASTER_ID_CONTROLCODECATEGORY_ID);
  
   SET @CONTROLCODECATEGORY_ID_MODULE_MASTER_ID = (SELECT top 1 ID FROM [Common].[ControlCodeCategory] WHERE COMPANYID=@NEW_COMPANY_ID AND CONTROLCODECATEGORYCODE='WorkingType')
  SET @MODULE_MASTER_ID_CONTROLCODECATEGORY_ID = (SELECT Id FROM [Common].[ModuleMaster]  WHERE COMPANYID=@UNIQUE_COMPANY_ID AND NAME='HR Cursor')
  INSERT INTO [Common].[ControlCodeCategoryModule] (Id, CompanyId, ControlCategoryId, ModuleMasterId) VALUES ((SELECT MAX(Id) + 1 FROM [Common].[ControlCodeCategoryModule]),
  @NEW_COMPANY_ID,@CONTROLCODECATEGORY_ID_MODULE_MASTER_ID,@MODULE_MASTER_ID_CONTROLCODECATEGORY_ID);

  
  -- SET @CONTROLCODECATEGORY_ID_MODULE_MASTER_ID = (SELECT top 1 ID FROM [Common].[ControlCodeCategory] WHERE COMPANYID=@NEW_COMPANY_ID AND CONTROLCODECATEGORYCODE='ChargeType')
  --SET @MODULE_MASTER_ID_CONTROLCODECATEGORY_ID = (SELECT Id FROM [Common].[ModuleMaster]  WHERE COMPANYID=@UNIQUE_COMPANY_ID AND NAME='Workflow Cursor')
  --INSERT INTO [Common].[ControlCodeCategoryModule] (Id, CompanyId, ControlCategoryId, ModuleMasterId) VALUES ((SELECT MAX(Id) + 1 FROM [Common].[ControlCodeCategoryModule]),
  --@NEW_COMPANY_ID,@CONTROLCODECATEGORY_ID_MODULE_MASTER_ID,@MODULE_MASTER_ID_CONTROLCODECATEGORY_ID);


 SET @CONTROLCODECATEGORY_ID_MODULE_MASTER_ID = (SELECT top 1 ID FROM [Common].[ControlCodeCategory] WHERE COMPANYID=@NEW_COMPANY_ID AND CONTROLCODECATEGORYCODE='Type')
  SET @MODULE_MASTER_ID_CONTROLCODECATEGORY_ID = (SELECT Id FROM [Common].[ModuleMaster]  WHERE COMPANYID=@UNIQUE_COMPANY_ID AND NAME='Workflow Cursor')
  INSERT INTO [Common].[ControlCodeCategoryModule] (Id, CompanyId, ControlCategoryId, ModuleMasterId) VALUES ((SELECT MAX(Id) + 1 FROM [Common].[ControlCodeCategoryModule]),
  @NEW_COMPANY_ID,@CONTROLCODECATEGORY_ID_MODULE_MASTER_ID,@MODULE_MASTER_ID_CONTROLCODECATEGORY_ID);


    
 SET @CONTROLCODECATEGORY_ID_MODULE_MASTER_ID = (SELECT top 1 ID FROM [Common].[ControlCodeCategory] WHERE COMPANYID=@NEW_COMPANY_ID AND CONTROLCODECATEGORYCODE='Reason')
  SET @MODULE_MASTER_ID_CONTROLCODECATEGORY_ID = (SELECT Id FROM [Common].[ModuleMaster]  WHERE COMPANYID=@UNIQUE_COMPANY_ID AND NAME='Workflow Cursor')
  INSERT INTO [Common].[ControlCodeCategoryModule] (Id, CompanyId, ControlCategoryId, ModuleMasterId) VALUES ((SELECT MAX(Id) + 1 FROM [Common].[ControlCodeCategoryModule]),
  @NEW_COMPANY_ID,@CONTROLCODECATEGORY_ID_MODULE_MASTER_ID,@MODULE_MASTER_ID_CONTROLCODECATEGORY_ID);


   SET @CONTROLCODECATEGORY_ID_MODULE_MASTER_ID = (SELECT top 1 ID FROM [Common].[ControlCodeCategory] WHERE COMPANYID=@NEW_COMPANY_ID AND CONTROLCODECATEGORYCODE='IncidentalClaimUnit')
  SET @MODULE_MASTER_ID_CONTROLCODECATEGORY_ID = (SELECT Id FROM [Common].[ModuleMaster]  WHERE COMPANYID=@UNIQUE_COMPANY_ID AND NAME='Admin Cursor')
  INSERT INTO [Common].[ControlCodeCategoryModule] (Id, CompanyId, ControlCategoryId, ModuleMasterId) VALUES ((SELECT MAX(Id) + 1 FROM [Common].[ControlCodeCategoryModule]),
  @NEW_COMPANY_ID,@CONTROLCODECATEGORY_ID_MODULE_MASTER_ID,@MODULE_MASTER_ID_CONTROLCODECATEGORY_ID);

     SET @CONTROLCODECATEGORY_ID_MODULE_MASTER_ID = (SELECT top 1 ID FROM [Common].[ControlCodeCategory] WHERE COMPANYID=@NEW_COMPANY_ID AND CONTROLCODECATEGORYCODE='EntityAddress')
  SET @MODULE_MASTER_ID_CONTROLCODECATEGORY_ID = (SELECT Id FROM [Common].[ModuleMaster]  WHERE COMPANYID=@UNIQUE_COMPANY_ID AND NAME='Workflow Cursor')
  INSERT INTO [Common].[ControlCodeCategoryModule] (Id, CompanyId, ControlCategoryId, ModuleMasterId) VALUES ((SELECT MAX(Id) + 1 FROM [Common].[ControlCodeCategoryModule]),
  @NEW_COMPANY_ID,@CONTROLCODECATEGORY_ID_MODULE_MASTER_ID,@MODULE_MASTER_ID_CONTROLCODECATEGORY_ID);

  

   SET @CONTROLCODECATEGORY_ID_MODULE_MASTER_ID = (SELECT top 1 ID FROM [Common].[ControlCodeCategory] WHERE COMPANYID=@NEW_COMPANY_ID AND CONTROLCODECATEGORYCODE='IndividualAddress')
  SET @MODULE_MASTER_ID_CONTROLCODECATEGORY_ID = (SELECT Id FROM [Common].[ModuleMaster]  WHERE COMPANYID=@UNIQUE_COMPANY_ID AND NAME='Workflow Cursor')
  INSERT INTO [Common].[ControlCodeCategoryModule] (Id, CompanyId, ControlCategoryId, ModuleMasterId) VALUES ((SELECT MAX(Id) + 1 FROM [Common].[ControlCodeCategoryModule]),
  @NEW_COMPANY_ID,@CONTROLCODECATEGORY_ID_MODULE_MASTER_ID,@MODULE_MASTER_ID_CONTROLCODECATEGORY_ID);


  
     SET @CONTROLCODECATEGORY_ID_MODULE_MASTER_ID = (SELECT top 1 ID FROM [Common].[ControlCodeCategory] WHERE COMPANYID=@NEW_COMPANY_ID AND CONTROLCODECATEGORYCODE='ReasonForCancel')
  SET @MODULE_MASTER_ID_CONTROLCODECATEGORY_ID = (SELECT Id FROM [Common].[ModuleMaster]  WHERE COMPANYID=@UNIQUE_COMPANY_ID AND NAME='Workflow Cursor')
  INSERT INTO [Common].[ControlCodeCategoryModule] (Id, CompanyId, ControlCategoryId, ModuleMasterId) VALUES ((SELECT MAX(Id) + 1 FROM [Common].[ControlCodeCategoryModule]),
  @NEW_COMPANY_ID,@CONTROLCODECATEGORY_ID_MODULE_MASTER_ID,@MODULE_MASTER_ID_CONTROLCODECATEGORY_ID);


  
       SET @CONTROLCODECATEGORY_ID_MODULE_MASTER_ID = (SELECT top 1 ID FROM [Common].[ControlCodeCategory] WHERE COMPANYID=@NEW_COMPANY_ID AND CONTROLCODECATEGORYCODE='PayMethod')
  SET @MODULE_MASTER_ID_CONTROLCODECATEGORY_ID = (SELECT Id FROM [Common].[ModuleMaster]  WHERE COMPANYID=@UNIQUE_COMPANY_ID AND NAME='HR Cursor')
  INSERT INTO [Common].[ControlCodeCategoryModule] (Id, CompanyId, ControlCategoryId, ModuleMasterId) VALUES ((SELECT MAX(Id) + 1 FROM [Common].[ControlCodeCategoryModule]),
  @NEW_COMPANY_ID,@CONTROLCODECATEGORY_ID_MODULE_MASTER_ID,@MODULE_MASTER_ID_CONTROLCODECATEGORY_ID);

  
       SET @CONTROLCODECATEGORY_ID_MODULE_MASTER_ID = (SELECT top 1 ID FROM [Common].[ControlCodeCategory] WHERE COMPANYID=@NEW_COMPANY_ID AND CONTROLCODECATEGORYCODE='PayComponentType')
  SET @MODULE_MASTER_ID_CONTROLCODECATEGORY_ID = (SELECT Id FROM [Common].[ModuleMaster]  WHERE COMPANYID=@UNIQUE_COMPANY_ID AND NAME='HR Cursor')
  INSERT INTO [Common].[ControlCodeCategoryModule] (Id, CompanyId, ControlCategoryId, ModuleMasterId) VALUES ((SELECT MAX(Id) + 1 FROM [Common].[ControlCodeCategoryModule]),
  @NEW_COMPANY_ID,@CONTROLCODECATEGORY_ID_MODULE_MASTER_ID,@MODULE_MASTER_ID_CONTROLCODECATEGORY_ID);

         SET @CONTROLCODECATEGORY_ID_MODULE_MASTER_ID = (SELECT top 1 ID FROM [Common].[ControlCodeCategory] WHERE COMPANYID=@NEW_COMPANY_ID AND CONTROLCODECATEGORYCODE='Tax Classification')
  SET @MODULE_MASTER_ID_CONTROLCODECATEGORY_ID = (SELECT Id FROM [Common].[ModuleMaster]  WHERE COMPANYID=@UNIQUE_COMPANY_ID AND NAME='HR Cursor')
  INSERT INTO [Common].[ControlCodeCategoryModule] (Id, CompanyId, ControlCategoryId, ModuleMasterId) VALUES ((SELECT MAX(Id) + 1 FROM [Common].[ControlCodeCategoryModule]),
  @NEW_COMPANY_ID,@CONTROLCODECATEGORY_ID_MODULE_MASTER_ID,@MODULE_MASTER_ID_CONTROLCODECATEGORY_ID);

  
       SET @CONTROLCODECATEGORY_ID_MODULE_MASTER_ID = (SELECT top 1 ID FROM [Common].[ControlCodeCategory] WHERE COMPANYID=@NEW_COMPANY_ID AND CONTROLCODECATEGORYCODE='ContributionFor')
  SET @MODULE_MASTER_ID_CONTROLCODECATEGORY_ID = (SELECT Id FROM [Common].[ModuleMaster]  WHERE COMPANYID=@UNIQUE_COMPANY_ID AND NAME='HR Cursor')
  INSERT INTO [Common].[ControlCodeCategoryModule] (Id, CompanyId, ControlCategoryId, ModuleMasterId) VALUES ((SELECT MAX(Id) + 1 FROM [Common].[ControlCodeCategoryModule]),
  @NEW_COMPANY_ID,@CONTROLCODECATEGORY_ID_MODULE_MASTER_ID,@MODULE_MASTER_ID_CONTROLCODECATEGORY_ID);

     SET @CONTROLCODECATEGORY_ID_MODULE_MASTER_ID = (SELECT top 1 ID FROM [Common].[ControlCodeCategory] WHERE COMPANYID=@NEW_COMPANY_ID AND CONTROLCODECATEGORYCODE='MileStone')
  SET @MODULE_MASTER_ID_CONTROLCODECATEGORY_ID = (SELECT Id FROM [Common].[ModuleMaster]  WHERE COMPANYID=@UNIQUE_COMPANY_ID AND NAME='Admin Cursor')
  INSERT INTO [Common].[ControlCodeCategoryModule] (Id, CompanyId, ControlCategoryId, ModuleMasterId) VALUES ((SELECT MAX(Id) + 1 FROM [Common].[ControlCodeCategoryModule]),
  @NEW_COMPANY_ID,@CONTROLCODECATEGORY_ID_MODULE_MASTER_ID,@MODULE_MASTER_ID_CONTROLCODECATEGORY_ID);

     SET @CONTROLCODECATEGORY_ID_MODULE_MASTER_ID = (SELECT top 1 ID FROM [Common].[ControlCodeCategory] WHERE COMPANYID=@NEW_COMPANY_ID AND CONTROLCODECATEGORYCODE='Task')
  SET @MODULE_MASTER_ID_CONTROLCODECATEGORY_ID = (SELECT Id FROM [Common].[ModuleMaster]  WHERE COMPANYID=@UNIQUE_COMPANY_ID AND NAME='Admin Cursor')
  INSERT INTO [Common].[ControlCodeCategoryModule] (Id, CompanyId, ControlCategoryId, ModuleMasterId) VALUES ((SELECT MAX(Id) + 1 FROM [Common].[ControlCodeCategoryModule]),
  @NEW_COMPANY_ID,@CONTROLCODECATEGORY_ID_MODULE_MASTER_ID,@MODULE_MASTER_ID_CONTROLCODECATEGORY_ID);

   	SET @CONTROLCODECATEGORY_ID_MODULE_MASTER_ID = (SELECT top 1 ID FROM [Common].[ControlCodeCategory] WHERE COMPANYID=@NEW_COMPANY_ID AND CONTROLCODECATEGORYCODE='Designation')
		SET @MODULE_MASTER_ID_CONTROLCODECATEGORY_ID = (SELECT Id FROM [Common].[ModuleMaster]  WHERE COMPANYID=@UNIQUE_COMPANY_ID AND NAME='Workflow Cursor')
		INSERT INTO [Common].[ControlCodeCategoryModule] (Id, CompanyId, ControlCategoryId, ModuleMasterId) VALUES ((SELECT MAX(Id) + 1 FROM [Common].[ControlCodeCategoryModule]),
		@NEW_COMPANY_ID,@CONTROLCODECATEGORY_ID_MODULE_MASTER_ID,@MODULE_MASTER_ID_CONTROLCODECATEGORY_ID);
  ----------------------------------------------WorkWeekSetup-------------------------------------------------------------------------------------------------------------------------		
		
--INSERT INTO [Common].[WorkWeekSetUp](Id,CompanyId,WeekDay,AMFromTime,AMToTime,PMFromTime,PMToTime,WorkingHours,UserCreated,CreatedDate,ModifiedBy,ModifiedDate,Remarks,Status,IsWorkingDay,RecOrder)
--SELECT (NEWID()),@NEW_COMPANY_ID,WeekDay,AMFromTime,AMToTime,PMFromTime,PMToTime,WorkingHours,UserCreated,GETUTCDATE(),ModifiedBy,ModifiedDate,Remarks,Status,IsWorkingDay,RecOrder
--FROM [Common].[WorkWeekSetUp] WHERE COMPANYID=@UNIQUE_COMPANY_ID;	

INSERT INTO [Common].[WorkWeekSetUp]([Id],[CompanyId],[WeekDay],[AMFromTime] ,[AMToTime],[PMFromTime],[PMToTime],[WorkingHours],[UserCreated],[CreatedDate],[ModifiedBy],[ModifiedDate],[Remarks],[Status],[IsWorkingDay],[RecOrder])
VALUES(NEWID(),@NEW_COMPANY_ID,'Monday','09:00:00','13:00:00','14:00:00','18:00:00','08:00:00','madhu@kgtan.com',GETUTCDATE(),null,null,null,1,1,1)

INSERT INTO [Common].[WorkWeekSetUp]([Id],[CompanyId],[WeekDay],[AMFromTime] ,[AMToTime],[PMFromTime],[PMToTime],[WorkingHours],[UserCreated],[CreatedDate],[ModifiedBy],[ModifiedDate],[Remarks],[Status],[IsWorkingDay],[RecOrder])
VALUES(NEWID(),@NEW_COMPANY_ID,'Tuesday','09:00:00','13:00:00','14:00:00','18:00:00','08:00:00','madhu@kgtan.com',GETUTCDATE(),null,null,null,1,1,2)

INSERT INTO [Common].[WorkWeekSetUp]([Id],[CompanyId],[WeekDay],[AMFromTime] ,[AMToTime],[PMFromTime],[PMToTime],[WorkingHours],[UserCreated],[CreatedDate],[ModifiedBy],[ModifiedDate],[Remarks],[Status],[IsWorkingDay],[RecOrder])
VALUES(NEWID(),@NEW_COMPANY_ID,'Wednesday','09:00:00','13:00:00','14:00:00','18:00:00','08:00:00','madhu@kgtan.com',GETUTCDATE(),null,null,null,1,1,3)

INSERT INTO [Common].[WorkWeekSetUp]([Id],[CompanyId],[WeekDay],[AMFromTime] ,[AMToTime],[PMFromTime],[PMToTime],[WorkingHours],[UserCreated],[CreatedDate],[ModifiedBy],[ModifiedDate],[Remarks],[Status],[IsWorkingDay],[RecOrder])
VALUES(NEWID(),@NEW_COMPANY_ID,'Thursday','09:00:00','13:00:00','14:00:00','18:00:00','08:00:00','madhu@kgtan.com',GETUTCDATE(),null,null,null,1,1,4)

INSERT INTO [Common].[WorkWeekSetUp]([Id],[CompanyId],[WeekDay],[AMFromTime] ,[AMToTime],[PMFromTime],[PMToTime],[WorkingHours],[UserCreated],[CreatedDate],[ModifiedBy],[ModifiedDate],[Remarks],[Status],[IsWorkingDay],[RecOrder])
VALUES(NEWID(),@NEW_COMPANY_ID,'Friday','09:00:00','13:00:00','14:00:00','18:00:00','08:00:00','madhu@kgtan.com',GETUTCDATE(),null,null,null,1,1,5)

DECLARE @IDs UNIQUEIDENTIFIER
SET @IDs=NEWID()
INSERT INTO [Common].[WorkWeekSetUp]([Id],[CompanyId],[WeekDay],[AMFromTime] ,[AMToTime],[PMFromTime],[PMToTime],[WorkingHours],[UserCreated],[CreatedDate],[ModifiedBy],[ModifiedDate],[Remarks],[Status],[IsWorkingDay],[RecOrder])
VALUES(@IDs,@NEW_COMPANY_ID,'Saturday','00:00:00','00:00:00','00:00:00','00:00:00','00:00:00','madhu@kgtan.com',GETUTCDATE(),null,null,null,1,0,6)

INSERT INTO [Common].[TimeLogItem]([Id],[CompanyId],[Type],[SubType],[ChargeType],[SystemType],[SystemId],[IsSystem],[Remarks],[RecOrder] ,[UserCreated] ,[CreatedDate],[ModifiedBy],[ModifiedDate],[Version],[Status],[ApplyToAll],[StartDate],[EndDate])
Values(NEWID(),@NEW_COMPANY_ID,'WorkWeekSetUp','Saturday','Non-Working','WorkWeekSetUp',@IDs,1,'',1,'',GETUTCDATE(),null,null,1,1,1,null,null)



DECLARE @NewID UNIQUEIDENTIFIER
SET  @NewID = NEWID()
INSERT INTO [Common].[WorkWeekSetUp]([Id],[CompanyId],[WeekDay],[AMFromTime] ,[AMToTime],[PMFromTime],[PMToTime],[WorkingHours],[UserCreated],[CreatedDate],[ModifiedBy],[ModifiedDate],[Remarks],[Status],[IsWorkingDay],[RecOrder])
VALUES(@NewID,@NEW_COMPANY_ID,'Sunday','00:00:00','00:00:00','00:00:00','00:00:00','00:00:00','madhu@kgtan.com',GETUTCDATE(),null,null,null,1,0,7)

INSERT INTO [Common].[TimeLogItem]([Id],[CompanyId],[Type],[SubType],[ChargeType],[SystemType],[SystemId],[IsSystem],[Remarks],[RecOrder] ,[UserCreated] ,[CreatedDate],[ModifiedBy],[ModifiedDate],[Version],[Status],[ApplyToAll],[StartDate],[EndDate])
Values(NEWID(),@NEW_COMPANY_ID,'WorkWeekSetUp','Sunday','Non-Working','WorkWeekSetUp',@NewID,1,'',2,'',GETUTCDATE(),null,null,1,1,1,null,null)


-------------------------------17-09-2016----TimeLogPeriod-----------------------------------------------
 
 SET @CONTROLCODECATEGORY_ID_MODULE_MASTER_ID = (SELECT top 1 ID FROM [Common].[ControlCodeCategory] WHERE COMPANYID=@NEW_COMPANY_ID AND CONTROLCODECATEGORYCODE='TimeLogPeriod')
  SET @MODULE_MASTER_ID_CONTROLCODECATEGORY_ID = (SELECT Id FROM [Common].[ModuleMaster]  WHERE COMPANYID=@UNIQUE_COMPANY_ID AND NAME='Admin Cursor')
  INSERT INTO [Common].[ControlCodeCategoryModule] (Id, CompanyId, ControlCategoryId, ModuleMasterId) VALUES ((SELECT MAX(Id) + 1 FROM [Common].[ControlCodeCategoryModule]),
  @NEW_COMPANY_ID,@CONTROLCODECATEGORY_ID_MODULE_MASTER_ID,@MODULE_MASTER_ID_CONTROLCODECATEGORY_ID);

			
			---WorkProgramSetup---14/8/2017
INSERT INTO [Audit].[WPSetup]
 select NEWID(),@NEW_COMPANY_ID as CompanyId,[Code],[Description],[Remarks],[RecOrder],[UserCreated],GETUTCDATE() as [CreatedDate],NULL as [ModifiedBy],NULL as [ModifiedDate],[Version],[Status],[ShortCode]
 From [Audit].[WPSetup] Where CompanyId = @UNIQUE_COMPANY_ID;

-----Leadsheet Setup-----
-- Insert Into [Audit].[Leadsheet] (Id, CompanyId, WorkProgramId, [Index], LeadsheetType, AccountClass, IsSystem, LeadSheetName, FinancialStatementTemplate, Remarks, RecOrder, UserCreated, CreatedDate, ModifiedBy, ModifiedDate, Version, Status )

--select Newid() as leadsheetid, @NEW_COMPANY_ID as newcompanyid,pp.Newcompanyid, [Index], LeadsheetType, AccountClass, IsSystem, LeadSheetName, FinancialStatementTemplate, Remarks, RecOrder, UserCreated, GETUTCDATE(),NULL AS ModifiedBy,NULL AS ModifiedDate, Version, Status from  [Audit].[LeadSheet]  as L
--INNER JOIN
--(
--select P.Id as 'Newcompanyid',w.Id as 'Oldcompanyid' from audit.WPSetup as w
--INNER JOIN 
--(

--select id,code,Description from audit.WPSetup where companyid =@NEW_COMPANY_ID

--) as p ON P.Code=w.Code and P.Description=w.Description

--where companyid in (@UNIQUE_COMPANY_ID)
--) as PP On PP.Oldcompanyid=WorkProgramId

--where CompanyId=@UNIQUE_COMPANY_ID
--  ---LeadSheetCategories-----
--Insert Into [Audit].[LeadSheetCategories]
--  ([Id],[LeadsheetID],[Name],[RecOrder],[Status])
--  SELECT newid() as Id
--,(select ID FROM [Audit].[LeadSheet] where CompanyId = @NEW_COMPANY_ID and LeadSheetName = (select LeadSheetName FROM [Audit].[LeadSheet] where Id = cat.[LeadsheetID] and CompanyId = @UNIQUE_COMPANY_ID))   as [LeadsheetID]
--	  ,cat.[Name]	 
--	  ,1
--	  ,cat.[Status]
--  FROM [Audit].[LeadSheetCategories] cat inner join [Audit].[LeadSheet] ld
--  on ld.Id = cat.LeadsheetID 
--  where ld.CompanyId = @UNIQUE_COMPANY_ID

  ---TickMarkSetup
    INSERT INTO [Audit].[TickMarkSetup]
 select NEWID(),@NEW_COMPANY_ID as CompanyId,[Code],[Description],[IsSystem],[Remarks],[RecOrder],[UserCreated],GETUTCDATE() as [CreatedDate],NULL AS [ModifiedBy],NULL AS [ModifiedDate],[Version],[Status]
 From [Audit].[TickMarkSetup] Where CompanyId = @UNIQUE_COMPANY_ID;

			------------------------10-25-2016--------
------SP For CompanyFeatures---
	   

	    
   BEGIN
INSERT INTO common.CompanyFeatures( Id, CompanyId, FeatureId, Status,  Remarks,IsChecked)
		select  NEWID(),@NEW_COMPANY_ID,b.FeatureId,b.Status,b.Remarks,b.IsChecked from [Common].[Feature] a join [Common].[CompanyFeatures] b on a.Id=b.FeatureId where a.VisibleStyle <> 'SuperUser-CheckBox' and a.VisibleStyle <> 'HRCursor-CheckBox' and CompanyId=0
 

END;
------SP For CompanyModuleSetUp---

	BEGIN
   IF NOT EXISTS (SELECT * FROM [Common].[CompanyFeatures] 
                   WHERE  [CompanyId] = @NEW_COMPANY_ID)
   BEGIN   
 INSERT INTO  [Common].[CompanyModuleSetUp] (Id, CompanyId,ModuleId,ModuleDetailUrl, Heading,SetUpOrder,IsMandatory,IsSetUpDone)  
       SELECT (NEWID()),@NEW_COMPANY_ID,ModuleId,ModuleDetailUrl, Heading,SetUpOrder,IsMandatory,IsSetUpDone FROM [Common].[CompanyModuleSetUp] WHERE COMPANYID=0	     
   END
END;

-----------------------Report and Report_Category and Report_Category_Report----------------------------------
BEGIN
EXEC [dbo].[SP_Report_Category_Report] @UNIQUE_COMPANY_ID,@CREATED_DATE,@NEW_COMPANY_ID
END


----------[HR].[WorkProfile]-----------------------------------------------

INSERT INTO HR.WorkProfile (Id, CompanyId, WorkProfileName, WorkingHoursPerDay, Monday, Tuesday, Wednenday, Thursday, Friday, Saturday, Sunday, TotalWorkingDaysPerWeek, TotalWorkingHoursPerWeek, IsDefaultProfile, IsSuperUserRec, Remarks, UserCreated, CreatedDate, ModifiedDate, ModifiedBy, RecOrder, Status, Version)
SELECT NEWID(), @NEW_COMPANY_ID, WorkProfileName, WorkingHoursPerDay, Monday, Tuesday, Wednenday, Thursday, Friday, Saturday, Sunday, TotalWorkingDaysPerWeek, TotalWorkingHoursPerWeek, IsDefaultProfile, 1, Remarks, UserCreated, CreatedDate, ModifiedDate, ModifiedBy, RecOrder, Status, Version FROM HR.WorkProfile WHERE CompanyId=@UNIQUE_COMPANY_ID

---------[HR].[WorkProfileDetails]---------------------------------------

INSERT INTO [HR].[WorkProfileDetails]  (Id, MasterId, Year, JanuaryDays, FebruaryDays, MarchDays, AprilDays, MayDays, JuneDays, JulyDays, AugustDays, SeptemberDays, OctoberDays, NovemberDays, DecemberDays, TotalWorkingHoursPerYear, TotalWorkingDaysPerYear,IsDefaultProfile,Remarks, UserCreated, CreatedDate, ModifiedDate, ModifiedBy, RecOrder, Status, Version)
SELECT NEWID(), (SELECT Id FROM HR.WorkProfile WHERE CompanyId=@NEW_COMPANY_ID AND WorkProfileName = (select WorkProfileName FROM [HR].[WorkProfile] where Id = WD.MasterId and CompanyId = @UNIQUE_COMPANY_ID)) as [MasterId], WD.Year, WD.JanuaryDays, WD.FebruaryDays, WD.MarchDays, WD.AprilDays, WD.MayDays, WD.JuneDays, WD.JulyDays, WD.AugustDays, WD.SeptemberDays, WD.OctoberDays, WD.NovemberDays, WD.DecemberDays, WD.TotalWorkingHoursPerYear, WD.TotalWorkingDaysPerYear,WD.IsDefaultProfile, WD.Remarks, WD.UserCreated, GETUTCDATE() as [CreatedDate], WD.ModifiedDate, WD.ModifiedBy, WD.RecOrder, WD.Status, WD.Version 
FROM [HR].[WorkProfileDetails] WD INNER JOIN [HR].[WorkProfile] W
ON W.Id = WD.MasterId
WHERE W.COMPANYID = @UNIQUE_COMPANY_ID


------------------------[HR].[WorkProfile]----------Seed Data--------------------
				
		--UPDATE [Auth].[Role] SET [TempId] = NULL WHERE COMPANYID = @NEW_COMPANY_ID;
		UPDATE [Common].[IdType] SET[TempIdTypeId] = NULL WHERE COMPANYID = @NEW_COMPANY_ID;
		UPDATE [Common].[AccountType] SET [TempAccountTypeId] = NULL WHERE COMPANYID = @NEW_COMPANY_ID;

		----------------------24/11/2016------------WorkType---------------------------------------------

		 SET @CONTROLCODECATEGORY_ID_MODULE_MASTER_ID = (SELECT top 1 ID FROM [Common].[ControlCodeCategory] WHERE COMPANYID=@NEW_COMPANY_ID AND CONTROLCODECATEGORYCODE='WorkType')
  SET @MODULE_MASTER_ID_CONTROLCODECATEGORY_ID = (SELECT Id FROM [Common].[ModuleMaster]  WHERE COMPANYID=@UNIQUE_COMPANY_ID AND NAME='Admin Cursor')
  INSERT INTO [Common].[ControlCodeCategoryModule] (Id, CompanyId, ControlCategoryId, ModuleMasterId) VALUES ((SELECT MAX(Id) + 1 FROM [Common].[ControlCodeCategoryModule]),
  @NEW_COMPANY_ID,@CONTROLCODECATEGORY_ID_MODULE_MASTER_ID,@MODULE_MASTER_ID_CONTROLCODECATEGORY_ID);
  --------------------------------------------------------Attendance Rules  ------------------------------------------------------------------------
		INSERT [Common].[AttendanceRules] ([Id], [CompanyId], [LateInTime], [LateInType], [LateInTimeType], [LateInStatus], [LateOutTime], [LateOutType], [LateOutTimeType], [LateOutStatus], [PreviousTime], [PreviousType], [PreviousTimeType], [PreviousStatus] ,[UserCreated]      ,[CreatedDate]      ,[ModifiedBy]      ,[ModifiedDate]      ,[Version]      ,[Status]) VALUES (NEWID(), @NEW_COMPANY_ID , 10, N'After', N'FromTime', 1, 240, N'After', N'ToTime', 1, 300, N'Before', N'FromTime', 0,'madhu@kgtan.com',GETUTCDATE(),NULL,NULL,NULL,1)
		-----------------------------------------------------------PayrollStatus-------------------------------------------------
		 SET @CONTROLCODECATEGORY_ID_MODULE_MASTER_ID = (SELECT top 1 ID FROM [Common].[ControlCodeCategory] WHERE COMPANYID=@NEW_COMPANY_ID AND CONTROLCODECATEGORYCODE='PayrollStatus')
  SET @MODULE_MASTER_ID_CONTROLCODECATEGORY_ID = (SELECT Id FROM [Common].[ModuleMaster]  WHERE COMPANYID=@UNIQUE_COMPANY_ID AND NAME='HR Cursor')
  INSERT INTO [Common].[ControlCodeCategoryModule] (Id, CompanyId, ControlCategoryId, ModuleMasterId) VALUES ((SELECT MAX(Id) + 1 FROM [Common].[ControlCodeCategoryModule]),
  @NEW_COMPANY_ID,@CONTROLCODECATEGORY_ID_MODULE_MASTER_ID,@MODULE_MASTER_ID_CONTROLCODECATEGORY_ID);
  ------------------------------------------28/12/2016  sudhakiran----------------------------------------------------
  BEGIN
   IF NOT EXISTS (SELECT * FROM [Hr].[PayComponent] 
                   WHERE  [CompanyId] = @NEW_COMPANY_ID)
   BEGIN   
 INSERT INTO  [Hr].[PayComponent]  ( [Id],[CompanyId],[Name],[ShortCode],[Type],[WageType],[IsCPF],[IsNsPay],[IsTAX],[IsSDL],[IR8AItemSection],[PayMethod],[Amount],[PercentageComponent],[Percentage],[Formula],[IsAdjustable],[MaxCap],[ApplyTo],[IsExcludeFromGrossWage],[TaxClassification],[Reamrks],[UserCreated],[CreatedDate],[ModifiedDate],[ModifiedBy],[RecOrder],[Status],[IsSystem],[DefaultCOA],[DefaultVendor])  
       SELECT (NEWID()),@NEW_COMPANY_ID,[Name],[ShortCode],[Type],[WageType],[IsCPF],[IsNsPay],[IsTAX],[IsSDL],[IR8AItemSection],[PayMethod],[Amount],[PercentageComponent],[Percentage],[Formula],[IsAdjustable],[MaxCap],[ApplyTo],[IsExcludeFromGrossWage],[TaxClassification],[Reamrks],[UserCreated],[CreatedDate],[ModifiedDate],[ModifiedBy],[RecOrder],[Status],[IsSystem],[DefaultCOA],[DefaultVendor] FROM [Hr].[PayComponent]  WHERE COMPANYID=0	     
   END
END;

-------------------------- Claims Category [Others] ---------------------------------------------

 SET @CONTROLCODECATEGORY_ID_MODULE_MASTER_ID = (SELECT top 1 ID FROM [Common].[ControlCodeCategory] WHERE COMPANYID=@NEW_COMPANY_ID AND CONTROLCODECATEGORYCODE='Claims Category')
  SET @MODULE_MASTER_ID_CONTROLCODECATEGORY_ID = (SELECT Id FROM [Common].[ModuleMaster]  WHERE COMPANYID=@UNIQUE_COMPANY_ID AND NAME='Admin Cursor')
  INSERT INTO [Common].[ControlCodeCategoryModule] (Id, CompanyId, ControlCategoryId, ModuleMasterId) VALUES ((SELECT MAX(Id) + 1 FROM [Common].[ControlCodeCategoryModule]),
  @NEW_COMPANY_ID,@CONTROLCODECATEGORY_ID_MODULE_MASTER_ID,@MODULE_MASTER_ID_CONTROLCODECATEGORY_ID);

  
-------------------------- Assets ---------------------------------------------

 SET @CONTROLCODECATEGORY_ID_MODULE_MASTER_ID = (SELECT top 1 ID FROM [Common].[ControlCodeCategory] WHERE COMPANYID=@NEW_COMPANY_ID AND CONTROLCODECATEGORYCODE='Assets')
  SET @MODULE_MASTER_ID_CONTROLCODECATEGORY_ID = (SELECT Id FROM [Common].[ModuleMaster]  WHERE COMPANYID=@UNIQUE_COMPANY_ID AND NAME='Admin Cursor')
  INSERT INTO [Common].[ControlCodeCategoryModule] (Id, CompanyId, ControlCategoryId, ModuleMasterId) VALUES ((SELECT MAX(Id) + 1 FROM [Common].[ControlCodeCategoryModule]),
  @NEW_COMPANY_ID,@CONTROLCODECATEGORY_ID_MODULE_MASTER_ID,@MODULE_MASTER_ID_CONTROLCODECATEGORY_ID);

    
-------------------------- Liabilities ---------------------------------------------

 SET @CONTROLCODECATEGORY_ID_MODULE_MASTER_ID = (SELECT top 1 ID FROM [Common].[ControlCodeCategory] WHERE COMPANYID=@NEW_COMPANY_ID AND CONTROLCODECATEGORYCODE='Liabilities')
  SET @MODULE_MASTER_ID_CONTROLCODECATEGORY_ID = (SELECT Id FROM [Common].[ModuleMaster]  WHERE COMPANYID=@UNIQUE_COMPANY_ID AND NAME='Admin Cursor')
  INSERT INTO [Common].[ControlCodeCategoryModule] (Id, CompanyId, ControlCategoryId, ModuleMasterId) VALUES ((SELECT MAX(Id) + 1 FROM [Common].[ControlCodeCategoryModule]),
  @NEW_COMPANY_ID,@CONTROLCODECATEGORY_ID_MODULE_MASTER_ID,@MODULE_MASTER_ID_CONTROLCODECATEGORY_ID);

  
-------------------------- Income ---------------------------------------------

 SET @CONTROLCODECATEGORY_ID_MODULE_MASTER_ID = (SELECT top 1 ID FROM [Common].[ControlCodeCategory] WHERE COMPANYID=@NEW_COMPANY_ID AND CONTROLCODECATEGORYCODE='Income')
  SET @MODULE_MASTER_ID_CONTROLCODECATEGORY_ID = (SELECT Id FROM [Common].[ModuleMaster]  WHERE COMPANYID=@UNIQUE_COMPANY_ID AND NAME='Admin Cursor')
  INSERT INTO [Common].[ControlCodeCategoryModule] (Id, CompanyId, ControlCategoryId, ModuleMasterId) VALUES ((SELECT MAX(Id) + 1 FROM [Common].[ControlCodeCategoryModule]),
  @NEW_COMPANY_ID,@CONTROLCODECATEGORY_ID_MODULE_MASTER_ID,@MODULE_MASTER_ID_CONTROLCODECATEGORY_ID);

   
-------------------------- Expenses ---------------------------------------------

 SET @CONTROLCODECATEGORY_ID_MODULE_MASTER_ID = (SELECT top 1 ID FROM [Common].[ControlCodeCategory] WHERE COMPANYID=@NEW_COMPANY_ID AND CONTROLCODECATEGORYCODE='Expenses')
  SET @MODULE_MASTER_ID_CONTROLCODECATEGORY_ID = (SELECT Id FROM [Common].[ModuleMaster]  WHERE COMPANYID=@UNIQUE_COMPANY_ID AND NAME='Admin Cursor')
  INSERT INTO [Common].[ControlCodeCategoryModule] (Id, CompanyId, ControlCategoryId, ModuleMasterId) VALUES ((SELECT MAX(Id) + 1 FROM [Common].[ControlCodeCategoryModule]),
  @NEW_COMPANY_ID,@CONTROLCODECATEGORY_ID_MODULE_MASTER_ID,@MODULE_MASTER_ID_CONTROLCODECATEGORY_ID);

  
  
-------------------------- Equity ---------------------------------------------

 SET @CONTROLCODECATEGORY_ID_MODULE_MASTER_ID = (SELECT top 1 ID FROM [Common].[ControlCodeCategory] WHERE COMPANYID=@NEW_COMPANY_ID AND CONTROLCODECATEGORYCODE='Equity')
  SET @MODULE_MASTER_ID_CONTROLCODECATEGORY_ID = (SELECT Id FROM [Common].[ModuleMaster]  WHERE COMPANYID=@UNIQUE_COMPANY_ID AND NAME='Admin Cursor')
  INSERT INTO [Common].[ControlCodeCategoryModule] (Id, CompanyId, ControlCategoryId, ModuleMasterId) VALUES ((SELECT MAX(Id) + 1 FROM [Common].[ControlCodeCategoryModule]),
  @NEW_COMPANY_ID,@CONTROLCODECATEGORY_ID_MODULE_MASTER_ID,@MODULE_MASTER_ID_CONTROLCODECATEGORY_ID);

 
 ------------------------For CourseCategory ---------------------------

 SET @CONTROLCODECATEGORY_ID_MODULE_MASTER_ID = (SELECT top 1 ID FROM [Common].[ControlCodeCategory] WHERE COMPANYID=@NEW_COMPANY_ID AND CONTROLCODECATEGORYCODE='Course Category')
  SET @MODULE_MASTER_ID_CONTROLCODECATEGORY_ID = (SELECT Id FROM [Common].[ModuleMaster]  WHERE COMPANYID=@UNIQUE_COMPANY_ID AND NAME='HR Cursor')
  INSERT INTO [Common].[ControlCodeCategoryModule] (Id, CompanyId, ControlCategoryId, ModuleMasterId) VALUES ((SELECT MAX(Id) + 1 FROM [Common].[ControlCodeCategoryModule]),
  @NEW_COMPANY_ID,@CONTROLCODECATEGORY_ID_MODULE_MASTER_ID,@MODULE_MASTER_ID_CONTROLCODECATEGORY_ID);


---------------------------For Funding ----------------------------------

 SET @CONTROLCODECATEGORY_ID_MODULE_MASTER_ID = (SELECT top 1 ID FROM [Common].[ControlCodeCategory] WHERE COMPANYID=@NEW_COMPANY_ID AND CONTROLCODECATEGORYCODE='Funding')
  SET @MODULE_MASTER_ID_CONTROLCODECATEGORY_ID = (SELECT Id FROM [Common].[ModuleMaster]  WHERE COMPANYID=@UNIQUE_COMPANY_ID AND NAME='HR Cursor')
  INSERT INTO [Common].[ControlCodeCategoryModule] (Id, CompanyId, ControlCategoryId, ModuleMasterId) VALUES ((SELECT MAX(Id) + 1 FROM [Common].[ControlCodeCategoryModule]),
  @NEW_COMPANY_ID,@CONTROLCODECATEGORY_ID_MODULE_MASTER_ID,@MODULE_MASTER_ID_CONTROLCODECATEGORY_ID);


    --------------- For Venue in Trainings----------------------------------
  
  SET @CONTROLCODECATEGORY_ID_MODULE_MASTER_ID = (SELECT top 1 ID FROM [Common].[ControlCodeCategory] WHERE COMPANYID=@NEW_COMPANY_ID AND CONTROLCODECATEGORYCODE='Venue')
  SET @MODULE_MASTER_ID_CONTROLCODECATEGORY_ID = (SELECT Id FROM [Common].[ModuleMaster]  WHERE COMPANYID=@UNIQUE_COMPANY_ID AND NAME='HR Cursor')
  INSERT INTO [Common].[ControlCodeCategoryModule] (Id, CompanyId, ControlCategoryId, ModuleMasterId) VALUES ((SELECT MAX(Id) + 1 FROM [Common].[ControlCodeCategoryModule]),
  @NEW_COMPANY_ID,@CONTROLCODECATEGORY_ID_MODULE_MASTER_ID,@MODULE_MASTER_ID_CONTROLCODECATEGORY_ID);
  
  	


	---------------------------------AUDIT--------------------------------------------------------------
	 -- SET @CONTROLCODECATEGORY_ID_MODULE_MASTER_ID = (SELECT top 1 ID FROM [Common].[ControlCodeCategory] WHERE COMPANYID=@NEW_COMPANY_ID AND CONTROLCODECATEGORYCODE='Salutation')
  --SET @MODULE_MASTER_ID_CONTROLCODECATEGORY_ID = (SELECT Id FROM [Common].[ModuleMaster]  WHERE COMPANYID=@UNIQUE_COMPANY_ID AND NAME='Audit Cursor')
  --INSERT INTO [Common].[ControlCodeCategoryModule] (Id, CompanyId, ControlCategoryId, ModuleMasterId) VALUES ((SELECT MAX(Id) + 1 FROM [Common].[ControlCodeCategoryModule]),
  --@NEW_COMPANY_ID,@CONTROLCODECATEGORY_ID_MODULE_MASTER_ID,@MODULE_MASTER_ID_CONTROLCODECATEGORY_ID);

  --	  SET @CONTROLCODECATEGORY_ID_MODULE_MASTER_ID = (SELECT top 1 ID FROM [Common].[ControlCodeCategory] WHERE COMPANYID=@NEW_COMPANY_ID AND CONTROLCODECATEGORYCODE='Designation')
  --SET @MODULE_MASTER_ID_CONTROLCODECATEGORY_ID = (SELECT Id FROM [Common].[ModuleMaster]  WHERE COMPANYID=@UNIQUE_COMPANY_ID AND NAME='Audit Cursor')
  --INSERT INTO [Common].[ControlCodeCategoryModule] (Id, CompanyId, ControlCategoryId, ModuleMasterId) VALUES ((SELECT MAX(Id) + 1 FROM [Common].[ControlCodeCategoryModule]),
  --@NEW_COMPANY_ID,@CONTROLCODECATEGORY_ID_MODULE_MASTER_ID,@MODULE_MASTER_ID_CONTROLCODECATEGORY_ID);

  	  SET @CONTROLCODECATEGORY_ID_MODULE_MASTER_ID = (SELECT top 1 ID FROM [Common].[ControlCodeCategory] WHERE COMPANYID=@NEW_COMPANY_ID AND CONTROLCODECATEGORYCODE='EngagementType')
  SET @MODULE_MASTER_ID_CONTROLCODECATEGORY_ID = (SELECT Id FROM [Common].[ModuleMaster]  WHERE COMPANYID=@UNIQUE_COMPANY_ID AND NAME='Audit Cursor')
  INSERT INTO [Common].[ControlCodeCategoryModule] (Id, CompanyId, ControlCategoryId, ModuleMasterId) VALUES ((SELECT MAX(Id) + 1 FROM [Common].[ControlCodeCategoryModule]),
  @NEW_COMPANY_ID,@CONTROLCODECATEGORY_ID_MODULE_MASTER_ID,@MODULE_MASTER_ID_CONTROLCODECATEGORY_ID);
 	  SET @CONTROLCODECATEGORY_ID_MODULE_MASTER_ID = (SELECT top 1 ID FROM [Common].[ControlCodeCategory] WHERE COMPANYID=@NEW_COMPANY_ID AND CONTROLCODECATEGORYCODE='EngagementReview')
  SET @MODULE_MASTER_ID_CONTROLCODECATEGORY_ID = (SELECT Id FROM [Common].[ModuleMaster]  WHERE COMPANYID=@UNIQUE_COMPANY_ID AND NAME='Audit Cursor')
  INSERT INTO [Common].[ControlCodeCategoryModule] (Id, CompanyId, ControlCategoryId, ModuleMasterId) VALUES ((SELECT MAX(Id) + 1 FROM [Common].[ControlCodeCategoryModule]),
  @NEW_COMPANY_ID,@CONTROLCODECATEGORY_ID_MODULE_MASTER_ID,@MODULE_MASTER_ID_CONTROLCODECATEGORY_ID);
 	  SET @CONTROLCODECATEGORY_ID_MODULE_MASTER_ID = (SELECT top 1 ID FROM [Common].[ControlCodeCategory] WHERE COMPANYID=@NEW_COMPANY_ID AND CONTROLCODECATEGORYCODE='TrialBalance Columns')
  SET @MODULE_MASTER_ID_CONTROLCODECATEGORY_ID = (SELECT Id FROM [Common].[ModuleMaster]  WHERE COMPANYID=@UNIQUE_COMPANY_ID AND NAME='Audit Cursor')
  INSERT INTO [Common].[ControlCodeCategoryModule] (Id, CompanyId, ControlCategoryId, ModuleMasterId) VALUES ((SELECT MAX(Id) + 1 FROM [Common].[ControlCodeCategoryModule]),
  @NEW_COMPANY_ID,@CONTROLCODECATEGORY_ID_MODULE_MASTER_ID,@MODULE_MASTER_ID_CONTROLCODECATEGORY_ID);
  -- 	  SET @CONTROLCODECATEGORY_ID_MODULE_MASTER_ID = (SELECT top 1 ID FROM [Common].[ControlCodeCategory] WHERE COMPANYID=@NEW_COMPANY_ID AND CONTROLCODECATEGORYCODE='CountryOfOrigin')
  --SET @MODULE_MASTER_ID_CONTROLCODECATEGORY_ID = (SELECT Id FROM [Common].[ModuleMaster]  WHERE COMPANYID=@UNIQUE_COMPANY_ID AND NAME='Audit Cursor')
  --INSERT INTO [Common].[ControlCodeCategoryModule] (Id, CompanyId, ControlCategoryId, ModuleMasterId) VALUES ((SELECT MAX(Id) + 1 FROM [Common].[ControlCodeCategoryModule]),
  --@NEW_COMPANY_ID,@CONTROLCODECATEGORY_ID_MODULE_MASTER_ID,@MODULE_MASTER_ID_CONTROLCODECATEGORY_ID);


    SET @CONTROLCODECATEGORY_ID_MODULE_MASTER_ID = (SELECT top 1 ID FROM [Common].[ControlCodeCategory] WHERE COMPANYID=@NEW_COMPANY_ID AND CONTROLCODECATEGORYCODE='EntityAddress')
  SET @MODULE_MASTER_ID_CONTROLCODECATEGORY_ID = (SELECT Id FROM [Common].[ModuleMaster]  WHERE COMPANYID=@UNIQUE_COMPANY_ID AND NAME='Audit Cursor')
  INSERT INTO [Common].[ControlCodeCategoryModule] (Id, CompanyId, ControlCategoryId, ModuleMasterId) VALUES ((SELECT MAX(Id) + 1 FROM [Common].[ControlCodeCategoryModule]),
  @NEW_COMPANY_ID,@CONTROLCODECATEGORY_ID_MODULE_MASTER_ID,@MODULE_MASTER_ID_CONTROLCODECATEGORY_ID);

  

   SET @CONTROLCODECATEGORY_ID_MODULE_MASTER_ID = (SELECT top 1 ID FROM [Common].[ControlCodeCategory] WHERE COMPANYID=@NEW_COMPANY_ID AND CONTROLCODECATEGORYCODE='IndividualAddress')
  SET @MODULE_MASTER_ID_CONTROLCODECATEGORY_ID = (SELECT Id FROM [Common].[ModuleMaster]  WHERE COMPANYID=@UNIQUE_COMPANY_ID AND NAME='Audit Cursor')
  INSERT INTO [Common].[ControlCodeCategoryModule] (Id, CompanyId, ControlCategoryId, ModuleMasterId) VALUES ((SELECT MAX(Id) + 1 FROM [Common].[ControlCodeCategoryModule]),
  @NEW_COMPANY_ID,@CONTROLCODECATEGORY_ID_MODULE_MASTER_ID,@MODULE_MASTER_ID_CONTROLCODECATEGORY_ID);

   	  SET @CONTROLCODECATEGORY_ID_MODULE_MASTER_ID = (SELECT top 1 ID FROM [Common].[ControlCodeCategory] WHERE COMPANYID=@NEW_COMPANY_ID AND CONTROLCODECATEGORYCODE='Address Type')
  SET @MODULE_MASTER_ID_CONTROLCODECATEGORY_ID = (SELECT Id FROM [Common].[ModuleMaster]  WHERE COMPANYID=@UNIQUE_COMPANY_ID AND NAME='Audit Cursor')
  INSERT INTO [Common].[ControlCodeCategoryModule] (Id, CompanyId, ControlCategoryId, ModuleMasterId) VALUES ((SELECT MAX(Id) + 1 FROM [Common].[ControlCodeCategoryModule]),
  @NEW_COMPANY_ID,@CONTROLCODECATEGORY_ID_MODULE_MASTER_ID,@MODULE_MASTER_ID_CONTROLCODECATEGORY_ID);
   	  SET @CONTROLCODECATEGORY_ID_MODULE_MASTER_ID = (SELECT top 1 ID FROM [Common].[ControlCodeCategory] WHERE COMPANYID=@NEW_COMPANY_ID AND CONTROLCODECATEGORYCODE='Address Type')
  SET @MODULE_MASTER_ID_CONTROLCODECATEGORY_ID = (SELECT Id FROM [Common].[ModuleMaster]  WHERE COMPANYID=@UNIQUE_COMPANY_ID AND NAME='Audit Cursor')
  INSERT INTO [Common].[ControlCodeCategoryModule] (Id, CompanyId, ControlCategoryId, ModuleMasterId) VALUES ((SELECT MAX(Id) + 1 FROM [Common].[ControlCodeCategoryModule]),
  @NEW_COMPANY_ID,@CONTROLCODECATEGORY_ID_MODULE_MASTER_ID,@MODULE_MASTER_ID_CONTROLCODECATEGORY_ID);
   	  SET @CONTROLCODECATEGORY_ID_MODULE_MASTER_ID = (SELECT top 1 ID FROM [Common].[ControlCodeCategory] WHERE COMPANYID=@NEW_COMPANY_ID AND CONTROLCODECATEGORYCODE='Additionallevels')
  SET @MODULE_MASTER_ID_CONTROLCODECATEGORY_ID = (SELECT Id FROM [Common].[ModuleMaster]  WHERE COMPANYID=@UNIQUE_COMPANY_ID AND NAME='Audit Cursor')
  INSERT INTO [Common].[ControlCodeCategoryModule] (Id, CompanyId, ControlCategoryId, ModuleMasterId) VALUES ((SELECT MAX(Id) + 1 FROM [Common].[ControlCodeCategoryModule]),
  @NEW_COMPANY_ID,@CONTROLCODECATEGORY_ID_MODULE_MASTER_ID,@MODULE_MASTER_ID_CONTROLCODECATEGORY_ID);
   	  SET @CONTROLCODECATEGORY_ID_MODULE_MASTER_ID = (SELECT top 1 ID FROM [Common].[ControlCodeCategory] WHERE COMPANYID=@NEW_COMPANY_ID AND CONTROLCODECATEGORYCODE='AuditPrimaryRole')
  SET @MODULE_MASTER_ID_CONTROLCODECATEGORY_ID = (SELECT Id FROM [Common].[ModuleMaster]  WHERE COMPANYID=@UNIQUE_COMPANY_ID AND NAME='Audit Cursor')
  INSERT INTO [Common].[ControlCodeCategoryModule] (Id, CompanyId, ControlCategoryId, ModuleMasterId) VALUES ((SELECT MAX(Id) + 1 FROM [Common].[ControlCodeCategoryModule]),
  @NEW_COMPANY_ID,@CONTROLCODECATEGORY_ID_MODULE_MASTER_ID,@MODULE_MASTER_ID_CONTROLCODECATEGORY_ID);
   	  SET @CONTROLCODECATEGORY_ID_MODULE_MASTER_ID = (SELECT top 1 ID FROM [Common].[ControlCodeCategory] WHERE COMPANYID=@NEW_COMPANY_ID AND CONTROLCODECATEGORYCODE='Leadsheet Type')
  SET @MODULE_MASTER_ID_CONTROLCODECATEGORY_ID = (SELECT Id FROM [Common].[ModuleMaster]  WHERE COMPANYID=@UNIQUE_COMPANY_ID AND NAME='Audit Cursor')
  INSERT INTO [Common].[ControlCodeCategoryModule] (Id, CompanyId, ControlCategoryId, ModuleMasterId) VALUES ((SELECT MAX(Id) + 1 FROM [Common].[ControlCodeCategoryModule]),
  @NEW_COMPANY_ID,@CONTROLCODECATEGORY_ID_MODULE_MASTER_ID,@MODULE_MASTER_ID_CONTROLCODECATEGORY_ID);
  	  SET @CONTROLCODECATEGORY_ID_MODULE_MASTER_ID = (SELECT top 1 ID FROM [Common].[ControlCodeCategory] WHERE COMPANYID=@NEW_COMPANY_ID AND CONTROLCODECATEGORYCODE='Account Class')
  SET @MODULE_MASTER_ID_CONTROLCODECATEGORY_ID = (SELECT Id FROM [Common].[ModuleMaster]  WHERE COMPANYID=@UNIQUE_COMPANY_ID AND NAME='Audit Cursor')
  INSERT INTO [Common].[ControlCodeCategoryModule] (Id, CompanyId, ControlCategoryId, ModuleMasterId) VALUES ((SELECT MAX(Id) + 1 FROM [Common].[ControlCodeCategoryModule]),
  @NEW_COMPANY_ID,@CONTROLCODECATEGORY_ID_MODULE_MASTER_ID,@MODULE_MASTER_ID_CONTROLCODECATEGORY_ID);
    	  SET @CONTROLCODECATEGORY_ID_MODULE_MASTER_ID = (SELECT top 1 ID FROM [Common].[ControlCodeCategory] WHERE COMPANYID=@NEW_COMPANY_ID AND CONTROLCODECATEGORYCODE='GeneralLedgerColumns')
  SET @MODULE_MASTER_ID_CONTROLCODECATEGORY_ID = (SELECT Id FROM [Common].[ModuleMaster]  WHERE COMPANYID=@UNIQUE_COMPANY_ID AND NAME='Audit Cursor')
  INSERT INTO [Common].[ControlCodeCategoryModule] (Id, CompanyId, ControlCategoryId, ModuleMasterId) VALUES ((SELECT MAX(Id) + 1 FROM [Common].[ControlCodeCategoryModule]),
  @NEW_COMPANY_ID,@CONTROLCODECATEGORY_ID_MODULE_MASTER_ID,@MODULE_MASTER_ID_CONTROLCODECATEGORY_ID);
    	  SET @CONTROLCODECATEGORY_ID_MODULE_MASTER_ID = (SELECT top 1 ID FROM [Common].[ControlCodeCategory] WHERE COMPANYID=@NEW_COMPANY_ID AND CONTROLCODECATEGORYCODE='FEPrimaryParticulars')
  SET @MODULE_MASTER_ID_CONTROLCODECATEGORY_ID = (SELECT Id FROM [Common].[ModuleMaster]  WHERE COMPANYID=@UNIQUE_COMPANY_ID AND NAME='Audit Cursor')
  INSERT INTO [Common].[ControlCodeCategoryModule] (Id, CompanyId, ControlCategoryId, ModuleMasterId) VALUES ((SELECT MAX(Id) + 1 FROM [Common].[ControlCodeCategoryModule]),
  @NEW_COMPANY_ID,@CONTROLCODECATEGORY_ID_MODULE_MASTER_ID,@MODULE_MASTER_ID_CONTROLCODECATEGORY_ID);

  	  SET @CONTROLCODECATEGORY_ID_MODULE_MASTER_ID = (SELECT top 1 ID FROM [Common].[ControlCodeCategory] WHERE COMPANYID=@NEW_COMPANY_ID AND CONTROLCODECATEGORYCODE='FESecondParticulars')
  SET @MODULE_MASTER_ID_CONTROLCODECATEGORY_ID = (SELECT Id FROM [Common].[ModuleMaster]  WHERE COMPANYID=@UNIQUE_COMPANY_ID AND NAME='Audit Cursor')
  INSERT INTO [Common].[ControlCodeCategoryModule] (Id, CompanyId, ControlCategoryId, ModuleMasterId) VALUES ((SELECT MAX(Id) + 1 FROM [Common].[ControlCodeCategoryModule]),
  @NEW_COMPANY_ID,@CONTROLCODECATEGORY_ID_MODULE_MASTER_ID,@MODULE_MASTER_ID_CONTROLCODECATEGORY_ID);
    	  SET @CONTROLCODECATEGORY_ID_MODULE_MASTER_ID = (SELECT top 1 ID FROM [Common].[ControlCodeCategory] WHERE COMPANYID=@NEW_COMPANY_ID AND CONTROLCODECATEGORYCODE='MPNameSuggestion')
  SET @MODULE_MASTER_ID_CONTROLCODECATEGORY_ID = (SELECT Id FROM [Common].[ModuleMaster]  WHERE COMPANYID=@UNIQUE_COMPANY_ID AND NAME='Audit Cursor')
  INSERT INTO [Common].[ControlCodeCategoryModule] (Id, CompanyId, ControlCategoryId, ModuleMasterId) VALUES ((SELECT MAX(Id) + 1 FROM [Common].[ControlCodeCategoryModule]),
  @NEW_COMPANY_ID,@CONTROLCODECATEGORY_ID_MODULE_MASTER_ID,@MODULE_MASTER_ID_CONTROLCODECATEGORY_ID);

      	  SET @CONTROLCODECATEGORY_ID_MODULE_MASTER_ID = (SELECT top 1 ID FROM [Common].[ControlCodeCategory] WHERE COMPANYID=@NEW_COMPANY_ID AND CONTROLCODECATEGORYCODE='MPSuggestion')
  SET @MODULE_MASTER_ID_CONTROLCODECATEGORY_ID = (SELECT Id FROM [Common].[ModuleMaster]  WHERE COMPANYID=@UNIQUE_COMPANY_ID AND NAME='Audit Cursor')
  INSERT INTO [Common].[ControlCodeCategoryModule] (Id, CompanyId, ControlCategoryId, ModuleMasterId) VALUES ((SELECT MAX(Id) + 1 FROM [Common].[ControlCodeCategoryModule]),
  @NEW_COMPANY_ID,@CONTROLCODECATEGORY_ID_MODULE_MASTER_ID,@MODULE_MASTER_ID_CONTROLCODECATEGORY_ID);
  
      	  SET @CONTROLCODECATEGORY_ID_MODULE_MASTER_ID = (SELECT top 1 ID FROM [Common].[ControlCodeCategory] WHERE COMPANYID=@NEW_COMPANY_ID AND CONTROLCODECATEGORYCODE='TErrorSuggestion')
  SET @MODULE_MASTER_ID_CONTROLCODECATEGORY_ID = (SELECT Id FROM [Common].[ModuleMaster]  WHERE COMPANYID=@UNIQUE_COMPANY_ID AND NAME='Audit Cursor')
  INSERT INTO [Common].[ControlCodeCategoryModule] (Id, CompanyId, ControlCategoryId, ModuleMasterId) VALUES ((SELECT MAX(Id) + 1 FROM [Common].[ControlCodeCategoryModule]),
  @NEW_COMPANY_ID,@CONTROLCODECATEGORY_ID_MODULE_MASTER_ID,@MODULE_MASTER_ID_CONTROLCODECATEGORY_ID);
        	  SET @CONTROLCODECATEGORY_ID_MODULE_MASTER_ID = (SELECT top 1 ID FROM [Common].[ControlCodeCategory] WHERE COMPANYID=@NEW_COMPANY_ID AND CONTROLCODECATEGORYCODE='FEConSuggestion')
  SET @MODULE_MASTER_ID_CONTROLCODECATEGORY_ID = (SELECT Id FROM [Common].[ModuleMaster]  WHERE COMPANYID=@UNIQUE_COMPANY_ID AND NAME='Audit Cursor')
  INSERT INTO [Common].[ControlCodeCategoryModule] (Id, CompanyId, ControlCategoryId, ModuleMasterId) VALUES ((SELECT MAX(Id) + 1 FROM [Common].[ControlCodeCategoryModule]),
  @NEW_COMPANY_ID,@CONTROLCODECATEGORY_ID_MODULE_MASTER_ID,@MODULE_MASTER_ID_CONTROLCODECATEGORY_ID);
          	  SET @CONTROLCODECATEGORY_ID_MODULE_MASTER_ID = (SELECT top 1 ID FROM [Common].[ControlCodeCategory] WHERE COMPANYID=@NEW_COMPANY_ID AND CONTROLCODECATEGORYCODE='Assets')
  SET @MODULE_MASTER_ID_CONTROLCODECATEGORY_ID = (SELECT Id FROM [Common].[ModuleMaster]  WHERE COMPANYID=@UNIQUE_COMPANY_ID AND NAME='Audit Cursor')
  INSERT INTO [Common].[ControlCodeCategoryModule] (Id, CompanyId, ControlCategoryId, ModuleMasterId) VALUES ((SELECT MAX(Id) + 1 FROM [Common].[ControlCodeCategoryModule]),
  @NEW_COMPANY_ID,@CONTROLCODECATEGORY_ID_MODULE_MASTER_ID,@MODULE_MASTER_ID_CONTROLCODECATEGORY_ID);
   SET @CONTROLCODECATEGORY_ID_MODULE_MASTER_ID = (SELECT top 1 ID FROM [Common].[ControlCodeCategory] WHERE COMPANYID=@NEW_COMPANY_ID AND CONTROLCODECATEGORYCODE='Liabilities')
  SET @MODULE_MASTER_ID_CONTROLCODECATEGORY_ID = (SELECT Id FROM [Common].[ModuleMaster]  WHERE COMPANYID=@UNIQUE_COMPANY_ID AND NAME='Audit Cursor')
  INSERT INTO [Common].[ControlCodeCategoryModule] (Id, CompanyId, ControlCategoryId, ModuleMasterId) VALUES ((SELECT MAX(Id) + 1 FROM [Common].[ControlCodeCategoryModule]),
  @NEW_COMPANY_ID,@CONTROLCODECATEGORY_ID_MODULE_MASTER_ID,@MODULE_MASTER_ID_CONTROLCODECATEGORY_ID);

     SET @CONTROLCODECATEGORY_ID_MODULE_MASTER_ID = (SELECT top 1 ID FROM [Common].[ControlCodeCategory] WHERE COMPANYID=@NEW_COMPANY_ID AND CONTROLCODECATEGORYCODE='Income')
  SET @MODULE_MASTER_ID_CONTROLCODECATEGORY_ID = (SELECT Id FROM [Common].[ModuleMaster]  WHERE COMPANYID=@UNIQUE_COMPANY_ID AND NAME='Audit Cursor')
  INSERT INTO [Common].[ControlCodeCategoryModule] (Id, CompanyId, ControlCategoryId, ModuleMasterId) VALUES ((SELECT MAX(Id) + 1 FROM [Common].[ControlCodeCategoryModule]),
  @NEW_COMPANY_ID,@CONTROLCODECATEGORY_ID_MODULE_MASTER_ID,@MODULE_MASTER_ID_CONTROLCODECATEGORY_ID);
   SET @CONTROLCODECATEGORY_ID_MODULE_MASTER_ID = (SELECT top 1 ID FROM [Common].[ControlCodeCategory] WHERE COMPANYID=@NEW_COMPANY_ID AND CONTROLCODECATEGORYCODE='Expenses')
  SET @MODULE_MASTER_ID_CONTROLCODECATEGORY_ID = (SELECT Id FROM [Common].[ModuleMaster]  WHERE COMPANYID=@UNIQUE_COMPANY_ID AND NAME='Audit Cursor')
  INSERT INTO [Common].[ControlCodeCategoryModule] (Id, CompanyId, ControlCategoryId, ModuleMasterId) VALUES ((SELECT MAX(Id) + 1 FROM [Common].[ControlCodeCategoryModule]),
  @NEW_COMPANY_ID,@CONTROLCODECATEGORY_ID_MODULE_MASTER_ID,@MODULE_MASTER_ID_CONTROLCODECATEGORY_ID);
   SET @CONTROLCODECATEGORY_ID_MODULE_MASTER_ID = (SELECT top 1 ID FROM [Common].[ControlCodeCategory] WHERE COMPANYID=@NEW_COMPANY_ID AND CONTROLCODECATEGORYCODE='Equity')
  SET @MODULE_MASTER_ID_CONTROLCODECATEGORY_ID = (SELECT Id FROM [Common].[ModuleMaster]  WHERE COMPANYID=@UNIQUE_COMPANY_ID AND NAME='Audit Cursor')
  INSERT INTO [Common].[ControlCodeCategoryModule] (Id, CompanyId, ControlCategoryId, ModuleMasterId) VALUES ((SELECT MAX(Id) + 1 FROM [Common].[ControlCodeCategoryModule]),
  @NEW_COMPANY_ID,@CONTROLCODECATEGORY_ID_MODULE_MASTER_ID,@MODULE_MASTER_ID_CONTROLCODECATEGORY_ID);
	

   SET @CONTROLCODECATEGORY_ID_MODULE_MASTER_ID = (SELECT top 1 ID FROM [Common].[ControlCodeCategory] WHERE COMPANYID=@NEW_COMPANY_ID AND CONTROLCODECATEGORYCODE='Materiality Type')
  SET @MODULE_MASTER_ID_CONTROLCODECATEGORY_ID = (SELECT Id FROM [Common].[ModuleMaster]  WHERE COMPANYID=@UNIQUE_COMPANY_ID AND NAME='Audit Cursor')
  INSERT INTO [Common].[ControlCodeCategoryModule] (Id, CompanyId, ControlCategoryId, ModuleMasterId) VALUES ((SELECT MAX(Id) + 1 FROM [Common].[ControlCodeCategoryModule]),
  @NEW_COMPANY_ID,@CONTROLCODECATEGORY_ID_MODULE_MASTER_ID,@MODULE_MASTER_ID_CONTROLCODECATEGORY_ID);


 SET @CONTROLCODECATEGORY_ID_MODULE_MASTER_ID = (SELECT top 1 ID FROM [Common].[ControlCodeCategory] WHERE COMPANYID=@NEW_COMPANY_ID AND CONTROLCODECATEGORYCODE='Predefined Type')
  SET @MODULE_MASTER_ID_CONTROLCODECATEGORY_ID = (SELECT Id FROM [Common].[ModuleMaster]  WHERE COMPANYID=@UNIQUE_COMPANY_ID AND NAME='Audit Cursor')
  INSERT INTO [Common].[ControlCodeCategoryModule] (Id, CompanyId, ControlCategoryId, ModuleMasterId) VALUES ((SELECT MAX(Id) + 1 FROM [Common].[ControlCodeCategoryModule]),
  @NEW_COMPANY_ID,@CONTROLCODECATEGORY_ID_MODULE_MASTER_ID,@MODULE_MASTER_ID_CONTROLCODECATEGORY_ID);
  --=================================== Country Control Code ===========================================

   SET @CONTROLCODECATEGORY_ID_MODULE_MASTER_ID = (SELECT top 1 ID FROM [Common].[ControlCodeCategory] WHERE COMPANYID=@NEW_COMPANY_ID AND CONTROLCODECATEGORYCODE='Country')
  SET @MODULE_MASTER_ID_CONTROLCODECATEGORY_ID = (SELECT Id FROM [Common].[ModuleMaster]  WHERE COMPANYID=@UNIQUE_COMPANY_ID AND NAME='Admin Cursor')
  INSERT INTO [Common].[ControlCodeCategoryModule] (Id, CompanyId, ControlCategoryId, ModuleMasterId) VALUES ((SELECT MAX(Id) + 1 FROM [Common].[ControlCodeCategoryModule]),
  @NEW_COMPANY_ID,@CONTROLCODECATEGORY_ID_MODULE_MASTER_ID,@MODULE_MASTER_ID_CONTROLCODECATEGORY_ID);
  

  SET @CONTROLCODECATEGORY_ID_MODULE_MASTER_ID = (SELECT top 1 ID FROM [Common].[ControlCodeCategory] WHERE COMPANYID=@NEW_COMPANY_ID AND CONTROLCODECATEGORYCODE='ReasonForCancel')
  SET @MODULE_MASTER_ID_CONTROLCODECATEGORY_ID = (SELECT Id FROM [Common].[ModuleMaster]  WHERE COMPANYID=@UNIQUE_COMPANY_ID AND NAME='Client Cursor')
  INSERT INTO [Common].[ControlCodeCategoryModule] (Id, CompanyId, ControlCategoryId, ModuleMasterId) VALUES ((SELECT MAX(Id) + 1 FROM [Common].[ControlCodeCategoryModule]),
  @NEW_COMPANY_ID,@CONTROLCODECATEGORY_ID_MODULE_MASTER_ID,@MODULE_MASTER_ID_CONTROLCODECATEGORY_ID);
  ------------------------For Question Category ---------------------------

  --SET @CONTROLCODECATEGORY_ID_MODULE_MASTER_ID = (SELECT top 1 ID FROM [Common].[ControlCodeCategory] WHERE COMPANYID=@NEW_COMPANY_ID AND CONTROLCODECATEGORYCODE='Question Category')
  --SET @MODULE_MASTER_ID_CONTROLCODECATEGORY_ID = (SELECT Id FROM [Common].[ModuleMaster]  WHERE COMPANYID=@UNIQUE_COMPANY_ID AND NAME='HR Cursor')
  --INSERT INTO [Common].[ControlCodeCategoryModule] (Id, CompanyId, ControlCategoryId, ModuleMasterId) VALUES ((SELECT MAX(Id) + 1 FROM [Common].[ControlCodeCategoryModule]),
  --@NEW_COMPANY_ID,@CONTROLCODECATEGORY_ID_MODULE_MASTER_ID,@MODULE_MASTER_ID_CONTROLCODECATEGORY_ID);


 -----=============== 19/06/2017 ===========================================

 ------------------------For Question Category ---------------------------

   SET @CONTROLCODECATEGORY_ID_MODULE_MASTER_ID = (SELECT top 1 ID FROM [Common].[ControlCodeCategory] WHERE COMPANYID=@NEW_COMPANY_ID AND CONTROLCODECATEGORYCODE='Question Category')
  SET @MODULE_MASTER_ID_CONTROLCODECATEGORY_ID = (SELECT Id FROM [Common].[ModuleMaster]  WHERE COMPANYID=@UNIQUE_COMPANY_ID AND NAME='Admin Cursor')
  INSERT INTO [Common].[ControlCodeCategoryModule] (Id, CompanyId, ControlCategoryId, ModuleMasterId) VALUES ((SELECT MAX(Id) + 1 FROM [Common].[ControlCodeCategoryModule]),
  @NEW_COMPANY_ID,@CONTROLCODECATEGORY_ID_MODULE_MASTER_ID,@MODULE_MASTER_ID_CONTROLCODECATEGORY_ID);

	  ------------------------Audit Menu ---------------------------
   --INSERT INTO [Audit].[EngagementTypeMenuMapping]
			--		SELECT NEWID(),Md.id,@NEW_COMPANY_ID,md.Description,'Audit',md.GroupName,md.Heading,md.PermissionKey,
			--		'Audit',1,md.RecOrder,'','madhu@kgtan.com',GETUTCDATE(),'','',1,1 from Common.ModuleDetail  md 
			--				 WHERE md.ModuleMasterId = (SELECT Id from Common.ModuleMaster WHERE NAME='Audit Cursor')

	--------------------------------Generic Template--------------------------------------

--	INSERT INTO Common.GenericTemplate ([Id],[CompanyId],[TemplateTypeId],[Name],[Code],[TempletContent],[IsSystem],[IsFooterExist],[IsHeaderExist],[RecOrder],[Remarks],[UserCreated],[CreatedDate],[ModifiedBy],[ModifiedDate],[Version],[Status])
--       SELECT  NEWID(),@NEW_COMPANY_ID,[TemplateTypeId],[Name],[Code],[TempletContent],[IsSystem],[IsFooterExist],[IsHeaderExist],[RecOrder],[Remarks],[UserCreated],GETUTCDATE(),null,null,[Version],1
--FROM Common.GenericTemplate WHERE CompanyId=@UNIQUE_COMPANY_ID
	

	declare @AuditFirmId bigint= (select AccountingFirmId from Common.Company where Id=@NEW_COMPANY_ID);
 if @AuditFirmId is null
  BEGIN
 INSERT INTO Common.GenericTemplate ([Id],[CompanyId],[TemplateTypeId],[Name],[Code],[TempletContent],[IsSystem],[IsFooterExist],[IsHeaderExist],[RecOrder],[Remarks],[UserCreated],[CreatedDate],[ModifiedBy],[ModifiedDate],[Version],[Status])
       SELECT  NEWID(),@NEW_COMPANY_ID,[TemplateTypeId],[Name],[Code],[TempletContent],[IsSystem],[IsFooterExist],[IsHeaderExist],[RecOrder],[Remarks],[UserCreated],GETUTCDATE(),null,null,[Version],1
  FROM Common.GenericTemplate WHERE CompanyId=@UNIQUE_COMPANY_ID
  END
else
  BEGIN
       INSERT INTO Common.GenericTemplate ([Id],[CompanyId],[TemplateTypeId],[Name],[Code],[TempletContent],[IsSystem],[IsFooterExist],[IsHeaderExist],[RecOrder],[Remarks],[UserCreated],[CreatedDate],[ModifiedBy],[ModifiedDate],[Version],[Status])
            SELECT  NEWID(),@NEW_COMPANY_ID,[TemplateTypeId],[Name],[Code],[TempletContent],[IsSystem],[IsFooterExist],[IsHeaderExist],[RecOrder],[Remarks],[UserCreated],GETUTCDATE(),null,null,[Version],1
       FROM Common.GenericTemplate WHERE CompanyId=@AuditFirmId
 END
	---------------------------------------------------------------------------------------

	  SET @CONTROLCODECATEGORY_ID_MODULE_MASTER_ID = (SELECT top 1 ID FROM [Common].[ControlCodeCategory] WHERE COMPANYID=@NEW_COMPANY_ID AND CONTROLCODECATEGORYCODE='TypeOfEntity')
  SET @MODULE_MASTER_ID_CONTROLCODECATEGORY_ID = (SELECT Id FROM [Common].[ModuleMaster]  WHERE COMPANYID=@UNIQUE_COMPANY_ID AND NAME='Tax Cursor')
  INSERT INTO [Common].[ControlCodeCategoryModule] (Id, CompanyId, ControlCategoryId, ModuleMasterId) VALUES ((SELECT MAX(Id) + 1 FROM [Common].[ControlCodeCategoryModule]),
  @NEW_COMPANY_ID,@CONTROLCODECATEGORY_ID_MODULE_MASTER_ID,@MODULE_MASTER_ID_CONTROLCODECATEGORY_ID);


  
	----------------------------- Classification Type ------------------------------

	   	  SET @CONTROLCODECATEGORY_ID_MODULE_MASTER_ID = (SELECT top 1 ID FROM [Common].[ControlCodeCategory] WHERE COMPANYID=@NEW_COMPANY_ID AND CONTROLCODECATEGORYCODE='Classification type')
  SET @MODULE_MASTER_ID_CONTROLCODECATEGORY_ID = (SELECT Id FROM [Common].[ModuleMaster]  WHERE COMPANYID=@UNIQUE_COMPANY_ID AND NAME='Tax Cursor')
  INSERT INTO [Common].[ControlCodeCategoryModule] (Id, CompanyId, ControlCategoryId, ModuleMasterId) VALUES ((SELECT MAX(Id) + 1 FROM [Common].[ControlCodeCategoryModule]),
  @NEW_COMPANY_ID,@CONTROLCODECATEGORY_ID_MODULE_MASTER_ID,@MODULE_MASTER_ID_CONTROLCODECATEGORY_ID);

  ---------------------------------------AccountClass For Tax----------------------

    	  SET @CONTROLCODECATEGORY_ID_MODULE_MASTER_ID = (SELECT top 1 ID FROM [Common].[ControlCodeCategory] WHERE COMPANYID=@NEW_COMPANY_ID AND CONTROLCODECATEGORYCODE='Account Class')
  SET @MODULE_MASTER_ID_CONTROLCODECATEGORY_ID = (SELECT Id FROM [Common].[ModuleMaster]  WHERE COMPANYID=@UNIQUE_COMPANY_ID AND NAME='Tax Cursor')
  INSERT INTO [Common].[ControlCodeCategoryModule] (Id, CompanyId, ControlCategoryId, ModuleMasterId) VALUES ((SELECT MAX(Id) + 1 FROM [Common].[ControlCodeCategoryModule]),
  @NEW_COMPANY_ID,@CONTROLCODECATEGORY_ID_MODULE_MASTER_ID,@MODULE_MASTER_ID_CONTROLCODECATEGORY_ID);



------------------------------------------Additionallevels For Tax-----------------------------------

     	  SET @CONTROLCODECATEGORY_ID_MODULE_MASTER_ID = (SELECT top 1 ID FROM [Common].[ControlCodeCategory] WHERE COMPANYID=@NEW_COMPANY_ID AND CONTROLCODECATEGORYCODE='Additionallevels')
  SET @MODULE_MASTER_ID_CONTROLCODECATEGORY_ID = (SELECT Id FROM [Common].[ModuleMaster]  WHERE COMPANYID=@UNIQUE_COMPANY_ID AND NAME='Tax Cursor')
  INSERT INTO [Common].[ControlCodeCategoryModule] (Id, CompanyId, ControlCategoryId, ModuleMasterId) VALUES ((SELECT MAX(Id) + 1 FROM [Common].[ControlCodeCategoryModule]),
  @NEW_COMPANY_ID,@CONTROLCODECATEGORY_ID_MODULE_MASTER_ID,@MODULE_MASTER_ID_CONTROLCODECATEGORY_ID);


  ------------------------------------------------TaxPrimaryRole--------------------------------------------------

     	  SET @CONTROLCODECATEGORY_ID_MODULE_MASTER_ID = (SELECT top 1 ID FROM [Common].[ControlCodeCategory] WHERE COMPANYID=@NEW_COMPANY_ID AND CONTROLCODECATEGORYCODE='TaxPrimaryRole')
  SET @MODULE_MASTER_ID_CONTROLCODECATEGORY_ID = (SELECT Id FROM [Common].[ModuleMaster]  WHERE COMPANYID=@UNIQUE_COMPANY_ID AND NAME='Tax Cursor')
  INSERT INTO [Common].[ControlCodeCategoryModule] (Id, CompanyId, ControlCategoryId, ModuleMasterId) VALUES ((SELECT MAX(Id) + 1 FROM [Common].[ControlCodeCategoryModule]),
  @NEW_COMPANY_ID,@CONTROLCODECATEGORY_ID_MODULE_MASTER_ID,@MODULE_MASTER_ID_CONTROLCODECATEGORY_ID);


 

	
--[Tax].[Classification]

	BEGIN
	   IF NOT EXISTS (SELECT * FROM [Tax].[Classification] WHERE  [CompanyId] = @NEW_COMPANY_ID)
   BEGIN   
 INSERT INTO  [Tax].[Classification] (Id, CompanyId, WorkProgramId, [Index], ClassificationType, AccountClass, IsSystem, ClassificationName, FinancialStatementTemplate, Remarks, RecOrder, UserCreated, CreatedDate, ModifiedBy, ModifiedDate, Version, Status ,Disclosure)
       SELECT NEWID(),@NEW_COMPANY_ID,null,[Index], ClassificationType, AccountClass, IsSystem, ClassificationName, FinancialStatementTemplate, Remarks, RecOrder, UserCreated, CreatedDate, ModifiedBy, ModifiedDate, Version, Status ,Disclosure FROM [Tax].[Classification] WHERE COMPANYID=@UNIQUE_COMPANY_ID	     
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


         SET @CONTROLCODECATEGORY_ID_MODULE_MASTER_ID = (SELECT top 1 ID FROM [Common].[ControlCodeCategory] WHERE COMPANYID=@NEW_COMPANY_ID AND CONTROLCODECATEGORYCODE='Tax Classification (Earning)')
  SET @MODULE_MASTER_ID_CONTROLCODECATEGORY_ID = (SELECT Id FROM [Common].[ModuleMaster]  WHERE COMPANYID=@UNIQUE_COMPANY_ID AND NAME='HR Cursor')
  INSERT INTO [Common].[ControlCodeCategoryModule] (Id, CompanyId, ControlCategoryId, ModuleMasterId) VALUES ((SELECT MAX(Id) + 1 FROM [Common].[ControlCodeCategoryModule]),
  @NEW_COMPANY_ID,@CONTROLCODECATEGORY_ID_MODULE_MASTER_ID,@MODULE_MASTER_ID_CONTROLCODECATEGORY_ID);




      SET @CONTROLCODECATEGORY_ID_MODULE_MASTER_ID = (SELECT top 1 ID FROM [Common].[ControlCodeCategory] WHERE COMPANYID=@NEW_COMPANY_ID AND CONTROLCODECATEGORYCODE='Tax Classification (Deduction)')
  SET @MODULE_MASTER_ID_CONTROLCODECATEGORY_ID = (SELECT Id FROM [Common].[ModuleMaster]  WHERE COMPANYID=@UNIQUE_COMPANY_ID AND NAME='HR Cursor')
  INSERT INTO [Common].[ControlCodeCategoryModule] (Id, CompanyId, ControlCategoryId, ModuleMasterId) VALUES ((SELECT MAX(Id) + 1 FROM [Common].[ControlCodeCategoryModule]),
  @NEW_COMPANY_ID,@CONTROLCODECATEGORY_ID_MODULE_MASTER_ID,@MODULE_MASTER_ID_CONTROLCODECATEGORY_ID);


   ------------------------------------------------Appraisal Cycle--------------------------------------------------

     	  SET @CONTROLCODECATEGORY_ID_MODULE_MASTER_ID = (SELECT top 1 ID FROM [Common].[ControlCodeCategory] WHERE COMPANYID=@NEW_COMPANY_ID AND CONTROLCODECATEGORYCODE='Appraisal Cycle')
  SET @MODULE_MASTER_ID_CONTROLCODECATEGORY_ID = (SELECT Id FROM [Common].[ModuleMaster]  WHERE COMPANYID=@UNIQUE_COMPANY_ID AND NAME='HR Cursor')
  INSERT INTO [Common].[ControlCodeCategoryModule] (Id, CompanyId, ControlCategoryId, ModuleMasterId) VALUES ((SELECT MAX(Id) + 1 FROM [Common].[ControlCodeCategoryModule]),
  @NEW_COMPANY_ID,@CONTROLCODECATEGORY_ID_MODULE_MASTER_ID,@MODULE_MASTER_ID_CONTROLCODECATEGORY_ID);

	  
   ------------------------------------------------Suggestion Screenname--------------------------------------------------

        SET @CONTROLCODECATEGORY_ID_MODULE_MASTER_ID = (SELECT top 1 ID FROM [Common].[ControlCodeCategory] WHERE COMPANYID=@NEW_COMPANY_ID AND CONTROLCODECATEGORYCODE='Suggestion Screenname')
  SET @MODULE_MASTER_ID_CONTROLCODECATEGORY_ID = (SELECT Id FROM [Common].[ModuleMaster]  WHERE COMPANYID=@UNIQUE_COMPANY_ID AND NAME='Admin Cursor')
  INSERT INTO [Common].[ControlCodeCategoryModule] (Id, CompanyId, ControlCategoryId, ModuleMasterId) VALUES ((SELECT MAX(Id) + 1 FROM [Common].[ControlCodeCategoryModule]),
  @NEW_COMPANY_ID,@CONTROLCODECATEGORY_ID_MODULE_MASTER_ID,@MODULE_MASTER_ID_CONTROLCODECATEGORY_ID);

 
  
   ------------------------------------------------Foreign Exchange Analysis--------------------------------------------------

        SET @CONTROLCODECATEGORY_ID_MODULE_MASTER_ID = (SELECT top 1 ID FROM [Common].[ControlCodeCategory] WHERE COMPANYID=@NEW_COMPANY_ID AND CONTROLCODECATEGORYCODE='Foreign Exchange Analysis')
  SET @MODULE_MASTER_ID_CONTROLCODECATEGORY_ID = (SELECT Id FROM [Common].[ModuleMaster]  WHERE COMPANYID=@UNIQUE_COMPANY_ID AND NAME='Admin Cursor')
  INSERT INTO [Common].[ControlCodeCategoryModule] (Id, CompanyId, ControlCategoryId, ModuleMasterId) VALUES ((SELECT MAX(Id) + 1 FROM [Common].[ControlCodeCategoryModule]),
  @NEW_COMPANY_ID,@CONTROLCODECATEGORY_ID_MODULE_MASTER_ID,@MODULE_MASTER_ID_CONTROLCODECATEGORY_ID);

 
  
   ------------------------------------------------'Functional Currency Analysis--------------------------------------------------

        SET @CONTROLCODECATEGORY_ID_MODULE_MASTER_ID = (SELECT top 1 ID FROM [Common].[ControlCodeCategory] WHERE COMPANYID=@NEW_COMPANY_ID AND CONTROLCODECATEGORYCODE='Functional Currency Analysis')
  SET @MODULE_MASTER_ID_CONTROLCODECATEGORY_ID = (SELECT Id FROM [Common].[ModuleMaster]  WHERE COMPANYID=@UNIQUE_COMPANY_ID AND NAME='Admin Cursor')
  INSERT INTO [Common].[ControlCodeCategoryModule] (Id, CompanyId, ControlCategoryId, ModuleMasterId) VALUES ((SELECT MAX(Id) + 1 FROM [Common].[ControlCodeCategoryModule]),
  @NEW_COMPANY_ID,@CONTROLCODECATEGORY_ID_MODULE_MASTER_ID,@MODULE_MASTER_ID_CONTROLCODECATEGORY_ID);

  
 -------------------------------16-11-2017----Type of Claim-----------------------------------------------
 
 SET @CONTROLCODECATEGORY_ID_MODULE_MASTER_ID = (SELECT top 1 ID FROM [Common].[ControlCodeCategory] WHERE COMPANYID=@NEW_COMPANY_ID AND CONTROLCODECATEGORYCODE='Type of Claim')
  SET @MODULE_MASTER_ID_CONTROLCODECATEGORY_ID = (SELECT Id FROM [Common].[ModuleMaster]  WHERE COMPANYID=@UNIQUE_COMPANY_ID AND NAME='Tax Cursor')
  INSERT INTO [Common].[ControlCodeCategoryModule] (Id, CompanyId, ControlCategoryId, ModuleMasterId) VALUES ((SELECT MAX(Id) + 1 FROM [Common].[ControlCodeCategoryModule]),
  @NEW_COMPANY_ID,@CONTROLCODECATEGORY_ID_MODULE_MASTER_ID,@MODULE_MASTER_ID_CONTROLCODECATEGORY_ID);


  -------------------------------16-11-2017----Asset Classification-----------------------------------------------
 
 SET @CONTROLCODECATEGORY_ID_MODULE_MASTER_ID = (SELECT top 1 ID FROM [Common].[ControlCodeCategory] WHERE COMPANYID=@NEW_COMPANY_ID AND CONTROLCODECATEGORYCODE='Asset Classification')
  SET @MODULE_MASTER_ID_CONTROLCODECATEGORY_ID = (SELECT Id FROM [Common].[ModuleMaster]  WHERE COMPANYID=@UNIQUE_COMPANY_ID AND NAME='Tax Cursor')
  INSERT INTO [Common].[ControlCodeCategoryModule] (Id, CompanyId, ControlCategoryId, ModuleMasterId) VALUES ((SELECT MAX(Id) + 1 FROM [Common].[ControlCodeCategoryModule]),
  @NEW_COMPANY_ID,@CONTROLCODECATEGORY_ID_MODULE_MASTER_ID,@MODULE_MASTER_ID_CONTROLCODECATEGORY_ID);

  
   -------------------------------Appendix

 SET @CONTROLCODECATEGORY_ID_MODULE_MASTER_ID = (SELECT top 1 ID FROM [Common].[ControlCodeCategory] WHERE COMPANYID=@NEW_COMPANY_ID AND CONTROLCODECATEGORYCODE='Appendix')
  SET @MODULE_MASTER_ID_CONTROLCODECATEGORY_ID = (SELECT Id FROM [Common].[ModuleMaster]  WHERE COMPANYID=@UNIQUE_COMPANY_ID AND NAME='Tax Cursor')
  INSERT INTO [Common].[ControlCodeCategoryModule] (Id, CompanyId, ControlCategoryId, ModuleMasterId) VALUES ((SELECT MAX(Id) + 1 FROM [Common].[ControlCodeCategoryModule]), @NEW_COMPANY_ID,@CONTROLCODECATEGORY_ID_MODULE_MASTER_ID,@MODULE_MASTER_ID_CONTROLCODECATEGORY_ID);
 
  ----------------------------------------Appendix-1-Medical Exp

   SET @CONTROLCODECATEGORY_ID_MODULE_MASTER_ID = (SELECT top 1 ID FROM [Common].[ControlCodeCategory] WHERE COMPANYID=@NEW_COMPANY_ID AND CONTROLCODECATEGORYCODE='Appendix-1-Medical Exp')
  SET @MODULE_MASTER_ID_CONTROLCODECATEGORY_ID = (SELECT Id FROM [Common].[ModuleMaster]  WHERE COMPANYID=@UNIQUE_COMPANY_ID AND NAME='Tax Cursor')
  INSERT INTO [Common].[ControlCodeCategoryModule] (Id, CompanyId, ControlCategoryId, ModuleMasterId) VALUES ((SELECT MAX(Id) + 1 FROM [Common].[ControlCodeCategoryModule]), @NEW_COMPANY_ID,@CONTROLCODECATEGORY_ID_MODULE_MASTER_ID,@MODULE_MASTER_ID_CONTROLCODECATEGORY_ID);


	  --------------------------------------------------------InitialSetup----------------------------------------------------
   INSERT INTO [Common].[InitialCursorSetup] ([Id], [CompanyId], [ModuleId], [ModuleDetailId], [IsSetUpDone],[MainModuleId],[Status],[MasterModuleId],[IsCommonModule])  
   SELECT ROW_NUMBER() OVER(ORDER BY ID) + (SELECT MAX(ID)  FROM [Common].[InitialCursorSetup]) ,@NEW_COMPANY_ID, [ModuleId], [ModuleDetailId], [IsSetUpDone],[MainModuleId],[Status],[MasterModuleId],[IsCommonModule] from 
   [Common].[InitialCursorSetup] WHERE CompanyId=@UNIQUE_COMPANY_ID and MasterModuleId in (select moduleid from common.companyModule where companyid=@NEW_COMPANY_ID and status=1);
	---------------------------------------------CommonModule-------------------------------------------------------------------
	UPDATE [Common].[CompanyModule] SET [SetupDone]= 1 WHERE [ModuleId] = (select Id from common.modulemaster where Name='Audit Cursor') AND [CompanyId] = @NEW_COMPANY_ID
	UPDATE [Common].[CompanyModule] SET [SetupDone]= 1 WHERE [ModuleId] = (select Id from common.modulemaster where Name='Knowledge Cursor') AND [CompanyId] = @NEW_COMPANY_ID
	UPDATE [Common].[CompanyModule] SET [SetupDone]= 1 WHERE [ModuleId] = (select Id from common.modulemaster where Name='Doc Cursor') AND [CompanyId] = @NEW_COMPANY_ID
	UPDATE [Common].[CompanyModule] SET [SetupDone]= 1 WHERE [ModuleId] = (select Id from common.modulemaster where Name='Tax Cursor') AND [CompanyId] = @NEW_COMPANY_ID
	UPDATE [Common].[CompanyModule] SET [SetupDone]= 1 WHERE [ModuleId] = (select Id from common.modulemaster where Name='BR Cursor') AND [CompanyId] = @NEW_COMPANY_ID
					

					--------------------------------------------------Bean-Entity-----------------------------------------
INSERT INTO [Bean].[Entity]([Id],[CompanyId],[Name],[TypeId],[IdTypeId],[IdNo],[GSTRegNo],[IsCustomer],[CustTOPId],[CustTOP],[CustTOPValue],[CustCreditLimit],[CustCurrency],[CustNature],[IsVendor],[VenTOPId],[VenTOP],[VenTOPValue],[VenCurrency],[VenNature],[AddressBookId],[IsLocal],[ResBlockHouseNo],[ResStreet],[ResUnitNo],[ResBuildingEstate],[ResCity],[ResPostalCode],[ResState],[ResCountry],[RecOrder],[Remarks],[UserCreated],[CreatedDate],[ModifiedBy],[ModifiedDate],[Version],[Status],[VenCreditLimit],[Communication],[VendorType],[IsShowPayroll]) SELECT(NEWID()),@NEW_COMPANY_ID,[Name],[TypeId],[IdTypeId],[IdNo],[GSTRegNo],[IsCustomer],[CustTOPId],[CustTOP],[CustTOPValue],[CustCreditLimit],[CustCurrency],[CustNature],[IsVendor],[VenTOPId],[VenTOP],[VenTOPValue],[VenCurrency],[VenNature],[AddressBookId],[IsLocal],[ResBlockHouseNo],[ResStreet],[ResUnitNo],[ResBuildingEstate],[ResCity],[ResPostalCode],[ResState],[ResCountry],[RecOrder],[Remarks],[UserCreated],[CreatedDate],[ModifiedBy],[ModifiedDate],[Version],[Status],[VenCreditLimit],[Communication],[VendorType],[IsShowPayroll] from Bean.Entity where COMPANYID=@UNIQUE_COMPANY_ID

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
