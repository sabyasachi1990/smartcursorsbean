USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [Import].[CCSync_Account_To_Client_To_Entity]    Script Date: 16-12-2024 9.20.11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE Procedure [Import].[CCSync_Account_To_Client_To_Entity] ---EXEC [Import].[CCSync_Account_To_Client_To_Entity] 1077
@CompanyId BigInt,
@TransactionId uniqueidentifier
As
Begin
--declare @CompanyId BigInt=1077	
Declare @GeneratedNumber Varchar(100),
		@SystemRefnum Varchar(100),
		@UserCreatedOrModified Varchar(10),
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
		set @BaseCurrency = (select Distinct  BaseCurrency from SmartCursorTST.Common.Localization where  CompanyId=@CompanyId)
		If @BaseCurrency is null Set @BaseCurrency='SGD'
	    Begin Transaction
	    Begin Try
		     declare @startdate [datetime2](7)
             declare @Enddate [datetime2](7)
             SET @startdate= GETUTCDATE()
		--=========================================Check Workflow Cursor Active or Inactive=====================================
        If Exists(Select Id From SmartCursorTST.Common.CompanyModule Where CompanyId=@CompanyId And ModuleId in (Select Id from SmartCursorTST.Common.ModuleMaster Where Name='Workflow Cursor') And Status=1)
		Begin
			--====================================Getting systemrefnumber=======================================
			Set @GeneratedNumber=(Select GeneratedNumber From SmartCursorTST.Common.AutoNumber Where CompanyId=@CompanyId And EntityType='WorkFlow Client' And ModuleMasterId=(Select Id From SmartCursorTST.Common.ModuleMaster Where Name='Workflow Cursor'))
			Set @SystemRefnum=(Select Top(1) SystemRefNo From SmartCursorTST.WorkFlow.Client Where CompanyId=@CompanyId And SystemRefNo Is not null Order By SystemRefNo Desc)
			If @SystemRefnum Is Null or @SystemRefnum =''
	        Begin
		       Set @SystemRefnum=(Select Preview From SmartCursorTST.Common.AutoNumber Where CompanyId=@CompanyId And EntityType='WorkFlow Client' And ModuleMasterId=(Select Id From SmartCursorTST.Common.ModuleMaster Where Name='Workflow Cursor'))
	        End
	        Set @SystemRefnum=Reverse(SUBSTRING(Reverse(@SystemRefnum),PATINDEX('%[0-9][^0-9]%', Reverse(@SystemRefnum))+1,DATALENGTH(@SystemRefnum)))

			--==================Insert into client table from account table========================================
			Insert Into SmartCursorTST.WorkFlow.Client (Id,Name,CompanyId,ClientTypeId,IdtypeId,ClientIdNo,TermsOfPaymentId,Industry,Source,SourceId,SourceName,SourceRemarks,IncorporationDate,FinancialYearEnd,CountryOfIncorporation,ClientStatus,PrincipalActivities,RecOrder,Remarks,UserCreated,CreatedDate,Version,Status,Communication,SystemRefNo,SyncAccountId,SyncAccountStatus,SyncAccountRemarks,SyncAccountDate)
			Select  NEWID(),Name,@CompanyId,AccountTypeId,AccountIdTypeId,AccountIdNo,TermsOfPaymentId,Industry,Source,SourceId,SourceName,SourceRemarks,IncorporationDate,FinancialYearEnd,CountryOfIncorporation,AccountStatus,PrincipalActivities,RecOrder,Remarks,@UserCreatedOrModified,@GetDate,Version,Status,Communication,
			CONCAT(@SystemRefnum,Right('0000000000'+Cast((@GeneratedNumber+ROW_NUMBER () Over (Order By Id) ) As varchar),Len(@GeneratedNumber))),Id,@SyncStatusCompleted,Null,@GetDate
			From SmartCursorTST.ClientCursor.Account 
			Where CompanyId=@CompanyId And IsAccount=1 And Status=1
			And Id Not In (Select SyncAccountId From SmartCursorTST.WorkFlow.Client Where CompanyId=@CompanyId And SyncAccountId Is Not NUll)
			And Isnull(SyncEntityId,'00000000-0000-0000-0000-000000000000') Not In (Select SyncEntityId From SmartCursorTST.WorkFlow.Client Where CompanyId=@CompanyId And SyncEntityId Is not null)
			--AND NAME='A+U Publishing Pte. Ltd.802'
			Order by Name
			
			--==================Insert into ClientStatusChange table from account table ========================================
			Insert Into SmartCursorTST.WorkFlow.ClientStatusChange (Id,CompanyId,ClientId,State,ModifiedBy,ModifiedDate)
			Select Newid(),@CompanyId,Id,'Active',@UserCreatedOrModified,@GetDate From SmartCursorTST.WorkFlow.Client Where CompanyId=@CompanyId And CreatedDate=@GetDate
			and id not in (select distinct ClientId from  SmartCursorTST.WorkFlow.ClientStatusChange where ClientId is not null and CompanyId=@companyid)
			
			--======================= UPDATE SyncClientId FROM account table 
			Update A Set A.SyncClientId=C.Id,A.ClientId=C.Id,A.SyncClientDate=@GetDate,A.SyncClientStatus=@SyncStatusCompleted,A.SyncClientRemarks=Null 
			From SmartCursorTST.ClientCursor.Account As A
			Inner Join SmartCursorTST.WorkFlow.Client As C On C.SyncAccountId=A.Id 
			Where A.CompanyId=@CompanyId And C.CreatedDate=@GetDate 
			and A.SyncClientId is null
			
			----====================================Update Autogeneratenumber=========================================
			Set @SystemRefnum=(Select Top(1) SystemRefNo From SmartCursorTST.WorkFlow.Client Where CompanyId=@CompanyId And SystemRefNo Is not null Order By SystemRefNo Desc)
			Set @SystemRefnum=Reverse(SUBSTRING(Reverse(@SystemRefnum),0,PATINDEX('%[0-9][^0-9]%', Reverse(@SystemRefnum))+1))
			Update SmartCursorTST.Common.AutoNumber Set GeneratedNumber=@SystemRefnum
			Where CompanyId=@CompanyId And EntityType='WorkFlow Client' And ModuleMasterId=(Select Id From SmartCursorTST.Common.ModuleMaster Where Name='Workflow Cursor')
			
			--==================Insert into Addresses table from account table ========================================
			Insert Into SmartCursorTST.Common.Addresses(Id,AddSectionType,AddType,AddTypeId,AddTypeIdInt,AddressBookId,Status,DocumentId,EntityId,ScreenName,IsCurrentAddress,CompanyId)
			Select Distinct NEWID() AS Id,Adrs.AddSectionType,'Client' AS AddType,A.SyncClientId AS AddTypeId,Adrs.AddTypeIdInt,Adrs.AddressBookId,
			Adrs.Status,Adrs.AddTypeId ,NULL AS EntityId,NULL AS ScreenName,Adrs.IsCurrentAddress,@CompanyId AS CompanyId
			From SmartCursorTST.Common.Addresses As Adrs
			Inner join SmartCursorTST.ClientCursor.Account As A On A.Id=Adrs.AddTypeId 
			Where A.CompanyId=@CompanyId And A.SyncClientId Is Not Null and IsAccount=1 And A.SyncClientDate=@GetDate 
			AND A.SyncClientId NOT IN (
	           Select Distinct AddTypeId  From SmartCursorTST.Common.Addresses As Adrs
			Inner Join SmartCursorTST.WorkFlow.Client As A On A.Id=Adrs.AddTypeId 
			Where A.CompanyId=@CompanyId And A.SyncAccountId  Is Not Null  And A.CreatedDate=@GetDate 
			)
			 --   AND Adrs.AddressBookId  NOT IN	(
				--Select Distinct Adrs.AddressBookId From SmartCursorTST.Common.Addresses As Adrs
				--Inner Join WorkFlow.Client As A On A.Id=Adrs.AddTypeId 
				--Where A.CompanyId=@CompanyId And A.SyncAccountId  Is Not Null -- And A.CreatedDate=@GetDate 
				--and Adrs.AddressBookId  IS NOT NULL
				--)
				--AND Adrs.AddSectionType NOT IN (
				--Select Distinct Addsectiontype From SmartCursorTST.Common.Addresses As Adrs
				--Inner Join WorkFlow.Client As A On A.Id=Adrs.AddTypeId 
				--Where A.CompanyId=@CompanyId And A.SyncAccountId Is Not Null --And A.CreatedDate=@GetDate
				--and Addsectiontype IS NOT NULL  
				--AND Adrs.AddressBookId  NOT IN	(
				--Select Distinct Adrs.AddressBookId From SmartCursorTST.Common.Addresses As Adrs
				--Inner Join WorkFlow.Client As A On A.Id=Adrs.AddTypeId 
				--Where A.CompanyId=@CompanyId And A.SyncAccountId  Is Not Null -- And A.CreatedDate=@GetDate 
				--and Adrs.AddressBookId  IS NOT NULL
				--) 
				--)


					--============================== UPDATE CLIENT ContactDetails FROM Account ContactDetails=========================
				Update A Set A.Designation=B.Designation,A.Communication=B.Communication,A.IsPrimaryContact=B.IsPrimaryContact,A.Matters=B.Matters,A.RecOrder=B.RecOrder,A.Status=B.Status,A.IsReminderReceipient=B.IsReminderReceipient,A.ModifiedBy=@UserCreatedOrModified,ModifiedDate=@GetDate,A.Remarks=B.Remarks,a.IsCopy=b.IsCopy From SmartCursorTST.Common.ContactDetails As A
				Inner Join 
				(Select A.SyncClientId,B.ContactId,B.Designation,B.Communication, B.IsPrimaryContact,B.Matters,B.RecOrder,B.IsReminderReceipient,B.Remarks,b.IsCopy,B.Status 
				From SmartCursorTST.Common.ContactDetails B
				Inner Join SmartCursorTST.ClientCursor.Account As A On A.Id=B.EntityId
				Inner Join SmartCursorTST.Common.Contact As C On C.Id=B.ContactId 
				--LEFT Join SmartCursorTST.ClientCursor.Account As A On A.SyncClientId=CD.EntityId
				Where A.CompanyId=@CompanyId And A.SyncClientId Is NOT  Null and A.IsAccount=1 And A.SyncClientDate=@GetDate 
				) As B On B.ContactId=A.ContactId
				Where A.EntityId=B.SyncClientId
				----===================================Insert into ContactDetails From Account ContactDetails=====================================
			    Insert Into SmartCursorTST.Common.ContactDetails (Id,ContactId,EntityId,EntityType,Designation,Communication,Matters,IsPrimaryContact,IsReminderReceipient,RecOrder,OtherDesignation,IsPinned,CursorShortCode,Status,UserCreated,CreatedDate,Remarks,DocId,DocType,IsCopy)
				Select Distinct NewId() AS Id,CD.ContactId,A.SyncClientId AS EntityId,'Client' AS EntityType,CD.Designation,CD.Communication,CD.Matters,
				CD.IsPrimaryContact,CD.IsReminderReceipient,CD.RecOrder,CD.OtherDesignation,CD.IsPinned,'WF' AS CursorShortCode,
				CD.Status,@UserCreatedOrModified AS UserCreated,@Getdate AS CreatedDate,CD.Remarks,CD.EntityId AS DocId,'Account' AS DocType,CD.IsCopy
				From SmartCursorTST.Common.ContactDetails As CD
				Inner Join SmartCursorTST.ClientCursor.Account As A On A.Id=CD.EntityId
				Inner Join SmartCursorTST.Common.Contact As C On C.Id=CD.ContactId 
				--LEFT Join SmartCursorTST.ClientCursor.Account As A On A.SyncClientId=CD.EntityId
				Where A.CompanyId=@CompanyId And A.SyncClientId Is Not Null  and A.IsAccount=1 And A.SyncClientDate=@GetDate 
				AND CD.ContactId NOT IN (
				Select Distinct CD.ContactId
				From SmartCursorTST.Common.ContactDetails As CD
				--Inner Join SmartCursorTST.ClientCursor.Account As A On A.Id=CD.EntityId
				Inner Join SmartCursorTST.Common.Contact As C On C.Id=CD.ContactId 
				Inner Join SmartCursorTST.ClientCursor.Account As A On A.SyncClientId=CD.EntityId
				Where A.CompanyId=@CompanyId And A.SyncClientId Is Not Null and A.IsAccount=1 And A.SyncClientDate=@GetDate 
				)
				AND CD.EntityId NOT IN (
				Select Distinct CD.EntityId
				From SmartCursorTST.Common.ContactDetails As CD
				--Inner Join SmartCursorTST.ClientCursor.Account As A On A.Id=CD.EntityId
				Inner Join SmartCursorTST.Common.Contact As C On C.Id=CD.ContactId 
				Inner Join SmartCursorTST.ClientCursor.Account As A On A.SyncClientId=CD.EntityId
				Where A.CompanyId=@CompanyId And A.SyncClientId Is Not Null and A.IsAccount=1 And A.SyncClientDate=@GetDate 
				)
			

				--DELETE CD From SmartCursorTST.Common.ContactDetails As CD
				--Inner Join WorkFlow.Client As A On A.Id=CD.EntityId
				--Inner Join SmartCursorTST.Common.Contact As C On C.Id=CD.ContactId 
				--Where A.CompanyId=@CompanyId And A.SyncAccountId Is Not Null 
				--AND CD.ContactId NOT IN 
				--(Select Distinct B.ContactId
				--From SmartCursorTST.Common.ContactDetails B
				--Inner Join SmartCursorTST.ClientCursor.Account As A On A.Id=B.EntityId
				--Inner Join SmartCursorTST.Common.Contact As C On C.Id=B.ContactId 
				----LEFT Join SmartCursorTST.ClientCursor.Account As A On A.SyncClientId=CD.EntityId
				--Where A.CompanyId=@CompanyId And A.SyncClientId Is NOT  Null and A.IsAccount=1 And A.SyncClientDate=@GetDate
				--)
				--AND A.SyncAccountId  NOT IN 
				--(Select Distinct B.EntityId
				--From SmartCursorTST.Common.ContactDetails B
				--Inner Join SmartCursorTST.ClientCursor.Account As A On A.Id=B.EntityId
				--Inner Join SmartCursorTST.Common.Contact As C On C.Id=B.ContactId 
				----LEFT Join SmartCursorTST.ClientCursor.Account As A On A.SyncClientId=CD.EntityId
				--Where A.CompanyId=@CompanyId And A.SyncClientId Is NOT  Null and A.IsAccount=1 And A.SyncClientDate=@GetDate
				--)

			----===================================Insert into @wfContactDetails From Account ContactDetails Addresses =====================================
				declare @wfContactDetails table(ContactDetailsId uniqueidentifier,Accountid uniqueidentifier,ClientId uniqueidentifier)
			    INSERT INTO @wfContactDetails
				Select Distinct CD.id,a.id,a.SyncClientId
				From SmartCursorTST.Common.ContactDetails As CD
				--Inner Join SmartCursorTST.ClientCursor.Account As A On A.Id=CD.EntityId
				Inner Join SmartCursorTST.Common.Contact As C On C.Id=CD.ContactId 
				Inner Join SmartCursorTST.ClientCursor.Account As A On A.SyncClientId=CD.EntityId
				Where A.CompanyId=@CompanyId And A.SyncClientId Is Not Null and A.IsAccount=1 AND A.SyncClientDate=@GetDate
				--AND A.NAME IN ('Ms. A+U Publishing Pte. Ltd.1010')
				
			----===================================Insert into Addresses From Account ContactDetails Addresses=====================================
				Insert Into SmartCursorTST.Common.Addresses(Id,AddSectionType,AddType,AddTypeId,AddTypeIdInt,AddressBookId,Status,DocumentId,EntityId,ScreenName,IsCurrentAddress,CompanyId)
				Select Distinct   NEWID() AS Id,Adrs.AddSectionType,'ClientContactDetailId' AS AddType,CC.ContactDetailsId AS AddTypeId,Adrs.AddTypeIdInt,Adrs.AddressBookId,
				Adrs.Status,Adrs.AddTypeId,NULL AS EntityId,'WF' AS ScreenName,Adrs.IsCurrentAddress,@CompanyId AS CompanyId
			    From SmartCursorTST.Common.Addresses As Adrs
				Inner join SmartCursorTST.Common.ContactDetails As A On A.Id=Adrs.AddTypeId 
				INNER join @wfContactDetails CC ON CC.Accountid=A.EntityId
				Where CompanyId=@CompanyId --And A.CreatedDate=@GetDate  
				AND A.EntityId In (Select Id From SmartCursorTST.ClientCursor.Account Where CompanyId=@CompanyId and isaccount=1 And SyncClientId Is Not Null And SyncClientDate=@GetDate
				)
				AND CC.ContactDetailsId NOT IN (
	            Select Distinct A.Id  From SmartCursorTST.Common.Addresses As Adrs
				Inner join SmartCursorTST.Common.ContactDetails As A On A.Id=Adrs.AddTypeId 
				Where Adrs.CompanyId=@CompanyId  And A.CreatedDate=@GetDate 
				and A.Id  IS NOT NULL and A.EntityId In (Select Id From SmartCursorTST.WorkFlow.Client Where CompanyId=@CompanyId And SyncAccountId  Is Not Null  And CreatedDate=@GetDate 
				)
				)
			    AND Adrs.AddressBookId  NOT IN	(
				Select Distinct Adrs.AddressBookId From SmartCursorTST.Common.Addresses As Adrs
				Inner join SmartCursorTST.Common.ContactDetails As A On A.Id=Adrs.AddTypeId 
				Where Adrs.CompanyId=@CompanyId  And A.CreatedDate=@GetDate 
				and Adrs.AddressBookId  IS NOT NULL and A.EntityId In (Select Id From SmartCursorTST.WorkFlow.Client Where CompanyId=@CompanyId And SyncAccountId  Is Not Null  And CreatedDate=@GetDate 
				)
				)
				AND Adrs.AddSectionType NOT IN (
				Select Distinct Addsectiontype From SmartCursorTST.Common.Addresses As Adrs
				Inner join SmartCursorTST.Common.ContactDetails As A On A.Id=Adrs.AddTypeId 
				Where Adrs.CompanyId=@CompanyId  And A.CreatedDate=@GetDate 
				and Adrs.Addsectiontype  IS NOT NULL and A.EntityId In (Select Id From SmartCursorTST.WorkFlow.Client Where CompanyId=@CompanyId And SyncAccountId  Is Not Null  And CreatedDate=@GetDate 
				)  
				AND Adrs.AddressBookId  NOT IN	(
				Select Distinct Adrs.AddressBookId From SmartCursorTST.Common.Addresses As Adrs
				Inner join SmartCursorTST.Common.ContactDetails As A On A.Id=Adrs.AddTypeId 
				Where Adrs.CompanyId=@CompanyId  And A.CreatedDate=@GetDate 
				and Adrs.AddressBookId  IS NOT NULL and A.EntityId In (Select Id From SmartCursorTST.WorkFlow.Client Where CompanyId=@CompanyId And SyncAccountId  Is Not Null  And CreatedDate=@GetDate 
				)
				)
				)



				--		Select Distinct Adrs.AddressBookId From SmartCursorTST.Common.Addresses As Adrs
				--Inner join SmartCursorTST.Common.ContactDetails As A On A.Id=Adrs.AddTypeId 
				--Where    A.EntityId  In('DCDBE409-A0FA-41E6-9415-300E1B48465C')
				--SELECT * FROM  SmartCursorTST.Common.Addresses As Adrs WHERE Adrs.AddTypeId ='9BCBF4FD-C3CF-4979-9B75-A159A7251159'

        End
