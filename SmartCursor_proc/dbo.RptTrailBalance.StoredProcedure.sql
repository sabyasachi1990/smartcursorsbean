USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[RptTrailBalance]    Script Date: 16-12-2024 9.20.11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

--exec RptTrailBalance @CompanyValue=1257,@ServiceCompany='No MC',@FromDate='2018-01-01',@ToDate='2018-06-24'
CREATE Procedure [dbo].[RptTrailBalance]
@CompanyValue Varchar(100),
@ServiceCompany varchar(max),
@FromDate date,
@ToDate  date
AS
Begin

Declare @CompanyId int
select @CompanyId = dbo.DecryptCompanyValue(@CompanyValue)

--Step 5: If basetotal >= 0 then BaseTotal is showing as Debit else -BaseTotal  is showing as credit
Select [Service Company],[COA Name],[COA COde],Case when BaseTotal >= 0 then BaseTotal end as Debit,case when BaseTotal < 0 then -BaseTotal end as Credit,classOrder
From
(
	--Step 4:BaseTotal=BaseDebit-BaseCredit
	select [Service Company],[COA Name],[COA COde],BaseDebit-BaseCredit as BaseTotal,classOrder
	From
	(
		--Step 3: Grouping done by [Service Company],[COA Name],[COA COde],classOrder
		Select [Service Company],[COA Name],[COA COde],SUM(BaseDebit) BaseDebit,SUM(BaseCredit) BaseCredit,classOrder
		From
		(
			--Step2: replacing null with zero
			Select [Service Company],[COA Name],[COA COde],isnull(BaseDebit,0) BaseDebit,isnull(BaseCredit,0) BaseCredit,classOrder
			From
			(
				--Step1: if both currencies are same and basedebit is null then get docdebit else basedebit.Same approach is applied for basecredit
				select SC.Name as [Service Company],COA.Name as [COA Name],COA.Code as [COA COde],--JD.DocDebit,JD.DocCredit,JD.BaseDebit,JD.BaseCredit,
					   case when JD.BaseCurrency=JD.DocCurrency and JD.BaseDebit is null then JD.DocDebit else JD.BaseDebit end  BaseDebit,
					   Case when JD.BaseCurrency=JD.DocCurrency and JD.BaseCredit is null then JD.DocCredit else JD.BaseCredit end  BaseCredit,
					   /*JD.BaseDebit,JD.BaseCredit,*/
					   /*JD.BaseCurrency,JD.DocCurrency,*/
					   Case when COA.Class in('Assets','Asset') then 1 
							when COA.Class='Liabilities' then 2
							when COA.Class='Equity' then 3
							when COA.Class='Income' then 4
							when COA.Class='Expenses' then 5 end as classOrder
				from  Bean.JournalDetail as JD
				join  Bean.Journal as J on J.Id=JD.journalId
				join  Bean.chartOfAccount as COA on COA.Id=JD.COAID
				join  Common.Company As SC on SC.Id=J.ServiceCompanyId
				where COA.companyId=@CompanyId and COA.ModuleType='Bean' and SC.Name=@ServiceCompany and J.DocumentState<>'Void'--and COA.Id='39944'
				and   convert(date,J.DocDate) between @FromDate and @ToDate 
				--group by SC.Name,COA.Name,COA.Code,COA.Class
				--And  JD.DocCurrency='SGD'
				--End of step1
			) st1
			--End of step2
		) st2
		group by [Service Company],[COA Name],[COA COde],classOrder
		--End of step3
	) st3
	--End of Step 4
)st4
order by classOrder
--End of Step 5

End
GO
