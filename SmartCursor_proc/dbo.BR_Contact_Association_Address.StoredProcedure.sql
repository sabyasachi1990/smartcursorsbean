USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[BR_Contact_Association_Address]    Script Date: 16-12-2024 9.20.10 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
Create  Procedure [dbo].[BR_Contact_Association_Address]

 @genericcontactIds nvarchar(Max),
 @entityId uniqueidentifier,
 @contactId uniqueidentifier
 
As 
Begin
If Exists(Select Id from Common.EntityDetail where Id=@entityId)
Begin
Declare @genericcontactId uniqueidentifier,@gcId nvarchar(100),@assciationEntityId uniqueidentifier
Declare  gccontactId Cursor for  Select items  From [dbo].[SplitToTable] (@genericcontactIds,',')  
Open gccontactId
Fetch Next From gccontactId into @gcId
While @@FETCH_STATUS=0
Begin
  Set @genericcontactId=CONVERT(uniqueidentifier,@gcId)
Declare @associatedcontactId uniqueidentifier,@addrbookIslocal bit,@addrbooktempId uniqueidentifier,@addrbookstatus bigint

Declare @associationsTemp table(ContactId uniqueidentifier,EntityId uniqueidentifier)

Declare @addrTemp Table(addrId uniqueidentifier,addrEntityId uniqueidentifier,addrStatus Bigint,addrAddressBookId uniqueidentifier,addrIsCurrentAddress bit,addrScreenName nvarchar(200),addrCompanyId Bigint,
addrAddTypeId uniqueidentifier,addrAddType Nvarchar(500),addrAddSectionType Nvarchar(300),addrRelationId uniqueidentifier)

Declare @addrbookTemp Table(addrtempId uniqueidentifier,addrtempIsLocal bit,addrtempBlockHouseNo nvarchar(256),addrtempStreet nvarchar(100),addrtempUnitNo nvarchar(256),addrtempBuildingEstate nvarchar(256),addrtempCity nvarchar(256),addrtempPostalCode nvarchar(10)
,addrtempState nvarchar(256),addrtempCountry nvarchar(256),addrtempPhone nvarchar(1000),addrtempEmail nvarchar(1000),addrtempWebsite nvarchar(1000),addrtempLatitude decimal(18,6),addrtempLongitude decimal(18,6),addrbookStatus Bigint)

Insert Into @addrTemp(addrId,addrEntityId,addrStatus,addrAddressBookId,addrIsCurrentAddress,addrScreenName,addrCompanyId,addrAddTypeId,addrAddType,addrAddSectionType,addrRelationId)
(Select Id,EntityId,Status,AddressBookId,IsCurrentAddress,ScreenName,CompanyId,AddTypeId,AddType,AddSectionType,RelationId from Common.Addresses where AddTypeId in (@contactId) And AddSectionType in ('Residential Address','Registered Office Address') )


Insert into @addrbookTemp(addrtempId,addrtempIsLocal,addrtempBlockHouseNo,addrtempStreet,addrtempUnitNo,addrtempBuildingEstate,addrtempCity,addrtempPostalCode 
,addrtempState ,addrtempCountry ,addrtempPhone ,addrtempEmail ,addrtempWebsite ,addrtempLatitude ,addrtempLongitude ,addrbookStatus)
((Select addrbook.Id,addrbook.IsLocal,addrbook.BlockHouseNo,addrbook.Street,addrbook.UnitNo,addrbook.BuildingEstate,addrbook.City,addrbook.PostalCode,addrbook.State,
addrbook.Country,addrbook.Phone,addrbook.Email,addrbook.Website,addrbook.Latitude,addrbook.Longitude,addrbook.Status
from Common.Addresses as addr 
join Common.AddressBook as addrbook on addr.AddressBookId =addrbook.Id
where addr.AddTypeId=@contactId And addr.AddSectionType in ('Registered Office Address','Residential Address')))


Insert Into @associationsTemp(ContactId,EntityId)
(Select Id,EntityId from Boardroom.Contacts where GenericContactId=@genericcontactId
And Id!=@contactId)
Declare @addrsId uniqueidentifier,@associationcntctId uniqueidentifier

Select * from @addrTemp
Select * from @addrbookTemp


