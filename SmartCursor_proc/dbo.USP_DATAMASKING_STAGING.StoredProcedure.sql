USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[USP_DATAMASKING_STAGING]    Script Date: 16-12-2024 9.20.11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
Create Procedure [dbo].[USP_DATAMASKING_STAGING]

As
Begin
Alter Table Notification.[NotificationSettings] Alter column OtherEmailRecipient nvarchar(524)
-- Exec [dbo].[USP_DATAMASKING_STAGING]

--Select IdNo,Communication from Common.Employee Where Communication is not null

Update Common.Contact Set IdNo=Replace(IdNo,IdNo,'XXXXXXXXXX')


Update Common.Contact Set Communication= REPLACE(Communication,
substring(substring(Communication,charindex('www.',Communication,1),
charindex('"',substring(Communication,charindex('www.',Communication,1),
LEN(Communication)),1)),charindex('www.',substring(Communication,charindex('www.',Communication,1),
charindex('"',substring(Communication,charindex('www.',Communication,1),
LEN(Communication)),1)),1),LEN(substring(Communication,charindex('www.',Communication,1),
charindex('"',substring(Communication,charindex('www.',Communication,1),
LEN(Communication)),1)))),'www.smartcursors.org"') 
where Communication like '%Website%'


Update Common.Contact Set Communication= CASE WHEN Communication like '%@%' THEN 
replace(communication, substring(substring(Communication,charindex('@',Communication,1),
charindex('"',substring(Communication,charindex('@',Communication,1),
LEN(Communication)),1)),charindex('@',substring(Communication,charindex('@.',Communication,1),
charindex('"',substring(Communication,charindex('@',Communication,1),
LEN(Communication)),1)),1),LEN(substring(Communication,charindex('@',Communication,1),
charindex('"',substring(Communication,charindex('@',Communication,1),
LEN(Communication)),-1)))),'@smartcursors.org')
ELSE Communication END
where Communication like '%Email%'

--REPLACE(Communication,
--substring(substring(Communication,charindex('@',Communication,1),
--charindex('"',substring(Communication,charindex('@',Communication,1),
--LEN(Communication)),1)),charindex('@',substring(Communication,charindex('@.',Communication,1),
--charindex('"',substring(Communication,charindex('@',Communication,1),
--LEN(Communication)),1)),1),LEN(substring(Communication,charindex('@',Communication,1),
--charindex('"',substring(Communication,charindex('@',Communication,1),
--LEN(Communication)),1)))),'@smartcursors.org') 
--where Communication like '%Email%'



Update Common.Contact set Communication=replace(replace(replace(replace(replace(replace
(replace(replace( replace(replace(Communication,1,9),2,8),3,7),4,6),5,0),6,5),7,4),8,3),9,2),0,1) 


--select Email, PhoneNo, Idno, communication from Common.Employee

 Update Common.Employee set Email=REPLACE(Email,substring(Email,charindex('@',Email,1),LEN(Email)),'@smartcursors.org')

Update AUDIT.AUDITCOMPANYENGAGEMENTDETAILS set UserName=REPLACE(UserName,substring(UserName,charindex('@',UserName,1),LEN(UserName)),'@smartcursors.org')

 Update Common.Employee Set PhoneNo=Replace(PhoneNo,PhoneNo,'XXXXXXXXXX')

 Update Common.Employee Set IdNo=Replace(IdNo,IdNo,'XXXXXXXXXX')

 Update Common.Employee Set Communication= REPLACE(Communication,
substring(substring(Communication,charindex('www.',Communication,1),
charindex('"',substring(Communication,charindex('www.',Communication,1),
LEN(Communication)),1)),charindex('www.',substring(Communication,charindex('www.',Communication,1),
charindex('"',substring(Communication,charindex('www.',Communication,1),
LEN(Communication)),1)),1),LEN(substring(Communication,charindex('www.',Communication,1),
charindex('"',substring(Communication,charindex('www.',Communication,1),
LEN(Communication)),1)))),'www.smartcursors.org"') 
where Communication like '%Website%'


Update Common.Employee Set Communication= CASE WHEN Communication like '%@%' THEN 
replace(communication, substring(substring(Communication,charindex('@',Communication,1),
charindex('"',substring(Communication,charindex('@',Communication,1),
LEN(Communication)),1)),charindex('@',substring(Communication,charindex('@.',Communication,1),
charindex('"',substring(Communication,charindex('@',Communication,1),
LEN(Communication)),1)),1),LEN(substring(Communication,charindex('@',Communication,1),
charindex('"',substring(Communication,charindex('@',Communication,1),
LEN(Communication)),-1)))),'@smartcursors.org')
ELSE Communication END
where Communication like '%Email%'


Update Common.Employee set Communication=replace(replace(replace(replace(replace(replace
(replace(replace( replace(replace(Communication,1,9),2,8),3,7),4,6),5,0),6,5),7,4),8,3),9,2),0,1) 


--select FromEmailId,CCEmailIds,BCCEmailIds from Common.Template

Update Common.Template set FromEmailId=REPLACE(FromEmailId,substring(FromEmailId,charindex('@',FromEmailId,1),LEN(FromEmailId)),'@smartcursors.org')

Update Common.Template set CCEmailIds=REPLACE(CCEmailIds,substring(CCEmailIds,charindex('@',CCEmailIds,1),LEN(CCEmailIds)),'@smartcursors.org')

Update Common.Template set BCCEmailIds=REPLACE(BCCEmailIds,substring(BCCEmailIds,charindex('@',BCCEmailIds,1),LEN(BCCEmailIds)),'@smartcursors.org')


--select sentBy,frommail,tomail from common.Communication

Update Common.Communication set sentBy=REPLACE(sentBy,substring(sentBy,charindex('@',sentBy,1),LEN(sentBy)),'@smartcursors.org')

Update Common.Communication set frommail=REPLACE(frommail,substring(frommail,charindex('@',frommail,1),LEN(frommail)),'@smartcursors.org')

Update Common.Communication set tomail=REPLACE(tomail,substring(tomail,charindex('@',tomail,1),LEN(tomail)),'@smartcursors.org')


--select Email,Phone from common.Addressbook

