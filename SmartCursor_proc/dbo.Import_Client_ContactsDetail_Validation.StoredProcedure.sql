USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[Import_Client_ContactsDetail_Validation]    Script Date: 16-12-2024 9.20.10 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO







CREATE  PROCEDURE [dbo].[Import_Client_ContactsDetail_Validation]  
 --exec [dbo].[Import_Client_ContactsDetail_Validation] 1136,'F693258B-F201-4C5F-B671-4EF4F26199A3'
@companyId int,
@TransactionId uniqueidentifier
AS
BEGIN 
Declare --@companyId int=809,
@clientId Uniqueidentifier,
@clientName Nvarchar(max),
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
 @ClientNewId Uniqueidentifier,
 @ClientNewName Nvarchar(max),
 @ContactNewId Uniqueidentifier,
 @ContactIdDeatialNewId Uniqueidentifier,
 @clientIdunic Uniqueidentifier

 ---------------------
 --  BEGIN TRANSACTION;
 --   BEGIN TRY
	----------------------

	  ---=========Creating Local temporary Tables  for addresss 
Create Table #Strng_Splt (Id Int Identity(1,1),AddrName Nvarchar(Max))
Declare ContactId_Get Cursor For
--------============== Import Contacts not in Common.Contact table --===============================
        select  Id,Name as ContactName,IdentificationType,IdentificationNumber,ClientRefNumber from  ImportWFContacts where TransactionId=@TransactionId	AND ( ImportStatus<>0 oR  ImportStatus IS NULL)  	
        Open ContactId_Get
		fetch next from ContactId_Get Into @id,@ContactName,@IdType,@IdNumber,@MasterId
		While @@FETCH_STATUS=0
		Begin


		--===================== 03.12.2019
		 
         Begin Transaction  
         Begin Try  
		 --==================== 03.12.2019


		  set @IdTypeID=(select  id  from Common.IdType where  Name=@IdType and CompanyId=@companyId)
         If Exists (Select Id from  WorkFlow.Client Where SystemRefNo=@MasterId and  CompanyId=@companyId) ---===Check AccountId  in ClientCursor.Account table
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
					Set @clientIdunic =(Select top 1 Id from  ImportWFClient Where ClientRefNumber=@MasterId and  TransactionId=@TransactionId)
					Set @clientId =(Select top 1 Id from  WorkFlow.Client Where SystemRefNo=@MasterId and  CompanyId=@companyId)
					Set @clientName =(Select top 1 Name from  WorkFlow.Client Where SystemRefNo=@MasterId and  CompanyId=@companyId)
	                Set @PerEmailJson =(Select 'Email' As 'key',PersonalEmail As 'value' From ImportWFContacts Where Name=@ContactName and PersonalEmail is not null and id=@id and ClientRefNumber=@MasterId and TransactionId=@TransactionId For Json Auto)
					Set @PerMobileJson =(Select 'Mobile' As 'key',PersonalMobile As 'value' From ImportWFContacts Where Name=@ContactName and PersonalMobile is not null and id=@id and ClientRefNumber=@MasterId and TransactionId=@TransactionId For Json Auto)
					Set @EntEmailJson =(Select 'Email' As 'key',EntityEmail As 'value' From ImportWFContacts Where Name=@ContactName and EntityEmail is not null and id=@id and ClientRefNumber=@MasterId and TransactionId=@TransactionId For Json Auto)
					Set @EntMobileJson =(Select 'Mobile' As 'key',	EntityMobile As 'value' From ImportWFContacts Where Name=@ContactName and EntityMobile is not null  and id=@id and ClientRefNumber=@MasterId and TransactionId=@TransactionId For Json Auto)
		
			
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
                    ------==================================  Insert into contact table =================================================
					
					 
					  INSERT INTO Common.Contact (Id,Salutation,FirstName,DOB,IdType,IdNo,	CountryOfResidence,	RecOrder,Remarks,UserCreated,CreatedDate,Status,CompanyId,Communication)

					  select @ContactId,Salutation,	Name as FirstName,CONVERT(datetime, DateofBirth, 103)  as DOB,@IdTypeID as IdType,IdentificationNumber as IdNo,	CountryOfResidence as CountryOfResidence,
	                  1 as RecOrder,Remarks,'System' as UserCreated,getutcdate() as CreatedDate, 1 as 'Status',@companyid,@PerJsondata as 'Communication'
	                  from  ImportWFContacts where  Name=@ContactName  and id=@id and ClientRefNumber=@MasterId and TransactionId=@TransactionId AND (ImportStatus<>0 or ImportStatus is null)


						----========================================  insert into Contact Deatils table

					   INSERT INTO Common.ContactDetails ( Id	,ContactId,	EntityId,	EntityType,	Designation	,Communication,	IsPrimaryContact,	RecOrder,
		               CursorShortCode,	Status,	IsCopy,	UserCreated,	CreatedDate,Remarks)

					   Select  @ContactIdDeatialId,@ContactId as ContactId,@clientId AS EntityId,'Client' as 'EntityType',EntityDesignation as Designation,@EntJsondata as 'Communication',
					   PrimaryContact as IsPrimaryContact, 1 RecOredr,   'WF' as 'CursorShortCode', 1 as 'Status',
					   copycommunicationandAddress as IsCopy,'System' as UserCreated,getutcdate() as CreatedDate,Remarks 
					   from ImportWFContacts where  Name=@ContactName  and id=@id and ClientRefNumber=@MasterId and TransactionId=@TransactionId AND (ImportStatus<>0 or ImportStatus is null)

						UPDATE  ImportWFContacts set ErrorRemarks=null  where  Name=@ContactName  and id=@id and ClientRefNumber=@MasterId and TransactionId=@TransactionId
			 			UPDATE  ImportWFContacts set ImportStatus=1 where  Name=@ContactName  and id=@id and ClientRefNumber=@MasterId and TransactionId=@TransactionId

					    -------------------- addressbook and address  in ClientCursor.Account table
                        
						  Select @LocalAddress=LocalAddress,@ForigenAddress=ForeignAddress
	                      From ImportWFClient
	                      Where    ClientRefNumber=@MasterId and TransactionId=@TransactionId  AND NAME=@clientName and ID=@clientIdunic
						
					  ----------------------PerLocalAddress and EntyLocalAddress in  workflow.client table
					  If Not Exists (Select Id from Common.Addresses Where AddTypeId=@clientId and  CompanyId=@companyId ) --== check clientId in  Common.Addresses table
		          Begin

					   If @LocalAddress Is Not Null  ---------- LocalAddress in  ClientCursor.Account table
					         Begin
						     Set @New_Loc_AddressBookId =NewId()
						
						     Insert Into #Strng_Splt(AddrName)
						     Select Value From string_split(@LocalAddress,',')

						     Insert Into Common.AddressBook (Id,IsLocal,BlockHouseNo,Street,UnitNo,BuildingEstate,City,PostalCode,State,Country,Phone,Email,UserCreated,CreatedDate,DocumentId,RecOrder)
						
							 Values(@New_Loc_AddressBookId,1,(Select AddrName From #Strng_Splt Where Id=1),(Select AddrName From #Strng_Splt Where Id=2),(Select AddrName From #Strng_Splt Where Id=3),(Select AddrName From #Strng_Splt Where Id=4),(Select AddrName From #Strng_Splt Where Id=5),(Select AddrName From #Strng_Splt Where Id=6),(Select AddrName From #Strng_Splt Where Id=5),(Select AddrName From #Strng_Splt Where Id=5),
							(SELECT Mobile   FROM ImportWFClient WHERE  ClientRefNumber=@MasterId  AND NAME=@clientName and TransactionId=@TransactionId and ID=@clientIdunic),
							(SELECT Email   FROM ImportWFClient WHERE   ClientRefNumber=@MasterId AND NAME=@clientName and TransactionId=@TransactionId and ID=@clientIdunic),'System',getutcdate(),@clientId,1  )
							
							Truncate Table #Strng_Splt

							Insert Into Common.Addresses (Id,AddSectionType,AddType,AddTypeId,AddTypeIdInt,AddressBookId,CompanyId,DocumentId,EntityId,CopyId)
						
							Values(NEWID(),'Registered Address','Client',@clientId,null,@New_Loc_AddressBookId,@CompanyId,@clientId,Null,Null)
					    End
						If @ForigenAddress Is Not Null ---------- ForigenAddress in  ClientCursor.Account table
								  Begin
								  Set @New_Frn_AddressBookId=NewId()
								  Insert Into #Strng_Splt(AddrName)
								  Select Value From string_split(@ForigenAddress,',')

								  Insert Into Common.AddressBook (Id,IsLocal, Street, UnitNo, City, State, Country,PostalCode,Phone,Email,UserCreated,CreatedDate,DocumentId,RecOrder)
							
								  Values(@New_Frn_AddressBookId,0,(Select AddrName From #Strng_Splt Where Id=1),(Select AddrName From #Strng_Splt Where Id=2),(Select AddrName From #Strng_Splt Where Id=3),(Select AddrName From #Strng_Splt Where Id=4),(Select AddrName From #Strng_Splt Where Id=5),(Select AddrName From #Strng_Splt Where Id=6),
								  (SELECT Mobile   FROM ImportWFClient WHERE  ClientRefNumber=@MasterId  AND NAME=@clientName and TransactionId=@TransactionId and ID=@clientIdunic),
								  (SELECT Email   FROM ImportWFClient WHERE  ClientRefNumber=@MasterId AND NAME=@clientName and TransactionId=@TransactionId and ID=@clientIdunic),'System',getutcdate(),@clientId,2 )
						
						        Insert Into Common.Addresses (Id,AddSectionType,AddType,AddTypeId,AddTypeIdInt,AddressBookId,CompanyId,DocumentId,EntityId,CopyId)
						
						       Values(NEWID(),'Mailing Address','Client',@clientId,null,@New_Frn_AddressBookId,@CompanyId,@clientId,Null,Null)
						       Truncate Table #Strng_Splt
					      End
						  END
					  -------------------- addressbook and address -- contact and contactdetail in Common.Contact table
                        
						  Select @PerLocalAddress=PersonalLocalAddress,@EntyLocalAddress=EntityLocalAddress,
						  @PerForigenAddress=PersonalForeignAddress,@EntyForigenAddress=EntityForeignAddress
						  From ImportWFContacts
	                      Where Name=@ContactName  and id=@id and ClientRefNumber=@MasterId and TransactionId=@TransactionId
						  ----------------------PerLocalAddress and EntyLocalAddress
					   If @PerLocalAddress Is Not Null ---PerLocalAddress in Common.Contact table
					         Begin
						     Set @New_Loc_AddressBookId =NewId()
						
						     Insert Into #Strng_Splt(AddrName)
						     Select Value From string_split(@PerLocalAddress,',')

						     Insert Into Common.AddressBook (Id,IsLocal,BlockHouseNo,Street,UnitNo,BuildingEstate,City,PostalCode,State,Country,Phone,Email,UserCreated,CreatedDate,DocumentId,RecOrder)
						
							 Values(@New_Loc_AddressBookId,1,(Select AddrName From #Strng_Splt Where Id=1),(Select AddrName From #Strng_Splt Where Id=2),(Select AddrName From #Strng_Splt Where Id=3),(Select AddrName From #Strng_Splt Where Id=4),(Select AddrName From #Strng_Splt Where Id=5),(Select AddrName From #Strng_Splt Where Id=6),(Select AddrName From #Strng_Splt Where Id=5),(Select AddrName From #Strng_Splt Where Id=5),
							(SELECT PersonalMobile   FROM ImportWFContacts WHERE Name=@ContactName and id=@id and ClientRefNumber=@MasterId and TransactionId=@TransactionId),
							(SELECT PersonalEmail   FROM ImportWFContacts WHERE Name=@ContactName  and id=@id and ClientRefNumber=@MasterId and TransactionId=@TransactionId),'System',getutcdate(),@clientId,1  )
							Truncate Table #Strng_Splt

							Insert Into Common.Addresses (Id,AddSectionType,AddType,AddTypeId,AddTypeIdInt,AddressBookId,CompanyId,DocumentId,EntityId,CopyId)
						
							Values(NEWID(),'Registered Address','Contact',@ContactId,null,@New_Loc_AddressBookId,@CompanyId,@clientId,Null,Null)
					    End
						If @EntyLocalAddress Is Not Null ---EntyLocalAddress in Common.Contactdetail table
								  Begin
								  Set @New_Frn_AddressBookId=NewId()
								  Insert Into #Strng_Splt(AddrName)
								  Select Value From string_split(@EntyLocalAddress,',')

								  Insert Into Common.AddressBook (Id,IsLocal,BlockHouseNo,Street,UnitNo,BuildingEstate,City,PostalCode,State,Country,Phone,Email,UserCreated,CreatedDate,DocumentId,RecOrder)
							
								  Values(@New_Frn_AddressBookId,1,(Select AddrName From #Strng_Splt Where Id=1),(Select AddrName From #Strng_Splt Where Id=2),(Select AddrName From #Strng_Splt Where Id=3),(Select AddrName From #Strng_Splt Where Id=4),(Select AddrName From #Strng_Splt Where Id=5),(Select AddrName From #Strng_Splt Where Id=6),(Select AddrName From #Strng_Splt Where Id=5),(Select AddrName From #Strng_Splt Where Id=5),
								  (SELECT EntityMobile FROM ImportWFContacts WHERE Name=@ContactName  and id=@id and ClientRefNumber=@MasterId and TransactionId=@TransactionId),
								  (SELECT EntityEmail FROM ImportWFContacts WHERE Name=@ContactName  and id=@id and ClientRefNumber=@MasterId and TransactionId=@TransactionId),'System',getutcdate(),@clientId,1 )
						
						        Insert Into Common.Addresses (Id,AddSectionType,AddType,AddTypeId,AddTypeIdInt,AddressBookId,CompanyId,DocumentId,EntityId,CopyId)
						
						       Values(NEWID(),'Registered Address','ClientContactDetailId',@ContactIdDeatialId,null,@New_Frn_AddressBookId,@CompanyId,@clientId,Null,Null)
						       Truncate Table #Strng_Splt
					      End
						  --------------------------PerForigenAddress and  EntyForigenAddress
                          If @PerForigenAddress Is Not Null  ---EntyLocalAddress in Common.Contact table
					          Begin
						        Set @New_Loc_AddressBookId =NewId()
						        Insert Into #Strng_Splt(AddrName)
						        Select Value From string_split(@PerForigenAddress,',')

						         Insert Into Common.AddressBook (Id,IsLocal, Street, UnitNo, City, State, Country,PostalCode,Phone,Email,UserCreated,CreatedDate,DocumentId,RecOrder)
						
								Values(@New_Loc_AddressBookId,0,(Select AddrName From #Strng_Splt Where Id=1),(Select AddrName From #Strng_Splt Where Id=2),(Select AddrName From #Strng_Splt Where Id=3),(Select AddrName From #Strng_Splt Where Id=4),(Select AddrName From #Strng_Splt Where Id=5),(Select AddrName From #Strng_Splt Where Id=6),
								(SELECT PersonalMobile   FROM ImportWFContacts WHERE Name=@ContactName  and id=@id and ClientRefNumber=@MasterId and TransactionId=@TransactionId),
								(SELECT PersonalEmail   FROM ImportWFContacts WHERE Name=@ContactName  and id=@id and ClientRefNumber=@MasterId and TransactionId=@TransactionId),'System',getutcdate(),@clientId,2)
								Truncate Table #Strng_Splt

						        Insert Into Common.Addresses (Id,AddSectionType,AddType,AddTypeId,AddTypeIdInt,AddressBookId,CompanyId,DocumentId,EntityId,CopyId)
						
						       Values(NEWID(),'Office Address','Contact',@ContactId,null,@New_Loc_AddressBookId,@CompanyId,@clientId,null,null)
					      End
					     If @EntyForigenAddress Is Not Null  ---EntyLocalAddress in Common.Contactdetail table
					          Begin
						      Set @New_Frn_AddressBookId=NewId()
						       Insert Into #Strng_Splt(AddrName)
						       Select Value From string_split(@EntyForigenAddress,',')

						       Insert Into Common.AddressBook (Id,IsLocal, Street, UnitNo, City, State, Country,PostalCode,Phone,Email,UserCreated,CreatedDate,DocumentId,RecOrder)
							
								Values(@New_Frn_AddressBookId,0,(Select AddrName From #Strng_Splt Where Id=1),(Select AddrName From #Strng_Splt Where Id=2),(Select AddrName From #Strng_Splt Where Id=3),(Select AddrName From #Strng_Splt Where Id=4),(Select AddrName From #Strng_Splt Where Id=5),(Select AddrName From #Strng_Splt Where Id=6),
								(SELECT EntityMobile FROM ImportWFContacts WHERE Name=@ContactName  and id=@id and ClientRefNumber=@MasterId and TransactionId=@TransactionId),
								(SELECT EntityEmail FROM ImportWFContacts WHERE Name=@ContactName  and id=@id and ClientRefNumber=@MasterId and TransactionId=@TransactionId),'System',getutcdate(),@clientId,2 )
						
								Insert Into Common.Addresses (Id,AddSectionType,AddType,AddTypeId,AddTypeIdInt,AddressBookId,CompanyId,DocumentId,EntityId,CopyId)
						
								Values(NEWID(),'Office Address','ClientContactDetailId',@ContactIdDeatialId,null,@New_Frn_AddressBookId,@CompanyId,@clientId,null,null)
								Truncate Table #Strng_Splt
					    End
						End
						--========================================================================

				---============================THIS Contact name same and diff client Insert into contactDetail Table --=========================================================
				 ELSE 
					 If Exists (Select  Id from  WorkFlow.Client Where SystemRefNo=@MasterId and  CompanyId=@companyId) ---===Check AccountId  in ClientCursor.Account table
		              Begin

					   SET @ClientNewId =(Select top 1  Id from  WorkFlow.Client Where SystemRefNo=@MasterId and  CompanyId=@companyId)
						SET @ClientNewName =(Select  top 1  Name from  WorkFlow.Client Where SystemRefNo=@MasterId and  CompanyId=@companyId)
		                 SET @ContactNewId=(Select  Id from  Common.Contact Where  FirstName=@ContactName and  case when  IdType is null  then 'xxx' else IdType end   =  case when  @IdTypeID is null  then 'xxx' else @IdTypeID end  and  case when  IdNo is null  then 'xxx' else IdNo end = case when  @IdNumber is null  then 'xxx' else @IdNumber end  and  CompanyId=@companyId )
					
					If Not Exists (Select Distinct Id from  Common.ContactDetails Where ContactId=@ContactNewId  AND EntityId=@ClientNewId) ---===Check ContactName  in Common.Contact table
		                Begin
						SET @ContactIdDeatialNewId=NewId()

					Set @PerEmailJson =(Select 'Email' As 'key',PersonalEmail As 'value' From ImportWFContacts Where Name=@ContactName and PersonalEmail is not null and id=@id and ClientRefNumber=@MasterId and TransactionId=@TransactionId For Json Auto)
					Set @PerMobileJson =(Select 'Mobile' As 'key',PersonalMobile As 'value' From ImportWFContacts Where Name=@ContactName and PersonalMobile is not null and id=@id and ClientRefNumber=@MasterId and TransactionId=@TransactionId For Json Auto)
					Set @EntEmailJson =(Select 'Email' As 'key',EntityEmail As 'value' From ImportWFContacts Where Name=@ContactName and EntityEmail is not null and id=@id and ClientRefNumber=@MasterId and TransactionId=@TransactionId For Json Auto)
					Set @EntMobileJson =(Select 'Mobile' As 'key',	EntityMobile As 'value' From ImportWFContacts Where Name=@ContactName and EntityMobile is not null  and id=@id and ClientRefNumber=@MasterId and TransactionId=@TransactionId For Json Auto)
				
			
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

					   INSERT INTO Common.ContactDetails ( Id	,ContactId,	EntityId,	EntityType,	Designation	,Communication,	IsPrimaryContact,	RecOrder,
		               CursorShortCode,	Status,	IsCopy,	UserCreated,	CreatedDate,Remarks)

					   Select  @ContactIdDeatialNewId,@ContactNewId as ContactId,@ClientNewId AS EntityId,'Client' as 'EntityType',EntityDesignation as Designation,@EntJsondata as 'Communication',
					   PrimaryContact as IsPrimaryContact, 1 RecOredr,   'WF' as 'CursorShortCode', 1 as 'Status',
					   copycommunicationandAddress as IsCopy,'System' as UserCreated,getutcdate() as CreatedDate,Remarks 
					   from ImportWFContacts where  Name=@ContactName  and id=@id and ClientRefNumber=@MasterId and TransactionId=@TransactionId AND (ImportStatus<>0 or ImportStatus is null)

						UPDATE  ImportWFContacts set ErrorRemarks=null  where  Name=@ContactName  and id=@id and ClientRefNumber=@MasterId and TransactionId=@TransactionId
			 			UPDATE  ImportWFContacts set ImportStatus=1 where  Name=@ContactName  and id=@id and ClientRefNumber=@MasterId and TransactionId=@TransactionId

					    -------------------- addressbook and address  in ClientCursor.Account table
                        
						  Select @LocalAddress=LocalAddress,@ForigenAddress=ForeignAddress
	                      From ImportWFClient
	                      Where    ClientRefNumber=@MasterId and TransactionId=@TransactionId  AND NAME=@ClientNewName
						
					  ----------------------PerLocalAddress and EntyLocalAddress in  workflow.client table
					  If Not Exists (Select Id from Common.Addresses Where AddTypeId=@ClientNewId and  CompanyId=@companyId ) --== check clientId in  Common.Addresses table
		          Begin

					   If @LocalAddress Is Not Null  ---------- LocalAddress in  ClientCursor.Account table
					         Begin
						     Set @New_Loc_AddressBookId =NewId()
						
						     Insert Into #Strng_Splt(AddrName)
						     Select Value From string_split(@LocalAddress,',')

						     Insert Into Common.AddressBook (Id,IsLocal,BlockHouseNo,Street,UnitNo,BuildingEstate,City,PostalCode,State,Country,Phone,Email,UserCreated,CreatedDate,DocumentId,RecOrder)
						
							 Values(@New_Loc_AddressBookId,1,(Select AddrName From #Strng_Splt Where Id=1),(Select AddrName From #Strng_Splt Where Id=2),(Select AddrName From #Strng_Splt Where Id=3),(Select AddrName From #Strng_Splt Where Id=4),(Select AddrName From #Strng_Splt Where Id=5),(Select AddrName From #Strng_Splt Where Id=6),(Select AddrName From #Strng_Splt Where Id=5),(Select AddrName From #Strng_Splt Where Id=5),
							(SELECT Mobile   FROM ImportWFClient WHERE  ClientRefNumber=@MasterId  AND NAME=@ClientNewName and TransactionId=@TransactionId),
							(SELECT Email   FROM ImportWFClient WHERE   ClientRefNumber=@MasterId AND NAME=@ClientNewName and TransactionId=@TransactionId),'System',getutcdate(),@ClientNewId,1  )
							
							Truncate Table #Strng_Splt

							Insert Into Common.Addresses (Id,AddSectionType,AddType,AddTypeId,AddTypeIdInt,AddressBookId,CompanyId,DocumentId,EntityId,CopyId)
						
							Values(NEWID(),'Registered Address','Client',@ClientNewId,null,@New_Loc_AddressBookId,@CompanyId,@ClientNewId,Null,Null)
					    End
						If @ForigenAddress Is Not Null ---------- ForigenAddress in  ClientCursor.Account table
								  Begin
								  Set @New_Frn_AddressBookId=NewId()
								  Insert Into #Strng_Splt(AddrName)
								  Select Value From string_split(@ForigenAddress,',')

								  Insert Into Common.AddressBook (Id,IsLocal, Street, UnitNo, City, State, Country,PostalCode,Phone,Email,UserCreated,CreatedDate,DocumentId,RecOrder)
							
								  Values(@New_Frn_AddressBookId,0,(Select AddrName From #Strng_Splt Where Id=1),(Select AddrName From #Strng_Splt Where Id=2),(Select AddrName From #Strng_Splt Where Id=3),(Select AddrName From #Strng_Splt Where Id=4),(Select AddrName From #Strng_Splt Where Id=5),(Select AddrName From #Strng_Splt Where Id=6),
							
								  (SELECT Mobile   FROM ImportWFClient WHERE  ClientRefNumber=@MasterId  AND NAME=@ClientNewName and TransactionId=@TransactionId),
								  (SELECT Email   FROM ImportWFClient WHERE  ClientRefNumber=@MasterId AND NAME=@ClientNewName and TransactionId=@TransactionId),'System',getutcdate(),@ClientNewId,2 )
						
						        Insert Into Common.Addresses (Id,AddSectionType,AddType,AddTypeId,AddTypeIdInt,AddressBookId,CompanyId,DocumentId,EntityId,CopyId)
						
						       Values(NEWID(),'Mailing Address','Client',@ClientNewId,null,@New_Frn_AddressBookId,@CompanyId,@ClientNewId,Null,Null)
						       Truncate Table #Strng_Splt
					      End
						  END
					  -------------------- addressbook and address -- contact and contactdetail in Common.Contact table
                        
						  Select @PerLocalAddress=PersonalLocalAddress,@EntyLocalAddress=EntityLocalAddress,
						  @PerForigenAddress=PersonalForeignAddress,@EntyForigenAddress=EntityForeignAddress
						  From ImportWFContacts
	                      Where Name=@ContactName  and id=@id and ClientRefNumber=@MasterId and TransactionId=@TransactionId
						  ----------------------PerLocalAddress and EntyLocalAddress
					
						If @EntyLocalAddress Is Not Null ---EntyLocalAddress in Common.Contactdetail table
								  Begin
								  Set @New_Frn_AddressBookId=NewId()
								  Insert Into #Strng_Splt(AddrName)
								  Select Value From string_split(@EntyLocalAddress,',')

								  Insert Into Common.AddressBook (Id,IsLocal,BlockHouseNo,Street,UnitNo,BuildingEstate,City,PostalCode,State,Country,Phone,Email,UserCreated,CreatedDate,DocumentId,RecOrder)
							
								  Values(@New_Frn_AddressBookId,1,(Select AddrName From #Strng_Splt Where Id=1),(Select AddrName From #Strng_Splt Where Id=2),(Select AddrName From #Strng_Splt Where Id=3),(Select AddrName From #Strng_Splt Where Id=4),(Select AddrName From #Strng_Splt Where Id=5),(Select AddrName From #Strng_Splt Where Id=6),(Select AddrName From #Strng_Splt Where Id=5),(Select AddrName From #Strng_Splt Where Id=5),
								  (SELECT EntityMobile FROM ImportWFContacts WHERE Name=@ContactName  and id=@id and ClientRefNumber=@MasterId and TransactionId=@TransactionId),
								  (SELECT EntityEmail FROM ImportWFContacts WHERE Name=@ContactName  and id=@id and ClientRefNumber=@MasterId and TransactionId=@TransactionId),'System',getutcdate(),@ClientNewId,1 )
						
						        Insert Into Common.Addresses (Id,AddSectionType,AddType,AddTypeId,AddTypeIdInt,AddressBookId,CompanyId,DocumentId,EntityId,CopyId)
						
						       Values(NEWID(),'Registered Address','ClientContactDetailId',@ContactIdDeatialNewId,null,@New_Frn_AddressBookId,@CompanyId,@ClientNewId,Null,Null)
						       Truncate Table #Strng_Splt
					      End
					
					     If @EntyForigenAddress Is Not Null  ---EntyLocalAddress in Common.Contactdetail table
					          Begin
						      Set @New_Frn_AddressBookId=NewId()
						       Insert Into #Strng_Splt(AddrName)
						       Select Value From string_split(@EntyForigenAddress,',')

						       Insert Into Common.AddressBook (Id,IsLocal, Street, UnitNo, City, State,Country,PostalCode,Phone,Email,UserCreated,CreatedDate,DocumentId,RecOrder)
							
								Values(@New_Frn_AddressBookId,0,(Select AddrName From #Strng_Splt Where Id=1),(Select AddrName From #Strng_Splt Where Id=2),(Select AddrName From #Strng_Splt Where Id=3),(Select AddrName From #Strng_Splt Where Id=4),(Select AddrName From #Strng_Splt Where Id=5),(Select AddrName From #Strng_Splt Where Id=6),
								
								(SELECT EntityMobile FROM ImportWFContacts WHERE Name=@ContactName  and id=@id and ClientRefNumber=@MasterId and TransactionId=@TransactionId),
								(SELECT EntityEmail FROM ImportWFContacts WHERE Name=@ContactName  and id=@id and ClientRefNumber=@MasterId and TransactionId=@TransactionId),'System',getutcdate(),@ClientNewId,2 )
						
								Insert Into Common.Addresses (Id,AddSectionType,AddType,AddTypeId,AddTypeIdInt,AddressBookId,CompanyId,DocumentId,EntityId,CopyId)
						
								Values(NEWID(),'Office Address','ClientContactDetailId',@ContactIdDeatialNewId,null,@New_Frn_AddressBookId,@CompanyId,@ClientNewId,null,null)
								Truncate Table #Strng_Splt
					    End
						End

						--====================================================================
						
							  
							  
							 --   ELSE  
								--BEGIN 
			 				--	UPDATE  ImportWFContacts set ErrorRemarks='ContactName Already Exists Please entered the correct information.'  where Name=@ContactName and id=@id and ClientRefNumber=@MasterId and TransactionId=@TransactionId
			 				--	UPDATE  ImportWFContacts set ImportStatus=0  where Name=@ContactName and id=@id and ClientRefNumber=@MasterId and TransactionId=@TransactionId
								--End 

                          END
						  END
						  --      ELSE 
								--BEGIN 
			 				--	UPDATE  ImportWFContacts set ErrorRemarks='Clientid Already Exists Please entered the correct information.'  where Name=@ContactName  and id=@id and ClientRefNumber=@MasterId and TransactionId=@TransactionId
			 				--	UPDATE  ImportWFContacts set ImportStatus=0  where Name=@ContactName  and id=@id and ClientRefNumber=@MasterId and TransactionId=@TransactionId
								--End 
         
		              --================================================================================03.12.2019
                    COMMIT TRANSACTION;
                    END TRY
                    BEGIN CATCH
                    Declare @ErrorMessage Nvarchar(4000)=error_message();
                    ROLLBACK;
                    If @ErrorMessage is not null
	                begin 

		            UPDATE  ImportWFClient set ErrorRemarks='please check Contact '   where ClientRefNumber=@MasterId and TransactionId=@TransactionId 
		            UPDATE  ImportWFClient set ImportStatus=0  where ClientRefNumber=@MasterId and TransactionId=@TransactionId 
					UPDATE  ImportWFContacts set ErrorRemarks=@ErrorMessage   where Name=@ContactName  and id=@id and ClientRefNumber=@MasterId and TransactionId=@TransactionId
			 		UPDATE  ImportWFContacts set ImportStatus=0   where Name=@ContactName  and id=@id and ClientRefNumber=@MasterId and TransactionId=@TransactionId
	                
					 declare @FailedCount int = (Select Count(*) from ImportWFClient Where TransactionId=@TransactionId and ImportStatus=0)
                     Update Common.[Transaction] Set TotalRecords=(Select Count(*) from ImportWFClient Where TransactionId=@TransactionId ),
                     FailedRecords=  (Case When @FailedCount>0 then @FailedCount else 0 end)   where Id=@TransactionId

					  End 
                      END CATCH
		  --================================================================================03.12.2019
		             
	fetch next from ContactId_Get Into @id,@ContactName,@IdType,@IdNumber,@MasterId
	End
	Close ContactId_Get
	Deallocate ContactId_Get
	Drop Table #Strng_Splt
	----------------------------
	--	  COMMIT TRANSACTION;
 --     END TRY
 --     BEGIN CATCH
	--  Declare @ErrorMessage Nvarchar(4000)
	--  ROLLBACK;
	--  Select @ErrorMessage=error_message();
	--  Raiserror(@ErrorMessage,16,1);
 --     END CATCH
	--  --------------------------------

		
	End



Update  hh set IsPrimaryContact=case when Rank=1 then 1 else 0 end from 
   --select id,ContactId,EntityId,IsPrimaryContact,CreatedDate,Rank, case when Rank=1 then 1 else 0 end as Isprimary  from
(
 select  id,ContactId,EntityId,IsPrimaryContact,CreatedDate ,
 RANK()over(partition by EntityId order by CreatedDate desc) as 'Rank'
 from Common.ContactDetails where  CreatedDate Is not null And EntityId Is not null and  EntityType='Client' and IsPrimaryContact=1  and
 ContactId in ( select DISTINCT   id from Common.Contact where CompanyId=@companyId  AND 
 FirstName COLLATE DATABASE_DEFAULT IN (select DISTINCT Name from ImportWFContacts C where TransactionId=@TransactionId  ))
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
Select Count(*) As Cnt,EntityId From Common.ContactDetails  where  CreatedDate Is not null And EntityId Is not null and  EntityType='Client'  AND 
 ContactId in ( select DISTINCT   id from Common.Contact where CompanyId=@companyId  AND 
 FirstName COLLATE DATABASE_DEFAULT IN (select DISTINCT Name from ImportWFContacts C where TransactionId=@TransactionId  ))
 Group By EntityId 
) As A
Inner Join 
(
Select Count(*) As Cnt,EntityId From Common.ContactDetails  where  CreatedDate Is not null And EntityId Is not null and  EntityType='Client' and  IsPrimaryContact=0 AND 
 ContactId in ( select DISTINCT   id from Common.Contact where CompanyId=@companyId  AND 
 FirstName COLLATE DATABASE_DEFAULT IN (select DISTINCT Name from ImportWFContacts C where TransactionId=@TransactionId  ))
 Group By EntityId 

) As B On A.EntityId =B.EntityId And A.Cnt =B.Cnt
)
) HH 



   Begin
   Exec [dbo].[Import_Client_To_Account_Entity] @companyId  -------- SYC   client to Account_Entity
   End

   	  
   Begin
 update c set c.BlockHouseNo='', c.BuildingEstate=''  from  Common.AddressBook c
 inner join Common.Addresses a on a.AddressBookId=c.Id
 where a.CompanyId=@companyId 
  and c.BlockHouseNo is null and  c.BuildingEstate is null
 

   End























GO
