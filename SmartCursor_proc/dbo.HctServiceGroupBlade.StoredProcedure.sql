USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[HctServiceGroupBlade]    Script Date: 16-12-2024 9.20.10 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[HctServiceGroupBlade]   
--Modified In Local Build By Kishore    
@CompanyId BIGINT, 
@Fromdate Datetime ,
@Todate Datetime,
@ServiceGroupId INT                           

AS                                      
BEGIN 
--Getting Revenue ServiceGroup Details
--Table 0

select SG.Name as 'ServiceGroup',Sum(O.fee) as 'Amount' from [ClientCursor].[Opportunity] as O
inner join [Common].[ServiceGroup] as SG ON SG.Id=O.ServiceGroupId
where  O.ServiceGroupId in (select items from dbo.SplitToTable(@ServiceGroupId,','))
and (o.createddate between @Fromdate and @Todate)
and o.CompanyId =@CompanyId 
Group BY SG.Name



--select YEAR(CREATEDDATE)Year,COUNT(ISACCOUNT) 'Acount&Lead',(COUNT(CASE WHEN ISACCOUNT =1 THEN 1 END))Account,(COUNT(CASE WHEN ISACCOUNT =0 THEN 1 END))Lead,
-- (Convert(Varchar,(100 * (COUNT(CASE WHEN ISACCOUNT =1 THEN 1 END)) / (count(ISACCOUNT))))+'%')'Percent'
--from [CLIENTCURSOR].[ACCOUNT]
--group by YEAR(CREATEDDATE);

--Getting Lead Conversion and Count
--Table 1

select COUNT(ISACCOUNT) 'Acount',(COUNT(CASE WHEN ISACCOUNT =0 THEN 1 END))Lead,
 (Convert(Varchar,(100 * (COUNT(CASE WHEN ISACCOUNT =1 THEN 1 END)) / (count(ISACCOUNT))))+'%')'Percent'
from [CLIENTCURSOR].[ACCOUNT]
where (createddate between @Fromdate and @Todate)
and CompanyId =@CompanyId

--Getting Service CompanyWise Revenue
--Table 2

SELECT      ISNULL(C.Name, 'Others') AS CompanyName, SUM(O.Fee)Fee
FROM            ClientCursor.Opportunity AS O INNER JOIN
                         Common.Company AS C ON C.Id = O.ServiceCompanyId
						 WHERE  O.ServiceGroupId in (select items from dbo.SplitToTable(@ServiceGroupId,','))
						 and (o.createddate between @Fromdate and @Todate)
						 and o.CompanyId =@CompanyId
						 Group By C.Name
      
-- (CONVERT(CHAR(4), O.CreatedDate, 120) = @InDate) AND (O.ServiceGroupId IN (@ServiceGroup))
--Top 1 Highest Fee
--Table 3
SELECT top 1 SG.Name as 'ServiceGroup' ,O.Fee as 'Fee' FROM [ClientCursor].[Opportunity]as o
inner join [Common].[ServiceGroup] as SG ON SG.Id=O.ServiceGroupId
where o.CompanyId =@CompanyId
and (o.createddate between @Fromdate and @Todate)
and  O.ServiceGroupId in (select items from dbo.SplitToTable(@ServiceGroupId,','))
--Group by SG.Name 
order by o.Fee DESC

--Top 1 Lowest Fee
--Table 4
SELECT top 1 SG.Name as 'ServiceGroup' ,O.Fee as 'Fee' FROM [ClientCursor].[Opportunity]as o
inner join [Common].[ServiceGroup] as SG ON SG.Id=O.ServiceGroupId
where o.CompanyId =@CompanyId
and (o.createddate between @Fromdate and @Todate)
and  O.ServiceGroupId in (select items from dbo.SplitToTable(@ServiceGroupId,','))
--Group by SG.Name 
order by o.Fee ASC

--Getting Top 10 Opportunities List
--Table 5
SELECT  Top 10 OpportunityNumber,A.Name as 'Account', o.CreatedDate,o.Fee FROM  ClientCursor.Opportunity as O
 inner Join [ClientCursor].[Account] as A on A.id=O.AccountId
 where o.CompanyId =@CompanyId
and (o.createddate between @Fromdate and @Todate)
and  O.ServiceGroupId in (select items from dbo.SplitToTable(@ServiceGroupId,','))
 Order By o.CreatedDate DESC

END
GO