Update Common.Addressbook set Email=REPLACE(Email,substring(Email,charindex('@',Email,1),LEN(Email)),'@smartcursors.org')

Update Common.Addressbook set Phone=Replace(Phone,Phone,'XXXXXXXXXX')


--select EmailAddress, HomeNumber, IDNumber from hr.JobApplication


Update hr.JobApplication set EmailAddress=REPLACE(EmailAddress,substring(EmailAddress,charindex('@',EmailAddress,1),LEN(EmailAddress)),'@smartcursors.org')

Update hr.JobApplication set HomeNumber=Replace(HomeNumber,HomeNumber,'XXXXXXXXXX')

Update hr.JobApplication set IDNumber=Replace(IDNumber,IDNumber,'XXXXXXXXXX')


--select PhoneNo from Auth.UserAccount


 Update Auth.UserAccount Set PhoneNo=Replace(PhoneNo,PhoneNo,'XXXXXXXXXX')

 --Update Auth.UserAccount Set Email=REPLACE(Email,substring(Email,charindex('@',Email,1),LEN(Email)),'@smartcursors.org')

 --Select Username,Email,REPLACE(Email,substring(Email,charindex('@',Email,1),LEN(Email)),'@smartcursors.org') from Auth.UserAccount 


--select PhoneNo,Communication from Common.CompanyUser


Update Common.CompanyUser Set PhoneNo=Replace(PhoneNo,PhoneNo,'XXXXXXXXXX')


 Update Common.CompanyUser Set Communication= REPLACE(Communication,
substring(substring(Communication,charindex('www.',Communication,1),
charindex('"',substring(Communication,charindex('www.',Communication,1),
LEN(Communication)),1)),charindex('www.',substring(Communication,charindex('www.',Communication,1),
charindex('"',substring(Communication,charindex('www.',Communication,1),
LEN(Communication)),1)),1),LEN(substring(Communication,charindex('www.',Communication,1),
charindex('"',substring(Communication,charindex('www.',Communication,1),
LEN(Communication)),1)))),'www.smartcursors.org"') 
where Communication like '%Website%'


Update Common.CompanyUser Set Communication= CASE WHEN Communication like '%@%' THEN 
replace(communication, substring(substring(Communication,charindex('@',Communication,1),
charindex('"',substring(Communication,charindex('@',Communication,1),
LEN(Communication)),1)),charindex('@',substring(Communication,charindex('@.',Communication,1),
charindex('"',substring(Communication,charindex('@',Communication,1),
LEN(Communication)),1)),1),LEN(substring(Communication,charindex('@',Communication,1),
charindex('"',substring(Communication,charindex('@',Communication,1),
LEN(Communication)),-1)))),'@smartcursors.org')
ELSE Communication END
where Communication like '%Email%'


Update Common.CompanyUser set Communication=replace(replace(replace(replace(replace(replace
(replace(replace( replace(replace(Communication,1,9),2,8),3,7),4,6),5,0),6,5),7,4),8,3),9,2),0,1) 



--select Communication from clientcursor.account

 Update clientcursor.account Set Communication= REPLACE(Communication,
substring(substring(Communication,charindex('www.',Communication,1),
charindex('"',substring(Communication,charindex('www.',Communication,1),
LEN(Communication)),1)),charindex('www.',substring(Communication,charindex('www.',Communication,1),
charindex('"',substring(Communication,charindex('www.',Communication,1),
LEN(Communication)),1)),1),LEN(substring(Communication,charindex('www.',Communication,1),
charindex('"',substring(Communication,charindex('www.',Communication,1),
LEN(Communication)),1)))),'www.smartcursors.org"') 
where Communication like '%Website%'


Update clientcursor.account Set Communication= CASE WHEN Communication like '%@%' THEN 
replace(communication, substring(substring(Communication,charindex('@',Communication,1),
charindex('"',substring(Communication,charindex('@',Communication,1),
LEN(Communication)),1)),charindex('@',substring(Communication,charindex('@.',Communication,1),
charindex('"',substring(Communication,charindex('@',Communication,1),
LEN(Communication)),1)),1),LEN(substring(Communication,charindex('@',Communication,1),
charindex('"',substring(Communication,charindex('@',Communication,1),
LEN(Communication)),-1)))),'@smartcursors.org')
ELSE Communication END
where Communication like '%Email%'


Update clientcursor.account set Communication=replace(replace(replace(replace(replace(replace
(replace(replace( replace(replace(Communication,1,9),2,8),3,7),4,6),5,0),6,5),7,4),8,3),9,2),0,1) 


--select Communication from ClientCursor.Vendor

 Update clientcursor.Vendor Set Communication= REPLACE(Communication,
substring(substring(Communication,charindex('www.',Communication,1),
charindex('"',substring(Communication,charindex('www.',Communication,1),
LEN(Communication)),1)),charindex('www.',substring(Communication,charindex('www.',Communication,1),
charindex('"',substring(Communication,charindex('www.',Communication,1),
LEN(Communication)),1)),1),LEN(substring(Communication,charindex('www.',Communication,1),
charindex('"',substring(Communication,charindex('www.',Communication,1),
LEN(Communication)),1)))),'www.smartcursors.org"') 
where Communication like '%Website%'


Update clientcursor.Vendor Set Communication= CASE WHEN Communication like '%@%' THEN 
replace(communication, substring(substring(Communication,charindex('@',Communication,1),
charindex('"',substring(Communication,charindex('@',Communication,1),
LEN(Communication)),1)),charindex('@',substring(Communication,charindex('@.',Communication,1),
charindex('"',substring(Communication,charindex('@',Communication,1),
LEN(Communication)),1)),1),LEN(substring(Communication,charindex('@',Communication,1),
charindex('"',substring(Communication,charindex('@',Communication,1),
LEN(Communication)),-1)))),'@smartcursors.org')
ELSE Communication END
where Communication like '%Email%'


Update clientcursor.Vendor set Communication=replace(replace(replace(replace(replace(replace
(replace(replace( replace(replace(Communication,1,9),2,8),3,7),4,6),5,0),6,5),7,4),8,3),9,2),0,1) 


