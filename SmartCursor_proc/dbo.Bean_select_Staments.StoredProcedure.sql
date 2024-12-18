USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[Bean_select_Staments]    Script Date: 16-12-2024 9.20.10 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE Procedure [dbo].[Bean_select_Staments]
AS
BEGIN

-- Exec Bean_select_Staments

SELECT Count(*) ,'Bean.AccountType' FROM Bean.AccountType
WHERE CompanyId in (0,1,10,12,19,136,138,172,239,242,256,258,261)

SELECT Count(*) ,'Bean.BankReconciliation' FROM Bean.BankReconciliation
WHERE CompanyId in (0,1,10,12,19,136,138,172,239,242,256,258,261)

SELECT Count(*) ,'Bean.BankReconciliationDetail' FROM Bean.BankReconciliationDetail BRD
Inner JOin Bean.BankReconciliation BRC ON BRC.Id=BRD.BankReconciliationId
WHERE BRC.CompanyId in (0,1,10,12,19,136,138,172,239,242,256,258,261)

select Count(*) ,'Bean.BankReconciliationSetting' from Bean.BankReconciliationSetting
WHERE CompanyId in (0,1,10,12,19,136,138,172,239,242,256,258,261)

select  Count(*) ,'Bean.BankTransfer'  from Bean.BankTransfer
WHERE CompanyId in (0,1,10,12,19,136,138,172,239,242,256,258,261)


select  Count(*) ,'Bean.BankTransferDetail' from Bean.BankTransferDetail BTD
INNER JOIN  Bean.BankTransfer  BT ON BT.id=BTD.BankTransferId
WHERE BT.CompanyId in (0,1,10,12,19,136,138,172,239,242,256,258,261)

select  Count(*) ,'Bean.Bill' from Bean.Bill
WHERE CompanyId in (0,1,10,12,19,136,138,172,239,242,256,258,261)

select  Count(*) ,'Bean.BillCreditMemo' from Bean.BillCreditMemo
WHERE CompanyId in (0,1,10,12,19,136,138,172,239,242,256,258,261)

select  Count(*) ,'Bean.BillCreditMemoDetail' from Bean.BillCreditMemoDetail BCMD
INNER JOIN Bean.BillCreditMemo BCM ON BCM.id=BCMD.CreditMemoId
WHERE BCM.CompanyId in (0,1,10,12,19,136,138,172,239,242,256,258,261)

select  Count(*) ,'Bean.BillCreditMemoGSTDetails' from Bean.BillCreditMemoGSTDetails BCMG
INNER JOIN Bean.BillCreditMemo BCM ON BCM.id=BCMG.CreditMemoId
WHERE BCM.CompanyId in (0,1,10,12,19,136,138,172,239,242,256,258,261)

select  Count(*) ,'Bean.BillDetail' from Bean.BillDetail BD
INNER JOIN Bean.Bill B ON B.Id=BD.BillId
WHERE B.CompanyId in (0,1,10,12,19,136,138,172,239,242,256,258,261)


select  Count(*) ,'Bean.BillGSTDetail' from Bean.BillGSTDetail  BGD
INNER JOIN Bean.Bill B ON B.Id=BGD.BillId
WHERE B.CompanyId in (0,1,10,12,19,136,138,172,239,242,256,258,261)


select  Count(*) ,'Bean.CashSale' from Bean.CashSale CS
WHERE CS.CompanyId in (0,1,10,12,19,136,138,172,239,242,256,258,261)


select  Count(*) ,'Bean.CashSaleDetail' from Bean.CashSaleDetail CSD
INNER JOIN Bean.CashSale CS ON CS.id=CSD.CashSaleId
WHERE CS.CompanyId in (0,1,10,12,19,136,138,172,239,242,256,258,261)

select  Count(*) ,'Bean.Category' from Bean.Category C
WHERE C.CompanyId in (0,1,10,12,19,136,138,172,239,242,256,258,261)

select  Count(*) ,'Bean.ChartOfAccount' from Bean.ChartOfAccount CA
WHERE CA.CompanyId in (0,1,10,12,19,136,138,172,239,242,256,258,261)

