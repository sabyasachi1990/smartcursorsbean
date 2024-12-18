USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[RPTAPAgeingDetailTestForBase]    Script Date: 16-12-2024 9.20.11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE Procedure [dbo].[RPTAPAgeingDetailTestForBase]

   @FromDate  Varchar(max),                            
   @ToDate  Varchar(max) ,
   --   @FromDate  DateTime,                            
   --@ToDate  DateTime ,

   @CompanyValue Varchar(10),
   @Currency INT,
   @Payables Varchar(50),
   @ServiceCompanyId varchar(100) 
   
     
 AS

Begin
   --Declare @TD Datetime=Getdate()

  Declare @CompanyId Int    
  SET @ToDate = CONVERT(DATETIME, CONVERT(varchar(11),@ToDate, 103 ) + ' 23:59:59', 103)  
  select @CompanyId = dbo.DecryptCompanyValue(@CompanyValue) 



  --exec RPTAPAgeingDetail @FromDate=N'01-01-1900',@ToDate=N'25-05-2018',@CompanyValue=N'295',@Currency=1,@Payables=N'AP',@ServiceCompanyId=N'296,327,765'


IF @Currency=0--Base

	  BEGIN
--IF @Payables=0
--BEGIN

with cte as


(


 Select E.Name AS 'EntityName',JD.SystemRefNo AS 'DocRefNo',
 Case when J.Nature='Trade' then 'AP' When  J.Nature='Others' then 'OP'end AS 'Payables',SC.Name AS 'ServiceCompany' 
,SC.ShortName AS Co,JD.DocDate, J.DueDate,JD.DocNo,DATEDIFF(d,J.DueDate, @ToDate) as OverDue,Jd.BaseCurrency Currency,Jd.DocCurrency AS 'Doc Curr'  
,DATEDIFF(d, J.DueDate, @ToDate) as PastDue,
Case When JD.DocType IN ('Credit Memo','Payroll Bill') AND JD.DocSubType IN ('Credit Memo','Payroll Bill') AND SUM(IsNULL(JD.BaseDebit,0))>0 then  
Convert(money,Concat('-',SUM(ISNULL(JD.BaseDebit,0)))) Else  SUM(ISNULL(JD.BaseCredit,0)) End AS Total ,
Case When JD.DocType IN ('Credit Memo','Payroll Bill') AND JD.DocSubType IN ('Credit Memo','Payroll Bill') AND SUM(IsNULL(JD.DocDebit,0))>0 then  
Convert(money,Concat('-',SUM(ISNULL(JD.DocDebit,0)))) Else  SUM(ISNULL(JD.DocCredit,0)) End AS DocTotal,
 --(JD.BaseCredit+(JD.BaseCredit*(JD.TaxRate/100))) as 'BalanceAmount' 
        Case When SUM(ISNULL(J.BalanceAmount,0))>0 then (SUM(ISNULL(J.BalanceAmount,0))
		*ISNULL(JD.ExchangeRate,0)) 
		Else
		 Case When JD.DocType IN ('Credit Memo','Payroll Bill') AND JD.DocSubType IN ('Credit Memo','Payroll Bill') AND SUM(IsNULL(JD.BaseDebit,0))>0 then  
Convert(money,Concat('-',SUM(ISNULL(JD.BaseDebit,0)))) Else  SUM(ISNULL(JD.BaseCredit,0)) End END  AS BalanceAmount,
  Case When SUM(ISNULL(J.BalanceAmount,0))>0 then SUM(ISNULL(J.BalanceAmount,0))
		--*ISNULL(JD.ExchangeRate,0)) 
		Else
		 Case When JD.DocType IN ('Credit Memo','Payroll Bill') AND JD.DocSubType IN ('Credit Memo','Payroll Bill') AND SUM(IsNULL(JD.DocDebit,0))>0 then  
Convert(money,Concat('-',SUM(ISNULL(JD.DocDebit,0)))) Else  SUM(ISNULL(JD.DocCredit,0)) End END  AS DocBalanceAmount
--ISNULL(SUM(JD.BaseCredit),0) AS BalanceAmount
	
	   
	    