--Select Communication from WorkFlow.Client

 Update WorkFlow.Client Set Communication= REPLACE(Communication,
substring(substring(Communication,charindex('www.',Communication,1),
charindex('"',substring(Communication,charindex('www.',Communication,1),
LEN(Communication)),1)),charindex('www.',substring(Communication,charindex('www.',Communication,1),
charindex('"',substring(Communication,charindex('www.',Communication,1),
LEN(Communication)),1)),1),LEN(substring(Communication,charindex('www.',Communication,1),
charindex('"',substring(Communication,charindex('www.',Communication,1),
LEN(Communication)),1)))),'www.smartcursors.org"') 
where Communication like '%Website%'


Update WorkFlow.Client Set Communication= CASE WHEN Communication like '%@%' THEN 
replace(communication, substring(substring(Communication,charindex('@',Communication,1),
charindex('"',substring(Communication,charindex('@',Communication,1),
LEN(Communication)),1)),charindex('@',substring(Communication,charindex('@.',Communication,1),
charindex('"',substring(Communication,charindex('@',Communication,1),
LEN(Communication)),1)),1),LEN(substring(Communication,charindex('@',Communication,1),
charindex('"',substring(Communication,charindex('@',Communication,1),
LEN(Communication)),-1)))),'@smartcursors.org')
ELSE Communication END
where Communication like '%Email%'


Update WorkFlow.Client set Communication=replace(replace(replace(replace(replace(replace
(replace(replace( replace(replace(Communication,1,9),2,8),3,7),4,6),5,0),6,5),7,4),8,3),9,2),0,1) 


--select Communication from Audit.AuditCompanyContact

 Update Audit.AuditCompanyContact Set Communication= REPLACE(Communication,
substring(substring(Communication,charindex('www.',Communication,1),
charindex('"',substring(Communication,charindex('www.',Communication,1),
LEN(Communication)),1)),charindex('www.',substring(Communication,charindex('www.',Communication,1),
charindex('"',substring(Communication,charindex('www.',Communication,1),
LEN(Communication)),1)),1),LEN(substring(Communication,charindex('www.',Communication,1),
charindex('"',substring(Communication,charindex('www.',Communication,1),
LEN(Communication)),1)))),'www.smartcursors.org"') 
where Communication like '%Website%'


Update Audit.AuditCompanyContact Set Communication= CASE WHEN Communication like '%@%' THEN 
replace(communication, substring(substring(Communication,charindex('@',Communication,1),
charindex('"',substring(Communication,charindex('@',Communication,1),
LEN(Communication)),1)),charindex('@',substring(Communication,charindex('@.',Communication,1),
charindex('"',substring(Communication,charindex('@',Communication,1),
LEN(Communication)),1)),1),LEN(substring(Communication,charindex('@',Communication,1),
charindex('"',substring(Communication,charindex('@',Communication,1),
LEN(Communication)),-1)))),'@smartcursors.org')
ELSE Communication END
where Communication like '%Email%'


Update Audit.AuditCompanyContact set Communication=replace(replace(replace(replace(replace(replace
(replace(replace( replace(replace(Communication,1,9),2,8),3,7),4,6),5,0),6,5),7,4),8,3),9,2),0,1) 


--select Communication from Tax.TaxCompanyContact

 Update Tax.TaxCompanyContact Set Communication= REPLACE(Communication,
substring(substring(Communication,charindex('www.',Communication,1),
charindex('"',substring(Communication,charindex('www.',Communication,1),
LEN(Communication)),1)),charindex('www.',substring(Communication,charindex('www.',Communication,1),
charindex('"',substring(Communication,charindex('www.',Communication,1),
LEN(Communication)),1)),1),LEN(substring(Communication,charindex('www.',Communication,1),
charindex('"',substring(Communication,charindex('www.',Communication,1),
LEN(Communication)),1)))),'www.smartcursors.org"') 
where Communication like '%Website%'


Update Tax.TaxCompanyContact Set Communication= CASE WHEN Communication like '%@%' THEN 
replace(communication, substring(substring(Communication,charindex('@',Communication,1),
charindex('"',substring(Communication,charindex('@',Communication,1),
LEN(Communication)),1)),charindex('@',substring(Communication,charindex('@.',Communication,1),
charindex('"',substring(Communication,charindex('@',Communication,1),
LEN(Communication)),1)),1),LEN(substring(Communication,charindex('@',Communication,1),
charindex('"',substring(Communication,charindex('@',Communication,1),
LEN(Communication)),-1)))),'@smartcursors.org')
ELSE Communication END
where Communication like '%Email%'


Update Tax.TaxCompanyContact set Communication=replace(replace(replace(replace(replace(replace
(replace(replace( replace(replace(Communication,1,9),2,8),3,7),4,6),5,0),6,5),7,4),8,3),9,2),0,1) 


--Select Communication from Common.EntityDetail

 Update Common.EntityDetail Set Communication= REPLACE(Communication,
substring(substring(Communication,charindex('www.',Communication,1),
charindex('"',substring(Communication,charindex('www.',Communication,1),
LEN(Communication)),1)),charindex('www.',substring(Communication,charindex('www.',Communication,1),
charindex('"',substring(Communication,charindex('www.',Communication,1),
LEN(Communication)),1)),1),LEN(substring(Communication,charindex('www.',Communication,1),
charindex('"',substring(Communication,charindex('www.',Communication,1),
LEN(Communication)),1)))),'www.smartcursors.org"') 
where Communication like '%Website%'


Update Common.EntityDetail Set Communication= CASE WHEN Communication like '%@%' THEN 
replace(communication, substring(substring(Communication,charindex('@',Communication,1),
charindex('"',substring(Communication,charindex('@',Communication,1),
LEN(Communication)),1)),charindex('@',substring(Communication,charindex('@.',Communication,1),
charindex('"',substring(Communication,charindex('@',Communication,1),
LEN(Communication)),1)),1),LEN(substring(Communication,charindex('@',Communication,1),
charindex('"',substring(Communication,charindex('@',Communication,1),
LEN(Communication)),-1)))),'@smartcursors.org')
ELSE Communication END
where Communication like '%Email%'


Update Common.EntityDetail set Communication=replace(replace(replace(replace(replace(replace
(replace(replace( replace(replace(Communication,1,9),2,8),3,7),4,6),5,0),6,5),7,4),8,3),9,2),0,1) 

