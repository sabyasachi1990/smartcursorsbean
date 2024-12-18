USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[Common_Sync_MasterData_Entity_Client]    Script Date: 16-12-2024 9.20.10 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

--Exec  [dbo].[Common_Sync_MasterData_Entity_Client] 237,99900,'Add'
CREATE Procedure [dbo].[Common_Sync_MasterData_Entity_Client]
	@CompanyId BigInt, 
	@EntityId Uniqueidentifier,
	@Action Varchar(50)
As
Begin
	Declare @UserCreatedOrModified Varchar(10),
			@ClientId Uniqueidentifier,
			@GetDate DateTime2,
			@BaseCurrency varchar(20),
			@SyncStatusCompleted varchar(20),
			@SyncStatusUpdateCompleted varchar(20),
			@SyncStatusUpdateFalied varchar(20),
			@SyncStatusFailed varchar(20),
			@IsExternalData Int,
			@CustNature Varchar(20),
			@IndCount Int,
			@Count Int,
			@ContactId Uniqueidentifier,
			@CDEntityId Uniqueidentifier,
			@SyncClientId Uniqueidentifier,
			@AdrsCount int,
			@AddressBookId Uniqueidentifier,
			@AdrsEntityId Uniqueidentifier,
			@AdrsSyncClientId Uniqueidentifier,
			@SystemRefnum Varchar(100),
			@GeneratedNumber Varchar(100),
			@AddressId Uniqueidentifier,
			@ContactDetailId Uniqueidentifier,
			@New_ContctDtlId Uniqueidentifier,
			@SyncEntityId Uniqueidentifier,
			@AddrsAddSecType nvarchar(200),
			@AdrsSyncEntityId Uniqueidentifier,
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
	Set @GeneratedNumber=(Select GeneratedNumber From Common.AutoNumber Where CompanyId=@CompanyId And EntityType='WorkFlow Client' And ModuleMasterId=(Select Id From Common.ModuleMaster Where Name='Workflow Cursor'))
	Set @SystemRefnum=(Select Top(1) SystemRefNo From WorkFlow.Client Where CompanyId=@CompanyId And SystemRefNo Is not null Order By CreatedDate Desc)
	If @SystemRefnum Is Null 
	Begin
		Set @SystemRefnum=(Select Preview From Common.AutoNumber Where CompanyId=@CompanyId And EntityType='WorkFlow Client' And ModuleMasterId=(Select Id From Common.ModuleMaster Where Name='Workflow Cursor'))
	End
	Set @SystemRefnum=Reverse(SUBSTRING(Reverse(@SystemRefnum),PATINDEX('%[0-9][^0-9]%', Reverse(@SystemRefnum))+1,DATALENGTH(@SystemRefnum)))
	If Exists (Select Id From Bean.Entity Where Id=@EntityId And CompanyId=@CompanyId And IsCustomer=1)
	Begin
		--Begin Transaction
		Begin Transaction
		--Try Block For Whole Transaction
		Begin Try
			/*
			If(@Action='Add')
			Begin
				If Not Exists (Select Id From WorkFlow.Client Where CompanyId=@CompanyId And SyncEntityId=@EntityId)
				Begin
					Begin Try
						
						Set @ClientId=NEWID()
						--Insert Into Workflow.client from Bean.Entity Case when TermsOfPaymentId is not null then TermsOfPaymentId else (select id from common.termsofpayment where companyid=@companyId and name='Credit - 0') end
						Insert Into WorkFlow.Client (Id,Name,ClientTypeId,IdtypeId,ClientIdNo,RecOrder,Remarks,UserCreated,CreatedDate,TermsOfPaymentId,Communication,CompanyId,SyncEntityId,SyncEntityStatus,SyncEntitydate,SyncEntityRemarks,SystemRefNo,ClientStatus,Status)
							Select @ClientId,Name,TypeId,IdTypeId,IdNo,RecOrder,Remarks,@UserCreatedOrModified,@GetDate,Case when CustTOPId is not null then CustTOPId else (select id from common.termsofpayment where companyid=@companyId and name='Credit - 0') end,Communication,CompanyId,Id,@SyncStatusCompleted,@GetDate,null,CONCAT(@SystemRefnum,Right('0000000000'+Cast((@GeneratedNumber+ROW_NUMBER () Over (Order By Id) ) As varchar),Len(@GeneratedNumber))),Case When Status=1 Then 'Active' When Status<>1 Then 'Inactive' End,Status
							From Bean.Entity
							Where CompanyId=@CompanyId And Id=@EntityId
						--Update Syncclient Details in Bean.Entity
						Update Bean.Entity Set SyncClientDate=@GetDate,SyncClientId=@ClientId,SyncClientStatus=@SyncStatusCompleted,SyncClientRemarks=null Where CompanyId=@CompanyId And Id=@EntityId
						--Insert Into ClientStatusChange
						Insert Into WorkFlow.ClientStatusChange (Id,CompanyId,ClientId,State,ModifiedBy,ModifiedDate)
							Values(NEWID(),@CompanyId,@ClientId,'Active',@UserCreatedOrModified,@GetDate)
						--ContactDetails From Entity
						Begin
							Set @IndCount=1
							Set @Count=0
							Insert into #Loc_Cont_Tbl
							Select Distinct Cd.Id As ContactDetailId,CD.EntityType,CD.ContactId,CD.EntityId,A.SyncClientId From Common.ContactDetails As CD
							Inner Join Bean.Entity As A On A.Id=CD.EntityId
							Inner Join Common.Contact As C On C.Id=CD.ContactId 
							Where A.CompanyId=@CompanyId And A.SyncClientId=@ClientId
							Select @Count=count(*) From #Loc_Cont_Tbl
							While @Count>=@IndCount
							Begin
								Select @ContactDetailId=ContactDetailId,@ContactId=ContactId,@CDEntityId=EntityId,@SyncClientId=DestId From #Loc_Cont_Tbl Where Id=@IndCount
								If Not Exists (Select Id From Common.ContactDetails Where ContactId=@ContactId And EntityId=@SyncClientId)
								Begin
									Set @New_ContctDtlId=NewId()
									Insert Into Common.ContactDetails (Id,ContactId,EntityId,EntityType,Designation,Communication,Matters,IsPrimaryContact,IsReminderReceipient,RecOrder,OtherDesignation,IsPinned,CursorShortCode,Status,UserCreated,CreatedDate,Remarks,DocId,DocType,IsCopy)
										Select @New_ContctDtlId,@ContactId,@SyncClientId,'Client',Designation,Communication,Matters,IsPrimaryContact,IsReminderReceipient,RecOrder,OtherDesignation,IsPinned,'WF',Status,@UserCreatedOrModified,@Getdate,Remarks,@CDEntityId,'Bean',IsCopy From Common.ContactDetails Where Id=@ContactDetailId
								End
								Else
								Begin
									Update A Set A.Designation=B.Designation,A.Communication=B.Communication,A.IsPrimaryContact=B.IsPrimaryContact,A.Matters=B.Matters,A.RecOrder=B.RecOrder,A.Status=B.Status,A.IsReminderReceipient=B.IsReminderReceipient,ModifiedBy=@UserCreatedOrModified,ModifiedDate=@GetDate,A.Remarks=B.Remarks,A.IsCopy=B.IsCopy From Common.ContactDetails As A
									Inner Join 
									(Select * From Common.ContactDetails Where EntityId=@EntityId And ContactId=@ContactId) As B On B.ContactId=A.ContactId
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
							Where A.CompanyId=@CompanyId And A.SyncEntityId=@EntityId
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
							Where A.CompanyId=@CompanyId And A.SyncClientId=@ClientId
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
							Select Distinct Adrs.id As AddressId,Adrs.AddressBookId,Adrs.AddSectionType,Adrs.AddTypeId,A.SyncEntityId From Common.Addresses As Adrs
							Inner join WorkFlow.Client As A On A.Id=Adrs.AddTypeId 
							Where A.CompanyId=@CompanyId And A.SyncEntityId=@EntityId
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
						--ContactDetail From Entity
						Begin
							Set @IndCount=1
							Insert into #Loc_AdrsTbl
							Select Distinct Adrs.id As AddressId,Adrs.AddressBookId,Adrs.AddSectionType,Adrs.AddTypeId,A.EntityId As EntityId From Common.Addresses As Adrs
							Inner join Common.ContactDetails As A On A.Id=Adrs.AddTypeId 
							Where A.EntityId In (Select Id From Bean.Entity Where CompanyId=@CompanyId And SyncClientId=@ClientId)
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
						--ContactDetail From Client
						Begin
							Set @IndCount=1
							Insert into #Loc_AdrsTbl
							Select Distinct Adrs.id As AddressId,Adrs.AddressBookId,Adrs.AddSectionType,Adrs.AddTypeId,A.EntityId As ClientId From Common.Addresses As Adrs
							Inner join Common.ContactDetails As A On A.Id=Adrs.AddTypeId 
							Where A.EntityId In (Select Id From WorkFlow.Client Where CompanyId=@CompanyId And SyncEntityId=@EntityId)
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
					End Try
					Begin Catch
						Declare @ErrMsg Nvarchar(max)
						Set @ErrMsg=(Select ERROR_MESSAGE())
						Update Bean.Entity Set SyncClientDate=@GetDate,SyncClientStatus=@SyncStatusFailed,SyncClientRemarks=@ErrMsg Where Id=@EntityId And CompanyId=@CompanyId
					End Catch
				End
				Else
				Begin
					Exec [dbo].[Common_Sync_MasterData_Entity_Client] @CompanyId,@EntityId,'Edit'
				End
			End

			Else */
			If(@Action='Edit')
			Begin
				If Exists (Select ID From WorkFlow.Client Where SyncEntityId=@EntityId And CompanyId=@CompanyId)
				Begin
					Begin Try
						Set @ClientId=(Select SyncClientId From Bean.Entity Where Id=@EntityId And CompanyId=@CompanyId)
						Update C  Set C.Name=E.Name,C.ClientTypeId=E.TypeId,C.IdtypeId=E.IdTypeId,C.ClientIdNo=E.IdNo,C.RecOrder=E.RecOrder,C.Remarks=E.Remarks,C.ModifiedBy=@UserCreatedOrModified,C.ModifiedDate=@GetDate,C.Communication=E.Communication,SyncEntitydate=@GetDate,SyncEntityStatus=@SyncStatusUpdateCompleted,c.IndustryCode=E.IndustryCode,c.Industry=e.Industry,c.PrincipalActivities=e.PrincipalActivities
						From WorkFlow.Client As C
						Inner Join Bean.Entity As E On E.Id=C.SyncEntityId
						Where C.CompanyId=@CompanyId And E.Id=@EntityId

						Update Bean.Entity Set SyncClientDate=@GetDate,SyncClientStatus=@SyncStatusUpdateCompleted 
						Where CompanyId=@CompanyId And Id=@EntityId
						/*
						--ContactDetails From Entity
						Begin
							Set @IndCount=1
							Set @Count=0
							Insert into #Loc_Cont_Tbl
							Select Distinct Cd.Id As ContactDetailId,CD.EntityType,CD.ContactId,CD.EntityId,A.SyncClientId From Common.ContactDetails As CD
							Inner Join Bean.Entity As A On A.Id=CD.EntityId
							Inner Join Common.Contact As C On C.Id=CD.ContactId 
							Where A.CompanyId=@CompanyId And A.SyncClientId=@ClientId
							Select @Count=count(*) From #Loc_Cont_Tbl
							While @Count>=@IndCount
							Begin
								Select @ContactDetailId=ContactDetailId,@ContactId=ContactId,@CDEntityId=EntityId,@SyncClientId=DestId From #Loc_Cont_Tbl Where Id=@IndCount
								If Not Exists (Select Id From Common.ContactDetails Where ContactId=@ContactId And EntityId=@SyncClientId)
								Begin
									Set @New_ContctDtlId=NewId()
									Insert Into Common.ContactDetails (Id,ContactId,EntityId,EntityType,Designation,Communication,Matters,IsPrimaryContact,IsReminderReceipient,RecOrder,OtherDesignation,IsPinned,CursorShortCode,Status,UserCreated,CreatedDate,Remarks,DocId,DocType,IsCopy)
										Select @New_ContctDtlId,@ContactId,@SyncClientId,'Client',Designation,Communication,Matters,IsPrimaryContact,IsReminderReceipient,RecOrder,OtherDesignation,IsPinned,'WF',Status,@UserCreatedOrModified,@Getdate,Remarks,@CDEntityId,'Bean',IsCopy From Common.ContactDetails Where Id=@ContactDetailId
								End
								Else
								Begin
									Update A Set A.Designation=B.Designation,A.Communication=B.Communication,A.IsPrimaryContact=B.IsPrimaryContact,A.Matters=B.Matters,A.RecOrder=B.RecOrder,A.Status=B.Status,A.IsReminderReceipient=B.IsReminderReceipient,ModifiedBy=@UserCreatedOrModified,ModifiedDate=@GetDate,A.Remarks=B.Remarks,A.IsCopy=b.IsCopy From Common.ContactDetails As A
									Inner Join 
									(Select * From Common.ContactDetails Where EntityId=@EntityId And ContactId=@ContactId) As B On B.ContactId=A.ContactId
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
							Where A.CompanyId=@CompanyId And A.SyncEntityId=@EntityId
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
						*/
						--Addresses From Entity
						Begin
							Set @IndCount=1
							Insert into #Loc_AdrsTbl
							Select Distinct Adrs.id As AddressId,Adrs.AddressBookId,Adrs.AddSectionType,Adrs.AddTypeId,A.SyncClientId From Common.Addresses As Adrs
							Inner join Bean.Entity As A On A.Id=Adrs.AddTypeId 
							Where A.CompanyId=@CompanyId And A.SyncClientId=@ClientId
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
							Select Distinct Adrs.id As AddressId,Adrs.AddressBookId,Adrs.AddSectionType,Adrs.AddTypeId,A.SyncEntityId From Common.Addresses As Adrs
							Inner join WorkFlow.Client As A On A.Id=Adrs.AddTypeId 
							Where A.CompanyId=@CompanyId And A.SyncEntityId=@EntityId
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
						/*
						--ContactDetail From Entity
						Begin
							Set @IndCount=1
							Insert into #Loc_AdrsTbl
							Select Distinct Adrs.id As AddressId,Adrs.AddressBookId,Adrs.AddSectionType,Adrs.AddTypeId,A.EntityId As EntityId From Common.Addresses As Adrs
							Inner join Common.ContactDetails As A On A.Id=Adrs.AddTypeId 
							Where A.EntityId In (Select Id From Bean.Entity Where CompanyId=@CompanyId And SyncClientId=@ClientId)
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
						--ContactDetail From Client
						Begin
							Set @IndCount=1
							Insert into #Loc_AdrsTbl
							Select Distinct Adrs.id As AddressId,Adrs.AddressBookId,Adrs.AddSectionType,Adrs.AddTypeId,A.EntityId As ClientId From Common.Addresses As Adrs
							Inner join Common.ContactDetails As A On A.Id=Adrs.AddTypeId 
							Where A.EntityId In (Select Id From WorkFlow.Client Where CompanyId=@CompanyId And SyncEntityId=@EntityId)
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
						*/
					End Try
					Begin catch
						Declare @UpdtErrMsg Nvarchar(Max)
						Set @UpdtErrMsg=(Select ERROR_MESSAGE())
						Update Bean.Entity Set SyncClientDate=@GetDate,SyncClientStatus=@SyncStatusUpdateFalied,SyncClientRemarks=@UpdtErrMsg Where Id=@EntityId And CompanyId=@CompanyId
					End Catch
				End
			/*	Else
				Begin
					Exec [dbo].[Common_Sync_MasterData_Entity_Client] @CompanyId,@EntityId,'Add'
				End */
			End
			Else If(@Action='Active' OR @Action='InActive')
			Begin
				If Exists (Select Id From WorkFlow.Client Where SyncEntityId=@EntityId And CompanyId=@CompanyId)
				Begin
					Begin Try
						Update WorkFlow.Client Set ClientStatus=@Action,Status = Case When @Action='Active' Then 1 When @Action='Inactive' Then 2 End ,ModifiedBy=@UserCreatedOrModified,ModifiedDate=@GetDate,SyncEntityDate=@GetDate,SyncEntityStatus=@SyncStatusUpdateCompleted
						Where SyncEntityId= @EntityId And CompanyId=@CompanyId
						Update Bean.Entity Set SyncClientDate=@GetDate,SyncClientId=@ClientId,SyncClientStatus=@SyncStatusUpdateCompleted,SyncClientRemarks=null Where CompanyId=@CompanyId And Id=@EntityId

					End Try
					Begin Catch
						Declare @ActErrMsg Nvarchar(Max)
						Set @ActErrMsg=(Select ERROR_MESSAGE())
						Update Bean.Entity Set SyncClientDate=@GetDate,SyncClientStatus=@SyncStatusUpdateFalied,SyncClientRemarks=@ActErrMsg Where Id=@EntityId And CompanyId=@CompanyId
					End Catch
				End
			End
			Set @SystemRefnum=(Select Top(1) SystemRefNo From WorkFlow.Client Where CompanyId=@CompanyId And SystemRefNo Is not null Order By CreatedDate Desc)
			Set @SystemRefnum=Reverse(SUBSTRING(Reverse(@SystemRefnum),0,PATINDEX('%[0-9][^0-9]%', Reverse(@SystemRefnum))+1))
			Update Common.AutoNumber Set GeneratedNumber=@SystemRefnum Where CompanyId=@CompanyId And EntityType='WorkFlow Client' And ModuleMasterId=(Select Id From Common.ModuleMaster Where Name='Workflow Cursor')

			
			Drop table #Loc_Cont_Tbl
			Drop table #Loc_AdrsTbl
			Commit Transaction
		End Try

		Begin Catch
			Rollback Transaction;
			Print Error_Message()
		End Catch
	End
End


GO
