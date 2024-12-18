USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[Import_Account_To_Client_Entity]    Script Date: 16-12-2024 9.20.10 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO







CREATE Procedure [dbo].[Import_Account_To_Client_Entity]
@CompanyId BigInt
As
Begin
	Declare @GeneratedNumber Varchar(100),
			@SystemRefnum Varchar(100),
			@UserCreatedOrModified Varchar(10),
			@GetDate DateTime2,
			@BaseCurrency varchar(20)='SGD',
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
	Begin Transaction
	Begin Try
		--Declare Temp Table variable to store contact deatils
		if object_id('tempdb..#Loc_Cont_Tbl', 'U') is null
		Create Table #Loc_Cont_Tbl (Id Int Identity(1,1),ContactDetailId Uniqueidentifier,EntityType Nvarchar(200),ContactId Uniqueidentifier,EntityId Uniqueidentifier,DestId Uniqueidentifier)
		--Declare Temp Table variable to store Addresses deatils
		if object_id('tempdb..#Loc_AdrsTbl', 'U') is null
		Create Table #Loc_AdrsTbl (Id Int Identity(1,1),AddressId Uniqueidentifier,AddressBookId Uniqueidentifier,AddSectionType NVarchar(100),AdrsEntityId Uniqueidentifier,DestId Uniqueidentifier)
		Truncate Table #Loc_Cont_Tbl
		Truncate Table #Loc_AdrsTbl
		--If Workflow Is Activated
		If Exists(Select Id From Common.CompanyModule Where CompanyId=@CompanyId And ModuleId in (Select Id from Common.ModuleMaster Where Name='Workflow Cursor') And Status=1)
		Begin
			--Getting systemrefnumber
			Set @GeneratedNumber=(Select GeneratedNumber From Common.AutoNumber Where CompanyId=@CompanyId And EntityType='WorkFlow Client' And ModuleMasterId=(Select Id From Common.ModuleMaster Where Name='Workflow Cursor'))
			Set @SystemRefnum=(Select Top(1) SystemRefNo From WorkFlow.Client Where CompanyId=@CompanyId And SystemRefNo Is not null Order By SystemRefNo Desc)
			If @SystemRefnum Is Null or @SystemRefnum =''
	        Begin
		       Set @SystemRefnum=(Select Preview From Common.AutoNumber Where CompanyId=@CompanyId And EntityType='WorkFlow Client' And ModuleMasterId=(Select Id From Common.ModuleMaster Where Name='Workflow Cursor'))
	        End
	            Set @SystemRefnum=Reverse(SUBSTRING(Reverse(@SystemRefnum),PATINDEX('%[0-9][^0-9]%', Reverse(@SystemRefnum))+1,DATALENGTH(@SystemRefnum)))

			--Set @SystemRefnum=Reverse(SUBSTRING(Reverse(@SystemRefnum),PATINDEX('%[0-9][^0-9]%', Reverse(@SystemRefnum))+1,DATALENGTH(@SystemRefnum)))
			--Insert into client table from account table
		
			Insert Into WorkFlow.Client (Id,Name,CompanyId,ClientTypeId,IdtypeId,ClientIdNo,TermsOfPaymentId,Industry,Source,SourceId,SourceName,SourceRemarks,IncorporationDate,FinancialYearEnd,CountryOfIncorporation,ClientStatus,PrincipalActivities,RecOrder,Remarks,UserCreated,CreatedDate,Version,Status,Communication,SystemRefNo,SyncAccountId,SyncAccountStatus,SyncAccountRemarks,SyncAccountDate)
				Select NEWID(),Name,@CompanyId,AccountTypeId,AccountIdTypeId,AccountIdNo,TermsOfPaymentId,Industry,Source,SourceId,SourceName,SourceRemarks,IncorporationDate,FinancialYearEnd,CountryOfIncorporation,AccountStatus,PrincipalActivities,RecOrder,Remarks,@UserCreatedOrModified,@GetDate,Version,Status,Communication,
				CONCAT(@SystemRefnum,Right('0000000000'+Cast((@GeneratedNumber+ROW_NUMBER () Over (Order By Id) ) As varchar),Len(@GeneratedNumber))),Id,@SyncStatusCompleted,Null,@GetDate
				From ClientCursor.Account 
				Where CompanyId=@CompanyId And IsAccount=1 And Status=1
				And Id Not In (Select SyncAccountId From WorkFlow.Client Where CompanyId=@CompanyId And SyncAccountId Is Not NUll)
				And Isnull(SyncEntityId,'00000000-0000-0000-0000-000000000000') Not In (Select SyncEntityId From WorkFlow.Client Where CompanyId=@CompanyId And SyncEntityId Is not null)
				And [Name] Not In (Select Distinct [Name] From WorkFlow.Client Where CompanyId=@CompanyId And SyncAccountId Is Not NUll)
				Order by Name
			Insert Into WorkFlow.ClientStatusChange (Id,CompanyId,ClientId,State,ModifiedBy,ModifiedDate)
			Select Newid(),@CompanyId,Id,'Active',@UserCreatedOrModified,@GetDate From WorkFlow.Client Where CompanyId=@CompanyId And CreatedDate=@GetDate
			
			-- Update syncClient Details in  Account
			Update A Set A.SyncClientId=C.Id,A.ClientId=C.Id,A.SyncClientDate=@GetDate,A.SyncClientStatus=@SyncStatusCompleted,A.SyncClientRemarks=Null 
			From ClientCursor.Account As A
			Inner Join WorkFlow.Client As C On C.SyncAccountId=A.Id 
			Where A.CompanyId=@CompanyId And C.CreatedDate=@GetDate
			--Update Autogeneratenumber
			Set @SystemRefnum=(Select Top(1) SystemRefNo From WorkFlow.Client Where CompanyId=@CompanyId And SystemRefNo Is not null Order By SystemRefNo Desc)
			Set @SystemRefnum=Reverse(SUBSTRING(Reverse(@SystemRefnum),0,PATINDEX('%[0-9][^0-9]%', Reverse(@SystemRefnum))+1))
			Update Common.AutoNumber Set GeneratedNumber=@SystemRefnum
			 Where CompanyId=@CompanyId And EntityType='WorkFlow Client' And ModuleMasterId=(Select Id From Common.ModuleMaster Where Name='Workflow Cursor')
			--ContactDetails From Account
			Begin
				Set @IndCount=1
				Set @Count=0
				Insert into #Loc_Cont_Tbl
				Select Distinct Cd.Id As ContactDetailId,CD.EntityType,CD.ContactId,CD.EntityId,A.SyncClientId From Common.ContactDetails As CD
				Inner Join ClientCursor.Account As A On A.Id=CD.EntityId
				Inner Join Common.Contact As C On C.Id=CD.ContactId 
				Where A.CompanyId=@CompanyId And A.SyncClientId Is Not Null And SyncClientDate=@GetDate and IsAccount=1
				Select @Count=count(*) From #Loc_Cont_Tbl
				While @Count>=@IndCount
				Begin
					Select @ContactDetailId=ContactDetailId,@ContactId=ContactId,@CDEntityId=EntityId,@SyncClientId=DestId From #Loc_Cont_Tbl Where Id=@IndCount
					If Not Exists (Select Id From Common.ContactDetails Where ContactId=@ContactId And EntityId=@SyncClientId)
					Begin
						Set @New_ContctDtlId=NewId()
						Insert Into Common.ContactDetails (Id,ContactId,EntityId,EntityType,Designation,Communication,Matters,IsPrimaryContact,IsReminderReceipient,RecOrder,OtherDesignation,IsPinned,CursorShortCode,Status,UserCreated,CreatedDate,Remarks,DocId,DocType,IsCopy)
							Select @New_ContctDtlId,@ContactId,@SyncClientId,'Client',Designation,Communication,Matters,IsPrimaryContact,IsReminderReceipient,RecOrder,OtherDesignation,IsPinned,'WF',Status,@UserCreatedOrModified,@Getdate,Remarks,@CDEntityId,'Account' ,IsCopy From Common.ContactDetails Where Id=@ContactDetailId
					End
					Else
					Begin
						Update A Set A.Designation=B.Designation,A.Communication=B.Communication,A.IsPrimaryContact=B.IsPrimaryContact,A.Matters=B.Matters,A.RecOrder=B.RecOrder,A.Status=B.Status,A.IsReminderReceipient=B.IsReminderReceipient,ModifiedBy=@UserCreatedOrModified,ModifiedDate=@GetDate,A.Remarks=B.Remarks,a.IsCopy=b.IsCopy From Common.ContactDetails As A
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
				Where A.CompanyId=@CompanyId And A.SyncAccountId Is Not Null And A.CreatedDate=@GetDate
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
				Where A.CompanyId=@CompanyId And A.SyncClientId Is Not Null And A.SyncClientDate=@GetDate and IsAccount=1
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
				Where A.CompanyId=@CompanyId And A.SyncAccountId Is Not Null And CreatedDate=@GetDate
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
				Where A.EntityId In (Select Id From ClientCursor.Account Where CompanyId=@CompanyId and isaccount=1 And SyncClientId Is Not Null And SyncClientDate=@GetDate)
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
				Where A.EntityId In (Select Id From WorkFlow.Client Where CompanyId=@CompanyId And SyncAccountId Is Not Null And CreatedDate=@GetDate)
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
		--If Bean Is Activated
		If Exists(Select Id From Common.CompanyModule Where CompanyId=@CompanyId And ModuleId in (Select Id from Common.ModuleMaster Where Name='Bean Cursor') And Status=1)
		Begin
			-- Insert Into Bean.Entity Table From Account
			Insert Into Bean.Entity(Id,Name,CompanyId,TypeId,IdTypeId,IdNo,IsCustomer,CustTOPId,CustCurrency,CustNature,RecOrder,Remarks,UserCreated,CreatedDate,Status,IsExternalData,IsShowPayroll,Communication,ExternalEntityType,SyncAccountId,SyncAccountDate,SyncAccountRemarks,SyncAccountStatus,SyncClientId,SyncClientDate,SyncClientRemarks,SyncClientStatus)
			Select NEWID(),Name,@CompanyId,AccountTypeId,AccountIdTypeId,AccountIdNo,1 As Iscutomer,Case when TermsOfPaymentId is not null then TermsOfPaymentId else (select id from common.termsofpayment where companyid=@companyId and name='Credit - 0') end,
					@BaseCurrency,'Trade',RecOrder,Remarks,@UserCreatedOrModified,@GetDate,Case When AccountStatus='Active' Then 1 When AccountStatus='Inactive' then 2 End ,@IsExternalData,1 As IsShowPayroll,Communication,'Account',Id,@GetDate,null,@SyncStatusCompleted,SyncClientId,@GetDate,null,@SyncStatusCompleted
			From ClientCursor.Account 
			Where IsAccount=1  and  CompanyId=@CompanyId And Id Not In (select SyncAccountId from Bean.Entity Where CompanyId=@CompanyId And SyncAccountId Is Not Null)
			And Isnull(SyncClientId,'00000000-0000-0000-0000-000000000000') Not In (Select SyncClientId From Bean.Entity Where CompanyId=@CompanyId And SyncClientId Is Not Null)
			And [name] Not In (select distinct [name] from Bean.Entity Where CompanyId=@CompanyId And SyncAccountId Is Not Null)
			order by Name
			-- Update syncEntity details in Account
			Update A Set A.SyncEntityId=E.Id,A.SyncEntitydate=@GetDate,A.SyncEntityStatus=@SyncStatusCompleted,A.SyncEntityRemarks=Null 

			From ClientCursor.Account As A
			Inner Join Bean.Entity As E On E.SyncAccountId=A.Id 
			Where A.CompanyId=@CompanyId And E.CreatedDate=@GetDate and IsAccount=1
			--ContactDetails From Account
			Begin
				Set @IndCount=1
				Set @Count=0
				Insert into #Loc_Cont_Tbl
				Select Distinct Cd.Id As ContactDetailId,CD.EntityType,CD.ContactId,CD.EntityId,A.SyncEntityId From Common.ContactDetails As CD
				Inner Join ClientCursor.Account As A On A.Id=CD.EntityId
				Inner Join Common.Contact As C On C.Id=CD.ContactId 
				Where A.CompanyId=@CompanyId And A.SyncEntityId Is Not Null And A.SyncEntityDate=@GetDate and IsAccount=1
				Select @Count=count(*) From #Loc_Cont_Tbl
				While @Count>=@IndCount
				Begin
					Select @ContactDetailId=ContactDetailId,@ContactId=ContactId,@CDEntityId=EntityId,@SyncEntityId=DestId From #Loc_Cont_Tbl Where Id=@IndCount
					If Not Exists (Select Id From Common.ContactDetails Where ContactId=@ContactId And EntityId=@SyncEntityId)
					Begin
						Set @New_ContctDtlId=NewId()
						Insert Into Common.ContactDetails (Id,ContactId,EntityId,EntityType,Designation,Communication,Matters,IsPrimaryContact,IsReminderReceipient,RecOrder,OtherDesignation,IsPinned,CursorShortCode,Status,UserCreated,CreatedDate,Remarks,DocId,DocType,IsCopy)
							Select @New_ContctDtlId,@ContactId,@SyncEntityId,'Entity',Designation,Communication,Matters,IsPrimaryContact,IsReminderReceipient,RecOrder,OtherDesignation,IsPinned,'Bean',Status,@UserCreatedOrModified,@Getdate,Remarks,@CDEntityId,'Account',IsCopy From Common.ContactDetails Where Id=@ContactDetailId
					End
					Else
					Begin
						Update A Set A.Designation=B.Designation,A.Communication=B.Communication,A.IsPrimaryContact=B.IsPrimaryContact,A.Matters=B.Matters,A.RecOrder=B.RecOrder,A.Status=B.Status,A.IsReminderReceipient=B.IsReminderReceipient,ModifiedBy=@UserCreatedOrModified,ModifiedDate=@GetDate,A.Remarks=B.Remarks,a.IsCopy=b.IsCopy From Common.ContactDetails As A
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
				Where A.CompanyId=@CompanyId And A.SyncClientId Is Not Null And A.CreatedDate=@GetDate
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
				Where A.CompanyId=@CompanyId And A.SyncEntityId Is Not Null And A.SyncEntityDate=@GetDate and IsAccount=1
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
				Where A.CompanyId=@CompanyId And A.SyncAccountId Is Not Null And A.CreatedDate=@GetDate
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
				Where A.EntityId In (Select Id From ClientCursor.Account Where CompanyId=@CompanyId  and isaccount=1 And SyncEntityId Is Not Null And SyncEntityDate=@GetDate)
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
				Where A.EntityId In (Select Id From Bean.Entity Where CompanyId=@CompanyId And SyncAccountId Is Not Null And CreatedDate=@GetDate)
				Select @AdrsCount=count(*) From #Loc_AdrsTbl
				While @AdrsCount>=@IndCount
				Begin
					Select @AddressId=AddressId,@AddressBookId=AddressBookId,@AddrsAddSecType=AddSectionType,@AdrsEntityId=AdrsEntityId,@CntdtlEntityId=DestId From #Loc_AdrsTbl Where Id=@IndCount
					Select @ContactId=ContactId,@SyncEntityId=EntityId From Common.ContactDetails Where Id=@AdrsEntityId
					If @ContactId Is Not null And @SyncEntityId Is Not Null
					Begin
						Set @SyncAccountId=(Select Id From ClientCursor.Account Where  isaccount=1 and CompanyId=@CompanyId And SyncEntityId=@SyncEntityId And SyncEntityId Is Not Null)
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
		--If Workflow And Bean Both Activated
		If Exists(Select Id From Common.CompanyModule Where CompanyId=@CompanyId And ModuleId in (Select Id from Common.ModuleMaster Where Name='Bean Cursor') And Status=1)
		Begin
			If Exists(Select Id From Common.CompanyModule Where CompanyId=@CompanyId And ModuleId in (Select Id from Common.ModuleMaster Where Name='Workflow Cursor') And Status=1)
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
		End
		Drop table #Loc_Cont_Tbl
		Drop table #Loc_AdrsTbl
		Commit Transaction
	End Try
	Begin catch
		RollBack Transaction
		Print Error_Message()
	End Catch
End

GO
