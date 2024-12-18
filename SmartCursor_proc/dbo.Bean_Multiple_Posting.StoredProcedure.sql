USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[Bean_Multiple_Posting]    Script Date: 16-12-2024 9.20.10 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE   Procedure [dbo].[Bean_Multiple_Posting]
(
@CompanyId BigInt,
@DocType Nvarchar(50),
@DocSubType Nvarchar(50),
@MasterId UniqueIdentifier,
@DocumentId UniqueIdentifier,
@IsreverseExcess Bit,
@IsOffset Bit,
@RoundingAmount nvarchar(max)

)
As 
Begin
-- Document Constants
	Declare @InvoiceDocument varchar(20) ='Invoice',
			@DebitNoteDocument varchar(20) ='Debit Note'
			
-- Nature
	Declare @NatureTrade varchar(20) = 'Trade',
			@NatureOthers varchar(20) = 'Others',
			@NatureInterco varchar(20) ='Interco'
---Doc Type
	Declare @CreditMemoDocument varchar(20) ='Credit Memo',
	@CreditNoteDocument varchar(20) ='Credit Note',
	 @DebtProvisionDocument nvarchar(20)='Debt Provision'
-- COA Names
	Declare @COATradeReceivables varchar(50) = 'Trade receivables',
	@COAotherReceivables varchar(50) = 'Other receivables', 
	@COATaxPaybleGST Varchar(50)='Tax payable (GST)', 
	@COATradePayables varchar(50) = 'Trade payables', 
	@COAOtherPayables varchar(50) = 'Other payables',
	@Rounding Varchar(50) ='Rounding',
	@ExchangeGainLossRealised Nvarchar(50)='Exchange gain/loss - Realised',
	@COADoubtfulDebtexpense varchar(50)='Doubtful debt expense',
	@COADebt_Provision_TR varchar(50)='Debt provision (TR)',
	@COADebt_Provision_OR varchar(50)='Debt provision (OR)'

	-- ZeroGUID
	Declare @GUIDZero Uniqueidentifier ='00000000-0000-0000-0000-000000000000'
	-- Local Variables
	Declare @JournalId Uniqueidentifier
	Declare @ErrorMessage Nvarchar(4000), @Count Int, @RecCount Int, @DetailId Uniqueidentifier
	--Declare @RecOrder Int
	Declare @TaxRate Float, @TaxRecCount Int, @TaxRecOrder Int = 1, @TypeNumber int = 0, @NA Char(2)='NA'
	Declare @Temp Table (Id Int identity(1,1),DetailId Uniqueidentifier)
	Declare @BCDocumentHistoryType DocumentHistoryTableType
	---------For Interco
	Declare @ServiceEntityId BigInt, @Nature Nvarchar(20)
	----For Base Debit and Base Credit Mis match
	Declare @BaseDebit Money,@BaseCredit Money,@DiffAmount Money,@MasterBaseAmount Money,@ExchangeRate Decimal(15,10)
	----For DocSub Type
	Declare @DocSubTypeGeneral Nvarchar(25)='General', @DocSubTypeApplication nvarchar(25)='Application',
			@CreationTypeSystem varchar(20) = 'System',@DocStatePosted nvarchar(20)='Posted'
	-- For Customer Balance Updation
	Declare @EntityId UniqueIdentifier
	Declare @OutStandingExRate Table(DocumentId UniqueIdentifier, ExchangeRate Decimal(15,10),CompanyId BigInt, DocType Nvarchar(50),DocNature nvarchar(10),OutDetailId UniqueIdentifier, ServiceEntityId BigInt)
	Declare @InvalidDocumentError Nvarchar(200)='Invalid Document'
	Declare @ICAccount Table(CompanyId BigInt, ServiceCompanyId BigInt,COAId BigInt, Name Nvarchar(30))
	Declare @SerEntityTemp Table(Id Int identity(1,1), ServiceEntityId BigInt)
	Declare @IsInterCoActivate bit=0,
			@DocCurrency Nvarchar(10),
			@GSTCurrency Nvarchar(10),
			@GSTExchangeRate decimal(15,10),
			@IsGSTActivate Bit,
			@BaseCurrency Nvarchar(10),
			@OutServiceEntityId BigInt,
			@OutStandingSum Money,
			@DDProvisionCOAId BigInt,
			@RecOrder int,
			@IsMultiCureencyActivate bit=0

			Declare @Roundcount int=0
			Declare @RoundReccount int=0
			Declare @countcoma int=0
			--Declare @Reccountcoma int=0
			Declare @Docid uniqueIdentifier
			Declare @Amount Money
			Declare @KeyPairValue nvarchar(500)
			Declare @KeyPairValueRecCount Int
			Declare @KeyPair Nvarchar(Max)
			Declare @ServiceEntityShortName Nvarchar(20), @CNServiceEntityId BigInt

	Declare @RoundingTable Table (DetailDocId uniqueIdentifier, DiffAmount money)
	Declare @tempTable Table(id int identity(1,1), stringVal nvarchar(300))

	
	Begin Try
	Begin Transaction
		If(@DocType<>@DebtProvisionDocument)
		Begin
			If Not Exists((select ID from Bean.CreditNoteApplication where Id=@DocumentId and InvoiceId=@MasterId)) and  Not Exists(select Id from Bean.CreditMemoApplication where Id=@DocumentId and CreditMemoId=@MasterId)
			Begin
				RAISERROR(@InvalidDocumentError,16,1)
			End
		End	
		
		If Exists(Select Id from Bean.Journal where CompanyId=@CompanyId and DocumentId=@DocumentId)
		Begin
			Delete from Bean.JournalDetail where DocumentId=@DocumentId and DocType=@DocType
			Delete from Bean.Journal where DocumentId=@DocumentId and CompanyId=@CompanyId
		End
		If(@DocType=@CreditNoteDocument)
		Begin
			
			Select @ServiceEntityId=ServiceCompanyId,@ExchangeRate=ExchangeRate,@Nature=Nature,@DocCurrency=DocCurrency,@GSTCurrency=GSTExCurrency,@GSTExchangeRate=@GSTExchangeRate,@EntityId=EntityId,@IsGSTActivate=IsGstSettings,@BaseCurrency=ExCurrency from Bean.Invoice where CompanyId=@CompanyId and DocType=@DocType and Id=@MasterId

			If(@Nature='Interco')
			Begin
				--Set @EntityId=(Select EntityId From Bean.Invoice Where Id=@MasterId)
					Set @CNServiceEntityId=(Select ServiceEntityId from Bean.Entity where id=@EntityId and CompanyId=@CompanyId)
					Set @ServiceEntityShortName= (select ShortName from Common.Company where Id=@CNServiceEntityId)
			End 

			-- Inserting Records Into Journal From Invoce 
			Set @JournalId = NEWID()
			Insert Into Bean.Journal (Id,CompanyId,DocDate,DocType,DocSubType,DocNo,ServiceCompanyId,SystemReferenceNo,IsNoSupportingDocs,NoSupportingDocument,DocCurrency,ExchangeRate,ExCurrency,GSTExchangeRate,GSTExCurrency,GSTTotalAmount,DocumentState,IsNoSupportingDocument,IsGstSettings,IsMultiCurrency,IsAllowableNonAllowable,Remarks,UserCreated,CreatedDate,ModifiedBy,ModifiedDate,Status,DocumentDescription,CreationType,GrandDocCreditTotal,GrandBaseCreditTotal,DueDate,EntityId,EntityType,PoNo,PostingDate,IsGSTApplied,COAId,DocumentId,CreditTermsId,Nature,BalanceAmount,ActualSysRefNo,RefNo,IsSegmentReporting)
			Select @JournalId,Inv.CompanyId,CNA.CreditNoteApplicationDate,@DocType,@DocSubTypeApplication,DocNo,ServiceCompanyId,CNA.CreditNoteApplicationNumber As SystemRefNo, CNA.IsNoSupportingDocument, NoSupportingDocs, DocCurrency,Inv.ExchangeRate,ExCurrency, GSTExchangeRate,GSTExCurrency,Isnull(GSTTotalAmount,0),@DocStatePosted,CNA.IsNoSupportingDocument,IsGstSettings,IsMultiCurrency,IsAllowableNonAllowable,CNA.Remarks,CNA.UserCreated,CNA.CreatedDate,CNA.ModifiedBy,CNA.ModifiedDate,CNA.Status,CNA.Remarks,@CreationTypeSystem,Round(CNA.CreditAmount,2) As GrandDocCreditTotal,Round((CNA.CreditAmount*Isnull(Inv.ExchangeRate,1)),2) As GrandBaseCreditTotal,CNA.CreditNoteApplicationDate,EntityId,EntityType,PONo,CNA.CreditNoteApplicationDate As PostingDate,IsGSTApplied,
			 Case 
				 when Nature=@NatureTrade Then (Select Id From Bean.ChartOfAccount Where CompanyId=@CompanyId And Name=@COATradeReceivables)
				 when Nature=@NatureOthers Then (Select Id From Bean.ChartOfAccount Where CompanyId=@CompanyId And Name=@COAotherReceivables)
				 When Nature=@NatureInterco Then (Select Id From Bean.ChartOfAccount Where CompanyId=@CompanyId and SubsidaryCompanyId=@CNServiceEntityId and Name=Concat('I/B - ',@ServiceEntityShortName))
				  End As COAId,
				CNA.Id As Documentid,CreditTermsId,Nature,BalanceAmount,DocNo As ActualSysRefNo,Null,ISNULL(IsSegmentReporting,0)
				From Bean.CreditNoteApplication CNA
				join Bean.Invoice Inv on Inv.Id=CNA.InvoiceId 
				 Where CNA.Id=@DocumentId



			If(@IsOffset=0 and @IsreverseExcess=0)
			Begin
				Insert Into @OutStandingExRate (CompanyId,DocumentId,DocType,ExchangeRate,DocNature,OutDetailId,ServiceEntityId)
				Select CNA.CompanyId,CNAD.DocumentId,Inv.DocType,Inv.ExchangeRate,Inv.Nature,CNAD.Id,Inv.ServiceCompanyId
				From Bean.CreditNoteApplication CNA
				join Bean.CreditNoteApplicationDetail CNAD ON CNA.Id=CNAD.CreditNoteApplicationId
				join Bean.Invoice Inv on Inv.Id=CNAD.DocumentId and CNAD.DocumentType=@InvoiceDocument
				where CNA.CompanyId=@CompanyId and CNA.Id=@DocumentId and CNAD.CreditAmount>0

				Insert Into @OutStandingExRate (CompanyId,DocumentId,DocType,ExchangeRate,DocNature,OutDetailId,ServiceEntityId)
				Select CNA.CompanyId,CNAD.DocumentId,DN.DocSubType,DN.ExchangeRate,DN.Nature,CNAD.Id,DN.ServiceCompanyId
				 From Bean.CreditNoteApplication CNA
				join Bean.CreditNoteApplicationDetail CNAD ON CNA.Id=CNAD.CreditNoteApplicationId
				join Bean.DebitNote DN on DN.Id=CNAD.DocumentId and CNAD.DocumentType=@DebitNoteDocument
				where CNA.CompanyId=@CompanyId and CNA.Id=@DocumentId and CNAD.CreditAmount>0

				If((select COUNT(ServiceEntityId) from Bean.CreditNoteApplicationDetail where CreditNoteApplicationId=@DocumentId and CreditAmount>0 and ServiceEntityId<>@ServiceEntityId)>1)
				Begin
					Set @IsInterCoActivate=1
					Insert Into @ICAccount(CompanyId,ServiceCompanyId,COAId,Name)
					select COA.CompanyId,COA.SubsidaryCompanyId,COA.Id,COA.Name
					from Bean.ChartOfAccount COA
					join Bean.AccountType Acc on COA.AccountTypeId=Acc.Id
					where Acc.CompanyId=@CompanyId and Acc.Name='Intercompany Clearing'
					and SubsidaryCompanyId in (Select ServiceEntityId from Bean.CreditNoteApplicationDetail where CreditNoteApplicationId = @DocumentId and CreditAmount>0)
				End
			End

			-- Inserting Records Into JournalDetail From CreditNoteApplicationDetail
				Insert Into @Temp
				Select Id From Bean.CreditNoteApplicationDetail Where CreditNoteApplicationId=@DocumentId and CreditAmount>0 Order By RecOrder
				Select @RecCount=Count(*) From @Temp
				Set @Count=1

				While @RecCount>=@Count
				Begin
					Set @DetailId=(Select DetailId From @Temp Where Id=@Count)
						--Set @RecOrder=1
					
					Insert Into Bean.JournalDetail (Id,JournalId,COAId,AccountDescription,TaxId,TaxRate,DocDebit,DocCredit,DocTaxCredit,DocTaxDebit,BaseDebit,BaseCredit,DocDebitTotal,DocCreditTotal,BaseDebitTotal,BaseCreditTotal,DocTaxAmount,BaseTaxAmount,BaseTaxDebit,BaseTaxCredit,DocumentId,DocumentDetailId,BaseCurrency,ExchangeRate,GSTExCurrency,GSTExchangeRate,DocType,DocSubType,ServiceCompanyId,DocNo,Nature,OffsetDocument,IsTax,EntityId,SystemRefNo,Remarks,PONo,CreditTermsId,DocCurrency,DocDate,DocDescription,PostingDate,RecOrder,GSTCredit,GSTTaxCredit)

					Select NEWID(),@JournalId,
					Case 
					When (@IsOffset=1 OR @IsreverseExcess=1) Then CNAD.COAId 
					Else
						Case 
						When @ServiceEntityId<> CNAD.ServiceEntityId  Then (select IC.COAId from @ICAccount IC where CompanyId=@CompanyId and	ServiceCompanyId=CNAD.ServiceEntityId)
						Else
							Case 
								when (Select DocNature from @OutStandingExRate ER where ER.DocumentId=CNAD.DocumentId and ER.DocType=CNAD.DocumentType)=@NatureTrade
										Then(Select Id From Bean.ChartOfAccount Where CompanyId=@CompanyId And Name=@COATradeReceivables)
								when (Select DocNature from @OutStandingExRate ER where ER.DocumentId=CNAD.DocumentId and ER.DocType=CNAD.DocumentType)=@NatureOthers    Then (Select Id From Bean.ChartOfAccount Where CompanyId=@CompanyId And Name=@COAotherReceivables)
							End 
						END
					End As COAId,
					CNA.Remarks As AccountDescription, CNAD.TaxId,CNAD.TaxRate,


					 null  As DocDebit,
					 CNAD.CreditAmount As DocCredit,
					  null as DocTaxCredit,
					 Case When CNAD.TaxAmount > 0 Then CNAD.TaxAmount Else null End As DocTaxDebit,
					  null  As BaseDebit,
					 Case When  @IsreverseExcess=1 Then ROUND(CNAD.CreditAmount*@ExchangeRate,2) 
					 When (@IsreverseExcess=0 and @IsOffset=0 and CNAD.ServiceEntityId=@ServiceEntityId) Then ROUND(CNAD.CreditAmount*(Select ER.ExchangeRate from @OutStandingExRate ER where DocumentId=CNAD.DocumentId and DocType=CNAD.DocumentType),2) 
					 When @IsOffset=1 Then ROUND(CNAD.CreditAmount*BaseCurrencyExchangeRate,2)
					 When (@IsreverseExcess=0 and @IsOffset=0 and CNAD.ServiceEntityId<>@ServiceEntityId) Then ROUND(CNAD.CreditAmount*@ExchangeRate,2)
					 End as BaseCredit,
					  0  as DocDebitTotal,
					 Case When CNAD.CreditAmount < 0 Then ABS(CNAD.CreditAmount) Else 0 End as DocCreditTotal,
					 0,--Case When InvID.BaseTotalAmount > 0 Then InvID.BaseTotalAmount Else null End as BaseDebitTotal,
					 0,--Case When InvID.BaseTotalAmount < 0 Then ABS(InvID.BaseTotalAmount) Else null End as BaseCreditTotal,
					 ABS(CNAD.TaxAmount) As DocTaxAmount,
					 ABS(CNAD.TaxAmount*@ExchangeRate) As BaseTaxAmount,
					 null As BaseTaxDebit,
					 Case When @IsreverseExcess=1 Then ROUND(CNAD.TaxAmount*@ExchangeRate,2) Else null END As BaseTaxCredit,
					 
					@DocumentId,CNAD.Id,@DocCurrency,
					Case When (@IsreverseExcess=1) Then @ExchangeRate
					When @IsOffset=1 Then CNAD.BaseCurrencyExchangeRate
					 When (@IsreverseExcess=0 and @IsOffset=0) Then  (Select ER.ExchangeRate from @OutStandingExRate ER where DocumentId=CNAD.DocumentId and DocType=CNAD.DocumentType) End As ExchangeRate,	@GSTCurrency, @GSTExchangeRate, @DocType,@DocSubTypeApplication,@ServiceEntityId,CNA.CreditNoteApplicationNumber,
					Case When (@IsOffset=1 OR @IsreverseExcess=1) Then @Nature Else (Select DocNature from @OutStandingExRate ER where ER.DocumentId=CNAD.DocumentId and ER.DocType=CNAD.DocumentType) End as Nature,
					Null AsOffsetDocument,0 As IsTax,@EntityId,CNA.CreditNoteApplicationNumber As SystemRefNo,CNA.Remarks,null, null As CreditTermsId,@DocCurrency,CNA.CreditNoteApplicationDate,
					null As DocDescription,CNA.CreditNoteApplicationDate As PostingDate,CNAD.RecOrder As RecOrder,
					Case When @IsreverseExcess=1 Then ROUND(CNAD.TaxAmount*IsNull(@GSTExchangeRate,1),2) Else null END As GSTCredit,
					Case When @IsreverseExcess=1 Then ROUND(CNAD.CreditAmount*IsNull(@GSTExchangeRate,1),2) Else null END As GSTTaxCredit
					From Bean.CreditNoteApplicationDetail As CNAD
					Inner Join Bean.CreditNoteApplication As CNA On CNA.Id=CNAD.CreditNoteApplicationId
					Where CNAD.Id=@DetailId


					-- Inserting Tax Lineitem into journaldetail if it is reverse excess
					If (@IsreverseExcess=1 and Exists(Select B.Id From Bean.CreditNoteApplication As A Inner Join Bean.CreditNoteApplicationDetail As B On A.Id=B.CreditNoteApplicationId Where @IsGSTActivate=1 And B.TaxRate is not null 
						And Convert(nvarchar(20),B.TaxIdCode)<>@NA And B.Id=@DetailId))
					--If Exists (Select B.Id From Bean.Invoice As A Inner Join Bean.InvoiceDetail As B On A.Id=B.InvoiceId Where A.IsGstSettings=1 And B.TaxRate is not null 
					--	And Convert(nvarchar(20),B.TaxIdCode)<>@NA And B.Id=@DetailId)
						Begin
							Set @TaxRecCount=@RecCount+@TaxRecOrder
							Insert Into Bean.JournalDetail (Id,JournalId,COAId,AccountDescription,AllowDisAllow,TaxId,TaxRate,DocDebit,DocCredit,DocTaxDebit,DocTaxCredit,BaseDebit,BaseCredit,DocDebitTotal,DocCreditTotal,BaseDebitTotal,BaseCreditTotal,DocumentId,DocumentDetailId,ItemId,BaseCurrency,ExchangeRate,GSTExCurrency,GSTExchangeRate,DocType,DocSubType,ServiceCompanyId,DocNo,Nature,OffsetDocument,IsTax,EntityId,SystemRefNo,Remarks,PONo,CreditTermsId,NoSupportingDocs,BaseAmount,DocCurrency,DocDate,DocDescription,PostingDate,RecOrder,DocTaxAmount,BaseTaxAmount)
							Select NEWID(),@JournalId,(Select Id From Bean.ChartOfAccount Where CompanyId=@CompanyId And Name=@COATaxPaybleGST) As COAId,CNA.Remarks As AccountDescription,null,CNAD.TaxId,CNAD.TaxRate,
							 null  As DocDebit,
							  CNAD.TaxAmount  As DocCredit,
							'0.00' As DocTaxDebit,
							'0.00' As DocTaxCredit,
							  null  As BaseDebit, 
							  Round(CNAD.TaxAmount*@ExchangeRate,2) As BaseCredit,
							'0.00' As DocDebitTotal,'0.00' As DocCreditTotal,null As BaseDebitTotal,null As BaseCreditTotal,@DocumentId,CNAD.Id,@GUIDZero,@BaseCurrency,@ExchangeRate,@GSTCurrency,@GSTExchangeRate,@DocType,@DocSubTypeApplication,@ServiceEntityId,CNA.CreditNoteApplicationNumber,@Nature,Null As OffsetDocument,1 As IsTax,@EntityId,CNA.CreditNoteApplicationNumber As SystemRefNo,CNA.Remarks,null,Null As CreditTermsId,
							 null,null As BaseAmount,@DocCurrency,CNA.CreditNoteApplicationDate,null As DocDescription,
							CNA.CreditNoteApplicationDate,@TaxRecCount As RecOrder,CNAD.TaxAmount,Round(CNAD.TaxAmount*@ExchangeRate,2)
							From Bean.CreditNoteApplicationDetail As CNAD
							Inner Join Bean.CreditNoteApplication As CNA On CNA.Id=CNAD.CreditNoteApplicationId
							Where CNAD.Id=@DetailId
							Set @TaxRecOrder=@TaxRecOrder+1
						End

						If(@IsreverseExcess=0 and @BaseCurrency<>@DocCurrency and @ServiceEntityId=(Select ServiceEntityId from @OutStandingExRate ER where ER.OutDetailId=@DetailId) and @ExchangeRate<>(Select ExchangeRate from @OutStandingExRate ER where ER.OutDetailId=@DetailId))
						Begin
							Insert Into Bean.JournalDetail (Id,JournalId,COAId,AccountDescription,AllowDisAllow,TaxId,TaxRate,DocDebit,DocCredit,DocTaxDebit,DocTaxCredit,BaseDebit,BaseCredit,DocDebitTotal,DocCreditTotal,BaseDebitTotal,BaseCreditTotal,DocumentId,DocumentDetailId,ItemId,BaseCurrency,ExchangeRate,GSTExCurrency,GSTExchangeRate,DocType,DocSubType,ServiceCompanyId,DocNo,Nature,OffsetDocument,IsTax,EntityId,SystemRefNo,Remarks,PONo,CreditTermsId,NoSupportingDocs,BaseAmount,DocCurrency,DocDate,DocDescription,PostingDate,RecOrder,DocTaxAmount,BaseTaxAmount)
							Select NEWID(),@JournalId,(Select Id From Bean.ChartOfAccount Where CompanyId=@CompanyId And Name=@ExchangeGainLossRealised) As COAId,CNA.Remarks As AccountDescription,null,CNAD.TaxId,CNAD.TaxRate,
							 null  As DocDebit,
							  null  As DocCredit,
							'0.00' As DocTaxDebit,
							'0.00' As DocTaxCredit,
							  Case When @IsOffset=1 and @ExchangeRate<CNAD.BaseCurrencyExchangeRate Then ROUND(CNAD.CreditAmount*(CNAD.BaseCurrencyExchangeRate-@ExchangeRate),2)
							  When @IsOffset=1 and @ExchangeRate<(Select ER.ExchangeRate from @OutStandingExRate ER where ER.DocumentId=CNAD.DocumentId and ER.DocType=CNAD.DocumentType) Then ROUND(CNAD.CreditAmount*((Select ER.ExchangeRate from @OutStandingExRate ER where ER.DocumentId=CNAD.DocumentId and ER.DocType=CNAD.DocumentType)-@ExchangeRate),2) 
							  End  As BaseDebit, 
							  Case When @IsOffset=1 and @ExchangeRate>CNAD.BaseCurrencyExchangeRate Then ROUND(CNAD.CreditAmount*(@ExchangeRate-CNAD.BaseCurrencyExchangeRate),2)
							  When @IsOffset=1 and @ExchangeRate>(Select ER.ExchangeRate from @OutStandingExRate ER where ER.DocumentId=CNAD.DocumentId and ER.DocType=CNAD.DocumentType) Then ROUND(CNAD.CreditAmount*(@ExchangeRate-(Select ER.ExchangeRate from @OutStandingExRate ER where ER.DocumentId=CNAD.DocumentId and ER.DocType=CNAD.DocumentType)),2) 
							  End As BaseCredit,
							'0.00' As DocDebitTotal,'0.00' As DocCreditTotal,null As BaseDebitTotal,null As BaseCreditTotal,@DocumentId,CNAD.Id,@GUIDZero,@BaseCurrency,@ExchangeRate,@GSTCurrency,@GSTExchangeRate,@DocType,@DocSubTypeApplication,@ServiceEntityId,CNA.CreditNoteApplicationNumber,@Nature,Null As OffsetDocument,0 As IsTax,@EntityId,CNA.CreditNoteApplicationNumber As SystemRefNo,CNA.Remarks,null,Null As CreditTermsId,
							 null,null As BaseAmount,@DocCurrency,CNA.CreditNoteApplicationDate,null As DocDescription,
							CNA.CreditNoteApplicationDate,@TaxRecCount As RecOrder,null,null
							From Bean.CreditNoteApplicationDetail As CNAD
							Inner Join Bean.CreditNoteApplication As CNA On CNA.Id=CNAD.CreditNoteApplicationId
							Where CNAD.Id=@DetailId
						End

							Set @Count=@Count+1
				End

					
					Select @MasterBaseAmount=Cast(Sum(ROUND(ABS(CreditAmount)*ISNULL(@ExchangeRate,1),2)+(Round(ABS(Isnull(TaxAmount,0))*ISNULL(@ExchangeRate,1),2)))as money) from Bean.CreditNoteApplicationDetail where CreditNoteApplicationId=@DocumentId
					-- Inserting Master Records Into JournalDetail From CN based on CN Nature 
					Insert Into Bean.JournalDetail(Id,JournalId,COAId,AccountDescription,DocDebit,BaseDebit,DocDebitTotal,BaseDebitTotal,DocumentId,DocumentDetailId,ItemId,DueDate,
						ExchangeRate, GSTExchangeRate, GSTExCurrency, Nature,DocType,DocSubType, ServiceCompanyId,CreditTermsId,DocNo,PostingDate,RecOrder,DocumentAmount,Currency,BaseCurrency,IsTax,EntityId,SystemRefNo, Remarks,PONo,BaseAmount,DocCurrency,DocDate,DocDescription,DocCreditTotal)

					Select NewId(),@JournalId,
					Case when @Nature=@NatureTrade Then (Select Id From Bean.ChartOfAccount Where CompanyId=@CompanyId And Name=@COATradeReceivables)
					when @Nature=@NatureOthers Then (Select Id From Bean.ChartOfAccount Where CompanyId=@CompanyId And Name=@COAotherReceivables) 
					When @Nature=@NatureInterco Then (Select Id From Bean.ChartOfAccount Where CompanyId=@CompanyId and SubsidaryCompanyId=@CNServiceEntityId and Name=Concat('I/B - ',@ServiceEntityShortName))
					End As COAId,Remarks,Round(CreditAmount,2),/*Round((GrandTotal*Isnull(ExchangeRate,1)),2)*/@MasterBaseAmount,Round(CreditAmount,2),/*Round	((GrandTotal*Isnull(ExchangeRate,1)),2)*/@MasterBaseAmount As BaseDebitTotal,@DocumentId,@GUIDZero,@GUIDZero,CreditNoteApplicationDate,ExchangeRate,@GSTExchangeRate,@GSTCurrency,@Nature,@DocType,@DocSubTypeApplication,@ServiceEntityId,null, CreditNoteApplicationNumber, CreditNoteApplicationDate,(Select Max   (Recorder)+1 From Bean.JournalDetail Where DocumentId=@DocumentId),Round(CreditAmount,2),
							@DocCurrency,@BaseCurrency,0,@EntityId,CreditNoteApplicationNumber,Remarks,null,/*Round(GrandTotal*Isnull(ExchangeRate,1),2)*/ @MasterBaseAmount,@DocCurrency,CreditNoteApplicationDate,Remarks,'0.00'
					From Bean.CreditNoteApplication Where Id=@DocumentId


					If((select ABS(SUM(BaseDebit)-SUM(BaseCredit)) from Bean.JournalDetail where DocumentId=@DocumentId group by DocType)>=0.01)
					Begin
						Select @BaseDebit=SUM(BaseDebit),@BaseCredit=SUM(BaseCredit),@DiffAmount=ABS(SUM(BaseDebit)-SUM(BaseCredit)) from Bean.JournalDetail where	DocumentId=@DocumentId
						
						Insert Into Bean.JournalDetail	(Id,JournalId,COAId,AccountDescription,BaseDebit,BaseCredit,DocumentId,DocumentDetailId,ItemId,DocDate,DueDate,PostingDate,ExchangeRate,GSTExchangeRate,GSTExCurrency,Nature,DocType,DocSubType,ServiceCompanyId, CreditTermsId, DocNo, Currency, BaseCurrency, IsTax, EntityId,	  SystemRefNo,  DocCurrency, RecOrder,DocDebitTotal,DocCreditTotal)
						select NEWID(), @JournalId, (Select Id from Bean.ChartOfAccount where CompanyId=@CompanyId and Name=@Rounding), Remarks, Case When	@BaseDebit>@BaseCredit Then null Else @DiffAmount End as BaseDebit, Case When @BaseCredit>@BaseDebit Then null Else @DiffAmount END as	  BaseCredit, @DocumentId,NEWID  (),@GUIDZero,CreditNoteApplicationDate,CreditNoteApplicationDate,CreditNoteApplicationDate,@ExchangeRate,@GSTExchangeRate,@GSTCurrency,@Nature,@DocType,@DocSubTypeApplication,@ServiceEntityId,null,CreditNoteApplicationNumber, @DocCurrency, @BaseCurrency, 0, @EntityId,CreditNoteApplicationNumber, @DocCurrency, (Select Max(Recorder)+1 From Bean.JournalDetail Where	   DocumentId=@DocumentId),0,0
						from Bean.CreditNoteApplication where CompanyId=@CompanyId and Id=@DocumentId
					End

				If(@IsInterCoActivate=1 and @IsreverseExcess<>1)--If Inter company Is Activate
				Begin
					
					
					Insert Into @SerEntityTemp 
					Select Distinct ServiceEntityId From Bean.CreditNoteApplicationDetail Where CreditNoteApplicationId=@DocumentId and CreditAmount>0 and ServiceEntityId<>@ServiceEntityId 
					Select @RecCount=Count(*) From @Temp
					Set @Count=1
					While(@RecCount>=@Count)
					Begin
						set @JournalId=NEWID()
						Set @OutServiceEntityId=(Select ServiceEntityId From @SerEntityTemp Where Id=@Count)

						Set @OutStandingSum=(Select SUM(CreditAmount) from Bean.CreditNoteApplicationDetail where CreditNoteApplicationId=@DocumentId and ServiceEntityId=@ServiceEntityId group by ServiceEntityId)
						Insert Into Bean.Journal (Id,CompanyId,DocDate,DocType,DocSubType,DocNo,ServiceCompanyId,SystemReferenceNo,IsNoSupportingDocs,NoSupportingDocument,DocCurrency,ExchangeRate,ExCurrency,GSTExchangeRate,GSTExCurrency,GSTTotalAmount,DocumentState,IsNoSupportingDocument,IsGstSettings,IsMultiCurrency,IsAllowableNonAllowable,Remarks,UserCreated,CreatedDate,ModifiedBy,ModifiedDate,Status,DocumentDescription,CreationType,GrandDocCreditTotal,GrandBaseCreditTotal,DueDate,EntityId,EntityType,PoNo,PostingDate,IsGSTApplied,COAId,DocumentId,CreditTermsId,Nature,BalanceAmount,ActualSysRefNo,RefNo,IsSegmentReporting)
						Select @JournalId,Inv.CompanyId,CNA.CreditNoteApplicationDate,@DocType,@DocSubTypeApplication,CNA.CreditNoteApplicationNumber,@OutServiceEntityId,CNA.CreditNoteApplicationNumber As SystemRefNo, CNA.IsNoSupportingDocument, NoSupportingDocs, DocCurrency,Inv.ExchangeRate,ExCurrency, GSTExchangeRate,GSTExCurrency,Isnull(GSTTotalAmount,0),@DocStatePosted,CNA.IsNoSupportingDocument,IsGstSettings,IsMultiCurrency,IsAllowableNonAllowable,CNA.Remarks,CNA.UserCreated,CNA.CreatedDate,CNA.ModifiedBy,CNA.ModifiedDate,CNA.Status,CNA.Remarks,@CreationTypeSystem,Round(CNA.CreditAmount,2) As GrandDocCreditTotal,Round((CNA.CreditAmount*Isnull(Inv.ExchangeRate,1)),2) As GrandBaseCreditTotal,CNA.CreditNoteApplicationDate,EntityId,EntityType,PONo,CNA.CreditNoteApplicationDate As PostingDate,IsGSTApplied,
					(Select COAId From @ICAccount Where CompanyId=@CompanyId And ServiceCompanyId=@ServiceEntityId) As COAId,
					CNA.Id As Documentid,Inv.CreditTermsId,Nature,BalanceAmount,CNA.CreditNoteApplicationNumber As ActualSysRefNo,Null,ISNULL(IsSegmentReporting,0)
					From Bean.CreditNoteApplication CNA
					join Bean.Invoice Inv on Inv.Id=CNA.InvoiceId 
				 Where CNA.Id=@DocumentId
						
						



						--Set @RecOrder=1
					
						Insert Into Bean.JournalDetail (Id,JournalId,COAId,AccountDescription,TaxId,TaxRate,DocDebit,DocCredit,DocTaxCredit,DocTaxDebit,BaseDebit,BaseCredit,DocDebitTotal,DocCreditTotal,BaseDebitTotal,BaseCreditTotal,DocTaxAmount,BaseTaxAmount,BaseTaxDebit,BaseTaxCredit,DocumentId,DocumentDetailId,BaseCurrency,ExchangeRate,GSTExCurrency,GSTExchangeRate,DocType,DocSubType,ServiceCompanyId,DocNo,Nature,OffsetDocument,IsTax,EntityId,SystemRefNo,Remarks,PONo,CreditTermsId,DocCurrency,DocDate,DocDescription,PostingDate,RecOrder)

						Select NEWID(),@JournalId,
							Case 
								when (Select DocNature from @OutStandingExRate ER where ER.DocumentId=CNAD.DocumentId and ER.DocType=CNAD.DocumentType)=@NatureTrade
										Then(Select Id From Bean.ChartOfAccount Where CompanyId=@CompanyId And Name=@COATradeReceivables)
								when (Select DocNature from @OutStandingExRate ER where ER.DocumentId=CNAD.DocumentId and ER.DocType=CNAD.DocumentType)=@NatureOthers    Then (Select Id From Bean.ChartOfAccount Where CompanyId=@CompanyId And Name=@COAotherReceivables)
						End As COAId,
						CNA.Remarks As AccountDescription, CNAD.TaxId,CNAD.TaxRate,
						null  As DocDebit,
						CNAD.CreditAmount As DocCredit,
						null as DocTaxCredit,
						Case When CNAD.TaxAmount > 0 Then CNAD.TaxAmount Else null End As DocTaxDebit,
						null  As BaseDebit,
						Case When 
						 (@IsreverseExcess=0 and @IsOffset=0 and CNAD.ServiceEntityId<>@ServiceEntityId) Then ROUND(CNAD.CreditAmount*(Select ER.ExchangeRate from @OutStandingExRate ER where DocumentId=CNAD.DocumentId and DocType=CNAD.DocumentType),2) 
						End as BaseCredit,
						0  as DocDebitTotal,
						Case When CNAD.CreditAmount < 0 Then ABS(CNAD.CreditAmount) Else 0 End as DocCreditTotal,
						0,--Case When InvID.BaseTotalAmount > 0 Then InvID.BaseTotalAmount Else null End as BaseDebitTotal,
						0,--Case When InvID.BaseTotalAmount < 0 Then ABS(InvID.BaseTotalAmount) Else null End as BaseCreditTotal,
						ABS(CNAD.TaxAmount) As DocTaxAmount,
						ABS(CNAD.TaxAmount*@ExchangeRate) As BaseTaxAmount,
						null As BaseTaxDebit,
						Case When @IsreverseExcess=1 Then ROUND(CNAD.TaxAmount*@ExchangeRate,2) Else null END As BaseTaxCredit,
					 
						@DocumentId,CNAD.Id,@DocCurrency,
						Case When (@IsreverseExcess=1) Then @ExchangeRate
						When @IsOffset=1 Then CNAD.BaseCurrencyExchangeRate
						When (@IsreverseExcess=0 and @IsOffset=0) Then  (Select ER.ExchangeRate from @OutStandingExRate ER where DocumentId=CNAD.DocumentId and DocType=CNAD.DocumentType) End As ExchangeRate,	@GSTCurrency, @GSTExchangeRate, @DocType,@DocSubTypeApplication,@OutServiceEntityId,CNA.CreditNoteApplicationNumber,
						Case When (@IsOffset=1 OR @IsreverseExcess=1) Then @Nature Else (Select DocNature from @OutStandingExRate ER where ER.DocumentId=CNAD.DocumentId and ER.DocType=CNAD.DocumentType) End as Nature,
						Null AsOffsetDocument,0 As IsTax,@EntityId,CNA.CreditNoteApplicationNumber As SystemRefNo,CNA.Remarks,null, null As CreditTermsId,@DocCurrency,CNA.CreditNoteApplicationDate,
						null As DocDescription,CNA.CreditNoteApplicationDate As PostingDate,CNAD.RecOrder As RecOrder
						From Bean.CreditNoteApplicationDetail As CNAD
						Inner Join Bean.CreditNoteApplication As CNA On CNA.Id=CNAD.CreditNoteApplicationId
						Where CNAD.ServiceEntityId=@OutServiceEntityId and CNAD.CreditNoteApplicationId=@DocumentId

						If(@IsreverseExcess=0 and @BaseCurrency<>@DocCurrency and @ExchangeRate<>(Select ExchangeRate from @OutStandingExRate ER where ER.ServiceEntityId=@ServiceEntityId))
						Begin
							Insert Into Bean.JournalDetail (Id,JournalId,COAId,AccountDescription,AllowDisAllow,TaxId,TaxRate,DocDebit,DocCredit,DocTaxDebit,DocTaxCredit,BaseDebit,BaseCredit,DocDebitTotal,DocCreditTotal,BaseDebitTotal,BaseCreditTotal,DocumentId,DocumentDetailId,ItemId,BaseCurrency,ExchangeRate,GSTExCurrency,GSTExchangeRate,DocType,DocSubType,ServiceCompanyId,DocNo,Nature,OffsetDocument,IsTax,EntityId,SystemRefNo,Remarks,PONo,CreditTermsId,NoSupportingDocs,BaseAmount,DocCurrency,DocDate,DocDescription,PostingDate,RecOrder,DocTaxAmount,BaseTaxAmount)
							Select NEWID(),@JournalId,(Select Id From Bean.ChartOfAccount Where CompanyId=@CompanyId And Name=@ExchangeGainLossRealised) As COAId,CNA.Remarks As AccountDescription,null,CNAD.TaxId,CNAD.TaxRate,
							 null  As DocDebit,
							  null  As DocCredit,
							'0.00' As DocTaxDebit,
							'0.00' As DocTaxCredit,
							  Case 
							  When @IsOffset=0 and @ExchangeRate<(Select ER.ExchangeRate from @OutStandingExRate ER where ER.DocumentId=CNAD.DocumentId and ER.DocType=CNAD.DocumentType) Then ROUND(CNAD.CreditAmount*((Select ER.ExchangeRate from @OutStandingExRate ER where ER.DocumentId=CNAD.DocumentId and ER.DocType=CNAD.DocumentType and CNAD.Id=@DetailId)-@ExchangeRate),2) 
							  End  As BaseDebit, 
							  Case
							  When @IsOffset=0 and @ExchangeRate>(Select ER.ExchangeRate from @OutStandingExRate ER where ER.DocumentId=CNAD.DocumentId and ER.DocType=CNAD.DocumentType) Then ROUND(CNAD.CreditAmount*(@ExchangeRate-(Select ER.ExchangeRate from @OutStandingExRate ER where ER.DocumentId=CNAD.DocumentId and ER.DocType=CNAD.DocumentType and CNAD.Id=@DetailId)),2) 
							  End As BaseCredit,
							'0.00' As DocDebitTotal,'0.00' As DocCreditTotal,null As BaseDebitTotal,null As BaseCreditTotal,@DocumentId,CNAD.Id,@GUIDZero,@BaseCurrency,@ExchangeRate,@GSTCurrency,@GSTExchangeRate,@DocType,@DocSubTypeApplication,@OutServiceEntityId,CNA.CreditNoteApplicationNumber,@Nature,Null As OffsetDocument,0 As IsTax,@EntityId,CNA.CreditNoteApplicationNumber As SystemRefNo,CNA.Remarks,null,Null As CreditTermsId,
							 null,null As BaseAmount,@DocCurrency,CNA.CreditNoteApplicationDate,null As DocDescription,
							CNA.CreditNoteApplicationDate,@TaxRecCount As RecOrder,null,null
							From Bean.CreditNoteApplicationDetail As CNAD
							Inner Join Bean.CreditNoteApplication As CNA On CNA.Id=CNAD.CreditNoteApplicationId
							Where CNAD.ServiceEntityId=@OutServiceEntityId and CNAD.CreditNoteApplicationId=@DocumentId
						End


						-- Inserting Master Records Into JournalDetail From CN based on CN Nature 
					Insert Into Bean.JournalDetail(Id,JournalId,COAId,AccountDescription,DocDebit,BaseDebit,DocDebitTotal,BaseDebitTotal,DocumentId,DocumentDetailId,ItemId,DueDate,
						ExchangeRate, GSTExchangeRate, GSTExCurrency, Nature,DocType,DocSubType, ServiceCompanyId,CreditTermsId,DocNo,PostingDate,RecOrder,DocumentAmount,Currency,BaseCurrency,IsTax,EntityId,SystemRefNo, Remarks,PONo,BaseAmount,DocCurrency,DocDate,DocDescription,DocCreditTotal)

					Select NewId(),@JournalId,
					 (Select COAId From @ICAccount Where CompanyId=@CompanyId And ServiceCompanyId=@ServiceEntityId)
					 As COAId,
							Remarks,Round(@OutStandingSum,2),Round((@OutStandingSum*Isnull(@ExchangeRate,1)),2),Round(@OutStandingSum,2),Round((@OutStandingSum*Isnull(@ExchangeRate,1)),2) As BaseDebitTotal,@DocumentId,@GUIDZero,@GUIDZero,
							CreditNoteApplicationDate,ExchangeRate,@GSTExchangeRate,@GSTCurrency,@Nature,@DocType,@DocSubTypeApplication,@OutServiceEntityId,null, CreditNoteApplicationNumber, CreditNoteApplicationDate,(Select Max   (Recorder)+1 From Bean.JournalDetail Where DocumentId=@DocumentId),Round(@OutStandingSum,2),
							@DocCurrency,@BaseCurrency,0,@EntityId,CreditNoteApplicationNumber,Remarks,null,Round((@OutStandingSum*Isnull(@ExchangeRate,1)),2),@DocCurrency,CreditNoteApplicationDate,Remarks,'0.00'
					From Bean.CreditNoteApplication Where Id=@DocumentId


					If((select ABS(SUM(BaseDebit)-SUM(BaseCredit)) from Bean.JournalDetail where DocumentId=@DocumentId group by DocType)>=0.01)
					Begin
						Select @BaseDebit=SUM(BaseDebit),@BaseCredit=SUM(BaseCredit),@DiffAmount=ABS(SUM(BaseDebit)-SUM(BaseCredit)) from Bean.JournalDetail where	DocumentId=@DocumentId
						
						Insert Into Bean.JournalDetail	(Id,JournalId,COAId,AccountDescription,BaseDebit,BaseCredit,DocumentId,DocumentDetailId,ItemId,DocDate,DueDate,PostingDate,ExchangeRate,GSTExchangeRate,GSTExCurrency,Nature,DocType,DocSubType,ServiceCompanyId, CreditTermsId, DocNo, Currency, BaseCurrency, IsTax, EntityId,	  SystemRefNo,  DocCurrency, RecOrder,DocDebitTotal,DocCreditTotal)
						select NEWID(), @JournalId, (Select Id from Bean.ChartOfAccount where CompanyId=@CompanyId and Name=@Rounding), Remarks, Case When	@BaseDebit>@BaseCredit Then null Else @DiffAmount End as BaseDebit, Case When @BaseCredit>@BaseDebit Then null Else @DiffAmount END as	  BaseCredit, @DocumentId,NEWID  (),@GUIDZero,CreditNoteApplicationDate,CreditNoteApplicationDate,CreditNoteApplicationDate,@ExchangeRate,@GSTExchangeRate,@GSTCurrency,@Nature,@DocType,@DocSubType,@OutServiceEntityId,null,CreditNoteApplicationNumber, @DocCurrency, @BaseCurrency, 0, @EntityId,CreditNoteApplicationNumber, @DocCurrency, (Select Max(Recorder)+1 From Bean.JournalDetail Where	   DocumentId=@DocumentId),0,0
						from Bean.CreditNoteApplication where CompanyId=@CompanyId and Id=@DocumentId
					End

					Set @Count=@Count+1

					End
				End
				

	End
		
		Else If(@DocType=@CreditMemoDocument)
		Begin

			If (@RoundingAmount is not null and @RoundingAmount <>'')
			Begin
		
				set @RoundingAmount=Replace(@RoundingAmount,'[','')
				Set @RoundingAmount=Replace(@RoundingAmount,']','')

				Insert Into @tempTable
				Select items From SplitToTable (@RoundingAmount,':')
				Set @Roundcount=(Select Count(*) From @tempTable)
				Set @RoundReccount=1
				While @Roundcount>=@RoundReccount
				Begin
				Set @KeyPairValueRecCount=0
				Set @KeyPair=(Select cast(stringVal As nvarchar(Max))  From @tempTable WHere Id=@RoundReccount)
				Declare KeyValueCSR Cursor  For
				Select items From SplitToTable(@KeyPair,',')
				Open KeyValueCSR
				Fetch Next from KeyValueCSR into @KeyPairValue
				While @@FETCH_STATUS=0
				Begin
					Set @KeyPairValueRecCount=@KeyPairValueRecCount+1
					--Print @KeyPairValue
					IF @KeyPairValueRecCount=1
					Begin
						Set @Docid=@KeyPairValue
					End
					Else
					Begin
						Set @Amount=Cast(@KeyPairValue As money)
						Insert Into @RoundingTable
						Select @Docid,@Amount
					End
					Fetch Next from KeyValueCSR into @KeyPairValue
				End
					Close KeyValueCSR
					Deallocate KeyValueCSR
					Set @RoundReccount=@RoundReccount+1
				End
			END

			
			Select @ServiceEntityId=ServiceCompanyId,@ExchangeRate=ExchangeRate,@Nature=Nature,@DocCurrency=DocCurrency,@GSTCurrency=GSTExCurrency,@GSTExchangeRate=GSTExchangeRate,@EntityId=EntityId,@IsGSTActivate=IsGstSettings,@BaseCurrency=ExCurrency from Bean.CreditMemo where CompanyId=@CompanyId and DocType=@DocType and Id=@MasterId

			If(@Nature='Interco')
			Begin
				--Set @EntityId=(Select EntityId From Bean.CreditMemo Where Id=@MasterId)
					Set @CNServiceEntityId=(Select ServiceEntityId from Bean.Entity where id=@EntityId and CompanyId=@CompanyId)
					Set @ServiceEntityShortName= (select ShortName from Common.Company where Id=@CNServiceEntityId)
			End 

			If(@BaseCurrency<>@DocCurrency)
			Begin
				Set @IsMultiCureencyActivate=1
			End

			-- Inserting Records Into Journal From Invoce 
			Set @JournalId = NEWID()
			Insert Into Bean.Journal (Id,CompanyId,DocDate,DocType,DocSubType,DocNo,ServiceCompanyId,SystemReferenceNo,IsNoSupportingDocs,NoSupportingDocument,DocCurrency,ExchangeRate,ExCurrency,GSTExchangeRate,GSTExCurrency,GSTTotalAmount,DocumentState,IsNoSupportingDocument,IsGstSettings,IsMultiCurrency,IsAllowableNonAllowable,Remarks,UserCreated,CreatedDate,ModifiedBy,ModifiedDate,Status,DocumentDescription,CreationType,GrandDocCreditTotal,GrandBaseCreditTotal,DueDate,EntityId,EntityType,PoNo,PostingDate,IsGSTApplied,COAId,DocumentId,CreditTermsId,Nature,BalanceAmount,ActualSysRefNo,RefNo,IsSegmentReporting)
			Select @JournalId,CM.CompanyId,CMA.CreditMemoApplicationDate,@DocType,@DocSubTypeApplication,CMA.CreditMemoApplicationNumber,ServiceCompanyId,CMA.CreditMemoApplicationNumber As SystemRefNo, CMA.IsNoSupportingDocument, NoSupportingDocs, DocCurrency,CM.ExchangeRate,ExCurrency, GSTExchangeRate,GSTExCurrency,Isnull(GSTTotalAmount,0),@DocStatePosted,CMA.IsNoSupportingDocument,IsGstSettings,IsMultiCurrency,IsAllowableNonAllowable,CMA.Remarks,CMA.UserCreated,CMA.CreatedDate,CMA.ModifiedBy,CMA.ModifiedDate,CMA.Status,CMA.Remarks,@CreationTypeSystem,Round(CMA.CreditAmount,2) As GrandDocCreditTotal,Round((CMA.CreditAmount*Isnull(CM.ExchangeRate,1)),2) As GrandBaseCreditTotal,CMA.CreditMemoApplicationDate,EntityId,EntityType,PONo,CMA.CreditMemoApplicationDate As PostingDate,IsGSTApplied,
			 Case 
				 when Nature=@NatureTrade Then (Select Id From Bean.ChartOfAccount Where CompanyId=@CompanyId And Name=@COATradePayables)
				 when Nature=@NatureOthers Then (Select Id From Bean.ChartOfAccount Where CompanyId=@CompanyId And Name=@COAOtherPayables)
				 When Nature=@NatureInterco Then (Select Id From Bean.ChartOfAccount Where CompanyId=@CompanyId and SubsidaryCompanyId=@CNServiceEntityId and Name=Concat('I/B - ',@ServiceEntityShortName))
				  End As COAId,
				CMA.Id As Documentid,CreditTermsId,Nature,BalanceAmount,DocNo As ActualSysRefNo,Null,ISNULL(IsSegmentReporting,0)
				From Bean.CreditMemoApplication CMA
				join Bean.CreditMemo CM on CM.Id=CMA.CreditMemoId 
				 Where CMA.Id=@DocumentId



			If(@IsOffset=0 and @IsreverseExcess=0)
			Begin
				Insert Into @OutStandingExRate (CompanyId,DocumentId,DocType,ExchangeRate,DocNature,OutDetailId,ServiceEntityId)
				Select CMA.CompanyId,CMAD.DocumentId,B.DocType,B.ExchangeRate,B.Nature,CMAD.Id,B.ServiceCompanyId
				From Bean.CreditMemoApplication CMA
				join Bean.CreditMemoApplicationDetail CMAD ON CMA.Id=CMAD.CreditMemoApplicationId
				join Bean.Bill B on B.Id=CMAD.DocumentId and CMAD.DocumentType Not In ('Bill Payemnt','Receipt')
				where CMA.CompanyId=@CompanyId and CMA.Id=@DocumentId and CMAD.CreditAmount>0
			End


			Insert Into @Temp
			Select Id From Bean.CreditMemoApplicationDetail Where CreditMemoApplicationId=@DocumentId and CreditAmount>0 Order By RecOrder
			Select @RecCount=Count(*) From @Temp
			Set @Count=1
			Set @RecOrder=1
			While @RecCount>=@Count
			Begin
				Set @DetailId=(Select DetailId From @Temp Where Id=@Count)
				
					
				Insert Into Bean.JournalDetail (Id,JournalId,COAId,AccountDescription,TaxId,TaxRate,DocDebit,DocCredit,DocTaxCredit,DocTaxDebit,BaseDebit,BaseCredit,DocDebitTotal,DocCreditTotal,BaseDebitTotal,BaseCreditTotal,DocTaxAmount,BaseTaxAmount,BaseTaxDebit,BaseTaxCredit,GSTDebit,GSTTaxDebit,DocumentId,DocumentDetailId,BaseCurrency,ExchangeRate,GSTExCurrency,GSTExchangeRate,DocType,DocSubType,ServiceCompanyId,DocNo,Nature,OffsetDocument,IsTax,EntityId,SystemRefNo,Remarks,PONo,CreditTermsId,DocCurrency,DocDate,DocDescription,PostingDate,RecOrder)

				Select NEWID(),@JournalId,
				Case 
				When (@IsOffset=1 OR @IsreverseExcess=1) Then CMAD.COAId 
				Else
					Case 
						when (Select DocNature from @OutStandingExRate ER where ER.DocumentId=CMAD.DocumentId )=@NatureTrade
							Then(Select Id From Bean.ChartOfAccount Where CompanyId=@CompanyId And Name=@COATradePayables)
						when (Select DocNature from @OutStandingExRate ER where ER.DocumentId=CMAD.DocumentId )=@NatureOthers		Then (Select Id From Bean.ChartOfAccount Where CompanyId=@CompanyId And Name=@COAOtherPayables)
						End 
						
				End As COAId,
				CMA.Remarks As AccountDescription, CMAD.TaxId,CMAD.TaxRate,


				CMAD.CreditAmount  As DocDebit,
				null As DocCredit,
				null as DocTaxCredit,
				Case When CMAD.TaxAmount > 0 Then CMAD.TaxAmount Else null End As DocTaxDebit,
				Case When  @IsreverseExcess=1 Then ROUND(CMAD.CreditAmount*@ExchangeRate,2) 
				When (@IsreverseExcess=0 and @IsOffset=0 ) Then  ROUND(CMAD.CreditAmount*(Select ER.ExchangeRate from @OutStandingExRate ER where DocumentId=CMAD.DocumentId ),2)-isnull((select RT.DiffAmount from @RoundingTable RT where RT.DetailDocId=CMAD.DocumentId),0) 
				When @IsOffset=1 Then Case When @IsMultiCureencyActivate=1 Then ROUND(CMAD.CreditAmount*BaseCurrencyExchangeRate,2) Else CMAD.CreditAmount End
				End  As BaseDebit,
				null as BaseCredit,
				Case When CMAD.CreditAmount < 0 Then ABS(CMAD.CreditAmount) Else 0 End  as DocDebitTotal,
				0 as DocCreditTotal,
				0,--Case When InvID.BaseTotalAmount > 0 Then InvID.BaseTotalAmount Else null End as BaseDebitTotal,
				0,--Case When InvID.BaseTotalAmount < 0 Then ABS(InvID.BaseTotalAmount) Else null End as BaseCreditTotal,
				ABS(CMAD.TaxAmount) As DocTaxAmount,
				ABS(CMAD.TaxAmount*@ExchangeRate) As BaseTaxAmount,
				Case When @IsreverseExcess=1 Then ROUND(Isnull(CMAD.TaxAmount,0)*IsNull(@ExchangeRate,1),2) Else null END As BaseTaxDebit,
				null As BaseTaxCredit,
				Case When @IsreverseExcess=1 Then ROUND(CMAD.TaxAmount*IsNull(@GSTExchangeRate,1),2) Else null END As GSTDebit,
				Case When @IsreverseExcess=1 Then ROUND(CMAD.CreditAmount*IsNull(@GSTExchangeRate,1),2) Else null END As GSTTaxDebit,	 
				@DocumentId,CMAD.Id,@BaseCurrency,
				Case When (@IsreverseExcess=1) Then @ExchangeRate
				When @IsOffset=1 Then CMAD.BaseCurrencyExchangeRate
				When (@IsreverseExcess=0 and @IsOffset=0) Then  (Select ER.ExchangeRate from @OutStandingExRate ER where DocumentId=CMAD.DocumentId ) End As ExchangeRate,	@GSTCurrency, @GSTExchangeRate, @DocType,@DocSubTypeApplication,@ServiceEntityId,CMA.CreditMemoApplicationNumber,
				Case When (@IsOffset=1 OR @IsreverseExcess=1) Then @Nature Else (Select DocNature from @OutStandingExRate ER where ER.DocumentId=CMAD.DocumentId ) End as Nature,
				Null AsOffsetDocument,0 As IsTax,@EntityId,CMA.CreditMemoApplicationNumber As SystemRefNo,CMA.Remarks,null, null As CreditTermsId,@DocCurrency,CMA.CreditMemoApplicationDate,
				null As DocDescription,CMA.CreditMemoApplicationDate As PostingDate,@RecOrder As RecOrder
				From Bean.CreditMemoApplicationDetail As CMAD
				Inner Join Bean.CreditMemoApplication As CMA On CMA.Id=CMAD.CreditMemoApplicationId
				Where CMAD.Id=@DetailId

				Set @RecOrder=@RecOrder+1;
					-- Inserting Tax Lineitem into journaldetail if it is reverse excess
					If (@IsOffset=0 and @IsreverseExcess=1 and Exists(Select B.Id From Bean.CreditMemoApplication As A Inner Join Bean.CreditMemoApplicationDetail As B On A.Id=B.CreditMemoApplicationId Where @IsGSTActivate=1 And B.TaxRate is not null 
						And Convert(nvarchar(20),B.TaxIdCode)<>@NA And B.Id=@DetailId ))
					--If Exists (Select B.Id From Bean.Invoice As A Inner Join Bean.InvoiceDetail As B On A.Id=B.InvoiceId Where A.IsGstSettings=1 And B.TaxRate is not null 
					--	And Convert(nvarchar(20),B.TaxIdCode)<>@NA And B.Id=@DetailId)
						Begin
							Set @TaxRecCount=@RecCount+@TaxRecOrder
							Insert Into Bean.JournalDetail (Id,JournalId,COAId,AccountDescription,AllowDisAllow,TaxId,TaxRate,DocDebit,DocCredit,DocTaxDebit,DocTaxCredit,BaseDebit,BaseCredit,DocDebitTotal,DocCreditTotal,BaseDebitTotal,BaseCreditTotal,DocumentId,DocumentDetailId,ItemId,BaseCurrency,ExchangeRate,GSTExCurrency,GSTExchangeRate,DocType,DocSubType,ServiceCompanyId,DocNo,Nature,OffsetDocument,IsTax,EntityId,SystemRefNo,Remarks,PONo,CreditTermsId,NoSupportingDocs,BaseAmount,DocCurrency,DocDate,DocDescription,PostingDate,RecOrder,DocTaxAmount,BaseTaxAmount)
							Select NEWID(),@JournalId,(Select Id From Bean.ChartOfAccount Where CompanyId=@CompanyId And Name=@COATaxPaybleGST) As COAId,CMA.Remarks As AccountDescription,null,CMAD.TaxId,CMAD.TaxRate,
							 CMAD.TaxAmount  As DocDebit,
							  null as DocCredit,
							'0.00' As DocTaxDebit,
							'0.00' As DocTaxCredit,
							  Round(CMAD.TaxAmount*@ExchangeRate,2)  As BaseDebit, 
							  null As BaseCredit,
							'0.00' As DocDebitTotal,'0.00' As DocCreditTotal,null As BaseDebitTotal,null As BaseCreditTotal,@DocumentId,CMAD.Id,@GUIDZero,@BaseCurrency,@ExchangeRate,@GSTCurrency,@GSTExchangeRate,@DocType,@DocSubTypeApplication,@ServiceEntityId,CMA.CreditMemoApplicationNumber,@Nature,Null As OffsetDocument,1 As IsTax,@EntityId,CMA.CreditMemoApplicationNumber As SystemRefNo,CMA.Remarks,null,Null As CreditTermsId,
							 null,null As BaseAmount,@DocCurrency,CMA.CreditMemoApplicationDate,null As DocDescription,
							CMA.CreditMemoApplicationDate,@TaxRecCount As RecOrder,CMAD.TaxAmount,Round(CMAD.TaxAmount*@ExchangeRate,2)
							From Bean.CreditMemoApplicationDetail As CMAD
							Inner Join Bean.CreditMemoApplication As CMA On CMA.Id=CMAD.CreditMemoApplicationId
							Where CMAD.Id=@DetailId
							Set @TaxRecOrder=@TaxRecOrder+1
						End

						If(@IsreverseExcess=0 and @BaseCurrency<>@DocCurrency )
						Begin
							Insert Into Bean.JournalDetail (Id,JournalId,COAId,AccountDescription,AllowDisAllow,TaxId,TaxRate,DocDebit,DocCredit,DocTaxDebit,DocTaxCredit,BaseCredit,BaseDebit,DocDebitTotal,DocCreditTotal,BaseDebitTotal,BaseCreditTotal,DocumentId,DocumentDetailId,ItemId,BaseCurrency,ExchangeRate,GSTExCurrency,GSTExchangeRate,DocType,DocSubType,ServiceCompanyId,DocNo,Nature,OffsetDocument,IsTax,EntityId,SystemRefNo,Remarks,PONo,CreditTermsId,NoSupportingDocs,BaseAmount,DocCurrency,DocDate,DocDescription,PostingDate,RecOrder,DocTaxAmount,BaseTaxAmount)
							Select NEWID(),@JournalId,(Select Id From Bean.ChartOfAccount Where CompanyId=@CompanyId And Name=@ExchangeGainLossRealised) As COAId,CMA.Remarks As AccountDescription,null,CMAD.TaxId,CMAD.TaxRate,
							 null  As DocDebit,
							  null  As DocCredit,
							'0.00' As DocTaxDebit,
							'0.00' As DocTaxCredit,
							  Case When @IsOffset=1 and @ExchangeRate<CMAD.BaseCurrencyExchangeRate Then ROUND(CMAD.CreditAmount*(CMAD.BaseCurrencyExchangeRate-@ExchangeRate),2)
							  When @IsOffset=0 and @ExchangeRate<(Select ER.ExchangeRate from @OutStandingExRate ER where ER.DocumentId=CMAD.DocumentId ) Then ROUND(CMAD.CreditAmount*((Select ER.ExchangeRate from @OutStandingExRate ER where ER.DocumentId=CMAD.DocumentId )-@ExchangeRate),2) 
							  End  As BaseCredit, 
							  Case When @IsOffset=1 and @ExchangeRate>CMAD.BaseCurrencyExchangeRate Then ROUND(CMAD.CreditAmount*(@ExchangeRate-CMAD.BaseCurrencyExchangeRate),2)
							  When @IsOffset=0 and @ExchangeRate>(Select ER.ExchangeRate from @OutStandingExRate ER where ER.DocumentId=CMAD.DocumentId ) Then ROUND(CMAD.CreditAmount*(@ExchangeRate-(Select ER.ExchangeRate from @OutStandingExRate ER where ER.DocumentId=CMAD.DocumentId )),2) 
							  End As BaseDebit,
							'0.00' As DocDebitTotal,'0.00' As DocCreditTotal,null As BaseDebitTotal,null As BaseCreditTotal,@DocumentId,CMAD.Id,@GUIDZero,@BaseCurrency,@ExchangeRate,@GSTCurrency,@GSTExchangeRate,@DocType,@DocSubTypeApplication,@ServiceEntityId,CMA.CreditMemoApplicationNumber,@Nature,Null As OffsetDocument,0 As IsTax,@EntityId,CMA.CreditMemoApplicationNumber As SystemRefNo,CMA.Remarks,null,Null As CreditTermsId,
							 null,null As BaseAmount,@DocCurrency,CMA.CreditMemoApplicationDate,null As DocDescription,
							CMA.CreditMemoApplicationDate,@RecOrder As RecOrder,null,null
							From Bean.CreditMemoApplicationDetail As CMAD
							Inner Join Bean.CreditMemoApplication As CMA On CMA.Id=CMAD.CreditMemoApplicationId
							Where CMAD.Id=@DetailId
							Set @RecOrder=@RecOrder+1;
						End

							Set @Count=@Count+1
				End

					
					Select @MasterBaseAmount=Cast(Sum(ROUND(ABS(CreditAmount)*ISNULL(@ExchangeRate,1),2)+(Round(ABS(Isnull(TaxAmount,0))*ISNULL(@ExchangeRate,1),2)))as money)- Isnull((select RT.DiffAmount from @RoundingTable RT where RT.DetailDocId=@MasterId),0) from Bean.CreditMemoApplicationDetail where CreditMemoApplicationId=@DocumentId
					-- Inserting Master Records Into JournalDetail From CN based on CN Nature 
					Insert Into Bean.JournalDetail(Id,JournalId,COAId,AccountDescription,DocCredit,BaseCredit,DocCreditTotal,BaseCreditTotal,DocumentId,DocumentDetailId,ItemId,DueDate,
						ExchangeRate, GSTExchangeRate, GSTExCurrency, Nature,DocType,DocSubType, ServiceCompanyId,CreditTermsId,DocNo,PostingDate,RecOrder,DocumentAmount,Currency,BaseCurrency,IsTax,EntityId,SystemRefNo, Remarks,PONo,BaseAmount,DocCurrency,DocDate,DocDescription,DocDebitTotal)

					Select NewId(),@JournalId,
					Case when @Nature=@NatureTrade Then (Select Id From Bean.ChartOfAccount Where CompanyId=@CompanyId And Name=@COATradePayables)
					when @Nature=@NatureOthers Then (Select Id From Bean.ChartOfAccount Where CompanyId=@CompanyId And Name=@COAOtherPayables) 
					When @Nature=@NatureInterco Then (Select Id From Bean.ChartOfAccount Where CompanyId=@CompanyId and SubsidaryCompanyId=@CNServiceEntityId and Name=Concat('I/B - ',@ServiceEntityShortName))
					End As COAId,
							Remarks,Round(CreditAmount,2),/*Round((GrandTotal*Isnull(ExchangeRate,1)),2)*/@MasterBaseAmount,Round(CreditAmount,2),/*Round	((GrandTotal*Isnull(ExchangeRate,1)),2)*/@MasterBaseAmount As BaseDebitTotal,@DocumentId,@GUIDZero,@GUIDZero,CreditMemoApplicationDate,ExchangeRate,@GSTExchangeRate,@GSTCurrency,@Nature,@DocType,@DocSubTypeApplication,@ServiceEntityId,null, CreditMemoApplicationDate, CreditMemoApplicationDate,(Select Max   (Recorder)+1 From Bean.JournalDetail Where DocumentId=@DocumentId),Round(CreditAmount,2),
							@DocCurrency,@BaseCurrency,0,@EntityId,CreditMemoApplicationNumber,Remarks,null,/*Round(GrandTotal*Isnull(ExchangeRate,1),2)*/ @MasterBaseAmount,@DocCurrency,CreditMemoApplicationDate,Remarks,'0.00'
					From Bean.CreditMemoApplication Where Id=@DocumentId


					If((select ABS(SUM(BaseDebit)-SUM(BaseCredit)) from Bean.JournalDetail where DocumentId=@DocumentId group by DocType)>=0.01)
					Begin
						Select @BaseDebit=SUM(BaseDebit),@BaseCredit=SUM(BaseCredit),@DiffAmount=ABS(SUM(BaseDebit)-SUM(BaseCredit)) from Bean.JournalDetail where	DocumentId=@DocumentId
						
						Insert Into Bean.JournalDetail	(Id,JournalId,COAId,AccountDescription,BaseDebit,BaseCredit,DocumentId,DocumentDetailId,ItemId,DocDate,DueDate,PostingDate,ExchangeRate,GSTExchangeRate,GSTExCurrency,Nature,DocType,DocSubType,ServiceCompanyId, CreditTermsId, DocNo, Currency, BaseCurrency, IsTax, EntityId,	  SystemRefNo,  DocCurrency, RecOrder,DocDebitTotal,DocCreditTotal)
						select NEWID(), @JournalId, (Select Id from Bean.ChartOfAccount where CompanyId=@CompanyId and Name=@Rounding), Remarks, Case When	@BaseDebit>@BaseCredit Then null Else @DiffAmount End as BaseDebit, Case When @BaseCredit>@BaseDebit Then null Else @DiffAmount END as	  BaseCredit, @DocumentId,NEWID  (),@GUIDZero,CreditMemoApplicationDate,CreditMemoApplicationDate,CreditMemoApplicationDate,@ExchangeRate,@GSTExchangeRate,@GSTCurrency,@Nature,@DocType,@DocSubTypeApplication,@ServiceEntityId,null,CreditMemoApplicationNumber, @DocCurrency, @BaseCurrency, 0, @EntityId,CreditMemoApplicationNumber, @DocCurrency, (Select Max(Recorder)+1 From Bean.JournalDetail Where	   DocumentId=@DocumentId),0,0
						from Bean.CreditMemoApplication where CompanyId=@CompanyId and Id=@DocumentId
					End
		End
		
		Else If(@DocType=@DebtProvisionDocument)
		Begin
			If Not Exists(select * from Bean.DoubtfulDebtAllocation where CompanyId=@CompanyId and IsRevExcess=1 and Id=@DocumentId and InvoiceId=@MasterId)
			Begin
				RAISERROR(@InvalidDocumentError,16,1)
			End
			Select @ServiceEntityId=ServiceCompanyId,@ExchangeRate=ExchangeRate,@Nature=Nature,@DocCurrency=DocCurrency,@GSTCurrency=GSTExCurrency,@GSTExchangeRate=@GSTExchangeRate,@EntityId=EntityId,@IsGSTActivate=IsGstSettings,@BaseCurrency=ExCurrency from Bean.Invoice where CompanyId=@CompanyId and DocType=@DocType and Id=@MasterId

			-- Inserting Records Into Journal From Debit Provision 
				Set @JournalId = NEWID()
				Insert Into Bean.Journal (Id,CompanyId,DocDate,DocType,DocSubType,DocNo,ServiceCompanyId,SystemReferenceNo,IsNoSupportingDocs,NoSupportingDocument,DocCurrency,ExchangeRate,ExCurrency,GSTExchangeRate,GSTExCurrency,GSTTotalAmount,DocumentState,IsNoSupportingDocument,IsGstSettings,IsMultiCurrency,IsAllowableNonAllowable,Remarks,UserCreated,CreatedDate,ModifiedBy,ModifiedDate,Status,DocumentDescription,CreationType,GrandDocCreditTotal,GrandBaseCreditTotal,DueDate,EntityId,EntityType,PoNo,PostingDate,IsGSTApplied,COAId,DocumentId,CreditTermsId,Nature,BalanceAmount,ActualSysRefNo,RefNo,IsSegmentReporting)
				Select @JournalId,Inv.CompanyId,alloc.DoubtfulDebtAllocationDate,@DocType,@DocSubType,alloc.DoubtfulDebtAllocationNumber,ServiceCompanyId,DocNo As SystemRefNo, alloc.IsNoSupportingDocument, NoSupportingDocs, DocCurrency,ExchangeRate,ExCurrency, GSTExchangeRate,GSTExCurrency,Isnull(GSTTotalAmount,0),@DocStatePosted,inv.IsNoSupportingDocument,IsGstSettings,IsMultiCurrency,IsAllowableNonAllowable,alloc.Remarks,alloc.UserCreated,alloc.CreatedDate,alloc.ModifiedBy,alloc.ModifiedDate,alloc.Status,DocDescription,@CreationTypeSystem,Round(alloc.AllocateAmount,2) As GrandDocCreditTotal,Round((alloc.AllocateAmount*Isnull(ExchangeRate,1)),2) As GrandBaseCreditTotal,alloc.DoubtfulDebtAllocationDate,EntityId,EntityType,PONo,alloc.DoubtfulDebtAllocationDate As PostingDate,IsGSTApplied,
				 Case 
				 when Nature=@NatureTrade Then (Select Id From Bean.ChartOfAccount Where CompanyId=@CompanyId And Name=@COADebt_Provision_TR)
				 when Nature=@NatureOthers Then (Select Id From Bean.ChartOfAccount Where CompanyId=@CompanyId And Name=@COADebt_Provision_OR)
				   End As COAId,
				alloc.Id As Documentid,inv.CreditTermsId,Nature,alloc.AllocateAmount,alloc.DoubtfulDebtAllocationNumber As ActualSysRefNo,Null,ISNULL(IsSegmentReporting,0)
				From Bean.Invoice Inv 
				join Bean.DoubtfulDebtAllocation alloc on alloc.InvoiceId=Inv.Id 
				Where alloc.Id=@DocumentId and Inv.DocType=@DebtProvisionDocument and Inv.Id=@MasterId

				-- Inserting Records Into JournalDetail From CreditMemoDetail
					
				Set @Count=1
				Set @RecCount=2
				While @RecCount>=@Count
				Begin
					If @Count=1
					Begin
						Set @DDProvisionCOAId=(Select Id from Bean.ChartOfAccount where CompanyId=@CompanyId and Name=Case When @Nature=@NatureTrade Then	@COADebt_Provision_TR Else @COADebt_Provision_OR End)
					End
					Else
					Begin
						Set @DDProvisionCOAId=(Select Id from Bean.ChartOfAccount where CompanyId=@CompanyId and Name=@COADoubtfulDebtexpense)
					End
						 
						Insert Into Bean.JournalDetail	(Id,JournalId,COAId,AccountDescription,DocDebit,DocCredit,DocTaxCredit,DocTaxDebit,BaseDebit,BaseCredit,DocDebitTotal,DocCreditTotal,BaseDebitTotal,BaseCreditTotal,BaseTaxDebit,BaseTaxCredit,DocumentId,BaseCurrency,ExchangeRate,GSTExCurrency,GSTExchangeRate,DocType,DocSubType,ServiceCompanyId,DocNo,Nature,OffsetDocument,IsTax,EntityId,SystemRefNo,Remarks,PONo,CreditTermsId,DocCurrency,DocDate,DocDescription,PostingDate,RecOrder,DocumentDetailId)

						Select NEWID(),@JournalId,@DDProvisionCOAId  As COAId,DebtProv.Remarks As AccountDescription,
						 Case When @Count=1 Then ROUND(DebtProv.AllocateAmount,2) Else null End As DocDebit,
						 Case When @Count=2 Then ROUND(DebtProv.AllocateAmount,2) Else null End As DocCredit,
						 '0.00' as DocTaxCredit,
						 '0.00' as DocTaxDebit,
						 Case When @Count=1 Then Round((DebtProv.AllocateAmount*Isnull(@ExchangeRate,1)),2) Else null End As BaseDebit,
						 Case When @Count=2 Then Round((DebtProv.AllocateAmount*Isnull(@ExchangeRate,1)),2) Else null End as BaseCredit,
						 '0.00' as DocDebitTotal,
						 '0.00' as DocCreditTotal,
						 '0.00' as BaseDebitTotal,
						 '0.00' as BaseCreditTotal,
						 '0.00' As BaseTaxDebit,
						 '0.00' As BaseTaxCredit,
						@DocumentId,@BaseCurrency,@ExchangeRate,@GSTCurrency, @GSTExchangeRate,	@DocType,@DocSubType,@ServiceEntityId,DebtProv.DoubtfulDebtAllocationNumber,@Nature,Null AsOffsetDocument,0	  AsIsTax,@EntityId,DebtProv.DoubtfulDebtAllocationNumber As SystemRefNo,DebtProv.Remarks,null as PONo,0 As		CreditTermsId,@DocCurrency,DebtProv.DoubtfulDebtAllocationDate,
						null As DocDescription,DebtProv.DoubtfulDebtAllocationDate As PostingDate,@Count As RecOrder,@GUIDZero
						From Bean.DoubtfulDebtAllocation As DebtProv
						Where DebtProv.Id=@DocumentId

						Set @Count=@Count+1
				End

				If((select ABS(SUM(BaseDebit)-SUM(BaseCredit)) from Bean.JournalDetail where DocumentId=@DocumentId group by DocType)>=0.01)
					Begin
						Select @BaseDebit=SUM(BaseDebit),@BaseCredit=SUM(BaseCredit),@DiffAmount=ABS(SUM(BaseDebit)-SUM(BaseCredit)) from Bean.JournalDetail where DocumentId=@DocumentId
						Insert Into Bean.JournalDetail (Id,JournalId,COAId,AccountDescription,BaseDebit,BaseCredit,DocumentId,DocumentDetailId,ItemId,DocDate,DueDate,PostingDate,ExchangeRate,GSTExchangeRate,GSTExCurrency,Nature,DocType,DocSubType,ServiceCompanyId, CreditTermsId, DocNo, Currency, BaseCurrency, IsTax, EntityId, SystemRefNo,  DocCurrency, RecOrder,DocDebitTotal,DocCreditTotal)
						select NEWID(), @JournalId, (Select Id from Bean.ChartOfAccount where CompanyId=@CompanyId and Name=@Rounding), DocDescription, Case When @BaseDebit>@BaseCredit Then null Else @DiffAmount End as BaseDebit, Case When @BaseCredit>@BaseDebit Then null Else @DiffAmount END as BaseCredit, @DocumentId,NEWID(),@GUIDZero,DocDate,DueDate,DocDate,ExchangeRate,GSTExchangeRate,GSTExCurrency,Nature,DocType,DocSubType,ServiceCompanyId,CreditTermsId,DocNo, DocCurrency, ExCurrency, 0, EntityId,DocNo, DocCurrency, (Select Max(Recorder)+1 From Bean.JournalDetail Where DocumentId=@DocumentId),0,0
						from Bean.Invoice where CompanyId=@CompanyId and Id=@DocumentId
					End
			set @EntityId = (Select EntityId From Bean.Invoice where CompanyId=@CompanyId and Id=@MasterId)
			if(@EntityId is not null)
			Begin
				Exec [dbo].[Bean_Update_CustBalance_and_CreditLimit] @CompanyId,@EntityId
			End
		End
	
	Commit Transaction
	End Try
	Begin Catch
		Rollback Transaction
		Select @ErrorMessage=ERROR_MESSAGE()
		RAISERROR(@ErrorMessage,16,1);
	End Catch



End
GO
