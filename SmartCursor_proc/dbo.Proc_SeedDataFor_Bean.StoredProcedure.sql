USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[Proc_SeedDataFor_Bean]    Script Date: 16-12-2024 9.20.11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE PROCEDURE [dbo].[Proc_SeedDataFor_Bean](@NEW_COMPANY_ID bigint,@UNIQUE_COMPANY_ID bigint)
 AS 
 BEGIN
 		 
		 
        DECLARE @CONTROLCODECATEGORY_ID_MODULE_MASTER_ID BIGINT
	    DECLARE @MODULE_MASTER_ID_CONTROLCODECATEGORY_ID BIGINT
	    DECLARE @ACCOUNTYPE_ID_ID_TYPE_ID BIGINT
	    DECLARE @ID_TYPE_ACCOUNTYPE_ID_ID BIGINT	
        DECLARE @CREATED_DATE DATETIME	
        SET @CREATED_DATE =GETUTCDATE()
		DECLARE @ACCOUNTTYPE_ID BIGINT,@NEW_aCCOUNTTYPE_ID BIGINT
		DECLARE @AccountType_Cnt bigint
		select @AccountType_Cnt=count(*) from [Bean].[AccountType]  where CompanyId=@NEW_COMPANY_ID
		IF @AccountType_Cnt=0
		Begin
		DECLARE ACCOUNT_CURSOR CURSOR FOR 
		SELECT iD FROM [Bean].[AccountType] WHERE COMPANYiD=0			
		OPEN ACCOUNT_CURSOR
		FETCH NEXT FROM ACCOUNT_CURSOR INTO @ACCOUNTTYPE_ID
		WHILE @@FETCH_STATUS=0
		BEGIN   
			SET @NEW_aCCOUNTTYPE_ID=(SELECT MAX(id) + 1 FROM [Bean].[AccountType])
								
			INSERT INTO [Bean].[AccountType] (Id, CompanyId, Name, Class, Category, SubCategory, Nature, AppliesTo, IsSystem, ShowCurrency, RecOrder,
				Remarks, UserCreated, CreatedDate, ModifiedBy, ModifiedDate, Version, Status, ShowCashflowType, ShowAllowable, ShowRevaluation, Indexs, ModuleType,CashflowType,FRATId,StandardRecOrder)
			SELECT @NEW_aCCOUNTTYPE_ID, @NEW_COMPANY_ID, Name, Class, Category, SubCategory, Nature, AppliesTo, IsSystem, ShowCurrency, RecOrder, Remarks, UserCreated, 
			@CREATED_DATE, ModifiedBy, ModifiedDate, Version, status, ShowCashflowType, ShowAllowable, ShowRevaluation, Indexs, ModuleType,CashflowType ,NEWID(),StandardRecOrder
			FROM [Bean].[AccountType]  WHERE COMPANYID=0 AND ID=@ACCOUNTTYPE_ID
				   	             
			INSERT INTO   [Bean].[ChartOfAccount] (Id, CompanyId, Code, Name, AccountTypeId, Class, Category, SubCategory, Nature, Currency, ShowRevaluation, CashflowType,
			AppliesTo, IsSystem, IsShowforCOA, RecOrder, Remarks, UserCreated, CreatedDate, ModifiedBy, ModifiedDate, Version, Status, IsSubLedger, IsCodeEditable,
			ShowCurrency, ShowCashFlow, ShowAllowable, IsRevaluation, Revaluation, DisAllowable, RealisedExchangeGainOrLoss, UnrealisedExchangeGainOrLoss, ModuleType,IsSeedData,IsDebt,IsLinkedAccount,IsRealCOA,FRCoaId,FRPATId)	
			SELECT ROW_NUMBER() OVER(ORDER BY ID) + (SELECT MAX(Id) FROM [Bean].[ChartOfAccount]) AS Id, @NEW_COMPANY_ID,Code, Name, @NEW_aCCOUNTTYPE_ID, Class, Category, SubCategory,
			Nature, Currency, ShowRevaluation, CashflowType, AppliesTo, IsSystem, IsShowforCOA, RecOrder, Remarks,
            UserCreated, @CREATED_DATE, ModifiedBy, ModifiedDate, Version, status, IsSubLedger, IsCodeEditable, ShowCurrency, ShowCashFlow, ShowAllowable, IsRevaluation, Revaluation, 
            DisAllowable, RealisedExchangeGainOrLoss, UnrealisedExchangeGainOrLoss, ModuleType,IsSeedData,IsDebt,IsLinkedAccount,IsRealCOA,NEWID(), (select FRATId from Bean.AccountType Where Id=@NEW_aCCOUNTTYPE_ID)  FROM [Bean].[ChartOfAccount] WHERE COMPANYID=0 AND Status!=3 AND Name!='Inventory revaluation' AND AccountTypeId = @ACCOUNTTYPE_ID
			FETCH NEXT FROM ACCOUNT_CURSOR INTO @ACCOUNTTYPE_ID
		END	
		CLOSE ACCOUNT_CURSOR
		Deallocate ACCOUNT_CURSOR	
		End

		-----Insert data for Intercompany transaction-----------

		--Declare  @companyId bigint=420;
		IF((Select CF.Status from Common.Feature F
			JOIN Common.CompanyFeatures CF on F.Id=CF.FeatureId
			where CF.Companyid=@NEW_COMPANY_ID and F.Name='Inter-Company' and F.ModuleId is null)=1)
		BEGIN
		--	Declare @COACOUNT bigint =(Select Max(Id) from Bean.ChartOfAccount)
			Insert into Bean.ChartOfAccount (Id,CompanyId,Code,Name,AccountTypeId,SubCategory,Category,Class,Nature,CashflowType,IsSeedData,CreatedDate,UserCreated,ModuleType,Status,IsRealCOA,SubsidaryCompanyId,IsLinkedAccount,Issystem,FRCoaId,FRPATId)	

		--	  --Select (@COACOUNT)+ROW_NUMBER()OVER(order by Id) as Id,c.ParentId as CompanyId,CONCAT('BS15000',ROW_NUMBER()OVER(order by Id)) as Code,CONCAT('I/C - ',C.ShortName) as Name,(Select Id from Bean.AccountType where CompanyId=@NEW_COMPANY_ID and Name='Intercompany clearing') As AccountTypeId,'Current' as SubCategory,'Balance Sheet' AS Category,'Assets' as Class,'Debit' as Nature,'Operating' as CashflowType,0 as IsSeedData,GETDATE() As CreatedDate,'madhu@kgtan.com' as UserCreated,'Bean' As ModuleType,1 as Status,1 as IsRealCOA,C.Id as SubsidaryCompanyId,1 as IsLinkedAccount ,NEWID() as FRCoaId,(select FRATId from Bean.AccountType Where Name='Intercompany clearing' and CompanyId=@NEW_COMPANY_ID ) as FRPATId  from Common.Company C where Id NOT IN
			  Select (ROW_NUMBER() OVER(ORDER BY ID) + (SELECT MAX(id) + 1 FROM [Bean].[ChartOfAccount])) as Id,c.ParentId as CompanyId,CONCAT('BS15000',ROW_NUMBER()OVER(order by Id)) as Code,CONCAT('I/C - ',C.ShortName) as Name,(Select Id from Bean.AccountType where CompanyId=@NEW_COMPANY_ID and Name='Intercompany clearing') As AccountTypeId,'Current' as SubCategory,'Balance Sheet' AS Category,'Assets' as Class,'Debit' as Nature,'Operating' as CashflowType,0 as IsSeedData,GETDATE() As CreatedDate,'madhu@kgtan.com' as UserCreated,'Bean' As ModuleType,1 as Status,1 as IsRealCOA,C.Id as SubsidaryCompanyId,1 as IsLinkedAccount,0 as IsSystem,NEWID() as FRCoaId,(select FRATId from Bean.AccountType Where Name='Intercompany clearing' and CompanyId=@NEW_COMPANY_ID ) as FRPATId  from Common.Company C where Id NOT IN
			  (
			  Select distinct C.Id from Bean.ChartOfAccount COA
			  JOIN Common.Company C on C.ParentId=COA.CompanyId
			  --JOIN Bean.AccountType ACT On ACT.Id=COA.AccountTypeId
			   where COA.CompanyId=@NEW_COMPANY_ID and COA.Name  LIKE '%I/C - %'
			   ) AND ParentId=@NEW_COMPANY_ID
		END


------------ControlCodeCategory Module-------------------
--Declare @ControlCodeCategory_FeeType_Cnt bigint
-- select @ControlCodeCategory_FeeType_Cnt=Count(*) from [Common].[ControlCodeCategoryModule] where companyid=@NEW_COMPANY_ID 
--and controlcategoryId in(SELECT ID FROM [Common].[ControlCodeCategory] WHERE COMPANYID=@NEW_COMPANY_ID AND CONTROLCODECATEGORYCODE='Fee Type') 
         
-- IF @ControlCodeCategory_FeeType_Cnt=0
--    Begin
--        SET @CONTROLCODECATEGORY_ID_MODULE_MASTER_ID = (SELECT ID FROM [Common].[ControlCodeCategory] WHERE COMPANYID=@NEW_COMPANY_ID AND CONTROLCODECATEGORYCODE='Fee Type')
--		SET @MODULE_MASTER_ID_CONTROLCODECATEGORY_ID = (SELECT Id FROM [Common].[ModuleMaster]  WHERE COMPANYID=@UNIQUE_COMPANY_ID AND NAME='Bean Cursor')
--		INSERT INTO [Common].[ControlCodeCategoryModule] (Id, CompanyId, ControlCategoryId, ModuleMasterId) VALUES ((SELECT MAX(Id) + 1 FROM [Common].[ControlCodeCategoryModule]),
--		@NEW_COMPANY_ID,@CONTROLCODECATEGORY_ID_MODULE_MASTER_ID,@MODULE_MASTER_ID_CONTROLCODECATEGORY_ID);
--	end
--	--------------------