FROM [Bean].[JournalDetail] JD 

   Inner Join [Bean].[Journal] J ON J.Id=JD.JournalId
   Left  Join [Bean].[Entity] as E On E.Id =JD.EntityId
   Left  Join [Bean].[ChartOfAccount] as C on C.Id=JD.COAId
   Left  Join Common.Company SC ON SC.Id=J.ServiceCompanyId


Where JD.DocType IN ('Bill','Credit Memo','Payroll Bill') AND JD.DocSubType IN ('Bill','Credit Memo','Payroll Bill')  AND C.CompanyId=@CompanyValue  --AND JD.DocNo='Bill-001'
      AND J.DocumentState IN ('Not Paid','Partial Paid','Posted','Not Applied','Partial Applied') AND E.IsVendor=1 ---AND JD.SystemRefNo='REV-2018-00001-JV2'
	  AND JD.DocumentDetailId='00000000-0000-0000-0000-000000000000'
	  AND (JD.ClearingStatus <> ('Cleared') or JD.ClearingStatus IS NULL)
	AND  Jd.PostingDate-->= @Todate then @Todate /*else J.DueDate */ End  
	  Between CONVERT(datetime, @FromDate, 103) AND CONVERT(datetime, @ToDate, 103) 
	--     AND 
	--case when J.DueDate>= @Todate then @Todate else J.DueDate  End   Between CONVERT(datetime, @FromDate, 103) AND CONVERT(datetime, @ToDate, 103) 
 --   AND Case When JD.DocType='Journal' AND JD.DocSubType='General' Then JD.DocDate Else J.DueDate End   
	----Between @FromDate and @ToDate
	--Between CONVERT(datetime, @FromDate, 103) AND CONVERT(datetime, @ToDate, 103)
	  AND Case when J.Nature='Trade' then 'AP' When  J.Nature='Others' then 'OP'
 --When J.Nature IN ('Trade','Others') then 'Both'
  end  In (select items from dbo.SplitToTable(@Payables,','))
      AND SC.Name in (select items from dbo.SplitToTable(@ServiceCompanyId,',')) 

Group By E.Name,SC.Name,SC.ShortName,JD.SystemRefNo,J.Nature,JD.DocType,JD.DocSubType,JD.DocCurrency,JD.DocNo,JD.DocDate,J.DueDate,JD.ExchangeRate,JD.BaseCurrency


Union All

	  Select E.Name AS 'EntityName',JD.SystemRefNo AS 'DocRefNo', 
	  --Case when E.VenNature='Trade' then 'AP' When  E.VenNature='Others' then 'OP'end AS 
	  Case When C.Name='Accounts payables' then 'AP' When C.Name='Other payables' then 'OP' END AS
	  'Payables',SC.Name AS 'ServiceCompany',SC.ShortName AS Co,JD.DocDate, JD.DocDate  AS DueDate,JD.DocNo,DATEDIFF(d, JD.DocDate, @ToDate) as OverDue,Jd.BaseCurrency Currency,JD.DocCurrency AS 'Doc Curr' 
	  ,DATEDIFF(d, JD.DocDate , @ToDate) as PastDue,Case When  SUM(IsNULL(case when JD.BaseCurrency=JD.DocCurrency and JD.BaseDebit is null then JD.DocDebit else JD.BaseDebit end,0))>0 then  
Convert(money,Concat('-',SUM(ISNULL(case when JD.BaseCurrency=JD.DocCurrency and JD.BaseDebit is null then JD.DocDebit else JD.BaseDebit end,0)))) Else  SUM(ISNULL(Case when JD.BaseCurrency=JD.DocCurrency and JD.BaseCredit is null then JD.DocCredit else JD.BaseCredit end,0)) End AS Total,
Case When  SUM(IsNULL(JD.DocDebit,0))>0 then  
Convert(money,Concat('-',SUM(ISNULL(JD.DocDebit,0)))) Else  SUM(ISNULL(JD.DocCredit,0)) End AS DocTotal,
Case When  SUM(IsNULL(JD.BaseDebit,0))>0 then  
SUM(ISNULL(case when JD.BaseCurrency=JD.DocCurrency and JD.BaseDebit is null then JD.DocDebit else JD.BaseDebit end,0)) Else  SUM(ISNULL(Case when JD.BaseCurrency=JD.DocCurrency and JD.BaseCredit is null then JD.DocCredit else JD.BaseCredit end,0)) End   AS BalanceAmount,

