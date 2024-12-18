USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[ASSOCIATION_COUNT_UPDATE_New]    Script Date: 16-12-2024 9.20.10 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   Procedure [dbo].[ASSOCIATION_COUNT_UPDATE_New] ------------  EXEC [dbo].[ASSOCIATION_COUNT_UPDATE_New] 
AS
BEGIN

DEclare 
@Id uniqueidentifier,
@Count Int,
@Idcount int=1
--==================================== exec [dbo].[ASSOCIATION_COUNT_UPDATE_New] =======================================================

Declare @Temp_AssociationCountPBI Table (AccountId uniqueidentifier,AssociationCount Int )

Declare @Acc_tbl Table (S_No Int Identity(1,1),AccountId Uniqueidentifier)

Insert Into @Acc_tbl
Select Id From ClientCursor.Account where Status=1

--Select * From @Acc_tbl

Select @Count=count(Id) From ClientCursor.Account  where Status=1

While @Idcount<=@Count
Begin

Select @id=AccountId From @Acc_tbl Where S_No=@Idcount

Insert Into @Temp_AssociationCountPBI

SELECT @Id as Accountid,count(distinct SSK.Id) 'AssociationCount'
FROM

(

Select E.TenantId,A.ID, A.Name

From Common.ContactDetails CD
Inner join ClientCursor.Account A On A.id=CD.EntityId
Left JOIN ClientCursor.Opportunity o ON O.AccountId=A.Id
left Join Common.ServiceGroup SG on SG.Id=O.ServiceGroupId
inner join Common.Company e on e.Id=A.CompanyId
Where EntityType='Account' and CD.EntityId<>@Id 
and   a.AccountStatus not in ('Lost','Inactive') and a.Status=1
and (o.Status=1 or o.status is null )and (IsTemp is null or IsTemp=0)


And CD.ContactId in
(
Select AC.Contactid from Common.ContactDetails AC
Inner Join ClientCursor.Account A on A.id=AC.EntityId
Inner Join Common.Contact C on C.id=AC.Contactid
Where A.ID=@Id  and 
exists ( Select ContactId from Common.ContactDetails 
where ContactId=AC.ContactId and EntityType='Account' 
group by ContactId having count(ContactId)>1 )
) 
GROUP BY A.Id,A.Name,E.TenantId

Union All


Select E.TenantId,A.ID, A.Name
from ClientCursor.ManualAssociation MA
Inner join ClientCursor.Account A On A.id=MA.ToAccountId
Left JOIN ClientCursor.Opportunity o ON O.AccountId=A.Id
left Join Common.ServiceGroup SG on SG.Id=O.ServiceGroupId
inner join Common.Company e on e.Id=A.CompanyId
where  (FromAccountId=@Id OR ToAccountId=@Id)
 and a.AccountStatus not in ('Lost','Inactive') and a.Status=1
and (o.Status=1 or o.status is null )and (IsTemp is null or IsTemp=0)
GROUP BY A.Id,A.Name,E.TenantId

) SSK

Set @Idcount=@Idcount+1

End

 update A SET A.SystemAssociationCount=P.AssociationCount from
  @Temp_AssociationCountPBI P
  INNER JOIN ClientCursor.Account A ON A.ID=P.AccountId WHERE  A.Status=1
--where AccountId='5D757486-BFE1-4216-8713-4793E123AD71'
  END
GO
