USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[RPTARAgeingDetailTestForBase]    Script Date: 16-12-2024 9.20.11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE Procedure [dbo].[RPTARAgeingDetailTestForBase]

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
	  --exec RPTARAgeingDetail @FromDate=N'01-01-1900',@ToDate=N'03-06-2018',
	  --@CompanyValue=N'1201',@Currency=1,@Payables=N'AR,OR',@ServiceCompanyId=N'1202'


IF @Currency=0--Base

	  BEGIN
--IF @Payables=0
--BEGIN

with cte as


(
Select E.Name AS 'EntityName',JD.SystemRefNo AS 'DocRefNo',
 Case when J.Nature='Trade' then 'AR' When  J.Nature='Others' then 'OR'end AS 'Payables'
,SC.ShortName AS Co,JD.DocDate,Case When JD.DocType IN ('Credit Note') AND JD.DocSubType IN ('Credit Note') Then JD.DocDate Else J.DueDate End  DueDate,JD.DocNo,DATEDIFF(d, Case When JD.DocType IN ('Credit Note') AND JD.DocSubType IN ('Credit Note') Then JD.DocDate Else J.DueDate End , @ToDate) as OverDue,Jd.DocCurrency 'Doc Curr',Case When JD.DocType IN ('Credit Note') AND JD.DocSubType IN ('Credit Note') AND SUM(IsNULL(JD.DocCredit,0))>0 then  
Convert(money,Concat('-',SUM(ISNULL(JD.DocCredit,0)))) Else  SUM(ISNULL(JD.DocDebit,0)) End AS DocTotal ,        
Case When SUM(ISNULL(J.BalanceAmount,0))>0 then SUM(ISNULL(J.BalanceAmount,0))
		--*ISNULL(JD.ExchangeRate,0)) 
		Else
		 Case When JD.DocType IN ('Credit Note') AND JD.DocSubType IN ('Credit Note') AND SUM(IsNULL(JD.DocCredit,0))>0 then  
Convert(money,Concat('-',SUM(ISNULL(JD.DocCredit,0)))) Else  SUM(ISNULL(JD.DocDebit,0)) End END  AS DocBalanceAmount ,Jd.BaseCurrency Currency 
,DATEDIFF(d, Case When JD.DocType IN ('Credit Note') AND JD.DocSubType IN ('Credit Note') Then JD.DocDate Else J.DueDate End , @ToDate) as PastDue,

Case When JD.DocType IN ('Credit Note') AND JD.DocSubType IN ('Credit Note') AND SUM(IsNULL(JD.BaseCredit,0))>0 then  
Convert(money,Concat('-',SUM(ISNULL(JD.BaseCredit,0)))) Else  SUM(ISNULL(JD.BaseDebit,0)) End AS Total , --(JD.BaseCredit+(JD.BaseCredit*(JD.TaxRate/100))) as 'BalanceAmount' 
        Case When SUM(ISNULL(J.BalanceAmount,0))>0 then (SUM(ISNULL(J.BalanceAmount,0))
		*ISNULL(JD.ExchangeRate,0)) 
		Else
		 Case When JD.DocType IN ('Credit Note') AND JD.DocSubType IN ('Credit Note') AND SUM(IsNULL(JD.BaseCredit,0))>0 then  
Convert(money,Concat('-',SUM(ISNULL(JD.BaseCredit,0)))) Else  SUM(ISNULL(JD.BaseDebit,0)) End END  AS BalanceAmount--ISNULL(SUM(JD.BaseCredit),0) AS BalanceAmount
	
	   
	    
FROM [Bean].[JournalDetail] JD 

   Inner Join [Bean].[Journal] J ON J.Id=JD.JournalId
   Left  Join [Bean].[Entity] as E On E.Id =JD.EntityId
   Left  Join [Bean].[ChartOfAccount] as C on C.Id=JD.COAId
   Left  Join Common.Company SC ON SC.Id=J.ServiceCompanyId


Where JD.DocType IN ('Invoice','Credit Note','Debit Note') AND JD.DocSubType IN ('Invoice','General','Recurring','Credit Note','Debit Note')  AND C.CompanyId=@CompanyValue  --AND JD.DocNo='Bill-001'
      AND J.DocumentState IN ('Not Paid','Partial Paid','Posted','Not Applied','Partial Applied') AND E.IsCustomer=1 ---AND JD.SystemRefNo='REV-2018-00001-JV2'
	   AND JD.DocumentDetailId='00000000-0000-0000-0000-000000000000'
	    AND (JD.ClearingStatus <> ('Cleared') or JD.ClearingStatus IS NULL)
	    AND
	      JD.PostingDate-->= @Todate then @Todate /*else J.DueDate */ End  
	  Between CONVERT(datetime, @FromDate, 103) AND CONVERT(datetime, @ToDate, 103) 
	--case when J.DueDate>= @Todate then @Todate else J.DueDate  End   Between CONVERT(datetime, @FromDate, 103) AND CONVERT(datetime, @ToDate, 103) 
    --AND Case When JD.DocType='Journal' AND JD.DocSubType='General' Then JD.DocDate Else J.DueDate End   Between CONVERT(datetime, @FromDate, 103) AND CONVERT(datetime, @ToDate, 103) 
	  AND Case when J.Nature='Trade' then 'AR' When  J.Nature='Others' then 'OR'
 --When J.Nature IN ('Trade','Others') then 'Both'
  end  In (select items from dbo.SplitToTable(@Payables,','))
      AND SC.Name in (select items from dbo.SplitToTable(@ServiceCompanyId,',')) 

