USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[Bean_State_Update]    Script Date: 16-12-2024 9.20.10 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE Procedure [dbo].[Bean_State_Update]
(
@CompanyId BigInt,
@DocumentId UniqueIdentifier,
@DocType Nvarchar(50),
@Description Nvarchar(250),
@PoNo Nvarchar(50),
@NoSupportingDocument Bit,
@IsNoSupportingDocs Bit,
@ModifiedDate DateTime2(7),
@ModifiedBy Nvarchar(100),
@Version Nvarchar(200),
@AccountDescription nvarchar(max)
)
As
Begin
	Declare @InvoiceDocument Nvarchar(50)='Invoice', @DebitNoteDocument nvarchar(50)='Debit Note',
	@CreditNote nvarchar(50)='Credit Note',@DebitProvision nvarchar(50)='Debt Provision',
	@BillDocument nvarchar(30)='Bill',@CreditMemoDocument nvarchar(30)='Credit Memo', @DepositDocument nvarchar(50)='Deposit', @WithdrawalDocument nvarchar(50)='Withdrawal', @JournalDocument Nvarchar(50)='Journal',@CashpaymentDocument nvarchar(50)='Cash Payment', @CashSaleDocument Nvarchar(50)='Cash Sale', @ReceiptDocument nvarchar(50)='Receipt', @PaymentDocument nvarchar(50)='Bill Payment', @TransferDocument nvarchar(50)='Transfer', @CNAppDocument Nvarchar(50)='Credit Note Application'
	, @CMAppDocument Nvarchar(50)='Credit Memo Application'
	Declare @ErrorMessage Nvarchar(1000), @ErrorServirity Int, @ErrorState Int
	Declare @TimeStamp nvarchar(100)
	Declare @BCDocumentHistoryType DocumentHistoryTableType
	Declare @DocumentState Nvarchar(30), @MasterId  uniqueIdentifier, @DocCurrency nvarchar(10), @ExchangeRate Decimal(15,10)

	----for AccountDescription
	Declare @AccDesccount int=0
	Declare @Reccount int=0
	Declare @countcoma int=0
	--Declare @Reccountcoma int=0
	Declare @Docid uniqueIdentifier
	Declare @Desc Nvarchar(500)
	Declare @KeyPairValue nvarchar(500)
	Declare @KeyPairValueRecCount Int
	Declare @KeyPair Nvarchar(Max)
	
	Declare @AccountDescTable Table (DetailDocId uniqueIdentifier, AccountDesc nvarchar(300))
	Declare @tempTable Table(id int identity(1,1), stringVal nvarchar(300))

	Begin Try
		Begin Transaction
		If Exists(Select Id from Bean.Journal (nolock) where CompanyId=@CompanyId and DocumentId=@DocumentId and DocumentState in (/*'Not Paid','Not Applied','Not Allocated',*/'Void'))
		Begin
			RAISERROR('State has been changed, kindly refresh the screen.',16,1); 
		End

		---for document Description
		If (@AccountDescription is not null and @AccountDescription <>'')
		Begin
		
			--set @AccountDescription=Replace(@AccountDescription,'[','')
			--Set @AccountDescription=Replace(@AccountDescription,']','')

			Insert Into @AccountDescTable
			---Select items From SplitToTable (@AccountDescription,':')
				SELECT S.*
              FROM OPENJSON (@AccountDescription, N'$')
              WITH (
              Id Nvarchar(200) N'$.Id',
              Dec Nvarchar(max) N'$.Dec'
              ) AS S;
	
			
		END

		If(@DocType=@InvoiceDocument)
		Begin
			IF(@Version is not NULL)
			Begin
				Select @TimeStamp=( CONVERT(NVARCHAR(200), CONVERT(BINARY(8), I.Version), 1)),@DocumentState=(i.DocumentState) from Bean.Invoice I (nolock) where Id=@DocumentId and CompanyId=@CompanyId
				IF @TimeStamp is not NULL and @TimeStamp<>@Version
				Begin
					RAISERROR('The document had been modified. Please refresh before proceeding.',16,1);
				End
			End
			
			if(@DocumentState='Completed')
			Begin
				Update ID Set ID.ItemDescription=Acc.AccountDesc from Bean.Invoice I Join Bean.InvoiceDetail ID on I.Id=ID.InvoiceId 
					Join @AccountDescTable Acc on Acc.DetailDocId=ID.Id where I.Id=@DocumentId and I.CompanyId=@companyId
				Update Bean.Invoice Set DocDescription=@Description,PONo=@PoNo,IsNoSupportingDocument=@IsNoSupportingDocs,NoSupportingDocs=@NoSupportingDocument,ModifiedBy=@ModifiedBy,ModifiedDate=@ModifiedDate where CompanyId=@CompanyId and Id=@DocumentId and DocType=@DocType
				----For Audit trial 
				Insert Into @BCDocumentHistoryType(TransactionId,CompanyId,DocumentId,DocType,DocSubType,DocState,DocCurrency,DocAmount,DocBalanaceAmount,ExchangeRate,BaseAmount,BaseBalanaceAmount,StateChangedBy,PostingDate,DocAppliedAmount,BaseAppliedAmount)
				Select @DocumentId,CompanyId,@DocumentId,DocType,DocSubType,DocumentState,DocCurrency,Round(GrandTotal,2) As DocAmount,Round(BalanceAmount,2) As DocBalanceAmount,ExchangeRate,/*Round(GrandTotal*ExchangeRate,2)*/ 0  As BaseAmount,Round(BalanceAmount*ExchangeRate,2) As BaseBalanceAmount,ISNULL(ModifiedBy,UserCreated),/*DocDate*/Case When DocumentState='Not Paid' Then  DocDate Else null End,/*Round(GrandTotal,2)*/Case When DocumentState='Not Paid' Then  Round(GrandTotal,2) Else 0 End As DocAppliedAmount, 0  As BaseAppliedAmount From Bean.Invoice Where Id=@DocumentId
				Exec [dbo].[Bean_DocumentHistory] @BCDocumentHistoryType
			End
			Else
			Begin
				If(@Description is not null and (@AccountDescription='' or @AccountDescription is null))
				Begin
					Update Jd Set Jd.AccountDescription=@Description from 
					Bean.Journal J
					Join Bean.JournalDetail Jd on J.Id=Jd.JournalId 
					Where CompanyId=@CompanyId and J.DocumentId=@DocumentId and (JD.IsTax=1 or		JD.DocumentDetailId='00000000-0000-0000-0000-000000000000')
					Update Bean.InvoiceDetail Set ItemDescription=@Description Where InvoiceId=@DocumentId and ItemDescription is null
				End 
				Else If(@AccountDescription<>'' and @AccountDescription is not null)
				Begin
					Update ID Set ID.ItemDescription=Acc.AccountDesc from Bean.Invoice I Join Bean.InvoiceDetail ID on I.Id=ID.InvoiceId 
					Join @AccountDescTable Acc on Acc.DetailDocId=ID.Id where I.Id=@DocumentId and I.CompanyId=@companyId

					Update JD Set JD.AccountDescription=Case When (JD.IsTax=1 or	JD.DocumentDetailId='00000000-0000-0000-0000-000000000000') Then @Description Else ID.ItemDescription End  from	   Bean.Invoice I
					Join Bean.InvoiceDetail ID on I.Id=ID.InvoiceId
					Join Bean.Journal J on J.DocumentId=I.Id
					join Bean.JournalDetail Jd  on Jd.JournalId=J.Id --and JD.DocumentId=@DocumentId
					where I.CompanyId=@CompanyId and I.Id=@DocumentId and Jd.DocumentId=@DocumentId and ID.Id=Jd.DocumentDetailId	and Jd.IsTax<>1

					Update Bean.Journaldetail Set AccountDescription=@Description where documentId=@DocumentId and (Istax=1 or	DocumentDetailId='00000000-0000-0000-0000-000000000000')

				End
				Update Bean.Journal Set DocumentDescription=@Description,PoNo=@PoNo,IsNoSupportingDocs=@IsNoSupportingDocs,NoSupportingDocument=@NoSupportingDocument,ModifiedBy=@ModifiedBy,ModifiedDate=@ModifiedDate where CompanyId=@CompanyId and DocumentId=@DocumentId
				Update Bean.Invoice Set DocDescription=@Description,PONo=@PoNo,IsNoSupportingDocument=@IsNoSupportingDocs,NoSupportingDocs=@NoSupportingDocument,ModifiedBy=@ModifiedBy,ModifiedDate=@ModifiedDate where CompanyId=@CompanyId and Id=@DocumentId and DocType=@DocType
				----For Audit trial 
				Insert Into @BCDocumentHistoryType(TransactionId,CompanyId,DocumentId,DocType,DocSubType,DocState,DocCurrency,DocAmount,DocBalanaceAmount,ExchangeRate,BaseAmount,BaseBalanaceAmount,StateChangedBy,PostingDate,DocAppliedAmount,BaseAppliedAmount)
				Select @DocumentId,CompanyId,@DocumentId,DocType,DocSubType,DocumentState,DocCurrency,Round(GrandTotal,2) As DocAmount,Round(BalanceAmount,2) As DocBalanceAmount,ExchangeRate,/*Round(GrandTotal*ExchangeRate,2)*/ 0  As BaseAmount,Round(BalanceAmount*ExchangeRate,2) As BaseBalanceAmount,ISNULL(ModifiedBy,UserCreated),/*DocDate*/Case When DocumentState='Not Paid' Then  DocDate Else null End,/*Round(GrandTotal,2)*/Case When DocumentState='Not Paid' Then  Round(GrandTotal,2) Else 0 End As DocAppliedAmount, 0  As BaseAppliedAmount From Bean.Invoice Where Id=@DocumentId
				Exec [dbo].[Bean_DocumentHistory] @BCDocumentHistoryType
			End
		End
		Else if (@DocType=@DebitNoteDocument)
		Begin
		IF(@Version is not NULL)
			Begin
				SET @TimeStamp=(Select CONVERT(NVARCHAR(200), CONVERT(BINARY(8), D.Version), 1) from Bean.DebitNote D where Id=@DocumentId and CompanyId=@CompanyId)
				IF @TimeStamp is not NULL and @TimeStamp<>@Version
				Begin
					RAISERROR('The document had been modified. Please refresh before proceeding.',16,1);
				End
			End

		if(@Description is not null and (@AccountDescription='' or @AccountDescription is null))
		Begin
			Update Jd Set Jd.AccountDescription=@Description from Bean.Journal J join Bean.JournalDetail Jd  on J.Id=JournalId
			where CompanyId=@CompanyId and J.DocumentId=@DocumentId and (JD.IsTax=1 or		JD.DocumentDetailId='00000000-0000-0000-0000-000000000000')
			Update bean.DebitNoteDetail Set AccountDescription=@Description where DebitNoteId=@DocumentId 
		End
		Else If(@AccountDescription<>'' and @AccountDescription is not null)
			Begin
				Update DD Set DD.AccountDescription=Acc.AccountDesc from Bean.DebitNote D Join Bean.DebitNoteDetail DD on D.Id=DD.DebitNoteId 
				Join @AccountDescTable Acc on Acc.DetailDocId=DD.Id where D.Id=@DocumentId and D.CompanyId=@companyId

				Update JD Set JD.AccountDescription=Case When (JD.IsTax=1 or	JD.DocumentDetailId='00000000-0000-0000-0000-000000000000') Then @Description Else DD.AccountDescription End  from Bean.DebitNote D
				Join Bean.DebitNoteDetail DD on D.Id=DD.DebitNoteId
				Join Bean.Journal J on J.DocumentId=D.Id
				join Bean.JournalDetail Jd  on Jd.JournalId=J.Id --and JD.DocumentId=@DocumentId
				where D.CompanyId=@CompanyId and D.Id=@DocumentId and Jd.DocumentId=@DocumentId and DD.Id=Jd.DocumentDetailId	and Jd.IsTax<>1

				Update Bean.Journaldetail Set AccountDescription=@Description where documentId=@DocumentId and (Istax=1 or	DocumentDetailId='00000000-0000-0000-0000-000000000000')

			End 
		Update Bean.Journal Set DocumentDescription=@Description,PoNo=@PoNo,IsNoSupportingDocs=@IsNoSupportingDocs,NoSupportingDocument=@NoSupportingDocument,ModifiedBy=@ModifiedBy,ModifiedDate=@ModifiedDate where CompanyId=@CompanyId and DocumentId=@DocumentId 
		Update Bean.DebitNote Set 		PONo=@PoNo,Remarks=@Description,IsNoSupportingDocument=@IsNoSupportingDocs,NoSupportingDocument=@NoSupportingDocument,ModifiedBy=@ModifiedBy,ModifiedDate=@ModifiedDate where 
		 CompanyId=@CompanyId and Id=@DocumentId 

		 ----For Audit trial 
			Insert Into @BCDocumentHistoryType(TransactionId,CompanyId,DocumentId,DocType,DocSubType,DocState,DocCurrency,DocAmount,DocBalanaceAmount,ExchangeRate,BaseAmount,BaseBalanaceAmount,StateChangedBy,PostingDate,DocAppliedAmount,BaseAppliedAmount)
			Select @DocumentId,CompanyId,@DocumentId,@DocType,
			'Genaral',DocumentState,DocCurrency,Round(GrandTotal,2) As DocAmount,Round(BalanceAmount,2) As DocBalanceAmount,ExchangeRate,/*Round(GrandTotal*ExchangeRate,2)*/ 0  As BaseAmount,Round(BalanceAmount*ExchangeRate,2) As BaseBalanceAmount,ISNULL(ModifiedBy,UserCreated),/*DocDate*/Case When DocumentState='Not Paid' Then  DocDate Else null End,/*Round(GrandTotal,2)*/Case When DocumentState='Not Paid' Then  Round(GrandTotal,2) Else 0 End As DocAppliedAmount, 0  As BaseAppliedAmount From Bean.DebitNote Where Id=@DocumentId
			Exec [dbo].[Bean_DocumentHistory] @BCDocumentHistoryType
		End
		Else if (@DocType=@CreditNote)
		Begin
		IF(@Version is not NULL)
		Begin
			SET @TimeStamp=(Select CONVERT(NVARCHAR(200), CONVERT(BINARY(8), I.Version), 1) from Bean.Invoice I (nolock) where Id=@DocumentId and CompanyId=@CompanyId)
			IF @TimeStamp is not NULL and @TimeStamp<>@Version
			Begin
				RAISERROR('The document had been modified. Please refresh before proceeding.',16,1);
			End
		End

		If(@Description is not null and (@AccountDescription='' or @AccountDescription is null))
			Begin
				Update Jd Set Jd.AccountDescription=@Description from 
				Bean.Journal J
				Join Bean.JournalDetail Jd on J.Id=Jd.JournalId 
				Where CompanyId=@CompanyId and J.DocumentId=@DocumentId and (JD.IsTax=1 or		JD.DocumentDetailId='00000000-0000-0000-0000-000000000000')
				Update Bean.InvoiceDetail Set ItemDescription=@Description Where InvoiceId=@DocumentId and ItemDescription is null
			End 
			Else If(@AccountDescription<>'' and @AccountDescription is not null)
			Begin
				Update ID Set ID.ItemDescription=Acc.AccountDesc from Bean.Invoice I Join Bean.InvoiceDetail ID on I.Id=ID.InvoiceId 
				Join @AccountDescTable Acc on Acc.DetailDocId=ID.Id where I.Id=@DocumentId and I.CompanyId=@companyId

				Update JD Set JD.AccountDescription=Case When (JD.IsTax=1 or	JD.DocumentDetailId='00000000-0000-0000-0000-000000000000') Then @Description Else ID.ItemDescription End  from	   Bean.Invoice I
				Join Bean.InvoiceDetail ID on I.Id=ID.InvoiceId
				Join Bean.Journal J on J.DocumentId=I.Id
				join Bean.JournalDetail Jd  on Jd.JournalId=J.Id --and JD.DocumentId=@DocumentId
				where I.CompanyId=@CompanyId and I.Id=@DocumentId and Jd.DocumentId=@DocumentId and ID.Id=Jd.DocumentDetailId	and Jd.IsTax<>1

				Update Bean.Journaldetail Set AccountDescription=@Description where documentId=@DocumentId and (Istax=1 or	DocumentDetailId='00000000-0000-0000-0000-000000000000')

			End

		Update Bean.Journal Set DocumentDescription=@Description,PoNo=@PoNo,IsNoSupportingDocs=@IsNoSupportingDocs,NoSupportingDocument=@NoSupportingDocument,ModifiedBy=@ModifiedBy,ModifiedDate=@ModifiedDate where CompanyId=@CompanyId and DocumentId=@DocumentId 
		Update Bean.Invoice Set PONo=@PoNo,IsNoSupportingDocument=@IsNoSupportingDocs,DocDescription=@Description,Remarks=@Description,NoSupportingDocs=@NoSupportingDocument,ModifiedBy=@ModifiedBy,ModifiedDate=@ModifiedDate where 
		 CompanyId=@CompanyId and Id=@DocumentId 

		 ----For Audit trial 
			Insert Into @BCDocumentHistoryType(TransactionId,CompanyId,DocumentId,DocType,DocSubType,DocState,DocCurrency,DocAmount,DocBalanaceAmount,ExchangeRate,BaseAmount,BaseBalanaceAmount,StateChangedBy,PostingDate,DocAppliedAmount,BaseAppliedAmount)
			Select @DocumentId,CompanyId,@DocumentId,@DocType,
			'Genaral',DocumentState,DocCurrency,Round(GrandTotal,2) As DocAmount,Round(BalanceAmount,2) As DocBalanceAmount,ExchangeRate,/*Round(GrandTotal*ExchangeRate,2)*/ 0  As BaseAmount,Round(BalanceAmount*ExchangeRate,2) As BaseBalanceAmount,ISNULL(ModifiedBy,UserCreated),/*DocDate*/Case When DocumentState='Not Applied' Then  DocDate Else null End,/*Round(GrandTotal,2)*/Case When DocumentState='Not Applied' Then  Round(GrandTotal,2) Else 0 End As DocAppliedAmount, 0  As BaseAppliedAmount From Bean.Invoice Where Id=@DocumentId
			Exec [dbo].[Bean_DocumentHistory] @BCDocumentHistoryType
		End
		Else if (@DocType=@DebitProvision)
		Begin
		IF(@Version is not NULL)
			Begin
				SET @TimeStamp=(Select CONVERT(NVARCHAR(200), CONVERT(BINARY(8), I.Version), 1) from Bean.Invoice I where Id=@DocumentId and CompanyId=@CompanyId)
				IF @TimeStamp is not NULL and @TimeStamp<>@Version
				Begin
					RAISERROR('The document had been modified. Please refresh before proceeding.',16,1);
				End
			End
		if(@Description is not null)
		Begin
			Update Jd Set Jd.AccountDescription=@Description from Bean.Journal J join Bean.JournalDetail Jd  on J.Id=JournalId
			where CompanyId=@CompanyId and J.DocumentId=@DocumentId and Jd.AccountDescription is  null
			Update bean.InvoiceDetail Set ItemDescription=@Description where InvoiceId=@DocumentId and ItemDescription is  null
		End 
		Update Bean.Journal Set DocumentDescription=@Description,PoNo=@PoNo,IsNoSupportingDocs=@IsNoSupportingDocs,NoSupportingDocument=@NoSupportingDocument,ModifiedBy=@ModifiedBy,ModifiedDate=@ModifiedDate where CompanyId=@CompanyId and DocumentId=@DocumentId 
		Update Bean.Invoice Set 		PONo=@PoNo,IsNoSupportingDocument=@IsNoSupportingDocs,DocDescription=@Description,NoSupportingDocs=@NoSupportingDocument,ModifiedBy=@ModifiedBy,ModifiedDate=@ModifiedDate where 
		 CompanyId=@CompanyId and Id=@DocumentId 

		 ----For Audit trial 
			Insert Into @BCDocumentHistoryType(TransactionId,CompanyId,DocumentId,DocType,DocSubType,DocState,DocCurrency,DocAmount,DocBalanaceAmount,ExchangeRate,BaseAmount,BaseBalanaceAmount,StateChangedBy,PostingDate,DocAppliedAmount,BaseAppliedAmount)
			Select @DocumentId,CompanyId,@DocumentId,@DocType,
			'Genaral',DocumentState,DocCurrency,Round(GrandTotal,2) As DocAmount,Round(BalanceAmount,2) As DocBalanceAmount,ExchangeRate,/*Round(GrandTotal*ExchangeRate,2)*/ 0  As BaseAmount,Round(BalanceAmount*ExchangeRate,2) As BaseBalanceAmount,ISNULL(ModifiedBy,UserCreated),/*DocDate*/Case When DocumentState='Not Allocated' Then  DocDate Else null End,/*Round(GrandTotal,2)*/Case When DocumentState='Not Allocated' Then  Round(GrandTotal,2) Else 0 End As DocAppliedAmount, 0  As BaseAppliedAmount From Bean.Invoice Where Id=@DocumentId
			Exec [dbo].[Bean_DocumentHistory] @BCDocumentHistoryType
		End
		Else if (@DocType=@BillDocument)
		Begin
		IF(@Version is not NULL)
			Begin
				SET @TimeStamp=(Select CONVERT(NVARCHAR(200), CONVERT(BINARY(8), I.Version), 1) from Bean.Bill I (nolock) where Id=@DocumentId and CompanyId=@CompanyId)
				IF @TimeStamp is not NULL and @TimeStamp<>@Version
				Begin
					RAISERROR('The document had been modified. Please refresh before proceeding.',16,1);
				End
			End
		

		if(@Description is not null and (@AccountDescription='' or @AccountDescription is null))
		Begin
			Update Jd Set Jd.AccountDescription=@Description from Bean.Journal J join Bean.JournalDetail Jd  on J.Id=JournalId 
			where CompanyId=@CompanyId and J.DocumentId=@DocumentId and (JD.IsTax=1 or		JD.DocumentDetailId='00000000-0000-0000-0000-000000000000')
			Update bean.BillDetail Set Description=@Description where BillId=@DocumentId and (Description is  null OR Description='')
		End 
		Else If(@AccountDescription<>'' and @AccountDescription is not null)
		Begin
			Update BD Set Bd.Description=Acc.AccountDesc from Bean.Bill B Join Bean.BillDetail BD on B.Id=Bd.BillId 
			Join @AccountDescTable Acc on Acc.DetailDocId=BD.Id where B.Id=@DocumentId and B.CompanyId=@companyId

			Update JD Set JD.AccountDescription=Case When (JD.IsTax=1 or JD.DocumentDetailId='00000000-0000-0000-0000-000000000000') Then @Description Else BD.Description End  from Bean.Bill B
			Join Bean.BillDetail BD on B.Id=BD.BillId
			Join Bean.Journal J on J.DocumentId=B.Id
			join Bean.JournalDetail Jd  on Jd.JournalId=J.Id --and JD.DocumentId=@DocumentId
			where B.CompanyId=@CompanyId and B.Id=@DocumentId and Jd.DocumentId=@DocumentId and BD.Id=Jd.DocumentDetailId and Jd.IsTax<>1

			Update Bean.Journaldetail Set AccountDescription=@Description where documentId=@DocumentId and (Istax=1 or DocumentDetailId='00000000-0000-0000-0000-000000000000')

		End
		Update Bean.Journal Set DocumentDescription=@Description,PoNo=@PoNo,IsNoSupportingDocs=@IsNoSupportingDocs,NoSupportingDocument=@NoSupportingDocument,ModifiedBy=@ModifiedBy,ModifiedDate=@ModifiedDate where CompanyId=@CompanyId and DocumentId=@DocumentId 
		Update Bean.Bill Set																												 IsNoSupportingDocument=@IsNoSupportingDocs,DocDescription=@Description,NoSupportingDocument=@NoSupportingDocument,	ModifiedBy=@ModifiedBy,ModifiedDate=@ModifiedDate where 
			  CompanyId=@CompanyId and Id=@DocumentId 

		 ----For Audit trial 
			Insert Into @BCDocumentHistoryType(TransactionId,CompanyId,DocumentId,DocType,DocSubType,DocState,DocCurrency,DocAmount,DocBalanaceAmount,ExchangeRate,BaseAmount,BaseBalanaceAmount,StateChangedBy,PostingDate,DocAppliedAmount,BaseAppliedAmount)
			Select @DocumentId,CompanyId,@DocumentId,@DocType,
			DocSubType,DocumentState,DocCurrency,Round(GrandTotal,2) As DocAmount,Round(BalanceAmount,2) As DocBalanceAmount,ExchangeRate,/*Round(GrandTotal*ExchangeRate,2)*/ 0  As BaseAmount,Round(BalanceAmount*ExchangeRate,2) As BaseBalanceAmount,ISNULL(ModifiedBy,UserCreated),/*DocDate*/Case When DocumentState='Not Paid' Then  PostingDate Else null End,/*Round(GrandTotal,2)*/Case When DocumentState='Not Paid' Then  Round(GrandTotal,2) Else 0 End As DocAppliedAmount, 0  As BaseAppliedAmount From Bean.Bill Where Id=@DocumentId
			Exec [dbo].[Bean_DocumentHistory] @BCDocumentHistoryType
		End
		Else if (@DocType=@CreditMemoDocument)
		Begin
		IF(@Version is not NULL)
			Begin
				SET @TimeStamp=(Select CONVERT(NVARCHAR(200), CONVERT(BINARY(8), I.Version), 1) from Bean.CreditMemo I where Id=@DocumentId and CompanyId=@CompanyId)
				IF @TimeStamp is not NULL and @TimeStamp<>@Version
				Begin
					RAISERROR('The document had been modified. Please refresh before proceeding.',16,1);
				End
			End
		if(@Description is not null AND (@AccountDescription='' or @AccountDescription is null))
		Begin
			Update Jd Set Jd.AccountDescription=@Description from Bean.Journal J join Bean.JournalDetail Jd  on J.Id=JournalId
			where CompanyId=@CompanyId and J.DocumentId=@DocumentId  and (JD.IsTax=1 or JD.DocumentDetailId='00000000-0000-0000-0000-000000000000')
			Update bean.CreditMemoDetail Set Description=@Description where CreditMemoId=@DocumentId and (Description is  null OR Description='')
		End 

		--Start
		Else If(@AccountDescription<>'' and @AccountDescription is not null)
		Begin
			Update CD Set CD.Description=Acc.AccountDesc from Bean.CreditMemo C Join Bean.CreditMemoDetail CD on C.Id=CD.CreditMemoId 
			Join @AccountDescTable Acc on Acc.DetailDocId=CD.Id where C.Id=@DocumentId and C.CompanyId=@companyId

			Update JD Set JD.AccountDescription=Case When (JD.IsTax=1 or JD.DocumentDetailId='00000000-0000-0000-0000-000000000000') Then @Description Else CD.Description End  from Bean.CreditMemo C
			Join Bean.CreditMemoDetail CD on C.Id=CD.CreditMemoId
			Join Bean.Journal J on J.DocumentId=C.Id
			join Bean.JournalDetail Jd  on Jd.JournalId=J.Id --and JD.DocumentId=@DocumentId
			where C.CompanyId=@CompanyId and C.Id=@DocumentId and Jd.DocumentId=@DocumentId and CD.Id=Jd.DocumentDetailId and Jd.IsTax<>1

			Update Bean.Journaldetail Set AccountDescription=@Description where documentId=@DocumentId and (Istax=1 or DocumentDetailId='00000000-0000-0000-0000-000000000000')
		End
		--End

		Update Bean.Journal Set DocumentDescription=@Description,PoNo=@PoNo,IsNoSupportingDocs=@IsNoSupportingDocs,NoSupportingDocument=@NoSupportingDocument,ModifiedBy=@ModifiedBy,ModifiedDate=@ModifiedDate where CompanyId=@CompanyId and DocumentId=@DocumentId 
		Update Bean.CreditMemo Set																												 IsNoSupportingDocument=@IsNoSupportingDocs,DocDescription=@Description,NoSupportingDocs=@NoSupportingDocument,	ModifiedBy=@ModifiedBy,ModifiedDate=@ModifiedDate where 
			  CompanyId=@CompanyId and Id=@DocumentId 

		 ----For Audit trial 
			Insert Into @BCDocumentHistoryType(TransactionId,CompanyId,DocumentId,DocType,DocSubType,DocState,DocCurrency,DocAmount,DocBalanaceAmount,ExchangeRate,BaseAmount,BaseBalanaceAmount,StateChangedBy,PostingDate,DocAppliedAmount,BaseAppliedAmount)
			Select @DocumentId,CompanyId,@DocumentId,@DocType,
			DocSubType,DocumentState,DocCurrency,Round(GrandTotal,2) As DocAmount,Round(BalanceAmount,2) As DocBalanceAmount,ExchangeRate,/*Round(GrandTotal*ExchangeRate,2)*/ 0  As BaseAmount,Round(BalanceAmount*ExchangeRate,2) As BaseBalanceAmount,ISNULL(ModifiedBy,UserCreated),/*DocDate*/Case When DocumentState='Not Paid' Then  PostingDate Else null End,/*Round(GrandTotal,2)*/Case When DocumentState='Not Paid' Then  Round(GrandTotal,2) Else 0 End As DocAppliedAmount, 0  As BaseAppliedAmount From Bean.CreditMemo Where Id=@DocumentId
			Exec [dbo].[Bean_DocumentHistory] @BCDocumentHistoryType
		End

		Else if (@DocType=@DepositDocument or @DocType=@WithdrawalDocument or @DocType=@CashpaymentDocument)
		Begin
		IF(@Version is not NULL)
			Begin
				SET @TimeStamp=(Select CONVERT(NVARCHAR(200), CONVERT(BINARY(8), D.Version), 1) from Bean.WithDrawal(nolock) D where Id=@DocumentId and CompanyId=@CompanyId)
				IF @TimeStamp is not NULL and @TimeStamp<>@Version
				Begin
					RAISERROR('The document had been modified. Please refresh before proceeding.',16,1);
				End
			End

		if(@Description is not null and (@AccountDescription='' or @AccountDescription is null))
		Begin
			Update Jd Set Jd.AccountDescription=@Description from Bean.Journal J join Bean.JournalDetail Jd  on J.Id=JournalId
			where CompanyId=@CompanyId and J.DocumentId=@DocumentId and (JD.IsTax=1 or		JD.DocumentDetailId='00000000-0000-0000-0000-000000000000')

			Update bean.WithDrawalDetail Set Description=@Description where WithdrawalId=@DocumentId and (Description is  null OR Description='')
		End
		Else If(@AccountDescription<>'' and @AccountDescription is not null)
		Begin
			Update WD Set WD.Description=Acc.AccountDesc from Bean.WithDrawal W Join Bean.WithDrawalDetail WD on	W.Id=WD.WithdrawalId 
			Join @AccountDescTable Acc on Acc.DetailDocId=WD.Id where W.Id=@DocumentId and W.CompanyId=@companyId

			Update JD Set JD.AccountDescription=Case When (JD.IsTax=1 or		JD.DocumentDetailId='00000000-0000-0000-0000-000000000000') Then @Description Else WD.Description End  from		Bean.WithDrawal W
			Join Bean.WithDrawalDetail WD on W.Id=WD.WithdrawalId
			Join Bean.Journal J on J.DocumentId=W.Id
			join Bean.JournalDetail Jd  on Jd.JournalId=J.Id --and JD.DocumentId=@DocumentId
			where W.CompanyId=@CompanyId and W.Id=@DocumentId and Jd.DocumentId=@DocumentId and WD.Id=Jd.DocumentDetailId	and		Jd.IsTax<>1

			Update Bean.Journaldetail Set AccountDescription=@Description where documentId=@DocumentId and (Istax=1 or	DocumentDetailId='00000000-0000-0000-0000-000000000000')

		End 
			Update Bean.Journal Set DocumentDescription=@Description,PoNo=@PoNo,IsNoSupportingDocs=@IsNoSupportingDocs,NoSupportingDocument=@NoSupportingDocument,ModifiedBy=@ModifiedBy,ModifiedDate=@ModifiedDate where CompanyId=@CompanyId and DocumentId=@DocumentId 
			Update Bean.WithDrawal Set 	DocDescription=@Description,ModifiedBy=@ModifiedBy,ModifiedDate=@ModifiedDate where 
			CompanyId=@CompanyId and Id=@DocumentId 

		 ----For Audit trial 
			Insert Into @BCDocumentHistoryType(TransactionId,CompanyId,DocumentId,DocType,DocSubType,DocState,DocCurrency,DocAmount,DocBalanaceAmount,ExchangeRate,BaseAmount,BaseBalanaceAmount,StateChangedBy,PostingDate,DocAppliedAmount,BaseAppliedAmount)
			Select @DocumentId,CompanyId,@DocumentId,@DocType,
			'Genaral',DocumentState,DocCurrency,Round(GrandTotal,2) As DocAmount,Round(GrandTotal,2) As DocBalanceAmount,ExchangeRate,/*Round(GrandTotal*ExchangeRate,2)*/ 0  As BaseAmount,Round(GrandTotal*ExchangeRate,2) As BaseBalanceAmount,ISNULL(ModifiedBy,UserCreated),/*DocDate*/Case When DocumentState='Not Paid' Then  DocDate Else null End, Round(GrandTotal,2)  As DocAppliedAmount, Round(GrandTotal*ExchangeRate,2)  As BaseAppliedAmount From Bean.WithDrawal Where Id=@DocumentId
			Exec [dbo].[Bean_DocumentHistory] @BCDocumentHistoryType
		End
		Else if (@DocType=@JournalDocument)
		Begin
		IF(@Version is not NULL)
			Begin
				Select @TimeStamp=(CONVERT(NVARCHAR(200), CONVERT(BINARY(8), D.Version), 1)),@DocumentState=D.InternalState from Bean.Journal D (nolock) where Id=@DocumentId and CompanyId=@CompanyId
				IF @TimeStamp is not NULL and @TimeStamp<>@Version
				Begin
					RAISERROR('The document had been modified. Please refresh before proceeding.',16,1);
				End
			End

		--if(@Description is not null and (@AccountDescription='' and @AccountDescription is null))
		--Begin
		--	Update Jd Set Jd.AccountDescription=@Description from Bean.Journal J join Bean.JournalDetail Jd  on J.Id=JournalId
		--	where CompanyId=@CompanyId and J.Id=@DocumentId and Jd.AccountDescription is  null
		--End
		If(@AccountDescription<>'' and @AccountDescription is not null)
		Begin
			Update JD Set Jd.AccountDescription=Acc.AccountDesc from Bean.Journal J Join Bean.JournalDetail JD on	J.Id=JD.JournalId 
			Join @AccountDescTable Acc on Acc.DetailDocId=JD.Id where J.Id=@DocumentId and J.CompanyId=@companyId
		End 
			Update Bean.Journaldetail Set AccountDescription=@Description where JournalId=@DocumentId and Istax=1 

		
			Update Bean.Journal Set DocumentDescription=@Description,IsNoSupportingDocs=@IsNoSupportingDocs,NoSupportingDocument=@NoSupportingDocument,ModifiedBy=@ModifiedBy,ModifiedDate=@ModifiedDate where CompanyId=@CompanyId and Id=@DocumentId 
		
		 
		End

		Else if (@DocType=@CashSaleDocument)
		Begin
		IF(@Version is not NULL)
			Begin
				SET @TimeStamp=(Select CONVERT(NVARCHAR(200), CONVERT(BINARY(8), D.Version), 1) from Bean.CashSale(nolock) D where Id=@DocumentId and CompanyId=@CompanyId)
				IF @TimeStamp is not NULL and @TimeStamp<>@Version
				Begin
					RAISERROR('The document had been modified. Please refresh before proceeding.',16,1);
				End
			End

		if(@Description is not null and (@AccountDescription='' or @AccountDescription is null))
		Begin
			Update Jd Set Jd.AccountDescription=@Description from Bean.Journal J join Bean.JournalDetail Jd  on J.Id=JournalId
			where CompanyId=@CompanyId and J.DocumentId=@DocumentId and (JD.IsTax=1 or		JD.DocumentDetailId='00000000-0000-0000-0000-000000000000')

			Update bean.CashSaleDetail Set ItemDescription=@Description where CashSaleId=@DocumentId and (ItemDescription is  null OR ItemDescription='')
		End
		Else If(@AccountDescription<>'' and @AccountDescription is not null)
		Begin
			Update CD Set CD.ItemDescription=Acc.AccountDesc from Bean.CashSale C Join Bean.CashSaleDetail CD on	C.Id=CD.CashSaleId 
			Join @AccountDescTable Acc on Acc.DetailDocId=CD.Id where C.Id=@DocumentId and C.CompanyId=@companyId

			Update JD Set JD.AccountDescription=Case When (JD.IsTax=1 or		JD.DocumentDetailId='00000000-0000-0000-0000-000000000000') Then @Description Else CD.ItemDescription End  from Bean.CashSale C
			Join Bean.CashSaleDetail CD on C.Id=CD.CashSaleId
			Join Bean.Journal J on J.DocumentId=C.Id
			join Bean.JournalDetail Jd  on Jd.JournalId=J.Id --and JD.DocumentId=@DocumentId
			where C.CompanyId=@CompanyId and C.Id=@DocumentId and Jd.DocumentId=@DocumentId and CD.Id=Jd.DocumentDetailId	and		Jd.IsTax<>1

			Update Bean.Journaldetail Set AccountDescription=@Description where documentId=@DocumentId and (Istax=1 or	DocumentDetailId='00000000-0000-0000-0000-000000000000')

		End 
		
			Update Bean.Journal Set DocumentDescription=@Description,PoNo=@PoNo,IsNoSupportingDocs=@IsNoSupportingDocs,NoSupportingDocument=@NoSupportingDocument,ModifiedBy=@ModifiedBy,ModifiedDate=@ModifiedDate where CompanyId=@CompanyId and DocumentId=@DocumentId 
			Update Bean.CashSale Set DocDescription=@Description,ModifiedBy=@ModifiedBy,ModifiedDate=@ModifiedDate where 
			CompanyId=@CompanyId and Id=@DocumentId 

		 ----For Audit trial 
			Insert Into @BCDocumentHistoryType(TransactionId,CompanyId,DocumentId,DocType,DocSubType,DocState,DocCurrency,DocAmount,DocBalanaceAmount,ExchangeRate,BaseAmount,BaseBalanaceAmount,StateChangedBy,PostingDate,DocAppliedAmount,BaseAppliedAmount)
			Select @DocumentId,CompanyId,@DocumentId,@DocType,
			'Genaral',DocumentState,DocCurrency,Round(GrandTotal,2) As DocAmount,Round(GrandTotal,2) As DocBalanceAmount,ExchangeRate,/*Round(GrandTotal*ExchangeRate,2)*/ 0  As BaseAmount,Round(GrandTotal*ExchangeRate,2) As BaseBalanceAmount,ISNULL(ModifiedBy,UserCreated),DocDate, Round(GrandTotal,2)  As DocAppliedAmount, Round(GrandTotal*ExchangeRate,2)  As BaseAppliedAmount From Bean.CashSale Where Id=@DocumentId
			Exec [dbo].[Bean_DocumentHistory] @BCDocumentHistoryType
		End
		Else if (@DocType=@ReceiptDocument)
		Begin
		IF(@Version is not NULL)
			Begin
				SET @TimeStamp=(Select CONVERT(NVARCHAR(200), CONVERT(BINARY(8), D.Version), 1) from Bean.Receipt(nolock) D  where Id=@DocumentId and CompanyId=@CompanyId)
				IF @TimeStamp is not NULL and @TimeStamp<>@Version
				Begin
					RAISERROR('The document had been modified. Please refresh before proceeding.',16,1);
				End
			End

		if(@Description is not null)
		Begin
			Update Jd Set Jd.AccountDescription=@Description from Bean.Journal J join Bean.JournalDetail Jd  on J.Id=JournalId
			where CompanyId=@CompanyId and J.DocumentId=@DocumentId 
		End
			Update Bean.Journal Set DocumentDescription=@Description,PoNo=@PoNo,IsNoSupportingDocs=@IsNoSupportingDocs,NoSupportingDocument=@NoSupportingDocument,ModifiedBy=@ModifiedBy,ModifiedDate=@ModifiedDate where CompanyId=@CompanyId and DocumentId=@DocumentId 
			Update Bean.Receipt Set Remarks=@Description,ModifiedBy=@ModifiedBy,ModifiedDate=@ModifiedDate where 
			CompanyId=@CompanyId and Id=@DocumentId 

		 ----For Audit trial 
			Insert Into @BCDocumentHistoryType(TransactionId,CompanyId,DocumentId,DocType,DocSubType,DocState,DocCurrency,DocAmount,DocBalanaceAmount,ExchangeRate,BaseAmount,BaseBalanaceAmount,StateChangedBy,PostingDate,DocAppliedAmount,BaseAppliedAmount)
			Select @DocumentId,CompanyId,@DocumentId,@DocType,
			'Genaral',DocumentState,DocCurrency,Round(GrandTotal,2) As DocAmount,Round(GrandTotal,2) As DocBalanceAmount,ExchangeRate, 0  As BaseAmount,Round(GrandTotal*ExchangeRate,2) As BaseBalanceAmount,ISNULL(ModifiedBy,UserCreated),DocDate, 0  As DocAppliedAmount, 0  As BaseAppliedAmount From Bean.Receipt Where Id=@DocumentId
			Exec [dbo].[Bean_DocumentHistory] @BCDocumentHistoryType
		End

		Else if (@DocType=@PaymentDocument)
		Begin
		IF(@Version is not NULL)
			Begin
				SET @TimeStamp=(Select CONVERT(NVARCHAR(200), CONVERT(BINARY(8), D.Version), 1) from Bean.Payment(nolock) D  where Id=@DocumentId and CompanyId=@CompanyId)
				IF @TimeStamp is not NULL and @TimeStamp<>@Version
				Begin
					RAISERROR('The document had been modified. Please refresh before proceeding.',16,1);
				End
			End

		if(@Description is not null)
		Begin
			Update Jd Set Jd.AccountDescription=@Description from Bean.Journal J join Bean.JournalDetail Jd  on J.Id=JournalId
			where CompanyId=@CompanyId and J.DocumentId=@DocumentId 
		End
			Update Bean.Journal Set DocumentDescription=@Description,PoNo=@PoNo,IsNoSupportingDocs=@IsNoSupportingDocs,NoSupportingDocument=@NoSupportingDocument,ModifiedBy=@ModifiedBy,ModifiedDate=@ModifiedDate where CompanyId=@CompanyId and DocumentId=@DocumentId 
			Update Bean.Payment Set Remarks=@Description,ModifiedBy=@ModifiedBy,ModifiedDate=@ModifiedDate where 
			CompanyId=@CompanyId and Id=@DocumentId 

		 ----For Audit trial 
			Insert Into @BCDocumentHistoryType(TransactionId,CompanyId,DocumentId,DocType,DocSubType,DocState,DocCurrency,DocAmount,DocBalanaceAmount,ExchangeRate,BaseAmount,BaseBalanaceAmount,StateChangedBy,PostingDate,DocAppliedAmount,BaseAppliedAmount)
			Select @DocumentId,CompanyId,@DocumentId,@DocType,
			'Genaral',DocumentState,DocCurrency,Round(GrandTotal,2) As DocAmount,Round(GrandTotal,2) As DocBalanceAmount,ExchangeRate, 0  As BaseAmount,Round(GrandTotal*ExchangeRate,2) As BaseBalanceAmount,ISNULL(ModifiedBy,UserCreated),DocDate, 0  As DocAppliedAmount, 0  As BaseAppliedAmount From Bean.Payment Where Id=@DocumentId
			Exec [dbo].[Bean_DocumentHistory] @BCDocumentHistoryType
		End

		Else if (@DocType=@TransferDocument)
		Begin
			IF(@Version is not NULL)
			Begin
				SET @TimeStamp=(Select CONVERT(NVARCHAR(200), CONVERT(BINARY(8), D.Version), 1) from Bean.BankTransfer(nolock) D  where Id=@DocumentId and CompanyId=@CompanyId)
				IF @TimeStamp is not NULL and @TimeStamp<>@Version
				Begin
					RAISERROR('The document had been modified. Please refresh before proceeding.',16,1);
				End
			End

		if(@Description is not null)
		Begin
			Update Jd Set Jd.AccountDescription=@Description from Bean.Journal J join Bean.JournalDetail Jd  on J.Id=JournalId
			where CompanyId=@CompanyId and J.DocumentId=@DocumentId 
		End
			Update Bean.Journal Set DocumentDescription=@Description,PoNo=@PoNo,IsNoSupportingDocs=@IsNoSupportingDocs,NoSupportingDocument=@NoSupportingDocument,ModifiedBy=@ModifiedBy,ModifiedDate=@ModifiedDate where CompanyId=@CompanyId and DocumentId=@DocumentId 
			Update Bean.BankTransfer Set DocDescription=@Description,ModifiedBy=@ModifiedBy,ModifiedDate=@ModifiedDate where 
			CompanyId=@CompanyId and Id=@DocumentId 

		 ----For Audit trial 
			Insert Into @BCDocumentHistoryType(TransactionId,CompanyId,DocumentId,DocType,DocSubType,DocState,DocCurrency,DocAmount,DocBalanaceAmount,ExchangeRate,BaseAmount,BaseBalanaceAmount,StateChangedBy,PostingDate,DocAppliedAmount,BaseAppliedAmount)
			Select @DocumentId,CompanyId,@DocumentId,@DocType,
			'Genaral',DocumentState,ExCurrency,0 As DocAmount,0 As DocBalanceAmount,ExchangeRate, 0  As BaseAmount,0 As BaseBalanceAmount,ISNULL(ModifiedBy,UserCreated),TransferDate, 0  As DocAppliedAmount, 0  As BaseAppliedAmount From Bean.BankTransfer Where Id=@DocumentId
			Exec [dbo].[Bean_DocumentHistory] @BCDocumentHistoryType
		End

		Else if (@DocType=@CMAppDocument)
		Begin
		IF(@Version is not NULL)
			Begin
				Select @TimeStamp=( CONVERT(NVARCHAR(200), CONVERT(BINARY(8), I.Version), 1)),@MasterId=CreditMemoId from Bean.CreditMemoApplication(nolock) I where Id=@DocumentId and CompanyId=@CompanyId
				IF @TimeStamp is not NULL and @TimeStamp<>@Version
				Begin
					RAISERROR('The document had been modified. Please refresh before proceeding.',16,1);
				End
			End
		if(@Description is not null AND (@AccountDescription='' or @AccountDescription is null))
		Begin
			Update Jd Set Jd.AccountDescription=@Description from Bean.Journal J join Bean.JournalDetail Jd  on J.Id=JournalId
			where CompanyId=@CompanyId and J.DocumentId=@DocumentId  and (JD.IsTax=1 or JD.DocumentDetailId='00000000-0000-0000-0000-000000000000')
			Update bean.CreditMemoApplicationDetail Set DocDescription=@Description where CreditMemoApplicationId=@DocumentId and (DocDescription is  null OR DocDescription='')
		End 

		--Start
		Else If(@AccountDescription<>'' and @AccountDescription is not null)
		Begin
			Update CD Set CD.DocDescription=Acc.AccountDesc from Bean.CreditMemoApplication C Join Bean.CreditMemoApplicationDetail CD on C.Id=CD.CreditMemoApplicationId 
			Join @AccountDescTable Acc on Acc.DetailDocId=CD.Id where C.Id=@DocumentId and C.CompanyId=@companyId

			Update JD Set JD.AccountDescription=Case When (JD.IsTax=1 or JD.DocumentDetailId='00000000-0000-0000-0000-000000000000') Then @Description Else CD.DocDescription End  from Bean.CreditMemoApplication C
			Join Bean.CreditMemoApplicationDetail CD on C.Id=CD.CreditMemoApplicationId
			Join Bean.Journal J on J.DocumentId=C.Id
			join Bean.JournalDetail Jd  on Jd.JournalId=J.Id --and JD.DocumentId=@DocumentId
			where C.CompanyId=@CompanyId and C.Id=@DocumentId and Jd.DocumentId=@DocumentId and CD.Id=Jd.DocumentDetailId and Jd.IsTax<>1

			Update Bean.Journaldetail Set AccountDescription=@Description where documentId=@DocumentId and (Istax=1 or DocumentDetailId='00000000-0000-0000-0000-000000000000')
		End
		--End

		Update Bean.Journal Set DocumentDescription=@Description,PoNo=@PoNo,IsNoSupportingDocs=@IsNoSupportingDocs,NoSupportingDocument=@NoSupportingDocument,ModifiedBy=@ModifiedBy,ModifiedDate=@ModifiedDate where CompanyId=@CompanyId and DocumentId=@DocumentId 
		Update Bean.CreditMemoApplication Set																												 IsNoSupportingDocument=@IsNoSupportingDocs,Remarks=@Description,	ModifiedBy=@ModifiedBy,ModifiedDate=@ModifiedDate where 
			  CompanyId=@CompanyId and Id=@DocumentId 

			  Select @DocCurrency=DocCurrency,@ExchangeRate=ExchangeRate from Bean.CreditMemo(nolock) where id=@MasterId and CompanyId=@CompanyId

		 ----For Audit trial 
			Insert Into @BCDocumentHistoryType(TransactionId,CompanyId,DocumentId,DocType,DocSubType,DocState,DocCurrency,DocAmount,DocBalanaceAmount,ExchangeRate,BaseAmount,BaseBalanaceAmount,StateChangedBy,PostingDate,DocAppliedAmount,BaseAppliedAmount)
			Select @DocumentId,CompanyId,@DocumentId,@CreditMemoDocument,
			'Application','Posted',@DocCurrency,Round(CreditAmount,2) As DocAmount,Round(CreditAmount,2) As DocBalanceAmount,@ExchangeRate, Round(CreditAmount*@ExchangeRate,2)  As BaseAmount,Round(CreditAmount*@ExchangeRate,2) As BaseBalanceAmount,ISNULL(ModifiedBy,UserCreated),CreditMemoApplicationDate ,Round(CreditAmount,2) As DocAppliedAmount, Round(CreditAmount*@ExchangeRate,2)  As BaseAppliedAmount From Bean.CreditMemoApplication Where Id=@DocumentId
			Exec [dbo].[Bean_DocumentHistory] @BCDocumentHistoryType
		End

		Else if (@DocType=@CNAppDocument)
		Begin
		IF(@Version is not NULL)
			Begin
				Select @TimeStamp=( CONVERT(NVARCHAR(200), CONVERT(BINARY(8), I.Version), 1)),@MasterId=InvoiceId from Bean.CreditNoteApplication(nolock) I where Id=@DocumentId and CompanyId=@CompanyId
				IF @TimeStamp is not NULL and @TimeStamp<>@Version
				Begin
					RAISERROR('The document had been modified. Please refresh before proceeding.',16,1);
				End
			End
		if(@Description is not null AND (@AccountDescription='' or @AccountDescription is null))
		Begin
			Update Jd Set Jd.AccountDescription=@Description from Bean.Journal J join Bean.JournalDetail Jd  on J.Id=JournalId
			where CompanyId=@CompanyId and J.DocumentId=@DocumentId  and (JD.IsTax=1 or JD.DocumentDetailId='00000000-0000-0000-0000-000000000000')
			Update bean.CreditNoteApplicationDetail Set DocDescription=@Description where CreditNoteApplicationId=@DocumentId and (DocDescription is  null OR DocDescription='')
		End 

		--Start
		Else If(@AccountDescription<>'' and @AccountDescription is not null)
		Begin
			Update CD Set CD.DocDescription=Acc.AccountDesc from Bean.CreditNoteApplication C Join Bean.CreditNoteApplicationDetail CD on C.Id=CD.CreditNoteApplicationId 
			Join @AccountDescTable Acc on Acc.DetailDocId=CD.Id where C.Id=@DocumentId and C.CompanyId=@companyId

			Update JD Set JD.AccountDescription=Case When (JD.IsTax=1 or JD.DocumentDetailId='00000000-0000-0000-0000-000000000000') Then @Description Else CD.DocDescription End  from Bean.CreditNoteApplication C
			Join Bean.CreditNoteApplicationDetail CD on C.Id=CD.CreditNoteApplicationId
			Join Bean.Journal J on J.DocumentId=C.Id
			join Bean.JournalDetail Jd  on Jd.JournalId=J.Id --and JD.DocumentId=@DocumentId
			where C.CompanyId=@CompanyId and C.Id=@DocumentId and Jd.DocumentId=@DocumentId and CD.Id=Jd.DocumentDetailId and Jd.IsTax<>1

			Update Bean.Journaldetail Set AccountDescription=@Description where documentId=@DocumentId and (Istax=1 or DocumentDetailId='00000000-0000-0000-0000-000000000000')
		End
		--End

		Update Bean.Journal Set DocumentDescription=@Description,PoNo=@PoNo,IsNoSupportingDocs=@IsNoSupportingDocs,NoSupportingDocument=@NoSupportingDocument,ModifiedBy=@ModifiedBy,ModifiedDate=@ModifiedDate where CompanyId=@CompanyId and DocumentId=@DocumentId 
		Update Bean.CreditNoteApplication Set																												 IsNoSupportingDocument=@IsNoSupportingDocs,Remarks=@Description,	ModifiedBy=@ModifiedBy,ModifiedDate=@ModifiedDate where 
			  CompanyId=@CompanyId and Id=@DocumentId 

			  Select @DocCurrency=DocCurrency,@ExchangeRate=ExchangeRate from Bean.Invoice(nolock) where id=@MasterId and CompanyId=@CompanyId

		 ----For Audit trial 
			Insert Into @BCDocumentHistoryType(TransactionId,CompanyId,DocumentId,DocType,DocSubType,DocState,DocCurrency,DocAmount,DocBalanaceAmount,ExchangeRate,BaseAmount,BaseBalanaceAmount,StateChangedBy,PostingDate,DocAppliedAmount,BaseAppliedAmount)
			Select @DocumentId,CompanyId,@DocumentId,@CreditNote,
			'Application','Posted',@DocCurrency,Round(CreditAmount,2) As DocAmount,Round(CreditAmount,2) As DocBalanceAmount,@ExchangeRate,Round(CreditAmount*@ExchangeRate,2)  As BaseAmount,Round(CreditAmount*@ExchangeRate,2) As BaseBalanceAmount,ISNULL(ModifiedBy,UserCreated),CreditNoteApplicationDate ,Round(CreditAmount,2) As DocAppliedAmount, Round(CreditAmount*@ExchangeRate,2)  As BaseAppliedAmount From Bean.CreditNoteApplication Where Id=@DocumentId
			Exec [dbo].[Bean_DocumentHistory] @BCDocumentHistoryType
		End

		Commit Transaction
	End Try
	Begin Catch
		RollBack Transaction 
		Select @ErrorMessage=ERROR_MESSAGE(),
			   @ErrorServirity=ERROR_SEVERITY(),
			   @ErrorState=ERROR_STATE()
		RAISERROR(@ErrorMessage,@ErrorServirity,@ErrorState)
	End Catch
End
GO
