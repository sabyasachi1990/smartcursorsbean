USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[BR_Migrate_Share_Contact_SP_Devbackup]    Script Date: 16-12-2024 9.20.10 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


-- Exec dbo.[BR_Migrate_Share_Contact_SP] 1257

CREATE Procedure [dbo].[BR_Migrate_Share_Contact_SP_Devbackup] 
--Declare 
@CompanyId Bigint
As
Begin
	Declare @Count Int
	Declare @RecCount Int=1 
	Declare @ContactName Nvarchar(250)
	Declare @EntityName Nvarchar(250)
	Declare @GenContactId Uniqueidentifier
	Declare @ContactId Uniqueidentifier
	Declare @EntityId Uniqueidentifier
	Declare @RegNum Nvarchar(250)
	Declare @IdType Nvarchar(250)
	Declare @IdNo Nvarchar(250)
	Declare @PerEmailJson  Nvarchar(max)
	Declare @PerMobileJson  Nvarchar(max)
	Declare @PerJsondata  Nvarchar(max)
	Declare @AddressbookId Uniqueidentifier
	Declare @UserCreated Nvarchar(25)='System'
	Declare @CraetedDate Datetime2=GETDATE()
	Declare @Category Nvarchar(250)
	Declare @SharehldrPostition Nvarchar(20)='Shareholder'
	Declare @Err_Msg Nvarchar(Max)
	Declare @IsRegistrableController Bit
	Declare @Notes nvarchar(1000)
	Declare @DateofEntry datetime
	Declare @Dateofbeacoming Datetime
	Declare @PlaceofIncorporation Nvarchar(500)
	Declare @UEN Nvarchar(500)
	Declare @Temp_Tbl Table(S_No Int Identity(1,1),ContactName Nvarchar(200),EntityName Nvarchar(200),RegNo Nvarchar(250),IdType Nvarchar(250),IdNo Nvarchar(250),Category Nvarchar(250),UEN Nvarchar(250),PlaceOfIncorporation Nvarchar(500),IsRegistrableController NVarchar(510), Notes nvarchar(1000),DateofEntry datetime,Dateofbeacoming Datetime)
