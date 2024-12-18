USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[Common_Sync_MasterData_Client_Entity]    Script Date: 16-12-2024 9.20.10 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


--Exec  [dbo].[Common_Sync_MasterData_Client_Entity] 237,'B3499922-C513-4AFA-ADE9-6D22894CC42D','Add'
CREATE Procedure [dbo].[Common_Sync_MasterData_Client_Entity]
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
			@EntityId Uniqueidentifier,
			@IndCount Int,
			@Count Int,
			@ContactId Uniqueidentifier,
			@CDEntityId Uniqueidentifier,
			@SyncEntityId Uniqueidentifier,
			@AdrsCount int,
			@AddressBookId Uniqueidentifier,
			@AdrsEntityId Uniqueidentifier,
			@AdrsSyncEntityId Uniqueidentifier,
			@ContactDetailId Uniqueidentifier,
			@New_ContctDtlId Uniqueidentifier,
			@SyncClientId Uniqueidentifier,
			@AddrsAddSecType Nvarchar(200),
			@AddressId Uniqueidentifier,
			@AdrsSyncClientId Uniqueidentifier,
			@CntDtlDestId Uniqueidentifier,
			@CntdtlEntityId Uniqueidentifier
		Set @UserCreatedOrModified='System'
		Set @GetDate=Getutcdate()
		Set @SyncStatusCompleted='Completed'
		Set @SyncStatusUpdateCompleted='UpdateCompleted'
		Set @SyncStatusUpdateFalied='UpdateFailed'
		Set @IsExternalData=1
		Set @CustNature='Trade'
		Set @SyncStatusFailed='Failed'

	--Declare Temp Table variable to store contact deatils
	Create Table #Loc_Cont_Tbl (Id Int Identity(1,1),ContactDetailId Uniqueidentifier,EntityType Nvarchar(200),ContactId Uniqueidentifier,EntityId Uniqueidentifier,DestId Uniqueidentifier)
	--Declare Temp Table variable to store Addresses deatils
	Create Table #Loc_AdrsTbl (Id Int Identity(1,1),AddressId Uniqueidentifier,AddressBookId Uniqueidentifier,AddSectionType NVarchar(100),AdrsEntityId Uniqueidentifier,DestId Uniqueidentifier)

	Select @BaseCurrency=BaseCurrency from bean.FinancialSetting where CompanyId=@CompanyId

	If @BaseCurrency is null Set @BaseCurrency='SGD'
