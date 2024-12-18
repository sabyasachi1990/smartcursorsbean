USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[GetPartnerDashBoardData]    Script Date: 16-12-2024 9.20.10 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

--CREATE NONCLUSTERED INDEX [<TrialBalanceImport_EngagementId>]
--ON [Audit].[TrialBalanceImport] ([EngagementId])

--exec [dbo].[GetPartnerDashBoardData] 'jiayi.ong@smartcursors.org',1

CREATE Procedure  [dbo].[GetPartnerDashBoardData]
@UserName Varchar(500),
@PartnerCompanyId Bigint

As
Begin 
--Declare @UserName Varchar(500)='john@smartcursors.org'


Select SUM(Total) AS Total,SUM([Not Yet Started]) AS 'NotYetStarted',SUM([Process Engs]) AS 'Progress',SUM([Completed Engs]) AS 'Completed'  From (
--Total
Select Count(AC.Id) AS 'Total',0 AS 'Not Yet Started',0 AS 'Process Engs',0 AS 'Completed Engs' from Audit.AuditCompanyEngagement AC 
Inner Join Audit.AuditCompanyEngagementDetails  AD ON AC.Id=AD.AuditCompanyEngagementId

Where AD.UserName=@UserName AND AC.Status=1

Union ALL
---------Not Yet Started 
Select 0 AS 'Total',Count(AC.Id) AS 'Not Yet Started',0 AS 'Process Engs',0 AS 'Completed Engs' from Audit.AuditCompanyEngagement AC 
Inner Join Audit.AuditCompanyEngagementDetails  AD ON AC.Id=AD.AuditCompanyEngagementId
Left Join audit.trialbalanceimport  TI ON TI.engagementid=AC.ID
Where AD.UserName=@UserName AND AC.Status=1 AND TI.EngagementId IS NULL

--Process Engs
Union ALL

Select 0 AS 'Total',0 AS 'Not Yet Started',Count( Distinct AC.Id) AS 'Process Engs',0 AS 'Completed Engs' from Audit.AuditCompanyEngagement AC 
Inner Join Audit.AuditCompanyEngagementDetails  AD ON AC.Id=AD.AuditCompanyEngagementId
--Left Join audit.userapproval UA ON UA.engagementid=AC.ID
Where AD.UserName=@UserName   AND AC.Status=1 and Ac.id  not in 
(select Engagementid from audit.userapproval where Screen ='Approvel' and type='Approved' )
and Ac.id  in (select Engagementid from audit.trialbalanceimport)

--Completed Engs 

Union ALL
Select  0 AS 'Total',0 AS 'Not Yet Started',0 AS 'Process Engs',Count(AC.Id) AS 'Completed Engs' 
from Audit.AuditCompanyEngagement AC 
Inner Join Audit.AuditCompanyEngagementDetails  AD ON AC.Id=AD.AuditCompanyEngagementId
--Left Join audit.userapproval UA ON UA.engagementid=AC.ID
Where AD.UserName=@UserName   AND AC.Status=1 and Ac.id in 
(select Engagementid from audit.userapproval where Screen ='Approvel' and type='Approved' )
and Ac.id  in (select Engagementid from audit.trialbalanceimport)

) AS A

----------------------------------------------------------------------------------------------------------

Declare @MINYear INT
Declare @Temp Table(Name NVarchar(100),Value INT,Year INT)

Declare @StartDate DateTime=(Select Min(AC.StartDate) From Audit.AuditCompanyEngagement AC 
Inner Join Audit.AuditCompanyEngagementDetails  AD ON AC.Id=AD.AuditCompanyEngagementId
Where AD.UserName=@UserName AND AC.Status=1
)

Declare @ENDDate DateTime=(Select MAX(AC.StartDate) From Audit.AuditCompanyEngagement AC 
Inner Join Audit.AuditCompanyEngagementDetails  AD ON AC.Id=AD.AuditCompanyEngagementId
Where AD.UserName=@UserName AND AC.Status=1
)


Insert INTO @Temp 