select  Count(*) ,'Bean.CreditMemo' from Bean.CreditMemo CM
WHERE CM.CompanyId in (0,1,10,12,19,136,138,172,239,242,256,258,261)

select  Count(*) ,'Bean.CreditMemoApplication' from Bean.CreditMemoApplication CMA
WHERE CMA.CompanyId in (0,1,10,12,19,136,138,172,239,242,256,258,261)

select  Count(*) ,'Bean.CreditMemoApplicationDetail' from Bean.CreditMemoApplicationDetail CMAD
INNER JOIN Bean.CreditMemoApplication CMA ON CMA.Id=CMAD.CreditMemoApplicationId
WHERE CMA.CompanyId in (0,1,10,12,19,136,138,172,239,242,256,258,261)

select  Count(*) ,'Bean.CreditMemoDetail' from Bean.CreditMemoDetail CMAD
INNER JOIN Bean.ChartOfAccount CA ON  CA.Id=CMAD.COAId
WHERE CA.CompanyId in (0,1,10,12,19,136,138,172,239,242,256,258,261)

select  Count(*) ,'Bean.CreditNoteApplication' from Bean.CreditNoteApplication CNA
WHERE CNA.CompanyId in (0,1,10,12,19,136,138,172,239,242,256,258,261)

select  Count(*) ,'Bean.CreditNoteApplicationDetail' from Bean.CreditNoteApplicationDetail CNAD
INNER JOIN Bean.CreditNoteApplication CNA ON CNA.id=CNAD.CreditNoteApplicationId
WHERE CNA.CompanyId in (0,1,10,12,19,136,138,172,239,242,256,258,261)

select  Count(*) ,'Bean.Currency' from Bean.Currency C
WHERE C.CompanyId in (0,1,10,12,19,136,138,172,239,242,256,258,261)

select  Count(*) ,'Bean.DebitNote' from Bean.DebitNote D
WHERE D.CompanyId in (0,1,10,12,19,136,138,172,239,242,256,258,261)

select  Count(*) ,'Bean.DebitNoteDetail' from Bean.DebitNoteDetail DND
INNER JOIN Bean.DebitNote DN ON DN.Id=DND.DebitNoteId
WHERE DN.CompanyId in (0,1,10,12,19,136,138,172,239,242,256,258,261)  

select  Count(*) ,'Bean.DebitNoteGSTDetail' from Bean.DebitNoteGSTDetail DND
INNER JOIN Bean.DebitNote DN ON DN.Id=DND.DebitNoteId
WHERE DN.CompanyId in (0,1,10,12,19,136,138,172,239,242,256,258,261)  

select  Count(*) ,'Bean.DebitNoteNote' from Bean.DebitNoteNote DNN
INNER JOIN Bean.DebitNote DN ON DN.Id=DNN.DebitNoteId
WHERE DN.CompanyId in (0,1,10,12,19,136,138,172,239,242,256,258,261)

select  Count(*) ,'Bean.DocumentRecurrence' from Bean.DocumentRecurrence 
WHERE CompanyId in (0,1,10,12,19,136,138,172,239,242,256,258,261)  

select  Count(*) ,'Bean.DoubtfulDebtAllocation' from Bean.DoubtfulDebtAllocation 
WHERE CompanyId in (0,1,10,12,19,136,138,172,239,242,256,258,261)


select  Count(*) ,'Bean.DoubtfulDebtAllocationDetail' from Bean.DoubtfulDebtAllocationDetail DDAD
INNER JOIN Bean.DoubtfulDebtAllocation DDA ON DDA.Id=DDAD.DoubtfulDebtAllocationId
WHERE DDA.CompanyId in (0,1,10,12,19,136,138,172,239,242,256,258,261)  


select  Count(*) ,'Bean.Entity' from Bean.Entity E
WHERE E.CompanyId in (0,1,10,12,19,136,138,172,239,242,256,258,261)   

select  Count(*) ,'Bean.FinancialSetting' from Bean.FinancialSetting FS
WHERE FS.CompanyId in (0,1,10,12,19,136,138,172,239,242,256,258,261) 

