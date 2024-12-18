USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[Xero_BC_COA_TaxCodes_Mapping]    Script Date: 16-12-2024 9.20.11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--exec Xero_BC_COA_TaxCodes_Mapping 2407, 2460, 'F05AD078-B115-4D3A-BEEE-F9B4615850CC'

CREATE procedure [dbo].[Xero_BC_COA_TaxCodes_Mapping](@parentComopanyId bigint, @subCompanyId bigint, @organisationId uniqueidentifier)
AS
BEGIN

    --========================= Account Types =====================

	If NOT EXISTS (select * from Common.XeroAccountTypeDetail where BeanAccountTypeId = (select top 1 Id from Bean.AccountType where CompanyId=@parentComopanyId and name='Cash and bank balances') AND XeroAccountTypeId = (select Id from Common.XeroAccountType where XeroAccTypeName='Bank' and XeroAccTypeId=1 and CompanyId=@subCompanyId and OrganisationId = @organisationId))
	BEGIN
	insert into Common.XeroAccountTypeDetail(Id, XeroAccountTypeId, BeanAccountTypeId) values (NEWID(), (select Id from Common.XeroAccountType where XeroAccTypeName='Bank' and XeroAccTypeId=1 and CompanyId=@subCompanyId and OrganisationId = @organisationId), (select top 1 Id from Bean.AccountType where CompanyId=@parentComopanyId and name='Bank'))
	END

	If NOT EXISTS (select * from Common.XeroAccountTypeDetail where XeroAccountTypeId =  (select Id from Common.XeroAccountType where XeroAccTypeName='Current' and XeroAccTypeId=2 and CompanyId=@subCompanyId and OrganisationId = @organisationId) AND BeanAccountTypeId = (select top 1 Id from Bean.AccountType where CompanyId=@parentComopanyId and name='Other current assets') )
	BEGIN
	insert into Common.XeroAccountTypeDetail(Id, XeroAccountTypeId, BeanAccountTypeId) values (NEWID(), (select Id from Common.XeroAccountType where XeroAccTypeName='Current' and XeroAccTypeId=2 and CompanyId=@subCompanyId and OrganisationId = @organisationId), (select top 1 Id from Bean.AccountType where CompanyId=@parentComopanyId and name='Other current assets'))
	END

	If NOT EXISTS (select * from Common.XeroAccountTypeDetail where XeroAccountTypeId = (select Id from Common.XeroAccountType where XeroAccTypeName='CurrentLiability' and XeroAccTypeId=3 and CompanyId=@subCompanyId and OrganisationId = @organisationId) AND BeanAccountTypeId= (select top 1 Id from Bean.AccountType where CompanyId=@parentComopanyId and name='Other current liabilities'))
	BEGIN
	insert into Common.XeroAccountTypeDetail(Id, XeroAccountTypeId, BeanAccountTypeId) values (NEWID(), (select Id from Common.XeroAccountType where XeroAccTypeName='CurrentLiability' and XeroAccTypeId=3 and CompanyId=@subCompanyId and OrganisationId = @organisationId), (select top 1 Id from Bean.AccountType where CompanyId=@parentComopanyId and name='Other current liabilities'))
	END

	If NOT EXISTS (select * from Common.XeroAccountTypeDetail where XeroAccountTypeId = (select Id from Common.XeroAccountType where XeroAccTypeName='Depreciation' and XeroAccTypeId=4 and CompanyId=@subCompanyId and OrganisationId = @organisationId) AND BeanAccountTypeId =  (select top 1 Id from Bean.AccountType where CompanyId=@parentComopanyId and name='Depreciation'))
	BEGIN
	insert into Common.XeroAccountTypeDetail(Id, XeroAccountTypeId, BeanAccountTypeId) values (NEWID(), (select Id from Common.XeroAccountType where XeroAccTypeName='Depreciation' and XeroAccTypeId=4 and CompanyId=@subCompanyId and OrganisationId = @organisationId), (select top 1 Id from Bean.AccountType where CompanyId=@parentComopanyId and name='Depreciation'))
	END
		
	If NOT EXISTS (select * from Common.XeroAccountTypeDetail where XeroAccountTypeId = (select Id from Common.XeroAccountType where XeroAccTypeName='DIRECTCOSTS' and XeroAccTypeId=5 and CompanyId=@subCompanyId and OrganisationId = @organisationId) AND BeanAccountTypeId = (select top 1 Id from Bean.AccountType where CompanyId=@parentComopanyId and name='Direct costs'))
	BEGIN
	insert into Common.XeroAccountTypeDetail(Id, XeroAccountTypeId, BeanAccountTypeId) values (NEWID(), (select Id from Common.XeroAccountType where XeroAccTypeName='DIRECTCOSTS' and XeroAccTypeId=5 and CompanyId=@subCompanyId and OrganisationId = @organisationId), (select top 1 Id from Bean.AccountType where CompanyId=@parentComopanyId and name='Direct costs'))
	END

	If NOT EXISTS (select * from Common.XeroAccountTypeDetail where XeroAccountTypeId = (select Id from Common.XeroAccountType where XeroAccTypeName='EQUITY' and XeroAccTypeId=6 and CompanyId=@subCompanyId and OrganisationId = @organisationId) AND BeanAccountTypeId = (select top 1 Id from Bean.AccountType where CompanyId=@parentComopanyId and name='EQUITY'))
	BEGIN
	insert into Common.XeroAccountTypeDetail(Id, XeroAccountTypeId, BeanAccountTypeId) values (NEWID(), (select Id from Common.XeroAccountType where XeroAccTypeName='EQUITY' and XeroAccTypeId=6 and CompanyId=@subCompanyId and OrganisationId = @organisationId), (select top 1 Id from Bean.AccountType where CompanyId=@parentComopanyId and name='EQUITY'))
	END

	If NOT EXISTS (select * from Common.XeroAccountTypeDetail where XeroAccountTypeId = (select Id from Common.XeroAccountType where XeroAccTypeName='Expense' and XeroAccTypeId=7 and CompanyId=@subCompanyId and OrganisationId = @organisationId) AND BeanAccountTypeId = (select top 1 Id from Bean.AccountType where CompanyId=@parentComopanyId and name='Other expenses'))
	BEGIN
	insert into Common.XeroAccountTypeDetail(Id, XeroAccountTypeId, BeanAccountTypeId) values (NEWID(), (select Id from Common.XeroAccountType where XeroAccTypeName='Expense' and XeroAccTypeId=7 and CompanyId=@subCompanyId and OrganisationId = @organisationId), (select top 1 Id from Bean.AccountType where CompanyId=@parentComopanyId and name='Other expenses'))
	END

	If NOT EXISTS (select * from Common.XeroAccountTypeDetail where XeroAccountTypeId = (select Id from Common.XeroAccountType where XeroAccTypeName='FIXED' and XeroAccTypeId=8 and CompanyId=@subCompanyId and OrganisationId = @organisationId) AND BeanAccountTypeId = (select top 1 Id from Bean.AccountType where CompanyId=@parentComopanyId and name='FIXED Asset'))
	BEGIN
	insert into Common.XeroAccountTypeDetail(Id, XeroAccountTypeId, BeanAccountTypeId) values (NEWID(), (select Id from Common.XeroAccountType where XeroAccTypeName='FIXED' and XeroAccTypeId=8 and CompanyId=@subCompanyId and OrganisationId = @organisationId), (select top 1 Id from Bean.AccountType where CompanyId=@parentComopanyId and name='FIXED Asset'))
	END

	If NOT EXISTS (select * from Common.XeroAccountTypeDetail where XeroAccountTypeId =  (select Id from Common.XeroAccountType where XeroAccTypeName='Inventory' and XeroAccTypeId=9 and CompanyId=@subCompanyId and OrganisationId = @organisationId) AND BeanAccountTypeId =(select top 1 Id from Bean.AccountType where CompanyId=@parentComopanyId and name='Inventory'))
	BEGIN
	insert into Common.XeroAccountTypeDetail(Id, XeroAccountTypeId, BeanAccountTypeId) values (NEWID(), (select Id from Common.XeroAccountType where XeroAccTypeName='Inventory' and XeroAccTypeId=9 and CompanyId=@subCompanyId and OrganisationId = @organisationId), (select top 1 Id from Bean.AccountType where CompanyId=@parentComopanyId and name='Inventory'))
	END

	If NOT EXISTS (select * from Common.XeroAccountTypeDetail where XeroAccountTypeId =  (select Id from Common.XeroAccountType where XeroAccTypeName='Liability' and XeroAccTypeId=10 and CompanyId=@subCompanyId and OrganisationId = @organisationId) AND BeanAccountTypeId =(select top 1 Id from Bean.AccountType where CompanyId=@parentComopanyId and name='Liability'))
	BEGIN
	insert into Common.XeroAccountTypeDetail(Id, XeroAccountTypeId, BeanAccountTypeId) values (NEWID(), (select Id from Common.XeroAccountType where XeroAccTypeName='Liability' and XeroAccTypeId=10 and CompanyId=@subCompanyId and OrganisationId = @organisationId), (select top 1 Id from Bean.AccountType where CompanyId=@parentComopanyId and name='Liability'))
	END

	If NOT EXISTS (select * from Common.XeroAccountTypeDetail where XeroAccountTypeId =  (select Id from Common.XeroAccountType where XeroAccTypeName='NONCURRENT' and XeroAccTypeId=11 and CompanyId=@subCompanyId and OrganisationId = @organisationId) AND BeanAccountTypeId =(select top 1 Id from Bean.AccountType where CompanyId=@parentComopanyId and name='Other non-current assets'))
	BEGIN
	insert into Common.XeroAccountTypeDetail(Id, XeroAccountTypeId, BeanAccountTypeId) values (NEWID(), (select Id from Common.XeroAccountType where XeroAccTypeName='NONCURRENT' and XeroAccTypeId=11 and CompanyId=@subCompanyId and OrganisationId = @organisationId), (select top 1 Id from Bean.AccountType where CompanyId=@parentComopanyId and name='Other non-current assets'))
	END

	If NOT EXISTS (select * from Common.XeroAccountTypeDetail where XeroAccountTypeId = (select Id from Common.XeroAccountType where XeroAccTypeName='OtherIncome' and XeroAccTypeId=12 and CompanyId=@subCompanyId and OrganisationId = @organisationId) AND BeanAccountTypeId =(select top 1 Id from Bean.AccountType where CompanyId=@parentComopanyId and name='Other income'))
	BEGIN
	insert into Common.XeroAccountTypeDetail(Id, XeroAccountTypeId, BeanAccountTypeId) values (NEWID(), (select Id from Common.XeroAccountType where XeroAccTypeName='OtherIncome' and XeroAccTypeId=12 and CompanyId=@subCompanyId and OrganisationId = @organisationId), (select top 1 Id from Bean.AccountType where CompanyId=@parentComopanyId and name='Other income'))
	END

	If NOT EXISTS (select * from Common.XeroAccountTypeDetail where XeroAccountTypeId = (select Id from Common.XeroAccountType where XeroAccTypeName='Overheads' and XeroAccTypeId=13 and CompanyId=@subCompanyId and OrganisationId = @organisationId) AND BeanAccountTypeId = (select top 1 Id from Bean.AccountType where CompanyId=@parentComopanyId and name='Overheads'))
	BEGIN
	insert into Common.XeroAccountTypeDetail(Id, XeroAccountTypeId, BeanAccountTypeId) values (NEWID(), (select Id from Common.XeroAccountType where XeroAccTypeName='Overheads' and XeroAccTypeId=13 and CompanyId=@subCompanyId and OrganisationId = @organisationId), (select top 1 Id from Bean.AccountType where CompanyId=@parentComopanyId and name='Overheads'))
	END

	If NOT EXISTS (select * from Common.XeroAccountTypeDetail where XeroAccountTypeId = (select Id from Common.XeroAccountType where XeroAccTypeName='PREPAYMENT' and XeroAccTypeId=14 and CompanyId=@subCompanyId and OrganisationId = @organisationId) AND BeanAccountTypeId = (select top 1 Id from Bean.AccountType where CompanyId=@parentComopanyId and name='Deposits and prepayments'))
	BEGIN
	insert into Common.XeroAccountTypeDetail(Id, XeroAccountTypeId, BeanAccountTypeId) values (NEWID(), (select Id from Common.XeroAccountType where XeroAccTypeName='PREPAYMENT' and XeroAccTypeId=14 and CompanyId=@subCompanyId and OrganisationId = @organisationId), (select top 1 Id from Bean.AccountType where CompanyId=@parentComopanyId and name='Deposits and prepayments'))
	END

	If NOT EXISTS (select * from Common.XeroAccountTypeDetail where XeroAccountTypeId =  (select Id from Common.XeroAccountType where XeroAccTypeName='REVENUE' and XeroAccTypeId=15 and CompanyId=@subCompanyId and OrganisationId = @organisationId) AND BeanAccountTypeId = (select top 1 Id from Bean.AccountType where CompanyId=@parentComopanyId and name='REVENUE'))
	BEGIN
	insert into Common.XeroAccountTypeDetail(Id, XeroAccountTypeId, BeanAccountTypeId) values (NEWID(), (select Id from Common.XeroAccountType where XeroAccTypeName='REVENUE' and XeroAccTypeId=15 and CompanyId=@subCompanyId and OrganisationId = @organisationId), (select top 1 Id from Bean.AccountType where CompanyId=@parentComopanyId and name='REVENUE'))
	END

	If NOT EXISTS (select * from Common.XeroAccountTypeDetail where XeroAccountTypeId = (select Id from Common.XeroAccountType where XeroAccTypeName='SALES' and XeroAccTypeId=16 and CompanyId=@subCompanyId and OrganisationId = @organisationId) AND BeanAccountTypeId = (select top 1 Id from Bean.AccountType where CompanyId=@parentComopanyId and name='SALES'))
	BEGIN
	insert into Common.XeroAccountTypeDetail(Id, XeroAccountTypeId, BeanAccountTypeId) values (NEWID(), (select Id from Common.XeroAccountType where XeroAccTypeName='SALES' and XeroAccTypeId=16 and CompanyId=@subCompanyId and OrganisationId = @organisationId), (select top 1 Id from Bean.AccountType where CompanyId=@parentComopanyId and name='SALES'))
	END

	If NOT EXISTS (select * from Common.XeroAccountTypeDetail where XeroAccountTypeId = (select Id from Common.XeroAccountType where XeroAccTypeName='TermLiability' and XeroAccTypeId=17 and CompanyId=@subCompanyId and OrganisationId = @organisationId) AND BeanAccountTypeId =(select top 1 Id from Bean.AccountType where CompanyId=@parentComopanyId and name='Other non-current liabilities'))
    BEGIN
	insert into Common.XeroAccountTypeDetail(Id, XeroAccountTypeId, BeanAccountTypeId) values (NEWID(), (select Id from Common.XeroAccountType where XeroAccTypeName='TermLiability' and XeroAccTypeId=17 and CompanyId=@subCompanyId and OrganisationId = @organisationId), (select top 1 Id from Bean.AccountType where CompanyId=@parentComopanyId and name='Other non-current liabilities'))
	END

	If NOT EXISTS (select * from Common.XeroAccountTypeDetail where XeroAccountTypeId =  (select Id from Common.XeroAccountType where XeroAccTypeName='PayGLiability' and XeroAccTypeId=18 and CompanyId=@subCompanyId and OrganisationId = @organisationId) AND BeanAccountTypeId = (select top 1 Id from Bean.AccountType where CompanyId=@parentComopanyId and name='PayGLiability'))
	BEGIN
	insert into Common.XeroAccountTypeDetail(Id, XeroAccountTypeId, BeanAccountTypeId) values (NEWID(), (select Id from Common.XeroAccountType where XeroAccTypeName='PayGLiability' and XeroAccTypeId=18 and CompanyId=@subCompanyId and OrganisationId = @organisationId), (select top 1 Id from Bean.AccountType where CompanyId=@parentComopanyId and name='PayGLiability'))
	END

	If NOT EXISTS (select * from Common.XeroAccountTypeDetail where XeroAccountTypeId =  (select Id from Common.XeroAccountType where XeroAccTypeName='SuperannuationExpense' and XeroAccTypeId=19 and CompanyId=@subCompanyId and OrganisationId = @organisationId) AND BeanAccountTypeId =(select top 1 Id from Bean.AccountType where CompanyId=@parentComopanyId and name='SuperannuationExpense'))
	BEGIN
	insert into Common.XeroAccountTypeDetail(Id, XeroAccountTypeId, BeanAccountTypeId) values (NEWID(), (select Id from Common.XeroAccountType where XeroAccTypeName='SuperannuationExpense' and XeroAccTypeId=19 and CompanyId=@subCompanyId and OrganisationId = @organisationId), (select top 1 Id from Bean.AccountType where CompanyId=@parentComopanyId and name='SuperannuationExpense'))
	END

	If NOT EXISTS (select * from Common.XeroAccountTypeDetail where XeroAccountTypeId = (select Id from Common.XeroAccountType where XeroAccTypeName='SuperannuationLiability' and XeroAccTypeId=20 and CompanyId=@subCompanyId and OrganisationId = @organisationId) AND BeanAccountTypeId= (select top 1 Id from Bean.AccountType where CompanyId=@parentComopanyId and name='SuperannuationLiability'))
	BEGIN
	insert into Common.XeroAccountTypeDetail(Id, XeroAccountTypeId, BeanAccountTypeId) values (NEWID(), (select Id from Common.XeroAccountType where XeroAccTypeName='SuperannuationLiability' and XeroAccTypeId=20 and CompanyId=@subCompanyId and OrganisationId = @organisationId), (select top 1 Id from Bean.AccountType where CompanyId=@parentComopanyId and name='SuperannuationLiability'))
	END

	If NOT EXISTS (select * from Common.XeroAccountTypeDetail where XeroAccountTypeId = (select Id from Common.XeroAccountType where XeroAccTypeName='WagesExpense' and XeroAccTypeId=21 and CompanyId=@subCompanyId and OrganisationId = @organisationId) AND BeanAccountTypeId =(select top 1 Id from Bean.AccountType where CompanyId=@parentComopanyId and name='WagesExpense'))
	BEGIN
	insert into Common.XeroAccountTypeDetail(Id, XeroAccountTypeId, BeanAccountTypeId) values (NEWID(), (select Id from Common.XeroAccountType where XeroAccTypeName='WagesExpense' and XeroAccTypeId=21 and CompanyId=@subCompanyId and OrganisationId = @organisationId), (select top 1 Id from Bean.AccountType where CompanyId=@parentComopanyId and name='WagesExpense'))
	END
	    
	--========================= COA ===============================
	
	IF NOT EXISTS (select *from  Common.XeroCOADetail where XeroCOAId =  (select Id from Common.XeroCOA where XeroName='437-Interest Expense' and XeroCode='437' and CompanyId=@subCompanyId and OrganisationId = @organisationId) AND BeanCOAId = (select top 1  Id from Bean.ChartOfAccount where CompanyId=@parentComopanyId and Name='Interest expenses'))
	BEGIN
	insert into Common.XeroCOADetail (Id, XeroCOAId, BeanCOAId) values (NEWID(), (select Id from Common.XeroCOA where XeroName='437-Interest Expense' and XeroCode='437' and CompanyId=@subCompanyId and OrganisationId = @organisationId), (select top 1  Id from Bean.ChartOfAccount where CompanyId=@parentComopanyId and Name='Interest expenses'))
	END

	IF NOT EXISTS (select *from  Common.XeroCOADetail where XeroCOAId = (select Id from Common.XeroCOA where XeroName='505-Income Tax Expense' and XeroCode='505' and CompanyId=@subCompanyId and OrganisationId = @organisationId) AND BeanCOAId = (select top 1  Id from Bean.ChartOfAccount where CompanyId=@parentComopanyId and Name='Taxation'))
	BEGIN
	insert into Common.XeroCOADetail (Id, XeroCOAId, BeanCOAId) values (NEWID(), (select Id from Common.XeroCOA where XeroName='505-Income Tax Expense' and XeroCode='505' and CompanyId=@subCompanyId and OrganisationId = @organisationId), (select top 1  Id from Bean.ChartOfAccount where CompanyId=@parentComopanyId and Name='Taxation'))
	END

	IF NOT EXISTS (select *from  Common.XeroCOADetail where XeroCOAId =   (select Id from Common.XeroCOA where XeroName='270-Interest Income' and XeroCode='270' and CompanyId=@subCompanyId and OrganisationId = @organisationId) AND BeanCOAId = (select top 1  Id from Bean.ChartOfAccount where CompanyId=@parentComopanyId and Name='Interest income'))
	BEGIN
	insert into Common.XeroCOADetail (Id, XeroCOAId, BeanCOAId) values (NEWID(), (select Id from Common.XeroCOA where XeroName='270-Interest Income' and XeroCode='270' and CompanyId=@subCompanyId and OrganisationId = @organisationId), (select top 1  Id from Bean.ChartOfAccount where CompanyId=@parentComopanyId and Name='Interest income'))
	END

	IF NOT EXISTS (select *from  Common.XeroCOADetail where XeroCOAId =  (select Id from Common.XeroCOA where XeroName='445-Light, Power, Heating' and XeroCode='445' and CompanyId=@subCompanyId and OrganisationId = @organisationId) AND BeanCOAId = (select top 1  Id from Bean.ChartOfAccount where CompanyId=@parentComopanyId and Name='Utilities'))
	BEGIN
	insert into Common.XeroCOADetail (Id, XeroCOAId, BeanCOAId) values (NEWID(), (select Id from Common.XeroCOA where XeroName='445-Light, Power, Heating' and XeroCode='445' and CompanyId=@subCompanyId and OrganisationId = @organisationId), (select top 1  Id from Bean.ChartOfAccount where CompanyId=@parentComopanyId and Name='Utilities'))
	END

	IF NOT EXISTS (select *from  Common.XeroCOADetail where XeroCOAId = (select Id from Common.XeroCOA where XeroName='449-Motor Vehicle Expenses' and XeroCode='449' and CompanyId=@subCompanyId and OrganisationId = @organisationId) AND BeanCOAId = (select top 1  Id from Bean.ChartOfAccount where CompanyId=@parentComopanyId and Name='Upkeep of motor vehicles'))
	BEGIN
	insert into Common.XeroCOADetail (Id, XeroCOAId, BeanCOAId) values (NEWID(), (select Id from Common.XeroCOA where XeroName='449-Motor Vehicle Expenses' and XeroCode='449' and CompanyId=@subCompanyId and OrganisationId = @organisationId), (select top 1  Id from Bean.ChartOfAccount where CompanyId=@parentComopanyId and Name='Upkeep of motor vehicles'))
	END

	IF NOT EXISTS (select *from  Common.XeroCOADetail where XeroCOAId =  (select Id from Common.XeroCOA where XeroName='493-Travel - National' and XeroCode='493' and CompanyId=@subCompanyId and OrganisationId = @organisationId) AND BeanCOAId = (select top 1  Id from Bean.ChartOfAccount where CompanyId=@parentComopanyId and Name='Travelling'))
	BEGIN
	insert into Common.XeroCOADetail (Id, XeroCOAId, BeanCOAId) values (NEWID(), (select Id from Common.XeroCOA where XeroName='493-Travel - National' and XeroCode='493' and CompanyId=@subCompanyId and OrganisationId = @organisationId), (select top 1  Id from Bean.ChartOfAccount where CompanyId=@parentComopanyId and Name='Travelling'))
	END

	IF NOT EXISTS (select *from  Common.XeroCOADetail where XeroCOAId =  (select Id from Common.XeroCOA where XeroName='489-Telephone & Internet' and XeroCode='489' and CompanyId=@subCompanyId and OrganisationId = @organisationId) AND BeanCOAId = (select top 1  Id from Bean.ChartOfAccount where CompanyId=@parentComopanyId and Name='Telecommunication'))
	BEGIN
	insert into Common.XeroCOADetail (Id, XeroCOAId, BeanCOAId) values (NEWID(), (select Id from Common.XeroCOA where XeroName='489-Telephone & Internet' and XeroCode='489' and CompanyId=@subCompanyId and OrganisationId = @organisationId), (select top 1  Id from Bean.ChartOfAccount where CompanyId=@parentComopanyId and Name='Telecommunication'))
	END

	IF NOT EXISTS (select *from  Common.XeroCOADetail where XeroCOAId = (select Id from Common.XeroCOA where XeroName='494-Travel - International' and XeroCode='494' and CompanyId=@subCompanyId and OrganisationId = @organisationId) AND BeanCOAId = (select top 1  Id from Bean.ChartOfAccount where CompanyId=@parentComopanyId and Name='Travelling'))
	BEGIN
	insert into Common.XeroCOADetail (Id, XeroCOAId, BeanCOAId) values (NEWID(), (select Id from Common.XeroCOA where XeroName='494-Travel - International' and XeroCode='494' and CompanyId=@subCompanyId and OrganisationId = @organisationId), (select top 1  Id from Bean.ChartOfAccount where CompanyId=@parentComopanyId and Name='Travelling'))
	END

	IF NOT EXISTS (select *from  Common.XeroCOADetail where XeroCOAId = (select Id from Common.XeroCOA where XeroName='477-Wages and Salaries' and XeroCode='477' and CompanyId=@subCompanyId and OrganisationId = @organisationId) AND BeanCOAId = (select top 1  Id from Bean.ChartOfAccount where CompanyId=@parentComopanyId and Name='Staff salary'))
	BEGIN
	insert into Common.XeroCOADetail (Id, XeroCOAId, BeanCOAId) values (NEWID(), (select Id from Common.XeroCOA where XeroName='477-Wages and Salaries' and XeroCode='477' and CompanyId=@subCompanyId and OrganisationId = @organisationId), (select top 1  Id from Bean.ChartOfAccount where CompanyId=@parentComopanyId and Name='Staff salary'))
	END

	IF NOT EXISTS (select *from  Common.XeroCOADetail where XeroCOAId = (select Id from Common.XeroCOA where XeroName='860-Rounding' and XeroCode='860' and CompanyId=@subCompanyId and OrganisationId = @organisationId) AND BeanCOAId = (select top 1  Id from Bean.ChartOfAccount where CompanyId=@parentComopanyId and Name='Rounding'))
	BEGIN
	insert into Common.XeroCOADetail (Id, XeroCOAId, BeanCOAId) values (NEWID(), (select Id from Common.XeroCOA where XeroName='860-Rounding' and XeroCode='860' and CompanyId=@subCompanyId and OrganisationId = @organisationId), (select top 1  Id from Bean.ChartOfAccount where CompanyId=@parentComopanyId and Name='Rounding'))
	END

	IF NOT EXISTS (select *from  Common.XeroCOADetail where XeroCOAId = (select Id from Common.XeroCOA where XeroName='473-Repairs and Maintenance' and XeroCode='473' and CompanyId=@subCompanyId and OrganisationId = @organisationId) AND BeanCOAId = (select top 1  Id from Bean.ChartOfAccount where CompanyId=@parentComopanyId and Name='Repair and maintenance'))
	BEGIN
	insert into Common.XeroCOADetail (Id, XeroCOAId, BeanCOAId) values (NEWID(), (select Id from Common.XeroCOA where XeroName='473-Repairs and Maintenance' and XeroCode='473' and CompanyId=@subCompanyId and OrganisationId = @organisationId), (select top 1  Id from Bean.ChartOfAccount where CompanyId=@parentComopanyId and Name='Repair and maintenance'))
	END

	IF NOT EXISTS (select *from  Common.XeroCOADetail where XeroCOAId = (select Id from Common.XeroCOA where XeroName='461-Printing & Stationery' and XeroCode='461' and CompanyId=@subCompanyId and OrganisationId = @organisationId) AND BeanCOAId = (select top 1  Id from Bean.ChartOfAccount where CompanyId=@parentComopanyId and Name='Printing and stationery'))
	BEGIN
	insert into Common.XeroCOADetail (Id, XeroCOAId, BeanCOAId) values (NEWID(), (select Id from Common.XeroCOA where XeroName='461-Printing & Stationery' and XeroCode='461' and CompanyId=@subCompanyId and OrganisationId = @organisationId), (select top 1  Id from Bean.ChartOfAccount where CompanyId=@parentComopanyId and Name='Printing and stationery'))
	END

	IF NOT EXISTS (select *from  Common.XeroCOADetail where XeroCOAId = (select Id from Common.XeroCOA where XeroName='453-Office Expenses' and XeroCode='453' and CompanyId=@subCompanyId and OrganisationId = @organisationId) AND BeanCOAId = (select top 1  Id from Bean.ChartOfAccount where CompanyId=@parentComopanyId and Name='Office expenses'))
	BEGIN
	insert into Common.XeroCOADetail (Id, XeroCOAId, BeanCOAId) values (NEWID(), (select Id from Common.XeroCOA where XeroName='453-Office Expenses' and XeroCode='453' and CompanyId=@subCompanyId and OrganisationId = @organisationId), (select top 1  Id from Bean.ChartOfAccount where CompanyId=@parentComopanyId and Name='Office expenses'))
	END

	IF NOT EXISTS (select *from  Common.XeroCOADetail where XeroCOAId = (select Id from Common.XeroCOA where XeroName='469-Rent' and XeroCode='469' and CompanyId=@subCompanyId and OrganisationId = @organisationId) AND BeanCOAId = (select top 1  Id from Bean.ChartOfAccount where CompanyId=@parentComopanyId and Name='Operating lease'))
	BEGIN
	insert into Common.XeroCOADetail (Id, XeroCOAId, BeanCOAId) values (NEWID(), (select Id from Common.XeroCOA where XeroName='469-Rent' and XeroCode='469' and CompanyId=@subCompanyId and OrganisationId = @organisationId), (select top 1  Id from Bean.ChartOfAccount where CompanyId=@parentComopanyId and Name='Operating lease'))
	END

	IF NOT EXISTS (select *from  Common.XeroCOADetail where XeroCOAId = (select Id from Common.XeroCOA where XeroName='433-Insurance' and XeroCode='433' and CompanyId=@subCompanyId and OrganisationId = @organisationId) AND BeanCOAId = (select top 1  Id from Bean.ChartOfAccount where CompanyId=@parentComopanyId and Name='Insurance'))
	BEGIN
	insert into Common.XeroCOADetail (Id, XeroCOAId, BeanCOAId) values (NEWID(), (select Id from Common.XeroCOA where XeroName='433-Insurance' and XeroCode='433' and CompanyId=@subCompanyId and OrganisationId = @organisationId), (select top 1  Id from Bean.ChartOfAccount where CompanyId=@parentComopanyId and Name='Insurance'))
	END

	IF NOT EXISTS (select *from  Common.XeroCOADetail where XeroCOAId = (select Id from Common.XeroCOA where XeroName='420-Entertainment' and XeroCode='420' and CompanyId=@subCompanyId and OrganisationId = @organisationId) AND BeanCOAId = (select top 1  Id from Bean.ChartOfAccount where CompanyId=@parentComopanyId and Name='Entertainment and gifts'))
	BEGIN
	insert into Common.XeroCOADetail (Id, XeroCOAId, BeanCOAId) values (NEWID(), (select Id from Common.XeroCOA where XeroName='420-Entertainment' and XeroCode='420' and CompanyId=@subCompanyId and OrganisationId = @organisationId), (select top 1  Id from Bean.ChartOfAccount where CompanyId=@parentComopanyId and Name='Entertainment and gifts'))
	END

	IF NOT EXISTS (select *from  Common.XeroCOADetail where XeroCOAId = (select Id from Common.XeroCOA where XeroName='437-Interest Expense' and XeroCode='437' and CompanyId=@subCompanyId and OrganisationId = @organisationId) AND BeanCOAId = (select top 1  Id from Bean.ChartOfAccount where CompanyId=@parentComopanyId and Name='Interest expenses'))
	BEGIN
	insert into Common.XeroCOADetail (Id, XeroCOAId, BeanCOAId) values (NEWID(), (select Id from Common.XeroCOA where XeroName='437-Interest Expense' and XeroCode='437' and CompanyId=@subCompanyId and OrganisationId = @organisationId), (select top 1  Id from Bean.ChartOfAccount where CompanyId=@parentComopanyId and Name='Interest expenses'))
	END

	IF NOT EXISTS (select *from  Common.XeroCOADetail where XeroCOAId = (select Id from Common.XeroCOA where XeroName='416-Depreciation' and XeroCode='416' and CompanyId=@subCompanyId and OrganisationId = @organisationId) AND BeanCOAId = (select top 1  Id from Bean.ChartOfAccount where CompanyId=@parentComopanyId and Name='Depreciation'))
	BEGIN
	insert into Common.XeroCOADetail (Id, XeroCOAId, BeanCOAId) values (NEWID(), (select Id from Common.XeroCOA where XeroName='416-Depreciation' and XeroCode='416' and CompanyId=@subCompanyId and OrganisationId = @organisationId), (select top 1  Id from Bean.ChartOfAccount where CompanyId=@parentComopanyId and Name='Depreciation'))
	END

	IF NOT EXISTS (select *from  Common.XeroCOADetail where XeroCOAId = (select Id from Common.XeroCOA where XeroName='425-Freight & Courier' and XeroCode='425' and CompanyId=@subCompanyId and OrganisationId = @organisationId) AND BeanCOAId = (select top 1  Id from Bean.ChartOfAccount where CompanyId=@parentComopanyId and Name='Courier and postages'))
	BEGIN
	insert into Common.XeroCOADetail (Id, XeroCOAId, BeanCOAId) values (NEWID(), (select Id from Common.XeroCOA where XeroName='425-Freight & Courier' and XeroCode='425' and CompanyId=@subCompanyId and OrganisationId = @organisationId), (select top 1  Id from Bean.ChartOfAccount where CompanyId=@parentComopanyId and Name='Courier and postages'))
	END

	IF NOT EXISTS (select *from  Common.XeroCOADetail where XeroCOAId = (select Id from Common.XeroCOA where XeroName='404-Bank Fees' and XeroCode='404' and CompanyId=@subCompanyId and OrganisationId = @organisationId) AND BeanCOAId = (select top 1  Id from Bean.ChartOfAccount where CompanyId=@parentComopanyId and Name='Bank charges'))
	BEGIN
	insert into Common.XeroCOADetail (Id, XeroCOAId, BeanCOAId) values (NEWID(), (select Id from Common.XeroCOA where XeroName='404-Bank Fees' and XeroCode='404' and CompanyId=@subCompanyId and OrganisationId = @organisationId), (select top 1  Id from Bean.ChartOfAccount where CompanyId=@parentComopanyId and Name='Bank charges'))
	END

	IF NOT EXISTS (select *from  Common.XeroCOADetail where XeroCOAId = (select Id from Common.XeroCOA where XeroName='400-Advertising' and XeroCode='400' and CompanyId=@subCompanyId and OrganisationId = @organisationId) AND BeanCOAId = (select top 1  Id from Bean.ChartOfAccount where CompanyId=@parentComopanyId and Name='Advertising'))
	BEGIN
	insert into Common.XeroCOADetail (Id, XeroCOAId, BeanCOAId) values (NEWID(), (select Id from Common.XeroCOA where XeroName='400-Advertising' and XeroCode='400' and CompanyId=@subCompanyId and OrganisationId = @organisationId), (select top 1  Id from Bean.ChartOfAccount where CompanyId=@parentComopanyId and Name='Advertising'))
	END

	IF NOT EXISTS (select *from  Common.XeroCOADetail where XeroCOAId =   (select Id from Common.XeroCOA where XeroName='200-Sales' and XeroCode='200' and CompanyId=@subCompanyId and OrganisationId = @organisationId) AND BeanCOAId = (select top 1  Id from Bean.ChartOfAccount where CompanyId=@parentComopanyId and Name='Revenue'))
	BEGIN
	insert into Common.XeroCOADetail (Id, XeroCOAId, BeanCOAId) values (NEWID(), (select Id from Common.XeroCOA where XeroName='200-Sales' and XeroCode='200' and CompanyId=@subCompanyId and OrganisationId = @organisationId), (select top 1  Id from Bean.ChartOfAccount where CompanyId=@parentComopanyId and Name='Revenue'))
	END

	IF NOT EXISTS (select *from  Common.XeroCOADetail where XeroCOAId =  (select Id from Common.XeroCOA where XeroName='960-Retained Earnings' and XeroCode='960' and CompanyId=@subCompanyId and OrganisationId = @organisationId) AND BeanCOAId = (select top 1  Id from Bean.ChartOfAccount where CompanyId=@parentComopanyId and Name='Retained earnings'))
	BEGIN
	insert into Common.XeroCOADetail (Id, XeroCOAId, BeanCOAId) values (NEWID(), (select Id from Common.XeroCOA where XeroName='960-Retained Earnings' and XeroCode='960' and CompanyId=@subCompanyId and OrganisationId = @organisationId), (select top 1  Id from Bean.ChartOfAccount where CompanyId=@parentComopanyId and Name='Retained earnings'))
	END

	IF NOT EXISTS (select *from  Common.XeroCOADetail where XeroCOAId =  (select Id from Common.XeroCOA where XeroName='970-Owner A Share Capital' and XeroCode='970' and CompanyId=@subCompanyId and OrganisationId = @organisationId) AND BeanCOAId = (select top 1  Id from Bean.ChartOfAccount where CompanyId=@parentComopanyId and Name='Share capital'))
	BEGIN
	insert into Common.XeroCOADetail (Id, XeroCOAId, BeanCOAId) values (NEWID(), (select Id from Common.XeroCOA where XeroName='970-Owner A Share Capital' and XeroCode='970' and CompanyId=@subCompanyId and OrganisationId = @organisationId), (select top 1  Id from Bean.ChartOfAccount where CompanyId=@parentComopanyId and Name='Share capital'))
	END

	IF NOT EXISTS (select *from  Common.XeroCOADetail where XeroCOAId =  (select Id from Common.XeroCOA where XeroName='830-Income Tax Payable' and XeroCode='830' and CompanyId=@subCompanyId and OrganisationId = @organisationId) AND BeanCOAId = (select top 1  Id from Bean.ChartOfAccount where CompanyId=@parentComopanyId and Name='Provision for taxation'))
	BEGIN
	insert into Common.XeroCOADetail (Id, XeroCOAId, BeanCOAId) values (NEWID(), (select Id from Common.XeroCOA where XeroName='830-Income Tax Payable' and XeroCode='830' and CompanyId=@subCompanyId and OrganisationId = @organisationId), (select top 1  Id from Bean.ChartOfAccount where CompanyId=@parentComopanyId and Name='Provision for taxation'))
	END

	IF NOT EXISTS (select *from  Common.XeroCOADetail where XeroCOAId = (select Id from Common.XeroCOA where XeroName='820-GST' and XeroCode='820' and CompanyId=@subCompanyId and OrganisationId = @organisationId) AND BeanCOAId = (select top 1  Id from Bean.ChartOfAccount where CompanyId=@parentComopanyId and Name='Tax payable (GST)'))
	BEGIN
	insert into Common.XeroCOADetail (Id, XeroCOAId, BeanCOAId) values (NEWID(), (select Id from Common.XeroCOA where XeroName='820-GST' and XeroCode='820' and CompanyId=@subCompanyId and OrganisationId = @organisationId), (select top 1  Id from Bean.ChartOfAccount where CompanyId=@parentComopanyId and Name='Tax payable (GST)'))
	END

	IF NOT EXISTS (select *from  Common.XeroCOADetail where XeroCOAId =  (select Id from Common.XeroCOA where XeroName='800-Accounts Payable' and XeroCode='800' and CompanyId=@subCompanyId and OrganisationId = @organisationId) AND BeanCOAId = (select top 1  Id from Bean.ChartOfAccount where CompanyId=@parentComopanyId and Name='Trade payables'))
	BEGIN
	insert into Common.XeroCOADetail (Id, XeroCOAId, BeanCOAId) values (NEWID(), (select Id from Common.XeroCOA where XeroName='800-Accounts Payable' and XeroCode='800' and CompanyId=@subCompanyId and OrganisationId = @organisationId), (select top 1  Id from Bean.ChartOfAccount where CompanyId=@parentComopanyId and Name='Trade payables'))
	END

	IF NOT EXISTS (select *from  Common.XeroCOADetail where XeroCOAId =  (select Id from Common.XeroCOA where XeroName='711-Less Accumulated Depreciation on Office Equipment' and XeroCode='711' and CompanyId=@subCompanyId and OrganisationId = @organisationId) AND BeanCOAId = (select top 1  Id from Bean.ChartOfAccount where CompanyId=@parentComopanyId and Name='Office Equipment - Accum Depn'))
	BEGIN
	insert into Common.XeroCOADetail (Id, XeroCOAId, BeanCOAId) values (NEWID(), (select Id from Common.XeroCOA where XeroName='711-Less Accumulated Depreciation on Office Equipment' and XeroCode='711' and CompanyId=@subCompanyId and OrganisationId = @organisationId), (select top 1  Id from Bean.ChartOfAccount where CompanyId=@parentComopanyId and Name='Office Equipment - Accum Depn'))
	END

	IF NOT EXISTS (select *from  Common.XeroCOADetail where XeroCOAId = (select Id from Common.XeroCOA where XeroName='710-Office Equipment' and XeroCode='710' and CompanyId=@subCompanyId and OrganisationId = @organisationId) AND BeanCOAId =(select top 1  Id from Bean.ChartOfAccount where CompanyId=@parentComopanyId and Name='Office equipment - Cost') )
	BEGIN
	insert into Common.XeroCOADetail (Id, XeroCOAId, BeanCOAId) values (NEWID(), (select Id from Common.XeroCOA where XeroName='710-Office Equipment' and XeroCode='710' and CompanyId=@subCompanyId and OrganisationId = @organisationId), (select top 1  Id from Bean.ChartOfAccount where CompanyId=@parentComopanyId and Name='Office equipment - Cost'))
	END

	IF NOT EXISTS (select *from  Common.XeroCOADetail where XeroCOAId = (select Id from Common.XeroCOA where XeroName='630-Inventory' and XeroCode='630' and CompanyId=@subCompanyId and OrganisationId = @organisationId) AND BeanCOAId = (select top 1  Id from Bean.ChartOfAccount where CompanyId=@parentComopanyId and Name='Inventory'))
	BEGIN
	 insert into Common.XeroCOADetail (Id, XeroCOAId, BeanCOAId) values (NEWID(), (select Id from Common.XeroCOA where XeroName='630-Inventory' and XeroCode='630' and CompanyId=@subCompanyId and OrganisationId = @organisationId), (select top 1  Id from Bean.ChartOfAccount where CompanyId=@parentComopanyId and Name='Inventory'))
	END

	IF NOT EXISTS (select *from  Common.XeroCOADetail where XeroCOAId =  (select Id from Common.XeroCOA where XeroName='610-Accounts Receivable' and XeroCode='610' and CompanyId=@subCompanyId and OrganisationId = @organisationId) AND BeanCOAId =(select top 1  Id from Bean.ChartOfAccount where CompanyId=@parentComopanyId and Name='Trade receivables'))
	BEGIN
	insert into Common.XeroCOADetail (Id, XeroCOAId, BeanCOAId) values (NEWID(), (select Id from Common.XeroCOA where XeroName='610-Accounts Receivable' and XeroCode='610' and CompanyId=@subCompanyId and OrganisationId = @organisationId), (select top 1  Id from Bean.ChartOfAccount where CompanyId=@parentComopanyId and Name='Trade receivables'))
	END

	--update Common.XeroCOA set OrganisationId=@organisationId, BeanCOAId = (select top 1  Id from Bean.ChartOfAccount where CompanyId=@parentComopanyId and Name='Interest expenses') where XeroName='437- Interest Expense' and XeroCode='437' and CompanyId=@subCompanyId and OrganisationId = @organisationId

	--update Common.XeroCOA set OrganisationId=@organisationId, BeanCOAId = (select top 1  Id from Bean.ChartOfAccount where CompanyId=@parentComopanyId and Name='Taxation') where XeroName='505- Income Tax Expense' and XeroCode='505' and CompanyId=@subCompanyId and OrganisationId = @organisationId

	--update Common.XeroCOA set OrganisationId=@organisationId, BeanCOAId = (select top 1  Id from Bean.ChartOfAccount where CompanyId=@parentComopanyId and Name='Interest income') where XeroName='270- Interest Income' and XeroCode='270' and CompanyId=@subCompanyId and OrganisationId = @organisationId

	--update Common.XeroCOA set OrganisationId=@organisationId, BeanCOAId = (select top 1  Id from Bean.ChartOfAccount where CompanyId=@parentComopanyId and Name='Utilities') where XeroName='445- Light, Power, Heating' and XeroCode='445' and CompanyId=@subCompanyId and OrganisationId = @organisationId

	--update Common.XeroCOA set OrganisationId=@organisationId, BeanCOAId = (select top 1  Id from Bean.ChartOfAccount where CompanyId=@parentComopanyId and Name='Upkeep of motor vehicles') where XeroName='449- Motor Vehicle Expenses' and XeroCode='449' and CompanyId=@subCompanyId and OrganisationId = @organisationId

	--update Common.XeroCOA set OrganisationId=@organisationId, BeanCOAId = (select top 1  Id from Bean.ChartOfAccount where CompanyId=@parentComopanyId and Name='Travelling') where XeroName='493- Travel - National' and XeroCode='493' and CompanyId=@subCompanyId and OrganisationId = @organisationId

	--update Common.XeroCOA set OrganisationId=@organisationId, BeanCOAId = (select top 1  Id from Bean.ChartOfAccount where CompanyId=@parentComopanyId and Name='Telecommunication') where XeroName='489- Telephone & Internet' and XeroCode='489' and CompanyId=@subCompanyId and OrganisationId = @organisationId

	--update Common.XeroCOA set OrganisationId=@organisationId, BeanCOAId = (select top 1  Id from Bean.ChartOfAccount where CompanyId=@parentComopanyId and Name='Travelling') where XeroName='494- Travel - International' and XeroCode='494' and CompanyId=@subCompanyId and OrganisationId = @organisationId

	--update Common.XeroCOA set OrganisationId=@organisationId, BeanCOAId = (select top 1  Id from Bean.ChartOfAccount where CompanyId=@parentComopanyId and Name='Staff salary') where XeroName='477- Wages and Salaries' and XeroCode='477' and CompanyId=@subCompanyId and OrganisationId = @organisationId

	--update Common.XeroCOA set OrganisationId=@organisationId, BeanCOAId = (select top 1  Id from Bean.ChartOfAccount where CompanyId=@parentComopanyId and Name='Rounding') where XeroName='860- Rounding' and XeroCode='860' and CompanyId=@subCompanyId and OrganisationId = @organisationId

	--update Common.XeroCOA set OrganisationId=@organisationId, BeanCOAId = (select top 1  Id from Bean.ChartOfAccount where CompanyId=@parentComopanyId and Name='Repair and maintenance') where XeroName='473- Repairs and Maintenance' and XeroCode='473' and CompanyId=@subCompanyId and OrganisationId = @organisationId

	--update Common.XeroCOA set OrganisationId=@organisationId, BeanCOAId = (select top 1  Id from Bean.ChartOfAccount where CompanyId=@parentComopanyId and Name='Printing and stationery') where XeroName='461- Printing & Stationery' and XeroCode='461' and CompanyId=@subCompanyId and OrganisationId = @organisationId

	--update Common.XeroCOA set OrganisationId=@organisationId, BeanCOAId = (select top 1  Id from Bean.ChartOfAccount where CompanyId=@parentComopanyId and Name='Office expenses') where XeroName='453- Office Expenses' and XeroCode='453' and CompanyId=@subCompanyId and OrganisationId = @organisationId

	--update Common.XeroCOA set OrganisationId=@organisationId, BeanCOAId = (select top 1  Id from Bean.ChartOfAccount where CompanyId=@parentComopanyId and Name='Operating lease') where XeroName='469- Rent' and XeroCode='469' and CompanyId=@subCompanyId and OrganisationId = @organisationId

	--update Common.XeroCOA set OrganisationId=@organisationId, BeanCOAId = (select top 1  Id from Bean.ChartOfAccount where CompanyId=@parentComopanyId and Name='Insurance') where XeroName='433- Insurance' and XeroCode='433' and CompanyId=@subCompanyId and OrganisationId = @organisationId

	--update Common.XeroCOA set OrganisationId=@organisationId, BeanCOAId = (select top 1  Id from Bean.ChartOfAccount where CompanyId=@parentComopanyId and Name='Entertainment and gifts') where XeroName='420- Entertainment' and XeroCode='420' and CompanyId=@subCompanyId and OrganisationId = @organisationId

	--update Common.XeroCOA set OrganisationId=@organisationId, BeanCOAId = (select top 1  Id from Bean.ChartOfAccount where CompanyId=@parentComopanyId and Name='Depreciation') where XeroName='416- Depreciation' and XeroCode='416' and CompanyId=@subCompanyId and OrganisationId = @organisationId

	--update Common.XeroCOA set OrganisationId=@organisationId, BeanCOAId = (select top 1  Id from Bean.ChartOfAccount where CompanyId=@parentComopanyId and Name='Courier and postages') where XeroName='425- Freight & Courier' and XeroCode='425' and CompanyId=@subCompanyId and OrganisationId = @organisationId

	--update Common.XeroCOA set OrganisationId=@organisationId, BeanCOAId = (select top 1  Id from Bean.ChartOfAccount where CompanyId=@parentComopanyId and Name='Bank charges') where XeroName='404- Bank Fees' and XeroCode='404' and CompanyId=@subCompanyId and OrganisationId = @organisationId

	--update Common.XeroCOA set OrganisationId=@organisationId, BeanCOAId = (select top 1  Id from Bean.ChartOfAccount where CompanyId=@parentComopanyId and Name='Advertising') where XeroName='400- Advertising' and XeroCode='400' and CompanyId=@subCompanyId and OrganisationId = @organisationId

	--update Common.XeroCOA set OrganisationId=@organisationId, BeanCOAId = (select top 1  Id from Bean.ChartOfAccount where CompanyId=@parentComopanyId and Name='Purchases') where XeroName='300- Purchases' and XeroCode='300' and CompanyId=@subCompanyId and OrganisationId = @organisationId

	--update Common.XeroCOA set OrganisationId=@organisationId, BeanCOAId = (select top 1  Id from Bean.ChartOfAccount where CompanyId=@parentComopanyId and Name='Revenue') where XeroName='200- Sales' and XeroCode='200' and CompanyId=@subCompanyId and OrganisationId = @organisationId

	--update Common.XeroCOA set OrganisationId=@organisationId, BeanCOAId = (select top 1  Id from Bean.ChartOfAccount where CompanyId=@parentComopanyId and Name='Retained earnings') where XeroName='960- Retained Earnings' and XeroCode='960' and CompanyId=@subCompanyId and OrganisationId = @organisationId

	--update Common.XeroCOA set OrganisationId=@organisationId, BeanCOAId = (select top 1  Id from Bean.ChartOfAccount where CompanyId=@parentComopanyId and Name='Share capital') where XeroName='970- Owner A Share Capital' and XeroCode='970' and CompanyId=@subCompanyId and OrganisationId = @organisationId

	--update Common.XeroCOA set OrganisationId=@organisationId, BeanCOAId = (select top 1  Id from Bean.ChartOfAccount where CompanyId=@parentComopanyId and Name='Provision for taxation') where XeroName='830- Income Tax Payable' and XeroCode='830' and CompanyId=@subCompanyId and OrganisationId = @organisationId

	--update Common.XeroCOA set OrganisationId=@organisationId, BeanCOAId = (select top 1  Id from Bean.ChartOfAccount where CompanyId=@parentComopanyId and Name='Tax payable (GST)') where XeroName='820- Sales Tax' and XeroCode='820' and CompanyId=@subCompanyId and OrganisationId = @organisationId

	--update Common.XeroCOA set OrganisationId=@organisationId, BeanCOAId = (select top 1  Id from Bean.ChartOfAccount where CompanyId=@parentComopanyId and Name='Trade payables') where XeroName='800- Accounts Payable' and XeroCode='800' and CompanyId=@subCompanyId and OrganisationId = @organisationId

	--update Common.XeroCOA set OrganisationId=@organisationId, BeanCOAId = (select top 1  Id from Bean.ChartOfAccount where CompanyId=@parentComopanyId and Name='Office Equipment - Accum Depn') where XeroName='711- Less Accumulated Depreciation on Office Equipment' and XeroCode='711' and CompanyId=@subCompanyId and OrganisationId = @organisationId

	--update Common.XeroCOA set OrganisationId=@organisationId, BeanCOAId = (select top 1  Id from Bean.ChartOfAccount where CompanyId=@parentComopanyId and Name='Office equipment - Cost') where XeroName='710- Office Equipment' and XeroCode='710' and CompanyId=@subCompanyId and OrganisationId = @organisationId

	--update Common.XeroCOA set OrganisationId=@organisationId, BeanCOAId = (select top 1  Id from Bean.ChartOfAccount where CompanyId=@parentComopanyId and Name='Inventory') where XeroName='630- Inventory' and XeroCode='630' and CompanyId=@subCompanyId and OrganisationId = @organisationId

	--update Common.XeroCOA set OrganisationId=@organisationId, BeanCOAId = (select top 1  Id from Bean.ChartOfAccount where CompanyId=@parentComopanyId and Name='Trade receivables') where XeroName='610- Accounts Receivable' and XeroCode='610' and CompanyId=@subCompanyId and OrganisationId = @organisationId

	--========================= Tax Codes ===============================

	IF NOT EXISTS (select * from Common.XeroTaxCodeDetail where beantaxcodeid = (select top 1  Id from Bean.TaxCode where Name='Deemed Supplies' and Code='DS' and TaxType='Output') AND xerotaxcodeid = (select Id from Common.XeroTaxCodes where XeroTaxName='Deemed Supplies (7.0000)' and XeroTaxRate='7.0000' and XeroTaxType='DSOUTPUT'  and CompanyId=@subCompanyId and OrganisationId = @organisationId))
	BEGIN
	insert into Common.XeroTaxCodeDetail (Id, beantaxcodeid, xerotaxcodeid) values (NEWID(), (select top 1  Id from Bean.TaxCode where Name='Deemed Supplies' and Code='DS' and TaxType='Output'), (select Id from Common.XeroTaxCodes where XeroTaxName='Deemed Supplies (7.0000)' and XeroTaxRate='7.0000' and XeroTaxType='DSOUTPUT'  and CompanyId=@subCompanyId and OrganisationId = @organisationId))
	END

	IF NOT EXISTS(select * from Common.XeroTaxCodeDetail where beantaxcodeid =  (select top 1  Id from Bean.TaxCode where Name='Disallowed Expenses' and Code='BL' and TaxType='Input' and CompanyId=0) AND xerotaxcodeid = (select Id from Common.XeroTaxCodes where XeroTaxName='Disallowed Expenses (0.0000)' and XeroTaxRate='0.0000' and XeroTaxType='BLINPUT2'  and CompanyId=@subCompanyId and OrganisationId = @organisationId))
	BEGIN
	insert into Common.XeroTaxCodeDetail (Id, beantaxcodeid, xerotaxcodeid) values (NEWID(), (select top 1  Id from Bean.TaxCode where Name='Disallowed Expenses' and Code='BL' and TaxType='Input' and CompanyId=0),(select Id from Common.XeroTaxCodes where XeroTaxName='Disallowed Expenses (0.0000)' and XeroTaxRate='0.0000' and XeroTaxType='BLINPUT2'  and CompanyId=@subCompanyId and OrganisationId = @organisationId))
	END

	IF NOT EXISTS (select * from Common.XeroTaxCodeDetail where beantaxcodeid = (select top 1  Id from Bean.TaxCode where Name='Exempt Purchases' and Code='EP' and TaxType='Input') AND xerotaxcodeid = (select Id from Common.XeroTaxCodes where XeroTaxName='Exempt Purchases (0.0000)' and XeroTaxRate='0.0000' and XeroTaxType='EPINPUT'  and CompanyId=@subCompanyId and OrganisationId = @organisationId))
	BEGIN
	insert into Common.XeroTaxCodeDetail (Id, beantaxcodeid, xerotaxcodeid) values (NEWID(), (select top 1  Id from Bean.TaxCode where Name='Exempt Purchases' and Code='EP' and TaxType='Input'), (select Id from Common.XeroTaxCodes where XeroTaxName='Exempt Purchases (0.0000)' and XeroTaxRate='0.0000' and XeroTaxType='EPINPUT'  and CompanyId=@subCompanyId and OrganisationId = @organisationId))
	END

	IF NOT EXISTS (select * from Common.XeroTaxCodeDetail where beantaxcodeid = (select top 1  Id from Bean.TaxCode where Name='Imports' and Code='IM' and TaxType='Input') AND xerotaxcodeid = (select Id from Common.XeroTaxCodes where XeroTaxName='Imports (0.0000)' and XeroTaxRate='0.0000' and XeroTaxType='IMINPUT2'  and CompanyId=@subCompanyId and OrganisationId = @organisationId))
	BEGIN
	insert into Common.XeroTaxCodeDetail (Id, beantaxcodeid, xerotaxcodeid) values (NEWID(), (select top 1  Id from Bean.TaxCode where Name='Imports' and Code='IM' and TaxType='Input'), (select Id from Common.XeroTaxCodes where XeroTaxName='Imports (0.0000)' and XeroTaxRate='0.0000' and XeroTaxType='IMINPUT2'  and CompanyId=@subCompanyId and OrganisationId = @organisationId))
	END

	IF NOT EXISTS (select * from Common.XeroTaxCodeDetail where beantaxcodeid = (select top 1  Id from Bean.TaxCode where Name='Imports under a special scheme' and Code='ME' and TaxType='Input') AND xerotaxcodeid = (select Id from Common.XeroTaxCodes where XeroTaxName='Imports under a Special Scheme (0.0000)' and XeroTaxRate='0.0000' and XeroTaxType='MEINPUT'  and CompanyId=@subCompanyId and OrganisationId = @organisationId))
	BEGIN
	insert into Common.XeroTaxCodeDetail (Id, beantaxcodeid, xerotaxcodeid) values (NEWID(), (select top 1  Id from Bean.TaxCode where Name='Imports under a special scheme' and Code='ME' and TaxType='Input'), (select Id from Common.XeroTaxCodes where XeroTaxName='Imports under a Special Scheme (0.0000)' and XeroTaxRate='0.0000' and XeroTaxType='MEINPUT'  and CompanyId=@subCompanyId and OrganisationId = @organisationId))
	END

	IF NOT EXISTS (select * from Common.XeroTaxCodeDetail where beantaxcodeid = (select top 1  Id from Bean.TaxCode where Name='Imports under Import GST Deferment Scheme' and Code='IGDS' and TaxType='Input') AND xerotaxcodeid = (select Id from Common.XeroTaxCodes where XeroTaxName='Imports under the Import GST Deferment Scheme (0.0000)' and XeroTaxRate='0.0000' and XeroTaxType='IGDSINPUT2'  and CompanyId=@subCompanyId and OrganisationId = @organisationId))
	BEGIN
	insert into Common.XeroTaxCodeDetail (Id, beantaxcodeid, xerotaxcodeid) values (NEWID(), (select top 1  Id from Bean.TaxCode where Name='Imports under Import GST Deferment Scheme' and Code='IGDS' and TaxType='Input'), (select Id from Common.XeroTaxCodes where XeroTaxName='Imports under the Import GST Deferment Scheme (0.0000)' and XeroTaxRate='0.0000' and XeroTaxType='IGDSINPUT2'  and CompanyId=@subCompanyId and OrganisationId = @organisationId))
	END

	IF NOT EXISTS (select * from Common.XeroTaxCodeDetail where beantaxcodeid = (select top 1  Id from Bean.TaxCode where Name='NA' and Code='NA' and TaxType='NA') AND xerotaxcodeid = (select Id from Common.XeroTaxCodes where XeroTaxName='No Tax (0.0000)' and XeroTaxRate='0.0000' and XeroTaxType='NONE'  and CompanyId=@subCompanyId and OrganisationId = @organisationId))
	BEGIN
	insert into Common.XeroTaxCodeDetail (Id, beantaxcodeid, xerotaxcodeid) values (NEWID(), (select top 1  Id from Bean.TaxCode where Name='NA' and Code='NA' and TaxType='NA'), (select Id from Common.XeroTaxCodes where XeroTaxName='No Tax (0.0000)' and XeroTaxRate='0.0000' and XeroTaxType='NONE'  and CompanyId=@subCompanyId and OrganisationId = @organisationId))
	END

	IF NOT EXISTS (select * from Common.XeroTaxCodeDetail where beantaxcodeid = (select top 1  Id from Bean.TaxCode where Name='Non-Regulation 33 Exempt Supplies' and Code='ESN33' and TaxType='Output') AND xerotaxcodeid = (select Id from Common.XeroTaxCodes where XeroTaxName='Non-Regulation 33 Exempt Supplies (0.0000)' and XeroTaxRate='0.0000' and XeroTaxType='ESN33OUTPUT'  and CompanyId=@subCompanyId and OrganisationId = @organisationId))
	BEGIN
	insert into Common.XeroTaxCodeDetail (Id, beantaxcodeid, xerotaxcodeid) values (NEWID(), (select top 1  Id from Bean.TaxCode where Name='Non-Regulation 33 Exempt Supplies' and Code='ESN33' and TaxType='Output'), (select Id from Common.XeroTaxCodes where XeroTaxName='Non-Regulation 33 Exempt Supplies (0.0000)' and XeroTaxRate='0.0000' and XeroTaxType='ESN33OUTPUT'  and CompanyId=@subCompanyId and OrganisationId = @organisationId))
	END

	IF NOT EXISTS (select * from Common.XeroTaxCodeDetail where beantaxcodeid = (select top 1  Id from Bean.TaxCode where Name='Out-of-Scope Purchases' and Code='OP' and TaxType='Input') AND xerotaxcodeid = (select Id from Common.XeroTaxCodes where XeroTaxName='Out Of Scope Purchases (0.0000)' and XeroTaxRate='0.0000' and XeroTaxType='OPINPUT'  and CompanyId=@subCompanyId and OrganisationId = @organisationId))
	BEGIN
	insert into Common.XeroTaxCodeDetail (Id, beantaxcodeid, xerotaxcodeid) values (NEWID(), (select top 1  Id from Bean.TaxCode where Name='Out-of-Scope Purchases' and Code='OP' and TaxType='Input'), (select Id from Common.XeroTaxCodes where XeroTaxName='Out Of Scope Purchases (0.0000)' and XeroTaxRate='0.0000' and XeroTaxType='OPINPUT'  and CompanyId=@subCompanyId and OrganisationId = @organisationId))
	END

	IF NOT EXISTS(select * from Common.XeroTaxCodeDetail where beantaxcodeid =  (select top 1  Id from Bean.TaxCode where Name='Out-of-Scope Supplies' and Code='OS' and TaxType='Output') AND xerotaxcodeid = (select Id from Common.XeroTaxCodes where XeroTaxName='Out Of Scope Supplies (0.0000)' and XeroTaxRate='0.0000' and XeroTaxType='OSOUTPUT'  and CompanyId=@subCompanyId and OrganisationId = @organisationId))
	BEGIN
	insert into Common.XeroTaxCodeDetail (Id, beantaxcodeid, xerotaxcodeid) values (NEWID(), (select top 1  Id from Bean.TaxCode where Name='Out-of-Scope Supplies' and Code='OS' and TaxType='Output'), (select Id from Common.XeroTaxCodes where XeroTaxName='Out Of Scope Supplies (0.0000)' and XeroTaxRate='0.0000' and XeroTaxType='OSOUTPUT'  and CompanyId=@subCompanyId and OrganisationId = @organisationId))
	END

	IF NOT EXISTS (select * from Common.XeroTaxCodeDetail where beantaxcodeid = (select top 1  Id from Bean.TaxCode where Name='Regulation 33 Exempt Supplies' and Code='ES33' and TaxType='Output') AND xerotaxcodeid = (select Id from Common.XeroTaxCodes where XeroTaxName='Regulation 33 Exempt Supplies (0.0000)' and XeroTaxRate='0.0000' and XeroTaxType='ES33OUTPUT'  and CompanyId=@subCompanyId and OrganisationId = @organisationId))
	BEGIN
	insert into Common.XeroTaxCodeDetail (Id, beantaxcodeid, xerotaxcodeid) values (NEWID(), (select top 1  Id from Bean.TaxCode where Name='Regulation 33 Exempt Supplies' and Code='ES33' and TaxType='Output'), (select Id from Common.XeroTaxCodes where XeroTaxName='Regulation 33 Exempt Supplies (0.0000)' and XeroTaxRate='0.0000' and XeroTaxType='ES33OUTPUT'  and CompanyId=@subCompanyId and OrganisationId = @organisationId))
	END

	IF NOT EXISTS (select * from Common.XeroTaxCodeDetail where beantaxcodeid = (select top 1  Id from Bean.TaxCode where Name='Standard-Rated Purchases' and Code='TX' and TaxType='INPUT') AND xerotaxcodeid = (select Id from Common.XeroTaxCodes where XeroTaxName='Standard-Rated Purchases (7.0000)' and XeroTaxRate='7.0000' and XeroTaxType='INPUT'  and CompanyId=@subCompanyId and OrganisationId = @organisationId))
	BEGIN
	insert into Common.XeroTaxCodeDetail (Id, beantaxcodeid, xerotaxcodeid) values (NEWID(), (select top 1  Id from Bean.TaxCode where Name='Standard-Rated Purchases' and Code='TX' and TaxType='INPUT'), (select Id from Common.XeroTaxCodes where XeroTaxName='Standard-Rated Purchases (7.0000)' and XeroTaxRate='7.0000' and XeroTaxType='INPUT'  and CompanyId=@subCompanyId and OrganisationId = @organisationId))
	END

	IF NOT EXISTS (select * from Common.XeroTaxCodeDetail where beantaxcodeid = (select top 1  Id from Bean.TaxCode where Name='Standard-Rated Supplies' and Code='SR' and TaxType='Output') AND xerotaxcodeid = (select Id from Common.XeroTaxCodes where XeroTaxName='Standard-Rated Supplies (7.0000)' and XeroTaxRate='7.0000' and XeroTaxType='OUTPUT'  and CompanyId=@subCompanyId and OrganisationId = @organisationId))
	BEGIN
	insert into Common.XeroTaxCodeDetail (Id, beantaxcodeid, xerotaxcodeid) values (NEWID(), (select top 1  Id from Bean.TaxCode where Name='Standard-Rated Supplies' and Code='SR' and TaxType='Output'), (select Id from Common.XeroTaxCodes where XeroTaxName='Standard-Rated Supplies (7.0000)' and XeroTaxRate='7.0000' and XeroTaxType='OUTPUT'  and CompanyId=@subCompanyId and OrganisationId = @organisationId))
	END

	IF NOT EXISTS  (select * from Common.XeroTaxCodeDetail where beantaxcodeid = (select top 1  Id from Bean.TaxCode where Name='Zero-Rated Purchases' and Code='ZP' and TaxType='INPUT') AND xerotaxcodeid = (select Id from Common.XeroTaxCodes where XeroTaxName='Zero-Rated Purchases (0.0000)' and XeroTaxRate='0.0000' and XeroTaxType='ZERORATEDINPUT'  and CompanyId=@subCompanyId and OrganisationId = @organisationId))
	BEGIN
	insert into Common.XeroTaxCodeDetail (Id, beantaxcodeid, xerotaxcodeid) values (NEWID(), (select top 1  Id from Bean.TaxCode where Name='Zero-Rated Purchases' and Code='ZP' and TaxType='INPUT'), (select Id from Common.XeroTaxCodes where XeroTaxName='Zero-Rated Purchases (0.0000)' and XeroTaxRate='0.0000' and XeroTaxType='ZERORATEDINPUT'  and CompanyId=@subCompanyId and OrganisationId = @organisationId))
	END

	IF NOT EXISTS (select * from Common.XeroTaxCodeDetail where beantaxcodeid = (select top 1  Id from Bean.TaxCode where Name='Zero-Rated Supplies' and Code='ZR' and TaxType='Output') AND xerotaxcodeid = (select Id from Common.XeroTaxCodes where XeroTaxName='Zero-Rated Supplies (0.0000)' and XeroTaxRate='0.0000' and XeroTaxType='ZERORATEDOUTPUT'  and CompanyId=@subCompanyId and OrganisationId = @organisationId))
	BEGIN
	insert into Common.XeroTaxCodeDetail (Id, beantaxcodeid, xerotaxcodeid) values (NEWID(), (select top 1  Id from Bean.TaxCode where Name='Zero-Rated Supplies' and Code='ZR' and TaxType='Output'), (select Id from Common.XeroTaxCodes where XeroTaxName='Zero-Rated Supplies (0.0000)' and XeroTaxRate='0.0000' and XeroTaxType='ZERORATEDOUTPUT'  and CompanyId=@subCompanyId and OrganisationId = @organisationId))
	END

	IF NOT EXISTS (select * from Common.XeroTaxCodeDetail where beantaxcodeid = (select top 1  Id from Bean.TaxCode where Name='Purchases subject to Customer Accounting' and Code='TXCA' and TaxType='INPUT') AND xerotaxcodeid = (select Id from Common.XeroTaxCodes where XeroTaxName='Customer Accounting Purchases (0.0000)' and XeroTaxRate='0.0000' and XeroTaxType='TXCA'  and CompanyId=@subCompanyId and OrganisationId = @organisationId))
	BEGIN
	insert into Common.XeroTaxCodeDetail (Id, beantaxcodeid, xerotaxcodeid) values (NEWID(), (select top 1  Id from Bean.TaxCode where Name='Purchases subject to Customer Accounting' and Code='TXCA' and TaxType='INPUT'), (select Id from Common.XeroTaxCodes where XeroTaxName='Customer Accounting Purchases (0.0000)' and XeroTaxRate='0.0000' and XeroTaxType='TXCA'  and CompanyId=@subCompanyId and OrganisationId = @organisationId))
	END

	IF NOT EXISTS (select * from Common.XeroTaxCodeDetail where beantaxcodeid = (select top 1  Id from Bean.TaxCode where Name='Supplies subject to Customer Accounting' and Code='SRCA-S' and TaxType='OUTPUT') AND xerotaxcodeid = (select Id from Common.XeroTaxCodes where XeroTaxName='Customer Accounting Supplies (0.0000)' and XeroTaxRate='0.0000' and XeroTaxType='SRCAS'  and CompanyId=@subCompanyId and OrganisationId = @organisationId))
	BEGIN
	insert into Common.XeroTaxCodeDetail (Id, beantaxcodeid, xerotaxcodeid) values (NEWID(), (select top 1  Id from Bean.TaxCode where Name='Supplies subject to Customer Accounting' and Code='SRCA-S' and TaxType='OUTPUT'), (select Id from Common.XeroTaxCodes where XeroTaxName='Customer Accounting Supplies (0.0000)' and XeroTaxRate='0.0000' and XeroTaxType='SRCAS'  and CompanyId=@subCompanyId and OrganisationId = @organisationId))
	END

	IF NOT EXISTS (select * from Common.XeroTaxCodeDetail where beantaxcodeid = (select top 1  Id from Bean.TaxCode where Name='Standard rated purchases that are directly attributable to non-regulation 33 exempt supplies' and Code='TX-N33' and TaxType='INPUT') AND xerotaxcodeid = (select Id from Common.XeroTaxCodes where XeroTaxName='Partially Exempt Traders Non-Regulation 33 Exempt (7.0000)' and XeroTaxRate='7.0000' and XeroTaxType='TXN33INPUT'  and CompanyId=@subCompanyId and OrganisationId = @organisationId))
	BEGIN
	insert into Common.XeroTaxCodeDetail (Id, beantaxcodeid, xerotaxcodeid) values (NEWID(), (select top 1  Id from Bean.TaxCode where Name='Standard rated purchases that are directly attributable to non-regulation 33 exempt supplies' and Code='TX-N33' and TaxType='INPUT'), (select Id from Common.XeroTaxCodes where XeroTaxName='Partially Exempt Traders Non-Regulation 33 Exempt (7.0000)' and XeroTaxRate='7.0000' and XeroTaxType='TXN33INPUT'  and CompanyId=@subCompanyId and OrganisationId = @organisationId))
	END

	IF NOT EXISTS (select * from Common.XeroTaxCodeDetail where beantaxcodeid = (select top 1  Id from Bean.TaxCode where Name='Standard rated purchases that are directly attributable to regulation 33 exempt supplies' and Code='TX-ESS' and TaxType='INPUT') AND xerotaxcodeid = (select Id from Common.XeroTaxCodes where XeroTaxName='Partially Exempt Traders Regulation 33 Exempt (7.0000)' and XeroTaxRate='7.0000' and XeroTaxType='TXESSINPUT'  and CompanyId=@subCompanyId and OrganisationId = @organisationId))
	BEGIN
	insert into Common.XeroTaxCodeDetail (Id, beantaxcodeid, xerotaxcodeid) values (NEWID(), (select top 1  Id from Bean.TaxCode where Name='Standard rated purchases that are directly attributable to regulation 33 exempt supplies' and Code='TX-ESS' and TaxType='INPUT'), (select Id from Common.XeroTaxCodes where XeroTaxName='Partially Exempt Traders Regulation 33 Exempt (7.0000)' and XeroTaxRate='7.0000' and XeroTaxType='TXESSINPUT'  and CompanyId=@subCompanyId and OrganisationId = @organisationId))
	END

	IF NOT EXISTS (select * from Common.XeroTaxCodeDetail where beantaxcodeid = (select top 1  Id from Bean.TaxCode where Name='Residual input tax' and Code='TX-RE' and TaxType='INPUT') AND xerotaxcodeid = (select Id from Common.XeroTaxCodes where XeroTaxName='Partially Exempt Traders Residual Input tax (7.0000)' and XeroTaxRate='7.0000' and XeroTaxType='TXREINPUT'  and CompanyId=@subCompanyId and OrganisationId = @organisationId))
	BEGIN
	insert into Common.XeroTaxCodeDetail (Id, beantaxcodeid, xerotaxcodeid) values (NEWID(), (select top 1  Id from Bean.TaxCode where Name='Residual input tax' and Code='TX-RE' and TaxType='INPUT'), (select Id from Common.XeroTaxCodes where XeroTaxName='Partially Exempt Traders Residual Input tax (7.0000)' and XeroTaxRate='7.0000' and XeroTaxType='TXREINPUT'  and CompanyId=@subCompanyId and OrganisationId = @organisationId))
	END

	IF NOT EXISTS (select * from Common.XeroTaxCodeDetail where beantaxcodeid = (select top 1  Id from Bean.TaxCode where Name='Non-GST purchases' and Code='NR' and TaxType='INPUT') AND xerotaxcodeid = (select Id from Common.XeroTaxCodes where XeroTaxName='Purchases from Non-GST Registered Suppliers (0.0000)' and XeroTaxRate='0.0000' and XeroTaxType='NRINPUT'  and CompanyId=@subCompanyId and OrganisationId = @organisationId))
	BEGIN
	insert into Common.XeroTaxCodeDetail (Id, beantaxcodeid, xerotaxcodeid) values (NEWID(), (select top 1  Id from Bean.TaxCode where Name='Non-GST purchases' and Code='NR' and TaxType='INPUT'), (select Id from Common.XeroTaxCodes where XeroTaxName='Purchases from Non-GST Registered Suppliers (0.0000)' and XeroTaxRate='0.0000' and XeroTaxType='NRINPUT'  and CompanyId=@subCompanyId and OrganisationId = @organisationId))
	END

END





























GO
