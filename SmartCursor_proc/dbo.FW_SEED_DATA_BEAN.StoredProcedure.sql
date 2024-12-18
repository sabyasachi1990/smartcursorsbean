USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[FW_SEED_DATA_BEAN]    Script Date: 16-12-2024 9.20.10 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[FW_SEED_DATA_BEAN](@UNIQUE_COMPANY_ID bigint, @NEW_COMPANY_ID bigint, @UNIQUE_ID uniqueidentifier)
AS
BEGIN
--BEGIN TRANSACTION
DECLARE @IN_PROGRESS nvarchar(20) = 'In-Progress'
DECLARE @COMPLETED nvarchar(20) = 'Completed'
DECLARE @ACCOUNTYPE_ID_ID_TYPE_ID BIGINT
DECLARE @ID_TYPE_ACCOUNTYPE_ID_ID BIGINT	
DECLARE @CREATED_DATE DATETIME = GETUTCDATE()
DECLARE @ACCOUNTTYPE_ID BIGINT,@NEW_aCCOUNTTYPE_ID BIGINT
DECLARE @MODULE_NAME varchar(20) = 'Bean Cursor' 
DECLARE @MODULE_ID bigint =  (select Id from Common.ModuleMaster(Nolock) where Name = @MODULE_NAME)
BEGIN TRY
--================================================================
--ControlCodeCategory, ControlCode and ControlCodeCategoryModule  Insertion
DECLARE @ControlCode_Unique_Identifier uniqueidentifier = NEWID()
INSERT INTO Common.DetailLog values(@ControlCode_Unique_Identifier, @UNIQUE_Id , 'FW_SEED_DATA_BEAN - ControlCodes Execution Started', GETUTCDATE() , '3.1' , NULL , @IN_PROGRESS )

 EXEC [dbo].[FW_CONTROL_CODE_INSERTION] @UNIQUE_COMPANY_ID, @NEW_COMPANY_ID, @MODULE_NAME

	  Update Common.DetailLog set Status = @COMPLETED where Id = @ControlCode_Unique_Identifier

	 --===============================================================
	 --ModuleDetail Insertion
	 DECLARE @ModuleDetail_Unique_Identifier uniqueidentifier = NEWID()
	 INSERT INTO Common.DetailLog values(@ModuleDetail_Unique_Identifier, @UNIQUE_Id , 'FW_SEED_DATA_BEAN - ModuleDetail Execution Started', GETUTCDATE() , '3.2' , NULL , @IN_PROGRESS )

	 EXEC [dbo].[FW_MODULE_DETAIL_INSERTION] @UNIQUE_COMPANY_ID, @NEW_COMPANY_ID, @MODULE_ID

	   Update Common.DetailLog set Status = @COMPLETED where Id = @ModuleDetail_Unique_Identifier
	 --================================================================
	 --InitialCursor Setup Insertion
	  DECLARE @InitialCursorSetup_Unique_Identifier uniqueidentifier = NEWID()
	 INSERT INTO Common.DetailLog values(@InitialCursorSetup_Unique_Identifier, @UNIQUE_Id , 'FW_SEED_DATA_BEAN - InitialCursorSetup Execution Started', GETUTCDATE() , '3.3' , NULL , @IN_PROGRESS )

	 EXEC [dbo].[FW_INITIAL_CURSOR_SETUP_SEED] @UNIQUE_COMPANY_ID, @NEW_COMPANY_ID, @MODULE_ID

	 Update Common.DetailLog set Status = @COMPLETED where Id = @InitialCursorSetup_Unique_Identifier
	 --============ Auto number insertion===============================================================
	 DECLARE @autoNumber_Unique_Identifier uniqueidentifier = NEWID()
	 INSERT INTO Common.DetailLog values(@autoNumber_Unique_Identifier, @UNIQUE_Id , 'FW_SEED_DATA_BEAN - AutoNumber Execution Started', GETUTCDATE() , '3.4' , NULL , @IN_PROGRESS )

		EXEC [dbo].[FW_AUTO_NUMBER_SEED_DATA] @UNIQUE_COMPANY_ID, @NEW_COMPANY_ID, @MODULE_ID

		Update Common.DetailLog set Status = @COMPLETED where Id = @autoNumber_Unique_Identifier
	--======================= GridMetaData ===================================
	 DECLARE @gridmetadata_Unique_Identifier uniqueidentifier = NEWID()
	 INSERT INTO Common.DetailLog values(@gridmetadata_Unique_Identifier, @UNIQUE_Id , 'FW_SEED_DATA_BEAN - GridMetaData Execution Started', GETUTCDATE() , '3.5' , NULL , @IN_PROGRESS )

	EXEC [dbo].[FW_GRIDMETADATA_SEED_INSERTION] @UNIQUE_COMPANY_ID, @NEW_COMPANY_ID, @MODULE_ID

	Update Common.DetailLog set Status = @COMPLETED where Id = @gridmetadata_Unique_Identifier
	--=============================================================================
	 DECLARE @accountCursor_Unique_Identifier uniqueidentifier = NEWID()
	 INSERT INTO Common.DetailLog values(@accountCursor_Unique_Identifier, @UNIQUE_Id , 'FW_SEED_DATA_BEAN - AccountType and ChartOfAccount Execution Started', GETUTCDATE() , '3.6' , NULL , @IN_PROGRESS )

			DECLARE @AccountType_Cnt bigint
			select @AccountType_Cnt=count(*) from [Bean].[AccountType](Nolock) where CompanyId=@NEW_COMPANY_ID
			IF @AccountType_Cnt=0
			Begin
			DECLARE ACCOUNT_CURSOR CURSOR FOR 
			SELECT iD FROM [Bean].[AccountType](Nolock) WHERE COMPANYiD=0			
			OPEN ACCOUNT_CURSOR
			FETCH NEXT FROM ACCOUNT_CURSOR INTO @ACCOUNTTYPE_ID
			WHILE @@FETCH_STATUS=0
			BEGIN   
				SET @NEW_aCCOUNTTYPE_ID=(SELECT MAX(id) + 1 FROM [Bean].[AccountType](Nolock))
								
				INSERT INTO [Bean].[AccountType] (Id, CompanyId, Name, Class, Category, SubCategory, Nature, AppliesTo, IsSystem, ShowCurrency, RecOrder,
					Remarks, UserCreated, CreatedDate, ModifiedBy, ModifiedDate, Version, Status, ShowCashflowType, ShowAllowable, ShowRevaluation, Indexs, ModuleType,CashflowType,FRATId,StandardRecOrder)
				SELECT @NEW_aCCOUNTTYPE_ID, @NEW_COMPANY_ID, Name, Class, Category, SubCategory, Nature, AppliesTo, IsSystem, ShowCurrency, RecOrder, Remarks, UserCreated, 
				@CREATED_DATE, null, null, Version, status, ShowCashflowType, ShowAllowable, ShowRevaluation, Indexs, ModuleType,CashflowType ,NEWID(),StandardRecOrder
				FROM [Bean].[AccountType](Nolock)  WHERE COMPANYID=0 AND ID=@ACCOUNTTYPE_ID
				   	             
				INSERT INTO   [Bean].[ChartOfAccount] (Id, CompanyId, Code, Name, AccountTypeId, Class, Category, SubCategory, Nature, Currency, ShowRevaluation, CashflowType,
				AppliesTo, IsSystem, IsShowforCOA, RecOrder, Remarks, UserCreated, CreatedDate, ModifiedBy, ModifiedDate, Version, Status, IsSubLedger, IsCodeEditable,
				ShowCurrency, ShowCashFlow, ShowAllowable, IsRevaluation, Revaluation, DisAllowable, RealisedExchangeGainOrLoss, UnrealisedExchangeGainOrLoss, ModuleType,IsSeedData,IsDebt,IsLinkedAccount,IsRealCOA,FRCoaId,FRPATId)	
				SELECT ROW_NUMBER() OVER(ORDER BY ID) + (SELECT MAX(Id) FROM [Bean].[ChartOfAccount](Nolock)) AS Id, @NEW_COMPANY_ID,Code, Name, @NEW_aCCOUNTTYPE_ID, Class, Category, SubCategory,
				Nature, Currency, ShowRevaluation, CashflowType, AppliesTo, IsSystem, IsShowforCOA, RecOrder, Remarks,
				UserCreated, @CREATED_DATE, null, null, Version, status, IsSubLedger, IsCodeEditable, ShowCurrency, ShowCashFlow, ShowAllowable, IsRevaluation, Revaluation, 
				DisAllowable, RealisedExchangeGainOrLoss, UnrealisedExchangeGainOrLoss, ModuleType,IsSeedData,IsDebt,IsLinkedAccount,IsRealCOA,NEWID(), (select FRATId from Bean.AccountType(Nolock) Where Id=@NEW_aCCOUNTTYPE_ID)  FROM [Bean].[ChartOfAccount](Nolock) WHERE COMPANYID=0 AND Status!=3 
				--AND Name!='Inventory revaluation' 
				AND Name Not In('Reimbursement (Clearing)','Claims Clearing - Personal','Clearing - Transfers','Clearing - Payments'/*,'Clearing - Receipts'*/,'Exchange gain/loss - Realised','Exchange gain/loss - Unrealised','Inventory revaluation'/*, 'Tax payable (GST)'*/)
				AND AccountTypeId = @ACCOUNTTYPE_ID
				FETCH NEXT FROM ACCOUNT_CURSOR INTO @ACCOUNTTYPE_ID
			END	
			CLOSE ACCOUNT_CURSOR
			Deallocate ACCOUNT_CURSOR	
			End

			Update Common.DetailLog set Status = @COMPLETED where Id = @accountCursor_Unique_Identifier
			-------Insert data for Intercompany transaction-----------

			--Declare  @companyId bigint=420;
			--IF((Select CF.Status from Common.Feature F
			--	JOIN Common.CompanyFeatures CF on F.Id=CF.FeatureId
			--	where CF.Companyid=@NEW_COMPANY_ID and F.Name='Inter-Company' and F.ModuleId is null)=1)
			--BEGIN
			----	Declare @COACOUNT bigint =(Select Max(Id) from Bean.ChartOfAccount)
			--	Insert into Bean.ChartOfAccount (Id,CompanyId,Code,Name,AccountTypeId,SubCategory,Category,Class,Nature,CashflowType,IsSeedData,CreatedDate,UserCreated,ModuleType,Status,IsRealCOA,SubsidaryCompanyId,IsLinkedAccount,Issystem,FRCoaId,FRPATId)
			--	Select (ROW_NUMBER() OVER(ORDER BY ID) + (SELECT MAX(id) + 1 FROM [Bean].[ChartOfAccount])) as Id,c.ParentId as CompanyId,CONCAT('BS15000',ROW_NUMBER()OVER(order by Id)) as Code,CONCAT('I/C - ',C.ShortName) as Name,(Select Id from Bean.AccountType where CompanyId=@NEW_COMPANY_ID and Name='Intercompany clearing') As AccountTypeId,'Current' as SubCategory,'Balance Sheet' AS Category,'Assets' as Class,'Debit' as Nature,'Operating' as CashflowType,0 as IsSeedData,GETUTCDATE() As CreatedDate,'madhu@kgtan.com' as UserCreated,'Bean' As ModuleType,1 as Status,1 as IsRealCOA,C.Id as SubsidaryCompanyId,1 as IsLinkedAccount,0 as IsSystem,NEWID() as FRCoaId,(select FRATId from Bean.AccountType Where Name='Intercompany clearing' and CompanyId=@NEW_COMPANY_ID ) as FRPATId  from Common.Company C where Id NOT IN
			--	  (
			--	  Select distinct C.Id from Bean.ChartOfAccount COA
			--	  JOIN Common.Company C on C.ParentId=COA.CompanyId
			--	  --JOIN Bean.AccountType ACT On ACT.Id=COA.AccountTypeId
			--	   where COA.CompanyId=@NEW_COMPANY_ID and COA.Name  LIKE '%I/C - %'
			--	   ) AND ParentId=@NEW_COMPANY_ID
			--END

			---If bean is activated later of any other cursor activation
			IF Exists( select Id from Common.Bank where CompanyId=@NEW_COMPANY_ID and COAId is null)
			BEGIN
		
			Insert into Bean.ChartOfAccount (Id,CompanyId,Code,Name,AccountTypeId,SubCategory,Category,Class,Nature,CashflowType,IsSeedData,CreatedDate,UserCreated,ModuleType,Status,IsRealCOA,SubsidaryCompanyId,IsLinkedAccount,Issystem,FRCoaId,FRPATId,Currency,ISBank,ShowRevaluation)
			Select (ROW_NUMBER() OVER(ORDER BY C.ID) + (SELECT MAX(Coa.Id) + 1 FROM [Bean].[ChartOfAccount] Coa)) as CId,c.ParentId as CompanyId,CONCAT('BS01000',ROW_NUMBER()OVER(order by C.Id)) as Code,bnk.COAName as Name,(Select Id from Bean.AccountType where CompanyId=@NEW_COMPANY_ID and Name='Cash and bank balances') As AccountTypeId,'Current' as SubCategory,'Balance Sheet' AS Category,'Assets' as Class,'Debit' as Nature,'Cash and cash equivalent' as CashflowType,0 as IsSeedData,GETUTCDATE() As CreatedDate,'System' as UserCreated,'Bean' As ModuleType,1 as Status,1 as IsRealCOA,C.Id as SubsidaryCompanyId,1 as IsLinkedAccount,0 as IsSystem,NEWID() as FRCoaId,(select FRATId from Bean.AccountType Where Name='Cash and bank balances' and CompanyId=@NEW_COMPANY_ID ) as FRPATId, bnk.Currency as Currency,1,1 from  Common.Company C 
				  JOIN Common.Bank BNK On BNK.SubcidaryCompanyId=C.Id
				   where BNK.CompanyId=@NEW_COMPANY_ID and  BNK.COAId is null and c.ParentId=@NEW_COMPANY_ID
		
			Update bnk Set bnk.COAId=coa.id from Common.Bank bnk Join
			Bean.ChartOfAccount COA on 	bnk.SubcidaryCompanyId=COA.SubsidaryCompanyId and COA.IsBank=1
			where bnk.COAName=coa.Name and bnk.COAId is null and bnk.CompanyId=@NEW_COMPANY_ID
			
			Update Coa Set COA.Name=bnk.COAName from Common.Bank bnk Join
			Bean.ChartOfAccount COA on 	bnk.SubcidaryCompanyId=COA.SubsidaryCompanyId and bnk.coaid=coa.id and COA.IsBank=1
			where  bnk.CompanyId=@NEW_COMPANY_ID  and bnk.COAName<>COA.Name

		END
		Else
		Begin
			Update Coa Set COA.Name=bnk.COAName from Common.Bank bnk Join
			Bean.ChartOfAccount COA on 	bnk.SubcidaryCompanyId=COA.SubsidaryCompanyId and bnk.coaid=coa.id and COA.IsBank=1
			where  bnk.CompanyId=@NEW_COMPANY_ID  and bnk.COAName<>COA.Name
		End


		Declare @id1 uniqueidentifier=newid();
