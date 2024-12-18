USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[BR_Migartion_Contact_SP_New_Devbackup]    Script Date: 16-12-2024 9.20.10 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE Procedure  [dbo].[BR_Migartion_Contact_SP_New_Devbackup]
@CompanyId BigInt
AS
BEGIN
-- exec [dbo].[BR_Migartion_Contact_SP_New] 1236

Declare --@companyId int,
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
		@ContactName Nvarchar(max),
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
		@IDno NVARCHAR(MAX) ,
		@Position nvarchar(max),
		@Sort NVARCHAR(MAX) ,
		@Category NVARCHAR(MAX),
		@Err_Msg Nvarchar(Max)
 
 
	Begin Transaction
	Begin Try
		Declare GenericContact Cursor For
        select  distinct Contact , [ID no],[ID Type]  from  [dbo].[BR_Concate_New_Devbackup] where  [Registration No] is not null 
		OPEN GenericContact
        FETCH NEXT FROM GenericContact INTO @ContactName,@IDno,@IdType
	    WHILE @@FETCH_STATUS = 0
        BEGIN

			If  NOT Exists (Select Distinct id from  Boardroom.GenericContact Where Name=@ContactName  and Coalesce(IDNumber,'NULL')=Coalesce(@IDno,'NULL') and Coalesce(IDType,'NULL') =COALESCE(@IdType,'NULL') and CompanyId=@companyId   )
			BEGIN

				set @GenericContactId=NewId()
				Set @PerEmailJson =(Select Distinct 'Email' As 'key',Email As 'value' From  [dbo].[BR_Concate_New_Devbackup] Where Contact=@ContactName and Email is not null   and Coalesce([ID no],'NULL')=Coalesce(@IDno,'NULL') and Coalesce([Id Type],'NULL') =COALESCE(@IdType,'NULL')  For Json Auto)
				Set @PerMobileJson =(Select Distinct 'Mobile' As 'key',[Mobile Phone No#] As 'value' From  [dbo].[BR_Concate_New_Devbackup] Where Contact=@ContactName and [Mobile Phone No#] is not null  And Coalesce([ID no],'NULL')=Coalesce(@IDno,'NULL') and Coalesce([Id Type],'NULL') =COALESCE(@IdType,'NULL')  For Json Auto)
					
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
				,Suffix,CorporateEntityRegister,Remarks,RecOrder,UserCreated,CreatedDate,ModifiedBy,ModifiedDate,Version,Status,IsMainContact,Type,TypeId,ShortName,IsNoProfile,CompanyNo)


				select Distinct top 1   @GenericContactId AS Id,@companyId AS CompanyId,Category Category,Salutation AS Salutation,Contact Name,
				case when [ID Type]='FIN' then 'FIN'
				when [ID Type]='NRIC (Citizen)' then 'NRIC (Citizen)' 
				when [ID Type]='NRIC (Permanent Resident)' then 'NRIC (Permanent Citizen)' 
				when [ID Type]='Passport' then 'Passport/Others' Else [ID Type] end as IDType,[ID no] IDNumber,[dbo].[InitCap](Nationality) AS  Nationality,Gender Gender,[Date of Birth] DateOfBirth,
  		--		Case when [Country of Birth]='UNITED STATES OF AMERICA' then 'United States'
				--when [Country of Birth]='Cyprus (Limassol)' then 'Cyprus' 
				--when [Country of Birth]='China' then 'Peoples Republic Of China' else
				 [dbo].[InitCap]([Country of Birth]) AS CountryOfBirth,Null CountryOfResidence,@PerJsondata Communication,[dbo].[InitCap]([Place of Incorporation]) AS CountryofIncorporation ,null AS CompanyType ,null AS Suffix,
				Null CorporateEntityRegister,Null Remarks,Null RecOrder,'System' UserCreated,GETUTCDATE() CreatedDate,null ModifiedBy,null ModifiedDate,Null Version,1 Status,
				Null IsMainContact,'Client' Type,null TypeId, dbo.fnFirsties(Contact) as  ShortName ,Null IsNoProfile,[Company No]
				from [dbo].[BR_Concate_New_Devbackup] 
				where [Registration No] is not null and Contact=@ContactName and [ID no]=@IDno and [Id Type] =@IdType --and Position=@Position

				Declare Contact Cursor For
				select Distinct [Registration No] AS RegistrationNo,[Entity Name],Contact , [ID no],[ID Type],Category,Position  from  [dbo].[BR_Concate_New_Devbackup]
				 where [Registration No] is not null and Contact =@ContactName and  Coalesce([ID no],'NULL')=Coalesce(@IDno,'NULL') and Coalesce([ID Type],'NULL')=Coalesce(@IdType,'NULL')
				OPEN Contact
				FETCH NEXT FROM Contact INTO @RegistrationNo,@EntityName,@ContactName,@IDno,@IdType,@Category,@Position
				WHILE @@FETCH_STATUS = 0
				BEGIN
					Set @EntityId=Null
					Set @EntityId =(Select Distinct Id from  Common.EntityDetail Where UEN=@RegistrationNo and CompanyId=@companyId)
					If   not Exists (Select Distinct id from  Boardroom.Contacts Where GenericContactId=@GenericContactId  and EntityId=@EntityId And CompanyId=@CompanyId)
					BEGIN
		 				set @ContactId=NewId()
						set @AddressbookId =NEWID()
						Insert into Boardroom.Contacts(Id,CompanyId,GenericContactId,Type,Remarks,RecOrder,UserCreated,CreatedDate,ModifiedBy,ModifiedDate,Version,Status,EntityId,IsEntity,
						DateOfCessation,Docstatus,IsPrimary,IsCessation,ReasonForCessation,DisqualifiedReasons,DisqualifiedReasonsSubsection,State,IsTemporary,IsReminder)
						
						select Distinct @ContactId Id,@companyId CompanyId,@GenericContactId GenericContactId,'Client' Type,Null Remarks,Null RecOrder,'System' As UserCreated,GETUTCDATE() CreatedDate,
						Null ModifiedBy,Null ModifiedDate,Null Version,1 Status,@EntityId EntityId,0 IsEntity,Null DateOfCessation,Null Docstatus,Null IsPrimary,
						Null IsCessation,NUll ReasonForCessation,Null DisqualifiedReasons,Null DisqualifiedReasonsSubsection,Null State,0 IsTemporary,Null IsReminder
						from [dbo].[BR_Concate_New_Devbackup] 
						where  [Registration No] is not null and [Registration No]=@RegistrationNo and [Entity Name]=@EntityName and Contact=@ContactName and [ID no]=@IDno and [Id Type] =@IdType --and Position=@Position

						Insert into  Boardroom.GenericContactDesignation(Id,CompanyId,ContactId,GenericContactId,EntityId,Type,Position,DateofAppointment,DateofCessation,ReasonforCessation,DisqualifiedReasons
																,DisqualifiedReasonsSubsection,Remarks,RecOrder,UserCreated,CreatedDate,ModifiedBy,ModifiedDate,Version
																,Status,ShortCode,CommencementDate,CorporateRepresentative,AlternateFor,NominatedBy,IsRegistrableController,IsSignificantInterest
																,IsSignificantControl,Sort,Reason)

						select   Top 1 NEWID() AS Id,@companyId CompanyId,@ContactId ContactId,@GenericContactId GenericContactId,@EntityId EntityId,
						NUll AS  Type,Position AS Position,CONVERT(VARCHAR(10), [Appointment Date], 110)  DateofAppointment ,Null DateofCessation,Null ReasonforCessation,Null DisqualifiedReasons,
						NUll DisqualifiedReasonsSubsection,Null Remarks,(select Max(RecOrder)+1 from Boardroom.GenericContactDesignation) As RecOrder,'System' UserCreated,GETUTCDATE() CreatedDate,Null ModifiedBy,Null ModifiedDate,
						Null Version,1 Status,(Select ShortCode From Boardroom.ContactMapping Where Category=@Category And Position=@Position And Status=1) ShortCode,NUll CommencementDate,NUll CorporateRepresentative,NUll  AlternateFor,NUll NominatedBy,Null IsRegistrableController,
						Null IsSignificantInterest,Null IsSignificantControl,(Select Sort From Boardroom.ContactMapping Where Category=@Category And Position=@Position And Status=1) Sort,NUll Reason
						From [dbo].[BR_Concate_New_Devbackup]
						where  [Registration No] is not null and [Registration No]=@RegistrationNo and [Entity Name]=@EntityName and Contact=@ContactName and Coalesce([ID no],'NULL')=Coalesce(@IDno,'NULL') and COALESCE([Id Type],'NULL') =COALESCE(@IdType,'NULL') and Coalesce(Position,'NULL')=Coalesce(@Position ,'NULL')


						Insert into [Common].[AddressBook]( Id,IsLocal,BlockHouseNo,Street,UnitNo,BuildingEstate,City,PostalCode,State,Country,Phone,Email,Website,Latitude,Longitude,RecOrder
															,Remarks,UserCreated,CreatedDate,ModifiedBy,ModifiedDate,Version,Status,DocumentId ) 


						select Top 1 @AddressbookId Id,Case when [local/foreign Address]='Local Address' then  1
						when [local/foreign Address]='Foreign Address' then  0 end AS IsLocal,[Block/House No] BlockHouseNo,
						
						Case when Street Is Not null then Street Else CAse when [local/foreign Address]='Foreign Address' then [Address Line2] End  ENd  AS Street,
						Case when [Level & Unit no] Is Not Null then [Level & Unit no] Else Case when [local/foreign Address]='Foreign Address' then [Address Line1] End  ENd as UnitNo,Building AS BuildingEstate,Null AS City,
						cast([Postal Code]as nvarchar(100)) PostalCode,Null State,Country AS Country,[Mobile Phone No#] Phone,Email Email,Null Website,Null Latitude,Null Longitude,NUll RecOrder,
						Null Remarks,'System' UserCreated,GETUTCDATE() AS CreatedDate,Null ModifiedBy,Null ModifiedDate,Null Version,1 AS Status,Null DocumentId
						from [dbo].[BR_Concate_New_Devbackup] 
						where  [Registration No] is not null and [Registration No]=@RegistrationNo and [Entity Name]=@EntityName and Contact=@ContactName and Coalesce([ID no],'NULL')=Coalesce(@IDno,'NULL') and Coalesce([Id Type],'NULL') =COALESCE(@IdType,'NULL') and Position=@Position
						--group by [Block/House No] ,[Address Line2] ,[Address Line1] ,Building ,Country ,[Postal Code],Country ,Country ,[Mobile Phone No#] ,Email,[local/foreign Address],Street,[Level & Unit no]

						-------[Common].[Addresses]---



						insert into [Common].[Addresses](Id,AddSectionType,AddType,AddTypeId,AddTypeIdInt,AddressBookId,Status,DocumentId,EntityId,ScreenName,IsCurrentAddress,CompanyId,CopyId)
						
						select Top 1 NEWID()Id, [Address Type] AS AddSectionType,'Client' AddType,@ContactId AddTypeId,Null AddTypeIdInt,@AddressbookId AddressBookId,
						1 Status,Null AS DocumentId,@EntityId EntityId,Null ScreenName,Null IsCurrentAddress,@companyId AS CompanyId,Null CopyId
						from [dbo].[BR_Concate_New_Devbackup] 
						where  [Registration No] is not null and [Registration No]=@RegistrationNo and [Entity Name]=@EntityName and Contact=@ContactName and Coalesce([ID no],'NULL')=Coalesce(@IDno,'NULL') and COALESCE([Id Type],'NULL') =COALESCE(@IdType,'NULL') 
						And Position=@Position
						Group by [Address Type]
						
						update Common.Addresses set AddSectionType='Registered Office Address' where CompanyId=@companyId and AddSectionType='REGISTERED OFFICE ADDRESS'
					End
					Else if Exists (Select Distinct id from  Boardroom.Contacts Where GenericContactId=@GenericContactId  and EntityId=@EntityId And CompanyId=@CompanyId)
					Begin 
						If Not Exists (Select Distinct id from  Boardroom.GenericContactDesignation Where  GenericContactId=@GenericContactId and ContactId=@ContactId and EntityId=@EntityId and Position=@Position  )
						BEGIN
							Insert into  Boardroom.GenericContactDesignation(Id,CompanyId,ContactId,GenericContactId,EntityId,Type,Position,DateofAppointment,DateofCessation,ReasonforCessation,DisqualifiedReasons
																			,DisqualifiedReasonsSubsection,Remarks,RecOrder,UserCreated,CreatedDate,ModifiedBy,ModifiedDate,Version
																			,Status,ShortCode,CommencementDate,CorporateRepresentative,AlternateFor,NominatedBy,IsRegistrableController,IsSignificantInterest
																			,IsSignificantControl,Sort,Reason)

							Select   Top 1 NEWID() AS Id,@companyId CompanyId,@ContactId ContactId,@GenericContactId GenericContactId,@EntityId EntityId,
							NUll AS  Type,Position AS Position,CONVERT(VARCHAR(10), [Appointment Date], 110)  DateofAppointment ,Null DateofCessation,Null ReasonforCessation,Null DisqualifiedReasons,
							NUll DisqualifiedReasonsSubsection,Null Remarks,(select Max(RecOrder)+1 from Boardroom.GenericContactDesignation) RecOrder,'System' UserCreated,GETUTCDATE() CreatedDate,Null ModifiedBy,Null ModifiedDate,
							Null Version,1 Status,(Select ShortCode From Boardroom.ContactMapping Where Category=@Category And Position=@Position And Status=1) ShortCode,NUll CommencementDate,NUll CorporateRepresentative,NUll  AlternateFor,NUll NominatedBy,Null IsRegistrableController,
							Null IsSignificantInterest,Null IsSignificantControl,(Select Sort From Boardroom.ContactMapping Where Category=@Category And Position=@Position And Status=1) Sort,NUll Reason
							From [dbo].[BR_Concate_New_Devbackup]
							where  [Registration No] is not null and [Registration No]=@RegistrationNo and [Entity Name]=@EntityName and Contact=@ContactName and Coalesce([ID no],'NULL')=Coalesce(@IDno,'NULL') and Coalesce([Id Type],'NULL') =Coalesce(@IdType,'NULL') and Coalesce(Position,'NULL')=Coalesce(@Position,'NULL')
						END
			
					END
	
					Fetch next from Contact Into @RegistrationNo,@EntityName,@ContactName,@IDno,@IdType,@Category,@Position
				
				END
				Close Contact
				Deallocate Contact

			End
			Else IF Exists (Select Distinct id from  Boardroom.GenericContact Where Name=@ContactName  and Coalesce(IDNumber,'NULL')=Coalesce(@IDno,'NULL') and Coalesce(IDType,'NULL') =COALESCE(@IdType,'NULL') and CompanyId=@companyId )
			Begin
				Set @GenericContactId=Null
				Set @GenericContactId=(Select Distinct id from  Boardroom.GenericContact Where Name=@ContactName  and Coalesce(IDNumber,'NULL')=Coalesce(@IDno,'NULL') and Coalesce(IDType,'NULL') =COALESCE(@IdType,'NULL') and CompanyId=@companyId )
								Declare Contact Cursor For
				select Distinct [Registration No] AS RegistrationNo,[Entity Name],Contact , [ID no],[ID Type],Category,Position  from  [dbo].[BR_Concate_New_Devbackup]
				 where [Registration No] is not null and Contact =@ContactName and  Coalesce([ID no],'NULL')=Coalesce(@IDno,'NULL') and Coalesce([ID Type],'NULL')=Coalesce(@IdType,'NULL')
				OPEN Contact
				FETCH NEXT FROM Contact INTO @RegistrationNo,@EntityName,@ContactName,@IDno,@IdType,@Category,@Position
				WHILE @@FETCH_STATUS = 0
				BEGIN
					Set @EntityId=Null
					Set @EntityId =(Select Distinct Id from  Common.EntityDetail Where UEN=@RegistrationNo and CompanyId=@companyId)
					If   not Exists (Select Distinct id from  Boardroom.Contacts Where GenericContactId=@GenericContactId  and EntityId=@EntityId And CompanyId=@CompanyId)
					BEGIN
		 				set @ContactId=NewId()
						set @AddressbookId =NEWID()
						Insert into Boardroom.Contacts(Id,CompanyId,GenericContactId,Type,Remarks,RecOrder,UserCreated,CreatedDate,ModifiedBy,ModifiedDate,Version,Status,EntityId,IsEntity,
						DateOfCessation,Docstatus,IsPrimary,IsCessation,ReasonForCessation,DisqualifiedReasons,DisqualifiedReasonsSubsection,State,IsTemporary,IsReminder)
						
						select Distinct @ContactId Id,@companyId CompanyId,@GenericContactId GenericContactId,'Client' Type,Null Remarks,Null RecOrder,'System' As UserCreated,GETUTCDATE() CreatedDate,
						Null ModifiedBy,Null ModifiedDate,Null Version,1 Status,@EntityId EntityId,0 IsEntity,Null DateOfCessation,Null Docstatus,Null IsPrimary,
						Null IsCessation,NUll ReasonForCessation,Null DisqualifiedReasons,Null DisqualifiedReasonsSubsection,Null State,0 IsTemporary,Null IsReminder
						from [dbo].[BR_Concate_New_Devbackup] 
						where  [Registration No] is not null and [Registration No]=@RegistrationNo and [Entity Name]=@EntityName and Contact=@ContactName and [ID no]=@IDno and [Id Type] =@IdType --and Position=@Position

						Insert into  Boardroom.GenericContactDesignation(Id,CompanyId,ContactId,GenericContactId,EntityId,Type,Position,DateofAppointment,DateofCessation,ReasonforCessation,DisqualifiedReasons
																,DisqualifiedReasonsSubsection,Remarks,RecOrder,UserCreated,CreatedDate,ModifiedBy,ModifiedDate,Version
																,Status,ShortCode,CommencementDate,CorporateRepresentative,AlternateFor,NominatedBy,IsRegistrableController,IsSignificantInterest
																,IsSignificantControl,Sort,Reason)

						select   Top 1 NEWID() AS Id,@companyId CompanyId,@ContactId ContactId,@GenericContactId GenericContactId,@EntityId EntityId,
						NUll AS  Type,Position AS Position,CONVERT(VARCHAR(10), [Appointment Date], 110)  DateofAppointment ,Null DateofCessation,Null ReasonforCessation,Null DisqualifiedReasons,
						NUll DisqualifiedReasonsSubsection,Null Remarks,(select Max(RecOrder)+1 from Boardroom.GenericContactDesignation) As RecOrder,'System' UserCreated,GETUTCDATE() CreatedDate,Null ModifiedBy,Null ModifiedDate,
						Null Version,1 Status,(Select ShortCode From Boardroom.ContactMapping Where Category=@Category And Position=@Position And Status=1) ShortCode,NUll CommencementDate,NUll CorporateRepresentative,NUll  AlternateFor,NUll NominatedBy,Null IsRegistrableController,
						Null IsSignificantInterest,Null IsSignificantControl,(Select Sort From Boardroom.ContactMapping Where Category=@Category And Position=@Position And Status=1) Sort,NUll Reason
						From [dbo].[BR_Concate_New_Devbackup]
						where  [Registration No] is not null and [Registration No]=@RegistrationNo and [Entity Name]=@EntityName and Contact=@ContactName and Coalesce([ID no],'NULL')=Coalesce(@IDno,'NULL') and COALESCE([Id Type],'NULL') =COALESCE(@IdType,'NULL') and Coalesce(Position,'NULL')=Coalesce(@Position ,'NULL')


						Insert into [Common].[AddressBook]( Id,IsLocal,BlockHouseNo,Street,UnitNo,BuildingEstate,City,PostalCode,State,Country,Phone,Email,Website,Latitude,Longitude,RecOrder
															,Remarks,UserCreated,CreatedDate,ModifiedBy,ModifiedDate,Version,Status,DocumentId ) 


						select Top 1 @AddressbookId Id,Case when [local/foreign Address]='Local Address' then  1
						when [local/foreign Address]='Foreign Address' then  0 end AS IsLocal,[Block/House No] BlockHouseNo,
						
						Case when Street Is Not null then Street Else CAse when [local/foreign Address]='Foreign Address' then [Address Line2] End  ENd  AS Street,
						Case when [Level & Unit no] Is Not Null then [Level & Unit no] Else Case when [local/foreign Address]='Foreign Address' then [Address Line1] End  ENd as UnitNo,Building AS BuildingEstate,Null AS City,
						cast([Postal Code]as nvarchar(100)) PostalCode,Null State,Country AS Country,[Mobile Phone No#] Phone,Email Email,Null Website,Null Latitude,Null Longitude,NUll RecOrder,
						Null Remarks,'System' UserCreated,GETUTCDATE() AS CreatedDate,Null ModifiedBy,Null ModifiedDate,Null Version,1 AS Status,Null DocumentId
						from [dbo].[BR_Concate_New_Devbackup] 
						where  [Registration No] is not null and [Registration No]=@RegistrationNo and [Entity Name]=@EntityName and Contact=@ContactName and Coalesce([ID no],'NULL')=Coalesce(@IDno,'NULL') and Coalesce([Id Type],'NULL') =COALESCE(@IdType,'NULL') and Position=@Position
						--group by [Block/House No] ,[Address Line2] ,[Address Line1] ,Building ,Country ,[Postal Code],Country ,Country ,[Mobile Phone No#] ,Email,[local/foreign Address],Street,[Level & Unit no]

						-------[Common].[Addresses]---



						insert into [Common].[Addresses](Id,AddSectionType,AddType,AddTypeId,AddTypeIdInt,AddressBookId,Status,DocumentId,EntityId,ScreenName,IsCurrentAddress,CompanyId,CopyId)
						
						select Top 1 NEWID()Id, [Address Type] AS AddSectionType,'Client' AddType,@ContactId AddTypeId,Null AddTypeIdInt,@AddressbookId AddressBookId,
						1 Status,Null AS DocumentId,@EntityId EntityId,Null ScreenName,Null IsCurrentAddress,@companyId AS CompanyId,Null CopyId
						from [dbo].[BR_Concate_New_Devbackup] 
						where  [Registration No] is not null and [Registration No]=@RegistrationNo and [Entity Name]=@EntityName and Contact=@ContactName and Coalesce([ID no],'NULL')=Coalesce(@IDno,'NULL') and COALESCE([Id Type],'NULL') =COALESCE(@IdType,'NULL') 
						And Position=@Position
						Group by [Address Type]
						
						update Common.Addresses set AddSectionType='Registered Office Address' where CompanyId=@companyId and AddSectionType='REGISTERED OFFICE ADDRESS'
					End
					Else if Exists (Select Distinct id from  Boardroom.Contacts Where GenericContactId=@GenericContactId  and EntityId=@EntityId And CompanyId=@CompanyId)
					Begin 
						If Not Exists (Select Distinct id from  Boardroom.GenericContactDesignation Where  GenericContactId=@GenericContactId and ContactId=@ContactId and EntityId=@EntityId and Position=@Position  )
						BEGIN
							Insert into  Boardroom.GenericContactDesignation(Id,CompanyId,ContactId,GenericContactId,EntityId,Type,Position,DateofAppointment,DateofCessation,ReasonforCessation,DisqualifiedReasons
																			,DisqualifiedReasonsSubsection,Remarks,RecOrder,UserCreated,CreatedDate,ModifiedBy,ModifiedDate,Version
																			,Status,ShortCode,CommencementDate,CorporateRepresentative,AlternateFor,NominatedBy,IsRegistrableController,IsSignificantInterest
																			,IsSignificantControl,Sort,Reason)

							Select   Top 1 NEWID() AS Id,@companyId CompanyId,@ContactId ContactId,@GenericContactId GenericContactId,@EntityId EntityId,
							NUll AS  Type,Position AS Position,CONVERT(VARCHAR(10), [Appointment Date], 110)  DateofAppointment ,Null DateofCessation,Null ReasonforCessation,Null DisqualifiedReasons,
							NUll DisqualifiedReasonsSubsection,Null Remarks,(select Max(RecOrder)+1 from Boardroom.GenericContactDesignation) RecOrder,'System' UserCreated,GETUTCDATE() CreatedDate,Null ModifiedBy,Null ModifiedDate,
							Null Version,1 Status,(Select ShortCode From Boardroom.ContactMapping Where Category=@Category And Position=@Position And Status=1) ShortCode,NUll CommencementDate,NUll CorporateRepresentative,NUll  AlternateFor,NUll NominatedBy,Null IsRegistrableController,
							Null IsSignificantInterest,Null IsSignificantControl,(Select Sort From Boardroom.ContactMapping Where Category=@Category And Position=@Position And Status=1) Sort,NUll Reason
							From [dbo].[BR_Concate_New_Devbackup]
							where  [Registration No] is not null and [Registration No]=@RegistrationNo and [Entity Name]=@EntityName and Contact=@ContactName and Coalesce([ID no],'NULL')=Coalesce(@IDno,'NULL') and Coalesce([Id Type],'NULL') =Coalesce(@IdType,'NULL') and Coalesce(Position,'NULL')=Coalesce(@Position,'NULL')
						END
			
					END
	
					Fetch next from Contact Into @RegistrationNo,@EntityName,@ContactName,@IDno,@IdType,@Category,@Position
				
				END
				Close Contact
				Deallocate Contact

			End
			Fetch next from GenericContact Into @ContactName,@IDno,@IdType
				
		END
		Close GenericContact
		Deallocate GenericContact
		Commit Transaction
	End Try
	Begin Catch
		RollBack;
		Set @Err_Msg=(Select ERROR_MESSAGE())
		RaisError(@Err_Msg,16,1);
	End Catch
End 
GO
