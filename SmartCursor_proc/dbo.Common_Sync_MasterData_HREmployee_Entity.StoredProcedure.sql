USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[Common_Sync_MasterData_HREmployee_Entity]    Script Date: 16-12-2024 9.20.10 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

--Exec  [dbo].[Common_Sync_MasterData_HREmployee_Entity] 2058,'E2586C95-3E2E-4911-88DF-FCE98746F37C','Add'
CREATE Procedure [dbo].[Common_Sync_MasterData_HREmployee_Entity]
	@CompanyId BigInt, 
	@HREmpId Uniqueidentifier,
	@Action Varchar(50)
As
Begin
	Declare @UserCreatedOrModfd Varchar(10),
			@GetDate DateTime2,
			@EntityId Uniqueidentifier,
			@BaseCurrency varchar(20),
			@SyncStatusCompleted varchar(20),
			@SyncStatusUpdateCompleted varchar(20),
			@SyncStatusUpdateFalied varchar(20),
			@SyncStatusFailed varchar(20),
			@IsExternalData Int,
			@CustNature Varchar(20),
			@IndCount Int,
			@AdrsCount Int,
			@AddrsAddSecType nvarchar(200),
			@AdrsSyncEmployeeId Uniqueidentifier,
			@AddressId Uniqueidentifier,
			@AdrsEntityId Uniqueidentifier,
			@AdrsSyncEntityId Uniqueidentifier,
			@AddressBookId Uniqueidentifier
		Set @UserCreatedOrModfd='System'
		Set @GetDate=Getutcdate()
		Set @SyncStatusCompleted='Completed'
		Set @SyncStatusUpdateCompleted='UpdateCompleted'
		Set @SyncStatusUpdateFalied='UpdateFailed'
		Set @IsExternalData=1
		Set @SyncStatusFailed='Failed'
	Select @BaseCurrency=BaseCurrency from bean.FinancialSetting where CompanyId=@CompanyId
	If @BaseCurrency is null Set @BaseCurrency='SGD'

	--Declare Temp Table variable to store contact deatils
	if object_id('tempdb..#Loc_Cont_Tbl', 'U') is null
	Create Table #Loc_Cont_Tbl (Id Int Identity(1,1),ContactDetailId Uniqueidentifier,EntityType Nvarchar(200),ContactId Uniqueidentifier,EntityId Uniqueidentifier,DestId Uniqueidentifier)
	--Declare Temp Table variable to store Addresses deatils
	if object_id('tempdb..#Loc_AdrsTbl', 'U') is null
	Create Table #Loc_AdrsTbl (Id Int Identity(1,1),AddressId Uniqueidentifier,AddressBookId Uniqueidentifier,AddSectionType NVarchar(100),AdrsEntityId Uniqueidentifier,DestId Uniqueidentifier)
	Truncate Table #Loc_Cont_Tbl
	Truncate Table #Loc_AdrsTbl
		