Group By E.Name,SC.ShortName,JD.SystemRefNo,J.Nature,JD.DocType,JD.DocSubType,JD.DocCurrency,JD.BaseCurrency,JD.DocNo,JD.DocDate,J.DueDate,JD.ExchangeRate

Union All


	  Select E.Name AS 'EntityName',JD.SystemRefNo AS 'DocRefNo', 
	  --Case when E.VenNature='Trade' then 'AP' When  E.VenNature='Others' then 'OP'end AS 
	  Case When C.Name='Accounts Receivables' then 'AR' When C.Name='Other receivables' then 'OR' END AS
	  'Payables',SC.ShortName AS Co,JD.DocDate, JD.DocDate  AS DueDate,JD.DocNo,DATEDIFF(d, JD.DocDate,@ToDate --getdate()
	  ) as OverDue,JD.DocCurrency AS 'Doc Curr',Case When  SUM(IsNULL(JD.DocCredit,0))>0 then  
Convert(money,Concat('-',SUM(ISNULL(JD.DocCredit,0)))) Else  SUM(ISNULL(JD.DocDebit,0)) End AS DocTotal,Case When  SUM(IsNULL(JD.DocCredit,0))>0 then  
SUM(ISNULL(JD.DocCredit,0)) Else  SUM(ISNULL(JD.DocDebit,0)) End   AS DocBalanceAmount,Jd.BaseCurrency Currency 
	  ,DATEDIFF(d, JD.DocDate , @ToDate) as PastDue,Case When  SUM(IsNULL(JD.BaseCredit,0))>0 then  
Convert(money,Concat('-',SUM(ISNULL(JD.BaseCredit,0)))) Else  SUM(ISNULL(JD.BaseDebit,0)) End AS Total,
Case When  SUM(IsNULL(JD.BaseCredit,0))>0 then  
SUM(ISNULL(JD.BaseCredit,0)) Else  SUM(ISNULL(JD.BaseDebit,0)) End   AS BalanceAmount

	  from Bean.JournalDetail JD
	  Inner Join [Bean].[Journal] J ON J.Id=JD.JournalId
	  Left  Join [Bean].[Entity] as E On E.Id =JD.EntityId
	  Left  Join [Bean].[ChartOfAccount] as C on C.Id=JD.COAId
      Left  Join Common.Company SC ON SC.Id=J.ServiceCompanyId
	  Where --JD.SystemRefNo='JV-2018-00002' AND 
	  E.IsCustomer=1 AND J.CompanyId=@CompanyValue AND JD.DocType='Receipt' AND JD.DocSubType='Customer'
	  AND J.DocumentState='Created' 
	   AND (JD.ClearingStatus <> ('Cleared') or JD.ClearingStatus IS NULL)
	  AND 
	  --Case when E.VenNature='Trade' then 'AP' When  E.VenNature='Others' then 'OP'end 
	  Case When C.Name='Accounts Receivables' then 'AR' When C.Name='Other receivables' then 'OR' END
	   In (select items from dbo.SplitToTable(@Payables,','))
	   AND  Jd.PostingDate-->= @Todate then @Todate /*else J.DueDate */ End  
	  Between CONVERT(datetime, @FromDate, 103) AND CONVERT(datetime, @ToDate, 103) 


	AND SC.Name in (select items from dbo.SplitToTable(@ServiceCompanyId,','))
	  Group By E.Name,JD.SystemRefNo,C.Name,/*E.VenNature*/SC.ShortName,JD.DocDate,JD.DocNo,Jd.DocCurrency,JD.BaseCurrency

Union All

--------------Doubtful Debt------------------

	  Select E.Name AS 'EntityName',JD.SystemRefNo AS 'DocRefNo', 
	  --Case when E.VenNature='Trade' then 'AP' When  E.VenNature='Others' then 'OP'end AS 
	  Case When C.Name='Doubtful Debt Provision(AR)' then 'AR' When C.Name='Doubtful Debt Provision(OR)' then 'OR' END AS
	  'Payables',SC.ShortName AS Co,JD.DocDate, JD.DocDate  AS DueDate,JD.DocNo,DATEDIFF(d, JD.DocDate,@ToDate --getdate()
	  ) as OverDue,JD.DocCurrency AS 'Doc Curr',
	  --Convert(money,Concat('-',SUM(ISNULL(JD.DocCredit,0)))) AS DocTotal,SUM(ISNULL(JD.DocCredit,0)) AS DocBalanceAmount,
	  Case When  SUM(IsNULL(JD.DocCredit,0))>0 then  
