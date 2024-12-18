USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [Import].[BRInsertIntoEntityShare]    Script Date: 16-12-2024 9.20.11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
 CREATE Procedure [Import].[BRInsertIntoEntityShare]  
 --Exec [Import].[BRInsertIntoEntityDetails] 2248,'F3C77FF3-6679-4DEA-819D-569DFF1EA5E8','BR Cursor-Entity Details'
 @companyId int,
 @TransactionId uniqueidentifier,
 @ScreenName Nvarchar(124)
 AS 
 Begin 
  
 -- Declare @companyId int=689,
 --@TransactionId uniqueidentifier='C3BEE5B2-E87D-4BE6-B952-0D73653570C8'
  BEGIN TRANSACTION;
 BEGIN TRY
     declare @startdate [datetime2](7)
     declare @Enddate [datetime2](7)
     SET @startdate= GETUTCDATE()
 --================================================ insert SuccessEnity data into  Boardroom.GenericContact: --==========================================
  insert into SmartCursorTST. Boardroom.GenericContact( id,[name],ShortName,Category,IdNumber,CompanyId,UserCreated,CreatedDate,[status] )
  select 
  GenericContactId,ContactName,ShortName,Category,IdNumber,CompanyId,'System'UserCreated,GETUTCDATE() as CreatedDate,1 as [Status]
 from [Import].[BRSuccessEntityShareContact] where TransactionId=@TransactionId and CompanyId=@companyId
 
 -- --================================================ insert SuccessEnity data into  Boardroom.contacts: --==========================================
  insert into SmartCursorTST.Boardroom.contacts
  ( id,GenericContactId,EntityId,IsEntity,CompanyId,UserCreated,CreatedDate,[status],[State],IsTemporary)
  select 
  ContactId,GenericContactId,EntityId,1 as IsEntity,CompanyId,'System'UserCreated,GETUTCDATE() as CreatedDate,1 as [Status], 'Active' as [State], 0 as IsTemporary 
  from [Import].[BRSuccessEntityShareContact] where TransactionId=@TransactionId and CompanyId=@companyId

 -- --================================================ insert SuccessEnity data into  Boardroom.GenericContactDesignation --=======================================
  INSERT INTO  SmartCursorTST.Boardroom.GenericContactDesignation
  (id,CompanyId,EntityId,ContactId,GenericContactId,UserCreated,CreatedDate,[status],[type],Position,ShortCode )
  select 
  NewId() as Id,CompanyId,EntityId,ContactId,GenericContactId,'System'UserCreated,GETUTCDATE() as CreatedDate,1 as [Status],'Shareholder' as [type], 'Shareholder' as Position,'SH' as ShortCode
  from [Import].[BRSuccessEntityShareContact] where TransactionId=@TransactionId and CompanyId=@companyId

   -- --================================================ insert SuccessEnity data into  Common.AddressBook: --========================
   INSERT INTO SmartCursorTST.Common.AddressBook
   ( ID,IsLocal,BlockHouseNo,Street,UnitNo,BuildingEstate,City,PostalCode,State,Country,RecOrder,UserCreated,CreatedDate,Status)
   select 
   AddressBookId, CASE WHEN [Local Address/ Foreign Address]='LOCAL ADDRESS' THEN 1 ELSE 0 END IsLocal ,[BlockHouse No],	
   Street,Unitno,	BuildingEstate,	City,PostalCode,City,City, 1 AS RecOrder,'System'UserCreated,GETUTCDATE() as CreatedDate,1 AS [Status]
   from [Import].[BRSuccessEntityShareContact] where TransactionId=@TransactionId and CompanyId=@companyId

   -- --================================================ insert SuccessEnity data into  Common.Address: --========================
   select * from Common.Addresses
    insert into  SmartCursorTST.Common.Addresses
	 ( ID,AddressBookId,AddSectionType,AddType,AddTypeId,EntityId,ScreenName,IsCurrentAddress,CompanyId, [Status] )
	 select 
    Newid() as Id,AddressBookId,[Address Type] as AddSectionType, 'EntityContactDetailId' as AddType,GenericContactId as AddTypeId,EntityId,'EntityContactDetailId' as ScreenName, 1 as IsCurrentAddress,CompanyId,1 AS [Status]
   from [Import].[BRSuccessEntityShareContact] where TransactionId=@TransactionId and CompanyId=@companyId

   -- --================================================ insert SuccessEnity data into  Boardroom.EntityActivity: --========================

  
 --===================================================================================================
     SET @Enddate= GETUTCDATE()
    insert into SmartCursorTST.[Import].[TransactionDetails]
    select newid(),@companyId,@TransactionId,@ScreenName,@startdate,@Enddate,'InsertIntoEntityDetails Completed',(select count(*) from  [Import].[BREnity] where TransactionId= @TransactionId ),( select count(*) from [Import].[BRFailureEnity] where TransactionId=@TransactionId),
    ( select count(*) from [Import].[BRSuccessEnity] where TransactionId=@TransactionId),null




  COMMIT TRANSACTION;
END TRY
BEGIN CATCH
	Declare @ErrorMessage Nvarchar(4000)
	ROLLBACK;
	Select @ErrorMessage=error_message();
	  If @ErrorMessage is not null
	  begin 
	  insert into SmartCursorTST.[Import].[TransactionDetails]
	  select newid(),@companyId,@TransactionId,@ScreenName,GETUTCDATE(),GETUTCDATE(),'InsertIntoEntityDetails Error',(select count(*) from [Import].[BREnity] where TransactionId= @TransactionId ),(select count(*) from [Import].[BREnity] where TransactionId= @TransactionId ),null,@ErrorMessage
	  end 
	Raiserror(@ErrorMessage,16,1);
END CATCH

 update c set c.BlockHouseNo='', c.BuildingEstate=''  from  SmartCursorTST.Common.AddressBook c
 inner join SmartCursorTST.Common.Addresses a on a.AddressBookId=c.Id
 where a.CompanyId=@companyId 
  and c.BlockHouseNo is null and  c.BuildingEstate is null

  end
GO