if not exists(select * from Bean.Category(Nolock) where Name='Assets' and CompanyId=@NEW_COMPANY_ID)
Begin
INSERT INTO [Bean].[Category]([Id],[CompanyId],[Name],[Type],[Recorder],[IsIncomeStatement],[LeadsheetId],[ColorCode],[AccountClass],[IsCollapse])
     VALUES  (@id1,@NEW_COMPANY_ID,'Assets','LeadSheet',1,Null,null,'clr1',null ,1)
End


if not exists(select * from Bean.[SubCategory](Nolock) where Name='Current Assets' and CompanyId=@NEW_COMPANY_ID)
Begin	 
INSERT INTO [Bean].[SubCategory]  ([Id],[Name],[CategoryId],[Recorder],[Type],[CompanyId],[TypeId],[SubCategoryOrder],[ParentId],[IsIncomeStatement],[ColorCode], [AccountClass],[IsCollapse])
     VALUES (NEWID(),'Current Assets','00000000-0000-0000-0000-000000000000',1,'LeadSheet',@NEW_COMPANY_ID,'91021766-F6F8-49FE-A230-66295B4BC3FB'
           ,null ,@id1,null,null,null,1)
End


if not exists(select * from Bean.[SubCategory](Nolock) where Name='Non-current Assets' and CompanyId=@NEW_COMPANY_ID)	
Begin
INSERT INTO [Bean].[SubCategory]  ([Id],[Name],[CategoryId],[Recorder],[Type],[CompanyId],[TypeId],[SubCategoryOrder],[ParentId],[IsIncomeStatement],[ColorCode], [AccountClass],[IsCollapse])
     VALUES (NEWID(),'Non-current Assets','00000000-0000-0000-0000-000000000000',2,'LeadSheet',@NEW_COMPANY_ID,'81021766-F6F8-49FE-A230-66295B4BC3FB'
           ,null ,@id1,null,null,null,1)