--======================================================================================================================================
	   --=========================================Check Bean Cursor Active or Inactive==================================
	   If Exists(Select Id From SmartCursorTST.Common.CompanyModule Where CompanyId=@CompanyId And ModuleId in (Select Id from SmartCursorTST.Common.ModuleMaster Where Name='Bean Cursor') And Status=1)
	   Begin
			--========================= Insert Into Bean.Entity Table From Account===========================================
			Insert Into SmartCursorTST.Bean.Entity(Id,Name,CompanyId,TypeId,IdTypeId,IdNo,IsCustomer,CustTOPId,CustCurrency,CustNature,RecOrder,Remarks,UserCreated,CreatedDate,Status,IsExternalData,IsShowPayroll,Communication,ExternalEntityType,SyncAccountId,SyncAccountDate,SyncAccountRemarks,SyncAccountStatus,SyncClientId,SyncClientDate,SyncClientRemarks,SyncClientStatus)
			Select  NEWID(),Name,@CompanyId,AccountTypeId,AccountIdTypeId,AccountIdNo,1 As Iscutomer,Case when TermsOfPaymentId is not null then TermsOfPaymentId else (select id from SmartCursorTST.common.termsofpayment where companyid=@companyId and name='Credit - 0') end,
					@BaseCurrency,'Trade',RecOrder,Remarks,@UserCreatedOrModified,@GetDate,Case When AccountStatus='Active' Then 1 When AccountStatus='Inactive' then 2 End ,@IsExternalData,1 As IsShowPayroll,Communication,'Account',Id,@GetDate,null,@SyncStatusCompleted,SyncClientId,@GetDate,null,@SyncStatusCompleted
			From SmartCursorTST.ClientCursor.Account 
			Where IsAccount=1  and  CompanyId=@CompanyId And Id Not In (select SyncAccountId from SmartCursorTST.Bean.Entity Where CompanyId=@CompanyId And SyncAccountId Is Not Null)
			And Isnull(SyncClientId,'00000000-0000-0000-0000-000000000000') Not In (Select SyncClientId From SmartCursorTST.Bean.Entity Where CompanyId=@CompanyId And SyncClientId Is Not Null)
			--AND NAME='A+U Publishing Pte. Ltd.802'
			order by Name
			-- =================================================Update syncEntity details in Account===========================
			Update A Set A.SyncEntityId=E.Id,A.SyncEntitydate=@GetDate,A.SyncEntityStatus=@SyncStatusCompleted,A.SyncEntityRemarks=Null 

			From SmartCursorTST.ClientCursor.Account As A
			Inner Join SmartCursorTST.Bean.Entity As E On E.SyncAccountId=A.Id 
			Where A.CompanyId=@CompanyId And E.CreatedDate=@GetDate and IsAccount=1

			--==================Insert into Addresses table from account table ========================================
			Insert Into SmartCursorTST.Common.Addresses(Id,AddSectionType,AddType,AddTypeId,AddTypeIdInt,AddressBookId,Status,DocumentId,EntityId,ScreenName,IsCurrentAddress,CompanyId)
			Select Distinct NEWID() AS Id,Adrs.AddSectionType,'Entity' AS AddType,A.SyncEntityId AS AddTypeId,Adrs.AddTypeIdInt,Adrs.AddressBookId,
			Adrs.Status,Adrs.AddTypeId ,NULL AS EntityId,NULL AS ScreenName,Adrs.IsCurrentAddress,@CompanyId AS CompanyId
			From SmartCursorTST.Common.Addresses As Adrs
			Inner join SmartCursorTST.ClientCursor.Account As A On A.Id=Adrs.AddTypeId 
			Where A.CompanyId=@CompanyId And A.SyncEntityId Is Not Null and IsAccount=1 And A.SyncEntityDate=@GetDate 
			AND A.SyncEntityId NOT IN (
	           Select Distinct AddTypeId  From SmartCursorTST.Common.Addresses As Adrs
			Inner join SmartCursorTST.Bean.Entity As A On A.Id=Adrs.AddTypeId 
			Where A.CompanyId=@CompanyId And A.SyncAccountId  Is Not Null  And A.CreatedDate=@GetDate 
			)

						--============================== UPDATE Entity ContactDetails FROM Account ContactDetails=========================
				Update A Set A.Designation=B.Designation,A.Communication=B.Communication,A.IsPrimaryContact=B.IsPrimaryContact,A.Matters=B.Matters,A.RecOrder=B.RecOrder,A.Status=B.Status,A.IsReminderReceipient=B.IsReminderReceipient,A.ModifiedBy=@UserCreatedOrModified,ModifiedDate=@GetDate,A.Remarks=B.Remarks,a.IsCopy=b.IsCopy From SmartCursorTST.Common.ContactDetails As A
				Inner Join 
				(Select A.SyncEntityId,B.ContactId,B.Designation,B.Communication, B.IsPrimaryContact,B.Matters,B.RecOrder,B.IsReminderReceipient,B.Remarks,b.IsCopy,B.Status 
				From SmartCursorTST.Common.ContactDetails B
				Inner Join SmartCursorTST.ClientCursor.Account As A On A.Id=B.EntityId
				Inner Join SmartCursorTST.Common.Contact As C On C.Id=B.ContactId 
				--LEFT Join SmartCursorTST.ClientCursor.Account As A On A.SyncEntityId=CD.EntityId
				Where A.CompanyId=@CompanyId And A.SyncEntityId Is NOT  Null and A.IsAccount=1 And A.SyncEntityDate=@GetDate 
				) As B On B.ContactId=A.ContactId
				Where A.EntityId=B.SyncEntityId

				----===================================Insert into ContactDetails From Account ContactDetails=====================================
			    Insert Into SmartCursorTST.Common.ContactDetails (Id,ContactId,EntityId,EntityType,Designation,Communication,Matters,IsPrimaryContact,IsReminderReceipient,RecOrder,OtherDesignation,IsPinned,CursorShortCode,Status,UserCreated,CreatedDate,Remarks,DocId,DocType,IsCopy)
				Select Distinct NewId() AS Id,CD.ContactId,A.SyncEntityId AS EntityId,'Entity' AS EntityType,CD.Designation,CD.Communication,CD.Matters,
				CD.IsPrimaryContact,CD.IsReminderReceipient,CD.RecOrder,CD.OtherDesignation,CD.IsPinned,'Bean' AS CursorShortCode,
				CD.Status,@UserCreatedOrModified AS UserCreated,@Getdate AS CreatedDate,CD.Remarks,CD.EntityId AS DocId,'Account' AS DocType,CD.IsCopy
				From SmartCursorTST.Common.ContactDetails As CD
				Inner Join SmartCursorTST.ClientCursor.Account As A On A.Id=CD.EntityId
				Inner Join SmartCursorTST.Common.Contact As C On C.Id=CD.ContactId 
				--LEFT Join SmartCursorTST.ClientCursor.Account As A On A.SyncEntityId=CD.EntityId
				Where A.CompanyId=@CompanyId And A.SyncEntityId Is Not Null  and A.IsAccount=1 And A.SyncEntityDate=@GetDate 
				AND CD.ContactId NOT IN (
				Select Distinct CD.ContactId
				From SmartCursorTST.Common.ContactDetails As CD
				--Inner Join SmartCursorTST.ClientCursor.Account As A On A.Id=CD.EntityId
				Inner Join SmartCursorTST.Common.Contact As C On C.Id=CD.ContactId 
				Inner Join SmartCursorTST.ClientCursor.Account As A On A.SyncEntityId=CD.EntityId
				Where A.CompanyId=@CompanyId And A.SyncEntityId Is Not Null and A.IsAccount=1 And A.SyncEntityDate=@GetDate 
				)
				AND CD.EntityId NOT IN (
				Select Distinct CD.EntityId
				From SmartCursorTST.Common.ContactDetails As CD
				--Inner Join SmartCursorTST.ClientCursor.Account As A On A.Id=CD.EntityId
				Inner Join SmartCursorTST.Common.Contact As C On C.Id=CD.ContactId 
				Inner Join SmartCursorTST.ClientCursor.Account As A On A.SyncEntityId=CD.EntityId
				Where A.CompanyId=@CompanyId And A.SyncEntityId Is Not Null and A.IsAccount=1 And A.SyncEntityDate=@GetDate 
				)
			

				--DELETE CD From SmartCursorTST.Common.ContactDetails As CD
				--Inner Join Bean.Entity As A On A.Id=CD.EntityId
				--Inner Join SmartCursorTST.Common.Contact As C On C.Id=CD.ContactId 
				--Where A.CompanyId=@CompanyId And A.SyncAccountId Is Not Null 
				--AND CD.ContactId NOT IN 
				--(Select Distinct B.ContactId
				--From SmartCursorTST.Common.ContactDetails B
				--Inner Join SmartCursorTST.ClientCursor.Account As A On A.Id=B.EntityId
				--Inner Join SmartCursorTST.Common.Contact As C On C.Id=B.ContactId 
				----LEFT Join SmartCursorTST.ClientCursor.Account As A On A.SyncEntityId=CD.EntityId
				--Where A.CompanyId=@CompanyId And A.SyncEntityId Is NOT  Null and A.IsAccount=1 And A.SyncEntityDate=@GetDate
				--)
				--AND A.SyncAccountId  NOT IN 
				--(Select Distinct B.EntityId
				--From SmartCursorTST.Common.ContactDetails B
				--Inner Join SmartCursorTST.ClientCursor.Account As A On A.Id=B.EntityId
				--Inner Join SmartCursorTST.Common.Contact As C On C.Id=B.ContactId 
				----LEFT Join SmartCursorTST.ClientCursor.Account As A On A.SyncEntityId=CD.EntityId
				--Where A.CompanyId=@CompanyId And A.SyncEntityId Is NOT  Null and A.IsAccount=1 And A.SyncEntityDate=@GetDate
				--)

			----===================================Insert into @beanContactDetails From Account ContactDetails Addresses =====================================
				declare @bcContactDetails table(ContactDetailsId uniqueidentifier,Accountid uniqueidentifier,EntityId uniqueidentifier)
			    INSERT INTO @bcContactDetails
				Select Distinct CD.id,a.id,a.SyncEntityId
				From SmartCursorTST.Common.ContactDetails As CD
				--Inner Join SmartCursorTST.ClientCursor.Account As A On A.Id=CD.EntityId
				Inner Join SmartCursorTST.Common.Contact As C On C.Id=CD.ContactId 
				Inner Join SmartCursorTST.ClientCursor.Account As A On A.SyncEntityId=CD.EntityId
				Where A.CompanyId=@CompanyId And A.SyncEntityId Is Not Null and A.IsAccount=1 AND A.SyncEntityDate=@GetDate
				--AND A.NAME IN ('Ms. A+U Publishing Pte. Ltd.1010')
			
			----===================================Insert into Addresses From Account ContactDetails Addresses=====================================
				Insert Into SmartCursorTST.Common.Addresses(Id,AddSectionType,AddType,AddTypeId,AddTypeIdInt,AddressBookId,Status,DocumentId,EntityId,ScreenName,IsCurrentAddress,CompanyId)
				Select Distinct   NEWID() AS Id,Adrs.AddSectionType,'EntityContactDetailId' AS AddType,CC.ContactDetailsId AS AddTypeId,Adrs.AddTypeIdInt,Adrs.AddressBookId,
				Adrs.Status,Adrs.AddTypeId,NULL AS EntityId,'BC' AS ScreenName,Adrs.IsCurrentAddress,@CompanyId AS CompanyId
			    From SmartCursorTST.Common.Addresses As Adrs
				Inner join SmartCursorTST.Common.ContactDetails As A On A.Id=Adrs.AddTypeId 
				INNER join @bcContactDetails CC ON CC.Accountid=A.EntityId
				Where CompanyId=@CompanyId --And A.CreatedDate=@GetDate  
				AND A.EntityId In (Select Id From SmartCursorTST.ClientCursor.Account Where CompanyId=@CompanyId and isaccount=1 And SyncEntityId Is Not Null And SyncEntityDate=@GetDate
				)
				AND CC.ContactDetailsId NOT IN (
	            Select Distinct A.Id  From SmartCursorTST.Common.Addresses As Adrs
				Inner join SmartCursorTST.Common.ContactDetails As A On A.Id=Adrs.AddTypeId 
				Where Adrs.CompanyId=@CompanyId  And A.CreatedDate=@GetDate 
				and A.Id  IS NOT NULL and A.EntityId In (Select Id From SmartCursorTST.Bean.Entity Where CompanyId=@CompanyId And SyncAccountId  Is Not Null  And CreatedDate=@GetDate 
				)
				)
			    AND Adrs.AddressBookId  NOT IN	(
				Select Distinct Adrs.AddressBookId From SmartCursorTST.Common.Addresses As Adrs
				Inner join SmartCursorTST.Common.ContactDetails As A On A.Id=Adrs.AddTypeId 
				Where Adrs.CompanyId=@CompanyId  And A.CreatedDate=@GetDate 
				and Adrs.AddressBookId  IS NOT NULL and A.EntityId In (Select Id From SmartCursorTST.Bean.Entity Where CompanyId=@CompanyId And SyncAccountId  Is Not Null  And CreatedDate=@GetDate 
				)
				)
				AND Adrs.AddSectionType NOT IN (
				Select Distinct Addsectiontype From SmartCursorTST.Common.Addresses As Adrs
				Inner join SmartCursorTST.Common.ContactDetails As A On A.Id=Adrs.AddTypeId 
				Where Adrs.CompanyId=@CompanyId  And A.CreatedDate=@GetDate 
				and Adrs.Addsectiontype  IS NOT NULL and A.EntityId In (Select Id From SmartCursorTST.Bean.Entity Where CompanyId=@CompanyId And SyncAccountId  Is Not Null  And CreatedDate=@GetDate 
				)  
				AND Adrs.AddressBookId  NOT IN	(
				Select Distinct Adrs.AddressBookId From SmartCursorTST.Common.Addresses As Adrs
				Inner join SmartCursorTST.Common.ContactDetails As A On A.Id=Adrs.AddTypeId 
				Where Adrs.CompanyId=@CompanyId  And A.CreatedDate=@GetDate 
				and Adrs.AddressBookId  IS NOT NULL and A.EntityId In (Select Id From SmartCursorTST.Bean.Entity Where CompanyId=@CompanyId And SyncAccountId  Is Not Null  And CreatedDate=@GetDate 
				)
				)
				)

	  End
    SET @Enddate= GETUTCDATE()
    insert into SmartCursorTST.[Import].[TransactionDetails]
    select newid(),@companyId,@TransactionId,'CC',@startdate,@Enddate,'CCSync_Account_To_Client_To_Entity Completed',(select count(*) from MigrationDBPRD.[Import].[CCAccount] where TransactionId= @TransactionId ),( select count(*) from MigrationDBPRD.[Import].[CCFailureAccount] where TransactionId=@TransactionId),
    ( select count(*) from MigrationDBPRD.[Import].[CCSuccessAccount] where TransactionId=@TransactionId),null


  COMMIT TRANSACTION;
END TRY
BEGIN CATCH
	Declare @ErrorMessage Nvarchar(4000)
	ROLLBACK;
	Select @ErrorMessage=error_message();
	  If @ErrorMessage is not null
	  begin 
	  insert into SmartCursorTST.[Import].[TransactionDetails]
	  select newid(),@companyId,@TransactionId,'CC',GETUTCDATE(),GETUTCDATE(),'CCSync_Account_To_Client_To_Entity Error',(select count(*) from MigrationDBPRD.[Import].[CCAccount] where TransactionId= @TransactionId ),(select count(*) from MigrationDBPRD.[Import].[CCAccount] where TransactionId= @TransactionId ),null,@ErrorMessage
	  end 
	Raiserror(@ErrorMessage,16,1);
END CATCH
	END

GO
