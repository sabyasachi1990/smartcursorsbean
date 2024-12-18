USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[BR_Migartion_Auditor_Contact_SP_New_Devbackup]    Script Date: 16-12-2024 9.20.10 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE Procedure  [dbo].[BR_Migartion_Auditor_Contact_SP_New_Devbackup]
@CompanyId BigInt
AS
BEGIN
-- exec [dbo].[BR_Migartion_Auditor_Contact_SP_New_Devbackup] 1257

Declare --@companyId int=1257,
		@GenericContactId uniqueidentifier,
		@Genericid uniqueidentifier,
		@Contactid uniqueidentifier,
		@RegistrationNo NVARCHAR(MAX),
		@EntityName NVARCHAR(MAX),
		@EntityId uniqueidentifier,
		@EEntityName  NVARCHAR(MAX),
		@CountryofIncorporation NVARCHAR(MAX),
		@CompanyType NVARCHAR(MAX),
		@Suffix NVARCHAR(MAX),
		@ShortName NVARCHAR(MAX),
		@AuditorContactName Nvarchar(max),
		@IdType Nvarchar(max),
		@IdNumber Nvarchar(max),
		@PerEmailJson  Nvarchar(max),
		@PerMobileJson  Nvarchar(max),
		@EntEmailJson  Nvarchar(max),
		@EntMobileJson  Nvarchar(max),
		@PerJsondata  Nvarchar(max),
		@EntJsondata Nvarchar(max),
		@GenericContactDesignationId Uniqueidentifier,
		@ShortCode Nvarchar(max),
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
		@AddressbookId Uniqueidentifier,
		@UENNO NVARCHAR(MAX),
		@AuditorIDno NVARCHAR(MAX) ,
		@Position nvarchar(max),
		@Sort NVARCHAR(MAX) ,
		@Category NVARCHAR(MAX) ,
		@AuditEntityId Uniqueidentifier,
		@AuditGenericontactid Uniqueidentifier,
		@AuditContactid   Uniqueidentifier
 
 
 
 Declare GenericContact Cursor For
 select Distinct Auditor,[Identification No] from dbo.[BR_New_CompanyDetails_DevBackup] cd
 Inner join [dbo].[BR_Concate_New_Table_Devbackup]  cc on cd.[Company No#]=cc.[Registration No]
 where Auditor<>'NA' 
 OPEN GenericContact
 FETCH NEXT FROM GenericContact INTO @AuditorContactName,@AuditorIDno--,@IdType
 WHILE @@FETCH_STATUS = 0
 BEGIN
 

	If  NOT Exists (Select Distinct id from  Boardroom.GenericContact Where Name=@AuditorContactName  and Coalesce(IDNumber,'NUll')=Coalesce(@AuditorIDno,'NUll') and CompanyId=@companyId)
	BEGIN
	
			set @GenericContactId=NewId()
			Set @PerEmailJson =(Select Distinct 'Email' As 'key',Email As 'value' From  [dbo].[BR_Concate_New_Table_Devbackup] Where Contact=@AuditorContactName and Email is not null   and Isnull([ID no],'NUll')=isnull(@AuditorIDno,'NUll')   For Json Auto)
			Set @PerMobileJson =(Select Distinct 'Mobile' As 'key',[Mobile Phone No#] As 'value' From  [dbo].[BR_Concate_New_Table_Devbackup] Where Contact=@AuditorContactName and [Mobile Phone No#] is not null   and Isnull([ID no],'NUll')=isnull(@AuditorIDno,'NUll') For Json Auto)
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

		
			insert into Boardroom.GenericContact (Id,CompanyId,Category,Salutation,Name,IDType,IDNumber,Nationality,Gender,DateOfBirth,CountryOfBirth,CountryOfResidence,Communication,CountryOfIncorporation,CompanyType
				,Suffix,CorporateEntityRegister,Remarks,RecOrder,UserCreated,CreatedDate,ModifiedBy,ModifiedDate,Version,Status,IsMainContact,Type,TypeId,ShortName,IsNoProfile)


			select Distinct top 1  @GenericContactId AS Id,@companyId AS CompanyId,Type As Category,Null AS Salutation,Auditor Name,
			 /*case when [ID Type]='FIN' then 'FIN'
			 when [ID Type]='NRIC (Citizen)' then 'NRIC (Citizen)' 
			 when [ID Type]='NRIC (Permanent Resident)' then 'NRIC (Permanent Citizen)' 
			 when [ID Type]='Passport' then 'Passport/Others' else [ID Type] end as IDType*/ Null As IdType,[Identification No] As IDNumber,[dbo].[InitCap](Country) AS  Nationality,Null As Gender,Null As DateOfBirth,
			 /*case when [Country of Birth]='UNITED STATES OF AMERICA' then 'United States'
			 when [Country of Birth]='Cyprus (Limassol)' then 'Cyprus' 
			 when [Country of Birth]='China' then 'Peoples Republic Of China' else [dbo].[InitCap]([Country of Birth]) end*/ Null As CountryOfBirth,Null As CountryOfResidence,@PerJsondata Communication,null AS CountryofIncorporation ,null AS CompanyType ,null AS Suffix,
			 Null CorporateEntityRegister,Null Remarks,Null RecOrder,'System' UserCreated,GETUTCDATE() CreatedDate,null ModifiedBy,null ModifiedDate,Null Version,1 Status,
			 Null IsMainContact,'Client' Type,null TypeId, dbo.fnFirsties(@AuditorContactName) as  ShortName ,Null IsNoProfile
			 from /*[dbo].[BR_Concate_New_Table_Devbackup] cc*/
			/* inner join */dbo.[BR_New_CompanyDetails_DevBackup] /*cd on cc.[Registration No]=cd.[Company No#] */
			  where Auditor<>'NA' and  [Company No#]is not null and Auditor=@AuditorContactName and isnull([Identification No],'Null')=isnull(@AuditorIDno,'Null')  ---and Position=@Position

-------------------------------------------------------------------------------------------------------------------------------

			Declare Contact Cursor For
			select Distinct Auditor,[Identification No],[Company No#],cd.[Entity Name],cd.Position,Type from dbo.[BR_New_CompanyDetails_DevBackup] cd
			inner join [dbo].[BR_Concate_New_Table_Devbackup]  cc on cd.[Company No#]=cc.[Registration No]
			where Auditor<>'NA' and Auditor =@AuditorContactName and  Coalesce([Identification No],'Null')=Coalesce(@AuditorIDno,'NUll') --and cd.[Entity Name]=@EntityName
			OPEN Contact
			FETCH NEXT FROM Contact INTO @AuditorContactName,@AuditorIDno,@RegistrationNo,@EntityName,@Position,@Category
			WHILE @@FETCH_STATUS = 0
			BEGIN
			

				set @EntityId=Null
				Set @EntityId =(Select Distinct Id from  Common.EntityDetail Where UEN=@RegistrationNo and EntityName=@EntityName and CompanyId=@companyId)

				If  Not Exists (Select Distinct id from  Boardroom.Contacts Where GenericContactId=@GenericContactId and CompanyId=@companyId and EntityId=@EntityId)
				 BEGIN
				  
					 set @ContactId=NewId()
					 set @AddressbookId =NEWID()
					

					Insert into Boardroom.Contacts(Id,CompanyId,GenericContactId,Type,Remarks,RecOrder,UserCreated,CreatedDate,ModifiedBy,ModifiedDate,Version,Status,EntityId,IsEntity,
					DateOfCessation,Docstatus,IsPrimary,IsCessation,ReasonForCessation,DisqualifiedReasons,DisqualifiedReasonsSubsection,State,IsTemporary,IsReminder)
         
					select TOP 1 @ContactId As Id,@companyId As CompanyId,@GenericContactId AsGenericContactId,'Client' Type,Null Remarks,Null RecOrder,'System' As UserCreated,GETUTCDATE() CreatedDate,
					Null ModifiedBy,Null ModifiedDate,Null Version,1 Status,@EntityId As EntityId,0 IsEntity,Null DateOfCessation,Null Docstatus,Null IsPrimary,
					Null IsCessation,NUll ReasonForCessation,Null DisqualifiedReasons,Null DisqualifiedReasonsSubsection,Null State,0 IsTemporary,Null IsReminder
					 from /*[dbo].[BR_Concate_New_Table_Devbackup] cc
					 inner join */dbo.[BR_New_CompanyDetails_DevBackup] /*cd on cc.[Registration No]=cd.[Company No#] */
					where  Auditor<>'NA'  and [Company No#] is not null and [Company No#]=@RegistrationNo and [Entity Name]=@EntityName and 
					Auditor=@AuditorContactName and Coalesce([Identification No],'Null')=@AuditorIDno  --and Position=@Position
									   					 				  				  
					If   Not Exists (Select Distinct id from  Boardroom.GenericContactDesignation Where  GenericContactId=@GenericContactId and ContactId=@ContactId and EntityId=@EntityId and Position=@Position)
					BEGIN
					     set @GenericContactDesignationId=null

						set @GenericContactDesignationId=NEWID()

						Insert into  Boardroom.GenericContactDesignation
						(Id,CompanyId,ContactId,GenericContactId,EntityId,Type,Position,DateofAppointment,DateofCessation,ReasonforCessation,DisqualifiedReasons
						,DisqualifiedReasonsSubsection,Remarks,RecOrder,UserCreated,CreatedDate,ModifiedBy,ModifiedDate,Version
						,Status,ShortCode,CommencementDate,CorporateRepresentative,AlternateFor,NominatedBy,IsRegistrableController,IsSignificantInterest
						,IsSignificantControl,Sort,Reason)
						
						select   TOp 1 @GenericContactDesignationId AS Id,@companyId CompanyId,@ContactId ContactId,@GenericContactId GenericContactId,@EntityId EntityId,
						NUll AS  Type,Position AS Position,CONVERT(VARCHAR(10), [auditor appt date], 110)  DateofAppointment ,Null DateofCessation,Null ReasonforCessation,Null DisqualifiedReasons,
						NUll DisqualifiedReasonsSubsection,Null Remarks,(select Max(RecOrder)+1 from Boardroom.GenericContactDesignation) RecOrder,'System' UserCreated,GETUTCDATE() CreatedDate,Null ModifiedBy,Null ModifiedDate,
						Null Version,1 Status,(Select ShortCode From Boardroom.ContactMapping Where Category=@Category And Position='Auditor' And Status=1) ShortCode,NUll CommencementDate,NUll CorporateRepresentative,NUll  AlternateFor,NUll NominatedBy,Null IsRegistrableController,
						Null IsSignificantInterest,Null IsSignificantControl,(Select Sort From Boardroom.ContactMapping Where Category=@Category And Position='Auditor' And Status=1) Sort,NUll Reason
						from /*[dbo].[BR_Concate_New_Table_Devbackup] cc
						inner join */dbo.[BR_New_CompanyDetails_DevBackup] /*cd on cc.[Registration No]=cd.[Company No#] */
						where  Auditor<>'NA'  and [Company No#]=@RegistrationNo and [Entity Name]=@EntityName and Auditor=@AuditorContactName and Coalesce([Identification No],'Null')=@AuditorIDno and Position=@Position 
					END
	
					
					Insert into [Common].[AddressBook]( Id,IsLocal,BlockHouseNo,Street,UnitNo,BuildingEstate,City,PostalCode,State,Country,Phone,Email,Website,Latitude,Longitude,RecOrder
					,Remarks,UserCreated,CreatedDate,ModifiedBy,ModifiedDate,Version,Status,DocumentId ) 
					
					select Top 1 @AddressbookId Id,1 AS IsLocal,[Auditor  Block/House No] BlockHouseNo,[Auditor  Street] AS Street,[Auditor Level & Unit no] UnitNo,[Auditor Building] AS BuildingEstate,[Auditor Country] AS City,
					[Auditor Postal Code] PostalCode,Country State,Country AS Country,Null Phone,Null Email,Null Website,Null Latitude,Null Longitude,NUll RecOrder,
					Null Remarks,'System' UserCreated,GETUTCDATE() AS CreatedDate,Null ModifiedBy,Null ModifiedDate,Null Version,1 AS Status,Null DocumentId
					from dbo.[BR_New_CompanyDetails_DevBackup] where Auditor=@AuditorContactName and Coalesce([Identification No],'NUll')=@AuditorIDno and [Company No#]=@RegistrationNo
					-------[Common].[Addresses]---
					
					insert into [Common].[Addresses](Id,AddSectionType,AddType,AddTypeId,AddTypeIdInt,AddressBookId,Status,DocumentId,EntityId,ScreenName,IsCurrentAddress,CompanyId,CopyId)
					
					select Top 1 NEWID()Id,[Auditor  Address Type] AS AddSectionType,'Client' AddType,@ContactId AddTypeId,Null AddTypeIdInt,@AddressbookId AddressBookId,
					1 Status,Null AS DocumentId,
					@EntityId EntityId,Null ScreenName,Null IsCurrentAddress,@CompanyId AS CompanyId,Null CopyId
					from dbo.[BR_New_CompanyDetails_DevBackup] where  Auditor=@AuditorContactName and Coalesce([Identification No],'NUll')=@AuditorIDno and [Company No#]=@RegistrationNo
					
					
					update Common.Addresses set AddSectionType='Registered Office Address' where CompanyId=@companyId and AddSectionType='REGISTERED OFFICE ADDRESS'

				END
				Else If  Exists (Select Distinct id from  Boardroom.Contacts Where GenericContactId=@GenericContactId  and EntityId=@EntityId and CompanyId=@companyId)
				BEGIN
				 
					SET @AuditContactid=Null
					SET @AuditContactid=(Select Distinct id from  Boardroom.Contacts Where GenericContactId=@GenericContactId  and EntityId=@EntityId and CompanyId=@companyId)

					If   Not Exists (Select Distinct id from  Boardroom.GenericContactDesignation Where  GenericContactId=@GenericContactId and ContactId=@AuditContactid and EntityId=@EntityId and Position=@Position  and Type=@Category )
					BEGIN
				
						Insert into  Boardroom.GenericContactDesignation
						(Id,CompanyId,ContactId,GenericContactId,EntityId,Type,Position,DateofAppointment,DateofCessation,ReasonforCessation,DisqualifiedReasons
						,DisqualifiedReasonsSubsection,Remarks,RecOrder,UserCreated,CreatedDate,ModifiedBy,ModifiedDate,Version
						,Status,ShortCode,CommencementDate,CorporateRepresentative,AlternateFor,NominatedBy,IsRegistrableController,IsSignificantInterest
						,IsSignificantControl,Sort,Reason)
						
						select   TOp 1 NewId() AS Id,@companyId CompanyId,@AuditContactid ContactId,@GenericContactId GenericContactId,@EntityId EntityId,
						NUll AS  Type,Position AS Position,CONVERT(VARCHAR(10), [auditor appt date], 110)  DateofAppointment ,Null DateofCessation,Null ReasonforCessation,Null DisqualifiedReasons,
						NUll DisqualifiedReasonsSubsection,Null Remarks,(select Max(RecOrder)+1 from Boardroom.GenericContactDesignation) RecOrder,'System' UserCreated,GETUTCDATE() CreatedDate,Null ModifiedBy,Null ModifiedDate,
						Null Version,1 Status,(Select ShortCode From Boardroom.ContactMapping Where Category=@Category And Position='Auditor' And Status=1) ShortCode,NUll CommencementDate,NUll CorporateRepresentative,NUll  AlternateFor,NUll NominatedBy,Null IsRegistrableController,
						Null IsSignificantInterest,Null IsSignificantControl,(Select Sort From Boardroom.ContactMapping Where Category=@Category And Position='Auditor' And Status=1) Sort,NUll Reason
						from /*[dbo].[BR_Concate_New_Table_Devbackup] cc
						inner join */dbo.[BR_New_CompanyDetails_DevBackup] /*cd on cc.[Registration No]=cd.[Company No#] */
						where  Auditor<>'NA'  and [Company No#]=@RegistrationNo and [Entity Name]=@EntityName and Auditor=@AuditorContactName and Coalesce([Identification No],'NUll')=@AuditorIDno and Position=@Position 
					END
					
				 END

			    Fetch next from Contact Into @AuditorContactName,@AuditorIDno,@RegistrationNo,@EntityName,@Position,@Category
				
			END
			Close Contact
			Deallocate Contact





----------------------------------------------------------------------1
    end 
	Else IF Exists (Select Distinct id from  Boardroom.GenericContact Where Name=@AuditorContactName  and Coalesce(IDNumber,'NUll')=Coalesce(@AuditorIDno,'NUll') and CompanyId=@companyId)
	Begin
		Set @GenericContactId=Null
		Set @GenericContactId=(Select Distinct id from  Boardroom.GenericContact Where Name=@AuditorContactName  and Coalesce(IDNumber,'NUll')=Coalesce(@AuditorIDno,'NUll') and CompanyId=@companyId)
	
		Declare Contact Cursor For
			select Distinct Auditor,[Identification No],[Company No#],cd.[Entity Name],cd.Position,Type from dbo.[BR_New_CompanyDetails_DevBackup] cd
			inner join [dbo].[BR_Concate_New_Table_Devbackup]  cc on cd.[Company No#]=cc.[Registration No]
			where Auditor<>'NA'  and Auditor =@AuditorContactName and  Coalesce([Identification No],'Null')=Coalesce(@AuditorIDno,'NUll') --and cd.[Entity Name]=@EntityName
			OPEN Contact
			FETCH NEXT FROM Contact INTO @AuditorContactName,@AuditorIDno,@RegistrationNo,@EntityName,@Position,@Category
			WHILE @@FETCH_STATUS = 0
			BEGIN
		

				set @EntityId=Null
				Set @EntityId =(Select Distinct Id from  Common.EntityDetail Where UEN=@RegistrationNo and CompanyId=@companyId)

				If  Not Exists (Select Distinct id from  Boardroom.Contacts Where GenericContactId=@GenericContactId and CompanyId=@companyId and EntityId=@EntityId)
				 BEGIN
				
					 set @ContactId=NewId()
					 set @AddressbookId =NEWID()
					 

					Insert into Boardroom.Contacts(Id,CompanyId,GenericContactId,Type,Remarks,RecOrder,UserCreated,CreatedDate,ModifiedBy,ModifiedDate,Version,Status,EntityId,IsEntity,
					DateOfCessation,Docstatus,IsPrimary,IsCessation,ReasonForCessation,DisqualifiedReasons,DisqualifiedReasonsSubsection,State,IsTemporary,IsReminder)
         
					select TOP 1 @ContactId As Id,@companyId As CompanyId,@GenericContactId AsGenericContactId,'Client' Type,Null Remarks,Null RecOrder,'System' As UserCreated,GETUTCDATE() CreatedDate,
					Null ModifiedBy,Null ModifiedDate,Null Version,1 Status,@EntityId As EntityId,0 IsEntity,Null DateOfCessation,Null Docstatus,Null IsPrimary,
					Null IsCessation,NUll ReasonForCessation,Null DisqualifiedReasons,Null DisqualifiedReasonsSubsection,Null State,0 IsTemporary,Null IsReminder
					 from /*[dbo].[BR_Concate_New_Table_Devbackup] cc
					 inner join */dbo.[BR_New_CompanyDetails_DevBackup] /*cd on cc.[Registration No]=cd.[Company No#] */
					where  Auditor<>'NA'  and [Company No#] is not null and [Company No#]=@RegistrationNo and [Entity Name]=@EntityName and 
					Auditor=@AuditorContactName and [Identification No]=@AuditorIDno  --and Position=@Position
									   					 				  				  
					If   Not Exists (Select Distinct id from  Boardroom.GenericContactDesignation Where  GenericContactId=@GenericContactId and ContactId=@ContactId and EntityId=@EntityId  and Position=@Position)
					BEGIN
					
						set @GenericContactDesignationId=NEWID()
						Insert into  Boardroom.GenericContactDesignation
						(Id,CompanyId,ContactId,GenericContactId,EntityId,Type,Position,DateofAppointment,DateofCessation,ReasonforCessation,DisqualifiedReasons
						,DisqualifiedReasonsSubsection,Remarks,RecOrder,UserCreated,CreatedDate,ModifiedBy,ModifiedDate,Version
						,Status,ShortCode,CommencementDate,CorporateRepresentative,AlternateFor,NominatedBy,IsRegistrableController,IsSignificantInterest
						,IsSignificantControl,Sort,Reason)
						
						select   TOp 1 @GenericContactDesignationId AS Id,@companyId CompanyId,@ContactId ContactId,@GenericContactId GenericContactId,@EntityId EntityId,
						NUll AS  Type,Position AS Position,CONVERT(VARCHAR(10), [auditor appt date], 110)  DateofAppointment ,Null DateofCessation,Null ReasonforCessation,Null DisqualifiedReasons,
						NUll DisqualifiedReasonsSubsection,Null Remarks,(select Max(RecOrder)+1 from Boardroom.GenericContactDesignation) RecOrder,'System' UserCreated,GETUTCDATE() CreatedDate,Null ModifiedBy,Null ModifiedDate,
						Null Version,1 Status,(Select ShortCode From Boardroom.ContactMapping Where Category=@Category And Position='Auditor' And Status=1) ShortCode,NUll CommencementDate,NUll CorporateRepresentative,NUll  AlternateFor,NUll NominatedBy,Null IsRegistrableController,
						Null IsSignificantInterest,Null IsSignificantControl,(Select Sort From Boardroom.ContactMapping Where Category=@Category And Position='Auditor' And Status=1) Sort,NUll Reason
						from /*[dbo].[BR_Concate_New_Table_Devbackup] cc
						inner join */dbo.[BR_New_CompanyDetails_DevBackup] /*cd on cc.[Registration No]=cd.[Company No#] */
						where  Auditor<>'NA'  and [Company No#]=@RegistrationNo and [Entity Name]=@EntityName and Auditor=@AuditorContactName and [Identification No]=@AuditorIDno --and Position=@Position 
					END
	
				
					Insert into [Common].[AddressBook]( Id,IsLocal,BlockHouseNo,Street,UnitNo,BuildingEstate,City,PostalCode,State,Country,Phone,Email,Website,Latitude,Longitude,RecOrder
					,Remarks,UserCreated,CreatedDate,ModifiedBy,ModifiedDate,Version,Status,DocumentId ) 
					
					select Top 1 @AddressbookId Id,1 AS IsLocal,[Auditor  Block/House No] BlockHouseNo,[Auditor  Street] AS Street,[Auditor Level & Unit no] UnitNo,[Auditor Building] AS BuildingEstate,[Auditor Country] AS City,
					[Auditor Postal Code] PostalCode,Country State,Country AS Country,Null Phone,Null Email,Null Website,Null Latitude,Null Longitude,NUll RecOrder,
					Null Remarks,'System' UserCreated,GETUTCDATE() AS CreatedDate,Null ModifiedBy,Null ModifiedDate,Null Version,1 AS Status,Null DocumentId
					from dbo.[BR_New_CompanyDetails_DevBackup] where Auditor=@AuditorContactName and Coalesce([Identification No],'NUll')=@AuditorIDno and [Company No#]=@RegistrationNo
					-------[Common].[Addresses]---
					
					insert into [Common].[Addresses](Id,AddSectionType,AddType,AddTypeId,AddTypeIdInt,AddressBookId,Status,DocumentId,EntityId,ScreenName,IsCurrentAddress,CompanyId,CopyId)
					
					
					select Top 1 NEWID()Id,[Auditor  Address Type] AS AddSectionType,'Client' AddType,@ContactId AddTypeId,Null AddTypeIdInt,@AddressbookId AddressBookId,
					1 Status,Null AS DocumentId,
					@EntityId EntityId,Null ScreenName,Null IsCurrentAddress,@CompanyId AS CompanyId,Null CopyId
					from dbo.[BR_New_CompanyDetails_DevBackup] where  Auditor=@AuditorContactName and Coalesce([Identification No],'NUll')=@AuditorIDno and [Company No#]=@RegistrationNo
					
					
					update Common.Addresses set AddSectionType='Registered Office Address' where CompanyId=@companyId and AddSectionType='REGISTERED OFFICE ADDRESS'

				END
				Else If  Exists (Select Distinct id from  Boardroom.Contacts Where GenericContactId=@GenericContactId  and EntityId=@EntityId and CompanyId=@companyId)
				BEGIN
				
					SET @AuditContactid=Null
					SET @AuditContactid=(Select Distinct id from  Boardroom.Contacts Where GenericContactId=@GenericContactId  and EntityId=@EntityId and CompanyId=@companyId)

					If   Not Exists (Select Distinct id from  Boardroom.GenericContactDesignation Where  GenericContactId=@GenericContactId and ContactId=@AuditContactid and EntityId=@EntityId and Position=@Position and Type=@Category )
					BEGIN
					
						Insert into  Boardroom.GenericContactDesignation
						(Id,CompanyId,ContactId,GenericContactId,EntityId,Type,Position,DateofAppointment,DateofCessation,ReasonforCessation,DisqualifiedReasons
						,DisqualifiedReasonsSubsection,Remarks,RecOrder,UserCreated,CreatedDate,ModifiedBy,ModifiedDate,Version
						,Status,ShortCode,CommencementDate,CorporateRepresentative,AlternateFor,NominatedBy,IsRegistrableController,IsSignificantInterest
						,IsSignificantControl,Sort,Reason)
						
						select   TOp 1 NewId() AS Id,@companyId CompanyId,@AuditContactid ContactId,@GenericContactId GenericContactId,@EntityId EntityId,
						NUll AS  Type,Position AS Position,CONVERT(VARCHAR(10), [auditor appt date], 110)  DateofAppointment ,Null DateofCessation,Null ReasonforCessation,Null DisqualifiedReasons,
						NUll DisqualifiedReasonsSubsection,Null Remarks,(select Max(RecOrder)+1 from Boardroom.GenericContactDesignation) RecOrder,'System' UserCreated,GETUTCDATE() CreatedDate,Null ModifiedBy,Null ModifiedDate,
						Null Version,1 Status,(Select ShortCode From Boardroom.ContactMapping Where Category=@Category And Position='Auditor' And Status=1) ShortCode,NUll CommencementDate,NUll CorporateRepresentative,NUll  AlternateFor,NUll NominatedBy,Null IsRegistrableController,
						Null IsSignificantInterest,Null IsSignificantControl,(Select Sort From Boardroom.ContactMapping Where Category=@Category And Position='Auditor' And Status=1) Sort,NUll Reason
						from /*[dbo].[BR_Concate_New_Table_Devbackup] cc
						inner join */dbo.[BR_New_CompanyDetails_DevBackup] /*cd on cc.[Registration No]=cd.[Company No#] */
						where  Auditor<>'NA'  and [Company No#]=@RegistrationNo and [Entity Name]=@EntityName and Auditor=@AuditorContactName and [Identification No]=@AuditorIDno and Position=@Position 
					END
					
				 END

			    Fetch next from Contact Into @AuditorContactName,@AuditorIDno,@RegistrationNo,@EntityName,@Position,@Category 
				
			END
			Close Contact
			Deallocate Contact

	End
   Fetch next from GenericContact Into @AuditorContactName,@AuditorIDno
				
 END
 Close GenericContact
 Deallocate GenericContact

END 
GO