Case When  SUM(IsNULL(JD.DocDebit,0))>0 then  
SUM(ISNULL(JD.DocDebit,0)) Else  SUM(ISNULL(JD.DocCredit,0)) End   AS DocBalanceAmount

	  from Bean.JournalDetail JD
	  Inner Join [Bean].[Journal] J ON J.Id=JD.JournalId
	  Left  Join [Bean].[Entity] as E On E.Id =JD.EntityId
	  Left  Join [Bean].[ChartOfAccount] as C on C.Id=JD.COAId
      Left  Join Common.Company SC ON SC.Id=J.ServiceCompanyId
	  Where --JD.SystemRefNo='JV-2018-00002' AND 
	  E.IsVendor=1 AND J.CompanyId=@CompanyValue AND JD.DocType='Journal' AND JD.DocSubType='General'
	  AND J.DocumentState  IN ('Posted','Reversed') 
	  AND (JD.ClearingStatus <> ('Cleared') or JD.ClearingStatus IS NULL)
	  AND 
	  --Case when E.VenNature='Trade' then 'AP' When  E.VenNature='Others' then 'OP'end 
	  Case When C.Name='Accounts payables' then 'AP' When C.Name='Other payables' then 'OP' END 
	   In (select items from dbo.SplitToTable(@Payables,','))
	 AND  JD.PostingDate-->= @Todate then @Todate /*else J.DueDate */ End  
	  Between CONVERT(datetime, @FromDate, 103) AND CONVERT(datetime, @ToDate, 103) 


	 AND SC.Name in (select items from dbo.SplitToTable(@ServiceCompanyId,',')) 
	  Group By E.Name,JD.SystemRefNo,C.Name,/*E.VenNature*/SC.Name,SC.ShortName,JD.DocDate,JD.DocNo,Jd.DocCurrency,JD.BaseCurrency


Union All

	  Select E.Name AS 'EntityName',J.ActualSysRefNo 'DocRefNo',--JD.SystemRefNo AS 'DocRefNo', 
	  --Case when E.VenNature='Trade' then 'AP' When  E.VenNature='Others' then 'OP'end AS 
	  Case When C.Name='Accounts payables' then 'AP' When C.Name='Other payables' then 'OP' END AS
	  'Payables',SC.Name AS 'ServiceCompany',SC.ShortName AS Co,JD.DocDate, JD.DocDate  AS DueDate,JD.SystemRefNo AS DocNo--JD.DocNo
	  ,DATEDIFF(d, JD.DocDate, @ToDate) as OverDue,Jd.BaseCurrency Currency,JD.DocCurrency AS 'Doc Curr' 
	  ,DATEDIFF(d, JD.DocDate , @ToDate) as PastDue,Case When  SUM(IsNULL(case when JD.BaseCurrency=JD.DocCurrency and JD.BaseDebit is null then JD.DocDebit else JD.BaseDebit end,0))>0 then  
Convert(money,Concat('-',SUM(ISNULL(case when JD.BaseCurrency=JD.DocCurrency and JD.BaseDebit is null then JD.DocDebit else JD.BaseDebit end,0)))) Else  SUM(ISNULL(Case when JD.BaseCurrency=JD.DocCurrency and JD.BaseCredit is null then JD.DocCredit else JD.BaseCredit end,0)) End AS Total,
Case When  SUM(IsNULL(JD.DocDebit,0))>0 then  
Convert(money,Concat('-',SUM(ISNULL(JD.DocDebit,0)))) Else  SUM(ISNULL(JD.DocCredit,0)) End AS DocTotal,
Case When  SUM(IsNULL(JD.BaseDebit,0))>0 then  
SUM(ISNULL(case when JD.BaseCurrency=JD.DocCurrency and JD.BaseDebit is null then JD.DocDebit else JD.BaseDebit end,0)) Else  SUM(ISNULL(Case when JD.BaseCurrency=JD.DocCurrency and JD.BaseCredit is null then JD.DocCredit else JD.BaseCredit end,0)) End   AS BalanceAmount,

