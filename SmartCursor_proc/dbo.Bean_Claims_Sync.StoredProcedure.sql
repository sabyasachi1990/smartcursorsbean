USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[Bean_Claims_Sync]    Script Date: 16-12-2024 9.20.10 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE  PROCEDURE [dbo].[Bean_Claims_Sync]
@CompanyId int,
@ClaimId uniqueidentifier,
@BillId uniqueidentifier,
@PostingDate datetime2(7),
@IsVoid bit,
@IsPayComponent bit,
@VendorId uniqueidentifier,
@ExchangeRate decimal(15,10),
@GstExchangeRate decimal(15,10),
@IsExchangeRateEditable bit

As
Begin
--Declaraction Part
Declare @EnitityId uniqueidentifier,
		@Id uniqueidentifier,
		@ServiceEntityId int,
		@IsGstSettings bit,
		@IsMultiCurrency bit,
		@Error_Message nvarchar(MAX),
		@Error_Servirity int,
		@Error_State int,
		@ClaimNumber varchar(50),
		@CaseGroupId uniqueidentifier,
		@CreditTermsId int,
		@DocCurrency varchar(10),
		@FinanceStartDate datetime2(7),
		@FinanceEndDate datetime2(7),
		@PeriodLockPassword nvarchar(30),
		@Financial int,
		@BaseCurrency varchar(10),
		@GrandTotal money,
		@GSTTotalAmount money,
		@EntityName nvarchar(500),
		@COAId int,
		@TaxPaybleGSTCOA  nvarchar(50)='Tax payable (GST)',
		@Rounding Varchar(50) ='Rounding',
		@TaxPaybleCoaId bigint,
		@GuidZero Uniqueidentifier='00000000-0000-0000-0000-000000000000',
		@GSTExCurrency Nvarchar(10),
		@BeanEntityId uniqueidentifier
		
-- Nature
Declare @NatureTrade varchar(20) = 'Trade'
Declare @NatureOthers varchar(20) = 'Others'

----For Base Debit and Base Credit Mis match
Declare @BaseDebit Money
Declare @BaseCredit Money
Declare @DiffAmount Money
Declare @MasterBaseAmount Money
	

-- Document Constants
Declare @BillDocument varchar(20) ='Bill',
		@ClaimDocument varchar(20)='Claim',
		@Sysytem varchar(20)='System',
		@JournalDocument varchar(20)='Journal'

-- Credit Terms Name

Declare @Credit_0 varchar(20)='Credit - 0',
		@Conterol_COde nvarchar(20)='CountryOfOrigin'

-- Document State

Declare @Not_Paid_State nvarchar(20)='Not Paid',
		@Void varchar(20)='Void'

Declare @ClaimDetailIds as Table(ParentIds uniqueidentifier)

--COA Names
Declare @COAName_Reimb varchar(50)='Reimbursement (Clearing)'
Declare @EmployeeId Uniqueidentifier
Declare @ClaimItem table(Id uniqueidentifier,COAId int,ItemName nvarchar(256))
Declare @IncidentalClaim table(Id uniqueidentifier,COAId int,ItemName nvarchar(256) )
Declare @TaxCode Table(TaxId int,TaxRate decimal(15,10),TaxCode varchar(20),TaxIdCode varchar(50))
Select @EnitityId=EmployeId,@EmployeeId=EmployeId,@Id=Id,@ServiceEntityId=CompanyId,@CaseGroupId=CaseGroupId,@ClaimNumber=ClaimNumber from HR.EmployeeClaim1 (nolock) where Id=@ClaimId and ParentCompanyId=@CompanyId
Begin Transaction

IF EXISTS(Select Id from Bean.MultiCurrencySetting (nolock) where CompanyId=@CompanyId)
Begin
	SET @IsMultiCurrency=1
End
Else
Begin
	SET @IsMultiCurrency=0
End

Select @IsGstSettings=IsGstSetting,@GSTExCurrency=ISNULL(GstCurrency,'SGD') from Common.Company (nolock) where Id=@ServiceEntityId
Select @ClaimNumber=CaseNumber from WorkFlow.CaseGroup (nolock) where Id=@CaseGroupId
Select @CreditTermsId=Id from Common.TermsOfPayment (nolock) where CompanyId=@CompanyId and Name=@Credit_0
select top 1 @DocCurrency=CC.CodeValue from Common.ControlCodeCategory CCC (nolock) join common.ControlCode CC (nolock) on CCC.Id = CC.ControlCategoryId join Common.Company C (nolock) on CCC.CompanyId = C.Id where CCC.ControlCodeCategoryCode = @Conterol_COde and CCC.CompanyId = @CompanyId and C.Jurisdiction = CC.CodeKey and C.Id = @CompanyId
Select @Financial=Id,@FinanceStartDate=PeriodLockDate,@FinanceEndDate=PeriodEndDate,@PeriodLockPassword=PeriodLockDatePassword from  Bean.FinancialSetting (nolock) where CompanyId=@CompanyId
Select @BaseCurrency=BaseCurrency from Common.Localization (nolock) where CompanyId=@CompanyId

IF (@VendorId <> '00000000-0000-0000-0000-000000000000')---If it is vendor
Begin
	SET @EntityName=(Select FirstName from Common.Employee (nolock) where Id=@EnitityId and CompanyId=@CompanyId)
	SET @EnitityId=Case When @VendorId<>'00000000-0000-0000-0000-000000000000' Then @VendorId Else @EnitityId End
	set @BeanEntityId = @VendorId
End
ELSE
Begin
	SET @EntityName=(Select FirstName from Common.Employee (nolock) where Id=@EnitityId and CompanyId=@CompanyId)
	Select @EnitityId=Id from Bean.Entity (nolock) where SyncEmployeeId=@EnitityId and CompanyId=@CompanyId 	