--Select Communication from Common.ContactDetails

 Update Common.ContactDetails Set Communication= REPLACE(Communication,
substring(substring(Communication,charindex('www.',Communication,1),
charindex('"',substring(Communication,charindex('www.',Communication,1),
LEN(Communication)),1)),charindex('www.',substring(Communication,charindex('www.',Communication,1),
charindex('"',substring(Communication,charindex('www.',Communication,1),
LEN(Communication)),1)),1),LEN(substring(Communication,charindex('www.',Communication,1),
charindex('"',substring(Communication,charindex('www.',Communication,1),
LEN(Communication)),1)))),'www.smartcursors.org"') 
where Communication like '%Website%'


Update Common.ContactDetails Set Communication= CASE WHEN Communication like '%@%' THEN 
replace(communication, substring(substring(Communication,charindex('@',Communication,1),
charindex('"',substring(Communication,charindex('@',Communication,1),
LEN(Communication)),1)),charindex('@',substring(Communication,charindex('@.',Communication,1),
charindex('"',substring(Communication,charindex('@',Communication,1),
LEN(Communication)),1)),1),LEN(substring(Communication,charindex('@',Communication,1),
charindex('"',substring(Communication,charindex('@',Communication,1),
LEN(Communication)),-1)))),'@smartcursors.org')
ELSE Communication END
where Communication like '%Email%'

Update Common.ContactDetails set Communication=replace(replace(replace(replace(replace(replace
(replace(replace( replace(replace(Communication,1,9),2,8),3,7),4,6),5,0),6,5),7,4),8,3),9,2),0,1) 

--select * from Common.Company

 Update Common.Company Set Communication= REPLACE(Communication,
substring(substring(Communication,charindex('www.',Communication,1),
charindex('"',substring(Communication,charindex('www.',Communication,1),
LEN(Communication)),1)),charindex('www.',substring(Communication,charindex('www.',Communication,1),
charindex('"',substring(Communication,charindex('www.',Communication,1),
LEN(Communication)),1)),1),LEN(substring(Communication,charindex('www.',Communication,1),
charindex('"',substring(Communication,charindex('www.',Communication,1),
LEN(Communication)),1)))),'www.smartcursors.org"') 
where Communication like '%Website%'


Update Common.Company Set Communication= CASE WHEN Communication like '%@%' THEN 
replace(communication, substring(substring(Communication,charindex('@',Communication,1),
charindex('"',substring(Communication,charindex('@',Communication,1),
LEN(Communication)),1)),charindex('@',substring(Communication,charindex('@.',Communication,1),
charindex('"',substring(Communication,charindex('@',Communication,1),
LEN(Communication)),1)),1),LEN(substring(Communication,charindex('@',Communication,1),
charindex('"',substring(Communication,charindex('@',Communication,1),
LEN(Communication)),-1)))),'@smartcursors.org')
ELSE Communication END
where Communication like '%Email%'


Update Common.Company set Communication=replace(replace(replace(replace(replace(replace
(replace(replace( replace(replace(Communication,1,9),2,8),3,7),4,6),5,0),6,5),7,4),8,3),9,2),0,1) 



-- Emails Updation

Update auth.useraccount Set Username=REPLACE(Username,substring(Username,charindex('@',Username,1),LEN(Username)),'@smartcursors.org')
Where Username not like ('%madhu@kgtan.com%') and UserName not like ('%@zirafftechnologies.com%')

-- Multiple UserNames Update

update aa set aa.Username=aa.UsernamenEW
from
(
Select rank,Username,ID,REPLACE(Username,substring(Username,charindex('@',Username,1),LEN(Username)),'')+
Cast (Rank as Varchar(2))+SUBSTRING(UserName,Charindex('@',Username,1),Len(UserName)) 'UsernamenEW'
from
(
SELECT DENSE_RANK() over(partition by Username order by Id DESC) as 'Rank',Username,ID
FROM  auth.useraccount as CI 
) As BH
Where Rank<>1

)as AA


-- Employee

Update E Set E.Username=Au.Username
from common.employee as e
join common.companyuser as cu on e.username=cu.username
join Auth.UserAccount au on cu.userid=au.Id
where e.companyid=cu.companyid


-- CompanyUser

update CU set CU.Username=AU.Username
from Common.CompanyUser As CU
Inner Join Auth.UserAccount As AU On AU.Id=CU.UserId

--(
--Select ua.Id,ua.username,u.Username as CUsername 
--from auth.UserAccount ua 
--inner join Common.CompanyUser u  on u.UserId=ua.Id
--where ua.id=u.UserId
--)as AA

-- ASPNETUSERS

update BB set BB.Netusername=Username
from 
(
Select  ua.UserId,ua.username,ans.UserName as Netusername 
from  auth.UserAccount ua 
inner join SCIdentitySTG.[dbo].[AspNetUsers] ans on ans.id=ua.UserId
where ans.id=ua.UserId
)as BB

update BB set BB.Netusername=Username
from 
(
Select  ua.UserId,ua.username,ans.Email as Netusername 
from  auth.UserAccount ua 
inner join SCIdentitySTG.[dbo].[AspNetUsers] ans on ans.id=ua.UserId
where ans.id=ua.UserId and ans.UserName<>'test3@smartcursors.org'
)as BB

update BB set BB.Netusername=Upper(Username)
from 
(
Select  ua.UserId,ua.username,ans.NormalizedEmail as Netusername 
from  auth.UserAccount ua 
inner join SCIdentitySTG.[dbo].[AspNetUsers] ans on ans.id=ua.UserId
where ans.id=ua.UserId
)as BB

update BB set BB.Netusername=Upper(Username)
from 
(
Select  ua.UserId,ua.username,ans.NormalizedUserName as Netusername 
from  auth.UserAccount ua 
inner join SCIdentitySTG.[dbo].[AspNetUsers] ans on ans.id=ua.UserId
where ans.id=ua.UserId
)as BB



-- Emails Updation

-- Select BccEmailIds,CcEmailIds,FromEmailId,ToEmailId from Audit.Template

