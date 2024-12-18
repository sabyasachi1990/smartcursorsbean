USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[Bean_Update_Locked_Flag]    Script Date: 16-12-2024 9.20.10 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE   Procedure [dbo].[Bean_Update_Locked_Flag]
(
@DocumentId UniqueIdentifier, 
@CompanyId Bigint, 
@DocType Nvarchar(30), 
@DocSubType NvarChar(30), 
@IsLocked bit,
@ModifiedBy nvarchar(300), 
@ModifiedDate DateTime2(7), 
@Version nvarchar(200) 
)
As 
Begin
	Declare @ErrorMessage Nvarchar(1000), @ErrorServirity Int, @ErrorState Int
	Declare @TimeStamp nvarchar(100), @DocumentState Nvarchar(30)
	Declare @InvoiceDocument Nvarchar(50)='Invoice', @DebitNoteDocument nvarchar(50)='Debit Note',
	@CreditNote nvarchar(50)='Credit Note',@DebitProvision nvarchar(50)='Debt Provision',
	@BillDocument nvarchar(30)='Bill',@CreditMemoDocument nvarchar(30)='Credit Memo', @DepositDocument nvarchar(50)='Deposit', @WithdrawalDocument nvarchar(50)='Withdrawal', @JournalDocument Nvarchar(50)='Journal',@CashpaymentDocument nvarchar(50)='Cash Payment', @CashSaleDocument Nvarchar(50)='Cash Sale', @ReceiptDocument nvarchar(50)='Receipt', @PaymentDocument nvarchar(50)='Bill Payment', @TransferDocument nvarchar(50)='Transfer',@General nvarchar(50)='General',@Application nvarchar(50)='Application', @Allocation nvarchar(25)='Allocation',@BankRecon nvarchar(30)='Bank Reconciliation',@ClearingDocument nvarchar(15)='Clearing',@RevalDoc nvarchar(30)='Reval',@OpeningBalDocument nvarchar(20)='Opening Bal', @Status int=0 
	Declare @VersionErrorMessage Nvarchar(300) ='The document had been modified. Please refresh before proceeding.'
	Declare @BCDocumentHistoryType DocumentHistoryTableType
	Begin Try
	Begin Transaction
		If((@DocType = @InvoiceDocument or @DocType=@CreditNote OR @DocType=@DebitProvision) and @DocSubType != @Application and @DocSubType != @Allocation)
		Begin
			IF(@Version is not NULL)
			Begin
					Select @TimeStamp=( CONVERT(NVARCHAR(200), CONVERT(BINARY(8), I.Version), 1)),@DocumentState=(i.DocumentState) from Bean.Invoice(nolock) I where Id=@DocumentId and CompanyId=@CompanyId
					IF @TimeStamp is not NULL and @TimeStamp<>@Version
					Begin
						RAISERROR(@VersionErrorMessage,16,1);
					End
					If(@DocumentState is not null)
					Begin
						Update Bean.Invoice Set IsLocked=@IsLocked,ModifiedBy=@ModifiedBy,ModifiedDate=@ModifiedDate where CompanyId=@CompanyId and Id=@DocumentId and DocType=@DocType

						----For Audit trial 
						Insert Into @BCDocumentHistoryType(TransactionId,CompanyId,DocumentId,DocType,DocSubType,DocState,DocCurrency,DocAmount,DocBalanaceAmount,ExchangeRate,BaseAmount,BaseBalanaceAmount,StateChangedBy,PostingDate,DocAppliedAmount,BaseAppliedAmount)
						Select @DocumentId,CompanyId,@DocumentId,DocType,DocSubType,DocumentState,DocCurrency,IsNull(BaseGrandTotal,0) As DocAmount,Round(BalanceAmount,2) As DocBalanceAmount,ExchangeRate, IsNull(BaseGrandTotal,0)  As BaseAmount,Round(BalanceAmount*ExchangeRate,2) As BaseBalanceAmount,ISNULL(ModifiedBy,UserCreated),  DocDate,Case When DocumentState='Not Paid' or DocumentState='Not Applied' or DocumentState='Not Allocated' Then GrandTotal Else 0 End As DocAppliedAmount, Case When DocumentState='Not Paid' or DocumentState='Not Applied' or DocumentState='Not Allocated' Then  BaseGrandTotal Else 0 End  As BaseAppliedAmount From Bean.Invoice(nolock) Where Id=@DocumentId and CompanyId=@CompanyId and DocType=@DocType
						Exec [dbo].[Bean_DocumentHistory] @BCDocumentHistoryType

					End
			End
		End
		If(@DocType=@DebitProvision and @DocSubType=@Allocation)
		Begin
			IF(@Version is not NULL)
			Begin
					Select @TimeStamp=( CONVERT(NVARCHAR(200), CONVERT(BINARY(8), I.Version), 1)),@Status=(i.Status) from Bean.DoubtfulDebtAllocation(nolock) I where Id=@DocumentId and CompanyId=@CompanyId
					IF @TimeStamp is not NULL and @TimeStamp<>@Version
					Begin
						RAISERROR(@VersionErrorMessage,16,1);
					End
					If(@Status<>0)
					Begin
						Update Bean.DoubtfulDebtAllocation Set IsLocked=@IsLocked,ModifiedBy=@ModifiedBy,ModifiedDate=@ModifiedDate where CompanyId=@CompanyId and Id=@DocumentId

						----For Audit trial 
						Insert Into @BCDocumentHistoryType(TransactionId,CompanyId,DocumentId,DocType,DocSubType,DocState,DocCurrency,DocAmount,DocBalanaceAmount,ExchangeRate,BaseAmount,BaseBalanaceAmount,StateChangedBy,PostingDate,DocAppliedAmount,BaseAppliedAmount)
						Select @DocumentId,INV.CompanyId,@DocumentId,@DocType,@DocSubType,INV.DocumentState,INV.DocCurrency,AllocateAmount As DocAmount,Round(INV.BalanceAmount,2) As DocBalanceAmount,INV.ExchangeRate, Round(DDA.AllocateAmount*INV.ExchangeRate,2) As BaseAmount,Round(DDA.AllocateAmount*INV.ExchangeRate,2) As BaseBalanceAmount,ISNULL(DDA.ModifiedBy,DDA.UserCreated),  DDA.DoubtfulDebtAllocationDate,AllocateAmount As DocAppliedAmount, ROUND(AllocateAmount*INV.ExchangeRate,2) As BaseAppliedAmount 
						From Bean.Invoice(nolock) INV inner join Bean.DoubtfulDebtAllocation(nolock) DDA on DDA.InvoiceId=INV.Id
							 Where DDA.Id=@DocumentId

 						Exec [dbo].[Bean_DocumentHistory] @BCDocumentHistoryType

					End
			End
		End
		If(@DocType = @DebitNoteDocument)
		Begin
			IF(@Version is not NULL)
			Begin
					Select @TimeStamp=( CONVERT(NVARCHAR(200), CONVERT(BINARY(8), I.Version), 1)),@DocumentState=(i.DocumentState) from Bean.DebitNote(nolock) I where Id=@DocumentId and CompanyId=@CompanyId
					IF @TimeStamp is not NULL and @TimeStamp<>@Version
					Begin
						RAISERROR(@VersionErrorMessage,16,1);
					End
					If(@DocumentState is not null)
					Begin
						Update Bean.DebitNote Set IsLocked=@IsLocked,ModifiedBy=@ModifiedBy,ModifiedDate=@ModifiedDate where CompanyId=@CompanyId and Id=@DocumentId

						----For Audit trial 
						Insert Into @BCDocumentHistoryType(TransactionId,CompanyId,DocumentId,DocType,DocSubType,DocState,DocCurrency,DocAmount,DocBalanaceAmount,ExchangeRate,BaseAmount,BaseBalanaceAmount,StateChangedBy,PostingDate,DocAppliedAmount,BaseAppliedAmount)
						Select @DocumentId,CompanyId,@DocumentId,@DocType,Case When Nature='Interco' Then Nature Else @General End,DocumentState,DocCurrency,BaseGrandTotal As DocAmount,Round(BalanceAmount,2) As DocBalanceAmount,ExchangeRate, BaseGrandTotal  As BaseAmount,Round(BalanceAmount*ExchangeRate,2) As BaseBalanceAmount,ISNULL(ModifiedBy,UserCreated),  DocDate,Case When DocumentState='Not Paid' Then GrandTotal Else 0 End As DocAppliedAmount, Case When DocumentState='Not Paid' Then  BaseGrandTotal Else 0 End  As BaseAppliedAmount From Bean.DebitNote(nolock) Where Id=@DocumentId
						Exec [dbo].[Bean_DocumentHistory] @BCDocumentHistoryType

					End
			End
		End
		If(@DocType = @CreditNote AND @DocSubType=@Application)
		Begin
			IF(@Version is not NULL)
			Begin
					Select @TimeStamp=( CONVERT(NVARCHAR(200), CONVERT(BINARY(8), I.Version), 1)),@Status=(i.Status) from Bean.CreditNoteApplication(nolock) I where Id=@DocumentId and CompanyId=@CompanyId
					IF @TimeStamp is not NULL and @TimeStamp<>@Version
					Begin
						RAISERROR(@VersionErrorMessage,16,1);
					End
					If(@Status<>0)
					Begin
						Update Bean.CreditNoteApplication Set IsLocked=@IsLocked,ModifiedBy=@ModifiedBy,ModifiedDate=@ModifiedDate where CompanyId=@CompanyId and Id=@DocumentId

						----For Audit trial 
						Insert Into @BCDocumentHistoryType(TransactionId,CompanyId,DocumentId,DocType,DocSubType,DocState,DocCurrency,DocAmount,DocBalanaceAmount,ExchangeRate,BaseAmount,BaseBalanaceAmount,StateChangedBy,PostingDate,DocAppliedAmount,BaseAppliedAmount)
						Select @DocumentId,INV.CompanyId,@DocumentId,@DocType,@DocSubType,INV.DocumentState,INV.DocCurrency,CreditAmount As DocAmount,Round(INV.BalanceAmount,2) As DocBalanceAmount,CNA.ExchangeRate, INV.BaseGrandTotal As BaseAmount,Round(INV.BalanceAmount*CNA.ExchangeRate,2) As BaseBalanceAmount,ISNULL(CNA.ModifiedBy,CNA.UserCreated),  CNA.CreditNoteApplicationDate,CreditAmount As DocAppliedAmount, ROUND(CreditAmount*CNA.ExchangeRate,2) As BaseAppliedAmount 
						From Bean.Invoice(nolock) INV inner join Bean.CreditNoteApplication(nolock) CNA on CNA.InvoiceId=INV.Id
							 Where CNA.Id=@DocumentId

 						Exec [dbo].[Bean_DocumentHistory] @BCDocumentHistoryType

					End
			End
		End
		If(@DocType = @CashSaleDocument)
		Begin
			IF(@Version is not NULL)
			Begin
					Select @TimeStamp=( CONVERT(NVARCHAR(200), CONVERT(BINARY(8), I.Version), 1)),@DocumentState=(i.DocumentState) from Bean.CashSale(nolock) I where Id=@DocumentId and CompanyId=@CompanyId
					IF @TimeStamp is not NULL and @TimeStamp<>@Version
					Begin
						RAISERROR(@VersionErrorMessage,16,1);
					End
					If(@DocumentState is not null)
					Begin
						Update Bean.CashSale Set IsLocked=@IsLocked,ModifiedBy=@ModifiedBy,ModifiedDate=@ModifiedDate where CompanyId=@CompanyId and Id=@DocumentId

						----For Audit trial 
						Insert Into @BCDocumentHistoryType(TransactionId,CompanyId,DocumentId,DocType,DocSubType,DocState,DocCurrency,DocAmount,DocBalanaceAmount,ExchangeRate,BaseAmount,BaseBalanaceAmount,StateChangedBy,PostingDate,DocAppliedAmount,BaseAppliedAmount)
						Select @DocumentId,CompanyId,@DocumentId,@DocType,
						@General,DocumentState,DocCurrency,Round(GrandTotal,2) As DocAmount,Round(GrandTotal,2) As DocBalanceAmount,ExchangeRate,0  As BaseAmount,Round(GrandTotal*ExchangeRate,2) As BaseBalanceAmount,ISNULL(ModifiedBy,UserCreated),DocDate, Round(GrandTotal,2)  As DocAppliedAmount, Round(GrandTotal*ExchangeRate,2)  As BaseAppliedAmount From Bean.CashSale Where Id=@DocumentId
						Exec [dbo].[Bean_DocumentHistory] @BCDocumentHistoryType

					End
			End
		End
		If(@DocType = @ReceiptDocument)
		Begin
			IF(@Version is not NULL)
			Begin
					Select @TimeStamp=( CONVERT(NVARCHAR(200), CONVERT(BINARY(8), I.Version), 1)),@DocumentState=(i.DocumentState) from Bean.Receipt(nolock) I where Id=@DocumentId and CompanyId=@CompanyId
					IF @TimeStamp is not NULL and @TimeStamp<>@Version
					Begin
						RAISERROR(@VersionErrorMessage,16,1);
					End
					If(@DocumentState is not null)
					Begin
						Update Bean.Receipt Set IsLocked=@IsLocked,ModifiedBy=@ModifiedBy,ModifiedDate=@ModifiedDate where CompanyId=@CompanyId and Id=@DocumentId

						----For Audit trial 
						Insert Into @BCDocumentHistoryType(TransactionId,CompanyId,DocumentId,DocType,DocSubType,DocState,DocCurrency,DocAmount,DocBalanaceAmount,ExchangeRate,BaseAmount,BaseBalanaceAmount,StateChangedBy,PostingDate,DocAppliedAmount,BaseAppliedAmount)
						Select @DocumentId,CompanyId,@DocumentId,@DocType,
						@General,DocumentState,DocCurrency,Round(GrandTotal,2) As DocAmount,Round(GrandTotal,2) As DocBalanceAmount,ExchangeRate, 0  As BaseAmount,Round(GrandTotal*ExchangeRate,2) As BaseBalanceAmount,ISNULL(ModifiedBy,UserCreated),DocDate, 0  As DocAppliedAmount, 0  As BaseAppliedAmount From Bean.Receipt(nolock) Where Id=@DocumentId
						Exec [dbo].[Bean_DocumentHistory] @BCDocumentHistoryType

					End
			End
		End
		If(@DocType = @BillDocument)
		Begin
			IF(@Version is not NULL)
			Begin
					Select @TimeStamp=( CONVERT(NVARCHAR(200), CONVERT(BINARY(8), I.Version), 1)),@DocumentState=(i.DocumentState) from Bean.Bill(nolock) I where Id=@DocumentId and CompanyId=@CompanyId
					IF @TimeStamp is not NULL and @TimeStamp<>@Version
					Begin
						RAISERROR(@VersionErrorMessage,16,1);
					End
					If(@DocumentState is not null)
					Begin
						Update Bean.Bill Set IsLocked=@IsLocked,ModifiedBy=@ModifiedBy,ModifiedDate=@ModifiedDate where CompanyId=@CompanyId and Id=@DocumentId

						----For Audit trial 
						Insert Into @BCDocumentHistoryType(TransactionId,CompanyId,DocumentId,DocType,DocSubType,DocState,DocCurrency,DocAmount,DocBalanaceAmount,ExchangeRate,BaseAmount,BaseBalanaceAmount,StateChangedBy,PostingDate,DocAppliedAmount,BaseAppliedAmount)
						Select @DocumentId,CompanyId,@DocumentId,@DocType,
						@DocSubType,DocumentState,DocCurrency,Round(GrandTotal,2) As DocAmount,Round(GrandTotal,2) As DocBalanceAmount,ExchangeRate,0  As BaseAmount,Round(GrandTotal*ExchangeRate,2) As BaseBalanceAmount,ISNULL(ModifiedBy,UserCreated),PostingDate, Case When DocumentState='Not Paid' Then GrandTotal Else 0 End As DocAppliedAmount, Case When DocumentState='Not Paid' Then  BaseGrandTotal Else 0 End  As BaseAppliedAmount From Bean.Bill(nolock) Where Id=@DocumentId
						Exec [dbo].[Bean_DocumentHistory] @BCDocumentHistoryType

					End
			End
		End
		If(@DocType = @CreditMemoDocument AND @DocSubType!=@Application)
		Begin
			IF(@Version is not NULL)
			Begin
					Select @TimeStamp=( CONVERT(NVARCHAR(200), CONVERT(BINARY(8), I.Version), 1)),@DocumentState=(i.DocumentState) from Bean.CreditMemo(nolock) I where Id=@DocumentId and CompanyId=@CompanyId
					IF @TimeStamp is not NULL and @TimeStamp<>@Version
					Begin
						RAISERROR(@VersionErrorMessage,16,1);
					End
					If(@DocumentState is not null)
					Begin
						Update Bean.CreditMemo Set IsLocked=@IsLocked,ModifiedBy=@ModifiedBy,ModifiedDate=@ModifiedDate where CompanyId=@CompanyId and Id=@DocumentId

						----For Audit trial 
						Insert Into @BCDocumentHistoryType(TransactionId,CompanyId,DocumentId,DocType,DocSubType,DocState,DocCurrency,DocAmount,DocBalanaceAmount,ExchangeRate,BaseAmount,BaseBalanaceAmount,StateChangedBy,PostingDate,DocAppliedAmount,BaseAppliedAmount)
						Select @DocumentId,CompanyId,@DocumentId,@DocType,
						@General,DocumentState,DocCurrency,Round(GrandTotal,2) As DocAmount,Round(GrandTotal,2) As DocBalanceAmount,ExchangeRate,0  As BaseAmount,Round(BalanceAmount*ExchangeRate,2) As BaseBalanceAmount,ISNULL(ModifiedBy,UserCreated),PostingDate, Case When DocumentState='Not Applied' Then GrandTotal Else 0 End As DocAppliedAmount, Case When DocumentState='Not Applied' Then  BaseGrandTotal Else 0 End  As BaseAppliedAmount From Bean.CreditMemo(nolock) Where Id=@DocumentId
						Exec [dbo].[Bean_DocumentHistory] @BCDocumentHistoryType

					End
			End
		End
		If(@DocType = @CreditMemoDocument AND @DocSubType=@Application)
		Begin
			IF(@Version is not NULL)
			Begin
					Select @TimeStamp=( CONVERT(NVARCHAR(200), CONVERT(BINARY(8), I.Version), 1)),@Status=(i.Status) from Bean.CreditMemoApplication(nolock) I where Id=@DocumentId and CompanyId=@CompanyId
					IF @TimeStamp is not NULL and @TimeStamp<>@Version
					Begin
						RAISERROR(@VersionErrorMessage,16,1);
					End
					If(@Status<>0)
					Begin
						Update Bean.CreditMemoApplication Set IsLocked=@IsLocked,ModifiedBy=@ModifiedBy,ModifiedDate=@ModifiedDate where CompanyId=@CompanyId and Id=@DocumentId

						----For Audit trial 
						Insert Into @BCDocumentHistoryType(TransactionId,CompanyId,DocumentId,DocType,DocSubType,DocState,DocCurrency,DocAmount,DocBalanaceAmount,ExchangeRate,BaseAmount,BaseBalanaceAmount,StateChangedBy,PostingDate,DocAppliedAmount,BaseAppliedAmount)
						Select @DocumentId,INV.CompanyId,@DocumentId,@DocType,@DocSubType,INV.DocumentState,INV.DocCurrency,CreditAmount As DocAmount,Round(INV.BalanceAmount,2) As DocBalanceAmount,CNA.ExchangeRate, INV.BaseGrandTotal As BaseAmount,Round(INV.BalanceAmount*CNA.ExchangeRate,2) As BaseBalanceAmount,ISNULL(CNA.ModifiedBy,CNA.UserCreated),  CNA.CreditMemoApplicationDate,CreditAmount As DocAppliedAmount, ROUND(CreditAmount*CNA.ExchangeRate,2) As BaseAppliedAmount 
						From Bean.CreditMemo(nolock) INV inner join Bean.CreditMemoApplication(nolock) CNA on CNA.CreditMemoId=INV.Id
							 Where CNA.Id=@DocumentId

 						Exec [dbo].[Bean_DocumentHistory] @BCDocumentHistoryType

					End
			End
		End
		If(@DocType = @PaymentDocument)
		Begin
			IF(@Version is not NULL)
			Begin
					Select @TimeStamp=( CONVERT(NVARCHAR(200), CONVERT(BINARY(8), I.Version), 1)),@DocumentState=(i.DocumentState) from Bean.Payment(nolock) I where Id=@DocumentId and CompanyId=@CompanyId
					IF @TimeStamp is not NULL and @TimeStamp<>@Version
					Begin
						RAISERROR(@VersionErrorMessage,16,1);
					End
					If(@DocumentState is not null)
					Begin
						Update Bean.Payment Set IsLocked=@IsLocked,ModifiedBy=@ModifiedBy,ModifiedDate=@ModifiedDate where CompanyId=@CompanyId and Id=@DocumentId

						----For Audit trial 
						Insert Into @BCDocumentHistoryType(TransactionId,CompanyId,DocumentId,DocType,DocSubType,DocState,DocCurrency,DocAmount,DocBalanaceAmount,ExchangeRate,BaseAmount,BaseBalanaceAmount,StateChangedBy,PostingDate,DocAppliedAmount,BaseAppliedAmount)
						Select @DocumentId,CompanyId,@DocumentId,@DocType,
						'Genaral',DocumentState,DocCurrency,Round(GrandTotal,2) As DocAmount,Round(GrandTotal,2) As DocBalanceAmount,ExchangeRate, 0  As BaseAmount,0 As BaseBalanceAmount,ISNULL(ModifiedBy,UserCreated),DocDate, 0  As DocAppliedAmount, 0  As BaseAppliedAmount From Bean.Payment(nolock) Where Id=@DocumentId
						Exec [dbo].[Bean_DocumentHistory] @BCDocumentHistoryType

					End
			End
		End
		If(@DocType = @WithdrawalDocument OR @DocType = @DepositDocument OR @DocType = @CashpaymentDocument)
		Begin
			IF(@Version is not NULL)
			Begin
					Select @TimeStamp=( CONVERT(NVARCHAR(200), CONVERT(BINARY(8), I.Version), 1)),@DocumentState=(i.DocumentState) from Bean.WithDrawal(nolock) I where Id=@DocumentId and CompanyId=@CompanyId
					IF @TimeStamp is not NULL and @TimeStamp<>@Version
					Begin
						RAISERROR(@VersionErrorMessage,16,1);
					End
					If(@DocumentState is not null)
					Begin
						Update Bean.WithDrawal Set IsLocked=@IsLocked,ModifiedBy=@ModifiedBy,ModifiedDate=@ModifiedDate where CompanyId=@CompanyId and Id=@DocumentId

						----For Audit trial 
						Insert Into @BCDocumentHistoryType(TransactionId,CompanyId,DocumentId,DocType,DocSubType,DocState,DocCurrency,DocAmount,DocBalanaceAmount,ExchangeRate,BaseAmount,BaseBalanaceAmount,StateChangedBy,PostingDate,DocAppliedAmount,BaseAppliedAmount)
						Select @DocumentId,CompanyId,@DocumentId,@DocType,
						@General,DocumentState,DocCurrency,Round(GrandTotal,2) As DocAmount,Round(GrandTotal,2) As DocBalanceAmount,ExchangeRate,0  As BaseAmount,Round(GrandTotal*ExchangeRate,2) As BaseBalanceAmount,ISNULL(ModifiedBy,UserCreated),DocDate, Round(GrandTotal,2)  As DocAppliedAmount, Round(GrandTotal*ExchangeRate,2)  As BaseAppliedAmount From Bean.WithDrawal(nolock) Where Id=@DocumentId
						Exec [dbo].[Bean_DocumentHistory] @BCDocumentHistoryType

					End
			End
		End
		If(@DocType = @TransferDocument)
		Begin
			IF(@Version is not NULL)
			Begin
					Select @TimeStamp=( CONVERT(NVARCHAR(200), CONVERT(BINARY(8), I.Version), 1)),@DocumentState=(i.DocumentState) from Bean.BankTransfer(nolock) I where Id=@DocumentId and CompanyId=@CompanyId
					IF @TimeStamp is not NULL and @TimeStamp<>@Version
					Begin
						RAISERROR(@VersionErrorMessage,16,1);
					End
					If(@DocumentState is not null)
					Begin
						Update Bean.BankTransfer Set IsLocked=@IsLocked,ModifiedBy=@ModifiedBy,ModifiedDate=@ModifiedDate where CompanyId=@CompanyId and Id=@DocumentId

						----For Audit trial 
						Insert Into @BCDocumentHistoryType(TransactionId,CompanyId,DocumentId,DocType,DocSubType,DocState,DocCurrency,DocAmount,DocBalanaceAmount,ExchangeRate,BaseAmount,BaseBalanaceAmount,StateChangedBy,PostingDate,DocAppliedAmount,BaseAppliedAmount)
						Select @DocumentId,CompanyId,@DocumentId,@DocType,
						@General,DocumentState,ExCurrency,0 As DocAmount,0 As DocBalanceAmount,ExchangeRate,0  As BaseAmount,0 As BaseBalanceAmount,ISNULL(ModifiedBy,UserCreated),TransferDate, 0  As DocAppliedAmount, 0  As BaseAppliedAmount From Bean.BankTransfer(nolock) Where Id=@DocumentId
						Exec [dbo].[Bean_DocumentHistory] @BCDocumentHistoryType

					End
			End
		End
		If(@DocType=@JournalDocument)
		Begin
			IF(@Version is not NULL)
			Begin
					Select @TimeStamp=( CONVERT(NVARCHAR(200), CONVERT(BINARY(8), I.Version), 1)),@DocumentState=(i.DocumentState) from Bean.Journal(nolock) I where Id=@DocumentId and CompanyId=@CompanyId
					IF @TimeStamp is not NULL and @TimeStamp<>@Version
					Begin
						RAISERROR(@VersionErrorMessage,16,1);
					End
					If(@DocumentState is not null)
					Begin
						Update Bean.Journal Set IsLocked=@IsLocked,ModifiedBy=@ModifiedBy,ModifiedDate=@ModifiedDate where CompanyId=@CompanyId and Id=@DocumentId
											 
					End
			End
		End
		if(@DocType=@BankRecon)
		Begin
			IF(@Version is not NULL)
			Begin
				Select @TimeStamp=( CONVERT(NVARCHAR(200), CONVERT(BINARY(8), I.Version), 1)),@DocumentState=(i.State) from Bean.BankReconciliation(nolock) I where Id=@DocumentId and CompanyId=@CompanyId
				IF @TimeStamp is not NULL and @TimeStamp<>@Version
				Begin
					RAISERROR(@VersionErrorMessage,16,1);
				End
				If(@DocumentState is not null)
				Begin
					Update Bean.BankReconciliation Set IsLocked=@IsLocked,ModifiedBy=@ModifiedBy,ModifiedDate=@ModifiedDate where CompanyId=@CompanyId and Id=@DocumentId

					----For Audit trial 
					Insert Into @BCDocumentHistoryType(TransactionId,CompanyId,DocumentId,DocType,DocSubType,DocState,DocCurrency,DocAmount,DocBalanaceAmount,ExchangeRate,BaseAmount,BaseBalanaceAmount,StateChangedBy,PostingDate,DocAppliedAmount,BaseAppliedAmount)
					Select @DocumentId,CompanyId,@DocumentId,@DocType,
					@doctype,State,'',StatementAmount As DocAmount,0 As DocBalanceAmount,null,0  As BaseAmount,StatementAmount As BaseBalanceAmount,ISNULL(ModifiedBy,UserCreated),BankReconciliationDate, 0  As DocAppliedAmount, 0  As BaseAppliedAmount From Bean.BankReconciliation Where Id=@DocumentId
					Exec [dbo].[Bean_DocumentHistory] @BCDocumentHistoryType

				End
			End
	  End
		if(@DocType=@ClearingDocument)
		Begin
			IF(@Version is not NULL)
			Begin
				Select @TimeStamp=( CONVERT(NVARCHAR(200), CONVERT(BINARY(8), I.Version), 1)),@DocumentState=(i.DocumentState) from Bean.GLClearing(nolock) I where Id=@DocumentId and CompanyId=@CompanyId
				IF @TimeStamp is not NULL and @TimeStamp<>@Version
				Begin
					RAISERROR(@VersionErrorMessage,16,1);
				End
				If(@DocumentState is not null)
				Begin
					Update Bean.GLClearing Set IsLocked=@IsLocked,ModifiedBy=@ModifiedBy,ModifiedDate=@ModifiedDate where CompanyId=@CompanyId and Id=@DocumentId
				End
			End
	  End
		If(@DocType = @RevalDoc)
		Begin
			IF(@Version is not NULL)
			Begin
					Select @TimeStamp=( CONVERT(NVARCHAR(200), CONVERT(BINARY(8), I.Version), 1)),@DocumentState=(i.DocState) from Bean.Revalution(nolock) I where Id=@DocumentId and CompanyId=@CompanyId
					IF @TimeStamp is not NULL and @TimeStamp<>@Version
					Begin
						RAISERROR(@VersionErrorMessage,16,1);
					End
					If(@DocumentState is not null)
					Begin
						Update Bean.Revalution Set IsLocked=@IsLocked,ModifiedBy=@ModifiedBy,ModifiedDate=@ModifiedDate where CompanyId=@CompanyId and Id=@DocumentId

					End
			End
		End
		if(@DocType=@OpeningBalDocument)
		Begin
			IF(@Version is not NULL)
			Begin
				Select @TimeStamp=( CONVERT(NVARCHAR(200), CONVERT(BINARY(8), I.Version), 1)),@DocumentState=(i.SaveType) from Bean.OpeningBalance(nolock) I where Id=@DocumentId and CompanyId=@CompanyId
				IF @TimeStamp is not NULL and @TimeStamp<>@Version
				Begin
					RAISERROR(@VersionErrorMessage,16,1);
				End
				If(@DocumentState is not null)
				Begin
					Update Bean.OpeningBalance Set IsLocked=@IsLocked,ModifiedBy=@ModifiedBy,ModifiedDate=@ModifiedDate where CompanyId=@CompanyId and Id=@DocumentId

					----For Audit trial 
					Insert Into @BCDocumentHistoryType(TransactionId,CompanyId,DocumentId,DocType,DocSubType,DocState,DocCurrency,DocAmount,DocBalanaceAmount,ExchangeRate,BaseAmount,BaseBalanaceAmount,StateChangedBy,PostingDate,DocAppliedAmount,BaseAppliedAmount)
					Select @DocumentId,CompanyId,@DocumentId,'Journal',
					@doctype,Case When SaveType='Save' Then'Posted' Else SaveType End,'',0 As DocAmount,0 As DocBalanceAmount,null,0  As BaseAmount,0 As BaseBalanceAmount,ISNULL(ModifiedBy,UserCreated),Date, 0  As DocAppliedAmount, 0  As BaseAppliedAmount From Bean.OpeningBalance Where Id=@DocumentId
					Exec [dbo].[Bean_DocumentHistory] @BCDocumentHistoryType

				End
			End
	  End
	Commit Transaction
	End Try
	Begin Catch
		Rollback Transaction
		Select @ErrorMessage=ERROR_MESSAGE(),
				   @ErrorServirity=ERROR_SEVERITY(),
				   @ErrorState=ERROR_STATE()
		RAISERROR(@ErrorMessage,@ErrorServirity,@ErrorState)
	End Catch
End

GO
