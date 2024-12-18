USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[Import_ContactsDetail_Validation_Old]    Script Date: 16-12-2024 9.20.10 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




create   PROCEDURE [dbo].[Import_ContactsDetail_Validation_Old] 
  --- exec [dbo].[Import_ContactsDetail_Validation]  583,'6DAC014A-69CF-411D-9616-B0B1B124EDD3'
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
@AccountNewName Nvarchar(max)

      --Begin Transaction  
      --Begin Try

   -- Validation of Client Import Tables

	-- validate	and update ImportStatus=0


	
 --update c set  c.Fee=0  from ImportContacts C
 --where c.Fee is null  and c.TransactionId=@TransactionId

 --update c set  c.Quotation=0  from ImportContacts C
 --where c.Quotation is null  and c.TransactionId=@TransactionId

 --update c set  c.Admin=0  from ImportContacts C
 --where c.Admin is null  and c.TransactionId=@TransactionId

 --update c set  c.AssignmentBilling=0  from ImportContacts C
 --where c.AssignmentBilling is null  and c.TransactionId=@TransactionId

 --update c set  c.Others=0  from ImportContacts C
 --where c.Others is null  and c.TransactionId=@TransactionId

 -- update c set  c.EntityPhone=''  from ImportContacts C
 --where c.EntityPhone is null  and c.TransactionId=@TransactionId

 -- update c set  c.EntityEmail=''  from ImportContacts C
 --where c.EntityEmail is null  and c.TransactionId=@TransactionId

 -- update c set  c.PersonalEmail=''  from ImportContacts C
 --where c.PersonalEmail is null  and c.TransactionId=@TransactionId

 -- update c set  c.PersonalPhone=''  from ImportContacts C
 --where c.PersonalPhone is null  and c.TransactionId=@TransactionId

 -- update c set  c.Phone=''  from ImportLeads C
 --where c.Phone is null  and c.TransactionId=@TransactionId

 -- update c set  c.Email='' from ImportLeads C
 --where c.Email is null  and c.TransactionId=@TransactionId



	if Exists (select Name from ImportContacts where Name is null and  TransactionId=@TransactionId)
	begin
		Update ImportContacts set ErrorRemarks = 'Mandatory field Name  missed', ImportStatus=0
		where  Name is null and TransactionId=@TransactionId
	end 

	 if Exists (select MasterId from ImportContacts where MasterId is null  and TransactionId=@TransactionId)
	begin
		Update ImportContacts set ErrorRemarks = 'Mandatory field MasterId  missed', ImportStatus=0
		where  MasterId is null and TransactionId=@TransactionId
	end 

	 if Exists (select Salutation from ImportContacts where Salutation is null  and TransactionId=@TransactionId)
	begin
		Update ImportContacts set ErrorRemarks = 'Mandatory field Salutation  missed', ImportStatus=0
		where  Salutation is null and TransactionId=@TransactionId
	end 

	-- if Exists (select PersonalEmail from ImportContacts where PersonalEmail is null  and TransactionId=@TransactionId)
	--begin
	--	Update ImportContacts set ErrorRemarks = 'Mandatory field PersonalEmail  missed', ImportStatus=0
	--	where  PersonalEmail is null and TransactionId=@TransactionId
	--end 

	-- if Exists (select PersonalPhone from ImportContacts where PersonalPhone is null  and TransactionId=@TransactionId)
	--begin
	--	Update ImportContacts set ErrorRemarks = 'Mandatory field PersonalPhone  missed', ImportStatus=0
	--	where  PersonalPhone is null and TransactionId=@TransactionId
	--end 

	 if Exists (select PrimaryContacts from ImportContacts where PrimaryContacts is null  and TransactionId=@TransactionId)
	begin
		Update ImportContacts set ErrorRemarks = 'Mandatory field PrimaryContacts  missed', ImportStatus=0
		where  PrimaryContacts is null and TransactionId=@TransactionId
	end 

	 if Exists (select ID from ImportContacts where EntityEmail is null and EntityPhone is null and PersonalPhone is null and  PersonalEmail is null  and TransactionId=@TransactionId)
	begin
		Update ImportContacts set ErrorRemarks = 'Mandatory field ContactCommunication missed', ImportStatus=0
		where  EntityEmail is null and EntityPhone is null and PersonalPhone is null and  PersonalEmail is null and TransactionId=@TransactionId
	end 

	-- if Exists (select EntityPhone from ImportContacts where EntityPhone is null  and TransactionId=@TransactionId)
	--begin
	--	Update ImportContacts set ErrorRemarks = 'Mandatory field EntityPhone  missed', ImportStatus=0
	--	where  EntityPhone is null and TransactionId=@TransactionId
	--end 


	--Update ImportContacts set ErrorRemarks = 'Mandatory fields missed', ImportStatus=0
	--where TransactionId=@TransactionId  and  Name is null or MasterId is null or Salutation is null or PersonalEmail is null and PersonalPhone is null
	--Or PrimaryContacts is null or EntityEmail is null and EntityPhone is null

 ---=========Creating Local temporary Tables  for addresss 
