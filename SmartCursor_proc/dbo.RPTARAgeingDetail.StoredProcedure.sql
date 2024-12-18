USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[RPTARAgeingDetail]    Script Date: 16-12-2024 9.20.11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE Procedure [dbo].[RPTARAgeingDetail]

   @FromDate  Varchar(50),                            
   @ToDate  Varchar(50) ,
   @CompanyValue Varchar(10),
   @Currency INT,
   @Payables Varchar(50),
   @ServiceCompanyId varchar(100) 
   
     
 AS

   Begin


  Declare @CompanyId Int    
 SET @ToDate = CONVERT(DATETIME, CONVERT(varchar(11),@ToDate, 103 ) + ' 23:59:59', 103)  
  select @CompanyId = dbo.DecryptCompanyValue(@CompanyValue) 


      --exec  [dbo].[RPTAPAgeingDetail] @CompanyValue=N'65',@FromDate='2017-01-01',@ToDate='2019-12-30',@Currency=N'0',@ServiceCompanyId=N'327'
      --exec  [dbo].[RPTARAgeingDetail] @CompanyValue=N'65',@FromDate='2017-01-01 00:00:00',@ToDate='2019-12-30 00:00:00',@Currency=N'0',@ServiceCompanyId=N'327'


IF @Currency=0

	  BEGIN
--IF @Payables=0
--BEGIN

with cte as


(


 Select E.Name AS 'EntityName',JD.SystemRefNo AS 'DocRefNo',
  Case when E.CustNature='Trade' then 'AR' When  E.CustNature='Others' then 'OR' end AS 'Payables'
,SC.ShortName AS Co,JD.DocDate,Case When JD.DocType='Journal' AND JD.DocSubType='General' Then JD.DocDate Else J.DueDate End  DueDate,JD.DocNo,DATEDIFF(d, Case When JD.DocType='Journal' AND JD.DocSubType='General' Then JD.DocDate Else J.DueDate End, getdate()) as OverDue,Jd.BaseCurrency Currency 
,DATEDIFF(d, Case When JD.DocType='Journal' AND JD.DocSubType='General' Then JD.DocDate Else J.DueDate End  , getdate()) as PastDue,
Case When JD.DocType='Journal' AND JD.DocSubType='General' AND SUM(IsNULL(JD.BaseCredit,0))>0 then  
Convert(money,Concat('-',SUM(ISNULL(JD.BaseCredit,0)))) Else  SUM(ISNULL(JD.BaseDebit,0)) End AS Total , --(JD.BaseCredit+(JD.BaseCredit*(JD.TaxRate/100))) as 'BalanceAmount' 
        Case When SUM(ISNULL(JD.AmountDue,0))>0 then (SUM(ISNULL(JD.AmountDue,0))*ISNULL(JD.ExchangeRate,0)) Else
		 Case When JD.DocType='Journal' AND JD.DocSubType='General' AND SUM(IsNULL(JD.BaseCredit,0))>0 then  
Convert(money,Concat('-',SUM(ISNULL(JD.BaseCredit,0)))) Else  SUM(ISNULL(JD.BaseDebit,0)) End END  AS BalanceAmount--ISNULL(SUM(JD.BaseCredit),0) AS BalanceAmount
	
	   
	    
FROM [Bean].[JournalDetail] JD 

   Inner Join [Bean].[Journal] J ON J.Id=JD.JournalId
   Left  Join [Bean].[Entity] as E On E.Id =JD.EntityId
   Left  Join [Bean].[ChartOfAccount] as C on C.Id=JD.COAId
   Left  Join Common.Company SC ON SC.Id=JD.ServiceCompanyId


Where JD.DocType IN ('Invoice','Credit Note','Journal') AND JD.DocSubType IN ('Invoice','CreditNote','General')  AND C.CompanyId=@CompanyValue
--AND JD.DocNo='Bill-001'
      AND J.DocumentState IN ('Not Paid','Partial Paid','Posted','Not Applied') AND E.IsCustomer=1 ---AND JD.SystemRefNo='REV-2018-00001-JV2'
    AND Case When JD.DocType='Journal' AND JD.DocSubType='General' Then JD.DocDate Else J.DueDate End   Between CONVERT(datetime, @FromDate, 103) AND CONVERT(datetime, @ToDate, 103)  AND
	  Case when E.CustNature='Trade' then 'AR' When  E.CustNature='Others' then 'OR'
 --When J.Nature IN ('Trade','Others') then 'Both'
  end  In (select items from dbo.SplitToTable(@Payables,','))
      AND SC.Id in (select items from dbo.SplitToTable(@ServiceCompanyId,',')) 

Group By E.Name,SC.ShortName,JD.SystemRefNo,E.CustNature,JD.DocType,JD.DocSubType,JD.BaseCurrency,JD.DocNo,JD.DocDate,J.DueDate,JD.ExchangeRate


)


 select C.EntityName,C.DocRefNo,C.Payables,C.DocNo,C.Co,C.DocDate,C.DueDate,Case When C.OverDue<0 then NULL Else OverDue End AS OverDue,C.Currency,C.Total,C.BalanceAmount,
        --CASE When C.PastDue <0 THEN  C.BalanceAmount END as 'Below 0' ,
        CASE When C.PastDue<=0  Then C.BalanceAmount  END as 'Current',
        CASE When C.PastDue>=1 AND C.PastDue<=30 Then C.BalanceAmount  END as '1 - 30',
        CASE When C.PastDue>=31 AND C.PastDue<=60 Then C.BalanceAmount END as '31 - 60',
        CASE When C.PastDue>=61 AND C.PastDue<=90 Then C.BalanceAmount END as '61 - 90',
        CASE When C.PastDue>=91 Then C.BalanceAmount END as '>90'  
	   
	   From cte as C


