USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[Bean_IC_Posting_ALL]    Script Date: 16-12-2024 9.20.10 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE   Procedure [dbo].[Bean_IC_Posting_ALL] 
@SourceId Uniqueidentifier,
@Type Nvarchar(20),		--Invoice/DebitNote/CreditNote/Bill etc..
@CompanyId Int
As
Begin
	Declare @CreationTypeSystem varchar(20) = 'System';

	-- For Customer Balance Updation
	Declare @EntityId UniqueIdentifier

	-- Document Constants
	Declare @TransferDocument varchar(20)='Transfer',
	@Withdrawal nvarchar(20)='Withdrawal',
	@Deposit nvarchar(20)='Deposit'

	-- Nature
	--Declare @NatureTrade varchar(20) = 'Trade'
	--Declare @NatureOthers varchar(20) = 'Others'
	Declare @SubTypeInterco varchar(20) ='Interco'


	-- COA Names
	Declare @COAClaring_BT varchar(50) = 'Clearing - Transfers'
	Declare @COAExchange_gain_loss varchar(50) = 'Exchange gain/loss - Realised'
	Declare @COATaxPaybleGST Varchar(50)='Tax payable (GST)'
	Declare @Rounding Varchar(50) ='Rounding'
	Declare @IBCOA_Name varchar(50)='Intercompany billing'
	 

	-- ZeroGUID
	Declare @GUIDZero Uniqueidentifier ='00000000-0000-0000-0000-000000000000'

	-- Local Variables
	Declare @JournalId Uniqueidentifier
	Declare @ErrorMessage Nvarchar(4000)
	Declare	@Count Int
	Declare @RecCount Int
	Declare @DetailCount Int
	Declare @RecOrder Int
	Declare @DetailId Uniqueidentifier
	Declare @DocumentId Uniqueidentifier
	Declare @Temp Table (S_No Int identity(1,1),DetailId Uniqueidentifier, SubCompanyId Bigint)
	Declare @IBCOA Table (COAName nvarchar(50),COAId bigint,ServiceEntityId bigint)
	Declare @DepositCurrency varchar(10)
	Declare @WithDrawalCurrency varchar(10)
	Declare @WithServiceCompId int
	Declare @DepositServiceCompId int
	Declare @WithCOAId bigint
	Declare @DepoCOAId bigint
	Declare @ClearingCOAId bigint
	Declare @WithdrawalEntityId uniqueidentifier
	Declare @DepositEntityId uniqueidentifier
	Declare @BaseCurrency varchar(20)
	Declare @BCDocumentHistoryType DocumentHistoryTableType
	  

	---------For Interco
	Declare @ServiceEntityId BigInt
	Declare @Nature Nvarchar(20)
	Declare @GainLossCOAId int
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
	Declare	@OldWithdrawalServEntityId BigInt,
		@NewWithdrawalServEntityId BigInt,
		@OldDepositServEntityId BigInt,
		@NewDepositServEntityId BigInt,
		@OldWithdrawalCoaId BigInt,
		@OldDepositCoaId BigInt,
		@NewWithdrawalCoaId BigInt,
		@NewDepositCoaId BigInt,

		@OldDocdate DateTime,
		@NewDocDate DateTime,
		@WithdrawalAmount Money,
		@DepositAmount Money,
		@IsAdd bit,
		@IsBankAccountExists bit

	--Common Error Message
	Declare @InvalidDocumentError Nvarchar(200)='Invalid Document'
	
	---For Customer Balance updation
	Declare @OldEntityId UniqueIdentifier, @OldCustCreditLimit Money
	Declare @CustEntId nvarchar(max)

	Begin Transaction
		Begin Try
		Set @ClearingCOAId=(Select Id from Bean.ChartOfAccount where CompanyId=@CompanyId and Name=@COAClaring_BT)
		 Select @BaseCurrency=ExCurrency,@ExchangeRate=(Case When BT.SystemCalculatedExchangeRate is null OR BT.SystemCalculatedExchangeRate=0 Then BT.ExchangeRate Else BT.SystemCalculatedExchangeRate End) From Bean.BankTransfer BT Where Id=@SourceId and CompanyId=@CompanyId 
		SET @GainLossCOAId=(Select Id from Bean.ChartOfAccount where CompanyId=@CompanyId and Name=@COAExchange_gain_loss)
			If (@Type=@TransferDocument)
			Begin
				Set @DocumentId =@SourceId
				Select @DepositServiceCompId=BD.ServiceCompanyId,@DepositCurrency=BD.Currency,@DepoCOAId=BD.COAId,@DepositAmount=BD.Amount from Bean.BankTransferDetail BD where BD.BankTransferId=@SourceId and BD.Type=@Deposit
				Select @WithServiceCompId=BD.ServiceCompanyId,@WithDrawalCurrency=BD.Currency,@WithCOAId=BD.COAId,@WithdrawalAmount=Bd.Amount from Bean.BankTransferDetail BD where BD.BankTransferId=@SourceId and BD.Type=@Withdrawal
				IF @DepositServiceCompId!=0 OR @DepositServiceCompId is not null
				Begin
					Set @DepositEntityId=(Select Id from Bean.Entity where CompanyId=@CompanyId and ServiceEntityId=@DepositServiceCompId)
				End
				IF @WithServiceCompId!=0 OR @WithServiceCompId is not null
				Begin
					Set @WithdrawalEntityId=(Select Id from Bean.Entity where CompanyId=@CompanyId and ServiceEntityId=@WithServiceCompId)
				End
				If Exists(select Id from Bean.Journal where CompanyId=@CompanyId and DocumentId=@DocumentId)
				Begin
					--Select @OldEntityId = EntityId from Bean.Journal where CompanyId=@CompanyId and DocumentId=@DocumentId
					Delete from Bean.JournalDetail where DocumentId=@DocumentId and DocType=@Type
					Delete from Bean.Journal where DocumentId=@DocumentId and CompanyId=@CompanyId and DocType=@Type
				End
				Else
				Begin
					--For Customer Balance updation we are getting EntityID 
					Set @OldEntityId = @EntityId 
				End
				
				-- Inserting Records Into Journal From Bank Transfer 
			IF @DepositCurrency<>@WithDrawalCurrency
			Begin
				Set @JournalId = NEWID()
				Insert Into Bean.Journal (Id,CompanyId,DocDate,DocType,DocSubType,DocNo,ServiceCompanyId,SystemReferenceNo,IsNoSupportingDocs,NoSupportingDocument,DocCurrency,ExchangeRate,ExCurrency,GSTExchangeRate,GSTExCurrency,GSTTotalAmount,DocumentState,IsNoSupportingDocument,IsGstSettings,IsMultiCurrency,IsAllowableNonAllowable,Remarks,UserCreated,CreatedDate,ModifiedBy,ModifiedDate,Status,DocumentDescription,CreationType,GrandDocCreditTotal,GrandBaseCreditTotal,DueDate,EntityId,EntityType,PoNo,PostingDate,IsGSTApplied,COAId,DocumentId,CreditTermsId,Nature,BalanceAmount,ActualSysRefNo,RefNo,IsSegmentReporting)

				Select @JournalId,CompanyId,TransferDate,@Type,@SubTypeInterco,DocNo,@WithServiceCompId As ServiceCompanyId,DocNo As SystemRefNo,IsNoSupportingDocument,IsNoSupportingDocument,ExCurrency,ExchangeRate,ExCurrency, NULL,NULL,0,DocumentState,/**/[IsNoSupportingDocument],IsGstSetting,IsMultiCurrency,0,Remarks,UserCreated,CreatedDate,ModifiedBy,ModifiedDate,Status,DocDescription,@CreationTypeSystem,Round(@WithdrawalAmount,2) As GrandDocCreditTotal,Round(@WithdrawalAmount,2) As GrandBaseCreditTotal,
						NULL,NULL,NULL,NULL,TransferDate As PostingDate,0,
						 @DepoCOAId As COAId,
							Id As Documentid,Null,NULL,NULL,DocNo As ActualSysRefNo,Null,0
				 From Bean.BankTransfer Where Id=@DocumentId 

				-- Inserting Records Into JournalDetail From InvoceDetail
				  
					Insert Into Bean.JournalDetail (Id,JournalId,COAId,AccountDescription,TaxId,TaxRate,DocDebit,DocCredit,DocTaxCredit,BaseDebit,BaseCredit,DocDebitTotal,DocCreditTotal,BaseDebitTotal,BaseCreditTotal,DocumentId,DocumentDetailId,BaseCurrency,ExchangeRate,GSTExCurrency,GSTExchangeRate,DocType,DocSubType,ServiceCompanyId,DocNo,Nature,OffsetDocument,IsTax,EntityId,SystemRefNo,Remarks,PONo,CreditTermsId,DocCurrency,DocDate,DocDescription,PostingDate,RecOrder,DocTaxAmount,BaseTaxAmount,BaseTaxCredit)
					Select NEWID(),@JournalId,Case When BTD.Type=@Withdrawal Then @ClearingCOAId Else @WithCOAId End As COAId,BT.DocDescription As AccountDescription,NULL,NULL,
					Case When BTD.Type=@Withdrawal THEN @WithdrawalAmount Else Null END As DocDebit,
					Case When BTD.Type=@Deposit THEN @WithdrawalAmount Else Null END As DocCredit,NULL,
					Case When BTD.Type=@Withdrawal THEN 
						Case When BT.ExCurrency=@WithDrawalCurrency Then @WithdrawalAmount Else Round((@WithdrawalAmount*IsNUll(Case When @DepositCurrency=@WithDrawalCurrency Then BT.ExchangeRate Else BT.SystemCalculatedExchangeRate End,1)),2) End Else Null END As BaseDebit,
					Case When BTD.Type=@Deposit THEN 
										Case When BT.ExCurrency=@WithDrawalCurrency Then @WithdrawalAmount Else Round((@WithdrawalAmount*IsNUll(Case When @DepositCurrency=@WithDrawalCurrency Then BT.ExchangeRate Else BT.SystemCalculatedExchangeRate End,1)),2) End 
						Else Null END As BaseCredit,'0.00',0,null,null,							@DocumentId,BTD.Id,BT.ExCurrency,NULL,NULL,NULL,@Type,@SubTypeInterco,@WithServiceCompId,BT.DocNo,NULL,Null As OffsetDocument,0 As IsTax,NULL,BT.DocNo As SystemRefNo,BT.Remarks,Null,0 As CreditTermsId,@WithDrawalCurrency as DocCurrency,BT.TransferDate,
							null As DocDescription,BT.TransferDate As PostingDate,BTD.RecOrder As RecOrder,NULL,NULL,NULL				
					From Bean.BankTransferDetail As BTD
					Inner Join Bean.BankTransfer As BT On BT.Id=BTD.BankTransferId
					Where BTD.BankTransferId=@SourceId and @WithdrawalAmount<>0
			End

			--insert IB related COA data to temp table
			Insert into @IBCOA 

			Select COA.Name as COAName,COA.Id as COAId,COA.SubsidaryCompanyId as ServiceEntityId from Bean.AccountType ATY Inner join Bean.ChartOfAccount COA on COA.AccountTypeId=ATY.Id where COA.SubsidaryCompanyId in (@DepositServiceCompId,@WithServiceCompId) and ATY.Name=@IBCOA_Name and ATY.CompanyId=@CompanyId

			Insert Into @Temp
			Select Id,ServiceCompanyId From Bean.SettlementDetail Where BankTransferId=@DocumentId Order By RecOrder
			Select @RecCount=Count(*) From @Temp
			Set @Count=1
			
			while @Count<=2
			Begin
				Set @RecOrder=1
				Set @JournalId = NEWID()
				Insert Into Bean.Journal (Id,CompanyId,DocDate,DocType,DocSubType,DocNo,ServiceCompanyId,SystemReferenceNo,IsNoSupportingDocs,NoSupportingDocument,DocCurrency,ExchangeRate,ExCurrency,GSTExchangeRate,GSTExCurrency,GSTTotalAmount,DocumentState,IsNoSupportingDocument,IsGstSettings,IsMultiCurrency,IsAllowableNonAllowable,Remarks,UserCreated,CreatedDate,ModifiedBy,ModifiedDate,Status,DocumentDescription,CreationType,GrandDocCreditTotal,GrandBaseCreditTotal,DueDate,EntityId,EntityType,PoNo,PostingDate,IsGSTApplied,COAId,DocumentId,CreditTermsId,Nature,BalanceAmount,ActualSysRefNo,RefNo,IsSegmentReporting)

				Select @JournalId,CompanyId,TransferDate,@Type,@SubTypeInterco,DocNo,Case When @Count=1 Then @WithServiceCompId Else @DepositServiceCompId End As ServiceCompanyId,DocNo As SystemRefNo,IsNoSupportingDocument,IsNoSupportingDocument,ExCurrency,ExchangeRate,ExCurrency, NULL,NULL,0,DocumentState,/**/[IsNoSupportingDocument],IsGstSetting,IsMultiCurrency,0,Remarks,UserCreated,CreatedDate,ModifiedBy,ModifiedDate,Status,DocDescription,@CreationTypeSystem,Round(@WithdrawalAmount,2) As GrandDocCreditTotal,Round(@WithdrawalAmount,2) As GrandBaseCreditTotal,
						NULL,Case When @Count=1 Then @DepositEntityId Else @WithdrawalEntityId End as EntityId,NULL,NULL,TransferDate As PostingDate,0,
						 @DepoCOAId As COAId,
							Id As Documentid,Null,NULL,NULL,DocNo As ActualSysRefNo,Null,0
				 From Bean.BankTransfer Where Id=@DocumentId

				-- Inserting Records Into JournalDetail As MasterRecord
				  
					Insert Into Bean.JournalDetail (Id,JournalId,COAId,AccountDescription,DocDebit,DocCredit,BaseDebit,BaseCredit,DocDebitTotal,DocCreditTotal,BaseDebitTotal,BaseCreditTotal,DocumentId,DocumentDetailId,BaseCurrency,ExchangeRate,GSTExCurrency,GSTExchangeRate,DocType,DocSubType,ServiceCompanyId,DocNo,Nature,OffsetDocument,IsTax,EntityId,SystemRefNo,CreditTermsId,DocCurrency,DocDate,DocDescription,PostingDate,RecOrder)

					Select NEWID(),@JournalId,Case When @Count=1 and @WithDrawalCurrency<>@DepositCurrency Then @ClearingCOAId Else   Case when @Count=1 Then @WithCOAId Else  BTD.COAId End End As COAId,BT.DocDescription As AccountDescription,
					Case When @Count=2 THEN BTD.Amount Else Null END As DocDebit,
					Case When @Count=1 THEN BTD.Amount Else Null END As DocCredit,
					Case When @Count=2 THEN Case When BT.ExCurrency=BTD.Currency Then BTD.Amount Else Round((BTD.Amount*IsNUll(Case When @DepositCurrency=@WithDrawalCurrency Then BT.ExchangeRate Else BT.SystemCalculatedExchangeRate End,1)),2) End Else Null END As BaseDebit,
					Case When @Count=1 THEN 
									Case When BT.ExCurrency=BTD.Currency Then BTD.Amount Else Round((BTD.Amount*IsNUll(Case When @DepositCurrency=@WithDrawalCurrency Then BT.ExchangeRate Else BT.SystemCalculatedExchangeRate End,1)),2) End 
						Else Null END As BaseCredit,'0.00',0,null,null,							@DocumentId,BTD.Id,BT.ExCurrency,NULL,NULL,NULL,@Type,@SubTypeInterco,/*BTD.ServiceCompanyId*/Case When @Count=1 Then @WithServiceCompId Else @DepositServiceCompId End As ServiceCompanyId,BT.DocNo,NULL,Null As OffsetDocument,0 As IsTax,NULL,BT.DocNo As SystemRefNo,0 As CreditTermsId,BTD.Currency,BT.TransferDate,
							null As DocDescription,BT.TransferDate As PostingDate,@RecOrder As RecOrder				
					From Bean.BankTransferDetail As BTD
					Inner Join Bean.BankTransfer As BT On BT.Id=BTD.BankTransferId
					Where BTD.BankTransferId=@SourceId and BTD.Type=@Deposit and BTD.Amount<>0

					Set @RecOrder=@RecOrder+1

					Set @DetailCount=1
					While @RecCount>=@DetailCount
					Begin
						Set @DetailId=(Select DetailId From @Temp Where S_No=@DetailCount)
						Set @ServiceEntityId=(Select SubCompanyId From @Temp Where S_No=@Count)

						 Insert Into Bean.JournalDetail (Id,JournalId,COAId,AccountDescription,DocDebit,DocCredit,BaseDebit,BaseCredit,DocDebitTotal,DocCreditTotal,BaseDebitTotal,BaseCreditTotal,DocumentId,DocumentDetailId,BaseCurrency,ExchangeRate,GSTExCurrency,GSTExchangeRate,DocType,DocSubType,ServiceCompanyId,DocNo,Nature,OffsetDocument,IsTax,EntityId,SystemRefNo,CreditTermsId,DocCurrency,DocDate,DocDescription,PostingDate,RecOrder)

						Select NEWID(),@JournalId,
						Case When @Count=2 Then (Select COAId from @IBCOA B where B.ServiceEntityId=@WithServiceCompId) Else (Select COAId from @IBCOA B where B.ServiceEntityId=@DepositServiceCompId) End As COAId,BT.DocDescription As AccountDescription,
						Case When @Count=1 and SETD.SettlemetType=@Withdrawal THEN SETD.SettledAmount 
								When @Count=2 and SETD.SettlemetType=@Deposit THEN SETD.SettledAmount
						 END As DocDebit,
						Case When @Count=1 and SETD.SettlemetType=@Deposit THEN SETD.SettledAmount
							 When @Count=2 and SETD.SettlemetType=@Withdrawal THEN SETD.SettledAmount 
						END As DocCredit,
						Case When @Count=1 and SETD.SettlemetType=@Withdrawal THEN 
								Case When BT.ExCurrency=SETD.Currency Then SETD.SettledAmount Else Round((SETD.SettledAmount*IsNUll(SETD.ExchangeRate,1)),2) END
								When @Count=2 and SETD.SettlemetType=@Deposit THEN 
										Case When BT.ExCurrency=SETD.Currency Then SETD.SettledAmount Else Round				((SETD.SettledAmount*IsNUll(SETD.ExchangeRate,1)),2) END
						END As BaseDebit,
						Case When @Count=1 and SETD.SettlemetType=@Deposit THEN 
											Case When BT.ExCurrency=SETD.Currency Then SETD.SettledAmount Else Round((SETD.SettledAmount*IsNUll(SETD.ExchangeRate,1)),2) End 
								When @Count=2 and SETD.SettlemetType=@Withdrawal THEN 
											Case When BT.ExCurrency=SETD.Currency Then SETD.SettledAmount Else Round((SETD.SettledAmount*IsNUll(SETD.ExchangeRate,1)),2) End 
						END As BaseCredit,'0.00',0,null,null,							@DocumentId,SETD.Id,BT.ExCurrency,NULL,NULL,NULL,@Type,@SubTypeInterco,Case When @Count=1 Then @WithServiceCompId Else @DepositServiceCompId End As ServiceCompanyId,BT.DocNo,NULL,Null As OffsetDocument,0 As IsTax,Case When @Count=1 Then @DepositEntityId Else @WithdrawalEntityId End as EntityId,BT.DocNo As SystemRefNo,0 As CreditTermsId,SETD.Currency,BT.TransferDate,
								null As DocDescription,BT.TransferDate As PostingDate,@RecOrder As RecOrder				
						From Bean.SettlementDetail As SETD
						Inner Join Bean.BankTransfer As BT On BT.Id=SETD.BankTransferId
						Where SETD.Id=@DetailId and SETD.SettledAmount<>0

						--Record order Increment purpose
						Set @RecOrder=@RecOrder+1

						IF @BaseCurrency<>@DepositCurrency
						Begin
							
							Insert Into Bean.JournalDetail (Id,JournalId,COAId,AccountDescription,DocDebit,DocCredit,BaseDebit,BaseCredit,DocDebitTotal,DocCreditTotal,BaseDebitTotal,BaseCreditTotal,DocumentId,DocumentDetailId,BaseCurrency,ExchangeRate,GSTExCurrency,GSTExchangeRate,DocType,DocSubType,ServiceCompanyId,DocNo,Nature,OffsetDocument,IsTax,EntityId,SystemRefNo,CreditTermsId,DocCurrency,DocDate,DocDescription,PostingDate,RecOrder)

						Select NEWID(),@JournalId,@GainLossCOAId As COAId,BT.DocDescription As AccountDescription,Null As DocDebit,NUll As DocCredit,
						Case When SETD.SettlemetType=@Withdrawal AND @ExchangeRate>SETD.ExchangeRate and @Count=1 THEN ROUND(SETD.SettledAmount*( @ExchangeRate-SETD.ExchangeRate),2)
							 When SETD.SettlemetType=@Deposit AND @ExchangeRate>SETD.ExchangeRate and @Count=2 THEN ROUND(SETD.SettledAmount*(@ExchangeRate-SETD.ExchangeRate),2)
								When SETD.SettlemetType=@Deposit AND @ExchangeRate<SETD.ExchangeRate and @Count=1 THEN ROUND(SETD.SettledAmount*(SETD.ExchangeRate-@ExchangeRate),2)
								When SETD.SettlemetType=@Withdrawal AND @ExchangeRate<SETD.ExchangeRate and @Count=2 THEN ROUND (SETD.SettledAmount*(SETD.ExchangeRate-@ExchangeRate),2)
						 END As BaseDebit,
						Case When SETD.SettlemetType=@Deposit AND @ExchangeRate>SETD.ExchangeRate and @Count=1 THEN ROUND(SETD.SettledAmount*(@ExchangeRate-SETD.ExchangeRate),2)
							 When SETD.SettlemetType=@Withdrawal AND @ExchangeRate>SETD.ExchangeRate and @Count=2 THEN ROUND(SETD.SettledAmount*(@ExchangeRate-SETD.ExchangeRate),2)
								When SETD.SettlemetType=@Deposit AND @ExchangeRate<SETD.ExchangeRate and @Count=2 THEN ROUND(SETD.SettledAmount*(SETD.ExchangeRate-@ExchangeRate),2)
								When SETD.SettlemetType=@Withdrawal AND @ExchangeRate<SETD.ExchangeRate and @Count=1 THEN ROUND(SETD.SettledAmount*( SETD.ExchangeRate-@ExchangeRate),2) 
								END As BaseCredit,'0.00',0,null,null,							@DocumentId,SETD.Id,BT.ExCurrency,NULL,NULL,NULL,@Type,@SubTypeInterco,/*SETD.ServiceCompanyId*/Case When @Count=1 Then @WithServiceCompId Else @DepositServiceCompId End As ServiceCompanyId,BT.DocNo,NULL,Null As OffsetDocument,0 As IsTax,Case When @Count=1 Then @DepositEntityId Else @WithdrawalEntityId End as EntityId,BT.DocNo As SystemRefNo,0 As CreditTermsId,SETD.Currency,BT.TransferDate,
								null As DocDescription,BT.TransferDate As PostingDate,@RecOrder As RecOrder				
						From Bean.SettlementDetail As SETD
						Inner Join Bean.BankTransfer As BT On BT.Id=SETD.BankTransferId
						Where SETD.Id=@DetailId

						Set @RecOrder=@RecOrder+1	 
						End

						Set @DetailCount=@DetailCount+1
					End
				Set @Count=@Count+1	

				--Debit Credit mismatch line item purpose
				If((select ABS(SUM(BaseDebit)-SUM(BaseCredit)) from Bean.JournalDetail where JournalId=@JournalId group by DocType)>=0.01)
				Begin
					Select @BaseDebit=SUM(BaseDebit),@BaseCredit=SUM(BaseCredit),@DiffAmount=ABS(SUM(BaseDebit)-SUM(BaseCredit)) from Bean.JournalDetail where DocumentId=@DocumentId
					
					Insert Into Bean.JournalDetail (Id,JournalId,COAId,AccountDescription,BaseDebit,BaseCredit,DocumentId,DocumentDetailId,ItemId,DocDate,DueDate,PostingDate,ExchangeRate,GSTExchangeRate,GSTExCurrency,Nature,DocType,DocSubType,ServiceCompanyId, CreditTermsId, DocNo, Currency, BaseCurrency, IsTax, EntityId, SystemRefNo,  DocCurrency, RecOrder,DocDebitTotal,DocCreditTotal)
					select NEWID(), @JournalId, (Select Id from Bean.ChartOfAccount where CompanyId=@CompanyId and Name=@Rounding), DocDescription, Case When @BaseDebit>@BaseCredit Then null Else @DiffAmount End as BaseDebit, Case When @BaseCredit>@BaseDebit Then null Else @DiffAmount END as BaseCredit, @DocumentId,NEWID(),@GUIDZero,TransferDate,TransferDate,TransferDate,ExchangeRate,ExchangeRate,'SGD',null,DocType,@SubTypeInterco,/*@ServiceEntityId*/Case When @Count=1 Then @WithServiceCompId Else @DepositServiceCompId End As ServiceCompanyId,0,DocNo, @DepositCurrency, ExCurrency, 0, Case When @Count=1 Then @DepositEntityId Else @WithdrawalEntityId End as EntityId,DocNo, @DepositCurrency,@RecOrder as RecOrder,0,0
					from Bean.BankTransfer where CompanyId=@CompanyId and Id=@DocumentId

					Set @RecOrder=@RecOrder+1
				End
				
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