--	Declare @ControlCodeCategory_CommunicationType_Cnt bigint
--   select @ControlCodeCategory_CommunicationType_Cnt=Count(*) from [Common].[ControlCodeCategoryModule] where companyid=@NEW_COMPANY_ID 
--   and controlcategoryId in(SELECT ID FROM [Common].[ControlCodeCategory] WHERE COMPANYID=@NEW_COMPANY_ID AND CONTROLCODECATEGORYCODE='CommunicationType') 
-- IF @ControlCodeCategory_CommunicationType_Cnt=0
--    Begin
--		SET @CONTROLCODECATEGORY_ID_MODULE_MASTER_ID = (SELECT ID FROM [Common].[ControlCodeCategory] WHERE COMPANYID=@NEW_COMPANY_ID AND CONTROLCODECATEGORYCODE='CommunicationType')
--		SET @MODULE_MASTER_ID_CONTROLCODECATEGORY_ID = (SELECT Id FROM [Common].[ModuleMaster]  WHERE COMPANYID=@UNIQUE_COMPANY_ID AND NAME='Bean Cursor')
--		INSERT INTO [Common].[ControlCodeCategoryModule] (Id, CompanyId, ControlCategoryId, ModuleMasterId) VALUES ((SELECT MAX(Id) + 1 FROM [Common].[ControlCodeCategoryModule]),
--		@NEW_COMPANY_ID,@CONTROLCODECATEGORY_ID_MODULE_MASTER_ID,@MODULE_MASTER_ID_CONTROLCODECATEGORY_ID);
--    end
--	----------------------
--	Declare @ControlCodeCategory_Units_Cnt bigint
--   select @ControlCodeCategory_Units_Cnt=Count(*) from [Common].[ControlCodeCategoryModule] where companyid=@NEW_COMPANY_ID 
--   and controlcategoryId in(SELECT ID FROM [Common].[ControlCodeCategory] WHERE COMPANYID=@NEW_COMPANY_ID AND CONTROLCODECATEGORYCODE='Units') 
--   IF @ControlCodeCategory_Units_Cnt=0
--  Begin
--        SET @CONTROLCODECATEGORY_ID_MODULE_MASTER_ID = (SELECT ID FROM [Common].[ControlCodeCategory] WHERE COMPANYID=@NEW_COMPANY_ID AND CONTROLCODECATEGORYCODE='Units')
--		SET @MODULE_MASTER_ID_CONTROLCODECATEGORY_ID = (SELECT Id FROM [Common].[ModuleMaster]  WHERE COMPANYID=@UNIQUE_COMPANY_ID AND NAME='Bean Cursor')
--		INSERT INTO [Common].[ControlCodeCategoryModule] (Id, CompanyId, ControlCategoryId, ModuleMasterId) VALUES ((SELECT MAX(Id) + 1 FROM [Common].[ControlCodeCategoryModule]),
--		@NEW_COMPANY_ID,@CONTROLCODECATEGORY_ID_MODULE_MASTER_ID,@MODULE_MASTER_ID_CONTROLCODECATEGORY_ID);
--  end
--  ----------------------------

--   Declare @ControlCodeCategory_Nature_Cnt bigint
--   select @ControlCodeCategory_Nature_Cnt=Count(*) from [Common].[ControlCodeCategoryModule] where companyid=@NEW_COMPANY_ID 
--   and controlcategoryId in(SELECT ID FROM [Common].[ControlCodeCategory] WHERE COMPANYID=@NEW_COMPANY_ID AND CONTROLCODECATEGORYCODE='Nature') 
--   IF @ControlCodeCategory_Nature_Cnt=0
--  Begin
--		SET @CONTROLCODECATEGORY_ID_MODULE_MASTER_ID = (SELECT ID FROM [Common].[ControlCodeCategory] WHERE COMPANYID=@NEW_COMPANY_ID AND CONTROLCODECATEGORYCODE='Nature')
--		SET @MODULE_MASTER_ID_CONTROLCODECATEGORY_ID = (SELECT Id FROM [Common].[ModuleMaster]  WHERE COMPANYID=@UNIQUE_COMPANY_ID AND NAME='Bean Cursor')
--		INSERT INTO [Common].[ControlCodeCategoryModule] (Id, CompanyId, ControlCategoryId, ModuleMasterId) VALUES ((SELECT MAX(Id) + 1 FROM [Common].[ControlCodeCategoryModule]),
--		@NEW_COMPANY_ID,@CONTROLCODECATEGORY_ID_MODULE_MASTER_ID,@MODULE_MASTER_ID_CONTROLCODECATEGORY_ID);			
--   end


--   --------------------- mode of Transfer(controlcodecategory)--------------------

--   Declare @ControlCodeCategory_ModeOfReceipt_Cnt bigint
--   select @ControlCodeCategory_ModeOfReceipt_Cnt=Count(*) from [Common].[ControlCodeCategoryModule] where companyid=@NEW_COMPANY_ID 
--   and controlcategoryId in(SELECT ID FROM [Common].[ControlCodeCategory] WHERE COMPANYID=@NEW_COMPANY_ID AND CONTROLCODECATEGORYCODE='ModeOfTransfer') 
--   IF @ControlCodeCategory_ModeOfReceipt_Cnt=0
--  Begin
--		SET @CONTROLCODECATEGORY_ID_MODULE_MASTER_ID = (SELECT ID FROM [Common].[ControlCodeCategory] WHERE COMPANYID=@NEW_COMPANY_ID AND CONTROLCODECATEGORYCODE='ModeOfTransfer')
--		SET @MODULE_MASTER_ID_CONTROLCODECATEGORY_ID = (SELECT Id FROM [Common].[ModuleMaster]  WHERE COMPANYID=@UNIQUE_COMPANY_ID AND NAME='Bean Cursor')
--		INSERT INTO [Common].[ControlCodeCategoryModule] (Id, CompanyId, ControlCategoryId, ModuleMasterId) VALUES ((SELECT MAX(Id) + 1 FROM [Common].[ControlCodeCategoryModule]),
--		@NEW_COMPANY_ID,@CONTROLCODECATEGORY_ID_MODULE_MASTER_ID,@MODULE_MASTER_ID_CONTROLCODECATEGORY_ID);			
--   end

Exec [dbo].[ControlCodeCategoryModule_SP_New] @NEW_COMPANY_ID,4


   
   
 --  if not exists(select * from Bean.Item where Code='Rounding (GST)'and CompanyId=@NEW_COMPANY_ID)
 --Insert Into Bean.Item (Id,CompanyId,Code,Description,COAId,DefaultTaxcodeId,CreatedDate,Status,IsExternalData) values 
 --(NEWID(),@NEW_COMPANY_ID,'Rounding (GST)','Rounding (GST)',(select Id from Bean.ChartOfAccount where Name='Rounding' and CompanyId=@NEW_COMPANY_ID),( select Id from Bean.TaxCode where Name='NA' and CompanyId=@UNIQUE_COMPANY_ID),GETDATE(),1,1)
   ------------for Bean category Seed data---------

   
--Declare @id1 uniqueidentifier=newid();
--if not exists(select * from Bean.Category where Name='Assets' and CompanyId=@NEW_COMPANY_ID)
--INSERT INTO [Bean].[Category]([Id],[CompanyId],[Name],[Type],[Recorder],[IsIncomeStatement],[LeadsheetId],[ColorCode],[AccountClass],[IsCollapse])
--     VALUES  (@id1,@NEW_COMPANY_ID,'Assets','LeadSheet',1,Null,null,'clr1',null ,1)

--if not exists(select * from Bean.Category where Name='Current Assets' and CompanyId=@NEW_COMPANY_ID)	 
--INSERT INTO [Bean].[SubCategory]  ([Id],[Name],[CategoryId],[Recorder],[Type],[CompanyId],[TypeId],[SubCategoryOrder],[ParentId],[IsIncomeStatement],[ColorCode], [AccountClass],[IsCollapse])
--     VALUES (NEWID(),'Current Assets','00000000-0000-0000-0000-000000000000',1,'LeadSheet',@NEW_COMPANY_ID,'91021766-F6F8-49FE-A230-66295B4BC3FB'
--           ,null ,@id1,null,null,null,1)
--if not exists(select * from Bean.Category where Name='Non-current Assets' and CompanyId=@NEW_COMPANY_ID)	
--INSERT INTO [Bean].[SubCategory]  ([Id],[Name],[CategoryId],[Recorder],[Type],[CompanyId],[TypeId],[SubCategoryOrder],[ParentId],[IsIncomeStatement],[ColorCode], [AccountClass],[IsCollapse])
--     VALUES (NEWID(),'Non-current Assets','00000000-0000-0000-0000-000000000000',2,'LeadSheet',@NEW_COMPANY_ID,'81021766-F6F8-49FE-A230-66295B4BC3FB'
--           ,null ,@id1,null,null,null,1)

