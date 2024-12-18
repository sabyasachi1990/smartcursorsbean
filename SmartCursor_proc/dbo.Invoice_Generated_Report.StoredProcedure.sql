USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[Invoice_Generated_Report]    Script Date: 16-12-2024 9.20.10 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

 CREATE procedure [dbo].[Invoice_Generated_Report]   --EXEC   Invoice_Generated_Report 
  AS
  BEGIN 
 select Distinct  [Client Name] ,[Contact Name],[Primary Contact],ContactEmail AS 'Contact Email' ,ContactMobile AS 'ContactMobile',inv.Number AS 'InvNumber',INV.InvDate AS 'Inv Date',InvFees  
 from 
(
  SELECT Distinct  A.Id as ClientId,A.SystemRefNo as 'Client Ref No',A.NAME AS 'Client Name',ClientStatus as 'State',H.Contact AS 'Contact Name' ,CASE WHEN C.IsPrimaryContact=1 THEN cc.FirstName END AS 'Primary Contact'  ,cASE WHEN C.IsPrimaryContact=1 THEN cc.Communication END as Communication,a.Industry,a.Source,a.SourceName,
  a.IncorporationDate,a.FinancialYearEnd,a.CountryOfIncorporation,a.PrincipalActivities,a.UserCreated,a.CreatedDate,a.ModifiedBy,a.ModifiedDate,
  kk.ClientMobile,kk.ClientEmail,kk.ContactMobile,kk.ContactEmail,
  b.TenantId,b.Name as Companyname
     FROM WorkFlow.Client A
     inner join Common.ContactDetails C ON C.EntityId=A.Id
     inner join Common.Contact cc on cc.id=c.ContactId
     inner join Common.Company b on b.id=a.CompanyId

     inner join 
     (
     SELECT Main.ID,LEFT(Main.Students,Len(Main.Students)-1) As Contact
     FROM
     (
         SELECT DISTINCT A.Id, 
            (
                SELECT CC.FirstName + ',' AS [text()]
                FROM WorkFlow.Client A1
                inner join Common.ContactDetails C ON C.EntityId=A1.Id
                inner join Common.Contact cc on cc.id=c.ContactId
                WHERE A1.Id = A.ID ORDER BY A1.Id 
                FOR XML PATH ('')
            ) [Students]
        FROM    WorkFlow.Client A
        inner join Common.ContactDetails C ON C.EntityId=A.Id
        inner join Common.Contact cc on cc.id=c.ContactId
        -- WHERE A.CompanyId=1 
    ) [Main]
	)h on h.id=a.id

	 inner join 
	(
	select ID,Name, case when ClientMobile is null then ClientPhone else ClientMobile end  ClientMobile ,ClientEmail,
    case when ContactMobile is null then ContactDetailsMobile else ContactMobile end  ContactMobile ,
    case when ContactEmail is null then ContactDetailsEmail else ContactEmail end  ContactEmail 
    from 
    (
   select  A.ID,A.Name,ClientMobile,ClientPhone,ClientEmail,
   case when ContactMobile is null then ContactPhone else ContactMobile end ContactMobile,
   case when ContactDetailsMobile is null then ContactDetailsPhone else ContactDetailsMobile end ContactDetailsMobile,
   ContactPhone,ContactEmail,ContactDetailsPhone,ContactDetailsEmail from WorkFlow.Client A 

--======================================== Client Communication ============================================================
    LEFT JOIN
   (
   select Distinct Id,Mobile as ClientMobile  
   from 
   (
   select Id,Communication,Mobile ,RANK() OVER (PARTITION BY Id ORDER BY Mobile DeSC) AS Rank 
   from 
   (
   select Distinct gg.Id ,gg.Communication,case when [key]='Mobile' then [value] end as 'Mobile'
   from 
   (
   Select Id,Communication,JSON_VALUE(S.value,'$.key') as 'key',JSON_VALUE(S.value,'$.value') as 'value'
   from WorkFlow.Client
   CROSS APPLY OPENJSON(WorkFlow.Client.Communication) S
   where  Communication<>''
   )gg
    where   case when [key]='Mobile' then [value] end is not null
   )ff
   )mm
   where rank=1
   )HH ON HH.Id=A.Id
   LEFT JOIN
   (
   select Distinct Id,Phone as ClientPhone  from 
   (
   select Id,Communication,Phone ,RANK() OVER (PARTITION BY Id ORDER BY Phone DeSC) AS Rank from 
   (
   select Distinct gg.Id ,gg.Communication,case when [key]='Phone' then [value] end as 'Phone'
   from 
  (
  Select Id,Communication,JSON_VALUE(S.value,'$.key') as 'key',JSON_VALUE(S.value,'$.value') as 'value'
  from WorkFlow.Client
  CROSS APPLY OPENJSON(WorkFlow.Client.Communication) S
  where  Communication<>''
  )gg
  where   case when [key]='Phone' then [value] end is not null
  )ff
  )mm
  where rank=1
  )LL ON LL.Id=A.Id

  LEFT JOIN
  (
  select Distinct Id,Email as ClientEmail  from 
  (

 select Id,Communication,Email ,RANK() OVER (PARTITION BY Id ORDER BY Email DeSC) AS Rank from 
 (
  select Distinct gg.Id ,gg.Communication,case when [key]='Email' then [value] end as 'Email'
  from 
  (
  Select Id,Communication,JSON_VALUE(S.value,'$.key') as 'key',JSON_VALUE(S.value,'$.value') as 'value'
  from WorkFlow.Client
  CROSS APPLY OPENJSON(WorkFlow.Client.Communication) S
  where  Communication<>''
  )gg
  where   case when [key]='Email' then [value] end is not null
  )ff
  )mm
  where rank=1
  )SS ON SS.Id=A.Id
       --======================================== Contact Communication ============================================================
   LEFT JOIN 
   (
   select Distinct Clientid,ContactMobile from 
   (
   select Clientid,FirstName,Communication,Mobile as ContactMobile ,RANK() OVER (PARTITION BY ID ORDER BY Mobile DeSC) AS Rank FROM 
   (
   select Distinct gg.Id,c.Id as Clientid,FirstName,gg.Communication,case when [key]='Mobile' then [value] end as 'Mobile'
   from 
   (
   Select ID,FirstName,Communication,JSON_VALUE(S.value,'$.key') as 'key',JSON_VALUE(S.value,'$.value') as 'value'
  from Common.Contact
  CROSS APPLY OPENJSON(Common.Contact.Communication) S
  where  (Communication<>'' or Communication<>']') 
   )gg
   inner join Common.ContactDetails c on c.ContactId=gg.Id
   inner join WorkFlow.Client a on a.id=c.EntityId
   where case when [key]='Mobile' then [value] end is not null and IsPrimaryContact=1
  )HH
  )jj
  where jj.rank=1
  )AA ON AA.Clientid=A.Id
 LEFT JOIN 
  (
  select Distinct Clientid,ContactPhone from 
  (
  select Clientid,FirstName,Communication,Phone as ContactPhone ,RANK() OVER (PARTITION BY ID ORDER BY Phone DeSC) AS Rank FROM 
  (
   select Distinct gg.Id,c.Id as Clientid,FirstName,gg.Communication,case when [key]='Phone' then [value] end as 'Phone'
   from 
  (
  Select ID,FirstName,Communication,JSON_VALUE(S.value,'$.key') as 'key',JSON_VALUE(S.value,'$.value') as 'value'
  from Common.Contact
  CROSS APPLY OPENJSON(Common.Contact.Communication) S
  where  (Communication<>'' or Communication<>']') 
  )gg
  inner join Common.ContactDetails c on c.ContactId=gg.Id
  inner join WorkFlow.Client a on a.id=c.EntityId
  where case when [key]='Phone' then [value] end is not null and IsPrimaryContact=1
 )HH
 )jj
 where jj.rank=1
 )Ab ON Ab.Clientid=A.Id

  LEFT JOIN 
  (
  select Distinct Clientid,ContactEmail from 
  (
   select Clientid,FirstName,Communication,Email as ContactEmail ,RANK() OVER (PARTITION BY ID ORDER BY Email DeSC) AS Rank FROM 
  (
   select Distinct gg.Id,c.Id as Clientid,FirstName,gg.Communication,case when [key]='Email' then [value] end as 'Email'
   from 
   (
  Select ID,FirstName,Communication,JSON_VALUE(S.value,'$.key') as 'key',JSON_VALUE(S.value,'$.value') as 'value'
  from Common.Contact
  CROSS APPLY OPENJSON(Common.Contact.Communication) S
  where  (Communication<>'' or Communication<>']') 
  )gg
  inner join Common.ContactDetails c on c.ContactId=gg.Id
  inner join WorkFlow.Client a on a.id=c.EntityId
  where case when [key]='Email' then [value] end is not null and IsPrimaryContact=1
  )HH
  )jj
  where jj.rank=1
  )Ac ON Ac.Clientid=A.Id

       --======================================== ContactDetails Communication ============================================================
 left join 
   (
   select Distinct EntityId, ContactDetailsMobile from 
   (
   select Distinct EntityId,Mobile as ContactDetailsMobile ,RANK() OVER (PARTITION BY EntityId ORDER BY Mobile DeSC) AS Rank  from 
   (
   
   select EntityId,Communication,Mobile ,RANK() OVER (PARTITION BY ContactId ORDER BY Mobile DeSC) AS Rank from 
   (
   select Distinct gg.EntityId,ContactId,gg.Communication,case when [key]='Mobile' then [value] end as 'Mobile'
   from 
  (
  Select ContactId,EntityId,Communication,JSON_VALUE(S.value,'$.key') as 'key',JSON_VALUE(S.value,'$.value') as 'value'
  from Common.ContactDetails
  CROSS APPLY OPENJSON(Common.ContactDetails.Communication) S
  where  IsPrimaryContact=1 and (Communication<>'')
  ) gg
  inner join Common.Contact c on c.id=gg.ContactId
  inner join WorkFlow.Client a on a.id=gg.EntityId
  where case when [key]='Mobile' then [value] end is not null 

  )ff
  )mm
  where rank=1
  )hh
  where rank=1
  )ad on ad.EntityId=a.id


   left join 
   (
   select Distinct EntityId, ContactDetailsPhone from 
   (
   select Distinct EntityId,Phone as ContactDetailsPhone ,RANK() OVER (PARTITION BY EntityId ORDER BY Phone DeSC) AS Rank  from 
   (
   
   select EntityId,Communication,Phone ,RANK() OVER (PARTITION BY ContactId ORDER BY Phone DeSC) AS Rank from 
   (
    select Distinct gg.EntityId,ContactId,gg.Communication,case when [key]='Phone' then [value] end as 'Phone'
    from 
   (
  Select ContactId,EntityId,Communication,JSON_VALUE(S.value,'$.key') as 'key',JSON_VALUE(S.value,'$.value') as 'value'
  from Common.ContactDetails
  CROSS APPLY OPENJSON(Common.ContactDetails.Communication) S
  where  IsPrimaryContact=1 and (Communication<>'')
  )gg
   inner join Common.Contact c on c.id=gg.ContactId
   inner join WorkFlow.Client a on a.id=gg.EntityId
  where case when [key]='Phone' then [value] end is not null 

  )ff
  )mm
  where rank=1
  )hh
  where rank=1
  )ae on ae.EntityId=a.id
   left join 
    (
    select Distinct EntityId, ContactDetailsEmail from 
    (
    select Distinct EntityId,Email as ContactDetailsEmail ,RANK() OVER (PARTITION BY EntityId ORDER BY Email DeSC) AS Rank  from 
    (
    
    select EntityId,Communication,Email ,RANK() OVER (PARTITION BY ContactId ORDER BY Email DeSC) AS Rank from 
    (
     select Distinct gg.EntityId,ContactId,gg.Communication,case when [key]='Email' then [value] end as 'Email'
     from 
    (
    Select ContactId,EntityId,Communication,JSON_VALUE(S.value,'$.key') as 'key',JSON_VALUE(S.value,'$.value') as 'value'
    from Common.ContactDetails
    CROSS APPLY OPENJSON(Common.ContactDetails.Communication) S
    where  IsPrimaryContact=1 and (Communication<>'')
   )gg
   inner join Common.Contact c on c.id=gg.ContactId
   inner join WorkFlow.Client a on a.id=gg.EntityId
   where case when [key]='Email' then [value] end is not null 

    )ff
    )mm
    where rank=1
    )hh
    where rank=1
    )af on af.EntityId=a.id

    )gg
    )kk on kk.Id=a.Id
 


    where   CASE WHEN C.IsPrimaryContact=1 THEN cc.FirstName END is not null
    --and a.CompanyId=1 
	)hh
	 inner join 
	 (
		   select distinct  a.id as newclientid ,inv.Number  as Number,convert(date,inv.InvDate) InvDate,sum(inv.TotalFee) as InvFees
	     FROM WorkFlow.Client A
		 inner join WorkFlow.Invoice inv on inv.ClientId=a.Id
		 where YEAR(inv.InvDate )=year(GETUTCDATE()) and month(inv.InvDate ) =1 and inv.Number is not null
		  group by a.id  ,inv.Number,convert(date,inv.InvDate),inv.TempNumber
		 )inv on HH.ClientId=INV.newclientid
    order by [Client Name]
    
	END 

	 --select * from  WorkFlow.Invoice  where ClientId='2A786F38-FCF7-4B66-97F4-07E681C823E7'


	 --select * from WorkFlow.Client where name='7 SIGMA INVESTMENTS PTE. LTD.'


 --select * from Common.Contact where FirstName='JAMES PHILLIP FIORILLA ORTEGA'

 -- select * from Common.ContactDetails where ContactId='FC476A67-FBAF-4DBB-BC66-CA8C184A4CBA'




 --  select * from WorkFlow.Client A  order by A.NAME





GO
