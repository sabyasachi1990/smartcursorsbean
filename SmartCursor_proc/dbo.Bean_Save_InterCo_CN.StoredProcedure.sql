USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[Bean_Save_InterCo_CN]    Script Date: 16-12-2024 9.20.10 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE   Procedure [dbo].[Bean_Save_InterCo_CN]
(
@CreditNoteApp CreditNoteApplication Readonly,
@CreditNoteAppDetial CreditNoteApplicationDetail Readonly
)
AS BEGIN
	Declare @companyId BIGINT, @Id UNIQUEIDENTIFIER,@DocumentID UNIQUEIDENTIFIER
	Declare @InvoiceId UNIQUEIDENTIFIER
	Declare @currentDate DATETIME2(7)=GETUTCDATE()
	Declare @BillServiceEntityId Bigint, @BillEntityId UNIQUEIDENTIFIER, @ServiceEntityId BigInt
	
	Declare @Exchangerate decimal(15,10),@BillState nvarchar(30),@DocType Nvarchar(25), @CreditAmount Money,@InvoiceGrandTotal Money,@InvoiceDocNo Nvarchar(30),@IsReverseExcess Bit,@RecCount int,@Count int,@Detailid UNIQUEIDENTIFIER,@DetailCreditAmount Money,@System nvarchar(20)='System', @ApplicationDate DateTime2(7),@OldReverseExcess Bit,@DocCurrency nvarchar(25),@OldCreditAmount Money
	Declare @isDocNoEditable bit,	
			@docNo NvarChar(200)
	DECLARE  @ErrorMessage  NVARCHAR(4000), 
			 @ErrorSeverity INT, 
			 @ErrorState    INT;
	DECLARE @FullyPaid Nvarchar(30)='Fully Paid',@PartialPaid Nvarchar(30)='Partial Paid',@NotPaid Nvarchar(25)='Not Paid'
	DECLARE @Temp Table (S_No Int identity(1,1),DetailId Uniqueidentifier, DocumentId Uniqueidentifier,CreditAmount money, DocumentType nvarchar(20))
	Declare @BCDocumentHistoryType DocumentHistoryTableType

	Declare @RoundingAmount Money, @BaseBalance Money, @DocumentGrandTotal Money, @DocExchangeRate decimal(15,10),@DocState Nvarchar(20), @OldRoundingAmount Money, @creditNoteGrandToatl Money, @OldDetailAmount Money, @NewCreditNoteAmount money, @IsAdd bit=0, @BaseGrandTotal Money, @BalanceAmount Money, @CNAppRoundingAmount money, @OldCNState Nvarchar(30),@oldDetailDocState NvarChar(30)
	Declare @FullyApplied Nvarchar(40)='Fully Applied', @PartialApplied Nvarchar(40)='Partial Applied', @NotApplied Nvarchar(20)='Not Applied'
	Declare @CNDocNo Nvarchar(50), @CnAppCount Int, @CnAppDocno Nvarchar(50), @IsCreditZero Bit
	Declare @CreditNoteDoc Nvarchar(20)='Credit Note', @CreditMemoDoc  Nvarchar(20)='Credit Memo', @ISNoSupportDocs Bit
	Declare @GUIDZero Uniqueidentifier ='00000000-0000-0000-0000-000000000000', @DetailType nvarchar(20)
			

	BEGIN TRY
		BEGIN TRANSACTION
		Select @companyId=CompanyId,@InvoiceId=InvoiceId,@CreditAmount=CreditAmount,@OldCreditAmount=CreditAmount,@IsReverseExcess=Isnull(IsRevExcess,0),@Id=Id,@ApplicationDate=CreditNoteApplicationDate from @CreditNoteApp
		IF NOT EXISTS(Select Id from Bean.Invoice(nolock) where CompanyId=@companyId and Id=@InvoiceId)
		Begin
			RAISERROR ('Invalid Document',16,1);
		End

		Select @InvoiceGrandTotal=GrandTotal,@CNDocNo=DocNo,@Exchangerate=isnull( ExchangeRate,1),@DocCurrency=DocCurrency,@ISNoSupportDocs=IsNull(IsNoSupportingDocument,0) from Bean.Invoice(nolock) where CompanyId=@companyId and Id=@InvoiceId
		IF(@CreditAmount>@InvoiceGrandTotal)
		Begin
			RAISERROR ('Invalid Document',16,1);
		End

		


		IF EXISTS(Select Id from Bean.CreditNoteApplication where Id=@Id and CompanyId=@companyId)
		BEGIN
			 --Set @OldReverseExcess=Isnull((Select IsRevExcess from Bean.CreditNoteApplication where id=@Id and CompanyId=@companyId),0)
			 Select  @OldCreditAmount=CreditAmount,@CNAppRoundingAmount=RoundingAmount,@OldReverseExcess=ISNULL(IsRevExcess,0) from  Bean.CreditNoteApplication(nolock) where CompanyId=@companyId and Id=@Id
			 

			Update CNA SET CNA.CreditNoteApplicationDate=CNAType.CreditNoteApplicationDate,CNA.Remarks=CNAType.Remarks,CNA.ModifiedBy= CNAType.ModifiedBy,CNA.ModifiedDate=@currentDate,CNA.IsRevExcess=CNAType.IsRevExcess,CNA.CreditAmount=CNAType.CreditAmount,CNA.IsNoSupportingDocumentActivated=@ISNoSupportDocs from Bean.CreditNoteApplication CNA 
			join @CreditNoteApp CNAType on CNA.Id=CNAType.Id where CNA.id=@id and CNA.CompanyId=@companyId

			If(@OldReverseExcess=1 and @IsReverseExcess=0)--If reverse excess is checked and later unchecked
			BEGIN
				--We are deleting the record from the creditnoteapplicationdetail as well as journal and journalDetail
				Delete from Bean.CreditNoteApplicationDetail where CreditNoteApplicationId=@Id
				Delete from Bean.JournalDetail where DocumentId=@Id
				Delete from Bean.Journal where DocumentId=@Id and CompanyId=@companyId

				Insert Into @Temp
				Select Id,DocumentId,CreditAmount,DocumentType From @CreditNoteAppDetial Where CreditNoteApplicationId=@Id and CreditAmount<>0 Order By RecOrder
				Select @RecCount=Count(*) From @Temp

				Set @Count=1
				While @RecCount>=@Count
				BEGIN
					---We are inserting the record in Credit Note ApplicationDetail
					Select @Detailid= DetailId,@DocumentID=DocumentId,@DetailCreditAmount=CreditAmount,@DetailType=DocumentType From @Temp Where S_No=@Count
					Set @RoundingAmount=0--For rounding amount
					Set @BalanceAmount=0

					IF(@DetailType='Invoice')
					Begin
						--Here we are checking if the balance amount of the invoice is greater then the detail credit amount or not
						IF((Select BalanceAmount from Bean.Invoice where Id=@DocumentID and CompanyId=@companyId and DocSubType='Interco')<@DetailCreditAmount)
						BEGIN
							RAISERROR ('Credit Amount Cannot be greater than the Balance Amount',16,1);
						END

						Select @DocumentGrandTotal=GrandTotal,@BaseBalance=BaseBalanceAmount,@DocExchangeRate=ExchangeRate,@OldRoundingAmount=RoundingAmount,@BalanceAmount=BalanceAmount from Bean.Invoice where CompanyId=@companyId and DocSubType='Interco' and Id=@DocumentID
						Set @BalanceAmount-=@DetailCreditAmount
						IF(@DocumentGrandTotal=@DetailCreditAmount)
						Begin
							if(@OldRoundingAmount<>0 and @OldRoundingAmount is not null)
							Begin
								Set @RoundingAmount=@OldRoundingAmount
								Set @DocState=@FullyPaid
								Set @BaseBalance=0
							End
							Else
							Begin
								Set @BaseBalance -=Round((isnull(@DetailCreditAmount,0)*@DocExchangeRate),2);
								Set @DocState=@FullyPaid
							End
						End
						Else
						Begin
							Set @BaseBalance -=Round((isnull(@DetailCreditAmount,0)*@DocExchangeRate),2)
							Set @DocState=Case When @BalanceAmount=0 Then @FullyPaid Else @PartialPaid End
						End

						Update Bean.Invoice Set ModifiedBy=@System,ModifiedDate=@currentDate,BalanceAmount-=@DetailCreditAmount,DocumentState=@DocState,BaseBalanceAmount=@BaseBalance,RoundingAmount=0 Where CompanyId=@companyId and Id=@DocumentID and DocumentState<>'Void'

						--Journal State need to update

						Update J Set J.DocumentState=Inv.DocumentState,J.BalanceAmount=inv.BalanceAmount,J.ModifiedBy=Inv.ModifiedBy,J.ModifiedDate=inv.ModifiedDate from Bean.Journal J
						Join Bean.Invoice Inv on inv.Id=J.DocumentId and j.CompanyId=@companyId and Inv.CompanyId=@companyId
						where J.DocumentId=@DocumentID and J.companyId=@companyId

						Update Bean.DocumentHistory set AgingState='Deleted' where DocumentId=@DocumentID and TransactionId=@Id and CompanyId=@companyId and AgingState is null

						Insert Into Bean.DocumentHistory(Id,TransactionId,CompanyId,DocumentId,DocType,DocSubType,DocState,DocCurrency,DocAmount,DocBalanaceAmount,ExchangeRate,BaseAmount,BaseBalanaceAmount,StateChangedBy,PostingDate,DocAppliedAmount,BaseAppliedAmount,StateChangedDate)
						Select NEWID(),@Id,CompanyId,@DocumentId,DocType,DocSubType,DocumentState,DocCurrency,Round(GrandTotal,2) As DocAmount,Round(BalanceAmount,2) As DocBalanceAmount,ExchangeRate,Round(GrandTotal*ExchangeRate,2) As BaseAmount,Round(BalanceAmount*ExchangeRate,2) As BaseBalanceAmount,@System,@ApplicationDate,  -Round(@DetailCreditAmount,2) As DocAppliedAmount,-ROUND(@DetailCreditAmount*ExchangeRate,2)/*+ISNULL(@RoundingAmount,0)*/ As BaseAppliedAmount,@currentDate From Bean.Invoice(nolock) Where Id=@DocumentId

					End
					Else If(@DetailType='Debit Note')
					Begin
						--Here we are checking if the balance amount of the Debit Note is greater then the detail credit amount or not
						IF((Select BalanceAmount from Bean.DebitNote(nolock) where Id=@DocumentID and CompanyId=@companyId and Nature='Interco')<@DetailCreditAmount)
						BEGIN
							RAISERROR ('Credit Amount Cannot be greater than the Balance Amount',16,1);
						END

						Select @DocumentGrandTotal=GrandTotal,@BaseBalance=BaseBalanceAmount,@DocExchangeRate=ExchangeRate,@OldRoundingAmount=RoundingAmount,@BalanceAmount=BalanceAmount from Bean.DebitNote(nolock) where CompanyId=@companyId and Nature='Interco' and Id=@DocumentID
						Set @BalanceAmount-=@DetailCreditAmount
						IF(@DocumentGrandTotal=@DetailCreditAmount)
						Begin
							if(@OldRoundingAmount<>0 and @OldRoundingAmount is not null)
							Begin
								Set @RoundingAmount=@OldRoundingAmount
								Set @DocState=@FullyPaid
								Set @BaseBalance=0
							End
							Else
							Begin
								Set @BaseBalance -=Round((isnull(@DetailCreditAmount,0)*@DocExchangeRate),2);
								Set @DocState=@FullyPaid
							End
						End
						Else
						Begin
							Set @BaseBalance -=Round((isnull(@DetailCreditAmount,0)*@DocExchangeRate),2)
							Set @DocState=Case When @BalanceAmount=0 Then @FullyPaid Else @PartialPaid End
						End

						Update Bean.DebitNote Set ModifiedBy=@System,ModifiedDate=@currentDate,BalanceAmount-=@DetailCreditAmount,DocumentState=@DocState,BaseBalanceAmount=@BaseBalance,RoundingAmount=0 Where CompanyId=@companyId and Id=@DocumentID and DocumentState<>'Void'

						--Journal State need to update

						Update J Set J.DocumentState=Inv.DocumentState,J.BalanceAmount=inv.BalanceAmount,J.ModifiedBy=Inv.ModifiedBy,J.ModifiedDate=inv.ModifiedDate from Bean.Journal J
						Join Bean.DebitNote Inv on inv.Id=J.DocumentId and j.CompanyId=@companyId and Inv.CompanyId=@companyId
						where J.DocumentId=@DocumentID and J.companyId=@companyId

						Update Bean.DocumentHistory set AgingState='Deleted' where DocumentId=@DocumentID and TransactionId=@Id and CompanyId=@companyId and AgingState is null

						Insert Into Bean.DocumentHistory(Id,TransactionId,CompanyId,DocumentId,DocType,DocSubType,DocState,DocCurrency,DocAmount,DocBalanaceAmount,ExchangeRate,BaseAmount,BaseBalanaceAmount,StateChangedBy,PostingDate,DocAppliedAmount,BaseAppliedAmount,StateChangedDate)
						Select NEWID(),@Id,CompanyId,@DocumentId,DocSubType,Nature,DocumentState,DocCurrency,Round(GrandTotal,2) As DocAmount,Round(BalanceAmount,2) As DocBalanceAmount,ExchangeRate,Round(GrandTotal*ExchangeRate,2) As BaseAmount,Round(BalanceAmount*ExchangeRate,2) As BaseBalanceAmount,@System,@ApplicationDate,  -Round(@DetailCreditAmount,2) As DocAppliedAmount,-ROUND(@DetailCreditAmount*ExchangeRate,2)/*+ISNULL(@RoundingAmount,0)*/ As BaseAppliedAmount,@currentDate From Bean.DebitNote(nolock) Where Id=@DocumentId
					End
					
					--We are inserting the record into the CreditNote application detail
					INSERT INTO Bean.CreditNoteApplicationDetail
					(Id, CreditNoteApplicationId, DocumentId,DocumentType, DocCurrency,CreditAmount, BaseCurrencyExchangeRate, DocDescription, COAId,TaxId,TaxRate, TaxIdCode,TaxAmount,TotalAmount,RecOrder,ServiceEntityId,DocNo,RoundingAmount)
					Select NEWID(),@Id,CNADetail.DocumentId,CNADetail.DocumentType,CNADetail.DocCurrency,CNADetail.CreditAmount,CNADetail.BaseCurrencyExchangeRate,CNADetail.DocDescription,null,null,null,null,null,CNADetail.TotalAmount,CNADetail.RecOrder,ServiceEntityId,DocNo,@RoundingAmount From @CreditNoteAppDetial CNADetail where CNADetail.Id=@Detailid

					Set @Count=@Count+1;
				END
			END
			ELSE IF(@OldReverseExcess=0 and @IsReverseExcess=1)
			BEGIN
				--Delete from Bean.CreditNoteApplicationDetail where CreditNoteApplicationId=@Id
				Insert Into @Temp
				Select Id,DocumentId,CreditAmount,DocumentType From Bean.CreditNoteApplicationDetail(nolock) Where CreditNoteApplicationId=@Id Order By RecOrder
				Select @RecCount=Count(*) From @Temp
				Set @Count=1
				While @RecCount>=@Count
				Begin
					Select @Detailid= DetailId,@DocumentID=DocumentId,@DetailCreditAmount=CreditAmount,@DetailType=DocumentType From @Temp Where S_No=@Count
					If Exists(Select Id from Bean.CreditNoteApplicationDetail(nolock) where Id=@Detailid)
					Begin
						IF(@DetailType='Invoice')
						Begin
							Select @RoundingAmount=ISNULL(RoundingAmount,0),@OldCreditAmount=CreditAmount from Bean.CreditNoteApplicationDetail(nolock) where Id=@Detailid 
							Select @DocExchangeRate=ISNULL(ExchangeRate,1),@BalanceAmount=BalanceAmount from Bean.Invoice(nolock) where CompanyId=@companyId and id=@DocumentID
							Set @BalanceAmount+=@OldCreditAmount
							Update Bean.Invoice Set ModifiedBy=@System,ModifiedDate=@currentDate,DocumentState=Case When @BalanceAmount=GrandTotal Then @NotPaid Else @PartialPaid End,BalanceAmount=@BalanceAmount,BaseBalanceAmount+=ROUND(@OldCreditAmount*@DocExchangeRate,2),RoundingAmount=Case when @RoundingAmount<>0 Then @RoundingAmount Else RoundingAmount End Where CompanyId=@companyId and Id=@DocumentID and DocumentState<>'Void'

							--Journal State need to update

							Update J Set J.DocumentState=Inv.DocumentState,J.BalanceAmount=inv.BalanceAmount,J.ModifiedBy=Inv.ModifiedBy,J.ModifiedDate=inv.ModifiedDate from Bean.Journal J
							Join Bean.Invoice Inv on inv.Id=J.DocumentId and j.CompanyId=@companyId and Inv.CompanyId=@companyId
							where J.DocumentId=@DocumentID and J.companyId=@companyId

							Insert Into @BCDocumentHistoryType(TransactionId,CompanyId,DocumentId,DocType,DocSubType,DocState,DocCurrency,DocAmount,DocBalanaceAmount,ExchangeRate,BaseAmount,BaseBalanaceAmount,StateChangedBy,PostingDate,DocAppliedAmount,BaseAppliedAmount)

							Select @Id,CompanyId,@DocumentID,DocType,DocSubType,DocumentState,DocCurrency,Round(GrandTotal,2) As DocAmount,Round(BalanceAmount,2) As DocBalanceAmount,ExchangeRate,Case When DocumentState=@NotApplied Then  BaseGrandTotal Else 0 End As BaseAmount, BaseBalanceAmount As BaseBalanceAmount,@System,@ApplicationDate,0 As DocAppliedAmount,0  As BaseAppliedAmount From Bean.Invoice(nolock) Where Id=@DocumentId
				
						End
						Else If(@DetailType='Debit Note')
						Begin
							Select @RoundingAmount=ISNULL(RoundingAmount,0),@OldCreditAmount=CreditAmount from Bean.CreditNoteApplicationDetail(nolock) where Id=@Detailid 
							Select @DocExchangeRate=ISNULL(ExchangeRate,1),@BalanceAmount=BalanceAmount from Bean.DebitNote(nolock) where CompanyId=@companyId and id=@DocumentID
							Set @BalanceAmount+=@OldCreditAmount
							Update Bean.DebitNote Set ModifiedBy=@System,ModifiedDate=@currentDate,DocumentState=Case When @BalanceAmount=GrandTotal Then @NotPaid Else @PartialPaid End,BalanceAmount=@BalanceAmount,BaseBalanceAmount+=ROUND(@OldCreditAmount*@DocExchangeRate,2),RoundingAmount=Case when @RoundingAmount<>0 Then @RoundingAmount Else RoundingAmount End Where CompanyId=@companyId and Id=@DocumentID and DocumentState<>'Void'

							--Journal State need to update

							Update J Set J.DocumentState=Inv.DocumentState,J.BalanceAmount=inv.BalanceAmount,J.ModifiedBy=Inv.ModifiedBy,J.ModifiedDate=inv.ModifiedDate from Bean.Journal J
							Join Bean.DebitNote Inv on inv.Id=J.DocumentId and j.CompanyId=@companyId and Inv.CompanyId=@companyId
							where J.DocumentId=@DocumentID and J.companyId=@companyId

							Insert Into @BCDocumentHistoryType(TransactionId,CompanyId,DocumentId,DocType,DocSubType,DocState,DocCurrency,DocAmount,DocBalanaceAmount,ExchangeRate,BaseAmount,BaseBalanaceAmount,StateChangedBy,PostingDate,DocAppliedAmount,BaseAppliedAmount)

							Select @Id,CompanyId,@DocumentID,DocSubType,Nature,DocumentState,DocCurrency,Round(GrandTotal,2) As DocAmount,Round(BalanceAmount,2) As DocBalanceAmount,ExchangeRate,Case When DocumentState=@NotApplied Then  BaseGrandTotal Else 0 End As BaseAmount, BaseBalanceAmount As BaseBalanceAmount,@System,@ApplicationDate,0 As DocAppliedAmount,0  As BaseAppliedAmount From Bean.DebitNote Where Id=@DocumentId
				
						End


						
						--Exec [dbo].[Bean_DocumentHistory] @BCDocumentHistoryType

						Delete from Bean.CreditNoteApplicationDetail where CreditNoteApplicationId=@Id and Id=@Detailid
					End
					Set @Count=@count+1;
				End

				-----Inserting the record in the CNApp detail

				INSERT INTO Bean.CreditNoteApplicationDetail
				(Id, CreditNoteApplicationId, DocumentId,DocumentType, DocCurrency,CreditAmount, BaseCurrencyExchangeRate, DocDescription, COAId,TaxId,TaxRate, TaxIdCode,TaxAmount,TotalAmount,RecOrder,ServiceEntityId,DocNo)
				Select NEWID(),@Id,@GUIDZero,null,CNADetail.DocCurrency,CNADetail.CreditAmount,CNADetail.BaseCurrencyExchangeRate,CNADetail.DocDescription,CNADetail.COAId,CNADetail.TaxId,CNADetail.TaxRate,CNADetail.TaxIdCode,CNADetail.TaxAmount,CNADetail.TotalAmount, CNADetail.RecOrder,null,null From @CreditNoteAppDetial CNADetail where CNADetail.CreditNoteApplicationId=@Id and CNADetail.CreditAmount<>0

					
			END
			Else IF(@OldReverseExcess=1 and @IsReverseExcess=1)
			BEGIN
				Update CNAD Set CNAD.COAId=CNADType.COAId,CNAd.CreditAmount=CNADType.CreditAmount,CNAD.DocDescription=CNADType.DocDescription,CNAd.TaxId=CNADType.TaxId,CNAD.TaxRate=CNADType.TaxRate,CNAD.TaxIdCode=CNADType.TaxIdCode,CNAD.TotalAmount=CNADType.TotalAmount,CNAD.TaxAmount=CNADType.TaxAmount from Bean.CreditNoteApplicationDetail CNAD join @CreditNoteAppDetial CNADType on CNAD.Id=CNADType.Id where CNAD.Id=CNADType.Id
				INSERT INTO Bean.CreditNoteApplicationDetail
				(Id, CreditNoteApplicationId, DocumentId,DocumentType, DocCurrency,CreditAmount, BaseCurrencyExchangeRate, DocDescription,COAId,TaxId,TaxRate,TaxIdCode,TaxAmount,TotalAmount,RecOrder,ServiceEntityId,DocNo)
				Select NEWID(),@Id,@GuidZero,null,CNADetail.DocCurrency,CNADetail.CreditAmount,CNADetail.BaseCurrencyExchangeRate,CNADetail.DocDescription,CNADetail.COAId,CNADetail.TaxId,CNADetail.TaxRate,CNADetail.TaxIdCode,CNADetail.TaxAmount,CNADetail.TotalAmount,(Select Max(RecOrder)+1 from Bean.CreditNoteApplicationDetail where CreditNoteApplicationId=@Id),null,null From @CreditNoteAppDetial CNADetail where CNADetail.Id Not in (select Id from Bean.CreditNoteApplicationDetail where CreditNoteApplicationId=@Id) and CNADetail.CreditNoteApplicationId=@Id

				
			END
			Else IF(@OldReverseExcess=0 and @IsReverseExcess=0)
			BEGIN
				Insert Into @Temp
				Select Id,DocumentId,CreditAmount,DocumentType From @CreditNoteAppDetial Where CreditNoteApplicationId=@Id Order By RecOrder
				Select @RecCount=Count(*) From @Temp

				Set @Count=1
				While @RecCount>=@Count
				BEGIN
					Select @Detailid= DetailId,@DocumentID=DocumentId,@DetailCreditAmount=CreditAmount,@DetailType=DocumentType From @Temp Where S_No=@Count
					Set @RoundingAmount=0
					Set @IsCreditZero=0
					Set @BalanceAmount=0
					Set @Count =@count+1; 
					If Exists(Select Id from Bean.CreditNoteApplicationDetail(nolock) where Id=@Detailid)
					Begin ---- If the rcord exists
						
						If(@DetailType='Invoice')
						Begin
							Select @DocumentGrandTotal=GrandTotal,@BaseBalance=BaseBalanceAmount,@DocExchangeRate=ExchangeRate,@OldRoundingAmount=RoundingAmount,@BalanceAmount=BalanceAmount,@oldDetailDocState=DocumentState from Bean.Invoice(nolock) where CompanyId=@companyId and DocSubType='Interco' and Id=@DocumentID
						End
						Else IF(@DetailType='Debit Note')
						Begin
							
							Select @DocumentGrandTotal=GrandTotal,@BaseBalance=BaseBalanceAmount,@DocExchangeRate=ExchangeRate,@OldRoundingAmount=RoundingAmount,@BalanceAmount=BalanceAmount,@oldDetailDocState=DocumentState from Bean.DebitNote(nolock) where CompanyId=@companyId and Nature='Interco' and Id=@DocumentID
						End
						

						Select @OldDetailAmount=CreditAmount from Bean.CreditNoteApplicationDetail(nolock) where Id=@Detailid 
						if(@OldDetailAmount!=@DetailCreditAmount)
						Begin
							If(@DetailCreditAmount=0)
							Begin--If The Edit Mode the @detailCreditAmount is 0
								Set @BalanceAmount+=@OldDetailAmount
								Set @BaseBalance+=Round(@OldDetailAmount*@DocExchangeRate,2)
								Set @DocState=Case When @BalanceAmount=@DocumentGrandTotal Then @NotPaid ELse @PartialPaid 
								End
								Set @IsCreditZero=1
							End--End of if zero
							Else
							Begin--If eidt mode the amount is not Zero
								Set @BalanceAmount-=(@DetailCreditAmount-@OldDetailAmount)
								If(@BalanceAmount=0)--If the Credtit amount zero then
								Begin
					
									If(@DetailCreditAmount=@DocumentGrandTotal)
									Begin
										Set @RoundingAmount=Case When (@OldRoundingAmount<>0 and @OldRoundingAmount is not null) Then @OldRoundingAmount Else  Round(@CreditAmount*@DocExchangeRate,2)-@BaseGrandTotal End;
										Set @DocState=@FullyPaid
										Set @BaseBalance=0
									End
									Else
									Begin
										Set @BaseBalance -=Round((isnull(@DetailCreditAmount,0)*@DocExchangeRate),2);
										Set @DocState=@FullyPaid
									End
								End
								Else
								Begin
									Set @BaseBalance=Case When @OldDetailAmount>@DetailCreditAmount Then @BaseBalance+ROUND(ABS(@OldDetailAmount-@DetailCreditAmount)*@DocExchangeRate,2) Else @BaseBalance-ROUND(ABS(@OldDetailAmount-@DetailCreditAmount)*@DocExchangeRate,2) End;
									Set @DocState=@PartialPaid
									If(@oldDetailDocState=@FullyPaid and (@OldRoundingAmount<>0 or @OldRoundingAmount is not null))
									Begin
										Set @RoundingAmount=@CNAppRoundingAmount
									End
								End
							
								IF (@DetailType='Invoice')
								Begin
									Update Bean.Invoice Set						ModifiedBy=@System,ModifiedDate=@currentDate,BalanceAmount=@BalanceAmount,DocumentState=@DocState,
								BaseBalanceAmount=@BaseBalance,RoundingAmount=Case when @DocState=@NotPaid Then @RoundingAmount Else 0 End  Where CompanyId=@companyId and Id=@DocumentID and DocumentState<>'Void'


								--Journal State need to update

								Update J Set J.DocumentState=Inv.DocumentState,J.BalanceAmount=inv.BalanceAmount,J.ModifiedBy=Inv.ModifiedBy,J.ModifiedDate=inv.ModifiedDate from Bean.Journal J
								Join Bean.Invoice Inv on inv.Id=J.DocumentId and j.CompanyId=@companyId and Inv.CompanyId=@companyId
								where J.DocumentId=@DocumentID and J.companyId=@companyId


								Insert Into @BCDocumentHistoryType		(TransactionId,CompanyId,DocumentId,DocType,DocSubType,DocState,DocCurrency,DocAmount,DocBalanaceAmount,ExchangeRate,BaseAmount,BaseBalanaceAmount,StateChangedBy,PostingDate,DocAppliedAmount,BaseAppliedAmount)

								Select @Id,CompanyId,Id,DocType,DocSubType,DocumentState,DocCurrency,Round(GrandTotal,2) As DocAmount,Round(BalanceAmount,2) As DocBalanceAmount,ExchangeRate,Case When DocumentState=@NotApplied Then  BaseGrandTotal Else 0 End As BaseAmount, BaseBalanceAmount As BaseBalanceAmount,@System,@ApplicationDate,-@CreditAmount As DocAppliedAmount,Case When @IsCreditZero=1 Then 0 Else -Round(@CreditAmount*@DocExchangeRate,2)/*+ISNULL(@RoundingAmount,0)*/ End As BaseAppliedAmount From Bean.Invoice(nolock) Where Id=@DocumentId and CompanyId=@companyId
								End
								Else If(@DetailType='Debit Note')
								Begin
										Update Bean.DebitNote Set						ModifiedBy=@System,ModifiedDate=@currentDate,BalanceAmount=@BalanceAmount,DocumentState=@DocState,
									BaseBalanceAmount=@BaseBalance,RoundingAmount=Case when @DocState=@NotPaid Then @RoundingAmount Else 0 End  Where CompanyId=@companyId and Id=@DocumentID and DocumentState<>'Void'


									--Journal State need to update

									Update J Set J.DocumentState=Inv.DocumentState,J.BalanceAmount=inv.BalanceAmount,J.ModifiedBy=Inv.ModifiedBy,J.ModifiedDate=inv.ModifiedDate from Bean.Journal J
									Join Bean.DebitNote Inv on inv.Id=J.DocumentId and j.CompanyId=@companyId and Inv.CompanyId=@companyId
									where J.DocumentId=@DocumentID and J.companyId=@companyId


									Insert Into @BCDocumentHistoryType		(TransactionId,CompanyId,DocumentId,DocType,DocSubType,DocState,DocCurrency,DocAmount,DocBalanaceAmount,ExchangeRate,BaseAmount,BaseBalanaceAmount,StateChangedBy,PostingDate,DocAppliedAmount,BaseAppliedAmount)

									Select @Id,CompanyId,Id,DocSubType,Nature,DocumentState,DocCurrency,Round(GrandTotal,2) As DocAmount,Round(BalanceAmount,2) As DocBalanceAmount,ExchangeRate,Case When DocumentState=@NotApplied Then  BaseGrandTotal Else 0 End As BaseAmount, BaseBalanceAmount As BaseBalanceAmount,@System,@ApplicationDate,-@CreditAmount As DocAppliedAmount,Case When @IsCreditZero=1 Then 0 Else -Round(@CreditAmount*@DocExchangeRate,2)/*+ISNULL(@RoundingAmount,0)*/ End As BaseAppliedAmount From Bean.DebitNote(nolock) Where Id=@DocumentId and CompanyId=@companyId
							End
								
				

							Update CNAD Set						CNAd.CreditAmount=@DetailCreditAmount,CNAD.DocDescription=CNADType.DocDescription,CNAD.DocumentId=@DocumentID,CNAD.ServiceEntityId=CNADType.ServiceEntityId,CNAD.DocNo=CNADType.DocNo from  Bean.CreditNoteApplicationDetail CNAD join @CreditNoteAppDetial CNADType on CNAD.Id=@Detailid where CNAD.Id=@Detailid
								--Exec [dbo].[Bean_DocumentHistory] @BCDocumentHistoryType



							End--End of edit mode is not 0
							
						End
						
						
					End
					Else
					Begin
						If (@DetailCreditAmount<>0)---If Detail Credit Amoun is greater than zero then insert
						Begin

							If(@DetailType='Invoice')
							Begin
								Select @DocumentGrandTotal=GrandTotal, @BaseBalance=BaseBalanceAmount,			@DocExchangeRate=ExchangeRate, @OldRoundingAmount=RoundingAmount, @BalanceAmount=BalanceAmount from Bean.Invoice(nolock) where CompanyId=@companyId and		DocSubType='Interco' and Id=@DocumentID
							End
							Else If(@DetailType='Debit Note')
							Begin
								Select @DocumentGrandTotal=GrandTotal, @BaseBalance=BaseBalanceAmount,			@DocExchangeRate=ExchangeRate, @OldRoundingAmount=RoundingAmount,	@BalanceAmount=BalanceAmount from Bean.DebitNote(nolock) where CompanyId=@companyId and Nature='Interco' and Id=@DocumentID
							End
							

							Set @BalanceAmount-=@DetailCreditAmount
							IF(@DocumentGrandTotal=@DetailCreditAmount)
							Begin
								if(@OldRoundingAmount<>0 and @OldRoundingAmount is not null)
								Begin
									Set @RoundingAmount=@OldRoundingAmount
									Set @DocState=@FullyPaid
									Set @BaseBalance=0
								End
								Else
								Begin
									Set @BaseBalance -=Round((isnull(@DetailCreditAmount,0)*@DocExchangeRate),2);
									Set @DocState=@FullyPaid
								End
							End
							Else
							Begin
								Set @BaseBalance -=Round((isnull(@DetailCreditAmount,0)*@DocExchangeRate),2)
								Set @DocState= Case When @BalanceAmount=0 Then @FullyPaid Else @PartialPaid End
							End


							INSERT INTO Bean.CreditNoteApplicationDetail
							(Id, CreditNoteApplicationId, DocumentId,DocumentType, DocCurrency,CreditAmount, BaseCurrencyExchangeRate, DocDescription, COAId,TaxId,TaxRate, TaxIdCode,TaxAmount,TotalAmount,RecOrder,ServiceEntityId,DocNo,RoundingAmount)
							Select NEWID(),@Id,CNADetail.DocumentId,CNADetail.DocumentType,CNADetail.DocCurrency,CNADetail.CreditAmount,CNADetail.BaseCurrencyExchangeRate,CNADetail.DocDescription,null,null,null,null,null,CNADetail.TotalAmount,CNADetail.RecOrder,CNADetail.ServiceEntityId,CNADetail.DocNo,@RoundingAmount From @CreditNoteAppDetial CNADetail where CNADetail.Id=@Detailid

							--IF((Select BalanceAmount from Bean.Invoice where Id=@DocumentID and CompanyId=@companyId and DocSubType='Interco')<@DetailCreditAmount)
							--BEGIN
							--	RAISERROR ('Credit Amount Canot be greater than the Balance Amount',16,1);
							--END

							If(@detailType='Invoice')
							Begin
								--Here we are updating the modified by, modified date, balance amount,	state and base balance amount
								Update Bean.Invoice Set			ModifiedBy=@System,ModifiedDate=@currentDate,BalanceAmount-=@DetailCreditAmount,DocumentState=@DocState,
							BaseBalanceAmount=@BaseBalance,RoundingAmount=0  Where CompanyId=@companyId and Id=@DocumentID and DocumentState<>'Void'

							--Journal State need to update

								Update J Set	J.DocumentState=Inv.DocumentState,J.BalanceAmount=inv.BalanceAmount,J.ModifiedBy=Inv.ModifiedBy,J.ModifiedDate=inv.ModifiedDate from Bean.Journal J
							Join Bean.Invoice Inv on inv.Id=J.DocumentId and j.CompanyId=@companyId and Inv.CompanyId=@companyId
							where J.DocumentId=@DocumentID and J.companyId=@companyId

							Update Bean.DocumentHistory set AgingState='Deleted' where DocumentId=@DocumentID and TransactionId=@Id and CompanyId=@companyId and AgingState is null

								Insert Into Bean.DocumentHistory		(Id,TransactionId,CompanyId,DocumentId,DocType,DocSubType,DocState,DocCurrency,DocAmount,DocBalanaceAmount,ExchangeRate,BaseAmount,BaseBalanaceAmount,StateChangedBy,PostingDate,DocAppliedAmount,BaseAppliedAmount,StateChangedDate)

							Select NEWID(),@Id,CompanyId,Id,DocType,DocSubType,DocumentState,DocCurrency,Round(GrandTotal,2) As DocAmount,Round(BalanceAmount,2) As DocBalanceAmount,ExchangeRate,Round(GrandTotal*ExchangeRate,2) As BaseAmount,Round(BalanceAmount*ExchangeRate,2) As BaseBalanceAmount,@System,@ApplicationDate,  -Round(@DetailCreditAmount,2) As DocAppliedAmount,-ROUND(@DetailCreditAmount*ExchangeRate,2)/*+Isnull(@RoundingAmount,0)*/ As BaseAppliedAmount,@currentDate From Bean.Invoice(nolock) Where Id=@DocumentId
							End
							Else If(@DetailType='Debit Note')
							Begin
								--Here we are updating the modified by, modified date, balance amount, state and base balance amount
							Update Bean.DebitNote Set ModifiedBy=@System,ModifiedDate=@currentDate,BalanceAmount-=@DetailCreditAmount,DocumentState=@DocState,
							BaseBalanceAmount=@BaseBalance,RoundingAmount=0  Where CompanyId=@companyId and Id=@DocumentID and DocumentState<>'Void'

							--Journal State need to update

							Update J Set J.DocumentState=Inv.DocumentState,J.BalanceAmount=inv.BalanceAmount,J.ModifiedBy=Inv.ModifiedBy,J.ModifiedDate=inv.ModifiedDate from Bean.Journal J
							Join Bean.DebitNote Inv on inv.Id=J.DocumentId and j.CompanyId=@companyId and Inv.CompanyId=@companyId
							where J.DocumentId=@DocumentID and J.companyId=@companyId

							Update Bean.DocumentHistory set AgingState='Deleted' where DocumentId=@DocumentID and TransactionId=@Id and CompanyId=@companyId and AgingState is null

							Insert Into Bean.DocumentHistory(Id,TransactionId,CompanyId,DocumentId,DocType,DocSubType,DocState,DocCurrency,DocAmount,DocBalanaceAmount,ExchangeRate,BaseAmount,BaseBalanaceAmount,StateChangedBy,PostingDate,DocAppliedAmount,BaseAppliedAmount,StateChangedDate)

							Select NEWID(),@Id,CompanyId,Id,DocSubType,Nature,DocumentState,DocCurrency,Round(GrandTotal,2) As DocAmount,Round(BalanceAmount,2) As DocBalanceAmount,ExchangeRate,Round(GrandTotal*ExchangeRate,2) As BaseAmount,Round(BalanceAmount*ExchangeRate,2) As BaseBalanceAmount,@System,@ApplicationDate,  -Round(@DetailCreditAmount,2) As DocAppliedAmount,-ROUND(@DetailCreditAmount*ExchangeRate,2)/*+Isnull(@RoundingAmount,0)*/ As BaseAppliedAmount,@currentDate From Bean.DebitNote(nolock) Where Id=@DocumentId
							End
							

							
						END
						--Set @Count =@count+1;

					End
					

					
					
				END
		    END


		END
		ELSE
		BEGIN
			Set @IsAdd=1

			select @CnAppCount=Isnull(COUNT(*),0)+1 from Bean.CreditNoteApplication where InvoiceId=@InvoiceId

			Select @CnAppDocno= CONCAT(@CNDocNo,'-A'+Cast(@CnAppCount as nvarchar(20)))

		
			INSERT INTO Bean.CreditNoteApplication 					(Id,InvoiceId,CompanyId,CreditNoteApplicationDate,CreditNoteApplicationResetDate,IsNoSupportingDocumentActivated,IsNoSupportingDocument,CreditAmount,Remarks,CreditNoteApplicationNumber,UserCreated,CreatedDate,ModifiedBy,ModifiedDate,Status,ExchangeRate,IsRevExcess)

			SELECT 
			@Id, Inv.Id,@companyId,CNA.CreditNoteApplicationDate,null,Isnull(Inv.NoSupportingDocs,0),ISnull(INv.IsNoSupportingDocument,0),CNA.CreditAmount,CNA.Remarks,@CnAppDocno,CNA.UserCreated,@currentDate,null,null,1,inv.ExchangeRate,CNA.IsRevExcess
			 from Bean.Invoice Inv 
			JOIN @CreditNoteApp CNA on CNA.InvoiceId=Inv.Id and CNA.CompanyId=@companyId 

			IF(@IsReverseExcess=1)
			BEGIN
				INSERT INTO Bean.CreditNoteApplicationDetail
				(Id, CreditNoteApplicationId, DocumentId,DocumentType, DocCurrency,CreditAmount, BaseCurrencyExchangeRate, DocDescription,COAId,TaxId,TaxRate,TaxIdCode,TaxAmount,TotalAmount,RecOrder,ServiceEntityId,DocNo)
				Select NEWID(),@Id,@GUIDZero,null,CNADetail.DocCurrency,CNADetail.CreditAmount,CNADetail.BaseCurrencyExchangeRate,CNADetail.DocDescription,CNADetail.COAId,CNADetail.TaxId,CNADetail.TaxRate,CNADetail.TaxIdCode,CNADetail.TaxAmount,CNADetail.TotalAmount,CNADetail.RecOrder,null,null From @CreditNoteAppDetial CNADetail where CNADetail.CreditNoteApplicationId=@Id and CNADetail.CreditAmount<>0
			END
			ELSE
			BEGIN
				
				Insert Into @Temp
				Select Id,DocumentId,CreditAmount,DocumentType From @CreditNoteAppDetial Where CreditNoteApplicationId=@Id and CreditAmount<>0 Order By RecOrder
				Select @RecCount=Count(*) From @Temp

				Set @Count=1
				While @RecCount>=@Count
				BEGIN

					Set @BalanceAmount=0;
					Select @Detailid= DetailId,@DocumentID=DocumentId,@DetailCreditAmount=CreditAmount,@DetailType=DocumentType From @Temp Where S_No=@Count

					--Here we need to update the documentState, BalanceAmount and BaseBalance Amount for the Interco invoice
					--If Exists(Select Id from Bean.Invoice where CompanyId=@companyId and Id=@DocumentID and DocSubType='Interco' and DocType='Invoice' and BalanceAmount<@DetailCreditAmount)
					--Begin
					--	RAISERROR ('Invalid Document',16,1);
					--End
					If(@DetailType='Invoice')
					Begin
						Select @DocumentGrandTotal=GrandTotal,@BaseBalance=BaseBalanceAmount,@DocExchangeRate=ExchangeRate,@OldRoundingAmount=RoundingAmount,@BalanceAmount=BalanceAmount from Bean.Invoice(nolock) where CompanyId=@companyId and DocSubType='Interco' and Id=@DocumentID
					End
					Else If(@DetailType='Debit Note')
					Begin
						Select @DocumentGrandTotal=GrandTotal, @BaseBalance=BaseBalanceAmount,			@DocExchangeRate=ExchangeRate, @OldRoundingAmount=RoundingAmount,	@BalanceAmount=BalanceAmount from Bean.DebitNote(nolock) where CompanyId=@companyId and Nature='Interco' and Id=@DocumentID
					End
					
					Set @BalanceAmount-=@DetailCreditAmount
					IF(@DocumentGrandTotal=@DetailCreditAmount)
					Begin
						if(@OldRoundingAmount<>0 and @OldRoundingAmount is not null)
						Begin
							Set @RoundingAmount=@OldRoundingAmount
							Set @DocState=@FullyPaid
							Set @BaseBalance=0
						End
						Else
						Begin
							Set @BaseBalance -=Round((isnull(@DetailCreditAmount,0)*@DocExchangeRate),2);
							Set @DocState=@FullyPaid
						End
					End
					Else
					Begin
						Set @BaseBalance -=Round((isnull(@DetailCreditAmount,0)*@DocExchangeRate),2)
						Set @DocState=Case When @BalanceAmount=0 Then @FullyPaid Else @PartialPaid End
					End


					INSERT INTO Bean.CreditNoteApplicationDetail
					(Id, CreditNoteApplicationId, DocumentId,DocumentType, DocCurrency,CreditAmount, BaseCurrencyExchangeRate, DocDescription, COAId,TaxId,TaxRate, TaxIdCode,TaxAmount,TotalAmount,RecOrder,ServiceEntityId,DocNo,RoundingAmount)
					Select NEWID(),@Id,CNADetail.DocumentId,CNADetail.DocumentType,CNADetail.DocCurrency,CNADetail.CreditAmount,CNADetail.BaseCurrencyExchangeRate,CNADetail.DocDescription,null,null,null,null,null,CNADetail.TotalAmount,CNADetail.RecOrder,CNADetail.ServiceEntityId,CNADetail.DocNo,@RoundingAmount From @CreditNoteAppDetial CNADetail where CNADetail.Id=@Detailid  

					--IF((Select BalanceAmount from Bean.Invoice where Id=@DocumentID and CompanyId=@companyId and DocSubType='Interco')<@DetailCreditAmount)
					--BEGIN
					--	RAISERROR ('Credit Amount Canot be greater than the Balance Amount',16,1);
					--END
					If(@DetailType='Invoice')
					Begin
						--Here we are updating the modified by, modified date, balance amount, state and base balance amount
					Update Bean.Invoice Set ModifiedBy=@System,ModifiedDate=@currentDate,BalanceAmount-=@DetailCreditAmount,DocumentState=@DocState,
					BaseBalanceAmount=@BaseBalance,RoundingAmount=0  Where CompanyId=@companyId and Id=@DocumentID and DocumentState<>'Void'

					--Journal State need to update

					Update J Set J.DocumentState=Inv.DocumentState,J.BalanceAmount=inv.BalanceAmount,J.ModifiedBy=Inv.ModifiedBy,J.ModifiedDate=inv.ModifiedDate from Bean.Journal J
					Join Bean.Invoice Inv on inv.Id=J.DocumentId and j.CompanyId=@companyId and Inv.CompanyId=@companyId
						where J.DocumentId=@DocumentID and J.companyId=@companyId

					--Update Bean.DocumentHistory where TransactionId=  and DocumentId=@d

					Update Bean.DocumentHistory set AgingState='Deleted' where DocumentId=@DocumentID and TransactionId=@Id and CompanyId=@companyId and AgingState is null

					Insert Into Bean.DocumentHistory(Id,TransactionId,CompanyId,DocumentId,DocType,DocSubType,DocState,DocCurrency,DocAmount,DocBalanaceAmount,ExchangeRate,BaseAmount,BaseBalanaceAmount,StateChangedBy,PostingDate,DocAppliedAmount,BaseAppliedAmount,StateChangedDate)
					Select NEWID(),@Id,CompanyId,ID,DocType,DocSubType,DocumentState,DocCurrency,Round(GrandTotal,2) As DocAmount,Round(BalanceAmount,2) As DocBalanceAmount,@DocExchangeRate,Round(GrandTotal*@DocExchangeRate,2) As BaseAmount,Round(BalanceAmount*@DocExchangeRate,2) As BaseBalanceAmount,@System,@ApplicationDate,  -Round(@DetailCreditAmount,2) As DocAppliedAmount,-ROUND(@DetailCreditAmount*@DocExchangeRate,2)/*+isnull(@RoundingAmount,0)*/ As BaseAppliedAmount,@currentDate From Bean.Invoice(nolock) Where Id=@DocumentId
					End
					Else If(@DetailType='Debit Note')
					Begin
						--Here we are updating the modified by, modified date, balance amount, state and base balance amount
						Update Bean.DebitNote Set ModifiedBy=@System,ModifiedDate=@currentDate,BalanceAmount-=@DetailCreditAmount,DocumentState=@DocState,
						BaseBalanceAmount=@BaseBalance,RoundingAmount=0  Where CompanyId=@companyId and Id=@DocumentID and DocumentState<>'Void'

						--Journal State need to update

						Update J Set J.DocumentState=Inv.DocumentState,J.BalanceAmount=inv.BalanceAmount,J.ModifiedBy=Inv.ModifiedBy,J.ModifiedDate=inv.ModifiedDate from Bean.Journal J
						Join Bean.DebitNote Inv on inv.Id=J.DocumentId and j.CompanyId=@companyId and Inv.CompanyId=@companyId
							where J.DocumentId=@DocumentID and J.companyId=@companyId

						Update Bean.DocumentHistory set AgingState='Deleted' where DocumentId=@DocumentID and TransactionId=@Id and CompanyId=@companyId and AgingState is null

						Insert Into Bean.DocumentHistory(Id,TransactionId,CompanyId,DocumentId,DocType,DocSubType,DocState,DocCurrency,DocAmount,DocBalanaceAmount,ExchangeRate,BaseAmount,BaseBalanaceAmount,StateChangedBy,PostingDate,DocAppliedAmount,BaseAppliedAmount,StateChangedDate)

						Select NEWID(),@Id,CompanyId,Id,DocSubType,Nature,DocumentState,DocCurrency,Round(GrandTotal,2) As DocAmount,Round(BalanceAmount,2) As DocBalanceAmount,ExchangeRate,Round(GrandTotal*ExchangeRate,2) As BaseAmount,Round(BalanceAmount*ExchangeRate,2) As BaseBalanceAmount,@System,@ApplicationDate,  -Round(@DetailCreditAmount,2) As DocAppliedAmount,-ROUND(@DetailCreditAmount*ExchangeRate,2)/*+Isnull(@RoundingAmount,0)*/ As BaseAppliedAmount,@currentDate From Bean.DebitNote(nolock) Where Id=@DocumentId
					End
					

					Set @Count=@count+1;
				END


			END
		END


		Insert Into @BCDocumentHistoryType(TransactionId,CompanyId,DocumentId,DocType,DocSubType,DocState,DocCurrency,DocAmount,DocBalanaceAmount,ExchangeRate,BaseAmount,BaseBalanaceAmount,StateChangedBy,PostingDate,DocAppliedAmount,BaseAppliedAmount)

		
		Select @InvoiceId,CompanyId,@id,'Credit Note','Application','Posted',@DocCurrency,Round(CreditAmount,2) As DocAmount,Round(CreditAmount,2) As DocBalanceAmount,ExchangeRate,Round(CreditAmount*@Exchangerate,2) As BaseAmount,Round(CreditAmount*ExchangeRate,2) As BaseBalanceAmount,Case when @isadd=1 then usercreated else ModifiedBy End,@ApplicationDate,  Round(@CreditAmount,2) As DocAppliedAmount,ROUND(@CreditAmount*ExchangeRate,2) As BaseAppliedAmount From Bean.CreditNoteApplication Where Id=@Id and CompanyId=@companyId
				
		--Exec [dbo].[Bean_DocumentHistory] @BCDocumentHistoryType
				

		---Updateing The CreditNote DocumentState and Balanceamount
		Set @RoundingAmount=0;
		Set @OldRoundingAmount=0;
		Set @BalanceAmount=0;
		Select @DocumentGrandTotal=GrandTotal,@BaseBalance=BaseBalanceAmount,@DocExchangeRate=ExchangeRate,@OldRoundingAmount=RoundingAmount,@BaseGrandTotal=BaseGrandTotal,@BalanceAmount=BalanceAmount,@OldCNState=DocumentState from Bean.Invoice(nolock) where CompanyId=@companyId and DocSubType='Interco' and Id=@InvoiceId
		Set @BalanceAmount-=Case When @IsAdd=1 Then @CreditAmount Else Isnull(@CreditAmount,0)-Isnull(@OldCreditAmount,0)End;

		If(@IsAdd=1)--If add mode
		Begin
			
			IF(@DocumentGrandTotal=@DetailCreditAmount)
			Begin
				Set @RoundingAmount=Case When @OldRoundingAmount<>0 and @OldRoundingAmount is not null Then @OldRoundingAmount Else  Round(@CreditAmount*@Exchangerate,2)-@BaseGrandTotal End;
				Set @DocState=@FullyApplied
				Set @BaseBalance=0
			End
			Else
			Begin
				Set @BaseBalance -=Round((isnull(@CreditAmount,0)*@Exchangerate),2);
				Set @DocState=Case When @BalanceAmount=0 Then @FullyApplied Else @PartialApplied End
			End
		End
		Else
		Begin
			If(@OldCreditAmount<>@CreditAmount)
			Begin
				If(@BalanceAmount=0)--If the Credtit amount zero then
				Begin
					
					If(@CreditAmount=@DocumentGrandTotal)
					Begin
						Set @RoundingAmount=Case When @OldRoundingAmount<>0 and @OldRoundingAmount is not null Then @OldRoundingAmount Else  Round(@CreditAmount*@Exchangerate,2)-@BaseGrandTotal End;
						Set @DocState=@FullyApplied
						Set @BaseBalance=0
					End
					Else
					Begin
						Set @BaseBalance =0;
						Set @DocState=@FullyApplied;
					End
				End

				Else
				Begin
					Set @BaseBalance=Case When @OldCreditAmount>@CreditAmount Then @BaseBalance+ROUND(ABS(@OldCreditAmount-@CreditAmount)*@Exchangerate,2) Else @BaseBalance-ROUND(ABS(@OldCreditAmount-@CreditAmount)*@Exchangerate,2) End;
					Set @DocState=@PartialApplied
					If(@OldCNState=@FullyApplied and (@CNAppRoundingAmount<>0 or @CNAppRoundingAmount is not null))
					Begin
						Set @RoundingAmount=@CNAppRoundingAmount
					End
				End

			End
			Else
			Begin
				Set @DocState=@OldCNState
			End
			
		END


		Update Bean.Invoice Set ModifiedBy=@System,ModifiedDate=@currentDate,BalanceAmount=@BalanceAmount,DocumentState=@DocState,
		RoundingAmount= Case When @DocState=@PartialApplied Then @RoundingAmount Else 0 End,BaseBalanceAmount=@BaseBalance  Where CompanyId=@companyId and Id=@InvoiceId and DocumentState<>'Void'

		--Journal State need to update for Credit Note

		Update J Set J.DocumentState=Inv.DocumentState,J.BalanceAmount=inv.BalanceAmount,J.ModifiedBy=Inv.ModifiedBy,J.ModifiedDate=inv.ModifiedDate from Bean.Journal J
		Join Bean.Invoice Inv on inv.Id=J.DocumentId and j.CompanyId=@companyId and Inv.CompanyId=@companyId
		where J.DocumentId=@InvoiceId and J.companyId=@companyId


		Update Bean.CreditNoteApplication Set RoundingAmount=case when @DocState=@FullyApplied Then @RoundingAmount Else 0 End Where id=@Id and CompanyId=@companyId and InvoiceId=@InvoiceId

		Insert Into @BCDocumentHistoryType(TransactionId,CompanyId,DocumentId,DocType,DocSubType,DocState,DocCurrency,DocAmount,DocBalanaceAmount,ExchangeRate,BaseAmount,BaseBalanaceAmount,StateChangedBy,PostingDate,DocAppliedAmount,BaseAppliedAmount)

		Select @Id,CompanyId,@InvoiceId,DocType,DocSubType,DocumentState,DocCurrency,Round(GrandTotal,2) As DocAmount,Round(BalanceAmount,2) As DocBalanceAmount,ExchangeRate,/*Round(GrandTotal*ExchangeRate,2)*/Case When DocumentState=@NotApplied Then  BaseGrandTotal Else 0 End As BaseAmount, BaseBalanceAmount As BaseBalanceAmount,@System,@ApplicationDate,/*Round(GrandTotal,2)*/-@CreditAmount As DocAppliedAmount,-Round(@CreditAmount*@Exchangerate,2)+ISNULL(@RoundingAmount,0) As BaseAppliedAmount From Bean.Invoice(nolock) Where Id=@InvoiceId and CompanyId=@companyId
				
		Exec [dbo].[Bean_DocumentHistory] @BCDocumentHistoryType


		

		exec [dbo].[Bean_Interco_Billing_Process] @id,'Application',@companyId,@GUIDZero,0


		If(@IsReverseExcess=1)
		Begin
			Exec Bean_Multiple_Posting @companyId,@CreditNoteDoc,'Interco',@InvoiceId,@Id,1,0, ' '
		End
		
		If(@IsAdd=0 and (Select Id from Bean.CreditNoteApplicationDetail(nolock) where CreditNoteApplicationId=@Id and CreditAmount=0) is not null) 
		Begin
		Delete CNAD from Bean.CreditNoteApplication CNA Join Bean.CreditNoteApplicationDetail CNAD On CNA.Id=CNAD.CreditNoteApplicationId where CNA.CompanyId=@companyId and CNA.Id=@Id and CNA.InvoiceId=@InvoiceId
		and CNAD.CreditAmount=0
		END

		COMMIT TRANSACTION
	END TRY
	BEGIN CATCH
		ROLLBACK TRANSACTION
		SELECT 
        @ErrorMessage = ERROR_MESSAGE(), 
        @ErrorSeverity = ERROR_SEVERITY(), 
        @ErrorState = ERROR_STATE();
 
		-- return the error inside the CATCH block
		RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState);
	END CATCH
		
END
GO
