USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [Import].[WFSync_Client_To_Account_To_Entity]    Script Date: 16-12-2024 9.20.11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


---2020-09-29 05:13:08.4233333

CREATE Procedure [Import].[WFSync_Client_To_Account_To_Entity] ---EXEC [Import].[WFSync_Client_To_Account_To_Entity] 1077
@CompanyId BigInt,
@TransactionId uniqueidentifier
As
Begin
--declare @CompanyId BigInt=1077	
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
	 set @BaseCurrency = (select Distinct  BaseCurrency from SmartCursorTST.Common.Localization where  CompanyId=@CompanyId)
	 If @BaseCurrency is null Set @BaseCurrency='SGD'
	    Begin Transaction
	    Begin Try
		----=============
		     declare @startdate [datetime2](7)
             declare @Enddate [datetime2](7)
             SET @startdate= GETUTCDATE()
   ---=============================Generate autonumber=================================================
		Set @GeneratedNumber=(Select GeneratedNumber From SmartCursorTST.Common.AutoNumber Where CompanyId=@CompanyId And EntityType='Account' And ModuleMasterId=(Select Id From SmartCursorTST.Common.ModuleMaster Where Name='Client Cursor'))
		Set @SystemRefnum=(Select Top(1) SystemRefNo From SmartCursorTST.ClientCursor.Account Where CompanyId=@CompanyId And SystemRefNo Is not null Order By CreatedDate Desc)
		Set @SystemRefnum=Reverse(SUBSTRING(Reverse(@SystemRefnum),PATINDEX('%[0-9][^0-9]%', Reverse(@SystemRefnum))+1,DATALENGTH(@SystemRefnum)))
		--=========================================Check Client Cursor Active or Inactive=====================================
       	If Exists(Select Id From SmartCursorTST.Common.CompanyModule Where CompanyId=@CompanyId And ModuleId in (Select Id from SmartCursorTST.Common.ModuleMaster Where Name='Client Cursor') And Status=1)
		Begin
			--==================Insert into account table from Client table========================================
			Insert Into SmartCursorTST.ClientCursor.Account (Id,Name,CompanyId,AccountTypeId,AccountIdTypeId,AccountIdNo,TermsOfPaymentId,Industry,Source,SourceId,SourceName,SourceRemarks,IncorporationDate,FinancialYearEnd,CountryOfIncorporation,AccountStatus,PrincipalActivities,UserCreated,CreatedDate,Version,Status,SystemRefNo,SyncClientId,SyncClientRemarks,SyncClientStatus,SyncClientDate,AccountId,IsAccount)
			Select  NEWID(),Name,CompanyId,ClientIdTypeId,IdtypeId,ClientIdNo,TermsOfPaymentId,Industry,Source,SourceId,SourceName,SourceRemarks,IncorporationDate,FinancialYearEnd,CountryOfIncorporation,ClientStatus,PrincipalActivities,@UserCreatedOrModified,@GetDate,Version,Status,CONCAT(@SystemRefnum,Right('0000000000'+Cast((@GeneratedNumber+ROW_NUMBER () Over (Order By Id) ) As varchar),Len(@GeneratedNumber))),Id,Null,@SyncStatusCompleted,@GetDate,CONCAT(@SystemRefnum,Right('0000000000'+Cast((@GeneratedNumber+ROW_NUMBER () Over (Order By Id) ) As varchar),Len(@GeneratedNumber)))
			,1
			From SmartCursorTST.WorkFlow.Client
			Where CompanyId=@CompanyId 
			And Id not in (Select SyncClientId from SmartCursorTST.ClientCursor.Account Where CompanyId=@CompanyId And SyncClientId Is Not Null)
			And isnull(SyncEntityId,'00000000-0000-0000-0000-000000000000')   Not In (Select SyncEntityId From SmartCursorTST.ClientCursor.Account Where CompanyId=@CompanyId And SyncEntityId Is Not null)
			AND NAME='A2 Manufacturing Pte Ltd100'
			order by Name
			
			--==================Insert into AccountStatusChange table from Client table ========================================
			Insert Into SmartCursorTST.ClientCursor.AccountStatusChange (Id,CompanyId,AccountId,State,ModifiedBy,ModifiedDate,IsAccount)
			Select Newid(),@CompanyId,Id,'Active',@UserCreatedOrModified,@GetDate,1 From SmartCursorTST.ClientCursor.Account Where CompanyId=@CompanyId AND IsAccount=1 And CreatedDate=@GetDate
			and id not in (select distinct AccountId from  SmartCursorTST.ClientCursor.AccountStatusChange where AccountId is not null and CompanyId=@companyid)
			
			--======================= UPDATE SyncAccountId FROM Client table 
			Update C Set C.SyncAccountId=A.Id,C.SyncAccountStatus=@SyncStatusCompleted,C.SyncAccountDate=@GetDate ,C.SyncAccountRemarks=null From SmartCursorTST.WorkFlow.Client As C
			Inner Join SmartCursorTST.ClientCursor.Account As A On A.SyncClientId=C.Id
			Where C.CompanyId=@CompanyId  AND A.IsAccount=1 And A.CreatedDate=@GetDate

			--==================Insert into Addresses table from Client table ========================================
			Insert Into SmartCursorTST.Common.Addresses(Id,AddSectionType,AddType,AddTypeId,AddTypeIdInt,AddressBookId,Status,DocumentId,EntityId,ScreenName,IsCurrentAddress,CompanyId)
			Select Distinct NEWID() AS Id,Adrs.AddSectionType,'Account' AS AddType,A.SyncAccountId AS AddTypeId,Adrs.AddTypeIdInt,Adrs.AddressBookId,
			Adrs.Status,Adrs.AddTypeId ,NULL AS EntityId,NULL AS ScreenName,Adrs.IsCurrentAddress,@CompanyId AS CompanyId
			From SmartCursorTST.Common.Addresses As Adrs
			Inner join SmartCursorTST.WorkFlow.Client As A On A.Id=Adrs.AddTypeId 
			Where A.CompanyId=@CompanyId And A.SyncAccountId Is Not Null  And A.SyncAccountDate=@GetDate 
			AND A.SyncAccountId NOT IN (
	           Select Distinct AddTypeId  From SmartCursorTST.Common.Addresses As Adrs
			Inner Join SmartCursorTST.ClientCursor.Account As A On A.Id=Adrs.AddTypeId 
			Where A.CompanyId=@CompanyId And A.SyncClientId  Is Not Null AND A.IsAccount=1  And A.CreatedDate=@GetDate 
			)
			 --   AND Adrs.AddressBookId  NOT IN	(
				--Select Distinct Adrs.AddressBookId From SmartCursorTST.Common.Addresses As Adrs
				--Inner Join SmartCursorTST.ClientCursor.Account As A On A.Id=Adrs.AddTypeId 
				--Where A.CompanyId=@CompanyId And A.SyncClientId  Is Not Null AND A.IsAccount=1 -- And A.CreatedDate=@GetDate 
				--and Adrs.AddressBookId  IS NOT NULL
				--)
				--AND Adrs.AddSectionType NOT IN (
				--Select Distinct Addsectiontype From SmartCursorTST.Common.Addresses As Adrs
				--Inner Join SmartCursorTST.ClientCursor.Account As A On A.Id=Adrs.AddTypeId 
				--Where A.CompanyId=@CompanyId And A.SyncClientId Is Not Null  AND A.IsAccount=1--And A.CreatedDate=@GetDate
				--and Addsectiontype IS NOT NULL  
				--AND Adrs.AddressBookId  NOT IN	(
				--Select Distinct Adrs.AddressBookId From SmartCursorTST.Common.Addresses As Adrs
				--Inner Join SmartCursorTST.ClientCursor.Account As A On A.Id=Adrs.AddTypeId 
				--Where A.CompanyId=@CompanyId And A.SyncClientId  Is Not Null AND A.IsAccount=1 -- And A.CreatedDate=@GetDate 
				--and Adrs.AddressBookId  IS NOT NULL
				--) 
				--)


					--============================== UPDATE Account ContactDetails FROM Client ContactDetails=========================
				Update A Set A.Designation=B.Designation,A.Communication=B.Communication,A.IsPrimaryContact=B.IsPrimaryContact,A.Matters=B.Matters,A.RecOrder=B.RecOrder,A.Status=B.Status,A.IsReminderReceipient=B.IsReminderReceipient,A.ModifiedBy=@UserCreatedOrModified,ModifiedDate=@GetDate,A.Remarks=B.Remarks,a.IsCopy=b.IsCopy From SmartCursorTST.Common.ContactDetails As A
				Inner Join 
				(Select A.SyncAccountId,B.ContactId,B.Designation,B.Communication, B.IsPrimaryContact,B.Matters,B.RecOrder,B.IsReminderReceipient,B.Remarks,b.IsCopy,B.Status 
				From SmartCursorTST.Common.ContactDetails B
				Inner Join SmartCursorTST.WorkFlow.Client As A On A.Id=B.EntityId
				Inner Join SmartCursorTST.Common.Contact As C On C.Id=B.ContactId 
				--LEFT Join SmartCursorTST.WorkFlow.Client As A On A.SyncAccountId=CD.EntityId
				Where A.CompanyId=@CompanyId And A.SyncAccountId Is NOT  Null  And A.SyncAccountDate=@GetDate 
				) As B On B.ContactId=A.ContactId
				Where A.EntityId=B.SyncAccountId
				----===================================Insert into ContactDetails From Client ContactDetails=====================================
			    Insert Into SmartCursorTST.Common.ContactDetails (Id,ContactId,EntityId,EntityType,Designation,Communication,Matters,IsPrimaryContact,IsReminderReceipient,RecOrder,OtherDesignation,IsPinned,CursorShortCode,Status,UserCreated,CreatedDate,Remarks,DocId,DocType,IsCopy)
				Select Distinct NewId() AS Id,CD.ContactId,A.SyncAccountId AS EntityId,'Account' AS EntityType,CD.Designation,CD.Communication,CD.Matters,
				CD.IsPrimaryContact,CD.IsReminderReceipient,CD.RecOrder,CD.OtherDesignation,CD.IsPinned,'CC' AS CursorShortCode,
				CD.Status,@UserCreatedOrModified AS UserCreated,@Getdate AS CreatedDate,CD.Remarks,CD.EntityId AS DocId,'Client' AS DocType,CD.IsCopy
				From SmartCursorTST.Common.ContactDetails As CD
				Inner Join SmartCursorTST.WorkFlow.Client As A On A.Id=CD.EntityId
				Inner Join SmartCursorTST.Common.Contact As C On C.Id=CD.ContactId 
				--LEFT Join SmartCursorTST.WorkFlow.Client As A On A.SyncAccountId=CD.EntityId
				Where A.CompanyId=@CompanyId And A.SyncAccountId Is Not Null  And A.SyncAccountDate=@GetDate 
				AND CD.ContactId NOT IN (
				Select Distinct CD.ContactId
				From SmartCursorTST.Common.ContactDetails As CD
				--Inner Join SmartCursorTST.WorkFlow.Client As A On A.Id=CD.EntityId
				Inner Join SmartCursorTST.Common.Contact As C On C.Id=CD.ContactId 
				Inner Join SmartCursorTST.WorkFlow.Client As A On A.SyncAccountId=CD.EntityId
				Where A.CompanyId=@CompanyId And A.SyncAccountId Is Not Null And A.SyncAccountDate=@GetDate 
				)
				AND CD.EntityId NOT IN (
				Select Distinct CD.EntityId
				From SmartCursorTST.Common.ContactDetails As CD
				--Inner Join SmartCursorTST.ClientCursor.Account As A On A.Id=CD.EntityId
				Inner Join SmartCursorTST.Common.Contact As C On C.Id=CD.ContactId 
				Inner Join SmartCursorTST.WorkFlow.Client As A On A.SyncAccountId=CD.EntityId
				Where A.CompanyId=@CompanyId And A.SyncAccountId Is Not Null  And A.SyncAccountDate=@GetDate 
				)
			

				--DELETE CD From SmartCursorTST.Common.ContactDetails As CD
				--Inner Join SmartCursorTST.ClientCursor.Account As A On A.Id=CD.EntityId
				--Inner Join SmartCursorTST.Common.Contact As C On C.Id=CD.ContactId 
				--Where A.CompanyId=@CompanyId And A.SyncClientId Is Not Null AND A.IsAccount=1
				--AND CD.ContactId NOT IN 
				--(Select Distinct B.ContactId
				--From SmartCursorTST.Common.ContactDetails B
				--Inner Join SmartCursorTST.WorkFlow.Client As A On A.Id=B.EntityId
				--Inner Join SmartCursorTST.Common.Contact As C On C.Id=B.ContactId 
				----LEFT Join SmartCursorTST.WorkFlow.Client As A On A.SyncAccountId=CD.EntityId
				--Where A.CompanyId=@CompanyId And A.SyncAccountId Is NOT  Null  And A.SyncAccountDate=@GetDate
				--)
				--AND A.SyncAccountId  NOT IN 
				--(Select Distinct B.EntityId
				--From SmartCursorTST.Common.ContactDetails B
				--Inner Join SmartCursorTST.WorkFlow.Client As A On A.Id=B.EntityId
				--Inner Join SmartCursorTST.Common.Contact As C On C.Id=B.ContactId 
				----LEFT Join SmartCursorTST.WorkFlow.Client As A On A.SyncAccountId=CD.EntityId
				--Where A.CompanyId=@CompanyId And A.SyncAccountId Is NOT  Null  And A.SyncAccountDate=@GetDate
				--)

			----===================================Insert into @wfContactDetails From Client ContactDetails Addresses =====================================
				declare @wfContactDetails table(ContactDetailsId uniqueidentifier,ClientId uniqueidentifier,Accountid uniqueidentifier)
			    INSERT INTO @wfContactDetails
				Select Distinct CD.id,a.id,a.SyncAccountId
				From SmartCursorTST.Common.ContactDetails As CD
				--Inner Join SmartCursorTST.ClientCursor.Account As A On A.Id=CD.EntityId
				Inner Join SmartCursorTST.Common.Contact As C On C.Id=CD.ContactId 
				Inner Join SmartCursorTST.WorkFlow.Client As A On A.SyncAccountId=CD.EntityId
				Where A.CompanyId=@CompanyId And A.SyncAccountId Is Not Null  AND A.SyncAccountDate=@GetDate
				--AND A.NAME IN ('Ms. A+U Publishing Pte. Ltd.1010')
				
			----===================================Insert into Addresses From Client ContactDetails Addresses=====================================
				Insert Into SmartCursorTST.Common.Addresses(Id,AddSectionType,AddType,AddTypeId,AddTypeIdInt,AddressBookId,Status,DocumentId,EntityId,ScreenName,IsCurrentAddress,CompanyId)
				Select Distinct   NEWID() AS Id,Adrs.AddSectionType,'AccountContactDetailId' AS AddType,CC.ContactDetailsId AS AddTypeId,Adrs.AddTypeIdInt,Adrs.AddressBookId,
				Adrs.Status,Adrs.AddTypeId,NULL AS EntityId,'CC' AS ScreenName,Adrs.IsCurrentAddress,@CompanyId AS CompanyId
			    From SmartCursorTST.Common.Addresses As Adrs
				Inner join SmartCursorTST.Common.ContactDetails As A On A.Id=Adrs.AddTypeId 
				INNER join @wfContactDetails CC ON CC.ClientId=A.EntityId
				Where CompanyId=@CompanyId --And A.CreatedDate=@GetDate  
				AND A.EntityId In (Select Id From SmartCursorTST.WorkFlow.Client Where CompanyId=@CompanyId And SyncAccountId  Is Not Null  And SyncAccountDate=@GetDate 
				)
				AND CC.ContactDetailsId NOT IN (
	            Select Distinct A.Id  From SmartCursorTST.Common.Addresses As Adrs
				Inner join SmartCursorTST.Common.ContactDetails As A On A.Id=Adrs.AddTypeId 
				Where Adrs.CompanyId=@CompanyId  And A.CreatedDate=@GetDate 
				and A.Id  IS NOT NULL and A.EntityId In (Select Id From SmartCursorTST.ClientCursor.Account Where CompanyId=@CompanyId and isaccount=1 And SyncClientId Is Not Null And CreatedDate=@GetDate 
				)
				)
			    AND Adrs.AddressBookId  NOT IN	(
				Select Distinct Adrs.AddressBookId From SmartCursorTST.Common.Addresses As Adrs
				Inner join SmartCursorTST.Common.ContactDetails As A On A.Id=Adrs.AddTypeId 
				Where Adrs.CompanyId=@CompanyId  And A.CreatedDate=@GetDate 
				and Adrs.AddressBookId  IS NOT NULL and A.EntityId In (Select Id From SmartCursorTST.ClientCursor.Account Where CompanyId=@CompanyId and isaccount=1 And SyncClientId Is Not Null And CreatedDate=@GetDate 
				)
				)
				AND Adrs.AddSectionType NOT IN (
				Select Distinct Addsectiontype From SmartCursorTST.Common.Addresses As Adrs
				Inner join SmartCursorTST.Common.ContactDetails As A On A.Id=Adrs.AddTypeId 
				Where Adrs.CompanyId=@CompanyId  And A.CreatedDate=@GetDate 
				and Adrs.Addsectiontype  IS NOT NULL and A.EntityId In (Select Id From SmartCursorTST.ClientCursor.Account Where CompanyId=@CompanyId and isaccount=1 And SyncClientId Is Not Null And CreatedDate=@GetDate 
				)  
				AND Adrs.AddressBookId  NOT IN	(
				Select Distinct Adrs.AddressBookId From SmartCursorTST.Common.Addresses As Adrs
				Inner join SmartCursorTST.Common.ContactDetails As A On A.Id=Adrs.AddTypeId 
				Where Adrs.CompanyId=@CompanyId  And A.CreatedDate=@GetDate 
				and Adrs.AddressBookId  IS NOT NULL and A.EntityId In (Select Id From SmartCursorTST.ClientCursor.Account Where CompanyId=@CompanyId and isaccount=1 And SyncClientId Is Not Null And CreatedDate=@GetDate 
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
			--========================= Insert Into Bean.Entity Table From Client===========================================
			Insert Into SmartCursorTST.Bean.Entity (Id,CompanyId,Name,TypeId,IdTypeId,IdNo,IsCustomer,CustTOPId,CustCurrency,CustNature,RecOrder,Remarks,UserCreated,CreatedDate,Status,IsExternalData,IsShowPayroll,Communication,ExternalEntityType,SyncClientId,SyncClientDate,SyncClientStatus,SyncClientRemarks)
			Select  NEWID(),@CompanyId,Name,ClientTypeId,IdtypeId,ClientIdNo,1,Case when TermsOfPaymentId is not null then TermsOfPaymentId else (select id from SmartCursorTST.common.termsofpayment where companyid=@companyId and name='Credit - 0') end,
					@BaseCurrency,@CustNature,RecOrder,Remarks,@UserCreatedOrModified,@GetDate,Case When ClientStatus='Active' Then 1 When ClientStatus='Inactive' then 2 End,1,1 ,Communication,'Client',Id,@GetDate,@SyncStatusCompleted,Null
			From SmartCursorTST.WorkFlow.Client 
			Where CompanyId=@CompanyId 
			And Id Not In (Select SyncClientId From SmartCursorTST.Bean.Entity Where CompanyId=@CompanyId And SyncClientId Is not null)
			And isnull(SyncAccountId,'00000000-0000-0000-0000-000000000000')  Not In (Select SyncAccountId From SmartCursorTST.Bean.Entity Where CompanyId=@CompanyId And SyncAccountId Is not null)
			--AND NAME='A2 Manufacturing Pte Ltd100'
			order by Name
			-- =================================================Update syncEntity details in Client===========================
			Update C Set C.SyncEntityId=E.Id,C.SyncEntitydate=@GetDate,C.SyncEntityStatus=@SyncStatusCompleted,C.SyncEntityRemarks=Null 
			From SmartCursorTST.WorkFlow.Client As C
			Inner Join SmartCursorTST.Bean.Entity As E On E.SyncClientId=C.Id
			Where C.CompanyId=@CompanyId And E.CreatedDate=@GetDate

			--==================Insert into Addresses table from Client table ========================================
			Insert Into SmartCursorTST.Common.Addresses(Id,AddSectionType,AddType,AddTypeId,AddTypeIdInt,AddressBookId,Status,DocumentId,EntityId,ScreenName,IsCurrentAddress,CompanyId)
			Select Distinct NEWID() AS Id,Adrs.AddSectionType,'Entity' AS AddType,A.SyncEntityId AS AddTypeId,Adrs.AddTypeIdInt,Adrs.AddressBookId,
			Adrs.Status,Adrs.AddTypeId ,NULL AS EntityId,NULL AS ScreenName,Adrs.IsCurrentAddress,@CompanyId AS CompanyId
			From SmartCursorTST.Common.Addresses As Adrs
			Inner join SmartCursorTST.WorkFlow.Client As A On A.Id=Adrs.AddTypeId 
			Where A.CompanyId=@CompanyId And A.SyncEntityId Is Not Null  And A.SyncEntityDate=@GetDate 
			AND A.SyncEntityId NOT IN (
	           Select Distinct AddTypeId  From SmartCursorTST.Common.Addresses As Adrs
			Inner join SmartCursorTST.Bean.Entity As A On A.Id=Adrs.AddTypeId 
			Where A.CompanyId=@CompanyId And A.SyncClientId  Is Not Null  And A.CreatedDate=@GetDate 
			)

						--============================== UPDATE Entity ContactDetails FROM Account ContactDetails=========================
				Update A Set A.Designation=B.Designation,A.Communication=B.Communication,A.IsPrimaryContact=B.IsPrimaryContact,A.Matters=B.Matters,A.RecOrder=B.RecOrder,A.Status=B.Status,A.IsReminderReceipient=B.IsReminderReceipient,A.ModifiedBy=@UserCreatedOrModified,ModifiedDate=@GetDate,A.Remarks=B.Remarks,a.IsCopy=b.IsCopy From SmartCursorTST.Common.ContactDetails As A
				Inner Join 
				(Select A.SyncEntityId,B.ContactId,B.Designation,B.Communication, B.IsPrimaryContact,B.Matters,B.RecOrder,B.IsReminderReceipient,B.Remarks,b.IsCopy,B.Status 
				From SmartCursorTST.Common.ContactDetails B
				Inner Join SmartCursorTST.WorkFlow.Client As A On A.Id=B.EntityId
				Inner Join SmartCursorTST.Common.Contact As C On C.Id=B.ContactId 
				--LEFT Join SmartCursorTST.ClientCursor.Account As A On A.SyncEntityId=CD.EntityId
				Where A.CompanyId=@CompanyId And A.SyncEntityId Is NOT  Null  And A.SyncEntityDate=@GetDate 
				) As B On B.ContactId=A.ContactId
				Where A.EntityId=B.SyncEntityId

				----===================================Insert into ContactDetails From Account ContactDetails=====================================
			    Insert Into SmartCursorTST.Common.ContactDetails (Id,ContactId,EntityId,EntityType,Designation,Communication,Matters,IsPrimaryContact,IsReminderReceipient,RecOrder,OtherDesignation,IsPinned,CursorShortCode,Status,UserCreated,CreatedDate,Remarks,DocId,DocType,IsCopy)
				Select Distinct NewId() AS Id,CD.ContactId,A.SyncEntityId AS EntityId,'Entity' AS EntityType,CD.Designation,CD.Communication,CD.Matters,
				CD.IsPrimaryContact,CD.IsReminderReceipient,CD.RecOrder,CD.OtherDesignation,CD.IsPinned,'Bean' AS CursorShortCode,
				CD.Status,@UserCreatedOrModified AS UserCreated,@Getdate AS CreatedDate,CD.Remarks,CD.EntityId AS DocId,'Clien' AS DocType,CD.IsCopy
				From SmartCursorTST.Common.ContactDetails As CD
				Inner Join SmartCursorTST.WorkFlow.Client As A On A.Id=CD.EntityId
				Inner Join SmartCursorTST.Common.Contact As C On C.Id=CD.ContactId 
				--LEFT Join SmartCursorTST.ClientCursor.Account As A On A.SyncEntityId=CD.EntityId
				Where A.CompanyId=@CompanyId And A.SyncEntityId Is Not Null   And A.SyncEntityDate=@GetDate 
				AND CD.ContactId NOT IN (
				Select Distinct CD.ContactId
				From SmartCursorTST.Common.ContactDetails As CD
				--Inner Join SmartCursorTST.ClientCursor.Account As A On A.Id=CD.EntityId
				Inner Join SmartCursorTST.Common.Contact As C On C.Id=CD.ContactId 
				Inner Join SmartCursorTST.WorkFlow.Client As A On A.SyncEntityId=CD.EntityId
				Where A.CompanyId=@CompanyId And A.SyncEntityId Is Not Null  And A.SyncEntityDate=@GetDate 
				)
				AND CD.EntityId NOT IN (
				Select Distinct CD.EntityId
				From SmartCursorTST.Common.ContactDetails As CD
				--Inner Join SmartCursorTST.ClientCursor.Account As A On A.Id=CD.EntityId
				Inner Join SmartCursorTST.Common.Contact As C On C.Id=CD.ContactId 
				Inner Join SmartCursorTST.WorkFlow.Client As A On A.SyncEntityId=CD.EntityId
				Where A.CompanyId=@CompanyId And A.SyncEntityId Is Not Null  And A.SyncEntityDate=@GetDate 
				)
			

				--DELETE CD From SmartCursorTST.Common.ContactDetails As CD
				--Inner Join Bean.Entity As A On A.Id=CD.EntityId
				--Inner Join SmartCursorTST.Common.Contact As C On C.Id=CD.ContactId 
				--Where A.CompanyId=@CompanyId And A.SyncClientId Is Not Null 
				--AND CD.ContactId NOT IN 
				--(Select Distinct B.ContactId
				--From SmartCursorTST.Common.ContactDetails B
				--Inner Join SmartCursorTST.WorkFlow.Client As A On A.Id=B.EntityId
				--Inner Join SmartCursorTST.Common.Contact As C On C.Id=B.ContactId 
				----LEFT Join SmartCursorTST.WorkFlow.Client As A On A.SyncEntityId=CD.EntityId
				--Where A.CompanyId=@CompanyId And A.SyncEntityId Is NOT  Null  And A.SyncEntityDate=@GetDate
				--)
				--AND A.SyncAccountId  NOT IN 
				--(Select Distinct B.EntityId
				--From SmartCursorTST.Common.ContactDetails B
				--Inner Join SmartCursorTST.WorkFlow.Client As A On A.Id=B.EntityId
				--Inner Join SmartCursorTST.Common.Contact As C On C.Id=B.ContactId 
				----LEFT Join SmartCursorTST.WorkFlow.Client As A On A.SyncEntityId=CD.EntityId
				--Where A.CompanyId=@CompanyId And A.SyncEntityId Is NOT  Null  And A.SyncEntityDate=@GetDate
				--)

			----===================================Insert into @beanContactDetails From Account ContactDetails Addresses =====================================
				declare @bcContactDetails table(ContactDetailsId uniqueidentifier,Clientid uniqueidentifier,EntityId uniqueidentifier)
			    INSERT INTO @bcContactDetails
				Select Distinct CD.id,a.id,a.SyncEntityId
				From SmartCursorTST.Common.ContactDetails As CD
				--Inner Join SmartCursorTST.ClientCursor.Account As A On A.Id=CD.EntityId
				Inner Join SmartCursorTST.Common.Contact As C On C.Id=CD.ContactId 
				Inner Join SmartCursorTST.WorkFlow.Client As A On A.SyncEntityId=CD.EntityId
				Where A.CompanyId=@CompanyId And A.SyncEntityId Is Not Null  AND A.SyncEntityDate=@GetDate
				--AND A.NAME IN ('Ms. A+U Publishing Pte. Ltd.1010')
				
			----===================================Insert into Addresses From Account ContactDetails Addresses=====================================
				Insert Into SmartCursorTST.Common.Addresses(Id,AddSectionType,AddType,AddTypeId,AddTypeIdInt,AddressBookId,Status,DocumentId,EntityId,ScreenName,IsCurrentAddress,CompanyId)
				Select Distinct   NEWID() AS Id,Adrs.AddSectionType,'EntityContactDetailId' AS AddType,CC.ContactDetailsId AS AddTypeId,Adrs.AddTypeIdInt,Adrs.AddressBookId,
				Adrs.Status,Adrs.AddTypeId,NULL AS EntityId,'BC' AS ScreenName,Adrs.IsCurrentAddress,@CompanyId AS CompanyId
			    From SmartCursorTST.Common.Addresses As Adrs
				Inner join SmartCursorTST.Common.ContactDetails As A On A.Id=Adrs.AddTypeId 
				INNER join @bcContactDetails CC ON CC.Clientid=A.EntityId
				Where CompanyId=@CompanyId --And A.CreatedDate=@GetDate  
				AND A.EntityId In (Select Id From SmartCursorTST.WorkFlow.Client Where CompanyId=@CompanyId  And SyncEntityId Is Not Null And SyncEntityDate=@GetDate
				)
				AND CC.ContactDetailsId NOT IN (
	            Select Distinct A.Id  From SmartCursorTST.Common.Addresses As Adrs
				Inner join SmartCursorTST.Common.ContactDetails As A On A.Id=Adrs.AddTypeId 
				Where Adrs.CompanyId=@CompanyId  And A.CreatedDate=@GetDate 
				and A.Id  IS NOT NULL and A.EntityId In (Select Id From SmartCursorTST.Bean.Entity Where CompanyId=@CompanyId And SyncClientId  Is Not Null  And CreatedDate=@GetDate 
				)
				)
			    AND Adrs.AddressBookId  NOT IN	(
				Select Distinct Adrs.AddressBookId From SmartCursorTST.Common.Addresses As Adrs
				Inner join SmartCursorTST.Common.ContactDetails As A On A.Id=Adrs.AddTypeId 
				Where Adrs.CompanyId=@CompanyId  And A.CreatedDate=@GetDate 
				and Adrs.AddressBookId  IS NOT NULL and A.EntityId In (Select Id From SmartCursorTST.Bean.Entity Where CompanyId=@CompanyId And SyncClientId  Is Not Null  And CreatedDate=@GetDate 
				)
				)
				AND Adrs.AddSectionType NOT IN (
				Select Distinct Addsectiontype From SmartCursorTST.Common.Addresses As Adrs
				Inner join SmartCursorTST.Common.ContactDetails As A On A.Id=Adrs.AddTypeId 
				Where Adrs.CompanyId=@CompanyId  And A.CreatedDate=@GetDate 
				and Adrs.Addsectiontype  IS NOT NULL and A.EntityId In (Select Id From SmartCursorTST.Bean.Entity Where CompanyId=@CompanyId And SyncClientId  Is Not Null  And CreatedDate=@GetDate 
				)  
				AND Adrs.AddressBookId  NOT IN	(
				Select Distinct Adrs.AddressBookId From SmartCursorTST.Common.Addresses As Adrs
				Inner join SmartCursorTST.Common.ContactDetails As A On A.Id=Adrs.AddTypeId 
				Where Adrs.CompanyId=@CompanyId  And A.CreatedDate=@GetDate 
				and Adrs.AddressBookId  IS NOT NULL and A.EntityId In (Select Id From SmartCursorTST.Bean.Entity Where CompanyId=@CompanyId And SyncClientId  Is Not Null  And CreatedDate=@GetDate 
				)
				)
				)

	  End
       
	   SET @Enddate= GETUTCDATE()
    insert into SmartCursorTST.[Import].[TransactionDetails]
    select newid(),@companyId,@TransactionId,'WF',@startdate,@Enddate,'WFSync_Client_To_Account_To_Entity Completed',(select count(*) from [Import].[WFClient] where TransactionId= @TransactionId ),( select count(*) from [Import].[WFFailureClient] where TransactionId=@TransactionId),
    ( select count(*) from [Import].[WFSuccessClient] where TransactionId=@TransactionId),null

  COMMIT TRANSACTION;
END TRY
BEGIN CATCH
	Declare @ErrorMessage Nvarchar(4000)
	ROLLBACK;
	Select @ErrorMessage=error_message();
	  If @ErrorMessage is not null
	  begin 
	  insert into SmartCursorTST.[Import].[TransactionDetails]
	  select newid(),@companyId,@TransactionId,'WF',GETUTCDATE(),GETUTCDATE(),'WFSync_Client_To_Account_To_Entity Error',(select count(*) from [Import].[WFClient] where TransactionId= @TransactionId ),(select count(*) from [Import].[WFClient] where TransactionId= @TransactionId ),null,@ErrorMessage
	  end 
	Raiserror(@ErrorMessage,16,1);
END CATCH
	END

GO