Update Audit.Template Set BccEmailIds=REPLACE(BccEmailIds,substring(BccEmailIds,charindex('@',BccEmailIds,1),LEN(BccEmailIds)),'@smartcursors.org'),
						  CcEmailIds=REPLACE(CcEmailIds,substring(CcEmailIds,charindex('@',CcEmailIds,1),LEN(CcEmailIds)),'@smartcursors.org'),
						  FromEmailId=REPLACE(FromEmailId,substring(FromEmailId,charindex('@',FromEmailId,1),LEN(FromEmailId)),'@smartcursors.org'),
						  ToEmailId=REPLACE(ToEmailId,substring(ToEmailId,charindex('@',ToEmailId,1),LEN(ToEmailId)),'@smartcursors.org')

-- Select Emails from ClientCursor.AccountContact

Update ClientCursor.AccountContact Set Emails=REPLACE(Emails,substring(Emails,charindex('@',Emails,1),LEN(Emails)),'@smartcursors.org')

-- Select Email from Common.AddressBook

Update Common.AddressBook Set Email=REPLACE(Email,substring(Email,charindex('@',Email,1),LEN(Email)),'@smartcursors.org')

-- Select Email from Common.Employee

Update Common.Employee Set Email=REPLACE(Email,substring(Email,charindex('@',Email,1),LEN(Email)),'@smartcursors.org')

-- Select BccEmailIds,CcEmailIds,FromEmailId,ToEmailId from Common.GenericTemplate

Update Common.GenericTemplate Set BccEmailIds=REPLACE(BccEmailIds,substring(BccEmailIds,charindex('@',BccEmailIds,1),LEN(BccEmailIds)),'@smartcursors.org'),
						          CcEmailIds=REPLACE(CcEmailIds,substring(CcEmailIds,charindex('@',CcEmailIds,1),LEN(CcEmailIds)),'@smartcursors.org'),
						          FromEmailId=REPLACE(FromEmailId,substring(FromEmailId,charindex('@',FromEmailId,1),LEN(FromEmailId)),'@smartcursors.org'),
						          ToEmailId=REPLACE(ToEmailId,substring(ToEmailId,charindex('@',ToEmailId,1),LEN(ToEmailId)),'@smartcursors.org')

-- Select FromEmail,ToEmail from Common.TemplateSent

Update Common.TemplateSent Set FromEmail=REPLACE(FromEmail,substring(FromEmail,charindex('@',FromEmail,1),LEN(FromEmail)),'@smartcursors.org'),
						       ToEmail=REPLACE(ToEmail,substring(ToEmail,charindex('@',ToEmail,1),LEN(ToEmail)),'@smartcursors.org')


-- Select Email,EmailConfirmed from dbo.AspNetUsers

Update dbo.AspNetUsers Set Email=REPLACE(Email,substring(Email,charindex('@',Email,1),LEN(Email)),'@smartcursors.org') where UserName<>'test3@smartcursors.org'

-- Select Email from dbo.Users

Update dbo.Users Set Email=REPLACE(Email,substring(Email,charindex('@',Email,1),LEN(Email)),'@smartcursors.org')

-- Select EmailAddress from HR.ApplicantHistory

Update HR.ApplicantHistory Set EmailAddress=REPLACE(EmailAddress,substring(EmailAddress,charindex('@',EmailAddress,1),LEN(EmailAddress)),'@smartcursors.org')

-- Select EmailAddress from HR.JobApplication

Update HR.JobApplication Set EmailAddress=REPLACE(EmailAddress,substring(EmailAddress,charindex('@',EmailAddress,1),LEN(EmailAddress)),'@smartcursors.org')

-- Select CCEmails from Support.Ticket

Update Support.Ticket Set CCEmails=REPLACE(CCEmails,substring(CCEmails,charindex('@',CCEmails,1),LEN(CCEmails)),'@smartcursors.org')


-- Select BccEmailIds,CcEmailIds,FromEmailId,ToEmailId from Tax.Template


Update Tax.Template Set BccEmailIds=REPLACE(BccEmailIds,substring(BccEmailIds,charindex('@',BccEmailIds,1),LEN(BccEmailIds)),'@smartcursors.org'),
						  CcEmailIds=REPLACE(CcEmailIds,substring(CcEmailIds,charindex('@',CcEmailIds,1),LEN(CcEmailIds)),'@smartcursors.org'),
						  FromEmailId=REPLACE(FromEmailId,substring(FromEmailId,charindex('@',FromEmailId,1),LEN(FromEmailId)),'@smartcursors.org'),
						  ToEmailId=REPLACE(ToEmailId,substring(ToEmailId,charindex('@',ToEmailId,1),LEN(ToEmailId)),'@smartcursors.org')


 -- UserAccount

Update E Set E.Email=E.Username
from Auth.UserAccount E 

--select Communication from Auth.[UserAccount]

Update Auth.[UserAccount] Set Communication= REPLACE(Communication,
substring(substring(Communication,charindex('www.',Communication,1),
charindex('"',substring(Communication,charindex('www.',Communication,1),
LEN(Communication)),1)),charindex('www.',substring(Communication,charindex('www.',Communication,1),
charindex('"',substring(Communication,charindex('www.',Communication,1),
LEN(Communication)),1)),1),LEN(substring(Communication,charindex('www.',Communication,1),
charindex('"',substring(Communication,charindex('www.',Communication,1),
LEN(Communication)),1)))),'www.smartcursors.org"') 
where Communication like '%Website%'


Update Auth.[UserAccount] Set Communication= CASE WHEN Communication like '%@%' THEN 
replace(communication, substring(substring(Communication,charindex('@',Communication,1),
charindex('"',substring(Communication,charindex('@',Communication,1),
LEN(Communication)),1)),charindex('@',substring(Communication,charindex('@.',Communication,1),
charindex('"',substring(Communication,charindex('@',Communication,1),
LEN(Communication)),1)),1),LEN(substring(Communication,charindex('@',Communication,1),
charindex('"',substring(Communication,charindex('@',Communication,1),
LEN(Communication)),-1)))),'@smartcursors.org')
ELSE Communication END
where Communication like '%Email%'