--Declare @id2 uniqueidentifier=newid();
--if not exists(select * from Bean.Category where Name='Liabilities' and CompanyId=@NEW_COMPANY_ID)	
--INSERT INTO [Bean].[Category]([Id],[CompanyId],[Name],[Type],[Recorder],[IsIncomeStatement],[LeadsheetId],[ColorCode],[AccountClass],[IsCollapse])
--     VALUES  (@id2,@NEW_COMPANY_ID,'Liabilities','LeadSheet',1,Null,null,'clr2',null ,1)
--if not exists(select * from Bean.Category where Name='Current Liabilities' and CompanyId=@NEW_COMPANY_ID)	
--INSERT INTO [Bean].[SubCategory]  ([Id],[Name],[CategoryId],[Recorder],[Type],[CompanyId],[TypeId],[SubCategoryOrder],[ParentId],[IsIncomeStatement],
--[ColorCode],[AccountClass],[IsCollapse])
--     VALUES (NEWID(),'Current Liabilities','00000000-0000-0000-0000-000000000000',1,'LeadSheet',@NEW_COMPANY_ID,'71021766-F6F8-49FE-A230-66295B4BC3FB'
--           ,null ,@id2,null,null,null,1)

--if not exists(select * from Bean.Category where Name='Non-current Liabilities' and CompanyId=@NEW_COMPANY_ID)	
--INSERT INTO [Bean].[SubCategory]  ([Id],[Name],[CategoryId],[Recorder],[Type],[CompanyId],[TypeId],[SubCategoryOrder],[ParentId],[IsIncomeStatement],[ColorCode], [AccountClass],[IsCollapse])
--     VALUES (NEWID(),'Non-current Liabilities','00000000-0000-0000-0000-000000000000',2,'LeadSheet',@NEW_COMPANY_ID,'61021766-F6F8-49FE-A230-66295B4BC3FB'
--           ,null ,@id2,null,null,null,1)

--if not exists(select * from Bean.Category where Name='Equity and Liabilities' and CompanyId=@NEW_COMPANY_ID)	
--Declare @id3 uniqueidentifier=newid();
--INSERT INTO [Bean].[Category]([Id],[CompanyId],[Name],[Type],[Recorder],[IsIncomeStatement],[LeadsheetId],[ColorCode],[AccountClass],[IsCollapse])
--     VALUES  (@id3,@NEW_COMPANY_ID,'Equity and Liabilities','SubTotal',2,Null,null,'clr5',null ,1)

--if not exists(select * from Bean.Category where Name='Equity' and CompanyId=@NEW_COMPANY_ID)	
--INSERT INTO [Bean].[SubCategory]  ([Id],[Name],[CategoryId],[Recorder],[Type],[CompanyId],[TypeId],[SubCategoryOrder],[ParentId],[IsIncomeStatement],
--[ColorCode],[AccountClass],[IsCollapse])
--     VALUES (NEWID(),'Equity','00000000-0000-0000-0000-000000000000',1,'LeadSheet',@NEW_COMPANY_ID,'41021766-F6F8-49FE-A230-66295B4BC3FB'
--           ,null ,@id3,null,null,null,1)

--if not exists(select * from Bean.Category where Name='Liabilities' and CompanyId=@NEW_COMPANY_ID)	
--INSERT INTO [Bean].[SubCategory]  ([Id],[Name],[CategoryId],[Recorder],[Type],[CompanyId],[TypeId],[SubCategoryOrder],[ParentId],[IsIncomeStatement],
--[ColorCode],[AccountClass],[IsCollapse])
--     VALUES (NEWID(),'Liabilities','00000000-0000-0000-0000-000000000000',2,'SubTotal',@NEW_COMPANY_ID,(select Id  from Bean.Category where Name='Liabilities' and CompanyId=@NEW_COMPANY_ID)
--           ,null ,@id3,null,null,null,1)



Declare @id1 uniqueidentifier=newid();
if not exists(select * from Bean.Category where Name='Assets' and CompanyId=@NEW_COMPANY_ID)
Begin
INSERT INTO [Bean].[Category]([Id],[CompanyId],[Name],[Type],[Recorder],[IsIncomeStatement],[LeadsheetId],[ColorCode],[AccountClass],[IsCollapse])
     VALUES  (@id1,@NEW_COMPANY_ID,'Assets','LeadSheet',1,Null,null,'clr1',null ,1)
End


if not exists(select * from Bean.[SubCategory] where Name='Current Assets' and CompanyId=@NEW_COMPANY_ID)
Begin	 
INSERT INTO [Bean].[SubCategory]  ([Id],[Name],[CategoryId],[Recorder],[Type],[CompanyId],[TypeId],[SubCategoryOrder],[ParentId],[IsIncomeStatement],[ColorCode], [AccountClass],[IsCollapse])
     VALUES (NEWID(),'Current Assets','00000000-0000-0000-0000-000000000000',1,'LeadSheet',@NEW_COMPANY_ID,'91021766-F6F8-49FE-A230-66295B4BC3FB'
           ,null ,@id1,null,null,null,1)
End


if not exists(select * from Bean.[SubCategory] where Name='Non-current Assets' and CompanyId=@NEW_COMPANY_ID)	
Begin
INSERT INTO [Bean].[SubCategory]  ([Id],[Name],[CategoryId],[Recorder],[Type],[CompanyId],[TypeId],[SubCategoryOrder],[ParentId],[IsIncomeStatement],[ColorCode], [AccountClass],[IsCollapse])
     VALUES (NEWID(),'Non-current Assets','00000000-0000-0000-0000-000000000000',2,'LeadSheet',@NEW_COMPANY_ID,'81021766-F6F8-49FE-A230-66295B4BC3FB'
           ,null ,@id1,null,null,null,1)
End


Declare @id2 uniqueidentifier=newid();
Begin
if not exists(select * from Bean.Category where Name='Liabilities' and CompanyId=@NEW_COMPANY_ID)	
INSERT INTO [Bean].[Category]([Id],[CompanyId],[Name],[Type],[Recorder],[IsIncomeStatement],[LeadsheetId],[ColorCode],[AccountClass],[IsCollapse])
     VALUES  (@id2,@NEW_COMPANY_ID,'Liabilities','LeadSheet',1,Null,null,'clr2',null ,1)
End


if not exists(select * from Bean.[SubCategory] where Name='Current Liabilities' and CompanyId=@NEW_COMPANY_ID)	
Begin
INSERT INTO [Bean].[SubCategory]  ([Id],[Name],[CategoryId],[Recorder],[Type],[CompanyId],[TypeId],[SubCategoryOrder],[ParentId],[IsIncomeStatement],
[ColorCode],[AccountClass],[IsCollapse])
     VALUES (NEWID(),'Current Liabilities','00000000-0000-0000-0000-000000000000',1,'LeadSheet',@NEW_COMPANY_ID,'71021766-F6F8-49FE-A230-66295B4BC3FB'
           ,null ,@id2,null,null,null,1)
End


if not exists(select * from Bean.[SubCategory] where Name='Non-current Liabilities' and CompanyId=@NEW_COMPANY_ID)	
Begin
INSERT INTO [Bean].[SubCategory]  ([Id],[Name],[CategoryId],[Recorder],[Type],[CompanyId],[TypeId],[SubCategoryOrder],[ParentId],[IsIncomeStatement],[ColorCode], [AccountClass],[IsCollapse])
     VALUES (NEWID(),'Non-current Liabilities','00000000-0000-0000-0000-000000000000',2,'LeadSheet',@NEW_COMPANY_ID,'61021766-F6F8-49FE-A230-66295B4BC3FB',null ,@id2,null,null,null,1)
End


Declare @id3 uniqueidentifier=newid();
if not exists(select * from Bean.Category where Name='Equity and Liabilities' and CompanyId=@NEW_COMPANY_ID)	
Begin
INSERT INTO [Bean].[Category]([Id],[CompanyId],[Name],[Type],[Recorder],[IsIncomeStatement],[LeadsheetId],[ColorCode],[AccountClass],[IsCollapse])
     VALUES  (@id3,@NEW_COMPANY_ID,'Equity and Liabilities','SubTotal',2,Null,null,'clr5',null ,1)
End


if not exists(select * from Bean.[SubCategory] where Name='Equity' and CompanyId=@NEW_COMPANY_ID)	
Begin
INSERT INTO [Bean].[SubCategory]  ([Id],[Name],[CategoryId],[Recorder],[Type],[CompanyId],[TypeId],[SubCategoryOrder],[ParentId],[IsIncomeStatement],
[ColorCode],[AccountClass],[IsCollapse])
     VALUES (NEWID(),'Equity','00000000-0000-0000-0000-000000000000',1,'LeadSheet',@NEW_COMPANY_ID,'41021766-F6F8-49FE-A230-66295B4BC3FB'
           ,null ,@id3,null,null,null,1)
End



if not exists(select * from Bean.[SubCategory] where Name='Liabilities' and CompanyId=@NEW_COMPANY_ID)	
Begin
INSERT INTO [Bean].[SubCategory]  ([Id],[Name],[CategoryId],[Recorder],[Type],[CompanyId],[TypeId],[SubCategoryOrder],[ParentId],[IsIncomeStatement],
[ColorCode],[AccountClass],[IsCollapse])
     VALUES (NEWID(),'Liabilities','00000000-0000-0000-0000-000000000000',2,'SubTotal',@NEW_COMPANY_ID,(select Id  from Bean.Category where Name='Liabilities' and CompanyId=@NEW_COMPANY_ID),null ,@id3,null,null,null,1)
End







----------------Income Statement --Seed Data for Category

------------------GrossProfit
BEGIN 
 IF NOT EXISTS (SELECT * FROM [Bean].[Category]  WHERE Name='Gross Profit' and CompanyId=@NEW_COMPANY_ID  )
