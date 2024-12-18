USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[Import_Client_To_Account_Entity]    Script Date: 16-12-2024 9.20.10 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE Procedure [dbo].[Import_Client_To_Account_Entity]
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
	 set @BaseCurrency = (select Distinct  BaseCurrency from Common.Localization where  CompanyId=@CompanyId)
	Begin Transaction
	Begin try
		--Declare Temp Table variable to store contact deatils
		if object_id('tempdb..#Loc_Cont_Tbl', 'U') is null
			Create Table #Loc_Cont_Tbl (Id Int Identity(1,1),ContactDetailId Uniqueidentifier,EntityType Nvarchar(200),ContactId Uniqueidentifier,EntityId Uniqueidentifier,DestId Uniqueidentifier)
		--Declare Temp Table variable to store Addresses deatils
		if object_id('tempdb..#Loc_AdrsTbl', 'U') is null
			Create Table #Loc_AdrsTbl (Id Int Identity(1,1),AddressId Uniqueidentifier,AddressBookId Uniqueidentifier,AddSectionType NVarchar(100),AdrsEntityId Uniqueidentifier,DestId Uniqueidentifier)
		Truncate table #Loc_Cont_Tbl
		Truncate table #Loc_AdrsTbl
		--Generate autonumber
		Set @GeneratedNumber=(Select GeneratedNumber From Common.AutoNumber Where CompanyId=@CompanyId And EntityType='Account' And ModuleMasterId=(Select Id From Common.ModuleMaster Where Name='Client Cursor'))
		Set @SystemRefnum=(Select Top(1) SystemRefNo From ClientCursor.Account Where CompanyId=@CompanyId And SystemRefNo Is not null Order By CreatedDate Desc)
		Set @SystemRefnum=Reverse(SUBSTRING(Reverse(@SystemRefnum),PATINDEX('%[0-9][^0-9]%', Reverse(@SystemRefnum))+1,DATALENGTH(@SystemRefnum)))
		If Exists(Select Id From Common.CompanyModule Where CompanyId=@CompanyId And ModuleId in (Select Id from Common.ModuleMaster Where Name='Client Cursor') And Status=1)
		Begin
			--Insert into CC.Account from WF.Client
			Insert Into ClientCursor.Account (Id,Name,CompanyId,AccountTypeId,AccountIdTypeId,AccountIdNo,TermsOfPaymentId,Industry,Source,SourceId,SourceName,SourceRemarks,IncorporationDate,FinancialYearEnd,CountryOfIncorporation,AccountStatus,PrincipalActivities,UserCreated,CreatedDate,Version,Status,SystemRefNo,SyncClientId,SyncClientRemarks,SyncClientStatus,SyncClientDate,AccountId)
				Select NEWID(),Name,CompanyId,ClientIdTypeId,IdtypeId,ClientIdNo,TermsOfPaymentId,Industry,Source,SourceId,SourceName,SourceRemarks,IncorporationDate,FinancialYearEnd,CountryOfIncorporation,ClientStatus,PrincipalActivities,@UserCreatedOrModified,@GetDate,Version,Status,CONCAT(@SystemRefnum,Right('0000000000'+Cast((@GeneratedNumber+ROW_NUMBER () Over (Order By Id) ) As varchar),Len(@GeneratedNumber))),Id,Null,@SyncStatusCompleted,@GetDate,CONCAT(@SystemRefnum,Right('0000000000'+Cast((@GeneratedNumber+ROW_NUMBER () Over (Order By Id) ) As varchar),Len(@GeneratedNumber)))
				From WorkFlow.Client
				Where CompanyId=@CompanyId 
				And Id not in (Select SyncClientId from ClientCursor.Account Where CompanyId=@CompanyId And SyncClientId Is Not Null)
				And isnull(SyncEntityId,'00000000-0000-0000-0000-000000000000')   Not In (Select SyncEntityId From ClientCursor.Account Where CompanyId=@CompanyId And SyncEntityId Is Not null)
				And [name] not in (Select distinct [name] from ClientCursor.Account Where CompanyId=@CompanyId And SyncClientId Is Not Null)
				order by Name
			--Update Syncaccount data 
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
				Where A.CompanyId=@CompanyId And A.SyncAccountId Is Not Null And SyncAccountDate=@Getdate
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

		End
		If Exists(Select Id From Common.CompanyModule Where CompanyId=@CompanyId And ModuleId in (Select Id from Common.ModuleMaster Where Name='Bean Cursor') And Status=1)
		Begin
			Insert Into Bean.Entity (Id,CompanyId,Name,TypeId,IdTypeId,IdNo,IsCustomer,CustTOPId,CustCurrency,CustNature,RecOrder,Remarks,UserCreated,CreatedDate,Status,IsExternalData,IsShowPayroll,Communication,ExternalEntityType,SyncClientId,SyncClientDate,SyncClientStatus,SyncClientRemarks)
			Select NEWID(),@CompanyId,Name,ClientTypeId,IdtypeId,ClientIdNo,1,Case when TermsOfPaymentId is not null then TermsOfPaymentId else (select id from common.termsofpayment where companyid=@companyId and name='Credit - 0') end,
					@BaseCurrency,@CustNature,RecOrder,Remarks,@UserCreatedOrModified,@GetDate,Case When ClientStatus='Active' Then 1 When ClientStatus='Inactive' then 2 End,1,1 ,Communication,'Client',Id,@GetDate,@SyncStatusCompleted,Null
			From WorkFlow.Client 
			Where CompanyId=@CompanyId 
			And Id Not In (Select SyncClientId From Bean.Entity Where CompanyId=@CompanyId And SyncClientId Is not null)
			And isnull(SyncAccountId,'00000000-0000-0000-0000-000000000000')  Not In (Select SyncAccountId From Bean.Entity Where CompanyId=@CompanyId And SyncAccountId Is not null)
			And [Name] Not In (Select distinct  [Name] From Bean.Entity Where CompanyId=@CompanyId And SyncClientId Is not null)	
				order by Name
			--Update SyncDetails In Client
			Update C Set C.SyncEntityId=E.Id,C.SyncEntitydate=@GetDate,C.SyncEntityStatus=@SyncStatusCompleted,C.SyncEntityRemarks=Null 
			From WorkFlow.Client As C
			Inner Join Bean.Entity As E On E.SyncClientId=C.Id
			Where C.CompanyId=@CompanyId And E.CreatedDate=@GetDate
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
		If Exists(Select Id From Common.CompanyModule Where CompanyId=@CompanyId And ModuleId in (Select Id from Common.ModuleMaster Where Name='Client Cursor') And Status=1)
		Begin
			If Exists(Select Id From Common.CompanyModule Where CompanyId=@CompanyId And ModuleId in (Select Id from Common.ModuleMaster Where Name='Bean Cursor') And Status=1)
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
		End
		Drop table #Loc_Cont_Tbl
		Drop table #Loc_AdrsTbl
		Commit Transaction
	End Try

	Begin Catch
		Rollback transaction
		Print Error_Message()
	End catch
	End
GO
