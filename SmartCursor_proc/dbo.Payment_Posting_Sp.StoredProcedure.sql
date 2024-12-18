USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[Payment_Posting_Sp]    Script Date: 16-12-2024 9.20.10 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE Procedure [dbo].[Payment_Posting_Sp]
@SourceId Uniqueidentifier,
@Type Nvarchar(20),	
@CompanyId BigInt,
@RoundingAmount nvarchar(4000)
As
Begin
	-- Documnet Type 
	Declare @InvoiceDocument varchar(50) ='Invoice'
	Declare @DebitNoteDocument varchar(50) ='Debit Note'
	Declare @CreditNoteDocument varchar(50) ='Credit Note'
	Declare @CreditMemoDocument nvarchar(50)='Credit Memo'
	Declare @BillDocument varchar(20) ='Bill'
	Declare	@PayrollBill varchar(50)='Payroll Bill'
	Declare	@openBal varchar(50)='Opening Bal'
	Declare	@Payroll varchar(20)='Payroll'
	Declare	@Claim varchar(20)='Claim'
	Declare @BillPayment varchar(50)='Bill Payment'
	Declare @General varchar(20)='General'
	Declare @NatureTrade varchar(20) = 'Trade'
	Declare @NatureOthers varchar(20) = 'Others'
	Declare @COATradeReceivables varchar(50) = 'Trade receivables'
	Declare @COAotherReceivables varchar(50) = 'Other receivables'
	Declare @COATradePayables varchar(50) = 'Trade payables'
	Declare @COAOtherPayables varchar(50) = 'Other payables'
	--Declare @COA_BankCharges varchar(50)='Bank charges'
	Declare @ExchangeGainOrLossRealised Nvarchar(50)='Exchange gain/loss - Realised'
	Declare @ClearingPayments Nvarchar(250)='Clearing - Payments'
	Declare @ClearingReceipts Nvarchar(250)='Clearing - Receipts'
	Declare @Rounding Nvarchar(25)='Rounding'
	Declare @IntercompClearingCOAName Nvarchar(250)='Intercompany Clearing'
	Declare @ClearingReceiptsCOAID Bigint
	Declare @GUIDZero Uniqueidentifier ='00000000-0000-0000-0000-000000000000'
	Declare @UserCreated Nvarchar(20) ='System'
	Declare @CreatedDate Datetime2=GETUTCDATE()
	Declare @DefaultExchangeRate Decimal(15,10)=1.00000000
	Declare @NA Char(2)='NA'
	Declare @BaseCurrency Varchar(25)
	Declare @DocCurrency Varchar(25)
	Declare @BankChargesCurrency Varchar(25)
	Declare @DocType Varchar(25)
	Declare @DocSubType Varchar(25)
	Declare @PaymentDtlId Uniqueidentifier
	Declare @JournalId Uniqueidentifier
	Declare @IntMstSeysRefNo Nvarchar(250)
	Declare @IntMastJournalId Uniqueidentifier
	Declare @MasterJournalId Uniqueidentifier
	Declare @ErrorMessage Nvarchar(4000)
	Declare	@Count Int
	Declare @RecCount Int
	Declare @DetailId Uniqueidentifier
	Declare @DocumentId Uniqueidentifier
	Declare @DefaultTaxCode Char(2)
	Declare @RecOrder int
	Declare @MasterRecOrder int
	Declare @ClearingPaymentsCOAID Bigint
	Declare @COAID BigInt
	Declare @ExchangeRate Decimal(15,10)
	Declare @MainExchangeRate Decimal(15,10)
	Declare @RoundingAmt Money
	Declare @RoundingCOAID BigInt
	Declare @ServCompCount Int
	Declare @ServCompCount2 Int
	Declare @ServCompaIdTblCnt Int
	Declare @ServCompId Int
	Declare @SystemRefNo Nvarchar(250)
	Declare @MasterSystemRefNo Nvarchar(250)
	Declare @DocNo Nvarchar(250)
	Declare @FullyApplied Nvarchar(50)='Fully Applied'
	Declare @Fullypaid Nvarchar(50)='Fully Paid'
	Declare @DocAmount Money
	Declare @IntroCompCOAID BigInt
	Declare @MainInterCoServCompCOAID BigInt
	Declare @MasterServComp BigInt
	Declare @RdtlRecCount int
	Declare @DtlCount Int
	Declare @IsCustomer Int
	Declare @PaymentOffSet Int
	Declare @OffSetDocumentType Nvarchar(50)
	Declare @ClearingPaymentInvOrDNAmount Money
	Declare @ClearingPaymentBillAmount Money
	Declare @ClearingPaymentsAmount Money
	Declare @CreditNoteAmount Money
	Declare @CreditMemoAmount Money
	Declare @SysCalExchangerate Decimal(15,10)
	Declare @ServCompRecOrder Int
	Declare @DtlRecOrder Int
	Declare @PaymentAmtTotal Money
	Declare @SysRefNumOrder Int
	Declare @IsRoundingAmount Int
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
	-- Declare Table Variables
	Declare @PaymentDtl Table (S_No Int identity(1,1),PaymentDtlId Uniqueidentifier)
	Declare @PaymentDtl_New Table (S_No Int,PaymentDtlId Uniqueidentifier)
	--Declare @InterCoPaymentDtl Table (S_No Int identity(1,1),PaymentDtlId Uniqueidentifier,ServCompId BigInt)
	Declare @ServCompaIdTbl Table (S_No Int Identity(1,1),SerCompId BigInt)
	Declare @Rounding_Tbl Table (S_No int Identity(1,1),JournalId Uniqueidentifier)
	Declare @RoundingAmountDetails Table (DocumentId Uniqueidentifier,Amount Money)

	Begin Transaction
	Begin Try
		-- Deleting Existing Jv
		IF Exists (Select Id From bean.Journal Where DocumentId=@SourceId And DocType=@Type)
		Begin
			Select @OldCOAId=COAId,@OldServEntityId=ServiceCompanyId,@OldDocAmount=Case When DocDebit IS null Then DocCredit Else DocDebit End,@OldDocdate=PostingDate
			From Bean.JournalDetail As JD  
			Inner Join Bean.ChartOfAccount As COA On COA.Id=JD.COAId
			Where JD.DocumentId=@SourceId and JD.DocumentDetailId='00000000-0000-0000-0000-000000000000' And COA.IsBank=1

			Select @NewCoaId=COAId,@NewServEntityId=ServiceCompanyId,@NewDocAmount=GrandTotal,@NewDocDate=DocDate 
			From Bean.Payment where CompanyId=@CompanyId and Id=@SourceId
			Set @IsAdd=1
			--Opt: Used Join to replace the In clause
			--Delete From Bean.JournalDetail Where JournalId In (Select Id From bean.Journal Where DocumentId=@SourceId)
			Delete JD From Bean.JournalDetail As JD
			JOIN Bean.Journal As J on JD.JournalId=J.Id
			Where J.DocumentId=@SourceId

			Delete From Bean.Journal Where DocumentId=@SourceId
		End
		Else
		Begin
			Select @NewCoaId=COAId,@NewServEntityId=ServiceCompanyId,@NewDocAmount=GrandTotal,@NewDocDate=DocDate 
			From Bean.Payment where CompanyId=@CompanyId and Id=@SourceId
		End
		IF @Type=@BillPayment
		Begin
			Set @DefaultTaxCode ='EP'
			Set @DocType='Bill Payment'
			Set @DocSubType='General'
			Set @SysRefNumOrder=1
			-- Opt : Replaced Set with Select
			Select @ClearingPaymentsCOAID= Id 
			From Bean.ChartOfAccount Where CompanyId=@CompanyId And Name=@ClearingPayments
			
			Set @RecOrder=1
			Set @MasterRecOrder=1
			-- Opt : Replaced Set with Select
			Select @ClearingReceiptsCOAID= Id From Bean.ChartOfAccount 
			Where CompanyId=@CompanyId And Name=@ClearingReceipts

			Declare @RndAmtcount int=0
			Declare @RndAmtReccount int=0
			Declare @KeyPairValueRecCount int=0
			Declare @Reccountcoma int=0
			Declare @KeyPair Nvarchar(Max)
			Declare @value Nvarchar(Max)
			Declare @KeyPairValue nvarchar(500)
			Declare @RndAmtDocid uniqueidentifier
			Declare @RndAmtAmount Money
			Declare @Min_SNo Int
			Declare @tempTable Table(id int identity(1,1), stringVal nvarchar(2000))
			Declare @KeyValue Table(Sno int identity(1,1), KeyValue nvarchar(1060))

			--Declare @RoundingTable Table (DetailDocId uniqueidentifier, DiffAmount money)
			IF @RoundingAmount Is Not Null And @RoundingAmount <>'' 
			Begin
				-- Opt : Combined the set clause
				Set @value=Replace(Replace(@RoundingAmount,'[',''),']','') 
				--Set @value=Replace(@value,']','')
				Insert Into @tempTable
				Select items From SplitToTable (@value,':')
				-- Opt : Replaced Set with Select
				Select @RndAmtcount= Count(*) From @tempTable
				Set @RndAmtReccount=1
				While @RndAmtcount>=@RndAmtReccount
				Begin
					Set @KeyPairValueRecCount=0
				    -- Opt : Replaced Set with Select
					Select @KeyPair= cast(stringVal As nvarchar(Max))  From @tempTable WHere Id=@RndAmtReccount
					-- Opt : Used table variable to replace the Cursor
					Delete From @KeyValue

					Insert Into @KeyValue
					Select items From SplitToTable(@KeyPair,',')

					Select @Min_Sno=Min(Sno) From @KeyValue
					Select @RndAmtDocid=KeyValue From @KeyValue Where Sno=@Min_Sno

					Insert Into @RoundingAmountDetails
					Select @RndAmtDocid,Cast(KeyValue As money) From @KeyValue Where Sno<>@Min_Sno

					/*
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
					*/
				    Set @RndAmtReccount=@RndAmtReccount+1
				End
			End
			Select @BaseCurrency=BaseCurrency,@BankChargesCurrency=BankPaymentAmmountCurrency,@DocCurrency=DocCurrency,@MainExchangeRate=ExchangeRate,
					@SysCalExchangerate=SystemCalculatedExchangeRate,@DocNo=DocNo,@MasterServComp=ServiceCompanyId
			From Bean.Payment 
			Where Id=@SourceId
			-- Opt : Replaced Set with Select
			Select @ServCompCount= Count(distinct ServiceCompanyId) From Bean.PaymentDetail Where PaymentId=@SourceId
			Select @ServCompCount2= Count(Id) From Bean.PaymentDetail 
			Where PaymentId=@SourceId 
			And ServiceCompanyId Not In (Select ServiceCompanyId From Bean.Payment Where Id=@SourceId)

			Select @PaymentOffSet= Count(*) From Bean.PaymentDetail 
			Where PaymentId=@SourceId And DocumentType=@CreditMemoDocument
			Select @IsCustomer= Isnull(IsCustomer,0) From Bean.Payment Where Id=@SourceId

			-- Payment Offset Inter Company
			IF (@IsCustomer=1 Or @PaymentOffSet>=1) And (@ServCompCount>1 Or @ServCompCount2 >=1)
			Begin
				Set @MasterJournalId=NEWID()
				Set @MasterSystemRefNo=CONCAT(@DocNo,'-JV',@SysRefNumOrder)
				Insert Into Bean.Journal (Id,CompanyId,DocDate,DocType,DocSubType,DocNo,ServiceCompanyId,SystemReferenceNo,IsNoSupportingDocs,NoSupportingDocument,DocCurrency,ExchangeRate,ExCurrency,ExDurationFrom,GSTExchangeRate,GSTExCurrency,GSTTotalAmount,DocumentState,IsNoSupportingDocument,IsGstSettings,IsMultiCurrency,IsAllowableNonAllowable,
										IsGSTCurrencyRateChanged,Remarks,UserCreated,CreatedDate,Status,DocumentDescription,CreationType,GrandDocDebitTotal,GrandDocCreditTotal,GrandBaseDebitTotal,
										GrandBaseCreditTotal,EntityId,EntityType,PostingDate,COAId,ModeOfReceipt,BankReceiptAmmount,ExcessPaidByClientAmmount,BalancingItemReciveCRAmount,  BalancingItemPayDRAmount,ReceiptApplicationAmmount,DocumentId,BankClearingDate,IsBalancing,ISAllowDisAllow,IsShow,ActualSysRefNo,IsSegmentReporting,TransferRefNo
										)
				Select @MasterJournalId,@CompanyId,DocDate,@DocType,@DocSubType,DocNo,ServiceCompanyId,@MasterSystemRefNo As SystemRefNo,IsNoSupportingDocument,NoSupportingDocs,DocCurrency,ExchangeRate,ExCurrency,ExDurationFrom,GSTExchangeRate,GSTExCurrency,Isnull(GSTTotalAmount,0),DocumentState,NoSupportingDocs,IsGstSettings,IsMultiCurrency,IsAllowableDisallowable,IsGSTCurrencyRateChanged,Remarks,@UserCreated,@CreatedDate,Status,Remarks As DocDescription,@UserCreated,GrandTotal,0.00 As GrandDocCreditTotal,Round(GrandTotal * ExchangeRate,2) As GrandBaseDebitTotal,
						0.00 As GrandBaseCreditTotal,EntityId,EntityType,DocDate As PostingDate,COAId,ModeOfReceipt,0.00 As BankReceiptAmmount,0.00 As ExcessPaidByClientAmmount,0.00 As BalancingItemReciveCRAmount,0.00 As BalancingItemPayDRAmount,0.00 As ReceiptApplicationAmmount,Id As DocumentId,BankClearingDate,0 As IsBalancing,IsDisAllow,1 As IsShow,DocNo As ActualSysRefNo,0 As IsSegmentReporting,PaymentRefNo
				From Bean.Payment Where CompanyId=@CompanyId And Id=@SourceId
				-- Opt : Replaced Set with Select
				Select @MainInterCoServCompCOAID= COA.Id 
				From Bean.ChartOfAccount As COA 
				Inner Join Bean.AccountType As ACT On ACT.Id=COA.AccountTypeId
				Where ACT.CompanyId=@CompanyId And ACT.Name=@IntercompClearingCOAName 
				And COA.SubsidaryCompanyId=@MasterServComp
											  
				IF @DocCurrency=@BankChargesCurrency And @BaseCurrency=@DocCurrency
				Begin
					IF Exists (Select Id From Bean.Payment Where Id=@SourceId And GrandTotal<>0)
					Begin
						/* Creating Mater record In JournalDetail */
						Insert Into Bean.JournalDetail (Id,JournalId,COAId,AccountDescription,AllowDisAllow,DocCredit,BaseCredit,DocDebitTotal,DocCreditTotal,BaseDebitTotal,BaseCreditTotal,DocumentId,DocumentDetailId,ItemId,BaseCurrency,ExchangeRate,GSTExCurrency,
														GSTExchangeRate,DocType,DocSubType,ServiceCompanyId,DocNo,IsTax,EntityId,SystemRefNo,DocCurrency,DocDate,PostingDate,RecOrder)
						Select NEWID(),@MasterJournalId,COAId,Remarks,IsDisAllow,GrandTotal,Round(GrandTotal * @MainExchangeRate,2),0.00 As DocDebitTotal,0.00 As DocCreditTotal,0.00 As BaseDebitTotal,0.00 As BaseCreditTotal,Id As DocumnetId,@GUIDZero,@GUIDZero,
								BaseCurrency,@MainExchangeRate As ExchangeRate,GSTExCurrency,GSTExchangeRate,@DocType,@DocSubType,ServiceCompanyId,DocNo,0 As IsTax,
								EntityId,@MasterSystemRefNo As SystemRefNo,@BankChargesCurrency,DocDate,DocDate,@MasterRecOrder As RecOrder
						From Bean.Payment Where Id=@SourceId
					End
					-- Service company details
					Insert Into @ServCompaIdTbl
					Select Distinct ServiceCompanyId From Bean.PaymentDetail Where PaymentId=@SourceId And PaymentAmount<>0
					-- Opt : Replaced Set with Select
					Select @ServCompaIdTblCnt= Count(*) From @ServCompaIdTbl 
					Set @RecCount=1
					While @ServCompaIdTblCnt>=@RecCount
					Begin
						-- Opt : Replaced Set with Select
						Select @ServCompId= SerCompId From @ServCompaIdTbl Where S_No=@RecCount
						IF @ServCompId=@MasterServComp
						Begin
							-- Detail Records
							Delete From @PaymentDtl_New
							Insert Into @PaymentDtl_New
							Select ROW_NUMBER() Over (Order By Id),Id From Bean.PaymentDetail Where PaymentId=@SourceId And ServiceCompanyId=@ServCompId And PaymentAmount<>0
							-- Opt : Replaced Set with Select
							Select @DtlCount= Count(*) From @PaymentDtl_New
							Set @RdtlRecCount=1
							While @DtlCount>=@RdtlRecCount
							Begin
								-- Opt : Replaced Set with Select
								Select @PaymentDtlId= PaymentDtlId From @PaymentDtl_New Where S_No=@RdtlRecCount
								Select @DocumentId= DocumentId From Bean.PaymentDetail Where ID=@PaymentDtlId
								Set @IsRoundingAmount=0
								IF Exists (Select Id From Bean.PaymentDetail Where Id=@PaymentDtlId And Nature=@NatureTrade And DocumentType =@InvoiceDocument)
								Begin
									-- Opt : Replaced Set with Select
									Select @COAID= Id From Bean.ChartOfAccount Where CompanyId=@CompanyId And Name=@COATradeReceivables
									IF Exists (Select Id From Bean.Invoice Where Id=@DocumentId And DocumentState In (@FullyApplied,@Fullypaid))
									Begin
										Set @IsRoundingAmount=1
									End
								End
								Else IF Exists (Select Id From Bean.PaymentDetail Where Id=@PaymentDtlId And Nature=@NatureOthers And DocumentType =@InvoiceDocument)
								Begin
									-- Opt : Replaced Set with Select
									Select @COAID= Id From Bean.ChartOfAccount 
									Where CompanyId=@CompanyId And Name=@COAotherReceivables
									IF Exists (Select Id From Bean.Invoice Where Id=@DocumentId And DocumentState In (@FullyApplied,@Fullypaid))
									Begin
										Set @IsRoundingAmount=1
									End
								End
								Else IF Exists (Select Id From Bean.PaymentDetail Where Id=@PaymentDtlId And Nature=@NatureTrade And DocumentType =@DebitNoteDocument)
								Begin
									-- Opt : Replaced Set with Select
									Select @COAID= Id From Bean.ChartOfAccount Where CompanyId=@CompanyId And Name=@COATradeReceivables
									IF Exists (Select Id From Bean.DebitNote Where Id=@DocumentId And DocumentState In (@FullyApplied,@Fullypaid))
									Begin
										Set @IsRoundingAmount=1
									End
								End
								Else IF Exists (Select Id From Bean.PaymentDetail Where Id=@PaymentDtlId And Nature=@NatureOthers And DocumentType =@DebitNoteDocument)
								Begin
									-- Opt : Replaced Set with Select
									Select @COAID= Id From Bean.ChartOfAccount Where CompanyId=@CompanyId And Name=@COAotherReceivables
									IF Exists (Select Id From Bean.DebitNote Where Id=@DocumentId And DocumentState In (@FullyApplied,@Fullypaid))
									Begin
										Set @IsRoundingAmount=1
									End
								End
								Else IF Exists (Select Id From Bean.PaymentDetail Where Id=@PaymentDtlId And Nature=@NatureTrade And DocumentType Not In (@InvoiceDocument,@DebitNoteDocument,@CreditNoteDocument,@CreditMemoDocument))
								Begin
									-- Opt : Replaced Set with Select
									Select @COAID= Id From Bean.ChartOfAccount Where CompanyId=@CompanyId And Name=@COATradePayables
									IF Exists (Select Id From Bean.Bill Where Id=@DocumentId And DocumentState In (@FullyApplied,@Fullypaid))
									Begin
										Set @IsRoundingAmount=1
									End
								End
								Else IF Exists (Select Id From Bean.PaymentDetail Where Id=@PaymentDtlId And Nature=@NatureOthers And DocumentType Not In (@InvoiceDocument,@DebitNoteDocument,@CreditNoteDocument,@CreditMemoDocument))
								Begin
									-- Opt : Replaced Set with Select
									Select @COAID= Id From Bean.ChartOfAccount Where CompanyId=@CompanyId And Name=@COAOtherPayables
									IF Exists (Select Id From Bean.Bill Where Id=@DocumentId And DocumentState In (@FullyApplied,@Fullypaid))
									Begin
										Set @IsRoundingAmount=1
									End
								End
								IF @IsRoundingAmount=1 And Exists (Select Amount From @RoundingAmountDetails Where DocumentId=@DocumentId And Amount Is Not Null And Amount<>'') --@RoundingAmount Is Not Null And @RoundingAmount <>''
								Begin
									-- Opt : Replaced Set with Select
									Select @DocAmount= Amount From @RoundingAmountDetails Where DocumentId=@DocumentId
								End
								Else
								Begin
									Set @DocAmount=0
								End
								-- Opt : Replaced Set with Select
								Select @OffSetDocumentType= DocumentType From Bean.PaymentDetail Where Id=@PaymentDtlId
								Set @MasterRecOrder=@MasterRecOrder+1
								IF @OffSetDocumentType=@InvoiceDocument Or @OffSetDocumentType=@DebitNoteDocument
								Begin
									Insert Into Bean.JournalDetail (Id,JournalId,COAId,AccountDescription,DocDebit,DocCredit,BaseDebit,BaseCredit,DocDebitTotal,DocCreditTotal,BaseDebitTotal,BaseCreditTotal,DocumentId,DocumentDetailId,ItemId,BaseCurrency,
																	ExchangeRate,DocType,DocSubType,ServiceCompanyId,DocNo,Nature,OffsetDocument,IsTax,EntityId,SystemRefNo,DocCurrency,DocDate,PostingDate,RecOrder
																	)
									Select NEWID(),@MasterJournalId,@COAID,P.Remarks,Null As DocDebit,PD.PaymentAmount As DocCredit,Null As BaseDebit,Round(PD.PaymentAmount * @MainExchangeRate,2)-Isnull(@DocAmount,0) As BaseCredit,
										0.00 As DocDebitTotal,0.00 As DocCreditTotal,0.00 As BaseDebitTotal,0.00 As BaseCreditTotal,P.Id As DocumnetId,PD.Id As DocumentDetailId,@GUIDZero,P.BaseCurrency,@MainExchangeRate As ExchangeRate,
										@DocType,@DocSubType,PD.ServiceCompanyId,P.DocNo,PD.Nature,Null As DocumentNo,0 As IsTax,P.EntityId,@MasterSystemRefNo,@BankChargesCurrency,P.DocDate,P.DocDate,@MasterRecOrder As RecOrder
									From Bean.Payment As P
									Inner Join bean.PaymentDetail As PD On PD.PaymentId=P.Id
									Where P.Id=@SourceId And PD.Id=@PaymentDtlId
								End
								Else IF @OffSetDocumentType=@CreditNoteDocument
								Begin
									Insert Into Bean.JournalDetail (Id,JournalId,COAId,AccountDescription,DocDebit,DocCredit,
																	BaseDebit,BaseCredit,
																	DocDebitTotal,DocCreditTotal,BaseDebitTotal,BaseCreditTotal,DocumentId,DocumentDetailId,ItemId,BaseCurrency,ExchangeRate,DocType,DocSubType,ServiceCompanyId,DocNo,Nature,OffsetDocument,IsTax,
																	EntityId,SystemRefNo,DocCurrency,DocDate,PostingDate,RecOrder
																	)
									Select NEWID(),@MasterJournalId,@ClearingPaymentsCOAID,P.Remarks,PD.PaymentAmount As DocDebit,Null As DocCredit,Round(PD.PaymentAmount * @MainExchangeRate,2) As BaseDebit,Null As BaseCredit,0.00 As DocDebitTotal,0.00 As DocCreditTotal,
											0.00 As BaseDebitTotal,0.00 As BaseCreditTotal,P.Id As DocumnetId,PD.Id As DocumentDetailId,@GUIDZero,P.BaseCurrency,@MainExchangeRate As ExchangeRate,@DocType,@DocSubType,PD.ServiceCompanyId,P.DocNo,PD.Nature,Null As DocumentNo,
											0 As IsTax,P.EntityId,@MasterSystemRefNo,@BankChargesCurrency,P.DocDate,P.DocDate,@MasterRecOrder As RecOrder
									From Bean.Payment As P
									Inner Join bean.PaymentDetail As PD On PD.PaymentId=P.Id
									Where P.Id=@SourceId And PD.Id=@PaymentDtlId
								End
								Else IF @OffSetDocumentType=@CreditMemoDocument
								Begin
									Insert Into Bean.JournalDetail (Id,JournalId,COAId,AccountDescription,DocDebit,DocCredit,
																	BaseDebit,BaseCredit,
																	DocDebitTotal,DocCreditTotal,BaseDebitTotal,BaseCreditTotal,DocumentId,DocumentDetailId,ItemId,BaseCurrency,ExchangeRate,DocType,DocSubType,ServiceCompanyId,DocNo,Nature,OffsetDocument,IsTax,
																	EntityId,SystemRefNo,DocCurrency,DocDate,PostingDate,RecOrder
																	)
									Select NEWID(),@MasterJournalId,@ClearingPaymentsCOAID,P.Remarks,Null As DocDebit,PD.PaymentAmount As DocCredit,Null As BaseDebit,Round(PD.PaymentAmount * @MainExchangeRate,2) As BaseCredit,0.00 As DocDebitTotal,0.00 As DocCreditTotal,
											0.00 As BaseDebitTotal,0.00 As BaseCreditTotal,P.Id As DocumnetId,PD.Id As DocumentDetailId,@GUIDZero,P.BaseCurrency,@MainExchangeRate As ExchangeRate,@DocType,@DocSubType,PD.ServiceCompanyId,P.DocNo,PD.Nature,Null As DocumentNo,0 As IsTax,
											P.EntityId,@MasterSystemRefNo,@BankChargesCurrency,P.DocDate,P.DocDate,@RecOrder As RecOrder
									From Bean.Payment As P
									Inner Join bean.PaymentDetail As PD On PD.PaymentId=P.Id
									Where P.Id=@SourceId And PD.Id=@PaymentDtlId
								End
								Else 
								Begin
									Insert Into Bean.JournalDetail (Id,JournalId,COAId,AccountDescription,DocDebit,DocCredit,BaseDebit,BaseCredit,DocDebitTotal,DocCreditTotal,BaseDebitTotal,BaseCreditTotal,DocumentId,DocumentDetailId,ItemId,BaseCurrency,ExchangeRate,DocType,DocSubType,
																	ServiceCompanyId,DocNo,Nature,OffsetDocument,IsTax,EntityId,SystemRefNo,DocCurrency,DocDate,PostingDate,RecOrder
																	)
									Select NEWID(),@MasterJournalId,@COAID,P.Remarks,PD.PaymentAmount As DocDebit,Null As DocCredit,Round(PD.PaymentAmount * @MainExchangeRate,2)-Isnull(@DocAmount,0) As BaseDebit,Null As BaseCredit,0.00 As DocDebitTotal,0.00 As DocCreditTotal,0.00 As BaseDebitTotal,
											0.00 As BaseCreditTotal,P.Id As DocumnetId,PD.Id As DocumentDetailId,@GUIDZero,P.BaseCurrency,@MainExchangeRate As ExchangeRate,@DocType,@DocSubType,PD.ServiceCompanyId,P.DocNo,PD.Nature,Null As DocumentNo,0 As IsTax,
											P.EntityId,@MasterSystemRefNo,@BankChargesCurrency,P.DocDate,P.DocDate,@MasterRecOrder As RecOrder
									From Bean.Payment As P
									Inner Join bean.PaymentDetail As PD On PD.PaymentId=P.Id
									Where P.Id=@SourceId And PD.Id=@PaymentDtlId
								End
								Set @RdtlRecCount=@RdtlRecCount+1
							End
						End
						-- Diffrent Service Companies
						Else
						Begin
							-- Opt : Replaced Set with Select
							Select @IntroCompCOAID= COA.Id 
							From Bean.ChartOfAccount As COA 
							Inner Join Bean.AccountType As ACT On ACT.Id=COA.AccountTypeId
							Where ACT.CompanyId=@CompanyId And ACT.Name=@IntercompClearingCOAName 
							And COA.SubsidaryCompanyId=@ServCompId
												
							If Exists (Select Id From Bean.PaymentDetail Where PaymentId=@SourceId And ServiceCompanyId=@ServCompId And DocumentType=@CreditMemoDocument And PaymentAmount<>0)
							Begin
								Set @MasterRecOrder=@MasterRecOrder+1
								-- Opt : Replaced Set with Select
								Select @PaymentAmtTotal= Sum(Isnull(PaymentAmount,0)) 
								From Bean.PaymentDetail Where ServiceCompanyId=@ServCompId 
								And PaymentId=@SourceId And DocumentType=@CreditMemoDocument
								Insert Into Bean.JournalDetail (Id,JournalId,COAId,AccountDescription,AllowDisAllow,DocCredit,BaseCredit,DocDebitTotal,DocCreditTotal,BaseDebitTotal,BaseCreditTotal,DocumentId,DocumentDetailId,ItemId,BaseCurrency,ExchangeRate,GSTExCurrency,GSTExchangeRate,DocType,
																DocSubType,ServiceCompanyId,DocNo,IsTax,EntityId,SystemRefNo,DocCurrency,DocDate,PostingDate,RecOrder)
								Select NEWID(),@MasterJournalId,@IntroCompCOAID,Remarks,IsDisAllow,@PaymentAmtTotal,Round(@PaymentAmtTotal * @MainExchangeRate,2),0.00 As DocDebitTotal,0.00 As DocCreditTotal,0.00 As BaseDebitTotal,0.00 As BaseCreditTotal,Id As DocumnetId,@GUIDZero,@GUIDZero,
										BaseCurrency,@MainExchangeRate As ExchangeRate,GSTExCurrency,GSTExchangeRate,@DocType,@DocSubType,@ServCompId As ServiceCompanyId,DocNo,0 As IsTax,EntityId,@MasterSystemRefNo As SystemRefNo,@BankChargesCurrency,DocDate,DocDate,@MasterRecOrder As RecOrder
								From Bean.Payment Where Id=@SourceId
							End
							If Exists (Select Id From Bean.PaymentDetail Where PaymentId=@SourceId And ServiceCompanyId=@ServCompId And DocumentType=@CreditNoteDocument And PaymentAmount<>0)
							Begin
								Set @MasterRecOrder=@MasterRecOrder+1
								-- Opt : Replaced Set with Select
								Select @PaymentAmtTotal=Sum(Isnull(PaymentAmount,0)) 
								From Bean.PaymentDetail 
								Where ServiceCompanyId=@ServCompId And PaymentId=@SourceId 
								And DocumentType=@CreditNoteDocument

								Insert Into Bean.JournalDetail (Id,JournalId,COAId,AccountDescription,AllowDisAllow,DocDebit,BaseDebit,DocDebitTotal,DocCreditTotal,BaseDebitTotal,BaseCreditTotal,DocumentId,DocumentDetailId,ItemId,BaseCurrency,ExchangeRate,GSTExCurrency,GSTExchangeRate,DocType,DocSubType,ServiceCompanyId,DocNo,IsTax,
												EntityId,SystemRefNo,DocCurrency,DocDate,PostingDate,RecOrder)
								Select NEWID(),@MasterJournalId,@IntroCompCOAID,Remarks,IsDisAllow,@PaymentAmtTotal,Round(@PaymentAmtTotal * @MainExchangeRate,2),0.00 As DocDebitTotal,0.00 As DocCreditTotal,0.00 As BaseDebitTotal,0.00 As BaseCreditTotal,Id As DocumnetId,@GUIDZero,@GUIDZero,
										BaseCurrency,@MainExchangeRate As ExchangeRate,GSTExCurrency,GSTExchangeRate,@DocType,@DocSubType,@ServCompId As ServiceCompanyId,DocNo,0 As IsTax,
										EntityId,@MasterSystemRefNo As SystemRefNo,@BankChargesCurrency,DocDate,DocDate,@MasterRecOrder As RecOrder
								From Bean.Payment Where Id=@SourceId
							End

							Set @MasterRecOrder=@MasterRecOrder+1
							--Set @PaymentAmtTotal=(Select Sum(Isnull(PaymentAmount,0)) From Bean.PaymentDetail Where ServiceCompanyId=@ServCompId And PaymentId=@SourceId And DocumentType Not in (@CreditMemoDocument,@CreditNoteDocument) )
							-- Opt : Replaced Set with Select
							Select @ClearingPaymentInvOrDNAmount= SUM(Isnull(PaymentAmount,0)) 
							From bean.PaymentDetail 
							Where PaymentId=@SourceId And ServiceCompanyId=@ServCompId 
							And DocumentType In (@InvoiceDocument,@DebitNoteDocument)

							Select @ClearingPaymentBillAmount= SUM(Isnull(PaymentAmount,0)) 
							From bean.PaymentDetail 
							Where PaymentId=@SourceId And ServiceCompanyId=@ServCompId 
							And DocumentType Not In (@CreditMemoDocument,@CreditNoteDocument,@InvoiceDocument,@DebitNoteDocument)
							Set @PaymentAmtTotal=ABS(Isnull(@ClearingPaymentBillAmount,0)-Isnull(@ClearingPaymentInvOrDNAmount,0))
							If @PaymentAmtTotal Is Not null And @PaymentAmtTotal<>0
							Begin
								IF (Isnull(@ClearingPaymentBillAmount,0)-Isnull(@ClearingPaymentInvOrDNAmount,0)) <0
								Begin
									/* Creating Mater record In Master JournalDetail */
									Insert Into Bean.JournalDetail (Id,JournalId,COAId,AccountDescription,AllowDisAllow,DocCredit,BaseCredit,DocDebitTotal,DocCreditTotal,BaseDebitTotal,BaseCreditTotal,DocumentId,DocumentDetailId,ItemId,
													BaseCurrency,ExchangeRate,GSTExCurrency,GSTExchangeRate,DocType,DocSubType,ServiceCompanyId,DocNo,IsTax,EntityId,SystemRefNo,DocCurrency,DocDate,PostingDate,RecOrder)
									Select NEWID(),@MasterJournalId,@IntroCompCOAID,Remarks,IsDisAllow,@PaymentAmtTotal,Round(@PaymentAmtTotal * @MainExchangeRate,2),0.00 As DocDebitTotal,0.00 As DocCreditTotal,0.00 As BaseDebitTotal,0.00 As BaseCreditTotal,Id As DocumnetId,@GUIDZero,@GUIDZero,
											BaseCurrency,@MainExchangeRate As ExchangeRate,GSTExCurrency,GSTExchangeRate,@DocType,@DocSubType,@ServCompId As ServiceCompanyId,DocNo,0 As IsTax,EntityId,@MasterSystemRefNo As SystemRefNo,@BankChargesCurrency,DocDate,DocDate,@MasterRecOrder As RecOrder
									From Bean.Payment Where Id=@SourceId
								End
								Else 
								Begin
									/* Creating Mater record In Master JournalDetail */
									Insert Into Bean.JournalDetail (Id,JournalId,COAId,AccountDescription,AllowDisAllow,DocDebit,BaseDebit,DocDebitTotal,DocCreditTotal,BaseDebitTotal,BaseCreditTotal,DocumentId,DocumentDetailId,ItemId,
													BaseCurrency,ExchangeRate,GSTExCurrency,GSTExchangeRate,DocType,DocSubType,ServiceCompanyId,DocNo,IsTax,EntityId,SystemRefNo,DocCurrency,DocDate,PostingDate,RecOrder)
									Select NEWID(),@MasterJournalId,@IntroCompCOAID,Remarks,IsDisAllow,@PaymentAmtTotal,Round(@PaymentAmtTotal * @MainExchangeRate,2),0.00 As DocDebitTotal,0.00 As DocCreditTotal,0.00 As BaseDebitTotal,0.00 As BaseCreditTotal,Id As DocumnetId,@GUIDZero,@GUIDZero,
											BaseCurrency,@MainExchangeRate As ExchangeRate,GSTExCurrency,GSTExchangeRate,@DocType,@DocSubType,@ServCompId As ServiceCompanyId,DocNo,0 As IsTax,EntityId,@MasterSystemRefNo As SystemRefNo,@BankChargesCurrency,DocDate,DocDate,@MasterRecOrder As RecOrder
									From Bean.Payment Where Id=@SourceId
								End
								-- New Journals
								Set @SysRefNumOrder=@SysRefNumOrder+1
								Set @SystemRefNo=Concat(@DocNo,'-JV',@SysRefNumOrder)
								Set @JournalId=NEWID()
								Insert Into Bean.Journal (Id,CompanyId,DocDate,DocType,DocSubType,DocNo,ServiceCompanyId,SystemReferenceNo,IsNoSupportingDocs,NoSupportingDocument,DocCurrency,ExchangeRate,ExCurrency,ExDurationFrom,GSTExchangeRate,GSTExCurrency,GSTTotalAmount,DocumentState,IsNoSupportingDocument,IsGstSettings,IsMultiCurrency,IsAllowableNonAllowable,IsGSTCurrencyRateChanged,Remarks,UserCreated,CreatedDate,Status,DocumentDescription,CreationType,GrandDocDebitTotal,GrandDocCreditTotal,GrandBaseDebitTotal,
														 GrandBaseCreditTotal,EntityId,EntityType,PostingDate,COAId,ModeOfReceipt,BankReceiptAmmount,ExcessPaidByClientAmmount,BalancingItemReciveCRAmount,  BalancingItemPayDRAmount,ReceiptApplicationAmmount,DocumentId,BankClearingDate,IsBalancing,ISAllowDisAllow,IsShow,ActualSysRefNo
														 ,IsSegmentReporting,TransferRefNo
														 )
								Select @JournalId,@CompanyId,DocDate,@DocType,@DocSubType,DocNo,@ServCompId,@SystemRefNo As SystemRefNo,IsNoSupportingDocument,NoSupportingDocs,DocCurrency,ExchangeRate,ExCurrency,ExDurationFrom,GSTExchangeRate,GSTExCurrency,Isnull(GSTTotalAmount,0),DocumentState,NoSupportingDocs,IsGstSettings,IsMultiCurrency,IsAllowableDisallowable,IsGSTCurrencyRateChanged,Remarks,@UserCreated,@CreatedDate,Status,Remarks As DocDescription,@UserCreated,GrandTotal,0.00 As GrandDocCreditTotal,Round(GrandTotal * ExchangeRate,2) As GrandBaseDebitTotal,
										0.00 As GrandBaseCreditTotal,EntityId,EntityType,DocDate As PostingDate,COAId,ModeOfReceipt,0.00 As BankReceiptAmmount,0.00 As ExcessPaidByClientAmmount,0.00 As BalancingItemReciveCRAmount,0.00 As BalancingItemPayDRAmount,0.00 As ReceiptApplicationAmmount,Id As DocumentId,BankClearingDate,0 As IsBalancing,IsDisAllow,1 As IsShow,DocNo As ActualSysRefNo,0 As IsSegmentReporting,PaymentRefNo
								From Bean.Payment Where CompanyId=@CompanyId And Id=@SourceId
								IF (Isnull(@ClearingPaymentBillAmount,0)-Isnull(@ClearingPaymentInvOrDNAmount,0)) <0
								Begin
									/* Creating Mater record In JournalDetail */
									Insert Into Bean.JournalDetail (Id,JournalId,COAId,AccountDescription,AllowDisAllow,DocDebit,BaseDebit,DocDebitTotal,DocCreditTotal,BaseDebitTotal,BaseCreditTotal,DocumentId,DocumentDetailId,ItemId,BaseCurrency,ExchangeRate,GSTExCurrency,GSTExchangeRate,DocType,DocSubType,ServiceCompanyId,DocNo,IsTax,
													EntityId, SystemRefNo, DocCurrency,DocDate, PostingDate,RecOrder )
									Select NEWID(),@JournalId,@MainInterCoServCompCOAID,Remarks,IsDisAllow,@PaymentAmtTotal,Round(@PaymentAmtTotal * @MainExchangeRate,2),0.00 As DocDebitTotal,0.00 As DocCreditTotal,0.00 As BaseDebitTotal,0.00 As BaseCreditTotal,Id As DocumnetId,@GUIDZero,@GUIDZero,
											BaseCurrency,@MainExchangeRate As ExchangeRate,GSTExCurrency,GSTExchangeRate,@DocType,@DocSubType,@ServCompId As ServiceCompanyId,DocNo,0 As IsTax,EntityId,@SystemRefNo As SystemRefNo,@BankChargesCurrency,DocDate,DocDate,@RecOrder As RecOrder
									From Bean.Payment Where Id=@SourceId
								End
								Else
								Begin
									/* Creating Mater record In JournalDetail */
									Insert Into Bean.JournalDetail (Id,JournalId,COAId,AccountDescription,AllowDisAllow,DocCredit,BaseCredit,DocDebitTotal,DocCreditTotal,BaseDebitTotal,BaseCreditTotal,DocumentId,DocumentDetailId,ItemId,BaseCurrency,ExchangeRate,GSTExCurrency,GSTExchangeRate,DocType,DocSubType,ServiceCompanyId,DocNo,IsTax,
													EntityId, SystemRefNo, DocCurrency,DocDate, PostingDate,RecOrder )
									Select NEWID(),@JournalId,@MainInterCoServCompCOAID,Remarks,IsDisAllow,@PaymentAmtTotal,Round(@PaymentAmtTotal * @MainExchangeRate,2),0.00 As DocDebitTotal,0.00 As DocCreditTotal,0.00 As BaseDebitTotal,0.00 As BaseCreditTotal,Id As DocumnetId,@GUIDZero,@GUIDZero,
											BaseCurrency,@MainExchangeRate As ExchangeRate,GSTExCurrency,GSTExchangeRate,@DocType,@DocSubType,@ServCompId As ServiceCompanyId,DocNo,0 As IsTax,EntityId,@SystemRefNo As SystemRefNo,@BankChargesCurrency,DocDate,DocDate,@RecOrder As RecOrder
									From Bean.Payment Where Id=@SourceId
								End
								-- Payment detail records
								Delete From @PaymentDtl_New
								Insert Into @PaymentDtl_New
								Select ROW_NUMBER() Over (Order By Id),Id From Bean.PaymentDetail Where PaymentId=@SourceId And ServiceCompanyId=@ServCompId And DocumentType Not in (@CreditMemoDocument,@CreditNoteDocument)
								-- Opt : Replaced Set with Select
								Select @DtlCount= Count(*) From @PaymentDtl_New
								Set @RdtlRecCount=1
								While @DtlCount>=@RdtlRecCount
								Begin
									-- Opt : Replaced Set with Select
									Select @PaymentDtlId= PaymentDtlId From @PaymentDtl_New Where S_No=@RdtlRecCount
									Select @DocumentId= DocumentId From Bean.PaymentDetail Where id=@PaymentDtlId
									Set @IsRoundingAmount=0
									IF Exists (Select Id From Bean.PaymentDetail Where Id=@PaymentDtlId And Nature=@NatureTrade And DocumentType =@InvoiceDocument)
									Begin
										-- Opt : Replaced Set with Select
										Select @COAID= Id From Bean.ChartOfAccount Where CompanyId=@CompanyId And Name=@COATradeReceivables
										IF Exists (Select Id From Bean.Invoice Where Id=@DocumentId And DocumentState In (@FullyApplied,@Fullypaid))
										Begin
											Set @IsRoundingAmount=1
										End
									End
									Else IF Exists (Select Id From Bean.PaymentDetail Where Id=@PaymentDtlId And Nature=@NatureOthers And DocumentType = @InvoiceDocument)
									Begin
										-- Opt : Replaced Set with Select
										Select @COAID= Id From Bean.ChartOfAccount Where CompanyId=@CompanyId And Name=@COAotherReceivables
										IF Exists (Select Id From Bean.Invoice Where Id=@DocumentId And DocumentState In (@FullyApplied,@Fullypaid))
										Begin
											Set @IsRoundingAmount=1
										End
									End
									Else IF Exists (Select Id From Bean.PaymentDetail Where Id=@PaymentDtlId And Nature=@NatureTrade And DocumentType =@DebitNoteDocument)
									Begin
										-- Opt : Replaced Set with Select
										Select @COAID= Id From Bean.ChartOfAccount Where CompanyId=@CompanyId And Name=@COATradeReceivables
										IF Exists (Select Id From Bean.DebitNote Where Id=@DocumentId And DocumentState In (@FullyApplied,@Fullypaid))
										Begin
											Set @IsRoundingAmount=1
										End
									End
									Else IF Exists (Select Id From Bean.PaymentDetail Where Id=@PaymentDtlId And Nature=@NatureOthers And DocumentType = @DebitNoteDocument)
									Begin
										-- Opt : Replaced Set with Select
										Select @COAID= Id From Bean.ChartOfAccount Where CompanyId=@CompanyId And Name=@COAotherReceivables
										IF Exists (Select Id From Bean.DebitNote Where Id=@DocumentId And DocumentState In (@FullyApplied,@Fullypaid))
										Begin
											Set @IsRoundingAmount=1
										End
									End
									Else IF Exists (Select Id From Bean.PaymentDetail Where Id=@PaymentDtlId And Nature=@NatureTrade And DocumentType Not In (@InvoiceDocument,@DebitNoteDocument,@CreditNoteDocument,@CreditMemoDocument))
									Begin
										-- Opt : Replaced Set with Select
										Select @COAID= Id From Bean.ChartOfAccount Where CompanyId=@CompanyId And Name=@COATradePayables
										IF Exists (Select Id From Bean.Bill Where Id=@DocumentId And DocumentState In (@FullyApplied,@Fullypaid))
										Begin
											Set @IsRoundingAmount=1
										End
									End
									Else IF Exists (Select Id From Bean.PaymentDetail Where Id=@PaymentDtlId And Nature=@NatureOthers And DocumentType Not In (@InvoiceDocument,@DebitNoteDocument,@CreditNoteDocument,@CreditMemoDocument))
									Begin
										-- Opt : Replaced Set with Select
										Select @COAID= Id From Bean.ChartOfAccount Where CompanyId=@CompanyId And Name=@COAOtherPayables
										IF Exists (Select Id From Bean.Bill Where Id=@DocumentId And DocumentState In (@FullyApplied,@Fullypaid))
										Begin
											Set @IsRoundingAmount=1
										End
									End
									IF @IsRoundingAmount=1  And Exists (Select Amount From @RoundingAmountDetails Where DocumentId=@DocumentId And Amount Is Not Null And Amount<>'') --And @RoundingAmount Is Not Null And @RoundingAmount <>''
									Begin
										-- Opt : Replaced Set with Select
										Select @DocAmount= Amount From @RoundingAmountDetails Where DocumentId=@DocumentId
									End
									Else
									Begin
										Set @DocAmount=0
									End
									-- Opt : Replaced Set with Select
									Select @OffSetDocumentType= DocumentType From Bean.PaymentDetail Where Id=@PaymentDtlId
									Set @RecOrder=@RecOrder+1
									IF @OffSetDocumentType=@InvoiceDocument Or @OffSetDocumentType=@DebitNoteDocument
									Begin
										Insert Into Bean.JournalDetail (Id,JournalId,COAId,AccountDescription,DocDebit,DocCredit,BaseDebit,BaseCredit,DocDebitTotal,DocCreditTotal,BaseDebitTotal,BaseCreditTotal,DocumentId,DocumentDetailId,ItemId,BaseCurrency,ExchangeRate,DocType,DocSubType,ServiceCompanyId,
																		DocNo,Nature,OffsetDocument,IsTax,EntityId, SystemRefNo, DocCurrency,DocDate, PostingDate,RecOrder 
																		)
										Select NEWID(),@JournalId,@COAID,P.Remarks,Null As DocDebit,PD.PaymentAmount As DocCredit,Null As BaseDebit,Round(PD.PaymentAmount * @MainExchangeRate,2)-Isnull(@DocAmount,0) As BaseCredit,0.00 As DocDebitTotal,0.00 As DocCreditTotal,0.00 As BaseDebitTotal,0.00 As BaseCreditTotal,
												P.Id As DocumnetId,PD.Id As DocumentDetailId,@GUIDZero,P.BaseCurrency,@MainExchangeRate As ExchangeRate,@DocType,@DocSubType,PD.ServiceCompanyId,P.DocNo,PD.Nature,Null As DocumentNo,0 As IsTax,P.EntityId,@SystemRefNo,@DocCurrency,P.DocDate,P.DocDate,@RecOrder As RecOrder
										From Bean.Payment As P
										Inner Join bean.PaymentDetail As PD On PD.PaymentId=P.Id
										Where P.Id=@SourceId And PD.Id=@PaymentDtlId
									End
									Else 
									Begin
										Insert Into Bean.JournalDetail (Id,JournalId,COAId,AccountDescription, DocDebit,DocCredit,BaseDebit,BaseCredit,DocDebitTotal,DocCreditTotal,BaseDebitTotal,BaseCreditTotal,DocumentId,DocumentDetailId,ItemId,
																		BaseCurrency,ExchangeRate, DocType,DocSubType,ServiceCompanyId,DocNo,Nature,OffsetDocument,IsTax,EntityId, SystemRefNo, DocCurrency,DocDate, PostingDate,RecOrder 
																		)
										Select NEWID(),@JournalId,@COAID,P.Remarks,PD.PaymentAmount As DocDebit,Null As DocCredit,Round(PD.PaymentAmount * @MainExchangeRate,2)-Isnull(@DocAmount,0) As BaseDebit,Null As BaseCredit,
											0.00 As DocDebitTotal,0.00 As DocCreditTotal,0.00 As BaseDebitTotal,0.00 As BaseCreditTotal,P.Id As DocumnetId,PD.Id As DocumentDetailId,@GUIDZero,P.BaseCurrency,@MainExchangeRate As ExchangeRate,
											@DocType,@DocSubType,PD.ServiceCompanyId,P.DocNo,PD.Nature,Null As DocumentNo,0 As IsTax,P.EntityId,@SystemRefNo,@DocCurrency,P.DocDate,P.DocDate,@RecOrder As RecOrder
										From Bean.Payment As P
										Inner Join bean.PaymentDetail As PD On PD.PaymentId=P.Id
										Where P.Id=@SourceId And PD.Id=@PaymentDtlId
									End
									Set @RdtlRecCount=@RdtlRecCount+1
								End
							End
						End
						Set @RecCount=@RecCount+1
					End
				End
				Else IF @DocCurrency=@BankChargesCurrency And @BaseCurrency<>@DocCurrency
				Begin
					/* Creating Mater record In JournalDetail */
					Insert Into Bean.JournalDetail (Id,JournalId,COAId,AccountDescription,AllowDisAllow,DocCredit,BaseCredit,DocDebitTotal,DocCreditTotal,BaseDebitTotal,BaseCreditTotal,DocumentId,DocumentDetailId,ItemId,BaseCurrency,ExchangeRate,GSTExCurrency,GSTExchangeRate,DocType,DocSubType,ServiceCompanyId,DocNo,IsTax,
													EntityId,SystemRefNo,DocCurrency,DocDate,PostingDate,RecOrder)
					Select NEWID(),@MasterJournalId,COAId,Remarks,IsDisAllow,GrandTotal,Round(GrandTotal * @MainExchangeRate,2),0.00 As DocDebitTotal,0.00 As DocCreditTotal,0.00 As BaseDebitTotal,0.00 As BaseCreditTotal,Id As DocumnetId,@GUIDZero,@GUIDZero,
							BaseCurrency,@MainExchangeRate As ExchangeRate,GSTExCurrency,GSTExchangeRate,@DocType,@DocSubType,ServiceCompanyId,DocNo,0 As IsTax,EntityId,@MasterSystemRefNo As SystemRefNo,@BankChargesCurrency,DocDate,DocDate,@MasterRecOrder As RecOrder
					From Bean.Payment Where Id=@SourceId
					-- Service company details
					Insert Into @ServCompaIdTbl
					Select Distinct ServiceCompanyId From Bean.PaymentDetail Where PaymentId=@SourceId And PaymentAmount<>0
					-- Opt : Replaced Set with Select
					Select @ServCompaIdTblCnt= Count(*) From @ServCompaIdTbl
					Set @RecCount=1
					While @ServCompaIdTblCnt>=@RecCount
					Begin
						-- Opt : Replaced Set with Select
						Select @ServCompId= SerCompId From @ServCompaIdTbl Where S_No=@RecCount
						IF @ServCompId=@MasterServComp
						Begin
							-- Detail Records
							Delete From @PaymentDtl_New
							Insert Into @PaymentDtl_New
							Select ROW_NUMBER() Over (Order By Id),Id From Bean.PaymentDetail Where PaymentId=@SourceId And ServiceCompanyId=@ServCompId And PaymentAmount<>0
							-- Opt : Replaced Set with Select
							Select @DtlCount= Count(*) From @PaymentDtl_New
							Set @RdtlRecCount=1
							While @DtlCount>=@RdtlRecCount
							Begin
								-- Opt : Replaced Set with Select
								Select @PaymentDtlId= PaymentDtlId From @PaymentDtl_New Where S_No=@RdtlRecCount
								Select @DocumentId= DocumentId From Bean.PaymentDetail Where Id=@PaymentDtlId
								Set @IsRoundingAmount=0
								IF Exists (Select Id From Bean.PaymentDetail Where Id=@PaymentDtlId And Nature=@NatureTrade And DocumentType =@InvoiceDocument)
								Begin
									-- Opt : Replaced Set with Select
									Select @COAID= Id From Bean.ChartOfAccount Where CompanyId=@CompanyId And Name=@COATradeReceivables
									Select @ExchangeRate= ExchangeRate From Bean.Invoice Where Id=@DocumentId
									IF Exists (Select Id From Bean.Invoice Where Id=@DocumentId And DocumentState In (@FullyApplied,@Fullypaid))
									Begin
										Set @IsRoundingAmount=1
									End
								End
								Else IF Exists (Select Id From Bean.PaymentDetail Where Id=@PaymentDtlId And Nature=@NatureOthers And DocumentType =@InvoiceDocument)
								Begin
									-- Opt : Replaced Set with Select
									Select @COAID= Id From Bean.ChartOfAccount Where CompanyId=@CompanyId And Name=@COAotherReceivables
									Select @ExchangeRate= ExchangeRate From Bean.Invoice Where Id=@DocumentId
									IF Exists (Select Id From Bean.Invoice Where Id=@DocumentId And DocumentState In (@FullyApplied,@Fullypaid))
									Begin
										Set @IsRoundingAmount=1
									End
								End
								IF Exists (Select Id From Bean.PaymentDetail Where Id=@PaymentDtlId And Nature=@NatureTrade And DocumentType =@DebitNoteDocument)
								Begin
									-- Opt : Replaced Set with Select
									Select @COAID= Id From Bean.ChartOfAccount Where CompanyId=@CompanyId And Name=@COATradeReceivables
									Select @ExchangeRate= ExchangeRate From Bean.DebitNote Where Id=@DocumentId
									IF Exists (Select Id From Bean.DebitNote Where Id=@DocumentId And DocumentState In (@FullyApplied,@Fullypaid))
									Begin
										Set @IsRoundingAmount=1
									End
								End
								Else IF Exists (Select Id From Bean.PaymentDetail Where Id=@PaymentDtlId And Nature=@NatureOthers And DocumentType =@DebitNoteDocument)
								Begin
									-- Opt : Replaced Set with Select
									Select @COAID= Id From Bean.ChartOfAccount Where CompanyId=@CompanyId And Name=@COAotherReceivables
									Select @ExchangeRate= ExchangeRate From Bean.DebitNote Where Id=@DocumentId
									IF Exists (Select Id From Bean.DebitNote Where Id=@DocumentId And DocumentState In (@FullyApplied,@Fullypaid))
									Begin
										Set @IsRoundingAmount=1
									End
								End
								Else IF Exists (Select Id From Bean.PaymentDetail Where Id=@PaymentDtlId And Nature=@NatureTrade And DocumentType Not In (@InvoiceDocument,@DebitNoteDocument,@CreditNoteDocument,@CreditMemoDocument))
								Begin
									-- Opt : Replaced Set with Select
									Select @COAID= Id From Bean.ChartOfAccount Where CompanyId=@CompanyId And Name=@COATradePayables
									Select @ExchangeRate= ExchangeRate From Bean.Bill Where Id=@DocumentId
									IF Exists (Select Id From Bean.Bill Where Id=@DocumentId And DocumentState In (@FullyApplied,@Fullypaid))
									Begin
										Set @IsRoundingAmount=1
									End
								End
								Else IF Exists (Select Id From Bean.PaymentDetail Where Id=@PaymentDtlId And Nature=@NatureOthers And DocumentType Not In (@InvoiceDocument,@DebitNoteDocument,@CreditNoteDocument,@CreditMemoDocument))
								Begin
									-- Opt : Replaced Set with Select
									Select @COAID= Id From Bean.ChartOfAccount Where CompanyId=@CompanyId And Name=@COAOtherPayables
									Select @ExchangeRate= ExchangeRate From Bean.Bill Where Id=@DocumentId
									IF Exists (Select Id From Bean.Bill Where Id=@DocumentId And DocumentState In (@FullyApplied,@Fullypaid))
									Begin
										Set @IsRoundingAmount=1
									End
								End
								IF @IsRoundingAmount=1 And Exists (Select Amount From @RoundingAmountDetails Where DocumentId=@DocumentId And Amount Is Not Null And Amount<>'') -- And @RoundingAmount Is Not Null And @RoundingAmount <>''
								Begin
									-- Opt : Replaced Set with Select
									Select @DocAmount= Amount From @RoundingAmountDetails Where DocumentId=@DocumentId
								End
								Else
								Begin
									Set @DocAmount=0
								End
								-- Opt : Replaced Set with Select
								Select @OffSetDocumentType= DocumentType From Bean.PaymentDetail Where Id=@PaymentDtlId
								Set @MasterRecOrder=@MasterRecOrder+1
								IF @OffSetDocumentType=@InvoiceDocument Or @OffSetDocumentType=@DebitNoteDocument
								Begin
									Insert Into Bean.JournalDetail (Id,JournalId,COAId,AccountDescription,DocDebit,DocCredit,BaseDebit,BaseCredit,DocDebitTotal,DocCreditTotal,BaseDebitTotal,BaseCreditTotal,DocumentId,DocumentDetailId,ItemId,BaseCurrency,ExchangeRate,
																	DocType,DocSubType,ServiceCompanyId,DocNo,Nature,OffsetDocument,IsTax,EntityId,SystemRefNo,DocCurrency,DocDate,PostingDate,RecOrder
																	)
									Select NEWID(),@MasterJournalId,@COAID,P.Remarks,Null As DocDebit,PD.PaymentAmount As DocCredit,Null As BaseDebit,Round(PD.PaymentAmount * @ExchangeRate,2)-Isnull(@DocAmount,0) As BaseCredit,
											0.00 As DocDebitTotal,0.00 As DocCreditTotal,0.00 As BaseDebitTotal,0.00 As BaseCreditTotal,P.Id As DocumnetId,PD.Id As DocumentDetailId,@GUIDZero,P.BaseCurrency,@ExchangeRate As ExchangeRate,
											@DocType,@DocSubType,PD.ServiceCompanyId,P.DocNo,PD.Nature,Null As DocumentNo,0 As IsTax,P.EntityId,@MasterSystemRefNo,@BankChargesCurrency,P.DocDate,P.DocDate,@MasterRecOrder As RecOrder
									From Bean.Payment As P
									Inner Join bean.PaymentDetail As PD On PD.PaymentId=P.Id
									Where P.Id=@SourceId And PD.Id=@PaymentDtlId
									IF @MainExchangeRate-@ExchangeRate<>0
									Begin
										-- Exchangegain or Loss
										-- Opt : Replaced Set with Select
										Select @COAID= Id From Bean.ChartOfAccount Where CompanyId=@CompanyId And Name=@ExchangeGainOrLossRealised
										Set @MasterRecOrder=@MasterRecOrder+1
										Insert Into Bean.JournalDetail (Id,JournalId,COAId,AccountDescription,DocDebit,DocCredit,
																		BaseDebit,BaseCredit,
																		DocDebitTotal,DocCreditTotal,BaseDebitTotal,BaseCreditTotal,DocumentId,DocumentDetailId,ItemId,BaseCurrency,ExchangeRate,DocType,DocSubType,ServiceCompanyId,DocNo,Nature,OffsetDocument,IsTax,
																		EntityId,SystemRefNo,DocCurrency,DocDate,PostingDate,RecOrder
																		)
										Select NEWID(),@MasterJournalId,@COAID,P.Remarks,Null As DocDebit,Null As DocCredit,
												Case When (@MainExchangeRate-@ExchangeRate)<0 Then ABS(Round((@MainExchangeRate-@ExchangeRate)  * PD.PaymentAmount,2)) End As BaseDebit,Case When (@MainExchangeRate-@ExchangeRate)>0 Then ABS(Round((@MainExchangeRate-@ExchangeRate) * PD.PaymentAmount,2) ) End As BaseCredit,
												0.00 As DocDebitTotal,0.00 As DocCreditTotal,0.00 As BaseDebitTotal,0.00 As BaseCreditTotal,P.Id As DocumnetId,PD.Id As DocumentDetailId,@GUIDZero,P.BaseCurrency,P.ExchangeRate,@DocType,@DocSubType,PD.ServiceCompanyId,P.DocNo,PD.Nature,PD.DocumentNo,0 As IsTax,
												EntityId,@MasterSystemRefNo,@BankChargesCurrency,DocDate,DocDate,@MasterRecOrder As RecOrder
										From Bean.Payment As P
										Inner Join bean.PaymentDetail As PD On PD.PaymentId=P.Id
										Where P.Id=@SourceId And PD.Id=@PaymentDtlId
									End
								End
								Else IF @OffSetDocumentType=@CreditNoteDocument
								Begin
									Insert Into Bean.JournalDetail (Id,JournalId,COAId,AccountDescription,DocDebit,DocCredit,BaseDebit,BaseCredit,DocDebitTotal,DocCreditTotal,BaseDebitTotal,BaseCreditTotal,DocumentId,DocumentDetailId,ItemId,BaseCurrency,ExchangeRate,DocType,DocSubType,ServiceCompanyId,
																	DocNo,Nature,OffsetDocument,IsTax,EntityId,SystemRefNo,DocCurrency,DocDate,PostingDate,RecOrder
																	)
									Select NEWID(),@MasterJournalId,@ClearingPaymentsCOAID,P.Remarks,PD.PaymentAmount As DocDebit,Null As DocCredit,Round(PD.PaymentAmount * @MainExchangeRate,2) As BaseDebit,Null As BaseCredit,0.00 As DocDebitTotal,0.00 As DocCreditTotal,0.00 As BaseDebitTotal,
											0.00 As BaseCreditTotal,P.Id As DocumnetId,PD.Id As DocumentDetailId,@GUIDZero,P.BaseCurrency,@MainExchangeRate As ExchangeRate,@DocType,@DocSubType,PD.ServiceCompanyId,P.DocNo,PD.Nature,Null As DocumentNo,0 As IsTax,
											P.EntityId,@MasterSystemRefNo,@BankChargesCurrency,P.DocDate,P.DocDate,@MasterRecOrder As RecOrder
									From Bean.Payment As P
									Inner Join bean.PaymentDetail As PD On PD.PaymentId=P.Id
									Where P.Id=@SourceId And PD.Id=@PaymentDtlId
								End
								Else IF @OffSetDocumentType=@CreditMemoDocument
								Begin
									Insert Into Bean.JournalDetail (Id,JournalId,COAId,AccountDescription,DocDebit,DocCredit,BaseDebit,BaseCredit,DocDebitTotal,DocCreditTotal,BaseDebitTotal,BaseCreditTotal,DocumentId,DocumentDetailId,ItemId,BaseCurrency,ExchangeRate,
																	DocType,DocSubType,ServiceCompanyId,DocNo,Nature,OffsetDocument,IsTax,EntityId,SystemRefNo,DocCurrency,DocDate,PostingDate,RecOrder
																	)
									Select NEWID(),@MasterJournalId,@ClearingPaymentsCOAID,P.Remarks,Null As DocDebit,PD.PaymentAmount As DocCredit,Null As BaseDebit,Round(PD.PaymentAmount * @MainExchangeRate,2) As BaseCredit,0.00 As DocDebitTotal,0.00 As DocCreditTotal,
											0.00 As BaseDebitTotal,0.00 As BaseCreditTotal,P.Id As DocumnetId,PD.Id As DocumentDetailId,@GUIDZero,P.BaseCurrency,@MainExchangeRate As ExchangeRate,@DocType,@DocSubType,PD.ServiceCompanyId,P.DocNo,PD.Nature,Null As DocumentNo,0 As IsTax,
											P.EntityId,@MasterSystemRefNo,@BankChargesCurrency,P.DocDate,P.DocDate,@MasterRecOrder As RecOrder
									From Bean.Payment As P
									Inner Join bean.PaymentDetail As PD On PD.PaymentId=P.Id
									Where P.Id=@SourceId And PD.Id=@PaymentDtlId
								End
								Else 
								Begin
									Insert Into Bean.JournalDetail (Id,JournalId,COAId,AccountDescription,DocDebit,DocCredit,BaseDebit,BaseCredit,DocDebitTotal,DocCreditTotal,BaseDebitTotal,BaseCreditTotal,DocumentId,DocumentDetailId,ItemId,BaseCurrency,ExchangeRate,DocType,
																	DocSubType,ServiceCompanyId,DocNo,Nature,OffsetDocument,IsTax,EntityId,SystemRefNo,DocCurrency,DocDate,PostingDate,RecOrder
																	)
									Select NEWID(),@MasterJournalId,@COAID,P.Remarks,PD.PaymentAmount As DocDebit,Null As DocCredit,Round(PD.PaymentAmount * @ExchangeRate,2)-Isnull(@DocAmount,0) As BaseDebit,Null As BaseCredit,0.00 As DocDebitTotal,0.00 As DocCreditTotal,
											0.00 As BaseDebitTotal,0.00 As BaseCreditTotal,P.Id As DocumnetId,PD.Id As DocumentDetailId,@GUIDZero,P.BaseCurrency,@ExchangeRate As ExchangeRate,@DocType,@DocSubType,PD.ServiceCompanyId,P.DocNo,PD.Nature,
											Null As DocumentNo,0 As IsTax,P.EntityId,@MasterSystemRefNo,@BankChargesCurrency,P.DocDate,P.DocDate,@MasterRecOrder As RecOrder
									From Bean.Payment As P
									Inner Join bean.PaymentDetail As PD On PD.PaymentId=P.Id
									Where P.Id=@SourceId And PD.Id=@PaymentDtlId
									IF @MainExchangeRate-@ExchangeRate<>0
									Begin
										-- Exchangegain or Loss
										-- Opt : Replaced Set with Select
										Select @COAID= Id From Bean.ChartOfAccount Where CompanyId=@CompanyId And Name=@ExchangeGainOrLossRealised
										Set @MasterRecOrder=@MasterRecOrder+1
										Insert Into Bean.JournalDetail (Id,JournalId,COAId,AccountDescription,DocDebit,DocCredit,BaseDebit,BaseCredit,DocDebitTotal,DocCreditTotal,BaseDebitTotal,BaseCreditTotal,DocumentId,DocumentDetailId,ItemId,BaseCurrency,ExchangeRate,
																		DocType,DocSubType,ServiceCompanyId,DocNo,Nature,OffsetDocument,IsTax,EntityId,SystemRefNo,DocCurrency,DocDate,PostingDate,RecOrder
																		)
										Select NEWID(),@MasterJournalId,@COAID,P.Remarks,Null As DocDebit,Null As DocCredit,Case When (@MainExchangeRate-@ExchangeRate)>0 Then ABS(Round((@MainExchangeRate-@ExchangeRate)  * PD.PaymentAmount,2)) End As BaseDebit,
												Case When (@MainExchangeRate-@ExchangeRate)<0 Then ABS(Round((@MainExchangeRate-@ExchangeRate) * PD.PaymentAmount,2) ) End As BaseCredit,0.00 As DocDebitTotal,0.00 As DocCreditTotal,0.00 As BaseDebitTotal,
												0.00 As BaseCreditTotal,P.Id As DocumnetId,PD.Id As DocumentDetailId,@GUIDZero,P.BaseCurrency,P.ExchangeRate,@DocType,@DocSubType,PD.ServiceCompanyId,P.DocNo,PD.Nature,PD.DocumentNo,0 As IsTax,
												EntityId,@MasterSystemRefNo,@BankChargesCurrency,DocDate,DocDate,@MasterRecOrder As RecOrder
										From Bean.Payment As P
										Inner Join bean.PaymentDetail As PD On PD.PaymentId=P.Id
										Where P.Id=@SourceId And PD.Id=@PaymentDtlId
									End
								End
								Set @RdtlRecCount=@RdtlRecCount+1
							End
						End
						-- Diffrent Service Companies
						Else
						Begin
							-- Opt : Replaced Set with Select
							Select @IntroCompCOAID= COA.Id 
							From Bean.ChartOfAccount As COA 
							Inner Join Bean.AccountType As ACT On ACT.Id=COA.AccountTypeId
							Where ACT.CompanyId=@CompanyId And ACT.Name=@IntercompClearingCOAName And COA.SubsidaryCompanyId=@ServCompId
												
							If Exists (Select Id From Bean.PaymentDetail Where PaymentId=@SourceId And ServiceCompanyId=@ServCompId And DocumentType=@CreditMemoDocument And PaymentAmount<>0)
							Begin
								Set @MasterRecOrder=@MasterRecOrder+1
								-- Opt : Replaced Set with Select
								Select @PaymentAmtTotal= Sum(Isnull(PaymentAmount,0)) From Bean.PaymentDetail 
								Where ServiceCompanyId=@ServCompId And PaymentId=@SourceId 
								And DocumentType=@CreditMemoDocument

								Insert Into Bean.JournalDetail (Id,JournalId,COAId,AccountDescription,AllowDisAllow,DocCredit,BaseCredit,DocDebitTotal,DocCreditTotal,BaseDebitTotal,BaseCreditTotal,DocumentId,DocumentDetailId,ItemId,
												BaseCurrency,ExchangeRate,GSTExCurrency,GSTExchangeRate,DocType,DocSubType,ServiceCompanyId,DocNo,IsTax,EntityId,SystemRefNo,DocCurrency,DocDate,PostingDate,RecOrder)
								Select NEWID(),@MasterJournalId,@IntroCompCOAID,Remarks,IsDisAllow,Round((@PaymentAmtTotal * @MainExchangeRate)/@MainExchangeRate,2),Round(@PaymentAmtTotal * @MainExchangeRate,2),0.00 As DocDebitTotal,0.00 As DocCreditTotal,0.00 As BaseDebitTotal,0.00 As BaseCreditTotal,Id As DocumnetId,
										@GUIDZero,@GUIDZero,BaseCurrency,@MainExchangeRate As ExchangeRate,GSTExCurrency,GSTExchangeRate,@DocType,@DocSubType,@ServCompId As ServiceCompanyId,DocNo,0 As IsTax,EntityId,@MasterSystemRefNo As SystemRefNo,@BankChargesCurrency,DocDate,DocDate,@MasterRecOrder As RecOrder
								From Bean.Payment Where Id=@SourceId
							End
							If Exists (Select Id From Bean.PaymentDetail Where PaymentId=@SourceId And ServiceCompanyId=@ServCompId And DocumentType=@CreditNoteDocument And PaymentAmount<>0)
							Begin
								Set @MasterRecOrder=@MasterRecOrder+1
								-- Opt : Replaced Set with Select
								Select @PaymentAmtTotal= Sum(Isnull(PaymentAmount,0)) 
								From Bean.PaymentDetail Where ServiceCompanyId=@ServCompId 
								And PaymentId=@SourceId And DocumentType=@CreditNoteDocument

								Insert Into Bean.JournalDetail (Id,JournalId,COAId,AccountDescription,AllowDisAllow,DocDebit,BaseDebit,DocDebitTotal,DocCreditTotal,BaseDebitTotal,BaseCreditTotal,DocumentId,DocumentDetailId,ItemId,BaseCurrency,ExchangeRate,GSTExCurrency,GSTExchangeRate,DocType,DocSubType,ServiceCompanyId,DocNo,IsTax,
												EntityId,SystemRefNo,DocCurrency,DocDate,PostingDate,RecOrder)
								Select NEWID(),@MasterJournalId,@IntroCompCOAID,Remarks,IsDisAllow,Round((@PaymentAmtTotal * @MainExchangeRate)/@MainExchangeRate,2),Round(@PaymentAmtTotal * @MainExchangeRate,2),0.00 As DocDebitTotal,0.00 As DocCreditTotal,0.00 As BaseDebitTotal,0.00 As BaseCreditTotal,Id As DocumnetId,@GUIDZero,@GUIDZero,
										BaseCurrency,@MainExchangeRate As ExchangeRate,GSTExCurrency,GSTExchangeRate,@DocType,@DocSubType,@ServCompId As ServiceCompanyId,DocNo,0 As IsTax,EntityId,@MasterSystemRefNo As SystemRefNo,@BankChargesCurrency,DocDate,DocDate,@MasterRecOrder As RecOrder
								From Bean.Payment Where Id=@SourceId
							End

							Set @MasterRecOrder=@MasterRecOrder+1
							--Set @PaymentAmtTotal=(Select Sum(Isnull(PaymentAmount,0)) From Bean.PaymentDetail Where ServiceCompanyId=@ServCompId And PaymentId=@SourceId And DocumentType Not in (@CreditMemoDocument,@CreditNoteDocument) )
							-- Opt : Replaced Set with Select
							Select @ClearingPaymentInvOrDNAmount= SUM(Isnull(PaymentAmount,0)) From bean.PaymentDetail Where PaymentId=@SourceId And ServiceCompanyId=@ServCompId And DocumentType In (@InvoiceDocument,@DebitNoteDocument)
							Select @ClearingPaymentBillAmount= SUM(Isnull(PaymentAmount,0)) From bean.PaymentDetail Where PaymentId=@SourceId And ServiceCompanyId=@ServCompId And DocumentType Not In (@CreditMemoDocument,@CreditNoteDocument,@InvoiceDocument,@DebitNoteDocument)
							Set @PaymentAmtTotal=ABS(Isnull(@ClearingPaymentBillAmount,0)-Isnull(@ClearingPaymentInvOrDNAmount,0))
							
							If @PaymentAmtTotal Is Not null And @PaymentAmtTotal<>0
							Begin
								IF (Isnull(@ClearingPaymentBillAmount,0)-Isnull(@ClearingPaymentInvOrDNAmount,0)) <0
								Begin
									/* Creating Mater record In Master JournalDetail */
									Insert Into Bean.JournalDetail (Id,JournalId,COAId,AccountDescription,AllowDisAllow, DocCredit, BaseCredit, DocDebitTotal,DocCreditTotal,BaseDebitTotal,BaseCreditTotal,DocumentId,DocumentDetailId,ItemId,BaseCurrency,ExchangeRate,GSTExCurrency,GSTExchangeRate,
																	DocType,DocSubType,ServiceCompanyId,DocNo,IsTax,EntityId, SystemRefNo, DocCurrency,DocDate, PostingDate,RecOrder )
									Select NEWID(),@MasterJournalId,@IntroCompCOAID,Remarks,IsDisAllow,@PaymentAmtTotal,Round(@PaymentAmtTotal * @MainExchangeRate,2),0.00 As DocDebitTotal,0.00 As DocCreditTotal,0.00 As BaseDebitTotal,0.00 As BaseCreditTotal,Id As DocumnetId,@GUIDZero,@GUIDZero,
											BaseCurrency,@MainExchangeRate As ExchangeRate,GSTExCurrency,GSTExchangeRate,@DocType,@DocSubType,@ServCompId As ServiceCompanyId,DocNo,0 As IsTax,EntityId,@MasterSystemRefNo As SystemRefNo,@BankChargesCurrency,DocDate,DocDate,@MasterRecOrder As RecOrder
									From Bean.Payment Where Id=@SourceId
								End
								Else
								Begin
									/* Creating Mater record In Master JournalDetail */
									Insert Into Bean.JournalDetail (Id,JournalId,COAId,AccountDescription,AllowDisAllow, DocDebit, BaseDebit, DocDebitTotal,DocCreditTotal,BaseDebitTotal,BaseCreditTotal,DocumentId,DocumentDetailId,ItemId,BaseCurrency,ExchangeRate,GSTExCurrency,GSTExchangeRate,
																	DocType,DocSubType,ServiceCompanyId,DocNo,IsTax,EntityId, SystemRefNo, DocCurrency,DocDate, PostingDate,RecOrder )
									Select NEWID(),@MasterJournalId,@IntroCompCOAID,Remarks,IsDisAllow,@PaymentAmtTotal,Round(@PaymentAmtTotal * @MainExchangeRate,2),0.00 As DocDebitTotal,0.00 As DocCreditTotal,0.00 As BaseDebitTotal,0.00 As BaseCreditTotal,Id As DocumnetId,@GUIDZero,@GUIDZero,
											BaseCurrency,@MainExchangeRate As ExchangeRate,GSTExCurrency,GSTExchangeRate,@DocType,@DocSubType,@ServCompId As ServiceCompanyId,DocNo,0 As IsTax,EntityId,@MasterSystemRefNo As SystemRefNo,@BankChargesCurrency,DocDate,DocDate,@MasterRecOrder As RecOrder
									From Bean.Payment Where Id=@SourceId
								End
								-- New Journals
								Set @SysRefNumOrder=@SysRefNumOrder+1
								Set @SystemRefNo=Concat(@DocNo,'-JV',@SysRefNumOrder)
								Set @JournalId=NEWID()
								Insert Into Bean.Journal (Id,CompanyId,DocDate,DocType,DocSubType,DocNo,ServiceCompanyId,SystemReferenceNo,IsNoSupportingDocs,NoSupportingDocument,DocCurrency,ExchangeRate,ExCurrency,ExDurationFrom,GSTExchangeRate,GSTExCurrency,GSTTotalAmount,DocumentState,IsNoSupportingDocument,IsGstSettings,IsMultiCurrency,IsAllowableNonAllowable,IsGSTCurrencyRateChanged,
															Remarks,UserCreated,CreatedDate,Status,DocumentDescription,CreationType,GrandDocDebitTotal,GrandDocCreditTotal,GrandBaseDebitTotal,GrandBaseCreditTotal,EntityId,EntityType,PostingDate,COAId,ModeOfReceipt,BankReceiptAmmount,ExcessPaidByClientAmmount,BalancingItemReciveCRAmount,  BalancingItemPayDRAmount,ReceiptApplicationAmmount,
															DocumentId,BankClearingDate,IsBalancing,ISAllowDisAllow, IsShow, ActualSysRefNo,IsSegmentReporting,TransferRefNo
														 )
								Select @JournalId,@CompanyId,DocDate,@DocType,@DocSubType,DocNo,@ServCompId,@SystemRefNo As SystemRefNo,IsNoSupportingDocument,NoSupportingDocs,DocCurrency,ExchangeRate,ExCurrency,ExDurationFrom,GSTExchangeRate,GSTExCurrency,Isnull(GSTTotalAmount,0),DocumentState,NoSupportingDocs,IsGstSettings,IsMultiCurrency,IsAllowableDisallowable,IsGSTCurrencyRateChanged,Remarks,@UserCreated,@CreatedDate,
										Status,Remarks As DocDescription,@UserCreated,GrandTotal,0.00 As GrandDocCreditTotal,Round(GrandTotal * ExchangeRate,2) As GrandBaseDebitTotal,0.00 As GrandBaseCreditTotal,EntityId,EntityType,DocDate As PostingDate,COAId,ModeOfReceipt,0.00 As BankReceiptAmmount,0.00 As ExcessPaidByClientAmmount,0.00 As BalancingItemReciveCRAmount,0.00 As BalancingItemPayDRAmount,
										0.00 As ReceiptApplicationAmmount,Id As DocumentId,BankClearingDate,0 As IsBalancing,IsDisAllow,1 As IsShow,DocNo As ActualSysRefNo,0 As IsSegmentReporting,PaymentRefNo
								From Bean.Payment Where CompanyId=@CompanyId And Id=@SourceId
								/* Creating Mater record In JournalDetail */
								IF (Isnull(@ClearingPaymentBillAmount,0)-Isnull(@ClearingPaymentInvOrDNAmount,0)) <0
								Begin
									Insert Into Bean.JournalDetail (Id,JournalId,COAId,AccountDescription,AllowDisAllow,DocDebit,BaseDebit,DocDebitTotal,DocCreditTotal,BaseDebitTotal,BaseCreditTotal,DocumentId,DocumentDetailId,ItemId,BaseCurrency,ExchangeRate,GSTExCurrency,GSTExchangeRate,
																	DocType,DocSubType,ServiceCompanyId,DocNo, IsTax,EntityId,SystemRefNo,DocCurrency,DocDate,PostingDate,RecOrder)
									Select NEWID(),@JournalId,@MainInterCoServCompCOAID,Remarks,IsDisAllow,@PaymentAmtTotal,Round(@PaymentAmtTotal * @MainExchangeRate,2),0.00 As DocDebitTotal,0.00 As DocCreditTotal,0.00 As BaseDebitTotal,0.00 As BaseCreditTotal,Id As DocumnetId,@GUIDZero,@GUIDZero,
											BaseCurrency,@MainExchangeRate As ExchangeRate,GSTExCurrency,GSTExchangeRate,@DocType,@DocSubType,@ServCompId As ServiceCompanyId,DocNo,0 As IsTax,EntityId,@SystemRefNo As SystemRefNo,@BankChargesCurrency,DocDate,DocDate,@RecOrder As RecOrder
									From Bean.Payment Where Id=@SourceId
								End 
								Else
								Begin
									Insert Into Bean.JournalDetail (Id,JournalId,COAId,AccountDescription,AllowDisAllow,DocCredit,BaseCredit,DocDebitTotal,DocCreditTotal,BaseDebitTotal,BaseCreditTotal,DocumentId,DocumentDetailId,ItemId,BaseCurrency,ExchangeRate,GSTExCurrency,GSTExchangeRate,
																	DocType,DocSubType,ServiceCompanyId,DocNo, IsTax,EntityId,SystemRefNo,DocCurrency,DocDate,PostingDate,RecOrder)
									Select NEWID(),@JournalId,@MainInterCoServCompCOAID,Remarks,IsDisAllow,@PaymentAmtTotal,Round(@PaymentAmtTotal * @MainExchangeRate,2),0.00 As DocDebitTotal,0.00 As DocCreditTotal,0.00 As BaseDebitTotal,0.00 As BaseCreditTotal,Id As DocumnetId,@GUIDZero,@GUIDZero,
											BaseCurrency,@MainExchangeRate As ExchangeRate,GSTExCurrency,GSTExchangeRate,@DocType,@DocSubType,@ServCompId As ServiceCompanyId,DocNo,0 As IsTax,EntityId,@SystemRefNo As SystemRefNo,@BankChargesCurrency,DocDate,DocDate,@RecOrder As RecOrder
									From Bean.Payment Where Id=@SourceId
								End
								-- Payment detail records
								Delete From @PaymentDtl_New
								Insert Into @PaymentDtl_New
								Select ROW_NUMBER() Over (Order By Id),Id From Bean.PaymentDetail Where PaymentId=@SourceId And ServiceCompanyId=@ServCompId And DocumentType Not in (@CreditMemoDocument,@CreditNoteDocument)
								-- Opt : Replaced Set with Select
								Select @DtlCount= Count(*) From @PaymentDtl_New
								Set @RdtlRecCount=1
								While @DtlCount>=@RdtlRecCount
								Begin
									-- Opt : Replaced Set with Select
									Select @PaymentDtlId= PaymentDtlId From @PaymentDtl_New Where S_No=@RdtlRecCount
									Select @DocumentId= DocumentId From Bean.PaymentDetail Where Id=@PaymentDtlId
									Set @IsRoundingAmount=0
									IF Exists (Select Id From Bean.PaymentDetail Where Id=@PaymentDtlId And Nature=@NatureTrade And DocumentType =@InvoiceDocument)
									Begin
										-- Opt : Replaced Set with Select
										Select @COAID= Id From Bean.ChartOfAccount Where CompanyId=@CompanyId And Name=@COATradeReceivables
										Select @ExchangeRate= ExchangeRate From Bean.Invoice Where Id=@DocumentId
										IF Exists (Select Id From Bean.Invoice Where Id=@DocumentId And DocumentState In (@FullyApplied,@Fullypaid))
										Begin
											Set @IsRoundingAmount=1
										End
									End
									Else IF Exists (Select Id From Bean.PaymentDetail Where Id=@PaymentDtlId And Nature=@NatureOthers And DocumentType =@InvoiceDocument)
									Begin
										-- Opt : Replaced Set with Select
										Select @COAID= Id From Bean.ChartOfAccount Where CompanyId=@CompanyId And Name=@COAotherReceivables
										Select @ExchangeRate= ExchangeRate From Bean.Invoice Where Id=@DocumentId
										IF Exists (Select Id From Bean.Invoice Where Id=@DocumentId And DocumentState In (@FullyApplied,@Fullypaid))
										Begin
											Set @IsRoundingAmount=1
										End
									End
									Else IF Exists (Select Id From Bean.PaymentDetail Where Id=@PaymentDtlId And Nature=@NatureTrade And DocumentType =@DebitNoteDocument)
									Begin
										-- Opt : Replaced Set with Select
										Select @COAID= Id From Bean.ChartOfAccount Where CompanyId=@CompanyId And Name=@COATradeReceivables
										Select @ExchangeRate= ExchangeRate From Bean.DebitNote Where Id=@DocumentId
										IF Exists (Select Id From Bean.DebitNote Where Id=@DocumentId And DocumentState In (@FullyApplied,@Fullypaid))
										Begin
											Set @IsRoundingAmount=1
										End
									End
									Else IF Exists (Select Id From Bean.PaymentDetail Where Id=@PaymentDtlId And Nature=@NatureOthers And DocumentType =@DebitNoteDocument)
									Begin
										-- Opt : Replaced Set with Select
										Select @COAID= Id From Bean.ChartOfAccount Where CompanyId=@CompanyId And Name=@COAotherReceivables
										Select @ExchangeRate= ExchangeRate From Bean.DebitNote Where Id=@DocumentId
										IF Exists (Select Id From Bean.DebitNote Where Id=@DocumentId And DocumentState In (@FullyApplied,@Fullypaid))
										Begin
											Set @IsRoundingAmount=1
										End
									End
									Else IF Exists (Select Id From Bean.PaymentDetail Where Id=@PaymentDtlId And Nature=@NatureTrade And DocumentType Not In (@InvoiceDocument,@DebitNoteDocument,@CreditNoteDocument,@CreditMemoDocument))
									Begin
										-- Opt : Replaced Set with Select
										Select @COAID= Id From Bean.ChartOfAccount Where CompanyId=@CompanyId And Name=@COATradePayables
										Select @ExchangeRate= ExchangeRate From Bean.Bill Where Id=@DocumentId
										IF Exists (Select Id From Bean.Bill Where Id=@DocumentId And DocumentState In (@FullyApplied,@Fullypaid))
										Begin
											Set @IsRoundingAmount=1
										End
									End
									Else IF Exists (Select Id From Bean.PaymentDetail Where Id=@PaymentDtlId And Nature=@NatureOthers And DocumentType Not In (@InvoiceDocument,@DebitNoteDocument,@CreditNoteDocument,@CreditMemoDocument))
									Begin
										-- Opt : Replaced Set with Select
										Select @COAID= Id From Bean.ChartOfAccount Where CompanyId=@CompanyId And Name=@COAOtherPayables
										Select @ExchangeRate= ExchangeRate From Bean.Bill Where Id=@DocumentId
										IF Exists (Select Id From Bean.Bill Where Id=@DocumentId And DocumentState In (@FullyApplied,@Fullypaid))
										Begin
											Set @IsRoundingAmount=1
										End
									End
									IF @IsRoundingAmount=1 And Exists (Select Amount From @RoundingAmountDetails Where DocumentId=@DocumentId And Amount Is Not Null And Amount<>'') --And @RoundingAmount Is Not Null And @RoundingAmount <>''
									Begin
										-- Opt : Replaced Set with Select
										Select @DocAmount= Amount From @RoundingAmountDetails Where DocumentId=@DocumentId
									End
									Else
									Begin
										Set @DocAmount=0
									End
									-- Opt : Replaced Set with Select
									Select @OffSetDocumentType= DocumentType From Bean.PaymentDetail Where Id=@PaymentDtlId
									Set @RecOrder=@RecOrder+1
									IF @OffSetDocumentType=@InvoiceDocument Or @OffSetDocumentType=@DebitNoteDocument
									Begin
										Insert Into Bean.JournalDetail (Id,JournalId,COAId,AccountDescription, DocDebit,DocCredit,BaseDebit,BaseCredit,DocDebitTotal,DocCreditTotal,BaseDebitTotal,BaseCreditTotal,DocumentId,DocumentDetailId,ItemId,BaseCurrency,ExchangeRate,
																		DocType,DocSubType,ServiceCompanyId,DocNo,Nature,OffsetDocument,IsTax,EntityId, SystemRefNo, DocCurrency,DocDate, PostingDate,RecOrder 
																		)
										Select NEWID(),@JournalId,@COAID,P.Remarks,Null As DocDebit,PD.PaymentAmount As DocCredit,Null As BaseDebit,Round(PD.PaymentAmount * @ExchangeRate,2)-Isnull(@DocAmount,0) As BaseCredit,0.00 As DocDebitTotal,0.00 As DocCreditTotal,0.00 As BaseDebitTotal,
												0.00 As BaseCreditTotal,P.Id As DocumnetId,PD.Id As DocumentDetailId,@GUIDZero,P.BaseCurrency,@ExchangeRate As ExchangeRate,@DocType,@DocSubType,PD.ServiceCompanyId,P.DocNo,PD.Nature,Null As DocumentNo,0 As IsTax,
												P.EntityId,@SystemRefNo,@DocCurrency,P.DocDate,P.DocDate,@RecOrder As RecOrder
										From Bean.Payment As P
										Inner Join bean.PaymentDetail As PD On PD.PaymentId=P.Id
										Where P.Id=@SourceId And PD.Id=@PaymentDtlId
										IF @MainExchangeRate-@ExchangeRate<>0
										Begin
											-- Exchangegain or Loss
											-- Opt : Replaced Set with Select
											Select @COAID= Id From Bean.ChartOfAccount Where CompanyId=@CompanyId And Name=@ExchangeGainOrLossRealised
											Set @RecOrder=@RecOrder+1
											Insert Into Bean.JournalDetail (Id,JournalId,COAId,AccountDescription, DocDebit,DocCredit,BaseDebit,BaseCredit,DocDebitTotal,DocCreditTotal,BaseDebitTotal,BaseCreditTotal,DocumentId,DocumentDetailId,ItemId,BaseCurrency,ExchangeRate,
																			DocType,DocSubType,ServiceCompanyId,DocNo,Nature,OffsetDocument,IsTax,EntityId, SystemRefNo, DocCurrency,DocDate, PostingDate,RecOrder 
																			)
											Select NEWID(),@JournalId,@COAID,P.Remarks,Null As DocDebit,Null As DocCredit,Case When (@MainExchangeRate-@ExchangeRate)<0 Then ABS(Round((@MainExchangeRate-@ExchangeRate)  * PD.PaymentAmount,2)) End As BaseDebit,
													Case When (@MainExchangeRate-@ExchangeRate)>0 Then ABS(Round((@MainExchangeRate-@ExchangeRate) * PD.PaymentAmount,2) ) End As BaseCredit,0.00 As DocDebitTotal,0.00 As DocCreditTotal,0.00 As BaseDebitTotal,
													0.00 As BaseCreditTotal,P.Id As DocumnetId,PD.Id As DocumentDetailId,@GUIDZero,P.BaseCurrency,P.ExchangeRate,@DocType,@DocSubType,PD.ServiceCompanyId,P.DocNo,PD.Nature,PD.DocumentNo,0 As IsTax,
													EntityId,@SystemRefNo,@DocCurrency,DocDate,DocDate,@RecOrder As RecOrder
											From Bean.Payment As P
											Inner Join bean.PaymentDetail As PD On PD.PaymentId=P.Id
											Where P.Id=@SourceId And PD.Id=@PaymentDtlId
										End
									End
									Else 
									Begin
										Insert Into Bean.JournalDetail (Id,JournalId,COAId,AccountDescription, DocDebit,DocCredit,BaseDebit,BaseCredit,DocDebitTotal,DocCreditTotal,BaseDebitTotal,BaseCreditTotal,DocumentId,DocumentDetailId,ItemId,
																		BaseCurrency,ExchangeRate, DocType,DocSubType,ServiceCompanyId,DocNo,Nature,OffsetDocument,IsTax,EntityId, SystemRefNo, DocCurrency,DocDate, PostingDate,RecOrder 
																		)
										Select NEWID(),@JournalId,@COAID,P.Remarks,PD.PaymentAmount As DocDebit,Null As DocCredit,Round(PD.PaymentAmount * @ExchangeRate,2)-Isnull(@DocAmount,0) As BaseDebit,Null As BaseCredit,0.00 As DocDebitTotal,
												0.00 As DocCreditTotal,0.00 As BaseDebitTotal,0.00 As BaseCreditTotal,P.Id As DocumnetId,PD.Id As DocumentDetailId,@GUIDZero,P.BaseCurrency,@ExchangeRate As ExchangeRate,@DocType,@DocSubType,
												PD.ServiceCompanyId,P.DocNo,PD.Nature,Null As DocumentNo,0 As IsTax,P.EntityId,@SystemRefNo,@DocCurrency,P.DocDate,P.DocDate,@RecOrder As RecOrder
										From Bean.Payment As P
										Inner Join bean.PaymentDetail As PD On PD.PaymentId=P.Id
										Where P.Id=@SourceId And PD.Id=@PaymentDtlId
										IF @MainExchangeRate-@ExchangeRate<>0
										Begin
											-- Exchangegain or Loss
											-- Opt : Replaced Set with Select
											Select @COAID= Id From Bean.ChartOfAccount Where CompanyId=@CompanyId And Name=@ExchangeGainOrLossRealised
											Set @RecOrder=@RecOrder+1
											Insert Into Bean.JournalDetail (Id,JournalId,COAId,AccountDescription, DocDebit,DocCredit,BaseDebit,BaseCredit,DocDebitTotal,DocCreditTotal,BaseDebitTotal,BaseCreditTotal,DocumentId,DocumentDetailId,ItemId,BaseCurrency,ExchangeRate,
																			DocType,DocSubType,ServiceCompanyId,DocNo,Nature,OffsetDocument,IsTax,EntityId, SystemRefNo, DocCurrency,DocDate, PostingDate,RecOrder 
																			)
											Select NEWID(),@JournalId,@COAID,P.Remarks,Null As DocDebit,Null As DocCredit,Case When (@MainExchangeRate-@ExchangeRate)>0 Then ABS(Round((@MainExchangeRate-@ExchangeRate)  * PD.PaymentAmount,2)) End As BaseDebit,
													Case When (@MainExchangeRate-@ExchangeRate)<0 Then ABS(Round((@MainExchangeRate-@ExchangeRate) * PD.PaymentAmount,2) ) End As BaseCredit,0.00 As DocDebitTotal,0.00 As DocCreditTotal,0.00 As BaseDebitTotal,
													0.00 As BaseCreditTotal,P.Id As DocumnetId,PD.Id As DocumentDetailId,@GUIDZero,P.BaseCurrency,P.ExchangeRate,@DocType,@DocSubType,PD.ServiceCompanyId,P.DocNo,PD.Nature,PD.DocumentNo,0 As IsTax,
													EntityId,@SystemRefNo,@DocCurrency,DocDate,DocDate,@RecOrder As RecOrder
											From Bean.Payment As P
											Inner Join bean.PaymentDetail As PD On PD.PaymentId=P.Id
											Where P.Id=@SourceId And PD.Id=@PaymentDtlId
										End
									End
									Set @RdtlRecCount=@RdtlRecCount+1
								End
							End
						End
						Set @RecCount=@RecCount+1
					End
				End
				Else IF @DocCurrency<>@BankChargesCurrency And @BaseCurrency=@DocCurrency
				Begin
					/* Creating Mater record In JournalDetail */
					Insert Into Bean.JournalDetail (Id,JournalId,COAId,AccountDescription,AllowDisAllow, DocCredit, BaseCredit, DocDebitTotal,DocCreditTotal,BaseDebitTotal,BaseCreditTotal,DocumentId,DocumentDetailId,ItemId,BaseCurrency,
													ExchangeRate,GSTExCurrency,GSTExchangeRate,DocType,DocSubType,ServiceCompanyId,DocNo, IsTax,EntityId, SystemRefNo, DocCurrency,DocDate, PostingDate,RecOrder )
					Select NEWID(),@MasterJournalId,COAId,Remarks,IsDisAllow,GrandTotal,Round(GrandTotal * @SysCalExchangerate,2),0.00 As DocDebitTotal,0.00 As DocCreditTotal,0.00 As BaseDebitTotal,0.00 As BaseCreditTotal,Id As DocumnetId,@GUIDZero,@GUIDZero,
							BaseCurrency,@SysCalExchangerate As ExchangeRate,GSTExCurrency,GSTExchangeRate,@DocType,@DocSubType,ServiceCompanyId,DocNo,0 As IsTax,EntityId,@MasterSystemRefNo As SystemRefNo,@BankChargesCurrency,DocDate,DocDate,@MasterRecOrder As RecOrder
					From Bean.Payment Where Id=@SourceId
					-- Service company details
					Insert Into @ServCompaIdTbl
					Select Distinct ServiceCompanyId From Bean.PaymentDetail Where PaymentId=@SourceId And PaymentAmount<>0
					-- Opt : Replaced Set with Select
					Select @ServCompaIdTblCnt= Count(*) From @ServCompaIdTbl
					Set @RecCount=1
					While @ServCompaIdTblCnt>=@RecCount
					Begin
						-- Opt : Replaced Set with Select
						Select @ServCompId= SerCompId From @ServCompaIdTbl Where S_No=@RecCount
						IF @ServCompId=@MasterServComp
						Begin
							-- Opt : Replaced Set with Select
							Select @ClearingPaymentInvOrDNAmount= Sum(Isnull(PaymentAmount,0)) From Bean.PaymentDetail Where PaymentId=@SourceId And ServiceCompanyId=@ServCompId And DocumentType In (@InvoiceDocument,@DebitNoteDocument)
							Select @ClearingPaymentBillAmount= Sum(Isnull(PaymentAmount,0)) From Bean.PaymentDetail Where PaymentId=@SourceId And ServiceCompanyId=@ServCompId And DocumentType Not In (@InvoiceDocument,@DebitNoteDocument,@CreditMemoDocument,@CreditNoteDocument)
							Set @PaymentAmtTotal=(ISnull(@ClearingPaymentBillAmount,0)-Isnull(@ClearingPaymentInvOrDNAmount,0))
							IF @PaymentAmtTotal IS Not Null And @PaymentAmtTotal<0
							Begin
								Insert Into Bean.JournalDetail (Id,JournalId,COAId,AccountDescription, DocDebit,DocCredit,BaseDebit,BaseCredit,DocDebitTotal,DocCreditTotal,BaseDebitTotal,BaseCreditTotal,DocumentId,DocumentDetailId,ItemId,BaseCurrency,ExchangeRate,
																DocType,DocSubType,ServiceCompanyId,DocNo,Nature,OffsetDocument,IsTax,EntityId, SystemRefNo, DocCurrency,DocDate, PostingDate,RecOrder 
																)
								Select NEWID(),@MasterJournalId,@ClearingPaymentsCOAID,P.Remarks,Null As DocDebit,Round(ABS(@PaymentAmtTotal)/@SysCalExchangerate,2) As DocCredit,Null As BaseDebit,Round(ABS(@PaymentAmtTotal) * @ExchangeRate,2) As BaseCredit,0.00 As DocDebitTotal,0.00 As DocCreditTotal,
										0.00 As BaseDebitTotal,0.00 As BaseCreditTotal,P.Id As DocumnetId,PD.Id As DocumentDetailId,@GUIDZero,P.BaseCurrency,@ExchangeRate As ExchangeRate,@DocType,@DocSubType,PD.ServiceCompanyId,P.DocNo,PD.Nature,
										Null As DocumentNo,0 As IsTax,P.EntityId,@MasterSystemRefNo,@BankChargesCurrency,P.DocDate,P.DocDate,@MasterRecOrder As RecOrder
								From Bean.Payment As P
								Inner Join bean.PaymentDetail As PD On PD.PaymentId=P.Id
								Where P.Id=@SourceId And PD.Id=@PaymentDtlId

								Set @SysRefNumOrder=@SysRefNumOrder+1
								Set @SystemRefNo=Concat(@DocNo,'-JV',@SysRefNumOrder)
								Set @JournalId=NEWID()
								Set @RecOrder=1
								Insert Into Bean.Journal (Id,CompanyId,DocDate,DocType,DocSubType,DocNo,ServiceCompanyId,SystemReferenceNo,IsNoSupportingDocs,NoSupportingDocument,DocCurrency,ExchangeRate,ExCurrency,ExDurationFrom,GSTExchangeRate,GSTExCurrency,GSTTotalAmount,DocumentState,IsNoSupportingDocument,IsGstSettings,IsMultiCurrency,IsAllowableNonAllowable,IsGSTCurrencyRateChanged,
															Remarks,UserCreated,CreatedDate,Status,DocumentDescription,CreationType,GrandDocDebitTotal,GrandDocCreditTotal,GrandBaseDebitTotal,GrandBaseCreditTotal,EntityId,EntityType,PostingDate,COAId,ModeOfReceipt,BankReceiptAmmount,ExcessPaidByClientAmmount,BalancingItemReciveCRAmount,  BalancingItemPayDRAmount,ReceiptApplicationAmmount,
															DocumentId, BankClearingDate ,IsBalancing,ISAllowDisAllow, IsShow, ActualSysRefNo,IsSegmentReporting,TransferRefNo
														 )
								Select @JournalId,@CompanyId,DocDate,@DocType,@DocSubType,DocNo,@ServCompId,@SystemRefNo As SystemRefNo,IsNoSupportingDocument,NoSupportingDocs,DocCurrency,ExchangeRate,ExCurrency,ExDurationFrom,GSTExchangeRate,GSTExCurrency,Isnull(GSTTotalAmount,0),DocumentState,NoSupportingDocs,IsGstSettings,IsMultiCurrency,IsAllowableDisallowable,IsGSTCurrencyRateChanged,Remarks,@UserCreated,@CreatedDate,Status,Remarks As DocDescription,@UserCreated,GrandTotal,0.00 As GrandDocCreditTotal,Round(GrandTotal * ExchangeRate,2) As GrandBaseDebitTotal,
										0.00 As GrandBaseCreditTotal,EntityId,EntityType,DocDate As PostingDate,COAId,ModeOfReceipt,0.00 As BankReceiptAmmount,0.00 As ExcessPaidByClientAmmount,0.00 As BalancingItemReciveCRAmount,0.00 As BalancingItemPayDRAmount,0.00 As ReceiptApplicationAmmount,Id As DocumentId,BankClearingDate,0 As IsBalancing,IsDisAllow,1 As IsShow,DocNo As ActualSysRefNo,0 As IsSegmentReporting,PaymentRefNo
								From Bean.Payment Where CompanyId=@CompanyId And Id=@SourceId
								/* Creating Mater record In JournalDetail */
								Insert Into Bean.JournalDetail (Id,JournalId,COAId,AccountDescription, DocDebit,DocCredit,BaseDebit,BaseCredit,DocDebitTotal,DocCreditTotal,BaseDebitTotal,BaseCreditTotal,DocumentId,DocumentDetailId,ItemId,BaseCurrency,ExchangeRate, DocType,DocSubType,ServiceCompanyId,DocNo,Nature,OffsetDocument,IsTax,
																EntityId, SystemRefNo, DocCurrency,DocDate, PostingDate,RecOrder 
																)
								Select NEWID(),@JournalId,@ClearingPaymentsCOAID,P.Remarks,ABS(@PaymentAmtTotal) As DocDebit,Null As DocCredit,Round(ABS(@PaymentAmtTotal) * @DefaultExchangeRate,2) As BaseDebit,Null As BaseCredit,
										0.00 As DocDebitTotal,0.00 As DocCreditTotal,0.00 As BaseDebitTotal,0.00 As BaseCreditTotal,P.Id As DocumnetId,PD.Id As DocumentDetailId,@GUIDZero,P.BaseCurrency,@ExchangeRate As ExchangeRate,
										@DocType,@DocSubType,PD.ServiceCompanyId,P.DocNo,PD.Nature,Null As DocumentNo,0 As IsTax,P.EntityId,@SystemRefNo,@DocCurrency,P.DocDate,P.DocDate,@RecOrder As RecOrder
								From Bean.Payment As P
								Inner Join bean.PaymentDetail As PD On PD.PaymentId=P.Id
								Where P.Id=@SourceId And PD.Id=@PaymentDtlId
							End
							Else IF @PaymentAmtTotal IS Not Null And @PaymentAmtTotal>0
							Begin
								Insert Into Bean.JournalDetail (Id,JournalId,COAId,AccountDescription, DocDebit,DocCredit,BaseDebit,BaseCredit,DocDebitTotal,DocCreditTotal,BaseDebitTotal,BaseCreditTotal,DocumentId,DocumentDetailId,ItemId,BaseCurrency,ExchangeRate, DocType,DocSubType,ServiceCompanyId,DocNo,Nature,OffsetDocument,IsTax,
															EntityId, SystemRefNo, DocCurrency,DocDate, PostingDate,RecOrder 
															)
								Select NEWID(),@MasterJournalId,@ClearingPaymentsCOAID,P.Remarks,Round(ABS(@PaymentAmtTotal)/@SysCalExchangerate,2) As DocDebit,Null As DocCredit,Round(ABS(@PaymentAmtTotal) * @DefaultExchangeRate,2)-Isnull(@DocAmount,0) As BaseDebit,Null As BaseCredit,
										0.00 As DocDebitTotal,0.00 As DocCreditTotal,0.00 As BaseDebitTotal,0.00 As BaseCreditTotal,P.Id As DocumnetId,P.Id As DocumentDetailId,@GUIDZero,P.BaseCurrency,@ExchangeRate As ExchangeRate,
										@DocType,@DocSubType,P.ServiceCompanyId,P.DocNo,Null As Nature,Null As DocumentNo,0 As IsTax,P.EntityId,@MasterSystemRefNo,@BankChargesCurrency,P.DocDate,P.DocDate,@MasterRecOrder As RecOrder
								From Bean.Payment As P
								--Inner Join bean.PaymentDetail As PD On PD.PaymentId=P.Id
								Where P.Id=@SourceId --And PD.Id=@PaymentDtlId
								Set @SysRefNumOrder=@SysRefNumOrder+1
								Set @SystemRefNo=Concat(@DocNo,'-JV',@SysRefNumOrder)
								Set @JournalId=NEWID()
								Set @RecOrder=1
								Insert Into Bean.Journal (Id,CompanyId,DocDate,DocType,DocSubType,DocNo,ServiceCompanyId,SystemReferenceNo,IsNoSupportingDocs,NoSupportingDocument,DocCurrency,ExchangeRate,ExCurrency,ExDurationFrom,GSTExchangeRate,GSTExCurrency,GSTTotalAmount,DocumentState,IsNoSupportingDocument,IsGstSettings,IsMultiCurrency,IsAllowableNonAllowable,IsGSTCurrencyRateChanged,
															Remarks,UserCreated,CreatedDate,Status,DocumentDescription,CreationType,GrandDocDebitTotal,GrandDocCreditTotal,GrandBaseDebitTotal,GrandBaseCreditTotal,EntityId,EntityType,PostingDate,COAId,ModeOfReceipt,BankReceiptAmmount,ExcessPaidByClientAmmount,BalancingItemReciveCRAmount,  BalancingItemPayDRAmount,ReceiptApplicationAmmount,
															DocumentId, BankClearingDate ,IsBalancing,ISAllowDisAllow, IsShow, ActualSysRefNo,IsSegmentReporting,TransferRefNo
														 )
								Select @JournalId,@CompanyId,DocDate,@DocType,@DocSubType,DocNo,@ServCompId,@SystemRefNo As SystemRefNo,IsNoSupportingDocument,NoSupportingDocs,DocCurrency,ExchangeRate,ExCurrency,ExDurationFrom,GSTExchangeRate,GSTExCurrency,Isnull(GSTTotalAmount,0),DocumentState,NoSupportingDocs,IsGstSettings,IsMultiCurrency,IsAllowableDisallowable,IsGSTCurrencyRateChanged,Remarks,@UserCreated,@CreatedDate,Status,Remarks As DocDescription,@UserCreated,GrandTotal,0.00 As GrandDocCreditTotal,Round(GrandTotal * ExchangeRate,2) As GrandBaseDebitTotal,
										0.00 As GrandBaseCreditTotal,EntityId,EntityType,DocDate As PostingDate,COAId,ModeOfReceipt,0.00 As BankReceiptAmmount,0.00 As ExcessPaidByClientAmmount,0.00 As BalancingItemReciveCRAmount,0.00 As BalancingItemPayDRAmount,0.00 As ReceiptApplicationAmmount,Id As DocumentId,BankClearingDate,0 As IsBalancing,IsDisAllow,1 As IsShow,DocNo As ActualSysRefNo,0 As IsSegmentReporting, PaymentRefNo
								From Bean.Payment Where CompanyId=@CompanyId And Id=@SourceId
								/* Creating Mater record In JournalDetail */
								Insert Into Bean.JournalDetail (Id,JournalId,COAId,AccountDescription, DocDebit,DocCredit,BaseDebit,BaseCredit,DocDebitTotal,DocCreditTotal,BaseDebitTotal,BaseCreditTotal,DocumentId,DocumentDetailId,ItemId,BaseCurrency,ExchangeRate, DocType,DocSubType,ServiceCompanyId,DocNo,Nature,OffsetDocument,IsTax,
																EntityId, SystemRefNo, DocCurrency,DocDate, PostingDate,RecOrder 
																)
								Select NEWID(),@JournalId,@ClearingPaymentsCOAID,P.Remarks,Null As DocDebit,ABS(@PaymentAmtTotal) As DocCredit,Null As BaseDebit,Round(ABS(@PaymentAmtTotal) * @DefaultExchangeRate,2) As BaseCredit,
										0.00 As DocDebitTotal,0.00 As DocCreditTotal,0.00 As BaseDebitTotal,0.00 As BaseCreditTotal,P.Id As DocumnetId,P.Id As DocumentDetailId,@GUIDZero,P.BaseCurrency,@ExchangeRate As ExchangeRate,
										@DocType,@DocSubType,P.ServiceCompanyId,P.DocNo,Null As Nature,Null As DocumentNo,0 As IsTax,P.EntityId,@SystemRefNo,@DocCurrency,P.DocDate,P.DocDate,@RecOrder As RecOrder
								From Bean.Payment As P
								--Inner Join bean.PaymentDetail As PD On PD.PaymentId=P.Id
								Where P.Id=@SourceId --And PD.Id=@PaymentDtlId
							End
							-- Detail Records
							Delete From @PaymentDtl_New
							Insert Into @PaymentDtl_New
							Select ROW_NUMBER() Over (Order By Id),Id From Bean.PaymentDetail Where PaymentId=@SourceId And ServiceCompanyId=@ServCompId And PaymentAmount<>0
							-- Opt : Replaced Set with Select
							Select @DtlCount= Count(*) From @PaymentDtl_New
							Set @RdtlRecCount=1
							While @DtlCount>=@RdtlRecCount
							Begin
								-- Opt : Replaced Set with Select
								Select @PaymentDtlId= PaymentDtlId From @PaymentDtl_New Where S_No=@RdtlRecCount
								Select @DocumentId= DocumentId From Bean.PaymentDetail Where Id=@PaymentDtlId
								Set @IsRoundingAmount=0
								IF Exists (Select Id From Bean.PaymentDetail Where Id=@PaymentDtlId And Nature=@NatureTrade And DocumentType =@InvoiceDocument)
								Begin
									-- Opt : Replaced Set with Select
									Select @COAID= Id From Bean.ChartOfAccount Where CompanyId=@CompanyId And Name=@COATradeReceivables
									Select @ExchangeRate= ExchangeRate From Bean.Invoice Where Id=@DocumentId
									IF Exists (Select Id From Bean.Invoice Where Id=@DocumentId And DocumentState In (@FullyApplied,@Fullypaid))
									Begin
										Set @IsRoundingAmount=1
									End
								End
								Else IF Exists (Select Id From Bean.PaymentDetail Where Id=@PaymentDtlId And Nature=@NatureOthers And DocumentType =@InvoiceDocument)
								Begin
									-- Opt : Replaced Set with Select
									Select @COAID= Id From Bean.ChartOfAccount Where CompanyId=@CompanyId And Name=@COAotherReceivables
									Select @ExchangeRate= ExchangeRate From Bean.Invoice Where Id=@DocumentId
									IF Exists (Select Id From Bean.Invoice Where Id=@DocumentId And DocumentState In (@FullyApplied,@Fullypaid))
									Begin
										Set @IsRoundingAmount=1
									End
								End
								Else IF Exists (Select Id From Bean.PaymentDetail Where Id=@PaymentDtlId And Nature=@NatureTrade And DocumentType =@DebitNoteDocument)
								Begin
									-- Opt : Replaced Set with Select
									Select @COAID= Id From Bean.ChartOfAccount Where CompanyId=@CompanyId And Name=@COATradeReceivables
									Select @ExchangeRate= ExchangeRate From Bean.DebitNote Where Id=@DocumentId
									IF Exists (Select Id From Bean.DebitNote Where Id=@DocumentId And DocumentState In (@FullyApplied,@Fullypaid))
									Begin
										Set @IsRoundingAmount=1
									End
								End
								Else IF Exists (Select Id From Bean.PaymentDetail Where Id=@PaymentDtlId And Nature=@NatureOthers And DocumentType =@DebitNoteDocument)
								Begin
									-- Opt : Replaced Set with Select
									Select @COAID= Id From Bean.ChartOfAccount Where CompanyId=@CompanyId And Name=@COAotherReceivables
									Select @ExchangeRate= ExchangeRate From Bean.DebitNote Where Id=@DocumentId
									IF Exists (Select Id From Bean.DebitNote Where Id=@DocumentId And DocumentState In (@FullyApplied,@Fullypaid))
									Begin
										Set @IsRoundingAmount=1
									End
								End
								Else IF Exists (Select Id From Bean.PaymentDetail Where Id=@PaymentDtlId And Nature=@NatureTrade And DocumentType Not In (@InvoiceDocument,@DebitNoteDocument,@CreditNoteDocument,@CreditMemoDocument))
								Begin
									-- Opt : Replaced Set with Select
									Select @COAID= Id From Bean.ChartOfAccount Where CompanyId=@CompanyId And Name=@COATradePayables
									Select @ExchangeRate= ExchangeRate From Bean.Bill Where Id=@DocumentId
									IF Exists (Select Id From Bean.Bill Where Id=@DocumentId And DocumentState In (@FullyApplied,@Fullypaid))
									Begin
										Set @IsRoundingAmount=1
									End
								End
								Else IF Exists (Select Id From Bean.PaymentDetail Where Id=@PaymentDtlId And Nature=@NatureOthers And DocumentType Not In (@InvoiceDocument,@DebitNoteDocument,@CreditNoteDocument,@CreditMemoDocument))
								Begin
									-- Opt : Replaced Set with Select
									Select @COAID= Id From Bean.ChartOfAccount Where CompanyId=@CompanyId And Name=@COAOtherPayables
									Select @ExchangeRate= ExchangeRate From Bean.Bill Where Id=@DocumentId
									IF Exists (Select Id From Bean.Bill Where Id=@DocumentId And DocumentState In (@FullyApplied,@Fullypaid))
									Begin
										Set @IsRoundingAmount=1
									End
								End
								IF @IsRoundingAmount=1 And Exists (Select Amount From @RoundingAmountDetails Where DocumentId=@DocumentId And Amount Is Not Null And Amount<>'') -- And @RoundingAmount Is Not Null And @RoundingAmount <>''
								Begin
									-- Opt : Replaced Set with Select
									Select @DocAmount= Amount From @RoundingAmountDetails Where DocumentId=@DocumentId
								End
								Else
								Begin
									Set @DocAmount=0
								End
								-- Opt : Replaced Set with Select
								Select @OffSetDocumentType= DocumentType From Bean.PaymentDetail Where Id=@PaymentDtlId
								Set @MasterRecOrder=@MasterRecOrder+1
								IF @OffSetDocumentType=@InvoiceDocument Or @OffSetDocumentType=@DebitNoteDocument
								Begin
									Set @RecOrder=@RecOrder+1
									Insert Into Bean.JournalDetail (Id,JournalId,COAId,AccountDescription, DocDebit,DocCredit,BaseDebit,BaseCredit,DocDebitTotal,DocCreditTotal,BaseDebitTotal,BaseCreditTotal,DocumentId,DocumentDetailId,ItemId,BaseCurrency,ExchangeRate, DocType,DocSubType,ServiceCompanyId,DocNo,Nature,OffsetDocument,IsTax,
																	EntityId, SystemRefNo, DocCurrency,DocDate, PostingDate,RecOrder 
																	)
									Select NEWID(),@JournalId,@COAID,P.Remarks,Null As DocDebit,PD.PaymentAmount As DocCredit,Null As BaseDebit,Round(PD.PaymentAmount * @DefaultExchangeRate,2)-Isnull(@DocAmount,0) As BaseCredit,
											0.00 As DocDebitTotal,0.00 As DocCreditTotal,0.00 As BaseDebitTotal,0.00 As BaseCreditTotal,P.Id As DocumnetId,PD.Id As DocumentDetailId,@GUIDZero,P.BaseCurrency,@ExchangeRate As ExchangeRate,
											@DocType,@DocSubType,PD.ServiceCompanyId,P.DocNo,PD.Nature,Null As DocumentNo,0 As IsTax,P.EntityId,@SystemRefNo,@DocCurrency,P.DocDate,P.DocDate,@RecOrder As RecOrder
									From Bean.Payment As P
									Inner Join bean.PaymentDetail As PD On PD.PaymentId=P.Id
									Where P.Id=@SourceId And PD.Id=@PaymentDtlId
								End
								Else IF @OffSetDocumentType=@CreditNoteDocument
								Begin
									Insert Into Bean.JournalDetail (Id,JournalId,COAId,AccountDescription, DocDebit,DocCredit,BaseDebit,BaseCredit,DocDebitTotal,DocCreditTotal,BaseDebitTotal,BaseCreditTotal,DocumentId,DocumentDetailId,ItemId,
																	BaseCurrency,ExchangeRate, DocType,DocSubType,ServiceCompanyId,DocNo,Nature,OffsetDocument,IsTax,EntityId, SystemRefNo, DocCurrency,DocDate, PostingDate,RecOrder 
																	)
									Select NEWID(),@MasterJournalId,@ClearingPaymentsCOAID,P.Remarks,Round(PD.PaymentAmount/@SysCalExchangerate,2) As DocDebit,Null As DocCredit,Round(PD.PaymentAmount * @DefaultExchangeRate,2) As BaseDebit,Null As BaseCredit,
											0.00 As DocDebitTotal,0.00 As DocCreditTotal,0.00 As BaseDebitTotal,0.00 As BaseCreditTotal,P.Id As DocumnetId,PD.Id As DocumentDetailId,@GUIDZero,P.BaseCurrency,@ExchangeRate As ExchangeRate,
											@DocType,@DocSubType,PD.ServiceCompanyId,P.DocNo,PD.Nature,Null As DocumentNo,0 As IsTax,P.EntityId,@MasterSystemRefNo,@BankChargesCurrency,P.DocDate,P.DocDate,@MasterRecOrder As RecOrder
									From Bean.Payment As P
									Inner Join bean.PaymentDetail As PD On PD.PaymentId=P.Id
									Where P.Id=@SourceId And PD.Id=@PaymentDtlId
								End
								Else IF @OffSetDocumentType=@CreditMemoDocument
								Begin
									Insert Into Bean.JournalDetail (Id,JournalId,COAId,AccountDescription, DocDebit,DocCredit,BaseDebit,BaseCredit,DocDebitTotal,DocCreditTotal,BaseDebitTotal,BaseCreditTotal,DocumentId,DocumentDetailId,ItemId,BaseCurrency,
																	ExchangeRate, DocType,DocSubType,ServiceCompanyId,DocNo,Nature,OffsetDocument,IsTax,EntityId, SystemRefNo, DocCurrency,DocDate, PostingDate,RecOrder 
																	)
									Select NEWID(),@MasterJournalId,@ClearingPaymentsCOAID,P.Remarks,Null As DocDebit,Round(PD.PaymentAmount/@SysCalExchangerate,2) As DocCredit,Null As BaseDebit,Round(PD.PaymentAmount * @DefaultExchangeRate,2) As BaseCredit,
											0.00 As DocDebitTotal,0.00 As DocCreditTotal,0.00 As BaseDebitTotal,0.00 As BaseCreditTotal,P.Id As DocumnetId,PD.Id As DocumentDetailId,@GUIDZero,P.BaseCurrency,@ExchangeRate As ExchangeRate,
											@DocType,@DocSubType,PD.ServiceCompanyId,P.DocNo,PD.Nature,Null As DocumentNo,0 As IsTax,P.EntityId,@MasterSystemRefNo,@BankChargesCurrency,P.DocDate,P.DocDate,@MasterRecOrder As RecOrder
									From Bean.Payment As P
									Inner Join bean.PaymentDetail As PD On PD.PaymentId=P.Id
									Where P.Id=@SourceId And PD.Id=@PaymentDtlId
								End
								Else 
								Begin
									Set @RecOrder=@RecOrder+1
									Insert Into Bean.JournalDetail (Id,JournalId,COAId,AccountDescription, DocDebit,DocCredit,BaseDebit,BaseCredit,DocDebitTotal,DocCreditTotal,BaseDebitTotal,BaseCreditTotal,DocumentId,DocumentDetailId,ItemId,BaseCurrency,ExchangeRate, DocType,DocSubType,ServiceCompanyId,DocNo,Nature,OffsetDocument,IsTax,
																	EntityId, SystemRefNo, DocCurrency,DocDate, PostingDate,RecOrder 
																	)
									Select NEWID(),@JournalId,@COAID,P.Remarks,PD.PaymentAmount As DocDebit,Null As DocCredit,Round(PD.PaymentAmount * @DefaultExchangeRate,2)-Isnull(@DocAmount,0) As BaseDebit,Null As BaseCredit,
											0.00 As DocDebitTotal,0.00 As DocCreditTotal,0.00 As BaseDebitTotal,0.00 As BaseCreditTotal,P.Id As DocumnetId,PD.Id As DocumentDetailId,@GUIDZero,P.BaseCurrency,@ExchangeRate As ExchangeRate,
											@DocType,@DocSubType,PD.ServiceCompanyId,P.DocNo,PD.Nature,Null As DocumentNo,0 As IsTax,P.EntityId,@SystemRefNo,@DocCurrency,P.DocDate,P.DocDate,@RecOrder As RecOrder
									From Bean.Payment As P
									Inner Join bean.PaymentDetail As PD On PD.PaymentId=P.Id
									Where P.Id=@SourceId And PD.Id=@PaymentDtlId	

								End
								Set @RdtlRecCount=@RdtlRecCount+1
							End
						End
						-- Diffrent Service Companies
						Else
						Begin
							-- Opt : Replaced Set with Select
							Select @IntroCompCOAID= COA.Id 
							From Bean.ChartOfAccount As COA 
							Inner Join Bean.AccountType As ACT On ACT.Id=COA.AccountTypeId
							Where ACT.CompanyId=@CompanyId And ACT.Name=@IntercompClearingCOAName 
							And COA.SubsidaryCompanyId=@ServCompId
							
							If Exists (Select Id From Bean.PaymentDetail Where PaymentId=@SourceId And ServiceCompanyId=@ServCompId And DocumentType=@CreditMemoDocument And PaymentAmount<>0)
							Begin
								Set @MasterRecOrder=@MasterRecOrder+1
								-- Opt : Replaced Set with Select
								Select @PaymentAmtTotal= Sum(Isnull(PaymentAmount,0)) From Bean.PaymentDetail Where ServiceCompanyId=@ServCompId And PaymentId=@SourceId And DocumentType=@CreditMemoDocument
								Insert Into Bean.JournalDetail (Id,JournalId,COAId,AccountDescription,AllowDisAllow, DocCredit, BaseCredit, DocDebitTotal,DocCreditTotal,BaseDebitTotal,BaseCreditTotal,DocumentId,DocumentDetailId,ItemId,
																BaseCurrency,ExchangeRate,GSTExCurrency,GSTExchangeRate,DocType,DocSubType,ServiceCompanyId,DocNo,IsTax,EntityId, SystemRefNo, DocCurrency,DocDate, PostingDate,RecOrder )
								Select NEWID(),@MasterJournalId,@IntroCompCOAID,Remarks,IsDisAllow,Round(@PaymentAmtTotal /@SysCalExchangerate,2),Round(@PaymentAmtTotal * @DefaultExchangeRate ,2),0.00 As DocDebitTotal,0.00 As DocCreditTotal,0.00 As BaseDebitTotal,0.00 As BaseCreditTotal,Id As DocumnetId,@GUIDZero,@GUIDZero,
										BaseCurrency,@MainExchangeRate As ExchangeRate,GSTExCurrency,GSTExchangeRate,@DocType,@DocSubType,@ServCompId As ServiceCompanyId,DocNo,0 As IsTax,EntityId,@MasterSystemRefNo As SystemRefNo,@BankChargesCurrency,DocDate,DocDate,@MasterRecOrder As RecOrder
								From Bean.Payment Where Id=@SourceId
								-- New Journals
								Set @SysRefNumOrder=@SysRefNumOrder+1
								Set @SystemRefNo=Concat(@DocNo,'-JV',@SysRefNumOrder)
								Set @JournalId=NEWID()
								Set @RecOrder=1
								Insert Into Bean.Journal (Id,CompanyId,DocDate,DocType,DocSubType,DocNo,ServiceCompanyId,SystemReferenceNo,IsNoSupportingDocs,NoSupportingDocument,DocCurrency,ExchangeRate,ExCurrency,ExDurationFrom,GSTExchangeRate,GSTExCurrency,GSTTotalAmount,DocumentState,IsNoSupportingDocument,IsGstSettings,IsMultiCurrency,IsAllowableNonAllowable,IsGSTCurrencyRateChanged,
															Remarks,UserCreated,CreatedDate,Status,DocumentDescription,CreationType,GrandDocDebitTotal,GrandDocCreditTotal,GrandBaseDebitTotal,GrandBaseCreditTotal,EntityId,EntityType,PostingDate,COAId,ModeOfReceipt,BankReceiptAmmount,ExcessPaidByClientAmmount,BalancingItemReciveCRAmount,  BalancingItemPayDRAmount,ReceiptApplicationAmmount,
															DocumentId, BankClearingDate ,IsBalancing,ISAllowDisAllow, IsShow, ActualSysRefNo,IsSegmentReporting,TransferRefNo
														 )
								Select @JournalId,@CompanyId,DocDate,@DocType,@DocSubType,DocNo,@ServCompId,@SystemRefNo As SystemRefNo,IsNoSupportingDocument,NoSupportingDocs,DocCurrency,ExchangeRate,ExCurrency,ExDurationFrom,GSTExchangeRate,GSTExCurrency,Isnull(GSTTotalAmount,0),DocumentState,NoSupportingDocs,IsGstSettings,IsMultiCurrency,IsAllowableDisallowable,IsGSTCurrencyRateChanged,Remarks,@UserCreated,@CreatedDate,Status,Remarks As DocDescription,@UserCreated,GrandTotal,0.00 As GrandDocCreditTotal,Round(GrandTotal * ExchangeRate,2) As GrandBaseDebitTotal,
										0.00 As GrandBaseCreditTotal,EntityId,EntityType,DocDate As PostingDate,COAId,ModeOfReceipt,0.00 As BankReceiptAmmount,0.00 As ExcessPaidByClientAmmount,0.00 As BalancingItemReciveCRAmount,0.00 As BalancingItemPayDRAmount,0.00 As ReceiptApplicationAmmount,Id As DocumentId,BankClearingDate,0 As IsBalancing,IsDisAllow,1 As IsShow,DocNo As ActualSysRefNo,0 As IsSegmentReporting, PaymentRefNo
								From Bean.Payment Where CompanyId=@CompanyId And Id=@SourceId
								/* Creating Mater record In JournalDetail */
								Insert Into Bean.JournalDetail (Id,JournalId,COAId,AccountDescription,AllowDisAllow, DocDebit, BaseDebit, DocDebitTotal,DocCreditTotal,BaseDebitTotal,BaseCreditTotal,DocumentId,DocumentDetailId,ItemId,
																BaseCurrency,ExchangeRate,GSTExCurrency,GSTExchangeRate,DocType,DocSubType,ServiceCompanyId,DocNo,IsTax,EntityId, SystemRefNo, DocCurrency,DocDate, PostingDate,RecOrder )
								Select NEWID(),@JournalId,@MainInterCoServCompCOAID,Remarks,IsDisAllow,Round((@PaymentAmtTotal /@SysCalExchangerate),2),Round((@PaymentAmtTotal/@SysCalExchangerate) * @SysCalExchangerate,2),0.00 As DocDebitTotal,0.00 As DocCreditTotal,0.00 As BaseDebitTotal,0.00 As BaseCreditTotal,Id As DocumnetId,@GUIDZero,@GUIDZero,
										BaseCurrency,@SysCalExchangerate As ExchangeRate,GSTExCurrency,GSTExchangeRate,@DocType,@DocSubType,@ServCompId As ServiceCompanyId,DocNo,0 As IsTax,EntityId,@MasterSystemRefNo As SystemRefNo,@BankChargesCurrency,DocDate,DocDate,@RecOrder As RecOrder
								From Bean.Payment Where Id=@SourceId
								Set @RecOrder=@RecOrder+1
								-- Clearing payments
								Insert Into Bean.JournalDetail (Id,JournalId,COAId,AccountDescription,AllowDisAllow, DocCredit, BaseCredit, DocDebitTotal,DocCreditTotal,BaseDebitTotal,BaseCreditTotal,DocumentId,DocumentDetailId,ItemId,
																BaseCurrency,ExchangeRate,GSTExCurrency,GSTExchangeRate,DocType,DocSubType,ServiceCompanyId,DocNo,IsTax,EntityId, SystemRefNo, DocCurrency,DocDate, PostingDate,RecOrder )
								Select NEWID(),@JournalId,@ClearingPaymentsCOAID,Remarks,IsDisAllow,Round(@PaymentAmtTotal /@SysCalExchangerate,2),Round(@PaymentAmtTotal * @DefaultExchangeRate ,2),0.00 As DocDebitTotal,0.00 As DocCreditTotal,0.00 As BaseDebitTotal,0.00 As BaseCreditTotal,Id As DocumnetId,@GUIDZero,@GUIDZero,
										BaseCurrency,@MainExchangeRate As ExchangeRate,GSTExCurrency,GSTExchangeRate,@DocType,@DocSubType,@ServCompId As ServiceCompanyId,DocNo,0 As IsTax,EntityId,@MasterSystemRefNo As SystemRefNo,@BankChargesCurrency,DocDate,DocDate,@MasterRecOrder As RecOrder
								From Bean.Payment Where Id=@SourceId
							End
							If Exists (Select Id From Bean.PaymentDetail Where PaymentId=@SourceId And ServiceCompanyId=@ServCompId And DocumentType=@CreditNoteDocument And PaymentAmount<>0)
							Begin
								Set @MasterRecOrder=@MasterRecOrder+1
								-- Opt : Replaced Set with Select
								Select @PaymentAmtTotal= Sum(Isnull(PaymentAmount,0)) From Bean.PaymentDetail 
								Where ServiceCompanyId=@ServCompId And PaymentId=@SourceId And DocumentType=@CreditNoteDocument
								Insert Into Bean.JournalDetail (Id,JournalId,COAId,AccountDescription,AllowDisAllow, DocDebit, BaseDebit, DocDebitTotal,DocCreditTotal,BaseDebitTotal,BaseCreditTotal,DocumentId,DocumentDetailId,ItemId,BaseCurrency,
																ExchangeRate,GSTExCurrency,GSTExchangeRate,DocType,DocSubType,ServiceCompanyId,DocNo,IsTax,EntityId, SystemRefNo, DocCurrency,DocDate, PostingDate,RecOrder )
								Select NEWID(),@MasterJournalId,@IntroCompCOAID,Remarks,IsDisAllow,Round(@PaymentAmtTotal/@SysCalExchangerate,2),Round(@PaymentAmtTotal * @DefaultExchangeRate,2),0.00 As DocDebitTotal,
										0.00 As DocCreditTotal,0.00 As BaseDebitTotal,0.00 As BaseCreditTotal,Id As DocumnetId,@GUIDZero,@GUIDZero,BaseCurrency,@MainExchangeRate As ExchangeRate,GSTExCurrency,GSTExchangeRate,@DocType,
										@DocSubType,@ServCompId As ServiceCompanyId,DocNo,0 As IsTax,EntityId,@MasterSystemRefNo As SystemRefNo,@BankChargesCurrency,DocDate,DocDate,@MasterRecOrder As RecOrder
								From Bean.Payment Where Id=@SourceId
								-- New Journals
								Set @SysRefNumOrder=@SysRefNumOrder+1
								Set @SystemRefNo=Concat(@DocNo,'-JV',@SysRefNumOrder)
								Set @JournalId=NEWID()
								Set @RecOrder=1
								Insert Into Bean.Journal (Id,CompanyId,DocDate,DocType,DocSubType,DocNo,ServiceCompanyId,SystemReferenceNo,IsNoSupportingDocs,NoSupportingDocument,DocCurrency,ExchangeRate,ExCurrency,ExDurationFrom,GSTExchangeRate,GSTExCurrency,GSTTotalAmount,DocumentState,IsNoSupportingDocument,IsGstSettings,IsMultiCurrency,IsAllowableNonAllowable,IsGSTCurrencyRateChanged,
															Remarks,UserCreated,CreatedDate,Status,DocumentDescription,CreationType,GrandDocDebitTotal,GrandDocCreditTotal,GrandBaseDebitTotal,GrandBaseCreditTotal,EntityId,EntityType,PostingDate,COAId,ModeOfReceipt,BankReceiptAmmount,ExcessPaidByClientAmmount,BalancingItemReciveCRAmount,  BalancingItemPayDRAmount,ReceiptApplicationAmmount,
															DocumentId, BankClearingDate ,IsBalancing,ISAllowDisAllow, IsShow, ActualSysRefNo,IsSegmentReporting,TransferRefNo
														 )
								Select @JournalId,@CompanyId,DocDate,@DocType,@DocSubType,DocNo,@ServCompId,@SystemRefNo As SystemRefNo,IsNoSupportingDocument,NoSupportingDocs,DocCurrency,ExchangeRate,ExCurrency,ExDurationFrom,GSTExchangeRate,GSTExCurrency,Isnull(GSTTotalAmount,0),DocumentState,NoSupportingDocs,IsGstSettings,IsMultiCurrency,IsAllowableDisallowable,IsGSTCurrencyRateChanged,Remarks,@UserCreated,@CreatedDate,Status,Remarks As DocDescription,@UserCreated,GrandTotal,0.00 As GrandDocCreditTotal,Round(GrandTotal * ExchangeRate,2) As GrandBaseDebitTotal,
										0.00 As GrandBaseCreditTotal,EntityId,EntityType,DocDate As PostingDate,COAId,ModeOfReceipt,0.00 As BankReceiptAmmount,0.00 As ExcessPaidByClientAmmount,0.00 As BalancingItemReciveCRAmount,0.00 As BalancingItemPayDRAmount,0.00 As ReceiptApplicationAmmount,Id As DocumentId,BankClearingDate,0 As IsBalancing,IsDisAllow,1 As IsShow,DocNo As ActualSysRefNo,0 As IsSegmentReporting, PaymentRefNo
								From Bean.Payment Where CompanyId=@CompanyId And Id=@SourceId
								/* Creating Mater record In JournalDetail */
								Insert Into Bean.JournalDetail (Id,JournalId,COAId,AccountDescription,AllowDisAllow, DocCredit, BaseCredit, DocDebitTotal,DocCreditTotal,BaseDebitTotal,BaseCreditTotal,DocumentId,DocumentDetailId,ItemId,
																BaseCurrency,ExchangeRate,GSTExCurrency,GSTExchangeRate,DocType,DocSubType,ServiceCompanyId,DocNo,IsTax,EntityId, SystemRefNo, DocCurrency,DocDate, PostingDate,RecOrder )
								Select NEWID(),@JournalId,@MainInterCoServCompCOAID,Remarks,IsDisAllow,Round(@PaymentAmtTotal/@SysCalExchangerate,2),Round((@PaymentAmtTotal/@SysCalExchangerate)* @SysCalExchangerate,2),0.00 As DocDebitTotal,0.00 As DocCreditTotal,0.00 As BaseDebitTotal,0.00 As BaseCreditTotal,Id As DocumnetId,@GUIDZero,@GUIDZero,
										BaseCurrency,@SysCalExchangerate As ExchangeRate,GSTExCurrency,GSTExchangeRate,@DocType,@DocSubType,@ServCompId As ServiceCompanyId,DocNo,0 As IsTax,EntityId,@MasterSystemRefNo As SystemRefNo,@BankChargesCurrency,DocDate,DocDate,@RecOrder As RecOrder
								From Bean.Payment Where Id=@SourceId
								-- Clearing payments
								Set @RecOrder=@RecOrder+1
								Insert Into Bean.JournalDetail (Id,JournalId,COAId,AccountDescription,AllowDisAllow, DocDebit, BaseDebit, DocDebitTotal,DocCreditTotal,BaseDebitTotal,BaseCreditTotal,DocumentId,DocumentDetailId,ItemId,
																BaseCurrency,ExchangeRate,GSTExCurrency,GSTExchangeRate,DocType,DocSubType,ServiceCompanyId,DocNo,IsTax,EntityId, SystemRefNo, DocCurrency,DocDate, PostingDate,RecOrder )
								Select NEWID(),@JournalId,@ClearingPaymentsCOAID,Remarks,IsDisAllow,Round(@PaymentAmtTotal/@SysCalExchangerate,2),Round((@PaymentAmtTotal/@SysCalExchangerate)* @SysCalExchangerate,2),0.00 As DocDebitTotal,0.00 As DocCreditTotal,0.00 As BaseDebitTotal,0.00 As BaseCreditTotal,Id As DocumnetId,@GUIDZero,@GUIDZero,
										BaseCurrency,@SysCalExchangerate As ExchangeRate,GSTExCurrency,GSTExchangeRate,@DocType,@DocSubType,@ServCompId As ServiceCompanyId,DocNo,0 As IsTax,EntityId,@MasterSystemRefNo As SystemRefNo,@BankChargesCurrency,DocDate,DocDate,@RecOrder As RecOrder
								From Bean.Payment Where Id=@SourceId
							End

							Set @MasterRecOrder=@MasterRecOrder+1
							--Set @PaymentAmtTotal=(Select Sum(Isnull(PaymentAmount,0)) From Bean.PaymentDetail Where ServiceCompanyId=@ServCompId And PaymentId=@SourceId And DocumentType Not in (@CreditMemoDocument,@CreditNoteDocument) )
							-- Opt : Replaced Set with Select
							Select @ClearingPaymentInvOrDNAmount= SUM(Isnull(PaymentAmount,0)) From bean.PaymentDetail Where PaymentId=@SourceId And ServiceCompanyId=@ServCompId And DocumentType In (@InvoiceDocument,@DebitNoteDocument)
							Select @ClearingPaymentBillAmount= SUM(Isnull(PaymentAmount,0)) From bean.PaymentDetail Where PaymentId=@SourceId  And ServiceCompanyId=@ServCompId And DocumentType Not In (@CreditMemoDocument,@CreditNoteDocument,@InvoiceDocument,@DebitNoteDocument)
							Set @PaymentAmtTotal=ABS(Isnull(@ClearingPaymentBillAmount,0)-Isnull(@ClearingPaymentInvOrDNAmount,0))
							
							If @PaymentAmtTotal Is Not null And @PaymentAmtTotal<>0
							Begin
								IF (Isnull(@ClearingPaymentBillAmount,0)-Isnull(@ClearingPaymentInvOrDNAmount,0)) <0
								Begin
									/* Creating Mater record In Master JournalDetail */
									Insert Into Bean.JournalDetail (Id,JournalId,COAId,AccountDescription,AllowDisAllow, DocCredit, BaseCredit, DocDebitTotal,DocCreditTotal,BaseDebitTotal,BaseCreditTotal,DocumentId,DocumentDetailId,ItemId,BaseCurrency,ExchangeRate,
																	GSTExCurrency,GSTExchangeRate,DocType,DocSubType,ServiceCompanyId,DocNo,IsTax,EntityId, SystemRefNo, DocCurrency,DocDate,PostingDate,RecOrder )
									Select NEWID(),@MasterJournalId,@IntroCompCOAID,Remarks,IsDisAllow,Round(ABS(@PaymentAmtTotal) / @SysCalExchangerate,2),Round((ABS(@PaymentAmtTotal) / @SysCalExchangerate) * @SysCalExchangerate ,2),0.00 As DocDebitTotal,0.00 As DocCreditTotal,0.00 As BaseDebitTotal,0.00 As BaseCreditTotal,Id As DocumnetId,@GUIDZero,@GUIDZero,
											BaseCurrency,@MainExchangeRate As ExchangeRate,GSTExCurrency,GSTExchangeRate,@DocType,@DocSubType,@ServCompId As ServiceCompanyId,DocNo,0 As IsTax,EntityId,@MasterSystemRefNo As SystemRefNo,@BankChargesCurrency,DocDate,DocDate,@MasterRecOrder As RecOrder
									From Bean.Payment Where Id=@SourceId
									-- New Journals
									Set @SysRefNumOrder=@SysRefNumOrder+1
									Set @SystemRefNo=Concat(@DocNo,'-JV',@SysRefNumOrder)
									Set @JournalId=NEWID()
									Insert Into Bean.Journal (Id,CompanyId,DocDate,DocType,DocSubType,DocNo,ServiceCompanyId,SystemReferenceNo,IsNoSupportingDocs,NoSupportingDocument,DocCurrency,ExchangeRate,ExCurrency,ExDurationFrom,GSTExchangeRate,GSTExCurrency,GSTTotalAmount,DocumentState,IsNoSupportingDocument,IsGstSettings,IsMultiCurrency,IsAllowableNonAllowable,IsGSTCurrencyRateChanged,
																Remarks,UserCreated,CreatedDate,Status,DocumentDescription,CreationType,GrandDocDebitTotal,GrandDocCreditTotal,GrandBaseDebitTotal,GrandBaseCreditTotal,EntityId,EntityType,PostingDate,COAId,ModeOfReceipt,BankReceiptAmmount,ExcessPaidByClientAmmount,BalancingItemReciveCRAmount,  BalancingItemPayDRAmount,ReceiptApplicationAmmount,
																DocumentId, BankClearingDate ,IsBalancing,ISAllowDisAllow, IsShow, ActualSysRefNo,IsSegmentReporting, TransferRefNo
															 )
									Select @JournalId,@CompanyId,DocDate,@DocType,@DocSubType,DocNo,@ServCompId,@SystemRefNo As SystemRefNo,IsNoSupportingDocument,NoSupportingDocs,DocCurrency,ExchangeRate,ExCurrency,ExDurationFrom,GSTExchangeRate,GSTExCurrency,Isnull(GSTTotalAmount,0),DocumentState,NoSupportingDocs,IsGstSettings,IsMultiCurrency,IsAllowableDisallowable,IsGSTCurrencyRateChanged,Remarks,@UserCreated,@CreatedDate,Status,Remarks As DocDescription,@UserCreated,GrandTotal,0.00 As GrandDocCreditTotal,Round(GrandTotal * ExchangeRate,2) As GrandBaseDebitTotal,
											0.00 As GrandBaseCreditTotal,EntityId,EntityType,DocDate As PostingDate,COAId,ModeOfReceipt,0.00 As BankReceiptAmmount,0.00 As ExcessPaidByClientAmmount,0.00 As BalancingItemReciveCRAmount,0.00 As BalancingItemPayDRAmount,0.00 As ReceiptApplicationAmmount,Id As DocumentId,BankClearingDate,0 As IsBalancing,IsDisAllow,1 As IsShow,DocNo As ActualSysRefNo,0 As IsSegmentReporting, PaymentRefNo
									From Bean.Payment Where CompanyId=@CompanyId And Id=@SourceId
									/* Creating Mater record In JournalDetail */
									Set @RecOrder=1
									Insert Into Bean.JournalDetail (Id,JournalId,COAId,AccountDescription,AllowDisAllow, DocDebit, BaseDebit, DocDebitTotal,DocCreditTotal,BaseDebitTotal,BaseCreditTotal,DocumentId,DocumentDetailId,ItemId,
																	BaseCurrency,ExchangeRate,GSTExCurrency,GSTExchangeRate,DocType,DocSubType,ServiceCompanyId,DocNo, IsTax,EntityId, SystemRefNo, DocCurrency,DocDate, PostingDate,RecOrder )
									Select NEWID(),@JournalId,@MainInterCoServCompCOAID,Remarks,IsDisAllow,Round(ABS(@PaymentAmtTotal) / @SysCalExchangerate,2),Round((ABS(@PaymentAmtTotal) / @SysCalExchangerate) * @SysCalExchangerate ,2),0.00 As DocDebitTotal,0.00 As DocCreditTotal,0.00 As BaseDebitTotal,0.00 As BaseCreditTotal,Id As DocumnetId,@GUIDZero,@GUIDZero,
											BaseCurrency,@MainExchangeRate As ExchangeRate,GSTExCurrency,GSTExchangeRate,@DocType,@DocSubType,@ServCompId As ServiceCompanyId,DocNo,0 As IsTax,
											EntityId,@SystemRefNo As SystemRefNo,@BankChargesCurrency,DocDate,DocDate,@RecOrder As RecOrder
									From Bean.Payment Where Id=@SourceId
									Set @RecOrder=@RecOrder+1
									Insert Into Bean.JournalDetail (Id,JournalId,COAId,AccountDescription,AllowDisAllow, DocCredit, BaseCredit, DocDebitTotal,DocCreditTotal,BaseDebitTotal,BaseCreditTotal,DocumentId,DocumentDetailId,ItemId,
																	BaseCurrency,ExchangeRate,GSTExCurrency,GSTExchangeRate,DocType,DocSubType,ServiceCompanyId,DocNo, IsTax,EntityId, SystemRefNo, DocCurrency,DocDate, PostingDate,RecOrder )
									Select NEWID(),@JournalId,@ClearingPaymentsCOAID,Remarks,IsDisAllow,Round(ABS(@PaymentAmtTotal) / @SysCalExchangerate,2),Round((ABS(@PaymentAmtTotal) / @SysCalExchangerate) * @SysCalExchangerate ,2),0.00 As DocDebitTotal,0.00 As DocCreditTotal,0.00 As BaseDebitTotal,0.00 As BaseCreditTotal,Id As DocumnetId,@GUIDZero,@GUIDZero,
											BaseCurrency,@MainExchangeRate As ExchangeRate,GSTExCurrency,GSTExchangeRate,@DocType,@DocSubType,@ServCompId As ServiceCompanyId,DocNo,0 As IsTax,
											EntityId,@SystemRefNo As SystemRefNo,@BankChargesCurrency,DocDate,DocDate,@RecOrder As RecOrder
									From Bean.Payment Where Id=@SourceId
								End
								Else IF (Isnull(@ClearingPaymentBillAmount,0)-Isnull(@ClearingPaymentInvOrDNAmount,0)) >0
								Begin
									Insert Into Bean.JournalDetail (Id,JournalId,COAId,AccountDescription,AllowDisAllow, DocDebit, BaseDebit, DocDebitTotal,DocCreditTotal,BaseDebitTotal,BaseCreditTotal,DocumentId,DocumentDetailId,ItemId,BaseCurrency,ExchangeRate,
																	GSTExCurrency,GSTExchangeRate,DocType,DocSubType,ServiceCompanyId,DocNo,IsTax,EntityId, SystemRefNo, DocCurrency,DocDate,PostingDate,RecOrder )
									Select NEWID(),@MasterJournalId,@IntroCompCOAID,Remarks,IsDisAllow,Round(ABS(@PaymentAmtTotal)/@SysCalExchangerate,2),Round(ABS(@PaymentAmtTotal) * @DefaultExchangeRate,2),0.00 As DocDebitTotal,0.00 As DocCreditTotal,0.00 As BaseDebitTotal,0.00 As BaseCreditTotal,Id As DocumnetId,@GUIDZero,@GUIDZero,
											BaseCurrency,@MainExchangeRate As ExchangeRate,GSTExCurrency,GSTExchangeRate,@DocType,@DocSubType,@ServCompId As ServiceCompanyId,DocNo,0 As IsTax,EntityId,@MasterSystemRefNo As SystemRefNo,@BankChargesCurrency,DocDate,DocDate,@MasterRecOrder As RecOrder
									From Bean.Payment Where Id=@SourceId
									-- New Journals
									Set @SysRefNumOrder=@SysRefNumOrder+1
									Set @SystemRefNo=Concat(@DocNo,'-JV',@SysRefNumOrder)
									Set @JournalId=NEWID()
									Insert Into Bean.Journal (Id,CompanyId,DocDate,DocType,DocSubType,DocNo,ServiceCompanyId,SystemReferenceNo,IsNoSupportingDocs,NoSupportingDocument,DocCurrency,ExchangeRate,ExCurrency,ExDurationFrom,GSTExchangeRate,GSTExCurrency,GSTTotalAmount,DocumentState,IsNoSupportingDocument,IsGstSettings,IsMultiCurrency,IsAllowableNonAllowable,IsGSTCurrencyRateChanged,
																Remarks,UserCreated,CreatedDate,Status,DocumentDescription,CreationType,GrandDocDebitTotal,GrandDocCreditTotal,GrandBaseDebitTotal,GrandBaseCreditTotal,EntityId,EntityType,PostingDate,COAId,ModeOfReceipt,BankReceiptAmmount,ExcessPaidByClientAmmount,BalancingItemReciveCRAmount,  BalancingItemPayDRAmount,ReceiptApplicationAmmount,
																DocumentId, BankClearingDate ,IsBalancing,ISAllowDisAllow, IsShow, ActualSysRefNo,IsSegmentReporting,TransferRefNo
															 )
									Select @JournalId,@CompanyId,DocDate,@DocType,@DocSubType,DocNo,@ServCompId,@SystemRefNo As SystemRefNo,IsNoSupportingDocument,NoSupportingDocs,DocCurrency,ExchangeRate,ExCurrency,ExDurationFrom,GSTExchangeRate,GSTExCurrency,Isnull(GSTTotalAmount,0),DocumentState,NoSupportingDocs,IsGstSettings,IsMultiCurrency,IsAllowableDisallowable,IsGSTCurrencyRateChanged,Remarks,@UserCreated,@CreatedDate,Status,Remarks As DocDescription,@UserCreated,GrandTotal,0.00 As GrandDocCreditTotal,Round(GrandTotal * ExchangeRate,2) As GrandBaseDebitTotal,
											0.00 As GrandBaseCreditTotal,EntityId,EntityType,DocDate As PostingDate,COAId,ModeOfReceipt,0.00 As BankReceiptAmmount,0.00 As ExcessPaidByClientAmmount,0.00 As BalancingItemReciveCRAmount,0.00 As BalancingItemPayDRAmount,0.00 As ReceiptApplicationAmmount,Id As DocumentId,BankClearingDate,0 As IsBalancing,IsDisAllow,1 As IsShow,DocNo As ActualSysRefNo,0 As IsSegmentReporting, PaymentRefNo
									From Bean.Payment Where CompanyId=@CompanyId And Id=@SourceId
									/* Creating Mater record In JournalDetail */
									Set @RecOrder=1
									Insert Into Bean.JournalDetail (Id,JournalId,COAId,AccountDescription,AllowDisAllow, DocCredit, BaseCredit, DocDebitTotal,DocCreditTotal,BaseDebitTotal,BaseCreditTotal,DocumentId,DocumentDetailId,ItemId,
																	BaseCurrency,ExchangeRate,GSTExCurrency,GSTExchangeRate,DocType,DocSubType,ServiceCompanyId,DocNo, IsTax,EntityId, SystemRefNo, DocCurrency,DocDate, PostingDate,RecOrder )
									Select NEWID(),@JournalId,@MainInterCoServCompCOAID,Remarks,IsDisAllow,Round(ABS(@PaymentAmtTotal) / @SysCalExchangerate,2),Round((ABS(@PaymentAmtTotal) / @SysCalExchangerate) * @SysCalExchangerate ,2),0.00 As DocDebitTotal,0.00 As DocCreditTotal,0.00 As BaseDebitTotal,0.00 As BaseCreditTotal,Id As DocumnetId,@GUIDZero,@GUIDZero,
											BaseCurrency,@MainExchangeRate As ExchangeRate,GSTExCurrency,GSTExchangeRate,@DocType,@DocSubType,@ServCompId As ServiceCompanyId,DocNo,0 As IsTax,
											EntityId,@SystemRefNo As SystemRefNo,@BankChargesCurrency,DocDate,DocDate,@RecOrder As RecOrder
									From Bean.Payment Where Id=@SourceId
									Set @RecOrder=@RecOrder+1
									Insert Into Bean.JournalDetail (Id,JournalId,COAId,AccountDescription,AllowDisAllow, DocDebit, BaseDebit, DocDebitTotal,DocCreditTotal,BaseDebitTotal,BaseCreditTotal,DocumentId,DocumentDetailId,ItemId,
																	BaseCurrency,ExchangeRate,GSTExCurrency,GSTExchangeRate,DocType,DocSubType,ServiceCompanyId,DocNo, IsTax,EntityId, SystemRefNo, DocCurrency,DocDate, PostingDate,RecOrder )
									Select NEWID(),@JournalId,@ClearingPaymentsCOAID,Remarks,IsDisAllow,Round(ABS(@PaymentAmtTotal) / @SysCalExchangerate,2),Round((ABS(@PaymentAmtTotal) / @SysCalExchangerate) * @SysCalExchangerate ,2),0.00 As DocDebitTotal,0.00 As DocCreditTotal,0.00 As BaseDebitTotal,0.00 As BaseCreditTotal,Id As DocumnetId,@GUIDZero,@GUIDZero,
											BaseCurrency,@MainExchangeRate As ExchangeRate,GSTExCurrency,GSTExchangeRate,@DocType,@DocSubType,@ServCompId As ServiceCompanyId,DocNo,0 As IsTax,
											EntityId,@SystemRefNo As SystemRefNo,@BankChargesCurrency,DocDate,DocDate,@RecOrder As RecOrder
									From Bean.Payment Where Id=@SourceId

								End
								-- New Journals
								Set @SysRefNumOrder=@SysRefNumOrder+1
								Set @SystemRefNo=Concat(@DocNo,'-JV',@SysRefNumOrder)
								Set @JournalId=NEWID()
								Insert Into Bean.Journal (Id,CompanyId,DocDate,DocType,DocSubType,DocNo,ServiceCompanyId,SystemReferenceNo,IsNoSupportingDocs,NoSupportingDocument,DocCurrency,ExchangeRate,ExCurrency,ExDurationFrom,GSTExchangeRate,GSTExCurrency,GSTTotalAmount,DocumentState,IsNoSupportingDocument,IsGstSettings,IsMultiCurrency,IsAllowableNonAllowable,IsGSTCurrencyRateChanged,
															Remarks,UserCreated,CreatedDate,Status,DocumentDescription,CreationType,GrandDocDebitTotal,GrandDocCreditTotal,GrandBaseDebitTotal,GrandBaseCreditTotal,EntityId,EntityType,PostingDate,COAId,ModeOfReceipt,BankReceiptAmmount,ExcessPaidByClientAmmount,BalancingItemReciveCRAmount,  BalancingItemPayDRAmount,ReceiptApplicationAmmount,
															DocumentId, BankClearingDate ,IsBalancing,ISAllowDisAllow, IsShow, ActualSysRefNo,IsSegmentReporting, TransferRefNo
														 )
								Select @JournalId,@CompanyId,DocDate,@DocType,@DocSubType,DocNo,@ServCompId,@SystemRefNo As SystemRefNo,IsNoSupportingDocument,NoSupportingDocs,DocCurrency,ExchangeRate,ExCurrency,ExDurationFrom,GSTExchangeRate,GSTExCurrency,Isnull(GSTTotalAmount,0),DocumentState,NoSupportingDocs,IsGstSettings,IsMultiCurrency,IsAllowableDisallowable,IsGSTCurrencyRateChanged,Remarks,@UserCreated,@CreatedDate,Status,Remarks As DocDescription,@UserCreated,GrandTotal,0.00 As GrandDocCreditTotal,Round(GrandTotal * ExchangeRate,2) As GrandBaseDebitTotal,
										0.00 As GrandBaseCreditTotal,EntityId,EntityType,DocDate As PostingDate,COAId,ModeOfReceipt,0.00 As BankReceiptAmmount,0.00 As ExcessPaidByClientAmmount,0.00 As BalancingItemReciveCRAmount,0.00 As BalancingItemPayDRAmount,0.00 As ReceiptApplicationAmmount,Id As DocumentId,BankClearingDate,0 As IsBalancing,IsDisAllow,1 As IsShow,DocNo As ActualSysRefNo,0 As IsSegmentReporting, PaymentRefNo
								From Bean.Payment Where CompanyId=@CompanyId And Id=@SourceId
								IF (Isnull(@ClearingPaymentBillAmount,0)-Isnull(@ClearingPaymentInvOrDNAmount,0)) <0
								Begin
									/* Creating Mater record In JournalDetail */
									Insert Into Bean.JournalDetail (Id,JournalId,COAId,AccountDescription,AllowDisAllow, DocDebit, BaseDebit, DocDebitTotal,DocCreditTotal,BaseDebitTotal,BaseCreditTotal,DocumentId,DocumentDetailId,ItemId,
																	BaseCurrency,ExchangeRate,GSTExCurrency,GSTExchangeRate,DocType,DocSubType,ServiceCompanyId,DocNo, IsTax,EntityId, SystemRefNo, DocCurrency,DocDate, PostingDate,RecOrder )
									Select NEWID(),@JournalId,@ClearingPaymentsCOAID,Remarks,IsDisAllow,ABS(@PaymentAmtTotal),Round(ABS(@PaymentAmtTotal) * @DefaultExchangeRate,2),0.00 As DocDebitTotal,0.00 As DocCreditTotal,0.00 As BaseDebitTotal,0.00 As BaseCreditTotal,Id As DocumnetId,@GUIDZero,@GUIDZero,
											BaseCurrency,@MainExchangeRate As ExchangeRate,GSTExCurrency,GSTExchangeRate,@DocType,@DocSubType,@ServCompId As ServiceCompanyId,DocNo,0 As IsTax,
											EntityId,@SystemRefNo As SystemRefNo,@DocCurrency,DocDate,DocDate,@RecOrder As RecOrder
									From Bean.Payment Where Id=@SourceId
								End
								Else If (Isnull(@ClearingPaymentBillAmount,0)-Isnull(@ClearingPaymentInvOrDNAmount,0)) >0
								begin
									Insert Into Bean.JournalDetail (Id,JournalId,COAId,AccountDescription,AllowDisAllow, DocCredit, BaseCredit, DocDebitTotal,DocCreditTotal,BaseDebitTotal,BaseCreditTotal,DocumentId,DocumentDetailId,ItemId,
																	BaseCurrency,ExchangeRate,GSTExCurrency,GSTExchangeRate,DocType,DocSubType,ServiceCompanyId,DocNo, IsTax,EntityId, SystemRefNo, DocCurrency,DocDate, PostingDate,RecOrder )
									Select NEWID(),@JournalId,@ClearingPaymentsCOAID,Remarks,IsDisAllow,ABS(@PaymentAmtTotal),Round(ABS(@PaymentAmtTotal) * @DefaultExchangeRate,2),0.00 As DocDebitTotal,0.00 As DocCreditTotal,0.00 As BaseDebitTotal,0.00 As BaseCreditTotal,Id As DocumnetId,@GUIDZero,@GUIDZero,
											BaseCurrency,@MainExchangeRate As ExchangeRate,GSTExCurrency,GSTExchangeRate,@DocType,@DocSubType,@ServCompId As ServiceCompanyId,DocNo,0 As IsTax,
											EntityId,@SystemRefNo As SystemRefNo,@DocCurrency,DocDate,DocDate,@RecOrder As RecOrder
									From Bean.Payment Where Id=@SourceId
								End
								-- Payment detail records
								Delete From @PaymentDtl_New
								Insert Into @PaymentDtl_New
								Select ROW_NUMBER() Over (Order By Id),Id From Bean.PaymentDetail Where PaymentId=@SourceId And ServiceCompanyId=@ServCompId And PaymentAmount<>0 And DocumentType Not in (@CreditMemoDocument,@CreditNoteDocument)
								-- Opt : Replaced Set with Select
								Select @DtlCount= Count(*) From @PaymentDtl_New
								Set @RdtlRecCount=1
								While @DtlCount>=@RdtlRecCount
								Begin
									-- Opt : Replaced Set with Select
									Select @PaymentDtlId= PaymentDtlId From @PaymentDtl_New Where S_No=@RdtlRecCount
									Select @DocumentId= DocumentId From Bean.PaymentDetail Where Id=@PaymentDtlId
									Set @IsRoundingAmount=0
									IF Exists (Select Id From Bean.PaymentDetail Where Id=@PaymentDtlId And Nature=@NatureTrade And DocumentType =@InvoiceDocument)
									Begin
										-- Opt : Replaced Set with Select
										Select @COAID= Id From Bean.ChartOfAccount Where CompanyId=@CompanyId And Name=@COATradeReceivables
										Select @ExchangeRate= ExchangeRate From Bean.Invoice Where Id=@DocumentId
										IF Exists (Select Id From Bean.Invoice Where Id=@DocumentId And DocumentState In (@FullyApplied,@Fullypaid))
										Begin
											Set @IsRoundingAmount=1
										End
									End
									Else IF Exists (Select Id From Bean.PaymentDetail Where Id=@PaymentDtlId And Nature=@NatureOthers And DocumentType =@InvoiceDocument)
									Begin
										-- Opt : Replaced Set with Select
										Select @COAID= Id From Bean.ChartOfAccount Where CompanyId=@CompanyId And Name=@COAotherReceivables
										Select @ExchangeRate= ExchangeRate From Bean.Invoice Where Id=@DocumentId
										IF Exists (Select Id From Bean.Invoice Where Id=@DocumentId And DocumentState In (@FullyApplied,@Fullypaid))
										Begin
											Set @IsRoundingAmount=1
										End
									End
									Else IF Exists (Select Id From Bean.PaymentDetail Where Id=@PaymentDtlId And Nature=@NatureTrade And DocumentType =@DebitNoteDocument)
									Begin
										-- Opt : Replaced Set with Select
										Select @COAID= Id From Bean.ChartOfAccount Where CompanyId=@CompanyId And Name=@COATradeReceivables
										Select @ExchangeRate= ExchangeRate From Bean.DebitNote Where Id=@DocumentId
										IF Exists (Select Id From Bean.DebitNote Where Id=@DocumentId And DocumentState In (@FullyApplied,@Fullypaid))
										Begin
											Set @IsRoundingAmount=1
										End
									End
									Else IF Exists (Select Id From Bean.PaymentDetail Where Id=@PaymentDtlId And Nature=@NatureOthers And DocumentType =@DebitNoteDocument)
									Begin
										-- Opt : Replaced Set with Select
										Select @COAID= Id From Bean.ChartOfAccount Where CompanyId=@CompanyId And Name=@COAotherReceivables
										Select @ExchangeRate= ExchangeRate From Bean.DebitNote Where Id=@DocumentId
										IF Exists (Select Id From Bean.DebitNote Where Id=@DocumentId And DocumentState In (@FullyApplied,@Fullypaid))
										Begin
											Set @IsRoundingAmount=1
										End
									End
									Else IF Exists (Select Id From Bean.PaymentDetail Where Id=@PaymentDtlId And Nature=@NatureTrade And DocumentType Not In (@InvoiceDocument,@DebitNoteDocument,@CreditNoteDocument,@CreditMemoDocument))
									Begin
										-- Opt : Replaced Set with Select
										Select @COAID= Id From Bean.ChartOfAccount Where CompanyId=@CompanyId And Name=@COATradePayables
										Select @ExchangeRate= ExchangeRate From Bean.Bill Where Id=@DocumentId
										IF Exists (Select Id From Bean.Bill Where Id=@DocumentId And DocumentState In (@FullyApplied,@Fullypaid))
										Begin
											Set @IsRoundingAmount=1
										End
									End
									Else IF Exists (Select Id From Bean.PaymentDetail Where Id=@PaymentDtlId And Nature=@NatureOthers And DocumentType Not In (@InvoiceDocument,@DebitNoteDocument,@CreditNoteDocument,@CreditMemoDocument))
									Begin
										-- Opt : Replaced Set with Select
										Select @COAID= Id From Bean.ChartOfAccount Where CompanyId=@CompanyId And Name=@COAOtherPayables
										Select @ExchangeRate= ExchangeRate From Bean.Bill Where Id=@DocumentId
										IF Exists (Select Id From Bean.Bill Where Id=@DocumentId And DocumentState In (@FullyApplied,@Fullypaid))
										Begin
											Set @IsRoundingAmount=1
										End
									End
									IF @IsRoundingAmount=1 And Exists (Select Amount From @RoundingAmountDetails Where DocumentId=@DocumentId And Amount Is Not Null And Amount<>'') --And @RoundingAmount Is Not Null And @RoundingAmount <>''
									Begin
										-- Opt : Replaced Set with Select
										Select @DocAmount= Amount From @RoundingAmountDetails Where DocumentId=@DocumentId
									End
									Else
									Begin
										Set @DocAmount=0
									End
									-- Opt : Replaced Set with Select
									Select @OffSetDocumentType= DocumentType From Bean.PaymentDetail Where Id=@PaymentDtlId
									Set @RecOrder=@RecOrder+1
									IF @OffSetDocumentType=@InvoiceDocument Or @OffSetDocumentType=@DebitNoteDocument
									Begin
										Insert Into Bean.JournalDetail (Id,JournalId,COAId,AccountDescription, DocDebit,DocCredit,BaseDebit,BaseCredit,DocDebitTotal,DocCreditTotal,BaseDebitTotal,BaseCreditTotal,DocumentId,DocumentDetailId,ItemId,BaseCurrency,
																		ExchangeRate, DocType,DocSubType,ServiceCompanyId,DocNo,Nature,OffsetDocument,IsTax,EntityId, SystemRefNo, DocCurrency,DocDate, PostingDate,RecOrder 
																		)
										Select NEWID(),@JournalId,@COAID,P.Remarks,Null As DocDebit,PD.PaymentAmount As DocCredit,Null As BaseDebit,Round(PD.PaymentAmount * @ExchangeRate,2)-Isnull(@DocAmount,0) As BaseCredit,0.00 As DocDebitTotal,0.00 As DocCreditTotal,
												0.00 As BaseDebitTotal,0.00 As BaseCreditTotal,P.Id As DocumnetId,PD.Id As DocumentDetailId,@GUIDZero,P.BaseCurrency,@ExchangeRate As ExchangeRate,@DocType,@DocSubType,PD.ServiceCompanyId,P.DocNo,PD.Nature,
												Null As DocumentNo,0 As IsTax,P.EntityId,@SystemRefNo,@DocCurrency,P.DocDate,P.DocDate,@RecOrder As RecOrder
										From Bean.Payment As P
										Inner Join bean.PaymentDetail As PD On PD.PaymentId=P.Id
										Where P.Id=@SourceId And PD.Id=@PaymentDtlId
									End
									Else 
									Begin
										Insert Into Bean.JournalDetail (Id,JournalId,COAId,AccountDescription, DocDebit,DocCredit,BaseDebit,BaseCredit,DocDebitTotal,DocCreditTotal,BaseDebitTotal,BaseCreditTotal,DocumentId,DocumentDetailId,ItemId,BaseCurrency,
																		ExchangeRate, DocType,DocSubType,ServiceCompanyId,DocNo,Nature,OffsetDocument,IsTax,EntityId, SystemRefNo, DocCurrency,DocDate, PostingDate,RecOrder 
																		)
										Select NEWID(),@JournalId,@COAID,P.Remarks,PD.PaymentAmount As DocDebit,Null As DocCredit,Round(PD.PaymentAmount * @ExchangeRate,2)-Isnull(@DocAmount,0) As BaseDebit,Null As BaseCredit,0.00 As DocDebitTotal,0.00 As DocCreditTotal,
												0.00 As BaseDebitTotal,0.00 As BaseCreditTotal,P.Id As DocumnetId,PD.Id As DocumentDetailId,@GUIDZero,P.BaseCurrency,@MainExchangeRate As ExchangeRate,@DocType,@DocSubType,PD.ServiceCompanyId,P.DocNo,PD.Nature,
												Null As DocumentNo,0 As IsTax,P.EntityId,@SystemRefNo,@DocCurrency,P.DocDate,P.DocDate,@RecOrder As RecOrder
										From Bean.Payment As P
										Inner Join bean.PaymentDetail As PD On PD.PaymentId=P.Id
										Where P.Id=@SourceId And PD.Id=@PaymentDtlId
									End
									Set @RdtlRecCount=@RdtlRecCount+1
								End
							End
						End
						Set @RecCount=@RecCount+1
					End
				End
				Else IF @DocCurrency<>@BankChargesCurrency And @BaseCurrency<>@DocCurrency
				Begin
					/* Creating Mater record In JournalDetail */
					Insert Into Bean.JournalDetail (Id,JournalId,COAId,AccountDescription,AllowDisAllow, DocCredit, BaseCredit, DocDebitTotal,DocCreditTotal,BaseDebitTotal,BaseCreditTotal,DocumentId,DocumentDetailId,ItemId,BaseCurrency,
													ExchangeRate,GSTExCurrency,GSTExchangeRate,DocType,DocSubType,ServiceCompanyId,DocNo, IsTax,EntityId, SystemRefNo, DocCurrency,DocDate, PostingDate,RecOrder )
					Select NEWID(),@MasterJournalId,COAId,Remarks,IsDisAllow,GrandTotal,Round(GrandTotal * @DefaultExchangeRate,2),0.00 As DocDebitTotal,0.00 As DocCreditTotal,0.00 As BaseDebitTotal,0.00 As BaseCreditTotal,Id As DocumnetId,@GUIDZero,@GUIDZero,
							BaseCurrency,@DefaultExchangeRate As ExchangeRate,GSTExCurrency,GSTExchangeRate,@DocType,@DocSubType,ServiceCompanyId,DocNo,0 As IsTax,
							EntityId,@MasterSystemRefNo As SystemRefNo,@BankChargesCurrency,DocDate,DocDate,@MasterRecOrder As RecOrder
					From Bean.Payment Where Id=@SourceId
					-- Service company details
					Insert Into @ServCompaIdTbl
					Select Distinct ServiceCompanyId From Bean.PaymentDetail Where PaymentId=@SourceId And PaymentAmount<>0
					-- Opt : Replaced Set with Select
					Select @ServCompaIdTblCnt= Count(*) From @ServCompaIdTbl
					Set @RecCount=1
					While @ServCompaIdTblCnt>=@RecCount
					Begin
						-- Opt : Replaced Set with Select
						Select @ServCompId= SerCompId From @ServCompaIdTbl Where S_No=@RecCount
						IF @ServCompId=@MasterServComp
						Begin
							If Exists (Select Id From Bean.PaymentDetail Where PaymentId=@SourceId And ServiceCompanyId=@ServCompId And DocumentType=@CreditMemoDocument And PaymentAmount<>0)
							Begin
								Set @MasterRecOrder=@MasterRecOrder+1
								--Set @PaymentAmtTotal=(Select Sum(Isnull(PaymentAmount,0)) From Bean.PaymentDetail Where ServiceCompanyId=@ServCompId And PaymentId=@SourceId And DocumentType=@CreditMemoDocument)
								Insert Into Bean.JournalDetail (Id,JournalId,COAId,AccountDescription,AllowDisAllow,DocCredit,BaseCredit,DocDebitTotal,DocCreditTotal,BaseDebitTotal,BaseCreditTotal,DocumentId,DocumentDetailId,ItemId,
												BaseCurrency,ExchangeRate,GSTExCurrency,GSTExchangeRate,DocType,DocSubType,ServiceCompanyId,DocNo,IsTax,EntityId,SystemRefNo,DocCurrency,DocDate,PostingDate,RecOrder)
								Select NEWID(),@MasterJournalId,@ClearingPaymentsCOAID,Remarks,IsDisAllow,Round((PD.PaymentAmount * @SysCalExchangerate)/@DefaultExchangeRate,2),Round(PD.PaymentAmount * @SysCalExchangerate,2),0.00 As DocDebitTotal,0.00 As DocCreditTotal,0.00 As BaseDebitTotal,0.00 As BaseCreditTotal,P.Id As DocumnetId,
										@GUIDZero,@GUIDZero,BaseCurrency,@DefaultExchangeRate As ExchangeRate,GSTExCurrency,GSTExchangeRate,@DocType,@DocSubType,@ServCompId As ServiceCompanyId,DocNo,0 As IsTax,EntityId,@MasterSystemRefNo As SystemRefNo,@BankChargesCurrency,DocDate,DocDate,@MasterRecOrder As RecOrder
								From Bean.Payment As P
								Inner Join Bean.PaymentDetail As PD On PD.PaymentId=P.Id And P.ServiceCompanyId=PD.ServiceCompanyId
								Where P.Id=@SourceId And PD.DocumentType=@CreditMemoDocument
							End
							If Exists (Select Id From Bean.PaymentDetail Where PaymentId=@SourceId And ServiceCompanyId=@ServCompId And DocumentType=@CreditNoteDocument And PaymentAmount<>0)
							Begin
								Set @MasterRecOrder=@MasterRecOrder+1
								--Set @PaymentAmtTotal=(Select Sum(Isnull(PaymentAmount,0)) From Bean.PaymentDetail Where ServiceCompanyId=@ServCompId And PaymentId=@SourceId And DocumentType=@CreditNoteDocument)
								Insert Into Bean.JournalDetail (Id,JournalId,COAId,AccountDescription,AllowDisAllow,DocDebit,BaseDebit,DocDebitTotal,DocCreditTotal,BaseDebitTotal,BaseCreditTotal,DocumentId,DocumentDetailId,ItemId,BaseCurrency,ExchangeRate,GSTExCurrency,GSTExchangeRate,DocType,DocSubType,ServiceCompanyId,DocNo,IsTax,
												EntityId,SystemRefNo,DocCurrency,DocDate,PostingDate,RecOrder)
								Select NEWID(),@MasterJournalId,@ClearingPaymentsCOAID,Remarks,IsDisAllow,Round((PD.PaymentAmount * @SysCalExchangerate)/@DefaultExchangeRate,2),Round(PD.PaymentAmount * @SysCalExchangerate,2),0.00 As DocDebitTotal,0.00 As DocCreditTotal,0.00 As BaseDebitTotal,0.00 As BaseCreditTotal,P.Id As DocumnetId,@GUIDZero,@GUIDZero,
										BaseCurrency,@DefaultExchangeRate As ExchangeRate,GSTExCurrency,GSTExchangeRate,@DocType,@DocSubType,@ServCompId As ServiceCompanyId,DocNo,0 As IsTax,EntityId,@MasterSystemRefNo As SystemRefNo,@BankChargesCurrency,DocDate,DocDate,@MasterRecOrder As RecOrder
								From Bean.Payment As P
								Inner Join Bean.PaymentDetail As PD On PD.PaymentId=P.Id And P.ServiceCompanyId=PD.ServiceCompanyId
								Where P.Id=@SourceId And PD.DocumentType=@CreditNoteDocument
							End
							IF Exists (Select Id From Bean.PaymentDetail Where PaymentId=@SourceId And ServiceCompanyId=@ServCompId And PaymentAmount<>0 And DocumentType Not In (@CreditMemoDocument,@CreditNoteDocument))
							Begin
								Set @MasterRecOrder=@MasterRecOrder+1
								-- Opt : Replaced Set with Select
								Select @ClearingPaymentInvOrDNAmount= Sum(Isnull(PaymentAmount,0)) From Bean.PaymentDetail Where PaymentId=@SourceId And ServiceCompanyId=@ServCompId And DocumentType In (@InvoiceDocument,@DebitNoteDocument)
								Select @ClearingPaymentBillAmount= Sum(Isnull(PaymentAmount,0)) From Bean.PaymentDetail Where PaymentId=@SourceId And ServiceCompanyId=@ServCompId And DocumentType Not In (@InvoiceDocument,@DebitNoteDocument,@CreditMemoDocument,@CreditNoteDocument)
								Set @PaymentAmtTotal=(ISnull(@ClearingPaymentBillAmount,0)-Isnull(@ClearingPaymentInvOrDNAmount,0))
								/* Creating Mater record In JournalDetail */
								IF @PaymentAmtTotal Is Not Null And @PaymentAmtTotal>0
								Begin
									Insert Into Bean.JournalDetail (Id,JournalId,COAId,AccountDescription,AllowDisAllow, DocDebit, BaseDebit, DocDebitTotal,DocCreditTotal,BaseDebitTotal,BaseCreditTotal,DocumentId,DocumentDetailId,ItemId,BaseCurrency,ExchangeRate,GSTExCurrency,
																	GSTExchangeRate,DocType,DocSubType,ServiceCompanyId,DocNo, IsTax,EntityId, SystemRefNo, DocCurrency,DocDate, PostingDate,RecOrder )
									Select NEWID(),@MasterJournalId,@ClearingPaymentsCOAID,Remarks,IsDisAllow,Round((ABS(@PaymentAmtTotal) * @SysCalExchangerate)/@DefaultExchangeRate,2) ,Round(ABS(@PaymentAmtTotal) * @SysCalExchangerate,2),0.00 As DocDebitTotal,0.00 As DocCreditTotal,0.00 As BaseDebitTotal,
											0.00 As BaseCreditTotal,Id As DocumnetId,@GUIDZero,@GUIDZero,BaseCurrency,@SysCalExchangerate As ExchangeRate,GSTExCurrency,GSTExchangeRate,@DocType,@DocSubType,@ServCompId,DocNo,0 As IsTax,EntityId,@MasterSystemRefNo As SystemRefNo,
											@BankChargesCurrency,DocDate,DocDate,@MasterRecOrder As RecOrder
									From Bean.Payment Where Id=@SourceId
								End
								Else If @PaymentAmtTotal Is Not Null And @PaymentAmtTotal<0
								Begin
									Insert Into Bean.JournalDetail (Id,JournalId,COAId,AccountDescription,AllowDisAllow, DocCredit, BaseCredit, DocDebitTotal,DocCreditTotal,BaseDebitTotal,BaseCreditTotal,DocumentId,DocumentDetailId,ItemId,BaseCurrency,ExchangeRate,GSTExCurrency,
																	GSTExchangeRate,DocType,DocSubType,ServiceCompanyId,DocNo, IsTax,EntityId, SystemRefNo, DocCurrency,DocDate, PostingDate,RecOrder )
									Select NEWID(),@MasterJournalId,@ClearingPaymentsCOAID,Remarks,IsDisAllow,Round((ABS(@PaymentAmtTotal) * @SysCalExchangerate)/@DefaultExchangeRate,2) ,Round(ABS(@PaymentAmtTotal) * @SysCalExchangerate,2),0.00 As DocDebitTotal,0.00 As DocCreditTotal,0.00 As BaseDebitTotal,
											0.00 As BaseCreditTotal,Id As DocumnetId,@GUIDZero,@GUIDZero,BaseCurrency,@SysCalExchangerate As ExchangeRate,GSTExCurrency,GSTExchangeRate,@DocType,@DocSubType,@ServCompId,DocNo,0 As IsTax,EntityId,@MasterSystemRefNo As SystemRefNo,
											@BankChargesCurrency,DocDate,DocDate,@MasterRecOrder As RecOrder
									From Bean.Payment Where Id=@SourceId
								End
								-- New Journal For Main ServComp Clearing Payments
								Set @SysRefNumOrder=@SysRefNumOrder+1
								Set @SystemRefNo=Concat(@DocNo,'-JV',@SysRefNumOrder)
								Set @JournalId=NEWID()
								Set @RecOrder=1
								Insert Into Bean.Journal (Id,CompanyId,DocDate,DocType,DocSubType,DocNo,ServiceCompanyId,SystemReferenceNo,IsNoSupportingDocs,NoSupportingDocument,DocCurrency,ExchangeRate,ExCurrency,ExDurationFrom,GSTExchangeRate,GSTExCurrency,
															GSTTotalAmount,DocumentState,IsNoSupportingDocument,IsGstSettings,IsMultiCurrency,IsAllowableNonAllowable,IsGSTCurrencyRateChanged,Remarks,UserCreated,CreatedDate,Status,DocumentDescription,CreationType,
															GrandDocDebitTotal,GrandDocCreditTotal,GrandBaseDebitTotal,GrandBaseCreditTotal,EntityId,EntityType,PostingDate,COAId,ModeOfReceipt,BankReceiptAmmount,ExcessPaidByClientAmmount,BalancingItemReciveCRAmount,
															BalancingItemPayDRAmount,ReceiptApplicationAmmount,DocumentId, BankClearingDate ,IsBalancing,ISAllowDisAllow,IsShow,ActualSysRefNo,IsSegmentReporting, TransferRefNo
										)
								Select @JournalId,@CompanyId,DocDate,@DocType,@DocSubType,DocNo,ServiceCompanyId,@SystemRefNo As SystemRefNo,IsNoSupportingDocument,NoSupportingDocs,DocCurrency,ExchangeRate,ExCurrency,ExDurationFrom,GSTExchangeRate,GSTExCurrency,
										Isnull(GSTTotalAmount,0),DocumentState,NoSupportingDocs,IsGstSettings,IsMultiCurrency,IsAllowableDisallowable,IsGSTCurrencyRateChanged,Remarks,@UserCreated,@CreatedDate,Status,Remarks As DocDescription,@UserCreated,GrandTotal,
										0.00 As GrandDocCreditTotal,Round(GrandTotal * ExchangeRate,2) As GrandBaseDebitTotal,0.00 As GrandBaseCreditTotal,EntityId,EntityType,DocDate As PostingDate,COAId,ModeOfReceipt,0.00 As BankReceiptAmmount,0.00 As ExcessPaidByClientAmmount,
										0.00 As BalancingItemReciveCRAmount,0.00 As BalancingItemPayDRAmount,0.00 As ReceiptApplicationAmmount,Id As DocumentId,BankClearingDate,0 As IsBalancing,IsDisAllow,1 As IsShow,DocNo As ActualSysRefNo,0 As IsSegmentReporting, PaymentRefNo
								From Bean.Payment Where CompanyId=@CompanyId And Id=@SourceId
								-- Journal Details For Main ServComp Clearing Payments
								IF @PaymentAmtTotal Is Not Null And @PaymentAmtTotal>0
								Begin
									Insert Into Bean.JournalDetail (Id,JournalId,COAId,AccountDescription,AllowDisAllow, DocCredit, BaseCredit, DocDebitTotal,DocCreditTotal,BaseDebitTotal,BaseCreditTotal,DocumentId,DocumentDetailId,ItemId,BaseCurrency,ExchangeRate,GSTExCurrency,GSTExchangeRate,DocType,DocSubType,ServiceCompanyId,DocNo, IsTax,
																	EntityId, SystemRefNo, DocCurrency,DocDate, PostingDate,RecOrder )
									Select NEWID(),@JournalId,@ClearingPaymentsCOAID,Remarks,IsDisAllow,ABS(@PaymentAmtTotal),Round(ABS(@PaymentAmtTotal) * @SysCalExchangerate,2),0.00 As DocDebitTotal,0.00 As DocCreditTotal,0.00 As BaseDebitTotal,0.00 As BaseCreditTotal,Id As DocumnetId,@GUIDZero,@GUIDZero,
											BaseCurrency,@SysCalExchangerate As ExchangeRate,GSTExCurrency,GSTExchangeRate,@DocType,@DocSubType,@ServCompId,DocNo,0 As IsTax,
											EntityId,@SystemRefNo As SystemRefNo,@DocCurrency,DocDate,DocDate,@RecOrder As RecOrder
									From Bean.Payment Where Id=@SourceId
								End
								Else IF @PaymentAmtTotal Is Not Null And @PaymentAmtTotal<0
								Begin
									Insert Into Bean.JournalDetail (Id,JournalId,COAId,AccountDescription,AllowDisAllow, DocDebit, BaseDebit, DocDebitTotal,DocCreditTotal,BaseDebitTotal,BaseCreditTotal,DocumentId,DocumentDetailId,ItemId,BaseCurrency,ExchangeRate,GSTExCurrency,GSTExchangeRate,DocType,DocSubType,ServiceCompanyId,DocNo, IsTax,
																	EntityId, SystemRefNo, DocCurrency,DocDate, PostingDate,RecOrder )
									Select NEWID(),@JournalId,@ClearingPaymentsCOAID,Remarks,IsDisAllow,ABS(@PaymentAmtTotal),Round(ABS(@PaymentAmtTotal) * @SysCalExchangerate,2),0.00 As DocDebitTotal,0.00 As DocCreditTotal,0.00 As BaseDebitTotal,0.00 As BaseCreditTotal,Id As DocumnetId,@GUIDZero,@GUIDZero,
											BaseCurrency,@SysCalExchangerate As ExchangeRate,GSTExCurrency,GSTExchangeRate,@DocType,@DocSubType,@ServCompId,DocNo,0 As IsTax,
											EntityId,@SystemRefNo As SystemRefNo,@DocCurrency,DocDate,DocDate,@RecOrder As RecOrder
									From Bean.Payment Where Id=@SourceId
								End
								-- Payment details
								Delete From @PaymentDtl_New
								Insert Into @PaymentDtl_New
								Select ROW_NUMBER() Over (Order By Id),Id From Bean.PaymentDetail 
								Where PaymentId=@SourceId And ServiceCompanyId=@ServCompId And PaymentAmount<>0 And DocumentType Not In (@CreditMemoDocument,@CreditNoteDocument)
								-- Opt : Replaced Set with Select
								Select @DtlCount= Count(*) From @PaymentDtl_New
								Set @RdtlRecCount=1
								While @DtlCount>=@RdtlRecCount
								Begin
									-- Opt : Replaced Set with Select
									Select @PaymentDtlId= PaymentDtlId From @PaymentDtl_New Where S_No=@RdtlRecCount
									Select @DocumentId= DocumentId From Bean.PaymentDetail Where Id=@PaymentDtlId
									Select @OffSetDocumentType= DocumentType From Bean.PaymentDetail Where Id=@PaymentDtlId
									Set @IsRoundingAmount=0
									IF @OffSetDocumentType Not In (@InvoiceDocument,@DebitNoteDocument)
									Begin
										IF Exists (Select Id From Bean.PaymentDetail Where Id=@PaymentDtlId And Nature=@NatureTrade)
										Begin
											-- Opt : Replaced Set with Select
											Select @COAID= Id From Bean.ChartOfAccount Where CompanyId=@CompanyId And Name=@COATradePayables
										End
										Else IF Exists (Select Id From Bean.PaymentDetail Where Id=@PaymentDtlId And Nature=@NatureOthers)
										Begin
											Select @COAID= Id From Bean.ChartOfAccount Where CompanyId=@CompanyId And Name=@COAOtherPayables
										End
										-- Opt : Replaced Set with Select
										Select @ExchangeRate= ExchangeRate From Bean.Bill Where Id=@DocumentId
										IF Exists (Select Id From Bean.Bill Where Id=@DocumentId And DocumentState In (@FullyApplied,@Fullypaid))
										Begin
											Set @IsRoundingAmount=1
										End
									End
									Else IF @OffSetDocumentType In (@InvoiceDocument,@DebitNoteDocument)
									Begin
										IF Exists (Select Id From Bean.PaymentDetail Where Id=@PaymentDtlId And Nature=@NatureTrade)
										Begin
											-- Opt : Replaced Set with Select
											Select @COAID= Id From Bean.ChartOfAccount Where CompanyId=@CompanyId And Name=@COATradeReceivables
										End
										Else IF Exists (Select Id From Bean.PaymentDetail Where Id=@PaymentDtlId And Nature=@NatureOthers)
										Begin
											-- Opt : Replaced Set with Select
											Select @COAID= Id From Bean.ChartOfAccount Where CompanyId=@CompanyId And Name=@COAotherReceivables
										End
										IF @OffSetDocumentType=@InvoiceDocument
										Begin
											-- Opt : Replaced Set with Select
											Select @ExchangeRate= ExchangeRate From Bean.Invoice Where Id=@DocumentId
											IF Exists (Select Id From Bean.Invoice Where Id=@DocumentId And DocumentState In (@FullyApplied,@Fullypaid))
											Begin
												Set @IsRoundingAmount=1
											End
										End
										Else IF @OffSetDocumentType=@DebitNoteDocument
										Begin
											-- Opt : Replaced Set with Select
											Select @ExchangeRate= ExchangeRate From Bean.DebitNote Where Id=@DocumentId
											IF Exists (Select Id From Bean.DebitNote Where Id=@DocumentId And DocumentState In (@FullyApplied,@Fullypaid))
											Begin
												Set @IsRoundingAmount=1
											End
										End
									End
									IF @IsRoundingAmount=1 And Exists (Select Amount From @RoundingAmountDetails Where DocumentId=@DocumentId And Amount Is Not Null And Amount<>'') --And @RoundingAmount Is Not Null And @RoundingAmount <>''
									Begin
										-- Opt : Replaced Set with Select
										Select @DocAmount= Amount From @RoundingAmountDetails Where DocumentId=@DocumentId
									End
									Else
									Begin
										Set @DocAmount=0
									End
									IF @OffSetDocumentType Not In (@InvoiceDocument,@DebitNoteDocument)
									Begin
										Set @RecOrder=@RecOrder+1
										Insert Into Bean.JournalDetail (Id,JournalId,COAId,AccountDescription, DocDebit,DocCredit,BaseDebit,BaseCredit,DocDebitTotal,DocCreditTotal,BaseDebitTotal,BaseCreditTotal,
																		DocumentId,DocumentDetailId,ItemId,BaseCurrency,ExchangeRate, DocType,DocSubType,ServiceCompanyId,DocNo,Nature,OffsetDocument,IsTax,EntityId,
																		SystemRefNo, DocCurrency,DocDate, PostingDate,RecOrder 
																		)
										Select NEWID(),@JournalId,@COAID,P.Remarks,PD.PaymentAmount As DocDebit,Null As DocCredit,
											Round(PD.PaymentAmount * @ExchangeRate,2)-Isnull(@DocAmount,0) As BaseDebit,Null As BaseCredit,
											0.00 As DocDebitTotal,0.00 As DocCreditTotal,0.00 As BaseDebitTotal,0.00 As BaseCreditTotal,P.Id As DocumnetId,PD.Id As DocumentDetailId,@GUIDZero,
											P.BaseCurrency,@ExchangeRate As ExchangeRate,@DocType,@DocSubType,PD.ServiceCompanyId,P.DocNo,PD.Nature,Null As DocumentNo,0 As IsTax,
											P.EntityId,@SystemRefNo,@DocCurrency,P.DocDate,P.DocDate,@RecOrder As RecOrder
										From Bean.Payment As P
										Inner Join bean.PaymentDetail As PD On PD.PaymentId=P.Id
										Where P.Id=@SourceId And PD.Id=@PaymentDtlId
										IF @SysCalExchangerate-@ExchangeRate<>0
										Begin
											-- Exchangegain or Loss
											-- Opt : Replaced Set with Select
											Select @COAID= Id From Bean.ChartOfAccount Where CompanyId=@CompanyId And Name=@ExchangeGainOrLossRealised
											Set @RecOrder=@RecOrder+1
											Insert Into Bean.JournalDetail (Id,JournalId,COAId,AccountDescription, DocDebit,DocCredit,
																			 BaseDebit,BaseCredit,
																			 DocDebitTotal,DocCreditTotal,BaseDebitTotal,BaseCreditTotal,DocumentId,DocumentDetailId,ItemId,BaseCurrency,ExchangeRate,
																			 DocType,DocSubType,ServiceCompanyId,DocNo,Nature,OffsetDocument,IsTax,EntityId, SystemRefNo, DocCurrency,DocDate, PostingDate,RecOrder 
																			)
											Select NEWID(),@JournalId,@COAID,P.Remarks,Null As DocDebit,Null As DocCredit,
												Case When (@SysCalExchangerate-@ExchangeRate)>0 Then ABS(Round((@SysCalExchangerate-@ExchangeRate)  * PD.PaymentAmount,2)) End As BaseDebit,Case When (@SysCalExchangerate-@ExchangeRate)<0 Then ABS(Round((@SysCalExchangerate-@ExchangeRate) * PD.PaymentAmount,2) ) End As BaseCredit,
												0.00 As DocDebitTotal,0.00 As DocCreditTotal,0.00 As BaseDebitTotal,0.00 As BaseCreditTotal,P.Id As DocumnetId,PD.Id As DocumentDetailId,@GUIDZero,
												P.BaseCurrency,P.ExchangeRate,@DocType,@DocSubType,PD.ServiceCompanyId,P.DocNo,PD.Nature,PD.DocumentNo,0 As IsTax,
												EntityId,@SystemRefNo,@DocCurrency,DocDate,DocDate,@RecOrder As RecOrder
											From Bean.Payment As P
											Inner Join bean.PaymentDetail As PD On PD.PaymentId=P.Id
											Where P.Id=@SourceId And PD.Id=@PaymentDtlId
										End
									End
									Else
									Begin
										Set @RecOrder=@RecOrder+1
										Insert Into Bean.JournalDetail (Id,JournalId,COAId,AccountDescription, DocDebit,DocCredit,BaseDebit,BaseCredit,DocDebitTotal,DocCreditTotal,BaseDebitTotal,BaseCreditTotal,DocumentId,
																		DocumentDetailId,ItemId,BaseCurrency,ExchangeRate,DocType,DocSubType,ServiceCompanyId,DocNo,Nature,OffsetDocument,IsTax,EntityId, SystemRefNo, DocCurrency,DocDate, PostingDate,RecOrder 
																		)
										Select NEWID(),@JournalId,@COAID,P.Remarks,Null As DocDebit,PD.PaymentAmount As DocCredit,Null As BaseDebit,Round(PD.PaymentAmount * @ExchangeRate,2)-Isnull(@DocAmount,0) As BaseCredit,0.00 As DocDebitTotal,0.00 As DocCreditTotal,
												0.00 As BaseDebitTotal,0.00 As BaseCreditTotal,P.Id As DocumnetId,PD.Id As DocumentDetailId,@GUIDZero,P.BaseCurrency,@ExchangeRate As ExchangeRate,@DocType,@DocSubType,PD.ServiceCompanyId,P.DocNo,PD.Nature,
												Null As DocumentNo,0 As IsTax,P.EntityId,@SystemRefNo,@DocCurrency,P.DocDate,P.DocDate,@RecOrder As RecOrder
										From Bean.Payment As P
										Inner Join bean.PaymentDetail As PD On PD.PaymentId=P.Id
										Where P.Id=@SourceId And PD.Id=@PaymentDtlId
										IF @SysCalExchangerate-@ExchangeRate<>0
										Begin
											-- Exchangegain or Loss
											-- Opt : Replaced Set with Select
											Select @COAID= Id From Bean.ChartOfAccount Where CompanyId=@CompanyId And Name=@ExchangeGainOrLossRealised
											Set @RecOrder=@RecOrder+1
											Insert Into Bean.JournalDetail (Id,JournalId,COAId,AccountDescription, DocDebit,DocCredit,BaseDebit,BaseCredit,DocDebitTotal,DocCreditTotal,BaseDebitTotal,BaseCreditTotal,DocumentId,DocumentDetailId,ItemId,BaseCurrency,
																			ExchangeRate, DocType,DocSubType,ServiceCompanyId,DocNo,Nature,OffsetDocument,IsTax,EntityId, SystemRefNo, DocCurrency,DocDate, PostingDate,RecOrder 
																			)
											Select NEWID(),@JournalId,@COAID,P.Remarks,Null As DocDebit,Null As DocCredit,
												Case When (@SysCalExchangerate-@ExchangeRate)<0 Then ABS(Round((@SysCalExchangerate-@ExchangeRate)  * PD.PaymentAmount,2)) End As BaseDebit,Case When (@SysCalExchangerate-@ExchangeRate)>0 Then ABS(Round((@SysCalExchangerate-@ExchangeRate) * PD.PaymentAmount,2) ) End As BaseCredit,
												0.00 As DocDebitTotal,0.00 As DocCreditTotal,0.00 As BaseDebitTotal,0.00 As BaseCreditTotal,P.Id As DocumnetId,PD.Id As DocumentDetailId,@GUIDZero,
												P.BaseCurrency,P.ExchangeRate,@DocType,@DocSubType,PD.ServiceCompanyId,P.DocNo,PD.Nature,PD.DocumentNo,0 As IsTax,
												EntityId,@SystemRefNo,@DocCurrency,DocDate,DocDate,@RecOrder As RecOrder
											From Bean.Payment As P
											Inner Join bean.PaymentDetail As PD On PD.PaymentId=P.Id
											Where P.Id=@SourceId And PD.Id=@PaymentDtlId
										End
									End
									Set @RdtlRecCount=@RdtlRecCount+1
								End
							End
						End
						Else
						Begin
							-- Opt : Replaced Set with Select
							Select @IntroCompCOAID= COA.Id 
							From Bean.ChartOfAccount As COA 
							Inner Join Bean.AccountType As ACT On ACT.Id=COA.AccountTypeId
							Where ACT.CompanyId=@CompanyId And ACT.Name=@IntercompClearingCOAName And COA.SubsidaryCompanyId=@ServCompId
												
							IF Exists (Select Id From Bean.PaymentDetail Where PaymentId=@SourceId And ServiceCompanyId=@ServCompId And PaymentAmount<>0 And DocumentType Not In (@CreditMemoDocument,@CreditNoteDocument))
							Begin
								-- Opt : Replaced Set with Select
								Select @ClearingPaymentInvOrDNAmount= Sum(Isnull(PaymentAmount,0)) From Bean.PaymentDetail Where PaymentId=@SourceId And ServiceCompanyId=@ServCompId And DocumentType In (@InvoiceDocument,@DebitNoteDocument)
								Select @ClearingPaymentBillAmount= Sum(Isnull(PaymentAmount,0)) From Bean.PaymentDetail Where PaymentId=@SourceId And ServiceCompanyId=@ServCompId And DocumentType Not In (@InvoiceDocument,@DebitNoteDocument,@CreditMemoDocument,@CreditNoteDocument)
								Set @PaymentAmtTotal=(ISnull(@ClearingPaymentBillAmount,0)-Isnull(@ClearingPaymentInvOrDNAmount,0))
								/* Creating Mater record In JournalDetail */
								
								IF @PaymentAmtTotal Is Not Null And @PaymentAmtTotal>0
								Begin
									Set @MasterRecOrder=@MasterRecOrder+1
									Insert Into Bean.JournalDetail (Id,JournalId,COAId,AccountDescription,AllowDisAllow, DocDebit, BaseDebit, DocDebitTotal,DocCreditTotal,BaseDebitTotal,BaseCreditTotal,DocumentId,DocumentDetailId,ItemId,BaseCurrency,ExchangeRate,GSTExCurrency,GSTExchangeRate,DocType,DocSubType,ServiceCompanyId,DocNo, IsTax,
																	EntityId, SystemRefNo, DocCurrency,DocDate, PostingDate,RecOrder )
									Select NEWID(),@MasterJournalId,@IntroCompCOAID,Remarks,IsDisAllow,Round((ABS(@PaymentAmtTotal) * @SysCalExchangerate)/@DefaultExchangeRate,2) ,Round(ABS(@PaymentAmtTotal) * @SysCalExchangerate,2),0.00 As DocDebitTotal,0.00 As DocCreditTotal,0.00 As BaseDebitTotal,0.00 As BaseCreditTotal,Id As DocumnetId,@GUIDZero,@GUIDZero,
											BaseCurrency,@SysCalExchangerate As ExchangeRate,GSTExCurrency,GSTExchangeRate,@DocType,@DocSubType,@ServCompId,DocNo,0 As IsTax,
											EntityId,@MasterSystemRefNo As SystemRefNo,@BankChargesCurrency,DocDate,DocDate,@MasterRecOrder As RecOrder
									From Bean.Payment Where Id=@SourceId
								End
								Else IF @PaymentAmtTotal Is Not Null And @PaymentAmtTotal<0
								Begin
									Set @MasterRecOrder=@MasterRecOrder+1
									Insert Into Bean.JournalDetail (Id,JournalId,COAId,AccountDescription,AllowDisAllow, DocCredit, BaseCredit, DocDebitTotal,DocCreditTotal,BaseDebitTotal,BaseCreditTotal,DocumentId,DocumentDetailId,ItemId,BaseCurrency,ExchangeRate,GSTExCurrency,GSTExchangeRate,DocType,DocSubType,ServiceCompanyId,DocNo, IsTax,
																	EntityId, SystemRefNo, DocCurrency,DocDate, PostingDate,RecOrder )
									Select NEWID(),@MasterJournalId,@IntroCompCOAID,Remarks,IsDisAllow,Round((ABS(@PaymentAmtTotal) * @SysCalExchangerate)/@DefaultExchangeRate,2) ,Round(ABS(@PaymentAmtTotal) * @SysCalExchangerate,2),0.00 As DocDebitTotal,0.00 As DocCreditTotal,0.00 As BaseDebitTotal,0.00 As BaseCreditTotal,Id As DocumnetId,@GUIDZero,@GUIDZero,
											BaseCurrency,@SysCalExchangerate As ExchangeRate,GSTExCurrency,GSTExchangeRate,@DocType,@DocSubType,@ServCompId,DocNo,0 As IsTax,
											EntityId,@MasterSystemRefNo As SystemRefNo,@BankChargesCurrency,DocDate,DocDate,@MasterRecOrder As RecOrder
									From Bean.Payment Where Id=@SourceId
								End
								-- New Journal For ServComp Clearing Payments Master
								Set @SysRefNumOrder=@SysRefNumOrder+1
								Set @SystemRefNo=Concat(@DocNo,'-JV',@SysRefNumOrder)
								Set @JournalId=NEWID()
								Insert Into Bean.Journal (Id,CompanyId,DocDate,DocType,DocSubType,DocNo,ServiceCompanyId,SystemReferenceNo,IsNoSupportingDocs,NoSupportingDocument,DocCurrency,ExchangeRate,ExCurrency,ExDurationFrom,GSTExchangeRate,GSTExCurrency,GSTTotalAmount,DocumentState,IsNoSupportingDocument,IsGstSettings,IsMultiCurrency,IsAllowableNonAllowable,IsGSTCurrencyRateChanged,Remarks,UserCreated,CreatedDate,Status,DocumentDescription,CreationType,GrandDocDebitTotal,GrandDocCreditTotal,GrandBaseDebitTotal,
														 GrandBaseCreditTotal,EntityId,EntityType,PostingDate,COAId,ModeOfReceipt,BankReceiptAmmount,ExcessPaidByClientAmmount,BalancingItemReciveCRAmount,  BalancingItemPayDRAmount,ReceiptApplicationAmmount,DocumentId,BankClearingDate ,IsBalancing,ISAllowDisAllow, IsShow, ActualSysRefNo,IsSegmentReporting, TransferRefNo
														 )
								Select @JournalId,@CompanyId,DocDate,@DocType,@DocSubType,DocNo,@ServCompId,@SystemRefNo As SystemRefNo,IsNoSupportingDocument,NoSupportingDocs,DocCurrency,ExchangeRate,ExCurrency,ExDurationFrom,GSTExchangeRate,GSTExCurrency,Isnull(GSTTotalAmount,0),DocumentState,NoSupportingDocs,IsGstSettings,IsMultiCurrency,IsAllowableDisallowable,IsGSTCurrencyRateChanged,Remarks,@UserCreated,@CreatedDate,Status,Remarks As DocDescription,@UserCreated,GrandTotal,0.00 As GrandDocCreditTotal,Round(GrandTotal * ExchangeRate,2) As GrandBaseDebitTotal,
										0.00 As GrandBaseCreditTotal,EntityId,EntityType,DocDate As PostingDate,COAId,ModeOfReceipt,0.00 As BankReceiptAmmount,0.00 As ExcessPaidByClientAmmount,0.00 As BalancingItemReciveCRAmount,0.00 As BalancingItemPayDRAmount,0.00 As ReceiptApplicationAmmount,Id As DocumentId,BankClearingDate,0 As IsBalancing,IsDisAllow,1 As IsShow,DocNo As ActualSysRefNo,0 As IsSegmentReporting, PaymentRefNo
								From Bean.Payment Where CompanyId=@CompanyId And Id=@SourceId
								-- Journal Details For ServComp Clearing Payments Master
								IF @PaymentAmtTotal Is Not Null And @PaymentAmtTotal>0
								Begin
									Set @RecOrder=@RecOrder+1
									Insert Into Bean.JournalDetail (Id,JournalId,COAId,AccountDescription,AllowDisAllow, DocCredit, BaseCredit, DocDebitTotal,DocCreditTotal,BaseDebitTotal,BaseCreditTotal,DocumentId,DocumentDetailId,ItemId,BaseCurrency,ExchangeRate,
																	GSTExCurrency,GSTExchangeRate,DocType,DocSubType,ServiceCompanyId,DocNo, IsTax,EntityId, SystemRefNo, DocCurrency,DocDate, PostingDate,RecOrder )
									Select NEWID(),@JournalId,@MainInterCoServCompCOAID,Remarks,IsDisAllow,Round((ABS(@PaymentAmtTotal) * @SysCalExchangerate)/@DefaultExchangeRate,2),Round(((ABS(@PaymentAmtTotal) * @SysCalExchangerate)/@DefaultExchangeRate) * @DefaultExchangeRate,2),0.00 As DocDebitTotal,0.00 As DocCreditTotal,0.00 As BaseDebitTotal,0.00 As BaseCreditTotal,Id As DocumnetId,@GUIDZero,@GUIDZero,
											BaseCurrency,@SysCalExchangerate As ExchangeRate,GSTExCurrency,GSTExchangeRate,@DocType,@DocSubType,@ServCompId,DocNo,0 As IsTax,
											EntityId,@SystemRefNo As SystemRefNo,@BankChargesCurrency,DocDate,DocDate,@RecOrder As RecOrder
									From Bean.Payment Where Id=@SourceId
									-- Journal Details For ServComp Clearing Payments Master Clearing Payments
									Set @RecOrder=@RecOrder+1
									Insert Into Bean.JournalDetail (Id,JournalId,COAId,AccountDescription,AllowDisAllow, DocDebit, BaseDebit, DocDebitTotal,DocCreditTotal,BaseDebitTotal,BaseCreditTotal,DocumentId,DocumentDetailId,ItemId,BaseCurrency,ExchangeRate,GSTExCurrency,GSTExchangeRate,DocType,DocSubType,ServiceCompanyId,DocNo, IsTax,
																	EntityId, SystemRefNo, DocCurrency,DocDate, PostingDate,RecOrder )
									Select NEWID(),@JournalId,@ClearingPaymentsCOAID,Remarks,IsDisAllow,Round((ABS(@PaymentAmtTotal) * @SysCalExchangerate)/@DefaultExchangeRate,2),Round((ABS(@PaymentAmtTotal) * @SysCalExchangerate),2),0.00 As DocDebitTotal,0.00 As DocCreditTotal,0.00 As BaseDebitTotal,0.00 As BaseCreditTotal,Id As DocumnetId,@GUIDZero,@GUIDZero,
											BaseCurrency,@SysCalExchangerate As ExchangeRate,GSTExCurrency,GSTExchangeRate,@DocType,@DocSubType,@ServCompId,DocNo,0 As IsTax,
											EntityId,@SystemRefNo As SystemRefNo,@BankChargesCurrency,DocDate,DocDate,@RecOrder As RecOrder
									From Bean.Payment Where Id=@SourceId
								End
								Else IF @PaymentAmtTotal Is Not Null And @PaymentAmtTotal<0
								Begin
									Set @RecOrder=@RecOrder+1
									Insert Into Bean.JournalDetail (Id,JournalId,COAId,AccountDescription,AllowDisAllow, DocDebit, BaseDebit, DocDebitTotal,DocCreditTotal,BaseDebitTotal,BaseCreditTotal,DocumentId,DocumentDetailId,ItemId,BaseCurrency,ExchangeRate,
																	GSTExCurrency,GSTExchangeRate,DocType,DocSubType,ServiceCompanyId,DocNo, IsTax,EntityId, SystemRefNo, DocCurrency,DocDate, PostingDate,RecOrder )
									Select NEWID(),@JournalId,@MainInterCoServCompCOAID,Remarks,IsDisAllow,Round((ABS(@PaymentAmtTotal) * @SysCalExchangerate)/@DefaultExchangeRate,2),Round(((ABS(@PaymentAmtTotal) * @SysCalExchangerate)/@DefaultExchangeRate) * @DefaultExchangeRate,2),0.00 As DocDebitTotal,0.00 As DocCreditTotal,0.00 As BaseDebitTotal,0.00 As BaseCreditTotal,Id As DocumnetId,@GUIDZero,@GUIDZero,
											BaseCurrency,@SysCalExchangerate As ExchangeRate,GSTExCurrency,GSTExchangeRate,@DocType,@DocSubType,@ServCompId,DocNo,0 As IsTax,
											EntityId,@SystemRefNo As SystemRefNo,@BankChargesCurrency,DocDate,DocDate,@RecOrder As RecOrder
									From Bean.Payment Where Id=@SourceId
									-- Journal Details For ServComp Clearing Payments Master Clearing Payments
									Set @RecOrder=@RecOrder+1
									Insert Into Bean.JournalDetail (Id,JournalId,COAId,AccountDescription,AllowDisAllow, DocCredit, BaseCredit, DocDebitTotal,DocCreditTotal,BaseDebitTotal,BaseCreditTotal,DocumentId,DocumentDetailId,ItemId,BaseCurrency,ExchangeRate,GSTExCurrency,GSTExchangeRate,DocType,DocSubType,ServiceCompanyId,DocNo, IsTax,
																	EntityId, SystemRefNo, DocCurrency,DocDate, PostingDate,RecOrder )
									Select NEWID(),@JournalId,@ClearingPaymentsCOAID,Remarks,IsDisAllow,Round((ABS(@PaymentAmtTotal) * @SysCalExchangerate)/@DefaultExchangeRate,2),Round((ABS(@PaymentAmtTotal) * @SysCalExchangerate),2),0.00 As DocDebitTotal,0.00 As DocCreditTotal,0.00 As BaseDebitTotal,0.00 As BaseCreditTotal,Id As DocumnetId,@GUIDZero,@GUIDZero,
											BaseCurrency,@SysCalExchangerate As ExchangeRate,GSTExCurrency,GSTExchangeRate,@DocType,@DocSubType,@ServCompId,DocNo,0 As IsTax,
											EntityId,@SystemRefNo As SystemRefNo,@BankChargesCurrency,DocDate,DocDate,@RecOrder As RecOrder
									From Bean.Payment Where Id=@SourceId
								End
								-- New Journal For ServComp Clearing Payments
								Set @SysRefNumOrder=@SysRefNumOrder+1
								Set @SystemRefNo=Concat(@DocNo,'-JV',@SysRefNumOrder)
								Set @JournalId=NEWID()
								Insert Into Bean.Journal (Id,CompanyId,DocDate,DocType,DocSubType,DocNo,ServiceCompanyId,SystemReferenceNo,IsNoSupportingDocs,NoSupportingDocument,DocCurrency,ExchangeRate,ExCurrency,ExDurationFrom,GSTExchangeRate,GSTExCurrency,GSTTotalAmount,DocumentState,IsNoSupportingDocument,IsGstSettings,IsMultiCurrency,IsAllowableNonAllowable,IsGSTCurrencyRateChanged,Remarks,UserCreated,CreatedDate,Status,DocumentDescription,CreationType,GrandDocDebitTotal,GrandDocCreditTotal,GrandBaseDebitTotal,
														 GrandBaseCreditTotal,EntityId,EntityType,PostingDate,COAId,ModeOfReceipt,BankReceiptAmmount,ExcessPaidByClientAmmount,BalancingItemReciveCRAmount,  BalancingItemPayDRAmount,ReceiptApplicationAmmount,DocumentId, BankClearingDate ,IsBalancing,ISAllowDisAllow, IsShow, ActualSysRefNo,IsSegmentReporting, TransferRefNo
														 )
								Select @JournalId,@CompanyId,DocDate,@DocType,@DocSubType,DocNo,@ServCompId,@SystemRefNo As SystemRefNo,IsNoSupportingDocument,NoSupportingDocs,DocCurrency,ExchangeRate,ExCurrency,ExDurationFrom,GSTExchangeRate,GSTExCurrency,Isnull(GSTTotalAmount,0),DocumentState,NoSupportingDocs,IsGstSettings,IsMultiCurrency,IsAllowableDisallowable,IsGSTCurrencyRateChanged,Remarks,@UserCreated,@CreatedDate,Status,Remarks As DocDescription,@UserCreated,GrandTotal,0.00 As GrandDocCreditTotal,Round(GrandTotal * ExchangeRate,2) As GrandBaseDebitTotal,
										0.00 As GrandBaseCreditTotal,EntityId,EntityType,DocDate As PostingDate,COAId,ModeOfReceipt,0.00 As BankReceiptAmmount,0.00 As ExcessPaidByClientAmmount,0.00 As BalancingItemReciveCRAmount,0.00 As BalancingItemPayDRAmount,0.00 As ReceiptApplicationAmmount,Id As DocumentId,BankClearingDate,0 As IsBalancing,IsDisAllow,1 As IsShow,DocNo As ActualSysRefNo,0 As IsSegmentReporting, PaymentRefNo
								From Bean.Payment Where CompanyId=@CompanyId And Id=@SourceId
								-- Journal Details For ServComp Clearing Payments
								IF @PaymentAmtTotal Is Not Null And @PaymentAmtTotal>0
								Begin
									Set @RecOrder=1
									Insert Into Bean.JournalDetail (Id,JournalId,COAId,AccountDescription,AllowDisAllow, DocCredit, BaseCredit, DocDebitTotal,DocCreditTotal,BaseDebitTotal,BaseCreditTotal,DocumentId,DocumentDetailId,ItemId,BaseCurrency,ExchangeRate,GSTExCurrency,GSTExchangeRate,DocType,DocSubType,ServiceCompanyId,DocNo, IsTax,
																	EntityId, SystemRefNo, DocCurrency,DocDate, PostingDate,RecOrder )
									Select NEWID(),@JournalId,@ClearingPaymentsCOAID,Remarks,IsDisAllow,ABS(@PaymentAmtTotal),Round(ABS(@PaymentAmtTotal) * @SysCalExchangerate,2),0.00 As DocDebitTotal,0.00 As DocCreditTotal,0.00 As BaseDebitTotal,0.00 As BaseCreditTotal,Id As DocumnetId,@GUIDZero,@GUIDZero,
											BaseCurrency,@SysCalExchangerate As ExchangeRate,GSTExCurrency,GSTExchangeRate,@DocType,@DocSubType,@ServCompId,DocNo,0 As IsTax,
											EntityId,@SystemRefNo As SystemRefNo,@DocCurrency,DocDate,DocDate,@RecOrder As RecOrder
									From Bean.Payment Where Id=@SourceId
								End
								Else IF @PaymentAmtTotal Is Not Null And @PaymentAmtTotal<0
								Begin
									Set @RecOrder=1
									Insert Into Bean.JournalDetail (Id,JournalId,COAId,AccountDescription,AllowDisAllow, DocDebit, BaseDebit, DocDebitTotal,DocCreditTotal,BaseDebitTotal,BaseCreditTotal,DocumentId,DocumentDetailId,ItemId,BaseCurrency,ExchangeRate,GSTExCurrency,GSTExchangeRate,DocType,DocSubType,ServiceCompanyId,DocNo, IsTax,
																	EntityId, SystemRefNo, DocCurrency,DocDate, PostingDate,RecOrder )
									Select NEWID(),@JournalId,@ClearingPaymentsCOAID,Remarks,IsDisAllow,ABS(@PaymentAmtTotal),Round(ABS(@PaymentAmtTotal) * @SysCalExchangerate,2),0.00 As DocDebitTotal,0.00 As DocCreditTotal,0.00 As BaseDebitTotal,0.00 As BaseCreditTotal,Id As DocumnetId,@GUIDZero,@GUIDZero,
											BaseCurrency,@SysCalExchangerate As ExchangeRate,GSTExCurrency,GSTExchangeRate,@DocType,@DocSubType,@ServCompId,DocNo,0 As IsTax,
											EntityId,@SystemRefNo As SystemRefNo,@DocCurrency,DocDate,DocDate,@RecOrder As RecOrder
									From Bean.Payment Where Id=@SourceId
								End
								-- Payment details
								Delete From @PaymentDtl_New
								Insert Into @PaymentDtl_New
								Select ROW_NUMBER() Over (Order By Id),Id From Bean.PaymentDetail 
								Where PaymentId=@SourceId And ServiceCompanyId=@ServCompId And PaymentAmount<>0 And DocumentType Not In (@CreditMemoDocument,@CreditNoteDocument)
								-- Opt : Replaced Set with Select
								Select @DtlCount= Count(*) From @PaymentDtl_New
								Set @RdtlRecCount=1
								While @DtlCount>=@RdtlRecCount
								Begin
									-- Opt : Replaced Set with Select
									Select @PaymentDtlId= PaymentDtlId From @PaymentDtl_New Where S_No=@RdtlRecCount
									Select @DocumentId= DocumentId From Bean.PaymentDetail Where Id=@PaymentDtlId
									Select @OffSetDocumentType= DocumentType From Bean.PaymentDetail Where Id=@PaymentDtlId
									Set @IsRoundingAmount=0
									IF @OffSetDocumentType Not In (@InvoiceDocument,@DebitNoteDocument)
									Begin
										IF Exists (Select Id From Bean.PaymentDetail Where Id=@PaymentDtlId And Nature=@NatureTrade)
										Begin
											-- Opt : Replaced Set with Select
											Select @COAID= Id From Bean.ChartOfAccount Where CompanyId=@CompanyId And Name=@COATradePayables
										End
										Else IF Exists (Select Id From Bean.PaymentDetail Where Id=@PaymentDtlId And Nature=@NatureOthers)
										Begin
											-- Opt : Replaced Set with Select
											Select @COAID= Id From Bean.ChartOfAccount Where CompanyId=@CompanyId And Name=@COAOtherPayables
										End
										IF Exists (Select Id From Bean.Bill Where Id=@DocumentId And DocumentState In (@FullyApplied,@Fullypaid))
										Begin
											Set @IsRoundingAmount=1
										End
										-- Opt : Replaced Set with Select
										Select @ExchangeRate= ExchangeRate From Bean.Bill Where Id=@DocumentId
									End
									Else IF @OffSetDocumentType In (@InvoiceDocument,@DebitNoteDocument)
									Begin
										IF Exists (Select Id From Bean.PaymentDetail Where Id=@PaymentDtlId And Nature=@NatureTrade)
										Begin
											-- Opt : Replaced Set with Select
											Select @COAID= Id From Bean.ChartOfAccount Where CompanyId=@CompanyId And Name=@COATradeReceivables
										End
										Else IF Exists (Select Id From Bean.PaymentDetail Where Id=@PaymentDtlId And Nature=@NatureOthers)
										Begin
											-- Opt : Replaced Set with Select
											Select @COAID= Id From Bean.ChartOfAccount Where CompanyId=@CompanyId And Name=@COAotherReceivables
										End
										IF @OffSetDocumentType=@InvoiceDocument
										Begin
											IF Exists (Select Id From Bean.Invoice Where Id=@DocumentId And DocumentState In (@FullyApplied,@Fullypaid))
											Begin
												Set @IsRoundingAmount=1
											End
											-- Opt : Replaced Set with Select
											Select @ExchangeRate= ExchangeRate From Bean.Invoice Where Id=@DocumentId
										End
										Else IF @OffSetDocumentType=@DebitNoteDocument
										Begin
											IF Exists (Select Id From Bean.DebitNote Where Id=@DocumentId And DocumentState In (@FullyApplied,@Fullypaid))
											Begin
												Set @IsRoundingAmount=1
											End
											-- Opt : Replaced Set with Select
											Select @ExchangeRate= ExchangeRate From Bean.DebitNote Where Id=@DocumentId
										End
									End
									IF @IsRoundingAmount=1 And Exists (Select Amount From @RoundingAmountDetails Where DocumentId=@DocumentId And Amount Is Not Null And Amount<>'') -- And @RoundingAmount Is Not Null And @RoundingAmount <>''
									Begin
										-- Opt : Replaced Set with Select
										Select @DocAmount= Amount From @RoundingAmountDetails Where DocumentId=@DocumentId
									End
									Else
									Begin
										Set @DocAmount=0
									End

									Set @RecOrder=@RecOrder+1
									IF @OffSetDocumentType Not In (@InvoiceDocument,@DebitNoteDocument)
									Begin
										Insert Into Bean.JournalDetail (Id,JournalId,COAId,AccountDescription, DocDebit,DocCredit,
																		 BaseDebit,BaseCredit,
																		 DocDebitTotal,DocCreditTotal,BaseDebitTotal,BaseCreditTotal,DocumentId,DocumentDetailId,ItemId,BaseCurrency,ExchangeRate, DocType,DocSubType,ServiceCompanyId,DocNo,Nature,OffsetDocument,IsTax,
																		EntityId, SystemRefNo, DocCurrency,DocDate, PostingDate,RecOrder 
																		)
										Select NEWID(),@JournalId,@COAID,P.Remarks,PD.PaymentAmount As DocDebit,Null As DocCredit,
											Round(PD.PaymentAmount * @ExchangeRate,2)-Isnull(@DocAmount,0) As BaseDebit,Null As BaseCredit,
											0.00 As DocDebitTotal,0.00 As DocCreditTotal,0.00 As BaseDebitTotal,0.00 As BaseCreditTotal,P.Id As DocumnetId,PD.Id As DocumentDetailId,@GUIDZero,
											P.BaseCurrency,@ExchangeRate As ExchangeRate,@DocType,@DocSubType,PD.ServiceCompanyId,P.DocNo,PD.Nature,Null As DocumentNo,0 As IsTax,
											P.EntityId,@SystemRefNo,@DocCurrency,P.DocDate,P.DocDate,@RecOrder As RecOrder
										From Bean.Payment As P
										Inner Join bean.PaymentDetail As PD On PD.PaymentId=P.Id
										Where P.Id=@SourceId And PD.Id=@PaymentDtlId
										IF @SysCalExchangerate-@ExchangeRate<>0
										Begin
											-- Exchangegain or Loss
											-- Opt : Replaced Set with Select
											Select @COAID= Id From Bean.ChartOfAccount Where CompanyId=@CompanyId And Name=@ExchangeGainOrLossRealised
											Set @RecOrder=@RecOrder+1
											Insert Into Bean.JournalDetail (Id,JournalId,COAId,AccountDescription, DocDebit,DocCredit,BaseDebit,BaseCredit,DocDebitTotal,DocCreditTotal,BaseDebitTotal,BaseCreditTotal,
																			DocumentId,DocumentDetailId,ItemId,BaseCurrency,ExchangeRate, DocType,DocSubType,ServiceCompanyId,DocNo,Nature,OffsetDocument,IsTax,
																			EntityId, SystemRefNo, DocCurrency,DocDate, PostingDate,RecOrder 
																			)
											Select NEWID(),@JournalId,@COAID,P.Remarks,Null As DocDebit,Null As DocCredit,
												Case When (@SysCalExchangerate-@ExchangeRate)>0 Then ABS(Round((@SysCalExchangerate-@ExchangeRate)  * PD.PaymentAmount,2)) End As BaseDebit,Case When (@SysCalExchangerate-@ExchangeRate)<0 Then ABS(Round((@SysCalExchangerate-@ExchangeRate) * PD.PaymentAmount,2) ) End As BaseCredit,
												0.00 As DocDebitTotal,0.00 As DocCreditTotal,0.00 As BaseDebitTotal,0.00 As BaseCreditTotal,P.Id As DocumnetId,PD.Id As DocumentDetailId,@GUIDZero,
												P.BaseCurrency,P.ExchangeRate,@DocType,@DocSubType,PD.ServiceCompanyId,P.DocNo,PD.Nature,PD.DocumentNo,0 As IsTax,
												EntityId,@SystemRefNo,@DocCurrency,DocDate,DocDate,@RecOrder As RecOrder
											From Bean.Payment As P
											Inner Join bean.PaymentDetail As PD On PD.PaymentId=P.Id
											Where P.Id=@SourceId And PD.Id=@PaymentDtlId
										End
									End
									Else IF @OffSetDocumentType In (@InvoiceDocument,@DebitNoteDocument)
									Begin
										Insert Into Bean.JournalDetail (Id,JournalId,COAId,AccountDescription, DocDebit,DocCredit,
																		 BaseDebit,BaseCredit,
																		 DocDebitTotal,DocCreditTotal,BaseDebitTotal,BaseCreditTotal,DocumentId,DocumentDetailId,ItemId,BaseCurrency,ExchangeRate, DocType,DocSubType,ServiceCompanyId,DocNo,Nature,OffsetDocument,IsTax,
																		EntityId, SystemRefNo, DocCurrency,DocDate, PostingDate,RecOrder
																		)
										Select NEWID(),@JournalId,@COAID,P.Remarks,Null As DocDebit,PD.PaymentAmount As DocCredit,
											Null As BaseDebit,Round(PD.PaymentAmount * @ExchangeRate,2)-Isnull(@DocAmount,0) As BaseCredit,
											0.00 As DocDebitTotal,0.00 As DocCreditTotal,0.00 As BaseDebitTotal,0.00 As BaseCreditTotal,P.Id As DocumnetId,PD.Id As DocumentDetailId,@GUIDZero,
											P.BaseCurrency,@ExchangeRate As ExchangeRate,@DocType,@DocSubType,PD.ServiceCompanyId,P.DocNo,PD.Nature,Null As DocumentNo,0 As IsTax,
											P.EntityId,@SystemRefNo,@DocCurrency,P.DocDate,P.DocDate,@RecOrder As RecOrder
										From Bean.Payment As P
										Inner Join bean.PaymentDetail As PD On PD.PaymentId=P.Id
										Where P.Id=@SourceId And PD.Id=@PaymentDtlId
										IF @SysCalExchangerate-@ExchangeRate<>0
										Begin
											-- Exchangegain or Loss
											-- Opt : Replaced Set with Select
											Select @COAID= Id From Bean.ChartOfAccount Where CompanyId=@CompanyId And Name=@ExchangeGainOrLossRealised
											Set @RecOrder=@RecOrder+1
											Insert Into Bean.JournalDetail (Id,JournalId,COAId,AccountDescription, DocDebit,DocCredit,BaseDebit,BaseCredit,DocDebitTotal,DocCreditTotal,BaseDebitTotal,BaseCreditTotal,DocumentId,DocumentDetailId,ItemId,
																			BaseCurrency,ExchangeRate, DocType,DocSubType,ServiceCompanyId,DocNo,Nature,OffsetDocument,IsTax,EntityId, SystemRefNo, DocCurrency,DocDate, PostingDate,RecOrder
																			)
											Select NEWID(),@JournalId,@COAID,P.Remarks,Null As DocDebit,Null As DocCredit,Case When (@SysCalExchangerate-@ExchangeRate)<0 Then ABS(Round((@SysCalExchangerate-@ExchangeRate)  * PD.PaymentAmount,2)) End As BaseDebit,
													Case When (@SysCalExchangerate-@ExchangeRate)>0 Then ABS(Round((@SysCalExchangerate-@ExchangeRate) * PD.PaymentAmount,2) ) End As BaseCredit,0.00 As DocDebitTotal,0.00 As DocCreditTotal,0.00 As BaseDebitTotal,
													0.00 As BaseCreditTotal,P.Id As DocumnetId,PD.Id As DocumentDetailId,@GUIDZero,P.BaseCurrency,P.ExchangeRate,@DocType,@DocSubType,PD.ServiceCompanyId,P.DocNo,PD.Nature,PD.DocumentNo,0 As IsTax,
													EntityId,@SystemRefNo,@DocCurrency,DocDate,DocDate,@RecOrder As RecOrder
											From Bean.Payment As P
											Inner Join bean.PaymentDetail As PD On PD.PaymentId=P.Id
											Where P.Id=@SourceId And PD.Id=@PaymentDtlId
										End
									End
									Set @RdtlRecCount=@RdtlRecCount+1
								End
							End
							
							IF Exists (Select Id From Bean.PaymentDetail Where PaymentId=@SourceId And ServiceCompanyId=@ServCompId And PaymentAmount<>0 And DocumentType = @CreditNoteDocument)
							Begin
								-- Opt : Replaced Set with Select
								Select @PaymentAmtTotal= Sum(Isnull(PaymentAmount,0)) From Bean.PaymentDetail Where PaymentId=@SourceId And ServiceCompanyId=@ServCompId And DocumentType = @CreditNoteDocument
								/* Creating Credit Note record In JournalDetail */
								Set @MasterRecOrder=@MasterRecOrder+1
								Insert Into Bean.JournalDetail (Id,JournalId,COAId,AccountDescription,AllowDisAllow, DocDebit, BaseDebit, DocDebitTotal,DocCreditTotal,BaseDebitTotal,BaseCreditTotal,DocumentId,DocumentDetailId,ItemId,BaseCurrency,ExchangeRate,GSTExCurrency,GSTExchangeRate,DocType,DocSubType,ServiceCompanyId,DocNo, IsTax,
																EntityId, SystemRefNo, DocCurrency,DocDate, PostingDate,RecOrder )
								Select NEWID(),@MasterJournalId,@IntroCompCOAID,Remarks,IsDisAllow,Round((@PaymentAmtTotal * @SysCalExchangerate)/@DefaultExchangeRate,2) ,Round(@PaymentAmtTotal * @SysCalExchangerate,2),0.00 As DocDebitTotal,0.00 As DocCreditTotal,0.00 As BaseDebitTotal,0.00 As BaseCreditTotal,Id As DocumnetId,@GUIDZero,@GUIDZero,
										BaseCurrency,@SysCalExchangerate As ExchangeRate,GSTExCurrency,GSTExchangeRate,@DocType,@DocSubType,@ServCompId,DocNo,0 As IsTax,
										EntityId,@MasterSystemRefNo As SystemRefNo,@BankChargesCurrency,DocDate,DocDate,@MasterRecOrder As RecOrder
								From Bean.Payment Where Id=@SourceId
								-- New Journal For ServComp Clearing Payments Master
								Set @SysRefNumOrder=@SysRefNumOrder+1
								Set @SystemRefNo=Concat(@DocNo,'-JV',@SysRefNumOrder)
								Set @JournalId=NEWID()
								Insert Into Bean.Journal (Id,CompanyId,DocDate,DocType,DocSubType,DocNo,ServiceCompanyId,SystemReferenceNo,IsNoSupportingDocs,NoSupportingDocument,DocCurrency,ExchangeRate,ExCurrency,ExDurationFrom,GSTExchangeRate,GSTExCurrency,GSTTotalAmount,DocumentState,IsNoSupportingDocument,IsGstSettings,IsMultiCurrency,IsAllowableNonAllowable,IsGSTCurrencyRateChanged,Remarks,UserCreated,CreatedDate,Status,DocumentDescription,CreationType,GrandDocDebitTotal,GrandDocCreditTotal,GrandBaseDebitTotal,
														 GrandBaseCreditTotal,EntityId,EntityType,PostingDate,COAId,ModeOfReceipt,BankReceiptAmmount,ExcessPaidByClientAmmount,BalancingItemReciveCRAmount,  BalancingItemPayDRAmount,ReceiptApplicationAmmount,DocumentId, BankClearingDate ,IsBalancing,ISAllowDisAllow, IsShow, ActualSysRefNo,IsSegmentReporting, TransferRefNo
														 )
								Select @JournalId,@CompanyId,DocDate,@DocType,@DocSubType,DocNo,@ServCompId,@SystemRefNo As SystemRefNo,IsNoSupportingDocument,NoSupportingDocs,DocCurrency,ExchangeRate,ExCurrency,ExDurationFrom,GSTExchangeRate,GSTExCurrency,Isnull(GSTTotalAmount,0),DocumentState,NoSupportingDocs,IsGstSettings,IsMultiCurrency,IsAllowableDisallowable,IsGSTCurrencyRateChanged,Remarks,@UserCreated,@CreatedDate,Status,Remarks As DocDescription,@UserCreated,GrandTotal,0.00 As GrandDocCreditTotal,Round(GrandTotal * ExchangeRate,2) As GrandBaseDebitTotal,
										0.00 As GrandBaseCreditTotal,EntityId,EntityType,DocDate As PostingDate,COAId,ModeOfReceipt,0.00 As BankReceiptAmmount,0.00 As ExcessPaidByClientAmmount,0.00 As BalancingItemReciveCRAmount,0.00 As BalancingItemPayDRAmount,0.00 As ReceiptApplicationAmmount,Id As DocumentId,BankClearingDate,0 As IsBalancing,IsDisAllow,1 As IsShow,DocNo As ActualSysRefNo,0 As IsSegmentReporting, PaymentRefNo
								From Bean.Payment Where CompanyId=@CompanyId And Id=@SourceId
								-- Journal Details For ServComp Clearing Payments Master
								Set @MasterRecOrder=@MasterRecOrder+1
								Insert Into Bean.JournalDetail (Id,JournalId,COAId,AccountDescription,AllowDisAllow, DocCredit, BaseCredit, DocDebitTotal,DocCreditTotal,BaseDebitTotal,BaseCreditTotal,DocumentId,DocumentDetailId,ItemId,BaseCurrency,ExchangeRate,GSTExCurrency,GSTExchangeRate,DocType,DocSubType,ServiceCompanyId,DocNo, IsTax,
																EntityId, SystemRefNo, DocCurrency,DocDate, PostingDate,RecOrder )
								Select NEWID(),@JournalId,@MainInterCoServCompCOAID,Remarks,IsDisAllow,Round((@PaymentAmtTotal * @SysCalExchangerate)/@DefaultExchangeRate,2),Round(((@PaymentAmtTotal * @SysCalExchangerate)/@DefaultExchangeRate) * @DefaultExchangeRate,2),0.00 As DocDebitTotal,0.00 As DocCreditTotal,0.00 As BaseDebitTotal,0.00 As BaseCreditTotal,Id As DocumnetId,@GUIDZero,@GUIDZero,
										BaseCurrency,@SysCalExchangerate As ExchangeRate,GSTExCurrency,GSTExchangeRate,@DocType,@DocSubType,@ServCompId,DocNo,0 As IsTax,
										EntityId,@SystemRefNo As SystemRefNo,@BankChargesCurrency,DocDate,DocDate,@MasterRecOrder As RecOrder
								From Bean.Payment Where Id=@SourceId
								-- Journal Details For ServComp Clearing Payments detail
								Set @RecOrder=@RecOrder+1
								Insert Into Bean.JournalDetail (Id,JournalId,COAId,AccountDescription,AllowDisAllow, DocDebit, BaseDebit, DocDebitTotal,DocCreditTotal,BaseDebitTotal,BaseCreditTotal,DocumentId,DocumentDetailId,ItemId,BaseCurrency,ExchangeRate,GSTExCurrency,GSTExchangeRate,DocType,DocSubType,ServiceCompanyId,DocNo, IsTax,
																EntityId, SystemRefNo, DocCurrency,DocDate, PostingDate,RecOrder )
								Select NEWID(),@JournalId,@ClearingPaymentsCOAID,Remarks,IsDisAllow,Round((@PaymentAmtTotal * @SysCalExchangerate)/@DefaultExchangeRate,2),Round(((@PaymentAmtTotal * @SysCalExchangerate)/@DefaultExchangeRate) * @DefaultExchangeRate,2),0.00 As DocDebitTotal,0.00 As DocCreditTotal,0.00 As BaseDebitTotal,0.00 As BaseCreditTotal,Id As DocumnetId,@GUIDZero,@GUIDZero,
										BaseCurrency,@SysCalExchangerate As ExchangeRate,GSTExCurrency,GSTExchangeRate,@DocType,@DocSubType,@ServCompId,DocNo,0 As IsTax,
										EntityId,@SystemRefNo As SystemRefNo,@BankChargesCurrency,DocDate,DocDate,@RecOrder As RecOrder
								From Bean.Payment Where Id=@SourceId
							End
							IF Exists (Select Id From Bean.PaymentDetail Where PaymentId=@SourceId And ServiceCompanyId=@ServCompId And PaymentAmount<>0 And DocumentType = @CreditMemoDocument)
							Begin
								-- Opt : Replaced Set with Select
								Select @PaymentAmtTotal= Sum(Isnull(PaymentAmount,0)) From Bean.PaymentDetail Where PaymentId=@SourceId And ServiceCompanyId=@ServCompId And DocumentType = @CreditMemoDocument
								/* Creating Credit Note record In JournalDetail */
								Set @MasterRecOrder=@MasterRecOrder+1
								Insert Into Bean.JournalDetail (Id,JournalId,COAId,AccountDescription,AllowDisAllow, DocCredit, BaseCredit, DocDebitTotal,DocCreditTotal,BaseDebitTotal,BaseCreditTotal,DocumentId,DocumentDetailId,ItemId,BaseCurrency,ExchangeRate,GSTExCurrency,GSTExchangeRate,DocType,DocSubType,ServiceCompanyId,DocNo, IsTax,
																EntityId, SystemRefNo, DocCurrency,DocDate, PostingDate,RecOrder )
								Select NEWID(),@MasterJournalId,@IntroCompCOAID,Remarks,IsDisAllow,Round((@PaymentAmtTotal * @SysCalExchangerate)/@DefaultExchangeRate,2) ,Round(@PaymentAmtTotal * @SysCalExchangerate,2),0.00 As DocDebitTotal,0.00 As DocCreditTotal,0.00 As BaseDebitTotal,0.00 As BaseCreditTotal,Id As DocumnetId,@GUIDZero,@GUIDZero,
										BaseCurrency,@SysCalExchangerate As ExchangeRate,GSTExCurrency,GSTExchangeRate,@DocType,@DocSubType,@ServCompId,DocNo,0 As IsTax,
										EntityId,@MasterSystemRefNo As SystemRefNo,@BankChargesCurrency,DocDate,DocDate,@MasterRecOrder As RecOrder
								From Bean.Payment Where Id=@SourceId
								-- New Journal For ServComp Clearing Payments Master
								Set @SysRefNumOrder=@SysRefNumOrder+1
								Set @SystemRefNo=Concat(@DocNo,'-JV',@SysRefNumOrder)
								Set @JournalId=NEWID()
								Insert Into Bean.Journal (Id,CompanyId,DocDate,DocType,DocSubType,DocNo,ServiceCompanyId,SystemReferenceNo,IsNoSupportingDocs,NoSupportingDocument,DocCurrency,ExchangeRate,ExCurrency,ExDurationFrom,GSTExchangeRate,GSTExCurrency,GSTTotalAmount,DocumentState,IsNoSupportingDocument,IsGstSettings,IsMultiCurrency,IsAllowableNonAllowable,IsGSTCurrencyRateChanged,Remarks,UserCreated,CreatedDate,Status,DocumentDescription,CreationType,GrandDocDebitTotal,GrandDocCreditTotal,GrandBaseDebitTotal,
														 GrandBaseCreditTotal,EntityId,EntityType,PostingDate,COAId,ModeOfReceipt,BankReceiptAmmount,ExcessPaidByClientAmmount,BalancingItemReciveCRAmount,  BalancingItemPayDRAmount,ReceiptApplicationAmmount,DocumentId, BankClearingDate ,IsBalancing,ISAllowDisAllow, IsShow, ActualSysRefNo,IsSegmentReporting, TransferRefNo
														 )
								Select @JournalId,@CompanyId,DocDate,@DocType,@DocSubType,DocNo,@ServCompId,@SystemRefNo As SystemRefNo,IsNoSupportingDocument,NoSupportingDocs,DocCurrency,ExchangeRate,ExCurrency,ExDurationFrom,GSTExchangeRate,GSTExCurrency,Isnull(GSTTotalAmount,0),DocumentState,NoSupportingDocs,IsGstSettings,IsMultiCurrency,IsAllowableDisallowable,IsGSTCurrencyRateChanged,Remarks,@UserCreated,@CreatedDate,Status,Remarks As DocDescription,@UserCreated,GrandTotal,0.00 As GrandDocCreditTotal,Round(GrandTotal * ExchangeRate,2) As GrandBaseDebitTotal,
										0.00 As GrandBaseCreditTotal,EntityId,EntityType,DocDate As PostingDate,COAId,ModeOfReceipt,0.00 As BankReceiptAmmount,0.00 As ExcessPaidByClientAmmount,0.00 As BalancingItemReciveCRAmount,0.00 As BalancingItemPayDRAmount,0.00 As ReceiptApplicationAmmount,Id As DocumentId,BankClearingDate,0 As IsBalancing,IsDisAllow,1 As IsShow,DocNo As ActualSysRefNo,0 As IsSegmentReporting, PaymentRefNo
								From Bean.Payment Where CompanyId=@CompanyId And Id=@SourceId
								-- Journal Details For ServComp Clearing Payments Master
								Set @RecOrder=@RecOrder+1
								Insert Into Bean.JournalDetail (Id,JournalId,COAId,AccountDescription,AllowDisAllow, DocDebit, BaseDebit, DocDebitTotal,DocCreditTotal,BaseDebitTotal,BaseCreditTotal,DocumentId,DocumentDetailId,ItemId,BaseCurrency,ExchangeRate,GSTExCurrency,GSTExchangeRate,DocType,DocSubType,ServiceCompanyId,DocNo, IsTax,
																EntityId, SystemRefNo, DocCurrency,DocDate, PostingDate,RecOrder )
								Select NEWID(),@JournalId,@MainInterCoServCompCOAID,Remarks,IsDisAllow,Round((@PaymentAmtTotal * @SysCalExchangerate)/@DefaultExchangeRate,2),Round(((@PaymentAmtTotal * @SysCalExchangerate)/@DefaultExchangeRate) * @DefaultExchangeRate,2),0.00 As DocDebitTotal,0.00 As DocCreditTotal,0.00 As BaseDebitTotal,0.00 As BaseCreditTotal,Id As DocumnetId,@GUIDZero,@GUIDZero,
										BaseCurrency,@SysCalExchangerate As ExchangeRate,GSTExCurrency,GSTExchangeRate,@DocType,@DocSubType,@ServCompId,DocNo,0 As IsTax,
										EntityId,@SystemRefNo As SystemRefNo,@BankChargesCurrency,DocDate,DocDate,@RecOrder As RecOrder
								From Bean.Payment Where Id=@SourceId
								-- Journal Details For ServComp Clearing Payments detail
								Set @RecOrder=@RecOrder+1
								Insert Into Bean.JournalDetail (Id,JournalId,COAId,AccountDescription,AllowDisAllow, DocCredit, BaseCredit, DocDebitTotal,DocCreditTotal,BaseDebitTotal,BaseCreditTotal,DocumentId,DocumentDetailId,ItemId,BaseCurrency,ExchangeRate,GSTExCurrency,GSTExchangeRate,DocType,DocSubType,ServiceCompanyId,DocNo, IsTax,
																EntityId, SystemRefNo, DocCurrency,DocDate, PostingDate,RecOrder )
								Select NEWID(),@JournalId,@ClearingPaymentsCOAID,Remarks,IsDisAllow,Round((@PaymentAmtTotal * @SysCalExchangerate)/@DefaultExchangeRate,2),Round(((@PaymentAmtTotal * @SysCalExchangerate)/@DefaultExchangeRate) * @DefaultExchangeRate,2),0.00 As DocDebitTotal,0.00 As DocCreditTotal,0.00 As BaseDebitTotal,0.00 As BaseCreditTotal,Id As DocumnetId,@GUIDZero,@GUIDZero,
										BaseCurrency,@SysCalExchangerate As ExchangeRate,GSTExCurrency,GSTExchangeRate,@DocType,@DocSubType,@ServCompId,DocNo,0 As IsTax,
										EntityId,@SystemRefNo As SystemRefNo,@BankChargesCurrency,DocDate,DocDate,@RecOrder As RecOrder
								From Bean.Payment Where Id=@SourceId
							End

						End
						Set @RecCount=@RecCount+1
					End
				End
			End
			-- Payment Offset Single Company
			Else IF @IsCustomer=1 Or @PaymentOffSet>=1
			Begin
				Set @MasterJournalId=NEWID()
				Set @MasterSystemRefNo=Concat(@DocNo,'-JV',@SysRefNumOrder)
				Insert Into Bean.Journal (Id,CompanyId,DocDate,DocType,DocSubType,DocNo,ServiceCompanyId,SystemReferenceNo,IsNoSupportingDocs,NoSupportingDocument,DocCurrency,ExchangeRate,ExCurrency,ExDurationFrom,GSTExchangeRate,GSTExCurrency,GSTTotalAmount,DocumentState,IsNoSupportingDocument,IsGstSettings,IsMultiCurrency,
											IsAllowableNonAllowable,IsGSTCurrencyRateChanged,Remarks,UserCreated,CreatedDate,Status,DocumentDescription,CreationType,GrandDocDebitTotal,GrandDocCreditTotal,GrandBaseDebitTotal,GrandBaseCreditTotal,EntityId,EntityType,PostingDate,COAId,ModeOfReceipt,BankReceiptAmmount,
											ExcessPaidByClientAmmount,BalancingItemReciveCRAmount,  BalancingItemPayDRAmount,ReceiptApplicationAmmount,DocumentId, BankClearingDate ,IsBalancing,ISAllowDisAllow, IsShow, ActualSysRefNo ,IsSegmentReporting, TransferRefNo
										)
				Select @MasterJournalId,@CompanyId,DocDate,@DocType,@DocSubType,DocNo,ServiceCompanyId,@MasterSystemRefNo As SystemRefNo,IsNoSupportingDocument,NoSupportingDocs,DocCurrency,ExchangeRate,ExCurrency,ExDurationFrom,GSTExchangeRate,GSTExCurrency,Isnull(GSTTotalAmount,0),DocumentState,NoSupportingDocs,IsGstSettings,IsMultiCurrency,IsAllowableDisallowable,IsGSTCurrencyRateChanged,Remarks,@UserCreated,@CreatedDate,Status,Remarks As DocDescription,@UserCreated,GrandTotal,0.00 As GrandDocCreditTotal,Round(GrandTotal * ExchangeRate,2) As GrandBaseDebitTotal,
						0.00 As GrandBaseCreditTotal,EntityId,EntityType,DocDate As PostingDate,COAId,ModeOfReceipt,0.00 As BankReceiptAmmount,0.00 As ExcessPaidByClientAmmount,0.00 As BalancingItemReciveCRAmount,0.00 As BalancingItemPayDRAmount,0.00 As ReceiptApplicationAmmount,Id As DocumentId,BankClearingDate,0 As IsBalancing,IsDisAllow,1 As IsShow,DocNo As ActualSysRefNo,0 As IsSegmentReporting, PaymentRefNo
				From Bean.Payment Where CompanyId=@CompanyId And Id=@SourceId
				IF @DocCurrency=@BankChargesCurrency And @BaseCurrency=@DocCurrency
				Begin
					/* Creating Mater record In JournalDetail */
					Insert Into Bean.JournalDetail (Id,JournalId,COAId,AccountDescription,AllowDisAllow, DocCredit, BaseCredit, DocDebitTotal,DocCreditTotal,BaseDebitTotal,BaseCreditTotal,DocumentId,DocumentDetailId,ItemId,BaseCurrency,ExchangeRate,GSTExCurrency,GSTExchangeRate,DocType,DocSubType,
													ServiceCompanyId,DocNo, IsTax,EntityId, SystemRefNo, DocCurrency,DocDate, PostingDate,RecOrder )
					Select NEWID(),@MasterJournalId,COAId,Remarks,IsDisAllow,GrandTotal,Round(GrandTotal * @DefaultExchangeRate,2),0.00 As DocDebitTotal,0.00 As DocCreditTotal,0.00 As BaseDebitTotal,0.00 As BaseCreditTotal,Id As DocumnetId,@GUIDZero,@GUIDZero,
							BaseCurrency,@DefaultExchangeRate As ExchangeRate,GSTExCurrency,GSTExchangeRate,@DocType,@DocSubType,ServiceCompanyId,DocNo,0 As IsTax,
							EntityId,@MasterSystemRefNo As SystemRefNo,@BankChargesCurrency,DocDate,DocDate,@MasterRecOrder As RecOrder
					From Bean.Payment Where Id=@SourceId
					IF Exists(Select Id From Bean.PaymentDetail Where PaymentId=@SourceId And PaymentAmount<>0)
					Begin
						Insert Into @PaymentDtl
						Select Id From Bean.PaymentDetail Where PaymentId=@SourceId And PaymentAmount<>0
						Set @RecCount=1
						-- Opt : Replaced Set with Select
						Select @Count= Count(*) From @PaymentDtl
						While @Count>=@RecCount
						Begin
							-- Opt : Replaced Set with Select
							Select @PaymentDtlId= PaymentDtlId From @PaymentDtl Where S_No=@RecCount
							Set @IsRoundingAmount=0
							-- Opt : Replaced Set with Select
							Select @DocumentId= DocumentId From Bean.PaymentDetail Where Id=@PaymentDtlId
							IF Exists (Select Id From Bean.PaymentDetail Where Id=@PaymentDtlId And Nature=@NatureTrade And DocumentType =@InvoiceDocument)
							Begin
								-- Opt : Replaced Set with Select
								Select @COAID= Id From Bean.ChartOfAccount Where CompanyId=@CompanyId And Name=@COATradeReceivables
								IF Exists (Select Id From Bean.Invoice Where Id=@DocumentId And DocumentState In (@FullyApplied,@Fullypaid))
								Begin
									Set @IsRoundingAmount=1
								End
							End
							Else IF Exists (Select Id From Bean.PaymentDetail Where Id=@PaymentDtlId And Nature=@NatureOthers And DocumentType =@InvoiceDocument)
							Begin
								-- Opt : Replaced Set with Select
								Select @COAID= Id From Bean.ChartOfAccount Where CompanyId=@CompanyId And Name=@COAotherReceivables
								IF Exists (Select Id From Bean.Invoice Where Id=@DocumentId And DocumentState In (@FullyApplied,@Fullypaid))
								Begin
									Set @IsRoundingAmount=1
								End
							End
							Else IF Exists (Select Id From Bean.PaymentDetail Where Id=@PaymentDtlId And Nature=@NatureTrade And DocumentType =@DebitNoteDocument)
							Begin
								-- Opt : Replaced Set with Select
								Select @COAID= Id From Bean.ChartOfAccount Where CompanyId=@CompanyId And Name=@COATradeReceivables
								IF Exists (Select Id From Bean.DebitNote Where Id=@DocumentId And DocumentState In (@FullyApplied,@Fullypaid))
								Begin
									Set @IsRoundingAmount=1
								End
							End
							Else IF Exists (Select Id From Bean.PaymentDetail Where Id=@PaymentDtlId And Nature=@NatureOthers And DocumentType =@DebitNoteDocument)
							Begin
								-- Opt : Replaced Set with Select
								Select @COAID= Id From Bean.ChartOfAccount Where CompanyId=@CompanyId And Name=@COAotherReceivables
								IF Exists (Select Id From Bean.DebitNote Where Id=@DocumentId And DocumentState In (@FullyApplied,@Fullypaid))
								Begin
									Set @IsRoundingAmount=1
								End
							End
							Else IF Exists (Select Id From Bean.PaymentDetail Where Id=@PaymentDtlId And Nature=@NatureTrade And DocumentType Not In (@InvoiceDocument,@DebitNoteDocument,@CreditNoteDocument,@CreditMemoDocument))
							Begin
								-- Opt : Replaced Set with Select
								Select @COAID= Id From Bean.ChartOfAccount Where CompanyId=@CompanyId And Name=@COATradePayables
								IF Exists (Select Id From Bean.Bill Where Id=@DocumentId And DocumentState In (@FullyApplied,@Fullypaid))
								Begin
									Set @IsRoundingAmount=1
								End
							End
							Else IF Exists (Select Id From Bean.PaymentDetail Where Id=@PaymentDtlId And Nature=@NatureOthers And DocumentType Not In (@InvoiceDocument,@DebitNoteDocument,@CreditNoteDocument,@CreditMemoDocument))
							Begin
								-- Opt : Replaced Set with Select
								Select @COAID= Id From Bean.ChartOfAccount Where CompanyId=@CompanyId And Name=@COAOtherPayables
								IF Exists (Select Id From Bean.Bill Where Id=@DocumentId And DocumentState In (@FullyApplied,@Fullypaid))
								Begin
									Set @IsRoundingAmount=1
								End
							End
							IF @IsRoundingAmount=1 And Exists (Select Amount From @RoundingAmountDetails Where DocumentId=@DocumentId And Amount Is Not Null And Amount<>'') -- And @RoundingAmount Is Not Null And @RoundingAmount <>''
							Begin
								-- Opt : Replaced Set with Select
								Select @DocAmount= Amount From @RoundingAmountDetails Where DocumentId=@DocumentId
							End
							Else
							Begin
								Set @DocAmount=0
							End
							-- Opt : Replaced Set with Select
							Select @OffSetDocumentType= DocumentType From Bean.PaymentDetail Where Id=@PaymentDtlId
							Set @MasterRecOrder=@MasterRecOrder+1
							IF @OffSetDocumentType=@InvoiceDocument Or @OffSetDocumentType=@DebitNoteDocument
							Begin
								Insert Into Bean.JournalDetail (Id,JournalId,COAId,AccountDescription, DocDebit,DocCredit,BaseDebit,BaseCredit,DocDebitTotal,DocCreditTotal,BaseDebitTotal,BaseCreditTotal,DocumentId,DocumentDetailId,ItemId,BaseCurrency,ExchangeRate,
																DocType,DocSubType,ServiceCompanyId,DocNo,Nature,OffsetDocument,IsTax,EntityId, SystemRefNo, DocCurrency,DocDate, PostingDate,RecOrder 
																)
								Select NEWID(),@MasterJournalId,@COAID,P.Remarks,Null As DocDebit,PD.PaymentAmount As DocCredit,Null As BaseDebit,Round(PD.PaymentAmount * @DefaultExchangeRate,2)-Isnull(@DocAmount,0) As BaseCredit,
									0.00 As DocDebitTotal,0.00 As DocCreditTotal,0.00 As BaseDebitTotal,0.00 As BaseCreditTotal,P.Id As DocumnetId,PD.Id As DocumentDetailId,@GUIDZero,P.BaseCurrency,@DefaultExchangeRate As ExchangeRate,
									@DocType,@DocSubType,PD.ServiceCompanyId,P.DocNo,PD.Nature,Null As DocumentNo,0 As IsTax,P.EntityId,@MasterSystemRefNo,@BankChargesCurrency,P.DocDate,P.DocDate,@MasterRecOrder As RecOrder
								From Bean.Payment As P
								Inner Join bean.PaymentDetail As PD On PD.PaymentId=P.Id
								Where P.Id=@SourceId And PD.Id=@PaymentDtlId
							End
							Else IF @OffSetDocumentType=@CreditNoteDocument
							Begin
								Insert Into Bean.JournalDetail (Id,JournalId,COAId,AccountDescription, DocDebit,DocCredit,BaseDebit,BaseCredit,DocDebitTotal,DocCreditTotal,BaseDebitTotal,BaseCreditTotal,DocumentId,DocumentDetailId,ItemId,
																BaseCurrency,ExchangeRate, DocType,DocSubType,ServiceCompanyId,DocNo,Nature,OffsetDocument,IsTax,EntityId, SystemRefNo, DocCurrency,DocDate, PostingDate,RecOrder 
																)
								Select NEWID(),@MasterJournalId,@ClearingPaymentsCOAID,P.Remarks,PD.PaymentAmount As DocDebit,Null As DocCredit,
									Round(PD.PaymentAmount * @DefaultExchangeRate,2) As BaseDebit,Null As BaseCredit,
									0.00 As DocDebitTotal,0.00 As DocCreditTotal,0.00 As BaseDebitTotal,0.00 As BaseCreditTotal,P.Id As DocumnetId,PD.Id As DocumentDetailId,@GUIDZero,
									P.BaseCurrency,@DefaultExchangeRate As ExchangeRate,@DocType,@DocSubType,PD.ServiceCompanyId,P.DocNo,PD.Nature,Null As DocumentNo,0 As IsTax,
									P.EntityId,@MasterSystemRefNo,@BankChargesCurrency,P.DocDate,P.DocDate,@MasterRecOrder As RecOrder
								From Bean.Payment As P
								Inner Join bean.PaymentDetail As PD On PD.PaymentId=P.Id
								Where P.Id=@SourceId And PD.Id=@PaymentDtlId
							End
							Else IF @OffSetDocumentType=@CreditMemoDocument
							Begin
								Insert Into Bean.JournalDetail (Id,JournalId,COAId,AccountDescription, DocDebit,DocCredit,
																 BaseDebit,BaseCredit,
																 DocDebitTotal,DocCreditTotal,BaseDebitTotal,BaseCreditTotal,DocumentId,DocumentDetailId,ItemId,BaseCurrency,ExchangeRate, 
																 DocType,DocSubType,ServiceCompanyId,DocNo,Nature,OffsetDocument,IsTax,EntityId, SystemRefNo, DocCurrency,DocDate, PostingDate,RecOrder 
																)
								Select NEWID(),@MasterJournalId,@ClearingPaymentsCOAID,P.Remarks,Null As DocDebit,PD.PaymentAmount As DocCredit,
									Null As BaseDebit,Round(PD.PaymentAmount * @DefaultExchangeRate,2) As BaseCredit,
									0.00 As DocDebitTotal,0.00 As DocCreditTotal,0.00 As BaseDebitTotal,0.00 As BaseCreditTotal,P.Id As DocumnetId,PD.Id As DocumentDetailId,@GUIDZero,
									P.BaseCurrency,@DefaultExchangeRate As ExchangeRate,@DocType,@DocSubType,PD.ServiceCompanyId,P.DocNo,PD.Nature,Null As DocumentNo,0 As IsTax,
									P.EntityId,@MasterSystemRefNo,@BankChargesCurrency,P.DocDate,P.DocDate,@MasterRecOrder As RecOrder
								From Bean.Payment As P
								Inner Join bean.PaymentDetail As PD On PD.PaymentId=P.Id
								Where P.Id=@SourceId And PD.Id=@PaymentDtlId
							End
							Else 
							Begin
								Insert Into Bean.JournalDetail (Id,JournalId,COAId,AccountDescription, DocDebit,DocCredit,BaseDebit,BaseCredit,DocDebitTotal,DocCreditTotal,BaseDebitTotal,BaseCreditTotal,
																DocumentId,DocumentDetailId,ItemId,BaseCurrency,ExchangeRate, DocType,DocSubType,ServiceCompanyId,DocNo,Nature,OffsetDocument,IsTax,
																EntityId, SystemRefNo, DocCurrency,DocDate, PostingDate,RecOrder 
																)
								Select NEWID(),@MasterJournalId,@COAID,P.Remarks,PD.PaymentAmount As DocDebit,Null As DocCredit,
									Round(PD.PaymentAmount * @DefaultExchangeRate,2)-Isnull(@DocAmount,0) As BaseDebit,Null As BaseCredit,
									0.00 As DocDebitTotal,0.00 As DocCreditTotal,0.00 As BaseDebitTotal,0.00 As BaseCreditTotal,P.Id As DocumnetId,PD.Id As DocumentDetailId,@GUIDZero,
									P.BaseCurrency,@DefaultExchangeRate As ExchangeRate,@DocType,@DocSubType,PD.ServiceCompanyId,P.DocNo,PD.Nature,Null As DocumentNo,0 As IsTax,
									P.EntityId,@MasterSystemRefNo,@BankChargesCurrency,P.DocDate,P.DocDate,@MasterRecOrder As RecOrder
								From Bean.Payment As P
								Inner Join bean.PaymentDetail As PD On PD.PaymentId=P.Id
								Where P.Id=@SourceId And PD.Id=@PaymentDtlId
							End
							Set @RecCount=@RecCount+1
						End
					End
				End
				Else IF @DocCurrency=@BankChargesCurrency And @BaseCurrency<>@DocCurrency
				Begin
					/* Creating Mater record In JournalDetail */
					Insert Into Bean.JournalDetail (Id,JournalId,COAId,AccountDescription,AllowDisAllow, DocCredit, BaseCredit, DocDebitTotal,DocCreditTotal,BaseDebitTotal,BaseCreditTotal,DocumentId,DocumentDetailId,ItemId,BaseCurrency,
													ExchangeRate,GSTExCurrency,GSTExchangeRate,DocType,DocSubType,ServiceCompanyId,DocNo, IsTax,EntityId, SystemRefNo, DocCurrency,DocDate, PostingDate,RecOrder )
					Select NEWID(),@MasterJournalId,COAId,Remarks,IsDisAllow,GrandTotal,Round(GrandTotal * ExchangeRate,2),0.00 As DocDebitTotal,0.00 As DocCreditTotal,0.00 As BaseDebitTotal,0.00 As BaseCreditTotal,Id As DocumnetId,@GUIDZero,@GUIDZero,
							BaseCurrency,ExchangeRate As ExchangeRate,GSTExCurrency,GSTExchangeRate,@DocType,@DocSubType,ServiceCompanyId,DocNo,0 As IsTax,
							EntityId,@MasterSystemRefNo As SystemRefNo,@BankChargesCurrency,DocDate,DocDate,@MasterRecOrder As RecOrder
					From Bean.Payment Where Id=@SourceId
					IF Exists(Select Id From Bean.PaymentDetail Where PaymentId=@SourceId And PaymentAmount<>0)
					Begin
						Insert Into @PaymentDtl
						Select Id From Bean.PaymentDetail Where PaymentId=@SourceId And PaymentAmount<>0
						Set @RecCount=1
						-- Opt : Replaced Set with Select
						Select @Count= Count(*) From @PaymentDtl
						While @Count>=@RecCount
						Begin
							-- Opt : Replaced Set with Select
							Select @PaymentDtlId= PaymentDtlId From @PaymentDtl Where S_No=@RecCount
							Select @DocumentId= DocumentId From Bean.PaymentDetail Where Id=@PaymentDtlId
							Set @IsRoundingAmount=0
							IF Exists (Select Id From Bean.PaymentDetail Where Id=@PaymentDtlId And Nature=@NatureTrade And DocumentType =@InvoiceDocument)
							Begin
								-- Opt : Replaced Set with Select
								Select @COAID= Id From Bean.ChartOfAccount Where CompanyId=@CompanyId And Name=@COATradeReceivables
								Select @ExchangeRate= ExchangeRate From Bean.Invoice Where Id=@DocumentId
								IF Exists (Select Id From Bean.Invoice Where Id=@DocumentId And DocumentState In (@FullyApplied,@Fullypaid))
								Begin
									Set @IsRoundingAmount=1
								End
							End
							Else IF Exists (Select Id From Bean.PaymentDetail Where Id=@PaymentDtlId And Nature=@NatureOthers And DocumentType=@InvoiceDocument)
							Begin
								-- Opt : Replaced Set with Select
								Select @COAID= Id From Bean.ChartOfAccount Where CompanyId=@CompanyId And Name=@COAotherReceivables
								Select @ExchangeRate= ExchangeRate From Bean.Invoice Where Id=@DocumentId
								IF Exists (Select Id From Bean.Invoice Where Id=@DocumentId And DocumentState In (@FullyApplied,@Fullypaid))
								Begin
									Set @IsRoundingAmount=1
								End
							End
							Else IF Exists (Select Id From Bean.PaymentDetail Where Id=@PaymentDtlId And Nature=@NatureTrade And DocumentType =@DebitNoteDocument)
							Begin
								-- Opt : Replaced Set with Select
								Select @COAID= Id From Bean.ChartOfAccount Where CompanyId=@CompanyId And Name=@COATradeReceivables
								Select @ExchangeRate= ExchangeRate From Bean.DebitNote Where Id=@DocumentId
								IF Exists (Select Id From Bean.DebitNote Where Id=@DocumentId And DocumentState In (@FullyApplied,@Fullypaid))
								Begin
									Set @IsRoundingAmount=1
								End
							End
							Else IF Exists (Select Id From Bean.PaymentDetail Where Id=@PaymentDtlId And Nature=@NatureOthers And DocumentType=@DebitNoteDocument)
							Begin
								-- Opt : Replaced Set with Select
								Select @COAID= Id From Bean.ChartOfAccount Where CompanyId=@CompanyId And Name=@COAotherReceivables
								Select @ExchangeRate= ExchangeRate From Bean.DebitNote Where Id=@DocumentId
								IF Exists (Select Id From Bean.DebitNote Where Id=@DocumentId And DocumentState In (@FullyApplied,@Fullypaid))
								Begin
									Set @IsRoundingAmount=1
								End
							End
							Else IF Exists (Select Id From Bean.PaymentDetail Where Id=@PaymentDtlId And Nature=@NatureTrade And DocumentType Not In (@InvoiceDocument,@DebitNoteDocument,@CreditNoteDocument,@CreditMemoDocument))
							Begin
								-- Opt : Replaced Set with Select
								Select @COAID= Id From Bean.ChartOfAccount Where CompanyId=@CompanyId And Name=@COATradePayables
								Select @ExchangeRate= ExchangeRate From Bean.Bill Where Id=@DocumentId
								IF Exists (Select Id From Bean.Bill Where Id=@DocumentId And DocumentState In (@FullyApplied,@Fullypaid))
								Begin
									Set @IsRoundingAmount=1
								End
							End
							Else IF Exists (Select Id From Bean.PaymentDetail Where Id=@PaymentDtlId And Nature=@NatureOthers And DocumentType Not In (@InvoiceDocument,@DebitNoteDocument,@CreditNoteDocument,@CreditMemoDocument))
							Begin
								-- Opt : Replaced Set with Select
								Select @COAID= Id From Bean.ChartOfAccount Where CompanyId=@CompanyId And Name=@COAOtherPayables
								Select @ExchangeRate= ExchangeRate From Bean.Bill Where Id=@DocumentId
								IF Exists (Select Id From Bean.Bill Where Id=@DocumentId And DocumentState In (@FullyApplied,@Fullypaid))
								Begin
									Set @IsRoundingAmount=1
								End
							End
							IF @IsRoundingAmount=1 And Exists (Select Amount From @RoundingAmountDetails Where DocumentId=@DocumentId And Amount Is Not Null And Amount<>'') --And @RoundingAmount Is Not Null And @RoundingAmount <>''
							Begin
								-- Opt : Replaced Set with Select
								Select @DocAmount= Amount From @RoundingAmountDetails Where DocumentId=@DocumentId
							End
							Else
							Begin
								Set @DocAmount=0
							End
							-- Opt : Replaced Set with Select
							Select @OffSetDocumentType= DocumentType From Bean.PaymentDetail Where Id=@PaymentDtlId
							Set @MasterRecOrder=@MasterRecOrder+1
							IF @OffSetDocumentType=@InvoiceDocument Or @OffSetDocumentType=@DebitNoteDocument
							Begin
								Insert Into Bean.JournalDetail (Id,JournalId,COAId,AccountDescription, DocDebit,DocCredit,
																 BaseDebit,BaseCredit,
																 DocDebitTotal,DocCreditTotal,BaseDebitTotal,BaseCreditTotal,DocumentId,DocumentDetailId,ItemId,BaseCurrency,ExchangeRate,
																 DocType,DocSubType,ServiceCompanyId,DocNo,Nature,OffsetDocument,IsTax,EntityId, SystemRefNo, DocCurrency,DocDate, PostingDate,RecOrder 
																)
								Select NEWID(),@MasterJournalId,@COAID,P.Remarks,Null As DocDebit,PD.PaymentAmount As DocCredit,
									Null As BaseDebit,Round(PD.PaymentAmount * @ExchangeRate,2)-Isnull(@DocAmount,0) As BaseCredit,
									0.00 As DocDebitTotal,0.00 As DocCreditTotal,0.00 As BaseDebitTotal,0.00 As BaseCreditTotal,P.Id As DocumnetId,PD.Id As DocumentDetailId,@GUIDZero,
									P.BaseCurrency,@ExchangeRate As ExchangeRate,@DocType,@DocSubType,PD.ServiceCompanyId,P.DocNo,PD.Nature,Null As DocumentNo,0 As IsTax,
									P.EntityId,@MasterSystemRefNo,@BankChargesCurrency,P.DocDate,P.DocDate,@MasterRecOrder As RecOrder
								From Bean.Payment As P
								Inner Join bean.PaymentDetail As PD On PD.PaymentId=P.Id
								Where P.Id=@SourceId And PD.Id=@PaymentDtlId
								-- Exchangegain or Loss
								IF @MainExchangeRate-@ExchangeRate<>0
								Begin
									-- Opt : Replaced Set with Select
									Select @COAID= Id From Bean.ChartOfAccount Where CompanyId=@CompanyId And Name=@ExchangeGainOrLossRealised
									Set @MasterRecOrder=@MasterRecOrder+1
									Insert Into Bean.JournalDetail (Id,JournalId,COAId,AccountDescription, DocDebit,DocCredit,BaseDebit,BaseCredit,
																	 DocDebitTotal,DocCreditTotal,BaseDebitTotal,BaseCreditTotal,DocumentId,DocumentDetailId,ItemId,BaseCurrency,ExchangeRate,
																	 DocType,DocSubType,ServiceCompanyId,DocNo,Nature,OffsetDocument,IsTax,EntityId, SystemRefNo, DocCurrency,DocDate, PostingDate,RecOrder 
																	)
									Select NEWID(),@MasterJournalId,@COAID,P.Remarks,Null As DocDebit,Null As DocCredit,
										Case When (@MainExchangeRate-@ExchangeRate)<0 Then ABS(Round((@MainExchangeRate-@ExchangeRate)  * PD.PaymentAmount,2)) End As BaseDebit,Case When (@MainExchangeRate-@ExchangeRate)>0 Then ABS(Round((@MainExchangeRate-@ExchangeRate) * PD.PaymentAmount,2) ) End As BaseCredit,
										0.00 As DocDebitTotal,0.00 As DocCreditTotal,0.00 As BaseDebitTotal,0.00 As BaseCreditTotal,P.Id As DocumnetId,PD.Id As DocumentDetailId,@GUIDZero,
										P.BaseCurrency,P.ExchangeRate,@DocType,@DocSubType,PD.ServiceCompanyId,P.DocNo,PD.Nature,PD.DocumentNo,0 As IsTax,
										EntityId,@MasterSystemRefNo,@BankChargesCurrency,DocDate,DocDate,@MasterRecOrder As RecOrder
									From Bean.Payment As P
									Inner Join bean.PaymentDetail As PD On PD.PaymentId=P.Id
									Where P.Id=@SourceId And PD.Id=@PaymentDtlId
								End
							End
							Else IF @OffSetDocumentType=@CreditNoteDocument
							Begin
								Insert Into Bean.JournalDetail (Id,JournalId,COAId,AccountDescription, DocDebit,DocCredit,
																 BaseDebit,BaseCredit,
																 DocDebitTotal,DocCreditTotal,BaseDebitTotal,BaseCreditTotal,DocumentId,DocumentDetailId,ItemId,BaseCurrency,ExchangeRate, 
																 DocType,DocSubType,ServiceCompanyId,DocNo,Nature,OffsetDocument,IsTax,EntityId,SystemRefNo,DocCurrency,DocDate,PostingDate,RecOrder 
																)
								Select NEWID(),@MasterJournalId,@ClearingPaymentsCOAID,P.Remarks,PD.PaymentAmount As DocDebit,Null As DocCredit,
									Round(PD.PaymentAmount * @MainExchangeRate,2) As BaseDebit,Null As BaseCredit,
									0.00 As DocDebitTotal,0.00 As DocCreditTotal,0.00 As BaseDebitTotal,0.00 As BaseCreditTotal,P.Id As DocumnetId,PD.Id As DocumentDetailId,@GUIDZero,
									P.BaseCurrency,@DefaultExchangeRate As ExchangeRate,@DocType,@DocSubType,PD.ServiceCompanyId,P.DocNo,PD.Nature,Null As DocumentNo,0 As IsTax,
									P.EntityId,@MasterSystemRefNo,@BankChargesCurrency,P.DocDate,P.DocDate,@MasterRecOrder As RecOrder
								From Bean.Payment As P
								Inner Join bean.PaymentDetail As PD On PD.PaymentId=P.Id
								Where P.Id=@SourceId And PD.Id=@PaymentDtlId
							End
							Else IF @OffSetDocumentType=@CreditMemoDocument
							Begin
								Insert Into Bean.JournalDetail (Id,JournalId,COAId,AccountDescription, DocDebit,DocCredit,
																 BaseDebit,BaseCredit,
																 DocDebitTotal,DocCreditTotal,BaseDebitTotal,BaseCreditTotal,DocumentId,DocumentDetailId,ItemId,BaseCurrency,ExchangeRate,
																 DocType,DocSubType,ServiceCompanyId,DocNo,Nature,OffsetDocument,IsTax,EntityId, SystemRefNo, DocCurrency,DocDate, PostingDate,RecOrder 
																)
								Select NEWID(),@MasterJournalId,@ClearingPaymentsCOAID,P.Remarks,Null As DocDebit,PD.PaymentAmount As DocCredit,
									Null As BaseDebit,Round(PD.PaymentAmount * @MainExchangeRate,2) As BaseCredit,
									0.00 As DocDebitTotal,0.00 As DocCreditTotal,0.00 As BaseDebitTotal,0.00 As BaseCreditTotal,P.Id As DocumnetId,PD.Id As DocumentDetailId,@GUIDZero,
									P.BaseCurrency,@DefaultExchangeRate As ExchangeRate,@DocType,@DocSubType,PD.ServiceCompanyId,P.DocNo,PD.Nature,Null As DocumentNo,0 As IsTax,
									P.EntityId,@MasterSystemRefNo,@BankChargesCurrency,P.DocDate,P.DocDate,@MasterRecOrder As RecOrder
								From Bean.Payment As P
								Inner Join bean.PaymentDetail As PD On PD.PaymentId=P.Id
								Where P.Id=@SourceId And PD.Id=@PaymentDtlId
							End
							Else 
							Begin
								Insert Into Bean.JournalDetail (Id,JournalId,COAId,AccountDescription, DocDebit,DocCredit,
																 BaseDebit,BaseCredit,
																 DocDebitTotal,DocCreditTotal,BaseDebitTotal,BaseCreditTotal,DocumentId,DocumentDetailId,ItemId,BaseCurrency,ExchangeRate,
																 DocType,DocSubType,ServiceCompanyId,DocNo,Nature,OffsetDocument,IsTax,EntityId, SystemRefNo, DocCurrency,DocDate, PostingDate,RecOrder 
																)
								Select NEWID(),@MasterJournalId,@COAID,P.Remarks,PD.PaymentAmount As DocDebit,Null As DocCredit,
									Round(PD.PaymentAmount * @ExchangeRate,2)-Isnull(@DocAmount,0) As BaseDebit,Null As BaseCredit,
									0.00 As DocDebitTotal,0.00 As DocCreditTotal,0.00 As BaseDebitTotal,0.00 As BaseCreditTotal,P.Id As DocumnetId,PD.Id As DocumentDetailId,@GUIDZero,
									P.BaseCurrency,@DefaultExchangeRate As ExchangeRate,@DocType,@DocSubType,PD.ServiceCompanyId,P.DocNo,PD.Nature,Null As DocumentNo,0 As IsTax,
									P.EntityId,@MasterSystemRefNo,@BankChargesCurrency,P.DocDate,P.DocDate,@MasterRecOrder As RecOrder
								From Bean.Payment As P
								Inner Join bean.PaymentDetail As PD On PD.PaymentId=P.Id
								Where P.Id=@SourceId And PD.Id=@PaymentDtlId
								IF @MainExchangeRate-@ExchangeRate<>0
								Begin
									-- Exchangegain or Loss
									-- Opt : Replaced Set with Select
									Select @COAID= Id From Bean.ChartOfAccount Where CompanyId=@CompanyId And Name=@ExchangeGainOrLossRealised
									Set @MasterRecOrder=@MasterRecOrder+1
									Insert Into Bean.JournalDetail (Id,JournalId,COAId,AccountDescription, DocDebit,DocCredit,
																	 BaseDebit,BaseCredit,
																	 DocDebitTotal,DocCreditTotal,BaseDebitTotal,BaseCreditTotal,DocumentId,DocumentDetailId,ItemId,BaseCurrency,ExchangeRate,
																	 DocType,DocSubType,ServiceCompanyId,DocNo,Nature,OffsetDocument,IsTax,EntityId, SystemRefNo, DocCurrency,DocDate, PostingDate,RecOrder 
																	)
									Select NEWID(),@MasterJournalId,@COAID,P.Remarks,Null As DocDebit,Null As DocCredit,
										Case When (@MainExchangeRate-@ExchangeRate)>0 Then ABS(Round((@MainExchangeRate-@ExchangeRate)  * PD.PaymentAmount,2)) End As BaseDebit,Case When (@MainExchangeRate-@ExchangeRate)<0 Then ABS(Round((@MainExchangeRate-@ExchangeRate) * PD.PaymentAmount,2) ) End As BaseCredit,
										0.00 As DocDebitTotal,0.00 As DocCreditTotal,0.00 As BaseDebitTotal,0.00 As BaseCreditTotal,P.Id As DocumnetId,PD.Id As DocumentDetailId,@GUIDZero,
										P.BaseCurrency,P.ExchangeRate,@DocType,@DocSubType,PD.ServiceCompanyId,P.DocNo,PD.Nature,PD.DocumentNo,0 As IsTax,
										EntityId,@MasterSystemRefNo,@BankChargesCurrency,DocDate,DocDate,@MasterRecOrder As RecOrder
									From Bean.Payment As P
									Inner Join bean.PaymentDetail As PD On PD.PaymentId=P.Id
									Where P.Id=@SourceId And PD.Id=@PaymentDtlId
								End
							End
							Set @RecCount=@RecCount+1
						End
					End
				End
				Else IF @DocCurrency<>@BankChargesCurrency And @BaseCurrency=@DocCurrency
				Begin
					/* Creating Mater record In JournalDetail */
					--Set @RecOrder=@RecOrder+1
					Insert Into Bean.JournalDetail (Id,JournalId,COAId,AccountDescription,AllowDisAllow, DocCredit, BaseCredit, DocDebitTotal,DocCreditTotal,BaseDebitTotal,BaseCreditTotal,DocumentId,DocumentDetailId,ItemId,BaseCurrency,ExchangeRate,
													GSTExCurrency,GSTExchangeRate,DocType,DocSubType,ServiceCompanyId,DocNo, IsTax,EntityId, SystemRefNo, DocCurrency,DocDate, PostingDate,RecOrder )
					Select NEWID(),@MasterJournalId,COAId,Remarks,IsDisAllow,GrandTotal,Round(GrandTotal * @SysCalExchangerate,2),0.00 As DocDebitTotal,0.00 As DocCreditTotal,0.00 As BaseDebitTotal,0.00 As BaseCreditTotal,Id As DocumnetId,@GUIDZero,@GUIDZero,
							BaseCurrency,@SysCalExchangerate As ExchangeRate,GSTExCurrency,GSTExchangeRate,@DocType,@DocSubType,ServiceCompanyId,DocNo,0 As IsTax,
							EntityId,@MasterSystemRefNo As SystemRefNo,@BankChargesCurrency,DocDate,DocDate,@MasterRecOrder As RecOrder
					From Bean.Payment Where Id=@SourceId
					-- Clearing Payments
					Set @MasterRecOrder=@MasterRecOrder+1
					--Set @PaymentAmtTotal=(Select SUM(Isnull(PaymentAmount,0)) From bean.PaymentDetail Where PaymentId=@SourceId And DocumentType Not In (@CreditMemoDocument,@CreditNoteDocument))
					-- Opt : Replaced Set with Select
					Select @ClearingPaymentInvOrDNAmount= SUM(Isnull(PaymentAmount,0)) From bean.PaymentDetail Where PaymentId=@SourceId And DocumentType In (@InvoiceDocument,@DebitNoteDocument)
					Select @ClearingPaymentBillAmount= SUM(Isnull(PaymentAmount,0)) From bean.PaymentDetail Where PaymentId=@SourceId And DocumentType Not In (@CreditMemoDocument,@CreditNoteDocument,@InvoiceDocument,@DebitNoteDocument)
					Set @PaymentAmtTotal=ABS(Isnull(@ClearingPaymentBillAmount,0)-Isnull(@ClearingPaymentInvOrDNAmount,0))
					-- Opt : Replaced Set with Select
					Select @ClearingPaymentsCOAID= Id From Bean.ChartOfAccount Where CompanyId=@CompanyId And Name=@ClearingPayments
					Insert Into Bean.JournalDetail (Id,JournalId,COAId,AccountDescription,AllowDisAllow, DocDebit, BaseDebit, DocDebitTotal,DocCreditTotal,BaseDebitTotal,BaseCreditTotal,DocumentId,DocumentDetailId,ItemId,BaseCurrency,ExchangeRate,
													GSTExCurrency,GSTExchangeRate,DocType,DocSubType,ServiceCompanyId,DocNo, IsTax,EntityId, SystemRefNo, DocCurrency,DocDate, PostingDate,RecOrder )
					Select NEWID(),@MasterJournalId,@ClearingPaymentsCOAID,Remarks,IsDisAllow,Round((@PaymentAmtTotal * @DefaultExchangeRate)/@SysCalExchangerate,2),Round(@PaymentAmtTotal * @DefaultExchangeRate,2),0.00 As DocDebitTotal,0.00 As DocCreditTotal,0.00 As BaseDebitTotal,0.00 As BaseCreditTotal,Id As DocumnetId,@GUIDZero,@GUIDZero,
							BaseCurrency,@DefaultExchangeRate As ExchangeRate,GSTExCurrency,GSTExchangeRate,@DocType,@DocSubType,ServiceCompanyId,DocNo,0 As IsTax,
							EntityId,@MasterSystemRefNo As SystemRefNo,@BankChargesCurrency,DocDate,DocDate,@MasterRecOrder As RecOrder
					From Bean.Payment Where Id=@SourceId
					-- 2nd Jv
					Set @SysRefNumOrder=@SysRefNumOrder+1
					Set @SystemRefNo=Concat(@DocNo,'-JV',@SysRefNumOrder)					
					Set @JournalId=NEWID()
					Insert Into Bean.Journal (Id,CompanyId,DocDate,DocType,DocSubType,DocNo,ServiceCompanyId,SystemReferenceNo,IsNoSupportingDocs,NoSupportingDocument,DocCurrency,ExchangeRate,ExCurrency,ExDurationFrom,GSTExchangeRate,GSTExCurrency,GSTTotalAmount,DocumentState,IsNoSupportingDocument,IsGstSettings,IsMultiCurrency,IsAllowableNonAllowable,
											IsGSTCurrencyRateChanged,Remarks,UserCreated,CreatedDate,Status,DocumentDescription,CreationType,GrandDocDebitTotal,GrandDocCreditTotal,GrandBaseDebitTotal,GrandBaseCreditTotal,EntityId,EntityType,PostingDate,COAId,ModeOfReceipt,BankReceiptAmmount,ExcessPaidByClientAmmount,BalancingItemReciveCRAmount,
											BalancingItemPayDRAmount,ReceiptApplicationAmmount,DocumentId, BankClearingDate ,IsBalancing,ISAllowDisAllow, IsShow, ActualSysRefNo,IsSegmentReporting, TransferRefNo
											)
					Select @JournalId,@CompanyId,DocDate,@DocType,@DocSubType,DocNo,ServiceCompanyId,@SystemRefNo As SystemRefNo,IsNoSupportingDocument,NoSupportingDocs,DocCurrency,ExchangeRate,ExCurrency,ExDurationFrom,GSTExchangeRate,GSTExCurrency,Isnull(GSTTotalAmount,0),DocumentState,NoSupportingDocs,IsGstSettings,IsMultiCurrency,IsAllowableDisallowable,IsGSTCurrencyRateChanged,Remarks,@UserCreated,@CreatedDate,Status,Remarks As DocDescription,@UserCreated,GrandTotal,0.00 As GrandDocCreditTotal,Round(GrandTotal * ExchangeRate,2) As GrandBaseDebitTotal,
							0.00 As GrandBaseCreditTotal,EntityId,EntityType,DocDate As PostingDate,COAId,ModeOfReceipt,0.00 As BankReceiptAmmount,0.00 As ExcessPaidByClientAmmount,0.00 As BalancingItemReciveCRAmount,0.00 As BalancingItemPayDRAmount,0.00 As ReceiptApplicationAmmount,Id As DocumentId,BankClearingDate,0 As IsBalancing,IsDisAllow,1 As IsShow,DocNo As ActualSysRefNo,0 As IsSegmentReporting, PaymentRefNo
					From Bean.Payment Where CompanyId=@CompanyId And Id=@SourceId
					-- 2 nd Jv Clearing Payments
					Set @DtlRecOrder=1
					Insert Into Bean.JournalDetail (Id,JournalId,COAId,AccountDescription,AllowDisAllow, DocCredit, BaseCredit, DocDebitTotal,DocCreditTotal,BaseDebitTotal,BaseCreditTotal,DocumentId,DocumentDetailId,ItemId,BaseCurrency,ExchangeRate,GSTExCurrency,
													GSTExchangeRate,DocType,DocSubType,ServiceCompanyId,DocNo, IsTax,EntityId, SystemRefNo, DocCurrency,DocDate, PostingDate,RecOrder )
					Select NEWID(),@JournalId,@ClearingPaymentsCOAID,Remarks,IsDisAllow,@PaymentAmtTotal ,Round(@PaymentAmtTotal * @DefaultExchangeRate,2),0.00 As DocDebitTotal,0.00 As DocCreditTotal,0.00 As BaseDebitTotal,0.00 As BaseCreditTotal,Id As DocumnetId,@GUIDZero,@GUIDZero,
							BaseCurrency,@DefaultExchangeRate As ExchangeRate,GSTExCurrency,GSTExchangeRate,@DocType,@DocSubType,ServiceCompanyId,DocNo,0 As IsTax,
							EntityId,@SystemRefNo As SystemRefNo,@DocCurrency,DocDate,DocDate,@DtlRecOrder As RecOrder
					From Bean.Payment Where Id=@SourceId
					-- Detail Records
					IF Exists(Select Id From Bean.PaymentDetail Where PaymentId=@SourceId And PaymentAmount<>0)
					Begin
						Insert Into @PaymentDtl
						Select Id From Bean.PaymentDetail Where PaymentId=@SourceId And PaymentAmount<>0
						Set @RecCount=1
						-- Opt : Replaced Set with Select
						Select @Count= Count(*) From @PaymentDtl
						While @Count>=@RecCount
						Begin
							-- Opt : Replaced Set with Select
							Select @PaymentDtlId= PaymentDtlId From @PaymentDtl Where S_No=@RecCount
							Select @DocumentId= DocumentId From bean.PaymentDetail Where Id=@PaymentDtlId
							Set @IsRoundingAmount=0
							IF Exists (Select Id From Bean.PaymentDetail Where Id=@PaymentDtlId And Nature=@NatureTrade And DocumentType =@InvoiceDocument)
							Begin
								-- Opt : Replaced Set with Select
								Select @COAID= Id From Bean.ChartOfAccount Where CompanyId=@CompanyId And Name=@COATradeReceivables
								IF Exists (Select Id From Bean.Invoice Where Id=@DocumentId And DocumentState In (@FullyApplied,@Fullypaid))
								Begin
									Set @IsRoundingAmount=1
								End
							End
							Else IF Exists (Select Id From Bean.PaymentDetail Where Id=@PaymentDtlId And Nature=@NatureOthers And DocumentType =@InvoiceDocument)
							Begin
								-- Opt : Replaced Set with Select
								Select @COAID= Id From Bean.ChartOfAccount Where CompanyId=@CompanyId And Name=@COAotherReceivables
								IF Exists (Select Id From Bean.Invoice Where Id=@DocumentId And DocumentState In (@FullyApplied,@Fullypaid))
								Begin
									Set @IsRoundingAmount=1
								End
							End
							Else IF Exists (Select Id From Bean.PaymentDetail Where Id=@PaymentDtlId And Nature=@NatureTrade And DocumentType =@DebitNoteDocument)
							Begin
								-- Opt : Replaced Set with Select
								Select @COAID= Id From Bean.ChartOfAccount Where CompanyId=@CompanyId And Name=@COATradeReceivables
								IF Exists (Select Id From Bean.DebitNote Where Id=@DocumentId And DocumentState In (@FullyApplied,@Fullypaid))
								Begin
									Set @IsRoundingAmount=1
								End
							End
							Else IF Exists (Select Id From Bean.PaymentDetail Where Id=@PaymentDtlId And Nature=@NatureOthers And DocumentType =@DebitNoteDocument)
							Begin
								-- Opt : Replaced Set with Select
								Select @COAID= Id From Bean.ChartOfAccount Where CompanyId=@CompanyId And Name=@COAotherReceivables
								IF Exists (Select Id From Bean.DebitNote Where Id=@DocumentId And DocumentState In (@FullyApplied,@Fullypaid))
								Begin
									Set @IsRoundingAmount=1
								End
							End
							Else IF Exists (Select Id From Bean.PaymentDetail Where Id=@PaymentDtlId And Nature=@NatureTrade And DocumentType Not In (@InvoiceDocument,@DebitNoteDocument,@CreditNoteDocument,@CreditMemoDocument))
							Begin
								-- Opt : Replaced Set with Select
								Select @COAID= Id From Bean.ChartOfAccount Where CompanyId=@CompanyId And Name=@COATradePayables
								IF Exists (Select Id From Bean.Bill Where Id=@DocumentId And DocumentState In (@FullyApplied,@Fullypaid))
								Begin
									Set @IsRoundingAmount=1
								End
							End
							Else IF Exists (Select Id From Bean.PaymentDetail Where Id=@PaymentDtlId And Nature=@NatureOthers And DocumentType Not In (@InvoiceDocument,@DebitNoteDocument,@CreditNoteDocument,@CreditMemoDocument))
							Begin
								Select @COAID= Id From Bean.ChartOfAccount Where CompanyId=@CompanyId And Name=@COAOtherPayables
								IF Exists (Select Id From Bean.Bill Where Id=@DocumentId And DocumentState In (@FullyApplied,@Fullypaid))
								Begin
									Set @IsRoundingAmount=1
								End
							End
							-- Opt : Replaced Set with Select
							Select @OffSetDocumentType= DocumentType From Bean.PaymentDetail Where Id=@PaymentDtlId
							IF @IsRoundingAmount=1 And Exists (Select Amount From @RoundingAmountDetails Where DocumentId=@DocumentId And Amount Is Not Null And Amount<>'') --And @RoundingAmount Is Not Null And @RoundingAmount <>''
							Begin
								-- Opt : Replaced Set with Select
								Select @DocAmount= Amount From @RoundingAmountDetails Where DocumentId=@DocumentId
							End
							Else
							Begin
								Set @DocAmount=0
							End
							IF @OffSetDocumentType=@InvoiceDocument Or @OffSetDocumentType=@DebitNoteDocument
							Begin
								Set @DtlRecOrder=@DtlRecOrder+1
								Insert Into Bean.JournalDetail (Id,JournalId,COAId,AccountDescription, DocDebit,DocCredit,
																 BaseDebit,BaseCredit,
																 DocDebitTotal,DocCreditTotal,BaseDebitTotal,BaseCreditTotal,DocumentId,DocumentDetailId,ItemId,BaseCurrency,ExchangeRate,
																 DocType,DocSubType,ServiceCompanyId,DocNo,Nature,OffsetDocument,IsTax,EntityId, SystemRefNo, DocCurrency,DocDate, PostingDate,RecOrder 
																)
								Select NEWID(),@JournalId,@COAID,P.Remarks,Null As DocDebit,PD.PaymentAmount As DocCredit,
									Null As BaseDebit,Round(PD.PaymentAmount * @DefaultExchangeRate,2)-Isnull(@DocAmount,0) As BaseCredit,
									0.00 As DocDebitTotal,0.00 As DocCreditTotal,0.00 As BaseDebitTotal,0.00 As BaseCreditTotal,P.Id As DocumnetId,PD.Id As DocumentDetailId,@GUIDZero,
									P.BaseCurrency,@DefaultExchangeRate As ExchangeRate,@DocType,@DocSubType,PD.ServiceCompanyId,P.DocNo,PD.Nature,Null As DocumentNo,0 As IsTax,
									P.EntityId,@SystemRefNo,@DocCurrency,P.DocDate,P.DocDate,@DtlRecOrder As RecOrder
								From Bean.Payment As P
								Inner Join bean.PaymentDetail As PD On PD.PaymentId=P.Id
								Where P.Id=@SourceId And PD.Id=@PaymentDtlId
							End
							Else IF @OffSetDocumentType=@CreditMemoDocument
							Begin
								Set @RecOrder=@RecOrder+1
								Insert Into Bean.JournalDetail (Id,JournalId,COAId,AccountDescription, DocDebit,DocCredit,
																 BaseDebit,BaseCredit,
																 DocDebitTotal,DocCreditTotal,BaseDebitTotal,BaseCreditTotal,DocumentId,DocumentDetailId,ItemId,BaseCurrency,ExchangeRate,
																 DocType,DocSubType,ServiceCompanyId,DocNo,Nature,OffsetDocument,IsTax,EntityId, SystemRefNo, DocCurrency,DocDate, PostingDate,RecOrder 
																)
								Select NEWID(),@MasterJournalId,@ClearingPaymentsCOAID,P.Remarks,Null As DocDebit,Round((PD.PaymentAmount * @DefaultExchangeRate)/@SysCalExchangerate,2) As DocCredit,
									Null As BaseDebit,Round(PD.PaymentAmount * @DefaultExchangeRate,2) As BaseCredit,
									0.00 As DocDebitTotal,0.00 As DocCreditTotal,0.00 As BaseDebitTotal,0.00 As BaseCreditTotal,P.Id As DocumnetId,PD.Id As DocumentDetailId,@GUIDZero,
									P.BaseCurrency,@DefaultExchangeRate As ExchangeRate,@DocType,@DocSubType,PD.ServiceCompanyId,P.DocNo,PD.Nature,Null As DocumentNo,0 As IsTax,
									P.EntityId,@MasterSystemRefNo,@BankChargesCurrency,P.DocDate,P.DocDate,@RecOrder As RecOrder
								From Bean.Payment As P
								Inner Join bean.PaymentDetail As PD On PD.PaymentId=P.Id
								Where P.Id=@SourceId And PD.Id=@PaymentDtlId
							End
							Else IF @OffSetDocumentType=@CreditNoteDocument
							Begin
								Set @RecOrder=@RecOrder+1
								Insert Into Bean.JournalDetail (Id,JournalId,COAId,AccountDescription, DocDebit,DocCredit,
																 BaseDebit,BaseCredit,
																 DocDebitTotal,DocCreditTotal,BaseDebitTotal,BaseCreditTotal,DocumentId,DocumentDetailId,ItemId,BaseCurrency,ExchangeRate,
																 DocType,DocSubType,ServiceCompanyId,DocNo,Nature,OffsetDocument,IsTax,EntityId, SystemRefNo, DocCurrency,DocDate, PostingDate,RecOrder 
																)
								Select NEWID(),@MasterJournalId,@ClearingPaymentsCOAID,P.Remarks,Round((PD.PaymentAmount * @DefaultExchangeRate)/@SysCalExchangerate,2) As DocDebit,Null As DocCredit,
									Round(PD.PaymentAmount * @DefaultExchangeRate,2) As BaseDebit,Null As BaseCredit,
									0.00 As DocDebitTotal,0.00 As DocCreditTotal,0.00 As BaseDebitTotal,0.00 As BaseCreditTotal,P.Id As DocumnetId,PD.Id As DocumentDetailId,@GUIDZero,
									P.BaseCurrency,@DefaultExchangeRate As ExchangeRate,@DocType,@DocSubType,PD.ServiceCompanyId,P.DocNo,PD.Nature,Null As DocumentNo,0 As IsTax,
									P.EntityId,@MasterSystemRefNo,@BankChargesCurrency,P.DocDate,P.DocDate,@RecOrder As RecOrder
								From Bean.Payment As P
								Inner Join bean.PaymentDetail As PD On PD.PaymentId=P.Id
								Where P.Id=@SourceId And PD.Id=@PaymentDtlId
							End
							Else 
							Begin
								Set @DtlRecOrder=@DtlRecOrder+1
								Insert Into Bean.JournalDetail (Id,JournalId,COAId,AccountDescription, DocDebit,DocCredit,
																 BaseDebit,BaseCredit,
																 DocDebitTotal,DocCreditTotal,BaseDebitTotal,BaseCreditTotal,DocumentId,DocumentDetailId,ItemId,BaseCurrency,ExchangeRate,
																 DocType,DocSubType,ServiceCompanyId,DocNo,Nature,OffsetDocument,IsTax,EntityId, SystemRefNo, DocCurrency,DocDate, PostingDate,RecOrder 
																)
								Select NEWID(),@JournalId,@COAID,P.Remarks,PD.PaymentAmount As DocDebit,Null As DocCredit,
									Round(PD.PaymentAmount * @DefaultExchangeRate,2)-Isnull(@DocAmount,0) As BaseDebit,Null As BaseCredit,
									0.00 As DocDebitTotal,0.00 As DocCreditTotal,0.00 As BaseDebitTotal,0.00 As BaseCreditTotal,P.Id As DocumnetId,PD.Id As DocumentDetailId,@GUIDZero,
									P.BaseCurrency,@DefaultExchangeRate As ExchangeRate,@DocType,@DocSubType,PD.ServiceCompanyId,P.DocNo,PD.Nature,Null As DocumentNo,0 As IsTax,
									P.EntityId,@SystemRefNo,@DocCurrency,P.DocDate,P.DocDate,@DtlRecOrder As RecOrder
								From Bean.Payment As P
								Inner Join bean.PaymentDetail As PD On PD.PaymentId=P.Id
								Where P.Id=@SourceId And PD.Id=@PaymentDtlId
							End
							Set @RecCount=@RecCount+1
						End
					End
				End
				Else IF @DocCurrency<>@BankChargesCurrency And @BaseCurrency<>@DocCurrency
				Begin
					/* Creating Mater record In JournalDetail */
					Insert Into Bean.JournalDetail (Id,JournalId,COAId,AccountDescription,AllowDisAllow, DocCredit, BaseCredit, DocDebitTotal,DocCreditTotal,BaseDebitTotal,BaseCreditTotal,DocumentId,DocumentDetailId,ItemId,BaseCurrency,ExchangeRate,
													GSTExCurrency,GSTExchangeRate,DocType,DocSubType,ServiceCompanyId,DocNo, IsTax,EntityId, SystemRefNo, DocCurrency,DocDate, PostingDate,RecOrder )
					Select NEWID(),@MasterJournalId,COAId,Remarks,IsDisAllow,GrandTotal,Round(GrandTotal * @DefaultExchangeRate,2),0.00 As DocDebitTotal,0.00 As DocCreditTotal,0.00 As BaseDebitTotal,0.00 As BaseCreditTotal,Id As DocumnetId,@GUIDZero,@GUIDZero,
							BaseCurrency,@DefaultExchangeRate As ExchangeRate,GSTExCurrency,GSTExchangeRate,@DocType,@DocSubType,ServiceCompanyId,DocNo,0 As IsTax,
							EntityId,@MasterSystemRefNo As SystemRefNo,@BankChargesCurrency,DocDate,DocDate,@MasterRecOrder As RecOrder
					From Bean.Payment Where Id=@SourceId
					-- Clearing Payments
					Set @MasterRecOrder=@MasterRecOrder+1
					-- Opt : Replaced Set with Select
					Select @ClearingPaymentInvOrDNAmount= SUM(Isnull(PaymentAmount,0)) From bean.PaymentDetail Where PaymentId=@SourceId And DocumentType In (@InvoiceDocument,@DebitNoteDocument)
					Select @ClearingPaymentBillAmount= SUM(Isnull(PaymentAmount,0)) From bean.PaymentDetail Where PaymentId=@SourceId And DocumentType Not In (@CreditMemoDocument,@CreditNoteDocument,@InvoiceDocument,@DebitNoteDocument)
					Set @PaymentAmtTotal=ABS(Isnull(@ClearingPaymentBillAmount,0)-Isnull(@ClearingPaymentInvOrDNAmount,0))
					Select @ClearingPaymentsCOAID= Id From Bean.ChartOfAccount Where CompanyId=@CompanyId And Name=@ClearingPayments
					Insert Into Bean.JournalDetail (Id,JournalId,COAId,AccountDescription,AllowDisAllow, DocDebit, BaseDebit, DocDebitTotal,DocCreditTotal,BaseDebitTotal,BaseCreditTotal,DocumentId,DocumentDetailId,ItemId,BaseCurrency,ExchangeRate,
													GSTExCurrency,GSTExchangeRate,DocType,DocSubType,ServiceCompanyId,DocNo, IsTax,EntityId, SystemRefNo, DocCurrency,DocDate, PostingDate,RecOrder )
					Select NEWID(),@MasterJournalId,@ClearingPaymentsCOAID,Remarks,IsDisAllow,Round((@PaymentAmtTotal * @SysCalExchangerate)/@DefaultExchangeRate,2),Round(@PaymentAmtTotal * @SysCalExchangerate,2),0.00 As DocDebitTotal,0.00 As DocCreditTotal,0.00 As BaseDebitTotal,0.00 As BaseCreditTotal,Id As DocumnetId,@GUIDZero,@GUIDZero,
							BaseCurrency,@DefaultExchangeRate As ExchangeRate,GSTExCurrency,GSTExchangeRate,@DocType,@DocSubType,ServiceCompanyId,DocNo,0 As IsTax,
							EntityId,@MasterSystemRefNo As SystemRefNo,@BankChargesCurrency,DocDate,DocDate,@MasterRecOrder As RecOrder
					From Bean.Payment Where Id=@SourceId
					-- 2nd Jv
					Set @SysRefNumOrder=@SysRefNumOrder+1
					Set @SystemRefNo=Concat(@DocNo,'-JV',@SysRefNumOrder)					
					Set @JournalId=NEWID()
					Insert Into Bean.Journal (Id,CompanyId,DocDate,DocType,DocSubType,DocNo,ServiceCompanyId,SystemReferenceNo,IsNoSupportingDocs,NoSupportingDocument,DocCurrency,ExchangeRate,ExCurrency,ExDurationFrom,GSTExchangeRate,GSTExCurrency,GSTTotalAmount,DocumentState,IsNoSupportingDocument,IsGstSettings,IsMultiCurrency,IsAllowableNonAllowable,
												IsGSTCurrencyRateChanged,Remarks,UserCreated,CreatedDate,Status,DocumentDescription,CreationType,GrandDocDebitTotal,GrandDocCreditTotal,GrandBaseDebitTotal,GrandBaseCreditTotal,EntityId,EntityType,PostingDate,COAId,ModeOfReceipt,BankReceiptAmmount,ExcessPaidByClientAmmount,BalancingItemReciveCRAmount, 
												BalancingItemPayDRAmount,ReceiptApplicationAmmount,DocumentId, BankClearingDate ,IsBalancing,ISAllowDisAllow, IsShow, ActualSysRefNo ,IsSegmentReporting, TransferRefNo
											)
					Select @JournalId,@CompanyId,DocDate,@DocType,@DocSubType,DocNo,ServiceCompanyId,@SystemRefNo As SystemRefNo,IsNoSupportingDocument,NoSupportingDocs,DocCurrency,ExchangeRate,ExCurrency,ExDurationFrom,GSTExchangeRate,GSTExCurrency,Isnull(GSTTotalAmount,0),DocumentState,NoSupportingDocs,IsGstSettings,IsMultiCurrency,IsAllowableDisallowable,IsGSTCurrencyRateChanged,Remarks,@UserCreated,@CreatedDate,Status,Remarks As DocDescription,@UserCreated,GrandTotal,0.00 As GrandDocCreditTotal,Round(GrandTotal * ExchangeRate,2) As GrandBaseDebitTotal,
							0.00 As GrandBaseCreditTotal,EntityId,EntityType,DocDate As PostingDate,COAId,ModeOfReceipt,0.00 As BankReceiptAmmount,0.00 As ExcessPaidByClientAmmount,0.00 As BalancingItemReciveCRAmount,0.00 As BalancingItemPayDRAmount,0.00 As ReceiptApplicationAmmount,Id As DocumentId,BankClearingDate,0 As IsBalancing,IsDisAllow,1 As IsShow,DocNo As ActualSysRefNo,0 As IsSegmentReporting, PaymentRefNo
					From Bean.Payment Where CompanyId=@CompanyId And Id=@SourceId
					-- 2 nd Jv Clearing Payments
					Set @DtlRecOrder=1
					Insert Into Bean.JournalDetail (Id,JournalId,COAId,AccountDescription,AllowDisAllow, DocCredit, BaseCredit, DocDebitTotal,DocCreditTotal,BaseDebitTotal,BaseCreditTotal,DocumentId,DocumentDetailId,ItemId,BaseCurrency,ExchangeRate,GSTExCurrency,GSTExchangeRate,
													DocType,DocSubType,ServiceCompanyId,DocNo, IsTax,EntityId, SystemRefNo, DocCurrency,DocDate, PostingDate,RecOrder )
					Select NEWID(),@JournalId,@ClearingPaymentsCOAID,Remarks,IsDisAllow,@PaymentAmtTotal ,Round(@PaymentAmtTotal * @SysCalExchangerate,2),0.00 As DocDebitTotal,0.00 As DocCreditTotal,0.00 As BaseDebitTotal,0.00 As BaseCreditTotal,Id As DocumnetId,@GUIDZero,@GUIDZero,
							BaseCurrency,@SysCalExchangerate As ExchangeRate,GSTExCurrency,GSTExchangeRate,@DocType,@DocSubType,ServiceCompanyId,DocNo,0 As IsTax,
							EntityId,@SystemRefNo As SystemRefNo,@DocCurrency,DocDate,DocDate,@DtlRecOrder As RecOrder
					From Bean.Payment Where Id=@SourceId
					-- Detail Records
					IF Exists(Select Id From Bean.PaymentDetail Where PaymentId=@SourceId And PaymentAmount<>0)
					Begin
						Insert Into @PaymentDtl
						Select Id From Bean.PaymentDetail Where PaymentId=@SourceId And PaymentAmount<>0
						Set @RecCount=1
						-- Opt : Replaced Set with Select
						Select @Count= Count(*) From @PaymentDtl
						While @Count>=@RecCount
						Begin
							-- Opt : Replaced Set with Select
							Select @PaymentDtlId= PaymentDtlId From @PaymentDtl Where S_No=@RecCount
							Select @DocumentId= DocumentId From Bean.PaymentDetail Where Id=@PaymentDtlId
							Set @IsRoundingAmount=0
							IF Exists (Select Id From Bean.PaymentDetail Where Id=@PaymentDtlId And Nature=@NatureTrade And DocumentType = @InvoiceDocument)
							Begin
								-- Opt : Replaced Set with Select
								Select @COAID= Id From Bean.ChartOfAccount Where CompanyId=@CompanyId And Name=@COATradeReceivables
								Select @ExchangeRate= ExchangeRate From Bean.Invoice Where Id=@DocumentId
								IF Exists (Select Id From Bean.Invoice Where Id=@DocumentId And DocumentState In (@FullyApplied,@Fullypaid))
								Begin
									Set @IsRoundingAmount=1
								End
							End
							Else IF Exists (Select Id From Bean.PaymentDetail Where Id=@PaymentDtlId And Nature=@NatureOthers And DocumentType =@InvoiceDocument)
							Begin
								-- Opt : Replaced Set with Select
								Select @COAID= Id From Bean.ChartOfAccount Where CompanyId=@CompanyId And Name=@COAotherReceivables
								Select @ExchangeRate= ExchangeRate From Bean.Invoice Where Id=@DocumentId
								IF Exists (Select Id From Bean.Invoice Where Id=@DocumentId And DocumentState In (@FullyApplied,@Fullypaid))
								Begin
									Set @IsRoundingAmount=1
								End
							End
							Else IF Exists (Select Id From Bean.PaymentDetail Where Id=@PaymentDtlId And Nature=@NatureTrade And DocumentType =@DebitNoteDocument)
							Begin
								-- Opt : Replaced Set with Select
								Select @COAID= Id From Bean.ChartOfAccount Where CompanyId=@CompanyId And Name=@COATradeReceivables
								Select @ExchangeRate= ExchangeRate From Bean.DebitNote Where Id=@DocumentId
								IF Exists (Select Id From Bean.DebitNote Where Id=@DocumentId And DocumentState In (@FullyApplied,@Fullypaid))
								Begin
									Set @IsRoundingAmount=1
								End
							End
							Else IF Exists (Select Id From Bean.PaymentDetail Where Id=@PaymentDtlId And Nature=@NatureOthers And DocumentType =@DebitNoteDocument)
							Begin
								-- Opt : Replaced Set with Select
								Select @COAID= Id From Bean.ChartOfAccount Where CompanyId=@CompanyId And Name=@COAotherReceivables
								Select @ExchangeRate= ExchangeRate From Bean.DebitNote Where Id=@DocumentId
								IF Exists (Select Id From Bean.DebitNote Where Id=@DocumentId And DocumentState In (@FullyApplied,@Fullypaid))
								Begin
									Set @IsRoundingAmount=1
								End
							End
							Else IF Exists (Select Id From Bean.PaymentDetail Where Id=@PaymentDtlId And Nature=@NatureTrade And DocumentType Not In (@InvoiceDocument,@DebitNoteDocument,@CreditNoteDocument,@CreditMemoDocument))
							Begin
								-- Opt : Replaced Set with Select
								Select @COAID= Id From Bean.ChartOfAccount Where CompanyId=@CompanyId And Name=@COATradePayables
								Select @ExchangeRate= ExchangeRate From Bean.Bill Where Id=@DocumentId
								IF Exists (Select Id From Bean.Bill Where Id=@DocumentId And DocumentState In (@FullyApplied,@Fullypaid))
								Begin
									Set @IsRoundingAmount=1
								End
							End
							Else IF Exists (Select Id From Bean.PaymentDetail Where Id=@PaymentDtlId And Nature=@NatureOthers And DocumentType Not In (@InvoiceDocument,@DebitNoteDocument,@CreditNoteDocument,@CreditMemoDocument))
							Begin
								-- Opt : Replaced Set with Select
								Select @COAID= Id From Bean.ChartOfAccount Where CompanyId=@CompanyId And Name=@COAOtherPayables
								Select @ExchangeRate= ExchangeRate From Bean.Bill Where Id=@DocumentId
								IF Exists (Select Id From Bean.Bill Where Id=@DocumentId And DocumentState In (@FullyApplied,@Fullypaid))
								Begin
									Set @IsRoundingAmount=1
								End
							End
							IF @IsRoundingAmount=1 And Exists (Select Amount From @RoundingAmountDetails Where DocumentId=@DocumentId And Amount Is Not Null And Amount<>'') --And @RoundingAmount Is Not Null And @RoundingAmount <>''
							Begin
								-- Opt : Replaced Set with Select
								Select @DocAmount= Amount From @RoundingAmountDetails Where DocumentId=@DocumentId
							End
							Else
							Begin
								Set @DocAmount=0
							End
							-- Opt : Replaced Set with Select
							Select @OffSetDocumentType= DocumentType From Bean.PaymentDetail Where Id=@PaymentDtlId
							
							IF @OffSetDocumentType=@InvoiceDocument Or @OffSetDocumentType=@DebitNoteDocument
							Begin
								Set @DtlRecOrder=@DtlRecOrder+1
								Insert Into Bean.JournalDetail (Id,JournalId,COAId,AccountDescription, DocDebit,DocCredit,BaseDebit,BaseCredit,DocDebitTotal,DocCreditTotal,BaseDebitTotal,
																BaseCreditTotal,DocumentId,DocumentDetailId,ItemId,BaseCurrency,ExchangeRate, DocType,DocSubType,ServiceCompanyId,DocNo,Nature,
																OffsetDocument,IsTax,EntityId, SystemRefNo, DocCurrency,DocDate, PostingDate,RecOrder 
																)
								Select NEWID(),@JournalId,@COAID,P.Remarks,Null As DocDebit,PD.PaymentAmount As DocCredit,
									Null As BaseDebit,Round(PD.PaymentAmount * @ExchangeRate,2)-Isnull(@DocAmount,0) As BaseCredit,
									0.00 As DocDebitTotal,0.00 As DocCreditTotal,0.00 As BaseDebitTotal,0.00 As BaseCreditTotal,P.Id As DocumnetId,PD.Id As DocumentDetailId,@GUIDZero,
									P.BaseCurrency,@ExchangeRate As ExchangeRate,@DocType,@DocSubType,PD.ServiceCompanyId,P.DocNo,PD.Nature,Null As DocumentNo,0 As IsTax,
									P.EntityId,@SystemRefNo,@DocCurrency,P.DocDate,P.DocDate,@DtlRecOrder As RecOrder
								From Bean.Payment As P
								Inner Join bean.PaymentDetail As PD On PD.PaymentId=P.Id
								Where P.Id=@SourceId And PD.Id=@PaymentDtlId
								IF @SysCalExchangerate-@ExchangeRate<>0
								Begin
									-- Exchangegain or Loss
									-- Opt : Replaced Set with Select
									Select @COAID= Id From Bean.ChartOfAccount Where CompanyId=@CompanyId And Name=@ExchangeGainOrLossRealised
									Set @DtlRecOrder=@DtlRecOrder+1
									Insert Into Bean.JournalDetail (Id,JournalId,COAId,AccountDescription, DocDebit,DocCredit,BaseDebit,BaseCredit,DocDebitTotal,DocCreditTotal,BaseDebitTotal,BaseCreditTotal,DocumentId,
																	DocumentDetailId,ItemId,BaseCurrency,ExchangeRate, DocType,DocSubType,ServiceCompanyId,DocNo,Nature,OffsetDocument,IsTax,EntityId, SystemRefNo, DocCurrency,DocDate, PostingDate,RecOrder 
																	)
									Select NEWID(),@JournalId,@COAID,P.Remarks,Null As DocDebit,Null As DocCredit,
										Case When (@SysCalExchangerate-@ExchangeRate)<0 Then ABS(Round((@SysCalExchangerate-@ExchangeRate)  * PD.PaymentAmount,2)) End As BaseDebit,
										Case When (@SysCalExchangerate-@ExchangeRate)>0 Then ABS(Round((@SysCalExchangerate-@ExchangeRate) * PD.PaymentAmount,2) ) End As BaseCredit,
										0.00 As DocDebitTotal,0.00 As DocCreditTotal,0.00 As BaseDebitTotal,0.00 As BaseCreditTotal,P.Id As DocumnetId,PD.Id As DocumentDetailId,@GUIDZero,
										P.BaseCurrency,P.ExchangeRate,@DocType,@DocSubType,PD.ServiceCompanyId,P.DocNo,PD.Nature,PD.DocumentNo,0 As IsTax,
										EntityId,@SystemRefNo,@DocCurrency,DocDate,DocDate,@DtlRecOrder As RecOrder
									From Bean.Payment As P
									Inner Join bean.PaymentDetail As PD On PD.PaymentId=P.Id
									Where P.Id=@SourceId And PD.Id=@PaymentDtlId
								End
							End
							Else IF @OffSetDocumentType=@CreditMemoDocument
							Begin
								Set @MasterRecOrder=@MasterRecOrder+1
								Insert Into Bean.JournalDetail (Id,JournalId,COAId,AccountDescription, DocDebit,DocCredit,
																 BaseDebit,BaseCredit,
																 DocDebitTotal,DocCreditTotal,BaseDebitTotal,BaseCreditTotal,DocumentId,DocumentDetailId,ItemId,BaseCurrency,ExchangeRate,
																 DocType,DocSubType,ServiceCompanyId,DocNo,Nature,OffsetDocument,IsTax,EntityId, SystemRefNo, DocCurrency,DocDate, PostingDate,RecOrder 
																)
								Select NEWID(),@MasterJournalId,@ClearingPaymentsCOAID,P.Remarks,Null As DocDebit,Round((PD.PaymentAmount * @SysCalExchangerate)/@DefaultExchangeRate,2) As DocCredit,
									Null As BaseDebit,Round(PD.PaymentAmount * @SysCalExchangerate,2) As BaseCredit,
									0.00 As DocDebitTotal,0.00 As DocCreditTotal,0.00 As BaseDebitTotal,0.00 As BaseCreditTotal,P.Id As DocumnetId,PD.Id As DocumentDetailId,@GUIDZero,
									P.BaseCurrency,@DefaultExchangeRate As ExchangeRate,@DocType,@DocSubType,PD.ServiceCompanyId,P.DocNo,PD.Nature,Null As DocumentNo,0 As IsTax,
									P.EntityId,@MasterSystemRefNo,@BankChargesCurrency,P.DocDate,P.DocDate,@MasterRecOrder As RecOrder
								From Bean.Payment As P
								Inner Join bean.PaymentDetail As PD On PD.PaymentId=P.Id
								Where P.Id=@SourceId And PD.Id=@PaymentDtlId
							End
							Else IF @OffSetDocumentType=@CreditNoteDocument
							Begin
								Set @MasterRecOrder=@MasterRecOrder+1
								Insert Into Bean.JournalDetail (Id,JournalId,COAId,AccountDescription, DocDebit,DocCredit,
																 BaseDebit,BaseCredit,
																 DocDebitTotal,DocCreditTotal,BaseDebitTotal,BaseCreditTotal,DocumentId,DocumentDetailId,ItemId,BaseCurrency,ExchangeRate,
																 DocType,DocSubType,ServiceCompanyId,DocNo,Nature,OffsetDocument,IsTax,EntityId, SystemRefNo, DocCurrency,DocDate, PostingDate,RecOrder 
																)
								Select NEWID(),@MasterJournalId,@ClearingPaymentsCOAID,P.Remarks,Round((PD.PaymentAmount * @SysCalExchangerate)/@DefaultExchangeRate,2) As DocDebit,Null As DocCredit,
									Round(PD.PaymentAmount * @SysCalExchangerate,2) As BaseDebit,Null As BaseCredit,
									0.00 As DocDebitTotal,0.00 As DocCreditTotal,0.00 As BaseDebitTotal,0.00 As BaseCreditTotal,P.Id As DocumnetId,PD.Id As DocumentDetailId,@GUIDZero,
									P.BaseCurrency,@DefaultExchangeRate As ExchangeRate,@DocType,@DocSubType,PD.ServiceCompanyId,P.DocNo,PD.Nature,Null As DocumentNo,0 As IsTax,
									P.EntityId,@MasterSystemRefNo,@BankChargesCurrency,P.DocDate,P.DocDate,@MasterRecOrder As RecOrder
								From Bean.Payment As P
								Inner Join bean.PaymentDetail As PD On PD.PaymentId=P.Id
								Where P.Id=@SourceId And PD.Id=@PaymentDtlId
							End
							Else 
							Begin
								Set @DtlRecOrder=@DtlRecOrder+1
								Insert Into Bean.JournalDetail (Id,JournalId,COAId,AccountDescription, DocDebit,DocCredit,BaseDebit,BaseCredit,DocDebitTotal,DocCreditTotal,BaseDebitTotal,BaseCreditTotal,DocumentId,
																DocumentDetailId,ItemId,BaseCurrency,ExchangeRate, DocType,DocSubType,ServiceCompanyId,DocNo,Nature,OffsetDocument,IsTax,EntityId, SystemRefNo, DocCurrency,DocDate, PostingDate,RecOrder 
																)
								Select NEWID(),@JournalId,@COAID,P.Remarks,PD.PaymentAmount As DocDebit,Null As DocCredit,
									Round(PD.PaymentAmount * @ExchangeRate,2)-Isnull(@DocAmount,0) As BaseDebit,Null As BaseCredit,
									0.00 As DocDebitTotal,0.00 As DocCreditTotal,0.00 As BaseDebitTotal,0.00 As BaseCreditTotal,P.Id As DocumnetId,PD.Id As DocumentDetailId,@GUIDZero,
									P.BaseCurrency,@ExchangeRate As ExchangeRate,@DocType,@DocSubType,PD.ServiceCompanyId,P.DocNo,PD.Nature,Null As DocumentNo,0 As IsTax,
									P.EntityId,@SystemRefNo,@DocCurrency,P.DocDate,P.DocDate,@DtlRecOrder As RecOrder
								From Bean.Payment As P
								Inner Join bean.PaymentDetail As PD On PD.PaymentId=P.Id
								Where P.Id=@SourceId And PD.Id=@PaymentDtlId
								IF @SysCalExchangerate-@ExchangeRate<>0
								Begin
									-- Exchangegain or Loss
									-- Opt : Replaced Set with Select
									Select @COAID= Id From Bean.ChartOfAccount Where CompanyId=@CompanyId And Name=@ExchangeGainOrLossRealised
									Set @DtlRecOrder=@DtlRecOrder+1
									Insert Into Bean.JournalDetail (Id,JournalId,COAId,AccountDescription, DocDebit,DocCredit,
																	 BaseDebit,BaseCredit,
																	 DocDebitTotal,DocCreditTotal,BaseDebitTotal,BaseCreditTotal,DocumentId,DocumentDetailId,ItemId,BaseCurrency,ExchangeRate, 
																	 DocType,DocSubType,ServiceCompanyId,DocNo,Nature,OffsetDocument,IsTax,EntityId, SystemRefNo, DocCurrency,DocDate, PostingDate,RecOrder 
																	)
									Select NEWID(),@JournalId,@COAID,P.Remarks,Null As DocDebit,Null As DocCredit,
										Case When (@ExchangeRate-@SysCalExchangerate)<0 Then ABS(Round((@ExchangeRate-@SysCalExchangerate)  * PD.PaymentAmount,2)) End As BaseDebit,Case When (@ExchangeRate-@SysCalExchangerate)>0 Then ABS(Round((@ExchangeRate-@SysCalExchangerate) * PD.PaymentAmount,2) ) End As BaseCredit,
										0.00 As DocDebitTotal,0.00 As DocCreditTotal,0.00 As BaseDebitTotal,0.00 As BaseCreditTotal,P.Id As DocumnetId,PD.Id As DocumentDetailId,@GUIDZero,
										P.BaseCurrency,P.ExchangeRate,@DocType,@DocSubType,PD.ServiceCompanyId,P.DocNo,PD.Nature,PD.DocumentNo,0 As IsTax,
										EntityId,@SystemRefNo,@DocCurrency,DocDate,DocDate,@DtlRecOrder As RecOrder
									From Bean.Payment As P
									Inner Join bean.PaymentDetail As PD On PD.PaymentId=P.Id
									Where P.Id=@SourceId And PD.Id=@PaymentDtlId
								End
							End
							Set @RecCount=@RecCount+1
						End
					End
				End
			End
			-- Payment Inter Company
			Else IF @ServCompCount >1 Or @ServCompCount2 >=1
			Begin
				Set @MasterSystemRefNo=Concat(@DocNo,'-JV',@SysRefNumOrder)
				Set @MasterJournalId=NEWID()
				Insert Into Bean.Journal (Id,CompanyId,DocDate,DocType,DocSubType,DocNo,ServiceCompanyId,SystemReferenceNo,IsNoSupportingDocs,NoSupportingDocument,DocCurrency,ExchangeRate,ExCurrency,ExDurationFrom,GSTExchangeRate,GSTExCurrency,GSTTotalAmount,DocumentState,IsNoSupportingDocument,IsGstSettings,IsMultiCurrency,IsAllowableNonAllowable,
											IsGSTCurrencyRateChanged,Remarks,UserCreated,CreatedDate,Status,DocumentDescription,CreationType,GrandDocDebitTotal,GrandDocCreditTotal,GrandBaseDebitTotal,GrandBaseCreditTotal,EntityId,EntityType,PostingDate,COAId,ModeOfReceipt,BankReceiptAmmount,ExcessPaidByClientAmmount,BalancingItemReciveCRAmount, 
											BalancingItemPayDRAmount,ReceiptApplicationAmmount,DocumentId, BankClearingDate ,IsBalancing,ISAllowDisAllow, IsShow, ActualSysRefNo ,IsSegmentReporting, TransferRefNo
										)
				Select @MasterJournalId,@CompanyId,DocDate,@DocType,@DocSubType,DocNo,ServiceCompanyId,@MasterSystemRefNo As SystemRefNo,IsNoSupportingDocument,NoSupportingDocs,DocCurrency,ExchangeRate,ExCurrency,ExDurationFrom,GSTExchangeRate,GSTExCurrency,Isnull(GSTTotalAmount,0),DocumentState,NoSupportingDocs,IsGstSettings,IsMultiCurrency,IsAllowableDisallowable,IsGSTCurrencyRateChanged,Remarks,@UserCreated,@CreatedDate,Status,Remarks As DocDescription,@UserCreated,GrandTotal,0.00 As GrandDocCreditTotal,Round(GrandTotal * ExchangeRate,2) As GrandBaseDebitTotal,
						0.00 As GrandBaseCreditTotal,EntityId,EntityType,DocDate As PostingDate,COAId,ModeOfReceipt,0.00 As BankReceiptAmmount,0.00 As ExcessPaidByClientAmmount,0.00 As BalancingItemReciveCRAmount,0.00 As BalancingItemPayDRAmount,0.00 As ReceiptApplicationAmmount,Id As DocumentId,BankClearingDate,0 As IsBalancing,IsDisAllow,1 As IsShow,DocNo As ActualSysRefNo,0 As IsSegmentReporting, PaymentRefNo
				From Bean.Payment Where CompanyId=@CompanyId And Id=@SourceId
				-- Opt : Replaced Set with Select
				Select @MainInterCoServCompCOAID= COA.Id 
				From Bean.ChartOfAccount As COA 
				Inner Join Bean.AccountType As ACT On ACT.Id=COA.AccountTypeId
				Where ACT.CompanyId=@CompanyId And ACT.Name=@IntercompClearingCOAName 
				And COA.SubsidaryCompanyId=@MasterServComp
				
				IF @DocCurrency=@BankChargesCurrency And @DocCurrency=@BaseCurrency
				Begin
					Set @RecOrder=@RecOrder+1
					/* Creating Mater record In JournalDetail */
					Insert Into Bean.JournalDetail (Id,JournalId,COAId,AccountDescription,AllowDisAllow, DocCredit, BaseCredit, DocDebitTotal,DocCreditTotal,BaseDebitTotal,BaseCreditTotal,DocumentId,DocumentDetailId,ItemId,BaseCurrency,
													ExchangeRate,GSTExCurrency,GSTExchangeRate,DocType,DocSubType,ServiceCompanyId,DocNo, IsTax,EntityId, SystemRefNo, DocCurrency,DocDate, PostingDate,RecOrder )
					Select NEWID(),@MasterJournalId,COAId,Remarks,IsDisAllow,GrandTotal,Round(GrandTotal * @DefaultExchangeRate,2),0.00 As DocDebitTotal,0.00 As DocCreditTotal,0.00 As BaseDebitTotal,0.00 As BaseCreditTotal,Id As DocumnetId,@GUIDZero,@GUIDZero,
							BaseCurrency,@DefaultExchangeRate As ExchangeRate,GSTExCurrency,GSTExchangeRate,@DocType,@DocSubType,ServiceCompanyId,DocNo,0 As IsTax,
							EntityId,@MasterSystemRefNo As SystemRefNo,@BankChargesCurrency,DocDate,DocDate,@RecOrder As RecOrder
					From Bean.Payment Where Id=@SourceId
					-- Master Servc Company Detail Records
					IF Exists(Select Id From Bean.PaymentDetail Where PaymentId=@SourceId And PaymentAmount<>0 And ServiceCompanyId=@MasterServComp)
					Begin
						Insert Into @PaymentDtl
						Select Id From Bean.PaymentDetail Where PaymentId=@SourceId And PaymentAmount<>0 And ServiceCompanyId=@MasterServComp
						Set @RecCount=1
						-- Opt : Replaced Set with Select
						Select @Count= Count(*) From @PaymentDtl
						While @Count>=@RecCount
						Begin
							-- Opt : Replaced Set with Select
							Select @PaymentDtlId= PaymentDtlId From @PaymentDtl Where S_No=@RecCount
							Select @DocumentId= DocumentId From Bean.PaymentDetail Where Id=@PaymentDtlId
							Select @OffSetDocumentType= DocumentType From bean.PaymentDetail Where Id=@PaymentDtlId
							IF Exists (Select Id From Bean.PaymentDetail Where Id=@PaymentDtlId And Nature=@NatureTrade)
							Begin
								-- Opt : Replaced Set with Select
								Select @COAID= Id From Bean.ChartOfAccount Where CompanyId=@CompanyId And Name=@COATradePayables
							End
							Else IF Exists (Select Id From Bean.PaymentDetail Where Id=@PaymentDtlId And Nature=@NatureOthers)
							Begin
							-- Opt : Replaced Set with Select
								Select @COAID= Id From Bean.ChartOfAccount Where CompanyId=@CompanyId And Name=@COAOtherPayables
							End
							IF @OffSetDocumentType=@InvoiceDocument
							Begin
								IF Exists (Select Id From Bean.Invoice Where Id=@DocumentId And DocumentState In (@FullyApplied,@Fullypaid))
								Begin
									Set @IsRoundingAmount=1
								End 
							End
							Else IF @OffSetDocumentType=@DebitNoteDocument
							Begin
								IF Exists (Select Id From Bean.DebitNote Where Id=@DocumentId And DocumentState In (@FullyApplied,@Fullypaid))
								Begin
									Set @IsRoundingAmount=1
								End 
							End
							Else IF @OffSetDocumentType in (@BillDocument,@PayrollBill,@openBal,@Payroll,@Claim,@General)
							Begin
								IF Exists (Select Id From Bean.Bill Where Id=@DocumentId And DocumentState In (@FullyApplied,@Fullypaid))
								Begin
									Set @IsRoundingAmount=1
								End 
							End

							IF @IsRoundingAmount=1 And Exists (Select Amount From @RoundingAmountDetails Where DocumentId=@DocumentId And Amount Is Not Null And Amount<>'') --And @RoundingAmount Is Not Null And @RoundingAmount <>''
							Begin
								-- Opt : Replaced Set with Select
								Select @DocAmount= Amount From @RoundingAmountDetails Where DocumentId=@DocumentId
							End
							Else
							Begin
								Set @DocAmount=0
							End
							Set @RecOrder=@RecOrder+1
							Insert Into Bean.JournalDetail (Id,JournalId,COAId,AccountDescription, DocDebit,DocCredit,BaseDebit,BaseCredit,DocDebitTotal,DocCreditTotal,BaseDebitTotal,BaseCreditTotal,
															DocumentId,DocumentDetailId,ItemId,BaseCurrency,ExchangeRate, DocType,DocSubType,ServiceCompanyId,DocNo,Nature,OffsetDocument,IsTax,
															EntityId, SystemRefNo, DocCurrency,DocDate, PostingDate,RecOrder 
															)
							Select NEWID(),@MasterJournalId,@COAID,P.Remarks,PD.PaymentAmount As DocDebit,Null As DocCredit,
								Round(PD.PaymentAmount * @DefaultExchangeRate,2)-Isnull(@DocAmount,0) As BaseDebit,Null As BaseCredit,
								0.00 As DocDebitTotal,0.00 As DocCreditTotal,0.00 As BaseDebitTotal,0.00 As BaseCreditTotal,P.Id As DocumnetId,PD.Id As DocumentDetailId,@GUIDZero,
								P.BaseCurrency,@DefaultExchangeRate As ExchangeRate,@DocType,@DocSubType,PD.ServiceCompanyId,P.DocNo,PD.Nature,Null As DocumentNo,0 As IsTax,
								P.EntityId,@MasterSystemRefNo,@BankChargesCurrency,P.DocDate,P.DocDate,@RecOrder As RecOrder
							From Bean.Payment As P
							Inner Join bean.PaymentDetail As PD On PD.PaymentId=P.Id
							Where P.Id=@SourceId And PD.Id=@PaymentDtlId
							Set @RecCount=@RecCount+1
						End
					End

					Insert Into @ServCompaIdTbl
					Select Distinct ServiceCompanyId From Bean.PaymentDetail Where PaymentId=@SourceId And PaymentAmount<>0 And ServiceCompanyId<>@MasterServComp
					-- Opt : Replaced Set with Select
					Select @Count= Count(*) From @ServCompaIdTbl
					Set @RecCount=1
					While @Count>=@RecCount
					Begin
						Set @RecOrder=@RecOrder+1
						-- Opt : Replaced Set with Select
						Select @ServCompId= SerCompId From @ServCompaIdTbl Where S_No=@RecCount
						Select @PaymentAmtTotal= Sum(Isnull(Case When DocumentType in (@InvoiceDocument,@DebitNoteDocument,@CreditMemoDocument) Then -(PaymentAmount)
																	 Else PaymentAmount End,0)) 
						From Bean.PaymentDetail Where PaymentId=@SourceId 
						And ServiceCompanyId=@ServCompId

						Select @IntroCompCOAID= COA.Id From Bean.ChartOfAccount As COA 
						Inner Join Bean.AccountType As ACT On ACT.Id=COA.AccountTypeId
						Where ACT.CompanyId=@CompanyId And ACT.Name=@IntercompClearingCOAName And COA.SubsidaryCompanyId=@ServCompId
						
						Insert Into Bean.JournalDetail (Id,JournalId,COAId,AccountDescription,AllowDisAllow, DocDebit, BaseDebit, DocDebitTotal,DocCreditTotal,BaseDebitTotal,BaseCreditTotal,DocumentId,DocumentDetailId,ItemId,BaseCurrency,
														ExchangeRate,GSTExCurrency,GSTExchangeRate,DocType,DocSubType,ServiceCompanyId,DocNo, IsTax,EntityId, SystemRefNo, DocCurrency,DocDate, PostingDate,RecOrder )
						Select NEWID(),@MasterJournalId,@IntroCompCOAID,P.Remarks,IsDisAllow,@PaymentAmtTotal,Round(@PaymentAmtTotal * @DefaultExchangeRate,2),0.00 As DocDebitTotal,0.00 As DocCreditTotal,0.00 As BaseDebitTotal,0.00 As BaseCreditTotal,P.Id As DocumnetId,@GUIDZero,@GUIDZero,
								BaseCurrency,@DefaultExchangeRate As ExchangeRate,GSTExCurrency,GSTExchangeRate,@DocType,@DocSubType,@ServCompId,DocNo,0 As IsTax,
								EntityId,@MasterSystemRefNo As SystemRefNo,@BankChargesCurrency,DocDate,DocDate,@RecOrder As RecOrder
						From Bean.Payment As P
						Where P.Id=@SourceId 

						-- Another JV For Different Service Company
						Set @SysRefNumOrder=@SysRefNumOrder+1
						Set @SystemRefNo=Concat(@DocNo,'-JV',@SysRefNumOrder)
						Set @JournalId=NEWID()
						Insert Into Bean.Journal (Id,CompanyId,DocDate,DocType,DocSubType,DocNo,ServiceCompanyId,SystemReferenceNo,IsNoSupportingDocs,NoSupportingDocument,DocCurrency,ExchangeRate,ExCurrency,ExDurationFrom,GSTExchangeRate,GSTExCurrency,GSTTotalAmount,DocumentState,IsNoSupportingDocument,IsGstSettings,IsMultiCurrency,IsAllowableNonAllowable,
													IsGSTCurrencyRateChanged,Remarks,UserCreated,CreatedDate,Status,DocumentDescription,CreationType,GrandDocDebitTotal,GrandDocCreditTotal,GrandBaseDebitTotal,GrandBaseCreditTotal,EntityId,EntityType,PostingDate,COAId,ModeOfReceipt,BankReceiptAmmount,ExcessPaidByClientAmmount,BalancingItemReciveCRAmount, 
													BalancingItemPayDRAmount,ReceiptApplicationAmmount,DocumentId, BankClearingDate ,IsBalancing,ISAllowDisAllow, IsShow, ActualSysRefNo ,IsSegmentReporting,TransferRefNo
												)
						Select @JournalId,@CompanyId,DocDate,@DocType,@DocSubType,DocNo,@ServCompId,@SystemRefNo As SystemRefNo,IsNoSupportingDocument,NoSupportingDocs,DocCurrency,ExchangeRate,ExCurrency,ExDurationFrom,GSTExchangeRate,GSTExCurrency,Isnull(GSTTotalAmount,0),DocumentState,NoSupportingDocs,IsGstSettings,IsMultiCurrency,IsAllowableDisallowable,IsGSTCurrencyRateChanged,Remarks,@UserCreated,@CreatedDate,Status,Remarks As DocDescription,@UserCreated,GrandTotal,0.00 As GrandDocCreditTotal,Round(GrandTotal * ExchangeRate,2) As GrandBaseDebitTotal,
								0.00 As GrandBaseCreditTotal,EntityId,EntityType,DocDate As PostingDate,COAId,ModeOfReceipt,0.00 As BankReceiptAmmount,0.00 As ExcessPaidByClientAmmount,0.00 As BalancingItemReciveCRAmount,0.00 As BalancingItemPayDRAmount,0.00 As ReceiptApplicationAmmount,Id As DocumentId,BankClearingDate,0 As IsBalancing,IsDisAllow,1 As IsShow,DocNo As ActualSysRefNo,0 As IsSegmentReporting, PaymentRefNo
						From Bean.Payment Where CompanyId=@CompanyId And Id=@SourceId
						
						Insert Into Bean.JournalDetail (Id,JournalId,COAId,AccountDescription,AllowDisAllow, DocCredit, BaseCredit, DocDebitTotal,DocCreditTotal,BaseDebitTotal,BaseCreditTotal,DocumentId,DocumentDetailId,ItemId,BaseCurrency,ExchangeRate,GSTExCurrency,GSTExchangeRate,DocType,DocSubType,ServiceCompanyId,DocNo, IsTax,
														EntityId, SystemRefNo, DocCurrency,DocDate, PostingDate,RecOrder )
						Select NEWID(),@JournalId,@MainInterCoServCompCOAID,P.Remarks,IsDisAllow,@PaymentAmtTotal,Round(@PaymentAmtTotal * @DefaultExchangeRate,2),0.00 As DocDebitTotal,0.00 As DocCreditTotal,0.00 As BaseDebitTotal,0.00 As BaseCreditTotal,P.Id As DocumnetId,@GUIDZero,@GUIDZero,
								BaseCurrency,@DefaultExchangeRate As ExchangeRate,GSTExCurrency,GSTExchangeRate,@DocType,@DocSubType,@ServCompId,DocNo,0 As IsTax,
								EntityId,@SystemRefNo As SystemRefNo,@BankChargesCurrency,DocDate,DocDate,@RecOrder As RecOrder
						From Bean.Payment As P
						Where P.Id=@SourceId 
															
						IF Exists(Select Id From Bean.PaymentDetail Where PaymentId=@SourceId And PaymentAmount<>0 And ServiceCompanyId=@ServCompId)
						Begin
							Delete From @PaymentDtl_New
							Insert Into @PaymentDtl_New
							Select ROW_NUMBER() Over (Order By Id),Id From Bean.PaymentDetail Where PaymentId=@SourceId And PaymentAmount<>0 And ServiceCompanyId=@ServCompId
							Set @RdtlRecCount=1
							-- Opt : Replaced Set with Select
							Select @DtlCount= Count(*) From @PaymentDtl_New
							While @DtlCount>=@RdtlRecCount
							Begin
								-- Opt : Replaced Set with Select
								Select @PaymentDtlId= PaymentDtlId From @PaymentDtl_New Where S_No=@RdtlRecCount
								Select @DocumentId= DocumentId From Bean.PaymentDetail Where id=@PaymentDtlId
								Select @OffSetDocumentType= DocumentType From bean.PaymentDetail Where Id=@PaymentDtlId
								Set @IsRoundingAmount=0
								IF Exists (Select Id From Bean.PaymentDetail Where Id=@PaymentDtlId And Nature=@NatureTrade)
								Begin
									-- Opt : Replaced Set with Select
									Select @COAID= Id From Bean.ChartOfAccount Where CompanyId=@CompanyId And Name=@COATradePayables
								End
								Else IF Exists (Select Id From Bean.PaymentDetail Where Id=@PaymentDtlId And Nature=@NatureOthers)
								Begin
									-- Opt : Replaced Set with Select
									Select @COAID= Id From Bean.ChartOfAccount Where CompanyId=@CompanyId And Name=@COAOtherPayables
								End
								IF @OffSetDocumentType=@InvoiceDocument
								Begin
									IF Exists (Select Id From Bean.Invoice Where Id=@DocumentId And DocumentState In (@FullyApplied,@Fullypaid))
									Begin
										Set @IsRoundingAmount=1
									End 
								End
								Else IF @OffSetDocumentType=@DebitNoteDocument
								Begin
									IF Exists (Select Id From Bean.DebitNote Where Id=@DocumentId And DocumentState In (@FullyApplied,@Fullypaid))
									Begin
										Set @IsRoundingAmount=1
									End 
								End
								Else IF @OffSetDocumentType in (@BillDocument,@PayrollBill,@openBal,@Payroll,@Claim,@General)
								Begin
									IF Exists (Select Id From Bean.Bill Where Id=@DocumentId And DocumentState In (@FullyApplied,@Fullypaid))
									Begin
										Set @IsRoundingAmount=1
									End 
								End

								IF @IsRoundingAmount=1 And Exists (Select Amount From @RoundingAmountDetails Where DocumentId=@DocumentId And Amount Is Not Null And Amount<>'') --And @RoundingAmount Is Not Null And @RoundingAmount <>''
								Begin
									-- Opt : Replaced Set with Select
									Select @DocAmount= Amount 
									From @RoundingAmountDetails Where DocumentId=@DocumentId
								End
								Else
								Begin
									Set @DocAmount=0
								End
								Set @RecOrder=@RecOrder+1
								Insert Into Bean.JournalDetail (Id,JournalId,COAId,AccountDescription, DocDebit,DocCredit,
																 BaseDebit,BaseCredit,
																 DocDebitTotal,DocCreditTotal,BaseDebitTotal,BaseCreditTotal,DocumentId,DocumentDetailId,ItemId,BaseCurrency,ExchangeRate, DocType,DocSubType,
																 ServiceCompanyId,DocNo,Nature,OffsetDocument,IsTax,EntityId, SystemRefNo, DocCurrency,DocDate, PostingDate,RecOrder 
																)
								Select NEWID(),@JournalId,@COAID,P.Remarks,PD.PaymentAmount As DocDebit,Null As DocCredit,
									Round(PD.PaymentAmount * @DefaultExchangeRate,2)-Isnull(@DocAmount,0) As BaseDebit,Null As BaseCredit,
									0.00 As DocDebitTotal,0.00 As DocCreditTotal,0.00 As BaseDebitTotal,0.00 As BaseCreditTotal,P.Id As DocumnetId,PD.Id As DocumentDetailId,@GUIDZero,
									P.BaseCurrency,@DefaultExchangeRate As ExchangeRate,@DocType,@DocSubType,PD.ServiceCompanyId,P.DocNo,PD.Nature,Null As DocumentNo,0 As IsTax,
									P.EntityId,@SystemRefNo,@DocCurrency,P.DocDate,P.DocDate,@RecOrder As RecOrder
								From Bean.Payment As P
								Inner Join bean.PaymentDetail As PD On PD.PaymentId=P.Id
								Where P.Id=@SourceId And PD.Id=@PaymentDtlId
								Set @RdtlRecCount=@RdtlRecCount+1
							End
						End
						Set @RecCount=@RecCount+1
					End
				End
				Else IF @DocCurrency=@BankChargesCurrency And @DocCurrency<>@BaseCurrency
				Begin
					Set @RecOrder=@RecOrder+1
					/* Creating Mater record In JournalDetail */
					Insert Into Bean.JournalDetail (Id,JournalId,COAId,AccountDescription,AllowDisAllow, DocCredit, BaseCredit, DocDebitTotal,DocCreditTotal,BaseDebitTotal,BaseCreditTotal,DocumentId,DocumentDetailId,ItemId,BaseCurrency,ExchangeRate,
													GSTExCurrency,GSTExchangeRate,DocType,DocSubType,ServiceCompanyId,DocNo, IsTax,EntityId, SystemRefNo, DocCurrency,DocDate, PostingDate,RecOrder )
					Select NEWID(),@MasterJournalId,COAId,Remarks,IsDisAllow,GrandTotal,Round(GrandTotal * ExchangeRate,2),0.00 As DocDebitTotal,0.00 As DocCreditTotal,0.00 As BaseDebitTotal,0.00 As BaseCreditTotal,Id As DocumnetId,@GUIDZero,@GUIDZero,
							BaseCurrency,ExchangeRate As ExchangeRate,GSTExCurrency,GSTExchangeRate,@DocType,@DocSubType,ServiceCompanyId,DocNo,0 As IsTax,
							EntityId,@MasterSystemRefNo As SystemRefNo,@BankChargesCurrency,DocDate,DocDate,@RecOrder As RecOrder
					From Bean.Payment Where Id=@SourceId
					-- Master Servc Company Detail Records
					IF Exists(Select Id From Bean.PaymentDetail Where PaymentId=@SourceId And PaymentAmount<>0 And ServiceCompanyId=@MasterServComp)
					Begin
						Insert Into @PaymentDtl
						Select Id From Bean.PaymentDetail Where PaymentId=@SourceId And PaymentAmount<>0 And ServiceCompanyId=@MasterServComp
						Set @RecCount=1
						-- Opt : Replaced Set with Select
						Select @Count= Count(*) From @PaymentDtl
						While @Count>=@RecCount
						Begin
							-- Opt : Replaced Set with Select
							Select @PaymentDtlId= PaymentDtlId From @PaymentDtl Where S_No=@RecCount
							IF Exists (Select Id From Bean.PaymentDetail Where Id=@PaymentDtlId And Nature=@NatureTrade)
							Begin
								-- Opt : Replaced Set with Select
								Select @COAID= Id From Bean.ChartOfAccount Where CompanyId=@CompanyId And Name=@COATradePayables
							End
							Else IF Exists (Select Id From Bean.PaymentDetail Where Id=@PaymentDtlId And Nature=@NatureOthers)
							Begin
								-- Opt : Replaced Set with Select
								Select @COAID= Id From Bean.ChartOfAccount Where CompanyId=@CompanyId And Name=@COAOtherPayables
							End
							-- Opt : Replaced Set with Select
							Select @DocumentId= DocumentId From Bean.PaymentDetail Where Id=@PaymentDtlId
							Select @OffSetDocumentType= DocumentType From Bean.PaymentDetail Where Id=@PaymentDtlId
							
							IF @OffSetDocumentType=@InvoiceDocument
							Begin
								-- Opt : Replaced Set with Select
								Select @ExchangeRate= ExchangeRate From Bean.Invoice Where Id=@DocumentId
								IF Exists (Select Id From Bean.Invoice Where Id=@DocumentId And DocumentState In (@FullyApplied,@Fullypaid))
								Begin
									Set @IsRoundingAmount=1
								End 
							End
							Else IF @OffSetDocumentType=@DebitNoteDocument
							Begin
								-- Opt : Replaced Set with Select
								Select @ExchangeRate= ExchangeRate From Bean.DebitNote Where Id=@DocumentId
								IF Exists (Select Id From Bean.DebitNote Where Id=@DocumentId And DocumentState In (@FullyApplied,@Fullypaid))
								Begin
									Set @IsRoundingAmount=1
								End 
							End
							Else IF @OffSetDocumentType in (@BillDocument,@PayrollBill,@openBal,@Payroll,@Claim,@General)
							Begin
								-- Opt : Replaced Set with Select
								Select @ExchangeRate= ExchangeRate From Bean.Bill Where Id=@DocumentId
								IF Exists (Select Id From Bean.Bill Where Id=@DocumentId And DocumentState In (@FullyApplied,@Fullypaid))
								Begin
									Set @IsRoundingAmount=1
								End 
							End

							IF @IsRoundingAmount=1 And Exists (Select Amount From @RoundingAmountDetails Where DocumentId=@DocumentId And Amount Is Not Null And Amount<>'') --And @RoundingAmount Is Not Null And @RoundingAmount <>''
							Begin
								-- Opt : Replaced Set with Select
								Select @DocAmount= Amount From @RoundingAmountDetails Where DocumentId=@DocumentId
							End
							Else
							Begin
								Set @DocAmount=0
							End
							Set @RecOrder=@RecOrder+1
							Insert Into Bean.JournalDetail (Id,JournalId,COAId,AccountDescription, DocDebit,DocCredit,
															 BaseDebit,BaseCredit,
															 DocDebitTotal,DocCreditTotal,BaseDebitTotal,BaseCreditTotal,DocumentId,DocumentDetailId,ItemId,BaseCurrency,ExchangeRate,
															 DocType,DocSubType,ServiceCompanyId,DocNo,Nature,OffsetDocument,IsTax,EntityId, SystemRefNo, DocCurrency,DocDate, PostingDate,RecOrder 
															)
							Select NEWID(),@MasterJournalId,@COAID,P.Remarks,PD.PaymentAmount As DocDebit,Null As DocCredit,
								Round(PD.PaymentAmount * @ExchangeRate,2)-Isnull(@DocAmount,0) As BaseDebit,Null As BaseCredit,
								0.00 As DocDebitTotal,0.00 As DocCreditTotal,0.00 As BaseDebitTotal,0.00 As BaseCreditTotal,P.Id As DocumnetId,PD.Id As DocumentDetailId,@GUIDZero,
								P.BaseCurrency,@ExchangeRate As ExchangeRate,@DocType,@DocSubType,PD.ServiceCompanyId,P.DocNo,PD.Nature,Null As DocumentNo,0 As IsTax,
								P.EntityId,@MasterSystemRefNo,@BankChargesCurrency,P.DocDate,P.DocDate,@RecOrder As RecOrder
							From Bean.Payment As P
							Inner Join bean.PaymentDetail As PD On PD.PaymentId=P.Id
							Where P.Id=@SourceId And PD.Id=@PaymentDtlId
							IF @MainExchangeRate-@ExchangeRate<>0
							Begin
								-- Exchangegain or Loss
								Set @RecOrder=@RecOrder+1
								-- Opt : Replaced Set with Select
								Select @COAID= Id From Bean.ChartOfAccount Where CompanyId=@CompanyId And Name=@ExchangeGainOrLossRealised
								Insert Into Bean.JournalDetail (Id,JournalId,COAId,AccountDescription, DocDebit,DocCredit,
																 BaseDebit,BaseCredit,
																 DocDebitTotal,DocCreditTotal,BaseDebitTotal,BaseCreditTotal,DocumentId,DocumentDetailId,ItemId,BaseCurrency,ExchangeRate,
																 DocType,DocSubType,ServiceCompanyId,DocNo,Nature,OffsetDocument,IsTax,EntityId, SystemRefNo, DocCurrency,DocDate, PostingDate,RecOrder 
																)
								Select NEWID(),@MasterJournalId,@COAID,P.Remarks,Null As DocDebit,Null As DocCredit,
									Case When (@MainExchangeRate-@ExchangeRate)>0 Then ABS(Round((@MainExchangeRate-@ExchangeRate)  * PD.PaymentAmount,2)) End As BaseDebit,Case When (@MainExchangeRate-@ExchangeRate)<0 Then ABS(Round((@MainExchangeRate-@ExchangeRate) * PD.PaymentAmount,2) ) End As BaseCredit,
									0.00 As DocDebitTotal,0.00 As DocCreditTotal,0.00 As BaseDebitTotal,0.00 As BaseCreditTotal,P.Id As DocumnetId,PD.Id As DocumentDetailId,@GUIDZero,
									P.BaseCurrency,P.ExchangeRate,@DocType,@DocSubType,PD.ServiceCompanyId,P.DocNo,PD.Nature,PD.DocumentNo,0 As IsTax,
									EntityId,@MasterSystemRefNo,@BankChargesCurrency,DocDate,DocDate,@RecOrder As RecOrder
								From Bean.Payment As P
								Inner Join bean.PaymentDetail As PD On PD.PaymentId=P.Id
								Where P.Id=@SourceId And PD.Id=@PaymentDtlId
							End
							Set @RecCount=@RecCount+1
						End
					End
					-- ServComp Records
					Insert Into @ServCompaIdTbl
					Select Distinct ServiceCompanyId From Bean.PaymentDetail Where PaymentId=@SourceId And PaymentAmount<>0 And ServiceCompanyId<>@MasterServComp
					-- Opt : Replaced Set with Select
					Select @Count= Count(*) From @ServCompaIdTbl
					Set @RecCount=1
					While @Count>=@RecCount
					Begin
						Set @RecOrder=@RecOrder+1
						-- Opt : Replaced Set with Select
						Select @ServCompId= SerCompId From @ServCompaIdTbl Where S_No=@RecCount
						Select @PaymentAmtTotal= Sum(Isnull(Case When DocumentType in (@InvoiceDocument,@DebitNoteDocument,@CreditMemoDocument) Then -(PaymentAmount)
																	 Else PaymentAmount End,0)) 
						From Bean.PaymentDetail Where PaymentId=@SourceId And ServiceCompanyId=@ServCompId
						Select @IntroCompCOAID= COA.Id 
						From Bean.ChartOfAccount As COA 
						Inner Join Bean.AccountType As ACT On ACT.Id=COA.AccountTypeId
						Where ACT.CompanyId=@CompanyId And ACT.Name=@IntercompClearingCOAName And COA.SubsidaryCompanyId=@ServCompId

						Insert Into Bean.JournalDetail (Id,JournalId,COAId,AccountDescription,AllowDisAllow, DocDebit, BaseDebit, DocDebitTotal,DocCreditTotal,BaseDebitTotal,BaseCreditTotal,DocumentId,DocumentDetailId,ItemId,BaseCurrency,ExchangeRate,GSTExCurrency,GSTExchangeRate,DocType,DocSubType,ServiceCompanyId,DocNo, IsTax,
														EntityId, SystemRefNo, DocCurrency,DocDate, PostingDate,RecOrder )
						Select NEWID(),@MasterJournalId,@IntroCompCOAID,P.Remarks,IsDisAllow,@PaymentAmtTotal,Round(@PaymentAmtTotal * ExchangeRate,2),0.00 As DocDebitTotal,0.00 As DocCreditTotal,0.00 As BaseDebitTotal,0.00 As BaseCreditTotal,P.Id As DocumnetId,@GUIDZero,@GUIDZero,
								BaseCurrency,ExchangeRate As ExchangeRate,GSTExCurrency,GSTExchangeRate,@DocType,@DocSubType,@ServCompId,DocNo,0 As IsTax,
								EntityId,@MasterSystemRefNo As SystemRefNo,@BankChargesCurrency,DocDate,DocDate,@RecOrder As RecOrder
						From Bean.Payment As P
						Where P.Id=@SourceId 

						-- Another JV For Different Service Company
						Set @JournalId=NEWID()
						Set @SysRefNumOrder=@SysRefNumOrder+1
						Set @SystemRefNo=Concat(@DocNo,'-JV',@SysRefNumOrder)
						Insert Into Bean.Journal (Id,CompanyId,DocDate,DocType,DocSubType,DocNo,ServiceCompanyId,SystemReferenceNo,IsNoSupportingDocs,NoSupportingDocument,DocCurrency,ExchangeRate,ExCurrency,ExDurationFrom,GSTExchangeRate,GSTExCurrency,GSTTotalAmount,DocumentState,IsNoSupportingDocument,IsGstSettings,IsMultiCurrency,IsAllowableNonAllowable,IsGSTCurrencyRateChanged,Remarks,UserCreated,CreatedDate,Status,DocumentDescription,CreationType,GrandDocDebitTotal,GrandDocCreditTotal,GrandBaseDebitTotal,
												GrandBaseCreditTotal,EntityId,EntityType,PostingDate,COAId,ModeOfReceipt,BankReceiptAmmount,ExcessPaidByClientAmmount,BalancingItemReciveCRAmount,  BalancingItemPayDRAmount,ReceiptApplicationAmmount,DocumentId, BankClearingDate ,IsBalancing,ISAllowDisAllow, IsShow, ActualSysRefNo 
												,IsSegmentReporting, TransferRefNo
												)
						Select @JournalId,@CompanyId,DocDate,@DocType,@DocSubType,DocNo,@ServCompId,@SystemRefNo As SystemRefNo,IsNoSupportingDocument,NoSupportingDocs,DocCurrency,ExchangeRate,ExCurrency,ExDurationFrom,GSTExchangeRate,GSTExCurrency,Isnull(GSTTotalAmount,0),DocumentState,NoSupportingDocs,IsGstSettings,IsMultiCurrency,IsAllowableDisallowable,IsGSTCurrencyRateChanged,Remarks,@UserCreated,@CreatedDate,Status,Remarks As DocDescription,@UserCreated,GrandTotal,0.00 As GrandDocCreditTotal,Round(GrandTotal * ExchangeRate,2) As GrandBaseDebitTotal,
								0.00 As GrandBaseCreditTotal,EntityId,EntityType,DocDate As PostingDate,COAId,ModeOfReceipt,0.00 As BankReceiptAmmount,0.00 As ExcessPaidByClientAmmount,0.00 As BalancingItemReciveCRAmount,0.00 As BalancingItemPayDRAmount,0.00 As ReceiptApplicationAmmount,Id As DocumentId,BankClearingDate,0 As IsBalancing,IsDisAllow,1 As IsShow,DocNo As ActualSysRefNo,0 As IsSegmentReporting, PaymentRefNo
						From Bean.Payment Where CompanyId=@CompanyId And Id=@SourceId
						
						Insert Into Bean.JournalDetail (Id,JournalId,COAId,AccountDescription,AllowDisAllow, DocCredit, BaseCredit, DocDebitTotal,DocCreditTotal,BaseDebitTotal,BaseCreditTotal,DocumentId,DocumentDetailId,ItemId,BaseCurrency,ExchangeRate,GSTExCurrency,GSTExchangeRate,DocType,DocSubType,ServiceCompanyId,DocNo, IsTax,
														EntityId, SystemRefNo, DocCurrency,DocDate, PostingDate,RecOrder )
						Select NEWID(),@JournalId,@MainInterCoServCompCOAID,P.Remarks,IsDisAllow,@PaymentAmtTotal,Round(@PaymentAmtTotal * ExchangeRate,2),0.00 As DocDebitTotal,0.00 As DocCreditTotal,0.00 As BaseDebitTotal,0.00 As BaseCreditTotal,P.Id As DocumnetId,@GUIDZero,@GUIDZero,
								BaseCurrency,ExchangeRate As ExchangeRate,GSTExCurrency,GSTExchangeRate,@DocType,@DocSubType,@ServCompId,DocNo,0 As IsTax,
								EntityId,@SystemRefNo As SystemRefNo,@BankChargesCurrency,DocDate,DocDate,@RecOrder As RecOrder
						From Bean.Payment As P
						Where P.Id=@SourceId 
															
						IF Exists(Select Id From Bean.PaymentDetail Where PaymentId=@SourceId And PaymentAmount<>0 And ServiceCompanyId=@ServCompId)
						Begin
							Delete From @PaymentDtl_New
							Insert Into @PaymentDtl_New
							Select ROW_NUMBER() Over (Order By Id),Id From Bean.PaymentDetail Where PaymentId=@SourceId And PaymentAmount<>0 And ServiceCompanyId=@ServCompId
							Set @RdtlRecCount=1
							-- Opt : Replaced Set with Select
							Select @DtlCount= Count(*) From @PaymentDtl_New
							While @DtlCount>=@RdtlRecCount
							Begin
								-- Opt : Replaced Set with Select
								Select @PaymentDtlId= PaymentDtlId From @PaymentDtl_New Where S_No=@RdtlRecCount
								IF Exists (Select Id From Bean.PaymentDetail Where Id=@PaymentDtlId And Nature=@NatureTrade)
								Begin
									-- Opt : Replaced Set with Select
									Select @COAID= Id From Bean.ChartOfAccount Where CompanyId=@CompanyId And Name=@COATradePayables
								End
								Else IF Exists (Select Id From Bean.PaymentDetail Where Id=@PaymentDtlId And Nature=@NatureOthers)
								Begin
									-- Opt : Replaced Set with Select
									Select @COAID= Id From Bean.ChartOfAccount Where CompanyId=@CompanyId And Name=@COAOtherPayables
								End
								-- Opt : Replaced Set with Select
								Select @DocumentId= DocumentId From Bean.PaymentDetail Where Id=@PaymentDtlId
								Select @OffSetDocumentType= DocumentType From Bean.PaymentDetail Where Id=@PaymentDtlId
							
								IF @OffSetDocumentType=@InvoiceDocument
								Begin
									-- Opt : Replaced Set with Select
									Select @ExchangeRate= ExchangeRate From Bean.Invoice Where Id=@DocumentId
									IF Exists (Select Id From Bean.Invoice Where Id=@DocumentId And DocumentState In (@FullyApplied,@Fullypaid))
									Begin
										Set @IsRoundingAmount=1
									End 
								End
								Else IF @OffSetDocumentType=@DebitNoteDocument
								Begin
									-- Opt : Replaced Set with Select
									Select @ExchangeRate= ExchangeRate From Bean.DebitNote Where Id=@DocumentId
									IF Exists (Select Id From Bean.DebitNote Where Id=@DocumentId And DocumentState In (@FullyApplied,@Fullypaid))
									Begin
										Set @IsRoundingAmount=1
									End 
								End
								Else IF @OffSetDocumentType in (@BillDocument,@General,@Payroll,@PayrollBill,@openBal,@Claim)
								Begin
									-- Opt : Replaced Set with Select
									Select @ExchangeRate= ExchangeRate From Bean.Bill Where Id=@DocumentId
									IF Exists (Select Id From Bean.Bill Where Id=@DocumentId And DocumentState In (@FullyApplied,@Fullypaid))
									Begin
										Set @IsRoundingAmount=1
									End 
								End

								IF @IsRoundingAmount=1 And Exists (Select Amount From @RoundingAmountDetails Where DocumentId=@DocumentId And Amount Is Not Null And Amount<>'') --And @RoundingAmount Is Not Null And @RoundingAmount <>''
								Begin
									-- Opt : Replaced Set with Select
									Select @DocAmount= Amount From @RoundingAmountDetails Where DocumentId=@DocumentId
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
								Select NEWID(),@JournalId,@COAID,P.Remarks,PD.PaymentAmount As DocDebit,Null As DocCredit,
									Round(PD.PaymentAmount * @ExchangeRate,2)-Isnull(@DocAmount,0) As BaseDebit,Null As BaseCredit,
									0.00 As DocDebitTotal,0.00 As DocCreditTotal,0.00 As BaseDebitTotal,0.00 As BaseCreditTotal,P.Id As DocumnetId,PD.Id As DocumentDetailId,@GUIDZero,
									P.BaseCurrency,@DefaultExchangeRate As ExchangeRate,@DocType,@DocSubType,PD.ServiceCompanyId,P.DocNo,PD.Nature,Null As DocumentNo,0 As IsTax,
									P.EntityId,@SystemRefNo,@DocCurrency,P.DocDate,P.DocDate,@RecOrder As RecOrder
								From Bean.Payment As P
								Inner Join bean.PaymentDetail As PD On PD.PaymentId=P.Id
								Where P.Id=@SourceId And PD.Id=@PaymentDtlId
								IF @MainExchangeRate-@ExchangeRate<>0
								Begin
									-- Exchangegain or Loss
									Set @RecOrder=@RecOrder+1
									-- Opt : Replaced Set with Select
									Select @COAID= Id From Bean.ChartOfAccount Where CompanyId=@CompanyId And Name=@ExchangeGainOrLossRealised
									Insert Into Bean.JournalDetail (Id,JournalId,COAId,AccountDescription, DocDebit,DocCredit,
																	 BaseDebit,BaseCredit,
																	 DocDebitTotal,DocCreditTotal,BaseDebitTotal,BaseCreditTotal,DocumentId,DocumentDetailId,ItemId,BaseCurrency,ExchangeRate, DocType,DocSubType,ServiceCompanyId,DocNo,Nature,OffsetDocument,IsTax,
																	EntityId, SystemRefNo, DocCurrency,DocDate, PostingDate,RecOrder 
																	)
									Select NEWID(),@JournalId,@COAID,P.Remarks,Null As DocDebit,Null As DocCredit,
										Case When (@MainExchangeRate-@ExchangeRate)>0 Then ABS(Round((@MainExchangeRate-@ExchangeRate)  * PD.PaymentAmount,2)) End As BaseDebit,Case When (@MainExchangeRate-@ExchangeRate)<0 Then ABS(Round((@MainExchangeRate-@ExchangeRate) * PD.PaymentAmount,2) ) End As BaseCredit,
										0.00 As DocDebitTotal,0.00 As DocCreditTotal,0.00 As BaseDebitTotal,0.00 As BaseCreditTotal,P.Id As DocumnetId,PD.Id As DocumentDetailId,@GUIDZero,
										P.BaseCurrency,P.ExchangeRate,@DocType,@DocSubType,PD.ServiceCompanyId,P.DocNo,PD.Nature,PD.DocumentNo,0 As IsTax,
										EntityId,@SystemRefNo,@DocCurrency,DocDate,DocDate,@RecOrder As RecOrder
									From Bean.Payment As P
									Inner Join bean.PaymentDetail As PD On PD.PaymentId=P.Id
									Where P.Id=@SourceId And PD.Id=@PaymentDtlId
								End
								Set @RdtlRecCount=@RdtlRecCount+1
							End
						End
						Set @RecCount=@RecCount+1
					End
				End
				Else IF @DocCurrency<>@BankChargesCurrency And @DocCurrency=@BaseCurrency
				Begin
					/* Creating Mater record In JournalDetail */
					Insert Into Bean.JournalDetail (Id,JournalId,COAId,AccountDescription,AllowDisAllow, DocCredit, BaseCredit, DocDebitTotal,DocCreditTotal,BaseDebitTotal,BaseCreditTotal,DocumentId,DocumentDetailId,ItemId,BaseCurrency,ExchangeRate,GSTExCurrency,GSTExchangeRate,DocType,DocSubType,ServiceCompanyId,DocNo, IsTax,
									EntityId, SystemRefNo, DocCurrency,DocDate, PostingDate,RecOrder )
					Select NEWID(),@MasterJournalId,COAId,Remarks,IsDisAllow,GrandTotal,Round(GrandTotal * @SysCalExchangerate,2),0.00 As DocDebitTotal,0.00 As DocCreditTotal,0.00 As BaseDebitTotal,0.00 As BaseCreditTotal,Id As DocumnetId,@GUIDZero,@GUIDZero,
							BaseCurrency,@SysCalExchangerate As ExchangeRate,GSTExCurrency,GSTExchangeRate,@DocType,@DocSubType,ServiceCompanyId,DocNo,0 As IsTax,
							EntityId,@MasterSystemRefNo As SystemRefNo,@BankChargesCurrency,DocDate,DocDate,@RecOrder As RecOrder
					From Bean.Payment Where Id=@SourceId
					-- Clearing Payments
					-- Opt : Replaced Set with Select
					Select @ClearingPaymentsCOAID= Id From Bean.ChartOfAccount Where CompanyId=@CompanyId And Name=@ClearingPayments
					Insert Into Bean.JournalDetail (Id,JournalId,COAId,AccountDescription,AllowDisAllow, DocDebit, BaseDebit, DocDebitTotal,DocCreditTotal,BaseDebitTotal,BaseCreditTotal,DocumentId,DocumentDetailId,ItemId,BaseCurrency,ExchangeRate,GSTExCurrency,GSTExchangeRate,DocType,DocSubType,ServiceCompanyId,DocNo, IsTax,
									EntityId, SystemRefNo, DocCurrency,DocDate, PostingDate,RecOrder )
					Select NEWID(),@MasterJournalId,@ClearingPaymentsCOAID,Remarks,IsDisAllow,GrandTotal,Round(GrandTotal * @SysCalExchangerate,2),0.00 As DocDebitTotal,0.00 As DocCreditTotal,0.00 As BaseDebitTotal,0.00 As BaseCreditTotal,Id As DocumnetId,@GUIDZero,@GUIDZero,
							BaseCurrency,@SysCalExchangerate As ExchangeRate,GSTExCurrency,GSTExchangeRate,@DocType,@DocSubType,ServiceCompanyId,DocNo,0 As IsTax,
							EntityId,@MasterSystemRefNo As SystemRefNo,@BankChargesCurrency,DocDate,DocDate,@RecOrder As RecOrder
					From Bean.Payment Where Id=@SourceId
					-- 2nd Jv
					--Set @IntMstSeysRefNo= Concat(@DocNo,'-JV',Substring(Reverse(Substring(Reverse(@SystemRefNo),1,CHARINDEX('-',Reverse(@SystemRefNo)))),PATINDEX('%[0-9]%',@SystemRefNo),DATALENGTH(Reverse(Substring(Reverse(@SystemRefNo),1,CHARINDEX('-',Reverse(@SystemRefNo))))))+1)
					Set @SysRefNumOrder=@SysRefNumOrder+1
					Set @IntMstSeysRefNo=Concat(@DocNo,'-JV',@SysRefNumOrder)
					Set @IntMastJournalId=NEWID()
					Insert Into Bean.Journal (Id,CompanyId,DocDate,DocType,DocSubType,DocNo,ServiceCompanyId,SystemReferenceNo,IsNoSupportingDocs,NoSupportingDocument,DocCurrency,ExchangeRate,ExCurrency,ExDurationFrom,GSTExchangeRate,GSTExCurrency,GSTTotalAmount,DocumentState,IsNoSupportingDocument,IsGstSettings,IsMultiCurrency,IsAllowableNonAllowable,IsGSTCurrencyRateChanged,Remarks,UserCreated,CreatedDate,Status,DocumentDescription,CreationType,GrandDocDebitTotal,GrandDocCreditTotal,GrandBaseDebitTotal,
											GrandBaseCreditTotal,EntityId,EntityType,PostingDate,COAId,ModeOfReceipt,BankReceiptAmmount,ExcessPaidByClientAmmount,BalancingItemReciveCRAmount,  BalancingItemPayDRAmount,ReceiptApplicationAmmount,DocumentId, BankClearingDate ,IsBalancing,ISAllowDisAllow, IsShow, ActualSysRefNo 
											,IsSegmentReporting, TransferRefNo
											)
					Select @IntMastJournalId,@CompanyId,DocDate,@DocType,@DocSubType,DocNo,ServiceCompanyId,@IntMstSeysRefNo As SystemRefNo,IsNoSupportingDocument,NoSupportingDocs,DocCurrency,ExchangeRate,ExCurrency,ExDurationFrom,GSTExchangeRate,GSTExCurrency,Isnull(GSTTotalAmount,0),DocumentState,NoSupportingDocs,IsGstSettings,IsMultiCurrency,IsAllowableDisallowable,IsGSTCurrencyRateChanged,Remarks,@UserCreated,@CreatedDate,Status,Remarks As DocDescription,@UserCreated,GrandTotal,0.00 As GrandDocCreditTotal,Round(GrandTotal * ExchangeRate,2) As GrandBaseDebitTotal,
							0.00 As GrandBaseCreditTotal,EntityId,EntityType,DocDate As PostingDate,COAId,ModeOfReceipt,0.00 As BankReceiptAmmount,0.00 As ExcessPaidByClientAmmount,0.00 As BalancingItemReciveCRAmount,0.00 As BalancingItemPayDRAmount,0.00 As ReceiptApplicationAmmount,Id As DocumentId,BankClearingDate,0 As IsBalancing,IsDisAllow,1 As IsShow,DocNo As ActualSysRefNo,0 As IsSegmentReporting, PaymentRefNo
					From Bean.Payment Where CompanyId=@CompanyId And Id=@SourceId
					-- 2 nd Jv Clearing Payments			
					Insert Into Bean.JournalDetail (Id,JournalId,COAId,AccountDescription,AllowDisAllow, DocCredit, BaseCredit, DocDebitTotal,DocCreditTotal,BaseDebitTotal,BaseCreditTotal,DocumentId,DocumentDetailId,ItemId,BaseCurrency,ExchangeRate,GSTExCurrency,GSTExchangeRate,DocType,DocSubType,ServiceCompanyId,DocNo, IsTax,
									EntityId, SystemRefNo, DocCurrency,DocDate, PostingDate,RecOrder )
					Select NEWID(),@IntMastJournalId,@ClearingPaymentsCOAID,Remarks,IsDisAllow,PaymentApplicationAmmount,Round(PaymentApplicationAmmount * @DefaultExchangeRate,2),0.00 As DocDebitTotal,0.00 As DocCreditTotal,0.00 As BaseDebitTotal,0.00 As BaseCreditTotal,Id As DocumnetId,@GUIDZero,@GUIDZero,
							BaseCurrency,@DefaultExchangeRate As ExchangeRate,GSTExCurrency,GSTExchangeRate,@DocType,@DocSubType,ServiceCompanyId,DocNo,0 As IsTax,
							EntityId,@IntMstSeysRefNo As SystemRefNo,@DocCurrency,DocDate,DocDate,@RecOrder As RecOrder
					From Bean.Payment Where Id=@SourceId
					IF Exists(Select Id From Bean.PaymentDetail Where PaymentId=@SourceId And PaymentAmount<>0 And ServiceCompanyId=@MasterServComp)
					Begin
						Insert Into @PaymentDtl
						Select Id From Bean.PaymentDetail Where PaymentId=@SourceId And PaymentAmount<>0 And ServiceCompanyId=@MasterServComp
						Set @RecCount=1
						-- Opt : Replaced Set with Select
						Select @Count= Count(*) From @PaymentDtl
						While @Count>=@RecCount
						Begin
							-- Opt : Replaced Set with Select
							Select @PaymentDtlId= PaymentDtlId From @PaymentDtl Where S_No=@RecCount
							IF Exists (Select Id From Bean.PaymentDetail Where Id=@PaymentDtlId And Nature=@NatureTrade)
							Begin
								-- Opt : Replaced Set with Select
								Select @COAID= Id From Bean.ChartOfAccount Where CompanyId=@CompanyId And Name=@COATradePayables
							End
							Else IF Exists (Select Id From Bean.PaymentDetail Where Id=@PaymentDtlId And Nature=@NatureOthers)
							Begin
								-- Opt : Replaced Set with Select
								Select @COAID= Id From Bean.ChartOfAccount Where CompanyId=@CompanyId And Name=@COAOtherPayables
							End
							--Set @DocumentId=(Select DocumentId From Bean.PaymentDetail Where Id=@PaymentDtlId)
							-- Opt : Replaced Set with Select
							Select @OffSetDocumentType= DocumentType From Bean.PaymentDetail Where Id=@PaymentDtlId
							
							IF @OffSetDocumentType=@InvoiceDocument
							Begin
								-- Opt : Replaced Set with Select
								Select @ExchangeRate= ExchangeRate From Bean.Invoice Where Id=@DocumentId
								IF Exists (Select Id From Bean.Invoice Where Id=@DocumentId And DocumentState In (@FullyApplied,@Fullypaid))
								Begin
									Set @IsRoundingAmount=1
								End 
							End
							Else IF @OffSetDocumentType=@DebitNoteDocument
							Begin
								-- Opt : Replaced Set with Select
								Select @ExchangeRate= ExchangeRate From Bean.DebitNote Where Id=@DocumentId
								IF Exists (Select Id From Bean.DebitNote Where Id=@DocumentId And DocumentState In (@FullyApplied,@Fullypaid))
								Begin
									Set @IsRoundingAmount=1
								End 
							End
							Else IF @OffSetDocumentType in (@BillDocument,@PayrollBill,@openBal,@Payroll,@Claim,@General)
							Begin
								-- Opt : Replaced Set with Select
								Select @ExchangeRate= ExchangeRate From Bean.Bill Where Id=@DocumentId
								IF Exists (Select Id From Bean.Bill Where Id=@DocumentId And DocumentState In (@FullyApplied,@Fullypaid))
								Begin
									Set @IsRoundingAmount=1
								End 
							End

							IF @IsRoundingAmount=1 And Exists (Select Amount From @RoundingAmountDetails Where DocumentId=@DocumentId And Amount Is Not Null And Amount<>'')
							Begin
								-- Opt : Replaced Set with Select
								Select @DocAmount= Amount From @RoundingAmountDetails Where DocumentId=@DocumentId
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
							Select NEWID(),@IntMastJournalId,@COAID,P.Remarks,PD.PaymentAmount As DocDebit,Null As DocCredit,
								Round(PD.PaymentAmount * @DefaultExchangeRate,2)-Isnull(@DocAmount,0) As BaseDebit,Null As BaseCredit,
								0.00 As DocDebitTotal,0.00 As DocCreditTotal,0.00 As BaseDebitTotal,0.00 As BaseCreditTotal,P.Id As DocumnetId,PD.Id As DocumentDetailId,@GUIDZero,
								P.BaseCurrency,@DefaultExchangeRate As ExchangeRate,@DocType,@DocSubType,PD.ServiceCompanyId,P.DocNo,PD.Nature,Null As DocumentNo,0 As IsTax,
								P.EntityId,@IntMstSeysRefNo,@DocCurrency,P.DocDate,P.DocDate,@RecOrder As RecOrder
							From Bean.Payment As P
							Inner Join bean.PaymentDetail As PD On PD.PaymentId=P.Id
							Where P.Id=@SourceId And PD.Id=@PaymentDtlId
							Set @RecCount=@RecCount+1
						End
					End
					-- Serv Company Details
					Insert Into @ServCompaIdTbl
					Select Distinct ServiceCompanyId From Bean.PaymentDetail Where PaymentId=@SourceId And PaymentAmount<>0 And ServiceCompanyId<>@MasterServComp
					-- Opt : Replaced Set with Select
					Select @Count= Count(*) From @ServCompaIdTbl
					Set @RecCount=1
					While @Count>=@RecCount
					Begin
						Set @RecOrder=@RecOrder+1
						-- Opt : Replaced Set with Select
						Select @ServCompId= SerCompId From @ServCompaIdTbl Where S_No=@RecCount
						Select @PaymentAmtTotal= Sum(Isnull(Case When DocumentType in (@InvoiceDocument,@DebitNoteDocument,@CreditMemoDocument) Then -(PaymentAmount)
																	 Else PaymentAmount End,0)) 
						From Bean.PaymentDetail Where PaymentId=@SourceId And ServiceCompanyId=@ServCompId
						Select @IntroCompCOAID= COA.Id 
						From Bean.ChartOfAccount As COA 
						Inner Join Bean.AccountType As ACT On ACT.Id=COA.AccountTypeId
						Where ACT.CompanyId=@CompanyId And ACT.Name=@IntercompClearingCOAName 
						And COA.SubsidaryCompanyId=@ServCompId
						Insert Into Bean.JournalDetail (Id,JournalId,COAId,AccountDescription,AllowDisAllow, DocDebit, BaseDebit, DocDebitTotal,DocCreditTotal,BaseDebitTotal,BaseCreditTotal,DocumentId,DocumentDetailId,ItemId,BaseCurrency,ExchangeRate,GSTExCurrency,GSTExchangeRate,DocType,DocSubType,ServiceCompanyId,DocNo, IsTax,
														EntityId, SystemRefNo, DocCurrency,DocDate, PostingDate,RecOrder )
						Select NEWID(),@IntMastJournalId,@IntroCompCOAID,P.Remarks,IsDisAllow,@PaymentAmtTotal,Round(@PaymentAmtTotal * @DefaultExchangeRate,2),0.00 As DocDebitTotal,0.00 As DocCreditTotal,0.00 As BaseDebitTotal,0.00 As BaseCreditTotal,P.Id As DocumnetId,@GUIDZero,@GUIDZero,
								BaseCurrency,@DefaultExchangeRate As ExchangeRate,GSTExCurrency,GSTExchangeRate,@DocType,@DocSubType,@ServCompId,DocNo,0 As IsTax,
								EntityId,@IntMstSeysRefNo As SystemRefNo,@DocCurrency,DocDate,DocDate,@RecOrder As RecOrder
						From Bean.Payment As P
						Where P.Id=@SourceId 

						-- Another JV For Different Service Company
						Set @SysRefNumOrder=@SysRefNumOrder+1
						Set @SystemRefNo=Concat(@DocNo,'-JV',@SysRefNumOrder)
						Set @JournalId=NEWID()
						Insert Into Bean.Journal (Id,CompanyId,DocDate,DocType,DocSubType,DocNo,ServiceCompanyId,SystemReferenceNo,IsNoSupportingDocs,NoSupportingDocument,DocCurrency,ExchangeRate,ExCurrency,ExDurationFrom,GSTExchangeRate,GSTExCurrency,GSTTotalAmount,DocumentState,IsNoSupportingDocument,IsGstSettings,IsMultiCurrency,IsAllowableNonAllowable,IsGSTCurrencyRateChanged,Remarks,UserCreated,CreatedDate,Status,DocumentDescription,CreationType,GrandDocDebitTotal,GrandDocCreditTotal,GrandBaseDebitTotal,
												GrandBaseCreditTotal,EntityId,EntityType,PostingDate,COAId,ModeOfReceipt,BankReceiptAmmount,ExcessPaidByClientAmmount,BalancingItemReciveCRAmount,  BalancingItemPayDRAmount,ReceiptApplicationAmmount,DocumentId, BankClearingDate ,IsBalancing,ISAllowDisAllow, IsShow, ActualSysRefNo 
												,IsSegmentReporting, TransferRefNo
												)
						Select @JournalId,@CompanyId,DocDate,@DocType,@DocSubType,DocNo,@ServCompId,@SystemRefNo As SystemRefNo,IsNoSupportingDocument,NoSupportingDocs,DocCurrency,ExchangeRate,ExCurrency,ExDurationFrom,GSTExchangeRate,GSTExCurrency,Isnull(GSTTotalAmount,0),DocumentState,NoSupportingDocs,IsGstSettings,IsMultiCurrency,IsAllowableDisallowable,IsGSTCurrencyRateChanged,Remarks,@UserCreated,@CreatedDate,Status,Remarks As DocDescription,@UserCreated,GrandTotal,0.00 As GrandDocCreditTotal,Round(GrandTotal * ExchangeRate,2) As GrandBaseDebitTotal,
								0.00 As GrandBaseCreditTotal,EntityId,EntityType,DocDate As PostingDate,COAId,ModeOfReceipt,0.00 As BankReceiptAmmount,0.00 As ExcessPaidByClientAmmount,0.00 As BalancingItemReciveCRAmount,0.00 As BalancingItemPayDRAmount,0.00 As ReceiptApplicationAmmount,Id As DocumentId,BankClearingDate,0 As IsBalancing,IsDisAllow,1 As IsShow,DocNo As ActualSysRefNo,0 As IsSegmentReporting, PaymentRefNo
						From Bean.Payment Where CompanyId=@CompanyId And Id=@SourceId
						
						Insert Into Bean.JournalDetail (Id,JournalId,COAId,AccountDescription,AllowDisAllow, DocCredit, BaseCredit, DocDebitTotal,DocCreditTotal,BaseDebitTotal,BaseCreditTotal,DocumentId,DocumentDetailId,ItemId,BaseCurrency,ExchangeRate,GSTExCurrency,GSTExchangeRate,DocType,DocSubType,ServiceCompanyId,DocNo, IsTax,
														EntityId, SystemRefNo, DocCurrency,DocDate, PostingDate,RecOrder )
						Select NEWID(),@JournalId,@MainInterCoServCompCOAID,P.Remarks,IsDisAllow,@PaymentAmtTotal,Round(@PaymentAmtTotal * @DefaultExchangeRate,2),0.00 As DocDebitTotal,0.00 As DocCreditTotal,0.00 As BaseDebitTotal,0.00 As BaseCreditTotal,P.Id As DocumnetId,@GUIDZero,@GUIDZero,
								BaseCurrency,@DefaultExchangeRate As ExchangeRate,GSTExCurrency,GSTExchangeRate,@DocType,@DocSubType,@ServCompId,DocNo,0 As IsTax,
								EntityId,@SystemRefNo As SystemRefNo,@DocCurrency,DocDate,DocDate,@RecOrder As RecOrder
						From Bean.Payment As P
						Where P.Id=@SourceId 
															
						IF Exists(Select Id From Bean.PaymentDetail Where PaymentId=@SourceId And PaymentAmount<>0 And ServiceCompanyId=@ServCompId)
						Begin
							Delete From @PaymentDtl_New
							Insert Into @PaymentDtl_New
							Select ROW_NUMBER() Over (Order By Id),Id From Bean.PaymentDetail Where PaymentId=@SourceId And PaymentAmount<>0 And ServiceCompanyId=@ServCompId
							Set @RdtlRecCount=1
							-- Opt : Replaced Set with Select
							Select @DtlCount= Count(*) From @PaymentDtl_New
							While @DtlCount>=@RdtlRecCount
							Begin
								-- Opt : Replaced Set with Select
								Select @PaymentDtlId= PaymentDtlId From @PaymentDtl_New Where S_No=@RdtlRecCount
								IF Exists (Select Id From Bean.PaymentDetail Where Id=@PaymentDtlId And Nature=@NatureTrade)
								Begin
									-- Opt : Replaced Set with Select
									Select @COAID= Id From Bean.ChartOfAccount Where CompanyId=@CompanyId And Name=@COATradePayables
								End
								Else IF Exists (Select Id From Bean.PaymentDetail Where Id=@PaymentDtlId And Nature=@NatureOthers)
								Begin
									Select @COAID= Id From Bean.ChartOfAccount Where CompanyId=@CompanyId And Name=@COAOtherPayables
								End
								-- Opt : Replaced Set with Select
								Select @DocumentId= DocumentId From Bean.PaymentDetail Where Id=@PaymentDtlId
								Select @OffSetDocumentType= DocumentType From Bean.PaymentDetail Where Id=@PaymentDtlId
							
								IF @OffSetDocumentType=@InvoiceDocument
								Begin
									-- Opt : Replaced Set with Select
									Select @ExchangeRate= ExchangeRate From Bean.Invoice Where Id=@DocumentId
									IF Exists (Select Id From Bean.Invoice Where Id=@DocumentId And DocumentState In (@FullyApplied,@Fullypaid))
									Begin
										Set @IsRoundingAmount=1
									End 
								End
								Else IF @OffSetDocumentType=@DebitNoteDocument
								Begin
									-- Opt : Replaced Set with Select
									Select @ExchangeRate= ExchangeRate From Bean.DebitNote Where Id=@DocumentId
									IF Exists (Select Id From Bean.DebitNote Where Id=@DocumentId And DocumentState In (@FullyApplied,@Fullypaid))
									Begin
										Set @IsRoundingAmount=1
									End 
								End
								Else IF @OffSetDocumentType in (@BillDocument,@PayrollBill,@openBal,@Payroll,@Claim,@General)
								Begin
									-- Opt : Replaced Set with Select
									Select @ExchangeRate= ExchangeRate From Bean.Bill Where Id=@DocumentId
									IF Exists (Select Id From Bean.Bill Where Id=@DocumentId And DocumentState In (@FullyApplied,@Fullypaid))
									Begin
										Set @IsRoundingAmount=1
									End 
								End

								IF @IsRoundingAmount=1 And Exists (Select Amount From @RoundingAmountDetails Where DocumentId=@DocumentId And Amount Is Not Null And Amount<>'') 
								Begin
									-- Opt : Replaced Set with Select
									Select @DocAmount= Amount From @RoundingAmountDetails Where DocumentId=@DocumentId
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
								Select NEWID(),@JournalId,@COAID,P.Remarks,PD.PaymentAmount As DocDebit,Null As DocCredit,
									Round(PD.PaymentAmount * @DefaultExchangeRate,2)-Isnull(@DocAmount,0) As BaseDebit,Null As BaseCredit,
									0.00 As DocDebitTotal,0.00 As DocCreditTotal,0.00 As BaseDebitTotal,0.00 As BaseCreditTotal,P.Id As DocumnetId,PD.Id As DocumentDetailId,@GUIDZero,
									P.BaseCurrency,@DefaultExchangeRate As ExchangeRate,@DocType,@DocSubType,PD.ServiceCompanyId,P.DocNo,PD.Nature,Null As DocumentNo,0 As IsTax,
									P.EntityId,@SystemRefNo,@DocCurrency,P.DocDate,P.DocDate,@RecOrder As RecOrder
								From Bean.Payment As P
								Inner Join bean.PaymentDetail As PD On PD.PaymentId=P.Id
								Where P.Id=@SourceId And PD.Id=@PaymentDtlId
								Set @RdtlRecCount=@RdtlRecCount+1
							End
						End
						Set @RecCount=@RecCount+1
					End
				End
				Else IF @DocCurrency<>@BankChargesCurrency And @DocCurrency<>@BaseCurrency
				Begin
					/* Creating Mater record In JournalDetail */
					Insert Into Bean.JournalDetail (Id,JournalId,COAId,AccountDescription,AllowDisAllow, DocCredit, BaseCredit, DocDebitTotal,DocCreditTotal,BaseDebitTotal,BaseCreditTotal,DocumentId,DocumentDetailId,ItemId,BaseCurrency,ExchangeRate,GSTExCurrency,GSTExchangeRate,DocType,DocSubType,ServiceCompanyId,DocNo, IsTax,
									EntityId, SystemRefNo, DocCurrency,DocDate, PostingDate,RecOrder )
					Select NEWID(),@MasterJournalId,COAId,Remarks,IsDisAllow,GrandTotal,Round(GrandTotal * @DefaultExchangeRate,2),0.00 As DocDebitTotal,0.00 As DocCreditTotal,0.00 As BaseDebitTotal,0.00 As BaseCreditTotal,Id As DocumnetId,@GUIDZero,@GUIDZero,
							BaseCurrency,@DefaultExchangeRate As ExchangeRate,GSTExCurrency,GSTExchangeRate,@DocType,@DocSubType,ServiceCompanyId,DocNo,0 As IsTax,
							EntityId,@MasterSystemRefNo As SystemRefNo,@BankChargesCurrency,DocDate,DocDate,@MasterRecOrder As RecOrder
					From Bean.Payment Where Id=@SourceId
					-- Clearing Payments
					Set @MasterRecOrder=@MasterRecOrder+1
					-- Opt : Replaced Set with Select
					Select @ClearingPaymentsCOAID= Id 
					From Bean.ChartOfAccount Where CompanyId=@CompanyId And Name=@ClearingPayments

					Insert Into Bean.JournalDetail (Id,JournalId,COAId,AccountDescription,AllowDisAllow, DocDebit, BaseDebit, DocDebitTotal,DocCreditTotal,BaseDebitTotal,BaseCreditTotal,DocumentId,DocumentDetailId,ItemId,BaseCurrency,ExchangeRate,GSTExCurrency,GSTExchangeRate,DocType,DocSubType,ServiceCompanyId,DocNo, IsTax,
									EntityId, SystemRefNo, DocCurrency,DocDate, PostingDate,RecOrder )
					Select NEWID(),@MasterJournalId,@ClearingPaymentsCOAID,Remarks,IsDisAllow,GrandTotal,Round(GrandTotal * @DefaultExchangeRate,2),0.00 As DocDebitTotal,0.00 As DocCreditTotal,0.00 As BaseDebitTotal,0.00 As BaseCreditTotal,Id As DocumnetId,@GUIDZero,@GUIDZero,
							BaseCurrency,@DefaultExchangeRate As ExchangeRate,GSTExCurrency,GSTExchangeRate,@DocType,@DocSubType,ServiceCompanyId,DocNo,0 As IsTax,
							EntityId,@MasterSystemRefNo As SystemRefNo,@BankChargesCurrency,DocDate,DocDate,@MasterRecOrder As RecOrder
					From Bean.Payment Where Id=@SourceId
					-- 2nd Jv
					--Set @IntMstSeysRefNo= Concat(@DocNo,'-JV',Substring(Reverse(Substring(Reverse(@SystemRefNo),1,CHARINDEX('-',Reverse(@SystemRefNo)))),PATINDEX('%[0-9]%',@SystemRefNo),DATALENGTH(Reverse(Substring(Reverse(@SystemRefNo),1,CHARINDEX('-',Reverse(@SystemRefNo))))))+1)
					Set @SysRefNumOrder=@SysRefNumOrder+1
					Set @IntMstSeysRefNo=Concat(@DocNo,'-JV',@SysRefNumOrder)
					Set @IntMastJournalId=NEWID()
					Insert Into Bean.Journal (Id,CompanyId,DocDate,DocType,DocSubType,DocNo,ServiceCompanyId,SystemReferenceNo,IsNoSupportingDocs,NoSupportingDocument,DocCurrency,ExchangeRate,ExCurrency,ExDurationFrom,GSTExchangeRate,GSTExCurrency,GSTTotalAmount,DocumentState,IsNoSupportingDocument,IsGstSettings,IsMultiCurrency,IsAllowableNonAllowable,IsGSTCurrencyRateChanged,Remarks,UserCreated,CreatedDate,Status,DocumentDescription,CreationType,GrandDocDebitTotal,GrandDocCreditTotal,GrandBaseDebitTotal,
											GrandBaseCreditTotal,EntityId,EntityType,PostingDate,COAId,ModeOfReceipt,BankReceiptAmmount,ExcessPaidByClientAmmount,BalancingItemReciveCRAmount,  BalancingItemPayDRAmount,ReceiptApplicationAmmount,DocumentId, BankClearingDate ,IsBalancing,ISAllowDisAllow, IsShow, ActualSysRefNo 
											,IsSegmentReporting, TransferRefNo
											)
					Select @IntMastJournalId,@CompanyId,DocDate,@DocType,@DocSubType,DocNo,ServiceCompanyId,@IntMstSeysRefNo As SystemRefNo,IsNoSupportingDocument,NoSupportingDocs,DocCurrency,ExchangeRate,ExCurrency,ExDurationFrom,GSTExchangeRate,GSTExCurrency,Isnull(GSTTotalAmount,0),DocumentState,NoSupportingDocs,IsGstSettings,IsMultiCurrency,IsAllowableDisallowable,IsGSTCurrencyRateChanged,Remarks,@UserCreated,@CreatedDate,Status,Remarks As DocDescription,@UserCreated,GrandTotal,0.00 As GrandDocCreditTotal,Round(GrandTotal * ExchangeRate,2) As GrandBaseDebitTotal,
							0.00 As GrandBaseCreditTotal,EntityId,EntityType,DocDate As PostingDate,COAId,ModeOfReceipt,0.00 As BankReceiptAmmount,0.00 As ExcessPaidByClientAmmount,0.00 As BalancingItemReciveCRAmount,0.00 As BalancingItemPayDRAmount,0.00 As ReceiptApplicationAmmount,Id As DocumentId,BankClearingDate,0 As IsBalancing,IsDisAllow,1 As IsShow,DocNo As ActualSysRefNo,0 As IsSegmentReporting, PaymentRefNo
					From Bean.Payment Where CompanyId=@CompanyId And Id=@SourceId
					-- 2 nd Jv Clearing Payments			
					Insert Into Bean.JournalDetail (Id,JournalId,COAId,AccountDescription,AllowDisAllow, DocCredit, BaseCredit, DocDebitTotal,DocCreditTotal,BaseDebitTotal,BaseCreditTotal,DocumentId,DocumentDetailId,ItemId,BaseCurrency,ExchangeRate,GSTExCurrency,GSTExchangeRate,DocType,DocSubType,ServiceCompanyId,DocNo, IsTax,
									EntityId, SystemRefNo, DocCurrency,DocDate, PostingDate,RecOrder )
					Select NEWID(),@IntMastJournalId,@ClearingPaymentsCOAID,Remarks,IsDisAllow,PaymentApplicationAmmount,Round(PaymentApplicationAmmount * @SysCalExchangerate,2),0.00 As DocDebitTotal,0.00 As DocCreditTotal,0.00 As BaseDebitTotal,0.00 As BaseCreditTotal,Id As DocumnetId,@GUIDZero,@GUIDZero,
							BaseCurrency,@SysCalExchangerate As ExchangeRate,GSTExCurrency,GSTExchangeRate,@DocType,@DocSubType,ServiceCompanyId,DocNo,0 As IsTax,
							EntityId,@IntMstSeysRefNo As SystemRefNo,@DocCurrency,DocDate,DocDate,@RecOrder As RecOrder
					From Bean.Payment Where Id=@SourceId
					IF Exists(Select Id From Bean.PaymentDetail Where PaymentId=@SourceId And PaymentAmount<>0 And ServiceCompanyId=@MasterServComp)
					Begin
						Insert Into @PaymentDtl
						Select Id From Bean.PaymentDetail Where PaymentId=@SourceId And PaymentAmount<>0 And ServiceCompanyId=@MasterServComp
						Set @RecCount=1
						-- Opt : Replaced Set with Select
						Select @Count= Count(*) From @PaymentDtl
						While @Count>=@RecCount
						Begin
							-- Opt : Replaced Set with Select
							Select @PaymentDtlId= PaymentDtlId From @PaymentDtl Where S_No=@RecCount
							IF Exists (Select Id From Bean.PaymentDetail Where Id=@PaymentDtlId And Nature=@NatureTrade)
							Begin
								-- Opt : Replaced Set with Select
								Select @COAID= Id From Bean.ChartOfAccount Where CompanyId=@CompanyId And Name=@COATradePayables
							End
							Else IF Exists (Select Id From Bean.PaymentDetail Where Id=@PaymentDtlId And Nature=@NatureOthers)
							Begin
								Select @COAID= Id From Bean.ChartOfAccount Where CompanyId=@CompanyId And Name=@COAOtherPayables
							End
							Select @DocumentId= DocumentId From Bean.PaymentDetail Where Id=@PaymentDtlId
							Select @OffSetDocumentType= DocumentType From Bean.PaymentDetail Where Id=@PaymentDtlId
							
							IF @OffSetDocumentType=@InvoiceDocument
							Begin
								-- Opt : Replaced Set with Select
								Select @ExchangeRate= ExchangeRate From Bean.Invoice Where Id=@DocumentId
								IF Exists (Select Id From Bean.Invoice Where Id=@DocumentId And DocumentState In (@FullyApplied,@Fullypaid))
								Begin
									Set @IsRoundingAmount=1
								End 
							End
							Else IF @OffSetDocumentType=@DebitNoteDocument
							Begin
								-- Opt : Replaced Set with Select
								Select @ExchangeRate= ExchangeRate From Bean.DebitNote Where Id=@DocumentId
								IF Exists (Select Id From Bean.DebitNote Where Id=@DocumentId And DocumentState In (@FullyApplied,@Fullypaid))
								Begin
									Set @IsRoundingAmount=1
								End 
							End
							Else IF @OffSetDocumentType in (@BillDocument,@PayrollBill,@openBal,@Payroll,@Claim,@General)
							Begin
								-- Opt : Replaced Set with Select
								Select @ExchangeRate= ExchangeRate From Bean.Bill Where Id=@DocumentId
								IF Exists (Select Id From Bean.Bill Where Id=@DocumentId And DocumentState In (@FullyApplied,@Fullypaid))
								Begin
									Set @IsRoundingAmount=1
								End 
							End

							IF @IsRoundingAmount=1 And Exists (Select Amount From @RoundingAmountDetails Where DocumentId=@DocumentId And Amount Is Not Null And Amount<>'') --And @RoundingAmount Is Not Null And @RoundingAmount <>''
							Begin
								-- Opt : Replaced Set with Select
								Select @DocAmount= Amount From @RoundingAmountDetails Where DocumentId=@DocumentId
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
							Select NEWID(),@IntMastJournalId,@COAID,P.Remarks,PD.PaymentAmount As DocDebit,Null As DocCredit,
								Round(PD.PaymentAmount * @ExchangeRate,2)-Isnull(@DocAmount,0) As BaseDebit,Null As BaseCredit,
								0.00 As DocDebitTotal,0.00 As DocCreditTotal,0.00 As BaseDebitTotal,0.00 As BaseCreditTotal,P.Id As DocumnetId,PD.Id As DocumentDetailId,@GUIDZero,
								P.BaseCurrency,@ExchangeRate As ExchangeRate,@DocType,@DocSubType,PD.ServiceCompanyId,P.DocNo,PD.Nature,Null As DocumentNo,0 As IsTax,
								P.EntityId,@IntMstSeysRefNo,@DocCurrency,P.DocDate,P.DocDate,@RecOrder As RecOrder
							From Bean.Payment As P
							Inner Join bean.PaymentDetail As PD On PD.PaymentId=P.Id
							Where P.Id=@SourceId And PD.Id=@PaymentDtlId
							IF @SysCalExchangerate-@ExchangeRate<>0
							Begin
								-- Exchangegain or Loss
								Set @RecOrder=@RecOrder+1
								-- Opt : Replaced Set with Select
								Select @COAID= Id From Bean.ChartOfAccount Where CompanyId=@CompanyId And Name=@ExchangeGainOrLossRealised
								Insert Into Bean.JournalDetail (Id,JournalId,COAId,AccountDescription, DocDebit,DocCredit,
																 BaseDebit,BaseCredit,
																 DocDebitTotal,DocCreditTotal,BaseDebitTotal,BaseCreditTotal,DocumentId,DocumentDetailId,ItemId,BaseCurrency,ExchangeRate, DocType,DocSubType,ServiceCompanyId,DocNo,Nature,OffsetDocument,IsTax,
																EntityId, SystemRefNo, DocCurrency,DocDate, PostingDate,RecOrder 
																)
								Select NEWID(),@IntMastJournalId,@COAID,P.Remarks,Null As DocDebit,Null As DocCredit,
									Case When (@SysCalExchangerate-@ExchangeRate)>0 Then ABS(Round((@SysCalExchangerate-@ExchangeRate)  * PD.PaymentAmount,2)) End As BaseDebit,Case When (@SysCalExchangerate-@ExchangeRate)<0 Then ABS(Round((@SysCalExchangerate-@ExchangeRate) * PD.PaymentAmount,2) ) End As BaseCredit,
									0.00 As DocDebitTotal,0.00 As DocCreditTotal,0.00 As BaseDebitTotal,0.00 As BaseCreditTotal,P.Id As DocumnetId,PD.Id As DocumentDetailId,@GUIDZero,
									P.BaseCurrency,@SysCalExchangerate As ExchangeRate,@DocType,@DocSubType,PD.ServiceCompanyId,P.DocNo,PD.Nature,PD.DocumentNo,0 As IsTax,
									EntityId,@IntMstSeysRefNo,@DocCurrency,DocDate,DocDate,@RecOrder As RecOrder
								From Bean.Payment As P
								Inner Join bean.PaymentDetail As PD On PD.PaymentId=P.Id
								Where P.Id=@SourceId And PD.Id=@PaymentDtlId
							End
							Set @RecCount=@RecCount+1
						End
					End
					-- Serv Company Details
					Insert Into @ServCompaIdTbl
					Select Distinct ServiceCompanyId From Bean.PaymentDetail Where PaymentId=@SourceId And PaymentAmount<>0 And ServiceCompanyId<>@MasterServComp
					-- Opt : Replaced Set with Select
					Select @Count= Count(*) From @ServCompaIdTbl
					Set @RecCount=1
					While @Count>=@RecCount
					Begin
						Set @RecOrder=@RecOrder+1
						-- Opt : Replaced Set with Select
						Select @ServCompId= SerCompId From @ServCompaIdTbl Where S_No=@RecCount
						Select @PaymentAmtTotal= Sum(Isnull(Case When DocumentType in (@InvoiceDocument,@DebitNoteDocument,@CreditMemoDocument) Then -(PaymentAmount)
																	 Else PaymentAmount End,0)) 
						From Bean.PaymentDetail Where PaymentId=@SourceId And ServiceCompanyId=@ServCompId
						Select @IntroCompCOAID= COA.Id 
						From Bean.ChartOfAccount As COA 
						Inner Join Bean.AccountType As ACT On ACT.Id=COA.AccountTypeId
						Where ACT.CompanyId=@CompanyId And ACT.Name=@IntercompClearingCOAName 
						And COA.SubsidaryCompanyId=@ServCompId
						Insert Into Bean.JournalDetail (Id,JournalId,COAId,AccountDescription,AllowDisAllow, DocDebit, BaseDebit, DocDebitTotal,DocCreditTotal,BaseDebitTotal,BaseCreditTotal,DocumentId,DocumentDetailId,ItemId,BaseCurrency,ExchangeRate,GSTExCurrency,GSTExchangeRate,DocType,DocSubType,ServiceCompanyId,DocNo, IsTax,
														EntityId, SystemRefNo, DocCurrency,DocDate, PostingDate,RecOrder )
						Select NEWID(),@IntMastJournalId,@IntroCompCOAID,P.Remarks,IsDisAllow,@PaymentAmtTotal,Round(@PaymentAmtTotal * @SysCalExchangerate,2),0.00 As DocDebitTotal,0.00 As DocCreditTotal,0.00 As BaseDebitTotal,0.00 As BaseCreditTotal,P.Id As DocumnetId,@GUIDZero,@GUIDZero,
								BaseCurrency,@SysCalExchangerate As ExchangeRate,GSTExCurrency,GSTExchangeRate,@DocType,@DocSubType,@ServCompId,DocNo,0 As IsTax,
								EntityId,@IntMstSeysRefNo As SystemRefNo,@DocCurrency,DocDate,DocDate,@RecOrder As RecOrder
						From Bean.Payment As P
						Where P.Id=@SourceId 

						-- Another JV For Different Service Company
						Set @SysRefNumOrder=@SysRefNumOrder+1
						Set @SystemRefNo=Concat(@DocNo,'-JV',@SysRefNumOrder)
						Set @JournalId=NEWID()
						Insert Into Bean.Journal (Id,CompanyId,DocDate,DocType,DocSubType,DocNo,ServiceCompanyId,SystemReferenceNo,IsNoSupportingDocs,NoSupportingDocument,DocCurrency,ExchangeRate,ExCurrency,ExDurationFrom,GSTExchangeRate,GSTExCurrency,GSTTotalAmount,DocumentState,IsNoSupportingDocument,IsGstSettings,IsMultiCurrency,IsAllowableNonAllowable,IsGSTCurrencyRateChanged,Remarks,UserCreated,CreatedDate,Status,DocumentDescription,CreationType,GrandDocDebitTotal,GrandDocCreditTotal,GrandBaseDebitTotal,
												GrandBaseCreditTotal,EntityId,EntityType,PostingDate,COAId,ModeOfReceipt,BankReceiptAmmount,ExcessPaidByClientAmmount,BalancingItemReciveCRAmount,  BalancingItemPayDRAmount,ReceiptApplicationAmmount,DocumentId, BankClearingDate ,IsBalancing,ISAllowDisAllow, IsShow, ActualSysRefNo 
												,IsSegmentReporting, TransferRefNo
												)
						Select @JournalId,@CompanyId,DocDate,@DocType,@DocSubType,DocNo,@ServCompId,@SystemRefNo As SystemRefNo,IsNoSupportingDocument,NoSupportingDocs,DocCurrency,ExchangeRate,ExCurrency,ExDurationFrom,GSTExchangeRate,GSTExCurrency,Isnull(GSTTotalAmount,0),DocumentState,NoSupportingDocs,IsGstSettings,IsMultiCurrency,IsAllowableDisallowable,IsGSTCurrencyRateChanged,Remarks,@UserCreated,@CreatedDate,Status,Remarks As DocDescription,@UserCreated,GrandTotal,0.00 As GrandDocCreditTotal,Round(GrandTotal * ExchangeRate,2) As GrandBaseDebitTotal,
								0.00 As GrandBaseCreditTotal,EntityId,EntityType,DocDate As PostingDate,COAId,ModeOfReceipt,0.00 As BankReceiptAmmount,0.00 As ExcessPaidByClientAmmount,0.00 As BalancingItemReciveCRAmount,0.00 As BalancingItemPayDRAmount,0.00 As ReceiptApplicationAmmount,Id As DocumentId,BankClearingDate,0 As IsBalancing,IsDisAllow,1 As IsShow,DocNo As ActualSysRefNo,0 As IsSegmentReporting, PaymentRefNo
						From Bean.Payment Where CompanyId=@CompanyId And Id=@SourceId
						
						Insert Into Bean.JournalDetail (Id,JournalId,COAId,AccountDescription,AllowDisAllow, DocCredit, BaseCredit, DocDebitTotal,DocCreditTotal,BaseDebitTotal,BaseCreditTotal,DocumentId,DocumentDetailId,ItemId,BaseCurrency,ExchangeRate,GSTExCurrency,GSTExchangeRate,DocType,DocSubType,ServiceCompanyId,DocNo, IsTax,
														EntityId, SystemRefNo, DocCurrency,DocDate, PostingDate,RecOrder )
						Select NEWID(),@JournalId,@MainInterCoServCompCOAID,P.Remarks,IsDisAllow,@PaymentAmtTotal,Round(@PaymentAmtTotal * @SysCalExchangerate,2),0.00 As DocDebitTotal,0.00 As DocCreditTotal,0.00 As BaseDebitTotal,0.00 As BaseCreditTotal,P.Id As DocumnetId,@GUIDZero,@GUIDZero,
								BaseCurrency,@SysCalExchangerate As ExchangeRate,GSTExCurrency,GSTExchangeRate,@DocType,@DocSubType,@ServCompId,DocNo,0 As IsTax,
								EntityId,@SystemRefNo As SystemRefNo,@DocCurrency,DocDate,DocDate,@RecOrder As RecOrder
						From Bean.Payment As P
						Where P.Id=@SourceId 
						-- Serv Company Detail Records									
						IF Exists(Select Id From Bean.PaymentDetail Where PaymentId=@SourceId And PaymentAmount<>0 And ServiceCompanyId=@ServCompId)
						Begin
							Delete From @PaymentDtl_New
							Insert Into @PaymentDtl_New
							Select ROW_NUMBER() Over (Order By Id),Id From Bean.PaymentDetail Where PaymentId=@SourceId And PaymentAmount<>0 And ServiceCompanyId=@ServCompId
							Set @RdtlRecCount=1
							-- Opt : Replaced Set with Select
							Select @DtlCount= Count(*) From @PaymentDtl_New
							While @DtlCount>=@RdtlRecCount
							Begin
								-- Opt : Replaced Set with Select
								Select @PaymentDtlId= PaymentDtlId From @PaymentDtl_New Where S_No=@RdtlRecCount
								IF Exists (Select Id From Bean.PaymentDetail Where Id=@PaymentDtlId And Nature=@NatureTrade)
								Begin
									-- Opt : Replaced Set with Select
									Select @COAID= Id From Bean.ChartOfAccount Where CompanyId=@CompanyId And Name=@COATradePayables
								End
								Else IF Exists (Select Id From Bean.PaymentDetail Where Id=@PaymentDtlId And Nature=@NatureOthers)
								Begin
									-- Opt : Replaced Set with Select
									Select @COAID= Id From Bean.ChartOfAccount Where CompanyId=@CompanyId And Name=@COAOtherPayables
								End
								-- Opt : Replaced Set with Select
								Select @DocumentId= DocumentId From Bean.PaymentDetail Where Id=@PaymentDtlId
								Select @OffSetDocumentType= DocumentType From Bean.PaymentDetail Where Id=@PaymentDtlId
							
								IF @OffSetDocumentType=@InvoiceDocument
								Begin
									-- Opt : Replaced Set with Select
									Select @ExchangeRate= ExchangeRate From Bean.Invoice Where Id=@DocumentId
									IF Exists (Select Id From Bean.Invoice Where Id=@DocumentId And DocumentState In (@FullyApplied,@Fullypaid))
									Begin
										Set @IsRoundingAmount=1
									End 
								End
								Else IF @OffSetDocumentType=@DebitNoteDocument
								Begin
									-- Opt : Replaced Set with Select
									Select @ExchangeRate= ExchangeRate From Bean.DebitNote Where Id=@DocumentId
									IF Exists (Select Id From Bean.DebitNote Where Id=@DocumentId And DocumentState In (@FullyApplied,@Fullypaid))
									Begin
										Set @IsRoundingAmount=1
									End 
								End
								Else IF @OffSetDocumentType in (@BillDocument,@PayrollBill,@openBal,@Payroll,@Claim,@General)
								Begin
									-- Opt : Replaced Set with Select
									Select @ExchangeRate= ExchangeRate From Bean.Bill Where Id=@DocumentId
									IF Exists (Select Id From Bean.Bill Where Id=@DocumentId And DocumentState In (@FullyApplied,@Fullypaid))
									Begin
										Set @IsRoundingAmount=1
									End 
								End

								IF @IsRoundingAmount=1 And Exists (Select Amount From @RoundingAmountDetails Where DocumentId=@DocumentId And Amount Is Not Null And Amount<>'') 
								Begin
									-- Opt : Replaced Set with Select
									Select @DocAmount= Amount From @RoundingAmountDetails Where DocumentId=@DocumentId
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
								Select NEWID(),@JournalId,@COAID,P.Remarks,PD.PaymentAmount As DocDebit,Null As DocCredit,
									Round(PD.PaymentAmount * @ExchangeRate,2)-Isnull(@DocAmount,0) As BaseDebit,Null As BaseCredit,
									0.00 As DocDebitTotal,0.00 As DocCreditTotal,0.00 As BaseDebitTotal,0.00 As BaseCreditTotal,P.Id As DocumnetId,PD.Id As DocumentDetailId,@GUIDZero,
									P.BaseCurrency,@ExchangeRate As ExchangeRate,@DocType,@DocSubType,PD.ServiceCompanyId,P.DocNo,PD.Nature,Null As DocumentNo,0 As IsTax,
									P.EntityId,@SystemRefNo,@DocCurrency,P.DocDate,P.DocDate,@RecOrder As RecOrder
								From Bean.Payment As P
								Inner Join bean.PaymentDetail As PD On PD.PaymentId=P.Id
								Where P.Id=@SourceId And PD.Id=@PaymentDtlId
								IF @SysCalExchangerate-@ExchangeRate<>0
								Begin
									-- Exchangegain or Loss
									Set @RecOrder=@RecOrder+1
									-- Opt : Replaced Set with Select
									Select @COAID= Id From Bean.ChartOfAccount Where CompanyId=@CompanyId And Name=@ExchangeGainOrLossRealised
									Insert Into Bean.JournalDetail (Id,JournalId,COAId,AccountDescription, DocDebit,DocCredit,
																	 BaseDebit,BaseCredit,
																	 DocDebitTotal,DocCreditTotal,BaseDebitTotal,BaseCreditTotal,DocumentId,DocumentDetailId,ItemId,BaseCurrency,ExchangeRate, DocType,DocSubType,ServiceCompanyId,DocNo,Nature,OffsetDocument,IsTax,
																	EntityId, SystemRefNo, DocCurrency,DocDate, PostingDate,RecOrder 
																	)
									Select NEWID(),@JournalId,@COAID,P.Remarks,Null As DocDebit,Null As DocCredit,
										Case When (@SysCalExchangerate-@ExchangeRate)>0 Then ABS(Round((@SysCalExchangerate-@ExchangeRate)  * PD.PaymentAmount,2)) End As BaseDebit,Case When (@SysCalExchangerate-@ExchangeRate)<0 Then ABS(Round((@SysCalExchangerate-@ExchangeRate) * PD.PaymentAmount,2) ) End As BaseCredit,
										0.00 As DocDebitTotal,0.00 As DocCreditTotal,0.00 As BaseDebitTotal,0.00 As BaseCreditTotal,P.Id As DocumnetId,PD.Id As DocumentDetailId,@GUIDZero,
										P.BaseCurrency,@SysCalExchangerate As ExchangeRate,@DocType,@DocSubType,PD.ServiceCompanyId,P.DocNo,PD.Nature,PD.DocumentNo,0 As IsTax,
										EntityId,@SystemRefNo,@DocCurrency,DocDate,DocDate,@RecOrder As RecOrder
									From Bean.Payment As P
									Inner Join bean.PaymentDetail As PD On PD.PaymentId=P.Id
									Where P.Id=@SourceId And PD.Id=@PaymentDtlId
								End
								Set @RdtlRecCount=@RdtlRecCount+1
							End
						End
						Set @RecCount=@RecCount+1
					End
				End
			End
			-- Payment Single Company
			Else
			Begin
				
				Set @MasterSystemRefNo=Concat(@DocNo,'-JV',@SysRefNumOrder)
				Set @MasterJournalId=NEWID()
				Insert Into Bean.Journal (Id,CompanyId,DocDate,DocType,DocSubType,DocNo,ServiceCompanyId,SystemReferenceNo,IsNoSupportingDocs,NoSupportingDocument,DocCurrency,ExchangeRate,ExCurrency,ExDurationFrom,GSTExchangeRate,GSTExCurrency,GSTTotalAmount,DocumentState,IsNoSupportingDocument,IsGstSettings,IsMultiCurrency,IsAllowableNonAllowable,IsGSTCurrencyRateChanged,Remarks,UserCreated,CreatedDate,Status,DocumentDescription,CreationType,GrandDocDebitTotal,GrandDocCreditTotal,GrandBaseDebitTotal,
							GrandBaseCreditTotal,EntityId,EntityType,PostingDate,COAId,ModeOfReceipt,BankReceiptAmmount,ExcessPaidByClientAmmount,BalancingItemReciveCRAmount,  BalancingItemPayDRAmount,ReceiptApplicationAmmount,DocumentId, BankClearingDate ,IsBalancing,ISAllowDisAllow, IsShow, ActualSysRefNo 
							,IsSegmentReporting, TransferRefNo
						 )
				Select @MasterJournalId,@CompanyId,DocDate,@DocType,@DocSubType,DocNo,ServiceCompanyId,@MasterSystemRefNo As SystemRefNo,IsNoSupportingDocument,NoSupportingDocs,DocCurrency,ExchangeRate,ExCurrency,ExDurationFrom,GSTExchangeRate,GSTExCurrency,Isnull(GSTTotalAmount,0),DocumentState,NoSupportingDocs,IsGstSettings,IsMultiCurrency,IsAllowableDisallowable,IsGSTCurrencyRateChanged,Remarks,@UserCreated,@CreatedDate,Status,Remarks As DocDescription,@UserCreated,GrandTotal,0.00 As GrandDocCreditTotal,Round(GrandTotal * ExchangeRate,2) As GrandBaseDebitTotal,
						0.00 As GrandBaseCreditTotal,EntityId,EntityType,DocDate As PostingDate,COAId,ModeOfReceipt,0.00 As BankReceiptAmmount,0.00 As ExcessPaidByClientAmmount,0.00 As BalancingItemReciveCRAmount,0.00 As BalancingItemPayDRAmount,0.00 As ReceiptApplicationAmmount,Id As DocumentId,BankClearingDate,0 As IsBalancing,IsDisAllow,1 As IsShow,DocNo As ActualSysRefNo,0 As IsSegmentReporting, PaymentRefNo
				From Bean.Payment Where CompanyId=@CompanyId And Id=@SourceId
				IF @DocCurrency=@BankChargesCurrency And @BaseCurrency=@DocCurrency
				Begin
					/* Creating Mater record In JournalDetail */
					Insert Into Bean.JournalDetail (Id,JournalId,COAId,AccountDescription,AllowDisAllow, DocCredit, BaseCredit, DocDebitTotal,DocCreditTotal,BaseDebitTotal,BaseCreditTotal,DocumentId,DocumentDetailId,ItemId,BaseCurrency,ExchangeRate,GSTExCurrency,GSTExchangeRate,DocType,DocSubType,ServiceCompanyId,DocNo, IsTax,
									EntityId, SystemRefNo, DocCurrency,DocDate, PostingDate,RecOrder )
					Select NEWID(),@MasterJournalId,COAId,Remarks,IsDisAllow,GrandTotal,Round(GrandTotal * @DefaultExchangeRate,2),0.00 As DocDebitTotal,0.00 As DocCreditTotal,0.00 As BaseDebitTotal,0.00 As BaseCreditTotal,Id As DocumnetId,@GUIDZero,@GUIDZero,
							BaseCurrency,@DefaultExchangeRate As ExchangeRate,GSTExCurrency,GSTExchangeRate,@DocType,@DocSubType,ServiceCompanyId,DocNo,0 As IsTax,
							EntityId,@MasterSystemRefNo As SystemRefNo,@BankChargesCurrency,DocDate,DocDate,@RecOrder As RecOrder
					From Bean.Payment Where Id=@SourceId
					IF Exists(Select Id From Bean.PaymentDetail Where PaymentId=@SourceId And PaymentAmount<>0)
					Begin
						Insert Into @PaymentDtl
						Select Id From Bean.PaymentDetail Where PaymentId=@SourceId And PaymentAmount<>0
						Set @RecCount=1
						-- Opt : Replaced Set with Select
						Select @Count= Count(*) From @PaymentDtl
						While @Count>=@RecCount
						Begin
							-- Opt : Replaced Set with Select
							Select @PaymentDtlId= PaymentDtlId From @PaymentDtl Where S_No=@RecCount
							Select @DocumentId= DocumentId From Bean.PaymentDetail Where id=@PaymentDtlId
							Set @IsRoundingAmount=0
							IF Exists (Select Id From Bean.PaymentDetail Where Id=@PaymentDtlId And Nature=@NatureTrade)
							Begin
								-- Opt : Replaced Set with Select
								Select @COAID= Id From Bean.ChartOfAccount Where CompanyId=@CompanyId And Name=@COATradePayables
							End
							Else IF Exists (Select Id From Bean.PaymentDetail Where Id=@PaymentDtlId And Nature=@NatureOthers)
							Begin
								-- Opt : Replaced Set with Select
								Select @COAID= Id From Bean.ChartOfAccount Where CompanyId=@CompanyId And Name=@COAOtherPayables
							End
							-- Opt : Replaced Set with Select
							Select @OffSetDocumentType= DocumentType From Bean.PaymentDetail Where Id=@PaymentDtlId
							
							IF @OffSetDocumentType=@InvoiceDocument
							Begin
								-- Opt : Replaced Set with Select
								Select @ExchangeRate= ExchangeRate From Bean.Invoice Where Id=@DocumentId
								IF Exists (Select Id From Bean.Invoice Where Id=@DocumentId And DocumentState In (@FullyApplied,@Fullypaid))
								Begin
									Set @IsRoundingAmount=1
								End 
							End
							Else IF @OffSetDocumentType=@DebitNoteDocument
							Begin
								-- Opt : Replaced Set with Select
								Select @ExchangeRate= ExchangeRate From Bean.DebitNote Where Id=@DocumentId
								IF Exists (Select Id From Bean.DebitNote Where Id=@DocumentId And DocumentState In (@FullyApplied,@Fullypaid))
								Begin
									Set @IsRoundingAmount=1
								End 
							End
							Else IF @OffSetDocumentType in (@BillDocument,@PayrollBill,@openBal,@Payroll,@Claim,@General)
							Begin
								-- Opt : Replaced Set with Select
								Select @ExchangeRate= ExchangeRate From Bean.Bill Where Id=@DocumentId
								IF Exists (Select Id From Bean.Bill Where Id=@DocumentId And DocumentState In (@FullyApplied,@Fullypaid))
								Begin
									Set @IsRoundingAmount=1
								End 
							End

							IF @IsRoundingAmount=1 And Exists (Select Amount From @RoundingAmountDetails Where DocumentId=@DocumentId And Amount Is Not Null And Amount<>'') --And @RoundingAmount Is Not Null And @RoundingAmount <>''
							Begin
								-- Opt : Replaced Set with Select
								Select @DocAmount= Amount From @RoundingAmountDetails Where DocumentId=@DocumentId
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
							Select NEWID(),@MasterJournalId,@COAID,P.Remarks,PD.PaymentAmount As DocDebit,Null As DocCredit,
								Round(PD.PaymentAmount * @DefaultExchangeRate,2)-Isnull(@DocAmount,0) As BaseDebit,Null As BaseCredit,
								0.00 As DocDebitTotal,0.00 As DocCreditTotal,0.00 As BaseDebitTotal,0.00 As BaseCreditTotal,P.Id As DocumnetId,PD.Id As DocumentDetailId,@GUIDZero,
								P.BaseCurrency,@DefaultExchangeRate As ExchangeRate,@DocType,@DocSubType,PD.ServiceCompanyId,P.DocNo,PD.Nature,Null As DocumentNo,0 As IsTax,
								P.EntityId,@MasterSystemRefNo,@BankChargesCurrency,P.DocDate,P.DocDate,@RecOrder As RecOrder
							From Bean.Payment As P
							Inner Join bean.PaymentDetail As PD On PD.PaymentId=P.Id
							Where P.Id=@SourceId And PD.Id=@PaymentDtlId
							Set @RecCount=@RecCount+1
						End
					End
				End
				Else IF @DocCurrency=@BankChargesCurrency And @DocCurrency<>@BaseCurrency
				Begin
					/* Creating Mater record In JournalDetail */
					Insert Into Bean.JournalDetail (Id,JournalId,COAId,AccountDescription,AllowDisAllow, DocCredit, BaseCredit, DocDebitTotal,DocCreditTotal,BaseDebitTotal,BaseCreditTotal,DocumentId,DocumentDetailId,ItemId,BaseCurrency,ExchangeRate,GSTExCurrency,GSTExchangeRate,DocType,DocSubType,ServiceCompanyId,DocNo, IsTax,
									EntityId, SystemRefNo, DocCurrency,DocDate, PostingDate,RecOrder )
					Select NEWID(),@MasterJournalId,COAId,Remarks,IsDisAllow,GrandTotal,Round(GrandTotal * ExchangeRate,2),0.00 As DocDebitTotal,0.00 As DocCreditTotal,0.00 As BaseDebitTotal,0.00 As BaseCreditTotal,Id As DocumnetId,@GUIDZero,@GUIDZero,
							BaseCurrency,ExchangeRate As ExchangeRate,GSTExCurrency,GSTExchangeRate,@DocType,@DocSubType,ServiceCompanyId,DocNo,0 As IsTax,
							EntityId,@MasterSystemRefNo As SystemRefNo,@BankChargesCurrency,DocDate,DocDate,@RecOrder As RecOrder
					From Bean.Payment Where Id=@SourceId
					-- Detail Records
					IF Exists(Select Id From Bean.PaymentDetail Where PaymentId=@SourceId And PaymentAmount<>0)
					Begin
						Insert Into @PaymentDtl
						Select Id From Bean.PaymentDetail Where PaymentId=@SourceId And PaymentAmount<>0
						Set @RecCount=1
						-- Opt : Replaced Set with Select
						Select @Count= Count(*) From @PaymentDtl
						While @Count>=@RecCount
						Begin
							-- Opt : Replaced Set with Select
							Select @PaymentDtlId= PaymentDtlId From @PaymentDtl Where S_No=@RecCount
							Select @DocumentId= DocumentId From Bean.PaymentDetail Where id=@PaymentDtlId
							Select @OffSetDocumentType= DocumentType From Bean.PaymentDetail Where id=@PaymentDtlId
							Set @IsRoundingAmount=0
							IF Exists (Select Id From Bean.PaymentDetail Where Id=@PaymentDtlId And Nature=@NatureTrade)
							Begin
								-- Opt : Replaced Set with Select
								Select @COAID= Id From Bean.ChartOfAccount Where CompanyId=@CompanyId And Name=@COATradePayables
							End
							Else IF Exists (Select Id From Bean.PaymentDetail Where Id=@PaymentDtlId And Nature=@NatureOthers)
							Begin
								-- Opt : Replaced Set with Select
								Select @COAID= Id From Bean.ChartOfAccount Where CompanyId=@CompanyId And Name=@COAOtherPayables
							End
							IF @OffSetDocumentType=@InvoiceDocument
							Begin
								-- Opt : Replaced Set with Select
								Select @ExchangeRate= ExchangeRate From Bean.Invoice Where Id=@DocumentId
								IF Exists (Select Id From Bean.Invoice Where Id=@DocumentId And DocumentState In (@FullyApplied,@Fullypaid))
								Begin
									Set @IsRoundingAmount=1
								End 
							End
							Else IF @OffSetDocumentType=@DebitNoteDocument
							Begin
								-- Opt : Replaced Set with Select
								Select @ExchangeRate= ExchangeRate From Bean.DebitNote Where Id=@DocumentId
								IF Exists (Select Id From Bean.DebitNote Where Id=@DocumentId And DocumentState In (@FullyApplied,@Fullypaid))
								Begin
									Set @IsRoundingAmount=1
								End 
							End
							Else IF @OffSetDocumentType in (@BillDocument,@PayrollBill,@openBal,@Payroll,@Claim,@General)
							Begin
								-- Opt : Replaced Set with Select
								Select @ExchangeRate= ExchangeRate From Bean.Bill Where Id=@DocumentId
								IF Exists (Select Id From Bean.Bill Where Id=@DocumentId And DocumentState In (@FullyApplied,@Fullypaid))
								Begin
									Set @IsRoundingAmount=1
								End 
							End

							IF @IsRoundingAmount=1 And Exists (Select Amount From @RoundingAmountDetails Where DocumentId=@DocumentId And Amount Is Not Null And Amount<>'') --And @RoundingAmount Is Not Null And @RoundingAmount <>''
							Begin
								-- Opt : Replaced Set with Select
								Select @DocAmount= Amount From @RoundingAmountDetails Where DocumentId=@DocumentId
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
							Select NEWID(),@MasterJournalId,@COAID,P.Remarks,PD.PaymentAmount As DocDebit,Null As DocCredit,
								Round(PD.PaymentAmount * Isnull(@ExchangeRate,1),2)-Isnull(@DocAmount,0) As BaseDebit,Null As BaseCredit,
								0.00 As DocDebitTotal,0.00 As DocCreditTotal,0.00 As BaseDebitTotal,0.00 As BaseCreditTotal,P.Id As DocumnetId,PD.Id As DocumentDetailId,@GUIDZero,
								P.BaseCurrency,@ExchangeRate As ExchangeRate,@DocType,@DocSubType,PD.ServiceCompanyId,P.DocNo,PD.Nature,Null As DocumentNo,0 As IsTax,
								P.EntityId,@MasterSystemRefNo,@BankChargesCurrency,P.DocDate,P.DocDate,@RecOrder As RecOrder
							From Bean.Payment As P
							Inner Join bean.PaymentDetail As PD On PD.PaymentId=P.Id
							Where P.Id=@SourceId And PD.Id=@PaymentDtlId
							IF @MainExchangeRate-@ExchangeRate<>0
							Begin
								-- Exchangegain or Loss
								Set @RecOrder=@RecOrder+1
								-- Opt : Replaced Set with Select
								Select @COAID= Id From Bean.ChartOfAccount Where CompanyId=@CompanyId And Name=@ExchangeGainOrLossRealised
								Insert Into Bean.JournalDetail (Id,JournalId,COAId,AccountDescription, DocDebit,DocCredit,BaseDebit,BaseCredit,
																 DocDebitTotal,DocCreditTotal,BaseDebitTotal,BaseCreditTotal,DocumentId,DocumentDetailId,ItemId,BaseCurrency,ExchangeRate, DocType,DocSubType,ServiceCompanyId,DocNo,Nature,OffsetDocument,IsTax,
																EntityId, SystemRefNo, DocCurrency,DocDate, PostingDate,RecOrder 
																)
								Select NEWID(),@MasterJournalId,@COAID,P.Remarks,Null As DocDebit,Null As DocCredit,
									Case When (@MainExchangeRate-@ExchangeRate)>0 Then ABS(Round((@MainExchangeRate-@ExchangeRate)  * PD.PaymentAmount,2)) End As BaseDebit,Case When (@MainExchangeRate-@ExchangeRate)<0 Then ABS(Round((@MainExchangeRate-@ExchangeRate) * PD.PaymentAmount,2) ) End As BaseCredit,
									0.00 As DocDebitTotal,0.00 As DocCreditTotal,0.00 As BaseDebitTotal,0.00 As BaseCreditTotal,P.Id As DocumnetId,PD.Id As DocumentDetailId,@GUIDZero,
									P.BaseCurrency,P.ExchangeRate,@DocType,@DocSubType,PD.ServiceCompanyId,P.DocNo,PD.Nature,PD.DocumentNo,0 As IsTax,
									EntityId,@MasterSystemRefNo,@BankChargesCurrency,DocDate,DocDate,@RecOrder As RecOrder
								From Bean.Payment As P
								Inner Join bean.PaymentDetail As PD On PD.PaymentId=P.Id
								Where P.Id=@SourceId And PD.Id=@PaymentDtlId
							End
							Set @RecCount=@RecCount+1
						End
					End
				End
				Else IF @DocCurrency<>@BankChargesCurrency And @DocCurrency=@BaseCurrency
				Begin
					/* Creating Mater record In JournalDetail */
					Insert Into Bean.JournalDetail (Id,JournalId,COAId,AccountDescription,AllowDisAllow, DocCredit, BaseCredit, DocDebitTotal,DocCreditTotal,BaseDebitTotal,BaseCreditTotal,DocumentId,DocumentDetailId,ItemId,BaseCurrency,ExchangeRate,GSTExCurrency,GSTExchangeRate,DocType,DocSubType,ServiceCompanyId,DocNo, IsTax,
									EntityId, SystemRefNo, DocCurrency,DocDate, PostingDate,RecOrder )
					Select NEWID(),@MasterJournalId,COAId,Remarks,IsDisAllow,GrandTotal,Round(GrandTotal * @SysCalExchangerate,2),0.00 As DocDebitTotal,0.00 As DocCreditTotal,0.00 As BaseDebitTotal,0.00 As BaseCreditTotal,Id As DocumnetId,@GUIDZero,@GUIDZero,
							BaseCurrency,@SysCalExchangerate As ExchangeRate,GSTExCurrency,GSTExchangeRate,@DocType,@DocSubType,ServiceCompanyId,DocNo,0 As IsTax,
							EntityId,@MasterSystemRefNo As SystemRefNo,@BankChargesCurrency,DocDate,DocDate,@RecOrder As Recorder
					From Bean.Payment Where Id=@SourceId
					-- Clearing Payments
					-- Opt : Replaced Set with Select
					Select @ClearingPaymentsCOAID= Id From Bean.ChartOfAccount Where CompanyId=@CompanyId And Name=@ClearingPayments
					Insert Into Bean.JournalDetail (Id,JournalId,COAId,AccountDescription,AllowDisAllow, DocDebit, BaseDebit, DocDebitTotal,DocCreditTotal,BaseDebitTotal,BaseCreditTotal,DocumentId,DocumentDetailId,ItemId,BaseCurrency,ExchangeRate,GSTExCurrency,GSTExchangeRate,DocType,DocSubType,ServiceCompanyId,DocNo, IsTax,
									EntityId, SystemRefNo, DocCurrency,DocDate, PostingDate,RecOrder )
					Select NEWID(),@MasterJournalId,@ClearingPaymentsCOAID,Remarks,IsDisAllow,GrandTotal,Round(GrandTotal * @SysCalExchangerate,2),0.00 As DocDebitTotal,0.00 As DocCreditTotal,0.00 As BaseDebitTotal,0.00 As BaseCreditTotal,Id As DocumnetId,@GUIDZero,@GUIDZero,
							BaseCurrency,@SysCalExchangerate As ExchangeRate,GSTExCurrency,GSTExchangeRate,@DocType,@DocSubType,ServiceCompanyId,DocNo,0 As IsTax,
							EntityId,@MasterSystemRefNo As SystemRefNo,@BankChargesCurrency,DocDate,DocDate,@RecOrder As RecOrder
					From Bean.Payment Where Id=@SourceId

					-- 2nd Jv
					--Set @SystemRefNo= Concat(@DocNo,'-JV',Substring(Reverse(Substring(Reverse(@SystemRefNo),1,CHARINDEX('-',Reverse(@SystemRefNo)))),PATINDEX('%[0-9]%',@SystemRefNo),DATALENGTH(Reverse(Substring(Reverse(@SystemRefNo),1,CHARINDEX('-',Reverse(@SystemRefNo))))))+1)
					Set @SysRefNumOrder=@SysRefNumOrder+1
					Set @SystemRefNo=Concat(@DocNo,'-JV',@SysRefNumOrder)
					Set @JournalId=NEWID()
					Insert Into Bean.Journal (Id,CompanyId,DocDate,DocType,DocSubType,DocNo,ServiceCompanyId,SystemReferenceNo,IsNoSupportingDocs,NoSupportingDocument,DocCurrency,ExchangeRate,ExCurrency,ExDurationFrom,GSTExchangeRate,GSTExCurrency,GSTTotalAmount,DocumentState,IsNoSupportingDocument,IsGstSettings,IsMultiCurrency,IsAllowableNonAllowable,IsGSTCurrencyRateChanged,Remarks,UserCreated,CreatedDate,Status,DocumentDescription,CreationType,GrandDocDebitTotal,GrandDocCreditTotal,GrandBaseDebitTotal,
											GrandBaseCreditTotal,EntityId,EntityType,PostingDate,COAId,ModeOfReceipt,BankReceiptAmmount,ExcessPaidByClientAmmount,BalancingItemReciveCRAmount,  BalancingItemPayDRAmount,ReceiptApplicationAmmount,DocumentId, BankClearingDate ,IsBalancing,ISAllowDisAllow, IsShow, ActualSysRefNo 
											,IsSegmentReporting, TransferRefNo
											)
					Select @JournalId,@CompanyId,DocDate,@DocType,@DocSubType,DocNo,ServiceCompanyId,@SystemRefNo As SystemRefNo,IsNoSupportingDocument,NoSupportingDocs,DocCurrency,ExchangeRate,ExCurrency,ExDurationFrom,GSTExchangeRate,GSTExCurrency,Isnull(GSTTotalAmount,0),DocumentState,NoSupportingDocs,IsGstSettings,IsMultiCurrency,IsAllowableDisallowable,IsGSTCurrencyRateChanged,Remarks,@UserCreated,@CreatedDate,Status,Remarks As DocDescription,@UserCreated,GrandTotal,0.00 As GrandDocCreditTotal,Round(GrandTotal * ExchangeRate,2) As GrandBaseDebitTotal,
							0.00 As GrandBaseCreditTotal,EntityId,EntityType,DocDate As PostingDate,COAId,ModeOfReceipt,0.00 As BankReceiptAmmount,0.00 As ExcessPaidByClientAmmount,0.00 As BalancingItemReciveCRAmount,0.00 As BalancingItemPayDRAmount,0.00 As ReceiptApplicationAmmount,Id As DocumentId,BankClearingDate,0 As IsBalancing,IsDisAllow,1 As IsShow,DocNo As ActualSysRefNo,0 As IsSegmentReporting, PaymentRefNo
					From Bean.Payment Where CompanyId=@CompanyId And Id=@SourceId
					-- 2 nd Jv Clearing Payments			
					Insert Into Bean.JournalDetail (Id,JournalId,COAId,AccountDescription,AllowDisAllow, DocCredit, BaseCredit, DocDebitTotal,DocCreditTotal,BaseDebitTotal,BaseCreditTotal,DocumentId,DocumentDetailId,ItemId,BaseCurrency,ExchangeRate,GSTExCurrency,GSTExchangeRate,DocType,DocSubType,ServiceCompanyId,DocNo, IsTax,
									EntityId, SystemRefNo, DocCurrency,DocDate, PostingDate,RecOrder )
					Select NEWID(),@JournalId,@ClearingPaymentsCOAID,Remarks,IsDisAllow,PaymentApplicationAmmount,Round(PaymentApplicationAmmount * @DefaultExchangeRate,2),0.00 As DocDebitTotal,0.00 As DocCreditTotal,0.00 As BaseDebitTotal,0.00 As BaseCreditTotal,Id As DocumnetId,@GUIDZero,@GUIDZero,
							BaseCurrency,@SysCalExchangerate As ExchangeRate,GSTExCurrency,GSTExchangeRate,@DocType,@DocSubType,ServiceCompanyId,DocNo,0 As IsTax,
							EntityId,@SystemRefNo As SystemRefNo,@DocCurrency,DocDate,DocDate,@RecOrder As RecOrder
					From Bean.Payment Where Id=@SourceId

					-- Detail Records
					IF Exists(Select Id From Bean.PaymentDetail Where PaymentId=@SourceId And PaymentAmount<>0)
					Begin
						Insert Into @PaymentDtl
						Select Id From Bean.PaymentDetail Where PaymentId=@SourceId And PaymentAmount<>0
						Set @RecCount=1
						-- Opt : Replaced Set with Select
						Select @Count= Count(*) From @PaymentDtl
						While @Count>=@RecCount
						Begin
							-- Opt : Replaced Set with Select
							Select @PaymentDtlId= PaymentDtlId From @PaymentDtl Where S_No=@RecCount
							Set @IsRoundingAmount=0
							Select @DocumentId= DocumentId From Bean.PaymentDetail Where Id=@PaymentDtlId
							Select @OffSetDocumentType= DocumentType From Bean.PaymentDetail Where Id=@PaymentDtlId
							IF Exists (Select Id From Bean.PaymentDetail Where Id=@PaymentDtlId And Nature=@NatureTrade)
							Begin
								-- Opt : Replaced Set with Select
								Select @COAID= Id From Bean.ChartOfAccount Where CompanyId=@CompanyId And Name=@COATradePayables
							End
							Else IF Exists (Select Id From Bean.PaymentDetail Where Id=@PaymentDtlId And Nature=@NatureOthers)
							Begin
								-- Opt : Replaced Set with Select
								Select @COAID= Id From Bean.ChartOfAccount Where CompanyId=@CompanyId And Name=@COAOtherPayables
							End
							IF @OffSetDocumentType=@InvoiceDocument
							Begin
								-- Opt : Replaced Set with Select
								Select @ExchangeRate= ExchangeRate From Bean.Invoice Where Id=@DocumentId
								IF Exists (Select Id From Bean.Invoice Where Id=@DocumentId And DocumentState In (@FullyApplied,@Fullypaid))
								Begin
									Set @IsRoundingAmount=1
								End 
							End
							Else IF @OffSetDocumentType=@DebitNoteDocument
							Begin
								-- Opt : Replaced Set with Select
								Select @ExchangeRate= ExchangeRate From Bean.DebitNote Where Id=@DocumentId
								IF Exists (Select Id From Bean.DebitNote Where Id=@DocumentId And DocumentState In (@FullyApplied,@Fullypaid))
								Begin
									Set @IsRoundingAmount=1
								End 
							End
							Else IF @OffSetDocumentType in (@BillDocument,@PayrollBill,@openBal,@Payroll,@Claim,@General)
							Begin
								-- Opt : Replaced Set with Select
								Select @ExchangeRate= ExchangeRate From Bean.Bill Where Id=@DocumentId
								IF Exists (Select Id From Bean.Bill Where Id=@DocumentId And DocumentState In (@FullyApplied,@Fullypaid))
								Begin
									Set @IsRoundingAmount=1
								End 
							End

							IF @IsRoundingAmount=1 And Exists (Select Amount From @RoundingAmountDetails Where DocumentId=@DocumentId And Amount Is Not Null And Amount<>'') --And @RoundingAmount Is Not Null And @RoundingAmount <>''
							Begin
								-- Opt : Replaced Set with Select
								Select @DocAmount= Amount From @RoundingAmountDetails Where DocumentId=@DocumentId
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
							Select NEWID(),@JournalId,@COAID,P.Remarks,PD.PaymentAmount As DocDebit,Null As DocCredit,
								Round(PD.PaymentAmount * @DefaultExchangeRate,2)-Isnull(@DocAmount,0) As BaseDebit,Null As BaseCredit,
								0.00 As DocDebitTotal,0.00 As DocCreditTotal,0.00 As BaseDebitTotal,0.00 As BaseCreditTotal,P.Id As DocumnetId,PD.Id As DocumentDetailId,@GUIDZero,
								P.BaseCurrency,@DefaultExchangeRate As ExchangeRate,@DocType,@DocSubType,PD.ServiceCompanyId,P.DocNo,PD.Nature,Null As DocumentNo,0 As IsTax,
								P.EntityId,@SystemRefNo,@DocCurrency,P.DocDate,P.DocDate,@RecOrder As RecOrder
							From Bean.Payment As P
							Inner Join bean.PaymentDetail As PD On PD.PaymentId=P.Id
							Where P.Id=@SourceId And PD.Id=@PaymentDtlId
							Set @RecCount=@RecCount+1
						End
					End
				End
				Else IF @DocCurrency<>@BankChargesCurrency And @DocCurrency<>@BaseCurrency
				Begin
					IF Exists (Select Id From Bean.Payment Where Id=@SourceId And GrandTotal<>0)
					Begin
						/* Creating Mater record In JournalDetail */
						Insert Into Bean.JournalDetail (Id,JournalId,COAId,AccountDescription,AllowDisAllow, DocCredit, BaseCredit, DocDebitTotal,DocCreditTotal,BaseDebitTotal,BaseCreditTotal,DocumentId,DocumentDetailId,ItemId,BaseCurrency,ExchangeRate,GSTExCurrency,GSTExchangeRate,DocType,DocSubType,ServiceCompanyId,DocNo, IsTax,
										EntityId, SystemRefNo, DocCurrency,DocDate, PostingDate,RecOrder )
						Select NEWID(),@MasterJournalId,COAId,Remarks,IsDisAllow,GrandTotal,Round(GrandTotal * @DefaultExchangeRate,2),0.00 As DocDebitTotal,0.00 As DocCreditTotal,0.00 As BaseDebitTotal,0.00 As BaseCreditTotal,Id As DocumnetId,@GUIDZero,@GUIDZero,
								BaseCurrency,@DefaultExchangeRate As ExchangeRate,GSTExCurrency,GSTExchangeRate,@DocType,@DocSubType,ServiceCompanyId,DocNo,0 As IsTax,
								EntityId,@MasterSystemRefNo As SystemRefNo,@BankChargesCurrency,DocDate,DocDate,@RecOrder As RecOrder
						From Bean.Payment Where Id=@SourceId
						-- Clearing Payments
						-- Opt : Replaced Set with Select
						Select @ClearingPaymentsCOAID= Id 
						From Bean.ChartOfAccount Where CompanyId=@CompanyId And Name=@ClearingPayments

						Insert Into Bean.JournalDetail (Id,JournalId,COAId,AccountDescription,AllowDisAllow, DocDebit, BaseDebit, DocDebitTotal,DocCreditTotal,BaseDebitTotal,BaseCreditTotal,DocumentId,DocumentDetailId,ItemId,BaseCurrency,ExchangeRate,GSTExCurrency,GSTExchangeRate,DocType,DocSubType,ServiceCompanyId,DocNo, IsTax,
										EntityId, SystemRefNo, DocCurrency,DocDate, PostingDate,RecOrder )
						Select NEWID(),@MasterJournalId,@ClearingPaymentsCOAID,Remarks,IsDisAllow,GrandTotal,Round(GrandTotal * @DefaultExchangeRate,2),0.00 As DocDebitTotal,0.00 As DocCreditTotal,0.00 As BaseDebitTotal,0.00 As BaseCreditTotal,Id As DocumnetId,@GUIDZero,@GUIDZero,
								BaseCurrency,@DefaultExchangeRate As ExchangeRate,GSTExCurrency,GSTExchangeRate,@DocType,@DocSubType,ServiceCompanyId,DocNo,0 As IsTax,
								EntityId,@MasterSystemRefNo As SystemRefNo,@BankChargesCurrency,DocDate,DocDate,@RecOrder As RecOrder
						From Bean.Payment Where Id=@SourceId

						-- 2nd Jv
						--Set @SystemRefNo= Concat(@DocNo,'-JV',Substring(Reverse(Substring(Reverse(@SystemRefNo),1,CHARINDEX('-',Reverse(@SystemRefNo)))),PATINDEX('%[0-9]%',@SystemRefNo),DATALENGTH(Reverse(Substring(Reverse(@SystemRefNo),1,CHARINDEX('-',Reverse(@SystemRefNo))))))+1)
						Set @SysRefNumOrder=@SysRefNumOrder+1
						Set @SystemRefNo=Concat(@DocNo,'-JV',@SysRefNumOrder)
						Set @JournalId=NEWID()
						Insert Into Bean.Journal (Id,CompanyId,DocDate,DocType,DocSubType,DocNo,ServiceCompanyId,SystemReferenceNo,IsNoSupportingDocs,NoSupportingDocument,DocCurrency,ExchangeRate,ExCurrency,ExDurationFrom,GSTExchangeRate,GSTExCurrency,GSTTotalAmount,DocumentState,IsNoSupportingDocument,IsGstSettings,IsMultiCurrency,IsAllowableNonAllowable,IsGSTCurrencyRateChanged,Remarks,UserCreated,CreatedDate,Status,DocumentDescription,CreationType,GrandDocDebitTotal,GrandDocCreditTotal,GrandBaseDebitTotal,
												GrandBaseCreditTotal,EntityId,EntityType,PostingDate,COAId,ModeOfReceipt,BankReceiptAmmount,ExcessPaidByClientAmmount,BalancingItemReciveCRAmount,  BalancingItemPayDRAmount,ReceiptApplicationAmmount,DocumentId, BankClearingDate ,IsBalancing,ISAllowDisAllow, IsShow, ActualSysRefNo 
												,IsSegmentReporting, TransferRefNo
												)
						Select @JournalId,@CompanyId,DocDate,@DocType,@DocSubType,DocNo,ServiceCompanyId,@SystemRefNo As SystemRefNo,IsNoSupportingDocument,NoSupportingDocs,DocCurrency,ExchangeRate,ExCurrency,ExDurationFrom,GSTExchangeRate,GSTExCurrency,Isnull(GSTTotalAmount,0),DocumentState,NoSupportingDocs,IsGstSettings,IsMultiCurrency,IsAllowableDisallowable,IsGSTCurrencyRateChanged,Remarks,@UserCreated,@CreatedDate,Status,Remarks As DocDescription,@UserCreated,GrandTotal,0.00 As GrandDocCreditTotal,Round(GrandTotal * ExchangeRate,2) As GrandBaseDebitTotal,
								0.00 As GrandBaseCreditTotal,EntityId,EntityType,DocDate As PostingDate,COAId,ModeOfReceipt,0.00 As BankReceiptAmmount,0.00 As ExcessPaidByClientAmmount,0.00 As BalancingItemReciveCRAmount,0.00 As BalancingItemPayDRAmount,0.00 As ReceiptApplicationAmmount,Id As DocumentId,BankClearingDate,0 As IsBalancing,IsDisAllow,1 As IsShow,DocNo As ActualSysRefNo,0 As IsSegmentReporting, PaymentRefNo
						From Bean.Payment Where CompanyId=@CompanyId And Id=@SourceId
						-- 2 nd Jv Clearing Payments			
						Insert Into Bean.JournalDetail (Id,JournalId,COAId,AccountDescription,AllowDisAllow, DocCredit, BaseCredit, DocDebitTotal,DocCreditTotal,BaseDebitTotal,BaseCreditTotal,DocumentId,DocumentDetailId,ItemId,BaseCurrency,ExchangeRate,GSTExCurrency,GSTExchangeRate,DocType,DocSubType,ServiceCompanyId,DocNo, IsTax,
										EntityId, SystemRefNo, DocCurrency,DocDate, PostingDate,RecOrder )
						Select NEWID(),@JournalId,@ClearingPaymentsCOAID,Remarks,IsDisAllow,PaymentApplicationAmmount,Round(PaymentApplicationAmmount * @SysCalExchangerate,2),0.00 As DocDebitTotal,0.00 As DocCreditTotal,0.00 As BaseDebitTotal,0.00 As BaseCreditTotal,Id As DocumnetId,@GUIDZero,@GUIDZero,
								BaseCurrency,@SysCalExchangerate As ExchangeRate,GSTExCurrency,GSTExchangeRate,@DocType,@DocSubType,ServiceCompanyId,DocNo,0 As IsTax,
								EntityId,@SystemRefNo As SystemRefNo,@DocCurrency ,DocDate,DocDate,@RecOrder As RecOrder
						From Bean.Payment Where Id=@SourceId

						-- Detail Records
						IF Exists(Select Id From Bean.PaymentDetail Where PaymentId=@SourceId And PaymentAmount<>0)
						Begin
							Insert Into @PaymentDtl
							Select Id From Bean.PaymentDetail Where PaymentId=@SourceId And PaymentAmount<>0
							Set @RecCount=1
							-- Opt : Replaced Set with Select
							Select @Count= Count(*) From @PaymentDtl
							While @Count>=@RecCount
							Begin
								-- Opt : Replaced Set with Select
								Select @PaymentDtlId= PaymentDtlId From @PaymentDtl Where S_No=@RecCount
								IF Exists (Select Id From Bean.PaymentDetail Where Id=@PaymentDtlId And Nature=@NatureTrade)
								Begin
									-- Opt : Replaced Set with Select
									Select @COAID= Id From Bean.ChartOfAccount Where CompanyId=@CompanyId And Name=@COATradePayables
								End
								Else IF Exists (Select Id From Bean.PaymentDetail Where Id=@PaymentDtlId And Nature=@NatureOthers)
								Begin
									-- Opt : Replaced Set with Select
									Select @COAID= Id From Bean.ChartOfAccount Where CompanyId=@CompanyId And Name=@COAOtherPayables
								End
								-- Opt : Replaced Set with Select
								Select @DocumentId= DocumentId From Bean.PaymentDetail Where Id=@PaymentDtlId
								Select @OffSetDocumentType= DocumentType From Bean.PaymentDetail Where Id=@PaymentDtlId
								IF @OffSetDocumentType=@InvoiceDocument
								Begin
									-- Opt : Replaced Set with Select
									Select @ExchangeRate= ExchangeRate From Bean.Invoice Where Id=@DocumentId
									IF Exists (Select Id From Bean.Invoice Where Id=@DocumentId And DocumentState In (@FullyApplied,@Fullypaid))
									Begin
										Set @IsRoundingAmount=1
									End 
								End
								Else IF @OffSetDocumentType=@DebitNoteDocument
								Begin
									-- Opt : Replaced Set with Select
									Select @ExchangeRate= ExchangeRate From Bean.DebitNote Where Id=@DocumentId
									IF Exists (Select Id From Bean.DebitNote Where Id=@DocumentId And DocumentState In (@FullyApplied,@Fullypaid))
									Begin
										Set @IsRoundingAmount=1
									End 
								End
								Else IF @OffSetDocumentType in (@BillDocument,@PayrollBill,@openBal,@Payroll,@Claim,@General)
								Begin
									-- Opt : Replaced Set with Select
									Select @ExchangeRate= ExchangeRate From Bean.Bill Where Id=@DocumentId
									IF Exists (Select Id From Bean.Bill Where Id=@DocumentId And DocumentState In (@FullyApplied,@Fullypaid))
									Begin
										Set @IsRoundingAmount=1
									End 
								End

								IF @IsRoundingAmount=1 And Exists (Select Amount From @RoundingAmountDetails Where DocumentId=@DocumentId And Amount Is Not Null And Amount<>'') 
								Begin
									-- Opt : Replaced Set with Select
									Select @DocAmount= Amount From @RoundingAmountDetails Where DocumentId=@DocumentId
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
								Select NEWID(),@JournalId,@COAID,P.Remarks,PD.PaymentAmount As DocDebit,Null As DocCredit,
									Round(PD.PaymentAmount * @ExchangeRate,2)-Isnull(@DocAmount,0) As BaseDebit,Null As BaseCredit,
									0.00 As DocDebitTotal,0.00 As DocCreditTotal,0.00 As BaseDebitTotal,0.00 As BaseCreditTotal,P.Id As DocumnetId,PD.Id As DocumentDetailId,@GUIDZero,
									P.BaseCurrency,@ExchangeRate As ExchangeRate,@DocType,@DocSubType,PD.ServiceCompanyId,P.DocNo,PD.Nature,Null As DocumentNo,0 As IsTax,
									P.EntityId,@SystemRefNo,@DocCurrency,P.DocDate,P.DocDate,@RecOrder As RecOrder
								From Bean.Payment As P
								Inner Join bean.PaymentDetail As PD On PD.PaymentId=P.Id
								Where P.Id=@SourceId And PD.Id=@PaymentDtlId
								IF @SysCalExchangerate-@ExchangeRate<>0
								Begin
									-- Exchangegain or Loss
									Set @RecOrder=@RecOrder+1
									-- Opt : Replaced Set with Select
									Select @COAID= Id 
									From Bean.ChartOfAccount 
									Where CompanyId=@CompanyId And Name=@ExchangeGainOrLossRealised

									Insert Into Bean.JournalDetail (Id,JournalId,COAId,AccountDescription, DocDebit,DocCredit,
																	 BaseDebit,BaseCredit,
																	 DocDebitTotal,DocCreditTotal,BaseDebitTotal,BaseCreditTotal,DocumentId,DocumentDetailId,ItemId,BaseCurrency,ExchangeRate, DocType,DocSubType,ServiceCompanyId,DocNo,Nature,OffsetDocument,IsTax,
																	EntityId, SystemRefNo, DocCurrency,DocDate, PostingDate,RecOrder 
																	)
									Select NEWID(),@JournalId,@COAID,P.Remarks,Null As DocDebit,Null As DocCredit,
										Case When (@SysCalExchangerate-@ExchangeRate)>0 Then ABS(Round((@SysCalExchangerate-@ExchangeRate)  * PD.PaymentAmount,2)) End As BaseDebit,Case When (@SysCalExchangerate-@ExchangeRate)<0 Then ABS(Round((@SysCalExchangerate-@ExchangeRate) * PD.PaymentAmount,2) ) End As BaseCredit,
										0.00 As DocDebitTotal,0.00 As DocCreditTotal,0.00 As BaseDebitTotal,0.00 As BaseCreditTotal,P.Id As DocumnetId,PD.Id As DocumentDetailId,@GUIDZero,
										P.BaseCurrency,P.ExchangeRate,@DocType,@DocSubType,PD.ServiceCompanyId,P.DocNo,PD.Nature,PD.DocumentNo,0 As IsTax,
										EntityId,@SystemRefNo,@DocCurrency,DocDate,DocDate,@RecOrder As RecOrder
									From Bean.Payment As P
									Inner Join bean.PaymentDetail As PD On PD.PaymentId=P.Id
									Where P.Id=@SourceId And PD.Id=@PaymentDtlId
								End
								Set @RecCount=@RecCount+1
							End
						End
					End
				End
			End	
			-- Rounding
			Insert Into @Rounding_Tbl
			Select Id From Bean.Journal where DocumentId=@SourceId And DocType=@Type
			-- Opt : Replaced Set with Select
			Select @Count= Count(*) From @Rounding_Tbl
			Set @RecCount=1
			While @Count>=@RecCount
			Begin
				-- Opt : Replaced Set with Select
				Select @JournalId= JournalId From @Rounding_Tbl Where S_No=@RecCount

				Set @DocCurrency= (Select Top(1) DocCurrency From bean.JournalDetail Where JournalId=@JournalId)
				/* Rounding Amount Base*/
				Select @RoundingAmt= SUM(ISnull(BaseDebit,0)-Isnull(BaseCredit,0)) 
				From Bean.JournalDetail Where JournalId=@JournalId
				IF @RoundingAmt<>0 
				Begin
					-- Opt : Replaced Set with Select
					Select @RecOrder= Max(RecOrder)+1 From Bean.JournalDetail Where JournalId=@JournalId
					Select @RoundingCOAID= Id From Bean.ChartOfAccount Where CompanyId=@CompanyId And Name=@Rounding
					Insert Into Bean.JournalDetail (Id,JournalId,COAId,AccountDescription, DocDebit,DocCredit,
									 BaseDebit,BaseCredit,
									 DocDebitTotal,DocCreditTotal,BaseDebitTotal,BaseCreditTotal,DocumentId,DocumentDetailId,ItemId,BaseCurrency,DocType,DocSubType,ServiceCompanyId,DocNo, IsTax,
									EntityId,DocCurrency,DocDate, PostingDate,RecOrder 
									)
					Select NEWID(),@JournalId,@RoundingCOAID,R.Remarks,Null As DocDebit,Null As DocCredit,
						Case When @RoundingAmt<0 Then ABS(@RoundingAmt) End BaseDebit,Case When @RoundingAmt>0 Then @RoundingAmt End BaseCredit,
						0.00 As DocDebitTotal,0.00 As DocCreditTotal,0.00 As BaseDebitTotal,0.00 As BaseCreditTotal,R.Id As DocumentId,NewId() As DocumentDetailId,@GUIDZero,
						R.BaseCurrency,@DocType,@DocSubType,R.ServiceCompanyId,R.DocNo,0 As IsTax,
						EntityId,@DocCurrency,DocDate,DocDate,@RecOrder As RecOrder
					From Bean.Payment As R
					Where R.Id=@SourceId 
				End
				/* Rounding Amount Doc */
				-- Opt : Replaced Set with Select
				Select @RoundingAmt= SUM(Isnull(DocDebit,0))-SUM(Isnull(DocCredit,0)) 
				From Bean.JournalDetail Where JournalId=@JournalId
				IF @RoundingAmt<>0 
				Begin
					-- Opt : Replaced Set with Select
					Select @RecOrder= Max(RecOrder)+1 From Bean.JournalDetail Where JournalId=@JournalId
					Select @RoundingCOAID= Id From Bean.ChartOfAccount Where CompanyId=@CompanyId And Name=@Rounding
					Insert Into Bean.JournalDetail (Id,JournalId,COAId,AccountDescription, DocDebit,DocCredit,
									 BaseDebit,BaseCredit,
									 DocDebitTotal,DocCreditTotal,BaseDebitTotal,BaseCreditTotal,DocumentId,DocumentDetailId,ItemId,BaseCurrency,DocType,DocSubType,ServiceCompanyId,DocNo, IsTax,
									EntityId,DocCurrency,DocDate, PostingDate,RecOrder 
									)
					Select NEWID(),@JournalId,@RoundingCOAID,R.Remarks,Case When @RoundingAmt<0 Then ABS(@RoundingAmt) End As DocDebit,Case When @RoundingAmt>0 Then @RoundingAmt End As DocCredit,
						Null BaseDebit,Null BaseCredit,
						0.00 As DocDebitTotal,0.00 As DocCreditTotal,0.00 As BaseDebitTotal,0.00 As BaseCreditTotal,R.Id As DocumentId,NewId() As DocumentDetailId,@GUIDZero,
						R.BaseCurrency,@DocType,@DocSubType,R.ServiceCompanyId,R.DocNo,0 As IsTax,
						EntityId,@DocCurrency,DocDate,DocDate,@RecOrder As RecOrder
					From Bean.Payment As R
					Where R.Id=@SourceId 
				End
				Set @RecCount=@RecCount+1
			End
		End

		Exec Bean_Update_BRC_Re_Run @companyId,@OldServEntityId,@NewServEntityId,@NewCoaId,@OldCoaId,@OldDocdate,@NewDocDate,@OldDocAmount,@NewDocAmount,@IsAdd

		Commit Transaction;
	End Try
	Begin Catch
		Rollback
		-- Opt : Replaced Set with Select
		Set @ErrorMessage= ERROR_MESSAGE()
		RaisError(@ErrorMessage,16,1)
	End Catch
End
GO