End
		Begin try
		IF((@Id IS NOT NULL OR @Id<>'00000000-0000-0000-0000-000000000000') AND @IsVoid=0)
			Begin
			IF EXISTS(Select 1 from HR.EmployeeClaimDetail with (nolock) where EmployeeClaimId=@ClaimId and ApprovedAmount>0)
			BEGIN
					IF (@Financial=NULL or @Financial=0)
						RAISERROR('The Financial settings should be activate',16,1)
					IF (@BaseCurrency<>@DocCurrency AND CONVERT(DATE,@PostingDate)>GETDATE())
						RAISERROR('Processing date should not be future date',16,1)
					IF(@EnitityId Is not NULL OR @EnitityId!='00000000-0000-0000-0000-000000000000')
						BEGIN
							If(@VendorId='00000000-0000-0000-0000-000000000000')---If Entity Type is Employee
							Begin
							
							   IF Not exists(Select Id from Bean.Entity with (nolock) where SyncEmployeeId=@EmployeeId and CompanyId=@CompanyId)
								BEGIN								   
								   --set @EmployeeId= (Select EmployeId from  HR.EmployeeClaim1 where Id=@ClaimId)
								   Exec [dbo].[Common_Sync_MasterData_HREmployee_Entity] @CompanyId,@EmployeeId,'Add' 
								 END
								IF Not exists(Select Id from Bean.Entity with (nolock) where SyncEmployeeId=@EmployeeId and CompanyId=@CompanyId)
								BEGIN
									RAISERROR('Employee is not exist in Bean',16,1)
								END
								else
								BEGIN
								set @BeanEntityId = (Select Id from Bean.Entity with (nolock) where SyncEmployeeId=@EmployeeId and CompanyId=@CompanyId);
								END 
												
							End
							Else---If Entity Type is not an Employee
							Begin
								IF Not exists(Select Id from Bean.Entity with (nolock) where Id=@EnitityId and CompanyId=@CompanyId)
								BEGIN
									RAISERROR('Vendor is not exist in Bean',16,1)
								END	
							End
						END
					IF(@CompanyId is NULL OR @CompanyId=0)
						RAISERROR('CompanyId is required',16,1)
					IF(@ServiceEntityId is NULL OR @ServiceEntityId=0)
						RAISERROR('ServiceEntity is required',16,1)
					IF EXISTS(Select 1 from HR.EmployeeClaimDetail with (nolock) where EmployeeClaimId=@ClaimId and ApprovedAmount!=0 and TaxAmount>ApprovedAmount)
						RAISERROR('Tax amount shoud not greater than amount to run the claims bill',16,1)
					--SET @BillId=NEWID()

					--For Claim Spliting 
					Insert into @ClaimDetailIds 
					Select EMPD.ParentId from HR.EmployeeClaim1 Emp with (nolock) 
					Inner join  HR.EmployeeClaimDetail EMPD with (nolock) On EMPD.EmployeeClaimId=Emp.Id  
					where Emp.Id=@ClaimId and Emp.ParentCompanyId=@CompanyId and EMPD.ParentId is not null group by EMPD.ParentId

					SET @GrandTotal=(
						Select 
						 SUM(ISNULL(ECD.ApprovedAmount,0))
							--ELSE Sum(BaseAmount) -(CASE WHEN @IsGstSettings=1 THEN Sum(ROUND((ISNULL(ECD.TaxAmount,0)* Isnull(@ExchangeRate,1)),2)) ELSE 0 End)
							 As GrandTotal
						from HR.EmployeeClaimDetail ECD with (nolock) where EmployeeClaimId=@ClaimId  and  ECD.Id not in (Select ParentIds from @ClaimDetailIds)
					)

					SET @GSTTotalAmount=(
					Select SUM(ISNULL(ED.TaxAmount,0)) from HR.EmployeeClaimDetail ED with (nolock) where EmployeeClaimId=@ClaimId
					)

					Insert into @ClaimItem 

					Select Id as Id,COAId as COAId,ItemName as ItemName from HR.ClaimItem with (nolock) where Id in (Select ClaimItemId from HR.EmployeeClaimDetail where EmployeeClaimId=@ClaimId)

					Insert into @IncidentalClaim 

					Select Id as Id,COAId as COAId,Item as ItemName from WorkFlow.IncidentalClaimItem with (nolock) where Id in (Select IncidentalClaimItemId from HR.EmployeeClaimDetail with (nolock) where EmployeeClaimId=@ClaimId)
					Insert into @TaxCode 
					Select Id as TaxId,TaxRate as TaxRate,Code as TaxCode,Case When code='NA' Then 'NA' Else CONCAT(Code,+'-'+Case When TaxRate is null Then 'NA' Else CAST(TaxRate as varchar(20))+'%' END) END as TaxIdCode from Bean.TaxCode with (nolock) where CompanyId= @CompanyId 

					
            if(@IsPayComponent=0)
              Begin
				Insert into Bean.Bill(Id,CompanyId,DocSubType,SystemReferenceNumber,DocNo,ServiceCompanyId,EntityId,Nature,DocumentDate,PostingDate,CreditTermsId,DueDate,DocCurrency,ExchangeRate,IsNoSupportingDocument,DocDescription,BaseCurrency,GSTExCurrency,GSTExchangeRate,GSTTotalAmount,GrandTotal,IsGstSettings,IsMultiCurrency,UserCreated,CreatedDate,Status,BalanceAmount,PayrollId,IsExternal,DocType,DocumentState,EntityType,CreditTermValue,IsSegmentReporting,IsAllowableDisallowable,IsGSTCurrencyRateChanged,IsBaseCurrencyRateChanged,SyncHRPayrollId,SyncHRPayrollDate,SyncHRPayrollStatus,SyncHRPayrollRemarks)

				Select @BillId as Id,ParentCompanyId as CompanyId,@ClaimDocument as DocSubType,ClaimNumber as SystemReferenceNumber,ClaimNumber as DocNo,@ServiceEntityId as ServiceCompanyId,@BeanEntityId as EntityId,@NatureOthers as Nature,MasterClaimDate as DocumentDate,CONVERT(DATE,@PostingDate) as PostingDate,@CreditTermsId as CreditTermsId,MasterClaimDate as DueDate,@DocCurrency as DocCurrency,Isnull(@ExchangeRate ,1)as ExchangeRate,0 as IsNoSupportingDocument,
				CONCAT(@EntityName+' '+ @ClaimDocument,+'-'+(CASE WHEN MasterClaimDate Is Not NULL THEN CAST(CONVERT(varchar(30), MasterClaimDate,103) as varchar(30)) ELSE NULL END)+(CASE WHEN @ClaimNumber Is Not NULL OR @ClaimNumber!='' THEN '('+@ClaimNumber+')' ELSE '' END)) as DocDescription,
				
				@BaseCurrency as BaseCurrency,@GSTExCurrency as GSTExCurrency,isnull(@GstExchangeRate,1) as GSTExchangeRate,@GSTTotalAmount as GSTTotalAmount,@GrandTotal as GrandTotal,IsNull(@IsGstSettings,0) as IsGstSettings,@IsMultiCurrency as IsMultiCurrency,@Sysytem as UserCreated,ModifiedDate as CreatedDate,Status as Status,@GrandTotal as BalanceAmount,Id as PayrollId,1 as IsExternal,@BillDocument as DocType,@Not_Paid_State as DocumentState,'Vendor' as EntityType,0 as CreditTermValue,0 as IsSegmentReporting,0 as IsAllowableDisallowable,0 as IsGSTCurrencyRateChanged,@IsExchangeRateEditable,@ClaimId,GETUTCDATE(),'Completed','The Claim has been synced successfully!'  from HR.EmployeeClaim1 with (nolock) where Id=@ClaimId and ParentCompanyId=@CompanyId


				
			  Insert into Bean.BillDetail (Id,BillId,Description,COAId,TaxId,TaxCode,TaxIdCode,TaxRate,DocAmount,DocTaxAmount,DocTotalAmount,BaseAmount,BaseTaxAmount,BaseTotalAmount,RecOrder,IsDisallow)

			     Select NEWID() as Id,@BillId as BillId,
				 Case When ((Select Id from @ClaimItem where Id=ECD.ClaimItemId) IS NOT NULL) THEN CONCAT((Select ItemName from @ClaimItem where Id=ECD.ClaimItemId),+' '+ECD.Description) ELSE CONCAT((Select ItemName from @IncidentalClaim where Id=ECD.IncidentalClaimItemId),+' '+ECD.Description) END as Description,
				 Case When ((Select COAId from @ClaimItem where Id=ECD.ClaimItemId) IS NOT Null) THEN (Select COAId from @ClaimItem where Id=ECD.ClaimItemId) ELSE (Select COAId from @IncidentalClaim where Id=ECD.IncidentalClaimItemId) END as COAId,
				 Case When @IsGSTSettings=1 THEN Case When ECD.TaxId IS NOT NULL THEN ECD.TaxId Else (Select TaxId from @TaxCode where TaxCode='NA') END ELSE NULL END as TaxId,
				 Case When @IsGSTSettings=1 THEN Case When ECD.TaxId IS NOT NULL THEN (Select TaxCode from @TaxCode TXD where TaxId=ECD.TaxId) Else NULL END ELSE NULL END as TaxCode,
				 Case When @IsGSTSettings=1 THEN Case When ECD.TaxId IS NOT NULL THEN (Select TaxIdCode from @TaxCode TXD where TaxId=ECD.TaxId) Else NULL END ELSE NULL END as TaxIdCode,
				 Case When @IsGSTSettings=1 THEN Case When ECD.TaxId IS NOT NULL THEN (Select TaxRate from @TaxCode TXD where TaxId=ECD.TaxId) Else 0 END ELSE NULL END as TaxRate,
				 Case When @IsGSTSettings=1 THEN ECD.ApprovedAmount - 
				   (Case When ECD.TaxAmount IS NOT NULL THEN ECD.TaxAmount ELSE 0 END) ELSE ECD.ApprovedAmount END as DocAmount,
				 Case When @IsGSTSettings=1 THEN IsNull(ECD.TaxAmount,0) Else 0 END as DocTaxAmount,
				--Case When @IsGSTSettings=1 THEN ECD.ApprovedAmount - 
				--		(Case When ECD.TaxAmount IS NOT NULL THEN ECD.TaxAmount ELSE 0 END) ELSE ECD.ApprovedAmount END as DocTotalAmount,
				 ECD.ApprovedAmount as DocTotalAmount,

				 Case When @DocCurrency=@BaseCurrency THEN ECD.ApprovedAmount ELSE ROUND(ISNULL(ECD.ApprovedAmount,0)*ISNULL(@ExchangeRate,1),2) END - 
				--Case When @DocCurrency=@BaseCurrency THEN 
				--CASE WHEN  @IsGstSettings=1 THEN ECD.TaxAmount ELSE 0 END ELSE 
					Case When @IsGstSettings=1 THEN ROUND(ISNULL(ECD.TaxAmount,0)*ISNULL(@ExchangeRate,1),2) ELSE 0 END As BaseAmount,
				 Case When @DocCurrency=@BaseCurrency THEN ISNULL(ECD.TaxAmount,0)
				--CASE WHEN  @IsGstSettings=1 THEN ECD.TaxAmount ELSE 0 END ELSE 
					Else  ROUND(ISNULL(ECD.TaxAmount,0)*ISNULL(@ExchangeRate,1),2) END As BaseTaxAmount,
				 Case When @DocCurrency=@BaseCurrency THEN ECD.ApprovedAmount ELSE ROUND(ISNULL(ECD.ApprovedAmount,0)*ISNULL(@ExchangeRate,1),2) END As BaseTotalAmount,
				   ECD.RecOrder as RecOrder,
				   0 as IsDisallow      
				 from HR.EmployeeClaimDetail ECD with (nolock) Join HR.EmployeeClaim1 EC with (nolock) on ECD.EmployeeClaimId=EC.Id where ECD.EmployeeClaimId=@ClaimId and EC.ParentCompanyId=@CompanyId and  ECD.Id not in (Select ParentIds from @ClaimDetailIds)

				 ----For Claim Bill Posting
				 If (@BillId Is Not NULL AND @BillId !='00000000-0000-0000-0000-000000000000')
	             Begin
	              Exec [dbo].[Bean_Posting] @BillId,@BillDocument,@CompanyId
	             End
		-------------------------- Audit Syncing New Code Start ------------------------------------------
		Declare @BeanStatus Nvarchar(30);
		Declare @BeanBillId uniqueidentifier;
		Set @BeanBillId =(Select Id from Bean.Bill where Id=@BillId);
		Set @BeanStatus =(select DocumentState from Bean.Bill where Id=@BillId);
		EXEC [dbo].[UpdateAuditSyncing] @ClaimId,@BeanBillId,'Success(Bill)',@BeanStatus,NULL,Null,Null,Null,Null,'HR Claim','Bean Claim'

	-----------------------------Audit Syncing New Code End----------------------------------------------
			END

			Else If(@IsPayComponent=1)
			Begin
			Set @TaxPaybleCoaId=(Select Id from Bean.ChartOfAccount with (nolock) where CompanyId=@CompanyId and Name=@TaxPaybleGSTCOA)

			Set @EntityName=(select E.FirstName From HR.EmployeeClaim1 EC with (nolock) Inner Join Common.Employee E with (nolock) On E.Id=EC.EmployeId Where EC.Id=@ClaimId)

			Set @COAId=(Select Id From Bean.ChartOfAccount with (nolock) where Name=@COAName_Reimb and CompanyId=@CompanyId)

		 --Jounal Table Insert From Claims
			 Insert into Bean.Journal(Id,CompanyId,DocSubType,SystemReferenceNo,DocNo,ServiceCompanyId,Nature,DocDate,PostingDate,CreditTermsId,DueDate,DocCurrency,ExchangeRate,ExCurrency,IsNoSupportingDocs,NoSupportingDocument,DocumentDescription,GSTExCurrency,GSTExchangeRate,GSTTotalAmount,GrandDocDebitTotal,GrandDocCreditTotal,GrandBaseDebitTotal,GrandBaseCreditTotal,IsGstSettings,IsMultiCurrency,UserCreated,CreatedDate,Status,BalanceAmount,DocType,DocumentState,IsSegmentReporting,ISAllowDisAllow,IsGSTCurrencyRateChanged,ActualSysRefNo,DocumentId,CreationType,EntityId,IsBaseCurrencyRateChanged,ReverseChildRefId,IsNoSupportingDocument)  
  
			 Select @BillId as Id,ParentCompanyId as CompanyId,@ClaimDocument as DocSubType,ClaimNumber as SystemReferenceNo,ClaimNumber as DocNo,@ServiceEntityId as ServiceCompanyId,null as Nature,CONVERT(DATE,@PostingDate) as DocDate,CONVERT(DATE,@PostingDate) as PostingDate,@CreditTermsId as CreditTermsId,MasterClaimDate as DueDate,@DocCurrency as DocCurrency,@ExchangeRate as ExchangeRate,@BaseCurrency as ExCurrency,0 as IsNoSupportingDocs,0 as NoSupportingDocument,
	 
			 CONCAT(@ClaimDocument,+'-'+(CASE WHEN MasterClaimDate Is Not Null  THEN CAST(CONVERT(varchar(30), MasterClaimDate,103) as varchar(30)) ELSE NULL END)+(CASE WHEN @ClaimNumber<>NULL OR @ClaimNumber!='' THEN '('+@ClaimNumber ELSE '' END)+('/'+ @EntityName)+')') as DocumentDescription,
			 @GSTExCurrency as GSTExCurrency,@GstExchangeRate as GSTExchangeRate,@GSTTotalAmount as GSTTotalAmount,@GrandTotal as GrandDocDebitTotal,@GrandTotal as GrandDocCreditTotal,@GrandTotal as GrandBaseDebitTotal,@GrandTotal as GrandBaseCreditTotal,IsNull(@IsGstSettings,0) as IsGstSettings,@IsMultiCurrency as IsMultiCurrency,@Sysytem as UserCreated,ModifiedDate as CreatedDate,Status as Status,@GrandTotal as BalanceAmount,@JournalDocument as DocType,'Posted' as DocumentState,0 as IsSegmentReporting,0 as ISAllowDisAllow,0 as IsGSTCurrencyRateChanged,ClaimNumber as ActualSysRefNo,@BillId as DocumentId,@Sysytem as CreationType,@EnitityId,@IsExchangeRateEditable,@ClaimId,0 as IsNoSupportingDocument from HR.EmployeeClaim1 with (nolock) where Id=@ClaimId and ParentCompanyId=@CompanyId 

			 --JournalDetail Insert From ClaimDetail

			  Insert into Bean.JournalDetail(Id,JournalId,AccountDescription,COAId,TaxId,TaxRate,DocDebit,DocCredit,DocTaxDebit,DocTaxCredit,BaseDebit,BaseCredit,BaseTaxDebit,GSTDebit,GSTTaxDebit,DocumentAmount,DocTaxAmount,BaseAmount,BaseTaxAmount,DocumentId,BaseCurrency,ExchangeRate,GSTExCurrency,GSTExchangeRate,DocType,DocSubType,ServiceCompanyId,DocNo,Nature,SystemRefNo,DocCurrency,DocDate,PostingDate,RecOrder,IsTax,DocDebitTotal,BaseDebitTotal,DocCreditTotal,EntityId,DocumentDetailId)  
			   Select NEWID() as Id,
			   @BillId as JournalId,
			   Case When ((Select Id from @ClaimItem where Id=ECD.ClaimItemId) IS NOT NULL) THEN CONCAT((Select ItemName from @ClaimItem where Id=ECD.ClaimItemId),+' '+ECD.Description) ELSE CONCAT((Select ItemName from @IncidentalClaim where Id=ECD.IncidentalClaimItemId),+' '+ECD.Description) END as AccountDescription,
			   Case When ((Select COAId from @ClaimItem where Id=ECD.ClaimItemId) IS NOT Null) THEN (Select COAId from @ClaimItem where Id=ECD.ClaimItemId) ELSE (Select COAId from @IncidentalClaim where Id=ECD.IncidentalClaimItemId) END as COAId,
			   Case When @IsGSTSettings=1 THEN Case When ECD.TaxId IS NOT NULL THEN ECD.TaxId Else (Select TaxId from @TaxCode where TaxCode='NA') END ELSE NULL END as TaxId,
			   Case When @IsGSTSettings=1 THEN Case When ECD.TaxId IS NOT NULL THEN (Select TaxRate from @TaxCode TXD where TaxId=ECD.TaxId) Else 0 END ELSE NULL END as TaxRate,
			   Case When @IsGSTSettings=1 THEN ECD.ApprovedAmount - 
							   (Case When ECD.TaxAmount IS NOT NULL THEN ECD.TaxAmount ELSE 0 END) ELSE ECD.ApprovedAmount END as DocDebit,
			   --Case When @IsGSTSettings=1 THEN ECD.ApprovedAmount -   
			   --(Case When ECD.TaxAmount IS NOT NULL THEN ECD.TaxAmount ELSE 0 END) ELSE ECD.ApprovedAmount END 
			   null as DocCredit,
			   Case When @IsGSTSettings=1 THEN IsNull(ECD.TaxAmount,0) Else 0 END as DocTaxDebit,
			   Case When @IsGSTSettings=1 THEN IsNull(ECD.TaxAmount,0) Else 0 END as DocTaxCredit,
			   Case When @DocCurrency=@BaseCurrency THEN ECD.ApprovedAmount ELSE ROUND(ISNULL(ECD.ApprovedAmount,0)*ISNULL(@ExchangeRate,1),2) END - 
							--Case When @DocCurrency=@BaseCurrency THEN 
							--CASE WHEN  @IsGstSettings=1 THEN ECD.TaxAmount ELSE 0 END ELSE 
								Case When @IsGstSettings=1 THEN ROUND(ISNULL(ECD.TaxAmount,0)*ISNULL(@ExchangeRate,1),2) ELSE 0 END As BaseDebit, 
			   --Case When @DocCurrency=@BaseCurrency THEN ECD.ApprovedAmount ELSE ROUND(ISNULL(ECD.ApprovedAmount,0)*ISNULL(@ExchangeRate,0),2) END -   
			   -- Case When @IsGstSettings=1 THEN ROUND(ISNULL(ECD.TaxAmount,0)*ISNULL(@ExchangeRate,0),2) ELSE 0 END 
			   Null As BaseCredit,
			   Case When @DocCurrency=@BaseCurrency THEN ISNULL(ECD.TaxAmount,0) 
				 Else  ROUND(ISNULL(ECD.TaxAmount,0)*ISNULL(@ExchangeRate,0),2) END As BaseTaxDebit,
			   ROUND(ISNULL(ECD.TaxAmount,0)*ISNULL(@GstExchangeRate,1),2) As GSTDebit,
			   Case When @DocCurrency='SGD' THEN ECD.ApprovedAmount ELSE ROUND(ISNULL(ECD.ApprovedAmount,0)*ISNULL(@GstExchangeRate,1),2) END - Case When @IsGstSettings=1 THEN ROUND(ISNULL(ECD.TaxAmount,0)*ISNULL(@GstExchangeRate,1),2) ELSE 0 END  As GSTTaxDebit,
			   Case When @IsGSTSettings=1 THEN ECD.ApprovedAmount -   
			   (Case When ECD.TaxAmount IS NOT NULL THEN ECD.TaxAmount ELSE 0 END) ELSE ECD.ApprovedAmount END as DocumentAmount,
			   Case When @IsGSTSettings=1 THEN IsNull(ECD.TaxAmount,0) Else 0 END as DocTaxAmount,
				Case When @DocCurrency=@BaseCurrency THEN ECD.ApprovedAmount ELSE ROUND(ISNULL(ECD.ApprovedAmount,0)*ISNULL(@ExchangeRate,0),2) END -   
			   Case When @IsGstSettings=1 THEN ROUND(ISNULL(ECD.TaxAmount,0)*ISNULL(@ExchangeRate,0),2) ELSE 0 END As BaseAmount, 
			   Case When @DocCurrency=@BaseCurrency THEN ISNULL(ECD.TaxAmount,0) 
				 Else  ROUND(ISNULL(ECD.TaxAmount,0)*ISNULL(@ExchangeRate,0),2) END As BaseTaxAmount,
			   @BillId as DocumentId,
			   @BaseCurrency as BaseCurrency,
			   @ExchangeRate as ExchangeRate,
			   @GSTExCurrency as GSTExCurrency,
			   @GstExchangeRate as GSTExchangeRate,
			   @JournalDocument as DocType,
			   @ClaimDocument as DocSubType,
			   @ServiceEntityId as ServiceCompanyId,
			   ClaimNumber as DocNo,
			   null as Nature,
			   ClaimNumber as SystemRefNo,
			   @DocCurrency as DocCurrency,
			   CONVERT(DATE,@PostingDate) as DocDate,
			   CONVERT(DATE,@PostingDate) as PostingDate,
			   ECD.RecOrder as RecOrder,
			   null as IsTax,
			   0 as DocDebitTotal,
			   0 as BaseDebitTotal,
			   0 as DocCreditTotal,
			   @EnitityId,
			   @GuidZero
			 --Case When @IsGSTSettings=1 THEN Case When ECD.TaxId IS NOT NULL THEN (Select TaxType from @TaxCode TXD where TaxId=ECD.TaxId) Else 0 END ELSE NULL END as TaxType,   
			 --Case When @DocCurrency=@BaseCurrency THEN ECD.ApprovedAmount ELSE ROUND(ISNULL(ECD.ApprovedAmount,0)*ISNULL(@ExchangeRate,0),2) END As BaseTotalAmount, 
       
			  from HR.EmployeeClaimDetail ECD with (nolock) Join HR.EmployeeClaim1 EC with (nolock) on ECD.EmployeeClaimId=EC.Id where ECD.EmployeeClaimId=@ClaimId and EC.ParentCompanyId=@CompanyId and  ECD.Id not in (Select ParentIds from @ClaimDetailIds) 
  
 
		----need to insert the tax amount
		IF(@IsGstSettings=1)
		Begin
			Insert into Bean.JournalDetail(Id,JournalId,AccountDescription,COAId,DocDebit,BaseDebit,DocumentAmount,BaseAmount,DocumentId,BaseCurrency,ExchangeRate,GSTExCurrency,GSTExchangeRate,DocType,DocSubType,ServiceCompanyId,DocNo,Nature,SystemRefNo,DocCurrency,DocDate,PostingDate,DocCreditTotal,DocDebitTotal,IsTax,TaxId,TaxRate,EntityId,DocumentDetailId)  
			Select NEWID() as Id,
			@BillId as JournalId,
			CONCAT('Claim',+'-'+(CASE WHEN jd.DocDate Is Not Null  THEN CAST(CONVERT(varchar(30), jd.DocDate,103) as varchar(30)) ELSE NULL END)+(CASE WHEN @ClaimNumber<>NULL OR @ClaimNumber!='' THEN '('+@ClaimNumber+')' ELSE '' END)+('/'+ @EntityName)) as AccountDescription,
			@TaxPaybleCoaId as COAId,
			Jd.DocTaxDebit as DocDebit,
			Jd.BaseTaxDebit As BaseDebit,
			Jd.DocTaxDebit as DocumentAmount,
			Jd.BaseTaxDebit BaseAmount, 
			@BillId as DocumentId,
			@BaseCurrency as BaseCurrency,
			@ExchangeRate as ExchangeRate,
			@GSTExCurrency as GSTExCurrency,
			@GstExchangeRate as GSTExchangeRate,
			@JournalDocument as DocType,
			@ClaimDocument as DocSubType,
			@ServiceEntityId as ServiceCompanyId,
			JD.DocNo as DocNo,
			null as Nature,
			JD.DocNo as SystemRefNo,
			@DocCurrency as DocCurrency,
			CONVERT(DATE,@PostingDate) as DocDate,
			CONVERT(DATE,@PostingDate) as PostingDate,
			0 as DocCreditTotal ,
			0 as DocDebitTotal,
			1 as IsTax,
			Jd.TaxId,
			Jd.TaxRate,
			@EnitityId,
			@GuidZero
			--(Select Max(id)+1 from Bean.JournalDetail where JournalId=@BillId)
       
			from Bean.JournalDetail JD  with (nolock) where JD.JournalId=@BillId and (Jd.TaxRate is not null or Jd.TaxRate <>1 and jd.IsTax is null) 

		End

		--Master Record For JournalDetail

		Insert into Bean.JournalDetail(Id,JournalId,COAId,DocCredit,BaseCredit,DocumentAmount,BaseAmount,DocumentId,BaseCurrency,ExchangeRate,GSTExCurrency,GSTExchangeRate,DocType,DocSubType,ServiceCompanyId,DocNo,Nature,SystemRefNo,DocCurrency,DocDate,AccountDescription,PostingDate,RecOrder,DocCreditTotal,DocDebitTotal,TaxId,TaxRate,EntityId,DocumentDetailId)  
		Select NEWID() as Id,
		@BillId as JournalId,
		@COAId as COAId,
		@GrandTotal as DocCredit,
		Round(@GrandTotal*@ExchangeRate,2) As BaseCredit,
		@GrandTotal as DocumentAmount,
		Round(@GrandTotal*@ExchangeRate,2) BaseAmount,
		@BillId as DocumentId,
		@BaseCurrency as BaseCurrency,
		@ExchangeRate as ExchangeRate,
		@GSTExCurrency as GSTExCurrency,
		@GstExchangeRate as GSTExchangeRate,
		@JournalDocument as DocType,
		@ClaimDocument as DocSubType,
		@ServiceEntityId as ServiceCompanyId,
		ClaimNumber as DocNo,
		null as Nature,
		ClaimNumber as SystemRefNo,
		@DocCurrency as DocCurrency,
		CONVERT(DATE,@PostingDate) as DocDate,
		CONCAT('Claim',+'-'+(CASE WHEN MasterClaimDate Is Not Null  THEN CAST(CONVERT(varchar(30), MasterClaimDate,103) as varchar(30)) ELSE NULL END)+(CASE WHEN @ClaimNumber<>NULL OR @ClaimNumber!='' THEN '('+@ClaimNumber+')' ELSE '' END)+('/'+ @EntityName)) as AccountDescription,
		CONVERT(DATE,@PostingDate) as PostingDate,
		EC.RecOrder as RecOrder,
		0 as DocCreditTotal ,
		0 as DocDebitTotal,
		(Select TaxId from @TaxCode where TaxCode='NA') as TaxId,
		(Select TaxRate from @TaxCode where TaxCode='NA') as TaxRate,
		@EnitityId,
		@GuidZero

	 --Round(@GrandTotal*@ExchangeRate,2) BaseTotalAmount, 
	  from HR.EmployeeClaim1 EC  where EC.Id=@ClaimId and EC.ParentCompanyId=@CompanyId 

	  -------Rounding Account
		If((select ABS(SUM(BaseDebit)-SUM(BaseCredit)) from Bean.JournalDetail where DocumentId=@BillId group by DocType)>=0.01)
		Begin
			Select @BaseDebit=SUM(BaseDebit),@BaseCredit=SUM(BaseCredit),@DiffAmount=ABS(SUM(BaseDebit)-SUM(BaseCredit)) from Bean.JournalDetail where DocumentId=@BillId
					
		Insert Into Bean.JournalDetail (Id,JournalId,COAId,AccountDescription,BaseDebit,BaseCredit,DocumentId,DocDate,DueDate,PostingDate,ExchangeRate,GSTExchangeRate,GSTExCurrency,Nature,DocType,DocSubType,ServiceCompanyId, CreditTermsId, DocNo, Currency, BaseCurrency, IsTax, SystemRefNo,  DocCurrency, RecOrder,DocDebitTotal,DocCreditTotal,TaxId,TaxRate,EntityId,DocumentDetailId)
			select NEWID(), @BillId, (Select Id from Bean.ChartOfAccount where CompanyId=@CompanyId and Name='Rounding'), DocumentDescription, Case When @BaseDebit>@BaseCredit Then null Else @DiffAmount End as BaseDebit, Case When @BaseCredit>@BaseDebit Then null Else @DiffAmount END as BaseCredit, @BillId,DocDate,DueDate,DocDate,ExchangeRate,GSTExchangeRate,GSTExCurrency,Nature,DocType,DocSubType,ServiceCompanyId,CreditTermsId,DocNo, DocCurrency, ExCurrency, 0,DocNo, DocCurrency, (Select Max(Recorder)+1 From Bean.JournalDetail with (nolock) Where DocumentId=@BillId),0,0,
			(Select TaxId from @TaxCode where TaxCode='NA') as TaxId,
			(Select TaxRate from @TaxCode where TaxCode='NA') as TaxRate,
			@EnitityId,@GuidZero
			from Bean.Journal with (nolock) where CompanyId=@CompanyId and Id=@BillId
		End
		---------------Audit Log Syncing New Code start ------------------------------------------------------------
		Declare @BeanJornalStatus Nvarchar(30);
		Declare @BeanJournalId uniqueidentifier;
		Set @BeanJournalId =(Select Id from Bean.Journal where Id=@BillId);
		Set @BeanJornalStatus =(select DocumentState from Bean.Journal where Id=@BillId);
		EXEC [dbo].[UpdateAuditSyncing] @ClaimId,@BeanJournalId,'Success(Journal)',@BeanJornalStatus,Null,Null,Null,Null,Null,'HR Claim','Bean Claim'
		----------------------Audit Log Syncing New Code End-----------------------------------------------
	End
    ELSE
	BEGIN
		RAISERROR('Approved Amount should be greater than 0 to run claim bill',16,1)
	END
   
		IF Exists(Select Id from Bean.Bill where Id=@BillId)
		Begin
		 Update HR.EmployeeClaim1 set DocumentId=@BillId,SyncBCClaimId=@BillId,VendorId=@EnitityId,SyncBCClaimDate=GETUTCDATE(),SyncBCClaimStatus='Completed',SyncBCClaimRemarks='The syncing process has been completed.' where Id=@ClaimId and ParentCompanyId=@CompanyId
		END
 End
