USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[Insert_COA_When_XERO_Activated]    Script Date: 16-12-2024 9.20.10 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [dbo].[Insert_COA_When_XERO_Activated](@companyId bigint)
AS
BEGIN
	DECLARE @ACCOUNTTYPE_ID BIGINT,@NEW_aCCOUNTTYPE_ID BIGINT
	DECLARE @CREATED_DATE DATETIME = GETUTCDATE()
	DECLARE @HR_ModuleId BIGINT = (select Id from Common.ModuleMaster where Name='HR Cursor')
	
	If Exists(select CF.* from common.CompanyFeatures CF
	join common.feature F on F.Id = CF.FeatureId
	where F.Name='Xero' and CF.CompanyId=@companyId and CF.Status=1 and CF.IsChecked=1)
	BEGIN
		IF not exists(select * from bean.ChartOfAccount where CompanyId=@companyId)
		BEGIN
			DECLARE @AccountType_Cnt bigint
			select @AccountType_Cnt=count(*) from [Bean].[AccountType](Nolock) where CompanyId=@companyId
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
					SELECT @NEW_aCCOUNTTYPE_ID, @companyId, Name, Class, Category, SubCategory, Nature, AppliesTo, IsSystem, ShowCurrency, RecOrder, Remarks, UserCreated, 
					@CREATED_DATE, null, null, Version, status, ShowCashflowType, ShowAllowable, ShowRevaluation, Indexs, ModuleType,CashflowType ,NEWID(),StandardRecOrder
					FROM [Bean].[AccountType](Nolock)  WHERE COMPANYID=0 AND ID=@ACCOUNTTYPE_ID
				   	             
					INSERT INTO   [Bean].[ChartOfAccount] (Id, CompanyId, Code, Name, AccountTypeId, Class, Category, SubCategory, Nature, Currency, ShowRevaluation, CashflowType,
					AppliesTo, IsSystem, IsShowforCOA, RecOrder, Remarks, UserCreated, CreatedDate, ModifiedBy, ModifiedDate, Version, Status, IsSubLedger, IsCodeEditable,
					ShowCurrency, ShowCashFlow, ShowAllowable, IsRevaluation, Revaluation, DisAllowable, RealisedExchangeGainOrLoss, UnrealisedExchangeGainOrLoss, ModuleType,IsSeedData,IsDebt,IsLinkedAccount,IsRealCOA,FRCoaId,FRPATId)	
					SELECT ROW_NUMBER() OVER(ORDER BY ID) + (SELECT MAX(Id) FROM [Bean].[ChartOfAccount](Nolock)) AS Id, @companyId,Code, Name, @NEW_aCCOUNTTYPE_ID, Class, Category, SubCategory,
					Nature, Currency, ShowRevaluation, CashflowType, AppliesTo, IsSystem, IsShowforCOA, RecOrder, Remarks,
					UserCreated, @CREATED_DATE, null, null, Version, status, IsSubLedger, IsCodeEditable, ShowCurrency, ShowCashFlow, ShowAllowable, IsRevaluation, Revaluation, 
					DisAllowable, RealisedExchangeGainOrLoss, UnrealisedExchangeGainOrLoss, ModuleType,IsSeedData,IsDebt,IsLinkedAccount,IsRealCOA,NEWID(), (select FRATId from Bean.AccountType(Nolock) Where Id=@NEW_aCCOUNTTYPE_ID)  FROM [Bean].[ChartOfAccount](Nolock) WHERE COMPANYID=0 AND Status!=3 
					--AND Name!='Inventory revaluation' 
					--AND Name Not In('Reimbursement (Clearing)','Claims Clearing - Personal','Clearing - Transfers','Clearing - Payments'/*,'Clearing - Receipts'*/,'Exchange gain/loss - Realised','Exchange gain/loss - Unrealised','Inventory revaluation'/*, 'Tax payable (GST)'*/)
					AND AccountTypeId = @ACCOUNTTYPE_ID
					FETCH NEXT FROM ACCOUNT_CURSOR INTO @ACCOUNTTYPE_ID
			    END	
				CLOSE ACCOUNT_CURSOR
				Deallocate ACCOUNT_CURSOR	
			End
		END
	END

	If Exists(select CF.* from common.CompanyFeatures CF
	join common.feature F on F.Id = CF.FeatureId
	where F.Name='Payroll' and F.ModuleId= @HR_ModuleId and CF.CompanyId=@companyId and CF.Status=1)
	BEGIN
		update hr.PayComponent set COAId= (select Id from Bean.ChartOfAccount where Name=DefaultCOA and CompanyId=@companyId) where CompanyId=@companyId and DefaultCOA is not null
	END
END
GO