Case When  SUM(IsNULL(JD.DocDebit,0))>0 then  
SUM(ISNULL(JD.DocDebit,0)) Else  SUM(ISNULL(JD.DocCredit,0)) End   AS DocBalanceAmount

	  from Bean.JournalDetail JD
	  Inner Join [Bean].[Journal] J ON J.Id=JD.JournalId
	  Left  Join [Bean].[Entity] as E On E.Id =JD.EntityId
	  Left  Join [Bean].[ChartOfAccount] as C on C.Id=JD.COAId
      Left  Join Common.Company SC ON SC.Id=J.ServiceCompanyId
	  Where --JD.SystemRefNo='JV-2018-00002' AND 
	  E.IsVendor=1 AND J.CompanyId=@CompanyValue AND JD.DocType='Journal' AND JD.DocSubType='Opening Balance'
	  AND J.DocumentState='Posted' 
	  AND (JD.ClearingStatus <> ('Cleared') or JD.ClearingStatus IS NULL)
	  AND 
	  --Case when E.VenNature='Trade' then 'AP' When  E.VenNature='Others' then 'OP'end 
	  Case When C.Name='Accounts payables' then 'AP' When C.Name='Other payables' then 'OP' END 
	   In (select items from dbo.SplitToTable(@Payables,','))
	 AND  Jd.PostingDate-->= @Todate then @Todate /*else J.DueDate */ End  
	  Between CONVERT(datetime, @FromDate, 103) AND CONVERT(datetime, @ToDate, 103) 


	 AND SC.Name in (select items from dbo.SplitToTable(@ServiceCompanyId,',')) 
	  Group By E.Name,JD.SystemRefNo,C.Name,/*E.VenNature*/SC.Name,SC.ShortName,J.ActualSysRefNo,JD.DocDate,JD.DocNo,Jd.DocCurrency,JD.BaseCurrency


)

 select C.EntityName,C.DocRefNo,C.Payables,C.DocNo,C.ServiceCompany,C.Co,C.DocDate,C.DueDate,Case When C.OverDue<0 then NULL Else OverDue End AS OverDue,C.Currency,C.[Doc Curr],C.Total,C.DocTotal,Case When C.Total<0 then C.BalanceAmount*(-1) else C.BalanceAmount end AS BalanceAmount,Case When C.DocTotal<0 then C.DocBalanceAmount*(-1) else C.DocBalanceAmount end AS DocBalanceAmount,
        --CASE When C.PastDue <0 THEN  C.BalanceAmount END as 'Below 0' ,
        CASE When C.PastDue<=0  Then Case When C.Total<0 then C.BalanceAmount*(-1) else C.BalanceAmount end  END as 'Current',
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
 Case when J.Nature='Trade' then 'AP' When  J.Nature='Others' then 'OP'end AS 'Payables',SC.Name AS 'ServiceCompany'
