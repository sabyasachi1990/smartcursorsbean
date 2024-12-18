USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[Bean_Interco_Billing_Process]    Script Date: 16-12-2024 9.20.10 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

--exec [dbo].[Bean_Interco_Billing_Process] '511a77b1-d1ed-4b7e-abd0-6a239b2e606e','Application',807,'FF1E3AB6-BF03-4289-861D-C231C0AEA13D',0
CREATE   PROCEDURE [dbo].[Bean_Interco_Billing_Process]
 @SourceId uniqueidentifier,
 @DocType Nvarchar(20),
 @CompanyId int,
 @EntityId uniqueidentifier,
 @ServiceEntityId int
 As 
 Begin
 Declare @Error_Message Varchar(Max)
 Declare @IsGSTSettings int
 Declare @BillId uniqueidentifier
 Declare @CreditMemoId uniqueidentifier
 Declare @DocDesc varchar(Max)
 Declare @CMApplicationId uniqueidentifier
 Declare @CNApplicationId uniqueidentifier
 Declare @IsCNReverseExcess bit=0
 Declare @IsCMReverseExcess bit=0
 Declare @CreditNoteId UniqueIdentifier
 Declare @CreditNoteExchangeRate Decimal(15,10)

 --Doc Type Declaration
 Declare @BillDocument nvarchar(20)='Bill',
		 @CreditMemoDocument nvarchar(20)='Credit Memo',
		 @EntityType nvarchar(20)='Vendor',
		 @System nvarchar(20)='System',
		 @CreditNoteDocument nvarchar(20)='Credit Note'

--Nature
Declare @IntercoNature varchar(20)='Interco'
 --Declare @TaxCode Table(TaxId int,TaxRate decimal(15,10),TaxCode varchar(20),TaxIdCode varchar(50),EffectiveForm Datetime2(7),EffectiveTo Datetime2(7))
 Declare @TaxCode Table(CompanyId BigInt,TaxId int,CustTaxId int,TaxRate decimal(15,10),TaxCode varchar(20),TaxIdCode varchar(50),DocumentId uniqueidentifier,DocTaxAmount money,DocAmount money, BaseTaxAmount money, BaseAmount money)

 --Error message

 DECLARE @ErrorMessage  NVARCHAR(4000),
			@ErrorSeverity INT,
            @ErrorState    INT
 Declare @DocDate DateTime2(7), 
		 @IsInvoiceGstActivate bit,
		 @OldServiceEntity BigInt


----For Outstanding Detail 
DECLARE @Temp Table (S_No Int identity(1,1),DetailId Uniqueidentifier, DocumentId Uniqueidentifier,CreditAmount money)
Declare @BCDocumentHistoryType DocumentHistoryTableType
Declare @RecCount int=0,@Count int=0
Declare @Detailid Uniqueidentifier, @DocumentID Uniqueidentifier, @DetailCreditAmount Money,@currentDate DateTime2(7) =GETUTCDATE()