Update Auth.[UserAccount] set Communication=replace(replace(replace(replace(replace(replace
(replace(replace( replace(replace(Communication,1,9),2,8),3,7),4,6),5,0),6,5),7,4),8,3),9,2),0,1) 
                                            
--select Communication from Bean.[Entity] -->no

Update Bean.[Entity]  Set Communication= REPLACE(Communication,
substring(substring(Communication,charindex('www.',Communication,1),
charindex('"',substring(Communication,charindex('www.',Communication,1),
LEN(Communication)),1)),charindex('www.',substring(Communication,charindex('www.',Communication,1),
charindex('"',substring(Communication,charindex('www.',Communication,1),
LEN(Communication)),1)),1),LEN(substring(Communication,charindex('www.',Communication,1),
charindex('"',substring(Communication,charindex('www.',Communication,1),
LEN(Communication)),1)))),'www.smartcursors.org"') 
where Communication like '%Website%'


Update Bean.[Entity]  Set Communication= CASE WHEN Communication like '%@%' THEN 
replace(communication, substring(substring(Communication,charindex('@',Communication,1),
charindex('"',substring(Communication,charindex('@',Communication,1),
LEN(Communication)),1)),charindex('@',substring(Communication,charindex('@.',Communication,1),
charindex('"',substring(Communication,charindex('@',Communication,1),
LEN(Communication)),1)),1),LEN(substring(Communication,charindex('@',Communication,1),
charindex('"',substring(Communication,charindex('@',Communication,1),
LEN(Communication)),-1)))),'@smartcursors.org')
ELSE Communication END
where Communication like '%Email%'


Update Bean.[Entity] set Communication=replace(replace(replace(replace(replace(replace
(replace(replace( replace(replace(Communication,1,9),2,8),3,7),4,6),5,0),6,5),7,4),8,3),9,2),0,1) 

--select Communication from Boardroom.[GenericContact] -->no

Update Boardroom.[GenericContact] Set Communication= REPLACE(Communication,
substring(substring(Communication,charindex('www.',Communication,1),
charindex('"',substring(Communication,charindex('www.',Communication,1),
LEN(Communication)),1)),charindex('www.',substring(Communication,charindex('www.',Communication,1),
charindex('"',substring(Communication,charindex('www.',Communication,1),
LEN(Communication)),1)),1),LEN(substring(Communication,charindex('www.',Communication,1),
charindex('"',substring(Communication,charindex('www.',Communication,1),
LEN(Communication)),1)))),'www.smartcursors.org"') 
where Communication like '%Website%'


Update Boardroom.[GenericContact] Set Communication= CASE WHEN Communication like '%@%' THEN 
replace(communication, substring(substring(Communication,charindex('@',Communication,1),
charindex('"',substring(Communication,charindex('@',Communication,1),
LEN(Communication)),1)),charindex('@',substring(Communication,charindex('@.',Communication,1),
charindex('"',substring(Communication,charindex('@',Communication,1),
LEN(Communication)),1)),1),LEN(substring(Communication,charindex('@',Communication,1),
charindex('"',substring(Communication,charindex('@',Communication,1),
LEN(Communication)),-1)))),'@smartcursors.org')
ELSE Communication END
where Communication like '%Email%'


Update Boardroom.[GenericContact] set Communication=replace(replace(replace(replace(replace(replace
(replace(replace( replace(replace(Communication,1,9),2,8),3,7),4,6),5,0),6,5),7,4),8,3),9,2),0,1) 


--select CurrentCommunication,ProposedCommunication from Boardroom.[OfficerChanges] -->no

Update Boardroom.[OfficerChanges] Set CurrentCommunication= REPLACE(CurrentCommunication,
substring(substring(CurrentCommunication,charindex('www.',CurrentCommunication,1),
charindex('"',substring(CurrentCommunication,charindex('www.',CurrentCommunication,1),
LEN(CurrentCommunication)),1)),charindex('www.',substring(CurrentCommunication,charindex('www.',CurrentCommunication,1),
charindex('"',substring(CurrentCommunication,charindex('www.',CurrentCommunication,1),
LEN(CurrentCommunication)),1)),1),LEN(substring(CurrentCommunication,charindex('www.',CurrentCommunication,1),
charindex('"',substring(CurrentCommunication,charindex('www.',CurrentCommunication,1),
LEN(CurrentCommunication)),1)))),'www.smartcursors.org"') 
where CurrentCommunication like '%Website%'


Update Boardroom.[OfficerChanges] Set CurrentCommunication= CASE WHEN CurrentCommunication like '%@%' THEN 
replace(CurrentCommunication, substring(substring(CurrentCommunication,charindex('@',CurrentCommunication,1),
charindex('"',substring(CurrentCommunication,charindex('@',CurrentCommunication,1),
LEN(CurrentCommunication)),1)),charindex('@',substring(CurrentCommunication,charindex('@.',CurrentCommunication,1),
charindex('"',substring(CurrentCommunication,charindex('@',CurrentCommunication,1),
LEN(CurrentCommunication)),1)),1),LEN(substring(CurrentCommunication,charindex('@',CurrentCommunication,1),
charindex('"',substring(CurrentCommunication,charindex('@',CurrentCommunication,1),
LEN(CurrentCommunication)),-1)))),'@smartcursors.org')
ELSE CurrentCommunication END
where CurrentCommunication like '%Email%'


Update Boardroom.[OfficerChanges] set CurrentCommunication=replace(replace(replace(replace(replace(replace
(replace(replace( replace(replace(CurrentCommunication,1,9),2,8),3,7),4,6),5,0),6,5),7,4),8,3),9,2),0,1) 


Update Boardroom.[OfficerChanges] Set ProposedCommunication= REPLACE(ProposedCommunication,
substring(substring(ProposedCommunication,charindex('www.',ProposedCommunication,1),
charindex('"',substring(ProposedCommunication,charindex('www.',ProposedCommunication,1),
LEN(ProposedCommunication)),1)),charindex('www.',substring(ProposedCommunication,charindex('www.',ProposedCommunication,1),
charindex('"',substring(ProposedCommunication,charindex('www.',ProposedCommunication,1),
LEN(ProposedCommunication)),1)),1),LEN(substring(ProposedCommunication,charindex('www.',ProposedCommunication,1),
charindex('"',substring(ProposedCommunication,charindex('www.',ProposedCommunication,1),
LEN(ProposedCommunication)),1)))),'www.smartcursors.org"') 
where ProposedCommunication like '%Website%'


