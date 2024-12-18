USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[Import_Emp_To_Entity]    Script Date: 16-12-2024 9.20.10 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE Procedure [dbo].[Import_Emp_To_Entity]
@CompanyId BigInt
As
Begin
	Declare @UserCreatedOrModified Varchar(10),
		@GetDate DateTime2,
		@BaseCurrency varchar(20),
		@SyncStatusCompleted varchar(20),
		@SyncStatusUpdateCompleted varchar(20),
		@IsExternalData Int,
		@SysRefNumber Nvarchar(50),
		@IndCount Int,
		@Count int,
		@SyncEntityId Uniqueidentifier,
		@AdrsSyncEntityId Uniqueidentifier,
		@AddressBookId Uniqueidentifier,
		@AdrsEntityId Uniqueidentifier,
		@AdrsCount int,
		@New_ContctDtlId Uniqueidentifier,
		@cntdtlAddType Nvarchar(200),
		@AddrsAddSecType Nvarchar(100),
		@AdrsSyncEmployeeId Uniqueidentifier,
		@AddressId UniqueIdentifier,
		@CntDtlDestId UniqueIdentifier
	Set @UserCreatedOrModified='System'
	Set @GetDate=Getutcdate()
	Set @SyncStatusCompleted='Completed'
	Set @SyncStatusUpdateCompleted='UpdateCompleted'
	Set @IsExternalData=1
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

		Select @BaseCurrency=BaseCurrency from bean.FinancialSetting where CompanyId=@CompanyId
		If @BaseCurrency is null Set @BaseCurrency='SGD'

		If Exists(Select Id From Common.CompanyModule Where CompanyId=@CompanyId And ModuleId in (Select Id from Common.ModuleMaster Where Name='Bean Cursor') And Status=1)
		Begin
			/*
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
			*/
			--insert into Entity table
			Insert Into Bean.Entity (Id,CompanyId,Name,DocumentId,TypeId,IdTypeId,IdNo,IsCustomer,IsVendor,VenTOPId,VenCurrency,VenNature,
				RecOrder,Remarks,UserCreated,CreatedDate,Communication,Status,IsExternalData,IsShowPayroll,VendorType,ExternalEntityType,SyncEmployeeId,SyncEmployeeStatus,SyncEmployeeDate,SyncEmployeeRemarks)
			Select Newid(),CompanyId,CONCAT(FirstName,'(',EmployeeId,')'),Id,null,null,IdNo,0,1,(select id from common.termsofpayment where companyid=@companyId and name='Credit - 0'),
				@BaseCurrency,'Others',1,Remarks,@UserCreatedOrModified,@GetDate,Communication,Status,@IsExternalData,1,'Employee','Employee',Id,@SyncStatusCompleted,@GetDate,null
			From Common.Employee
			Where Companyid=@CompanyId
			And Id Not In (Select SyncEmployeeId From Bean.Entity Where CompanyId=@CompanyId And SyncEmployeeId Is Not Null) 
			Order by FirstName
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
					If Not Exists (Select Id From Common.Addresses Where Addsectiontype=@AddrsAddSecType And AddTypeId=@AdrsSyncEntityId And AddressBookId=@AddressBookId /*And CompanyId=@CompanyId*/)
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
		Drop table #Loc_Cont_Tbl
		Drop table #Loc_AdrsTbl
		Commit Transaction
	End Try
	Begin Catch
		rollback transaction
		Print Error_Message()
	End Catch
End
GO