END

--Else IF @Payables=1
--BEGIN

--with cte as


--(


-- Select E.Name AS 'EntityName',JD.SystemRefNo AS 'DocRefNo' 
--,SC.ShortName AS Co,JD.DocDate,J.DueDate,JD.DocNo,DATEDIFF(d, JD.DocDate, getdate()) as OverDue,Jd.BaseCurrency Currency 
--,DATEDIFF(d, JD.DocDate, getdate()) as PastDue,ISNULL(SUM(JD.BaseCredit),0) AS Total, --(JD.BaseCredit+(JD.BaseCredit*(JD.TaxRate/100))) as 'BalanceAmount' 
--        Case When ISNULL(SUM(JD.AmountDue),0)>0 then (ISNULL(SUM(JD.AmountDue),0)*ISNULL(JD.ExchangeRate,0)) Else ISNULL(SUM(JD.BaseCredit),0) END  AS BalanceAmount--ISNULL(SUM(JD.BaseCredit),0) AS BalanceAmount
	   
	    
--FROM [Bean].[FactJournalDetail] JD 

--   Inner Join [Bean].[FactJournal] J ON J.Id=JD.JournalId
--   Left  Join [Bean].[DimEntity] as E On E.Id =JD.EntityId
--   Left  Join [Bean].[DimChartOfAccount] as C on C.Id=JD.COAId
--   Left  Join Common.DimCompany SC ON SC.Id=JD.ServiceCompanyId


--Where JD.DocType='Bill' AND C.CompanyId=@CompanyValue  --AND JD.DocNo='Bill-001'
--      AND J.DocumentState IN ('Not Paid','Partial Paid') AND E.IsVendor=1 AND J.Nature='Others'
--      AND JD.DocDate Between CONVERT(datetime, @FromDate, 103) AND CONVERT(datetime, @ToDate, 103) 
--	  AND J.Nature In (select items from dbo.SplitToTable(@Payables,','))
--      AND SC.Id in (select items from dbo.SplitToTable(@ServiceCompanyId,',')) 

--Group By E.Name,SC.ShortName,JD.SystemRefNo,JD.BaseCurrency,JD.DocNo,JD.DocDate,J.DueDate,JD.ExchangeRate


--)


-- select C.EntityName,C.DocRefNo,C.DocNo,C.Co,C.DocDate,C.DueDate,C.OverDue,C.Currency,C.Total,C.BalanceAmount,
--        --CASE When C.PastDue <0 THEN  C.BalanceAmount END as 'Below 0' ,
--        CASE When C.PastDue=0  Then C.BalanceAmount  END as 'Current',
--        CASE When C.PastDue>=1 AND C.PastDue<=30 Then C.BalanceAmount  END as '1 - 30',
--        CASE When C.PastDue>=31 AND C.PastDue<=60 Then C.BalanceAmount END as '31 - 60',
--        CASE When C.PastDue>=61 AND C.PastDue<=90 Then C.BalanceAmount END as '61 - 90',
--        CASE When C.PastDue>=91 Then C.BalanceAmount END as '>90'  
	   
