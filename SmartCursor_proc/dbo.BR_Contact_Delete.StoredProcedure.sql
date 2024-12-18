USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[BR_Contact_Delete]    Script Date: 16-12-2024 9.20.10 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE Proc [dbo].[BR_Contact_Delete]
@contactId uniqueidentifier, 
@entityId uniqueidentifier,
@companyId bigint
as 
BEGIN
Declare @count bigint,@genericContactId  uniqueidentifier,@ErrMsg Nvarchar(250)
 SET @count = (select COUNT(Id) from Boardroom.Contacts where EntityId=@entityId and IsEntity!=1)
  IF (@count>1)
  Begin
  If Exists(Select Id from Boardroom.OfficerChanges as oc where oc.ContactsId in (@contactId))
  Begin 
      SET @genericContactId=(Select GenericContactId from Boardroom.Contacts where Id=@contactId) 
        SET @genericContactId=(Select GenericContactId from Boardroom.Contacts where Id=@contactId) 
         If EXISTS(Select Id from Common.DocRepository where TypeId=@contactId and CompanyId=@companyId)
	        Begin
		      Update Common.DocRepository set Status=4 where TypeId=@contactId and CompanyId=@companyId
		    End
         If EXISTS (select Id from Common.Addresses where AddTypeId=@contactId and CompanyId=@companyId and EntityId=@entityId)
	       Begin
		    Update Common.AddressBook set Status=4 where Id in (select Id from Common.Addresses where AddTypeId=@contactId and CompanyId=@companyId and EntityId=@entityId)
			Update Common.Addresses  set Status=4 where AddTypeId=@contactId and CompanyId=@companyId and EntityId=@entityId
		   End
         If EXISTS(Select Id from Boardroom.GenericContactDesignation where ContactId=@contactId)
	        Begin
	           Update  Boardroom.GenericContactDesignation set Status=4 where ContactId=@contactId
	        End
			Update Boardroom.Contacts  set Status=4 where Id=@contactId
	     If NOT EXISTS (select Id from Boardroom.Contacts where GenericContactId=@genericContactId and Id!=@contactId and EntityId!=@entityId)  
	         Begin
	           Update Boardroom.GenericContact set Status=4 where Id=@genericContactId
	         End

  End
  Else If Exists(Select Id from Boardroom.[Transaction] as trans where trans.ContactId in (@contactId))
  Begin 
      SET @genericContactId=(Select GenericContactId from Boardroom.Contacts where Id=@contactId) 
         If EXISTS(Select Id from Common.DocRepository where TypeId=@contactId and CompanyId=@companyId)
	        Begin
		      Update Common.DocRepository set Status=4 where TypeId=@contactId and CompanyId=@companyId
		    End
         If EXISTS (select Id from Common.Addresses where AddTypeId=@contactId and CompanyId=@companyId and EntityId=@entityId)
	       Begin
		    Update Common.AddressBook set Status=4 where Id in (select Id from Common.Addresses where AddTypeId=@contactId and CompanyId=@companyId and EntityId=@entityId)
			Update Common.Addresses  set Status=4 where AddTypeId=@contactId and CompanyId=@companyId and EntityId=@entityId
		   End
         If EXISTS(Select Id from Boardroom.GenericContactDesignation where ContactId=@contactId)
	        Begin
	           Update  Boardroom.GenericContactDesignation set Status=4 where ContactId=@contactId
	        End
			Update Boardroom.Contacts  set Status=4 where Id=@contactId
	     If NOT EXISTS (select Id from Boardroom.Contacts where GenericContactId=@genericContactId and Id!=@contactId and EntityId!=@entityId)  
	         Begin
	           Update Boardroom.GenericContact set Status=4 where Id=@genericContactId
	         End

  End

   Else  IF EXISTS(select Id from Boardroom.Contacts where Id=@contactId )    
      Begin
         SET @genericContactId=(Select GenericContactId from Boardroom.Contacts where Id=@contactId) 
         If EXISTS(Select Id from Common.DocRepository where TypeId=@contactId and CompanyId=@companyId)
	        Begin
		      Delete Common.DocRepository where TypeId=@contactId and CompanyId=@companyId
		    End
         If EXISTS (select Id from Common.Addresses where AddTypeId=@contactId and CompanyId=@companyId and EntityId=@entityId)
	       Begin
		    Delete Common.AddressBook where Id in (select Id from Common.Addresses where AddTypeId=@contactId and CompanyId=@companyId and EntityId=@entityId)
			Delete Common.Addresses where AddTypeId=@contactId and CompanyId=@companyId and EntityId=@entityId
		   End
         If EXISTS(Select Id from Boardroom.GenericContactDesignation where ContactId=@contactId)
	        Begin
	           Delete Boardroom.GenericContactDesignation where ContactId=@contactId
	        End
			Delete Boardroom.Contacts where Id=@contactId
	     If NOT EXISTS (select Id from Boardroom.Contacts where GenericContactId=@genericContactId and Id!=@contactId and EntityId!=@entityId)  
	         Begin
	           Delete Boardroom.GenericContact where Id=@genericContactId
	         End
	     
	  set @ErrMsg='Contact Deleted Sucessfully.'
      End
	END
     Else
     Begin 
      Set @ErrMsg='Contact Changes Inprogress'
      END
  
      select @ErrMsg
End
GO
