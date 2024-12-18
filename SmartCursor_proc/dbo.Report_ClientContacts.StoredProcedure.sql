USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[Report_ClientContacts]    Script Date: 16-12-2024 9.20.11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


 CREATE procedure [dbo].[Report_ClientContacts]
  AS
 BEGIN


  
  select  --A.ID,A.Name,Contact,ContactEmail,ContactPhone,ContactMobil , PrimaryContact,PrimaryContactEmail, PrimaryContactPhone, PrimaryContactMobil 

Distinct  A.Id as ClientId,A.SystemRefNo as 'Client Ref No',A.NAME AS 'Client Name',ClientStatus as 'State',Contact AS 'Contact Name' ,PrimaryContact AS 'Primary Contact'  ,
 hh.Communication as Communication,a.Industry,a.Source,a.SourceName,
  a.IncorporationDate,a.FinancialYearEnd,a.CountryOfIncorporation,a.PrincipalActivities,a.UserCreated,a.CreatedDate,a.ModifiedBy,a.ModifiedDate,
  case when PrimaryContactMobil is null then PrimaryContactPhone else PrimaryContactMobil end   as PrimaryContactMobil,PrimaryContactEmail,case when ContactMobil is null then ContactPhone else ContactMobil end   as ContactMobile,ContactEmail as ContactEmail,
  V.TenantId
	 from WorkFlow.Client A 
   inner join Common.Company V on V.id=a.CompanyId
  inner  join 
  (
  select Distinct  A.ID,ss.FirstName as PrimaryContact,S.Communication
	 from WorkFlow.Client A 
	 inner join Common.ContactDetails S ON S.EntityId=A.Id
     inner join Common.Contact SS on SS.id=S.ContactId
     inner join Common.Company V on V.id=a.CompanyId
	 where --a.companyid=1 and
	 s.IsPrimaryContact=1
  )hh on hh.id=a.id
	 INNER JOIN 
 (
 select Name,id as ClientId,LEFT(Students,Len(Students)-1) as Contact from 
 (
   select a.Name,a.id,
         (
		 SELECT FirstName + ',' AS [text()]
		 from 
 (
 select ID,FirstName,Communication,IsPrimaryContact from   
 (
 select 
Id,Communication,FirstName,IsPrimaryContact
    from  (
	  select  a.Id,s.Communication,ss.FirstName,s.IsPrimaryContact
     from   workflow.Client A  
    left  join Common.ContactDetails as  s  on a.Id=s.EntityId  
    inner join Common.Contact as ss on ss.Id=s.ContactId  
	inner join Common.Company as c on c.id=A.CompanyId
	where --a.CompanyId=1 and
	s.IsPrimaryContact<>1
	) as A
		 --outer apply string_split(Communication,'}') 
		 ) as B
		  where FirstName is not null 
		  )hh
		  where hh.Id=a.Id
	        order by hh.Id 
			 FOR XML PATH ('') 
			 )[Students]
            from   workflow.Client A  
            --where a.CompanyId=1 
			)A
			)CN ON CN.ClientId=A.Id
	 INNER JOIN 
 (
 select Name,id as ClientId,LEFT(Students,Len(Students)-1) as ContactEmail from 
 (
   select a.Name,a.id,
         (
		 SELECT Email + ',' AS [text()]
		 from 
 (
 select ID,FirstName,Address AS Email,Communication,IsPrimaryContact from   
 (
 select Case when Substring(value,10,3) ='Ema' then 'Email'
 when Substring(value,10,3) ='Pho' then 'Phone'
 when Substring(value,10,3) ='Mob' then 'Mobil'end 
 as name, REPLACE(REPLACE(substring(value,26,49),'"',' '),'-',' ') as Address,
Id,Communication,FirstName,IsPrimaryContact
    from  (
	  select  a.Id,s.Communication,ss.FirstName,s.IsPrimaryContact
     from   workflow.Client A  
    left  join Common.ContactDetails as  s  on a.Id=s.EntityId  
    inner join Common.Contact as ss on ss.Id=s.ContactId  
	inner join Common.Company as c on c.id=A.CompanyId
	where --a.CompanyId=1 and
	s.IsPrimaryContact<>1
	) as A
		 outer apply string_split(Communication,'}') 
		 ) as B
		  where name is not null and Address<>'' and name='Email'
		  )hh
		  where hh.Id=a.Id
	        order by hh.Id 
			 FOR XML PATH ('') 
			 )[Students]
            from   workflow.Client A  
            --where a.CompanyId=1 
			)A
			)AA ON AA.ClientId=A.Id
			inner join 