BEGIN 

INSERT INTO [Bean].[Category]([Id],[CompanyId],[Name],[Type],[Recorder],[IsIncomeStatement], [LeadsheetId],[ColorCode],[AccountClass],[IsCollapse])
     VALUES
           (NEWID(),@NEW_COMPANY_ID,'Gross Profit','LeadSheet',1,1,null,'clr1',null,null)
END
END;

-------------------Profit before Tax

BEGIN 
 IF NOT EXISTS (SELECT * FROM [Bean].[Category]  WHERE Name='Profit before Tax' and CompanyId=@NEW_COMPANY_ID)
BEGIN 

INSERT INTO [Bean].[Category]([Id],[CompanyId],[Name],[Type],[Recorder],[IsIncomeStatement], [LeadsheetId],[ColorCode],[AccountClass],[IsCollapse])
     VALUES
           (NEWID(),@NEW_COMPANY_ID,'Profit before Tax','SubTotal',2,1,null,'clr2',null,null)
END
END;

-------------------Profit after Tax


BEGIN 
 IF NOT EXISTS (SELECT * FROM [Bean].[Category]  WHERE Name='Profit after Tax' and CompanyId=@NEW_COMPANY_ID )
BEGIN 

INSERT INTO [Bean].[Category]([Id],[CompanyId],[Name],[Type],[Recorder],[IsIncomeStatement], [LeadsheetId],[ColorCode],[AccountClass],[IsCollapse])
     VALUES
           (NEWID(),@NEW_COMPANY_ID,'Profit after Tax','SubTotal',2,1,null,'clr3',null,null)
END
END;

----------------Income Statement --Seed Data for SubCategory


------------------GrossProfit--Revenue

BEGIN 
 IF NOT EXISTS (SELECT * FROM [Bean].[SubCategory]  WHERE ParentId =(Select Id From [Bean].[Category] Where Name='Gross Profit' and CompanyId=@NEW_COMPANY_ID) and Name='Revenue' and CompanyId=@NEW_COMPANY_ID)
BEGIN 

INSERT INTO [Bean].[SubCategory]([Id],[Name],[CategoryId],[Recorder],[Type],[CompanyId],[TypeId],
           [SubCategoryOrder],[ParentId],[IsIncomeStatement],[ColorCode],[AccountClass],[IsCollapse])
     VALUES (NEWID(),'Revenue','00000000-0000-0000-0000-000000000000',1,'LeadSheet',@NEW_COMPANY_ID,(Select FRATId From Bean.AccountType Where CompanyId=@NEW_COMPANY_ID and Name='Revenue'),'',(Select Id From [Bean].[Category]Where Name='Gross Profit' and CompanyId=@NEW_COMPANY_ID),1,null,null,null)
END
END;

------------------GrossProfit--Direct costs


BEGIN 
 IF NOT EXISTS (SELECT * FROM [Bean].[SubCategory]  WHERE ParentId =(Select Id From [Bean].[Category] Where Name='Gross Profit' and CompanyId=@NEW_COMPANY_ID) and Name='Direct costs' and CompanyId=@NEW_COMPANY_ID)
BEGIN 

INSERT INTO [Bean].[SubCategory]([Id],[Name],[CategoryId],[Recorder],[Type],[CompanyId],[TypeId],
           [SubCategoryOrder],[ParentId],[IsIncomeStatement],[ColorCode],[AccountClass],[IsCollapse])
     VALUES (NEWID(),'Direct costs','00000000-0000-0000-0000-000000000000',2,'LeadSheet',@NEW_COMPANY_ID,(Select FRATId From Bean.AccountType Where CompanyId=@NEW_COMPANY_ID and Name='Direct costs'),'',(Select Id From [Bean].[Category]Where Name='Gross Profit' and CompanyId=@NEW_COMPANY_ID),1,null,null,null)
END
END;

-----------------Profit before Tax-----GrossProfit

BEGIN 
 IF NOT EXISTS (SELECT * FROM [Bean].[SubCategory]  WHERE ParentId =(Select Id From [Bean].[Category] Where Name='Profit before Tax' and CompanyId=@NEW_COMPANY_ID) and Name='Gross Profit' and CompanyId=@NEW_COMPANY_ID)
BEGIN 

INSERT INTO [Bean].[SubCategory]([Id],[Name],[CategoryId],[Recorder],[Type],[CompanyId],[TypeId],
           [SubCategoryOrder],[ParentId],[IsIncomeStatement],[ColorCode],[AccountClass],[IsCollapse])
     VALUES (NEWID(),'Gross Profit','00000000-0000-0000-0000-000000000000',1,'SubTotal',@NEW_COMPANY_ID,(Select Id From [Bean].[Category] Where CompanyId=@NEW_COMPANY_ID and Name='Gross Profit'),'',(Select Id From [Bean].[Category]Where Name='Profit before Tax' and CompanyId=@NEW_COMPANY_ID),1,null,null,null)
END
END;
------------------Profit before Tax--Operating expenses

BEGIN 
 IF NOT EXISTS (SELECT * FROM [Bean].[SubCategory]  WHERE ParentId =(Select Id From [Bean].[Category]       Where Name='Profit before Tax' and CompanyId=@NEW_COMPANY_ID) and Name='Operating expenses' and CompanyId=@NEW_COMPANY_ID)
BEGIN 

INSERT INTO [Bean].[SubCategory]([Id],[Name],[CategoryId],[Recorder],[Type],[CompanyId],[TypeId],
           [SubCategoryOrder],[ParentId],[IsIncomeStatement],[ColorCode],[AccountClass],[IsCollapse])
     VALUES (NEWID(),'Operating expenses','00000000-0000-0000-0000-000000000000',3,'LeadSheet',@NEW_COMPANY_ID,(Select FRATId From Bean.AccountType Where CompanyId=@NEW_COMPANY_ID and Name='Operating expenses'),'',(Select Id From [Bean].[Category]Where Name='Profit before Tax' and CompanyId=@NEW_COMPANY_ID),1,null,null,null)
END
END;


------------------Profit before Tax--Exchange gain/loss


BEGIN 
 IF NOT EXISTS (SELECT * FROM [Bean].[SubCategory]  WHERE ParentId =(Select Id From [Bean].[Category] Where Name='Profit before Tax' and CompanyId=@NEW_COMPANY_ID) and Name='Exchange gain/loss' and CompanyId=@NEW_COMPANY_ID)
BEGIN 

INSERT INTO [Bean].[SubCategory]([Id],[Name],[CategoryId],[Recorder],[Type],[CompanyId],[TypeId],
           [SubCategoryOrder],[ParentId],[IsIncomeStatement],[ColorCode],[AccountClass],[IsCollapse])
     VALUES (NEWID(),'Exchange gain/loss','00000000-0000-0000-0000-000000000000',14,'LeadSheet',@NEW_COMPANY_ID,(Select FRATId From Bean.AccountType Where CompanyId=@NEW_COMPANY_ID and Name='Exchange gain/loss'),'',(Select Id From [Bean].[Category]Where Name='Profit before Tax' and CompanyId=@NEW_COMPANY_ID),1,null,null,null)
END
END;

------------------Profit before Tax--Rounding


BEGIN 
 IF NOT EXISTS (SELECT * FROM [Bean].[SubCategory]  WHERE ParentId =(Select Id From [Bean].[Category] Where Name='Profit before Tax' and CompanyId=@NEW_COMPANY_ID) and Name='Rounding' and CompanyId=@NEW_COMPANY_ID)
BEGIN 

INSERT INTO [Bean].[SubCategory]([Id],[Name],[CategoryId],[Recorder],[Type],[CompanyId],[TypeId],
           [SubCategoryOrder],[ParentId],[IsIncomeStatement],[ColorCode],[AccountClass],[IsCollapse])
     VALUES (NEWID(),'Rounding','00000000-0000-0000-0000-000000000000',11,'LeadSheet',@NEW_COMPANY_ID,(Select FRATId From Bean.AccountType Where CompanyId=@NEW_COMPANY_ID and Name='Rounding'),'',(Select Id From [Bean].[Category]Where Name='Profit before Tax' and CompanyId=@NEW_COMPANY_ID),1,null,null,null)
END
END;

------------------Profit before Tax--Other expenses


BEGIN 
 IF NOT EXISTS (SELECT * FROM [Bean].[SubCategory]  WHERE ParentId =(Select Id From [Bean].[Category] Where Name='Profit before Tax' and CompanyId=@NEW_COMPANY_ID) and Name='Other expenses' and CompanyId=@NEW_COMPANY_ID)
BEGIN 

INSERT INTO [Bean].[SubCategory]([Id],[Name],[CategoryId],[Recorder],[Type],[CompanyId],[TypeId],
           [SubCategoryOrder],[ParentId],[IsIncomeStatement],[ColorCode],[AccountClass],[IsCollapse])
     VALUES (NEWID(),'Other expenses','00000000-0000-0000-0000-000000000000',10,'LeadSheet',@NEW_COMPANY_ID,(Select FRATId From Bean.AccountType Where CompanyId=@NEW_COMPANY_ID and Name='Other expenses'),'',(Select Id From [Bean].[Category]Where Name='Profit before Tax' and CompanyId=@NEW_COMPANY_ID),1,null,null,null)
END
END;


------------------Profit before Tax--Other income


