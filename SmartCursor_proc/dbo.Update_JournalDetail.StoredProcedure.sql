USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[Update_JournalDetail]    Script Date: 16-12-2024 9.20.11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


--Exec [dbo].[Update_JournalDetail] 244


Create Procedure [dbo].[Update_JournalDetail]
@CompanyId Bigint
As
Begin
	-- Invoice
	Update JD Set  JD.DocTaxDebit=Case When Jd.DocDebit Is Not Null Then Invdtl.DocTaxAmount Else 0 End,
					JD.DocTaxCredit=Case When JD.DocCredit Is Not Null Then Invdtl.DocTaxAmount Else 0 End,
					JD.BaseTaxDebit=Case When Jd.BaseDebit Is Not Null Then Invdtl.BaseTaxAmount Else 0 End,
					JD.BaseTaxCredit=Case When Jd.BaseCredit Is Not Null Then Invdtl.BaseTaxAmount Else 0 End
	From Bean.Invoice As Inv
	Inner Join Bean.InvoiceDetail As Invdtl On Invdtl.InvoiceId=Inv.Id
	Inner Join Bean.Journal As J On J.DocumentId=Inv.Id
	Inner join Bean.JournalDetail As JD On JD.JournalId=J.Id And Jd.DocumentDetailId=Invdtl.Id
	Where J.IsGstSettings=1 And J.CompanyId=@CompanyId And JD.IsTax<>1 And JD.DocumentDetailId<>'00000000-0000-0000-0000-000000000000'
	-- CreditNoteApplication
	Update JD Set JD.DocTaxDebit=Case When Jd.DocDebit Is Not Null Then CNAD.TaxAmount Else 0 End,
					JD.DocTaxCredit=Case When JD.DocCredit Is Not Null Then CNAD.TaxAmount Else 0 End,
					JD.BaseTaxDebit=Case When Jd.BaseDebit Is Not Null Then Round((CNAD.TaxAmount * Inv.ExchangeRate),2) Else 0 End,
					JD.BaseTaxCredit=Case When Jd.BaseCredit Is Not Null Then Round((CNAD.TaxAmount * Inv.ExchangeRate),2) Else 0 End
	From Bean.CreditNoteApplication As CNA
	Inner Join Bean.CreditNoteApplicationDetail As CNAD On CNAD.CreditNoteApplicationId=CNA.Id
	Inner Join Bean.Invoice As Inv On Inv.Id=CNA.InvoiceId
	Inner Join Bean.Journal As J On J.DocumentId=CNA.Id
	Inner join Bean.JournalDetail As JD On JD.JournalId=J.Id And Jd.DocumentDetailId=CNAD.Id
	Where J.IsGstSettings=1 And J.CompanyId=@CompanyId And JD.IsTax<>1 And JD.DocumentDetailId<>'00000000-0000-0000-0000-000000000000' And CNA.IsRevExcess=1
	-- CashSale
	Update JD Set JD.DocTaxDebit=Case When Jd.DocDebit Is Not Null Then CSD.DocTaxAmount Else 0 End,
					JD.DocTaxCredit=Case When JD.DocCredit Is Not Null Then CSD.DocTaxAmount Else 0 End,
					JD.BaseTaxDebit=Case When Jd.BaseDebit Is Not Null Then CSD.BaseTaxAmount Else 0 End,
					JD.BaseTaxCredit=Case When Jd.BaseCredit Is Not Null Then CSD.BaseTaxAmount  Else 0 End
	From Bean.CashSale As CS
	Inner Join Bean.CashSaleDetail As CSD On CSD.CashSaleId=CS.Id
	--Inner Join Bean.Invoice As Inv On Inv.Id=CNA.InvoiceId
	Inner Join Bean.Journal As J On J.DocumentId=CS.Id
	Inner join Bean.JournalDetail As JD On JD.JournalId=J.Id And Jd.DocumentDetailId=CSD.Id
	Where J.IsGstSettings=1 And J.CompanyId=@CompanyId And JD.IsTax<>1 And JD.DocumentDetailId<>'00000000-0000-0000-0000-000000000000'
	-- DebitNote
	Update JD Set JD.DocTaxDebit=Case When Jd.DocDebit Is Not Null Then DND.DocTaxAmount Else 0 End,
					JD.DocTaxCredit=Case When JD.DocCredit Is Not Null Then DND.DocTaxAmount Else 0 End ,
					JD.BaseTaxDebit=Case When Jd.BaseDebit Is Not Null Then DND.BaseTaxAmount Else 0 End ,
					JD.BaseTaxCredit=Case When Jd.BaseCredit Is Not Null Then DND.BaseTaxAmount  Else 0 End
	From Bean.DebitNote As DN
	Inner Join Bean.DebitNoteDetail As DND On DND.DebitNoteId=DN.Id
	--Inner Join Bean.Invoice As Inv On Inv.Id=CNA.InvoiceId
	Inner Join Bean.Journal As J On J.DocumentId=DN.Id
	Inner join Bean.JournalDetail As JD On JD.JournalId=J.Id And Jd.DocumentDetailId=DND.Id
	Where J.IsGstSettings=1 And J.CompanyId=@CompanyId And JD.IsTax<>1 And JD.DocumentDetailId<>'00000000-0000-0000-0000-000000000000'
	-- RecieptBalancingItem
	Update JD Set JD.DocTaxDebit=Case When Jd.DocDebit Is Not Null Then RBI.DocTaxAmount Else 0 End,
			JD.DocTaxCredit=Case When JD.DocCredit Is Not Null Then RBI.DocTaxAmount Else 0 End,
			JD.BaseTaxDebit=Case When Jd.BaseDebit Is Not Null Then Round((RBI.DocTaxAmount * R.ExchangeRate),2) Else 0 End,
			JD.BaseTaxCredit=Case When Jd.BaseCredit Is Not Null Then Round((RBI.DocTaxAmount * R.ExchangeRate),2) Else 0 End
	From Bean.ReceiptBalancingItem As RBI
	Inner Join Bean.Receipt As R On R.Id=RBI.ReceiptId
	--Inner Join Bean.Invoice As Inv On Inv.Id=CNA.InvoiceId
	Inner Join Bean.Journal As J On J.DocumentId=R.Id
	Inner join Bean.JournalDetail As JD On JD.JournalId=J.Id And Jd.DocumentDetailId=RBI.Id
	Where /*J.IsGstSettings=1 And*/ J.CompanyId=@CompanyId And JD.IsTax<>1 And JD.DocumentDetailId<>'00000000-0000-0000-0000-000000000000' And RBI.TaxId Is Not Null

	--//Vendor
	-- Bill
	Update JD Set  JD.DocTaxDebit=Case When Jd.DocDebit Is Not Null Then BD.DocTaxAmount Else 0 End ,
					JD.DocTaxCredit=Case When JD.DocCredit Is Not Null Then BD.DocTaxAmount Else 0 End ,
					JD.BaseTaxDebit=Case When Jd.BaseDebit Is Not Null Then BD.BaseTaxAmount Else 0 End ,
					JD.BaseTaxCredit=Case When Jd.BaseCredit Is Not Null Then BD.BaseTaxAmount Else 0 End 
	From Bean.Bill As B
	Inner Join Bean.BillDetail As BD On BD.BillId=B.Id
	Inner Join Bean.Journal As J On J.DocumentId=B.Id
	Inner join Bean.JournalDetail As JD On JD.JournalId=J.Id And Jd.DocumentDetailId=BD.Id
	Where J.IsGstSettings=1 And J.CompanyId=@CompanyId And JD.IsTax<>1 And JD.DocumentDetailId<>'00000000-0000-0000-0000-000000000000'

	-- WithDrawl
	Update JD Set JD.DocTaxDebit=Case When Jd.DocDebit Is Not Null Then WD.DocTaxAmount Else 0 End,
					JD.DocTaxCredit=Case When JD.DocCredit Is Not Null Then WD.DocTaxAmount Else 0 End,
					JD.BaseTaxDebit=Case When Jd.BaseDebit Is Not Null Then WD.BaseTaxAmount Else 0 End,
					JD.BaseTaxCredit=Case When Jd.BaseCredit Is Not Null Then WD.BaseTaxAmount Else 0 End
	From Bean.WithDrawal As W
	Inner Join Bean.WithDrawalDetail As WD On WD.WithdrawalId=W.Id
	Inner Join Bean.Journal As J On J.DocumentId=W.Id
	Inner join Bean.JournalDetail As JD On JD.JournalId=J.Id And Jd.DocumentDetailId=WD.Id
	Where J.IsGstSettings=1 And J.CompanyId=@CompanyId And JD.IsTax<>1 And JD.DocumentDetailId<>'00000000-0000-0000-0000-000000000000'

	-- CreditMemo
	Update JD Set JD.DocTaxDebit=Case When Jd.DocDebit Is Not Null Then CMD.DocTaxAmount Else 0 End,
					JD.DocTaxCredit=Case When JD.DocCredit Is Not Null Then CMD.DocTaxAmount Else 0 End,
					JD.BaseTaxDebit=Case When Jd.BaseDebit Is Not Null Then CMD.BaseTaxAmount Else 0 End,
					JD.BaseTaxCredit=Case When Jd.BaseCredit Is Not Null Then CMD.BaseTaxAmount Else 0 End
	From Bean.CreditMemo As CM
	Inner Join Bean.CreditMemoDetail As CMD On CMD.CreditMemoId=CM.Id
	Inner Join Bean.Journal As J On J.DocumentId=CM.Id
	Inner join Bean.JournalDetail As JD On JD.JournalId=J.Id And Jd.DocumentDetailId=CMD.Id
	Where J.IsGstSettings=1 And J.CompanyId=@CompanyId And JD.IsTax<>1 And JD.DocumentDetailId<>'00000000-0000-0000-0000-000000000000'

	-- CreditMemo Application
	Update JD Set JD.DocTaxDebit=Case When Jd.DocDebit Is Not Null Then CMAD.TaxAmount Else 0 End,
					JD.DocTaxCredit=Case When JD.DocCredit Is Not Null Then CMAD.TaxAmount Else 0 End,
					JD.BaseTaxDebit=Case When Jd.BaseDebit Is Not Null Then Round((CMAD.TaxAmount* CM.ExchangeRate),2) Else 0 End,
					JD.BaseTaxCredit=Case When Jd.BaseCredit Is Not Null Then Round((CMAD.TaxAmount* CM.ExchangeRate),2) Else 0 End
	From Bean.CreditMemoApplication As CMA
	Inner Join Bean.CreditMemoApplicationDetail As CMAD On CMAD.CreditMemoApplicationId=CMA.Id
	Inner Join Bean.CreditMemo As CM On CM.Id=CMA.CreditMemoId
	Inner Join Bean.Journal As J On J.DocumentId=CMA.Id
	Inner join Bean.JournalDetail As JD On JD.JournalId=J.Id And Jd.DocumentDetailId=CMAD.Id
	Where J.IsGstSettings=1 And J.CompanyId=@CompanyId And JD.IsTax<>1 And JD.DocumentDetailId<>'00000000-0000-0000-0000-000000000000' And IsRevExcess=1


End
GO