(
	select Name,id as ClientId,LEFT(Students,Len(Students)-1) as ContactPhone from 
 (
   select a.Name,a.id,
         (
		 SELECT Phone + ',' AS [text()]
		 from 
 (
 select ID,FirstName,Address AS Phone,Communication,IsPrimaryContact from   
 (
 select Case when Substring(value,10,3) ='Ema' then 'Email'
 when Substring(value,10,3) ='Pho' then 'Phone'
 when Substring(value,10,3) ='Mob' then 'Mobil'end 
 as name, REPLACE(REPLACE(substring(value,26,49),'"',' '),'-',' ') as Address,
Id,Communication,FirstName,IsPrimaryContact
    from  (
	  select  a.Id,s.Communication,ss.FirstName,s.IsPrimaryContact
     from   workflow.Client A  
    left  join Common.ContactDetails as  s  on a.Id=s.EntityId  
    inner join Common.Contact as ss on ss.Id=s.ContactId  
	inner join Common.Company as c on c.id=A.CompanyId
	where --a.CompanyId=1 and 
	s.IsPrimaryContact<>1
	) as A
		 outer apply string_split(Communication,'}') 
		 ) as B
		  where name is not null and Address<>'' and name='Phone'
		  )hh
		  where hh.Id=a.Id
	        order by hh.Id 
			 FOR XML PATH ('') 
			 )[Students]
            from   workflow.Client A  
            --where a.CompanyId=1 
			)B
			)BB ON BB.ClientId=A.Id
			INNER JOIN 
			(
			select Name,id as ClientId,LEFT(Students,Len(Students)-1) as ContactMobil from 
 (
   select a.Name,a.id,
         (
		 SELECT Mobil + ',' AS [text()]
		 from 
 (
 select ID,FirstName,Address AS Mobil,Communication,IsPrimaryContact from   
 (
 select Case when Substring(value,10,3) ='Ema' then 'Email'
 when Substring(value,10,3) ='Pho' then 'Phone'
 when Substring(value,10,3) ='Mob' then 'Mobil'end 
 as name, REPLACE(REPLACE(substring(value,26,49),'"',' '),'-',' ') as Address,
Id,Communication,FirstName,IsPrimaryContact
    from  (
	  select  a.Id,s.Communication,ss.FirstName,s.IsPrimaryContact
     from   workflow.Client A  
    left  join Common.ContactDetails as  s  on a.Id=s.EntityId  
    inner join Common.Contact as ss on ss.Id=s.ContactId  
	inner join Common.Company as c on c.id=A.CompanyId
	where --a.CompanyId=1 and 
	s.IsPrimaryContact<>1
	) as A
		 outer apply string_split(Communication,'}') 
		 ) as B
		  where name is not null and Address<>'' and name='Mobil'
		  )hh
		  where hh.Id=a.Id
	        order by hh.Id 
			 FOR XML PATH ('') 
			 )[Students]
            from   workflow.Client A  
            --where a.CompanyId=1 
			)C
			)CC ON CC.ClientId=A.Id

				 INNER JOIN 
 (
 select Name,id as ClientId,LEFT(Students,Len(Students)-1) as PrimaryContactEmail from 
 (
   select a.Name,a.id,
         (
		 SELECT Email + ',' AS [text()]
		 from 
 (
 select ID,FirstName,Address AS Email,Communication,IsPrimaryContact from   
 (
 select Case when Substring(value,10,3) ='Ema' then 'Email'
 when Substring(value,10,3) ='Pho' then 'Phone'
 when Substring(value,10,3) ='Mob' then 'Mobil'end 
 as name, REPLACE(REPLACE(substring(value,26,49),'"',' '),'-',' ') as Address,
Id,Communication,FirstName,IsPrimaryContact
    from  (
	  select  a.Id,s.Communication,ss.FirstName,s.IsPrimaryContact
     from   workflow.Client A  
    left  join Common.ContactDetails as  s  on a.Id=s.EntityId  
    inner join Common.Contact as ss on ss.Id=s.ContactId  
	inner join Common.Company as c on c.id=A.CompanyId
	where --a.CompanyId=1 and
	s.IsPrimaryContact=1
	) as A
		 outer apply string_split(Communication,'}') 
		 ) as B
		  where name is not null and Address<>'' and name='Email'
		  )hh
		  where hh.Id=a.Id
	        order by hh.Id 
			 FOR XML PATH ('') 
			 )[Students]
            from   workflow.Client A  
            --where a.CompanyId=1 
			)A
			)AAa ON AAa.ClientId=A.Id
			inner join 