End


Declare @id2 uniqueidentifier=newid();
Begin
if not exists(select * from Bean.Category(Nolock) where Name='Liabilities' and CompanyId=@NEW_COMPANY_ID)	
INSERT INTO [Bean].[Category]([Id],[CompanyId],[Name],[Type],[Recorder],[IsIncomeStatement],[LeadsheetId],[ColorCode],[AccountClass],[IsCollapse])
     VALUES  (@id2,@NEW_COMPANY_ID,'Liabilities','LeadSheet',1,Null,null,'clr2',null ,1)
End


if not exists(select * from Bean.[SubCategory](Nolock) where Name='Current Liabilities' and CompanyId=@NEW_COMPANY_ID)	
Begin
INSERT INTO [Bean].[SubCategory]  ([Id],[Name],[CategoryId],[Recorder],[Type],[CompanyId],[TypeId],[SubCategoryOrder],[ParentId],[IsIncomeStatement],
[ColorCode],[AccountClass],[IsCollapse])
     VALUES (NEWID(),'Current Liabilities','00000000-0000-0000-0000-000000000000',1,'LeadSheet',@NEW_COMPANY_ID,'71021766-F6F8-49FE-A230-66295B4BC3FB'
           ,null ,@id2,null,null,null,1)
End


if not exists(select * from Bean.[SubCategory](Nolock) where Name='Non-current Liabilities' and CompanyId=@NEW_COMPANY_ID)	
Begin
INSERT INTO [Bean].[SubCategory] ([Id],[Name],[CategoryId],[Recorder],[Type],[CompanyId],[TypeId],[SubCategoryOrder],[ParentId],[IsIncomeStatement],[ColorCode], [AccountClass],[IsCollapse])
     VALUES (NEWID(),'Non-current Liabilities','00000000-0000-0000-0000-000000000000',2,'LeadSheet',@NEW_COMPANY_ID,'61021766-F6F8-49FE-A230-66295B4BC3FB',null ,@id2,null,null,null,1)
