USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[Bean_MultiCurrency_COA_Add]    Script Date: 16-12-2024 9.20.10 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
Create     proc [dbo].[Bean_MultiCurrency_COA_Add]
@companyId int --New CompanyId
as
Begin
--AccountType Names
Declare @System varchar(20) = 'System'
Declare @ExchangeGainloss varchar(20)='Exchange gain/loss'
--COA Names
Declare @ClearingReceipts varchar(20) = 'Clearing - Receipts'
Declare @ClearingTransfers varchar(20) = 'Clearing - Transfers'
Declare @ClearingPayments varchar(20) = 'Clearing - Payments'
Declare @ExchangeGainlossRealised varchar(40) ='Exchange gain/loss - Realised'
Declare @ExchangeGainlossUnrealised varchar(40) ='Exchange gain/loss - Unrealised'
--Local Variable
Declare @id int
Declare @AccountId int
Declare @ErrorMessage Nvarchar(4000)
Declare @FratId uniqueidentifier

	Begin Try
	Begin Transaction
		--AccountTypeId,FRATId Basis of new company id and account name
		Select @AccountId=Id,@FratId = FratId from Bean.AccountType(NoLock) where CompanyId = @companyId and Name =@System
		 
		--COA Name as Clearing- Receipts
		if not exists(select Id from Bean.ChartOfAccount(NoLock) Where CompanyId = @companyId and Name = @ClearingReceipts)
		Begin

			Set @id = (Select max (id)+1 from Bean.ChartOfAccount(NoLock)) 
			--Inserting COA Clearing - Receipts for new company
			Insert into Bean.ChartOfAccount
				select @id,@companyId,code,Name,@AccountId,SubCategory,Category,class,Nature,Currency,ShowRevaluation,
					CashflowType,AppliesTo,IsSystem,IsShowforCOA,RecOrder,Remarks,UserCreated,GETUTCDATE(),ModifiedBy,Modifieddate,
					Version,Status,IsSubLedger,IsCodeEditable,ShowCurrency,ShowCashFlow,ShowAllowable,IsRevaluation,Revaluation,
					DisAllowable,RealisedExchangeGainOrLoss,UnrealisedExchangeGainOrLoss,ModuleType,IsSeedData,SubsidaryCompanyId,
					IsBank,IsDebt,IsAllowableNotAllowableActivated,IsLinkedAccount,IsRealCOA,NEWID(),@FratId,FRRecOrder,
					CategoryId,SubCategoryId,TaxType,XeroCode,XeroName,XeroClass,XeroAccountTypeId,XeroAccountId,IsFromXero
				from Bean.ChartOfAccount (NoLock) where companyid =0 and name = @ClearingReceipts
		End
		--COA Name As Clearing Transfers
		if not exists(select Id from Bean.ChartOfAccount(NoLock) Where CompanyId = @companyId and Name = @ClearingTransfers)
		Begin
			Set @id = (Select max (id)+1 from Bean.ChartOfAccount(NoLock))
			--Inserting COA Clearing - Transfers for new company
			Insert into Bean.ChartOfAccount 
				select @id,@companyId,code,Name,@AccountId,SubCategory,Category,class,Nature,Currency,ShowRevaluation,
				CashflowType,AppliesTo,IsSystem,IsShowforCOA,RecOrder,Remarks,UserCreated,GETUTCDATE(),ModifiedBy,Modifieddate,
				Version,Status,IsSubLedger,IsCodeEditable,ShowCurrency,ShowCashFlow,ShowAllowable,IsRevaluation,Revaluation,
				DisAllowable,RealisedExchangeGainOrLoss,UnrealisedExchangeGainOrLoss,ModuleType,IsSeedData,SubsidaryCompanyId,
				IsBank,IsDebt,IsAllowableNotAllowableActivated,IsLinkedAccount,IsRealCOA,NEWID(),@FratId,FRRecOrder,
				CategoryId,SubCategoryId,TaxType,XeroCode,XeroName,XeroClass,XeroAccountTypeId,XeroAccountId,IsFromXero
				from Bean.ChartOfAccount (NoLock) where companyid =0 and name = @ClearingTransfers
		End

		--COA Name As Clearing-Payments
		if not exists(select Id from Bean.ChartOfAccount(NoLock) Where CompanyId = @companyId and Name = @ClearingPayments)
		Begin
			Set @id = (Select max (id)+1 from Bean.ChartOfAccount(NoLock))
			--Inserting COA Clearing - Payments for new company
			Insert into Bean.ChartOfAccount 
				select @id,@companyId,code,Name,@AccountId,SubCategory,Category,class,Nature,Currency,ShowRevaluation,
				CashflowType,AppliesTo,IsSystem,IsShowforCOA,RecOrder,Remarks,UserCreated,GETUTCDATE(),ModifiedBy,Modifieddate,
				Version,Status,IsSubLedger,IsCodeEditable,ShowCurrency,ShowCashFlow,ShowAllowable,IsRevaluation,Revaluation,
				DisAllowable,RealisedExchangeGainOrLoss,UnrealisedExchangeGainOrLoss,ModuleType,IsSeedData,SubsidaryCompanyId,
				IsBank,IsDebt,IsAllowableNotAllowableActivated,IsLinkedAccount,IsRealCOA,NEWID(),@FratId,FRRecOrder,
				CategoryId,SubCategoryId,TaxType,XeroCode,XeroName,XeroClass,XeroAccountTypeId,XeroAccountId,IsFromXero
				from Bean.ChartOfAccount (NoLock) where companyid =0 and name = @ClearingPayments
		End
		--AccountTypeId,FRATId On the basis of companyId and account name
		Select @AccountId=Id,@FratId = FratId from bean.accounttype Where CompanyId = @companyId and name = @ExchangeGainloss
		--COA Name As Exchange gain/loss - Realised
		if not exists(Select Id from Bean.ChartOfAccount(NoLock) Where CompanyId = @companyId and Name = @ExchangeGainlossRealised)
		Begin
			Set @id = (Select max(Id)+1 from Bean.ChartOfAccount(NoLock))
			--Inserting COA Exchange gain/loss - Realised for new company
			Insert into Bean.ChartOfAccount
				select @id,@companyId,code,Name,@AccountId,SubCategory,Category,class,Nature,Currency,ShowRevaluation,
				CashflowType,AppliesTo,IsSystem,IsShowforCOA,RecOrder,Remarks,UserCreated,GETUTCDATE(),ModifiedBy,Modifieddate,
				Version,Status,IsSubLedger,IsCodeEditable,ShowCurrency,ShowCashFlow,ShowAllowable,IsRevaluation,Revaluation,
				DisAllowable,RealisedExchangeGainOrLoss,UnrealisedExchangeGainOrLoss,ModuleType,IsSeedData,SubsidaryCompanyId,
				IsBank,IsDebt,IsAllowableNotAllowableActivated,IsLinkedAccount,IsRealCOA,NEWID(),@FratId,FRRecOrder,
				CategoryId,SubCategoryId,TaxType,XeroCode,XeroName,XeroClass,XeroAccountTypeId,XeroAccountId,IsFromXero
				from Bean.ChartOfAccount (NoLock) where companyid =0 and name = @ExchangeGainlossRealised
		End
		--COA Name As Exchange gain/loss - Unrealised
		if not exists(Select Id from Bean.ChartOfAccount(NoLock) Where CompanyId = @companyId and Name = @ExchangeGainlossUnrealised)
		Begin
				Set @id = (Select max(Id)+1 from Bean.ChartOfAccount(NoLock))
				--Inserting COA Exchange gain/loss - Unrealised for new company
			Insert into Bean.ChartOfAccount
				select @id,@companyId,code,Name,@AccountId,SubCategory,Category,class,Nature,Currency,ShowRevaluation,
				CashflowType,AppliesTo,IsSystem,IsShowforCOA,RecOrder,Remarks,UserCreated,GETUTCDATE(),ModifiedBy,Modifieddate,
				Version,Status,IsSubLedger,IsCodeEditable,ShowCurrency,ShowCashFlow,ShowAllowable,IsRevaluation,Revaluation,
				DisAllowable,RealisedExchangeGainOrLoss,UnrealisedExchangeGainOrLoss,ModuleType,IsSeedData,SubsidaryCompanyId,
				IsBank,IsDebt,IsAllowableNotAllowableActivated,IsLinkedAccount,IsRealCOA,NEWID(),@FratId,FRRecOrder,
				CategoryId,SubCategoryId,TaxType,XeroCode,XeroName,XeroClass,XeroAccountTypeId,XeroAccountId,IsFromXero
				from Bean.ChartOfAccount (NoLock) where companyid =0 and name = @ExchangeGainlossUnrealised

		End
		Commit Transaction
	End Try
	Begin Catch
		RollBack
		Select @ErrorMessage=ERROR_MESSAGE()
			RAISERROR(@ErrorMessage,16,1);
	End Catch
end
GO
