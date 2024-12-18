USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[HctServiceBlade]    Script Date: 16-12-2024 9.20.10 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[HctServiceBlade]   

--Modified In Local Build By Kishore 
   
@CompanyId BIGINT, 
@Fromdate Datetime ,
@Todate Datetime,
@ServiceId int                                

AS                                      

BEGIN 

--Getting Revenue Service Details
--Table 0

print'0'
select S.Name as 'Service',Sum(O.fee) as 'Amount' from [ClientCursor].[Opportunity] as O
inner join [Common].[Service] as S ON S.Id=O.ServiceId
WHERE O.ServiceId in (@ServiceId) 
and (o.createddate between @Fromdate and @Todate)
Group BY S.Name
print '1'
--select YEAR(CREATEDDATE)Year,COUNT(ISACCOUNT) 'Acount&Lead',(COUNT(CASE WHEN ISACCOUNT =1 THEN 1 END))Account,(COUNT(CASE WHEN ISACCOUNT =0 THEN 1 END))Lead,
-- (Convert(Varchar,(100 * (COUNT(CASE WHEN ISACCOUNT =1 THEN 1 END)) / (count(ISACCOUNT))))+'%')'Percent'
--from [CLIENTCURSOR].[ACCOUNT]
--group by YEAR(CREATEDDATE);

--Getting Lead Conversion and Count
--Table 1
print'2'
--select COUNT(ISACCOUNT) 'Acount',(COUNT(CASE WHEN ISACCOUNT =0 THEN 1 END))Lead,
--(Convert(Varchar,(100 * (COUNT(CASE WHEN ISACCOUNT =1 THEN 1 END)) / (count(ISACCOUNT))))+'%')'Percent'
--from [CLIENTCURSOR].[ACCOUNT]
-- where  (createddate between @Fromdate and @Todate)


 select COUNT(ISACCOUNT) 'Acount',(COUNT(CASE WHEN ISACCOUNT =0 THEN 1 END))Lead,
 (Convert(Varchar,(100 * (COUNT(CASE WHEN ISACCOUNT =1 THEN 1 END)) / (count(ISACCOUNT))))+'%')'Percent'
from [CLIENTCURSOR].[ACCOUNT]
where (createddate between @Fromdate and @Todate)

 print'3'
--Getting Service CompanyWise Revenue
--Table 2
SELECT      ISNULL(C.Name, 'Others') AS CompanyName, SUM(O.Fee)Amount FROM  ClientCursor.Opportunity AS O
 INNER JOIN Common.Company AS C ON C.Id = O.ServiceCompanyId
 inner join [Common].[Service] as S ON S.Id=O.ServiceId
 WHERE O.ServiceId in (@ServiceId) 
	and (o.createddate between @Fromdate and @Todate)
 Group By C.Name
 print'4'
 --Top 1 Highest Fee
--Table 3
SELECT top 1 S.Name as 'Service' ,SUM(O.Fee) as 'Fee' FROM [ClientCursor].[Opportunity]as o
inner join [Common].[Service] as S ON S.Id=O.ServiceId
Group by S.Name 
order by SUM(o.Fee) DESC
print'5'
--Top 1 Lowest Fee
--Table 4
SELECT top 1 S.Name as 'Service' ,SUM(O.Fee) as 'Fee' FROM [ClientCursor].[Opportunity]as o
inner join [Common].[Service] as S ON S.Id=O.ServiceId
Group by S.Name 
order by SUM(o.Fee) ASC
print'6'
 --Getting Top 10 Opportunities List
--Table 5
 SELECT  Top 10 OpportunityNumber,A.Name as 'Account', o.CreatedDate,o.Fee FROM  ClientCursor.Opportunity as O
 inner Join [ClientCursor].[Account] as A on A.id=O.AccountId
 Order By o.CreatedDate DESC

END
GO