Begin Transaction
Begin Try
	Insert Into @Temp_Tbl (ContactName,EntityName,RegNo,IdType,IdNo,Category,UEN,PlaceOfIncorporation,IsRegistrableController,Notes,DateofEntry,Dateofbeacoming)
	Select Distinct Name As ContactName,[Entity Name],[Registration No],[ID Type],[Id No],Category,UEN,[Place of Incorporation],[Registrable Controller (Yes/No)],Notes,[Date of Entry],[Date of becoming] From dbo.[share_contact_New_Devbackup]

	Select @Count=Count(*) From @Temp_Tbl
	While @Count>=@RecCount
	Begin
		Select @EntityName=EntityName,@ContactName=ContactName,@RegNum=RegNo,@IdType=IdType,@IdNo=IdNo,@Category=Category,@IsRegistrableController=(Case When IsRegistrableController='YES' Then 1 Else 0 End),@Notes=Notes,@DateofEntry=DateofEntry,@Dateofbeacoming=Dateofbeacoming,@PlaceofIncorporation=PlaceOfIncorporation,@UEN=UEN From @Temp_Tbl Where S_No=@RecCount
		Set @EntityId=(Select Id From Common.EntityDetail Where UEN=@RegNum And CompanyId=@CompanyId /*And ChoosenEntityName=@EntityName*/)
		/*IF @EntityId Is Null
		Begin
			Set @Err_Msg=Concat('Entity Id Is Null','EntityName: ',@EntityName,' ','RegNo: ',@RegNum )
			RaisError(@Err_Msg,16,1)
		End
		*/
		IF @EntityId Is Not Null
		Begin
		IF (@IdType Is null Or @IdType = '' Or @IdType = ' ') Or (@IdNo Is null Or @IdNo = '' Or @IdNo = ' ') 
		Begin
			Set @GenContactId=(Select Id From Boardroom.GenericContact Where Name=@ContactName And CompanyId=@CompanyId And Coalesce(IDType,'NULL')=Case When @Category='Corporate' Then Case When @PlaceofIncorporation='SINGAPORE' Then 'Local Company' Else 'Others' End Else Coalesce(@IdType,'NULL') End And Coalesce(IDNumber,'NULL')=Case When @Category='Corporate' Then @UEN Else Coalesce(@IdNo,'NULL') End )
			IF @GenContactId Is Not Null
			Begin
				Set @ContactId=(Select Id From Boardroom.Contacts Where GenericContactId=@GenContactId And EntityId=@EntityId And CompanyId=@CompanyId)
				IF @ContactId Is Not Null
				Begin
					IF Not Exists (Select Id From Boardroom.GenericContactDesignation Where GenericContactId=@GenContactId And EntityId=@EntityId And ContactId=@ContactId And Position=@SharehldrPostition And CompanyId=@CompanyId)
					Begin
						Insert Into Boardroom.GenericContactDesignation(Id,CompanyId,ContactId,GenericContactId,EntityId,Position,Status,UserCreated,CreatedDate,ShortCode,Sort,RecOrder,DateofAppointment,IsRegistrableController,Remarks,DateofRegistrable/*,Type,DateofAppointment,DateofCessation,ReasonforCessation,
																	DisqualifiedReasons,DisqualifiedReasonsSubsection,Remarks,UserCreated,CreatedDate,ModifiedBy,ModifiedDate,
																	Version,CommencementDate,CorporateRepresentative,AlternateFor,NominatedBy,IsRegistrableController,
																	IsSignificantInterest,IsSignificantControl,Reason,RegistrabledBy,DateofNominator,DateofRegistrable*/)
						Values(NEWID(),@CompanyId,@ContactId,@GenContactId,@EntityId,@SharehldrPostition,1,@UserCreated,@CraetedDate,(Select ShortCode From Boardroom.ContactMapping Where Position=@SharehldrPostition And Category=@Category And Type=@SharehldrPostition),(Select Sort From Boardroom.ContactMapping Where Type=@SharehldrPostition And Category=@Category And Position=@SharehldrPostition),(Select Max(RecOrder)+1 From Boardroom.GenericContactDesignation),@DateofEntry,@IsRegistrableController,@Notes,@Dateofbeacoming)

					End
				End
				Else IF @ContactId Is NUll
				Begin
					Set @PerEmailJson =(Select Distinct 'Email' As 'key',[Email ] As 'value' From  [dbo].[share_contact_New_Devbackup] Where Name=@ContactName and [Email ]  is not null   And Coalesce([ID no],'NULL')=Coalesce(@IdNo,'NULL') And Coalesce([ID Type],'NULL')=Coalesce(@IdType,'NULL')  For Json Auto)
					Set @PerMobileJson =(Select Distinct 'Mobile' As 'key',[Mobile Phone No#] As 'value' From  [dbo].[share_contact_New_Devbackup] Where Name=@ContactName and [Mobile Phone No#] is not null    And Coalesce([ID no],'NULL')=Coalesce(@IdNo,'NULL') And Coalesce([ID Type],'NULL')=Coalesce(@IdType,'NULL')  For Json Auto)
								
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

 					 Declare Contact_Null Cursor For
					 select Distinct [Registration No] AS RegistrationNo,[Entity Name],[ID no],[ID Type],UEN,[Place of Incorporation],Category  from  [dbo].[share_contact_New_Devbackup]
					 where [Registration No] is not null and Name =@ContactName  And Coalesce([ID no],'NULL')=Coalesce(@IdNo,'NULL') And Coalesce([ID Type],'NULL')=Coalesce(@IdType,'NULL')
					 OPEN Contact_Null
					 FETCH NEXT FROM Contact_Null INTO @RegNum,@EntityName,@IDno,@IdType,@UEN,@PlaceofIncorporation,@category
					 WHILE @@FETCH_STATUS = 0
					 BEGIN
						
						Set @EntityId =(Select Distinct Id from  Common.EntityDetail Where UEN=@RegNum and CompanyId=@CompanyId)
						If @EntityId Is Not Null
						Begin
 						If Exists (Select Distinct id from  Boardroom.GenericContact Where Name=@ContactName And CompanyId=@CompanyId And Coalesce(IDType,'NULL')=Case When @Category='Corporate' Then Case When @PlaceofIncorporation='SINGAPORE' Then 'Local Company' Else 'Others' End Else Coalesce(@IdType,'NULL') End And Coalesce(IDNumber,'NULL')=Case When @Category='Corporate' Then @UEN Else Coalesce(@IdNo,'NULL') End  /*and TypeId=@EntityId*/)
						BEGIN
							IF Not Exists (Select Id From Boardroom.Contacts Where GenericContactId=@GenContactId And EntityId=@EntityId And CompanyId=@CompanyId)
							Begin
								set @ContactId=NewId()
								set @AddressbookId =NEWID()
								-----------Boardroom.Contacts-----------
								Insert into Boardroom.Contacts(Id,CompanyId,GenericContactId,Type,Remarks,RecOrder,UserCreated,CreatedDate,ModifiedBy,ModifiedDate,Version,Status,EntityId,IsEntity,
								DateOfCessation,Docstatus,IsPrimary,IsCessation,ReasonForCessation,DisqualifiedReasons,DisqualifiedReasonsSubsection,State,IsTemporary,IsReminder)
								
								select Distinct @ContactId Id,@CompanyId CompanyId,@GenContactId GenericContactId,'Client' Type,Null Remarks,Null RecOrder,'System' As UserCreated,Getdate() CreatedDate,
								Null ModifiedBy,Null ModifiedDate,Null Version,1 Status,@EntityId EntityId,0 IsEntity,Null DateOfCessation,Null Docstatus,Null IsPrimary,
								Null IsCessation,NUll ReasonForCessation,Null DisqualifiedReasons,Null DisqualifiedReasonsSubsection,Null State,0 IsTemporary,Null IsReminder
								from [dbo].[share_contact_New_Devbackup] 
								where  [Registration No] is not null and [Registration No]=@RegNum and [Entity Name]=@EntityName and Name=@ContactName and Coalesce([ID Type],'NULL')=Coalesce(@IdType,'NULL') And Coalesce([ID no],'NULL')=Coalesce(@IdNo,'NULL') --and Position=@Position
								
								Insert Into Boardroom.GenericContactDesignation (Id,CompanyId,ContactId,GenericContactId,EntityId,Type,Position,Status,ShortCode,UserCreated,CreatedDate,Sort,RecOrder,DateofAppointment,IsRegistrableController,Remarks,DateofRegistrable/*,DateofAppointment,DateofCessation,ReasonforCessation,DisqualifiedReasons,DisqualifiedReasonsSubsection,
													Remarks,ModifiedBy,ModifiedDate,Version,CommencementDate,CorporateRepresentative,AlternateFor,
													NominatedBy,IsRegistrableController,IsSignificantInterest,IsSignificantControl,Reason,RegistrabledBy,DateofNominator,DateofRegistrable*/)
								Values(Newid(),@CompanyId,@ContactId,@GenContactId,@EntityId,Null,@SharehldrPostition,1,(Select ShortCode From Boardroom.ContactMapping Where Position=@SharehldrPostition And Category=@Category),@UserCreated,@CraetedDate,(Select Sort From Boardroom.ContactMapping Where Position=@SharehldrPostition And Category=@Category And Type=@SharehldrPostition),(Select Max(RecOrder)+1 From Boardroom.GenericContactDesignation),@DateofEntry,@IsRegistrableController,@Notes,@Dateofbeacoming)
							
								-----------[Common].[AddressBook]-----------

								Insert into [Common].[AddressBook]( Id,IsLocal,BlockHouseNo,Street,UnitNo,BuildingEstate,City,PostalCode,State,Country,Phone,Email,Website,Latitude,Longitude,RecOrder
									,Remarks,UserCreated,CreatedDate,ModifiedBy,ModifiedDate,Version,Status,DocumentId ) 
						
						
								Select Top (1) @AddressbookId Id,Case when [Local Address/ Foreign Address]='Local Address' then  1
								when [Local Address/ Foreign Address]='Foreign Address' then  0 end AS IsLocal,[Block/House No] As BlockHouseNo,							
								Case When Street Is Not Null Then Street Else Case When [Local Address/ Foreign Address]='Foreign Address' then AddressLine2 End ENd  AS Street,
								Case When [Level & Unit no] Is Not Null Then [Level & Unit no] Else Case When [Local Address/ Foreign Address]='Foreign Address' then AddressLine2 End End As UnitNo,
								[Building] AS BuildingEstate,Null AS City,
								cast([Postal Code] as nvarchar(100)) PostalCode,Null State,Country AS Country,[Mobile Phone No#] Phone,[Email ] Email,Null Website,Null Latitude,Null Longitude,NUll RecOrder,
								Null Remarks,'System' UserCreated,Getdate() AS CreatedDate,Null ModifiedBy,Null ModifiedDate,Null Version,1 AS Status,Null DocumentId
								from [dbo].[share_contact_New_Devbackup] 
								where  [Registration No] is not null and [Registration No]=@RegNum and [Entity Name]=@EntityName and Name=@ContactName and Coalesce([ID Type],'NULL')=Coalesce(@IdType,'NULL') And Coalesce([ID no],'NULL')=Coalesce(@IdNo,'NULL') --And Position=@Position
								group by [Block/House No] ,AddressLine2 ,AddressLine1 ,Building ,Country ,[Postal Code],[Mobile Phone No#] ,[Email ], [Local Address/ Foreign Address],Street,[Level & Unit no]
						
								-------[Common].[Addresses]---
								Insert into [Common].[Addresses](Id,AddSectionType,AddType,AddTypeId,AddTypeIdInt,AddressBookId,Status,DocumentId,EntityId,ScreenName,IsCurrentAddress,CompanyId,CopyId)
						
								Select Distinct NEWID()Id, [Address Type] AS AddSectionType,'Client' AddType,@ContactId AddTypeId,Null AddTypeIdInt,@AddressbookId AddressBookId,
								1 Status,Null AS DocumentId,@EntityId EntityId,Null ScreenName,Null IsCurrentAddress,@CompanyId AS CompanyId,Null CopyId
								from [dbo].[share_contact_New_Devbackup]
								Where  [Registration No] is not null and [Registration No]=@RegNum and [Entity Name]=@EntityName and Name=@ContactName and Coalesce([ID Type],'NULL')=Coalesce(@IdType,'NULL') And Coalesce([ID no],'NULL')=Coalesce(@IdNo,'NULL') 
								--Position=@Position
								Group by [Address Type]
								Update Common.Addresses set AddSectionType='Registered Office Address' where CompanyId=@CompanyId and AddSectionType='REGISTERED OFFICE ADDRESS'

							End
							Else IF Exists (Select Id From Boardroom.Contacts Where GenericContactId=@GenContactId And EntityId=@EntityId And CompanyId=@CompanyId)
							Begin
								IF Not Exists (Select Id From Boardroom.GenericContactDesignation Where GenericContactId=@GenContactId And ContactId=(Select Id From Boardroom.Contacts Where GenericContactId=@GenContactId And EntityId=@EntityId And CompanyId=@CompanyId) And EntityId=@EntityId And Position=@SharehldrPostition And CompanyId=@CompanyId)
								Begin
									Insert Into Boardroom.GenericContactDesignation (Id,CompanyId,ContactId,GenericContactId,EntityId,Type,Position,Status,ShortCode,UserCreated,CreatedDate,Sort,RecOrder,DateofAppointment,IsRegistrableController,Remarks,DateofRegistrable/*,DateofAppointment,DateofCessation,ReasonforCessation,DisqualifiedReasons,DisqualifiedReasonsSubsection,
													Remarks,ModifiedBy,ModifiedDate,Version,CommencementDate,CorporateRepresentative,AlternateFor,
													NominatedBy,IsRegistrableController,IsSignificantInterest,IsSignificantControl,Reason,RegistrabledBy,DateofNominator,DateofRegistrable*/)
									Values(Newid(),@CompanyId,(Select Id From Boardroom.Contacts Where GenericContactId=@GenContactId And EntityId=@EntityId And CompanyId=@CompanyId),@GenContactId,@EntityId,Null,@SharehldrPostition,1,(Select ShortCode From Boardroom.ContactMapping Where Position=@SharehldrPostition And Category=@Category),@UserCreated,@CraetedDate,(Select Sort From Boardroom.ContactMapping Where Position=@SharehldrPostition And Category=@Category And Type=@SharehldrPostition),(Select Max(RecOrder) From Boardroom.GenericContactDesignation),@DateofEntry,@IsRegistrableController,@Notes,@Dateofbeacoming)
								End
							End
						End
						End
						FETCH NEXT FROM Contact_Null INTO @RegNum,@EntityName,@IDno,@IdType,@UEN,@PlaceofIncorporation,@category
					End
					Close Contact_Null
					Deallocate Contact_Null
				End
			End
			IF @GenContactId Is Null
			Begin
				Set @GenContactId=NEWID()
				Set @PerEmailJson =(Select Distinct 'Email' As 'key',[Email ] As 'value' From  [dbo].[share_contact_New_Devbackup] Where Name=@ContactName and [Email ]  is not null   And Coalesce([ID Type],'NULL')=Coalesce(@IdType,'NULL') And Coalesce([ID no],'NULL')=Coalesce(@IdNo,'NULL')  For Json Auto)
				Set @PerMobileJson =(Select Distinct 'Mobile' As 'key',[Mobile Phone No#] As 'value' From  [dbo].[share_contact_New_Devbackup] Where Name=@ContactName and [Mobile Phone No#] is not null   And Coalesce([ID Type],'NULL')=Coalesce(@IdType,'NULL') And Coalesce([ID no],'NULL')=Coalesce(@IdNo,'NULL')  For Json Auto)
								
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

					 Insert into Boardroom.GenericContact (Id,CompanyId,Category,Salutation,Name,IDType,IDNumber,Nationality,Gender,DateOfBirth,CountryOfBirth,CountryOfResidence,
					 										Communication,CountryOfIncorporation,CompanyType,Suffix,CorporateEntityRegister,Remarks,RecOrder,UserCreated,CreatedDate,
					 										ModifiedBy,ModifiedDate,Version,Status,IsMainContact,Type,TypeId,ShortName,IsNoProfile,DateofCorporate,LegalForm,GoverningJurisdiction,RegisterCompaniesJurisdiction,CompanyNo)
					 
					 
					 select Distinct top 1   @GenContactId AS Id,@CompanyId AS CompanyId,Category Category,Salutation AS Salutation,@ContactName As Name,
					 /*case when [ID Type1]='FIN' then 'FIN'
					 when [ID Type1]='NRIC (Citizen)' then 'NRIC (Citizen)' 
					 when [ID Type1]='NRIC (Permanent Resident)' then 'NRIC (Permanent Citizen)' 
					 when [ID Type1]='Passport' then 'Passport/Others' end as IDType,[ID no1] IDNumber,*/
					 Case When Category='Corporate' Then Case When @PlaceOfIncorporation='SINGAPORE' Then 'Local Company' Else 'Others' End Else @IdType End,
					 Case When Category='Corporate' Then @UEN Else @IdNo End,
					 [dbo].[InitCap](Nationality) AS  Nationality,Gender Gender,[Date of Birth] DateOfBirth,
					 --case when [Country of Birth]='UNITED STATES OF AMERICA' then 'United States'
					 --when [Country of Birth]='Cyprus (Limassol)' then 'Cyprus' 
					 --when [Country of Birth]='China' then 'Peoples Republic Of China' else 
					 [dbo].[InitCap]([Country of Birth]) AS CountryOfBirth,NUll CountryOfResidence,@PerJsondata Communication,[dbo].[InitCap](@PlaceofIncorporation) AS CountryofIncorporation ,null AS CompanyType ,null AS Suffix,
					 Null CorporateEntityRegister,Null Remarks,Null RecOrder,'System' UserCreated,GETDATE() CreatedDate,null ModifiedBy,null ModifiedDate,Null Version,1 Status,
					 Null IsMainContact,'Client' Type,null TypeId, dbo.fnFirsties(@ContactName) as  ShortName ,Null As IsNoProfile,[Incorporation Date],[Legal Form],[Governing Jurisdiction & Law],[Registrar of Companies of the Jurisdiction],[Company No]
					 from [dbo].[share_contact_New_Devbackup]
					 where [Registration No] is not null and Name=@ContactName 
					 And Coalesce([ID Type],'NULL')=Coalesce(@IdType,'NULL') And Coalesce([ID no],'NULL')=Coalesce(@IdNo,'NULL')
 
					 Declare Contact_Null Cursor For
					 select Distinct [Registration No] AS RegistrationNo,[Entity Name],[ID no],[ID Type],UEN,[Place of Incorporation],Category  from  [dbo].[share_contact_New_Devbackup]
					 where [Registration No] is not null and Name =@ContactName and  Coalesce([ID Type],'NULL')=Coalesce(@IdType,'NULL') And Coalesce([ID no],'NULL')=Coalesce(@IdNo,'NULL')
					 OPEN Contact_Null
					 FETCH NEXT FROM Contact_Null INTO @RegNum,@EntityName,@IDno,@IdType,@UEN,@PlaceofIncorporation,@category
					 WHILE @@FETCH_STATUS = 0
					 BEGIN
						Set @EntityId =(Select Distinct Id from  Common.EntityDetail Where UEN=@RegNum and CompanyId=@CompanyId)
						If @EntityId Is Not Null
						Begin
 						If Exists (Select Distinct id from  Boardroom.GenericContact Where Name=@ContactName And Coalesce(IDType,'NULL')=Case When @Category='Corporate' Then Case When @PlaceofIncorporation='SINGAPORE' Then 'Local Company' Else 'Others' End Else Coalesce(@IdType,'NULL') End And Coalesce(IDNumber,'NULL')=Case When @Category='Corporate' Then @UEN Else Coalesce(@IdNo,'NULL') End /*and TypeId=@EntityId*/)
						BEGIN
							IF Not Exists (Select Id From Boardroom.Contacts Where GenericContactId=@GenContactId And EntityId=@EntityId And CompanyId=@CompanyId)
							Begin
								set @ContactId=NewId()
								set @AddressbookId =NEWID()
								-----------Boardroom.Contacts-----------
								Insert into Boardroom.Contacts(Id,CompanyId,GenericContactId,Type,Remarks,RecOrder,UserCreated,CreatedDate,ModifiedBy,ModifiedDate,Version,Status,EntityId,IsEntity,
								DateOfCessation,Docstatus,IsPrimary,IsCessation,ReasonForCessation,DisqualifiedReasons,DisqualifiedReasonsSubsection,State,IsTemporary,IsReminder)
								
								select Distinct @ContactId Id,@CompanyId CompanyId,@GenContactId GenericContactId,'Client' Type,Null Remarks,Null RecOrder,'System' As UserCreated,Getdate() CreatedDate,
								Null ModifiedBy,Null ModifiedDate,Null Version,1 Status,@EntityId EntityId,0 IsEntity,Null DateOfCessation,Null Docstatus,Null IsPrimary,
								Null IsCessation,NUll ReasonForCessation,Null DisqualifiedReasons,Null DisqualifiedReasonsSubsection,Null State,0 IsTemporary,Null IsReminder
								from [dbo].[share_contact_New_Devbackup] 
								where  [Registration No] is not null and [Registration No]=@RegNum and [Entity Name]=@EntityName and Name=@ContactName and Coalesce([ID Type],'NULL')=Coalesce(@IdType,'NULL') And Coalesce([ID no],'NULL')=Coalesce(@IdNo,'NULL') --and Position=@Position
								Insert Into Boardroom.GenericContactDesignation (Id,CompanyId,ContactId,GenericContactId,EntityId,Type,Position,Status,ShortCode,UserCreated,CreatedDate,Sort,RecOrder,DateofAppointment,IsRegistrableController,Remarks,DateofRegistrable/*,DateofAppointment,DateofCessation,ReasonforCessation,DisqualifiedReasons,DisqualifiedReasonsSubsection,
													Remarks,ModifiedBy,ModifiedDate,Version,CommencementDate,CorporateRepresentative,AlternateFor,
													NominatedBy,IsRegistrableController,IsSignificantInterest,IsSignificantControl,Reason,RegistrabledBy,DateofNominator,DateofRegistrable*/)
								Values(Newid(),@CompanyId,@ContactId,@GenContactId,@EntityId,Null,@SharehldrPostition,1,(Select ShortCode From Boardroom.ContactMapping Where Position=@SharehldrPostition And Category=@Category),@UserCreated,@CraetedDate,(Select Sort From Boardroom.ContactMapping Where Position=@SharehldrPostition And Category=@Category And Type=@SharehldrPostition),(Select Max(RecOrder)+1 From Boardroom.GenericContactDesignation),@DateofEntry,@IsRegistrableController,@Notes,@Dateofbeacoming)
							
								-----------[Common].[AddressBook]-----------
								Insert into [Common].[AddressBook]( Id,IsLocal,BlockHouseNo,Street,UnitNo,BuildingEstate,City,PostalCode,State,Country,Phone,Email,Website,Latitude,Longitude,RecOrder
									,Remarks,UserCreated,CreatedDate,ModifiedBy,ModifiedDate,Version,Status,DocumentId ) 
						
						
								Select Top (1) @AddressbookId Id,Case when [Local Address/ Foreign Address]='Local Address' then  1
								when [Local Address/ Foreign Address]='Foreign Address' then  0 end AS IsLocal,[Block/House No] As BlockHouseNo,							
								Case When Street Is Not Null Then Street Else Case When [Local Address/ Foreign Address]='Foreign Address' then AddressLine2 End ENd  AS Street,
								Case When [Level & Unit no] Is Not Null Then [Level & Unit no] Else Case When [Local Address/ Foreign Address]='Foreign Address' then AddressLine2 End End As UnitNo,
								[Building] AS BuildingEstate,Null AS City,
								cast([Postal Code] as nvarchar(100)) PostalCode,Null State,Country AS Country,[Mobile Phone No#] Phone,[Email ] Email,Null Website,Null Latitude,Null Longitude,NUll RecOrder,
								Null Remarks,'System' UserCreated,Getdate() AS CreatedDate,Null ModifiedBy,Null ModifiedDate,Null Version,1 AS Status,Null DocumentId
								from [dbo].[share_contact_New_Devbackup] 
								where  [Registration No] is not null and [Registration No]=@RegNum and [Entity Name]=@EntityName and Name=@ContactName and Coalesce([ID Type],'NULL')=Coalesce(@IdType,'NULL') And Coalesce([ID no],'NULL')=Coalesce(@IdNo,'NULL') --and Position=@Position
								group by [Block/House No] ,AddressLine2 ,AddressLine1 ,Building ,Country ,[Postal Code],[Mobile Phone No#] ,[Email ], [Local Address/ Foreign Address],Street,[Level & Unit no]
						
								-------[Common].[Addresses]---
								Insert into [Common].[Addresses](Id,AddSectionType,AddType,AddTypeId,AddTypeIdInt,AddressBookId,Status,DocumentId,EntityId,ScreenName,IsCurrentAddress,CompanyId,CopyId)
						
								Select Distinct NEWID()Id, [Address Type] AS AddSectionType,'Client' AddType,@ContactId AddTypeId,Null AddTypeIdInt,@AddressbookId AddressBookId,
								1 Status,Null AS DocumentId,@EntityId EntityId,Null ScreenName,Null IsCurrentAddress,@CompanyId AS CompanyId,Null CopyId
								from [dbo].[share_contact_New_Devbackup]
								Where  [Registration No] is not null and [Registration No]=@RegNum and [Entity Name]=@EntityName and Name=@ContactName and Coalesce([ID Type],'NULL')=Coalesce(@IdType,'NULL') And Coalesce([ID no],'NULL')=Coalesce(@IdNo,'NULL') 
								--Position=@Position
								Group by [Address Type]

								Update Common.Addresses set AddSectionType='Registered Office Address' where CompanyId=@CompanyId and AddSectionType='REGISTERED OFFICE ADDRESS'

							End
							Else IF Exists (Select Id From Boardroom.Contacts Where GenericContactId=@GenContactId And EntityId=@EntityId And CompanyId=@CompanyId)
							Begin
								IF Not Exists (Select Id From Boardroom.GenericContactDesignation Where GenericContactId=@GenContactId And ContactId=(Select Id From Boardroom.Contacts Where GenericContactId=@GenContactId And EntityId=@EntityId And CompanyId=@CompanyId) And EntityId=@EntityId And Position=@SharehldrPostition And CompanyId=@CompanyId)
								Begin
		
									Insert Into Boardroom.GenericContactDesignation (Id,CompanyId,ContactId,GenericContactId,EntityId,Type,Position,Status,ShortCode,UserCreated,CreatedDate,Sort,RecOrder,DateofAppointment,IsRegistrableController,Remarks,DateofRegistrable/*,DateofAppointment,DateofCessation,ReasonforCessation,DisqualifiedReasons,DisqualifiedReasonsSubsection,
													Remarks,ModifiedBy,ModifiedDate,Version,CommencementDate,CorporateRepresentative,AlternateFor,
													NominatedBy,IsRegistrableController,IsSignificantInterest,IsSignificantControl,Reason,RegistrabledBy,DateofNominator,DateofRegistrable*/)
									Values(Newid(),@CompanyId,(Select Id From Boardroom.Contacts Where GenericContactId=@GenContactId And EntityId=@EntityId And CompanyId=@CompanyId),@GenContactId,@EntityId,Null,@SharehldrPostition,1,(Select ShortCode From Boardroom.ContactMapping Where Position=@SharehldrPostition And Category=@Category),@UserCreated,@CraetedDate,(Select Sort From Boardroom.ContactMapping Where Position=@SharehldrPostition And Category=@Category And Type=@SharehldrPostition),(Select Max(RecOrder) From Boardroom.GenericContactDesignation),@DateofEntry,@IsRegistrableController,@Notes,@Dateofbeacoming)
								End
							End
						End
						End
						FETCH NEXT FROM Contact_Null INTO @RegNum,@EntityName,@IDno,@IdType,@UEN,@PlaceofIncorporation,@category
					End
					Close Contact_Null
					Deallocate Contact_Null
			End
		End
		Else IF (@IdType Is Not Null And( @IdType <> '' Or @IdType <> ' ')) Or (@IdNo Is Not Null And( @IdNo <> '' Or @IdNo <> ' ') )
		Begin
			Set @GenContactId=(Select Id From Boardroom.GenericContact Where Name=@ContactName And CompanyId=@CompanyId And Coalesce(IDType,'NULL')=Case When @Category='Corporate' Then Case When @PlaceofIncorporation='SINGAPORE' Then 'Local Company' Else 'Others' End Else Coalesce(@IdType,'NULL') End And Coalesce(IDNumber,'NULL')=Case When Category='Corporate' Then @UEN Else Coalesce(@IdNo,'NULL') End)
			IF @GenContactId Is Not Null
			Begin
				Set @ContactId=(Select Id From Boardroom.Contacts Where GenericContactId=@GenContactId And EntityId=@EntityId And CompanyId=@CompanyId)
				IF @ContactId Is Not Null
				Begin
					IF Not Exists (Select Id From Boardroom.GenericContactDesignation Where GenericContactId=@GenContactId And EntityId=@EntityId And ContactId=@ContactId And Position=@SharehldrPostition And CompanyId=@CompanyId)
					Begin
						Insert Into Boardroom.GenericContactDesignation(Id,CompanyId,ContactId,GenericContactId,EntityId,Position,Status,ShortCode,UserCreated,CreatedDate,Sort,RecOrder,DateofAppointment,IsRegistrableController,Remarks,DateofRegistrable/*,Type,DateofAppointment,DateofCessation,ReasonforCessation,
																	DisqualifiedReasons,DisqualifiedReasonsSubsection,Remarks,ModifiedBy,ModifiedDate,
																	Version,CommencementDate,CorporateRepresentative,AlternateFor,NominatedBy,IsRegistrableController,
																	IsSignificantInterest,IsSignificantControl,Reason,RegistrabledBy,DateofNominator,DateofRegistrable*/)
						Values(NEWID(),@CompanyId,@ContactId,@GenContactId,@EntityId,@SharehldrPostition,1,(Select ShortCode From Boardroom.ContactMapping Where Position=@SharehldrPostition And Category=@Category),@UserCreated,@CraetedDate,(Select Sort From Boardroom.ContactMapping Where Position=@SharehldrPostition And Category=@Category And Type=@SharehldrPostition),(Select Max(RecOrder) From Boardroom.GenericContactDesignation),@DateofEntry,@IsRegistrableController,@Notes,@Dateofbeacoming)

					End
				End
				Else IF @ContactId Is Null
				Begin
					Set @PerEmailJson =(Select Distinct 'Email' As 'key',[Email ] As 'value' From  [dbo].[share_contact_New_Devbackup] Where Name=@ContactName and [Email ] is not null   and Coalesce([ID Type],'NULL')=Coalesce(@IdType,'NULL') And Coalesce([ID no],'NULL')=Coalesce(@IdNo,'NULL')   For Json Auto)
					Set @PerMobileJson =(Select Distinct 'Mobile' As 'key',[Mobile Phone No#] As 'value' From  [dbo].[share_contact_New_Devbackup] Where Name=@ContactName and [Mobile Phone No#] is not null and Coalesce([ID Type],'NULL')=Coalesce(@IdType,'NULL') And Coalesce([ID no],'NULL')=Coalesce(@IdNo,'NULL')  For Json Auto)
					IF @PerEmailJson Is Not Null
					Begin
						IF @PerMobileJson Is Not Null
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
					Declare Contact Cursor For
					select Distinct [Registration No] AS RegistrationNo,[Entity Name],[ID no],[ID Type],UEN,[Place of Incorporation],Category 
					From  [dbo].[share_contact_New_Devbackup]
					Where [Registration No] Is Not Null And Name=@ContactName And [ID no]=@IDno And [ID Type]=@IdType
					OPEN Contact
					FETCH NEXT FROM Contact INTO @RegNum,@EntityName,@IDno,@IdType,@UEN,@PlaceofIncorporation,@category
					WHILE @@FETCH_STATUS = 0
					BEGIN
						Set @EntityId =(Select Distinct Id from Common.EntityDetail Where UEN=@RegNum and CompanyId=@CompanyId /*And ChoosenEntityName=@EntityName*/)
						If @EntityId Is Not Null
						Begin
 						If Exists (Select Distinct id from  Boardroom.GenericContact Where Name=@ContactName  And Coalesce(IDType,'NULL')=Case When @Category='Corporate' Then Case When @PlaceofIncorporation='SINGAPORE' Then 'Local Company' Else 'Others' End Else Coalesce(@IdType,'NULL') End And Coalesce(IDNumber,'NULL')=Case When @Category='Corporate' Then @UEN Else Coalesce(@IdNo,'NULL') End And CompanyId=@CompanyId /*and TypeId=@EntityId*/ )
						BEGIN
							IF Not Exists (Select Id From Boardroom.Contacts Where GenericContactId=@GenContactId And EntityId=@EntityId And CompanyId=@CompanyId)
							Begin
								Set @ContactId=NewId()
								Set @AddressbookId =NEWID()
								Insert into Boardroom.Contacts(Id,CompanyId,GenericContactId,Type,Remarks,RecOrder,UserCreated,CreatedDate,ModifiedBy,ModifiedDate,Version,Status,EntityId,IsEntity,
								DateOfCessation,Docstatus,IsPrimary,IsCessation,ReasonForCessation,DisqualifiedReasons,DisqualifiedReasonsSubsection,State,IsTemporary,IsReminder)

								select Distinct @ContactId Id,@CompanyId CompanyId,@GenContactId GenericContactId,'Client' Type,Null Remarks,Null RecOrder,'System' As UserCreated,Getdate() CreatedDate,
								Null ModifiedBy,Null ModifiedDate,Null Version,1 Status,@EntityId EntityId,0 IsEntity,Null DateOfCessation,Null Docstatus,Null IsPrimary,
								Null IsCessation,NUll ReasonForCessation,Null DisqualifiedReasons,Null DisqualifiedReasonsSubsection,Null State,0 IsTemporary,Null IsReminder
								from [dbo].[share_contact_New_Devbackup] 
								where  [Registration No] is not null and [Registration No]=@RegNum and [Entity Name]=@EntityName and Name=@ContactName and Coalesce([ID Type],'NULL')=Coalesce(@IdType,'NULL') And Coalesce([ID no],'NULL')=Coalesce(@IdNo,'NULL') --and Position=@Position
								Insert Into Boardroom.GenericContactDesignation (Id,CompanyId,ContactId,GenericContactId,EntityId,Type,Position,Status,ShortCode,UserCreated,CreatedDate,Sort,RecOrder,DateofAppointment,IsRegistrableController,Remarks,DateofRegistrable/*,DateofAppointment,DateofCessation,ReasonforCessation,DisqualifiedReasons,DisqualifiedReasonsSubsection,
													Remarks,ModifiedBy,ModifiedDate,Version,CommencementDate,CorporateRepresentative,AlternateFor,
													NominatedBy,IsRegistrableController,IsSignificantInterest,IsSignificantControl,Reason,RegistrabledBy,DateofNominator,DateofRegistrable*/)
								Values(Newid(),@CompanyId,@ContactId,@GenContactId,@EntityId,Null,@SharehldrPostition,1,(Select ShortCode From Boardroom.ContactMapping Where Position=@SharehldrPostition And Category=@Category),@UserCreated,@CraetedDate,(Select Sort From Boardroom.ContactMapping Where Position=@SharehldrPostition And Category=@Category And Type=@SharehldrPostition),(Select Max(RecOrder) From Boardroom.GenericContactDesignation),@DateofEntry,@IsRegistrableController,@Notes,@Dateofbeacoming)
								Insert into [Common].[AddressBook]( Id,IsLocal,BlockHouseNo,Street,UnitNo,BuildingEstate,City,PostalCode,State,Country,Phone,Email,Website,Latitude,Longitude,RecOrder
								,Remarks,UserCreated,CreatedDate,ModifiedBy,ModifiedDate,Version,Status,DocumentId ) 

								select Top (1) @AddressbookId Id,Case when [Local Address/ Foreign Address]='Local Address' then  1
										when [Local Address/ Foreign Address]='Foreign Address' then  0 end AS IsLocal,[Block/House No] As BlockHouseNo,
										Case when Street Is Not Null Then Street Else Case when [Local Address/ Foreign Address]='Foreign Address' then [AddressLine2] End ENd  AS Street,
										Case when [Level & Unit no] Is Not Null then [Level & Unit no] Else Case When [Local Address/ Foreign Address]='Foreign Address' then [AddressLine1] End ENd as UnitNo,Building AS BuildingEstate,Null AS City,
										cast([Postal Code] as nvarchar(100)) PostalCode,Null State,[Country] AS Country,[Mobile Phone No#] As Phone,[Email ] As Email,Null Website,Null Latitude,Null Longitude,NUll RecOrder,
										Null Remarks,'System' UserCreated,Getdate() AS CreatedDate,Null ModifiedBy,Null ModifiedDate,Null Version,1 AS Status,Null DocumentId
								from [dbo].[share_contact_New_Devbackup] 
								where  [Registration No] is not null and [Registration No]=@RegNum and [Entity Name]=@EntityName and Name=@ContactName and Coalesce([ID Type],'NULL')=Coalesce(@IdType,'NULL') And Coalesce([ID no],'NULL')=Coalesce(@IdNo,'NULL') --and Position=@Position
								group by [Block/House No] ,[AddressLine2] ,[AddressLine1] ,Building ,Country ,[Postal Code],[Mobile Phone No#] ,[Email ], [Local Address/ Foreign Address],Street,[Level & Unit no]

								-------[Common].[Addresses]---
								Insert into [Common].[Addresses](Id,AddSectionType,AddType,AddTypeId,AddTypeIdInt,AddressBookId,Status,DocumentId,EntityId,ScreenName,IsCurrentAddress,CompanyId,CopyId)

								select Distinct NEWID() As Id, [Address Type] AS AddSectionType,'Client' AddType,@ContactId AddTypeId,Null AddTypeIdInt,@AddressbookId AddressBookId,
								1 Status,Null AS DocumentId,@EntityId EntityId,Null ScreenName,Null IsCurrentAddress,@CompanyId AS CompanyId,Null CopyId
								from [dbo].[share_contact_New_Devbackup] 
								where  [Registration No] is not null and [Registration No]=@RegNum and [Entity Name]=@EntityName and Name=@ContactName and Coalesce([ID Type],'NULL')=Coalesce(@IdType,'NULL') And Coalesce([ID no],'NULL')=Coalesce(@IdNo,'NULL')
							
								 --Position=@Position
								Group by [Address Type]
							
								Update Common.Addresses set AddSectionType='Registered Office Address' where CompanyId=@CompanyId and AddSectionType='REGISTERED OFFICE ADDRESS'
								-------------------------------
							End
							Else IF Exists (Select Id From Boardroom.Contacts Where GenericContactId=@GenContactId And EntityId=@EntityId And CompanyId=@CompanyId)
							Begin
								IF Not Exists (Select Id From Boardroom.GenericContactDesignation Where GenericContactId=@GenContactId And ContactId=(Select Id From Boardroom.Contacts Where GenericContactId=@GenContactId And EntityId=@EntityId And CompanyId=@CompanyId) And EntityId=@EntityId And Position=@SharehldrPostition And CompanyId=@CompanyId)
								Begin
									Insert Into Boardroom.GenericContactDesignation (Id,CompanyId,ContactId,GenericContactId,EntityId,Type,Position,Status,ShortCode,UserCreated,CreatedDate,Sort,RecOrder,DateofAppointment,IsRegistrableController,Remarks,DateofRegistrable/*,DateofAppointment,DateofCessation,ReasonforCessation,DisqualifiedReasons,DisqualifiedReasonsSubsection,
													Remarks,ModifiedBy,ModifiedDate,Version,CommencementDate,CorporateRepresentative,AlternateFor,
													NominatedBy,IsRegistrableController,IsSignificantInterest,IsSignificantControl,Reason,RegistrabledBy,DateofNominator,DateofRegistrable*/)
									Values(Newid(),@CompanyId,(Select Id From Boardroom.Contacts Where GenericContactId=@GenContactId And EntityId=@EntityId And CompanyId=@CompanyId),@GenContactId,@EntityId,Null,@SharehldrPostition,1,(Select ShortCode From Boardroom.ContactMapping Where Position=@SharehldrPostition And Category=@Category),@UserCreated,@CraetedDate,(Select Sort From Boardroom.ContactMapping Where Position=@SharehldrPostition And Category=@Category And Type=@SharehldrPostition),(Select Max(RecOrder) From Boardroom.GenericContactDesignation),@DateofEntry,@IsRegistrableController,@Notes,@Dateofbeacoming)
								End
							End

						END
						End
						Fetch next from Contact Into @RegNum,@EntityName,@IDno,@IdType,@UEN,@PlaceofIncorporation,@category
							
					END
					Close Contact
					Deallocate Contact

				End
			End
			IF @GenContactId Is Null
			Begin
				Set @GenContactId=NEWID()
				Set @PerEmailJson =(Select Distinct 'Email' As 'key',[Email ] As 'value' From  [dbo].[share_contact_New_Devbackup] Where Name=@ContactName and [Email ] is not null   and Coalesce([ID Type],'NULL')=Coalesce(@IdType,'NULL') And Coalesce([ID no],'NULL')=Coalesce(@IdNo,'NULL')   For Json Auto)
				Set @PerMobileJson =(Select Distinct 'Mobile' As 'key',[Mobile Phone No#] As 'value' From  [dbo].[share_contact_New_Devbackup] Where Name=@ContactName and [Mobile Phone No#] is not null and Coalesce([ID Type],'NULL')=Coalesce(@IdType,'NULL') And Coalesce([ID no],'NULL')=Coalesce(@IdNo,'NULL')  For Json Auto)
				IF @PerEmailJson Is Not Null
				Begin
					IF @PerMobileJson Is Not Null
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
				Insert into Boardroom.GenericContact (Id,CompanyId,Category,Salutation,Name,IDType,IDNumber,Nationality,Gender,DateOfBirth,CountryOfBirth,CountryOfResidence,Communication,CountryOfIncorporation,CompanyType
				      ,Suffix,CorporateEntityRegister,Remarks,RecOrder,UserCreated,CreatedDate,ModifiedBy,ModifiedDate,Version,Status,IsMainContact,Type,TypeId,
				     ShortName,IsNoProfile,DateofCorporate,LegalForm,GoverningJurisdiction,RegisterCompaniesJurisdiction,CompanyNo)

				Select Distinct top 1   @GenContactId AS Id,@CompanyId AS CompanyId,Category As Category,Salutation AS Salutation,@ContactName Name,
					Case When Category='Corporate' Then Case When [Place of Incorporation]='SINGAPORE' Then 'Local Company' Else 'Others' End Else 
						case when [ID Type]='FIN' then 'FIN'
							 when [ID Type]='NRIC (Citizen)' then 'NRIC (Citizen)' 
							 when [ID Type]='NRIC (Permanent Resident)' then 'NRIC (Permanent Citizen)' 
							 when [ID Type]='Passport' then 'Passport/Others' Else [ID Type] end End As IDType,
						 Case When Category='Corporate' Then UEN Else [ID no] End As IDNumber,[dbo].[InitCap](Nationality) AS  Nationality,Gender Gender,[Date of Birth] DateOfBirth,
					--case when [Country of Birth]='UNITED STATES OF AMERICA' then 'United States'
					--	 when [Country of Birth]='Cyprus (Limassol)' then 'Cyprus' 
					--	 when [Country of Birth]='China' then 'Peoples Republic Of China' else
						  [dbo].[InitCap]([Country of Birth]) AS CountryOfBirth,
					NUll CountryOfResidence,@PerJsondata Communication,[dbo].[InitCap](@PlaceofIncorporation) AS CountryofIncorporation ,null AS CompanyType ,null AS Suffix,
					Null CorporateEntityRegister,Null Remarks,Null RecOrder,'System' UserCreated,GETDATE() CreatedDate,null ModifiedBy,null ModifiedDate,Null Version,1 Status,
					Null IsMainContact,'Client' Type,Null TypeId, dbo.fnFirsties(@ContactName) as  ShortName ,Null IsNoProfile,[Incorporation Date],[Legal Form],[Governing Jurisdiction & Law],[Registrar of Companies of the Jurisdiction],[Company No]
				From [dbo].[share_contact_New_Devbackup]
				Where [Registration No] is not null and Name=@ContactName and Coalesce([ID Type],'NULL')=Coalesce(@IdType,'NULL') And Coalesce([ID no],'NULL')=Coalesce(@IdNo,'NULL')
				
				Declare Contact Cursor For
				select Distinct [Registration No] AS RegistrationNo,[Entity Name],[ID no],[ID Type],UEN,[Place of Incorporation],Category
				From  [dbo].[share_contact_New_Devbackup]
				Where [Registration No] Is Not Null And Name=@ContactName And Coalesce([ID Type],'NULL')=Coalesce(@IdType,'NULL') And Coalesce([ID no],'NULL')=Coalesce(@IdNo,'NULL')
				OPEN Contact
				FETCH NEXT FROM Contact INTO @RegNum,@EntityName,@IDno,@IdType,@UEN,@PlaceofIncorporation,@category
				WHILE @@FETCH_STATUS = 0
				BEGIN
					Set @EntityId =(Select Distinct Id from Common.EntityDetail Where UEN=@RegNum and CompanyId=@CompanyId /*And ChoosenEntityName=@EntityName*/)
					If @EntityId Is Not Null
					Begin
 					If Exists (Select Distinct id from  Boardroom.GenericContact Where Name=@ContactName  And Coalesce(IDType,'NULL')=Case When @Category='Corporate' Then Case When @PlaceofIncorporation='SINGAPORE' Then 'Local Company' Else 'Others' End Else Coalesce(@IdType,'NULL') End And Coalesce(IDNumber,'NULL')=Case When @Category='Corporate' Then @UEN Else Coalesce(@IdNo,'NULL') End /*and TypeId=@EntityId*/ )
					BEGIN
						IF Not Exists (Select Id From Boardroom.Contacts Where GenericContactId=@GenContactId And EntityId=@EntityId)
						Begin
							set @ContactId=NewId()
							set @AddressbookId =NEWID()
							Insert into Boardroom.Contacts(Id,CompanyId,GenericContactId,Type,Remarks,RecOrder,UserCreated,CreatedDate,ModifiedBy,ModifiedDate,Version,Status,EntityId,IsEntity,
							DateOfCessation,Docstatus,IsPrimary,IsCessation,ReasonForCessation,DisqualifiedReasons,DisqualifiedReasonsSubsection,State,IsTemporary,IsReminder)

							select Distinct @ContactId Id,@CompanyId CompanyId,@GenContactId GenericContactId,'Client' Type,Null Remarks,Null RecOrder,'System' As UserCreated,Getdate() CreatedDate,
							Null ModifiedBy,Null ModifiedDate,Null Version,1 Status,@EntityId EntityId,0 IsEntity,Null DateOfCessation,Null Docstatus,Null IsPrimary,
							Null IsCessation,NUll ReasonForCessation,Null DisqualifiedReasons,Null DisqualifiedReasonsSubsection,Null State,0 IsTemporary,Null IsReminder
							from [dbo].[share_contact_New_Devbackup] 
							where  [Registration No] is not null and [Registration No]=@RegNum and [Entity Name]=@EntityName and Name=@ContactName and Coalesce([ID Type],'NULL')=Coalesce(@IdType,'NULL') And Coalesce([ID no],'NULL')=Coalesce(@IdNo,'NULL') --and Position=@Position
							Insert Into Boardroom.GenericContactDesignation (Id,CompanyId,ContactId,GenericContactId,EntityId,Type,Position,Status,ShortCode,UserCreated,CreatedDate,Sort,RecOrder,DateofAppointment,IsRegistrableController,Remarks,DateofRegistrable/*,DateofAppointment,DateofCessation,ReasonforCessation,DisqualifiedReasons,DisqualifiedReasonsSubsection,
													Remarks,ModifiedBy,ModifiedDate,Version,CommencementDate,CorporateRepresentative,AlternateFor,
													NominatedBy,IsRegistrableController,IsSignificantInterest,IsSignificantControl,Reason,RegistrabledBy,DateofNominator,DateofRegistrable*/)
								Values(Newid(),@CompanyId,@ContactId,@GenContactId,@EntityId,Null,@SharehldrPostition,1,(Select ShortCode From Boardroom.ContactMapping Where Position=@SharehldrPostition And Category=@Category),@UserCreated,@CraetedDate,(Select Sort From Boardroom.ContactMapping Where Position=@SharehldrPostition And Category=@Category And Type=@SharehldrPostition),(Select Max(RecOrder) From Boardroom.GenericContactDesignation),@DateofEntry,@IsRegistrableController,@Notes,@Dateofbeacoming)
							Insert into [Common].[AddressBook]( Id,IsLocal,BlockHouseNo,Street,UnitNo,BuildingEstate,City,PostalCode,State,Country,Phone,Email,Website,Latitude,Longitude,RecOrder
								,Remarks,UserCreated,CreatedDate,ModifiedBy,ModifiedDate,Version,Status,DocumentId ) 


							select Top (1) @AddressbookId Id,Case when [Local Address/ Foreign Address]='Local Address' then  1
							when [Local Address/ Foreign Address]='Foreign Address' then  0 end AS IsLocal,[Block/House No] As BlockHouseNo,
							
							Case when Street Is Not Null Then Street Else Case when [Local Address/ Foreign Address]='Foreign Address' then [AddressLine2] End ENd  AS Street,
							
							Case when [Level & Unit no] Is Not Null then [Level & Unit no] Else Case When [Local Address/ Foreign Address]='Foreign Address' then [AddressLine1] End ENd as UnitNo,Building AS BuildingEstate,Null AS City,
							cast([Postal Code] as nvarchar(100)) PostalCode,Null State,[Country] AS Country,[Mobile Phone No#] As Phone,[Email ] As Email,Null Website,Null Latitude,Null Longitude,NUll RecOrder,
							Null Remarks,'System' UserCreated,Getdate() AS CreatedDate,Null ModifiedBy,Null ModifiedDate,Null Version,1 AS Status,Null DocumentId
							from [dbo].[share_contact_New_Devbackup] 
							where  [Registration No] is not null and [Registration No]=@RegNum and [Entity Name]=@EntityName and Name=@ContactName and Coalesce([ID Type],'NULL')=Coalesce(@IdType,'NULL') And Coalesce([ID no],'NULL')=Coalesce(@IdNo,'NULL') --and Position=@Position
							group by [Block/House No] ,[AddressLine2] ,[AddressLine1] ,Building ,Country ,[Postal Code],[Mobile Phone No#] ,[Email ], [Local Address/ Foreign Address],Street,[Level & Unit no]

							-------[Common].[Addresses]---
							Insert into [Common].[Addresses](Id,AddSectionType,AddType,AddTypeId,AddTypeIdInt,AddressBookId,Status,DocumentId,EntityId,ScreenName,IsCurrentAddress,CompanyId,CopyId)

							select Distinct NEWID() As Id, [Address Type] AS AddSectionType,'Client' AddType,@ContactId AddTypeId,Null AddTypeIdInt,@AddressbookId AddressBookId,
							1 Status,Null AS DocumentId,@EntityId EntityId,Null ScreenName,Null IsCurrentAddress,@CompanyId AS CompanyId,Null CopyId
							from [dbo].[share_contact_New_Devbackup] 
							where  [Registration No] is not null and [Registration No]=@RegNum and [Entity Name]=@EntityName and Name=@ContactName and Coalesce([ID no],'NULL')=Coalesce(@IDno,'NULL') and Coalesce([ID Type],'NULL') =Coalesce(@IdType,NULL)
							
							 --Position=@Position
							Group by [Address Type]
							
							Update Common.Addresses set AddSectionType='Registered Office Address' where CompanyId=@CompanyId and AddSectionType='REGISTERED OFFICE ADDRESS'
							-------------------------------
						End
						Else IF Exists (Select Id From Boardroom.Contacts Where GenericContactId=@GenContactId And EntityId=@EntityId And CompanyId=@CompanyId)
						Begin
							IF Not Exists (Select Id From Boardroom.GenericContactDesignation Where GenericContactId=@GenContactId And ContactId=(Select Id From Boardroom.Contacts Where GenericContactId=@GenContactId And EntityId=@EntityId And CompanyId=@CompanyId) And EntityId=@EntityId And Position=@SharehldrPostition And CompanyId=@CompanyId)
							Begin
									Insert Into Boardroom.GenericContactDesignation (Id,CompanyId,ContactId,GenericContactId,EntityId,Type,Position,Status,ShortCode,UserCreated,CreatedDate,Sort,RecOrder,DateofAppointment,IsRegistrableController,Remarks,DateofRegistrable/*,DateofAppointment,DateofCessation,ReasonforCessation,DisqualifiedReasons,DisqualifiedReasonsSubsection,
													Remarks,ModifiedBy,ModifiedDate,Version,CommencementDate,CorporateRepresentative,AlternateFor,
													NominatedBy,IsRegistrableController,IsSignificantInterest,IsSignificantControl,Reason,RegistrabledBy,DateofNominator,DateofRegistrable*/)
									Values(Newid(),@CompanyId,(Select Id From Boardroom.Contacts Where GenericContactId=@GenContactId And EntityId=@EntityId And CompanyId=@CompanyId),@GenContactId,@EntityId,Null,@SharehldrPostition,1,(Select ShortCode From Boardroom.ContactMapping Where Position=@SharehldrPostition And Category=@Category),@UserCreated,@CraetedDate,(Select Sort From Boardroom.ContactMapping Where Position=@SharehldrPostition And Category=@Category And Type=@SharehldrPostition),(Select Max(RecOrder) From Boardroom.GenericContactDesignation),@DateofEntry,@IsRegistrableController,@Notes,@Dateofbeacoming)
							End
						End

					END
					End
					Fetch next from Contact Into @RegNum,@EntityName,@IDno,@IdType,@UEN,@PlaceofIncorporation,@category
							
					END
					Close Contact
					Deallocate Contact

			End
		End

		End
		Set @RecCount=@RecCount+1
		
	End
	Update GC Set GC.IsNoProfile=null From Boardroom.GenericContact As GC
	Inner Join Boardroom.GenericContactDesignation As GCD On GCD.GenericContactId=GC.Id  And GCD.CompanyId=GC.CompanyId 
	Where GC.CompanyId=@CompanyId --And GCD.Position=@SharehldrPostition
	Commit Transaction
End Try
Begin Catch
	Rollback;
	Set @Err_Msg=(Select ERROR_MESSAGE())
	RaisError (@Err_Msg,16,1);

End Catch

End
GO
