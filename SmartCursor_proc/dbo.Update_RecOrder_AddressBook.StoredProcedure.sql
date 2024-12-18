USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[Update_RecOrder_AddressBook]    Script Date: 16-12-2024 9.20.11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE procedure [dbo].[Update_RecOrder_AddressBook] ---------------exec Update_RecOrder_AddressBook
as
begin 

Declare @companyId int=1,
@ClientId Uniqueidentifier,
@AccountId Uniqueidentifier

 ---======================Address book update  order by Recorder ------AddType_ client

Declare AccountId_Get Cursor For

 select distinct  A.AddTypeId from Common.AddressBook K  INNER JOIN Common.Addresses A ON A.AddressBookId=K.Id  INNER JOIN WorkFlow.Client AA ON AA.ID=A.AddTypeId  WHERE   aa.CompanyId=@companyId and K.RecOrder IS NULL and A.AddType ='Client'   ORDER BY A.AddTypeId

Open AccountId_Get
fetch next from AccountId_Get Into @ClientId
While @@FETCH_STATUS=0

Begin
--------------------- insert into clientid in WorkFlow.Client
 --select k.RecOrder from 
update k set k.RecOrder=1
  from Common.AddressBook K  INNER JOIN Common.Addresses A ON A.AddressBookId=K.Id  INNER JOIN WorkFlow.Client AA ON AA.ID=A.AddTypeId  WHERE   aa.CompanyId=@companyId  and A.AddTypeId= @ClientId and K.RecOrder IS NULL and A.AddType ='Client' and A.AddSectionType='Registered Address'  --select k.RecOrder from  update k set k.RecOrder=2
   from  Common.AddressBook K  INNER JOIN Common.Addresses A ON A.AddressBookId=K.Id  INNER JOIN WorkFlow.Client AA ON AA.ID=A.AddTypeId  WHERE   aa.CompanyId=@companyId  and A.AddTypeId= @ClientId and K.RecOrder IS NULL and A.AddType ='Client' and A.AddSectionType='Mailing Address'    --select k.RecOrder  from  update k set k.RecOrder=3
  from Common.AddressBook K  INNER JOIN Common.Addresses A ON A.AddressBookId=K.Id  INNER JOIN WorkFlow.Client AA ON AA.ID=A.AddTypeId  WHERE   aa.CompanyId=@companyId  and A.AddTypeId= @ClientId and K.RecOrder IS NULL and A.AddType ='Client' and A.AddSectionType='Others'

fetch next from AccountId_Get Into @ClientId

End
Close AccountId_Get
Deallocate AccountId_Get




---======================Address book update  order by Recorder ------AddType Accouts

Declare AccountId_Get Cursor For

 select distinct  A.AddTypeId from Common.AddressBook K  INNER JOIN Common.Addresses A ON A.AddressBookId=K.Id  INNER JOIN ClientCursor.Account AA ON AA.ID=A.AddTypeId  WHERE   aa.CompanyId=@companyId and K.RecOrder IS NULL and A.AddType ='Account'   ORDER BY A.AddTypeId

Open AccountId_Get
fetch next from AccountId_Get Into @AccountId
While @@FETCH_STATUS=0

Begin
--------------------- insert into clientid in WorkFlow.Client
 --select k.RecOrder from 
update k set k.RecOrder=1
  from Common.AddressBook K  INNER JOIN Common.Addresses A ON A.AddressBookId=K.Id  INNER JOIN ClientCursor.Account AA ON AA.ID=A.AddTypeId  WHERE   aa.CompanyId=@companyId  and A.AddTypeId= @AccountId and K.RecOrder IS NULL and A.AddType ='Account' and A.AddSectionType='Registered Address'  --select k.RecOrder from  update k set k.RecOrder=2
   from  Common.AddressBook K  INNER JOIN Common.Addresses A ON A.AddressBookId=K.Id  INNER JOIN ClientCursor.Account AA ON AA.ID=A.AddTypeId  WHERE   aa.CompanyId=@companyId  and A.AddTypeId= @AccountId and K.RecOrder IS NULL and A.AddType ='Account' and A.AddSectionType='Mailing Address'    --select k.RecOrder  from  update k set k.RecOrder=3
  from Common.AddressBook K  INNER JOIN Common.Addresses A ON A.AddressBookId=K.Id  INNER JOIN ClientCursor.Account AA ON AA.ID=A.AddTypeId  WHERE   aa.CompanyId=@companyId  and A.AddTypeId= @AccountId and K.RecOrder IS NULL and A.AddType ='Account' and A.AddSectionType='Others'

fetch next from AccountId_Get Into @AccountId

End
Close AccountId_Get
Deallocate AccountId_Get

--======================================================================= STEP 9  end

--======================================================================= STEP 10  begin  not exc  only check data

 --    ---UPDATE K SET RecOrder=2 	--     SELECT A.AddTypeId,K.RecOrder,A.AddSectionType 	-- from Common.AddressBook K -- INNER JOIN Common.Addresses A ON A.AddressBookId=K.Id -- INNER JOIN ClientCursor.Account AA ON AA.ID=A.AddTypeId -- WHERE   aa.CompanyId=1 and A.AddType ='Account' AND  A.AddTypeId='6663551E-BA17-415A-A14C-4503042041DE' AND A.AddSectionType='Others'



 --  --update k set k.RecOrder=1
 --   SELECT A.AddTypeId,K.RecOrder,A.AddSectionType 	--from  Common.AddressBook K -- INNER JOIN Common.Addresses A ON A.AddressBookId=K.Id -- INNER JOIN WorkFlow.Client AA ON AA.ID=A.AddTypeId -- WHERE   aa.CompanyId=1  AND  A.AddTypeId='6957601F-2A96-4654-ABD7-3107B8C528AD'  and A.AddType ='Client' and A.AddSectionType='Mailing Address'   --======================================================================= STEP 10 end  end 
GO