End
	
IF(@IsVoid=1 and @IsPayComponent=0)
Begin
	IF Exists (Select Id from Bean.Bill with (nolock) where PayrollId=@ClaimId and CompanyId=@CompanyId and DocumentState=@Not_Paid_State)
    Begin
			If Exists(Select 1 from Bean.Bill with (nolock) where PayrollId=@ClaimId and CompanyId=@CompanyId and DocumentState = @Void)
			Begin
				Declare @count int 
				Set @count = (Select COUNT(*) from Bean.Bill with (nolock) where PayrollId=@ClaimId and CompanyId=@CompanyId and DocumentState = @Void)
				If(@count = 1)
				Begin
					--Updating Old Void DocNo
					Update Bean.Bill set DocNo=CONCAT(DocNo,'(1)') where PayrollId=@ClaimId and CompanyId=@CompanyId and DocumentState = @Void
			        Update Bean.Journal set DocNo=CONCAT(DocNo,'(1)') where DocumentId in (Select Id from Bean.Bill where PayrollId=@ClaimId and CompanyId=@CompanyId and DocumentState = @Void)
					--Updating New Void Docno
					Update Bean.Bill set DocumentState=@Void,ModifiedBy=@Sysytem,ModifiedDate=GETUTCDATE(),DocNo=CONCAT(DocNo,'-V(2)') where PayrollId=@ClaimId and CompanyId=@CompanyId and DocumentState = @Not_Paid_State
			        Update Bean.Journal set DocumentState=@Void,ModifiedBy=@Sysytem,ModifiedDate=GETUTCDATE(),DocNo=CONCAT(DocNo,'-V(2)') where DocumentId in (Select Id from Bean.Bill where PayrollId=@ClaimId and CompanyId=@CompanyId and DocumentState = @Not_Paid_State)
					Insert Into Bean.DocumentHistory(Id,TransactionId,CompanyId,DocumentId,DocType,DocSubType,DocState,DocCurrency,DocAmount,DocBalanaceAmount,ExchangeRate,BaseAmount,BaseBalanaceAmount,StateChangedBy,PostingDate,DocAppliedAmount,BaseAppliedAmount,StateChangedDate)
					Select NEWID(),Id,CompanyId,Id,DocType,DocSubType,DocumentState,DocCurrency,Round(GrandTotal,2) As DocAmount,Round(BalanceAmount,2) As DocBalanceAmount,ExchangeRate, Round(BalanceAmount*ExchangeRate,2)  As BaseAmount,Round(BalanceAmount*ExchangeRate,2) As BaseBalanceAmount, ModifiedBy, null , 0  As DocAppliedAmount, 0  As BaseAppliedAmount,ModifiedDate From Bean.Bill with (nolock) Where PayrollId=@ClaimId and CompanyId=@CompanyId and DocumentState = @Not_Paid_State
				End
				else If(@count > 1)
				Begin
					Set @count = @count+1
					Declare @voidNo nvarchar(100)
					Set @voidNo = (Select CONCAT('-V(',(Select CONCAT(@count,')'))))
					Update Bean.Bill set DocumentState=@Void,ModifiedBy=@Sysytem,ModifiedDate=GETUTCDATE(),DocNo=CONCAT(DocNo,@voidNo) where PayrollId=@ClaimId and CompanyId=@CompanyId
					Update Bean.Journal set DocumentState=@Void,ModifiedBy=@Sysytem,ModifiedDate=GETUTCDATE(),DocNo=CONCAT(DocNo,@voidNo) where DocumentId in (Select Id from Bean.Bill where PayrollId=@ClaimId and CompanyId=@CompanyId)
					Insert Into Bean.DocumentHistory(Id,TransactionId,CompanyId,DocumentId,DocType,DocSubType,DocState,DocCurrency,DocAmount,DocBalanaceAmount,ExchangeRate,BaseAmount,BaseBalanaceAmount,StateChangedBy,PostingDate,DocAppliedAmount,BaseAppliedAmount,StateChangedDate)
					Select NEWID(),Id,CompanyId,Id,DocType,DocSubType,DocumentState,DocCurrency,Round(GrandTotal,2) As DocAmount,Round(BalanceAmount,2) As DocBalanceAmount,ExchangeRate, Round(BalanceAmount*ExchangeRate,2)  As BaseAmount,Round(BalanceAmount*ExchangeRate,2) As BaseBalanceAmount, ModifiedBy, null , 0  As DocAppliedAmount, 0  As BaseAppliedAmount,ModifiedDate From Bean.Bill with (nolock) Where PayrollId=@ClaimId and CompanyId=@CompanyId
				End
			End
			Else
			Begin
				Update Bean.Bill set DocumentState=@Void,ModifiedBy=@Sysytem,ModifiedDate=GETUTCDATE(),DocNo=CONCAT(DocNo,'-V') where PayrollId=@ClaimId and CompanyId=@CompanyId
		        Update Bean.Journal set DocumentState=@Void,ModifiedBy=@Sysytem,ModifiedDate=GETUTCDATE(),DocNo=CONCAT(DocNo,'-V') where DocumentId in (Select Id from Bean.Bill where PayrollId=@ClaimId and CompanyId=@CompanyId)
				Insert Into Bean.DocumentHistory(Id,TransactionId,CompanyId,DocumentId,DocType,DocSubType,DocState,DocCurrency,DocAmount,DocBalanaceAmount,ExchangeRate,BaseAmount,BaseBalanaceAmount,StateChangedBy,PostingDate,DocAppliedAmount,BaseAppliedAmount,StateChangedDate)
				Select NEWID(),Id,CompanyId,Id,DocType,DocSubType,DocumentState,DocCurrency,Round(GrandTotal,2) As DocAmount,Round(BalanceAmount,2) As DocBalanceAmount,ExchangeRate, Round(BalanceAmount*ExchangeRate,2)  As BaseAmount,Round(BalanceAmount*ExchangeRate,2) As BaseBalanceAmount, ModifiedBy, null , 0  As DocAppliedAmount, 0  As BaseAppliedAmount,ModifiedDate From Bean.Bill with (nolock) Where PayrollId=@ClaimId and CompanyId=@CompanyId
			End

		Declare @BeanBillId1 uniqueidentifier;
		Set @BeanBillId1 =(Select SyncBCClaimId from HR.EmployeeClaim1 where Id=@ClaimId);
		EXEC [dbo].[UpdateAuditSyncing] @ClaimId,@BeanBillId1,'Success(Bill)-V',@Void,Null,Null,Null,Null,Null,'HR Claim','Bean Claim'

    End
    ELSE
		Begin
			RAISERROR('Bill state should be ''Not Paid'' to void the claim.',16,1)
        End
    END