Convert(money,Concat('-',SUM(ISNULL(JD.DocCredit,0)))) Else  SUM(ISNULL(JD.DocDebit,0)) End AS DocTotal,
Case When  SUM(IsNULL(JD.DocCredit,0))>0 then  
SUM(ISNULL(JD.DocCredit,0)) Else  SUM(ISNULL(JD.DocDebit,0)) End   AS DocBalanceAmount,
Jd.BaseCurrency Currency 
	  ,DATEDIFF(d, JD.DocDate , @ToDate) as PastDue,
	  
	  Case When  SUM(IsNULL(Case when JD.BaseCurrency=JD.DocCurrency and JD.BaseCredit is null then JD.DocCredit else JD.BaseCredit end,0))>0 then  
Convert(money,Concat('-',SUM(ISNULL(Case when JD.BaseCurrency=JD.DocCurrency and JD.BaseCredit is null then JD.DocCredit else JD.BaseCredit end,0)))) Else  SUM(ISNULL(case when JD.BaseCurrency=JD.DocCurrency and JD.BaseDebit is null then JD.DocDebit else JD.BaseDebit end,0)) End AS Total,


Case When  SUM(IsNULL(Case when JD.BaseCurrency=JD.DocCurrency and JD.BaseCredit is null then JD.DocCredit else JD.BaseCredit end,0))>0 then  
SUM(ISNULL(Case when JD.BaseCurrency=JD.DocCurrency and JD.BaseCredit is null then JD.DocCredit else JD.BaseCredit end,0)) Else  SUM(ISNULL(case when JD.BaseCurrency=JD.DocCurrency and JD.BaseDebit is null then JD.DocDebit else JD.BaseDebit end,0)) End   AS BalanceAmount

	  from Bean.JournalDetail JD
	  Inner Join [Bean].[Journal] J ON J.Id=JD.JournalId
	  Left  Join [Bean].[Entity] as E On E.Id =JD.EntityId
	  Left  Join [Bean].[ChartOfAccount] as C on C.Id=JD.COAId
      Left  Join Common.Company SC ON SC.Id=J.ServiceCompanyId
	  Where --JD.SystemRefNo='JV-2018-00002' AND 
	  E.IsCustomer=1 AND 
	  J.CompanyId=@CompanyValue AND JD.DocType='Doubtful Debt' 
	  --AND JD.DocSubType='General'
	  AND J.DocumentState NOT IN ('Void') 
	  AND Case When C.Name='Doubtful Debt Provision(AR)' then 'AR' When C.Name='Doubtful Debt Provision(OR)' then 'OR' END
	   In (select items from dbo.SplitToTable(@Payables,','))
	   AND  Jd.PostingDate 
	  Between CONVERT(datetime, @FromDate, 103) AND CONVERT(datetime, @ToDate, 103) 


	AND SC.Name in (select items from dbo.SplitToTable(@ServiceCompanyId,','))
	  Group By E.Name,JD.SystemRefNo,C.Name,SC.ShortName,JD.DocDate,JD.DocNo,Jd.DocCurrency,JD.BaseCurrency



	  UNION ALL





	  Select E.Name AS 'EntityName',JD.SystemRefNo AS 'DocRefNo', 
	  --Case when E.VenNature='Trade' then 'AP' When  E.VenNature='Others' then 'OP'end AS 
	  Case When C.Name='Accounts Receivables' then 'AR' When C.Name='Other receivables' then 'OR' END AS
	  'Payables',SC.ShortName AS Co,JD.DocDate, JD.DocDate  AS DueDate,JD.DocNo,DATEDIFF(d, JD.DocDate,@ToDate --getdate()
	  ) as OverDue,JD.DocCurrency AS 'Doc Curr',Case When  SUM(IsNULL(JD.DocCredit,0))>0 then  
Convert(money,Concat('-',SUM(ISNULL(JD.DocCredit,0)))) Else  SUM(ISNULL(JD.DocDebit,0)) End AS DocTotal,Case When  SUM(IsNULL(JD.DocCredit,0))>0 then  
SUM(ISNULL(JD.DocCredit,0)) Else  SUM(ISNULL(JD.DocDebit,0)) End   AS DocBalanceAmount,Jd.BaseCurrency Currency 
	  ,DATEDIFF(d, JD.DocDate , @ToDate) as PastDue,
	  
	  Case When  SUM(IsNULL(Case when JD.BaseCurrency=JD.DocCurrency and JD.BaseCredit is null then JD.DocCredit else JD.BaseCredit end,0))>0 then  
Convert(money,Concat('-',SUM(ISNULL(Case when JD.BaseCurrency=JD.DocCurrency and JD.BaseCredit is null then JD.DocCredit else JD.BaseCredit end,0)))) Else  SUM(ISNULL(case when JD.BaseCurrency=JD.DocCurrency and JD.BaseDebit is null then JD.DocDebit else JD.BaseDebit end,0)) End AS Total,


