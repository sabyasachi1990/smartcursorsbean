USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[Common_Sync_MasterData_CursorActivate]    Script Date: 16-12-2024 9.20.10 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



--Exec [dbo].[Common_Sync_MasterData_Import] 'Bean Cursor',1

CREATE Procedure [dbo].[Common_Sync_MasterData_CursorActivate]
@CursorName Varchar(50),
@CompanyId BigInt
As
Begin
	Declare @UserCreatedOrModified Varchar(10),
			@GetDate DateTime2,
			@BaseCurrency varchar(20),
			@SyncStatusCompleted varchar(20),
			@SyncStatusUpdateCompleted varchar(20),
			@IsExternalData Int,
			@CustNature Varchar(20),
			@SysRefNumber Nvarchar(50),
			@IndCount Int,
			@Count int,
			@SyncEntityId Uniqueidentifier,
			@AdrsSyncEntityId Uniqueidentifier,
			@AddressBookId Uniqueidentifier,
			@AdrsEntityId Uniqueidentifier,
			@AdrsAccountId Uniqueidentifier,
			@AdrsClientId Uniqueidentifier,
			@AdrsSyncClientId Uniqueidentifier,
			@AdrsCount int,
			@AdrsSyncEntitytId Uniqueidentifier,
			@AdrsSyncAccountId Uniqueidentifier,
			@SyncAccountId Uniqueidentifier,
			@ContactId Uniqueidentifier,
			@CDEntityId Uniqueidentifier,
			@SyncClientId Uniqueidentifier,
			@ContactDetailId Uniqueidentifier,
			@SystemRefnum Varchar(100),
			@GeneratedNumber Varchar(100),
			@New_ContctDtlId Uniqueidentifier,
			@CntDtl_AddBookId Uniqueidentifier,
			@cntdtlAddType Nvarchar(200),
			@CntdtlAddressId Uniqueidentifier,
			@CntdtlEntityId Uniqueidentifier,
			@CntDtlEntityType Nvarchar(200),
			@AddrsAddSecType Nvarchar(100),
			@AdrsSyncEmployeeId Uniqueidentifier,
			@AddressId UniqueIdentifier,
			@CntDtlDestId UniqueIdentifier
	Set @UserCreatedOrModified='System'
	Set @GetDate=Getutcdate()
	Set @SyncStatusCompleted='Completed'
	Set @SyncStatusUpdateCompleted='UpdateCompleted'
	Set @IsExternalData=1
	Set @CustNature='Trade'
	
	--Declare Temp Table variable to store contact deatils
	Create Table #Loc_Cont_Tbl (Id Int Identity(1,1),ContactDetailId Uniqueidentifier,EntityType Nvarchar(200),ContactId Uniqueidentifier,EntityId Uniqueidentifier,DestId Uniqueidentifier)
	--Declare Temp Table variable to store Addresses deatils
	Create Table #Loc_AdrsTbl (Id Int Identity(1,1),AddressId Uniqueidentifier,AddressBookId Uniqueidentifier,AddSectionType NVarchar(100),AdrsEntityId Uniqueidentifier,DestId Uniqueidentifier)

	Select @BaseCurrency=BaseCurrency from bean.FinancialSetting where CompanyId=@CompanyId

	If @BaseCurrency is null Set @BaseCurrency='SGD'

	Begin Transaction

	Begin Try
		IF @CursorName='Bean Cursor'
		Begin
			-- Check Workflow Cursor Activated Or Not If Workflow Activated
			If Exists(Select Id From Common.CompanyModule Where CompanyId=@CompanyId And ModuleId in (Select Id from Common.ModuleMaster Where Name='Workflow Cursor') And Status=1)
			Begin
				/* Tables Bean.Item & Common.Service*/
				--Update existing records in Bean.Item Table
				Update I Set I.CompanyId=S.CompanyId,I.Code=Concat(SG.Code,S.Code),I.COAId=S.CoaId,I.Description=S.Name,I.DefaultTaxcodeId=Case when S.IsGSTActivate =1 Then S.TaxCodeId Else Null End,
						I.RecOrder=S.RecOrder,I.Remarks=S.Remarks,I.ModifiedBy=@UserCreatedOrModified,I.ModifiedDate=@GetDate,I.Version=S.Version,I.Status=S.Status,I.SyncServiceId=S.Id,I.IsExternalData=@IsExternalData,I.SyncServicedate=@GetDate,I.SyncServiceStatus=@SyncStatusUpdateCompleted,I.SyncServiceRemarks=null
				From Bean.Item As I
				Inner Join Common.Service As S On S.Id=I.SyncServiceId
				Inner Join Common.ServiceGroup As SG On SG.Id=S.ServiceGroupId
				Where I.CompanyId=@CompanyId And S.CoaId Is Not Null
				-- Update syncitem details in service 
				Update S Set S.SyncItemStatus=@SyncStatusUpdateCompleted,S.SyncItemdate=@GetDate,SyncItemRemarks=null--,S.SyncItemId=I.Id
				From Common.Service As S 
				Inner Join Common.ServiceGroup As SG On SG.Id=S.ServiceGroupId
				Inner Join Bean.Item As I On I.SyncServiceId=S.Id
				Where S.CompanyId=@CompanyId And I.ModifiedDate=@GetDate
				-- Insert Into Bean.Item Table From Service
				Insert Into Bean.Item (Id,CompanyId,Code,COAId,Description,DefaultTaxcodeId,RecOrder,Remarks,UserCreated,CreatedDate,Version,Status,IsExternalData,SyncServiceId,SyncServiceStatus,SyncServicedate,SyncServiceRemarks,DocumentId)
					Select NEWID(),@CompanyId,Concat(Sg.code,S.Code),CoaId,S.Name,Case when S.IsGSTActivate =1 Then S.TaxCodeId Else Null End As TaxCodeId,S.RecOrder,S.Remarks,@UserCreatedOrModified,@GetDate,S.Version,S.Status,1,S.Id,@SyncStatusCompleted,@GetDate,Null,S.Id
					From Common.Service As S
					Inner Join Common.ServiceGroup As SG On SG.Id=S.ServiceGroupId
					Where S.CompanyId=@CompanyId And S.Id Not In (Select SyncServiceId From Bean.Item Where CompanyId=@CompanyId And SyncServiceId Is Not Null)
					And S.CoaId Is Not Null
				-- Update syncitem details in service
				Update S Set S.SyncItemId=I.Id,S.SyncItemdate=@GetDate,S.SyncItemStatus=@SyncStatusCompleted,SyncItemRemarks=Null 
				From Common.Service As S
				Inner Join Bean.Item As I On I.SyncServiceId=S.Id
				Where S.CompanyId=@CompanyId And I.CreatedDate=@GetDate

				/*Entity*/
				--Update existing records in Bean.Entiy table
				Update E Set E.CompanyId=@CompanyId,E.Name=C.Name,E.TypeId=C.ClientTypeId,E.IdTypeId=C.IdtypeId,E.IdNo=C.ClientIdNo,E.IsCustomer=1,E.CustTOPId=Case when TermsOfPaymentId is not null then TermsOfPaymentId else (select id from common.termsofpayment where companyid=@companyId and name='Credit - 0') end,
						E.CustCurrency=@BaseCurrency,E.CustNature=@CustNature,E.RecOrder=C.RecOrder,E.Remarks=C.Remarks,E.ModifiedBy=@UserCreatedOrModified,E.ModifiedDate=@GetDate,E.Status=Case When C.ClientStatus='Active' Then 1 When C.ClientStatus='Inactive' then 2 End ,E.IsExternalData=@IsExternalData,IsShowPayroll=1,Communication=C.Communication,E.ExternalEntityType='Client',E.SyncClientId=C.Id,E.SyncClientStatus=@SyncStatusUpdateCompleted,E.SyncClientDate=@GetDate,E.SyncClientRemarks=null
				From Bean.Entity As E
				Inner Join WorkFlow.Client As C On C.Id=E.SyncClientId
				Where E.CompanyId=@CompanyId
				-- Update syncentity details in Entity
				Update C Set C.SyncEntityStatus=@SyncStatusUpdateCompleted,C.SyncEntitydate=@GetDate,C.SyncEntityId=E.Id,C.SyncEntityRemarks=null
				From WorkFlow.Client As C 
				Inner Join Bean.Entity As E On E.SyncClientId=C.Id
				Where C.CompanyId=@CompanyId And E.ModifiedDate=@GetDate
				-- Insert Into Bean.Entity Table From Client
				Insert Into Bean.Entity (Id,CompanyId,Name,TypeId,IdTypeId,IdNo,IsCustomer,CustTOPId,CustCurrency,CustNature,RecOrder,Remarks,UserCreated,CreatedDate,Status,IsExternalData,IsShowPayroll,Communication,ExternalEntityType,SyncClientId,SyncClientDate,SyncClientStatus,SyncClientRemarks)
					Select NEWID(),@CompanyId,Name,ClientTypeId,IdtypeId,ClientIdNo,1,Case when TermsOfPaymentId is not null then TermsOfPaymentId else (select id from common.termsofpayment where companyid=@companyId and name='Credit - 0') end,
							@BaseCurrency,@CustNature,RecOrder,Remarks,@UserCreatedOrModified,@GetDate,Case When ClientStatus='Active' Then 1 When ClientStatus='Inactive' then 2 End,1,1 ,Communication,'Client',Id,@GetDate,@SyncStatusCompleted,Null
					From WorkFlow.Client 
					Where CompanyId=@CompanyId And Id Not In (Select SyncClientId From Bean.Entity Where CompanyId=@CompanyId And SyncClientId Is not null)
					And SyncAccountId Not In (Select SyncAccountId From Bean.Entity Where CompanyId=@CompanyId And SyncAccountId Is not null) 
				-- Update syncEntity details in Client
				Update C Set C.SyncEntityId=E.Id,C.SyncEntitydate=@GetDate,C.SyncEntityStatus=@SyncStatusCompleted,C.SyncEntityRemarks=Null 
				From WorkFlow.Client As C
				Inner Join Bean.Entity As E On E.SyncClientId=C.Id
				Where C.CompanyId=@CompanyId And E.CreatedDate=@GetDate
				-- Client Cursor Exists
				If Exists (Select Id From Common.CompanyModule Where CompanyId=@CompanyId And ModuleId in (Select Id from Common.ModuleMaster Where Name='Client Cursor') And Status=1)
				Begin
					-- Update syncEntity details in Account
					Update A Set A.SyncEntityId=E.Id,A.SyncEntitydate=@GetDate,A.SyncEntityStatus=@SyncStatusCompleted,A.SyncEntityRemarks=Null 
					From ClientCursor.Account As A
					Inner Join Bean.Entity As E On E.SyncClientId=A.SyncClientId
					Where E.CompanyId=@CompanyId And E.CreatedDate=@GetDate
					-- Update syncAccount details in Entity
					Update E Set E.SyncAccountId=A.Id,E.SyncAccountDate=@GetDate,E.SyncAccountStatus=@SyncStatusCompleted,E.SyncAccountRemarks=Null 
					From ClientCursor.Account As A
					Inner Join Bean.Entity As E On E.SyncClientId=A.SyncClientId
					Where E.CompanyId=@CompanyId And E.CreatedDate=@GetDate
				End
				
				--ContactDetails From Client
				Begin
					Set @IndCount=1
					Set @Count=0
					Insert into #Loc_Cont_Tbl
					Select Distinct Cd.Id As ContactDetailId,CD.EntityType,CD.ContactId,CD.EntityId,A.SyncEntityId From Common.ContactDetails As CD
					Inner Join WorkFlow.Client As A On A.Id=CD.EntityId
					Inner Join Common.Contact As C On C.Id=CD.ContactId 
					Where A.CompanyId=@CompanyId And A.SyncEntityId Is Not Null
					Select @Count=count(*) From #Loc_Cont_Tbl
					While @Count>=@IndCount
					Begin
						Select @ContactDetailId=ContactDetailId,@ContactId=ContactId,@CDEntityId=EntityId,@SyncEntityId=DestId From #Loc_Cont_Tbl Where Id=@IndCount
						If Not Exists (Select Id From Common.ContactDetails Where ContactId=@ContactId And EntityId=@SyncEntityId)
						Begin
							Set @New_ContctDtlId=NewId()
							Insert Into Common.ContactDetails (Id,ContactId,EntityId,EntityType,Designation,Communication,Matters,IsPrimaryContact,IsReminderReceipient,RecOrder,OtherDesignation,IsPinned,CursorShortCode,Status,UserCreated,CreatedDate,Remarks,DocId,DocType,Iscopy)
								Select @New_ContctDtlId,@ContactId,@SyncEntityId,'Entity',Designation,Communication,Matters,IsPrimaryContact,IsReminderReceipient,RecOrder,OtherDesignation,IsPinned,'Bean',Status,@UserCreatedOrModified,@Getdate,Remarks,@CDEntityId,'Client',IsCopy From Common.ContactDetails Where Id=@ContactDetailId
						End
						Else
						Begin
							Update A Set A.Designation=B.Designation,A.Communication=B.Communication,A.IsPrimaryContact=B.IsPrimaryContact,A.Matters=B.Matters,A.RecOrder=B.RecOrder,A.Status=B.Status,A.IsReminderReceipient=B.IsReminderReceipient,ModifiedBy=@UserCreatedOrModified,ModifiedDate=@GetDate,A.Remarks=B.Remarks,A.IsCopy=B.IsCopy From Common.ContactDetails As A
							Inner Join 
							(Select * From Common.ContactDetails Where EntityId=@CDEntityId And ContactId=@ContactId) As B On B.ContactId=A.ContactId
							Where A.ContactId=@ContactId And A.EntityId=@SyncEntityId
						End
						Set @IndCount=@IndCount+1
					End
					Truncate Table #Loc_Cont_Tbl
				End 
				--ContactDetails From Entity
				Begin
					Set @IndCount=1
					Set @Count=0
					Insert into #Loc_Cont_Tbl
					Select Distinct Cd.Id As ContactDetailId,CD.EntityType,CD.ContactId,CD.EntityId,A.SyncClientId From Common.ContactDetails As CD
					Inner Join Bean.Entity As A On A.Id=CD.EntityId
					Inner Join Common.Contact As C On C.Id=CD.ContactId 
					Where A.CompanyId=@CompanyId And A.SyncClientId Is Not Null
					Select @Count=count(*) From #Loc_Cont_Tbl
					While @Count>=@IndCount
					Begin
						Select @ContactDetailId=ContactDetailId,@ContactId=ContactId,@CDEntityId=EntityId,@SyncClientId=DestId From #Loc_Cont_Tbl Where Id=@IndCount
						If Not Exists (Select Id From Common.ContactDetails Where ContactId=@ContactId And EntityId=@SyncClientId)
						Begin
							Delete From Common.ContactDetails Where Id=@ContactDetailId
						End
						Set @IndCount=@IndCount+1
					End
					Truncate Table #Loc_Cont_Tbl
				End 
				--Addresses From Client
				Begin
					Set @IndCount=1
					Insert into #Loc_AdrsTbl
					Select Distinct Adrs.id As AddressId,Adrs.AddressBookId,Adrs.AddSectionType,Adrs.AddTypeId,A.SyncEntityId From Common.Addresses As Adrs
					Inner join WorkFlow.Client As A On A.Id=Adrs.AddTypeId 
					Where A.CompanyId=@CompanyId And A.SyncEntityId Is Not Null
					Select @AdrsCount=count(*) From #Loc_AdrsTbl
					While @AdrsCount>=@IndCount
					Begin
						Select @AddressId=AddressId,@AddressBookId=AddressBookId,@AddrsAddSecType=AddSectionType,@AdrsEntityId=AdrsEntityId,@AdrsSyncEntityId=DestId From #Loc_AdrsTbl Where Id=@IndCount
						If Not Exists (Select Id From Common.Addresses Where Addsectiontype=@AddrsAddSecType And AddTypeId=@AdrsSyncEntityId And AddressBookId=@AddressBookId/*And CompanyId=@CompanyId*/)
						Begin
							Insert Into Common.Addresses(Id,AddSectionType,AddType,AddTypeId,AddTypeIdInt,AddressBookId,Status,DocumentId,EntityId,ScreenName,IsCurrentAddress,CompanyId)
								Select NEWID(),AddSectionType,'Entity',@AdrsSyncEntityId,AddTypeIdInt,AddressBookId,Status,@AdrsEntityId,null,null,IsCurrentAddress,@CompanyId From Common.Addresses Where Id=@AddressId /*And CompanyId=@CompanyId*/
						End
						Set @IndCount=@IndCount+1
					End
					Truncate Table #Loc_AdrsTbl
				End 
				--Addresses From Entity
				Begin
					Set @IndCount=1
					Insert into #Loc_AdrsTbl
					Select Distinct Adrs.id As AddressId,Adrs.AddressBookId,Adrs.AddSectionType,Adrs.AddTypeId,A.SyncClientId From Common.Addresses As Adrs
					Inner join Bean.Entity As A On A.Id=Adrs.AddTypeId 
					Where A.CompanyId=@CompanyId And A.SyncClientId Is Not Null
					Select @AdrsCount=count(*) From #Loc_AdrsTbl
					While @AdrsCount>=@IndCount
					Begin
						Select @AddressId=AddressId,@AddressBookId=AddressBookId,@AddrsAddSecType=AddSectionType,@AdrsEntityId=AdrsEntityId,@AdrsSyncClientId=DestId From #Loc_AdrsTbl Where Id=@IndCount
						If Not Exists (Select Id From Common.Addresses Where Addsectiontype=@AddrsAddSecType And AddTypeId=@AdrsSyncClientId And Addressbookid=@AddressBookId/*And CompanyId=@CompanyId*/)
						Begin
							Delete From Common.Addresses Where Id=@AddressId
						End
						Set @IndCount=@IndCount+1
					End
					Truncate Table #Loc_AdrsTbl
				End 
				--ContactDetail Address From Client
				Begin
					Set @IndCount=1
					Insert into #Loc_AdrsTbl
					Select Distinct Adrs.id As AddressId,Adrs.AddressBookId,Adrs.AddSectionType,Adrs.AddTypeId,A.EntityId From Common.Addresses As Adrs
					Inner join Common.ContactDetails As A On A.Id=Adrs.AddTypeId 
					Where A.EntityId In (Select Id From WorkFlow.Client Where CompanyId=@CompanyId And SyncEntityId Is Not Null)
					Select @AdrsCount=count(*) From #Loc_AdrsTbl
					While @AdrsCount>=@IndCount
					Begin
						Select @AddressId=AddressId,@AddressBookId=AddressBookId,@AddrsAddSecType=AddSectionType,@AdrsEntityId=AdrsEntityId,@CntdtlEntityId=DestId From #Loc_AdrsTbl Where Id=@IndCount
						Select @ContactId=ContactId,@SyncClientId=EntityId From Common.ContactDetails Where Id=@AdrsEntityId
						If @ContactId Is Not null And @SyncClientId Is Not Null
						Begin
							Set @SyncEntityId=(Select Id From Bean.Entity Where CompanyId=@CompanyId And SyncClientId=@SyncClientId And SyncClientId Is Not Null)
							If @SyncEntityId Is Not Null
							Begin
								Select @CntDtlDestId=Id From Common.ContactDetails Where EntityId=@SyncEntityId And ContactId=@ContactId
								If Not Exists (Select Id From Common.Addresses Where Addsectiontype=@AddrsAddSecType And AddTypeId=@CntDtlDestId And AddressBookId=@AddressBookId/*And CompanyId=@CompanyId*/)
								Begin
									Insert Into Common.Addresses(Id,AddSectionType,AddType,AddTypeId,AddTypeIdInt,AddressBookId,Status,DocumentId,EntityId,ScreenName,IsCurrentAddress,CompanyId)
										Select NEWID(),AddSectionType,'EntityContactDetailId',@CntDtlDestId,AddTypeIdInt,AddressBookId,Status,@AdrsEntityId,null,null,IsCurrentAddress,@CompanyId From Common.Addresses Where Id=@AddressId /*And CompanyId=@CompanyId*/
								End
							End
						End
						Set @IndCount=@IndCount+1
					End
					Truncate Table #Loc_AdrsTbl
				End 
				--ContactDetail Address From Entity
				Begin
					Set @IndCount=1
					Insert into #Loc_AdrsTbl
					Select Distinct Adrs.id As AddressId,Adrs.AddressBookId,Adrs.AddSectionType,Adrs.AddTypeId,A.EntityId From Common.Addresses As Adrs
					Inner join Common.ContactDetails As A On A.Id=Adrs.AddTypeId 
					Where A.EntityId In (Select Id From Bean.Entity Where CompanyId=@CompanyId And SyncClientId Is Not Null)
					Select @AdrsCount=count(*) From #Loc_AdrsTbl
					While @AdrsCount>=@IndCount
					Begin
						Select @AddressId=AddressId,@AddressBookId=AddressBookId,@AddrsAddSecType=AddSectionType,@AdrsEntityId=AdrsEntityId,@CntdtlEntityId=DestId From #Loc_AdrsTbl Where Id=@IndCount
						Select @ContactId=ContactId,@SyncEntityId=EntityId From Common.ContactDetails Where Id=@AdrsEntityId
						If @ContactId Is Not null And @SyncEntityId Is Not Null
						Begin
							Set @SyncClientId=(Select Id From WorkFlow.Client Where CompanyId=@CompanyId And SyncEntityId=@SyncEntityId And SyncEntityId Is Not Null)
							If @SyncClientId Is Not Null
							Begin
								Select @CntDtlDestId=Id From Common.ContactDetails Where EntityId=@SyncClientId And ContactId=@ContactId
								If Not Exists (Select Id From Common.Addresses Where Addsectiontype=@AddrsAddSecType And AddTypeId=@CntDtlDestId And AddressBookId=@AddressBookId /*And CompanyId=@CompanyId*/)
								Begin
									Delete From Common.Addresses Where Id=@AddressId
								End
							End
						End
						Set @IndCount=@IndCount+1
					End
					Truncate Table #Loc_AdrsTbl
				End 
			End
			-- If Workflow Is Not Activated Then Check ClientCursor Is Activated Or Not
			Else If Exists (Select Id From Common.CompanyModule Where CompanyId=@CompanyId And ModuleId in (Select Id from Common.ModuleMaster Where Name='Client Cursor') And Status=1)
			Begin
				--Update Bean.Entity Table and Account
				Update E Set E.Name=A.Name,E.TypeId=A.AccountTypeId,E.IdTypeId=A.AccountIdTypeId,E.IdNo=A.AccountIdNo,E.IsCustomer=1,E.CustTOPId=Case when TermsOfPaymentId is not null then TermsOfPaymentId else (select id from common.termsofpayment where companyid=@companyId and name='Credit - 0') end,E.CustCurrency=@BaseCurrency,E.CustNature='Trade',
						E.RecOrder=A.RecOrder,E.Remarks=A.Remarks,E.ModifiedBy=@UserCreatedOrModified,E.ModifiedDate=@GetDate,E.Status=Case When A.AccountStatus='Active' Then 1 When A.AccountStatus='Inactive' then 2 End ,E.IsExternalData=@IsExternalData,E.IsShowPayroll=1,E.Communication=A.Communication,E.ExternalEntityType='Account',E.SyncAccountDate=@GetDate,E.SyncAccountRemarks=Null,E.SyncAccountStatus=@SyncStatusUpdateCompleted 
				From Bean.Entity As E
				Inner Join ClientCursor.Account As A On A.Id=E.SyncAccountId
				Where E.CompanyId=@CompanyId And E.SyncAccountId Is Not Null
				--Update SyncEntity details in Account
				Update A Set A.SyncEntityDate=@GetDate,A.SyncEntityStatus=@SyncStatusUpdateCompleted,A.SyncEntityRemarks=null From ClientCursor.Account As A
				Inner Join Bean.Entity As E On E.SyncAccountId=A.Id
				Where A.CompanyId=@CompanyId And E.ModifiedDate=@GetDate
				-- Insert Into Bean.Entity Table From Account
				Insert Into Bean.Entity(Id,Name,CompanyId,TypeId,IdTypeId,IdNo,IsCustomer,CustTOPId,CustCurrency,CustNature,RecOrder,Remarks,UserCreated,CreatedDate,Status,IsExternalData,IsShowPayroll,Communication,ExternalEntityType,SyncAccountId,SyncAccountDate,SyncAccountRemarks,SyncAccountStatus)
				Select NEWID(),Name,@CompanyId,AccountTypeId,AccountIdTypeId,AccountIdNo,1 As Iscutomer,Case when TermsOfPaymentId is not null then TermsOfPaymentId else (select id from common.termsofpayment where companyid=@companyId and name='Credit - 0') end,
						@BaseCurrency,'Trade',RecOrder,Remarks,@UserCreatedOrModified,@GetDate,Case When AccountStatus='Active' Then 1 When AccountStatus='Inactive' then 2 End ,@IsExternalData,1 As IsShowPayroll,Communication,'Account',Id,@GetDate,null,@SyncStatusCompleted
				From ClientCursor.Account
				Where CompanyId=@CompanyId And Id Not In (select SyncAccountId from Bean.Entity Where CompanyId=@CompanyId And SyncAccountId Is Not Null)
				And SyncClientId Not In (Select SyncClientId From Bean.Entity Where CompanyId=@CompanyId And SyncClientId Is Not Null)
				-- Update syncEntity details in Account
				Update A Set A.SyncEntityId=E.Id,A.SyncEntitydate=@GetDate,A.SyncEntityStatus=@SyncStatusCompleted,A.SyncEntityRemarks=Null 
				From ClientCursor.Account As A
				Inner Join Bean.Entity As E On E.SyncAccountId=A.Id 
				Where A.CompanyId=@CompanyId And E.CreatedDate=@GetDate
				--ContactDetails From Account
				Begin
					Set @IndCount=1
					Set @Count=0
					Insert into #Loc_Cont_Tbl
					Select Distinct Cd.Id As ContactDetailId,CD.EntityType,CD.ContactId,CD.EntityId,A.SyncEntityId From Common.ContactDetails As CD
					Inner Join ClientCursor.Account As A On A.Id=CD.EntityId
					Inner Join Common.Contact As C On C.Id=CD.ContactId 
					Where A.CompanyId=@CompanyId And A.SyncEntityId Is Not Null
					Select @Count=count(*) From #Loc_Cont_Tbl
					While @Count>=@IndCount
					Begin
						Select @ContactDetailId=ContactDetailId,@ContactId=ContactId,@CDEntityId=EntityId,@SyncEntityId=DestId From #Loc_Cont_Tbl Where Id=@IndCount
						If Not Exists (Select Id From Common.ContactDetails Where ContactId=@ContactId And EntityId=@SyncEntityId)
						Begin
							Set @New_ContctDtlId=NewId()
							Insert Into Common.ContactDetails (Id,ContactId,EntityId,EntityType,Designation,Communication,Matters,IsPrimaryContact,IsReminderReceipient,RecOrder,OtherDesignation,IsPinned,CursorShortCode,Status,UserCreated,CreatedDate,Remarks,DocId,DocType)
								Select @New_ContctDtlId,@ContactId,@SyncEntityId,'Entity',Designation,Communication,Matters,IsPrimaryContact,IsReminderReceipient,RecOrder,OtherDesignation,IsPinned,'Bean',Status,@UserCreatedOrModified,@Getdate,Remarks,@CDEntityId,'Account' From Common.ContactDetails Where Id=@ContactDetailId
						End
						Else
						Begin
							Update A Set A.Designation=B.Designation,A.Communication=B.Communication,A.IsPrimaryContact=B.IsPrimaryContact,A.Matters=B.Matters,A.RecOrder=B.RecOrder,A.Status=B.Status,A.IsReminderReceipient=B.IsReminderReceipient,ModifiedBy=@UserCreatedOrModified,ModifiedDate=@GetDate,A.Remarks=B.Remarks From Common.ContactDetails As A
							Inner Join 
							(Select * From Common.ContactDetails Where EntityId=@CDEntityId And ContactId=@ContactId) As B On B.ContactId=A.ContactId
							Where A.ContactId=@ContactId And A.EntityId=@SyncEntityId
						End
						Set @IndCount=@IndCount+1
					End
					Truncate Table #Loc_Cont_Tbl
				End 
				--ContactDetails From Entity
				Begin
					Set @IndCount=1
					Set @Count=0
					Insert into #Loc_Cont_Tbl
					Select Distinct Cd.Id As ContactDetailId,CD.EntityType,CD.ContactId,CD.EntityId,A.SyncAccountId From Common.ContactDetails As CD
					Inner Join Bean.Entity As A On A.Id=CD.EntityId
					Inner Join Common.Contact As C On C.Id=CD.ContactId 
					Where A.CompanyId=@CompanyId And A.SyncClientId Is Not Null
					Select @Count=count(*) From #Loc_Cont_Tbl
					While @Count>=@IndCount
					Begin
						Select @ContactDetailId=ContactDetailId,@ContactId=ContactId,@CDEntityId=EntityId,@SyncAccountId=DestId From #Loc_Cont_Tbl Where Id=@IndCount
						If Not Exists (Select Id From Common.ContactDetails Where ContactId=@ContactId And EntityId=@SyncAccountId)
						Begin
							Delete From Common.ContactDetails Where Id=@ContactDetailId
						End
						Set @IndCount=@IndCount+1
					End
					Truncate Table #Loc_Cont_Tbl
				End 
				--Addresses From Account
				Begin
					Set @IndCount=1
					Insert into #Loc_AdrsTbl
					Select Distinct Adrs.id As AddressId,Adrs.AddressBookId,Adrs.AddSectionType,Adrs.AddTypeId,A.SyncEntityId From Common.Addresses As Adrs
					Inner join ClientCursor.Account As A On A.Id=Adrs.AddTypeId 
					Where A.CompanyId=@CompanyId And A.SyncEntityId Is Not Null
					Select @AdrsCount=count(*) From #Loc_AdrsTbl
					While @AdrsCount>=@IndCount
					Begin
						Select @AddressId=AddressId,@AddressBookId=AddressBookId,@AddrsAddSecType=AddSectionType,@AdrsEntityId=AdrsEntityId,@AdrsSyncEntityId=DestId From #Loc_AdrsTbl Where Id=@IndCount
						If Not Exists (Select Id From Common.Addresses Where Addsectiontype=@AddrsAddSecType And AddTypeId=@AdrsSyncEntityId And AddressBookId=@AddressBookId/*And CompanyId=@CompanyId*/)
						Begin
							Insert Into Common.Addresses(Id,AddSectionType,AddType,AddTypeId,AddTypeIdInt,AddressBookId,Status,DocumentId,EntityId,ScreenName,IsCurrentAddress,CompanyId)
								Select NEWID(),AddSectionType,'Entity',@AdrsSyncEntityId,AddTypeIdInt,AddressBookId,Status,@AdrsEntityId,null,null,IsCurrentAddress,@CompanyId From Common.Addresses Where Id=@AddressId /*And CompanyId=@CompanyId*/
						End
						Set @IndCount=@IndCount+1
					End
					Truncate Table #Loc_AdrsTbl
				End 
				--Addresses From Entity
				Begin
					Set @IndCount=1
					Insert into #Loc_AdrsTbl
					Select Distinct Adrs.id As AddressId,Adrs.AddressBookId,Adrs.AddSectionType,Adrs.AddTypeId,A.SyncAccountId From Common.Addresses As Adrs
					Inner join Bean.Entity As A On A.Id=Adrs.AddTypeId 
					Where A.CompanyId=@CompanyId And A.SyncAccountId Is Not Null
					Select @AdrsCount=count(*) From #Loc_AdrsTbl
					While @AdrsCount>=@IndCount
					Begin
						Select @AddressId=AddressId,@AddressBookId=AddressBookId,@AddrsAddSecType=AddSectionType,@AdrsEntityId=AdrsEntityId,@AdrsSyncAccountId=DestId From #Loc_AdrsTbl Where Id=@IndCount
						If Not Exists (Select Id From Common.Addresses Where Addsectiontype=@AddrsAddSecType And AddTypeId=@AdrsSyncAccountId And Addressbookid=@AddressBookId/*And CompanyId=@CompanyId*/)
						Begin
							Delete From Common.Addresses Where Id=@AddressId
						End
						Set @IndCount=@IndCount+1
					End
					Truncate Table #Loc_AdrsTbl
				End 
				--ContactDetail Addresses From Account
				Begin
					Set @IndCount=1
					Insert into #Loc_AdrsTbl
					Select Distinct Adrs.id As AddressId,Adrs.AddressBookId,Adrs.AddSectionType,Adrs.AddTypeId,A.EntityId As AccountId From Common.Addresses As Adrs
					Inner join Common.ContactDetails As A On A.Id=Adrs.AddTypeId 
					Where A.EntityId In (Select Id From ClientCursor.Account Where CompanyId=@CompanyId And SyncEntityId Is Not Null)
					Select @AdrsCount=count(*) From #Loc_AdrsTbl
					While @AdrsCount>=@IndCount
					Begin
						Select @AddressId=AddressId,@AddressBookId=AddressBookId,@AddrsAddSecType=AddSectionType,@AdrsEntityId=AdrsEntityId,@CntdtlEntityId=DestId From #Loc_AdrsTbl Where Id=@IndCount
						Select @ContactId=ContactId,@SyncAccountId=EntityId From Common.ContactDetails Where Id=@AdrsEntityId
						If @ContactId Is Not null And @SyncAccountId Is Not Null
						Begin
							Set @SyncEntityId=(Select Id From Bean.Entity Where CompanyId=@CompanyId And SyncAccountId=@SyncAccountId And SyncAccountId Is Not Null)
							If @SyncEntityId Is Not Null
							Begin
								Select @CntDtlDestId=Id From Common.ContactDetails Where EntityId=@SyncEntityId And ContactId=@ContactId
								If Not Exists (Select Id From Common.Addresses Where Addsectiontype=@AddrsAddSecType And AddTypeId=@CntDtlDestId And AddressBookId=@AddressBookId/*And CompanyId=@CompanyId*/)
								Begin
									Insert Into Common.Addresses(Id,AddSectionType,AddType,AddTypeId,AddTypeIdInt,AddressBookId,Status,DocumentId,EntityId,ScreenName,IsCurrentAddress,CompanyId)
										Select NEWID(),AddSectionType,'EntityContactDetailId',@CntDtlDestId,AddTypeIdInt,AddressBookId,Status,@AdrsEntityId,null,null,IsCurrentAddress,@CompanyId From Common.Addresses Where Id=@AddressId /*And CompanyId=@CompanyId*/
								End
							End
						End
						Set @IndCount=@IndCount+1
					End
					Truncate Table #Loc_AdrsTbl
				End 
				--ContactDetail Addresses From Entity
				Begin
					Set @IndCount=1
					Insert into #Loc_AdrsTbl
					Select Distinct Adrs.id As AddressId,Adrs.AddressBookId,Adrs.AddSectionType,Adrs.AddTypeId,A.EntityId From Common.Addresses As Adrs
					Inner join Common.ContactDetails As A On A.Id=Adrs.AddTypeId 
					Where A.EntityId In (Select Id From Bean.Entity Where CompanyId=@CompanyId And SyncAccountId Is Not Null)
					Select @AdrsCount=count(*) From #Loc_AdrsTbl
					While @AdrsCount>=@IndCount
					Begin
						Select @AddressId=AddressId,@AddressBookId=AddressBookId,@AddrsAddSecType=AddSectionType,@AdrsEntityId=AdrsEntityId,@CntdtlEntityId=DestId From #Loc_AdrsTbl Where Id=@IndCount
						Select @ContactId=ContactId,@SyncEntityId=EntityId From Common.ContactDetails Where Id=@AdrsEntityId
						If @ContactId Is Not null And @SyncEntityId Is Not Null
						Begin
							Set @SyncAccountId=(Select Id From ClientCursor.Account Where CompanyId=@CompanyId And SyncEntityId=@SyncEntityId And SyncEntityId Is Not Null)
							If @SyncAccountId Is Not Null
							Begin
								Select @CntDtlDestId=Id From Common.ContactDetails Where EntityId=@SyncAccountId And ContactId=@ContactId
								If Not Exists (Select Id From Common.Addresses Where Addsectiontype=@AddrsAddSecType And AddTypeId=@CntDtlDestId And AddressBookId=@AddressBookId /*And CompanyId=@CompanyId*/)
								Begin
									Delete From Common.Addresses Where Id=@AddressId
								End
							End
						End
						Set @IndCount=@IndCount+1
					End
					Truncate Table #Loc_AdrsTbl
				End 
			End

			If Exists(Select Id From Common.CompanyModule Where CompanyId=@CompanyId And ModuleId in (Select Id from Common.ModuleMaster Where Name='HR Cursor') And Status=1)
			Begin
					--Update matching data in employee & Entity tables
					Update E Set E.CompanyId=@CompanyId,E.Name=CONCAT(FirstName,'(',EmployeeId,')'),E.DocumentId=Emp.Id,E.TypeId=null,E.IdTypeId=Null,E.IdNo=Emp.IdNo,E.IsCustomer=0,E.IsVendor=1,E.VenCurrency=@BaseCurrency,E.VenNature='Others',E.RecOrder=1,E.Remarks=Emp.Remarks,UserCreated=@UserCreatedOrModified,
					E.CreatedDate=@GetDate,E.Communication=Emp.Communication,E.Status=Emp.Status,E.IsExternalData=1,E.IsShowPayroll=1,E.VendorType='Employee',E.ExternalEntityType='Employee',E.SyncEmployeeDate=@GetDate,E.SyncEmployeeRemarks=null,SyncEmployeeStatus=@SyncStatusUpdateCompleted
					From Bean.Entity As E 
					Inner Join Common.Employee As Emp On Emp.SyncEntityId=E.Id
					Where Emp.CompanyId=@CompanyId
					--update syncing details
					Update Emp Set Emp.SyncEntityDate=@GetDate,Emp.SyncEntityRemarks=null,Emp.SyncEntityStatus=@SyncStatusUpdateCompleted From Common.Employee As Emp
					Inner Join Bean.Entity As E On E.SyncEmployeeId=Emp.Id
					Where E.CompanyId=@CompanyId And E.ModifiedDate=@GetDate
					--insert into Entity table
					Insert Into Bean.Entity (Id,CompanyId,Name,DocumentId,TypeId,IdTypeId,IdNo,IsCustomer,IsVendor,VenTOPId,VenCurrency,VenNature,
						RecOrder,Remarks,UserCreated,CreatedDate,Communication,Status,IsExternalData,IsShowPayroll,VendorType,ExternalEntityType,SyncEmployeeId,SyncEmployeeStatus,SyncEmployeeDate,SyncEmployeeRemarks)
					Select Newid(),CompanyId,CONCAT(FirstName,'(',EmployeeId,')'),Id,null,null,IdNo,0,1,(select id from common.termsofpayment where companyid=@companyId and name='Credit - 0'),
						@BaseCurrency,'Others',1,Remarks,@UserCreatedOrModified,@GetDate,Communication,Status,1,1,'Employee','Employee',Id,@SyncStatusCompleted,@GetDate,null
					From Common.Employee
					Where Companyid=@CompanyId
					And Id Not In (Select SyncEmployeeId From Bean.Entity Where CompanyId=@CompanyId) 
					--update Syncdetails in employee table
					Update Emp Set Emp.SyncEntityId=E.Id,Emp.SyncEntityDate=@GetDate,Emp.SyncEntityStatus=@SyncStatusCompleted,Emp.SyncEntityRemarks=null From Common.Employee As Emp
					Inner Join Bean.Entity As E On E.SyncEmployeeId=Emp.Id
					Where E.CompanyId=@CompanyId And E.Createddate=@GetDate
					--Addresses From Employee
					Begin
						Set @IndCount=1
						Insert into #Loc_AdrsTbl
						Select Distinct Adrs.id As AddressId,Adrs.AddressBookId,Adrs.AddSectionType,Adrs.AddTypeId,Emp.SyncEntityId From Common.Addresses As Adrs
						Inner join Common.Employee As Emp On Emp.Id=Adrs.AddTypeId 
						Where Emp.CompanyId=@CompanyId And Emp.SyncEntityId Is Not Null
						Select @AdrsCount=count(*) From #Loc_AdrsTbl
						While @AdrsCount>=@IndCount
						Begin
							Select @AddressId=AddressId,@AddressBookId=AddressBookId,@AddrsAddSecType=AddSectionType,@AdrsEntityId=AdrsEntityId,@AdrsSyncEntityId=DestId From #Loc_AdrsTbl Where Id=@IndCount
							If Not Exists (Select Id From Common.Addresses Where Addsectiontype=@AddrsAddSecType And AddTypeId=@AdrsSyncEntityId /*And CompanyId=@CompanyId*/)
							Begin
								Insert Into Common.Addresses(Id,AddSectionType,AddType,AddTypeId,AddTypeIdInt,AddressBookId,Status,DocumentId,EntityId,ScreenName,IsCurrentAddress,CompanyId)
									Select NEWID(),AddSectionType,'Entity',@AdrsSyncEntityId,AddTypeIdInt,AddressBookId,Status,@AdrsEntityId,null,null,IsCurrentAddress,@CompanyId From Common.Addresses Where Id=@AddressId /*And CompanyId=@CompanyId*/
							End
							Set @IndCount=@IndCount+1
						End
						Truncate Table #Loc_AdrsTbl
					End 
					--Addresses From Entity
					Begin
						Set @IndCount=1
						Insert into #Loc_AdrsTbl
						Select Distinct Adrs.id As AddressId,Adrs.AddressBookId,Adrs.AddSectionType,Adrs.AddTypeId,A.SyncEmployeeId From Common.Addresses As Adrs
						Inner join Bean.Entity As A On A.Id=Adrs.AddTypeId 
						Where A.CompanyId=@CompanyId And A.SyncEmployeeId Is Not Null
						Select @AdrsCount=count(*) From #Loc_AdrsTbl
						While @AdrsCount>=@IndCount
						Begin
							Select @AddressId=AddressId,@AddressBookId=AddressBookId,@AddrsAddSecType=AddSectionType,@AdrsEntityId=AdrsEntityId,@AdrsSyncEmployeeId=DestId From #Loc_AdrsTbl Where Id=@IndCount
							If Not Exists (Select Id From Common.Addresses Where Addsectiontype=@AddrsAddSecType And AddTypeId=@AdrsSyncEmployeeId And Addressbookid=@AddressBookId/*And CompanyId=@CompanyId*/)
							Begin
								Delete From Common.Addresses Where Id=@AddressId
							End
							Set @IndCount=@IndCount+1
						End
						Truncate Table #Loc_AdrsTbl
					End 
				End
		End

		------ WorkFlow Cursor ----------
		If @CursorName='WorkFlow Cursor'
		Begin
			-- If ClientCursor Is Activated
			If Exists(Select Id From Common.CompanyModule Where CompanyId=@CompanyId And ModuleId in (Select Id from Common.ModuleMaster Where Name='Client Cursor') And Status=1)
			Begin
				--Update Workflow.Client And Clientcursor.Account
				Update C Set C.Name=A.Name,C.ClientTypeId=A.AccountTypeId,C.IdtypeId=A.AccountIdTypeId,C.ClientIdNo=A.AccountIdNo,C.TermsOfPaymentId=A.TermsOfPaymentId,C.Industry=A.Industry,C.Source=A.Source,C.SourceId=A.SourceId,C.SourceName=A.SourceName,C.SourceRemarks=A.SourceRemarks,C.IncorporationDate=A.IncorporationDate,
						C.FinancialYearEnd=A.FinancialYearEnd,C.CountryOfIncorporation=A.CountryOfIncorporation,C.ClientStatus=A.AccountStatus,C.PrincipalActivities=A.PrincipalActivities,C.RecOrder=A.RecOrder,C.Remarks=A.Remarks,C.ModifiedBy=@UserCreatedOrModified,C.ModifiedDate=@GetDate,C.Version=A.Version,C.Status=Case When A.AccountStatus='Active' Then 1 When A.AccountStatus='Inactive' then 2 End ,
						C.Communication=A.Communication,C.SyncAccountDate=@GetDate,C.SyncAccountRemarks=null,SyncAccountStatus=@SyncStatusUpdateCompleted
				From WorkFlow.Client As C
				Inner Join ClientCursor.Account As A On A.Id=C.SyncAccountId
				Where A.CompanyId=@CompanyId 
				--Upadet SyncClientid in Account table
				Update A Set A.SyncClientStatus=@SyncStatusUpdateCompleted,A.SyncClientDate=@GetDate,SyncClientRemarks=null From ClientCursor.Account As A
				Inner Join WorkFlow.Client as C On C.Id=A.SyncClientId
				Where C.CompanyId=@CompanyId And C.ModifiedDate=@GetDate
				--Getting systemrefnumber
				Set @GeneratedNumber=(Select GeneratedNumber From Common.AutoNumber Where CompanyId=@CompanyId And EntityType='WorkFlow Client' And ModuleMasterId=(Select Id From Common.ModuleMaster Where Name='Workflow Cursor'))
				Set @SystemRefnum=(Select Top(1) SystemRefNo From WorkFlow.Client Where CompanyId=@CompanyId And SystemRefNo Is not null Order By CreatedDate Desc)
				Set @SystemRefnum=Reverse(SUBSTRING(Reverse(@SystemRefnum),PATINDEX('%[0-9][^0-9]%', Reverse(@SystemRefnum))+1,DATALENGTH(@SystemRefnum)))
				--Insert into client table from account table
				Insert Into WorkFlow.Client (Id,Name,CompanyId,ClientTypeId,IdtypeId,ClientIdNo,TermsOfPaymentId,Industry,Source,SourceId,SourceName,SourceRemarks,IncorporationDate,FinancialYearEnd,CountryOfIncorporation,ClientStatus,PrincipalActivities,RecOrder,Remarks,UserCreated,CreatedDate,Version,Status,Communication,SystemRefNo,SyncAccountId,SyncAccountStatus,SyncAccountRemarks,SyncAccountDate)
					Select NEWID(),Name,@CompanyId,AccountTypeId,AccountIdTypeId,AccountIdNo,TermsOfPaymentId,Industry,Source,SourceId,SourceName,SourceRemarks,IncorporationDate,FinancialYearEnd,CountryOfIncorporation,AccountStatus,PrincipalActivities,RecOrder,Remarks,@UserCreatedOrModified,@GetDate,Version,Status,Communication,CONCAT(@SystemRefnum,Right('0000000000'+Cast((@GeneratedNumber+ROW_NUMBER () Over (Order By Id) ) As varchar),Len(@GeneratedNumber))),Id,@SyncStatusCompleted,Null,@GetDate
					From ClientCursor.Account 
					Where CompanyId=@CompanyId And IsAccount=1 And Status=1
					And Id Not In (Select SyncAccountId From WorkFlow.Client Where CompanyId=@CompanyId And SyncAccountId Is Not NUll)
					And SyncEntityId Not In (Select SyncEntityId From WorkFlow.Client Where CompanyId=@CompanyId And SyncEntityId Is not null)
					--And Id Not In (Select C.SyncAccountId From Bean.Entity As E Inner Join WorkFlow.Client As C On C.SyncEntityId=E.Id Where E.CompanyId=@CompanyId And SyncAccountId Is Not NUll)
				Insert Into WorkFlow.ClientStatusChange (Id,CompanyId,ClientId,State,ModifiedBy,ModifiedDate)
					Select Newid(),@CompanyId,Id,'Active',@UserCreatedOrModified,@GetDate From WorkFlow.Client Where CompanyId=@CompanyId And CreatedDate=@GetDate
				-- Update syncClient Details in  Account
				Update A Set A.SyncClientId=C.Id,A.SyncClientDate=@GetDate,A.SyncClientStatus=@SyncStatusCompleted,A.SyncClientRemarks=Null 
				From ClientCursor.Account As A
				Inner Join WorkFlow.Client As C On C.SyncAccountId=A.Id 
				Where A.CompanyId=@CompanyId And C.CreatedDate=@GetDate
				--Update Autogeneratenumber
				Set @SystemRefnum=(Select Top(1) SystemRefNo From WorkFlow.Client Where CompanyId=@CompanyId And SystemRefNo Is not null Order By CreatedDate Desc)
				Set @SystemRefnum=Reverse(SUBSTRING(Reverse(@SystemRefnum),0,PATINDEX('%[0-9][^0-9]%', Reverse(@SystemRefnum))+1))
				Update Common.AutoNumber Set GeneratedNumber=@SystemRefnum Where CompanyId=@CompanyId And EntityType='WorkFlow Client' And ModuleMasterId=(Select Id From Common.ModuleMaster Where Name='Workflow Cursor')
				--If Bean also Activated
				If Exists(Select Id From Common.CompanyModule Where CompanyId=@CompanyId And ModuleId in (Select Id from Common.ModuleMaster Where Name='Bean Cursor') And Status=1)
				Begin
					-- Update syncClient details in Entity
					Update E Set E.SyncClientId=C.Id,E.SyncClientRemarks=null,E.SyncClientStatus=@SyncStatusCompleted,E.SyncClientDate=@GetDate From Bean.Entity As E
					Inner join WorkFlow.Client As C on C.SyncAccountId=E.SyncAccountId
					Where C.SyncAccountId Is Not Null And E.SyncAccountId Is Not Null And C.CompanyId=@CompanyId And C.CreatedDate=@GetDate
					--Update SyncEntityDetails in Client
					Update C Set C.SyncEntityId=E.Id,C.SyncEntityRemarks=Null,C.SyncEntityStatus=@SyncStatusCompleted,C.SyncEntityDate=@GetDate From WorkFlow.Client As C
					inner Join Bean.Entity As E On E.SyncAccountId=C.SyncAccountId
					Where C.SyncAccountId Is Not Null And E.SyncAccountId Is Not Null And C.CompanyId=@CompanyId And C.CreatedDate=@GetDate
				End
				--ContactDetails From Account
				Begin
					Set @IndCount=1
					Set @Count=0
					Insert into #Loc_Cont_Tbl
					Select Distinct Cd.Id As ContactDetailId,CD.EntityType,CD.ContactId,CD.EntityId,A.SyncClientId From Common.ContactDetails As CD
					Inner Join ClientCursor.Account As A On A.Id=CD.EntityId
					Inner Join Common.Contact As C On C.Id=CD.ContactId 
					Where A.CompanyId=@CompanyId And A.SyncClientId Is Not Null
					Select @Count=count(*) From #Loc_Cont_Tbl
					While @Count>=@IndCount
					Begin
						Select @ContactDetailId=ContactDetailId,@ContactId=ContactId,@CDEntityId=EntityId,@SyncClientId=DestId From #Loc_Cont_Tbl Where Id=@IndCount
						If Not Exists (Select Id From Common.ContactDetails Where ContactId=@ContactId And EntityId=@SyncClientId)
						Begin
							Set @New_ContctDtlId=NewId()
							Insert Into Common.ContactDetails (Id,ContactId,EntityId,EntityType,Designation,Communication,Matters,IsPrimaryContact,IsReminderReceipient,RecOrder,OtherDesignation,IsPinned,CursorShortCode,Status,UserCreated,CreatedDate,Remarks,DocId,DocType)
								Select @New_ContctDtlId,@ContactId,@SyncClientId,'Client',Designation,Communication,Matters,IsPrimaryContact,IsReminderReceipient,RecOrder,OtherDesignation,IsPinned,'WF',Status,@UserCreatedOrModified,@Getdate,Remarks,@CDEntityId,'Account' From Common.ContactDetails Where Id=@ContactDetailId
						End
						Else
						Begin
							Update A Set A.Designation=B.Designation,A.Communication=B.Communication,A.IsPrimaryContact=B.IsPrimaryContact,A.Matters=B.Matters,A.RecOrder=B.RecOrder,A.Status=B.Status,A.IsReminderReceipient=B.IsReminderReceipient,ModifiedBy=@UserCreatedOrModified,ModifiedDate=@GetDate,A.Remarks=B.Remarks From Common.ContactDetails As A
							Inner Join 
							(Select * From Common.ContactDetails Where EntityId=@CDEntityId And ContactId=@ContactId) As B On B.ContactId=A.ContactId
							Where A.ContactId=@ContactId And A.EntityId=@SyncClientId
						End
						Set @IndCount=@IndCount+1
					End
					Truncate Table #Loc_Cont_Tbl
				End 
				--ContactDetails From Client
				Begin
					Set @IndCount=1
					Set @Count=0
					Insert into #Loc_Cont_Tbl
					Select Distinct Cd.Id As ContactDetailId,CD.EntityType,CD.ContactId,CD.EntityId,A.SyncAccountId From Common.ContactDetails As CD
					Inner Join WorkFlow.Client As A On A.Id=CD.EntityId
					Inner Join Common.Contact As C On C.Id=CD.ContactId 
					Where A.CompanyId=@CompanyId And A.SyncAccountId Is Not Null
					Select @Count=count(*) From #Loc_Cont_Tbl
					While @Count>=@IndCount
					Begin
						Select @ContactDetailId=ContactDetailId,@ContactId=ContactId,@CDEntityId=EntityId,@SyncAccountId=DestId From #Loc_Cont_Tbl Where Id=@IndCount
						If Not Exists (Select Id From Common.ContactDetails Where ContactId=@ContactId And EntityId=@SyncAccountId)
						Begin
							Delete From Common.ContactDetails Where Id=@ContactDetailId
						End
						Set @IndCount=@IndCount+1
					End
					Truncate Table #Loc_Cont_Tbl
				End 
				--Addresses From Account
				Begin
					Set @IndCount=1
					Insert into #Loc_AdrsTbl
					Select Distinct Adrs.id As AddressId,Adrs.AddressBookId,Adrs.AddSectionType,Adrs.AddTypeId,A.SyncClientId From Common.Addresses As Adrs
					Inner join ClientCursor.Account As A On A.Id=Adrs.AddTypeId 
					Where A.CompanyId=@CompanyId And A.SyncClientId Is Not Null
					Select @AdrsCount=count(*) From #Loc_AdrsTbl
					While @AdrsCount>=@IndCount
					Begin
						Select @AddressId=AddressId,@AddressBookId=AddressBookId,@AddrsAddSecType=AddSectionType,@AdrsEntityId=AdrsEntityId,@AdrsSyncClientId=DestId From #Loc_AdrsTbl Where Id=@IndCount
						If Not Exists (Select Id From Common.Addresses Where Addsectiontype=@AddrsAddSecType And AddTypeId=@AdrsSyncClientId And AddressBookId=@AddressBookId/*And CompanyId=@CompanyId*/)
						Begin
							Insert Into Common.Addresses(Id,AddSectionType,AddType,AddTypeId,AddTypeIdInt,AddressBookId,Status,DocumentId,EntityId,ScreenName,IsCurrentAddress,CompanyId)
								Select NEWID(),AddSectionType,'Client',@AdrsSyncClientId,AddTypeIdInt,AddressBookId,Status,@AdrsEntityId,null,null,IsCurrentAddress,@CompanyId From Common.Addresses Where Id=@AddressId /*And CompanyId=@CompanyId*/
						End
						Set @IndCount=@IndCount+1
					End
					Truncate Table #Loc_AdrsTbl
				End 
				--Addresses From Client
				Begin
					Set @IndCount=1
					Insert into #Loc_AdrsTbl
					Select Distinct Adrs.id As AddressId,Adrs.AddressBookId,Adrs.AddSectionType,Adrs.AddTypeId,A.SyncAccountId From Common.Addresses As Adrs
					Inner join WorkFlow.Client As A On A.Id=Adrs.AddTypeId 
					Where A.CompanyId=@CompanyId And A.SyncAccountId Is Not Null
					Select @AdrsCount=count(*) From #Loc_AdrsTbl
					While @AdrsCount>=@IndCount
					Begin
						Select @AddressId=AddressId,@AddressBookId=AddressBookId,@AddrsAddSecType=AddSectionType,@AdrsEntityId=AdrsEntityId,@AdrsSyncAccountId=DestId From #Loc_AdrsTbl Where Id=@IndCount
						If Not Exists (Select Id From Common.Addresses Where Addsectiontype=@AddrsAddSecType And AddTypeId=@AdrsSyncAccountId And Addressbookid=@AddressBookId/*And CompanyId=@CompanyId*/)
						Begin
							Delete From Common.Addresses Where Id=@AddressId
						End
						Set @IndCount=@IndCount+1
					End
					Truncate Table #Loc_AdrsTbl
				End 
				--ContactDetail Addresses From Account 
				Begin
					Set @IndCount=1
					Insert into #Loc_AdrsTbl
					Select Distinct Adrs.id As AddressId,Adrs.AddressBookId,Adrs.AddSectionType,Adrs.AddTypeId,A.EntityId As AccountId From Common.Addresses As Adrs
					Inner join Common.ContactDetails As A On A.Id=Adrs.AddTypeId 
					Where A.EntityId In (Select Id From ClientCursor.Account Where CompanyId=@CompanyId And SyncClientId Is Not Null)
					Select @AdrsCount=count(*) From #Loc_AdrsTbl
					While @AdrsCount>=@IndCount
					Begin
						Select @AddressId=AddressId,@AddressBookId=AddressBookId,@AddrsAddSecType=AddSectionType,@AdrsEntityId=AdrsEntityId,@CntdtlEntityId=DestId From #Loc_AdrsTbl Where Id=@IndCount
						Select @ContactId=ContactId,@SyncAccountId=EntityId From Common.ContactDetails Where Id=@AdrsEntityId
						If @ContactId Is Not null And @SyncAccountId Is Not Null
						Begin
							Set @SyncClientId=(Select Id From WorkFlow.Client Where CompanyId=@CompanyId And SyncAccountId=@SyncAccountId And SyncAccountId Is Not Null)
							If @SyncClientId Is Not Null
							Begin
								Select @CntDtlDestId=Id From Common.ContactDetails Where EntityId=@SyncClientId And ContactId=@ContactId
								If Not Exists (Select Id From Common.Addresses Where Addsectiontype=@AddrsAddSecType And AddTypeId=@CntDtlDestId And AddressBookId=@AddressBookId/*And CompanyId=@CompanyId*/)
								Begin
									Insert Into Common.Addresses(Id,AddSectionType,AddType,AddTypeId,AddTypeIdInt,AddressBookId,Status,DocumentId,EntityId,ScreenName,IsCurrentAddress,CompanyId)
										Select NEWID(),AddSectionType,'ClientContactDetailId',@CntDtlDestId,AddTypeIdInt,AddressBookId,Status,@AdrsEntityId,null,null,IsCurrentAddress,@CompanyId From Common.Addresses Where Id=@AddressId /*And CompanyId=@CompanyId*/
								End
							End
						End
						Set @IndCount=@IndCount+1
					End
					Truncate Table #Loc_AdrsTbl
				End 
				--ContactDetail Addresses From Client
				Begin
					Set @IndCount=1
					Insert into #Loc_AdrsTbl
					Select Distinct Adrs.id As AddressId,Adrs.AddressBookId,Adrs.AddSectionType,Adrs.AddTypeId,A.EntityId From Common.Addresses As Adrs
					Inner join Common.ContactDetails As A On A.Id=Adrs.AddTypeId 
					Where A.EntityId In (Select Id From WorkFlow.Client Where CompanyId=@CompanyId And SyncAccountId Is Not Null)
					Select @AdrsCount=count(*) From #Loc_AdrsTbl
					While @AdrsCount>=@IndCount
					Begin
						Select @AddressId=AddressId,@AddressBookId=AddressBookId,@AddrsAddSecType=AddSectionType,@AdrsEntityId=AdrsEntityId,@CntdtlEntityId=DestId From #Loc_AdrsTbl Where Id=@IndCount
						Select @ContactId=ContactId,@SyncClientId=EntityId From Common.ContactDetails Where Id=@AdrsEntityId
						If @ContactId Is Not null And @SyncClientId Is Not Null
						Begin
							Set @SyncAccountId=(Select SyncAccountId From WorkFlow.Client Where CompanyId=@CompanyId And Id=@SyncClientId And SyncAccountId Is Not Null)
							If @SyncAccountId Is Not Null
							Begin
								Select @CntDtlDestId=Id From Common.ContactDetails Where EntityId=@SyncAccountId And ContactId=@ContactId
								If Not Exists (Select Id From Common.Addresses Where Addsectiontype=@AddrsAddSecType And AddTypeId=@CntDtlDestId And AddressBookId=@AddressBookId /*And CompanyId=@CompanyId*/)
								Begin
									Delete From Common.Addresses Where Id=@AddressId
								End
							End
						End
						Set @IndCount=@IndCount+1
					End
					Truncate Table #Loc_AdrsTbl
				End 
			End
			--If Bean Only Activated
			Else If Exists(Select Id From Common.CompanyModule Where CompanyId=@CompanyId And ModuleId in (Select Id from Common.ModuleMaster Where Name='Bean Cursor') And Status=1)
			Begin
				--Update existing records in Bean.Entiy table
				Update C  Set C.Name=E.Name,C.ClientTypeId=E.TypeId,C.IdtypeId=E.IdTypeId,C.ClientIdNo=E.IdNo,C.RecOrder=E.RecOrder,C.Remarks=E.Remarks,C.ModifiedBy=@UserCreatedOrModified,C.ModifiedDate=@GetDate,C.Communication=E.Communication,SyncEntitydate=@GetDate,SyncEntityStatus=@SyncStatusUpdateCompleted,
				C.ClientStatus=Case When E.Status=1 Then 'Active' When E.Status<>1 Then 'InActive' End,C.SyncEntityRemarks=null
				From WorkFlow.Client As C
				Inner Join Bean.Entity As E On E.Id=C.SyncEntityId
				Where C.CompanyId=@CompanyId And C.SyncEntityId Is Not Null

				-- Update syncentity details in Entity
				Update E Set E.SyncClientStatus=@SyncStatusUpdateCompleted,E.SyncClientdate=@GetDate,E.SyncClientId=E.Id,E.SyncClientRemarks=null
				From WorkFlow.Client As C 
				Inner Join Bean.Entity As E On E.Id=C.SyncEntityId
				Where C.CompanyId=@CompanyId And C.ModifiedDate=@GetDate
				/*
				-- Insert Into Bean.Entity Table From Client
				Insert Into WorkFlow.Client (Id,Name,ClientTypeId,IdtypeId,ClientIdNo,RecOrder,Remarks,UserCreated,CreatedDate,Communication,CompanyId,SyncEntityId,SyncEntityStatus,SyncEntitydate,SyncEntityRemarks,SystemRefNo,ClientStatus,Status)
					Select Newid(),Name,TypeId,IdTypeId,IdNo,RecOrder,Remarks,@UserCreatedOrModified,@GetDate,Communication,CompanyId,Id,@SyncStatusCompleted,@GetDate,null,CONCAT(@SystemRefnum,Right('0000000000'+Cast((@GeneratedNumber+ROW_NUMBER () Over (Order By Id) ) As varchar),Len(@GeneratedNumber))),Case When Status=1 Then 'Active' When Status<>1 Then 'Inactive' End,Status
					From Bean.Entity
					Where CompanyId=@CompanyId
					And Id Not In(Select SyncClientId From WorkFlow.Client Where CompanyId=@CompanyId And SyncClientId Is Not Null)
					And SyncAccountId Not In (Select SyncAccountId From WorkFlow.Client Where CompanyId=@CompanyId And SyncAccountId Is Not Null)
				-- Update syncEntity details in Client
				Update E Set E.SyncClientId=C.Id,E.SyncClientdate=@GetDate,E.SyncClientStatus=@SyncStatusCompleted,E.SyncClientRemarks=Null 
				From WorkFlow.Client As C
				Inner Join Bean.Entity As E On E.SyncClientId=C.Id
				Where C.CompanyId=@CompanyId And E.CreatedDate=@GetDate
				*/
				--ContactDetails From Entity
				Begin
					Set @IndCount=1
					Set @Count=0
					Insert into #Loc_Cont_Tbl
					Select Distinct Cd.Id As ContactDetailId,CD.EntityType,CD.ContactId,CD.EntityId,A.SyncClientId From Common.ContactDetails As CD
					Inner Join Bean.Entity As A On A.Id=CD.EntityId
					Inner Join Common.Contact As C On C.Id=CD.ContactId 
					Where A.CompanyId=@CompanyId And A.SyncClientId Is Not Null
					Select @Count=count(*) From #Loc_Cont_Tbl
					While @Count>=@IndCount
					Begin
						Select @ContactDetailId=ContactDetailId,@ContactId=ContactId,@CDEntityId=EntityId,@SyncClientId=DestId From #Loc_Cont_Tbl Where Id=@IndCount
						If Not Exists (Select Id From Common.ContactDetails Where ContactId=@ContactId And EntityId=@SyncClientId)
						Begin
							Set @New_ContctDtlId=NewId()
							Insert Into Common.ContactDetails (Id,ContactId,EntityId,EntityType,Designation,Communication,Matters,IsPrimaryContact,IsReminderReceipient,RecOrder,OtherDesignation,IsPinned,CursorShortCode,Status,UserCreated,CreatedDate,Remarks,DocId,DocType)
								Select @New_ContctDtlId,@ContactId,@SyncClientId,'Client',Designation,Communication,Matters,IsPrimaryContact,IsReminderReceipient,RecOrder,OtherDesignation,IsPinned,'WF',Status,@UserCreatedOrModified,@Getdate,Remarks,@CDEntityId,'Bean' From Common.ContactDetails Where Id=@ContactDetailId
						End
						Else
						Begin
							Update A Set A.Designation=B.Designation,A.Communication=B.Communication,A.IsPrimaryContact=B.IsPrimaryContact,A.Matters=B.Matters,A.RecOrder=B.RecOrder,A.Status=B.Status,A.IsReminderReceipient=B.IsReminderReceipient,ModifiedBy=@UserCreatedOrModified,ModifiedDate=@GetDate,A.Remarks=B.Remarks From Common.ContactDetails As A
							Inner Join 
							(Select * From Common.ContactDetails Where EntityId=@CDEntityId And ContactId=@ContactId) As B On B.ContactId=A.ContactId
							Where A.ContactId=@ContactId And A.EntityId=@SyncClientId
						End
						Set @IndCount=@IndCount+1
					End
					Truncate Table #Loc_Cont_Tbl
				End 
				--ContactDetails From Client
				Begin
					Set @IndCount=1
					Set @Count=0
					Insert into #Loc_Cont_Tbl
					Select Distinct Cd.Id As ContactDetailId,CD.EntityType,CD.ContactId,CD.EntityId,A.SyncEntityId From Common.ContactDetails As CD
					Inner Join WorkFlow.Client As A On A.Id=CD.EntityId
					Inner Join Common.Contact As C On C.Id=CD.ContactId 
					Where A.CompanyId=@CompanyId And A.SyncEntityId Is Not Null
					Select @Count=count(*) From #Loc_Cont_Tbl
					While @Count>=@IndCount
					Begin
						Select @ContactDetailId=ContactDetailId,@ContactId=ContactId,@CDEntityId=EntityId,@SyncEntityId=DestId From #Loc_Cont_Tbl Where Id=@IndCount
						If Not Exists (Select Id From Common.ContactDetails Where ContactId=@ContactId And EntityId=@SyncEntityId)
						Begin
							Delete From Common.ContactDetails Where Id=@ContactDetailId
						End
						Set @IndCount=@IndCount+1
					End
					Truncate Table #Loc_Cont_Tbl
				End 
				--Addresses From Entity
				Begin
					Set @IndCount=1
					Insert into #Loc_AdrsTbl
					Select Distinct Adrs.id As AddressId,Adrs.AddressBookId,Adrs.AddSectionType,Adrs.AddTypeId,A.SyncClientId From Common.Addresses As Adrs
					Inner join Bean.Entity As A On A.Id=Adrs.AddTypeId 
					Where A.CompanyId=@CompanyId And A.SyncClientId Is Not Null
					Select @AdrsCount=count(*) From #Loc_AdrsTbl
					While @AdrsCount>=@IndCount
					Begin
						Select @AddressId=AddressId,@AddressBookId=AddressBookId,@AddrsAddSecType=AddSectionType,@AdrsEntityId=AdrsEntityId,@AdrsSyncClientId=DestId From #Loc_AdrsTbl Where Id=@IndCount
						If Not Exists (Select Id From Common.Addresses Where Addsectiontype=@AddrsAddSecType And AddTypeId=@AdrsSyncEntityId And AddressBookId=@AddressBookId/*And CompanyId=@CompanyId*/)
						Begin
							Insert Into Common.Addresses(Id,AddSectionType,AddType,AddTypeId,AddTypeIdInt,AddressBookId,Status,DocumentId,EntityId,ScreenName,IsCurrentAddress,CompanyId)
								Select NEWID(),AddSectionType,'Client',@AdrsSyncClientId,AddTypeIdInt,AddressBookId,Status,@AdrsEntityId,null,null,IsCurrentAddress,@CompanyId From Common.Addresses Where Id=@AddressId /*And CompanyId=@CompanyId*/
						End
						Set @IndCount=@IndCount+1
					End
					Truncate Table #Loc_AdrsTbl
				End 
				--Addresses From Client
				Begin
					Set @IndCount=1
					Insert into #Loc_AdrsTbl
					Select Distinct Adrs.id As AddressId,Adrs.AddressBookId,Adrs.AddSectionType,Adrs.AddTypeId,A.SyncEntityId From Common.Addresses As Adrs
					Inner join WorkFlow.Client As A On A.Id=Adrs.AddTypeId 
					Where A.CompanyId=@CompanyId And A.SyncEntityId Is Not Null
					Select @AdrsCount=count(*) From #Loc_AdrsTbl
					While @AdrsCount>=@IndCount
					Begin
						Select @AddressId=AddressId,@AddressBookId=AddressBookId,@AddrsAddSecType=AddSectionType,@AdrsEntityId=AdrsEntityId,@AdrsSyncEntityId=DestId From #Loc_AdrsTbl Where Id=@IndCount
						If Not Exists (Select Id From Common.Addresses Where Addsectiontype=@AddrsAddSecType And AddTypeId=@AdrsSyncEntityId And Addressbookid=@AddressBookId/*And CompanyId=@CompanyId*/)
						Begin
							Delete From Common.Addresses Where Id=@AddressId
						End
						Set @IndCount=@IndCount+1
					End
					Truncate Table #Loc_AdrsTbl
				End 
				--ContactDetail Addresses From Entity
				Begin
					Set @IndCount=1
					Insert into #Loc_AdrsTbl
					Select Distinct Adrs.id As AddressId,Adrs.AddressBookId,Adrs.AddSectionType,Adrs.AddTypeId,A.EntityId As EntityId From Common.Addresses As Adrs
					Inner join Common.ContactDetails As A On A.Id=Adrs.AddTypeId 
					Where A.EntityId In (Select Id From Bean.Entity Where CompanyId=@CompanyId And SyncClientId Is Not Null)
					Select @AdrsCount=count(*) From #Loc_AdrsTbl
					While @AdrsCount>=@IndCount
					Begin
						Select @AddressId=AddressId,@AddressBookId=AddressBookId,@AddrsAddSecType=AddSectionType,@AdrsEntityId=AdrsEntityId,@CntdtlEntityId=DestId From #Loc_AdrsTbl Where Id=@IndCount
						Select @ContactId=ContactId,@SyncEntityId=EntityId From Common.ContactDetails Where Id=@AdrsEntityId
						If @ContactId Is Not null And @SyncEntityId Is Not Null
						Begin
							Set @SyncClientId=(Select Id From WorkFlow.Client Where CompanyId=@CompanyId And SyncEntityId=@SyncEntityId And @SyncEntityId Is Not Null)
							If @SyncClientId Is Not Null
							Begin
								Select @CntDtlDestId=Id From Common.ContactDetails Where EntityId=@SyncClientId And ContactId=@ContactId
								If Not Exists (Select Id From Common.Addresses Where Addsectiontype=@AddrsAddSecType And AddTypeId=@CntDtlDestId And AddressBookId=@AddressBookId/*And CompanyId=@CompanyId*/)
								Begin
									Insert Into Common.Addresses(Id,AddSectionType,AddType,AddTypeId,AddTypeIdInt,AddressBookId,Status,DocumentId,EntityId,ScreenName,IsCurrentAddress,CompanyId)
										Select NEWID(),AddSectionType,'ClientContactDetailId',@CntDtlDestId,AddTypeIdInt,AddressBookId,Status,@AdrsEntityId,null,null,IsCurrentAddress,@CompanyId From Common.Addresses Where Id=@AddressId /*And CompanyId=@CompanyId*/
								End
							End
						End
						Set @IndCount=@IndCount+1
					End
					Truncate Table #Loc_AdrsTbl
				End 
				--ContactDetail Addresses From Client
				Begin
					Set @IndCount=1
					Insert into #Loc_AdrsTbl
					Select Distinct Adrs.id As AddressId,Adrs.AddressBookId,Adrs.AddSectionType,Adrs.AddTypeId,A.EntityId As ClientId From Common.Addresses As Adrs
					Inner join Common.ContactDetails As A On A.Id=Adrs.AddTypeId 
					Where A.EntityId In (Select Id From WorkFlow.Client Where CompanyId=@CompanyId And SyncEntityId Is Not Null)
					Select @AdrsCount=count(*) From #Loc_AdrsTbl
					While @AdrsCount>=@IndCount
					Begin
						Select @AddressId=AddressId,@AddressBookId=AddressBookId,@AddrsAddSecType=AddSectionType,@AdrsEntityId=AdrsEntityId,@CntdtlEntityId=DestId From #Loc_AdrsTbl Where Id=@IndCount
						Select @ContactId=ContactId,@SyncClientId=EntityId From Common.ContactDetails Where Id=@AdrsEntityId
						If @ContactId Is Not null And @SyncEntityId Is Not Null
						Begin
							Set @SyncEntityId=(Select Id From Bean.Entity Where CompanyId=@CompanyId And SyncClientId=@SyncClientId And SyncClientId Is Not Null)
							If @SyncEntityId Is Not Null
							Begin
								Select @CntDtlDestId=Id From Common.ContactDetails Where EntityId=@SyncClientId And ContactId=@ContactId
								If Not Exists (Select Id From Common.Addresses Where Addsectiontype=@AddrsAddSecType And AddTypeId=@CntDtlDestId And AddressBookId=@AddressBookId /*And CompanyId=@CompanyId*/)
								Begin
									Delete From Common.Addresses Where Id=@AddressId
								End
							End
						End
						Set @IndCount=@IndCount+1
					End
					Truncate Table #Loc_AdrsTbl
				End 
			End
		End
		-- ClientCursor--
		If @CursorName='Client Cursor'
		Begin
			--If Workflow Is Activated
			If Exists(Select Id From Common.CompanyModule Where CompanyId=@CompanyId And ModuleId in (Select Id from Common.ModuleMaster Where Name='Workflow Cursor') And Status=1)
			Begin
				-- Update Existing data Workflow.Client & CC.Account
				Update A Set A.AccountTypeId=C.ClientTypeId,A.AccountIdTypeId=C.IdtypeId,A.AccountIdNo=C.ClientIdNo,A.TermsOfPaymentId=C.TermsOfPaymentId,A.Industry=C.Industry,A.Source=C.Source,A.SourceId=C.SourceId,A.SourceName=C.SourceName,A.SourceRemarks=C.SourceRemarks,A.IncorporationDate=C.IncorporationDate,A.ClientId=C.Id, 
						A.FinancialYearEnd=C.FinancialYearEnd,A.CountryOfIncorporation=C.CountryOfIncorporation,A.AccountStatus=C.ClientStatus,A.PrincipalActivities=C.PrincipalActivities,A.RecOrder=C.RecOrder,A.Remarks=C.Remarks,A.ModifiedBy=@UserCreatedOrModified,A.ModifiedDate=@GetDate,A.Version=C.Version,A.Status=C.Status,A.Communication=C.Communication,A.SyncClientStatus=@SyncStatusUpdateCompleted,A.SyncClientDate=@GetDate,A.SyncClientRemarks=null
				From ClientCursor.Account As A
				Inner Join Workflow.Client As C On C.SyncAccountId=A.Id
				Where A.CompanyId=@CompanyId And C.SyncAccountId Is Not Null 
				--Update SyncClient Detail in Account
				Update C Set C.SyncAccountStatus=@SyncStatusUpdateCompleted,C.SyncAccountDate=@GetDate,C.SyncAccountRemarks=Null From ClientCursor.Account As A
				Inner Join WorkFlow.Client As C On C.Id=A.SyncClientId
				Where A.CompanyId=@CompanyId
				--Generate autonumber
				Set @GeneratedNumber=(Select GeneratedNumber From Common.AutoNumber Where CompanyId=@CompanyId And EntityType='Account' And ModuleMasterId=(Select Id From Common.ModuleMaster Where Name='Client Cursor'))
				Set @SystemRefnum=(Select Top(1) SystemRefNo From ClientCursor.Account Where CompanyId=@CompanyId And SystemRefNo Is not null Order By CreatedDate Desc)
				Set @SystemRefnum=Reverse(SUBSTRING(Reverse(@SystemRefnum),PATINDEX('%[0-9][^0-9]%', Reverse(@SystemRefnum))+1,DATALENGTH(@SystemRefnum)))
				--Insert into CC.Account from WF.Client
				Insert Into ClientCursor.Account (Id,Name,CompanyId,AccountTypeId,AccountIdTypeId,AccountIdNo,TermsOfPaymentId,Industry,Source,SourceId,SourceName,SourceRemarks,IncorporationDate,FinancialYearEnd,CountryOfIncorporation,AccountStatus,PrincipalActivities,UserCreated,CreatedDate,Version,Status,SystemRefNo,SyncClientId,SyncClientRemarks,SyncClientStatus,SyncClientDate)
					Select NEWID(),Name,CompanyId,ClientIdTypeId,IdtypeId,ClientIdNo,TermsOfPaymentId,Industry,Source,SourceId,SourceName,SourceRemarks,IncorporationDate,FinancialYearEnd,CountryOfIncorporation,ClientStatus,PrincipalActivities,@UserCreatedOrModified,@GetDate,Version,Status,CONCAT(@SystemRefnum,Right('0000000000'+Cast((@GeneratedNumber+ROW_NUMBER () Over (Order By Id) ) As varchar),Len(@GeneratedNumber))),Id,Null,@SyncStatusCompleted,@GetDate
					From WorkFlow.Client
					Where CompanyId=@CompanyId 
					And Id not in (Select SyncClientId from ClientCursor.Account Where CompanyId=@CompanyId And SyncClientId Is Not Null)
					And SyncEntityId Not In (Select Id From Bean.Entity Where CompanyId=@CompanyId)
				--Update Syncaccount  data 
				Update C Set C.SyncAccountId=A.Id,C.SyncAccountStatus=@SyncStatusCompleted,C.SyncAccountDate=@GetDate ,C.SyncAccountRemarks=null From WorkFlow.Client As C
				Inner Join ClientCursor.Account As A On A.SyncClientId=C.Id
				Where C.CompanyId=@CompanyId And A.CreatedDate=@GetDate
				--ContactDetails From Client
				Begin
					Set @IndCount=1
					Set @Count=0
					Insert into #Loc_Cont_Tbl
					Select Distinct Cd.Id As ContactDetailId,CD.EntityType,CD.ContactId,CD.EntityId,A.SyncAccountId From Common.ContactDetails As CD
					Inner Join WorkFlow.Client As A On A.Id=CD.EntityId
					Inner Join Common.Contact As C On C.Id=CD.ContactId 
					Where A.CompanyId=@CompanyId And A.SyncAccountId Is Not Null
					Select @Count=count(*) From #Loc_Cont_Tbl
					While @Count>=@IndCount
					Begin
						Select @ContactDetailId=ContactDetailId,@ContactId=ContactId,@CDEntityId=EntityId,@SyncAccountId=DestId From #Loc_Cont_Tbl Where Id=@IndCount
						If Not Exists (Select Id From Common.ContactDetails Where ContactId=@ContactId And EntityId=@SyncAccountId)
						Begin
							Set @New_ContctDtlId=NewId()
							Insert Into Common.ContactDetails (Id,ContactId,EntityId,EntityType,Designation,Communication,Matters,IsPrimaryContact,IsReminderReceipient,RecOrder,OtherDesignation,IsPinned,CursorShortCode,Status,UserCreated,CreatedDate,Remarks,DocId,DocType)
								Select @New_ContctDtlId,@ContactId,@SyncAccountId,'Account',Designation,Communication,Matters,IsPrimaryContact,IsReminderReceipient,RecOrder,OtherDesignation,IsPinned,'CC',Status,@UserCreatedOrModified,@Getdate,Remarks,@CDEntityId,'Client' From Common.ContactDetails Where Id=@ContactDetailId
						End
						Else
						Begin
							Update A Set A.Designation=B.Designation,A.Communication=B.Communication,A.IsPrimaryContact=B.IsPrimaryContact,A.Matters=B.Matters,A.RecOrder=B.RecOrder,A.Status=B.Status,A.IsReminderReceipient=B.IsReminderReceipient,ModifiedBy=@UserCreatedOrModified,ModifiedDate=@GetDate,A.Remarks=B.Remarks From Common.ContactDetails As A
							Inner Join 
							(Select * From Common.ContactDetails Where EntityId=@CDEntityId And ContactId=@ContactId) As B On B.ContactId=A.ContactId
							Where A.ContactId=@ContactId And A.EntityId=@SyncAccountId
						End
						Set @IndCount=@IndCount+1
					End
					Truncate Table #Loc_Cont_Tbl
				End 
				--ContactDetails From Account
				Begin
					Set @IndCount=1
					Set @Count=0
					Insert into #Loc_Cont_Tbl
					Select Distinct Cd.Id As ContactDetailId,CD.EntityType,CD.ContactId,CD.EntityId,A.SyncClientId From Common.ContactDetails As CD
					Inner Join ClientCursor.Account As A On A.Id=CD.EntityId
					Inner Join Common.Contact As C On C.Id=CD.ContactId 
					Where A.CompanyId=@CompanyId And A.SyncClientId Is Not Null
					Select @Count=count(*) From #Loc_Cont_Tbl
					While @Count>=@IndCount
					Begin
						Select @ContactDetailId=ContactDetailId,@ContactId=ContactId,@CDEntityId=EntityId,@SyncClientId=DestId From #Loc_Cont_Tbl Where Id=@IndCount
						If Not Exists (Select Id From Common.ContactDetails Where ContactId=@ContactId And EntityId=@SyncClientId)
						Begin
							Delete From Common.ContactDetails Where Id=@ContactDetailId
						End
						Set @IndCount=@IndCount+1
					End
					Truncate Table #Loc_Cont_Tbl
				End 
				--Addresses From Client
				Begin
					Set @IndCount=1
					Insert into #Loc_AdrsTbl
					Select Distinct Adrs.id As AddressId,Adrs.AddressBookId,Adrs.AddSectionType,Adrs.AddTypeId,A.SyncAccountId From Common.Addresses As Adrs
					Inner join WorkFlow.Client As A On A.Id=Adrs.AddTypeId 
					Where A.CompanyId=@CompanyId And A.SyncAccountId Is Not Null
					Select @AdrsCount=count(*) From #Loc_AdrsTbl
					While @AdrsCount>=@IndCount
					Begin
						Select @AddressId=AddressId,@AddressBookId=AddressBookId,@AddrsAddSecType=AddSectionType,@AdrsEntityId=AdrsEntityId,@AdrsSyncAccountId=DestId From #Loc_AdrsTbl Where Id=@IndCount
						If Not Exists (Select Id From Common.Addresses Where Addsectiontype=@AddrsAddSecType And AddTypeId=@AdrsSyncAccountId And AddressBookId=@AddressBookId /*And CompanyId=@CompanyId*/)
						Begin
							Insert Into Common.Addresses(Id,AddSectionType,AddType,AddTypeId,AddTypeIdInt,AddressBookId,Status,DocumentId,EntityId,ScreenName,IsCurrentAddress,CompanyId)
								Select NEWID(),AddSectionType,'Account',@AdrsSyncAccountId,AddTypeIdInt,AddressBookId,Status,@AdrsEntityId,null,null,IsCurrentAddress,@CompanyId From Common.Addresses Where Id=@AddressId /*And CompanyId=@CompanyId*/
						End
						Set @IndCount=@IndCount+1
					End
					Truncate Table #Loc_AdrsTbl
				End 
				--Addresses From Account
				Begin
					Set @IndCount=1
					Insert into #Loc_AdrsTbl
					Select Distinct Adrs.id As AddressId,Adrs.AddressBookId,Adrs.AddSectionType,Adrs.AddTypeId,A.SyncClientId From Common.Addresses As Adrs
					Inner join ClientCursor.Account As A On A.Id=Adrs.AddTypeId 
					Where A.CompanyId=@CompanyId And A.SyncClientId Is Not Null
					Select @AdrsCount=count(*) From #Loc_AdrsTbl
					While @AdrsCount>=@IndCount
					Begin
						Select @AddressId=AddressId,@AddressBookId=AddressBookId,@AddrsAddSecType=AddSectionType,@AdrsEntityId=AdrsEntityId,@AdrsSyncClientId=DestId From #Loc_AdrsTbl Where Id=@IndCount
						If Not Exists (Select Id From Common.Addresses Where Addsectiontype=@AddrsAddSecType And AddTypeId=@AdrsSyncClientId And Addressbookid=@AddressBookId/*And CompanyId=@CompanyId*/)
						Begin
							Delete From Common.Addresses Where Id=@AddressId
						End
						Set @IndCount=@IndCount+1
					End
					Truncate Table #Loc_AdrsTbl
				End 
				--ContactDetail Addresses From Client
				Begin
					Set @IndCount=1
					Insert into #Loc_AdrsTbl
					Select Distinct Adrs.id As AddressId,Adrs.AddressBookId,Adrs.AddSectionType,Adrs.AddTypeId,A.EntityId As EntityId From Common.Addresses As Adrs
					Inner join Common.ContactDetails As A On A.Id=Adrs.AddTypeId 
					Where A.EntityId In (Select Id From WorkFlow.Client Where CompanyId=@CompanyId And SyncAccountId Is Not Null)
					Select @AdrsCount=count(*) From #Loc_AdrsTbl
					While @AdrsCount>=@IndCount
					Begin
						Select @AddressId=AddressId,@AddressBookId=AddressBookId,@AddrsAddSecType=AddSectionType,@AdrsEntityId=AdrsEntityId,@CntdtlEntityId=DestId From #Loc_AdrsTbl Where Id=@IndCount
						Select @ContactId=ContactId,@SyncClientId=EntityId From Common.ContactDetails Where Id=@AdrsEntityId
						If @ContactId Is Not null And @SyncClientId Is Not Null
						Begin
							Set @SyncAccountId=(Select Id From ClientCursor.Account Where CompanyId=@CompanyId And SyncClientId=@SyncClientId And SyncClientId Is Not Null)
							If @SyncAccountId Is Not Null
							Begin
								Select @CntDtlDestId=Id From Common.ContactDetails Where EntityId=@SyncClientId And ContactId=@ContactId
								If Not Exists (Select Id From Common.Addresses Where Addsectiontype=@AddrsAddSecType And AddTypeId=@CntDtlDestId And AddressBookId=@AddressBookId/*And CompanyId=@CompanyId*/)
								Begin
									Insert Into Common.Addresses(Id,AddSectionType,AddType,AddTypeId,AddTypeIdInt,AddressBookId,Status,DocumentId,EntityId,ScreenName,IsCurrentAddress,CompanyId)
										Select NEWID(),AddSectionType,'AccountContactDetailId',@CntDtlDestId,AddTypeIdInt,AddressBookId,Status,@AdrsEntityId,null,null,IsCurrentAddress,@CompanyId From Common.Addresses Where Id=@AddressId /*And CompanyId=@CompanyId*/
								End
							End
						End
						Set @IndCount=@IndCount+1
					End
					Truncate Table #Loc_AdrsTbl
				End 
				--ContactDetail Addresses From Account
				Begin
					Set @IndCount=1
					Insert into #Loc_AdrsTbl
					Select Distinct Adrs.id As AddressId,Adrs.AddressBookId,Adrs.AddSectionType,Adrs.AddTypeId,A.EntityId From Common.Addresses As Adrs
					Inner join Common.ContactDetails As A On A.Id=Adrs.AddTypeId 
					Where A.EntityId In (Select Id From ClientCursor.Account Where CompanyId=@CompanyId And SyncClientId Is Not Null)
					Select @AdrsCount=count(*) From #Loc_AdrsTbl
					While @AdrsCount>=@IndCount
					Begin
						Select @AddressId=AddressId,@AddressBookId=AddressBookId,@AddrsAddSecType=AddSectionType,@AdrsEntityId=AdrsEntityId,@CntdtlEntityId=DestId From #Loc_AdrsTbl Where Id=@IndCount
						Select @ContactId=ContactId,@SyncAccountId=EntityId From Common.ContactDetails Where Id=@AdrsEntityId
						If @ContactId Is Not null And @SyncAccountId Is Not Null
						Begin
							Set @SyncClientId=(Select Id From WorkFlow.Client Where CompanyId=@CompanyId And SyncAccountId=@SyncAccountId And SyncAccountId Is Not Null)
							If @SyncClientId Is Not Null
							Begin
								Select @CntDtlDestId=Id From Common.ContactDetails Where EntityId=@SyncClientId And ContactId=@ContactId
								If Not Exists (Select Id From Common.Addresses Where Addsectiontype=@AddrsAddSecType And AddTypeId=@CntDtlDestId And AddressBookId=@AddressBookId /*And CompanyId=@CompanyId*/)
								Begin
									Delete From Common.Addresses Where Id=@AddressId
								End
							End
						End
						Set @IndCount=@IndCount+1
					End
					Truncate Table #Loc_AdrsTbl
				End
				--If Bean Also Activated
				If Exists(Select Id From Common.CompanyModule Where CompanyId=@CompanyId And ModuleId in (Select Id from Common.ModuleMaster Where Name='Bean Cursor') And Status=1)
				Begin
					Update E Set E.SyncAccountId=C.SyncAccountId,E.SyncAccountDate=@GetDate,E.SyncAccountRemarks=Null,E.SyncAccountStatus=@SyncStatusCompleted From Bean.Entity As E
					Inner Join WorkFlow.Client As C On C.SyncEntityId=E.Id
					Where C.CompanyId=@CompanyId And C.SyncEntityId Is Not Null

					Update A Set A.SyncEntityId=C.SyncEntityId,A.SyncEntityDate=@GetDate,A.SyncEntityRemarks=Null,A.SyncEntityStatus=@SyncStatusCompleted From ClientCursor.Account As A
					Inner Join WorkFlow.Client As C On C.SyncAccountId=A.Id
					Where C.CompanyId=@CompanyId And C.SyncAccountId Is Not Null
				End
			End
			--If Bean Only Activated
			Else If Exists(Select Id From Common.CompanyModule Where CompanyId=@CompanyId And ModuleId in (Select Id from Common.ModuleMaster Where Name='Bean Cursor') And Status=1)
			Begin
				--Update clientcursor.account & Entity tables
				Update A  Set A.Name=E.Name,A.AccountTypeId=E.TypeId,A.AccountIdTypeId=E.IdTypeId,AccountIdNo=E.IdNo,A.RecOrder=E.RecOrder,A.Remarks=E.Remarks,A.ModifiedBy=@UserCreatedOrModified,A.ModifiedDate=@GetDate,A.Communication=E.Communication,A.SyncEntityDate=@GetDate,A.SyncEntityStatus=@SyncStatusUpdateCompleted,SyncEntityRemarks=null,A.AccountStatus=Case When E.Status=1 Then 'Active' When E.Status<>1 Then 'Inactive' End
				From ClientCursor.Account As A
				Inner Join Bean.Entity As E On E.Id=A.SyncEntityId
				Where A.CompanyId=@CompanyId 
				--Update Syncdetails in Account table
				Update E Set E.SyncAccountDate=@GetDate,E.SyncAccountStatus=@SyncStatusUpdateCompleted,E.SyncAccountRemarks=null From Bean.Entity As E
				Inner Join ClientCursor.Account As A On A.SyncEntityId=E.Id 
				Where A.CompanyId=@CompanyId  And A.ModifiedDate=@GetDate
				/*
				-- Inert Into Account table
				Insert Into ClientCursor.Account(Id,Name,AccountTypeId,AccountIdTypeId,AccountIdNo,RecOrder,Remarks,UserCreated,CreatedDate,Communication,CompanyId,SyncEntityId,SyncEntityStatus,SyncEntityDate,SyncEntityRemarks,SystemRefNo,AccountStatus)
					Select NEWID(),Name,TypeId,IdTypeId,IdNo,RecOrder,Remarks,@UserCreatedOrModified,@GetDate,Communication,CompanyId,Id,@SyncStatusCompleted,@GetDate,null,CONCAT(@SystemRefnum,Right('0000000000'+Cast((@GeneratedNumber+ROW_NUMBER () Over (Order By Id) ) As varchar),Len(@GeneratedNumber))),Case When Status=1 Then 'Active' When Status<>1 Then 'Inactive' End
					From Bean.Entity 
					Where CompanyId=@CompanyId And IsCustomer=1
					And Id Not In (Select SyncAccountId From ClientCursor.Account Where CompanyId=@CompanyId And SyncAccountId Is Not null)
					And SyncClientId Not In (Select SyncClientId From ClientCursor.Account Where SyncClientId Is Not null)
				--Update syncdetails in Account table
				Update E Set E.SyncAccountDate=@GetDate,E.SyncAccountStatus=@SyncStatusCompleted,E.SyncAccountRemarks=null From Bean.Entity As E
				Inner Join ClientCursor.Account As A On A.SyncEntityId=E.Id 
				Where A.CompanyId=@CompanyId  And A.CreatedDate=@GetDate
				*/
				--ContactDetails From Entity
				Begin
					Set @IndCount=1
					Set @Count=0
					Insert into #Loc_Cont_Tbl
					Select Distinct Cd.Id As ContactDetailId,CD.EntityType,CD.ContactId,CD.EntityId,A.SyncAccountId From Common.ContactDetails As CD
					Inner Join Bean.Entity As A On A.Id=CD.EntityId
					Inner Join Common.Contact As C On C.Id=CD.ContactId 
					Where A.CompanyId=@CompanyId And A.SyncAccountId Is Not Null
					Select @Count=count(*) From #Loc_Cont_Tbl
					While @Count>=@IndCount
					Begin
						Select @ContactDetailId=ContactDetailId,@ContactId=ContactId,@CDEntityId=EntityId,@SyncAccountId=DestId From #Loc_Cont_Tbl Where Id=@IndCount
						If Not Exists (Select Id From Common.ContactDetails Where ContactId=@ContactId And EntityId=@SyncAccountId)
						Begin
							Set @New_ContctDtlId=NewId()
							Insert Into Common.ContactDetails (Id,ContactId,EntityId,EntityType,Designation,Communication,Matters,IsPrimaryContact,IsReminderReceipient,RecOrder,OtherDesignation,IsPinned,CursorShortCode,Status,UserCreated,CreatedDate,Remarks,DocId,DocType)
								Select @New_ContctDtlId,@ContactId,@SyncAccountId,'Account',Designation,Communication,Matters,IsPrimaryContact,IsReminderReceipient,RecOrder,OtherDesignation,IsPinned,'CC',Status,@UserCreatedOrModified,@Getdate,Remarks,@CDEntityId,'Bean' From Common.ContactDetails Where Id=@ContactDetailId
						End
						Else
						Begin
							Update A Set A.Designation=B.Designation,A.Communication=B.Communication,A.IsPrimaryContact=B.IsPrimaryContact,A.Matters=B.Matters,A.RecOrder=B.RecOrder,A.Status=B.Status,A.IsReminderReceipient=B.IsReminderReceipient,ModifiedBy=@UserCreatedOrModified,ModifiedDate=@GetDate,A.Remarks=B.Remarks From Common.ContactDetails As A
							Inner Join 
							(Select * From Common.ContactDetails Where EntityId=@CDEntityId And ContactId=@ContactId) As B On B.ContactId=A.ContactId
							Where A.ContactId=@ContactId And A.EntityId=@SyncAccountId
						End
						Set @IndCount=@IndCount+1
					End
					Truncate Table #Loc_Cont_Tbl
				End 
				--ContactDetails From Account
				Begin
					Set @IndCount=1
					Set @Count=0
					Insert into #Loc_Cont_Tbl
					Select Distinct Cd.Id As ContactDetailId,CD.EntityType,CD.ContactId,CD.EntityId,A.SyncEntityId From Common.ContactDetails As CD
					Inner Join ClientCursor.Account As A On A.Id=CD.EntityId
					Inner Join Common.Contact As C On C.Id=CD.ContactId 
					Where A.CompanyId=@CompanyId And A.SyncEntityId Is Not Null
					Select @Count=count(*) From #Loc_Cont_Tbl
					While @Count>=@IndCount
					Begin
						Select @ContactDetailId=ContactDetailId,@ContactId=ContactId,@CDEntityId=EntityId,@SyncEntityId=DestId From #Loc_Cont_Tbl Where Id=@IndCount
						If Not Exists (Select Id From Common.ContactDetails Where ContactId=@ContactId And EntityId=@SyncEntityId)
						Begin
							Delete From Common.ContactDetails Where Id=@ContactDetailId
						End
						Set @IndCount=@IndCount+1
					End
					Truncate Table #Loc_Cont_Tbl
				End 
				--Addresses From Entity
				Begin
					Set @IndCount=1
					Insert into #Loc_AdrsTbl
					Select Distinct Adrs.id As AddressId,Adrs.AddressBookId,Adrs.AddSectionType,Adrs.AddTypeId,A.SyncAccountId From Common.Addresses As Adrs
					Inner join Bean.Entity As A On A.Id=Adrs.AddTypeId 
					Where A.CompanyId=@CompanyId And A.SyncAccountId Is Not Null
					Select @AdrsCount=count(*) From #Loc_AdrsTbl
					While @AdrsCount>=@IndCount
					Begin
						Select @AddressId=AddressId,@AddressBookId=AddressBookId,@AddrsAddSecType=AddSectionType,@AdrsEntityId=AdrsEntityId,@AdrsSyncAccountId=DestId From #Loc_AdrsTbl Where Id=@IndCount
						If Not Exists (Select Id From Common.Addresses Where Addsectiontype=@AddrsAddSecType And AddTypeId=@AdrsSyncAccountId And AddressBookId=@AddressBookId/*And CompanyId=@CompanyId*/)
						Begin
							Insert Into Common.Addresses(Id,AddSectionType,AddType,AddTypeId,AddTypeIdInt,AddressBookId,Status,DocumentId,EntityId,ScreenName,IsCurrentAddress,CompanyId)
								Select NEWID(),AddSectionType,'Account',@AdrsSyncAccountId,AddTypeIdInt,AddressBookId,Status,@AdrsEntityId,null,null,IsCurrentAddress,@CompanyId From Common.Addresses Where Id=@AddressId /*And CompanyId=@CompanyId*/
						End
						Set @IndCount=@IndCount+1
					End
					Truncate Table #Loc_AdrsTbl
				End 
				--Addresses From Account
				Begin
					Set @IndCount=1
					Insert into #Loc_AdrsTbl
					Select Distinct Adrs.id As AddressId,Adrs.AddressBookId,Adrs.AddSectionType,Adrs.AddTypeId,A.SyncEntityId From Common.Addresses As Adrs
					Inner join ClientCursor.Account As A On A.Id=Adrs.AddTypeId 
					Where A.CompanyId=@CompanyId And A.SyncEntityId Is Not Null
					Select @AdrsCount=count(*) From #Loc_AdrsTbl
					While @AdrsCount>=@IndCount
					Begin
						Select @AddressId=AddressId,@AddressBookId=AddressBookId,@AddrsAddSecType=AddSectionType,@AdrsEntityId=AdrsEntityId,@AdrsSyncEntityId=DestId From #Loc_AdrsTbl Where Id=@IndCount
						If Not Exists (Select Id From Common.Addresses Where Addsectiontype=@AddrsAddSecType And AddTypeId=@AdrsSyncEntityId And Addressbookid=@AddressBookId/*And CompanyId=@CompanyId*/)
						Begin
							Delete From Common.Addresses Where Id=@AddressId
						End
						Set @IndCount=@IndCount+1
					End
					Truncate Table #Loc_AdrsTbl
				End 
				--ContactDetail Addresses From Entity
				Begin
					Set @IndCount=1
					Insert into #Loc_AdrsTbl
					Select Distinct Adrs.id As AddressId,Adrs.AddressBookId,Adrs.AddSectionType,Adrs.AddTypeId,A.EntityId As EntityId From Common.Addresses As Adrs
					Inner join Common.ContactDetails As A On A.Id=Adrs.AddTypeId 
					Where A.EntityId In (Select Id From Bean.Entity Where CompanyId=@CompanyId And SyncClientId Is Not Null)
					Select @AdrsCount=count(*) From #Loc_AdrsTbl
					While @AdrsCount>=@IndCount
					Begin
						Select @AddressId=AddressId,@AddressBookId=AddressBookId,@AddrsAddSecType=AddSectionType,@AdrsEntityId=AdrsEntityId,@CntdtlEntityId=DestId From #Loc_AdrsTbl Where Id=@IndCount
						Select @ContactId=ContactId,@SyncEntityId=EntityId From Common.ContactDetails Where Id=@AdrsEntityId
						If @ContactId Is Not null And @SyncEntityId Is Not Null
						Begin
							Set @SyncAccountId=(Select Id From ClientCursor.Account Where CompanyId=@CompanyId And SyncEntityId=@SyncEntityId And @SyncEntityId Is Not Null)
							If @SyncAccountId Is Not Null
							Begin
								Select @CntDtlDestId=Id From Common.ContactDetails Where EntityId=@SyncAccountId And ContactId=@ContactId
								If Not Exists (Select Id From Common.Addresses Where Addsectiontype=@AddrsAddSecType And AddTypeId=@CntDtlDestId And AddressBookId=@AddressBookId/*And CompanyId=@CompanyId*/)
								Begin
									Insert Into Common.Addresses(Id,AddSectionType,AddType,AddTypeId,AddTypeIdInt,AddressBookId,Status,DocumentId,EntityId,ScreenName,IsCurrentAddress,CompanyId)
										Select NEWID(),AddSectionType,'AccountContactDetailId',@CntDtlDestId,AddTypeIdInt,AddressBookId,Status,@AdrsEntityId,null,null,IsCurrentAddress,@CompanyId From Common.Addresses Where Id=@AddressId /*And CompanyId=@CompanyId*/
								End
							End
						End
						Set @IndCount=@IndCount+1
					End
					Truncate Table #Loc_AdrsTbl
				End 
				--ContactDetail Addresses From Account
				Begin
					Set @IndCount=1
					Insert into #Loc_AdrsTbl
					Select Distinct Adrs.id As AddressId,Adrs.AddressBookId,Adrs.AddSectionType,Adrs.AddTypeId,A.EntityId  From Common.Addresses As Adrs
					Inner join Common.ContactDetails As A On A.Id=Adrs.AddTypeId 
					Where A.EntityId In (Select Id From ClientCursor.Account Where CompanyId=@CompanyId And SyncEntityId Is Not Null)
					Select @AdrsCount=count(*) From #Loc_AdrsTbl
					While @AdrsCount>=@IndCount
					Begin
						Select @AddressId=AddressId,@AddressBookId=AddressBookId,@AddrsAddSecType=AddSectionType,@AdrsEntityId=AdrsEntityId,@CntdtlEntityId=DestId From #Loc_AdrsTbl Where Id=@IndCount
						Select @ContactId=ContactId,@SyncAccountId=EntityId From Common.ContactDetails Where Id=@AdrsEntityId
						If @ContactId Is Not null And @SyncAccountId Is Not Null
						Begin
							Set @SyncEntityId=(Select Id From Bean.Entity Where CompanyId=@CompanyId And SyncAccountId=@SyncAccountId And SyncAccountId Is Not Null)
							If @SyncEntityId Is Not Null
							Begin
								Select @CntDtlDestId=Id From Common.ContactDetails Where EntityId=@SyncEntityId And ContactId=@ContactId
								If Not Exists (Select Id From Common.Addresses Where Addsectiontype=@AddrsAddSecType And AddTypeId=@CntDtlDestId And AddressBookId=@AddressBookId /*And CompanyId=@CompanyId*/)
								Begin
									Delete From Common.Addresses Where Id=@AddressId
								End
							End
						End
						Set @IndCount=@IndCount+1
					End
					Truncate Table #Loc_AdrsTbl
				End 
			End
		End
		Drop table #Loc_Cont_Tbl
		Drop table #Loc_AdrsTbl
		Commit Transaction
	End Try
	Begin Catch
		Rollback;
		Throw;
	End Catch

End


GO