Create Table #Strng_Splt (Id Int Identity(1,1),AddrName Nvarchar(Max))
Declare ContactId_Get Cursor For
--------============== Import Contacts not in Common.Contact table --===============================
        select  Id,Name as ContactName,   IdentificationType , IdentificationNumber,MasterId from ImportContacts where TransactionId=@TransactionId 
        AND ( ImportStatus<>0 oR  ImportStatus IS NULL) ---and  id not in (select DISTINCT   Id from Common.Contact where CompanyId=@companyId)
		Open ContactId_Get
		fetch next from ContactId_Get Into @id,@ContactName,@IdType,@IdNumber,@MasterId
		While @@FETCH_STATUS=0
		Begin
		set @IdTypeID=(select    id  from Common.IdType where  Name=@IdType and CompanyId=@companyId)
         If Exists (Select   Id from  ClientCursor.Account Where AccountId=@MasterId and  CompanyId=@companyId) ---===Check AccountId  in ClientCursor.Account table
		    Begin
		     If Not Exists (Select   Id from  Common.Contact Where  FirstName=@ContactName and  case when  IdType is null  then 'xxx' else IdType end   =  case when  @IdTypeID is null  then 'xxx' else @IdTypeID end  and  case when  IdNo is null  then 'xxx' else IdNo end = case when  @IdNumber is null  then 'xxx' else @IdNumber end  and  CompanyId=@companyId ) ---===Check ContactName  in Common.Contact table
		       Begin
			      --If Not Exists (Select Id from  Common.Contact Where  IdType=@IdType and  CompanyId=@companyId ) ---===Check IdType  in Common.Contact table
		       --     Begin
			      --    If Not Exists (Select Id from  Common.Contact Where  IdNo=@IdNumber and  CompanyId=@companyId ) ---===Check IdNumber  in Common.Contact table
		       --        Begin	

			  ----============== set AccountId,PerEmailJson,PerMobileJson,EntEmailJson,EntMobileJson For Json Auto
                    SET @ContactIdDeatialId=NewId()
					set @ContactId=NewId()
					Set @AccountId =(Select Id from  ClientCursor.Account Where AccountId=@MasterId and  CompanyId=@companyId)
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
                    ------==================================  Insert into contact table 
					  
					  
					 
					   INSERT INTO Common.Contact (id,Salutation,	FirstName,DOB,	IdType,	IdNo,	CountryOfResidence,	
					   RecOrder,Remarks,UserCreated,CreatedDate,Status,Communication,CompanyId)

					   Select @ContactId as Id,Salutation,C.Name as 'FirstName',CONVERT(datetime, DateofBirth, 103) as DOB,@IdTypeID as IdType,
					   C.IdentificationNumber as IdNo,CountryOfResidence, 1 as RecOrder,Remarks,'System' as UserCreated,GetDate() as CreatedDate,
					   Case when Inactive=1 then 0 else 1 end as 'Status',@PerJsondata as 'Communication',@companyid
					   from ImportContacts C
					   Where Name=@ContactName  and id=@id and MasterId=@MasterId and TransactionId=@TransactionId AND (ImportStatus<>0 or ImportStatus is null)


						----========================================  insert into Contact Deatils table

						--Update ImportContacts set PrimaryContacts=0 where MasterId=@MasterId 
					   INSERT INTO Common.ContactDetails (Id,	ContactId,	EntityId,	EntityType,	Designation,	
					   Communication,	Matters,	IsPrimaryContact,	IsReminderReceipient,
					   RecOrder,CursorShortCode	,Status,	IsCopy,	UserCreated,	CreatedDate,	Remarks)

					  Select  @ContactIdDeatialId,@ContactId as ContactId,@AccountId AS EntityId,'Account' as 'EntityType',EntityDesignation as Designation,@EntJsondata as 'Communication',
					    Case when  Fee=0 and Quotation=0 and Admin=0
					   and AssignmentBilling=0  and Others=0 then NULL
					   when  Fee is null and Quotation is null and Admin is null
					   and AssignmentBilling is null and Others is null  then NULL
					ELSE substring(case when Fee=1 then 'Fee;' else '' end + 
					  case when Quotation=1 then 'Quotations;' else '' end+ 
					  case when Admin=1 then 'Admin;' else '' end+
					  case when AssignmentBilling=1 THEN 'Assignment Billing;' ELSE '' end +
					  CASE WHEN Others=1 THEN 'Others;' else '' end ,1,
					  (LEN(case when Fee=1 then 'Fee;' else '' end + 
					  case when Quotation=1 then 'Quotations;' else '' end+ 
					  case when Admin=1 then 'Admin;' else '' end+
					  case when AssignmentBilling=1 THEN 'Assignment Billing;' ELSE '' end +
					  CASE WHEN Others=1 THEN 'Others;' else '' end)-1)) END as 'Matters',1 as IsPrimaryContact,
					  ReminderRecipient as 'IsReminderReceipient', 1 RecOredr,   'CC' as 'CursorShortCode', Case when Inactive=1 then 0 else 1 end as 'Status',
					  copycommunicationandAddress as IsCopy,'System' as UserCreated,getdate() as CreatedDate,Remarks
					  from ImportContacts C
					  Where Name=@ContactName  and id=@id and MasterId=@MasterId and TransactionId=@TransactionId AND (ImportStatus<>0 or ImportStatus is null)


					   Update Common.ContactDetails set IsPrimaryContact=0 where EntityId=@AccountId and ContactId<>@ContactId and id<>@ContactIdDeatialId --this is primarycontact 1 condition

						  
						UPDATE  ImportContacts set ErrorRemarks=null  where Name=@ContactName  and id=@id and MasterId=@MasterId and TransactionId=@TransactionId
			 			UPDATE  ImportContacts set ImportStatus=1  where Name=@ContactName  and id=@id and MasterId=@MasterId and TransactionId=@TransactionId

					    -------------------- addressbook and address  in ClientCursor.Account table
                        
						  Select @LocalAddress=LocalAddress,@ForigenAddress=Foreignaddress
	                      From ImportLeads
	                      Where   AccountId=@MasterId and Name=@AccountName and TransactionId=@TransactionId
						
					  ----------------------PerLocalAddress and EntyLocalAddress in  ClientCursor.Account table
					  If Not Exists (Select  Id from Common.Addresses Where AddTypeId=@AccountId and  CompanyId=@companyId ) --== check AccountId in  Common.Addresses table
		              Begin

					  If @LocalAddress Is Not Null  ---------- LocalAddress in  ClientCursor.Account table
					  Begin
						     Set @New_Loc_AddressBookId =NewId()
						
						     Insert Into #Strng_Splt(AddrName)
						     Select Value From string_split(@LocalAddress,',')

						     Insert Into Common.AddressBook (Id,IsLocal,BlockHouseNo,Street,UnitNo,BuildingEstate,City,PostalCode,State,Country,Phone,Email,UserCreated,CreatedDate,DocumentId,RecOrder)
						
							 Values(@New_Loc_AddressBookId,1,(Select AddrName From #Strng_Splt Where Id=1),(Select AddrName From #Strng_Splt Where Id=2),(Select AddrName From #Strng_Splt Where Id=3),(Select AddrName From #Strng_Splt Where Id=4),(Select AddrName From #Strng_Splt Where Id=5),(Select AddrName From #Strng_Splt Where Id=6),(Select AddrName From #Strng_Splt Where Id=5),(Select AddrName From #Strng_Splt Where Id=5),
							(SELECT Phone   FROM ImportLeads WHERE  AccountId=@MasterId and Name=@AccountName and TransactionId=@TransactionId),
							(SELECT Email   FROM ImportLeads WHERE   AccountId=@MasterId and Name=@AccountName and TransactionId=@TransactionId),'System',getdate(),@AccountId,1  )
							
							Truncate Table #Strng_Splt

							Insert Into Common.Addresses (Id,AddSectionType,AddType,AddTypeId,AddTypeIdInt,AddressBookId,CompanyId,DocumentId,EntityId,CopyId)
						
							Values(NEWID(),'Registered Address','Account',@AccountId,null,@New_Loc_AddressBookId,@CompanyId,@AccountId,Null,Null)
					    End
					  If @ForigenAddress Is Not Null ---------- ForigenAddress in  ClientCursor.Account table
					  Begin
								  Set @New_Frn_AddressBookId=NewId()
								  Insert Into #Strng_Splt(AddrName)
								  Select Value From string_split(@ForigenAddress,',')

								  Insert Into Common.AddressBook (Id,IsLocal,BlockHouseNo,Street,UnitNo,BuildingEstate,City,PostalCode,State,Country,Phone,Email,UserCreated,CreatedDate,DocumentId,RecOrder)
							
								  Values(@New_Frn_AddressBookId,0,(Select AddrName From #Strng_Splt Where Id=1),(Select AddrName From #Strng_Splt Where Id=2),(Select AddrName From #Strng_Splt Where Id=3),(Select AddrName From #Strng_Splt Where Id=4),(Select AddrName From #Strng_Splt Where Id=5),(Select AddrName From #Strng_Splt Where Id=6),(Select AddrName From #Strng_Splt Where Id=5),(Select AddrName From #Strng_Splt Where Id=5),
								  (SELECT Phone   FROM ImportLeads WHERE  AccountId=@MasterId and Name=@AccountName and TransactionId=@TransactionId),
								  (SELECT Email   FROM ImportLeads WHERE  AccountId=@MasterId and Name=@AccountName and TransactionId=@TransactionId),'System',getdate(),@AccountId,2 )
						
						        Insert Into Common.Addresses (Id,AddSectionType,AddType,AddTypeId,AddTypeIdInt,AddressBookId,CompanyId,DocumentId,EntityId,CopyId)
						
						       Values(NEWID(),'Mailing Address','Account',@AccountId,null,@New_Frn_AddressBookId,@CompanyId,@AccountId,Null,Null)
						       Truncate Table #Strng_Splt
					  End
					  END
					  -------------------- addressbook and address -- contact and contactdetail in Common.Contact table
                        
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

						     Insert Into Common.AddressBook (Id,IsLocal,BlockHouseNo,Street,UnitNo,BuildingEstate,City,PostalCode,State,Country,Phone,Email,UserCreated,CreatedDate,DocumentId,RecOrder)
						
							 Values(@New_Loc_AddressBookId,1,(Select AddrName From #Strng_Splt Where Id=1),(Select AddrName From #Strng_Splt Where Id=2),(Select AddrName From #Strng_Splt Where Id=3),(Select AddrName From #Strng_Splt Where Id=4),(Select AddrName From #Strng_Splt Where Id=5),(Select AddrName From #Strng_Splt Where Id=6),(Select AddrName From #Strng_Splt Where Id=5),(Select AddrName From #Strng_Splt Where Id=5),
							(SELECT PersonalPhone   FROM ImportContacts WHERE Name=@ContactName  and id=@id and MasterId=@MasterId and TransactionId=@TransactionId),
							(SELECT PersonalEmail   FROM ImportContacts WHERE Name=@ContactName  and id=@id and MasterId=@MasterId and TransactionId=@TransactionId),'System',getdate(),@AccountId,1  )
							Truncate Table #Strng_Splt

							Insert Into Common.Addresses (Id,AddSectionType,AddType,AddTypeId,AddTypeIdInt,AddressBookId,CompanyId,DocumentId,EntityId,CopyId)
						
							Values(NEWID(),'Registered Address','Contact',@ContactId,null,@New_Loc_AddressBookId,@CompanyId,@AccountId,Null,Null)
					    End
					   If @EntyLocalAddress Is Not Null ---EntyLocalAddress in Common.Contactdetail table
					   Begin
								  Set @New_Frn_AddressBookId=NewId()
								  Insert Into #Strng_Splt(AddrName)
								  Select Value From string_split(@EntyLocalAddress,',')

								  Insert Into Common.AddressBook (Id,IsLocal,BlockHouseNo,Street,UnitNo,BuildingEstate,City,PostalCode,State,Country,Phone,Email,UserCreated,CreatedDate,DocumentId,RecOrder)
							
								  Values(@New_Frn_AddressBookId,1,(Select AddrName From #Strng_Splt Where Id=1),(Select AddrName From #Strng_Splt Where Id=2),(Select AddrName From #Strng_Splt Where Id=3),(Select AddrName From #Strng_Splt Where Id=4),(Select AddrName From #Strng_Splt Where Id=5),(Select AddrName From #Strng_Splt Where Id=6),(Select AddrName From #Strng_Splt Where Id=5),(Select AddrName From #Strng_Splt Where Id=5),
								  (SELECT EntityPhone FROM ImportContacts WHERE Name=@ContactName  and id=@id  and MasterId=@MasterId and TransactionId=@TransactionId),
								  (SELECT EntityEmail FROM ImportContacts WHERE Name=@ContactName  and id=@id and MasterId=@MasterId and TransactionId=@TransactionId),'System',getdate(),@AccountId,1 )
						
						        Insert Into Common.Addresses (Id,AddSectionType,AddType,AddTypeId,AddTypeIdInt,AddressBookId,CompanyId,DocumentId,EntityId,CopyId)
						
						       Values(NEWID(),'Registered Address','AccountContactDetailId',@ContactIdDeatialId,null,@New_Frn_AddressBookId,@CompanyId,@AccountId,Null,Null)
						       Truncate Table #Strng_Splt
					     End
						  --------------------------PerForigenAddress and  EntyForigenAddress
                          If @PerForigenAddress Is Not Null  ---EntyLocalAddress in Common.Contact table
					      Begin
						        Set @New_Loc_AddressBookId =NewId()
						        Insert Into #Strng_Splt(AddrName)
						        Select Value From string_split(@PerForigenAddress,',')

						         Insert Into Common.AddressBook (Id,IsLocal,BlockHouseNo,Street,UnitNo,BuildingEstate,City,PostalCode,State,Country,Phone,Email,UserCreated,CreatedDate,DocumentId,RecOrder)
						
								Values(@New_Loc_AddressBookId,0,(Select AddrName From #Strng_Splt Where Id=1),(Select AddrName From #Strng_Splt Where Id=2),(Select AddrName From #Strng_Splt Where Id=3),(Select AddrName From #Strng_Splt Where Id=4),(Select AddrName From #Strng_Splt Where Id=5),(Select AddrName From #Strng_Splt Where Id=6),(Select AddrName From #Strng_Splt Where Id=5),(Select AddrName From #Strng_Splt Where Id=5),
								(SELECT PersonalPhone   FROM ImportContacts WHERE Name=@ContactName  and id=@id and MasterId=@MasterId and TransactionId=@TransactionId),
								(SELECT PersonalEmail   FROM ImportContacts WHERE Name=@ContactName  and id=@id and MasterId=@MasterId and TransactionId=@TransactionId),'System',getdate(),@AccountId,2)
								Truncate Table #Strng_Splt

						        Insert Into Common.Addresses (Id,AddSectionType,AddType,AddTypeId,AddTypeIdInt,AddressBookId,CompanyId,DocumentId,EntityId,CopyId)
						
						       Values(NEWID(),'Mailing Address','Contact',@ContactId,null,@New_Loc_AddressBookId,@CompanyId,@AccountId,null,null)
					      End
					      If @EntyForigenAddress Is Not Null  ---EntyLocalAddress in Common.Contactdetail table
					      Begin
						      Set @New_Frn_AddressBookId=NewId()
						       Insert Into #Strng_Splt(AddrName)
						       Select Value From string_split(@EntyForigenAddress,',')

						       Insert Into Common.AddressBook (Id,IsLocal,BlockHouseNo,Street,UnitNo,BuildingEstate,City,PostalCode,State,Country,Phone,Email,UserCreated,CreatedDate,DocumentId,RecOrder)
							
								Values(@New_Frn_AddressBookId,0,(Select AddrName From #Strng_Splt Where Id=1),(Select AddrName From #Strng_Splt Where Id=2),(Select AddrName From #Strng_Splt Where Id=3),(Select AddrName From #Strng_Splt Where Id=4),(Select AddrName From #Strng_Splt Where Id=5),(Select AddrName From #Strng_Splt Where Id=6),(Select AddrName From #Strng_Splt Where Id=5),(Select AddrName From #Strng_Splt Where Id=5),
								(SELECT EntityPhone FROM ImportContacts WHERE Name=@ContactName  and id=@id and MasterId=@MasterId and TransactionId=@TransactionId),
								(SELECT EntityEmail FROM ImportContacts WHERE Name=@ContactName  and id=@id and MasterId=@MasterId and TransactionId=@TransactionId ),'System',getdate(),@AccountId,2 )
						
								Insert Into Common.Addresses (Id,AddSectionType,AddType,AddTypeId,AddTypeIdInt,AddressBookId,CompanyId,DocumentId,EntityId,CopyId)
						
								Values(NEWID(),'Mailing Address','AccountContactDetailId',@ContactIdDeatialId,null,@New_Frn_AddressBookId,@CompanyId,@AccountId,null,null)
								Truncate Table #Strng_Splt
					    End
						end
							
							      ---============================THIS Contact name same and diff client Insert into contactDetail Table --=========================================================
					 ELSE 
					 If Exists (Select  Id from  ClientCursor.Account Where AccountId=@MasterId and  CompanyId=@companyId) ---===Check AccountId  in ClientCursor.Account table
		              Begin
							 SET @AccountNewId =(Select  Id from  ClientCursor.Account Where AccountId=@MasterId and  CompanyId=@companyId)
							  SET @AccountNewName =(Select  Name from  ClientCursor.Account Where AccountId=@MasterId and  CompanyId=@companyId)
		                     SET @ContactNewId=(Select  Id from  Common.Contact Where  FirstName=@ContactName  and  CompanyId=@companyId )

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
                
						----========================================  insert into Contact Deatils table

					   INSERT INTO Common.ContactDetails (Id,	ContactId,	EntityId,	EntityType,	Designation,	
					   Communication,	Matters,	IsPrimaryContact,	IsReminderReceipient,
					   RecOrder,CursorShortCode	,Status,	IsCopy,	UserCreated,	CreatedDate,	Remarks)

					  Select  @ContactIdDeatialNewId,@ContactNewId as ContactId,@AccountNewId AS EntityId,'Account' as 'EntityType',EntityDesignation as Designation,@EntJsondata as 'Communication',
					   Case when  Fee=0 and Quotation=0 and Admin=0
					   and AssignmentBilling=0  and Others=0 then NULL
					     when  Fee is null and Quotation is null and Admin is null
					   and AssignmentBilling is null and Others is null  then NULL
					ELSE substring(case when Fee=1 then 'Fee;' else '' end + 
					  case when Quotation=1 then 'Quotations;' else '' end+ 
					  case when Admin=1 then 'Admin;' else '' end+
					  case when AssignmentBilling=1 THEN 'Assignment Billing;' ELSE '' end +
					  CASE WHEN Others=1 THEN 'Others;' else '' end ,1,
					  (LEN(case when Fee=1 then 'Fee;' else '' end + 
					  case when Quotation=1 then 'Quotations;' else '' end+ 
					  case when Admin=1 then 'Admin;' else '' end+
					  case when AssignmentBilling=1 THEN 'Assignment Billing;' ELSE '' end +
					  CASE WHEN Others=1 THEN 'Others;' else '' end)-1)) END as 'Matters',1 as IsPrimaryContact,
					  ReminderRecipient as 'IsReminderReceipient', 1 RecOredr,   'CC' as 'CursorShortCode', Case when Inactive=1 then 0 else 1 end as 'Status',
					  copycommunicationandAddress as IsCopy,'System' as UserCreated,GetDate() as CreatedDate,Remarks
					  from ImportContacts C
					  Where Name=@ContactName  and id=@id and MasterId=@MasterId and TransactionId=@TransactionId AND (ImportStatus<>0 or ImportStatus is null)
					  		   
					    Update Common.ContactDetails set IsPrimaryContact=0 where EntityId=@AccountNewId and ContactId<>@ContactNewId and id<>@ContactIdDeatialNewId --this is primarycontact 1 condition

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
							(SELECT Email   FROM ImportLeads WHERE   AccountId=@MasterId and Name=@AccountNewName and TransactionId=@TransactionId),'System',getdate(),@AccountNewId,1  )
							
							Truncate Table #Strng_Splt

							Insert Into Common.Addresses (Id,AddSectionType,AddType,AddTypeId,AddTypeIdInt,AddressBookId,CompanyId,DocumentId,EntityId,CopyId)
						
							Values(NEWID(),'Registered Address','Account',@AccountNewId,null,@New_Loc_AddressBookId,@CompanyId,@AccountNewId,Null,Null)
					    End
						If @ForigenAddress Is Not Null ---------- ForigenAddress in  ClientCursor.Account table
						 Begin
								  Set @New_Frn_AddressBookId=NewId()
								  Insert Into #Strng_Splt(AddrName)
								  Select Value From string_split(@ForigenAddress,',')

								  Insert Into Common.AddressBook (Id,IsLocal,BlockHouseNo,Street,UnitNo,BuildingEstate,City,PostalCode,State,Country,Phone,Email,UserCreated,CreatedDate,DocumentId,RecOrder)
							
								  Values(@New_Frn_AddressBookId,0,(Select AddrName From #Strng_Splt Where Id=1),(Select AddrName From #Strng_Splt Where Id=2),(Select AddrName From #Strng_Splt Where Id=3),(Select AddrName From #Strng_Splt Where Id=4),(Select AddrName From #Strng_Splt Where Id=5),(Select AddrName From #Strng_Splt Where Id=6),(Select AddrName From #Strng_Splt Where Id=5),(Select AddrName From #Strng_Splt Where Id=5),
								  (SELECT Phone   FROM ImportLeads WHERE  AccountId=@MasterId and Name=@AccountNewName and TransactionId=@TransactionId),
								  (SELECT Email   FROM ImportLeads WHERE  AccountId=@MasterId and Name=@AccountNewName and TransactionId=@TransactionId),'System',getdate(),@AccountNewId,2 )
						
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
								  (SELECT EntityEmail FROM ImportContacts WHERE Name=@ContactName  and id=@id and MasterId=@MasterId and TransactionId=@TransactionId),'System',getdate(),@AccountNewId,1 )
						
						        Insert Into Common.Addresses (Id,AddSectionType,AddType,AddTypeId,AddTypeIdInt,AddressBookId,CompanyId,DocumentId,EntityId,CopyId)
						
						       Values(NEWID(),'Registered Address','AccountContactDetailId',@ContactIdDeatialNewId,null,@New_Frn_AddressBookId,@CompanyId,@AccountNewId,Null,Null)
						       Truncate Table #Strng_Splt
					      End
					     If @EntyForigenAddress Is Not Null  ---EntyLocalAddress in Common.Contactdetail table
					      Begin
						      Set @New_Frn_AddressBookId=NewId()
						       Insert Into #Strng_Splt(AddrName)
						       Select Value From string_split(@EntyForigenAddress,',')

						       Insert Into Common.AddressBook (Id,IsLocal,BlockHouseNo,Street,UnitNo,BuildingEstate,City,PostalCode,State,Country,Phone,Email,UserCreated,CreatedDate,DocumentId,RecOrder)
							
								Values(@New_Frn_AddressBookId,0,(Select AddrName From #Strng_Splt Where Id=1),(Select AddrName From #Strng_Splt Where Id=2),(Select AddrName From #Strng_Splt Where Id=3),(Select AddrName From #Strng_Splt Where Id=4),(Select AddrName From #Strng_Splt Where Id=5),(Select AddrName From #Strng_Splt Where Id=6),(Select AddrName From #Strng_Splt Where Id=5),(Select AddrName From #Strng_Splt Where Id=5),
								(SELECT EntityPhone FROM ImportContacts WHERE Name=@ContactName  and id=@id and MasterId=@MasterId and TransactionId=@TransactionId),
								(SELECT EntityEmail FROM ImportContacts WHERE Name=@ContactName  and id=@id and MasterId=@MasterId and TransactionId=@TransactionId ),'System',getdate(),@AccountNewId,2 )
						
								Insert Into Common.Addresses (Id,AddSectionType,AddType,AddTypeId,AddTypeIdInt,AddressBookId,CompanyId,DocumentId,EntityId,CopyId)
						
								Values(NEWID(),'Mailing Address','AccountContactDetailId',@ContactIdDeatialNewId,null,@New_Frn_AddressBookId,@CompanyId,@AccountNewId,null,null)
								Truncate Table #Strng_Splt
					    End
						end

							  
							  -----------------------------------------------
						ELSE  
							BEGIN    
			 				 UPDATE  ImportContacts set ErrorRemarks='Exists contactName and IdType'  where Name=@ContactName  and id=@id and MasterId=@MasterId and TransactionId=@TransactionId
			 				 UPDATE  ImportContacts set ImportStatus=0  where Name=@ContactName  and id=@id and MasterId=@MasterId and TransactionId=@TransactionId
					       End 

                      END
					  END
			ELSE 
			BEGIN 
			 UPDATE  ImportContacts set ErrorRemarks='Please Insert Accountid'  where Name=@ContactName  and id=@id and MasterId=@MasterId and TransactionId=@TransactionId
			 UPDATE  ImportContacts set ImportStatus=0  where Name=@ContactName  and id=@id and MasterId=@MasterId and TransactionId=@TransactionId
			End 
           
	fetch next from ContactId_Get Into @id,@ContactName,@IdType,@IdNumber,@MasterId
	End
	Close ContactId_Get
	Deallocate ContactId_Get
	Drop Table #Strng_Splt	
	End
   Begin
   Exec [dbo].[Import_Account_To_Client_Entity] @companyId  -------- SYC  ACCOUNTS TO CLIENTS 
   End


									--Commit Transaction  
				     --               End Try  
				     --               Begin Catch  
				     --               RollBack Transaction  
				     --               Throw;  
				     --               End Catch  
						   
							 
							 
							 
							 
--							 --======================================= Import_ContactsDetail_Validation =============================
----accountStatusChange
--SELECT * FROM ClientCursor.AccountStatusChange WHERE CompanyId=583 AND AccountId IN 
--( select id from ClientCursor.Account where   companyid=583  and AccountId in
-- ( SELECT DISTINCT AccountId from ImportLeads where TransactionId='6DAC014A-69CF-411D-9616-B0B1B124EDD3' ))

------- account
-- select id from ClientCursor.Account where   companyid=583  and AccountId in
-- ( SELECT DISTINCT AccountId from ImportLeads where TransactionId='6DAC014A-69CF-411D-9616-B0B1B124EDD3' )


-- ---- contact detail
--select * from Common.ContactDetails where EntityType='Account' and  contactid in 
--(Select Id from  Common.Contact Where CompanyId=583 and  firstname 
--IN (	select DISTINCT Name from ImportContacts C where TransactionId='6DAC014A-69CF-411D-9616-B0B1B124EDD3')) order by ContactId

-- ---- contact 
--Select * from  Common.Contact Where   CompanyId=583 and  firstname IN (	select DISTINCT Name from ImportContacts C where TransactionId='6DAC014A-69CF-411D-9616-B0B1B124EDD3') order by id


------- AddressBook account

-- SELECT * FROM Common.AddressBook WHERE  Id IN ( SELECT DISTINCT AddressBookId FROM Common.Addresses WHERE CompanyId=583 
--  AND AddTypeId IN (select id from ClientCursor.Account where   companyid=583  and AccountId in
-- ( SELECT DISTINCT AccountId from ImportLeads where TransactionId='6DAC014A-69CF-411D-9616-B0B1B124EDD3' )) )

-- ----- Addresses account
--SELECT * FROM Common.Addresses WHERE CompanyId=583 AND AddTypeId IN 
--( select id from ClientCursor.Account where   companyid=583  and AccountId in
-- ( SELECT DISTINCT AccountId from ImportLeads where TransactionId='6DAC014A-69CF-411D-9616-B0B1B124EDD3' )) order by AddTypeId

-- ----- AddressBook contact

-- SELECT * FROM Common.AddressBook WHERE  Id IN ( SELECT DISTINCT AddressBookId FROM Common.Addresses WHERE CompanyId=583 
--  AND AddTypeId IN (select id from Common.Contact where   companyid=583  and FirstName in
-- ( SELECT DISTINCT Name from ImportContacts where TransactionId='6DAC014A-69CF-411D-9616-B0B1B124EDD3' )) )

-- ----- Addresses contact
--SELECT * FROM Common.Addresses WHERE CompanyId=583 AND AddTypeId IN 
--( select id from Common.Contact where   companyid=583  and FirstName in
-- ( SELECT DISTINCT Name from ImportContacts where TransactionId='6DAC014A-69CF-411D-9616-B0B1B124EDD3' )) order by AddTypeId



--  ----- AddressBook contactdetatil

-- SELECT * FROM Common.AddressBook WHERE  Id IN ( SELECT DISTINCT AddressBookId FROM Common.Addresses WHERE CompanyId=583 
--  AND AddTypeId IN (select Id from Common.ContactDetails where  contactid in (select id from Common.Contact where   companyid=583  and FirstName in
-- ( SELECT DISTINCT Name from ImportContacts where TransactionId='6DAC014A-69CF-411D-9616-B0B1B124EDD3' )) ))

-- ----- Addresses contactdetatil
--SELECT * FROM Common.Addresses WHERE CompanyId=583 AND AddTypeId IN (select Id from Common.ContactDetails where  contactid in
--( select id from Common.Contact where   companyid=583  and FirstName in
-- ( SELECT DISTINCT Name from ImportContacts where TransactionId='6DAC014A-69CF-411D-9616-B0B1B124EDD3' )))
GO
