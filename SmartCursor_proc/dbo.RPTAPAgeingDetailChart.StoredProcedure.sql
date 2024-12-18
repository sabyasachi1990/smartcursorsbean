USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[RPTAPAgeingDetailChart]    Script Date: 16-12-2024 9.20.11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE Procedure [dbo].[RPTAPAgeingDetailChart]


   @FromDate  Varchar(50),                            
   @ToDate  Varchar(50) ,
   @CompanyValue Varchar(10),
   @Type INT,
   @ServiceCompanyId varchar(100)  
   
    
 AS

   Begin


   Declare @CompanyId Int    
   --SET @ToDate = CONVERT(DATETIME, CONVERT(varchar(11),@ToDate, 103 ) + ' 23:59:59', 103)
   select @CompanyId = dbo.DecryptCompanyValue(@CompanyValue) 

select Ageing,BalanceAmount, case when Ageing='Below 0' then 1 when Ageing='Current' then 2 when Ageing='1 - 30' then 3 when Ageing='31 - 60' then 4 when Ageing='61 - 90' then 5 when Ageing='>90' then 6 end as Recorder
from
 (

  Select CASE When C.PastDue <0 THEN   'Below 0' 
         When C.PastDue=0  Then  'Current'
         When C.PastDue>=1 AND C.PastDue<=30 Then  '1 - 30'
         When C.PastDue>=31 AND C.PastDue<=60 Then '31 - 60'
         When C.PastDue>=61 AND C.PastDue<=90 Then   '61 - 90'
         When C.PastDue>=91 Then  '>90'  END AS 'Ageing',SUM(BalanceAmount)  BalanceAmount
		

From 


    (

	Select E.Name AS 'EntityName',SC.Name AS ServiceCompany,JD.DocType,JD.DocDate,JD.DocNo,J.PoNo,
 DATEDIFF(d, JD.DocDate, getdate()) as PastDue, --(JD.BaseCredit+(JD.BaseCredit*(JD.TaxRate/100))) as 'BalanceAmount' 
        Case When ISNULL(SUM(JD.AmountDue),0)>0 then (ISNULL(SUM(JD.AmountDue),0)*ISNULL(JD.ExchangeRate,0)) Else 
		ISNULL(SUM(JD.BaseCredit),0) END  AS BalanceAmount--ISNULL(SUM(JD.BaseCredit),0) AS BalanceAmount 


FROM  [Bean].[JournalDetail] JD 


   Inner Join [Bean].[Journal] J ON J.Id=JD.JournalId
   Left  Join [Bean].[Entity] as E On E.Id =JD.EntityId
   Left  Join [Bean].[ChartOfAccount] as C on C.Id=JD.COAId
   Left  Join Common.Company SC ON SC.Id=JD.ServiceCompanyId


Where JD.DocType='Bill' AND C.CompanyId=@CompanyValue
      AND J.DocumentState IN ('Not Paid','Partial Paid') AND E.IsVendor=1
      AND JD.DocDate Between CONVERT(datetime, @FromDate, 103) AND CONVERT(datetime, @ToDate, 103) 
      AND SC.Id in (select items from dbo.SplitToTable(@ServiceCompanyId,',')) 


Group By E.Name,SC.Name,JD.DocType,JD.DocNo,JD.DocDate,J.PoNo,JD.ExchangeRate

--      Select SC.Name AS ServiceCompany,DATEDIFF(d, JD.DocDate, getdate()) as PastDue, --(JD.BaseCredit+(JD.BaseCredit*(JD.TaxRate/100))) as 'BalanceAmount' 
--             Case When ISNULL(SUM(JD.AmountDue),0)>0 then (ISNULL(SUM(JD.AmountDue),0)*ISNULL(JD.ExchangeRate,0)) Else ISNULL(SUM(JD.BaseCredit),0) END  AS BalanceAmount--ISNULL(SUM(JD.BaseCredit),0) AS BalanceAmount 


--FROM [Bean].[FactJournalDetail] JD 


--   Inner Join [Bean].[FactJournal] J ON J.Id=JD.JournalId
--   Left  Join [Bean].[DimEntity] as E On E.Id =JD.EntityId
--   Left  Join [Bean].[DimChartOfAccount] as C on C.Id=JD.COAId
--   Left  Join Common.DimCompany SC ON SC.Id=JD.ServiceCompanyId


--Where C.CompanyId=@CompanyValue AND JD.DocType='Bill'
--      AND J.DocumentState IN ('Not Paid','Partial Paid') AND E.IsVendor=1
--      AND JD.DocDate Between @FromDate AND @ToDate 
--      AND SC.Id in (select items from dbo.SplitToTable(@ServiceCompanyId,',')) 

-- Group By SC.Name ,JD.DocDate,JD.ExchangeRate


      ) AS C

	  Group By CASE When C.PastDue <0 THEN   'Below 0' 
         When C.PastDue=0  Then  'Current'
         When C.PastDue>=1 AND C.PastDue<=30 Then  '1 - 30'
         When C.PastDue>=31 AND C.PastDue<=60 Then '31 - 60'
         When C.PastDue>=61 AND C.PastDue<=90 Then   '61 - 90'
        When C.PastDue>=91 Then  '>90'  END

) as dt1

END
GO