,SC.ShortName AS Co,JD.DocDate, J.DueDate,JD.DocNo,DATEDIFF(d,J.DueDate, @ToDate) as OverDue,Jd.DocCurrency Currency 
,DATEDIFF(d, J.DueDate, @ToDate) as PastDue,
Case When JD.DocType IN ('Credit Memo','Payroll Bill') AND JD.DocSubType IN ('Credit Memo','Payroll Bill') AND SUM(IsNULL(JD.DocDebit,0))>0 then  
Convert(money,Concat('-',SUM(ISNULL(JD.DocDebit,0)))) Else  SUM(ISNULL(JD.DocCredit,0)) End AS Total , --(JD.BaseCredit+(JD.BaseCredit*(JD.TaxRate/100))) as 'BalanceAmount' 
        Case When SUM(ISNULL(J.BalanceAmount,0))>0 then SUM(ISNULL(J.BalanceAmount,0))
		--*ISNULL(JD.ExchangeRate,0)) 
		Else
		 Case When JD.DocType IN ('Credit Memo','Payroll Bill') AND JD.DocSubType IN ('Credit Memo','Payroll Bill') AND SUM(IsNULL(JD.DocDebit,0))>0 then  
Convert(money,Concat('-',SUM(ISNULL(JD.DocDebit,0)))) Else  SUM(ISNULL(JD.DocCredit,0)) End END  AS BalanceAmount--ISNULL(SUM(JD.BaseCredit),0) AS BalanceAmount
	
	   
	    
FROM [Bean].[JournalDetail] JD 

   Inner Join [Bean].[Journal] J ON J.Id=JD.JournalId
   Left  Join [Bean].[Entity] as E On E.Id =JD.EntityId
   Left  Join [Bean].[ChartOfAccount] as C on C.Id=JD.COAId
   Left  Join Common.Company SC ON SC.Id=J.ServiceCompanyId


Where JD.DocType IN ('Bill','Credit Memo','Payroll Bill') AND JD.DocSubType IN ('Bill','Credit Memo','Payroll Bill')  AND C.CompanyId=@CompanyValue  --AND JD.DocNo='Bill-001'
      AND J.DocumentState IN ('Not Paid','Partial Paid','Posted','Not Applied','Partial Applied') AND E.IsVendor=1 ---AND JD.SystemRefNo='REV-2018-00001-JV2'
	  AND JD.DocumentDetailId='00000000-0000-0000-0000-000000000000'
	  AND (JD.ClearingStatus <> ('Cleared') or JD.ClearingStatus IS NULL)
	     AND 
	 JD.PostingDate-->= @Todate then @Todate else J.DueDate  End 
	  Between CONVERT(datetime, @FromDate, 103) AND CONVERT(datetime, @ToDate, 103) 
 --   AND Case When JD.DocType='Journal' AND JD.DocSubType='General' Then JD.DocDate Else J.DueDate End   
	----Between @FromDate and @ToDate
	--Between CONVERT(datetime, @FromDate, 103) AND CONVERT(datetime, @ToDate, 103)
	  AND Case when J.Nature='Trade' then 'AP' When  J.Nature='Others' then 'OP'
 --When J.Nature IN ('Trade','Others') then 'Both'
  end  In (select items from dbo.SplitToTable(@Payables,','))
      AND SC.Name in (select items from dbo.SplitToTable(@ServiceCompanyId,',')) 

Group By E.Name,SC.Name,SC.ShortName,JD.SystemRefNo,J.Nature,JD.DocType,JD.DocSubType,JD.DocCurrency,JD.DocNo,JD.DocDate,J.DueDate,JD.ExchangeRate


Union All

	  Select E.Name AS 'EntityName',JD.SystemRefNo AS 'DocRefNo', 
	  --Case when E.VenNature='Trade' then 'AP' When  E.VenNature='Others' then 'OP'end AS 
	  Case When C.Name='Accounts payables' then 'AP' When C.Name='Other payables' then 'OP' END AS
	  'Payables',SC.Name AS 'ServiceCompany',SC.ShortName AS Co,JD.DocDate, JD.DocDate  AS DueDate,JD.DocNo,DATEDIFF(d, JD.DocDate, @ToDate) as OverDue,Jd.DocCurrency Currency 
	  ,DATEDIFF(d, JD.DocDate , @ToDate) as PastDue,Case When  SUM(IsNULL(JD.DocDebit,0))>0 then  