Select Name,Value,Year/*Case When Year>MIN(Year)+9 Then '>10Ys' Else Year END AS Year*/
	From 
	( 
Select SUM(Total) AS Total,SUM([Not Yet Started]) AS 'NotYetStarted',SUM([Process Engs]) AS 'Progress',SUM([Completed Engs]) AS 'Completed',Year/*, MIN(Year),Case When Year>MIN(Year)+9 Then '>10Ys' Else Year END AS Year,MIN(Year)*/
From 
(
--Total
Select Count(AC.Id) AS 'Total',0 AS 'Not Yet Started',0 AS 'Process Engs',0 AS 'Completed Engs',Year(AC.StartDate) AS Year from Audit.AuditCompanyEngagement AC 
Inner Join Audit.AuditCompanyEngagementDetails  AD ON AC.Id=AD.AuditCompanyEngagementId
Where AD.UserName=@UserName AND AC.Status=1
Group By Year(AC.StartDate) 

Union ALL
---------Not Yet Started 
Select 0 AS 'Total',Count(AC.Id) AS 'Not Yet Started',0 AS 'Process Engs',0 AS 'Completed Engs',Year(AC.StartDate) AS Year from Audit.AuditCompanyEngagement AC 
Inner Join Audit.AuditCompanyEngagementDetails  AD ON AC.Id=AD.AuditCompanyEngagementId
Left Join audit.trialbalanceimport  TI ON TI.engagementid=AC.ID
Where AD.UserName=@UserName AND AC.Status=1 AND TI.EngagementId IS NULL
Group By Year(AC.StartDate)
--Process Engs
Union ALL

Select 0 AS 'Total',0 AS 'Not Yet Started',Count( Distinct AC.Id) AS 'Process Engs',0 AS 'Completed Engs',Year(AC.StartDate) AS Year from Audit.AuditCompanyEngagement AC 
Inner Join Audit.AuditCompanyEngagementDetails  AD ON AC.Id=AD.AuditCompanyEngagementId
--Left Join audit.userapproval UA ON UA.engagementid=AC.ID
Where AD.UserName=@UserName   AND AC.Status=1 and Ac.id  not in 
(select Engagementid from audit.userapproval where Screen ='Approvel' and type='Approved' )
and Ac.id  in (select Engagementid from audit.trialbalanceimport)
Group By Year(AC.StartDate)
--Completed Engs 

Union ALL
Select  0 AS 'Total',0 AS 'Not Yet Started',0 AS 'Process Engs',Count(AC.Id) AS 'Completed Engs',Year(AC.StartDate) AS Year from Audit.AuditCompanyEngagement AC 
Inner Join Audit.AuditCompanyEngagementDetails  AD ON AC.Id=AD.AuditCompanyEngagementId
--Left Join audit.userapproval UA ON UA.engagementid=AC.ID
Where AD.UserName=@UserName   AND AC.Status=1 and Ac.id in 
(select Engagementid from audit.userapproval where Screen ='Approvel' and type='Approved' )
and Ac.id  in (select Engagementid from audit.trialbalanceimport)
Group By Year(AC.StartDate)
) AS A
Group By Year
) B
UNPIVOT
	(
		Value For Name in (Total,NotYetStarted,Progress,Completed)
	)PVT

	Order By Year

	SET @MINYear=(Select MIN(Year)+9 Year From @Temp)

		SET @MINYear=(Select MIN(Year)+9 Year From @Temp)

	--Select Name,SUM(Value) Value,Case When Year>@MINYear Then '>10Ys' Else Cast(Year AS Nvarchar(100)) END AS Year From @Temp
	--Group BY Name,Case When Year>@MINYear Then '>10Ys' Else Cast(Year AS Nvarchar(100)) END
	--Order By Case When Year>@MINYear Then '>10Ys' Else Cast(Year AS Nvarchar(100)) END

	Select Name,SUM(Value) Value,Year
	From (
		Select  Name,Value Value,Case When Year>@MINYear Then '>10Ys' Else Cast(Year AS Nvarchar(100)) END AS Year
		
		From (
	Select Name,case when Year=Year(CreatedDate) then Value else 0 end as Value,Year(CreatedDate) AS Year  From @Temp
	Cross JOIN  
      (  
	  
 SELECT  TOP (DATEDIFF(DAY, @StartDate, @ENDDate) + 1)
        CreatedDate = convert(Date,DATEADD(DAY, ROW_NUMBER() OVER(ORDER BY a.object_id) - 1, @StartDate))
  FROM    sys.all_objects a
        CROSS JOIN sys.all_objects b
  
    ) AS PP 
	Group BY Name,Value,Year,PP.CreatedDate
	) AS B
	Group By Name,Value,Year			     
	) A 
	 --Where Name='Total'
	Group BY Name,Year
	Order By Case When Year Not Like '%>10Ys%' then 'A'
	              When Year Like '%>10Ys%' then 'B' END 
	/*	Select  Name,SUM(Value) Value,Year  From (
	Select Name,SUM(Value) Value,Case When Year>@MINYear Then '>10Ys' Else Cast(Year AS Nvarchar(100)) END AS Year From @Temp
	Group BY Name,Case When Year>@MINYear Then '>10Ys' Else Cast(Year AS Nvarchar(100)) END
	) A 
	Group BY Name,Year
	Order By Case When Year Not Like '%>10Ys%' then 'A'
	              When Year Like '%>10Ys%' then 'B' END */

-------------------------------------------------------------------------------------------------------------------------------
--Declare @UserName Varchar(500)='john@smartcursors.org',@PartnerCompanyId Bigint=689

Declare @Temp1 Table(FirstName NVarchar(500),Username NVarchar(500))

