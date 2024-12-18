USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[BR_Bizfile_Temp_delete]    Script Date: 16-12-2024 9.20.10 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

create Proc  [dbo].[BR_Bizfile_Temp_delete]
@entityId uniqueidentifier

as 
Begin
if Exists (select  id  from Common.EntityDetail where  Id=@entityId and IsBizTemp=1)
 BEGIN

 If Exists(select Id from Boardroom.EntityActivity where EntityId=@entityId)
   Begin
       Delete Boardroom.EntityActivity where EntityId=@entityId
   End
 If Exists(Select Id from Boardroom.Contacts where EntityId=@entityId)
   Begin
       Delete Boardroom.GenericContactDesignation where ContactId in (select Id from Boardroom.Contacts where EntityId=@entityId) and Position not in ('Shareholder')
	   Delete Boardroom.GenericContact where Id in (select Id from Boardroom.Contacts where EntityId=@entityId)
	   Delete Boardroom.Contacts where  Id in (select contactId from Boardroom.GenericContactDesignation where ContactId in (select Id from Boardroom.Contacts where EntityId=@entityId) and Position not in ('Shareholder')) 
   End
If Exists(Select Id from Boardroom.Allotment where EntityId=@entityId)
  Begin
       Delete Boardroom.TransactionLog where TransactionId in (select Id from [Boardroom].[Transaction] where EntityId=@entityId)
	   Delete Boardroom.[Transaction] where EntityId=@entityId
	   Delete Boardroom.AllotmentDetails where AllotmentId in (select Id from Boardroom.Allotment where EntityId=@entityId)
	   Delete Boardroom.Allotment where EntityId=@entityId
	   Delete Boardroom.GenericContactDesignation where ContactId in (select Id from Boardroom.Contacts where EntityId=@entityId) and Position  in ('Shareholder')
       Delete Boardroom.Contacts where  Id in (select contactId from Boardroom.GenericContactDesignation where ContactId in (select Id from Boardroom.Contacts where EntityId=@entityId) and Position  in ('Shareholder')) 

  End
  if exists(select Id from Boardroom.BRAGM where EntityId=@entityId)

  Begin
    Delete Boardroom.BRAGM where EntityId=@entityId
  End
  if Exists(select Id from Boardroom.Charge where EntityId=@entityId)
  Begin
    Delete Boardroom.Charge where EntityId=@entityId
  End


 End

 End


GO