--	   From cte as C


--END

--Else IF @Payables=2
--BEGIN

--with cte as


--(


-- Select E.Name AS 'EntityName',JD.SystemRefNo AS 'DocRefNo' 
--,SC.ShortName AS Co,JD.DocDate,J.DueDate,JD.DocNo,DATEDIFF(d, JD.DocDate, getdate()) as OverDue,Jd.BaseCurrency Currency 
--,DATEDIFF(d, JD.DocDate, getdate()) as PastDue,ISNULL(SUM(JD.BaseCredit),0) AS Total, --(JD.BaseCredit+(JD.BaseCredit*(JD.TaxRate/100))) as 'BalanceAmount' 
--        Case When ISNULL(SUM(JD.AmountDue),0)>0 then (ISNULL(SUM(JD.AmountDue),0)*ISNULL(JD.ExchangeRate,0)) Else ISNULL(SUM(JD.BaseCredit),0) END  AS BalanceAmount--ISNULL(SUM(JD.BaseCredit),0) AS BalanceAmount
	   
	    
--FROM [Bean].[FactJournalDetail] JD 

--   Inner Join [Bean].[FactJournal] J ON J.Id=JD.JournalId
--   Left  Join [Bean].[DimEntity] as E On E.Id =JD.EntityId
--   Left  Join [Bean].[DimChartOfAccount] as C on C.Id=JD.COAId
--   Left  Join Common.DimCompany SC ON SC.Id=JD.ServiceCompanyId


--Where JD.DocType='Bill' AND C.CompanyId=@CompanyValue  --AND JD.DocNo='Bill-001'
--      AND J.DocumentState IN ('Not Paid','Partial Paid') AND E.IsVendor=1 AND J.Nature IN ('Trade','Others')
--      AND JD.DocDate Between CONVERT(datetime, @FromDate, 103) AND CONVERT(datetime, @ToDate, 103) 
--	  AND J.Nature  In (select items from dbo.SplitToTable(@Payables,','))
--      AND SC.Id in (select items from dbo.SplitToTable(@ServiceCompanyId,',')) 

--Group By E.Name,SC.ShortName,JD.SystemRefNo,JD.BaseCurrency,JD.DocNo,JD.DocDate,J.DueDate,JD.ExchangeRate


--)


-- select C.EntityName,C.DocRefNo,C.DocNo,C.Co,C.DocDate,C.DueDate,C.OverDue,C.Currency,C.Total,C.BalanceAmount,
--        --CASE When C.PastDue <0 THEN  C.BalanceAmount END as 'Below 0' ,
--        CASE When C.PastDue=0  Then C.BalanceAmount  END as 'Current',
--        CASE When C.PastDue>=1 AND C.PastDue<=30 Then C.BalanceAmount  END as '1 - 30',
--        CASE When C.PastDue>=31 AND C.PastDue<=60 Then C.BalanceAmount END as '31 - 60',
--        CASE When C.PastDue>=61 AND C.PastDue<=90 Then C.BalanceAmount END as '61 - 90',
--        CASE When C.PastDue>=91 Then C.BalanceAmount END as '>90'  
	   
--	   From cte as C


--END
--END

Else
IF @Currency=1

	  BEGIN
--IF @Payables=0
--BEGIN


with cte as


(


 Select E.Name AS 'EntityName',JD.SystemRefNo AS 'DocRefNo',
 Case when E.CustNature='Trade' then 'AR' When  E.CustNature='Others' then 'OR'end AS 'Payables'
,SC.ShortName AS Co,JD.DocDate,Case When JD.DocType='Journal' AND JD.DocSubType='General' Then JD.DocDate Else J.DueDate End  DueDate,JD.DocNo,DATEDIFF(d, Case When JD.DocType='Journal' AND JD.DocSubType='General' Then JD.DocDate Else J.DueDate End  , getdate()) as OverDue,Jd.DocCurrency Currency 
,DATEDIFF(d, Case When JD.DocType='Journal' AND JD.DocSubType='General' Then JD.DocDate Else J.DueDate End , getdate()) as PastDue,
Case When JD.DocType='Journal' AND JD.DocSubType='General' AND SUM(IsNULL(JD.DocCredit,0))>0 then  
Convert(money,Concat('-',SUM(ISNULL(JD.DocCredit,0)))) Else  SUM(ISNULL(JD.DocDebit,0)) End AS Total , --(JD.BaseCredit+(JD.BaseCredit*(JD.TaxRate/100))) as 'BalanceAmount' 
        Case When SUM(ISNULL(JD.AmountDue,0))>0 then SUM(ISNULL(JD.AmountDue,0))
		--*ISNULL(JD.ExchangeRate,0)) 
		Else
		 Case When JD.DocType='Journal' AND JD.DocSubType='General' AND SUM(IsNULL(JD.DocCredit,0))>0 then  
