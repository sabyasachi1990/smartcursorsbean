USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[Bean_Insert_Document_History]    Script Date: 16-12-2024 9.20.10 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
 CREATE     procedure [dbo].[Bean_Insert_Document_History]
(
@CompanyId BigInt,
@DocumentId Uniqueidentifier,
@DocumentType nvarchar(50),
@IsVoid Bit
)
As Begin
     DECLARE  @ErrorMessage  NVARCHAR(4000),
             @ErrorSeverity INT,
             @ErrorState    INT;
     Declare @Nature Nvarchar(20), @DocDescription Nvarchar(500)
	 Declare @DocId Uniqueidentifier
	 Declare @serviceCompanyId BigInt
    Begin Try
        IF (@DocumentType='Invoice')--If document Type is Invoice
        Begin
            If Exists(Select ID from Bean.Invoice (NOLOCK) where CompanyId=@CompanyId and DocType=@DocumentType and Id=@DocumentId)
            Begin
                IF Exists(Select Id from Bean.DocumentHistory (NOLOCK) where DocumentId=@DocumentId AND TransactionId=@DocumentId and CompanyId=@companyId)
                BEGIN---If Eidt mode if we are modifying the record
                    Update Bean.DocumentHistory WITH (ROWLOCK) set AgingState='Deleted' where CompanyId=@companyId and DocumentId=@DocumentId and TransactionId=@DocumentId and AgingState is null
                    Insert Into Bean.DocumentHistory(Id,TransactionId,CompanyId,DocumentId,DocType,DocSubType,DocState,DocCurrency,DocAmount,DocBalanaceAmount,ExchangeRate,BaseAmount,BaseBalanaceAmount,StateChangedBy,StateChangedDate,PostingDate,DocAppliedAmount,BaseAppliedAmount)
                    Select NEWID(),@DocumentId,CompanyId,@DocumentId,DocType,DocSubType,DocumentState,DocCurrency,Round(GrandTotal,2) As DocAmount,Round(BalanceAmount,2) As DocBalanceAmount,ExchangeRate,Round(GrandTotal*ExchangeRate,2) As BaseAmount,Round(BalanceAmount*ExchangeRate,2) As BaseBalanceAmount,UserCreated,GETUTCDATE(),DocDate,Round(GrandTotal,2) AS DocAppliedAmount,Round(GrandTotal*ExchangeRate,2) As BaseAppliedAmount From Bean.Invoice (NOLOCK) Where Id=@DocumentId
                END
                ELSE
                BEGIN
                    Insert Into Bean.DocumentHistory(Id,TransactionId,CompanyId,DocumentId,DocType,DocSubType,DocState,DocCurrency,DocAmount,DocBalanaceAmount,ExchangeRate,BaseAmount,BaseBalanaceAmount,StateChangedBy,StateChangedDate,PostingDate,DocAppliedAmount,BaseAppliedAmount)
                    Select NEWID(),@DocumentId,CompanyId,@DocumentId,DocType,DocSubType,DocumentState,DocCurrency,Round(GrandTotal,2) As DocAmount,Round(BalanceAmount,2) As DocBalanceAmount,ExchangeRate,Round(GrandTotal*ExchangeRate,2) As BaseAmount,Round(BalanceAmount*ExchangeRate,2) As BaseBalanceAmount,UserCreated,GETUTCDATE(),DocDate,Round(GrandTotal,2) AS DocAppliedAmount,Round(GrandTotal*ExchangeRate,2) As BaseAppliedAmount From Bean.Invoice (NOLOCK) Where Id=@DocumentId
                END
            End
        End
        Else IF (@DocumentType='Bill') --If document Type is Bill
        Begin
            If (@IsVoid =1)
            Begin
                Select @DocumentId=Id  from Bean.Bill (NOLOCK) where PayrollId=@DocumentId and DocType=@DocumentType and CompanyId=@CompanyId
            End
            If EXISTS(Select id from Bean.Bill (NOLOCK) where id=@DocumentId and DocType=@DocumentType and CompanyId=@CompanyId)
            Begin
                Select @Nature=Nature,@DocDescription=DocDescription,@serviceCompanyId=ServiceCompanyId from Bean.Bill (NOLOCK) where Id=@DocumentId and DocType=@DocumentType and CompanyId=@CompanyId
                IF(@Nature='Interco' and @IsVoid <> 1)
                Begin
					If Not Exists(Select Ic.Id from Bean.InterCompanySetting IC (NOLOCK)
								Join Bean.InterCompanySettingDetail ICD (NOLOCK) on IC.Id=ICD.InterCompanySettingId
								Where Ic.CompanyId=@CompanyId and icd.ServiceEntityId=@serviceCompanyId and icd.Status=1)
					Begin
						RAISERROR ('Service Entity is not mapped in I/B Service Entity Mappings',16,1);
					End
                    Update Jd Set Jd.AccountDescription=@DocDescription from Bean.JournalDetail JD WITH (ROWLOCK)
                    join Bean.Journal J (NOLOCK) on JD.JournalId=J.Id 
                    where J.CompanyId=@CompanyId and J.DocType=@DocumentType and Jd.DocumentId=@DocumentId and IsTax=1
                    Update Bean.Journal WITH (ROWLOCK) Set DocumentDescription=@DocDescription  Where CompanyId=@CompanyId and DocType=@DocumentType and DocumentId=@DocumentId
                End
                Else
                Begin
                    If(@IsVoid=1)
                    Begin
                        Update Bean.Bill WITH (ROWLOCK) Set DocumentState='Void',DocNo=CONCAT(DocNo,'-V'),ModifiedBy='System',ModifiedDate=GETUTCDATE() where  id=@DocumentId and DocType=@DocumentType and CompanyId=@CompanyId and Nature='Interco'

 

                        Update Bean.Journal WITH (ROWLOCK) Set DocNo=CONCAT(DocNo,'-V'),DocumentState='Void',ModifiedBy='System',ModifiedDate=GETUTCDATE()  Where CompanyId=@CompanyId and DocType=@DocumentType and DocumentId=@DocumentId
                    End
                    
                End
                
                IF EXISTS(Select Id from Bean.DocumentHistory (NOLOCK) where CompanyId=@companyId and TransactionId=@DocumentId and    DocumentId = @DocumentId)
                BEGIN
                    Update Bean.DocumentHistory WITH (ROWLOCK) set AgingState='Deleted' where CompanyId=@CompanyId and DocumentId=@DocumentId and    TransactionId=@DocumentId and AgingState is null
                    Insert Into Bean.DocumentHistory    (Id,TransactionId,CompanyId,DocumentId,DocType,DocSubType,DocState,DocCurrency,DocAmount,DocBalanaceAmount,ExchangeRate ,BaseAmount,BaseBalanaceAmount,StateChangedBy,StateChangedDate,PostingDate,DocAppliedAmount,BaseAppliedAmount)
                    Select NEWID(),@DocumentId,CompanyId,@DocumentId,DocType,DocSubType,DocumentState,DocCurrency,Round(GrandTotal,2) As    DocAmount,Round(BalanceAmount,2) As DocBalanceAmount,ExchangeRate,Round(GrandTotal*ExchangeRate,2) As BaseAmount,Round (BalanceAmount*ExchangeRate,2) As BaseBalanceAmount,UserCreated,GETUTCDATE(),PostingDate,Round(GrandTotal,2) As     DocAppliedAmount,Round(GrandTotal*ExchangeRate,2) As BaseAppliedAmount From Bean.Bill (NOLOCK) Where Id=@DocumentId
                END
                ELSE
                BEGIN
                    Insert Into Bean.DocumentHistory    (Id,TransactionId,CompanyId,DocumentId,DocType,DocSubType,DocState,DocCurrency,DocAmount,DocBalanaceAmount,ExchangeRate ,BaseAmount,BaseBalanaceAmount,StateChangedBy,StateChangedDate,PostingDate,DocAppliedAmount,BaseAppliedAmount)
                    Select NEWID(),@DocumentId,CompanyId,@DocumentId,DocType,DocSubType,DocumentState,DocCurrency,Round(GrandTotal,2) As    DocAmount,Round(BalanceAmount,2) As DocBalanceAmount,ExchangeRate,Round(GrandTotal*ExchangeRate,2) As BaseAmount,Round (BalanceAmount*ExchangeRate,2) As BaseBalanceAmount,UserCreated,GETUTCDATE(),PostingDate,Round(GrandTotal,2) As     DocAppliedAmount,Round(GrandTotal*ExchangeRate,2) As BaseAppliedAmount From Bean.Bill (NOLOCK) Where Id=@DocumentId
                END
            End
        End--End of Document Type Bill
        Else IF @DocumentType='Application'-- Void of Interco CM app
		Begin
		Declare @CMId as uniqueidentifier,
				@BalanceAmount as money,
				@GrandTotal as money,
				@CreditAmount as money,
				@CNId as uniqueidentifier,
				@IsRevAccess bit,
				@tempBalAmount money=0,
				@RecCount int=0,@Count int=0,
				--@CMApplicationId uniqueidentifier,
				@Detailid uniqueidentifier,
				@DetailCreditAmount money,
				@DocExchangeRate decimal(15,10),
				@RoundingAmount money,
				@OldCreditAmount money,
				@CMAppId uniqueidentifier,
				@DetailDocId uniqueidentifier,
				@ApplicationDate DateTime2(7),
				@CmExchangeRate Decimal(15,10),
				@CmAppAmount Money,
				@DocCurrency Nvarchar(10)
		DECLARE @Temp Table (S_No Int identity(1,1),DetailId Uniqueidentifier, DocumentId Uniqueidentifier,CreditAmount money)
		Declare @BCDocumentHistoryType DocumentHistoryTableType
		---Constants

		Declare @System varchar(20)='System',
			@NotPaid varchar(10)='Not Paid',
			@PartialPaid varchar(20)='Partial Paid',
			@currentDate datetime2(7)=Getdate()

		---DocType Constants
		Declare @CreditMemoDoc nvarchar(20)='Credit Memo',
			@DocState_NotApplied nvarchar(20)='Not Applied',
			@DocState_PartialApplied nvarchar(20)='Partial Applied',
			@Void varchar(10)='Void'

	
			Select @CreditAmount=CN.CreditAmount,@CNId=CN.InvoiceId,@IsRevAccess=CN.IsRevExcess from Bean.CreditNoteApplication(nolock) CN where Id=@DocumentId

			Select @CMId=Id,@BalanceAmount=CM.BalanceAmount,@GrandTotal=CM.GrandTotal,@CmExchangeRate=ExchangeRate,@DocCurrency=DocCurrency from Bean.CreditMemo(nolock) CM where CM.ParentInvoiceID=@CNId and  CM.DocType=@CreditMemoDoc and CM.CompanyId=@CompanyId and Nature='Interco'

			Select @CMAppId=Id,@ApplicationDate=CreditMemoApplicationDate,@CmAppAmount=CreditAmount From Bean.CreditMemoApplication(nolock) where DocumentId=@DocumentId and CompanyId=@CompanyId and CreditMemoId=@CMId

			IF @CMId is not null AND @CMId<>'00000000-0000-0000-0000-000000000000'
			Begin
								
				IF Exists(Select Id from Bean.CreditMemoApplication(nolock) where CreditMemoId=@CMId and Id=@CMAppId and CompanyId=@CompanyId)
				Begin
					Update Bean.CreditMemoApplication WITH (ROWLOCK) set Status=2,ModifiedBy=@System,ModifiedDate=@currentDate,CreditMemoApplicationNumber=CONCAT(CreditMemoApplicationNumber,'-V') where CreditMemoId=@CMId and Id=@CMAppId and CompanyId=@CompanyId

					If(@IsRevAccess=1)
					Begin
						Update J Set J.DocumentState='Void',J.ModifiedBy=CMA.ModifiedBy,J.ModifiedDate=CMA.ModifiedDate from Bean.CreditMemoApplication CMA (NOLOCK) Join Bean.Journal J WITH (ROWLOCK) On J.DocumentId=CMA.Id
						Where J.DocumentId=@CMAppId and CMA.CompanyId=@CompanyId
					End

						--CM App documentHistory
						Insert Into @BCDocumentHistoryType(TransactionId,CompanyId,DocumentId,DocType,DocSubType,DocState,DocCurrency,DocAmount,DocBalanaceAmount,ExchangeRate,BaseAmount,BaseBalanaceAmount,StateChangedBy,PostingDate,DocAppliedAmount,BaseAppliedAmount)

		
						Select @CMId,CompanyId,@CMAppId,'Credit Memo','Application','Void',@DocCurrency,Round(CreditAmount,2) As DocAmount,Round(CreditAmount,2) As DocBalanceAmount,ExchangeRate,Round(CreditAmount*@CmExchangeRate,2) As BaseAmount,Round(CreditAmount*ExchangeRate,2) As BaseBalanceAmount,@System,@ApplicationDate,  0 As DocAppliedAmount,0 As BaseAppliedAmount From Bean.CreditMemoApplication (NOLOCK) Where Id=@CMAppId and CompanyId=@companyId
				
						--Exec [dbo].[Bean_DocumentHistory] @BCDocumentHistoryType

						SET @tempBalAmount=@BalanceAmount+@CreditAmount
						IF @GrandTotal=@tempBalAmount
						BEGIN
							Update Bean.CreditMemo WITH (ROWLOCK) set ModifiedBy=@System,ModifiedDate=@currentDate,BalanceAmount=@tempBalAmount,DocumentState=@DocState_NotApplied,BaseBalanceAmount=BaseGrandTotal where Id=@CMId and CompanyId=@CompanyId and ParentInvoiceID=@CNId
						END
						IF @GrandTotal != @tempBalAmount
						BEGIN
							Update Bean.CreditMemo WITH (ROWLOCK) set ModifiedBy=@System,ModifiedDate=@currentDate,BalanceAmount=@tempBalAmount,DocumentState=@DocState_PartialApplied,BaseBalanceAmount=BaseBalanceAmount+ROUND(@CreditAmount*@CmExchangeRate,2) where Id=@CMId and CompanyId=@CompanyId and ParentInvoiceID=@CNId
						END
						--Credit Memo Journal update
						Update J Set J.BalanceAmount=Cm.BalanceAmount,J.DocumentState=CM.DocumentState,J.ModifiedBy=Cm.ModifiedBy,J.ModifiedDate=CM.modifiedDate from Bean.CreditMemo CM (NOLOCK) Join Bean.Journal J WITH (ROWLOCK)
						on CM.Id=J.DocumentId and J.CompanyId=@CompanyId and CM.CompanyId=@CompanyId
						Where J.DocumentId=@CMId and J.CompanyId=@CompanyId and J.DocType=@CreditMemoDoc
						--Update Bean.Journal set ModifiedBy=@System,ModifiedDate=@currentDate,BalanceAmount=@tempBalAmount,DocumentState=Case When @GrandTotal=@tempBalAmount Then @DocState_NotApplied Else @DocState_PartialApplied END where CompanyId=@CompanyId and DocumentId=@CMId

						--CM docuemnt History
						Insert Into @BCDocumentHistoryType(TransactionId,CompanyId,DocumentId,DocType,DocSubType,DocState,DocCurrency,DocAmount,DocBalanaceAmount,ExchangeRate,BaseAmount,BaseBalanaceAmount,StateChangedBy,PostingDate,DocAppliedAmount,BaseAppliedAmount)

						Select @CMAppId,CompanyId,@CMId,DocType,DocSubType,DocumentState,DocCurrency,Round(GrandTotal,2) As DocAmount,Round(BalanceAmount,2) As DocBalanceAmount,ExchangeRate,/*Round(GrandTotal*ExchangeRate,2)*/Case When DocumentState=@DocState_NotApplied Then  BaseGrandTotal Else 0 End As BaseAmount, BaseBalanceAmount As BaseBalanceAmount,@System,@ApplicationDate,/*Round(GrandTotal,2)*/-@CreditAmount As DocAppliedAmount,-Round(@CreditAmount*@CmExchangeRate,2)+ISNULL(@RoundingAmount,0) As BaseAppliedAmount From Bean.CreditMemo (NOLOCK) Where Id=@CMId and CompanyId=@CompanyId
				
						--Exec [dbo].[Bean_DocumentHistory] @BCDocumentHistoryType
					IF @IsVoid=1 AND (@IsRevAccess=0 OR @IsRevAccess is NULL)
					BEGIN
						Insert Into @Temp
						Select Id,DocumentId,CreditAmount From Bean.CreditMemoApplicationDetail(nolock) Where CreditMemoApplicationId=@CMAppId Order By RecOrder
						Select @RecCount=Count(*) From @Temp
						Set @Count=1
						While @RecCount>=@Count
						Begin
							Select @Detailid= DetailId,@DetailDocId=DocumentId,@DetailCreditAmount=CreditAmount From @Temp Where S_No=@Count
							Set @BalanceAmount=0
							If Exists(Select Id from Bean.CreditMemoApplicationDetail (NOLOCK) where Id=@Detailid)
							Begin
								Select @RoundingAmount=ISNULL(RoundingAmount,0),@OldCreditAmount=CreditAmount from Bean.CreditMemoApplicationDetail(nolock) where Id=@Detailid 

								Select @DocExchangeRate=ISNULL(ExchangeRate,1),@BalanceAmount=BalanceAmount from Bean.Bill (NOLOCK) where CompanyId=@companyId and id=@DetailDocId
								Set @BalanceAmount+=@OldCreditAmount
								Update Bean.Bill WITH (ROWLOCK) Set ModifiedBy=@System,ModifiedDate=@currentDate,DocumentState=Case When @BalanceAmount=GrandTotal Then @NotPaid Else @PartialPaid End,BalanceAmount=@BalanceAmount,BaseBalanceAmount+=ROUND(@OldCreditAmount*@DocExchangeRate,2),RoundingAmount=Case when @RoundingAmount<>0 Then @RoundingAmount Else RoundingAmount End Where CompanyId=@companyId and Id=@DetailDocId and DocumentState<>@Void

								--Journal State need to update

								Update J Set J.DocumentState=B.DocumentState,J.BalanceAmount=B.BalanceAmount,J.ModifiedBy=B.ModifiedBy,J.ModifiedDate=B.ModifiedDate from Bean.Journal J WITH (ROWLOCK)
								Join Bean.Bill B (NOLOCK) on B.Id=J.DocumentId and j.CompanyId=@companyId and B.CompanyId=@companyId
								where J.DocumentId=@DetailDocId and J.companyId=@companyId

								--Bill document History updation

								Insert Into @BCDocumentHistoryType(TransactionId,CompanyId,DocumentId,DocType,DocSubType,DocState,DocCurrency,DocAmount,DocBalanaceAmount,ExchangeRate,BaseAmount,BaseBalanaceAmount,StateChangedBy,PostingDate,DocAppliedAmount,BaseAppliedAmount)

								Select @CMAppId,CompanyId,@DetailDocId,DocType,DocSubType,DocumentState,DocCurrency,Round(GrandTotal,2) As DocAmount,Round(BalanceAmount,2) As DocBalanceAmount,ExchangeRate,Case When DocumentState=@DocState_NotApplied Then  BaseGrandTotal Else 0 End As BaseAmount, BaseBalanceAmount As BaseBalanceAmount,@System,@ApplicationDate,0 As DocAppliedAmount,0  As BaseAppliedAmount From Bean.Bill(nolock) Where Id=@DetailDocId and companyId=@companyId
				
								

						 
							End
							Set @Count=@count+1;
						End
					END
					Exec [dbo].[Bean_DocumentHistory] @BCDocumentHistoryType
				END
			END

		End



		Else If(@DocumentType='Credit Memo')
		Begin
			

			

			If(@IsVoid=1)
			Begin
				If Exists(Select ID from Bean.CreditMemo (NOLOCK) where CompanyId=@CompanyId and DocType=@DocumentType and ParentInvoiceID=@DocumentId and DocumentState='Not Applied')
				Begin
					Select @DocId=Id,@serviceCompanyId=ServiceCompanyId from Bean.CreditMemo (NOLOCK) where CompanyId=@CompanyId and DocType=@DocumentType and ParentInvoiceID=@DocumentId and DocumentState='Not Applied' 
					Update Bean.CreditMemo WITH (ROWLOCK) set DocNo=Concat(DocNo,'-V'),DocumentState='Void',ModifiedDate=GETUTCDATE(),ModifiedBy='System' where CompanyId=@CompanyId and DocType=@DocumentType and ParentInvoiceID=@DocumentId

					Update Bean.Journal WITH (ROWLOCK) Set DocNo=CONCAT(DocNo,'-V'),DocumentState='Void',ModifiedBy='System',ModifiedDate=GETUTCDATE()  Where CompanyId=@CompanyId and DocType=@DocumentType and DocumentId=@DocId
				End
			End
			Else
			Begin
				Select @DocId=Id,@serviceCompanyId=ServiceCompanyId,@DocDescription=DocDescription from Bean.CreditMemo (NOLOCK) where CompanyId=@CompanyId and DocType=@DocumentType and Id=@DocumentId and DocumentState='Not Applied'
				If Not Exists(Select Ic.Id from Bean.InterCompanySetting IC (NOLOCK)
								Join Bean.InterCompanySettingDetail ICD (NOLOCK) on IC.Id=ICD.InterCompanySettingId
								Where Ic.CompanyId=@CompanyId and icd.ServiceEntityId=@serviceCompanyId and icd.Status=1)
					Begin
						RAISERROR ('Service Entity is not mapped in I/B Service Entity Mappings',16,1);
					End
                    Update Jd Set Jd.AccountDescription=@DocDescription from Bean.JournalDetail JD WITH (ROWLOCK)
                    join Bean.Journal J on JD.JournalId=J.Id 
                    where J.CompanyId=@CompanyId and J.DocType=@DocumentType and Jd.DocumentId=@DocId and IsTax=1

                    Update Bean.Journal WITH (ROWLOCK) Set DocumentDescription=@DocDescription  Where CompanyId=@CompanyId and DocType=@DocumentType and DocumentId=@DocId
			End

			
			 
                IF Exists(Select Id from Bean.DocumentHistory (NOLOCK) where DocumentId=@DocId AND TransactionId=@DocId and CompanyId=@companyId)
                BEGIN---If Edit mode if we are modifying the record
                    Update Bean.DocumentHistory WITH (ROWLOCK) set AgingState='Deleted' where CompanyId=@companyId and DocumentId=@DocId and TransactionId=@DocId and AgingState is null

                    Insert Into Bean.DocumentHistory(Id,TransactionId,CompanyId,DocumentId,DocType,DocSubType,DocState,DocCurrency,DocAmount,DocBalanaceAmount,ExchangeRate,BaseAmount,BaseBalanaceAmount,StateChangedBy,StateChangedDate,PostingDate,DocAppliedAmount,BaseAppliedAmount)
                    Select NEWID(),@DocId,CompanyId,@DocId,DocType,DocSubType,DocumentState,DocCurrency,Round(GrandTotal,2) As DocAmount,Round(BalanceAmount,2) As DocBalanceAmount,ExchangeRate,Round(GrandTotal*ExchangeRate,2) As BaseAmount,Round(BalanceAmount*ExchangeRate,2) As BaseBalanceAmount,ModifiedBy,GETUTCDATE(),DocDate
					--,Round(GrandTotal,2) AS DocAppliedAmount
					--,Round(GrandTotal*ExchangeRate,2) As BaseAppliedAmount 
					,null,null From Bean.CreditMemo(Nolock) Where  Id=@DocId and CompanyId=@CompanyId
                END
                ELSE
                BEGIN
                    Insert Into Bean.DocumentHistory(Id,TransactionId,CompanyId,DocumentId,DocType,DocSubType,DocState,DocCurrency,DocAmount,DocBalanaceAmount,ExchangeRate,BaseAmount,BaseBalanaceAmount,StateChangedBy,StateChangedDate,PostingDate,DocAppliedAmount,BaseAppliedAmount)
                    Select NEWID(),@DocId,CompanyId,@DocId,DocType,DocSubType,DocumentState,DocCurrency,Round(GrandTotal,2) As DocAmount,Round(BalanceAmount,2) As DocBalanceAmount,ExchangeRate,Round(GrandTotal*ExchangeRate,2) As BaseAmount,Round(BalanceAmount*ExchangeRate,2) As BaseBalanceAmount,UserCreated,GETUTCDATE(),DocDate
					--,Round(GrandTotal,2) AS DocAppliedAmount
					--,Round(GrandTotal*ExchangeRate,2) As BaseAppliedAmount 
					,null,null From Bean.CreditMemo (NOLOCK) Where Id=@DocId and CompanyId=@CompanyId
                END
           
		End
    End Try
    Begin Catch
        SELECT
        @ErrorMessage = ERROR_MESSAGE(),
        @ErrorSeverity = ERROR_SEVERITY(),
        @ErrorState = ERROR_STATE();
        -- return the error inside the CATCH block
        RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState);
    End Catch
End

GO