Else If(@IsVoid=1 and @IsPayComponent=1)
Begin
	IF Exists (Select Id from Bean.Journal with (nolock) where ReverseChildRefId=@ClaimId and CompanyId=@CompanyId and DocumentState='Posted')
    Begin
		If Exists(Select 1 from Bean.Journal with (nolock) where ReverseChildRefId =@ClaimId and CompanyId=@CompanyId and DocumentState = @Void)
		Begin
			Declare @count1 int 
			Set @count1 = (Select COUNT(*) from Bean.Journal with (nolock) where ReverseChildRefId =@ClaimId and CompanyId=@CompanyId and DocumentState = @Void)
			If(@count1 = 1)
			Begin
				--updating old void docno
				Update Bean.Journal set DocNo=CONCAT(DocNo,'(1)') where ReverseChildRefId =@ClaimId and DocumentState = @void and companyId = @companyId
				--Updating New void DocNo
				Update Bean.Journal set DocumentState=@Void,ModifiedBy=@Sysytem,ModifiedDate=GETUTCDATE(),DocNo=CONCAT(DocNo,'-V(2)') where ReverseChildRefId =@ClaimId And CompanyId = @companyId and DocumentState = 'Posted'
			End
			else if (@count1 > 1)
			Begin
				Set @count1 = @count1+1
				Declare @voidNo1 nvarchar(100)
				Set @voidNo1 = (Select CONCAT('-V(',(Select CONCAT(@count1,')'))))
				Update Bean.Journal set DocumentState=@Void,ModifiedBy=@Sysytem,ModifiedDate=GETUTCDATE(),DocNo=CONCAT(DocNo,@voidNo1) where ReverseChildRefId =@ClaimId and CompanyId = @CompanyId And DocumentState = 'Posted'
			End
		End
		Else
		Begin
			Update Bean.Journal set DocumentState=@Void,ModifiedBy=@Sysytem,ModifiedDate=GETUTCDATE(),DocNo=CONCAT(DocNo,'-V') where ReverseChildRefId =@ClaimId
		End

		Declare @BeanJournal1 uniqueidentifier;
		Set @BeanJournal1 =(Select SyncBCClaimId from HR.EmployeeClaim1 where Id=@ClaimId);
		EXEC [dbo].[UpdateAuditSyncing] @ClaimId,@BeanJournal1,'Success(Journal)-V',@Void,Null,Null,Null,Null,Null,'HR Claim','Bean Claim'

    End
    ELSE
    Begin
		RAISERROR('Journal state should be ''Posted'' to void the claim.',16,1)
    End
END

	Commit Transaction
	End Try

	Begin catch
	Rollback;

	Select @Error_Message=ERROR_MESSAGE(),
			@Error_Servirity=ERROR_SEVERITY(),
			@Error_State=ERROR_STATE()
		RAISERROR(@Error_Message,@Error_Servirity,@Error_State)
	End Catch
END
GO
