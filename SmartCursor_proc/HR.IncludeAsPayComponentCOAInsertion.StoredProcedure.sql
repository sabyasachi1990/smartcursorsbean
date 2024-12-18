USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [HR].[IncludeAsPayComponentCOAInsertion]    Script Date: 16-12-2024 9.20.11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE procedure [HR].[IncludeAsPayComponentCOAInsertion](@companyId bigint)
As
BEGIN
	IF exists(select * from Common.HRSettings where CompanyId=@companyId and Includepaycomponent = 1)
	BEGIN
		if not exists(select * from Bean.ChartOfAccount where Name='Reimbursement (Clearing)' and CompanyId=@companyId)
		BEGIN
			insert into bean.ChartOfAccount ( Id,CompanyId,Code,Name,AccountTypeId,SubCategory,Category,Class,Nature,Currency,ShowRevaluation,CashflowType,AppliesTo,IsSystem,IsShowforCOA,RecOrder,Remarks,UserCreated,CreatedDate,ModifiedBy,ModifiedDate,Version,Status,IsSubLedger,IsCodeEditable,ShowCurrency,ShowCashFlow,ShowAllowable,IsRevaluation,Revaluation,DisAllowable,RealisedExchangeGainOrLoss,UnrealisedExchangeGainOrLoss,ModuleType,IsSeedData,SubsidaryCompanyId,IsBank,IsDebt,IsAllowableNotAllowableActivated,IsLinkedAccount,IsRealCOA,FRCoaId,FRPATId,FRRecOrder,CategoryId,SubCategoryId,TaxType,XeroCode,XeroName,XeroClass,XeroAccountTypeId,XeroAccountId,IsFromXero)

			select (SELECT MAX(Id) FROM Bean.ChartOfAccount)+ROW_NUMBER() OVER(ORDER BY ID)  AS Id,@companyId,Code,Name,(Select Id from Bean.AccountType where Name='Other current liabilities' and CompanyId=@companyId) as AccountTypeId,SubCategory,Category,Class,Nature,Currency,ShowRevaluation,CashflowType,AppliesTo,IsSystem,IsShowforCOA,RecOrder,Remarks,UserCreated,CreatedDate,ModifiedBy,ModifiedDate,Version,Status,IsSubLedger,IsCodeEditable,ShowCurrency,ShowCashFlow,ShowAllowable,IsRevaluation,Revaluation,DisAllowable,RealisedExchangeGainOrLoss,UnrealisedExchangeGainOrLoss,ModuleType,IsSeedData,SubsidaryCompanyId,IsBank,IsDebt,IsAllowableNotAllowableActivated,1,IsRealCOA,FRCoaId,FRPATId,FRRecOrder,CategoryId,SubCategoryId,TaxType,XeroCode,XeroName,XeroClass,XeroAccountTypeId,XeroAccountId,IsFromXero
				from Bean.ChartOfAccount where Name in ('Reimbursement (Clearing)') and CompanyId=0 --and name not in (select Name from Bean.ChartOfAccount where Name in ('Reimbursement (Clearing)') and CompanyId=@NEW_COMPANY_ID)
		END
		ELSE
		BEGIN
			update Bean.ChartOfAccount set IsLinkedAccount=1 where Name in ('Reimbursement (Clearing)') and CompanyId=@companyId
		END
	END
END


GO