End


Declare @id3 uniqueidentifier=newid();
if not exists(select Id from Bean.Category(Nolock) where Name='Equity and Liabilities' and CompanyId=@NEW_COMPANY_ID)	
Begin
INSERT INTO [Bean].[Category]([Id],[CompanyId],[Name],[Type],[Recorder],[IsIncomeStatement],[LeadsheetId],[ColorCode],[AccountClass],[IsCollapse])
     VALUES  (@id3,@NEW_COMPANY_ID,'Equity and Liabilities','SubTotal',2,Null,null,'clr5',null ,1)
End


if not exists(select * from Bean.[SubCategory](Nolock) where Name='Equity' and CompanyId=@NEW_COMPANY_ID)	
Begin
INSERT INTO [Bean].[SubCategory]  ([Id],[Name],[CategoryId],[Recorder],[Type],[CompanyId],[TypeId],[SubCategoryOrder],[ParentId],[IsIncomeStatement],
[ColorCode],[AccountClass],[IsCollapse])
     VALUES (NEWID(),'Equity','00000000-0000-0000-0000-000000000000',1,'LeadSheet',@NEW_COMPANY_ID,'41021766-F6F8-49FE-A230-66295B4BC3FB'
           ,null ,@id3,null,null,null,1)
End



if not exists(select * from Bean.[SubCategory](Nolock) where Name='Liabilities' and CompanyId=@NEW_COMPANY_ID)	
Begin
INSERT INTO [Bean].[SubCategory]  ([Id],[Name],[CategoryId],[Recorder],[Type],[CompanyId],[TypeId],[SubCategoryOrder],[ParentId],[IsIncomeStatement],
[ColorCode],[AccountClass],[IsCollapse])
     VALUES (NEWID(),'Liabilities','00000000-0000-0000-0000-000000000000',2,'SubTotal',@NEW_COMPANY_ID,(select Id  from Bean.Category(Nolock) where Name='Liabilities' and CompanyId=@NEW_COMPANY_ID),null ,@id3,null,null,null,1)
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
			Select @Entity_Cnt=Count(*)
            from [Bean].[Entity](Nolock) where companyid=@NEW_COMPANY_ID	
	        IF @Entity_Cnt=0
	Begin		
            INSERT INTO [Bean].[Entity]([Id],[CompanyId],[Name],[TypeId],[IdTypeId],[IdNo],[GSTRegNo],[IsCustomer],[CustTOPId],[CustTOP],[CustTOPValue],[CustCreditLimit],[CustCurrency],[CustNature],[IsVendor],[VenTOPId],[VenTOP],[VenTOPValue],[VenCurrency],[VenNature],[AddressBookId],[IsLocal],[ResBlockHouseNo],[ResStreet],[ResUnitNo],[ResBuildingEstate],[ResCity],[ResPostalCode],[ResState],[ResCountry],[RecOrder],[Remarks],[UserCreated],[CreatedDate],[ModifiedBy],[ModifiedDate],[Version],[Status],[VenCreditLimit],[Communication],[VendorType],[IsShowPayroll]) SELECT(NEWID()),@NEW_COMPANY_ID,[Name],[TypeId],[IdTypeId],[IdNo],[GSTRegNo],[IsCustomer],[CustTOPId],[CustTOP],[CustTOPValue],[CustCreditLimit],[CustCurrency],[CustNature],[IsVendor],[VenTOPId],[VenTOP],[VenTOPValue],[VenCurrency],[VenNature],[AddressBookId],[IsLocal],[ResBlockHouseNo],[ResStreet],[ResUnitNo],[ResBuildingEstate],[ResCity],[ResPostalCode],[ResState],[ResCountry],[RecOrder],[Remarks],[UserCreated],[CreatedDate],null,null,[Version],[Status],[VenCreditLimit],[Communication],[VendorType],[IsShowPayroll] from Bean.Entity(Nolock) where COMPANYID=@UNIQUE_COMPANY_ID;
    end


	Declare @CompanyFeatures_Cnt BIGINT
	select 	@CompanyFeatures_Cnt=Count(*) from [Common].[Feature] a join [Common].[CompanyFeatures] b on a.Id=b.FeatureId where 
	--a.VisibleStyle <> 'SuperUser-CheckBox' and a.VisibleStyle <> 'HRCursor-CheckBox' 
	a.VisibleStyle ='Functionality' and a.ModuleId=(Select Id from Common.ModuleMaster where Name='Bean Cursor') and CompanyId=@NEW_COMPANY_ID

	IF @CompanyFeatures_Cnt=0
	Begin
		INSERT INTO common.CompanyFeatures(Id,CompanyId,FeatureId,Status,Remarks,IsChecked,CreatedDate,UserCreated)
		select  NEWID(),@NEW_COMPANY_ID,b.FeatureId,b.Status,b.Remarks,b.IsChecked,GETDATE(),'System' from [Common].[Feature] a join [Common].			[CompanyFeatures] b on a.Id=b.FeatureId where
		 --a.VisibleStyle <> 'SuperUser-CheckBox' and a.VisibleStyle <> 'HRCursor-CheckBox' 
		 a.VisibleStyle ='Functionality'and a.ModuleId=(Select Id from Common.ModuleMaster where Name='Bean Cursor') and CompanyId=@UNIQUE_COMPANY_ID
	End

	 If (((select status from common.companymodule(Nolock) where companyid=@NEW_COMPANY_ID and moduleid=(select Id from common.ModuleMaster(Nolock) where Name='Workflow Cursor' and companyId=0)) = 1) and ((select status from common.companymodule(Nolock) where companyid=@NEW_COMPANY_ID and moduleid=(select Id from common.ModuleMaster(Nolock) where Name='Bean Cursor' and companyId=0)) = 1)) 
	Begin
	   EXEC [dbo].[SP_WF_2_Bean]  @NEW_COMPANY_ID
    END
    If (((select status from common.companymodule(Nolock) where companyid=@NEW_COMPANY_ID and moduleid=(select Id from common.ModuleMaster(Nolock) where Name='Hr Cursor' and companyId=0)) = 1) and ((select status from common.companymodule(Nolock) where companyid=@NEW_COMPANY_ID and moduleid=(select Id from common.ModuleMaster(Nolock) where Name='Bean Cursor' and companyId=0)) = 1)) 
	Begin
	   EXEC [dbo].[SP_HR_2_Bean]  @NEW_COMPANY_ID
	   	---HR Cursor paycomponent coa Seed Data-----------//new changes on 07-12-2019
		--Begin Try
			If Exists(Select Id from HR.PayComponent(Nolock) where CompanyId=@NEW_COMPANY_ID and COAId is null)
			Begin
				Update pay set pay.COAId=coa.Id 
				from hr.PayComponent pay
				left join Bean.ChartOfAccount coa on coa.Name=pay.DefaultCOA and coa.CompanyId=@NEW_COMPANY_ID
				where pay.CompanyId=@NEW_COMPANY_ID and pay.COAId is null
			End
		--End Try
		--Begin Catch
		--End Catch
    END
	--==============================================================================================================
	--Template Seed data Insertion

	if Not Exists(Select Id from common.generictemplate where companyid = @NEW_COMPANY_ID and Cursorname = 'Bean Cursor')
		Begin
			insert into Common.GenericTemplate
		Select NEWID		(),@NEW_COMPANY_ID,CT.Id,GT.Name,GT.Code,GT.TempletContent,GT.IsSystem,GT.IsFooterExist,GT.IsHeaderExist,GT.RecOrder,GT.Remarks,GT.UserCreated,GT.CreatedDate,GT.ModifiedBy,GT.ModifiedDate,GT.Version,GT.Status,GT.Category,GT.Conditions,GT.IsUsed,GT.FromEmailId,GT.ToEmailId,GT.CCEmailIds,GT.BCCEmailIds,GT.TemplateType,GT.Subject,GT.IsPartnerTemplate,GT.IsDefultTemplate,GT.Isthisemailtemplate,GT.IsLandscape,GT.CursorName,GT.ServiceCompanyIds,GT.ServiceCompanyNames,GT.IsEnableServiceEntities,GT.ISAllowDuplicates,GT.Jurisdiction from Common.GenericTemplate GT Join Common.TemplateType CT on GT.TemplateTypeId=CT.Id and GT.CompanyId=0 where CT.CompanyId=0 and CT.ModuleMasterId=4 and GT.Status = 1
		End
	--===================================================================================================================

	if exists(select cf.[status] from common.feature f join common.companyfeatures cf on f.id = cf.featureId where f.name = 'Multi-Currency' and cf.status = 1 and cf.companyid = @NEW_COMPANY_ID)
	Begin
		exec [dbo].[Bean_MultiCurrency_COA_Add] @NEW_COMPANY_ID
	End


	--COMMIT TRANSACTION
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
