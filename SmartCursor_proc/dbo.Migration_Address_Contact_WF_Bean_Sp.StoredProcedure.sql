USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[Migration_Address_Contact_WF_Bean_Sp]    Script Date: 16-12-2024 9.20.10 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




create procedure [dbo].[Migration_Address_Contact_WF_Bean_Sp]  ---- EXEC  [dbo].[Migration_Address_Contact_WF_Bean_Sp] 1
@CompanyId bigint
as
begin

Declare
@AddTypeId Uniqueidentifier,
@AddType nvarchar(50),
@Contact Uniqueidentifier,
@Account Uniqueidentifier,
@Client Uniqueidentifier,
@Entity Uniqueidentifier
   Declare Addresses_Get Cursor For

		SELECT Distinct AddTypeId,AddType FROM Common.Addresses WHERE AddType='Contact' ---and  AddTypeId=@AddTypeId
		Open Addresses_Get
		fetch next from Addresses_Get Into @AddTypeId,@AddType
		While @@FETCH_STATUS=0
		BEGIN

		            set @Contact= (select distinct Id from Common.Contact WHERE CompanyId=@CompanyId and   ID IN(select  distinct   AddTypeId  from Common.Addresses where   AddTypeId=@AddTypeId)  )
				    set @Account= (	select distinct cd.Id from Common.ContactDetails cd inner join Common.Contact c on c.id=cd.ContactId WHERE c.CompanyId=@CompanyId and EntityType='Account' AND cd.Id IN(select  distinct   AddTypeId  from Common.Addresses where   AddTypeId=@AddTypeId)  )
				    set @Client= ( select distinct cd.Id from Common.ContactDetails cd inner join Common.Contact c on c.id=cd.ContactId WHERE c.CompanyId=@CompanyId and EntityType='Client' AND cd.Id IN (select  distinct   AddTypeId  from Common.Addresses where   AddTypeId=@AddTypeId ) )
					 set @Entity= ( select distinct cd.Id from Common.ContactDetails cd inner join Common.Contact c on c.id=cd.ContactId WHERE c.CompanyId=@CompanyId and EntityType='Entity' AND cd.Id IN (select  distinct   AddTypeId  from Common.Addresses where   AddTypeId=@AddTypeId )  )

					    If (@Contact is not null)
					       begin
						 update  C SET Id=Id,AddSectionType=AddSectionType,AddType=AddType,AddTypeId=AddTypeId,AddTypeIdInt=AddTypeIdInt,AddressBookId=AddressBookId,Status=Status,DocumentId=DocumentId,EntityId=EntityId,ScreenName=ScreenName,IsCurrentAddress=IsCurrentAddress,CompanyId=@CompanyId From Common.Addresses C Where AddTypeId=@AddTypeId and AddType=@AddType
				           end
				        If (@Account is not null)
					      begin
						  update  C SET Id=Id,AddSectionType=AddSectionType,AddType='AccountContactDetailId',AddTypeId=AddTypeId,AddTypeIdInt=AddTypeIdInt,AddressBookId=AddressBookId,Status=Status,DocumentId=DocumentId,EntityId=EntityId,ScreenName=ScreenName,IsCurrentAddress=IsCurrentAddress,CompanyId=@CompanyId From Common.Addresses C Where AddTypeId=@AddTypeId and AddType=@AddType
						   end
						If (@Client is not null)
					      begin
						 update  C SET Id=Id,AddSectionType=AddSectionType,AddType='ClientContactDetailId',AddTypeId=AddTypeId,AddTypeIdInt=AddTypeIdInt,AddressBookId=AddressBookId,Status=Status,DocumentId=DocumentId,EntityId=EntityId,ScreenName=ScreenName,IsCurrentAddress=IsCurrentAddress,CompanyId=@CompanyId From Common.Addresses C Where AddTypeId=@AddTypeId and AddType=@AddType
						  end
						If (@Entity is not null)
					      begin
						  update  C SET Id=Id,AddSectionType=AddSectionType,AddType='EntityContactDetailId',AddTypeId=AddTypeId,AddTypeIdInt=AddTypeIdInt,AddressBookId=AddressBookId,Status=Status,DocumentId=DocumentId,EntityId=EntityId,ScreenName=ScreenName,IsCurrentAddress=IsCurrentAddress,CompanyId=@CompanyId From Common.Addresses C Where AddTypeId=@AddTypeId and AddType=@AddType
		                  end
		  
		 fetch next from Addresses_Get Into @AddTypeId,@AddType
	
		 End 
		 Close Addresses_Get
		 Deallocate Addresses_Get

		 end




----================================================================address  contact contactdetail ====================================================================================