--Begin Transaction
Begin Transaction
	--Try Block For Whole Transaction
	Begin Try
		If(@Action='Add')
		Begin
			If Not Exists(Select Id From Bean.Entity Where CompanyId=@CompanyId And SyncEmployeeId=@HREmpId)
			Begin
				Begin Try
					Set @EntityId=NEWID()

					Insert Into Bean.Entity (Id,CompanyId,Name,DocumentId,TypeId,IdTypeId,IdNo,IsCustomer,IsVendor,VenTOPId,VenCurrency,VenNature,RecOrder,Remarks,UserCreated,CreatedDate,Communication,Status,IsExternalData,IsShowPayroll,VendorType,ExternalEntityType,SyncEmployeeId,SyncEmployeeStatus,SyncEmployeeDate,SyncEmployeeRemarks)
					Select @EntityId,CompanyId,CONCAT(FirstName,'(',EmployeeId,')'),@HREmpId,null,null,IdNo,0,1,(select id from common.termsofpayment where companyid=@companyId and name='Credit - 0' and isvendor = 1),
						@BaseCurrency,'Others',1,Remarks,@UserCreatedOrModfd,CreatedDate,Communication,1,1,1,'Employee','Employee',@HREmpId,@SyncStatusCompleted,@GetDate,null
						from Common.Employee where Id=@HREmpId
						
					Update Common.Employee Set SyncEntityId=@EntityId,SyncEntityDate=@GetDate,SyncEntityStatus=@SyncStatusCompleted,SyncEntityRemarks=null Where Id=@HREmpId And CompanyId=@CompanyId
					--Addresses From Employee
					Begin
						Set @IndCount=1
						Insert into #Loc_AdrsTbl
						Select Distinct Adrs.id As AddressId,Adrs.AddressBookId,Adrs.AddSectionType,Adrs.AddTypeId,Emp.SyncEntityId From Common.Addresses As Adrs
						Inner join Common.Employee As Emp On Emp.Id=Adrs.AddTypeId 
						Where Emp.CompanyId=@CompanyId And Emp.SyncEntityId =@EntityId
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
						Where A.CompanyId=@CompanyId And A.SyncEmployeeId =@HREmpId
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
				End Try
				Begin Catch
					Declare @ErrMsg Nvarchar(max)
					Set @ErrMsg=(Select ERROR_MESSAGE())
					Update Common.Employee Set SyncEntityDate=@GetDate,SyncEntityStatus=@SyncStatusFailed,SyncEntityRemarks=@ErrMsg Where Id=@HREmpId And CompanyId=@CompanyId
				End Catch
			End
			Else
			Begin
				Exec [dbo].[Common_Sync_MasterData_HREmployee_Entity] @CompanyId,@HREmpId,'Edit'
			End
		End
		--Update bean.Entity table records based on documentid which is edited in common.Employee table	
		Else If(@Action='Edit')
		Begin
			--Edit
			If Exists (Select Id From Bean.Entity Where CompanyId=@CompanyId And SyncEmployeeId=@HREmpId)
			Begin
				Begin Try
					
					Update E Set E.CompanyId=@CompanyId,E.Name=CONCAT(FirstName,'(',EmployeeId,')'),E.DocumentId=@HREmpId,E.TypeId=null,E.IdTypeId=Null,E.IdNo=Emp.IdNo,E.IsCustomer=0,E.IsVendor=1,E.VenCurrency=@BaseCurrency,E.VenNature='Others',E.RecOrder=1,E.Remarks=Emp.Remarks,ModifiedBy=@UserCreatedOrModfd,
					E.ModifiedDate=Emp.ModifiedDate,E.Communication=Emp.Communication,E.Status=1,E.IsExternalData=1,E.IsShowPayroll=1,E.VendorType='Employee',E.ExternalEntityType='Employee',E.SyncEmployeeDate=@GetDate,E.SyncEmployeeRemarks=null,SyncEmployeeStatus=@SyncStatusUpdateCompleted,E.VenTOPId=(select id from common.termsofpayment where companyid=@companyId and name='Credit - 0')
					From Bean.Entity As E 
					Inner Join Common.Employee As Emp On Emp.SyncEntityId=E.Id
					Where Emp.Id= @HREmpId And Emp.CompanyId=@CompanyId
					Update Common.Employee Set SyncEntityDate=@GetDate,SyncEntityStatus=@SyncStatusUpdateCompleted,SyncEntityRemarks=null Where Id=@HREmpId And CompanyId=@CompanyId
					--Addresses From Employee
					Begin
						Set @IndCount=1
						Insert into #Loc_AdrsTbl
						Select Distinct Adrs.id As AddressId,Adrs.AddressBookId,Adrs.AddSectionType,Adrs.AddTypeId,Emp.SyncEntityId From Common.Addresses As Adrs
						Inner join Common.Employee As Emp On Emp.Id=Adrs.AddTypeId 
						Where Emp.CompanyId=@CompanyId And Emp.SyncEntityId =@EntityId
						Select @AdrsCount=count(*) From #Loc_AdrsTbl
						While @AdrsCount>=@IndCount
						Begin
							Select @AddressId=AddressId,@AddressBookId=AddressBookId,@AddrsAddSecType=AddSectionType,@AdrsEntityId=AdrsEntityId,@AdrsSyncEntityId=DestId From #Loc_AdrsTbl Where Id=@IndCount
							If Not Exists (Select Id From Common.Addresses Where Addsectiontype=@AddrsAddSecType And AddTypeId=@AdrsSyncEntityId And Addressbookid=@AddressBookId/*And CompanyId=@CompanyId*/)
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
						Where A.CompanyId=@CompanyId And A.SyncEmployeeId =@HREmpId
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
								
				End Try
				Begin catch
					Declare @UpdtErrMsg Nvarchar(Max)
					Set @ErrMsg=(Select ERROR_MESSAGE())
					Update Common.Employee Set SyncEntityDate=@GetDate,SyncEntityStatus=@SyncStatusUpdateFalied,SyncEntityRemarks=@UpdtErrMsg Where Id=@HREmpId And CompanyId=@CompanyId
				End Catch
			End
			/*
			Else 
			Begin
				Exec [dbo].[Common_Sync_MasterData_HREmployee_Entity] @CompanyId,@HREmpId,'Add'
			End
			*/
		End
		Else If(@Action='Active' OR @Action='Inactive')
		Begin
			If Exists (Select Id From Bean.Entity Where SyncEmployeeId=@HREmpId And CompanyId=@CompanyId)
			Begin
				Begin Try
					Update Bean.Entity Set Status = Case When @Action='Active' Then 1 When @Action='Inactive' Then 2 End ,ModifiedBy=@UserCreatedOrModfd,ModifiedDate=@GetDate,SyncEmployeeStatus=@SyncStatusUpdateCompleted,SyncEmployeeDate=@GetDate,SyncEmployeeRemarks=Null
					Where SyncEmployeeId=@HREmpId And CompanyId=@CompanyId
					Update Common.Employee Set SyncEntityId=@EntityId,SyncEntityDate=@GetDate,SyncEntityStatus=@SyncStatusUpdateCompleted,SyncEntityRemarks=null Where Id=@HREmpId And CompanyId=@CompanyId

				End Try
				Begin Catch
					Declare @ActErrMsg Nvarchar(Max)
					Set @ErrMsg=(Select ERROR_MESSAGE())
					Update Common.Employee Set SyncEntityDate=@GetDate,SyncEntityStatus=@SyncStatusUpdateFalied,SyncEntityRemarks=@ActErrMsg Where Id=@HREmpId And CompanyId=@CompanyId
				End Catch
			End
		End
		--Commit Transaction
		Commit Transaction
	End Try

	Begin Catch
		Rollback Transaction;
		Print Error_Message()
	End Catch

End
GO
