USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[Common_Sync_Contact_Sp]    Script Date: 16-12-2024 9.20.10 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE Procedure [dbo].[Common_Sync_Contact_Sp]
@SourceId Uniqueidentifier,
@SourceType Varchar(50),
@ContactId Uniqueidentifier,
@Type Varchar(20)
As
Begin
	Declare @SyncClientId Uniqueidentifier,
			@SyncEntityId Uniqueidentifier,
			@SyncAccountId Uniqueidentifier,
			@ContactDetailId Uniqueidentifier,
			@New_ContctDtlId Uniqueidentifier,
			@UserCreatedOrModified Varchar(20),
			@Getdate Datetime2,
			@AddressBookId Uniqueidentifier, --- new add
			@IndCount Int,
			@Count Int,
			@AdrsCount Int,
			@AddressId Uniqueidentifier,
			@AdrsEntityId Uniqueidentifier,
			@AddrsAddSecType Nvarchar(200),
			@CntDtlDestId Uniqueidentifier
		Set @UserCreatedOrModified='System'
		Set @Getdate=GETUTCDATE()
	if object_id('tempdb..#Loc_Cont_Tbl', 'U') is null
	Create Table #Loc_Cont_Tbl (Id Int Identity(1,1),ContactDetailId Uniqueidentifier,EntityType Nvarchar(200),ContactId Uniqueidentifier,EntityId Uniqueidentifier,DestId Uniqueidentifier)
	--Declare Temp Table variable to store Addresses deatils
	if object_id('tempdb..#Loc_AdrsTbl', 'U') is null
	Create Table #Loc_AdrsTbl (Id Int Identity(1,1),AddressId Uniqueidentifier,AddressBookId Uniqueidentifier,AddSectionType NVarchar(100),AdrsEntityId Uniqueidentifier,DestId Uniqueidentifier)

	Declare @Temp Table(AddressBookid Uniqueidentifier)
	Begin Transaction
	Begin Try
		If @Type='Add'
		Begin
			If @SourceType ='Account'
			Begin
				Set @SyncClientId=(Select SyncClientId From ClientCursor.Account Where Id=@SourceId)
				Set @SyncEntityId=(Select SyncEntityId From ClientCursor.Account Where Id=@SourceId)
				If @SyncClientId Is Not Null
				Begin
					--Contact From Account
					Begin
						Set @IndCount=1
						Set @Count=0
						Insert into #Loc_Cont_Tbl
						Select Distinct Cd.Id As ContactDetailId,CD.EntityType,CD.ContactId,CD.EntityId,B.SyncClientId From Common.ContactDetails As CD
						Inner Join ClientCursor.Account As B On B.Id=CD.EntityId
						Inner Join Common.Contact As C On C.Id=CD.ContactId 
						Where C.Id=@ContactId And CD.EntityId=@SourceId
						Select @Count=count(*) From #Loc_Cont_Tbl
						While @Count>=@IndCount
						Begin
							Select @ContactDetailId=ContactDetailId From #Loc_Cont_Tbl Where Id=@IndCount
							If Not Exists (Select Id From Common.ContactDetails Where ContactId=@ContactId And EntityId=@SyncClientId)
							Begin

							If  Exists (Select Id From Common.ContactDetails Where ContactId=@ContactId And EntityId=@SourceId and IsPrimaryContact=1)
							Begin
							
							Update A SET IsPrimaryContact=0 FROM 
							Common.ContactDetails A Where ContactId<>@ContactId And EntityId=@SyncClientId and IsPrimaryContact=1
							end
								Set @New_ContctDtlId=NewId()
								Insert Into Common.ContactDetails (Id,ContactId,EntityId,EntityType,Designation,Communication,Matters,IsPrimaryContact,IsReminderReceipient,RecOrder,OtherDesignation,IsPinned,CursorShortCode,Status,UserCreated,CreatedDate,Remarks,DocId,DocType,IsCopy)
									Select @New_ContctDtlId,@ContactId,@SyncClientId,'Client',Designation,Communication,Matters,IsPrimaryContact,IsReminderReceipient,RecOrder,OtherDesignation,IsPinned,'WF',Status,@UserCreatedOrModified,@Getdate,Remarks,@SourceId,'Account',IsCopy From Common.ContactDetails Where Id=@ContactDetailId
							End
							Else
							Begin
								Update A Set A.Designation=B.Designation,A.Communication=B.Communication,A.IsPrimaryContact=B.IsPrimaryContact,A.Matters=B.Matters,A.RecOrder=B.RecOrder,A.Status=B.Status,A.IsReminderReceipient=B.IsReminderReceipient,ModifiedBy=@UserCreatedOrModified,ModifiedDate=@GetDate,A.Remarks=B.Remarks,A.IsCopy=B.IsCopy From Common.ContactDetails As A
								Inner Join 
								(Select * From Common.ContactDetails Where EntityId=@SourceId And ContactId=@ContactId) As B On B.ContactId=A.ContactId
								Where A.ContactId=@ContactId And A.EntityId=@SyncClientId
							End
							Set @IndCount=@IndCount+1
						End
						Truncate Table #Loc_Cont_Tbl
					End 
					--Addresses From Account
					Begin
						Set @IndCount=1
						Insert into #Loc_AdrsTbl
						Select Distinct Adrs.id As AddressId,Adrs.AddressBookId,Adrs.AddSectionType,Adrs.AddTypeId,Newid() From Common.Addresses As Adrs
						--Inner Join ClientCursor.
						Where AddTypeId=@SourceId
						Select @AdrsCount=count(*) From #Loc_AdrsTbl
						While @AdrsCount>=@IndCount
						Begin
							Select @AddressId=AddressId,@AddressBookId=AddressBookId,@AddrsAddSecType=AddSectionType From #Loc_AdrsTbl Where Id=@IndCount
							If Not Exists (Select Id From Common.Addresses Where Addsectiontype=@AddrsAddSecType And AddTypeId=@SyncClientId And AddressBookId=@AddressBookId/*And CompanyId=@CompanyId*/)
							Begin
								Insert Into Common.Addresses(Id,AddSectionType,AddType,AddTypeId,AddTypeIdInt,AddressBookId,Status,DocumentId,EntityId,ScreenName,IsCurrentAddress,CompanyId)
									Select NEWID(),AddSectionType,'Client',@SyncClientId,AddTypeIdInt,AddressBookId,Status,@SourceId,null,null,IsCurrentAddress,CompanyId From Common.Addresses Where Id=@AddressId /*And CompanyId=@CompanyId*/
							End
							Set @IndCount=@IndCount+1
						End
						Truncate Table #Loc_AdrsTbl
					End 
					-- Contact Detail Address
					Begin
						Set @IndCount=1
						Insert into #Loc_AdrsTbl
						Select Distinct Adrs.id As AddressId,Adrs.AddressBookId,Adrs.AddSectionType,Adrs.AddTypeId,Newid() From Common.Addresses As Adrs
						Inner join Common.ContactDetails As A On A.Id=Adrs.AddTypeId 
						Where A.EntityId=@SourceId And A.ContactId=@ContactId
						Select @AdrsCount=count(*) From #Loc_AdrsTbl
						While @AdrsCount>=@IndCount
						Begin
							Select @AddressId=AddressId,@AddressBookId=AddressBookId,@AddrsAddSecType=AddSectionType,@AdrsEntityId=AdrsEntityId From #Loc_AdrsTbl Where Id=@IndCount
							--Select @ContactId=ContactId,@SyncAccountId=EntityId From Common.ContactDetails Where Id=@AdrsEntityId
							If @ContactId Is Not null And @SourceId Is Not Null
							Begin
								If @SyncClientId Is Not Null
								Begin
									Select @CntDtlDestId=Id From Common.ContactDetails Where EntityId=@SyncClientId And ContactId=@ContactId
									If Not Exists (Select Id From Common.Addresses Where Addsectiontype=@AddrsAddSecType And AddTypeId=@CntDtlDestId And AddressBookId=@AddressBookId/*And CompanyId=@CompanyId*/)
									Begin
										Insert Into Common.Addresses(Id,AddSectionType,AddType,AddTypeId,AddTypeIdInt,AddressBookId,Status,DocumentId,EntityId,ScreenName,IsCurrentAddress,CompanyId)
											Select NEWID(),AddSectionType,'ClientContactDetail',@CntDtlDestId,AddTypeIdInt,AddressBookId,Status,@AdrsEntityId,null,null,IsCurrentAddress,CompanyId From Common.Addresses Where Id=@AddressId /*And CompanyId=@CompanyId*/
									End
								End
							End
							Set @IndCount=@IndCount+1
						End
						Truncate Table #Loc_AdrsTbl
					End 
				End
				If @SyncEntityId Is Not Null
				Begin
					--Contact From Account
					Begin
						Set @IndCount=1
						Set @Count=0
						Insert into #Loc_Cont_Tbl
						Select Distinct Cd.Id As ContactDetailId,CD.EntityType,CD.ContactId,CD.EntityId,Newid() From Common.ContactDetails As CD
						Inner Join Common.Contact As C On C.Id=CD.ContactId 
						Where C.Id=@ContactId And CD.EntityId=@SourceId
						Select @Count=count(*) From #Loc_Cont_Tbl
						While @Count>=@IndCount
						Begin
							Select @ContactDetailId=ContactDetailId From #Loc_Cont_Tbl Where Id=@IndCount
							If Not Exists (Select Id From Common.ContactDetails Where ContactId=@ContactId And EntityId=@SyncEntityId)
							Begin

								If  Exists (Select Id From Common.ContactDetails Where ContactId=@ContactId And EntityId=@SourceId and IsPrimaryContact=1)
							Begin
							
							Update A SET IsPrimaryContact=0 FROM 
							Common.ContactDetails A Where ContactId<>@ContactId And EntityId=@SyncEntityId and IsPrimaryContact=1
							end



								Set @New_ContctDtlId=NewId()
								Insert Into Common.ContactDetails (Id,ContactId,EntityId,EntityType,Designation,Communication,Matters,IsPrimaryContact,IsReminderReceipient,RecOrder,OtherDesignation,IsPinned,CursorShortCode,Status,UserCreated,CreatedDate,Remarks,DocId,DocType,IsCopy)
									Select @New_ContctDtlId,@ContactId,@SyncEntityId,'Entity',Designation,Communication,Matters,IsPrimaryContact,IsReminderReceipient,RecOrder,OtherDesignation,IsPinned,'BC',Status,@UserCreatedOrModified,@Getdate,Remarks,@SourceId,'Account',IsCopy From Common.ContactDetails Where Id=@ContactDetailId
							End
							Else
							Begin
								Update A Set A.Designation=B.Designation,A.Communication=B.Communication,A.IsPrimaryContact=B.IsPrimaryContact,A.Matters=B.Matters,A.RecOrder=B.RecOrder,A.Status=B.Status,A.IsReminderReceipient=B.IsReminderReceipient,ModifiedBy=@UserCreatedOrModified,ModifiedDate=@GetDate,A.Remarks=B.Remarks,A.IsCopy=B.IsCopy From Common.ContactDetails As A
								Inner Join 
								(Select * From Common.ContactDetails Where EntityId=@SourceId And ContactId=@ContactId) As B On B.ContactId=A.ContactId
								Where A.ContactId=@ContactId And A.EntityId=@SyncEntityId
							End
							Set @IndCount=@IndCount+1
						End
						Truncate Table #Loc_Cont_Tbl
					End 
					--Addresses From Account
					Begin
						Set @IndCount=1
						Insert into #Loc_AdrsTbl
						Select Distinct Adrs.id As AddressId,Adrs.AddressBookId,Adrs.AddSectionType,Adrs.AddTypeId,Newid() From Common.Addresses As Adrs
						Where AddTypeId=@SourceId
						Select @AdrsCount=count(*) From #Loc_AdrsTbl
						While @AdrsCount>=@IndCount
						Begin
							Select @AddressId=AddressId,@AddressBookId=AddressBookId,@AddrsAddSecType=AddSectionType From #Loc_AdrsTbl Where Id=@IndCount
							If Not Exists (Select Id From Common.Addresses Where Addsectiontype=@AddrsAddSecType And AddTypeId=@SyncEntityId And AddressBookId=@AddressBookId/*And CompanyId=@CompanyId*/)
							Begin
								Insert Into Common.Addresses(Id,AddSectionType,AddType,AddTypeId,AddTypeIdInt,AddressBookId,Status,DocumentId,EntityId,ScreenName,IsCurrentAddress,CompanyId)
									Select NEWID(),AddSectionType,'Entity',@SyncEntityId,AddTypeIdInt,AddressBookId,Status,@SourceId,null,null,IsCurrentAddress,CompanyId From Common.Addresses Where Id=@AddressId /*And CompanyId=@CompanyId*/
							End
							Set @IndCount=@IndCount+1
						End
						Truncate Table #Loc_AdrsTbl
					End 
					-- Contact Detail Address
					Begin
						Set @IndCount=1
						Insert into #Loc_AdrsTbl
						Select Distinct Adrs.id As AddressId,Adrs.AddressBookId,Adrs.AddSectionType,Adrs.AddTypeId,Newid() From Common.Addresses As Adrs
						Inner join Common.ContactDetails As A On A.Id=Adrs.AddTypeId 
						Where A.EntityId=@SourceId And A.ContactId=@ContactId
						Select @AdrsCount=count(*) From #Loc_AdrsTbl
						While @AdrsCount>=@IndCount
						Begin
							Select @AddressId=AddressId,@AddressBookId=AddressBookId,@AddrsAddSecType=AddSectionType,@AdrsEntityId=AdrsEntityId From #Loc_AdrsTbl Where Id=@IndCount
							--Select @ContactId=ContactId,@SyncAccountId=EntityId From Common.ContactDetails Where Id=@AdrsEntityId
							If @ContactId Is Not null And @SourceId Is Not Null
							Begin
								If @SyncEntityId Is Not Null
								Begin
									Select @CntDtlDestId=Id From Common.ContactDetails Where EntityId=@SyncEntityId And ContactId=@ContactId
									If Not Exists (Select Id From Common.Addresses Where Addsectiontype=@AddrsAddSecType And AddTypeId=@CntDtlDestId And AddressBookId=@AddressBookId/*And CompanyId=@CompanyId*/)
									Begin
										Insert Into Common.Addresses(Id,AddSectionType,AddType,AddTypeId,AddTypeIdInt,AddressBookId,Status,DocumentId,EntityId,ScreenName,IsCurrentAddress,CompanyId)
											Select NEWID(),AddSectionType,'ClientContactDetail',@CntDtlDestId,AddTypeIdInt,AddressBookId,Status,@AdrsEntityId,null,null,IsCurrentAddress,CompanyId From Common.Addresses Where Id=@AddressId /*And CompanyId=@CompanyId*/
									End
								End
							End
							Set @IndCount=@IndCount+1
						End
						Truncate Table #Loc_AdrsTbl
					End
				End
			End
			Else If @SourceType ='Client'
			Begin
				Set @SyncAccountId=(Select SyncAccountId From Workflow.Client Where Id=@SourceId)
				Set @SyncEntityId=(Select SyncEntityId From Workflow.Client Where Id=@SourceId)
				If @SyncAccountId Is Not Null
				Begin
					--Contact From Client
					Begin
						Set @IndCount=1
						Set @Count=0
						Insert into #Loc_Cont_Tbl
						Select Distinct Cd.Id As ContactDetailId,CD.EntityType,CD.ContactId,CD.EntityId,Newid() From Common.ContactDetails As CD
						Inner Join Common.Contact As C On C.Id=CD.ContactId 
						Where C.Id=@ContactId And CD.EntityId=@SourceId
						Select @Count=count(*) From #Loc_Cont_Tbl
						While @Count>=@IndCount
						Begin
							Select @ContactDetailId=ContactDetailId From #Loc_Cont_Tbl Where Id=@IndCount
							If Not Exists (Select Id From Common.ContactDetails Where ContactId=@ContactId And EntityId=@SyncAccountId)
							Begin

								If  Exists (Select Id From Common.ContactDetails Where ContactId=@ContactId And EntityId=@SourceId and IsPrimaryContact=1)
							Begin
							
							Update A SET IsPrimaryContact=0 FROM 
							Common.ContactDetails A Where ContactId<>@ContactId And EntityId=@SyncAccountId and IsPrimaryContact=1
							end

								Set @New_ContctDtlId=NewId()
								Insert Into Common.ContactDetails (Id,ContactId,EntityId,EntityType,Designation,Communication,Matters,IsPrimaryContact,IsReminderReceipient,RecOrder,OtherDesignation,IsPinned,CursorShortCode,Status,UserCreated,CreatedDate,Remarks,DocId,DocType,IsCopy)
									Select @New_ContctDtlId,@ContactId,@SyncAccountId,'Account',Designation,Communication,Matters,IsPrimaryContact,IsReminderReceipient,RecOrder,OtherDesignation,IsPinned,'CC',Status,@UserCreatedOrModified,@Getdate,Remarks,@SourceId,'Client',IsCopy From Common.ContactDetails Where Id=@ContactDetailId
							End
							Else
							Begin
								Update A Set A.Designation=B.Designation,A.Communication=B.Communication,A.IsPrimaryContact=B.IsPrimaryContact,A.Matters=B.Matters,A.RecOrder=B.RecOrder,A.Status=B.Status,A.IsReminderReceipient=B.IsReminderReceipient,ModifiedBy=@UserCreatedOrModified,ModifiedDate=@GetDate,A.Remarks=B.Remarks,A.IsCopy=B.IsCopy From Common.ContactDetails As A
								Inner Join 
								(Select * From Common.ContactDetails Where EntityId=@SourceId And ContactId=@ContactId) As B On B.ContactId=A.ContactId
								Where A.ContactId=@ContactId And A.EntityId=@SyncAccountId
							End
							Set @IndCount=@IndCount+1
						End
						Truncate Table #Loc_Cont_Tbl
					End 
					--Addresses From Client
					Begin
						Set @IndCount=1
						Insert into #Loc_AdrsTbl
						Select Distinct Adrs.id As AddressId,Adrs.AddressBookId,Adrs.AddSectionType,Adrs.AddTypeId,Newid() From Common.Addresses As Adrs
						Where AddTypeId=@SourceId
						Select @AdrsCount=count(*) From #Loc_AdrsTbl
						While @AdrsCount>=@IndCount
						Begin
							Select @AddressId=AddressId,@AddressBookId=AddressBookId,@AddrsAddSecType=AddSectionType From #Loc_AdrsTbl Where Id=@IndCount
							If Not Exists (Select Id From Common.Addresses Where Addsectiontype=@AddrsAddSecType And AddTypeId=@SyncAccountId And AddressBookId=@AddressBookId/*And CompanyId=@CompanyId*/)
							Begin
								Insert Into Common.Addresses(Id,AddSectionType,AddType,AddTypeId,AddTypeIdInt,AddressBookId,Status,DocumentId,EntityId,ScreenName,IsCurrentAddress,CompanyId)
									Select NEWID(),AddSectionType,'Account',@SyncAccountId,AddTypeIdInt,AddressBookId,Status,@SourceId,null,null,IsCurrentAddress,CompanyId From Common.Addresses Where Id=@AddressId /*And CompanyId=@CompanyId*/
							End
							Set @IndCount=@IndCount+1
						End
						Truncate Table #Loc_AdrsTbl
					End 
					-- Contact Detail Address
					Begin
						Set @IndCount=1
						Insert into #Loc_AdrsTbl
						Select Distinct Adrs.id As AddressId,Adrs.AddressBookId,Adrs.AddSectionType,Adrs.AddTypeId,Newid() From Common.Addresses As Adrs
						Inner join Common.ContactDetails As A On A.Id=Adrs.AddTypeId 
						Where A.EntityId=@SourceId And A.ContactId=@ContactId
						Select @AdrsCount=count(*) From #Loc_AdrsTbl
						While @AdrsCount>=@IndCount
						Begin
							Select @AddressId=AddressId,@AddressBookId=AddressBookId,@AddrsAddSecType=AddSectionType,@AdrsEntityId=AdrsEntityId From #Loc_AdrsTbl Where Id=@IndCount
							--Select @ContactId=ContactId,@SyncAccountId=EntityId From Common.ContactDetails Where Id=@AdrsEntityId
							If @ContactId Is Not null And @SourceId Is Not Null
							Begin
								If @SyncAccountId Is Not Null
								Begin
									Select @CntDtlDestId=Id From Common.ContactDetails Where EntityId=@SyncAccountId And ContactId=@ContactId
									If Not Exists (Select Id From Common.Addresses Where Addsectiontype=@AddrsAddSecType And AddTypeId=@CntDtlDestId And AddressBookId=@AddressBookId/*And CompanyId=@CompanyId*/)
									Begin
										Insert Into Common.Addresses(Id,AddSectionType,AddType,AddTypeId,AddTypeIdInt,AddressBookId,Status,DocumentId,EntityId,ScreenName,IsCurrentAddress,CompanyId)
											Select NEWID(),AddSectionType,'AccountContactDetail',@CntDtlDestId,AddTypeIdInt,AddressBookId,Status,@AdrsEntityId,null,null,IsCurrentAddress,CompanyId From Common.Addresses Where Id=@AddressId /*And CompanyId=@CompanyId*/
									End
								End
							End
							Set @IndCount=@IndCount+1
						End
						Truncate Table #Loc_AdrsTbl
					End 
				End
				If @SyncEntityId Is Not Null
				Begin
					--Contact From Client
					Begin
						Set @IndCount=1
						Set @Count=0
						Insert into #Loc_Cont_Tbl
						Select Distinct Cd.Id As ContactDetailId,CD.EntityType,CD.ContactId,CD.EntityId,Newid() From Common.ContactDetails As CD
						Inner Join Common.Contact As C On C.Id=CD.ContactId 
						Where C.Id=@ContactId And CD.EntityId=@SourceId
						Select @Count=count(*) From #Loc_Cont_Tbl
						While @Count>=@IndCount
						Begin
							Select @ContactDetailId=ContactDetailId From #Loc_Cont_Tbl Where Id=@IndCount
							If Not Exists (Select Id From Common.ContactDetails Where ContactId=@ContactId And EntityId=@SyncEntityId)
							Begin
							If  Exists (Select Id From Common.ContactDetails Where ContactId=@ContactId And EntityId=@SourceId and IsPrimaryContact=1)
							Begin
							
							Update A SET IsPrimaryContact=0 FROM 
							Common.ContactDetails A Where ContactId<>@ContactId And EntityId=@SyncEntityId and IsPrimaryContact=1
							end

								Set @New_ContctDtlId=NewId()
								Insert Into Common.ContactDetails (Id,ContactId,EntityId,EntityType,Designation,Communication,Matters,IsPrimaryContact,IsReminderReceipient,RecOrder,OtherDesignation,IsPinned,CursorShortCode,Status,UserCreated,CreatedDate,Remarks,DocId,DocType,IsCopy)
									Select @New_ContctDtlId,@ContactId,@SyncEntityId,'Entity',Designation,Communication,Matters,IsPrimaryContact,IsReminderReceipient,RecOrder,OtherDesignation,IsPinned,'BC',Status,@UserCreatedOrModified,@Getdate,Remarks,@SourceId,'Client',IsCopy From Common.ContactDetails Where Id=@ContactDetailId
							End
							Else
							Begin
								Update A Set A.Designation=B.Designation,A.Communication=B.Communication,A.IsPrimaryContact=B.IsPrimaryContact,A.Matters=B.Matters,A.RecOrder=B.RecOrder,A.Status=B.Status,A.IsReminderReceipient=B.IsReminderReceipient,ModifiedBy=@UserCreatedOrModified,ModifiedDate=@GetDate,A.Remarks=B.Remarks,A.IsCopy=B.IsCopy From Common.ContactDetails As A
								Inner Join 
								(Select * From Common.ContactDetails Where EntityId=@SourceId And ContactId=@ContactId) As B On B.ContactId=A.ContactId
								Where A.ContactId=@ContactId And A.EntityId=@SyncEntityId
							End
							Set @IndCount=@IndCount+1
						End
						Truncate Table #Loc_Cont_Tbl
					End 
					--Addresses From Client
					Begin
						Set @IndCount=1
						Insert into #Loc_AdrsTbl
						Select Distinct Adrs.id As AddressId,Adrs.AddressBookId,Adrs.AddSectionType,Adrs.AddTypeId,Newid() From Common.Addresses As Adrs
						Where AddTypeId=@SourceId
						Select @AdrsCount=count(*) From #Loc_AdrsTbl
						While @AdrsCount>=@IndCount
						Begin
							Select @AddressId=AddressId,@AddressBookId=AddressBookId,@AddrsAddSecType=AddSectionType From #Loc_AdrsTbl Where Id=@IndCount
							If Not Exists (Select Id From Common.Addresses Where Addsectiontype=@AddrsAddSecType And AddTypeId=@SyncEntityId And AddressBookId=@AddressBookId/*And CompanyId=@CompanyId*/)
							Begin
								Insert Into Common.Addresses(Id,AddSectionType,AddType,AddTypeId,AddTypeIdInt,AddressBookId,Status,DocumentId,EntityId,ScreenName,IsCurrentAddress,CompanyId)
									Select NEWID(),AddSectionType,'Entity',@SyncEntityId,AddTypeIdInt,AddressBookId,Status,@SourceId,null,null,IsCurrentAddress,CompanyId From Common.Addresses Where Id=@AddressId /*And CompanyId=@CompanyId*/
							End
							Set @IndCount=@IndCount+1
						End
						Truncate Table #Loc_AdrsTbl
					End 
					-- Contact Detail Address
					Begin
						Set @IndCount=1
						Insert into #Loc_AdrsTbl
						Select Distinct Adrs.id As AddressId,Adrs.AddressBookId,Adrs.AddSectionType,Adrs.AddTypeId,Newid() From Common.Addresses As Adrs
						Inner join Common.ContactDetails As A On A.Id=Adrs.AddTypeId 
						Where A.EntityId=@SourceId And A.ContactId=@ContactId
						Select @AdrsCount=count(*) From #Loc_AdrsTbl
						While @AdrsCount>=@IndCount
						Begin
							Select @AddressId=AddressId,@AddressBookId=AddressBookId,@AddrsAddSecType=AddSectionType,@AdrsEntityId=AdrsEntityId From #Loc_AdrsTbl Where Id=@IndCount
							--Select @ContactId=ContactId,@SyncAccountId=EntityId From Common.ContactDetails Where Id=@AdrsEntityId
							If @ContactId Is Not null And @SourceId Is Not Null
							Begin
								If @SyncEntityId Is Not Null
								Begin
									Select @CntDtlDestId=Id From Common.ContactDetails Where EntityId=@SyncEntityId And ContactId=@ContactId
									If Not Exists (Select Id From Common.Addresses Where Addsectiontype=@AddrsAddSecType And AddTypeId=@CntDtlDestId And AddressBookId=@AddressBookId/*And CompanyId=@CompanyId*/)
									Begin
										Insert Into Common.Addresses(Id,AddSectionType,AddType,AddTypeId,AddTypeIdInt,AddressBookId,Status,DocumentId,EntityId,ScreenName,IsCurrentAddress,CompanyId)
											Select NEWID(),AddSectionType,'EntityContactDetail',@CntDtlDestId,AddTypeIdInt,AddressBookId,Status,@AdrsEntityId,null,null,IsCurrentAddress,CompanyId From Common.Addresses Where Id=@AddressId /*And CompanyId=@CompanyId*/
									End
								End
							End
							Set @IndCount=@IndCount+1
						End
						Truncate Table #Loc_AdrsTbl
					End
				End
			End
			Else If @SourceType ='Entity'
			Begin
				Set @SyncAccountId=(Select SyncAccountId From Bean.Entity Where Id=@SourceId)
				Set @SyncClientId=(Select SyncClientId From Bean.Entity Where Id=@SourceId)
				If @SyncAccountId Is Not Null
				Begin
					--Contact From Entity
					Begin
						Set @IndCount=1
						Set @Count=0
						Insert into #Loc_Cont_Tbl
						Select Distinct Cd.Id As ContactDetailId,CD.EntityType,CD.ContactId,CD.EntityId,Newid() From Common.ContactDetails As CD
						Inner Join Common.Contact As C On C.Id=CD.ContactId 
						Where C.Id=@ContactId And CD.EntityId=@SourceId
						Select @Count=count(*) From #Loc_Cont_Tbl
						While @Count>=@IndCount
						Begin
							Select @ContactDetailId=ContactDetailId From #Loc_Cont_Tbl Where Id=@IndCount
							If Not Exists (Select Id From Common.ContactDetails Where ContactId=@ContactId And EntityId=@SyncAccountId)
							Begin

						
								Set @New_ContctDtlId=NewId()
								Insert Into Common.ContactDetails (Id,ContactId,EntityId,EntityType,Designation,Communication,Matters,IsPrimaryContact,IsReminderReceipient,RecOrder,OtherDesignation,IsPinned,CursorShortCode,Status,UserCreated,CreatedDate,Remarks,DocId,DocType,IsCopy)
									Select @New_ContctDtlId,@ContactId,@SyncAccountId,'Account',Designation,Communication,Matters,IsPrimaryContact,IsReminderReceipient,RecOrder,OtherDesignation,IsPinned,'CC',Status,@UserCreatedOrModified,@Getdate,Remarks,@SourceId,'Entity',IsCopy From Common.ContactDetails Where Id=@ContactDetailId
							End
							Else
							Begin
								Update A Set A.Designation=B.Designation,A.Communication=B.Communication,A.IsPrimaryContact=B.IsPrimaryContact,A.Matters=B.Matters,A.RecOrder=B.RecOrder,A.Status=B.Status,A.IsReminderReceipient=B.IsReminderReceipient,ModifiedBy=@UserCreatedOrModified,ModifiedDate=@GetDate,A.Remarks=B.Remarks,A.IsCopy=B.IsCopy From Common.ContactDetails As A
								Inner Join 
								(Select * From Common.ContactDetails Where EntityId=@SourceId And ContactId=@ContactId) As B On B.ContactId=A.ContactId
								Where A.ContactId=@ContactId And A.EntityId=@SyncAccountId
							End
							Set @IndCount=@IndCount+1
						End
						Truncate Table #Loc_Cont_Tbl
					End 
					--Addresses From Entity
					Begin
						Set @IndCount=1
						Insert into #Loc_AdrsTbl
						Select Distinct Adrs.id As AddressId,Adrs.AddressBookId,Adrs.AddSectionType,Adrs.AddTypeId,Newid() From Common.Addresses As Adrs
						Where AddTypeId=@SourceId
						Select @AdrsCount=count(*) From #Loc_AdrsTbl
						While @AdrsCount>=@IndCount
						Begin
							Select @AddressId=AddressId,@AddressBookId=AddressBookId,@AddrsAddSecType=AddSectionType From #Loc_AdrsTbl Where Id=@IndCount
							If Not Exists (Select Id From Common.Addresses Where Addsectiontype=@AddrsAddSecType And AddTypeId=@SyncAccountId And AddressBookId=@AddressBookId/*And CompanyId=@CompanyId*/)
							Begin
								Insert Into Common.Addresses(Id,AddSectionType,AddType,AddTypeId,AddTypeIdInt,AddressBookId,Status,DocumentId,EntityId,ScreenName,IsCurrentAddress,CompanyId)
									Select NEWID(),AddSectionType,'Account',@SyncAccountId,AddTypeIdInt,AddressBookId,Status,@SourceId,null,null,IsCurrentAddress,CompanyId From Common.Addresses Where Id=@AddressId /*And CompanyId=@CompanyId*/
							End
							Set @IndCount=@IndCount+1
						End
						Truncate Table #Loc_AdrsTbl
					End 
					-- Contact Detail Address
					Begin
						Set @IndCount=1
						Insert into #Loc_AdrsTbl
						Select Distinct Adrs.id As AddressId,Adrs.AddressBookId,Adrs.AddSectionType,Adrs.AddTypeId,Newid() From Common.Addresses As Adrs
						Inner join Common.ContactDetails As A On A.Id=Adrs.AddTypeId 
						Where A.EntityId=@SourceId And A.ContactId=@ContactId
						Select @AdrsCount=count(*) From #Loc_AdrsTbl
						While @AdrsCount>=@IndCount
						Begin
							Select @AddressId=AddressId,@AddressBookId=AddressBookId,@AddrsAddSecType=AddSectionType,@AdrsEntityId=AdrsEntityId From #Loc_AdrsTbl Where Id=@IndCount
							--Select @ContactId=ContactId,@SyncAccountId=EntityId From Common.ContactDetails Where Id=@AdrsEntityId
							If @ContactId Is Not null And @SourceId Is Not Null
							Begin
								If @SyncAccountId Is Not Null
								Begin
									Select @CntDtlDestId=Id From Common.ContactDetails Where EntityId=@SyncAccountId And ContactId=@ContactId
									If Not Exists (Select Id From Common.Addresses Where Addsectiontype=@AddrsAddSecType And AddTypeId=@CntDtlDestId And AddressBookId=@AddressBookId/*And CompanyId=@CompanyId*/)
									Begin
										Insert Into Common.Addresses(Id,AddSectionType,AddType,AddTypeId,AddTypeIdInt,AddressBookId,Status,DocumentId,EntityId,ScreenName,IsCurrentAddress,CompanyId)
											Select NEWID(),AddSectionType,'AccountContactDetail',@CntDtlDestId,AddTypeIdInt,AddressBookId,Status,@AdrsEntityId,null,null,IsCurrentAddress,CompanyId From Common.Addresses Where Id=@AddressId /*And CompanyId=@CompanyId*/
									End
								End
							End
							Set @IndCount=@IndCount+1
						End
						Truncate Table #Loc_AdrsTbl
					End 
				End
				If @SyncClientId Is Not Null
				Begin
					--Contact From Entity
					Begin
						Set @IndCount=1
						Set @Count=0
						Insert into #Loc_Cont_Tbl
						Select Distinct Cd.Id As ContactDetailId,CD.EntityType,CD.ContactId,CD.EntityId,Newid() From Common.ContactDetails As CD
						Inner Join Common.Contact As C On C.Id=CD.ContactId 
						Where C.Id=@ContactId And CD.EntityId=@SourceId
						Select @Count=count(*) From #Loc_Cont_Tbl
						While @Count>=@IndCount
						Begin
							Select @ContactDetailId=ContactDetailId From #Loc_Cont_Tbl Where Id=@IndCount
							If Not Exists (Select Id From Common.ContactDetails Where ContactId=@ContactId And EntityId=@SyncClientId)
							Begin
								Set @New_ContctDtlId=NewId()
								Insert Into Common.ContactDetails (Id,ContactId,EntityId,EntityType,Designation,Communication,Matters,IsPrimaryContact,IsReminderReceipient,RecOrder,OtherDesignation,IsPinned,CursorShortCode,Status,UserCreated,CreatedDate,Remarks,DocId,DocType,IsCopy)
									Select @New_ContctDtlId,@ContactId,@SyncClientId,'Client',Designation,Communication,Matters,IsPrimaryContact,IsReminderReceipient,RecOrder,OtherDesignation,IsPinned,'WF',Status,@UserCreatedOrModified,@Getdate,Remarks,@SourceId,'Entity',IsCopy From Common.ContactDetails Where Id=@ContactDetailId
							End
							Else
							Begin
								Update A Set A.Designation=B.Designation,A.Communication=B.Communication,A.IsPrimaryContact=B.IsPrimaryContact,A.Matters=B.Matters,A.RecOrder=B.RecOrder,A.Status=B.Status,A.IsReminderReceipient=B.IsReminderReceipient,ModifiedBy=@UserCreatedOrModified,ModifiedDate=@GetDate,A.Remarks=B.Remarks,A.IsCopy=B.IsCopy From Common.ContactDetails As A
								Inner Join 
								(Select * From Common.ContactDetails Where EntityId=@SourceId And ContactId=@ContactId) As B On B.ContactId=A.ContactId
								Where A.ContactId=@ContactId And A.EntityId=@SyncClientId
							End
							Set @IndCount=@IndCount+1
						End
						Truncate Table #Loc_Cont_Tbl
					End 
					--Addresses From Entity
					Begin
						Set @IndCount=1
						Insert into #Loc_AdrsTbl
						Select Distinct Adrs.id As AddressId,Adrs.AddressBookId,Adrs.AddSectionType,Adrs.AddTypeId,Newid() From Common.Addresses As Adrs
						Where AddTypeId=@SourceId
						Select @AdrsCount=count(*) From #Loc_AdrsTbl
						While @AdrsCount>=@IndCount
						Begin
							Select @AddressId=AddressId,@AddressBookId=AddressBookId,@AddrsAddSecType=AddSectionType From #Loc_AdrsTbl Where Id=@IndCount
							If Not Exists (Select Id From Common.Addresses Where Addsectiontype=@AddrsAddSecType And AddTypeId=@SyncClientId And AddressBookId=@AddressBookId/*And CompanyId=@CompanyId*/)
							Begin
								Insert Into Common.Addresses(Id,AddSectionType,AddType,AddTypeId,AddTypeIdInt,AddressBookId,Status,DocumentId,EntityId,ScreenName,IsCurrentAddress,CompanyId)
									Select NEWID(),AddSectionType,'Client',@SyncClientId,AddTypeIdInt,AddressBookId,Status,@SourceId,null,null,IsCurrentAddress,CompanyId From Common.Addresses Where Id=@AddressId /*And CompanyId=@CompanyId*/
							End
							Set @IndCount=@IndCount+1
						End
						Truncate Table #Loc_AdrsTbl
					End 
					-- Contact Detail Address
					Begin
						Set @IndCount=1
						Insert into #Loc_AdrsTbl
						Select Distinct Adrs.id As AddressId,Adrs.AddressBookId,Adrs.AddSectionType,Adrs.AddTypeId,Newid() From Common.Addresses As Adrs
						Inner join Common.ContactDetails As A On A.Id=Adrs.AddTypeId 
						Where A.EntityId=@SourceId And A.ContactId=@ContactId
						Select @AdrsCount=count(*) From #Loc_AdrsTbl
						While @AdrsCount>=@IndCount
						Begin
							Select @AddressId=AddressId,@AddressBookId=AddressBookId,@AddrsAddSecType=AddSectionType,@AdrsEntityId=AdrsEntityId From #Loc_AdrsTbl Where Id=@IndCount
							--Select @ContactId=ContactId,@SyncAccountId=EntityId From Common.ContactDetails Where Id=@AdrsEntityId
							If @ContactId Is Not null And @SourceId Is Not Null
							Begin
								If @SyncClientId Is Not Null
								Begin
									Select @CntDtlDestId=Id From Common.ContactDetails Where EntityId=@SyncClientId And ContactId=@ContactId
									If Not Exists (Select Id From Common.Addresses Where Addsectiontype=@AddrsAddSecType And AddTypeId=@CntDtlDestId And AddressBookId=@AddressBookId/*And CompanyId=@CompanyId*/)
									Begin
										Insert Into Common.Addresses(Id,AddSectionType,AddType,AddTypeId,AddTypeIdInt,AddressBookId,Status,DocumentId,EntityId,ScreenName,IsCurrentAddress,CompanyId)
											Select NEWID(),AddSectionType,'ClientContactDetail',@CntDtlDestId,AddTypeIdInt,AddressBookId,Status,@AdrsEntityId,null,null,IsCurrentAddress,CompanyId From Common.Addresses Where Id=@AddressId /*And CompanyId=@CompanyId*/
									End
								End
							End
							Set @IndCount=@IndCount+1
						End
						Truncate Table #Loc_AdrsTbl
					End 
				End
			End
		End
		If @Type='Delete'
		Begin
			If @SourceType ='Account'
			Begin
				Set @SyncClientId=(Select SyncClientId From ClientCursor.Account Where Id=@SourceId)
				Set @SyncEntityId=(Select SyncEntityId From ClientCursor.Account Where Id=@SourceId)
				If @SyncClientId Is Not Null
				Begin
					If Exists (Select Id From Common.ContactDetails Where ContactId=@ContactId And EntityId=@SyncClientId)
					Begin
						Delete From Common.Addresses Where AddTypeId in (Select Id From Common.ContactDetails Where ContactId=@ContactId And EntityId=@SyncClientId)
						Delete From Common.ContactDetails Where ContactId=@ContactId And EntityId=@SyncClientId
					End
					Delete From Common.Addresses Where AddTypeId=@SyncClientId
				End
				If @SyncEntityId Is NOt Null
				Begin
					If Exists (Select Id From Common.ContactDetails Where ContactId=@ContactId And EntityId=@SyncEntityId)
					Begin
						Delete From Common.Addresses Where AddTypeId in (Select Id From Common.ContactDetails Where ContactId=@ContactId And EntityId=@SyncEntityId)
						Delete From Common.ContactDetails Where ContactId=@ContactId And EntityId=@SyncEntityId
					End
					Delete From Common.Addresses Where AddTypeId=@SyncEntityId 
				End
			End
			Else If @SourceType ='Client'
			Begin
				Set @SyncAccountId=(Select SyncAccountId From Workflow.Client Where Id=@SourceId)
				Set @SyncEntityId=(Select SyncEntityId From Workflow.Client Where Id=@SourceId)
				If @SyncAccountId Is Not Null
				Begin
					If Exists (Select Id From Common.ContactDetails Where ContactId=@ContactId And EntityId=@SyncAccountId)
					Begin
						Delete From Common.Addresses Where AddTypeId in (Select Id From Common.ContactDetails Where ContactId=@ContactId And EntityId=@SyncAccountId)
						Delete From Common.ContactDetails Where ContactId=@ContactId And EntityId=@SyncAccountId
					End
					Delete From Common.Addresses Where AddTypeId=@SyncAccountId
				End
				If @SyncEntityId Is NOt Null
				Begin
					If Exists (Select Id From Common.ContactDetails Where ContactId=@ContactId And EntityId=@SyncEntityId)
					Begin
						Delete From Common.Addresses Where AddTypeId in (Select Id From Common.ContactDetails Where ContactId=@ContactId And EntityId=@SyncEntityId)
						Delete From Common.ContactDetails Where ContactId=@ContactId And EntityId=@SyncEntityId
					End
					Delete From Common.Addresses Where AddTypeId=@SyncEntityId
				End
			End
			Else If @SourceType ='Entity'
			Begin
				Set @SyncAccountId=(Select SyncAccountId From Bean.Entity Where Id=@SourceId)
				Set @SyncClientId=(Select SyncClientId From Bean.Entity Where Id=@SourceId)
				If @SyncAccountId Is Not Null
				Begin
					If Exists (Select Id From Common.ContactDetails Where ContactId=@ContactId And EntityId=@SyncAccountId)
					Begin
						Delete From Common.Addresses Where AddTypeId in (Select Id From Common.ContactDetails Where ContactId=@ContactId And EntityId=@SyncAccountId)
						Delete From Common.ContactDetails Where ContactId=@ContactId And EntityId=@SyncAccountId
					End
					Delete From Common.Addresses Where AddTypeId=@SyncAccountId
				End
				If @SyncClientId Is NOt Null
				Begin
					If Exists (Select Id From Common.ContactDetails Where ContactId=@ContactId And EntityId=@SyncClientId)
					Begin
						Delete From Common.Addresses Where AddTypeId in (Select Id From Common.ContactDetails Where ContactId=@ContactId And EntityId=@SyncClientId)
						Delete From Common.ContactDetails Where ContactId=@ContactId And EntityId=@SyncClientId
					End
					Delete From Common.Addresses Where AddTypeId=@SyncClientId
				End
			End
			--Insert Into @Temp
			--Select AddressBookId  From Common.Addresses Where AddTypeId=@ContactId
						 			 
			Delete From Common.Addresses Where AddTypeId in (Select Id From Common.ContactDetails Where ContactId=@ContactId And EntityId=@SourceId)
			Delete From Common.Addresses Where AddTypeId=@SourceId
			Delete From Common.ContactDetails where ContactId=@ContactId and EntityId=@SourceId
			If Not Exists(Select Id From Common.ContactDetails Where ContactId=@ContactId)
			Begin
				Insert Into @Temp
				Select AddressBookId From Common.Addresses Where AddTypeId=@ContactId
				Delete From Common.Addresses Where AddTypeId=@ContactId
				Delete From Common.AddressBook Where Id In(Select AddressBookid From @Temp)
				Delete From Common.Contact Where Id=@ContactId
				Delete From @Temp
			End
			Insert Into @Temp
			Select AddressBookId  From Common.Addresses Where AddTypeId in (Select Id From Common.ContactDetails Where ContactId=@ContactId And EntityId=@SourceId)
			Insert Into @Temp
			Select AddressBookId  From Common.Addresses Where AddTypeId=@SourceId
			Declare AddBookId_CSR Cursor For
			Select AddressBookid From @Temp
			Open AddBookId_CSR
			Fetch Next From AddBookId_CSR Into @AddressBookId
			While @@FETCH_STATUS=0
			Begin
				Delete From Common.AddressBook Where Id=@AddressBookId And Not Exists(Select Id From Common.Addresses Where AddressBookId=@AddressBookId)
				Fetch Next From AddBookId_CSR Into @AddressBookId
			End
			Close AddBookId_CSR
			Deallocate AddBookId_CSR
		End
		If @Type='Edit'
		Begin
			If @SourceType ='Account'
			Begin
				Set @SyncClientId=(Select SyncClientId From ClientCursor.Account Where Id=@SourceId)
				Set @SyncEntityId=(Select SyncEntityId From ClientCursor.Account Where Id=@SourceId)
				If @SyncClientId Is Not Null
				Begin
					--ContactDetails From Account
					Begin
						Set @IndCount=1
						Set @Count=0
						Insert into #Loc_Cont_Tbl
						Select Distinct Cd.Id As ContactDetailId,CD.EntityType,CD.ContactId,CD.EntityId,A.SyncClientId From Common.ContactDetails As CD
						Inner Join ClientCursor.Account As A On A.Id=CD.EntityId
						Inner Join Common.Contact As C On C.Id=CD.ContactId 
						Where C.Id=@ContactId And A.Id=@SourceId
						Select @Count=count(*) From #Loc_Cont_Tbl
						While @Count>=@IndCount
						Begin
							Select @ContactDetailId=ContactDetailId From #Loc_Cont_Tbl Where Id=@IndCount
							If Exists (Select Id From Common.ContactDetails Where ContactId=@ContactId And EntityId=@SyncClientId)
							Begin
								Update A Set A.Designation=B.Designation,A.Communication=B.Communication,A.IsPrimaryContact=B.IsPrimaryContact,A.Matters=B.Matters,A.RecOrder=B.RecOrder,A.Status=B.Status,A.IsReminderReceipient=B.IsReminderReceipient,ModifiedBy=@UserCreatedOrModified,ModifiedDate=@GetDate,A.Remarks=B.Remarks,A.IsCopy=B.IsCopy From Common.ContactDetails As A
								Inner Join 
								(Select * From Common.ContactDetails Where EntityId=@SourceId And ContactId=@ContactId) As B On B.ContactId=A.ContactId
								Where A.ContactId=@ContactId And A.EntityId=@SyncClientId
							End
							If Exists (Select Id From Common.ContactDetails Where ContactId=@ContactId And EntityId=@SourceId And IsPrimaryContact=1)
							Begin
								Update Common.ContactDetails Set IsPrimaryContact=0 Where EntityId=@SyncClientId And ContactId<>@ContactId
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
						Where A.Id=@SourceId
						Select @AdrsCount=count(*) From #Loc_AdrsTbl
						While @AdrsCount>=@IndCount
						Begin
							Select @AddressId=AddressId,@AddressBookId=AddressBookId,@AddrsAddSecType=AddSectionType,@AdrsEntityId=AdrsEntityId From #Loc_AdrsTbl Where Id=@IndCount
							If Not Exists (Select Id From Common.Addresses Where Addsectiontype=@AddrsAddSecType And AddTypeId=@SyncClientId And AddressBookId=@AddressBookId/*And CompanyId=@CompanyId*/)
							Begin
								Insert Into Common.Addresses(Id,AddSectionType,AddType,AddTypeId,AddTypeIdInt,AddressBookId,Status,DocumentId,EntityId,ScreenName,IsCurrentAddress,CompanyId)
									Select NEWID(),AddSectionType,'Client',@SyncClientId,AddTypeIdInt,AddressBookId,Status,@AdrsEntityId,null,null,IsCurrentAddress,CompanyId From Common.Addresses Where Id=@AddressId /*And CompanyId=@CompanyId*/
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
						Where A.Id=@SyncClientId
						Select @AdrsCount=count(*) From #Loc_AdrsTbl
						While @AdrsCount>=@IndCount
						Begin
							Select @AddressId=AddressId,@AddressBookId=AddressBookId,@AddrsAddSecType=AddSectionType,@AdrsEntityId=AdrsEntityId From #Loc_AdrsTbl Where Id=@IndCount
							If Not Exists (Select Id From Common.Addresses Where Addsectiontype=@AddrsAddSecType And AddTypeId=@SourceId And Addressbookid=@AddressBookId/*And CompanyId=@CompanyId*/)
							Begin
								Delete From Common.Addresses Where Id=@AddressId
								Delete From Common.AddressBook Where Id=@AddressBookId And Not Exists (Select Id From Common.Addresses Where AddressBookId=@AddressBookId)
							End
							Set @IndCount=@IndCount+1
						End
						Truncate Table #Loc_AdrsTbl
					End 
					
					--ContactDetail From Account
					Begin
						Set @IndCount=1
						Insert into #Loc_AdrsTbl
						Select Distinct Adrs.id As AddressId,Adrs.AddressBookId,Adrs.AddSectionType,Adrs.AddTypeId,A.EntityId As AccountId From Common.Addresses As Adrs
						Inner join Common.ContactDetails As A On A.Id=Adrs.AddTypeId 
						Where A.EntityId = @SourceId
						Select @AdrsCount=count(*) From #Loc_AdrsTbl
						While @AdrsCount>=@IndCount
						Begin
							Select @AddressId=AddressId,@AddressBookId=AddressBookId,@AddrsAddSecType=AddSectionType,@AdrsEntityId=AdrsEntityId From #Loc_AdrsTbl Where Id=@IndCount
							--Select @ContactId=ContactId,@SyncAccountId=EntityId From Common.ContactDetails Where Id=@AdrsEntityId
							If @ContactId Is Not null And @SourceId Is Not Null
							Begin
								--Set @SyncClientId=(Select Id From WorkFlow.Client Where CompanyId=@CompanyId And SyncAccountId=@SyncAccountId And SyncAccountId Is Not Null)
								If @SyncClientId Is Not Null
								Begin
									Select @CntDtlDestId=Id From Common.ContactDetails Where EntityId=@SyncClientId And ContactId=@ContactId
									If Not Exists (Select Id From Common.Addresses Where Addsectiontype=@AddrsAddSecType And AddTypeId=@CntDtlDestId And AddressBookId=@AddressBookId/*And CompanyId=@CompanyId*/)
									Begin
										Insert Into Common.Addresses(Id,AddSectionType,AddType,AddTypeId,AddTypeIdInt,AddressBookId,Status,DocumentId,EntityId,ScreenName,IsCurrentAddress,CompanyId)
											Select NEWID(),AddSectionType,'ClientContactDetail',@CntDtlDestId,AddTypeIdInt,AddressBookId,Status,@SourceId,null,null,IsCurrentAddress,CompanyId From Common.Addresses Where Id=@AddressId /*And CompanyId=@CompanyId*/
									End
								End
							End
							Set @IndCount=@IndCount+1
						End
						Truncate Table #Loc_AdrsTbl
					End 
					-- ContactDetail From Client
					Begin
						Set @IndCount=1
						Insert into #Loc_AdrsTbl
						Select Distinct Adrs.id As AddressId,Adrs.AddressBookId,Adrs.AddSectionType,Adrs.AddTypeId,A.EntityId From Common.Addresses As Adrs
						Inner join Common.ContactDetails As A On A.Id=Adrs.AddTypeId 
						Where A.EntityId =@SyncClientId
						Select @AdrsCount=count(*) From #Loc_AdrsTbl
						While @AdrsCount>=@IndCount
						Begin
							Select @AddressId=AddressId,@AddressBookId=AddressBookId,@AddrsAddSecType=AddSectionType,@AdrsEntityId=AdrsEntityId From #Loc_AdrsTbl Where Id=@IndCount
							--Select @ContactId=ContactId,@SyncClientId=EntityId From Common.ContactDetails Where Id=@AdrsEntityId
							If @ContactId Is Not null And @SyncClientId Is Not Null
							Begin
								--Set @SyncAccountId=(Select SyncAccountId From WorkFlow.Client Where CompanyId=@CompanyId And Id=@SyncClientId And SyncAccountId Is Not Null)
								If @SourceId Is Not Null
								Begin
									Select @CntDtlDestId=Id From Common.ContactDetails Where EntityId=@SourceId And ContactId=@ContactId
									If Not Exists (Select Id From Common.Addresses Where Addsectiontype=@AddrsAddSecType And AddTypeId=@CntDtlDestId And AddressBookId=@AddressBookId /*And CompanyId=@CompanyId*/)
									Begin
										Delete From Common.Addresses Where Id=@AddressId
										Delete From Common.AddressBook Where Id=@AddressBookId And Not Exists (Select Id From Common.Addresses Where AddressBookId=@AddressBookId)
									End
								End
							End
							Set @IndCount=@IndCount+1
						End
						Truncate Table #Loc_AdrsTbl
					End 
				End
					
				If @SyncEntityId Is Not Null
				Begin
					--ContactDetails From Account
					Begin
						Set @IndCount=1
						Set @Count=0
						Insert into #Loc_Cont_Tbl
						Select Distinct Cd.Id As ContactDetailId,CD.EntityType,CD.ContactId,CD.EntityId,A.SyncClientId From Common.ContactDetails As CD
						Inner Join ClientCursor.Account As A On A.Id=CD.EntityId
						Inner Join Common.Contact As C On C.Id=CD.ContactId 
						Where C.Id=@ContactId And A.Id=@SourceId
						Select @Count=count(*) From #Loc_Cont_Tbl
						While @Count>=@IndCount
						Begin
							Select @ContactDetailId=ContactDetailId From #Loc_Cont_Tbl Where Id=@IndCount
							If Exists (Select Id From Common.ContactDetails Where ContactId=@ContactId And EntityId=@SyncEntityId)
							Begin
								Update A Set A.Designation=B.Designation,A.Communication=B.Communication,A.IsPrimaryContact=B.IsPrimaryContact,A.Matters=B.Matters,A.RecOrder=B.RecOrder,A.Status=B.Status,A.IsReminderReceipient=B.IsReminderReceipient,ModifiedBy=@UserCreatedOrModified,ModifiedDate=@GetDate,A.Remarks=B.Remarks,A.IsCopy=B.IsCopy From Common.ContactDetails As A
								Inner Join 
								(Select * From Common.ContactDetails Where EntityId=@SourceId And ContactId=@ContactId) As B On B.ContactId=A.ContactId
								Where A.ContactId=@ContactId And A.EntityId=@SyncEntityId
							End
							If Exists (Select Id From Common.ContactDetails Where ContactId=@ContactId And EntityId=@SourceId And IsPrimaryContact=1)
							Begin
								Update Common.ContactDetails Set IsPrimaryContact=0 Where EntityId=@SyncEntityId And ContactId<>@ContactId
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
						Where A.Id=@SourceId
						Select @AdrsCount=count(*) From #Loc_AdrsTbl
						While @AdrsCount>=@IndCount
						Begin
							Select @AddressId=AddressId,@AddressBookId=AddressBookId,@AddrsAddSecType=AddSectionType,@AdrsEntityId=AdrsEntityId From #Loc_AdrsTbl Where Id=@IndCount
							If Not Exists (Select Id From Common.Addresses Where Addsectiontype=@AddrsAddSecType And AddTypeId=@SyncEntityId And AddressBookId=@AddressBookId/*And CompanyId=@CompanyId*/)
							Begin
								Insert Into Common.Addresses(Id,AddSectionType,AddType,AddTypeId,AddTypeIdInt,AddressBookId,Status,DocumentId,EntityId,ScreenName,IsCurrentAddress,CompanyId)
									Select NEWID(),AddSectionType,'Entity',@SyncEntityId,AddTypeIdInt,AddressBookId,Status,@AdrsEntityId,null,null,IsCurrentAddress,CompanyId From Common.Addresses Where Id=@AddressId /*And CompanyId=@CompanyId*/
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
						Where A.Id=@SyncEntityId
						Select @AdrsCount=count(*) From #Loc_AdrsTbl
						While @AdrsCount>=@IndCount
						Begin
							Select @AddressId=AddressId,@AddressBookId=AddressBookId,@AddrsAddSecType=AddSectionType,@AdrsEntityId=AdrsEntityId From #Loc_AdrsTbl Where Id=@IndCount
							If Not Exists (Select Id From Common.Addresses Where Addsectiontype=@AddrsAddSecType And AddTypeId=@SourceId And Addressbookid=@AddressBookId/*And CompanyId=@CompanyId*/)
							Begin
								Delete From Common.Addresses Where Id=@AddressId
								Delete From Common.AddressBook Where Id=@AddressBookId And Not Exists (Select Id From Common.Addresses Where AddressBookId=@AddressBookId)
							End
							Set @IndCount=@IndCount+1
						End
						Truncate Table #Loc_AdrsTbl
					End 
					
					--ContactDetail From Account
					Begin
						Set @IndCount=1
						Insert into #Loc_AdrsTbl
						Select Distinct Adrs.id As AddressId,Adrs.AddressBookId,Adrs.AddSectionType,Adrs.AddTypeId,A.EntityId As AccountId From Common.Addresses As Adrs
						Inner join Common.ContactDetails As A On A.Id=Adrs.AddTypeId 
						Where A.EntityId = @SourceId
						Select @AdrsCount=count(*) From #Loc_AdrsTbl
						While @AdrsCount>=@IndCount
						Begin
							Select @AddressId=AddressId,@AddressBookId=AddressBookId,@AddrsAddSecType=AddSectionType,@AdrsEntityId=AdrsEntityId From #Loc_AdrsTbl Where Id=@IndCount
							--Select @ContactId=ContactId,@SyncAccountId=EntityId From Common.ContactDetails Where Id=@AdrsEntityId
							If @ContactId Is Not null And @SourceId Is Not Null
							Begin
								--Set @SyncClientId=(Select Id From WorkFlow.Client Where CompanyId=@CompanyId And SyncAccountId=@SyncAccountId And SyncAccountId Is Not Null)
								If @SyncEntityId Is Not Null
								Begin
									Select @CntDtlDestId=Id From Common.ContactDetails Where EntityId=@SyncEntityId And ContactId=@ContactId
									If Not Exists (Select Id From Common.Addresses Where Addsectiontype=@AddrsAddSecType And AddTypeId=@CntDtlDestId And AddressBookId=@AddressBookId/*And CompanyId=@CompanyId*/)
									Begin
										Insert Into Common.Addresses(Id,AddSectionType,AddType,AddTypeId,AddTypeIdInt,AddressBookId,Status,DocumentId,EntityId,ScreenName,IsCurrentAddress,CompanyId)
											Select NEWID(),AddSectionType,'EntityContactDetail',@CntDtlDestId,AddTypeIdInt,AddressBookId,Status,@SourceId,null,null,IsCurrentAddress,CompanyId From Common.Addresses Where Id=@AddressId /*And CompanyId=@CompanyId*/
									End
								End
							End
							Set @IndCount=@IndCount+1
						End
						Truncate Table #Loc_AdrsTbl
					End 
					-- ContactDetail From Entity
					Begin
						Set @IndCount=1
						Insert into #Loc_AdrsTbl
						Select Distinct Adrs.id As AddressId,Adrs.AddressBookId,Adrs.AddSectionType,Adrs.AddTypeId,A.EntityId From Common.Addresses As Adrs
						Inner join Common.ContactDetails As A On A.Id=Adrs.AddTypeId 
						Where A.EntityId =@SyncEntityId
						Select @AdrsCount=count(*) From #Loc_AdrsTbl
						While @AdrsCount>=@IndCount
						Begin
							Select @AddressId=AddressId,@AddressBookId=AddressBookId,@AddrsAddSecType=AddSectionType,@AdrsEntityId=AdrsEntityId From #Loc_AdrsTbl Where Id=@IndCount
							--Select @ContactId=ContactId,@SyncEntityId=EntityId From Common.ContactDetails Where Id=@AdrsEntityId
							If @ContactId Is Not null And @SyncEntityId Is Not Null
							Begin
								--Set @SyncAccountId=(Select SyncAccountId From WorkFlow.Client Where CompanyId=@CompanyId And Id=@SyncClientId And SyncAccountId Is Not Null)
								If @SourceId Is Not Null
								Begin
									Select @CntDtlDestId=Id From Common.ContactDetails Where EntityId=@SourceId And ContactId=@ContactId
									If Not Exists (Select Id From Common.Addresses Where Addsectiontype=@AddrsAddSecType And AddTypeId=@CntDtlDestId And AddressBookId=@AddressBookId /*And CompanyId=@CompanyId*/)
									Begin
										Delete From Common.Addresses Where Id=@AddressId
										Delete From Common.AddressBook Where Id=@AddressBookId And Not Exists (Select Id From Common.Addresses Where AddressBookId=@AddressBookId)
									End
								End
							End
							Set @IndCount=@IndCount+1
						End
						Truncate Table #Loc_AdrsTbl
					End 

				End
			End
			If @SourceType ='Client'
			Begin
				Set @SyncAccountId=(Select SyncAccountId From WorkFlow.Client Where Id=@SourceId)
				Set @SyncEntityId=(Select SyncEntityId From WorkFlow.Client Where Id=@SourceId)

				If @SyncAccountId Is Not Null
				Begin
					--ContactDetails From Client
					Begin
						Set @IndCount=1
						Set @Count=0
						Insert into #Loc_Cont_Tbl
						Select Distinct Cd.Id As ContactDetailId,CD.EntityType,CD.ContactId,CD.EntityId,A.SyncAccountId From Common.ContactDetails As CD
						Inner Join WorkFlow.Client As A On A.Id=CD.EntityId
						Inner Join Common.Contact As C On C.Id=CD.ContactId 
						Where C.Id=@ContactId And A.Id=@SourceId
						Select @Count=count(*) From #Loc_Cont_Tbl
						While @Count>=@IndCount
						Begin
							Select @ContactDetailId=ContactDetailId From #Loc_Cont_Tbl Where Id=@IndCount
							If Exists (Select Id From Common.ContactDetails Where ContactId=@ContactId And EntityId=@SyncAccountId)
							Begin
								Update A Set A.Designation=B.Designation,A.Communication=B.Communication,A.IsPrimaryContact=B.IsPrimaryContact,A.Matters=B.Matters,A.RecOrder=B.RecOrder,A.Status=B.Status,A.IsReminderReceipient=B.IsReminderReceipient,ModifiedBy=@UserCreatedOrModified,ModifiedDate=@GetDate,A.Remarks=B.Remarks,A.IsCopy=B.IsCopy From Common.ContactDetails As A
								Inner Join 
								(Select * From Common.ContactDetails Where EntityId=@SourceId And ContactId=@ContactId) As B On B.ContactId=A.ContactId
								Where A.ContactId=@ContactId And A.EntityId=@SyncAccountId
							End
							If Exists (Select Id From Common.ContactDetails Where ContactId=@ContactId And EntityId=@SourceId And IsPrimaryContact=1)
							Begin
								Update Common.ContactDetails Set IsPrimaryContact=0 Where EntityId=@SyncAccountId And ContactId<>@ContactId
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
						Where A.Id=@SourceId
						Select @AdrsCount=count(*) From #Loc_AdrsTbl
						While @AdrsCount>=@IndCount
						Begin
							Select @AddressId=AddressId,@AddressBookId=AddressBookId,@AddrsAddSecType=AddSectionType,@AdrsEntityId=AdrsEntityId From #Loc_AdrsTbl Where Id=@IndCount
							If Not Exists (Select Id From Common.Addresses Where Addsectiontype=@AddrsAddSecType And AddTypeId=@SyncAccountId And AddressBookId=@AddressBookId/*And CompanyId=@CompanyId*/)
							Begin
								Insert Into Common.Addresses(Id,AddSectionType,AddType,AddTypeId,AddTypeIdInt,AddressBookId,Status,DocumentId,EntityId,ScreenName,IsCurrentAddress,CompanyId)
									Select NEWID(),AddSectionType,'Account',@SyncAccountId,AddTypeIdInt,AddressBookId,Status,@AdrsEntityId,null,null,IsCurrentAddress,CompanyId From Common.Addresses Where Id=@AddressId /*And CompanyId=@CompanyId*/
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
						Where A.Id=@SyncAccountId
						Select @AdrsCount=count(*) From #Loc_AdrsTbl
						While @AdrsCount>=@IndCount
						Begin
							Select @AddressId=AddressId,@AddressBookId=AddressBookId,@AddrsAddSecType=AddSectionType,@AdrsEntityId=AdrsEntityId From #Loc_AdrsTbl Where Id=@IndCount
							If Not Exists (Select Id From Common.Addresses Where Addsectiontype=@AddrsAddSecType And AddTypeId=@SourceId And Addressbookid=@AddressBookId/*And CompanyId=@CompanyId*/)
							Begin
								Delete From Common.Addresses Where Id=@AddressId
								Delete From Common.AddressBook Where Id=@AddressBookId And Not Exists (Select Id From Common.Addresses Where AddressBookId=@AddressBookId)
							End
							Set @IndCount=@IndCount+1
						End
						Truncate Table #Loc_AdrsTbl
					End 
					
					--ContactDetail From Client
					Begin
						Set @IndCount=1
						Insert into #Loc_AdrsTbl
						Select Distinct Adrs.id As AddressId,Adrs.AddressBookId,Adrs.AddSectionType,Adrs.AddTypeId,A.EntityId As AccountId From Common.Addresses As Adrs
						Inner join Common.ContactDetails As A On A.Id=Adrs.AddTypeId 
						Where A.EntityId = @SourceId
						Select @AdrsCount=count(*) From #Loc_AdrsTbl
						While @AdrsCount>=@IndCount
						Begin
							Select @AddressId=AddressId,@AddressBookId=AddressBookId,@AddrsAddSecType=AddSectionType,@AdrsEntityId=AdrsEntityId From #Loc_AdrsTbl Where Id=@IndCount
							--Select @ContactId=ContactId,@SyncAccountId=EntityId From Common.ContactDetails Where Id=@AdrsEntityId
							If @ContactId Is Not null And @SourceId Is Not Null
							Begin
								--Set @SyncClientId=(Select Id From WorkFlow.Client Where CompanyId=@CompanyId And SyncAccountId=@SyncAccountId And SyncAccountId Is Not Null)
								If @SyncAccountId Is Not Null
								Begin
									Select @CntDtlDestId=Id From Common.ContactDetails Where EntityId=@SyncAccountId And ContactId=@ContactId
									If Not Exists (Select Id From Common.Addresses Where Addsectiontype=@AddrsAddSecType And AddTypeId=@CntDtlDestId And AddressBookId=@AddressBookId/*And CompanyId=@CompanyId*/)
									Begin
										Insert Into Common.Addresses(Id,AddSectionType,AddType,AddTypeId,AddTypeIdInt,AddressBookId,Status,DocumentId,EntityId,ScreenName,IsCurrentAddress,CompanyId)
											Select NEWID(),AddSectionType,'AccountContactDetail',@CntDtlDestId,AddTypeIdInt,AddressBookId,Status,@SourceId,null,null,IsCurrentAddress,CompanyId From Common.Addresses Where Id=@AddressId /*And CompanyId=@CompanyId*/
									End
								End
							End
							Set @IndCount=@IndCount+1
						End
						Truncate Table #Loc_AdrsTbl
					End 
					-- ContactDetail From Account
					Begin
						Set @IndCount=1
						Insert into #Loc_AdrsTbl
						Select Distinct Adrs.id As AddressId,Adrs.AddressBookId,Adrs.AddSectionType,Adrs.AddTypeId,A.EntityId From Common.Addresses As Adrs
						Inner join Common.ContactDetails As A On A.Id=Adrs.AddTypeId 
						Where A.EntityId =@SyncAccountId
						Select @AdrsCount=count(*) From #Loc_AdrsTbl
						While @AdrsCount>=@IndCount
						Begin
							Select @AddressId=AddressId,@AddressBookId=AddressBookId,@AddrsAddSecType=AddSectionType,@AdrsEntityId=AdrsEntityId From #Loc_AdrsTbl Where Id=@IndCount
							--Select @ContactId=ContactId,@SyncAccountId=EntityId From Common.ContactDetails Where Id=@AdrsEntityId
							If @ContactId Is Not null And @SyncAccountId Is Not Null
							Begin
								--Set @SyncAccountId=(Select SyncAccountId From WorkFlow.Client Where CompanyId=@CompanyId And Id=@SyncClientId And SyncAccountId Is Not Null)
								If @SourceId Is Not Null
								Begin
									Select @CntDtlDestId=Id From Common.ContactDetails Where EntityId=@SourceId And ContactId=@ContactId
									If Not Exists (Select Id From Common.Addresses Where Addsectiontype=@AddrsAddSecType And AddTypeId=@CntDtlDestId And AddressBookId=@AddressBookId /*And CompanyId=@CompanyId*/)
									Begin
										Delete From Common.Addresses Where Id=@AddressId
										Delete From Common.AddressBook Where Id=@AddressBookId And Not Exists (Select Id From Common.Addresses Where AddressBookId=@AddressBookId)
									End
								End
							End
							Set @IndCount=@IndCount+1
						End
						Truncate Table #Loc_AdrsTbl
					End 
				End
					
				If @SyncEntityId Is Not Null
				Begin
					--ContactDetails From Client
					Begin
						Set @IndCount=1
						Set @Count=0
						Insert into #Loc_Cont_Tbl
						Select Distinct Cd.Id As ContactDetailId,CD.EntityType,CD.ContactId,CD.EntityId,A.SyncEntityId From Common.ContactDetails As CD
						Inner Join WorkFlow.Client As A On A.Id=CD.EntityId
						Inner Join Common.Contact As C On C.Id=CD.ContactId 
						Where C.Id=@ContactId And A.Id=@SourceId
						Select @Count=count(*) From #Loc_Cont_Tbl
						While @Count>=@IndCount
						Begin
							Select @ContactDetailId=ContactDetailId From #Loc_Cont_Tbl Where Id=@IndCount
							If Exists (Select Id From Common.ContactDetails Where ContactId=@ContactId And EntityId=@SyncEntityId)
							Begin
								Update A Set A.Designation=B.Designation,A.Communication=B.Communication,A.IsPrimaryContact=B.IsPrimaryContact,A.Matters=B.Matters,A.RecOrder=B.RecOrder,A.Status=B.Status,A.IsReminderReceipient=B.IsReminderReceipient,ModifiedBy=@UserCreatedOrModified,ModifiedDate=@GetDate,A.Remarks=B.Remarks,A.IsCopy=B.IsCopy From Common.ContactDetails As A
								Inner Join 
								(Select * From Common.ContactDetails Where EntityId=@SourceId And ContactId=@ContactId) As B On B.ContactId=A.ContactId
								Where A.ContactId=@ContactId And A.EntityId=@SyncEntityId
							End
							If Exists (Select Id From Common.ContactDetails Where ContactId=@ContactId And EntityId=@SourceId And IsPrimaryContact=1)
							Begin
								Update Common.ContactDetails Set IsPrimaryContact=0 Where EntityId=@SyncEntityId And ContactId<>@ContactId
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
						Where A.Id=@SourceId
						Select @AdrsCount=count(*) From #Loc_AdrsTbl
						While @AdrsCount>=@IndCount
						Begin
							Select @AddressId=AddressId,@AddressBookId=AddressBookId,@AddrsAddSecType=AddSectionType,@AdrsEntityId=AdrsEntityId From #Loc_AdrsTbl Where Id=@IndCount
							If Not Exists (Select Id From Common.Addresses Where Addsectiontype=@AddrsAddSecType And AddTypeId=@SyncEntityId And AddressBookId=@AddressBookId/*And CompanyId=@CompanyId*/)
							Begin
								Insert Into Common.Addresses(Id,AddSectionType,AddType,AddTypeId,AddTypeIdInt,AddressBookId,Status,DocumentId,EntityId,ScreenName,IsCurrentAddress,CompanyId)
									Select NEWID(),AddSectionType,'Entity',@SyncEntityId,AddTypeIdInt,AddressBookId,Status,@AdrsEntityId,null,null,IsCurrentAddress,CompanyId From Common.Addresses Where Id=@AddressId /*And CompanyId=@CompanyId*/
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
						Where A.Id=@SyncEntityId
						Select @AdrsCount=count(*) From #Loc_AdrsTbl
						While @AdrsCount>=@IndCount
						Begin
							Select @AddressId=AddressId,@AddressBookId=AddressBookId,@AddrsAddSecType=AddSectionType,@AdrsEntityId=AdrsEntityId From #Loc_AdrsTbl Where Id=@IndCount
							If Not Exists (Select Id From Common.Addresses Where Addsectiontype=@AddrsAddSecType And AddTypeId=@SourceId And Addressbookid=@AddressBookId/*And CompanyId=@CompanyId*/)
							Begin
								Delete From Common.Addresses Where Id=@AddressId
								Delete From Common.AddressBook Where Id=@AddressBookId And Not Exists (Select Id From Common.Addresses Where AddressBookId=@AddressBookId)
							End
							Set @IndCount=@IndCount+1
						End
						Truncate Table #Loc_AdrsTbl
					End 
					
					--ContactDetail From Client
					Begin
						Set @IndCount=1
						Insert into #Loc_AdrsTbl
						Select Distinct Adrs.id As AddressId,Adrs.AddressBookId,Adrs.AddSectionType,Adrs.AddTypeId,A.EntityId As AccountId From Common.Addresses As Adrs
						Inner join Common.ContactDetails As A On A.Id=Adrs.AddTypeId 
						Where A.EntityId = @SourceId
						Select @AdrsCount=count(*) From #Loc_AdrsTbl
						While @AdrsCount>=@IndCount
						Begin
							Select @AddressId=AddressId,@AddressBookId=AddressBookId,@AddrsAddSecType=AddSectionType,@AdrsEntityId=AdrsEntityId From #Loc_AdrsTbl Where Id=@IndCount
							--Select @ContactId=ContactId,@SyncAccountId=EntityId From Common.ContactDetails Where Id=@AdrsEntityId
							If @ContactId Is Not null And @SourceId Is Not Null
							Begin
								--Set @SyncClientId=(Select Id From WorkFlow.Client Where CompanyId=@CompanyId And SyncAccountId=@SyncAccountId And SyncAccountId Is Not Null)
								If @SyncEntityId Is Not Null
								Begin
									Select @CntDtlDestId=Id From Common.ContactDetails Where EntityId=@SyncEntityId And ContactId=@ContactId
									If Not Exists (Select Id From Common.Addresses Where Addsectiontype=@AddrsAddSecType And AddTypeId=@CntDtlDestId And AddressBookId=@AddressBookId/*And CompanyId=@CompanyId*/)
									Begin
										Insert Into Common.Addresses(Id,AddSectionType,AddType,AddTypeId,AddTypeIdInt,AddressBookId,Status,DocumentId,EntityId,ScreenName,IsCurrentAddress,CompanyId)
											Select NEWID(),AddSectionType,'EntityContactDetail',@CntDtlDestId,AddTypeIdInt,AddressBookId,Status,@SourceId,null,null,IsCurrentAddress,CompanyId From Common.Addresses Where Id=@AddressId /*And CompanyId=@CompanyId*/
									End
								End
							End
							Set @IndCount=@IndCount+1
						End
						Truncate Table #Loc_AdrsTbl
					End 
					-- ContactDetail From Entity
					Begin
						Set @IndCount=1
						Insert into #Loc_AdrsTbl
						Select Distinct Adrs.id As AddressId,Adrs.AddressBookId,Adrs.AddSectionType,Adrs.AddTypeId,A.EntityId From Common.Addresses As Adrs
						Inner join Common.ContactDetails As A On A.Id=Adrs.AddTypeId 
						Where A.EntityId =@SyncEntityId
						Select @AdrsCount=count(*) From #Loc_AdrsTbl
						While @AdrsCount>=@IndCount
						Begin
							Select @AddressId=AddressId,@AddressBookId=AddressBookId,@AddrsAddSecType=AddSectionType,@AdrsEntityId=AdrsEntityId From #Loc_AdrsTbl Where Id=@IndCount
							--Select @ContactId=ContactId,@SyncEntityId=EntityId From Common.ContactDetails Where Id=@AdrsEntityId
							If @ContactId Is Not null And @SyncEntityId Is Not Null
							Begin
								--Set @SyncAccountId=(Select SyncAccountId From WorkFlow.Client Where CompanyId=@CompanyId And Id=@SyncClientId And SyncAccountId Is Not Null)
								If @SyncEntityId Is Not Null
								Begin
									Select @CntDtlDestId=Id From Common.ContactDetails Where EntityId=@SourceId And ContactId=@ContactId
									If Not Exists (Select Id From Common.Addresses Where Addsectiontype=@AddrsAddSecType And AddTypeId=@CntDtlDestId And AddressBookId=@AddressBookId /*And CompanyId=@CompanyId*/)
									Begin
										Delete From Common.Addresses Where Id=@AddressId
										Delete From Common.AddressBook Where Id=@AddressBookId And Not Exists (Select Id From Common.Addresses Where AddressBookId=@AddressBookId)
									End
								End
							End
							Set @IndCount=@IndCount+1
						End
						Truncate Table #Loc_AdrsTbl
					End 

				End
			End
			If @SourceType ='Entity'
			Begin
				Set @SyncAccountId=(Select SyncAccountId From Bean.Entity Where Id=@SourceId)
				Set @SyncClientId=(Select SyncClientId From Bean.Entity Where Id=@SourceId)
				
				If @SyncClientId Is Not Null
				Begin
					--ContactDetails From Entity
					Begin
						Set @IndCount=1
						Set @Count=0
						Insert into #Loc_Cont_Tbl
						Select Distinct Cd.Id As ContactDetailId,CD.EntityType,CD.ContactId,CD.EntityId,A.SyncClientId From Common.ContactDetails As CD
						Inner Join Bean.Entity As A On A.Id=CD.EntityId
						Inner Join Common.Contact As C On C.Id=CD.ContactId 
						Where C.Id=@ContactId And A.Id=@SourceId
						Select @Count=count(*) From #Loc_Cont_Tbl
						While @Count>=@IndCount
						Begin
							Select @ContactDetailId=ContactDetailId From #Loc_Cont_Tbl Where Id=@IndCount
							If Exists (Select Id From Common.ContactDetails Where ContactId=@ContactId And EntityId=@SyncClientId)
							Begin
								Update A Set A.Designation=B.Designation,A.Communication=B.Communication,A.IsPrimaryContact=B.IsPrimaryContact,A.Matters=B.Matters,A.RecOrder=B.RecOrder,A.Status=B.Status,A.IsReminderReceipient=B.IsReminderReceipient,ModifiedBy=@UserCreatedOrModified,ModifiedDate=@GetDate,A.Remarks=B.Remarks,A.IsCopy=B.IsCopy From Common.ContactDetails As A
								Inner Join 
								(Select * From Common.ContactDetails Where EntityId=@SourceId And ContactId=@ContactId) As B On B.ContactId=A.ContactId
								Where A.ContactId=@ContactId And A.EntityId=@SyncClientId
							End
							If Exists (Select Id From Common.ContactDetails Where ContactId=@ContactId And EntityId=@SourceId And IsPrimaryContact=1)
							Begin
								Update Common.ContactDetails Set IsPrimaryContact=0 Where EntityId=@SyncClientId And ContactId<>@ContactId
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
						Where A.Id=@SourceId
						Select @AdrsCount=count(*) From #Loc_AdrsTbl
						While @AdrsCount>=@IndCount
						Begin
							Select @AddressId=AddressId,@AddressBookId=AddressBookId,@AddrsAddSecType=AddSectionType,@AdrsEntityId=AdrsEntityId From #Loc_AdrsTbl Where Id=@IndCount
							If Not Exists (Select Id From Common.Addresses Where Addsectiontype=@AddrsAddSecType And AddTypeId=@SyncClientId And AddressBookId=@AddressBookId/*And CompanyId=@CompanyId*/)
							Begin
								Insert Into Common.Addresses(Id,AddSectionType,AddType,AddTypeId,AddTypeIdInt,AddressBookId,Status,DocumentId,EntityId,ScreenName,IsCurrentAddress,CompanyId)
									Select NEWID(),AddSectionType,'Client',@SyncClientId,AddTypeIdInt,AddressBookId,Status,@AdrsEntityId,null,null,IsCurrentAddress,CompanyId From Common.Addresses Where Id=@AddressId /*And CompanyId=@CompanyId*/
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
						Where A.Id=@SyncClientId
						Select @AdrsCount=count(*) From #Loc_AdrsTbl
						While @AdrsCount>=@IndCount
						Begin
							Select @AddressId=AddressId,@AddressBookId=AddressBookId,@AddrsAddSecType=AddSectionType,@AdrsEntityId=AdrsEntityId From #Loc_AdrsTbl Where Id=@IndCount
							If Not Exists (Select Id From Common.Addresses Where Addsectiontype=@AddrsAddSecType And AddTypeId=@SourceId And Addressbookid=@AddressBookId/*And CompanyId=@CompanyId*/)
							Begin
								Delete From Common.Addresses Where Id=@AddressId
								Delete From Common.AddressBook Where Id=@AddressBookId And Not Exists (Select Id From Common.Addresses Where AddressBookId=@AddressBookId)
							End
							Set @IndCount=@IndCount+1
						End
						Truncate Table #Loc_AdrsTbl
					End 
					
					--ContactDetail From Entity
					Begin
						Set @IndCount=1
						Insert into #Loc_AdrsTbl
						Select Distinct Adrs.id As AddressId,Adrs.AddressBookId,Adrs.AddSectionType,Adrs.AddTypeId,A.EntityId As AccountId From Common.Addresses As Adrs
						Inner join Common.ContactDetails As A On A.Id=Adrs.AddTypeId 
						Where A.EntityId = @SourceId
						Select @AdrsCount=count(*) From #Loc_AdrsTbl
						While @AdrsCount>=@IndCount
						Begin
							Select @AddressId=AddressId,@AddressBookId=AddressBookId,@AddrsAddSecType=AddSectionType,@AdrsEntityId=AdrsEntityId From #Loc_AdrsTbl Where Id=@IndCount
							--Select @ContactId=ContactId,@SyncAccountId=EntityId From Common.ContactDetails Where Id=@AdrsEntityId
							If @ContactId Is Not null And @SourceId Is Not Null
							Begin
								--Set @SyncClientId=(Select Id From WorkFlow.Client Where CompanyId=@CompanyId And SyncAccountId=@SyncAccountId And SyncAccountId Is Not Null)
								If @SyncClientId Is Not Null
								Begin
									Select @CntDtlDestId=Id From Common.ContactDetails Where EntityId=@SyncClientId And ContactId=@ContactId
									If Not Exists (Select Id From Common.Addresses Where Addsectiontype=@AddrsAddSecType And AddTypeId=@CntDtlDestId And AddressBookId=@AddressBookId/*And CompanyId=@CompanyId*/)
									Begin
										Insert Into Common.Addresses(Id,AddSectionType,AddType,AddTypeId,AddTypeIdInt,AddressBookId,Status,DocumentId,EntityId,ScreenName,IsCurrentAddress,CompanyId)
											Select NEWID(),AddSectionType,'ClientContactDetail',@CntDtlDestId,AddTypeIdInt,AddressBookId,Status,@SourceId,null,null,IsCurrentAddress,CompanyId From Common.Addresses Where Id=@AddressId /*And CompanyId=@CompanyId*/
									End
								End
							End
							Set @IndCount=@IndCount+1
						End
						Truncate Table #Loc_AdrsTbl
					End 
					-- ContactDetail From Client
					Begin
						Set @IndCount=1
						Insert into #Loc_AdrsTbl
						Select Distinct Adrs.id As AddressId,Adrs.AddressBookId,Adrs.AddSectionType,Adrs.AddTypeId,A.EntityId From Common.Addresses As Adrs
						Inner join Common.ContactDetails As A On A.Id=Adrs.AddTypeId 
						Where A.EntityId =@SyncClientId
						Select @AdrsCount=count(*) From #Loc_AdrsTbl
						While @AdrsCount>=@IndCount
						Begin
							Select @AddressId=AddressId,@AddressBookId=AddressBookId,@AddrsAddSecType=AddSectionType,@AdrsEntityId=AdrsEntityId From #Loc_AdrsTbl Where Id=@IndCount
							--Select @ContactId=ContactId,@SyncClientId=EntityId From Common.ContactDetails Where Id=@AdrsEntityId
							If @ContactId Is Not null And @SyncClientId Is Not Null
							Begin
								--Set @SyncAccountId=(Select SyncAccountId From WorkFlow.Client Where CompanyId=@CompanyId And Id=@SyncClientId And SyncAccountId Is Not Null)
								If @SourceId Is Not Null
								Begin
									Select @CntDtlDestId=Id From Common.ContactDetails Where EntityId=@SourceId And ContactId=@ContactId
									If Not Exists (Select Id From Common.Addresses Where Addsectiontype=@AddrsAddSecType And AddTypeId=@CntDtlDestId And AddressBookId=@AddressBookId /*And CompanyId=@CompanyId*/)
									Begin
										Delete From Common.Addresses Where Id=@AddressId
										Delete From Common.AddressBook Where Id=@AddressBookId And Not Exists (Select Id From Common.Addresses Where AddressBookId=@AddressBookId)
									End
								End
							End
							Set @IndCount=@IndCount+1
						End
						Truncate Table #Loc_AdrsTbl
					End 
				End
				If @SyncAccountId Is Not Null
				Begin
					--ContactDetails From Entity
					Begin
						Set @IndCount=1
						Set @Count=0
						Insert into #Loc_Cont_Tbl
						Select Distinct Cd.Id As ContactDetailId,CD.EntityType,CD.ContactId,CD.EntityId,A.SyncClientId From Common.ContactDetails As CD
						Inner Join Bean.Entity As A On A.Id=CD.EntityId
						Inner Join Common.Contact As C On C.Id=CD.ContactId 
						Where C.Id=@ContactId And A.Id=@SourceId
						Select @Count=count(*) From #Loc_Cont_Tbl
						While @Count>=@IndCount
						Begin
							Select @ContactDetailId=ContactDetailId From #Loc_Cont_Tbl Where Id=@IndCount
							If Exists (Select Id From Common.ContactDetails Where ContactId=@ContactId And EntityId=@SyncAccountId)
							Begin
								Update A Set A.Designation=B.Designation,A.Communication=B.Communication,A.IsPrimaryContact=B.IsPrimaryContact,A.Matters=B.Matters,A.RecOrder=B.RecOrder,A.Status=B.Status,A.IsReminderReceipient=B.IsReminderReceipient,ModifiedBy=@UserCreatedOrModified,ModifiedDate=@GetDate,A.Remarks=B.Remarks,A.IsCopy=B.IsCopy From Common.ContactDetails As A
								Inner Join 
								(Select * From Common.ContactDetails Where EntityId=@SourceId And ContactId=@ContactId) As B On B.ContactId=A.ContactId
								Where A.ContactId=@ContactId And A.EntityId=@SyncAccountId
							End
							If Exists (Select Id From Common.ContactDetails Where ContactId=@ContactId And EntityId=@SourceId And IsPrimaryContact=1)
							Begin
								Update Common.ContactDetails Set IsPrimaryContact=0 Where EntityId=@SyncEntityId And ContactId<>@ContactId
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
						Inner join ClientCursor.Account As A On A.Id=Adrs.AddTypeId 
						Where A.Id=@SourceId
						Select @AdrsCount=count(*) From #Loc_AdrsTbl
						While @AdrsCount>=@IndCount
						Begin
							Select @AddressId=AddressId,@AddressBookId=AddressBookId,@AddrsAddSecType=AddSectionType,@AdrsEntityId=AdrsEntityId From #Loc_AdrsTbl Where Id=@IndCount
							If Not Exists (Select Id From Common.Addresses Where Addsectiontype=@AddrsAddSecType And AddTypeId=@SyncAccountId And AddressBookId=@AddressBookId/*And CompanyId=@CompanyId*/)
							Begin
								Insert Into Common.Addresses(Id,AddSectionType,AddType,AddTypeId,AddTypeIdInt,AddressBookId,Status,DocumentId,EntityId,ScreenName,IsCurrentAddress,CompanyId)
									Select NEWID(),AddSectionType,'Account',@SyncAccountId,AddTypeIdInt,AddressBookId,Status,@AdrsEntityId,null,null,IsCurrentAddress,CompanyId From Common.Addresses Where Id=@AddressId /*And CompanyId=@CompanyId*/
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
						Inner join WorkFlow.Client As A On A.Id=Adrs.AddTypeId 
						Where A.Id=@SyncAccountId
						Select @AdrsCount=count(*) From #Loc_AdrsTbl
						While @AdrsCount>=@IndCount
						Begin
							Select @AddressId=AddressId,@AddressBookId=AddressBookId,@AddrsAddSecType=AddSectionType,@AdrsEntityId=AdrsEntityId From #Loc_AdrsTbl Where Id=@IndCount
							If Not Exists (Select Id From Common.Addresses Where Addsectiontype=@AddrsAddSecType And AddTypeId=@SourceId And Addressbookid=@AddressBookId/*And CompanyId=@CompanyId*/)
							Begin
								Delete From Common.Addresses Where Id=@AddressId
								Delete From Common.AddressBook Where Id=@AddressBookId And Not Exists (Select Id From Common.Addresses Where AddressBookId=@AddressBookId)
							End
							Set @IndCount=@IndCount+1
						End
						Truncate Table #Loc_AdrsTbl
					End 
					
					--ContactDetail From Account
					Begin
						Set @IndCount=1
						Insert into #Loc_AdrsTbl
						Select Distinct Adrs.id As AddressId,Adrs.AddressBookId,Adrs.AddSectionType,Adrs.AddTypeId,A.EntityId As AccountId From Common.Addresses As Adrs
						Inner join Common.ContactDetails As A On A.Id=Adrs.AddTypeId 
						Where A.EntityId = @SourceId
						Select @AdrsCount=count(*) From #Loc_AdrsTbl
						While @AdrsCount>=@IndCount
						Begin
							Select @AddressId=AddressId,@AddressBookId=AddressBookId,@AddrsAddSecType=AddSectionType,@AdrsEntityId=AdrsEntityId From #Loc_AdrsTbl Where Id=@IndCount
							--Select @ContactId=ContactId,@SyncAccountId=EntityId From Common.ContactDetails Where Id=@AdrsEntityId
							If @ContactId Is Not null And @SourceId Is Not Null
							Begin
								--Set @SyncClientId=(Select Id From WorkFlow.Client Where CompanyId=@CompanyId And SyncAccountId=@SyncAccountId And SyncAccountId Is Not Null)
								If @SyncAccountId Is Not Null
								Begin
									Select @CntDtlDestId=Id From Common.ContactDetails Where EntityId=@SyncAccountId And ContactId=@ContactId
									If Not Exists (Select Id From Common.Addresses Where Addsectiontype=@AddrsAddSecType And AddTypeId=@CntDtlDestId And AddressBookId=@AddressBookId/*And CompanyId=@CompanyId*/)
									Begin
										Insert Into Common.Addresses(Id,AddSectionType,AddType,AddTypeId,AddTypeIdInt,AddressBookId,Status,DocumentId,EntityId,ScreenName,IsCurrentAddress,CompanyId)
											Select NEWID(),AddSectionType,'AccountContactDetail',@CntDtlDestId,AddTypeIdInt,AddressBookId,Status,@SourceId,null,null,IsCurrentAddress,CompanyId From Common.Addresses Where Id=@AddressId /*And CompanyId=@CompanyId*/
									End
								End
							End
							Set @IndCount=@IndCount+1
						End
						Truncate Table #Loc_AdrsTbl
					End 
					-- ContactDetail From Entity
					Begin
						Set @IndCount=1
						Insert into #Loc_AdrsTbl
						Select Distinct Adrs.id As AddressId,Adrs.AddressBookId,Adrs.AddSectionType,Adrs.AddTypeId,A.EntityId From Common.Addresses As Adrs
						Inner join Common.ContactDetails As A On A.Id=Adrs.AddTypeId 
						Where A.EntityId =@SyncAccountId
						Select @AdrsCount=count(*) From #Loc_AdrsTbl
						While @AdrsCount>=@IndCount
						Begin
							Select @AddressId=AddressId,@AddressBookId=AddressBookId,@AddrsAddSecType=AddSectionType,@AdrsEntityId=AdrsEntityId From #Loc_AdrsTbl Where Id=@IndCount
							--Select @ContactId=ContactId,@SyncAccountId=EntityId From Common.ContactDetails Where Id=@AdrsEntityId
							If @ContactId Is Not null And @SyncAccountId Is Not Null
							Begin
								--Set @SyncAccountId=(Select SyncAccountId From WorkFlow.Client Where CompanyId=@CompanyId And Id=@SyncClientId And SyncAccountId Is Not Null)
								If @SourceId Is Not Null
								Begin
									Select @CntDtlDestId=Id From Common.ContactDetails Where EntityId=@SourceId And ContactId=@ContactId
									If Not Exists (Select Id From Common.Addresses Where Addsectiontype=@AddrsAddSecType And AddTypeId=@CntDtlDestId And AddressBookId=@AddressBookId /*And CompanyId=@CompanyId*/)
									Begin
										Delete From Common.Addresses Where Id=@AddressId
										Delete From Common.AddressBook Where Id=@AddressBookId And Not Exists (Select Id From Common.Addresses Where AddressBookId=@AddressBookId)
									End
								End
							End
							Set @IndCount=@IndCount+1
						End
						Truncate Table #Loc_AdrsTbl
					End 

				End

			End
		End
		
		Commit Transaction
	End Try
	
	Begin Catch
		Rollback Transaction
		Print Error_Message()
	End Catch
End
GO
