USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[Bean_Cuurency_SP]    Script Date: 16-12-2024 9.20.10 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--exec [Bean_Cuurency_SP]
Create   Procedure [dbo].[Bean_Cuurency_SP]
AS
Begin

Declare   @Temp table (Id bigint,Code nvarchar(10),CompanyId bigint,Name nvarchar(150),Status int)

Insert into @Temp 
Select Id,Code,CompanyId,Name,Status from Bean.Currency Where CompanyId=0 And Code IN (
Select DIstinct Currency From (
--====HR=============
select DIstinct Currency from [HR].[EmployeeDepartment] where Currency is not null and Currency<>'' 
Union All
select DIstinct Currency from   [HR].[EmployeeClaimDetail] where Currency is not null and Currency<>'' 
Union All
select DIstinct CaseDocCurrency AS Currency from   [HR].[EmployeeClaimDetail]
where CaseDocCurrency is not null and CaseDocCurrency<>'' 

Union All
---======Bean-===============--
select Distinct DocCurrency AS Currency from bean.Journal where DocCurrency is not null and DocCurrency<>'' 
Union All
select Distinct ExCurrency AS Currency from bean.Journal where ExCurrency is not null and ExCurrency<>''
---======WOrkFlow===========
Union All
Select Distinct Currency from WorkFlow.CaseGroup where Currency is not null and Currency<>''
--Union All
--Select Distinct BaseCurrency Currency from WorkFlow.CaseGroup where BaseCurrency is not null and BaseCurrency<>''

Union All
Select Distinct Currency from WorkFlow.Invoice where Currency is not null and Currency<>''
--Union All
--Select Distinct BaseCurrency Currency from WorkFlow.Invoice where BaseCurrency is not null and BaseCurrency<>''
--Union All
--Select Distinct TaxCurrency Currency from WorkFlow.Invoice where TaxCurrency is not null and TaxCurrency<>''

--Union All
--Select Distinct DocCurrency Currency from WorkFlow.Incidental where DocCurrency is not null and DocCurrency<>''
--Union All
--Select Distinct TaxCurrency Currency from WorkFlow.Incidental where TaxCurrency is not null and DocCurrency<>''
--Union All
--Select Distinct BaseCurrency Currency from WorkFlow.Incidental where BaseCurrency is not null and DocCurrency<>''

Union All
Select Distinct Currency Currency from WorkFlow.Claim where Currency is not null and Currency<>''
--Union All
--Select Distinct BaseCurrency Currency from WorkFlow.Claim where BaseCurrency is not null and BaseCurrency<>''

--Union All
--Select Distinct BaseCurrency Currency from Common.SOAReminderBatchList where BaseCurrency is not null and BaseCurrency<>''

--Union All
--Select Distinct BaseCurrency Currency from Common.SOAReminderBatchListDetails  where BaseCurrency is not null and BaseCurrency<>''
--Union All
--Select Distinct DocCurrency Currency from Common.SOAReminderBatchListDetails  where DocCurrency is not null and DocCurrency<>''

----Client Cursor

Union All
Select distinct Currency from ClientCursor.Opportunity where Currency is not null and Currency<>''
--Union all
--Select distinct BaseCurrency from ClientCursor.Opportunity where BaseCurrency is not null and BaseCurrency<>''
Union all
Select distinct Currency from ClientCursor.OpportunityHistory where Currency is not null and Currency<>''
--Union all
--Select distinct BaseCurrency from ClientCursor.OpportunityHistory where BaseCurrency is not null and BaseCurrency<>''

)as AA
)
Update @Temp set Status=1 where CompanyId=0
select * from @Temp
--Select * from Bean.Currency where CompanyId=0  and  Status=1 and COde Not in (select Code from @Temp where Status=1 and CompanyId=0)

--update  C set c.status=1 from Bean.Currency C where /*C.CompanyId=0  and */C.Code in (select Code from @Temp where Status=1 and CompanyId=0)

--Delete from Bean.Currency where CompanyId<>0 and code not in (select Code from @Temp where Status=1 and CompanyId=0)

END
GO