Declare assocationcontct cursor for (Select ContactId,EntityId from @associationsTemp)
Open assocationcontct
Fetch Next From assocationcontct Into @associationcntctId,@assciationEntityId
While @@FETCH_STATUS=0
Begin

 Begin
  Declare addrdelete Cursor for (Select addrtempIsLocal as localaddress,addrtempId from @addrbookTemp where addrbookStatus=3)
  Open addrdelete
  Fetch Next From addrdelete into @addrbookIslocal,@addrbooktempId
  While @@FETCH_STATUS=0
  Begin
   If((select COUNT(addrId) from @addrTemp where addrStatus=3)<> 0)
    Begin
     Print 'enter for delete Address'
     Set @addrsId =(Select addr.Id from Common.Addresses as addr 
                    join common.AddressBook as addrbook on addr.AddressBookId=addrbook.Id
                    where addr.AddSectionType in ('Registered Office Address' ,'Residential Address')
                    And addr.AddTypeId in (@associationcntctId) And addrbook.IsLocal=@addrbookIslocal)
	Select @addrbookIslocal
	Select @addrsId	 as 'delete Address Id' 
   If(@addrsId Is not Null)
    Begin
	Print 'Enter into Delete'
      Declare @addrbookId uniqueidentifier = (select AddressBookId from Common.Addresses where Id=@addrsId)
      Delete Common.Addresses where Id=@addrsId
      Delete Common.AddressBook where Id=@addrbookId


	  Declare @deleteaddrbookId uniqueidentifier = (select addrtempId from @addrbookTemp where addrtempIsLocal=@addrbookIslocal and addrbookStatus=3)
	  Delete Common.Addresses where  AddTypeId=@contactId and Status=3
	  Delete Common.AddressBook where Id in (@deleteaddrbookId)

   End
   End
   Fetch Next From addrdelete into @addrbookIslocal,@addrbooktempId
   End
   Close  addrdelete
  Deallocate addrdelete
 End

 Begin
 Print 'Entity into AddOrModify'
  Declare addraddormodify Cursor for (Select addrtempIsLocal as localaddress,addrtempId from @addrbookTemp where addrbookStatus=1)
  Open addraddormodify
  Fetch Next From addraddormodify into @addrbookIslocal,@addrbooktempId
  While @@FETCH_STATUS=0
Begin
 Declare @newaddrBookId Uniqueidentifier =NewId()
 select * from @addrTemp where addrStatus=1 
 Declare @addorupdatecount bigint=(select COUNT(*) from @addrTemp where addrStatus=1)
 Select @addorupdatecount 