select  Count(*) ,'Bean.Forex' from Bean.Forex F
WHERE F.CompanyId in (0,1,10,12,19,136,138,172,239,242,256,258,261)    

select  Count(*) ,'Bean.GLClearing' from Bean.GLClearing GlC
WHERE GlC.CompanyId in (0,1,10,12,19,136,138,172,239,242,256,258,261) 

select  Count(*) ,'Bean.GLClearingDetail' from Bean.GLClearingDetail GlCD
Inner join Bean.GLClearing GlC ON GlC.id=GlCD.GLClearingId
WHERE GlC.CompanyId in (0,1,10,12,19,136,138,172,239,242,256,258,261)          

select  Count(*) ,'Bean.Invoice' from Bean.Invoice I
WHERE I.CompanyId in (0,1,10,12,19,136,138,172,239,242,256,258,261) 

select  Count(*) ,'Bean.InvoiceDetail' from Bean.InvoiceDetail ID
INNER JOIN Bean.Invoice I ON I.id=id.InvoiceId
WHERE I.CompanyId in (0,1,10,12,19,136,138,172,239,242,256,258,261)    

select  Count(*) ,'Bean.InvoiceGSTDetail' from Bean.InvoiceGSTDetail IGD
INNER JOIN Bean.Invoice I ON I.id=IGD.InvoiceId
WHERE I.CompanyId in (0,1,10,12,19,136,138,172,239,242,256,258,261)

select  Count(*) ,'Bean.InvoiceNote' from Bean.InvoiceNote N
INNER JOIN Bean.Invoice I ON I.id=N.InvoiceId
WHERE I.CompanyId in (0,1,10,12,19,136,138,172,239,242,256,258,261)

select  Count(*) ,'Bean.Item' from Bean.Item I
WHERE I.CompanyId in (0,1,10,12,19,136,138,172,239,242,256,258,261)

select  Count(*) ,'Bean.Journal' from Bean.Journal J
WHERE J.CompanyId in (0,1,10,12,19,136,138,172,239,242,256,258,261)

select  Count(*) ,'Bean.JournalDetail' from Bean.JournalDetail JD
INNER JOIN Bean.Journal J ON J.id=JD.JournalId
WHERE J.CompanyId in (0,1,10,12,19,136,138,172,239,242,256,258,261)

select  Count(*) ,'Bean.JournalGSTDetail' from Bean.JournalGSTDetail JGD
INNER JOIN Bean.Journal J ON J.id=JGD.JournalId
WHERE J.CompanyId in (0,1,10,12,19,136,138,172,239,242,256,258,261)

select  Count(*) ,'Bean.JournalHistory' from Bean.JournalHistory JH
INNER JOIN Bean.Journal J ON J.id=JH.JournalId
WHERE J.CompanyId in (0,1,10,12,19,136,138,172,239,242,256,258,261)

select  Count(*) ,'Bean.JournalLedger' from Bean.JournalLedger JL
WHERE JL.CompanyId in (0,1,10,12,19,136,138,172,239,242,256,258,261)

--select  Count(*) ,'Bean.JournalLedger' from Bean.JvActivityLog JL
--WHERE JL.CompanyId in (0,1,10,12,19,136,138,172,239,242,256,258,261)

select  Count(*) ,'Bean.MultiCurrencySetting' from Bean.MultiCurrencySetting MCS
WHERE MCS.CompanyId in (0,1,10,12,19,136,138,172,239,242,256,258,261)

select  Count(*) ,'Bean.OpeningBalance' from Bean.OpeningBalance OB
WHERE OB.CompanyId in (0,1,10,12,19,136,138,172,239,242,256,258,261)

select  Count(*) ,'Bean.OpeningBalanceDetail' from Bean.OpeningBalanceDetail OBD
INNER JOIN Bean.OpeningBalance OB ON OB.id=OBD.OpeningBalanceId
WHERE OB.CompanyId in (0,1,10,12,19,136,138,172,239,242,256,258,261)

