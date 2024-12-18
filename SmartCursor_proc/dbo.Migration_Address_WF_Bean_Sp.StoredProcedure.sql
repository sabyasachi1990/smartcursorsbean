USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[Migration_Address_WF_Bean_Sp]    Script Date: 16-12-2024 9.20.10 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


create procedure [dbo].[Migration_Address_WF_Bean_Sp]   ---Exec  [dbo].[Migration_Address_WF_Bean_Sp] 1 
@CompanyId bigint
as
begin

Declare
---@CompanyId bigint=1,
@AddTypeId Uniqueidentifier,
@AddType nvarchar(50),
@SyncClientId Uniqueidentifier,
@SyncEntityId Uniqueidentifier

   Declare Addresses_Get Cursor For

		SELECT Distinct AddTypeId,AddType FROM Common.Addresses WHERE AddType='Account' --and  AddTypeId=@AddTypeId
		Open Addresses_Get
		fetch next from Addresses_Get Into @AddTypeId,@AddType
		While @@FETCH_STATUS=0
		BEGIN

		  If Not Exists ( select Distinct AddTypeId  FROM Common.Addresses where  AddType='Client' AND AddTypeId in(select  SyncClientId  from ClientCursor.Account where  Id=@AddTypeId and CompanyId=@companyId))
             Begin
			 If Not Exists ( select Distinct AddTypeId  FROM Common.Addresses where  AddType='Entity' AND AddTypeId in(select  SyncEntityId  from ClientCursor.Account where  Id=@AddTypeId and CompanyId=@companyId))
               Begin
                If Exists ( select  SyncClientId  from ClientCursor.Account where  Id=@AddTypeId and CompanyId=@companyId )
                 Begin
			      If Exists ( select  SyncEntityId  from ClientCursor.Account where  Id=@AddTypeId and CompanyId=@companyId )
                    Begin
				    set @SyncClientId= (select  SyncClientId  from ClientCursor.Account where  Id=@AddTypeId and CompanyId=@companyId )
				    set @SyncEntityId= (select  SyncEntityId  from ClientCursor.Account where  Id=@AddTypeId and CompanyId=@companyId )
					    If (@SyncClientId is not null)
					    begin

						 Insert Into Common.Addresses(Id,AddSectionType,AddType,AddTypeId,AddTypeIdInt,AddressBookId,Status,DocumentId,EntityId,ScreenName,IsCurrentAddress,CompanyId,CopyId)
						 Select NEWID(),AddSectionType,'Client',@SyncClientId,AddTypeIdInt,AddressBookId,Status,DocumentId,EntityId,ScreenName,IsCurrentAddress,@CompanyId,CopyId From Common.Addresses Where AddTypeId=@AddTypeId and AddType=@AddType
				         end
				
				         If (@SyncEntityId is not null)
					     begin
					    Insert Into Common.Addresses(Id,AddSectionType,AddType,AddTypeId,AddTypeIdInt,AddressBookId,Status,DocumentId,EntityId,ScreenName,IsCurrentAddress,CompanyId,CopyId)
						 Select NEWID(),AddSectionType,'Entity',@SyncEntityId,AddTypeIdInt,AddressBookId,Status,DocumentId,EntityId,ScreenName,IsCurrentAddress,@CompanyId,CopyId From Common.Addresses Where AddTypeId=@AddTypeId and AddType=@AddType
		                 end
				   End
		        End
		      End
		  End


		 fetch next from Addresses_Get Into @AddTypeId,@AddType
	
		 End 
		 Close Addresses_Get
		 Deallocate Addresses_Get
		 end 



--================================================================address====================================================================================
--select distinct id from ClientCursor.Account where Status=1 and IsAccount=1 and CompanyId=1 --------1124
--select distinct SyncClientId from ClientCursor.Account where Status=1 and IsAccount=1 and CompanyId=1  --------1124
--select distinct  SyncEntityId from ClientCursor.Account where Status=1 and IsAccount=1 and CompanyId=1 ---- 1124
------
--select distinct id from WorkFlow.Client where CompanyId=1 ------1124
--select distinct SyncAccountId from WorkFlow.Client where CompanyId=1 ------1124
--select distinct SyncEntityId from WorkFlow.Client where CompanyId=1 ------1124
-------
--select distinct id from Bean.Entity where CompanyId=1 --1266
--select distinct  SyncAccountId from Bean.Entity where CompanyId=1 --1124
--select distinct SyncClientId from Bean.Entity where CompanyId=1 --1124
--select distinct SyncEmployeeId from Bean.Entity where CompanyId=1 --0
---------
--select distinct id from Common.Employee where CompanyId=1 --93
--select distinct SyncEntityId from Common.Employee where CompanyId=1 ---0

--	-------=============Account 1
		
--	select distinct AddTypeId from  Common.Addresses where  AddType in('Account') and AddTypeId in ( select distinct id from ClientCursor.Account where Id is not null  and CompanyId=1  and status=1 and IsAccount=1) --1110

--  select * from ClientCursor.Account where Id is not null  and CompanyId=1  and status=1 and IsAccount=1 and id  not in (	select distinct AddTypeId from  Common.Addresses where  AddType in('Account') ) --14

