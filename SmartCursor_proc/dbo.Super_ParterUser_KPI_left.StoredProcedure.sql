USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[Super_ParterUser_KPI_left]    Script Date: 16-12-2024 9.20.11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE Procedure [dbo].[Super_ParterUser_KPI_left]
as
Begin 
----------------- PARTER USER kPI 
 Select SUM(Clients)  AS Clients ,sum(isnull([Client Cursor],0)) as 'CC',sum(isnull([Workflow Cursor],0)) as 'WF', sum(isnull([HR Cursor],0)) as 'HR',sum(isnull([Bean Cursor],0)) as 'BC', sum(isnull([Tax Cursor],0)) as 'Tax',sum(isnull([Audit Cursor],0)) as 'Audit',sum(isnull([Admin Cursor],0)) as  'Admin',(Users) as Users 
  FROM 
  (
  SELECT DISTINCT  MM.Name ,COUNT(distinct C.Id) AS 'Count',  LL.Users as Users,AID AS Clients 
  FROM COMMON.company C
  inner  join Common.CompanyUser Cu on Cu.CompanyId=c.id   and CU.Status=1 and CU.IsPartnerUser=1
  --inner  join ClientCursor.Account A ON A.CompanyId=C.Id AND A.Status=1
   inner join Common.CompanyModule Cm on Cm.CompanyId=C.Id AND CM.Status=1
    inner join Common.ModuleMaster MM ON MM.ID=CM.ModuleId AND MM.Status=1
	INNER JOIN 
  (
  SELECT DISTINCT ID, SUM(Users) OVER() AS Users FROM 
  (
   SELECT C.ID ,Cu.id AS EID,count( distinct Cu.id) as Users
  FROM COMMON.company C
  inner  join Common.CompanyUser Cu on Cu.CompanyId=c.id   and CU.Status=1 and CU.IsPartnerUser=1
  --inner  join ClientCursor.Account A ON A.CompanyId=C.Id AND A.Status=1
   inner join Common.CompanyModule Cm on Cm.CompanyId=C.Id AND CM.Status=1
    inner join Common.ModuleMaster MM ON MM.ID=CM.ModuleId AND MM.Status=1
	where C.Status=1 AND C.IsAccountingFirm=1 --------AND CONVERT(DATE,C.CreatedDate) Between @FromDate and @ToDate
	--- AND C.ID=19
	GROUP BY C.ID ,Cu.id
	) DD
	)LL ON LL.ID=C.ID 
	LEFT JOIN 
(

 select DISTINCT   CID,sum(AID) over() as AID FROM 
 (
  SELECT distinct   CID,AID as eid,COUNT (distinct AID) AS AID FROM 
 (
 SELECT distinct  C.Id AS CID,A.ID  as  AID
  FROM COMMON.company C
inner JOIN ClientCursor.Account A ON A.CompanyId=C.Id AND A.Status=1 and a.isaccount=1
 WHERE C.Status=1 AND C.IsAccountingFirm=1 ---- AND CONVERT(DATE,C.CreatedDate) Between @FromDate and @ToDate
 --and c.id=19
 union all
 SELECT distinct  C.Id AS CID,CASE WHEN ca.accountid is null  THEN CA.ID END  AS AID
  FROM COMMON.company C
inner join workflow.client CA on CA.CompanyId=C.Id
 WHERE C.Status=1 AND C.IsAccountingFirm=1  and CASE WHEN ca.accountid is null  THEN CA.ID END is not null --AND CONVERT(DATE,C.CreatedDate) Between @FromDate and @ToDate
 --AND C.ID=19
 ) SS
 group by CID,AID
 ) FF
 )DD ON DD.CID =C.ID
   where C.Status=1 AND C.IsAccountingFirm=1  ----- AND CONVERT(DATE,C.CreatedDate) Between @FromDate and @ToDate
   AND MM.NAME in ( 'Client Cursor','Workflow Cursor','Audit Cursor','Bean Cursor','Tax Cursor','HR Cursor','Admin Cursor')
   ---and C.Id=19
   group by MM.Name,AID,LL.Users
   ) DD
   PIVOT
(
SUM(Count) FOR Name in ([Client Cursor] ,[Workflow Cursor] , [HR Cursor] ,[Bean Cursor] ,[Tax Cursor] ,[Audit Cursor] ,[Admin Cursor])
)
Pivottable
group by Users
-----------------------------------LEFT SIDE

 SELECT  Name,[Count]  AS 'Count',DATE  FROM 
(
   SELECT DISTINCT  MM.Name ,COUNT(distinct C.Id) AS 'Count' ,CONVERT(DATE,C.CreatedDate) AS DATE 
  FROM COMMON.company C
  inner  join Common.CompanyUser Cu on Cu.CompanyId=c.id   and CU.Status=1 and CU.IsPartnerUser=1
  inner  join ClientCursor.Account A ON A.CompanyId=C.Id AND A.Status=1
   inner join Common.CompanyModule Cm on Cm.CompanyId=C.Id AND CM.Status=1
    inner join Common.ModuleMaster MM ON MM.ID=CM.ModuleId AND MM.Status=1
	  where C.Status=1 AND C.IsAccountingFirm=1  -----AND CONVERT(DATE,C.CreatedDate) Between @FromDate and @ToDate
   AND MM.NAME in ( 'Client Cursor','Workflow Cursor','Audit Cursor','Bean Cursor','Tax Cursor','HR Cursor','Admin Cursor')
   ---and C.Id=19
     group by MM.Name,CONVERT(DATE,C.CreatedDate)
	 )DD

	end 
















 
GO