--select distinct Id from Common.Contact WHERE CompanyId=1 and   ID IN(select  distinct   AddTypeId  from Common.Addresses ) ---171 
--select distinct cd.Id from Common.ContactDetails cd inner join Common.Contact c on c.id=cd.ContactId WHERE c.CompanyId=@CompanyId and EntityType='Account' AND cd.Id IN(select  distinct   AddTypeId  from Common.Addresses )
--select distinct cd.Id from Common.ContactDetails cd inner join Common.Contact c on c.id=cd.ContactId WHERE c.CompanyId=@CompanyId and EntityType='Client' AND cd.Id IN (select  distinct   AddTypeId  from Common.Addresses )
--select distinct cd.Id from Common.ContactDetails cd inner join Common.Contact c on c.id=cd.ContactId WHERE c.CompanyId=@CompanyId and EntityType='Entity' AND cd.Id IN (select  distinct   AddTypeId  from Common.Addresses ) 

----================================================= ADDRESS CONTACT CONTACT DETAIL ==============================================================

-------===================== CHECK CONTACT IDS 1
--select * from Common.Contact WHERE CompanyId=1 and   ID IN(select  distinct   AddTypeId  from Common.Addresses WHERE AddType IN ('AccountContact','ClientContact','BeanContact')) ---171

--SELECT * from Common.Addresses C  WHERE AddTypeId IN (select DISTINCT iD from Common.Contact WHERE CompanyId=1) ORDER BY AddTypeId
-------===================== CHECK CONTACTDetails IDS 2
--select * from Common.ContactDetails CD INNER JOIN Common.Contact C ON C.ID=CD.ContactId
-- WHERE CompanyId=1 and   CD.Id IN(select  distinct   AddTypeId  from Common.Addresses  ) 
-- ORDER BY EntityType -----------52 ACCOUNT,9 CLIENT,9 ENTITY


-- select  * from Common.Addresses WHERE AddTypeId IN(select DISTINCT CD.Id from Common.ContactDetails CD INNER JOIN Common.Contact C ON C.ID=CD.ContactId WHERE CompanyId=1) ORDER BY AddTypeId

---------=============UPDATE CONTACT 3

-- UPDATE C SET AddType='Contact' from Common.Addresses C  WHERE AddTypeId IN (select DISTINCT iD from Common.Contact WHERE CompanyId=1)
-- UPDATE C SET AddType='Contact'  from Common.Addresses C WHERE AddTypeId IN(select DISTINCT CD.Id from Common.ContactDetails CD INNER JOIN Common.Contact C ON C.ID=CD.ContactId WHERE CompanyId=1)

-------============== CHECK MORE THEN 3  AddTypeId CONTACT  4

--  select  AddTypeId from  Common.Addresses where  AddType in('Contact') and AddTypeId 
--  in ( select DISTINCT iD from Common.Contact WHERE CompanyId=1) 
--  group by AddTypeId
--  having count(AddType)>1
--  order by AddTypeId 

--  -----============== CHECK MORE THEN 3  AddTypeId CONTACT Detail ids 5

--  select  AddTypeId from  Common.Addresses where  AddType in('Contact') and AddTypeId 
--  in ( select DISTINCT CD.Id from Common.ContactDetails CD INNER JOIN Common.Contact C ON C.ID=CD.ContactId WHERE CompanyId=1) 
--  group by AddTypeId
--  having count(AddType)>1
--  order by AddTypeId 

--  --===================================== exec [dbo].[Migration_Address_Contact_WF_Bean_Sp] 5

--  -----===================== CHECK  data CONTACT IDS 6
--select * from Common.Contact WHERE CompanyId=1 and   ID IN(select  distinct   AddTypeId  from Common.Addresses WHERE AddType IN ('AccountContact','ClientContact','BeanContact')) ---171

--SELECT * from Common.Addresses C  WHERE AddTypeId IN (select DISTINCT iD from Common.Contact WHERE CompanyId=1) ORDER BY AddTypeId
-------===================== CHECK  data CONTACTDetails IDS 7
--select * from Common.ContactDetails CD INNER JOIN Common.Contact C ON C.ID=CD.ContactId
-- WHERE CompanyId=1 and   CD.Id IN(select  distinct   AddTypeId  from Common.Addresses  ) 
-- ORDER BY EntityType -----------52 ACCOUNT,9 CLIENT,9 ENTITY


-- select  * from Common.Addresses WHERE AddTypeId IN(select DISTINCT CD.Id from Common.ContactDetails CD INNER JOIN Common.Contact C ON C.ID=CD.ContactId WHERE CompanyId=1) ORDER BY AddTypeId

-- --============================= end 


	
GO