----------------=======client 2

--select distinct AddTypeId from  Common.Addresses where  AddType in('client') and AddTypeId in ( select distinct Id  from WorkFlow.Client where Id is not null  and CompanyId=1 ) --1122

--select * from WorkFlow.Client where Id is not null  and CompanyId=1 and Id  not in ( select distinct AddTypeId from  Common.Addresses where  AddType in('client') ) --2
----------------========Entity 3

--select distinct AddTypeId from  Common.Addresses where  AddType in('Entity') and AddTypeId in ( select distinct Id  from bean.Entity where SyncClientId is not null  and CompanyId=1  ) ---1122

--select * from Bean.Entity where SyncAccountId is not null  and CompanyId=1  and Id  not in (select distinct AddTypeId from  Common.Addresses where  AddType in('Entity')) ---2

----------------======== Delete client  and  Entity 4


--delete from  Common.Addresses where  AddType in('Entity') and AddTypeId in (select distinct Id  from bean.Entity where SyncClientId is not null  and CompanyId=1 )-----2101

--delete from  Common.Addresses where  AddType in('client') and AddTypeId in ( select distinct Id  from WorkFlow.Client where Id is not null  and CompanyId=1 ) --2101


-----------========== check data delete client  and  Entity 5

--	select distinct AddTypeId from  Common.Addresses where  AddType in('Account') and AddTypeId in ( select distinct id from ClientCursor.Account where Id is not null  and CompanyId=1  and status=1 and IsAccount=1) --1110
--	select distinct AddTypeId from  Common.Addresses where  AddType in('client') and AddTypeId in ( select distinct Id  from WorkFlow.Client where Id is not null  and CompanyId=1 ) --1110
--	select distinct AddTypeId from  Common.Addresses where  AddType in('Entity') and AddTypeId in ( select distinct Id  from bean.Entity where SyncClientId is not null  and CompanyId=1  ) ---1110

-------============== CHECK MORE THEN 3  AddTypeId Account 6

--  select AddTypeId from  Common.Addresses where  AddType in('Account') and AddTypeId 
--  in ( select distinct id from ClientCursor.Account where Id is not null  and CompanyId=1  and status=1 and IsAccount=1) 
--  group by AddTypeId
--  having count(AddType)>2
--  order by AddTypeId 
-----============== AddSectionType='Others' accountids 7

--  select * from  Common.Addresses where AddTypeId in (
--'C6819658-B22D-425A-98C2-0AE2A55F1036',
--'76DCAFF9-EA8E-4C57-BD88-1A2071A53EC5',
--'13FC75E7-D71E-45BD-B7C0-4AA18022BBD5',
--'4AD71540-49C2-4802-95B7-78E2F17A9A0A',
--'EEE69629-AB72-4C9D-A871-824C8D994BDC',
--'4327DF9C-60A7-43B5-9DAA-913FF0819709')
--and AddSectionType='Others'
--order by AddTypeId

-----============== AddSectionType='Others' AddressBookIds 8

-- select * from  Common.Addresses where AddressBookId in(
--'E47D7951-3992-456E-B61C-C3F21F89369E',
--'417D0863-3443-4DC5-BA18-CEDA63661A38',
--'39986DC3-9DAA-4034-B684-0F217EC32519',
--'C68FBD1D-2918-4FC7-B323-CD5C39B767FA',
--'AB01ABF6-3FBC-4668-819F-735E007ABE06',
--'E534DE97-F009-49C2-893E-52577F309645')
--order by AddressBookId
-----===================== delete AddressBookIds more then 2 AddSectionType='Others' 9

--delete from  Common.Addresses where AddressBookId in(
--'E47D7951-3992-456E-B61C-C3F21F89369E',
--'417D0863-3443-4DC5-BA18-CEDA63661A38',
--'39986DC3-9DAA-4034-B684-0F217EC32519',
--'C68FBD1D-2918-4FC7-B323-CD5C39B767FA',
--'AB01ABF6-3FBC-4668-819F-735E007ABE06',
--'E534DE97-F009-49C2-893E-52577F309645')
------------------- =========  check data delete Account 10

--		select * from  Common.Addresses where  AddType in('Account') and AddTypeId in ( select distinct id from ClientCursor.Account where Id is not null  and CompanyId=1  and status=1 and IsAccount=1) order by AddTypeId --1790

------=========== EXEC [dbo].[Migration_Address_WF_Bean_Sp] AND CHECK DATA Account client Entity 11

--select * from  Common.Addresses where  AddType in('Account') and AddTypeId in ( select distinct id from ClientCursor.Account where Id is not null  and CompanyId=1  and status=1 and IsAccount=1) order by AddTypeId --1790
--select * from  Common.Addresses where  AddType in('client') and AddTypeId in ( select distinct Id  from WorkFlow.Client where Id is not null  and CompanyId=1 ) --1790
--select * from  Common.Addresses where  AddType in('Entity') and AddTypeId in ( select distinct Id  from bean.Entity where SyncClientId is not null  and CompanyId=1  ) ---1790
GO