Case When  SUM(IsNULL(Case when JD.BaseCurrency=JD.DocCurrency and JD.BaseCredit is null then JD.DocCredit else JD.BaseCredit end,0))>0 then  
SUM(ISNULL(Case when JD.BaseCurrency=JD.DocCurrency and JD.BaseCredit is null then JD.DocCredit else JD.BaseCredit end,0)) Else  SUM(ISNULL(case when JD.BaseCurrency=JD.DocCurrency and JD.BaseDebit is null then JD.DocDebit else JD.BaseDebit end,0)) End   AS BalanceAmount

	  from Bean.JournalDetail JD
	  Inner Join [Bean].[Journal] J ON J.Id=JD.JournalId
	  Left  Join [Bean].[Entity] as E On E.Id =JD.EntityId
	  Left  Join [Bean].[ChartOfAccount] as C on C.Id=JD.COAId
      Left  Join Common.Company SC ON SC.Id=J.ServiceCompanyId
	  Where 
	  E.IsCustomer=1 AND J.CompanyId=@CompanyValue AND JD.DocType='Journal' AND JD.DocSubType='General'
	  AND J.DocumentState IN ('Posted','Reversed') 
	   AND (JD.ClearingStatus <> ('Cleared') or JD.ClearingStatus IS NULL)
	  AND 
	  Case When C.Name='Accounts Receivables' then 'AR' When C.Name='Other receivables' then 'OR' END
	   In (select items from dbo.SplitToTable(@Payables,','))
	   AND  Jd.PostingDate
	  Between CONVERT(datetime, @FromDate, 103) AND CONVERT(datetime, @ToDate, 103) 


	AND SC.Name in (select items from dbo.SplitToTable(@ServiceCompanyId,','))
	  Group By E.Name,JD.SystemRefNo,C.Name,SC.ShortName,JD.DocDate,JD.DocNo,Jd.DocCurrency,JD.BaseCurrency

Union All


	  Select E.Name AS 'EntityName',J.ActualSysRefNo AS 'DocRefNo',--JD.SystemRefNo AS 'DocRefNo', 
	  --Case when E.VenNature='Trade' then 'AP' When  E.VenNature='Others' then 'OP'end AS 
	  Case When C.Name='Accounts Receivables' then 'AR' When C.Name='Other receivables' then 'OR' END AS
	  'Payables',SC.ShortName AS Co,JD.DocDate, JD.DocDate  AS DueDate,JD.SystemRefNo AS DocNo,--JD.DocNo,
	  DATEDIFF(d, JD.DocDate,@ToDate --getdate()
	  ) as OverDue,JD.DocCurrency AS 'Doc Curr',Case When  SUM(IsNULL(JD.DocCredit,0))>0 then  
Convert(money,Concat('-',SUM(ISNULL(JD.DocCredit,0)))) Else  SUM(ISNULL(JD.DocDebit,0)) End AS DocTotal,
Case When  SUM(IsNULL(JD.DocCredit,0))>0 then  
SUM(ISNULL(JD.DocCredit,0)) Else  SUM(ISNULL(JD.DocDebit,0)) End   AS DocBalanceAmount,Jd.BaseCurrency Currency 

	  ,DATEDIFF(d, JD.DocDate , @ToDate) as PastDue,
	  
	  Case When  SUM(IsNULL(Case when JD.BaseCurrency=JD.DocCurrency and JD.BaseCredit is null then JD.DocCredit else JD.BaseCredit end,0))>0 then  
Convert(money,Concat('-',SUM(ISNULL(Case when JD.BaseCurrency=JD.DocCurrency and JD.BaseCredit is null then JD.DocCredit else JD.BaseCredit end,0)))) Else  SUM(ISNULL(case when JD.BaseCurrency=JD.DocCurrency and JD.BaseDebit is null then JD.DocDebit else JD.BaseDebit end,0)) End AS Total,