If(@addorupdatecount=1 )
Begin
Print 'enter into '
select @associationcntctId

 Set @addrsId =(Select addr.Id from Common.Addresses as addr 
               join common.AddressBook as addrbook on addr.AddressBookId=addrbook.Id
              where addr.AddSectionType in ('Registered Office Address','Residential Address')
              And addr.AddTypeId in (@associationcntctId) and addr.Status=1) 
	
   If(@addrsId Is Not Null)
     Begin
	 Print 'Enter into update'
   (Select * from @addrbookTemp where addrtempIsLocal=@addrbookIslocal and addrbookStatus=1)
     Update Common.AddressBook Set
     IsLocal=(Select addrtempIsLocal from @addrbookTemp where   addrbookStatus=1),
     BlockHouseNo=(Select addrtempBlockHouseNo from @addrbookTemp where   addrbookStatus=1 ),
     Street=(Select addrtempStreet from @addrbookTemp where  addrbookStatus=1),
     UnitNo=(Select addrtempUnitNo from @addrbookTemp where  addrbookStatus=1),
     BuildingEstate=(Select addrtempBuildingEstate from @addrbookTemp where  addrbookStatus=1),
     PostalCode=(Select addrtempPostalCode from @addrbookTemp where  addrbookStatus=1),
     State=(Select addrtempState from @addrbookTemp where  addrbookStatus=1),
     Country=(Select addrtempCountry from @addrbookTemp where  addrbookStatus=1),
     Phone=(Select addrtempPhone from @addrbookTemp where  addrbookStatus=1),
     Email=(Select addrtempEmail from @addrbookTemp where  addrbookStatus=1),
     Website=(Select addrtempWebsite from @addrbookTemp where  addrbookStatus=1),
     Latitude=(Select addrtempLatitude from @addrbookTemp where  addrbookStatus=1),
     Longitude=(Select addrtempLongitude from @addrbookTemp where  addrbookStatus=1)
  
    where Id in (
    Select addr.AddressBookId from Common.Addresses as addr 
    join Common.AddressBook as addrbook on addr.AddressBookId =addrbook.Id
    where (addr.AddSectionType='Registered Office Address' OR addr.AddSectionType='Residential Address')
    And addr.AddTypeId in (Select ContactId from @associationsTemp) And  addrbook.Id not in (@addrbooktempId) And addr.Status=1)
   
   Declare @DeleteAddress bigint=(select COUNT(addr.Id) from Common.Addresses as addr
                                  join Common.AddressBook as addrbook on addr.AddressBookId=addrbook.Id
								  where addr.AddTypeId=@associationcntctId And addrbook.IsLocal!=@addrbookIslocal)
  
  
  End
   Else 
    Begin

	   Print 'Enter for Inseting'
	   Set @newaddrBookId=NEWID()

       (Select * from @addrbookTemp where addrtempIsLocal=@addrbookIslocal)

        Insert Common.AddressBook Values( @newaddrBookId,(Select addrtempIsLocal from @addrbookTemp where addrtempIsLocal=@addrbookIslocal and addrbookStatus=1),(Select  addrtempBlockHouseNo from @addrbookTemp where addrtempIsLocal=@addrbookIslocal and addrbookStatus=1),(select addrtempStreet from @addrbookTemp where addrtempIsLocal=@addrbookIslocal and addrbookStatus=1),(select addrtempUnitNo from @addrbookTemp where addrtempIsLocal=@addrbookIslocal and addrbookStatus=1),
		(select addrtempBuildingEstate from @addrbookTemp where addrtempIsLocal=@addrbookIslocal and addrbookStatus=1),(select addrtempCity from @addrbookTemp where addrtempIsLocal=@addrbookIslocal and addrbookStatus=1),(select addrtempPostalCode from @addrbookTemp where addrtempIsLocal=@addrbookIslocal and addrbookStatus=1),
		(Select addrtempState from @addrbookTemp where addrtempIsLocal=@addrbookIslocal and addrbookStatus=1),(select addrtempCountry from @addrbookTemp where addrtempIsLocal=@addrbookIslocal and addrbookStatus=1),(select addrtempPhone from @addrbookTemp where addrtempIsLocal=@addrbookIslocal and addrbookStatus=1),(select addrtempEmail from @addrbookTemp where addrtempIsLocal=@addrbookIslocal and addrbookStatus=1),(select addrtempWebsite from @addrbookTemp where addrtempIsLocal=@addrbookIslocal and addrbookStatus=1),(select addrtempLatitude from @addrbookTemp where addrtempIsLocal=@addrbookIslocal and addrbookStatus=1),
		(select addrtempLongitude from @addrbookTemp where addrtempIsLocal=@addrbookIslocal and addrbookStatus=1),NULL,NULL,NULL,NULL,NULL,NULL,1,1,NULL)
 
      

      Insert Common.Addresses (Id,CompanyId,EntityId,AddTypeId,ScreenName,AddType,AddSectionType,AddressBookId,IsCurrentAddress,RelationId,Status)
      (Select NEWID(),adrtemp.addrCompanyId,@assciationEntityId,@associationcntctId,'Contacts',adrtemp.addrAddType,adrtemp.addrAddSectionType,@newaddrBookId,1,adrtemp.addrRelationId,adrtemp.addrStatus from @addrTemp as adrtemp
	  join @addrbookTemp as adbooktemp on adrtemp.addrAddressBookId=adbooktemp.addrtempId
	  where adbooktemp.addrtempIsLocal=@addrbookIslocal	And adrtemp.addrStatus=1)

    End

End

