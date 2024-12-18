USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[Bean_Posting]    Script Date: 16-12-2024 9.20.10 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE   Procedure [dbo].[Bean_Posting] 
@SourceId Uniqueidentifier,
@Type Nvarchar(20),		--Invoice/DebitNote/CreditNote/Bill etc..
@CompanyId Int
As
Begin
	Declare @CreationTypeSystem varchar(20) = 'System';

	-- For Customer Balance Updation
	Declare @EntityId UniqueIdentifier

	-- Document Constants
	Declare @InvoiceDocument varchar(20) ='Invoice'
	Declare @DebitNoteDocument varchar(20) ='Debit Note'
	Declare @CreditNoteDocument varchar(20) ='Credit Note',
	@DebtProvisionDocument nvarchar(20)='Debt Provision'
	Declare @BillDocument varchar(20) ='Bill',
	@CreditMemoDocument nvarchar(20)='Credit Memo'
	Declare @DepositDocument varchar(20)='Deposit', @CashPaymentDocument varchar(20)='Cash Payment', @WithdrawalDocument varchar(20)='Withdrawal'
	Declare @CashSaleDocument Varchar(20)='Cash Sale'


	-- Nature
	Declare @NatureTrade varchar(20) = 'Trade'
	Declare @NatureOthers varchar(20) = 'Others'
	Declare @NatureInterco varchar(20) ='Interco'

	-- COA Names
	Declare @COATradeReceivables varchar(50) = 'Trade receivables'
	Declare @COAotherReceivables varchar(50) = 'Other receivables'
	Declare @COATaxPaybleGST Varchar(50)='Tax payable (GST)'
	Declare @COATradePayables varchar(50) = 'Trade payables'
	Declare @COAOtherPayables varchar(50) = 'Other payables'
	Declare @Rounding Varchar(50) ='Rounding'
	Declare @COADoubtfulDebtexpense varchar(50)='Doubtful debt expense'
	Declare @COADebt_Provision_AR varchar(50)='Debt provision (TR)'
	Declare @COADebt_Provision_OR varchar(50)='Debt provision (OR)'

	-- ZeroGUID
	Declare @GUIDZero Uniqueidentifier ='00000000-0000-0000-0000-000000000000'

	-- Local Variables
	Declare @JournalId Uniqueidentifier
	Declare @ErrorMessage Nvarchar(4000)
	Declare	@Count Int
	Declare @RecCount Int
	Declare @DetailId Uniqueidentifier
	Declare @IsAddNote bit=0
	--Declare @RecOrder Int
	Declare @TaxRate Float
	Declare @DocumentId Uniqueidentifier
	Declare @TaxRecCount Int
	Declare @TaxRecOrder Int = 1
	Declare @TypeNumber int = 0
	Declare @NA Char(2)='NA'
	Declare @Temp Table (S_No Int identity(1,1),DetailId Uniqueidentifier)
	Declare @BCDocumentHistoryType DocumentHistoryTableType

	---------For Interco
	Declare @ServiceEntityId BigInt
	Declare @Nature Nvarchar(20)
	Declare @ServiceEntityShortName Nvarchar(100)

	----For Base Debit and Base Credit Mis match
	Declare @BaseDebit Money
	Declare @BaseCredit Money
	Declare @DiffAmount Money
	Declare @MasterBaseAmount Money
	Declare @ExchangeRate Decimal(15,10)
	Declare @DocSubType nvarchar(30)

	----For DocSub Type
	Declare @DocSubTypeGeneral Nvarchar(25)='General', @NotAppliedState nvarchar(30)='Not Applied', @NotPaidState Nvarchar(50)='Not Paid',@NotAllocatedState nvarchar(30)='Not Allocated'

	-----For Brc Rerun
	Declare	@OldServEntityId BigInt,
		@NewServEntityId BigInt,
		@OldCoaId BigInt,
		@NewCoaId BigInt,
		@OldDocdate DateTime,
		@NewDocDate DateTime,
		@OldDocAmount Money,
		@NewDocAmount Money,
		@IsAdd bit,
		@IsBankAccountExists bit

	--Common Error Message
	Declare @InvalidDocumentError Nvarchar(200)='Invalid Document'
	
	---For Customer Balance updation
	Declare @OldEntityId UniqueIdentifier, @OldCustCreditLimit Money
	Declare @CustEntId nvarchar(max)

	Begin Transaction
		Begin Try
			If (@Type=@InvoiceDocument)
			Begin
				Set @DocumentId =(Select Id From Bean.Invoice (NOLOCK) Where DocumentId=@SourceId)

				---For Interco posting -- Get Service CompanyId by entityid
				Set @Nature=(select Nature from Bean.Invoice (NOLOCK) where Id=@SourceId)
				If(@Nature=@NatureInterco)
				Begin
					--For Customer Balance updation we are getting EntityID 
					Set @EntityId=(Select EntityId From Bean.Invoice (NOLOCK) Where Id=@SourceId)
					Set @ServiceEntityId=(Select ServiceEntityId from Bean.Entity (NOLOCK) where id=@EntityId and CompanyId=@CompanyId)
					Set @DocumentId =@SourceId
					Set @ServiceEntityShortName= (select ShortName from Common.Company (NOLOCK) where Id=@ServiceEntityId)
				End
				Else
				Begin
					IF (@DocumentId Is NUll Or @DocumentId='00000000-0000-0000-0000-000000000000')
					Begin
						Set @DocumentId=@SourceId
						--For Customer Balance updation we are getting EntityID 
						Set @EntityId = (Select EntityId From Bean.Invoice (NOLOCK) Where Id=@SourceId)
					End
					Else
					Begin
						Set @EntityId = (Select EntityId From Bean.Invoice (NOLOCK) Where DocumentId=@SourceId)
					End
				End

				If Exists(select Id from Bean.Journal (NOLOCK) where CompanyId=@CompanyId and DocumentId=@DocumentId)
				Begin
					Select @OldEntityId = EntityId,@IsAddNote=IsAddNote from Bean.Journal (NOLOCK) where CompanyId=@CompanyId and DocumentId=@DocumentId
					
					Delete from Bean.JournalDetail with (ROWLOCK) where DocumentId=@DocumentId and DocType=@Type
					Delete from Bean.Journal with (ROWLOCK) where DocumentId=@DocumentId and CompanyId=@CompanyId and DocType=@Type
				End
				Else
				Begin
					--For Customer Balance updation we are getting EntityID 
					Set @OldEntityId = @EntityId 
				End
				
				-- Inserting Records Into Journal From Invoce 
				Set @JournalId = NEWID()
				Insert Into Bean.Journal (Id,CompanyId,DocDate,DocType,DocSubType,DocNo,ServiceCompanyId,SystemReferenceNo,IsNoSupportingDocs,NoSupportingDocument,DocCurrency,ExchangeRate,ExCurrency,GSTExchangeRate,GSTExCurrency,GSTTotalAmount,DocumentState,IsNoSupportingDocument,IsGstSettings,IsMultiCurrency,IsAllowableNonAllowable,Remarks,UserCreated,CreatedDate,ModifiedBy,ModifiedDate,Status,DocumentDescription,CreationType,GrandDocDebitTotal,GrandBaseDebitTotal,DueDate,EntityId,EntityType,PoNo,PostingDate,IsGSTApplied,COAId,DocumentId,CreditTermsId,Nature,BalanceAmount,ActualSysRefNo,RefNo,IsSegmentReporting,IsAddNote)
				Select @JournalId,CompanyId,DocDate,@Type,DocSubType,DocNo,ServiceCompanyId,DocNo As SystemRefNo,IsNoSupportingDocument,NoSupportingDocs,DocCurrency,ExchangeRate,ExCurrency, GSTExchangeRate,GSTExCurrency,Isnull(GSTTotalAmount,0),DocumentState,/**/[IsNoSupportingDocument],IsGstSettings,IsMultiCurrency,IsAllowableNonAllowable,Remarks,UserCreated,CreatedDate,ModifiedBy,ModifiedDate,Status,DocDescription,@CreationTypeSystem,Round(GrandTotal,2) As GrandDocDebitTotal,Round((GrandTotal*Isnull(ExchangeRate,1)),2) As GrandBaseDebitTotal,
						DueDate,EntityId,EntityType,PONo,DocDate As PostingDate,IsGSTApplied,
						Case when Nature=@NatureTrade Then (Select Id From Bean.ChartOfAccount (NOLOCK) Where CompanyId=@CompanyId And Name=@COATradeReceivables)
							 when Nature=@NatureOthers Then (Select Id From Bean.ChartOfAccount (NOLOCK) Where CompanyId=@CompanyId And Name=@COAotherReceivables)
							When Nature=@NatureInterco Then (Select Id From Bean.ChartOfAccount (NOLOCK) Where CompanyId=@CompanyId and SubsidaryCompanyId=@ServiceEntityId and Name=Concat('I/B - ',@ServiceEntityShortName)) End As COAId,
							Id As Documentid,CreditTermsId,Nature,BalanceAmount,DocNo As ActualSysRefNo,Null,ISNULL(IsSegmentReporting,0),@IsAddNote as IsAddNote
				 From Bean.Invoice (NOLOCK) Where Id=@DocumentId
				-- Inserting Records Into JournalDetail From InvoceDetail
				Insert Into @Temp
				Select Id From Bean.InvoiceDetail (NOLOCK) Where InvoiceId=@DocumentId Order By RecOrder

				Select @RecCount=Count(*) From @Temp
				Set @Count=1
				Set @TaxRecCount = @RecCount+1

				While @RecCount>=@Count
				Begin
					Set @DetailId=(Select DetailId From @Temp Where S_No=@Count)
					--Set @RecOrder=1
					Insert Into Bean.JournalDetail (Id,JournalId,COAId,AccountDescription,TaxId,TaxRate,DocDebit,DocCredit,DocTaxCredit,BaseDebit,BaseCredit,DocDebitTotal,DocCreditTotal,BaseDebitTotal,BaseCreditTotal, DocumentId, DocumentDetailId, ItemId,ItemCode,ItemDescription,BaseCurrency,ExchangeRate,GSTExCurrency,GSTExchangeRate,DocType,DocSubType,ServiceCompanyId,DocNo,Nature,OffsetDocument,IsTax,EntityId,SystemRefNo,Remarks,PONo,CreditTermsId,DocCurrency,DocDate,DocDescription,PostingDate,RecOrder,DocTaxAmount,BaseTaxAmount,BaseTaxCredit,GSTCredit,GSTTaxCredit)
					Select NEWID(),@JournalId,
							InvID.COAId As COAId,
							InvID.ItemDescription As AccountDescription,InvID.TaxId,InvID.TaxRate,null As DocDebit,InvID.DocAmount As DocCredit,InvID.DocTaxAmount,null As BaseDebit,InvID.BaseAmount as BaseCredit,'0.00',InvID.DocTotalAmount,null,null,@DocumentId, InvID.Id,InvID.ItemId,InvID.ItemCode,InvID.ItemDescription,Inv.ExCurrency,Inv.ExchangeRate,Inv.GSTExCurrency,Inv.GSTExchangeRate,@Type,Inv.DocSubType,Inv.ServiceCompanyId,Inv.DocNo,Inv.Nature,Null As OffsetDocument,0 As IsTax,Inv.EntityId,Inv.DocNo As SystemRefNo,Inv.Remarks,Inv.PONo,0 As CreditTermsId,Inv.DocCurrency,Inv.DocDate,
							null As DocDescription,Inv.DocDate As PostingDate,InvID.RecOrder As RecOrder,InvID.DocTaxAmount,InvID.BaseTaxAmount,InvID.BaseTaxAmount,
							ROUND(ISNULL(InvID.DocTaxAmount,0)*Isnull(Inv.GSTExchangeRate,1),2) as GSTCredit,
							ROUND(ISNULL(InvID.DocAmount,0)*Isnull(Inv.GSTExchangeRate,1),2) as GSTTaxCredit
					From Bean.InvoiceDetail As InvID  (NOLOCK)
					Inner Join Bean.Invoice As Inv (NOLOCK) On Inv.Id=InvID.InvoiceId
					Where InvID.Id=@DetailId
					-- Inserting Tax Lineitem into journaldetail
					If Exists (Select B.Id From Bean.Invoice As A (NOLOCK) Inner Join Bean.InvoiceDetail As B (NOLOCK) On A.Id=B.InvoiceId Where A.IsGstSettings=1 And B.TaxRate is not null 
						And Convert(nvarchar(20),B.TaxIdCode)<>@NA And B.Id=@DetailId)
					Begin
						--Set @TaxRecCount=@RecCount+@TaxRecOrder
						Insert Into Bean.JournalDetail (Id,JournalId,COAId,AccountDescription,AllowDisAllow,TaxId,TaxRate,DocDebit,DocCredit,DocTaxDebit,DocTaxCredit,BaseDebit,BaseCredit,DocDebitTotal,DocCreditTotal,BaseDebitTotal,BaseCreditTotal,DocumentId,DocumentDetailId,ItemId,BaseCurrency,ExchangeRate,GSTExCurrency,GSTExchangeRate,DocType,DocSubType,ServiceCompanyId,DocNo,Nature,OffsetDocument,IsTax,EntityId,SystemRefNo,Remarks,PONo,CreditTermsId,NoSupportingDocs,BaseAmount,DocCurrency,DocDate,DocDescription,PostingDate,RecOrder,DocTaxAmount,BaseTaxAmount)
						Select NEWID(),@JournalId,(Select Id From Bean.ChartOfAccount Where CompanyId=@CompanyId And Name=@COATaxPaybleGST) As COAId,Inv.DocDescription As AccountDescription,InvID.AllowDisAllow,InvID.TaxId,InvID.TaxRate,null As DocDebit,InvID.DocTaxAmount As DocCredit,'0.00' As DocTaxDebit,'0.00' As DocTaxCredit,null As BaseDebit,Round(InvID.DocTaxAmount*Isnull(inv.ExchangeRate,1),2) As BaseCredit,'0.00' As DocDebitTotal,'0.00' As DocCreditTotal,null As BaseDebitTotal,null As BaseCreditTotal,@DocumentId,InvID.Id,@GUIDZero,Inv.ExCurrency,Inv.ExchangeRate,Inv.GSTExCurrency,Inv.GSTExchangeRate,@Type,Inv.DocSubType,Inv.ServiceCompanyId,Inv.DocNo,Inv.Nature,Null As OffsetDocument,1 As IsTax,Inv.EntityId,Inv.DocNo As SystemRefNo,Inv.Remarks,Inv.PONo,Null As CreditTermsId,
								Inv.NoSupportingDocs,null As BaseAmount,Inv.DocCurrency,Inv.DocDate,null As DocDescription,
										Inv.DocDate,@TaxRecCount As RecOrder,InvID.DocTaxAmount,InvID.BaseTaxAmount
								From Bean.InvoiceDetail As InvID (NOLOCK)
								Inner Join Bean.Invoice As Inv (NOLOCK) On Inv.Id=InvID.InvoiceId
						Where InvID.Id=@DetailId
						--Set @TaxRecOrder=@TaxRecOrder+1
						Set @TaxRecCount = @TaxRecCount+1
					End
					Set @Count=@Count+1
				End

				Select @ExchangeRate=ExchangeRate from Bean.Invoice (NOLOCK) where CompanyId=@CompanyId and Id=@DocumentId
				Select @MasterBaseAmount=Cast(Sum(ROUND(ABS(DocAmount)*ISNULL(@ExchangeRate,1),2)+(Round(ABS(Isnull(DocTaxAmount,0))*ISNULL(@ExchangeRate,1),2)))as money) from Bean.InvoiceDetail (NOLOCK) where InvoiceId=@DocumentId

				-- Inserting Master Records Into JournalDetail From Invoce 
				Insert Into Bean.JournalDetail (Id,JournalId,COAId,AccountDescription,DocDebit,BaseDebit,DocDebitTotal,BaseDebitTotal,DocumentId,DocumentDetailId,ItemId,DueDate,ExchangeRate,GSTExchangeRate,GSTExCurrency,Nature,DocType,DocSubType,ServiceCompanyId,CreditTermsId,DocNo,PostingDate,RecOrder,DocumentAmount,Currency,BaseCurrency,IsTax,EntityId,SystemRefNo,Remarks,PONo,BaseAmount,DocCurrency,DocDate,DocDescription,DocCreditTotal)
				Select NewId(),@JournalId,Case when Nature=@NatureTrade Then (Select Id From Bean.ChartOfAccount (NOLOCK) Where CompanyId=@CompanyId And Name=@COATradeReceivables)
												when Nature=@NatureOthers Then (Select Id From Bean.ChartOfAccount (NOLOCK) Where CompanyId=@CompanyId And Name=@COAotherReceivables) 
												 When Nature=@NatureInterco Then (Select Id From Bean.ChartOfAccount (NOLOCK) Where CompanyId=@CompanyId and SubsidaryCompanyId=@ServiceEntityId and Name=Concat('I/B - ',@ServiceEntityShortName)) End As COAId,
						DocDescription,Round(GrandTotal,2),/*Round((GrandTotal*Isnull(ExchangeRate,1)),2)*/@MasterBaseAmount,Round(GrandTotal,2),/*Round((GrandTotal*Isnull(ExchangeRate,1)),2)*/@MasterBaseAmount As BaseDebitTotal,@DocumentId,@GUIDZero,@GUIDZero,DueDate,ExchangeRate,GSTExchangeRate,GSTExCurrency,Nature,@Type,DocSubType,ServiceCompanyId,CreditTermsId, DocNo, DocDate,(Select Max(Recorder)+1 From Bean.JournalDetail (NOLOCK) Where DocumentId=@DocumentId),Round(GrandTotal,2),
						DocCurrency,ExCurrency,0,EntityId,DocNo,Remarks,PONo,/*Round(GrandTotal*Isnull(ExchangeRate,1),2)*/@MasterBaseAmount,DocCurrency,DocDate,DocDescription,'0.00'
				From Bean.Invoice (NOLOCK) Where Id=@DocumentId

				
				


				If((select ABS(SUM(BaseDebit)-SUM(BaseCredit)) from Bean.JournalDetail (NOLOCK) where DocumentId=@DocumentId group by DocType)>=0.01)
				Begin
					Select @BaseDebit=SUM(BaseDebit),@BaseCredit=SUM(BaseCredit),@DiffAmount=ABS(SUM(BaseDebit)-SUM(BaseCredit)) from Bean.JournalDetail (NOLOCK) where DocumentId=@DocumentId
					
					Insert Into Bean.JournalDetail (Id,JournalId,COAId,AccountDescription,BaseDebit,BaseCredit,DocumentId,DocumentDetailId,ItemId,DocDate,DueDate,PostingDate,ExchangeRate,GSTExchangeRate,GSTExCurrency,Nature,DocType,DocSubType,ServiceCompanyId, CreditTermsId, DocNo, Currency, BaseCurrency, IsTax, EntityId, SystemRefNo,  DocCurrency, RecOrder,DocDebitTotal,DocCreditTotal)
					select NEWID(), @JournalId, (Select Id from Bean.ChartOfAccount (NOLOCK) where CompanyId=@CompanyId and Name=@Rounding), DocDescription, Case When @BaseDebit>@BaseCredit Then null Else @DiffAmount End as BaseDebit, Case When @BaseCredit>@BaseDebit Then null Else @DiffAmount END as BaseCredit, @DocumentId,NEWID(),@GUIDZero,DocDate,DueDate,DocDate,ExchangeRate,GSTExchangeRate,GSTExCurrency,Nature,DocType,DocSubType,ServiceCompanyId,CreditTermsId,DocNo, DocCurrency, ExCurrency, 0, EntityId,DocNo, DocCurrency, (Select Max(Recorder)+1 From Bean.JournalDetail (NOLOCK) Where DocumentId=@DocumentId),0,0
					from Bean.Invoice (NOLOCK) where CompanyId=@CompanyId and Id=@DocumentId
				End

				--0.01 BaseGrandTotal and BaseBalanceAmount updation for Invoice 
				IF (@MasterBaseAmount IS NOT NULL)
				Begin
					Update Bean.Invoice set BaseGrandTotal=@MasterBaseAmount,BaseBalanceAmount=@MasterBaseAmount where Id=@DocumentId and CompanyId=@CompanyId
				END

				-- Inserting Records into DocumentHistory Table
				Insert Into @BCDocumentHistoryType(TransactionId,CompanyId,DocumentId,DocType,DocSubType,DocState,DocCurrency,DocAmount,DocBalanaceAmount,ExchangeRate,BaseAmount,BaseBalanaceAmount,StateChangedBy,PostingDate,DocAppliedAmount,BaseAppliedAmount)
				Select @DocumentId,CompanyId,@DocumentId,DocType,DocSubType,DocumentState,DocCurrency,Round(GrandTotal,2) As DocAmount,Round(BalanceAmount,2) As DocBalanceAmount,ExchangeRate,/*Round(GrandTotal*ExchangeRate,2)*/Case When DocumentState='Not Paid' Then  @MasterBaseAmount Else 0 End As BaseAmount,Round(BalanceAmount*ExchangeRate,2) As BaseBalanceAmount,Case When ModifiedBy IS null Then UserCreated Else ModifiedBy End,/*DocDate*/Case When DocumentState='Not Paid' Then  DocDate Else null End,/*Round(GrandTotal,2)*/Case When DocumentState='Not Paid' Then  Round(GrandTotal,2) Else 0 End As DocAppliedAmount,Case When DocumentState='Not Paid' Then  @MasterBaseAmount Else 0 End As BaseAppliedAmount From Bean.Invoice (NOLOCK) Where Id=@DocumentId
				
				Exec [dbo].[Bean_DocumentHistory] @BCDocumentHistoryType   -------->> Another SP

				SET @CustEntId=@EntityId

				If(@OldEntityId <> @EntityId)
				Begin
					select @CustEntId=Cast(CONCAT(@OldEntityId,+','+Cast(@EntityId as nvarchar(200))) as nvarchar(200))
				End

				Exec [dbo].[Bean_Update_CustBalance_and_CreditLimit] @CompanyId, @CustEntId   -------->> Another SP
			End

			ELSE IF(@Type=@DebitNoteDocument)
			Begin
				--Set @DocumentId =(Select Id From Bean.DebitNote Where Id=@SourceId)
				Set @DocumentId=@SourceId
				Declare @IsInterCo bit=0;

				---For Interco posting -- Get Service CompanyId by entityid
				select @Nature= Nature,@EntityId=EntityId,@ExchangeRate=ISNULL(ExchangeRate,1) from Bean.DebitNote(nolock) where Id=@SourceId
				If(@Nature=@NatureInterco)
				Begin
					Set @IsInterCo=1;
					Set @ServiceEntityId=(Select ServiceEntityId from Bean.Entity(nolock) where id=@EntityId and CompanyId=@CompanyId)
					Set @ServiceEntityShortName= (select ShortName from Common.Company(nolock) where Id=@ServiceEntityId)
				End

				If Exists(select Id from Bean.Journal(nolock) where CompanyId=@CompanyId and DocumentId=@DocumentId)
				Begin
					Select @OldEntityId = EntityId,@IsAddNote=IsAddNote from Bean.Journal(nolock) where CompanyId=@CompanyId and DocumentId=@DocumentId
					--For Customer Balance updation we are getting EntityID 
					Delete from Bean.JournalDetail with (ROWLOCK) where DocumentId=@SourceId and DocType=@Type
					Delete from Bean.Journal with (ROWLOCK) where DocumentId=@SourceId and CompanyId=@CompanyId and DocType=@Type
				End
				Else
				Begin
					--For Customer Balance updation we are getting EntityID 
					Set @OldEntityId = @EntityId 
				End
			 
				-- Inserting Records Into Journal From DebitNote 
				Set @JournalId = NEWID()
				Insert Into Bean.Journal (Id,CompanyId,DocDate,DocType,DocSubType,DocNo,ServiceCompanyId,SystemReferenceNo,IsNoSupportingDocs,NoSupportingDocument,DocCurrency,ExchangeRate,ExCurrency,GSTExchangeRate,GSTExCurrency,GSTTotalAmount,DocumentState,IsNoSupportingDocument,IsGstSettings,IsMultiCurrency,IsAllowableNonAllowable,Remarks,UserCreated,CreatedDate,ModifiedBy,ModifiedDate,Status,DocumentDescription,CreationType,GrandDocDebitTotal,GrandBaseDebitTotal,DueDate,EntityId,EntityType,PoNo,PostingDate,IsGSTApplied,COAId,DocumentId,CreditTermsId,Nature,BalanceAmount,ActualSysRefNo,RefNo,IsSegmentReporting,IsAddNote)
				Select @JournalId,CompanyId,DocDate,@Type, Case when @IsInterCo=1 Then @NatureInterco Else  @DocSubTypeGeneral End,DocNo,ServiceCompanyId,DocNo As SystemRefNo,IsNoSupportingDocument,NoSupportingDocs,DocCurrency,ExchangeRate,ExCurrency, GSTExchangeRate,GSTExCurrency,Isnull(GSTTotalAmount,0),DocumentState,/**/[IsNoSupportingDocument],IsGstSettings,IsMultiCurrency,IsAllowableNonAllowable,Remarks,UserCreated,CreatedDate,ModifiedBy,ModifiedDate,Status,Remarks,@CreationTypeSystem,Round(GrandTotal,2) As GrandDocDebitTotal,Round((GrandTotal*Isnull(ExchangeRate,1)),2) As GrandBaseDebitTotal,
						DueDate,EntityId,EntityType,PONo,DocDate As PostingDate,IsGSTApplied,
						Case when Nature=@NatureTrade Then (Select Id From Bean.ChartOfAccount(nolock) Where CompanyId=@CompanyId And Name=@COATradeReceivables)
							 when Nature=@NatureOthers Then (Select Id From Bean.ChartOfAccount(nolock) Where CompanyId=@CompanyId And Name=@COAotherReceivables)
							When Nature=@NatureInterco Then (Select Id From Bean.ChartOfAccount(nolock) Where CompanyId=@CompanyId and SubsidaryCompanyId=@ServiceEntityId and Name=Concat('I/B - ',@ServiceEntityShortName)) End As COAId,
							Id As Documentid,CreditTermsId,Nature,BalanceAmount,DocNo As ActualSysRefNo,Null,ISNULL(IsSegmentReporting,0),@IsAddNote as IsAddNote
				 From Bean.DebitNote(nolock) Where Id=@DocumentId
				-- Inserting Records Into JournalDetail From DebitNoteDetail
				Insert Into @Temp
				Select Id From Bean.DebitNoteDetail(nolock) Where DebitNoteId=@DocumentId Order By RecOrder

				Select @RecCount=Count(*) From @Temp
				Set @Count=1
				Set @TaxRecCount = @RecCount+1

				While @RecCount>=@Count
				Begin
					Set @DetailId=(Select DetailId From @Temp Where S_No=@Count)
					--Set @RecOrder=1
					Insert Into Bean.JournalDetail (Id,JournalId,COAId,AccountDescription,TaxId,TaxRate,DocDebit,DocCredit,DocTaxCredit,BaseDebit,BaseCredit,DocDebitTotal,DocCreditTotal,BaseDebitTotal,BaseCreditTotal,DocumentId,DocumentDetailId,ItemId,ItemCode,ItemDescription,BaseCurrency,ExchangeRate,GSTExCurrency,GSTExchangeRate,DocType,DocSubType,ServiceCompanyId,DocNo,Nature,OffsetDocument,IsTax,EntityId,SystemRefNo,Remarks,PONo,CreditTermsId,DocCurrency,DocDate,DocDescription,PostingDate,RecOrder,DocTaxAmount,BaseTaxAmount,BaseTaxCredit,GSTCredit,GSTTaxCredit)
					Select NEWID(),@JournalId,InvID.COAId As COAId,
							AccountDescription As AccountDescription,InvID.TaxId,InvID.TaxRate,null As DocDebit,InvID.DocAmount As DocCredit,InvID.DocTaxAmount,null As BaseDebit,InvID.BaseAmount as BaseCredit, '0.00', InvID.DocTotalAmount, null,null, @DocumentId,InvID.Id,NULL,NULL,NULL, Inv.ExCurrency,Inv.ExchangeRate,Inv.GSTExCurrency,Inv.GSTExchangeRate,@Type,Case when @IsInterCo=1 Then @NatureInterco Else  @DocSubTypeGeneral End,Inv.ServiceCompanyId,Inv.DocNo,Inv.Nature,Null As OffsetDocument,0 As IsTax,Inv.EntityId,Inv.DocNo As SystemRefNo,Inv.Remarks,Inv.PONo,0 As CreditTermsId,Inv.DocCurrency,Inv.DocDate,
							Remarks As DocDescription,Inv.DocDate As PostingDate,InvID.RecOrder As RecOrder,InvID.DocTaxAmount,InvID.BaseTaxAmount,InvID.BaseTaxAmount,
							ROUND((ISNULL(InvID.DocTaxAmount,0)*Isnull(Inv.GSTExchangeRate,1)),2) as GSTCredit,
							ROUND((ISNULL(InvID.DocAmount,0)*Isnull(Inv.GSTExchangeRate,1)),2) as GSTTaxCredit
					From Bean.DebitNoteDetail As InvID (nolock) 
					Inner Join Bean.DebitNote As Inv(nolock) On Inv.Id=InvID.DebitNoteId
					Where InvID.Id=@DetailId
					-- Inserting Tax Lineitem into journaldetail
					If Exists (Select B.Id From Bean.DebitNote As A(nolock) Inner Join Bean.DebitNoteDetail As B (nolock) On A.Id=B.DebitNoteId Where A.IsGstSettings=1 And B.TaxRate is not null 
					And Convert(nvarchar(20),B.TaxIdCode)<>@NA And B.Id=@DetailId)
					Begin
						--Set @TaxRecCount=@RecCount+@TaxRecOrder
						Insert Into Bean.JournalDetail (Id,JournalId,COAId,AccountDescription,AllowDisAllow,TaxId,TaxRate,DocDebit,DocCredit,DocTaxDebit,DocTaxCredit,BaseDebit,BaseCredit,DocDebitTotal,DocCreditTotal,BaseDebitTotal,BaseCreditTotal,DocumentId,DocumentDetailId,ItemId,BaseCurrency,ExchangeRate,GSTExCurrency,GSTExchangeRate,DocType,DocSubType,ServiceCompanyId,DocNo,Nature,OffsetDocument,IsTax,EntityId,SystemRefNo,Remarks,PONo,CreditTermsId,NoSupportingDocs,BaseAmount,DocCurrency,DocDate,DocDescription,PostingDate,RecOrder,DocTaxAmount,BaseTaxAmount)

						Select NEWID(),@JournalId,(Select Id From Bean.ChartOfAccount(nolock) Where CompanyId=@CompanyId And Name=@COATaxPaybleGST) As COAId,Remarks As AccountDescription,DND.AllowDisAllow,DND.TaxId,DND.TaxRate,null As DocDebit,DND.DocTaxAmount As DocCredit,'0.00' As DocTaxDebit,'0.00' As DocTaxCredit,null As BaseDebit,Round(DND.DocTaxAmount*Isnull(D.ExchangeRate,1),2) As BaseCredit,'0.00' As DocDebitTotal,'0.00' As DocCreditTotal,null As BaseDebitTotal,null As BaseCreditTotal,@DocumentId,DND.Id,@GUIDZero,D.ExCurrency,D.ExchangeRate,D.GSTExCurrency,D.GSTExchangeRate,@Type,Case when @IsInterCo=1 Then @NatureInterco Else  @DocSubTypeGeneral End,D.ServiceCompanyId,D.DocNo,D.Nature,Null As OffsetDocument,1 As IsTax,D.EntityId,D.DocNo As SystemRefNo,D.Remarks,D.PONo,Null As CreditTermsId,
								D.NoSupportingDocs,null As BaseAmount,D.DocCurrency,D.DocDate,null As DocDescription,
										D.DocDate,@TaxRecCount As RecOrder,DND.DocTaxAmount,DND.BaseTaxAmount
								From Bean.DebitNoteDetail As DND (nolock)
								Inner Join Bean.DebitNote As D(nolock) On D.Id=DND.DebitNoteId
						Where DND.Id=@DetailId
						--Set @TaxRecOrder=@TaxRecOrder+1
						Set @TaxRecCount = @TaxRecCount+1
					End
					Set @Count=@Count+1
				End

				
				Select @MasterBaseAmount=Cast(Sum(ROUND(ABS(DocAmount)*ISNULL(@ExchangeRate,1),2)+(Round(ABS(Isnull(DocTaxAmount,0))*ISNULL(@ExchangeRate,1),2)))as money) from Bean.DebitNoteDetail(nolock) where DebitNoteId=@DocumentId


				-- Inserting Master Records Into JournalDetail From Invoce 
				Insert Into Bean.JournalDetail (Id,JournalId,COAId,AccountDescription,DocDebit,BaseDebit,DocDebitTotal,BaseDebitTotal,DocumentId,DocumentDetailId,ItemId,DueDate,ExchangeRate,GSTExchangeRate,GSTExCurrency,Nature,DocType,DocSubType,ServiceCompanyId,CreditTermsId,DocNo,PostingDate,RecOrder,DocumentAmount,Currency,BaseCurrency,IsTax,EntityId,SystemRefNo,Remarks,PONo,BaseAmount,DocCurrency,DocDate,DocDescription,DocCreditTotal)
				Select NewId(),@JournalId,Case when Nature=@NatureTrade Then (Select Id From Bean.ChartOfAccount(nolock)  Where CompanyId=@CompanyId And Name=@COATradeReceivables)
												when Nature=@NatureOthers Then (Select Id From Bean.ChartOfAccount(nolock)  Where CompanyId=@CompanyId And Name=@COAotherReceivables) 
												 When Nature=@NatureInterco Then (Select Id From Bean.ChartOfAccount(nolock)  Where CompanyId=@CompanyId and SubsidaryCompanyId=@ServiceEntityId and Name=Concat('I/B - ',@ServiceEntityShortName)) End As COAId,
						Remarks,Round(GrandTotal,2),/*Round((GrandTotal*Isnull(ExchangeRate,1)),2)*/@MasterBaseAmount,Round(GrandTotal,2),/*Round((GrandTotal*Isnull(ExchangeRate,1)),2)*/@MasterBaseAmount As BaseDebitTotal,@DocumentId,@GUIDZero,@GUIDZero,DueDate,ExchangeRate,GSTExchangeRate,GSTExCurrency,Nature,@Type,Case when @IsInterCo=1 Then @NatureInterco Else  @DocSubTypeGeneral End,ServiceCompanyId,CreditTermsId, DocNo, DocDate,(@Count+1),Round(GrandTotal,2),
						DocCurrency,ExCurrency,0,EntityId,DocNo,Remarks,PONo,/*Round((GrandTotal*Isnull(ExchangeRate,1)),2)*/@MasterBaseAmount,DocCurrency,DocDate,Remarks,'0.00'
				From Bean.DebitNote(nolock) Where Id=@DocumentId


				--0.01 BaseGrandTotal and BaseBalanceAmount updation for Debit Note 
				IF @MasterBaseAmount!=0 AND @MasterBaseAmount IS NOT NULL
				Begin
					Update Bean.DebitNote set BaseGrandTotal=@MasterBaseAmount,BaseBalanceAmount=@MasterBaseAmount where Id=@DocumentId and CompanyId=@CompanyId
				END

				--Rounding Account Data Insertion
				If((select ABS(SUM(BaseDebit)-SUM(BaseCredit)) from Bean.JournalDetail(nolock) where DocumentId=@DocumentId group by DocType)>=0.01)
				Begin
					Select @BaseDebit=SUM(BaseDebit),@BaseCredit=SUM(BaseCredit),@DiffAmount=ABS(SUM(BaseDebit)-SUM(BaseCredit)) from Bean.JournalDetail(nolock) where DocumentId=@DocumentId
					
					Insert Into Bean.JournalDetail (Id,JournalId,COAId,AccountDescription,BaseDebit,BaseCredit,DocumentId,DocumentDetailId,ItemId,DocDate,DueDate,PostingDate,ExchangeRate,GSTExchangeRate,GSTExCurrency,Nature,DocType,DocSubType,ServiceCompanyId, CreditTermsId, DocNo, Currency, BaseCurrency, IsTax, EntityId, SystemRefNo,  DocCurrency, RecOrder,DocDebitTotal,DocCreditTotal)
					select NEWID(), @JournalId, (Select Id from Bean.ChartOfAccount(nolock)  where CompanyId=@CompanyId and Name=@Rounding), Remarks, Case When @BaseDebit>@BaseCredit Then null Else @DiffAmount End as BaseDebit, Case When @BaseCredit>@BaseDebit Then null Else @DiffAmount END as BaseCredit, @DocumentId,NEWID(),@GUIDZero,DocDate,DueDate,DocDate,ExchangeRate,GSTExchangeRate,GSTExCurrency,Nature,DocSubType,Case when @IsInterCo=1 Then @NatureInterco Else  @DocSubTypeGeneral End,ServiceCompanyId,CreditTermsId,DocNo, DocCurrency, ExCurrency, 0, EntityId,DocNo, DocCurrency, (@Count+2),0,0
					from Bean.DebitNote(nolock) where CompanyId=@CompanyId and Id=@DocumentId
				End


				-- Inserting Records into DocumentHistory Table
				Insert Into @BCDocumentHistoryType(TransactionId,CompanyId,DocumentId,DocType,DocSubType,DocState,DocCurrency,DocAmount,DocBalanaceAmount,ExchangeRate,BaseAmount,BaseBalanaceAmount,StateChangedBy,PostingDate,DocAppliedAmount,BaseAppliedAmount)
				Select @DocumentId,CompanyId,@DocumentId,DocSubType,Case when @IsInterCo=1 Then @NatureInterco Else  @DocSubTypeGeneral End,DocumentState,DocCurrency,Round(GrandTotal,2) As DocAmount,Round(BalanceAmount,2) As DocBalanceAmount,ExchangeRate,/*Round(GrandTotal*ExchangeRate,2)*/Case When DocumentState='Not Paid' Then  @MasterBaseAmount Else 0 End As BaseAmount,Round(BalanceAmount*ExchangeRate,2) As BaseBalanceAmount,Case When ModifiedBy IS null Then UserCreated Else ModifiedBy End,/*DocDate*/Case When DocumentState='Not Paid' Then  DocDate Else null End,/*Round(GrandTotal,2)*/Case When DocumentState='Not Paid' Then  Round(GrandTotal,2) Else 0 End As DocAppliedAmount,Case When DocumentState='Not Paid' Then  @MasterBaseAmount Else 0 End As BaseAppliedAmount From Bean.DebitNote(nolock) Where Id=@DocumentId
				
				Exec [dbo].[Bean_DocumentHistory] @BCDocumentHistoryType   ---->> Another SP


				If(@OldEntityId <> @EntityId)
				Begin
					select @CustEntId=Cast(CONCAT(@OldEntityId,+','+Cast(@EntityId as nvarchar(200))) as nvarchar(200))

					Exec [dbo].[Bean_Update_CustBalance_and_CreditLimit] @CompanyId, @CustEntId
					--Exec [dbo].[Bean_Update_CustBalance] @CompanyId, @OldEntityId
				End
				Else
				Begin
					Exec [dbo].[Bean_Update_CustBalance_and_CreditLimit] @CompanyId, @EntityId
				End
			End

			ELSE IF(@Type=@BillDocument)
			BEGIN
				SET @DocumentId=@SourceId
				---For Interco posting -- Get Service CompanyId by entityid
				--Set @Nature=(select Nature from Bean.Bill where Id=@SourceId)
				Select @Nature=Nature,@DocSubType=DocSubType,@EntityId=EntityId from Bean.Bill(nolock) where Id=@SourceId
				If(@Nature=@NatureInterco)
				Begin
					--For Customer Balance updation we are getting EntityID 
					Set @ServiceEntityId=(Select ServiceEntityId from Bean.Entity(nolock) where id=@EntityId and CompanyId=@CompanyId)
					--Set @DocumentId =@SourceId
					Set @ServiceEntityShortName= (select ShortName from Common.Company(nolock) where Id=@ServiceEntityId)
					--Delete from Bean.JournalDetail where DocumentId=@SourceId and DocType=@Type
					--Delete from Bean.Journal where DocumentId=@SourceId and CompanyId=@CompanyId and DocType=@Type
				End
				Else
				Begin
					--For Customer Balance updation we are getting EntityID 
					IF (@DocSubType=@DocSubTypeGeneral)
					Begin
						Set @EntityId = @EntityId
					End
					Else
					Begin
						--For Customer Balance updation we are getting EntityID 
						Set @EntityId=(Select EntityId From Bean.Bill(nolock) Where PayrollId=@SourceId)
					End 
				End
				 
				If Exists(select Id from Bean.Journal(nolock) where CompanyId=@CompanyId and DocumentId=@DocumentId)
				Begin
					Delete from Bean.JournalDetail with (ROWLOCK) where DocumentId=@SourceId and DocType=@Type
					Delete from Bean.Journal with (ROWLOCK) where DocumentId=@SourceId and CompanyId=@CompanyId and DocType=@Type
				End
				

				--------Journal Save call
				Set @JournalId = NEWID()
				Insert Into Bean.Journal (Id,CompanyId,DocDate,DocType,DocSubType,DocNo,ServiceCompanyId,SystemReferenceNo,IsNoSupportingDocs,NoSupportingDocument,DocCurrency,ExchangeRate,ExCurrency,GSTExchangeRate,GSTExCurrency,GSTTotalAmount,DocumentState,IsNoSupportingDocument,IsGstSettings,IsMultiCurrency,IsAllowableNonAllowable,Remarks,UserCreated,CreatedDate,ModifiedBy,ModifiedDate,Status,DocumentDescription,CreationType,GrandDocCreditTotal,GrandBaseCreditTotal,DueDate,EntityId,EntityType,PostingDate,IsGSTApplied,COAId,DocumentId,CreditTermsId,Nature,BalanceAmount,ActualSysRefNo,RefNo,IsSegmentReporting)
				Select @JournalId,CompanyId,DocumentDate,@Type,DocSubType,DocNo,ServiceCompanyId,DocNo As SystemRefNo,IsNoSupportingDocument,NoSupportingDocument,DocCurrency,ExchangeRate,BaseCurrency, GSTExchangeRate,GSTExCurrency,Isnull(GSTTotalAmount,0),DocumentState,/**/[IsNoSupportingDocument],IsGstSettings,IsMultiCurrency,IsAllowableDisallowable,Remarks,UserCreated,CreatedDate,ModifiedBy,ModifiedDate,Status,DocDescription,@CreationTypeSystem,Round(GrandTotal,2) As GrandDocCreditTotal,Round((GrandTotal*Isnull(ExchangeRate,1)),2) As GrandBaseCreditTotal,
											DueDate,EntityId,EntityType,PostingDate As PostingDate,IsGSTApplied,
											Case when Nature=@NatureTrade Then (Select Id From Bean.ChartOfAccount(nolock)  Where CompanyId=@CompanyId And Name=@COATradePayables)
												 when Nature=@NatureOthers Then (Select Id From Bean.ChartOfAccount(nolock)  Where CompanyId=@CompanyId And Name=@COAOtherPayables)
												When Nature=@NatureInterco Then (Select Id From Bean.ChartOfAccount(nolock)  Where CompanyId=@CompanyId and SubsidaryCompanyId=@ServiceEntityId and Name=Concat('I/B - ',@ServiceEntityShortName)) End As COAId,
												Id As Documentid,CreditTermsId,Nature,BalanceAmount,DocNo As ActualSysRefNo,Null,ISNULL(IsSegmentReporting,0)
				From Bean.Bill(nolock)  Where Id=@DocumentId

				-- Inserting Records Into JournalDetail From BillDetail
				Insert Into @Temp
				Select Id From Bean.BillDetail(nolock)  Where BillId=@DocumentId Order By RecOrder
				
				Select @RecCount=Count(*) From @Temp
				Set @Count=1
				Set @TaxRecCount = @RecCount+1
				While @RecCount>=@Count
				Begin
					Set @DetailId=(Select DetailId From @Temp Where S_No=@Count)
					
					Insert Into Bean.JournalDetail (Id,JournalId,COAId,AccountDescription,TaxId,TaxRate,DocCredit,DocDebit,BaseCredit,BaseDebit,DocDebitTotal,DocCreditTotal,BaseDebitTotal,BaseCreditTotal,DocumentId,DocumentDetailId,BaseCurrency,ExchangeRate,GSTExCurrency,GSTExchangeRate,DocType,DocSubType,ServiceCompanyId,DocNo,Nature,OffsetDocument,IsTax,EntityId,SystemRefNo,Remarks,CreditTermsId,DocCurrency,DocDate,DocDescription,PostingDate,RecOrder,DocTaxAmount,BaseTaxAmount,DocTaxDebit,BaseTaxDebit,DocTaxCredit,BaseTaxCredit,GSTCredit,GSTTaxCredit,GSTDebit,GSTTaxDebit)										
					Select NEWID(),@JournalId,BD.COAId As COAId,BD.Description As AccountDescription,BD.TaxId,BD.TaxRate,Case When B.DocType=@BillDocument AND BD.DocAmount<0 THEN ABS(BD.DocAmount) Else Null End As DocCredit,Case When B.DocType=@BillDocument AND BD.DocAmount>=0 THEN BD.DocAmount Else Null End As DocDebit,Case When B.DocType=@BillDocument AND BD.BaseAmount<0 THEN ABS(BD.BaseAmount) Else Null End As BaseCredit,Case When B.DocType=@BillDocument AND BD.BaseAmount>=0 THEN BD.BaseAmount Else Null End as BaseDebit,'0.00',BD.DocTotalAmount,null,null,@DocumentId,BD.Id,B.BaseCurrency,B.ExchangeRate,B.GSTExCurrency,B.GSTExchangeRate,@Type,B.DocSubType,B.ServiceCompanyId,B.DocNo,B.Nature,Null As OffsetDocument,0 As IsTax,B.EntityId,B.DocNo As SystemRefNo,B.Remarks,0 As CreditTermsId,B.DocCurrency,B.DocumentDate,
							null As DocDescription,B.PostingDate As PostingDate,BD.RecOrder As RecOrder,BD.DocTaxAmount, BD.BaseTaxAmount,
							Case When BD.DocTaxAmount>0 Then BD.DocTaxAmount Else 0 End,
							Case When BD.BaseAmount>0 Then BD.BaseTaxAmount Else 0 End,
							Case When BD.DocTaxAmount<0 Then ABS(BD.DocTaxAmount) Else 0 End,
							Case When BD.BaseAmount<0 Then ABS(BD.BaseTaxAmount) Else 0 End,
					Case When BD.DocTaxAmount<0 and B.DocType=@BillDocument Then ABS(ROUND((ISNULL(BD.DocTaxAmount,0)*Isnull(B.GSTExchangeRate,1)),2)) Else null END as GStCredit,
					Case When BD.DocAmount<0 and B.DocType=@BillDocument Then ABS(ROUND((ISNULL(BD.DocAmount,0)*Isnull(B.GSTExchangeRate,1)),2)) Else null END as GSTTaxCredit,
					Case When BD.DocTaxAmount>0 and B.DocType=@BillDocument Then ROUND((ISNULL(BD.DocTaxAmount,0)*Isnull(B.GSTExchangeRate,1)),2) Else null END as GSTDebit,
					Case When BD.DocAmount>0 and B.DocType=@BillDocument Then ROUND((ISNULL(BD.DocAmount,0)*Isnull(B.GSTExchangeRate,1)),2) Else null END as GSTTaxDebit
					From Bean.BillDetail As BD (nolock) 
					Inner Join Bean.Bill As B (nolock)  On B.Id=BD.BillId
					Where BD.Id=@DetailId
					-- Inserting Tax Lineitem into journaldetail
					If Exists (Select B.Id From Bean.Bill As A(nolock)  Inner Join Bean.BillDetail As B(nolock)  On A.Id=B.BillId Where A.IsGstSettings=1 And B.TaxRate is not null 
						And Convert(nvarchar(20),B.TaxIdCode)<>@NA And B.Id=@DetailId)
					Begin
						--Set @TaxRecCount=@RecCount+@TaxRecOrder
						
						Insert Into Bean.JournalDetail (Id,JournalId,COAId,AccountDescription,AllowDisAllow,TaxId,TaxRate,DocCredit,DocDebit,DocTaxCredit,DocTaxDebit,BaseCredit,BaseDebit,DocDebitTotal,DocCreditTotal,BaseDebitTotal,BaseCreditTotal,DocumentId,DocumentDetailId,ItemId,BaseCurrency,ExchangeRate,GSTExCurrency,GSTExchangeRate,DocType,DocSubType,ServiceCompanyId,DocNo,Nature,OffsetDocument,IsTax,EntityId,SystemRefNo,Remarks,CreditTermsId,NoSupportingDocs,BaseAmount,DocCurrency,DocDate,DocDescription,PostingDate,RecOrder,DocTaxAmount,BaseTaxAmount)

						Select NEWID(),@JournalId,(Select Id From Bean.ChartOfAccount(nolock)  Where CompanyId=@CompanyId And Name=@COATaxPaybleGST) As COAId,B.DocDescription As AccountDescription,B.IsAllowableDisallowable,BD.TaxId,BD.TaxRate,Case When BD.DocTaxAmount<0 Then ABS(BD.DocTaxAmount) Else Null End As DocCredit,Case When BD.DocTaxAmount>=0 Then BD.DocTaxAmount Else Null End As DocDebit,'0.00' As DocTaxCredit,'0.00' As DocTaxDebit,Case When BD.BaseTaxAmount<0 Then ABS(Round(BD.DocTaxAmount*Isnull(B.ExchangeRate,1),2)) Else Null End As BaseCredit,Case When BD.BaseTaxAmount>=0 Then  Round(BD.DocTaxAmount*Isnull(B.ExchangeRate,1),2) Else Null End As BaseDebit,'0.00' As DocDebitTotal,'0.00' As DocCreditTotal,null As BaseDebitTotal,null As BaseCreditTotal, @DocumentId,BD.Id,@GUIDZero,B.BaseCurrency, B.ExchangeRate,B.GSTExCurrency,B.GSTExchangeRate,@Type,B.DocSubType,B.ServiceCompanyId,B.DocNo,B.Nature,Null As OffsetDocument,1 As IsTax,B.EntityId,B.DocNo As SystemRefNo,B.Remarks,B.CreditTermsId As CreditTermsId,
								B.NoSupportingDocument,null As BaseAmount,B.DocCurrency,B.DocumentDate,null As DocDescription,
								B.PostingDate,@TaxRecCount As RecOrder,BD.DocTaxAmount,BD.BaseTaxAmount
						From Bean.BillDetail As BD(nolock) 
						Inner Join Bean.Bill As B(nolock)  On B.Id=BD.BillId
						Where BD.Id=@DetailId
						--Set @TaxRecOrder=@TaxRecOrder+1
						Set @TaxRecCount = @TaxRecCount+1
					End
						Set @Count=@Count+1
				End

				Select @ExchangeRate=ExchangeRate from Bean.Bill(nolock)  where CompanyId=@CompanyId and Id=@DocumentId
				Select @MasterBaseAmount=Cast(ABS(Sum(ROUND(DocAmount*ISNULL(@ExchangeRate,1),2)+(Round(Isnull(DocTaxAmount,0)*ISNULL(@ExchangeRate,1),2))))as money) from Bean.BillDetail(nolock)  where BillId=@DocumentId

				 --Inserting Master Records Into JournalDetail From Bill 
				Insert Into Bean.JournalDetail (Id,JournalId,COAId,AccountDescription,DocCredit,BaseCredit,DocCreditTotal,BaseCreditTotal,DocumentId,DocumentDetailId,ItemId,DueDate,ExchangeRate,GSTExchangeRate,GSTExCurrency,Nature,DocType,DocSubType,ServiceCompanyId,CreditTermsId,DocNo,PostingDate,RecOrder,DocumentAmount,Currency,BaseCurrency,IsTax,EntityId,SystemRefNo,Remarks,BaseAmount,DocCurrency,DocDate,DocDescription,DocDebitTotal)
												
				Select NewId(),@JournalId,
				Case when Nature=@NatureTrade Then (Select Id From Bean.ChartOfAccount(nolock) Where CompanyId=@CompanyId And Name=@COATradePayables)
				when Nature=@NatureOthers Then (Select Id From Bean.ChartOfAccount(nolock) Where CompanyId=@CompanyId And Name=@COAOtherPayables)
				When Nature=@NatureInterco Then (Select Id From Bean.ChartOfAccount(nolock) Where CompanyId=@CompanyId and SubsidaryCompanyId=@ServiceEntityId and Name=Concat('I/B - ',@ServiceEntityShortName)) End As COAId,
						DocDescription,Round(GrandTotal,2),@MasterBaseAmount,Round(GrandTotal,2),@MasterBaseAmount As BaseCreditTotal,@DocumentId,@GUIDZero,@GUIDZero,DueDate,ExchangeRate,GSTExchangeRate,GSTExCurrency,Nature,@Type,DocSubType,ServiceCompanyId,CreditTermsId, DocNo, PostingDate,(Select Max(Recorder)+1 From Bean.JournalDetail Where DocumentId=@DocumentId),Round(GrandTotal,2),DocCurrency,BaseCurrency,0,EntityId,DocNo,Remarks,@MasterBaseAmount,DocCurrency,DocumentDate,DocDescription,'0.00'
				From Bean.Bill(nolock) Where Id=@DocumentId


				--0.01 BaseGrandTotal and BaseBalanceAmount updation for Bill 
				IF @MasterBaseAmount!=0 AND @MasterBaseAmount IS NOT NULL
				Begin
					Update Bean.Bill set BaseGrandTotal=@MasterBaseAmount,BaseBalanceAmount=@MasterBaseAmount where Id=@DocumentId and CompanyId=@CompanyId
				END

				If((select ABS(SUM(BaseDebit)-SUM(BaseCredit)) from Bean.JournalDetail where DocumentId=@DocumentId group by DocType)>=0.01)
				Begin
					Select @BaseDebit=SUM(BaseDebit),@BaseCredit=SUM(BaseCredit),@DiffAmount=ABS(SUM(BaseDebit)-SUM(BaseCredit)) from Bean.JournalDetail(nolock) where DocumentId=@DocumentId
					Insert Into Bean.JournalDetail (Id,JournalId,COAId,AccountDescription,BaseDebit,BaseCredit,DocumentId,DocumentDetailId,ItemId,DocDate,DueDate,PostingDate,ExchangeRate,GSTExchangeRate,GSTExCurrency,Nature,DocType,DocSubType,ServiceCompanyId, CreditTermsId, DocNo, Currency, BaseCurrency, IsTax, EntityId, SystemRefNo,  DocCurrency, RecOrder,DocDebitTotal,DocCreditTotal)
					select NEWID(), @JournalId, (Select Id from Bean.ChartOfAccount where CompanyId=@CompanyId and Name=@Rounding), DocDescription,  Case When @BaseDebit>@BaseCredit Then null Else @DiffAmount End as BaseDebit, Case When @BaseCredit>@BaseDebit Then null Else @DiffAmount END as BaseCredit, @DocumentId,NEWID(),@GUIDZero,DocumentDate,DueDate,PostingDate,ExchangeRate,GSTExchangeRate,GSTExCurrency,Nature,DocType,DocSubType,ServiceCompanyId,CreditTermsId,DocNo, DocCurrency, BaseCurrency, 0, EntityId,DocNo, DocCurrency, (Select Max(Recorder)+1 From Bean.JournalDetail(nolock) Where DocumentId=@DocumentId),0,0
					from Bean.Bill where CompanyId=@CompanyId and Id=@DocumentId
				End

				-- Inserting Records into DocumentHistory Table
				Insert Into @BCDocumentHistoryType(TransactionId,CompanyId,DocumentId,DocType,DocSubType,DocState,DocCurrency,DocAmount,DocBalanaceAmount,ExchangeRate,BaseAmount,BaseBalanaceAmount,StateChangedBy,PostingDate,DocAppliedAmount,BaseAppliedAmount)
				Select @DocumentId,CompanyId,@DocumentId,@Type,docsubtype,DocumentState,DocCurrency,Round(GrandTotal,2) As DocAmount,Round(BalanceAmount,2) As DocBalanceAmount,ExchangeRate,/*Round(GrandTotal*ExchangeRate,2)*/Case When DocumentState='Not Paid' Then  @MasterBaseAmount Else 0 End As BaseAmount,Round(BalanceAmount*ExchangeRate,2) As BaseBalanceAmount,Case When ModifiedBy IS null Then UserCreated Else ModifiedBy End,/*DocDate*/Case When DocumentState='Not Paid' Then  PostingDate Else null End,/*Round(GrandTotal,2)*/Case When DocumentState='Not Paid' Then  Round(GrandTotal,2) Else 0 End As DocAppliedAmount,Case When DocumentState='Not Paid' Then  @MasterBaseAmount Else 0 End As BaseAppliedAmount From Bean.Bill(nolock) Where Id=@DocumentId
				
				Exec [dbo].[Bean_DocumentHistory] @BCDocumentHistoryType
			END
			

			Else If(@Type=@CashPaymentDocument OR @Type=@WithdrawalDocument Or @Type=@DepositDocument)
			Begin---If DocType is Cash Payment, WithDrawal and Deposit
				Set @DocumentId=@SourceId
				If Not Exists(Select Id from Bean.WithDrawal(Nolock) where CompanyId=@CompanyId and Id=@DocumentId and DocType=@Type)
				Begin
					RAISERROR (@InvalidDocumentError,16,1);
				END

				If Exists(select Id from Bean.Journal(Nolock) where CompanyId=@CompanyId and DocumentId=@DocumentId and DocType=@Type)
				Begin
					-----For BRC we need to check for the bank account
					select @OldCoaId=COAId,@OldServEntityId=ServiceCompanyId,@OldDocAmount=Case When DocDebit IS null Then DocCredit Else DocDebit End,@OldDocdate=PostingDate from Bean.JournalDetail(Nolock) where DocumentId=@DocumentId and DocumentDetailId='00000000-0000-0000-0000-000000000000'
					Select @NewCoaId=COAId,@NewServEntityId=ServiceCompanyId,@NewDocAmount=GrandTotal,@NewDocDate=DocDate from Bean.WithDrawal(Nolock) where CompanyId=@CompanyId and Id=@DocumentId and DocType=@Type
					Set @IsAdd=0;
					Delete from Bean.JournalDetail with (ROWLOCK) where DocumentId=@SourceId and DocType=@Type
					Delete from Bean.Journal with (ROWLOCK) where DocumentId=@SourceId and CompanyId=@CompanyId and DocType=@Type
				End
				Else
				Begin
					Set @IsAdd=1;
					Select @NewCoaId=COAId,@OldCoaId=COAId,@NewServEntityId=ServiceCompanyId,@OldServEntityId=ServiceCompanyId,@NewDocAmount=GrandTotal,@OldDocAmount=GrandTotal,@NewDocDate=DocDate,@OldDocdate=DocDate from Bean.WithDrawal(Nolock) where CompanyId=@CompanyId and Id=@DocumentId and DocType=@Type
				End
				If Exists(Select Id from Bean.ChartOfAccount(Nolock) where CompanyId=@CompanyId and Id in (@NewCoaId,@OldCoaId) and IsBank=1)
				Begin
					Set @IsBankAccountExists=1
				End
				--------Journal Save call
				Set @JournalId = NEWID()
				Insert Into Bean.Journal (Id,CompanyId,DocDate,DocType,DocSubType,DocNo,ServiceCompanyId,SystemReferenceNo,IsNoSupportingDocs,NoSupportingDocument,DocCurrency,ExchangeRate,ExCurrency,GSTExchangeRate,GSTExCurrency,GSTTotalAmount,DocumentState,IsNoSupportingDocument,IsGstSettings,IsMultiCurrency,IsAllowableNonAllowable,Remarks,UserCreated,CreatedDate,ModifiedBy,ModifiedDate,Status,DocumentDescription,CreationType,GrandDocCreditTotal,GrandBaseCreditTotal,EntityId,EntityType,PostingDate,IsGSTApplied,COAId,DocumentId,CreditTermsId,Nature,BalanceAmount,ActualSysRefNo,RefNo,IsSegmentReporting,TransferRefNo,ModeOfReceipt)
				Select @JournalId,CompanyId,DocDate,@Type,@DocSubTypeGeneral,DocNo,ServiceCompanyId,DocNo As SystemRefNo,IsNoSupportingDocumentActivated,NoSupportingDocs,DocCurrency,ExchangeRate,ExCurrency, GSTExchangeRate,GSTExCurrency,Isnull(GSTTotalAmount,0),DocumentState,/**/IsNoSupportingDocumentActivated,IsGstSettingsActivated,IsMultiCurrencyActivated,IsAllowableNonAllowableActivated,Remarks,UserCreated,CreatedDate,ModifiedBy,ModifiedDate,Status,DocDescription,@CreationTypeSystem,Round(GrandTotal,2) As GrandDocCreditTotal,Round((GrandTotal*Isnull(ExchangeRate,1)),2) As GrandBaseCreditTotal,EntityId,EntityType,DocDate As PostingDate,IsGstSettingsActivated,
						COAId As COAId,
						Id As Documentid,0,null,null,DocNo As ActualSysRefNo,Null,ISNULL(IsSegmentReportingActivated,0),WithDrawalRefNo,ModeOfWithDrawal
				From Bean.WithDrawal(Nolock) Where Id=@DocumentId

				-- Inserting Records Into JournalDetail From WithDrawalDetail
				Insert Into @Temp
				Select Id From Bean.WithDrawalDetail(Nolock) Where WithdrawalId=@DocumentId Order By RecOrder
				
				Select @RecCount=Count(*) From @Temp
				Set @Count=1
				Set @TaxRecCount = @RecCount+1
				While @RecCount>=@Count
				Begin
					Set @DetailId=(Select DetailId From @Temp Where S_No=@Count)
					
					Insert Into Bean.JournalDetail (Id,JournalId,COAId,AccountDescription,TaxId,TaxRate,DocCredit,DocDebit,BaseCredit,BaseDebit,DocDebitTotal,DocCreditTotal,BaseDebitTotal,BaseCreditTotal,DocTaxDebit,DocTaxCredit,BaseTaxDebit,BaseTaxCredit,DocumentId,DocumentDetailId,BaseCurrency,ExchangeRate,GSTExCurrency,GSTExchangeRate,DocType,DocSubType,ServiceCompanyId,DocNo,Nature,OffsetDocument,IsTax,EntityId,SystemRefNo,Remarks,CreditTermsId,DocCurrency,DocDate,DocDescription,PostingDate,RecOrder,GSTCredit,GSTTaxCredit,GSTDebit,GSTTaxDebit)										
					Select NEWID(),@JournalId,WD.COAId As COAId,WD.Description As AccountDescription,WD.TaxId,WD.TaxRate,
							Case When W.DocType =@DepositDocument and WD.DocAmount>0 Then WD.DocAmount  
								 When (W.DocType=@CashPaymentDocument or W.DocType=@WithdrawalDocument) and Wd.DocAmount < 0  Then ABS(WD.DocAmount) End As DocCredit,
							Case When W.DocType=@DepositDocument and WD.DocAmount<0 Then ABS(WD.DocAmount)
								 When (W.DocType=@CashPaymentDocument or W.DocType=@WithdrawalDocument) and WD.DocAmount > 0 Then WD.DocAmount Else null End As DocDebit,
							Case When W.DocType=@DepositDocument and WD.BaseAmount>0 Then WD.BaseAmount								
								 When (W.DocType=@CashPaymentDocument or W.DocType=@WithdrawalDocument) and Wd.BaseAmount < 0 Then ABS(WD.BaseAmount) Else null End As BaseCredit,
							Case When W.DocType=@DepositDocument and WD.BaseAmount<0 Then ABS(WD.BaseAmount)
								 When (W.DocType=@CashPaymentDocument or W.DocType=@WithdrawalDocument) and WD.BaseAmount > 0 Then WD.BaseAmount Else null End as BaseDebit,
							'0.00',WD.DocTotalAmount,null,null,
							Case When W.DocType=@DepositDocument and WD.DocTaxAmount<0 Then ABS(WD.DocTaxAmount)
								 When (W.DocType=@CashPaymentDocument or W.DocType=@WithdrawalDocument) and WD.DocTaxAmount > 0 Then WD.DocTaxAmount Else null End as DocTaxDebit,
							Case When W.DocType=@DepositDocument and WD.DocTaxAmount>0 Then WD.DocTaxAmount
								 When (W.DocType=@CashPaymentDocument or W.DocType=@WithdrawalDocument) and Wd.DocTaxAmount < 0 Then ABS(WD.DocTaxAmount) Else null End As DocTaxCredit,
							Case When W.DocType=@DepositDocument and WD.BaseTaxAmount<0 Then ABS(WD.BaseTaxAmount)
								 When (W.DocType=@CashPaymentDocument or W.DocType=@WithdrawalDocument) and WD.BaseTaxAmount > 0 Then WD.BaseTaxAmount Else null End as	BaseTaxDebit,
							Case When W.DocType=@DepositDocument and WD.BaseTaxAmount>0 Then WD.BaseTaxAmount	
								 When (W.DocType=@CashPaymentDocument or W.DocType=@WithdrawalDocument) and WD.BaseTaxAmount < 0 Then Abs(WD.BaseTaxAmount) Else null End as BaseTaxCredit,
							@DocumentId,WD.Id,W.ExCurrency,W.ExchangeRate, W.GSTExCurrency,		W.GSTExchangeRate,@Type,@DocSubTypeGeneral,W.ServiceCompanyId,W.DocNo,null,Null		As				OffsetDocument,0 As		IsTax,W.EntityId,W.DocNo As SystemRefNo,W.Remarks,0 As CreditTermsId,W.DocCurrency,W.DocDate,
							null As DocDescription,W.DocDate As PostingDate,WD.RecOrder As RecOrder,

							Case When W.DocType=@DepositDocument and WD.DocTaxAmount>0 Then ROUND((ISNULL(WD.DocTaxAmount,0)*Isnull(W.GSTExchangeRate,1)),2)	
								 When (W.DocType=@CashPaymentDocument or W.DocType=@WithdrawalDocument) and WD.DocTaxAmount < 0 Then Abs(ROUND((ISNULL(WD.DocTaxAmount,0)*Isnull(W.GSTExchangeRate,1)),2)) Else null End as GSTCredit,

								 Case When W.DocType=@DepositDocument and WD.DocAmount>0 Then ROUND((ISNULL(WD.DocAmount,0)*Isnull(W.GSTExchangeRate,1)),2)	
								 When (W.DocType=@CashPaymentDocument or W.DocType=@WithdrawalDocument) and WD.DocAmount < 0 Then Abs(ROUND((ISNULL(WD.DocAmount,0)*Isnull(W.GSTExchangeRate,1)),2)) Else null End as GSTTaxCredit,

							Case When W.DocType=@DepositDocument and WD.DocTaxAmount<0 Then ABS(ROUND((ISNULL(WD.DocTaxAmount,0)*Isnull(W.GSTExchangeRate,1)),2))
								 When (W.DocType=@CashPaymentDocument or W.DocType=@WithdrawalDocument) and WD.BaseTaxAmount > 0 Then ROUND((ISNULL(WD.DocTaxAmount,0)*Isnull(W.GSTExchangeRate,1)),2) Else null End as	GSTDebit,

								 Case When W.DocType=@DepositDocument and WD.DocAmount<0 Then ABS(ROUND((ISNULL(WD.DocAmount,0)*Isnull(W.GSTExchangeRate,1)),2))
								 When (W.DocType=@CashPaymentDocument or W.DocType=@WithdrawalDocument) and WD.DocAmount > 0 Then ROUND((ISNULL(WD.DocAmount,0)*Isnull(W.GSTExchangeRate,1)),2) Else null End as	GSTDebit

					From Bean.WithDrawalDetail(Nolock) As WD
					Inner Join Bean.WithDrawal(Nolock) As W On W.Id=WD.WithdrawalId
					Where WD.Id=@DetailId
					-- Inserting Tax Lineitem into journaldetail
					If Exists (Select B.Id From Bean.WithDrawal(Nolock) As A Inner Join Bean.WithDrawalDetail(Nolock) As B On A.Id=B.WithdrawalId Where A.IsGstSettingsActivated=1 And B.TaxRate is not null 
					And Convert(nvarchar(20),B.TaxIdCode)<>@NA And B.Id=@DetailId)
					Begin
						--Set @TaxRecCount=@RecCount+@TaxRecOrder
						Insert Into Bean.JournalDetail (Id,JournalId,COAId,AccountDescription,AllowDisAllow,TaxId,TaxRate,DocDebit,DocCredit,DocTaxCredit,DocTaxDebit,BaseCredit,BaseDebit,DocDebitTotal,DocCreditTotal,BaseDebitTotal,BaseCreditTotal,DocumentId,DocumentDetailId,ItemId,BaseCurrency,ExchangeRate,GSTExCurrency,GSTExchangeRate,DocType,DocSubType,ServiceCompanyId,DocNo,Nature,OffsetDocument,IsTax,EntityId,SystemRefNo,Remarks,CreditTermsId,NoSupportingDocs,BaseAmount,DocCurrency,DocDate,DocDescription,PostingDate,RecOrder,DocTaxAmount,BaseTaxAmount)

						Select NEWID(),@JournalId,(Select Id From Bean.ChartOfAccount(nolock) Where CompanyId=@CompanyId And Name=@COATaxPaybleGST) As COAId,W.DocDescription As AccountDescription,W.IsAllowableNonAllowableActivated,WD.TaxId,WD.TaxRate,
								Case When W.DocType=@DepositDocument and WD.DocTaxAmount<0 Then ABS(WD.DocTaxAmount)
									 When (W.DocType=@CashPaymentDocument or W.DocType=@WithdrawalDocument) and WD.DocTaxAmount > 0 Then WD.DocTaxAmount Else null End As DocDebit,
								Case When W.DocType=@DepositDocument and WD.DocTaxAmount>0 Then WD.DocTaxAmount
									 When (W.DocType=@CashPaymentDocument or W.DocType=@WithdrawalDocument) and Wd.DocTaxAmount < 0 Then ABS(WD.DocTaxAmount) Else null End As DocCredit,
								'0.00' As DocTaxCredit,'0.00' As DocTaxDebit,
								Case When W.DocType=@DepositDocument and WD.BaseTaxAmount>0 Then WD.BaseTaxAmount
									 When (W.DocType=@CashPaymentDocument or W.DocType=@WithdrawalDocument) and WD.BaseTaxAmount < 0 Then Abs(WD.BaseTaxAmount) Else null End As BaseCredit,
								Case When W.DocType=@DepositDocument and WD.BaseTaxAmount<0 Then ABS(WD.BaseTaxAmount)
									 When (W.DocType=@CashPaymentDocument or W.DocType=@WithdrawalDocument) and WD.BaseTaxAmount > 0 Then WD.BaseTaxAmount Else null End As BaseDebit,
								'0.00' As DocDebitTotal,'0.00' As DocCreditTotal,null As BaseDebitTotal,null As BaseCreditTotal,
								@DocumentId, WD.Id, @GUIDZero, W.ExCurrency, W.ExchangeRate, W.GSTExCurrency, W.GSTExchangeRate, @Type, @DocSubTypeGeneral, W.ServiceCompanyId,W.DocNo,null,Null As OffsetDocument,1 As IsTax,W.EntityId,W.DocNo As SystemRefNo,W.Remarks,0 As CreditTermsId, W.NoSupportingDocs, null As BaseAmount,W.DocCurrency,W.DocDate,null As DocDescription, W.DocDate, @TaxRecCount As RecOrder, WD.DocTaxAmount, WD.BaseTaxAmount
						From Bean.WithDrawalDetail(Nolock) As WD
						Inner Join Bean.WithDrawal(Nolock) As W On W.Id=WD.WithdrawalId
						Where WD.Id=@DetailId
						--Set @TaxRecOrder=@TaxRecOrder+1
						Set @TaxRecCount = @TaxRecCount+1
					End
					Set @Count=@Count+1
				End

				Select @ExchangeRate=ExchangeRate from Bean.WithDrawal(Nolock) where CompanyId=@CompanyId and Id=@DocumentId
				Select @MasterBaseAmount=Cast(ABS(Sum(ROUND(DocAmount*ISNULL(@ExchangeRate,1),2)+(Round(Isnull(DocTaxAmount,0)*ISNULL(@ExchangeRate,1),2))))as money) from Bean.WithDrawalDetail(Nolock) where WithdrawalId=@DocumentId

				--Inserting Master Records Into JournalDetail From Withdrawal 
				Insert Into Bean.JournalDetail (Id,JournalId,COAId,AccountDescription,DocCredit,DocDebit,BaseCredit,BaseDebit,DocCreditTotal,DocDebitTotal,BaseCreditTotal,BaseDebitTotal,DocumentId,DocumentDetailId,ItemId,DueDate,ExchangeRate,GSTExchangeRate,GSTExCurrency,Nature,DocType,DocSubType,ServiceCompanyId,CreditTermsId,DocNo,PostingDate,RecOrder,DocumentAmount,Currency,BaseCurrency,IsTax,EntityId,SystemRefNo,Remarks,BaseAmount,DocCurrency,DocDate,DocDescription)
													
				Select NewId(),@JournalId, (Select Id from Bean.ChartOfAccount(nolock) where CompanyId=@CompanyId and Id=COAId) As COAId, DocDescription,
						Case When (DocType=@CashPaymentDocument or DocType=@WithdrawalDocument) Then Round(GrandTotal,2) End as DocCredit,
						Case When DocType=@DepositDocument Then Round(GrandTotal,2) End as DocDebit, 
						Case When (DocType=@CashPaymentDocument or DocType=@WithdrawalDocument) Then /*Round((GrandTotal*Isnull(ExchangeRate,1)),2)*/ @MasterBaseAmount End as BaseCredit,
						Case When DocType=@DepositDocument Then /*Round((GrandTotal*Isnull(ExchangeRate,1)),2)*/@MasterBaseAmount End as BaseDebit,
						Case When (DocType=@CashPaymentDocument or DocType=@WithdrawalDocument) Then Round(GrandTotal,2) Else 0 End DocCreditTotal,
						Case When DocType=@DepositDocument Then Round(GrandTotal,2) Else 0 End DocDebitTotal,
						Case When (DocType=@CashPaymentDocument or DocType=@WithdrawalDocument) Then /*Round((GrandTotal*Isnull(ExchangeRate,1)),2)*/@MasterBaseAmount End As BaseCreditTotal,
						Case When DocType=@DepositDocument Then /*Round((GrandTotal*Isnull(ExchangeRate,1)),2)*/@MasterBaseAmount End as BaseDebitTotal,
						@DocumentId,@GUIDZero,@GUIDZero, DocDate, ExchangeRate, GSTExchangeRate, GSTExCurrency, null, @Type, @DocSubTypeGeneral,ServiceCompanyId,0, DocNo, DocDate,(Select Max(Recorder)+1 
				From Bean.JournalDetail(Nolock) 
				Where DocumentId=@DocumentId),Round(GrandTotal,2),	DocCurrency,ExCurrency,0,EntityId,DocNo,Remarks,/*Round((GrandTotal*Isnull(ExchangeRate,1)),2)*/@MasterBaseAmount,DocCurrency,DocDate,DocDescription From Bean.WithDrawal(Nolock) Where Id=@DocumentId


				If((select ABS(SUM(BaseDebit)-SUM(BaseCredit)) from Bean.JournalDetail(Nolock) where DocumentId=@DocumentId group by DocType)>=0.01)
				Begin
					Select @BaseDebit=SUM(BaseDebit),@BaseCredit=SUM(BaseCredit),@DiffAmount=ABS(SUM(BaseDebit)-SUM(BaseCredit)) from Bean.JournalDetail(Nolock) where DocumentId=@DocumentId
					Insert Into Bean.JournalDetail(Id,JournalId,COAId,AccountDescription,BaseDebit,BaseCredit,DocumentId,DocumentDetailId,ItemId,DocDate,DueDate,PostingDate,ExchangeRate,GSTExchangeRate,GSTExCurrency,Nature,DocType,DocSubType,ServiceCompanyId, CreditTermsId, DocNo, Currency,BaseCurrency,IsTax,EntityId, SystemRefNo,  DocCurrency, RecOrder,DocDebitTotal,DocCreditTotal)
					select NEWID(), @JournalId, (Select Id from Bean.ChartOfAccount(nolock) where CompanyId=@CompanyId and Name=@Rounding),DocDescription, Case When @BaseDebit>@BaseCredit Then null Else @DiffAmount End as BaseDebit, Case When @BaseCredit>@BaseDebit Then null Else @DiffAmount END as BaseCredit, @DocumentId,NEWID(), @GUIDZero, DocDate, DocDate, DocDate, ExchangeRate, GSTExchangeRate, GSTExCurrency, NULL, DocType, @DocSubTypeGeneral, ServiceCompanyId, NULl,DocNo, DocCurrency, ExCurrency, 0, EntityId,DocNo, DocCurrency, (Select Max(Recorder)+1 From Bean.JournalDetail(nolock) Where DocumentId=@DocumentId),0,0
					from Bean.WithDrawal(Nolock) where CompanyId=@CompanyId and Id=@DocumentId
				End

				-- Inserting Records into DocumentHistory Table
				IF EXISTS(Select Id from Bean.DocumentHistory(Nolock) where CompanyId=@companyId and TransactionId=@DocumentId and DocumentId=@DocumentId)
				BEGIN
					Update Bean.DocumentHistory set AgingState='Deleted' where CompanyId=@CompanyId and DocumentId=@DocumentId and TransactionId=@DocumentId and AgingState is null
					Insert Into Bean.DocumentHistory(Id,TransactionId,CompanyId,DocumentId,DocType,DocSubType,DocState,DocCurrency,DocAmount,DocBalanaceAmount,ExchangeRate,BaseAmount,BaseBalanaceAmount,StateChangedBy,StateChangedDate,PostingDate,DocAppliedAmount,BaseAppliedAmount,AgingState)
					Select NEWID(),@DocumentId,CompanyId,@DocumentId,DocType,@DocSubTypeGeneral,DocumentState,DocCurrency,Round(GrandTotal,2) As DocAmount,0 As DocBalanceAmount,ExchangeRate,Round(GrandTotal*ExchangeRate,2) As BaseAmount,Round(0*ExchangeRate,2) As BaseBalanceAmount,ModifiedBy,GETUTCDATE(),DocDate,Round(GrandTotal,2) As DocAppliedAmount,Round(GrandTotal*ExchangeRate,2) As BaseAppliedAmount,null From Bean.WithDrawal(Nolock) Where Id=@DocumentId
				END
				ELSE
				BEGIN
					Insert Into Bean.DocumentHistory(Id,TransactionId,CompanyId,DocumentId,DocType,DocSubType,DocState,DocCurrency,DocAmount,DocBalanaceAmount,ExchangeRate,BaseAmount,BaseBalanaceAmount,StateChangedBy,StateChangedDate,PostingDate,DocAppliedAmount,BaseAppliedAmount,AgingState)
					Select NEWID(),@DocumentId,CompanyId,@DocumentId,DocType,@DocSubTypeGeneral,DocumentState,DocCurrency,Round(GrandTotal,2) As DocAmount,0 As DocBalanceAmount,ExchangeRate,Round(GrandTotal*ExchangeRate,2) As BaseAmount,Round(0*ExchangeRate,2) As BaseBalanceAmount,usercreated,GETUTCDATE(),DocDate,Round(GrandTotal,2) As DocAppliedAmount,Round(GrandTotal*ExchangeRate,2) As BaseAppliedAmount,null From Bean.WithDrawal(Nolock) Where Id=@DocumentId
				END
				
				--Calling BRC to be re run SP
				If (@IsBankAccountExists=1)
				Begin
					exec Bean_Update_BRC_Re_Run @companyId, @OldServEntityId, @NewServEntityId, @NewCoaId, @OldCoaId, @OldDocdate, @NewDocDate, @OldDocAmount, @NewDocAmount, @IsAdd
				End
			End

			Else If(@Type=@CashSaleDocument)
			Begin
				If Not Exists(select Id from Bean.CashSale(nolock) where CompanyId=@CompanyId and Id=@SourceId)
				Begin
					Raiserror(@InvalidDocumentError,16,1);
				End
				Set @DocumentId=@SourceId

				If Exists(select Id from Bean.Journal(nolock) where CompanyId=@CompanyId and DocumentId=@DocumentId)
				Begin
					Select @OldEntityId = EntityId from Bean.Journal(nolock) where CompanyId=@CompanyId and DocumentId=@DocumentId
					Delete from Bean.JournalDetail with (ROWLOCK) where DocumentId=@DocumentId and DocType=@Type
					Delete from Bean.Journal with (ROWLOCK) where DocumentId=@DocumentId and CompanyId=@CompanyId and DocType=@Type
				End
				Else
				Begin
					--For Customer Balance updation we are getting EntityID 
					Set @OldEntityId = @EntityId 
				End

				If Exists(select Id from Bean.Journal(nolock) where CompanyId=@CompanyId and DocumentId=@DocumentId and DocType=@Type)
				Begin
					-----For BRC we need to check for the bank account
					select @OldCoaId=COAId,@OldServEntityId=ServiceCompanyId,@OldDocAmount=Case When DocDebit IS null Then DocCredit Else DocDebit End,@OldDocdate=PostingDate from Bean.JournalDetail(nolock) where DocumentId=@DocumentId and DocumentDetailId='00000000-0000-0000-0000-000000000000'
					Select @NewCoaId=COAId,@NewServEntityId=ServiceCompanyId,@NewDocAmount=GrandTotal,@NewDocDate=DocDate from Bean.WithDrawal(nolock) where CompanyId=@CompanyId and Id=@DocumentId and DocType=@Type
					Set @IsAdd=0;
					Delete from Bean.JournalDetail with (ROWLOCK) where DocumentId=@SourceId and DocType=@Type
					Delete from Bean.Journal with (ROWLOCK) where DocumentId=@SourceId and CompanyId=@CompanyId and DocType=@Type
				End
				Else
				Begin
					Set @IsAdd=1;
					Select @NewCoaId=COAId,@OldCoaId=COAId,@NewServEntityId=ServiceCompanyId,@OldServEntityId=ServiceCompanyId,@NewDocAmount=GrandTotal,@OldDocAmount=GrandTotal,@NewDocDate=DocDate,@OldDocdate=DocDate from Bean.CashSale(nolock) where CompanyId=@CompanyId and Id=@DocumentId and DocType=@Type
				End
				If Exists(Select Id from Bean.ChartOfAccount(nolock) where CompanyId=@CompanyId and Id in (@NewCoaId,@OldCoaId) and IsBank=1)
				Begin
					Set @IsBankAccountExists=1
				End

				Select @ExchangeRate=ExchangeRate from Bean.CashSale(nolock) where CompanyId=@CompanyId and Id=@DocumentId
				Select @MasterBaseAmount=Cast(Sum(ROUND(ABS(DocAmount)*ISNULL(@ExchangeRate,1),2)+(Round(ABS(Isnull(DocTaxAmount,0))*ISNULL(@ExchangeRate,1),2)))as money) from Bean.CashSaleDetail(nolock) where CashSaleId=@DocumentId

				-- Inserting Records Into Journal From Cash Sale 
				Set @JournalId = NEWID()
				Insert Into Bean.Journal (Id,CompanyId,DocDate,DocType,DocSubType,DocNo,ServiceCompanyId,SystemReferenceNo,IsNoSupportingDocs,NoSupportingDocument,DocCurrency,ExchangeRate,ExCurrency,GSTExchangeRate,GSTExCurrency,GSTTotalAmount,DocumentState,IsNoSupportingDocument,IsGstSettings,IsMultiCurrency,IsAllowableNonAllowable,Remarks,UserCreated,CreatedDate,ModifiedBy,ModifiedDate,Status,DocumentDescription,CreationType,GrandDocDebitTotal,GrandBaseDebitTotal,DueDate,EntityId,EntityType,PoNo,PostingDate,IsGSTApplied,COAId,DocumentId,CreditTermsId,Nature,BalanceAmount,ActualSysRefNo,RefNo,IsSegmentReporting,TransferRefNo,ModeOfReceipt)
				Select @JournalId,CompanyId,DocDate,@Type,DocSubType,DocNo,ServiceCompanyId,DocNo As SystemRefNo, IsNoSupportingDocument, NoSupportingDocs, DocCurrency,ExchangeRate,ExCurrency, GSTExchangeRate,GSTExCurrency,Isnull(GSTTotalAmount,0), DocumentState, IsNoSupportingDocument, IsGstSettings, IsMultiCurrency, IsAllowableNonAllowable, Remarks,UserCreated, CreatedDate, ModifiedBy, ModifiedDate, Status, DocDescription,@CreationTypeSystem,Round(GrandTotal,2) As GrandDocDebitTotal,/*Round((GrandTotal*Isnull(ExchangeRate,1)),2)*/@MasterBaseAmount As GrandBaseDebitTotal,DocDate,EntityId,EntityType,PONo,DocDate As PostingDate,IsGSTApplied,
					(Select Id From Bean.ChartOfAccount(nolock) Where CompanyId=@CompanyId And Id=COAId) As COAId,
					Id As Documentid,null as CreditTermsId,null as Nature,BalanceAmount,DocNo As ActualSysRefNo,Null,ISNULL(IsSegmentReporting,0),ReceiptrefNo,ModeOfReceipt
				From Bean.CashSale(nolock) Where Id=@DocumentId

				-- Inserting Records Into JournalDetail From Cash Sale Detail
				Insert Into @Temp
				Select Id From Bean.CashSaleDetail(nolock) Where CashSaleId=@DocumentId Order By RecOrder
				
				Select @RecCount=Count(*) From @Temp
				Set @Count=1
				Set @TaxRecCount = @RecCount+1
				While @RecCount>=@Count
				Begin
					Set @DetailId=(Select DetailId From @Temp Where S_No=@Count)
					--Set @RecOrder=1
					Insert Into Bean.JournalDetail (Id,JournalId,COAId,AccountDescription,TaxId,TaxRate,DocDebit,DocCredit,DocTaxCredit,BaseDebit,BaseCredit,DocDebitTotal,DocCreditTotal,BaseDebitTotal,BaseCreditTotal,DocumentId,DocumentDetailId,ItemId,ItemCode,ItemDescription,	BaseCurrency,ExchangeRate,	GSTExCurrency,GSTExchangeRate,DocType,DocSubType,ServiceCompanyId,DocNo,Nature,OffsetDocument,IsTax,EntityId,SystemRefNo,Remarks,PONo,CreditTermsId,DocCurrency,DocDate,DocDescription,PostingDate,RecOrder,DocTaxAmount,BaseTaxAmount,BaseTaxCredit,GSTCredit,GSTTaxCredit)
					Select NEWID(),@JournalId,CSD.COAId As COAId,CSD.ItemDescription As AccountDescription,CSD.TaxId,CSD.TaxRate,null As DocDebit,CSD.DocAmount As DocCredit,CSD.DocTaxAmount,null As BaseDebit,CSD.BaseAmount as BaseCredit, '0.00', CSD.DocTotalAmount,null,null,	@DocumentId,CSD.Id,CSD.ItemId,CSD.ItemCode,CSD.ItemDescription,CS.ExCurrency, CS.ExchangeRate,CS.GSTExCurrency,CS.GSTExchangeRate,@Type,CS.DocSubType,CS.ServiceCompanyId,CS.DocNo,null Nature,Null As OffsetDocument,0 As IsTax,CS.EntityId,CS.DocNo As SystemRefNo,CS.Remarks,CS.PONo,0 As CreditTermsId,CS.DocCurrency,CS.DocDate,
							null As DocDescription,CS.DocDate As PostingDate,CSD.RecOrder As RecOrder,CSD.DocTaxAmount,CSD.BaseTaxAmount,CSD.BaseTaxAmount,
							ROUND((ISNULL(CSD.DocTaxAmount,0)*Isnull(CS.GSTExchangeRate,1)),2) as GSTCredit,
							ROUND((ISNULL(CSD.DocAmount,0)*Isnull(CS.GSTExchangeRate,1)),2) as GSTTaxCredit
					From Bean.CashSaleDetail As CSD(nolock)
					Inner Join Bean.CashSale As CS On CS.Id=CSD.CashSaleId
					Where CSD.Id=@DetailId

					-- Inserting Tax Lineitem into journaldetail
					If Exists (Select B.Id From Bean.CashSale(nolock) As A Inner Join Bean.CashSaleDetail As B On A.Id=B.CashSaleId Where A.IsGstSettings=1 And B.TaxRate is not null 
						And Convert(nvarchar(20),B.TaxIdCode)<>@NA And B.Id=@DetailId)
					Begin
						--Set @TaxRecCount=@RecCount+@TaxRecOrder
						Insert Into Bean.JournalDetail (Id,JournalId,COAId,AccountDescription,AllowDisAllow,TaxId,TaxRate,DocDebit,DocCredit,DocTaxDebit,DocTaxCredit,BaseDebit,BaseCredit,DocDebitTotal,DocCreditTotal,BaseDebitTotal,BaseCreditTotal,DocumentId, DocumentDetailId, ItemId, BaseCurrency, ExchangeRate, GSTExCurrency,GSTExchangeRate,DocType,DocSubType,ServiceCompanyId,DocNo,Nature,OffsetDocument,IsTax,EntityId,SystemRefNo,Remarks,CreditTermsId,NoSupportingDocs,BaseAmount,DocCurrency,DocDate,DocDescription,PostingDate,RecOrder,DocTaxAmount,BaseTaxAmount)

						Select NEWID(),@JournalId,(Select Id From Bean.ChartOfAccount(nolock) Where CompanyId=@CompanyId And Name=@COATaxPaybleGST) As COAId,CS.DocDescription As AccountDescription,CSD.AllowDisAllow,CSD.TaxId,CSD.TaxRate,null As DocDebit,CSD.DocTaxAmount As DocCredit,'0.00' As DocTaxDebit,'0.00' As DocTaxCredit,null As BaseDebit,Round(CSD.DocTaxAmount*Isnull(CS.ExchangeRate,1),2) As BaseCredit,'0.00' As DocDebitTotal,'0.00' As DocCreditTotal,null As BaseDebitTotal,null As BaseCreditTotal,	@DocumentId,CSD.Id,@GUIDZero,CS.ExCurrency,CS.ExchangeRate,CS.GSTExCurrency,CS.GSTExchangeRate,@Type,CS.DocSubType,CS.ServiceCompanyId,CS.DocNo,null as Nature,Null As OffsetDocument,1 As IsTax,CS.EntityId,CS.DocNo As SystemRefNo,CS.Remarks,Null As CreditTermsId,CS.NoSupportingDocs,null As BaseAmount,CS.DocCurrency,CS.DocDate,null As DocDescription,CS.DocDate, @TaxRecCount As RecOrder,CSD.DocTaxAmount,CSD.BaseTaxAmount
						From Bean.CashSaleDetail As CSD(nolock)
						Inner Join Bean.CashSale As CS(nolock) On CS.Id=CSD.CashSaleId
						Where CSD.Id=@DetailId
						--Set @TaxRecOrder=@TaxRecOrder+1
						Set @TaxRecCount = @TaxRecCount+1
					End
					Set @Count=@Count+1
				End

				-- Inserting Master Records Into JournalDetail From Cash Sale 
				Insert Into Bean.JournalDetail (Id,JournalId,COAId,AccountDescription,DocDebit,BaseDebit,DocDebitTotal,BaseDebitTotal,DocumentId,DocumentDetailId,ItemId,DueDate,ExchangeRate,GSTExchangeRate,GSTExCurrency,Nature,DocType,DocSubType,ServiceCompanyId,CreditTermsId,DocNo,PostingDate,RecOrder,DocumentAmount,Currency,BaseCurrency,IsTax,EntityId,SystemRefNo,Remarks,PONo,BaseAmount,DocCurrency,DocDate,DocDescription,DocCreditTotal)
				Select NewId(),@JournalId,(Select Id From Bean.ChartOfAccount(nolock) Where CompanyId=@CompanyId And Id=COAId) As COAId,
				DocDescription,Round(GrandTotal,2),/*Round((GrandTotal*Isnull(ExchangeRate,1)),2)*/@MasterBaseAmount,Round(GrandTotal,2),/*Round((GrandTotal*Isnull(ExchangeRate,1)),2)*/@MasterBaseAmount As BaseDebitTotal,@DocumentId,@GUIDZero,@GUIDZero,
				DocDate,ExchangeRate,GSTExchangeRate,GSTExCurrency,null as Nature, @Type,@DocSubTypeGeneral,ServiceCompanyId,null as CreditTermsId, DocNo, DocDate,(Select Max(Recorder)+1 From Bean.JournalDetail Where DocumentId=@DocumentId),Round(GrandTotal,2),
				DocCurrency,ExCurrency,0,EntityId,DocNo,Remarks,PONo,/*Round(GrandTotal*Isnull(ExchangeRate,1),2)*/@MasterBaseAmount,DocCurrency,DocDate,DocDescription,'0.00'
				From Bean.CashSale(nolock) Where Id=@DocumentId


				If((select ABS(SUM(BaseDebit)-SUM(BaseCredit)) from Bean.JournalDetail(nolock) where DocumentId=@DocumentId group by DocType)>=0.01)
				Begin
					Select @BaseDebit=SUM(BaseDebit),@BaseCredit=SUM(BaseCredit),@DiffAmount=ABS(SUM(BaseDebit)-SUM(BaseCredit)) from Bean.JournalDetail(nolock) where DocumentId=@DocumentId
					Insert Into Bean.JournalDetail (Id,JournalId,COAId,AccountDescription,BaseDebit,BaseCredit,DocumentId,DocumentDetailId,ItemId,DocDate,DueDate,PostingDate,ExchangeRate,GSTExchangeRate,GSTExCurrency,Nature,DocType,DocSubType,ServiceCompanyId, CreditTermsId, DocNo, Currency, BaseCurrency, IsTax, EntityId, SystemRefNo,  DocCurrency, RecOrder,DocDebitTotal,DocCreditTotal)
					select NEWID(), @JournalId, (Select Id from Bean.ChartOfAccount(nolock) where CompanyId=@CompanyId and Name=@Rounding), DocDescription, Case When @BaseDebit>@BaseCredit Then null Else @DiffAmount End as BaseDebit, Case When @BaseCredit>@BaseDebit Then null Else @DiffAmount END as BaseCredit, @DocumentId,NEWID(),@GUIDZero,DocDate,DocDate,DocDate,ExchangeRate,GSTExchangeRate,GSTExCurrency,null as Nature, DocType, DocSubType, ServiceCompanyId, null as CreditTermsId,DocNo, DocCurrency, ExCurrency, 0, EntityId,DocNo, DocCurrency, (Select Max(Recorder)+1 From Bean.JournalDetail(nolock) Where DocumentId=@DocumentId),0,0
					from Bean.CashSale(nolock) where CompanyId=@CompanyId and Id=@DocumentId
				End


				-- Inserting Records into DocumentHistory Table
				Insert Into Bean.DocumentHistory(Id,TransactionId,CompanyId,DocumentId,DocType,DocSubType,DocState,DocCurrency,DocAmount,DocBalanaceAmount,ExchangeRate,BaseAmount,BaseBalanaceAmount,StateChangedBy,StateChangedDate,PostingDate,DocAppliedAmount,BaseAppliedAmount,AgingState)
				Select NEWID(),@DocumentId,CompanyId,@DocumentId,DocType,DocSubType,DocumentState,DocCurrency,Round(GrandTotal,2) As DocAmount,Round(BalanceAmount,2) As DocBalanceAmount,ExchangeRate,/*Round(GrandTotal*ExchangeRate,2)*/@MasterBaseAmount As BaseAmount,/*Round(GrandTotal*ExchangeRate,2)*/@MasterBaseAmount As BaseBalanceAmount,UserCreated,GETUTCDATE(),DocDate,Round(GrandTotal,2) AS DocAppliedAmount,/*Round(GrandTotal*ExchangeRate,2)*/@MasterBaseAmount As BaseAppliedAmount,null From Bean.CashSale(nolock) Where Id=@DocumentId

				--Calling BRC to be re run SP
				If (@IsBankAccountExists=1)
				Begin
					exec Bean_Update_BRC_Re_Run @companyId, @OldServEntityId, @NewServEntityId, @NewCoaId, @OldCoaId, @OldDocdate, @NewDocDate, @OldDocAmount, @NewDocAmount, @IsAdd
				End
			End

			Else If(@Type=@CreditNoteDocument)
			Begin
				Set @DocumentId=@SourceId
				If Not Exists(select Id from Bean.Invoice(nolock) where CompanyId=@CompanyId and Id=@DocumentId and DocType=@Type)
				Begin
					RAISERROR(@InvalidDocumentError,16,1);
				End
			
				---For Interco posting -- Get Service CompanyId by entityid
				Set @Nature=(select Nature from Bean.Invoice(nolock) where Id=@SourceId)
				If(@Nature=@NatureInterco)
				Begin
					--For Customer Balance updation we are getting EntityID 
					Set @EntityId=(Select EntityId From Bean.Invoice(nolock) Where Id=@SourceId)
					Set @ServiceEntityId=(Select ServiceEntityId from Bean.Entity(nolock) where id=@EntityId and CompanyId=@CompanyId)
					Set @DocumentId =@SourceId
					Set @ServiceEntityShortName= (select ShortName from Common.Company(nolock) where Id=@ServiceEntityId)
				End
				Else
				Begin
					IF (@DocumentId Is NUll Or @DocumentId='00000000-0000-0000-0000-000000000000')
					Begin
						Set @DocumentId=@SourceId
						--For Customer Balance updation we are getting EntityID 
						Set @EntityId = (Select EntityId From Bean.Invoice(nolock) Where Id=@SourceId and CompanyId=@CompanyId)
					End
					Else IF (@DocumentId Is Not NUll)
					Begin
						--For Customer Balance updation we are getting EntityID 
						Set @EntityId = (Select EntityId From Bean.Invoice(nolock) Where Id=@SourceId and CompanyId=@CompanyId)
					End
					Else
					Begin
						Set @EntityId = (Select EntityId From Bean.Invoice(nolock) Where DocumentId=@SourceId and CompanyId=@CompanyId)
					End
				End

				If Exists(select Id from Bean.Journal(nolock) where CompanyId=@CompanyId and DocumentId=@DocumentId)
				Begin
					Select @OldEntityId = EntityId from Bean.Journal(nolock) where CompanyId=@CompanyId and DocumentId=@DocumentId
					Delete from Bean.JournalDetail where DocumentId=@DocumentId and DocType=@Type
					Delete from Bean.Journal where DocumentId=@DocumentId and CompanyId=@CompanyId and DocType=@Type
				End
				Else
				Begin
					--For Customer Balance updation we are getting EntityID 
					Set @OldEntityId = @EntityId 
				End
				
						
				-- Inserting Records Into Journal From Invoce 
				Set @JournalId = NEWID()
				Insert Into Bean.Journal (Id,CompanyId,DocDate,DocType,DocSubType,DocNo,ServiceCompanyId,SystemReferenceNo,IsNoSupportingDocs,NoSupportingDocument,DocCurrency,ExchangeRate,ExCurrency,GSTExchangeRate,GSTExCurrency,GSTTotalAmount,DocumentState,IsNoSupportingDocument,IsGstSettings,IsMultiCurrency,IsAllowableNonAllowable,Remarks,UserCreated,CreatedDate,ModifiedBy,ModifiedDate,Status,DocumentDescription,CreationType,GrandDocCreditTotal,GrandBaseCreditTotal,DueDate,EntityId,EntityType,PoNo,PostingDate,IsGSTApplied,COAId,DocumentId,CreditTermsId,Nature,BalanceAmount,ActualSysRefNo,RefNo,IsSegmentReporting)
				Select @JournalId,CompanyId,DocDate,@Type,DocSubType,DocNo,ServiceCompanyId,DocNo As SystemRefNo, IsNoSupportingDocument, NoSupportingDocs, DocCurrency,ExchangeRate,ExCurrency, GSTExchangeRate,GSTExCurrency,Isnull(GSTTotalAmount,0),DocumentState,IsNoSupportingDocument,IsGstSettings,IsMultiCurrency,IsAllowableNonAllowable,Remarks,UserCreated,CreatedDate,ModifiedBy,ModifiedDate,Status,DocDescription,@CreationTypeSystem,Round(GrandTotal,2) As GrandDocCreditTotal,Round((GrandTotal*Isnull(ExchangeRate,1)),2) As GrandBaseCreditTotal,DueDate,EntityId,EntityType,PONo,DocDate As PostingDate,IsGSTApplied,
						Case when Nature=@NatureTrade Then (Select Id From Bean.ChartOfAccount(nolock) Where CompanyId=@CompanyId And Name=@COATradeReceivables)
							 when Nature=@NatureOthers Then (Select Id From Bean.ChartOfAccount(nolock) Where CompanyId=@CompanyId And Name=@COAotherReceivables)
							 When Nature=@NatureInterco Then (Select Id From Bean.ChartOfAccount(nolock) Where CompanyId=@CompanyId and SubsidaryCompanyId=@ServiceEntityId and Name=Concat('I/B - ',@ServiceEntityShortName)) End As COAId,
						Id As Documentid,CreditTermsId,Nature,BalanceAmount,DocNo As ActualSysRefNo,Null,ISNULL(IsSegmentReporting,0)
				From Bean.Invoice(nolock) Where Id=@DocumentId

				-- Inserting Records Into JournalDetail From InvoceDetail
				Insert Into @Temp
				Select Id From Bean.InvoiceDetail(nolock) Where InvoiceId=@DocumentId Order By RecOrder
				
				Select @RecCount=Count(*) From @Temp
				Set @Count=1
				Set @TaxRecCount = @RecCount+1
				While @RecCount>=@Count
				Begin
					Set @DetailId=(Select DetailId From @Temp Where S_No=@Count)
						--Set @RecOrder=1
					Insert Into Bean.JournalDetail (Id,JournalId,COAId,AccountDescription,TaxId,TaxRate,DocDebit,DocCredit,DocTaxCredit,DocTaxDebit,BaseDebit,BaseCredit,DocDebitTotal,DocCreditTotal,BaseDebitTotal,BaseCreditTotal,DocTaxAmount,BaseTaxAmount,BaseTaxDebit,BaseTaxCredit,DocumentId,DocumentDetailId,ItemId,ItemCode,ItemDescription,BaseCurrency,ExchangeRate,GSTExCurrency,GSTExchangeRate,DocType,DocSubType,ServiceCompanyId,DocNo,Nature,OffsetDocument,IsTax,EntityId,SystemRefNo,Remarks,PONo,CreditTermsId,DocCurrency,DocDate,DocDescription,PostingDate,RecOrder,GSTDebit,GSTTaxDebit,GSTCredit,GSTTaxCredit)

					Select NEWID(),@JournalId,InvID.COAId As COAId,InvID.ItemDescription As AccountDescription, InvID.TaxId,InvID.TaxRate,
						Case When InvID.DocAmount > 0 Then InvID.DocAmount Else null End As DocDebit,
						Case When InvID.DocAmount < 0 Then ABS(InvID.DocAmount) Else null End As DocCredit,
						Case When InvID.DocTaxAmount < 0 Then ABS(InvID.DocTaxAmount) Else null End DocTaxCredit,
						Case When InvID.DocTaxAmount > 0 Then InvID.DocTaxAmount Else null End As DocTaxDebit,
						Case When InvID.BaseAmount > 0 Then InvID.BaseAmount Else null End As BaseDebit,
						Case When InvID.BaseAmount < 0 Then ABS(InvID.BaseAmount) Else null End as BaseCredit,
						Case When InvID.DocTotalAmount > 0 Then InvID.DocTotalAmount Else 0 End as DocDebitTotal,
						Case When InvID.DocTotalAmount < 0 Then ABS(InvID.DocTotalAmount) Else 0 End as DocCreditTotal,
						Case When InvID.BaseTotalAmount > 0 Then InvID.BaseTotalAmount Else null End as BaseDebitTotal,
						Case When InvID.BaseTotalAmount < 0 Then ABS(InvID.BaseTotalAmount) Else null End as BaseCreditTotal,
						ABS(InvID.DocTaxAmount) As DocTaxAmount,
						ABS(InvId.BaseTaxAmount) As BaseTaxAmount,
						Case When InvID.BaseTaxAmount > 0 Then InvID.BaseTaxAmount Else null End As BaseTaxDebit,
						Case When InvID.BaseTaxAmount < 0 Then ABS(InvID.BaseTaxAmount) Else null End As BaseTaxCredit,@DocumentId,InvID.Id,InvID.ItemId,InvID.ItemCode,InvID.ItemDescription,Inv.ExCurrency,Inv.ExchangeRate,	Inv.GSTExCurrency, Inv.GSTExchangeRate, @Type,Inv.DocSubType,Inv.ServiceCompanyId,Inv.DocNo,Inv.Nature,Null AsOffsetDocument,0AsIsTax,Inv.EntityId,Inv.DocNo As SystemRefNo,Inv.Remarks,Inv.PONo,0 As CreditTermsId,Inv.DocCurrency,Inv.DocDate,
						null As DocDescription,Inv.DocDate As PostingDate,InvID.RecOrder As RecOrder,
						Case When InvID.DocTaxAmount > 0 Then ROUND((ISNULL(InvID.DocTaxAmount,0)*Isnull(Inv.GSTExchangeRate,1)),2) Else null End As GSTDebit,
						Case When InvID.DocAmount > 0 Then ROUND((ISNULL(InvID.DocAmount,0)*Isnull(Inv.GSTExchangeRate,1)),2) Else null End As GSTTaxDebit,
						Case When InvID.DocTaxAmount < 0 Then ABS(ROUND((ISNULL(InvID.DocTaxAmount,0)*Isnull(Inv.GSTExchangeRate,1)),2)) Else null End As GSTCredit,
						Case When InvID.DocAmount < 0 Then ABS(ROUND((ISNULL(InvID.DocAmount,0)*Isnull(Inv.GSTExchangeRate,1)),2)) Else null End As GSTTaxCredit
					From Bean.InvoiceDetail(nolock) As InvID
					Inner Join Bean.Invoice As Inv On Inv.Id=InvID.InvoiceId
					Where InvID.Id=@DetailId
					-- Inserting Tax Lineitem into journaldetail
					If Exists (Select B.Id From Bean.Invoice(nolock) As A Inner Join Bean.InvoiceDetail As B On A.Id=B.InvoiceId Where A.IsGstSettings=1 And B.TaxRate is not null 
						And Convert(nvarchar(20),B.TaxIdCode)<>@NA And B.Id=@DetailId)
					Begin
						--Set @TaxRecCount=@RecCount+@TaxRecOrder
						Insert Into Bean.JournalDetail (Id,JournalId,COAId,AccountDescription,AllowDisAllow,TaxId,TaxRate,DocDebit,DocCredit,DocTaxDebit,DocTaxCredit,BaseDebit,BaseCredit,DocDebitTotal,DocCreditTotal,BaseDebitTotal,BaseCreditTotal,DocumentId,DocumentDetailId,ItemId,BaseCurrency,ExchangeRate,GSTExCurrency,GSTExchangeRate,DocType,DocSubType,ServiceCompanyId,DocNo,Nature,OffsetDocument,IsTax,EntityId,SystemRefNo,Remarks,PONo,CreditTermsId,NoSupportingDocs,BaseAmount,DocCurrency,DocDate,DocDescription,PostingDate,RecOrder,DocTaxAmount,BaseTaxAmount)
						Select NEWID(),@JournalId,(Select Id From Bean.ChartOfAccount(nolock) Where CompanyId=@CompanyId And Name=@COATaxPaybleGST) As COAId,Inv.DocDescription As AccountDescription,InvID.AllowDisAllow,InvID.TaxId,InvID.TaxRate,
						Case When InvID.DocTaxAmount > 0 Then InvID.DocTaxAmount Else null End As DocDebit,
						Case When InvID.DocTaxAmount < 0 Then ABS(InvID.DocTaxAmount) Else null End As DocCredit,
						'0.00' As DocTaxDebit,
						'0.00' As DocTaxCredit,
						 Case When InvID.BaseTaxAmount > 0 Then InvID.BaseTaxAmount Else null End As BaseDebit, 
						 Case When InvID.BaseTaxAmount < 0 Then ABS(InvID.BaseTaxAmount) Else null End As BaseCredit,
						'0.00' As DocDebitTotal,'0.00' As DocCreditTotal,null As BaseDebitTotal,null As BaseCreditTotal,@DocumentId,InvID.Id,@GUIDZero,Inv.ExCurrency,Inv.ExchangeRate,Inv.GSTExCurrency,Inv.GSTExchangeRate,@Type,Inv.DocSubType,Inv.ServiceCompanyId,Inv.DocNo,Inv.Nature,Null As OffsetDocument,1 As IsTax,Inv.EntityId,Inv.DocNo As SystemRefNo,Inv.Remarks,Inv.PONo,Null As CreditTermsId,
						 Inv.NoSupportingDocs,null As BaseAmount,Inv.DocCurrency,Inv.DocDate,null As DocDescription,
						Inv.DocDate,@TaxRecCount As RecOrder,InvID.DocTaxAmount,InvID.BaseTaxAmount
						From Bean.InvoiceDetail As InvID(nolock)
						Inner Join Bean.Invoice As Inv(nolock) On Inv.Id=InvID.InvoiceId
						Where InvID.Id=@DetailId
						--Set @TaxRecOrder=@TaxRecOrder+1
						Set @TaxRecCount = @TaxRecCount+1
					End
					Set @Count=@Count+1
				End

				Select @ExchangeRate=ExchangeRate from Bean.Invoice(nolock) where CompanyId=@CompanyId and Id=@DocumentId
				Select @MasterBaseAmount=Cast(Sum(ROUND(ABS(DocAmount)*ISNULL(@ExchangeRate,1),2)+(Round(ABS(Isnull(DocTaxAmount,0))*ISNULL(@ExchangeRate,1),2)))as money) from Bean.InvoiceDetail(nolock) where InvoiceId=@DocumentId

				-- Inserting Master Records Into JournalDetail From Invoce 
				Insert Into Bean.JournalDetail (Id,JournalId,COAId,AccountDescription,DocCredit,BaseCredit,DocCreditTotal,BaseCreditTotal,DocumentId,DocumentDetailId,ItemId,DueDate,ExchangeRate,GSTExchangeRate,GSTExCurrency,Nature,DocType,DocSubType,ServiceCompanyId,CreditTermsId, DocNo, PostingDate, RecOrder, DocumentAmount, Currency,BaseCurrency,IsTax,EntityId,SystemRefNo,Remarks,PONo,BaseAmount, DocCurrency,DocDate,DocDescription,DocDebitTotal)
				Select NewId(),@JournalId,
						Case when Nature=@NatureTrade Then (Select Id From Bean.ChartOfAccount(nolock) Where CompanyId=@CompanyId And Name=@COATradeReceivables)
							 when Nature=@NatureOthers Then (Select Id From Bean.ChartOfAccount(nolock) Where CompanyId=@CompanyId And Name=@COAotherReceivables) 
							 When Nature=@NatureInterco Then (Select Id From Bean.ChartOfAccount(nolock) Where CompanyId=@CompanyId and SubsidaryCompanyId=@ServiceEntityId and Name=Concat('I/B - ',@ServiceEntityShortName)) End As COAId,
						DocDescription,Round(GrandTotal,2),/*Round((GrandTotal*Isnull(ExchangeRate,1)),2)*/@MasterBaseAmount,Round(GrandTotal,2),/*Round((GrandTotal*Isnull(ExchangeRate,1)),2)*/@MasterBaseAmount As BaseCreditTotal,@DocumentId,@GUIDZero,@GUIDZero,DueDate,ExchangeRate,GSTExchangeRate,GSTExCurrency,Nature,@Type,DocSubType,ServiceCompanyId,CreditTermsId, DocNo, DocDate,(Select Max(Recorder)+1 From Bean.JournalDetail Where DocumentId=@DocumentId),Round(GrandTotal,2),
						DocCurrency,ExCurrency,0,EntityId,DocNo,Remarks,PONo,/*Round(GrandTotal*Isnull(ExchangeRate,1),2)*/@MasterBaseAmount,DocCurrency,DocDate,DocDescription,'0.00'
				From Bean.Invoice(nolock) Where Id=@DocumentId

				--0.01 BaseGrandTotal and BaseBalanceAmount updation for Credit Note 
				--IF @MasterBaseAmount!=0 AND @MasterBaseAmount IS NOT NULL
				--Begin
				--	Update Bean.Invoice set BaseGrandTotal=@MasterBaseAmount,BaseBalanceAmount=@MasterBaseAmount where Id=@DocumentId and CompanyId=@CompanyId
				--END


				If((select ABS(SUM(BaseDebit)-SUM(BaseCredit)) from Bean.JournalDetail(nolock) where DocumentId=@DocumentId group by DocType)>=0.01)
				Begin
					Select @BaseDebit=SUM(BaseDebit),@BaseCredit=SUM(BaseCredit),@DiffAmount=ABS(SUM(BaseDebit)-SUM(BaseCredit)) from Bean.JournalDetail(nolock) where DocumentId=@DocumentId
					Insert Into Bean.JournalDetail (Id,JournalId,COAId,AccountDescription,BaseDebit,BaseCredit,DocumentId,DocumentDetailId,ItemId,DocDate,DueDate,PostingDate,ExchangeRate,GSTExchangeRate,GSTExCurrency,Nature,DocType,DocSubType,ServiceCompanyId, CreditTermsId, DocNo, Currency, BaseCurrency, IsTax, EntityId, SystemRefNo,  DocCurrency, RecOrder,DocDebitTotal,DocCreditTotal)
					select NEWID(), @JournalId, (Select Id from Bean.ChartOfAccount(nolock) where CompanyId=@CompanyId and Name=@Rounding), DocDescription, Case When @BaseDebit>@BaseCredit Then null Else @DiffAmount End as BaseDebit, Case When @BaseCredit>@BaseDebit Then null Else @DiffAmount END as BaseCredit, @DocumentId,NEWID(),@GUIDZero,DocDate,DueDate,DocDate,ExchangeRate,GSTExchangeRate,GSTExCurrency,Nature,DocType,DocSubType,ServiceCompanyId,CreditTermsId,DocNo, DocCurrency, ExCurrency, 0, EntityId,DocNo, DocCurrency, (Select Max(Recorder)+1 From Bean.JournalDetail(nolock) Where DocumentId=@DocumentId),0,0
					from Bean.Invoice(nolock) where CompanyId=@CompanyId and Id=@DocumentId
				End


				-- Inserting Records into DocumentHistory Table
				Insert Into @BCDocumentHistoryType(TransactionId,CompanyId,DocumentId,DocType,DocSubType,DocState,DocCurrency,DocAmount,DocBalanaceAmount,ExchangeRate,BaseAmount,BaseBalanaceAmount,StateChangedBy,PostingDate,DocAppliedAmount,BaseAppliedAmount)
				Select @DocumentId,CompanyId,@DocumentId,DocType,DocSubType,DocumentState,DocCurrency,Round(GrandTotal,2) As DocAmount,Round(BalanceAmount,2) As DocBalanceAmount,ExchangeRate,/*Round(GrandTotal*ExchangeRate,2)*/Case When DocumentState=@NotAppliedState Then  @MasterBaseAmount Else 0 End As BaseAmount,Round(BalanceAmount*ExchangeRate,2) As BaseBalanceAmount,Case When ModifiedBy IS null Then UserCreated Else ModifiedBy End,/*DocDate*/Case When DocumentState=@NotAppliedState Then  DocDate Else null End,/*Round(GrandTotal,2)*/Case When DocumentState=@NotAppliedState Then  Round(GrandTotal,2) Else 0 End As DocAppliedAmount,Case When DocumentState=@NotAppliedState Then  @MasterBaseAmount Else 0 End As BaseAppliedAmount From Bean.Invoice(nolock) Where Id=@DocumentId
				
				Exec [dbo].[Bean_DocumentHistory] @BCDocumentHistoryType
			 
				If(@OldEntityId <> @EntityId)
				Begin
					Select @CustEntId=Cast(CONCAT(@OldEntityId,+','+Cast(@EntityId as nvarchar(200))) as nvarchar(200))

					Exec [dbo].[Bean_Update_CustBalance_and_CreditLimit] @CompanyId, @CustEntId
					--Exec [dbo].[Bean_Update_CustBalance] @CompanyId, @OldEntityId
				End
				Else
				Begin
					--Select @CustEntId= Cast(@OldEntityId as nvarchar(MAX))
					Exec [dbo].[Bean_Update_CustBalance_and_CreditLimit] @CompanyId,@EntityId
				End
			End
			Else If(@Type=@CreditMemoDocument)
			Begin
				Set @DocumentId=@SourceId
				If Not Exists(select Id from Bean.CreditMemo(nolock) where CompanyId=@CompanyId and Id=@DocumentId and DocType=@Type)
				Begin
					RAISERROR(@InvalidDocumentError,16,1);
				End
			
			---For Interco posting -- Get Service CompanyId by entityid
				Set @Nature=(select Nature from Bean.CreditMemo(nolock) where Id=@SourceId)
				If(@Nature=@NatureInterco)
				Begin
					--For Customer Balance updation we are getting EntityID 
					Set @EntityId=(Select EntityId From Bean.CreditMemo(nolock) Where Id=@SourceId)
					Set @ServiceEntityId=(Select ServiceEntityId from Bean.Entity(nolock) where id=@EntityId and CompanyId=@CompanyId)
					Set @DocumentId =@SourceId
					Set @ServiceEntityShortName= (select ShortName from Common.Company(nolock) where Id=@ServiceEntityId)
				End
				Else
				Begin
					Set @EntityId = (Select EntityId From Bean.Invoice(nolock) Where DocumentId=@SourceId)
				End

				If Exists(select Id from Bean.Journal(nolock) where CompanyId=@CompanyId and DocumentId=@DocumentId)
				Begin
					Delete from Bean.JournalDetail where DocumentId=@DocumentId and DocType=@Type
					Delete from Bean.Journal where DocumentId=@DocumentId and CompanyId=@CompanyId and DocType=@Type
				End
						
				-- Inserting Records Into Journal From Credit Memo 
				Set @JournalId = NEWID()
				Insert Into Bean.Journal (Id,CompanyId,DocDate,DocType,DocSubType,DocNo,ServiceCompanyId,SystemReferenceNo,IsNoSupportingDocs,NoSupportingDocument,DocCurrency,ExchangeRate,ExCurrency,GSTExchangeRate,GSTExCurrency,GSTTotalAmount,DocumentState,IsNoSupportingDocument,IsGstSettings,IsMultiCurrency,IsAllowableNonAllowable,Remarks,UserCreated,CreatedDate,ModifiedBy,ModifiedDate,Status,DocumentDescription,CreationType,GrandDocCreditTotal,GrandBaseCreditTotal,DueDate,EntityId,EntityType,PoNo,PostingDate,IsGSTApplied,COAId,DocumentId,CreditTermsId,Nature,BalanceAmount,ActualSysRefNo,RefNo,IsSegmentReporting)
				Select @JournalId,CompanyId,DocDate,@Type,DocSubType,DocNo,ServiceCompanyId,DocNo As SystemRefNo, IsNoSupportingDocument, NoSupportingDocs, DocCurrency,ExchangeRate,ExCurrency, GSTExchangeRate,GSTExCurrency,Isnull(GSTTotalAmount,0),DocumentState,IsNoSupportingDocument,IsGstSettings,IsMultiCurrency,IsAllowableNonAllowable,Remarks,UserCreated,CreatedDate,ModifiedBy,ModifiedDate,Status,DocDescription,@CreationTypeSystem,Round(GrandTotal,2) As GrandDocCreditTotal,Round((GrandTotal*Isnull(ExchangeRate,1)),2) As GrandBaseCreditTotal,DueDate,EntityId,EntityType,PONo,PostingDate As PostingDate,IsGSTApplied,
				 Case 
				 when Nature=@NatureTrade Then (Select Id From Bean.ChartOfAccount(nolock) Where CompanyId=@CompanyId And Name=@COATradePayables)
				 when Nature=@NatureOthers Then (Select Id From Bean.ChartOfAccount(nolock) Where CompanyId=@CompanyId And Name=@COAOtherPayables)
				 When Nature=@NatureInterco Then (Select Id From Bean.ChartOfAccount(nolock) Where CompanyId=@CompanyId and SubsidaryCompanyId=@ServiceEntityId and Name=Concat('I/B - ',@ServiceEntityShortName)) End As COAId,
				Id As Documentid,CreditTermsId,Nature,BalanceAmount,DocNo As ActualSysRefNo,Null,ISNULL(IsSegmentReporting,0)
				From Bean.CreditMemo(nolock) Where Id=@DocumentId

				-- Inserting Records Into JournalDetail From CreditMemoDetail
					Insert Into @Temp
					Select Id From Bean.CreditMemoDetail(nolock) Where CreditMemoId=@DocumentId Order By RecOrder
					Select @RecCount=Count(*) From @Temp
					Set @Count=1

				While @RecCount>=@Count
				Begin
					Set @DetailId=(Select DetailId From @Temp Where S_No=@Count)
						--Set @RecOrder=1
					Insert Into Bean.JournalDetail (Id,JournalId,COAId,AccountDescription,TaxId,TaxRate,DocDebit,DocCredit,DocTaxCredit,DocTaxDebit,BaseDebit,BaseCredit,DocDebitTotal,DocCreditTotal,BaseDebitTotal,BaseCreditTotal,DocTaxAmount,BaseTaxAmount,BaseTaxDebit,BaseTaxCredit,GSTCredit,GSTTaxCredit,GSTDebit,GSTTaxDebit,DocumentId,DocumentDetailId,BaseCurrency,ExchangeRate,GSTExCurrency,GSTExchangeRate,DocType,DocSubType,ServiceCompanyId,DocNo,Nature,OffsetDocument,IsTax,EntityId,SystemRefNo,Remarks,PONo,CreditTermsId,DocCurrency,DocDate,DocDescription,PostingDate,RecOrder)

					Select NEWID(),@JournalId,MemoD.COAId As COAId,MemoD.Description As AccountDescription, MemoD.TaxId,MemoD.TaxRate,
					 Case When MemoD.DocAmount < 0 Then ABS(MemoD.DocAmount) Else null End As DocDebit,
					 Case When MemoD.DocAmount > 0 Then MemoD.DocAmount Else null End As DocCredit,
					 Case When MemoD.DocTaxAmount > 0 Then MemoD.DocTaxAmount Else null End DocTaxCredit,
					 Case When MemoD.DocTaxAmount < 0 Then ABS(MemoD.DocTaxAmount) Else null End As DocTaxDebit,
					 Case When MemoD.BaseAmount < 0 Then ABS(MemoD.BaseAmount) Else null End As BaseDebit,
					 Case When MemoD.BaseAmount > 0 Then MemoD.BaseAmount Else null End as BaseCredit,
					 Case When MemoD.DocTotalAmount < 0 Then ABS(MemoD.DocTotalAmount) Else 0 End as DocDebitTotal,
					 Case When MemoD.DocTotalAmount > 0 Then MemoD.DocTotalAmount Else 0 End as DocCreditTotal,
					 Case When MemoD.BaseTotalAmount < 0 Then ABS(MemoD.BaseTotalAmount) Else null End as BaseDebitTotal,
					 Case When MemoD.BaseTotalAmount > 0 Then MemoD.BaseTotalAmount Else null End as BaseCreditTotal,
					 ABS(MemoD.DocTaxAmount) As DocTaxAmount,
					 ABS(MemoD.BaseTaxAmount) As BaseTaxAmount,
					 Case When MemoD.BaseTaxAmount < 0 Then ABS(MemoD.BaseTaxAmount) Else null End As BaseTaxDebit,
					 Case When MemoD.BaseTaxAmount > 0 Then MemoD.BaseTaxAmount Else null End As BaseTaxCredit,

					 Case When MemoD.DocTaxAmount > 0 Then ROUND((ISNULL(MemoD.DocTaxAmount,0)*Isnull(Memo.GSTExchangeRate,1)),2)  Else null End GSTCredit,
					  Case When MemoD.DocAmount > 0 Then ROUND((ISNULL(MemoD.DocAmount,0)*Isnull(Memo.GSTExchangeRate,1)),2)  Else null End GSTTaxCredit,
					  Case When MemoD.DocTaxAmount < 0 Then ABS(ROUND((ISNULL(MemoD.DocTaxAmount,0)*Isnull(Memo.GSTExchangeRate,1)),2))  Else null End GSTDebit,
					  Case When MemoD.DocAmount < 0 Then ABS(ROUND((ISNULL(MemoD.DocAmount,0)*Isnull(Memo.GSTExchangeRate,1)),2))  Else null End GSTTaxDebit,

					@DocumentId,MemoD.Id,Memo.ExCurrency,Memo.ExchangeRate,	Memo.GSTExCurrency, Memo.GSTExchangeRate, @Type,Memo.DocSubType,Memo.ServiceCompanyId,Memo.DocNo,Memo.Nature,Null AsOffsetDocument,0AsIsTax,Memo.EntityId,Memo.DocNo As SystemRefNo,Memo.Remarks,Memo.PONo,0 As CreditTermsId,Memo.DocCurrency,Memo.DocDate,
					null As DocDescription,Memo.PostingDate As PostingDate,MemoD.RecOrder As RecOrder
					From Bean.CreditMemoDetail As MemoD(nolock)
					Inner Join Bean.CreditMemo As Memo On Memo.Id=MemoD.CreditMemoId
					Where MemoD.Id=@DetailId
					-- Inserting Tax Lineitem into journaldetail
					If Exists (Select B.Id From Bean.CreditMemo(nolock) As A Inner Join Bean.CreditMemoDetail As B On A.Id=B.CreditMemoId Where A.IsGstSettings=1 And B.TaxRate is not null 
						And Convert(nvarchar(20),B.TaxIdCode)<>@NA And B.Id=@DetailId)
						Begin
							Set @TaxRecCount=@RecCount+@TaxRecOrder
							Insert Into Bean.JournalDetail (Id,JournalId,COAId,AccountDescription,AllowDisAllow,TaxId,TaxRate,DocDebit,DocCredit,DocTaxDebit,DocTaxCredit,BaseDebit,BaseCredit,DocDebitTotal,DocCreditTotal,BaseDebitTotal,BaseCreditTotal,DocumentId,DocumentDetailId,ItemId,BaseCurrency,ExchangeRate,GSTExCurrency,GSTExchangeRate,DocType,DocSubType,ServiceCompanyId,DocNo,Nature,OffsetDocument,IsTax,EntityId,SystemRefNo,Remarks,PONo,CreditTermsId,NoSupportingDocs,BaseAmount,DocCurrency,DocDate,DocDescription,PostingDate,RecOrder,DocTaxAmount,BaseTaxAmount)
							Select NEWID(),@JournalId,(Select Id From Bean.ChartOfAccount(nolock) Where CompanyId=@CompanyId And Name=@COATaxPaybleGST) As COAId,Inv.DocDescription As AccountDescription,InvID.AllowDisAllow,InvID.TaxId,InvID.TaxRate,
							Case When InvID.DocTaxAmount < 0 Then ABS(InvID.DocTaxAmount) Else null End As DocDebit,
							Case When InvID.DocTaxAmount > 0 Then InvID.DocTaxAmount Else null End As DocCredit,
							'0.00' As DocTaxDebit,
							'0.00' As DocTaxCredit,
							 Case When InvID.BaseTaxAmount < 0 Then ABS(InvID.BaseTaxAmount) Else null End As BaseDebit, 
							 Case When InvID.BaseTaxAmount > 0 Then InvID.BaseTaxAmount Else null End As BaseCredit,
							'0.00' As DocDebitTotal,'0.00' As DocCreditTotal,null As BaseDebitTotal,null As BaseCreditTotal,@DocumentId,InvID.Id,@GUIDZero,Inv.ExCurrency,Inv.ExchangeRate,Inv.GSTExCurrency,Inv.GSTExchangeRate,@Type,Inv.DocSubType,Inv.ServiceCompanyId,Inv.DocNo,Inv.Nature,Null As OffsetDocument,1 As IsTax,Inv.EntityId,Inv.DocNo As SystemRefNo,Inv.Remarks,Inv.PONo,Null As CreditTermsId,
							 Inv.NoSupportingDocs,null As BaseAmount,Inv.DocCurrency,Inv.DocDate,null As DocDescription,
							Inv.PostingDate,@TaxRecCount As RecOrder,InvID.DocTaxAmount,InvID.BaseTaxAmount
							From Bean.CreditMemoDetail As InvID(nolock)
							Inner Join Bean.CreditMemo As Inv(nolock) On Inv.Id=InvID.CreditMemoId
							Where InvID.Id=@DetailId
							Set @TaxRecOrder=@TaxRecOrder+1
						End
							Set @Count=@Count+1
					End

					Select @ExchangeRate=ExchangeRate from Bean.CreditMemo(nolock) where CompanyId=@CompanyId and Id=@DocumentId
					Select @MasterBaseAmount=Cast(ABS(Sum(ROUND(DocAmount*ISNULL(@ExchangeRate,1),2)+(Round(Isnull(DocTaxAmount,0)*ISNULL(@ExchangeRate,1),2))))as money) from Bean.CreditMemoDetail where CreditMemoId=@DocumentId

					-- Inserting Master Records Into JournalDetail From Invoce 
					Insert Into Bean.JournalDetail (Id,JournalId,COAId,AccountDescription,DocDebit,BaseDebit,DocDebitTotal,BaseDebitTotal,DocumentId,DocumentDetailId,ItemId,DueDate,ExchangeRate,GSTExchangeRate,GSTExCurrency,Nature,DocType,DocSubType,ServiceCompanyId,CreditTermsId, DocNo, PostingDate, RecOrder, DocumentAmount, Currency,BaseCurrency,IsTax,EntityId,SystemRefNo,Remarks,PONo,BaseAmount, DocCurrency,DocDate,DocDescription,DocCreditTotal,BaseCreditTotal)
					Select NewId(),@JournalId,
					Case 
					when Nature=@NatureTrade Then (Select Id From Bean.ChartOfAccount(nolock) Where CompanyId=@CompanyId And Name=@COATradePayables)
					when Nature=@NatureOthers Then (Select Id From Bean.ChartOfAccount(nolock) Where CompanyId=@CompanyId And Name=@COAOtherPayables) 
					When Nature=@NatureInterco Then (Select Id From Bean.ChartOfAccount(nolock) Where CompanyId=@CompanyId and SubsidaryCompanyId=@ServiceEntityId and Name=Concat('I/B - ',@ServiceEntityShortName)) End As COAId,
					DocDescription,Round(GrandTotal,2),/*Round((GrandTotal*Isnull(ExchangeRate,1)),2)*/@MasterBaseAmount,Round(GrandTotal,2),/*Round((GrandTotal*Isnull(ExchangeRate,1)),2)*/@MasterBaseAmount As BaseCreditTotal,@DocumentId,@GUIDZero,@GUIDZero,DueDate,ExchangeRate,GSTExchangeRate,GSTExCurrency,Nature,@Type,DocSubType,ServiceCompanyId,CreditTermsId, DocNo, PostingDate,(Select Max(Recorder)+1 From Bean.JournalDetail(nolock) Where DocumentId=@DocumentId),Round(GrandTotal,2),
					DocCurrency,ExCurrency,0,EntityId,DocNo,Remarks,PONo,/*Round(GrandTotal*Isnull(ExchangeRate,1),2)*/@MasterBaseAmount,DocCurrency,DocDate,DocDescription,'0.00' as DocCreditTotal,'0.00' as BaseCreditTotal
					From Bean.CreditMemo(nolock) Where Id=@DocumentId

				--0.01 BaseGrandTotal and BaseBalanceAmount updation for Credit Memo 
				--IF @MasterBaseAmount!=0 AND @MasterBaseAmount IS NOT NULL
				--Begin
				--	Update Bean.CreditMemo set BaseGrandTotal=@MasterBaseAmount,BaseBalanceAmount=@MasterBaseAmount where Id=@DocumentId and CompanyId=@CompanyId
				--END

					If((select ABS(SUM(BaseDebit)-SUM(BaseCredit)) from Bean.JournalDetail(nolock) where DocumentId=@DocumentId group by DocType)>=0.01)
					Begin
						Select @BaseDebit=SUM(BaseDebit),@BaseCredit=SUM(BaseCredit),@DiffAmount=ABS(SUM(BaseDebit)-SUM(BaseCredit)) from Bean.JournalDetail where DocumentId=@DocumentId
						Insert Into Bean.JournalDetail (Id,JournalId,COAId,AccountDescription,BaseDebit,BaseCredit,DocumentId,DocumentDetailId,ItemId,DocDate,DueDate,PostingDate,ExchangeRate,GSTExchangeRate,GSTExCurrency,Nature,DocType,DocSubType,ServiceCompanyId, CreditTermsId, DocNo, Currency, BaseCurrency, IsTax, EntityId, SystemRefNo,  DocCurrency, RecOrder,DocDebitTotal,DocCreditTotal)
						select NEWID(), @JournalId, (Select Id from Bean.ChartOfAccount(nolock) where CompanyId=@CompanyId and Name=@Rounding), DocDescription, Case When @BaseDebit>@BaseCredit Then null Else @DiffAmount End as BaseDebit, Case When @BaseCredit>@BaseDebit Then null Else @DiffAmount END as BaseCredit, @DocumentId,NEWID(),@GUIDZero,DocDate,DueDate,PostingDate,ExchangeRate,GSTExchangeRate,GSTExCurrency,Nature,DocType,DocSubType,ServiceCompanyId,CreditTermsId,DocNo, DocCurrency, ExCurrency, 0, EntityId,DocNo, DocCurrency, (Select Max(Recorder)+1 From Bean.JournalDetail(nolock) Where DocumentId=@DocumentId),0,0
						from Bean.CreditMemo(nolock) where CompanyId=@CompanyId and Id=@DocumentId
					End


					-- Inserting Records into DocumentHistory Table
					Insert Into @BCDocumentHistoryType(TransactionId,CompanyId,DocumentId,DocType,DocSubType,DocState,DocCurrency,DocAmount,DocBalanaceAmount,ExchangeRate,BaseAmount,BaseBalanaceAmount,StateChangedBy,PostingDate,DocAppliedAmount,BaseAppliedAmount)
					Select @DocumentId,CompanyId,@DocumentId,DocType,DocSubType,DocumentState,DocCurrency,Round(GrandTotal,2) As DocAmount,Round(BalanceAmount,2) As DocBalanceAmount,ExchangeRate,/*Round(GrandTotal*ExchangeRate,2)*/Case When DocumentState=@NotAppliedState Then  @MasterBaseAmount Else 0 End As BaseAmount,Round(BalanceAmount*ExchangeRate,2) As BaseBalanceAmount,Case When ModifiedBy IS null Then UserCreated Else ModifiedBy End,/*DocDate*/Case When DocumentState=@NotAppliedState Then  PostingDate Else null End,/*Round(GrandTotal,2)*/Case When DocumentState=@NotAppliedState Then  Round(GrandTotal,2) Else 0 End As DocAppliedAmount,Case When DocumentState=@NotAppliedState Then  @MasterBaseAmount Else 0 End As BaseAppliedAmount From Bean.CreditMemo(nolock) Where Id=@DocumentId
					Exec [dbo].[Bean_DocumentHistory] @BCDocumentHistoryType
					 
			End
			Else If(@Type=@DebtProvisionDocument)
			Begin
				Set @DocumentId=@SourceId
				If Not Exists(select Id from Bean.Invoice(nolock) where CompanyId=@CompanyId and Id=@DocumentId and DocType=@Type)
				Begin
					RAISERROR(@InvalidDocumentError,16,1);
				End
			
			  -- Get Service CompanyId by entityid
				Set @Nature=(select Nature from Bean.Invoice(nolock) where Id=@SourceId)
				 
				Set @EntityId = (Select EntityId From Bean.Invoice(nolock) Where Id=@SourceId)
				

				If Exists(select Id from Bean.Journal(nolock) where CompanyId=@CompanyId and DocumentId=@DocumentId)
				Begin
					Delete from Bean.JournalDetail with (ROWLOCK) where DocumentId=@DocumentId and DocType=@Type
					Delete from Bean.Journal with (ROWLOCK) where DocumentId=@DocumentId and CompanyId=@CompanyId and DocType=@Type
				End
						
				-- Inserting Records Into Journal From Debit Provision 
				Set @JournalId = NEWID()
				Insert Into Bean.Journal (Id,CompanyId,DocDate,DocType,DocSubType,DocNo,ServiceCompanyId,SystemReferenceNo,IsNoSupportingDocs,NoSupportingDocument,DocCurrency,ExchangeRate,ExCurrency,GSTExchangeRate,GSTExCurrency,GSTTotalAmount,DocumentState,IsNoSupportingDocument,IsGstSettings,IsMultiCurrency,IsAllowableNonAllowable,Remarks,UserCreated,CreatedDate,ModifiedBy,ModifiedDate,Status,DocumentDescription,CreationType,GrandDocCreditTotal,GrandBaseCreditTotal,DueDate,EntityId,EntityType,PoNo,PostingDate,IsGSTApplied,COAId,DocumentId,CreditTermsId,Nature,BalanceAmount,ActualSysRefNo,RefNo,IsSegmentReporting)
				Select @JournalId,CompanyId,DocDate,@Type,DocSubType,DocNo,ServiceCompanyId,DocNo As SystemRefNo, IsNoSupportingDocument, NoSupportingDocs, DocCurrency,ExchangeRate,ExCurrency, GSTExchangeRate,GSTExCurrency,Isnull(GSTTotalAmount,0),DocumentState,IsNoSupportingDocument,IsGstSettings,IsMultiCurrency,IsAllowableNonAllowable,Remarks,UserCreated,CreatedDate,ModifiedBy,ModifiedDate,Status,DocDescription,@CreationTypeSystem,Round(GrandTotal,2) As GrandDocCreditTotal,Round((GrandTotal*Isnull(ExchangeRate,1)),2) As GrandBaseCreditTotal,DueDate,EntityId,EntityType,PONo,DocDate As PostingDate,IsGSTApplied,
				 Case 
				 when Nature=@NatureTrade Then (Select Id From Bean.ChartOfAccount(nolock) Where CompanyId=@CompanyId And Name=@COATradeReceivables)
				 when Nature=@NatureOthers Then (Select Id From Bean.ChartOfAccount(nolock) Where CompanyId=@CompanyId And Name=@COAotherReceivables)
				   End As COAId,
				Id As Documentid,CreditTermsId,Nature,BalanceAmount,DocNo As ActualSysRefNo,Null,ISNULL(IsSegmentReporting,0)
				From Bean.Invoice(nolock) Where Id=@DocumentId

				-- Inserting Records Into JournalDetail From CreditMemoDetail
					
				Set @Count=1
				Set @RecCount=2
				While @RecCount>=@Count
				Begin
				If @Count=1
				Begin
				Set @NewCoaId=(Select Id from Bean.ChartOfAccount(nolock) where CompanyId=@CompanyId and Name=@COADoubtfulDebtexpense)
				End
				Else
				Begin
				Set @NewCoaId=(Select Id from Bean.ChartOfAccount(nolock) where CompanyId=@CompanyId and Name=Case When @Nature=@NatureTrade Then @COADebt_Provision_AR Else @COADebt_Provision_OR End)
				End
					 
					Insert Into Bean.JournalDetail (Id,JournalId,COAId,AccountDescription,DocDebit,DocCredit,DocTaxCredit,DocTaxDebit,BaseDebit,BaseCredit,DocDebitTotal,DocCreditTotal,BaseDebitTotal,BaseCreditTotal,BaseTaxDebit,BaseTaxCredit,DocumentId,BaseCurrency,ExchangeRate,GSTExCurrency,GSTExchangeRate,DocType,DocSubType,ServiceCompanyId,DocNo,Nature,OffsetDocument,IsTax,EntityId,SystemRefNo,Remarks,PONo,CreditTermsId,DocCurrency,DocDate,DocDescription,PostingDate,RecOrder,DocumentDetailId)

					Select NEWID(),@JournalId,@NewCoaId  As COAId,DebtProv.DocDescription As AccountDescription,
					 Case When @Count=1 Then ROUND(DebtProv.GrandTotal,2) Else null End As DocDebit,
					 Case When @Count=2 Then ROUND(DebtProv.GrandTotal,2) Else null End As DocCredit,
					 '0.00' as DocTaxCredit,
					 '0.00' as DocTaxDebit,
					 Case When @Count=1 Then Round((GrandTotal*Isnull(ExchangeRate,1)),2) Else null End As BaseDebit,
					 Case When @Count=2 Then Round((GrandTotal*Isnull(ExchangeRate,1)),2) Else null End as BaseCredit,
					 '0.00' as DocDebitTotal,
					 '0.00' as DocCreditTotal,
					 '0.00' as BaseDebitTotal,
					 '0.00' as BaseCreditTotal,
					 '0.00' As BaseTaxDebit,
					 '0.00' As BaseTaxCredit,
					@DocumentId,DebtProv.ExCurrency,DebtProv.ExchangeRate,	DebtProv.GSTExCurrency, DebtProv.GSTExchangeRate, @Type,DebtProv.DocSubType,DebtProv.ServiceCompanyId,DebtProv.DocNo,DebtProv.Nature,Null AsOffsetDocument,0AsIsTax,DebtProv.EntityId,DebtProv.DocNo As SystemRefNo,DebtProv.Remarks,DebtProv.PONo,0 As CreditTermsId,DebtProv.DocCurrency,DebtProv.DocDate,
					null As DocDescription,DebtProv.DocDate As PostingDate,@Count As RecOrder,@GUIDZero
					From Bean.Invoice As DebtProv(nolock)
					 
					Where DebtProv.Id=@DocumentId and DebtProv.CompanyId=@CompanyId
					
						 
						Set @Count=@Count+1
					End

					If((select ABS(SUM(BaseDebit)-SUM(BaseCredit)) from Bean.JournalDetail(nolock) where DocumentId=@DocumentId group by DocType)>=0.01)
					Begin
						Select @BaseDebit=SUM(BaseDebit),@BaseCredit=SUM(BaseCredit),@DiffAmount=ABS(SUM(BaseDebit)-SUM(BaseCredit)) from Bean.JournalDetail(nolock) where DocumentId=@DocumentId
						Insert Into Bean.JournalDetail (Id,JournalId,COAId,AccountDescription,BaseDebit,BaseCredit,DocumentId,DocumentDetailId,ItemId,DocDate,DueDate,PostingDate,ExchangeRate,GSTExchangeRate,GSTExCurrency,Nature,DocType,DocSubType,ServiceCompanyId, CreditTermsId, DocNo, Currency, BaseCurrency, IsTax, EntityId, SystemRefNo,  DocCurrency, RecOrder,DocDebitTotal,DocCreditTotal)
						select NEWID(), @JournalId, (Select Id from Bean.ChartOfAccount(nolock) where CompanyId=@CompanyId and Name=@Rounding), DocDescription, Case When @BaseDebit>@BaseCredit Then null Else @DiffAmount End as BaseDebit, Case When @BaseCredit>@BaseDebit Then null Else @DiffAmount END as BaseCredit, @DocumentId,NEWID(),@GUIDZero,DocDate,DueDate,DocDate,ExchangeRate,GSTExchangeRate,GSTExCurrency,Nature,DocType,DocSubType,ServiceCompanyId,CreditTermsId,DocNo, DocCurrency, ExCurrency, 0, EntityId,DocNo, DocCurrency, (Select Max(Recorder)+1 From Bean.JournalDetail(nolock) Where DocumentId=@DocumentId),0,0
						from Bean.Invoice(nolock) where CompanyId=@CompanyId and Id=@DocumentId
					End

					

					-- Inserting Records into DocumentHistory Table
					Insert Into @BCDocumentHistoryType(TransactionId,CompanyId,DocumentId,DocType,DocSubType,DocState,DocCurrency,DocAmount,DocBalanaceAmount,ExchangeRate,BaseAmount,BaseBalanaceAmount,StateChangedBy,PostingDate,DocAppliedAmount,BaseAppliedAmount)
					Select @DocumentId,CompanyId,@DocumentId,DocType,DocSubType,DocumentState,DocCurrency,Round(GrandTotal,2) As DocAmount,Round(BalanceAmount,2) As DocBalanceAmount,ExchangeRate,/*Round(GrandTotal*ExchangeRate,2)*/Case When DocumentState=@NotAllocatedState Then  Round(GrandTotal*ExchangeRate,2) Else 0 End As BaseAmount,Round(BalanceAmount*ExchangeRate,2) As BaseBalanceAmount,Case When ModifiedBy IS null Then UserCreated Else ModifiedBy End,/*DocDate*/Case When DocumentState=@NotAllocatedState Then  DocDate Else null End,/*Round(GrandTotal,2)*/Case When DocumentState=@NotAllocatedState Then  Round(GrandTotal,2) Else 0 End As DocAppliedAmount,Case When DocumentState=@NotAllocatedState Then  Round(GrandTotal*ExchangeRate,2) Else 0 End As BaseAppliedAmount From Bean.Invoice(nolock) Where Id=@DocumentId
					Exec [dbo].[Bean_DocumentHistory] @BCDocumentHistoryType
					
					If(@OldEntityId <> @EntityId)
				Begin
					Select @CustEntId=Cast(CONCAT(@OldEntityId,+','+Cast(@EntityId as nvarchar(200))) as nvarchar(200))

					Exec [dbo].[Bean_Update_CustBalance_and_CreditLimit] @CompanyId, @CustEntId
					--Exec [dbo].[Bean_Update_CustBalance] @CompanyId, @OldEntityId
				End
				Else
				Begin
					--Select @CustEntId= Cast(@OldEntityId as nvarchar(MAX))
					Exec [dbo].[Bean_Update_CustBalance_and_CreditLimit] @CompanyId,@EntityId
				End 
			End
			Commit Transaction
		End Try
		Begin Catch
			Rollback;
			Select @ErrorMessage=ERROR_MESSAGE()
			RAISERROR(@ErrorMessage,16,1);
		End Catch
End
GO