BEGIN 
 IF NOT EXISTS (SELECT * FROM [Bean].[SubCategory]  WHERE ParentId =(Select Id From [Bean].[Category]       Where Name='Profit before Tax' and CompanyId=@NEW_COMPANY_ID) and Name='Other income' and CompanyId=@NEW_COMPANY_ID)
BEGIN 

INSERT INTO [Bean].[SubCategory]([Id],[Name],[CategoryId],[Recorder],[Type],[CompanyId],[TypeId],
           [SubCategoryOrder],[ParentId],[IsIncomeStatement],[ColorCode],[AccountClass],[IsCollapse])
     VALUES (NEWID(),'Other income','00000000-0000-0000-0000-000000000000',12,'LeadSheet',@NEW_COMPANY_ID,(Select FRATId From Bean.AccountType Where CompanyId=@NEW_COMPANY_ID and Name='Other income'),'',(Select Id From [Bean].[Category]Where Name='Profit before Tax' and CompanyId=@NEW_COMPANY_ID),1,null,null,null)
END
END;

------------------Profit before Tax--General and admin expenses


BEGIN 
 IF NOT EXISTS (SELECT * FROM [Bean].[SubCategory]  WHERE ParentId =(Select Id From [Bean].[Category]       Where Name='Profit before Tax' and CompanyId=@NEW_COMPANY_ID) and Name='General and admin expenses' and CompanyId=@NEW_COMPANY_ID)
BEGIN 

INSERT INTO [Bean].[SubCategory]([Id],[Name],[CategoryId],[Recorder],[Type],[CompanyId],[TypeId],
           [SubCategoryOrder],[ParentId],[IsIncomeStatement],[ColorCode],[AccountClass],[IsCollapse])
   VALUES (NEWID(),'General and admin expenses','00000000-0000-0000-0000-000000000000',4,'LeadSheet',@NEW_COMPANY_ID,(Select FRATId From Bean.AccountType Where CompanyId=@NEW_COMPANY_ID and Name='General and admin expenses'),'',(Select Id From [Bean].[Category]Where Name='Profit before Tax' and CompanyId=@NEW_COMPANY_ID),1,null,null,null)
END
END;


------------------Profit before Tax--Sales and marketing expenses


BEGIN 
 IF NOT EXISTS (SELECT * FROM [Bean].[SubCategory]  WHERE ParentId =(Select Id From [Bean].[Category]       Where Name='Profit before Tax' and CompanyId=@NEW_COMPANY_ID) and Name='Sales and marketing expenses' and CompanyId=@NEW_COMPANY_ID)
BEGIN 

INSERT INTO [Bean].[SubCategory]([Id],[Name],[CategoryId],[Recorder],[Type],[CompanyId],[TypeId],
           [SubCategoryOrder],[ParentId],[IsIncomeStatement],[ColorCode],[AccountClass],[IsCollapse])
 VALUES (NEWID(),'Sales and marketing expenses','00000000-0000-0000-0000-000000000000',5,'LeadSheet',@NEW_COMPANY_ID,(Select FRATId From Bean.AccountType Where CompanyId=@NEW_COMPANY_ID and Name='Sales and marketing expenses'),'',(Select Id From [Bean].[Category]Where Name='Profit before Tax' and CompanyId=@NEW_COMPANY_ID),1,null,null,null)
END
END;


------------------Profit before Tax--Amortisation


BEGIN 
 IF NOT EXISTS (SELECT * FROM [Bean].[SubCategory]  WHERE ParentId =(Select Id From [Bean].[Category]       Where Name='Profit before Tax' and CompanyId=@NEW_COMPANY_ID) and Name='Amortisation' and CompanyId=@NEW_COMPANY_ID)
BEGIN 

INSERT INTO [Bean].[SubCategory]([Id],[Name],[CategoryId],[Recorder],[Type],[CompanyId],[TypeId],
           [SubCategoryOrder],[ParentId],[IsIncomeStatement],[ColorCode],[AccountClass],[IsCollapse])
 VALUES (NEWID(),'Amortisation','00000000-0000-0000-0000-000000000000',9,'LeadSheet',@NEW_COMPANY_ID,(Select FRATId From Bean.AccountType Where CompanyId=@NEW_COMPANY_ID and Name='Amortisation'),'',(Select Id From [Bean].[Category]Where Name='Profit before Tax' and CompanyId=@NEW_COMPANY_ID),1,null,null,null)
END
END;

------------------Profit before Tax--Depreciation


BEGIN 
 IF NOT EXISTS (SELECT * FROM [Bean].[SubCategory]  WHERE ParentId =(Select Id From [Bean].[Category]       Where Name='Profit before Tax' and CompanyId=@NEW_COMPANY_ID) and Name='Depreciation' and CompanyId=@NEW_COMPANY_ID)
BEGIN 

INSERT INTO [Bean].[SubCategory]([Id],[Name],[CategoryId],[Recorder],[Type],[CompanyId],[TypeId],
           [SubCategoryOrder],[ParentId],[IsIncomeStatement],[ColorCode],[AccountClass],[IsCollapse])
 VALUES (NEWID(),'Depreciation','00000000-0000-0000-0000-000000000000',8,'LeadSheet',@NEW_COMPANY_ID,(Select FRATId From Bean.AccountType Where CompanyId=@NEW_COMPANY_ID and Name='Depreciation'),'',(Select Id From [Bean].[Category]Where Name='Profit before Tax' and CompanyId=@NEW_COMPANY_ID),1,null,null,null)
END
END;
------------------Profit before Tax--Interest expenses

BEGIN 
 IF NOT EXISTS (SELECT * FROM [Bean].[SubCategory]  WHERE ParentId =(Select Id From [Bean].[Category]       Where Name='Profit before Tax' and CompanyId=@NEW_COMPANY_ID) and Name='Interest expenses' and CompanyId=@NEW_COMPANY_ID)
BEGIN 

INSERT INTO [Bean].[SubCategory]([Id],[Name],[CategoryId],[Recorder],[Type],[CompanyId],[TypeId],
           [SubCategoryOrder],[ParentId],[IsIncomeStatement],[ColorCode],[AccountClass],[IsCollapse])
 VALUES (NEWID(),'Interest expenses','00000000-0000-0000-0000-000000000000',7,'LeadSheet',@NEW_COMPANY_ID,(Select FRATId From Bean.AccountType Where CompanyId=@NEW_COMPANY_ID and Name='Interest expenses'),'',(Select Id From [Bean].[Category]Where Name='Profit before Tax' and CompanyId=@NEW_COMPANY_ID),1,null,null,null)
END
END;


------------------Profit before Tax--Interest income


BEGIN 
 IF NOT EXISTS (SELECT * FROM [Bean].[SubCategory]  WHERE ParentId =(Select Id From [Bean].[Category]       Where Name='Profit before Tax' and CompanyId=@NEW_COMPANY_ID) and Name='Interest income' and CompanyId=@NEW_COMPANY_ID)
BEGIN 

INSERT INTO [Bean].[SubCategory]([Id],[Name],[CategoryId],[Recorder],[Type],[CompanyId],[TypeId],
           [SubCategoryOrder],[ParentId],[IsIncomeStatement],[ColorCode],[AccountClass],[IsCollapse])
 VALUES (NEWID(),'Interest income','00000000-0000-0000-0000-000000000000',13,'LeadSheet',@NEW_COMPANY_ID,(Select FRATId From Bean.AccountType Where CompanyId=@NEW_COMPANY_ID and Name='Interest income'),'',(Select Id From [Bean].[Category]Where Name='Profit before Tax' and CompanyId=@NEW_COMPANY_ID),1,null,null,null)
END
END;

------------------Profit before Tax--Interest income


BEGIN 
 IF NOT EXISTS (SELECT * FROM [Bean].[SubCategory]  WHERE ParentId =(Select Id From [Bean].[Category]       Where Name='Profit before Tax' and CompanyId=@NEW_COMPANY_ID) and Name='Staff cost' and CompanyId=@NEW_COMPANY_ID)
BEGIN 

INSERT INTO [Bean].[SubCategory]([Id],[Name],[CategoryId],[Recorder],[Type],[CompanyId],[TypeId],
           [SubCategoryOrder],[ParentId],[IsIncomeStatement],[ColorCode],[AccountClass],[IsCollapse])
 VALUES (NEWID(),'Staff cost','00000000-0000-0000-0000-000000000000',6,'LeadSheet',@NEW_COMPANY_ID,(Select FRATId From Bean.AccountType Where CompanyId=@NEW_COMPANY_ID and Name='Staff cost'),'',(Select Id From [Bean].[Category]Where Name='Profit before Tax' and CompanyId=@NEW_COMPANY_ID),1,null,null,null)
END
END;

-----------------Profit after Tax-----Profit before Tax'

BEGIN 
 IF NOT EXISTS (SELECT * FROM [Bean].[SubCategory]  WHERE ParentId =(Select Id From [Bean].[Category]             Where Name='Profit after Tax' and CompanyId=@NEW_COMPANY_ID) and Name='Profit before Tax' and CompanyId=@NEW_COMPANY_ID)
BEGIN 

INSERT INTO [Bean].[SubCategory]([Id],[Name],[CategoryId],[Recorder],[Type],[CompanyId],[TypeId],
           [SubCategoryOrder],[ParentId],[IsIncomeStatement],[ColorCode],[AccountClass],[IsCollapse])
     VALUES (NEWID(),'Profit before Tax','00000000-0000-0000-0000-000000000000',1,'SubTotal',@NEW_COMPANY_ID,(Select Id From [Bean].[Category] Where CompanyId=@NEW_COMPANY_ID and Name='Profit before Tax'),'',(Select Id From [Bean].[Category]Where Name='Profit after Tax' and CompanyId=@NEW_COMPANY_ID),1,null,null,null)