Case When  SUM(IsNULL(Case when JD.BaseCurrency=JD.DocCurrency and JD.BaseCredit is null then JD.DocCredit else JD.BaseCredit end,0))>0 then  
SUM(ISNULL(Case when JD.BaseCurrency=JD.DocCurrency and JD.BaseCredit is null then JD.DocCredit else JD.BaseCredit end,0)) Else  SUM(ISNULL(case when JD.BaseCurrency=JD.DocCurrency and JD.BaseDebit is null then JD.DocDebit else JD.BaseDebit end,0)) End   AS BalanceAmount

	  from Bean.JournalDetail JD
	  Inner Join [Bean].[Journal] J ON J.Id=JD.JournalId
	  Left  Join [Bean].[Entity] as E On E.Id =JD.EntityId
	  Left  Join [Bean].[ChartOfAccount] as C on C.Id=JD.COAId
      Left  Join Common.Company SC ON SC.Id=J.ServiceCompanyId
	  Where --JD.SystemRefNo='JV-2018-00002' AND 
	  E.IsCustomer=1 AND J.CompanyId=@CompanyValue AND JD.DocType='Journal' AND JD.DocSubType='Opening Balance'
	  AND J.DocumentState='Posted' 
	   AND (JD.ClearingStatus <> ('Cleared') or JD.ClearingStatus IS NULL)
	  AND 
	  --Case when E.VenNature='Trade' then 'AP' When  E.VenNature='Others' then 'OP'end 
	  Case When C.Name='Accounts Receivables' then 'AR' When C.Name='Other receivables' then 'OR' END
	   In (select items from dbo.SplitToTable(@Payables,','))
	   AND  Jd.PostingDate-->= @Todate then @Todate /*else J.DueDate */ End  
	  Between CONVERT(datetime, @FromDate, 103) AND CONVERT(datetime, @ToDate, 103) 


	AND SC.Name in (select items from dbo.SplitToTable(@ServiceCompanyId,','))
	  Group By E.Name,JD.SystemRefNo,C.Name,/*E.VenNature*/SC.ShortName,JD.DocDate,J.ActualSysRefNo,JD.DocNo,Jd.DocCurrency,JD.BaseCurrency

)


 select C.EntityName,C.DocRefNo,C.Payables,C.DocNo,C.Co,C.DocDate,C.DueDate,Case When C.OverDue<0 then NULL Else OverDue End AS OverDue,C.[Doc Curr],C.DocTotal,Case When C.DocTotal<0 then C.DocBalanceAmount*(-1) else C.DocBalanceAmount end AS DocBalanceAmount,C.Currency,C.Total,Case When C.Total<0 then C.BalanceAmount*(-1) else C.BalanceAmount end AS BalanceAmount,
        --CASE When C.PastDue <0 THEN  C.BalanceAmount END as 'Below 0' ,
        CASE When C.PastDue<=0  Then Case When C.Total<0 then C.BalanceAmount*(-1) else C.BalanceAmount end   END as 'Current',
        CASE When C.PastDue>=1 AND C.PastDue<=30 Then Case When C.Total<0 then C.BalanceAmount*(-1) else C.BalanceAmount end  END as '1 - 30',
        CASE When C.PastDue>=31 AND C.PastDue<=60 Then Case When C.Total<0 then C.BalanceAmount*(-1) else C.BalanceAmount end END as '31 - 60',
        CASE When C.PastDue>=61 AND C.PastDue<=90 Then Case When C.Total<0 then C.BalanceAmount*(-1) else C.BalanceAmount end END as '61 - 90',
        CASE When C.PastDue>=91 Then Case When C.Total<0 then C.BalanceAmount*(-1) else C.BalanceAmount end END as '>90'  
	   
	   From cte as C



END

Else
IF @Currency=1--Doc

	  BEGIN

with cte as


(


  Select E.Name AS 'EntityName',JD.SystemRefNo AS 'DocRefNo',
 Case when J.Nature='Trade' then 'AR' When  J.Nature='Others' then 'OR'end AS 'Payables'
,SC.ShortName AS Co,JD.DocDate,Case When JD.DocType IN ('Credit Note') AND JD.DocSubType IN ('Credit Note') Then JD.DocDate Else J.DueDate End  DueDate,JD.DocNo,DATEDIFF(d, Case When JD.DocType IN ('Credit Note') AND JD.DocSubType IN ('Credit Note') Then JD.DocDate Else J.DueDate End  , @ToDate) as OverDue,Jd.DocCurrency Currency 
,DATEDIFF(d, Case When JD.DocType IN ('Credit Note') AND JD.DocSubType IN ('Credit Note') Then JD.DocDate Else J.DueDate End , @ToDate) as PastDue,

Case When JD.DocType IN('Credit Note') AND JD.DocSubType IN('Credit Note') AND SUM(IsNULL(JD.DocCredit,0))>0 then  
Convert(money,Concat('-',SUM(ISNULL(JD.DocCredit,0)))) Else  SUM(ISNULL(JD.DocDebit,0)) End AS Total , --(JD.BaseCredit+(JD.BaseCredit*(JD.TaxRate/100))) as 'BalanceAmount' 
        Case When SUM(ISNULL(J.BalanceAmount,0))>0 then SUM(ISNULL(J.BalanceAmount,0))
		--*ISNULL(JD.ExchangeRate,0)) 
		Else
		 Case When JD.DocType IN ('Credit Note') AND JD.DocSubType IN ('Credit Note') AND SUM(IsNULL(JD.DocCredit,0))>0 then  
Convert(money,Concat('-',SUM(ISNULL(JD.DocCredit,0)))) Else  SUM(ISNULL(JD.DocDebit,0)) End END  AS BalanceAmount--ISNULL(SUM(JD.BaseCredit),0) AS BalanceAmount
	
	   
	    
FROM [Bean].[JournalDetail] JD 

   Inner Join [Bean].[Journal] J ON J.Id=JD.JournalId
   Left  Join [Bean].[Entity] as E On E.Id =JD.EntityId
   Left  Join [Bean].[ChartOfAccount] as C on C.Id=JD.COAId
   Left  Join Common.Company SC ON SC.Id=J.ServiceCompanyId


