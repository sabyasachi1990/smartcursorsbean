USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[GLparameter]    Script Date: 16-12-2024 9.20.10 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE   Procedure [dbo].[GLparameter]
	@CompanyId INT, @UserName Nvarchar(500)
AS 
Begin 
-----Service Company
--Commented by lokanath on 11-05-2020
 --declare @CompanyValue varchar(100)=65
	-- select distinct SC.Name,SC.Id
	--	From Bean.JournalDetail as JD
	--	Inner Join Bean.Journal as J on J.Id=JD.JournalId
	--	Inner Join Common.Company as SC on SC.Id=J.ServiceCompanyId
	--	Inner Join Bean.ChartOfAccount COA on COA.Id=JD.COAId
	--where COA.CompanyId=@CompanyId 
	--order by SC.Name

	select distinct SC.ShortName as Name,SC.Id
		From Bean.JournalDetail as JD
		Inner Join Bean.Journal as J on J.Id=JD.JournalId
		Inner Join Common.Company as SC on SC.Id=J.ServiceCompanyId
		Inner Join Common.COmpanyUser as CU on SC.ParentId = CU.CompanyId
		Inner Join Common.CompanyUserDetail as CUD on (CUD.ServiceEntityId = SC.Id and CU.Id = CUD.CompanyUserId)
		--Inner Join Bean.ChartOfAccount COA on COA.Id=JD.COAId
	where J.CompanyId=@CompanyId and CU.Username = @UserName
	order by SC.ShortName
----ChartOfAccount
--declare @CompanyValue varchar(100)=1294
	 Select  Name COAName,COAId,SubsidaryCompanyId ServiceCompany,IsBank
	 From
	 (
	  select COA.Name,Case when COA.Class in('Assets','Asset') then 1 
			 when COA.Class='Liabilities' then 2
			 when COA.Class='Equity' then 3
			 when COA.Class='Income' then 4
			 when COA.Class='Expenses' then 5 end as classOrder,COA.Id COAId,
			 A.RecOrder,COA.Code,COA.SubsidaryCompanyId,COA.IsBank
		From Bean.ChartOfAccount as COA 
		Left Join Bean.AccountType A ON COA.AccountTypeId=A.Id And COA.CompanyId=COA.CompanyId
		where COA.CompanyId=@CompanyId --and COA.Name in ('Accounts payables','Accounts Receivables') 
			and COA.ModuleType='Bean' AND COA.Name NOT IN ('Clearing - Payments','Clearing - Receipts','Clearing - Transfers','Opening balance')
			AND IsrealCoa=1 --and COA.Name in (SELECT items FROM dbo.SplitToTable(@COA,',')) 
			
	)dt1
	order by classOrder,RecOrder,Code,Name

--DocType
	select distinct JD.DocType--,SC.Id
		From Bean.JournalDetail as JD
		Inner Join Bean.Journal as J on J.Id=JD.JournalId
		Inner Join Bean.ChartOfAccount COA on COA.Id=JD.COAId
	where COA.CompanyId=@CompanyId
END
GO
