USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [Import].[HRSync_Emp_To_Entity]    Script Date: 16-12-2024 9.20.11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




create Procedure [Import].[HRSync_Emp_To_Entity]-- Exec [Import].[HRSync_Emp_To_Entity] 1077
@CompanyId BigInt,
@TransactionId uniqueidentifier
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
	    declare @startdate [datetime2](7)
        declare @Enddate [datetime2](7)
        SET @startdate= GETUTCDATE()

		Select @BaseCurrency=BaseCurrency from SmartCursorTST.bean.FinancialSetting where CompanyId=@CompanyId
		If @BaseCurrency is null Set @BaseCurrency='SGD'
		--======================================= Check Bean Cursor ative or inactive==================================================
		If Exists(Select Id From SmartCursorTST.Common.CompanyModule Where CompanyId=@CompanyId And ModuleId in (Select Id from SmartCursorTST.Common.ModuleMaster Where Name='Bean Cursor') And Status=1)
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
			--=============================================insert into Entity table from Employee====================================
			Insert Into SmartCursorTST.Bean.Entity (Id,CompanyId,Name,DocumentId,TypeId,IdTypeId,IdNo,IsCustomer,IsVendor,VenTOPId,VenCurrency,VenNature,
			RecOrder,Remarks,UserCreated,CreatedDate,Communication,Status,IsExternalData,IsShowPayroll,VendorType,ExternalEntityType,SyncEmployeeId,SyncEmployeeStatus,SyncEmployeeDate,SyncEmployeeRemarks)
			
			Select Newid(),CompanyId,CONCAT(FirstName,'(',EmployeeId,')'),Id,null,null,IdNo,0,1,(select id from SmartCursorTST.common.termsofpayment where companyid=@companyId and name='Credit - 0'),
			@BaseCurrency,'Others',1,Remarks,@UserCreatedOrModified,@GetDate,Communication,Status,@IsExternalData,1,'Employee','Employee',Id,@SyncStatusCompleted,@GetDate,null
			From SmartCursorTST.Common.Employee
			Where Companyid=@CompanyId
			And Id Not In (Select SyncEmployeeId From SmartCursorTST.Bean.Entity Where CompanyId=@CompanyId And SyncEmployeeId Is Not Null) 
			Order by FirstName

			--=================================update Syncdetails in employee table =====================================
			Update Emp Set Emp.SyncEntityId=E.Id,Emp.SyncEntityDate=@GetDate,Emp.SyncEntityStatus=@SyncStatusCompleted,Emp.SyncEntityRemarks=null From SmartCursorTST.Common.Employee As Emp
			Inner Join SmartCursorTST.Bean.Entity As E On E.SyncEmployeeId=Emp.Id
			Where E.CompanyId=@CompanyId And E.Createddate=@GetDate
			--==================Insert into Addresses table from From Employee ========================================
			Insert Into SmartCursorTST.Common.Addresses(Id,AddSectionType,AddType,AddTypeId,AddTypeIdInt,AddressBookId,Status,DocumentId,EntityId,ScreenName,IsCurrentAddress,CompanyId)
			Select Distinct NEWID() AS Id,Adrs.AddSectionType,'Entity' AS AddType,Emp.SyncEntityId AS AddTypeId,Adrs.AddTypeIdInt,Adrs.AddressBookId,
			Adrs.Status,Adrs.AddTypeId ,NULL AS EntityId,NULL AS ScreenName,Adrs.IsCurrentAddress,@CompanyId AS CompanyId
			From SmartCursorTST.Common.Addresses As Adrs
			Inner join SmartCursorTST.Common.Employee As Emp On Emp.Id=Adrs.AddTypeId 
			Where Emp.CompanyId=@CompanyId And Emp.SyncEntityId Is Not Null And Emp.SyncEntityDate=@GetDate 
			AND Emp.SyncEntityId NOT IN (
	           Select Distinct AddTypeId  From SmartCursorTST.Common.Addresses As Adrs
			Inner join SmartCursorTST.Bean.Entity As A On A.Id=Adrs.AddTypeId 
			Where A.CompanyId=@CompanyId And A.SyncEmployeeId  Is Not Null  And A.CreatedDate=@GetDate 
			)
			
		end		
	       SET @Enddate= GETUTCDATE()
    insert into SmartCursorTST.[Import].[TransactionDetails]
    select newid(),@companyId,@TransactionId,'HR',@startdate,@Enddate,'HRSync_Emp_To_Entity Completed',(select count(*) from [Import].[HRPersonalDetails] where TransactionId= @TransactionId ),( select count(*) from [Import].[HRFailurePersonalDetails] where TransactionId=@TransactionId),
    ( select count(*) from [Import].[HRSuccessPersonalDetails] where TransactionId=@TransactionId),null


--========================================================IsPrimaryContact====================================================


  COMMIT TRANSACTION;
END TRY
BEGIN CATCH
	Declare @ErrorMessage Nvarchar(4000)
	ROLLBACK;
	Select @ErrorMessage=error_message();
	  If @ErrorMessage is not null
	  begin 
	  insert into SmartCursorTST.[Import].[TransactionDetails]
	  select newid(),@companyId,@TransactionId,'HR',GETUTCDATE(),GETUTCDATE(),'HRSync_Emp_To_Entity Error',(select count(*) from [Import].[HRPersonalDetails] where TransactionId= @TransactionId ),(select count(*) from [Import].[HRPersonalDetails] where TransactionId= @TransactionId ),null,@ErrorMessage
	  end 
	Raiserror(@ErrorMessage,16,1);
END CATCH
End
GO
