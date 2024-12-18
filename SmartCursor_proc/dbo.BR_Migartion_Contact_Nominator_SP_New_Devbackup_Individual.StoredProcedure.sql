USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[BR_Migartion_Contact_Nominator_SP_New_Devbackup_Individual]    Script Date: 16-12-2024 9.20.10 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- Exec [dbo].[BR_Migartion_Contact_Nominator_SP_New_Devbackup_Individual] 2659
CREATE  Procedure [dbo].[BR_Migartion_Contact_Nominator_SP_New_Devbackup_Individual]
--Declare 
 @CompanyId Bigint--=2659
AS
BEGIN
-- exec [dbo].[BR_Migartion_Contact_Nominator_SP_New] 1236

 Declare  /*@CompanyId int=1257,*/
		  @NominieGenericContactId uniqueidentifier,
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
		  @Nominator Nvarchar(max),
		  @IdType Nvarchar(max),
		  --@IdNumber Nvarchar(max),
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
		  @Category NVARCHAR(MAX) ,
		  @Nominator1  NVARCHAR(MAX),
		  @ContactName Nvarchar(500),
		  @GenericContactId Uniqueidentifier,
		  @ConIdNo Nvarchar(500),
		  @ConIdType  Nvarchar(500),
		  @Err_Msg Nvarchar(max)

		
