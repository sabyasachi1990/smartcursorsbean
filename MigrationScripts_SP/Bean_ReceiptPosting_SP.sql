USE SmartCursorSTG
GO

IF EXISTS (Select 1 from sys.objects where OBJECT_ID=OBJECT_ID( '[Bean_RecieptPosting_Sp]')AND type='P')
BEGIN
 Drop Proc Bean_RecieptPosting_Sp
END
GO


CREATE Procedure [dbo].[Bean_RecieptPosting_Sp]
@SourceId Uniqueidentifier,
@Type Nvarchar(20),	
@CompanyId BigInt,
@RoundingAmount nvarchar(4000)
As
Begin
	-- Documnet Type 
	Declare @InvoiceDocument varchar(20) ='Invoice'
	Declare @DebitNoteDocument varchar(20) ='Debit Note'
	Declare @CreditNoteDocument varchar(20) ='Credit Note'
	Declare @CreditMemoDocument nvarchar(20)='Credit Memo'
	Declare @BillDocument varchar(20) ='Bill'
	Declare @Pay_Dr Nvarchar(25)='Pay(Dr)'
	Declare @Receive_Cr Nvarchar(25)='Receive(Cr)'
	-- Nature
	Declare @NatureTrade varchar(20) = 'Trade'
	Declare @NatureOthers varchar(20) = 'Others'

	Declare @COATradeReceivables varchar(50) = 'Trade receivables'
	Declare @COAotherReceivables varchar(50) = 'Other receivables'
	Declare @COATradePayables varchar(50) = 'Trade payables'
	Declare @COAOtherPayables varchar(50) = 'Other payables'
	Declare @COA_BankCharges varchar(50)='Bank charges'
	Declare @ExchangeGainOrLossRealised Nvarchar(50)='Exchange gain/loss - Realised'
	Declare @ClearingReceipts Nvarchar(250)='Clearing - Receipts'
	Declare @Rounding Nvarchar(25)='Rounding'
	Declare @TaxPayableGSTAccount VARCHAR(30)='Tax payable (GST)'
	Declare @IntercompClearingCOAName Nvarchar(250)='Intercompany Clearing'

	Declare @GUIDZero Uniqueidentifier ='00000000-0000-0000-0000-000000000000'
	Declare @UserCreated Nvarchar(20) ='System'
	Declare @CreatedDate Datetime2=GETUTCDATE()
	Declare @DefaultExchangeRate Decimal(15,10)=1.00000000
	Declare @NA Char(2)='NA'
	Declare @BaseCurrency Varchar(25)
	Declare @DocCurrency Varchar(25)
	Declare @BankChargesCurrency Varchar(25)
	Declare @FullyApplied Nvarchar(50)='Fully Applied'
	Declare @Fullypaid Nvarchar(50)='Fully Paid'
	Declare @DocType Varchar(25)
	Declare @DocSubType Varchar(25)
	Declare @RecieptDtlId Uniqueidentifier
	Declare @JournalId Uniqueidentifier
	Declare @IntMastSysRefNo Nvarchar(250)
	Declare @IntMastJournalId Uniqueidentifier
	Declare @MasterJournalId Uniqueidentifier
	Declare @ErrorMessage Nvarchar(4000)
	Declare	@Count Int
	Declare	@DtlCount Int
	Declare @BankCharges_COAId Bigint
	Declare @TaxPayableGST_COAID Bigint
	Declare @RecCount Int
	Declare @IsRoundingAmount Int
	Declare @TaxRate Float
	Declare @DocumentId Uniqueidentifier
	Declare @TaxRecCount Int
	Declare @DefaultTaxCode Char(2)
	Declare @TaxId Int
	Declare @TaxType Varchar(50)
	Declare @RecOrder int
	Declare @ExcesPaidByClient Nvarchar(250)
	Declare @ExcesPaidByClientAmt Money
	Declare @ClearingReceiptsCOAID Bigint
	Declare @RecieptBalId Uniqueidentifier
	Declare @GST Int 
	Declare @COAID BigInt
	Declare @ExchangeRate Decimal(15,10)
	Declare @MainExchangeRate Decimal(15,10)
	Declare @RoundingAmt Money
	Declare @RoundingCOAID BigInt
	Declare @DocAmount Money
	Declare @ServCompCount Int
	Declare @ServCompCount2 Int
	Declare @ServCompaIdTblCnt Int
	Declare @ServCompId Int
	Declare @SystemRefNo Nvarchar(250)
	Declare @MasterSystemRefNo Nvarchar(250)
	Declare @DocNo Nvarchar(250)
	Declare @IntroCompCOAID BigInt
	Declare @MainInterCoServCompCOAID BigInt
	Declare @MasterServComp BigInt
	Declare @RdtlRecCount int
	Declare @ReceiptOffSet Int
	Declare @OffSetDocumentType Nvarchar(50)
	Declare @ClearingRecieptInvOrDNAmount Money
	Declare @ClearingRecieptBillAmount Money
	Declare @ClearingRecieptAmount Money
	Declare @CreditNoteAmount Money
	Declare @CreditMemoAmount Money
	Declare @SysCalExchangerate Decimal(15,10)
	Declare  @RecOrderAnotherJV Int
	Declare @CreditNoteJournalId Uniqueidentifier
	Declare @DtlRecOrder Int
	Declare @SysRefNum_Incr Int
	Declare @ExchangeGainOrLossCOAID Int

	Declare @CustEntityId Nvarchar(550)
	Declare @OldEntityId Uniqueidentifier
	Declare @NewEntityId Uniqueidentifier
	Declare @OldCOAId BigInt
	Declare @NewCOAId BigInt
	Declare @OldServEntityId Bigint
	Declare @NewServEntityId BigInt
	Declare @OldDocAmount Money
	Declare @NewDocAmount Money
	Declare @OldDocdate DateTime2(7)
	Declare @NewDocDate DateTime2(7)
	Declare @IsAdd Int 
	   
	Declare @RecieptDtl Table (S_No Int identity(1,1),RecieptDtlId Uniqueidentifier)
	Declare @RecieptDtl_New Table (S_No Int,RecieptDtlId Uniqueidentifier)
	Declare @InterCoRecieptDtl Table (S_No Int identity(1,1),RecieptDtlId Uniqueidentifier,ServCompId BigInt)
	Declare @ServCompaIdTbl Table (S_No Int Identity(1,1),SerCompId BigInt)
	Declare @RecieptBalLnItm Table (S_no Int Identity(1,1),RecieptBalId Uniqueidentifier)
	Declare @RoundingAmountDetails Table (DocumentId Uniqueidentifier,Amount Money)
	Declare @Rounding_Tbl Table (S_No int Identity(1,1),JournalId Uniqueidentifier)

	Begin Transaction
	Begin Try
		-- Deleting Existing Jv
		IF Exists (Select Id From bean.Journal(Nolock) Where DocumentId=@SourceId And DocType=@Type)
		Begin
			Set @OldEntityId=(Select Distinct EntityId From Bean.Journal(Nolock) Where DocumentId=@SourceId And DocType=@Type And EntityId Is Not Null)
			Set @NewEntityId=(Select EntityId From Bean.Receipt(Nolock) Where Id=@SourceId)
			Set @CustEntityId=Concat(Cast(@OldEntityId as nvarchar(200)),',',Cast(@NewEntityId As Nvarchar(200)))
			
			Select @OldCOAId=COAId,@OldServEntityId=ServiceCompanyId,@OldDocAmount=Case When DocDebit IS null Then DocCredit Else DocDebit End,@OldDocdate=PostingDate
			From Bean.JournalDetail(Nolock) As JD  
			Inner Join Bean.ChartOfAccount(Nolock) As COA On COA.Id=JD.COAId
			Where JD.DocumentId=@SourceId and JD.DocumentDetailId='00000000-0000-0000-0000-000000000000' And COA.IsBank=1

			Select @NewCoaId=COAId,@NewServEntityId=ServiceCompanyId,@NewDocAmount=GrandTotal,@NewDocDate=DocDate 
			From Bean.Receipt(Nolock) where CompanyId=@CompanyId and Id=@SourceId
			Set @IsAdd=1

			Delete From Bean.JournalDetail Where JournalId In (Select Id From bean.Journal(Nolock) Where DocumentId=@SourceId And DocType=@Type)
			Delete From Bean.Journal Where DocumentId=@SourceId And DocType=@Type

		End
		Else
		Begin
			Select @NewCoaId=COAId,@NewServEntityId=ServiceCompanyId,@NewDocAmount=GrandTotal,@NewDocDate=DocDate 
			From Bean.Receipt(Nolock) where CompanyId=@CompanyId and Id=@SourceId

			Set @NewEntityId=(Select EntityId From Bean.Receipt(Nolock) Where Id=@SourceId)
			Set @CustEntityId=@NewEntityId
			Set @IsAdd=0
		End
		/* Receipt */
		IF @Type='Receipt'
		Begin
			Set @DefaultTaxCode ='EP'
			Set @DocType='Receipt'
			Set @DocSubType='General'
			Set @RecOrder=1
			Set @SysRefNum_Incr=1
			Declare @RndAmtcount int=0
			Declare @RndAmtReccount int=0
			Declare @KeyPairValueRecCount int=0
			Declare @Reccountcoma int=0
			Declare @KeyPair Nvarchar(Max)
			Declare @value Nvarchar(Max)
			Declare @KeyPairValue nvarchar(500)
			Declare @RndAmtDocid uniqueidentifier
			Declare @RndAmtAmount Money
			Declare @tempTable Table(id int identity(1,1), stringVal nvarchar(2000))
			--Declare @RoundingTable Table (DetailDocId uniqueidentifier, DiffAmount money)
			IF @RoundingAmount Is Not Null And @RoundingAmount <>'' 
			Begin
				Set @value=Replace(@RoundingAmount,'[','') 
				Set @value=Replace(@value,']','')
				Insert Into @tempTable
				Select items From SplitToTable (@value,':')
				Set @RndAmtcount=(Select Count(*) From @tempTable)
				Set @RndAmtReccount=1
				While @RndAmtcount>=@RndAmtReccount
				Begin
					Set @KeyPairValueRecCount=0
				    Set @KeyPair=(Select cast(stringVal As nvarchar(Max))  From @tempTable WHere Id=@RndAmtReccount)
					Declare KeyValueCSR Cursor  For
				    Select items From SplitToTable(@KeyPair,',')
					Open KeyValueCSR
					Fetch Next from KeyValueCSR into @KeyPairValue
					While @@FETCH_STATUS=0
					Begin
						Set @KeyPairValueRecCount=@KeyPairValueRecCount+1
						IF @KeyPairValueRecCount=1
						Begin
							Set @RndAmtDocid=@KeyPairValue
						End
						Else
						Begin
							Set @RndAmtAmount=Cast(@KeyPairValue As money)
							Insert Into @RoundingAmountDetails
							Select @RndAmtDocid,@RndAmtAmount
						End
						Fetch Next from KeyValueCSR into @KeyPairValue
					End
					Close KeyValueCSR
					Deallocate KeyValueCSR
				    Set @RndAmtReccount=@RndAmtReccount+1
				End
			End
			-- Getting Currency,Amount & Exchange Rate Of Reciept
			Select @BaseCurrency=BaseCurrency,@BankChargesCurrency=BankChargesCurrency,@DocCurrency=DocCurrency,@ExcesPaidByClient=ExcessPaidByClient,
					@ExcesPaidByClientAmt=ExcessPaidByClientAmmount,@GST=IsGstSettings,@MasterServComp=ServiceCompanyId,@SysCalExchangerate=SystemCalculatedExchangeRate,
					@MainExchangeRate=ExchangeRate,@DocNo=DocNo
			From Bean.Receipt(Nolock) Where CompanyId=@CompanyId And Id=@SourceId
			-- Getting I/C For Master Service Company
			Set @MainInterCoServCompCOAID=(Select COA.Id From Bean.ChartOfAccount(Nolock) As COA 
											Inner Join Bean.AccountType(Nolock) As ACT On ACT.Id=COA.AccountTypeId
											Where ACT.CompanyId=@CompanyId And ACT.Name=@IntercompClearingCOAName And COA.SubsidaryCompanyId=@MasterServComp
										   )
			Set @SysCalExchangerate=ISNULL(@SysCalExchangerate,@MainExchangeRate)
			-- Getting Service Company Count To Check Multi Comp Or Not
			Set @ServCompCount=(Select Count(distinct ServiceCompanyId) From Bean.ReceiptDetail(Nolock) Where ReceiptId=@SourceId)
			Set @ServCompCount2=(Select Count(Id) From Bean.ReceiptDetail(Nolock) Where ReceiptId=@SourceId And ServiceCompanyId Not In (Select ServiceCompanyId From Bean.Receipt(Nolock) Where Id=@SourceId) )
			-- To Check Reciept Is OffSet Or Not
			Set @ReceiptOffSet=(Select Count(*) From Bean.ReceiptDetail(Nolock) Where ReceiptId=@SourceId And DocumentType=@CreditNoteDocument)
			Set @ClearingReceiptsCOAID=(Select Id From Bean.ChartOfAccount(Nolock) Where CompanyId=@CompanyId And Name=@ClearingReceipts)
			If Exists (Select Id From Bean.Receipt(Nolock) Where Id=@SourceId And IsGstSettings=1)
			Begin
				Select @TaxId=Id,@TaxType=TaxType,@TaxRate=TaxRate From Bean.TaxCode(Nolock) Where Code=@DefaultTaxCode and CompanyId = @CompanyId
			End
			Set @BankCharges_COAId=(Select Id From Bean.ChartOfAccount(Nolock) Where CompanyId=@CompanyId And Name=@COA_BankCharges)
			SET @TaxPayableGST_COAID = (Select Id from Bean.ChartOfAccount where Name=@TaxPayableGSTAccount and CompanyId=@CompanyId)
			Set @ExchangeGainOrLossCOAID=(Select Id From Bean.ChartOfAccount(Nolock) Where CompanyId=@CompanyId And Name=@ExchangeGainOrLossRealised)
			-- Reciept OFF Set Multi Company Records
			IF ((Select Isnull(IsVendor,0) From Bean.Receipt(Nolock) Where Id=@SourceId)=1 Or @ReceiptOffSet>=1) And( @ServCompCount > 1 Or @ServCompCount2 <> 0)
			Begin
				Set @MasterJournalId=NEWID()
				Set @MasterSystemRefNo=CONCAT(@DocNo,'-JV',@SysRefNum_Incr)
				-- Main Journal
				Insert Into Bean.Journal (Id,CompanyId,DocDate,DocType,DocSubType,DocNo,ServiceCompanyId,SystemReferenceNo,IsNoSupportingDocs,NoSupportingDocument,DocCurrency,ExchangeRate,ExCurrency,ExDurationFrom,GSTExchangeRate,GSTExCurrency,GSTTotalAmount,DocumentState,IsNoSupportingDocument,IsGstSettings,IsMultiCurrency,IsAllowableNonAllowable,IsGSTCurrencyRateChanged,Remarks,UserCreated,CreatedDate,Status,DocumentDescription,CreationType,GrandDocDebitTotal,GrandDocCreditTotal,GrandBaseDebitTotal,
										GrandBaseCreditTotal,EntityId,EntityType,PostingDate,COAId,ModeOfReceipt,BankReceiptAmmount,ExcessPaidByClientAmmount,BalancingItemReciveCRAmount,  BalancingItemPayDRAmount,ReceiptApplicationAmmount,DocumentId, BankClearingDate ,IsBalancing,ISAllowDisAllow, IsShow, ActualSysRefNo 
										,IsSegmentReporting,TransferRefNo
										)
				Select @MasterJournalId,@CompanyId,DocDate,@DocType,@DocSubType,DocNo,ServiceCompanyId,@MasterSystemRefNo As SystemRefNo,IsNoSupportingDocument,NoSupportingDocs,DocCurrency,ExchangeRate,ExCurrency,ExDurationFrom,GSTExchangeRate,GSTExCurrency,Isnull(GSTTotalAmount,0),DocumentState,NoSupportingDocs,IsGstSettings,IsMultiCurrency,IsAllowableDisallowable,IsGSTCurrencyRateChanged,Remarks,@UserCreated,@CreatedDate,Status,Remarks As DocDescription,@UserCreated,GrandTotal,0.00 As GrandDocCreditTotal,GrandTotal * Round(ExchangeRate,2) As GrandBaseDebitTotal,
						0.00 As GrandBaseCreditTotal,EntityId,EntityType,DocDate As PostingDate,COAId,ModeOfReceipt,0.00 As BankReceiptAmmount,0.00 As ExcessPaidByClientAmmount,0.00 As BalancingItemReciveCRAmount,0.00 As BalancingItemPayDRAmount,0.00 As ReceiptApplicationAmmount,@SourceId As DocumentId,BankClearingDate,0 As IsBalancing,IsDisAllow,1 As IsShow,DocNo As ActualSysRefNo,0 As IsSegmentReporting,ReceiptRefNo
				From Bean.Receipt(Nolock) Where CompanyId=@CompanyId And Id=@SourceId

				IF @DocCurrency=@BankChargesCurrency And @BaseCurrency=@DocCurrency
				Begin
					/* Creating Mater record In JournalDetail */
					IF Exists (Select Id From Bean.Receipt(Nolock) Where Id=@SourceId And GrandTotal<>0)
					Begin
						Set @RecOrder=@RecOrder+1
						Insert Into Bean.JournalDetail (Id,JournalId,COAId,AccountDescription,AllowDisAllow, DocDebit, BaseDebit, DocDebitTotal,DocCreditTotal,BaseDebitTotal,BaseCreditTotal,DocumentId,DocumentDetailId,ItemId,BaseCurrency,ExchangeRate,GSTExCurrency,GSTExchangeRate,DocType,DocSubType,ServiceCompanyId,DocNo, IsTax,
										EntityId, SystemRefNo, DocCurrency,DocDate, PostingDate,RecOrder )
						Select NEWID(),@MasterJournalId,COAId,Remarks,IsDisAllow,Isnull(BankReceiptAmmount,0) As BankReceiptAmmount,Round(Isnull(BankReceiptAmmount,0) * @DefaultExchangeRate,2),0.00 As DocDebitTotal,0.00 As DocCreditTotal,0.00 As BaseDebitTotal,0.00 As BaseCreditTotal,Id As DocumentId,@GUIDZero,@GUIDZero,
								BaseCurrency,@DefaultExchangeRate,GSTExCurrency,GSTExchangeRate,@DocType,@DocSubType,ServiceCompanyId,DocNo,0 As IsTax,
								EntityId,@MasterSystemRefNo As SystemRefNo,@DocCurrency,DocDate,DocDate,@RecOrder As RecOrder
						From Bean.Receipt(Nolock) Where Id=@SourceId
					End
					Else IF Exists (Select Id From Bean.Receipt(Nolock) Where Id=@SourceId And GrandTotal=0 And BankReceiptAmmount<>0)
					Begin
						Set @RecOrder=@RecOrder+1
						Insert Into Bean.JournalDetail (Id,JournalId,COAId,AccountDescription,AllowDisAllow, DocDebit, BaseDebit, DocDebitTotal,DocCreditTotal,BaseDebitTotal,BaseCreditTotal,DocumentId,DocumentDetailId,ItemId,BaseCurrency,ExchangeRate,GSTExCurrency,GSTExchangeRate,DocType,DocSubType,ServiceCompanyId,DocNo, IsTax,
										EntityId, SystemRefNo, DocCurrency,DocDate, PostingDate,RecOrder )
						Select NEWID(),@MasterJournalId,COAId,Remarks,IsDisAllow,Isnull(BankReceiptAmmount,0) As BankReceiptAmmount,Round(Isnull(BankReceiptAmmount,0) * @DefaultExchangeRate,2),0.00 As DocDebitTotal,0.00 As DocCreditTotal,0.00 As BaseDebitTotal,0.00 As BaseCreditTotal,Id As DocumentId,@GUIDZero,@GUIDZero,
								BaseCurrency,@DefaultExchangeRate,GSTExCurrency,GSTExchangeRate,@DocType,@DocSubType,ServiceCompanyId,DocNo,0 As IsTax,
								EntityId,@MasterSystemRefNo As SystemRefNo,@DocCurrency,DocDate,DocDate,@RecOrder As RecOrder
						From Bean.Receipt(Nolock) Where Id=@SourceId
					End
					/* Creating Record in Journaldetail With Bank Charges Amount */
					If Exists(Select Id From Bean.Receipt(Nolock) Where Id=@SourceId And BankCharges Is Not Null)
					Begin
						Set @RecOrder=@RecOrder+1
						Insert Into Bean.JournalDetail (Id,JournalId,COAId,AccountDescription,AllowDisAllow,TaxId,TaxType,TaxRate,DocDebit, BaseDebit, DocDebitTotal,DocCreditTotal,BaseDebitTotal,BaseCreditTotal,DocumentId,DocumentDetailId,ItemId,BaseCurrency,ExchangeRate,GSTExCurrency,GSTExchangeRate,DocType,DocSubType,ServiceCompanyId,DocNo, IsTax,
													EntityId, SystemRefNo, DocCurrency,DocDate, PostingDate,RecOrder,GSTTaxDebit)
						Select NEWID(),@MasterJournalId,@BankCharges_COAId,Remarks,IsDisAllow,@TaxId,@TaxType,@TaxRate,BankCharges,BankCharges * Round(@DefaultExchangeRate,2),0.00 As DocDebitTotal,0.00 As DocCreditTotal,0.00 As BaseDebitTotal,0.00 As BaseCreditTotal,Id As DocumentId,Id As DocumentDetailId,@GUIDZero,
							BaseCurrency,@DefaultExchangeRate,GSTExCurrency,GSTExchangeRate,@DocType,@DocSubType,ServiceCompanyId,DocNo,0 As IsTax,
							EntityId,@MasterSystemRefNo As SystemRefNo,@DocCurrency,DocDate,DocDate,@RecOrder As RecOrder,
							Case When @TaxId Is Not Null Then Round(BankCharges * Coalesce(GSTexchangerate,@DefaultExchangeRate),2) End As GSTTaxDebit
						From Bean.Receipt(Nolock)
						Where Id=@SourceId
					End
					/* Creating Record in Journaldetail With ExcesPaidByClientAmt Amount */
					If @ExcesPaidByClientAmt Is NOt Null
					Begin
						Set @RecOrder=@RecOrder+1
						Insert Into Bean.JournalDetail (Id,JournalId,COAId,AccountDescription,AllowDisAllow, DocCredit, BaseCredit, DocDebitTotal,DocCreditTotal,BaseDebitTotal,BaseCreditTotal,DocumentId,DocumentDetailId,ItemId,BaseCurrency,ExchangeRate,GSTExCurrency,GSTExchangeRate,DocType,DocSubType,ServiceCompanyId,DocNo, IsTax,
														EntityId, SystemRefNo, DocCurrency,DocDate, PostingDate,RecOrder )
						Select NEWID(),@MasterJournalId,@ClearingReceiptsCOAID,Remarks,IsDisAllow,ExcessPaidByClientAmmount,ExcessPaidByClientAmmount * Round(@DefaultExchangeRate,2),0.00 As DocDebitTotal,0.00 As DocCreditTotal,0.00 As BaseDebitTotal,0.00 As BaseCreditTotal,Id As DocumentId,Id As DocumentDtlId,@GUIDZero,
								BaseCurrency,@DefaultExchangeRate,BankReceiptAmmountCurrency,ExchangeRate,@DocType,@DocSubType,ServiceCompanyId,DocNo,0 As IsTax,
								EntityId,@MasterSystemRefNo As SystemRefNo,@DocCurrency,DocDate,DocDate,@RecOrder As RecOrder
						From Bean.Receipt(Nolock)
						Where Id=@SourceId
					End
					/* Creating Balancing Line Items */
					Insert Into @RecieptBalLnItm
					Select RBI.Id From Bean.ReceiptBalancingItem(Nolock) As RBI
					Inner Join bean.Receipt(Nolock) As R On R.Id=RBI.ReceiptId
					Where R.Id=@SourceId Order by RecOrder
					Set @Count=(Select Count(*) From @RecieptBalLnItm)
					Set @RecCount=1
					While @Count>=@RecCount
					Begin
						Select @RecieptBalId=RecieptBalId From @RecieptBalLnItm Where S_no=@RecCount
						Select @TaxId=TaxId,@TaxRate=TaxRate From Bean.ReceiptBalancingItem(Nolock) Where Id=@RecieptBalId
						Set @RecOrder=@RecOrder+1
						Insert Into Bean.JournalDetail (Id,JournalId,COAId,AccountDescription,AllowDisAllow,TaxId,TaxType,TaxRate,DocDebit,DocCredit,
													DocTaxDebit,DocTaxCredit,BaseDebit,BaseCredit,
													BaseTaxDebit,BaseTaxCredit,DocDebitTotal,DocCreditTotal,BaseDebitTotal,BaseCreditTotal,DocumentId,DocumentDetailId,ItemId,BaseCurrency,ExchangeRate,GSTExCurrency,GSTExchangeRate,DocType,DocSubType,ServiceCompanyId,DocNo, IsTax,
													EntityId, SystemRefNo, DocCurrency,DocDate, PostingDate,RecOrder,GSTTaxDebit,GSTTaxCredit,GSTDebit,GSTCredit)
						Select NEWID(),@MasterJournalId,RBi.COAId,R.Remarks,RBI.IsDisAllow,RBI.TaxId,RBI.TaxType,Rbi.TaxRate,
							Case When RBI.ReciveORPay=@Pay_Dr Then RBI.DocAmount End As DocDebit,Case When RBI.ReciveORPay=@Receive_Cr Then RBI.DocAmount End As DocCredit,
							Case When RBI.ReciveORPay=@Pay_Dr Then RBI.DocTaxAmount End As DocTaxDebdit,Case When RBI.ReciveORPay=@Receive_Cr Then RBI.DocTaxAmount End As DocTaxCredit,
							Case When RBI.ReciveORPay=@Pay_Dr Then RBI.DocAmount * Round(@DefaultExchangeRate,2) End As BaseDebit,
							Case When RBI.ReciveORPay=@Receive_Cr Then RBI.DocAmount * Round(@DefaultExchangeRate,2) End As BaseCredit,
							Case When RBI.ReciveORPay=@Pay_Dr Then RBI.DocTaxAmount * Round(@DefaultExchangeRate,2) End As BaseTaxDebit,
							Case When RBI.ReciveORPay=@Receive_Cr Then RBI.DocTaxAmount * Round(@DefaultExchangeRate,2) End As BaseTaxCredit,0.00 As DocDebitTotal,0.00 As DocCreditTotal,0.00 As BaseDebitTotal,0.00 As BaseCreditTotal,R.Id As DocumentId,RBI.Id As DocumentDetailId,@GUIDZero,
							R.BaseCurrency,@DefaultExchangeRate As ExchangeRate,R.GSTExCurrency,R.GSTExchangeRate,@DocType,@DocSubType,ServiceCompanyId,DocNo,0 As IsTax,
							EntityId,@MasterSystemRefNo As SystemRefNo,@DocCurrency,DocDate,DocDate,@RecOrder As RecOrder,
							Case When RBI.ReciveORPay=@Pay_Dr Then Round(RBI.DocAmount * Coalesce(R.GSTExchangeRate,@DefaultExchangeRate),2) End As GSTTaxDebit,
							Case When RBI.ReciveORPay=@Receive_Cr Then Round(RBI.DocAmount * Coalesce(R.GSTExchangeRate,@DefaultExchangeRate),2) End As GSTTaxCredit,
							Case When RBI.ReciveORPay=@Pay_Dr Then Round(RBI.DocTaxAmount * Coalesce(R.GSTExchangeRate,@DefaultExchangeRate),2) End As GSTDebit,
							Case When RBI.ReciveORPay=@Receive_Cr Then Round(RBI.DocTaxAmount * Coalesce(R.GSTExchangeRate,@DefaultExchangeRate),2) End As GSTCredit
						From Bean.Receipt(Nolock) As R
						Inner Join bean.ReceiptBalancingItem(Nolock) As RBI On RBI.ReceiptId=R.Id
						Where R.Id=@SourceId And Rbi.Id=@RecieptBalId
						-- Creating Tax Line Items
						If @GST Is Not Null And @GST=1 And @TaxId Is Not Null And (@TaxRate Is Not Null And @TaxRate<>0)
						Begin
							
							Set @TaxRecCount=@RecOrder+@Count
							Insert Into Bean.JournalDetail (Id,JournalId,COAId,AccountDescription,AllowDisAllow,TaxId,TaxType,TaxRate,DocDebit,DocCredit,
									 BaseDebit,BaseCredit,
									 DocDebitTotal,DocCreditTotal,BaseDebitTotal,BaseCreditTotal,DocumentId,DocumentDetailId,ItemId,BaseCurrency,ExchangeRate,GSTExCurrency,GSTExchangeRate,DocType,DocSubType,ServiceCompanyId,DocNo, IsTax,
									EntityId, SystemRefNo, DocCurrency,DocDate, PostingDate,RecOrder )
							Select NEWID(),@MasterJournalId,@TaxPayableGST_COAID as COAId,R.Remarks,RBI.IsDisAllow,RBI.TaxId,RBI.TaxType,Rbi.TaxRate,Case When RBI.ReciveORPay=@Pay_Dr Then RBI.DocTaxAmount End As DocDebit,Case When RBI.ReciveORPay=@Receive_Cr Then RBI.DocTaxAmount End As DocCredit,
								Case When RBI.ReciveORPay=@Pay_Dr Then RBI.DocTaxAmount * Round(@DefaultExchangeRate,2) End As BaseDebit,Case When RBI.ReciveORPay=@Receive_Cr Then RBI.DocTaxAmount * Round(@DefaultExchangeRate,2) End As BaseCredit,
								0.00 As DocDebitTotal,0.00 As DocCreditTotal,0.00 As BaseDebitTotal,0.00 As BaseCreditTotal,R.Id As DocumentId,RBI.Id As DocumentDetailId,@GUIDZero,
								R.BaseCurrency,@DefaultExchangeRate As ExchangeRate,R.GSTExCurrency,R.GSTExchangeRate,@DocType,@DocSubType,ServiceCompanyId,DocNo,1 As IsTax,
								EntityId,@MasterSystemRefNo As SystemRefNo,@DocCurrency,DocDate,DocDate,@TaxRecCount As RecOrder
							From Bean.Receipt(Nolock) As R
							Inner Join bean.ReceiptBalancingItem(Nolock) As RBI On RBI.ReceiptId=R.Id
							Where R.Id=@SourceId And Rbi.Id=@RecieptBalId
						End
						Set @RecCount=@RecCount+1
					End
					-- ServComp Records
					Insert Into @ServCompaIdTbl
					Select Distinct RD.ServiceCompanyId From Bean.ReceiptDetail(Nolock) As RD
					Inner Join Bean.Receipt(Nolock) As R On RD.ReceiptId=R.Id 
					Where R.Id=@SourceId And RD.ReceiptAmount<>0 And RD.ServiceCompanyId<>@MasterServComp And ReceiptAmount<>0
					Set @Count=(Select Count(*) From @ServCompaIdTbl)
					Set @RecCount=1
					While @Count>=@RecCount
					Begin
						Select @ServCompId=SerCompId From @ServCompaIdTbl Where S_No=@RecCount
						Set @IntroCompCOAID=(Select COA.Id From Bean.ChartOfAccount(Nolock) As COA 
												Inner Join Bean.AccountType(Nolock) As ACT On ACT.Id=COA.AccountTypeId
												Where ACT.CompanyId=@CompanyId And ACT.Name=@IntercompClearingCOAName And COA.SubsidaryCompanyId=@ServCompId)
						Set @ClearingRecieptInvOrDNAmount=(Select Sum(Isnull(ReceiptAmount,0)) From bean.ReceiptDetail(Nolock) Where ReceiptId=@SourceId And ServiceCompanyId=@ServCompId And DocumentType in (@InvoiceDocument,@DebitNoteDocument))
						Set @ClearingRecieptBillAmount=(Select Sum(Isnull(ReceiptAmount,0)) From bean.ReceiptDetail(Nolock) Where ReceiptId=@SourceId And ServiceCompanyId=@ServCompId And DocumentType=@BillDocument) 
						Set @CreditNoteAmount=(Select Sum(Isnull(ReceiptAmount,0)) From Bean.ReceiptDetail(Nolock) Where ReceiptId=@SourceId And ServiceCompanyId=@ServCompId And DocumentType=@CreditNoteDocument)
						Set @CreditMemoAmount=(Select Sum(Isnull(ReceiptAmount,0)) From Bean.ReceiptDetail(Nolock) Where ReceiptId=@SourceId And ServiceCompanyId=@ServCompId And DocumentType=@CreditMemoDocument)
						IF @ClearingRecieptInvOrDNAmount Is null
						Begin
							Set @ClearingRecieptInvOrDNAmount =Isnull(@ClearingRecieptInvOrDNAmount,0)
						End
						IF @ClearingRecieptBillAmount Is null
						Begin
							Set @ClearingRecieptBillAmount =Isnull(@ClearingRecieptBillAmount,0)
						End
						IF @CreditNoteAmount Is null
						Begin
							Set @CreditNoteAmount =Isnull(@CreditNoteAmount,0)
						End
						IF @CreditMemoAmount Is null
						Begin
							Set @CreditMemoAmount =Isnull(@CreditMemoAmount,0)
						End
						IF (@ClearingRecieptInvOrDNAmount Is Not Null And @ClearingRecieptInvOrDNAmount<>0) OR (@ClearingRecieptBillAmount Is Not Null And @ClearingRecieptBillAmount <>0)
						Begin
							Set @RecOrder=@RecOrder+1
							Insert Into Bean.JournalDetail (Id,JournalId,COAId,AccountDescription, DocDebit,DocCredit,
															 BaseDebit,BaseCredit,
															 DocDebitTotal,DocCreditTotal,BaseDebitTotal,BaseCreditTotal,DocumentId,DocumentDetailId,ItemId,BaseCurrency,ExchangeRate, DocType,DocSubType,ServiceCompanyId,DocNo,Nature,OffsetDocument,IsTax,
															EntityId, SystemRefNo, DocCurrency,DocDate, PostingDate,RecOrder 
															)
							Select NEWID(),@MasterJournalId,@IntroCompCOAID,R.Remarks,Case When (@ClearingRecieptInvOrDNAmount-@ClearingRecieptBillAmount)<0 Then ABS(@ClearingRecieptInvOrDNAmount-@ClearingRecieptBillAmount) End As DocDebit,
								Case When (@ClearingRecieptInvOrDNAmount-@ClearingRecieptBillAmount)>0 Then ABS(@ClearingRecieptInvOrDNAmount-@ClearingRecieptBillAmount) End As DocCredit,
								Case When (@ClearingRecieptInvOrDNAmount-@ClearingRecieptBillAmount)<0 Then ABS(@ClearingRecieptInvOrDNAmount-@ClearingRecieptBillAmount) * Round(@DefaultExchangeRate,2) End As BaseDebit,
								Case When (@ClearingRecieptInvOrDNAmount-@ClearingRecieptBillAmount)>0 Then ABS(@ClearingRecieptInvOrDNAmount-@ClearingRecieptBillAmount) * Round(@DefaultExchangeRate,2) End As BaseCredit,
								0.00 As DocDebitTotal,0.00 As DocCreditTotal,0.00 As BaseDebitTotal,0.00 As BaseCreditTotal,R.Id As DocumentId,@GUIDZero As DocumentDetailId,@GUIDZero,
								R.BaseCurrency,@DefaultExchangeRate As ExchangeRate,@DocType,@DocSubType,@MasterServComp As ServiceCompanyId,R.DocNo,Null As Nature,R.DocNo,0 As IsTax,
								R.EntityId,@MasterSystemRefNo,@DocCurrency,R.DocDate,R.DocDate,@RecOrder As RecOrder
							From Bean.Receipt(Nolock) As R
							Where R.Id=@SourceId
							-- Details
							Set @JournalId=NEWID()
							Set @SysRefNum_Incr=@SysRefNum_Incr+1
							Set @SystemRefNo=CONCAT(@DocNo,'-JV',@SysRefNum_Incr)
							Insert Into Bean.Journal (Id,CompanyId,DocDate,DocType,DocSubType,DocNo,ServiceCompanyId,SystemReferenceNo,IsNoSupportingDocs,NoSupportingDocument,DocCurrency,ExchangeRate,ExCurrency,ExDurationFrom,GSTExchangeRate,GSTExCurrency,GSTTotalAmount,DocumentState,IsNoSupportingDocument,IsGstSettings,IsMultiCurrency,IsAllowableNonAllowable,IsGSTCurrencyRateChanged,Remarks,UserCreated,CreatedDate,Status,DocumentDescription,CreationType,GrandDocDebitTotal,GrandDocCreditTotal,GrandBaseDebitTotal,
														GrandBaseCreditTotal,EntityId,EntityType,PostingDate,COAId,ModeOfReceipt,BankReceiptAmmount,ExcessPaidByClientAmmount,BalancingItemReciveCRAmount,  BalancingItemPayDRAmount,ReceiptApplicationAmmount,DocumentId, BankClearingDate ,IsBalancing,ISAllowDisAllow, IsShow, ActualSysRefNo 
														,IsSegmentReporting,TransferRefNo
													 )
							Select @JournalId,@CompanyId,DocDate,@DocType,@DocSubType,DocNo,@ServCompId As ServiceCompanyId,@SystemRefNo As SystemRefNo,IsNoSupportingDocument,NoSupportingDocs,DocCurrency,ExchangeRate,ExCurrency,ExDurationFrom,GSTExchangeRate,GSTExCurrency,Isnull(GSTTotalAmount,0),DocumentState,NoSupportingDocs,IsGstSettings,IsMultiCurrency,IsAllowableDisallowable,IsGSTCurrencyRateChanged,Remarks,@UserCreated,@CreatedDate,Status,Remarks As DocDescription,@UserCreated,GrandTotal,0.00 As GrandDocCreditTotal,GrandTotal * Round(ExchangeRate,2) As GrandBaseDebitTotal,
									0.00 As GrandBaseCreditTotal,EntityId,EntityType,DocDate As PostingDate,@IntroCompCOAID As COAId,ModeOfReceipt,0.00 As BankReceiptAmmount,0.00 As ExcessPaidByClientAmmount,0.00 As BalancingItemReciveCRAmount,0.00 As BalancingItemPayDRAmount,0.00 As ReceiptApplicationAmmount,Id As DocumentId,BankClearingDate,0 As IsBalancing,IsDisAllow,1 As IsShow,DocNo As ActualSysRefNo, 0 As IsSegmentReporting,ReceiptRefNo
							From Bean.Receipt(Nolock) Where CompanyId=@CompanyId And Id=@SourceId
							Set @DtlRecOrder=1
							Insert Into Bean.JournalDetail (Id,JournalId,COAId,AccountDescription, DocDebit,DocCredit,
													 BaseDebit,BaseCredit,
													 DocDebitTotal,DocCreditTotal,BaseDebitTotal,BaseCreditTotal,DocumentId,DocumentDetailId,ItemId,BaseCurrency,ExchangeRate, DocType,DocSubType,ServiceCompanyId,DocNo,Nature,OffsetDocument,IsTax,
													EntityId, SystemRefNo, DocCurrency,DocDate, PostingDate,RecOrder 
													)
							Select NEWID(),@JournalId,@MainInterCoServCompCOAID,R.Remarks,Case When (@ClearingRecieptInvOrDNAmount-@ClearingRecieptBillAmount) >0 Then ABS(@ClearingRecieptInvOrDNAmount-@ClearingRecieptBillAmount) End As DocDebit,
									Case When (@ClearingRecieptInvOrDNAmount-@ClearingRecieptBillAmount)<0 Then ABS(@ClearingRecieptInvOrDNAmount-@ClearingRecieptBillAmount) End As DocCredit,
									Case When (@ClearingRecieptInvOrDNAmount-@ClearingRecieptBillAmount) >0 Then ABS(@ClearingRecieptInvOrDNAmount-@ClearingRecieptBillAmount) * Round(@DefaultExchangeRate,2) End As BaseDebit,
									Case When (@ClearingRecieptInvOrDNAmount-@ClearingRecieptBillAmount) <0 Then ABS(@ClearingRecieptInvOrDNAmount-@ClearingRecieptBillAmount) * Round(@DefaultExchangeRate,2) End As BaseCredit,
									0.00 As DocDebitTotal,0.00 As DocCreditTotal,0.00 As BaseDebitTotal,0.00 As BaseCreditTotal,R.Id As DocumentId,R.Id As DocumentDetailId,@GUIDZero,
									R.BaseCurrency,R.ExchangeRate,@DocType,@DocSubType,@ServCompId As ServiceCompanyId,R.DocNo,Null As Nature,R.DocNo,0 As IsTax,
									R.EntityId,@SystemRefNo,@DocCurrency,R.DocDate,R.DocDate,@DtlRecOrder As RecOrder
							From Bean.Receipt(Nolock) As R
							Where R.Id=@SourceId 
							-- Detail Records
							Delete From @RecieptDtl_New
							Insert Into @RecieptDtl_New 
							Select ROW_NUMBER() Over (Order By RD.id),RD.Id From Bean.ReceiptDetail(Nolock) As RD
							Inner Join Bean.Receipt(Nolock) As R On RD.ReceiptId=R.Id 
							Where R.Id=@SourceId And RD.ServiceCompanyId=@ServCompId And RD.ReceiptAmount<>0 And RD.DocumentType Not In (@CreditNoteDocument,@CreditMemoDocument) Order By RD.RecOrder
							Set @DtlCount=(Select Count(*) From @RecieptDtl_New)
							Set @RdtlRecCount=1
							While @DtlCount>=@RdtlRecCount
							Begin
								Set @RecieptDtlId=(Select RecieptDtlId From @RecieptDtl_New Where S_No=@RdtlRecCount)
								Set @OffSetDocumentType=(Select DocumentType From Bean.ReceiptDetail(Nolock) Where Id=@RecieptDtlId)
								--Getting COAID By Checking Nature
								IF Exists (Select ID From Bean.ReceiptDetail(Nolock) Where id=@RecieptDtlId And Nature=@NatureTrade And DocumentType in (@InvoiceDocument,@DebitNoteDocument))
								Begin
									Set @COAID=(Select Id From Bean.ChartOfAccount(Nolock) Where CompanyId=@CompanyId And Name=@COATradeReceivables)
								End
								Else IF Exists (Select ID From Bean.ReceiptDetail(Nolock) Where id=@RecieptDtlId And Nature=@NatureOthers And DocumentType in (@InvoiceDocument,@DebitNoteDocument))
								Begin
									Set @COAID=(Select Id From Bean.ChartOfAccount(Nolock) Where CompanyId=@CompanyId And Name=@COAotherReceivables )
								End
								Else IF Exists (Select ID From Bean.ReceiptDetail(Nolock) Where id=@RecieptDtlId And DocumentType=@BillDocument And Nature=@NatureTrade)
								Begin
									Set @COAID=(Select Id From Bean.ChartOfAccount(Nolock) Where CompanyId=@CompanyId And Name=@COATradePayables)
								End
								Else IF Exists (Select ID From Bean.ReceiptDetail(Nolock) Where id=@RecieptDtlId And DocumentType=@BillDocument And Nature=@NatureOthers)
								Begin
									Set @COAID=(Select Id From Bean.ChartOfAccount(Nolock) Where CompanyId=@CompanyId And Name=@COAOtherPayables)
								End
								IF (Coalesce(@OffSetDocumentType,'NULL')=@BillDocument)
								Begin
									Set @DtlRecOrder=@DtlRecOrder+1
									Insert Into Bean.JournalDetail (Id,JournalId,COAId,AccountDescription, DocDebit,DocCredit,
																	 BaseDebit,BaseCredit,
																	 DocDebitTotal,DocCreditTotal,BaseDebitTotal,BaseCreditTotal,DocumentId,DocumentDetailId,ItemId,BaseCurrency,ExchangeRate, DocType,DocSubType,ServiceCompanyId,DocNo,Nature,OffsetDocument,IsTax,
																	EntityId, SystemRefNo, DocCurrency,DocDate, PostingDate,RecOrder 
																	)
									Select NEWID(),@JournalId,@COAID,R.Remarks,RD.ReceiptAmount As DocDebit,Null As DocCredit,
										RD.ReceiptAmount * Round(@DefaultExchangeRate,2) As BaseDebit,Null As BaseCredit,
										0.00 As DocDebitTotal,0.00 As DocCreditTotal,0.00 As BaseDebitTotal,0.00 As BaseCreditTotal,R.Id As DocumentId,RD.Id As DocumentDetailId,@GUIDZero,
										R.BaseCurrency,@DefaultExchangeRate As ExchangeRate,@DocType,@DocSubType,RD.ServiceCompanyId,R.DocNo,RD.Nature,Null As DocumentNo,0 As IsTax,
										R.EntityId,@SystemRefNo,@DocCurrency,R.DocDate,R.DocDate,@DtlRecOrder As RecOrder
									From Bean.Receipt(Nolock) As R
									Inner Join bean.ReceiptDetail(Nolock) As RD On RD.ReceiptId=R.Id
									Where R.Id=@SourceId And RD.Id=@RecieptDtlId
								End
								Else
								Begin
									Set @DtlRecOrder=@DtlRecOrder+1
									Insert Into Bean.JournalDetail (Id,JournalId,COAId,AccountDescription, DocDebit,DocCredit,
															 BaseDebit,BaseCredit,
															 DocDebitTotal,DocCreditTotal,BaseDebitTotal,BaseCreditTotal,DocumentId,DocumentDetailId,ItemId,BaseCurrency,ExchangeRate, DocType,DocSubType,ServiceCompanyId,DocNo,Nature,OffsetDocument,IsTax,
															EntityId, SystemRefNo, DocCurrency,DocDate, PostingDate,RecOrder 
															)
									Select NEWID(),@JournalId,@COAID,R.Remarks,Null As DocDebit,RD.ReceiptAmount As DocCredit,
										Null As BaseDebit,RD.ReceiptAmount * Round(@DefaultExchangeRate,2) As BaseCredit,
										0.00 As DocDebitTotal,0.00 As DocCreditTotal,0.00 As BaseDebitTotal,0.00 As BaseCreditTotal,R.Id As DocumentId,RD.Id As DocumentDetailId,@GUIDZero,
										R.BaseCurrency,@DefaultExchangeRate As ExchangeRate,@DocType,@DocSubType,RD.ServiceCompanyId,R.DocNo,RD.Nature,RD.DocumentNo,0 As IsTax,
										R.EntityId,@SystemRefNo,@DocCurrency,R.DocDate,R.DocDate,@DtlRecOrder As RecOrder
									From Bean.Receipt(Nolock) As R
									Inner Join bean.ReceiptDetail(Nolock) As RD On RD.ReceiptId=R.Id
									Where R.Id=@SourceId And RD.Id=@RecieptDtlId
								End
								Set @RdtlRecCount=@RdtlRecCount+1
							End
						End
						IF @CreditMemoAmount Is Not Null And @CreditMemoAmount<>0
						Begin
							Set @RecOrder=@RecOrder+1
							Insert Into Bean.JournalDetail (Id,JournalId,COAId,AccountDescription, DocDebit,DocCredit,
														 BaseDebit,BaseCredit,
														 DocDebitTotal,DocCreditTotal,BaseDebitTotal,BaseCreditTotal,DocumentId,DocumentDetailId,ItemId,BaseCurrency,ExchangeRate, DocType,DocSubType,ServiceCompanyId,DocNo,Nature,OffsetDocument,IsTax,
														EntityId, SystemRefNo, DocCurrency,DocDate, PostingDate,RecOrder 
														)
							Select NEWID(),@MasterJournalId,@IntroCompCOAID,R.Remarks,Null As DocDebit,@CreditMemoAmount As DocCredit,
								Null As BaseDebit,@CreditMemoAmount * Round(@DefaultExchangeRate,2) As BaseCredit,
								0.00 As DocDebitTotal,0.00 As DocCreditTotal,0.00 As BaseDebitTotal,0.00 As BaseCreditTotal,R.Id As DocumentId,@GUIDZero As DocumentDetailId,@GUIDZero,
								R.BaseCurrency,@DefaultExchangeRate As ExchangeRate,@DocType,@DocSubType,@MasterServComp As ServiceCompanyId,R.DocNo,Null As Nature,R.DocNo,0 As IsTax,
								R.EntityId,@MasterSystemRefNo,@DocCurrency,R.DocDate,R.DocDate,@RecOrder As RecOrder
							From Bean.Receipt(Nolock) As R
							Where R.Id=@SourceId
						End
						IF @CreditNoteAmount Is Not Null And @CreditNoteAmount<>0
						Begin
							Set @RecOrder=@RecOrder+1
							Insert Into Bean.JournalDetail (Id,JournalId,COAId,AccountDescription, DocDebit,DocCredit,
														 BaseDebit,BaseCredit,
														 DocDebitTotal,DocCreditTotal,BaseDebitTotal,BaseCreditTotal,DocumentId,DocumentDetailId,ItemId,BaseCurrency,ExchangeRate, DocType,DocSubType,ServiceCompanyId,DocNo,Nature,OffsetDocument,IsTax,
														EntityId, SystemRefNo, DocCurrency,DocDate, PostingDate,RecOrder 
														)
							Select NEWID(),@MasterJournalId,@IntroCompCOAID,R.Remarks,@CreditNoteAmount As DocDebit,NUll As DocCredit,
								@CreditNoteAmount * Round(@DefaultExchangeRate,2) As BaseDebit,Null As BaseCredit,
								0.00 As DocDebitTotal,0.00 As DocCreditTotal,0.00 As BaseDebitTotal,0.00 As BaseCreditTotal,R.Id As DocumentId,@GUIDZero As DocumentDetailId,@GUIDZero,
								R.BaseCurrency,@DefaultExchangeRate As ExchangeRate,@DocType,@DocSubType,@MasterServComp As ServiceCompanyId,R.DocNo,Null As Nature,R.DocNo,0 As IsTax,
								R.EntityId,@MasterSystemRefNo,@DocCurrency,R.DocDate,R.DocDate,@RecOrder As RecOrder
							From Bean.Receipt(Nolock) As R
							Where R.Id=@SourceId
						End
						Set @RecCount=@RecCount+1
					End
					-- Credit Note Jv for master service company
					IF Exists (Select Id From Bean.ReceiptDetail(Nolock) Where ReceiptId=@SourceId And ServiceCompanyId=@MasterServComp And DocumentType =@CreditNoteDocument)
					Begin
						Set @RecOrder=@RecOrder+1
						Set @CreditNoteAmount=(Select Sum(Isnull(ReceiptAmount,0)) From Bean.ReceiptDetail(Nolock) Where ReceiptId=@SourceId And ServiceCompanyId=@MasterServComp And DocumentType =@CreditNoteDocument)
						Insert Into Bean.JournalDetail (Id,JournalId,COAId,AccountDescription, DocDebit,DocCredit,
																 BaseDebit,BaseCredit,
																 DocDebitTotal,DocCreditTotal,BaseDebitTotal,BaseCreditTotal,DocumentId,DocumentDetailId,ItemId,BaseCurrency,ExchangeRate, DocType,DocSubType,ServiceCompanyId,DocNo,Nature,OffsetDocument,IsTax,
																EntityId, SystemRefNo, DocCurrency,DocDate, PostingDate,RecOrder 
																)
						Select NEWID(),@MasterJournalId,@ClearingReceiptsCOAID,R.Remarks,@CreditNoteAmount As DocDebit,Null As DocCredit,
							Round(@CreditNoteAmount * @DefaultExchangeRate,2) As BaseDebit, Null As BaseCredit,
							0.00 As DocDebitTotal,0.00 As DocCreditTotal,0.00 As BaseDebitTotal,0.00 As BaseCreditTotal,R.Id As DocumentId,@GUIDZero As DocumentDetailId,@GUIDZero,
							R.BaseCurrency,@DefaultExchangeRate As ExchangeRate,@DocType,@DocSubType,ServiceCompanyId As ServiceCompanyId,R.DocNo,Null As Nature,R.DocNo,0 As IsTax,
							R.EntityId,@MasterSystemRefNo,@BankChargesCurrency,R.DocDate,R.DocDate,@RecOrder As RecOrder
						From Bean.Receipt(Nolock) As R
						Where R.Id=@SourceId
					End
					-- Credit Memo Jv for master service company
					IF Exists (Select Id From Bean.ReceiptDetail(Nolock) Where ReceiptId=@SourceId And ServiceCompanyId=@MasterServComp And DocumentType =@CreditMemoDocument)
					Begin
						Set @RecOrder=@RecOrder+1
						Set @creditmemoAmount=(Select Sum(Isnull(ReceiptAmount,0)) From Bean.ReceiptDetail(Nolock) Where ReceiptId=@SourceId And ServiceCompanyId=@MasterServComp And DocumentType =@CreditMemoDocument)
						Insert Into Bean.JournalDetail (Id,JournalId,COAId,AccountDescription, DocDebit,DocCredit,
																 BaseDebit,BaseCredit,
																 DocDebitTotal,DocCreditTotal,BaseDebitTotal,BaseCreditTotal,DocumentId,DocumentDetailId,ItemId,BaseCurrency,ExchangeRate, DocType,DocSubType,ServiceCompanyId,DocNo,Nature,OffsetDocument,IsTax,
																EntityId, SystemRefNo, DocCurrency,DocDate, PostingDate,RecOrder 
																)
						Select NEWID(),@MasterJournalId,@ClearingReceiptsCOAID,R.Remarks,Null As DocDebit,@creditmemoAmount As DocCredit,
							Null As BaseDebit,Round(@creditmemoAmount * @DefaultExchangeRate,2) As BaseCredit,
							0.00 As DocDebitTotal,0.00 As DocCreditTotal,0.00 As BaseDebitTotal,0.00 As BaseCreditTotal,R.Id As DocumentId,@GUIDZero As DocumentDetailId,@GUIDZero,
							R.BaseCurrency,@DefaultExchangeRate As ExchangeRate,@DocType,@DocSubType,ServiceCompanyId As ServiceCompanyId,R.DocNo,Null As Nature,R.DocNo,0 As IsTax,
							R.EntityId,@MasterSystemRefNo,@BankChargesCurrency,R.DocDate,R.DocDate,@RecOrder As RecOrder
						From Bean.Receipt(Nolock) As R
						Where R.Id=@SourceId
					End
					-- Creating Records For Interco In Journal Detail
					Insert Into @RecieptDtl 
					Select RD.Id From Bean.ReceiptDetail(Nolock) As RD
					Inner Join Bean.Receipt(Nolock) As R On RD.ReceiptId=R.Id 
					Where R.Id=@SourceId And RD.ReceiptAmount<>0 And RD.ServiceCompanyId=@MasterServComp And RD.DocumentType Not In (@CreditNoteDocument,@CreditMemoDocument) Order By RD.RecOrder 
					Set @Count=(Select Count(*) From @RecieptDtl)
					Set @RecCount=1
					While @Count>=@RecCount
					Begin
						Set @RecieptDtlId=(Select RecieptDtlId From @RecieptDtl Where S_No=@RecCount)
						Set @OffSetDocumentType=(Select DocumentType From Bean.ReceiptDetail(Nolock) Where Id=@RecieptDtlId)
						Set @DocumentId=(Select DocumentId From Bean.ReceiptDetail(Nolock) Where Id=@RecieptDtlId)
						Set @IsRoundingAmount=0
						--Getting COAID By Checking Nature
						IF Exists (Select ID From Bean.ReceiptDetail(Nolock) Where id=@RecieptDtlId And Nature=@NatureTrade And DocumentType=@InvoiceDocument)
						Begin
							Set @COAID=(Select Id From Bean.ChartOfAccount(Nolock) Where CompanyId=@CompanyId And Name=@COATradeReceivables)
							IF Exists(Select Id From Bean.Invoice(Nolock) Where Id=@DocumentId And DocumentState In (@FullyApplied,@Fullypaid))
							Begin
								Set @IsRoundingAmount=1
							End
						End
						Else IF Exists (Select ID From Bean.ReceiptDetail(Nolock) Where id=@RecieptDtlId And Nature=@NatureOthers And DocumentType=@InvoiceDocument)
						Begin
							Set @COAID=(Select Id From Bean.ChartOfAccount(Nolock) Where CompanyId=@CompanyId And Name=@COAotherReceivables )
							IF Exists(Select Id From Bean.Invoice(Nolock) Where Id=@DocumentId And DocumentState In (@FullyApplied,@Fullypaid))
							Begin
								Set @IsRoundingAmount=1
							End
						End
						Else IF Exists (Select ID From Bean.ReceiptDetail(Nolock) Where id=@RecieptDtlId And Nature=@NatureTrade And DocumentType=@DebitNoteDocument)
						Begin
							Set @COAID=(Select Id From Bean.ChartOfAccount(Nolock) Where CompanyId=@CompanyId And Name=@COATradeReceivables)
							IF Exists(Select Id From Bean.DebitNote(Nolock) Where Id=@DocumentId And DocumentState In (@FullyApplied,@Fullypaid))
							Begin
								Set @IsRoundingAmount=1
							End
						End
						Else IF Exists (Select ID From Bean.ReceiptDetail(Nolock) Where id=@RecieptDtlId And Nature=@NatureOthers And DocumentType=@DebitNoteDocument)
						Begin
							Set @COAID=(Select Id From Bean.ChartOfAccount(Nolock) Where CompanyId=@CompanyId And Name=@COAotherReceivables )
							IF Exists(Select Id From Bean.DebitNote(Nolock) Where Id=@DocumentId And DocumentState In (@FullyApplied,@Fullypaid))
							Begin
								Set @IsRoundingAmount=1
							End
						End
						Else IF Exists (Select ID From Bean.ReceiptDetail(Nolock) Where id=@RecieptDtlId And DocumentType=@BillDocument And Nature=@NatureTrade)
						Begin
							Set @COAID=(Select Id From Bean.ChartOfAccount(Nolock) Where CompanyId=@CompanyId And Name=@COATradePayables)
							IF Exists(Select Id From Bean.Bill(Nolock) Where Id=@DocumentId And DocumentState In (@FullyApplied,@Fullypaid))
							Begin
								Set @IsRoundingAmount=1
							End
						End
						Else IF Exists (Select ID From Bean.ReceiptDetail(Nolock) Where id=@RecieptDtlId And DocumentType=@BillDocument And Nature=@NatureOthers)
						Begin
							Set @COAID=(Select Id From Bean.ChartOfAccount(Nolock) Where CompanyId=@CompanyId And Name=@COAOtherPayables)
							IF Exists(Select Id From Bean.Bill(Nolock) Where Id=@DocumentId And DocumentState In (@FullyApplied,@Fullypaid))
							Begin
								Set @IsRoundingAmount=1
							End
						End
						IF @IsRoundingAmount=1 And Exists (Select Amount From @RoundingAmountDetails Where DocumentId=@DocumentId And Amount Is Not Null And Amount<>'')
						Begin
							Set @DocAmount=(Select Amount From @RoundingAmountDetails Where DocumentId=@DocumentId)
						End
						Else
						Begin
							Set @DocAmount=0
						End

						IF Coalesce(@OffSetDocumentType,'NULL')=@BillDocument
						Begin
							Set @RecOrder=@RecOrder+1
							Insert Into Bean.JournalDetail (Id,JournalId,COAId,AccountDescription, DocDebit,DocCredit,
															 BaseDebit,BaseCredit,
															 DocDebitTotal,DocCreditTotal,BaseDebitTotal,BaseCreditTotal,DocumentId,DocumentDetailId,ItemId,BaseCurrency,ExchangeRate, DocType,DocSubType,ServiceCompanyId,DocNo,Nature,OffsetDocument,IsTax,
															EntityId, SystemRefNo, DocCurrency,DocDate, PostingDate,RecOrder 
															)
							Select NEWID(),@MasterJournalId,@COAID,R.Remarks,RD.ReceiptAmount As DocDebit,Null As DocCredit,
								RD.ReceiptAmount * Round(R.ExchangeRate,2)- Isnull(@DocAmount,0) As BaseDebit,Null As BaseCredit,
								0.00 As DocDebitTotal,0.00 As DocCreditTotal,0.00 As BaseDebitTotal,0.00 As BaseCreditTotal,R.Id As DocumentId,RD.Id As DocumentDetailId,@GUIDZero,
								R.BaseCurrency,R.ExchangeRate,@DocType,@DocSubType,@MasterServComp AS ServiceCompanyId,R.DocNo,RD.Nature,Null As DocumentNo,0 As IsTax,
								R.EntityId,@MasterSystemRefNo,@DocCurrency,R.DocDate,R.DocDate,@RecOrder As RecOrder
							From Bean.Receipt(Nolock) As R
							Inner Join bean.ReceiptDetail(Nolock) As RD On RD.ReceiptId=R.Id
							Where R.Id=@SourceId And RD.Id=@RecieptDtlId
						End
						Else
						Begin
							Set @RecOrder=@RecOrder+1
							Insert Into Bean.JournalDetail (Id,JournalId,COAId,AccountDescription, DocDebit,DocCredit,
													 BaseDebit,BaseCredit,
													 DocDebitTotal,DocCreditTotal,BaseDebitTotal,BaseCreditTotal,DocumentId,DocumentDetailId,ItemId,BaseCurrency,ExchangeRate, DocType,DocSubType,ServiceCompanyId,DocNo,Nature,OffsetDocument,IsTax,
													EntityId, SystemRefNo, DocCurrency,DocDate, PostingDate,RecOrder 
													)
							Select NEWID(),@MasterJournalId,@COAID,R.Remarks,Null As DocDebit,RD.ReceiptAmount As DocCredit,
								Null As BaseDebit,RD.ReceiptAmount * Round(@DefaultExchangeRate,2)- Isnull(@DocAmount,0) As BaseCredit,
								0.00 As DocDebitTotal,0.00 As DocCreditTotal,0.00 As BaseDebitTotal,0.00 As BaseCreditTotal,R.Id As DocumentId,RD.Id As DocumentDetailId,@GUIDZero,
								R.BaseCurrency,@DefaultExchangeRate As ExchangeRate,@DocType,@DocSubType,@MasterServComp As ServiceCompanyId,R.DocNo,RD.Nature,RD.DocumentNo,0 As IsTax,
								R.EntityId,@MasterSystemRefNo,@DocCurrency,R.DocDate,R.DocDate,@RecOrder As RecOrder
							From Bean.Receipt(Nolock) As R
							Inner Join bean.ReceiptDetail(Nolock) As RD On RD.ReceiptId=R.Id
							Where R.Id=@SourceId And RD.Id=@RecieptDtlId
						End
						Set @RecCount=@RecCount+1
					End
				End
				Else IF @DocCurrency=@BankChargesCurrency And @BaseCurrency<>@DocCurrency
				Begin
					/* Creating Mater record In JournalDetail */
					IF Exists (Select Id From Bean.Receipt(Nolock) Where Id=@SourceId And GrandTotal<>0)
					Begin
						Set @RecOrder=@RecOrder+1
						Insert Into Bean.JournalDetail (Id,JournalId,COAId,AccountDescription,AllowDisAllow, DocDebit, BaseDebit, DocDebitTotal,DocCreditTotal,BaseDebitTotal,BaseCreditTotal,DocumentId,DocumentDetailId,ItemId,BaseCurrency,ExchangeRate,GSTExCurrency,GSTExchangeRate,DocType,DocSubType,ServiceCompanyId,DocNo, IsTax,
										EntityId, SystemRefNo, DocCurrency,DocDate, PostingDate,RecOrder )
						Select NEWID(),@MasterJournalId,COAId,Remarks,IsDisAllow,Isnull(BankReceiptAmmount,0) As BankReceiptAmmount,Round(Isnull(BankReceiptAmmount,0) * @MainExchangeRate,2),0.00 As DocDebitTotal,0.00 As DocCreditTotal,0.00 As BaseDebitTotal,0.00 As BaseCreditTotal,Id As DocumentId,@GUIDZero,@GUIDZero,
								BaseCurrency,@MainExchangeRate,GSTExCurrency,GSTExchangeRate,@DocType,@DocSubType,ServiceCompanyId,DocNo,0 As IsTax,
								EntityId,@MasterSystemRefNo As SystemRefNo,@BankChargesCurrency,DocDate,DocDate,@RecOrder As RecOrder
						From Bean.Receipt(Nolock) Where Id=@SourceId
					End
					Else IF Exists (Select Id From Bean.Receipt(Nolock) Where Id=@SourceId And GrandTotal=0 And BankReceiptAmmount<>0)
					Begin
						Set @RecOrder=@RecOrder+1
						Insert Into Bean.JournalDetail (Id,JournalId,COAId,AccountDescription,AllowDisAllow, DocDebit, BaseDebit, DocDebitTotal,DocCreditTotal,BaseDebitTotal,BaseCreditTotal,DocumentId,DocumentDetailId,ItemId,BaseCurrency,ExchangeRate,GSTExCurrency,GSTExchangeRate,DocType,DocSubType,ServiceCompanyId,DocNo, IsTax,
										EntityId, SystemRefNo, DocCurrency,DocDate, PostingDate,RecOrder )
						Select NEWID(),@MasterJournalId,COAId,Remarks,IsDisAllow,Isnull(BankReceiptAmmount,0) As BankReceiptAmmount,Round(Isnull(BankReceiptAmmount,0) * @MainExchangeRate,2),0.00 As DocDebitTotal,0.00 As DocCreditTotal,0.00 As BaseDebitTotal,0.00 As BaseCreditTotal,Id As DocumentId,@GUIDZero,@GUIDZero,
								BaseCurrency,@MainExchangeRate,GSTExCurrency,GSTExchangeRate,@DocType,@DocSubType,ServiceCompanyId,DocNo,0 As IsTax,
								EntityId,@MasterSystemRefNo As SystemRefNo,@BankChargesCurrency,DocDate,DocDate,@RecOrder As RecOrder
						From Bean.Receipt(Nolock) Where Id=@SourceId
					End
					/* Creating Record in Journaldetail With Bank Charges Amount */
					If Exists(Select Id From Bean.Receipt(Nolock) Where Id=@SourceId And BankCharges Is Not Null)
					Begin
						Set @RecOrder=@RecOrder+1
						Insert Into Bean.JournalDetail (Id,JournalId,COAId,AccountDescription,AllowDisAllow,TaxId,TaxType,TaxRate,DocDebit, BaseDebit, DocDebitTotal,DocCreditTotal,BaseDebitTotal,BaseCreditTotal,DocumentId,DocumentDetailId,ItemId,BaseCurrency,ExchangeRate,GSTExCurrency,GSTExchangeRate,DocType,DocSubType,ServiceCompanyId,DocNo, IsTax,
													EntityId, SystemRefNo, DocCurrency,DocDate, PostingDate,RecOrder,GSTTaxDebit)
						Select NEWID(),@MasterJournalId,@BankCharges_COAId,Remarks,IsDisAllow,@TaxId,@TaxType,@TaxRate,BankCharges,Round(BankCharges * @MainExchangeRate,2),0.00 As DocDebitTotal,0.00 As DocCreditTotal,0.00 As BaseDebitTotal,0.00 As BaseCreditTotal,Id As DocumentId,Id As DocumentDetailId,@GUIDZero,
							BaseCurrency,@MainExchangeRate,GSTExCurrency,GSTExchangeRate,@DocType,@DocSubType,ServiceCompanyId,DocNo,0 As IsTax,
							EntityId,@MasterSystemRefNo As SystemRefNo,@BankChargesCurrency,DocDate,DocDate,@RecOrder As RecOrder,
							Case When @TaxId Is Not Null Then Round(BankCharges * Coalesce(GSTexchangerate,@DefaultExchangeRate),2) End As GSTTaxDebit
						From Bean.Receipt(Nolock)
						Where Id=@SourceId
					End
					/* Creating Record in Journaldetail With ExcesPaidByClientAmt Amount */
					If @ExcesPaidByClientAmt Is NOt Null
					Begin
						Set @RecOrder=@RecOrder+1
						Insert Into Bean.JournalDetail (Id,JournalId,COAId,AccountDescription,AllowDisAllow, DocCredit, BaseCredit, DocDebitTotal,DocCreditTotal,BaseDebitTotal,BaseCreditTotal,DocumentId,DocumentDetailId,ItemId,BaseCurrency,ExchangeRate,GSTExCurrency,GSTExchangeRate,DocType,DocSubType,ServiceCompanyId,DocNo, IsTax,
														EntityId, SystemRefNo, DocCurrency,DocDate, PostingDate,RecOrder )
						Select NEWID(),@MasterJournalId,@ClearingReceiptsCOAID,Remarks,IsDisAllow,ExcessPaidByClientAmmount,Round(ExcessPaidByClientAmmount * @MainExchangeRate,2),0.00 As DocDebitTotal,0.00 As DocCreditTotal,0.00 As BaseDebitTotal,0.00 As BaseCreditTotal,Id As DocumentId,Id As DocumentDtlId,@GUIDZero,
								BaseCurrency,@MainExchangeRate,BankReceiptAmmountCurrency,ExchangeRate,@DocType,@DocSubType,ServiceCompanyId,DocNo,0 As IsTax,
								EntityId,@MasterSystemRefNo As SystemRefNo,@BankChargesCurrency,DocDate,DocDate,@RecOrder As RecOrder
						From Bean.Receipt(Nolock)
						Where Id=@SourceId
					End
					/* Creating Balancing Line Items */
					Insert Into @RecieptBalLnItm
					Select RBI.Id From Bean.ReceiptBalancingItem(Nolock) As RBI
					Inner Join bean.Receipt(Nolock) As R On R.Id=RBI.ReceiptId
					Where R.Id=@SourceId Order by RecOrder
					Set @Count=(Select Count(*) From @RecieptBalLnItm)
					Set @RecCount=1
					While @Count>=@RecCount
					Begin
						Select @RecieptBalId=RecieptBalId From @RecieptBalLnItm Where S_no=@RecCount
						Select @TaxId=TaxId,@TaxRate=TaxRate From Bean.ReceiptBalancingItem(Nolock) Where Id=@RecieptBalId
						Set @RecOrder=@RecOrder+1
						Insert Into Bean.JournalDetail (Id,JournalId,COAId,AccountDescription,AllowDisAllow,TaxId,TaxType,TaxRate,DocDebit,DocCredit,
													DocTaxDebit,DocTaxCredit,BaseDebit,BaseCredit,
													BaseTaxDebit,BaseTaxCredit,DocDebitTotal,DocCreditTotal,BaseDebitTotal,BaseCreditTotal,DocumentId,DocumentDetailId,ItemId,BaseCurrency,ExchangeRate,GSTExCurrency,GSTExchangeRate,DocType,DocSubType,ServiceCompanyId,DocNo, IsTax,
													EntityId, SystemRefNo, DocCurrency,DocDate, PostingDate,RecOrder,GSTTaxDebit,GSTTaxCredit,GSTDebit,GSTCredit)
						Select NEWID(),@MasterJournalId,RBi.COAId,R.Remarks,RBI.IsDisAllow,RBI.TaxId,RBI.TaxType,Rbi.TaxRate,Case When RBI.ReciveORPay=@Pay_Dr Then RBI.DocAmount End As DocDebit,Case When RBI.ReciveORPay=@Receive_Cr Then RBI.DocAmount End As DocCredit,
							Case When RBI.ReciveORPay=@Pay_Dr Then RBI.DocTaxAmount End As DocTaxDebdit,Case When RBI.ReciveORPay=@Receive_Cr Then RBI.DocTaxAmount End As DocTaxCredit,Case When RBI.ReciveORPay=@Pay_Dr Then Round(RBI.DocAmount * @MainExchangeRate,2) End As BaseDebit,
							Case When RBI.ReciveORPay=@Receive_Cr Then Round(RBI.DocAmount * @MainExchangeRate,2) End As BaseCredit,
							Case When RBI.ReciveORPay=@Pay_Dr Then Round(RBI.DocTaxAmount * @MainExchangeRate,2) End As BaseTaxDebdit,
							Case When RBI.ReciveORPay=@Receive_Cr Then Round(RBI.DocTaxAmount * @MainExchangeRate,2) End As BaseTaxCredit,0.00 As DocDebitTotal,0.00 As DocCreditTotal,0.00 As BaseDebitTotal,0.00 As BaseCreditTotal,R.Id As DocumentId,RBI.Id As DocumentDetailId,@GUIDZero,
							R.BaseCurrency,@MainExchangeRate As ExchangeRate,R.GSTExCurrency,R.GSTExchangeRate,@DocType,@DocSubType,ServiceCompanyId,DocNo,0 As IsTax,
							EntityId,@MasterSystemRefNo,@BankChargesCurrency,DocDate,DocDate,@RecOrder As RecOrder,
							Case When RBI.ReciveORPay=@Pay_Dr Then Round(RBI.DocAmount * Coalesce(R.GSTExchangeRate,@DefaultExchangeRate),2) End As GSTTaxDebit,
							Case When RBI.ReciveORPay=@Receive_Cr Then Round(RBI.DocAmount * Coalesce(R.GSTExchangeRate,@DefaultExchangeRate),2) End As GSTTaxCredit,
							Case When RBI.ReciveORPay=@Pay_Dr Then Round(RBI.DocTaxAmount * Coalesce(R.GSTExchangeRate,@DefaultExchangeRate),2) End As GSTDebit,
							Case When RBI.ReciveORPay=@Receive_Cr Then Round(RBI.DocTaxAmount * Coalesce(R.GSTExchangeRate,@DefaultExchangeRate),2) End As GSTCredit
						From Bean.Receipt(Nolock) As R
						Inner Join bean.ReceiptBalancingItem(Nolock) As RBI On RBI.ReceiptId=R.Id
						Where R.Id=@SourceId And Rbi.Id=@RecieptBalId
						-- Creating Tax Line Items
						If @GST Is Not Null And @GST=1 And @TaxId Is Not Null And (@TaxRate Is Not Null And @TaxRate<>0)
						Begin
							Set @TaxRecCount=@RecOrder+@Count
							Insert Into Bean.JournalDetail (Id,JournalId,COAId,AccountDescription,AllowDisAllow,TaxId,TaxType,TaxRate,DocDebit,DocCredit,
									 BaseDebit,BaseCredit,
									 DocDebitTotal,DocCreditTotal,BaseDebitTotal,BaseCreditTotal,DocumentId,DocumentDetailId,ItemId,BaseCurrency,ExchangeRate,GSTExCurrency,GSTExchangeRate,DocType,DocSubType,ServiceCompanyId,DocNo, IsTax,
									EntityId, SystemRefNo, DocCurrency,DocDate, PostingDate,RecOrder )
							Select NEWID(),@MasterJournalId,@TaxPayableGST_COAID as COAId,R.Remarks,RBI.IsDisAllow,RBI.TaxId,RBI.TaxType,Rbi.TaxRate,Case When RBI.ReciveORPay=@Pay_Dr Then RBI.DocTaxAmount End As DocDebit,Case When RBI.ReciveORPay=@Receive_Cr Then RBI.DocTaxAmount End As DocCredit,
								Case When RBI.ReciveORPay=@Pay_Dr Then Round(RBI.DocTaxAmount * @MainExchangeRate,2) End As BaseDebit,Case When RBI.ReciveORPay=@Receive_Cr Then Round(RBI.DocTaxAmount * @MainExchangeRate,2) End As BaseCredit,
								0.00 As DocDebitTotal,0.00 As DocCreditTotal,0.00 As BaseDebitTotal,0.00 As BaseCreditTotal,R.Id As DocumentId,RBI.Id As DocumentDetailId,@GUIDZero,
								R.BaseCurrency,@MainExchangeRate As ExchangeRate,R.GSTExCurrency,R.GSTExchangeRate,@DocType,@DocSubType,ServiceCompanyId,DocNo,1 As IsTax,
								EntityId,@MasterSystemRefNo,@BankChargesCurrency,DocDate,DocDate,@TaxRecCount As RecOrder
							From Bean.Receipt(Nolock) As R
							Inner Join bean.ReceiptBalancingItem(Nolock) As RBI On RBI.ReceiptId=R.Id
							Where R.Id=@SourceId And Rbi.Id=@RecieptBalId
						End
						Set @RecCount=@RecCount+1
					End
					-- ServComp Records
					Insert Into @ServCompaIdTbl
					Select Distinct RD.ServiceCompanyId From Bean.ReceiptDetail(Nolock) As RD
					Inner Join Bean.Receipt(Nolock) As R On RD.ReceiptId=R.Id 
					Where R.Id=@SourceId And RD.ReceiptAmount<>0 And RD.ServiceCompanyId<>@MasterServComp And ReceiptAmount<>0
					Set @Count=(Select Count(*) From @ServCompaIdTbl)
					Set @RecCount=1
					While @Count>=@RecCount
					Begin
						Select @ServCompId=SerCompId From @ServCompaIdTbl Where S_No=@RecCount
						Set @IntroCompCOAID=(Select COA.Id From Bean.ChartOfAccount(Nolock) As COA 
												Inner Join Bean.AccountType(Nolock) As ACT On ACT.Id=COA.AccountTypeId
												Where ACT.CompanyId=@CompanyId And ACT.Name=@IntercompClearingCOAName And COA.SubsidaryCompanyId=@ServCompId)
						Set @ClearingRecieptInvOrDNAmount=(Select Sum(Isnull(ReceiptAmount,0)) From bean.ReceiptDetail(Nolock) Where ReceiptId=@SourceId And ServiceCompanyId=@ServCompId And DocumentType In (@InvoiceDocument,@DebitNoteDocument))
						Set @ClearingRecieptBillAmount=(Select Sum(Isnull(ReceiptAmount,0)) From bean.ReceiptDetail(Nolock) Where ReceiptId=@SourceId And ServiceCompanyId=@ServCompId And DocumentType=@BillDocument) 
						Set @CreditNoteAmount=(Select Sum(Isnull(ReceiptAmount,0)) From Bean.ReceiptDetail(Nolock) Where ReceiptId=@SourceId And ServiceCompanyId=@ServCompId And DocumentType=@CreditNoteDocument)
						Set @CreditMemoAmount=(Select Sum(Isnull(ReceiptAmount,0)) From Bean.ReceiptDetail(Nolock) Where ReceiptId=@SourceId And ServiceCompanyId=@ServCompId And DocumentType=@CreditMemoDocument)
						IF @ClearingRecieptInvOrDNAmount Is null
						Begin
							Set @ClearingRecieptInvOrDNAmount =0
						End
						IF @ClearingRecieptBillAmount Is null
						Begin
							Set @ClearingRecieptBillAmount =0
						End

						IF @CreditNoteAmount Is null
						Begin
							Set @CreditNoteAmount =0
						End
						IF @CreditMemoAmount Is null
						Begin
							Set @CreditMemoAmount =0
						End
						-- Credit Amount
						IF @CreditMemoAmount Is Not Null And @CreditMemoAmount<>0
						Begin
							Set @RecOrder=@RecOrder+1
							Insert Into Bean.JournalDetail (Id,JournalId,COAId,AccountDescription, DocDebit,DocCredit,
														 BaseDebit,BaseCredit,
														 DocDebitTotal,DocCreditTotal,BaseDebitTotal,BaseCreditTotal,DocumentId,DocumentDetailId,ItemId,BaseCurrency,ExchangeRate, DocType,DocSubType,ServiceCompanyId,DocNo,Nature,OffsetDocument,IsTax,
														EntityId, SystemRefNo, DocCurrency,DocDate, PostingDate,RecOrder 
														)
							Select NEWID(),@MasterJournalId,@IntroCompCOAID,R.Remarks,Null As DocDebit,@CreditMemoAmount As DocCredit,
								Null As BaseDebit,Round(@CreditMemoAmount * @MainExchangeRate,2) As BaseCredit,
								0.00 As DocDebitTotal,0.00 As DocCreditTotal,0.00 As BaseDebitTotal,0.00 As BaseCreditTotal,R.Id As DocumentId,@GUIDZero As DocumentDetailId,@GUIDZero,
								R.BaseCurrency,@MainExchangeRate As ExchangeRate,@DocType,@DocSubType,@MasterServComp As ServiceCompanyId,R.DocNo,Null As Nature,R.DocNo,0 As IsTax,
								R.EntityId,@MasterSystemRefNo,@DocCurrency,R.DocDate,R.DocDate,@RecOrder As RecOrder
							From Bean.Receipt(Nolock) As R
							Where R.Id=@SourceId
						End
						-- CreditNote Amount
						IF @CreditNoteAmount Is Not Null And @CreditNoteAmount<>0
						Begin
							Set @RecOrder=@RecOrder+1
							Insert Into Bean.JournalDetail (Id,JournalId,COAId,AccountDescription, DocDebit,DocCredit,
														 BaseDebit,BaseCredit,
														 DocDebitTotal,DocCreditTotal,BaseDebitTotal,BaseCreditTotal,DocumentId,DocumentDetailId,ItemId,BaseCurrency,ExchangeRate, DocType,DocSubType,ServiceCompanyId,DocNo,Nature,OffsetDocument,IsTax,
														EntityId, SystemRefNo, DocCurrency,DocDate, PostingDate,RecOrder 
														)
							Select NEWID(),@MasterJournalId,@IntroCompCOAID,R.Remarks,@CreditNoteAmount As DocDebit,NUll As DocCredit,
								Round(@CreditNoteAmount * @MainExchangeRate,2) As BaseDebit,Null As BaseCredit,
								0.00 As DocDebitTotal,0.00 As DocCreditTotal,0.00 As BaseDebitTotal,0.00 As BaseCreditTotal,R.Id As DocumentId,@GUIDZero As DocumentDetailId,@GUIDZero,
								R.BaseCurrency,@MainExchangeRate As ExchangeRate,@DocType,@DocSubType,@MasterServComp As ServiceCompanyId,R.DocNo,Null As Nature,R.DocNo,0 As IsTax,
								R.EntityId,@MasterSystemRefNo,@DocCurrency,R.DocDate,R.DocDate,@RecOrder As RecOrder
							From Bean.Receipt(Nolock) As R
							Where R.Id=@SourceId
						End
						-- Invoice Or DebitNote Records
						IF (@ClearingRecieptInvOrDNAmount IS NOt Null And @ClearingRecieptInvOrDNAmount<>0) Or (@ClearingRecieptBillAmount	IS Not Null	And @ClearingRecieptBillAmount<>0)	
						Begin
							Set @RecOrder=@RecOrder+1
							Insert Into Bean.JournalDetail (Id,JournalId,COAId,AccountDescription, DocDebit,DocCredit,
															 BaseDebit,BaseCredit,
															 DocDebitTotal,DocCreditTotal,BaseDebitTotal,BaseCreditTotal,DocumentId,DocumentDetailId,ItemId,BaseCurrency,ExchangeRate, DocType,DocSubType,ServiceCompanyId,DocNo,Nature,OffsetDocument,IsTax,
															EntityId, SystemRefNo, DocCurrency,DocDate, PostingDate,RecOrder 
															)
							Select NEWID(),@MasterJournalId,@IntroCompCOAID,R.Remarks,
								Case When (@ClearingRecieptInvOrDNAmount-@ClearingRecieptBillAmount)<0 Then ABS(@ClearingRecieptInvOrDNAmount-@ClearingRecieptBillAmount) End As DocDebit,
								Case When (@ClearingRecieptInvOrDNAmount-@ClearingRecieptBillAmount)>0 Then ABS(@ClearingRecieptInvOrDNAmount-@ClearingRecieptBillAmount) End As DocCredit,
								Case When (@ClearingRecieptInvOrDNAmount-@ClearingRecieptBillAmount)<0 Then ABS(Round((@ClearingRecieptInvOrDNAmount-@ClearingRecieptBillAmount) * @MainExchangeRate,2)) End As BaseDebit,
								Case When (@ClearingRecieptInvOrDNAmount-@ClearingRecieptBillAmount)>0 Then ABS(Round((@ClearingRecieptInvOrDNAmount-@ClearingRecieptBillAmount) * @MainExchangeRate,2)) End As BaseCredit,
								0.00 As DocDebitTotal,0.00 As DocCreditTotal,0.00 As BaseDebitTotal,0.00 As BaseCreditTotal,R.Id As DocumentId,@GUIDZero As DocumentDetailId,@GUIDZero,
								R.BaseCurrency,@MainExchangeRate As ExchangeRate,@DocType,@DocSubType,@MasterServComp As ServiceCompanyId,R.DocNo,Null As Nature,R.DocNo,0 As IsTax,
								R.EntityId,@MasterSystemRefNo,@BankChargesCurrency,R.DocDate,R.DocDate,@RecOrder As RecOrder
							From Bean.Receipt(Nolock) As R
							Where R.Id=@SourceId
							Set @SysRefNum_Incr=@SysRefNum_Incr+1
							Set @SystemRefNo=CONCAT(@DocNo,'-JV',@SysRefNum_Incr)
							Set @JournalId=NEWID()
							Insert Into Bean.Journal (Id,CompanyId,DocDate,DocType,DocSubType,DocNo,ServiceCompanyId,SystemReferenceNo,IsNoSupportingDocs,NoSupportingDocument,DocCurrency,ExchangeRate,ExCurrency,ExDurationFrom,GSTExchangeRate,GSTExCurrency,GSTTotalAmount,DocumentState,IsNoSupportingDocument,IsGstSettings,IsMultiCurrency,IsAllowableNonAllowable,IsGSTCurrencyRateChanged,Remarks,UserCreated,CreatedDate,Status,DocumentDescription,CreationType,GrandDocDebitTotal,GrandDocCreditTotal,GrandBaseDebitTotal,
														GrandBaseCreditTotal,EntityId,EntityType,PostingDate,COAId,ModeOfReceipt,BankReceiptAmmount,ExcessPaidByClientAmmount,BalancingItemReciveCRAmount,  BalancingItemPayDRAmount,ReceiptApplicationAmmount,DocumentId, BankClearingDate ,IsBalancing,ISAllowDisAllow, IsShow, ActualSysRefNo 
														,IsSegmentReporting,TransferRefNo
													 )
							Select @JournalId,@CompanyId,DocDate,@DocType,@DocSubType,DocNo,@ServCompId As ServiceCompanyId,@SystemRefNo As SystemRefNo,IsNoSupportingDocument,NoSupportingDocs,DocCurrency,ExchangeRate,ExCurrency,ExDurationFrom,GSTExchangeRate,GSTExCurrency,Isnull(GSTTotalAmount,0),DocumentState,NoSupportingDocs,IsGstSettings,IsMultiCurrency,IsAllowableDisallowable,IsGSTCurrencyRateChanged,Remarks,@UserCreated,@CreatedDate,Status,Remarks As DocDescription,@UserCreated,GrandTotal,0.00 As GrandDocCreditTotal,GrandTotal * Round(ExchangeRate,2) As GrandBaseDebitTotal,
									0.00 As GrandBaseCreditTotal,EntityId,EntityType,DocDate As PostingDate,@IntroCompCOAID As COAId,ModeOfReceipt,0.00 As BankReceiptAmmount,0.00 As ExcessPaidByClientAmmount,0.00 As BalancingItemReciveCRAmount,0.00 As BalancingItemPayDRAmount,0.00 As ReceiptApplicationAmmount,Id As DocumentId,BankClearingDate,0 As IsBalancing,IsDisAllow,1 As IsShow,DocNo As ActualSysRefNo,0 As IsSegmentReporting,ReceiptRefNo
							From Bean.Receipt(Nolock) Where CompanyId=@CompanyId And Id=@SourceId
							Set @RecOrderAnotherJV=1
							Insert Into Bean.JournalDetail (Id,JournalId,COAId,AccountDescription, DocDebit,DocCredit,
															 BaseDebit,BaseCredit,
															 DocDebitTotal,DocCreditTotal,BaseDebitTotal,BaseCreditTotal,DocumentId,DocumentDetailId,ItemId,BaseCurrency,ExchangeRate, DocType,DocSubType,ServiceCompanyId,DocNo,Nature,OffsetDocument,IsTax,
															EntityId, SystemRefNo, DocCurrency,DocDate, PostingDate,RecOrder 
															)
							Select NEWID(),@JournalId,@MainInterCoServCompCOAID,R.Remarks,
								Case When (@ClearingRecieptInvOrDNAmount-@ClearingRecieptBillAmount)>0 Then ABS(@ClearingRecieptInvOrDNAmount-@ClearingRecieptBillAmount) End As DocDebit,
								Case When (@ClearingRecieptInvOrDNAmount-@ClearingRecieptBillAmount)<0 Then ABS(@ClearingRecieptInvOrDNAmount-@ClearingRecieptBillAmount) End As DocCredit,
								Case When (@ClearingRecieptInvOrDNAmount-@ClearingRecieptBillAmount)>0 Then ABS(Round((@ClearingRecieptInvOrDNAmount-@ClearingRecieptBillAmount) * @MainExchangeRate,2)) End As BaseDebit,
								Case When (@ClearingRecieptInvOrDNAmount-@ClearingRecieptBillAmount)<0 Then ABS(Round((@ClearingRecieptInvOrDNAmount-@ClearingRecieptBillAmount) * @MainExchangeRate,2)) End As BaseCredit,
								0.00 As DocDebitTotal,0.00 As DocCreditTotal,0.00 As BaseDebitTotal,0.00 As BaseCreditTotal,R.Id As DocumentId,@GUIDZero As DocumentDetailId,@GUIDZero,
								R.BaseCurrency,@MainExchangeRate As ExchangeRate,@DocType,@DocSubType,@ServCompId As ServiceCompanyId,R.DocNo,Null As Nature,R.DocNo,0 As IsTax,
								R.EntityId,@SystemRefNo,@DocCurrency,R.DocDate,R.DocDate,@RecOrderAnotherJV As RecOrder
							From Bean.Receipt(Nolock) As R Where Id=@SourceId
							-- Receipt Details		
							Delete From @RecieptDtl_New
							Insert Into @RecieptDtl_New 
							Select ROW_NUMBER() Over (Order By RD.id),RD.Id From Bean.ReceiptDetail(Nolock) As RD
							Inner Join Bean.Receipt(Nolock) As R On RD.ReceiptId=R.Id 
							Where R.Id=@SourceId And RD.ServiceCompanyId=@ServCompId And RD.ReceiptAmount<>0 And RD.DocumentType Not In (@CreditNoteDocument,@CreditMemoDocument) Order By RD.RecOrder
							Set @DtlCount=(Select Count(*) From @RecieptDtl_New)
							Set @RdtlRecCount=1
							While @DtlCount>=@RdtlRecCount
							Begin
								Set @RecieptDtlId=(Select RecieptDtlId From @RecieptDtl_New Where S_No=@RdtlRecCount)
								Set @DocumentId=(Select DocumentId From Bean.ReceiptDetail(Nolock) Where Id=@RecieptDtlId)
								Set @OffSetDocumentType=(Select DocumentType From Bean.ReceiptDetail(Nolock) Where Id=@RecieptDtlId)
								Set @IsRoundingAmount=0
								--Getting COAID By Checking Nature
								IF Exists (Select ID From Bean.ReceiptDetail(Nolock) Where id=@RecieptDtlId And Nature=@NatureTrade And DocumentType =@InvoiceDocument)
								Begin
									Set @COAID=(Select Id From Bean.ChartOfAccount(Nolock) Where CompanyId=@CompanyId And Name=@COATradeReceivables)
									Set @ExchangeRate=(Select ExchangeRate From Bean.Invoice(Nolock) Where Id=@DocumentId)
									IF Exists(Select Id From Bean.Invoice(Nolock) Where Id=@DocumentId And DocumentState In (@FullyApplied,@Fullypaid))
									Begin
										Set @IsRoundingAmount=1
									End
								End
								Else IF Exists (Select ID From Bean.ReceiptDetail(Nolock) Where id=@RecieptDtlId And Nature=@NatureOthers And DocumentType =@InvoiceDocument)
								Begin
									Set @ExchangeRate=(Select ExchangeRate From Bean.Invoice(Nolock) Where Id=@DocumentId)
									Set @COAID=(Select Id From Bean.ChartOfAccount(Nolock) Where CompanyId=@CompanyId And Name=@COAotherReceivables)
									IF Exists(Select Id From Bean.Invoice(Nolock) Where Id=@DocumentId And DocumentState In (@FullyApplied,@Fullypaid))
									Begin
										Set @IsRoundingAmount=1
									End
								End
								Else IF Exists (Select ID From Bean.ReceiptDetail(Nolock) Where id=@RecieptDtlId And Nature=@NatureTrade And DocumentType =@DebitNoteDocument)
								Begin
									Set @COAID=(Select Id From Bean.ChartOfAccount(Nolock) Where CompanyId=@CompanyId And Name=@COATradeReceivables)
									Set @ExchangeRate=(Select ExchangeRate From Bean.DebitNote(Nolock) Where Id=@DocumentId)
									IF Exists(Select Id From Bean.DebitNote(Nolock) Where Id=@DocumentId And DocumentState In (@FullyApplied,@Fullypaid))
									Begin
										Set @IsRoundingAmount=1
									End
								End
								Else IF Exists (Select ID From Bean.ReceiptDetail(Nolock) Where id=@RecieptDtlId And Nature=@NatureOthers And DocumentType =@DebitNoteDocument)
								Begin
									Set @ExchangeRate=(Select ExchangeRate From Bean.DebitNote(Nolock) Where Id=@DocumentId)
									Set @COAID=(Select Id From Bean.ChartOfAccount(Nolock) Where CompanyId=@CompanyId And Name=@COAotherReceivables)
									IF Exists(Select Id From Bean.DebitNote(Nolock) Where Id=@DocumentId And DocumentState In (@FullyApplied,@Fullypaid))
									Begin
										Set @IsRoundingAmount=1
									End
								End
								Else IF Exists (Select ID From Bean.ReceiptDetail(Nolock) Where id=@RecieptDtlId And DocumentType=@BillDocument And Nature=@NatureTrade)
								Begin
									Set @COAID=(Select Id From Bean.ChartOfAccount(Nolock) Where CompanyId=@CompanyId And Name=@COATradePayables)
									Set @ExchangeRate=(Select ExchangeRate From Bean.Bill(Nolock) Where Id=@DocumentId)
									IF Exists(Select Id From Bean.Bill(Nolock) Where Id=@DocumentId And DocumentState In (@FullyApplied,@Fullypaid))
									Begin
										Set @IsRoundingAmount=1
									End
								End
								Else IF Exists (Select ID From Bean.ReceiptDetail(Nolock) Where id=@RecieptDtlId And DocumentType=@BillDocument And Nature=@NatureOthers)
								Begin
									Set @COAID=(Select Id From Bean.ChartOfAccount(Nolock) Where CompanyId=@CompanyId And Name=@COAOtherPayables)
									Set @ExchangeRate=(Select ExchangeRate From Bean.Bill(Nolock) Where Id=@DocumentId)
									IF Exists(Select Id From Bean.Bill(Nolock) Where Id=@DocumentId And DocumentState In (@FullyApplied,@Fullypaid))
									Begin
										Set @IsRoundingAmount=1
									End
								End
								IF @IsRoundingAmount=1 And Exists (Select Amount From @RoundingAmountDetails Where DocumentId=@DocumentId And Amount Is Not Null And Amount<>'')
								Begin
									Set @DocAmount=(Select Amount From @RoundingAmountDetails Where DocumentId=@DocumentId)
								End
								Else
								Begin
									Set @DocAmount=0
								End

								IF (Coalesce(@OffSetDocumentType,'NULL')=@BillDocument)
								Begin
									Set @RecOrderAnotherJV=@RecOrderAnotherJV+1
									Insert Into Bean.JournalDetail (Id,JournalId,COAId,AccountDescription, DocDebit,DocCredit,
																	 BaseDebit,BaseCredit,
																	 DocDebitTotal,DocCreditTotal,BaseDebitTotal,BaseCreditTotal,DocumentId,DocumentDetailId,ItemId,BaseCurrency,ExchangeRate, DocType,DocSubType,ServiceCompanyId,DocNo,Nature,OffsetDocument,IsTax,
																	EntityId, SystemRefNo, DocCurrency,DocDate, PostingDate,RecOrder 
																	)
									Select NEWID(),@JournalId,@COAID,R.Remarks,RD.ReceiptAmount As DocDebit,Null As DocCredit,
										Round(RD.ReceiptAmount * @ExchangeRate,2)- Isnull(@DocAmount,0) As BaseDebit,Null As BaseCredit,
										0.00 As DocDebitTotal,0.00 As DocCreditTotal,0.00 As BaseDebitTotal,0.00 As BaseCreditTotal,R.Id As DocumentId,RD.Id As DocumentDetailId,@GUIDZero,
										R.BaseCurrency,@ExchangeRate As ExchangeRate,@DocType,@DocSubType,RD.ServiceCompanyId,R.DocNo,RD.Nature,Null As DocumentNo,0 As IsTax,
										R.EntityId,@SystemRefNo,@DocCurrency,R.DocDate,R.DocDate,@RecOrderAnotherJV As RecOrder
									From Bean.Receipt(Nolock) As R
									Inner Join bean.ReceiptDetail(Nolock) As RD On RD.ReceiptId=R.Id
									Where R.Id=@SourceId And RD.Id=@RecieptDtlId
									IF @MainExchangeRate-@ExchangeRate<>0
									Begin
										-- ExchangeGainOrLossRealised
										Set @RecOrderAnotherJV=@RecOrderAnotherJV+1
										Insert Into Bean.JournalDetail (Id,JournalId,COAId,AccountDescription, DocDebit,DocCredit,
																		 BaseDebit,BaseCredit,
																		 DocDebitTotal,DocCreditTotal,BaseDebitTotal,BaseCreditTotal,DocumentId,DocumentDetailId,ItemId,BaseCurrency,ExchangeRate, DocType,DocSubType,ServiceCompanyId,DocNo,Nature,OffsetDocument,IsTax,
																		EntityId, SystemRefNo, DocCurrency,DocDate, PostingDate,RecOrder 
																		)
										Select NEWID(),@JournalId,@ExchangeGainOrLossCOAID,R.Remarks,Null As DocDebit,Null As DocCredit,
											Case When (@MainExchangeRate-@ExchangeRate)>0 Then ABS(Round((@MainExchangeRate-@ExchangeRate) * RD.ReceiptAmount,2)) End As BaseDebit,
											Case When (@MainExchangeRate-@ExchangeRate)<0 Then ABS(Round((@MainExchangeRate-@ExchangeRate) * RD.ReceiptAmount,2)) End As BaseCredit,
											0.00 As DocDebitTotal,0.00 As DocCreditTotal,0.00 As BaseDebitTotal,0.00 As BaseCreditTotal,R.Id As DocumentId,RD.Id As DocumentDetailId,@GUIDZero,
											R.BaseCurrency,@ExchangeRate As ExchangeRate,@DocType,@DocSubType,RD.ServiceCompanyId,R.DocNo,Null As Nature,Null As DocumentNo,0 As IsTax,
											R.EntityId,@SystemRefNo,@DocCurrency,R.DocDate,R.DocDate,@RecOrderAnotherJV As RecOrder
										From Bean.Receipt(Nolock) As R
										Inner Join bean.ReceiptDetail(Nolock) As RD On RD.ReceiptId=R.Id
										Where R.Id=@SourceId And RD.Id=@RecieptDtlId
									End
								End
								Else
								Begin	
									Set @RecOrderAnotherJV=@RecOrderAnotherJV+1
									Insert Into Bean.JournalDetail (Id,JournalId,COAId,AccountDescription, DocDebit,DocCredit,
															 BaseDebit,BaseCredit,
															 DocDebitTotal,DocCreditTotal,BaseDebitTotal,BaseCreditTotal,DocumentId,DocumentDetailId,ItemId,BaseCurrency,ExchangeRate, DocType,DocSubType,ServiceCompanyId,DocNo,Nature,OffsetDocument,IsTax,
															EntityId, SystemRefNo, DocCurrency,DocDate, PostingDate,RecOrder 
															)
									Select NEWID(),@JournalId,@COAID,R.Remarks,Null As DocDebit,RD.ReceiptAmount As DocCredit,
										Null As BaseDebit,Round(RD.ReceiptAmount * @ExchangeRate,2)- Isnull(@DocAmount,0) As BaseCredit,
										0.00 As DocDebitTotal,0.00 As DocCreditTotal,0.00 As BaseDebitTotal,0.00 As BaseCreditTotal,R.Id As DocumentId,RD.Id As DocumentDetailId,@GUIDZero,
										R.BaseCurrency,@ExchangeRate As ExchangeRate,@DocType,@DocSubType,RD.ServiceCompanyId,R.DocNo,RD.Nature,RD.DocumentNo,0 As IsTax,
										R.EntityId,@SystemRefNo,@DocCurrency,R.DocDate,R.DocDate,@RecOrderAnotherJV As RecOrder
									From Bean.Receipt(Nolock) As R
									Inner Join bean.ReceiptDetail(Nolock) As RD On RD.ReceiptId=R.Id
									Where R.Id=@SourceId And RD.Id=@RecieptDtlId
									IF @MainExchangeRate-@ExchangeRate<>0
									Begin
										-- ExchangeGainOrLossRealised
										Set @RecOrderAnotherJV=@RecOrderAnotherJV+1
										Insert Into Bean.JournalDetail (Id,JournalId,COAId,AccountDescription, DocDebit,DocCredit,
																		 BaseDebit,BaseCredit,
																		 DocDebitTotal,DocCreditTotal,BaseDebitTotal,BaseCreditTotal,DocumentId,DocumentDetailId,ItemId,BaseCurrency,ExchangeRate, DocType,DocSubType,ServiceCompanyId,DocNo,Nature,OffsetDocument,IsTax,
																		EntityId, SystemRefNo, DocCurrency,DocDate, PostingDate,RecOrder 
																		)
										Select NEWID(),@JournalId,@ExchangeGainOrLossCOAID,R.Remarks,Null As DocDebit,Null As DocCredit,
											Case When (@MainExchangeRate-@ExchangeRate)<0 Then ABS(Round((@MainExchangeRate-@ExchangeRate) * RD.ReceiptAmount,2)) End As BaseDebit,
											Case When (@MainExchangeRate-@ExchangeRate)>0 Then ABS(Round((@MainExchangeRate-@ExchangeRate) * RD.ReceiptAmount,2)) End As BaseCredit,
											0.00 As DocDebitTotal,0.00 As DocCreditTotal,0.00 As BaseDebitTotal,0.00 As BaseCreditTotal,R.Id As DocumentId,RD.Id As DocumentDetailId,@GUIDZero,
											R.BaseCurrency,@ExchangeRate As ExchangeRate,@DocType,@DocSubType,RD.ServiceCompanyId,R.DocNo,Null As Nature,Null As DocumentNo,0 As IsTax,
											R.EntityId,@SystemRefNo,@DocCurrency,R.DocDate,R.DocDate,@RecOrderAnotherJV As RecOrder
										From Bean.Receipt(Nolock) As R
										Inner Join bean.ReceiptDetail(Nolock) As RD On RD.ReceiptId=R.Id
										Where R.Id=@SourceId And RD.Id=@RecieptDtlId
									End
								End
								Set @RdtlRecCount=@RdtlRecCount+1
							End
						End
						Set @RecCount=@RecCount+1
					End
					-- Credit Note Jv for master service company
					IF Exists (Select Id From Bean.ReceiptDetail(Nolock) Where ReceiptId=@SourceId And ServiceCompanyId=@MasterServComp And DocumentType =@CreditNoteDocument)
					Begin
						Set @RecOrder=@RecOrder+1
						Set @CreditNoteAmount=(Select Sum(Isnull(ReceiptAmount,0)) From Bean.ReceiptDetail(Nolock) Where ReceiptId=@SourceId And ServiceCompanyId=@MasterServComp And DocumentType =@CreditNoteDocument)
						Insert Into Bean.JournalDetail (Id,JournalId,COAId,AccountDescription, DocDebit,DocCredit,
																 BaseDebit,BaseCredit,
																 DocDebitTotal,DocCreditTotal,BaseDebitTotal,BaseCreditTotal,DocumentId,DocumentDetailId,ItemId,BaseCurrency,ExchangeRate, DocType,DocSubType,ServiceCompanyId,DocNo,Nature,OffsetDocument,IsTax,
																EntityId, SystemRefNo, DocCurrency,DocDate, PostingDate,RecOrder 
																)
						Select NEWID(),@MasterJournalId,@ClearingReceiptsCOAID,R.Remarks,@CreditNoteAmount As DocDebit,Null As DocCredit,
							Round(@CreditNoteAmount * @MainExchangeRate,2) As BaseDebit, Null As BaseCredit,
							0.00 As DocDebitTotal,0.00 As DocCreditTotal,0.00 As BaseDebitTotal,0.00 As BaseCreditTotal,R.Id As DocumentId,@GUIDZero As DocumentDetailId,@GUIDZero,
							R.BaseCurrency,@MainExchangeRate As ExchangeRate,@DocType,@DocSubType,ServiceCompanyId As ServiceCompanyId,R.DocNo,Null As Nature,R.DocNo,0 As IsTax,
							R.EntityId,@MasterSystemRefNo,@BankChargesCurrency,R.DocDate,R.DocDate,@RecOrder As RecOrder
						From Bean.Receipt(Nolock) As R
						Where R.Id=@SourceId
					End
					-- Credit Memo Jv for master service company
					IF Exists (Select Id From Bean.ReceiptDetail(Nolock) Where ReceiptId=@SourceId And ServiceCompanyId=@MasterServComp And DocumentType =@CreditMemoDocument)
					Begin
						Set @RecOrder=@RecOrder+1
						Set @creditmemoAmount=(Select Sum(Isnull(ReceiptAmount,0)) From Bean.ReceiptDetail(Nolock) Where ReceiptId=@SourceId And ServiceCompanyId=@MasterServComp And DocumentType =@CreditMemoDocument)
						Insert Into Bean.JournalDetail (Id,JournalId,COAId,AccountDescription, DocDebit,DocCredit,
																 BaseDebit,BaseCredit,
																 DocDebitTotal,DocCreditTotal,BaseDebitTotal,BaseCreditTotal,DocumentId,DocumentDetailId,ItemId,BaseCurrency,ExchangeRate, DocType,DocSubType,ServiceCompanyId,DocNo,Nature,OffsetDocument,IsTax,
																EntityId, SystemRefNo, DocCurrency,DocDate, PostingDate,RecOrder 
																)
						Select NEWID(),@MasterJournalId,@ClearingReceiptsCOAID,R.Remarks,Null As DocDebit,@creditmemoAmount As DocCredit,
							Null As BaseDebit,Round(@creditmemoAmount * @MainExchangeRate,2) As BaseCredit,
							0.00 As DocDebitTotal,0.00 As DocCreditTotal,0.00 As BaseDebitTotal,0.00 As BaseCreditTotal,R.Id As DocumentId,@GUIDZero As DocumentDetailId,@GUIDZero,
							R.BaseCurrency,@MainExchangeRate As ExchangeRate,@DocType,@DocSubType,ServiceCompanyId As ServiceCompanyId,R.DocNo,Null As Nature,R.DocNo,0 As IsTax,
							R.EntityId,@MasterSystemRefNo,@BankChargesCurrency,R.DocDate,R.DocDate,@RecOrder As RecOrder
						From Bean.Receipt(Nolock) As R
						Where R.Id=@SourceId
					End
					-- Creating Records For Interco In Journal Detail
					Insert Into @RecieptDtl 
					Select RD.Id From Bean.ReceiptDetail(Nolock) As RD
					Inner Join Bean.Receipt(Nolock) As R On RD.ReceiptId=R.Id 
					Where R.Id=@SourceId And RD.ReceiptAmount<>0 And RD.ServiceCompanyId=@MasterServComp And RD.DocumentType Not In (@CreditMemoDocument,@CreditNoteDocument) Order By RD.RecOrder 
					Set @Count=(Select Count(*) From @RecieptDtl)
					--Set @RecOrder=2
					Set @RecCount=1
					While @Count>=@RecCount
					Begin
						Set @RecieptDtlId=(Select RecieptDtlId From @RecieptDtl Where S_No=@RecCount)
						Set @DocumentId=(Select DocumentId From Bean.ReceiptDetail(Nolock) Where Id=@RecieptDtlId)
						Set @OffSetDocumentType=(Select DocumentType From Bean.ReceiptDetail(Nolock) Where Id=@RecieptDtlId)
						Set @IsRoundingAmount=0
						--Getting COAID By Checking Nature
						IF Exists (Select ID From Bean.ReceiptDetail(Nolock) Where id=@RecieptDtlId And Nature=@NatureTrade And DocumentType=@InvoiceDocument)
						Begin
							Set @COAID=(Select Id From Bean.ChartOfAccount(Nolock) Where CompanyId=@CompanyId And Name=@COATradeReceivables)
							Set @ExchangeRate=(Select ExchangeRate From Bean.Invoice(Nolock) Where Id=@DocumentId)
							IF Exists(Select Id From Bean.Invoice(Nolock) Where Id=@DocumentId And DocumentState In (@FullyApplied,@Fullypaid))
							Begin
								Set @IsRoundingAmount=1
							End
						End
						Else IF Exists (Select ID From Bean.ReceiptDetail(Nolock) Where id=@RecieptDtlId And Nature=@NatureOthers And DocumentType=@InvoiceDocument)
						Begin
							Set @COAID=(Select Id From Bean.ChartOfAccount(Nolock) Where CompanyId=@CompanyId And Name=@COAotherReceivables )
							Set @ExchangeRate=(Select ExchangeRate From Bean.Invoice(Nolock) Where Id=@DocumentId)
							IF Exists(Select Id From Bean.Invoice(Nolock) Where Id=@DocumentId And DocumentState In (@FullyApplied,@Fullypaid))
							Begin
								Set @IsRoundingAmount=1
							End
						End
						Else IF Exists (Select ID From Bean.ReceiptDetail(Nolock) Where id=@RecieptDtlId And Nature=@NatureTrade And DocumentType=@DebitNoteDocument)
						Begin
							Set @COAID=(Select Id From Bean.ChartOfAccount(Nolock) Where CompanyId=@CompanyId And Name=@COATradeReceivables)
							Set @ExchangeRate=(Select ExchangeRate From Bean.DebitNote(Nolock) Where Id=@DocumentId)
							IF Exists(Select Id From Bean.DebitNote(Nolock) Where Id=@DocumentId And DocumentState In (@FullyApplied,@Fullypaid))
							Begin
								Set @IsRoundingAmount=1
							End
						End
						Else IF Exists (Select ID From Bean.ReceiptDetail(Nolock) Where id=@RecieptDtlId And Nature=@NatureOthers And DocumentType=@DebitNoteDocument)
						Begin
							Set @COAID=(Select Id From Bean.ChartOfAccount(Nolock) Where CompanyId=@CompanyId And Name=@COAotherReceivables )
							Set @ExchangeRate=(Select ExchangeRate From Bean.DebitNote(Nolock) Where Id=@DocumentId)
							IF Exists(Select Id From Bean.DebitNote(Nolock) Where Id=@DocumentId And DocumentState In (@FullyApplied,@Fullypaid))
							Begin
								Set @IsRoundingAmount=1
							End
						End
						Else IF Exists (Select ID From Bean.ReceiptDetail(Nolock) Where id=@RecieptDtlId And DocumentType=@BillDocument And Nature=@NatureTrade)
						Begin
							Set @COAID=(Select Id From Bean.ChartOfAccount(Nolock) Where CompanyId=@CompanyId And Name=@COATradePayables)
							Set @ExchangeRate=(Select ExchangeRate From Bean.Bill(Nolock) Where Id=@DocumentId)
							IF Exists(Select Id From Bean.Bill(Nolock) Where Id=@DocumentId And DocumentState In (@FullyApplied,@Fullypaid))
							Begin
								Set @IsRoundingAmount=1
							End
						End
						Else IF Exists (Select ID From Bean.ReceiptDetail(Nolock) Where id=@RecieptDtlId And DocumentType=@BillDocument And Nature=@NatureOthers)
						Begin
							Set @COAID=(Select Id From Bean.ChartOfAccount(Nolock) Where CompanyId=@CompanyId And Name=@COAOtherPayables)
							Set @ExchangeRate=(Select ExchangeRate From Bean.Bill(Nolock) Where Id=@DocumentId)
							IF Exists(Select Id From Bean.Bill(Nolock) Where Id=@DocumentId And DocumentState In (@FullyApplied,@Fullypaid))
							Begin
								Set @IsRoundingAmount=1
							End
						End
						
						IF @IsRoundingAmount=1 And Exists (Select Amount From @RoundingAmountDetails Where DocumentId=@DocumentId And Amount Is Not Null And Amount<>'')
						Begin
							Set @DocAmount=(Select Amount From @RoundingAmountDetails Where DocumentId=@DocumentId)
						End
						Else
						Begin
							Set @DocAmount=0
						End
						IF Coalesce(@OffSetDocumentType,'NULL')=@BillDocument
						Begin
							Set @RecOrder=@RecOrder+1
							Insert Into Bean.JournalDetail (Id,JournalId,COAId,AccountDescription, DocDebit,DocCredit,
															 BaseDebit,BaseCredit,
															 DocDebitTotal,DocCreditTotal,BaseDebitTotal,BaseCreditTotal,DocumentId,DocumentDetailId,ItemId,BaseCurrency,ExchangeRate, DocType,DocSubType,ServiceCompanyId,DocNo,Nature,OffsetDocument,IsTax,
															EntityId, SystemRefNo, DocCurrency,DocDate, PostingDate,RecOrder 
															)
							Select NEWID(),@MasterJournalId,@COAID,R.Remarks,RD.ReceiptAmount As DocDebit,Null As DocCredit,
								Round(RD.ReceiptAmount * @ExchangeRate,2)- Isnull(@DocAmount,0) As BaseDebit,Null As BaseCredit,
								0.00 As DocDebitTotal,0.00 As DocCreditTotal,0.00 As BaseDebitTotal,0.00 As BaseCreditTotal,R.Id As DocumentId,RD.Id As DocumentDetailId,@GUIDZero,
								R.BaseCurrency,@ExchangeRate,@DocType,@DocSubType,@MasterServComp As ServiceCompanyId,R.DocNo,RD.Nature,Null As DocumentNo,0 As IsTax,
								R.EntityId,@MasterSystemRefNo,@DocCurrency,R.DocDate,R.DocDate,@RecOrder As RecOrder
							From Bean.Receipt(Nolock) As R
							Inner Join bean.ReceiptDetail(Nolock) As RD On RD.ReceiptId=R.Id
							Where R.Id=@SourceId And RD.Id=@RecieptDtlId
							IF @MainExchangeRate-@ExchangeRate<>0
							Begin
								-- ExchangeGainOrLossRealised
								Set @RecOrder= @RecOrder + 1
								Insert Into Bean.JournalDetail (Id,JournalId,COAId,AccountDescription, DocDebit,DocCredit,
																 BaseDebit,BaseCredit,
																 DocDebitTotal,DocCreditTotal,BaseDebitTotal,BaseCreditTotal,DocumentId,DocumentDetailId,ItemId,BaseCurrency,ExchangeRate, DocType,DocSubType,ServiceCompanyId,DocNo,Nature,OffsetDocument,IsTax,
																EntityId, SystemRefNo, DocCurrency,DocDate, PostingDate,RecOrder 
																)
								Select NEWID(),@MasterJournalId,@ExchangeGainOrLossCOAID,R.Remarks,Null As DocDebit,Null As DocCredit,
									Case When (@MainExchangeRate-@ExchangeRate)>0 Then ABS(Round((@MainExchangeRate-@ExchangeRate) * RD.ReceiptAmount,2)) End As BaseDebit,
									Case When (@MainExchangeRate-@ExchangeRate)<0 Then ABS(Round((@MainExchangeRate-@ExchangeRate) * RD.ReceiptAmount,2)) End As BaseCredit,
									0.00 As DocDebitTotal,0.00 As DocCreditTotal,0.00 As BaseDebitTotal,0.00 As BaseCreditTotal,R.Id As DocumentId,RD.Id As DocumentDetailId,@GUIDZero,
									R.BaseCurrency,@ExchangeRate,@DocType,@DocSubType,@MasterServComp As ServiceCompanyId,R.DocNo,RD.Nature,Null As DocumentNo,0 As IsTax,
									R.EntityId,@MasterSystemRefNo,@DocCurrency,R.DocDate,R.DocDate,@RecOrder As RecOrder
								From Bean.Receipt(Nolock) As R
								Inner Join bean.ReceiptDetail(Nolock) As RD On RD.ReceiptId=R.Id
								Where R.Id=@SourceId And RD.Id=@RecieptDtlId
							End
						End
						Else
						Begin
							Set @RecOrder=@RecOrder+1
							Insert Into Bean.JournalDetail (Id,JournalId,COAId,AccountDescription, DocDebit,DocCredit,
													 BaseDebit,BaseCredit,
													 DocDebitTotal,DocCreditTotal,BaseDebitTotal,BaseCreditTotal,DocumentId,DocumentDetailId,ItemId,BaseCurrency,ExchangeRate, DocType,DocSubType,ServiceCompanyId,DocNo,Nature,OffsetDocument,IsTax,
													EntityId, SystemRefNo, DocCurrency,DocDate, PostingDate,RecOrder 
													)
							Select NEWID(),@MasterJournalId,@COAID,R.Remarks,Null As DocDebit,RD.ReceiptAmount As DocCredit,
								Null As BaseDebit,Round(RD.ReceiptAmount * @ExchangeRate,2)- Isnull(@DocAmount,0) As BaseCredit,
								0.00 As DocDebitTotal,0.00 As DocCreditTotal,0.00 As BaseDebitTotal,0.00 As BaseCreditTotal,R.Id As DocumentId,RD.Id As DocumentDetailId,@GUIDZero,
								R.BaseCurrency,@ExchangeRate,@DocType,@DocSubType,@MasterServComp As ServiceCompanyId,R.DocNo,RD.Nature,RD.DocumentNo,0 As IsTax,
								R.EntityId,@MasterSystemRefNo,@DocCurrency,R.DocDate,R.DocDate,@RecOrder As RecOrder
							From Bean.Receipt(Nolock) As R
							Inner Join bean.ReceiptDetail(Nolock) As RD On RD.ReceiptId=R.Id
							Where R.Id=@SourceId And RD.Id=@RecieptDtlId
							IF @MainExchangeRate-@ExchangeRate<>0
							Begin
								-- ExchangeGainOrLossRealised
								Set @RecOrder= @RecOrder + 1
								Insert Into Bean.JournalDetail (Id,JournalId,COAId,AccountDescription, DocDebit,DocCredit,
																 BaseDebit,BaseCredit,
																 DocDebitTotal,DocCreditTotal,BaseDebitTotal,BaseCreditTotal,DocumentId,DocumentDetailId,ItemId,BaseCurrency,ExchangeRate, DocType,DocSubType,ServiceCompanyId,DocNo,Nature,OffsetDocument,IsTax,
																EntityId, SystemRefNo, DocCurrency,DocDate, PostingDate,RecOrder 
																)
								Select NEWID(),@MasterJournalId,@ExchangeGainOrLossCOAID,R.Remarks,Null As DocDebit,Null As DocCredit,
									Case When (@MainExchangeRate-@ExchangeRate)<0 Then ABS(Round((@MainExchangeRate-@ExchangeRate) * RD.ReceiptAmount,2)) End As BaseDebit,
									Case When (@MainExchangeRate-@ExchangeRate)>0 Then ABS(Round((@MainExchangeRate-@ExchangeRate) * RD.ReceiptAmount,2)) End As BaseCredit,
									0.00 As DocDebitTotal,0.00 As DocCreditTotal,0.00 As BaseDebitTotal,0.00 As BaseCreditTotal,R.Id As DocumentId,RD.Id As DocumentDetailId,@GUIDZero,
									R.BaseCurrency,@ExchangeRate,@DocType,@DocSubType,@MasterServComp As ServiceCompanyId,R.DocNo,RD.Nature,Null As DocumentNo,0 As IsTax,
									R.EntityId,@MasterSystemRefNo,@DocCurrency,R.DocDate,R.DocDate,@RecOrder As RecOrder
								From Bean.Receipt(Nolock) As R
								Inner Join bean.ReceiptDetail(Nolock) As RD On RD.ReceiptId=R.Id
								Where R.Id=@SourceId And RD.Id=@RecieptDtlId
							End
						End
						Set @RecCount=@RecCount+1
					End
				End
				Else IF @DocCurrency<>@BankChargesCurrency And @BaseCurrency=@DocCurrency
				Begin
					/* Creating Mater record In JournalDetail */
					IF Exists (Select Id From Bean.Receipt(Nolock) Where Id=@SourceId And GrandTotal<>0)
					Begin
						Set @RecOrder=@RecOrder+1
						Insert Into Bean.JournalDetail (Id,JournalId,COAId,AccountDescription,AllowDisAllow, DocDebit, BaseDebit, DocDebitTotal,DocCreditTotal,BaseDebitTotal,BaseCreditTotal,DocumentId,DocumentDetailId,ItemId,BaseCurrency,ExchangeRate,GSTExCurrency,GSTExchangeRate,DocType,DocSubType,ServiceCompanyId,DocNo, IsTax,
										EntityId, SystemRefNo, DocCurrency,DocDate, PostingDate,RecOrder )
						Select NEWID(),@MasterJournalId,COAId,Remarks,IsDisAllow,BankReceiptAmmount,Round(BankReceiptAmmount * @SysCalExchangerate,2),0.00 As DocDebitTotal,0.00 As DocCreditTotal,0.00 As BaseDebitTotal,0.00 As BaseCreditTotal,Id As DocumentId,@GUIDZero,@GUIDZero,
								BaseCurrency,@SysCalExchangerate As ExchangeRate,GSTExCurrency,GSTExchangeRate,@DocType,@DocSubType,ServiceCompanyId,DocNo,0 As IsTax,
								EntityId,@MasterSystemRefNo As SystemRefNo,@BankChargesCurrency,DocDate,DocDate,@RecOrder As RecOrder
						From Bean.Receipt(Nolock) Where Id=@SourceId
					End
					Else IF Exists (Select Id From Bean.Receipt(Nolock) Where Id=@SourceId And GrandTotal=0 And BankReceiptAmmount<>0)
					Begin
						Set @RecOrder=@RecOrder+1
						Insert Into Bean.JournalDetail (Id,JournalId,COAId,AccountDescription,AllowDisAllow, DocDebit, BaseDebit, DocDebitTotal,DocCreditTotal,BaseDebitTotal,BaseCreditTotal,DocumentId,DocumentDetailId,ItemId,BaseCurrency,ExchangeRate,GSTExCurrency,GSTExchangeRate,DocType,DocSubType,ServiceCompanyId,DocNo, IsTax,
										EntityId, SystemRefNo, DocCurrency,DocDate, PostingDate,RecOrder )
						Select NEWID(),@MasterJournalId,COAId,Remarks,IsDisAllow,Isnull(BankReceiptAmmount,0) As BankReceiptAmmount,Round(Isnull(BankReceiptAmmount,0) * @SysCalExchangerate,2),0.00 As DocDebitTotal,0.00 As DocCreditTotal,0.00 As BaseDebitTotal,0.00 As BaseCreditTotal,Id As DocumentId,@GUIDZero,@GUIDZero,
								BaseCurrency,@SysCalExchangerate As ExchangeRate,GSTExCurrency,GSTExchangeRate,@DocType,@DocSubType,ServiceCompanyId,DocNo,0 As IsTax,
								EntityId,@MasterSystemRefNo As SystemRefNo,@BankChargesCurrency,DocDate,DocDate,@RecOrder As RecOrder
						From Bean.Receipt(Nolock) Where Id=@SourceId
					End
					/* Creating Record in Journaldetail With Bank Charges Amount */
					If Exists(Select Id From Bean.Receipt(Nolock) Where Id=@SourceId And BankCharges Is Not Null)
					Begin
						Insert Into Bean.JournalDetail (Id,JournalId,COAId,AccountDescription,AllowDisAllow,TaxId,TaxType,TaxRate,DocDebit, BaseDebit, DocDebitTotal,DocCreditTotal,BaseDebitTotal,BaseCreditTotal,DocumentId,DocumentDetailId,ItemId,BaseCurrency,ExchangeRate,GSTExCurrency,GSTExchangeRate,DocType,DocSubType,ServiceCompanyId,DocNo, IsTax,
													EntityId, SystemRefNo, DocCurrency,DocDate, PostingDate,RecOrder,GSTTaxDebit)
						Select NEWID(),@MasterJournalId,@BankCharges_COAId,Remarks,IsDisAllow,@TaxId,@TaxType,@TaxRate,BankCharges,Round(BankCharges * @SysCalExchangerate,2),0.00 As DocDebitTotal,0.00 As DocCreditTotal,0.00 As BaseDebitTotal,0.00 As BaseCreditTotal,Id As DocumentId,Id As DocumentDetailId,@GUIDZero,
							BaseCurrency,@SysCalExchangerate,GSTExCurrency,GSTExchangeRate,@DocType,@DocSubType,ServiceCompanyId,DocNo,0 As IsTax,
							EntityId,@MasterSystemRefNo As SystemRefNo,@BankChargesCurrency,DocDate,DocDate,@RecOrder As RecOrder,
							Case When @TaxId Is Not Null Then Round(BankCharges * Coalesce(GSTexchangerate,@DefaultExchangeRate),2) End As GSTTaxDebit
						From Bean.Receipt(Nolock)
						Where Id=@SourceId
					End
					/* Creating Record in Journaldetail With ExcesPaidByClientAmt Amount */
					If @ExcesPaidByClientAmt Is NOt Null
					Begin
						Set @RecOrder=@RecOrder+1
						Insert Into Bean.JournalDetail (Id,JournalId,COAId,AccountDescription,AllowDisAllow, DocCredit, BaseCredit, DocDebitTotal,DocCreditTotal,BaseDebitTotal,BaseCreditTotal,DocumentId,DocumentDetailId,ItemId,BaseCurrency,ExchangeRate,GSTExCurrency,GSTExchangeRate,DocType,DocSubType,ServiceCompanyId,DocNo, IsTax,
														EntityId, SystemRefNo, DocCurrency,DocDate, PostingDate,RecOrder )
						Select NEWID(),@MasterJournalId,@ClearingReceiptsCOAID,Remarks,IsDisAllow,ExcessPaidByClientAmmount,Round(ExcessPaidByClientAmmount * @SysCalExchangerate,2),0.00 As DocDebitTotal,0.00 As DocCreditTotal,0.00 As BaseDebitTotal,0.00 As BaseCreditTotal,Id As DocumentId,Id As DocumentDtlId,@GUIDZero,
								BaseCurrency,@SysCalExchangerate,BankReceiptAmmountCurrency,ExchangeRate,@DocType,@DocSubType,ServiceCompanyId,DocNo,0 As IsTax,
								EntityId,@MasterSystemRefNo,@BankChargesCurrency,DocDate,DocDate,@RecOrder As RecOrder
						From Bean.Receipt(Nolock) 
						Where Id=@SourceId
					End
					/* Creating Balancing Line Items */
					Insert Into @RecieptBalLnItm
					Select RBI.Id From Bean.ReceiptBalancingItem(Nolock) As RBI
					Inner Join bean.Receipt(Nolock) As R On R.Id=RBI.ReceiptId
					Where R.Id=@SourceId Order by RecOrder
					Set @Count=(Select Count(*) From @RecieptBalLnItm)
					Set @RecCount=1
					While @Count>=@RecCount
					Begin
						Select @RecieptBalId=RecieptBalId From @RecieptBalLnItm Where S_no=@RecCount
						Select @TaxId=TaxId,@TaxRate=TaxRate From Bean.ReceiptBalancingItem(Nolock) Where Id=@RecieptBalId
						Set @RecOrder=@RecOrder+1
						Insert Into Bean.JournalDetail (Id,JournalId,COAId,AccountDescription,AllowDisAllow,TaxId,TaxType,TaxRate,DocDebit,DocCredit,
													DocTaxDebit,DocTaxCredit,BaseDebit,BaseCredit,
													BaseTaxDebit,BaseTaxCredit,DocDebitTotal,DocCreditTotal,BaseDebitTotal,BaseCreditTotal,DocumentId,DocumentDetailId,ItemId,BaseCurrency,ExchangeRate,GSTExCurrency,GSTExchangeRate,DocType,DocSubType,ServiceCompanyId,DocNo, IsTax,
													EntityId, SystemRefNo, DocCurrency,DocDate, PostingDate,RecOrder,GSTTaxDebit,GSTTaxCredit,GSTDebit,GSTCredit)
						Select NEWID(),@MasterJournalId,RBi.COAId,R.Remarks,RBI.IsDisAllow,RBI.TaxId,RBI.TaxType,Rbi.TaxRate,Case When RBI.ReciveORPay=@Pay_Dr Then RBI.DocAmount End As DocDebit,Case When RBI.ReciveORPay=@Receive_Cr Then RBI.DocAmount End As DocCredit,
							Case When RBI.ReciveORPay=@Pay_Dr Then RBI.DocTaxAmount End As DocTaxDebdit,Case When RBI.ReciveORPay=@Receive_Cr Then RBI.DocTaxAmount End As DocTaxCredit,
							Case When RBI.ReciveORPay=@Pay_Dr Then Round(RBI.DocAmount * @SysCalExchangerate,2) End As BaseDebit,
							Case When RBI.ReciveORPay=@Receive_Cr Then Round(RBI.DocAmount * @SysCalExchangerate,2) End As BaseCredit,
							Case When RBI.ReciveORPay=@Pay_Dr Then Round(RBI.DocTaxAmount * @SysCalExchangerate,2) End As BaseTaxDebdit,
							Case When RBI.ReciveORPay=@Receive_Cr Then Round(RBI.DocTaxAmount * @SysCalExchangerate,2) End As BaseTaxCredit,0.00 As DocDebitTotal,0.00 As DocCreditTotal,0.00 As BaseDebitTotal,0.00 As BaseCreditTotal,R.Id As DocumentId,RBI.Id As DocumentDetailId,@GUIDZero,
							R.BaseCurrency,@SysCalExchangerate As ExchangeRate,R.GSTExCurrency,R.GSTExchangeRate,@DocType,@DocSubType,ServiceCompanyId,DocNo,0 As IsTax,
							EntityId,@MasterSystemRefNo,@BankChargesCurrency,DocDate,DocDate,@RecOrder As RecOrder,
							Case When RBI.ReciveORPay=@Pay_Dr Then Round(RBI.DocAmount * Coalesce(R.GSTExchangeRate,@DefaultExchangeRate),2) End As GSTTaxDebit,
							Case When RBI.ReciveORPay=@Receive_Cr Then Round(RBI.DocAmount * Coalesce(R.GSTExchangeRate,@DefaultExchangeRate),2) End As GSTTaxCredit,
							Case When RBI.ReciveORPay=@Pay_Dr Then Round(RBI.DocTaxAmount * Coalesce(R.GSTExchangeRate,@DefaultExchangeRate),2) End As GSTDebit,
							Case When RBI.ReciveORPay=@Receive_Cr Then Round(RBI.DocTaxAmount * Coalesce(R.GSTExchangeRate,@DefaultExchangeRate),2) End As GSTCredit
						From Bean.Receipt(Nolock) As R
						Inner Join bean.ReceiptBalancingItem(Nolock) As RBI On RBI.ReceiptId=R.Id
						Where R.Id=@SourceId And Rbi.Id=@RecieptBalId
						-- Creating Tax Line Items
						If @GST Is Not Null And @GST=1 And @TaxId Is Not Null And (@TaxRate Is Not Null And @TaxRate<>0)
						Begin
							Set @TaxRecCount=@RecOrder+@Count
							Insert Into Bean.JournalDetail (Id,JournalId,COAId,AccountDescription,AllowDisAllow,TaxId,TaxType,TaxRate,DocDebit,DocCredit,
									 BaseDebit,BaseCredit,
									 DocDebitTotal,DocCreditTotal,BaseDebitTotal,BaseCreditTotal,DocumentId,DocumentDetailId,ItemId,BaseCurrency,ExchangeRate,GSTExCurrency,GSTExchangeRate,DocType,DocSubType,ServiceCompanyId,DocNo, IsTax,
									EntityId, SystemRefNo, DocCurrency,DocDate, PostingDate,RecOrder )
							Select NEWID(),@MasterJournalId,@TaxPayableGST_COAID as COAId,R.Remarks,RBI.IsDisAllow,RBI.TaxId,RBI.TaxType,Rbi.TaxRate,Case When RBI.ReciveORPay=@Pay_Dr Then RBI.DocTaxAmount End As DocDebit,Case When RBI.ReciveORPay=@Receive_Cr Then RBI.DocTaxAmount End As DocCredit,
								Case When RBI.ReciveORPay=@Pay_Dr Then Round(RBI.DocTaxAmount * @SysCalExchangerate,2) End As BaseDebit,Case When RBI.ReciveORPay=@Receive_Cr Then Round(RBI.DocTaxAmount * @SysCalExchangerate,2) End As BaseCredit,
								0.00 As DocDebitTotal,0.00 As DocCreditTotal,0.00 As BaseDebitTotal,0.00 As BaseCreditTotal,R.Id As DocumentId,RBI.Id As DocumentDetailId,@GUIDZero,
								R.BaseCurrency,@SysCalExchangerate As ExchangeRate,R.GSTExCurrency,R.GSTExchangeRate,@DocType,@DocSubType,ServiceCompanyId,DocNo,1 As IsTax,
								EntityId,@MasterSystemRefNo,@BankChargesCurrency,DocDate,DocDate,@TaxRecCount As RecOrder
							From Bean.Receipt(Nolock) As R
							Inner Join bean.ReceiptBalancingItem(Nolock) As RBI On RBI.ReceiptId=R.Id
							Where R.Id=@SourceId And Rbi.Id=@RecieptBalId
						End
						Set @RecCount=@RecCount+1
					End
					-- ServComp Records
					Insert Into @ServCompaIdTbl
					Select Distinct RD.ServiceCompanyId From Bean.ReceiptDetail(Nolock) As RD
					Inner Join Bean.Receipt(Nolock) As R On RD.ReceiptId=R.Id 
					Where R.Id=@SourceId And RD.ReceiptAmount<>0 And RD.ServiceCompanyId<>@MasterServComp And ReceiptAmount<>0
					Set @Count=(Select Count(*) From @ServCompaIdTbl)
					Set @RecCount=1
					While @Count>=@RecCount
					Begin
						Select @ServCompId=SerCompId From @ServCompaIdTbl Where S_No=@RecCount
						Set @IntroCompCOAID=(Select COA.Id From Bean.ChartOfAccount(Nolock) As COA 
												Inner Join Bean.AccountType(Nolock) As ACT On ACT.Id=COA.AccountTypeId
												Where ACT.CompanyId=@CompanyId And ACT.Name=@IntercompClearingCOAName And COA.SubsidaryCompanyId=@ServCompId)
						Set @ClearingRecieptInvOrDNAmount=(Select Sum(Isnull(ReceiptAmount,0)) From bean.ReceiptDetail(Nolock) Where ReceiptId=@SourceId And ServiceCompanyId=@ServCompId And DocumentType in (@InvoiceDocument,@DebitNoteDocument))
						Set @ClearingRecieptBillAmount=(Select Sum(Isnull(ReceiptAmount,0)) From bean.ReceiptDetail(Nolock) Where ReceiptId=@SourceId And ServiceCompanyId=@ServCompId And DocumentType=@BillDocument) 
						Set @CreditNoteAmount=(Select Sum(Isnull(ReceiptAmount,0)) From Bean.ReceiptDetail(Nolock) Where ReceiptId=@SourceId And ServiceCompanyId=@ServCompId And DocumentType=@CreditNoteDocument)
						Set @CreditMemoAmount=(Select Sum(Isnull(ReceiptAmount,0)) From Bean.ReceiptDetail(Nolock) Where ReceiptId=@SourceId And ServiceCompanyId=@ServCompId And DocumentType=@CreditMemoDocument)
						IF @ClearingRecieptInvOrDNAmount Is null
						Begin
							Set @ClearingRecieptInvOrDNAmount =Isnull(@ClearingRecieptInvOrDNAmount,0)
						End
						IF @ClearingRecieptBillAmount Is null
						Begin
							Set @ClearingRecieptBillAmount =Isnull(@ClearingRecieptBillAmount,0)
						End

						IF @CreditNoteAmount Is null
						Begin
							Set @CreditNoteAmount =Isnull(@CreditNoteAmount,0)
						End
						IF @CreditMemoAmount Is null
						Begin
							Set @CreditMemoAmount =Isnull(@CreditMemoAmount,0)
						End
						-- CreditMemoAmount
						IF @CreditMemoAmount Is Not Null And @CreditMemoAmount<>0
						Begin
							Set @RecOrder=@RecOrder+1
							Insert Into Bean.JournalDetail (Id,JournalId,COAId,AccountDescription, DocDebit,DocCredit,
														 BaseDebit,BaseCredit,
														 DocDebitTotal,DocCreditTotal,BaseDebitTotal,BaseCreditTotal,DocumentId,DocumentDetailId,ItemId,BaseCurrency,ExchangeRate, DocType,DocSubType,ServiceCompanyId,DocNo,Nature,OffsetDocument,IsTax,
														EntityId, SystemRefNo, DocCurrency,DocDate, PostingDate,RecOrder 
														)
							Select NEWID(),@MasterJournalId,@IntroCompCOAID,R.Remarks,Null As DocDebit,Round((@CreditMemoAmount * @DefaultExchangeRate)/@SysCalExchangerate,2) As DocCredit,
								Null As BaseDebit,Round(@CreditMemoAmount * @DefaultExchangeRate,2) As BaseCredit,
								0.00 As DocDebitTotal,0.00 As DocCreditTotal,0.00 As BaseDebitTotal,0.00 As BaseCreditTotal,@SourceId As DocumentId,@GUIDZero As DocumentDetailId,@GUIDZero,
								R.BaseCurrency,@SysCalExchangerate As ExchangeRate,@DocType,@DocSubType,@MasterServComp As ServiceCompanyId,R.DocNo,Null As Nature,R.DocNo,0 As IsTax,
								R.EntityId,@MasterSystemRefNo,@BankChargesCurrency,R.DocDate,R.DocDate,@RecOrder As RecOrder
							From Bean.Receipt(Nolock) As R
							Where R.Id=@SourceId
							-- Create CreditMemo Journal I/C
							Set @JournalId=NEWID()
							Set @SysRefNum_Incr=@SysRefNum_Incr+1
							Set @SystemRefNo=CONCAT(@DocNo,'-JV',@SysRefNum_Incr)
							Set @RecOrderAnotherJV=1
							Insert Into Bean.Journal (Id,CompanyId,DocDate,DocType,DocSubType,DocNo,ServiceCompanyId,SystemReferenceNo,IsNoSupportingDocs,NoSupportingDocument,DocCurrency,ExchangeRate,ExCurrency,ExDurationFrom,GSTExchangeRate,GSTExCurrency,GSTTotalAmount,DocumentState,IsNoSupportingDocument,IsGstSettings,IsMultiCurrency,IsAllowableNonAllowable,IsGSTCurrencyRateChanged,Remarks,UserCreated,CreatedDate,Status,DocumentDescription,CreationType,GrandDocDebitTotal,GrandDocCreditTotal,GrandBaseDebitTotal,
														GrandBaseCreditTotal,EntityId,EntityType,PostingDate,COAId,ModeOfReceipt,BankReceiptAmmount,ExcessPaidByClientAmmount,BalancingItemReciveCRAmount,  BalancingItemPayDRAmount,ReceiptApplicationAmmount,DocumentId, BankClearingDate ,IsBalancing,ISAllowDisAllow, IsShow, ActualSysRefNo 
														,IsSegmentReporting,TransferRefNo
													 )
							Select @JournalId,@CompanyId,DocDate,@DocType,@DocSubType,DocNo,@ServCompId As ServiceCompanyId,@SystemRefNo As SystemRefNo,IsNoSupportingDocument,NoSupportingDocs,DocCurrency,ExchangeRate,ExCurrency,ExDurationFrom,GSTExchangeRate,GSTExCurrency,Isnull(GSTTotalAmount,0),DocumentState,NoSupportingDocs,IsGstSettings,IsMultiCurrency,IsAllowableDisallowable,IsGSTCurrencyRateChanged,Remarks,@UserCreated,@CreatedDate,Status,Remarks As DocDescription,@UserCreated,GrandTotal,0.00 As GrandDocCreditTotal,GrandTotal * Round(ExchangeRate,2) As GrandBaseDebitTotal,
									0.00 As GrandBaseCreditTotal,EntityId,EntityType,DocDate As PostingDate,@IntroCompCOAID As COAId,ModeOfReceipt,0.00 As BankReceiptAmmount,0.00 As ExcessPaidByClientAmmount,0.00 As BalancingItemReciveCRAmount,0.00 As BalancingItemPayDRAmount,0.00 As ReceiptApplicationAmmount,Id As DocumentId,BankClearingDate,0 As IsBalancing,IsDisAllow,1 As IsShow,DocNo As ActualSysRefNo,0 As IsSegmentReporting,ReceiptRefNo
							From Bean.Receipt(Nolock) Where CompanyId=@CompanyId And Id=@SourceId
							-- Create CreditMemo Journal I/C JD COA
							Insert Into Bean.JournalDetail (Id,JournalId,COAId,AccountDescription, DocDebit,DocCredit,
														 BaseDebit,BaseCredit,
														 DocDebitTotal,DocCreditTotal,BaseDebitTotal,BaseCreditTotal,DocumentId,DocumentDetailId,ItemId,BaseCurrency,ExchangeRate, DocType,DocSubType,ServiceCompanyId,DocNo,Nature,OffsetDocument,IsTax,
														EntityId, SystemRefNo, DocCurrency,DocDate, PostingDate,RecOrder 
														)
							Select NEWID(),@JournalId,@MainInterCoServCompCOAID,R.Remarks,Round((@CreditMemoAmount * @DefaultExchangeRate)/@SysCalExchangerate,2) As DocDebit,Null As DocCredit,
								Round(@CreditMemoAmount * @DefaultExchangeRate,2) As BaseDebit,NUll As BaseCredit,
								0.00 As DocDebitTotal,0.00 As DocCreditTotal,0.00 As BaseDebitTotal,0.00 As BaseCreditTotal,R.Id As DocumentId,@GUIDZero As DocumentDetailId,@GUIDZero,
								R.BaseCurrency,@SysCalExchangerate As ExchangeRate,@DocType,@DocSubType,@ServCompId As ServiceCompanyId,R.DocNo,Null As Nature,R.DocNo,0 As IsTax,
								R.EntityId,@SystemRefNo,@BankChargesCurrency,R.DocDate,R.DocDate,@RecOrderAnotherJV As RecOrder
							From Bean.Receipt(Nolock) As R
							Where R.Id=@SourceId
							-- Create CreditMemo Journal I/C JD ClearingReceipts COA
							Set @RecOrderAnotherJV=@RecOrderAnotherJV+1
							Insert Into Bean.JournalDetail (Id,JournalId,COAId,AccountDescription, DocDebit,DocCredit,
														 BaseDebit,BaseCredit,
														 DocDebitTotal,DocCreditTotal,BaseDebitTotal,BaseCreditTotal,DocumentId,DocumentDetailId,ItemId,BaseCurrency,ExchangeRate, DocType,DocSubType,ServiceCompanyId,DocNo,Nature,OffsetDocument,IsTax,
														EntityId, SystemRefNo, DocCurrency,DocDate, PostingDate,RecOrder 
														)
							Select NEWID(),@JournalId,@ClearingReceiptsCOAID,R.Remarks,Null As DocDebit,Round((@CreditMemoAmount * @DefaultExchangeRate)/@SysCalExchangerate,2) As DocCredit,
								Null As BaseDebit,Round(@CreditMemoAmount * @DefaultExchangeRate,2) As BaseCredit,
								0.00 As DocDebitTotal,0.00 As DocCreditTotal,0.00 As BaseDebitTotal,0.00 As BaseCreditTotal,R.Id As DocumentId,@GUIDZero As DocumentDetailId,@GUIDZero,
								R.BaseCurrency,@SysCalExchangerate As ExchangeRate,@DocType,@DocSubType,@ServCompId As ServiceCompanyId,R.DocNo,Null As Nature,R.DocNo,0 As IsTax,
								R.EntityId,@SystemRefNo,@BankChargesCurrency,R.DocDate,R.DocDate,@RecOrderAnotherJV As RecOrder
							From Bean.Receipt(Nolock) As R
							Where R.Id=@SourceId
						End
						-- CreditNoteAmount
						IF @CreditNoteAmount Is Not Null And @CreditNoteAmount<>0
						Begin
							Set @RecOrder=@RecOrder+1
							Insert Into Bean.JournalDetail (Id,JournalId,COAId,AccountDescription, DocDebit,DocCredit,
														 BaseDebit,BaseCredit,
														 DocDebitTotal,DocCreditTotal,BaseDebitTotal,BaseCreditTotal,DocumentId,DocumentDetailId,ItemId,BaseCurrency,ExchangeRate, DocType,DocSubType,ServiceCompanyId,DocNo,Nature,OffsetDocument,IsTax,
														EntityId, SystemRefNo, DocCurrency,DocDate, PostingDate,RecOrder 
														)
							Select NEWID(),@MasterJournalId,@IntroCompCOAID,R.Remarks,Round((@CreditNoteAmount * @DefaultExchangeRate)/@SysCalExchangerate,2) As DocDebit,NUll As DocCredit,
								Round(@CreditNoteAmount * @DefaultExchangeRate,2) As BaseDebit,Null As BaseCredit,
								0.00 As DocDebitTotal,0.00 As DocCreditTotal,0.00 As BaseDebitTotal,0.00 As BaseCreditTotal,R.Id As DocumentId,@GUIDZero As DocumentDetailId,@GUIDZero,
								R.BaseCurrency,@SysCalExchangerate As ExchangeRate,@DocType,@DocSubType,@MasterServComp As ServiceCompanyId,R.DocNo,Null As Nature,R.DocNo,0 As IsTax,
								R.EntityId,@MasterSystemRefNo,@BankChargesCurrency,R.DocDate,R.DocDate,@RecOrder As RecOrder
							From Bean.Receipt(Nolock) As R
							Where R.Id=@SourceId
							-- Creating CreditNote Journal
							Set @CreditNoteJournalId=NEWID()
							Set @SysRefNum_Incr=@SysRefNum_Incr+1
							Set @SystemRefNo=CONCAT(@DocNo,'-JV',@SysRefNum_Incr)
							Insert Into Bean.Journal (Id,CompanyId,DocDate,DocType,DocSubType,DocNo,ServiceCompanyId,SystemReferenceNo,IsNoSupportingDocs,NoSupportingDocument,DocCurrency,ExchangeRate,ExCurrency,ExDurationFrom,GSTExchangeRate,GSTExCurrency,GSTTotalAmount,DocumentState,IsNoSupportingDocument,IsGstSettings,IsMultiCurrency,IsAllowableNonAllowable,IsGSTCurrencyRateChanged,Remarks,UserCreated,CreatedDate,Status,DocumentDescription,CreationType,GrandDocDebitTotal,GrandDocCreditTotal,GrandBaseDebitTotal,
													 GrandBaseCreditTotal,EntityId,EntityType,PostingDate,COAId,ModeOfReceipt,BankReceiptAmmount,ExcessPaidByClientAmmount,BalancingItemReciveCRAmount,  BalancingItemPayDRAmount,ReceiptApplicationAmmount,DocumentId, BankClearingDate ,IsBalancing,ISAllowDisAllow, IsShow, ActualSysRefNo 
													 ,IsSegmentReporting,TransferRefNo
													 )
							Select @CreditNoteJournalId,@CompanyId,DocDate,@DocType,@DocSubType,DocNo,@ServCompId As ServiceCompanyId,@SystemRefNo As SystemRefNo,IsNoSupportingDocument,NoSupportingDocs,DocCurrency,ExchangeRate,ExCurrency,ExDurationFrom,GSTExchangeRate,GSTExCurrency,Isnull(GSTTotalAmount,0),DocumentState,NoSupportingDocs,IsGstSettings,IsMultiCurrency,IsAllowableDisallowable,IsGSTCurrencyRateChanged,Remarks,@UserCreated,@CreatedDate,Status,Remarks As DocDescription,@UserCreated,GrandTotal,0.00 As GrandDocCreditTotal,GrandTotal * Round(ExchangeRate,2) As GrandBaseDebitTotal,
									0.00 As GrandBaseCreditTotal,EntityId,EntityType,DocDate As PostingDate,@IntroCompCOAID As COAId,ModeOfReceipt,0.00 As BankReceiptAmmount,0.00 As ExcessPaidByClientAmmount,0.00 As BalancingItemReciveCRAmount,0.00 As BalancingItemPayDRAmount,0.00 As ReceiptApplicationAmmount,Id As DocumentId,BankClearingDate,0 As IsBalancing,IsDisAllow,1 As IsShow,DocNo As ActualSysRefNo,0 As IsSegmentReporting,ReceiptRefNo
							From Bean.Receipt(Nolock) Where CompanyId=@CompanyId And Id=@SourceId
							-- CreditNote Journal Detail MainInterCoServCompCOAID
							Set @RecOrderAnotherJV=1
							Insert Into Bean.JournalDetail (Id,JournalId,COAId,AccountDescription, DocDebit,DocCredit,
														 BaseDebit,BaseCredit,
														 DocDebitTotal,DocCreditTotal,BaseDebitTotal,BaseCreditTotal,DocumentId,DocumentDetailId,ItemId,BaseCurrency,ExchangeRate, DocType,DocSubType,ServiceCompanyId,DocNo,Nature,OffsetDocument,IsTax,
														EntityId, SystemRefNo, DocCurrency,DocDate, PostingDate,RecOrder 
														)
							Select NEWID(),@CreditNoteJournalId,@MainInterCoServCompCOAID,R.Remarks,Null As DocDebit,Round((@CreditNoteAmount * @DefaultExchangeRate)/ @SysCalExchangerate,2) As DocCredit,
								Null As BaseDebit,Round(@CreditNoteAmount * @DefaultExchangeRate,2) As BaseCredit,
								0.00 As DocDebitTotal,0.00 As DocCreditTotal,0.00 As BaseDebitTotal,0.00 As BaseCreditTotal,R.Id As DocumentId,@GUIDZero As DocumentDetailId,@GUIDZero,
								R.BaseCurrency,@SysCalExchangerate As ExchangeRate,@DocType,@DocSubType,@ServCompId As ServiceCompanyId,R.DocNo,Null As Nature,R.DocNo,0 As IsTax,
								R.EntityId,@SystemRefNo,@BankChargesCurrency,R.DocDate,R.DocDate,@RecOrderAnotherJV As RecOrder
							From Bean.Receipt(Nolock) As R
							Where R.Id=@SourceId
							-- CreditNote Journal Detail ClearingReceipts
							Set @RecOrderAnotherJV=@RecOrderAnotherJV+1
							Insert Into Bean.JournalDetail (Id,JournalId,COAId,AccountDescription, DocDebit,DocCredit,
														 BaseDebit,BaseCredit,
														 DocDebitTotal,DocCreditTotal,BaseDebitTotal,BaseCreditTotal,DocumentId,DocumentDetailId,ItemId,BaseCurrency,ExchangeRate, DocType,DocSubType,ServiceCompanyId,DocNo,Nature,OffsetDocument,IsTax,
														EntityId, SystemRefNo, DocCurrency,DocDate, PostingDate,RecOrder 
														)
							Select NEWID(),@CreditNoteJournalId,@ClearingReceiptsCOAID,R.Remarks,Round((@CreditNoteAmount * @DefaultExchangeRate)/ @SysCalExchangerate,2) As DocDebit,Null As DocCredit,
								Round(@CreditNoteAmount * @DefaultExchangeRate,2) As BaseDebit,Null As BaseCredit,
								0.00 As DocDebitTotal,0.00 As DocCreditTotal,0.00 As BaseDebitTotal,0.00 As BaseCreditTotal,R.Id As DocumentId,@GUIDZero As DocumentDetailId,@GUIDZero,
								R.BaseCurrency,@SysCalExchangerate As ExchangeRate,@DocType,@DocSubType,@ServCompId As ServiceCompanyId,R.DocNo,Null As Nature,R.DocNo,0 As IsTax,
								R.EntityId,@SystemRefNo,@BankChargesCurrency,R.DocDate,R.DocDate,@RecOrderAnotherJV As RecOrder
							From Bean.Receipt(Nolock) As R
							Where R.Id=@SourceId
						End
						-- ClearingRecieptInvOrDNAmount Receipt Details
						IF (@ClearingRecieptInvOrDNAmount Is Not Null And @ClearingRecieptInvOrDNAmount<>0) OR (@ClearingRecieptBillAmount Is Not Null And @ClearingRecieptBillAmount<>0)
						Begin
							Set @RecOrder=@RecOrder+1
							Insert Into Bean.JournalDetail (Id,JournalId,COAId,AccountDescription, DocDebit,DocCredit,
															 BaseDebit,BaseCredit,
															 DocDebitTotal,DocCreditTotal,BaseDebitTotal,BaseCreditTotal,DocumentId,DocumentDetailId,ItemId,BaseCurrency,ExchangeRate, DocType,DocSubType,ServiceCompanyId,DocNo,Nature,OffsetDocument,IsTax,
															EntityId, SystemRefNo, DocCurrency,DocDate, PostingDate,RecOrder 
															)
							Select NEWID(),@MasterJournalId,@IntroCompCOAID,R.Remarks,
								Case When (@ClearingRecieptInvOrDNAmount-@ClearingRecieptBillAmount)<0 Then ABS(Round(((@ClearingRecieptInvOrDNAmount-@ClearingRecieptBillAmount) * @DefaultExchangeRate)/ @SysCalExchangerate,2)) End As DocDebit,
								Case When (@ClearingRecieptInvOrDNAmount-@ClearingRecieptBillAmount) >=0 Then ABS(Round(((@ClearingRecieptInvOrDNAmount-@ClearingRecieptBillAmount) * @DefaultExchangeRate)/ @SysCalExchangerate,2)) End As DocCredit,
								Case When (@ClearingRecieptInvOrDNAmount-@ClearingRecieptBillAmount)<0 Then ABS(Round((@ClearingRecieptInvOrDNAmount-@ClearingRecieptBillAmount) * @DefaultExchangeRate,2)) End As BaseDebit,
								Case When (@ClearingRecieptInvOrDNAmount-@ClearingRecieptBillAmount)>0 Then ABS(Round((@ClearingRecieptInvOrDNAmount-@ClearingRecieptBillAmount) * @DefaultExchangeRate,2)) End As BaseCredit,
								0.00 As DocDebitTotal,0.00 As DocCreditTotal,0.00 As BaseDebitTotal,0.00 As BaseCreditTotal,R.Id As DocumentId,@GUIDZero As DocumentDetailId,@GUIDZero,
								R.BaseCurrency,@SysCalExchangerate As ExchangeRate,@DocType,@DocSubType,@MasterServComp As ServiceCompanyId,R.DocNo,Null As Nature,R.DocNo,0 As IsTax,
								R.EntityId,@MasterSystemRefNo,@BankChargesCurrency,R.DocDate,R.DocDate,@RecOrder As RecOrder
							From Bean.Receipt(Nolock) As R
							Where R.Id=@SourceId
							-- Creating Journal With I/c
							Set @JournalId=NEWID()
							Set @SysRefNum_Incr=@SysRefNum_Incr+1
							Set @SystemRefNo=CONCAT(@DocNo,'-JV',@SysRefNum_Incr)
							Insert Into Bean.Journal (Id,CompanyId,DocDate,DocType,DocSubType,DocNo,ServiceCompanyId,SystemReferenceNo,IsNoSupportingDocs,NoSupportingDocument,DocCurrency,ExchangeRate,ExCurrency,ExDurationFrom,GSTExchangeRate,GSTExCurrency,GSTTotalAmount,DocumentState,IsNoSupportingDocument,IsGstSettings,IsMultiCurrency,IsAllowableNonAllowable,IsGSTCurrencyRateChanged,Remarks,UserCreated,CreatedDate,Status,DocumentDescription,CreationType,GrandDocDebitTotal,GrandDocCreditTotal,GrandBaseDebitTotal,
														GrandBaseCreditTotal,EntityId,EntityType,PostingDate,COAId,ModeOfReceipt,BankReceiptAmmount,ExcessPaidByClientAmmount,BalancingItemReciveCRAmount,  BalancingItemPayDRAmount,ReceiptApplicationAmmount,DocumentId, BankClearingDate ,IsBalancing,ISAllowDisAllow, IsShow, ActualSysRefNo 
														,IsSegmentReporting,TransferRefNo
													 )
							Select @JournalId,@CompanyId,DocDate,@DocType,@DocSubType,DocNo,@ServCompId As ServiceCompanyId,@SystemRefNo As SystemRefNo,IsNoSupportingDocument,NoSupportingDocs,DocCurrency,ExchangeRate,ExCurrency,ExDurationFrom,GSTExchangeRate,GSTExCurrency,Isnull(GSTTotalAmount,0),DocumentState,NoSupportingDocs,IsGstSettings,IsMultiCurrency,IsAllowableDisallowable,IsGSTCurrencyRateChanged,Remarks,@UserCreated,@CreatedDate,Status,Remarks As DocDescription,@UserCreated,GrandTotal,0.00 As GrandDocCreditTotal,GrandTotal * Round(ExchangeRate,2) As GrandBaseDebitTotal,
									0.00 As GrandBaseCreditTotal,EntityId,EntityType,DocDate As PostingDate,@IntroCompCOAID As COAId,ModeOfReceipt,0.00 As BankReceiptAmmount,0.00 As ExcessPaidByClientAmmount,0.00 As BalancingItemReciveCRAmount,0.00 As BalancingItemPayDRAmount,0.00 As ReceiptApplicationAmmount,Id As DocumentId,BankClearingDate,0 As IsBalancing,IsDisAllow,1 As IsShow,DocNo As ActualSysRefNo,0 As IsSegmentReporting,ReceiptRefNo
							From Bean.Receipt(Nolock) Where CompanyId=@CompanyId And Id=@SourceId
							-- Creating Journal With I/c JD i/C COA
							Set @RecOrderAnotherJV=1
							Insert Into Bean.JournalDetail (Id,JournalId,COAId,AccountDescription, DocDebit,DocCredit,
													 BaseDebit,BaseCredit,
													 DocDebitTotal,DocCreditTotal,BaseDebitTotal,BaseCreditTotal,DocumentId,DocumentDetailId,ItemId,BaseCurrency,ExchangeRate, DocType,DocSubType,ServiceCompanyId,DocNo,Nature,OffsetDocument,IsTax,
													EntityId, SystemRefNo, DocCurrency,DocDate, PostingDate,RecOrder 
													)
							Select NEWID(),@JournalId,@MainInterCoServCompCOAID,R.Remarks,Case When (@ClearingRecieptInvOrDNAmount-@ClearingRecieptBillAmount)>0 Then ABS(Round(((@ClearingRecieptInvOrDNAmount-@ClearingRecieptBillAmount)* @DefaultExchangeRate)/@SysCalExchangerate,2)) End As DocDebit,
									Case When (@ClearingRecieptInvOrDNAmount-@ClearingRecieptBillAmount)<0 Then ABS(Round(((@ClearingRecieptInvOrDNAmount-@ClearingRecieptBillAmount)* @DefaultExchangeRate)/@SysCalExchangerate,2)) End As DocCredit,
									Case When (@ClearingRecieptInvOrDNAmount-@ClearingRecieptBillAmount)>0 Then ABS(Round((((@ClearingRecieptInvOrDNAmount-@ClearingRecieptBillAmount) * @DefaultExchangeRate)/@SysCalExchangerate) * @SysCalExchangerate,2)) End As BaseDebit,
									Case When (@ClearingRecieptInvOrDNAmount-@ClearingRecieptBillAmount)<0 Then ABS(Round((((@ClearingRecieptInvOrDNAmount-@ClearingRecieptBillAmount) * @DefaultExchangeRate)/@SysCalExchangerate) * @SysCalExchangerate,2)) End As BaseCredit,
									0.00 As DocDebitTotal,0.00 As DocCreditTotal,0.00 As BaseDebitTotal,0.00 As BaseCreditTotal,R.Id As DocumentId,R.Id As DocumentDetailId,@GUIDZero,
									R.BaseCurrency,@SysCalExchangerate As ExchangeRate,@DocType,@DocSubType,@ServCompId As ServiceCompanyId,R.DocNo,Null As Nature,R.DocNo,0 As IsTax,
									R.EntityId,@SystemRefNo,@BankChargesCurrency,R.DocDate,R.DocDate,@RecOrderAnotherJV As RecOrder
							From Bean.Receipt(Nolock) As R
							Where R.Id=@SourceId
							-- Creating Journal With I/c  Jd Clearingreceipts COA
							Set @RecOrderAnotherJV=@RecOrderAnotherJV+1
							Insert Into Bean.JournalDetail (Id,JournalId,COAId,AccountDescription, DocDebit,DocCredit,
													 BaseDebit,BaseCredit,
													 DocDebitTotal,DocCreditTotal,BaseDebitTotal,BaseCreditTotal,DocumentId,DocumentDetailId,ItemId,BaseCurrency,ExchangeRate, DocType,DocSubType,ServiceCompanyId,DocNo,Nature,OffsetDocument,IsTax,
													EntityId, SystemRefNo, DocCurrency,DocDate, PostingDate,RecOrder 
													)
							Select NEWID(),@JournalId,@ClearingReceiptsCOAID,R.Remarks,Case When (@ClearingRecieptInvOrDNAmount-@ClearingRecieptBillAmount) <0 Then ABS(Round(((@ClearingRecieptInvOrDNAmount-@ClearingRecieptBillAmount)* @DefaultExchangeRate)/@SysCalExchangerate,2)) End As DocDebit,Case When (@ClearingRecieptInvOrDNAmount-@ClearingRecieptBillAmount)>0 Then ABS(Round(((@ClearingRecieptInvOrDNAmount-@ClearingRecieptBillAmount)* @DefaultExchangeRate)/@SysCalExchangerate,2)) End As DocCredit,
									Case When (@ClearingRecieptInvOrDNAmount-@ClearingRecieptBillAmount) <0 Then ABS(Round((((@ClearingRecieptInvOrDNAmount-@ClearingRecieptBillAmount) * @DefaultExchangeRate)/@SysCalExchangerate) * @SysCalExchangerate,2)) End As BaseDebit,
									Case When (@ClearingRecieptInvOrDNAmount-@ClearingRecieptBillAmount) >0 Then ABS(Round((((@ClearingRecieptInvOrDNAmount-@ClearingRecieptBillAmount) * @DefaultExchangeRate)/@SysCalExchangerate) * @SysCalExchangerate,2)) End As BaseCredit,
									0.00 As DocDebitTotal,0.00 As DocCreditTotal,0.00 As BaseDebitTotal,0.00 As BaseCreditTotal,R.Id As DocumentId,R.Id As DocumentDetailId,@GUIDZero,
									R.BaseCurrency,@SysCalExchangerate As ExchangeRate,@DocType,@DocSubType,@ServCompId As ServiceCompanyId,R.DocNo,Null As Nature,R.DocNo,0 As IsTax,
									R.EntityId,@SystemRefNo,@BankChargesCurrency,R.DocDate,R.DocDate,@RecOrderAnotherJV As RecOrder
							From Bean.Receipt(Nolock) As R
							Where R.Id=@SourceId
							-- Creating Journal With Clearing Receipts
							Set @JournalId=NEWID()
							Set @SystemRefNo= Concat(Substring(Reverse(Substring(Reverse(@SystemRefNo),1,CHARINDEX('-',Reverse(@SystemRefNo)))),PATINDEX('%[0-9]%',@SystemRefNo),DATALENGTH(Reverse(Substring(Reverse(@SystemRefNo),1,CHARINDEX('-',Reverse(@SystemRefNo))))))+1,'')
							Insert Into Bean.Journal (Id,CompanyId,DocDate,DocType,DocSubType,DocNo,ServiceCompanyId,SystemReferenceNo,IsNoSupportingDocs,NoSupportingDocument,DocCurrency,ExchangeRate,ExCurrency,ExDurationFrom,GSTExchangeRate,GSTExCurrency,GSTTotalAmount,DocumentState,IsNoSupportingDocument,IsGstSettings,IsMultiCurrency,IsAllowableNonAllowable,IsGSTCurrencyRateChanged,Remarks,UserCreated,CreatedDate,Status,DocumentDescription,CreationType,GrandDocDebitTotal,GrandDocCreditTotal,GrandBaseDebitTotal,
														GrandBaseCreditTotal,EntityId,EntityType,PostingDate,COAId,ModeOfReceipt,BankReceiptAmmount,ExcessPaidByClientAmmount,BalancingItemReciveCRAmount,  BalancingItemPayDRAmount,ReceiptApplicationAmmount,DocumentId, BankClearingDate ,IsBalancing,ISAllowDisAllow, IsShow, ActualSysRefNo 
														,IsSegmentReporting,TransferRefNo
													 )
							Select @JournalId,@CompanyId,DocDate,@DocType,@DocSubType,DocNo,@ServCompId As ServiceCompanyId,@SystemRefNo As SystemRefNo,IsNoSupportingDocument,NoSupportingDocs,DocCurrency,ExchangeRate,ExCurrency,ExDurationFrom,GSTExchangeRate,GSTExCurrency,Isnull(GSTTotalAmount,0),DocumentState,NoSupportingDocs,IsGstSettings,IsMultiCurrency,IsAllowableDisallowable,IsGSTCurrencyRateChanged,Remarks,@UserCreated,@CreatedDate,Status,Remarks As DocDescription,@UserCreated,GrandTotal,0.00 As GrandDocCreditTotal,GrandTotal * Round(ExchangeRate,2) As GrandBaseDebitTotal,
									0.00 As GrandBaseCreditTotal,EntityId,EntityType,DocDate As PostingDate,@IntroCompCOAID As COAId,ModeOfReceipt,0.00 As BankReceiptAmmount,0.00 As ExcessPaidByClientAmmount,0.00 As BalancingItemReciveCRAmount,0.00 As BalancingItemPayDRAmount,0.00 As ReceiptApplicationAmmount,Id As DocumentId,BankClearingDate,0 As IsBalancing,IsDisAllow,1 As IsShow,DocNo As ActualSysRefNo,0 As IsSegmentReporting,ReceiptRefNo
							From Bean.Receipt(Nolock) Where CompanyId=@CompanyId And Id=@SourceId
							-- Creating Journal With Clearing Receipts JD COA
							Set @RecOrderAnotherJV=1
							Insert Into Bean.JournalDetail (Id,JournalId,COAId,AccountDescription, DocDebit,DocCredit,
													 BaseDebit,BaseCredit,
													 DocDebitTotal,DocCreditTotal,BaseDebitTotal,BaseCreditTotal,DocumentId,DocumentDetailId,ItemId,BaseCurrency,ExchangeRate, DocType,DocSubType,ServiceCompanyId,DocNo,Nature,OffsetDocument,IsTax,
													EntityId, SystemRefNo, DocCurrency,DocDate, PostingDate,RecOrder 
													)
							Select NEWID(),@JournalId,@ClearingReceiptsCOAID,R.Remarks,Case When (@ClearingRecieptInvOrDNAmount-@ClearingRecieptBillAmount)>0 Then ABS(@ClearingRecieptInvOrDNAmount-@ClearingRecieptBillAmount) End As DocDebit,
									Case When (@ClearingRecieptInvOrDNAmount-@ClearingRecieptBillAmount)<0 Then ABS(@ClearingRecieptInvOrDNAmount-@ClearingRecieptBillAmount) End As DocCredit,
									Case When (@ClearingRecieptInvOrDNAmount-@ClearingRecieptBillAmount)>0 Then ABS(Round((@ClearingRecieptInvOrDNAmount-@ClearingRecieptBillAmount) * @DefaultExchangeRate,2)) End As BaseDebit,
									Case When (@ClearingRecieptInvOrDNAmount-@ClearingRecieptBillAmount)<0 Then ABS(Round((@ClearingRecieptInvOrDNAmount-@ClearingRecieptBillAmount) * @DefaultExchangeRate,2)) End As BaseCredit,
									0.00 As DocDebitTotal,0.00 As DocCreditTotal,0.00 As BaseDebitTotal,0.00 As BaseCreditTotal,R.Id As DocumentId,R.Id As DocumentDetailId,@GUIDZero,
									R.BaseCurrency,@DefaultExchangeRate As ExchangeRate,@DocType,@DocSubType,@ServCompId As ServiceCompanyId,R.DocNo,Null As Nature,R.DocNo,0 As IsTax,
									R.EntityId,@SystemRefNo,@DocCurrency,R.DocDate,R.DocDate,@RecOrderAnotherJV As RecOrder
							From Bean.Receipt(Nolock) As R
							Where R.Id=@SourceId
							-- Receipt Detail Records Serv Comp Wise
							Delete From @RecieptDtl_New
							Insert Into @RecieptDtl_New 
							Select ROW_NUMBER() Over (Order By RD.id) ,RD.Id From Bean.ReceiptDetail(Nolock) As RD
							Inner Join Bean.Receipt(Nolock) As R On RD.ReceiptId=R.Id 
							Where R.Id=@SourceId And RD.ServiceCompanyId=@ServCompId And RD.ReceiptAmount<>0 And RD.DocumentType Not In (@CreditNoteDocument,@CreditMemoDocument) Order By RD.RecOrder
							Set @DtlCount=(Select Count(*) From @RecieptDtl_New)
							Set @RdtlRecCount=1
							While @DtlCount>=@RdtlRecCount
							Begin
								Set @RecieptDtlId=(Select RecieptDtlId From @RecieptDtl_New Where S_No=@RdtlRecCount)
								Set @OffSetDocumentType=(Select DocumentType From Bean.ReceiptDetail(Nolock) Where Id=@RecieptDtlId)
								Set @DocumentId=(Select DocumentId From Bean.ReceiptDetail(Nolock) Where Id=@RecieptDtlId)
								Set @IsRoundingAmount=0
								IF Exists (Select ID From Bean.ReceiptDetail(Nolock) Where id=@RecieptDtlId And Nature=@NatureTrade And DocumentType =@InvoiceDocument)
								Begin
									Set @COAID=(Select Id From Bean.ChartOfAccount(Nolock) Where CompanyId=@CompanyId And Name=@COATradeReceivables)
									IF Exists(Select Id From Bean.Invoice(Nolock) Where Id=@DocumentId And DocumentState In (@FullyApplied,@Fullypaid))
									Begin
										Set @IsRoundingAmount=1
									End
								End
								-- InvoiceDocument & DebitNoteDocument With OtherReceivables
								Else IF Exists (Select ID From Bean.ReceiptDetail(Nolock) Where id=@RecieptDtlId And Nature=@NatureOthers And DocumentType =@InvoiceDocument)
								Begin
									Set @COAID=(Select Id From Bean.ChartOfAccount(Nolock) Where CompanyId=@CompanyId And Name=@COAotherReceivables )
									IF Exists(Select Id From Bean.Invoice(Nolock) Where Id=@DocumentId And DocumentState In (@FullyApplied,@Fullypaid))
									Begin
										Set @IsRoundingAmount=1
									End
								End
								Else IF Exists (Select ID From Bean.ReceiptDetail(Nolock) Where id=@RecieptDtlId And Nature=@NatureTrade And DocumentType =@DebitNoteDocument)
								Begin
									Set @COAID=(Select Id From Bean.ChartOfAccount(Nolock) Where CompanyId=@CompanyId And Name=@COATradeReceivables)
									IF Exists(Select Id From Bean.DebitNote(Nolock) Where Id=@DocumentId And DocumentState In (@FullyApplied,@Fullypaid))
									Begin
										Set @IsRoundingAmount=1
									End
								End
								-- InvoiceDocument & DebitNoteDocument With OtherReceivables
								Else IF Exists (Select ID From Bean.ReceiptDetail(Nolock) Where id=@RecieptDtlId And Nature=@NatureOthers And DocumentType =@DebitNoteDocument)
								Begin
									Set @COAID=(Select Id From Bean.ChartOfAccount(Nolock) Where CompanyId=@CompanyId And Name=@COAotherReceivables )
									IF Exists(Select Id From Bean.DebitNote(Nolock) Where Id=@DocumentId And DocumentState In (@FullyApplied,@Fullypaid))
									Begin
										Set @IsRoundingAmount=1
									End
								End
								-- BillDocument Trade
								Else IF Exists (Select ID From Bean.ReceiptDetail(Nolock) Where id=@RecieptDtlId And DocumentType=@BillDocument And Nature=@NatureTrade)
								Begin
									Set @COAID=(Select Id From Bean.ChartOfAccount(Nolock) Where CompanyId=@CompanyId And Name=@COATradePayables)
									IF Exists(Select Id From Bean.Bill(Nolock) Where Id=@DocumentId And DocumentState In (@FullyApplied,@Fullypaid))
									Begin
										Set @IsRoundingAmount=1
									End
								End
								-- BillDocument Others
								Else IF Exists (Select ID From Bean.ReceiptDetail(Nolock) Where id=@RecieptDtlId And DocumentType=@BillDocument And Nature=@NatureOthers)
								Begin
									Set @COAID=(Select Id From Bean.ChartOfAccount(Nolock) Where CompanyId=@CompanyId And Name=@COAOtherPayables)
									IF Exists(Select Id From Bean.Bill(Nolock) Where Id=@DocumentId And DocumentState In (@FullyApplied,@Fullypaid))
									Begin
										Set @IsRoundingAmount=1
									End
								End
								IF @IsRoundingAmount=1 And Exists (Select Amount From @RoundingAmountDetails Where DocumentId=@DocumentId And Amount Is Not Null And Amount<>'')
								Begin
									Set @DocAmount=(Select Amount From @RoundingAmountDetails Where DocumentId=@DocumentId)
								End
								Else
								Begin
									Set @DocAmount=0
								End
								IF (Coalesce(@OffSetDocumentType,'NULL')=@BillDocument)
								Begin
									Set @RecOrderAnotherJV=@RecOrderAnotherJV+1
									Insert Into Bean.JournalDetail (Id,JournalId,COAId,AccountDescription, DocDebit,DocCredit,
																	 BaseDebit,BaseCredit,
																	 DocDebitTotal,DocCreditTotal,BaseDebitTotal,BaseCreditTotal,DocumentId,DocumentDetailId,ItemId,BaseCurrency,ExchangeRate, DocType,DocSubType,ServiceCompanyId,DocNo,Nature,OffsetDocument,IsTax,
																	EntityId, SystemRefNo, DocCurrency,DocDate, PostingDate,RecOrder 
																	)
									Select NEWID(),@JournalId,@COAID,R.Remarks,RD.ReceiptAmount As DocDebit,Null As DocCredit,
										Round(RD.ReceiptAmount * @DefaultExchangeRate,2)- Isnull(@DocAmount,0) As BaseDebit,Null As BaseCredit,
										0.00 As DocDebitTotal,0.00 As DocCreditTotal,0.00 As BaseDebitTotal,0.00 As BaseCreditTotal,R.Id As DocumentId,RD.Id As DocumentDetailId,@GUIDZero,
										R.BaseCurrency,@DefaultExchangeRate As ExchangeRate,@DocType,@DocSubType,RD.ServiceCompanyId,R.DocNo,RD.Nature,Null As DocumentNo,0 As IsTax,
										R.EntityId,@SystemRefNo,@DocCurrency,R.DocDate,R.DocDate,@RecOrderAnotherJV As RecOrder
									From Bean.Receipt(Nolock) As R
									Inner Join bean.ReceiptDetail(Nolock) As RD On RD.ReceiptId=R.Id
									Where R.Id=@SourceId And RD.Id=@RecieptDtlId
								End
								Else
								Begin
									Set @RecOrderAnotherJV=@RecOrderAnotherJV+1
									Insert Into Bean.JournalDetail (Id,JournalId,COAId,AccountDescription, DocDebit,DocCredit,
															 BaseDebit,BaseCredit,
															 DocDebitTotal,DocCreditTotal,BaseDebitTotal,BaseCreditTotal,DocumentId,DocumentDetailId,ItemId,BaseCurrency,ExchangeRate, DocType,DocSubType,ServiceCompanyId,DocNo,Nature,OffsetDocument,IsTax,
															EntityId, SystemRefNo, DocCurrency,DocDate, PostingDate,RecOrder 
															)
									Select NEWID(),@JournalId,@COAID,R.Remarks,Null As DocDebit,RD.ReceiptAmount As DocCredit,
										Null As BaseDebit,Round(RD.ReceiptAmount * @DefaultExchangeRate,2)- Isnull(@DocAmount,0) As BaseCredit,
										0.00 As DocDebitTotal,0.00 As DocCreditTotal,0.00 As BaseDebitTotal,0.00 As BaseCreditTotal,R.Id As DocumentId,RD.Id As DocumentDetailId,@GUIDZero,
										R.BaseCurrency,@DefaultExchangeRate As ExchangeRate,@DocType,@DocSubType,RD.ServiceCompanyId,R.DocNo,RD.Nature,RD.DocumentNo,0 As IsTax,
										R.EntityId,@SystemRefNo,@DocCurrency,R.DocDate,R.DocDate,@RecOrderAnotherJV As RecOrder
									From Bean.Receipt(Nolock) As R
									Inner Join bean.ReceiptDetail(Nolock) As RD On RD.ReceiptId=R.Id
									Where R.Id=@SourceId And RD.Id=@RecieptDtlId
								End
								Set @RdtlRecCount=@RdtlRecCount+1
							End
						End
						Set @RecCount=@RecCount+1
					End
					-- Credit Note Jv for master service company
					IF Exists (Select Id From Bean.ReceiptDetail(Nolock) Where ReceiptId=@SourceId And ServiceCompanyId=@MasterServComp And DocumentType =@CreditNoteDocument)
					Begin
						Set @RecOrder=@RecOrder+1
						Set @CreditNoteAmount=(Select Sum(Isnull(ReceiptAmount,0)) From Bean.ReceiptDetail(Nolock) Where ReceiptId=@SourceId And ServiceCompanyId=@MasterServComp And DocumentType =@CreditNoteDocument)
						Insert Into Bean.JournalDetail (Id,JournalId,COAId,AccountDescription, DocDebit,DocCredit,
																 BaseDebit,BaseCredit,
																 DocDebitTotal,DocCreditTotal,BaseDebitTotal,BaseCreditTotal,DocumentId,DocumentDetailId,ItemId,BaseCurrency,ExchangeRate, DocType,DocSubType,ServiceCompanyId,DocNo,Nature,OffsetDocument,IsTax,
																EntityId, SystemRefNo, DocCurrency,DocDate, PostingDate,RecOrder 
																)
						Select NEWID(),@MasterJournalId,@ClearingReceiptsCOAID,R.Remarks,Round((@CreditNoteAmount/@SysCalExchangerate),2) As DocDebit,Null As DocCredit,
							Round(@CreditNoteAmount * @DefaultExchangeRate,2) As BaseDebit, Null As BaseCredit,
							0.00 As DocDebitTotal,0.00 As DocCreditTotal,0.00 As BaseDebitTotal,0.00 As BaseCreditTotal,R.Id As DocumentId,@GUIDZero As DocumentDetailId,@GUIDZero,
							R.BaseCurrency,@DefaultExchangeRate As ExchangeRate,@DocType,@DocSubType,ServiceCompanyId As ServiceCompanyId,R.DocNo,Null As Nature,R.DocNo,0 As IsTax,
							R.EntityId,@MasterSystemRefNo,@BankChargesCurrency,R.DocDate,R.DocDate,@RecOrder As RecOrder
						From Bean.Receipt(Nolock) As R
						Where R.Id=@SourceId
					End
					-- Credit Memo Jv for master service company
					IF Exists (Select Id From Bean.ReceiptDetail(Nolock) Where ReceiptId=@SourceId And ServiceCompanyId=@MasterServComp And DocumentType =@CreditMemoDocument)
					Begin
						Set @RecOrder=@RecOrder+1
						Set @creditmemoAmount=(Select Sum(Isnull(ReceiptAmount,0)) From Bean.ReceiptDetail(Nolock) Where ReceiptId=@SourceId And ServiceCompanyId=@MasterServComp And DocumentType =@CreditMemoDocument)
						Insert Into Bean.JournalDetail (Id,JournalId,COAId,AccountDescription, DocDebit,DocCredit,
																 BaseDebit,BaseCredit,
																 DocDebitTotal,DocCreditTotal,BaseDebitTotal,BaseCreditTotal,DocumentId,DocumentDetailId,ItemId,BaseCurrency,ExchangeRate, DocType,DocSubType,ServiceCompanyId,DocNo,Nature,OffsetDocument,IsTax,
																EntityId, SystemRefNo, DocCurrency,DocDate, PostingDate,RecOrder 
																)
						Select NEWID(),@MasterJournalId,@ClearingReceiptsCOAID,R.Remarks,Null As DocDebit,Round((@creditmemoAmount/@SysCalExchangerate),2) As DocCredit,
							Null As BaseDebit,Round(@creditmemoAmount * @DefaultExchangeRate,2) As BaseCredit,
							0.00 As DocDebitTotal,0.00 As DocCreditTotal,0.00 As BaseDebitTotal,0.00 As BaseCreditTotal,R.Id As DocumentId,@GUIDZero As DocumentDetailId,@GUIDZero,
							R.BaseCurrency,@DefaultExchangeRate As ExchangeRate,@DocType,@DocSubType,ServiceCompanyId As ServiceCompanyId,R.DocNo,Null As Nature,R.DocNo,0 As IsTax,
							R.EntityId,@MasterSystemRefNo,@BankChargesCurrency,R.DocDate,R.DocDate,@RecOrder As RecOrder
						From Bean.Receipt(Nolock) As R
						Where R.Id=@SourceId
					End
					-- Main ServComp Detail records in journal detail
					Set @ClearingRecieptInvOrDNAmount=(Select Sum(Isnull(ReceiptAmount,0)) From Bean.ReceiptDetail(Nolock) Where ReceiptId=@SourceId And ServiceCompanyId=@MasterServComp And DocumentType in (@InvoiceDocument,@DebitNoteDocument))
					Set @ClearingRecieptBillAmount=(Select Sum(Isnull(ReceiptAmount,0)) From Bean.ReceiptDetail(Nolock) Where ReceiptId=@SourceId And ServiceCompanyId=@MasterServComp And DocumentType =@BillDocument)
					IF @ClearingRecieptInvOrDNAmount Is null
					Begin
						Set @ClearingRecieptInvOrDNAmount =Isnull(@ClearingRecieptInvOrDNAmount,0)
					End
					IF @ClearingRecieptBillAmount Is null
					Begin
						Set @ClearingRecieptBillAmount =Isnull(@ClearingRecieptBillAmount,0)
					End
					IF (@ClearingRecieptInvOrDNAmount Is Not Null And @ClearingRecieptInvOrDNAmount<>0) OR (@ClearingRecieptBillAmount Is Not Null And @ClearingRecieptBillAmount<>0)
					Begin
						Set @RecOrder=@RecOrder+1
						Insert Into Bean.JournalDetail (Id,JournalId,COAId,AccountDescription, DocDebit,DocCredit,
																 BaseDebit,BaseCredit,
																 DocDebitTotal,DocCreditTotal,BaseDebitTotal,BaseCreditTotal,DocumentId,DocumentDetailId,ItemId,BaseCurrency,ExchangeRate, DocType,DocSubType,ServiceCompanyId,DocNo,Nature,OffsetDocument,IsTax,
																EntityId, SystemRefNo, DocCurrency,DocDate, PostingDate,RecOrder 
																)
						Select NEWID(),@MasterJournalId,@ClearingReceiptsCOAID,R.Remarks,Case When @ClearingRecieptInvOrDNAmount<@ClearingRecieptBillAmount Then ABS(Round(((@ClearingRecieptInvOrDNAmount-@ClearingRecieptBillAmount) * @DefaultExchangeRate)/ @SysCalExchangerate,2)) End As DocDebit,
							Case When @ClearingRecieptInvOrDNAmount>@ClearingRecieptBillAmount Then ABS(Round(((@ClearingRecieptInvOrDNAmount-@ClearingRecieptBillAmount) * @DefaultExchangeRate)/ @SysCalExchangerate,2)) End As DocCredit,
							Case When @ClearingRecieptInvOrDNAmount<@ClearingRecieptBillAmount Then ABS(Round((@ClearingRecieptInvOrDNAmount-@ClearingRecieptBillAmount) * @DefaultExchangeRate,2)) End As BaseDebit,
							Case When @ClearingRecieptInvOrDNAmount>@ClearingRecieptBillAmount Then ABS(Round((@ClearingRecieptInvOrDNAmount-@ClearingRecieptBillAmount) * @DefaultExchangeRate,2)) End As BaseCredit,
							0.00 As DocDebitTotal,0.00 As DocCreditTotal,0.00 As BaseDebitTotal,0.00 As BaseCreditTotal,R.Id As DocumentId,@GUIDZero As DocumentDetailId,@GUIDZero,
							R.BaseCurrency,@SysCalExchangerate As ExchangeRate,@DocType,@DocSubType,@MasterServComp As ServiceCompanyId,R.DocNo,Null As Nature,R.DocNo,0 As IsTax,
							R.EntityId,@MasterSystemRefNo,@BankChargesCurrency,R.DocDate,R.DocDate,@RecOrder As RecOrder
						From Bean.Receipt(Nolock) As R
						Where R.Id=@SourceId
						-- Creating New Jv for Main ServComp Detail records 
						Set @JournalId=NEWID()
						Set @SysRefNum_Incr=@SysRefNum_Incr+1
						Set @SystemRefNo=CONCAT(@DocNo,'-JV',@SysRefNum_Incr)
						Insert Into Bean.Journal (Id,CompanyId,DocDate,DocType,DocSubType,DocNo,ServiceCompanyId,SystemReferenceNo,IsNoSupportingDocs,NoSupportingDocument,DocCurrency,ExchangeRate,ExCurrency,ExDurationFrom,GSTExchangeRate,GSTExCurrency,GSTTotalAmount,DocumentState,IsNoSupportingDocument,IsGstSettings,IsMultiCurrency,IsAllowableNonAllowable,IsGSTCurrencyRateChanged,Remarks,UserCreated,CreatedDate,Status,DocumentDescription,CreationType,GrandDocDebitTotal,GrandDocCreditTotal,GrandBaseDebitTotal,
												 GrandBaseCreditTotal,EntityId,EntityType,PostingDate,COAId,ModeOfReceipt,BankReceiptAmmount,ExcessPaidByClientAmmount,BalancingItemReciveCRAmount,  BalancingItemPayDRAmount,ReceiptApplicationAmmount,DocumentId, BankClearingDate ,IsBalancing,ISAllowDisAllow, IsShow, ActualSysRefNo 
												 ,IsSegmentReporting,TransferRefNo
												 )
						Select @JournalId,@CompanyId,DocDate,@DocType,@DocSubType,DocNo,@MasterServComp As ServiceCompanyId,@SystemRefNo As SystemRefNo,IsNoSupportingDocument,NoSupportingDocs,DocCurrency,ExchangeRate,ExCurrency,ExDurationFrom,GSTExchangeRate,GSTExCurrency,Isnull(GSTTotalAmount,0),DocumentState,NoSupportingDocs,IsGstSettings,IsMultiCurrency,IsAllowableDisallowable,IsGSTCurrencyRateChanged,Remarks,@UserCreated,@CreatedDate,Status,Remarks As DocDescription,@UserCreated,GrandTotal,0.00 As GrandDocCreditTotal,GrandTotal * Round(ExchangeRate,2) As GrandBaseDebitTotal,
								0.00 As GrandBaseCreditTotal,EntityId,EntityType,DocDate As PostingDate,@IntroCompCOAID As COAId,ModeOfReceipt,0.00 As BankReceiptAmmount,0.00 As ExcessPaidByClientAmmount,0.00 As BalancingItemReciveCRAmount,0.00 As BalancingItemPayDRAmount,0.00 As ReceiptApplicationAmmount,Id As DocumentId,BankClearingDate,0 As IsBalancing,IsDisAllow,1 As IsShow,DocNo As ActualSysRefNo,0 As IsSegmentReporting,ReceiptRefNo
						From Bean.Receipt(Nolock) Where CompanyId=@CompanyId And Id=@SourceId
						Set @RecOrder=@RecOrder+1
						Insert Into Bean.JournalDetail (Id,JournalId,COAId,AccountDescription, DocDebit,DocCredit,
														 BaseDebit,BaseCredit,
														 DocDebitTotal,DocCreditTotal,BaseDebitTotal,BaseCreditTotal,DocumentId,DocumentDetailId,ItemId,BaseCurrency,ExchangeRate, DocType,DocSubType,ServiceCompanyId,DocNo,Nature,OffsetDocument,IsTax,
														EntityId, SystemRefNo, DocCurrency,DocDate, PostingDate,RecOrder 
														)
						Select NEWID(),@JournalId,@ClearingReceiptsCOAID,R.Remarks,
							Case When @ClearingRecieptInvOrDNAmount>@ClearingRecieptBillAmount Then ABS(@ClearingRecieptInvOrDNAmount-@ClearingRecieptBillAmount) End As DocDebit,
							Case When @ClearingRecieptInvOrDNAmount<@ClearingRecieptBillAmount Then ABS(@ClearingRecieptInvOrDNAmount-@ClearingRecieptBillAmount) End As DocCredit,
							Case When @ClearingRecieptInvOrDNAmount>@ClearingRecieptBillAmount Then ABS(Round((@ClearingRecieptInvOrDNAmount-@ClearingRecieptBillAmount) * @DefaultExchangeRate,2)) End As BaseDebit,
							Case When @ClearingRecieptInvOrDNAmount<@ClearingRecieptBillAmount Then ABS(Round((@ClearingRecieptInvOrDNAmount-@ClearingRecieptBillAmount) * @DefaultExchangeRate,2)) End As BaseCredit,
							0.00 As DocDebitTotal,0.00 As DocCreditTotal,0.00 As BaseDebitTotal,0.00 As BaseCreditTotal,R.Id As DocumentId,@GUIDZero As DocumentDetailId,@GUIDZero,
							R.BaseCurrency,@DefaultExchangeRate As ExchangeRate,@DocType,@DocSubType,@MasterServComp As ServiceCompanyId,R.DocNo,Null As Nature,R.DocNo,0 As IsTax,
							R.EntityId,@SystemRefNo,@DocCurrency,R.DocDate,R.DocDate,@RecOrder As RecOrder
						From Bean.Receipt(Nolock) As R
						Where R.Id=@SourceId
						
						-- Creating Records For Interco In Journal Detail
						Insert Into @RecieptDtl 
						Select RD.Id From Bean.ReceiptDetail(Nolock) As RD
						Inner Join Bean.Receipt(Nolock) As R On RD.ReceiptId=R.Id 
						Where R.Id=@SourceId And RD.ReceiptAmount<>0 And RD.ServiceCompanyId=@MasterServComp And RD.DocumentType Not In (@CreditMemoDocument,@CreditNoteDocument) Order By RD.RecOrder 
						Set @Count=(Select Count(*) From @RecieptDtl)
						Set @RecCount=1
						While @Count>=@RecCount
						Begin
							Set @RecieptDtlId=(Select RecieptDtlId From @RecieptDtl Where S_No=@RecCount)
							Set @OffSetDocumentType=(Select DocumentType from Bean.ReceiptDetail(Nolock) Where Id=@RecieptDtlId)
							Set @DocumentId=(Select DocumentId From Bean.ReceiptDetail(Nolock) Where Id=@RecieptDtlId)
							Set @ServCompId=@MasterServComp
							Set @IsRoundingAmount=0
							IF Coalesce(@OffSetDocumentType,'NULL')=@CreditNoteDocument Or  Coalesce(@OffSetDocumentType,'NULL')=@CreditMemoDocument
							Begin
								Set @DocAmount=0
							End
							--Getting COAID By Checking Nature
							IF Exists (Select ID From Bean.ReceiptDetail(Nolock) Where id=@RecieptDtlId And Nature=@NatureTrade And DocumentType =@InvoiceDocument)
							Begin
								Set @COAID=(Select Id From Bean.ChartOfAccount(Nolock) Where CompanyId=@CompanyId And Name=@COATradeReceivables)
								IF Exists(Select Id From Bean.Invoice(Nolock) Where Id=@DocumentId And DocumentState In (@FullyApplied,@Fullypaid))
								Begin
									Set @IsRoundingAmount=1
								End
							End
							Else IF Exists (Select ID From Bean.ReceiptDetail(Nolock) Where id=@RecieptDtlId And Nature=@NatureOthers And DocumentType =@InvoiceDocument)
							Begin
								Set @COAID=(Select Id From Bean.ChartOfAccount(Nolock) Where CompanyId=@CompanyId And Name=@COAotherReceivables )
								IF Exists(Select Id From Bean.Invoice(Nolock) Where Id=@DocumentId And DocumentState In (@FullyApplied,@Fullypaid))
								Begin
									Set @IsRoundingAmount=1
								End
							End
							Else IF Exists (Select ID From Bean.ReceiptDetail(Nolock) Where id=@RecieptDtlId And Nature=@NatureTrade And DocumentType =@DebitNoteDocument)
							Begin
								Set @COAID=(Select Id From Bean.ChartOfAccount(Nolock) Where CompanyId=@CompanyId And Name=@COATradeReceivables)
								IF Exists(Select Id From Bean.DebitNote(Nolock) Where Id=@DocumentId And DocumentState In (@FullyApplied,@Fullypaid))
								Begin
									Set @IsRoundingAmount=1
								End
							End
							Else IF Exists (Select ID From Bean.ReceiptDetail(Nolock) Where id=@RecieptDtlId And Nature=@NatureOthers And DocumentType =@DebitNoteDocument)
							Begin
								Set @COAID=(Select Id From Bean.ChartOfAccount(Nolock) Where CompanyId=@CompanyId And Name=@COAotherReceivables )
								IF Exists(Select Id From Bean.DebitNote(Nolock) Where Id=@DocumentId And DocumentState In (@FullyApplied,@Fullypaid))
								Begin
									Set @IsRoundingAmount=1
								End
							End
							Else IF Exists (Select ID From Bean.ReceiptDetail(Nolock) Where id=@RecieptDtlId And DocumentType=@CreditNoteDocument)
							Begin
								Set @COAID=(Select Id From Bean.ChartOfAccount(Nolock) Where CompanyId=@CompanyId And Name=@ClearingReceipts)
							End
							Else IF Exists (Select ID From Bean.ReceiptDetail(Nolock) Where id=@RecieptDtlId And DocumentType=@CreditMemoDocument And Nature=@NatureTrade)
							Begin
								Set @COAID=(Select Id From Bean.ChartOfAccount(Nolock) Where CompanyId=@CompanyId And Name=@COATradePayables)
							End
							Else IF Exists (Select ID From Bean.ReceiptDetail(Nolock) Where id=@RecieptDtlId And DocumentType=@CreditMemoDocument And Nature=@NatureOthers)
							Begin
								Set @COAID=(Select Id From Bean.ChartOfAccount(Nolock) Where CompanyId=@CompanyId And Name=@COAOtherPayables)
							End
							Else IF Exists (Select ID From Bean.ReceiptDetail(Nolock) Where id=@RecieptDtlId And DocumentType=@BillDocument And Nature=@NatureTrade)
							Begin
								Set @COAID=(Select Id From Bean.ChartOfAccount(Nolock) Where CompanyId=@CompanyId And Name=@COATradePayables)
								IF Exists(Select Id From Bean.Bill(Nolock) Where Id=@DocumentId And DocumentState In (@FullyApplied,@Fullypaid))
								Begin
									Set @IsRoundingAmount=1
								End
							End
							Else IF Exists (Select ID From Bean.ReceiptDetail(Nolock) Where id=@RecieptDtlId And DocumentType=@BillDocument And Nature=@NatureOthers)
							Begin
								Set @COAID=(Select Id From Bean.ChartOfAccount(Nolock) Where CompanyId=@CompanyId And Name=@COAOtherPayables)
								IF Exists(Select Id From Bean.Bill(Nolock) Where Id=@DocumentId And DocumentState In (@FullyApplied,@Fullypaid))
								Begin
									Set @IsRoundingAmount=1
								End
							End
							IF @IsRoundingAmount=1 And Exists (Select Amount From @RoundingAmountDetails Where DocumentId=@DocumentId And Amount Is Not Null And Amount<>'')
							Begin
								Set @DocAmount=(Select Amount From @RoundingAmountDetails Where DocumentId=@DocumentId)
							End
							Else
							Begin
								Set @DocAmount=0
							End
							IF Coalesce(@OffSetDocumentType,'NULL')=@BillDocument
							Begin
								Set @RecOrder=@RecOrder+1
								Insert Into Bean.JournalDetail (Id,JournalId,COAId,AccountDescription, DocDebit,DocCredit,
																 BaseDebit,BaseCredit,
																 DocDebitTotal,DocCreditTotal,BaseDebitTotal,BaseCreditTotal,DocumentId,DocumentDetailId,ItemId,BaseCurrency,ExchangeRate, DocType,DocSubType,ServiceCompanyId,DocNo,Nature,OffsetDocument,IsTax,
																EntityId, SystemRefNo, DocCurrency,DocDate, PostingDate,RecOrder 
																)
								Select NEWID(),@JournalId,@COAID,R.Remarks,RD.ReceiptAmount As DocDebit,Null As DocCredit,
									Round(RD.ReceiptAmount * @DefaultExchangeRate,2)- Isnull(@DocAmount,0) As BaseDebit,Null As BaseCredit,
									0.00 As DocDebitTotal,0.00 As DocCreditTotal,0.00 As BaseDebitTotal,0.00 As BaseCreditTotal,R.Id As DocumentId,RD.Id As DocumentDetailId,@GUIDZero,
									R.BaseCurrency,@DefaultExchangeRate As ExchangeRate,@DocType,@DocSubType,RD.ServiceCompanyId,R.DocNo,RD.Nature,Null As DocumentNo,0 As IsTax,
									R.EntityId,@SystemRefNo,@DocCurrency,R.DocDate,R.DocDate,@RecOrder As RecOrder
								From Bean.Receipt(Nolock) As R
								Inner Join bean.ReceiptDetail(Nolock) As RD On RD.ReceiptId=R.Id
								Where R.Id=@SourceId And RD.Id=@RecieptDtlId
							End
							Else
							Begin
								Set @RecOrder=@RecOrder+1
								Insert Into Bean.JournalDetail (Id,JournalId,COAId,AccountDescription, DocDebit,DocCredit,
														 BaseDebit,BaseCredit,
														 DocDebitTotal,DocCreditTotal,BaseDebitTotal,BaseCreditTotal,DocumentId,DocumentDetailId,ItemId,BaseCurrency,ExchangeRate, DocType,DocSubType,ServiceCompanyId,DocNo,Nature,OffsetDocument,IsTax,
														EntityId, SystemRefNo, DocCurrency,DocDate, PostingDate,RecOrder 
														)
								Select NEWID(),@JournalId,@COAID,R.Remarks,Null As DocDebit,RD.ReceiptAmount As DocCredit,
									Null As BaseDebit,Round(RD.ReceiptAmount * @DefaultExchangeRate,2)- Isnull(@DocAmount,0) As BaseCredit,
									0.00 As DocDebitTotal,0.00 As DocCreditTotal,0.00 As BaseDebitTotal,0.00 As BaseCreditTotal,R.Id As DocumentId,RD.Id As DocumentDetailId,@GUIDZero,
									R.BaseCurrency,@DefaultExchangeRate As ExchangeRate,@DocType,@DocSubType,RD.ServiceCompanyId,R.DocNo,RD.Nature,RD.DocumentNo,0 As IsTax,
									R.EntityId,@SystemRefNo,@DocCurrency,R.DocDate,R.DocDate,@RecOrder As RecOrder
								From Bean.Receipt(Nolock) As R
								Inner Join bean.ReceiptDetail(Nolock) As RD On RD.ReceiptId=R.Id
								Where R.Id=@SourceId And RD.Id=@RecieptDtlId
							End
							Set @RecCount=@RecCount+1
						End
					End
				End
				Else IF @DocCurrency<>@BankChargesCurrency And @BaseCurrency<>@DocCurrency
				Begin
					/* Creating Mater record In JournalDetail */
					IF Exists (Select Id From Bean.Receipt(Nolock) Where Id=@SourceId And GrandTotal<>0)
					Begin
						Insert Into Bean.JournalDetail (Id,JournalId,COAId,AccountDescription,AllowDisAllow, DocDebit, BaseDebit, DocDebitTotal,DocCreditTotal,BaseDebitTotal,BaseCreditTotal,DocumentId,DocumentDetailId,ItemId,BaseCurrency,ExchangeRate,GSTExCurrency,GSTExchangeRate,DocType,DocSubType,ServiceCompanyId,DocNo, IsTax,
										EntityId, SystemRefNo, DocCurrency,DocDate, PostingDate,RecOrder )
						Select NEWID(),@MasterJournalId,COAId,Remarks,IsDisAllow,Isnull(BankReceiptAmmount,0) As BankReceiptAmmount,Round(Isnull(BankReceiptAmmount,0) * @DefaultExchangeRate,2),0.00 As DocDebitTotal,0.00 As DocCreditTotal,0.00 As BaseDebitTotal,0.00 As BaseCreditTotal,Id As DocumentId,@GUIDZero,@GUIDZero,
								BaseCurrency,@DefaultExchangeRate,GSTExCurrency,GSTExchangeRate,@DocType,@DocSubType,ServiceCompanyId,DocNo,0 As IsTax,
								EntityId,@MasterSystemRefNo As SystemRefNo,@BankChargesCurrency,DocDate,DocDate,@RecOrder As RecOrder
						From Bean.Receipt(Nolock) Where Id=@SourceId
					End
					Else IF Exists (Select Id From Bean.Receipt(Nolock) Where Id=@SourceId And GrandTotal=0 And BankReceiptAmmount<>0)
					Begin
						Insert Into Bean.JournalDetail (Id,JournalId,COAId,AccountDescription,AllowDisAllow, DocDebit, BaseDebit, DocDebitTotal,DocCreditTotal,BaseDebitTotal,BaseCreditTotal,DocumentId,DocumentDetailId,ItemId,BaseCurrency,ExchangeRate,GSTExCurrency,GSTExchangeRate,DocType,DocSubType,ServiceCompanyId,DocNo, IsTax,
										EntityId, SystemRefNo, DocCurrency,DocDate, PostingDate,RecOrder )
						Select NEWID(),@MasterJournalId,COAId,Remarks,IsDisAllow,Isnull(BankReceiptAmmount,0) As BankReceiptAmmount,Round(Isnull(BankReceiptAmmount,0) * @DefaultExchangeRate,2),0.00 As DocDebitTotal,0.00 As DocCreditTotal,0.00 As BaseDebitTotal,0.00 As BaseCreditTotal,Id As DocumentId,@GUIDZero,@GUIDZero,
								BaseCurrency,@DefaultExchangeRate,GSTExCurrency,GSTExchangeRate,@DocType,@DocSubType,ServiceCompanyId,DocNo,0 As IsTax,
								EntityId,@MasterSystemRefNo As SystemRefNo,@BankChargesCurrency,DocDate,DocDate,@RecOrder As RecOrder
						From Bean.Receipt(Nolock) Where Id=@SourceId
					End
					/* Creating Record in Journaldetail With Bank Charges Amount */
					If Exists(Select Id From Bean.Receipt(Nolock) Where Id=@SourceId And BankCharges Is Not Null)
					Begin
						Set @RecOrder=@RecOrder+1
						Insert Into Bean.JournalDetail (Id,JournalId,COAId,AccountDescription,AllowDisAllow,TaxId,TaxType,TaxRate,DocDebit, BaseDebit, DocDebitTotal,DocCreditTotal,BaseDebitTotal,BaseCreditTotal,DocumentId,DocumentDetailId,ItemId,BaseCurrency,ExchangeRate,GSTExCurrency,GSTExchangeRate,DocType,DocSubType,ServiceCompanyId,DocNo, IsTax,
													EntityId, SystemRefNo, DocCurrency,DocDate, PostingDate,RecOrder,GSTTaxDebit)
						Select NEWID(),@MasterJournalId,@BankCharges_COAId,Remarks,IsDisAllow,@TaxId,@TaxType,@TaxRate,BankCharges,Round(BankCharges * @DefaultExchangeRate,2),0.00 As DocDebitTotal,0.00 As DocCreditTotal,0.00 As BaseDebitTotal,0.00 As BaseCreditTotal,Id As DocumentId,Id As DocumentDetailId,@GUIDZero,
							BaseCurrency,@DefaultExchangeRate,GSTExCurrency,GSTExchangeRate,@DocType,@DocSubType,ServiceCompanyId,DocNo,0 As IsTax,
							EntityId,@MasterSystemRefNo As SystemRefNo,@BankChargesCurrency,DocDate,DocDate,@RecOrder As RecOrder,
							Case When @TaxId Is Not Null Then Round(BankCharges * Coalesce(GSTexchangerate,@DefaultExchangeRate),2) End As GSTTaxDebit
						From Bean.Receipt(Nolock) 
						Where Id=@SourceId
					End
					/* Creating Record in Journaldetail With ExcesPaidByClientAmt Amount */
					If @ExcesPaidByClientAmt Is NOt Null
					Begin
						Set @RecOrder=@RecOrder+1
						Insert Into Bean.JournalDetail (Id,JournalId,COAId,AccountDescription,AllowDisAllow, DocCredit, BaseCredit, DocDebitTotal,DocCreditTotal,BaseDebitTotal,BaseCreditTotal,DocumentId,DocumentDetailId,ItemId,BaseCurrency,ExchangeRate,GSTExCurrency,GSTExchangeRate,DocType,DocSubType,ServiceCompanyId,DocNo, IsTax,
														EntityId, SystemRefNo, DocCurrency,DocDate, PostingDate,RecOrder )
						Select NEWID(),@MasterJournalId,@ClearingReceiptsCOAID,Remarks,IsDisAllow,ExcessPaidByClientAmmount,Round(ExcessPaidByClientAmmount * @DefaultExchangeRate,2),0.00 As DocDebitTotal,0.00 As DocCreditTotal,0.00 As BaseDebitTotal,0.00 As BaseCreditTotal,Id As DocumentId,Id As DocumentDtlId,@GUIDZero,
								BaseCurrency,@DefaultExchangeRate,BankReceiptAmmountCurrency,ExchangeRate,@DocType,@DocSubType,ServiceCompanyId,DocNo,0 As IsTax,
								EntityId,@MasterSystemRefNo,@BankChargesCurrency,DocDate,DocDate,@RecOrder As RecOrder
						From Bean.Receipt(Nolock) 
						Where Id=@SourceId
					End
					/* Creating Balancing Line Items */
					Insert Into @RecieptBalLnItm
					Select RBI.Id From Bean.ReceiptBalancingItem(Nolock) As RBI
					Inner Join bean.Receipt(Nolock) As R On R.Id=RBI.ReceiptId
					Where R.Id=@SourceId Order by RecOrder
					Set @Count=(Select Count(*) From @RecieptBalLnItm)
					Set @RecCount=1
					While @Count>=@RecCount
					Begin
						Select @RecieptBalId=RecieptBalId From @RecieptBalLnItm Where S_no=@RecCount
						Select @TaxId=TaxId,@TaxRate=TaxRate From Bean.ReceiptBalancingItem(Nolock) Where Id=@RecieptBalId
						Set @RecOrder=@RecOrder+1
						Insert Into Bean.JournalDetail (Id,JournalId,COAId,AccountDescription,AllowDisAllow,TaxId,TaxType,TaxRate,DocDebit,DocCredit,
													DocTaxDebit,DocTaxCredit,BaseDebit,BaseCredit,
													BaseTaxDebit,BaseTaxCredit,DocDebitTotal,DocCreditTotal,BaseDebitTotal,BaseCreditTotal,DocumentId,DocumentDetailId,ItemId,BaseCurrency,ExchangeRate,GSTExCurrency,GSTExchangeRate,DocType,DocSubType,ServiceCompanyId,DocNo, IsTax,
													EntityId, SystemRefNo, DocCurrency,DocDate, PostingDate,RecOrder,GSTTaxDebit,GSTTaxCredit,GSTDebit,GSTCredit)
						Select NEWID(),@MasterJournalId,RBi.COAId,R.Remarks,RBI.IsDisAllow,RBI.TaxId,RBI.TaxType,Rbi.TaxRate,
							Case When RBI.ReciveORPay=@Pay_Dr Then RBI.DocAmount End As DocDebit,Case When RBI.ReciveORPay=@Receive_Cr Then RBI.DocAmount End As DocCredit,
							Case When RBI.ReciveORPay=@Pay_Dr Then RBI.DocTaxAmount End As DocTaxDebdit,
							Case When RBI.ReciveORPay=@Receive_Cr Then RBI.DocTaxAmount End As DocTaxCredit,
							Case When RBI.ReciveORPay=@Pay_Dr Then Round(RBI.DocAmount * @DefaultExchangeRate,2) End As BaseDebit,
							Case When RBI.ReciveORPay=@Receive_Cr Then Round(RBI.DocAmount * @DefaultExchangeRate,2) End As BaseCredit,
							Case When RBI.ReciveORPay=@Pay_Dr Then Round(RBI.DocTaxAmount * @DefaultExchangeRate,2) End As BaseTaxDebdit,
							Case When RBI.ReciveORPay=@Receive_Cr Then Round(RBI.DocTaxAmount * @DefaultExchangeRate,2) End As BaseTaxCredit,0.00 As DocDebitTotal,0.00 As DocCreditTotal,0.00 As BaseDebitTotal,0.00 As BaseCreditTotal,R.Id As DocumentId,RBI.Id As DocumentDetailId,@GUIDZero,
							R.BaseCurrency,@DefaultExchangeRate As ExchangeRate,R.GSTExCurrency,R.GSTExchangeRate,@DocType,@DocSubType,ServiceCompanyId,DocNo,0 As IsTax,
							EntityId,@MasterSystemRefNo,@BankChargesCurrency,DocDate,DocDate,@RecOrder As RecOrder,
							Case When RBI.ReciveORPay=@Pay_Dr Then Round(RBI.DocAmount * Coalesce(R.GSTExchangeRate,@DefaultExchangeRate),2) End As GSTTaxDebit,
							Case When RBI.ReciveORPay=@Receive_Cr Then Round(RBI.DocAmount * Coalesce(R.GSTExchangeRate,@DefaultExchangeRate),2) End As GSTTaxCredit,
							Case When RBI.ReciveORPay=@Pay_Dr Then Round(RBI.DocTaxAmount * Coalesce(R.GSTExchangeRate,@DefaultExchangeRate),2) End As GSTDebit,
							Case When RBI.ReciveORPay=@Receive_Cr Then Round(RBI.DocTaxAmount * Coalesce(R.GSTExchangeRate,@DefaultExchangeRate),2) End As GSTCredit
						From Bean.Receipt(Nolock) As R
						Inner Join bean.ReceiptBalancingItem(Nolock) As RBI On RBI.ReceiptId=R.Id
						Where R.Id=@SourceId And Rbi.Id=@RecieptBalId
						-- Creating Tax Line Items
						If @GST Is Not Null And @GST=1 And @TaxId Is Not Null And (@TaxRate Is Not Null And @TaxRate<>0)
						Begin
							Set @TaxRecCount=@RecOrder+@Count
							Insert Into Bean.JournalDetail (Id,JournalId,COAId,AccountDescription,AllowDisAllow,TaxId,TaxType,TaxRate,DocDebit,DocCredit,
									 BaseDebit,BaseCredit,
									 DocDebitTotal,DocCreditTotal,BaseDebitTotal,BaseCreditTotal,DocumentId,DocumentDetailId,ItemId,BaseCurrency,ExchangeRate,GSTExCurrency,GSTExchangeRate,DocType,DocSubType,ServiceCompanyId,DocNo, IsTax,
									EntityId, SystemRefNo, DocCurrency,DocDate, PostingDate,RecOrder )
							Select NEWID(),@MasterJournalId,@TaxPayableGST_COAID as COAId,R.Remarks,RBI.IsDisAllow,RBI.TaxId,RBI.TaxType,Rbi.TaxRate,Case When RBI.ReciveORPay=@Pay_Dr Then RBI.DocTaxAmount End As DocDebit,Case When RBI.ReciveORPay=@Receive_Cr Then RBI.DocTaxAmount End As DocCredit,
								Case When RBI.ReciveORPay=@Pay_Dr Then Round(RBI.DocTaxAmount * @DefaultExchangeRate,2) End As BaseDebit,Case When RBI.ReciveORPay=@Receive_Cr Then Round(RBI.DocTaxAmount * @DefaultExchangeRate,2) End As BaseCredit,
								0.00 As DocDebitTotal,0.00 As DocCreditTotal,0.00 As BaseDebitTotal,0.00 As BaseCreditTotal,R.Id As DocumentId,RBI.Id As DocumentDetailId,@GUIDZero,
								R.BaseCurrency,@DefaultExchangeRate As ExchangeRate,R.GSTExCurrency,R.GSTExchangeRate,@DocType,@DocSubType,ServiceCompanyId,DocNo,1 As IsTax,
								EntityId,@MasterSystemRefNo,@BankChargesCurrency,DocDate,DocDate,@TaxRecCount As RecOrder
							From Bean.Receipt(Nolock) As R
							Inner Join bean.ReceiptBalancingItem(Nolock) As RBI On RBI.ReceiptId=R.Id
							Where R.Id=@SourceId And Rbi.Id=@RecieptBalId
						End
						Set @RecCount=@RecCount+1
					End
					-- ServComp Records
					Insert Into @ServCompaIdTbl
					Select Distinct RD.ServiceCompanyId From Bean.ReceiptDetail(Nolock) As RD
					Inner Join Bean.Receipt(Nolock) As R On RD.ReceiptId=R.Id 
					Where R.Id=@SourceId And RD.ReceiptAmount<>0 And RD.ServiceCompanyId<>@MasterServComp  /*And ReceiptAmount<>0*/
					--Group By RD.ServiceCompanyId Order By RD.RecOrder 
					Set @Count=(Select Count(*) From @ServCompaIdTbl)
					Set @RecCount=1
					While @Count>=@RecCount
					Begin
						Select @ServCompId=SerCompId From @ServCompaIdTbl Where S_No=@RecCount
						Set @IntroCompCOAID=(Select COA.Id From Bean.ChartOfAccount(Nolock) As COA 
												Inner Join Bean.AccountType(Nolock) As ACT On ACT.Id=COA.AccountTypeId
												Where ACT.CompanyId=@CompanyId And ACT.Name=@IntercompClearingCOAName And COA.SubsidaryCompanyId=@ServCompId)
						Set @ClearingRecieptInvOrDNAmount=(Select Sum(Isnull(ReceiptAmount,0)) From bean.ReceiptDetail(Nolock) Where ReceiptId=@SourceId And ServiceCompanyId=@ServCompId And DocumentType In (@InvoiceDocument ,@DebitNoteDocument))
						Set @ClearingRecieptBillAmount=(Select Sum(Isnull(ReceiptAmount,0)) From bean.ReceiptDetail(Nolock) Where ReceiptId=@SourceId And ServiceCompanyId=@ServCompId And DocumentType=@BillDocument) 
						Set @CreditNoteAmount=(Select Sum(Isnull(ReceiptAmount,0)) From Bean.ReceiptDetail(Nolock) Where ReceiptId=@SourceId And ServiceCompanyId=@ServCompId And DocumentType=@CreditNoteDocument)
						Set @CreditMemoAmount=(Select Sum(Isnull(ReceiptAmount,0)) From Bean.ReceiptDetail(Nolock) Where ReceiptId=@SourceId And ServiceCompanyId=@ServCompId And DocumentType=@CreditMemoDocument)
						IF @CreditNoteAmount Is null
						Begin
							Set @CreditNoteAmount =Isnull(@CreditNoteAmount,0)
						End
						IF @CreditMemoAmount Is null
						Begin
							Set @CreditMemoAmount =Isnull(@CreditMemoAmount,0)
						End
						IF @ClearingRecieptInvOrDNAmount Is null
						Begin
							Set @ClearingRecieptInvOrDNAmount =Isnull(@ClearingRecieptInvOrDNAmount,0)
						End
						IF @ClearingRecieptBillAmount Is null
						Begin
							Set @ClearingRecieptBillAmount =Isnull(@ClearingRecieptBillAmount,0)
						End
						-- CreditMemoAmount
						IF @CreditMemoAmount Is Not Null And @CreditMemoAmount<>0
						Begin
							Set @RecOrder=@RecOrder+1
							Insert Into Bean.JournalDetail (Id,JournalId,COAId,AccountDescription, DocDebit,DocCredit,
														 BaseDebit,BaseCredit,
														 DocDebitTotal,DocCreditTotal,BaseDebitTotal,BaseCreditTotal,DocumentId,DocumentDetailId,ItemId,BaseCurrency,ExchangeRate, DocType,DocSubType,ServiceCompanyId,DocNo,Nature,OffsetDocument,IsTax,
														EntityId, SystemRefNo, DocCurrency,DocDate, PostingDate,RecOrder 
														)
							Select NEWID(),@MasterJournalId,@IntroCompCOAID,R.Remarks,Null As DocDebit,Round(@CreditMemoAmount * @SysCalExchangerate,2) As DocCredit,
								Null As BaseDebit,Round((@CreditMemoAmount * @SysCalExchangerate) * @DefaultExchangeRate,2) As BaseCredit,
								0.00 As DocDebitTotal,0.00 As DocCreditTotal,0.00 As BaseDebitTotal,0.00 As BaseCreditTotal,R.Id As DocumentId,@GUIDZero As DocumentDetailId,@GUIDZero,
								R.BaseCurrency,@DefaultExchangeRate As ExchangeRate,@DocType,@DocSubType,ServiceCompanyId As ServiceCompanyId,R.DocNo,Null As Nature,R.DocNo,0 As IsTax,
								R.EntityId,@MasterSystemRefNo,@BankChargesCurrency,R.DocDate,R.DocDate,@RecOrder As RecOrder
							From Bean.Receipt(Nolock) As R
							Where R.Id=@SourceId
							-- Create CreditMemo Journal I/C
							Set @JournalId=NEWID()
							Set @SysRefNum_Incr=@SysRefNum_Incr+1
							Set @SystemRefNo=CONCAT(@DocNo,'-JV',@SysRefNum_Incr)
							Insert Into Bean.Journal (Id,CompanyId,DocDate,DocType,DocSubType,DocNo,ServiceCompanyId,SystemReferenceNo,IsNoSupportingDocs,NoSupportingDocument,DocCurrency,ExchangeRate,ExCurrency,ExDurationFrom,GSTExchangeRate,GSTExCurrency,GSTTotalAmount,DocumentState,IsNoSupportingDocument,IsGstSettings,IsMultiCurrency,IsAllowableNonAllowable,IsGSTCurrencyRateChanged,Remarks,UserCreated,CreatedDate,Status,DocumentDescription,CreationType,GrandDocDebitTotal,GrandDocCreditTotal,GrandBaseDebitTotal,
														GrandBaseCreditTotal,EntityId,EntityType,PostingDate,COAId,ModeOfReceipt,BankReceiptAmmount,ExcessPaidByClientAmmount,BalancingItemReciveCRAmount,  BalancingItemPayDRAmount,ReceiptApplicationAmmount,DocumentId, BankClearingDate ,IsBalancing,ISAllowDisAllow, IsShow, ActualSysRefNo 
														,IsSegmentReporting,TransferRefNo
													 )
							Select @JournalId,@CompanyId,DocDate,@DocType,@DocSubType,DocNo,@ServCompId As ServiceCompanyId,@SystemRefNo As SystemRefNo,IsNoSupportingDocument,NoSupportingDocs,DocCurrency,ExchangeRate,ExCurrency,ExDurationFrom,GSTExchangeRate,GSTExCurrency,Isnull(GSTTotalAmount,0),DocumentState,NoSupportingDocs,IsGstSettings,IsMultiCurrency,IsAllowableDisallowable,IsGSTCurrencyRateChanged,Remarks,@UserCreated,@CreatedDate,Status,Remarks As DocDescription,@UserCreated,GrandTotal,0.00 As GrandDocCreditTotal,GrandTotal * Round(ExchangeRate,2) As GrandBaseDebitTotal,
									0.00 As GrandBaseCreditTotal,EntityId,EntityType,DocDate As PostingDate,@IntroCompCOAID As COAId,ModeOfReceipt,0.00 As BankReceiptAmmount,0.00 As ExcessPaidByClientAmmount,0.00 As BalancingItemReciveCRAmount,0.00 As BalancingItemPayDRAmount,0.00 As ReceiptApplicationAmmount,Id As DocumentId,BankClearingDate,0 As IsBalancing,IsDisAllow,1 As IsShow,DocNo As ActualSysRefNo,0 As IsSegmentReporting,ReceiptRefNo
							From Bean.Receipt(Nolock) Where CompanyId=@CompanyId And Id=@SourceId
							-- Create CreditMemo Journal I/C JD COA
							Set @RecOrderAnotherJV=1
							Insert Into Bean.JournalDetail (Id,JournalId,COAId,AccountDescription, DocDebit,DocCredit,
														 BaseDebit,BaseCredit,
														 DocDebitTotal,DocCreditTotal,BaseDebitTotal,BaseCreditTotal,DocumentId,DocumentDetailId,ItemId,BaseCurrency,ExchangeRate, DocType,DocSubType,ServiceCompanyId,DocNo,Nature,OffsetDocument,IsTax,
														EntityId, SystemRefNo, DocCurrency,DocDate, PostingDate,RecOrder 
														)
							Select NEWID(),@JournalId,@MainInterCoServCompCOAID,R.Remarks,Round(@CreditMemoAmount * @SysCalExchangerate,2) As DocDebit,Null As DocCredit,
								Round((@CreditMemoAmount * @SysCalExchangerate) * @DefaultExchangeRate,2) As BaseDebit,NUll As BaseCredit,
								0.00 As DocDebitTotal,0.00 As DocCreditTotal,0.00 As BaseDebitTotal,0.00 As BaseCreditTotal,R.Id As DocumentId,@GUIDZero As DocumentDetailId,@GUIDZero,
								R.BaseCurrency,@DefaultExchangeRate As ExchangeRate,@DocType,@DocSubType,@ServCompId As ServiceCompanyId,R.DocNo,Null As Nature,R.DocNo,0 As IsTax,
								R.EntityId,@SystemRefNo,@BankChargesCurrency,R.DocDate,R.DocDate,@RecOrderAnotherJV As RecOrder
							From Bean.Receipt(Nolock) As R
							Where R.Id=@SourceId
							-- Create CreditMemo Journal I/C JD ClearingReceipts COA
							Set @RecOrderAnotherJV=@RecOrderAnotherJV+1
							Insert Into Bean.JournalDetail (Id,JournalId,COAId,AccountDescription, DocDebit,DocCredit,
														 BaseDebit,BaseCredit,
														 DocDebitTotal,DocCreditTotal,BaseDebitTotal,BaseCreditTotal,DocumentId,DocumentDetailId,ItemId,BaseCurrency,ExchangeRate, DocType,DocSubType,ServiceCompanyId,DocNo,Nature,OffsetDocument,IsTax,
														EntityId, SystemRefNo, DocCurrency,DocDate, PostingDate,RecOrder 
														)
							Select NEWID(),@JournalId,@ClearingReceiptsCOAID,R.Remarks,Null As DocDebit,Round(@CreditMemoAmount * @SysCalExchangerate,2) As DocCredit,
								Null As BaseDebit,Round((@CreditMemoAmount * @SysCalExchangerate) * @DefaultExchangeRate,2) As BaseCredit,
								0.00 As DocDebitTotal,0.00 As DocCreditTotal,0.00 As BaseDebitTotal,0.00 As BaseCreditTotal,R.Id As DocumentId,@GUIDZero As DocumentDetailId,@GUIDZero,
								R.BaseCurrency,@DefaultExchangeRate As ExchangeRate,@DocType,@DocSubType,@ServCompId As ServiceCompanyId,R.DocNo,Null As Nature,R.DocNo,0 As IsTax,
								R.EntityId,@SystemRefNo,@BankChargesCurrency,R.DocDate,R.DocDate,@RecOrder As RecOrder
							From Bean.Receipt(Nolock) As R
							Where R.Id=@SourceId
						End
						-- CreditNoteAmount
						IF @CreditNoteAmount Is Not Null And @CreditNoteAmount <>0
						Begin
							Set @RecOrder=@RecOrder+1
							Insert Into Bean.JournalDetail (Id,JournalId,COAId,AccountDescription, DocDebit,DocCredit,
														 BaseDebit,BaseCredit,
														 DocDebitTotal,DocCreditTotal,BaseDebitTotal,BaseCreditTotal,DocumentId,DocumentDetailId,ItemId,BaseCurrency,ExchangeRate, DocType,DocSubType,ServiceCompanyId,DocNo,Nature,OffsetDocument,IsTax,
														EntityId, SystemRefNo, DocCurrency,DocDate, PostingDate,RecOrder 
														)
							Select NEWID(),@MasterJournalId,@IntroCompCOAID,R.Remarks,Round(@CreditNoteAmount * @SysCalExchangerate,2) As DocDebit,NUll As DocCredit,
								Round((@CreditNoteAmount * @SysCalExchangerate) * @DefaultExchangeRate,2) As BaseDebit,Null As BaseCredit,
								0.00 As DocDebitTotal,0.00 As DocCreditTotal,0.00 As BaseDebitTotal,0.00 As BaseCreditTotal,R.Id As DocumentId,@GUIDZero As DocumentDetailId,@GUIDZero,
								R.BaseCurrency,@DefaultExchangeRate As ExchangeRate,@DocType,@DocSubType,ServiceCompanyId As ServiceCompanyId,R.DocNo,Null As Nature,R.DocNo,0 As IsTax,
								R.EntityId,@MasterSystemRefNo,@BankChargesCurrency,R.DocDate,R.DocDate,@RecOrder As RecOrder
							From Bean.Receipt(Nolock) As R
							Where R.Id=@SourceId
							-- Creating CreditNote Journal
							Set @CreditNoteJournalId=NEWID()
							Set @SysRefNum_Incr=@SysRefNum_Incr+1
							Set @SystemRefNo=CONCAT(@DocNo,'-JV',@SysRefNum_Incr)
							Insert Into Bean.Journal (Id,CompanyId,DocDate,DocType,DocSubType,DocNo,ServiceCompanyId,SystemReferenceNo,IsNoSupportingDocs,NoSupportingDocument,DocCurrency,ExchangeRate,ExCurrency,ExDurationFrom,GSTExchangeRate,GSTExCurrency,GSTTotalAmount,DocumentState,IsNoSupportingDocument,IsGstSettings,IsMultiCurrency,IsAllowableNonAllowable,IsGSTCurrencyRateChanged,Remarks,UserCreated,CreatedDate,Status,DocumentDescription,CreationType,GrandDocDebitTotal,GrandDocCreditTotal,GrandBaseDebitTotal,
													 GrandBaseCreditTotal,EntityId,EntityType,PostingDate,COAId,ModeOfReceipt,BankReceiptAmmount,ExcessPaidByClientAmmount,BalancingItemReciveCRAmount,  BalancingItemPayDRAmount,ReceiptApplicationAmmount,DocumentId, BankClearingDate ,IsBalancing,ISAllowDisAllow, IsShow, ActualSysRefNo 
													 ,IsSegmentReporting,TransferRefNo
													 )
							Select @CreditNoteJournalId,@CompanyId,DocDate,@DocType,@DocSubType,DocNo,@ServCompId As ServiceCompanyId,@SystemRefNo As SystemRefNo,IsNoSupportingDocument,NoSupportingDocs,DocCurrency,ExchangeRate,ExCurrency,ExDurationFrom,GSTExchangeRate,GSTExCurrency,Isnull(GSTTotalAmount,0),DocumentState,NoSupportingDocs,IsGstSettings,IsMultiCurrency,IsAllowableDisallowable,IsGSTCurrencyRateChanged,Remarks,@UserCreated,@CreatedDate,Status,Remarks As DocDescription,@UserCreated,GrandTotal,0.00 As GrandDocCreditTotal,GrandTotal * Round(ExchangeRate,2) As GrandBaseDebitTotal,
									0.00 As GrandBaseCreditTotal,EntityId,EntityType,DocDate As PostingDate,@IntroCompCOAID As COAId,ModeOfReceipt,0.00 As BankReceiptAmmount,0.00 As ExcessPaidByClientAmmount,0.00 As BalancingItemReciveCRAmount,0.00 As BalancingItemPayDRAmount,0.00 As ReceiptApplicationAmmount,Id As DocumentId,BankClearingDate,0 As IsBalancing,IsDisAllow,1 As IsShow,DocNo As ActualSysRefNo,0 As IsSegmentReporting,ReceiptRefNo
							From Bean.Receipt(Nolock) Where CompanyId=@CompanyId And Id=@SourceId
							-- CreditNote Journal Detail MainInterCoServCompCOAID
							Set @RecOrderAnotherJV=1
							Insert Into Bean.JournalDetail (Id,JournalId,COAId,AccountDescription, DocDebit,DocCredit,
														 BaseDebit,BaseCredit,
														 DocDebitTotal,DocCreditTotal,BaseDebitTotal,BaseCreditTotal,DocumentId,DocumentDetailId,ItemId,BaseCurrency,ExchangeRate, DocType,DocSubType,ServiceCompanyId,DocNo,Nature,OffsetDocument,IsTax,
														EntityId, SystemRefNo, DocCurrency,DocDate, PostingDate,RecOrder 
														)
							Select NEWID(),@CreditNoteJournalId,@MainInterCoServCompCOAID,R.Remarks,Null As DocDebit,Round(@CreditNoteAmount * @SysCalExchangerate,2) As DocCredit,
								Null As BaseDebit,Round((@CreditNoteAmount * @SysCalExchangerate) * @DefaultExchangeRate,2) As BaseCredit,
								0.00 As DocDebitTotal,0.00 As DocCreditTotal,0.00 As BaseDebitTotal,0.00 As BaseCreditTotal,R.Id As DocumentId,@GUIDZero As DocumentDetailId,@GUIDZero,
								R.BaseCurrency,@DefaultExchangeRate As ExchangeRate,@DocType,@DocSubType,@ServCompId As ServiceCompanyId,R.DocNo,Null As Nature,R.DocNo,0 As IsTax,
								R.EntityId,@SystemRefNo,@BankChargesCurrency,R.DocDate,R.DocDate,1 As RecOrder
							From Bean.Receipt(Nolock) As R
							Where R.Id=@SourceId
							-- CreditNote Journal Detail ClearingReceipts
							Set @RecOrderAnotherJV=@RecOrderAnotherJV+1
							Insert Into Bean.JournalDetail (Id,JournalId,COAId,AccountDescription, DocDebit,DocCredit,
														 BaseDebit,BaseCredit,
														 DocDebitTotal,DocCreditTotal,BaseDebitTotal,BaseCreditTotal,DocumentId,DocumentDetailId,ItemId,BaseCurrency,ExchangeRate, DocType,DocSubType,ServiceCompanyId,DocNo,Nature,OffsetDocument,IsTax,
														EntityId, SystemRefNo, DocCurrency,DocDate, PostingDate,RecOrder 
														)
							Select NEWID(),@CreditNoteJournalId,@ClearingReceiptsCOAID,R.Remarks,Round(@CreditNoteAmount * @SysCalExchangerate,2) As DocDebit,Null As DocCredit,
								Round((@CreditNoteAmount * @SysCalExchangerate) * @DefaultExchangeRate,2) As BaseDebit,Null As BaseCredit,
								0.00 As DocDebitTotal,0.00 As DocCreditTotal,0.00 As BaseDebitTotal,0.00 As BaseCreditTotal,R.Id As DocumentId,@GUIDZero As DocumentDetailId,@GUIDZero,
								R.BaseCurrency,@DefaultExchangeRate As ExchangeRate,@DocType,@DocSubType,@ServCompId As ServiceCompanyId,R.DocNo,Null As Nature,R.DocNo,0 As IsTax,
								R.EntityId,@SystemRefNo,@BankChargesCurrency,R.DocDate,R.DocDate,2 As RecOrder
							From Bean.Receipt(Nolock) As R
							Where R.Id=@SourceId
						End
						-- ClearingRecieptInvOrDNAmount Receipt Details
						IF (@ClearingRecieptInvOrDNAmount Is Not Null And @ClearingRecieptInvOrDNAmount<>0) OR (@ClearingRecieptBillAmount Is Not Null And @ClearingRecieptBillAmount <>0)
						Begin
							Set @RecOrder=@RecOrder+1
							Insert Into Bean.JournalDetail (Id,JournalId,COAId,AccountDescription, DocDebit,DocCredit,
															 BaseDebit,BaseCredit,
															 DocDebitTotal,DocCreditTotal,BaseDebitTotal,BaseCreditTotal,DocumentId,DocumentDetailId,ItemId,BaseCurrency,ExchangeRate, DocType,DocSubType,ServiceCompanyId,DocNo,Nature,OffsetDocument,IsTax,
															EntityId, SystemRefNo, DocCurrency,DocDate, PostingDate,RecOrder 
															)
							Select NEWID(),@MasterJournalId,@IntroCompCOAID,R.Remarks,
								Case When (@ClearingRecieptInvOrDNAmount-@ClearingRecieptBillAmount)<0 Then ABS(Round((@ClearingRecieptInvOrDNAmount-@ClearingRecieptBillAmount) * @SysCalExchangerate,2)) End As DocDebit,
								Case When (@ClearingRecieptInvOrDNAmount-@ClearingRecieptBillAmount)>0 Then ABS(Round((@ClearingRecieptInvOrDNAmount-@ClearingRecieptBillAmount) * @SysCalExchangerate,2)) End As DocCredit,
								Case When (@ClearingRecieptInvOrDNAmount-@ClearingRecieptBillAmount)<0 Then ABS(Round(((@ClearingRecieptInvOrDNAmount-@ClearingRecieptBillAmount) * @SysCalExchangerate) * @DefaultExchangeRate,2)) End As BaseDebit,
								Case When (@ClearingRecieptInvOrDNAmount-@ClearingRecieptBillAmount)>0 Then ABS(Round(((@ClearingRecieptInvOrDNAmount-@ClearingRecieptBillAmount) * @SysCalExchangerate) * @DefaultExchangeRate,2)) End As BaseCredit,
								0.00 As DocDebitTotal,0.00 As DocCreditTotal,0.00 As BaseDebitTotal,0.00 As BaseCreditTotal,R.Id As DocumentId,@GUIDZero As DocumentDetailId,@GUIDZero,
								R.BaseCurrency,@DefaultExchangeRate As ExchangeRate,@DocType,@DocSubType,ServiceCompanyId As ServiceCompanyId,R.DocNo,Null As Nature,R.DocNo,0 As IsTax,
								R.EntityId,@MasterSystemRefNo,@BankChargesCurrency,R.DocDate,R.DocDate,@RecOrder As RecOrder
							From Bean.Receipt(Nolock) As R
							Where R.Id=@SourceId
							-- Creating Journal With I/c
							Set @JournalId=NEWID()
							Set @SysRefNum_Incr=@SysRefNum_Incr+1
							Set @SystemRefNo=CONCAT(@DocNo,'-JV',@SysRefNum_Incr)
							Insert Into Bean.Journal (Id,CompanyId,DocDate,DocType,DocSubType,DocNo,ServiceCompanyId,SystemReferenceNo,IsNoSupportingDocs,NoSupportingDocument,DocCurrency,ExchangeRate,ExCurrency,ExDurationFrom,GSTExchangeRate,GSTExCurrency,GSTTotalAmount,DocumentState,IsNoSupportingDocument,IsGstSettings,IsMultiCurrency,IsAllowableNonAllowable,IsGSTCurrencyRateChanged,Remarks,UserCreated,CreatedDate,Status,DocumentDescription,CreationType,GrandDocDebitTotal,GrandDocCreditTotal,GrandBaseDebitTotal,
														GrandBaseCreditTotal,EntityId,EntityType,PostingDate,COAId,ModeOfReceipt,BankReceiptAmmount,ExcessPaidByClientAmmount,BalancingItemReciveCRAmount,  BalancingItemPayDRAmount,ReceiptApplicationAmmount,DocumentId, BankClearingDate ,IsBalancing,ISAllowDisAllow, IsShow, ActualSysRefNo 
														,IsSegmentReporting,TransferRefNo
													 )
							Select @JournalId,@CompanyId,DocDate,@DocType,@DocSubType,DocNo,@ServCompId As ServiceCompanyId,@SystemRefNo As SystemRefNo,IsNoSupportingDocument,NoSupportingDocs,DocCurrency,ExchangeRate,ExCurrency,ExDurationFrom,GSTExchangeRate,GSTExCurrency,Isnull(GSTTotalAmount,0),DocumentState,NoSupportingDocs,IsGstSettings,IsMultiCurrency,IsAllowableDisallowable,IsGSTCurrencyRateChanged,Remarks,@UserCreated,@CreatedDate,Status,Remarks As DocDescription,@UserCreated,GrandTotal,0.00 As GrandDocCreditTotal,GrandTotal * Round(ExchangeRate,2) As GrandBaseDebitTotal,
									0.00 As GrandBaseCreditTotal,EntityId,EntityType,DocDate As PostingDate,@IntroCompCOAID As COAId,ModeOfReceipt,0.00 As BankReceiptAmmount,0.00 As ExcessPaidByClientAmmount,0.00 As BalancingItemReciveCRAmount,0.00 As BalancingItemPayDRAmount,0.00 As ReceiptApplicationAmmount,Id As DocumentId,BankClearingDate,0 As IsBalancing,IsDisAllow,1 As IsShow,DocNo As ActualSysRefNo,0 As IsSegmentReporting,ReceiptRefNo
							From Bean.Receipt(Nolock) Where CompanyId=@CompanyId And Id=@SourceId
							-- Creating Journal With I/c JD i/C COA
							Set @RecOrderAnotherJV=1
							Insert Into Bean.JournalDetail (Id,JournalId,COAId,AccountDescription, DocDebit,DocCredit,
													 BaseDebit,BaseCredit,
													 DocDebitTotal,DocCreditTotal,BaseDebitTotal,BaseCreditTotal,DocumentId,DocumentDetailId,ItemId,BaseCurrency,ExchangeRate, DocType,DocSubType,ServiceCompanyId,DocNo,Nature,OffsetDocument,IsTax,
													EntityId, SystemRefNo, DocCurrency,DocDate, PostingDate,RecOrder 
													)
							Select NEWID(),@JournalId,@MainInterCoServCompCOAID,R.Remarks,
									Case When (@ClearingRecieptInvOrDNAmount-@ClearingRecieptBillAmount)>0 Then ABS(Round((@ClearingRecieptInvOrDNAmount-@ClearingRecieptBillAmount)* @SysCalExchangerate,2)) End As DocDebit,
									Case When (@ClearingRecieptInvOrDNAmount-@ClearingRecieptBillAmount)<0 Then ABS(Round((@ClearingRecieptInvOrDNAmount-@ClearingRecieptBillAmount)* @SysCalExchangerate,2)) End As DocCredit,
									Case When (@ClearingRecieptInvOrDNAmount-@ClearingRecieptBillAmount)>0 Then ABS(Round(((@ClearingRecieptInvOrDNAmount-@ClearingRecieptBillAmount)* @SysCalExchangerate) * @DefaultExchangeRate,2)) End As BaseDebit,
									Case When (@ClearingRecieptInvOrDNAmount-@ClearingRecieptBillAmount)<0 Then ABS(Round(((@ClearingRecieptInvOrDNAmount-@ClearingRecieptBillAmount)* @SysCalExchangerate) * @DefaultExchangeRate,2)) End As BaseCredit,
									0.00 As DocDebitTotal,0.00 As DocCreditTotal,0.00 As BaseDebitTotal,0.00 As BaseCreditTotal,R.Id As DocumentId,R.Id As DocumentDetailId,@GUIDZero,
									R.BaseCurrency,@DefaultExchangeRate As ExchangeRate,@DocType,@DocSubType,@ServCompId As ServiceCompanyId,R.DocNo,Null As Nature,R.DocNo,0 As IsTax,
									R.EntityId,@SystemRefNo,@BankChargesCurrency,R.DocDate,R.DocDate,@RecOrderAnotherJV As RecOrder
							From Bean.Receipt(Nolock) As R
							Where R.Id=@SourceId
							-- Creating Journal With I/c  Jd Clearingreceipts COA
							Set @RecOrderAnotherJV=@RecOrderAnotherJV+1
							Insert Into Bean.JournalDetail (Id,JournalId,COAId,AccountDescription, DocDebit,DocCredit,
													 BaseDebit,BaseCredit,
													 DocDebitTotal,DocCreditTotal,BaseDebitTotal,BaseCreditTotal,DocumentId,DocumentDetailId,ItemId,BaseCurrency,ExchangeRate, DocType,DocSubType,ServiceCompanyId,DocNo,Nature,OffsetDocument,IsTax,
													EntityId, SystemRefNo, DocCurrency,DocDate, PostingDate,RecOrder 
													)
							Select NEWID(),@JournalId,@ClearingReceiptsCOAID,R.Remarks,
									Case When (@ClearingRecieptInvOrDNAmount-@ClearingRecieptBillAmount)<0 Then ABS(Round((@ClearingRecieptInvOrDNAmount-@ClearingRecieptBillAmount)* @SysCalExchangerate,2)) End As DocDebit,
									Case When (@ClearingRecieptInvOrDNAmount-@ClearingRecieptBillAmount)>0 Then ABS(Round((@ClearingRecieptInvOrDNAmount-@ClearingRecieptBillAmount)* @SysCalExchangerate,2)) End As DocCredit,
									Case When (@ClearingRecieptInvOrDNAmount-@ClearingRecieptBillAmount)<0 Then ABS(Round(((@ClearingRecieptInvOrDNAmount-@ClearingRecieptBillAmount)* @SysCalExchangerate) * @DefaultExchangeRate,2)) End As BaseDebit,
									Case When (@ClearingRecieptInvOrDNAmount-@ClearingRecieptBillAmount)>0 Then ABS(Round(((@ClearingRecieptInvOrDNAmount-@ClearingRecieptBillAmount)* @SysCalExchangerate) * @DefaultExchangeRate,2)) End As BaseCredit,
									0.00 As DocDebitTotal,0.00 As DocCreditTotal,0.00 As BaseDebitTotal,0.00 As BaseCreditTotal,R.Id As DocumentId,R.Id As DocumentDetailId,@GUIDZero,
									R.BaseCurrency,@SysCalExchangerate As ExchangeRate,@DocType,@DocSubType,@ServCompId As ServiceCompanyId,R.DocNo,Null As Nature,R.DocNo,0 As IsTax,
									R.EntityId,@SystemRefNo,@BankChargesCurrency,R.DocDate,R.DocDate,@RecOrderAnotherJV As RecOrder
							From Bean.Receipt(Nolock) As R
							Where R.Id=@SourceId

							-- Creating Journal With Clearing Receipts
							Set @JournalId=NEWID()
							Set @SysRefNum_Incr=@SysRefNum_Incr+1
							Set @SystemRefNo=CONCAT(@DocNo,'-JV',@SysRefNum_Incr)
							Insert Into Bean.Journal (Id,CompanyId,DocDate,DocType,DocSubType,DocNo,ServiceCompanyId,SystemReferenceNo,IsNoSupportingDocs,NoSupportingDocument,DocCurrency,ExchangeRate,ExCurrency,ExDurationFrom,GSTExchangeRate,GSTExCurrency,GSTTotalAmount,DocumentState,IsNoSupportingDocument,IsGstSettings,IsMultiCurrency,IsAllowableNonAllowable,IsGSTCurrencyRateChanged,Remarks,UserCreated,CreatedDate,Status,DocumentDescription,CreationType,GrandDocDebitTotal,GrandDocCreditTotal,GrandBaseDebitTotal,
														GrandBaseCreditTotal,EntityId,EntityType,PostingDate,COAId,ModeOfReceipt,BankReceiptAmmount,ExcessPaidByClientAmmount,BalancingItemReciveCRAmount,  BalancingItemPayDRAmount,ReceiptApplicationAmmount,DocumentId, BankClearingDate ,IsBalancing,ISAllowDisAllow, IsShow, ActualSysRefNo 
														,IsSegmentReporting,TransferRefNo
													 )
							Select @JournalId,@CompanyId,DocDate,@DocType,@DocSubType,DocNo,@ServCompId As ServiceCompanyId,@SystemRefNo As SystemRefNo,IsNoSupportingDocument,NoSupportingDocs,DocCurrency,ExchangeRate,ExCurrency,ExDurationFrom,GSTExchangeRate,GSTExCurrency,Isnull(GSTTotalAmount,0),DocumentState,NoSupportingDocs,IsGstSettings,IsMultiCurrency,IsAllowableDisallowable,IsGSTCurrencyRateChanged,Remarks,@UserCreated,@CreatedDate,Status,Remarks As DocDescription,@UserCreated,GrandTotal,0.00 As GrandDocCreditTotal,GrandTotal * Round(ExchangeRate,2) As GrandBaseDebitTotal,
									0.00 As GrandBaseCreditTotal,EntityId,EntityType,DocDate As PostingDate,@IntroCompCOAID As COAId,ModeOfReceipt,0.00 As BankReceiptAmmount,0.00 As ExcessPaidByClientAmmount,0.00 As BalancingItemReciveCRAmount,0.00 As BalancingItemPayDRAmount,0.00 As ReceiptApplicationAmmount,Id As DocumentId,BankClearingDate,0 As IsBalancing,IsDisAllow,1 As IsShow,DocNo As ActualSysRefNo,0 As IsSegmentReporting,ReceiptRefNo
							From Bean.Receipt(Nolock) Where CompanyId=@CompanyId And Id=@SourceId
							-- Creating Journal With Clearing Receipts JD COA
							Set @RecOrderAnotherJV=1
							Insert Into Bean.JournalDetail (Id,JournalId,COAId,AccountDescription, DocDebit,DocCredit,
													 BaseDebit,BaseCredit,
													 DocDebitTotal,DocCreditTotal,BaseDebitTotal,BaseCreditTotal,DocumentId,DocumentDetailId,ItemId,BaseCurrency,ExchangeRate, DocType,DocSubType,ServiceCompanyId,DocNo,Nature,OffsetDocument,IsTax,
													EntityId, SystemRefNo, DocCurrency,DocDate, PostingDate,RecOrder 
													)
							Select NEWID(),@JournalId,@ClearingReceiptsCOAID,R.Remarks,
									Case When (@ClearingRecieptInvOrDNAmount-@ClearingRecieptBillAmount)>0 Then ABS(@ClearingRecieptInvOrDNAmount-@ClearingRecieptBillAmount) End As DocDebit,
									Case When (@ClearingRecieptInvOrDNAmount-@ClearingRecieptBillAmount)<0 Then ABS(@ClearingRecieptInvOrDNAmount-@ClearingRecieptBillAmount) End As DocCredit,
									Case When (@ClearingRecieptInvOrDNAmount-@ClearingRecieptBillAmount)>0 Then ABS(Round((@ClearingRecieptInvOrDNAmount-@ClearingRecieptBillAmount) * @SysCalExchangerate,2)) End As BaseDebit,
									Case When (@ClearingRecieptInvOrDNAmount-@ClearingRecieptBillAmount)<0 Then ABS(Round((@ClearingRecieptInvOrDNAmount-@ClearingRecieptBillAmount) * @SysCalExchangerate,2)) End As BaseCredit,
									0.00 As DocDebitTotal,0.00 As DocCreditTotal,0.00 As BaseDebitTotal,0.00 As BaseCreditTotal,R.Id As DocumentId,R.Id As DocumentDetailId,@GUIDZero,
									R.BaseCurrency,@SysCalExchangerate As ExchangeRate,@DocType,@DocSubType,@ServCompId As ServiceCompanyId,R.DocNo,Null As Nature,R.DocNo,0 As IsTax,
									R.EntityId,@SystemRefNo,@DocCurrency,R.DocDate,R.DocDate,@RecOrderAnotherJV As RecOrder
							From Bean.Receipt(Nolock) As R
							Where R.Id=@SourceId
							-- Receipt Detail Records Serv Comp Wise
							Delete From @RecieptDtl_New
							Insert Into @RecieptDtl_New 
							Select ROW_NUMBER() Over (Order By RD.id),RD.Id From Bean.ReceiptDetail(Nolock) As RD
							Inner Join Bean.Receipt(Nolock) As R On RD.ReceiptId=R.Id 
							Where R.Id=@SourceId And RD.ServiceCompanyId=@ServCompId And RD.ReceiptAmount<>0 And RD.DocumentType Not In (@CreditNoteDocument,@CreditMemoDocument) Order By RD.RecOrder
							Set @DtlCount=(Select Count(*) From @RecieptDtl_New)
							--Set @RecOrder=2
							Set @RdtlRecCount=1
							While @DtlCount>=@RdtlRecCount
							Begin
								Set @RecieptDtlId=(Select RecieptDtlId From @RecieptDtl_New Where S_No=@RdtlRecCount)
								Set @DocumentId=(Select DocumentId From Bean.ReceiptDetail(Nolock) Where Id=@RecieptDtlId)
								Set @OffSetDocumentType=(Select DocumentType From Bean.ReceiptDetail(Nolock) Where ID=@RecieptDtlId)
								Set @IsRoundingAmount=0
								--Getting COAID By Checking Nature
								-- InvoiceDocument & DebitNoteDocument With TradeReceivables
								IF Exists (Select ID From Bean.ReceiptDetail(Nolock) Where id=@RecieptDtlId And Nature=@NatureTrade And DocumentType=@InvoiceDocument)
								Begin
									Set @COAID=(Select Id From Bean.ChartOfAccount(Nolock) Where CompanyId=@CompanyId And Name=@COATradeReceivables)
									Set @ExchangeRate=(Select ExchangeRate From Bean.Invoice(Nolock) Where Id=@DocumentId)
									IF Exists(Select Id From Bean.Invoice(Nolock) Where Id=@DocumentId And DocumentState In (@FullyApplied,@Fullypaid))
									Begin
										Set @IsRoundingAmount=1
									End
								End
								-- InvoiceDocument & DebitNoteDocument With OtherReceivables
								Else IF Exists (Select ID From Bean.ReceiptDetail(Nolock) Where id=@RecieptDtlId And Nature=@NatureOthers And DocumentType=@InvoiceDocument)
								Begin
									Set @COAID=(Select Id From Bean.ChartOfAccount(Nolock) Where CompanyId=@CompanyId And Name=@COAotherReceivables )
									Set @ExchangeRate=(Select ExchangeRate From Bean.Invoice(Nolock) Where Id=@DocumentId)
									IF Exists(Select Id From Bean.Invoice(Nolock) Where Id=@DocumentId And DocumentState In (@FullyApplied,@Fullypaid))
									Begin
										Set @IsRoundingAmount=1
									End
								End
								Else IF Exists (Select ID From Bean.ReceiptDetail(Nolock) Where id=@RecieptDtlId And Nature=@NatureTrade And DocumentType=@DebitNoteDocument)
								Begin
									Set @COAID=(Select Id From Bean.ChartOfAccount(Nolock) Where CompanyId=@CompanyId And Name=@COATradeReceivables)
									Set @ExchangeRate=(Select ExchangeRate From Bean.DebitNote(Nolock) Where Id=@DocumentId)
									IF Exists(Select Id From Bean.DebitNote(Nolock) Where Id=@DocumentId And DocumentState In (@FullyApplied,@Fullypaid))
									Begin
										Set @IsRoundingAmount=1
									End
								End
								Else IF Exists (Select ID From Bean.ReceiptDetail(Nolock) Where id=@RecieptDtlId And Nature=@NatureOthers And DocumentType=@DebitNoteDocument)
								Begin
									Set @COAID=(Select Id From Bean.ChartOfAccount(Nolock) Where CompanyId=@CompanyId And Name=@COAotherReceivables )
									Set @ExchangeRate=(Select ExchangeRate From Bean.DebitNote(Nolock) Where Id=@DocumentId)
									IF Exists(Select Id From Bean.DebitNote(Nolock) Where Id=@DocumentId And DocumentState In (@FullyApplied,@Fullypaid))
									Begin
										Set @IsRoundingAmount=1
									End
								End
								-- BillDocument Trade
								Else IF Exists (Select ID From Bean.ReceiptDetail(Nolock) Where id=@RecieptDtlId And DocumentType=@BillDocument And Nature=@NatureTrade)
								Begin
									Set @COAID=(Select Id From Bean.ChartOfAccount(Nolock) Where CompanyId=@CompanyId And Name=@COATradePayables)
									Set @ExchangeRate=(Select ExchangeRate From Bean.Bill(Nolock) Where Id=@DocumentId)
									IF Exists(Select Id From Bean.Bill(Nolock) Where Id=@DocumentId And DocumentState In (@FullyApplied,@Fullypaid))
									Begin
										Set @IsRoundingAmount=1
									End
								End
								-- BillDocument Others
								Else IF Exists (Select ID From Bean.ReceiptDetail(Nolock) Where id=@RecieptDtlId And DocumentType=@BillDocument And Nature=@NatureOthers)
								Begin
									Set @COAID=(Select Id From Bean.ChartOfAccount(Nolock) Where CompanyId=@CompanyId And Name=@COAOtherPayables)
									Set @ExchangeRate=(Select ExchangeRate From Bean.Bill(Nolock) Where Id=@DocumentId)
									IF Exists(Select Id From Bean.Bill(Nolock) Where Id=@DocumentId And DocumentState In (@FullyApplied,@Fullypaid))
									Begin
										Set @IsRoundingAmount=1
									End
								End
								
								IF @IsRoundingAmount=1 And Exists (Select Amount From @RoundingAmountDetails Where DocumentId=@DocumentId And Amount Is Not Null And Amount<>'')
								Begin
									Set @DocAmount=(Select Amount From @RoundingAmountDetails Where DocumentId=@DocumentId)
								End
								Else
								Begin
									Set @DocAmount=0
								End
								IF (Coalesce(@OffSetDocumentType,'NULL')=@BillDocument)
								Begin
									Set @RecOrderAnotherJV=@RecOrderAnotherJV+1
									Insert Into Bean.JournalDetail (Id,JournalId,COAId,AccountDescription, DocDebit,DocCredit,
																	 BaseDebit,BaseCredit,
																	 DocDebitTotal,DocCreditTotal,BaseDebitTotal,BaseCreditTotal,DocumentId,DocumentDetailId,ItemId,BaseCurrency,ExchangeRate, DocType,DocSubType,ServiceCompanyId,DocNo,Nature,OffsetDocument,IsTax,
																	EntityId, SystemRefNo, DocCurrency,DocDate, PostingDate,RecOrder 
																	)
									Select NEWID(),@JournalId,@COAID,R.Remarks,RD.ReceiptAmount As DocDebit,Null As DocCredit,
										Round(RD.ReceiptAmount * @ExchangeRate,2)- Isnull(@DocAmount,0) As BaseDebit,Null As BaseCredit,
										0.00 As DocDebitTotal,0.00 As DocCreditTotal,0.00 As BaseDebitTotal,0.00 As BaseCreditTotal,R.Id As DocumentId,RD.Id As DocumentDetailId,@GUIDZero,
										R.BaseCurrency,@ExchangeRate As ExchangeRate,@DocType,@DocSubType,RD.ServiceCompanyId,R.DocNo,RD.Nature,Null As DocumentNo,0 As IsTax,
										R.EntityId,@SystemRefNo,@DocCurrency,R.DocDate,R.DocDate,@RecOrderAnotherJV As RecOrder
									From Bean.Receipt(Nolock) As R
									Inner Join bean.ReceiptDetail(Nolock) As RD On RD.ReceiptId=R.Id
									Where R.Id=@SourceId And RD.Id=@RecieptDtlId
									-- ExchangeGainOrLossRealised
									IF @SysCalExchangerate-@ExchangeRate<>0
									Begin
										Set @RecOrderAnotherJV=@RecOrderAnotherJV+1
										Insert Into Bean.JournalDetail (Id,JournalId,COAId,AccountDescription, DocDebit,DocCredit,
																		 BaseDebit,BaseCredit,
																		 DocDebitTotal,DocCreditTotal,BaseDebitTotal,BaseCreditTotal,DocumentId,DocumentDetailId,ItemId,BaseCurrency,ExchangeRate, DocType,DocSubType,ServiceCompanyId,DocNo,Nature,OffsetDocument,IsTax,
																		EntityId, SystemRefNo, DocCurrency,DocDate, PostingDate,RecOrder 
																		)
										Select NEWID(),@JournalId,@ExchangeGainOrLossCOAID,R.Remarks,Null As DocDebit,Null As DocCredit,
											Case When (@ExchangeRate-@SysCalExchangerate)<0 Then ABS(Round((@SysCalExchangerate-@ExchangeRate) * RD.ReceiptAmount,2)) End As BaseDebit,
											Case When (@ExchangeRate-@SysCalExchangerate)>0 Then ABS(Round((@ExchangeRate-@SysCalExchangerate) * RD.ReceiptAmount,2)) End As BaseCredit,
											0.00 As DocDebitTotal,0.00 As DocCreditTotal,0.00 As BaseDebitTotal,0.00 As BaseCreditTotal,R.Id As DocumentId,RD.Id As DocumentDetailId,@GUIDZero,
											R.BaseCurrency,@ExchangeRate As ExchangeRate,@DocType,@DocSubType,RD.ServiceCompanyId,R.DocNo,Null As Nature,Null As DocumentNo,0 As IsTax,
											R.EntityId,@SystemRefNo,@DocCurrency,R.DocDate,R.DocDate,@RecOrderAnotherJV As RecOrder
										From Bean.Receipt(Nolock) As R
										Inner Join bean.ReceiptDetail(Nolock) As RD On RD.ReceiptId=R.Id
										Where R.Id=@SourceId And RD.Id=@RecieptDtlId
									End
								End
								Else
								Begin
									Set @RecOrderAnotherJV=@RecOrderAnotherJV+1
									Insert Into Bean.JournalDetail (Id,JournalId,COAId,AccountDescription, DocDebit,DocCredit,
															 BaseDebit,BaseCredit,
															 DocDebitTotal,DocCreditTotal,BaseDebitTotal,BaseCreditTotal,DocumentId,DocumentDetailId,ItemId,BaseCurrency,ExchangeRate, DocType,DocSubType,ServiceCompanyId,DocNo,Nature,OffsetDocument,IsTax,
															EntityId, SystemRefNo, DocCurrency,DocDate, PostingDate,RecOrder 
															)
									Select NEWID(),@JournalId,@COAID,R.Remarks,Null As DocDebit,RD.ReceiptAmount As DocCredit,
										Null As BaseDebit,Round(RD.ReceiptAmount * @ExchangeRate,2)- Isnull(@DocAmount,0) As BaseCredit,
										0.00 As DocDebitTotal,0.00 As DocCreditTotal,0.00 As BaseDebitTotal,0.00 As BaseCreditTotal,R.Id As DocumentId,RD.Id As DocumentDetailId,@GUIDZero,
										R.BaseCurrency,@ExchangeRate As ExchangeRate,@DocType,@DocSubType,RD.ServiceCompanyId,R.DocNo,RD.Nature,RD.DocumentNo,0 As IsTax,
										R.EntityId,@SystemRefNo,@DocCurrency,R.DocDate,R.DocDate,@RecOrderAnotherJV As RecOrder
									From Bean.Receipt(Nolock) As R
									Inner Join bean.ReceiptDetail(Nolock) As RD On RD.ReceiptId=R.Id
									Where R.Id=@SourceId And RD.Id=@RecieptDtlId
									-- ExchangeGainOrLossRealised
									IF @SysCalExchangerate-@ExchangeRate<>0
									Begin
										Set @RecOrderAnotherJV=@RecOrderAnotherJV+1
										Insert Into Bean.JournalDetail (Id,JournalId,COAId,AccountDescription, DocDebit,DocCredit,
																		 BaseDebit,BaseCredit,
																		 DocDebitTotal,DocCreditTotal,BaseDebitTotal,BaseCreditTotal,DocumentId,DocumentDetailId,ItemId,BaseCurrency,ExchangeRate, DocType,DocSubType,ServiceCompanyId,DocNo,Nature,OffsetDocument,IsTax,
																		EntityId, SystemRefNo, DocCurrency,DocDate, PostingDate,RecOrder 
																		)
										Select NEWID(),@JournalId,@ExchangeGainOrLossCOAID,R.Remarks,Null As DocDebit,Null As DocCredit,
											Case When (@ExchangeRate-@SysCalExchangerate)>0 Then ABS(Round((@ExchangeRate-@SysCalExchangerate) * RD.ReceiptAmount,2)) End As BaseDebit,
											Case When (@ExchangeRate-@SysCalExchangerate)<0 Then ABS(Round((@SysCalExchangerate-@ExchangeRate) * RD.ReceiptAmount,2)) End As BaseCredit,
											0.00 As DocDebitTotal,0.00 As DocCreditTotal,0.00 As BaseDebitTotal,0.00 As BaseCreditTotal,R.Id As DocumentId,RD.Id As DocumentDetailId,@GUIDZero,
											R.BaseCurrency,@ExchangeRate As ExchangeRate,@DocType,@DocSubType,RD.ServiceCompanyId,R.DocNo,Null As Nature,Null As DocumentNo,0 As IsTax,
											R.EntityId,@SystemRefNo,@DocCurrency,R.DocDate,R.DocDate,@RecOrderAnotherJV As RecOrder
										From Bean.Receipt(Nolock) As R
										Inner Join bean.ReceiptDetail(Nolock) As RD On RD.ReceiptId=R.Id
										Where R.Id=@SourceId And RD.Id=@RecieptDtlId
									End
								End
								Set @RdtlRecCount=@RdtlRecCount+1
							End
						End
						Set @RecCount=@RecCount+1
					End

					-- Main ServComp Detail records in journal detail
					Set @ClearingRecieptInvOrDNAmount=(Select Sum(Isnull(ReceiptAmount,0)) From Bean.ReceiptDetail(Nolock) Where ReceiptId=@SourceId And ServiceCompanyId=@MasterServComp And DocumentType in (@InvoiceDocument,@DebitNoteDocument))
					Set @ClearingRecieptBillAmount=(Select Sum(Isnull(ReceiptAmount,0)) From Bean.ReceiptDetail(Nolock) Where ReceiptId=@SourceId And ServiceCompanyId=@MasterServComp And DocumentType =@BillDocument)
					IF @ClearingRecieptInvOrDNAmount Is null
					Begin
						Set @ClearingRecieptInvOrDNAmount =Isnull(@ClearingRecieptInvOrDNAmount,0)
					End
					IF @ClearingRecieptBillAmount Is null
					Begin
						Set @ClearingRecieptBillAmount =Isnull(@ClearingRecieptBillAmount,0)
					End
									
					IF (@ClearingRecieptInvOrDNAmount Is Not Null And @ClearingRecieptInvOrDNAmount<>0) OR (@ClearingRecieptBillAmount Is Not Null And @ClearingRecieptBillAmount <>0)
					Begin
						Set @RecOrder=@RecOrder+1
						Insert Into Bean.JournalDetail (Id,JournalId,COAId,AccountDescription, DocDebit,DocCredit,
																 BaseDebit,BaseCredit,
																 DocDebitTotal,DocCreditTotal,BaseDebitTotal,BaseCreditTotal,DocumentId,DocumentDetailId,ItemId,BaseCurrency,ExchangeRate, DocType,DocSubType,ServiceCompanyId,DocNo,Nature,OffsetDocument,IsTax,
																EntityId, SystemRefNo, DocCurrency,DocDate, PostingDate,RecOrder 
																)
						Select NEWID(),@MasterJournalId,@ClearingReceiptsCOAID,R.Remarks,
							Case When (@ClearingRecieptInvOrDNAmount-@ClearingRecieptBillAmount) <0 Then ABS(Round((@ClearingRecieptInvOrDNAmount-@ClearingRecieptBillAmount) * @SysCalExchangerate,2)) End As DocDebit,
							Case When (@ClearingRecieptInvOrDNAmount-@ClearingRecieptBillAmount) >0 Then ABS(Round((@ClearingRecieptInvOrDNAmount-@ClearingRecieptBillAmount) * @SysCalExchangerate,2)) End As DocCredit,
							Case When (@ClearingRecieptInvOrDNAmount-@ClearingRecieptBillAmount) <0 Then ABS(Round(((@ClearingRecieptInvOrDNAmount-@ClearingRecieptBillAmount) * @SysCalExchangerate) * @DefaultExchangeRate,2)) End As BaseDebit,
							Case When (@ClearingRecieptInvOrDNAmount-@ClearingRecieptBillAmount) >0 Then ABS(Round(((@ClearingRecieptInvOrDNAmount-@ClearingRecieptBillAmount) * @SysCalExchangerate) * @DefaultExchangeRate,2)) End As BaseCredit,
							0.00 As DocDebitTotal,0.00 As DocCreditTotal,0.00 As BaseDebitTotal,0.00 As BaseCreditTotal,R.Id As DocumentId,@GUIDZero As DocumentDetailId,@GUIDZero,
							R.BaseCurrency,@DefaultExchangeRate As ExchangeRate,@DocType,@DocSubType,ServiceCompanyId As ServiceCompanyId,R.DocNo,Null As Nature,R.DocNo,0 As IsTax,
							R.EntityId,@MasterSystemRefNo,@BankChargesCurrency,R.DocDate,R.DocDate,@RecOrder As RecOrder
						From Bean.Receipt(Nolock) As R
						Where R.Id=@SourceId
						-- Creating New Jv for Main ServComp Detail records 
						Set @JournalId=NEWID()
						Set @SysRefNum_Incr=@SysRefNum_Incr+1
						Set @SystemRefNo=CONCAT(@DocNo,'-JV',@SysRefNum_Incr)
						Insert Into Bean.Journal (Id,CompanyId,DocDate,DocType,DocSubType,DocNo,ServiceCompanyId,SystemReferenceNo,IsNoSupportingDocs,NoSupportingDocument,DocCurrency,ExchangeRate,ExCurrency,ExDurationFrom,GSTExchangeRate,GSTExCurrency,GSTTotalAmount,DocumentState,IsNoSupportingDocument,IsGstSettings,IsMultiCurrency,IsAllowableNonAllowable,IsGSTCurrencyRateChanged,Remarks,UserCreated,CreatedDate,Status,DocumentDescription,CreationType,GrandDocDebitTotal,GrandDocCreditTotal,GrandBaseDebitTotal,
												 GrandBaseCreditTotal,EntityId,EntityType,PostingDate,COAId,ModeOfReceipt,BankReceiptAmmount,ExcessPaidByClientAmmount,BalancingItemReciveCRAmount,  BalancingItemPayDRAmount,ReceiptApplicationAmmount,DocumentId, BankClearingDate ,IsBalancing,ISAllowDisAllow, IsShow, ActualSysRefNo 
												 ,IsSegmentReporting,TransferRefNo
												 )
						Select @JournalId,@CompanyId,DocDate,@DocType,@DocSubType,DocNo,ServiceCompanyId As ServiceCompanyId,@SystemRefNo As SystemRefNo,IsNoSupportingDocument,NoSupportingDocs,DocCurrency,ExchangeRate,ExCurrency,ExDurationFrom,GSTExchangeRate,GSTExCurrency,Isnull(GSTTotalAmount,0),DocumentState,NoSupportingDocs,IsGstSettings,IsMultiCurrency,IsAllowableDisallowable,IsGSTCurrencyRateChanged,Remarks,@UserCreated,@CreatedDate,Status,Remarks As DocDescription,@UserCreated,GrandTotal,0.00 As GrandDocCreditTotal,GrandTotal * Round(ExchangeRate,2) As GrandBaseDebitTotal,
								0.00 As GrandBaseCreditTotal,EntityId,EntityType,DocDate As PostingDate,@IntroCompCOAID As COAId,ModeOfReceipt,0.00 As BankReceiptAmmount,0.00 As ExcessPaidByClientAmmount,0.00 As BalancingItemReciveCRAmount,0.00 As BalancingItemPayDRAmount,0.00 As ReceiptApplicationAmmount,Id As DocumentId,BankClearingDate,0 As IsBalancing,IsDisAllow,1 As IsShow,DocNo As ActualSysRefNo,0 As IsSegmentReporting,ReceiptRefNo
						From Bean.Receipt(Nolock) Where CompanyId=@CompanyId And Id=@SourceId
						Set @RecOrderAnotherJV=1
						Insert Into Bean.JournalDetail (Id,JournalId,COAId,AccountDescription, DocDebit,DocCredit,
														 BaseDebit,BaseCredit,
														 DocDebitTotal,DocCreditTotal,BaseDebitTotal,BaseCreditTotal,DocumentId,DocumentDetailId,ItemId,BaseCurrency,ExchangeRate, DocType,DocSubType,ServiceCompanyId,DocNo,Nature,OffsetDocument,IsTax,
														EntityId, SystemRefNo, DocCurrency,DocDate, PostingDate,RecOrder 
														)
						Select NEWID(),@JournalId,@ClearingReceiptsCOAID,R.Remarks,
							Case When (@ClearingRecieptInvOrDNAmount-@ClearingRecieptBillAmount)>0 Then ABS(@ClearingRecieptInvOrDNAmount-@ClearingRecieptBillAmount) End As DocDebit,
							Case When (@ClearingRecieptInvOrDNAmount-@ClearingRecieptBillAmount)<0 Then ABS(@ClearingRecieptInvOrDNAmount-@ClearingRecieptBillAmount) End As DocCredit,
							Case When (@ClearingRecieptInvOrDNAmount-@ClearingRecieptBillAmount)>0 Then ABS(Round((@ClearingRecieptInvOrDNAmount-@ClearingRecieptBillAmount) * @SysCalExchangerate,2)) End As BaseDebit,
							Case When (@ClearingRecieptInvOrDNAmount-@ClearingRecieptBillAmount)<0 Then ABS(Round((@ClearingRecieptInvOrDNAmount-@ClearingRecieptBillAmount) * @SysCalExchangerate,2)) End As BaseCredit,
							0.00 As DocDebitTotal,0.00 As DocCreditTotal,0.00 As BaseDebitTotal,0.00 As BaseCreditTotal,R.Id As DocumentId,@GUIDZero As DocumentDetailId,@GUIDZero,
							R.BaseCurrency,@SysCalExchangerate As ExchangeRate,@DocType,@DocSubType,ServiceCompanyId As ServiceCompanyId,R.DocNo,Null As Nature,R.DocNo,0 As IsTax,
							R.EntityId,@SystemRefNo,@DocCurrency,R.DocDate,R.DocDate,@RecOrderAnotherJV As RecOrder
						From Bean.Receipt(Nolock) As R
						Where R.Id=@SourceId
					End
					IF Exists (Select Id From Bean.ReceiptDetail(Nolock) Where ReceiptId=@SourceId And ServiceCompanyId=@MasterServComp And DocumentType =@CreditNoteDocument)
					Begin
						Set @RecOrder=@RecOrder+1
						Set @CreditNoteAmount=(Select Sum(Isnull(ReceiptAmount,0)) From Bean.ReceiptDetail(Nolock) Where ReceiptId=@SourceId And ServiceCompanyId=@MasterServComp And DocumentType =@CreditNoteDocument)
						Insert Into Bean.JournalDetail (Id,JournalId,COAId,AccountDescription, DocDebit,DocCredit,
																 BaseDebit,BaseCredit,
																 DocDebitTotal,DocCreditTotal,BaseDebitTotal,BaseCreditTotal,DocumentId,DocumentDetailId,ItemId,BaseCurrency,ExchangeRate, DocType,DocSubType,ServiceCompanyId,DocNo,Nature,OffsetDocument,IsTax,
																EntityId, SystemRefNo, DocCurrency,DocDate, PostingDate,RecOrder 
																)
						Select NEWID(),@MasterJournalId,@ClearingReceiptsCOAID,R.Remarks,Round(@CreditNoteAmount * @SysCalExchangerate,2) As DocDebit,Null As DocCredit,
							Round((@CreditNoteAmount * @SysCalExchangerate) * @DefaultExchangeRate,2) As BaseDebit, Null As BaseCredit,
							0.00 As DocDebitTotal,0.00 As DocCreditTotal,0.00 As BaseDebitTotal,0.00 As BaseCreditTotal,R.Id As DocumentId,@GUIDZero As DocumentDetailId,@GUIDZero,
							R.BaseCurrency,@DefaultExchangeRate As ExchangeRate,@DocType,@DocSubType,ServiceCompanyId As ServiceCompanyId,R.DocNo,Null As Nature,R.DocNo,0 As IsTax,
							R.EntityId,@MasterSystemRefNo,@BankChargesCurrency,R.DocDate,R.DocDate,@RecOrder As RecOrder
						From Bean.Receipt(Nolock) As R
						Where R.Id=@SourceId
					End
					IF Exists (Select Id From Bean.ReceiptDetail(Nolock) Where ReceiptId=@SourceId And ServiceCompanyId=@MasterServComp And DocumentType =@CreditMemoDocument)
					Begin
						Set @RecOrder=@RecOrder+1
						Set @creditmemoAmount=(Select Sum(Isnull(ReceiptAmount,0)) From Bean.ReceiptDetail(Nolock) Where ReceiptId=@SourceId And ServiceCompanyId=@MasterServComp And DocumentType =@CreditMemoDocument)
						Insert Into Bean.JournalDetail (Id,JournalId,COAId,AccountDescription, DocDebit,DocCredit,
																 BaseDebit,BaseCredit,
																 DocDebitTotal,DocCreditTotal,BaseDebitTotal,BaseCreditTotal,DocumentId,DocumentDetailId,ItemId,BaseCurrency,ExchangeRate, DocType,DocSubType,ServiceCompanyId,DocNo,Nature,OffsetDocument,IsTax,
																EntityId, SystemRefNo, DocCurrency,DocDate, PostingDate,RecOrder 
																)
						Select NEWID(),@MasterJournalId,@ClearingReceiptsCOAID,R.Remarks,Null As DocDebit,Round(@creditmemoAmount * @SysCalExchangerate,2) As DocCredit,
							Null As BaseDebit,Round((@creditmemoAmount * @SysCalExchangerate) * @DefaultExchangeRate,2) As BaseCredit,
							0.00 As DocDebitTotal,0.00 As DocCreditTotal,0.00 As BaseDebitTotal,0.00 As BaseCreditTotal,R.Id As DocumentId,@GUIDZero As DocumentDetailId,@GUIDZero,
							R.BaseCurrency,@DefaultExchangeRate As ExchangeRate,@DocType,@DocSubType,ServiceCompanyId As ServiceCompanyId,R.DocNo,Null As Nature,R.DocNo,0 As IsTax,
							R.EntityId,@MasterSystemRefNo,@BankChargesCurrency,R.DocDate,R.DocDate,@RecOrder As RecOrder
						From Bean.Receipt(Nolock) As R
						Where R.Id=@SourceId
					End
					-- Creating Records For Interco In Journal Detail
					Insert Into @RecieptDtl 
					Select RD.Id From Bean.ReceiptDetail(Nolock) As RD
					Inner Join Bean.Receipt(Nolock) As R On RD.ReceiptId=R.Id 
					Where R.Id=@SourceId And RD.ReceiptAmount<>0 And RD.ServiceCompanyId=@MasterServComp And RD.DocumentType Not In (@CreditNoteDocument,@CreditMemoDocument) Order By RD.RecOrder 
					Set @Count=(Select Count(*) From @RecieptDtl)
					--Set @RecOrder=2
					Set @RecCount=1
					While @Count>=@RecCount
					Begin
						Set @RecieptDtlId=(Select RecieptDtlId From @RecieptDtl Where S_No=@RecCount)
						Set @DocumentId=(Select DocumentId From Bean.ReceiptDetail(Nolock) Where Id=@RecieptDtlId)
						Set @OffSetDocumentType=(Select DocumentType From Bean.ReceiptDetail(Nolock) Where Id=@RecieptDtlId)
						IF Coalesce(@OffSetDocumentType,'NULL')=@CreditNoteDocument Or  Coalesce(@OffSetDocumentType,'NULL')=@CreditMemoDocument
						Begin
							Set @DocAmount=0
						End
						Set @IsRoundingAmount=0
						--Getting COAID By Checking Nature
						IF Exists (Select ID From Bean.ReceiptDetail(Nolock) Where id=@RecieptDtlId And Nature=@NatureTrade And DocumentType =@InvoiceDocument)
						Begin
							Set @COAID=(Select Id From Bean.ChartOfAccount(Nolock) Where CompanyId=@CompanyId And Name=@COATradeReceivables)
							Set @ExchangeRate=(Select ExchangeRate From Bean.Invoice(Nolock) Where Id=@DocumentId)
							IF Exists(Select Id From Bean.Invoice(Nolock) Where Id=@DocumentId And DocumentState In (@FullyApplied,@Fullypaid))
							Begin
								Set @IsRoundingAmount=1
							End
						End
						Else IF Exists (Select ID From Bean.ReceiptDetail(Nolock) Where id=@RecieptDtlId And Nature=@NatureOthers And DocumentType =@InvoiceDocument)
						Begin
							Set @COAID=(Select Id From Bean.ChartOfAccount(Nolock) Where CompanyId=@CompanyId And Name=@COAotherReceivables )
							Set @ExchangeRate=(Select ExchangeRate From Bean.Invoice(Nolock) Where Id=@DocumentId)
							IF Exists(Select Id From Bean.Invoice(Nolock) Where Id=@DocumentId And DocumentState In (@FullyApplied,@Fullypaid))
							Begin
								Set @IsRoundingAmount=1
							End
						End
						Else IF Exists (Select ID From Bean.ReceiptDetail(Nolock) Where id=@RecieptDtlId And Nature=@NatureTrade And DocumentType =@DebitNoteDocument)
						Begin
							Set @COAID=(Select Id From Bean.ChartOfAccount(Nolock) Where CompanyId=@CompanyId And Name=@COATradeReceivables)
							Set @ExchangeRate=(Select ExchangeRate From Bean.DebitNote(Nolock) Where Id=@DocumentId)
							IF Exists(Select Id From Bean.DebitNote(Nolock) Where Id=@DocumentId And DocumentState In (@FullyApplied,@Fullypaid))
							Begin
								Set @IsRoundingAmount=1
							End
						End
						Else IF Exists (Select ID From Bean.ReceiptDetail(Nolock) Where id=@RecieptDtlId And Nature=@NatureOthers And DocumentType =@DebitNoteDocument)
						Begin
							Set @COAID=(Select Id From Bean.ChartOfAccount(Nolock) Where CompanyId=@CompanyId And Name=@COAotherReceivables )
							Set @ExchangeRate=(Select ExchangeRate From Bean.DebitNote(Nolock) Where Id=@DocumentId)
							IF Exists(Select Id From Bean.DebitNote(Nolock) Where Id=@DocumentId And DocumentState In (@FullyApplied,@Fullypaid))
							Begin
								Set @IsRoundingAmount=1
							End
						End
						Else IF Exists (Select ID From Bean.ReceiptDetail(Nolock) Where id=@RecieptDtlId And DocumentType=@BillDocument And Nature=@NatureTrade)
						Begin
							Set @COAID=(Select Id From Bean.ChartOfAccount(Nolock) Where CompanyId=@CompanyId And Name=@COATradePayables)
							Set @ExchangeRate=(Select ExchangeRate From Bean.Bill(Nolock) Where Id=@DocumentId)
							IF Exists(Select Id From Bean.Bill(Nolock) Where Id=@DocumentId And DocumentState In (@FullyApplied,@Fullypaid))
							Begin
								Set @IsRoundingAmount=1
							End
						End
						Else IF Exists (Select ID From Bean.ReceiptDetail(Nolock) Where id=@RecieptDtlId And DocumentType=@BillDocument And Nature=@NatureOthers)
						Begin
							Set @COAID=(Select Id From Bean.ChartOfAccount(Nolock) Where CompanyId=@CompanyId And Name=@COAOtherPayables)
							Set @ExchangeRate=(Select ExchangeRate From Bean.Bill(Nolock) Where Id=@DocumentId)
							IF Exists(Select Id From Bean.Bill(Nolock) Where Id=@DocumentId And DocumentState In (@FullyApplied,@Fullypaid))
							Begin
								Set @IsRoundingAmount=1
							End
						End
						IF @IsRoundingAmount=1 And Exists (Select Amount From @RoundingAmountDetails Where DocumentId=@DocumentId And Amount Is Not Null And Amount<>'')
						Begin
							Set @DocAmount=(Select Amount From @RoundingAmountDetails Where DocumentId=@DocumentId)
						End
						Else
						Begin
							Set @DocAmount=0
						End
						IF Coalesce(@OffSetDocumentType,'NULL')=@BillDocument
						Begin
							Set @RecOrderAnotherJV=@RecOrderAnotherJV+1
							Insert Into Bean.JournalDetail (Id,JournalId,COAId,AccountDescription, DocDebit,DocCredit,
															 BaseDebit,BaseCredit,
															 DocDebitTotal,DocCreditTotal,BaseDebitTotal,BaseCreditTotal,DocumentId,DocumentDetailId,ItemId,BaseCurrency,ExchangeRate, DocType,DocSubType,ServiceCompanyId,DocNo,Nature,OffsetDocument,IsTax,
															EntityId, SystemRefNo, DocCurrency,DocDate, PostingDate,RecOrder 
															)
							Select NEWID(),@JournalId,@COAID,R.Remarks,RD.ReceiptAmount As DocDebit,Null As DocCredit,Round(RD.ReceiptAmount * @ExchangeRate,2)- Isnull(@DocAmount,0) As BaseDebit,Null As BaseCredit,
								0.00 As DocDebitTotal,0.00 As DocCreditTotal,0.00 As BaseDebitTotal,0.00 As BaseCreditTotal,R.Id As DocumentId,RD.Id As DocumentDetailId,@GUIDZero,
								R.BaseCurrency,@ExchangeRate,@DocType,@DocSubType,RD.ServiceCompanyId,R.DocNo,RD.Nature,Null As DocumentNo,0 As IsTax,
								R.EntityId,@SystemRefNo,@DocCurrency,R.DocDate,R.DocDate,@RecOrderAnotherJV As RecOrder
							From Bean.Receipt(Nolock) As R
							Inner Join bean.ReceiptDetail(Nolock) As RD On RD.ReceiptId=R.Id
							Where R.Id=@SourceId And RD.Id=@RecieptDtlId
							-- ExchangeGainOrLossRealised
							IF @SysCalExchangerate-@ExchangeRate<>0 
							Begin
								Set @RecOrderAnotherJV=@RecOrderAnotherJV+1
								Insert Into Bean.JournalDetail (Id,JournalId,COAId,AccountDescription, DocDebit,DocCredit,
																 BaseDebit,BaseCredit,
																 DocDebitTotal,DocCreditTotal,BaseDebitTotal,BaseCreditTotal,DocumentId,DocumentDetailId,ItemId,BaseCurrency,ExchangeRate, DocType,DocSubType,ServiceCompanyId,DocNo,Nature,OffsetDocument,IsTax,
																EntityId, SystemRefNo, DocCurrency,DocDate, PostingDate,RecOrder 
																)
								Select NEWID(),@JournalId,@ExchangeGainOrLossCOAID,R.Remarks,Null As DocDebit,Null As DocCredit,
									Case When (@ExchangeRate-@SysCalExchangerate)<0 Then ABS(Round((@ExchangeRate-@SysCalExchangerate) * RD.ReceiptAmount,2)) End As BaseDebit,
									Case When (@ExchangeRate-@SysCalExchangerate)>0 Then ABS(Round((@ExchangeRate-@SysCalExchangerate) * RD.ReceiptAmount,2)) End As BaseCredit,
									0.00 As DocDebitTotal,0.00 As DocCreditTotal,0.00 As BaseDebitTotal,0.00 As BaseCreditTotal,R.Id As DocumentId,RD.Id As DocumentDetailId,@GUIDZero,
									R.BaseCurrency,@ExchangeRate As ExchangeRate,@DocType,@DocSubType,RD.ServiceCompanyId,R.DocNo,Null As Nature,Null As DocumentNo,0 As IsTax,
									R.EntityId,@SystemRefNo,@DocCurrency,R.DocDate,R.DocDate,@RecOrderAnotherJV As RecOrder
								From Bean.Receipt(Nolock) As R
								Inner Join bean.ReceiptDetail(Nolock) As RD On RD.ReceiptId=R.Id
								Where R.Id=@SourceId And RD.Id=@RecieptDtlId
							End
						End
						Else
						Begin
							Set @RecOrderAnotherJV=@RecOrderAnotherJV+1
							Insert Into Bean.JournalDetail (Id,JournalId,COAId,AccountDescription, DocDebit,DocCredit,
													 BaseDebit,BaseCredit,
													 DocDebitTotal,DocCreditTotal,BaseDebitTotal,BaseCreditTotal,DocumentId,DocumentDetailId,ItemId,BaseCurrency,ExchangeRate, DocType,DocSubType,ServiceCompanyId,DocNo,Nature,OffsetDocument,IsTax,
													EntityId, SystemRefNo, DocCurrency,DocDate, PostingDate,RecOrder 
													)
							Select NEWID(),@JournalId,@COAID,R.Remarks,Null As DocDebit,RD.ReceiptAmount As DocCredit,
								Null As BaseDebit,
								Round(RD.ReceiptAmount * @ExchangeRate,2)- Isnull(@DocAmount,0)As BaseCredit,
								0.00 As DocDebitTotal,0.00 As DocCreditTotal,0.00 As BaseDebitTotal,0.00 As BaseCreditTotal,R.Id As DocumentId,RD.Id As DocumentDetailId,@GUIDZero,
								R.BaseCurrency,@ExchangeRate,@DocType,@DocSubType,RD.ServiceCompanyId,R.DocNo,RD.Nature,RD.DocumentNo,0 As IsTax,
								R.EntityId,@SystemRefNo,@DocCurrency,R.DocDate,R.DocDate,@RecOrderAnotherJV As RecOrder
							From Bean.Receipt(Nolock) As R
							Inner Join bean.ReceiptDetail(Nolock) As RD On RD.ReceiptId=R.Id
							Where R.Id=@SourceId And RD.Id=@RecieptDtlId
							-- ExchangeGainOrLossRealised
							IF @SysCalExchangerate-@ExchangeRate<>0
							Begin
								Set @RecOrderAnotherJV=@RecOrderAnotherJV+1
								Insert Into Bean.JournalDetail (Id,JournalId,COAId,AccountDescription, DocDebit,DocCredit,
																 BaseDebit,BaseCredit,
																 DocDebitTotal,DocCreditTotal,BaseDebitTotal,BaseCreditTotal,DocumentId,DocumentDetailId,ItemId,BaseCurrency,ExchangeRate, DocType,DocSubType,ServiceCompanyId,DocNo,Nature,OffsetDocument,IsTax,
																EntityId, SystemRefNo, DocCurrency,DocDate, PostingDate,RecOrder 
																)
								Select NEWID(),@JournalId,@ExchangeGainOrLossCOAID,R.Remarks,Null As DocDebit,Null As DocCredit,
									Case When (@ExchangeRate-@SysCalExchangerate)>0 Then ABS(Round((@ExchangeRate-@SysCalExchangerate) * RD.ReceiptAmount,2)) End As BaseDebit,
									Case When (@ExchangeRate-@SysCalExchangerate)<0 Then ABS(Round((@ExchangeRate-@SysCalExchangerate) * RD.ReceiptAmount,2)) End As BaseCredit,
									0.00 As DocDebitTotal,0.00 As DocCreditTotal,0.00 As BaseDebitTotal,0.00 As BaseCreditTotal,R.Id As DocumentId,RD.Id As DocumentDetailId,@GUIDZero,
									R.BaseCurrency,@ExchangeRate As ExchangeRate,@DocType,@DocSubType,RD.ServiceCompanyId,R.DocNo,Null As Nature,Null As DocumentNo,0 As IsTax,
									R.EntityId,@SystemRefNo,@DocCurrency,R.DocDate,R.DocDate,@RecOrderAnotherJV As RecOrder
								From Bean.Receipt(Nolock) As R
								Inner Join bean.ReceiptDetail(Nolock) As RD On RD.ReceiptId=R.Id
								Where R.Id=@SourceId And RD.Id=@RecieptDtlId
							End
						End
						Set @RecCount=@RecCount+1
					End
				End
			End
			-- Reciept OFF Set Single Company Records
			Else IF ((Select Isnull(IsVendor,0) From Bean.Receipt(Nolock) Where Id=@SourceId)=1 Or @ReceiptOffSet>=1) And (@ServCompCount<=1 Or @ServCompCount2 = 0)
			Begin
				Set @MasterJournalId=NEWID()
				Set @MasterSystemRefNo=CONCAT(@DocNo,'-JV',@SysRefNum_Incr)
				Insert Into Bean.Journal (Id,CompanyId,DocDate,DocType,DocSubType,DocNo,ServiceCompanyId,SystemReferenceNo,IsNoSupportingDocs,NoSupportingDocument,DocCurrency,ExchangeRate,ExCurrency,ExDurationFrom,GSTExchangeRate,GSTExCurrency,GSTTotalAmount,DocumentState,IsNoSupportingDocument,IsGstSettings,IsMultiCurrency,IsAllowableNonAllowable,IsGSTCurrencyRateChanged,Remarks,UserCreated,CreatedDate,Status,DocumentDescription,CreationType,GrandDocDebitTotal,GrandDocCreditTotal,GrandBaseDebitTotal,
										GrandBaseCreditTotal,EntityId,EntityType,PostingDate,COAId,ModeOfReceipt,BankReceiptAmmount,ExcessPaidByClientAmmount,BalancingItemReciveCRAmount,  BalancingItemPayDRAmount,ReceiptApplicationAmmount,DocumentId,BankClearingDate,IsBalancing,ISAllowDisAllow,IsShow,ActualSysRefNo,IsSegmentReporting,TransferRefNo
										)
				Select @MasterJournalId,@CompanyId,DocDate,@DocType,@DocSubType,DocNo,ServiceCompanyId,@MasterSystemRefNo As SystemRefNo,IsNoSupportingDocument,NoSupportingDocs,DocCurrency,ExchangeRate,ExCurrency,ExDurationFrom,GSTExchangeRate,GSTExCurrency,Isnull(GSTTotalAmount,0),DocumentState,NoSupportingDocs,IsGstSettings,IsMultiCurrency,IsAllowableDisallowable,IsGSTCurrencyRateChanged,Remarks,@UserCreated,@CreatedDate,Status,Remarks As DocDescription,@UserCreated,GrandTotal,0.00 As GrandDocCreditTotal,Round(GrandTotal * ExchangeRate,2) As GrandBaseDebitTotal,
						0.00 As GrandBaseCreditTotal,EntityId,EntityType,DocDate As PostingDate,COAId,ModeOfReceipt,0.00 As BankReceiptAmmount,0.00 As ExcessPaidByClientAmmount,0.00 As BalancingItemReciveCRAmount,0.00 As BalancingItemPayDRAmount,0.00 As ReceiptApplicationAmmount,Id As DocumentId,BankClearingDate,0 As IsBalancing,IsDisAllow,1 As IsShow,DocNo As ActualSysRefNo,0 As IsSegmentReporting,ReceiptRefNo
				From Bean.Receipt(Nolock) Where CompanyId=@CompanyId And Id=@SourceId

				IF @DocCurrency=@BankChargesCurrency And @BaseCurrency=@DocCurrency
				Begin
					/* Creating Mater record In JournalDetail */
					IF Exists (Select Id From Bean.Receipt(Nolock) Where Id=@SourceId And GrandTotal<>0)
					Begin
						Insert Into Bean.JournalDetail (Id,JournalId,COAId,AccountDescription,AllowDisAllow,DocDebit,BaseDebit,DocDebitTotal,DocCreditTotal,BaseDebitTotal,BaseCreditTotal,DocumentId,DocumentDetailId,ItemId,BaseCurrency,ExchangeRate,GSTExCurrency,GSTExchangeRate,DocType,DocSubType,ServiceCompanyId,DocNo,IsTax,
										EntityId,SystemRefNo,DocCurrency,DocDate,PostingDate,RecOrder)
						Select NEWID(),@MasterJournalId,COAId,Remarks,IsDisAllow,Isnull(BankReceiptAmmount,0) As BankReceiptAmmount,Round(Isnull(BankReceiptAmmount,0) * ExchangeRate,2),0.00 As DocDebitTotal,0.00 As DocCreditTotal,0.00 As BaseDebitTotal,0.00 As BaseCreditTotal,Id As DocumentId,@GUIDZero,@GUIDZero,
								BaseCurrency,ExchangeRate,GSTExCurrency,GSTExchangeRate,@DocType,@DocSubType,ServiceCompanyId,DocNo,0 As IsTax,
								EntityId,@MasterSystemRefNo As SystemRefNo,@DocCurrency,DocDate,DocDate,@RecOrder As RecOrder
						From Bean.Receipt(Nolock) Where Id=@SourceId
					End
					Else IF Exists (Select Id From Bean.Receipt(Nolock) Where Id=@SourceId And GrandTotal=0 And BankReceiptAmmount<>0)
					Begin
						Insert Into Bean.JournalDetail (Id,JournalId,COAId,AccountDescription,AllowDisAllow,DocDebit,BaseDebit,DocDebitTotal,DocCreditTotal,BaseDebitTotal,BaseCreditTotal,DocumentId,DocumentDetailId,ItemId,BaseCurrency,ExchangeRate,GSTExCurrency,GSTExchangeRate,DocType,DocSubType,ServiceCompanyId,DocNo,IsTax,
										EntityId,SystemRefNo,DocCurrency,DocDate,PostingDate,RecOrder)
						Select NEWID(),@MasterJournalId,COAId,Remarks,IsDisAllow,Isnull(BankReceiptAmmount,0) As BankReceiptAmmount,Round(Isnull(BankReceiptAmmount,0) * ExchangeRate,2),0.00 As DocDebitTotal,0.00 As DocCreditTotal,0.00 As BaseDebitTotal,0.00 As BaseCreditTotal,Id As DocumentId,@GUIDZero,@GUIDZero,
								BaseCurrency,ExchangeRate,GSTExCurrency,GSTExchangeRate,@DocType,@DocSubType,ServiceCompanyId,DocNo,0 As IsTax,
								EntityId,@MasterSystemRefNo As SystemRefNo,@DocCurrency,DocDate,DocDate,@RecOrder As RecOrder
						From Bean.Receipt(Nolock) Where Id=@SourceId
					End
					/* Creating Record in Journaldetail With Bank Charges Amount */
					If Exists(Select Id From Bean.Receipt(Nolock) Where Id=@SourceId And BankCharges Is Not Null)
					Begin
						Set @RecOrder=@RecOrder+1
						Insert Into Bean.JournalDetail (Id,JournalId,COAId,AccountDescription,AllowDisAllow,TaxId,TaxType,TaxRate,DocDebit,BaseDebit,DocDebitTotal,DocCreditTotal,BaseDebitTotal,BaseCreditTotal,DocumentId,DocumentDetailId,ItemId,BaseCurrency,ExchangeRate,GSTExCurrency,GSTExchangeRate,DocType,DocSubType,ServiceCompanyId,DocNo, IsTax,
													EntityId,SystemRefNo,DocCurrency,DocDate,PostingDate,RecOrder,GSTTaxDebit)
						Select NEWID(),@MasterJournalId,@BankCharges_COAId,Remarks,IsDisAllow,@TaxId,@TaxType,@TaxRate,BankCharges,BankCharges * Round(ExchangeRate,2),0.00 As DocDebitTotal,0.00 As DocCreditTotal,0.00 As BaseDebitTotal,0.00 As BaseCreditTotal,Id As DocumentId,Id As DocumentDetailId,@GUIDZero,
							BaseCurrency,ExchangeRate,GSTExCurrency,GSTExchangeRate,@DocType,@DocSubType,ServiceCompanyId,DocNo,0 As IsTax,
							EntityId,@MasterSystemRefNo As SystemRefNo,@DocCurrency,DocDate,DocDate,@RecOrder As RecOrder,
							Case When @TaxId Is Not Null Then Round(BankCharges * Coalesce(GSTexchangerate,@DefaultExchangeRate),2) End As GSTTaxDebit
						From Bean.Receipt(Nolock)
						Where Id=@SourceId
					End
					/* Creating Record in Journaldetail With @ExcesPaidByClientAmt Amount */
					If @ExcesPaidByClientAmt Is NOt Null
					Begin
						Set @RecOrder=@RecOrder+1
						Insert Into Bean.JournalDetail (Id,JournalId,COAId,AccountDescription,AllowDisAllow,DocCredit,BaseCredit,DocDebitTotal,DocCreditTotal,BaseDebitTotal,BaseCreditTotal,DocumentId,DocumentDetailId,ItemId,BaseCurrency,ExchangeRate,GSTExCurrency,GSTExchangeRate,DocType,DocSubType,ServiceCompanyId,DocNo,IsTax,
														EntityId,SystemRefNo,DocCurrency,DocDate,PostingDate,RecOrder)
						Select NEWID(),@MasterJournalId,@ClearingReceiptsCOAID,Remarks,IsDisAllow,ExcessPaidByClientAmmount,ExcessPaidByClientAmmount * Round(ExchangeRate,2),0.00 As DocDebitTotal,0.00 As DocCreditTotal,0.00 As BaseDebitTotal,0.00 As BaseCreditTotal,Id As DocumentId,Id As DocumentDtlId,@GUIDZero,
								BaseCurrency,ExchangeRate,BankReceiptAmmountCurrency,ExchangeRate,@DocType,@DocSubType,ServiceCompanyId,DocNo,0 As IsTax,
								EntityId,@MasterSystemRefNo,@DocCurrency,DocDate,DocDate,@RecOrder As RecOrder
						From Bean.Receipt(Nolock)
						Where Id=@SourceId
					End
					/* Creating Balancing Line Items */
					Insert Into @RecieptBalLnItm
					Select RBI.Id From Bean.ReceiptBalancingItem(Nolock) As RBI
					Inner Join bean.Receipt(Nolock) As R On R.Id=RBI.ReceiptId
					Where R.Id=@SourceId Order by RecOrder
					Set @Count=(Select Count(*) From @RecieptBalLnItm)
					Set @RecCount=1
					While @Count>=@RecCount
					Begin
						Select @RecieptBalId=RecieptBalId From @RecieptBalLnItm Where S_no=@RecCount
						Select @TaxId=TaxId,@TaxRate=TaxRate From Bean.ReceiptBalancingItem(Nolock) Where Id=@RecieptBalId
						Set @RecOrder=@RecOrder+1
						Insert Into Bean.JournalDetail (Id,JournalId,COAId,AccountDescription,AllowDisAllow,TaxId,TaxType,TaxRate,DocDebit,DocCredit,
													DocTaxDebit,DocTaxCredit,BaseDebit,BaseCredit,
													BaseTaxDebit,BaseTaxCredit,DocDebitTotal,DocCreditTotal,BaseDebitTotal,BaseCreditTotal,DocumentId,DocumentDetailId,ItemId,BaseCurrency,ExchangeRate,GSTExCurrency,GSTExchangeRate,DocType,DocSubType,ServiceCompanyId,DocNo, IsTax,
													EntityId, SystemRefNo, DocCurrency,DocDate, PostingDate,RecOrder,GSTTaxDebit,GSTTaxCredit,GSTDebit,GSTCredit)
						Select NEWID(),@MasterJournalId,RBi.COAId,R.Remarks,RBI.IsDisAllow,RBI.TaxId,RBI.TaxType,Rbi.TaxRate,
						Case When RBI.ReciveORPay=@Pay_Dr Then RBI.DocAmount End As DocDebit,Case When RBI.ReciveORPay=@Receive_Cr Then RBI.DocAmount End As DocCredit,
							Case When RBI.ReciveORPay=@Pay_Dr Then RBI.DocTaxAmount End As DocTaxDebdit,
							Case When RBI.ReciveORPay=@Receive_Cr Then RBI.DocTaxAmount End As DocTaxCredit,
							Case When RBI.ReciveORPay=@Pay_Dr Then RBI.DocAmount * Round(@DefaultExchangeRate,2) End As BaseDebit,
							Case When RBI.ReciveORPay=@Receive_Cr Then RBI.DocAmount * Round(@DefaultExchangeRate,2) End As BaseCredit,
							Case When RBI.ReciveORPay=@Pay_Dr Then RBI.DocTaxAmount * Round(@DefaultExchangeRate,2) End As BaseTaxDebdit,
							Case When RBI.ReciveORPay=@Receive_Cr Then RBI.DocTaxAmount * Round(@DefaultExchangeRate,2) End As BaseTaxCredit,0.00 As DocDebitTotal,0.00 As DocCreditTotal,0.00 As BaseDebitTotal,0.00 As BaseCreditTotal,R.Id As DocumentId,RBI.Id As DocumentDetailId,@GUIDZero,
							R.BaseCurrency,R.ExchangeRate,R.GSTExCurrency,R.GSTExchangeRate,@DocType,@DocSubType,ServiceCompanyId,DocNo,0 As IsTax,
							EntityId,@MasterSystemRefNo,@DocCurrency,DocDate,DocDate,@RecOrder As RecOrder,
							Case When RBI.ReciveORPay=@Pay_Dr Then Round(RBI.DocAmount * Coalesce(R.GSTExchangeRate,@DefaultExchangeRate),2) End As GSTTaxDebit,
							Case When RBI.ReciveORPay=@Receive_Cr Then Round(RBI.DocAmount * Coalesce(R.GSTExchangeRate,@DefaultExchangeRate),2) End As GSTTaxCredit,
							Case When RBI.ReciveORPay=@Pay_Dr Then Round(RBI.DocTaxAmount * Coalesce(R.GSTExchangeRate,@DefaultExchangeRate),2) End As GSTDebit,
							Case When RBI.ReciveORPay=@Receive_Cr Then Round(RBI.DocTaxAmount * Coalesce(R.GSTExchangeRate,@DefaultExchangeRate),2) End As GSTCredit
						From Bean.Receipt(Nolock) As R
						Inner Join bean.ReceiptBalancingItem(Nolock) As RBI On RBI.ReceiptId=R.Id
						Where R.Id=@SourceId And Rbi.Id=@RecieptBalId
						-- Creating Tax Line Items
						If @GST Is Not Null And @GST=1 And @TaxId Is Not Null And (@TaxRate Is Not Null And @TaxRate<>0)
						Begin
							Set @TaxRecCount=@RecOrder+@Count
							Insert Into Bean.JournalDetail (Id,JournalId,COAId,AccountDescription,AllowDisAllow,TaxId,TaxType,TaxRate,DocDebit,DocCredit,
									 BaseDebit,BaseCredit,
									 DocDebitTotal,DocCreditTotal,BaseDebitTotal,BaseCreditTotal,DocumentId,DocumentDetailId,ItemId,BaseCurrency,ExchangeRate,GSTExCurrency,GSTExchangeRate,DocType,DocSubType,ServiceCompanyId,DocNo, IsTax,
									EntityId, SystemRefNo, DocCurrency,DocDate, PostingDate,RecOrder )
							Select NEWID(),@MasterJournalId,@TaxPayableGST_COAID as COAId,R.Remarks,RBI.IsDisAllow,RBI.TaxId,RBI.TaxType,Rbi.TaxRate,Case When RBI.ReciveORPay=@Pay_Dr Then RBI.DocTaxAmount End As DocDebit,Case When RBI.ReciveORPay=@Receive_Cr Then RBI.DocTaxAmount End As DocCredit,
								Case When RBI.ReciveORPay=@Pay_Dr Then RBI.DocTaxAmount * Round(R.GSTExchangeRate,2) End As BaseDebit,Case When RBI.ReciveORPay=@Receive_Cr Then RBI.DocTaxAmount * Round(R.GSTExchangeRate,2) End As BaseCredit,
								0.00 As DocDebitTotal,0.00 As DocCreditTotal,0.00 As BaseDebitTotal,0.00 As BaseCreditTotal,R.Id As DocumentId,RBI.Id As DocumentDetailId,@GUIDZero,
								R.BaseCurrency,R.ExchangeRate,R.GSTExCurrency,R.GSTExchangeRate,@DocType,@DocSubType,ServiceCompanyId,DocNo,1 As IsTax,
								EntityId,@MasterSystemRefNo,@DocCurrency,DocDate,DocDate,@TaxRecCount As RecOrder
							From Bean.Receipt(Nolock) As R
							Inner Join bean.ReceiptBalancingItem(Nolock) As RBI On RBI.ReceiptId=R.Id
							Where R.Id=@SourceId And Rbi.Id=@RecieptBalId
						End
						Set @RecCount=@RecCount+1
					End
					/*OutStanding Records*/
					IF Exists (Select Id From Bean.ReceiptDetail(Nolock) Where ReceiptId=@SourceId And ReceiptAmount<>0)
					Begin
						-- Creating Records For Interco In Journal Detail
						Insert Into @RecieptDtl 
						Select RD.Id From Bean.ReceiptDetail(Nolock) As RD
						Inner Join Bean.Receipt(Nolock) As R On RD.ReceiptId=R.Id 
						Where R.Id=@SourceId And RD.ReceiptAmount<>0 Order By RD.RecOrder 
						Set @Count=(Select Count(*) From @RecieptDtl)
						--Set @RecOrder=2
						Set @RecCount=1
						While @Count>=@RecCount
						Begin
							Set @IsRoundingAmount=0
							Set @RecieptDtlId=(Select RecieptDtlId From @RecieptDtl Where S_No=@RecCount)
							Set @OffSetDocumentType =(Select DocumentType From Bean.ReceiptDetail(Nolock) Where Id=@RecieptDtlId)
							Set @DocumentId=(Select DocumentId From Bean.ReceiptDetail(Nolock) Where Id=@RecieptDtlId)
							--Getting COAID By Checking Nature
							IF Exists (Select ID From Bean.ReceiptDetail(Nolock) Where id=@RecieptDtlId And Nature=@NatureTrade And DocumentType=@InvoiceDocument)
							Begin
								Set @COAID=(Select Id From Bean.ChartOfAccount(Nolock) Where CompanyId=@CompanyId And Name=@COATradeReceivables)
								IF Exists (Select Id From Bean.Invoice(Nolock) Where Id=@DocumentId And DocumentState In (@FullyApplied,@Fullypaid))
								Begin
									Set @IsRoundingAmount=1
								End
							End
							Else IF Exists (Select ID From Bean.ReceiptDetail(Nolock) Where id=@RecieptDtlId And Nature=@NatureOthers And DocumentType=@InvoiceDocument)
							Begin
								Set @COAID=(Select Id From Bean.ChartOfAccount(Nolock) Where CompanyId=@CompanyId And Name=@COAotherReceivables)
								IF Exists (Select Id From Bean.Invoice(Nolock) Where Id=@DocumentId And DocumentState In (@FullyApplied,@Fullypaid))
								Begin
									Set @IsRoundingAmount=1
								End
							End
							Else IF Exists (Select ID From Bean.ReceiptDetail(Nolock) Where id=@RecieptDtlId And Nature=@NatureTrade And DocumentType=@DebitNoteDocument)
							Begin
								Set @COAID=(Select Id From Bean.ChartOfAccount(Nolock) Where CompanyId=@CompanyId And Name=@COATradeReceivables)
								IF Exists (Select Id From Bean.DebitNote(Nolock) Where Id=@DocumentId And DocumentState In (@FullyApplied,@Fullypaid))
								Begin
									Set @IsRoundingAmount=1
								End
							End
							Else IF Exists (Select ID From Bean.ReceiptDetail(Nolock) Where id=@RecieptDtlId And Nature=@NatureOthers And DocumentType=@DebitNoteDocument)
							Begin
								Set @COAID=(Select Id From Bean.ChartOfAccount(Nolock) Where CompanyId=@CompanyId And Name=@COAotherReceivables )
								IF Exists (Select Id From Bean.DebitNote(Nolock) Where Id=@DocumentId And DocumentState In (@FullyApplied,@Fullypaid))
								Begin
									Set @IsRoundingAmount=1
								End
							End
							Else IF Exists (Select ID From Bean.ReceiptDetail(Nolock) Where id=@RecieptDtlId And DocumentType=@CreditNoteDocument)
							Begin
								Set @COAID=(Select Id From Bean.ChartOfAccount(Nolock) Where CompanyId=@CompanyId And Name=@ClearingReceipts)
							End
							Else IF Exists (Select ID From Bean.ReceiptDetail(Nolock) Where id=@RecieptDtlId And DocumentType=@CreditMemoDocument)
							Begin
								Set @COAID=(Select Id From Bean.ChartOfAccount(Nolock) Where CompanyId=@CompanyId And Name=@ClearingReceipts)
							End
							Else IF Exists (Select ID From Bean.ReceiptDetail(Nolock) Where id=@RecieptDtlId And DocumentType=@BillDocument And Nature=@NatureTrade)
							Begin
								Set @COAID=(Select Id From Bean.ChartOfAccount(Nolock) Where CompanyId=@CompanyId And Name=@COATradePayables)
								IF Exists (Select Id From Bean.Bill(Nolock) Where Id=@DocumentId And DocumentState In (@FullyApplied,@Fullypaid))
								Begin
									Set @IsRoundingAmount=1
								End
							End
							Else IF Exists (Select ID From Bean.ReceiptDetail(Nolock) Where id=@RecieptDtlId And DocumentType=@BillDocument And Nature=@NatureOthers)
							Begin
								Set @COAID=(Select Id From Bean.ChartOfAccount(Nolock) Where CompanyId=@CompanyId And Name=@COAOtherPayables)
								IF Exists (Select Id From Bean.Bill(Nolock) Where Id=@DocumentId And DocumentState In (@FullyApplied,@Fullypaid))
								Begin
									Set @IsRoundingAmount=1
								End
							End
							IF Coalesce(@OffSetDocumentType,'NULL')=@CreditNoteDocument Or  Coalesce(@OffSetDocumentType,'NULL')=@CreditMemoDocument
							Begin
								Set @DocAmount=0
							End
							IF @IsRoundingAmount=1 And Exists (Select Amount From @RoundingAmountDetails Where DocumentId=@DocumentId And Amount Is Not Null And Amount<>'')
							Begin
								Set @DocAmount=(Select Amount From @RoundingAmountDetails Where DocumentId=@DocumentId)
							End
							Else
							Begin
								Set @DocAmount=0
							End
							IF (Coalesce(@OffSetDocumentType,'NULL')=@CreditNoteDocument Or Coalesce(@OffSetDocumentType,'NULL')=@BillDocument)
							Begin
								Insert Into Bean.JournalDetail (Id,JournalId,COAId,AccountDescription, DocDebit,DocCredit,
																 BaseDebit,BaseCredit,
																 DocDebitTotal,DocCreditTotal,BaseDebitTotal,BaseCreditTotal,DocumentId,DocumentDetailId,ItemId,BaseCurrency,ExchangeRate, DocType,DocSubType,ServiceCompanyId,DocNo,Nature,OffsetDocument,IsTax,
																EntityId, SystemRefNo, DocCurrency,DocDate, PostingDate,RecOrder 
																)
								Select NEWID(),@MasterJournalId,@COAID,R.Remarks,RD.ReceiptAmount As DocDebit,Null As DocCredit,
									Round(RD.ReceiptAmount * @DefaultExchangeRate,2)- Isnull(@DocAmount,0) As BaseDebit,Null As BaseCredit,
									0.00 As DocDebitTotal,0.00 As DocCreditTotal,0.00 As BaseDebitTotal,0.00 As BaseCreditTotal,R.Id As DocumentId,RD.Id As DocumentDetailId,@GUIDZero,
									R.BaseCurrency,@DefaultExchangeRate As ExchangeRate,@DocType,@DocSubType,@MasterServComp As ServiceCompanyId,R.DocNo,RD.Nature,Null As DocumentNo,0 As IsTax,
									R.EntityId,@MasterSystemRefNo,@DocCurrency,R.DocDate,R.DocDate,@RecOrder As RecOrder
								From Bean.Receipt(Nolock) As R
								Inner Join bean.ReceiptDetail(Nolock) As RD On RD.ReceiptId=R.Id
								Where R.Id=@SourceId And RD.Id=@RecieptDtlId
							End
							Else
							Begin
								Insert Into Bean.JournalDetail (Id,JournalId,COAId,AccountDescription, DocDebit,DocCredit,
														 BaseDebit,BaseCredit,
														 DocDebitTotal,DocCreditTotal,BaseDebitTotal,BaseCreditTotal,DocumentId,DocumentDetailId,ItemId,BaseCurrency,ExchangeRate, DocType,DocSubType,ServiceCompanyId,DocNo,Nature,OffsetDocument,IsTax,
														EntityId, SystemRefNo, DocCurrency,DocDate, PostingDate,RecOrder 
														)
								Select NEWID(),@MasterJournalId,@COAID,R.Remarks,Null As DocDebit,RD.ReceiptAmount As DocCredit,
									Null As BaseDebit,Round(RD.ReceiptAmount * @DefaultExchangeRate,2)- Isnull(@DocAmount,0) As BaseCredit,
									0.00 As DocDebitTotal,0.00 As DocCreditTotal,0.00 As BaseDebitTotal,0.00 As BaseCreditTotal,R.Id As DocumentId,RD.Id As DocumentDetailId,@GUIDZero,
									R.BaseCurrency,@DefaultExchangeRate As ExchangeRate,@DocType,@DocSubType,@MasterServComp As ServiceCompanyId,R.DocNo,RD.Nature,RD.DocumentNo,0 As IsTax,
									R.EntityId,@MasterSystemRefNo,@DocCurrency,R.DocDate,R.DocDate,@RecOrder As RecOrder
								From Bean.Receipt(Nolock) As R
								Inner Join bean.ReceiptDetail(Nolock) As RD On RD.ReceiptId=R.Id
								Where R.Id=@SourceId And RD.Id=@RecieptDtlId
							End
							Set @RecOrder=@RecOrder+1
							Set @RecCount=@RecCount+1
						End
					End
				End
				/*@DocCurrency=@BankChargesCurrency<>@DocCurrency*/
				Else IF @DocCurrency=@BankChargesCurrency And @BaseCurrency<>@DocCurrency
				Begin
					/* Creating Mater record In JournalDetail */
					IF Exists (Select Id From Bean.Receipt(Nolock) Where Id=@SourceId And GrandTotal<>0)
					Begin
						Insert Into Bean.JournalDetail (Id,JournalId,COAId,AccountDescription,AllowDisAllow, DocDebit, BaseDebit, DocDebitTotal,DocCreditTotal,BaseDebitTotal,BaseCreditTotal,DocumentId,DocumentDetailId,ItemId,BaseCurrency,ExchangeRate,GSTExCurrency,GSTExchangeRate,DocType,DocSubType,ServiceCompanyId,DocNo, IsTax,
										EntityId, SystemRefNo, DocCurrency,DocDate, PostingDate,RecOrder )
						Select NEWID(),@MasterJournalId,COAId,Remarks,IsDisAllow,Isnull(BankReceiptAmmount,0) As BankReceiptAmmount,Round(Isnull(BankReceiptAmmount,0) * @MainExchangeRate,2),0.00 As DocDebitTotal,0.00 As DocCreditTotal,0.00 As BaseDebitTotal,0.00 As BaseCreditTotal,Id As DocumentId,@GUIDZero,@GUIDZero,
								BaseCurrency,@MainExchangeRate As ExchangeRate,GSTExCurrency,GSTExchangeRate,@DocType,@DocSubType,ServiceCompanyId,DocNo,0 As IsTax,
								EntityId,@MasterSystemRefNo As SystemRefNo,@BankChargesCurrency,DocDate,DocDate,@RecOrder As RecOrder
						From Bean.Receipt(Nolock) Where Id=@SourceId
					End
					Else IF Exists (Select Id From Bean.Receipt(Nolock) Where Id=@SourceId And GrandTotal=0 And BankReceiptAmmount<>0)
					Begin
						Insert Into Bean.JournalDetail (Id,JournalId,COAId,AccountDescription,AllowDisAllow, DocDebit, BaseDebit, DocDebitTotal,DocCreditTotal,BaseDebitTotal,BaseCreditTotal,DocumentId,DocumentDetailId,ItemId,BaseCurrency,ExchangeRate,GSTExCurrency,GSTExchangeRate,DocType,DocSubType,ServiceCompanyId,DocNo, IsTax,
										EntityId, SystemRefNo, DocCurrency,DocDate, PostingDate,RecOrder )
						Select NEWID(),@MasterJournalId,COAId,Remarks,IsDisAllow,Isnull(BankReceiptAmmount,0) As BankReceiptAmmount,Round(Isnull(BankReceiptAmmount,0) * @MainExchangeRate,2),0.00 As DocDebitTotal,0.00 As DocCreditTotal,0.00 As BaseDebitTotal,0.00 As BaseCreditTotal,Id As DocumentId,@GUIDZero,@GUIDZero,
								BaseCurrency,@MainExchangeRate As ExchangeRate,GSTExCurrency,GSTExchangeRate,@DocType,@DocSubType,ServiceCompanyId,DocNo,0 As IsTax,
								EntityId,@MasterSystemRefNo As SystemRefNo,@BankChargesCurrency,DocDate,DocDate,@RecOrder As RecOrder
						From Bean.Receipt(Nolock) Where Id=@SourceId
					End
					/* Creating Record in Journaldetail With Bank Charges Amount */
					If Exists(Select Id From Bean.Receipt(Nolock) Where Id=@SourceId And BankCharges Is Not Null)
					Begin
						Set @RecOrder=@RecOrder+1
						Insert Into Bean.JournalDetail (Id,JournalId,COAId,AccountDescription,AllowDisAllow,TaxId,TaxType,TaxRate,DocDebit, BaseDebit, DocDebitTotal,DocCreditTotal,BaseDebitTotal,BaseCreditTotal,DocumentId,DocumentDetailId,ItemId,BaseCurrency,ExchangeRate,GSTExCurrency,GSTExchangeRate,DocType,DocSubType,ServiceCompanyId,DocNo, IsTax,
													EntityId, SystemRefNo, DocCurrency,DocDate, PostingDate,RecOrder,GSTTaxDebit)
						Select NEWID(),@MasterJournalId,@BankCharges_COAId,Remarks,IsDisAllow,@TaxId,@TaxType,@TaxRate,BankCharges,Round(BankCharges * ExchangeRate,2),0.00 As DocDebitTotal,0.00 As DocCreditTotal,0.00 As BaseDebitTotal,0.00 As BaseCreditTotal,Id As DocumentId,Id As DocumentDetailId,@GUIDZero,
							BaseCurrency,ExchangeRate,GSTExCurrency,GSTExchangeRate,@DocType,@DocSubType,ServiceCompanyId,DocNo,0 As IsTax,
							EntityId,@MasterSystemRefNo As SystemRefNo,@BankChargesCurrency,DocDate,DocDate,@RecOrder As RecOrder,
							Case When @TaxId Is Not Null Then Round(BankCharges * Coalesce(GSTexchangerate,@DefaultExchangeRate),2) End As GSTTaxDebit
						From Bean.Receipt(Nolock) 
						Where Id=@SourceId
					End
					/* Creating Record in Journaldetail With @ExcesPaidByClientAmt Amount */
					If @ExcesPaidByClientAmt Is NOt Null
					Begin
						Set @RecOrder=@RecOrder+1
						Insert Into Bean.JournalDetail (Id,JournalId,COAId,AccountDescription,AllowDisAllow, DocCredit, BaseCredit, DocDebitTotal,DocCreditTotal,BaseDebitTotal,BaseCreditTotal,DocumentId,DocumentDetailId,ItemId,BaseCurrency,ExchangeRate,GSTExCurrency,GSTExchangeRate,DocType,DocSubType,ServiceCompanyId,DocNo, IsTax,
														EntityId, SystemRefNo, DocCurrency,DocDate, PostingDate,RecOrder )
						Select NEWID(),@MasterJournalId,@ClearingReceiptsCOAID,Remarks,IsDisAllow,ExcessPaidByClientAmmount As DocCredit,Round(ExcessPaidByClientAmmount * ExchangeRate,2) As BaseCredit,0.00 As DocDebitTotal,0.00 As DocCreditTotal,0.00 As BaseDebitTotal,0.00 As BaseCreditTotal,Id As DocumentId,Id As DocumentDtlId,@GUIDZero,
								BaseCurrency,ExchangeRate,BankReceiptAmmountCurrency,ExchangeRate,@DocType,@DocSubType,ServiceCompanyId,DocNo,0 As IsTax,
								EntityId,@MasterSystemRefNo,@BankChargesCurrency,DocDate,DocDate,@RecOrder As RecOrder
						From Bean.Receipt(Nolock)
						Where Id=@SourceId
					End
					/* Creating Balancing Line Items */
					Insert Into @RecieptBalLnItm
					Select RBI.Id From Bean.ReceiptBalancingItem(Nolock) As RBI
					Inner Join bean.Receipt(Nolock) As R On R.Id=RBI.ReceiptId
					Where R.Id=@SourceId Order by RecOrder
					Set @Count=(Select Count(*) From @RecieptBalLnItm)
					Set @RecCount=1
					While @Count>=@RecCount
					Begin
						Select @RecieptBalId=RecieptBalId From @RecieptBalLnItm Where S_no=@RecCount
						Select @TaxId=TaxId,@TaxRate=TaxRate From Bean.ReceiptBalancingItem(Nolock) Where Id=@RecieptBalId
						Set @RecOrder=@RecOrder+1
						Insert Into Bean.JournalDetail (Id,JournalId,COAId,AccountDescription,AllowDisAllow,TaxId,TaxType,TaxRate,DocDebit,DocCredit,
													DocTaxDebit,DocTaxCredit,BaseDebit,BaseCredit,
													BaseTaxDebit,BaseTaxCredit,DocDebitTotal,DocCreditTotal,BaseDebitTotal,BaseCreditTotal,DocumentId,DocumentDetailId,ItemId,BaseCurrency,ExchangeRate,GSTExCurrency,GSTExchangeRate,DocType,DocSubType,ServiceCompanyId,DocNo, IsTax,
													EntityId, SystemRefNo, DocCurrency,DocDate, PostingDate,RecOrder,GSTTaxDebit,GSTTaxCredit,GSTDebit,GSTCredit)
						Select NEWID(),@MasterJournalId,RBi.COAId,R.Remarks,RBI.IsDisAllow,RBI.TaxId,RBI.TaxType,Rbi.TaxRate,Case When RBI.ReciveORPay=@Pay_Dr Then RBI.DocAmount End As DocDebit,
						Case When RBI.ReciveORPay=@Receive_Cr Then RBI.DocAmount End As DocCredit,
							Case When RBI.ReciveORPay=@Pay_Dr Then RBI.DocTaxAmount End As DocTaxDebdit,Case When RBI.ReciveORPay=@Receive_Cr Then RBI.DocTaxAmount End As DocTaxCredit,
							Case When RBI.ReciveORPay=@Pay_Dr Then Round(RBI.DocAmount * @MainExchangeRate,2) End As BaseDebit,
							Case When RBI.ReciveORPay=@Receive_Cr Then Round(RBI.DocAmount * @MainExchangeRate,2) End As BaseCredit,
							Case When RBI.ReciveORPay=@Pay_Dr Then Round(RBI.DocTaxAmount * @MainExchangeRate,2) End As BaseTaxDebdit,
							Case When RBI.ReciveORPay=@Receive_Cr Then Round(RBI.DocTaxAmount * @MainExchangeRate,2) End As BaseTaxCredit,0.00 As DocDebitTotal,0.00 As DocCreditTotal,0.00 As BaseDebitTotal,0.00 As BaseCreditTotal,R.Id As DocumentId,RBI.Id As DocumentDetailId,@GUIDZero,
							R.BaseCurrency,R.ExchangeRate,R.GSTExCurrency,R.GSTExchangeRate,@DocType,@DocSubType,ServiceCompanyId,DocNo,0 As IsTax,
							EntityId,@MasterSystemRefNo,@BankChargesCurrency,DocDate,DocDate,@RecOrder As RecOrder,
							Case When RBI.ReciveORPay=@Pay_Dr Then Round(RBI.DocAmount * Coalesce(R.GSTExchangeRate,@DefaultExchangeRate),2) End As GSTTaxDebit,
							Case When RBI.ReciveORPay=@Receive_Cr Then Round(RBI.DocAmount * Coalesce(R.GSTExchangeRate,@DefaultExchangeRate),2) End As GSTTaxCredit,
							Case When RBI.ReciveORPay=@Pay_Dr Then Round(RBI.DocTaxAmount * Coalesce(R.GSTExchangeRate,@DefaultExchangeRate),2) End As GSTDebit,
							Case When RBI.ReciveORPay=@Receive_Cr Then Round(RBI.DocTaxAmount * Coalesce(R.GSTExchangeRate,@DefaultExchangeRate),2) End As GSTCredit
						From Bean.Receipt(Nolock) As R
						Inner Join bean.ReceiptBalancingItem(Nolock) As RBI On RBI.ReceiptId=R.Id
						Where R.Id=@SourceId And Rbi.Id=@RecieptBalId
						-- Creating Tax Line Items
						If @GST Is Not Null And @GST=1 And @TaxId Is Not Null And (@TaxRate Is Not Null And @TaxRate<>0)
						Begin
							Set @TaxRecCount=@RecOrder+@Count
							Insert Into Bean.JournalDetail (Id,JournalId,COAId,AccountDescription,AllowDisAllow,TaxId,TaxType,TaxRate,DocDebit,DocCredit,
									 BaseDebit,BaseCredit,
									 DocDebitTotal,DocCreditTotal,BaseDebitTotal,BaseCreditTotal,DocumentId,DocumentDetailId,ItemId,BaseCurrency,ExchangeRate,GSTExCurrency,GSTExchangeRate,DocType,DocSubType,ServiceCompanyId,DocNo, IsTax,
									EntityId, SystemRefNo, DocCurrency,DocDate, PostingDate,RecOrder )
							Select NEWID(),@MasterJournalId,@TaxPayableGST_COAID as COAId,R.Remarks,RBI.IsDisAllow,RBI.TaxId,RBI.TaxType,Rbi.TaxRate,Case When RBI.ReciveORPay=@Pay_Dr Then RBI.DocTaxAmount End As DocDebit,Case When RBI.ReciveORPay=@Receive_Cr Then RBI.DocTaxAmount End As DocCredit,
								Case When RBI.ReciveORPay=@Pay_Dr Then Round(RBI.DocTaxAmount * R.ExchangeRate,2) End As BaseDebit,Case When RBI.ReciveORPay=@Receive_Cr Then Round(RBI.DocTaxAmount * R.ExchangeRate,2) End As BaseCredit,
								0.00 As DocDebitTotal,0.00 As DocCreditTotal,0.00 As BaseDebitTotal,0.00 As BaseCreditTotal,R.Id As DocumentId,RBI.Id As DocumentDetailId,@GUIDZero,
								R.BaseCurrency,R.ExchangeRate,R.GSTExCurrency,R.GSTExchangeRate,@DocType,@DocSubType,ServiceCompanyId,DocNo,1 As IsTax,
								EntityId,@MasterSystemRefNo,@BankChargesCurrency,DocDate,DocDate,@TaxRecCount As RecOrder
							From Bean.Receipt(Nolock) As R
							Inner Join bean.ReceiptBalancingItem(Nolock) As RBI On RBI.ReceiptId=R.Id
							Where R.Id=@SourceId And Rbi.Id=@RecieptBalId
						End
						Set @RecCount=@RecCount+1
					End
					/*OutStanding Records*/
					IF Exists (Select Id From Bean.ReceiptDetail(Nolock) Where ReceiptId=@SourceId And ReceiptAmount<>0)
					Begin
						--Reciept Detail & Exchange Gain/Loss
						Insert Into @RecieptDtl 
						Select RD.Id From Bean.ReceiptDetail(Nolock) As RD
						Inner Join Bean.Receipt(Nolock) As R On RD.ReceiptId=R.Id 
						Where R.Id=@SourceId And RD.ReceiptAmount<>0 And RD.DocumentType Not In (@CreditNoteDocument,@CreditMemoDocument) Order By RD.RecOrder
						Set @Count=(Select Count(*) From @RecieptDtl)
						Set @RecCount=1
						While @Count>=@RecCount
						Begin
							Set @RecieptDtlId=(Select RecieptDtlId From @RecieptDtl Where S_No=@RecCount)
							Set @DocumentId=(Select DocumentId From Bean.ReceiptDetail(Nolock) Where Id=@RecieptDtlId)
							Set @OffSetDocumentType=(Select DocumentType From Bean.ReceiptDetail(Nolock) Where Id=@RecieptDtlId)
							Set @IsRoundingAmount=0
							IF Exists (Select DocumentType From Bean.ReceiptDetail(Nolock) Where Id=@RecieptDtlId And DocumentType=@InvoiceDocument)
							Begin
								Set @ExchangeRate=(Select ExchangeRate From Bean.Invoice(Nolock) Where Id=@DocumentId)
								IF Exists(Select Id From Bean.Invoice(Nolock) Where Id=@DocumentId And DocumentState In (@FullyApplied,@Fullypaid))
								Begin
									Set @IsRoundingAmount=1
								End
							End
							Else IF Exists (Select DocumentType From Bean.ReceiptDetail(Nolock) Where Id=@RecieptDtlId And DocumentType=@DebitNoteDocument)
							Begin
								Set @ExchangeRate=(Select ExchangeRate From Bean.DebitNote(Nolock) Where Id=@DocumentId)
								IF Exists(Select Id From Bean.DebitNote(Nolock) Where Id=@DocumentId And DocumentState In (@FullyApplied,@Fullypaid))
								Begin
									Set @IsRoundingAmount=1
								End
							End
							Else IF Exists (Select DocumentType From Bean.ReceiptDetail(Nolock) Where Id=@RecieptDtlId And DocumentType=@BillDocument)
							Begin
								Set @ExchangeRate=(Select ExchangeRate From Bean.Bill(Nolock) Where Id=@DocumentId)
								IF Exists(Select Id From Bean.Bill(Nolock) Where Id=@DocumentId And DocumentState In (@FullyApplied,@Fullypaid))
								Begin
									Set @IsRoundingAmount=1
								End
							End
							--Getting COAID By Checking Nature
							IF Exists (Select ID From Bean.ReceiptDetail(Nolock) Where id=@RecieptDtlId And Nature=@NatureTrade And DocumentType<>@BillDocument)
							Begin
								Set @COAID=(Select Id From Bean.ChartOfAccount(Nolock) Where CompanyId=@CompanyId And Name=@COATradeReceivables)
							End
							Else IF Exists (Select ID From Bean.ReceiptDetail(Nolock) Where id=@RecieptDtlId And Nature=@NatureOthers And DocumentType<>@BillDocument)
							Begin
								Set @COAID=(Select Id From Bean.ChartOfAccount(Nolock) Where CompanyId=@CompanyId And Name=@COAotherReceivables)
							End
							Else IF Exists (Select ID From Bean.ReceiptDetail(Nolock) Where id=@RecieptDtlId And Nature=@NatureTrade And DocumentType=@BillDocument)
							Begin
								Set @COAID=(Select Id From Bean.ChartOfAccount(Nolock) Where CompanyId=@CompanyId And Name=@COATradePayables)
							End
							Else IF Exists (Select ID From Bean.ReceiptDetail(Nolock) Where id=@RecieptDtlId And Nature=@NatureOthers And DocumentType=@BillDocument)
							Begin
								Set @COAID=(Select Id From Bean.ChartOfAccount(Nolock) Where CompanyId=@CompanyId And Name=@COAOtherPayables)
							End
							-- Checking Document Type Bill Or Not
							Set @RecOrder=@RecOrder+1
							IF Coalesce(@OffSetDocumentType,'NULL')=@BillDocument
							Begin
								Insert Into Bean.JournalDetail (Id,JournalId,COAId,AccountDescription, DocDebit,DocCredit,
														 BaseDebit,BaseCredit,
														 DocDebitTotal,DocCreditTotal,BaseDebitTotal,BaseCreditTotal,DocumentId,DocumentDetailId,ItemId,BaseCurrency,ExchangeRate, DocType,DocSubType,ServiceCompanyId,DocNo,Nature,OffsetDocument,IsTax,
														EntityId, SystemRefNo, DocCurrency,DocDate, PostingDate,RecOrder 
														)
								Select NEWID(),@MasterJournalId,@COAID,R.Remarks,Rd.ReceiptAmount As DocDebit,Null As DocCredit,
									Round(Rd.ReceiptAmount * @ExchangeRate,2)- Isnull(@DocAmount,0) As BaseDebit,Null As BaseCredit,
									0.00 As DocDebitTotal,0.00 As DocCreditTotal,0.00 As BaseDebitTotal,0.00 As BaseCreditTotal,R.Id As DocumentId,RD.Id As DocumentDetailId,@GUIDZero,
									R.BaseCurrency,@ExchangeRate,@DocType,@DocSubType,@MasterServComp As ServiceCompanyId,R.DocNo,RD.Nature,RD.DocumentNo,0 As IsTax,
									R.EntityId,@MasterSystemRefNo,@BankChargesCurrency,R.DocDate,R.DocDate,@RecOrder As RecOrder
								From Bean.Receipt(Nolock) As R
								Inner Join bean.ReceiptDetail(Nolock) As RD On RD.ReceiptId=R.Id
								Where R.Id=@SourceId And RD.Id=@RecieptDtlId
								
								-- ExchangeGainOrLossRealised Records
								IF @MainExchangeRate-@ExchangeRate<>0
								Begin
									Set @RecOrder=@RecOrder+1
									Insert Into Bean.JournalDetail (Id,JournalId,COAId,AccountDescription, DocDebit,DocCredit,
																	 BaseDebit,BaseCredit,
																	 DocDebitTotal,DocCreditTotal,BaseDebitTotal,BaseCreditTotal,DocumentId,DocumentDetailId,ItemId,BaseCurrency,ExchangeRate, DocType,DocSubType,ServiceCompanyId,DocNo,Nature,OffsetDocument,IsTax,
																	EntityId, SystemRefNo, DocCurrency,DocDate, PostingDate,RecOrder 
																	)
									Select NEWID(),@MasterJournalId,@ExchangeGainOrLossCOAID,R.Remarks,Null As DocDebit,Null As DocCredit,
										Case When (@MainExchangeRate-@ExchangeRate)>0 Then ABS(Round((@MainExchangeRate-@ExchangeRate) * RD.ReceiptAmount,2)) End As BaseDebit,Case When (@MainExchangeRate-@ExchangeRate)<0 Then ABS(Round((@MainExchangeRate-@ExchangeRate) * RD.ReceiptAmount,2)) End As BaseCredit,
										0.00 As DocDebitTotal,0.00 As DocCreditTotal,0.00 As BaseDebitTotal,0.00 As BaseCreditTotal,R.Id As DocumentId,RD.Id As DocumentDetailId,@GUIDZero,
										R.BaseCurrency,r.ExchangeRate,@DocType,@DocSubType,@MasterServComp As ServiceCompanyId,R.DocNo,RD.Nature,RD.DocumentNo,0 As IsTax,
										EntityId,@MasterSystemRefNo,@DocCurrency,DocDate,DocDate,@RecOrder As RecOrder
									From Bean.Receipt(Nolock) As R
									Inner Join bean.ReceiptDetail(Nolock) As RD On RD.ReceiptId=R.Id
									Where R.Id=@SourceId And RD.Id=@RecieptDtlId
								End
							End
							Else
							Begin
								Insert Into Bean.JournalDetail (Id,JournalId,COAId,AccountDescription, DocDebit,DocCredit,
														 BaseDebit,BaseCredit,
														 DocDebitTotal,DocCreditTotal,BaseDebitTotal,BaseCreditTotal,DocumentId,DocumentDetailId,ItemId,BaseCurrency,ExchangeRate, DocType,DocSubType,ServiceCompanyId,DocNo,Nature,OffsetDocument,IsTax,
														EntityId, SystemRefNo, DocCurrency,DocDate, PostingDate,RecOrder 
														)
								Select NEWID(),@MasterJournalId,@COAID,R.Remarks,Null As DocDebit,Rd.ReceiptAmount As DocCredit,
									Null As BaseDebit,Round(Rd.ReceiptAmount * @ExchangeRate,2)- Isnull(@DocAmount,0) As BaseCredit,
									0.00 As DocDebitTotal,0.00 As DocCreditTotal,0.00 As BaseDebitTotal,0.00 As BaseCreditTotal,R.Id As DocumentId,RD.Id As DocumentDetailId,@GUIDZero,
									R.BaseCurrency,@ExchangeRate,@DocType,@DocSubType,@MasterServComp As ServiceCompanyId,R.DocNo,RD.Nature,RD.DocumentNo,0 As IsTax,
									R.EntityId,@MasterSystemRefNo,@DocCurrency,R.DocDate,R.DocDate,@RecOrder As RecOrder
								From Bean.Receipt(Nolock) As R
								Inner Join bean.ReceiptDetail(Nolock) As RD On RD.ReceiptId=R.Id
								Where R.Id=@SourceId And RD.Id=@RecieptDtlId
								-- ExchangeGainOrLossRealised Records
								IF @MainExchangeRate-@ExchangeRate<>0
								Begin
									Set @RecOrder=@RecOrder+1
									Insert Into Bean.JournalDetail (Id,JournalId,COAId,AccountDescription, DocDebit,DocCredit,
																	 BaseDebit,BaseCredit,
																	 DocDebitTotal,DocCreditTotal,BaseDebitTotal,BaseCreditTotal,DocumentId,DocumentDetailId,ItemId,BaseCurrency,ExchangeRate, DocType,DocSubType,ServiceCompanyId,DocNo,Nature,OffsetDocument,IsTax,
																	EntityId, SystemRefNo, DocCurrency,DocDate, PostingDate,RecOrder 
																	)
									Select NEWID(),@MasterJournalId,@ExchangeGainOrLossCOAID,R.Remarks,Null As DocDebit,Null As DocCredit,
										Case When (@MainExchangeRate-@ExchangeRate)<0 Then ABS(Round((@MainExchangeRate-@ExchangeRate) * RD.ReceiptAmount,2)) End As BaseDebit,Case When (@MainExchangeRate-@ExchangeRate)>0 Then ABS(Round((@MainExchangeRate-@ExchangeRate) * RD.ReceiptAmount,2)) End As BaseCredit,
										0.00 As DocDebitTotal,0.00 As DocCreditTotal,0.00 As BaseDebitTotal,0.00 As BaseCreditTotal,R.Id As DocumentId,RD.Id As DocumentDetailId,@GUIDZero,
										R.BaseCurrency,R.ExchangeRate,@DocType,@DocSubType,@MasterServComp As ServiceCompanyId,R.DocNo,RD.Nature,RD.DocumentNo,0 As IsTax,
										EntityId,@MasterSystemRefNo,@DocCurrency,DocDate,DocDate,@RecOrder As RecOrder
									From Bean.Receipt(Nolock) As R
									Inner Join bean.ReceiptDetail(Nolock) As RD On RD.ReceiptId=R.Id
									Where R.Id=@SourceId And RD.Id=@RecieptDtlId
								End
							End
							Set @RecCount=@RecCount+1
						End
						--CreditNote Record
						IF Exists (Select Id From Bean.ReceiptDetail(Nolock) Where ReceiptId=@SourceId And DocumentType=@CreditNoteDocument)
						Begin
							Set @CreditNoteAmount=(Select Sum(ISnull(ReceiptAmount,0)) From Bean.ReceiptDetail(Nolock) Where ReceiptId=@SourceId And DocumentType=@CreditNoteDocument)
							Set @RecOrder=@RecOrder+1
							Insert Into Bean.JournalDetail (Id,JournalId,COAId,AccountDescription, DocDebit,DocCredit,
															 BaseDebit,BaseCredit,
															 DocDebitTotal,DocCreditTotal,BaseDebitTotal,BaseCreditTotal,DocumentId,DocumentDetailId,ItemId,BaseCurrency,ExchangeRate, DocType,DocSubType,ServiceCompanyId,DocNo, IsTax,
															EntityId, SystemRefNo, DocCurrency,DocDate, PostingDate,RecOrder 
															)
							Select NEWID(),@MasterJournalId,@ClearingReceiptsCOAID,R.Remarks,@CreditNoteAmount As DocDebit,Null As DocCredit,
								Round(@CreditNoteAmount * R.ExchangeRate,2) As BaseDebit,Null As BaseCredit,
								0.00 As DocDebitTotal,0.00 As DocCreditTotal,0.00 As BaseDebitTotal,0.00 As BaseCreditTotal,R.Id As DocumentId,R.Id As DocumentDetailId,@GUIDZero,
								R.BaseCurrency,R.ExchangeRate, @DocType,@DocSubType,ServiceCompanyId,DocNo,0 As IsTax,
								EntityId,@MasterSystemRefNo,@DocCurrency,DocDate,DocDate,@RecOrder As RecOrder
							From Bean.Receipt(Nolock) As R
							Where R.Id=@SourceId
						End
						--CreditMemo Record
						IF Exists (Select Id From Bean.ReceiptDetail(Nolock) Where ReceiptId=@SourceId And DocumentType=@CreditMemoDocument)
						Begin
							Set @CreditMemoAmount=(Select Sum(Isnull(ReceiptAmount,0)) From Bean.ReceiptDetail(Nolock) Where ReceiptId=@SourceId And DocumentType=@CreditMemoDocument)
							Set @RecOrder=@RecOrder+1
							Insert Into Bean.JournalDetail (Id,JournalId,COAId,AccountDescription, DocDebit,DocCredit,
															 BaseDebit,BaseCredit,
															 DocDebitTotal,DocCreditTotal,BaseDebitTotal,BaseCreditTotal,DocumentId,DocumentDetailId,ItemId,BaseCurrency,ExchangeRate, DocType,DocSubType,ServiceCompanyId,DocNo, IsTax,
															EntityId, SystemRefNo, DocCurrency,DocDate, PostingDate,RecOrder 
															)
							Select NEWID(),@MasterJournalId,@ClearingReceiptsCOAID,R.Remarks,Null As DocDebit,@CreditMemoAmount As DocCredit,
								Null As BaseDebit,Round(@CreditMemoAmount * R.ExchangeRate,2) As BaseCredit,
								0.00 As DocDebitTotal,0.00 As DocCreditTotal,0.00 As BaseDebitTotal,0.00 As BaseCreditTotal,R.Id As DocumentId,R.Id As DocumentDetailId,@GUIDZero,
								R.BaseCurrency,R.ExchangeRate, @DocType,@DocSubType,ServiceCompanyId,DocNo,0 As IsTax,
								EntityId,@MasterSystemRefNo,@DocCurrency,DocDate,DocDate,@RecOrder As RecOrder
							From Bean.Receipt(Nolock) As R
							Where R.Id=@SourceId
						End
					End
				End
				/* @BaseCurrency=@DocCurrency<>@BankChargesCurrency */
				Else IF @DocCurrency<>@BankChargesCurrency And @BaseCurrency=@DocCurrency
				Begin
					/* Creating Mater record In JournalDetail */
					IF Exists (Select Id From Bean.Receipt(Nolock) Where Id=@SourceId And GrandTotal<>0)
					Begin
						Insert Into Bean.JournalDetail (Id,JournalId,COAId,AccountDescription,AllowDisAllow, DocDebit, BaseDebit, DocDebitTotal,DocCreditTotal,BaseDebitTotal,BaseCreditTotal,DocumentId,DocumentDetailId,ItemId,BaseCurrency,ExchangeRate,GSTExCurrency,GSTExchangeRate,DocType,DocSubType,ServiceCompanyId,DocNo, IsTax,
										EntityId, SystemRefNo, DocCurrency,DocDate, PostingDate,RecOrder )
						Select NEWID(),@MasterJournalId,COAId,Remarks,IsDisAllow,Isnull(BankReceiptAmmount,0) As BankReceiptAmmount,Round(Isnull(BankReceiptAmmount,0) * @SysCalExchangerate,2),0.00 As DocDebitTotal,0.00 As DocCreditTotal,0.00 As BaseDebitTotal,0.00 As BaseCreditTotal,Id As DocumentId,@GUIDZero,@GUIDZero,
								BaseCurrency,@SysCalExchangerate As ExchangeRate,GSTExCurrency,GSTExchangeRate,@DocType,@DocSubType,ServiceCompanyId,DocNo,0 As IsTax,
								EntityId,@MasterSystemRefNo As SystemRefNo,@BankChargesCurrency,DocDate,DocDate,@RecOrder As RecOrder
						From Bean.Receipt(Nolock) Where Id=@SourceId
					End
					Else IF Exists (Select Id From Bean.Receipt(Nolock) Where Id=@SourceId And GrandTotal=0 And BankReceiptAmmount<>0)
					Begin
						Insert Into Bean.JournalDetail (Id,JournalId,COAId,AccountDescription,AllowDisAllow, DocDebit, BaseDebit, DocDebitTotal,DocCreditTotal,BaseDebitTotal,BaseCreditTotal,DocumentId,DocumentDetailId,ItemId,BaseCurrency,ExchangeRate,GSTExCurrency,GSTExchangeRate,DocType,DocSubType,ServiceCompanyId,DocNo, IsTax,
										EntityId, SystemRefNo, DocCurrency,DocDate, PostingDate,RecOrder )
						Select NEWID(),@MasterJournalId,COAId,Remarks,IsDisAllow,Isnull(BankReceiptAmmount,0) As BankReceiptAmmount,Round(Isnull(BankReceiptAmmount,0) * @SysCalExchangerate,2),0.00 As DocDebitTotal,0.00 As DocCreditTotal,0.00 As BaseDebitTotal,0.00 As BaseCreditTotal,Id As DocumentId,@GUIDZero,@GUIDZero,
								BaseCurrency,@SysCalExchangerate As ExchangeRate,GSTExCurrency,GSTExchangeRate,@DocType,@DocSubType,ServiceCompanyId,DocNo,0 As IsTax,
								EntityId,@MasterSystemRefNo As SystemRefNo,@BankChargesCurrency,DocDate,DocDate,@RecOrder As RecOrder
						From Bean.Receipt(Nolock) Where Id=@SourceId
					End
					/* Creating Record in Journaldetail With Bank Charges Amount */
					If Exists(Select Id From Bean.Receipt(Nolock) Where Id=@SourceId And BankCharges Is Not Null)
					Begin
						Set @RecOrder=@RecOrder+1
						Insert Into Bean.JournalDetail (Id,JournalId,COAId,AccountDescription,AllowDisAllow,TaxId,TaxType,TaxRate,DocDebit, BaseDebit, DocDebitTotal,DocCreditTotal,BaseDebitTotal,BaseCreditTotal,DocumentId,DocumentDetailId,ItemId,BaseCurrency,ExchangeRate,GSTExCurrency,GSTExchangeRate,DocType,DocSubType,ServiceCompanyId,DocNo, IsTax,
													EntityId, SystemRefNo, DocCurrency,DocDate, PostingDate,RecOrder,GSTTaxDebit)
						Select NEWID(),@MasterJournalId,@BankCharges_COAId,Remarks,IsDisAllow,@TaxId,@TaxType,@TaxRate,BankCharges,Round(BankCharges * @SysCalExchangerate,2),0.00 As DocDebitTotal,0.00 As DocCreditTotal,0.00 As BaseDebitTotal,0.00 As BaseCreditTotal,Id As DocumentId,Id As DocumentDetailId,@GUIDZero,
							BaseCurrency,@SysCalExchangerate,GSTExCurrency,GSTExchangeRate,@DocType,@DocSubType,ServiceCompanyId,DocNo,0 As IsTax,
							EntityId,@MasterSystemRefNo As SystemRefNo,@BankChargesCurrency,DocDate,DocDate,@RecOrder As RecOrder,
							Case When @TaxId Is Not Null Then Round(BankCharges * Coalesce(GSTexchangerate,@DefaultExchangeRate),2) End As GSTTaxDebit
						From Bean.Receipt(Nolock)
						Where Id=@SourceId
					End
					/* Creating Record in Journaldetail With @ExcesPaidByClientAmt Amount */
					If @ExcesPaidByClientAmt Is NOt Null
					Begin
						Set @RecOrder=@RecOrder+1
						Insert Into Bean.JournalDetail (Id,JournalId,COAId,AccountDescription,AllowDisAllow, DocCredit, BaseCredit, DocDebitTotal,DocCreditTotal,BaseDebitTotal,BaseCreditTotal,DocumentId,DocumentDetailId,ItemId,BaseCurrency,ExchangeRate,GSTExCurrency,GSTExchangeRate,DocType,DocSubType,ServiceCompanyId,DocNo, IsTax,
														EntityId, SystemRefNo, DocCurrency,DocDate, PostingDate,RecOrder )
						Select NEWID(),@MasterJournalId,@ClearingReceiptsCOAID,Remarks,IsDisAllow,ExcessPaidByClientAmmount,Round(ExcessPaidByClientAmmount * @SysCalExchangerate,2),0.00 As DocDebitTotal,0.00 As DocCreditTotal,0.00 As BaseDebitTotal,0.00 As BaseCreditTotal,Id As DocumentId,Id As DocumentDtlId,@GUIDZero,
								BaseCurrency,@SysCalExchangerate As ExchangeRate,BankReceiptAmmountCurrency,ExchangeRate,@DocType,@DocSubType,ServiceCompanyId,DocNo,0 As IsTax,
								EntityId,@MasterSystemRefNo,@BankChargesCurrency,DocDate,DocDate,@RecOrder As RecOrder
						From Bean.Receipt(Nolock)
						Where Id=@SourceId
					End
					/* Creating Balancing Line Items */
					Insert Into @RecieptBalLnItm
					Select RBI.Id From Bean.ReceiptBalancingItem(Nolock) As RBI
					Inner Join bean.Receipt(Nolock) As R On R.Id=RBI.ReceiptId
					Where R.Id=@SourceId Order by RecOrder
					Set @Count=(Select Count(*) From @RecieptBalLnItm)
					Set @RecCount=1
					While @Count>=@RecCount
					Begin
						Select @RecieptBalId=RecieptBalId From @RecieptBalLnItm Where S_no=@RecCount
						Select @TaxId=TaxId,@TaxRate=TaxRate From Bean.ReceiptBalancingItem(Nolock) Where Id=@RecieptBalId
						Set @RecOrder=@RecOrder+1
						Insert Into Bean.JournalDetail (Id,JournalId,COAId,AccountDescription,AllowDisAllow,TaxId,TaxType,TaxRate,DocDebit,DocCredit,
													DocTaxDebit,DocTaxCredit,BaseDebit,BaseCredit,
													BaseTaxDebit,BaseTaxCredit,DocDebitTotal,DocCreditTotal,BaseDebitTotal,BaseCreditTotal,DocumentId,DocumentDetailId,ItemId,BaseCurrency,ExchangeRate,GSTExCurrency,GSTExchangeRate,DocType,DocSubType,ServiceCompanyId,DocNo, IsTax,
													EntityId, SystemRefNo, DocCurrency,DocDate, PostingDate,RecOrder,GSTTaxDebit,GSTTaxCredit,GSTDebit,GSTCredit)
						Select NEWID(),@MasterJournalId,RBi.COAId,R.Remarks,RBI.IsDisAllow,RBI.TaxId,RBI.TaxType,Rbi.TaxRate,
						Case When RBI.ReciveORPay=@Pay_Dr Then RBI.DocAmount End As DocDebit,Case When RBI.ReciveORPay=@Receive_Cr Then RBI.DocAmount End As DocCredit,
							Case When RBI.ReciveORPay=@Pay_Dr Then RBI.DocTaxAmount End As DocTaxDebdit,Case When RBI.ReciveORPay=@Receive_Cr Then RBI.DocTaxAmount End As DocTaxCredit,
							Case When RBI.ReciveORPay=@Pay_Dr Then Round(RBI.DocAmount * @SysCalExchangerate,2) End As BaseDebit,
							Case When RBI.ReciveORPay=@Receive_Cr Then Round(RBI.DocAmount * @SysCalExchangerate,2) End As BaseCredit,
							Case When RBI.ReciveORPay=@Pay_Dr Then Round(RBI.DocTaxAmount * @SysCalExchangerate,2) End As BaseTaxDebdit,
							Case When RBI.ReciveORPay=@Receive_Cr Then Round(RBI.DocTaxAmount * @SysCalExchangerate,2) End As BaseTaxCredit,0.00 As DocDebitTotal,0.00 As DocCreditTotal,0.00 As BaseDebitTotal,0.00 As BaseCreditTotal,R.Id As DocumentId,RBI.Id As DocumentDetailId,@GUIDZero,
							R.BaseCurrency,@SysCalExchangerate As ExchangeRate,R.GSTExCurrency,R.GSTExchangeRate,@DocType,@DocSubType,ServiceCompanyId,DocNo,0 As IsTax,
							EntityId,@MasterSystemRefNo,@BankChargesCurrency,DocDate,DocDate,@RecOrder As RecOrder,
							Case When RBI.ReciveORPay=@Pay_Dr Then Round(RBI.DocAmount * Coalesce(R.GSTExchangeRate,@DefaultExchangeRate),2) End As GSTTaxDebit,
							Case When RBI.ReciveORPay=@Receive_Cr Then Round(RBI.DocAmount * Coalesce(R.GSTExchangeRate,@DefaultExchangeRate),2) End As GSTTaxCredit,
							Case When RBI.ReciveORPay=@Pay_Dr Then Round(RBI.DocTaxAmount * Coalesce(R.GSTExchangeRate,@DefaultExchangeRate),2) End As GSTDebit,
							Case When RBI.ReciveORPay=@Receive_Cr Then Round(RBI.DocTaxAmount * Coalesce(R.GSTExchangeRate,@DefaultExchangeRate),2) End As GSTCredit
						From Bean.Receipt(Nolock) As R
						Inner Join bean.ReceiptBalancingItem(Nolock) As RBI On RBI.ReceiptId=R.Id
						Where R.Id=@SourceId And Rbi.Id=@RecieptBalId
						-- Creating Tax Line Items
						If @GST Is Not Null And @GST=1 And @TaxId Is Not Null And (@TaxRate Is Not Null And @TaxRate<>0)
						Begin
							Set @TaxRecCount=@RecOrder+@Count
							Insert Into Bean.JournalDetail (Id,JournalId,COAId,AccountDescription,AllowDisAllow,TaxId,TaxType,TaxRate,DocDebit,DocCredit,
									 BaseDebit,BaseCredit,
									 DocDebitTotal,DocCreditTotal,BaseDebitTotal,BaseCreditTotal,DocumentId,DocumentDetailId,ItemId,BaseCurrency,ExchangeRate,GSTExCurrency,GSTExchangeRate,DocType,DocSubType,ServiceCompanyId,DocNo, IsTax,
									EntityId, SystemRefNo, DocCurrency,DocDate, PostingDate,RecOrder )
							Select NEWID(),@MasterJournalId,@TaxPayableGST_COAID as COAId,R.Remarks,RBI.IsDisAllow,RBI.TaxId,RBI.TaxType,Rbi.TaxRate,Case When RBI.ReciveORPay=@Pay_Dr Then RBI.DocTaxAmount End As DocDebit,Case When RBI.ReciveORPay=@Receive_Cr Then RBI.DocTaxAmount End As DocCredit,
								Case When RBI.ReciveORPay=@Pay_Dr Then Round(RBI.DocTaxAmount * @SysCalExchangerate,2) End As BaseDebit,Case When RBI.ReciveORPay=@Receive_Cr Then Round(RBI.DocTaxAmount * @SysCalExchangerate,2) End As BaseCredit,
								0.00 As DocDebitTotal,0.00 As DocCreditTotal,0.00 As BaseDebitTotal,0.00 As BaseCreditTotal,R.Id As DocumentId,RBI.Id As DocumentDetailId,@GUIDZero,
								R.BaseCurrency,@SysCalExchangerate As ExchangeRate,R.GSTExCurrency,R.GSTExchangeRate,@DocType,@DocSubType,ServiceCompanyId,DocNo,1 As IsTax,
								EntityId,@MasterSystemRefNo,@BankChargesCurrency,DocDate,DocDate,@TaxRecCount As RecOrder
							From Bean.Receipt(Nolock) As R
							Inner Join bean.ReceiptBalancingItem(Nolock) As RBI On RBI.ReceiptId=R.Id
							Where R.Id=@SourceId And Rbi.Id=@RecieptBalId
						End
						Set @RecCount=@RecCount+1
					End
					/* Outstanding Records*/
					IF Exists (Select Id From Bean.ReceiptDetail(Nolock) Where ReceiptId=@SourceId And ReceiptAmount<>0)
					Begin
						-- Clearing Reciepts Main Journal
						Set @RecOrder=@RecOrder+1
						Set @ClearingRecieptBillAmount=(Select Sum(Isnull(ReceiptAmount,0)) From Bean.ReceiptDetail(Nolock) Where ReceiptId=@SourceId And DocumentType=@BillDocument)
						Set @ClearingRecieptInvOrDNAmount=(Select Sum(Isnull(ReceiptAmount,0)) From Bean.ReceiptDetail(Nolock) Where ReceiptId=@SourceId And DocumentType in(@InvoiceDocument,@DebitNoteDocument))
						IF @ClearingRecieptInvOrDNAmount Is null
						Begin
							Set @ClearingRecieptInvOrDNAmount =Isnull(@ClearingRecieptInvOrDNAmount,0)
						End
						IF @ClearingRecieptBillAmount Is null
						Begin
							Set @ClearingRecieptBillAmount =Isnull(@ClearingRecieptBillAmount,0)
						End
						Set @ClearingRecieptAmount=Abs(@ClearingRecieptInvOrDNAmount-@ClearingRecieptBillAmount)
						IF (@ClearingRecieptInvOrDNAmount IS NOT NUll And @ClearingRecieptInvOrDNAmount<>0) Or(@ClearingRecieptBillAmount IS NOT NULL And @ClearingRecieptBillAmount<>0) 
						Begin
							Insert Into Bean.JournalDetail (Id,JournalId,COAId,AccountDescription, DocDebit,DocCredit,
															 BaseDebit,BaseCredit,
															 DocDebitTotal,DocCreditTotal,BaseDebitTotal,BaseCreditTotal,DocumentId,DocumentDetailId,ItemId,BaseCurrency,ExchangeRate, DocType,DocSubType,ServiceCompanyId,DocNo, IsTax,
															EntityId, SystemRefNo, DocCurrency,DocDate, PostingDate,RecOrder 
															)
							Select NEWID(),@MasterJournalId,@ClearingReceiptsCOAID,R.Remarks,
								Case When (@ClearingRecieptInvOrDNAmount-@ClearingRecieptBillAmount) <0 Then Round((@ClearingRecieptAmount*@DefaultExchangeRate)/@SysCalExchangerate,2) End As DocDebit,
								Case When (@ClearingRecieptInvOrDNAmount-@ClearingRecieptBillAmount) >0 Then Round((@ClearingRecieptAmount*@DefaultExchangeRate)/@SysCalExchangerate,2) End As DocCredit,
								Case When (@ClearingRecieptInvOrDNAmount-@ClearingRecieptBillAmount) <0 Then Round(@ClearingRecieptAmount * @DefaultExchangeRate,2) End As BaseDebit,
								Case When (@ClearingRecieptInvOrDNAmount-@ClearingRecieptBillAmount) >0 Then Round(@ClearingRecieptAmount * @DefaultExchangeRate,2) End As BaseCredit,
								0.00 As DocDebitTotal,0.00 As DocCreditTotal,0.00 As BaseDebitTotal,0.00 As BaseCreditTotal,R.Id As DocumentId,R.Id As DocumentDetailId,@GUIDZero,
								R.BaseCurrency,@SysCalExchangerate As ExchangeRate, @DocType,@DocSubType,ServiceCompanyId,DocNo,0 As IsTax,
								EntityId,@MasterSystemRefNo,@BankChargesCurrency,DocDate,DocDate,@RecOrder As RecOrder
							From Bean.Receipt(Nolock) As R
							Where R.Id=@SourceId
						End
						--CreditNote Record
						IF Exists (Select Id From Bean.ReceiptDetail(Nolock) Where ReceiptId=@SourceId And DocumentType=@CreditNoteDocument)
						Begin
							Set @CreditNoteAmount=(Select Sum(Isnull(ReceiptAmount,0)) From Bean.ReceiptDetail(Nolock) Where ReceiptId=@SourceId And DocumentType=@CreditNoteDocument)
							Set @RecOrder=@RecOrder+1
							Insert Into Bean.JournalDetail (Id,JournalId,COAId,AccountDescription, DocDebit,DocCredit,
															 BaseDebit,BaseCredit,
															 DocDebitTotal,DocCreditTotal,BaseDebitTotal,BaseCreditTotal,DocumentId,DocumentDetailId,ItemId,BaseCurrency,ExchangeRate, DocType,DocSubType,ServiceCompanyId,DocNo, IsTax,
															EntityId, SystemRefNo, DocCurrency,DocDate, PostingDate,RecOrder 
															)
							Select NEWID(),@MasterJournalId,@ClearingReceiptsCOAID,R.Remarks,Round((@CreditNoteAmount * @DefaultExchangeRate)/@SysCalExchangerate,2) As DocDebit,Null As DocCredit,
								Round(@CreditNoteAmount * @DefaultExchangeRate,2) As BaseDebit,Null As BaseCredit,
								0.00 As DocDebitTotal,0.00 As DocCreditTotal,0.00 As BaseDebitTotal,0.00 As BaseCreditTotal,R.Id As DocumentId,R.Id As DocumentDetailId,@GUIDZero,
								R.BaseCurrency,@SysCalExchangerate As ExchangeRate, @DocType,@DocSubType,ServiceCompanyId,DocNo,0 As IsTax,
								EntityId,@MasterSystemRefNo,@BankChargesCurrency,DocDate,DocDate,@RecOrder As RecOrder
							From Bean.Receipt(Nolock) As R
							Where R.Id=@SourceId
						End
						--CreditMemo Record
						IF Exists (Select Id From Bean.ReceiptDetail(Nolock) Where ReceiptId=@SourceId And DocumentType=@CreditMemoDocument)
						Begin
							Set @CreditMemoAmount=(Select Sum(Isnull(ReceiptAmount,0)) From Bean.ReceiptDetail(Nolock) Where ReceiptId=@SourceId And DocumentType=@CreditMemoDocument)
							Set @RecOrder=@RecOrder+1
							Insert Into Bean.JournalDetail (Id,JournalId,COAId,AccountDescription, DocDebit,DocCredit,
															 BaseDebit,BaseCredit,
															 DocDebitTotal,DocCreditTotal,BaseDebitTotal,BaseCreditTotal,DocumentId,DocumentDetailId,ItemId,BaseCurrency,ExchangeRate, DocType,DocSubType,ServiceCompanyId,DocNo, IsTax,
															EntityId, SystemRefNo, DocCurrency,DocDate, PostingDate,RecOrder 
															)
							Select NEWID(),@MasterJournalId,@ClearingReceiptsCOAID,R.Remarks,Null As DocDebit,Round((@CreditMemoAmount * @DefaultExchangeRate)/@SysCalExchangerate,2) As DocCredit,
								Null As BaseDebit,Round(@CreditMemoAmount * @DefaultExchangeRate,2) As BaseCredit,
								0.00 As DocDebitTotal,0.00 As DocCreditTotal,0.00 As BaseDebitTotal,0.00 As BaseCreditTotal,R.Id As DocumentId,R.Id As DocumentDetailId,@GUIDZero,
								R.BaseCurrency,@SysCalExchangerate As ExchangeRate, @DocType,@DocSubType,ServiceCompanyId,DocNo,0 As IsTax,
								EntityId,@MasterSystemRefNo,@BankChargesCurrency,DocDate,DocDate,@RecOrder As RecOrder
							From Bean.Receipt(Nolock) As R
							Where R.Id=@SourceId
						End
						--Creating Journal For Master Record With DifferentCurrency
						Set @JournalId=NEWID()
						Set @RecOrder=1
						Set @SysRefNum_Incr=@SysRefNum_Incr+1
						Set @SystemRefNo=CONCAT(@DocNo,'-JV',@SysRefNum_Incr)
						Insert Into Bean.Journal (Id,CompanyId,DocDate,DocType,DocSubType,DocNo,ServiceCompanyId,SystemReferenceNo,IsNoSupportingDocs,NoSupportingDocument,DocCurrency,ExchangeRate,ExCurrency,ExDurationFrom,GSTExchangeRate,GSTExCurrency,GSTTotalAmount,DocumentState,IsNoSupportingDocument,IsGstSettings,IsMultiCurrency,IsAllowableNonAllowable,IsGSTCurrencyRateChanged,Remarks,UserCreated,CreatedDate,Status,DocumentDescription,CreationType,GrandDocDebitTotal,GrandDocCreditTotal,GrandBaseDebitTotal,
													GrandBaseCreditTotal,EntityId,EntityType,PostingDate,COAId,ModeOfReceipt,BankReceiptAmmount,ExcessPaidByClientAmmount,BalancingItemReciveCRAmount,  BalancingItemPayDRAmount,ReceiptApplicationAmmount,DocumentId, BankClearingDate ,IsBalancing,ISAllowDisAllow, IsShow, ActualSysRefNo 
													,IsSegmentReporting,TransferRefNo
												 )
						Select @JournalId,@CompanyId,DocDate,@DocType,@DocSubType,DocNo,ServiceCompanyId,DocNo As SystemRefNo,IsNoSupportingDocument,NoSupportingDocs,DocCurrency,ExchangeRate,ExCurrency,ExDurationFrom,GSTExchangeRate,GSTExCurrency,Isnull(GSTTotalAmount,0),DocumentState,NoSupportingDocs,IsGstSettings,IsMultiCurrency,IsAllowableDisallowable,IsGSTCurrencyRateChanged,Remarks,@UserCreated,@CreatedDate,Status,Remarks As DocDescription,@UserCreated,GrandTotal,0.00 As GrandDocCreditTotal,GrandTotal * Round(ExchangeRate,2) As GrandBaseDebitTotal,
								0.00 As GrandBaseCreditTotal,EntityId,EntityType,DocDate As PostingDate,COAId,ModeOfReceipt,0.00 As BankReceiptAmmount,0.00 As ExcessPaidByClientAmmount,0.00 As BalancingItemReciveCRAmount,0.00 As BalancingItemPayDRAmount,0.00 As ReceiptApplicationAmmount,Id As DocumentId,BankClearingDate,0 As IsBalancing,IsDisAllow,1 As IsShow,DocNo As ActualSysRefNo,0 As IsSegmentReporting,ReceiptRefNo
						From Bean.Receipt(Nolock) Where CompanyId=@CompanyId And Id=@SourceId
						Insert Into Bean.JournalDetail (Id,JournalId,COAId,AccountDescription, DocDebit,DocCredit,
														 BaseDebit,BaseCredit,
														 DocDebitTotal,DocCreditTotal,BaseDebitTotal,BaseCreditTotal,DocumentId,DocumentDetailId,ItemId,BaseCurrency,ExchangeRate, DocType,DocSubType,ServiceCompanyId,DocNo, IsTax,
														EntityId, SystemRefNo, DocCurrency,DocDate, PostingDate,RecOrder 
														)
						Select NEWID(),@JournalId,@ClearingReceiptsCOAID,R.Remarks,
							Case When (@ClearingRecieptInvOrDNAmount-@ClearingRecieptBillAmount)>0 Then @ClearingRecieptAmount End As DocDebit,
							Case When (@ClearingRecieptInvOrDNAmount-@ClearingRecieptBillAmount)<0 Then @ClearingRecieptAmount End As DocCredit,
							Case When (@ClearingRecieptInvOrDNAmount-@ClearingRecieptBillAmount)>0 Then Round(@ClearingRecieptAmount*@DefaultExchangeRate,2) End As BaseDebit,
							Case When (@ClearingRecieptInvOrDNAmount-@ClearingRecieptBillAmount)<0 Then Round(@ClearingRecieptAmount*@DefaultExchangeRate,2) End As BaseCredit,
							0.00 As DocDebitTotal,0.00 As DocCreditTotal,0.00 As BaseDebitTotal,0.00 As BaseCreditTotal,R.Id As DocumentId,R.Id As DocumentDetailId,@GUIDZero,
							R.BaseCurrency,R.ExchangeRate, @DocType,@DocSubType,ServiceCompanyId,DocNo,0 As IsTax,
							EntityId,@SystemRefNo,@DocCurrency,DocDate,DocDate,@RecOrder As RecOrder
						From Bean.Receipt(Nolock) As R
						Where R.Id=@SourceId
						--Reciept Detail & Exchange Gain/Loss
						Insert Into @RecieptDtl 
						Select RD.Id From Bean.ReceiptDetail(Nolock) As RD
						Inner Join Bean.Receipt(Nolock) As R On RD.ReceiptId=R.Id 
						Where R.Id=@SourceId And RD.ReceiptAmount<>0 And RD.DocumentType Not In (@CreditNoteDocument,@CreditMemoDocument) Order By RD.RecOrder
						Set @Count=(Select Count(*) From @RecieptDtl)
						Set @RecCount=1
						While @Count>=@RecCount
						Begin
							Set @RecOrder=@RecOrder+1
							Set @RecieptDtlId=(Select RecieptDtlId From @RecieptDtl Where S_No=@RecCount)
							Set @DocumentId=(Select DocumentId From Bean.ReceiptDetail(Nolock) Where Id=@RecieptDtlId)
							Set @OffSetDocumentType=(Select DocumentType From Bean.ReceiptDetail(Nolock) Where Id=@RecieptDtlId)
							--Getting COAID By Checking Nature
							IF Exists (Select ID From Bean.ReceiptDetail(Nolock) Where id=@RecieptDtlId And Nature=@NatureTrade And DocumentType<>@BillDocument)
							Begin
								Set @COAID=(Select Id From Bean.ChartOfAccount(Nolock) Where CompanyId=@CompanyId And Name=@COATradeReceivables)
							End
							Else IF Exists (Select ID From Bean.ReceiptDetail(Nolock) Where id=@RecieptDtlId And Nature=@NatureOthers And DocumentType<>@BillDocument)
							Begin
								Set @COAID=(Select Id From Bean.ChartOfAccount(Nolock) Where CompanyId=@CompanyId And Name=@COAotherReceivables)
							End
							Else IF Exists (Select ID From Bean.ReceiptDetail(Nolock) Where id=@RecieptDtlId And Nature=@NatureTrade And DocumentType=@BillDocument)
							Begin
								Set @COAID=(Select Id From Bean.ChartOfAccount(Nolock) Where CompanyId=@CompanyId And Name=@COATradePayables)
								IF Exists(Select Id From Bean.Bill(Nolock) Where Id=@DocumentId And DocumentState In (@FullyApplied,@Fullypaid))
								Begin
									Set @IsRoundingAmount=1
								End
							End
							Else IF Exists (Select ID From Bean.ReceiptDetail(Nolock) Where id=@RecieptDtlId And Nature=@NatureOthers And DocumentType=@BillDocument)
							Begin
								Set @COAID=(Select Id From Bean.ChartOfAccount(Nolock) Where CompanyId=@CompanyId And Name=@COAOtherPayables)
								IF Exists(Select Id From Bean.Bill(Nolock) Where Id=@DocumentId And DocumentState In (@FullyApplied,@Fullypaid))
								Begin
									Set @IsRoundingAmount=1
								End
							End
							IF Exists (Select ID From Bean.ReceiptDetail(Nolock) Where id=@RecieptDtlId And DocumentType=@InvoiceDocument)
							Begin
								IF Exists(Select Id From Bean.Invoice(Nolock) Where Id=@DocumentId And DocumentState In (@FullyApplied,@Fullypaid))
								Begin
									Set @IsRoundingAmount=1
								End
							End
							Else IF Exists (Select ID From Bean.ReceiptDetail(Nolock) Where id=@RecieptDtlId And DocumentType=@DebitNoteDocument)
							Begin
								IF Exists(Select Id From Bean.DebitNote(Nolock) Where Id=@DocumentId And DocumentState In (@FullyApplied,@Fullypaid))
								Begin
									Set @IsRoundingAmount=1
								End
							End
							
							IF @IsRoundingAmount=1 And Exists (Select Amount From @RoundingAmountDetails Where DocumentId=@DocumentId And Amount Is Not Null And Amount<>'')
							Begin
								Set @DocAmount=(Select Amount From @RoundingAmountDetails Where DocumentId=@DocumentId)
							End
							Else
							Begin
								Set @DocAmount=0
							End
							-- Checking Document Type Bill Or Not
							IF Coalesce(@OffSetDocumentType,'NULL')=@BillDocument
							Begin
								Insert Into Bean.JournalDetail (Id,JournalId,COAId,AccountDescription, DocDebit,DocCredit,
														 BaseDebit,BaseCredit,
														 DocDebitTotal,DocCreditTotal,BaseDebitTotal,BaseCreditTotal,DocumentId,DocumentDetailId,ItemId,BaseCurrency,ExchangeRate, DocType,DocSubType,ServiceCompanyId,DocNo,Nature,OffsetDocument,IsTax,
														EntityId, SystemRefNo, DocCurrency,DocDate, PostingDate,RecOrder 
														)
								Select NEWID(),@JournalId,@COAID,R.Remarks,Rd.ReceiptAmount As DocDebit,Null As DocCredit,
									Round(Rd.ReceiptAmount * @DefaultExchangeRate,2)- Isnull(@DocAmount,0) As BaseDebit,Null As BaseCredit,
									0.00 As DocDebitTotal,0.00 As DocCreditTotal,0.00 As BaseDebitTotal,0.00 As BaseCreditTotal,R.Id As DocumentId,RD.Id As DocumentDetailId,@GUIDZero,
									R.BaseCurrency,R.ExchangeRate,@DocType,@DocSubType,RD.ServiceCompanyId,R.DocNo,RD.Nature,RD.DocumentNo,0 As IsTax,
									R.EntityId,@SystemRefNo,@DocCurrency,R.DocDate,R.DocDate,@RecOrder As RecOrder
								From Bean.Receipt(Nolock) As R
								Inner Join bean.ReceiptDetail(Nolock) As RD On RD.ReceiptId=R.Id
								Where R.Id=@SourceId And RD.Id=@RecieptDtlId
							End
							Else
							Begin
								Insert Into Bean.JournalDetail (Id,JournalId,COAId,AccountDescription, DocDebit,DocCredit,
														 BaseDebit,BaseCredit,
														 DocDebitTotal,DocCreditTotal,BaseDebitTotal,BaseCreditTotal,DocumentId,DocumentDetailId,ItemId,BaseCurrency,ExchangeRate, DocType,DocSubType,ServiceCompanyId,DocNo,Nature,OffsetDocument,IsTax,
														EntityId, SystemRefNo, DocCurrency,DocDate, PostingDate,RecOrder 
														)
								Select NEWID(),@JournalId,@COAID,R.Remarks,Null As DocDebit,Rd.ReceiptAmount As DocCredit,
									Null As BaseDebit,Round(Rd.ReceiptAmount * @DefaultExchangeRate,2)- Isnull(@DocAmount,0) As BaseCredit,
									0.00 As DocDebitTotal,0.00 As DocCreditTotal,0.00 As BaseDebitTotal,0.00 As BaseCreditTotal,R.Id As DocumentId,RD.Id As DocumentDetailId,@GUIDZero,
									R.BaseCurrency,R.ExchangeRate,@DocType,@DocSubType,RD.ServiceCompanyId,R.DocNo,RD.Nature,RD.DocumentNo,0 As IsTax,
									R.EntityId,@SystemRefNo,@DocCurrency,R.DocDate,R.DocDate,@RecOrder As RecOrder
								From Bean.Receipt(Nolock) As R
								Inner Join bean.ReceiptDetail(Nolock) As RD On RD.ReceiptId=R.Id
								Where R.Id=@SourceId And RD.Id=@RecieptDtlId
							End
							Set @RecCount=@RecCount+1
						End
					End
				End
				Else IF @DocCurrency<>@BankChargesCurrency And @BaseCurrency<>@DocCurrency
				Begin
					/* Creating Mater record In JournalDetail */
					IF Exists (Select Id From Bean.Receipt(Nolock) Where Id=@SourceId And GrandTotal<>0)
					Begin
						Insert Into Bean.JournalDetail (Id,JournalId,COAId,AccountDescription,AllowDisAllow, DocDebit, BaseDebit, DocDebitTotal,DocCreditTotal,BaseDebitTotal,BaseCreditTotal,DocumentId,DocumentDetailId,ItemId,BaseCurrency,ExchangeRate,GSTExCurrency,GSTExchangeRate,DocType,DocSubType,ServiceCompanyId,DocNo, IsTax,
										EntityId, SystemRefNo, DocCurrency,DocDate, PostingDate,RecOrder )
						Select NEWID(),@MasterJournalId,COAId,Remarks,IsDisAllow,Isnull(BankReceiptAmmount,0) As BankReceiptAmmount,Round(Isnull(BankReceiptAmmount,0) * @DefaultExchangeRate,2),0.00 As DocDebitTotal,0.00 As DocCreditTotal,0.00 As BaseDebitTotal,0.00 As BaseCreditTotal,Id As DocumentId,@GUIDZero,@GUIDZero,
								BaseCurrency,@DefaultExchangeRate As ExchangeRate,GSTExCurrency,GSTExchangeRate,@DocType,@DocSubType,ServiceCompanyId,DocNo,0 As IsTax,
								EntityId,@MasterSystemRefNo As SystemRefNo,@BankChargesCurrency,DocDate,DocDate,@RecOrder As RecOrder
						From Bean.Receipt(Nolock) Where Id=@SourceId
					End
					Else IF Exists (Select Id From Bean.Receipt(Nolock) Where Id=@SourceId And GrandTotal=0 And BankReceiptAmmount<>0)
					Begin
						Insert Into Bean.JournalDetail (Id,JournalId,COAId,AccountDescription,AllowDisAllow, DocDebit, BaseDebit, DocDebitTotal,DocCreditTotal,BaseDebitTotal,BaseCreditTotal,DocumentId,DocumentDetailId,ItemId,BaseCurrency,ExchangeRate,GSTExCurrency,GSTExchangeRate,DocType,DocSubType,ServiceCompanyId,DocNo, IsTax,
										EntityId, SystemRefNo, DocCurrency,DocDate, PostingDate,RecOrder )
						Select NEWID(),@MasterJournalId,COAId,Remarks,IsDisAllow,Isnull(BankReceiptAmmount,0) As BankReceiptAmmount,Round(Isnull(BankReceiptAmmount,0) * @DefaultExchangeRate,2),0.00 As DocDebitTotal,0.00 As DocCreditTotal,0.00 As BaseDebitTotal,0.00 As BaseCreditTotal,Id As DocumentId,@GUIDZero,@GUIDZero,
								BaseCurrency,@DefaultExchangeRate As ExchangeRate,GSTExCurrency,GSTExchangeRate,@DocType,@DocSubType,ServiceCompanyId,DocNo,0 As IsTax,
								EntityId,@MasterSystemRefNo As SystemRefNo,@BankChargesCurrency,DocDate,DocDate,@RecOrder As RecOrder
						From Bean.Receipt(Nolock) Where Id=@SourceId
					End
					/* Creating Record in Journaldetail With Bank Charges Amount */
					If Exists(Select Id From Bean.Receipt(Nolock) Where Id=@SourceId And BankCharges Is Not Null)
					Begin
						Set @RecOrder=@RecOrder+1
						Insert Into Bean.JournalDetail (Id,JournalId,COAId,AccountDescription,AllowDisAllow,TaxId,TaxType,TaxRate,DocDebit, BaseDebit, DocDebitTotal,DocCreditTotal,BaseDebitTotal,BaseCreditTotal,DocumentId,DocumentDetailId,ItemId,BaseCurrency,ExchangeRate,GSTExCurrency,GSTExchangeRate,DocType,DocSubType,ServiceCompanyId,DocNo, IsTax,
													EntityId, SystemRefNo, DocCurrency,DocDate, PostingDate,RecOrder,GSTTaxDebit)
						Select NEWID(),@MasterJournalId,@BankCharges_COAId,Remarks,IsDisAllow,@TaxId,@TaxType,@TaxRate,BankCharges,Round(BankCharges * @DefaultExchangeRate,2),0.00 As DocDebitTotal,0.00 As DocCreditTotal,0.00 As BaseDebitTotal,0.00 As BaseCreditTotal,Id As DocumentId,Id As DocumentDetailId,@GUIDZero,
							BaseCurrency,@DefaultExchangeRate As ExchangeRate,GSTExCurrency,GSTExchangeRate,@DocType,@DocSubType,ServiceCompanyId,DocNo,0 As IsTax,
							EntityId,@MasterSystemRefNo As SystemRefNo,@BankChargesCurrency,DocDate,DocDate,@RecOrder As RecOrder,
							Case When @TaxId Is Not Null Then Round(BankCharges * Coalesce(GSTexchangerate,@DefaultExchangeRate),2) End As GSTTaxDebit
						From Bean.Receipt(Nolock) 
						Where Id=@SourceId
					End
					/* Creating Record in Journaldetail With @ExcesPaidByClientAmt Amount */
					If @ExcesPaidByClientAmt Is NOt Null
					Begin
						Set @RecOrder=@RecOrder+1
						Insert Into Bean.JournalDetail (Id,JournalId,COAId,AccountDescription,AllowDisAllow, DocCredit, BaseCredit, DocDebitTotal,DocCreditTotal,BaseDebitTotal,BaseCreditTotal,DocumentId,DocumentDetailId,ItemId,BaseCurrency,ExchangeRate,GSTExCurrency,GSTExchangeRate,DocType,DocSubType,ServiceCompanyId,DocNo, IsTax,
														EntityId, SystemRefNo, DocCurrency,DocDate, PostingDate,RecOrder )
						Select NEWID(),@MasterJournalId,@ClearingReceiptsCOAID,Remarks,IsDisAllow,ExcessPaidByClientAmmount,Round(ExcessPaidByClientAmmount * @DefaultExchangeRate,2),0.00 As DocDebitTotal,0.00 As DocCreditTotal,0.00 As BaseDebitTotal,0.00 As BaseCreditTotal,Id As DocumentId,Id As DocumentDtlId,@GUIDZero,
								BaseCurrency,@DefaultExchangeRate As ExchangeRate,BankReceiptAmmountCurrency,ExchangeRate,@DocType,@DocSubType,ServiceCompanyId,DocNo,0 As IsTax,
								EntityId,@MasterSystemRefNo,@BankChargesCurrency,DocDate,DocDate,@RecOrder As RecOrder
						From Bean.Receipt(Nolock)
						Where Id=@SourceId
					End
					/* Creating Balancing Line Items */
					Insert Into @RecieptBalLnItm
					Select RBI.Id From Bean.ReceiptBalancingItem(Nolock) As RBI
					Inner Join bean.Receipt(Nolock) As R On R.Id=RBI.ReceiptId
					Where R.Id=@SourceId Order by RecOrder
					Set @Count=(Select Count(*) From @RecieptBalLnItm)
					Set @RecCount=1
					While @Count>=@RecCount
					Begin
						Select @RecieptBalId=RecieptBalId From @RecieptBalLnItm Where S_no=@RecCount
						Select @TaxId=TaxId,@TaxRate=TaxRate From Bean.ReceiptBalancingItem(Nolock) Where Id=@RecieptBalId
						Set @RecOrder=@RecOrder+1
						Insert Into Bean.JournalDetail (Id,JournalId,COAId,AccountDescription,AllowDisAllow,TaxId,TaxType,TaxRate,DocDebit,DocCredit,
													DocTaxDebit,DocTaxCredit,BaseDebit,BaseCredit,
													BaseTaxDebit,BaseTaxCredit,DocDebitTotal,DocCreditTotal,BaseDebitTotal,BaseCreditTotal,DocumentId,DocumentDetailId,ItemId,BaseCurrency,ExchangeRate,GSTExCurrency,GSTExchangeRate,DocType,DocSubType,ServiceCompanyId,DocNo, IsTax,
													EntityId, SystemRefNo, DocCurrency,DocDate, PostingDate,RecOrder,GSTTaxDebit,GSTTaxCredit,GSTDebit,GSTCredit)
						Select NEWID(),@MasterJournalId,RBi.COAId,R.Remarks,RBI.IsDisAllow,RBI.TaxId,RBI.TaxType,Rbi.TaxRate,Case When RBI.ReciveORPay=@Pay_Dr Then RBI.DocAmount End As DocDebit,Case When RBI.ReciveORPay=@Receive_Cr Then RBI.DocAmount End As DocCredit,
							Case When RBI.ReciveORPay=@Pay_Dr Then RBI.DocTaxAmount End As DocTaxDebdit,Case When RBI.ReciveORPay=@Receive_Cr Then RBI.DocTaxAmount End As DocTaxCredit,Case When RBI.ReciveORPay=@Pay_Dr Then Round(RBI.DocAmount * @DefaultExchangeRate,2) End As BaseDebit,Case When RBI.ReciveORPay=@Receive_Cr Then Round(RBI.DocAmount * @DefaultExchangeRate,2) End As BaseCredit,
							Case When RBI.ReciveORPay=@Pay_Dr Then RBI.DocTaxAmount * Round(@DefaultExchangeRate,2) End As BaseTaxDebdit,Case When RBI.ReciveORPay=@Receive_Cr Then RBI.DocTaxAmount * Round(@DefaultExchangeRate,2) End As BaseTaxCredit,0.00 As DocDebitTotal,0.00 As DocCreditTotal,0.00 As BaseDebitTotal,0.00 As BaseCreditTotal,R.Id As DocumentId,RBI.Id As DocumentDetailId,@GUIDZero,
							R.BaseCurrency,@DefaultExchangeRate As ExchangeRate,R.GSTExCurrency,R.GSTExchangeRate,@DocType,@DocSubType,ServiceCompanyId,DocNo,0 As IsTax,
							EntityId,@MasterSystemRefNo,@BankChargesCurrency,DocDate,DocDate,@RecOrder As RecOrder,
							Case When RBI.ReciveORPay=@Pay_Dr Then Round(RBI.DocAmount * Coalesce(R.GSTExchangeRate,@DefaultExchangeRate),2) End As GSTTaxDebit,
							Case When RBI.ReciveORPay=@Receive_Cr Then Round(RBI.DocAmount * Coalesce(R.GSTExchangeRate,@DefaultExchangeRate),2) End As GSTTaxCredit,
							Case When RBI.ReciveORPay=@Pay_Dr Then Round(RBI.DocTaxAmount * Coalesce(R.GSTExchangeRate,@DefaultExchangeRate),2) End As GSTDebit,
							Case When RBI.ReciveORPay=@Receive_Cr Then Round(RBI.DocTaxAmount * Coalesce(R.GSTExchangeRate,@DefaultExchangeRate),2) End As GSTCredit
						From Bean.Receipt(Nolock) As R
						Inner Join bean.ReceiptBalancingItem(Nolock) As RBI On RBI.ReceiptId=R.Id
						Where R.Id=@SourceId And Rbi.Id=@RecieptBalId
						-- Creating Tax Line Items
						If @GST Is Not Null And @GST=1 And @TaxId Is Not Null And (@TaxRate Is Not Null And @TaxRate<>0)
						Begin
							Set @TaxRecCount=@RecOrder+@Count
							Insert Into Bean.JournalDetail (Id,JournalId,COAId,AccountDescription,AllowDisAllow,TaxId,TaxType,TaxRate,DocDebit,DocCredit,
									 BaseDebit,BaseCredit,
									 DocDebitTotal,DocCreditTotal,BaseDebitTotal,BaseCreditTotal,DocumentId,DocumentDetailId,ItemId,BaseCurrency,ExchangeRate,GSTExCurrency,GSTExchangeRate,DocType,DocSubType,ServiceCompanyId,DocNo, IsTax,
									EntityId, SystemRefNo, DocCurrency,DocDate, PostingDate,RecOrder )
							Select NEWID(),@MasterJournalId,@TaxPayableGST_COAID as COAId,R.Remarks,RBI.IsDisAllow,RBI.TaxId,RBI.TaxType,Rbi.TaxRate,Case When RBI.ReciveORPay=@Pay_Dr Then RBI.DocTaxAmount End As DocDebit,Case When RBI.ReciveORPay=@Receive_Cr Then RBI.DocTaxAmount End As DocCredit,
								Case When RBI.ReciveORPay=@Pay_Dr Then RBI.DocTaxAmount * Round(@DefaultExchangeRate,2) End As BaseDebit,Case When RBI.ReciveORPay=@Receive_Cr Then RBI.DocTaxAmount * Round(@DefaultExchangeRate,2) End As BaseCredit,
								0.00 As DocDebitTotal,0.00 As DocCreditTotal,0.00 As BaseDebitTotal,0.00 As BaseCreditTotal,R.Id As DocumentId,RBI.Id As DocumentDetailId,@GUIDZero,
								R.BaseCurrency,@DefaultExchangeRate As ExchangeRate,R.GSTExCurrency,R.GSTExchangeRate,@DocType,@DocSubType,ServiceCompanyId,DocNo,1 As IsTax,
								EntityId,@MasterSystemRefNo,@BankChargesCurrency,DocDate,DocDate,@TaxRecCount As RecOrder
							From Bean.Receipt(Nolock) As R
							Inner Join bean.ReceiptBalancingItem(Nolock) As RBI On RBI.ReceiptId=R.Id
							Where R.Id=@SourceId And Rbi.Id=@RecieptBalId
						End
						Set @RecCount=@RecCount+1
					End
					IF Exists (Select Id From Bean.ReceiptDetail(Nolock) Where ReceiptId=@SourceId And ReceiptAmount<>0)
					Begin
						Set @RecOrder=@RecOrder+1
						Set @SysCalExchangerate=Coalesce(@SysCalExchangerate,@MainExchangeRate)
						Set @ClearingRecieptBillAmount=(Select Sum(Isnull(ReceiptAmount,0)) From Bean.ReceiptDetail(Nolock) Where ReceiptId=@SourceId And DocumentType=@BillDocument)
						Set @ClearingRecieptInvOrDNAmount=(Select Sum(Isnull(ReceiptAmount,0)) From Bean.ReceiptDetail(Nolock) Where ReceiptId=@SourceId And DocumentType In (@InvoiceDocument,@DebitNoteDocument))
						IF @ClearingRecieptInvOrDNAmount Is null
						Begin
							Set @ClearingRecieptInvOrDNAmount =Isnull(@ClearingRecieptInvOrDNAmount,0)
						End
						IF @ClearingRecieptBillAmount Is null
						Begin
							Set @ClearingRecieptBillAmount =Isnull(@ClearingRecieptBillAmount,0)
						End
						Set @ClearingRecieptAmount=ABS(@ClearingRecieptInvOrDNAmount-@ClearingRecieptBillAmount)
						IF (@ClearingRecieptInvOrDNAmount Is NOT Null And @ClearingRecieptInvOrDNAmount<>0) Or (@ClearingRecieptBillAmount Is Not Null And @ClearingRecieptBillAmount<>0)
						Begin
							Insert Into Bean.JournalDetail (Id,JournalId,COAId,AccountDescription, DocDebit,DocCredit,
															 BaseDebit,BaseCredit,
															 DocDebitTotal,DocCreditTotal,BaseDebitTotal,BaseCreditTotal,DocumentId,DocumentDetailId,ItemId,BaseCurrency,ExchangeRate, DocType,DocSubType,ServiceCompanyId,DocNo, IsTax,
															EntityId, SystemRefNo, DocCurrency,DocDate, PostingDate,RecOrder 
															)
							Select NEWID(),@MasterJournalId,@ClearingReceiptsCOAID,R.Remarks,
								Case When (@ClearingRecieptInvOrDNAmount-@ClearingRecieptBillAmount)<0 Then Round(@ClearingRecieptAmount * @SysCalExchangerate,2) End As DocDebit,
								Case When (@ClearingRecieptInvOrDNAmount-@ClearingRecieptBillAmount)>0 Then Round(@ClearingRecieptAmount * @SysCalExchangerate,2) End As DocCredit,
								Case When (@ClearingRecieptInvOrDNAmount-@ClearingRecieptBillAmount)<0 Then Round((@ClearingRecieptAmount * @SysCalExchangerate) * @DefaultExchangeRate,2) End As BaseDebit,
								Case When (@ClearingRecieptInvOrDNAmount-@ClearingRecieptBillAmount)>0 Then Round((@ClearingRecieptAmount * @SysCalExchangerate) * @DefaultExchangeRate,2) End As BaseCredit,
								0.00 As DocDebitTotal,0.00 As DocCreditTotal,0.00 As BaseDebitTotal,0.00 As BaseCreditTotal,R.Id As DocumentId,R.Id As DocumentDetailId,@GUIDZero,
								R.BaseCurrency,@DefaultExchangeRate As ExchangeRate, @DocType,@DocSubType,ServiceCompanyId,DocNo,0 As IsTax,
								EntityId,@MasterSystemRefNo,@BankChargesCurrency,DocDate,DocDate,@RecOrder As RecOrder
							From Bean.Receipt(Nolock) As R
							Where R.Id=@SourceId
						End
						--CreditNote Record
						IF Exists (Select Id From Bean.ReceiptDetail(Nolock) Where ReceiptId=@SourceId And DocumentType=@CreditNoteDocument)
						Begin
							Set @CreditNoteAmount=(Select Sum(Isnull(ReceiptAmount,0)) From Bean.ReceiptDetail(Nolock) Where ReceiptId=@SourceId And DocumentType=@CreditNoteDocument)
							Set @RecOrder=@RecOrder+1
							Insert Into Bean.JournalDetail (Id,JournalId,COAId,AccountDescription, DocDebit,DocCredit,
															 BaseDebit,BaseCredit,
															 DocDebitTotal,DocCreditTotal,BaseDebitTotal,BaseCreditTotal,DocumentId,DocumentDetailId,ItemId,BaseCurrency,ExchangeRate, DocType,DocSubType,ServiceCompanyId,DocNo, IsTax,
															EntityId, SystemRefNo, DocCurrency,DocDate, PostingDate,RecOrder 
															)
							Select NEWID(),@MasterJournalId,@ClearingReceiptsCOAID,R.Remarks,Round(@CreditNoteAmount * @SysCalExchangerate,2) As DocDebit,Null As DocCredit,
								Round((@CreditNoteAmount * @SysCalExchangerate) * @DefaultExchangeRate,2) As BaseDebit,Null As BaseCredit,
								0.00 As DocDebitTotal,0.00 As DocCreditTotal,0.00 As BaseDebitTotal,0.00 As BaseCreditTotal,R.Id As DocumentId,R.Id As DocumentDetailId,@GUIDZero,
								R.BaseCurrency,@DefaultExchangeRate As ExchangeRate, @DocType,@DocSubType,ServiceCompanyId,DocNo,0 As IsTax,
								EntityId,@MasterSystemRefNo,@BankChargesCurrency,DocDate,DocDate,@RecOrder As RecOrder
							From Bean.Receipt(Nolock) As R
							Where R.Id=@SourceId
						End
						--CreditMemo Record
						IF Exists (Select Id From Bean.ReceiptDetail(Nolock) Where ReceiptId=@SourceId And DocumentType=@CreditMemoDocument)
						Begin
							Set @CreditMemoAmount=(Select Sum(Isnull(ReceiptAmount,0)) From Bean.ReceiptDetail(Nolock) Where ReceiptId=@SourceId And DocumentType=@CreditMemoDocument)
							Set @RecOrder=@RecOrder+1
							Insert Into Bean.JournalDetail (Id,JournalId,COAId,AccountDescription, DocDebit,DocCredit,
															 BaseDebit,BaseCredit,
															 DocDebitTotal,DocCreditTotal,BaseDebitTotal,BaseCreditTotal,DocumentId,DocumentDetailId,ItemId,BaseCurrency,ExchangeRate, DocType,DocSubType,ServiceCompanyId,DocNo, IsTax,
															EntityId, SystemRefNo, DocCurrency,DocDate, PostingDate,RecOrder 
															)
							Select NEWID(),@MasterJournalId,@ClearingReceiptsCOAID,R.Remarks,Null As DocDebit,Round(@CreditMemoAmount * @SysCalExchangerate,2) As DocCredit,
								Null As BaseDebit,Round((@CreditMemoAmount * @SysCalExchangerate) * @DefaultExchangeRate,2) As BaseCredit,
								0.00 As DocDebitTotal,0.00 As DocCreditTotal,0.00 As BaseDebitTotal,0.00 As BaseCreditTotal,R.Id As DocumentId,R.Id As DocumentDetailId,@GUIDZero,
								R.BaseCurrency,R.ExchangeRate, @DocType,@DocSubType,ServiceCompanyId,DocNo,0 As IsTax,
								EntityId,@MasterSystemRefNo,@BankChargesCurrency,DocDate,DocDate,@RecOrder As RecOrder
							From Bean.Receipt(Nolock) As R
							Where R.Id=@SourceId
						End
						---------
						--Creating Journal For Master Record With DifferentCurrency
						Set @JournalId=NEWID()
						Set @RecOrder=1
						Set @SysRefNum_Incr=@SysRefNum_Incr+1
						Set @SystemRefNo=CONCAT(@DocNo,'-JV',@SysRefNum_Incr)
						Insert Into Bean.Journal (Id,CompanyId,DocDate,DocType,DocSubType,DocNo,ServiceCompanyId,SystemReferenceNo,IsNoSupportingDocs,NoSupportingDocument,DocCurrency,ExchangeRate,ExCurrency,ExDurationFrom,GSTExchangeRate,GSTExCurrency,GSTTotalAmount,DocumentState,IsNoSupportingDocument,IsGstSettings,IsMultiCurrency,IsAllowableNonAllowable,IsGSTCurrencyRateChanged,Remarks,UserCreated,CreatedDate,Status,DocumentDescription,CreationType,GrandDocDebitTotal,GrandDocCreditTotal,GrandBaseDebitTotal,
													GrandBaseCreditTotal,EntityId,EntityType,PostingDate,COAId,ModeOfReceipt,BankReceiptAmmount,ExcessPaidByClientAmmount,BalancingItemReciveCRAmount,  BalancingItemPayDRAmount,ReceiptApplicationAmmount,DocumentId, BankClearingDate ,IsBalancing,ISAllowDisAllow, IsShow, ActualSysRefNo 
													,IsSegmentReporting,TransferRefNo
												 )
						Select @JournalId,@CompanyId,DocDate,@DocType,@DocSubType,DocNo,ServiceCompanyId,DocNo As SystemRefNo,IsNoSupportingDocument,NoSupportingDocs,DocCurrency,ExchangeRate,ExCurrency,ExDurationFrom,GSTExchangeRate,GSTExCurrency,Isnull(GSTTotalAmount,0),DocumentState,NoSupportingDocs,IsGstSettings,IsMultiCurrency,IsAllowableDisallowable,IsGSTCurrencyRateChanged,Remarks,@UserCreated,@CreatedDate,Status,Remarks As DocDescription,@UserCreated,GrandTotal,0.00 As GrandDocCreditTotal,GrandTotal * Round(ExchangeRate,2) As GrandBaseDebitTotal,
								0.00 As GrandBaseCreditTotal,EntityId,EntityType,DocDate As PostingDate,COAId,ModeOfReceipt,0.00 As BankReceiptAmmount,0.00 As ExcessPaidByClientAmmount,0.00 As BalancingItemReciveCRAmount,0.00 As BalancingItemPayDRAmount,0.00 As ReceiptApplicationAmmount,Id As DocumentId,BankClearingDate,0 As IsBalancing,IsDisAllow,1 As IsShow,DocNo As ActualSysRefNo,0 As IsSegmentReporting,ReceiptRefNo
						From Bean.Receipt(Nolock) Where CompanyId=@CompanyId And Id=@SourceId

						Insert Into Bean.JournalDetail (Id,JournalId,COAId,AccountDescription, DocDebit,DocCredit,
														 BaseDebit,BaseCredit,
														 DocDebitTotal,DocCreditTotal,BaseDebitTotal,BaseCreditTotal,DocumentId,DocumentDetailId,ItemId,BaseCurrency,ExchangeRate, DocType,DocSubType,ServiceCompanyId,DocNo, IsTax,
														EntityId, SystemRefNo, DocCurrency,DocDate, PostingDate,RecOrder 
														)
						Select NEWID(),@JournalId,@ClearingReceiptsCOAID,R.Remarks,
							Case When (@ClearingRecieptInvOrDNAmount-@ClearingRecieptBillAmount)>0 Then ABS(@ClearingRecieptInvOrDNAmount-@ClearingRecieptBillAmount) End As DocDebit,
							Case When (@ClearingRecieptInvOrDNAmount-@ClearingRecieptBillAmount)<0 Then ABS(@ClearingRecieptInvOrDNAmount-@ClearingRecieptBillAmount) End As DocCredit,
							Case When (@ClearingRecieptInvOrDNAmount-@ClearingRecieptBillAmount)>0 Then ABS(Round((@ClearingRecieptInvOrDNAmount-@ClearingRecieptBillAmount) * @SysCalExchangerate,2)) End As BaseDebit,
							Case When (@ClearingRecieptInvOrDNAmount-@ClearingRecieptBillAmount)<0 Then ABS(Round((@ClearingRecieptInvOrDNAmount-@ClearingRecieptBillAmount) * @SysCalExchangerate,2)) End As BaseCredit,
							0.00 As DocDebitTotal,0.00 As DocCreditTotal,0.00 As BaseDebitTotal,0.00 As BaseCreditTotal,R.Id As DocumentId,R.Id As DocumentDetailId,@GUIDZero,
							R.BaseCurrency,R.ExchangeRate, @DocType,@DocSubType,ServiceCompanyId,DocNo,0 As IsTax,
							EntityId,@SystemRefNo,@DocCurrency,DocDate,DocDate,@RecOrder As RecOrder
						From Bean.Receipt(Nolock) As R
						Where R.Id=@SourceId
						--Reciept Detail & Exchange Gain/Loss
						Insert Into @RecieptDtl 
						Select RD.Id From Bean.ReceiptDetail(Nolock) As RD
						Inner Join Bean.Receipt(Nolock) As R On RD.ReceiptId=R.Id 
						Where R.Id=@SourceId And RD.ReceiptAmount<>0 And RD.DocumentType Not In (@CreditNoteDocument,@CreditMemoDocument) Order By RD.RecOrder
						Set @Count=(Select Count(*) From @RecieptDtl)
						Set @RecOrder=2
						Set @RecCount=1
						While @Count>=@RecCount
						Begin
							Set @RecieptDtlId=(Select RecieptDtlId From @RecieptDtl Where S_No=@RecCount)
							Set @DocumentId=(Select DocumentId From Bean.ReceiptDetail(Nolock) Where Id=@RecieptDtlId)
							Set @IsRoundingAmount=0
							IF Exists (Select DocumentType From Bean.ReceiptDetail(Nolock) Where Id=@RecieptDtlId And DocumentType=@InvoiceDocument)
							Begin
								Set @ExchangeRate=(Select ExchangeRate From Bean.Invoice(Nolock) Where Id=@DocumentId)
								IF Exists(Select Id From Bean.Invoice(Nolock) Where Id=@DocumentId And DocumentState In (@FullyApplied,@Fullypaid))
								Begin
									Set @IsRoundingAmount=1
								End
							End
							Else IF Exists (Select DocumentType From Bean.ReceiptDetail(Nolock) Where Id=@RecieptDtlId And DocumentType=@DebitNoteDocument)
							Begin
								Set @ExchangeRate=(Select ExchangeRate From Bean.DebitNote(Nolock) Where Id=@DocumentId)
								IF Exists(Select Id From Bean.DebitNote(Nolock) Where Id=@DocumentId And DocumentState In (@FullyApplied,@Fullypaid))
								Begin
									Set @IsRoundingAmount=1
								End
							End
							Else IF Exists (Select DocumentType From Bean.ReceiptDetail(Nolock) Where Id=@RecieptDtlId And DocumentType=@BillDocument)
							Begin
								Set @ExchangeRate=(Select ExchangeRate From Bean.Bill(Nolock) Where Id=@DocumentId)
								IF Exists(Select Id From Bean.Bill(Nolock) Where Id=@DocumentId And DocumentState In (@FullyApplied,@Fullypaid))
								Begin
									Set @IsRoundingAmount=1
								End
							End
							--Getting COAID By Checking Nature
							IF Exists (Select ID From Bean.ReceiptDetail(Nolock) Where id=@RecieptDtlId And Nature=@NatureTrade And DocumentType<>@BillDocument)
							Begin
								Set @COAID=(Select Id From Bean.ChartOfAccount(Nolock) Where CompanyId=@CompanyId And Name=@COATradeReceivables)
							End
							Else IF Exists (Select ID From Bean.ReceiptDetail(Nolock) Where id=@RecieptDtlId And Nature=@NatureOthers And DocumentType<>@BillDocument)
							Begin
								Set @COAID=(Select Id From Bean.ChartOfAccount(Nolock) Where CompanyId=@CompanyId And Name=@COAotherReceivables)
							End
							Else IF Exists (Select ID From Bean.ReceiptDetail(Nolock) Where id=@RecieptDtlId And Nature=@NatureTrade And DocumentType=@BillDocument)
							Begin
								Set @COAID=(Select Id From Bean.ChartOfAccount(Nolock) Where CompanyId=@CompanyId And Name=@COATradePayables)
							End
							Else IF Exists (Select ID From Bean.ReceiptDetail(Nolock) Where id=@RecieptDtlId And Nature=@NatureOthers And DocumentType=@BillDocument)
							Begin
								Set @COAID=(Select Id From Bean.ChartOfAccount(Nolock) Where CompanyId=@CompanyId And Name=@COAOtherPayables)
							End
							IF @IsRoundingAmount=1 And Exists (Select Amount From @RoundingAmountDetails Where DocumentId=@DocumentId And Amount Is Not Null And Amount<>'')
							Begin
								Set @DocAmount=(Select Amount From @RoundingAmountDetails Where DocumentId=@DocumentId)
							End
							Else
							Begin
								Set @DocAmount=0
							End
							-- Checking Document Type Bill Or Not
							IF Exists (Select Id From Bean.ReceiptDetail(Nolock) Where Id=@RecieptDtlId And DocumentType=@BillDocument)
							Begin
								Set @RecOrder=@RecOrder+1
								Insert Into Bean.JournalDetail (Id,JournalId,COAId,AccountDescription, DocDebit,DocCredit,
														 BaseDebit,BaseCredit,
														 DocDebitTotal,DocCreditTotal,BaseDebitTotal,BaseCreditTotal,DocumentId,DocumentDetailId,ItemId,BaseCurrency,ExchangeRate, DocType,DocSubType,ServiceCompanyId,DocNo,Nature,OffsetDocument,IsTax,
														EntityId, SystemRefNo, DocCurrency,DocDate, PostingDate,RecOrder 
														)
								Select NEWID(),@JournalId,@COAID,R.Remarks,Rd.ReceiptAmount As DocDebit,Null As DocCredit,
									Round(Rd.ReceiptAmount * @ExchangeRate,2)- Isnull(@DocAmount,0) As BaseDebit,Null As BaseCredit,
									0.00 As DocDebitTotal,0.00 As DocCreditTotal,0.00 As BaseDebitTotal,0.00 As BaseCreditTotal,R.Id As DocumentId,RD.Id As DocumentDetailId,@GUIDZero,
									R.BaseCurrency,@ExchangeRate As ExchangeRate,@DocType,@DocSubType,RD.ServiceCompanyId,R.DocNo,RD.Nature,RD.DocumentNo,0 As IsTax,
									R.EntityId,@SystemRefNo,@DocCurrency,R.DocDate,R.DocDate,@RecOrder As RecOrder
								From Bean.Receipt(Nolock) As R
								Inner Join bean.ReceiptDetail(Nolock) As RD On RD.ReceiptId=R.Id
								Where R.Id=@SourceId And RD.Id=@RecieptDtlId
								
								IF @SysCalExchangerate-@ExchangeRate<>0
								Begin
									Set @RecOrder=@RecOrder+1
									-- ExchangeGainOrLossRealised
									Insert Into Bean.JournalDetail (Id,JournalId,COAId,AccountDescription, DocDebit,DocCredit,
																	 BaseDebit,BaseCredit,
																	 DocDebitTotal,DocCreditTotal,BaseDebitTotal,BaseCreditTotal,DocumentId,DocumentDetailId,ItemId,BaseCurrency,ExchangeRate, DocType,DocSubType,ServiceCompanyId,DocNo,Nature,OffsetDocument,IsTax,
																	EntityId, SystemRefNo, DocCurrency,DocDate, PostingDate,RecOrder 
																	)
									Select NEWID(),@JournalId,@ExchangeGainOrLossCOAID,R.Remarks,Null As DocDebit,Null As DocCredit,
										Case When (@SysCalExchangerate-@ExchangeRate)>0 Then ABS(Round((@SysCalExchangerate-@ExchangeRate) * RD.ReceiptAmount,2)) End As BaseDebit,Case When (@SysCalExchangerate-@ExchangeRate)<0 Then ABS(Round((@SysCalExchangerate-@ExchangeRate)* RD.ReceiptAmount,2) ) End As BaseCredit,
										0.00 As DocDebitTotal,0.00 As DocCreditTotal,0.00 As BaseDebitTotal,0.00 As BaseCreditTotal,R.Id As DocumentId,RD.Id As DocumentDetailId,@GUIDZero,
										R.BaseCurrency,Null As ExchangeRate,@DocType,@DocSubType,RD.ServiceCompanyId,R.DocNo,RD.Nature,RD.DocumentNo,0 As IsTax,
										EntityId,@SystemRefNo,@DocCurrency,DocDate,DocDate,@RecOrder As RecOrder
									From Bean.Receipt(Nolock) As R
									Inner Join bean.ReceiptDetail(Nolock) As RD On RD.ReceiptId=R.Id
									Where R.Id=@SourceId And RD.Id=@RecieptDtlId
								End
							End
							Else
							Begin
								Set @RecOrder=@RecOrder+1
								Insert Into Bean.JournalDetail (Id,JournalId,COAId,AccountDescription, DocDebit,DocCredit,
														 BaseDebit,BaseCredit,
														 DocDebitTotal,DocCreditTotal,BaseDebitTotal,BaseCreditTotal,DocumentId,DocumentDetailId,ItemId,BaseCurrency,ExchangeRate, DocType,DocSubType,ServiceCompanyId,DocNo,Nature,OffsetDocument,IsTax,
														EntityId, SystemRefNo, DocCurrency,DocDate, PostingDate,RecOrder 
														)
								Select NEWID(),@JournalId,@COAID,R.Remarks,Null As DocDebit,Rd.ReceiptAmount As DocCredit,
									Null As BaseDebit,Round(Rd.ReceiptAmount * @ExchangeRate,2)- Isnull(@DocAmount,0) As BaseCredit,
									0.00 As DocDebitTotal,0.00 As DocCreditTotal,0.00 As BaseDebitTotal,0.00 As BaseCreditTotal,R.Id As DocumentId,RD.Id As DocumentDetailId,@GUIDZero,
									R.BaseCurrency,@ExchangeRate As ExchangeRate,@DocType,@DocSubType,RD.ServiceCompanyId,R.DocNo,RD.Nature,RD.DocumentNo,0 As IsTax,
									R.EntityId,@SystemRefNo,@DocCurrency,R.DocDate,R.DocDate,@RecOrder As RecOrder
								From Bean.Receipt(Nolock) As R
								Inner Join bean.ReceiptDetail(Nolock) As RD On RD.ReceiptId=R.Id
								Where R.Id=@SourceId And RD.Id=@RecieptDtlId
								IF @SysCalExchangerate-@ExchangeRate<>0
								Begin
									Set @RecOrder=@RecOrder+1
									-- ExchangeGainOrLossRealised
									Insert Into Bean.JournalDetail (Id,JournalId,COAId,AccountDescription, DocDebit,DocCredit,
																	 BaseDebit,BaseCredit,
																	 DocDebitTotal,DocCreditTotal,BaseDebitTotal,BaseCreditTotal,DocumentId,DocumentDetailId,ItemId,BaseCurrency,ExchangeRate, DocType,DocSubType,ServiceCompanyId,DocNo,Nature,OffsetDocument,IsTax,
																	EntityId, SystemRefNo, DocCurrency,DocDate, PostingDate,RecOrder 
																	)
									Select NEWID(),@JournalId,@ExchangeGainOrLossCOAID,R.Remarks,Null As DocDebit,Null As DocCredit,
										Case When (@SysCalExchangerate -@ExchangeRate)<0 Then ABS(Round((@SysCalExchangerate -@ExchangeRate) * RD.ReceiptAmount,2)) End As BaseDebit,Case When (@SysCalExchangerate -@ExchangeRate)>0 Then ABS(Round((@SysCalExchangerate -@ExchangeRate) * RD.ReceiptAmount,2)) End As BaseCredit,
										0.00 As DocDebitTotal,0.00 As DocCreditTotal,0.00 As BaseDebitTotal,0.00 As BaseCreditTotal,R.Id As DocumentId,RD.Id As DocumentDetailId,@GUIDZero,
										R.BaseCurrency,Null As ExchangeRate,@DocType,@DocSubType,RD.ServiceCompanyId,R.DocNo,RD.Nature,RD.DocumentNo,0 As IsTax,
										EntityId,@SystemRefNo,@DocCurrency,DocDate,DocDate,@RecOrder As RecOrder
									From Bean.Receipt(Nolock) As R
									Inner Join bean.ReceiptDetail(Nolock) As RD On RD.ReceiptId=R.Id
									Where R.Id=@SourceId And RD.Id=@RecieptDtlId
								End
							End
							Set @RecCount=@RecCount+1
						End
					End
				End
			End
			/* Checking Intro Company Or Not */
			Else IF @ServCompCount > 1 Or @ServCompCount2 <> 0
			Begin
				/* Creating Main Journal */
				Set @MasterJournalId=NEWID()
				Set @MasterSystemRefNo=CONCAT(@DocNo,'-JV',@SysRefNum_Incr)
				Insert Into Bean.Journal (Id,CompanyId,DocDate,DocType,DocSubType,DocNo,ServiceCompanyId,SystemReferenceNo,IsNoSupportingDocs,NoSupportingDocument,DocCurrency,ExchangeRate,ExCurrency,ExDurationFrom,GSTExchangeRate,GSTExCurrency,GSTTotalAmount,DocumentState,IsNoSupportingDocument,IsGstSettings,IsMultiCurrency,IsAllowableNonAllowable,IsGSTCurrencyRateChanged,Remarks,UserCreated,CreatedDate,Status,DocumentDescription,CreationType,GrandDocDebitTotal,GrandDocCreditTotal,GrandBaseDebitTotal,
											GrandBaseCreditTotal,EntityId,EntityType,PostingDate,COAId,ModeOfReceipt,BankReceiptAmmount,ExcessPaidByClientAmmount,BalancingItemReciveCRAmount,  BalancingItemPayDRAmount,ReceiptApplicationAmmount,DocumentId, BankClearingDate ,IsBalancing,ISAllowDisAllow, IsShow, ActualSysRefNo,IsSegmentReporting,TransferRefNo
										  )
				Select @MasterJournalId,@CompanyId,DocDate,@DocType,@DocSubType,DocNo,ServiceCompanyId,@SystemRefNo As SystemRefNo,IsNoSupportingDocument,NoSupportingDocs,DocCurrency,ExchangeRate,ExCurrency,ExDurationFrom,GSTExchangeRate,GSTExCurrency,Isnull(GSTTotalAmount,0),DocumentState,NoSupportingDocs,IsGstSettings,IsMultiCurrency,IsAllowableDisallowable,IsGSTCurrencyRateChanged,Remarks,@UserCreated,@CreatedDate,Status,Remarks As DocDescription,@UserCreated,GrandTotal,0.00 As GrandDocCreditTotal,GrandTotal * Round(ExchangeRate,2) As GrandBaseDebitTotal,
						0.00 As GrandBaseCreditTotal,EntityId,EntityType,DocDate As PostingDate,COAId,ModeOfReceipt,0.00 As BankReceiptAmmount,0.00 As ExcessPaidByClientAmmount,0.00 As BalancingItemReciveCRAmount,0.00 As BalancingItemPayDRAmount,0.00 As ReceiptApplicationAmmount,Id As DocumentId,BankClearingDate,0 As IsBalancing,IsDisAllow,1 As IsShow,DocNo As ActualSysRefNo,0 As IsSegmentReporting,ReceiptRefNo
				From Bean.Receipt(Nolock) Where CompanyId=@CompanyId And Id=@SourceId
				/* DocCurrency=BaseCureency=BankChargesCurrency */
				IF @DocCurrency=@BankChargesCurrency And @BaseCurrency=@DocCurrency
				Begin
					/* Creating Mater Record With BankReceiptAmmount In JournalDetail */
					IF Exists (Select Id From Bean.Receipt(Nolock) Where Id=@SourceId And GrandTotal<>0)
					Begin
						Insert Into Bean.JournalDetail (Id,JournalId,COAId,AccountDescription,AllowDisAllow, DocDebit, BaseDebit, DocDebitTotal,DocCreditTotal,BaseDebitTotal,BaseCreditTotal,DocumentId,DocumentDetailId,ItemId,BaseCurrency,ExchangeRate,GSTExCurrency,GSTExchangeRate,DocType,DocSubType,ServiceCompanyId,DocNo, IsTax,
										EntityId, SystemRefNo, DocCurrency,DocDate, PostingDate,RecOrder )
						Select NEWID(),@MasterJournalId,COAId,Remarks,IsDisAllow,BankReceiptAmmount,BankReceiptAmmount * Round(ExchangeRate,2),0.00 As DocDebitTotal,0.00 As DocCreditTotal,0.00 As BaseDebitTotal,0.00 As BaseCreditTotal,Id As DocumentId,@GUIDZero,@GUIDZero,
								BaseCurrency,ExchangeRate,GSTExCurrency,GSTExchangeRate,@DocType,@DocSubType,ServiceCompanyId,DocNo,0 As IsTax,
								EntityId,@MasterSystemRefNo As SystemRefNo,@BankChargesCurrency,DocDate,DocDate,@RecOrder As RecOrder
						From Bean.Receipt(Nolock) Where Id=@SourceId
					End
					Else IF Exists (Select Id From Bean.Receipt(Nolock) Where Id=@SourceId And GrandTotal=0 And BankReceiptAmmount<>0)
					Begin
						Insert Into Bean.JournalDetail (Id,JournalId,COAId,AccountDescription,AllowDisAllow, DocDebit, BaseDebit, DocDebitTotal,DocCreditTotal,BaseDebitTotal,BaseCreditTotal,DocumentId,DocumentDetailId,ItemId,BaseCurrency,ExchangeRate,GSTExCurrency,GSTExchangeRate,DocType,DocSubType,ServiceCompanyId,DocNo, IsTax,
										EntityId, SystemRefNo, DocCurrency,DocDate, PostingDate,RecOrder )
						Select NEWID(),@MasterJournalId,COAId,Remarks,IsDisAllow,Isnull(BankReceiptAmmount,0) As BankReceiptAmmount,Round(Isnull(BankReceiptAmmount,0) * ExchangeRate,2),0.00 As DocDebitTotal,0.00 As DocCreditTotal,0.00 As BaseDebitTotal,0.00 As BaseCreditTotal,Id As DocumentId,@GUIDZero,@GUIDZero,
								BaseCurrency,ExchangeRate,GSTExCurrency,GSTExchangeRate,@DocType,@DocSubType,ServiceCompanyId,DocNo,0 As IsTax,
								EntityId,@MasterSystemRefNo As SystemRefNo,@BankChargesCurrency,DocDate,DocDate,@RecOrder As RecOrder
						From Bean.Receipt(Nolock) Where Id=@SourceId
					End
					/* Creating Record in Journaldetail With Bank Charges Amount */
					If Exists(Select Id From Bean.Receipt(Nolock) Where Id=@SourceId And BankCharges Is Not Null)
					Begin
						Set @RecOrder=@RecOrder+1
						Insert Into Bean.JournalDetail (Id,JournalId,COAId,AccountDescription,AllowDisAllow,TaxId,TaxType,TaxRate,DocDebit, BaseDebit, DocDebitTotal,DocCreditTotal,BaseDebitTotal,BaseCreditTotal,DocumentId,DocumentDetailId,ItemId,BaseCurrency,ExchangeRate,GSTExCurrency,GSTExchangeRate,DocType,DocSubType,ServiceCompanyId,DocNo, IsTax,
													EntityId, SystemRefNo, DocCurrency,DocDate, PostingDate,RecOrder,GSTTaxDebit)
						Select NEWID(),@MasterJournalId,@BankCharges_COAId,Remarks,IsDisAllow,@TaxId,@TaxType,@TaxRate,BankCharges,BankCharges * Round(ExchangeRate,2),0.00 As DocDebitTotal,0.00 As DocCreditTotal,0.00 As BaseDebitTotal,0.00 As BaseCreditTotal,Id As DocumentId,Id As DocumentDetailId,@GUIDZero,
							BaseCurrency,ExchangeRate,GSTExCurrency,GSTExchangeRate,@DocType,@DocSubType,ServiceCompanyId,DocNo,0 As IsTax,
							EntityId,@MasterSystemRefNo As SystemRefNo,@DocCurrency,DocDate,DocDate,@RecOrder As RecOrder,
							Case When @TaxId Is Not Null Then Round(BankCharges * Coalesce(GSTexchangerate,@DefaultExchangeRate),2) End As GSTTaxDebit
						From Bean.Receipt(Nolock)
						Where Id=@SourceId
					End
					/* Creating Record in Journaldetail With @ExcesPaidByClientAmt Amount */
					If @ExcesPaidByClientAmt Is NOt Null
					Begin
						Set @RecOrder=@RecOrder+1
						Insert Into Bean.JournalDetail (Id,JournalId,COAId,AccountDescription,AllowDisAllow, DocCredit, BaseCredit, DocDebitTotal,DocCreditTotal,BaseDebitTotal,BaseCreditTotal,DocumentId,DocumentDetailId,ItemId,BaseCurrency,ExchangeRate,GSTExCurrency,GSTExchangeRate,DocType,DocSubType,ServiceCompanyId,DocNo, IsTax,
														EntityId, SystemRefNo, DocCurrency,DocDate, PostingDate,RecOrder )
						Select NEWID(),@MasterJournalId,@ClearingReceiptsCOAID,Remarks,IsDisAllow,ExcessPaidByClientAmmount,ExcessPaidByClientAmmount * Round(ExchangeRate,2),0.00 As DocDebitTotal,0.00 As DocCreditTotal,0.00 As BaseDebitTotal,0.00 As BaseCreditTotal,Id As DocumentId,Id As DocumentDtlId,@GUIDZero,
								BaseCurrency,ExchangeRate,BankReceiptAmmountCurrency,ExchangeRate,@DocType,@DocSubType,ServiceCompanyId,DocNo,0 As IsTax,
								EntityId,@MasterSystemRefNo,@DocCurrency,DocDate,DocDate,@RecOrder As RecOrder
						From Bean.Receipt(Nolock) 
						Where Id=@SourceId
					End
					/* Creating Balancing Line Items */
					Insert Into @RecieptBalLnItm
					Select RBI.Id From Bean.ReceiptBalancingItem(Nolock) As RBI
					Inner Join bean.Receipt(Nolock) As R On R.Id=RBI.ReceiptId
					Where R.Id=@SourceId Order by RecOrder
					Set @Count=(Select Count(*) From @RecieptBalLnItm)
					Set @RecCount=1
					While @Count>=@RecCount
					Begin
						Select @RecieptBalId=RecieptBalId From @RecieptBalLnItm Where S_no=@RecCount
						Select @TaxId=TaxId,@TaxRate=TaxRate From Bean.ReceiptBalancingItem(Nolock) Where Id=@RecieptBalId
						Set @RecOrder=@RecOrder+1
						Insert Into Bean.JournalDetail (Id,JournalId,COAId,AccountDescription,AllowDisAllow,TaxId,TaxType,TaxRate,DocDebit,DocCredit,
													DocTaxDebit,DocTaxCredit,BaseDebit,BaseCredit,
													BaseTaxDebit,BaseTaxCredit,DocDebitTotal,DocCreditTotal,BaseDebitTotal,BaseCreditTotal,DocumentId,DocumentDetailId,ItemId,BaseCurrency,ExchangeRate,GSTExCurrency,GSTExchangeRate,DocType,DocSubType,ServiceCompanyId,DocNo, IsTax,
													EntityId, SystemRefNo, DocCurrency,DocDate, PostingDate,RecOrder,GSTTaxDebit,GSTTaxCredit,GSTDebit,GSTCredit)
						Select NEWID(),@MasterJournalId,RBi.COAId,R.Remarks,RBI.IsDisAllow,RBI.TaxId,RBI.TaxType,Rbi.TaxRate,Case When RBI.ReciveORPay=@Pay_Dr Then RBI.DocAmount End As DocDebit,Case When RBI.ReciveORPay=@Receive_Cr Then RBI.DocAmount End As DocCredit,
							Case When RBI.ReciveORPay=@Pay_Dr Then RBI.DocTaxAmount End As DocTaxDebdit,Case When RBI.ReciveORPay=@Receive_Cr Then RBI.DocTaxAmount End As DocTaxCredit,Case When RBI.ReciveORPay=@Pay_Dr Then RBI.DocAmount * Round(R.ExchangeRate,2) End As BaseDebit,Case When RBI.ReciveORPay=@Receive_Cr Then RBI.DocAmount * Round(R.ExchangeRate,2) End As BaseCredit,
							Case When RBI.ReciveORPay=@Pay_Dr Then RBI.DocTaxAmount * Round(@MainExchangeRate,2) End As BaseTaxDebdit,Case When RBI.ReciveORPay=@Receive_Cr Then RBI.DocTaxAmount * Round(@MainExchangeRate,2) End As BaseTaxCredit,0.00 As DocDebitTotal,0.00 As DocCreditTotal,0.00 As BaseDebitTotal,0.00 As BaseCreditTotal,R.Id As DocumentId,RBI.Id As DocumentDetailId,@GUIDZero,
							R.BaseCurrency,R.ExchangeRate,R.GSTExCurrency,R.GSTExchangeRate,@DocType,@DocSubType,ServiceCompanyId,DocNo,0 As IsTax,
							EntityId,@MasterSystemRefNo,@DocCurrency,DocDate,DocDate,@RecOrder As RecOrder,
							Case When RBI.ReciveORPay=@Pay_Dr Then Round(RBI.DocAmount * Coalesce(R.GSTExchangeRate,@DefaultExchangeRate),2) End As GSTTaxDebit,
							Case When RBI.ReciveORPay=@Receive_Cr Then Round(RBI.DocAmount * Coalesce(R.GSTExchangeRate,@DefaultExchangeRate),2) End As GSTTaxCredit,
							Case When RBI.ReciveORPay=@Pay_Dr Then Round(RBI.DocTaxAmount * Coalesce(R.GSTExchangeRate,@DefaultExchangeRate),2) End As GSTDebit,
							Case When RBI.ReciveORPay=@Receive_Cr Then Round(RBI.DocTaxAmount * Coalesce(R.GSTExchangeRate,@DefaultExchangeRate),2) End As GSTCredit
						From Bean.Receipt(Nolock) As R
						Inner Join bean.ReceiptBalancingItem(Nolock) As RBI On RBI.ReceiptId=R.Id
						Where R.Id=@SourceId And Rbi.Id=@RecieptBalId
						-- Creating Tax Line Items
						If @GST Is Not Null And @GST=1 And @TaxId Is Not Null And (@TaxRate Is Not Null And @TaxRate<>0)
						Begin
							Set @TaxRecCount=@RecOrder+@Count
							Insert Into Bean.JournalDetail (Id,JournalId,COAId,AccountDescription,AllowDisAllow,TaxId,TaxType,TaxRate,DocDebit,DocCredit,
									 BaseDebit,BaseCredit,
									 DocDebitTotal,DocCreditTotal,BaseDebitTotal,BaseCreditTotal,DocumentId,DocumentDetailId,ItemId,BaseCurrency,ExchangeRate,GSTExCurrency,GSTExchangeRate,DocType,DocSubType,ServiceCompanyId,DocNo, IsTax,
									EntityId, SystemRefNo, DocCurrency,DocDate, PostingDate,RecOrder )
							Select NEWID(),@MasterJournalId,@TaxPayableGST_COAID as COAId,R.Remarks,RBI.IsDisAllow,RBI.TaxId,RBI.TaxType,Rbi.TaxRate,Case When RBI.ReciveORPay=@Pay_Dr Then RBI.DocTaxAmount End As DocDebit,Case When RBI.ReciveORPay=@Receive_Cr Then RBI.DocTaxAmount End As DocCredit,
								Case When RBI.ReciveORPay=@Pay_Dr Then RBI.DocTaxAmount * Round(R.ExchangeRate,2) End As BaseDebit,Case When RBI.ReciveORPay=@Receive_Cr Then RBI.DocTaxAmount * Round(R.ExchangeRate,2) End As BaseCredit,
								0.00 As DocDebitTotal,0.00 As DocCreditTotal,0.00 As BaseDebitTotal,0.00 As BaseCreditTotal,R.Id As DocumentId,RBI.Id As DocumentDetailId,@GUIDZero,
								R.BaseCurrency,R.ExchangeRate,R.GSTExCurrency,R.GSTExchangeRate,@DocType,@DocSubType,ServiceCompanyId,DocNo,1 As IsTax,
								EntityId,@MasterSystemRefNo,@DocCurrency,DocDate,DocDate,@TaxRecCount As RecOrder
							From Bean.Receipt(Nolock) As R
							Inner Join bean.ReceiptBalancingItem(Nolock) As RBI On RBI.ReceiptId=R.Id
							Where R.Id=@SourceId And Rbi.Id=@RecieptBalId
						End
						Set @RecCount=@RecCount+1
					End
					IF Exists (Select Id From Bean.ReceiptDetail(Nolock) Where ReceiptId=@SourceId And ReceiptAmount<>0)
					Begin
						/* Reciept Detail Main Serv Comp */
						Insert Into @InterCoRecieptDtl 
						Select RD.Id,RD.ServiceCompanyId From Bean.ReceiptDetail(Nolock) As RD
						Inner Join Bean.Receipt(Nolock) As R On RD.ReceiptId=R.Id 
						Where R.Id=@SourceId And RD.ServiceCompanyId=@MasterServComp And RD.ReceiptAmount <>0 Order By RD.RecOrder
						Set @Count=(Select Count(*) From @InterCoRecieptDtl)
						Set @RecCount=1
						While @Count>=@RecCount
						Begin
							Set @RecOrder=@RecOrder+1
							Set @RecieptDtlId=(Select RecieptDtlId From @InterCoRecieptDtl Where S_No=@RecCount)
							Set @ServCompId=(Select ServCompId From @InterCoRecieptDtl Where S_No=@RecCount)
							Set @DocumentId=(Select DocumentId From Bean.ReceiptDetail(Nolock) Where Id=@RecieptDtlId)
							Set @IsRoundingAmount=0
							--Getting COAID By Checking Nature
							IF Exists (Select ID From Bean.ReceiptDetail(Nolock) Where id=@RecieptDtlId And Nature=@NatureTrade)
							Begin
								Set @COAID=(Select Id From Bean.ChartOfAccount(Nolock) Where CompanyId=@CompanyId And Name=@COATradeReceivables)
							End
							Else IF Exists (Select ID From Bean.ReceiptDetail(Nolock) Where id=@RecieptDtlId And Nature=@NatureOthers)
							Begin
								Set @COAID=(Select Id From Bean.ChartOfAccount(Nolock) Where CompanyId=@CompanyId And Name=@COAotherReceivables)
							End
							IF Exists (Select Id From Bean.ReceiptDetail(Nolock) Where Id=@RecieptDtlId And DocumentType=@InvoiceDocument)
							Begin
								If Exists (Select Id From Bean.Invoice(Nolock) Where Id=@DocumentId And DocumentState in (@FullyApplied,@Fullypaid))
								Begin
									Set @IsRoundingAmount=1
								End
							End
							ELSE IF Exists (Select Id From Bean.ReceiptDetail(Nolock) Where Id=@RecieptDtlId And DocumentType=@DebitNoteDocument)
							Begin
								If Exists (Select Id From Bean.DebitNote(Nolock) Where Id=@DocumentId And DocumentState in (@FullyApplied,@Fullypaid))
								Begin
									Set @IsRoundingAmount=1
								End
							End
		
							IF @IsRoundingAmount=1 And Exists (Select Amount From @RoundingAmountDetails Where DocumentId=@DocumentId And Amount Is Not Null And Amount<>'')
							Begin
								Set @DocAmount=(Select Amount From @RoundingAmountDetails Where DocumentId=@DocumentId)
							End
							Else
							Begin
								Set @DocAmount=0
							End
							Insert Into Bean.JournalDetail (Id,JournalId,COAId,AccountDescription, DocDebit,DocCredit,
															 BaseDebit,BaseCredit,
															 DocDebitTotal,DocCreditTotal,BaseDebitTotal,BaseCreditTotal,DocumentId,DocumentDetailId,ItemId,BaseCurrency,ExchangeRate, DocType,DocSubType,ServiceCompanyId,DocNo,Nature,OffsetDocument,IsTax,
															EntityId, SystemRefNo, DocCurrency,DocDate, PostingDate,RecOrder 
															)
							Select NEWID(),@MasterJournalId,@COAID,R.Remarks,Null As DocDebit,RD.ReceiptAmount As DocCredit,
								Null As BaseDebit,RD.ReceiptAmount * Round(R.ExchangeRate,2)- Isnull(@DocAmount,0) As BaseCredit,
								0.00 As DocDebitTotal,0.00 As DocCreditTotal,0.00 As BaseDebitTotal,0.00 As BaseCreditTotal,R.Id As DocumentId,RD.Id As DocumentDetailId,@GUIDZero,
								R.BaseCurrency,R.ExchangeRate,@DocType,@DocSubType,@MasterServComp As ServiceCompanyId,R.DocNo,RD.Nature,RD.DocumentNo,0 As IsTax,
								EntityId,@MasterSystemRefNo,@DocCurrency,DocDate,DocDate,@RecOrder As RecOrder
							From Bean.Receipt(Nolock) As R
							Inner Join bean.ReceiptDetail(Nolock) As RD On RD.ReceiptId=R.Id
							Where R.Id=@SourceId And RD.Id=@RecieptDtlId
		
							Set @RecCount=@RecCount+1
						End
						-- Looping Service Company Id's To Create Journal
						Insert Into @ServCompaIdTbl
						Select Distinct ServiceCompanyId From Bean.ReceiptDetail(Nolock) 
						Where ReceiptId=@SourceId And ServiceCompanyId<>@MasterServComp And ReceiptAmount<>0
						Set @ServCompaIdTblCnt=(Select Count(S_No) From @ServCompaIdTbl)
						Set @RecCount=1
						While @ServCompaIdTblCnt>=@RecCount
						Begin
							Select @ServCompId=SerCompId From @ServCompaIdTbl Where S_No=@RecCount
							Set @SysRefNum_Incr=@SysRefNum_Incr+1
							Set @SystemRefNo=CONCAT(@DocNo,'-JV',@SysRefNum_Incr)
							Set @JournalId=NEWID()
							Set @IntroCompCOAID=(Select COA.Id From Bean.ChartOfAccount(Nolock) As COA 
													Inner Join Bean.AccountType(Nolock) As ACT On ACT.Id=COA.AccountTypeId
													Where ACT.CompanyId=@CompanyId And ACT.Name=@IntercompClearingCOAName And COA.SubsidaryCompanyId=@ServCompId)
							Set @RecOrder=@RecOrder+1
							Insert Into Bean.JournalDetail (Id,JournalId,COAId,AccountDescription, DocDebit,DocCredit,
															 BaseDebit,BaseCredit,
															 DocDebitTotal,DocCreditTotal,BaseDebitTotal,BaseCreditTotal,DocumentId,DocumentDetailId,ItemId,BaseCurrency,ExchangeRate, DocType,DocSubType,ServiceCompanyId,DocNo,Nature,OffsetDocument,IsTax,
															EntityId, SystemRefNo, DocCurrency,DocDate, PostingDate,RecOrder 
															)
							Select NEWID(),@MasterJournalId,@IntroCompCOAID,R.Remarks,Null As DocDebit,Sum(Isnull(RD.ReceiptAmount,0)) As DocCredit,
								Null As BaseDebit,Round(Sum(Isnull(RD.ReceiptAmount,0)) * R.ExchangeRate,2) As BaseCredit,
								0.00 As DocDebitTotal,0.00 As DocCreditTotal,0.00 As BaseDebitTotal,0.00 As BaseCreditTotal,R.Id As DocumentId,@GUIDZero As DocumentDetailId,@GUIDZero,
								R.BaseCurrency,R.ExchangeRate,@DocType,@DocSubType,@MasterServComp As ServiceCompanyId,R.DocNo,Null As Nature,R.DocNo,0 As IsTax,
								R.EntityId,@MasterSystemRefNo,@DocCurrency,R.DocDate,R.DocDate,@RecOrder As RecOrder
							From Bean.Receipt(Nolock) As R
							Inner Join bean.ReceiptDetail(Nolock) As RD On RD.ReceiptId=R.Id
							Where R.Id=@SourceId And RD.ServiceCompanyId=@ServCompId
							Group By R.Remarks,R.ExchangeRate,R.Id,R.BaseCurrency,R.DocNo,R.EntityId,R.DocDate
							
							Insert Into Bean.Journal (Id,CompanyId,DocDate,DocType,DocSubType,DocNo,ServiceCompanyId,SystemReferenceNo,IsNoSupportingDocs,NoSupportingDocument,DocCurrency,ExchangeRate,ExCurrency,ExDurationFrom,GSTExchangeRate,GSTExCurrency,GSTTotalAmount,DocumentState,IsNoSupportingDocument,IsGstSettings,IsMultiCurrency,IsAllowableNonAllowable,IsGSTCurrencyRateChanged,Remarks,UserCreated,CreatedDate,Status,DocumentDescription,CreationType,GrandDocDebitTotal,GrandDocCreditTotal,GrandBaseDebitTotal,
														GrandBaseCreditTotal,EntityId,EntityType,PostingDate,COAId,ModeOfReceipt,BankReceiptAmmount,ExcessPaidByClientAmmount,BalancingItemReciveCRAmount,  BalancingItemPayDRAmount,ReceiptApplicationAmmount,DocumentId, BankClearingDate ,IsBalancing,ISAllowDisAllow, IsShow, ActualSysRefNo 
														,IsSegmentReporting,TransferRefNo
													 )
							Select @JournalId,@CompanyId,DocDate,@DocType,@DocSubType,DocNo,@ServCompId As ServiceCompanyId,@SystemRefNo As SystemRefNo,IsNoSupportingDocument,NoSupportingDocs,DocCurrency,ExchangeRate,ExCurrency,ExDurationFrom,GSTExchangeRate,GSTExCurrency,Isnull(GSTTotalAmount,0),DocumentState,NoSupportingDocs,IsGstSettings,IsMultiCurrency,IsAllowableDisallowable,IsGSTCurrencyRateChanged,Remarks,@UserCreated,@CreatedDate,Status,Remarks As DocDescription,@UserCreated,GrandTotal,0.00 As GrandDocCreditTotal,GrandTotal * Round(ExchangeRate,2) As GrandBaseDebitTotal,
									0.00 As GrandBaseCreditTotal,EntityId,EntityType,DocDate As PostingDate,@IntroCompCOAID As COAId,ModeOfReceipt,0.00 As BankReceiptAmmount,0.00 As ExcessPaidByClientAmmount,0.00 As BalancingItemReciveCRAmount,0.00 As BalancingItemPayDRAmount,0.00 As ReceiptApplicationAmmount,Id As DocumentId,BankClearingDate,0 As IsBalancing,IsDisAllow,1 As IsShow,DocNo As ActualSysRefNo,0 As IsSegmentReporting,ReceiptRefNo
							From Bean.Receipt(Nolock) Where CompanyId=@CompanyId And Id=@SourceId

							Insert Into Bean.JournalDetail (Id,JournalId,COAId,AccountDescription, DocDebit,DocCredit,
													 BaseDebit,BaseCredit,
													 DocDebitTotal,DocCreditTotal,BaseDebitTotal,BaseCreditTotal,DocumentId,DocumentDetailId,ItemId,BaseCurrency,ExchangeRate, DocType,DocSubType,ServiceCompanyId,DocNo,Nature,OffsetDocument,IsTax,
													EntityId, SystemRefNo, DocCurrency,DocDate, PostingDate,RecOrder 
													)
							Select NEWID(),@JournalId,@MainInterCoServCompCOAID,R.Remarks,Sum(Isnull(RD.ReceiptAmount,0)) As DocDebit,Null As DocCredit,
									Sum(Isnull(RD.ReceiptAmount,0)) * Round(R.ExchangeRate,2) As BaseDebit,Null As BaseCredit,
									0.00 As DocDebitTotal,0.00 As DocCreditTotal,0.00 As BaseDebitTotal,0.00 As BaseCreditTotal,R.Id As DocumentId,R.Id As DocumentDetailId,@GUIDZero,
									R.BaseCurrency,R.ExchangeRate,@DocType,@DocSubType,RD.ServiceCompanyId,R.DocNo,Null As Nature,RD.DocumentNo,0 As IsTax,
									R.EntityId,@SystemRefNo,@DocCurrency,R.DocDate,R.DocDate,1 As RecOrder
							From Bean.Receipt(Nolock) As R
							Inner Join bean.ReceiptDetail(Nolock) As RD On RD.ReceiptId=R.Id
							Where R.Id=@SourceId And RD.ServiceCompanyId=@ServCompId And RD.ReceiptAmount<>0
							Group By R.Remarks,R.ExchangeRate,R.Id,R.BaseCurrency,R.ExchangeRate,RD.ServiceCompanyId,R.DocNo,R.EntityId,R.DocDate,RD.DocumentNo
							-- Creating Records For Interco In Journal Detail 
							Delete From @RecieptDtl_New
							Insert Into @RecieptDtl_New 
							Select ROW_NUMBER() Over (Order By RD.Id),RD.Id From Bean.ReceiptDetail(Nolock) As RD
							Inner Join Bean.Receipt(Nolock) As R On RD.ReceiptId=R.Id 
							Where R.Id=@SourceId And RD.ServiceCompanyId=@ServCompId And RD.ReceiptAmount<>0 Order By RD.RecOrder
							Set @Count=(Select Count(*) From @RecieptDtl_New)
							Set @RecOrder=2
							Set @RdtlRecCount=1
							While @Count>=@RdtlRecCount
							Begin
								Set @RecieptDtlId=(Select RecieptDtlId From @RecieptDtl_New Where S_No=@RdtlRecCount)
								Set @DocumentId=(Select DocumentId From Bean.ReceiptDetail(Nolock) Where Id=@RecieptDtlId)
								Set @IsRoundingAmount=0
								--Getting COAID By Checking Nature
								IF Exists (Select ID From Bean.ReceiptDetail(Nolock) Where id=@RecieptDtlId And Nature=@NatureTrade)
								Begin
									Set @COAID=(Select Id From Bean.ChartOfAccount(Nolock) Where CompanyId=@CompanyId And Name=@COATradeReceivables)
								End
								Else IF Exists (Select ID From Bean.ReceiptDetail(Nolock) Where id=@RecieptDtlId And Nature=@NatureOthers)
								Begin
									Set @COAID=(Select Id From Bean.ChartOfAccount(Nolock) Where CompanyId=@CompanyId And Name=@COAotherReceivables)
								End
								IF Exists (Select Id From Bean.ReceiptDetail(Nolock) Where Id=@RecieptDtlId And DocumentType=@InvoiceDocument)
								Begin
									If Exists (Select Id From Bean.Invoice(Nolock) Where Id=@DocumentId And DocumentState in (@FullyApplied,@Fullypaid))
									Begin
										Set @IsRoundingAmount=1
									End
								End
								ELSE IF Exists (Select Id From Bean.ReceiptDetail(Nolock) Where Id=@RecieptDtlId And DocumentType=@DebitNoteDocument)
								Begin
									If Exists (Select Id From Bean.DebitNote(Nolock) Where Id=@DocumentId And DocumentState in (@FullyApplied,@Fullypaid))
									Begin
										Set @IsRoundingAmount=1
									End
								End

								IF @IsRoundingAmount=1 And Exists (Select Amount From @RoundingAmountDetails Where DocumentId=@DocumentId And Amount Is Not Null And Amount<>'')
								Begin 
									Set @DocAmount=(Select Amount From @RoundingAmountDetails Where DocumentId=@DocumentId)
								End
								Else
								Begin
									Set @DocAmount=0
								End
								Insert Into Bean.JournalDetail (Id,JournalId,COAId,AccountDescription, DocDebit,DocCredit,
														 BaseDebit,BaseCredit,
														 DocDebitTotal,DocCreditTotal,BaseDebitTotal,BaseCreditTotal,DocumentId,DocumentDetailId,ItemId,BaseCurrency,ExchangeRate, DocType,DocSubType,ServiceCompanyId,DocNo,Nature,OffsetDocument,IsTax,
														EntityId, SystemRefNo, DocCurrency,DocDate, PostingDate,RecOrder 
														)
								Select NEWID(),@JournalId,@COAID,R.Remarks,Null As DocDebit,RD.ReceiptAmount As DocCredit,
									Null As BaseDebit,RD.ReceiptAmount * Round(R.ExchangeRate,2)- Isnull(@DocAmount,0) As BaseCredit,
									0.00 As DocDebitTotal,0.00 As DocCreditTotal,0.00 As BaseDebitTotal,0.00 As BaseCreditTotal,R.Id As DocumentId,RD.Id As DocumentDetailId,@GUIDZero,
									R.BaseCurrency,R.ExchangeRate,@DocType,@DocSubType,RD.ServiceCompanyId,R.DocNo,RD.Nature,RD.DocumentNo,0 As IsTax,
									R.EntityId,@SystemRefNo,@DocCurrency,R.DocDate,R.DocDate,@RecOrder As RecOrder
								From Bean.Receipt(Nolock) As R
								Inner Join bean.ReceiptDetail(Nolock) As RD On RD.ReceiptId=R.Id
								Where R.Id=@SourceId And RD.ServiceCompanyId=@ServCompId
								And RD.Id=@RecieptDtlId
								Set @RecOrder=@RecOrder+1
								Set @RdtlRecCount=@RdtlRecCount+1
							End
							Set @RecCount=@RecCount+1
						End
					End
				End
				/*BaseCurrency <> Doccurrency=BankChargesCurrency */
				Else IF @DocCurrency=@BankChargesCurrency And @BaseCurrency<>@DocCurrency
				Begin
					/* Creating Mater Record With BankReceiptAmmount In JournalDetail */
					IF Exists (Select Id From Bean.Receipt(Nolock) Where Id=@SourceId And GrandTotal<>0)
					Begin
						Insert Into Bean.JournalDetail (Id,JournalId,COAId,AccountDescription,AllowDisAllow, DocDebit, BaseDebit, DocDebitTotal,DocCreditTotal,BaseDebitTotal,BaseCreditTotal,DocumentId,DocumentDetailId,ItemId,BaseCurrency,ExchangeRate,GSTExCurrency,GSTExchangeRate,DocType,DocSubType,ServiceCompanyId,DocNo, IsTax,
										EntityId, SystemRefNo, DocCurrency,DocDate, PostingDate,RecOrder )
						Select NEWID(),@MasterJournalId,COAId,Remarks,IsDisAllow,BankReceiptAmmount,Round(BankReceiptAmmount * ExchangeRate,2),0.00 As DocDebitTotal,0.00 As DocCreditTotal,0.00 As BaseDebitTotal,0.00 As BaseCreditTotal,Id As DocumentId,@GUIDZero,@GUIDZero,
								BaseCurrency,ExchangeRate,GSTExCurrency,GSTExchangeRate,@DocType,@DocSubType,ServiceCompanyId,DocNo,0 As IsTax,
								EntityId,@MasterSystemRefNo As SystemRefNo,@BankChargesCurrency,DocDate,DocDate,@RecOrder As RecOrder
						From Bean.Receipt(Nolock) Where Id=@SourceId
					End
					Else IF Exists (Select Id From Bean.Receipt(Nolock) Where Id=@SourceId And GrandTotal=0 And BankReceiptAmmount<>0)
					Begin
						Insert Into Bean.JournalDetail (Id,JournalId,COAId,AccountDescription,AllowDisAllow, DocDebit, BaseDebit, DocDebitTotal,DocCreditTotal,BaseDebitTotal,BaseCreditTotal,DocumentId,DocumentDetailId,ItemId,BaseCurrency,ExchangeRate,GSTExCurrency,GSTExchangeRate,DocType,DocSubType,ServiceCompanyId,DocNo, IsTax,
										EntityId, SystemRefNo, DocCurrency,DocDate, PostingDate,RecOrder )
						Select NEWID(),@MasterJournalId,COAId,Remarks,IsDisAllow,Isnull(BankReceiptAmmount,0) As BankReceiptAmmount,Round(Isnull(BankReceiptAmmount,0) * ExchangeRate,2),0.00 As DocDebitTotal,0.00 As DocCreditTotal,0.00 As BaseDebitTotal,0.00 As BaseCreditTotal,Id As DocumentId,@GUIDZero,@GUIDZero,
								BaseCurrency,ExchangeRate,GSTExCurrency,GSTExchangeRate,@DocType,@DocSubType,ServiceCompanyId,DocNo,0 As IsTax,
								EntityId,@MasterSystemRefNo As SystemRefNo,@BankChargesCurrency,DocDate,DocDate,@RecOrder As RecOrder
						From Bean.Receipt(Nolock) Where Id=@SourceId
					End
					/* Creating Record in Journaldetail With Bank Charges Amount */
					If Exists(Select Id From Bean.Receipt(Nolock) Where Id=@SourceId And BankCharges Is Not Null)
					Begin
						Set @RecOrder=@RecOrder+1
						Insert Into Bean.JournalDetail (Id,JournalId,COAId,AccountDescription,AllowDisAllow,TaxId,TaxType,TaxRate,DocDebit, BaseDebit, DocDebitTotal,DocCreditTotal,BaseDebitTotal,BaseCreditTotal,DocumentId,DocumentDetailId,ItemId,BaseCurrency,ExchangeRate,GSTExCurrency,GSTExchangeRate,DocType,DocSubType,ServiceCompanyId,DocNo, IsTax,
													EntityId, SystemRefNo, DocCurrency,DocDate, PostingDate,RecOrder,GSTTaxDebit)
						Select NEWID(),@MasterJournalId,@BankCharges_COAId,Remarks,IsDisAllow,@TaxId,@TaxType,@TaxRate,BankCharges,Round(BankCharges * ExchangeRate,2),0.00 As DocDebitTotal,0.00 As DocCreditTotal,0.00 As BaseDebitTotal,0.00 As BaseCreditTotal,Id As DocumentId,Id As DocumentDetailId,@GUIDZero,
							BaseCurrency,ExchangeRate,GSTExCurrency,GSTExchangeRate,@DocType,@DocSubType,ServiceCompanyId,DocNo,0 As IsTax,
							EntityId,@MasterSystemRefNo As SystemRefNo,@BankChargesCurrency,DocDate,DocDate,@RecOrder As RecOrder,
							Case When @TaxId Is Not Null Then Round(BankCharges * Coalesce(GSTexchangerate,@DefaultExchangeRate),2) End As GSTTaxDebit
						From Bean.Receipt(Nolock)
						Where Id=@SourceId
					End
					/* Creating Record in Journaldetail With @ExcesPaidByClientAmt Amount */
					If @ExcesPaidByClientAmt Is NOt Null
					Begin
						Set @RecOrder=@RecOrder+1
						Insert Into Bean.JournalDetail (Id,JournalId,COAId,AccountDescription,AllowDisAllow, DocCredit, BaseCredit, DocDebitTotal,DocCreditTotal,BaseDebitTotal,BaseCreditTotal,DocumentId,DocumentDetailId,ItemId,BaseCurrency,ExchangeRate,GSTExCurrency,GSTExchangeRate,DocType,DocSubType,ServiceCompanyId,DocNo, IsTax,
														EntityId, SystemRefNo, DocCurrency,DocDate, PostingDate,RecOrder )
						Select NEWID(),@MasterJournalId,@ClearingReceiptsCOAID,Remarks,IsDisAllow,ExcessPaidByClientAmmount,Round(ExcessPaidByClientAmmount * ExchangeRate,2),0.00 As DocDebitTotal,0.00 As DocCreditTotal,0.00 As BaseDebitTotal,0.00 As BaseCreditTotal,Id As DocumentId,Id As DocumentDtlId,@GUIDZero,
								BaseCurrency,ExchangeRate,BankReceiptAmmountCurrency,ExchangeRate,@DocType,@DocSubType,ServiceCompanyId,DocNo,0 As IsTax,
								EntityId,@MasterSystemRefNo,@BankChargesCurrency,DocDate,DocDate,@RecOrder As RecOrder
						From Bean.Receipt(Nolock) 
						Where Id=@SourceId
					End
					/* Creating Balancing Line Items */
					Insert Into @RecieptBalLnItm
					Select RBI.Id From Bean.ReceiptBalancingItem(Nolock) As RBI
					Inner Join bean.Receipt(Nolock) As R On R.Id=RBI.ReceiptId
					Where R.Id=@SourceId Order by RecOrder
					Set @Count=(Select Count(*) From @RecieptBalLnItm)
					Set @RecCount=1
					While @Count>=@RecCount
					Begin
						Select @RecieptBalId=RecieptBalId From @RecieptBalLnItm Where S_no=@RecCount
						Select @TaxId=TaxId,@TaxRate=TaxRate From Bean.ReceiptBalancingItem(Nolock) Where Id=@RecieptBalId
						Set @RecOrder=@RecOrder+1
						Insert Into Bean.JournalDetail (Id,JournalId,COAId,AccountDescription,AllowDisAllow,TaxId,TaxType,TaxRate,DocDebit,DocCredit,
													DocTaxDebit,DocTaxCredit,BaseDebit,BaseCredit,
													BaseTaxDebit,BaseTaxCredit,DocDebitTotal,DocCreditTotal,BaseDebitTotal,BaseCreditTotal,DocumentId,DocumentDetailId,ItemId,BaseCurrency,ExchangeRate,GSTExCurrency,GSTExchangeRate,DocType,DocSubType,ServiceCompanyId,DocNo, IsTax,
													EntityId, SystemRefNo, DocCurrency,DocDate, PostingDate,RecOrder,GSTTaxDebit,GSTTaxCredit,GSTDebit,GSTCredit)
						Select NEWID(),@MasterJournalId,RBi.COAId,R.Remarks,RBI.IsDisAllow,RBI.TaxId,RBI.TaxType,Rbi.TaxRate,Case When RBI.ReciveORPay=@Pay_Dr Then RBI.DocAmount End As DocDebit,Case When RBI.ReciveORPay=@Receive_Cr Then RBI.DocAmount End As DocCredit,
							Case When RBI.ReciveORPay=@Pay_Dr Then RBI.DocTaxAmount End As DocTaxDebdit,Case When RBI.ReciveORPay=@Receive_Cr Then RBI.DocTaxAmount End As DocTaxCredit,Case When RBI.ReciveORPay=@Pay_Dr Then Round(RBI.DocAmount * R.ExchangeRate,2) End As BaseDebit,Case When RBI.ReciveORPay=@Receive_Cr Then Round(RBI.DocAmount * R.ExchangeRate,2) End As BaseCredit,
							Case When RBI.ReciveORPay=@Pay_Dr Then RBI.DocTaxAmount * Round(@MainExchangeRate,2) End As BaseTaxDebdit,Case When RBI.ReciveORPay=@Receive_Cr Then RBI.DocTaxAmount * Round(@MainExchangeRate,2) End As BaseTaxCredit,0.00 As DocDebitTotal,0.00 As DocCreditTotal,0.00 As BaseDebitTotal,0.00 As BaseCreditTotal,R.Id As DocumentId,RBI.Id As DocumentDetailId,@GUIDZero,
							R.BaseCurrency,R.ExchangeRate,R.GSTExCurrency,R.GSTExchangeRate,@DocType,@DocSubType,ServiceCompanyId,DocNo,0 As IsTax,
							EntityId,@MasterSystemRefNo,@BankChargesCurrency,DocDate,DocDate,@RecOrder As RecOrder,
							Case When RBI.ReciveORPay=@Pay_Dr Then Round(RBI.DocAmount * Coalesce(R.GSTExchangeRate,@DefaultExchangeRate),2) End As GSTTaxDebit,
							Case When RBI.ReciveORPay=@Receive_Cr Then Round(RBI.DocAmount * Coalesce(R.GSTExchangeRate,@DefaultExchangeRate),2) End As GSTTaxCredit,
							Case When RBI.ReciveORPay=@Pay_Dr Then Round(RBI.DocTaxAmount * Coalesce(R.GSTExchangeRate,@DefaultExchangeRate),2) End As GSTDebit,
							Case When RBI.ReciveORPay=@Receive_Cr Then Round(RBI.DocTaxAmount * Coalesce(R.GSTExchangeRate,@DefaultExchangeRate),2) End As GSTCredit
						From Bean.Receipt(Nolock) As R
						Inner Join bean.ReceiptBalancingItem(Nolock) As RBI On RBI.ReceiptId=R.Id
						Where R.Id=@SourceId And Rbi.Id=@RecieptBalId
						-- Creating Tax Line Items
						If @GST Is Not Null And @GST=1 And @TaxId Is Not Null And (@TaxRate Is Not Null And @TaxRate<>0)
						Begin
							Set @TaxRecCount=@RecOrder+@Count
							Insert Into Bean.JournalDetail (Id,JournalId,COAId,AccountDescription,AllowDisAllow,TaxId,TaxType,TaxRate,DocDebit,DocCredit,
									 BaseDebit,BaseCredit,
									 DocDebitTotal,DocCreditTotal,BaseDebitTotal,BaseCreditTotal,DocumentId,DocumentDetailId,ItemId,BaseCurrency,ExchangeRate,GSTExCurrency,GSTExchangeRate,DocType,DocSubType,ServiceCompanyId,DocNo, IsTax,
									EntityId, SystemRefNo, DocCurrency,DocDate, PostingDate,RecOrder )
							Select NEWID(),@MasterJournalId,@TaxPayableGST_COAID as COAId,R.Remarks,RBI.IsDisAllow,RBI.TaxId,RBI.TaxType,Rbi.TaxRate,Case When RBI.ReciveORPay=@Pay_Dr Then RBI.DocTaxAmount End As DocDebit,Case When RBI.ReciveORPay=@Receive_Cr Then RBI.DocTaxAmount End As DocCredit,
								Case When RBI.ReciveORPay=@Pay_Dr Then Round(RBI.DocTaxAmount * R.ExchangeRate,2) End As BaseDebit,Case When RBI.ReciveORPay=@Receive_Cr Then Round(RBI.DocTaxAmount * R.ExchangeRate,2) End As BaseCredit,
								0.00 As DocDebitTotal,0.00 As DocCreditTotal,0.00 As BaseDebitTotal,0.00 As BaseCreditTotal,R.Id As DocumentId,RBI.Id As DocumentDetailId,@GUIDZero,
								R.BaseCurrency,R.ExchangeRate,R.GSTExCurrency,R.GSTExchangeRate,@DocType,@DocSubType,ServiceCompanyId,DocNo,1 As IsTax,
								EntityId,@MasterSystemRefNo,@BankChargesCurrency,DocDate,DocDate,@TaxRecCount As RecOrder
							From Bean.Receipt(Nolock) As R
							Inner Join bean.ReceiptBalancingItem(Nolock) As RBI On RBI.ReceiptId=R.Id
							Where R.Id=@SourceId And Rbi.Id=@RecieptBalId
						End
						Set @RecCount=@RecCount+1
					End
					
					IF Exists (Select Id From Bean.ReceiptDetail(Nolock) Where ReceiptId=@SourceId And ReceiptAmount<>0)
					Begin
						/* Reciept Detail */
						Insert Into @InterCoRecieptDtl 
						Select RD.Id,RD.ServiceCompanyId From Bean.ReceiptDetail(Nolock) As RD
						Inner Join Bean.Receipt(Nolock) As R On RD.ReceiptId=R.Id 
						Where R.Id=@SourceId  And RD.ServiceCompanyId=@MasterServComp And RD.ReceiptAmount<>0 Order By RD.RecOrder
						Set @Count=(Select Count(*) From @InterCoRecieptDtl)
						Set @RecCount=1
						While @Count>=@RecCount
						Begin
							Set @RecOrder=@RecOrder+1
							Set @RecieptDtlId=(Select RecieptDtlId From @InterCoRecieptDtl Where S_No=@RecCount)
							Set @ServCompId=(Select ServCompId From @InterCoRecieptDtl Where S_No=@RecCount)
							Set @DocumentId=(Select DocumentId From Bean.ReceiptDetail(Nolock) Where Id=@RecieptDtlId)
							Set @IsRoundingAmount=0
							IF Exists (Select DocumentType From Bean.ReceiptDetail(Nolock) Where Id=@RecieptDtlId And DocumentType=@InvoiceDocument)
							Begin
								Set @ExchangeRate=(Select ExchangeRate From Bean.Invoice(Nolock) Where Id=@DocumentId)
								IF Exists(Select Id From Bean.Invoice(Nolock) Where Id=@DocumentId And DocumentState In (@FullyApplied,@Fullypaid))
								Begin
									Set @IsRoundingAmount=1
								End
							End
							Else IF Exists (Select DocumentType From Bean.ReceiptDetail(Nolock) Where Id=@RecieptDtlId And DocumentType=@DebitNoteDocument)
							Begin
								Set @ExchangeRate=(Select ExchangeRate From Bean.DebitNote(Nolock) Where Id=@DocumentId)
								IF Exists(Select Id From Bean.DebitNote(Nolock) Where Id=@DocumentId And DocumentState In (@FullyApplied,@Fullypaid))
								Begin
									Set @IsRoundingAmount=1
								End
							End
							-- Getting COAID By Checking Nature
							IF Exists (Select ID From Bean.ReceiptDetail(Nolock) Where id=@RecieptDtlId And Nature=@NatureTrade)
							Begin
								Set @COAID=(Select Id From Bean.ChartOfAccount(Nolock) Where CompanyId=@CompanyId And Name=@COATradeReceivables)
							End
							Else IF Exists (Select ID From Bean.ReceiptDetail(Nolock) Where id=@RecieptDtlId And Nature=@NatureOthers)
							Begin
								Set @COAID=(Select Id From Bean.ChartOfAccount(Nolock) Where CompanyId=@CompanyId And Name=@COAotherReceivables)
							End
							
							IF @IsRoundingAmount=1 And Exists (Select Amount From @RoundingAmountDetails Where DocumentId=@DocumentId And Amount Is Not Null And Amount<>'')
							Begin
								Set @DocAmount=(Select Amount From @RoundingAmountDetails Where DocumentId=@DocumentId)
							End
							Else
							Begin
								Set @DocAmount=0
							End
							Insert Into Bean.JournalDetail (Id,JournalId,COAId,AccountDescription, DocDebit,DocCredit,
															 BaseDebit,BaseCredit,
															 DocDebitTotal,DocCreditTotal,BaseDebitTotal,BaseCreditTotal,DocumentId,DocumentDetailId,ItemId,BaseCurrency,ExchangeRate, DocType,DocSubType,ServiceCompanyId,DocNo,Nature,OffsetDocument,IsTax,
															EntityId, SystemRefNo, DocCurrency,DocDate, PostingDate,RecOrder 
															)
							Select NEWID(),@MasterJournalId,@COAID,R.Remarks,Null As DocDebit,RD.ReceiptAmount As DocCredit,
								Null As BaseDebit,Round(RD.ReceiptAmount * @ExchangeRate,2)- Isnull(@DocAmount,0) As BaseCredit,
								0.00 As DocDebitTotal,0.00 As DocCreditTotal,0.00 As BaseDebitTotal,0.00 As BaseCreditTotal,R.Id As DocumentId,RD.Id As DocumentDetailId,@GUIDZero,
								R.BaseCurrency,R.ExchangeRate,@DocType,@DocSubType,@MasterServComp As ServiceCompanyId,R.DocNo,RD.Nature,RD.DocumentNo,0 As IsTax,
								EntityId,@MasterSystemRefNo,@BankChargesCurrency,DocDate,DocDate,@RecOrder As RecOrder
							From Bean.Receipt(Nolock) As R
							Inner Join bean.ReceiptDetail(Nolock) As RD On RD.ReceiptId=R.Id
							Where R.Id=@SourceId And RD.Id=@RecieptDtlId
							-- ExchangeGainOrLossRealised
							IF @MainExchangeRate-@ExchangeRate<>0
							Begin
								Set @RecOrder=@RecOrder+1
								Insert Into Bean.JournalDetail (Id,JournalId,COAId,AccountDescription, DocDebit,DocCredit,
																 BaseDebit,BaseCredit,
																 DocDebitTotal,DocCreditTotal,BaseDebitTotal,BaseCreditTotal,DocumentId,DocumentDetailId,ItemId,BaseCurrency,ExchangeRate, DocType,DocSubType,ServiceCompanyId,DocNo,Nature,OffsetDocument,IsTax,
																EntityId, SystemRefNo, DocCurrency,DocDate, PostingDate,RecOrder 
																)
								Select NEWID(),@MasterJournalId,@ExchangeGainOrLossCOAID,R.Remarks,Null As DocDebit,Null As DocCredit,
									Case When (@MainExchangerate-@ExchangeRate) <0 Then ABS(Round((@MainExchangerate-@ExchangeRate)*RD.ReceiptAmount,2))  End As BaseDebit,
									Case When (@MainExchangerate-@ExchangeRate)>0 Then ABS(Round((@MainExchangerate-@ExchangeRate)*RD.ReceiptAmount,2)) End As BaseCredit,
									0.00 As DocDebitTotal,0.00 As DocCreditTotal,0.00 As BaseDebitTotal,0.00 As BaseCreditTotal,R.Id As DocumentId,RD.Id As DocumentDetailId,@GUIDZero,
									R.BaseCurrency,R.ExchangeRate,@DocType,@DocSubType,@MasterServComp As ServiceCompanyId,R.DocNo,RD.Nature,RD.DocumentNo,0 As IsTax,
									EntityId,@MasterSystemRefNo,@BankChargesCurrency,DocDate,DocDate,@RecOrder As RecOrder
								From Bean.Receipt(Nolock) As R
								Inner Join bean.ReceiptDetail(Nolock) As RD On RD.ReceiptId=R.Id
								Where R.Id=@SourceId And RD.Id=@RecieptDtlId
							End
							Set @RecCount=@RecCount+1
						End
						Set @IntMastSysRefNo=@MasterSystemRefNo
						-- Looping Service Company Id's To Create Journal
						Insert Into @ServCompaIdTbl
						Select Distinct ServiceCompanyId From Bean.ReceiptDetail(Nolock) Where ReceiptId=@SourceId And ServiceCompanyId<>@MasterServComp And ReceiptAmount<>0
						Set @ServCompaIdTblCnt=(Select Count(S_No) From @ServCompaIdTbl)
						Set @RecCount=1
						While @ServCompaIdTblCnt>=@RecCount
						Begin
							Set @RecOrder=@RecOrder+1
							Select @ServCompId=SerCompId From @ServCompaIdTbl Where S_No=@RecCount
							Set @IntroCompCOAID=(Select COA.Id From Bean.ChartOfAccount(Nolock) As COA 
												Inner Join Bean.AccountType(Nolock) As ACT On ACT.Id=COA.AccountTypeId
												Where ACT.CompanyId=@CompanyId And ACT.Name=@IntercompClearingCOAName And COA.SubsidaryCompanyId=@ServCompId)
							-- I/C Records In Main Journal
							Insert Into Bean.JournalDetail (Id,JournalId,COAId,AccountDescription, DocDebit,DocCredit,
															 BaseDebit,BaseCredit,
															 DocDebitTotal,DocCreditTotal,BaseDebitTotal,BaseCreditTotal,DocumentId,DocumentDetailId,ItemId,BaseCurrency,ExchangeRate, DocType,DocSubType,ServiceCompanyId,DocNo,Nature,OffsetDocument,IsTax,
															EntityId, SystemRefNo, DocCurrency,DocDate, PostingDate,RecOrder 
															)
							Select NEWID(),@MasterJournalId,@IntroCompCOAID,R.Remarks,Null As DocDebit,Sum(Isnull(RD.ReceiptAmount,0)) As DocCredit,
								Null As BaseDebit,Round(Sum(Isnull(RD.ReceiptAmount,0)) * R.ExchangeRate,2) As BaseCredit,
								0.00 As DocDebitTotal,0.00 As DocCreditTotal,0.00 As BaseDebitTotal,0.00 As BaseCreditTotal,R.Id As DocumentId,@GUIDZero As DocumentDetailId,@GUIDZero,
								R.BaseCurrency,R.ExchangeRate,@DocType,@DocSubType,@MasterServComp As ServiceCompanyId,R.DocNo,Null As Nature,R.DocNo,0 As IsTax,
								R.EntityId,@IntMastSysRefNo,@BankChargesCurrency,R.DocDate,R.DocDate,@RecOrder As RecOrder
							From Bean.Receipt(Nolock) As R
							Inner Join bean.ReceiptDetail(Nolock) As RD On RD.ReceiptId=R.Id
							Where R.Id=@SourceId And RD.ServiceCompanyId=@ServCompId
							Group By R.Remarks,R.ExchangeRate,R.Id,R.BaseCurrency,R.DocNo,R.EntityId,R.DocDate
							Set @SysRefNum_Incr=@SysRefNum_Incr+1
							Set @SystemRefNo=CONCAT(@DocNo,'-JV',@SysRefNum_Incr)
							Set @JournalId=NEWID()

							Insert Into Bean.Journal (Id,CompanyId,DocDate,DocType,DocSubType,DocNo,ServiceCompanyId,SystemReferenceNo,IsNoSupportingDocs,NoSupportingDocument,DocCurrency,ExchangeRate,ExCurrency,ExDurationFrom,GSTExchangeRate,GSTExCurrency,GSTTotalAmount,DocumentState,IsNoSupportingDocument,IsGstSettings,IsMultiCurrency,IsAllowableNonAllowable,IsGSTCurrencyRateChanged,Remarks,UserCreated,CreatedDate,Status,DocumentDescription,CreationType,GrandDocDebitTotal,GrandDocCreditTotal,GrandBaseDebitTotal,
														GrandBaseCreditTotal,EntityId,EntityType,PostingDate,COAId,ModeOfReceipt,BankReceiptAmmount,ExcessPaidByClientAmmount,BalancingItemReciveCRAmount,  BalancingItemPayDRAmount,ReceiptApplicationAmmount,DocumentId, BankClearingDate ,IsBalancing,ISAllowDisAllow, IsShow, ActualSysRefNo 
														,IsSegmentReporting,TransferRefNo
													 )
							Select @JournalId,@CompanyId,DocDate,@DocType,@DocSubType,DocNo,@ServCompId As ServiceCompanyId,@SystemRefNo As SystemRefNo,IsNoSupportingDocument,NoSupportingDocs,DocCurrency,ExchangeRate,ExCurrency,ExDurationFrom,GSTExchangeRate,GSTExCurrency,Isnull(GSTTotalAmount,0),DocumentState,NoSupportingDocs,IsGstSettings,IsMultiCurrency,IsAllowableDisallowable,IsGSTCurrencyRateChanged,Remarks,@UserCreated,@CreatedDate,Status,Remarks As DocDescription,@UserCreated,GrandTotal,0.00 As GrandDocCreditTotal,GrandTotal * Round(ExchangeRate,2) As GrandBaseDebitTotal,
									0.00 As GrandBaseCreditTotal,EntityId,EntityType,DocDate As PostingDate,@IntroCompCOAID As COAId,ModeOfReceipt,0.00 As BankReceiptAmmount,0.00 As ExcessPaidByClientAmmount,0.00 As BalancingItemReciveCRAmount,0.00 As BalancingItemPayDRAmount,0.00 As ReceiptApplicationAmmount,Id As DocumentId,BankClearingDate,0 As IsBalancing,IsDisAllow,1 As IsShow,DocNo As ActualSysRefNo,0 As IsSegmentReporting,ReceiptRefNo
							From Bean.Receipt(Nolock) Where CompanyId=@CompanyId And Id=@SourceId

							Insert Into Bean.JournalDetail (Id,JournalId,COAId,AccountDescription, DocDebit,DocCredit,
													 BaseDebit,BaseCredit,
													 DocDebitTotal,DocCreditTotal,BaseDebitTotal,BaseCreditTotal,DocumentId,DocumentDetailId,ItemId,BaseCurrency,ExchangeRate, DocType,DocSubType,ServiceCompanyId,DocNo,Nature,OffsetDocument,IsTax,
													EntityId, SystemRefNo, DocCurrency,DocDate, PostingDate,RecOrder 
													)
							Select NEWID(),@JournalId,@MainInterCoServCompCOAID,R.Remarks,Sum(Isnull(RD.ReceiptAmount,0)) As DocDebit,Null As DocCredit,
									Round(Sum(Isnull(RD.ReceiptAmount,0)) * R.ExchangeRate,2) As BaseDebit,Null As BaseCredit,
									0.00 As DocDebitTotal,0.00 As DocCreditTotal,0.00 As BaseDebitTotal,0.00 As BaseCreditTotal,R.Id As DocumentId,R.Id As DocumentDetailId,@GUIDZero,
									R.BaseCurrency,R.ExchangeRate,@DocType,@DocSubType,RD.ServiceCompanyId,R.DocNo,Null As Nature,RD.DocumentNo,0 As IsTax,
									R.EntityId,@SystemRefNo,@DocCurrency,R.DocDate,R.DocDate,1 As RecOrder
							From Bean.Receipt(Nolock) As R
							Inner Join bean.ReceiptDetail(Nolock) As RD On RD.ReceiptId=R.Id
							Where R.Id=@SourceId And RD.ServiceCompanyId=@ServCompId And RD.ReceiptAmount<>0
							Group By R.Remarks,R.ExchangeRate,R.Id,R.BaseCurrency,R.ExchangeRate,RD.ServiceCompanyId,R.DocNo,R.EntityId,R.DocDate,RD.DocumentNo
							-- Creating Records For Interco In Journal Detail
							Delete From @RecieptDtl_New
							Insert Into @RecieptDtl_New 
							Select ROW_NUMBER() Over (Order By RD.Id),RD.Id From Bean.ReceiptDetail(Nolock) As RD
							Inner Join Bean.Receipt(Nolock) As R On RD.ReceiptId=R.Id 
							Where R.Id=@SourceId And RD.ServiceCompanyId=@ServCompId And RD.ReceiptAmount<>0 Order By RD.RecOrder
							Set @Count=(Select Count(*) From @RecieptDtl_New)
							Set @RecOrder=2
							Set @RdtlRecCount=1
							While @Count>=@RdtlRecCount
							Begin
								Set @RecieptDtlId=(Select RecieptDtlId From @RecieptDtl_New Where S_No=@RdtlRecCount)
								Set @DocumentId=(Select DocumentId From Bean.ReceiptDetail(Nolock) Where Id=@RecieptDtlId)
								Set @IsRoundingAmount=0
								IF Exists (Select DocumentType From Bean.ReceiptDetail(Nolock) Where Id=@RecieptDtlId And DocumentType=@InvoiceDocument)
								Begin
									Set @ExchangeRate=(Select ExchangeRate From Bean.Invoice(Nolock) Where Id=@DocumentId)
									IF Exists(Select Id From Bean.Invoice(Nolock) Where Id=@DocumentId And DocumentState In (@FullyApplied,@Fullypaid))
									Begin
										Set @IsRoundingAmount=1
									End
								End
								Else IF Exists (Select DocumentType From Bean.ReceiptDetail(Nolock) Where Id=@RecieptDtlId And DocumentType=@DebitNoteDocument)
								Begin
									Set @ExchangeRate=(Select ExchangeRate From Bean.DebitNote(Nolock) Where Id=@DocumentId)
									IF Exists(Select Id From Bean.DebitNote(Nolock) Where Id=@DocumentId And DocumentState In (@FullyApplied,@Fullypaid))
									Begin
										Set @IsRoundingAmount=1
									End
								End
								--Getting COAID By Checking Nature
								IF Exists (Select ID From Bean.ReceiptDetail(Nolock) Where id=@RecieptDtlId And Nature=@NatureTrade)
								Begin
									Set @COAID=(Select Id From Bean.ChartOfAccount(Nolock) Where CompanyId=@CompanyId And Name=@COATradeReceivables)
								End
								Else IF Exists (Select ID From Bean.ReceiptDetail(Nolock) Where id=@RecieptDtlId And Nature=@NatureOthers)
								Begin
									Set @COAID=(Select Id From Bean.ChartOfAccount(Nolock) Where CompanyId=@CompanyId And Name=@COAotherReceivables)
								End
								IF @IsRoundingAmount=1 And Exists (Select Amount From @RoundingAmountDetails Where DocumentId=@DocumentId And Amount Is Not Null And Amount<>'')
								Begin
									Set @DocAmount=(Select Amount From @RoundingAmountDetails Where DocumentId=@DocumentId)
								End
								Else
								Begin
									Set @DocAmount=0
								End

								Insert Into Bean.JournalDetail (Id,JournalId,COAId,AccountDescription, DocDebit,DocCredit,
														 BaseDebit,BaseCredit,
														 DocDebitTotal,DocCreditTotal,BaseDebitTotal,BaseCreditTotal,DocumentId,DocumentDetailId,ItemId,BaseCurrency,ExchangeRate, DocType,DocSubType,ServiceCompanyId,DocNo,Nature,OffsetDocument,IsTax,
														EntityId, SystemRefNo, DocCurrency,DocDate, PostingDate,RecOrder 
														)
								Select NEWID(),@JournalId,@COAID,R.Remarks,Null As DocDebit,RD.ReceiptAmount As DocCredit,
									Null As BaseDebit,Round(RD.ReceiptAmount * @ExchangeRate,2)- Isnull(@DocAmount,0) As BaseCredit,
									0.00 As DocDebitTotal,0.00 As DocCreditTotal,0.00 As BaseDebitTotal,0.00 As BaseCreditTotal,R.Id As DocumentId,RD.Id As DocumentDetailId,@GUIDZero,
									R.BaseCurrency,@ExchangeRate As ExchangeRate,@DocType,@DocSubType,RD.ServiceCompanyId,R.DocNo,RD.Nature,RD.DocumentNo,0 As IsTax,
									R.EntityId,@SystemRefNo,@DocCurrency,R.DocDate,R.DocDate,@RecOrder As RecOrder
								From Bean.Receipt(Nolock) As R
								Inner Join bean.ReceiptDetail(Nolock) As RD On RD.ReceiptId=R.Id
								Where R.Id=@SourceId And RD.ServiceCompanyId=@ServCompId
								And RD.Id=@RecieptDtlId
								IF @SysCalExchangerate-@ExchangeRate<>0
								Begin
									Set @RecOrder=@RecOrder+1
									-- ExchangeGainOrLossRealised
									Insert Into Bean.JournalDetail (Id,JournalId,COAId,AccountDescription, DocDebit,DocCredit,
																	 BaseDebit,BaseCredit,
																	 DocDebitTotal,DocCreditTotal,BaseDebitTotal,BaseCreditTotal,DocumentId,DocumentDetailId,ItemId,BaseCurrency,ExchangeRate, DocType,DocSubType,ServiceCompanyId,DocNo,Nature,OffsetDocument,IsTax,
																	EntityId, SystemRefNo, DocCurrency,DocDate, PostingDate,RecOrder 
																	)
									Select NEWID(),@JournalId,@ExchangeGainOrLossCOAID,R.Remarks,Null As DocDebit,Null As DocCredit,
										Case When (@SysCalExchangerate-@ExchangeRate) <0 Then ABS(Round((@SysCalExchangerate-@ExchangeRate)*RD.ReceiptAmount,2))  End As BaseDebit,
									Case When (@SysCalExchangerate-@ExchangeRate)>0 Then ABS(Round((@SysCalExchangerate-@ExchangeRate)*RD.ReceiptAmount,2)) End As BaseCredit,
										0.00 As DocDebitTotal,0.00 As DocCreditTotal,0.00 As BaseDebitTotal,0.00 As BaseCreditTotal,R.Id As DocumentId,RD.Id As DocumentDetailId,@GUIDZero,
										R.BaseCurrency,R.ExchangeRate,@DocType,@DocSubType,RD.ServiceCompanyId,R.DocNo,RD.Nature,RD.DocumentNo,0 As IsTax,
										EntityId,R.SystemRefNo,@DocCurrency,DocDate,DocDate,@RecOrder As RecOrder
									From Bean.Receipt(Nolock) As R
									Inner Join bean.ReceiptDetail(Nolock) As RD On RD.ReceiptId=R.Id
									Where R.Id=@SourceId And RD.Id=@RecieptDtlId
								End
								Set @RecOrder=@RecOrder+1
								Set @RdtlRecCount=@RdtlRecCount+1
							End
							Set @RecCount=@RecCount+1
						End
					End		
				End
				Else IF @DocCurrency<>@BankChargesCurrency And @BaseCurrency=@DocCurrency
				Begin
					/* Creating Mater Record With BankReceiptAmmount In JournalDetail */
					IF Exists (Select Id From Bean.Receipt(Nolock) Where Id=@SourceId And GrandTotal<>0)
					Begin
						Insert Into Bean.JournalDetail (Id,JournalId,COAId,AccountDescription,AllowDisAllow, DocDebit, BaseDebit, DocDebitTotal,DocCreditTotal,BaseDebitTotal,BaseCreditTotal,DocumentId,DocumentDetailId,ItemId,BaseCurrency,ExchangeRate,GSTExCurrency,GSTExchangeRate,DocType,DocSubType,ServiceCompanyId,DocNo, IsTax,
										EntityId, SystemRefNo, DocCurrency,DocDate, PostingDate,RecOrder )
						Select NEWID(),@MasterJournalId,COAId,Remarks,IsDisAllow,Isnull(BankReceiptAmmount,0) As BankReceiptAmmount,Round(Isnull(BankReceiptAmmount,0) * @SysCalExchangerate,2),0.00 As DocDebitTotal,0.00 As DocCreditTotal,0.00 As BaseDebitTotal,0.00 As BaseCreditTotal,Id As DocumentId,@GUIDZero,@GUIDZero,
								BaseCurrency,@SysCalExchangerate As ExchangeRate,GSTExCurrency,GSTExchangeRate,@DocType,@DocSubType,ServiceCompanyId,DocNo,0 As IsTax,
								EntityId,@MasterSystemRefNo As SystemRefNo,@BankChargesCurrency,DocDate,DocDate,@RecOrder As RecOrder
						From Bean.Receipt(Nolock) Where Id=@SourceId
					End
					Else IF Exists (Select Id From Bean.Receipt(Nolock) Where Id=@SourceId And GrandTotal=0 And BankReceiptAmmount<>0)
					Begin
						Insert Into Bean.JournalDetail (Id,JournalId,COAId,AccountDescription,AllowDisAllow, DocDebit, BaseDebit, DocDebitTotal,DocCreditTotal,BaseDebitTotal,BaseCreditTotal,DocumentId,DocumentDetailId,ItemId,BaseCurrency,ExchangeRate,GSTExCurrency,GSTExchangeRate,DocType,DocSubType,ServiceCompanyId,DocNo, IsTax,
										EntityId, SystemRefNo, DocCurrency,DocDate, PostingDate,RecOrder)
						Select NEWID(),@MasterJournalId,COAId,Remarks,IsDisAllow,Isnull(BankReceiptAmmount,0) As BankReceiptAmmount,Round(Isnull(BankReceiptAmmount,0) * @SysCalExchangerate,2),0.00 As DocDebitTotal,0.00 As DocCreditTotal,0.00 As BaseDebitTotal,0.00 As BaseCreditTotal,Id As DocumentId,@GUIDZero,@GUIDZero,
								BaseCurrency,@SysCalExchangerate As ExchangeRate,GSTExCurrency,GSTExchangeRate,@DocType,@DocSubType,ServiceCompanyId,DocNo,0 As IsTax,
								EntityId,@MasterSystemRefNo As SystemRefNo,@BankChargesCurrency,DocDate,DocDate,@RecOrder As RecOrder
						From Bean.Receipt(Nolock) Where Id=@SourceId
					End
					/* Creating Record in Journaldetail With Bank Charges Amount */
					If Exists(Select Id From Bean.Receipt(Nolock) Where Id=@SourceId And BankCharges Is Not Null)
					Begin
						Set @RecOrder=@RecOrder+1
						Insert Into Bean.JournalDetail (Id,JournalId,COAId,AccountDescription,AllowDisAllow,TaxId,TaxType,TaxRate,DocDebit, BaseDebit, DocDebitTotal,DocCreditTotal,BaseDebitTotal,BaseCreditTotal,DocumentId,DocumentDetailId,ItemId,BaseCurrency,ExchangeRate,GSTExCurrency,GSTExchangeRate,DocType,DocSubType,ServiceCompanyId,DocNo, IsTax,
													EntityId, SystemRefNo, DocCurrency,DocDate, PostingDate,RecOrder,GSTTaxDebit)
						Select NEWID(),@MasterJournalId,@BankCharges_COAId,Remarks,IsDisAllow,@TaxId,@TaxType,@TaxRate,BankCharges,Round(BankCharges * @SysCalExchangerate,2),0.00 As DocDebitTotal,0.00 As DocCreditTotal,0.00 As BaseDebitTotal,0.00 As BaseCreditTotal,Id As DocumentId,Id As DocumentDetailId,@GUIDZero,
							BaseCurrency,@SysCalExchangerate As ExchangeRate,GSTExCurrency,GSTExchangeRate,@DocType,@DocSubType,ServiceCompanyId,DocNo,0 As IsTax,
							EntityId,@MasterSystemRefNo As SystemRefNo,@BankChargesCurrency,DocDate,DocDate,@RecOrder As RecOrder,
							Case When @TaxId Is Not Null Then Round(BankCharges * Coalesce(GSTexchangerate,@DefaultExchangeRate),2) End As GSTTaxDebit
						From Bean.Receipt(Nolock) 
						Where Id=@SourceId
					End
					/* Creating Record in Journaldetail With @ExcesPaidByClientAmt Amount */
					If @ExcesPaidByClientAmt Is NOt Null
					Begin
						Set @RecOrder=@RecOrder+1
						Insert Into Bean.JournalDetail (Id,JournalId,COAId,AccountDescription,AllowDisAllow, DocCredit, BaseCredit, DocDebitTotal,DocCreditTotal,BaseDebitTotal,BaseCreditTotal,DocumentId,DocumentDetailId,ItemId,BaseCurrency,ExchangeRate,GSTExCurrency,GSTExchangeRate,DocType,DocSubType,ServiceCompanyId,DocNo, IsTax,
														EntityId, SystemRefNo, DocCurrency,DocDate, PostingDate,RecOrder )
						Select NEWID(),@MasterJournalId,@ClearingReceiptsCOAID,Remarks,IsDisAllow,ExcessPaidByClientAmmount,Round(ExcessPaidByClientAmmount * @SysCalExchangerate,2),0.00 As DocDebitTotal,0.00 As DocCreditTotal,0.00 As BaseDebitTotal,0.00 As BaseCreditTotal,Id As DocumentId,Id As DocumentDtlId,@GUIDZero,
								BaseCurrency,@SysCalExchangerate As ExchangeRate,BankReceiptAmmountCurrency,ExchangeRate,@DocType,@DocSubType,ServiceCompanyId,DocNo,0 As IsTax,
								EntityId,@MasterSystemRefNo,@BankChargesCurrency,DocDate,DocDate,@RecOrder As RecOrder
						From Bean.Receipt(Nolock) 
						Where Id=@SourceId
					End
					/* Creating Balancing Line Items */
					Insert Into @RecieptBalLnItm
					Select RBI.Id From Bean.ReceiptBalancingItem(Nolock) As RBI
					Inner Join bean.Receipt(Nolock) As R On R.Id=RBI.ReceiptId
					Where R.Id=@SourceId Order by RecOrder
					Set @Count=(Select Count(*) From @RecieptBalLnItm)
					Set @RecCount=1
					While @Count>=@RecCount
					Begin
						Select @RecieptBalId=RecieptBalId From @RecieptBalLnItm Where S_no=@RecCount
						Select @TaxId=TaxId,@TaxRate=TaxRate From Bean.ReceiptBalancingItem(Nolock) Where Id=@RecieptBalId
						Set @RecOrder=@RecOrder+1
						Insert Into Bean.JournalDetail (Id,JournalId,COAId,AccountDescription,AllowDisAllow,TaxId,TaxType,TaxRate,DocDebit,DocCredit,
													DocTaxDebit,DocTaxCredit,BaseDebit,BaseCredit,
													BaseTaxDebit,BaseTaxCredit,DocDebitTotal,DocCreditTotal,BaseDebitTotal,BaseCreditTotal,DocumentId,DocumentDetailId,ItemId,BaseCurrency,ExchangeRate,GSTExCurrency,GSTExchangeRate,DocType,DocSubType,ServiceCompanyId,DocNo, IsTax,
													EntityId, SystemRefNo, DocCurrency,DocDate, PostingDate,RecOrder,GSTTaxDebit,GSTTaxCredit,GSTDebit,GSTCredit)
						Select NEWID(),@MasterJournalId,RBi.COAId,R.Remarks,RBI.IsDisAllow,RBI.TaxId,RBI.TaxType,Rbi.TaxRate,Case When RBI.ReciveORPay=@Pay_Dr Then RBI.DocAmount End As DocDebit,Case When RBI.ReciveORPay=@Receive_Cr Then RBI.DocAmount End As DocCredit,
							Case When RBI.ReciveORPay=@Pay_Dr Then RBI.DocTaxAmount End As DocTaxDebdit,Case When RBI.ReciveORPay=@Receive_Cr Then RBI.DocTaxAmount End As DocTaxCredit,Case When RBI.ReciveORPay=@Pay_Dr Then Round(RBI.DocAmount * @SysCalExchangerate,2) End As BaseDebit,Case When RBI.ReciveORPay=@Receive_Cr Then Round(RBI.DocAmount * @SysCalExchangerate,2) End As BaseCredit,
							Case When RBI.ReciveORPay=@Pay_Dr Then Round(RBI.DocTaxAmount * @SysCalExchangerate,2) End As BaseTaxDebdit,Case When RBI.ReciveORPay=@Receive_Cr Then Round(RBI.DocTaxAmount * @SysCalExchangerate,2) End As BaseTaxCredit,0.00 As DocDebitTotal,0.00 As DocCreditTotal,0.00 As BaseDebitTotal,0.00 As BaseCreditTotal,R.Id As DocumentId,RBI.Id As DocumentDetailId,@GUIDZero,
							R.BaseCurrency,@SysCalExchangerate As ExchangeRate,R.GSTExCurrency,R.GSTExchangeRate,@DocType,@DocSubType,ServiceCompanyId,DocNo,0 As IsTax,
							EntityId,@MasterSystemRefNo,@BankChargesCurrency,DocDate,DocDate,@RecOrder As RecOrder,
							Case When RBI.ReciveORPay=@Pay_Dr Then Round(RBI.DocAmount * Coalesce(R.GSTExchangeRate,@DefaultExchangeRate),2) End As GSTTaxDebit,
							Case When RBI.ReciveORPay=@Receive_Cr Then Round(RBI.DocAmount * Coalesce(R.GSTExchangeRate,@DefaultExchangeRate),2) End As GSTTaxCredit,
							Case When RBI.ReciveORPay=@Pay_Dr Then Round(RBI.DocTaxAmount * Coalesce(R.GSTExchangeRate,@DefaultExchangeRate),2) End As GSTDebit,
							Case When RBI.ReciveORPay=@Receive_Cr Then Round(RBI.DocTaxAmount * Coalesce(R.GSTExchangeRate,@DefaultExchangeRate),2) End As GSTCredit
						From Bean.Receipt(Nolock) As R
						Inner Join bean.ReceiptBalancingItem(Nolock) As RBI On RBI.ReceiptId=R.Id
						Where R.Id=@SourceId And Rbi.Id=@RecieptBalId
						-- Creating Tax Line Items
						If @GST Is Not Null And @GST=1 And @TaxId Is Not Null And (@TaxRate Is Not Null And @TaxRate<>0)
						Begin
							Set @TaxRecCount=@RecOrder+@Count
							Insert Into Bean.JournalDetail (Id,JournalId,COAId,AccountDescription,AllowDisAllow,TaxId,TaxType,TaxRate,DocDebit,DocCredit,
									 BaseDebit,BaseCredit,
									 DocDebitTotal,DocCreditTotal,BaseDebitTotal,BaseCreditTotal,DocumentId,DocumentDetailId,ItemId,BaseCurrency,ExchangeRate,GSTExCurrency,GSTExchangeRate,DocType,DocSubType,ServiceCompanyId,DocNo, IsTax,
									EntityId, SystemRefNo, DocCurrency,DocDate, PostingDate,RecOrder )
							Select NEWID(),@MasterJournalId,@TaxPayableGST_COAID as COAId,R.Remarks,RBI.IsDisAllow,RBI.TaxId,RBI.TaxType,Rbi.TaxRate,Case When RBI.ReciveORPay=@Pay_Dr Then RBI.DocTaxAmount End As DocDebit,Case When RBI.ReciveORPay=@Receive_Cr Then RBI.DocTaxAmount End As DocCredit,
								Case When RBI.ReciveORPay=@Pay_Dr Then Round(RBI.DocTaxAmount * @SysCalExchangerate,2) End As BaseDebit,Case When RBI.ReciveORPay=@Receive_Cr Then Round(RBI.DocTaxAmount * @SysCalExchangerate,2) End As BaseCredit,
								0.00 As DocDebitTotal,0.00 As DocCreditTotal,0.00 As BaseDebitTotal,0.00 As BaseCreditTotal,R.Id As DocumentId,RBI.Id As DocumentDetailId,@GUIDZero,
								R.BaseCurrency,@SysCalExchangerate As ExchangeRate,R.GSTExCurrency,R.GSTExchangeRate,@DocType,@DocSubType,ServiceCompanyId,DocNo,1 As IsTax,
								EntityId,@MasterSystemRefNo,@BankChargesCurrency,DocDate,DocDate,@TaxRecCount As RecOrder
							From Bean.Receipt(Nolock) As R
							Inner Join bean.ReceiptBalancingItem(Nolock) As RBI On RBI.ReceiptId=R.Id
							Where R.Id=@SourceId And Rbi.Id=@RecieptBalId
						End
						Set @RecCount=@RecCount+1
					End
					IF Exists (Select Id From Bean.ReceiptDetail(Nolock) Where ReceiptId=@SourceId And ReceiptAmount<>0)
					Begin
						-- Clearing Reciepts Main Journal
						Set @ClearingRecieptAmount=(Select SUM(Isnull(DocDebit,0))-Sum(Isnull(DocCredit,0)) From Bean.JournalDetail(Nolock) Where JournalId=@MasterJournalId)
						Set @RecOrder=@RecOrder+1
						Insert Into Bean.JournalDetail (Id,JournalId,COAId,AccountDescription, DocDebit,DocCredit,
														 BaseDebit,BaseCredit,
														 DocDebitTotal,DocCreditTotal,BaseDebitTotal,BaseCreditTotal,DocumentId,DocumentDetailId,ItemId,BaseCurrency,ExchangeRate, DocType,DocSubType,ServiceCompanyId,DocNo, IsTax,
														EntityId, SystemRefNo, DocCurrency,DocDate, PostingDate,RecOrder 
														)
						Select NEWID(),@MasterJournalId,@ClearingReceiptsCOAID,R.Remarks,Null As DocDebit,Abs(@ClearingRecieptAmount) As DocCredit,
							Null As BaseDebit,ABS(Round(@ClearingRecieptAmount * @SysCalExchangerate,2)) As BaseCredit,
							0.00 As DocDebitTotal,0.00 As DocCreditTotal,0.00 As BaseDebitTotal,0.00 As BaseCreditTotal,R.Id As DocumentId,R.Id As DocumentDetailId,@GUIDZero,
							R.BaseCurrency,R.ExchangeRate, @DocType,@DocSubType,ServiceCompanyId,DocNo,0 As IsTax,
							EntityId,@MasterSystemRefNo,@BankChargesCurrency,DocDate,DocDate,@RecOrder As RecOrder
						From Bean.Receipt(Nolock) As R
						Where R.Id=@SourceId
						--Creating Journal For Master Record With DifferentCurrency
						Set @IntMastJournalId=NEWID()
						Set @RecOrder=1
						Set @SysRefNum_Incr=@SysRefNum_Incr+1
						Set @IntMastSysRefNo=CONCAT(@DocNo,'-JV',@SysRefNum_Incr)
						Insert Into Bean.Journal (Id,CompanyId,DocDate,DocType,DocSubType,DocNo,ServiceCompanyId,SystemReferenceNo,IsNoSupportingDocs,NoSupportingDocument,DocCurrency,ExchangeRate,ExCurrency,ExDurationFrom,GSTExchangeRate,GSTExCurrency,GSTTotalAmount,DocumentState,IsNoSupportingDocument,IsGstSettings,IsMultiCurrency,IsAllowableNonAllowable,IsGSTCurrencyRateChanged,Remarks,UserCreated,CreatedDate,Status,DocumentDescription,CreationType,GrandDocDebitTotal,GrandDocCreditTotal,GrandBaseDebitTotal,
													GrandBaseCreditTotal,EntityId,EntityType,PostingDate,COAId,ModeOfReceipt,BankReceiptAmmount,ExcessPaidByClientAmmount,BalancingItemReciveCRAmount,  BalancingItemPayDRAmount,ReceiptApplicationAmmount,DocumentId, BankClearingDate ,IsBalancing,ISAllowDisAllow, IsShow, ActualSysRefNo 
													,IsSegmentReporting,TransferRefNo
												 )
						Select @IntMastJournalId,@CompanyId,DocDate,@DocType,@DocSubType,DocNo,ServiceCompanyId,@IntMastSysRefNo As SystemRefNo,IsNoSupportingDocument,NoSupportingDocs,DocCurrency,ExchangeRate,ExCurrency,ExDurationFrom,GSTExchangeRate,GSTExCurrency,Isnull(GSTTotalAmount,0),DocumentState,NoSupportingDocs,IsGstSettings,IsMultiCurrency,IsAllowableDisallowable,IsGSTCurrencyRateChanged,Remarks,@UserCreated,@CreatedDate,Status,Remarks As DocDescription,@UserCreated,GrandTotal,0.00 As GrandDocCreditTotal,GrandTotal * Round(ExchangeRate,2) As GrandBaseDebitTotal,
								0.00 As GrandBaseCreditTotal,EntityId,EntityType,DocDate As PostingDate,COAId,ModeOfReceipt,0.00 As BankReceiptAmmount,0.00 As ExcessPaidByClientAmmount,0.00 As BalancingItemReciveCRAmount,0.00 As BalancingItemPayDRAmount,0.00 As ReceiptApplicationAmmount,Id As DocumentId,BankClearingDate,0 As IsBalancing,IsDisAllow,1 As IsShow,DocNo As ActualSysRefNo,0 As IsSegmentReporting,ReceiptRefNo
						From Bean.Receipt(Nolock) Where CompanyId=@CompanyId And Id=@SourceId

						Set @RecOrder=@RecOrder+1
						Insert Into Bean.JournalDetail (Id,JournalId,COAId,AccountDescription, DocDebit,DocCredit,
														 BaseDebit,BaseCredit,
														 DocDebitTotal,DocCreditTotal,BaseDebitTotal,BaseCreditTotal,DocumentId,DocumentDetailId,ItemId,BaseCurrency,ExchangeRate, DocType,DocSubType,ServiceCompanyId,DocNo, IsTax,
														EntityId, SystemRefNo, DocCurrency,DocDate, PostingDate,RecOrder 
														)
						Select NEWID(),@IntMastJournalId,@ClearingReceiptsCOAID,R.Remarks,R.ReceiptApplicationAmmount As DocDebit,Null As DocCredit,
							Round(@ClearingRecieptAmount * @SysCalExchangerate,2) As BaseDebit,Null As BaseCredit,
							0.00 As DocDebitTotal,0.00 As DocCreditTotal,0.00 As BaseDebitTotal,0.00 As BaseCreditTotal,R.Id As DocumentId,R.Id As DocumentDetailId,@GUIDZero,
							R.BaseCurrency,@SysCalExchangerate As ExchangeRate, @DocType,@DocSubType,ServiceCompanyId,DocNo,0 As IsTax,
							EntityId,@IntMastSysRefNo,@DocCurrency,DocDate,DocDate,@RecOrder As RecOrder
						From Bean.Receipt(Nolock) As R
						Where R.Id=@SourceId
						--Reciept Detail 
						Insert Into @InterCoRecieptDtl 
						Select RD.Id,RD.ServiceCompanyId From Bean.ReceiptDetail(Nolock) As RD
						Inner Join Bean.Receipt(Nolock) As R On RD.ReceiptId=R.Id 
						Where R.Id=@SourceId And RD.ServiceCompanyId=@MasterServComp And RD.ReceiptAmount<>0 Order By RD.RecOrder
						Set @Count=(Select Count(*) From @InterCoRecieptDtl)
						Set @RecOrder=2
						Set @RecCount=1
						While @Count>=@RecCount
						Begin
							Set @RecieptDtlId=(Select RecieptDtlId From @InterCoRecieptDtl Where S_No=@RecCount)
							Set @DocumentId=(Select DocumentId From Bean.ReceiptDetail(Nolock) Where Id=@RecieptDtlId)
							Set @IsRoundingAmount=0
							IF Exists (Select DocumentType From Bean.ReceiptDetail(Nolock) Where Id=@RecieptDtlId And DocumentType=@InvoiceDocument)
							Begin
								Set @ExchangeRate=(Select ExchangeRate From Bean.Invoice(Nolock) Where Id=@DocumentId)
								IF Exists(Select Id From Bean.Invoice(Nolock) Where Id=@DocumentId And DocumentState In (@FullyApplied,@Fullypaid))
								Begin
									Set @IsRoundingAmount=1
								End
							End
							Else IF Exists (Select DocumentType From Bean.ReceiptDetail(Nolock) Where Id=@RecieptDtlId And DocumentType=@DebitNoteDocument)
							Begin
								Set @ExchangeRate=(Select ExchangeRate From Bean.DebitNote(Nolock) Where Id=@DocumentId)
								IF Exists(Select Id From Bean.DebitNote(Nolock) Where Id=@DocumentId And DocumentState In (@FullyApplied,@Fullypaid))
								Begin
									Set @IsRoundingAmount=1
								End
							End
							--Getting COAID By Checking Nature
							IF Exists (Select ID From Bean.ReceiptDetail(Nolock) Where id=@RecieptDtlId And Nature=@NatureTrade)
							Begin
								Set @COAID=(Select Id From Bean.ChartOfAccount(Nolock) Where CompanyId=@CompanyId And Name=@COATradeReceivables)
							End
							Else IF Exists (Select ID From Bean.ReceiptDetail(Nolock) Where id=@RecieptDtlId And Nature=@NatureOthers)
							Begin
								Set @COAID=(Select Id From Bean.ChartOfAccount(Nolock) Where CompanyId=@CompanyId And Name=@COAotherReceivables)
							End
							IF @IsRoundingAmount=1 And Exists (Select Amount From @RoundingAmountDetails Where DocumentId=@DocumentId And Amount Is Not Null And Amount<>'')
							Begin
								Set @DocAmount=(Select Amount From @RoundingAmountDetails Where DocumentId=@DocumentId)
							End
							Else
							Begin
								Set @DocAmount=0
							End
							Insert Into Bean.JournalDetail (Id,JournalId,COAId,AccountDescription, DocDebit,DocCredit,
													 BaseDebit,BaseCredit,
													 DocDebitTotal,DocCreditTotal,BaseDebitTotal,BaseCreditTotal,DocumentId,DocumentDetailId,ItemId,BaseCurrency,ExchangeRate, DocType,DocSubType,ServiceCompanyId,DocNo,Nature,OffsetDocument,IsTax,
													EntityId, SystemRefNo, DocCurrency,DocDate, PostingDate,RecOrder 
													)
							Select NEWID(),@IntMastJournalId,@COAID,R.Remarks,Null As DocDebit,RD.ReceiptAmount As DocCredit,
								Null As BaseDebit,Round(RD.ReceiptAmount * @DefaultExchangeRate,2)- Isnull(@DocAmount,0) As BaseCredit,
								0.00 As DocDebitTotal,0.00 As DocCreditTotal,0.00 As BaseDebitTotal,0.00 As BaseCreditTotal,R.Id As DocumentId,RD.Id As DocumentDetailId,@GUIDZero,
								R.BaseCurrency,@DefaultExchangeRate As ExchangeRate,@DocType,@DocSubType,RD.ServiceCompanyId,R.DocNo,RD.Nature,RD.DocumentNo,0 As IsTax,
								R.EntityId,@IntMastSysRefNo,@DocCurrency,R.DocDate,R.DocDate,@RecOrder As RecOrder
							From Bean.Receipt(Nolock) As R
							Inner Join bean.ReceiptDetail(Nolock) As RD On RD.ReceiptId=R.Id
							Where R.Id=@SourceId 
							And RD.Id=@RecieptDtlId
							Set @RecOrder=@RecOrder+1
							Set @RecCount=@RecCount+1
						End
						-- Looping Service Company Id's To Create Journal
						Insert Into @ServCompaIdTbl
						Select Distinct ServiceCompanyId From Bean.ReceiptDetail(Nolock) Where ReceiptId=@SourceId And ServiceCompanyId <>@MasterServComp And ReceiptAmount<>0
						Set @ServCompaIdTblCnt=(Select Count(S_No) From @ServCompaIdTbl)
						Set @RecCount=1
						While @ServCompaIdTblCnt>=@RecCount
						Begin
							Select @ServCompId=SerCompId From @ServCompaIdTbl Where S_No=@RecCount
							Set @SysRefNum_Incr=@SysRefNum_Incr+1
							Set @SystemRefNo=CONCAT(@DocNo,'-JV',@SysRefNum_Incr)
							
							Set @JournalId=NEWID()
							Set @IntroCompCOAID=(Select COA.Id From Bean.ChartOfAccount(Nolock) As COA 
													Inner Join Bean.AccountType(Nolock) As ACT On ACT.Id=COA.AccountTypeId
													Where ACT.CompanyId=@CompanyId And ACT.Name=@IntercompClearingCOAName And COA.SubsidaryCompanyId=@ServCompId)
							Insert Into Bean.Journal (Id,CompanyId,DocDate,DocType,DocSubType,DocNo,ServiceCompanyId,SystemReferenceNo,IsNoSupportingDocs,NoSupportingDocument,DocCurrency,ExchangeRate,ExCurrency,ExDurationFrom,GSTExchangeRate,GSTExCurrency,GSTTotalAmount,DocumentState,IsNoSupportingDocument,IsGstSettings,IsMultiCurrency,IsAllowableNonAllowable,IsGSTCurrencyRateChanged,Remarks,UserCreated,CreatedDate,Status,DocumentDescription,CreationType,GrandDocDebitTotal,GrandDocCreditTotal,GrandBaseDebitTotal,
														GrandBaseCreditTotal,EntityId,EntityType,PostingDate,COAId,ModeOfReceipt,BankReceiptAmmount,ExcessPaidByClientAmmount,BalancingItemReciveCRAmount,  BalancingItemPayDRAmount,ReceiptApplicationAmmount,DocumentId, BankClearingDate ,IsBalancing,ISAllowDisAllow, IsShow, ActualSysRefNo 
														,IsSegmentReporting,TransferRefNo
													 )
							Select @JournalId,@CompanyId,DocDate,@DocType,@DocSubType,DocNo,@ServCompId As ServiceCompanyId,@SystemRefNo As SystemRefNo,IsNoSupportingDocument,NoSupportingDocs,DocCurrency,ExchangeRate,ExCurrency,ExDurationFrom,GSTExchangeRate,GSTExCurrency,Isnull(GSTTotalAmount,0),DocumentState,NoSupportingDocs,IsGstSettings,IsMultiCurrency,IsAllowableDisallowable,IsGSTCurrencyRateChanged,Remarks,@UserCreated,@CreatedDate,Status,Remarks As DocDescription,@UserCreated,GrandTotal,0.00 As GrandDocCreditTotal,GrandTotal * Round(ExchangeRate,2) As GrandBaseDebitTotal,
									0.00 As GrandBaseCreditTotal,EntityId,EntityType,DocDate As PostingDate,@IntroCompCOAID As COAId,ModeOfReceipt,0.00 As BankReceiptAmmount,0.00 As ExcessPaidByClientAmmount,0.00 As BalancingItemReciveCRAmount,0.00 As BalancingItemPayDRAmount,0.00 As ReceiptApplicationAmmount,Id As DocumentId,BankClearingDate,0 As IsBalancing,IsDisAllow,1 As IsShow,DocNo As ActualSysRefNo,0 As IsSegmentReporting,ReceiptRefNo
							From Bean.Receipt(Nolock) Where CompanyId=@CompanyId And Id=@SourceId
							-- Inter Service Company I/C
							Insert Into Bean.JournalDetail (Id,JournalId,COAId,AccountDescription, DocDebit,DocCredit,
													 BaseDebit,BaseCredit,
													 DocDebitTotal,DocCreditTotal,BaseDebitTotal,BaseCreditTotal,DocumentId,DocumentDetailId,ItemId,BaseCurrency,ExchangeRate, DocType,DocSubType,ServiceCompanyId,DocNo,Nature,OffsetDocument,IsTax,
													EntityId, SystemRefNo, DocCurrency,DocDate, PostingDate,RecOrder 
													)
							Select NEWID(),@IntMastJournalId,@IntroCompCOAID,R.Remarks,Null As DocDebit,Sum(Isnull(RD.ReceiptAmount,0)) As DocCredit,
									Null As BaseDebit,Round(Sum(Isnull(RD.ReceiptAmount,0)) * @DefaultExchangeRate,2) As BaseCredit,
									0.00 As DocDebitTotal,0.00 As DocCreditTotal,0.00 As BaseDebitTotal,0.00 As BaseCreditTotal,R.Id As DocumentId,R.Id As DocumentDetailId,@GUIDZero,
									R.BaseCurrency,@DefaultExchangeRate As ExchangeRate,@DocType,@DocSubType,RD.ServiceCompanyId,R.DocNo,Null As Nature,Null,0 As IsTax,
									R.EntityId,@IntMastSysRefNo,@DocCurrency,R.DocDate,R.DocDate,1 As RecOrder
							From Bean.Receipt(Nolock) As R 
							Inner Join bean.ReceiptDetail(Nolock) As RD On RD.ReceiptId=R.Id
							Where R.Id=@SourceId And RD.ServiceCompanyId=@ServCompId And RD.ReceiptAmount<>0
							Group By R.Remarks,R.ExchangeRate,R.Id,R.BaseCurrency,R.ExchangeRate,RD.ServiceCompanyId,R.DocNo,R.EntityId,R.DocDate

							Insert Into Bean.JournalDetail (Id,JournalId,COAId,AccountDescription, DocDebit,DocCredit,
													 BaseDebit,BaseCredit,
													 DocDebitTotal,DocCreditTotal,BaseDebitTotal,BaseCreditTotal,DocumentId,DocumentDetailId,ItemId,BaseCurrency,ExchangeRate, DocType,DocSubType,ServiceCompanyId,DocNo,Nature,OffsetDocument,IsTax,
													EntityId, SystemRefNo, DocCurrency,DocDate, PostingDate,RecOrder 
													)
							Select NEWID(),@JournalId,@MainInterCoServCompCOAID,R.Remarks,Sum(Isnull(RD.ReceiptAmount,0)) As DocDebit,Null As DocCredit,
									Round(Sum(Isnull(RD.ReceiptAmount,0)) * @DefaultExchangeRate,2) As BaseDebit,Null As BaseCredit,
									0.00 As DocDebitTotal,0.00 As DocCreditTotal,0.00 As BaseDebitTotal,0.00 As BaseCreditTotal,R.Id As DocumentId,R.Id As DocumentDetailId,@GUIDZero,
									R.BaseCurrency,@DefaultExchangeRate As ExchangeRate,@DocType,@DocSubType,RD.ServiceCompanyId,R.DocNo,Null As Nature,Null,0 As IsTax,
									R.EntityId,@SystemRefNo,@DocCurrency,R.DocDate,R.DocDate,1 As RecOrder
							From Bean.Receipt(Nolock) As R
							Inner Join bean.ReceiptDetail(Nolock) As RD On RD.ReceiptId=R.Id
							Where R.Id=@SourceId And RD.ServiceCompanyId=@ServCompId And RD.ReceiptAmount<>0
							Group By R.Remarks,R.ExchangeRate,R.Id,R.BaseCurrency,R.ExchangeRate,RD.ServiceCompanyId,R.DocNo,R.EntityId,R.DocDate
							
							-- Creating Records For Interco In Journal Detail
							Delete From @RecieptDtl_New
							Insert Into @RecieptDtl_New 
							Select ROW_NUMBER() Over (Order by RD.Id),RD.Id From Bean.ReceiptDetail(Nolock) As RD
							Inner Join Bean.Receipt(Nolock) As R On RD.ReceiptId=R.Id 
							Where R.Id=@SourceId And RD.ServiceCompanyId=@ServCompId And RD.ReceiptAmount<>0 Order By RD.RecOrder
							Set @Count=(Select Count(*) From @RecieptDtl_New)
							Set @RecOrder=2
							Set @RdtlRecCount=1
							While @Count>=@RdtlRecCount
							Begin
								Set @IsRoundingAmount=0
								Set @RecieptDtlId=(Select RecieptDtlId From @RecieptDtl_New Where S_No=@RdtlRecCount)
								Set @DocumentId=(Select DocumentId From Bean.ReceiptDetail(Nolock) Where Id=@RecieptDtlId)
								IF Exists (Select DocumentType From Bean.ReceiptDetail(Nolock) Where Id=@RecieptDtlId And DocumentType=@InvoiceDocument)
								Begin
									Set @ExchangeRate=(Select ExchangeRate From Bean.Invoice(Nolock) Where Id=@DocumentId)
									IF Exists(Select Id From Bean.Invoice(Nolock) Where Id=@DocumentId And DocumentState In (@FullyApplied,@Fullypaid))
									Begin
										Set @IsRoundingAmount=1
									End
								End
								Else IF Exists (Select DocumentType From Bean.ReceiptDetail(Nolock) Where Id=@RecieptDtlId And DocumentType=@DebitNoteDocument)
								Begin
									Set @ExchangeRate=(Select ExchangeRate From Bean.DebitNote(Nolock) Where Id=@DocumentId)
									IF Exists(Select Id From Bean.DebitNote(Nolock) Where Id=@DocumentId And DocumentState In (@FullyApplied,@Fullypaid))
									Begin
										Set @IsRoundingAmount=1
									End
								End
								--Getting COAID By Checking Nature
								IF Exists (Select ID From Bean.ReceiptDetail(Nolock) Where id=@RecieptDtlId And Nature=@NatureTrade)
								Begin
									Set @COAID=(Select Id From Bean.ChartOfAccount(Nolock) Where CompanyId=@CompanyId And Name=@COATradeReceivables)
								End
								Else IF Exists (Select ID From Bean.ReceiptDetail(Nolock) Where id=@RecieptDtlId And Nature=@NatureOthers)
								Begin
									Set @COAID=(Select Id From Bean.ChartOfAccount(Nolock) Where CompanyId=@CompanyId And Name=@COAotherReceivables)
								End
								IF @IsRoundingAmount=1 And Exists (Select Amount From @RoundingAmountDetails Where DocumentId=@DocumentId And Amount Is Not Null And Amount<>'')
								Begin
									Set @DocAmount=(Select Amount From @RoundingAmountDetails Where DocumentId=@DocumentId)
								End
								Else
								Begin
									Set @DocAmount=0
								End
								Insert Into Bean.JournalDetail (Id,JournalId,COAId,AccountDescription, DocDebit,DocCredit,
														 BaseDebit,BaseCredit,
														 DocDebitTotal,DocCreditTotal,BaseDebitTotal,BaseCreditTotal,DocumentId,DocumentDetailId,ItemId,BaseCurrency,ExchangeRate, DocType,DocSubType,ServiceCompanyId,DocNo,Nature,OffsetDocument,IsTax,
														EntityId, SystemRefNo, DocCurrency,DocDate, PostingDate,RecOrder 
														)
								Select NEWID(),@JournalId,@COAID,R.Remarks,Null As DocDebit,RD.ReceiptAmount As DocCredit,
									Null As BaseDebit,Round(RD.ReceiptAmount * @DefaultExchangeRate,2)- Isnull(@DocAmount,0) As BaseCredit,
									0.00 As DocDebitTotal,0.00 As DocCreditTotal,0.00 As BaseDebitTotal,0.00 As BaseCreditTotal,R.Id As DocumentId,RD.Id As DocumentDetailId,@GUIDZero,
									R.BaseCurrency,@DefaultExchangeRate As ExchangeRate,@DocType,@DocSubType,RD.ServiceCompanyId,R.DocNo,RD.Nature,RD.DocumentNo,0 As IsTax,
									R.EntityId,@SystemRefNo,@DocCurrency,R.DocDate,R.DocDate,@RecOrder As RecOrder
								From Bean.Receipt(Nolock) As R
								Inner Join bean.ReceiptDetail(Nolock) As RD On RD.ReceiptId=R.Id
								Where R.Id=@SourceId And RD.Id=@RecieptDtlId

								Set @RecOrder=@RecOrder+1
								Set @RdtlRecCount=@RdtlRecCount+1
							End
							Set @RecCount=@RecCount+1
						End
					End
				End
				Else IF @DocCurrency<>@BankChargesCurrency And @BaseCurrency<>@DocCurrency
				Begin
					/* Creating Mater Record With BankReceiptAmmount In JournalDetail */
					IF Exists (Select Id From Bean.Receipt(Nolock) Where Id=@SourceId And GrandTotal<>0)
					Begin
						Insert Into Bean.JournalDetail (Id,JournalId,COAId,AccountDescription,AllowDisAllow, DocDebit, BaseDebit, DocDebitTotal,DocCreditTotal,BaseDebitTotal,BaseCreditTotal,DocumentId,DocumentDetailId,ItemId,BaseCurrency,ExchangeRate,GSTExCurrency,GSTExchangeRate,DocType,DocSubType,ServiceCompanyId,DocNo, IsTax,
										EntityId, SystemRefNo, DocCurrency,DocDate, PostingDate,RecOrder )
						Select NEWID(),@MasterJournalId,COAId,Remarks,IsDisAllow,BankReceiptAmmount,BankReceiptAmmount * Round(@DefaultExchangeRate,2),0.00 As DocDebitTotal,0.00 As DocCreditTotal,0.00 As BaseDebitTotal,0.00 As BaseCreditTotal,Id As DocumentId,@GUIDZero,@GUIDZero,
								BaseCurrency,@DefaultExchangeRate As ExchangeRate,GSTExCurrency,GSTExchangeRate,@DocType,@DocSubType,ServiceCompanyId,DocNo,0 As IsTax,
								EntityId,@MasterSystemRefNo As SystemRefNo,@BankChargesCurrency,DocDate,DocDate,@RecOrder As RecOrder
						From Bean.Receipt(Nolock) Where Id=@SourceId
					End
					Else IF Exists (Select Id From Bean.Receipt(Nolock) Where Id=@SourceId And GrandTotal=0 And BankReceiptAmmount<>0)
					Begin
						Insert Into Bean.JournalDetail (Id,JournalId,COAId,AccountDescription,AllowDisAllow, DocDebit, BaseDebit, DocDebitTotal,DocCreditTotal,BaseDebitTotal,BaseCreditTotal,DocumentId,DocumentDetailId,ItemId,BaseCurrency,ExchangeRate,GSTExCurrency,GSTExchangeRate,DocType,DocSubType,ServiceCompanyId,DocNo, IsTax,
										EntityId, SystemRefNo, DocCurrency,DocDate, PostingDate,RecOrder )
						Select NEWID(),@MasterJournalId,COAId,Remarks,IsDisAllow,Isnull(BankReceiptAmmount,0) As BankReceiptAmmount,Round(Isnull(BankReceiptAmmount,0) * @DefaultExchangeRate,2),0.00 As DocDebitTotal,0.00 As DocCreditTotal,0.00 As BaseDebitTotal,0.00 As BaseCreditTotal,Id As DocumentId,@GUIDZero,@GUIDZero,
								BaseCurrency,@DefaultExchangeRate As ExchangeRate,GSTExCurrency,GSTExchangeRate,@DocType,@DocSubType,ServiceCompanyId,DocNo,0 As IsTax,
								EntityId,@MasterSystemRefNo As SystemRefNo,@BankChargesCurrency,DocDate,DocDate,@RecOrder As RecOrder
						From Bean.Receipt(Nolock) Where Id=@SourceId
					End
					/* Creating Record in Journaldetail With Bank Charges Amount */
					If Exists(Select Id From Bean.Receipt(Nolock) Where Id=@SourceId And BankCharges Is Not Null)
					Begin
						Set @RecOrder=@RecOrder+1
						Insert Into Bean.JournalDetail (Id,JournalId,COAId,AccountDescription,AllowDisAllow,TaxId,TaxType,TaxRate,DocDebit, BaseDebit, DocDebitTotal,DocCreditTotal,BaseDebitTotal,BaseCreditTotal,DocumentId,DocumentDetailId,ItemId,BaseCurrency,ExchangeRate,GSTExCurrency,GSTExchangeRate,DocType,DocSubType,ServiceCompanyId,DocNo, IsTax,
													EntityId, SystemRefNo, DocCurrency,DocDate, PostingDate,RecOrder,GSTTaxDebit)
						Select NEWID(),@MasterJournalId,@BankCharges_COAId,Remarks,IsDisAllow,@TaxId,@TaxType,@TaxRate,BankCharges,BankCharges * Round(@DefaultExchangeRate,2),0.00 As DocDebitTotal,0.00 As DocCreditTotal,0.00 As BaseDebitTotal,0.00 As BaseCreditTotal,Id As DocumentId,Id As DocumentDetailId,@GUIDZero,
							BaseCurrency,@DefaultExchangeRate,GSTExCurrency,GSTExchangeRate,@DocType,@DocSubType,ServiceCompanyId,DocNo,0 As IsTax,
							EntityId,@MasterSystemRefNo As SystemRefNo,@BankChargesCurrency,DocDate,DocDate,@RecOrder As RecOrder,
							Case When @TaxId Is Not Null Then Round(BankCharges * Coalesce(GSTexchangerate,@DefaultExchangeRate),2) End As GSTTaxDebit
						From Bean.Receipt(Nolock)
						Where Id=@SourceId
					End
					/* Creating Record in Journaldetail With @ExcesPaidByClientAmt Amount */
					If @ExcesPaidByClientAmt Is NOt Null
					Begin
						Set @RecOrder=@RecOrder+1
						Insert Into Bean.JournalDetail (Id,JournalId,COAId,AccountDescription,AllowDisAllow, DocCredit, BaseCredit, DocDebitTotal,DocCreditTotal,BaseDebitTotal,BaseCreditTotal,DocumentId,DocumentDetailId,ItemId,BaseCurrency,ExchangeRate,GSTExCurrency,GSTExchangeRate,DocType,DocSubType,ServiceCompanyId,DocNo, IsTax,
														EntityId, SystemRefNo, DocCurrency,DocDate, PostingDate,RecOrder )
						Select NEWID(),@MasterJournalId,@ClearingReceiptsCOAID,Remarks,IsDisAllow,ExcessPaidByClientAmmount,ExcessPaidByClientAmmount * Round(@DefaultExchangeRate,2),0.00 As DocDebitTotal,0.00 As DocCreditTotal,0.00 As BaseDebitTotal,0.00 As BaseCreditTotal,Id As DocumentId,Id As DocumentDtlId,@GUIDZero,
								BaseCurrency,@DefaultExchangeRate,BankReceiptAmmountCurrency,ExchangeRate,@DocType,@DocSubType,ServiceCompanyId,DocNo,0 As IsTax,
								EntityId,@MasterSystemRefNo,@BankChargesCurrency,DocDate,DocDate,@RecOrder As RecOrder
						From Bean.Receipt(Nolock)
						Where Id=@SourceId
					End
					/* Creating Balancing Line Items */
					Insert Into @RecieptBalLnItm
					Select RBI.Id From Bean.ReceiptBalancingItem(Nolock) As RBI
					Inner Join bean.Receipt(Nolock) As R On R.Id=RBI.ReceiptId
					Where R.Id=@SourceId Order by RecOrder
					Set @Count=(Select Count(*) From @RecieptBalLnItm)
					Set @RecCount=1
					While @Count>=@RecCount
					Begin
						Select @RecieptBalId=RecieptBalId From @RecieptBalLnItm Where S_no=@RecCount
						Select @TaxId=TaxId,@TaxRate=TaxRate From Bean.ReceiptBalancingItem(Nolock) Where Id=@RecieptBalId
						Set @RecOrder=@RecOrder+1
						Insert Into Bean.JournalDetail (Id,JournalId,COAId,AccountDescription,AllowDisAllow,TaxId,TaxType,TaxRate,DocDebit,DocCredit,
													DocTaxDebit,DocTaxCredit,BaseDebit,BaseCredit,
													BaseTaxDebit,BaseTaxCredit,DocDebitTotal,DocCreditTotal,BaseDebitTotal,BaseCreditTotal,DocumentId,DocumentDetailId,ItemId,BaseCurrency,ExchangeRate,GSTExCurrency,GSTExchangeRate,DocType,DocSubType,ServiceCompanyId,DocNo, IsTax,
													EntityId, SystemRefNo, DocCurrency,DocDate, PostingDate,RecOrder,GSTTaxDebit,GSTTaxCredit,GSTDebit,GSTCredit)
						Select NEWID(),@MasterJournalId,RBi.COAId,R.Remarks,RBI.IsDisAllow,RBI.TaxId,RBI.TaxType,Rbi.TaxRate,Case When RBI.ReciveORPay=@Pay_Dr Then RBI.DocAmount End As DocDebit,Case When RBI.ReciveORPay=@Receive_Cr Then RBI.DocAmount End As DocCredit,
							Case When RBI.ReciveORPay=@Pay_Dr Then RBI.DocTaxAmount End As DocTaxDebdit,Case When RBI.ReciveORPay=@Receive_Cr Then RBI.DocTaxAmount End As DocTaxCredit,Case When RBI.ReciveORPay=@Pay_Dr Then RBI.DocAmount * Round(@DefaultExchangeRate,2) End As BaseDebit,Case When RBI.ReciveORPay=@Receive_Cr Then RBI.DocAmount * Round(@DefaultExchangeRate,2) End As BaseCredit,
							Case When RBI.ReciveORPay=@Pay_Dr Then RBI.DocTaxAmount * Round(@DefaultExchangeRate,2) End As BaseTaxDebdit,Case When RBI.ReciveORPay=@Receive_Cr Then RBI.DocTaxAmount * Round(@DefaultExchangeRate,2) End As BaseTaxCredit,0.00 As DocDebitTotal,0.00 As DocCreditTotal,0.00 As BaseDebitTotal,0.00 As BaseCreditTotal,R.Id As DocumentId,RBI.Id As DocumentDetailId,@GUIDZero,
							R.BaseCurrency,@DefaultExchangeRate As ExchangeRate,R.GSTExCurrency,R.GSTExchangeRate,@DocType,@DocSubType,ServiceCompanyId,DocNo,0 As IsTax,
							EntityId,@MasterSystemRefNo,@BankChargesCurrency,DocDate,DocDate,@RecOrder As RecOrder,
							Case When RBI.ReciveORPay=@Pay_Dr Then Round(RBI.DocAmount * Coalesce(R.GSTExchangeRate,@DefaultExchangeRate),2) End As GSTTaxDebit,
							Case When RBI.ReciveORPay=@Receive_Cr Then Round(RBI.DocAmount * Coalesce(R.GSTExchangeRate,@DefaultExchangeRate),2) End As GSTTaxCredit,
							Case When RBI.ReciveORPay=@Pay_Dr Then Round(RBI.DocTaxAmount * Coalesce(R.GSTExchangeRate,@DefaultExchangeRate),2) End As GSTDebit,
							Case When RBI.ReciveORPay=@Receive_Cr Then Round(RBI.DocTaxAmount * Coalesce(R.GSTExchangeRate,@DefaultExchangeRate),2) End As GSTCredit
						From Bean.Receipt(Nolock) As R
						Inner Join bean.ReceiptBalancingItem(Nolock) As RBI On RBI.ReceiptId=R.Id
						Where R.Id=@SourceId And Rbi.Id=@RecieptBalId
						-- Creating Tax Line Items
						If @GST Is Not Null And @GST=1 And @TaxId Is Not Null And (@TaxRate Is Not Null And @TaxRate<>0)
						Begin
							Set @TaxRecCount=@RecOrder+@Count
							Insert Into Bean.JournalDetail (Id,JournalId,COAId,AccountDescription,AllowDisAllow,TaxId,TaxType,TaxRate,DocDebit,DocCredit,
									 BaseDebit,BaseCredit,
									 DocDebitTotal,DocCreditTotal,BaseDebitTotal,BaseCreditTotal,DocumentId,DocumentDetailId,ItemId,BaseCurrency,ExchangeRate,GSTExCurrency,GSTExchangeRate,DocType,DocSubType,ServiceCompanyId,DocNo, IsTax,
									EntityId, SystemRefNo, DocCurrency,DocDate, PostingDate,RecOrder )
							Select NEWID(),@MasterJournalId,@TaxPayableGST_COAID as COAId,R.Remarks,RBI.IsDisAllow,RBI.TaxId,RBI.TaxType,Rbi.TaxRate,Case When RBI.ReciveORPay=@Pay_Dr Then RBI.DocTaxAmount End As DocDebit,Case When RBI.ReciveORPay=@Receive_Cr Then RBI.DocTaxAmount End As DocCredit,
								Case When RBI.ReciveORPay=@Pay_Dr Then Round(RBI.DocTaxAmount * @DefaultExchangeRate,2) End As BaseDebit,Case When RBI.ReciveORPay=@Receive_Cr Then RBI.DocTaxAmount * Round(@DefaultExchangeRate,2) End As BaseCredit,
								0.00 As DocDebitTotal,0.00 As DocCreditTotal,0.00 As BaseDebitTotal,0.00 As BaseCreditTotal,R.Id As DocumentId,RBI.Id As DocumentDetailId,@GUIDZero,
								R.BaseCurrency,@DefaultExchangeRate As ExchangeRate,R.GSTExCurrency,R.GSTExchangeRate,@DocType,@DocSubType,ServiceCompanyId,DocNo,1 As IsTax,
								EntityId,@MasterSystemRefNo,@BankChargesCurrency,DocDate,DocDate,@TaxRecCount As RecOrder
							From Bean.Receipt(Nolock) As R
							Inner Join bean.ReceiptBalancingItem(Nolock) As RBI On RBI.ReceiptId=R.Id
							Where R.Id=@SourceId And Rbi.Id=@RecieptBalId
						End
						Set @RecCount=@RecCount+1
					End
					IF Exists (Select Id From Bean.ReceiptDetail(Nolock) Where ReceiptId=@SourceId And ReceiptAmount<>0)
					Begin
						-- Clearing Reciepts Main Journal
						Set @ClearingRecieptAmount=(Select SUM(Isnull(DocDebit,0))-Sum(Isnull(DocCredit,0)) From Bean.JournalDetail(Nolock) Where JournalId=@MasterJournalId)
						Set @RecOrder=@RecOrder+1

						Insert Into Bean.JournalDetail (Id,JournalId,COAId,AccountDescription, DocDebit,DocCredit,
														 BaseDebit,BaseCredit,
														 DocDebitTotal,DocCreditTotal,BaseDebitTotal,BaseCreditTotal,DocumentId,DocumentDetailId,ItemId,BaseCurrency,ExchangeRate, DocType,DocSubType,ServiceCompanyId,DocNo, IsTax,
														EntityId, SystemRefNo, DocCurrency,DocDate, PostingDate,RecOrder 
														)
						Select NEWID(),@MasterJournalId,@ClearingReceiptsCOAID,R.Remarks,Null As DocDebit,Abs(@ClearingRecieptAmount) As DocCredit,
							Null As BaseDebit,ABS(Round(@ClearingRecieptAmount * @DefaultExchangeRate,2)) As BaseCredit,
							0.00 As DocDebitTotal,0.00 As DocCreditTotal,0.00 As BaseDebitTotal,0.00 As BaseCreditTotal,R.Id As DocumentId,R.Id As DocumentDetailId,@GUIDZero,
							R.BaseCurrency,@DefaultExchangeRate As ExchangeRate, @DocType,@DocSubType,ServiceCompanyId,DocNo,0 As IsTax,
							EntityId,@MasterSystemRefNo,@BankChargesCurrency,DocDate,DocDate,@RecOrder As RecOrder
						From Bean.Receipt(Nolock) As R
						Where R.Id=@SourceId
						--Creating Journal For Master Record With DifferentCurrency
						Set @IntMastJournalId=NEWID()
						Set @RecOrder=1
						Set @SysRefNum_Incr=@SysRefNum_Incr+1
						Set @IntMastSysRefNo=CONCAT(@DocNo,'-JV',@SysRefNum_Incr)
						--Set @IntMastSysRefNo=@SystemRefNo
						Insert Into Bean.Journal (Id,CompanyId,DocDate,DocType,DocSubType,DocNo,ServiceCompanyId,SystemReferenceNo,IsNoSupportingDocs,NoSupportingDocument,DocCurrency,ExchangeRate,ExCurrency,ExDurationFrom,GSTExchangeRate,GSTExCurrency,GSTTotalAmount,DocumentState,IsNoSupportingDocument,IsGstSettings,IsMultiCurrency,IsAllowableNonAllowable,IsGSTCurrencyRateChanged,Remarks,UserCreated,CreatedDate,Status,DocumentDescription,CreationType,GrandDocDebitTotal,GrandDocCreditTotal,GrandBaseDebitTotal,
													GrandBaseCreditTotal,EntityId,EntityType,PostingDate,COAId,ModeOfReceipt,BankReceiptAmmount,ExcessPaidByClientAmmount,BalancingItemReciveCRAmount,  BalancingItemPayDRAmount,ReceiptApplicationAmmount,DocumentId, BankClearingDate ,IsBalancing,ISAllowDisAllow, IsShow, ActualSysRefNo 
													,IsSegmentReporting,TransferRefNo
												 )
						Select @IntMastJournalId,@CompanyId,DocDate,@DocType,@DocSubType,DocNo,ServiceCompanyId,@IntMastSysRefNo As SystemRefNo,IsNoSupportingDocument,NoSupportingDocs,DocCurrency,ExchangeRate,ExCurrency,ExDurationFrom,GSTExchangeRate,GSTExCurrency,Isnull(GSTTotalAmount,0),DocumentState,NoSupportingDocs,IsGstSettings,IsMultiCurrency,IsAllowableDisallowable,IsGSTCurrencyRateChanged,Remarks,@UserCreated,@CreatedDate,Status,Remarks As DocDescription,@UserCreated,GrandTotal,0.00 As GrandDocCreditTotal,GrandTotal * Round(ExchangeRate,2) As GrandBaseDebitTotal,
								0.00 As GrandBaseCreditTotal,EntityId,EntityType,DocDate As PostingDate,COAId,ModeOfReceipt,0.00 As BankReceiptAmmount,0.00 As ExcessPaidByClientAmmount,0.00 As BalancingItemReciveCRAmount,0.00 As BalancingItemPayDRAmount,0.00 As ReceiptApplicationAmmount,Id As DocumentId,BankClearingDate,0 As IsBalancing,IsDisAllow,1 As IsShow,DocNo As ActualSysRefNo,0 As IsSegmentReporting,ReceiptRefNo
						From Bean.Receipt(Nolock) Where CompanyId=@CompanyId And Id=@SourceId

						Set @RecOrder=@RecOrder+1
						Insert Into Bean.JournalDetail (Id,JournalId,COAId,AccountDescription, DocDebit,DocCredit,
														 BaseDebit,BaseCredit,
														 DocDebitTotal,DocCreditTotal,BaseDebitTotal,BaseCreditTotal,DocumentId,DocumentDetailId,ItemId,BaseCurrency,ExchangeRate, DocType,DocSubType,ServiceCompanyId,DocNo, IsTax,
														EntityId, SystemRefNo, DocCurrency,DocDate, PostingDate,RecOrder 
														)
						Select NEWID(),@IntMastJournalId,@ClearingReceiptsCOAID,R.Remarks,R.ReceiptApplicationAmmount As DocDebit,Null As DocCredit,
							Round(@ClearingRecieptAmount * @DefaultExchangeRate,2) As BaseDebit,Null As BaseCredit,
							0.00 As DocDebitTotal,0.00 As DocCreditTotal,0.00 As BaseDebitTotal,0.00 As BaseCreditTotal,R.Id As DocumentId,R.Id As DocumentDetailId,@GUIDZero,
							R.BaseCurrency,@DefaultExchangeRate As ExchangeRate, @DocType,@DocSubType,ServiceCompanyId,DocNo,0 As IsTax,
							EntityId,@IntMastSysRefNo,@DocCurrency,DocDate,DocDate,@RecOrder As RecOrder
						From Bean.Receipt(Nolock) As R
						Where R.Id=@SourceId

						--Reciept Detail & Exchange Gain/Loss
						Insert Into @InterCoRecieptDtl 
						Select RD.Id,RD.ServiceCompanyId From Bean.ReceiptDetail(Nolock) As RD
						Inner Join Bean.Receipt(Nolock) As R On RD.ReceiptId=R.Id 
						Where R.Id=@SourceId And RD.ServiceCompanyId=@MasterServComp And RD.ReceiptAmount<>0 Order By RD.RecOrder
						Set @Count=(Select Count(*) From @InterCoRecieptDtl)
						Set @RecOrder=2
						Set @RecCount=1
						While @Count>=@RecCount
						Begin
							Set @RecieptDtlId=(Select RecieptDtlId From @InterCoRecieptDtl Where S_No=@RecCount)
							Set @DocumentId=(Select DocumentId From Bean.ReceiptDetail(Nolock) Where Id=@RecieptDtlId)
							Set @IsRoundingAmount=0
							IF Exists (Select DocumentType From Bean.ReceiptDetail(Nolock) Where Id=@RecieptDtlId And DocumentType=@InvoiceDocument)
							Begin
								Set @ExchangeRate=(Select ExchangeRate From Bean.Invoice(Nolock) Where Id=@DocumentId)
								IF Exists(Select Id From Bean.Invoice(Nolock) Where Id=@DocumentId And DocumentState In (@FullyApplied,@Fullypaid))
								Begin
									Set @IsRoundingAmount=1
								End
							End
							Else IF Exists (Select DocumentType From Bean.ReceiptDetail(Nolock) Where Id=@RecieptDtlId And DocumentType=@DebitNoteDocument)
							Begin
								Set @ExchangeRate=(Select ExchangeRate From Bean.DebitNote(Nolock) Where Id=@DocumentId)
								IF Exists(Select Id From Bean.DebitNote(Nolock) Where Id=@DocumentId And DocumentState In (@FullyApplied,@Fullypaid))
								Begin
									Set @IsRoundingAmount=1
								End
							End
							--Getting COAID By Checking Nature
							IF Exists (Select ID From Bean.ReceiptDetail(Nolock) Where id=@RecieptDtlId And Nature=@NatureTrade)
							Begin
								Set @COAID=(Select Id From Bean.ChartOfAccount(Nolock) Where CompanyId=@CompanyId And Name=@COATradeReceivables)
							End
							Else IF Exists (Select ID From Bean.ReceiptDetail(Nolock) Where id=@RecieptDtlId And Nature=@NatureOthers)
							Begin
								Set @COAID=(Select Id From Bean.ChartOfAccount(Nolock) Where CompanyId=@CompanyId And Name=@COAotherReceivables)
							End
							IF @IsRoundingAmount=1 And Exists (Select Amount From @RoundingAmountDetails Where DocumentId=@DocumentId And Amount Is Not Null And Amount<>'')
							Begin
								Set @DocAmount=(Select Amount From @RoundingAmountDetails Where DocumentId=@DocumentId)
							End
							Else
							Begin
								Set @DocAmount=0
							End
							Set @RecOrder=@RecOrder+1
							Insert Into Bean.JournalDetail (Id,JournalId,COAId,AccountDescription, DocDebit,DocCredit,
													 BaseDebit,BaseCredit,
													 DocDebitTotal,DocCreditTotal,BaseDebitTotal,BaseCreditTotal,DocumentId,DocumentDetailId,ItemId,BaseCurrency,ExchangeRate, DocType,DocSubType,ServiceCompanyId,DocNo,Nature,OffsetDocument,IsTax,
													EntityId, SystemRefNo, DocCurrency,DocDate, PostingDate,RecOrder 
													)
							Select NEWID(),@IntMastJournalId,@COAID,R.Remarks,Null As DocDebit,RD.ReceiptAmount As DocCredit,
								Null As BaseDebit,Round(RD.ReceiptAmount * @ExchangeRate,2)- Isnull(@DocAmount,0) As BaseCredit,
								0.00 As DocDebitTotal,0.00 As DocCreditTotal,0.00 As BaseDebitTotal,0.00 As BaseCreditTotal,R.Id As DocumentId,RD.Id As DocumentDetailId,@GUIDZero,
								R.BaseCurrency,@ExchangeRate As ExchangeRate,@DocType,@DocSubType,RD.ServiceCompanyId,R.DocNo,RD.Nature,RD.DocumentNo,0 As IsTax,
								R.EntityId,@IntMastSysRefNo,@DocCurrency,R.DocDate,R.DocDate,@RecOrder As RecOrder
							From Bean.Receipt(Nolock) As R
							Inner Join bean.ReceiptDetail(Nolock) As RD On RD.ReceiptId=R.Id
							Where R.Id=@SourceId And RD.Id=@RecieptDtlId
							IF @SysCalExchangerate-@ExchangeRate<>0
							Begin
								Set @RecOrder=@RecOrder+1
								-- ExchangeGainOrLossRealised
								Insert Into Bean.JournalDetail (Id,JournalId,COAId,AccountDescription, DocDebit,DocCredit,
																 BaseDebit,BaseCredit,
																 DocDebitTotal,DocCreditTotal,BaseDebitTotal,BaseCreditTotal,DocumentId,DocumentDetailId,ItemId,BaseCurrency,ExchangeRate, DocType,DocSubType,ServiceCompanyId,DocNo,Nature,OffsetDocument,IsTax,
																EntityId, SystemRefNo, DocCurrency,DocDate, PostingDate,RecOrder 
																)
								Select NEWID(),@IntMastJournalId,@ExchangeGainOrLossCOAID,R.Remarks,Null As DocDebit,Null As DocCredit,
									Case When (@SysCalExchangerate-@ExchangeRate) <0 Then ABS(Round((@SysCalExchangerate-@ExchangeRate)*RD.ReceiptAmount,2))  End As BaseDebit,
										Case When (@SysCalExchangerate-@ExchangeRate)>0 Then ABS(Round((@SysCalExchangerate-@ExchangeRate)*RD.ReceiptAmount,2)) End As BaseCredit,
									0.00 As DocDebitTotal,0.00 As DocCreditTotal,0.00 As BaseDebitTotal,0.00 As BaseCreditTotal,R.Id As DocumentId,RD.Id As DocumentDetailId,@GUIDZero,
									R.BaseCurrency,R.ExchangeRate,@DocType,@DocSubType,RD.ServiceCompanyId,R.DocNo,RD.Nature,RD.DocumentNo,0 As IsTax,
									EntityId,@IntMastSysRefNo,@DocCurrency,DocDate,DocDate,@RecOrder As RecOrder
								From Bean.Receipt(Nolock) As R
								Inner Join bean.ReceiptDetail(Nolock) As RD On RD.ReceiptId=R.Id
								Where R.Id=@SourceId And RD.Id=@RecieptDtlId
							End
							Set @RecCount=@RecCount+1
						End
						-- Looping Service Company Id's To Create Journal
						Insert Into @ServCompaIdTbl
						Select Distinct ServiceCompanyId From Bean.ReceiptDetail(Nolock) Where ReceiptId=@SourceId And ServiceCompanyId<>@MasterServComp And ReceiptAmount<>0
						Set @ServCompaIdTblCnt=(Select Count(S_No) From @ServCompaIdTbl)
						Set @RdtlRecCount=1
						While @ServCompaIdTblCnt>=@RdtlRecCount
						Begin
							Set @RecOrder=@RecOrder+1
							Set @ServCompId=(Select SerCompId From @ServCompaIdTbl Where S_No=@RdtlRecCount)
							Set @IntroCompCOAID=(Select COA.Id From Bean.ChartOfAccount(Nolock) As COA 
												Inner Join Bean.AccountType(Nolock) As ACT On ACT.Id=COA.AccountTypeId
												Where ACT.CompanyId=@CompanyId And ACT.Name=@IntercompClearingCOAName And COA.SubsidaryCompanyId=@ServCompId)
							Insert Into Bean.JournalDetail (Id,JournalId,COAId,AccountDescription, DocDebit,DocCredit,
															 BaseDebit,BaseCredit,
															 DocDebitTotal,DocCreditTotal,BaseDebitTotal,BaseCreditTotal,DocumentId,DocumentDetailId,ItemId,BaseCurrency,ExchangeRate, DocType,DocSubType,ServiceCompanyId,DocNo,Nature,OffsetDocument,IsTax,
															EntityId, SystemRefNo, DocCurrency,DocDate, PostingDate,RecOrder 
															)
							Select NEWID(),@IntMastJournalId,@IntroCompCOAID,R.Remarks,Null As DocDebit,Sum(Isnull(RD.ReceiptAmount,0)) As DocCredit,
								Null As BaseDebit,Round(Sum(Isnull(RD.ReceiptAmount,0)) * @SysCalExchangerate,2) As BaseCredit,
								0.00 As DocDebitTotal,0.00 As DocCreditTotal,0.00 As BaseDebitTotal,0.00 As BaseCreditTotal,R.Id As DocumentId,@GUIDZero As DocumentDetailId,@GUIDZero,
								R.BaseCurrency,@SysCalExchangerate As ExchangeRate,@DocType,@DocSubType,RD.ServiceCompanyId,R.DocNo,Null As Nature,R.DocNo,0 As IsTax,
								R.EntityId,@IntMastSysRefNo,@DocCurrency,R.DocDate,R.DocDate,@RecOrder As RecOrder
							From Bean.Receipt(Nolock) As R
							Inner Join bean.ReceiptDetail(Nolock) As RD On RD.ReceiptId=R.Id
							Where R.Id=@SourceId And RD.ServiceCompanyId=@ServCompId
							Group By R.Remarks,R.ExchangeRate,R.Id,R.BaseCurrency,Rd.ServiceCompanyId,R.DocNo,R.EntityId,R.DocDate
							Set @SysRefNum_Incr=@SysRefNum_Incr+1
							Set @SystemRefNo=CONCAT(@DocNo,'-JV',@SysRefNum_Incr)
							Set @JournalId=NEWID()

							Insert Into Bean.Journal (Id,CompanyId,DocDate,DocType,DocSubType,DocNo,ServiceCompanyId,SystemReferenceNo,IsNoSupportingDocs,NoSupportingDocument,DocCurrency,ExchangeRate,ExCurrency,ExDurationFrom,GSTExchangeRate,GSTExCurrency,GSTTotalAmount,DocumentState,IsNoSupportingDocument,IsGstSettings,IsMultiCurrency,IsAllowableNonAllowable,IsGSTCurrencyRateChanged,Remarks,UserCreated,CreatedDate,Status,DocumentDescription,CreationType,GrandDocDebitTotal,GrandDocCreditTotal,GrandBaseDebitTotal,
														GrandBaseCreditTotal,EntityId,EntityType,PostingDate,COAId,ModeOfReceipt,BankReceiptAmmount,ExcessPaidByClientAmmount,BalancingItemReciveCRAmount,  BalancingItemPayDRAmount,ReceiptApplicationAmmount,DocumentId, BankClearingDate ,IsBalancing,ISAllowDisAllow, IsShow, ActualSysRefNo 
														,IsSegmentReporting,TransferRefNo
													 )
							Select @JournalId,@CompanyId,DocDate,@DocType,@DocSubType,DocNo,@ServCompId As ServiceCompanyId,@SystemRefNo As SystemRefNo,IsNoSupportingDocument,NoSupportingDocs,DocCurrency,ExchangeRate,ExCurrency,ExDurationFrom,GSTExchangeRate,GSTExCurrency,Isnull(GSTTotalAmount,0),DocumentState,NoSupportingDocs,IsGstSettings,IsMultiCurrency,IsAllowableDisallowable,IsGSTCurrencyRateChanged,Remarks,@UserCreated,@CreatedDate,Status,Remarks As DocDescription,@UserCreated,GrandTotal,0.00 As GrandDocCreditTotal,GrandTotal * Round(ExchangeRate,2) As GrandBaseDebitTotal,
									0.00 As GrandBaseCreditTotal,EntityId,EntityType,DocDate As PostingDate,@IntroCompCOAID As COAId,ModeOfReceipt,0.00 As BankReceiptAmmount,0.00 As ExcessPaidByClientAmmount,0.00 As BalancingItemReciveCRAmount,0.00 As BalancingItemPayDRAmount,0.00 As ReceiptApplicationAmmount,Id As DocumentId,BankClearingDate,0 As IsBalancing,IsDisAllow,1 As IsShow,DocNo As ActualSysRefNo, 0 As IsSegmentReporting,ReceiptRefNo
							From Bean.Receipt(Nolock) Where CompanyId=@CompanyId And Id=@SourceId

							Insert Into Bean.JournalDetail (Id,JournalId,COAId,AccountDescription, DocDebit,DocCredit,
													 BaseDebit,BaseCredit,
													 DocDebitTotal,DocCreditTotal,BaseDebitTotal,BaseCreditTotal,DocumentId,DocumentDetailId,ItemId,BaseCurrency,ExchangeRate, DocType,DocSubType,ServiceCompanyId,DocNo,Nature,OffsetDocument,IsTax,
													EntityId, SystemRefNo, DocCurrency,DocDate, PostingDate,RecOrder 
													)
							Select NEWID(),@JournalId,@MainInterCoServCompCOAID,R.Remarks,Sum(Isnull(RD.ReceiptAmount,0)) As DocDebit,Null As DocCredit,
									Round(Sum(Isnull(RD.ReceiptAmount,0)) * @SysCalExchangerate,2) As BaseDebit,Null As BaseCredit,
									0.00 As DocDebitTotal,0.00 As DocCreditTotal,0.00 As BaseDebitTotal,0.00 As BaseCreditTotal,R.Id As DocumentId,R.Id As DocumentDetailId,@GUIDZero,
									R.BaseCurrency,@SysCalExchangerate As ExchangeRate,@DocType,@DocSubType,RD.ServiceCompanyId,R.DocNo,Null As Nature,RD.DocumentNo,0 As IsTax,
									R.EntityId,@SystemRefNo,@DocCurrency,R.DocDate,R.DocDate,1 As RecOrder
							From Bean.Receipt(Nolock) As R
							Inner Join bean.ReceiptDetail(Nolock) As RD On RD.ReceiptId=R.Id
							Where R.Id=@SourceId And RD.ServiceCompanyId=@ServCompId
							Group By R.Remarks,R.ExchangeRate,R.Id,R.BaseCurrency,R.ExchangeRate,RD.ServiceCompanyId,R.DocNo,R.EntityId,R.DocDate,RD.DocumentNo
							
							-- Creating Records For Interco In Journal Detail
							Delete From @RecieptDtl_New
							Insert Into @RecieptDtl_New 
							Select ROW_NUMBER()Over (Order By RD.Id),RD.Id From Bean.ReceiptDetail(Nolock) As RD
							Inner Join Bean.Receipt(Nolock) As R On RD.ReceiptId=R.Id 
							Where R.Id=@SourceId And RD.ServiceCompanyId=@ServCompId And RD.ReceiptAmount<>0 Order By RD.RecOrder
							Set @Count=(Select Count(*) From @RecieptDtl_New)
							Set @RecOrder=2
							Set @RecCount=1
							While @Count>=@RecCount
							Begin
								
								Set @RecieptDtlId=(Select RecieptDtlId From @RecieptDtl_New Where S_No=@RecCount)
								Set @DocumentId=(Select DocumentId From Bean.ReceiptDetail(Nolock) Where Id=@RecieptDtlId)
								Set @IsRoundingAmount=0
								IF Exists (Select DocumentType From Bean.ReceiptDetail(Nolock) Where Id=@RecieptDtlId And DocumentType=@InvoiceDocument)
								Begin
									Set @ExchangeRate=(Select ExchangeRate From Bean.Invoice(Nolock) Where Id=@DocumentId)
									IF Exists(Select Id From Bean.Invoice(Nolock) Where Id=@DocumentId And DocumentState In (@FullyApplied,@Fullypaid))
									Begin
										Set @IsRoundingAmount=1
									End
								End
								Else IF Exists (Select DocumentType From Bean.ReceiptDetail(Nolock) Where Id=@RecieptDtlId And DocumentType=@DebitNoteDocument)
								Begin
									Set @ExchangeRate=(Select ExchangeRate From Bean.DebitNote(Nolock) Where Id=@DocumentId)
									IF Exists(Select Id From Bean.Invoice(Nolock) Where Id=@DocumentId And DocumentState In (@FullyApplied,@Fullypaid))
									Begin
										Set @IsRoundingAmount=1
									End
								End
								
								IF @IsRoundingAmount=1 And Exists (Select Amount From @RoundingAmountDetails Where DocumentId=@DocumentId And Amount Is Not Null And Amount<>'')
								Begin
									Set @DocAmount=(Select Amount From @RoundingAmountDetails Where DocumentId=@DocumentId)
								End
								Else
								Begin
									Set @DocAmount=0
								End
								--Getting COAID By Checking Nature
								IF Exists (Select ID From Bean.ReceiptDetail(Nolock) Where id=@RecieptDtlId And Nature=@NatureTrade)
								Begin
									Set @COAID=(Select Id From Bean.ChartOfAccount(Nolock) Where CompanyId=@CompanyId And Name=@COATradeReceivables)
								End
								Else IF Exists (Select ID From Bean.ReceiptDetail(Nolock) Where id=@RecieptDtlId And Nature=@NatureOthers)
								Begin
									Set @COAID=(Select Id From Bean.ChartOfAccount(Nolock) Where CompanyId=@CompanyId And Name=@COAotherReceivables)
								End
								Set @RecOrder=@RecOrder+1
								Insert Into Bean.JournalDetail (Id,JournalId,COAId,AccountDescription, DocDebit,DocCredit,
														 BaseDebit,BaseCredit,
														 DocDebitTotal,DocCreditTotal,BaseDebitTotal,BaseCreditTotal,DocumentId,DocumentDetailId,ItemId,BaseCurrency,ExchangeRate, DocType,DocSubType,ServiceCompanyId,DocNo,Nature,OffsetDocument,IsTax,
														EntityId, SystemRefNo, DocCurrency,DocDate, PostingDate,RecOrder 
														)
								Select NEWID(),@JournalId,@COAID,R.Remarks,Null As DocDebit,RD.ReceiptAmount As DocCredit,
									Null As BaseDebit,Round(RD.ReceiptAmount * @ExchangeRate,2)- Isnull(@DocAmount,0) As BaseCredit,
									0.00 As DocDebitTotal,0.00 As DocCreditTotal,0.00 As BaseDebitTotal,0.00 As BaseCreditTotal,R.Id As DocumentId,RD.Id As DocumentDetailId,@GUIDZero,
									R.BaseCurrency,@ExchangeRate As ExchangeRate,@DocType,@DocSubType,RD.ServiceCompanyId,R.DocNo,RD.Nature,RD.DocumentNo,0 As IsTax,
									R.EntityId,@SystemRefNo,@DocCurrency,R.DocDate,R.DocDate,@RecOrder As RecOrder
								From Bean.Receipt(Nolock) As R
								Inner Join bean.ReceiptDetail(Nolock) As RD On RD.ReceiptId=R.Id
								Where R.Id=@SourceId And RD.Id=@RecieptDtlId
								IF @SysCalExchangerate-@ExchangeRate <>0
								Begin
									Set @RecOrder=@RecOrder+1
									-- ExchangeGainOrLossRealised
									Insert Into Bean.JournalDetail (Id,JournalId,COAId,AccountDescription, DocDebit,DocCredit,
																	 BaseDebit,BaseCredit,
																	 DocDebitTotal,DocCreditTotal,BaseDebitTotal,BaseCreditTotal,DocumentId,DocumentDetailId,ItemId,BaseCurrency,ExchangeRate, DocType,DocSubType,ServiceCompanyId,DocNo,Nature,OffsetDocument,IsTax,
																	EntityId, SystemRefNo, DocCurrency,DocDate, PostingDate,RecOrder 
																	)
									Select NEWID(),@JournalId,@ExchangeGainOrLossCOAID,R.Remarks,Null As DocDebit,Null As DocCredit,
											Case When (@SysCalExchangerate-@ExchangeRate) <0 Then ABS(Round((@SysCalExchangerate-@ExchangeRate)*RD.ReceiptAmount,2))  End As BaseDebit,
											Case When (@SysCalExchangerate-@ExchangeRate)>0 Then ABS(Round((@SysCalExchangerate-@ExchangeRate)*RD.ReceiptAmount,2)) End As BaseCredit,
											0.00 As DocDebitTotal,0.00 As DocCreditTotal,0.00 As BaseDebitTotal,0.00 As BaseCreditTotal,R.Id As DocumentId,RD.Id As DocumentDetailId,@GUIDZero,
										R.BaseCurrency,R.ExchangeRate,@DocType,@DocSubType,RD.ServiceCompanyId,R.DocNo,RD.Nature,RD.DocumentNo,0 As IsTax,
										EntityId,R.SystemRefNo,@DocCurrency,DocDate,DocDate,@RecOrder As RecOrder
									From Bean.Receipt(Nolock) As R
									Inner Join bean.ReceiptDetail(Nolock) As RD On RD.ReceiptId=R.Id
									Where R.Id=@SourceId And RD.Id=@RecieptDtlId
								End
								Set @RecCount=@RecCount+1
							End
							Set @RdtlRecCount=@RdtlRecCount+1
						End
					End
				End	
			End
			Else /*Single Company*/
			Begin
				Set @MasterJournalId=NEWID()
				Set @MasterSystemRefNo=CONCAT(@DocNo,'-JV',@SysRefNum_Incr)

				Insert Into Bean.Journal (Id,CompanyId,DocDate,DocType,DocSubType,DocNo,ServiceCompanyId,SystemReferenceNo,IsNoSupportingDocs,NoSupportingDocument,DocCurrency,ExchangeRate,ExCurrency,ExDurationFrom,GSTExchangeRate,GSTExCurrency,GSTTotalAmount,DocumentState,IsNoSupportingDocument,IsGstSettings,IsMultiCurrency,IsAllowableNonAllowable,IsGSTCurrencyRateChanged,Remarks,UserCreated,CreatedDate,Status,DocumentDescription,CreationType,GrandDocDebitTotal,GrandDocCreditTotal,GrandBaseDebitTotal,
							GrandBaseCreditTotal,EntityId,EntityType,PostingDate,COAId,ModeOfReceipt,BankReceiptAmmount,ExcessPaidByClientAmmount,BalancingItemReciveCRAmount,  BalancingItemPayDRAmount,ReceiptApplicationAmmount,DocumentId, BankClearingDate ,IsBalancing,ISAllowDisAllow, IsShow, ActualSysRefNo 
							,IsSegmentReporting,TransferRefNo
						 )
				Select @MasterJournalId,@CompanyId,DocDate,@DocType,@DocSubType,DocNo,ServiceCompanyId,@MasterSystemRefNo As SystemRefNo,IsNoSupportingDocument,NoSupportingDocs,DocCurrency,ExchangeRate,ExCurrency,ExDurationFrom,GSTExchangeRate,GSTExCurrency,Isnull(GSTTotalAmount,0),DocumentState,NoSupportingDocs,IsGstSettings,IsMultiCurrency,IsAllowableDisallowable,IsGSTCurrencyRateChanged,Remarks,@UserCreated,@CreatedDate,Status,Remarks As DocDescription,@UserCreated,GrandTotal,0.00 As GrandDocCreditTotal,GrandTotal * Round(ExchangeRate,2) As GrandBaseDebitTotal,
						0.00 As GrandBaseCreditTotal,EntityId,EntityType,DocDate As PostingDate,COAId,ModeOfReceipt,0.00 As BankReceiptAmmount,0.00 As ExcessPaidByClientAmmount,0.00 As BalancingItemReciveCRAmount,0.00 As BalancingItemPayDRAmount,0.00 As ReceiptApplicationAmmount,Id As DocumentId,BankClearingDate,0 As IsBalancing,IsDisAllow,1 As IsShow,DocNo As ActualSysRefNo,0 As IsSegmentReporting,ReceiptRefNo
				From Bean.Receipt(Nolock) Where CompanyId=@CompanyId And Id=@SourceId

				/* Detailed Records  */
				IF @DocCurrency=@BankChargesCurrency And @BaseCurrency=@DocCurrency
				Begin
					/* Creating Mater record In JournalDetail */
					IF Exists (Select Id From Bean.Receipt(Nolock) Where Id=@SourceId And GrandTotal<>0)
					Begin
						Insert Into Bean.JournalDetail (Id,JournalId,COAId,AccountDescription,AllowDisAllow, DocDebit, BaseDebit, DocDebitTotal,DocCreditTotal,BaseDebitTotal,BaseCreditTotal,DocumentId,DocumentDetailId,ItemId,BaseCurrency,ExchangeRate,GSTExCurrency,GSTExchangeRate,DocType,DocSubType,ServiceCompanyId,DocNo, IsTax,
										EntityId, SystemRefNo, DocCurrency,DocDate, PostingDate,RecOrder)
						Select NEWID(),@MasterJournalId,COAId,Remarks,IsDisAllow,Isnull(BankReceiptAmmount,0) As BankReceiptAmmount,Round(Isnull(BankReceiptAmmount,0) * ExchangeRate,2),0.00 As DocDebitTotal,0.00 As DocCreditTotal,0.00 As BaseDebitTotal,0.00 As BaseCreditTotal,Id As DocumentId,@GUIDZero,@GUIDZero,
								BaseCurrency,ExchangeRate,GSTExCurrency,GSTExchangeRate,@DocType,@DocSubType,ServiceCompanyId,DocNo,0 As IsTax,
								EntityId,@MasterSystemRefNo As SystemRefNo,@BankChargesCurrency,DocDate,DocDate,@RecOrder As RecOrder
						From Bean.Receipt(Nolock) Where Id=@SourceId
					End
					Else IF Exists (Select Id From Bean.Receipt(Nolock) Where Id=@SourceId And GrandTotal=0 And BankReceiptAmmount<>0)
					Begin
						Insert Into Bean.JournalDetail (Id,JournalId,COAId,AccountDescription,AllowDisAllow, DocDebit, BaseDebit, DocDebitTotal,DocCreditTotal,BaseDebitTotal,BaseCreditTotal,DocumentId,DocumentDetailId,ItemId,BaseCurrency,ExchangeRate,GSTExCurrency,GSTExchangeRate,DocType,DocSubType,ServiceCompanyId,DocNo, IsTax,
										EntityId, SystemRefNo, DocCurrency,DocDate, PostingDate,RecOrder )
						Select NEWID(),@MasterJournalId,COAId,Remarks,IsDisAllow,Isnull(BankReceiptAmmount,0) As BankReceiptAmmount,Round(Isnull(BankReceiptAmmount,0) * ExchangeRate,2),0.00 As DocDebitTotal,0.00 As DocCreditTotal,0.00 As BaseDebitTotal,0.00 As BaseCreditTotal,Id As DocumentId,@GUIDZero,@GUIDZero,
								BaseCurrency,ExchangeRate,GSTExCurrency,GSTExchangeRate,@DocType,@DocSubType,ServiceCompanyId,DocNo,0 As IsTax,
								EntityId,@MasterSystemRefNo As SystemRefNo,@BankChargesCurrency,DocDate,DocDate,@RecOrder As RecOrder
						From Bean.Receipt(Nolock) Where Id=@SourceId
					End
					/* Creating Record in Journaldetail With Bank Charges Amount */
					If Exists(Select Id From Bean.Receipt(Nolock) Where Id=@SourceId And BankCharges Is Not Null)
					Begin
						Set @RecOrder=@RecOrder+1
						Insert Into Bean.JournalDetail (Id,JournalId,COAId,AccountDescription,AllowDisAllow,TaxId,TaxType,TaxRate,DocDebit, BaseDebit, DocDebitTotal,DocCreditTotal,BaseDebitTotal,BaseCreditTotal,DocumentId,DocumentDetailId,ItemId,BaseCurrency,ExchangeRate,GSTExCurrency,GSTExchangeRate,DocType,DocSubType,ServiceCompanyId,DocNo, IsTax,
													EntityId, SystemRefNo, DocCurrency,DocDate, PostingDate,RecOrder,GSTTaxDebit)
						Select NEWID(),@MasterJournalId,@BankCharges_COAId,Remarks,IsDisAllow,@TaxId,@TaxType,@TaxRate,BankCharges,BankCharges * Round(ExchangeRate,2),0.00 As DocDebitTotal,0.00 As DocCreditTotal,0.00 As BaseDebitTotal,0.00 As BaseCreditTotal,Id As DocumentId,Id As DocumentDetailId,@GUIDZero,
							BaseCurrency,ExchangeRate,GSTExCurrency,GSTExchangeRate,@DocType,@DocSubType,ServiceCompanyId,DocNo,0 As IsTax,
							EntityId,@MasterSystemRefNo As SystemRefNo,@BankChargesCurrency,DocDate,DocDate,@RecOrder As RecOrder,
							Case When @TaxId Is Not Null Then Round(BankCharges * Coalesce(GSTexchangerate,@DefaultExchangeRate),2) End As GSTTaxDebit
						From Bean.Receipt(Nolock) 
						Where Id=@SourceId
					End
					/* Creating Record in Journaldetail With @ExcesPaidByClientAmt Amount */
					If @ExcesPaidByClientAmt Is NOt Null
					Begin
						Set @RecOrder=@RecOrder+1
						Insert Into Bean.JournalDetail (Id,JournalId,COAId,AccountDescription,AllowDisAllow, DocCredit, BaseCredit, DocDebitTotal,DocCreditTotal,BaseDebitTotal,BaseCreditTotal,DocumentId,DocumentDetailId,ItemId,BaseCurrency,ExchangeRate,GSTExCurrency,GSTExchangeRate,DocType,DocSubType,ServiceCompanyId,DocNo, IsTax,
														EntityId, SystemRefNo, DocCurrency,DocDate, PostingDate,RecOrder )
						Select NEWID(),@MasterJournalId,@ClearingReceiptsCOAID,Remarks,IsDisAllow,ExcessPaidByClientAmmount,ExcessPaidByClientAmmount * Round(ExchangeRate,2),0.00 As DocDebitTotal,0.00 As DocCreditTotal,0.00 As BaseDebitTotal,0.00 As BaseCreditTotal,Id As DocumentId,Id As DocumentDtlId,@GUIDZero,
								BaseCurrency,ExchangeRate,BankReceiptAmmountCurrency,ExchangeRate,@DocType,@DocSubType,ServiceCompanyId,DocNo,0 As IsTax,
								EntityId,@MasterSystemRefNo,@BankChargesCurrency,DocDate,DocDate,@RecOrder As RecOrder
						From Bean.Receipt(Nolock) 
						Where Id=@SourceId
					End
					/* Creating Balancing Line Items */
					Insert Into @RecieptBalLnItm
					Select RBI.Id From Bean.ReceiptBalancingItem(Nolock) As RBI
					Inner Join bean.Receipt(Nolock) As R On R.Id=RBI.ReceiptId
					Where R.Id=@SourceId Order by RecOrder
					Set @Count=(Select Count(*) From @RecieptBalLnItm)
					Set @RecCount=1
					While @Count>=@RecCount
					Begin
						Select @RecieptBalId=RecieptBalId From @RecieptBalLnItm Where S_no=@RecCount
						Select @TaxId=TaxId,@TaxRate=TaxRate From Bean.ReceiptBalancingItem(Nolock) Where Id=@RecieptBalId
						Set @RecOrder=@RecOrder+1
						Insert Into Bean.JournalDetail (Id,JournalId,COAId,AccountDescription,AllowDisAllow,TaxId,TaxType,TaxRate,DocDebit,DocCredit,
													DocTaxDebit,DocTaxCredit,BaseDebit,BaseCredit,
													BaseTaxDebit,BaseTaxCredit,DocDebitTotal,DocCreditTotal,BaseDebitTotal,BaseCreditTotal,DocumentId,DocumentDetailId,ItemId,BaseCurrency,ExchangeRate,GSTExCurrency,GSTExchangeRate,DocType,DocSubType,ServiceCompanyId,DocNo, IsTax,
													EntityId, SystemRefNo, DocCurrency,DocDate, PostingDate,RecOrder,GSTTaxDebit,GSTTaxCredit,GSTDebit,GSTCredit)
						Select NEWID(),@MasterJournalId,RBi.COAId,R.Remarks,RBI.IsDisAllow,RBI.TaxId,RBI.TaxType,Rbi.TaxRate,Case When RBI.ReciveORPay=@Pay_Dr Then RBI.DocAmount End As DocDebit,Case When RBI.ReciveORPay=@Receive_Cr Then RBI.DocAmount End As DocCredit,
							Case When RBI.ReciveORPay=@Pay_Dr Then RBI.DocTaxAmount End As DocTaxDebdit,Case When RBI.ReciveORPay=@Receive_Cr Then RBI.DocTaxAmount End As DocTaxCredit,
							Case When RBI.ReciveORPay=@Pay_Dr Then RBI.DocAmount * Round(@DefaultExchangeRate,2) End As BaseDebit,
							Case When RBI.ReciveORPay=@Receive_Cr Then RBI.DocAmount * Round(@DefaultExchangeRate,2) End As BaseCredit,
							Case When RBI.ReciveORPay=@Pay_Dr Then RBI.DocTaxAmount * Round(@DefaultExchangeRate,2) End As BaseTaxDebdit,Case When RBI.ReciveORPay=@Receive_Cr Then RBI.DocTaxAmount * Round(@DefaultExchangeRate,2) End As BaseTaxCredit,0.00 As DocDebitTotal,0.00 As DocCreditTotal,0.00 As BaseDebitTotal,0.00 As BaseCreditTotal,R.Id As DocumentId,RBI.Id As DocumentDetailId,@GUIDZero,
							R.BaseCurrency,R.ExchangeRate,R.GSTExCurrency,R.GSTExchangeRate,@DocType,@DocSubType,ServiceCompanyId,DocNo,0 As IsTax,
							EntityId,@MasterSystemRefNo,@BankChargesCurrency,DocDate,DocDate,@RecOrder As RecOrder,
							Case When RBI.ReciveORPay=@Pay_Dr Then Round(RBI.DocAmount * Coalesce(R.GSTExchangeRate,@DefaultExchangeRate),2) End As GSTTaxDebit,
							Case When RBI.ReciveORPay=@Receive_Cr Then Round(RBI.DocAmount * Coalesce(R.GSTExchangeRate,@DefaultExchangeRate),2) End As GSTTaxCredit,
							Case When RBI.ReciveORPay=@Pay_Dr Then Round(RBI.DocTaxAmount * Coalesce(R.GSTExchangeRate,@DefaultExchangeRate),2) End As GSTDebit,
							Case When RBI.ReciveORPay=@Receive_Cr Then Round(RBI.DocTaxAmount * Coalesce(R.GSTExchangeRate,@DefaultExchangeRate),2) End As GSTCredit
						From Bean.Receipt(Nolock) As R
						Inner Join bean.ReceiptBalancingItem(Nolock) As RBI On RBI.ReceiptId=R.Id
						Where R.Id=@SourceId And Rbi.Id=@RecieptBalId
						-- Creating Tax Line Items
						If @GST Is Not Null And @GST=1 And @TaxId Is Not Null And (@TaxRate Is Not Null And @TaxRate<>0)
						Begin
							Set @TaxRecCount=@RecOrder+@Count
							Insert Into Bean.JournalDetail (Id,JournalId,COAId,AccountDescription,AllowDisAllow,TaxId,TaxType,TaxRate,DocDebit,DocCredit,
									 BaseDebit,BaseCredit,
									 DocDebitTotal,DocCreditTotal,BaseDebitTotal,BaseCreditTotal,DocumentId,DocumentDetailId,ItemId,BaseCurrency,ExchangeRate,GSTExCurrency,GSTExchangeRate,DocType,DocSubType,ServiceCompanyId,DocNo, IsTax,
									EntityId, SystemRefNo, DocCurrency,DocDate, PostingDate,RecOrder )
							Select NEWID(),@MasterJournalId,@TaxPayableGST_COAID as COAId,R.Remarks,RBI.IsDisAllow,RBI.TaxId,RBI.TaxType,Rbi.TaxRate,Case When RBI.ReciveORPay=@Pay_Dr Then RBI.DocTaxAmount End As DocDebit,Case When RBI.ReciveORPay=@Receive_Cr Then RBI.DocTaxAmount End As DocCredit,
								Case When RBI.ReciveORPay=@Pay_Dr Then RBI.DocTaxAmount * Round(R.GSTExchangeRate,2) End As BaseDebit,Case When RBI.ReciveORPay=@Receive_Cr Then RBI.DocTaxAmount * Round(R.GSTExchangeRate,2) End As BaseCredit,
								0.00 As DocDebitTotal,0.00 As DocCreditTotal,0.00 As BaseDebitTotal,0.00 As BaseCreditTotal,R.Id As DocumentId,RBI.Id As DocumentDetailId,@GUIDZero,
								R.BaseCurrency,R.ExchangeRate,R.GSTExCurrency,R.GSTExchangeRate,@DocType,@DocSubType,ServiceCompanyId,DocNo,1 As IsTax,
								EntityId,@MasterSystemRefNo,@BankChargesCurrency,DocDate,DocDate,@TaxRecCount As RecOrder
							From Bean.Receipt(Nolock) As R
							Inner Join bean.ReceiptBalancingItem(Nolock) As RBI On RBI.ReceiptId=R.Id
							Where R.Id=@SourceId And Rbi.Id=@RecieptBalId
							Set @RecOrder=@RecOrder+1
						End
						Set @RecCount=@RecCount+1
					End
					IF Exists (Select Id From Bean.ReceiptDetail(Nolock) Where ReceiptId=@SourceId And ReceiptAmount<>0)
					Begin
						-- Creating Records For Interco In Journal Detail
						Insert Into @RecieptDtl 
						Select RD.Id From Bean.ReceiptDetail(Nolock) As RD
						Inner Join Bean.Receipt(Nolock) As R On RD.ReceiptId=R.Id 
						Where R.Id=@SourceId And RD.ReceiptAmount<>0 Order By RD.RecOrder 
						Set @Count=(Select Count(*) From @RecieptDtl)
						--Set @RecOrder=2
						Set @RecCount=1
						While @Count>=@RecCount
						Begin
							Set @RecieptDtlId=(Select RecieptDtlId From @RecieptDtl Where S_No=@RecCount)
							Set @DocumentId=(Select DocumentId From Bean.ReceiptDetail(Nolock) Where Id=@RecieptDtlId)
							Set @IsRoundingAmount=0
							--Getting COAID By Checking Nature
							IF Exists (Select ID From Bean.ReceiptDetail(Nolock) Where id=@RecieptDtlId And Nature=@NatureTrade)
							Begin
								Set @COAID=(Select Id From Bean.ChartOfAccount(Nolock) Where CompanyId=@CompanyId And Name=@COATradeReceivables)
							End
							Else IF Exists (Select ID From Bean.ReceiptDetail(Nolock) Where id=@RecieptDtlId And Nature=@NatureOthers)
							Begin
								Set @COAID=(Select Id From Bean.ChartOfAccount(Nolock) Where CompanyId=@CompanyId And Name=@COAotherReceivables)
							End
							IF Exists (Select ID From Bean.ReceiptDetail(Nolock) Where id=@RecieptDtlId And DocumentType=@InvoiceDocument)
							Begin
								IF Exists(Select Id From Bean.Invoice(Nolock) Where Id=@DocumentId And DocumentState In (@FullyApplied,@Fullypaid))
								Begin
									Set @IsRoundingAmount=1
								End
							End
							Else IF Exists (Select ID From Bean.ReceiptDetail(Nolock) Where id=@RecieptDtlId And DocumentType=@DebitNoteDocument)
							Begin
								IF Exists(Select Id From Bean.DebitNote(Nolock) Where Id=@DocumentId And DocumentState In (@FullyApplied,@Fullypaid))
								Begin
									Set @IsRoundingAmount=1
								End
							End
							IF @IsRoundingAmount=1 And Exists (Select Amount From @RoundingAmountDetails Where DocumentId=@DocumentId And Amount Is Not Null And Amount<>'')
							Begin
								Set @DocAmount=(Select Amount From @RoundingAmountDetails Where DocumentId=@DocumentId)
							End
							Else
							Begin
								Set @DocAmount=0
							End
							Insert Into Bean.JournalDetail (Id,JournalId,COAId,AccountDescription, DocDebit,DocCredit,
													 BaseDebit,BaseCredit,
													 DocDebitTotal,DocCreditTotal,BaseDebitTotal,BaseCreditTotal,DocumentId,DocumentDetailId,ItemId,BaseCurrency,ExchangeRate, DocType,DocSubType,ServiceCompanyId,DocNo,Nature,OffsetDocument,IsTax,
													EntityId, SystemRefNo, DocCurrency,DocDate, PostingDate,RecOrder 
													)
							Select NEWID(),@MasterJournalId,@COAID,R.Remarks,Null As DocDebit,RD.ReceiptAmount As DocCredit,
								Null As BaseDebit,RD.ReceiptAmount * Round(R.ExchangeRate,2)- Isnull(@DocAmount,0) As BaseCredit,
								0.00 As DocDebitTotal,0.00 As DocCreditTotal,0.00 As BaseDebitTotal,0.00 As BaseCreditTotal,R.Id As DocumentId,RD.Id As DocumentDetailId,@GUIDZero,
								R.BaseCurrency,R.ExchangeRate,@DocType,@DocSubType,@MasterServComp As ServiceCompanyId,R.DocNo,RD.Nature,RD.DocumentNo,0 As IsTax,
								R.EntityId,@MasterSystemRefNo,@BankChargesCurrency,R.DocDate,R.DocDate,@RecOrder As RecOrder
							From Bean.Receipt(Nolock) As R
							Inner Join bean.ReceiptDetail(Nolock) As RD On RD.ReceiptId=R.Id
							Where R.Id=@SourceId And RD.Id=@RecieptDtlId
							Set @RecOrder=@RecOrder+1
							Set @RecCount=@RecCount+1
						End
					End
				End
				Else IF @DocCurrency=@BankChargesCurrency And @BaseCurrency<>@DocCurrency
				Begin
					/* Creating Mater record In JournalDetail */
					IF Exists (Select Id From Bean.Receipt(Nolock) Where Id=@SourceId And GrandTotal<>0)
					Begin
						Insert Into Bean.JournalDetail (Id,JournalId,COAId,AccountDescription,AllowDisAllow, DocDebit, BaseDebit, DocDebitTotal,DocCreditTotal,BaseDebitTotal,BaseCreditTotal,DocumentId,DocumentDetailId,ItemId,BaseCurrency,ExchangeRate,GSTExCurrency,GSTExchangeRate,DocType,DocSubType,ServiceCompanyId,DocNo, IsTax,
										EntityId, SystemRefNo, DocCurrency,DocDate, PostingDate,RecOrder )
						Select NEWID(),@MasterJournalId,COAId,Remarks,IsDisAllow,Isnull(BankReceiptAmmount,0) As BankReceiptAmmount,Round(Isnull(BankReceiptAmmount,0) * ExchangeRate,2),0.00 As DocDebitTotal,0.00 As DocCreditTotal,0.00 As BaseDebitTotal,0.00 As BaseCreditTotal,Id As DocumentId,@GUIDZero,@GUIDZero,
								BaseCurrency,ExchangeRate,GSTExCurrency,GSTExchangeRate,@DocType,@DocSubType,ServiceCompanyId,DocNo,0 As IsTax,
								EntityId,@MasterSystemRefNo As SystemRefNo,@BankChargesCurrency,DocDate,DocDate,@RecOrder As RecOrder
						From Bean.Receipt(Nolock) Where Id=@SourceId
					End
					Else IF Exists (Select Id From Bean.Receipt(Nolock) Where Id=@SourceId And GrandTotal=0 And BankReceiptAmmount<>0)
					Begin
						Insert Into Bean.JournalDetail (Id,JournalId,COAId,AccountDescription,AllowDisAllow, DocDebit, BaseDebit, DocDebitTotal,DocCreditTotal,BaseDebitTotal,BaseCreditTotal,DocumentId,DocumentDetailId,ItemId,BaseCurrency,ExchangeRate,GSTExCurrency,GSTExchangeRate,DocType,DocSubType,ServiceCompanyId,DocNo, IsTax,
										EntityId, SystemRefNo, DocCurrency,DocDate, PostingDate,RecOrder )
						Select NEWID(),@MasterJournalId,COAId,Remarks,IsDisAllow,Isnull(BankReceiptAmmount,0) As BankReceiptAmmount,Round(ISnull(BankReceiptAmmount,0) * ExchangeRate,2),0.00 As DocDebitTotal,0.00 As DocCreditTotal,0.00 As BaseDebitTotal,0.00 As BaseCreditTotal,Id As DocumentId,@GUIDZero,@GUIDZero,
								BaseCurrency,ExchangeRate,GSTExCurrency,GSTExchangeRate,@DocType,@DocSubType,ServiceCompanyId,DocNo,0 As IsTax,
								EntityId,@MasterSystemRefNo As SystemRefNo,@BankChargesCurrency,DocDate,DocDate,@RecOrder As RecOrder
						From Bean.Receipt(Nolock) Where Id=@SourceId
					End
					/* Creating Record in Journaldetail With Bank Charges Amount */
					If Exists(Select Id From Bean.Receipt(Nolock) Where Id=@SourceId And BankCharges Is Not Null)
					Begin
						Set @RecOrder=@RecOrder+1
						Insert Into Bean.JournalDetail (Id,JournalId,COAId,AccountDescription,AllowDisAllow,TaxId,TaxType,TaxRate,DocDebit, BaseDebit, DocDebitTotal,DocCreditTotal,BaseDebitTotal,BaseCreditTotal,DocumentId,DocumentDetailId,ItemId,BaseCurrency,ExchangeRate,GSTExCurrency,GSTExchangeRate,DocType,DocSubType,ServiceCompanyId,DocNo, IsTax,
													EntityId, SystemRefNo, DocCurrency,DocDate, PostingDate,RecOrder,GSTTaxDebit)
						Select NEWID(),@MasterJournalId,@BankCharges_COAId,Remarks,IsDisAllow,@TaxId,@TaxType,@TaxRate,BankCharges,Round(BankCharges * ExchangeRate,2),0.00 As DocDebitTotal,0.00 As DocCreditTotal,0.00 As BaseDebitTotal,0.00 As BaseCreditTotal,Id As DocumentId,Id As DocumentDetailId,@GUIDZero,
							BaseCurrency,ExchangeRate,GSTExCurrency,GSTExchangeRate,@DocType,@DocSubType,ServiceCompanyId,DocNo,0 As IsTax,
							EntityId,@MasterSystemRefNo As SystemRefNo,@BankChargesCurrency,DocDate,DocDate,@RecOrder As RecOrder,
							Case When @TaxId Is Not Null Then Round(BankCharges * Coalesce(GSTexchangerate,@DefaultExchangeRate),2) End As GSTTaxDebit
						From Bean.Receipt(Nolock)
						Where Id=@SourceId
					End
					/* Creating Record in Journaldetail With @ExcesPaidByClientAmt Amount */
					If @ExcesPaidByClientAmt Is NOt Null
					Begin
						Set @RecOrder=@RecOrder+1
						Insert Into Bean.JournalDetail (Id,JournalId,COAId,AccountDescription,AllowDisAllow, DocCredit, BaseCredit, DocDebitTotal,DocCreditTotal,BaseDebitTotal,BaseCreditTotal,DocumentId,DocumentDetailId,ItemId,BaseCurrency,ExchangeRate,GSTExCurrency,GSTExchangeRate,DocType,DocSubType,ServiceCompanyId,DocNo, IsTax,
														EntityId, SystemRefNo, DocCurrency,DocDate, PostingDate,RecOrder )
						Select NEWID(),@MasterJournalId,@ClearingReceiptsCOAID,Remarks,IsDisAllow,ExcessPaidByClientAmmount,Round(ExcessPaidByClientAmmount * ExchangeRate,2),0.00 As DocDebitTotal,0.00 As DocCreditTotal,0.00 As BaseDebitTotal,0.00 As BaseCreditTotal,Id As DocumentId,Id As DocumentDtlId,@GUIDZero,
								BaseCurrency,ExchangeRate,BankReceiptAmmountCurrency,ExchangeRate,@DocType,@DocSubType,ServiceCompanyId,DocNo,0 As IsTax,
								EntityId,@MasterSystemRefNo,@BankChargesCurrency,DocDate,DocDate,@RecOrder As RecOrder
						From Bean.Receipt(Nolock) 
						Where Id=@SourceId
					End
					/* Creating Balancing Line Items */
					Insert Into @RecieptBalLnItm
					Select RBI.Id From Bean.ReceiptBalancingItem(Nolock) As RBI
					Inner Join bean.Receipt(Nolock) As R On R.Id=RBI.ReceiptId
					Where R.Id=@SourceId Order by RecOrder
					Set @Count=(Select Count(*) From @RecieptBalLnItm)
					Set @RecCount=1
					While @Count>=@RecCount
					Begin
						Select @RecieptBalId=RecieptBalId From @RecieptBalLnItm Where S_no=@RecCount
						Select @TaxId=TaxId,@TaxRate=TaxRate From Bean.ReceiptBalancingItem(Nolock) Where Id=@RecieptBalId
						Set @RecOrder=@RecOrder+1
						Insert Into Bean.JournalDetail (Id,JournalId,COAId,AccountDescription,AllowDisAllow,TaxId,TaxType,TaxRate,DocDebit,DocCredit,
													DocTaxDebit,DocTaxCredit,BaseDebit,BaseCredit,
													BaseTaxDebit,BaseTaxCredit,DocDebitTotal,DocCreditTotal,BaseDebitTotal,BaseCreditTotal,DocumentId,DocumentDetailId,ItemId,BaseCurrency,ExchangeRate,GSTExCurrency,GSTExchangeRate,DocType,DocSubType,ServiceCompanyId,DocNo, IsTax,
													EntityId, SystemRefNo, DocCurrency,DocDate, PostingDate,RecOrder,GSTTaxDebit,GSTTaxCredit,GSTDebit,GSTCredit)
						Select NEWID(),@MasterJournalId,RBi.COAId,R.Remarks,RBI.IsDisAllow,RBI.TaxId,RBI.TaxType,Rbi.TaxRate,Case When RBI.ReciveORPay=@Pay_Dr Then RBI.DocAmount End As DocDebit,Case When RBI.ReciveORPay=@Receive_Cr Then RBI.DocAmount End As DocCredit,
							Case When RBI.ReciveORPay=@Pay_Dr Then RBI.DocTaxAmount End As DocTaxDebdit,Case When RBI.ReciveORPay=@Receive_Cr Then RBI.DocTaxAmount End As DocTaxCredit,
							Case When RBI.ReciveORPay=@Pay_Dr Then Round(RBI.DocAmount * R.ExchangeRate,2) End As BaseDebit,
							Case When RBI.ReciveORPay=@Receive_Cr Then Round(RBI.DocAmount * R.ExchangeRate,2) End As BaseCredit,
							Case When RBI.ReciveORPay=@Pay_Dr Then RBI.DocTaxAmount * Round(@MainExchangeRate,2) End As BaseTaxDebdit,Case When RBI.ReciveORPay=@Receive_Cr Then RBI.DocTaxAmount * Round(@MainExchangeRate,2) End As BaseTaxCredit,0.00 As DocDebitTotal,0.00 As DocCreditTotal,0.00 As BaseDebitTotal,0.00 As BaseCreditTotal,R.Id As DocumentId,RBI.Id As DocumentDetailId,@GUIDZero,
							R.BaseCurrency,R.ExchangeRate,R.GSTExCurrency,R.GSTExchangeRate,@DocType,@DocSubType,ServiceCompanyId,DocNo,0 As IsTax,
							EntityId,@MasterSystemRefNo,@BankChargesCurrency,DocDate,DocDate,@RecOrder As RecOrder,
							Case When RBI.ReciveORPay=@Pay_Dr Then Round(RBI.DocAmount * Coalesce(R.GSTExchangeRate,@DefaultExchangeRate),2) End As GSTTaxDebit,
							Case When RBI.ReciveORPay=@Receive_Cr Then Round(RBI.DocAmount * Coalesce(R.GSTExchangeRate,@DefaultExchangeRate),2) End As GSTTaxCredit,
							Case When RBI.ReciveORPay=@Pay_Dr Then Round(RBI.DocTaxAmount * Coalesce(R.GSTExchangeRate,@DefaultExchangeRate),2) End As GSTDebit,
							Case When RBI.ReciveORPay=@Receive_Cr Then Round(RBI.DocTaxAmount * Coalesce(R.GSTExchangeRate,@DefaultExchangeRate),2) End As GSTCredit
						From Bean.Receipt(Nolock) As R
						Inner Join bean.ReceiptBalancingItem(Nolock) As RBI On RBI.ReceiptId=R.Id
						Where R.Id=@SourceId And Rbi.Id=@RecieptBalId
						-- Creating Tax Line Items
						If @GST Is Not Null And @GST=1 And @TaxId Is Not Null And (@TaxRate Is Not Null And @TaxRate<>0)
						Begin
							Set @TaxRecCount=@RecOrder+@Count
							Insert Into Bean.JournalDetail (Id,JournalId,COAId,AccountDescription,AllowDisAllow,TaxId,TaxType,TaxRate,DocDebit,DocCredit,
									 BaseDebit,BaseCredit,
									 DocDebitTotal,DocCreditTotal,BaseDebitTotal,BaseCreditTotal,DocumentId,DocumentDetailId,ItemId,BaseCurrency,ExchangeRate,GSTExCurrency,GSTExchangeRate,DocType,DocSubType,ServiceCompanyId,DocNo, IsTax,
									EntityId, SystemRefNo, DocCurrency,DocDate, PostingDate,RecOrder )
							Select NEWID(),@MasterJournalId,@TaxPayableGST_COAID as COAId,R.Remarks,RBI.IsDisAllow,RBI.TaxId,RBI.TaxType,Rbi.TaxRate,Case When RBI.ReciveORPay=@Pay_Dr Then RBI.DocTaxAmount End As DocDebit,Case When RBI.ReciveORPay=@Receive_Cr Then RBI.DocTaxAmount End As DocCredit,
								Case When RBI.ReciveORPay=@Pay_Dr Then Round(RBI.DocTaxAmount * R.ExchangeRate,2) End As BaseDebit,Case When RBI.ReciveORPay=@Receive_Cr Then Round(RBI.DocTaxAmount * R.ExchangeRate,2) End As BaseCredit,
								0.00 As DocDebitTotal,0.00 As DocCreditTotal,0.00 As BaseDebitTotal,0.00 As BaseCreditTotal,R.Id As DocumentId,RBI.Id As DocumentDetailId,@GUIDZero,
								R.BaseCurrency,R.ExchangeRate,R.GSTExCurrency,R.GSTExchangeRate,@DocType,@DocSubType,ServiceCompanyId,DocNo,1 As IsTax,
								EntityId,@MasterSystemRefNo,@BankChargesCurrency,DocDate,DocDate,@TaxRecCount As RecOrder
							From Bean.Receipt(Nolock) As R
							Inner Join bean.ReceiptBalancingItem(Nolock) As RBI On RBI.ReceiptId=R.Id
							Where R.Id=@SourceId And Rbi.Id=@RecieptBalId

							Set @RecOrder=@RecOrder+1
						End
						Set @RecCount=@RecCount+1
					End
					IF Exists (Select Id From Bean.ReceiptDetail(Nolock) Where ReceiptId=@SourceId And ReceiptAmount<>0)
					Begin
						-- Creating Records For Interco In Journal Detail
						Insert Into @RecieptDtl 
						Select RD.Id From Bean.ReceiptDetail(Nolock) As RD
						Inner Join Bean.Receipt(Nolock) As R On RD.ReceiptId=R.Id 
						Where R.Id=@SourceId And RD.ReceiptAmount<>0 Order By RD.RecOrder
						Set @Count=(Select Count(*) From @RecieptDtl)
						Set @RecCount=1
						While @Count>=@RecCount
						Begin
							Set @RecieptDtlId=(Select RecieptDtlId From @RecieptDtl Where S_No=@RecCount)
							Set @DocumentId=(Select DocumentId From Bean.ReceiptDetail(Nolock) Where Id=@RecieptDtlId)
							Set @IsRoundingAmount=0
							IF Exists (Select DocumentType From Bean.ReceiptDetail(Nolock) Where Id=@RecieptDtlId And DocumentType=@InvoiceDocument)
							Begin
								Set @ExchangeRate=(Select ExchangeRate From Bean.Invoice(Nolock) Where Id=@DocumentId)
								IF Exists(Select Id From Bean.Invoice(Nolock) Where Id=@DocumentId And DocumentState In (@FullyApplied,@Fullypaid))
								Begin
									Set @IsRoundingAmount=1
								End
							End
							Else IF Exists (Select DocumentType From Bean.ReceiptDetail(Nolock) Where Id=@RecieptDtlId And DocumentType=@DebitNoteDocument)
							Begin
								Set @ExchangeRate=(Select ExchangeRate From Bean.DebitNote(Nolock) Where Id=@DocumentId)
								IF Exists(Select Id From Bean.DebitNote(Nolock) Where Id=@DocumentId And DocumentState In (@FullyApplied,@Fullypaid))
								Begin
									Set @IsRoundingAmount=1
								End
							End
							IF @IsRoundingAmount=1 And Exists (Select Amount From @RoundingAmountDetails Where DocumentId=@DocumentId And Amount Is Not Null And Amount<>'')
							Begin
								Set @DocAmount=(Select Amount From @RoundingAmountDetails Where DocumentId=@DocumentId)
							End
							Else
							Begin
								Set @DocAmount=0
							End
							--Getting COAID By Checking Nature
							IF Exists (Select ID From Bean.ReceiptDetail(Nolock) Where id=@RecieptDtlId And Nature=@NatureTrade)
							Begin
								Set @COAID=(Select Id From Bean.ChartOfAccount(Nolock) Where CompanyId=@CompanyId And Name=@COATradeReceivables)
							End
							Else IF Exists (Select ID From Bean.ReceiptDetail(Nolock) Where id=@RecieptDtlId And Nature=@NatureOthers)
							Begin
								Set @COAID=(Select Id From Bean.ChartOfAccount(Nolock) Where CompanyId=@CompanyId And Name=@COAotherReceivables)
							End
							Set @RecOrder=@RecOrder+1
							Insert Into Bean.JournalDetail (Id,JournalId,COAId,AccountDescription, DocDebit,DocCredit,
													 BaseDebit,BaseCredit,
													 DocDebitTotal,DocCreditTotal,BaseDebitTotal,BaseCreditTotal,DocumentId,DocumentDetailId,ItemId,BaseCurrency,ExchangeRate, DocType,DocSubType,ServiceCompanyId,DocNo,Nature,OffsetDocument,IsTax,
													EntityId, SystemRefNo, DocCurrency,DocDate, PostingDate,RecOrder 
													)
							Select NEWID(),@MasterJournalId,@COAID,R.Remarks,Null As DocDebit,RD.ReceiptAmount As DocCredit,
								Null As BaseDebit,Round(RD.ReceiptAmount * @ExchangeRate,2)- Isnull(@DocAmount,0) As BaseCredit,
								0.00 As DocDebitTotal,0.00 As DocCreditTotal,0.00 As BaseDebitTotal,0.00 As BaseCreditTotal,R.Id As DocumentId,RD.Id As DocumentDetailId,@GUIDZero,
								R.BaseCurrency,R.ExchangeRate,@DocType,@DocSubType,@MasterServComp As ServiceCompanyId,R.DocNo,RD.Nature,RD.DocumentNo,0 As IsTax,
								R.EntityId,@MasterSystemRefNo,@BankChargesCurrency,R.DocDate,R.DocDate,@RecOrder As RecOrder
							From Bean.Receipt(Nolock) As R
							Inner Join bean.ReceiptDetail(Nolock) As RD On RD.ReceiptId=R.Id
							Where R.Id=@SourceId And RD.Id=@RecieptDtlId
							IF @MainExchangeRate-@ExchangeRate<>0
							Begin
								Set @RecOrder=@RecOrder+1
								-- ExchangeGainOrLossRealised
								Insert Into Bean.JournalDetail (Id,JournalId,COAId,AccountDescription, DocDebit,DocCredit,
																 BaseDebit,BaseCredit,
																 DocDebitTotal,DocCreditTotal,BaseDebitTotal,BaseCreditTotal,DocumentId,DocumentDetailId,ItemId,BaseCurrency,ExchangeRate, DocType,DocSubType,ServiceCompanyId,DocNo,Nature,OffsetDocument,IsTax,
																EntityId, SystemRefNo, DocCurrency,DocDate, PostingDate,RecOrder 
																)
								Select NEWID(),@MasterJournalId,@ExchangeGainOrLossCOAID,R.Remarks,Null As DocDebit,Null As DocCredit,
									Case When (@MainExchangeRate-@ExchangeRate)<0 Then ABS(Round((@MainExchangeRate-@ExchangeRate)*RD.ReceiptAmount,2))  End As BaseDebit,
									Case When (@MainExchangeRate-@ExchangeRate)>0 Then ABS(Round((@MainExchangeRate-@ExchangeRate)*RD.ReceiptAmount,2)) End As BaseCredit,
									0.00 As DocDebitTotal,0.00 As DocCreditTotal,0.00 As BaseDebitTotal,0.00 As BaseCreditTotal,R.Id As DocumentId,RD.Id As DocumentDetailId,@GUIDZero,
									R.BaseCurrency,R.ExchangeRate,@DocType,@DocSubType,@MasterServComp As ServiceCompanyId,R.DocNo,RD.Nature,RD.DocumentNo,0 As IsTax,
									EntityId,@MasterSystemRefNo,@BankChargesCurrency,DocDate,DocDate,@RecOrder As RecOrder
								From Bean.Receipt(Nolock) As R
								Inner Join bean.ReceiptDetail(Nolock) As RD On RD.ReceiptId=R.Id
								Where R.Id=@SourceId And RD.Id=@RecieptDtlId
							End
							Set @RecCount=@RecCount+1
						End
					End
				End
				Else IF @DocCurrency<>@BankChargesCurrency And @BaseCurrency=@DocCurrency
				Begin
					/* Creating Mater record In JournalDetail */
					IF Exists (Select Id From Bean.Receipt(Nolock) Where Id=@SourceId And GrandTotal<>0)
					Begin
						Insert Into Bean.JournalDetail (Id,JournalId,COAId,AccountDescription,AllowDisAllow, DocDebit, BaseDebit, DocDebitTotal,DocCreditTotal,BaseDebitTotal,BaseCreditTotal,DocumentId,DocumentDetailId,ItemId,BaseCurrency,ExchangeRate,GSTExCurrency,GSTExchangeRate,DocType,DocSubType,ServiceCompanyId,DocNo, IsTax,
										EntityId, SystemRefNo, DocCurrency,DocDate, PostingDate,RecOrder )
						Select NEWID(),@MasterJournalId,COAId,Remarks,IsDisAllow,Isnull(BankReceiptAmmount,0) As BankReceiptAmmount,Round(Isnull(BankReceiptAmmount,0) * @SysCalExchangerate,2),0.00 As DocDebitTotal,0.00 As DocCreditTotal,0.00 As BaseDebitTotal,0.00 As BaseCreditTotal,Id As DocumentId,@GUIDZero,@GUIDZero,
								BaseCurrency,@SysCalExchangerate As ExchangeRate,GSTExCurrency,GSTExchangeRate,@DocType,@DocSubType,ServiceCompanyId,DocNo,0 As IsTax,
								EntityId,@MasterSystemRefNo As SystemRefNo,@BankChargesCurrency,DocDate,DocDate,@RecOrder As RecOrder
						From Bean.Receipt(Nolock) Where Id=@SourceId
					End
					Else IF Exists (Select Id From Bean.Receipt(Nolock) Where Id=@SourceId And GrandTotal=0 And BankReceiptAmmount<>0) 
					Begin
						Insert Into Bean.JournalDetail (Id,JournalId,COAId,AccountDescription,AllowDisAllow, DocDebit, BaseDebit, DocDebitTotal,DocCreditTotal,BaseDebitTotal,BaseCreditTotal,DocumentId,DocumentDetailId,ItemId,BaseCurrency,ExchangeRate,GSTExCurrency,GSTExchangeRate,DocType,DocSubType,ServiceCompanyId,DocNo, IsTax,
										EntityId, SystemRefNo, DocCurrency,DocDate, PostingDate,RecOrder )
						Select NEWID(),@MasterJournalId,COAId,Remarks,IsDisAllow,ISnull(BankReceiptAmmount,0) As BankReceiptAmmount,Round(ISnull(BankReceiptAmmount,0) * @SysCalExchangerate,2),0.00 As DocDebitTotal,0.00 As DocCreditTotal,0.00 As BaseDebitTotal,0.00 As BaseCreditTotal,Id As DocumentId,@GUIDZero,@GUIDZero,
								BaseCurrency,@SysCalExchangerate As ExchangeRate,GSTExCurrency,GSTExchangeRate,@DocType,@DocSubType,ServiceCompanyId,DocNo,0 As IsTax,
								EntityId,@MasterSystemRefNo As SystemRefNo,@BankChargesCurrency,DocDate,DocDate,@RecOrder As RecOrder
						From Bean.Receipt(Nolock) Where Id=@SourceId
					End
					/* Creating Record in Journaldetail With Bank Charges Amount */
					If Exists(Select Id From Bean.Receipt(Nolock) Where Id=@SourceId And BankCharges Is Not Null)
					Begin
						Set @RecOrder=@RecOrder+1
						Insert Into Bean.JournalDetail (Id,JournalId,COAId,AccountDescription,AllowDisAllow,TaxId,TaxType,TaxRate,DocDebit, BaseDebit, DocDebitTotal,DocCreditTotal,BaseDebitTotal,BaseCreditTotal,DocumentId,DocumentDetailId,ItemId,BaseCurrency,ExchangeRate,GSTExCurrency,GSTExchangeRate,DocType,DocSubType,ServiceCompanyId,DocNo, IsTax,
													EntityId, SystemRefNo, DocCurrency,DocDate, PostingDate,RecOrder,GSTTaxDebit)
						Select NEWID(),@MasterJournalId,@BankCharges_COAId,Remarks,IsDisAllow,@TaxId,@TaxType,@TaxRate,BankCharges,Round(BankCharges * @SysCalExchangerate,2),0.00 As DocDebitTotal,0.00 As DocCreditTotal,0.00 As BaseDebitTotal,0.00 As BaseCreditTotal,Id As DocumentId,Id As DocumentDetailId,@GUIDZero,
							BaseCurrency,@SysCalExchangerate As ExchangeRate,GSTExCurrency,GSTExchangeRate,@DocType,@DocSubType,ServiceCompanyId,DocNo,0 As IsTax,
							EntityId,@MasterSystemRefNo As SystemRefNo,@BankChargesCurrency,DocDate,DocDate,@RecOrder As RecOrder,
							Case When @TaxId Is Not Null Then Round(BankCharges * Coalesce(GSTexchangerate,@DefaultExchangeRate),2) End As GSTTaxDebit
						From Bean.Receipt(Nolock) 
						Where Id=@SourceId
					End
					/* Creating Record in Journaldetail With @ExcesPaidByClientAmt Amount */
					If @ExcesPaidByClientAmt Is NOt Null
					Begin
						Set @RecOrder=@RecOrder+1
						Insert Into Bean.JournalDetail (Id,JournalId,COAId,AccountDescription,AllowDisAllow, DocCredit, BaseCredit, DocDebitTotal,DocCreditTotal,BaseDebitTotal,BaseCreditTotal,DocumentId,DocumentDetailId,ItemId,BaseCurrency,ExchangeRate,GSTExCurrency,GSTExchangeRate,DocType,DocSubType,ServiceCompanyId,DocNo, IsTax,
														EntityId, SystemRefNo, DocCurrency,DocDate, PostingDate,RecOrder )
						Select NEWID(),@MasterJournalId,@ClearingReceiptsCOAID,Remarks,IsDisAllow,ExcessPaidByClientAmmount,Round(ExcessPaidByClientAmmount * @SysCalExchangerate,2),0.00 As DocDebitTotal,0.00 As DocCreditTotal,0.00 As BaseDebitTotal,0.00 As BaseCreditTotal,Id As DocumentId,Id As DocumentDtlId,@GUIDZero,
								BaseCurrency,@SysCalExchangerate As ExchangeRate,BankReceiptAmmountCurrency,ExchangeRate,@DocType,@DocSubType,ServiceCompanyId,DocNo,0 As IsTax,
								EntityId,@MasterSystemRefNo,@BankChargesCurrency,DocDate,DocDate,@RecOrder As RecOrder
						From Bean.Receipt(Nolock) 
						Where Id=@SourceId
					End
					/* Creating Balancing Line Items */
					Insert Into @RecieptBalLnItm
					Select RBI.Id From Bean.ReceiptBalancingItem(Nolock) As RBI
					Inner Join bean.Receipt(Nolock) As R On R.Id=RBI.ReceiptId
					Where R.Id=@SourceId Order by RecOrder
					Set @Count=(Select Count(*) From @RecieptBalLnItm)
					Set @RecCount=1
					While @Count>=@RecCount
					Begin
						Select @RecieptBalId=RecieptBalId From @RecieptBalLnItm Where S_no=@RecCount
						Select @TaxId=TaxId,@TaxRate=TaxRate From Bean.ReceiptBalancingItem(Nolock) Where Id=@RecieptBalId
						Set @RecOrder=@RecOrder+1
						Insert Into Bean.JournalDetail (Id,JournalId,COAId,AccountDescription,AllowDisAllow,TaxId,TaxType,TaxRate,DocDebit,DocCredit,
													DocTaxDebit,DocTaxCredit,BaseDebit,BaseCredit,
													BaseTaxDebit,BaseTaxCredit,DocDebitTotal,DocCreditTotal,BaseDebitTotal,BaseCreditTotal,DocumentId,DocumentDetailId,ItemId,BaseCurrency,ExchangeRate,GSTExCurrency,GSTExchangeRate,DocType,DocSubType,ServiceCompanyId,DocNo, IsTax,
													EntityId, SystemRefNo, DocCurrency,DocDate, PostingDate,RecOrder,GSTTaxDebit,GSTTaxCredit,GSTDebit,GSTCredit)
						Select NEWID(),@MasterJournalId,RBi.COAId,R.Remarks,RBI.IsDisAllow,RBI.TaxId,RBI.TaxType,Rbi.TaxRate,Case When RBI.ReciveORPay=@Pay_Dr Then RBI.DocAmount End As DocDebit,Case When RBI.ReciveORPay=@Receive_Cr Then RBI.DocAmount End As DocCredit,
							Case When RBI.ReciveORPay=@Pay_Dr Then RBI.DocTaxAmount End As DocTaxDebdit,Case When RBI.ReciveORPay=@Receive_Cr Then RBI.DocTaxAmount End As DocTaxCredit,
							Case When RBI.ReciveORPay=@Pay_Dr Then Round(RBI.DocAmount * @SysCalExchangerate,2) End As BaseDebit,
							Case When RBI.ReciveORPay=@Receive_Cr Then Round(RBI.DocAmount * @SysCalExchangerate,2) End As BaseCredit,
							Case When RBI.ReciveORPay=@Pay_Dr Then RBI.DocTaxAmount * Round(@SysCalExchangerate,2) End As BaseTaxDebdit,Case When RBI.ReciveORPay=@Receive_Cr Then RBI.DocTaxAmount * Round(@SysCalExchangerate,2) End As BaseTaxCredit,0.00 As DocDebitTotal,0.00 As DocCreditTotal,0.00 As BaseDebitTotal,0.00 As BaseCreditTotal,R.Id As DocumentId,RBI.Id As DocumentDetailId,@GUIDZero,
							R.BaseCurrency,@SysCalExchangerate As ExchangeRate,R.GSTExCurrency,R.GSTExchangeRate,@DocType,@DocSubType,ServiceCompanyId,DocNo,0 As IsTax,
							EntityId,@MasterSystemRefNo,@BankChargesCurrency,DocDate,DocDate,@RecOrder As RecOrder,
							Case When RBI.ReciveORPay=@Pay_Dr Then Round(RBI.DocAmount * Coalesce(R.GSTExchangeRate,@DefaultExchangeRate),2) End As GSTTaxDebit,
							Case When RBI.ReciveORPay=@Receive_Cr Then Round(RBI.DocAmount * Coalesce(R.GSTExchangeRate,@DefaultExchangeRate),2) End As GSTTaxCredit,
							Case When RBI.ReciveORPay=@Pay_Dr Then Round(RBI.DocTaxAmount * Coalesce(R.GSTExchangeRate,@DefaultExchangeRate),2) End As GSTDebit,
							Case When RBI.ReciveORPay=@Receive_Cr Then Round(RBI.DocTaxAmount * Coalesce(R.GSTExchangeRate,@DefaultExchangeRate),2) End As GSTCredit
						From Bean.Receipt(Nolock) As R
						Inner Join bean.ReceiptBalancingItem(Nolock) As RBI On RBI.ReceiptId=R.Id
						Where R.Id=@SourceId And Rbi.Id=@RecieptBalId
						-- Creating Tax Line Items
						If @GST Is Not Null And @GST=1 And @TaxId Is Not Null And (@TaxRate Is Not Null And @TaxRate<>0)
						Begin
							Set @TaxRecCount=@RecOrder+@Count
							Insert Into Bean.JournalDetail (Id,JournalId,COAId,AccountDescription,AllowDisAllow,TaxId,TaxType,TaxRate,DocDebit,DocCredit,
									 BaseDebit,BaseCredit,
									 DocDebitTotal,DocCreditTotal,BaseDebitTotal,BaseCreditTotal,DocumentId,DocumentDetailId,ItemId,BaseCurrency,ExchangeRate,GSTExCurrency,GSTExchangeRate,DocType,DocSubType,ServiceCompanyId,DocNo, IsTax,
									EntityId, SystemRefNo, DocCurrency,DocDate, PostingDate,RecOrder )
							Select NEWID(),@MasterJournalId,@TaxPayableGST_COAID as COAId,R.Remarks,RBI.IsDisAllow,RBI.TaxId,RBI.TaxType,Rbi.TaxRate,Case When RBI.ReciveORPay=@Pay_Dr Then RBI.DocTaxAmount End As DocDebit,Case When RBI.ReciveORPay=@Receive_Cr Then RBI.DocTaxAmount End As DocCredit,
								Case When RBI.ReciveORPay=@Pay_Dr Then Round(RBI.DocTaxAmount * @SysCalExchangerate,2) End As BaseDebit,Case When RBI.ReciveORPay=@Receive_Cr Then Round(RBI.DocTaxAmount * @SysCalExchangerate,2) End As BaseCredit,
								0.00 As DocDebitTotal,0.00 As DocCreditTotal,0.00 As BaseDebitTotal,0.00 As BaseCreditTotal,R.Id As DocumentId,RBI.Id As DocumentDetailId,@GUIDZero,
								R.BaseCurrency,@SysCalExchangerate As ExchangeRate,R.GSTExCurrency,R.GSTExchangeRate,@DocType,@DocSubType,ServiceCompanyId,DocNo,1 As IsTax,
								EntityId,@MasterSystemRefNo,@BankChargesCurrency,DocDate,DocDate,@TaxRecCount As RecOrder
							From Bean.Receipt(Nolock) As R
							Inner Join bean.ReceiptBalancingItem(Nolock) As RBI On RBI.ReceiptId=R.Id
							Where R.Id=@SourceId And Rbi.Id=@RecieptBalId

							Set @RecOrder=@RecOrder+1
						End
						Set @RecCount=@RecCount+1
					End
					IF Exists (Select Id From Bean.ReceiptDetail(Nolock) Where ReceiptId=@SourceId And ReceiptAmount<>0)
					Begin
						Set @ClearingRecieptAmount=(Select Sum(Isnull(DocDebit,0))-Sum(Isnull(DocCredit,0)) From Bean.JournalDetail(Nolock) Where JournalId=@MasterJournalId)
						Set @RecOrder=@RecOrder+1
						Insert Into Bean.JournalDetail (Id,JournalId,COAId,AccountDescription, DocDebit,DocCredit,
														 BaseDebit,BaseCredit,
														 DocDebitTotal,DocCreditTotal,BaseDebitTotal,BaseCreditTotal,DocumentId,DocumentDetailId,ItemId,BaseCurrency,ExchangeRate, DocType,DocSubType,ServiceCompanyId,DocNo, IsTax,
														EntityId, SystemRefNo, DocCurrency,DocDate, PostingDate,RecOrder 
														)
						Select NEWID(),@MasterJournalId,@ClearingReceiptsCOAID,R.Remarks,Null As DocDebit,ABS(@ClearingRecieptAmount) As DocCredit,
							Null As BaseDebit,ABS(Round(@ClearingRecieptAmount * @SysCalExchangerate,2)) As BaseCredit,
							0.00 As DocDebitTotal,0.00 As DocCreditTotal,0.00 As BaseDebitTotal,0.00 As BaseCreditTotal,R.Id As DocumentId,R.Id As DocumentDetailId,@GUIDZero,
							R.BaseCurrency,@DefaultExchangeRate As ExchangeRate, @DocType,@DocSubType,ServiceCompanyId,DocNo,0 As IsTax,
							EntityId,@MasterSystemRefNo As SystemRefNo,@BankChargesCurrency,DocDate,DocDate,@RecOrder As RecOrder
						From Bean.Receipt(Nolock) As R
						Where R.Id=@SourceId
						Set @SysRefNum_Incr=@SysRefNum_Incr+1
						Set @SystemRefNo=CONCAT(@DocNo,'-JV',@SysRefNum_Incr)
						Set @JournalId=NEWID()
						Set @RecOrder=1
						Insert Into Bean.Journal (Id,CompanyId,DocDate,DocType,DocSubType,DocNo,ServiceCompanyId,SystemReferenceNo,IsNoSupportingDocs,NoSupportingDocument,DocCurrency,ExchangeRate,ExCurrency,ExDurationFrom,GSTExchangeRate,GSTExCurrency,GSTTotalAmount,DocumentState,IsNoSupportingDocument,IsGstSettings,IsMultiCurrency,IsAllowableNonAllowable,IsGSTCurrencyRateChanged,Remarks,UserCreated,CreatedDate,Status,DocumentDescription,CreationType,GrandDocDebitTotal,GrandDocCreditTotal,GrandBaseDebitTotal,
													GrandBaseCreditTotal,EntityId,EntityType,PostingDate,COAId,ModeOfReceipt,BankReceiptAmmount,ExcessPaidByClientAmmount,BalancingItemReciveCRAmount,  BalancingItemPayDRAmount,ReceiptApplicationAmmount,DocumentId, BankClearingDate ,IsBalancing,ISAllowDisAllow, IsShow, ActualSysRefNo 
													,IsSegmentReporting,TransferRefNo
												 )
						Select @JournalId,@CompanyId,DocDate,@DocType,@DocSubType,DocNo,ServiceCompanyId,@SystemRefNo As SystemRefNo,IsNoSupportingDocument,NoSupportingDocs,DocCurrency,ExchangeRate,ExCurrency,ExDurationFrom,GSTExchangeRate,GSTExCurrency,Isnull(GSTTotalAmount,0),DocumentState,NoSupportingDocs,IsGstSettings,IsMultiCurrency,IsAllowableDisallowable,IsGSTCurrencyRateChanged,Remarks,@UserCreated,@CreatedDate,Status,Remarks As DocDescription,@UserCreated,GrandTotal,0.00 As GrandDocCreditTotal,GrandTotal * Round(ExchangeRate,2) As GrandBaseDebitTotal,
								0.00 As GrandBaseCreditTotal,EntityId,EntityType,DocDate As PostingDate,COAId,ModeOfReceipt,0.00 As BankReceiptAmmount,0.00 As ExcessPaidByClientAmmount,0.00 As BalancingItemReciveCRAmount,0.00 As BalancingItemPayDRAmount,0.00 As ReceiptApplicationAmmount,Id As DocumentId,BankClearingDate,0 As IsBalancing,IsDisAllow,1 As IsShow,DocNo As ActualSysRefNo,0 As IsSegmentReporting,ReceiptRefNo
						From Bean.Receipt(Nolock) Where CompanyId=@CompanyId And Id=@SourceId
						Set @RecOrder=@RecOrder+1
						Insert Into Bean.JournalDetail (Id,JournalId,COAId,AccountDescription, DocDebit,DocCredit,
														 BaseDebit,BaseCredit,
														 DocDebitTotal,DocCreditTotal,BaseDebitTotal,BaseCreditTotal,DocumentId,DocumentDetailId,ItemId,BaseCurrency,ExchangeRate, DocType,DocSubType,ServiceCompanyId,DocNo, IsTax,
														EntityId, SystemRefNo, DocCurrency,DocDate, PostingDate,RecOrder 
														)
						Select NEWID(),@JournalId,@ClearingReceiptsCOAID,R.Remarks,R.ReceiptApplicationAmmount As DocDebit,Null As DocCredit,
							Round(R.ReceiptApplicationAmmount * @DefaultExchangeRate,2) As BaseDebit,Null As BaseCredit,
							0.00 As DocDebitTotal,0.00 As DocCreditTotal,0.00 As BaseDebitTotal,0.00 As BaseCreditTotal,R.Id As DocumentId,R.Id As DocumentDetailId,@GUIDZero,
							R.BaseCurrency,@DefaultExchangeRate As ExchangeRate, @DocType,@DocSubType,ServiceCompanyId,DocNo,0 As IsTax,
							EntityId,@SystemRefNo,@DocCurrency,DocDate,DocDate,@RecOrder As RecOrder
						From Bean.Receipt(Nolock) As R
						Where R.Id=@SourceId
						-- Detail Records
						Insert Into @RecieptDtl 
						Select RD.Id From Bean.ReceiptDetail(Nolock) As RD
						Inner Join Bean.Receipt(Nolock) As R On RD.ReceiptId=R.Id
						Where R.Id=@SourceId And RD.ReceiptAmount<>0 Order By RD.RecOrder
						Set @Count=(Select Count(*) From @RecieptDtl)
						Set @RecCount=1
						While @Count>=@RecCount
						Begin
							Set @RecOrder=@RecOrder+1
							Set @RecieptDtlId=(Select RecieptDtlId From @RecieptDtl Where S_No=@RecCount)
							Set @DocumentId=(Select DocumentId From Bean.ReceiptDetail(Nolock) Where Id=@RecieptDtlId)
							Set @IsRoundingAmount=0
							IF Exists (Select ID From Bean.ReceiptDetail(Nolock) Where id=@RecieptDtlId And Nature=@NatureTrade)
							Begin
								Set @COAID=(Select Id From Bean.ChartOfAccount(Nolock) Where CompanyId=@CompanyId And Name=@COATradeReceivables)
							End
							Else IF Exists (Select ID From Bean.ReceiptDetail(Nolock) Where id=@RecieptDtlId And Nature=@NatureOthers)
							Begin
								Set @COAID=(Select Id From Bean.ChartOfAccount(Nolock) Where CompanyId=@CompanyId And Name=@COAotherReceivables)
							End
							IF Exists (Select ID From Bean.ReceiptDetail(Nolock) Where id=@RecieptDtlId And DocumentType=@InvoiceDocument)
							Begin
								IF Exists(Select Id From Bean.Invoice(Nolock) Where Id=@DocumentId And DocumentState In (@FullyApplied,@Fullypaid))
								Begin
									Set @IsRoundingAmount=1
								End
							End
							Else IF Exists (Select ID From Bean.ReceiptDetail(Nolock) Where id=@RecieptDtlId And DocumentType=@DebitNoteDocument)
							Begin
								IF Exists(Select Id From Bean.DebitNote(Nolock) Where Id=@DocumentId And DocumentState In (@FullyApplied,@Fullypaid))
								Begin
									Set @IsRoundingAmount=1
								End
							End
							IF @IsRoundingAmount=1 And Exists (Select Amount From @RoundingAmountDetails Where DocumentId=@DocumentId And Amount Is Not Null And Amount<>'')
							Begin
								Set @DocAmount=(Select Amount From @RoundingAmountDetails Where DocumentId=@DocumentId)
							End
							Else
							Begin
								Set @DocAmount=0
							End
							Insert Into Bean.JournalDetail (Id,JournalId,COAId,AccountDescription, DocDebit,DocCredit,
															 BaseDebit,BaseCredit,
															 DocDebitTotal,DocCreditTotal,BaseDebitTotal,BaseCreditTotal,DocumentId,DocumentDetailId,ItemId,BaseCurrency,ExchangeRate, DocType,DocSubType,ServiceCompanyId,DocNo,Nature,OffsetDocument,IsTax,
															EntityId, SystemRefNo, DocCurrency,DocDate, PostingDate,RecOrder 
															)
							Select NEWID(),@JournalId,@COAID,R.Remarks,Null As DocDebit,RD.ReceiptAmount As DocCredit,
								Null As BaseDebit,Round(RD.ReceiptAmount * @DefaultExchangeRate,2)- Isnull(@DocAmount,0) As BaseCredit,
								0.00 As DocDebitTotal,0.00 As DocCreditTotal,0.00 As BaseDebitTotal,0.00 As BaseCreditTotal,R.Id As DocumentId,RD.Id As DocumentDetailId,@GUIDZero,
								R.BaseCurrency,@DefaultExchangeRate As ExchangeRate,@DocType,@DocSubType,RD.ServiceCompanyId,R.DocNo,RD.Nature,RD.DocumentNo,0 As IsTax,
								EntityId,@SystemRefNo,@DocCurrency,DocDate,DocDate,@RecOrder As RecOrder
							From Bean.Receipt(Nolock) As R
							Inner Join bean.ReceiptDetail(Nolock) As RD On RD.ReceiptId=R.Id
							Where R.Id=@SourceId And RD.Id=@RecieptDtlId
							Set @RecCount=@RecCount+1
						End
					End
				End
				Else IF @DocCurrency<>@BankChargesCurrency And @BaseCurrency<>@DocCurrency
				Begin
					/* Creating Mater record In JournalDetail */
					IF Exists (Select Id From Bean.Receipt(Nolock) Where Id=@SourceId And GrandTotal<>0)
					Begin
						Insert Into Bean.JournalDetail (Id,JournalId,COAId,AccountDescription,AllowDisAllow, DocDebit, BaseDebit, DocDebitTotal,DocCreditTotal,BaseDebitTotal,BaseCreditTotal,DocumentId,DocumentDetailId,ItemId,BaseCurrency,ExchangeRate,GSTExCurrency,GSTExchangeRate,DocType,DocSubType,ServiceCompanyId,DocNo, IsTax,
										EntityId, SystemRefNo, DocCurrency,DocDate, PostingDate,RecOrder )
						Select NEWID(),@MasterJournalId,COAId,Remarks,IsDisAllow,Isnull(BankReceiptAmmount,0) As BankReceiptAmmount,Round(BankReceiptAmmount * @DefaultExchangeRate,2),0.00 As DocDebitTotal,0.00 As DocCreditTotal,0.00 As BaseDebitTotal,0.00 As BaseCreditTotal,Id As DocumentId,@GUIDZero,@GUIDZero,
								BaseCurrency,@DefaultExchangeRate As ExchangeRate,GSTExCurrency,GSTExchangeRate,@DocType,@DocSubType,ServiceCompanyId,DocNo,0 As IsTax,
								EntityId,@MasterSystemRefNo As SystemRefNo,@BankChargesCurrency,DocDate,DocDate,@RecOrder As RecOrder
						From Bean.Receipt(Nolock) Where Id=@SourceId
					End
					Else IF Exists (Select Id From Bean.Receipt(Nolock) Where Id=@SourceId And GrandTotal=0 And BankReceiptAmmount<>0)
					Begin
						Insert Into Bean.JournalDetail (Id,JournalId,COAId,AccountDescription,AllowDisAllow, DocDebit, BaseDebit, DocDebitTotal,DocCreditTotal,BaseDebitTotal,BaseCreditTotal,DocumentId,DocumentDetailId,ItemId,BaseCurrency,ExchangeRate,GSTExCurrency,GSTExchangeRate,DocType,DocSubType,ServiceCompanyId,DocNo, IsTax,
										EntityId, SystemRefNo, DocCurrency,DocDate, PostingDate,RecOrder )
						Select NEWID(),@MasterJournalId,COAId,Remarks,IsDisAllow,Isnull(BankReceiptAmmount,0) As BankReceiptAmmount,Round(Isnull(BankReceiptAmmount,0) * @DefaultExchangeRate,2),0.00 As DocDebitTotal,0.00 As DocCreditTotal,0.00 As BaseDebitTotal,0.00 As BaseCreditTotal,Id As DocumentId,@GUIDZero,@GUIDZero,
								BaseCurrency,@DefaultExchangeRate As ExchangeRate,GSTExCurrency,GSTExchangeRate,@DocType,@DocSubType,ServiceCompanyId,DocNo,0 As IsTax,
								EntityId,@MasterSystemRefNo As SystemRefNo,@BankChargesCurrency,DocDate,DocDate,@RecOrder As RecOrder
						From Bean.Receipt(Nolock) Where Id=@SourceId
					End
					/* Creating Record in Journaldetail With Bank Charges Amount */
					If Exists(Select Id From Bean.Receipt(Nolock) Where Id=@SourceId And BankCharges Is Not Null)
					Begin
						Set @RecOrder=@RecOrder+1
						Insert Into Bean.JournalDetail (Id,JournalId,COAId,AccountDescription,AllowDisAllow,TaxId,TaxType,TaxRate,DocDebit, BaseDebit, DocDebitTotal,DocCreditTotal,BaseDebitTotal,BaseCreditTotal,DocumentId,DocumentDetailId,ItemId,BaseCurrency,ExchangeRate,GSTExCurrency,GSTExchangeRate,DocType,DocSubType,ServiceCompanyId,DocNo, IsTax,
													EntityId, SystemRefNo, DocCurrency,DocDate, PostingDate,RecOrder,GSTTaxDebit)
						Select NEWID(),@MasterJournalId,@BankCharges_COAId,Remarks,IsDisAllow,@TaxId,@TaxType,@TaxRate,BankCharges,Round(BankCharges * @DefaultExchangeRate,2),0.00 As DocDebitTotal,0.00 As DocCreditTotal,0.00 As BaseDebitTotal,0.00 As BaseCreditTotal,Id As DocumentId,Id As DocumentDetailId,@GUIDZero,
							BaseCurrency,@DefaultExchangeRate As ExchangeRate,GSTExCurrency,GSTExchangeRate,@DocType,@DocSubType,ServiceCompanyId,DocNo,0 As IsTax,
							EntityId,@MasterSystemRefNo As SystemRefNo,@BankChargesCurrency,DocDate,DocDate,@RecOrder As RecOrder,
							Case When @TaxId Is Not Null Then Round(BankCharges * Coalesce(GSTexchangerate,@DefaultExchangeRate),2) End As GSTTaxDebit
						From Bean.Receipt(Nolock) 
						Where Id=@SourceId
					End
					/* Creating Record in Journaldetail With ExcesPaidByClientAmt Amount */
					If @ExcesPaidByClientAmt Is NOt Null
					Begin
						Set @RecOrder=@RecOrder+1
						Insert Into Bean.JournalDetail (Id,JournalId,COAId,AccountDescription,AllowDisAllow, DocCredit, BaseCredit, DocDebitTotal,DocCreditTotal,BaseDebitTotal,BaseCreditTotal,DocumentId,DocumentDetailId,ItemId,BaseCurrency,ExchangeRate,GSTExCurrency,GSTExchangeRate,DocType,DocSubType,ServiceCompanyId,DocNo, IsTax,
														EntityId, SystemRefNo, DocCurrency,DocDate, PostingDate,RecOrder )
						Select NEWID(),@MasterJournalId,@ClearingReceiptsCOAID,Remarks,IsDisAllow,ExcessPaidByClientAmmount, Round(ExcessPaidByClientAmmount * @DefaultExchangeRate,2),0.00 As DocDebitTotal,0.00 As DocCreditTotal,0.00 As BaseDebitTotal,0.00 As BaseCreditTotal,Id As DocumentId,Id As DocumentDtlId,@GUIDZero,
								BaseCurrency,@DefaultExchangeRate As ExchangeRate,BankReceiptAmmountCurrency,ExchangeRate,@DocType,@DocSubType,ServiceCompanyId,DocNo,0 As IsTax,
								EntityId,@MasterSystemRefNo,@BankChargesCurrency,DocDate,DocDate,@RecOrder As RecOrder
						From Bean.Receipt(Nolock) 
						Where Id=@SourceId
					End
					/* Creating Balancing Line Items */
					Insert Into @RecieptBalLnItm
					Select RBI.Id From Bean.ReceiptBalancingItem(Nolock) As RBI
					Inner Join bean.Receipt(Nolock) As R On R.Id=RBI.ReceiptId
					Where R.Id=@SourceId Order by RecOrder
					Set @Count=(Select Count(*) From @RecieptBalLnItm)
					Set @RecCount=1
					While @Count>=@RecCount
					Begin
						Select @RecieptBalId=RecieptBalId From @RecieptBalLnItm Where S_no=@RecCount
						Select @TaxId=TaxId,@TaxRate=TaxRate From Bean.ReceiptBalancingItem(Nolock) Where Id=@RecieptBalId
						Set @RecOrder=@RecOrder+1
						Insert Into Bean.JournalDetail (Id,JournalId,COAId,AccountDescription,AllowDisAllow,TaxId,TaxType,TaxRate,DocDebit,DocCredit,
													DocTaxDebit,DocTaxCredit,BaseDebit,BaseCredit,
													BaseTaxDebit,BaseTaxCredit,DocDebitTotal,DocCreditTotal,BaseDebitTotal,BaseCreditTotal,DocumentId,DocumentDetailId,ItemId,BaseCurrency,ExchangeRate,GSTExCurrency,GSTExchangeRate,DocType,DocSubType,ServiceCompanyId,DocNo, IsTax,
													EntityId, SystemRefNo, DocCurrency,DocDate, PostingDate,RecOrder,GSTTaxDebit,GSTTaxCredit,GSTDebit,GSTCredit)
						Select NEWID(),@MasterJournalId,RBi.COAId,R.Remarks,RBI.IsDisAllow,RBI.TaxId,RBI.TaxType,Rbi.TaxRate,Case When RBI.ReciveORPay=@Pay_Dr Then RBI.DocAmount End As DocDebit,Case When RBI.ReciveORPay=@Receive_Cr Then RBI.DocAmount End As DocCredit,
							Case When RBI.ReciveORPay=@Pay_Dr Then RBI.DocTaxAmount End As DocTaxDebdit,Case When RBI.ReciveORPay=@Receive_Cr Then RBI.DocTaxAmount End As DocTaxCredit,Case When RBI.ReciveORPay=@Pay_Dr Then RBI.DocAmount * Round(@DefaultExchangeRate,2) End As BaseDebit,Case When RBI.ReciveORPay=@Receive_Cr Then RBI.DocAmount * Round(@DefaultExchangeRate,2) End As BaseCredit,
							Case When RBI.ReciveORPay=@Pay_Dr Then RBI.DocTaxAmount * Round(@DefaultExchangeRate,2) End As BaseTaxDebdit,Case When RBI.ReciveORPay=@Receive_Cr Then RBI.DocTaxAmount * Round(@DefaultExchangeRate,2) End As BaseTaxCredit,0.00 As DocDebitTotal,0.00 As DocCreditTotal,0.00 As BaseDebitTotal,0.00 As BaseCreditTotal,R.Id As DocumentId,RBI.Id As DocumentDetailId,@GUIDZero,
							R.BaseCurrency,@DefaultExchangeRate As ExchangeRate,R.GSTExCurrency,R.GSTExchangeRate,@DocType,@DocSubType,ServiceCompanyId,DocNo,0 As IsTax,
							EntityId,@MasterSystemRefNo,@BankChargesCurrency,DocDate,DocDate,@RecOrder As RecOrder,
							Case When RBI.ReciveORPay=@Pay_Dr Then Round(RBI.DocAmount * Coalesce(R.GSTExchangeRate,@DefaultExchangeRate),2) End As GSTTaxDebit,
							Case When RBI.ReciveORPay=@Receive_Cr Then Round(RBI.DocAmount * Coalesce(R.GSTExchangeRate,@DefaultExchangeRate),2) End As GSTTaxCredit,
							Case When RBI.ReciveORPay=@Pay_Dr Then Round(RBI.DocTaxAmount * Coalesce(R.GSTExchangeRate,@DefaultExchangeRate),2) End As GSTDebit,
							Case When RBI.ReciveORPay=@Receive_Cr Then Round(RBI.DocTaxAmount * Coalesce(R.GSTExchangeRate,@DefaultExchangeRate),2) End As GSTCredit
						From Bean.Receipt(Nolock) As R
						Inner Join bean.ReceiptBalancingItem(Nolock) As RBI On RBI.ReceiptId=R.Id
						Where R.Id=@SourceId And Rbi.Id=@RecieptBalId
						-- Creating Tax Line Items
						If @GST Is Not Null And @GST=1 And @TaxId Is Not Null And (@TaxRate Is Not Null And @TaxRate<>0)
						Begin
							Set @TaxRecCount=@RecOrder+@Count
							Insert Into Bean.JournalDetail (Id,JournalId,COAId,AccountDescription,AllowDisAllow,TaxId,TaxType,TaxRate,DocDebit,DocCredit,
									 BaseDebit,BaseCredit,
									 DocDebitTotal,DocCreditTotal,BaseDebitTotal,BaseCreditTotal,DocumentId,DocumentDetailId,ItemId,BaseCurrency,ExchangeRate,GSTExCurrency,GSTExchangeRate,DocType,DocSubType,ServiceCompanyId,DocNo, IsTax,
									EntityId, SystemRefNo, DocCurrency,DocDate, PostingDate,RecOrder )
							Select NEWID(),@MasterJournalId,@TaxPayableGST_COAID as COAId,R.Remarks,RBI.IsDisAllow,RBI.TaxId,RBI.TaxType,Rbi.TaxRate,Case When RBI.ReciveORPay=@Pay_Dr Then RBI.DocTaxAmount End As DocDebit,Case When RBI.ReciveORPay=@Receive_Cr Then RBI.DocTaxAmount End As DocCredit,
								Case When RBI.ReciveORPay=@Pay_Dr Then RBI.DocTaxAmount * Round(@DefaultExchangeRate,2) End As BaseDebit,Case When RBI.ReciveORPay=@Receive_Cr Then RBI.DocTaxAmount * Round(@DefaultExchangeRate,2) End As BaseCredit,
								0.00 As DocDebitTotal,0.00 As DocCreditTotal,0.00 As BaseDebitTotal,0.00 As BaseCreditTotal,R.Id As DocumentId,RBI.Id As DocumentDetailId,@GUIDZero,
								R.BaseCurrency,@DefaultExchangeRate As ExchangeRate,R.GSTExCurrency,R.GSTExchangeRate,@DocType,@DocSubType,ServiceCompanyId,DocNo,1 As IsTax,
								EntityId,@MasterSystemRefNo,@BankChargesCurrency,DocDate,DocDate,@TaxRecCount As RecOrder
							From Bean.Receipt(Nolock) As R
							Inner Join bean.ReceiptBalancingItem(Nolock) As RBI On RBI.ReceiptId=R.Id
							Where R.Id=@SourceId And Rbi.Id=@RecieptBalId

							Set @RecOrder=@RecOrder+1
						End
						Set @RecCount=@RecCount+1
					End
					IF Exists (Select Id From Bean.ReceiptDetail(Nolock) Where ReceiptId=@SourceId And ReceiptAmount<>0)
					Begin
						Set @ClearingRecieptAmount=(Select Sum(Isnull(DocDebit,0)-ISnull(DocCredit,0)) From Bean.JournalDetail(Nolock) Where JournalId=@MasterJournalId)
						Set @RecOrder=@RecOrder+1
						IF @ClearingRecieptAmount IS Not Null And @ClearingRecieptAmount<>0
						Begin
							Insert Into Bean.JournalDetail (Id,JournalId,COAId,AccountDescription, DocDebit,DocCredit,
															 BaseDebit,BaseCredit,
															 DocDebitTotal,DocCreditTotal,BaseDebitTotal,BaseCreditTotal,DocumentId,DocumentDetailId,ItemId,BaseCurrency,ExchangeRate, DocType,DocSubType,ServiceCompanyId,DocNo, IsTax,
															EntityId, SystemRefNo, DocCurrency,DocDate, PostingDate,RecOrder 
															)
							Select NEWID(),@MasterJournalId,@ClearingReceiptsCOAID,R.Remarks,Null As DocDebit,ABS(@ClearingRecieptAmount) As DocCredit,
								Null As BaseDebit,ABS(Round(@ClearingRecieptAmount * @DefaultExchangeRate,2)) As BaseCredit,
								0.00 As DocDebitTotal,0.00 As DocCreditTotal,0.00 As BaseDebitTotal,0.00 As BaseCreditTotal,R.Id As DocumentId,R.Id As DocumentDetailId,@GUIDZero,
								R.BaseCurrency,@DefaultExchangeRate As ExchangeRate, @DocType,@DocSubType,ServiceCompanyId,DocNo,0 As IsTax,
								EntityId,@MasterSystemRefNo As SystemRefNo,@BankChargesCurrency,DocDate,DocDate,@RecOrder As RecOrder
							From Bean.Receipt(Nolock) As R
							Where R.Id=@SourceId
						End
						Set @SysRefNum_Incr=@SysRefNum_Incr+1
						Set @SystemRefNo=CONCAT(@DocNo,'-JV',@SysRefNum_Incr)
						Set @JournalId=NEWID()
						Set @RecOrder=1
						Insert Into Bean.Journal (Id,CompanyId,DocDate,DocType,DocSubType,DocNo,ServiceCompanyId,SystemReferenceNo,IsNoSupportingDocs,NoSupportingDocument,DocCurrency,ExchangeRate,ExCurrency,ExDurationFrom,GSTExchangeRate,GSTExCurrency,GSTTotalAmount,DocumentState,IsNoSupportingDocument,IsGstSettings,IsMultiCurrency,IsAllowableNonAllowable,IsGSTCurrencyRateChanged,Remarks,UserCreated,CreatedDate,Status,DocumentDescription,CreationType,GrandDocDebitTotal,GrandDocCreditTotal,GrandBaseDebitTotal,
													GrandBaseCreditTotal,EntityId,EntityType,PostingDate,COAId,ModeOfReceipt,BankReceiptAmmount,ExcessPaidByClientAmmount,BalancingItemReciveCRAmount,  BalancingItemPayDRAmount,ReceiptApplicationAmmount,DocumentId, BankClearingDate ,IsBalancing,ISAllowDisAllow, IsShow, ActualSysRefNo 
													,IsSegmentReporting,TransferRefNo
												 )
						Select @JournalId,@CompanyId,DocDate,@DocType,@DocSubType,DocNo,ServiceCompanyId,@SystemRefNo As SystemRefNo,IsNoSupportingDocument,NoSupportingDocs,DocCurrency,ExchangeRate,ExCurrency,ExDurationFrom,GSTExchangeRate,GSTExCurrency,Isnull(GSTTotalAmount,0),DocumentState,NoSupportingDocs,IsGstSettings,IsMultiCurrency,IsAllowableDisallowable,IsGSTCurrencyRateChanged,Remarks,@UserCreated,@CreatedDate,Status,Remarks As DocDescription,@UserCreated,GrandTotal,0.00 As GrandDocCreditTotal,GrandTotal * Round(ExchangeRate,2) As GrandBaseDebitTotal,
								0.00 As GrandBaseCreditTotal,EntityId,EntityType,DocDate As PostingDate,COAId,ModeOfReceipt,0.00 As BankReceiptAmmount,0.00 As ExcessPaidByClientAmmount,0.00 As BalancingItemReciveCRAmount,0.00 As BalancingItemPayDRAmount,0.00 As ReceiptApplicationAmmount,Id As DocumentId,BankClearingDate,0 As IsBalancing,IsDisAllow,1 As IsShow,DocNo As ActualSysRefNo,0 As IsSegmentReporting,ReceiptRefNo
						From Bean.Receipt(Nolock) Where CompanyId=@CompanyId And Id=@SourceId
						Set @RecOrder=@RecOrder+1
						Insert Into Bean.JournalDetail (Id,JournalId,COAId,AccountDescription, DocDebit,DocCredit,
														 BaseDebit,BaseCredit,
														 DocDebitTotal,DocCreditTotal,BaseDebitTotal,BaseCreditTotal,DocumentId,DocumentDetailId,ItemId,BaseCurrency,ExchangeRate, DocType,DocSubType,ServiceCompanyId,DocNo, IsTax,
														EntityId, SystemRefNo, DocCurrency,DocDate, PostingDate,RecOrder 
														)
						Select NEWID(),@JournalId,@ClearingReceiptsCOAID,R.Remarks,R.ReceiptApplicationAmmount As DocDebit,Null As DocCredit,
							Round(R.ReceiptApplicationAmmount * @SysCalExchangerate,2) As BaseDebit,Null As BaseCredit,
							0.00 As DocDebitTotal,0.00 As DocCreditTotal,0.00 As BaseDebitTotal,0.00 As BaseCreditTotal,R.Id As DocumentId,R.Id As DocumentDetailId,@GUIDZero,
							R.BaseCurrency,@SysCalExchangerate As ExchangeRate, @DocType,@DocSubType,ServiceCompanyId,DocNo,0 As IsTax,
							EntityId,@SystemRefNo As SystemRefNo,@DocCurrency,DocDate,DocDate,@RecOrder As RecOrder
						From Bean.Receipt(Nolock) As R
						Where R.Id=@SourceId
						-- Reciept Detail
						Insert Into @RecieptDtl 
						Select RD.Id From Bean.ReceiptDetail(Nolock) As RD
						Inner Join Bean.Receipt(Nolock) As R On RD.ReceiptId=R.Id
						Where R.Id=@SourceId And RD.ReceiptAmount<>0 Order By RD.RecOrder
						Set @Count=(Select Count(*) From @RecieptDtl)
						Set @RecCount=1
						While @Count>=@RecCount
						Begin
							Set @RecOrder=@RecOrder+1
							Set @RecieptDtlId=(Select RecieptDtlId From @RecieptDtl Where S_No=@RecCount)
							Set @DocumentId=(Select DocumentId From Bean.ReceiptDetail(Nolock) Where Id=@RecieptDtlId)
							Set @IsRoundingAmount=0
							IF Exists (Select DocumentType From Bean.ReceiptDetail(Nolock) Where Id=@RecieptDtlId And DocumentType=@InvoiceDocument)
							Begin
								Set @ExchangeRate=(Select ExchangeRate From Bean.Invoice(Nolock) Where Id=@DocumentId)
								IF Exists(Select Id From Bean.Invoice(Nolock) Where Id=@DocumentId And DocumentState In (@FullyApplied,@Fullypaid))
								Begin
									Set @IsRoundingAmount=1
								End
							End
							Else IF Exists (Select DocumentType From Bean.ReceiptDetail(Nolock) Where Id=@RecieptDtlId And DocumentType=@DebitNoteDocument)
							Begin
								Set @ExchangeRate=(Select ExchangeRate From Bean.DebitNote(Nolock) Where Id=@DocumentId)
								IF Exists(Select Id From Bean.DebitNote(Nolock) Where Id=@DocumentId And DocumentState In (@FullyApplied,@Fullypaid))
								Begin
									Set @IsRoundingAmount=1
								End
							End

							IF Exists (Select ID From Bean.ReceiptDetail(Nolock) Where id=@RecieptDtlId And Nature=@NatureTrade)
							Begin
								Set @COAID=(Select Id From Bean.ChartOfAccount(Nolock) Where CompanyId=@CompanyId And Name=@COATradeReceivables)
							End
							Else IF Exists (Select ID From Bean.ReceiptDetail(Nolock) Where id=@RecieptDtlId And Nature=@NatureOthers)
							Begin
								Set @COAID=(Select Id From Bean.ChartOfAccount(Nolock) Where CompanyId=@CompanyId And Name=@COAotherReceivables)
							End
							IF @IsRoundingAmount=1 And Exists (Select Amount From @RoundingAmountDetails Where DocumentId=@DocumentId And Amount Is Not Null And Amount<>'')
							Begin
								Set @DocAmount=(Select Amount From @RoundingAmountDetails Where DocumentId=@DocumentId)
							End
							Else
							Begin
								Set @DocAmount=0
							End
							Insert Into Bean.JournalDetail (Id,JournalId,COAId,AccountDescription, DocDebit,DocCredit,
															 BaseDebit,BaseCredit,
															 DocDebitTotal,DocCreditTotal,BaseDebitTotal,BaseCreditTotal,DocumentId,DocumentDetailId,ItemId,BaseCurrency,ExchangeRate, DocType,DocSubType,ServiceCompanyId,DocNo,Nature,OffsetDocument,IsTax,
															EntityId, SystemRefNo, DocCurrency,DocDate, PostingDate,RecOrder 
															)
							Select NEWID(),@JournalId,@COAID,R.Remarks,Null As DocDebit,RD.ReceiptAmount As DocCredit,
								Null As BaseDebit,Round(RD.ReceiptAmount * @ExchangeRate,2)- Isnull(@DocAmount,0) As BaseCredit,
								0.00 As DocDebitTotal,0.00 As DocCreditTotal,0.00 As BaseDebitTotal,0.00 As BaseCreditTotal,R.Id As DocumentId,RD.Id As DocumentDetailId,@GUIDZero,
								R.BaseCurrency,@ExchangeRate As ExchangeRate,@DocType,@DocSubType,RD.ServiceCompanyId,R.DocNo,RD.Nature,RD.DocumentNo,0 As IsTax,
								EntityId,@SystemRefNo As SystemRefNo,@DocCurrency,DocDate,DocDate,@RecOrder As RecOrder
							From Bean.Receipt(Nolock) As R
							Inner Join bean.ReceiptDetail(Nolock) As RD On RD.ReceiptId=R.Id
							Where R.Id=@SourceId And RD.Id=@RecieptDtlId
							IF @SysCalExchangerate-@ExchangeRate<>0
							Begin
								-- Exchange Gain/Loss
								Set @RecOrder=@RecOrder+1
								Insert Into Bean.JournalDetail (Id,JournalId,COAId,AccountDescription, DocDebit,DocCredit,
																 BaseDebit,BaseCredit,
																 DocDebitTotal,DocCreditTotal,BaseDebitTotal,BaseCreditTotal,DocumentId,DocumentDetailId,ItemId,BaseCurrency,ExchangeRate, DocType,DocSubType,ServiceCompanyId,DocNo,Nature,OffsetDocument,IsTax,
																EntityId, SystemRefNo, DocCurrency,DocDate, PostingDate,RecOrder 
																)
								Select NEWID(),@JournalId,@ExchangeGainOrLossCOAID,R.Remarks,Null As DocDebit,Null As DocCredit,
									Case When (@SysCalExchangerate-@ExchangeRate)<0 Then ABS(Round((@SysCalExchangerate-@ExchangeRate)*RD.ReceiptAmount,2))  End As BaseDebit,
									Case When (@SysCalExchangerate-@ExchangeRate)>0 Then ABS(Round((@SysCalExchangerate-@ExchangeRate)*RD.ReceiptAmount,2)) End As BaseCredit,
									0.00 As DocDebitTotal,0.00 As DocCreditTotal,0.00 As BaseDebitTotal,0.00 As BaseCreditTotal,R.Id As DocumentId,RD.Id As DocumentDetailId,@GUIDZero,
									R.BaseCurrency,R.ExchangeRate,@DocType,@DocSubType,RD.ServiceCompanyId,R.DocNo,RD.Nature,RD.DocumentNo,0 As IsTax,
									EntityId,@SystemRefNo As SystemRefNo,@DocCurrency,DocDate,DocDate,@RecOrder As RecOrder
								From Bean.Receipt(Nolock) As R
								Inner Join bean.ReceiptDetail(Nolock) As RD On RD.ReceiptId=R.Id
								Where R.Id=@SourceId And RD.Id=@RecieptDtlId
							End
							Set @RecCount=@RecCount+1
						End
					End
				End
			End
			-- Rounding
			Insert Into @Rounding_Tbl
			Select Id From Bean.Journal(Nolock) where DocumentId=@SourceId And DocType=@Type
			Set @Count=(Select Count(*) From @Rounding_Tbl)
			Set @RecCount=1
			While @Count>=@RecCount
			Begin
				Set @JournalId=(Select JournalId From @Rounding_Tbl Where S_No=@RecCount)
				Set @ServCompId=(Select ServiceCompanyId From Bean.Journal Where Id=@JournalId)
				Set @DocCurrency=(Select Top(1) DocCurrency From bean.JournalDetail(Nolock) Where JournalId=@JournalId)
				/* Rounding Amount Base*/
				Set @RoundingAmt=(Select SUM(Isnull(BaseDebit,0))-SUM(Isnull(BaseCredit,0)) From Bean.JournalDetail(Nolock) Where JournalId=@JournalId)
				IF @RoundingAmt<>0 
				Begin
					Set @RecOrder=(Select Max(RecOrder)+1 From Bean.JournalDetail(Nolock) Where JournalId=@JournalId)
					Set @RoundingCOAID=(Select Id From Bean.ChartOfAccount(Nolock) Where CompanyId=@CompanyId And Name=@Rounding)
					Insert Into Bean.JournalDetail (Id,JournalId,COAId,AccountDescription, DocDebit,DocCredit,
									 BaseDebit,BaseCredit,
									 DocDebitTotal,DocCreditTotal,BaseDebitTotal,BaseCreditTotal,DocumentId,DocumentDetailId,ItemId,BaseCurrency, DocType,DocSubType,ServiceCompanyId,DocNo, IsTax,
									EntityId,DocCurrency,DocDate, PostingDate,RecOrder 
									)
					Select NEWID(),@JournalId,@RoundingCOAID,R.Remarks,Null As DocDebit,Null As DocCredit,
						Case When @RoundingAmt<0 Then ABS(@RoundingAmt) End BaseDebit,Case When @RoundingAmt>0 Then @RoundingAmt End BaseCredit,
						0.00 As DocDebitTotal,0.00 As DocCreditTotal,0.00 As BaseDebitTotal,0.00 As BaseCreditTotal,R.Id As DocumentId,NewId() As DocumentDetailId,@GUIDZero,
						R.BaseCurrency,@DocType,@DocSubType,@ServCompId As ServiceCompanyId,R.DocNo,0 As IsTax,
						EntityId,@DocCurrency,DocDate,DocDate,@RecOrder As RecOrder
					From Bean.Receipt(Nolock) As R
					Where R.Id=@SourceId 
				End
				/* Rounding Amount Doc */
				Set @RoundingAmt=(Select SUM(Isnull(DocDebit,0))-SUM(Isnull(DocCredit,0)) From Bean.JournalDetail(Nolock) Where JournalId=@JournalId)
				IF @RoundingAmt<>0 
				Begin
				Set @RecOrder=(Select Max(RecOrder)+1 From Bean.JournalDetail(Nolock) Where JournalId=@JournalId)
				Set @RoundingCOAID=(Select Id From Bean.ChartOfAccount(Nolock) Where CompanyId=@CompanyId And Name=@Rounding)
				Insert Into Bean.JournalDetail (Id,JournalId,COAId,AccountDescription, DocDebit,DocCredit,
								 BaseDebit,BaseCredit,
								 DocDebitTotal,DocCreditTotal,BaseDebitTotal,BaseCreditTotal,DocumentId,DocumentDetailId,ItemId,BaseCurrency, DocType,DocSubType,ServiceCompanyId,DocNo, IsTax,
								EntityId, DocCurrency,DocDate, PostingDate,RecOrder 
								)
				Select NEWID(),@JournalId,@RoundingCOAID,R.Remarks,Case When @RoundingAmt<0 Then ABS(@RoundingAmt) End As DocDebit,Case When @RoundingAmt>0 Then @RoundingAmt End As DocCredit,
					Null BaseDebit,Null BaseCredit,
					0.00 As DocDebitTotal,0.00 As DocCreditTotal,0.00 As BaseDebitTotal,0.00 As BaseCreditTotal,R.Id As DocumentId,NewId() As DocumentDetailId,@GUIDZero,
					R.BaseCurrency,@DocType,@DocSubType,@ServCompId As ServiceCompanyId,R.DocNo,0 As IsTax,
					EntityId,@DocCurrency,DocDate,DocDate,@RecOrder As RecOrder
				From Bean.Receipt(Nolock) As R
				Where R.Id=@SourceId 
			End
				Set @RecCount=@RecCount+1
			End
		End
			Exec [dbo].[Bean_Update_CustBalance_and_CreditLimit] @CompanyId, @CustEntityId

			Exec Bean_Update_BRC_Re_Run @companyId,@OldServEntityId,@NewServEntityId,@NewCoaId,@OldCoaId,@OldDocdate,@NewDocDate,@OldDocAmount,@NewDocAmount,@IsAdd

		Commit Transaction
	End Try
	Begin Catch
		Rollback Transaction
		Set @ErrorMessage=(Select ERROR_MESSAGE())
		RaisError( @ErrorMessage,16,1)
	End Catch

End