Insert INTO @Temp1 
--Select  Distinct Top 10 CU.FirstName AS FirstName,CU.Username from  Audit.AuditCompany AAC /*ON ACE.AuditCompanyId=AAC.Id*/
--Inner Join Common.CompanyUser CU ON CU.CompanyId=AAC.CompanyId
--Inner Join Common.CompanyModule CM ON CM.CompanyId=AAC.CompanyId
--Where  CU.UserName <>@UserName
--AND CM.ModuleId=3 And CM.Status=1 

--AND CM.CompanyId in (select ID from common.company where id=@PartnerCompanyId and parentid is null and IsAccountingFirm=1
--Union
--select ID from common.company where ParentId in (select id from common.company where id=@PartnerCompanyId and parentid is null and IsAccountingFirm=1))
Select Distinct Top 10 CU.FirstName AS FirstName,CU.Username From 

Common.CompanyUser CU Where CU.CompanyId IN (Select CompanyId From Common.CompanyModule Where Status=1 AND ModuleId=3 AND CompanyId In (
select ID from common.company where id=@PartnerCompanyId and parentid is null and IsAccountingFirm=1
Union
select ID from common.company where ParentId in (select id from common.company where id=@PartnerCompanyId and parentid is null and IsAccountingFirm=1)) 
) AND  CU.UserName <>@UserName

-------------------------------------------------------------------------------------------
Select Name,Value,UserName/*Case When Year>MIN(Year)+9 Then '>10Ys' Else Year END AS Year*/
	From 
	( 
Select SUM(Total) AS Total,SUM([Not Yet Started]) AS 'NotYetStarted',SUM([Process Engs]) AS 'Progress',SUM([Completed Engs]) AS 'Completed',UserName/*, MIN(Year),Case When Year>MIN(Year)+9 Then '>10Ys' Else Year END AS Year,MIN(Year)*/
From 
(
--Total
Select Count(AC.Id) AS 'Total',0 AS 'Not Yet Started',0 AS 'Process Engs',0 AS 'Completed Engs',T.FirstName UserName from Audit.AuditCompanyEngagement AC 
Inner Join Audit.AuditCompanyEngagementDetails  AD ON AC.Id=AD.AuditCompanyEngagementId
Inner Join @Temp1 T ON T.Username=AD.UserName
Where AD.UserName IN (Select Username From @Temp1) AND AC.Status=1
Group By T.FirstName 

Union ALL
---------Not Yet Started 
Select 0 AS 'Total',Count(AC.Id) AS 'Not Yet Started',0 AS 'Process Engs',0 AS 'Completed Engs',T.FirstName UserName from Audit.AuditCompanyEngagement AC 
Inner Join Audit.AuditCompanyEngagementDetails  AD ON AC.Id=AD.AuditCompanyEngagementId
Left Join audit.trialbalanceimport  TI ON TI.engagementid=AC.ID
Inner Join @Temp1 T ON T.Username=AD.UserName
Where AD.UserName IN (Select Username From @Temp1) AND AC.Status=1 AND TI.EngagementId IS NULL
Group By T.FirstName 
--Process Engs
Union ALL

Select 0 AS 'Total',0 AS 'Not Yet Started',Count( Distinct AC.Id) AS 'Process Engs',0 AS 'Completed Engs',T.FirstName UserName from Audit.AuditCompanyEngagement AC 
Inner Join Audit.AuditCompanyEngagementDetails  AD ON AC.Id=AD.AuditCompanyEngagementId
--Left Join audit.userapproval UA ON UA.engagementid=AC.ID
Inner Join @Temp1 T ON T.Username=AD.UserName
Where AD.UserName IN (Select Username From @Temp1)  AND AC.Status=1 and Ac.id  not in 
(select Engagementid from audit.userapproval where Screen ='Approvel' and type='Approved' )
and Ac.id  in (select Engagementid from audit.trialbalanceimport)
Group By T.FirstName 
--Completed Engs 

Union ALL
Select  0 AS 'Total',0 AS 'Not Yet Started',0 AS 'Process Engs',Count(AC.Id) AS 'Completed Engs',T.FirstName UserName from Audit.AuditCompanyEngagement AC 
Inner Join Audit.AuditCompanyEngagementDetails  AD ON AC.Id=AD.AuditCompanyEngagementId
--Left Join audit.userapproval UA ON UA.engagementid=AC.ID
Inner Join @Temp1 T ON T.Username=AD.UserName
Where AD.UserName IN (Select Username From @Temp1)   AND AC.Status=1 and Ac.id in 
(select Engagementid from audit.userapproval where Screen ='Approvel' and type='Approved' )
and Ac.id  in (select Engagementid from audit.trialbalanceimport)
Group By T.FirstName 
) AS A
Group By UserName
) B
UNPIVOT
	(
		Value For Name in (Total,NotYetStarted,Progress,Completed)
	)PVT

	Order By UserName

	END
GO