Else
Begin
Print 'enter into '
select @associationcntctId

 Set @addrsId =(Select addr.Id from Common.Addresses as addr 
               join common.AddressBook as addrbook on addr.AddressBookId=addrbook.Id
              where addr.AddSectionType in ('Registered Office Address','Residential Address')
              And addr.AddTypeId in (@associationcntctId) And addrbook.IsLocal=@addrbookIslocal And addr.Status=1) 
	
   If(@addrsId Is Not Null)
     Begin
	 Print 'Enter into update'
   (Select * from @addrbookTemp where addrtempIsLocal=@addrbookIslocal and addrbookStatus=1)
     Update Common.AddressBook Set
     IsLocal=(Select addrtempIsLocal from @addrbookTemp where addrtempIsLocal=@addrbookIslocal and addrbookStatus=1),
     BlockHouseNo=(Select addrtempBlockHouseNo from @addrbookTemp where addrtempIsLocal=@addrbookIslocal and addrbookStatus=1 ),
     Street=(Select addrtempStreet from @addrbookTemp where addrtempIsLocal=@addrbookIslocal and addrbookStatus=1),
     UnitNo=(Select addrtempUnitNo from @addrbookTemp where addrtempIsLocal=@addrbookIslocal and addrbookStatus=1),
     BuildingEstate=(Select addrtempBuildingEstate from @addrbookTemp where addrtempIsLocal=@addrbookIslocal and addrbookStatus=1),
     PostalCode=(Select addrtempPostalCode from @addrbookTemp where addrtempIsLocal=@addrbookIslocal and addrbookStatus=1),
     State=(Select addrtempState from @addrbookTemp where addrtempIsLocal=@addrbookIslocal and addrbookStatus=1),
     Country=(Select addrtempCountry from @addrbookTemp where addrtempIsLocal=@addrbookIslocal and addrbookStatus=1),
     Phone=(Select addrtempPhone from @addrbookTemp where addrtempIsLocal=@addrbookIslocal and addrbookStatus=1),
     Email=(Select addrtempEmail from @addrbookTemp where addrtempIsLocal=@addrbookIslocal and addrbookStatus=1),
     Website=(Select addrtempWebsite from @addrbookTemp where addrtempIsLocal=@addrbookIslocal and addrbookStatus=1),
     Latitude=(Select addrtempLatitude from @addrbookTemp where addrtempIsLocal=@addrbookIslocal and addrbookStatus=1),
     Longitude=(Select addrtempLongitude from @addrbookTemp where addrtempIsLocal=@addrbookIslocal and addrbookStatus=1)
  
    where Id in (
    Select addr.AddressBookId from Common.Addresses as addr 
    join Common.AddressBook as addrbook on addr.AddressBookId =addrbook.Id
    where (addr.AddSectionType='Registered Office Address' OR addr.AddSectionType='Residential Address')
    And addr.AddTypeId in (Select ContactId from @associationsTemp) And addrbook.IsLocal in (@addrbookIslocal) and addrbook.Id not in (@addrbooktempId) And addr.Status=1)
   
   
  End
   Else 
    Begin

	   Print 'Enter for Inseting'
	   Set @newaddrBookId=NEWID()

       (Select * from @addrbookTemp where addrtempIsLocal=@addrbookIslocal)

        Insert Common.AddressBook Values( @newaddrBookId,(Select addrtempIsLocal from @addrbookTemp where addrtempIsLocal=@addrbookIslocal and addrbookStatus=1),(Select  addrtempBlockHouseNo from @addrbookTemp where addrtempIsLocal=@addrbookIslocal and addrbookStatus=1),(select addrtempStreet from @addrbookTemp where addrtempIsLocal=@addrbookIslocal and addrbookStatus=1),(select addrtempUnitNo from @addrbookTemp where addrtempIsLocal=@addrbookIslocal and addrbookStatus=1),
		(select addrtempBuildingEstate from @addrbookTemp where addrtempIsLocal=@addrbookIslocal and addrbookStatus=1),(select addrtempCity from @addrbookTemp where addrtempIsLocal=@addrbookIslocal and addrbookStatus=1),(select addrtempPostalCode from @addrbookTemp where addrtempIsLocal=@addrbookIslocal and addrbookStatus=1),
		(Select addrtempState from @addrbookTemp where addrtempIsLocal=@addrbookIslocal and addrbookStatus=1),(select addrtempCountry from @addrbookTemp where addrtempIsLocal=@addrbookIslocal and addrbookStatus=1),(select addrtempPhone from @addrbookTemp where addrtempIsLocal=@addrbookIslocal and addrbookStatus=1),(select addrtempEmail from @addrbookTemp where addrtempIsLocal=@addrbookIslocal and addrbookStatus=1),(select addrtempWebsite from @addrbookTemp where addrtempIsLocal=@addrbookIslocal and addrbookStatus=1),(select addrtempLatitude from @addrbookTemp where addrtempIsLocal=@addrbookIslocal and addrbookStatus=1),
		(select addrtempLongitude from @addrbookTemp where addrtempIsLocal=@addrbookIslocal and addrbookStatus=1),NULL,NULL,NULL,NULL,NULL,NULL,1,1,NULL)
 
      

      Insert Common.Addresses (Id,CompanyId,EntityId,AddTypeId,ScreenName,AddType,AddSectionType,AddressBookId,IsCurrentAddress,RelationId,Status)
      (Select NEWID(),adrtemp.addrCompanyId,@assciationEntityId,@associationcntctId,'Contacts',adrtemp.addrAddType,adrtemp.addrAddSectionType,@newaddrBookId,1,adrtemp.addrRelationId,adrtemp.addrStatus from @addrTemp as adrtemp
	  join @addrbookTemp as adbooktemp on adrtemp.addrAddressBookId=adbooktemp.addrtempId
	  where adbooktemp.addrtempIsLocal=@addrbookIslocal	And adrtemp.addrStatus=1)

    End

End
  Fetch Next From addraddormodify into @addrbookIslocal,@addrbooktempId
  End

   

  Close  addraddormodify
  Deallocate addraddormodify
End
 
Fetch Next From assocationcontct into @associationcntctId,@assciationEntityId
End
close assocationcontct
Deallocate assocationcontct

Fetch Next From gccontactId into @gcId
End
close gccontactId
Deallocate gccontactId
End



End
GO