--Begin Transaction
Begin Transaction
	--Try Block For Whole Transaction
	Begin Try
		If(@Action='Add')
		Begin
			If Not Exists (Select Id From Bean.Entity Where CompanyId=@CompanyId And SyncClientId=@ClientId)
			Begin
				Begin Try
					Set @EntityId=NEWID()
					Insert Into Bean.Entity (Id,CompanyId,Name,TypeId,IdTypeId,IdNo,IsCustomer,CustTOPId,CustCurrency,CustNature,RecOrder,Remarks,UserCreated,CreatedDate,Status,IsExternalData,IsShowPayroll,Communication,ExternalEntityType,SyncClientId,SyncClientDate,SyncClientStatus,SyncClientRemarks,DocumentId,Industry,IndustryCode,PrincipalActivities)
						Select @EntityId,@CompanyId,Name,ClientTypeId,IdtypeId,ClientIdNo,1,Case when TermsOfPaymentId is not null then TermsOfPaymentId else (select id from common.termsofpayment where companyid=@companyId and name='Credit - 0') end,
								@BaseCurrency,@CustNature,RecOrder,Remarks,@UserCreatedOrModified,@GetDate,Status,1,1 ,Communication,'Client',Id,@GetDate,@SyncStatusCompleted,null,@ClientId,Industry,IndustryCode,PrincipalActivities
						From WorkFlow.Client 
						Where CompanyId=@CompanyId And Id=@ClientId
					Update WorkFlow.Client Set SyncEntityId=@EntityId,SyncEntitydate=@GetDate,SyncEntityStatus=@SyncStatusCompleted,SyncEntityRemarks=null Where Id=@ClientId And CompanyId=@CompanyId
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
								Set @New_ContctDtlId=NewId()
								Insert Into Common.ContactDetails (Id,ContactId,EntityId,EntityType,Designation,Communication,Matters,IsPrimaryContact,IsReminderReceipient,RecOrder,OtherDesignation,IsPinned,CursorShortCode,Status,UserCreated,CreatedDate,Remarks,DocId,DocType,IsCopy)
									Select @New_ContctDtlId,@ContactId,@SyncEntityId,'Entity',Designation,Communication,Matters,IsPrimaryContact,IsReminderReceipient,RecOrder,OtherDesignation,IsPinned,'Bean',Status,@UserCreatedOrModified,@Getdate,Remarks,@CDEntityId,'Client',IsCopy From Common.ContactDetails Where Id=@ContactDetailId
							End
							Else
							Begin
								Update A Set A.Designation=B.Designation,A.Communication=B.Communication,A.IsPrimaryContact=B.IsPrimaryContact,A.Matters=B.Matters,A.RecOrder=B.RecOrder,A.Status=B.Status,A.IsReminderReceipient=B.IsReminderReceipient,ModifiedBy=@UserCreatedOrModified,ModifiedDate=@GetDate,A.Remarks=B.Remarks,A.IsCopy=B.IsCopy From Common.ContactDetails As A
								Inner Join 
								(Select * From Common.ContactDetails Where EntityId=@ClientId And ContactId=@ContactId) As B On B.ContactId=A.ContactId
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
						Select Distinct Adrs.id As AddressId,Adrs.AddressBookId,Adrs.AddSectionType,Adrs.AddTypeId,A.SyncEntityId From Common.Addresses As Adrs
						Inner join WorkFlow.Client As A On A.Id=Adrs.AddTypeId 
						Where A.CompanyId=@CompanyId And A.SyncEntityId=@EntityId
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
						Select Distinct Adrs.id As AddressId,Adrs.AddressBookId,Adrs.AddSectionType,Adrs.AddTypeId,A.EntityId From Common.Addresses As Adrs
						Inner join Common.ContactDetails As A On A.Id=Adrs.AddTypeId 
						Where A.EntityId In (Select Id From WorkFlow.Client Where CompanyId=@CompanyId And SyncEntityId=@EntityId)
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
					--ContactDetail From Entity
					Begin
						Set @IndCount=1
						Insert into #Loc_AdrsTbl
						Select Distinct Adrs.id As AddressId,Adrs.AddressBookId,Adrs.AddSectionType,Adrs.AddTypeId,A.EntityId From Common.Addresses As Adrs
						Inner join Common.ContactDetails As A On A.Id=Adrs.AddTypeId 
						Where A.EntityId In (Select Id From Bean.Entity Where CompanyId=@CompanyId And SyncClientId=@ClientId)
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
				End Try
				Begin Catch
					Declare @ErrMsg Nvarchar(max)
					Set @ErrMsg=(Select ERROR_MESSAGE())
					Update WorkFlow.Client Set SyncEntitydate=@GetDate,SyncEntityStatus=@SyncStatusFailed,SyncEntityRemarks=@ErrMsg Where Id=@ClientId And CompanyId=@CompanyId
				End Catch
			End
			Else
			Begin
				Exec [dbo].[Common_Sync_MasterData_Client_Entity] @CompanyId,@ClientId,'Edit'
			End
		End
		--Update bean.item table records based on documentid which is edited in common.service table	
		Else If(@Action='Edit')
		Begin
			--Edit
			If Exists (Select ID From Bean.Entity Where CompanyId=@CompanyId And SyncClientId=@ClientId)
			Begin
				Begin Try
					Set @EntityId=(Select SyncEntityId From Workflow.Client Where CompanyId=@CompanyId And Id=@ClientId)
					Update E Set E.CompanyId=@CompanyId,E.Name=C.Name,E.TypeId=C.ClientTypeId,E.IdTypeId=C.IdtypeId,E.IdNo=C.ClientIdNo,E.IsCustomer=1,E.CustTOPId=Case when TermsOfPaymentId is not null then TermsOfPaymentId else (select id from common.termsofpayment where companyid=@companyId and name='Credit - 0') end,E.CustCurrency=@BaseCurrency,E.CustNature=@CustNature,E.RecOrder=C.RecOrder,E.Remarks=C.Remarks,E.ModifiedBy=@UserCreatedOrModified,E.ModifiedDate=@GetDate,E.Status=C.Status,E.IsExternalData=@IsExternalData,IsShowPayroll=1,Communication=C.Communication,E.ExternalEntityType='Client',E.SyncClientStatus=@SyncStatusUpdateCompleted,E.SyncClientDate=@GetDate,E.SyncClientRemarks=Null,E.Industry=C.Industry,E.IndustryCode=C.IndustryCode,E.PrincipalActivities=C.PrincipalActivities
					From Bean.Entity As E
					Inner Join WorkFlow.Client As C On C.Id=E.SyncClientId
					Where E.CompanyId=@CompanyId And C.Id=@ClientId

					Update WorkFlow.Client Set SyncEntitydate=@GetDate,SyncEntityStatus=@SyncStatusUpdateCompleted,SyncEntityRemarks=null Where CompanyId=@CompanyId And ID=@ClientId
					/*
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
								Set @New_ContctDtlId=NewId()
								Insert Into Common.ContactDetails (Id,ContactId,EntityId,EntityType,Designation,Communication,Matters,IsPrimaryContact,IsReminderReceipient,RecOrder,OtherDesignation,IsPinned,CursorShortCode,Status,UserCreated,CreatedDate,Remarks,DocId,DocType,IsCopy)
									Select @New_ContctDtlId,@ContactId,@SyncEntityId,'Entity',Designation,Communication,Matters,IsPrimaryContact,IsReminderReceipient,RecOrder,OtherDesignation,IsPinned,'Bean',Status,@UserCreatedOrModified,@Getdate,Remarks,@CDEntityId,'Client',IsCopy From Common.ContactDetails Where Id=@ContactDetailId
							End
							Else
							Begin
								Update A Set A.Designation=B.Designation,A.Communication=B.Communication,A.IsPrimaryContact=B.IsPrimaryContact,A.Matters=B.Matters,A.RecOrder=B.RecOrder,A.Status=B.Status,A.IsReminderReceipient=B.IsReminderReceipient,ModifiedBy=@UserCreatedOrModified,ModifiedDate=@GetDate,A.Remarks=B.Remarks,A.IsCopy=B.IsCopy From Common.ContactDetails As A
								Inner Join 
								(Select * From Common.ContactDetails Where EntityId=@ClientId And ContactId=@ContactId) As B On B.ContactId=A.ContactId
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
						Select Distinct Adrs.id As AddressId,Adrs.AddressBookId,Adrs.AddSectionType,Adrs.AddTypeId,A.SyncEntityId From Common.Addresses As Adrs
						Inner join WorkFlow.Client As A On A.Id=Adrs.AddTypeId 
						Where A.CompanyId=@CompanyId And A.SyncEntityId=@EntityId
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
						Select Distinct Adrs.id As AddressId,Adrs.AddressBookId,Adrs.AddSectionType,Adrs.AddTypeId,A.EntityId From Common.Addresses As Adrs
						Inner join Common.ContactDetails As A On A.Id=Adrs.AddTypeId 
						Where A.EntityId In (Select Id From WorkFlow.Client Where CompanyId=@CompanyId And SyncEntityId=@EntityId)
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
					--ContactDetail From Entity
					Begin
						Set @IndCount=1
						Insert into #Loc_AdrsTbl
						Select Distinct Adrs.id As AddressId,Adrs.AddressBookId,Adrs.AddSectionType,Adrs.AddTypeId,A.EntityId From Common.Addresses As Adrs
						Inner join Common.ContactDetails As A On A.Id=Adrs.AddTypeId 
						Where A.EntityId In (Select Id From Bean.Entity Where CompanyId=@CompanyId And SyncClientId=@ClientId)
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
					*/
				End Try
				Begin catch
					Declare @UpdtErrMsg Nvarchar(Max)
					Set @UpdtErrMsg=(Select ERROR_MESSAGE())
					Update WorkFlow.Client Set SyncEntitydate=@GetDate,SyncEntityStatus=@SyncStatusUpdateFalied,SyncEntityRemarks=@UpdtErrMsg Where Id=@ClientId And CompanyId=@CompanyId
				End Catch
			End
		/*	Else
			Begin
				Exec [dbo].[Common_Sync_MasterData_Client_Entity] @CompanyId,@ClientId,'Add'
			End */
		End
		Else If(@Action='Active' OR @Action='Inactive')
		Begin
			If Exists (Select Id From Bean.Entity Where SyncClientId=@ClientId And CompanyId=@CompanyId)
			Begin
				Begin Try
					Update Bean.Entity Set Status = Case When @Action='Active' Then 1 When @Action='Inactive' Then 2 End ,ModifiedBy=@UserCreatedOrModified,ModifiedDate=@GetDate,SyncClientStatus=@SyncStatusUpdateCompleted,SyncClientDate=@GetDate,SyncClientRemarks=null Where SyncClientId= @ClientId And CompanyId=@CompanyId
					Update WorkFlow.Client Set SyncEntitydate=@GetDate,SyncEntityStatus=@SyncStatusUpdateCompleted,SyncEntityRemarks=null Where Id=@ClientId And CompanyId=@CompanyId
				End Try
				Begin Catch
					Declare @ActErrMsg Nvarchar(Max)
					Set @ActErrMsg=(Select ERROR_MESSAGE())
					Update WorkFlow.Client Set SyncEntitydate=@GetDate,SyncEntityStatus=@SyncStatusUpdateFalied,SyncEntityRemarks=@ActErrMsg Where Id=@ClientId And CompanyId=@CompanyId
				End Catch
			End
		End
		Drop table #Loc_Cont_Tbl
		Drop table #Loc_AdrsTbl
		Commit Transaction
	End Try

	Begin Catch
	Rollback Transaction;
	End Catch

End


GO