END
END;

------------------Profit after Tax--Operating expenses


BEGIN 
 IF NOT EXISTS (SELECT * FROM [Bean].[SubCategory]  WHERE ParentId =(Select Id From [Bean].[Category]       Where Name='Profit after Tax' and CompanyId=@NEW_COMPANY_ID) and Name='Taxation' and CompanyId=@NEW_COMPANY_ID)
BEGIN 

INSERT INTO [Bean].[SubCategory]([Id],[Name],[CategoryId],[Recorder],[Type],[CompanyId],[TypeId],
           [SubCategoryOrder],[ParentId],[IsIncomeStatement],[ColorCode],[AccountClass],[IsCollapse])
     VALUES (NEWID(),'Taxation','00000000-0000-0000-0000-000000000000',15,'LeadSheet',@NEW_COMPANY_ID,(Select FRATId From Bean.AccountType Where CompanyId=@NEW_COMPANY_ID and Name='Taxation'),'',(Select Id From [Bean].[Category]Where Name='Profit after Tax' and CompanyId=@NEW_COMPANY_ID),1,null,null,null)
END
END;










	                                          --------------------------------Bean-Entity-----------------------------------------
	----------------------------------------------------------------------------------------------------------------------------------------------------------------
	Declare @Entity_Cnt bigint;
			Select 	 @Entity_Cnt=Count(*)
            from 	[Bean].[Entity] where companyid=@NEW_COMPANY_ID	
	        IF @Entity_Cnt=0
	Begin		
            INSERT INTO [Bean].[Entity]([Id],[CompanyId],[Name],[TypeId],[IdTypeId],[IdNo],[GSTRegNo],[IsCustomer],[CustTOPId],[CustTOP],[CustTOPValue],[CustCreditLimit],[CustCurrency],[CustNature],[IsVendor],[VenTOPId],[VenTOP],[VenTOPValue],[VenCurrency],[VenNature],[AddressBookId],[IsLocal],[ResBlockHouseNo],[ResStreet],[ResUnitNo],[ResBuildingEstate],[ResCity],[ResPostalCode],[ResState],[ResCountry],[RecOrder],[Remarks],[UserCreated],[CreatedDate],[ModifiedBy],[ModifiedDate],[Version],[Status],[VenCreditLimit],[Communication],[VendorType],[IsShowPayroll]) SELECT(NEWID()),@NEW_COMPANY_ID,[Name],[TypeId],[IdTypeId],[IdNo],[GSTRegNo],[IsCustomer],[CustTOPId],[CustTOP],[CustTOPValue],[CustCreditLimit],[CustCurrency],[CustNature],[IsVendor],[VenTOPId],[VenTOP],[VenTOPValue],[VenCurrency],[VenNature],[AddressBookId],[IsLocal],[ResBlockHouseNo],[ResStreet],[ResUnitNo],[ResBuildingEstate],[ResCity],[ResPostalCode],[ResState],[ResCountry],[RecOrder],[Remarks],[UserCreated],[CreatedDate],[ModifiedBy],[ModifiedDate],[Version],[Status],[VenCreditLimit],[Communication],[VendorType],[IsShowPayroll] from Bean.Entity where COMPANYID=@UNIQUE_COMPANY_ID;
    end

	Declare @CompanyFeatures_Cnt BIGINT
	select 	@CompanyFeatures_Cnt=Count(*) from [Common].[Feature] a join [Common].[CompanyFeatures] b on a.Id=b.FeatureId where a.VisibleStyle <> 'SuperUser-CheckBox' and a.VisibleStyle <> 'HRCursor-CheckBox' and CompanyId=@NEW_COMPANY_ID

	IF @CompanyFeatures_Cnt=0
	Begin
		INSERT INTO common.CompanyFeatures(Id,CompanyId,FeatureId,Status,Remarks,IsChecked,CreatedDate,UserCreated)
		select  NEWID(),@NEW_COMPANY_ID,b.FeatureId,b.Status,b.Remarks,b.IsChecked,GETDATE(),'System' from [Common].[Feature] a join [Common].			[CompanyFeatures] b on a.Id=b.FeatureId where a.VisibleStyle <> 'SuperUser-CheckBox' and a.VisibleStyle <> 'HRCursor-CheckBox' and CompanyId=@UNIQUE_COMPANY_ID
	End

	 If (((select status from common.companymodule where companyid=@NEW_COMPANY_ID and moduleid=(select Id from common.ModuleMaster where Name='Workflow Cursor' and companyId=0)) = 1) and ((select status from common.companymodule where companyid=@NEW_COMPANY_ID and moduleid=(select Id from common.ModuleMaster where Name='Bean Cursor' and companyId=0)) = 1)) 
	Begin
	   EXEC [dbo].[SP_WF_2_Bean]  @NEW_COMPANY_ID
    END
    If (((select status from common.companymodule where companyid=@NEW_COMPANY_ID and moduleid=(select Id from common.ModuleMaster where Name='Hr Cursor' and companyId=0)) = 1) and ((select status from common.companymodule where companyid=@NEW_COMPANY_ID and moduleid=(select Id from common.ModuleMaster where Name='Bean Cursor' and companyId=0)) = 1)) 
	Begin
	   EXEC [dbo].[SP_HR_2_Bean]  @NEW_COMPANY_ID
	   	---HR Cursor paycomponent coa Seed Data-----------//new changes on 07-12-2019
		Begin Try
			If Exists(Select Id from HR.PayComponent where CompanyId=@NEW_COMPANY_ID and COAId is null)
			Begin
				Update pay set pay.COAId=coa.Id 
				from hr.PayComponent pay
				left join Bean.ChartOfAccount coa on coa.Name=pay.DefaultCOA and coa.CompanyId=@NEW_COMPANY_ID
				where pay.CompanyId=@NEW_COMPANY_ID and pay.COAId is null
			End
		End Try
		Begin Catch
		End Catch
    END






	--------------Template Insertion-------------------

	 ----   if not exists(select * from Common.TemplateType where name='Invoice' and CompanyId=@NEW_COMPANY_ID)
		----begin
		----	insert into Common.TemplateType (Id, CompanyId, ModuleMasterId, Name,Description, RecOrder, Remarks,Status, Actions) values
		----	(Newid(), @NEW_COMPANY_ID,(select Id from Common.ModuleMaster where name='Bean Cursor'), 'Invoice',NULL,25,NULL,1,NULL)
		----end
		--if not exists(select Id from Common.GenericTemplate where name='Invoice' and Code='Invoice' and CompanyId=@NEW_COMPANY_ID and TemplateTypeId=(select id from Common.TemplateType where CompanyId=0 and ModuleMasterId=(select Id from Common.ModuleMaster where name='Bean Cursor') and Name='Invoice'))
		--begin
		--	insert into Common.GenericTemplate (Id, CompanyId, TemplateTypeId, Name, Code, TempletContent,IsSystem,IsFooterExist,IsHeaderExist, RecOrder, Remarks, UserCreated, CreatedDate, ModifiedBy, ModifiedDate, Version, Status, TemplateType, IsPartnerTemplate) 
		--	select NEWID(), @NEW_COMPANY_ID, (select Id from Common.TemplateType where Name='Invoice' and CompanyId=@UNIQUE_COMPANY_ID and ModuleMasterId=(select Id from Common.ModuleMaster where name='Bean Cursor')), Name, Code, TempletContent,IsSystem,IsFooterExist,IsHeaderExist, RecOrder, Remarks, UserCreated, CreatedDate, ModifiedBy, ModifiedDate, Version, Status, TemplateType, IsPartnerTemplate from Common.GenericTemplate where CompanyId=@UNIQUE_COMPANY_ID and Code='Invoice' and TemplateTypeId=(select id from Common.TemplateType where CompanyId=@UNIQUE_COMPANY_ID and ModuleMasterId=(select Id from Common.ModuleMaster where name='Bean Cursor') and Name='Invoice')
		--end

  ----      if not exists(select * from Common.TemplateType where name='Credit Note' and CompanyId=@NEW_COMPANY_ID)
		----begin
		----	insert into Common.TemplateType (Id, CompanyId, ModuleMasterId, Name,Description, RecOrder, Remarks,Status, Actions) values
		----	(Newid(), @NEW_COMPANY_ID,(select Id from Common.ModuleMaster where name='Bean Cursor'), 'Credit Note',NULL,25,NULL,1,NULL)
		----end
		--if not exists(select Id from Common.GenericTemplate where name='Credit Note' and Code='Credit Note' and CompanyId=@NEW_COMPANY_ID and TemplateTypeId=(select id from Common.TemplateType where CompanyId=0 and ModuleMasterId=(select Id from Common.ModuleMaster where name='Bean Cursor') and Name='Credit Note'))
		--begin
		--	insert into Common.GenericTemplate (Id, CompanyId, TemplateTypeId, Name, Code, TempletContent,IsSystem,IsFooterExist,IsHeaderExist, RecOrder, Remarks, UserCreated, CreatedDate, ModifiedBy, ModifiedDate, Version, Status, TemplateType, IsPartnerTemplate) 
		--	select NEWID(), @NEW_COMPANY_ID, (select Id from Common.TemplateType where Name='Credit Note' and CompanyId=@UNIQUE_COMPANY_ID and ModuleMasterId=(select Id from Common.ModuleMaster where name='Bean Cursor')), Name, Code, TempletContent,IsSystem,IsFooterExist,IsHeaderExist, RecOrder, Remarks, UserCreated, CreatedDate, ModifiedBy, ModifiedDate, Version, Status, TemplateType, IsPartnerTemplate from Common.GenericTemplate where CompanyId=@UNIQUE_COMPANY_ID and Code='Credit Note' and TemplateTypeId=(select id from Common.TemplateType where CompanyId=@UNIQUE_COMPANY_ID and ModuleMasterId=(select Id from Common.ModuleMaster where name='Bean Cursor') and Name='Credit Note')
		--end


  ----     if not exists(select * from Common.TemplateType where name='Receipt' and CompanyId=@NEW_COMPANY_ID)
		----begin
		----	insert into Common.TemplateType (Id, CompanyId, ModuleMasterId, Name,Description, RecOrder, Remarks,Status, Actions) values
		----	(Newid(), @NEW_COMPANY_ID,(select Id from Common.ModuleMaster where name='Bean Cursor'), 'Receipt',NULL,25,NULL,1,NULL)
		----end
		--if not exists(select Id from Common.GenericTemplate where name='Receipt' and Code='Receipt' and CompanyId=@NEW_COMPANY_ID and TemplateTypeId=(select Id from Common.TemplateType where CompanyId=0 and ModuleMasterId=(select Id from Common.ModuleMaster where name='Bean Cursor') and Name='Receipt'))
		--begin
		--	insert into Common.GenericTemplate (Id, CompanyId, TemplateTypeId, Name, Code, TempletContent,IsSystem,IsFooterExist,IsHeaderExist, RecOrder, Remarks, UserCreated, CreatedDate, ModifiedBy, ModifiedDate, Version, Status, TemplateType, IsPartnerTemplate) 
		--	select NEWID(), @NEW_COMPANY_ID, (select Id from Common.TemplateType where Name='Receipt' and CompanyId=@UNIQUE_COMPANY_ID and ModuleMasterId=(select Id from Common.ModuleMaster where name='Bean Cursor')), Name, Code, TempletContent,IsSystem,IsFooterExist,IsHeaderExist, RecOrder, Remarks, UserCreated, CreatedDate, ModifiedBy, ModifiedDate, Version, Status, TemplateType, IsPartnerTemplate from Common.GenericTemplate where CompanyId=@UNIQUE_COMPANY_ID and Code='Receipt' and TemplateTypeId=(select id from Common.TemplateType where CompanyId=@UNIQUE_COMPANY_ID and ModuleMasterId=(select Id from Common.ModuleMaster where name='Bean Cursor') and Name='Receipt')
		--end

  ----      if not exists(select * from Common.TemplateType where name='Statement Of Account' and CompanyId=@NEW_COMPANY_ID)
		----begin
		----	insert into Common.TemplateType (Id, CompanyId, ModuleMasterId, Name,Description, RecOrder, Remarks,Status, Actions) values
		----	(Newid(), @NEW_COMPANY_ID,(select Id from Common.ModuleMaster where name='Bean Cursor'), 'Statement Of Account',NULL,25,NULL,1,NULL)
		----end
		--if not exists(select Id from Common.GenericTemplate where name='Statement Of Account' and Code='Statement Of Account' and CompanyId=@NEW_COMPANY_ID and TemplateTypeId=(select id from Common.TemplateType where CompanyId=0 and ModuleMasterId=(select Id from Common.ModuleMaster where name='Bean Cursor') and Name='Statement Of Account'))
		--begin
		--	insert into Common.GenericTemplate (Id, CompanyId, TemplateTypeId, Name, Code, TempletContent,IsSystem,IsFooterExist,IsHeaderExist, RecOrder, Remarks, UserCreated, CreatedDate, ModifiedBy, ModifiedDate, Version, Status, TemplateType, IsPartnerTemplate) 
		--	select NEWID(), @NEW_COMPANY_ID, (select Id from Common.TemplateType where Name='Statement Of Account' and CompanyId=@UNIQUE_COMPANY_ID and ModuleMasterId=(select Id from Common.ModuleMaster where name='Bean Cursor')), Name, Code, TempletContent,IsSystem,IsFooterExist,IsHeaderExist, RecOrder, Remarks, UserCreated, CreatedDate, ModifiedBy, ModifiedDate, Version, Status, TemplateType, IsPartnerTemplate from Common.GenericTemplate where CompanyId=@UNIQUE_COMPANY_ID and Code='Statement Of Account' and TemplateTypeId=(select id from Common.TemplateType where CompanyId=@UNIQUE_COMPANY_ID and ModuleMasterId=(select Id from Common.ModuleMaster where name='Bean Cursor') and Name='Statement Of Account')
		--end

		--	if not exists(select Id from Common.GenericTemplate where name='Bean Invoice Email' and Code='Bean Invoice Email' and CompanyId=@NEW_COMPANY_ID and TemplateTypeId=(select id from Common.TemplateType where CompanyId=0 and ModuleMasterId=(select Id from Common.ModuleMaster where name='Bean Cursor') and Name='Bean Invoice Email'))
		--begin
		--	insert into Common.GenericTemplate (Id, CompanyId, TemplateTypeId, Name, Code, TempletContent,IsSystem,IsFooterExist,IsHeaderExist, RecOrder, Remarks, UserCreated, CreatedDate, ModifiedBy, ModifiedDate, Version, Status, TemplateType, IsPartnerTemplate) 
		--	select NEWID(), @NEW_COMPANY_ID, (select Id from Common.TemplateType where Name='Bean Invoice Email' and CompanyId=@UNIQUE_COMPANY_ID and ModuleMasterId=(select Id from Common.ModuleMaster where name='Bean Cursor')), Name, Code, TempletContent,IsSystem,IsFooterExist,IsHeaderExist, RecOrder, Remarks, UserCreated, CreatedDate, ModifiedBy, ModifiedDate, Version, Status, TemplateType, IsPartnerTemplate from Common.GenericTemplate where CompanyId=@UNIQUE_COMPANY_ID and Code='Bean Invoice Email' and TemplateTypeId=(select id from Common.TemplateType where CompanyId=@UNIQUE_COMPANY_ID and ModuleMasterId=(select Id from Common.ModuleMaster where name='Bean Cursor') and Name='Bean Invoice Email')
		--end

		--if not exists(select Id from Common.GenericTemplate where name='Bean Credit Note Email' and Code='Bean Credit Note Email' and CompanyId=@NEW_COMPANY_ID and TemplateTypeId=(select id from Common.TemplateType where CompanyId=0 and ModuleMasterId=(select Id from Common.ModuleMaster where name='Bean Cursor') and Name='Bean Credit Note Email'))
		--begin
		--	insert into Common.GenericTemplate (Id, CompanyId, TemplateTypeId, Name, Code, TempletContent,IsSystem,IsFooterExist,IsHeaderExist, RecOrder, Remarks, UserCreated, CreatedDate, ModifiedBy, ModifiedDate, Version, Status, TemplateType, IsPartnerTemplate) 
		--	select NEWID(), @NEW_COMPANY_ID, (select Id from Common.TemplateType where Name='Bean Credit Note Email' and CompanyId=@UNIQUE_COMPANY_ID and ModuleMasterId=(select Id from Common.ModuleMaster where name='Bean Cursor')), Name, Code, TempletContent,IsSystem,IsFooterExist,IsHeaderExist, RecOrder, Remarks, UserCreated, CreatedDate, ModifiedBy, ModifiedDate, Version, Status, TemplateType, IsPartnerTemplate from Common.GenericTemplate where CompanyId=@UNIQUE_COMPANY_ID and Code='Credit Note Email' and TemplateTypeId=(select id from Common.TemplateType where CompanyId=@UNIQUE_COMPANY_ID and ModuleMasterId=(select Id from Common.ModuleMaster where name='Bean Cursor') and Name='Bean Credit Note Email')
		--end

		--if not exists(select Id from Common.GenericTemplate where name='Bean Receipt Email' and Code='Bean Receipt Email' and CompanyId=@NEW_COMPANY_ID and TemplateTypeId=(select id from Common.TemplateType where CompanyId=0 and ModuleMasterId=(select Id from Common.ModuleMaster where name='Bean Cursor') and Name='Bean Receipt Email'))
		--begin
		--	insert into Common.GenericTemplate (Id, CompanyId, TemplateTypeId, Name, Code, TempletContent,IsSystem,IsFooterExist,IsHeaderExist, RecOrder, Remarks, UserCreated, CreatedDate, ModifiedBy, ModifiedDate, Version, Status, TemplateType, IsPartnerTemplate) 
		--	select NEWID(), @NEW_COMPANY_ID, (select Id from Common.TemplateType where Name='Bean Receipt Email' and CompanyId=@UNIQUE_COMPANY_ID and ModuleMasterId=(select Id from Common.ModuleMaster where name='Bean Cursor')), Name, Code, TempletContent,IsSystem,IsFooterExist,IsHeaderExist, RecOrder, Remarks, UserCreated, CreatedDate, ModifiedBy, ModifiedDate, Version, Status, TemplateType, IsPartnerTemplate from Common.GenericTemplate where CompanyId=@UNIQUE_COMPANY_ID and Code='Bean Receipt Email' and TemplateTypeId=(select id from Common.TemplateType where CompanyId=@UNIQUE_COMPANY_ID and ModuleMasterId=(select Id from Common.ModuleMaster where name='Bean Cursor') and Name='Bean Receipt Email')
		--end

		--if not exists(select Id from Common.GenericTemplate where name='SOA Email' and Code='SOA Email' and CompanyId=@NEW_COMPANY_ID and TemplateTypeId=(select id from Common.TemplateType where CompanyId=0 and ModuleMasterId=(select Id from Common.ModuleMaster where name='Bean Cursor') and Name='SOA Email'))
		--begin
		--	insert into Common.GenericTemplate (Id, CompanyId, TemplateTypeId, Name, Code, TempletContent,IsSystem,IsFooterExist,IsHeaderExist, RecOrder, Remarks, UserCreated, CreatedDate, ModifiedBy, ModifiedDate, Version, Status, TemplateType, IsPartnerTemplate) 
		--	select NEWID(), @NEW_COMPANY_ID, (select Id from Common.TemplateType where Name='SOA Email' and CompanyId=@UNIQUE_COMPANY_ID and ModuleMasterId=(select Id from Common.ModuleMaster where name='Bean Cursor')), Name, Code, TempletContent,IsSystem,IsFooterExist,IsHeaderExist, RecOrder, Remarks, UserCreated, CreatedDate, ModifiedBy, ModifiedDate, Version, Status, TemplateType, IsPartnerTemplate from Common.GenericTemplate where CompanyId=@UNIQUE_COMPANY_ID and Code='SOA Email' and TemplateTypeId=(select id from Common.TemplateType where CompanyId=@UNIQUE_COMPANY_ID and ModuleMasterId=(select Id from Common.ModuleMaster where name='Bean Cursor') and Name='SOA Email')
		--end


		--------------------------DN
		--if not exists(select Id from Common.GenericTemplate where name='Debit Note' and Code='Debit Note' and CompanyId=@NEW_COMPANY_ID and TemplateTypeId=(select id from Common.TemplateType where CompanyId=0 and ModuleMasterId=(select Id from Common.ModuleMaster where name='Bean Cursor') and Name='Debit Note'))
		--begin
		--	insert into Common.GenericTemplate (Id, CompanyId, TemplateTypeId, Name, Code, TempletContent,IsSystem,IsFooterExist,IsHeaderExist, RecOrder, Remarks, UserCreated, CreatedDate, ModifiedBy, ModifiedDate, Version, Status, TemplateType, IsPartnerTemplate) 
		--	select NEWID(), @NEW_COMPANY_ID, (select Id from Common.TemplateType where Name='Debit Note' and CompanyId=@UNIQUE_COMPANY_ID and ModuleMasterId=(select Id from Common.ModuleMaster where name='Bean Cursor')), Name, Code, TempletContent,IsSystem,IsFooterExist,IsHeaderExist, RecOrder, Remarks, UserCreated, CreatedDate, ModifiedBy, ModifiedDate, Version, Status, TemplateType, IsPartnerTemplate from Common.GenericTemplate where CompanyId=@UNIQUE_COMPANY_ID and Code='Debit Note' and TemplateTypeId=(select id from Common.TemplateType where CompanyId=@UNIQUE_COMPANY_ID and ModuleMasterId=(select Id from Common.ModuleMaster where name='Bean Cursor') and Name='Debit Note')
		--end

		--------------------------DN Email
		--if not exists(select Id from Common.GenericTemplate where name='Bean Debit Note Email' and Code='Debit Note Email' and CompanyId=@NEW_COMPANY_ID and TemplateTypeId=(select id from Common.TemplateType where CompanyId=0 and ModuleMasterId=(select Id from Common.ModuleMaster where name='Bean Cursor') and Name='Bean Debit Note Email'))
		--begin
		--	insert into Common.GenericTemplate (Id, CompanyId, TemplateTypeId, Name, Code, TempletContent,IsSystem,IsFooterExist,IsHeaderExist, RecOrder, Remarks, UserCreated, CreatedDate, ModifiedBy, ModifiedDate, Version, Status, TemplateType, IsPartnerTemplate) 
		--	select NEWID(), @NEW_COMPANY_ID, (select Id from Common.TemplateType where Name='Bean Debit Note Email' and CompanyId=@UNIQUE_COMPANY_ID and ModuleMasterId=(select Id from Common.ModuleMaster where name='Bean Cursor')), Name, Code, TempletContent,IsSystem,IsFooterExist,IsHeaderExist, RecOrder, Remarks, UserCreated, CreatedDate, ModifiedBy, ModifiedDate, Version, Status, TemplateType, IsPartnerTemplate from Common.GenericTemplate where CompanyId=@UNIQUE_COMPANY_ID and Code='Debit Note Email' and TemplateTypeId=(select id from Common.TemplateType where CompanyId=@UNIQUE_COMPANY_ID and ModuleMasterId=(select Id from Common.ModuleMaster where name='Bean Cursor') and Name='Bean Debit Note Email')
		--end

		--------------------------DN Multiple Email
		--if not exists(select Id from Common.GenericTemplate where name='Debit Note Multiple Email' and Code='DN Multiple Email' and CompanyId=@NEW_COMPANY_ID and TemplateTypeId=(select id from Common.TemplateType where CompanyId=0 and ModuleMasterId=(select Id from Common.ModuleMaster where name='Bean Cursor') and Name='Debit Note Multiple Email'))
		--begin
		--	insert into Common.GenericTemplate (Id, CompanyId, TemplateTypeId, Name, Code, TempletContent,IsSystem,IsFooterExist,IsHeaderExist, RecOrder, Remarks, UserCreated, CreatedDate, ModifiedBy, ModifiedDate, Version, Status, TemplateType, IsPartnerTemplate) 
		--	select NEWID(), @NEW_COMPANY_ID, (select Id from Common.TemplateType where Name='Debit Note Multiple Email' and CompanyId=@UNIQUE_COMPANY_ID and ModuleMasterId=(select Id from Common.ModuleMaster where name='Bean Cursor')), Name, Code, TempletContent,IsSystem,IsFooterExist,IsHeaderExist, RecOrder, Remarks, UserCreated, CreatedDate, ModifiedBy, ModifiedDate, Version, Status, TemplateType, IsPartnerTemplate from Common.GenericTemplate where CompanyId=@UNIQUE_COMPANY_ID and Code='DN Multiple Email' and TemplateTypeId=(select id from Common.TemplateType where CompanyId=@UNIQUE_COMPANY_ID and ModuleMasterId=(select Id from Common.ModuleMaster where name='Bean Cursor') and Name='Debit Note Multiple Email')
		--end

		-------------------------Cash Sale
		--if not exists(select Id from Common.GenericTemplate where name='Cash Sale' and Code='Cash Sale' and CompanyId=@NEW_COMPANY_ID and TemplateTypeId=(select id from Common.TemplateType where CompanyId=0 and ModuleMasterId=(select Id from Common.ModuleMaster where name='Bean Cursor') and Name='Cash Sale'))
		--begin
		--	insert into Common.GenericTemplate (Id, CompanyId, TemplateTypeId, Name, Code, TempletContent,IsSystem,IsFooterExist,IsHeaderExist, RecOrder, Remarks, UserCreated, CreatedDate, ModifiedBy, ModifiedDate, Version, Status, TemplateType, IsPartnerTemplate) 
		--	select NEWID(), @NEW_COMPANY_ID, (select Id from Common.TemplateType where Name='Cash Sale' and CompanyId=@UNIQUE_COMPANY_ID and ModuleMasterId=(select Id from Common.ModuleMaster where name='Bean Cursor')), Name, Code, TempletContent,IsSystem,IsFooterExist,IsHeaderExist, RecOrder, Remarks, UserCreated, CreatedDate, ModifiedBy, ModifiedDate, Version, Status, TemplateType, IsPartnerTemplate from Common.GenericTemplate where CompanyId=@UNIQUE_COMPANY_ID and Code='Cash Sale' and TemplateTypeId=(select id from Common.TemplateType where CompanyId=@UNIQUE_COMPANY_ID and ModuleMasterId=(select Id from Common.ModuleMaster where name='Bean Cursor') and Name='Cash Sale')
		--end

		-------------------------Cash Sale Email
		--if not exists(select Id from Common.GenericTemplate where name='Cash Sale Email' and Code='Cash Sale Email' and CompanyId=@NEW_COMPANY_ID and TemplateTypeId=(select id from Common.TemplateType where CompanyId=0 and ModuleMasterId=(select Id from Common.ModuleMaster where name='Bean Cursor') and Name='Cash Sale Email'))
		--begin
		--	insert into Common.GenericTemplate (Id, CompanyId, TemplateTypeId, Name, Code, TempletContent,IsSystem,IsFooterExist,IsHeaderExist, RecOrder, Remarks, UserCreated, CreatedDate, ModifiedBy, ModifiedDate, Version, Status, TemplateType, IsPartnerTemplate) 
		--	select NEWID(), @NEW_COMPANY_ID, (select Id from Common.TemplateType where Name='Cash Sale Email' and CompanyId=@UNIQUE_COMPANY_ID and ModuleMasterId=(select Id from Common.ModuleMaster where name='Bean Cursor')), Name, Code, TempletContent,IsSystem,IsFooterExist,IsHeaderExist, RecOrder, Remarks, UserCreated, CreatedDate, ModifiedBy, ModifiedDate, Version, Status, TemplateType, IsPartnerTemplate from Common.GenericTemplate where CompanyId=@UNIQUE_COMPANY_ID and Code='Cash Sale Email' and TemplateTypeId=(select id from Common.TemplateType where CompanyId=@UNIQUE_COMPANY_ID and ModuleMasterId=(select Id from Common.ModuleMaster where name='Bean Cursor') and Name='Cash Sale Email')
		--end

 End
GO