Begin Transaction
Begin Try
		 Declare GenericContact Cursor For
         Select  distinct Nominator,Contact , [ID no1],
			case when [ID Type1]='FIN' then 'FIN'
							 when [ID Type1]='NRIC (Citizen)' then 'NRIC (Citizen)' 
							 when [ID Type1]='NRIC (Permanent Resident)' then 'NRIC (Permanent Citizen)' 
							 when [ID Type1]='Passport' then 'Passport/Others' Else [ID Type1] end as [ID Type1],[Registration No],
			[ID no],
		 case when [ID Type]='FIN' then 'FIN'
							 when [ID Type]='NRIC (Citizen)' then 'NRIC (Citizen)' 
							 when [ID Type]='NRIC (Permanent Resident)' then 'NRIC (Permanent Citizen)' 
							 when [ID Type]='Passport' then 'Passport/Others' Else [ID Type] end as [ID Type]
		from  [dbo].[BR_Concate_New_Table_Devbackup] where  [Registration No] is not null 
	     and  [Nominee Director]='Yes' and Category1='Individual'
		 OPEN GenericContact
         FETCH NEXT FROM GenericContact INTO @Nominator,@ContactName,@IDno,@IdType,@RegistrationNo,@ConIdNo,@ConIdType
	     WHILE @@FETCH_STATUS = 0
         BEGIN
	
			Set @EntityId=(Select Id From Common.EntityDetail Where UEN=@RegistrationNo And CompanyId=@CompanyId)
			Set @GenericContactId=(Select distinct Id From Boardroom.GenericContact Where CompanyId=@CompanyId And Name=@ContactName And Coalesce(IDType,'NULL')=Coalesce(@ConIdType,'NULL') And Coalesce(IDNumber,'NULL')=Coalesce(@ConIdNo,'NULL'))
			IF (@IDno Is Not Null And (@IDno<>'' Or @IDno<>' ')) OR (@IdType is Not Null And (@IdType <>'' Or @IdType<>' '))
			BEGIN
		
				If @GenericContactId Is Not Null 
				Begin
					Set @NominieGenericContactId=Null
					Set @NominieGenericContactId=(Select Distinct id from  Boardroom.GenericContact Where Name=@Nominator  And Coalesce(IDType,'NULL')=Coalesce(@IdType,'NULL') And Coalesce(IDNumber,'NULL')=Coalesce(@IDno,'NULL') and CompanyId=@CompanyId )
					IF @NominieGenericContactId Is Not Null
					Begin
						IF Exists (Select Id From Boardroom.GenericContactDesignation Where GenericContactId=@GenericContactId And EntityId=@EntityId And CompanyId=@CompanyId And Position='Director')
						Begin
							Update Boardroom.GenericContactDesignation Set NominatedBy=@NominieGenericContactId Where GenericContactId=@GenericContactId And Position='Director' And EntityId=@EntityId And CompanyId=@CompanyId
						End
					End
					Else IF @NominieGenericContactId Is Null
					Begin
					
		
						Set @NominieGenericContactId =NEWID()
						Set @PerEmailJson =(Select Distinct 'Email' As 'key',Email As 'value' From  [dbo].[BR_Concate_New_Table_Devbackup] Where Nominator=@Nominator and Email is not null   and Concat([ID no1],'NULL')=Coalesce(@IDno,'NULL') and Coalesce([Id Type1],'NULL') =Coalesce(@IdType,'NULL') For Json Auto)
						Set @PerMobileJson =(Select Distinct 'Mobile' As 'key',[Mobile Phone No#] As 'value' From  [dbo].[BR_Concate_New_Table_Devbackup] Where Nominator=@Nominator and [Mobile Phone No#] is not null and Concat([ID no1],'NULL')=Coalesce(@IDno,'NULL') and Coalesce([Id Type1],'NULL') =Coalesce(@IdType,'NULL') For Json Auto)
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

						
		
							
						insert into Boardroom.GenericContact (Id,CompanyId,Category,Salutation,Name,IDType,IDNumber,Nationality,Gender,DateOfBirth,CountryOfBirth,CountryOfResidence,Communication,CountryOfIncorporation,CompanyType
					      ,Suffix,CorporateEntityRegister,Remarks,RecOrder,UserCreated,CreatedDate,ModifiedBy,ModifiedDate,Version,Status,IsMainContact,Type,TypeId,ShortName,IsNoProfile)

						 select Distinct top 1   @NominieGenericContactId AS Id,@CompanyId AS CompanyId,Category1 Category,Salutation1 AS Salutation,@Nominator Name,
								case when [ID Type1]='FIN' then 'FIN'
									 when [ID Type1]='NRIC (Citizen)' then 'NRIC (Citizen)' 
									when [ID Type1]='NRIC (Permanent Resident)' then 'NRIC (Permanent Citizen)' 
									when [ID Type1]='Passport' then 'Passport/Others' Else [ID Type1] end as IDType,
								[ID no1] IDNumber,[dbo].[InitCap](Nationality1) AS  Nationality,Gender1 Gender,[Date of Birth1] DateOfBirth,
								--case when [Country of Birth1]='UNITED STATES OF AMERICA' then 'United States'
								--	when [Country of Birth1]='Cyprus (Limassol)' then 'Cyprus' 
								--	when [Country of Birth1]='China' then 'Peoples Republic Of China' else 
									[dbo].[InitCap]([Country of Birth1]) AS CountryOfBirth,
								Null CountryOfResidence,@PerJsondata Communication,null AS CountryofIncorporation ,null AS CompanyType ,null AS Suffix,
								Null CorporateEntityRegister,Null Remarks,Null RecOrder,'System' UserCreated,GETDATE() CreatedDate,null ModifiedBy,null ModifiedDate,Null Version,1 Status,
								Null IsMainContact,'Client' Type,null TypeId, dbo.fnFirsties(Nominator) as  ShortName ,Null IsNoProfile
						From [dbo].[BR_Concate_New_Table_Devbackup] 
						where [Registration No] is not null and Nominator=@Nominator And Nominator Is Not Null And Nominator<>'NA' and Coalesce([ID no1],'NULL')=Coalesce(@IDno,'NULL') and Coalesce([Id Type1],'NULL') =Coalesce(@IdType,'NULL') ---and Position=@Position

----------------	---------------------------------------------------------------------------------------------------------------

						Declare Contact Cursor For
						select Distinct [Registration No] AS RegistrationNo,[Entity Name],Nominator , [ID no1],
								 case when [ID Type1]='FIN' then 'FIN'
									  when [ID Type1]='NRIC (Citizen)' then 'NRIC (Citizen)' 
									  when [ID Type1]='NRIC (Permanent Resident)' then 'NRIC (Permanent Citizen)' 
									  when [ID Type1]='Passport' then 'Passport/Others' Else [ID Type1] end as [ID Type1],Position,Category  from  [dbo].[BR_Concate_New_Table_Devbackup]
									  where [Registration No] is not null and  [Nominee Director]='Yes' and Category1='Individual' and Nominator =@Nominator And Nominator<>'NA' And  Coalesce([ID no1],'NULL')=Coalesce(@IDno,'NULL') and Coalesce([ID Type1],'NULL')=Coalesce(@IdType,'NULL')-- And Category1='Individual'
						OPEN Contact
						FETCH NEXT FROM Contact INTO @RegistrationNo,@EntityName,@Nominator,@IDno,@IdType,@Position,@Category
						WHILE @@FETCH_STATUS = 0
						BEGIN
					
							Set @EntityId =(Select Distinct Id from  Common.EntityDetail Where UEN=@RegistrationNo and CompanyId=@CompanyId)
 							If NOT Exists (Select Distinct id from  Boardroom.Contacts Where GenericContactId=@NominieGenericContactId  And EntityId=@EntityId And CompanyId=@CompanyId)
							BEGIN
						
					 			set @ContactId=NewId()
								set @AddressbookId =NEWID()
						
								Insert into Boardroom.Contacts(Id,CompanyId,GenericContactId,Type,Remarks,RecOrder,UserCreated,CreatedDate,ModifiedBy,ModifiedDate,Version,Status,EntityId,IsEntity,
								DateOfCessation,Docstatus,IsPrimary,IsCessation,ReasonForCessation,DisqualifiedReasons,DisqualifiedReasonsSubsection,State,IsTemporary,IsReminder)

								select Distinct @ContactId Id,@CompanyId As CompanyId,@NominieGenericContactId As GenericContactId,'Client' Type,Null Remarks,Null RecOrder,'System' As UserCreated,Getdate() CreatedDate,
								Null ModifiedBy,Null ModifiedDate,Null Version,1 Status,@EntityId EntityId,0 IsEntity,Null DateOfCessation,Null Docstatus,Null IsPrimary,
								Null IsCessation,NUll ReasonForCessation,Null DisqualifiedReasons,Null DisqualifiedReasonsSubsection,Null State,0 IsTemporary,Null IsReminder
								from [dbo].[BR_Concate_New_Table_Devbackup] 
								where  [Registration No] is not null and [Registration No]=@RegistrationNo and Nominator<>'NA' And [Entity Name]=@EntityName and Nominator=@Nominator and Coalesce([ID no1],'NULL')=Coalesce(@IDno,'NULL') and Coalesce([ID Type1],'NULL')=Coalesce(@IdType,'NULL') /*And Category1='Individual'*/ --and Position=@Position

							IF @Category='individual'
							BEGIN

								Insert into  Boardroom.GenericContactDesignation
									(Id,CompanyId,ContactId,GenericContactId,EntityId,Type,Position,DateofAppointment,DateofCessation,ReasonforCessation,DisqualifiedReasons
									,DisqualifiedReasonsSubsection,Remarks,RecOrder,UserCreated,CreatedDate,ModifiedBy,ModifiedDate,Version
									,Status,ShortCode,CommencementDate,CorporateRepresentative,AlternateFor,NominatedBy,IsRegistrableController,IsSignificantInterest
									,IsSignificantControl,Sort,Reason)

								select   Distinct NEWID() AS Id,@CompanyId As CompanyId,@ContactId ContactId,@NominieGenericContactId GenericContactId,@EntityId As EntityId,
								NUll AS  Type,Position AS Position,CONVERT(VARCHAR(10), [Appointment Date], 110)  DateofAppointment ,Null DateofCessation,Null ReasonforCessation,Null DisqualifiedReasons,
								NUll DisqualifiedReasonsSubsection,Null Remarks,(select Max(RecOrder)+1 from Boardroom.GenericContactDesignation) As RecOrder,'System' UserCreated,GETDATE() CreatedDate,Null ModifiedBy,Null ModifiedDate,
								Null Version,1 Status,(Select ShortCode From Boardroom.ContactMapping Where Category=@Category And Position='Director' And Status=1) ShortCode,NUll CommencementDate,NUll CorporateRepresentative,NUll  AlternateFor,@NominieGenericContactId NominatedBy,Null IsRegistrableController,
								Null IsSignificantInterest,Null IsSignificantControl,(Select Sort From Boardroom.ContactMapping Where Category=@Category And Position='Director' And Status=1) As Sort,NUll Reason
								From [dbo].[BR_Concate_New_Table_Devbackup]
								where  [Registration No] is not null and [Registration No]=@RegistrationNo and [Entity Name]=@EntityName and Nominator=@Nominator and Coalesce([ID no1],'NULL')=Coalesce(@IDno,'NULL') and Coalesce([ID Type1],'NULL')=Coalesce(@IdType,'NULL') And Category1='Individual' and Position=@Position 
							END
									
								Insert into [Common].[AddressBook]( Id,IsLocal,BlockHouseNo,Street,UnitNo,BuildingEstate,City,PostalCode,State,Country,Phone,Email,Website,Latitude,Longitude,RecOrder
										,Remarks,UserCreated,CreatedDate,ModifiedBy,ModifiedDate,Version,Status,DocumentId ) 

								select Distinct @AddressbookId Id,Case when [Local Address/ Foreign Address]='Local Address' then  1
																		when [Local Address/ Foreign Address]='Foreign Address' then  0 end AS IsLocal,[Block/House No1] BlockHouseNo,							
											Case when Street1=cast(Street1 as nvarchar(100)) then Street1
												when [Local Address/ Foreign Address]='Foreign Address' then [AddressLine2]  ENd  AS Street1,
											Case when [Level & Unit no1]=[Level & Unit no1] then [Level & Unit no1]
												when [Local Address/ Foreign Address]='Foreign Address' then [AddressLine1]  ENd as UnitNo,Building1 AS BuildingEstate,Null AS City,
											cast([Postal Code1]as nvarchar(100)) PostalCode,Null State,Country1 AS Country,[Mobile Phone No#1] Phone,[Email 1] Email,Null Website,Null Latitude,Null Longitude,NUll RecOrder,
											Null Remarks,'System' UserCreated,Getdate() AS CreatedDate,Null ModifiedBy,Null ModifiedDate,Null Version,1 AS Status,Null DocumentId
								from [dbo].[BR_Concate_New_Table_Devbackup] 
								where  [Registration No] is not null and [Registration No]=@RegistrationNo and [Entity Name]=@EntityName and Nominator=@Nominator and Coalesce([ID no1],'NULL')=Coalesce(@IDno,'NULL') and Coalesce([ID Type1],'NULL')=Coalesce(@IdType,'NULL') And Category1='Individual' --and Position=@Position
								group by [Block/House No1] ,[AddressLine2] ,[AddressLine1] ,Building1 ,Country1 ,[Postal Code1],Country1 ,Country1 ,[Mobile Phone No#1] ,[Email 1], [Local Address/ Foreign Address],Street1,[Level & Unit no1]

								-------[Common].[Addresses]---


						
								insert into [Common].[Addresses](Id,AddSectionType,AddType,AddTypeId,AddTypeIdInt,AddressBookId,Status,DocumentId,EntityId,ScreenName,IsCurrentAddress,CompanyId,CopyId)

								select Distinct NEWID()Id, [Address Type1] AS AddSectionType,'Client' AddType,@ContactId AddTypeId,Null AddTypeIdInt,@AddressbookId AddressBookId,
								1 Status,Null AS DocumentId,@EntityId EntityId,Null ScreenName,Null IsCurrentAddress,@CompanyId AS CompanyId,Null CopyId
								from [dbo].[BR_Concate_New_Table_Devbackup] 
								where  [Registration No] is not null and [Registration No]=@RegistrationNo and [Entity Name]=@EntityName and Nominator=@Nominator and Coalesce([ID no1],'NULL')=Coalesce(@IDno,'NULL') and Coalesce([ID Type1],'NULL')=Coalesce(@IdType,'NULL') And Category1='Individual' 
							
								--Position=@Position
								Group by [Address Type1]
							
								update Common.Addresses set AddSectionType='Registered Office Address' where CompanyId=@CompanyId and AddSectionType='REGISTERED OFFICE ADDRESS'
								Update Boardroom.GenericContactDesignation Set NominatedBy=@NominieGenericContactId Where GenericContactId=@GenericContactId And Position='Director' And EntityId=@EntityId And CompanyId=@CompanyId

								-------------------------------
							END
							
							Else If Exists (Select Distinct id from  Boardroom.Contacts Where GenericContactId=@NominieGenericContactId  And EntityId=@EntityId And CompanyId=@CompanyId)
							Begin 
								
								IF Exists (Select Id From Boardroom.GenericContactDesignation Where GenericContactId=@NominieGenericContactId And EntityId=@EntityId And ContactId=(Select Distinct id from  Boardroom.Contacts Where GenericContactId=@NominieGenericContactId  And EntityId=@EntityId And CompanyId=@CompanyId) and CompanyId=@CompanyId)
								Begin
									Update Boardroom.GenericContactDesignation Set NominatedBy=@NominieGenericContactId Where GenericContactId=@GenericContactId And EntityId=@EntityId And CompanyId=@CompanyId And Position='Director'
								End
								Else IF Not Exists (Select Id From Boardroom.GenericContactDesignation Where GenericContactId=@NominieGenericContactId And EntityId=@EntityId And ContactId=(Select Distinct id from  Boardroom.Contacts Where GenericContactId=@NominieGenericContactId  And EntityId=@EntityId And CompanyId=@CompanyId) and CompanyId=@CompanyId)
								Begin
							
									Insert into  Boardroom.GenericContactDesignation
									(Id,CompanyId,ContactId,GenericContactId,EntityId,Type,Position,DateofAppointment,DateofCessation,ReasonforCessation,DisqualifiedReasons
									,DisqualifiedReasonsSubsection,Remarks,RecOrder,UserCreated,CreatedDate,ModifiedBy,ModifiedDate,Version
									,Status,ShortCode,CommencementDate,CorporateRepresentative,AlternateFor,NominatedBy,IsRegistrableController,IsSignificantInterest
									,IsSignificantControl,Sort,Reason)

									select   Distinct NEWID() AS Id,@CompanyId As CompanyId,(Select Distinct id from  Boardroom.Contacts Where GenericContactId=@NominieGenericContactId  And EntityId=@EntityId And CompanyId=@CompanyId) As ContactId,@NominieGenericContactId GenericContactId,@EntityId As EntityId,
									NUll AS  Type,Position AS Position,CONVERT(VARCHAR(10), [Appointment Date], 110)  DateofAppointment ,Null DateofCessation,Null ReasonforCessation,Null DisqualifiedReasons,
									NUll DisqualifiedReasonsSubsection,Null Remarks,(select Max(RecOrder)+1 from Boardroom.GenericContactDesignation) As RecOrder,'System' UserCreated,GETDATE() CreatedDate,Null ModifiedBy,Null ModifiedDate,
									Null Version,1 Status,(Select ShortCode From Boardroom.ContactMapping Where Category=@Category And Position='Director' And Status=1) ShortCode,NUll CommencementDate,NUll CorporateRepresentative,NUll  AlternateFor,@NominieGenericContactId NominatedBy,Null IsRegistrableController,
									Null IsSignificantInterest,Null IsSignificantControl,(Select Sort From Boardroom.ContactMapping Where Category=@Category And Position='Director' And Status=1) As Sort,NUll Reason
									From [dbo].[BR_Concate_New_Table_Devbackup]
									where  [Registration No] is not null and [Registration No]=@RegistrationNo and [Entity Name]=@EntityName and Nominator=@Nominator and Coalesce([ID no1],'NULL')=Coalesce(@IDno,'NULL') and Coalesce([ID Type1],'NULL')=Coalesce(@IdType,'NULL') And Category1='Individual' and Position=@Position 
									
									Update Boardroom.GenericContactDesignation Set NominatedBy=@NominieGenericContactId Where GenericContactId=@GenericContactId And EntityId=@EntityId And CompanyId=@CompanyId And Position='Director'
								
								End
							End

						Fetch next from Contact Into @RegistrationNo,@EntityName,@Nominator,@IDno,@IdType,@Position,@Category
							
						END
						Close Contact
						Deallocate Contact
						End
				End
			End
			Else IF (@IDno Is Null OR (@IDno='' Or @IDno=' ')) OR (@IdType is Null Or (@IdType ='' Or @IdType=' '))
			Begin
		
				If @GenericContactId Is Not Null
				Begin
					Set @NominieGenericContactId=(Select Distinct id from  Boardroom.GenericContact Where Name=@Nominator  And Coalesce(IDType,'NULL')=Coalesce(@IdType,'NULL') And Coalesce(IDNumber,'NULL')=Coalesce(@Idno,'NULL') and CompanyId=@CompanyId )
					IF @NominieGenericContactId Is Not Null
					Begin
						Update Boardroom.GenericContactDesignation Set NominatedBy=@NominieGenericContactId Where GenericContactId=@GenericContactId And Position='Director' And EntityId=@EntityId And CompanyId=@CompanyId
					End
					Else IF @NominieGenericContactId Is Null
					Begin
						Set @NominieGenericContactId =NEWID()
						Set @PerEmailJson =(Select Distinct 'Email' As 'key',Email As 'value' From  [dbo].[BR_Concate_New_Table_Devbackup] Where Nominator=@Nominator and Email is not null   and Coalesce([ID no1],'NULL')=Coalesce(@IDno,'NULL') and Coalesce([Id Type1],'NULL') =Coalesce(@IdType,'NULL')   For Json Auto)
						Set @PerMobileJson =(Select Distinct 'Mobile' As 'key',[Mobile Phone No#] As 'value' From  [dbo].[BR_Concate_New_Table_Devbackup] Where Nominator=@Nominator and [Mobile Phone No#] is not null   and Coalesce([ID no1],'NULL')=Coalesce(@IDno,'NULL') and Coalesce([Id Type1],'NULL') =Coalesce(@IdType,'NULL')  For Json Auto)
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

					
					
						insert into Boardroom.GenericContact (Id,CompanyId,Category,Salutation,Name,IDType,IDNumber,Nationality,Gender,DateOfBirth,CountryOfBirth,CountryOfResidence,Communication,CountryOfIncorporation,CompanyType
					      ,Suffix,CorporateEntityRegister,Remarks,RecOrder,UserCreated,CreatedDate,ModifiedBy,ModifiedDate,Version,Status,IsMainContact,Type,TypeId,ShortName,IsNoProfile)

						 select Distinct top 1   @NominieGenericContactId AS Id,@CompanyId AS CompanyId,Category1 Category,Salutation1 AS Salutation,@Nominator Name,
								@IdType as IDType,
								@IDno IDNumber,[dbo].[InitCap](Nationality1) AS  Nationality,Gender1 Gender,[Date of Birth1] DateOfBirth,
								--case when [Country of Birth1]='UNITED STATES OF AMERICA' then 'United States'
								--	when [Country of Birth1]='Cyprus (Limassol)' then 'Cyprus' 
								--	when [Country of Birth1]='China' then 'Peoples Republic Of China' else 
									[dbo].[InitCap]([Country of Birth1]) AS CountryOfBirth,
								NUll CountryOfResidence,@PerJsondata Communication,null AS CountryofIncorporation ,null AS CompanyType ,null AS Suffix,
								Null CorporateEntityRegister,Null Remarks,Null RecOrder,'System' UserCreated,GETDATE() CreatedDate,null ModifiedBy,null ModifiedDate,Null Version,1 Status,
								Null IsMainContact,'Client' Type,null TypeId, dbo.fnFirsties(Nominator) as  ShortName ,1 As IsNoProfile
						From [dbo].[BR_Concate_New_Table_Devbackup] 
						where [Registration No] is not null and Nominator=@Nominator And Nominator Is Not Null And Nominator<>'NA' and Coalesce([ID no1],'NULL')=Coalesce(@IDno,'NULL') and Coalesce([Id Type1],'NULL') =Coalesce(@IdType,'NULL') ---and Position=@Position

----------------	---------------------------------------------------------------------------------------------------------------

						Declare Contact Cursor For
						select Distinct [Registration No] AS RegistrationNo,[Entity Name],Nominator , [ID no1],
								 case when [ID Type1]='FIN' then 'FIN'
									  when [ID Type1]='NRIC (Citizen)' then 'NRIC (Citizen)' 
									  when [ID Type1]='NRIC (Permanent Resident)' then 'NRIC (Permanent Citizen)' 
									  when [ID Type1]='Passport' then 'Passport/Others' Else [ID Type1] end as [ID Type1],Position,Category  from  [dbo].[BR_Concate_New_Table_Devbackup]
									  where [Registration No] is not null and  [Nominee Director]='Yes' and Category1='Individual' and Nominator =@Nominator And Nominator<>'NA' And Coalesce([ID no1],'NULL')=Coalesce(@IDno,'NULL') and Coalesce([ID Type1],'NULL')=Coalesce(@IdType,'NULL')
						OPEN Contact
						FETCH NEXT FROM Contact INTO @RegistrationNo,@EntityName,@Nominator,@IDno,@IdType,@Position,@Category
						WHILE @@FETCH_STATUS = 0
						BEGIN
					
							Set @EntityId =(Select Distinct Id from  Common.EntityDetail Where UEN=@RegistrationNo and CompanyId=@CompanyId)
 							If NOT Exists (Select Distinct id from  Boardroom.Contacts Where GenericContactId=@NominieGenericContactId  And EntityId=@EntityId And CompanyId=@CompanyId)
							BEGIN
					 			set @ContactId=NewId()
								set @AddressbookId =NEWID()
						
								Insert into Boardroom.Contacts(Id,CompanyId,GenericContactId,Type,Remarks,RecOrder,UserCreated,CreatedDate,ModifiedBy,ModifiedDate,Version,Status,EntityId,IsEntity,
								DateOfCessation,Docstatus,IsPrimary,IsCessation,ReasonForCessation,DisqualifiedReasons,DisqualifiedReasonsSubsection,State,IsTemporary,IsReminder)

								select Distinct @ContactId Id,@CompanyId As CompanyId,@NominieGenericContactId As GenericContactId,'Client' Type,Null Remarks,Null RecOrder,'System' As UserCreated,Getdate() CreatedDate,
								Null ModifiedBy,Null ModifiedDate,Null Version,1 Status,@EntityId EntityId,0 IsEntity,Null DateOfCessation,Null Docstatus,Null IsPrimary,
								Null IsCessation,NUll ReasonForCessation,Null DisqualifiedReasons,Null DisqualifiedReasonsSubsection,Null State,0 IsTemporary,Null IsReminder
								from [dbo].[BR_Concate_New_Table_Devbackup] 
								where  [Registration No] is not null and [Registration No]=@RegistrationNo and [Entity Name]=@EntityName and Nominator=@Nominator and Coalesce([ID no1],'NULL')=Coalesce(@IDno,'NULL') and Coalesce([ID Type1],'NULL')=Coalesce(@IdType,'NULL') --And Category1<>'Individual' --and Position=@Position



								Update Boardroom.GenericContactDesignation Set NominatedBy=@NominieGenericContactId Where GenericContactId=@GenericContactId And Position='Director' And EntityId=@EntityId And CompanyId=@CompanyId

								/*
								Insert into  Boardroom.GenericContactDesignation
									(Id,CompanyId,ContactId,GenericContactId,EntityId,Type,Position,DateofAppointment,DateofCessation,ReasonforCessation,DisqualifiedReasons
									,DisqualifiedReasonsSubsection,Remarks,RecOrder,UserCreated,CreatedDate,ModifiedBy,ModifiedDate,Version
									,Status,ShortCode,CommencementDate,CorporateRepresentative,AlternateFor,NominatedBy,IsRegistrableController,IsSignificantInterest
									,IsSignificantControl,Sort,Reason)

								select   Distinct NEWID() AS Id,@CompanyId As CompanyId,@ContactId ContactId,@NominieGenericContactId GenericContactId,@EntityId As EntityId,
								NUll AS  Type,Position AS Position,CONVERT(VARCHAR(10), [Appointment Date], 110)  DateofAppointment ,Null DateofCessation,Null ReasonforCessation,Null DisqualifiedReasons,
								NUll DisqualifiedReasonsSubsection,Null Remarks,(select Max(RecOrder)+1 from Boardroom.GenericContactDesignation) As RecOrder,'System' UserCreated,GETDATE() CreatedDate,Null ModifiedBy,Null ModifiedDate,
								Null Version,1 Status,(Select ShortCode From Boardroom.ContactMapping Where Category=@Category And Position='Director' And Status=1) ShortCode,NUll CommencementDate,NUll CorporateRepresentative,NUll  AlternateFor,@NominieGenericContactId NominatedBy,Null IsRegistrableController,
								Null IsSignificantInterest,Null IsSignificantControl,(Select Sort From Boardroom.ContactMapping Where Category=@Category And Position='Director' And Status=1) As Sort,NUll Reason
								From [dbo].[BR_Concate_New_Table_Devbackup]
								where  [Registration No] is not null and [Registration No]=@RegistrationNo and [Entity Name]=@EntityName and Contact=@Nominator and Coalesce([ID no1],'NULL')=Coalesce(@IDno,'NULL') and Coalesce([ID Type1],'NULL')=Coalesce(@IdType,'NULL') And Category1='Individual' and Position=@Position 
								*/
						
								Insert into [Common].[AddressBook]( Id,IsLocal,BlockHouseNo,Street,UnitNo,BuildingEstate,City,PostalCode,State,Country,Phone,Email,Website,Latitude,Longitude,RecOrder
										,Remarks,UserCreated,CreatedDate,ModifiedBy,ModifiedDate,Version,Status,DocumentId ) 

								select Distinct @AddressbookId Id,Case when [Local Address/ Foreign Address]='Local Address' then  1
																		when [Local Address/ Foreign Address]='Foreign Address' then  0 end AS IsLocal,[Block/House No1] BlockHouseNo,							
											Case when Street1=cast(Street1 as nvarchar(100)) then Street1
												when [Local Address/ Foreign Address]='Foreign Address' then [AddressLine2]  ENd  AS Street1,
											Case when [Level & Unit no1]=[Level & Unit no1] then [Level & Unit no1]
												when [Local Address/ Foreign Address]='Foreign Address' then [AddressLine1]  ENd as UnitNo,Building1 AS BuildingEstate,Null AS City,
											cast([Postal Code1]as nvarchar(100)) PostalCode,Null State,Country1 AS Country,[Mobile Phone No#1] Phone,[Email 1] Email,Null Website,Null Latitude,Null Longitude,NUll RecOrder,
											Null Remarks,'System' UserCreated,Getdate() AS CreatedDate,Null ModifiedBy,Null ModifiedDate,Null Version,1 AS Status,Null DocumentId
								from [dbo].[BR_Concate_New_Table_Devbackup] 
								where  [Registration No] is not null and [Registration No]=@RegistrationNo and [Entity Name]=@EntityName and Nominator=@Nominator and Coalesce([ID no1],'NULL')=Coalesce(@IDno,'NULL') and Coalesce([ID Type1],'NULL')=Coalesce(@IdType,'NULL') --and Position=@Position
								group by [Block/House No1] ,[AddressLine2] ,[AddressLine1] ,Building1 ,Country1 ,[Postal Code1],Country1 ,Country1 ,[Mobile Phone No#1] ,[Email 1], [Local Address/ Foreign Address],Street1,[Level & Unit no1]

								-------[Common].[Addresses]---


							
								insert into [Common].[Addresses](Id,AddSectionType,AddType,AddTypeId,AddTypeIdInt,AddressBookId,Status,DocumentId,EntityId,ScreenName,IsCurrentAddress,CompanyId,CopyId)

								select Distinct NEWID()Id, [Address Type1] AS AddSectionType,'Client' AddType,@ContactId AddTypeId,Null AddTypeIdInt,@AddressbookId AddressBookId,
								1 Status,Null AS DocumentId,@EntityId EntityId,Null ScreenName,Null IsCurrentAddress,@CompanyId AS CompanyId,Null CopyId
								from [dbo].[BR_Concate_New_Table_Devbackup] 
								where  [Registration No] is not null and [Registration No]=@RegistrationNo and [Entity Name]=@EntityName and Nominator=@Nominator and Coalesce([ID no1],'NULL')=Coalesce(@IDno,'NULL') and Coalesce([ID Type1],'NULL')=Coalesce(@IdType,'NULL') 
							
								--Position=@Position
								Group by [Address Type1]
							
								update Common.Addresses set AddSectionType='Registered Office Address' where CompanyId=@CompanyId and AddSectionType='REGISTERED OFFICE ADDRESS'
								-------------------------------
							END
							Else If Exists (Select Distinct id from  Boardroom.Contacts Where GenericContactId=@NominieGenericContactId  And EntityId=@EntityId And CompanyId=@CompanyId)
							Begin
								--IF Exists (Select Id From Boardroom.GenericContactDesignation Where GenericContactId=@NominieGenericContactId And EntityId=@EntityId And ContactId=(Select Distinct id from  Boardroom.Contacts Where GenericContactId=@NominieGenericContactId  And EntityId=@EntityId And CompanyId=@CompanyId) and CompanyId=@CompanyId)
								--Begin
									Update Boardroom.GenericContactDesignation Set NominatedBy=@NominieGenericContactId Where GenericContactId=@GenericContactId And EntityId=@EntityId And CompanyId=@CompanyId And Position='Director'
								--End
								/*Else IF Not Exists (Select Id From Boardroom.GenericContactDesignation Where GenericContactId=@NominieGenericContactId And EntityId=@EntityId And ContactId=(Select Distinct id from  Boardroom.Contacts Where GenericContactId=@NominieGenericContactId  And EntityId=@EntityId And CompanyId=@CompanyId) and CompanyId=@CompanyId)
								Begin
									Insert into  Boardroom.GenericContactDesignation
									(Id,CompanyId,ContactId,GenericContactId,EntityId,Type,Position,DateofAppointment,DateofCessation,ReasonforCessation,DisqualifiedReasons
									,DisqualifiedReasonsSubsection,Remarks,RecOrder,UserCreated,CreatedDate,ModifiedBy,ModifiedDate,Version
									,Status,ShortCode,CommencementDate,CorporateRepresentative,AlternateFor,NominatedBy,IsRegistrableController,IsSignificantInterest
									,IsSignificantControl,Sort,Reason)

									select   Distinct NEWID() AS Id,@CompanyId As CompanyId,(Select Distinct id from  Boardroom.Contacts Where GenericContactId=@NominieGenericContactId  And EntityId=@EntityId And CompanyId=@CompanyId) As ContactId,@NominieGenericContactId GenericContactId,@EntityId As EntityId,
									NUll AS  Type,Position AS Position,CONVERT(VARCHAR(10), [Appointment Date], 110)  DateofAppointment ,Null DateofCessation,Null ReasonforCessation,Null DisqualifiedReasons,
									NUll DisqualifiedReasonsSubsection,Null Remarks,(select Max(RecOrder)+1 from Boardroom.GenericContactDesignation) As RecOrder,'System' UserCreated,GETDATE() CreatedDate,Null ModifiedBy,Null ModifiedDate,
									Null Version,1 Status,(Select ShortCode From Boardroom.ContactMapping Where Category=@Category And Position='Director' And Status=1) ShortCode,NUll CommencementDate,NUll CorporateRepresentative,NUll  AlternateFor,@NominieGenericContactId NominatedBy,Null IsRegistrableController,
									Null IsSignificantInterest,Null IsSignificantControl,(Select Sort From Boardroom.ContactMapping Where Category=@Category And Position='Director' And Status=1) As Sort,NUll Reason
									From [dbo].[BR_Concate_New_Table_Devbackup]
									where  [Registration No] is not null and [Registration No]=@RegistrationNo and [Entity Name]=@EntityName and Contact=@Nominator and Coalesce([ID no1],'NULL')=Coalesce(@IDno,'NULL') and Coalesce([ID Type1],'NULL')=Coalesce(@IdType,'NULL') and Position=@Position 
									
									Update Boardroom.GenericContactDesignation Set NominatedBy=@NominieGenericContactId Where GenericContactId=@GenericContactId And EntityId=@EntityId And CompanyId=@CompanyId And Position='Director'
								
								End*/
							End

						Fetch next from Contact Into @RegistrationNo,@EntityName,@Nominator,@IDno,@IdType,@Position,@Category
							
						END
						Close Contact
						Deallocate Contact
						End
				End
				
			End
				FETCH NEXT FROM GenericContact INTO @Nominator,@ContactName,@IDno,@IdType,@RegistrationNo,@ConIdNo,@ConIdType
				
			END
			Close GenericContact
			Deallocate GenericContact
		Commit Transaction		
End Try

Begin Catch
	Rollback;
	Set @Err_Msg=(Select ERROR_MESSAGE())
	Raiserror(@Err_Msg,16,1)
End Catch

End
GO