Where JD.DocType IN ('Invoice','Credit Note','Debit Note') AND JD.DocSubType IN ('Invoice','General','Recurring','Credit Note','Debit Note')  AND C.CompanyId=@CompanyValue  --AND JD.DocNo='Bill-001'
      AND J.DocumentState IN ('Not Paid','Partial Paid','Posted','Not Applied','Partial Applied') AND E.IsCustomer=1 ---AND JD.SystemRefNo='REV-2018-00001-JV2'
	   AND JD.DocumentDetailId='00000000-0000-0000-0000-000000000000'
	    AND (JD.ClearingStatus <> ('Cleared') or JD.ClearingStatus IS NULL)
	    AND
	      Jd.PostingDate-->= @Todate then @Todate /*else J.DueDate */ End  
	  Between CONVERT(datetime, @FromDate, 103) AND CONVERT(datetime, @ToDate, 103) 
	--case when J.DueDate>= @Todate then @Todate else J.DueDate  End   Between CONVERT(datetime, @FromDate, 103) AND CONVERT(datetime, @ToDate, 103) 
    --AND Case When JD.DocType='Journal' AND JD.DocSubType='General' Then JD.DocDate Else J.DueDate End   Between CONVERT(datetime, @FromDate, 103) AND CONVERT(datetime, @ToDate, 103) 
	  AND Case when J.Nature='Trade' then 'AR' When  J.Nature='Others' then 'OR'
 --When J.Nature IN ('Trade','Others') then 'Both'
  end  In (select items from dbo.SplitToTable(@Payables,','))
     AND SC.Name in (select items from dbo.SplitToTable(@ServiceCompanyId,','))

Group By E.Name,SC.ShortName,JD.SystemRefNo,J.Nature,JD.DocType,JD.DocSubType,JD.DocCurrency,JD.DocNo,JD.DocDate,J.DueDate,JD.ExchangeRate



Union All


	  Select E.Name AS 'EntityName',JD.SystemRefNo AS 'DocRefNo', 
	  --Case when E.VenNature='Trade' then 'AP' When  E.VenNature='Others' then 'OP'end AS 
	  Case When C.Name='Accounts Receivables' then 'AR' When C.Name='Other receivables' then 'OR' END AS
	  'Payables',SC.ShortName AS Co,JD.DocDate, JD.DocDate  AS DueDate,JD.DocNo,DATEDIFF(d, JD.DocDate, @ToDate) as OverDue,Jd.DocCurrency Currency 
	  ,DATEDIFF(d, JD.DocDate , @ToDate) as PastDue,Case When  SUM(IsNULL(JD.DocCredit,0))>0 then  
       Convert(money,Concat('-',SUM(ISNULL(JD.DocCredit,0)))) Else  SUM(ISNULL(JD.DocDebit,0)) End AS Total,
       Case When  SUM(IsNULL(JD.DocCredit,0))>0 then  
      SUM(ISNULL(JD.DocCredit,0)) Else  SUM(ISNULL(JD.DocDebit,0)) End   AS BalanceAmount

	  from Bean.JournalDetail JD
	  Inner Join [Bean].[Journal] J ON J.Id=JD.JournalId
	  Left  Join [Bean].[Entity] as E On E.Id =JD.EntityId
	  Left  Join [Bean].[ChartOfAccount] as C on C.Id=JD.COAId
      Left  Join Common.Company SC ON SC.Id=J.ServiceCompanyId
	  Where --JD.SystemRefNo='JV-2018-00002' AND 
	  E.IsCustomer=1 AND J.CompanyId=@CompanyValue AND JD.DocType='Receipt' AND JD.DocSubType='Customer'
	  AND J.DocumentState='Created' 
	   AND (JD.ClearingStatus <> ('Cleared') or JD.ClearingStatus IS NULL)
	  AND 
	  --Case when E.VenNature='Trade' then 'AP' When  E.VenNature='Others' then 'OP'end 
	  Case When C.Name='Accounts Receivables' then 'AR' When C.Name='Other receivables' then 'OR' END
	   In (select items from dbo.SplitToTable(@Payables,','))
	   AND Jd.PostingDate-->= @Todate then @Todate /*else J.DueDate */ End  
	  Between CONVERT(datetime, @FromDate, 103) AND CONVERT(datetime, @ToDate, 103) 
	  -- AND  case when JD.DocDate>=@todate then @todate else JD.DocDate End 
	  --Between CONVERT(datetime, @FromDate, 103) AND CONVERT(datetime, @ToDate, 103) 


	 AND SC.Name in (select items from dbo.SplitToTable(@ServiceCompanyId,',')) 
	  Group By E.Name,JD.SystemRefNo,C.Name,/*E.VenNature*/SC.ShortName,JD.DocDate,JD.DocNo,Jd.DocCurrency

Union All