Convert(money,Concat('-',SUM(ISNULL(JD.DocCredit,0)))) Else  SUM(ISNULL(JD.DocDebit,0)) End END  AS BalanceAmount--ISNULL(SUM(JD.BaseCredit),0) AS BalanceAmount
	
	   
	    
FROM [Bean].[JournalDetail] JD 

   Inner Join [Bean].[Journal] J ON J.Id=JD.JournalId
   Left  Join [Bean].[Entity] as E On E.Id =JD.EntityId
   Left  Join [Bean].[ChartOfAccount] as C on C.Id=JD.COAId
   Left  Join Common.Company SC ON SC.Id=JD.ServiceCompanyId


Where JD.DocType IN ('Invoice','Credit Note','Journal') AND JD.DocSubType IN ('Invoice','CreditNote','General')  AND C.CompanyId=@CompanyValue  --AND JD.DocNo='Bill-001'
      AND J.DocumentState IN ('Not Paid','Partial Paid','Posted','Not Applied') AND E.IsCustomer=1 ---AND JD.SystemRefNo='REV-2018-00001-JV2'
    AND Case When JD.DocType='Journal' AND JD.DocSubType='General' Then JD.DocDate Else J.DueDate End   Between CONVERT(datetime, @FromDate, 103) AND CONVERT(datetime, @ToDate, 103) 
	  AND Case when E.CustNature='Trade' then 'AR' When  E.CustNature='Others' then 'OR'
 --When J.Nature IN ('Trade','Others') then 'Both'
  end  In (select items from dbo.SplitToTable(@Payables,','))
      AND SC.Id in (select items from dbo.SplitToTable(@ServiceCompanyId,',')) 

Group By E.Name,SC.ShortName,JD.SystemRefNo,E.CustNature,JD.DocType,JD.DocSubType,JD.DocCurrency,JD.DocNo,JD.DocDate,J.DueDate,JD.ExchangeRate


)


 select C.EntityName,C.DocRefNo,C.Payables,C.DocNo,C.Co,C.DocDate,C.DueDate,Case When C.OverDue<0 then NULL Else OverDue End AS OverDue,C.Currency,C.Total,C.BalanceAmount,
        --CASE When C.PastDue <0 THEN  C.BalanceAmount END as 'Below 0' ,
        CASE When C.PastDue<=0  Then C.BalanceAmount  END as 'Current',
        CASE When C.PastDue>=1 AND C.PastDue<=30 Then C.BalanceAmount  END as '1 - 30',
        CASE When C.PastDue>=31 AND C.PastDue<=60 Then C.BalanceAmount END as '31 - 60',
        CASE When C.PastDue>=61 AND C.PastDue<=90 Then C.BalanceAmount END as '61 - 90',
        CASE When C.PastDue>=91 Then C.BalanceAmount END as '>90'  
	   
	   From cte as C


END
Else
IF @Currency=2

	  BEGIN
--IF @Payables=0
--BEGIN


with cte as


