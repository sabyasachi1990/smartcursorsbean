USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[Common_Sync_MasterData_Client_Account]    Script Date: 16-12-2024 9.20.10 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


--Exec  [dbo].[Common_Sync_MasterData_Client_Account] 237,'FDB5D605-D740-4A9B-8A83-A4A838BA0083','Add'
CREATE Procedure [dbo].[Common_Sync_MasterData_Client_Account]
	@CompanyId BigInt, 
	@ClientId Uniqueidentifier,
	@Action Varchar(50)
As
Begin
	Declare @UserCreatedOrModified Varchar(10),
			@GetDate DateTime2,
			@BaseCurrency varchar(20),
			@SyncStatusCompleted varchar(20),
			@SyncStatusUpdateCompleted varchar(20),
			@SyncStatusUpdateFalied varchar(20),
			@SyncStatusFailed varchar(20),
			@IsExternalData Int,
			@CustNature Varchar(20),
			@AccountId Uniqueidentifier,
			@IndCount Int,
			@Count Int,
			@ContactId Uniqueidentifier,
			@CDEntityId Uniqueidentifier,
			@SyncAccountId Uniqueidentifier,
			@AdrsCount int,
			@AddressBookId Uniqueidentifier,
			@AdrsEntityId Uniqueidentifier,
			@AdrsSyncAccountId Uniqueidentifier,
			@SystemRefnum Varchar(100),
			@GeneratedNumber Varchar(100),
			@AddressId Uniqueidentifier,
			@ContactDetailId Uniqueidentifier,
			@New_ContctDtlId Uniqueidentifier,
			@SyncClientId Uniqueidentifier,
			@AddrsAddSecType Nvarchar(200),
			@AdrsSyncClientId Uniqueidentifier,
			@CntdtlEntityId Uniqueidentifier,
			@CntDtlDestId Uniqueidentifier
		Set @UserCreatedOrModified='System'
		Set @GetDate=Getutcdate()
		Set @SyncStatusCompleted='Completed'
		Set @SyncStatusUpdateCompleted='UpdateCompleted'
		Set @SyncStatusUpdateFalied='UpdateFailed'
		Set @IsExternalData=1
		Set @CustNature='Trade'
		Set @SyncStatusFailed='Failed'

	--Declare Temp Table variable to store contact deatils
	if object_id('tempdb..#Loc_Cont_Tbl', 'U') is null
	Create Table #Loc_Cont_Tbl (Id Int Identity(1,1),ContactDetailId Uniqueidentifier,EntityType Nvarchar(200),ContactId Uniqueidentifier,EntityId Uniqueidentifier,DestId Uniqueidentifier)
	--Declare Temp Table variable to store Addresses deatils
	if object_id('tempdb..#Loc_AdrsTbl', 'U') is null
	Create Table #Loc_AdrsTbl (Id Int Identity(1,1),AddressId Uniqueidentifier,AddressBookId Uniqueidentifier,AddSectionType NVarchar(100),AdrsEntityId Uniqueidentifier,DestId Uniqueidentifier)
	Truncate Table #Loc_Cont_Tbl
	Truncate Table #Loc_AdrsTbl
	Set @GeneratedNumber=(Select GeneratedNumber From Common.AutoNumber Where CompanyId=@CompanyId And EntityType='Account' And ModuleMasterId=(Select Id From Common.ModuleMaster Where Name='Client Cursor'))
	Set @SystemRefnum=(Select Top(1) SystemRefNo From ClientCursor.Account Where CompanyId=@CompanyId And SystemRefNo Is not null Order By CreatedDate Desc)
	If @SystemRefnum Is Null 
	Begin
		Set @SystemRefnum=(Select Preview From Common.AutoNumber Where CompanyId=@CompanyId And EntityType='Account' And ModuleMasterId=(Select Id From Common.ModuleMaster Where Name='Client Cursor'))
	End
	Set @SystemRefnum=Reverse(SUBSTRING(Reverse(@SystemRefnum),PATINDEX('%[0-9][^0-9]%', Reverse(@SystemRefnum))+1,DATALENGTH(@SystemRefnum)))
