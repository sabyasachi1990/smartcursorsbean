USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[Bean_CustVen_LUs]    Script Date: 16-12-2024 9.20.10 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[Bean_CustVen_LUs]
@companyId bigint,
@isCustomer bit
As
Begin

--Select BE.Name,CE.ShortName 
--	From Bean.Entity BE 
--	JOIN Common.Company CE on CE.ParentId=@companyId
--	Where BE.CompanyId=@companyId
--		And ((@isCustomer =1 and BE.IsCustomer=1) OR ( @isCustomer =0 And BE.IsVendor=1))
--		Order By BE.Name,CE.ShortName
IF @IsCustomer=0
BEGIN
Select * From (
Select BE.Name,CE.ShortName
	From Bean.Journal J
	Inner Join Bean.JournalDetail JD on  J.Id=JD.JournalId 
	Inner Join Bean.Entity BE on JD.EntityId=BE.Id
	JOIN Common.Company CE on CE.ParentId=@companyId
	Where BE.CompanyId=@companyId  --AND J.DocumentState in ('Partial Applied','Not Applied','Not Paid','Partial Paid')
		AND JD.DocType IN ('Bill','Credit Memo','Bill Payment','Cash Payment','Payroll Bill','Payroll Payment')
		--AND J.DocType IN ('Journal')
		 AND (JD.ClearingStatus <> ('Cleared') OR JD.ClearingStatus IS NULL)
		 --AND BE.Name='SKYWALKER NEWMEDIA TECHNOLOGY PTE. LTD. (FKA BLOCKCHAIN NEWMEDIA NETWORK PTE. LTD.)'
		--And ((@isCustomer =1 and BE.IsCustomer=1) OR ( @isCustomer =0 And BE.IsVendor=1))
		--Order By BE.Name,CE.ShortName

	Union All 

	Select BE.Name,CE.ShortName
	From Bean.Bill J
	Inner Join Bean.BillDetail JD on  J.Id=JD.BillId
	Inner Join Bean.Entity BE on J.EntityId=BE.Id
	JOIN Common.Company CE on CE.ParentId=@companyId
	Where BE.CompanyId=@companyId  --AND J.DocumentState in ('Partial Applied','Not Applied','Not Paid','Partial Paid')
		AND J.DocType IN ('Bill') AND J.DocSubType IN ('Opening Bal')
		--AND J.DocType IN ('Journal')
		 --AND (JD.ClearingStatus <> ('Cleared') OR JD.ClearingStatus IS NULL)
		 --AND BE.Name='SKYWALKER NEWMEDIA TECHNOLOGY PTE. LTD. (FKA BLOCKCHAIN NEWMEDIA NETWORK PTE. LTD.)'
		--And ((@isCustomer =1 and BE.IsCustomer=1) OR ( @isCustomer =0 And BE.IsVendor=1))
		--Order By BE.Name,CE.ShortName

		Union All 

	Select BE.Name,CE.ShortName
	From Bean.CreditMemo J
	Inner Join Bean.CreditMemoDetail JD on  J.Id=JD.CreditMemoId
	Inner Join Bean.Entity BE on J.EntityId=BE.Id
	JOIN Common.Company CE on CE.ParentId=@companyId
	Where BE.CompanyId=@companyId  --AND J.DocumentState in ('Partial Applied','Not Applied','Not Paid','Partial Paid')
		AND J.DocType IN ('Credit Memo') AND J.DocSubType IN ('Opening Bal')
		--AND J.DocType IN ('Journal')
		 --AND (JD.ClearingStatus <> ('Cleared') OR JD.ClearingStatus IS NULL)
		-- AND BE.Name='SKYWALKER NEWMEDIA TECHNOLOGY PTE. LTD. (FKA BLOCKCHAIN NEWMEDIA NETWORK PTE. LTD.)'
		--And ((@isCustomer =1 and BE.IsCustomer=1) OR ( @isCustomer =0 And BE.IsVendor=1))
		) AS A
		Order By Name,ShortName


		END 

Else 

IF @IsCustomer=1
BEGIN
Select * From (
Select BE.Name,CE.ShortName 
	From Bean.Journal J
	Inner Join Bean.JournalDetail JD on  J.Id=JD.JournalId 
	Inner Join Bean.Entity BE on JD.EntityId=BE.Id
	JOIN Common.Company CE on CE.ParentId=@companyId
	Where BE.CompanyId=@companyId   AND (JD.ClearingStatus <> ('Cleared') or JD.ClearingStatus IS NULL)
		 AND J.DocumentState in ('Partial Applied','Not Applied','Not Paid','Partial Paid')
		 And JD.DocType in ('Invoice','Debit Note','Receipt','Cash Sale','Debt Provision','Credit Note')
		--And ((@isCustomer =1 and BE.IsCustomer=1) OR ( @isCustomer =0 And BE.IsVendor=1))
		--Order By BE.Name,CE.ShortName

Union All 

Select BE.Name,CE.ShortName 
	From Bean.Invoice J
	Inner Join Bean.InvoiceDetail JD on  J.Id=JD.InvoiceId 
	Inner Join Bean.Entity BE on J.EntityId=BE.Id
	JOIN Common.Company CE on CE.ParentId=@companyId
	Where BE.CompanyId=@companyId   
		 AND J.DocumentState in ('Partial Applied','Not Applied','Not Paid','Partial Paid')
		 And J.DocType in ('Invoice','Credit Note') AND J.DocSubType IN ('Opening Bal')
		--And ((@isCustomer =1 and BE.IsCustomer=1) OR ( @isCustomer =0 And BE.IsVendor=1))
		) AS A
		Order By Name,ShortName

		END 


END
GO