---------------------------Doubtful Debt-----------------------------------

	  	  Select E.Name AS 'EntityName',JD.SystemRefNo AS 'DocRefNo', 
	  --Case when E.VenNature='Trade' then 'AP' When  E.VenNature='Others' then 'OP'end AS 
	  Case When C.Name='Doubtful Debt Provision(AR)' then 'AR' When C.Name='Doubtful Debt Provision(OR)' then 'OR' END AS
	  'Payables',SC.ShortName AS Co,JD.DocDate, JD.DocDate  AS DueDate,JD.DocNo,DATEDIFF(d, JD.DocDate, @ToDate) as OverDue,Jd.DocCurrency Currency 
	  ,DATEDIFF(d, JD.DocDate , @ToDate) as PastDue,
--Convert(money,Concat('-',SUM(ISNULL(JD.DocCredit,0))))   AS Total, 
--SUM(ISNULL(JD.DocCredit,0))     AS BalanceAmount

	  Case When  SUM(IsNULL(JD.DocCredit,0))>0 then  
Convert(money,Concat('-',SUM(ISNULL(JD.DocCredit,0)))) Else  SUM(ISNULL(JD.DocDebit,0)) End AS Total,
Case When  SUM(IsNULL(JD.DocCredit,0))>0 then  
SUM(ISNULL(JD.DocCredit,0)) Else  SUM(ISNULL(JD.DocDebit,0)) End   AS BalanceAmount

	  from Bean.JournalDetail JD
	  Inner Join [Bean].[Journal] J ON J.Id=JD.JournalId
	  Left  Join [Bean].[Entity] as E On E.Id =JD.EntityId
	  Left  Join [Bean].[ChartOfAccount] as C on C.Id=JD.COAId
      Left  Join Common.Company SC ON SC.Id=J.ServiceCompanyId
	  Where --JD.SystemRefNo='JV-2018-00002' AND 
	  E.IsCustomer=1  AND	  J.CompanyId=@CompanyValue AND JD.DocType='Doubtful Debt' 
	  --AND JD.DocSubType='General'
	  AND J.DocumentState NOT IN ('Void') 
 
	   AND Case When C.Name='Doubtful Debt Provision(AR)' then 'AR' When C.Name='Doubtful Debt Provision(OR)' then 'OR' END
	   In (select items from dbo.SplitToTable(@Payables,','))
	   AND Jd.PostingDate-->= @Todate then @Todate /*else J.DueDate */ End  
	  Between CONVERT(datetime, @FromDate, 103) AND CONVERT(datetime, @ToDate, 103) 
	  -- AND  case when JD.DocDate>=@todate then @todate else JD.DocDate End 
	  --Between CONVERT(datetime, @FromDate, 103) AND CONVERT(datetime, @ToDate, 103) 


	 AND SC.Name in (select items from dbo.SplitToTable(@ServiceCompanyId,',')) 
	  Group By E.Name,JD.SystemRefNo,C.Name,/*E.VenNature*/SC.ShortName,JD.DocDate,JD.DocNo,Jd.DocCurrency


	




UNION ALL

	  Select E.Name AS 'EntityName',JD.SystemRefNo AS 'DocRefNo', 
	  --Case when E.VenNature='Trade' then 'AP' When  E.VenNature='Others' then 'OP'end AS 
	  Case When C.Name='Accounts Receivables' then 'AR' When C.Name='Other receivables' then 'OR' END AS
	  'Payables',SC.ShortName AS Co,JD.DocDate, JD.DocDate  AS DueDate,JD.DocNo,DATEDIFF(d, JD.DocDate, @ToDate) as OverDue,Jd.DocCurrency Currency 
	  ,DATEDIFF(d, JD.DocDate , @ToDate) as PastDue,Case When  SUM(IsNULL(JD.DocCredit,0))>0 then  
Convert(money,Concat('-',SUM(ISNULL(JD.DocCredit,0)))) Else  SUM(ISNULL(JD.DocDebit,0)) End AS Total,
Case When  SUM(IsNULL(JD.DocCredit,0))>0 then  
SUM(ISNULL(JD.DocCredit,0)) Else  SUM(ISNULL(JD.DocDebit,0)) End   AS BalanceAmount

	  from Bean.JournalDetail JD
	  Inner Join [Bean].[Journal] J ON J.Id=JD.JournalId
	  Left  Join [Bean].[Entity] as E On E.Id =JD.EntityId
	  Left  Join [Bean].[ChartOfAccount] as C on C.Id=JD.COAId
      Left  Join Common.Company SC ON SC.Id=J.ServiceCompanyId
	  Where --JD.SystemRefNo='JV-2018-00002' AND 
	  E.IsCustomer=1 AND J.CompanyId=@CompanyValue AND JD.DocType='Journal' AND JD.DocSubType='General'
	   AND J.DocumentState IN ('Posted','Reversed')
	   AND (JD.ClearingStatus <> ('Cleared') or JD.ClearingStatus IS NULL)
	  AND 
	  --Case when E.VenNature='Trade' then 'AP' When  E.VenNature='Others' then 'OP'end 
	  Case When C.Name='Accounts Receivables' then 'AR' When C.Name='Other receivables' then 'OR' END
	   In (select items from dbo.SplitToTable(@Payables,','))
	   AND Jd.PostingDate-->= @Todate then @Todate /*else J.DueDate */ End  
	  Between CONVERT(datetime, @FromDate, 103) AND CONVERT(datetime, @ToDate, 103) 
	  -- AND  case when JD.DocDate>=@todate then @todate else JD.DocDate End 
	  --Between CONVERT(datetime, @FromDate, 103) AND CONVERT(datetime, @ToDate, 103) 


	 AND SC.Name in (select items from dbo.SplitToTable(@ServiceCompanyId,',')) 
	  Group By E.Name,JD.SystemRefNo,C.Name,/*E.VenNature*/SC.ShortName,JD.DocDate,JD.DocNo,Jd.DocCurrency