--Begin Transaction
Begin Transaction
	--Try Block For Whole Transaction
	Begin Try
		If(@Action='Add')
		Begin
			If Not Exists (Select Id From ClientCursor.Account Where CompanyId=@CompanyId And SyncClientId=@ClientId)
			Begin
				Begin Try
					Set @AccountId=NEWID()
					Insert Into ClientCursor.Account (Id,Name,CompanyId,AccountTypeId,AccountIdTypeId,AccountIdNo,TermsOfPaymentId,Industry,Source,SourceId,SourceName,SourceRemarks,IncorporationDate,FinancialYearEnd,CountryOfIncorporation,AccountStatus,PrincipalActivities,UserCreated,CreatedDate,Version,Status,SyncClientId,SyncClientStatus,SyncClientDate,SyncClientRemarks,ClientId,SystemRefNo,IsAccount,AccountId)
						Select @AccountId,Name,CompanyId,ClientIdTypeId,IdtypeId,ClientIdNo,TermsOfPaymentId,Industry,Source,SourceId,SourceName,SourceRemarks,IncorporationDate,FinancialYearEnd,CountryOfIncorporation,ClientStatus,PrincipalActivities,@UserCreatedOrModified,@GetDate,Version,Status,Id,@SyncStatusCompleted,@GetDate,Null,@ClientId,CONCAT(@SystemRefnum,Right('0000000000'+Cast((@GeneratedNumber+ROW_NUMBER () Over (Order By Id) ) As varchar),Len(@GeneratedNumber))),1,CONCAT(@SystemRefnum,Right('0000000000'+Cast((@GeneratedNumber+ROW_NUMBER () Over (Order By Id) ) As varchar),Len(@GeneratedNumber)))
						From WorkFlow.Client
						Where CompanyId=@CompanyId And Id=@ClientId
					Update WorkFlow.Client Set SyncAccountId=@AccountId,SyncAccountDate=@GetDate,SyncAccountStatus=@SyncStatusCompleted,SyncAccountRemarks=null Where Id=@ClientId And CompanyId=@CompanyId
					
					--ContactDetails From Client
					Begin
						Set @IndCount=1
						Set @Count=0
						Insert into #Loc_Cont_Tbl
						Select Distinct Cd.Id As ContactDetailId,CD.EntityType,CD.ContactId,CD.EntityId,A.SyncAccountId From Common.ContactDetails As CD
						Inner Join WorkFlow.Client As A On A.Id=CD.EntityId
						Inner Join Common.Contact As C On C.Id=CD.ContactId 
						Where A.CompanyId=@CompanyId And A.SyncAccountId Is Not Null And A.Id=@ClientId
						Select @Count=count(*) From #Loc_Cont_Tbl
						While @Count>=@IndCount
						Begin
							Select @ContactDetailId=ContactDetailId,@ContactId=ContactId,@CDEntityId=EntityId,@SyncAccountId=DestId From #Loc_Cont_Tbl Where Id=@IndCount
							If Not Exists (Select Id From Common.ContactDetails Where ContactId=@ContactId And EntityId=@SyncAccountId)
							Begin
								Set @New_ContctDtlId=NewId()
								Insert Into Common.ContactDetails (Id,ContactId,EntityId,EntityType,Designation,Communication,Matters,IsPrimaryContact,IsReminderReceipient,RecOrder,OtherDesignation,IsPinned,CursorShortCode,Status,UserCreated,CreatedDate,Remarks,DocId,DocType,IsCopy)
									Select @New_ContctDtlId,@ContactId,@SyncAccountId,'Account',Designation,Communication,Matters,IsPrimaryContact,IsReminderReceipient,RecOrder,OtherDesignation,IsPinned,'CC',Status,@UserCreatedOrModified,@Getdate,Remarks,@CDEntityId,'Client',IsCopy From Common.ContactDetails Where Id=@ContactDetailId
							End
							Else
							Begin
								Update A Set A.Designation=B.Designation,A.Communication=B.Communication,A.IsPrimaryContact=B.IsPrimaryContact,A.Matters=B.Matters,A.RecOrder=B.RecOrder,A.Status=B.Status,A.IsReminderReceipient=B.IsReminderReceipient,ModifiedBy=@UserCreatedOrModified,ModifiedDate=@GetDate,A.Remarks=B.Remarks,A.IsCopy=B.IsCopy From Common.ContactDetails As A
								Inner Join 
								(Select * From Common.ContactDetails Where EntityId=@ClientId And ContactId=@ContactId) As B On B.ContactId=A.ContactId
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
						Where A.CompanyId=@CompanyId And A.SyncClientId=@ClientId
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
						Where A.CompanyId=@CompanyId And A.SyncAccountId=@AccountId
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
						Select Distinct Adrs.id As AddressId,Adrs.AddressBookId,Adrs.AddSectionType,Adrs.AddTypeId,A.SyncClientId From Common.Addresses As Adrs
						Inner join ClientCursor.Account As A On A.Id=Adrs.AddTypeId 
						Where A.CompanyId=@CompanyId And A.SyncClientId=@ClientId
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
					
					--ContactDetail From Client
					Begin
						Set @IndCount=1
						Insert into #Loc_AdrsTbl
						Select Distinct Adrs.id As AddressId,Adrs.AddressBookId,Adrs.AddSectionType,Adrs.AddTypeId,A.EntityId As EntityId From Common.Addresses As Adrs
						Inner join Common.ContactDetails As A On A.Id=Adrs.AddTypeId 
						Where A.EntityId In (Select Id From WorkFlow.Client Where CompanyId=@CompanyId And SyncAccountId=@AccountId)
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
					--ContactDetail From Account
					Begin
						Set @IndCount=1
						Insert into #Loc_AdrsTbl
						Select Distinct Adrs.id As AddressId,Adrs.AddressBookId,Adrs.AddSectionType,Adrs.AddTypeId,A.EntityId From Common.Addresses As Adrs
						Inner join Common.ContactDetails As A On A.Id=Adrs.AddTypeId 
						Where A.EntityId In (Select Id From ClientCursor.Account Where CompanyId=@CompanyId And SyncClientId=@ClientId)
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
				
				End Try
				Begin Catch
					Declare @ErrMsg Nvarchar(max)
					Set @ErrMsg=(Select ERROR_MESSAGE())
					Update WorkFlow.Client Set SyncAccountDate=@GetDate,SyncAccountStatus=@SyncStatusFailed,SyncAccountRemarks=@ErrMsg Where Id=@ClientId And CompanyId=@CompanyId
				End Catch
			End
			Else
			Begin
				Exec [dbo].[Common_Sync_MasterData_Client_Account] @CompanyId,@ClientId,'Edit'
			End
		End
		--Update bean.item table records based on documentid which is edited in common.service table	
		Else If(@Action='Edit')
		Begin
			--Edit
			If Exists (Select ID From ClientCursor.Account Where SyncClientId=@ClientId And CompanyId=@CompanyId)
			Begin
				Begin Try
					Set @AccountId=(Select SyncAccountId From WorkFlow.Client Where CompanyId=@CompanyId And Id=@ClientId)
					Update A Set A.Name=C.Name,A.AccountTypeId=C.ClientTypeId,A.AccountIdTypeId=C.IdtypeId,A.AccountIdNo=C.ClientIdNo,A.TermsOfPaymentId=C.TermsOfPaymentId,A.Industry=C.Industry,A.Source=C.Source,A.SourceId=C.SourceId,A.SourceName=C.SourceName,A.SourceRemarks=C.SourceRemarks,A.IncorporationDate=C.IncorporationDate,A.FinancialYearEnd=C.FinancialYearEnd,A.CountryOfIncorporation=C.CountryOfIncorporation,
					A.AccountStatus=C.ClientStatus,A.PrincipalActivities=C.PrincipalActivities,A.RecOrder=C.RecOrder,A.Remarks=C.Remarks,A.ModifiedBy=@UserCreatedOrModified,A.ModifiedDate=@GetDate,A.Version=C.Version,A.Status=C.Status,A.Communication=C.Communication,A.SyncClientStatus=@SyncStatusUpdateCompleted,A.SyncClientDate=@GetDate,A.SyncClientRemarks=null,a.IndustryCode=c.IndustryCode
					From ClientCursor.Account As A
					Inner Join Workflow.Client As C On C.SyncAccountId=A.Id 
					Where A.CompanyId=@CompanyId  And C.Id=@ClientId
					--Update SyncDetails In Workflow.Client
					Update WorkFlow.Client Set SyncAccountDate=@GetDate,SyncAccountStatus=@SyncStatusUpdateCompleted,SyncAccountRemarks=null Where CompanyId=@CompanyId And Id=@ClientId
					/*
					--ContactDetails From Client
					Begin
						Set @IndCount=1
						Set @Count=0
						Insert into #Loc_Cont_Tbl
						Select Distinct Cd.Id As ContactDetailId,CD.EntityType,CD.ContactId,CD.EntityId,A.SyncAccountId From Common.ContactDetails As CD
						Inner Join WorkFlow.Client As A On A.Id=CD.EntityId
						Inner Join Common.Contact As C On C.Id=CD.ContactId 
						Where A.CompanyId=@CompanyId And A.SyncAccountId Is Not Null And A.Id=@ClientId
						Select @Count=count(*) From #Loc_Cont_Tbl
						While @Count>=@IndCount
						Begin
							Select @ContactDetailId=ContactDetailId,@ContactId=ContactId,@CDEntityId=EntityId,@SyncAccountId=DestId From #Loc_Cont_Tbl Where Id=@IndCount
							If Not Exists (Select Id From Common.ContactDetails Where ContactId=@ContactId And EntityId=@SyncAccountId)
							Begin
								Set @New_ContctDtlId=NewId()
								Insert Into Common.ContactDetails (Id,ContactId,EntityId,EntityType,Designation,Communication,Matters,IsPrimaryContact,IsReminderReceipient,RecOrder,OtherDesignation,IsPinned,CursorShortCode,Status,UserCreated,CreatedDate,Remarks,DocId,DocType,IsCopy)
									Select @New_ContctDtlId,@ContactId,@SyncAccountId,'Account',Designation,Communication,Matters,IsPrimaryContact,IsReminderReceipient,RecOrder,OtherDesignation,IsPinned,'CC',Status,@UserCreatedOrModified,@Getdate,Remarks,@CDEntityId,'Client',IsCopy From Common.ContactDetails Where Id=@ContactDetailId
							End
							Else
							Begin
								Update A Set A.Designation=B.Designation,A.Communication=B.Communication,A.IsPrimaryContact=B.IsPrimaryContact,A.Matters=B.Matters,A.RecOrder=B.RecOrder,A.Status=B.Status,A.IsReminderReceipient=B.IsReminderReceipient,ModifiedBy=@UserCreatedOrModified,ModifiedDate=@GetDate,A.Remarks=B.Remarks,A.IsCopy=B.IsCopy From Common.ContactDetails As A
								Inner Join 
								(Select * From Common.ContactDetails Where EntityId=@ClientId And ContactId=@ContactId) As B On B.ContactId=A.ContactId
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
						Where A.CompanyId=@CompanyId And A.SyncClientId=@ClientId
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
				*/
					--Addresses From Client
					Begin
						Set @IndCount=1
						Insert into #Loc_AdrsTbl
						Select Distinct Adrs.id As AddressId,Adrs.AddressBookId,Adrs.AddSectionType,Adrs.AddTypeId,A.SyncAccountId From Common.Addresses As Adrs
						Inner join WorkFlow.Client As A On A.Id=Adrs.AddTypeId 
						Where A.CompanyId=@CompanyId And A.SyncAccountId=@AccountId
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
						Select Distinct Adrs.id As AddressId,Adrs.AddressBookId,Adrs.AddSectionType,Adrs.AddTypeId,A.SyncClientId From Common.Addresses As Adrs
						Inner join ClientCursor.Account As A On A.Id=Adrs.AddTypeId 
						Where A.CompanyId=@CompanyId And A.SyncClientId=@ClientId
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
				/*
					--ContactDetail From Client
					Begin
						Set @IndCount=1
						Insert into #Loc_AdrsTbl
						Select Distinct Adrs.id As AddressId,Adrs.AddressBookId,Adrs.AddSectionType,Adrs.AddTypeId,A.EntityId As EntityId From Common.Addresses As Adrs
						Inner join Common.ContactDetails As A On A.Id=Adrs.AddTypeId 
						Where A.EntityId In (Select Id From WorkFlow.Client Where CompanyId=@CompanyId And SyncAccountId=@AccountId)
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
					--ContactDetail From Account
					Begin
						Set @IndCount=1
						Insert into #Loc_AdrsTbl
						Select Distinct Adrs.id As AddressId,Adrs.AddressBookId,Adrs.AddSectionType,Adrs.AddTypeId,A.EntityId From Common.Addresses As Adrs
						Inner join Common.ContactDetails As A On A.Id=Adrs.AddTypeId 
						Where A.EntityId In (Select Id From ClientCursor.Account Where CompanyId=@CompanyId And SyncClientId=@ClientId)
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
					*/
				End Try
				Begin catch
					Declare @UpdtErrMsg Nvarchar(Max)
					Set @UpdtErrMsg=(Select ERROR_MESSAGE())
					Update WorkFlow.Client Set SyncAccountDate=@GetDate,SyncAccountStatus=@SyncStatusFailed,SyncAccountRemarks=@UpdtErrMsg Where Id=@ClientId And CompanyId=@CompanyId
				End Catch
			End
		End
		Else If(@Action='Active' OR @Action='Inactive')
		Begin
			If Exists (Select ID From ClientCursor.Account Where SyncClientId=@ClientId And CompanyId=@CompanyId)
			Begin
				Begin Try
					Update ClientCursor.Account Set AccountStatus=@Action,Status = Case When @Action='Active' Then 1 When @Action='Inactive' Then 2 End ,ModifiedBy=@UserCreatedOrModified,ModifiedDate=@GetDate,SyncClientStatus=@SyncStatusUpdateCompleted,SyncClientDate=@GetDate,SyncClientRemarks=null Where SyncClientId=@ClientId And CompanyId=@CompanyId
					Update WorkFlow.Client Set SyncAccountDate=@GetDate,SyncAccountStatus=@SyncStatusUpdateCompleted,SyncAccountRemarks=null Where CompanyId=@CompanyId And Id=@ClientId
				End Try
				Begin Catch
					Declare @ActErrMsg Nvarchar(Max)
					Set @ActErrMsg=(Select ERROR_MESSAGE())
					Update WorkFlow.Client Set SyncAccountDate=@GetDate,SyncAccountStatus=@SyncStatusUpdateFalied,SyncEntityRemarks=@ActErrMsg Where Id=@ClientId And CompanyId=@CompanyId
				End Catch
			End
		End
		/* --Update Syncdetails in Bean.Entity If Bean Is Activated
		If Exists (Select Id From Common.CompanyModule Where CompanyId=@CompanyId And ModuleId in (Select Id from Common.ModuleMaster Where Name='Bean Cursor') And Status=1)
		Begin
			Exec [dbo].[Common_Sync_MasterData_Client_Entity] @CompanyId,@ClientId,@Action
		End
		--Commit Transaction */
		Set @SystemRefnum=(Select Top(1) SystemRefNo From ClientCursor.Account Where CompanyId=@CompanyId And SystemRefNo Is not null Order By CreatedDate Desc)
		Set @SystemRefnum=Reverse(SUBSTRING(Reverse(@SystemRefnum),0,PATINDEX('%[0-9][^0-9]%', Reverse(@SystemRefnum))+1))
		Update Common.AutoNumber Set GeneratedNumber=@SystemRefnum Where CompanyId=@CompanyId And EntityType='Account' And ModuleMasterId=(Select Id From Common.ModuleMaster Where Name='Client Cursor')

		
		Drop table #Loc_Cont_Tbl
		Drop table #Loc_AdrsTbl

		Commit Transaction
	End Try

	Begin Catch
	Rollback Transaction;
	End Catch

End
GO
