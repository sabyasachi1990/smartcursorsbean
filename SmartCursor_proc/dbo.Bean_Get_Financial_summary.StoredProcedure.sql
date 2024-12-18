USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[Bean_Get_Financial_summary]    Script Date: 16-12-2024 9.20.10 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

--exec Bean_Get_Financial_summary 1917,'9d37c606-d340-4d82-aecd-5ca1f7176e72','bsinfotechsgd@smartcursors.org'

CREATE     Procedure [dbo].[Bean_Get_Financial_summary]
(
@companyId BigInt,
@EntityId uniqueidentifier,
@userName Nvarchar(500)
)
AS 
BEGIN
	
	--//To Get the permission service Entity the user is having
	Declare @serviceEntityIds nvarchar(1000)

	select @serviceEntityIds=COALESCE(@serviceEntityIds + ',', '') + CAST(CUD.ServiceEntityId AS VARCHAR(100)) from Common.Company(nolock) Comp 
	Join Common.CompanyUser(nolock) CU on Comp.ParentId=cu.CompanyId 
	Join Common.CompanyUserDetail(nolock) CUD on CUD.CompanyUserId = CU.Id and CUD.ServiceEntityId=Comp.Id
	Where Comp.ParentId=@companyId and cu.Username=@userName



	Declare @AsOfDate datetime, @ReverseAmount Money
	SET @AsOfDate =GETUTCDATE()
	Set @ReverseAmount=(Select Cast(Round(Sum(Isnull(CAP.CreditAmount,0) * Case When I.ExchangeRate is null OR I.ExchangeRate=0 Then 1 Else I.ExchangeRate End),2) as decimal(18,2)) From Bean.CreditNoteApplication CAP with (nolock)
	Inner Join Bean.Invoice I with (nolock) On I.Id=CAP.InvoiceId
	Where I.CompanyId=@companyId And I.EntityId=@EntityId And CAP.IsRevExcess=1 and CAP.Status=1 And I.ServiceCompanyId in (Select items From dbo.SplitToTable (@serviceEntityIds,',')))
	
	If EXISTS( Select Id from Bean.Entity where CompanyId=@companyId and Id=@EntityId)
	BEGIN
		Select SUM(Billings) Billings, SUM(PaidAmt) PaidAmt, --0 as UnpaidAmt,
		Sum(CreditAmount) as CreditAmount, Sum(GrossBalance) as GrossBalance,sum (DebtProvAmount) as DebtProvAmount,sum(NetBalance) as NetBalance From
		(
		select (firstAmount) as Billings ,(CSAmt+RECAmt+PaymAmt) as PaidAmt, secondAmount as CreditAmount, (firstAmount-secondAmount-(CSAmt+RECAmt+PaymAmt)) as GrossBalance,
		debtAmount as DebtProvAmount, ((firstAmount-secondAmount-(CSAmt+RECAmt+PaymAmt))-debtAmount) as NetBalance
		From 
		(
		Select 
		CASE WHEN J.DocType in ('Invoice','Debit Note','Cash Sale') AND JD.DocumentDetailId='00000000-0000-0000-0000-000000000000' --then 
		Then SUM(Isnull(JD.BaseDebit,0)) Else 0 End as firstAmount,
		--CASE WHEN J.DocType='Credit Note' AND JD.DocumentDetailId='00000000-0000-0000-0000-000000000000' 
		--Then SUM(COALESCE(-JD.DocDebit,JD.DocCredit,0)) Else 0 End as secondAmount,
		0 As secondAmount,
		CASE WHEN J.DocType='Cash Sale' AND JD.DocumentDetailId='00000000-0000-0000-0000-000000000000'
		Then SUM(isnull(JD.BaseDebit,0)) else 0 END as CSAmt,
		CASE WHEN J.DocType='Debt Provision' AND JD.DocumentDetailId='00000000-0000-0000-0000-000000000000' AND COA.Name='Doubtful debt expense'
		Then SUM(COALESCE(JD.BaseDebit,-JD.BaseCredit,0)) else 0 END as debtAmount,
		/*CASE WHEN J.DocType='Receipt' AND COA.Name In ('Trade receivables','Other receivables') 
		Then SUM(isnull(JD.DocCredit,0)) else 0 END*/ 0 as RECAmt,0 as PaymAmt,J.DocType
		
		From Bean.JournalDetail(nolock) JD 
		JOIN Bean.Journal(nolock) J on J.Id=JD.JournalId 
		JOIN Bean.Entity(nolock) E on JD.EntityId=E.Id
		JOIN Bean.ChartOfAccount(nolock) COA On COA.Id=JD.COAId
		Where COA.CompanyId=@CompanyId and Jd.ServiceCompanyId in (Select items From dbo.SplitToTable (@serviceEntityIds,','))
		--AND JD.PostingDate <= @AsOfDate
		AND J.DocType IN ('Invoice','Debit Note','Cash Sale','Receipt','Debt Provision')
		AND J.DocumentState Not In ('Void','Recurring','Parked','Cancelled') AND Jd.EntiTyId=@EntityId
		Group By J.DocumentState,J.DocType,JD.DocumentDetailId,
		--JD.BaseCurrency,JD.DocCurrency
		COA.Name,JD.DocSubType
		
		UNION ALL
		
		Select 
		CASE WHEN I.DocType in ('Invoice') AND I.DocSubType IN ('Opening Bal') 
		THEN I.BaseGrandTotal else 0 End as firstAmount,
		0 as secondAmount,
		0 as CSAmt,
		0 as debtAmount,
		0 as RECAmt,
		0 as PaymAmt,
		I.DocType
		From Bean.Invoice(nolock) I
		Inner Join Bean.InvoiceDetail(nolock) ID ON ID.InvoiceId=I.Id
		JOIN Common.Company(nolock) E On I.CompanyId=E.Id
		JOIN Bean.ChartOfAccount(nolock) COA On COA.Id=ID.COAId
		Where e.Id=@CompanyId and I.ServiceCompanyId in (Select items From dbo.SplitToTable (@serviceEntityIds,','))
		--and I.DocDate <=@AsOfDate
		And I.DocType in ('Invoice') AND I.DocSubType IN ('Opening Bal') AND I.IsOBInvoice = 1 
		AND I.DocumentState Not In ('Void','Recurring','Parked','Cancelled') and I.EntityId=@EntityId

		

		Union ALL
		
		 
        Select 0 As FirstAmount,
		0 as secondAmount,
		0 as CSAmt,
		0 as debtAmount,
		RecieptAmt-CrdAmnt As RECAmt,
		0 As PaymAmt,
		A.DocumentType From 
		(
		Select Case When RD.DocumentType In ('Invoice','Debit Note') Then Round(Sum(Isnull(RD.ReceiptAmount,0) * Case When RD.DocumentType='Invoice' Then I.ExchangeRate Else D.ExchangeRate End),2) Else 0 END As RecieptAmt,
				Case When RD.DocumentType ='Credit Note' Then Round(Sum(Isnull(RD.ReceiptAmount,0) * I.ExchangeRate),2) Else 0 End As CrdAmnt,RD.DocumentType
		From Bean.Receipt(nolock) As R 
		Inner Join Bean.ReceiptDetail(nolock) As RD On RD.ReceiptId=R.Id
		Inner Join Bean.Entity(nolock) As E On E.Id=R.EntityId
		Left Join Bean.Invoice(nolock) As I on I.CompanyId=R.CompanyId and I.DocType In('Invoice','Credit Note') and RD.DocumentId=I.Id and I.DocumentState!='Void' and I.ServiceCompanyId in (Select items From dbo.SplitToTable (@serviceEntityIds,','))
		Left Join Bean.DebitNote(nolock) As D on D.CompanyId=R.CompanyId and RD.DocumentId=D.Id and D.DocumentState!='Void' and D.ServiceCompanyId in (Select items From dbo.SplitToTable (@serviceEntityIds,','))
		Where R.EntityId=@EntityId and R.DocumentState!='Void'
		Group By RD.DocumentType
		) As A

		Union ALL

		Select 0 As FirstAmount,
		0 as secondAmount,
		0 as CSAmt,
		0 as debtAmount,
		0 As RECAmt,
		PaymentAmt-CrdAmnt As PaymAmt,
		P.DocumentType From 
		(
		Select Case When PD.DocumentType In ('Invoice','Debit Note') Then Round(Sum(Isnull(PD.PaymentAmount,0) * Case When Pd.DocumentType='Invoice' Then I.ExchangeRate Else D.ExchangeRate End),2) Else 0 END As PaymentAmt,
				Case When PD.DocumentType ='Credit Note' Then Round(Sum(Isnull(PD.PaymentAmount,0) * I.ExchangeRate),2) Else 0 End As CrdAmnt,PD.DocumentType
		From Bean.Payment(nolock) As P 
		Inner Join Bean.PaymentDetail(nolock) As PD On PD.PaymentId=P.Id
		Inner Join Bean.Entity(nolock) As E On E.Id=P.EntityId
		Left Join Bean.Invoice(nolock) As I on I.CompanyId=P.CompanyId and I.DocType In('Invoice','Credit Note') and Pd.DocumentId=I.Id and I.DocumentState!='Void' and I.ServiceCompanyId in (Select items From dbo.SplitToTable (@serviceEntityIds,','))
		Left Join Bean.DebitNote(nolock) As D on D.CompanyId=P.CompanyId and Pd.DocumentId=D.Id and D.DocumentState!='Void' and D.ServiceCompanyId in (Select items From dbo.SplitToTable (@serviceEntityIds,','))
		Where P.EntityId=@EntityId and P.DocumentState!='Void'
		Group By PD.DocumentType
		) As P
		
		UNION ALL
		
		Select 0 as firstAmount,
		CASE WHEN I.DocType = 'Credit Note' 
		--AND I.DocSubType IN ('Opening Bal','General','Application') 
		THEN Cast(SUM(i.BaseGrandTotal) - isnull(@ReverseAmount,0) as decimal (18,2))
		--Then (Case When i.GrandTotal<>0 and @ReverseAmount<>0 then i.GrandTotal-@ReverseAmount else ISNULL(I.GrandTotal,0) end)
		ELSE 0 End as secondAmount,
		0 as CSAmt,
		0 as debtAmount,
		0 as RECAmt,
		0 as PaymAmt,
		I.DocType
		From Bean.Invoice(nolock) I
		Where I.CompanyId=@CompanyId and I.ServiceCompanyId in (Select items From dbo.SplitToTable (@serviceEntityIds,','))
		And I.DocType in ('Credit Note') AND I.DocumentState Not In ('Void')
		and I.EntityId=@EntityId and i.DocSubType<>'Application'
		Group By i.DocType--,i.BaseGrandTotal
		
		--Case When 
		
		) as P Where (firstAmount)<>0 or (CSAmt+RECAmt+PaymAmt)<>0 or (secondAmount)<>0 or (firstAmount-secondAmount-(CSAmt+RECAmt+PaymAmt))<> 0 or debtAmount <>0 or	((firstAmount-secondAmount-(CSAmt+RECAmt+PaymAmt))-debtAmount)<>0
		) AS S
		
	END

END
GO
