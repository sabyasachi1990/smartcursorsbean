USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[Bean_Save_Interco_invoice]    Script Date: 16-12-2024 9.20.10 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE   Procedure [dbo].[Bean_Save_Interco_invoice]
(
@document DocumentType Readonly,
@documentDetail DocumentDetailType Readonly,
@CreditNoteApp CreditNoteApplication Readonly,
@CreditNoteAppDetial CreditNoteApplicationDetail Readonly
)
AS
BEGIN
	Declare @companyId BIGINT
	Declare @DocumentId UNIQUEIDENTIFIER
	Declare @currentDate DATETIME2(7)=GETUTCDATE()
	Declare @BillServiceEntityId Bigint, @BillEntityId UNIQUEIDENTIFIER, @ServiceEntityId BigInt
	--Declare @invoiceId UNIQUEIDENTIFIER
	Declare @RecordStatus Nvarchar(20)
	Declare @isDocNoEditable bit,	
			@docNo NvarChar(200)
	DECLARE  @ErrorMessage  NVARCHAR(4000), 
			 @ErrorSeverity INT, 
			 @ErrorState    INT;
	Declare @OldGrandTotal money, @DocState nvarchar(30), @NewGrandTotal money, @Exchangerate decimal(15,10),@BillState nvarchar(30), @COACount int,@DocType Nvarchar(25)
	Declare @CreditNote nvarchar(20)='Credit Note', @Invoice nvarchar(20)='Invoice',@DebitNote Nvarchar(20)='Debit Note',@billId UniqueIdentifier
	--Declare @IsGstSettings Bit
	BEGIN TRY
		Begin Transaction ---Begin the Transaction

		--SET @invoiceId=NEWID()
		
		Select @DocumentId=Id, @companyId=CompanyId,@BillEntityId=EntityId,@ServiceEntityId=ServiceCompanyId,@NewGrandTotal=GrandTotal,@Exchangerate=Isnull(ExchangeRate,1),@DocType=DocType,@docNo=DocNo from @document
		Select @BillServiceEntityId=ServiceEntityId from Bean.Entity where CompanyId=@companyId and id=@BillEntityId

		Set @COACount= (select COUNT(distinct COAID) from @documentDetail)

		If ((Select DocumentState from Bean.Invoice(Nolock) where Id=@DocumentId and DocumentState='Void' and CompanyId=@companyId and DocType=@DocType)='Void')
		Begin
			RAISERROR ('The State of the transaction has been changed, you cannot save this record.',16,1);
		End
		
		IF((Select COUNT(*) from Bean.InterCompanySetting(Nolock) inter 
		join Bean.InterCompanySettingDetail(Nolock) interDetail on inter.Id=interDetail.InterCompanySettingId 
		where inter.CompanyId=@companyId and inter.InterCompanyType='Billing' and interDetail.Status=1 and interDetail.ServiceEntityId In (@BillServiceEntityId,@ServiceEntityId))<>2)
		BEGIN
			RAISERROR ('Service Entity is not mapped in I/B Service Entity Mappings',16,1);
		END
		IF (@COACount<>( SELECT Count(COAMap.Id) FROM Bean.COAMapping(Nolock) COAMap 
		 join Bean.COAMappingDetail(Nolock) COAMDetail on COAMDetail.COAMappingId=COAMap.Id
		 WHERE COAMap.CompanyId=@companyId and COAMDetail.CustCOAId  IN (Select distinct COAID from @documentDetail) and COAMDetail.Status=1))
		BEGIN
			RAISERROR ('Chart Of Account is not mapped in I/B COA Mappings',16,1);
		END
		IF((Select IsGstSettings from @document)=1 and (Select Count(Distinct TaxId) from @documentDetail where TaxIdcode<>'NA' and( RecordStatus is null or RecordStatus='Modified')) >0)
		BEGIN
			IF NOT EXISTS(SELECT TaxCodeMap.Id from Bean.TaxCodeMapping TaxCodeMap with (Nolock)
			JOIN Bean.TaxCodeMappingDetail TaxCodeMapDetail  with (Nolock) On TaxCodeMap.Id=TaxCodeMapDetail.TaxCodeMappingId
			JOIN Bean.TaxCode TXC with (nolock) on TXC.Code=TaxCodeMapDetail.CustTaxCode
			WHERE TaxCodeMap.CompanyId=@companyId and TXC.Id IN(Select TaxId from @documentDetail where TaxIdcode<>'NA' and( RecordStatus is null or RecordStatus='Modified')))
			BEGIN
				RAISERROR ('Taxcode is not mapped in I/B Taxcode Mappings',16,1);
			END
		END
		--Newly added for the taxcode inactivation purpose
			IF((select Status from common.GSTSetting(nolock) where CompanyId=@companyId and ServiceCompanyId=@BillServiceEntityId)=1 and (Select IsGstSettings from @document)=1)
			BEGIN
				If Exists(Select id from Bean.taxcode where companyid=@companyId and Status=2 and code in (SELECT TaxCodeMapDetail.VenTaxCode from Bean.TaxCodeMapping(Nolock) TaxCodeMap
				join Bean.TaxCodeMappingDetail(Nolock) TaxCodeMapDetail On TaxCodeMap.Id=TaxCodeMapDetail.TaxCodeMappingId WHERE TaxCodeMap.CompanyId=@companyId and TaxCodeMapDetail.CustTaxId IN(Select TaxId from @documentDetail where TaxIdcode<>'NA' and( RecordStatus is null or RecordStatus='Modified'  or RecordStatus='Added'))))
				BEGIN
					RAISERROR ('Taxcode(s) mapped under I/B taxcode mapping are in Inactive state in Bean Taxcodes.',16,1);
				END
				--if exists(SELECT TaxCodeMap.Id from Bean.TaxCodeMapping(Nolock) TaxCodeMap
				--join Bean.TaxCodeMappingDetail(Nolock) TaxCodeMapDetail On TaxCodeMap.Id=TaxCodeMapDetail.TaxCodeMappingId
				--Join Bean.TaxCode tax on tax.Code=TaxCodeMapDetail.VenTaxCode and tax.CompanyId=@companyId
				-- WHERE TaxCodeMap.CompanyId=@companyId and TaxCodeMapDetail.CustTaxId IN(Select TaxId from @documentDetail where TaxIdcode<>'NA' and( RecordStatus is null or RecordStatus='Modified')) and tax.Status=2)
				-- BEGIN
				--	RAISERROR ('Ven taxcode is not activated in taxcode screen',16,1);
				--END
				
			END
		---End of tax code inactivation	
		Set @BillEntityId=(select id from Bean.Entity(Nolock) where ServiceEntityId=@ServiceEntityId)
		
		If(@DocType=@DebitNote)
		Begin
			IF Exists(Select Id from Bean.DebitNote(Nolock) where Id=@DocumentId and CompanyId=@companyId)
			BEGIN----IF Exists then update
				Select @OldGrandTotal=BalanceAmount, @DocState=DocumentState from Bean.DebitNote(Nolock) where Id=@DocumentId and CompanyId=@companyId

				
					If (@DocState<>'Not Paid' and @OldGrandTotal<>@NewGrandTotal)
					Begin
						RAISERROR ('The State of the transaction has been changed, kindly refresh to proceed.',16,1);
					End
					If((Select ClearingState from Bean.DebitNoteDetail(Nolock) where DebitNoteId=@DocumentId and ClearingState='Cleared')='Cleared')
					Begin
						RAISERROR ('The State of the transaction has been changed, kindly refresh to proceed.',16,1);
					End

					select @billId=Id,@BillState=DocumentState from Bean.Bill(Nolock) where payrollid=@DocumentId and companyid=@companyId
					If(@billId is not null and @BillState<>@DocState)
					Begin
						RAISERROR ('The Corresponding Bill state has been changed.',16,1);
					End
					--Doc no veryfying
					If Exists(Select DocNo from Bean.Bill(Nolock) where CompanyId=@companyId and ID<>@billId and EntityId=@BillEntityId and DocNo=@docNo and DocumentState<>'Void' and DocSubType<>'Payroll')
					Begin
						RAISERROR ('Document number already exist in Bill.',16,1);
					End
				
				
			
				Update DN SET DN.ServiceCompanyId=doc.ServiceCompanyId,DN.EntityId=doc.EntityId,DN.DocNo=doc.DocNo,DN.ExchangeRate=doc.ExchangeRate,DN.GSTExchangeRate=doc.GSTExchangeRate,DN.DocCurrency=doc.DocCurrency,DN.DocDate=doc.DocDate,DN.DueDate=doc.DueDate,DN.CreditTermsId=doc.CreditTermsId,DN.PONo=doc.PONo,DN.Remarks=doc.DocDescription,DN.NoSupportingDocs=doc.NoSupportingDocs,DN.IsNoSupportingDocument=doc.NoSupportingDocs,DN.BalanceAmount= Case When (doc.DocumentState='Not Paid' ) Then doc.GrandTotal Else DN.BalanceAmount End, DN.GrandTotal=doc.GrandTotal,DN.ModifiedBy=doc.ModifiedBy,DN.ModifiedDate=@currentDate,DN.IsMultiCurrency=doc.IsMultiCurrency,DN.IsGstSettings=doc.IsGstSettings,DN.IsGSTApplied=doc.IsGSTApplied,DN.IsAllowableNonAllowable=doc.IsAllowableNonAllowable,DN.Nature=doc.Nature,DN.IsBaseCurrencyRateChanged=doc.IsBaseCurrencyRateChanged,DN.IsGSTCurrencyRateChanged=doc.IsGSTCurrencyRateChanged from Bean.DebitNote(Nolock) DN Join @document doc On DN.Id=doc.id

				------RecordStatus is Modified
				IF Exists(Select Id from @documentDetail where RecordStatus is null)
				BEGIN
					Update DNDetail SET DNDetail.AccountDescription=docDetail.ItemDescription, DNDetail.COAId=docDetail.COAId,DNDetail.TaxId=docDetail.TaxId,DNDetail.TaxRate=docDetail.TaxRate,DNDetail.TaxIdCode=docDetail.TaxIdCode,DNDetail.DocAmount=docDetail.DocAmount,DNDetail.DocTaxAmount=docDetail.DocTaxAmount,DNDetail.DocTotalAmount=docDetail.DocTotalAmount,
					DNDetail.BaseAmount=ROUND(docDetail.DocAmount*@Exchangerate,2),
					DNDetail.BaseTaxAmount=ROUND(Isnull(docDetail.DocTaxAmount,0)*@Exchangerate,2),
					DNDetail.BaseTotalAmount=ROUND(docDetail.DocAmount*@Exchangerate,2)+ROUND(Isnull(docDetail.DocTaxAmount,0)*@Exchangerate,2)/*,invDetail.IsPLAccount=docDetail.IsPLAccount*/ from Bean.DebitNoteDetail(Nolock) DNDetail 
					Join @documentDetail docDetail on DNDetail.Id=docDetail.Id where docDetail.RecordStatus is null
				END

				------RecordStatus is Added
				IF EXISTS(Select Id from @documentDetail where RecordStatus='Added')
				BEGIN
					Insert Into Bean.DebitNoteDetail(Id,DebitNoteId,COAId,TaxId,TaxRate,DocAmount,DocTaxAmount,DocTotalAmount,BaseAmount,BaseTaxAmount,BaseTotalAmount,TaxIdCode,RecOrder,AccountDescription)
					Select NEWID(),@DocumentId,detail.COAId,detail.TaxId,detail.TaxRate,detail.DocAmount,detail.DocTaxAmount,detail.DocTotalAmount,
					ROUND(detail.DocAmount*@Exchangerate,2),
					ROUND(Isnull(detail.DocTaxAmount,0)*@Exchangerate,2),
					ROUND(detail.DocAmount*@Exchangerate,2)+ROUND(Isnull(detail.DocTaxAmount,0)*@Exchangerate,2)/*,detail.IsPLAccount*/,
					detail.TaxIdCode,
					--ROW_NUMBER() over (ORDER BY detail.id) 
					(Select MAX(RecOrder)+1 from Bean.DebitNoteDetail(nolock) where DebitNoteId=@DocumentId),
					ItemDescription
					from @documentDetail detail where detail.RecordStatus='Added'
				END

				------RecordStatus is Deleted
				IF EXISTS(Select Id from @documentDetail where RecordStatus='Deleted')
				BEGIN
					Delete DNDetail from Bean.DebitNoteDetail DNDetail 
					join @documentDetail docDetail on DNDetail.ID=docDetail.Id where docDetail.RecordStatus='Deleted'
				END
			
			END------End of IF Exists
			ELSE ---IF Not Exists
			BEGIN---Beging OF insertion
			
				---Doc no checking
				Set @isDocNoEditable=(Select IsEditable from Common.AutoNumber(Nolock) where CompanyId=@companyId and EntityType=@DocType and ModuleMasterId in (select id from Common.ModuleMaster(nolock) where Name='Bean Cursor'))
				IF(@isDocNoEditable=1)
				BEGIN
					Set @docNo=(select DocNo from @document)
				END
				Else
				BEGIN
					--Declare @SpDocNo NvarChar(100)
					Exec Common_GenerateDocNo @companyId,'Bean Cursor',@DocType,0,@docNo out
					--Set @docNo='CN-2020-00033'
				END

				---Doc no verifying
				
				If Exists(Select DocNo from Bean.Bill(Nolock) where CompanyId=@companyId and EntityId=@BillEntityId and DocNo=@docNo and DocumentState<>'Void' and DocSubType<>'Payroll')
				Begin
					RAISERROR ('Document number already exist in Bill.',16,1);
				End

			
				Insert Into Bean.DebitNote(Id,CompanyId,ServiceCompanyId,EntityId,DocNo,DocSubType,Nature,IsNoSupportingDocument,NoSupportingDocs,IsAllowableNonAllowable,CreditTermsId,DocCurrency,ExchangeRate,ExCurrency,GSTExchangeRate,GSTExCurrency,DocumentState,BalanceAmount,GSTTotalAmount,GrandTotal,IsGstSettings,IsGSTApplied,UserCreated,CreatedDate,ModifiedBy,ModifiedDate,Remarks,DocDate,DueDate,PONo,EntityType,IsMultiCurrency,IsBaseCurrencyRateChanged,IsGSTCurrencyRateChanged,IsSegmentReporting)

				Select @DocumentId, doc.CompanyId, doc.ServiceCompanyId, doc.EntityId, @docNo, @DocType, 'Interco',doc.IsNoSupportingDocument, doc.NoSupportingDocs, doc.IsAllowableNonAllowable, doc.CreditTermsId, doc.DocCurrency, doc.ExchangeRate, doc.BaseCurrency, doc.GSTExchangeRate, doc.GSTCurrency, IsNull(doc.DocumentState,'Not Paid'), doc.GrandTotal, doc.GSTTotalAmount, doc.GrandTotal, doc.IsGstSettings, doc.IsGSTApplied, doc.UserCreated, @currentDate,null,null,doc.DocDescription, doc.DocDate,doc.DueDate,doc.PONo,'Customer',doc.IsMultiCurrency,doc.IsBaseCurrencyRateChanged,IsGSTCurrencyRateChanged,0 from @document doc

				Insert Into Bean.DebitNoteDetail(Id,DebitNoteId,COAId,TaxId,TaxRate,DocAmount,DocTaxAmount,DocTotalAmount,BaseAmount,BaseTaxAmount,BaseTotalAmount,TaxIdCode,RecOrder,AccountDescription)
					Select NEWID(),@DocumentId,detail.COAId,detail.TaxId,detail.TaxRate,detail.DocAmount,detail.DocTaxAmount,detail.DocTotalAmount,
					ROUND(detail.DocAmount*@Exchangerate,2),
					ROUND(Isnull(detail.DocTaxAmount,0)*@Exchangerate,2),
					ROUND(detail.DocAmount*@Exchangerate,2)+ROUND(Isnull(detail.DocTaxAmount,0)*@Exchangerate,2),
					detail.TaxIdCode,
					detail.RecOrder,
					ItemDescription
					from @documentDetail detail 

				
			END-----End OF Insertion

			
		End
		Else
		Begin
			IF Exists(Select Id from Bean.Invoice(Nolock) where Id=@DocumentId and CompanyId=@companyId)
			BEGIN----IF Exists then update
			Select @OldGrandTotal=BalanceAmount, @DocState=DocumentState from Bean.Invoice(Nolock) where Id=@DocumentId and CompanyId=@companyId

			IF(@DocType=@Invoice)
			Begin
				If (@DocState<>'Not Paid' and @OldGrandTotal<>@NewGrandTotal)
				Begin
					RAISERROR ('The State of the transaction has been changed, kindly refresh to proceed.',16,1);
				End
				If((Select ClearingState from Bean.InvoiceDetail(Nolock) where InvoiceId=@DocumentId and ClearingState='Cleared')='Cleared')
				Begin
					RAISERROR ('The State of the transaction has been changed, kindly refresh to proceed.',16,1);
				End

				select @billId=Id,@BillState=DocumentState from Bean.Bill(Nolock) where payrollid=@DocumentId and companyid=@companyId
				If(@billId is not null and @BillState<>@DocState)
				Begin
					RAISERROR ('The Corresponding Bill state has been changed.',16,1);
				End
				--Doc no veryfying
				If Exists(Select DocNo from Bean.Bill(Nolock) where CompanyId=@companyId and ID<>@billId and EntityId=@BillEntityId and DocNo=@docNo and DocumentState<>'Void' and DocSubType<>'Payroll')
				Begin
					RAISERROR ('Document number already exist in Bill.',16,1);
				End
			End
			Else If(@DocType=@CreditNote)
			Begin
				If (@DocState<>'Not Applied' and @OldGrandTotal<>@NewGrandTotal)
				Begin
					RAISERROR ('The State of the transaction has been changed, kindly refresh to proceed.',16,1);
				End
				If((Select ClearingState from Bean.InvoiceDetail(Nolock) where InvoiceId=@DocumentId and ClearingState='Cleared')='Cleared')
				Begin
					RAISERROR ('The State of the transaction has been changed, kindly refresh to proceed.',16,1);
				End

				
				select @billId=Id,@BillState=DocumentState from Bean.CreditMemo(Nolock) where ParentInvoiceID=@DocumentId and companyid=@companyId
				If(@billId is not null and @BillState<>@DocState)
				Begin
					RAISERROR ('The Corresponding CreditMemo state has been changed.',16,1);
				End
				--Doc no veryfying
				If Exists(Select DocNo from Bean.CreditMemo(Nolock) where CompanyId=@companyId and ID<>@billId and EntityId=@BillEntityId and DocNo=@docNo and DocumentState<>'Void' )
				Begin
					RAISERROR ('Document number already exist in Credit Memo.',16,1);
				End

			End
			
			Update INV SET inv.ServiceCompanyId=doc.ServiceCompanyId,inv.EntityId=doc.EntityId,inv.DocNo=doc.DocNo,inv.ExchangeRate=doc.ExchangeRate,inv.GSTExchangeRate=doc.GSTExchangeRate,inv.DocCurrency=doc.DocCurrency,inv.DocDate=doc.DocDate,inv.DueDate=doc.DueDate,inv.CreditTermsId=doc.CreditTermsId,inv.PONo=doc.PONo,inv.DocDescription=doc.DocDescription,inv.NoSupportingDocs=doc.NoSupportingDocs,inv.IsNoSupportingDocument=doc.NoSupportingDocs,inv.BalanceAmount= Case When (doc.DocumentState='Not Paid' Or Doc.DocumentState='Not Applied') Then doc.GrandTotal Else inv.BalanceAmount End, inv.GrandTotal=doc.GrandTotal,inv.InvoiceNumber=doc.DocNo,inv.ModifiedBy=doc.ModifiedBy,inv.ModifiedDate=@currentDate,inv.IsMultiCurrency=doc.IsMultiCurrency,inv.IsGstSettings=doc.IsGstSettings,inv.IsGSTApplied=doc.IsGSTApplied,inv.IsAllowableNonAllowable=doc.IsAllowableNonAllowable,inv.Nature=doc.Nature,inv.DocSubType=doc.DocSubType,INV.IsBaseCurrencyRateChanged=doc.IsBaseCurrencyRateChanged,inv.IsGSTCurrencyRateChanged=doc.IsGSTCurrencyRateChanged from Bean.Invoice(Nolock) INV Join @document doc On inv.Id=doc.id

			------RecordStatus is Modified
			IF Exists(Select Id from @documentDetail where RecordStatus is null)
			BEGIN
				Update invDetail SET invDetail.ItemId=docDetail.ItemId,invDetail.ItemCode=docDetail.ItemCode,invDetail.ItemDescription=docDetail.ItemDescription,invDetail.Qty=docDetail.Qty,invDetail.Unit=docDetail.Unit,invDetail.UnitPrice=docDetail.UnitPrice,invDetail.Discount=docDetail.Discount,invDetail.DiscountType=docDetail.DiscountType,invDetail.COAId=docDetail.COAId,invDetail.TaxId=docDetail.TaxId,invDetail.TaxRate=docDetail.TaxRate,invDetail.TaxIdCode=docDetail.TaxIdCode,invDetail.DocAmount=docDetail.DocAmount,invDetail.DocTaxAmount=docDetail.DocTaxAmount,invDetail.DocTotalAmount=docDetail.DocTotalAmount,
				invDetail.BaseAmount=ROUND(docDetail.DocAmount*@Exchangerate,2),
				invDetail.BaseTaxAmount=ROUND(Isnull(docDetail.DocTaxAmount,0)*@Exchangerate,2),
				invDetail.BaseTotalAmount=ROUND(docDetail.DocAmount*@Exchangerate,2)+ROUND(Isnull(docDetail.DocTaxAmount,0)*@Exchangerate,2)/*,invDetail.IsPLAccount=docDetail.IsPLAccount*/ from Bean.InvoiceDetail(Nolock) invDetail 
				Join @documentDetail docDetail on invDetail.Id=docDetail.Id where docDetail.RecordStatus is null
			END

			------RecordStatus is Added
			IF EXISTS(Select Id from @documentDetail where RecordStatus='Added')
			BEGIN
				Insert Into Bean.InvoiceDetail(Id,InvoiceId,ItemId,ItemCode,ItemDescription,Qty,Unit,UnitPrice,Discount,DiscountType,COAId,TaxId,TaxRate,DocAmount,DocTaxAmount,DocTotalAmount,BaseAmount,BaseTaxAmount,BaseTotalAmount,TaxIdCode,AmtCurrency,RecOrder,Remarks)
				Select NEWID(),@DocumentId,detail.ItemId,detail.ItemCode,detail.ItemDescription,detail.Qty,detail.Unit,detail.UnitPrice,detail.Discount,detail.DiscountType,detail.COAId/*,detail.AllowDisAllow*/,detail.TaxId,detail.TaxRate,detail.DocAmount,detail.DocTaxAmount,detail.DocTotalAmount,
				ROUND(detail.DocAmount*@Exchangerate,2),
				ROUND(Isnull(detail.DocTaxAmount,0)*@Exchangerate,2),
				ROUND(detail.DocAmount*@Exchangerate,2)+ROUND(Isnull(detail.DocTaxAmount,0)*@Exchangerate,2)/*,detail.IsPLAccount*/,
				detail.TaxIdCode,detail.AmtCurrency,
				--ROW_NUMBER() over (ORDER BY detail.id) 
				(Select MAX(RecOrder)+1 from Bean.InvoiceDetail where InvoiceId=@DocumentId),
				ItemDescription
				from @documentDetail detail where detail.RecordStatus='Added'
			END

			------RecordStatus is Deleted
			IF EXISTS(Select Id from @documentDetail where RecordStatus='Deleted')
			BEGIN
				Delete invDetail from Bean.InvoiceDetail invDetail 
				join @documentDetail docDetail on invDetail.ID=docDetail.Id where docDetail.RecordStatus='Deleted'
			END
			
		END------End of IF Exists
			ELSE ---IF Not Exists
			BEGIN---Beging OF insertion
			
			---Doc no checking
				Set @isDocNoEditable=(Select IsEditable from Common.AutoNumber(Nolock) where CompanyId=@companyId and EntityType=@DocType and ModuleMasterId in (select id from Common.ModuleMaster where Name='Bean Cursor'))
				IF(@isDocNoEditable=1)
				BEGIN
					Set @docNo=(select DocNo from @document)
				END
				Else
				BEGIN
					--Declare @SpDocNo NvarChar(100)
					Exec Common_GenerateDocNo @companyId,'Bean Cursor',@DocType,0,@docNo out
					--Set @docNo='CN-2020-00033'
				END

				---Doc no verifying
				If(@DocType=@Invoice)
				Begin
					If Exists(Select DocNo from Bean.Bill(Nolock) where CompanyId=@companyId and EntityId=@BillEntityId and DocNo=@docNo and DocumentState<>'Void' and DocSubType<>'Payroll')
					Begin
						RAISERROR ('Document number already exist in Bill.',16,1);
					End
				End
				Else If(@DocType=@CreditNote)
				Begin
				
					If Exists(Select DocNo from Bean.CreditMemo(Nolock) where CompanyId=@companyId and EntityId=@BillEntityId and DocNo=@docNo and DocumentState<>'Void' )
					Begin
						RAISERROR ('Document number already exist in Credit Memo.',16,1);
					End
				End
			

			
				Insert Into Bean.Invoice (Id,CompanyId,ServiceCompanyId,EntityId,DocNo,InvoiceNumber,DocType,DocSubType,Nature,IsNoSupportingDocument,NoSupportingDocs,IsAllowableDisallowableActivated,IsAllowableNonAllowable,CreditTermsId,DocCurrency,ExchangeRate,ExCurrency,GSTExchangeRate,GSTExCurrency,DocumentState,BalanceAmount,GSTTotalAmount,GrandTotal,IsGstSettings,CursorType,InternalState,IsGSTApplied,UserCreated,CreatedDate,ModifiedBy,ModifiedDate,DocDescription,DocDate,DueDate,PONo,IsRepeatingInvoice,EntityType,IsMultiCurrency,IsBaseCurrencyRateChanged,IsGSTCurrencyRateChanged,ExtensionType)  
   
                Select @DocumentId, doc.CompanyId, doc.ServiceCompanyId, doc.EntityId, @docNo, @docNo, @DocType, 'Interco',doc.Nature,doc.IsNoSupportingDocument, doc.NoSupportingDocs, doc.IsAllowableDisallowableActivated,doc.IsAllowableNonAllowable, doc.CreditTermsId, doc.DocCurrency, doc.ExchangeRate,doc.BaseCurrency, doc.GSTExchangeRate, doc.GSTCurrency, IsNull(doc.DocumentState,Case WHEN doc.DocType='Invoice' THEN  'Not Paid' Else 'Not Applied' End), doc.GrandTotal, doc.GSTTotalAmount, doc.GrandTotal,doc.IsGstSettings, 'Bean','Posted', doc.IsGSTApplied, doc.UserCreated, @currentDate,null,null,doc.DocDescription, doc.DocDate,doc.DueDate,doc.PONo,0,'Customer',doc.IsMultiCurrency,doc.IsBaseCurrencyRateChanged,IsGSTCurrencyRateChanged,Case When @DocType=@CreditNote Then 'General' Else null End from @document doc 

				Insert Into Bean.InvoiceDetail(Id,InvoiceId,ItemId,ItemCode,ItemDescription,Qty,Unit,UnitPrice,Discount,DiscountType,COAId,TaxId,TaxRate,DocAmount,DocTaxAmount,DocTotalAmount,BaseAmount,BaseTaxAmount,BaseTotalAmount,TaxIdCode,AmtCurrency,RecOrder)
				Select NEWID(),@DocumentId,detail.ItemId,detail.ItemCode,detail.ItemDescription,detail.Qty,detail.Unit,detail.UnitPrice,detail.Discount,detail.DiscountType,detail.COAId/*,detail.AllowDisAllow*/,detail.TaxId,detail.TaxRate,detail.DocAmount,detail.DocTaxAmount,detail.DocTotalAmount,
				ROUND(detail.DocAmount*@Exchangerate,2),
				ROUND(Isnull(detail.DocTaxAmount,0)*@Exchangerate,2),
				ROUND(detail.DocAmount*@Exchangerate,2)+ROUND(Isnull(detail.DocTaxAmount,0)*@Exchangerate,2)/*,detail.IsPLAccount*/,
				detail.TaxIdCode,detail.AmtCurrency,
				--ROW_NUMBER() over (ORDER BY detail.Id) 
				--ISNULL((Select MAX(RecOrder)+1 from Bean.InvoiceDetail where InvoiceId=@DocumentId),1)
				detail.RecOrder
				from @documentDetail detail
			END-----End OF Insertion

			--Updating the BaseGrandTotal and BaseBalanceAmount
			IF(@DocType=@CreditNote)
			BEGIN
				Update Inv Set Inv.BaseGrandTotal=A.BaseAmount,Inv.BaseBalanceAmount=A.BaseAmount from Bean.Invoice Inv
				Inner Join
				(Select inv.Id,Inv.CompanyId,Round(SUM(Isnull(Invd.BaseTotalAmount,0)),2) As BaseAmount from Bean.Invoice Inv
				Join Bean.InvoiceDetail Invd on Inv.Id =Invd.InvoiceId where inv.Id=@DocumentId and Inv.CompanyId=@companyId
				Group By inv.Id,Inv.CompanyId) As A on A.Id=inv.Id and A.CompanyId=inv.CompanyId and inv.CompanyId=@companyId where A.CompanyId=@companyId and A.Id=@DocumentId
			END
		End
		

		------Calling Bill/Credit Memo Document save call
		If(@DocType=@Invoice OR @DocType=@DebitNote)
		Begin
			Exec [dbo].[Bean_Interco_Billing_Process] @DocumentId, 'Bill',@companyId,@BillEntityId,@BillServiceEntityId
		End
		Else
		Begin
			Exec [dbo].[Bean_Interco_Billing_Process] @DocumentId,'Credit Memo',@companyId,@BillEntityId,@BillServiceEntityId
		End
		Exec [dbo].[Bean_Posting] @DocumentId,@DocType,@companyId
		
		IF((Select COUNT(*) from @CreditNoteApp)>=1)
		Begin
			Exec Bean_Save_InterCo_CN @CreditNoteApp,@CreditNoteAppDetial
		End

		Commit Transaction ----Commit the transaction
	END TRY
	BEGIN CATCH
		Rollback Transaction
		SELECT 
        @ErrorMessage = ERROR_MESSAGE(), 
        @ErrorSeverity = ERROR_SEVERITY(), 
        @ErrorState = ERROR_STATE();
 
		-- return the error inside the CATCH block
		RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState);
	END CATCH
END
GO