Update Boardroom.[OfficerChanges] Set ProposedCommunication= CASE WHEN ProposedCommunication like '%@%' THEN 
replace(ProposedCommunication, substring(substring(ProposedCommunication,charindex('@',ProposedCommunication,1),
charindex('"',substring(ProposedCommunication,charindex('@',ProposedCommunication,1),
LEN(ProposedCommunication)),1)),charindex('@',substring(ProposedCommunication,charindex('@.',ProposedCommunication,1),
charindex('"',substring(ProposedCommunication,charindex('@',ProposedCommunication,1),
LEN(ProposedCommunication)),1)),1),LEN(substring(ProposedCommunication,charindex('@',ProposedCommunication,1),
charindex('"',substring(ProposedCommunication,charindex('@',ProposedCommunication,1),
LEN(ProposedCommunication)),-1)))),'@smartcursors.org')
ELSE ProposedCommunication END
where ProposedCommunication like '%Email%'


Update Boardroom.[OfficerChanges] set ProposedCommunication=replace(replace(replace(replace(replace(replace
(replace(replace( replace(replace(ProposedCommunication,1,9),2,8),3,7),4,6),5,0),6,5),7,4),8,3),9,2),0,1) 


--select Communication from ClientCursor.[Account]-->NO

Update ClientCursor.[Account] Set Communication= REPLACE(Communication,
substring(substring(Communication,charindex('www.',Communication,1),
charindex('"',substring(Communication,charindex('www.',Communication,1),
LEN(Communication)),1)),charindex('www.',substring(Communication,charindex('www.',Communication,1),
charindex('"',substring(Communication,charindex('www.',Communication,1),
LEN(Communication)),1)),1),LEN(substring(Communication,charindex('www.',Communication,1),
charindex('"',substring(Communication,charindex('www.',Communication,1),
LEN(Communication)),1)))),'www.smartcursors.org"') 
where Communication like '%Website%'


Update ClientCursor.[Account] Set Communication= CASE WHEN Communication like '%@%' THEN 
replace(communication, substring(substring(Communication,charindex('@',Communication,1),
charindex('"',substring(Communication,charindex('@',Communication,1),
LEN(Communication)),1)),charindex('@',substring(Communication,charindex('@.',Communication,1),
charindex('"',substring(Communication,charindex('@',Communication,1),
LEN(Communication)),1)),1),LEN(substring(Communication,charindex('@',Communication,1),
charindex('"',substring(Communication,charindex('@',Communication,1),
LEN(Communication)),-1)))),'@smartcursors.org')
ELSE Communication END
where Communication like '%Email%'


Update ClientCursor.[Account] set Communication=replace(replace(replace(replace(replace(replace
(replace(replace( replace(replace(Communication,1,9),2,8),3,7),4,6),5,0),6,5),7,4),8,3),9,2),0,1) 


--select Communication from ClientCursor.[AccountContact] -->Excel-->Communication/Emails,

Update ClientCursor.[AccountContact] Set Communication= REPLACE(Communication,
substring(substring(Communication,charindex('www.',Communication,1),
charindex('"',substring(Communication,charindex('www.',Communication,1),
LEN(Communication)),1)),charindex('www.',substring(Communication,charindex('www.',Communication,1),
charindex('"',substring(Communication,charindex('www.',Communication,1),
LEN(Communication)),1)),1),LEN(substring(Communication,charindex('www.',Communication,1),
charindex('"',substring(Communication,charindex('www.',Communication,1),
LEN(Communication)),1)))),'www.smartcursors.org"') 
where Communication like '%Website%'


Update ClientCursor.[AccountContact] Set Communication= CASE WHEN Communication like '%@%' THEN 
replace(communication, substring(substring(Communication,charindex('@',Communication,1),
charindex('"',substring(Communication,charindex('@',Communication,1),
LEN(Communication)),1)),charindex('@',substring(Communication,charindex('@.',Communication,1),
charindex('"',substring(Communication,charindex('@',Communication,1),
LEN(Communication)),1)),1),LEN(substring(Communication,charindex('@',Communication,1),
charindex('"',substring(Communication,charindex('@',Communication,1),
LEN(Communication)),-1)))),'@smartcursors.org')
ELSE Communication END
where Communication like '%Email%'


Update ClientCursor.[AccountContact] set Communication=replace(replace(replace(replace(replace(replace
(replace(replace( replace(replace(Communication,1,9),2,8),3,7),4,6),5,0),6,5),7,4),8,3),9,2),0,1) 


--select Username from ClientCursor.[AccountIncharge] -->no

Update ClientCursor.[AccountIncharge] set Username=REPLACE(Username,substring(Username,charindex('@',Username,1),LEN(Username)),'@smartcursors.org')
                                                     
--select BCCMail,CCMail from Common.[Communication]  

Update Common.[Communication]  set BCCMail=REPLACE(BCCMail,substring(BCCMail,charindex('@',BCCMail,1),LEN(BCCMail)),'@smartcursors.org')

--select Email from Common.[CompanyUser] 

Update Common.[CompanyUser] set Email=REPLACE(Email,substring(Email,charindex('@',Email,1),LEN(Email)),'@smartcursors.org')


--select Email from Common.[DocumentSigner] -->No

Update Common.[DocumentSigner] set Email=REPLACE(Email,substring(Email,charindex('@',Email,1),LEN(Email)),'@smartcursors.org')


--select AdminEmail from Common.[ExternalConfiguration] -->NO

Update Common.[ExternalConfiguration] set AdminEmail=REPLACE(AdminEmail,substring(AdminEmail,charindex('@',AdminEmail,1),LEN(AdminEmail)),'@smartcursors.org')


----select Recipient from Common.[ReminderBatchList] -->NO


--select UserName from Common.[Reply] -->NO

Update Common.[Reply]set UserName=REPLACE(UserName,substring(UserName,charindex('@',UserName,1),LEN(UserName)),'@smartcursors.org')


--select ToEmailId from Common.[Template] 