---For 0.01
Declare @RoundingAmount Money, @BaseBalance Money, @DocumentGrandTotal Money, @DocExchangeRate decimal(15,10),@DocState Nvarchar(20), @OldRoundingAmount Money, @creditNoteGrandToatl Money, @OldDetailAmount Money, @NewCreditNoteAmount money, @IsAdd bit=0, @BaseGrandTotal Money, @BalanceAmount Money, @CNAppRoundingAmount money, @OldCNState Nvarchar(30),@oldDetailDocState NvarChar(30)
Declare @FullyApplied Nvarchar(40)='Fully Applied', @PartialApplied Nvarchar(40)='Partial Applied', @NotApplied Nvarchar(20)='Not Applied'
Declare @CNDocNo Nvarchar(50), @CnAppCount Int, @CnAppDocno Nvarchar(50), @IsCreditZero Bit, @ApplicationDate DateTime2(7)
DECLARE @FullyPaid Nvarchar(30)='Fully Paid',@PartialPaid Nvarchar(30)='Partial Paid',@NotPaid Nvarchar(25)='Not Paid'
Declare @CreditAmount Money, @OldCreditAmount Money, @DocCurrency Nvarchar(20), @ISNoSupportDocs Bit, @OldReverseExcess bit
Declare @GUIDZero Uniqueidentifier ='00000000-0000-0000-0000-000000000000'
 
	 Begin Try
	 Begin Transaction

	 If Exists(Select Id from Bean.Invoice(Nolock) where Id=@SourceId and CompanyId=@CompanyId)
	 Begin--Begin Main


	 Set @IsGSTSettings= Isnull((Select IsGstSetting from Common.Company(Nolock) where Id = @ServiceEntityId and ParentId=@CompanyId),0)
	 

	 Select @DocDesc=DocDescription,@DocDate=DocDate,@IsInvoiceGstActivate=ISNULL(IsGstSettings,0) from Bean.Invoice(Nolock) where Id=@SourceId and CompanyId=@CompanyId
	 If(@DocType<>'Application')
	 Begin
		 If (@IsInvoiceGstActivate=1 and @IsGSTSettings=1)
		 Begin
			Insert into @TaxCode
			Select A.CompanyId,A.Id,B.TaxId,A.TaxRate,A.VenTaxCode,A.TaxIdCode,B.Id,
		 
			Case When isnull(A.TaxRate,0)=isnull(B.TaxRate,0) Then Isnull(B.DocTaxAmount,0) 
			Else Case When A.TaxRate=0 Then 0 Else ROUND(B.DocTotalAmount-Round(((B.DocTotalAmount*100)/(100+Isnull(A.TaxRate,0))),2),2) End End As DocTaxAmount,

			Case When isnull(A.TaxRate,0)=isnull(B.TaxRate,0) Then B.DocAmount 
			Else Case When A.TaxRate=0 Then B.DocTotalAmount Else 
			Round(((B.DocTotalAmount*100)/(100+Isnull(A.TaxRate,0))),2) End End As DocAmount,

			Case When isnull(A.TaxRate,0)=isnull(B.TaxRate,0) Then B.BaseTaxAmount 
			Else Case When A.TaxRate=0 Then 0 Else ROUND(B.BaseTotalAmount-Round(((B.BaseTotalAmount*100)/(100+Isnull(A.TaxRate,0))),2),2)End End As BaseTaxAmount,

			Case When isnull(A.TaxRate,0)=isnull(B.TaxRate,0) Then B.BaseAmount 
			Else Case When A.TaxRate=0 Then B.BaseTotalAmount Else 
			Round(((B.BaseTotalAmount*100)/(100+Isnull(A.TaxRate,0))),2) End End As BaseAmount

			from 
			(
			select taxMap.CompanyId,taxMapDetail.CustTaxCode,taxMapDetail.VenTaxCode,tax.Id,TaxRate,tax.EffectiveFrom,tax.EffectiveTo,CONCAT(Code,+'-'+Case When TaxRate is null Then 'NA' Else CAST(TaxRate as varchar(20))+'%' END) as TaxIdCode 
			from Bean.TaxCodeMapping(Nolock) taxMap
			join Bean.TaxCodeMappingDetail(Nolock) taxMapDetail on taxMap.Id=taxMapDetail.TaxCodeMappingId
			join Bean.TaxCode(Nolock) tax on taxMapDetail.VenTaxCode=tax.Code and tax.CompanyId=@CompanyId
			--join Bean.InvoiceDetail invd on invd.InvoiceId='844dc373-1e1a-4e74-a930-85851278dd41'
			where taxMap.CompanyId=@CompanyId and EffectiveFrom<=@DocDate and (EffectiveTo is null or EffectiveTo>=@DocDate)) As A
			join
			(
			select  tax.Code,Id.TaxId,Id.Id,ID.DocAmount,ID.DocTaxAmount,ID.DocTotalAmount,ID.BaseAmount,ID.BaseTaxAmount,ID.BaseTotalAmount,ID.TaxRate from Bean.TaxCode(Nolock) tax
			join Bean.InvoiceDetail(Nolock) ID on tax.Id=Id.TaxId and tax.CompanyId=@CompanyId
			where Id.InvoiceId=@SourceId) As B
			on A.CustTaxCode=B.Code and A.CompanyId=@CompanyId
		 End
	 END

	 IF @DocType=@BillDocument
	 Begin
	 If Not exists (Select Id from Bean.Bill(Nolock) where PayrollId=@SourceId and CompanyId=@CompanyId)
		Begin--Begin of Bill New
		Set @BillId=NEWID()
		Insert into Bean.Bill(Id,CompanyId,DocSubType,SystemReferenceNumber,DocNo,ServiceCompanyId,EntityId,Nature,DocumentDate,PostingDate,CreditTermsId,DueDate,DocCurrency,ExchangeRate,IsNoSupportingDocument,DocDescription,BaseCurrency,GSTExCurrency,GSTExchangeRate,GSTTotalAmount,GrandTotal,IsGstSettings,IsMultiCurrency,UserCreated,CreatedDate,ModifiedBy,ModifiedDate,Status,BalanceAmount,PayrollId,IsExternal,DocType,DocumentState,EntityType,CreditTermValue,IsSegmentReporting,IsAllowableDisallowable,IsGSTCurrencyRateChanged,IsBaseCurrencyRateChanged)
		Select @BillId as Id,CompanyId as CompanyId,DocSubType as DocSubType,DocNo as SystemReferenceNumber,DocNo as DocNo,@ServiceEntityId as ServiceCompanyId,@EntityId as EntityId,Nature as Nature,DocDate as DocumentDate,DocDate as PostingDate,CreditTermsId as CreditTermsId,DueDate as DueDate,DocCurrency as DocCurrency,ExchangeRate as ExchangeRate,IsNoSupportingDocument as IsNoSupportingDocument,@DocDesc as DocDescription,ExCurrency as BaseCurrency,GSTExCurrency as GSTExCurrency,GSTExchangeRate as GSTExchangeRate,
		Case When GSTTotalAmount is null  Then 0 Else GSTTotalAmount End as GSTTotalAmount,
		GrandTotal as GrandTotal,@IsGSTSettings as IsGstSettings,IsMultiCurrency as IsMultiCurrency,@System as UserCreated,GETUTCDATE() as CreatedDate,null as ModifiedBy,null as ModifiedDate,Status as Status,BalanceAmount as BalanceAmount,Id as PayrollId,1 as IsExternal,@BillDocument as DocType,DocumentState as DocumentState,@EntityType as EntityType,0 as CreditTermValue,0 as IsSegmentReporting,0 as IsAllowableDisallowable,0 as IsGSTCurrencyRateChanged,IsBaseCurrencyRateChanged  from Bean.Invoice(Nolock) where Id=@SourceId and CompanyId=@CompanyId

		Insert into Bean.BillDetail (Id,BillId,Description,COAId,TaxId,TaxCode,TaxType,TaxRate,DocAmount,DocTaxAmount,DocTotalAmount,BaseAmount,BaseTaxAmount,BaseTotalAmount,RecOrder,TaxIdCode,IsDisallow)

		Select NEWID() as Id,@BillId as BillId,ID.ItemDescription as Description,(Select VenCOAId from Bean.COAMappingDetail where CustCOAId=ID.COAId and Status=1) as COAId,
		-----TaxId
		Case When @IsGSTSettings =1 and @IsInvoiceGstActivate=1 
		THEN
		Case When ID.TaxIdcode='NA' Then (Select Id from Bean.TaxCode where Code='NA' and TaxRate is null and CompanyId=@CompanyId)
		Else
		 (Select TaxId from @TaxCode where DocumentId=ID.Id and CustTaxId=Id.TaxId and CompanyId=@CompanyId)
		End
		When @IsGSTSettings=1 and @IsInvoiceGstActivate=0 
		Then (Select Id from Bean.TaxCode where Code='NA' and TaxRate is null and CompanyId=@CompanyId)
		   END as TaxId,
		------TaxCode
		Case 
		When @IsGSTSettings =1 and @IsInvoiceGstActivate=1 
		THEN 
			Case When ID.TaxIdcode='NA' Then (Select code from Bean.TaxCode where Code='NA' and TaxRate is null and CompanyId=@CompanyId)
		Else
		  (Select TaxCode from @TaxCode where DocumentId=ID.Id and CustTaxId=Id.TaxId and CompanyId=@CompanyId)
		End
		When @IsGSTSettings=1 and @IsInvoiceGstActivate=0
		 Then (Select Code from Bean.TaxCode where Code='NA' and TaxRate is null and CompanyId=@CompanyId) 
		 END as TaxCode,


		 'Output' as TaxType,

		 -----TaxRate
		Case When @IsGSTSettings =1 and @IsInvoiceGstActivate=1 THEN 
		Case When ID.TaxIdcode='NA' Then (Select TaxRate from Bean.TaxCode where Code='NA' and TaxRate is null and CompanyId=@CompanyId)
		Else
			(Select TaxRate from @TaxCode where DocumentId=ID.Id and CustTaxId=Id.TaxId and CompanyId=@CompanyId)
		End
		  When @IsGSTSettings=1 and @IsInvoiceGstActivate=0 Then 
		  (Select TaxRate from Bean.TaxCode where Code='NA' and TaxRate is null and CompanyId=@CompanyId) END as TaxRate,


		 Case When @IsGSTSettings =1 and @IsInvoiceGstActivate=1 and ID.TaxIDCode<>'NA' THEN Isnull((Select DocAmount from @TaxCode where DocumentId=ID.Id and CompanyId=@CompanyId),0) Else Isnull(ID.DocTotalAmount,0) END  as DocAmount,


		Case When @IsGSTSettings =1 and @IsInvoiceGstActivate=1 and ID.TaxIDCode<>'NA' THEN isnull((Select DocTaxAmount from @TaxCode where DocumentId=ID.Id and CompanyId=@CompanyId),0) Else 0 END as DocTaxAmount,
		
		isnull(ID.DocTotalAmount,0) as DocTotalAmount,
		
		Case When @IsGSTSettings =1 and @IsInvoiceGstActivate=1 and ID.TaxIDCode<>'NA' Then isnull((Select BaseAmount from @TaxCode where DocumentId=ID.Id and CompanyId=@CompanyId),0) Else ISNULL(ID.BaseTotalAmount,0) End as BaseAmount,

		Case When @IsGSTSettings =1 and @IsInvoiceGstActivate=1 and ID.TaxIDCode<>'NA' THEN isnull((Select BaseTaxAmount from @TaxCode where DocumentId=ID.Id and CompanyId=@CompanyId),0) Else 0 END As BaseTaxAmount,
		
		ID.BaseTotalAmount as BaseTotalAmount,
		ID.RecOrder as RecOrder,
		-------TaxIdCode
		Case When @IsGSTSettings =1 and @IsInvoiceGstActivate=1
		 THEN 
		 Case When ID.TaxIdcode='NA' Then (Select Code from Bean.TaxCode where Code='NA' and TaxRate is null and CompanyId=@CompanyId)
		Else
		(Select TaxIdCode from @TaxCode where DocumentId=ID.Id and CustTaxId=Id.TaxId and CompanyId=@CompanyId)
		End
		  When @IsGSTSettings=1 and @IsInvoiceGstActivate=0 Then (Select Code from Bean.TaxCode(Nolock) where Code='NA' and TaxRate is null and CompanyId=@CompanyId) END as TaxIdCode,0 as IsDisallow  from Bean.InvoiceDetail(Nolock) ID Join Bean.Invoice(Nolock) I on ID.InvoiceId=I.Id where ID.InvoiceId=@SourceId and I.CompanyId=@CompanyId
		End---End Of Bill New


	Else
	Begin--Begin Of Edit Bill
		Set @OldServiceEntity=(Select ServiceCompanyId from Bean.Bill where CompanyId=@CompanyId and PayrollId=@SourceId)
		Update B set B.ServiceCompanyId=@ServiceEntityId,b.Nature=i.Nature,b.EntityId=@EntityId,b.DocumentDate=i.DocDate,b.PostingDate=i.DocDate,B.DueDate=I.DueDate,B.CreditTermsId=I.CreditTermsId,B.DocCurrency=I.DocCurrency,B.ExchangeRate=I.ExchangeRate,B.DocDescription=I.DocDescription,B.ModifiedBy=@System,B.ModifiedDate=GETUTCDATE(), B.IsGstSettings=Case When @OldServiceEntity<>@ServiceEntityId Then @IsGSTSettings Else B.IsGstSettings End, B.GrandTotal=I.GrandTotal, UserCreated=@System, DocNo=I.DocNo,SystemReferenceNumber=I.DocNo,BalanceAmount=I.BalanceAmount,B.IsGSTCurrencyRateChanged=Isnull(I.IsGSTCurrencyRateChanged,0),B.IsBaseCurrencyRateChanged=Isnull(I.IsBaseCurrencyRateChanged,0) from Bean.Bill as B 
		Inner Join Bean.Invoice as I on B.PayrollId=I.Id and B.CompanyId=I.CompanyId where I.Id=@SourceId and I.CompanyId=@CompanyId


		--Delete Old Detail from Edit mode
		Delete BD from Bean.Bill B Inner Join Bean.BillDetail BD on B.Id=BD.BillId
		where B.PayrollId=@SourceId And B.CompanyId=@CompanyId
		Set @BillId=(Select Id from Bean.Bill(Nolock) where PayrollId=@SourceId and CompanyId=@CompanyId)
		--Insert new Bill Detail Data in Edit Mode
		Insert into Bean.BillDetail (Id,BillId,Description,COAId,TaxId,TaxCode,TaxType,TaxRate,DocAmount,DocTaxAmount,DocTotalAmount,BaseAmount,BaseTaxAmount,BaseTotalAmount,RecOrder,TaxIdCode,IsDisallow)

		Select NEWID() as Id,@BillId as BillId,ID.ItemDescription as Description,(Select VenCOAId from Bean.COAMappingDetail where CustCOAId=ID.COAId and Status=1) as COAId,
		-----TaxId
		Case When @IsGSTSettings =1 and @IsInvoiceGstActivate=1 
		THEN
		Case When ID.TaxIdcode='NA' Then (Select Id from Bean.TaxCode where Code='NA' and TaxRate is null and CompanyId=@CompanyId)
		Else
		 (Select TaxId from @TaxCode where DocumentId=ID.Id and CustTaxId=Id.TaxId and CompanyId=@CompanyId)
		End
		When @IsGSTSettings=1 and @IsInvoiceGstActivate=0 
		Then (Select Id from Bean.TaxCode where Code='NA' and TaxRate is null and CompanyId=@CompanyId)
		   END as TaxId,
		------TaxCode
		Case 
		When @IsGSTSettings =1 and @IsInvoiceGstActivate=1 
		THEN 
			Case When ID.TaxIdcode='NA' Then (Select code from Bean.TaxCode where Code='NA' and TaxRate is null and CompanyId=@CompanyId)
		Else
		  (Select TaxCode from @TaxCode where DocumentId=ID.Id and CustTaxId=Id.TaxId and CompanyId=@CompanyId)
		End
		When @IsGSTSettings=1 and @IsInvoiceGstActivate=0
		 Then (Select Code from Bean.TaxCode where Code='NA' and TaxRate is null and CompanyId=@CompanyId) 
		 END as TaxCode,


		 'Output' as TaxType,

		 -----TaxRate
		Case When @IsGSTSettings =1 and @IsInvoiceGstActivate=1 THEN 
		Case When ID.TaxIdcode='NA' Then (Select TaxRate from Bean.TaxCode where Code='NA' and TaxRate is null and CompanyId=@CompanyId)
		Else
			(Select TaxRate from @TaxCode where DocumentId=ID.Id and CustTaxId=Id.TaxId and CompanyId=@CompanyId)
		End
		  When @IsGSTSettings=1 and @IsInvoiceGstActivate=0 Then 
		  (Select TaxRate from Bean.TaxCode where Code='NA' and TaxRate is null and CompanyId=@CompanyId) END as TaxRate,


		 Case When @IsGSTSettings =1 and @IsInvoiceGstActivate=1 and ID.TaxIDCode<>'NA' THEN Isnull((Select DocAmount from @TaxCode where DocumentId=ID.Id and CompanyId=@CompanyId),0) Else Isnull(ID.DocTotalAmount,0) END  as DocAmount,


		Case When @IsGSTSettings =1 and @IsInvoiceGstActivate=1 and ID.TaxIDCode<>'NA' THEN isnull((Select DocTaxAmount from @TaxCode where DocumentId=ID.Id and CompanyId=@CompanyId),0) Else 0 END as DocTaxAmount,
		
		isnull(ID.DocTotalAmount,0) as DocTotalAmount,
		
		Case When @IsGSTSettings =1 and @IsInvoiceGstActivate=1 and ID.TaxIDCode<>'NA' Then isnull((Select BaseAmount from @TaxCode where DocumentId=ID.Id and CompanyId=@CompanyId),0) Else ISNULL(ID.BaseTotalAmount,0) End as BaseAmount,

		Case When @IsGSTSettings =1 and @IsInvoiceGstActivate=1 and ID.TaxIDCode<>'NA' THEN isnull((Select BaseTaxAmount from @TaxCode where DocumentId=ID.Id and CompanyId=@CompanyId),0) Else 0 END As BaseTaxAmount,
		
		ID.BaseTotalAmount as BaseTotalAmount,
		ID.RecOrder as RecOrder,
		-------TaxIdCode
		Case When @IsGSTSettings =1 and @IsInvoiceGstActivate=1
		 THEN 
		 Case When ID.TaxIdcode='NA' Then (Select Code from Bean.TaxCode where Code='NA' and TaxRate is null and CompanyId=@CompanyId)
		Else
		(Select TaxIdCode from @TaxCode where DocumentId=ID.Id and CustTaxId=Id.TaxId and CompanyId=@CompanyId)
		End
		  When @IsGSTSettings=1 and @IsInvoiceGstActivate=0 Then (Select Code from Bean.TaxCode(Nolock) where Code='NA' and TaxRate is null and CompanyId=@CompanyId) END as TaxIdCode,0 as IsDisallow  from Bean.InvoiceDetail(Nolock) ID Join Bean.Invoice(Nolock) I on ID.InvoiceId=I.Id where ID.InvoiceId=@SourceId and I.CompanyId=@CompanyId

		End ----End of Edit Bill
		If (@BillId Is Not NULL AND @BillId !='00000000-0000-0000-0000-000000000000')
		Begin
		 Exec [dbo].[Bean_Posting] @BillId,@BillDocument,@CompanyId
		End	
	End--DocType Bill End

	IF @DocType=@CreditMemoDocument
	Begin
		
		 
		If Not exists (Select Id from Bean.CreditMemo where ParentInvoiceID=@SourceId and CompanyId=@CompanyId)
		Begin--Begin of CM New
		Set @CreditMemoId=NEWID()
		Insert into Bean.CreditMemo(Id,CompanyId,DocSubType,CreditMemoNumber,DocNo,ServiceCompanyId,EntityId,Nature,DocDate,PostingDate,CreditTermsId,DueDate,DocCurrency,ExchangeRate,IsNoSupportingDocument,DocDescription,ExCurrency,GSTExCurrency,GSTExchangeRate,GSTTotalAmount,GrandTotal,IsGstSettings,IsMultiCurrency,UserCreated,CreatedDate,ModifiedBy,ModifiedDate,Status,BalanceAmount,DocType,DocumentState,EntityType,IsSegmentReporting,IsAllowableNonAllowable,IsGSTCurrencyRateChanged,IsBaseCurrencyRateChanged,ParentInvoiceID,BaseGranDTotal,BaseBalanceAmount)

		Select @CreditMemoId as Id,CompanyId as CompanyId,DocSubType as DocSubType,DocNo as SystemReferenceNumber,DocNo as DocNo,@ServiceEntityId as ServiceCompanyId,@EntityId as EntityId,Nature as Nature,DocDate as DocumentDate,DocDate as PostingDate,CreditTermsId as CreditTermsId,DueDate as DueDate,DocCurrency as DocCurrency,ExchangeRate as ExchangeRate,IsNoSupportingDocument as IsNoSupportingDocument,@DocDesc as DocDescription,ExCurrency as BaseCurrency,GSTExCurrency as GSTExCurrency,GSTExchangeRate as GSTExchangeRate,
		Case When GSTTotalAmount is null  Then 0 Else GSTTotalAmount End as GSTTotalAmount,
		GrandTotal as GrandTotal,@IsGSTSettings as IsGstSettings,IsMultiCurrency as IsMultiCurrency,@System as UserCreated,GETUTCDATE() as CreatedDate,null as ModifiedBy,null as ModifiedDate,Status as Status,BalanceAmount as BalanceAmount,@CreditMemoDocument as DocType,DocumentState as DocumentState,@EntityType as EntityType,0 as IsSegmentReporting,0 as IsAllowableDisallowable,0 as IsGSTCurrencyRateChanged,IsBaseCurrencyRateChanged,@SourceId as ParentInvoiceID,BaseGrandTotal,BaseBalanceAmount  from Bean.Invoice(Nolock) where Id=@SourceId and CompanyId=@CompanyId and DocType=@CreditNoteDocument

		Insert into Bean.CreditMemoDetail(Id,CreditMemoId,Description,COAId,TaxId,TaxRate,DocAmount,DocTaxAmount,DocTotalAmount,BaseAmount,BaseTaxAmount,BaseTotalAmount,RecOrder,TaxIdCode,AllowDisAllow)

		Select NEWID() as Id,@CreditMemoId as CreditMemoId,ID.ItemDescription as Description,
		(Select VenCOAId from Bean.COAMappingDetail where CustCOAId=ID.COAId and Status=1) as COAId,
		-----TaxId
		Case When @IsGSTSettings =1 and @IsInvoiceGstActivate=1 
		THEN 
		Case When Id.TaxIdCode='NA' Then (Select Id from Bean.TaxCode where Code='NA' and TaxRate is null and CompanyId=@CompanyId)
		Else
		(Select TaxId from @TaxCode where DocumentId=ID.Id and CustTaxId=Id.TaxId and CompanyId=@CompanyId)
		End
		When @IsGSTSettings=1 and @IsInvoiceGstActivate=0 
		Then (Select Id from Bean.TaxCode where Code='NA' and TaxRate is null and CompanyId=@CompanyId)
		   END as TaxId,
		----Taxrate
		Case When @IsGSTSettings =1 and @IsInvoiceGstActivate=1 THEN 
		Case When Id.TaxIdCode='NA' Then (Select TaxRate from Bean.TaxCode where Code='NA' and TaxRate is null and CompanyId=@CompanyId)
		Else
		(Select TaxRate from @TaxCode where DocumentId=ID.Id and CustTaxId=Id.TaxId and CompanyId=@CompanyId)
		End
		  When @IsGSTSettings=1 and @IsInvoiceGstActivate=0 Then 
		  (Select TaxRate from Bean.TaxCode where Code='NA' and TaxRate is null and CompanyId=@CompanyId) END as TaxRate,

		 Case When @IsGSTSettings =1 and @IsInvoiceGstActivate=1 and Id.TaxIdCode<>'NA' THEN /*ISNULL(ID.DocAmount,0)*/Isnull((Select DocAmount from @TaxCode where DocumentId=ID.Id and CompanyId=@CompanyId),0) Else Isnull(ID.DocTotalAmount,0) END  as DocAmount,
		Case When @IsGSTSettings =1 and @IsInvoiceGstActivate=1 and Id.TaxIdCode<>'NA' THEN /*ISNULL(ID.DocTaxAmount,0)*/isnull((Select DocTaxAmount from @TaxCode where DocumentId=ID.Id and CompanyId=@CompanyId),0) Else 0 END as DocTaxAmount,

		isnull(ID.DocTotalAmount,0) as DocTotalAmount,
		--ID.BaseAmount As BaseAmount,
		Case When @IsGSTSettings =1 and @IsInvoiceGstActivate=1 and Id.TaxIdCode<>'NA' Then /*ISNULL(Id.BaseAmount,0)*/isnull((Select BaseAmount from @TaxCode where DocumentId=ID.Id and CompanyId=@CompanyId),0) Else ISNULL(ID.BaseTotalAmount,0) End as BaseAmount,

		Case When @IsGSTSettings =1 and @IsInvoiceGstActivate=1 and Id.TaxIdCode<>'NA' THEN /*ISNULL(ID.BaseTaxAmount,0)*/isnull((Select BaseTaxAmount from @TaxCode where DocumentId=ID.Id and CompanyId=@CompanyId),0) Else 0 END As BaseTaxAmount,

		--Case When @IsGSTSettings IS NOT NULL THEN ID.BaseTotalAmount ELSE ID.BaseAmount END as BaseTotalAmount,
		ID.BaseTotalAmount as BaseTotalAmount,

		ID.RecOrder as RecOrder,
		Case When @IsGSTSettings =1 and @IsInvoiceGstActivate=1
		 THEN 
		 Case When Id.TaxIdCode='NA' Then (Select Code from Bean.TaxCode where Code='NA' and TaxRate is null and CompanyId=@CompanyId)
		Else
		(Select TaxIdCode from @TaxCode where DocumentId=ID.Id and CustTaxId=Id.TaxId and CompanyId=@CompanyId)
		End
		  When @IsGSTSettings=1 and @IsInvoiceGstActivate=0 Then (Select Code from Bean.TaxCode where Code='NA' and TaxRate is null and CompanyId=@CompanyId) END as TaxIdCode,0 as IsDisallow 
		   from Bean.InvoiceDetail(Nolock) ID Join Bean.Invoice(Nolock) I on ID.InvoiceId=I.Id where ID.InvoiceId=@SourceId and I.CompanyId=@CompanyId and I.DocType=@CreditNoteDocument and I.Nature=@IntercoNature
		End---End Of CM New


	Else
		Begin--Begin Of Edit CM
		
		Set @OldServiceEntity=(Select ServiceCompanyId from Bean.CreditMemo(Nolock) where CompanyId=@CompanyId and ParentInvoiceID=@SourceId)
		Update CM set CM.ServiceCompanyId=@ServiceEntityId,CM.Nature=i.Nature,CM.EntityId=@EntityId,CM.DocDate=i.DocDate,CM.PostingDate=i.DocDate,CM.DueDate=I.DueDate,CM.CreditTermsId=I.CreditTermsId,CM.DocCurrency=I.DocCurrency,CM.ExchangeRate=I.ExchangeRate,CM.DocDescription=I.DocDescription,CM.ModifiedBy=@System,CM.ModifiedDate=GETUTCDATE(), CM.IsGstSettings=Case When @OldServiceEntity<>@ServiceEntityId Then @IsGSTSettings Else CM.IsGstSettings End, CM.GrandTotal=I.GrandTotal, UserCreated=@System, DocNo=I.DocNo,CreditMemoNumber=I.DocNo,BalanceAmount=I.BalanceAmount,CM.IsGSTCurrencyRateChanged=Isnull(I.IsGSTCurrencyRateChanged,0),CM.IsBaseCurrencyRateChanged=Isnull(I.IsBaseCurrencyRateChanged,0),BaseGrandTotal=I.BaseGrandTotal,BaseBalanceAmount=I.BaseBalanceAmount from Bean.CreditMemo as CM 
		Inner Join Bean.Invoice as I on CM.ParentInvoiceID=I.Id and CM.CompanyId=I.CompanyId where I.Id=@SourceId and I.CompanyId=@CompanyId

		
		Set @CreditMemoId=(Select Id from Bean.CreditMemo(Nolock) where ParentInvoiceID=@SourceId and CompanyId=@CompanyId)
		--Delete Old Detail from Edit mode
		Delete CMD from Bean.CreditMemo CM Inner Join Bean.CreditMemoDetail CMD on CM.Id=CMD.CreditMemoId
		where CM.Id=@CreditMemoId And CM.CompanyId=@CompanyId and CM.ParentInvoiceID=@SourceId

		
		--Insert new CM Detail Data in Edit Mode
		Insert into Bean.CreditMemoDetail(Id,CreditMemoId,Description,COAId,TaxId,TaxRate,DocAmount,DocTaxAmount,DocTotalAmount,BaseAmount,BaseTaxAmount,BaseTotalAmount,RecOrder,TaxIdCode,AllowDisAllow)

		Select NEWID() as Id,@CreditMemoId as CreditMemoId,ID.ItemDescription as Description,
		(Select VenCOAId from Bean.COAMappingDetail where CustCOAId=ID.COAId and Status=1) as COAId,
		-----TaxId
		Case When @IsGSTSettings =1 and @IsInvoiceGstActivate=1 
		THEN 
		Case When Id.TaxIdCode='NA' Then (Select Id from Bean.TaxCode where Code='NA' and TaxRate is null and CompanyId=@CompanyId)
		Else
		(Select TaxId from @TaxCode where DocumentId=ID.Id and CustTaxId=Id.TaxId and CompanyId=@CompanyId)
		End
		When @IsGSTSettings=1 and @IsInvoiceGstActivate=0 
		Then (Select Id from Bean.TaxCode where Code='NA' and TaxRate is null and CompanyId=@CompanyId)
		   END as TaxId,
		----Taxrate
		Case When @IsGSTSettings =1 and @IsInvoiceGstActivate=1 THEN 
		Case When Id.TaxIdCode='NA' Then (Select TaxRate from Bean.TaxCode where Code='NA' and TaxRate is null and CompanyId=@CompanyId)
		Else
		(Select TaxRate from @TaxCode where DocumentId=ID.Id and CustTaxId=Id.TaxId and CompanyId=@CompanyId)
		End
		  When @IsGSTSettings=1 and @IsInvoiceGstActivate=0 Then 
		  (Select TaxRate from Bean.TaxCode where Code='NA' and TaxRate is null and CompanyId=@CompanyId) END as TaxRate,

		 Case When @IsGSTSettings =1 and @IsInvoiceGstActivate=1 and Id.TaxIdCode<>'NA' THEN /*ISNULL(ID.DocAmount,0)*/Isnull((Select DocAmount from @TaxCode where DocumentId=ID.Id and CompanyId=@CompanyId),0) Else Isnull(ID.DocTotalAmount,0) END  as DocAmount,
		Case When @IsGSTSettings =1 and @IsInvoiceGstActivate=1 and Id.TaxIdCode<>'NA' THEN /*ISNULL(ID.DocTaxAmount,0)*/isnull((Select DocTaxAmount from @TaxCode where DocumentId=ID.Id and CompanyId=@CompanyId),0) Else 0 END as DocTaxAmount,

		isnull(ID.DocTotalAmount,0) as DocTotalAmount,
		--ID.BaseAmount As BaseAmount,
		Case When @IsGSTSettings =1 and @IsInvoiceGstActivate=1 and Id.TaxIdCode<>'NA' Then /*ISNULL(Id.BaseAmount,0)*/isnull((Select BaseAmount from @TaxCode where DocumentId=ID.Id and CompanyId=@CompanyId),0) Else ISNULL(ID.BaseTotalAmount,0) End as BaseAmount,

		Case When @IsGSTSettings =1 and @IsInvoiceGstActivate=1 and Id.TaxIdCode<>'NA' THEN /*ISNULL(ID.BaseTaxAmount,0)*/isnull((Select BaseTaxAmount from @TaxCode where DocumentId=ID.Id and CompanyId=@CompanyId),0) Else 0 END As BaseTaxAmount,

		--Case When @IsGSTSettings IS NOT NULL THEN ID.BaseTotalAmount ELSE ID.BaseAmount END as BaseTotalAmount,
		ID.BaseTotalAmount as BaseTotalAmount,

		ID.RecOrder as RecOrder,
		Case When @IsGSTSettings =1 and @IsInvoiceGstActivate=1
		 THEN 
		 Case When Id.TaxIdCode='NA' Then (Select Code from Bean.TaxCode where Code='NA' and TaxRate is null and CompanyId=@CompanyId)
		Else
		(Select TaxIdCode from @TaxCode where DocumentId=ID.Id and CustTaxId=Id.TaxId and CompanyId=@CompanyId)
		End
		  When @IsGSTSettings=1 and @IsInvoiceGstActivate=0 Then (Select Code from Bean.TaxCode where Code='NA' and TaxRate is null and CompanyId=@CompanyId) END as TaxIdCode,0 as IsDisallow 
		   from Bean.InvoiceDetail(Nolock) ID Join Bean.Invoice(Nolock) I on ID.InvoiceId=I.Id where ID.InvoiceId=@SourceId and I.CompanyId=@CompanyId and I.DocType=@CreditNoteDocument and I.Nature=@IntercoNature

		End ----End of Edit CM
		If (@CreditMemoId Is Not NULL AND @CreditMemoId !='00000000-0000-0000-0000-000000000000')
		Begin
			Print 'Posting Call'
			Exec [dbo].[Bean_Posting] @CreditMemoId,@CreditMemoDocument,@CompanyId
		End

		
	End--DocType CreditMemo End

	


		
	End---Doctype Bill and CM

	Else If @DocType='Application'
	Begin
		--For Interco CreditMemo Application Creation
			

		Select  @CNApplicationId=@SourceId,@IsCNReverseExcess=ISNULL(CN.IsRevExcess,0),@CreditNoteId=inv.Id,@CreditNoteExchangeRate=inv.ExchangeRate,@ApplicationDate=CreditNoteApplicationDate,@CreditAmount=cn.CreditAmount,@DocDate=INv.DocDate from Bean.Invoice(Nolock) Inv Inner join Bean.CreditNoteApplication(Nolock) CN on Inv.Id=cn.InvoiceId where CN.Id=@SourceId and Inv.Nature=@IntercoNature

		Select @IsInvoiceGstActivate=ISNULL(IsGstSettings,0) from Bean.Invoice(Nolock) where Id=@CreditNoteId and CompanyId=@CompanyId

		If Not Exists(Select Id from Bean.CreditMemo(Nolock) where ParentInvoiceID=@CreditNoteId and CompanyId=@CompanyId)
		RAISERROR ('Invalid Credit Memo Document',16,1);

		Select @CreditMemoId=Id,@IsGSTSettings=Isnull(IsGstSettings,0),@DocCurrency=DocCurrency,@ISNoSupportDocs=IsNoSupportingDocument from Bean.CreditMemo(Nolock) where CompanyId=@CompanyId and ParentInvoiceID=@CreditNoteId

		If(@IsCNReverseExcess=1 and @IsInvoiceGstActivate=1 and @IsGSTSettings=1)
		Begin
			Insert into @TaxCode
			Select A.CompanyId,A.Id,B.TaxId,A.TaxRate,A.VenTaxCode,A.TaxIdCode,B.Id,
		 
			Case When isnull(A.TaxRate,0)=isnull(B.TaxRate,0) Then Isnull(B.TaxAmount,0) 
			Else Case When A.TaxRate=0 Then 0 Else ROUND(B.TotalAmount-Round(((B.TotalAmount*100)/(100+Isnull(A.TaxRate,0))),2),2) End End As DocTaxAmount,

			Case When isnull(A.TaxRate,0)=isnull(B.TaxRate,0) Then B.CreditAmount 
			Else Case When A.TaxRate=0 Then B.TotalAmount Else 
			Round(((B.TotalAmount*100)/(100+Isnull(A.TaxRate,0))),2) End End As DocAmount,

			Case When isnull(A.TaxRate,0)=isnull(B.TaxRate,0) Then B.BaseTaxAmount 
			Else Case When A.TaxRate=0 Then 0 Else ROUND(B.BaseTotalAmount-Round(((B.BaseTotalAmount*100)/(100+Isnull(A.TaxRate,0))),2),2)End End As BaseTaxAmount,

			Case When isnull(A.TaxRate,0)=isnull(B.TaxRate,0) Then B.BaseAmount 
			Else Case When A.TaxRate=0 Then B.BaseTotalAmount Else 
			Round(((B.BaseTotalAmount*100)/(100+Isnull(A.TaxRate,0))),2) End End As BaseAmount

			from 
			(
			select taxMap.CompanyId,taxMapDetail.CustTaxCode,taxMapDetail.VenTaxCode,tax.Id,TaxRate,tax.EffectiveFrom,tax.EffectiveTo,CONCAT(Code,+'-'+Case When TaxRate is null Then 'NA' Else CAST(TaxRate as varchar(20))+'%' END) as TaxIdCode 
			from Bean.TaxCodeMapping(Nolock) taxMap
			join Bean.TaxCodeMappingDetail(Nolock) taxMapDetail on taxMap.Id=taxMapDetail.TaxCodeMappingId
			join Bean.TaxCode tax on taxMapDetail.VenTaxCode=tax.Code and tax.CompanyId=@CompanyId
			--join Bean.InvoiceDetail invd on invd.InvoiceId='844dc373-1e1a-4e74-a930-85851278dd41'
			where taxMap.CompanyId=@CompanyId and EffectiveFrom<=@DocDate and (EffectiveTo is null or EffectiveTo>=@DocDate)) As A
			join
			(
			select  tax.Code,Id.TaxId,Id.Id,ID.CreditAmount,ID.TaxAmount,ID.TotalAmount,Round(Id.CreditAmount*@CreditNoteExchangeRate,2) As BaseAmount,Round(Id.TaxAmount*@CreditNoteExchangeRate,2) As BaseTaxAmount,Round(Id.TotalAmount*@CreditNoteExchangeRate,2) As BaseTotalAmount,ID.TaxRate from Bean.TaxCode tax
			join Bean.CreditNoteApplicationDetail(Nolock) ID on tax.Id=Id.TaxId and tax.CompanyId=@CompanyId
			where Id.CreditNoteApplicationId=@SourceId) As B
			on A.CustTaxCode=B.Code and A.CompanyId=@CompanyId
		End



		If Exists(Select Id from Bean.CreditMemoApplication(Nolock) where CompanyId=@CompanyId and DocumentId=@CNApplicationId)
		Begin
				
			 Select  @OldCreditAmount=CreditAmount,@CNAppRoundingAmount=RoundingAmount,@CMApplicationId=Id from  Bean.CreditMemoApplication(Nolock) where CompanyId=@companyId and DocumentId=@CNApplicationId
			 
			 Set @OldReverseExcess=Isnull((Select IsRevExcess from Bean.CreditMemoApplication(Nolock) where id=@CMApplicationId and CompanyId=@companyId),0)

			---As we are saving 
			Update CMA SET CMA.CreditMemoApplicationDate=CNAType.CreditNoteApplicationDate,CMA.Remarks=CNAType.Remarks,CMA.ModifiedBy= 'System',CMA.ModifiedDate=@currentDate,CMA.IsRevExcess=@IsCNReverseExcess,CMA.CreditAmount=CNAType.CreditAmount,CMA.IsNoSupportingDocumentActivated=@ISNoSupportDocs from Bean.CreditMemoApplication CMA 
			join Bean.CreditNoteApplication CNAType on CMA.DocumentId=CNAType.Id and CNAType.CompanyId=@CompanyId Where CMA.Id=@CMApplicationId and CMA.CompanyId=@CompanyId and CMA.DocumentId=@CNApplicationId

			If(@OldReverseExcess=1 and @IsCNReverseExcess=0)--If reverse excess is checked and later unchecked
			BEGIN
				--We are deleting the record from the creditnoteapplicationdetail as well as journal and journalDetail
				Delete CMD from Bean.CreditMemoApplication CMA 
				join Bean.CreditMemoApplicationDetail CMD on CMA.Id=CMD.CreditMemoApplicationId where CMA.id=@CMApplicationId and CMA.CompanyId=@CompanyId

				Delete from Bean.JournalDetail where DocumentId=@CMApplicationId
				Delete from Bean.Journal where DocumentId=@CMApplicationId and CompanyId=@companyId
						

				Insert Into @Temp
				Select Id,DocumentId,CreditAmount From Bean.CreditNoteApplicationDetail(Nolock) Where CreditNoteApplicationId=@CNApplicationId and CreditAmount<>0 Order By RecOrder
				Select @RecCount=Count(*) From @Temp

				Set @Count=1
				While @RecCount>=@Count
				Begin
					Select @Detailid= DetailId,@DocumentID=DocumentId,@DetailCreditAmount=CreditAmount From @Temp Where S_No=@Count
					Set @BalanceAmount=0;
					Select @DocumentGrandTotal=GrandTotal,@BaseBalance=BaseBalanceAmount,@DocExchangeRate=ExchangeRate,@OldRoundingAmount=RoundingAmount,@BillId=Id,@BalanceAmount=BalanceAmount from Bean.Bill(Nolock) where CompanyId=@companyId and DocSubType=@IntercoNature and PayrollId=@DocumentID

					If(@BillId is null)
						RAISERROR ('Corresponding Bill is not available',16,1);

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

					INSERT INTO Bean.CreditMemoApplicationDetail
					(Id, CreditMemoApplicationId, DocumentId,DocumentType, DocCurrency,CreditAmount, BaseCurrencyExchangeRate, DocDescription, COAId,TaxId,TaxRate, TaxIdCode,TaxAmount,TotalAmount,RecOrder,DocNo,RoundingAmount)
					Select NEWID(),@CMApplicationId,@BillId,@BillDocument,CNADetail.DocCurrency,CNADetail.CreditAmount,CNADetail.BaseCurrencyExchangeRate,CNADetail.DocDescription,null,null,null,null,null,CNADetail.TotalAmount,CNADetail.RecOrder,CNADetail.DocNo,@RoundingAmount From Bean.CreditNoteApplicationDetail(Nolock) CNADetail where CNADetail.Id=@Detailid

					IF((Select BalanceAmount from Bean.Bill(Nolock) where Id=@BillId and CompanyId=@companyId and DocSubType='Interco')<@DetailCreditAmount)
					BEGIN
						RAISERROR ('Credit Amount Cannot be greater than the Balance Amount',16,1);
					END

					--Here we are updating the modified by, modified date, balance amount, state and base balance amount
					Update Bean.Bill Set ModifiedBy=@System,ModifiedDate=@currentDate,BalanceAmount-=@DetailCreditAmount,DocumentState=@DocState,
					BaseBalanceAmount=@BaseBalance,RoundingAmount=0  Where CompanyId=@companyId and Id=@BillId and DocumentState<>'Void'

					--Journal State need to update

					Update J Set J.DocumentState=B.DocumentState,J.BalanceAmount=B.BalanceAmount,J.ModifiedBy=B.ModifiedBy,J.ModifiedDate=B.ModifiedDate from Bean.Journal J
					Join Bean.Bill B on B.Id=J.DocumentId and j.CompanyId=@companyId and B.CompanyId=@companyId
						where J.DocumentId=@BillId and J.companyId=@companyId

					Update Bean.DocumentHistory set AgingState='Deleted' where DocumentId=@BillId and TransactionId=@CMApplicationId and CompanyId=@companyId and AgingState is null

					---Document history need to update
					Insert Into Bean.DocumentHistory(Id,TransactionId,CompanyId,DocumentId,DocType,DocSubType,DocState,DocCurrency,DocAmount,DocBalanaceAmount,ExchangeRate,BaseAmount,BaseBalanaceAmount,StateChangedBy,PostingDate,DocAppliedAmount,BaseAppliedAmount,StateChangedDate)
					Select NEWID(),@CMApplicationId,CompanyId,@BillId,DocType,DocSubType,DocumentState,DocCurrency,Round(GrandTotal,2) As DocAmount,Round(BalanceAmount,2) As DocBalanceAmount,ExchangeRate,Round(GrandTotal*ExchangeRate,2) As BaseAmount,Round(BalanceAmount*ExchangeRate,2) As BaseBalanceAmount,@System,@ApplicationDate,  -Round(@DetailCreditAmount,2) As DocAppliedAmount,-ROUND(@DetailCreditAmount*ExchangeRate,2)+@RoundingAmount As BaseAppliedAmount,@currentDate From Bean.Bill(Nolock) Where Id=@BillId

					Set @Count=@Count+1
				End
			END
			ELSE IF(@OldReverseExcess=0 and @IsCNReverseExcess=1)
			BEGIN
				--Need to reverse the state of the bill if in edit mode is reverse excess is checked
				Insert Into @Temp
				Select Id,DocumentId,CreditAmount From Bean.CreditMemoApplicationDetail(Nolock) Where CreditMemoApplicationId=@CMApplicationId Order By RecOrder
				Select @RecCount=Count(*) From @Temp
				Set @Count=1
				While @RecCount>=@Count
				Begin
					Select @Detailid= DetailId,@DocumentID=DocumentId,@DetailCreditAmount=CreditAmount From @Temp Where S_No=@Count
					If Exists(Select Id from Bean.CreditMemoApplicationDetail(Nolock) where Id=@Detailid)
					Begin
						Select @RoundingAmount=ISNULL(RoundingAmount,0),@OldCreditAmount=CreditAmount from Bean.CreditMemoApplicationDetail where Id=@Detailid 

						Select @DocExchangeRate=ISNULL(ExchangeRate,1),@BalanceAmount=BalanceAmount from Bean.Bill where CompanyId=@companyId and id=@DocumentID
						Set @BalanceAmount+=@OldCreditAmount
						Update Bean.Bill Set ModifiedBy=@System,ModifiedDate=@currentDate,DocumentState=Case When @BalanceAmount=GrandTotal Then @NotPaid Else @PartialPaid End,BalanceAmount=@BalanceAmount,BaseBalanceAmount+=ROUND(@OldCreditAmount*@DocExchangeRate,2),RoundingAmount=Case when @RoundingAmount<>0 Then @RoundingAmount Else RoundingAmount End Where CompanyId=@companyId and Id=@DocumentID and DocumentState<>'Void'

						--Journal State need to update

						Update J Set J.DocumentState=B.DocumentState,J.BalanceAmount=B.BalanceAmount,J.ModifiedBy=B.ModifiedBy,J.ModifiedDate=B.ModifiedDate from Bean.Journal J
						Join Bean.Bill B on B.Id=J.DocumentId and j.CompanyId=@companyId and B.CompanyId=@companyId
						where J.DocumentId=@DocumentID and J.companyId=@companyId

						Insert Into @BCDocumentHistoryType(TransactionId,CompanyId,DocumentId,DocType,DocSubType,DocState,DocCurrency,DocAmount,DocBalanaceAmount,ExchangeRate,BaseAmount,BaseBalanaceAmount,StateChangedBy,PostingDate,DocAppliedAmount,BaseAppliedAmount)

						Select @CMApplicationId,CompanyId,@DocumentID,DocType,DocSubType,DocumentState,DocCurrency,Round(GrandTotal,2) As DocAmount,Round(BalanceAmount,2) As DocBalanceAmount,ExchangeRate,Case When DocumentState=@NotApplied Then  BaseGrandTotal Else 0 End As BaseAmount, BaseBalanceAmount As BaseBalanceAmount,@System,@ApplicationDate,0 As DocAppliedAmount,0  As BaseAppliedAmount From Bean.Bill(Nolock) Where Id=@DocumentId
				
						--Exec [dbo].[Bean_DocumentHistory] @BCDocumentHistoryType

						Delete from Bean.CreditMemoApplicationDetail where CreditMemoApplicationId=@CMApplicationId and Id=@Detailid
					End
					Set @Count=@count+1;
				End

				-----Inserting the record in the CNApp detail

				If(@IsCNReverseExcess=1)
				Begin
					INSERT INTO [Bean].[CreditMemoApplicationDetail]
			   ([Id],[CreditMemoApplicationId],[DocumentId],[DocumentType],[DocCurrency],[CreditAmount],[BaseCurrencyExchangeRate],[COAId],[DocDescription],[TaxId],[TaxRate],[TaxIdCode],[TaxAmount],[TotalAmount],[RecOrder],[DocNo])

					Select NewId() as Id,@CMApplicationId,CNAD.DocumentId,CNAD.DocumentType,CNAD.DocCurrency,

					Case When @IsGSTSettings =1 and @IsInvoiceGstActivate=1 and CNAD.TaxIdCode<>'NA' THEN /*ISNULL(ID.DocAmount,0)*/Isnull((Select DocAmount from @TaxCode where DocumentId=CNAD.Id and CompanyId=@CompanyId),0) Else Isnull(CNAD.TotalAmount,0) END AS CreditAmount,


					CNAD.BaseCurrencyExchangeRate,
					(Select VenCOAId from Bean.COAMappingDetail where CustCOAId=CNAD.COAId and Status=1) as COAId,

					CNAD.DocDescription as DocDescription,

					-------TaxId
					Case When @IsGSTSettings=1 and @IsInvoiceGstActivate=1 
					THEN 
						Case When CNAD.TaxIdCode='NA' Then (Select Id from Bean.TaxCode where Code='NA' and TaxRate is null and CompanyId=@CompanyId)
					Else
					(Select TaxId from @TaxCode where DocumentId=CNAD.Id and CustTaxId=CNAD.TaxId and CompanyId=@CompanyId)
					End
					WHEN @IsGSTSettings=0 and @IsInvoiceGstActivate=1 
					THEN (Select Id from Bean.TaxCode where Code='NA' and TaxRate is null and CompanyId=@CompanyId) END as TaxId,
					
					----TaxRate
					Case When @IsGSTSettings =1 and @IsInvoiceGstActivate=1 
					THEN 
						Case When CNAD.TaxIdCode='NA' Then (Select TaxRate from Bean.TaxCode where Code='NA' and TaxRate is null and CompanyId=@CompanyId)
					Else 
					(Select TaxRate from @TaxCode where DocumentId=CNAD.Id and CustTaxId=CNAD.TaxId and CompanyId=@CompanyId)
					End
					WHEN @IsGSTSettings=1 and @IsInvoiceGstActivate=0 
					THEN (Select TaxRate from Bean.TaxCode where Code='NA' and TaxRate is null and CompanyId=@CompanyId) END as TaxRate,

					CASE WHEN @IsGSTSettings =1 and @IsInvoiceGstActivate=1
					THEN
						Case When CNAD.TaxIdCode='NA' Then (Select Code from Bean.TaxCode where Code='NA' and TaxRate is null and CompanyId=@CompanyId)
					Else 
					 (Select TaxIdCode from @TaxCode where DocumentId=CNAD.Id and CustTaxId=CNAD.TaxId and CompanyId=@CompanyId)
					 End
					WHEN @IsGSTSettings=0 and @IsInvoiceGstActivate=1 
					THEN (Select Code from Bean.TaxCode where Code='NA' and TaxRate is null and CompanyId=@CompanyId) END as TaxIdCode,

					CASE WHEN @IsGSTSettings =1 and @IsInvoiceGstActivate=1 And CNAD.TaxIdCode<>'NA'
					THEN ISNULL((Select DocTaxAmount from @TaxCode where DocumentId=CNAD.Id and CompanyId=@CompanyId),0) Else 0 END as TaxAmount,

					ISNULL(CNAD.TotalAmount,0) as TotalAmount,

					CNAD.RecOrder,CNAD.DocNo 
					from Bean.CreditNoteApplication(Nolock) CNA inner join Bean.CreditNoteApplicationDetail(Nolock) CNAD on CNA.Id=CNAD.CreditNoteApplicationId where CNA.CompanyId=@CompanyId and CNA.InvoiceId=@CreditNoteId and CNA.CompanyId=@CompanyId and CNA.Id=@SourceId order by CNAD.RecOrder
				End

					
			END
			Else IF(@OldReverseExcess=1 and @IsCNReverseExcess=1)
			BEGIN
				
				Delete CMD from Bean.CreditMemoApplication CMA 
				join Bean.CreditMemoApplicationDetail CMD on CMA.Id=CMD.CreditMemoApplicationId where CMA.id=@CMApplicationId and CMA.CompanyId=@CompanyId
								
				INSERT INTO [Bean].[CreditMemoApplicationDetail]
			   ([Id],[CreditMemoApplicationId],[DocumentId],[DocumentType],[DocCurrency],[CreditAmount],[BaseCurrencyExchangeRate],[COAId],[DocDescription],[TaxId],[TaxRate],[TaxIdCode],[TaxAmount],[TotalAmount],[RecOrder],[DocNo])

					Select NewId() as Id,@CMApplicationId,CNAD.DocumentId,CNAD.DocumentType,CNAD.DocCurrency,

					Case When @IsGSTSettings =1 and @IsInvoiceGstActivate=1 and CNAD.TaxIdCode<>'NA' THEN /*ISNULL(ID.DocAmount,0)*/Isnull((Select DocAmount from @TaxCode where DocumentId=CNAD.Id and CompanyId=@CompanyId),0) Else Isnull(CNAD.TotalAmount,0) END AS CreditAmount,


					CNAD.BaseCurrencyExchangeRate,
					(Select VenCOAId from Bean.COAMappingDetail where CustCOAId=CNAD.COAId and Status=1) as COAId,

					CNAD.DocDescription as DocDescription,

					-------TaxId
					Case When @IsGSTSettings=1 and @IsInvoiceGstActivate=1 
					THEN 
						Case When CNAD.TaxIdCode='NA' Then (Select Id from Bean.TaxCode where Code='NA' and TaxRate is null and CompanyId=@CompanyId)
					Else
					(Select TaxId from @TaxCode where DocumentId=CNAD.Id and CustTaxId=CNAD.TaxId and CompanyId=@CompanyId)
					End
					WHEN @IsGSTSettings=0 and @IsInvoiceGstActivate=1 
					THEN (Select Id from Bean.TaxCode where Code='NA' and TaxRate is null and CompanyId=@CompanyId) END as TaxId,
					
					----TaxRate
					Case When @IsGSTSettings =1 and @IsInvoiceGstActivate=1 
					THEN 
						Case When CNAD.TaxIdCode='NA' Then (Select TaxRate from Bean.TaxCode where Code='NA' and TaxRate is null and CompanyId=@CompanyId)
					Else 
					(Select TaxRate from @TaxCode where DocumentId=CNAD.Id and CustTaxId=CNAD.TaxId and CompanyId=@CompanyId)
					End
					WHEN @IsGSTSettings=1 and @IsInvoiceGstActivate=0 
					THEN (Select TaxRate from Bean.TaxCode where Code='NA' and TaxRate is null and CompanyId=@CompanyId) END as TaxRate,

					CASE WHEN @IsGSTSettings =1 and @IsInvoiceGstActivate=1
					THEN
						Case When CNAD.TaxIdCode='NA' Then (Select Code from Bean.TaxCode where Code='NA' and TaxRate is null and CompanyId=@CompanyId)
					Else 
					 (Select TaxIdCode from @TaxCode where DocumentId=CNAD.Id and CustTaxId=CNAD.TaxId and CompanyId=@CompanyId)
					 End
					WHEN @IsGSTSettings=0 and @IsInvoiceGstActivate=1 
					THEN (Select Code from Bean.TaxCode where Code='NA' and TaxRate is null and CompanyId=@CompanyId) END as TaxIdCode,

					CASE WHEN @IsGSTSettings =1 and @IsInvoiceGstActivate=1 And CNAD.TaxIdCode<>'NA'
					THEN ISNULL((Select DocTaxAmount from @TaxCode where DocumentId=CNAD.Id and CompanyId=@CompanyId),0) Else 0 END as TaxAmount,

					ISNULL(CNAD.TotalAmount,0) as TotalAmount,

					CNAD.RecOrder,CNAD.DocNo 
					from Bean.CreditNoteApplication(Nolock) CNA inner join Bean.CreditNoteApplicationDetail(Nolock) CNAD on CNA.Id=CNAD.CreditNoteApplicationId where CNA.CompanyId=@CompanyId and CNA.InvoiceId=@CreditNoteId and CNA.CompanyId=@CompanyId and CNA.Id=@SourceId order by CNAD.RecOrder
								
			END
			Else IF(@OldReverseExcess=0 and @IsCNReverseExcess=0)
			BEGIN
				Insert Into @Temp
				Select Id,DocumentId,CreditAmount From Bean.CreditNoteApplicationDetail  Where CreditNoteApplicationId=@cnapplicationid Order By RecOrder
				Select @RecCount=Count(*) From @Temp

				Set @Count=1
				While @RecCount>=@Count
				BEGIN
					Select @Detailid= DetailId,@DocumentID=DocumentId,@DetailCreditAmount=CreditAmount From @Temp Where S_No=@Count
					Set @RoundingAmount=0
					Set @IsCreditZero=0
					Set @BalanceAmount=0		
					Set @Count+=1;

					Select @BillId=Id from Bean.Bill where PayrollId=@DocumentID and CompanyId=@CompanyId and Nature=@IntercoNature

					If (@BillId is null)
					RAISERROR ('Corresponding Bill is not available',16,1);

					
					If Exists(Select Id from Bean.CreditMemoApplicationDetail(nolock) where CreditMemoApplicationId=@CMApplicationId and DocumentId=@BillId)
					Begin ---- If the rcord exists
						
						Select @DocumentGrandTotal=GrandTotal,@BaseBalance=BaseBalanceAmount,@DocExchangeRate=ExchangeRate,@OldRoundingAmount=RoundingAmount,@BalanceAmount=BalanceAmount,@oldDetailDocState=DocumentState from Bean.Bill(Nolock) where CompanyId=@companyId and DocSubType='Interco' and Id=@BillId

						Select @OldDetailAmount=CreditAmount from Bean.CreditMemoApplicationDetail(Nolock) where CreditMemoApplicationId=@CMApplicationId and DocumentId=@BillId
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

								Update Bean.Bill Set ModifiedBy=@System,ModifiedDate=@currentDate,BalanceAmount=@BalanceAmount,DocumentState=@DocState,
								BaseBalanceAmount=@BaseBalance,RoundingAmount=Case when @DocState=@NotPaid Then @RoundingAmount Else 0 End  Where CompanyId=@companyId and Id=@BillId and DocumentState<>'Void'


								--Journal State need to update

								Update J Set J.DocumentState=B.DocumentState,J.BalanceAmount=B.BalanceAmount,J.ModifiedBy=B.ModifiedBy,J.ModifiedDate=B.ModifiedDate from Bean.Journal J
								Join Bean.Bill B on B.Id=J.DocumentId and j.CompanyId=@companyId and B.CompanyId=@companyId
								where J.DocumentId=@BillId and J.companyId=@companyId



								If(@DetailCreditAmount<>0)
								Begin
								Update CNAD Set		CNAd.CreditAmount=@DetailCreditAmount,CNAD.DocDescription=CNADType.DocDescription,CNAD.DocNo=CNADType.DocNo from Bean.CreditMemoApplicationDetail CNAD join Bean.CreditMemoApplicationDetail CNADType on CNAD.CreditMemoApplicationId=@CMApplicationId and CNAD.DocumentId=@BillId where CNAd.DocumentId=@BillId and CNAD.CreditMemoApplicationId=@CMApplicationId
								End
								Else
								Begin
									Delete from Bean.CreditMemoApplicationDetail where CreditMemoApplicationId=@CreditMemoId	and DocumentId=@BillId 
								End



								Insert Into @BCDocumentHistoryType(TransactionId,CompanyId,DocumentId,DocType,DocSubType,DocState,DocCurrency,DocAmount,DocBalanaceAmount,ExchangeRate,BaseAmount,BaseBalanaceAmount,StateChangedBy,PostingDate,DocAppliedAmount,BaseAppliedAmount)

								Select @CMApplicationId,CompanyId,@BillId,DocType,DocSubType,DocumentState,DocCurrency,Round(GrandTotal,2) As DocAmount,Round(BalanceAmount,2) As DocBalanceAmount,ExchangeRate,Case When DocumentState=@NotApplied Then  BaseGrandTotal Else 0 End As BaseAmount, BaseBalanceAmount As BaseBalanceAmount,@System,@ApplicationDate,-@CreditAmount As DocAppliedAmount,Case When @IsCreditZero=1 Then 0 Else -Round(@CreditAmount*@DocExchangeRate,2)+ISNULL(@RoundingAmount,0) End As BaseAppliedAmount From Bean.Bill(Nolock) Where Id=@BillId
				
								--Exec [dbo].[Bean_DocumentHistory] @BCDocumentHistoryType



							End--End of edit mode is not 0
							
						End
						
						
					End--If not exists
					
					Else--If Not exists then need to add
					Begin
						If (@DetailCreditAmount<>0)---If Detail Credit Amoun is greater than zero then insert
						Begin
							
							Select @DocumentGrandTotal=GrandTotal,@BaseBalance=BaseBalanceAmount,@DocExchangeRate=ExchangeRate,@OldRoundingAmount=RoundingAmount,@BillId=Id,@BalanceAmount=BalanceAmount from Bean.Bill(Nolock) where CompanyId=@companyId and DocSubType=@IntercoNature and PayrollId=@DocumentID

							If(@BillId is null)
								RAISERROR ('Corresponding Bill is not available',16,1);		
								
							Set @BalanceAmount-=@DetailCreditAmount;						
							
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

							INSERT INTO Bean.CreditMemoApplicationDetail
							(Id, CreditMemoApplicationId, DocumentId,DocumentType, DocCurrency,CreditAmount, BaseCurrencyExchangeRate, DocDescription, COAId,TaxId,TaxRate, TaxIdCode,TaxAmount,TotalAmount,RecOrder,DocNo,RoundingAmount)
							Select NEWID(),@CMApplicationId,@BillId,@BillDocument,CNADetail.DocCurrency,CNADetail.CreditAmount,CNADetail.BaseCurrencyExchangeRate,CNADetail.DocDescription,null,null,null,null,null,CNADetail.TotalAmount,CNADetail.RecOrder,CNADetail.DocNo,@RoundingAmount From Bean.CreditNoteApplicationDetail(Nolock) CNADetail where CNADetail.Id=@Detailid

							IF((Select BalanceAmount from Bean.Bill(Nolock) where Id=@BillId and CompanyId=@companyId and DocSubType='Interco')<@DetailCreditAmount)
							BEGIN
								RAISERROR ('Credit Amount Canot be greater than the Balance Amount',16,1);
							END

							--Here we are updating the modified by, modified date, balance amount, state and base balance amount
							Update Bean.Bill Set ModifiedBy=@System,ModifiedDate=@currentDate,BalanceAmount-=@DetailCreditAmount,DocumentState=@DocState,
							BaseBalanceAmount=@BaseBalance,RoundingAmount=0  Where CompanyId=@companyId and Id=@BillId and DocumentState<>'Void'

							--Journal State need to update

							Update J Set J.DocumentState=B.DocumentState,J.BalanceAmount=B.BalanceAmount,J.ModifiedBy=B.ModifiedBy,J.ModifiedDate=B.ModifiedDate from Bean.Journal J
							Join Bean.Bill B on B.Id=J.DocumentId and j.CompanyId=@companyId and B.CompanyId=@companyId
								where J.DocumentId=@BillId and J.companyId=@companyId

							Update Bean.DocumentHistory set AgingState='Deleted' where DocumentId=@BillId and TransactionId=@CMApplicationId and CompanyId=@companyId and AgingState is null
							Insert Into Bean.DocumentHistory(Id,TransactionId,CompanyId,DocumentId,DocType,DocSubType,DocState,DocCurrency,DocAmount,DocBalanaceAmount,ExchangeRate,BaseAmount,BaseBalanaceAmount,StateChangedBy,PostingDate,DocAppliedAmount,BaseAppliedAmount,StateChangedDate)
							Select NEWID(),@CMApplicationId,CompanyId,@BillId,DocType,DocSubType,DocumentState,DocCurrency,Round(GrandTotal,2) As DocAmount,Round(BalanceAmount,2) As DocBalanceAmount,ExchangeRate,Round(GrandTotal*ExchangeRate,2) As BaseAmount,Round(BalanceAmount*ExchangeRate,2) As BaseBalanceAmount,@System,@ApplicationDate,  -Round(@DetailCreditAmount,2) As DocAppliedAmount,-ROUND(@DetailCreditAmount*ExchangeRate,2)/*+Isnull(@RoundingAmount,0)*/ As BaseAppliedAmount,@currentDate From Bean.Bill(Nolock) Where Id=@BillId

							
						END
						--Set @Count=@Count+1

					End----End of If Not exists
					
							
					
			END
		END
		End
		Else
		Begin
			Print 'Add Mode'
		    Set @IsAdd=1
			Set @CMApplicationId=NEWID()
			INSERT INTO [Bean].[CreditMemoApplication] ([Id],[CreditMemoId],[CompanyId],[CreditMemoApplicationDate],[CreditMemoApplicationResetDate],[IsNoSupportingDocumentActivated],[IsNoSupportingDocument],[CreditAmount],[Remarks],[CreditMemoApplicationNumber],[UserCreated],[CreatedDate],[ModifiedBy],[ModifiedDate],[Status],[ExchangeRate],[IsRevExcess],[DocumentId],[ClearingState])

			SELECT @CMApplicationId As [Id],@CreditMemoId as CreditMemoId,[CompanyId],[CreditNoteApplicationDate],[CreditNoteApplicationResetDate],[IsNoSupportingDocumentActivated],[IsNoSupportingDocument],[CreditAmount],[Remarks],[CreditNoteApplicationNumber],[UserCreated],[CreatedDate],[ModifiedBy],[ModifiedDate],[Status],[ExchangeRate],[IsRevExcess],@CNApplicationId,null FROM Bean.CreditNoteApplication(Nolock) where Id=@CNApplicationId and CompanyId=@CompanyId

			If(@IsCNReverseExcess=1)
			Begin
				INSERT INTO [Bean].[CreditMemoApplicationDetail]
			   ([Id],[CreditMemoApplicationId],[DocumentId],[DocumentType],[DocCurrency],[CreditAmount],[BaseCurrencyExchangeRate],[COAId],[DocDescription],[TaxId],[TaxRate],[TaxIdCode],[TaxAmount],[TotalAmount],[RecOrder],[DocNo])

					Select NewId() as Id,@CMApplicationId,CNAD.DocumentId,CNAD.DocumentType,CNAD.DocCurrency,

					Case When @IsGSTSettings =1 and @IsInvoiceGstActivate=1 and CNAD.TaxIdCode<>'NA' THEN /*ISNULL(ID.DocAmount,0)*/Isnull((Select DocAmount from @TaxCode where DocumentId=CNAD.Id and CompanyId=@CompanyId),0) Else Isnull(CNAD.TotalAmount,0) END AS CreditAmount,


					CNAD.BaseCurrencyExchangeRate,
					(Select VenCOAId from Bean.COAMappingDetail where CustCOAId=CNAD.COAId and Status=1) as COAId,

					CNAD.DocDescription as DocDescription,

					-------TaxId
					Case When @IsGSTSettings=1 and @IsInvoiceGstActivate=1 
					THEN 
						Case When CNAD.TaxIdCode='NA' Then (Select Id from Bean.TaxCode where Code='NA' and TaxRate is null and CompanyId=@CompanyId)
					Else
					(Select TaxId from @TaxCode where DocumentId=CNAD.Id and CustTaxId=CNAD.TaxId and CompanyId=@CompanyId)
					End
					WHEN @IsGSTSettings=0 and @IsInvoiceGstActivate=1 
					THEN (Select Id from Bean.TaxCode where Code='NA' and TaxRate is null and CompanyId=@CompanyId) END as TaxId,
					
					----TaxRate
					Case When @IsGSTSettings =1 and @IsInvoiceGstActivate=1 
					THEN 
						Case When CNAD.TaxIdCode='NA' Then (Select TaxRate from Bean.TaxCode where Code='NA' and TaxRate is null and CompanyId=@CompanyId)
					Else 
					(Select TaxRate from @TaxCode where DocumentId=CNAD.Id and CustTaxId=CNAD.TaxId and CompanyId=@CompanyId)
					End
					WHEN @IsGSTSettings=1 and @IsInvoiceGstActivate=0 
					THEN (Select TaxRate from Bean.TaxCode where Code='NA' and TaxRate is null and CompanyId=@CompanyId) END as TaxRate,

					CASE WHEN @IsGSTSettings =1 and @IsInvoiceGstActivate=1
					THEN
						Case When CNAD.TaxIdCode='NA' Then (Select Code from Bean.TaxCode where Code='NA' and TaxRate is null and CompanyId=@CompanyId)
					Else 
					 (Select TaxIdCode from @TaxCode where DocumentId=CNAD.Id and CustTaxId=CNAD.TaxId and CompanyId=@CompanyId)
					 End
					WHEN @IsGSTSettings=0 and @IsInvoiceGstActivate=1 
					THEN (Select Code from Bean.TaxCode where Code='NA' and TaxRate is null and CompanyId=@CompanyId) END as TaxIdCode,

					CASE WHEN @IsGSTSettings =1 and @IsInvoiceGstActivate=1 And CNAD.TaxIdCode<>'NA'
					THEN ISNULL((Select DocTaxAmount from @TaxCode where DocumentId=CNAD.Id and CompanyId=@CompanyId),0) Else 0 END as TaxAmount,

					ISNULL(CNAD.TotalAmount,0) as TotalAmount,

					CNAD.RecOrder,CNAD.DocNo 
					from Bean.CreditNoteApplication(Nolock) CNA inner join Bean.CreditNoteApplicationDetail(Nolock) CNAD on CNA.Id=CNAD.CreditNoteApplicationId where CNA.CompanyId=@CompanyId and CNA.InvoiceId=@CreditNoteId and CNA.CompanyId=@CompanyId and CNA.Id=@SourceId order by CNAD.RecOrder
			End

			Else---If it is not reverse excess is not checked
			Begin
				Print 'Insert Detail'
				Insert Into @Temp
				Select Id,DocumentId,CreditAmount From Bean.CreditNoteApplicationDetail Where CreditNoteApplicationId=@CNApplicationId and CreditAmount<>0 Order By RecOrder
				Select @RecCount=Count(*) From @Temp

				Set @Count=1
				While @RecCount>=@Count
				Begin
					Select @Detailid= DetailId,@DocumentID=DocumentId,@DetailCreditAmount=CreditAmount From @Temp Where S_No=@Count
					Set @BalanceAmount=0

					Select @DocumentGrandTotal=GrandTotal,@BaseBalance=BaseBalanceAmount,@DocExchangeRate=ExchangeRate,@OldRoundingAmount=RoundingAmount,@BillId=Id,@BalanceAmount=BalanceAmount from Bean.Bill(Nolock) where CompanyId=@companyId and DocSubType=@IntercoNature and PayrollId=@DocumentID
					If(@BillId is null)
					RAISERROR ('Corresponding Bill is not available',16,1);

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

					INSERT INTO Bean.CreditMemoApplicationDetail
					(Id, CreditMemoApplicationId, DocumentId,DocumentType, DocCurrency,CreditAmount, BaseCurrencyExchangeRate, DocDescription, COAId,TaxId,TaxRate, TaxIdCode,TaxAmount,TotalAmount,RecOrder,DocNo,RoundingAmount)
					Select NEWID(),@CMApplicationId,@BillId,@BillDocument,CNADetail.DocCurrency,CNADetail.CreditAmount,CNADetail.BaseCurrencyExchangeRate,CNADetail.DocDescription,null,null,null,null,null,CNADetail.TotalAmount,CNADetail.RecOrder,CNADetail.DocNo,@RoundingAmount From Bean.CreditNoteApplicationDetail(Nolock) CNADetail where CNADetail.Id=@Detailid

					--IF((Select BalanceAmount from Bean.Bill where Id=@BillId and CompanyId=@companyId and DocSubType='Interco')<@DetailCreditAmount)
					--BEGIN
					--	RAISERROR ('Credit Amount Canot be greater than the Balance Amount',16,1);
					--END

					--Here we are updating the modified by, modified date, balance amount, state and base balance amount
					Update Bean.Bill Set ModifiedBy=@System,ModifiedDate=@currentDate,BalanceAmount-=@DetailCreditAmount,DocumentState=@DocState,
					BaseBalanceAmount=@BaseBalance,RoundingAmount=0  Where CompanyId=@companyId and Id=@BillId and DocumentState<>'Void'

					--Journal State need to update

					Update J Set J.DocumentState=B.DocumentState,J.BalanceAmount=B.BalanceAmount,J.ModifiedBy=B.ModifiedBy,J.ModifiedDate=B.ModifiedDate from Bean.Journal J
					Join Bean.Bill B on B.Id=J.DocumentId and j.CompanyId=@companyId and B.CompanyId=@companyId
						where J.DocumentId=@BillId and J.companyId=@companyId

					Update Bean.DocumentHistory set AgingState='Deleted' where DocumentId=@BillId and TransactionId=@CMApplicationId and CompanyId=@companyId and AgingState is null
					Insert Into Bean.DocumentHistory(Id,TransactionId,CompanyId,DocumentId,DocType,DocSubType,DocState,DocCurrency,DocAmount,DocBalanaceAmount,ExchangeRate,BaseAmount,BaseBalanaceAmount,StateChangedBy,PostingDate,DocAppliedAmount,BaseAppliedAmount,StateChangedDate)
					Select NEWID(),@CMApplicationId,CompanyId,@BillId,DocType,DocSubType,DocumentState,DocCurrency,Round(GrandTotal,2) As DocAmount,Round(BalanceAmount,2) As DocBalanceAmount,ExchangeRate,Round(GrandTotal*ExchangeRate,2) As BaseAmount,Round(BalanceAmount*ExchangeRate,2) As BaseBalanceAmount,@System,@ApplicationDate,  -Round(@DetailCreditAmount,2) As DocAppliedAmount,-ROUND(@DetailCreditAmount*ExchangeRate,2)/*+Isnull(@RoundingAmount,0)*/ As BaseAppliedAmount,@currentDate From Bean.Bill(Nolock) Where Id=@BillId and companyid=@CompanyId

					Set @Count=@Count+1
				End
			End
		End


		Insert Into @BCDocumentHistoryType(TransactionId,CompanyId,DocumentId,DocType,DocSubType,DocState,DocCurrency,DocAmount,DocBalanaceAmount,ExchangeRate,BaseAmount,BaseBalanaceAmount,StateChangedBy,PostingDate,DocAppliedAmount,BaseAppliedAmount)

		
		Select @CreditMemoId,CompanyId,@CMApplicationId,'Credit Memo','Application','Posted',@DocCurrency,Round(CreditAmount,2) As DocAmount,Round(CreditAmount,2) As DocBalanceAmount,ExchangeRate,Round(CreditAmount*@CreditNoteExchangeRate,2) As BaseAmount,Round(CreditAmount*ExchangeRate,2) As BaseBalanceAmount,@System,@ApplicationDate,  Round(@CreditAmount,2) As DocAppliedAmount,ROUND(@CreditAmount*ExchangeRate,2) As BaseAppliedAmount From Bean.CreditMemoApplication(Nolock) Where Id=@CMApplicationId and CompanyId=@companyId
				
		--Exec [dbo].[Bean_DocumentHistory] @BCDocumentHistoryType
				

		---Updateing The CreditNote DocumentState and Balanceamount
		Set @RoundingAmount=0;
		Set @OldRoundingAmount=0;
		Set @BalanceAmount=0;
		Select @DocumentGrandTotal=GrandTotal,@BaseBalance=BaseBalanceAmount,@DocExchangeRate=ExchangeRate,@OldRoundingAmount=RoundingAmount,@BaseGrandTotal=BaseGrandTotal,@BalanceAmount=BalanceAmount,@OldCNState=DocumentState from Bean.CreditMemo where CompanyId=@companyId and DocSubType='Interco' and Id=@CreditMemoId
		Set @BalanceAmount-=Case When @IsAdd=1 Then @CreditAmount Else Isnull(@CreditAmount,0)-Isnull(@OldCreditAmount,0)End;

		If(@IsAdd=1)--If add mode
		Begin
			
			IF(@DocumentGrandTotal=@DetailCreditAmount)
			Begin
				Set @RoundingAmount=Case When @OldRoundingAmount<>0 and @OldRoundingAmount is not null Then @OldRoundingAmount Else  Round(@CreditAmount*@CreditNoteExchangeRate,2)-@BaseGrandTotal End;
				Set @DocState=@FullyApplied
				Set @BaseBalance=0
			End
			Else
			Begin
				Set @BaseBalance -=Round((isnull(@CreditAmount,0)*@CreditNoteExchangeRate),2);
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
						Set @RoundingAmount=Case When @OldRoundingAmount<>0 and @OldRoundingAmount is not null Then @OldRoundingAmount Else  Round(@CreditAmount*@CreditNoteExchangeRate,2)-@BaseGrandTotal End;
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
					Set @BaseBalance=Case When @OldCreditAmount>@CreditAmount Then @BaseBalance+ROUND(ABS(@OldCreditAmount-@CreditAmount)*@CreditNoteExchangeRate,2) Else @BaseBalance-ROUND(ABS(@OldCreditAmount-@CreditAmount)*@CreditNoteExchangeRate,2) End;
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


		Update Bean.CreditMemo Set ModifiedBy=@System,ModifiedDate=@currentDate,BalanceAmount=@BalanceAmount,DocumentState=@DocState,
		RoundingAmount= Case When @DocState=@PartialApplied Then @RoundingAmount Else 0 End,BaseBalanceAmount=@BaseBalance  Where CompanyId=@companyId and Id=@CreditMemoId and DocumentState<>'Void'

		--Journal State need to update for Credit Note

		Update J Set J.DocumentState=CM.DocumentState,J.BalanceAmount=CM.BalanceAmount,J.ModifiedBy=CM.ModifiedBy,J.ModifiedDate=CM.ModifiedDate from Bean.Journal J
		Join Bean.CreditMemo CM on CM.Id=J.DocumentId and j.CompanyId=@companyId and CM.CompanyId=@companyId
		where J.DocumentId=@CreditMemoId and J.companyId=@companyId


		Update Bean.CreditMemoApplication Set RoundingAmount=case when @DocState=@FullyApplied Then @RoundingAmount Else 0 End Where id=@CMApplicationId and CompanyId=@companyId and CreditMemoId=@CreditMemoId

		Insert Into @BCDocumentHistoryType(TransactionId,CompanyId,DocumentId,DocType,DocSubType,DocState,DocCurrency,DocAmount,DocBalanaceAmount,ExchangeRate,BaseAmount,BaseBalanaceAmount,StateChangedBy,PostingDate,DocAppliedAmount,BaseAppliedAmount)

		Select @CMApplicationId,CompanyId,@CreditMemoId,DocType,DocSubType,DocumentState,DocCurrency,Round(GrandTotal,2) As DocAmount,Round(BalanceAmount,2) As DocBalanceAmount,ExchangeRate,/*Round(GrandTotal*ExchangeRate,2)*/Case When DocumentState=@NotApplied Then  BaseGrandTotal Else 0 End As BaseAmount, BaseBalanceAmount As BaseBalanceAmount,@System,@ApplicationDate,/*Round(GrandTotal,2)*/-@CreditAmount As DocAppliedAmount,-Round(@CreditAmount*@CreditNoteExchangeRate,2)+ISNULL(@RoundingAmount,0) As BaseAppliedAmount From Bean.CreditMemo(Nolock) Where Id=@CreditMemoId
				
		Exec [dbo].[Bean_DocumentHistory] @BCDocumentHistoryType


		If(@IsCNReverseExcess=1)
		Begin
			Exec Bean_Multiple_Posting @companyId,@CreditMemoDocument,'Interco',@CreditMemoId,@CMApplicationId,1,0, ' '
		End


	END---END of Application doctype

	Else If(@DocType=@BillDocument)
	BEGIN
		IF Exists(Select Id from Bean.DebitNote(Nolock) where Id=@SourceId and CompanyId=@CompanyId)
		Begin
			
			 Set @IsGSTSettings= Isnull((Select IsGstSetting from Common.Company(Nolock) where Id = @ServiceEntityId and ParentId=@CompanyId),0)
	 

			 Select @DocDesc=Remarks,@DocDate=DocDate,@IsInvoiceGstActivate=ISNULL(IsGstSettings,0) from Bean.DebitNote(Nolock) where Id=@SourceId and CompanyId=@CompanyId
			 
				 If (@IsInvoiceGstActivate=1 and @IsGSTSettings=1)
				 Begin
					Insert into @TaxCode
					Select A.CompanyId,A.Id,B.TaxId,A.TaxRate,A.VenTaxCode,A.TaxIdCode,B.Id,
		 
					Case When isnull(A.TaxRate,0)=isnull(B.TaxRate,0) Then Isnull(B.DocTaxAmount,0) 
					Else Case When A.TaxRate=0 Then 0 Else ROUND(B.DocTotalAmount-Round(((B.DocTotalAmount*100)/(100+Isnull(A.TaxRate,0))),2),2) End End As DocTaxAmount,

					Case When isnull(A.TaxRate,0)=isnull(B.TaxRate,0) Then B.DocAmount 
					Else Case When A.TaxRate=0 Then B.DocTotalAmount Else 
					Round(((B.DocTotalAmount*100)/(100+Isnull(A.TaxRate,0))),2) End End As DocAmount,

					Case When isnull(A.TaxRate,0)=isnull(B.TaxRate,0) Then B.BaseTaxAmount 
					Else Case When A.TaxRate=0 Then 0 Else ROUND(B.BaseTotalAmount-Round(((B.BaseTotalAmount*100)/(100+Isnull(A.TaxRate,0))),2),2)End End As BaseTaxAmount,

					Case When isnull(A.TaxRate,0)=isnull(B.TaxRate,0) Then B.BaseAmount 
					Else Case When A.TaxRate=0 Then B.BaseTotalAmount Else 
					Round(((B.BaseTotalAmount*100)/(100+Isnull(A.TaxRate,0))),2) End End As BaseAmount

					from 
					(
					select taxMap.CompanyId,taxMapDetail.CustTaxCode,taxMapDetail.VenTaxCode,tax.Id,TaxRate,tax.EffectiveFrom,tax.EffectiveTo,CONCAT(Code,+'-'+Case When TaxRate is null Then 'NA' Else CAST(TaxRate as varchar(20))+'%' END) as TaxIdCode 
					from Bean.TaxCodeMapping(Nolock) taxMap
					join Bean.TaxCodeMappingDetail(Nolock) taxMapDetail on taxMap.Id=taxMapDetail.TaxCodeMappingId
					join Bean.TaxCode(Nolock) tax on taxMapDetail.VenTaxCode=tax.Code and tax.CompanyId=@CompanyId
					--join Bean.InvoiceDetail invd on invd.InvoiceId='844dc373-1e1a-4e74-a930-85851278dd41'
					where taxMap.CompanyId=@CompanyId and EffectiveFrom<=@DocDate and (EffectiveTo is null or EffectiveTo>=@DocDate)) As A
					join
					(
					select  tax.Code,Id.TaxId,Id.Id,ID.DocAmount,ID.DocTaxAmount,ID.DocTotalAmount,ID.BaseAmount,ID.BaseTaxAmount,ID.BaseTotalAmount,ID.TaxRate from Bean.TaxCode(Nolock) tax
					join Bean.DebitNoteDetail(Nolock) ID on tax.Id=Id.TaxId and tax.CompanyId=@CompanyId
					where Id.DebitNoteId=@SourceId) As B
					on A.CustTaxCode=B.Code and A.CompanyId=@CompanyId
				 End
			 

			 IF @DocType=@BillDocument
			 Begin
			 If Not exists (Select Id from Bean.Bill(Nolock) where PayrollId=@SourceId and CompanyId=@CompanyId)
				Begin--Begin of Bill New
				Set @BillId=NEWID()
				Insert into Bean.Bill(Id,CompanyId,DocSubType,SystemReferenceNumber,DocNo,ServiceCompanyId,EntityId,Nature,DocumentDate,PostingDate,CreditTermsId,DueDate,DocCurrency,ExchangeRate,IsNoSupportingDocument,DocDescription,BaseCurrency,GSTExCurrency,GSTExchangeRate,GSTTotalAmount,GrandTotal,IsGstSettings,IsMultiCurrency,UserCreated,CreatedDate,ModifiedBy,ModifiedDate,Status,BalanceAmount,PayrollId,IsExternal,DocType,DocumentState,EntityType,CreditTermValue,IsSegmentReporting,IsAllowableDisallowable,IsGSTCurrencyRateChanged,IsBaseCurrencyRateChanged)

				Select @BillId as Id,CompanyId as CompanyId,@IntercoNature as DocSubType,DocNo as SystemReferenceNumber,DocNo as DocNo,@ServiceEntityId as ServiceCompanyId,@EntityId as EntityId,Nature as Nature,DocDate as DocumentDate,DocDate as PostingDate,CreditTermsId as CreditTermsId,DueDate as DueDate,DocCurrency as DocCurrency,ExchangeRate as ExchangeRate,IsNoSupportingDocument as IsNoSupportingDocument,@DocDesc as DocDescription,ExCurrency as BaseCurrency,GSTExCurrency as GSTExCurrency,GSTExchangeRate as GSTExchangeRate,
				Case When GSTTotalAmount is null  Then 0 Else GSTTotalAmount End as GSTTotalAmount,
				GrandTotal as GrandTotal,@IsGSTSettings as IsGstSettings,IsMultiCurrency as IsMultiCurrency,@System as UserCreated,GETUTCDATE() as CreatedDate,null as ModifiedBy,null as ModifiedDate,Status as Status,BalanceAmount as BalanceAmount,Id as PayrollId,1 as IsExternal,@BillDocument as DocType,DocumentState as DocumentState,@EntityType as EntityType,0 as CreditTermValue,0 as IsSegmentReporting,0 as IsAllowableDisallowable,0 as IsGSTCurrencyRateChanged,IsBaseCurrencyRateChanged  from Bean.DebitNote(Nolock) where Id=@SourceId and CompanyId=@CompanyId

				Insert into Bean.BillDetail (Id,BillId,Description,COAId,TaxId,TaxCode,TaxType,TaxRate,DocAmount,DocTaxAmount,DocTotalAmount,BaseAmount,BaseTaxAmount,BaseTotalAmount,RecOrder,TaxIdCode,IsDisallow)

				Select NEWID() as Id,@BillId as BillId,ID.AccountDescription as Description,(Select VenCOAId from Bean.COAMappingDetail where CustCOAId=ID.COAId and Status=1) as COAId,
				-----TaxId
				Case When @IsGSTSettings =1 and @IsInvoiceGstActivate=1 
				THEN
				Case When ID.TaxIdcode='NA' Then (Select Id from Bean.TaxCode where Code='NA' and TaxRate is null and CompanyId=@CompanyId)
				Else
				 (Select TaxId from @TaxCode where DocumentId=ID.Id and CustTaxId=Id.TaxId and CompanyId=@CompanyId)
				End
				When @IsGSTSettings=1 and @IsInvoiceGstActivate=0 
				Then (Select Id from Bean.TaxCode where Code='NA' and TaxRate is null and CompanyId=@CompanyId)
				   END as TaxId,
				------TaxCode
				Case 
				When @IsGSTSettings =1 and @IsInvoiceGstActivate=1 
				THEN 
					Case When ID.TaxIdcode='NA' Then (Select code from Bean.TaxCode where Code='NA' and TaxRate is null and CompanyId=@CompanyId)
				Else
				  (Select TaxCode from @TaxCode where DocumentId=ID.Id and CustTaxId=Id.TaxId and CompanyId=@CompanyId)
				End
				When @IsGSTSettings=1 and @IsInvoiceGstActivate=0
				 Then (Select Code from Bean.TaxCode where Code='NA' and TaxRate is null and CompanyId=@CompanyId) 
				 END as TaxCode,


				 'Output' as TaxType,

				 -----TaxRate
				Case When @IsGSTSettings =1 and @IsInvoiceGstActivate=1 THEN 
				Case When ID.TaxIdcode='NA' Then (Select TaxRate from Bean.TaxCode where Code='NA' and TaxRate is null and CompanyId=@CompanyId)
				Else
					(Select TaxRate from @TaxCode where DocumentId=ID.Id and CustTaxId=Id.TaxId and CompanyId=@CompanyId)
				End
				  When @IsGSTSettings=1 and @IsInvoiceGstActivate=0 Then 
				  (Select TaxRate from Bean.TaxCode where Code='NA' and TaxRate is null and CompanyId=@CompanyId) END as TaxRate,


				 Case When @IsGSTSettings =1 and @IsInvoiceGstActivate=1 and ID.TaxIDCode<>'NA' THEN Isnull((Select DocAmount from @TaxCode where DocumentId=ID.Id and CompanyId=@CompanyId),0) Else Isnull(ID.DocTotalAmount,0) END  as DocAmount,


				Case When @IsGSTSettings =1 and @IsInvoiceGstActivate=1 and ID.TaxIDCode<>'NA' THEN isnull((Select DocTaxAmount from @TaxCode where DocumentId=ID.Id and CompanyId=@CompanyId),0) Else 0 END as DocTaxAmount,
		
				isnull(ID.DocTotalAmount,0) as DocTotalAmount,
		
				Case When @IsGSTSettings =1 and @IsInvoiceGstActivate=1 and ID.TaxIDCode<>'NA' Then isnull((Select BaseAmount from @TaxCode where DocumentId=ID.Id and CompanyId=@CompanyId),0) Else ISNULL(ID.BaseTotalAmount,0) End as BaseAmount,

				Case When @IsGSTSettings =1 and @IsInvoiceGstActivate=1 and ID.TaxIDCode<>'NA' THEN isnull((Select BaseTaxAmount from @TaxCode where DocumentId=ID.Id and CompanyId=@CompanyId),0) Else 0 END As BaseTaxAmount,
		
				ID.BaseTotalAmount as BaseTotalAmount,
				ID.RecOrder as RecOrder,
				-------TaxIdCode
				Case When @IsGSTSettings =1 and @IsInvoiceGstActivate=1
				 THEN 
				 Case When ID.TaxIdcode='NA' Then (Select Code from Bean.TaxCode where Code='NA' and TaxRate is null and CompanyId=@CompanyId)
				Else
				(Select TaxIdCode from @TaxCode where DocumentId=ID.Id and CustTaxId=Id.TaxId and CompanyId=@CompanyId)
				End
				  When @IsGSTSettings=1 and @IsInvoiceGstActivate=0 Then (Select Code from Bean.TaxCode(Nolock) where Code='NA' and TaxRate is null and CompanyId=@CompanyId) END as TaxIdCode,0 as IsDisallow  from Bean.DebitNoteDetail(Nolock) ID Join Bean.DebitNote(Nolock) I on ID.DebitNoteId=I.Id where ID.DebitNoteId=@SourceId and I.CompanyId=@CompanyId
				End---End Of Bill New


			Else
			Begin--Begin Of Edit Bill
				Set @OldServiceEntity=(Select ServiceCompanyId from Bean.Bill(nolock) where CompanyId=@CompanyId and PayrollId=@SourceId)
				Update B set B.ServiceCompanyId=@ServiceEntityId,b.Nature=i.Nature,b.EntityId=@EntityId,b.DocumentDate=i.DocDate,b.PostingDate=i.DocDate,B.DueDate=I.DueDate,B.CreditTermsId=I.CreditTermsId,B.DocCurrency=I.DocCurrency,B.ExchangeRate=I.ExchangeRate,B.DocDescription=I.Remarks,B.ModifiedBy=@System,B.ModifiedDate=GETUTCDATE(), B.IsGstSettings=Case When @OldServiceEntity<>@ServiceEntityId Then @IsGSTSettings Else B.IsGstSettings End, B.GrandTotal=I.GrandTotal, UserCreated=@System, DocNo=I.DocNo,SystemReferenceNumber=I.DocNo,BalanceAmount=I.BalanceAmount,B.IsGSTCurrencyRateChanged=Isnull(I.IsGSTCurrencyRateChanged,0),B.IsBaseCurrencyRateChanged=Isnull(I.IsBaseCurrencyRateChanged,0) from Bean.Bill as B 
				Inner Join Bean.DebitNote as I on B.PayrollId=I.Id and B.CompanyId=I.CompanyId where I.Id=@SourceId and I.CompanyId=@CompanyId


				--Delete Old Detail from Edit mode
				Delete BD from Bean.Bill B Inner Join Bean.BillDetail BD on B.Id=BD.BillId
				where B.PayrollId=@SourceId And B.CompanyId=@CompanyId
				Set @BillId=(Select Id from Bean.Bill(Nolock) where PayrollId=@SourceId and CompanyId=@CompanyId)
				--Insert new Bill Detail Data in Edit Mode
				Insert into Bean.BillDetail (Id,BillId,Description,COAId,TaxId,TaxCode,TaxType,TaxRate,DocAmount,DocTaxAmount,DocTotalAmount,BaseAmount,BaseTaxAmount,BaseTotalAmount,RecOrder,TaxIdCode,IsDisallow)

				Select NEWID() as Id,@BillId as BillId,ID.AccountDescription as Description,(Select VenCOAId from Bean.COAMappingDetail where CustCOAId=ID.COAId and Status=1) as COAId,
				-----TaxId
				Case When @IsGSTSettings =1 and @IsInvoiceGstActivate=1 
				THEN
				Case When ID.TaxIdcode='NA' Then (Select Id from Bean.TaxCode where Code='NA' and TaxRate is null and CompanyId=@CompanyId)
				Else
				 (Select TaxId from @TaxCode where DocumentId=ID.Id and CustTaxId=Id.TaxId and CompanyId=@CompanyId)
				End
				When @IsGSTSettings=1 and @IsInvoiceGstActivate=0 
				Then (Select Id from Bean.TaxCode where Code='NA' and TaxRate is null and CompanyId=@CompanyId)
				   END as TaxId,
				------TaxCode
				Case 
				When @IsGSTSettings =1 and @IsInvoiceGstActivate=1 
				THEN 
					Case When ID.TaxIdcode='NA' Then (Select code from Bean.TaxCode where Code='NA' and TaxRate is null and CompanyId=@CompanyId)
				Else
				  (Select TaxCode from @TaxCode where DocumentId=ID.Id and CustTaxId=Id.TaxId and CompanyId=@CompanyId)
				End
				When @IsGSTSettings=1 and @IsInvoiceGstActivate=0
				 Then (Select Code from Bean.TaxCode where Code='NA' and TaxRate is null and CompanyId=@CompanyId) 
				 END as TaxCode,


				 'Output' as TaxType,

				 -----TaxRate
				Case When @IsGSTSettings =1 and @IsInvoiceGstActivate=1 THEN 
				Case When ID.TaxIdcode='NA' Then (Select TaxRate from Bean.TaxCode where Code='NA' and TaxRate is null and CompanyId=@CompanyId)
				Else
					(Select TaxRate from @TaxCode where DocumentId=ID.Id and CustTaxId=Id.TaxId and CompanyId=@CompanyId)
				End
				  When @IsGSTSettings=1 and @IsInvoiceGstActivate=0 Then 
				  (Select TaxRate from Bean.TaxCode where Code='NA' and TaxRate is null and CompanyId=@CompanyId) END as TaxRate,


				 Case When @IsGSTSettings =1 and @IsInvoiceGstActivate=1 and ID.TaxIDCode<>'NA' THEN Isnull((Select DocAmount from @TaxCode where DocumentId=ID.Id and CompanyId=@CompanyId),0) Else Isnull(ID.DocTotalAmount,0) END  as DocAmount,


				Case When @IsGSTSettings =1 and @IsInvoiceGstActivate=1 and ID.TaxIDCode<>'NA' THEN isnull((Select DocTaxAmount from @TaxCode where DocumentId=ID.Id and CompanyId=@CompanyId),0) Else 0 END as DocTaxAmount,
		
				isnull(ID.DocTotalAmount,0) as DocTotalAmount,
		
				Case When @IsGSTSettings =1 and @IsInvoiceGstActivate=1 and ID.TaxIDCode<>'NA' Then isnull((Select BaseAmount from @TaxCode where DocumentId=ID.Id and CompanyId=@CompanyId),0) Else ISNULL(ID.BaseTotalAmount,0) End as BaseAmount,

				Case When @IsGSTSettings =1 and @IsInvoiceGstActivate=1 and ID.TaxIDCode<>'NA' THEN isnull((Select BaseTaxAmount from @TaxCode where DocumentId=ID.Id and CompanyId=@CompanyId),0) Else 0 END As BaseTaxAmount,
		
				ID.BaseTotalAmount as BaseTotalAmount,
				ID.RecOrder as RecOrder,
				-------TaxIdCode
				Case When @IsGSTSettings =1 and @IsInvoiceGstActivate=1
				 THEN 
				 Case When ID.TaxIdcode='NA' Then (Select Code from Bean.TaxCode where Code='NA' and TaxRate is null and CompanyId=@CompanyId)
				Else
				(Select TaxIdCode from @TaxCode where DocumentId=ID.Id and CustTaxId=Id.TaxId and CompanyId=@CompanyId)
				End
				  When @IsGSTSettings=1 and @IsInvoiceGstActivate=0 Then (Select Code from Bean.TaxCode(Nolock) where Code='NA' and TaxRate is null and CompanyId=@CompanyId) END as TaxIdCode,0 as IsDisallow  from Bean.DebitNoteDetail(Nolock) ID Join Bean.DebitNote(Nolock) I on ID.DebitNoteId=I.Id where ID.DebitNoteId=@SourceId and I.CompanyId=@CompanyId

				End ----End of Edit Bill
				If (@BillId Is Not NULL AND @BillId !='00000000-0000-0000-0000-000000000000')
				Begin
				 Exec [dbo].[Bean_Posting] @BillId,@BillDocument,@CompanyId
				End	
			End--DocType Bill End
		End
	END

	 Commit Transaction
	
	  
	 End Try
	 Begin Catch
	 Rollback;
	 SELECT
        @ErrorMessage = ERROR_MESSAGE(),
        @ErrorSeverity = ERROR_SEVERITY(),
        @ErrorState = ERROR_STATE();

		-- return the error inside the CATCH block
		RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState);
	 
	 --RAISERROR(ERROR_MESSAGE(),16,1)
	 End Catch
 
 End
GO
