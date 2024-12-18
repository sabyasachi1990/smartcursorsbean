USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[Bean_DocumentHistory_Migration_SP]    Script Date: 16-12-2024 9.20.10 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


--Delete Bean.DocumentHistory Where CompanyId=1
--Exec [dbo].[Bean_DocumentHistory_Migration_SP] 1
CREATE Procedure [dbo].[Bean_DocumentHistory_Migration_SP]
@CompanyId Bigint
As
Begin
	Declare @Count Int 
	Declare @DocumentId Uniqueidentifier
	Declare @CreatedDate DateTime2
	Declare @ModifiedDate DateTime2
	Declare @RecCount Int
	Declare @ErrorMessage Nvarchar(4000)
	Declare @RowCount Int
	Declare @State NVarchar(50)
	Declare @Status Int
	--Declare @AplliedAmount Money

	Begin Transaction
	Begin Try
		IF OBJECT_ID('tempdb..#DocHstr_Migr') IS NOT NULL
		Begin
			Drop Table #DocHstr_Migr
		End
		Create Table #DocHstr_Migr (Sno Int Identity (1,1),DocumentId Uniqueidentifier,CreatedDate DateTime2,ModifiedDate DateTime2,DocState Nvarchar(50))
		--Print 1
		-- Invoice,Credit Note,Debt Provision
		Insert Into #DocHstr_Migr (DocumentId,CreatedDate,ModifiedDate,DocState)
		Select Id,CreatedDate,ModifiedDate,DocumentState From Bean.Invoice Where CompanyId=@CompanyId And Id Not In (Select DocumentId From Bean.DocumentHistory Where CompanyId=@CompanyId)
		Set @RecCount=1
		Select @Count =  COUNT(*) From #DocHstr_Migr
		While @Count>=@RecCount
		Begin
			Select @DocumentId=DocumentId,@CreatedDate=CreatedDate,@ModifiedDate=ModifiedDate,@State=DocState From #DocHstr_Migr Where Sno=@RecCount
			If @ModifiedDate Is Null
			Begin
				Insert Into Bean.DocumentHistory(Id,TransactionId,CompanyId,DocumentId,DocType,DocSubType,DocState,DocCurrency,DocAmount,DocBalanaceAmount,ExchangeRate,BaseAmount,BaseBalanaceAmount,StateChangedBy,StateChangedDate,PostingDate,DocAppliedAmount,BaseAppliedAmount)
				Select NEWID(),I.Id,@CompanyId,I.Id,I.DocType,I.DocSubType,I.DocumentState,I.DocCurrency,Round(I.GrandTotal,2) As DocAmount,Round(I.BalanceAmount,2) As DocBalanceAmount,I.ExchangeRate,Round(I.GrandTotal*Isnull(I.ExchangeRate,1),2) As BaseAmount,Round(I.BalanceAmount*Isnull(I.ExchangeRate,1),2) As BaseBalanceAmount,I.UserCreated,I.CreatedDate,
				Case When I.DocSubType='Opening Bal' Then OB.Date Else I.DocDate End As PostingDate,(ROUND(I.GrandTotal,2)),(ROUND(I.GrandTotal * I.ExchangeRate,2)) 
				From Bean.Invoice I 
				Left Join Bean.OpeningBalance OB ON OB.Id=I.OpeningBalanceId
				Where I.Id=@DocumentId And I.CompanyId=@CompanyId
			End
			Else
			Begin

				If @State='Void'
				Begin
					
					Insert Into Bean.DocumentHistory(Id,TransactionId,CompanyId,DocumentId,DocType,DocSubType,DocState,DocCurrency,DocAmount,DocBalanaceAmount,ExchangeRate,BaseAmount,BaseBalanaceAmount,StateChangedBy,StateChangedDate,PostingDate,DocAppliedAmount,BaseAppliedAmount)
					Select NEWID(),Case When I.DocSubType='Opening Bal' Then OB.Id ELSE I.Id END AS TransactionId,@CompanyId,I.Id,I.DocType,DocSubType,Case When I.DocType='Credit Note' Then 'Not Applied'
																				When I.DocType='Debit provision' Then 'Not Allocated'
																				When I.DocType='Invoice' Then Case When GrandTotal=0.00 Then 'Fully Paid' Else 'Not Paid' End Else DocumentState End As DocumentState,
					DocCurrency,Round(GrandTotal,2) As DocAmount,Round(GrandTotal,2) As DocBalanceAmount,ExchangeRate,Round(GrandTotal*Isnull(ExchangeRate,1),2) As BaseAmount,Round(GrandTotal*Isnull(ExchangeRate,1),2) As BaseBalanceAmount,I.Usercreated,I.CreatedDate,Case When I.DocSubType='Opening Bal' Then OB.Date Else I.DocDate End As PostingDate,(Round(GrandTotal,2)),(Round(GrandTotal * ExchangeRate,2)) 
					From Bean.Invoice I
					Left Join Bean.OpeningBalance OB ON OB.Id=I.OpeningBalanceId
					 Where I.Id=@DocumentId And I.CompanyId=@CompanyId
				
					Insert Into Bean.DocumentHistory(Id,TransactionId,CompanyId,DocumentId,DocType,DocSubType,DocState,DocCurrency,DocAmount,DocBalanaceAmount,ExchangeRate,BaseAmount,BaseBalanaceAmount,StateChangedBy,StateChangedDate,DocAppliedAmount,BaseAppliedAmount)
					Select NEWID(),Id,@CompanyId,Id,DocType,DocSubType,DocumentState,DocCurrency,Round(GrandTotal,2) As DocAmount,Round(BalanceAmount,2) As DocBalanceAmount,ExchangeRate,Round(GrandTotal*Isnull(ExchangeRate,1),2) As BaseAmount,Round(BalanceAmount*Isnull(ExchangeRate,1),2) As BaseBalanceAmount,Coalesce(ModifiedBy,'System'),ModifiedDate,0.00,0.00 
					From Bean.Invoice Where Id=@DocumentId And CompanyId=@CompanyId
				End
				Else
				Begin
					Insert Into Bean.DocumentHistory(Id,TransactionId,CompanyId,DocumentId,DocType,DocSubType,DocState,DocCurrency,DocAmount,DocBalanaceAmount,ExchangeRate,BaseAmount,BaseBalanaceAmount,StateChangedBy,StateChangedDate,PostingDate,DocAppliedAmount,BaseAppliedAmount)
					Select NEWID(),Case When I.DocSubType='Opening Bal' Then OB.Id ELSE I.Id END AS TransactionId,@CompanyId,I.Id,I.DocType,DocSubType,Case When I.DocType='Credit Note' Then 'Not Applied'
																				When I.DocType='Debit provision' Then 'Not Allocated'
																				When I.DocType='Invoice' Then 'Not Paid' END As DocumentState, 
																				--Case When GrandTotal=0.00 Then 'Fully Paid' Else 'Not Paid' End Else DocumentState End As DocumentState,
					DocCurrency,Round(GrandTotal,2) As DocAmount,Round(GrandTotal,2) As DocBalanceAmount,ExchangeRate,Round(GrandTotal*Isnull(ExchangeRate,1),2) As BaseAmount,Round(GrandTotal*Isnull(ExchangeRate,1),2) As BaseBalanceAmount,I.UserCreated,I.CreatedDate,Case When I.DocSubType='Opening Bal' Then OB.Date Else I.DocDate End As PostingDate,(Round(GrandTotal,2)),(Round(GrandTotal * ExchangeRate,2)) 
					From Bean.Invoice I
					Left Join Bean.OpeningBalance OB ON OB.Id=I.OpeningBalanceId
					 Where I.Id=@DocumentId And I.CompanyId=@CompanyId
	

					Insert Into Bean.DocumentHistory(Id,TransactionId,CompanyId,DocumentId,DocType,DocSubType,DocState,DocCurrency,DocAmount,DocBalanaceAmount,
													ExchangeRate,BaseAmount,BaseBalanaceAmount,StateChangedBy,StateChangedDate,PostingDate,DocAppliedAmount,BaseAppliedAmount)
					Select NEWID(),R.Id,@CompanyId,INV.Id,INV.DocType,INV.DocSubType,INV.DocumentState,INV.DocCurrency,Round(INV.GrandTotal,2) As DocAmount,
					Round(INV.BalanceAmount,2) As DocBalanceAmount,INV.ExchangeRate,Round(INV.GrandTotal*Isnull(INV.ExchangeRate,1),2) As BaseAmount,
					Round(INV.BalanceAmount*Isnull(INV.ExchangeRate,1),2) As BaseBalanceAmount,Coalesce(INV.ModifiedBy,'System'),
					Case When R.ModifiedDate Is Null Then R.CreatedDate Else R.ModifiedDate End As StateChangeData,
					Case When R.DocumentState='Void' Then Null Else R.DocDate End,Case When R.DocumentState='Void' Then 0.00 Else -(Round(RD.ReceiptAmount,2)) End As DocRecieptAmount,
					Case When R.DocumentState='Void' Then 0.00 Else -(Round(RD.ReceiptAmount * Inv.Exchangerate,2)) End As BaseRecieptAmount
					From Bean.Invoice As Inv
					Inner Join Bean.ReceiptDetail As RD On RD.DocumentId=Inv.Id
					Inner Join Bean.Receipt As R On R.Id=RD.ReceiptId  Where INV.Id=@DocumentId And INV.CompanyId=@CompanyId And RD.ReceiptAmount <>0 And Inv.DocType<>'Credit Note'

					Insert Into Bean.DocumentHistory(Id,TransactionId,CompanyId,DocumentId,DocType,DocSubType,DocState,DocCurrency,DocAmount,DocBalanaceAmount,
													ExchangeRate,BaseAmount,BaseBalanaceAmount,StateChangedBy,StateChangedDate,PostingDate,DocAppliedAmount,BaseAppliedAmount)
					Select NEWID(),P.Id,@CompanyId,INV.Id,INV.DocType,INV.DocSubType,INV.DocumentState,INV.DocCurrency,Round(INV.GrandTotal,2) As DocAmount,
					Round(INV.BalanceAmount,2) As DocBalanceAmount,INV.ExchangeRate,Round(INV.GrandTotal*Isnull(INV.ExchangeRate,1),2) As BaseAmount,
					Round(INV.BalanceAmount*Isnull(INV.ExchangeRate,1),2) As BaseBalanceAmount,Coalesce(INV.ModifiedBy,'System'),
					Case When P.ModifiedDate Is Null Then P.CreatedDate Else P.ModifiedDate End As StateChangeData,Case When P.DocumentState='Void' Then Null Else P.DocDate End,
					Case When P.DocumentState ='Void' Then 0.00 Else -(Round(PD.PaymentAmount,2)) End As DocPaymnetAmount,
					Case When P.DocumentState ='Void' Then 0.00 Else -(Round(PD.PaymentAmount * INV.ExchangeRate,2)) End As BasePaymnetAmount
					From Bean.Invoice As Inv
					Inner Join Bean.PaymentDetail As PD On PD.DocumentId=Inv.Id
					Inner Join Bean.Payment As P On P.Id=PD.PaymentId  Where INV.Id=@DocumentId And INV.CompanyId=@CompanyId And PD.PaymentAmount <>0 And Inv.DocType<>'Credit Note'

					Insert Into Bean.DocumentHistory(Id,TransactionId,CompanyId,DocumentId,DocType,DocSubType,DocState,DocCurrency,DocAmount,DocBalanaceAmount,
													ExchangeRate,BaseAmount,BaseBalanaceAmount,StateChangedBy,StateChangedDate,PostingDate,DocAppliedAmount,BaseAppliedAmount)
					Select NEWID(),CA.Id,@CompanyId,INV.Id,INV.DocType,INV.DocSubType,INV.DocumentState,INV.DocCurrency,Round(INV.GrandTotal,2) As DocAmount,
					Round(INV.BalanceAmount,2) As DocBalanceAmount,INV.ExchangeRate,Round(INV.GrandTotal*Isnull(INV.ExchangeRate,1),2) As BaseAmount,
					Round(INV.BalanceAmount*Isnull(INV.ExchangeRate,1),2) As BaseBalanceAmount,Coalesce(INV.ModifiedBy,'System'),
					Case When CA.ModifiedDate Is Null Then CA.CreatedDate Else CA.ModifiedDate End As StateChangeData,Case When CA.Status=2 Then Null Else CA.CreditNoteApplicationDate End,
					Case When CA.Status=2 Then 0.00 Else -(Round(CAD.CreditAmount,2)) End As DocCreditAmount,
					Case When CA.Status=2 Then 0.00 Else -(Round(CAD.CreditAmount * INV.ExchangeRate,2)) End As BaseCreditAmount
					From Bean.Invoice As Inv
					Inner Join Bean.CreditNoteApplicationDetail As CAD On CAD.DocumentId=Inv.Id
					Inner Join Bean.CreditNoteApplication As CA On CA.Id=CAD.CreditNoteApplicationId  Where INV.Id=@DocumentId And INV.CompanyId=@CompanyId And CAD.CreditAmount <>0 And Inv.DocType<>'Credit Note'

				End
			End
			Set @RecCount=@RecCount+1
		End
		Truncate Table #DocHstr_Migr
		--Print 2
		-- DebitNote
		Insert Into #DocHstr_Migr (DocumentId,CreatedDate,ModifiedDate,DocState)
		Select Id,CreatedDate,ModifiedDate,DocumentState From Bean.DebitNote Where CompanyId=@CompanyId And Id Not In (Select DocumentId From Bean.DocumentHistory Where CompanyId=@CompanyId)
		Set @RecCount=1
		Select @Count=COUNT(*) From #DocHstr_Migr
		While @Count>=@RecCount
		Begin
			Select @DocumentId=DocumentId,@CreatedDate=CreatedDate,@ModifiedDate=ModifiedDate,@State=DocState From #DocHstr_Migr Where Sno=@RecCount
			If @ModifiedDate Is Null
			Begin
				Insert Into Bean.DocumentHistory(Id,TransactionId,CompanyId,DocumentId,DocType,DocSubType,DocState,DocCurrency,DocAmount,DocBalanaceAmount,ExchangeRate,BaseAmount,BaseBalanaceAmount,StateChangedBy,StateChangedDate,PostingDate,DocAppliedAmount,BaseAppliedAmount)
				Select NEWID(),@DocumentId,@CompanyId,Id,'Debit Note' As DocType,'General' As DocSubType,DocumentState,DocCurrency,Round(GrandTotal,2) As DocAmount,Round(BalanceAmount,2) As DocBalanceAmount,ExchangeRate,Round(GrandTotal*Isnull(ExchangeRate,1),2) As BaseAmount,Round(BalanceAmount * ExchangeRate,2) As BaseBalanceAmount,UserCreated,CreatedDate,DocDate,(ROUND(GrandTotal,2)),(ROUND(GrandTotal * ExchangeRate,2)) From Bean.DebitNote Where Id=@DocumentId And CompanyId=@CompanyId
			End
			Else
			Begin
				If @State='Void'
				Begin
					Insert Into Bean.DocumentHistory(Id,TransactionId,CompanyId,DocumentId,DocType,DocSubType,DocState,DocCurrency,DocAmount,DocBalanaceAmount,ExchangeRate,BaseAmount,BaseBalanaceAmount,StateChangedBy,StateChangedDate,PostingDate,DocAppliedAmount,BaseAppliedAmount)
					Select NEWID(),Id,@CompanyId,Id,'Debit Note' As DocType,'General' As DocSubType,Case When GrandTotal=0.00 Then 'Fully Paid' Else 'Not Paid' End As DocumentState,DocCurrency,Round(GrandTotal,2) As DocAmount,Round(GrandTotal,2) As DocBalanceAmount,ExchangeRate,Round(GrandTotal*Isnull(ExchangeRate,1),2) As BaseAmount,Round(GrandTotal*Isnull(ExchangeRate,1),2) As BaseBalanceAmount,Usercreated,CreatedDate,DocDate,(ROUND(GrandTotal,2)),(ROUND(GrandTotal * ExchangeRate,2)) From Bean.DebitNote Where Id=@DocumentId And CompanyId=@CompanyId
					
					Insert Into Bean.DocumentHistory(Id,TransactionId,CompanyId,DocumentId,DocType,DocSubType,DocState,DocCurrency,DocAmount,DocBalanaceAmount,ExchangeRate,BaseAmount,BaseBalanaceAmount,StateChangedBy,StateChangedDate,DocAppliedAmount,BaseAppliedAmount)
					Select NEWID(),Id,@CompanyId,Id,'Debit Note' As DocType,'General' As DocSubType,DocumentState,DocCurrency,Round(GrandTotal,2) As DocAmount,Round(BalanceAmount,2) As DocBalanceAmount,ExchangeRate,Round(GrandTotal*Isnull(ExchangeRate,1),2) As BaseAmount,Round(BalanceAmount*ExchangeRate,2) As BaseBalanceAmount,Coalesce(ModifiedBy,'System'),ModifiedDate,0.00,0.00 From Bean.DebitNote Where Id=@DocumentId And CompanyId=@CompanyId
				End
				Else
				Begin
					insert Into Bean.DocumentHistory(Id,TransactionId,CompanyId,DocumentId,DocType,DocSubType,DocState,DocCurrency,DocAmount,DocBalanaceAmount,ExchangeRate,BaseAmount,BaseBalanaceAmount,StateChangedBy,StateChangedDate,PostingDate,DocAppliedAmount,BaseAppliedAmount)
					Select NEWID(),Id,@CompanyId,Id,'Debit Note' As DocType,'General' As DocSubType,Case When GrandTotal=0.00 Then 'Fully Paid' Else 'Not Paid' End As DocumentState,DocCurrency,Round(GrandTotal,2) As DocAmount,Round(GrandTotal,2) As DocBalanceAmount,ExchangeRate,Round(GrandTotal*Isnull(ExchangeRate,1),2) As BaseAmount,Round(GrandTotal*Isnull(ExchangeRate,1),2) As BaseBalanceAmount,Usercreated,CreatedDate,DocDate,(ROUND(GrandTotal,2)),(ROUND(GrandTotal * ExchangeRate,2)) From Bean.DebitNote Where Id=@DocumentId And CompanyId=@CompanyId

					Insert Into Bean.DocumentHistory(Id,TransactionId,CompanyId,DocumentId,DocType,DocSubType,DocState,DocCurrency,DocAmount,DocBalanaceAmount,ExchangeRate,BaseAmount,BaseBalanaceAmount,StateChangedBy,StateChangedDate,PostingDate,DocAppliedAmount,BaseAppliedAmount)
					Select NEWID(),R.Id,@CompanyId,DN.Id,'Debit Note' As DocType,'General' As DocSubType,Case When DN.GrandTotal=0.00 Then 'Fully Paid' Else 'Not Paid' End As DocumentState,DN.DocCurrency,Round(DN.GrandTotal,2) As DocAmount,Round(DN.GrandTotal,2) As DocBalanceAmount,DN.ExchangeRate,Round(DN.GrandTotal*Isnull(DN.ExchangeRate,1),2) As BaseAmount,Round(DN.GrandTotal*Isnull(DN.ExchangeRate,1),2) As BaseBalanceAmount,DN.Usercreated,
					Case When R.ModifiedDate Is Null Then R.CreatedDate Else R.ModifiedDate End As StateChangeData,
					Case When R.DocumentState='Void' Then Null Else R.DocDate End,Case When R.DocumentState='Void' Then 0.00 Else -(Round(RD.ReceiptAmount,2)) End As DocRecieptAmount,
					Case When R.DocumentState='Void' Then 0.00 Else -(Round(RD.ReceiptAmount * DN.ExchangeRate,2)) End As BaseRecieptAmount
					From Bean.DebitNote As DN 
					Inner Join Bean.ReceiptDetail As RD On RD.DocumentId=DN.Id
					Inner Join Bean.Receipt As R On R.Id=RD.ReceiptId
					Where DN.Id=@DocumentId And DN.CompanyId=@CompanyId And RD.ReceiptAmount<>0

					Insert Into Bean.DocumentHistory(Id,TransactionId,CompanyId,DocumentId,DocType,DocSubType,DocState,DocCurrency,DocAmount,DocBalanaceAmount,ExchangeRate,BaseAmount,BaseBalanaceAmount,StateChangedBy,StateChangedDate,PostingDate,DocAppliedAmount,BaseAppliedAmount)
					Select NEWID(),P.Id,@CompanyId,DN.Id,'Debit Note' As DocType,'General' As DocSubType,Case When DN.GrandTotal=0.00 Then 'Fully Paid' Else 'Not Paid' End As DocumentState,DN.DocCurrency,Round(DN.GrandTotal,2) As DocAmount,Round(DN.GrandTotal,2) As DocBalanceAmount,DN.ExchangeRate,Round(DN.GrandTotal*Isnull(DN.ExchangeRate,1),2) As BaseAmount,Round(DN.GrandTotal*Isnull(DN.ExchangeRate,1),2) As BaseBalanceAmount,DN.Usercreated,
					Case When P.ModifiedDate Is Null Then P.CreatedDate Else P.ModifiedDate End As StateChangeData,
					Case When P.DocumentState='Void' Then Null Else P.DocDate End,Case When P.DocumentState='Void' Then 0.00 Else -(Round(PD.PaymentAmount,2)) End As DocPaymentAmount,
					Case When P.DocumentState='Void' Then 0.00 Else -(Round(PD.PaymentAmount * DN.ExchangeRate,2)) End As BasePaymentAmount
					From Bean.DebitNote As DN 
					Inner Join Bean.PaymentDetail As PD On PD.DocumentId=DN.Id
					Inner Join Bean.Payment As P On P.Id=PD.PaymentId
					Where DN.Id=@DocumentId And DN.CompanyId=@CompanyId And PD.PaymentAmount<>0

					Insert Into Bean.DocumentHistory(Id,TransactionId,CompanyId,DocumentId,DocType,DocSubType,DocState,DocCurrency,DocAmount,DocBalanaceAmount,ExchangeRate,BaseAmount,BaseBalanaceAmount,StateChangedBy,StateChangedDate,PostingDate,DocAppliedAmount,BaseAppliedAmount)
					Select NEWID(),CA.Id,@CompanyId,DN.Id,'Debit Note' As DocType,'General' As DocSubType,Case When DN.GrandTotal=0.00 Then 'Fully Paid' Else 'Not Paid' End As DocumentState,DN.DocCurrency,Round(DN.GrandTotal,2) As DocAmount,Round(DN.GrandTotal,2) As DocBalanceAmount,DN.ExchangeRate,Round(DN.GrandTotal*Isnull(DN.ExchangeRate,1),2) As BaseAmount,Round(DN.GrandTotal*Isnull(DN.ExchangeRate,1),2) As BaseBalanceAmount,DN.Usercreated,
					Case When CA.ModifiedDate Is Null Then CA.CreatedDate Else CA.ModifiedDate End As StateChangeData,
					Case When CA.Status=2 Then Null Else CA.CreditNoteApplicationDate End,Case When CA.Status=2 Then 0.00 Else -(Round(CAD.CreditAmount,2)) End As DocCreditAmount,
					Case When CA.Status=2 Then 0.00 Else -(Round(CAD.CreditAmount * DN.ExchangeRate,2)) End As BaseCreditAmount
					From Bean.DebitNote As DN 
					Inner Join Bean.CreditNoteApplicationDetail As CAD On CAD.DocumentId=DN.Id
					Inner Join Bean.CreditNoteApplication As CA On CA.Id=CAD.CreditNoteApplicationId
					Where DN.Id=@DocumentId And DN.CompanyId=@CompanyId And CAD.CreditAmount<>0
					
				End
			End
			Set @RecCount=@RecCount+1
		End
		Truncate Table #DocHstr_Migr
		--Print 3
		-- Credit Note Application
		Insert Into #DocHstr_Migr (DocumentId,CreatedDate,ModifiedDate,DocState)
		Select Id,CreatedDate,ModifiedDate,Case When Status=2 Then 'Void' Else 'Not Void' End  From Bean.CreditNoteApplication Where CompanyId=@CompanyId And Id Not In (Select DocumentId From Bean.DocumentHistory Where CompanyId=@CompanyId)
		Set @RecCount=1
		Select @Count=COUNT(*) From #DocHstr_Migr
		While @Count>=@RecCount
		Begin
			Select @DocumentId=DocumentId,@CreatedDate=CreatedDate,@ModifiedDate=ModifiedDate,@State=DocState From #DocHstr_Migr Where Sno=@RecCount
			If @ModifiedDate Is Null
			Begin
				Insert Into Bean.DocumentHistory(Id,TransactionId,CompanyId,DocumentId,DocType,DocSubType,DocState,DocCurrency,DocAmount,DocBalanaceAmount,ExchangeRate,BaseAmount,BaseBalanaceAmount,StateChangedBy,StateChangedDate,PostingDate,DocAppliedAmount,BaseAppliedAmount)
				Select NEWID(),@DocumentId,@CompanyId,CNA.Id,'Credit Note' As DocType,'Application' As DocSubType,Case When CNA.Status=1 Then 'Posted' When CNA.Status=2 Then 'Void' ENd As DocumentState,DocCurrency,Round(CreditAmount,2) As DocAmount,0.00 As DocBalanceAmount,Inv.ExchangeRate,Round(CreditAmount*Inv.ExchangeRate,2) As BaseAmount,0.00 As BaseBalanceAmount,CNA.UserCreated,CNA.CreatedDate,CNA.CreditNoteApplicationDate,(Round(CreditAmount,2)),(Round(CreditAmount * Inv.ExchangeRate,2)) From Bean.CreditNoteApplication As CNA
				Inner Join Bean.Invoice As Inv On Inv.Id=CNA.InvoiceId Where CNA.Id=@DocumentId And CNA.CompanyId=@CompanyId

				Insert Into Bean.DocumentHistory(Id,TransactionId,CompanyId,DocumentId,DocType,DocSubType,DocState,DocCurrency,DocAmount,DocBalanaceAmount,ExchangeRate,BaseAmount,BaseBalanaceAmount,StateChangedBy,StateChangedDate,PostingDate,DocAppliedAmount,BaseAppliedAmount)
				Select NEWID(),CNA.Id,@CompanyId,Inv.Id,'Credit Note' As DocType,Inv.DocSubType As DocSubType,Inv.DocumentState As DocumentState,DocCurrency,Round(CNA.CreditAmount,2) As DocAmount,0.00 As DocBalanceAmount,Inv.ExchangeRate,Round(CNA.CreditAmount*Isnull(Inv.ExchangeRate,1),2) As BaseAmount,0.00 As BaseBalanceAmount,CNA.UserCreated,
				Case When CNA.ModifiedDate Is Null Then CNA.CreatedDate Else CNA.ModifiedDate End,CNA.CreditNoteApplicationDate,-(Round(CreditAmount,2)),-(Round(CreditAmount * Inv.ExchangeRate,2)) 
				From Bean.CreditNoteApplication As CNA 
				Inner Join Bean.Invoice As Inv On Inv.Id=CNA.InvoiceId 
				Where CNA.Id=@DocumentId And CNA.CompanyId=@CompanyId 
			End
			Else
			Begin
				Insert Into Bean.DocumentHistory(Id,TransactionId,CompanyId,DocumentId,DocType,DocSubType,DocState,DocCurrency,DocAmount,DocBalanaceAmount,ExchangeRate,BaseAmount,BaseBalanaceAmount,StateChangedBy,StateChangedDate,PostingDate,DocAppliedAmount,BaseAppliedAmount)
				Select NEWID(),CNA.Id,@CompanyId,CNA.Id,'Credit Note' As DocType,'Application' As DocSubType,'Posted' As DocumentState,DocCurrency,Round(CNA.CreditAmount,2) As DocAmount,0.00 As DocBalanceAmount,Inv.ExchangeRate,Round(CNA.CreditAmount*Isnull(Inv.ExchangeRate,1),2) As BaseAmount,0.00 As BaseBalanceAmount,CNA.UserCreated,CNA.CreatedDate,CNA.CreditNoteApplicationDate,(Round(CreditAmount,2)),(Round(CreditAmount * Inv.ExchangeRate,2)) From Bean.CreditNoteApplication As CNA 
				Inner Join Bean.Invoice As Inv On Inv.Id=CNA.InvoiceId Where CNA.Id=@DocumentId And CNA.CompanyId=@CompanyId

				Insert Into Bean.DocumentHistory(Id,TransactionId,CompanyId,DocumentId,DocType,DocSubType,DocState,DocCurrency,DocAmount,DocBalanaceAmount,ExchangeRate,BaseAmount,BaseBalanaceAmount,StateChangedBy,StateChangedDate,DocAppliedAmount,BaseAppliedAmount)
				Select NEWID(),CNA.Id,@CompanyId,CNA.Id,'Credit Note' As DocType,'Application' As DocSubType,Case When CNA.Status=1 Then 'Posted' When CNA.Status=2 Then 'Void' ENd As DocumentState,DocCurrency,Round(CNA.CreditAmount,2) As DocAmount,0.00 As DocBalanceAmount,INV.ExchangeRate,Round(CNA.CreditAmount*Isnull(Inv.ExchangeRate,1),2) As BaseAmount,0.00 As BaseBalanceAmount,Coalesce(CNA.ModifiedBy,'System'),CNA.ModifiedDate,0.00,0.00 From Bean.CreditNoteApplication As CNA
				Inner Join Bean.Invoice As Inv On Inv.Id=CNA.InvoiceId Where CNA.Id=@DocumentId And CNA.CompanyId=@CompanyId
				If @State<>'Void'
				Begin
					Insert Into Bean.DocumentHistory(Id,TransactionId,CompanyId,DocumentId,DocType,DocSubType,DocState,DocCurrency,DocAmount,DocBalanaceAmount,ExchangeRate,BaseAmount,BaseBalanaceAmount,StateChangedBy,StateChangedDate,PostingDate,DocAppliedAmount,BaseAppliedAmount)
					Select NEWID(),CNA.Id,@CompanyId,Inv.Id,'Credit Note' As DocType,Inv.DocSubType As DocSubType,Inv.DocumentState As DocumentState,DocCurrency,Round(CNA.CreditAmount,2) As DocAmount,0.00 As DocBalanceAmount,Inv.ExchangeRate,Round(CNA.CreditAmount*Isnull(Inv.ExchangeRate,1),2) As BaseAmount,0.00 As BaseBalanceAmount,CNA.UserCreated,
					Case When CNA.ModifiedDate Is Null Then CNA.CreatedDate Else CNA.ModifiedDate End,CNA.CreditNoteApplicationDate,-(Round(CreditAmount,2)),-(Round(CreditAmount * Inv.ExchangeRate,2)) From Bean.CreditNoteApplication As CNA 
					Inner Join Bean.Invoice As Inv On Inv.Id=CNA.InvoiceId 
					Where CNA.Id=@DocumentId And CNA.CompanyId=@CompanyId 
				End
			End
			Set @RecCount=@RecCount+1
		End
		Truncate Table #DocHstr_Migr
		--Print 4
		-- Receipt
		Insert Into #DocHstr_Migr (DocumentId,CreatedDate,ModifiedDate)
		Select Id,CreatedDate,ModifiedDate From Bean.Receipt Where CompanyId=@CompanyId And Id Not In (Select DocumentId From Bean.DocumentHistory Where CompanyId=@CompanyId)
		Set @RecCount=1
		Select @Count=COUNT(*) From #DocHstr_Migr
		While @Count>=@RecCount
		Begin
			Select @DocumentId=DocumentId,@CreatedDate=CreatedDate,@ModifiedDate=ModifiedDate From #DocHstr_Migr Where Sno=@RecCount
			If @ModifiedDate Is Null
			Begin
				Insert Into Bean.DocumentHistory(Id,TransactionId,CompanyId,DocumentId,DocType,DocSubType,DocState,DocCurrency,DocAmount,DocBalanaceAmount,ExchangeRate,BaseAmount,BaseBalanaceAmount,StateChangedBy,StateChangedDate,PostingDate,DocAppliedAmount,BaseAppliedAmount)
				Select NEWID(),Id,@CompanyId,Id,'Receipt' As DocType,'General' As DocSubType,DocumentState,DocCurrency,Round(GrandTotal,2) As DocAmount,0.00 As DocBalanaceAmount,ExchangeRate,Round(GrandTotal*Isnull(ExchangeRate,1),2) As BaseAmount,0.00 As BaseBalanceAmount,UserCreated,CreatedDate,DocDate,(Round(GrandTotal,2)),(Round(GrandTotal * ExchangeRate,2)) From Bean.Receipt Where Id=@DocumentId And CompanyId=@CompanyId
			End
			Else
			Begin
				Insert Into Bean.DocumentHistory(Id,TransactionId,CompanyId,DocumentId,DocType,DocSubType,DocState,DocCurrency,DocAmount,DocBalanaceAmount,ExchangeRate,BaseAmount,BaseBalanaceAmount,StateChangedBy,StateChangedDate,PostingDate,DocAppliedAmount,BaseAppliedAmount)
				Select NEWID(),Id,@CompanyId,Id,'Receipt' As DocType,'General' As DocSubType,'Posted' As DocumentState,DocCurrency,Round(GrandTotal,2) As DocAmount,0.00 As DocBalanaceAmount,ExchangeRate,Round(GrandTotal*Isnull(ExchangeRate,1),2) As BaseAmount,0.00 As DocBalanceAmount,Usercreated,CreatedDate,DocDate,(Round(GrandTotal,2)),(Round(GrandTotal * ExchangeRate,2)) From Bean.Receipt Where Id=@DocumentId And CompanyId=@CompanyId
				
				Insert Into Bean.DocumentHistory(Id,TransactionId,CompanyId,DocumentId,DocType,DocSubType,DocState,DocCurrency,DocAmount,DocBalanaceAmount,ExchangeRate,BaseAmount,BaseBalanaceAmount,StateChangedBy,StateChangedDate,DocAppliedAmount,BaseAppliedAmount)
				Select NEWID(),Id,@CompanyId,Id,'Receipt' As DocType,'General' As DocSubType,DocumentState,DocCurrency,Round(GrandTotal,2) As DocAmount,0.00 As DocBalanceAmount,ExchangeRate,Round(GrandTotal*Isnull(ExchangeRate,1),2) As BaseAmount,0.00 As BaseBalanceAmount,Coalesce(ModifiedBy,'System'),ModifiedDate,0.00,0.00 From Bean.Receipt Where Id=@DocumentId And CompanyId=@CompanyId
			End
			Set @RecCount=@RecCount+1
		End
		Truncate Table #DocHstr_Migr
		--Print 5
		-- Cash Sale
		Insert Into #DocHstr_Migr (DocumentId,CreatedDate,ModifiedDate)
		Select Id,CreatedDate,ModifiedDate From Bean.CashSale Where CompanyId=@CompanyId And Id Not In (Select DocumentId From Bean.DocumentHistory Where CompanyId=@CompanyId)
		Set @RecCount=1
		Select @Count=COUNT(*) From #DocHstr_Migr
		While @Count>=@RecCount
		Begin
			Select @DocumentId=DocumentId,@CreatedDate=CreatedDate,@ModifiedDate=ModifiedDate From #DocHstr_Migr Where Sno=@RecCount
			If @ModifiedDate Is Null
			Begin
				Insert Into Bean.DocumentHistory(Id,TransactionId,CompanyId,DocumentId,DocType,DocSubType,DocState,DocCurrency,DocAmount,DocBalanaceAmount,ExchangeRate,BaseAmount,BaseBalanaceAmount,StateChangedBy,StateChangedDate,PostingDate,DocAppliedAmount,BaseAppliedAmount)
				Select NEWID(),Id,@CompanyId,Id,DocSubType,DocSubType,DocumentState,DocCurrency,Round(GrandTotal,2) As DocAmount,0.00 As DocBalanaceAmount,ExchangeRate,Round(GrandTotal*Isnull(ExchangeRate,1),2) As BaseAmount,0.00 As BaseBalanceAmount,UserCreated,CreatedDate,DocDate,(Round(GrandTotal,2)),(Round(GrandTotal * ExchangeRate,2)) From Bean.CashSale Where Id=@DocumentId And CompanyId=@CompanyId
			End
			Else
			Begin
				Insert Into Bean.DocumentHistory(Id,TransactionId,CompanyId,DocumentId,DocType,DocSubType,DocState,DocCurrency,DocAmount,DocBalanaceAmount,ExchangeRate,BaseAmount,BaseBalanaceAmount,StateChangedBy,StateChangedDate,PostingDate,DocAppliedAmount,BaseAppliedAmount)
				Select NEWID(),Id,@CompanyId,Id,'Cash Sale' As DocType,'General' As DocSubType,'Posted' As DocumentState,DocCurrency,Round(GrandTotal,2) As DocAmount,0.00 As DocBalanaceAmount,ExchangeRate,Round(GrandTotal*Isnull(ExchangeRate,1),2) As BaseAmount,0.00 As DocBalanceAmount,Usercreated,CreatedDate,DocDate,(Round(GrandTotal,2)),(Round(GrandTotal * ExchangeRate,2)) From Bean.CashSale Where Id=@DocumentId And CompanyId=@CompanyId
				
				Insert Into Bean.DocumentHistory(Id,TransactionId,CompanyId,DocumentId,DocType,DocSubType,DocState,DocCurrency,DocAmount,DocBalanaceAmount,ExchangeRate,BaseAmount,BaseBalanaceAmount,StateChangedBy,StateChangedDate,DocAppliedAmount,BaseAppliedAmount)
				Select NEWID(),Id,@CompanyId,Id,'Cash Sale' As DocType,'General' As DocSubType,DocumentState,DocCurrency,Round(GrandTotal,2) As DocAmount,0.00 As DocBalanceAmount,ExchangeRate,Round(GrandTotal*Isnull(ExchangeRate,1),2) As BaseAmount,0.00 As BaseBalanceAmount,Coalesce(ModifiedBy,'System'),ModifiedDate,0.00,0.00 From Bean.CashSale Where Id=@DocumentId And CompanyId=@CompanyId
			End
			Set @RecCount=@RecCount+1
		End
		Truncate Table #DocHstr_Migr
		--Print 6
		-- Debit Provision Allocation
		Insert Into #DocHstr_Migr (DocumentId,CreatedDate,ModifiedDate)
		Select Id,CreatedDate,ModifiedDate From Bean.DoubtfulDebtAllocation Where CompanyId=@CompanyId And Id Not In (Select DocumentId From Bean.DocumentHistory Where CompanyId=@CompanyId)
		Set @RecCount=1
		Select @Count=COUNT(*) From #DocHstr_Migr
		While @Count>=@RecCount
		Begin
			Select @DocumentId=DocumentId,@CreatedDate=CreatedDate,@ModifiedDate=ModifiedDate From #DocHstr_Migr Where Sno=@RecCount
			If @ModifiedDate Is Null
			Begin
				Insert Into Bean.DocumentHistory(Id,TransactionId,CompanyId,DocumentId,DocType,DocSubType,DocState,DocCurrency,DocAmount,DocBalanaceAmount,ExchangeRate,BaseAmount,BaseBalanaceAmount,StateChangedBy,StateChangedDate,PostingDate,DocAppliedAmount,BaseAppliedAmount)
				Select NEWID(),DDA.Id,@CompanyId,DDA.Id,'Debit Provision' As DocType,'Allocation' As DocSubType,Case When DDA.Status=1 Then 'Posted' When DDA.Status=2 Then 'Void' End As DocumentState,DocCurrency,Round(Isnull(DDA.AllocateAmount,0.00),2) As DocAmount,0.00 As DocBalanaceAmount,INV.ExchangeRate,Round(Isnull(DDA.AllocateAmount,0.00)*Isnull(INV.ExchangeRate,1),2) As BaseAmount,0.00 As BaseBalanceAmount,DDA.UserCreated,DDA.CreatedDate,DDA.DoubtfulDebtAllocationDate,(Round(DDA.AllocateAmount,2)),(Round(DDA.AllocateAmount * Inv.ExchangeRate,2)) From Bean.DoubtfulDebtAllocation As DDA
				Inner Join Bean.Invoice As Inv On Inv.Id=DDA.InvoiceId Where DDA.Id=@DocumentId And DDA.CompanyId=@CompanyId
			End
			Else
			Begin
				Insert Into Bean.DocumentHistory(Id,TransactionId,CompanyId,DocumentId,DocType,DocSubType,DocState,DocCurrency,DocAmount,DocBalanaceAmount,ExchangeRate,BaseAmount,BaseBalanaceAmount,StateChangedBy,StateChangedDate,PostingDate,DocAppliedAmount,BaseAppliedAmount)
				Select NEWID(),DDA.Id,@CompanyId,DDA.Id,'Debit Provision' As DocType,'Allocation' As DocSubType,'Posted' As DocumentState,DocCurrency,Round(Isnull(DDA.AllocateAmount,0.00),2) As DocAmount,0.00 As DocBalanaceAmount,Inv.ExchangeRate,Round(Isnull(DDA.AllocateAmount,0.00)*ExchangeRate,2) As BaseAmount,0.00 As DocBalanceAmount,DDA.UserCreated,DDA.CreatedDate,DDA.DoubtfulDebtAllocationDate,(Round(DDA.AllocateAmount,2)),(Round(DDA.AllocateAmount * Inv.ExchangeRate,2)) From Bean.DoubtfulDebtAllocation As DDA
				Inner Join Bean.Invoice As Inv On Inv.Id=DDA.InvoiceId Where DDA.Id=@DocumentId And DDA.CompanyId=@CompanyId
				
				Insert Into Bean.DocumentHistory(Id,TransactionId,CompanyId,DocumentId,DocType,DocSubType,DocState,DocCurrency,DocAmount,DocBalanaceAmount,ExchangeRate,BaseAmount,BaseBalanaceAmount,StateChangedBy,StateChangedDate,DocAppliedAmount,BaseAppliedAmount)
				Select NEWID(),DDA.Id,@CompanyId,DDA.Id,'Debit Provision' As DocType,'Allocation' As DocSubType,Case When DDA.Status=1 Then 'Posted' When DDA.Status=2 Then 'Void' End As DocumentState,DocCurrency,Round(Isnull(DDA.AllocateAmount,0.00),2) As DocAmount,0.00 As DocBalanceAmount,ExchangeRate,Round(Isnull(DDA.AllocateAmount,0.00)*Isnull(INV.ExchangeRate,1),2) As BaseAmount,0.00 As BaseBalanceAmount,Coalesce(DDA.ModifiedBy,'System'),DDA.ModifiedDate,0.00,0.00 From Bean.DoubtfulDebtAllocation As DDA
				Inner Join Bean.Invoice As Inv On Inv.Id=DDA.InvoiceId Where DDA.Id=@DocumentId And DDA.CompanyId=@CompanyId
			End
			Set @RecCount=@RecCount+1
		End
		Truncate Table #DocHstr_Migr
		--Print 7
		-- Journal
		Insert Into #DocHstr_Migr (DocumentId,CreatedDate,ModifiedDate)
		Select Id,CreatedDate,ModifiedDate From Bean.Journal Where CompanyId=@CompanyId And DocType='Journal' And DocSubType Not In ('Opening Bal','Reval') And DocumentState<>'Recurring' And Id Not In (Select DocumentId From Bean.DocumentHistory Where CompanyId=@CompanyId)
		Set @RecCount=1
		Select @Count=COUNT(*) From #DocHstr_Migr
		While @Count>=@RecCount
		Begin
			Select @DocumentId=DocumentId,@CreatedDate=CreatedDate,@ModifiedDate=ModifiedDate From #DocHstr_Migr Where Sno=@RecCount
			If @ModifiedDate Is Null
			Begin
				Insert Into Bean.DocumentHistory(Id,TransactionId,CompanyId,DocumentId,DocType,DocSubType,DocState,DocCurrency,DocAmount,DocBalanaceAmount,ExchangeRate,BaseAmount,BaseBalanaceAmount,StateChangedBy,StateChangedDate,PostingDate)
				Select NEWID(),Id,@CompanyId,Id,DocType,DocSubType,DocumentState,DocCurrency,Round(Isnull(GrandDocDebitTotal,GrandDocCreditTotal),2) As DocAmount,0.00 As DocBalanaceAmount,ExchangeRate,Round(Isnull(GrandDocDebitTotal,GrandDocCreditTotal) * ExchangeRate,2) As BaseAmount,0.00 As BaseBalanceAmount,UserCreated,CreatedDate,PostingDate From Bean.Journal Where Id=@DocumentId And CompanyId=@CompanyId And DocType='Journal'
			End
			Else
			Begin
				Insert Into Bean.DocumentHistory(Id,TransactionId,CompanyId,DocumentId,DocType,DocSubType,DocState,DocCurrency,DocAmount,DocBalanaceAmount,ExchangeRate,BaseAmount,BaseBalanaceAmount,StateChangedBy,StateChangedDate)
				Select NEWID(),Id,@CompanyId,Id,DocType,DocSubType,'Posted' As DocumentState,DocCurrency,Round(Coalesce(GrandDocDebitTotal,GrandDocCreditTotal),2) As DocAmount,0.00 As DocBalanaceAmount,ExchangeRate,Round(Coalesce(GrandDocDebitTotal,GrandDocCreditTotal,0.00) * Isnull(ExchangeRate,1),2) As BaseAmount,0.00 As BaseBalanceAmount,Usercreated,CreatedDate From Bean.Journal Where Id=@DocumentId And CompanyId=@CompanyId And DocType='Journal'
				
				Insert Into Bean.DocumentHistory(Id,TransactionId,CompanyId,DocumentId,DocType,DocSubType,DocState,DocCurrency,DocAmount,DocBalanaceAmount,ExchangeRate,BaseAmount,BaseBalanaceAmount,StateChangedBy,StateChangedDate)
				Select NEWID(),Id,@CompanyId,Id,DocType,DocSubType,DocumentState,DocCurrency,Round(Isnull(GrandDocDebitTotal,GrandDocCreditTotal),2) As DocAmount,0.00 As DocBalanaceAmount,ExchangeRate,Round(coalesce(GrandDocDebitTotal,GrandDocCreditTotal,0.00) * Isnull(ExchangeRate,1),2) As BaseAmount,0.00 As BaseBalanceAmount,Coalesce(ModifiedBy,'System'),ModifiedDate From Bean.Journal Where Id=@DocumentId And CompanyId=@CompanyId And DocType='Journal'
			End
			Set @RecCount=@RecCount+1
		End
		Truncate Table #DocHstr_Migr
		--Print 8
		-- WithDrawal,Deposit,CashPayment
		Insert Into #DocHstr_Migr (DocumentId,CreatedDate,ModifiedDate)
		Select Id,CreatedDate,ModifiedDate From Bean.WithDrawal Where CompanyId=@CompanyId And Id Not In (Select DocumentId From Bean.DocumentHistory Where CompanyId=@CompanyId)
		Set @RecCount=1
		Select @Count=COUNT(*) From #DocHstr_Migr
		While @Count>=@RecCount
		Begin
			Select @DocumentId=DocumentId,@CreatedDate=CreatedDate,@ModifiedDate=ModifiedDate From #DocHstr_Migr Where Sno=@RecCount
			If @ModifiedDate Is Null
			Begin
				Insert Into Bean.DocumentHistory(Id,TransactionId,CompanyId,DocumentId,DocType,DocSubType,DocState,DocCurrency,DocAmount,DocBalanaceAmount,ExchangeRate,BaseAmount,BaseBalanaceAmount,StateChangedBy,StateChangedDate)
				Select NEWID(),Id,@CompanyId,Id,DocType,'General',DocumentState,DocCurrency,GrandTotal As DocAmount,0.00 As DocBalanaceAmount,ExchangeRate,Round(GrandTotal * Isnull(ExchangeRate,1),2) As BaseAmount,0.00 As BaseBalanceAmount,UserCreated,CreatedDate From Bean.WithDrawal Where Id=@DocumentId And CompanyId=@CompanyId
			End
			Else
			Begin
				Insert Into Bean.DocumentHistory(Id,TransactionId,CompanyId,DocumentId,DocType,DocSubType,DocState,DocCurrency,DocAmount,DocBalanaceAmount,ExchangeRate,BaseAmount,BaseBalanaceAmount,StateChangedBy,StateChangedDate)
				Select NEWID(),Id,@CompanyId,Id,DocType,'General','Posted' As DocumentState,DocCurrency,GrandTotal As DocAmount,0.00 As DocBalanaceAmount,ExchangeRate,Round(GrandTotal * Isnull(ExchangeRate,1),2) As BaseAmount,0.00 As BaseBalanceAmount,Usercreated,CreatedDate From Bean.WithDrawal Where Id=@DocumentId And CompanyId=@CompanyId
				
				Insert Into Bean.DocumentHistory(Id,TransactionId,CompanyId,DocumentId,DocType,DocSubType,DocState,DocCurrency,DocAmount,DocBalanaceAmount,ExchangeRate,BaseAmount,BaseBalanaceAmount,StateChangedBy,StateChangedDate)
				Select NEWID(),Id,@CompanyId,Id,DocType,'General',DocumentState,DocCurrency,GrandTotal As DocAmount,0.00 As DocBalanaceAmount,ExchangeRate,Round(GrandTotal * Isnull(ExchangeRate,1),2) As BaseAmount,0.00 As BaseBalanceAmount,Coalesce(ModifiedBy,'System'),ModifiedDate From Bean.WithDrawal Where Id=@DocumentId And CompanyId=@CompanyId
			End
			Set @RecCount=@RecCount+1
		End
		Truncate Table #DocHstr_Migr
		--Print 9
		-- CreditMemo
		Insert Into #DocHstr_Migr (DocumentId,CreatedDate,ModifiedDate)
		Select Id,CreatedDate,ModifiedDate From Bean.CreditMemo Where CompanyId=@CompanyId And Id Not In (Select DocumentId From Bean.DocumentHistory Where CompanyId=@CompanyId)
		Set @RecCount=1
		Select @Count=COUNT(*) From #DocHstr_Migr
		While @Count>=@RecCount
		Begin
			Select @DocumentId=DocumentId,@CreatedDate=CreatedDate,@ModifiedDate=ModifiedDate From #DocHstr_Migr Where Sno=@RecCount
			If @ModifiedDate Is Null
			Begin
				Insert Into Bean.DocumentHistory(Id,TransactionId,CompanyId,DocumentId,DocType,DocSubType,DocState,DocCurrency,DocAmount,DocBalanaceAmount,ExchangeRate,BaseAmount,BaseBalanaceAmount,StateChangedBy,StateChangedDate,PostingDate,DocAppliedAmount,BaseAppliedAmount)
				Select NEWID(),Case When CM.DocSubType='Opening Bal' Then OB.Id ELSE CM.Id END AS TransactionId,@CompanyId,CM.Id,CM.DocType,DocSubType,DocumentState,DocCurrency,Round(GrandTotal,2) As DocAmount,Round(BalanceAmount,2) As DocBalanceAmount,ExchangeRate,Round(GrandTotal*Isnull(ExchangeRate,1),2) As BaseAmount,Round(BalanceAmount*Isnull(ExchangeRate,1),2) As BaseBalanceAmount,CM.UserCreated,CM.CreatedDate,Case When CM.DocSubType='Opening Bal' Then OB.Date Else CM.PostingDate End As PostingDate,Round(GrandTotal,2) As DocAppliedAmount,Round(GrandTotal*Isnull(ExchangeRate,1),2) As BaseAppliedAmount 
				From Bean.CreditMemo CM
				Left Join Bean.OpeningBalance OB ON OB.Id=CM.OpeningBalanceId
				 Where CM.Id=@DocumentId And CM.CompanyId=@CompanyId
			End
			Else
			Begin
				Insert Into Bean.DocumentHistory(Id,TransactionId,CompanyId,DocumentId,DocType,DocSubType,DocState,DocCurrency,DocAmount,DocBalanaceAmount,ExchangeRate,BaseAmount,BaseBalanaceAmount,StateChangedBy,StateChangedDate,PostingDate,DocAppliedAmount,BaseAppliedAmount)
				Select NEWID(),Case When CM.DocSubType='Opening Bal' Then OB.Id ELSE CM.Id END AS TransactionId,@CompanyId,CM.Id,CM.DocType,DocSubType,Case When GrandTotal=0.00 Then 'Fully Applied' Else 'Not Applied' End As DocumentState,DocCurrency,Round(GrandTotal,2) As DocAmount,Round(GrandTotal,2) As DocBalanceAmount,ExchangeRate,Round(GrandTotal*Isnull(ExchangeRate,1),2) As BaseAmount,Round(GrandTotal*ExchangeRate,2) As BaseBalanceAmount,CM.Usercreated,CM.CreatedDate,Case When CM.DocSubType='Opening Bal' Then OB.Date Else CM.PostingDate End As PostingDate,Round(GrandTotal,2) As DocAppliedAmount,Round(GrandTotal*Isnull(ExchangeRate,1),2) As BaseAppliedAmount 
				From Bean.CreditMemo CM
				Left Join Bean.OpeningBalance OB ON OB.Id=CM.OpeningBalanceId
				Where CM.Id=@DocumentId And CM.CompanyId=@CompanyId
				
				Insert Into Bean.DocumentHistory(Id,TransactionId,CompanyId,DocumentId,DocType,DocSubType,DocState,DocCurrency,DocAmount,DocBalanaceAmount,ExchangeRate,BaseAmount,BaseBalanaceAmount,StateChangedBy,StateChangedDate,DocAppliedAmount,BaseAppliedAmount)
				Select NEWID(),Id,@CompanyId,Id,DocType,DocSubType,DocumentState,DocCurrency,Round(GrandTotal,2) As DocAmount,Round(BalanceAmount,2) As DocBalanceAmount,ExchangeRate,Round(GrandTotal*Isnull(ExchangeRate,1),2) As BaseAmount,Round(BalanceAmount*Isnull(ExchangeRate,1),2) As BaseBalanceAmount,Coalesce(ModifiedBy,'System'),ModifiedDate,0.00,0.00 From Bean.CreditMemo Where Id=@DocumentId And CompanyId=@CompanyId
			End
			Set @RecCount=@RecCount+1
		End
		Truncate Table #DocHstr_Migr
		--Print 10
		-- CreditMemo Application
		Insert Into #DocHstr_Migr (DocumentId,CreatedDate,ModifiedDate,DocState)
		Select Id,CreatedDate,ModifiedDate,Case When Status=2 Then 'Void' Else 'Not Void' End From Bean.CreditMemoApplication Where CompanyId=@CompanyId And Id Not In (Select DocumentId From Bean.DocumentHistory Where CompanyId=@CompanyId)
		Set @RecCount=1
		Select @Count=COUNT(*) From #DocHstr_Migr
		While @Count>=@RecCount
		Begin
			Select @DocumentId=DocumentId,@CreatedDate=CreatedDate,@ModifiedDate=ModifiedDate,@State=DocState From #DocHstr_Migr Where Sno=@RecCount
			If @ModifiedDate Is Null
			Begin
				Insert Into Bean.DocumentHistory(Id,TransactionId,CompanyId,DocumentId,DocType,DocSubType,DocState,DocCurrency,DocAmount,DocBalanaceAmount,ExchangeRate,BaseAmount,BaseBalanaceAmount,StateChangedBy,StateChangedDate,PostingDate,DocAppliedAmount,BaseAppliedAmount)
				Select NEWID(),CMA.Id,@CompanyId,CMA.Id,'Credit Memo' As Doctype,'Application' As DocSubType,Case when CMA.Status=1 Then 'Posted' when CMA.Status=2 Then 'Void' End As DocumentState,DocCurrency,Round(CMA.CreditAmount,2) As DocAmount,0.00 As DocBalanceAmount,CM.ExchangeRate,Round(GrandTotal*Isnull(CM.ExchangeRate,1),2) As BaseAmount,Round(BalanceAmount*Isnull(CM.ExchangeRate,1),2) As BaseBalanceAmount,CMA.UserCreated,CMA.CreatedDate,CM.PostingDate,(Round(CM.GrandTotal,2)),(Round(CM.GrandTotal * CM.ExchangeRate,2)) From Bean.CreditMemoApplication As CMA
				Inner Join Bean.CreditMemo As CM On CM.Id=CMA.CreditMemoId Where CMA.Id=@DocumentId And CMA.CompanyId=@CompanyId

				Insert Into Bean.DocumentHistory(Id,TransactionId,CompanyId,DocumentId,DocType,DocSubType,DocState,DocCurrency,DocAmount,DocBalanaceAmount,ExchangeRate,BaseAmount,BaseBalanaceAmount,StateChangedBy,StateChangedDate,PostingDate,DocAppliedAmount,BaseAppliedAmount)
				Select NEWID(),CMA.Id,@CompanyId,CM.Id,'Credit Memo' As Doctype,CM.DocSubType As DocSubType,Case when CMA.Status=1 Then CM.DocumentState when CMA.Status=2 Then 'Void' End  As DocumentState,DocCurrency,Round(CMA.CreditAmount,2) As DocAmount,0.00 As DocBalanceAmount,CM.ExchangeRate,Round(GrandTotal*Isnull(CM.ExchangeRate,1),2) As BaseAmount,0.00 As BaseBalanceAmount,Coalesce(CMA.ModifiedBy,'System'),Case When CMA.ModifiedDate Is Null Then CMA.CreatedDate Else CMA.ModifiedDate End,CMA.CreditMemoApplicationDate,-(ROUND(CMA.CreditAmount,2)),-(ROUND(CMA.CreditAmount * CM.ExchangeRate,2)) From Bean.CreditMemoApplication As CMA
				Inner Join Bean.CreditMemo As CM On CM.Id=CMA.CreditMemoId Where CMA.Id=@DocumentId And CMA.CompanyId=@CompanyId
			End
			Else
			Begin
				Insert Into Bean.DocumentHistory(Id,TransactionId,CompanyId,DocumentId,DocType,DocSubType,DocState,DocCurrency,DocAmount,DocBalanaceAmount,ExchangeRate,BaseAmount,BaseBalanaceAmount,StateChangedBy,StateChangedDate,PostingDate,DocAppliedAmount,BaseAppliedAmount)
				Select NEWID(),CMA.Id,@CompanyId,CMA.Id,'Credit Memo' As Doctype,'Application' As DocSubType,'Posted' As DocumentState,DocCurrency,Round(CMA.CreditAmount,2) As DocAmount,0.00 As DocBalanceAmount,CM.ExchangeRate,Round(CMA.CreditAmount*Isnull(CM.ExchangeRate,1),2) As BaseAmount,0.00 As BaseBalanceAmount,CMA.UserCreated,CMA.CreatedDate,CM.PostingDate,(Round(CM.GrandTotal,2)),(Round(CM.GrandTotal * CM.ExchangeRate,2)) From Bean.CreditMemoApplication As CMA
				Inner Join Bean.CreditMemo As CM On CM.Id=CMA.CreditMemoId Where CMA.Id=@DocumentId And CMA.CompanyId=@CompanyId

				Insert Into Bean.DocumentHistory(Id,TransactionId,CompanyId,DocumentId,DocType,DocSubType,DocState,DocCurrency,DocAmount,DocBalanaceAmount,ExchangeRate,BaseAmount,BaseBalanaceAmount,StateChangedBy,StateChangedDate,DocAppliedAmount,BaseAppliedAmount)
				Select NEWID(),CMA.Id,@CompanyId,CMA.Id,'Credit Memo' As Doctype,'Application' As DocSubType,Case when CMA.Status=1 Then 'Posted' when CMA.Status=2 Then 'Void' End  As DocumentState,DocCurrency,Round(CMA.CreditAmount,2) As DocAmount,0.00 As DocBalanceAmount,CM.ExchangeRate,Round(GrandTotal*Isnull(CM.ExchangeRate,1),2) As BaseAmount,0.00 As BaseBalanceAmount,Coalesce(CMA.ModifiedBy,'System'),CMA.ModifiedDate,0.00,0.00 From Bean.CreditMemoApplication As CMA
				Inner Join Bean.CreditMemo As CM On CM.Id=CMA.CreditMemoId Where CMA.Id=@DocumentId And CMA.CompanyId=@CompanyId
				If @State<>'Void'
				Begin
					Insert Into Bean.DocumentHistory(Id,TransactionId,CompanyId,DocumentId,DocType,DocSubType,DocState,DocCurrency,DocAmount,DocBalanaceAmount,ExchangeRate,BaseAmount,BaseBalanaceAmount,StateChangedBy,StateChangedDate,PostingDate,DocAppliedAmount,BaseAppliedAmount)
					Select NEWID(),CMA.Id,@CompanyId,CM.Id,'Credit Memo' As Doctype,CM.DocSubType As DocSubType,Case when CMA.Status=1 Then CM.DocumentState when CMA.Status=2 Then 'Void' End  As DocumentState,DocCurrency,Round(CMA.CreditAmount,2) As DocAmount,0.00 As DocBalanceAmount,CM.ExchangeRate,Round(GrandTotal*Isnull(CM.ExchangeRate,1),2) As BaseAmount,0.00 As BaseBalanceAmount,Coalesce(CMA.ModifiedBy,'System'),Case When CMA.ModifiedDate Is Null Then CMA.CreatedDate Else CMA.ModifiedDate End,CMA.CreditMemoApplicationDate,-(ROUND(CMA.CreditAmount,2)),-(ROUND(CMA.CreditAmount * CM.ExchangeRate,2)) From Bean.CreditMemoApplication As CMA
					Inner Join Bean.CreditMemo As CM On CM.Id=CMA.CreditMemoId Where CMA.Id=@DocumentId And CMA.CompanyId=@CompanyId
				End
			End
			Set @RecCount=@RecCount+1
		End
		Truncate Table #DocHstr_Migr
		--Print 11
		-- Bill,Payroll Bills
		Insert Into #DocHstr_Migr (DocumentId,CreatedDate,ModifiedDate,DocState)
		Select Id,CreatedDate,ModifiedDate,DocumentState From Bean.Bill Where CompanyId=@CompanyId And Id Not In (Select DocumentId From Bean.DocumentHistory Where CompanyId=@CompanyId)
		Set @RecCount=1
		Select @Count=COUNT(*) From #DocHstr_Migr
		While @Count>=@RecCount
		Begin
			Select @DocumentId=DocumentId,@CreatedDate=CreatedDate,@ModifiedDate=ModifiedDate,@State=DocState From #DocHstr_Migr Where Sno=@RecCount
			If @ModifiedDate Is Null
			Begin
				Insert Into Bean.DocumentHistory(Id,TransactionId,CompanyId,DocumentId,DocType,DocSubType,DocState,DocCurrency,DocAmount,DocBalanaceAmount,ExchangeRate,BaseAmount,BaseBalanaceAmount,StateChangedBy,StateChangedDate,PostingDate,DocAppliedAmount,BaseAppliedAmount)
				Select NEWID(),Id,@CompanyId,Id,DocType,DocSubType,DocumentState,DocCurrency,Round(GrandTotal,2) As DocAmount,Round(BalanceAmount,2) As DocBalanceAmount,ExchangeRate,Round(GrandTotal*Isnull(ExchangeRate,1),2) As BaseAmount,Round(BalanceAmount*ExchangeRate,2) As BaseBalanceAmount,UserCreated,CreatedDate,PostingDate,(Round(GrandTotal,2)),(ROUND(GrandTotal * ExchangeRate,2)) 
				From Bean.Bill B

				Where Id=@DocumentId And CompanyId=@CompanyId
			End
			Else
			Begin
				If @State='Void'
				Begin
					Insert Into Bean.DocumentHistory(Id,TransactionId,CompanyId,DocumentId,DocType,DocSubType,DocState,DocCurrency,DocAmount,DocBalanaceAmount,ExchangeRate,BaseAmount,BaseBalanaceAmount,StateChangedBy,StateChangedDate,PostingDate,DocAppliedAmount,BaseAppliedAmount)
					Select NEWID(),Id,@CompanyId,Id,DocType,DocSubType,Case When GrandTotal=0.00 Then 'Fully Paid' Else 'Not Paid' End As DocumentState,DocCurrency,Round(GrandTotal,2) As DocAmount,Round(GrandTotal,2) As DocBalanceAmount,ExchangeRate,Round(GrandTotal*Isnull(ExchangeRate,1),2) As BaseAmount,Round(GrandTotal*Isnull(ExchangeRate,1),2) As BaseBalanceAmount,Usercreated,CreatedDate,PostingDate,(ROUND(GrandTotal,2)),(ROUND(GrandTotal * ExchangeRate,2)) From Bean.Bill Where Id=@DocumentId And CompanyId=@CompanyId
					
					Insert Into Bean.DocumentHistory(Id,TransactionId,CompanyId,DocumentId,DocType,DocSubType,DocState,DocCurrency,DocAmount,DocBalanaceAmount,ExchangeRate,BaseAmount,BaseBalanaceAmount,StateChangedBy,StateChangedDate,DocAppliedAmount,BaseAppliedAmount)
					Select NEWID(),Id,@CompanyId,Id,DocType,DocSubType,DocumentState,DocCurrency,Round(GrandTotal,2) As DocAmount,Round(BalanceAmount,2) As DocBalanceAmount,ExchangeRate,Round(GrandTotal*Isnull(ExchangeRate,1),2) As BaseAmount,Round(BalanceAmount*Isnull(ExchangeRate,1),2) As BaseBalanceAmount,Coalesce(ModifiedBy,'System'),ModifiedDate,0.00,0.00 From Bean.Bill Where Id=@DocumentId And CompanyId=@CompanyId
				End
				Else
				Begin
					Insert Into Bean.DocumentHistory(Id,TransactionId,CompanyId,DocumentId,DocType,DocSubType,DocState,DocCurrency,DocAmount,DocBalanaceAmount,ExchangeRate,BaseAmount,BaseBalanaceAmount,StateChangedBy,StateChangedDate,PostingDate,DocAppliedAmount,BaseAppliedAmount)
					Select NEWID(),Id,@CompanyId,Id,DocType,DocSubType,Case When GrandTotal=0.00 Then 'Fully Paid' Else 'Not Paid' End As DocumentState,DocCurrency,Round(GrandTotal,2) As DocAmount,Round(GrandTotal,2) As DocBalanceAmount,ExchangeRate,Round(GrandTotal*Isnull(ExchangeRate,1),2) As BaseAmount,Round(GrandTotal*Isnull(ExchangeRate,1),2) As BaseBalanceAmount,Usercreated,CreatedDate,PostingDate,(ROUND(GrandTotal,2)),(ROUND(GrandTotal * ExchangeRate,2)) From Bean.Bill Where Id=@DocumentId And CompanyId=@CompanyId


					Insert Into Bean.DocumentHistory(Id,TransactionId,CompanyId,DocumentId,DocType,DocSubType,DocState,DocCurrency,DocAmount,DocBalanaceAmount,ExchangeRate,BaseAmount,BaseBalanaceAmount,StateChangedBy,StateChangedDate,PostingDate,DocAppliedAmount,BaseAppliedAmount)
					Select NEWID(),R.Id,@CompanyId,B.Id,B.DocType,B.DocSubType,Case When B.GrandTotal=0.00 Then 'Fully Paid' Else 'Not Paid' End As DocumentState,B.DocCurrency,Round(B.GrandTotal,2) As DocAmount,Round(B.GrandTotal,2) As DocBalanceAmount,B.ExchangeRate,Round(B.GrandTotal*Isnull(B.ExchangeRate,1),2) As BaseAmount,Round(B.GrandTotal*Isnull(B.ExchangeRate,1),2) As BaseBalanceAmount,B.Usercreated,
					Case When R.ModifiedDate Is Null Then R.CreatedDate Else R.ModifiedDate End As StateChangeData,
					Case When R.DocumentState='Void' Then Null Else R.DocDate End,Case When R.DocumentState='Void' Then 0.00 Else -(Round(RD.ReceiptAmount,2)) End As DocRecieptAmount,
					Case When R.DocumentState='Void' Then 0.00 Else -(Round(RD.ReceiptAmount * B.ExchangeRate,2)) End As DocRecieptAmount
					From Bean.Bill As B 
					Inner Join Bean.ReceiptDetail As RD On RD.DocumentId=B.Id
					Inner Join Bean.Receipt As R On R.Id=RD.ReceiptId
					Where B.Id=@DocumentId And B.CompanyId=@CompanyId And RD.ReceiptAmount <>0
					--Print 111
					Insert Into Bean.DocumentHistory(Id,TransactionId,CompanyId,DocumentId,DocType,DocSubType,DocState,DocCurrency,DocAmount,DocBalanaceAmount,ExchangeRate,BaseAmount,BaseBalanaceAmount,StateChangedBy,StateChangedDate,PostingDate,DocAppliedAmount,BaseAppliedAmount)
					Select NEWID(),P.Id,@CompanyId,B.Id,B.DocType,B.DocSubType,Case When B.GrandTotal=0.00 Then 'Fully Paid' Else 'Not Paid' End As DocumentState,B.DocCurrency,Round(B.GrandTotal,2) As DocAmount,Round(B.GrandTotal,2) As DocBalanceAmount,B.ExchangeRate,Round(B.GrandTotal*Isnull(B.ExchangeRate,1),2) As BaseAmount,Round(B.GrandTotal*Isnull(B.ExchangeRate,1),2) As BaseBalanceAmount,B.Usercreated,
					Case When P.ModifiedDate Is Null Then P.CreatedDate Else P.ModifiedDate End As StateChangeData,
					Case When P.DocumentState='Void' Then Null Else P.DocDate End,Case When P.DocumentState='Void' Then 0.00 Else -(Round(PD.PaymentAmount,2)) End As DocPaymentAmount,
					Case When P.DocumentState='Void' Then 0.00 Else -(Round(PD.PaymentAmount * B.ExchangeRate,2)) End As BasePaymentAmount
					From Bean.Bill As B 
					Inner Join Bean.PaymentDetail As PD On PD.DocumentId=B.Id
					Inner Join Bean.Payment As P On P.Id=PD.PaymentId
					Where B.Id=@DocumentId And B.CompanyId=@CompanyId And PD.PaymentAmount <>0
					--Print 112
					Insert Into Bean.DocumentHistory(Id,TransactionId,CompanyId,DocumentId,DocType,DocSubType,DocState,DocCurrency,DocAmount,DocBalanaceAmount,ExchangeRate,BaseAmount,BaseBalanaceAmount,StateChangedBy,StateChangedDate,PostingDate,DocAppliedAmount,BaseAppliedAmount)
					Select NEWID(),CM.Id,@CompanyId,B.Id,B.DocType,B.DocSubType,Case When B.GrandTotal=0.00 Then 'Fully Paid' Else 'Not Paid' End As DocumentState,B.DocCurrency,Round(B.GrandTotal,2) As DocAmount,Round(B.GrandTotal,2) As DocBalanceAmount,B.ExchangeRate,Round(B.GrandTotal*Isnull(B.ExchangeRate,1),2) As BaseAmount,Round(B.GrandTotal*Isnull(B.ExchangeRate,1),2) As BaseBalanceAmount,B.Usercreated,
					Case When CM.ModifiedDate Is Null Then CM.CreatedDate Else CM.ModifiedDate End As StateChangeData,
					Case When CM.Status=2 Then Null Else CM.CreditMemoApplicationDate End,
					Case When CM.Status=2 Then 0.00 Else -(Round(CMD.CreditAmount,2)) End As DocCreditAmount,
					Case When CM.Status=2 Then 0.00 Else -(Round(CMD.CreditAmount * B.ExchangeRate,2)) End As BaseCreditAmount
					From Bean.Bill As B 
					Inner Join Bean.CreditMemoApplicationDetail As CMD On CMD.DocumentId=B.Id
					Inner Join Bean.CreditMemoApplication As CM On CM.Id=CMD.CreditMemoApplicationId
					Where B.Id=@DocumentId And B.CompanyId=@CompanyId And CMD.CreditAmount <>0

				End
			End
			Set @RecCount=@RecCount+1
		End
		Truncate Table #DocHstr_Migr
		--Print 12
		-- BillPayment,Payroll payments
		Insert Into #DocHstr_Migr (DocumentId,CreatedDate,ModifiedDate)
		Select Id,CreatedDate,ModifiedDate From Bean.Payment Where CompanyId=@CompanyId And Id Not In (Select DocumentId From Bean.DocumentHistory Where CompanyId=@CompanyId)
		Set @RecCount=1
		Select @Count=COUNT(*) From #DocHstr_Migr
		While @Count>=@RecCount
		Begin
			Select @DocumentId=DocumentId,@CreatedDate=CreatedDate,@ModifiedDate=ModifiedDate From #DocHstr_Migr Where Sno=@RecCount

			If @ModifiedDate Is Null
			Begin
				Insert Into Bean.DocumentHistory(Id,TransactionId,CompanyId,DocumentId,DocType,DocSubType,DocState,DocCurrency,DocAmount,DocBalanaceAmount,ExchangeRate,BaseAmount,BaseBalanaceAmount,StateChangedBy,StateChangedDate,PostingDate,DocAppliedAmount,BaseAppliedAmount)
				Select NEWID(),Id,@CompanyId,Id,DocType,DocSubType,DocumentState,DocCurrency,Round(GrandTotal,2) As DocAmount,0.00 As DocBalanceAmount,ExchangeRate,Round(GrandTotal*Isnull(ExchangeRate,1),2) As BaseAmount,0.00 As BaseBalanceAmount,UserCreated,CreatedDate,DocDate,(Round(GrandTotal,2)),(Round(GrandTotal * ExchangeRate,2)) From Bean.Payment Where Id=@DocumentId And CompanyId=@CompanyId
			End
			Else
			Begin
				Insert Into Bean.DocumentHistory(Id,TransactionId,CompanyId,DocumentId,DocType,DocSubType,DocState,DocCurrency,DocAmount,DocBalanaceAmount,ExchangeRate,BaseAmount,BaseBalanaceAmount,StateChangedBy,StateChangedDate,PostingDate,DocAppliedAmount,BaseAppliedAmount)
				Select NEWID(),Id,@CompanyId,Id,DocType,DocSubType,'Posted' As DocumentState,DocCurrency,Round(GrandTotal,2) As DocAmount,0.00 As DocBalanceAmount,ExchangeRate,Round(GrandTotal*Isnull(ExchangeRate,1),2) As BaseAmount,0.00 As BaseBalanceAmount,Usercreated,CreatedDate,DocDate,(Round(GrandTotal,2)),(Round(GrandTotal * ExchangeRate,2)) From Bean.Payment Where Id=@DocumentId And CompanyId=@CompanyId
				
				Insert Into Bean.DocumentHistory(Id,TransactionId,CompanyId,DocumentId,DocType,DocSubType,DocState,DocCurrency,DocAmount,DocBalanaceAmount,ExchangeRate,BaseAmount,BaseBalanaceAmount,StateChangedBy,StateChangedDate,DocAppliedAmount,BaseAppliedAmount)
				Select NEWID(),Id,@CompanyId,Id,DocType,DocSubType,DocumentState,DocCurrency,Round(GrandTotal,2) As DocAmount,0.00 As DocBalanceAmount,ExchangeRate,Round(GrandTotal*Isnull(ExchangeRate,1),2) As BaseAmount,0.00 As BaseBalanceAmount,Coalesce(ModifiedBy,'System'),ModifiedDate,0.00,0.00 From Bean.Payment Where Id=@DocumentId And CompanyId=@CompanyId
			End
			Set @RecCount=@RecCount+1
		End
		Truncate Table #DocHstr_Migr
		--Print 13
		-- Bank Reconciliations
		Insert Into #DocHstr_Migr (DocumentId,CreatedDate,ModifiedDate)
		Select Id,CreatedDate,ModifiedDate From Bean.BankReconciliation Where CompanyId=@CompanyId And Id Not In (Select DocumentId From Bean.DocumentHistory Where CompanyId=@CompanyId)
		Set @RecCount=1
		Select @Count=COUNT(*) From #DocHstr_Migr
		While @Count>=@RecCount
		Begin
			Select @DocumentId=DocumentId,@CreatedDate=CreatedDate,@ModifiedDate=ModifiedDate From #DocHstr_Migr Where Sno=@RecCount
			If @ModifiedDate Is Null
			Begin
				Insert Into Bean.DocumentHistory(Id,TransactionId,CompanyId,DocumentId,DocType,DocSubType,DocState,DocCurrency,DocAmount,DocBalanaceAmount,ExchangeRate,BaseAmount,BaseBalanaceAmount,StateChangedBy,StateChangedDate)
				Select NEWID(),Id,@CompanyId,Id,'Bank Reconciliation','Bank Reconciliation',state As DocumentState,'' DocCurrency,Round(StatementAmount,2) As DocAmount,0.00 As DocBalanaceAmount,Null As ExchangeRate,Round(StatementAmount,2) As BaseAmount,0.00 As BaseBalanceAmount,UserCreated,CreatedDate From Bean.BankReconciliation Where Id=@DocumentId And CompanyId=@CompanyId
			End
			Else
			Begin
				Insert Into Bean.DocumentHistory(Id,TransactionId,CompanyId,DocumentId,DocType,DocSubType,DocState,DocCurrency,DocAmount,DocBalanaceAmount,ExchangeRate,BaseAmount,BaseBalanaceAmount,StateChangedBy,StateChangedDate)
				Select NEWID(),Id,@CompanyId,Id,'Bank Reconciliation','Bank Reconciliation','Draft' As DocumentState,'' DocCurrency,Round(StatementAmount,2) As DocAmount,0.00 As DocBalanaceAmount,Null As ExchangeRate,Round(StatementAmount,2) As BaseAmount,0.00 As BaseBalanceAmount,Usercreated,CreatedDate From Bean.BankReconciliation Where Id=@DocumentId And CompanyId=@CompanyId
				
				Insert Into Bean.DocumentHistory(Id,TransactionId,CompanyId,DocumentId,DocType,DocSubType,DocState,DocCurrency,DocAmount,DocBalanaceAmount,ExchangeRate,BaseAmount,BaseBalanaceAmount,StateChangedBy,StateChangedDate)
				Select NEWID(),Id,@CompanyId,Id,'Bank Reconciliation' DocType,'Bank Reconciliation' DocType,State As DocumentState,'' DocCurrency,Round(StatementAmount,2) As DocAmount,0.00 As DocBalanaceAmount,Null As ExchangeRate,Round(StatementAmount,2) As BaseAmount,0.00 As BaseBalanceAmount,Coalesce(ModifiedBy,'System'),ModifiedDate From Bean.BankReconciliation Where Id=@DocumentId And CompanyId=@CompanyId
			End
			Set @RecCount=@RecCount+1
		End
		Truncate Table #DocHstr_Migr
		--Print 14
		-- OpeningBalance
		Insert Into #DocHstr_Migr (DocumentId,CreatedDate,ModifiedDate)
		Select Id,CreatedDate,ModifiedDate From Bean.OpeningBalance Where CompanyId=@CompanyId And Id Not In (Select DocumentId From Bean.DocumentHistory Where CompanyId=@CompanyId)
		Set @RecCount=1
		Select @Count=COUNT(*) From #DocHstr_Migr
		While @Count>=@RecCount
		Begin
			Select @DocumentId=DocumentId,@CreatedDate=CreatedDate,@ModifiedDate=ModifiedDate From #DocHstr_Migr Where Sno=@RecCount

			If @ModifiedDate Is Null
			Begin
				Insert Into Bean.DocumentHistory(Id,TransactionId,CompanyId,DocumentId,DocType,DocSubType,DocState,DocCurrency,DocAmount,DocBalanaceAmount,ExchangeRate,BaseAmount,BaseBalanaceAmount,StateChangedBy,StateChangedDate)
				Select NEWID(),@DocumentId,@CompanyId,Id,'Journal' DocType,'Opening Bal' DocSubType,Case When SaveType='Save' Then 'Posted' Else SaveType End As DocumentState,'' DocCurrency,0.00 As DocAmount,0.00 As DocBalanceAmount,1.00 As ExchangeRate,0.00 As BaseAmount,0.00 As BaseBalanceAmount,UserCreated,CreatedDate From Bean.OpeningBalance Where Id=@DocumentId And CompanyId=@CompanyId
			End
			Else
			Begin
				Insert Into Bean.DocumentHistory(Id,TransactionId,CompanyId,DocumentId,DocType,DocSubType,DocState,DocCurrency,DocAmount,DocBalanaceAmount,ExchangeRate,BaseAmount,BaseBalanaceAmount,StateChangedBy,StateChangedDate)
				Select NEWID(),Id,@CompanyId,Id,'Journal' DocType,'Opening Bal' DocSubType,'Draft' As DocumentState,'' As DocCurrency,0.00 As DocAmount,0.00 As DocBalanceAmount,1.00 ExchangeRate,0.00 As BaseAmount,0.00 As BaseBalanceAmount,Usercreated,CreatedDate From Bean.OpeningBalance Where Id=@DocumentId And CompanyId=@CompanyId
				
				Insert Into Bean.DocumentHistory(Id,TransactionId,CompanyId,DocumentId,DocType,DocSubType,DocState,DocCurrency,DocAmount,DocBalanaceAmount,ExchangeRate,BaseAmount,BaseBalanaceAmount,StateChangedBy,StateChangedDate)
				Select NEWID(),Id,@CompanyId,Id,'Journal' DocType,'Opening Bal' DocSubType,Case When SaveType='Save' Then 'Posted' Else SaveType End As DocumentState,'' DocCurrency,0.00 As DocAmount,0.00 As DocBalanceAmount,1.00 ExchangeRate,0.00 As BaseAmount,0.00 As BaseBalanceAmount,Coalesce(ModifiedBy,'System'),ModifiedDate From Bean.OpeningBalance Where Id=@DocumentId And CompanyId=@CompanyId
			End
			Set @RecCount=@RecCount+1
		End
		Truncate Table #DocHstr_Migr
		/*
		--Master Journal Recurring
		**Insert Into #DocHstr_Migr (DocumentId,CreatedDate,ModifiedDate)
		**Select Id,CreatedDate,ModifiedDate From Bean.Journal Where CompanyId=@CompanyId And DocType='Journal' And DocSubType='Recurring' And DocumentState='Recurring' And Id Not In (Select DocumentId From Bean.DocumentHistory Where CompanyId=@CompanyId)
		**Set @RecCount=1
		**Select @Count=COUNT(*) From #DocHstr_Migr
		**While @Count>=@RecCount
		**Begin
		**	Select @DocumentId=DocumentId,@CreatedDate=CreatedDate,@ModifiedDate=ModifiedDate From #DocHstr_Migr Where Sno=@RecCount
		**	If @ModifiedDate Is Null
		**	Begin
		**		Insert Into Bean.DocumentHistory(Id,TransactionId,CompanyId,DocumentId,DocType,DocSubType,DocState,DocCurrency,DocAmount,DocBalanaceAmount,ExchangeRate,BaseAmount,BaseBalanaceAmount,StateChangedBy,StateChangedDate)
		**		Select NEWID(),@DocumentId,@CompanyId,Id,DocType,DocSubType,DocumentState,DocCurrency,Round(Isnull(GrandDocDebitTotal,GrandDocCreditTotal),2) As DocAmount,Round(BalanceAmount,2) As DocBalanaceAmount,ExchangeRate,Round(Isnull(GrandDocDebitTotal,GrandDocCreditTotal) * ExchangeRate,2) As BaseAmount,Round(BalanceAmount * Isnull(ExchangeRate,1),2) As BaseBalanceAmount,UserCreated,CreatedDate From Bean.Journal Where Id=@DocumentId And CompanyId=@CompanyId And DocType='Journal'
		**	End
		**	Else
		**	Begin
		**		Insert Into Bean.DocumentHistory(Id,TransactionId,CompanyId,DocumentId,DocType,DocSubType,DocState,DocCurrency,DocAmount,DocBalanaceAmount,ExchangeRate,BaseAmount,BaseBalanaceAmount,StateChangedBy,StateChangedDate)
		**		Select NEWID(),@DocumentId,@CompanyId,Id,DocType,DocSubType,'RE' As DocumentState,DocCurrency,Round(Coalesce(GrandDocDebitTotal,GrandDocCreditTotal),2) As DocAmount,Round(coalesce(GrandDocDebitTotal,GrandDocCreditTotal),2) As DocBalanaceAmount,ExchangeRate,Round(Coalesce(GrandDocDebitTotal,GrandDocCreditTotal) * Isnull(ExchangeRate,1),2) As BaseAmount,Round(Coalesce(GrandDocDebitTotal,GrandDocCreditTotal) * Isnull(ExchangeRate,1),2) As BaseBalanceAmount,Usercreated,CreatedDate From Bean.Journal Where Id=@DocumentId And CompanyId=@CompanyId And DocType='Journal'
		**		
		**		Insert Into Bean.DocumentHistory(Id,TransactionId,CompanyId,DocumentId,DocType,DocSubType,DocState,DocCurrency,DocAmount,DocBalanaceAmount,ExchangeRate,BaseAmount,BaseBalanaceAmount,StateChangedBy,StateChangedDate)
		**		Select NEWID(),@DocumentId,@CompanyId,Id,DocType,DocSubType,DocumentState,DocCurrency,Round(Isnull(GrandDocDebitTotal,GrandDocCreditTotal),2) As DocAmount,BalanceAmount As DocBalanaceAmount,ExchangeRate,Round(Isnull(GrandDocDebitTotal,GrandDocCreditTotal) * Isnull(ExchangeRate,1),2) As BaseAmount,(BalanceAmount*Isnull(ExchangeRate,1)) As BaseBalanceAmount,Coalesce(ModifiedBy,'System'),ModifiedDate From Bean.Journal Where Id=@DocumentId And CompanyId=@CompanyId And DocType='Journal'
		**	End
		**	Set @RecCount=@RecCount+1
		**End
		**Truncate Table #DocHstr_Migr
		*/
		/*
		-- Transfer
		**Insert Into #DocHstr_Migr (DocumentId,CreatedDate,ModifiedDate)
		**Select Id,CreatedDate,ModifiedDate From Bean.BankTransfer Where CompanyId=@CompanyId And Id Not In (Select DocumentId From Bean.DocumentHistory Where CompanyId=@CompanyId)
		**Set @RecCount=1
		**Select @Count=COUNT(*) From #DocHstr_Migr
		**While @Count>=@RecCount
		**Begin
		**	--Set @DocumentId = (Select DocumentId From #DocHstr_Migr Where Sno=@RecCount)
		**	--Set @CreatedDate = (Select CreatedDate From #DocHstr_Migr Where Sno=@RecCount)
		**	--Set @ModifiedDate = (Select ModifiedDate  From #DocHstr_Migr Where Sno=@RecCount)
		**	Select @DocumentId=DocumentId,@CreatedDate=CreatedDate,@ModifiedDate=ModifiedDate From #DocHstr_Migr Where Sno=@RecCount
		**	If @ModifiedDate Is Null
		**	Begin
		**		Insert Into Bean.DocumentHistory(Id,TransactionId,CompanyId,DocumentId,DocType,DocSubType,DocState,DocCurrency,DocAmount,DocBalanaceAmount,ExchangeRate,BaseAmount,BaseBalanaceAmount,StateChangedBy,StateChangedDate)
		**		Select NEWID(),@DocumentId,@CompanyId,Id,DocType,DocType,DocumentState,ExCurrency,GrandTotal As DocAmount,0.00 As DocBalanaceAmount,ExchangeRate,Round(GrandTotal * ExchangeRate,2) As BaseAmount,0.00 As BaseBalanceAmount,UserCreated,CreatedDate From Bean.BankTransfer Where Id=@DocumentId And CompanyId=@CompanyId
		**	End
		**	Else
		**	Begin
		**		Insert Into Bean.DocumentHistory(Id,TransactionId,CompanyId,DocumentId,DocType,DocSubType,DocState,DocCurrency,DocAmount,DocBalanaceAmount,ExchangeRate,BaseAmount,BaseBalanaceAmount,StateChangedBy,StateChangedDate)
		**		Select NEWID(),@DocumentId,@CompanyId,Id,DocType,DocType,'Posted' As DocumentState,DocCurrency,GrandTotal As DocAmount,0.00 As DocBalanaceAmount,ExchangeRate,Round(GrandTotal * ExchangeRate,2) As BaseAmount,0.00 As BaseBalanceAmount,Usercreated,CreatedDate From Bean.BankTransfer Where Id=@DocumentId And CompanyId=@CompanyId
		**		
		**		Insert Into Bean.DocumentHistory(Id,TransactionId,CompanyId,DocumentId,DocType,DocSubType,DocState,DocCurrency,DocAmount,DocBalanaceAmount,ExchangeRate,BaseAmount,BaseBalanaceAmount,StateChangedBy,StateChangedDate)
		**		Select NEWID(),@DocumentId,@CompanyId,Id,DocType,DocType,DocumentState,DocCurrency,GrandTotal As DocAmount,0.00 As DocBalanaceAmount,ExchangeRate,Round(GrandTotal * ExchangeRate,2) As BaseAmount,0.00 As BaseBalanceAmount,Coalesce(ModifiedBy,'System'),ModifiedDate From Bean.BankTransfer Where Id=@DocumentId And CompanyId=@CompanyId
		**	End
		**	Set @RecCount=@RecCount+1
		**End
		**Truncate Table #DocHstr_Migr
		*/
		IF OBJECT_ID('tempdb..#DocHstr_Migr') IS NOT NULL
		Begin
			Drop Table #DocHstr_Migr
		End
	Commit Transaction
	End Try
	Begin Catch
		Rollback;
		Set @ErrorMessage=(Select ERROR_MESSAGE())
		RaisError(@ErrorMessage,16,1);
	End Catch


End

GO
