USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[RptTrailBalanceFinancialYear]    Script Date: 16-12-2024 9.20.11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE Procedure [dbo].[RptTrailBalanceFinancialYear]
@CompanyValue Varchar(100),
@ServiceCompany varchar(max),
@ToDate  Datetime

AS
Begin


--Declare @CompanyId INT=98,@ServiceCompany Varchar(100) = 'Axis pvt ltd' ,@ToDate DateTime='2018-08-22'
Declare @CompanyId int
select @CompanyId = dbo.DecryptCompanyValue(@CompanyValue)


Declare @StartDate date='1990-01-01'

 --Declare @StartDate date=(
 --select Top 1 JD.PostingDate from Bean.JournalDetail as JD
 --   join  Bean.Journal as J on J.Id=JD.journalId Where j.CompanyId=@CompanyId
	--and JD.PostingDate is not null
	--Order by JD.PostingDate )

	--print(@startDate)

	Declare @Date DateTime= (Select Case when dateadd(YEAR, 0, dateadd(day, 1, cast(REPLACE(BusinessYearEnd, '-', ' ')
 +cast(datepart(year, @ToDate/*getdate()*/) as char(4)) as date))) < @ToDate--getdate() 
 then dateadd(YEAR, 0, dateadd(day, 1,cast(REPLACE(BusinessYearEnd, '-', ' ') + cast(datepart(year, @ToDate/*getdate()*/) as char(4)) as date)))else
  dateadd(YEAR, -1, dateadd(day, 1, cast(REPLACE(BusinessYearEnd, '-', ' ') +cast(datepart(year, @ToDate/*getdate()*/) as char(4)) as date))) end as
 FromDate from[Common].[Localization] Where CompanyId=@CompanyId)


 Select --[Service Company],
 [COA Name],[COA COde],SUM(Debit) AS Debit,SUM(Credit) Credit from 
 (

 --ReturnErnings:
 --Step 5: If basetotal >= 0 then BaseTotal is showing as Debit else -BaseTotal  is showing as credit
Select --[Service Company],
[COA Name],[COA COde],classOrder,RecOrder,SUM(Debit) Debit,SUM(Credit) Credit From
(

Select --[Service Company],
[COA Name],[COA COde],
Case when BaseTotal >= 0 then BaseTotal end as Debit,case when BaseTotal < 0 then -BaseTotal end as Credit,classOrder,RecOrder
From
(
	--Step 4:BaseTotal=BaseDebit-BaseCredit
	select --[Service Company],
	[COA Name],[COA COde],
	BaseDebit-BaseCredit as BaseTotal,classOrder,RecOrder
	From
	(
		--Step 3: Grouping done by [Service Company],[COA Name],[COA COde],classOrder
		Select --[Service Company],
		[COA Name],[COA COde],
		SUM(BaseDebit) BaseDebit,SUM(BaseCredit) BaseCredit,classOrder,RecOrder
		From
		(
			--Step2: replacing null with zero
			Select --[Service Company],
			[COA Name],[COA COde],
			isnull(BaseDebit,0) BaseDebit,isnull(BaseCredit,0) BaseCredit,classOrder,RecOrder
			From
			(
 Select --SC.Name as [Service Company],
 COA.Name AS [COA Name],COA.Code AS [COA COde],'2' AS classOrder,'' AS RecOrder,
 case when JD.BaseCurrency=JD.DocCurrency and JD.BaseDebit is null then JD.DocDebit else JD.BaseDebit end  BaseDebit,
        Case when JD.BaseCurrency=JD.DocCurrency and JD.BaseCredit is null then JD.DocCredit else JD.BaseCredit end  BaseCredit--,
   
 from 
 Bean.JournalDetail as JD
    join  Bean.Journal as J on J.Id=JD.journalId
    join  Bean.chartOfAccount as COA on COA.Id=JD.COAID

	 join  Common.Company As SC on SC.Id=J.ServiceCompanyId
 Where COA.CompanyId=@CompanyId  AND COA.Name IN ('Retained earnings')
  AND SC.Name in (select items from dbo.SplitToTable(@ServiceCompany,',')) AND JD.PostingDate Between @StartDate And @Date-1

  UNION ALL

  Select --SC.Name as [Service Company],
 COA.Name AS [COA Name],COA.Code AS [COA COde],'2' AS classOrder,'' AS RecOrder,
 case when JD.BaseCurrency=JD.DocCurrency and JD.BaseDebit is null then JD.DocDebit else JD.BaseDebit end  BaseDebit,
        Case when JD.BaseCurrency=JD.DocCurrency and JD.BaseCredit is null then JD.DocCredit else JD.BaseCredit end  BaseCredit--,
   
 from 
 Bean.JournalDetail as JD
    join  Bean.Journal as J on J.Id=JD.journalId
    join  Bean.chartOfAccount as COA on COA.Id=JD.COAID
	 join  Common.Company As SC on SC.Id=J.ServiceCompanyId
 Where COA.CompanyId=@CompanyId  AND COA.Name IN ('Retained earnings')
  AND SC.Name in (select items from dbo.SplitToTable(@ServiceCompany,',')) AND JD.PostingDate Between @Date And @ToDate

 UNION ALL

select --SC.Name as [Service Company],
'Retained earnings' AS [COA Name],
(Select Distinct COA.Code From 
Bean.JournalDetail as JD
    join  Bean.Journal as J on J.Id=JD.journalId
join Bean.chartOfAccount COA ON COA.Id=JD.COAId
join  Common.Company As SC on SC.Id=J.ServiceCompanyId
Where COA.CompanyId=@CompanyId AND COA.Name IN ('Retained earnings') 
AND SC.Name in (select items from dbo.SplitToTable(@ServiceCompany,','))) AS [COA COde],'2' AS classOrder,'' AS RecOrder,
        case when JD.BaseCurrency=JD.DocCurrency and JD.BaseDebit is null then JD.DocDebit else JD.BaseDebit end  BaseDebit,
        Case when JD.BaseCurrency=JD.DocCurrency and JD.BaseCredit is null then JD.DocCredit else JD.BaseCredit end  BaseCredit--,
   
       -- Case when COA.Class in('Assets','Asset') then 1 
       --when COA.Class='Liabilities' then 2
       --when COA.Class='Equity' then 3
       --when COA.Class='Income' then 4
       --when COA.Class='Expenses' then 5 end as classOrder
    from  Bean.JournalDetail as JD
    join  Bean.Journal as J on J.Id=JD.journalId
    join  Bean.chartOfAccount as COA on COA.Id=JD.COAID

    join  Common.Company As SC on SC.Id=J.ServiceCompanyId
    where COA.companyId=@CompanyId and COA.ModuleType='Bean' 
	and SC.Name in (select items from dbo.SplitToTable(@ServiceCompany,','))
	and J.DocumentState NOT IN ('Void','Cancelled','Parked','Reset','Recurring')
    
    AND COA.Class IN ('Income','Expenses')
    and   convert(date,JD.PostingDate) Between  @StartDate And @Date-1
 ) RE1
			--End of step2
		) RE2
		group by --[Service Company],
		[COA Name],[COA COde]---
		 ,classOrder,RecOrder
		--End of step3
	) RE3
	--End of Step 4
)RE4
--order by classOrder
--End of Step 5
)RE5
Group By --[Service Company],
[COA Name],[COA COde],classOrder,RecOrder

Union All 

--Income,Expenses:

 Select --[Service Company],
 [COA Name],[COA COde],classOrder,Recorder,
Case when BaseTotal >= 0 then BaseTotal end as Debit,case when BaseTotal < 0 then -BaseTotal end as Credit
From
(
	--Step 4:BaseTotal=BaseDebit-BaseCredit
	select --[Service Company],
	[COA Name],[COA COde],
	BaseDebit-BaseCredit as BaseTotal,classOrder,Recorder
	From
	(
		--Step 3: Grouping done by [Service Company],[COA Name],[COA COde],classOrder
		Select --[Service Company],
		[COA Name],[COA COde],
		SUM(BaseDebit) BaseDebit,SUM(BaseCredit) BaseCredit,classOrder,Recorder
		From
		(
			--Step2: replacing null with zero
			Select --[Service Company],
			[COA Name],[COA COde],
			isnull(BaseDebit,0) BaseDebit,isnull(BaseCredit,0) BaseCredit,classOrder,Recorder
			From
			(
 select --SC.Name as [Service Company],
 COA.Name [COA Name],JD.PostingDate,COA.Code AS [COA COde],'3' AS classOrder,AT.Recorder,
        case when JD.BaseCurrency=JD.DocCurrency and JD.BaseDebit is null then JD.DocDebit else JD.BaseDebit end  BaseDebit,
        Case when JD.BaseCurrency=JD.DocCurrency and JD.BaseCredit is null then JD.DocCredit else JD.BaseCredit end  BaseCredit--,
   
       -- Case when COA.Class in('Assets','Asset') then 1 
       --when COA.Class='Liabilities' then 2
       --when COA.Class='Equity' then 3
       --when COA.Class='Income' then 4
       --when COA.Class='Expenses' then 5 end as classOrder
    from  Bean.JournalDetail as JD
    join  Bean.Journal as J on J.Id=JD.journalId
    join  Bean.chartOfAccount as COA on COA.Id=JD.COAID
	Left Join Bean.AccountType As AT On AT.Id=COA.AccountTypeId And AT.CompanyId=COA.CompanyId
    join  Common.Company As SC on SC.Id=J.ServiceCompanyId

    where COA.companyId=@CompanyId and COA.ModuleType='Bean' 
	and SC.Name in (select items from dbo.SplitToTable(@ServiceCompany,','))
	and J.DocumentState NOT IN ('Void','Cancelled','Parked','Reset','Recurring')
    
    AND COA.Class IN ('Income','Expenses')
    and   convert(date,JD.PostingDate) Between  @Date And @ToDate/*getdate()*/
	 ) IE1
			--End of step2
		) IE2
		group by --[Service Company],
		[COA Name],[COA COde]---
		   ,classOrder,Recorder
		--End of step3
	) IE3
	--End of Step 4
)IE4
--order by classOrder
--End of Step 5

Union All


--Balance Sheet:
Select --[Service Company],
[COA Name],[COA COde],classOrder,RecOrder,
Case when BaseTotal >= 0 then BaseTotal end as Debit,case when BaseTotal < 0 then -BaseTotal end as Credit
From
(
	--Step 4:BaseTotal=BaseDebit-BaseCredit
	select --[Service Company],
	[COA Name],[COA COde],
	BaseDebit-BaseCredit as BaseTotal,classOrder,RecOrder
	From
	(
		--Step 3: Grouping done by [Service Company],[COA Name],[COA COde],classOrder
		Select --[Service Company],
		[COA Name],[COA COde],
		SUM(BaseDebit) BaseDebit,SUM(BaseCredit) BaseCredit,classOrder,RecOrder
		From
		(
			--Step2: replacing null with zero
			Select --[Service Company],
			[COA Name],[COA COde],
			isnull(BaseDebit,0) BaseDebit,isnull(BaseCredit,0) BaseCredit,classOrder,RecOrder
			From
			(
 select --SC.Name as [Service Company],
 COa.Name [COA Name],JD.PostingDate,COA.Code AS [COA COde],'1' AS classOrder,AT.RecOrder,
        case when JD.BaseCurrency=JD.DocCurrency and JD.BaseDebit is null then JD.DocDebit else JD.BaseDebit end  BaseDebit,
        Case when JD.BaseCurrency=JD.DocCurrency and JD.BaseCredit is null then JD.DocCredit else JD.BaseCredit end  BaseCredit--,
   
       -- Case when COA.Class in('Assets','Asset') then 1 
       --when COA.Class='Liabilities' then 2
       --when COA.Class='Equity' then 3
       --when COA.Class='Income' then 4
       --when COA.Class='Expenses' then 5 end as classOrder
    from  Bean.JournalDetail as JD
    join  Bean.Journal as J on J.Id=JD.journalId
    join  Bean.chartOfAccount as COA on COA.Id=JD.COAID
	Left Join Bean.AccountType As AT On AT.Id=COA.AccountTypeId And AT.CompanyId=COA.CompanyId
    join  Common.Company As SC on SC.Id=J.ServiceCompanyId
    where COA.companyId=@CompanyId and COA.ModuleType='Bean' 
	and SC.Name in (select items from dbo.SplitToTable(@ServiceCompany,','))
	and J.DocumentState NOT IN ('Void','Cancelled','Parked','Reset','Recurring')
    
    AND COA.Category='Balance Sheet' AND COA.Name NOT IN ('Retained earnings')--COA.Class IN ('Income','Expenses')
    and   convert(date,JD.PostingDate) Between  @StartDate And @ToDate/*getdate()*/
		 ) BS1
			--End of step2
		) BS2
		group by --[Service Company],
		[COA Name],[COA COde]
		         ,classOrder,RecOrder
		--End of step3
	) BS3
	--End of Step 4
)BS4

) TB1

Group By --[Service Company],
[COA Name],[COA COde],classOrder,RecOrder
order by classOrder,RecOrder
 


 END
GO