Convert(money,Concat('-',SUM(ISNULL(JD.DocDebit,0)))) Else  SUM(ISNULL(JD.DocCredit,0)) End AS Total,
Case When  SUM(IsNULL(JD.DocDebit,0))>0 then  
SUM(ISNULL(JD.DocDebit,0)) Else  SUM(ISNULL(JD.DocCredit,0)) End   AS BalanceAmount

	  from Bean.JournalDetail JD
	  Inner Join [Bean].[Journal] J ON J.Id=JD.JournalId
	  Left  Join [Bean].[Entity] as E On E.Id =JD.EntityId
	  Left  Join [Bean].[ChartOfAccount] as C on C.Id=JD.COAId
      Left  Join Common.Company SC ON SC.Id=J.ServiceCompanyId
	  Where --JD.SystemRefNo='JV-2018-00002' AND 
	  E.IsVendor=1 AND J.CompanyId=@CompanyValue AND JD.DocType='Journal' AND JD.DocSubType='General'
	   AND J.DocumentState  IN ('Posted','Reversed')
	  AND (JD.ClearingStatus <> ('Cleared') or JD.ClearingStatus IS NULL)
	  AND 
	  --Case when E.VenNature='Trade' then 'AP' When  E.VenNature='Others' then 'OP'end 
	  Case When C.Name='Accounts payables' then 'AP' When C.Name='Other payables' then 'OP' END
	   In (select items from dbo.SplitToTable(@Payables,','))
	AND  Jd.PostingDate-->= @Todate then @Todate /*else J.DueDate */ End  
	  Between CONVERT(datetime, @FromDate, 103) AND CONVERT(datetime, @ToDate, 103) 


	 AND SC.Name in (select items from dbo.SplitToTable(@ServiceCompanyId,',')) 
	  Group By E.Name,JD.SystemRefNo,C.Name,/*E.VenNature*/SC.Name,SC.ShortName,JD.DocDate,JD.DocNo,Jd.DocCurrency

Union All

	  Select E.Name AS 'EntityName',J.ActualSysRefNo AS 'DocRefNo',--JD.SystemRefNo AS 'DocRefNo', 
	  --Case when E.VenNature='Trade' then 'AP' When  E.VenNature='Others' then 'OP'end AS 
	  Case When C.Name='Accounts payables' then 'AP' When C.Name='Other payables' then 'OP' END AS
	  'Payables',SC.Name AS 'ServiceCompany',SC.ShortName AS Co,JD.DocDate, JD.DocDate  AS DueDate,JD.SystemRefNo AS DocNo--JD.DocNo
	  ,DATEDIFF(d, JD.DocDate, @ToDate) as OverDue,Jd.DocCurrency Currency 
	  ,DATEDIFF(d, JD.DocDate , @ToDate) as PastDue,Case When  SUM(IsNULL(JD.DocDebit,0))>0 then  
Convert(money,Concat('-',SUM(ISNULL(JD.DocDebit,0)))) Else  SUM(ISNULL(JD.DocCredit,0)) End AS Total,
Case When  SUM(IsNULL(JD.DocDebit,0))>0 then  
SUM(ISNULL(JD.DocDebit,0)) Else  SUM(ISNULL(JD.DocCredit,0)) End   AS BalanceAmount

	  from Bean.JournalDetail JD
	  Inner Join [Bean].[Journal] J ON J.Id=JD.JournalId
	  Left  Join [Bean].[Entity] as E On E.Id =JD.EntityId
	  Left  Join [Bean].[ChartOfAccount] as C on C.Id=JD.COAId
      Left  Join Common.Company SC ON SC.Id=J.ServiceCompanyId
	  Where --JD.SystemRefNo='JV-2018-00002' AND 
	  E.IsVendor=1 AND J.CompanyId=@CompanyValue AND JD.DocType='Journal' AND JD.DocSubType='Opening Balance'
	  AND J.DocumentState='Posted' 
	  AND (JD.ClearingStatus <> ('Cleared') or JD.ClearingStatus IS NULL)
	  AND 
	  --Case when E.VenNature='Trade' then 'AP' When  E.VenNature='Others' then 'OP'end 
	  Case When C.Name='Accounts payables' then 'AP' When C.Name='Other payables' then 'OP' END
	   In (select items from dbo.SplitToTable(@Payables,','))
	AND  Jd.PostingDate-->= @Todate then @Todate /*else J.DueDate */ End  
	  Between CONVERT(datetime, @FromDate, 103) AND CONVERT(datetime, @ToDate, 103) 


	 AND SC.Name in (select items from dbo.SplitToTable(@ServiceCompanyId,',')) 
	  Group By E.Name,JD.SystemRefNo,C.Name,/*E.VenNature*/SC.Name,SC.ShortName,J.ActualSysRefNo,JD.DocDate,JD.DocNo,Jd.DocCurrency
	  
	  )

 select C.EntityName,C.DocRefNo,C.Payables,C.DocNo,C.ServiceCompany,C.Co,C.DocDate,C.DueDate,Case When C.OverDue<0 then NULL Else OverDue End AS OverDue,C.Currency,C.Total,Case When C.Total<0 then C.BalanceAmount*(-1) else C.BalanceAmount end AS BalanceAmount,
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
 Case when J.Nature='Trade' then 'AP' When  J.Nature='Others' then 'OP'end AS 'Payables'
