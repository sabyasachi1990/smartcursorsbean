USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[Import_ContactsDetail_Validation]    Script Date: 16-12-2024 9.20.10 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO










CREATE Procedure  [dbo].[Import_ContactsDetail_Validation] 
  --- exec [dbo].[Import_ContactsDetail_Validation]  1558,'6B4E5F46-D4AB-45B6-8573-09D4DB2FF550'
@companyId int,
@TransactionId uniqueidentifier
AS
BEGIN 
 Declare --@companyId int=809,            
 @AccountId Uniqueidentifier,
 @ContactId Uniqueidentifier,
 @ContactIdDeatialId Uniqueidentifier,
 @MasterId NVARCHAR(MAX),
 @COMMN Nvarchar(max),
 @COMMNDeatil Nvarchar(max),
 @LocalAddress Nvarchar(Max),
 @PerLocalAddress Nvarchar(Max),
 @EntyLocalAddress Nvarchar(Max),
 @LclAdrs_Vrbl Nvarchar(Max),
 @New_Loc_AddressBookId Uniqueidentifier,
 @New_Frn_AddressBookId Uniqueidentifier,
 @ForigenAddress Nvarchar(Max),
 @PerForigenAddress Nvarchar(Max),
 @EntyForigenAddress Nvarchar(Max),
 @BlockHouseNo Nvarchar(512),
 @Street Nvarchar(2000),
 @UnitNo Nvarchar(512),
 @BuildingEstate Nvarchar(512),
 @PostalCode Nvarchar(20),
 @Country Nvarchar(512),
 @PerEmailJson  Nvarchar(max),
 @PerMobileJson  Nvarchar(max),
 @EntEmailJson  Nvarchar(max),
 @EntMobileJson  Nvarchar(max),
 @PerJsondata  Nvarchar(max),
 @EntJsondata Nvarchar(max),
 @ContactName Nvarchar(max),
 @IdType Nvarchar(max),
 @IdNumber Nvarchar(max),
 @id Uniqueidentifier,
 @IdTypeID  Nvarchar(max),
 @AccountNewId Uniqueidentifier,
 @ContactNewId Uniqueidentifier,
 @ContactIdDeatialNewId Uniqueidentifier,
 @AccountName Nvarchar(max),
 @AccountNewName Nvarchar(max),
 @AccountIduni Uniqueidentifier
 ---========= =========================================Creating Local temporary Tables  for addresss =========================================
 Create Table #Strng_Splt (Id Int Identity(1,1),AddrName Nvarchar(Max))
 --------========================================= ContactId_Get Cursor --===============================================================
 Declare ContactId_Get Cursor For
 select  Id,Name as ContactName,   IdentificationType , IdentificationNumber,MasterId from ImportContacts where TransactionId=@TransactionId 
 AND ( ImportStatus<>0 oR  ImportStatus IS NULL)  ---and  id not in (select DISTINCT   Id from Common.Contact where CompanyId=@companyId)
 Open ContactId_Get
 fetch next from ContactId_Get Into @id,@ContactName,@IdType,@IdNumber,@MasterId
 While @@FETCH_STATUS=0
 Begin
	--===================== 03.12.2019 
    Begin Transaction  
    Begin Try  
	--==================== 03.12.2019
    If Exists ( select  Id from ImportContacts where TransactionId=@TransactionId AND ( ImportStatus<>0 oR  ImportStatus IS NULL) and MasterId=@MasterId  and id=@Id and name=@ContactName)
    Begin
      set @IdTypeID=(select    id  from Common.IdType where  Name=@IdType and CompanyId=@companyId)
      If Exists (Select   Id from  ClientCursor.Account Where AccountId=@MasterId and  CompanyId=@companyId) ---===Check AccountId  in ClientCursor.Account table
	  Begin
		 If Not Exists (Select   Id from  Common.Contact Where  FirstName=@ContactName and  case when  IdType is null  then 'xxx' else IdType end   =  case when  @IdTypeID is null  then 'xxx' else @IdTypeID end  and  case when  IdNo is null  then 'xxx' else IdNo end = case when  @IdNumber is null  then 'xxx' else @IdNumber end  and  CompanyId=@companyId ) ---===Check ContactName  in Common.Contact table
		 Begin
		 --If Not Exists (Select Id from  Common.Contact Where  IdType=@IdType and  CompanyId=@companyId ) ---===Check IdType  in Common.Contact table
		 -- Begin
		 -- If Not Exists (Select Id from  Common.Contact Where  IdNo=@IdNumber and  CompanyId=@companyId ) ---===Check IdNumber  in Common.Contact table
		 --Begin	
         --========================== set AccountId,PerEmailJson,PerMobileJson,EntEmailJson,EntMobileJson For Json Auto=====================================================
             SET @ContactIdDeatialId=NewId()
			 set @ContactId=NewId()
			 Set @AccountIduni =(Select top 1 Id from  ImportLeads Where AccountId=@MasterId and  TransactionId=@TransactionId)
			 Set @AccountId =(Select top 1 Id from  ClientCursor.Account Where AccountId=@MasterId and  CompanyId=@companyId)
			 Set @AccountName =(Select Name from  ClientCursor.Account Where AccountId=@MasterId and  CompanyId=@companyId)
	         Set @PerEmailJson =(Select 'Email' As 'key',PersonalEmail As 'value' From ImportContacts Where Name=@ContactName and PersonalEmail is not null  and id=@id and MasterId=@MasterId and TransactionId=@TransactionId For Json Auto)
			 Set @PerMobileJson =(Select 'Mobile' As 'key',PersonalPhone As 'value' From ImportContacts Where Name=@ContactName and PersonalPhone is not null  and id=@id and MasterId=@MasterId and TransactionId=@TransactionId For Json Auto)
			 Set @EntEmailJson =(Select 'Email' As 'key',EntityEmail As 'value' From ImportContacts Where Name=@ContactName and EntityEmail is not null and id=@id and MasterId=@MasterId and TransactionId=@TransactionId For Json Auto)
			 Set @EntMobileJson =(Select 'Mobile' As 'key',EntityPhone As 'value' From ImportContacts Where Name=@ContactName and EntityPhone is not null and id=@id and MasterId=@MasterId and TransactionId=@TransactionId For Json Auto)
			 If @PerEmailJson Is Not Null
			 Begin
				If @PerMobileJson Is Not Null
				Begin
				 Set @PerJsondata =Concat(Substring(@PerEmailJson,1,len(@PerEmailJson)-1),',',Substring(@PerMobileJson,2,len(@PerMobileJson)))
				End	
				Else
				Begin
				 Set @PerJsondata=@PerEmailJson
				End
			 End
			 If @PerEmailJson Is Null
			 Begin
			  If @PerMobileJson Is Not Null
			  Begin
			   Set @PerJsondata=@PerMobileJson
			  End
			  Else
			  Begin
			   Set @PerJsondata=null
			  End
			 END
		     If @EntEmailJson Is Not Null
			 Begin
			  If @EntMobileJson Is Not Null
			  Begin
			   Set @EntJsondata =Concat(Substring(@EntEmailJson,1,len(@EntEmailJson)-1),',',Substring(@EntMobileJson,2,len(@EntMobileJson)))
			  End	
			  Else
			  Begin
			   Set @EntJsondata=@EntEmailJson
			  End
			 End
			 If @EntEmailJson Is Null
			 Begin
			  If @EntMobileJson Is Not Null
			  Begin
			   Set @EntJsondata=@EntMobileJson
			  End
			  Else
			  Begin
			   Set @EntJsondata=null
			  End
			 END
              ------==================================  Insert into contact table =====================================================	  
		     INSERT INTO Common.Contact
			 (
			 id,Salutation,	FirstName,DOB,	IdType,	IdNo,	CountryOfResidence,	
			 RecOrder,Remarks,UserCreated,CreatedDate,Communication,CompanyId,Status
			 )
             Select @ContactId as Id,Salutation,C.Name as 'FirstName',CONVERT(datetime, DateofBirth, 103) as DOB,@IdTypeID as IdType,
			 C.IdentificationNumber as IdNo,CountryOfResidence, 1 as RecOrder,Remarks,'System' as UserCreated,GETUTCDATE() as CreatedDate,
			 @PerJsondata as 'Communication',@companyid,1 as Status
			 from ImportContacts C
			 Where Name=@ContactName  and id=@id and MasterId=@MasterId and TransactionId=@TransactionId AND (ImportStatus<>0 or ImportStatus is null)
			 ----========================================  insert into Contact Deatils table  =====================================================
			 INSERT INTO Common.ContactDetails 
			 (
			 Id,	ContactId,	EntityId,	EntityType,	Designation,	
			 Communication,		IsPrimaryContact,	IsReminderReceipient,
			 RecOrder,CursorShortCode,IsCopy,UserCreated,CreatedDate,Remarks,Status
			 )
             Select  @ContactIdDeatialId,@ContactId as ContactId,@AccountId AS EntityId,'Account' as 'EntityType',
			 EntityDesignation as Designation,@EntJsondata as 'Communication',
					--    Case when  Fee=0 and Quotation=0 and Admin=0
					--   and AssignmentBilling=0  and Others=0 then NULL
					--   when  Fee is null and Quotation is null and Admin is null
					--   and AssignmentBilling is null and Others is null  then NULL
					--ELSE substring(case when Fee=1 then 'Fee;' else '' end + 
					--  case when Quotation=1 then 'Quotations;' else '' end+ 
					--  case when Admin=1 then 'Admin;' else '' end+
					--  case when AssignmentBilling=1 THEN 'Assignment Billing;' ELSE '' end +
					--  CASE WHEN Others=1 THEN 'Others;' else '' end ,1,
					--  (LEN(case when Fee=1 then 'Fee;' else '' end + 
					--  case when Quotation=1 then 'Quotations;' else '' end+ 
					--  case when Admin=1 then 'Admin;' else '' end+
					--  case when AssignmentBilling=1 THEN 'Assignment Billing;' ELSE '' end +
					--  CASE WHEN Others=1 THEN 'Others;' else '' end)-1)) END as 'Matters',
			 PrimaryContacts as IsPrimaryContact,
			 ReminderRecipient as 'IsReminderReceipient', 1 RecOredr,   'CC' as 'CursorShortCode', 
			 copycommunicationandAddress as IsCopy,'System' as UserCreated,GETUTCDATE() as CreatedDate,Remarks,1 as Status
			 from ImportContacts C
			 Where Name=@ContactName  and id=@id and MasterId=@MasterId and TransactionId=@TransactionId AND (ImportStatus<>0 or ImportStatus is null)
             -- Update Common.ContactDetails set IsPrimaryContact=0 where EntityId=@AccountId and ContactId<>@ContactId and id<>@ContactIdDeatialId --this is primarycontact 1 condition
             UPDATE  ImportContacts set ErrorRemarks=null  where Name=@ContactName  and id=@id and MasterId=@MasterId and TransactionId=@TransactionId
			 UPDATE  ImportContacts set ImportStatus=1  where Name=@ContactName  and id=@id and MasterId=@MasterId and TransactionId=@TransactionId
             --============================ addressbook and address  in ClientCursor.Account table ================================================      
			 Select @LocalAddress=LocalAddress,@ForigenAddress=Foreignaddress
	         From ImportLeads
	         Where   AccountId=@MasterId and Name=@AccountName and TransactionId=@TransactionId and Id=@AccountIduni						
             ---------------================PerLocalAddress and EntyLocalAddress in  ClientCursor.Account table=======================================
			 If Not Exists (Select  Id from Common.Addresses Where AddTypeId=@AccountId and  CompanyId=@companyId ) --== check AccountId in  Common.Addresses table
		     Begin
               If @LocalAddress Is Not Null  ---------- LocalAddress in  ClientCursor.Account table
			   Begin
	             Set @New_Loc_AddressBookId =NewId()
				 Insert Into #Strng_Splt(AddrName)
				 Select Value From string_split(@LocalAddress,',')
                 Insert Into Common.AddressBook 
				 (
				 Id,IsLocal,BlockHouseNo,Street,UnitNo,BuildingEstate,City,PostalCode,State,Country,Phone,Email,UserCreated,CreatedDate,DocumentId,RecOrder
				 )
				 Values(@New_Loc_AddressBookId,1,(Select AddrName From #Strng_Splt Where Id=1),(Select AddrName From #Strng_Splt Where Id=2),(Select AddrName From #Strng_Splt Where Id=3),(Select AddrName From #Strng_Splt Where Id=4),(Select AddrName From #Strng_Splt Where Id=5),(Select AddrName From #Strng_Splt Where Id=6),(Select AddrName From #Strng_Splt Where Id=5),(Select AddrName From #Strng_Splt Where Id=5),
				 (SELECT Phone   FROM ImportLeads WHERE  AccountId=@MasterId and Name=@AccountName and TransactionId=@TransactionId  and Id=@AccountIduni),
				 (SELECT Email   FROM ImportLeads WHERE   AccountId=@MasterId and Name=@AccountName and TransactionId=@TransactionId and Id=@AccountIduni),'System',GETUTCDATE(),@AccountId,1  )
				 Truncate Table #Strng_Splt
                 Insert Into Common.Addresses (Id,AddSectionType,AddType,AddTypeId,AddTypeIdInt,AddressBookId,CompanyId,DocumentId,EntityId,CopyId)
				 Values(NEWID(),'Registered Address','Account',@AccountId,null,@New_Loc_AddressBookId,@CompanyId,@AccountId,Null,Null)
			   End
			   If @ForigenAddress Is Not Null ---------- ForigenAddress in  ClientCursor.Account table
			   Begin
			    Set @New_Frn_AddressBookId=NewId()
			    Insert Into #Strng_Splt(AddrName)
			    Select Value From string_split(@ForigenAddress,',')
                Insert Into Common.AddressBook 
			    (
			    Id,IsLocal, Street, UnitNo, City, State, Country,PostalCode,Phone,Email,UserCreated,CreatedDate,DocumentId,RecOrder
			    )
			    Values(@New_Frn_AddressBookId,0,(Select AddrName From #Strng_Splt Where Id=1),(Select AddrName From #Strng_Splt Where Id=2),(Select AddrName From #Strng_Splt Where Id=3),(Select AddrName From #Strng_Splt Where Id=4),(Select AddrName From #Strng_Splt Where Id=5),(Select AddrName From #Strng_Splt Where Id=6),
			    (SELECT Phone   FROM ImportLeads WHERE  AccountId=@MasterId and Name=@AccountName and TransactionId=@TransactionId and Id=@AccountIduni),
			    (SELECT Email   FROM ImportLeads WHERE  AccountId=@MasterId and Name=@AccountName and TransactionId=@TransactionId and Id=@AccountIduni),'System',GETUTCDATE(),@AccountId,2 )
			     Insert Into Common.Addresses
			     (
				  Id,AddSectionType,AddType,AddTypeId,AddTypeIdInt,AddressBookId,CompanyId,DocumentId,EntityId,CopyId
				 )
				 Values(NEWID(),'Mailing Address','Account',@AccountId,null,@New_Frn_AddressBookId,@CompanyId,@AccountId,Null,Null)
				 Truncate Table #Strng_Splt
			   End
			 END
		 ------============================ addressbook and address contact and contactdetail in Common.Contact table========================================
             Select @PerLocalAddress=PersonalLocalAddress,@EntyLocalAddress=EntityLocalAddress,
			 @PerForigenAddress=PersonalForeignAddress,@EntyForigenAddress=EntityForeignAddress
			 From ImportContacts 
	         Where Name=@ContactName  and id=@id and MasterId=@MasterId and TransactionId=@TransactionId
			 ----------------------PerLocalAddress and EntyLocalAddress
			 If @PerLocalAddress Is Not Null ---PerLocalAddress in Common.Contact table
			 Begin
			  Set @New_Loc_AddressBookId =NewId()
			  Insert Into #Strng_Splt(AddrName)
			  Select Value From string_split(@PerLocalAddress,',')
              Insert Into Common.AddressBook 
			  (
			   Id,IsLocal,BlockHouseNo,Street,UnitNo,BuildingEstate,City,PostalCode,State,Country,Phone,Email,UserCreated,CreatedDate,DocumentId,RecOrder
			  )
			  Values(@New_Loc_AddressBookId,1,(Select AddrName From #Strng_Splt Where Id=1),(Select AddrName From #Strng_Splt Where Id=2),(Select AddrName From #Strng_Splt Where Id=3),(Select AddrName From #Strng_Splt Where Id=4),(Select AddrName From #Strng_Splt Where Id=5),(Select AddrName From #Strng_Splt Where Id=6),(Select AddrName From #Strng_Splt Where Id=5),(Select AddrName From #Strng_Splt Where Id=5),
			  (SELECT PersonalPhone   FROM ImportContacts WHERE Name=@ContactName  and id=@id and MasterId=@MasterId and TransactionId=@TransactionId),
			  (SELECT PersonalEmail   FROM ImportContacts WHERE Name=@ContactName  and id=@id and MasterId=@MasterId and TransactionId=@TransactionId),'System',GETUTCDATE(),@AccountId,1  )
			  Truncate Table #Strng_Splt
              Insert Into Common.Addresses 
			  (
			   Id,AddSectionType,AddType,AddTypeId,AddTypeIdInt,AddressBookId,CompanyId,DocumentId,EntityId,CopyId
			  )
			  Values(NEWID(),'Residential Address','Contact',@ContactId,null,@New_Loc_AddressBookId,@CompanyId,@AccountId,Null,Null)
			 End
			 If @EntyLocalAddress Is Not Null ---EntyLocalAddress in Common.Contactdetail table
			 Begin
			  Set @New_Frn_AddressBookId=NewId()
			  Insert Into #Strng_Splt(AddrName)
			  Select Value From string_split(@EntyLocalAddress,',')
              Insert Into Common.AddressBook 
			  (
			   Id,IsLocal,BlockHouseNo,Street,UnitNo,BuildingEstate,City,PostalCode,State,Country,Phone,Email,UserCreated,CreatedDate,DocumentId,RecOrder
			  )
			  Values(@New_Frn_AddressBookId,1,(Select AddrName From #Strng_Splt Where Id=1),(Select AddrName From #Strng_Splt Where Id=2),(Select AddrName From #Strng_Splt Where Id=3),(Select AddrName From #Strng_Splt Where Id=4),(Select AddrName From #Strng_Splt Where Id=5),(Select AddrName From #Strng_Splt Where Id=6),(Select AddrName From #Strng_Splt Where Id=5),(Select AddrName From #Strng_Splt Where Id=5),
			  (SELECT EntityPhone FROM ImportContacts WHERE Name=@ContactName  and id=@id  and MasterId=@MasterId and TransactionId=@TransactionId),
			  (SELECT EntityEmail FROM ImportContacts WHERE Name=@ContactName  and id=@id and MasterId=@MasterId and TransactionId=@TransactionId),'System',GETUTCDATE(),@AccountId,1 )
			  Insert Into Common.Addresses 
			  (
			   Id,AddSectionType,AddType,AddTypeId,AddTypeIdInt,AddressBookId,CompanyId,DocumentId,EntityId,CopyId
			  )
			  Values(NEWID(),'Residential Address','AccountContactDetailId',@ContactIdDeatialId,null,@New_Frn_AddressBookId,@CompanyId,@AccountId,Null,Null)
			  Truncate Table #Strng_Splt
			 End
			 --------------------------PerForigenAddress and  EntyForigenAddress
             If @PerForigenAddress Is Not Null  ---EntyLocalAddress in Common.Contact table
			 Begin
			  Set @New_Loc_AddressBookId =NewId()
			  Insert Into #Strng_Splt(AddrName)
			  Select Value From string_split(@PerForigenAddress,',')
              Insert Into Common.AddressBook
			  (
			  Id,IsLocal, Street, UnitNo, City, State, Country,PostalCode,Phone,Email,UserCreated,CreatedDate,DocumentId,RecOrder
			  )
			  Values(@New_Loc_AddressBookId,0,(Select AddrName From #Strng_Splt Where Id=1),(Select AddrName From #Strng_Splt Where Id=2),(Select AddrName From #Strng_Splt Where Id=3),(Select AddrName From #Strng_Splt Where Id=4),(Select AddrName From #Strng_Splt Where Id=5),(Select AddrName From #Strng_Splt Where Id=6),
			  (SELECT PersonalPhone   FROM ImportContacts WHERE Name=@ContactName  and id=@id and MasterId=@MasterId and TransactionId=@TransactionId),
			  (SELECT PersonalEmail   FROM ImportContacts WHERE Name=@ContactName  and id=@id and MasterId=@MasterId and TransactionId=@TransactionId),'System',GETUTCDATE(),@AccountId,2)
			  Truncate Table #Strng_Splt
              Insert Into Common.Addresses (Id,AddSectionType,AddType,AddTypeId,AddTypeIdInt,AddressBookId,CompanyId,DocumentId,EntityId,CopyId)
			  Values(NEWID(),'Office Address','Contact',@ContactId,null,@New_Loc_AddressBookId,@CompanyId,@AccountId,null,null)
			 End
			 If @EntyForigenAddress Is Not Null  ---EntyLocalAddress in Common.Contactdetail table
			 Begin
			  Set @New_Frn_AddressBookId=NewId()
			  Insert Into #Strng_Splt(AddrName)
			  Select Value From string_split(@EntyForigenAddress,',')
              Insert Into Common.AddressBook (Id,IsLocal, Street, UnitNo, City, State, Country,PostalCode,Phone,Email,UserCreated,CreatedDate,DocumentId,RecOrder)
			  Values(@New_Frn_AddressBookId,0,(Select AddrName From #Strng_Splt Where Id=1),(Select AddrName From #Strng_Splt Where Id=2),(Select AddrName From #Strng_Splt Where Id=3),(Select AddrName From #Strng_Splt Where Id=4),(Select AddrName From #Strng_Splt Where Id=5),(Select AddrName From #Strng_Splt Where Id=6),
			  (SELECT EntityPhone FROM ImportContacts WHERE Name=@ContactName  and id=@id and MasterId=@MasterId and TransactionId=@TransactionId),
			  (SELECT EntityEmail FROM ImportContacts WHERE Name=@ContactName  and id=@id and MasterId=@MasterId and TransactionId=@TransactionId ),'System',GETUTCDATE(),@AccountId,2 )
			  Insert Into Common.Addresses 
			  (
			   Id,AddSectionType,AddType,AddTypeId,AddTypeIdInt,AddressBookId,CompanyId,DocumentId,EntityId,CopyId
			  )
			  Values(NEWID(),'Office Address','AccountContactDetailId',@ContactIdDeatialId,null,@New_Frn_AddressBookId,@CompanyId,@AccountId,null,null)
			  Truncate Table #Strng_Splt
			 End
		 END				
          ---============================THIS Contact name same and diff client Insert into contactDetail Table --=========================================================
		 ELSE 
		 If Exists (Select  Id from  ClientCursor.Account Where AccountId=@MasterId and  CompanyId=@companyId) ---===Check AccountId  in ClientCursor.Account table
		 Begin
			SET @AccountNewId =(Select  Id from  ClientCursor.Account Where AccountId=@MasterId and  CompanyId=@companyId)
			SET @AccountNewName =(Select  Name from  ClientCursor.Account Where AccountId=@MasterId and  CompanyId=@companyId)
		    SET @ContactNewId=(Select  Id from  Common.Contact Where  FirstName=@ContactName and  case when  IdType is null  then 'xxx' else IdType end   =  case when  @IdTypeID is null  then 'xxx' else @IdTypeID end  and  case when  IdNo is null  then 'xxx' else IdNo end = case when  @IdNumber is null  then 'xxx' else @IdNumber END and  CompanyId=@companyId )
            If Not Exists (Select Distinct Id from  Common.ContactDetails Where ContactId=@ContactNewId  AND EntityId=@AccountNewId) ---===Check ContactName  in Common.Contact table
		    Begin
             SET @ContactIdDeatialNewId=NewId()
             Set @PerEmailJson =(Select 'Email' As 'key',PersonalEmail As 'value' From ImportContacts Where Name=@ContactName and PersonalEmail is not null  and id=@id and MasterId=@MasterId and TransactionId=@TransactionId For Json Auto)
             Set @PerMobileJson =(Select 'Mobile' As 'key',PersonalPhone As 'value' From ImportContacts Where Name=@ContactName and PersonalPhone is not null and id=@id and MasterId=@MasterId and TransactionId=@TransactionId For Json Auto)
             Set @EntEmailJson =(Select 'Email' As 'key',EntityEmail As 'value' From ImportContacts Where Name=@ContactName and EntityEmail is not null and id=@id and MasterId=@MasterId and TransactionId=@TransactionId For Json Auto)
             Set @EntMobileJson =(Select 'Mobile' As 'key',EntityPhone As 'value' From ImportContacts Where Name=@ContactName and EntityPhone is not null  and id=@id and MasterId=@MasterId and TransactionId=@TransactionId For Json Auto)
			 If @PerEmailJson Is Not Null
			 Begin
			  If @PerMobileJson Is Not Null
			  Begin
			   Set @PerJsondata =Concat(Substring(@PerEmailJson,1,len(@PerEmailJson)-1),',',Substring(@PerMobileJson,2,len(@PerMobileJson)))
			  End	
			  Else
			  Begin
				Set @PerJsondata=@PerEmailJson
			  End
			 End
			 If @PerEmailJson Is Null
			 Begin
			  If @PerMobileJson Is Not Null
			  Begin
				Set @PerJsondata=@PerMobileJson
			  End
			  Else
		      Begin
				Set @PerJsondata=null
			  End
			 END
			 If @EntEmailJson Is Not Null
			 Begin
			   If @EntMobileJson Is Not Null
			   Begin
			    Set @EntJsondata =Concat(Substring(@EntEmailJson,1,len(@EntEmailJson)-1),',',Substring(@EntMobileJson,2,len(@EntMobileJson)))
			   End	
			   Else
			   Begin
				 Set @EntJsondata=@EntEmailJson
			   End
			 End
			 If @EntEmailJson Is Null
			 Begin
			  If @EntMobileJson Is Not Null
			  Begin
			   Set @EntJsondata=@EntMobileJson
			  End
			  Else
			  Begin
			    Set @EntJsondata=null
			  End
			 END
              ----========================================  insert into Contact Deatils table===============================
             INSERT INTO Common.ContactDetails
			 (
			 Id,	ContactId,	EntityId,	EntityType,	Designation,	
			 Communication,		IsPrimaryContact,	IsReminderReceipient,
			 RecOrder,CursorShortCode	,	IsCopy,	UserCreated,	CreatedDate,	Remarks,Status
			 )
             Select  @ContactIdDeatialNewId,@ContactNewId as ContactId,@AccountNewId AS EntityId,'Account' as 'EntityType',EntityDesignation as Designation,@EntJsondata as 'Communication',
					--   Case when  Fee=0 and Quotation=0 and Admin=0
					--   and AssignmentBilling=0  and Others=0 then NULL
					--     when  Fee is null and Quotation is null and Admin is null
					--   and AssignmentBilling is null and Others is null  then NULL
					--ELSE substring(case when Fee=1 then 'Fee;' else '' end + 
					--  case when Quotation=1 then 'Quotations;' else '' end+ 
					--  case when Admin=1 then 'Admin;' else '' end+
					--  case when AssignmentBilling=1 THEN 'Assignment Billing;' ELSE '' end +
					--  CASE WHEN Others=1 THEN 'Others;' else '' end ,1,
					--  (LEN(case when Fee=1 then 'Fee;' else '' end + 
					--  case when Quotation=1 then 'Quotations;' else '' end+ 
					--  case when Admin=1 then 'Admin;' else '' end+
					--  case when AssignmentBilling=1 THEN 'Assignment Billing;' ELSE '' end +
					--  CASE WHEN Others=1 THEN 'Others;' else '' end)-1)) END as 'Matters',
			  PrimaryContacts as IsPrimaryContact,
			  ReminderRecipient as 'IsReminderReceipient', 1 RecOredr,   'CC' as 'CursorShortCode',
			  copycommunicationandAddress as IsCopy,'System' as UserCreated,GETUTCDATE() as CreatedDate,Remarks,1 as Status
			  from ImportContacts C
			  Where Name=@ContactName  and id=@id and MasterId=@MasterId and TransactionId=@TransactionId AND (ImportStatus<>0 or ImportStatus is null)
			  --- Update Common.ContactDetails set IsPrimaryContact=0 where EntityId=@AccountNewId and ContactId<>@ContactNewId and id<>@ContactIdDeatialNewId --this is primarycontact 1 condition
              UPDATE  ImportContacts set ErrorRemarks=null  where Name=@ContactName  and id=@id and MasterId=@MasterId and TransactionId=@TransactionId
			  UPDATE  ImportContacts set ImportStatus=1  where Name=@ContactName  and id=@id and MasterId=@MasterId and TransactionId=@TransactionId
                -------------------- addressbook and address  in ClientCursor.Account table
              Select @LocalAddress=LocalAddress,@ForigenAddress=Foreignaddress
	          From ImportLeads
	          Where   AccountId=@MasterId and NAME=@AccountNewName AND TransactionId=@TransactionId
				----------------------PerLocalAddress and EntyLocalAddress in  ClientCursor.Account table
			  If Not Exists (Select Id from Common.Addresses Where AddTypeId=@AccountNewId and  CompanyId=@companyId ) --== check AccountId in  Common.Addresses table
		      Begin
                If @LocalAddress Is Not Null  ---------- LocalAddress in  ClientCursor.Account table
				Begin
				  Set @New_Loc_AddressBookId =NewId()
				  Insert Into #Strng_Splt(AddrName)
						     Select Value From string_split(@LocalAddress,',')

						     Insert Into Common.AddressBook (Id,IsLocal,BlockHouseNo,Street,UnitNo,BuildingEstate,City,PostalCode,State,Country,Phone,Email,UserCreated,CreatedDate,DocumentId,RecOrder)
						
							 Values(@New_Loc_AddressBookId,1,(Select AddrName From #Strng_Splt Where Id=1),(Select AddrName From #Strng_Splt Where Id=2),(Select AddrName From #Strng_Splt Where Id=3),(Select AddrName From #Strng_Splt Where Id=4),(Select AddrName From #Strng_Splt Where Id=5),(Select AddrName From #Strng_Splt Where Id=6),(Select AddrName From #Strng_Splt Where Id=5),(Select AddrName From #Strng_Splt Where Id=5),
							(SELECT Phone   FROM ImportLeads WHERE  AccountId=@MasterId and Name=@AccountNewName and TransactionId=@TransactionId),
							(SELECT Email   FROM ImportLeads WHERE   AccountId=@MasterId and Name=@AccountNewName and TransactionId=@TransactionId),'System',GETUTCDATE(),@AccountNewId,1  )
							
							Truncate Table #Strng_Splt

							Insert Into Common.Addresses (Id,AddSectionType,AddType,AddTypeId,AddTypeIdInt,AddressBookId,CompanyId,DocumentId,EntityId,CopyId)
						
							Values(NEWID(),'Registered Address','Account',@AccountNewId,null,@New_Loc_AddressBookId,@CompanyId,@AccountNewId,Null,Null)
					    End
						If @ForigenAddress Is Not Null ---------- ForigenAddress in  ClientCursor.Account table
						 Begin
								  Set @New_Frn_AddressBookId=NewId()
								  Insert Into #Strng_Splt(AddrName)
								  Select Value From string_split(@ForigenAddress,',')

								  Insert Into Common.AddressBook (Id,IsLocal, Street, UnitNo, City, State, Country,PostalCode,Phone,Email,UserCreated,CreatedDate,DocumentId,RecOrder)
							
								  Values(@New_Frn_AddressBookId,0,(Select AddrName From #Strng_Splt Where Id=1),(Select AddrName From #Strng_Splt Where Id=2),(Select AddrName From #Strng_Splt Where Id=3),(Select AddrName From #Strng_Splt Where Id=4),(Select AddrName From #Strng_Splt Where Id=5),(Select AddrName From #Strng_Splt Where Id=6),
								  (SELECT Phone   FROM ImportLeads WHERE  AccountId=@MasterId and Name=@AccountNewName and TransactionId=@TransactionId),
								  (SELECT Email   FROM ImportLeads WHERE  AccountId=@MasterId and Name=@AccountNewName and TransactionId=@TransactionId),'System',GETUTCDATE(),@AccountNewId,2 )
						
						        Insert Into Common.Addresses (Id,AddSectionType,AddType,AddTypeId,AddTypeIdInt,AddressBookId,CompanyId,DocumentId,EntityId,CopyId)
						
						       Values(NEWID(),'Mailing Address','Account',@AccountNewId,null,@New_Frn_AddressBookId,@CompanyId,@AccountNewId,Null,Null)
						       Truncate Table #Strng_Splt
					     End
						 END
					  -------------------- addressbook and address -- contact and contactdetail in Common.Contact table
                        
						  Select @PerLocalAddress=PersonalLocalAddress,@EntyLocalAddress=EntityLocalAddress,
						  @PerForigenAddress=PersonalForeignAddress,@EntyForigenAddress=EntityForeignAddress
						  From ImportContacts 
	                      Where Name=@ContactName  and id=@id and MasterId=@MasterId and TransactionId=@TransactionId
						  ----------------------PerLocalAddress and EntyLocalAddress
					 
						If @EntyLocalAddress Is Not Null ---EntyLocalAddress in Common.Contactdetail table
						Begin
								  Set @New_Frn_AddressBookId=NewId()
								  Insert Into #Strng_Splt(AddrName)
								  Select Value From string_split(@EntyLocalAddress,',')

								  Insert Into Common.AddressBook (Id,IsLocal,BlockHouseNo,Street,UnitNo,BuildingEstate,City,PostalCode,State,Country,Phone,Email,UserCreated,CreatedDate,DocumentId,RecOrder)
							
								  Values(@New_Frn_AddressBookId,1,(Select AddrName From #Strng_Splt Where Id=1),(Select AddrName From #Strng_Splt Where Id=2),(Select AddrName From #Strng_Splt Where Id=3),(Select AddrName From #Strng_Splt Where Id=4),(Select AddrName From #Strng_Splt Where Id=5),(Select AddrName From #Strng_Splt Where Id=6),(Select AddrName From #Strng_Splt Where Id=5),(Select AddrName From #Strng_Splt Where Id=5),
								  (SELECT EntityPhone FROM ImportContacts WHERE Name=@ContactName  and id=@id  and MasterId=@MasterId and TransactionId=@TransactionId),
								  (SELECT EntityEmail FROM ImportContacts WHERE Name=@ContactName  and id=@id and MasterId=@MasterId and TransactionId=@TransactionId),'System',GETUTCDATE(),@AccountNewId,1 )
						
						        Insert Into Common.Addresses (Id,AddSectionType,AddType,AddTypeId,AddTypeIdInt,AddressBookId,CompanyId,DocumentId,EntityId,CopyId)
						
						       Values(NEWID(),'Residential Address','AccountContactDetailId',@ContactIdDeatialNewId,null,@New_Frn_AddressBookId,@CompanyId,@AccountNewId,Null,Null)
						       Truncate Table #Strng_Splt
					      End
					     If @EntyForigenAddress Is Not Null  ---EntyLocalAddress in Common.Contactdetail table
					      Begin
						      Set @New_Frn_AddressBookId=NewId()
						       Insert Into #Strng_Splt(AddrName)
						       Select Value From string_split(@EntyForigenAddress,',')

						       Insert Into Common.AddressBook (Id,IsLocal, Street, UnitNo, City, State, Country,PostalCode,Phone,Email,UserCreated,CreatedDate,DocumentId,RecOrder)
							
								Values(@New_Frn_AddressBookId,0,(Select AddrName From #Strng_Splt Where Id=1),(Select AddrName From #Strng_Splt Where Id=2),(Select AddrName From #Strng_Splt Where Id=3),(Select AddrName From #Strng_Splt Where Id=4),(Select AddrName From #Strng_Splt Where Id=5),(Select AddrName From #Strng_Splt Where Id=6),
							
								(SELECT EntityPhone FROM ImportContacts WHERE Name=@ContactName  and id=@id and MasterId=@MasterId and TransactionId=@TransactionId),
								(SELECT EntityEmail FROM ImportContacts WHERE Name=@ContactName  and id=@id and MasterId=@MasterId and TransactionId=@TransactionId ),'System',GETUTCDATE(),@AccountNewId,2 )
						
								Insert Into Common.Addresses (Id,AddSectionType,AddType,AddTypeId,AddTypeIdInt,AddressBookId,CompanyId,DocumentId,EntityId,CopyId)
						
								Values(NEWID(),'Office Address','AccountContactDetailId',@ContactIdDeatialNewId,null,@New_Frn_AddressBookId,@CompanyId,@AccountNewId,null,null)
								Truncate Table #Strng_Splt
					    End
						end

							  
							  -----------------------------------------------
						-- //ELSE  
						--	BEGIN    
			 		--		 UPDATE  ImportContacts set ErrorRemarks=Case when ErrorRemarks is not null then  CONCAT(ErrorRemarks,',',  'Contactname Already Exists Please entered the correct information.')
      --                       Else 'Contactname Already Exists Please entered the correct information.' end  where Name=@ContactName  and id=@id and MasterId=@MasterId and TransactionId=@TransactionId
			 		--		 UPDATE  ImportContacts set ImportStatus=0  where Name=@ContactName  and id=@id and MasterId=@MasterId and TransactionId=@TransactionId
					 --      End //

                      END
					  END
			-- // ELSE 
			--BEGIN 
			-- UPDATE  ImportContacts set ErrorRemarks=Case when ErrorRemarks is not null then  CONCAT(ErrorRemarks,',',  'Please enter the correct Accountid')
   --          Else 'Please enter the correct Accountid' end  where Name=@ContactName  and id=@id and MasterId=@MasterId and TransactionId=@TransactionId
			-- UPDATE  ImportContacts set ImportStatus=0  where Name=@ContactName  and id=@id and MasterId=@MasterId and TransactionId=@TransactionId
			--End //
			 END





			            --================================================================================03.12.2019
                COMMIT TRANSACTION;
                END TRY
                BEGIN CATCH
                Declare @ErrorMessage Nvarchar(4000)=error_message();
                ROLLBACK;
                If @ErrorMessage is not null
	                begin 

		            UPDATE  Importleads set AccountErrorRemarks='please check Contact '   where AccountId=@MasterId and TransactionId=@TransactionId 
		            UPDATE  Importleads set AccountImportStatus=0  where AccountId=@MasterId and TransactionId=@TransactionId 
					UPDATE  ImportContacts set ErrorRemarks=@ErrorMessage  where Name=@ContactName  and id=@id and MasterId=@MasterId and TransactionId=@TransactionId
			 		UPDATE  ImportContacts set ImportStatus=0  where Name=@ContactName  and id=@id and MasterId=@MasterId and TransactionId=@TransactionId
	                
					     Declare @Failure int=( select count(*) from Importleads where TransactionId=@TransactionId and AccountImportStatus=0)
   Declare @Success int=( select count(*) from Importleads where TransactionId=@TransactionId and AccountImportStatus=1)

   update Common.[Transaction] 
   set FailedRecords=@Failure,
   [Status]=(select case when @Failure<>0 and @Success<>0 then 'Partially Completed' when @Failure=0 and @Success<>0 then 'Completed'when @Failure<>0 and @Success=0 then 'Failed'end )
   , TotalRecords=( select count(*) from Importleads where TransactionId=@TransactionId)
   , [Remarks]=(select case when @Failure<>0 and @Success<>0 then 'Some Accounts Inserted' when @Failure=0 and @Success<>0 then 'All Accounts Inserted'when @Failure<>0 and @Success=0 then 'All Accounts Failed'end )
  where CompanyId=@companyId and id=@TransactionId


					End 
                END CATCH
		  --================================================================================03.12.2019

           
	fetch next from ContactId_Get Into @id,@ContactName,@IdType,@IdNumber,@MasterId
	End
	Close ContactId_Get
	Deallocate ContactId_Get
	Drop Table #Strng_Splt	

	END



	 --COMMIT TRANSACTION;
  --END TRY
  --   BEGIN CATCH
	 ---- Declare @ErrorMessage Nvarchar(4000)
	 ---- ROLLBACK;
	 ---- Select @ErrorMessage=error_message();
	 ---- Raiserror(@ErrorMessage,16,1);
  --       Declare @error nvarchar(max) = error_message();
  --END CATCH



	--END
	

	
Update  hh set IsPrimaryContact=case when Rank=1 then 1 else 0 end from 
   --select id,ContactId,EntityId,IsPrimaryContact,CreatedDate,Rank, case when Rank=1 then 1 else 0 end as Isprimary  from
(
 select  id,ContactId,EntityId,IsPrimaryContact,CreatedDate ,
 RANK()over(partition by EntityId order by CreatedDate desc) as 'Rank'
 from Common.ContactDetails where  CreatedDate Is not null And EntityId Is not null and  EntityType='Account' and IsPrimaryContact=1  and
 ContactId in ( select DISTINCT   id from Common.Contact where CompanyId=@companyId  AND 
 FirstName COLLATE DATABASE_DEFAULT IN (select DISTINCT Name from ImportContacts C where TransactionId=@TransactionId  ))
)hh
--order by EntityId





Update  hh set IsPrimaryContact=case when Rank=1 then 1 else 0 end from 
   --select id,ContactId,EntityId,IsPrimaryContact,CreatedDate,Rank, case when Rank=1 then 1 else 0 end as Isprimary  from
(
 select  id,ContactId,EntityId,IsPrimaryContact,CreatedDate ,
 RANK()over(partition by EntityId order by CreatedDate ASC) as 'Rank' From Common.ContactDetails Where EntityId In 

(
Select A.EntityId From 
(
Select Count(*) As Cnt,EntityId From Common.ContactDetails  where  CreatedDate Is not null And EntityId Is not null and  EntityType='Account'  AND 
 ContactId in ( select DISTINCT   id from Common.Contact where CompanyId=@companyId  AND 
 FirstName COLLATE DATABASE_DEFAULT IN (select DISTINCT Name from ImportContacts C where TransactionId=@TransactionId  ))
 Group By EntityId 
) As A
Inner Join 
(
Select Count(*) As Cnt,EntityId From Common.ContactDetails  where  CreatedDate Is not null And EntityId Is not null and  EntityType='Account' and  IsPrimaryContact=0 AND 
 ContactId in ( select DISTINCT   id from Common.Contact where CompanyId=@companyId  AND 
 FirstName COLLATE DATABASE_DEFAULT IN (select DISTINCT Name from ImportContacts C where TransactionId=@TransactionId  ))
 Group By EntityId 

) As B On A.EntityId =B.EntityId And A.Cnt =B.Cnt
)
) HH 
--order by EntityId


   Begin
   Exec [dbo].[Import_Account_To_Client_Entity] @companyId  -------- SYC  ACCOUNTS TO CLIENTS 
   End
    Begin
 update c set c.BlockHouseNo='', c.BuildingEstate=''  from  Common.AddressBook c
 inner join Common.Addresses a on a.AddressBookId=c.Id
 where a.CompanyId=@companyId 
  and c.BlockHouseNo is null and  c.BuildingEstate is null
   End


							 
							 
	
GO