Union All


	  Select E.Name AS 'EntityName',J.ActualSysRefNo AS 'DocRefNo',--JD.SystemRefNo AS 'DocRefNo', 
	  --Case when E.VenNature='Trade' then 'AP' When  E.VenNature='Others' then 'OP'end AS 
	  Case When C.Name='Accounts Receivables' then 'AR' When C.Name='Other receivables' then 'OR' END AS
	  'Payables',SC.ShortName AS Co,JD.DocDate, JD.DocDate  AS DueDate,JD.SystemRefNo AS DocNo,--JD.DocNo,
	  DATEDIFF(d, JD.DocDate, @ToDate) as OverDue,Jd.DocCurrency Currency 
	  ,DATEDIFF(d, JD.DocDate , @ToDate) as PastDue,Case When  SUM(IsNULL(JD.DocCredit,0))>0 then  
Convert(money,Concat('-',SUM(ISNULL(JD.DocCredit,0)))) Else  SUM(ISNULL(JD.DocDebit,0)) End AS Total,
Case When  SUM(IsNULL(JD.DocCredit,0))>0 then  
SUM(ISNULL(JD.DocCredit,0)) Else  SUM(ISNULL(JD.DocDebit,0)) End   AS BalanceAmount

	  from Bean.JournalDetail JD
	  Inner Join [Bean].[Journal] J ON J.Id=JD.JournalId
	  Left  Join [Bean].[Entity] as E On E.Id =JD.EntityId
	  Left  Join [Bean].[ChartOfAccount] as C on C.Id=JD.COAId
      Left  Join Common.Company SC ON SC.Id=J.ServiceCompanyId
	  Where --JD.SystemRefNo='JV-2018-00002' AND 
	  E.IsCustomer=1 AND J.CompanyId=@CompanyValue AND JD.DocType='Journal' AND JD.DocSubType='Opening Balance'
	  AND J.DocumentState='Posted' 
	   AND (JD.ClearingStatus <> ('Cleared') or JD.ClearingStatus IS NULL)
	  AND 
	  --Case when E.VenNature='Trade' then 'AP' When  E.VenNature='Others' then 'OP'end 
	  Case When C.Name='Accounts Receivables' then 'AR' When C.Name='Other receivables' then 'OR' END
	   In (select items from dbo.SplitToTable(@Payables,','))
	   AND Jd.PostingDate-->= @Todate then @Todate /*else J.DueDate */ End  
	  Between CONVERT(datetime, @FromDate, 103) AND CONVERT(datetime, @ToDate, 103) 
	  -- AND  case when JD.DocDate>=@todate then @todate else JD.DocDate End 
	  --Between CONVERT(datetime, @FromDate, 103) AND CONVERT(datetime, @ToDate, 103) 


	 AND SC.Name in (select items from dbo.SplitToTable(@ServiceCompanyId,',')) 
	  Group By E.Name,JD.SystemRefNo,C.Name,/*E.VenNature*/SC.ShortName,JD.DocDate,J.ActualSysRefNo,JD.DocNo,Jd.DocCurrency


)
 select C.EntityName,C.DocRefNo,C.Payables,C.DocNo,C.Co,C.DocDate,C.DueDate,Case When C.OverDue<0 then NULL Else OverDue End AS OverDue,C.Currency,C.Total,Case When C.Total<0 then C.BalanceAmount*(-1) else C.BalanceAmount end AS BalanceAmount,
        --CASE When C.PastDue <0 THEN  C.BalanceAmount END as 'Below 0' ,
        CASE When C.PastDue<=0  Then Case When C.Total<0 then C.BalanceAmount*(-1) else C.BalanceAmount end  END as 'Current',
        CASE When C.PastDue>=1 AND C.PastDue<=30 Then Case When C.Total<0 then C.BalanceAmount*(-1) else C.BalanceAmount end  END as '1 - 30',
        CASE When C.PastDue>=31 AND C.PastDue<=60 Then Case When C.Total<0 then C.BalanceAmount*(-1) else C.BalanceAmount end END as '31 - 60',
        CASE When C.PastDue>=61 AND C.PastDue<=90 Then Case When C.Total<0 then C.BalanceAmount*(-1) else C.BalanceAmount end END as '61 - 90',
        CASE When C.PastDue>=91 Then Case When C.Total<0 then C.BalanceAmount*(-1) else C.BalanceAmount end END as '>90'  


 
	   
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


   END
GO