,SC.ShortName AS Co,JD.DocDate,JD.DocDate AS DueDate,JD.DocNo,DATEDIFF(d, JD.DocDate, getdate()) as OverDue,Jd.DocCurrency Currency 
,DATEDIFF(d, JD.DocDate, getdate()) as PastDue,
Case When JD.DocType='Journal' AND JD.DocSubType='General' AND SUM(IsNULL(JD.DocDebit,0))>0 then  
Convert(money,Concat('-',SUM(ISNULL(JD.DocDebit,0)))) Else  SUM(ISNULL(JD.DocCredit,0)) End AS Total , --(JD.BaseCredit+(JD.BaseCredit*(JD.TaxRate/100))) as 'BalanceAmount' 
        Case When SUM(ISNULL(JD.AmountDue,0))>0 then (SUM(ISNULL(JD.AmountDue,0))*ISNULL(JD.ExchangeRate,0)) Else
		 Case When JD.DocType='Journal' AND JD.DocSubType='General' AND SUM(IsNULL(JD.DocDebit,0))>0 then  
Convert(money,Concat('-',SUM(ISNULL(JD.DocDebit,0)))) Else  SUM(ISNULL(JD.DocCredit,0)) End END  AS BalanceAmount--ISNULL(SUM(JD.BaseCredit),0) AS BalanceAmount
	
	   
	    
FROM [Bean].[JournalDetail] JD 

   Inner Join [Bean].[Journal] J ON J.Id=JD.JournalId
   Left  Join [Bean].[Entity] as E On E.Id =JD.EntityId
   Left  Join [Bean].[ChartOfAccount] as C on C.Id=JD.COAId
   Left  Join Common.Company SC ON SC.Id=JD.ServiceCompanyId


Where JD.DocType IN ('Journal') AND JD.DocSubType IN ('Revaluation')  AND C.CompanyId=@CompanyValue  --AND JD.DocNo='Bill-001'
      AND J.DocumentState IN ('Not Paid','Partial Paid','Posted') AND E.IsVendor=1 ---AND JD.SystemRefNo='REV-2018-00001-JV2'
    AND JD.DocDate= @ToDate   --Between CONVERT(datetime, @FromDate, 103) AND CONVERT(datetime, @ToDate, 103) 
	  AND Case when J.Nature='Trade' then 'AP' When  J.Nature='Others' then 'OP'
 --When J.Nature IN ('Trade','Others') then 'Both'
  end  In (select items from dbo.SplitToTable(@Payables,','))
      AND SC.Id in (select items from dbo.SplitToTable(@ServiceCompanyId,',')) 

Group By E.Name,SC.ShortName,JD.SystemRefNo,J.Nature,JD.DocType,JD.DocSubType,JD.DocCurrency,JD.DocNo,JD.DocDate,J.DueDate,JD.ExchangeRate


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