select  Count(*) ,'Bean.OpeningBalanceDetailLineItem' from Bean.OpeningBalanceDetailLineItem OBDL
--Inner join Bean.ChartOfAccount A on A.Id=OBDL.COAId
INNER JOIN Bean.OpeningBalanceDetail OBD ON OBD.Id=OBDL.OpeningBalanceDetailId
INNER JOIN Bean.OpeningBalance OB ON OB.Id=OBD.OpeningBalanceId
WHERE OB.CompanyId in (0,1,10,12,19,136,138,172,239,242,256,258,261)

--select  Count(*) ,'Bean.Order' from Bean.Order 
--WHERE CompanyId in (0,1,10,12,19,136,138,172,239,242,256,258,261)


select  Count(*) ,'Bean.Payment' from Bean.Payment 
WHERE CompanyId in (0,1,10,12,19,136,138,172,239,242,256,258,261)

select  Count(*) ,'Bean.PaymentDetail' from Bean.PaymentDetail  PD
INNER JOIN Bean.Payment P ON p.id=PD.PaymentId
WHERE p.CompanyId in (0,1,10,12,19,136,138,172,239,242,256,258,261)

select  Count(*) ,'Bean.Provision' from Bean.Provision  
WHERE CompanyId in (0,1,10,12,19,136,138,172,239,242,256,258,261)

select  Count(*) ,'Bean.Receipt' from Bean.Receipt  
WHERE CompanyId in (0,1,10,12,19,136,138,172,239,242,256,258,261)


select  Count(*) ,'Bean.ReceiptBalancingItem' from Bean.ReceiptBalancingItem  RB
INNER JOIN Bean.Receipt  R ON R.id=RB.ReceiptId
WHERE R.CompanyId in (0,1,10,12,19,136,138,172,239,242,256,258,261)

select  Count(*) ,'Bean.ReceiptDetail' from Bean.ReceiptDetail  RD
INNER JOIN Bean.Receipt  R ON R.id=RD.ReceiptId
WHERE R.CompanyId in (0,1,10,12,19,136,138,172,239,242,256,258,261)

select  Count(*) ,'Bean.ReceiptGSTDetail' from Bean.ReceiptGSTDetail  RGD
INNER JOIN Bean.Receipt  R ON R.id=RGD.ReceiptId
WHERE R.CompanyId in (0,1,10,12,19,136,138,172,239,242,256,258,261)

select  Count(*) ,'Bean.Revalution' from Bean.Revalution  R
WHERE R.CompanyId in (0,1,10,12,19,136,138,172,239,242,256,258,261)

select  Count(*) ,'Bean.RevalutionDetail' from Bean.RevalutionDetail  RD
INNER JOIN Bean.Revalution  R on R.id=RD.RevalutionId
WHERE R.CompanyId in (0,1,10,12,19,136,138,172,239,242,256,258,261)

select  Count(*) ,'Bean.SegmentDetail' from Bean.SegmentDetail  SD
INNER JOIN Bean.SegmentMaster SM ON SM.Id =SD.SegmentMasterId
WHERE SM.CompanyId in (0,1,10,12,19,136,138,172,239,242,256,258,261)

select  Count(*) ,'Bean.SegmentMaster' from Bean.SegmentMaster  SM
WHERE SM.CompanyId in (0,1,10,12,19,136,138,172,239,242,256,258,261)

select  Count(*) ,'Bean.SubCategory' from Bean.SubCategory  
WHERE CompanyId in (0,1,10,12,19,136,138,172,239,242,256,258,261)

select  Count(*) ,'Bean.TaxCode' from Bean.TaxCode  
WHERE CompanyId in (0,1,10,12,19,136,138,172,239,242,256,258,261)

select  Count(*) ,'Bean.WithDrawal' from Bean.WithDrawal  
WHERE CompanyId in (0,1,10,12,19,136,138,172,239,242,256,258,261)

select  Count(*) ,'Bean.WithDrawalDetail' from Bean.WithDrawalDetail WD
 INNER JOIN  Bean.WithDrawal W ON W.id=WD.WithdrawalId
WHERE W.CompanyId in (0,1,10,12,19,136,138,172,239,242,256,258,261)

END
GO