(


 Select E.Name AS 'EntityName',JD.SystemRefNo AS 'DocRefNo',
Case when E.CustNature='Trade' then 'AR' When  E.CustNature='Others' then 'OR' end AS 'Payables'
,SC.ShortName AS Co,JD.DocDate,JD.DocDate DueDate,JD.DocNo,DATEDIFF(d, JD.DocDate, getdate()) as OverDue,Jd.DocCurrency Currency 
,DATEDIFF(d, JD.DocDate, getdate()) as PastDue,
 SUM(ISNULL(JD.DocCredit,0))  AS Total , --(JD.BaseCredit+(JD.BaseCredit*(JD.TaxRate/100))) as 'BalanceAmount' 
        Case When SUM(ISNULL(JD.AmountDue,0))>0 then (SUM(ISNULL(JD.AmountDue,0))*ISNULL(JD.ExchangeRate,0)) Else
  SUM(ISNULL(JD.DocCredit,0)) END  AS BalanceAmount--ISNULL(SUM(JD.BaseCredit),0) AS BalanceAmount
	
	   
	    
FROM [Bean].[JournalDetail] JD 

   Inner Join [Bean].[Journal] J ON J.Id=JD.JournalId
   Left  Join [Bean].[Entity] as E On E.Id =JD.EntityId
   Left  Join [Bean].[ChartOfAccount] as C on C.Id=JD.COAId
   Left  Join Common.Company SC ON SC.Id=JD.ServiceCompanyId


Where JD.DocType IN ('Journal') AND JD.DocSubType IN ('Revaluation')  AND C.CompanyId=@CompanyValue  --AND JD.DocNo='Bill-001'
      AND J.DocumentState IN ('Not Paid','Partial Paid','Posted') AND E.IsCustomer=1 ---AND JD.SystemRefNo='REV-2018-00001-JV2'
    AND JD.DocDate=CONVERT(datetime, @ToDate, 103) --Between CONVERT(datetime, @FromDate, 103) AND CONVERT(datetime, @ToDate, 103) 
	  AND Case when E.CustNature='Trade' then 'AR' When  E.CustNature='Others' then 'OR'
 --When J.Nature IN ('Trade','Others') then 'Both'
  end  In (select items from dbo.SplitToTable(@Payables,','))
      AND SC.Id in (select items from dbo.SplitToTable(@ServiceCompanyId,',')) 

Group By E.Name,SC.ShortName,JD.SystemRefNo,E.CustNature,JD.DocType,JD.DocSubType,JD.DocCurrency,JD.DocNo,JD.DocDate,J.DueDate,JD.ExchangeRate


)


 select C.EntityName,C.DocRefNo,C.Payables,C.DocNo,C.Co,C.DocDate,C.DueDate,Case When C.OverDue<0 then NULL Else OverDue End AS OverDue,C.Currency,C.Total,C.BalanceAmount,
        --CASE When C.PastDue <0 THEN  C.BalanceAmount END as 'Below 0' ,
        CASE When C.PastDue=0  Then C.BalanceAmount  END as 'Current',
        CASE When C.PastDue>=1 AND C.PastDue<=30 Then C.BalanceAmount  END as '1 - 30',
        CASE When C.PastDue>=31 AND C.PastDue<=60 Then C.BalanceAmount END as '31 - 60',
        CASE When C.PastDue>=61 AND C.PastDue<=90 Then C.BalanceAmount END as '61 - 90',
        CASE When C.PastDue>=91 Then C.BalanceAmount END as '>90'  
	   
	   From cte as C


END
--ELSE IF @Payables=1
--BEGIN


--with cte as


--(


-- Select E.Name AS 'EntityName',JD.SystemRefNo AS 'DocRefNo' 
--,JD.DocNo,SC.ShortName AS Co,JD.DocDate,J.DueDate,DATEDIFF(d, JD.DocDate, getdate()) as OverDue,Jd.DocCurrency Currency,
--DATEDIFF(d, JD.DocDate, getdate()) as PastDue,ISNULL(SUM(JD.DocCredit),0) Total, --(JD.BaseCredit+(JD.BaseCredit*(JD.TaxRate/100))) as 'BalanceAmount' 
--        Case When ISNULL(SUM(JD.AmountDue),0)>0 then ISNULL(SUM(JD.AmountDue),0) Else ISNULL(SUM(JD.DocCredit),0) END  AS BalanceAmount--ISNULL(SUM(JD.BaseCredit),0) AS BalanceAmount
	   
	    
--FROM [Bean].[FactJournalDetail] JD 

--   Inner Join [Bean].[FactJournal] J ON J.Id=JD.JournalId
--   Left  Join [Bean].[DimEntity] as E On E.Id =JD.EntityId
--   Left  Join [Bean].[DimChartOfAccount] as C on C.Id=JD.COAId
--   Left  Join Common.DimCompany SC ON SC.Id=JD.ServiceCompanyId


--Where JD.DocType='Bill' AND C.CompanyId=@CompanyValue  --AND JD.DocNo='Bill-001'
--      AND J.DocumentState IN ('Not Paid','Partial Paid') AND E.IsVendor=1 AND J.Nature='Others'
--      AND JD.DocDate Between CONVERT(datetime, @FromDate, 103) AND CONVERT(datetime, @ToDate, 103) 
--	   AND J.Nature In (select items from dbo.SplitToTable(@Payables,','))
--      AND SC.Id in (select items from dbo.SplitToTable(@ServiceCompanyId,',')) 

--Group By  E.Name,SC.ShortName,JD.SystemRefNo,JD.DocNo,JD.DocCurrency,JD.DocDate,J.DueDate,JD.ExchangeRate


--)


