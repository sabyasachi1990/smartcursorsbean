USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[Import_Bean_ContactsDetail_Validation]    Script Date: 16-12-2024 9.20.10 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO






CREATE Procedure  [dbo].[Import_Bean_ContactsDetail_Validation]    
 --exec [dbo].[Import_Bean_ContactsDetail_Validation]   727,'8F0519E9-1C4B-40A8-B29E-8F181C3A02E4' 
@companyId int,
@TransactionId uniqueidentifier


AS
BEGIN
DECLARE 
-- @companyId int=237,
--@TransactionId uniqueidentifier='D643FC9E-CDA9-4FFE-8AAE-61C995279288',
@EntityId Uniqueidentifier,
@ContactId Uniqueidentifier,
@ContactIdDeatialId Uniqueidentifier,
@EntityName NVARCHAR(MAX),
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
 @IdTypeid Nvarchar(max),
 @EntityNewId Uniqueidentifier,
 @EntityNewName Nvarchar(max),
 @ContactNewId Uniqueidentifier,
 @ContactIdDeatialNewId Uniqueidentifier,
 @EntityIduni Uniqueidentifier

      --Begin Transaction  
      --Begin Try



	  ---=========Creating Local temporary Tables  for addresss 
Create Table #Strng_Splt (Id Int Identity(1,1),AddrName Nvarchar(Max))
Declare ContactId_Get Cursor For
--------============== Import Contacts not in Common.Contact table --===============================
select Id,Name as ContactName,IdentificationType,IdentificationNumber,EntityName from ImportBeanContacts where TransactionId=@TransactionId AND ( ImportStatus<>0 oR  ImportStatus IS NULL)  	 ---and  id not in (select DISTINCT   Id from Common.Contact where CompanyId=@companyId)
		Open ContactId_Get
		fetch next from ContactId_Get Into @id,@ContactName,@IdType,@IdNumber,@EntityName
		While @@FETCH_STATUS=0
		Begin

		 --===================== 03.12.2019
		 
         Begin Transaction  
         Begin Try  
		 --==================== 03.12.2019






		set @IdTypeid = (SELECT id FROM Common.IdType WHERE Name = @IdType AND CompanyId = @companyId)
         If Exists (Select Id from  bean.entity Where Name=@EntityName and  CompanyId=@companyId) ---===Check AccountId  in ClientCursor.Account table
		    Begin
		     If Not Exists (Select Id from  Common.Contact Where  FirstName=@ContactName and  case when  IdType is null  then 'xxx' else IdType end   =  case when  @IdTypeID is null  then 'xxx' else @IdTypeID end  and  case when  IdNo is null  then 'xxx' else IdNo end = case when  @IdNumber is null  then 'xxx' else @IdNumber end  and  CompanyId=@companyId ) ---===Check ContactName  in Common.Contact table
		       Begin
			      --If Not Exists (Select Id from  Common.Contact Where  IdType=@IdType and  CompanyId=@companyId ) ---===Check IdType  in Common.Contact table
		       --     Begin
			      --    If Not Exists (Select Id from  Common.Contact Where  IdNo=@IdNumber and  CompanyId=@companyId ) ---===Check IdNumber  in Common.Contact table
		       --        Begin

			  ----============== set AccountId,PerEmailJson,PerMobileJson,EntEmailJson,EntMobileJson For Json Auto
                    SET @ContactIdDeatialId=NewId()
					set @ContactId=NewId()
					Set @EntityIduni =(Select top 1 Id from  ImportEntities Where EntityName=@EntityName and  TransactionId=@TransactionId)
					Set @EntityId =(Select Id from  bean.entity Where Name=@EntityName and  CompanyId=@companyId)
	                Set @PerEmailJson =(Select 'Email' As 'key',PersonalEmail As 'value' From ImportBeanContacts Where Name=@ContactName  and id=@id and EntityName=@EntityName and PersonalEmail is not null and TransactionId=@TransactionId For Json Auto)

					Set @PerMobileJson =(Select 'Mobile' As 'key',PersonalPhone As 'value' From ImportBeanContacts Where Name=@ContactName  and id=@id and EntityName=@EntityName and PersonalPhone is not null and TransactionId=@TransactionId For Json Auto)

					Set @EntEmailJson =(Select 'Email' As 'key',EntityEmail As 'value' From ImportBeanContacts Where Name=@ContactName  and id=@id and EntityName=@EntityName and EntityEmail is not null and TransactionId=@TransactionId For Json Auto)

					Set @EntMobileJson =(Select 'Mobile' As 'key',EntityPhone As 'value' From ImportBeanContacts Where Name=@ContactName  and id=@id and EntityName=@EntityName and EntityPhone is not null and TransactionId=@TransactionId For Json Auto)
				
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

					   Select @ContactId as Id,Salutation,C.Name as 'FirstName',CONVERT(datetime, DateofBirth, 103) as DOB,@IdTypeid as IdType,
					   C.IdentificationNumber as IdNo,CountryOfResidence, 1 as RecOrder,Remarks,'System' as UserCreated,GETUTCDATE() as CreatedDate,
					  1 as 'Status',@PerJsondata as 'Communication',@companyid
					   from ImportBeanContacts C
					   Where Name=@ContactName  and id=@id and EntityName=@EntityName  and TransactionId=@TransactionId AND (ImportStatus<>0 or ImportStatus is null)


						----========================================  insert into Contact Deatils table

					   INSERT INTO Common.ContactDetails (Id,	ContactId,	EntityId,	EntityType,	Designation,	
					   Communication,	IsPrimaryContact,RecOrder,CursorShortCode	,Status,	IsCopy,	UserCreated,	CreatedDate,	Remarks)

					  Select  @ContactIdDeatialId,@ContactId as ContactId,@EntityId AS EntityId,'Entity' as 'EntityType',Designation,
					  @EntJsondata as 'Communication', PrimaryContacts as IsPrimaryContact,
					   1 RecOredr,   'Bean' as 'CursorShortCode',1 as 'Status',
					  copycommunicationandAddress as IsCopy,'System' as UserCreated,GETUTCDATE() as CreatedDate,Remarks
					  from ImportBeanContacts C
					  Where Name=@ContactName and id=@id and EntityName=@EntityName and TransactionId=@TransactionId AND (ImportStatus<>0 or ImportStatus is null)

						UPDATE  ImportBeanContacts set ErrorRemarks=null  where Name=@ContactName  and id=@id and EntityName=@EntityName and TransactionId=@TransactionId
			 			UPDATE  ImportBeanContacts set ImportStatus=1  where Name=@ContactName  and id=@id and EntityName=@EntityName and TransactionId=@TransactionId

					    -------------------- addressbook and address  in ClientCursor.Account table
                        
						  Select @LocalAddress=LocalAddress,@ForigenAddress=Foreignaddress
	                      From ImportEntities
	                      Where  EntityName=@EntityName and TransactionId=@TransactionId and id=@EntityIduni
						
					  ----------------------PerLocalAddress and EntyLocalAddress in  ClientCursor.Account table
					  If Not Exists (Select Id from Common.Addresses Where AddTypeId=@entityid and  CompanyId=@companyId ) --== check AccountId in  Common.Addresses table
		          Begin

					   If @LocalAddress Is Not Null  ---------- LocalAddress in  ClientCursor.Account table
					         Begin
						     Set @New_Loc_AddressBookId =NewId()
						
						     Insert Into #Strng_Splt(AddrName)
						     Select Value From string_split(@LocalAddress,',')

						     Insert Into Common.AddressBook (Id,IsLocal,BlockHouseNo,Street,UnitNo,BuildingEstate,City,PostalCode,State,Country,Phone,Email,UserCreated,CreatedDate,DocumentId,RecOrder)
						
							 Values(@New_Loc_AddressBookId,1,(Select AddrName From #Strng_Splt Where Id=1),(Select AddrName From #Strng_Splt Where Id=2),(Select AddrName From #Strng_Splt Where Id=3),(Select AddrName From #Strng_Splt Where Id=4),(Select AddrName From #Strng_Splt Where Id=5),(Select AddrName From #Strng_Splt Where Id=6),(Select AddrName From #Strng_Splt Where Id=5),(Select AddrName From #Strng_Splt Where Id=5),
							(SELECT Phone   FROM ImportEntities WHERE  EntityName=@EntityName and TransactionId=@TransactionId  and id=@EntityIduni),
							(SELECT Email   FROM ImportEntities WHERE   EntityName=@EntityName and TransactionId=@TransactionId  and id=@EntityIduni),'System',GETUTCDATE(),@entityid,1  )
							
							Truncate Table #Strng_Splt

							Insert Into Common.Addresses (Id,AddSectionType,AddType,AddTypeId,AddTypeIdInt,AddressBookId,CompanyId,DocumentId,EntityId,CopyId)
						
							Values(NEWID(),'Registered Address','Entity',@entityid,null,@New_Loc_AddressBookId,@CompanyId,@entityid,Null,Null)
					    End
						If @ForigenAddress Is Not Null ---------- ForigenAddress in  ClientCursor.Account table
								  Begin
								  Set @New_Frn_AddressBookId=NewId()
								  Insert Into #Strng_Splt(AddrName)
								  Select Value From string_split(@ForigenAddress,',')

								  Insert Into Common.AddressBook (Id,IsLocal, Street, UnitNo, City, State, Country,PostalCode,Phone,Email,UserCreated,CreatedDate,DocumentId,RecOrder)
							
								  Values(@New_Frn_AddressBookId,0,(Select AddrName From #Strng_Splt Where Id=1),(Select AddrName From #Strng_Splt Where Id=2),(Select AddrName From #Strng_Splt Where Id=3),(Select AddrName From #Strng_Splt Where Id=4),(Select AddrName From #Strng_Splt Where Id=5),(Select AddrName From #Strng_Splt Where Id=6),
								  
								  (SELECT Phone   FROM ImportEntities WHERE  EntityName=@EntityName and TransactionId=@TransactionId  and id=@EntityIduni),
								  (SELECT Email   FROM ImportEntities WHERE  EntityName=@EntityName and TransactionId=@TransactionId  and id=@EntityIduni),'System',GETUTCDATE(),@entityid,2 )
						
						        Insert Into Common.Addresses (Id,AddSectionType,AddType,AddTypeId,AddTypeIdInt,AddressBookId,CompanyId,DocumentId,EntityId,CopyId)
						
						       Values(NEWID(),'Mailing Address','Entity',@entityid,null,@New_Frn_AddressBookId,@CompanyId,@entityid,Null,Null)
						       Truncate Table #Strng_Splt
					      End
						  END
					  -------------------- addressbook and address -- contact and contactdetail in Common.Contact table
                        
						  Select @PerLocalAddress=PersonalLocalAddress,@EntyLocalAddress=EntityLocalAddress,
						  @PerForigenAddress=PersonalForeignAddress,@EntyForigenAddress=EntityForeignAddress
						  From ImportBeanContacts 
	                      Where Name=@ContactName  and id=@id and EntityName=@EntityName and TransactionId=@TransactionId
						  ----------------------PerLocalAddress and EntyLocalAddress
					   If @PerLocalAddress Is Not Null ---PerLocalAddress in Common.Contact table
					         Begin
						     Set @New_Loc_AddressBookId =NewId()
						
						     Insert Into #Strng_Splt(AddrName)
						     Select Value From string_split(@PerLocalAddress,',')

						     Insert Into Common.AddressBook (Id,IsLocal,BlockHouseNo,Street,UnitNo,BuildingEstate,City,PostalCode,State,Country,Phone,Email,UserCreated,CreatedDate,DocumentId,RecOrder)
						
							 Values(@New_Loc_AddressBookId,1,(Select AddrName From #Strng_Splt Where Id=1),(Select AddrName From #Strng_Splt Where Id=2),(Select AddrName From #Strng_Splt Where Id=3),(Select AddrName From #Strng_Splt Where Id=4),(Select AddrName From #Strng_Splt Where Id=5),(Select AddrName From #Strng_Splt Where Id=6),(Select AddrName From #Strng_Splt Where Id=5),(Select AddrName From #Strng_Splt Where Id=5),
							(SELECT PersonalPhone   FROM ImportBeanContacts WHERE Name=@ContactName  and id=@id and EntityName=@EntityName and TransactionId=@TransactionId),
							(SELECT PersonalEmail   FROM ImportBeanContacts WHERE Name=@ContactName  and id=@id and EntityName=@EntityName and TransactionId=@TransactionId),'System',GETUTCDATE(),@entityid,1  )
							Truncate Table #Strng_Splt

							Insert Into Common.Addresses (Id,AddSectionType,AddType,AddTypeId,AddTypeIdInt,AddressBookId,CompanyId,DocumentId,EntityId,CopyId)
						
							Values(NEWID(),'Registered Address','Contact',@ContactId,null,@New_Loc_AddressBookId,@CompanyId,@entityid,Null,Null)
					    End
						If @EntyLocalAddress Is Not Null ---EntyLocalAddress in Common.Contactdetail table
								  Begin
								  Set @New_Frn_AddressBookId=NewId()
								  Insert Into #Strng_Splt(AddrName)
								  Select Value From string_split(@EntyLocalAddress,',')

								  Insert Into Common.AddressBook (Id,IsLocal,BlockHouseNo,Street,UnitNo,BuildingEstate,City,PostalCode,State,Country,Phone,Email,UserCreated,CreatedDate,DocumentId,RecOrder)
							
								  Values(@New_Frn_AddressBookId,1,(Select AddrName From #Strng_Splt Where Id=1),(Select AddrName From #Strng_Splt Where Id=2),(Select AddrName From #Strng_Splt Where Id=3),(Select AddrName From #Strng_Splt Where Id=4),(Select AddrName From #Strng_Splt Where Id=5),(Select AddrName From #Strng_Splt Where Id=6),(Select AddrName From #Strng_Splt Where Id=5),(Select AddrName From #Strng_Splt Where Id=5),
								  (SELECT EntityPhone FROM ImportBeanContacts WHERE Name=@ContactName and IdentificationType=@IdType and id=@id  and EntityName=@EntityName and TransactionId=@TransactionId),
								  (SELECT EntityEmail FROM ImportBeanContacts WHERE Name=@ContactName and IdentificationType=@IdType and id=@id and EntityName=@EntityName and TransactionId=@TransactionId),'System',GETUTCDATE(),@entityid,1 )
						
						        Insert Into Common.Addresses (Id,AddSectionType,AddType,AddTypeId,AddTypeIdInt,AddressBookId,CompanyId,DocumentId,EntityId,CopyId)
						
						       Values(NEWID(),'Registered Address','EntityContactDetailId',@ContactIdDeatialId,null,@New_Frn_AddressBookId,@CompanyId,@entityid,Null,Null)
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
							
								(SELECT PersonalPhone   FROM ImportBeanContacts WHERE Name=@ContactName and IdentificationType=@IdType and id=@id and EntityName=@EntityName and TransactionId=@TransactionId),
								(SELECT PersonalEmail   FROM ImportBeanContacts WHERE Name=@ContactName and IdentificationType=@IdType and id=@id and EntityName=@EntityName and TransactionId=@TransactionId),'System',GETUTCDATE(),@entityid,2)
								Truncate Table #Strng_Splt

						        Insert Into Common.Addresses (Id,AddSectionType,AddType,AddTypeId,AddTypeIdInt,AddressBookId,CompanyId,DocumentId,EntityId,CopyId)
						
						       Values(NEWID(),'Office Address','Contact',@ContactId,null,@New_Loc_AddressBookId,@CompanyId,@entityid,null,null)
					      End
					     If @EntyForigenAddress Is Not Null  ---EntyLocalAddress in Common.Contactdetail table
					          Begin
						      Set @New_Frn_AddressBookId=NewId()
						       Insert Into #Strng_Splt(AddrName)
						       Select Value From string_split(@EntyForigenAddress,',')

						       Insert Into Common.AddressBook (Id,IsLocal, Street, UnitNo, City, State, Country,PostalCode,Phone,Email,UserCreated,CreatedDate,DocumentId,RecOrder)
							
								Values(@New_Frn_AddressBookId,0,(Select AddrName From #Strng_Splt Where Id=1),(Select AddrName From #Strng_Splt Where Id=2),(Select AddrName From #Strng_Splt Where Id=3),(Select AddrName From #Strng_Splt Where Id=4),(Select AddrName From #Strng_Splt Where Id=5),(Select AddrName From #Strng_Splt Where Id=6),
						
								(SELECT EntityPhone FROM ImportBeanContacts WHERE Name=@ContactName and IdentificationType=@IdType and id=@id and EntityName=@EntityName and TransactionId=@TransactionId),
								(SELECT EntityEmail FROM ImportBeanContacts WHERE Name=@ContactName and IdentificationType=@IdType and id=@id and EntityName=@EntityName and TransactionId=@TransactionId ),'System',GETUTCDATE(),@entityid,2 )
						
								Insert Into Common.Addresses (Id,AddSectionType,AddType,AddTypeId,AddTypeIdInt,AddressBookId,CompanyId,DocumentId,EntityId,CopyId)
						
								Values(NEWID(),'Office Address','EntityContactDetailId',@ContactIdDeatialId,null,@New_Frn_AddressBookId,@CompanyId,@entityid,null,null)
								Truncate Table #Strng_Splt
					    End
						end
			--------===========================
			 ELSE 
					 If Exists (Select  Id from  Bean.Entity Where Name=@EntityName and  CompanyId=@companyId) ---===Check AccountId  in ClientCursor.Account table
		              Begin

		               SET @EntityNewId =(Select  Id from  Bean.Entity Where Name=@EntityName and  CompanyId=@companyId)
		               SET @EntityNewName =(Select  Name from  Bean.Entity Where Name=@EntityName and  CompanyId=@companyId)
	                   SET @ContactNewId=(Select  Id from  Common.Contact Where  FirstName=@ContactName and  case when  IdType is null  then 'xxx' else IdType end   =  case when  @IdTypeID is null  then 'xxx' else @IdTypeID end  and  case when  IdNo is null  then 'xxx' else IdNo end = case when  @IdNumber is null  then 'xxx' else @IdNumber end  and  CompanyId=@companyId )

                  If Not Exists (Select Distinct Id from  Common.ContactDetails Where ContactId=@ContactNewId  AND EntityId=@EntityNewId) ---===Check ContactName  in Common.Contact table
		           Begin
						
						SET @ContactIdDeatialNewId=NewId()
					Set @PerEmailJson =(Select 'Email' As 'key',PersonalEmail As 'value' From ImportBeanContacts Where Name=@ContactName  and id=@id and EntityName=@EntityNewName and PersonalEmail is not null and TransactionId=@TransactionId For Json Auto)

					Set @PerMobileJson =(Select 'Mobile' As 'key',PersonalPhone As 'value' From ImportBeanContacts Where Name=@ContactName  and id=@id and EntityName=@EntityNewName and PersonalPhone is not null and TransactionId=@TransactionId For Json Auto)

					Set @EntEmailJson =(Select 'Email' As 'key',EntityEmail As 'value' From ImportBeanContacts Where Name=@ContactName  and id=@id and EntityName=@EntityNewName and EntityEmail is not null and TransactionId=@TransactionId For Json Auto)

					Set @EntMobileJson =(Select 'Mobile' As 'key',EntityPhone As 'value' From ImportBeanContacts Where Name=@ContactName  and id=@id and EntityName=@EntityNewName and EntityPhone is not null and TransactionId=@TransactionId For Json Auto)
				
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
					   Communication,	IsPrimaryContact,RecOrder,CursorShortCode	,Status,	IsCopy,	UserCreated,	CreatedDate,	Remarks)

					  Select  @ContactIdDeatialNewId,@ContactNewId as ContactId,@EntityNewId AS EntityId,'Entity' as 'EntityType',Designation,
					  @EntJsondata as 'Communication', PrimaryContacts as IsPrimaryContact,
					   1 RecOredr,   'Bean' as 'CursorShortCode', 1 as 'Status',
					  copycommunicationandAddress as IsCopy,'System' as UserCreated,GETUTCDATE() as CreatedDate,Remarks
					  from ImportBeanContacts C
					  Where Name=@ContactName and id=@id and EntityName=@EntityNewName and TransactionId=@TransactionId AND (ImportStatus<>0 or ImportStatus is null)

						UPDATE  ImportBeanContacts set ErrorRemarks=null  where Name=@ContactName  and id=@id and EntityName=@EntityNewName and TransactionId=@TransactionId
			 			UPDATE  ImportBeanContacts set ImportStatus=1  where Name=@ContactName  and id=@id and EntityName=@EntityNewName and TransactionId=@TransactionId

					    -------------------- addressbook and address  in ClientCursor.Account table
                        
						  Select @LocalAddress=LocalAddress,@ForigenAddress=Foreignaddress
	                      From ImportEntities
	                      Where  EntityName=@EntityNewName and TransactionId=@TransactionId
						
					  ----------------------PerLocalAddress and EntyLocalAddress in  ClientCursor.Account table
					  If Not Exists (Select Id from Common.Addresses Where AddTypeId=@EntityNewId and  CompanyId=@companyId ) --== check AccountId in  Common.Addresses table
		          Begin

					   If @LocalAddress Is Not Null  ---------- LocalAddress in  ClientCursor.Account table
					         Begin
						     Set @New_Loc_AddressBookId =NewId()
						
						     Insert Into #Strng_Splt(AddrName)
						     Select Value From string_split(@LocalAddress,',')

						     Insert Into Common.AddressBook (Id,IsLocal,BlockHouseNo,Street,UnitNo,BuildingEstate,City,PostalCode,State,Country,Phone,Email,UserCreated,CreatedDate,DocumentId,RecOrder)
						
							 Values(@New_Loc_AddressBookId,1,(Select AddrName From #Strng_Splt Where Id=1),(Select AddrName From #Strng_Splt Where Id=2),(Select AddrName From #Strng_Splt Where Id=3),(Select AddrName From #Strng_Splt Where Id=4),(Select AddrName From #Strng_Splt Where Id=5),(Select AddrName From #Strng_Splt Where Id=6),(Select AddrName From #Strng_Splt Where Id=5),(Select AddrName From #Strng_Splt Where Id=5),
							(SELECT Phone   FROM ImportEntities WHERE  EntityName=@EntityNewName and TransactionId=@TransactionId),
							(SELECT Email   FROM ImportEntities WHERE   EntityName=@EntityNewName and TransactionId=@TransactionId),'System',GETUTCDATE(),@EntityNewId,1  )
							
							Truncate Table #Strng_Splt

							Insert Into Common.Addresses (Id,AddSectionType,AddType,AddTypeId,AddTypeIdInt,AddressBookId,CompanyId,DocumentId,EntityId,CopyId)
						
							Values(NEWID(),'Registered Address','Entity',@EntityNewId,null,@New_Loc_AddressBookId,@CompanyId,@EntityNewId,Null,Null)
					    End
						If @ForigenAddress Is Not Null ---------- ForigenAddress in  ClientCursor.Account table
								  Begin
								  Set @New_Frn_AddressBookId=NewId()
								  Insert Into #Strng_Splt(AddrName)
								  Select Value From string_split(@ForigenAddress,',')

								  Insert Into Common.AddressBook (Id,IsLocal, Street, UnitNo, City, State, Country,PostalCode,Phone,Email,UserCreated,CreatedDate,DocumentId,RecOrder)
							
								  Values(@New_Frn_AddressBookId,0,(Select AddrName From #Strng_Splt Where Id=1),(Select AddrName From #Strng_Splt Where Id=2),(Select AddrName From #Strng_Splt Where Id=3),(Select AddrName From #Strng_Splt Where Id=4),(Select AddrName From #Strng_Splt Where Id=5),(Select AddrName From #Strng_Splt Where Id=6),
								
								  (SELECT Phone   FROM ImportEntities WHERE  EntityName=@EntityNewName and TransactionId=@TransactionId),
								  (SELECT Email   FROM ImportEntities WHERE  EntityName=@EntityNewName and TransactionId=@TransactionId),'System',GETUTCDATE(),@EntityNewId,2 )
						
						        Insert Into Common.Addresses (Id,AddSectionType,AddType,AddTypeId,AddTypeIdInt,AddressBookId,CompanyId,DocumentId,EntityId,CopyId)
						
						       Values(NEWID(),'Mailing Address','Entity',@EntityNewId,null,@New_Frn_AddressBookId,@CompanyId,@EntityNewId,Null,Null)
						       Truncate Table #Strng_Splt
					      End
						  END
					  -------------------- addressbook and address -- contact and contactdetail in Common.Contact table
                        
						  Select @PerLocalAddress=PersonalLocalAddress,@EntyLocalAddress=EntityLocalAddress,
						  @PerForigenAddress=PersonalForeignAddress,@EntyForigenAddress=EntityForeignAddress
						  From ImportBeanContacts 
	                      Where Name=@ContactName  and id=@id and EntityName=@EntityNewName and TransactionId=@TransactionId

						If @EntyLocalAddress Is Not Null ---EntyLocalAddress in Common.Contactdetail table
								  Begin
								  Set @New_Frn_AddressBookId=NewId()
								  Insert Into #Strng_Splt(AddrName)
								  Select Value From string_split(@EntyLocalAddress,',')

								  Insert Into Common.AddressBook (Id,IsLocal,BlockHouseNo,Street,UnitNo,BuildingEstate,City,PostalCode,State,Country,Phone,Email,UserCreated,CreatedDate,DocumentId,RecOrder)
							
								  Values(@New_Frn_AddressBookId,1,(Select AddrName From #Strng_Splt Where Id=1),(Select AddrName From #Strng_Splt Where Id=2),(Select AddrName From #Strng_Splt Where Id=3),(Select AddrName From #Strng_Splt Where Id=4),(Select AddrName From #Strng_Splt Where Id=5),(Select AddrName From #Strng_Splt Where Id=6),(Select AddrName From #Strng_Splt Where Id=5),(Select AddrName From #Strng_Splt Where Id=5),
								  (SELECT EntityPhone FROM ImportBeanContacts WHERE Name=@ContactName and IdentificationType=@IdType and id=@id  and EntityName=@EntityName and TransactionId=@TransactionId),
								  (SELECT EntityEmail FROM ImportBeanContacts WHERE Name=@ContactName and IdentificationType=@IdType and id=@id and EntityName=@EntityName and TransactionId=@TransactionId),'System',GETUTCDATE(),@EntityNewId,1 )
						
						        Insert Into Common.Addresses (Id,AddSectionType,AddType,AddTypeId,AddTypeIdInt,AddressBookId,CompanyId,DocumentId,EntityId,CopyId)
						
						       Values(NEWID(),'Registered Address','EntityContactDetailId',@ContactIdDeatialNewId,null,@New_Frn_AddressBookId,@CompanyId,@EntityNewId,Null,Null)
						       Truncate Table #Strng_Splt
					      End
						
					     If @EntyForigenAddress Is Not Null  ---EntyLocalAddress in Common.Contactdetail table
					          Begin
						      Set @New_Frn_AddressBookId=NewId()
						       Insert Into #Strng_Splt(AddrName)
						       Select Value From string_split(@EntyForigenAddress,',')

						       Insert Into Common.AddressBook (Id,IsLocal, Street, UnitNo, City, State, Country,PostalCode,Phone,Email,UserCreated,CreatedDate,DocumentId,RecOrder)
							
								Values(@New_Frn_AddressBookId,0,(Select AddrName From #Strng_Splt Where Id=1),(Select AddrName From #Strng_Splt Where Id=2),(Select AddrName From #Strng_Splt Where Id=3),(Select AddrName From #Strng_Splt Where Id=4),(Select AddrName From #Strng_Splt Where Id=5),(Select AddrName From #Strng_Splt Where Id=6),
					
								(SELECT EntityPhone FROM ImportBeanContacts WHERE Name=@ContactName and IdentificationType=@IdType and id=@id and EntityName=@EntityName and TransactionId=@TransactionId),
								(SELECT EntityEmail FROM ImportBeanContacts WHERE Name=@ContactName and IdentificationType=@IdType and id=@id and EntityName=@EntityName and TransactionId=@TransactionId ),'System',GETUTCDATE(),@EntityNewId,2 )
						
								Insert Into Common.Addresses (Id,AddSectionType,AddType,AddTypeId,AddTypeIdInt,AddressBookId,CompanyId,DocumentId,EntityId,CopyId)
						
								Values(NEWID(),'Office Address','EntityContactDetailId',@ContactIdDeatialNewId,null,@New_Frn_AddressBookId,@CompanyId,@EntityNewId,null,null)
								Truncate Table #Strng_Splt
					    End
						end

			--========================
							  
							  
							 -- ELSE  
								--BEGIN 
			 				--	UPDATE  ImportBeanContacts set ErrorRemarks='ContactName Already Exists Please entered the correct information.'  where Name=@ContactName and id=@id and EntityName=@EntityName and TransactionId=@TransactionId
			 				--	UPDATE  ImportBeanContacts set ImportStatus=0  where Name=@ContactName  and id=@id and EntityName=@EntityName and TransactionId=@TransactionId
								--End 
								end

                         End
						  --ELSE 
								--BEGIN 
			 				--	UPDATE  ImportBeanContacts set ErrorRemarks='Please enter the Entityid'  where Name=@ContactName  and id=@id and EntityName=@EntityName and TransactionId=@TransactionId
			 				--	UPDATE  ImportBeanContacts set ImportStatus=0  where Name=@ContactName  and id=@id and EntityName=@EntityName and TransactionId=@
								--end

       --================================================================================03.12.2019
                COMMIT TRANSACTION;
                END TRY
                BEGIN CATCH
                Declare @ErrorMessage Nvarchar(4000)=error_message();
                ROLLBACK;
                If @ErrorMessage is not null
	                begin 

		            UPDATE  ImportEntities set ErrorRemarks='please check Contact '   where  EntityName=@EntityName and TransactionId=@TransactionId
		            UPDATE  ImportEntities set ImportStatus=0  where  EntityName=@EntityName and TransactionId=@TransactionId
					UPDATE  ImportBeanContacts set ErrorRemarks=@ErrorMessage  where Name=@ContactName  and id=@id and EntityName=@EntityName and TransactionId=@TransactionId
			 		UPDATE  ImportBeanContacts set ImportStatus=0  where Name=@ContactName  and id=@id and EntityName=@EntityName and TransactionId=@TransactionId
	                
					 declare @FailedCount int = (Select Count(*) from ImportEntities Where TransactionId=@TransactionId and ImportStatus=0)
                     Update Common.[Transaction] Set TotalRecords=(Select Count(*) from ImportEntities Where TransactionId=@TransactionId ),
                     FailedRecords=  (Case When @FailedCount>0 then @FailedCount else 0 end)   where Id=@TransactionId

					End 
                END CATCH
		  --================================================================================03.12.2019
                     
	fetch next from ContactId_Get Into @id,@ContactName,@IdType,@IdNumber,@EntityName
	End
	Close ContactId_Get
	Deallocate ContactId_Get
	Drop Table #Strng_Splt	
	End
	
Update  hh set IsPrimaryContact=case when Rank=1 then 1 else 0 end from 
   --select id,ContactId,EntityId,IsPrimaryContact,CreatedDate,Rank, case when Rank=1 then 1 else 0 end as Isprimary  from
(
 select  id,ContactId,EntityId,IsPrimaryContact,CreatedDate ,
 RANK()over(partition by EntityId order by CreatedDate desc) as 'Rank'
 from Common.ContactDetails where  CreatedDate Is not null And EntityId Is not null and  EntityType='Entity' and IsPrimaryContact=1  and
 ContactId in ( select DISTINCT   id from Common.Contact where CompanyId=@companyId  AND 
 FirstName COLLATE DATABASE_DEFAULT IN (select DISTINCT Name from ImportBeanContacts C where TransactionId=@TransactionId  ))
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
Select Count(*) As Cnt,EntityId From Common.ContactDetails  where  CreatedDate Is not null And EntityId Is not null and  EntityType='Entity'  AND 
 ContactId in ( select DISTINCT   id from Common.Contact where CompanyId=@companyId  AND 
 FirstName COLLATE DATABASE_DEFAULT IN (select DISTINCT Name from ImportBeanContacts C where TransactionId=@TransactionId  ))
 Group By EntityId 
) As A
Inner Join 
(
Select Count(*) As Cnt,EntityId From Common.ContactDetails  where  CreatedDate Is not null And EntityId Is not null and  EntityType='Entity' and  IsPrimaryContact=0 AND 
 ContactId in ( select DISTINCT   id from Common.Contact where CompanyId=@companyId  AND 
 FirstName COLLATE DATABASE_DEFAULT IN (select DISTINCT Name from ImportBeanContacts C where TransactionId=@TransactionId  ))
 Group By EntityId 

) As B On A.EntityId =B.EntityId And A.Cnt =B.Cnt
)
) HH 



	  
   Begin
 update c set c.BlockHouseNo='', c.BuildingEstate=''  from  Common.AddressBook c
 inner join Common.Addresses a on a.AddressBookId=c.Id
 where a.CompanyId=@companyId 
  and c.BlockHouseNo is null and  c.BuildingEstate is null
 

   End


							

							 
							 



GO