Update Common.[Template] set ToEmailId=REPLACE(ToEmailId,substring(ToEmailId,charindex('@',ToEmailId,1),LEN(ToEmailId)),'@smartcursors.org')

--select [Email 1],Email from dbo.[BR_Concate_New_devbackup]  -->Excel-->Building,Contact,[Email 1],Email

Update dbo.[BR_Concate_New_devbackup] set Email=REPLACE(Email,substring(Email,charindex('@',Email,1),LEN(Email)),'@smartcursors.org')

Update dbo.[BR_Concate_New_devbackup] set [Email 1]=REPLACE([Email 1],substring([Email 1],charindex('@',[Email 1],1),LEN([Email 1])),'@smartcursors.org')
                                                                        
--select [Email 1],Email from dbo.[BR_Concate_New_Table_devbackup]	-->Excel-->Building,Contact,[Email 1],Email 

Update dbo.[BR_Concate_New_Table_devbackup] set Email=REPLACE(Email,substring(Email,charindex('@',Email,1),LEN(Email)),'@smartcursors.org')

Update dbo.[BR_Concate_New_Table_devbackup] set [Email 1]=REPLACE([Email 1],substring([Email 1],charindex('@',[Email 1],1),LEN([Email 1])),'@smartcursors.org')


--select EntityEmail,PersonalEmail from dbo.[ImportBeanContacts] -->NO

Update dbo.[ImportBeanContacts] set EntityEmail=REPLACE(EntityEmail,substring(EntityEmail,charindex('@',EntityEmail,1),LEN(EntityEmail)),'@smartcursors.org')

Update dbo.[ImportBeanContacts] set PersonalEmail=REPLACE(PersonalEmail,substring(PersonalEmail,charindex('@',PersonalEmail,1),LEN(PersonalEmail)),'@smartcursors.org')

--select EntityEmail,EntityLocalAddress,PersonalEmail from dbo.[ImportContacts] -->NO

Update dbo.[ImportContacts] set EntityEmail=REPLACE(EntityEmail,substring(EntityEmail,charindex('@',EntityEmail,1),LEN(EntityEmail)),'@smartcursors.org')

Update dbo.[ImportContacts] set PersonalEmail=REPLACE(PersonalEmail,substring(PersonalEmail,charindex('@',PersonalEmail,1),LEN(PersonalEmail)),'@smartcursors.org')

--select Email from dbo.[ImportEntities] --NO

Update dbo.[ImportEntities] set Email=REPLACE(Email,substring(Email,charindex('@',Email,1),LEN(Email)),'@smartcursors.org')

--select email,Foreignaddress,LocalAddress,Phone from dbo.[ImportLeads]  -->NO

Update dbo.[ImportLeads]  set Email=REPLACE(Email,substring(Email,charindex('@',Email,1),LEN(Email)),'@smartcursors.org')

--Update dbo.[ImportLeads] Set Phone=Replace(Phone,Phone,'XXXXXXXXXX')

--Select Phone,Replace(Phone,Phone,'XXXXXXXXXX') from dbo.ImportLeads

--select email,LocalAddress,Mobile from dbo.[ImportPersonalDetails] -->NO

Update dbo.[ImportPersonalDetails]  set email=REPLACE(email,substring(email,charindex('@',email,1),LEN(email)),'@smartcursors.org')

Update dbo.[ImportPersonalDetails] Set Mobile=Replace(Mobile,Mobile,'XXXXXXXXXX')

--select Email from dbo.[ImportWFClient] -->NO

Update dbo.[ImportWFClient]  set email=REPLACE(email,substring(email,charindex('@',email,1),LEN(email)),'@smartcursors.org')

--select EntityEmail,PersonalEmail from dbo.[ImportWFContacts] -->No

Update dbo.[ImportWFContacts]  set EntityEmail=REPLACE(EntityEmail,substring(EntityEmail,charindex('@',EntityEmail,1),LEN(EntityEmail)),'@smartcursors.org')

Update dbo.[ImportWFContacts]  set PersonalEmail=REPLACE(PersonalEmail,substring(PersonalEmail,charindex('@',PersonalEmail,1),LEN(PersonalEmail)),'@smartcursors.org')


--select email from dbo.[Share_Contact_NEw_devbackup] --NO

Update dbo.[Share_Contact_NEw_devbackup] set email=REPLACE(email,substring(email,charindex('@',email,1),LEN(email)),'@smartcursors.org')

--select UserName,Email from dbo.[Users] -->Excel-->UserName,Email                              

--select username from dbo.[VW_Payroll] -->No


--select username from dbo.[VW_User_SupportPBI] -->No

--Update [VW_User_SupportPBI] set username=REPLACE(username,substring(username,charindex('@',username,1),LEN(username)),'@smartcursors.org')

Update Support.[Ticket] set CCEmails=REPLACE(CCEmails,substring(CCEmails,charindex('@',CCEmails,1),LEN(CCEmails)),'@smartcursors.org')

-------Notification.[NotificationSettings]-----------

Update  AA Set OtherRecipients=OtherRecipients_New
from 
(
select  t.OtherRecipients,tt.OtherRecipients_New from Notification.[NotificationSettings] t
inner join Temp1_OtherRecipients_New tt on tt.id=t.id
where t.OtherRecipients<>''
)as AA


Update BB  Set OtherEmailRecipient=OtherEmailRecipient_New 
from 
(
select  t.OtherEmailRecipient,tt.OtherEmailRecipient_New from Notification.[NotificationSettings] t
inner join Temp1_OtherEmailRecipient_New tt on tt.id=t.id
where t.OtherEmailRecipient<>''
)as bb

---------Common.[Communication]------------

Update CC Set CCMail=CCMail_New 
from 
(
select  t.CCMail,tt.CCMail_New from Common.[Communication] t
inner join Temp1_CCMaill_New tt on tt.id=t.id
where t.CCMail<>''
)as CC

---------Common.[ReminderBatchList]-------- 
Update DD Set Recipient=Recipient_New 
from 

(
select  t.Recipient,tt.Recipient_New from Common.[ReminderBatchList]  t
inner join Temp1_Recipient_New tt on tt.id=t.id
where t.Recipient<>''
)as DD



End
GO