-- select C.EntityName,C.DocRefNo,C.DocNo,C.Co,C.DocDate,C.DueDate,C.OverDue,C.Currency,C.Total,C.BalanceAmount,
--        --CASE When C.PastDue <0 THEN  C.BalanceAmount END as 'Below 0' ,
--        CASE When C.PastDue=0  Then C.BalanceAmount  END as 'Current',
--        CASE When C.PastDue>=1 AND C.PastDue<=30 Then C.BalanceAmount  END as '1 - 30',
--        CASE When C.PastDue>=31 AND C.PastDue<=60 Then C.BalanceAmount END as '31 - 60',
--        CASE When C.PastDue>=61 AND C.PastDue<=90 Then C.BalanceAmount END as '61 - 90',
--        CASE When C.PastDue>=91 Then C.BalanceAmount END as '>90'  
	   
--	   From cte as C


--END

--ELSE IF @Payables=2
--BEGIN


--with cte as


--(


-- Select E.Name AS 'EntityName',JD.SystemRefNo AS 'DocRefNo' 
--,JD.DocNo,SC.ShortName AS Co,JD.DocDate,J.DueDate,DATEDIFF(d, JD.DocDate, getdate()) as OverDue,Jd.DocCurrency Currency,
--DATEDIFF(d, JD.DocDate, getdate()) as PastDue,ISNULL(SUM(JD.DocCredit),0) Total, --(JD.BaseCredit+(JD.BaseCredit*(JD.TaxRate/100))) as 'BalanceAmount' 
--        Case When ISNULL(SUM(JD.AmountDue),0)>0 then ISNULL(SUM(JD.AmountDue),0) Else ISNULL(SUM(JD.DocCredit),0) END  AS BalanceAmount--ISNULL(SUM(JD.BaseCredit),0) AS BalanceAmount
	   
	    
--FROM [Bean].[FactJournalDetail] JD 

--   Inner Join [Bean].[FactJournal] J ON J.Id=JD.JournalId
--   Left  Join [Bean].[DimEntity] as E On E.Id =JD.EntityId
--   Left  Join [Bean].[DimChartOfAccount] as C on C.Id=JD.COAId
--   Left  Join Common.DimCompany SC ON SC.Id=JD.ServiceCompanyId


--Where JD.DocType='Bill' AND C.CompanyId=@CompanyValue  --AND JD.DocNo='Bill-001'
--      AND J.DocumentState IN ('Not Paid','Partial Paid') AND E.IsVendor=1 AND J.Nature IN ('Trade','Others')
--      AND JD.DocDate Between CONVERT(datetime, @FromDate, 103) AND CONVERT(datetime, @ToDate, 103) 
--	   AND  J.Nature In (select items from dbo.SplitToTable(@Payables,','))
--      AND SC.Id in (select items from dbo.SplitToTable(@ServiceCompanyId,',')) 

--Group By  E.Name,SC.ShortName,JD.SystemRefNo,JD.DocNo,JD.DocCurrency,JD.DocDate,J.DueDate,JD.ExchangeRate


--)


-- select C.EntityName,C.DocRefNo,C.DocNo,C.Co,C.DocDate,C.DueDate,C.OverDue,C.Currency,C.Total,C.BalanceAmount,
--        --CASE When C.PastDue <0 THEN  C.BalanceAmount END as 'Below 0' ,
--        CASE When C.PastDue=0  Then C.BalanceAmount  END as 'Current',
--        CASE When C.PastDue>=1 AND C.PastDue<=30 Then C.BalanceAmount  END as '1 - 30',
--        CASE When C.PastDue>=31 AND C.PastDue<=60 Then C.BalanceAmount END as '31 - 60',
--        CASE When C.PastDue>=61 AND C.PastDue<=90 Then C.BalanceAmount END as '61 - 90',
--        CASE When C.PastDue>=91 Then C.BalanceAmount END as '>90'  
	   
--	   From cte as C


--END

  -- END

   END

GO
