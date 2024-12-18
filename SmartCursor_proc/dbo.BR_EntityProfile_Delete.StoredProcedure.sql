USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[BR_EntityProfile_Delete]    Script Date: 16-12-2024 9.20.10 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


--@entityId uniqueidentifier='c64ad3f4-ec09-42d8-94a8-659a4862351f',@companyId bigint=713

CREATE Proc [dbo].[BR_EntityProfile_Delete]
@entityIds nvarchar(MAX),

@companyId bigint

as 
BEGIN
 
Declare @entityId uniqueidentifier

Declare entityCursor cursor for 
(SELECT Convert(uniqueidentifier,value)
FROM STRING_SPLIT(@entityIds, ',')  
WHERE RTRIM(value) <> '')
Open entityCursor
FETCH NEXT FROM entityCursor into @entityId
 WHILE @@FETCH_STATUS = 0
 BEGIN
 if Exists (select  id  from Common.EntityDetail where CompanyId=@companyId and Id=@entityId)
 BEGIN
    Declare @screenId uniqueidentifier,@changeIn nvarchar(100)
    Declare entityChanges cursor for
    select Changein,Id from Boardroom.Changes where EntityId=@entityId
    Open entityChanges
    FETCH NEXT FROM entityChanges into @changeIn,@screenId
    WHILE @@FETCH_STATUS = 0
    BEGIN
    
       if(@changeIn='Entity Name')
        BEGIN
       	  Delete Boardroom.EntityChanges where ChangesId=@screenId
       	  Delete Common.DocRepository where TypeId=@screenId
       	END
       if(@changeIn='Activity')
       BEGIN
          Delete Boardroom.ActivityChanges where ChangesId=@screenId
       	  Delete Common.DocRepository where TypeId=@screenId
       End
       			
       if(@changeIn='Notice of Place Where Register of Members and Index is Kept')
       BEGIN
           Delete Boardroom.AdressesActivity where ChangesId=@screenId
       	   Delete Common.DocRepository where TypeId=@screenId
       End
       if(@changeIn='Registered Office Address or Office Hours')
       BEGIN
           Delete Boardroom.AdressesActivity where ChangesId=@screenId
       	   Delete Common.DocRepository where TypeId=@screenId
       	End	
       
       if(@changeIn='FYE')
       BEGIN
          Delete Boardroom.FYEChanges where ChangesId=@screenId
       	  Delete Common.DocRepository where TypeId=@screenId
       	End		
       if(@changeIn='Appointment or Cessation of Auditors')
       Begin
	    Delete Boardroom.ChangesAppointmentDetails where OfficerChangesId in (select Id from Boardroom.OfficerChanges where ChangesId=@screenId)
         Delete Boardroom.OfficerChanges where ChangesId=@screenId
       	 Delete Common.DocRepository where TypeId=@screenId
		  delete Boardroom.EntityChanges where ChangesId=@screenId
       End	
	   if(@changeIn='Appointment or Cessation of Officers')
       Begin
	      Delete Boardroom.ChangesAppointmentDetails where OfficerChangesId in (select Id from Boardroom.OfficerChanges where ChangesId=@screenId)
          Delete Boardroom.OfficerChanges where ChangesId=@screenId
       	  Delete Common.DocRepository where TypeId=@screenId
		  delete Boardroom.EntityChanges where ChangesId=@screenId
		  
       End	
        if(@changeIn='Appointment or Cessation of Registrable Controller')
       Begin
	      Delete Boardroom.ChangesAppointmentDetails where OfficerChangesId in (select Id from Boardroom.OfficerChanges where ChangesId=@screenId)
          Delete Boardroom.OfficerChanges where ChangesId=@screenId
       	  Delete Common.DocRepository where TypeId=@screenId
		  delete Boardroom.EntityChanges where ChangesId=@screenId
		  
       End	
       if(@changeIn='Change in Personal Particulars of Company Officers')
       Begin
          Delete Boardroom.OfficerChanges where ChangesId=@screenId
       	  Delete Common.DocRepository where TypeId=@screenId
		   Delete Boardroom.EntityChanges where ChangesId=@screenId
       End
       if(@changeIn='AGM and AR')
       Begin
        Delete Boardroom.AGMFillingChanges where ChangesId=@screenId
       end	
       		
       if(@changeIn='Extension of Time Under Section 175')
       Begin 
        Delete Boardroom.AGMChanges where ChangesId=@screenId
       end		
       		
       delete Boardroom.InCharge where ChangesId=@screenId
       delete Boardroom.GenerateTemplate where ChangesId=@screenId
       delete Boardroom.Changes where Id=@screenId
     
       			
       FETCH NEXT FROM entityChanges into @changeIn,@screenId
   END
   close entityChanges
   DEALLOCATE  entityChanges
    
  if exists (select Id from Boardroom.BRAGM where EntityId=@entityId)
   Begin
      delete Boardroom.BRAGM where EntityId=@entityId
   End
  

  if Exists (select Id from Boardroom.Allotment where EntityId=@entityId)
   Begin
   		Delete Boardroom.TransactionLog where TransactionId  in (select Id from Boardroom.[Transaction] where EntityId=@entityId)
	    Delete Common.DocRepository where TypeId in (select Id from Boardroom.[Transaction] where EntityId=@entityId)
 		Delete Boardroom.[Transaction] where  EntityId=@entityId
		Delete Boardroom.AllotmentDetails where AllotmentId in (select Id from Boardroom.Allotment where EntityId=@entityId)
		Delete Boardroom.Allotment where EntityId=@entityId
		 
         
   End
 

  if Exists (select Id from Boardroom.Contacts where EntityId=@entityId)
  Begin
   Delete Boardroom.ContactCommencementDetails where ContactId in (select Id from Boardroom.Contacts where EntityId=@entityId)
	Delete Boardroom.GenericContactDesignation where EntityId=@entityId
	
	Delete Common.DocRepository where TypeId in (select Id from Boardroom.Contacts where EntityId=@entityId)
	--Delete Boardroom.GenericContact where Id not in (select GenericContactId from Boardroom.Contacts where EntityId not in (@entityId)) and Id  in (select GenericContactId from Boardroom.Contacts where EntityId  in (@entityId))
	Delete Boardroom.GenericContact where Id in (select Id from Boardroom.Contacts where EntityId=@entityId)
	Delete Boardroom.Contacts where EntityId=@entityId
	 
  End


  if Exists (select Id from Boardroom.EntityActivity where EntityId=@entityId)
    begin 
         delete Boardroom.EntityActivity where EntityId=@entityId
    End
 

 Delete Common.AddressBook where Id in (select Id from Common.Addresses where EntityId=@entityId and EntityId Is not null)
 Delete Common.Addresses where EntityId=@entityId and EntityId Is not null
 Delete Boardroom.Remindersent where EntityId=@entityId
 Delete Common.CommunicationFiles where CommunicationId in  (select Id from Common.Communication where TemplateId=@entityId	)
 Delete Common.Communication where TemplateId=@entityId	
 
 delete Common.ChangesHistory where DynamicTemplateId in (select Id from Boardroom.DynamicTemplates where EntityId=@entityId)
 Delete Boardroom.InCharge where DynamicTemplateId in (select Id from Boardroom.DynamicTemplates where EntityId=@entityId)
 delete Boardroom.DynamicTemplatesDetail where DynamicTemplateId in (select Id from Boardroom.DynamicTemplates where EntityId=@entityId)
 delete Boardroom.GenerateTemplate where DynamicTemplateId in (select Id from Boardroom.DynamicTemplates where EntityId=@entityId)
 Delete Boardroom.DynamicTemplates where EntityId=@entityId

 Delete Boardroom.EntityIncharge where EntityId=@entityId
 Delete Boardroom.Charge where EntityId=@entityId
 --Delete Boardroom.TemplateSent where EntityId=@entityId
 Delete Common.EntityDetail where CompanyId=@companyId and Id=@entityId

 End
FETCH NEXT FROM entityCursor into @entityId
   END
   close entityCursor
   DEALLOCATE  entityCursor
End
GO