(
	select Name,id as ClientId,LEFT(Students,Len(Students)-1) as PrimaryContactPhone from 
 (
   select a.Name,a.id,
         (
		 SELECT Phone + ',' AS [text()]
		 from 
 (
 select ID,FirstName,Address AS Phone,Communication,IsPrimaryContact from   
 (
 select Case when Substring(value,10,3) ='Ema' then 'Email'
 when Substring(value,10,3) ='Pho' then 'Phone'
 when Substring(value,10,3) ='Mob' then 'Mobil'end 
 as name, REPLACE(REPLACE(substring(value,26,49),'"',' '),'-',' ') as Address,
Id,Communication,FirstName,IsPrimaryContact
    from  (
	  select  a.Id,s.Communication,ss.FirstName,s.IsPrimaryContact
     from   workflow.Client A  
    left  join Common.ContactDetails as  s  on a.Id=s.EntityId  
    inner join Common.Contact as ss on ss.Id=s.ContactId  
	inner join Common.Company as c on c.id=A.CompanyId
	where --a.CompanyId=1 and 
	s.IsPrimaryContact=1
	) as A
		 outer apply string_split(Communication,'}') 
		 ) as B
		  where name is not null and Address<>'' and name='Phone'
		  )hh
		  where hh.Id=a.Id
	        order by hh.Id 
			 FOR XML PATH ('') 
			 )[Students]
            from   workflow.Client A  
           -- where a.CompanyId=1 
			)B
			)BBb ON BBb.ClientId=A.Id
			INNER JOIN 
			(
			select Name,id as ClientId,LEFT(Students,Len(Students)-1) as PrimaryContactMobil from 
 (
   select a.Name,a.id,
         (
		 SELECT Mobil + ',' AS [text()]
		 from 
 (
 select ID,FirstName,Address AS Mobil,Communication,IsPrimaryContact from   
 (
 select Case when Substring(value,10,3) ='Ema' then 'Email'
 when Substring(value,10,3) ='Pho' then 'Phone'
 when Substring(value,10,3) ='Mob' then 'Mobil'end 
 as name, REPLACE(REPLACE(substring(value,26,49),'"',' '),'-',' ') as Address,
Id,Communication,FirstName,IsPrimaryContact
    from  (
	  select  a.Id,s.Communication,ss.FirstName,s.IsPrimaryContact
     from   workflow.Client A  
    left  join Common.ContactDetails as  s  on a.Id=s.EntityId  
    inner join Common.Contact as ss on ss.Id=s.ContactId  
	inner join Common.Company as c on c.id=A.CompanyId
	where --a.CompanyId=1 and 
	s.IsPrimaryContact=1
	) as A
		 outer apply string_split(Communication,'}') 
		 ) as B
		  where name is not null and Address<>'' and name='Mobil'
		  )hh
		  where hh.Id=a.Id
	        order by hh.Id 
			 FOR XML PATH ('') 
			 )[Students]
            from   workflow.Client A  
            --where a.CompanyId=1 
			)C
			)CCc ON CCc.ClientId=A.Id
			--WHERE A.CompanyId=1 --AND S.IsPrimaryContact=1

    order by A.NAME
    
    END



 --select * from Common.Contact where FirstName='JAMES PHILLIP FIORILLA ORTEGA'

 -- select * from Common.ContactDetails where ContactId='FC476A67-FBAF-4DBB-BC66-CA8C184A4CBA'




 --  select * from WorkFlow.Client A  order by A.NAME





GO
