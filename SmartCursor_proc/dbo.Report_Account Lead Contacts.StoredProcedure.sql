USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[Report_Account/Lead Contacts]    Script Date: 16-12-2024 9.20.11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE Procedure [dbo].[Report_Account/Lead Contacts]
 as
 begin 
  
  select  Distinct A.NAME AS 'Account/Lead name',AccountStatus as 'State',CONVERT(DATE,a.FinancialYearEnd) AS FYE,PrimaryContact AS 'Primary Contact'  ,
    case when PrimaryContactMobil is null then PrimaryContactPhone else PrimaryContactMobil end   as Mobil,PrimaryContactEmail as Email,
CONCAT_WS(', ',CASE WHEN IsAGMDocsReminders=1 THEN 'AGM' END, CASE WHEN IsCorporateTaxReminders=1 THEN 'ECI'END,CASE WHEN IsAuditReminders=1 THEN 'Audit' END,CASE WHEN [IsFinalTax]=1 THEN 'Final Tax' END)   AS Reminders,
 
case when IsReminderReceipient=1 then PrimaryContact end as 'Reminder recipient name',case when IsReminderReceipient=1 then PrimaryContactEmail END AS 'Reminder recipient email'

	 from ClientCursor.Account A 
   inner join Common.Company V on V.id=a.CompanyId
  inner  join 
  (
  select Distinct  A.ID,ss.FirstName as PrimaryContact,S.Communication,S.IsReminderReceipient
	 from ClientCursor.Account  A 
	 inner join Common.ContactDetails S ON S.EntityId=A.Id
     inner join Common.Contact SS on SS.id=S.ContactId
     inner join Common.Company V on V.id=a.CompanyId
	 where A.Status=1 AND --a.companyid=1 and
	 s.IsPrimaryContact=1
  )hh on hh.id=a.id
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
     from   ClientCursor.Account  A  
    left  join Common.ContactDetails as  s  on a.Id=s.EntityId  
    inner join Common.Contact as ss on ss.Id=s.ContactId  
	inner join Common.Company as c on c.id=A.CompanyId
	where A.Status=1 AND --a.CompanyId=1 and
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
            from   ClientCursor.Account  A  
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
     from   ClientCursor.Account  A  
    left  join Common.ContactDetails as  s  on a.Id=s.EntityId  
    inner join Common.Contact as ss on ss.Id=s.ContactId  
	inner join Common.Company as c on c.id=A.CompanyId
	where A.Status=1 AND --a.CompanyId=1 and 
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
            from   ClientCursor.Account  A  
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
     from   ClientCursor.Account  A  
    left  join Common.ContactDetails as  s  on a.Id=s.EntityId  
    inner join Common.Contact as ss on ss.Id=s.ContactId  
	inner join Common.Company as c on c.id=A.CompanyId
	where A.Status=1 AND --a.CompanyId=1 and 
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
            from   ClientCursor.Account  A  
            --where a.CompanyId=1 
			)C
			)CCc ON CCc.ClientId=A.Id
			WHERE A.Status=1 AND A.CompanyId=1 --AND A.Id='0C168217-6C12-4FC0-8310-E29482205BD2'
			AND AccountStatus IN ('Active','Re-active','New','Re-new')
           order by A.NAME,A.AccountStatus

end 



GO
