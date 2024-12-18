USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[HTMLRpt_General_Ledger]    Script Date: 16-12-2024 9.20.10 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

  --Declare @CompanyValue Varchar(100)='98',
  --        @FromDate Datetime='2016-01-01',
		--  @ToDate Datetime='2018-09-24',
  --        @COA Nvarchar(MAX)='Accounts payables,revaluation,Accounts payables,Accounts Receivables,Accounts receivables revaluation,Accruals,Accruals revaluation,Advertising,Agency Fund,Amt due from/to director:Director 1,Amt due from/to director:Director 2,Bank Charges,Cash and bank balances revaluation,Clearing,Clearing-Receipt,Closing stock,Commission,Courier and postages,Course fees,Deferred taxation,Deposit 1,Deposits and prepayments revaluation,Depreciation,Directors CPF,Directors fees,Directors remuneration,Dividend Appropriation,Donation,Doubtful Debt expense,Doubtful Debt Provision(AR),Doubtful Debt Provision(OR),Employer CPF,Entertainment and gifts,Exchange Gain/Loss - Realised,Exchange Gain/Loss - Unrealised,Fixed assets revaluation,Fixed deposit,Foreign worker levy,Freight & Handling charges,Furniture and Fittings - Accum Depn,Furniture and Fittings - Cost,I/C,Inf - Clearing(USD),Inf - OCBC23456(SGD),Inf - OCBC87654(USD),Insurance,Interest exp on bank overdraft,Interest exp on finance lease,Interest expense,Interest income,Inventory,Medical fees,Membership and Licence fees,Miscellaneous expenses,Motor Vehicle - Accum Depn,Motor Vehicle - Cost,Office Equipment - Accum Depn,Office Equipment - Cost,Office expenses,Opening stock,Operating lease,Other current assets revaluation,Other current liabilities revaluation,Other expenses,Other income,Other non-current assets revaluation,Other non-current liabilities revaluation,Other payable revaluation,Other payables,Other receivables,Other receivables revaluation,Penalty and fines,Permit fees,Petty Cash,Printing and stationery,Private vehicle expenses,Professional fees,Provision for taxation,Purchases,Renovation - Accum Depn,Renovation - Cost,Repair and Maintenance,Retained earnings,Revenue,Rounding,Rounding Account,SDL,Share Capital,Skill Development Levy,Staff accomodation,Staff CPF,Staff salary,Staff welfare,Storage Rental,Subcontractors/Outsourcing,Tax payable (GST),Telecommunication,Transportation,Travelling,Upkeep of motor vehicles,Utilities,Webhosting',
  --        @ServiceCompany Varchar(MAX)='Axis pvt ltd'

--exec [dbo].[Rpt_General_Ledger_with_FinancialYear_Updated] @CompanyValue='1294',@FromDate='2018-01-01',@ToDate='2018-12-31',
--@COA =N'Accounts payable revaluation, Accounts payables,Accounts Receivables,Accounts receivables revaluation,Accruals,Accruals revaluation,Advertising,Agency Fund,Bank Charges,bea - CVDCVD(SGD),bea - dvddvd(USD),Cash and bank balances revaluation,Clearing,Clearing-Receipt,Commission,Courier and postages,Course fees,Deferred taxation,Deposit 1,Deposits and prepayments revaluation,Depreciation,Directors CPF,Directors fees,Directors remuneration,Dividend Appropriation,Donation,Doubtful Debt expense,Doubtful Debt Provision(AR),Doubtful Debt Provision(OR),Employer CPF,Entertainment and gifts,Exchange Gain/Loss - Realised,Exchange Gain/Loss - Unrealised,Fixed assets revaluation,Fixed deposit,Foreign worker levy,Furniture and Fittings - Accum Depn,Furniture and Fittings - Cost,I/C,Insurance,Interest exp on bank overdraft,Interest exp on finance lease,Interest expense,Interest income,Inventory,Inventory revaluation,JVC - DDTDDT(SGD),JVC - OCBCOCBC(USD),Medical fees,Membership and Licence fees,Miscellaneous expenses,Motor Vehicle - Accum Depn,Motor Vehicle - Cost,Office Equipment - Accum Depn,Office Equipment - Cost,Office expenses,Operating lease,Other current assets revaluation,Other current liabilities revaluation,Other expenses,Other income,Other non-current assets revaluation,Other non-current liabilities revaluation,Other payable revaluation,Other payables,Other receivables,Other receivables revaluation,Penalty and fines,Permit fees,Petty Cash,Printing and stationery,Private vehicle expenses,Professional fees,Provision for taxation,Purchases,Renovation - Accum Depn,Renovation - Cost,Repair and Maintenance,Retained earnings,Revenue,Rounding,Rounding Account,SDL,Share Capital,Soft - DBCDBC(SGD),Soft - hnjhnj(USD),Soft - sobsob(USD),Staff accomodation,Staff CPF,Staff salary,Staff welfare,STN - SGGSGG(USD),STN - VVCVVC(SGD),Subcontractors/Outsourcing,Tax payable (GST),Telecommunication,Transportation,Travelling,Upkeep of motor vehicles,Utilities,Webhosting',
--@ServiceCompany ='Analytics Reports'

--exec [dbo].[Rpt_General_Ledger_with_FinancialYear_Updated] @CompanyValue='134',@FromDate='2018-01-01',@ToDate='2018-12-31',
--@COA ='Accounts payable revaluation,Accounts payables,Accounts Receivables,Accounts receivables revaluation,Accruals,Accruals revaluation,Advertising,Agency Fund,Amt due from/to director:Director 1,Amt due from/to director:Director 2,Bank Charges,Cash and bank balances revaluation,Clearing,Clearing-Receipt,Closing stock,Commission,Courier and postages,Course fees,Deferred taxation,Deposit 1,Deposits and prepayments revaluation,Depreciation,Directors CPF,Directors fees,Directors remuneration,Dividend Appropriation,Donation,Doubtful Debt expense,Doubtful Debt Provision(AR),Doubtful Debt Provision(OR),Employer CPF,Entertainment and gifts,Exchange Gain/Loss - Realised,Exchange Gain/Loss - Unrealised,Fixed assets revaluation,Fixed deposit,Foreign worker levy,Freight & Handling charges,Furniture and Fittings - Accum Depn,Furniture and Fittings - Cost,I/C,Inf - Clearing(USD),Inf - OCBC23456(SGD),Inf - OCBC87654(USD),Insurance,Interest exp on bank overdraft,Interest exp on finance lease,Interest expense,Interest income,Inventory,Medical fees,Membership and Licence fees,Miscellaneous expenses,Motor Vehicle - Accum Depn,Motor Vehicle - Cost,Office Equipment - Accum Depn,Office Equipment - Cost,Office expenses,Opening stock,Operating lease,Other current assets revaluation,Other current liabilities revaluation,Other expenses,Other income,Other non-current assets revaluation,Other non-current liabilities revaluation,Other payable revaluation,Other payables,Other receivables,Other receivables revaluation,Penalty and fines,Permit fees,Petty Cash,Printing and stationery,Private vehicle expenses,Professional fees,Provision for taxation,Purchases,Renovation - Accum Depn,Renovation - Cost,Repair and Maintenance,Retained earnings,Revenue,Rounding,Rounding Account,SDL,Share Capital,Skill Development Levy,Staff accomodation,Staff CPF,Staff salary,Staff welfare,Storage Rental,Subcontractors/Outsourcing,Tax payable (GST),Telecommunication,Transportation,Travelling,Upkeep of motor vehicles,Utilities,Webhosting',
--@ServiceCompany ='InfoWeb Solutions'


CREATE Procedure [dbo].[HTMLRpt_General_Ledger]
@CompanyValue Varchar(100),
@FromDate Datetime,
@ToDate  Datetime,
@COA varchar(MAX),
@ServiceCompany Varchar(MAX)
As
Begin

Declare @CompanyId int
Select @CompanyId = dbo.DecryptCompanyValue(@CompanyValue)
                      /*******step1: moving coa name and category of selected coa's into @COA_Category table variable**********/
Declare  @COA_Category TABLE ([COA Name] NVARCHAR(MAX),Category NVARCHAR(MAX),Code Nvarchar(max),ClassOrder int,RecOrder INT)

Insert Into @COA_Category
Select Name,Category,Code,classOrder,RecOrder
From
(
	Select C.Name,C.Category,C.Code,Case when C.Class in('Assets','Asset') then 1 
							when C.Class='Liabilities' then 2
							when C.Class='Equity' then 3
							when C.Class='Income' then 4
							when C.Class='Expenses' then 5 end as classOrder, A.RecOrder
	From   Bean.ChartOfAccount C
	Left Join Bean.AccountType A ON A.ID=C.AccountTypeId AND A.CompanyId=C.CompanyId
	where  C.CompanyId=@CompanyId and C.ModuleType='Bean'
) as DT1
Where Name  in(select items from dbo.SplitToTable(CONVERT(nvarchar(max), (SELECT @COA FOR XML PATH('')), 1),','))
	Order By RecOrder,classOrder
--Select * from @COA_Category
                     /*************end of step1*******************/

                     /********step2: moving coa names where category in balance sheet into @COA_BalanceSheet**********/

Declare @COA_BalanceSheet table ([COA Name] nvarchar(max),Code Nvarchar(max),ClassOrder int,Recorder INT)

Insert Into @COA_BalanceSheet
Select [COA Name],Code,ClassOrder,RecOrder from @COA_Category where Category='Balance Sheet' order by RecOrder,[COA Name]

--Select * from @COA_BalanceSheet

                       /********End of Step2**********/

                       /********step3: moving coa names where category in Income Statement into @COA_IncomeStatement**********/

Declare @COA_IncomeStatement table ([COA Name] nvarchar(max),Code Nvarchar(max),ClassOrder int,RecOrder Int)

Insert Into @COA_IncomeStatement
Select [COA Name],Code,ClassOrder,RecOrder int from @COA_Category where Category='Income Statement' order by RecOrder,[COA Name]

--Select * from @COA_IncomeStatement

                      /********End of Step3**********/

            /******* Step 4: Declaring variables for RE,IS,BS and assigning values into currosponding variables based on FromDate and ToDate *********/ 

Declare @SystemStartDate Date -- i.e to get system start date for that service company. It gives the first transaction recorded date of the selected service company.

Declare @FromDateYear Bigint --i.e to get year  of FromDate
Declare @ToDateYear Bigint --i.e to get year of ToDate

Declare @FYEFromDate Date --i.e to get Financial year end date for year of FromDate
Declare @FYEToDate Date --i.e to get Financial year end date for year of ToDate

Declare @PreviousFYEFromDate Date--i.e to get Financial year end date for (year-1) of FromDate
Declare @PreviousFYEToDate Date --i.e to get Financial year end date for (year-1) of ToDate

Declare @RetainedEarningsFromDate Date --i.e. to get Retained Earnings FromDate
Declare @RetainedEarningsToDate Date -- i.e to get Retained Earnings ToDate

Declare @BSBroughtForwardFromDate Date-- i.e to get Balance Sheet Brought Forwarded From Date
Declare @BSBroughtForwardToDate Date-- i.e to get Balance Sheet Brought Forwarded To Date
Declare @BSFromDate Date-- i.e to get Balance Sheet From Date
Declare @BSToDate Date-- i.e to get Balance Sheet To Date

Declare @ISBroughtForwardFromDate Date -- i.e to get Income Statement Brought Forwarded From Date
Declare @ISBroughtForwardToDate Date --i.e. to get Income Statement Brought Forwarded To Date
Declare @ISFromDate Date --i.e to get Income Statement From Date
Declare @ISToDate Date -- i.e to get Income Statement To Date

Declare @DaysBetweenDates Bigint -- i.e to get days between FromDate and ToDate

Declare @Bus_Year_End NVarchar(200) -- i.e to get businee year end  of the company
Select @Bus_Year_End= BusinessYearEnd from Common.Localization where CompanyId=@CompanyId
--Print @Bus_Year_End

Select @FromDateYear= YEAR(@FromDate), @ToDateYear=YEAR(@ToDate)  --assigning values to @FromDateYear, @ToDateYear
--Print @FromDateYear, @ToDateYear

  --Assigning @FYEFromDate
Select @FYEFromDate=Cast(@Bus_Year_End+'-'+cast(@FromDateYear as nvarchar) as date) --casting @FromDateYear to nvarchar and resultant is concatinating to @Bus_Year_End.Then the resultant is cast to date
--Print @FYEFromDate

  --Assigning @FYEToDate
Select @FYEToDate=Cast(@Bus_Year_End+'-'+cast(@ToDateYear as nvarchar) as date) --casting @ToDateYear to nvarchar and resultant is concatinating to @Bus_Year_End.Then the resultant is cast to date
--Print @FYEToDate

  --Assigning @PreviousFYEFromDate
Select @PreviousFYEFromDate=DATEADD(year,-1,@FYEFromDate) --going 1 year back from @FYEFromDate
--print @PreviousFYEFromDate

  --Assigning @PreviousFYEToDate
Select @PreviousFYEToDate=DATEADD(year,-1,@FYEToDate) --going 1 year back from @FYEToDate
--print @PreviousFYEToDate

  --Assigning @SystemStartDate value
  Select @SystemStartDate='1900-01-01'

Declare @UserStartDate date --used to get system first transaction date which will be used in B/F balance date.

--Select @UserStartDate=DocDate
--From
--(
--	Select   DocDate,RANK()over (order by docdate) Ranking
--	From
--	(
--		select       distinct convert(date,J.DocDate) DocDate
--		from         Bean.JournalDetail as JD
--		inner join   Bean.Journal as J on J.Id=JD.JournalId
--		Inner Join   Bean.ChartOfAccount COA on COA.Id=JD.COAId
--		Inner Join   Common.Company as SC on SC.Id=J.ServiceCompanyId
--		left join    Common.TermsOfPayment as TP on TP.Id=JD.CreditTermsId
--		where        COA.CompanyId=@CompanyId --and SC.Name=@ServiceCompany
--		            AND J.DocumentState NOT IN ('Void','Cancelled','Parked','Reset')
--	) dt1
--)dt2
--where Ranking=1

Select @UserStartDate = convert(date,Min(J.DocDate))
From  Bean.Journal as J
where J.CompanyId=98 AND J.DocumentState NOT IN ('Void','Cancelled','Parked','Reset')
--Print @UserStartDate

  --Assigning @DaysBetweenDates value
Select @DaysBetweenDates= DATEDIFF(DAY,@FromDate,@ToDate)
--Print @DaysBetweenDates

  --ASSIGNING BALANCE SHEET DATES VALUES
SELECT @BSBroughtForwardFromDate=@SystemStartDate
SELECT @BSBroughtForwardToDate=DATEADD(DAY,-1,@FromDate) --@FROMDATE-1
SELECT @BSFromDate=@FromDate
SELECT @BSToDate=@ToDate
 -- END OF ASSIGNING BALANCE SHEET DATES VALUES

/****** @Bus_Year_End='01-Jan' STARTING POINT *************/
IF @Bus_Year_End='01-Jan'
BEGIN
/**** START of @DaysBetweenDates>=366 Condition ***********/
	IF @DaysBetweenDates>=366 --1
	BEGIN
		IF (@FromDate=@FYEFromDate AND @ToDate=@FYEToDate) --1.1
		BEGIN
			SELECT @RetainedEarningsFromDate=@SystemStartDate
			SELECT @RetainedEarningsToDate=@PreviousFYEToDate

			SELECT @ISBroughtForwardFromDate=@SystemStartDate
			--SELECT @ISBroughtForwardFromDate='1900-01-01'
			SELECT @ISBroughtForwardToDate=@PreviousFYEToDate
			--SELECT @ISFromDate=DATEADD(DAY,1,@PreviousFYEToDate) --i.e.@TDTY1+1
			SELECT @ISFromDate=@FromDate
			SELECT @ISToDate=@ToDate
		END -- END OF 1.1
		ELSE IF (@FromDate=@FYEFromDate AND @ToDate>@FYEToDate) --1.2
		BEGIN
			SELECT @RetainedEarningsFromDate=@SystemStartDate
			SELECT @RetainedEarningsToDate=@FYEToDate

			SELECT @ISBroughtForwardFromDate=@SystemStartDate
			--SELECT @ISBroughtForwardFromDate='1900-01-01'
			SELECT @ISBroughtForwardToDate=@FYEToDate
			SELECT @ISFromDate=DATEADD(DAY,1,@FYEToDate) --i.e.@FYEToDate+1
			SELECT @ISToDate=@ToDate
		END -- END OF 1.2
		ELSE IF (@FromDate > @FYEFromDate AND @ToDate=@FYEToDate) --1.3
		BEGIN
			SELECT @RetainedEarningsFromDate=@SystemStartDate
			SELECT @RetainedEarningsToDate=@PreviousFYEToDate

			SELECT @ISBroughtForwardFromDate='1900-01-01'
			SELECT @ISBroughtForwardToDate=@PreviousFYEToDate
			SELECT @ISFromDate=DATEADD(DAY,1,@PreviousFYEToDate) --i.e.@TDTY1+1
			SELECT @ISToDate=@ToDate
		END -- END OF 1.3
		ELSE IF (@FromDate > @FYEFromDate AND @ToDate > @FYEToDate) --1.4
		BEGIN
			SELECT @RetainedEarningsFromDate=@SystemStartDate
			SELECT @RetainedEarningsToDate=@FYEToDate

			SELECT @ISBroughtForwardFromDate='1900-01-01'
			SELECT @ISBroughtForwardToDate=@FYEToDate
			SELECT @ISFromDate=DATEADD(DAY,1,@FYEToDate) --i.e.@FYEToDate+1
			SELECT @ISToDate=@ToDate
		END -- END OF 1.4
	END -- END OF 1
	/**** End of @DaysBetweenDates>=366 Condition ***********/

	/**** starting of @DaysBetweenDates<366 *******/
	ELSE
	BEGIN
	/****** STARTING OF @FromDateYear<>@ToDateYear IN @DaysBetweenDates<366 CONDITION ********/ 
		IF @FromDateYear<>@ToDateYear --2
		BEGIN
			IF (@FromDate > @FYEFromDate AND @ToDate=@FYEToDate) --2.1
			BEGIN
				SELECT @RetainedEarningsFromDate=@SystemStartDate
				SELECT @RetainedEarningsToDate=@FYEFromDate

				SELECT @ISBroughtForwardFromDate=DATEADD(DAY,1,@FYEFromDate) --i.e. @FYEFromDate+1
				SELECT @ISBroughtForwardToDate=DATEADD(DAY,-1,@FromDate) --i.e. @FD-1
				SELECT @ISFromDate=@FromDate
				SELECT @ISToDate=@ToDate
			END -- END OF 2.1
			ELSE IF (@FromDate > @FYEFromDate AND @ToDate > @FYEToDate) --2.2
			BEGIN
				SELECT @RetainedEarningsFromDate=@SystemStartDate
				SELECT @RetainedEarningsToDate=@FYEToDate

				SELECT @ISBroughtForwardFromDate='1900-01-01'
				SELECT @ISBroughtForwardToDate=@FYEToDate
				SELECT @ISFromDate=DATEADD(DAY,1,@FYEToDate) --i.e. @FYEToDate+1
				SELECT @ISToDate=@ToDate
			END -- END OF 2.2
		END -- END OF 2
	/****** ENDING OF @FromDateYear<>@ToDateYear IN @DaysBetweenDates<366 CONDITION ********/

	/****** STARTING OF @FromDateYear=@ToDateYear IN @DaysBetweenDates<366 CONDITION ********/
		ELSE IF @FromDateYear=@ToDateYear --3
		BEGIN
			IF(@FromDate=@FYEFromDate AND @ToDate=@FYEFromDate AND @FromDate=@ToDate) --3.1
			BEGIN
				SELECT @RetainedEarningsFromDate=@SystemStartDate
				SELECT @RetainedEarningsToDate=@PreviousFYEFromDate

				SELECT @ISBroughtForwardFromDate=DATEADD(DAY,1,@PreviousFYEFromDate) --i.e. @PreviousFYEFromDate+1
				SELECT @ISBroughtForwardToDate=DATEADD(DAY,-1,@FromDate) -- i.e.@FROMDATE-1
				SELECT @ISFromDate=@FromDate
				SELECT @ISToDate=@ToDate
			END --END OF 3.1
			ELSE IF(@FromDate > @FYEFromDate AND @ToDate > @FYEFromDate AND @FromDate=@ToDate) --3.2
			BEGIN
				SELECT @RetainedEarningsFromDate=@SystemStartDate
				SELECT @RetainedEarningsToDate=@FYEFromDate

				SELECT @ISBroughtForwardFromDate=DATEADD(DAY,1,@FYEFromDate) -- i.e. @FYEFromDate+1
				SELECT @ISBroughtForwardToDate=DATEADD(DAY,-1,@FromDate) -- i.e.@FromDate-1
				SELECT @ISFromDate=@FromDate
				SELECT @ISToDate=@ToDate
			END -- END OF 3.2
			ELSE IF(@FromDate=@FYEFromDate AND @ToDate > @FYEFromDate) --3.3
			BEGIN
				SELECT @RetainedEarningsFromDate=@SystemStartDate
				SELECT @RetainedEarningsToDate=@FYEFromDate

				SELECT @ISBroughtForwardFromDate='1900-01-01'
				SELECT @ISBroughtForwardToDate=@FYEFromDate
				SELECT @ISFromDate=DATEADD(DAY,1,@FYEFromDate) --i.e. @FYEFromDate+1
				SELECT @ISToDate=@ToDate
			END -- END OF 3.3
			ELSE IF (@FromDate > @FYEFromDate AND @ToDate > @FYEFromDate) --3.4
			BEGIN
				SELECT @RetainedEarningsFromDate=@SystemStartDate
				SELECT @RetainedEarningsToDate=@FYEFromDate

				SELECT @ISBroughtForwardFromDate=DATEADD(DAY,1,@FYEFromDate) --i.e. @FYEFromDate+1
				SELECT @ISBroughtForwardToDate=DATEADD(DAY,-1,@FromDate) --i.e. @FromDate-1
				SELECT @ISFromDate=@FromDate
				SELECT @ISToDate=@ToDate
			END -- END OF 3.4
		END -- END OF 3
	/****** ENDING OF @FromDateYear=@ToDateYear IN @DaysBetweenDates<366 CONDITION ********/
	END
	/**** Endifing of @DaysBetweenDates<366 *******/
END
/****** @Bus_Year_End='01-Jan' ENDING POINT *************/	

/****** @Bus_Year_End='31-Dec' STARTING POINT *************/
ELSE IF @Bus_Year_End='31-Dec'
BEGIN
  /**** START of @DaysBetweenDates>=366 Condition ***********/
	IF @DaysBetweenDates >=366  --1
	BEGIN
		IF(@FromDate < @FYEFromDate AND @ToDate < @FYEToDate) --1.1
		BEGIN
			SELECT @RetainedEarningsFromDate=@SystemStartDate
			SELECT @RetainedEarningsToDate=@PreviousFYEToDate

			SELECT @ISBroughtForwardFromDate='1900-01-01'
			SELECT @ISBroughtForwardToDate=@PreviousFYEToDate
			SELECT @ISFromDate=DATEADD(DAY,1,@PreviousFYEToDate) --i.e. @PreviousFYEToDate+1
			SELECT @ISToDate=@ToDate
		END -- END OF 1.1
		ELSE IF(@FromDate < @FYEFromDate AND @ToDate=@FYEToDate) --1.2
		BEGIN
			SELECT @RetainedEarningsFromDate=@SystemStartDate
			SELECT @RetainedEarningsToDate=@PreviousFYEToDate

			SELECT @ISBroughtForwardFromDate='1900-01-01'
			SELECT @ISBroughtForwardToDate=@PreviousFYEToDate
			SELECT @ISFromDate=DATEADD(DAY,1,@PreviousFYEToDate) --i.e. @PreviousFYEToDate+1
			SELECT @ISToDate=@ToDate
		END -- END OF 1.2
		ELSE IF(@FromDate=@FYEFromDate AND @ToDate < @FYEToDate) --1.3
		BEGIN
			SELECT @RetainedEarningsFromDate=@SystemStartDate
			SELECT @RetainedEarningsToDate=@PreviousFYEToDate

			SELECT @ISBroughtForwardFromDate='1900-01-01'
			SELECT @ISBroughtForwardToDate=@PreviousFYEToDate
			SELECT @ISFromDate=DATEADD(DAY,1,@PreviousFYEToDate) --i.e. @PreviousFYEToDate+1
			SELECT @ISToDate=@ToDate
		END -- END OF 1.3
		ELSE IF(@FromDate=@FYEFromDate AND @ToDate=@FYEToDate) --1.4
		BEGIN
			SELECT @RetainedEarningsFromDate=@SystemStartDate
			SELECT @RetainedEarningsToDate=@PreviousFYEToDate

			SELECT @ISBroughtForwardFromDate='1900-01-01'
			SELECT @ISBroughtForwardToDate=@PreviousFYEToDate
			SELECT @ISFromDate=DATEADD(DAY,1,@PreviousFYEToDate) --i.e. @PreviousFYEToDate+1
			SELECT @ISToDate=@ToDate
		END -- END OF 1.4
	END -- END OF 1
	/**** End of @DaysBetweenDates>=366 Condition ***********/

	/**** STARTING of @DaysBetweenDates<366 *******/
	ELSE
	BEGIN
	/****** STARTING OF @FromDateYear<>@ToDateYear CONDITION IN @DaysBetweenDates<366 CONDITION ********/
		IF(@FromDateYear<>@ToDateYear) --START OF 2
		BEGIN
			IF(@FromDate < @FYEFromDate AND @ToDate < @FYEToDate) --2.1
			BEGIN
				SELECT @RetainedEarningsFromDate=@SystemStartDate
				SELECT @RetainedEarningsToDate=@PreviousFYEToDate

				SELECT @ISBroughtForwardFromDate='1900-01-01'
				SELECT @ISBroughtForwardToDate=@PreviousFYEToDate
				SELECT @ISFromDate=DATEADD(DAY,1,@PreviousFYEToDate) --i.e. @PreviousFYEToDate+1
				SELECT @ISToDate=@ToDate
			END  --END OF 2.1
			ELSE IF(@FromDate=@FYEFromDate AND @ToDate < @FYEToDate) --2.2
			BEGIN
				SELECT @RetainedEarningsFromDate=@SystemStartDate
				SELECT @RetainedEarningsToDate=@PreviousFYEToDate

				SELECT @ISBroughtForwardFromDate='1900-01-01'
				SELECT @ISBroughtForwardToDate=@PreviousFYEToDate
				SELECT @ISFromDate=DATEADD(DAY,1,@PreviousFYEToDate) --i.e.@PreviousFYEToDate+1
				SELECT @ISToDate=@ToDate
			END -- END OF 2.2
		END --END OF 2
	/****** ENDING OF @FromDateYear<>@ToDateYear CONDITION IN @DaysBetweenDates<366 CONDITION ********/

	/****** STARTING OF @FromDateYear=@ToDateYear CONDITION IN @DaysBetweenDates<366 CONDITION ********/
		ELSE IF(@FromDateYear=@ToDateYear)  -- START 3
		BEGIN
			IF(@FromDate = @FYEFromDate AND @ToDate=@FYEFromDate AND @FromDate=@ToDate) --3.1
			BEGIN
				SELECT @RetainedEarningsFromDate=@SystemStartDate
				SELECT @RetainedEarningsToDate=@PreviousFYEToDate

				SELECT @ISBroughtForwardFromDate=DATEADD(DAY,1,@PreviousFYEFromDate) --i.e. @PreviousFYEFromDate+1
				SELECT @ISBroughtForwardToDate=DATEADD(DAY,-1,@FromDate) --i.e. @FD-1
				SELECT @ISFromDate=@FromDate
				SELECT @ISToDate=@ToDate
			END  --END  OF 3.1
			ELSE IF(@FromDate < @FYEFromDate AND @ToDate < @FYEFromDate AND @FromDate=@ToDate) --3.2
			BEGIN
				SELECT @RetainedEarningsFromDate=@SystemStartDate
				SELECT @RetainedEarningsToDate=@PreviousFYEToDate

				SELECT @ISBroughtForwardFromDate=DATEADD(DAY,1,@PreviousFYEToDate) --i.e. @PreviousFYEToDate+1
				SELECT @ISBroughtForwardToDate=DATEADD(DAY,-1,@FromDate) --i.e. @FromDate-1
				SELECT @ISFromDate=@FromDate
				SELECT @ISToDate=@ToDate
			END -- END OF 3.2
			ELSE IF(@FromDate < @FYEFromDate AND @ToDate < @FYEFromDate AND @FromDate<>DATEADD(DAY,1,@PreviousFYEFromDate)) --3.3
			BEGIN
				SELECT @RetainedEarningsFromDate=@SystemStartDate
				SELECT @RetainedEarningsToDate=@PreviousFYEToDate

				SELECT @ISBroughtForwardFromDate=DATEADD(DAY,1,@PreviousFYEToDate) --i.e. @PreviousFYEToDate+1
				SELECT @ISBroughtForwardToDate=DATEADD(DAY,-1,@FromDate) --i.e @FromDate-1
				SELECT @ISFromDate=@FromDate
				SELECT @ISToDate=@ToDate
			END --END OF 3.3 
			ELSE IF(@FromDate < @FYEFromDate AND @ToDate=@FYEFromDate AND @FromDate<>DATEADD(DAY,1,@PreviousFYEFromDate)) --3.4
			BEGIN
				SELECT @RetainedEarningsFromDate=@SystemStartDate
				SELECT @RetainedEarningsToDate=@PreviousFYEToDate

				SELECT @ISBroughtForwardFromDate=DATEADD(DAY,1,@PreviousFYEToDate) --i.e. @PreviousFYEToDate+1
				SELECT @ISBroughtForwardToDate=DATEADD(DAY,-1,@FromDate) --i.e. @FromDate-1
				SELECT @ISFromDate=@FromDate
				SELECT @ISToDate=@ToDate
			END --END OF 3.4
			ELSE IF(@FromDate < @FYEFromDate AND @ToDate < @FYEFromDate AND @FromDate=DATEADD(DAY,1,@PreviousFYEFromDate)) --3.5
			BEGIN
				SELECT @RetainedEarningsFromDate=@SystemStartDate
				SELECT @RetainedEarningsToDate=@PreviousFYEFromDate

				SELECT @ISBroughtForwardFromDate='1900-01-01'
				SELECT @ISBroughtForwardToDate=@PreviousFYEFromDate
				SELECT @ISFromDate=@FromDate
				SELECT @ISToDate=@ToDate
			END --END OF 3.5 
			ELSE IF(@FromDate < @FYEFromDate AND @ToDate=@FYEFromDate AND @FromDate=DATEADD(DAY,1,@PreviousFYEFromDate)) --3.6
			BEGIN
				SELECT @RetainedEarningsFromDate=@SystemStartDate
				SELECT @RetainedEarningsToDate=@PreviousFYEFromDate

				SELECT @ISBroughtForwardFromDate='1900-01-01'
				SELECT @ISBroughtForwardToDate=@PreviousFYEFromDate
				SELECT @ISFromDate=@FromDate
				SELECT @ISToDate=@ToDate
			END --END OF 3.6
		END -- END OF 3
	/****** ENDING OF @FromDateYear=@ToDateYear CONDITION IN @DaysBetweenDates<366 CONDITION ********/
	END
	/**** Endifing of @DaysBetweenDates<366 *******/
END

/****** @Bus_Year_End='31-Dec' ENDING POINT *************/	

/****** @Bus_Year_End NOT IN ('31-Dec','01-Jan') STARTING POINT *************/	

ELSE 
BEGIN
     /**** START of @DaysBetweenDates>=365 Condition ***********/
	IF @DaysBetweenDates >=365  --1
	BEGIN
		IF(@FromDate < @FYEFromDate AND @ToDate < @FYEToDate) --1.1
		BEGIN
			SELECT @RetainedEarningsFromDate=@SystemStartDate
			SELECT @RetainedEarningsToDate=@PreviousFYEToDate

			SELECT @ISBroughtForwardFromDate='1900-01-01'
			SELECT @ISBroughtForwardToDate=@PreviousFYEToDate
			SELECT @ISFromDate=DATEADD(DAY,1,@PreviousFYEToDate) --i.e. @PreviousFYEToDate+1
			SELECT @ISToDate=@ToDate
		END --END OF 1.1
		ELSE IF(@FromDate > @FYEFromDate AND @ToDate >@FYEToDate) --1.2
		BEGIN
			SELECT @RetainedEarningsFromDate=@SystemStartDate
			SELECT @RetainedEarningsToDate=@FYEToDate

			SELECT @ISBroughtForwardFromDate='1900-01-01'
			SELECT @ISBroughtForwardToDate=@FYEToDate
			SELECT @ISFromDate=DATEADD(DAY,1,@FYEToDate) --i.e. @FYEToDate+1
			SELECT @ISToDate=@ToDate
		END -- END OF 1.2
		ELSE IF (@FromDate < @FYEFromDate AND @ToDate > @FYEToDate) --1.3.1
		BEGIN
			SELECT @RetainedEarningsFromDate=@SystemStartDate
			SELECT @RetainedEarningsToDate=@FYEToDate

			SELECT @ISBroughtForwardFromDate='1900-01-01'
			SELECT @ISBroughtForwardToDate=@FYEToDate
			SELECT @ISFromDate=DATEADD(DAY,1,@FYEToDate) --i.e. @FYEToDate+1
			SELECT @ISToDate=@ToDate
		END --1.3.1
		ELSE IF(@FromDate > @FYEFromDate AND @ToDate < @FYEToDate) --1.3.2
		BEGIN
			SELECT @RetainedEarningsFromDate=@SystemStartDate
			SELECT @RetainedEarningsToDate=@PreviousFYEToDate

			SELECT @ISBroughtForwardFromDate='1900-01-01'
			SELECT @ISBroughtForwardToDate=@PreviousFYEToDate
			SELECT @ISFromDate=DATEADD(DAY,1,@PreviousFYEToDate) --i.e. @PreviousFYEToDate+1
			SELECT @ISToDate=@ToDate
		END -- END OF 1.3.2
		ELSE IF(@FromDate < @FYEFromDate AND @ToDate= @FYEToDate) --1.4
		BEGIN
			SELECT @RetainedEarningsFromDate=@SystemStartDate
			SELECT @RetainedEarningsToDate=@PreviousFYEToDate

			SELECT @ISBroughtForwardFromDate='1900-01-01'
			SELECT @ISBroughtForwardToDate=@PreviousFYEToDate
			SELECT @ISFromDate=DATEADD(DAY,1,@PreviousFYEToDate) --i.e. @PreviousFYEToDate+1
			SELECT @ISToDate=@ToDate
		END --END OF 1.4
		ELSE IF(@FromDate > @FYEFromDate AND @ToDate=@FYEToDate) --1.5
		BEGIN
			SELECT @RetainedEarningsFromDate=@SystemStartDate
			SELECT @RetainedEarningsToDate=@PreviousFYEToDate

			SELECT @ISBroughtForwardFromDate='1900-01-01'
			SELECT @ISBroughtForwardToDate=@PreviousFYEToDate
			SELECT @ISFromDate=DATEADD(DAY,1,@PreviousFYEToDate) -- i.e. @PreviousFYEToDate+1
			SELECT @ISToDate=@ToDate
		END -- END OF 1.5
		ELSE IF(@FromDate = @FYEFromDate AND @ToDate = @FYEToDate) --1.6
		BEGIN
			SELECT @RetainedEarningsFromDate=@SystemStartDate
			SELECT @RetainedEarningsToDate=@PreviousFYEToDate

			SELECT @ISBroughtForwardFromDate='1900-01-01'
			SELECT @ISBroughtForwardToDate=@PreviousFYEToDate
			SELECT @ISFromDate=DATEADD(DAY,1,@PreviousFYEToDate) --i.e. @PreviousFYEToDate+1
			SELECT @ISToDate=@ToDate
		END --END OF 1.6
		ELSE IF(@FromDate = @FYEFromDate AND @ToDate < @FYEToDate) --1.7
		BEGIN
			SELECT @RetainedEarningsFromDate=@SystemStartDate
			SELECT @RetainedEarningsToDate=@PreviousFYEToDate

			SELECT @ISBroughtForwardFromDate='1900-01-01'
			SELECT @ISBroughtForwardToDate=@PreviousFYEToDate
			SELECT @ISFromDate=DATEADD(DAY,1,@PreviousFYEToDate) --i.e. @PreviousFYEToDate+1
			SELECT @ISToDate=@ToDate
		END -- END OF 1.7
		ELSE IF(@FromDate = @FYEFromDate AND @ToDate > @FYEToDate) --1.8
		BEGIN
			SELECT @RetainedEarningsFromDate=@SystemStartDate
			SELECT @RetainedEarningsToDate=@FYEToDate

			SELECT @ISBroughtForwardFromDate='1900-01-01'
			SELECT @ISBroughtForwardToDate=@FYEToDate
			SELECT @ISFromDate=DATEADD(DAY,1,@FYEToDate) --i.e.@FYEToDate+1
			SELECT @ISToDate=@ToDate
		END --END OF 1.8
	END -- END OF 1
	/**** END of @DaysBetweenDates>=365 Condition ***********/

	/**** STARTING of @DaysBetweenDates<365 *******/
	ELSE
	BEGIN
	   /****** STARTING OF @FromDateYear<>@ToDateYear CONDITION IN @DaysBetweenDates<365 CONDITION ********/
		IF (@FromDateYear<>@ToDateYear) --2
		BEGIN
			IF(@FromDate < @FYEFromDate AND @ToDate < @FYEToDate) --2.1
			BEGIN
				SELECT @RetainedEarningsFromDate=@SystemStartDate
				SELECT @RetainedEarningsToDate=@PreviousFYEToDate

				SELECT @ISBroughtForwardFromDate='1900-01-01'
				SELECT @ISBroughtForwardToDate=@FYEFromDate
				SELECT @ISFromDate=DATEADD(DAY,1,@FYEFromDate) --i.e.@FYEFromDate+1
				SELECT @ISToDate=@ToDate
			END --END OF 2.1
			ELSE IF(@FromDate = @FYEFromDate AND @ToDate < @FYEToDate) --2.2
			BEGIN
				SELECT @RetainedEarningsFromDate=@SystemStartDate
				SELECT @RetainedEarningsToDate=@FromDate

				SELECT @ISBroughtForwardFromDate='1900-01-01'
				SELECT @ISBroughtForwardToDate=@FYEFromDate
				SELECT @ISFromDate=DATEADD(DAY,1,@FYEFromDate) --i.e.@FYEFromDate+1
				SELECT @ISToDate=@ToDate
			END --END OF 2.2
			ELSE IF(@FromDate > @FYEFromDate AND @ToDate < @FYEToDate) --2.3
			BEGIN
				SELECT @RetainedEarningsFromDate=@SystemStartDate
				SELECT @RetainedEarningsToDate=@FYEFromDate

				SELECT @ISBroughtForwardFromDate=DATEADD(DAY,1,@FYEFromDate) --i.e. @FYEFromDate+1
				SELECT @ISBroughtForwardToDate=DATEADD(DAY,-1,@FromDate) --i.e. @FromDate-1
				SELECT @ISFromDate=@FromDate
				SELECT @ISToDate=@ToDate
			END --END OF 2.3
			ELSE IF(@FromDate >@FYEFromDate AND @ToDate=@FYEToDate) --2.4
			BEGIN
				SELECT @RetainedEarningsFromDate=@SystemStartDate
				SELECT @RetainedEarningsToDate=@FYEFromDate

				SELECT @ISBroughtForwardFromDate=DATEADD(DAY,1,@FYEFromDate) --i.e. @FYEFromDate+1
				SELECT @ISBroughtForwardToDate=DATEADD(DAY,-1,@FromDate) --i.e.@FromDate-1
				SELECT @ISFromDate=@FromDate
				SELECT @ISToDate=@ToDate
			END --END OF 2.4
			ELSE IF(@FromDate > @FYEFromDate AND @ToDate > @FYEToDate) --2.5
			BEGIN
				SELECT @RetainedEarningsFromDate=@SystemStartDate
				SELECT @RetainedEarningsToDate=@FYEToDate

				SELECT @ISBroughtForwardFromDate='1900-01-01'
				SELECT @ISBroughtForwardToDate=@FYEToDate
				SELECT @ISFromDate=DATEADD(DAY,1,@FYEToDate) --i.e. @FYEToDate+1
				SELECT @ISToDate=@ToDate
			END --END OF 2.5

		END -- END OF 2
		/****** ENDING OF @FromDateYear<>@ToDateYear CONDITION IN @DaysBetweenDates<365 CONDITION ********/

		/****** STARTING OF @FromDateYear=@ToDateYear CONDITION IN @DaysBetweenDates<365 CONDITION ********/
		ELSE IF(@FromDateYear=@ToDateYear) --3
		BEGIN
			IF(@FromDate < @FYEFromDate AND @ToDate < @FYEFromDate AND @FromDate<>@ToDate) --3.1
			BEGIN
				SELECT @RetainedEarningsFromDate=@SystemStartDate
				SELECT @RetainedEarningsToDate=@PreviousFYEFromDate
				
				SELECT @ISBroughtForwardFromDate=DATEADD(DAY,1,@PreviousFYEFromDate) -- i.e. @PreviousFYEFromDate+1
				SELECT @ISBroughtForwardToDate=DATEADD(DAY,-1,@FromDate) --i.e @FromDate-1
				SELECT @ISFromDate=@FromDate
				SELECT @ISToDate=@ToDate
			END -- END OF 3.1
			ELSE IF(@FromDate < @FYEFromDate AND @ToDate = @FYEFromDate) --3.2
			BEGIN
				SELECT @RetainedEarningsFromDate=@SystemStartDate
				SELECT @RetainedEarningsToDate=@PreviousFYEFromDate

				SELECT @ISBroughtForwardFromDate=DATEADD(DAY,1,@PreviousFYEFromDate) --i.e. @PreviousFYEFromDate+1
				SELECT @ISBroughtForwardToDate=DATEADD(DAY,-1,@FromDate) --i.e @FromDate-1
				SELECT @ISFromDate=@FromDate
				SELECT @ISToDate=@ToDate
			END --END OF 3.2
			ELSE IF(@FromDate < @FYEFromDate AND @ToDate > @FYEFromDate) -- 3.3
			BEGIN
				SELECT @RetainedEarningsFromDate=@SystemStartDate
				SELECT @RetainedEarningsToDate=@FYEFromDate

				SELECT @ISBroughtForwardFromDate='1900-01-01'
				SELECT @ISBroughtForwardToDate=@FYEFromDate
				SELECT @ISFromDate=DATEADD(DAY,1,@FYEFromDate) --i.e.@FYEFromDate+1
				SELECT @ISToDate=@ToDate
			END --END OF 3.3
			ELSE IF(@FromDate = @FYEFromDate AND @ToDate > @FYEFromDate) --3.4
			BEGIN
				SELECT @RetainedEarningsFromDate=@SystemStartDate
				SELECT @RetainedEarningsToDate=@FYEFromDate

				SELECT @ISBroughtForwardFromDate='1900-01-01'
				SELECT @ISBroughtForwardToDate=@FYEFromDate
				SELECT @ISFromDate=DATEADD(DAY,1,@FYEFromDate) --i.e. @FYEFromDate+1
				SELECT @ISToDate=@ToDate
			END -- END OF 3.4
			ELSE IF(@FromDate = @FYEFromDate AND @ToDate=@FYEFromDate AND @FromDate=@ToDate) --3.5
			BEGIN
				SELECT @RetainedEarningsFromDate=@SystemStartDate
				SELECT @RetainedEarningsToDate=@PreviousFYEFromDate

				SELECT @ISBroughtForwardFromDate=DATEADD(DAY,1,@PreviousFYEFromDate) --i.e. @PreviousFYEFromDate+1
				SELECT @ISBroughtForwardToDate=DATEADD(DAY,-1,@FromDate) --i.e. @FromDate-1
				SELECT @ISFromDate=@FromDate
				SELECT @ISToDate=@ToDate
			END --END OF 3.5
			ELSE IF(@FromDate > @FYEFromDate AND @ToDate > @FYEToDate AND @FromDate<>@ToDate) --3.6
			BEGIN
				SELECT @RetainedEarningsFromDate=@SystemStartDate
				SELECT @RetainedEarningsToDate=@FYEFromDate

				SELECT @ISBroughtForwardFromDate=DATEADD(DAY,1,@FYEFromDate) --i.e. @FYEFromDate+1
				SELECT @ISBroughtForwardToDate=DATEADD(DAY,-1,@FromDate) --i.e. @FromDate-1
				SELECT @ISFromDate=@FromDate
				SELECT @ISToDate=@ToDate
			END --END OF 3.6
			ELSE IF(@FromDate < @FYEFromDate AND @ToDate < @FYEFromDate AND @FromDate=@ToDate) --3.7
			BEGIN
				SELECT @RetainedEarningsFromDate=@SystemStartDate
				SELECT @RetainedEarningsToDate=@PreviousFYEFromDate

				SELECT @ISBroughtForwardFromDate=DATEADD(DAY,1,@PreviousFYEFromDate) --i.e. @PreviousFYEFromDate+1
				SELECT @ISBroughtForwardToDate=DATEADD(DAY,-1,@FromDate) --i.e. @FromDate-1
				SELECT @ISFromDate=@FromDate
				SELECT @ISToDate=@ToDate
			END -- END OF 3.7
			ELSE IF(@FromDate > @FYEFromDate AND @ToDate > @FYEFromDate AND @FromDate=@ToDate) --3.8
			BEGIN
				SELECT @RetainedEarningsFromDate=@SystemStartDate
				SELECT @RetainedEarningsToDate=@FYEFromDate

				SELECT @ISBroughtForwardFromDate=DATEADD(DAY,1,@FYEFromDate) --i.e. @FYEFromDate+1
				SELECT @ISBroughtForwardToDate=DATEADD(DAY,-1,@FromDate) --i.e. @FromDate-1
				SELECT @ISFromDate=@FromDate
				SELECT @ISToDate=@ToDate
			END -- END OF 3.8
		END --END OF 3
		/****** ENDING OF @FromDateYear=@ToDateYear CONDITION IN @DaysBetweenDates<365 CONDITION ********/
	END
	/**** Endifing of @DaysBetweenDates<365 *******/
END

/****** @Bus_Year_End NOT IN ('31-Dec','01-Jan') ENDING POINT *************/	

--PRINT @RetainedEarningsFromDate
--PRINT @RetainedEarningsToDate
--PRINT @ISBroughtForwardFromDate
--PRINT @ISBroughtForwardToDate
--PRINT @ISFromDate
--PRINT @ISToDate
--PRINT @BSBroughtForwardFromDate
--PRINT @BSBroughtForwardToDate
--PRINT @BSFromDate
--PRINT @BSToDate

                                                  /******* End of Step4 ***************/

                                     /*******Step 5 : Getting SegmentStatus,No Supporting Documents, Bank Reconciliation and MultiCurrencySetting**********/

--Here we declare the table variables to store intermediate and final resultant data

-- @GLReport intermediate table variable is used to store data after getting each coa data by applying cursor code and other conditions
Declare @GLReport Table( [COA Name] NVARCHAR(MAX),RecOrder INT,DocType NVARCHAR(MAX),DocSubType Nvarchar(max),DocumentDescription Nvarchar(max),DocDate datetime2,DocNo Nvarchar(max),SystemRefNo NVarchar(max),ServiceCompany Nvarchar(max),EntityName NVarchar(max),BaseDebit money,BaseCredit money,BaseBalance money,ExchangeRate decimal(15,10),BaseCurrency Nvarchar(max),DocCurrency NVarchar(max),DocDebit money,DocCredit money,DocBalance money,SegmentCategory1 Nvarchar(max),SegmentCategory2 NVarchar(max),MCS_Status int,SegmentStatus int,CorrAccount NVarchar(max),[Entity Type] Nvarchar(max),[Vendor Type] Nvarchar(max),PONo NVarchar(max),Nature Nvarchar(max),[CreditTerms(Days)] float,DueDate datetime2,[NSD ISCHECKED] int,[NO SUPPORT DOC] NVarchar(20),ItemCode NVarchar(max),ItemDescription NVarchar(max),Qty float,Unit NVarchar(100),UnitPrice money,[DiscountType] NVarchar(10),Discount float,[BRM ISCHECKED] int,[ALLOWABLE/DISALLOWABLE] NVarchar(max),[Bank Clearing] datetime2,ModeOfReceipt NVarchar(200),ReversalDate datetime2,[Bank Reconcile] NVarchar(20),[Reversal Doc Ref] NVarchar(max),ClearingStatus Nvarchar(100),[Created By] NVarchar(600),[Created On] datetime2,[Modified By] NVarchar(600),[Modified On] datetime2,COA_Parameter NVarchar(max),classOrder BIGINT)

--@GLReport1 intermediate table variable is used to get data from @GLReport. It is having same columns from @GLReport with same data type.
--And at starting point we declare a column with name 'Number' with identity.
Declare @GLReport1 Table(Number Bigint identity(1,1), [COA Name] NVARCHAR(MAX),RecOrder INT,DocType NVARCHAR(MAX),DocSubType Nvarchar(max),DocumentDescription Nvarchar(max),DocDate datetime2,DocNo Nvarchar(max),SystemRefNo NVarchar(max),ServiceCompany Nvarchar(max),EntityName NVarchar(max),BaseDebit money,BaseCredit money,BaseBalance money,ExchangeRate decimal(15,10),BaseCurrency Nvarchar(max),DocCurrency NVarchar(max),DocDebit money,DocCredit money,DocBalance money,SegmentCategory1 Nvarchar(max),SegmentCategory2 NVarchar(max),MCS_Status int,SegmentStatus int,CorrAccount NVarchar(max),[Entity Type] Nvarchar(max),[Vendor Type] Nvarchar(max),PONo NVarchar(max),Nature Nvarchar(max),[CreditTerms(Days)] float,DueDate datetime2,[NSD ISCHECKED] int,[NO SUPPORT DOC] NVarchar(20),ItemCode NVarchar(max),ItemDescription NVarchar(max),Qty float,Unit NVarchar(100),UnitPrice money,[DiscountType] NVarchar(10),Discount float,[BRM ISCHECKED] int,[ALLOWABLE/DISALLOWABLE] NVarchar(max),[Bank Clearing] datetime2,ModeOfReceipt NVarchar(200),ReversalDate datetime2,[Bank Reconcile] NVarchar(20),[Reversal Doc Ref] NVarchar(max),ClearingStatus Nvarchar(100),[Created By] NVarchar(600),[Created On] datetime2,[Modified By] NVarchar(600),[Modified On] datetime2,COA_Parameter NVarchar(max),classOrder BIGINT)

--@GLReport_AfterAdding_SubTotal is store final result.It is having same columns from @GLReport with same data type.
--And finally it is having a column  named as IsSubTotal which is identify to whether the record is belongs to subtotal or not.
Declare @GLReport_AfterAdding_SubTotal Table([COA Name] NVARCHAR(MAX),RecOrder INT,DocType NVARCHAR(MAX),DocSubType Nvarchar(max),DocumentDescription Nvarchar(max),DocDate datetime2,DocNo Nvarchar(max),SystemRefNo NVarchar(max),ServiceCompany Nvarchar(max),EntityName NVarchar(max),BaseDebit money,BaseCredit money,BaseBalance money,ExchangeRate decimal(15,10),BaseCurrency Nvarchar(max),DocCurrency NVarchar(max),DocDebit money,DocCredit money,DocBalance money,SegmentCategory1 Nvarchar(max),SegmentCategory2 NVarchar(max),MCS_Status int,SegmentStatus int,CorrAccount NVarchar(max),[Entity Type] Nvarchar(max),[Vendor Type] Nvarchar(max),PONo NVarchar(max),Nature Nvarchar(max),[CreditTerms(Days)] float,DueDate datetime2,[NSD ISCHECKED] int,[NO SUPPORT DOC] NVarchar(20),ItemCode NVarchar(max),ItemDescription NVarchar(max),Qty float,Unit NVarchar(100),UnitPrice money,[DiscountType] NVarchar(10),Discount float,[BRM ISCHECKED] int,[ALLOWABLE/DISALLOWABLE] NVarchar(max),[Bank Clearing] datetime2,ModeOfReceipt NVarchar(200),ReversalDate datetime2,[Bank Reconcile] NVarchar(20),[Reversal Doc Ref] NVarchar(max),ClearingStatus Nvarchar(100),[Created By] NVarchar(600),[Created On] datetime2,[Modified By] NVarchar(600),[Modified On] datetime2,COA_Parameter NVarchar(max),classOrder BIGINT,IsSubTotal INt,ISBF int)

Declare @SegmentStatus int
--Select @SegmentStatus=Status
--From
--(
--	select distinct CompanyId,status
--	from
--	(
--		select CompanyId, Status from bean.SegmentMaster where CompanyId=@CompanyId
--	) as st1
--)as st2

Declare @NSdISChecked int
--Select @NSdISChecked=[NSD ISCHECKED] 
--From
--(
--	Select  CompanyId,ISNULL(IsChecked,0) AS [NSD ISCHECKED]  
--	From    Common.CompanyFeatures where CompanyId=@CompanyId and FeatureId=(select distinct id from Common.Feature where Name='No Supporting Documents') 

--)dt1

Declare @BRMIsChecked int
--Select @BRMIsChecked= [BRM ISCHECKED]
--From
--(
--    Select  CompanyId,ISNULL(IsChecked,0) AS [BRM ISCHECKED] 
--     From    Common.CompanyFeatures where CompanyId=@CompanyId and FeatureId=(select distinct id from Common.Feature where Name='Bank Reconciliation') 
--)dt2

Select @SegmentStatus=SegmentReporting, @BRMIsChecked=[Bank Reconciliation],@NSdISChecked=[No Supporting Documents]
From
(
	Select F.Name, Case When CF.Status=1 Then 1  Else 0 End Status
	From [common].[companyfeatures] CF
	Inner join [Common].[Feature] F On F.Id = CF.FeatureId
	Where F.Name in ('SegmentReporting', 'Bank Reconciliation', 'No Supporting Documents') And CF.CompanyId=@CompanyId
) Tab1
PIVOT
(
	Sum(Status) For Name IN (SegmentReporting, [Bank Reconciliation],[No Supporting Documents])  
) Tab2
--Print @SegmentStatus
--Print @NSdISChecked
--Print @BRMIsChecked

--------- Code should modified to fetch data from CompanyFeatures --
Declare @MCS_Status int
Select @MCS_Status=Status from Bean.MultiCurrencySetting where CompanyId=@CompanyId
--------- Code should modified to fetch data from CompanyFeatures --
--Print @MCS_Status

                               /*******END of Step 5 : Getting SegmentStatus,No Supporting Documents, Bank Reconciliation and MultiCurrencySetting**********/

                                /****** step 6: Data for Income Statement coa's **********/

Declare @COA_IS nvarchar(max)-- Income statement coa
Declare @COA_IS_CODE nvarchar(max)--Income statement coa code
Declare @COA_IS_CORDER INT --Income Statement coa class order
Declare @COA_IS_RECORDER INT --Income Statement AccountType order

Declare @IS_BF_CNT Bigint --used to store no of distinct dates between @ISBroughtForwardFromDate and @ISBroughtForwardToDate when @ISBroughtForwardFromDate<>='1900-01-01' condition becomes true
Declare @IS_DC_FOR_ZERO table (DocCurrency NVarchar(10))-- used to store distinct Doc currencies when @ISBroughtForwardFromDate='1900-01-01' condition satisfied
Declare @DocCur_Zero NVarchar(10) --used in IS_FOR_ZERO cursor 

Declare @ISDoccurrency table (DocCurr nvarchar(10))--used to store distinct doc currencies between @FromDate and @ToDate and Between @BSBroughtForwardFromDate and @BSBroughtForwardToDate
Declare @ISDoccurrency1 table (DocCurr nvarchar(10)) --used to get distinct doc currencies from @ISDoccurrency
Declare @ISCurrency_FOR_NOTZERO NVarchar(10)-- used to store Doc currency which is used in  IS_FOR_NOTZERO_currency cursor
Declare @IS_BFCurrencyCNT bigint --used to store count of no of days between @BFFD and @BFTD for corresponding @Dcocurrency of Selected INCOME STATEMENT COA
Declare @IS_BF_OB_CNT_forZero bigint --used to store count of days between @ISFromDate and @ISToDate for Opening balance doc type
Declare @IS_BF_IntCount_forNOTZero bigint --used to calculate distinct date counts between @ISBroughtForwardFromDate and @ISBroughtForwardToDate 
Declare @IS_BF_OBCount_forNOTZero bigint -- used to calculate disctinct date counts between @ISFromDate and @ISToDate for opening balance docsubtype


Declare IncomeSheet_cursor cursor for select * from @COA_IncomeStatement
Open IncomeSheet_cursor
Fetch next from IncomeSheet_cursor into @COA_IS,@COA_IS_CODE,@COA_IS_CORDER,@COA_IS_RECORDER 
while @@FETCH_STATUS=0
Begin
   --STEP 6.1: GETTING BROUGHT FORWARDED BALANCE FOR INCOME STATEMENT COA TYPE
   --STARTING POINT OF STEP 6.1

   /*** STEP 6.1.1: @ISBroughtForwardFromDate='1900-01-01' means the Brought forwarded balance should be zero ************/
   /*** IN THIS SCENARIO WE DONT CONSIDER DOC CURRENCIES BETWEEN @ISBroughtForwardFromDate AND @ISBroughtForwardToDate.***/
   /*** START OF 6.1.1: @ISBroughtForwardFromDate='1900-01-01' ***/
	IF @ISBroughtForwardFromDate='1900-01-01'
	BEGIN

	     /**** STEP 6.1.1.A : GETTING DISTINCT DOC CURRENCIES FOR SELECTED IC_COA BETWEEN @ISFromDate AND @ISToDate.AND RESULT IS INSERTED INTO @IS_DC_FOR_ZERO TABLE VARIABLE *******/
	         IF EXISTS (SELECT * FROM @IS_DC_FOR_ZERO)
			BEGIN
				  DELETE   FROM @IS_DC_FOR_ZERO
			END

			Insert Into @IS_DC_FOR_ZERO
			SELECT		Distinct isnull(JD.DocCurrency,'SGD') DocCurrency
			From        Bean.JournalDetail JD 
			Inner Join  Bean.Journal J on J.Id=JD.JournalId
			Inner Join  Bean.ChartOfAccount COA on COA.Id=JD.COAId
			Inner Join  Common.Company as SC on SC.Id=J.ServiceCompanyId
			WHERE       COA.CompanyId=@CompanyId
						AND  COA.Name in(select items from dbo.SplitToTable(CONVERT(nvarchar(max), (SELECT @COA_IS FOR XML PATH('')), 1),','))
						AND  SC.Name in(select items from dbo.SplitToTable(CONVERT(nvarchar(max), (SELECT @ServiceCompany FOR XML PATH('')), 1),','))
						AND CONVERT(DATE,J.DocDate) BETWEEN @ISFromDate AND @ISToDate
						AND COA.ModuleType='Bean'
						AND J.DocumentState NOT IN ('Void','Cancelled','Parked','Reset')
						--AND J.DocumentState<>'Void'

	     /**** ENDING OF STEP 6.1.1.A : GETTING DISTINCT DOC CURRENCIES FOR SELECTED IC_COA BETWEEN @ISFromDate AND @ISToDate.AND RESULT IS INSERTED INTO @IS_DC_FOR_ZERO TABLE VARIABLE *******/

			Declare IS_FOR_ZERO cursor for select * from @IS_DC_FOR_ZERO
			Open IS_FOR_ZERO
			Fetch Next From IS_FOR_ZERO Into @DocCur_Zero
			while @@FETCH_STATUS=0
			BEGIN
			/* STEP 6.1.1.B: SET TO TO DOCBALANCE,BASEBALANCE TO 0.00  if we dont have opening balance. if we have opening balance then we can show it.
			   AND ASSIGNED SOME OTHER FIELDS BASED ON REQUIREMENT */

			   -- Step 6.1.1.B.1: Calculating count for opening balance dates between @ISFromDate and @ISToDate for corresponding doc currency which satisfy B/F balance =0 condition.
			   -- Start of step 6.1.1.B.1
					SELECT	   @IS_BF_OB_CNT_forZero= count(distinct convert(date,J.DocDate))	
					From        Bean.JournalDetail JD 
					Inner Join  Bean.Journal J on J.Id=JD.JournalId
					Inner Join  Bean.ChartOfAccount COA on COA.Id=JD.COAId
					Inner Join  Common.Company as SC on SC.Id=J.ServiceCompanyId
					WHERE       COA.CompanyId=@CompanyId
								AND  COA.Name in(select items from dbo.SplitToTable(CONVERT(nvarchar(max), (SELECT @COA_IS FOR XML PATH('')), 1),','))
								AND  SC.Name in(select items from dbo.SplitToTable(CONVERT(nvarchar(max), (SELECT @ServiceCompany FOR XML PATH('')), 1),','))
								AND CONVERT(DATE,J.DocDate) BETWEEN @ISFromDate AND @ISToDate
								AND ISNULL(JD.DocCurrency,'SGD') = @DocCur_Zero
								AND COA.ModuleType='Bean'
								AND J.DocumentState NOT IN ('Void','Cancelled','Parked','Reset')
								AND J.DocType='Journal' and j.DocsubType='Opening Balance'
								--AND J.DocumentState<>'Void'
                 --End of step 6.1.1.B.1

				 --  step 6.1.1.B.2: If @IS_BF_OB_CNT_forZero=0 then shows base balance and doc balance as 0.00
				 -- Start of step 6.1.1.B.2 
				 IF @IS_BF_OB_CNT_forZero=0
				 Begin

					Insert Into @GLReport
					select  @COA_IS_CODE+'  '+@COA_IS as [COA Name],@COA_IS_RecOrder AS RecOrder, 'Balance B/F' as DocType,'' as DocSubType,'' as DocumentDescription,@ISFromDate as DocDate,'' as DocNo,'' as SystemRefNo,@ServiceCompany as  ServiceCompany,''  as EntityName,null as BaseDebit,null as BaseCredit,0.00 as BaseBalance,null as ExchangeRate,'SGD' as BaseCurrency, @DocCur_Zero as DocCurrency, null as DocDebit,null as DocCredit,0.00 as DocBalance/*IsMultiCurrency,*/,null as SegmentCategory1,null as SegmentCategory2, @MCS_Status,@SegmentStatus as SegmentStatus,null as CorrAccount,null as [Entity Type],null as [Vendor Type],null as PONo,null as Nature,null as [CreditTerms(Days)],null as DueDate,@NSdISChecked as [NSD ISCHECKED],null as [NO SUPPORT DOC],null as ItemCode,null as ItemDescription,null as Qty,null as Unit,null as UnitPrice,null as DiscountType,null as Discount,@BRMIsChecked as [BRM ISCHECKED],null as [ALLOWABLE/DISALLOWABLE],null as [Bank Clearing],null as ModeOfReceipt,null as ReversalDate,NULL as [Bank Reconcile],null as [Reversal Doc Ref],null as ClearingStatus,null as [Created By],null as [Created On],null as [Modified By],null as [Modified On],@COA_IS COA_Parameter,@COA_IS_CORDER as classOrder
				 
				 End
				 -- End of step 6.1.1.B.2 

				
				 Else IF @IS_BF_OB_CNT_forZero<>0
				  --  step 6.1.1.B.3: This condition is executed when  @IS_BF_OB_CNT_forZero<>0.
				 --  We can calculate opening balances between @ISFromDate And @ISToDate for corresponding Doc Currency and assinged in B/F balance amount.
				 --  Start of step 6.1.1.B.3
				 Begin
				    Insert Into @GLReport
					select  @COA_IS_CODE+'  '+@COA_IS as [COA Name],@COA_IS_RecOrder AS RecOrder, 'Balance B/F' as DocType,'' as DocSubType,'' as DocumentDescription,@ISFromDate as DocDate,'' as DocNo,'' as SystemRefNo,@ServiceCompany as  ServiceCompany,''  as EntityName,null as BaseDebit,null as BaseCredit,sum(BaseBalance) as BaseBalance,null as ExchangeRate, BaseCurrency, @DocCur_Zero as DocCurrency, null as DocDebit,null as DocCredit,sum(DocBalance) as DocBalance/*IsMultiCurrency,*/,null as SegmentCategory1,null as SegmentCategory2, @MCS_Status,@SegmentStatus as SegmentStatus,null as CorrAccount,null as [Entity Type],null as [Vendor Type],null as PONo,null as Nature,null as [CreditTerms(Days)],null as DueDate,@NSdISChecked as [NSD ISCHECKED],null as [NO SUPPORT DOC],null as ItemCode,null as ItemDescription,null as Qty,null as Unit,null as UnitPrice,null as DiscountType,null as Discount,@BRMIsChecked as [BRM ISCHECKED],null as [ALLOWABLE/DISALLOWABLE],null as [Bank Clearing],null as ModeOfReceipt,null as ReversalDate,NULL as [Bank Reconcile],null as [Reversal Doc Ref],null as ClearingStatus,null as [Created By],null as [Created On],null as [Modified By],null as [Modified On],@COA_IS COA_Parameter,@COA_IS_CORDER as classOrder
					From
				
					(	-- This block gives base and doc balances  for opening balances whhich should have to shown in B/F balance

						SELECT		isnull((isnull(Case when JD.BaseCurrency=JD.DocCurrency and JD.BaseDebit is null then JD.DocDebit else  JD.BaseDebit end ,0)-isnull(Case when JD.DocCurrency=JD.BaseCurrency and JD.BaseCredit is null then JD.DocCredit else JD.BaseCredit end,0)),0) as BaseBalance,			
									isnull((isnull(JD.DocDebit,0)-isnull(JD.DocCredit,0)),0) as DocBalance,isnull(JD.DocCurrency,'SGD') as DocCurrency,JD.BaseCurrency			
						From        Bean.JournalDetail JD 
						Inner Join  Bean.Journal J on J.Id=JD.JournalId
						Inner Join  Bean.ChartOfAccount COA on COA.Id=JD.COAId
						Inner Join  Common.Company as SC on SC.Id=J.ServiceCompanyId
						WHERE       COA.CompanyId=@CompanyId
									AND  COA.Name in(select items from dbo.SplitToTable(CONVERT(nvarchar(max), (SELECT @COA_IS FOR XML PATH('')), 1),','))
									AND  SC.Name in(select items from dbo.SplitToTable(CONVERT(nvarchar(max), (SELECT @ServiceCompany FOR XML PATH('')), 1),','))
									AND CONVERT(DATE,J.DocDate) BETWEEN @ISFromDate AND @ISToDate
									AND ISNULL(JD.DocCurrency,'SGD') = @DocCur_Zero
									AND COA.ModuleType='Bean'
									AND J.DocumentState NOT IN ('Void','Cancelled','Parked','Reset')
									AND J.DocType='Journal' and j.DocsubType='Opening Balance'
									--AND J.DocumentState<>'Void'		
					 )ex1	
					  Group By DocCurrency,BaseCurrency
				END   
				--  End of step 6.1.1.B.3 
			/* END OF STEP 6.1.1.B: SET TO TO DOCBALANCE,BASEBALANCE TO 0.00 AND ASSIGNED SOME OTHER FIELDS BASED ON REQUIREMENT */	
			    
				Fetch Next From IS_FOR_ZERO Into @DocCur_Zero
			END
			CLOSE IS_FOR_ZERO
			DEALLOCATE IS_FOR_ZERO
			
	END
				/*** END OF STEP 6.1.1: @ISBroughtForwardFromDate='1900-01-01' means the Brought forwarded balance should be zero ************/

	           /** STEP 6.1.2: @ISBroughtForwardFromDate<>'1900-01-01' i.e. THERE MIGHT BE SOME VALUE FOR BALANCE BROUGHT FORWARD ***/
	ELSE
	BEGIN
	/*** Step 6.1.2.a : getting Distinct Doc currencies between @BSFromDate and @BSToDate for corresponding @COA_IS ****/
	        IF EXISTS (SELECT * FROM @ISDoccurrency)
			BEGIN
				  DELETE   FROM @ISDoccurrency
			END

			IF EXISTS (SELECT * FROM @ISDoccurrency1)
			BEGIN
				  DELETE   FROM @ISDoccurrency1
			END

	        Insert Into @ISDoccurrency
			SELECT		Distinct isnull(JD.DocCurrency,'SGD') DocCurrency
			From        Bean.JournalDetail JD 
			Inner Join  Bean.Journal J on J.Id=JD.JournalId
			Inner Join  Bean.ChartOfAccount COA on COA.Id=JD.COAId
			Inner Join  Common.Company as SC on SC.Id=J.ServiceCompanyId
			WHERE       COA.CompanyId=@CompanyId
						AND  COA.Name in(select items from dbo.SplitToTable(CONVERT(nvarchar(max), (SELECT @COA_IS FOR XML PATH('')), 1),','))
						AND  SC.Name in(select items from dbo.SplitToTable(CONVERT(nvarchar(max), (SELECT @ServiceCompany FOR XML PATH('')), 1),','))
						AND CONVERT(DATE,J.DocDate) BETWEEN @ISFromDate AND @ISToDate
						AND COA.ModuleType='Bean'
						AND J.DocumentState NOT IN ('Void','Cancelled','Parked','Reset')
						--AND J.DocumentState<>'Void'
	/*** End of Step 6.1.2.a : getting Distinct Doc currencies between @BSFromDate and @BSToDate for corresponding @COA_IS ****/

	/*** Step 6.1.2.b : getting Distinct Doc currencies between @ISBroughtForwardFromDate and @ISBroughtForwardToDate for corresponding @COA_IS ****/
			--Insert Into @ISDoccurrency
			UNION ALL
			SELECT		Distinct isnull(JD.DocCurrency,'SGD') DocCurrency
			From        Bean.JournalDetail JD 
			Inner Join  Bean.Journal J on J.Id=JD.JournalId
			Inner Join  Bean.ChartOfAccount COA on COA.Id=JD.COAId
			Inner Join  Common.Company as SC on SC.Id=J.ServiceCompanyId
			WHERE       COA.CompanyId=@CompanyId
						AND  COA.Name in(select items from dbo.SplitToTable(CONVERT(nvarchar(max), (SELECT @COA_IS FOR XML PATH('')), 1),','))
						AND  SC.Name in(select items from dbo.SplitToTable(CONVERT(nvarchar(max), (SELECT @ServiceCompany FOR XML PATH('')), 1),','))
						AND CONVERT(DATE,J.DocDate) BETWEEN @ISBroughtForwardFromDate AND @ISBroughtForwardToDate
						AND COA.ModuleType='Bean'
						AND J.DocumentState NOT IN ('Void','Cancelled','Parked','Reset')
						--AND J.DocumentState<>'Void'
	/*** End of Step 6.1.2.b : getting Distinct Doc currencies between @ISBroughtForwardFromDate and @ISBroughtForwardToDate for corresponding @COA_IS ****/

	/***Step 6.1.2.c: Getting distinct doccurrencies from @ISDoccurrency TABLE VARIABLE into @ISDoccurrency1 ***/

	        Insert Into @ISDoccurrency1
		    Select Distinct DocCurr From @ISDoccurrency
			

			Declare IS_FOR_NOTZERO_currency cursor for select * from @ISDoccurrency1
			Open IS_FOR_NOTZERO_currency
			Fetch Next From IS_FOR_NOTZERO_currency Into @ISCurrency_FOR_NOTZERO
			while @@FETCH_STATUS=0
			Begin
			/***Step 6.1.2.d: Getting count of distinct docdates for currosponding DocCurrency of selected INCONME STATEMENT COA between @ISBroughtForwardFromDate and @IDBFTD & @ISFromDate and @ISToDate For opening balances doc subtype ***/
				
				--Step 6.1.2.d.1: Getting date count for B/f balance between @ISBroughtForwardFromDate and @ISBroughtForwardToDate
				SELECT		@IS_BF_IntCount_forNOTZero=COUNT(DISTINCT CONVERT(DATE,J.DocDate))		
			    From        Bean.JournalDetail JD 
				Inner Join  Bean.Journal J on J.Id=JD.JournalId
				Inner Join  Bean.ChartOfAccount COA on COA.Id=JD.COAId
				Inner Join  Common.Company as SC on SC.Id=J.ServiceCompanyId
				WHERE       COA.CompanyId=@CompanyId
							AND  COA.Name in(select items from dbo.SplitToTable(CONVERT(nvarchar(max), (SELECT @COA_IS FOR XML PATH('')), 1),','))
							AND  SC.Name in(select items from dbo.SplitToTable(CONVERT(nvarchar(max), (SELECT @ServiceCompany FOR XML PATH('')), 1),','))
							AND CONVERT(DATE,J.DocDate) BETWEEN @ISBroughtForwardFromDate AND @ISBroughtForwardToDate
							AND ISNULL(JD.DocCurrency,'SGD') = @ISCurrency_FOR_NOTZERO
							AND COA.ModuleType='Bean'
							AND J.DocumentState NOT IN ('Void','Cancelled','Parked','Reset')
							--AND J.DocumentState<>'Void'
				--end of step 6.1.2.d :Getting date count for B/f balance between @ISBroughtForwardFromDate and @ISBroughtForwardToDate
				
				--Step 6.1.2.d.2: Getting date count for opening balance docsubtype between @ISFromDate and @ISToDate
					SELECT	    @IS_BF_OBCount_forNOTZero= count(DISTINCT convert(date,J.DocDate))	
					From        Bean.JournalDetail JD 
					Inner Join  Bean.Journal J on J.Id=JD.JournalId
					Inner Join  Bean.ChartOfAccount COA on COA.Id=JD.COAId
					Inner Join  Common.Company as SC on SC.Id=J.ServiceCompanyId
					WHERE       COA.CompanyId=@CompanyId
								AND  COA.Name in(select items from dbo.SplitToTable(CONVERT(nvarchar(max), (SELECT @COA_IS FOR XML PATH('')), 1),','))
								AND  SC.Name in(select items from dbo.SplitToTable(CONVERT(nvarchar(max), (SELECT @ServiceCompany FOR XML PATH('')), 1),','))
								AND CONVERT(DATE,J.DocDate) BETWEEN @ISFromDate AND @ISToDate
								AND ISNULL(JD.DocCurrency,'SGD') = @ISCurrency_FOR_NOTZERO
								AND COA.ModuleType='Bean'
								AND J.DocumentState NOT IN ('Void','Cancelled','Parked','Reset')
								AND J.DocType='Journal' and j.DocsubType='Opening Balance'
								--AND J.DocumentState<>'Void'

				--step 6.1.2.d.3: sum of 6.1.2.d.1 and 6.1.2.d.2 and assign results to @IS_BFCurrencyCNT
				    Select @IS_BFCurrencyCNT=@IS_BF_IntCount_forNOTZero+@IS_BF_OBCount_forNOTZero

				--print @IS_BFCurrencyCNT

            /***End of Step 6.1.2.d: Getting count of distinct docdates for currosponding DocCurrency of selected INCOME STATEMENT COA between @ISBroughtForwardFromDate and @ISBroughtForwardToDate ***/

			/**** Step 6.1.2.e:@IS_BFCurrencyCNT=0 (i.e. there are no transactions in choosen doc currency for getting Brought forwarded balance. ***/
			--In this case We replace docbalance and basebalance as0.00 
				IF @IS_BFCurrencyCNT=0
				Begin
					Insert Into @GLReport
					select  @COA_IS_CODE+'  '+@COA_IS as [COA Name],@COA_IS_RecOrder AS RecOrder, 'Balance B/F' as DocType,'' as DocSubType,'' as DocumentDescription,@ISFromDate as DocDate,'' as DocNo,'' as SystemRefNo,@ServiceCompany as  ServiceCompany,''  as EntityName,null as BaseDebit,null as BaseCredit,0.00 as BaseBalance,null as ExchangeRate,'SGD' as BaseCurrency, @ISCurrency_FOR_NOTZERO as DocCurrency, null as DocDebit,null as DocCredit,0.00 as DocBalance/*IsMultiCurrency,*/,null as SegmentCategory1,null as SegmentCategory2, @MCS_Status,@SegmentStatus as SegmentStatus,null as CorrAccount,null as [Entity Type],null as [Vendor Type],null as PONo,null as Nature,null as [CreditTerms(Days)],null as DueDate,@NSdISChecked as [NSD ISCHECKED],null as [NO SUPPORT DOC],null as ItemCode,null as ItemDescription,null as Qty,null as Unit,null as UnitPrice,null as DiscountType,null as Discount,@BRMIsChecked as [BRM ISCHECKED],null as [ALLOWABLE/DISALLOWABLE],null as [Bank Clearing],null as ModeOfReceipt,null as ReversalDate,NULL as [Bank Reconcile],null as [Reversal Doc Ref],null as ClearingStatus,null as [Created By],null as [Created On],null as [Modified By],null as [Modified On],@COA_IS COA_Parameter,@COA_IS_CORDER as classOrder      
				End
			/**** Step End of 6.1.2.e: @IS_BFCurrencyCNT=0 (i.e. there are no transactions in choosen doc currency for getting Brought forwarded balance. ***/
			
			/**** Step 6.1.2.f:  @IS_BFCurrencyCNT<>0 (i.e. there are few transactions in choosen doc currency for getting Brought forwarded balance. ***/
				ELSE IF @IS_BFCurrencyCNT<>0 
				BEGIN
			      
					  INSERT INTO @GLReport
					  SELECT  @COA_IS_CODE+'  '+@COA_IS as [COA Name],@COA_IS_RecOrder AS Recorder, 'Balance B/F' as DocType,'' as DocSubType,'' as DocumentDescription,@ISFromDate as DocDate,'' as DocNo,'' as SystemRefNo,@ServiceCompany as  ServiceCompany,''  as EntityName,null as BaseDebit,null as BaseCredit,SUM(BaseBalance) as BaseBalance,null as ExchangeRate, BaseCurrency/*null as BaseCurrency*/, DocCurrency/*null as DocCurrency*/, null as DocDebit,null as DocCredit,SUM(DocBalance) as DocBalance/*IsMultiCurrency,*/,null as SegmentCategory1,null as SegmentCategory2, @MCS_Status,@SegmentStatus as SegmentStatus,null as CorrAccount,null as [Entity Type],null as [Vendor Type],null as PONo,null as Nature,null as [CreditTerms(Days)],null as DueDate,@NSdISChecked as [NSD ISCHECKED],null as [NO SUPPORT DOC],null as ItemCode,null as ItemDescription,null as Qty,null as Unit,null as UnitPrice,null as DiscountType,null as Discount,@BRMIsChecked as [BRM ISCHECKED],null as [ALLOWABLE/DISALLOWABLE],null as [Bank Clearing],null as ModeOfReceipt,null as ReversalDate,NULL as [Bank Reconcile],null as [Reversal Doc Ref],null as ClearingStatus,null as [Created By],null as [Created On],null as [Modified By],null as [Modified On],@COA_IS COA_Parameter,@COA_IS_CORDER as classOrder
					  FROM
					  (
						  SELECT SUM(BaseBalance) as BaseBalance,SUM(DocBalance) as DocBalance,DocCurrency,BaseCurrency
						  FROM
						  (	
								SELECT		isnull((isnull(Case when JD.BaseCurrency=JD.DocCurrency and JD.BaseDebit is null then JD.DocDebit else  JD.BaseDebit end ,0)-isnull(Case when JD.DocCurrency=JD.BaseCurrency and JD.BaseCredit is null then JD.DocCredit else JD.BaseCredit end,0)),0) as BaseBalance,			
											isnull((isnull(JD.DocDebit,0)-isnull(JD.DocCredit,0)),0) as DocBalance,isnull(JD.DocCurrency,'SGD') as DocCurrency,JD.BaseCurrency			
								From        Bean.JournalDetail JD 
								Inner Join  Bean.Journal J on J.Id=JD.JournalId
								Inner Join  Bean.ChartOfAccount COA on COA.Id=JD.COAId
								Inner Join  Common.Company as SC on SC.Id=J.ServiceCompanyId
								WHERE       COA.CompanyId=@CompanyId
											AND  COA.Name in(select items from dbo.SplitToTable(CONVERT(nvarchar(max), (SELECT @COA_IS FOR XML PATH('')), 1),','))
											AND  SC.Name in(select items from dbo.SplitToTable(CONVERT(nvarchar(max), (SELECT @ServiceCompany FOR XML PATH('')), 1),','))
											AND CONVERT(DATE,J.DocDate) BETWEEN @ISBroughtForwardFromDate AND @ISBroughtForwardToDate
											AND ISNULL(JD.DocCurrency,'SGD') = @ISCurrency_FOR_NOTZERO
											AND COA.ModuleType='Bean'
											AND J.DocumentState NOT IN ('Void','Cancelled','Parked','Reset')
											--AND J.DocumentState<>'Void'
						  )DT1
						  Group By DocCurrency,BaseCurrency

						  union all

						  SELECT SUM(BaseBalance) as BaseBalance,SUM(DocBalance) as DocBalance,DocCurrency,BaseCurrency
						  FROM
						  (	
								SELECT		isnull((isnull(Case when JD.BaseCurrency=JD.DocCurrency and JD.BaseDebit is null then JD.DocDebit else  JD.BaseDebit end ,0)-isnull(Case when JD.DocCurrency=JD.BaseCurrency and JD.BaseCredit is null then JD.DocCredit else JD.BaseCredit end,0)),0) as BaseBalance,			
											isnull((isnull(JD.DocDebit,0)-isnull(JD.DocCredit,0)),0) as DocBalance,isnull(JD.DocCurrency,'SGD') as DocCurrency,JD.BaseCurrency			
								From        Bean.JournalDetail JD 
								Inner Join  Bean.Journal J on J.Id=JD.JournalId
								Inner Join  Bean.ChartOfAccount COA on COA.Id=JD.COAId
								Inner Join  Common.Company as SC on SC.Id=J.ServiceCompanyId
								WHERE       COA.CompanyId=@CompanyId
											AND  COA.Name in(select items from dbo.SplitToTable(CONVERT(nvarchar(max), (SELECT @COA_IS FOR XML PATH('')), 1),','))
											AND  SC.Name in(select items from dbo.SplitToTable(CONVERT(nvarchar(max), (SELECT @ServiceCompany FOR XML PATH('')), 1),','))
											AND CONVERT(DATE,J.DocDate) BETWEEN @ISFromDate AND @ISToDate
											AND ISNULL(JD.DocCurrency,'SGD') = @ISCurrency_FOR_NOTZERO
											AND COA.ModuleType='Bean'
											AND J.DocumentState NOT IN ('Void','Cancelled','Parked','Reset')
											AND J.DocType='Journal' and j.DocsubType='Opening Balance'
											--AND J.DocumentState<>'Void'
						  )DT1
						  Group By DocCurrency,BaseCurrency
					  )ex2
					   Group By DocCurrency,BaseCurrency
				END

			/**** End of Step 6.1.2.f:  @IS_BFCurrencyCNT<>0 (i.e. there are few transactions in choosen doc currency for getting Brought forwarded balance. ***/
			
				Fetch Next From IS_FOR_NOTZERO_currency Into @ISCurrency_FOR_NOTZERO
			End
			Close IS_FOR_NOTZERO_currency
			Deallocate IS_FOR_NOTZERO_currency
	END
	 /** END OF STEP 6.1.2: @ISBroughtForwardFromDate<>'1900-01-01' i.e. THERE MIGHT BE SOME VALUE FOR BALANCE BROUGHT FORWARD ***/

	--END OF STEP 6.1: GETTING BROUGHT FORWARDED BALANCE FOR INCOME STATEMENT COA TYPE

	--ENDING OF STEP 6.1: GETTING BROUGHT FORWARDED BALANCE FOR INCOME STATEMENT COA TYPE
	
	--STEP 6.2: GETTING RECORDS BETWEEN @ISFromDate AND @ISToDate
	 /********* Step 6.2.1 : Getting records when documentdetailid is 0 AND JD.DocType<>'Journal' *******************/
 
	 /*********** Step 6.2.1.3 : here we join MS1 (Step 6.2.1.1) and FCA (Step 6.2.1.2.a) *****************/
	 /*********** Taking all columns from MS1 and corresponding Account column from FCA ****************/
	 Insert Into @GLReport
	 select [COA Name],RecOrder,DocType,DocSubType,DocumentDescription,DocDate,DocNo,SystemRefNo,ServiceCompany,EntityName,BaseDebit,BaseCredit,BaseBalance,ExchangeRate,BaseCurrency,DocCurrency,DocDebit,DocCredit,DocBalance,/*IsMultiCurrency,*/SegmentCategory1,SegmentCategory2,MCS_Status,Status,  /*FCA.CorrAccount*/  CorrAccount,[Entity Type],[Vendor Type],PONo,Nature,[CreditTerms(Days)],DueDate,[NSD ISCHECKED],[NO SUPPORT DOC],ItemCode,ItemDescription,Qty,Unit,UnitPrice,DiscountType,Discount,[BRM ISCHECKED],[ALLOWABLE/DISALLOWABLE],[Bank Clearing],ModeOfReceipt,ReversalDate,[Bank Reconcile],[Reversal Doc Ref],ClearingStatus,[Created By],[Created On],[Modified By],[Modified On],COA_Parameter,classOrder

	 from
	 (
		 /********* Step 6.2.1.1 : Getting records except coresponding account column ************************************/
		 Select      COA.Code+'  '+ COA.Name as 'COA Name', JD.DocType,JD.DocSubType,
		             --J.DocumentDescription as DocumentDescription,
					 case when J.DocType<>'Journal' then J.DocumentDescription
					      when J.DocType='Journal'
						  then
						    Case when J.DocSubType='Opening Balance'
							     then 
								   case when Jd.AccountDescription is null then J.DocumentDescription else Jd.AccountDescription  end
								 when J.DocSubType<>'Opening Balance' then J.DocumentDescription
							end
					  end as DocumentDescription,  
					 J.DocDate,case when J.DocType='Journal' and J.DocSubType='Opening Balance' then JD.SystemRefNo else JD.DocNo end as DocNo,J.ActualSysRefNo SystemRefNo, SC.Name ServiceCompany,case when J.DocType<>'Journal' then E.Name when J.DocType='Journal' then EJ.Name end as EntityName,case when JD.BaseCurrency=JD.DocCurrency and JD.BaseDebit is null then JD.DocDebit else JD.BaseDebit end BaseDebit,case when JD.BaseCurrency=JD.DocCurrency and JD.BaseCredit is null then JD.DocCredit else JD.BaseCredit end BaseCredit,isnull((isnull(Case when JD.BaseCurrency=JD.DocCurrency and JD.BaseDebit is null then JD.DocDebit else  JD.BaseDebit end ,0)-isnull(Case when JD.DocCurrency=JD.BaseCurrency and JD.BaseCredit is null then JD.DocCredit else JD.BaseCredit end,0)),0) as BaseBalance ,jd.ExchangeRate,jd.BaseCurrency,isnull(JD.DocCurrency,'SGD') DocCurrency,JD.DocDebit,JD.DocCredit,isnull((isnull(JD.DocDebit,0)-isnull(JD.DocCredit,0)),0) as DocBalance,/*IsMultiCurrency,*/jd.SegmentCategory1,JD.SegmentCategory2,Case when MCS.Status=1 then 1 else 0 end MCS_Status, SM3.Status,/*COA.Name as [Corr Account],*/
					 JD.JournalId,
					 --case when J.DocType<>'Journal'and E.IsCustomer=1 then 'Customer' when E.IsVendor=1 then 'Vendor' end as [Entity Type],E.VendorType as [Vendor Type],
					 case when J.DocType<>'Journal'
					      then
				             Case when E.IsCustomer=1 then 'Customer' when E.IsVendor=1 then 'Vendor' end 
			              when J.DocType='Journal'
                          then
                             Case when EJ.IsCustomer=1 then 'Customer' when EJ.IsVendor=1 then 'Vendor' end 
			              end 
			          as [Entity Type],
                     case when J.DocType<>'Journal' then E.VendorType 
			              when J.DocType='Journal' then EJ.VendorType
			         end
			         as [Vendor Type],
					 J.PONo,JD.Nature,TP.TOPValue as [CreditTerms(Days)],J.DueDate,NSD.[NSD ISCHECKED],CASE WHEN J.IsNoSupportingDocs=0 THEN 'NO' WHEN J.IsNoSupportingDocs=1 THEN 'YES' END AS [NO SUPPORT DOC],JD.ItemCode,JD.ItemDescription,JD.Qty,JD.Unit,JD.UnitPrice,JD.DiscountType,JD.Discount,[BRM ISCHECKED],case when JD.AllowDisAllow=0 then 'NO' when JD.AllowDisAllow=1 then 'YES' END AS [ALLOWABLE/DISALLOWABLE],JD.ClearingDate AS [Bank Clearing],J.ModeOfReceipt,J.ReversalDate,
					 case when J.IsBankReconcile=0 then 'NO' when J.IsBankReconcile=1 then 'YES' end as [Bank Reconcile],case when J.IsAutoReversalJournal in (1) then J.SystemReferenceNo  end as [Reversal Doc Ref],JD.ClearingStatus,J.UserCreated as [Created By],J.CreatedDate as [Created On],J.ModifiedBy as [Modified By],J.ModifiedDate as [Modified On],@COA_IS as COA_Parameter,
					 Case when COA.Class in('Assets','Asset') then 1 
									when COA.Class='Liabilities' then 2
									when COA.Class='Equity' then 3
									when COA.Class='Income' then 4
									when COA.Class='Expenses' then 5 end as classOrder,AT.RecOrder,CCOA.Name as CorrAccount
		 From        Bean.JournalDetail JD 
		 Inner Join  Bean.Journal J on J.Id=JD.JournalId
		 Inner Join  Bean.ChartOfAccount COA on COA.Id=JD.COAId
		 Left  Join  Bean.ChartOfAccount CCOA on CCOA.Id=JD.CorrAccountId
		 Left  Join  Bean.AccountType AT ON AT.Id=COA.AccountTypeId AND AT.CompanyId=COA.CompanyId 
		 Inner Join  Common.Company as SC on SC.Id=J.ServiceCompanyId
		 Left  join  Bean.Entity as E on E.Id=J.EntityId and J.DocType<>'Journal'
		 Left  Join  Bean.Entity as EJ on EJ.Id=JD.EntityId and J.DocType='Journal' 
		 Left join   Bean.SegmentMaster as SM1 on SM1.Id=JD.SegmentMasterid1 and J.CompanyId=SM1.CompanyId
		 Left join   Bean.SegmentMaster as SM2 on SM2.Id=JD.SegmentMasterid1 and J.CompanyId=SM2.CompanyId
		 Left join   Bean.MultiCurrencySetting MCS on MCS.companyId=J.CompanyId
		 Left Join 
		  (
			  select distinct CompanyId,status
			  from
			  (
				select CompanyId, Status from bean.SegmentMaster where CompanyId=@CompanyId
			  ) as st1
		  ) SM3 on SM3.companyid=J.CompanyId 
		 Left join   Common.TermsOfPayment as TP on TP.Id=JD.CreditTermsId
		 LEFT JOIN
		  (
			 select   CompanyId,ISNULL(IsChecked,0) AS [NSD ISCHECKED]  
			 From     Common.CompanyFeatures where CompanyId=@CompanyId and FeatureId=(select distinct id from Common.Feature where Name='No Supporting Documents') 
		  ) AS NSD ON NSD.CompanyId=J.CompanyId
		 LEFT JOIN
		  (
			 select  CompanyId,ISNULL(IsChecked,0) AS [BRM ISCHECKED] 
			 From    Common.CompanyFeatures where CompanyId=@CompanyId and FeatureId=(select distinct id from Common.Feature where Name='Bank Reconciliation') 
		   ) AS BRM ON BRM.CompanyId=J.CompanyId

		 where COA.CompanyId=@CompanyId and  JD.DocumentDetailId='00000000-0000-0000-0000-000000000000' and COA.ModuleType='Bean' --and JD.IsTax<>1
		 /*and JD.DocType not in('Credit Memo','Credit Note') and JD.DocSubType not in('CreditNote','Credit Memo')*/
		 /*and COA.Name in(@COA_IS) */
		 AND  COA.Name in(select items from dbo.SplitToTable(CONVERT(nvarchar(max), (SELECT @COA_IS FOR XML PATH('')), 1),','))
		/* and SC.Name in (SELECT items FROM dbo.SplitToTable(@ServiceCompany,','))*/
		AND  SC.Name in(select items from dbo.SplitToTable(CONVERT(nvarchar(max), (SELECT @ServiceCompany FOR XML PATH('')), 1),','))
		 and CONVERT(DATE,J.DocDate) between @ISFromDate and @ISToDate AND J.DocumentState NOT IN ('Void','Cancelled','Parked','Reset') -- And J.DocumentState<>'Void'
		 AND JD.DocType<>'Journal'
		 --order by [COA Name],DocDate
	 ) as MS1

	 /*********Ending of Step 6.2.1.1 *************************/
	
	/*********** Ending of step 6.2.1.3 **************/
	/*********** Ending of step 6.2.1 **************/

	union all

/********* Step 6.2.2 : Getting records when documentdetailid is  not 0 AND JD.DocType<>'Journal' *******************/
 /*********** Step 6.2.2.3 : here we join MS1 (Step 6.2.2.1) and FCA (Step 6.2.2.2) *****************/
 /*********** Taking all columns from MS1 and corresponding Account column from FCA ****************/

	 select [COA Name],RecOrder,DocType,DocSubType,DocumentDescription,DocDate,DocNo,SystemRefNo,ServiceCompany,EntityName,BaseDebit,BaseCredit,BaseBalance,ExchangeRate,BaseCurrency,DocCurrency,DocDebit,DocCredit,DocBalance,/*IsMultiCurrency,*/SegmentCategory1,SegmentCategory2,MCS_Status,Status, /*FCA.CorrAccount*/CorrAccount,[Entity Type],[Vendor Type],PONo,Nature,[CreditTerms(Days)],DueDate,[NSD ISCHECKED],[NO SUPPORT DOC],ItemCode,ItemDescription,Qty,Unit,UnitPrice,DiscountType,Discount,[BRM ISCHECKED],[ALLOWABLE/DISALLOWABLE],[Bank Clearing],ModeOfReceipt,ReversalDate,[Bank Reconcile],[Reversal Doc Ref],ClearingStatus,[Created By],[Created On],[Modified By],[Modified On],COA_Parameter,classOrder

	 from
	 (
		  /********* Step 6.2.2.1 : Getting records except coresponding account column ************************************/
		 select       COA.Code+'  '+ COA.Name as 'COA Name', JD.DocType,JD.DocSubType,
		              --J.DocumentDescription as DocumentDescription,
					  case when J.DocType<>'Journal' then J.DocumentDescription
					      when J.DocType='Journal'
						  then
						    Case when J.DocSubType='Opening Balance'
							     then 
								   case when Jd.AccountDescription is null then J.DocumentDescription else Jd.AccountDescription  end
								 when J.DocSubType<>'Opening Balance' then J.DocumentDescription
							end
					  end as DocumentDescription, 
					  J.DocDate,case when J.DocType='Journal' and J.DocSubType='Opening Balance' then JD.SystemRefNo else JD.DocNo end as DocNo,J.ActualSysRefNo SystemRefNo, SC.Name ServiceCompany,case when J.DocType<>'Journal' then E.Name when J.DocType='Journal' then EJ.Name end as EntityName,case when JD.BaseCurrency=JD.DocCurrency and JD.BaseDebit is null then JD.DocDebit else JD.BaseDebit end BaseDebit,case when JD.BaseCurrency=JD.DocCurrency and JD.BaseCredit is null then JD.DocCredit else JD.BaseCredit end BaseCredit,isnull((isnull(Case when JD.BaseCurrency=JD.DocCurrency and JD.BaseDebit is null then JD.DocDebit else  JD.BaseDebit end ,0)-isnull(Case when JD.DocCurrency=JD.BaseCurrency and JD.BaseCredit is null then JD.DocCredit else JD.BaseCredit end,0)),0) as BaseBalance ,jd.ExchangeRate,jd.BaseCurrency,isnull(JD.DocCurrency,'SGD') DocCurrency,JD.DocDebit,JD.DocCredit,isnull((isnull(JD.DocDebit,0)-isnull(JD.DocCredit,0)),0) as DocBalance,IsMultiCurrency,jd.SegmentCategory1,JD.SegmentCategory2,Case when MCS.Status=1 then 1 else 0 end MCS_Status, SM3.Status,/*COA.Name as [Corr Account],*/
					  JD.JournalId,
					  --case when E.IsCustomer=1 then 'Customer' when E.IsVendor=1 then 'Vendor' end as [Entity Type],E.VendorType as [Vendor Type],
					  case when J.DocType<>'Journal'
					      then
				             Case when E.IsCustomer=1 then 'Customer' when E.IsVendor=1 then 'Vendor' end 
			              when J.DocType='Journal'
                          then
                             Case when EJ.IsCustomer=1 then 'Customer' when EJ.IsVendor=1 then 'Vendor' end 
			              end 
			          as [Entity Type],
                     case when J.DocType<>'Journal' then E.VendorType 
			              when J.DocType='Journal' then EJ.VendorType
			         end
			         as [Vendor Type],
					  J.PONo,JD.Nature,TP.TOPValue as [CreditTerms(Days)],J.DueDate,NSD.[NSD ISCHECKED],CASE WHEN J.IsNoSupportingDocs=0 THEN 'NO' WHEN J.IsNoSupportingDocs=1 THEN 'YES' END AS [NO SUPPORT DOC],JD.ItemCode,JD.ItemDescription,JD.Qty,JD.Unit,JD.UnitPrice,JD.DiscountType,JD.Discount,[BRM ISCHECKED],case when JD.AllowDisAllow=0 then 'NO' when JD.AllowDisAllow=1 then 'YES' END AS [ALLOWABLE/DISALLOWABLE],JD.ClearingDate AS [Bank Clearing],J.ModeOfReceipt,J.ReversalDate,
					  case when J.IsBankReconcile=0 then 'NO' when J.IsBankReconcile=1 then 'YES' end as [Bank Reconcile],case when J.IsAutoReversalJournal in (1) then J.SystemReferenceNo  end as [Reversal Doc Ref],JD.ClearingStatus,J.UserCreated as [Created By],J.CreatedDate as [Created On],J.ModifiedBy as [Modified By],J.ModifiedDate as [Modified On],@COA_IS as COA_Parameter,
					  Case when COA.Class in('Assets','Asset') then 1  
									when COA.Class='Liabilities' then 2
									when COA.Class='Equity' then 3
									when COA.Class='Income' then 4
									when COA.Class='Expenses' then 5 end as classOrder,AT.RecOrder,CCOA.Name as CorrAccount
		 From         Bean.JournalDetail JD 
		 Inner Join   Bean.Journal J on J.Id=JD.JournalId
		 Inner Join   Bean.ChartOfAccount COA on COA.Id=JD.COAId
		 Left  Join   Bean.ChartOfAccount CCOA on CCOA.Id=JD.CorrAccountId
		 Left  Join  Bean.AccountType AT ON AT.Id=COA.AccountTypeId AND AT.CompanyId=COA.CompanyId 
		 Inner Join   Common.Company as SC on SC.Id=J.ServiceCompanyId
		 Left  join  Bean.Entity as E on E.Id=J.EntityId and J.DocType<>'Journal'
		 Left  Join  Bean.Entity as EJ on EJ.Id=JD.EntityId and J.DocType='Journal' 
		 Left join    Bean.SegmentMaster as SM1 on SM1.Id=JD.SegmentMasterid1 and J.CompanyId=SM1.CompanyId
		 Left join    Bean.SegmentMaster as SM2 on SM2.Id=JD.SegmentMasterid1 and J.CompanyId=SM2.CompanyId
		 Left join    Bean.MultiCurrencySetting MCS on MCS.companyId=J.CompanyId
		 Left Join 
		  (
			  Select distinct CompanyId,status
			  From
			  (
				select CompanyId, Status from bean.SegmentMaster where CompanyId=@CompanyId
			  ) as st1
		  ) SM3 on SM3.companyid=J.CompanyId 
		 Left join Common.TermsOfPayment as TP on TP.Id=JD.CreditTermsId
		 LEFT JOIN
		  (
			 Select CompanyId,ISNULL(IsChecked,0) AS [NSD ISCHECKED]  
			 From   Common.CompanyFeatures where CompanyId=@CompanyId and FeatureId=(select distinct id from Common.Feature where Name='No Supporting Documents') 
		  ) AS NSD ON NSD.CompanyId=J.CompanyId
		 LEFT JOIN
		  (
			 Select  CompanyId,ISNULL(IsChecked,0) AS [BRM ISCHECKED] 
			 From    Common.CompanyFeatures where CompanyId=@CompanyId and FeatureId=(select distinct id from Common.Feature where Name='Bank Reconciliation') 
		   ) AS BRM ON BRM.CompanyId=J.CompanyId

		 where COA.CompanyId=@CompanyId and  JD.DocumentDetailId<>'00000000-0000-0000-0000-000000000000' and COA.ModuleType='Bean' 
		
		AND  COA.Name in(select items from dbo.SplitToTable(CONVERT(nvarchar(max), (SELECT @COA_IS FOR XML PATH('')), 1),',')) 
		AND  SC.Name in(select items from dbo.SplitToTable(CONVERT(nvarchar(max), (SELECT @ServiceCompany FOR XML PATH('')), 1),','))
		 and CONVERT(DATE,J.DocDate) between @ISFromDate and @ISToDate AND J.DocumentState NOT IN ('Void','Cancelled','Parked','Reset') 
		 AND JD.DocType<>'Journal'
		
	 ) as MS1

	 /*********Ending of Step Step 6.2.2.1 *************************/
	/*********** Ending of step Step 6.2.2.3 **************/
	/*********** Ending of step Step 6.2.2 **************/

   UNION ALL

   	 /********* Step 6.2.3 : Getting records when documentdetailid is 0 AND JD.DocType='Journal' AND JD.DocSubType<>'Opening Balance' *******************/
 
	 /*********** Step 6.2.3.3 : here we join MS1 (Step 6.2.3.1) and FCA (Step 6.2.3.2.a) *****************/
	 /*********** Taking all columns from MS1 and corresponding Account column from FCA ****************/
	
	 select [COA Name],RecOrder,DocType,DocSubType,DocumentDescription,DocDate,DocNo,SystemRefNo,ServiceCompany,EntityName,BaseDebit,BaseCredit,BaseBalance,ExchangeRate,BaseCurrency,DocCurrency,DocDebit,DocCredit,DocBalance,/*IsMultiCurrency,*/SegmentCategory1,SegmentCategory2,MCS_Status,Status,  /*FCA.CorrAccount*/  CorrAccount,[Entity Type],[Vendor Type],PONo,Nature,[CreditTerms(Days)],DueDate,[NSD ISCHECKED],[NO SUPPORT DOC],ItemCode,ItemDescription,Qty,Unit,UnitPrice,DiscountType,Discount,[BRM ISCHECKED],[ALLOWABLE/DISALLOWABLE],[Bank Clearing],ModeOfReceipt,ReversalDate,[Bank Reconcile],[Reversal Doc Ref],ClearingStatus,[Created By],[Created On],[Modified By],[Modified On],COA_Parameter,classOrder

	 from
	 (
		 /********* Step 6.2.3.1 : Getting records except coresponding account column ************************************/
		 Select      COA.Code+'  '+ COA.Name as 'COA Name', JD.DocType,JD.DocSubType,
					 case when J.DocType<>'Journal' then J.DocumentDescription
					      when J.DocType='Journal'
						  then
						    Case when J.DocSubType='Opening Balance'
							     then 
								   case when Jd.AccountDescription is null then J.DocumentDescription else Jd.AccountDescription  end
								 when J.DocSubType<>'Opening Balance' then J.DocumentDescription
							end
					  end as DocumentDescription,  
					 J.DocDate,case when J.DocType='Journal' and J.DocSubType='Opening Balance' then JD.SystemRefNo else JD.DocNo end as DocNo,J.ActualSysRefNo SystemRefNo, SC.Name ServiceCompany,case when J.DocType<>'Journal' then E.Name when J.DocType='Journal' then EJ.Name end as EntityName,case when JD.BaseCurrency=JD.DocCurrency and JD.BaseDebit is null then JD.DocDebit else JD.BaseDebit end BaseDebit,case when JD.BaseCurrency=JD.DocCurrency and JD.BaseCredit is null then JD.DocCredit else JD.BaseCredit end BaseCredit,isnull((isnull(Case when JD.BaseCurrency=JD.DocCurrency and JD.BaseDebit is null then JD.DocDebit else  JD.BaseDebit end ,0)-isnull(Case when JD.DocCurrency=JD.BaseCurrency and JD.BaseCredit is null then JD.DocCredit else JD.BaseCredit end,0)),0) as BaseBalance ,jd.ExchangeRate,jd.BaseCurrency,isnull(JD.DocCurrency,'SGD') DocCurrency,JD.DocDebit,JD.DocCredit,isnull((isnull(JD.DocDebit,0)-isnull(JD.DocCredit,0)),0) as DocBalance,/*IsMultiCurrency,*/jd.SegmentCategory1,JD.SegmentCategory2,Case when MCS.Status=1 then 1 else 0 end MCS_Status, SM3.Status,/*COA.Name as [Corr Account],*/
					 JD.JournalId,
					 case when J.DocType<>'Journal'
					      then
				             Case when E.IsCustomer=1 then 'Customer' when E.IsVendor=1 then 'Vendor' end 
			              when J.DocType='Journal'
                          then
                             Case when EJ.IsCustomer=1 then 'Customer' when EJ.IsVendor=1 then 'Vendor' end 
			              end 
			          as [Entity Type],
                     case when J.DocType<>'Journal' then E.VendorType 
			              when J.DocType='Journal' then EJ.VendorType
			         end
			         as [Vendor Type],
					 J.PONo,JD.Nature,TP.TOPValue as [CreditTerms(Days)],J.DueDate,NSD.[NSD ISCHECKED],CASE WHEN J.IsNoSupportingDocs=0 THEN 'NO' WHEN J.IsNoSupportingDocs=1 THEN 'YES' END AS [NO SUPPORT DOC],JD.ItemCode,JD.ItemDescription,JD.Qty,JD.Unit,JD.UnitPrice,JD.DiscountType,JD.Discount,[BRM ISCHECKED],case when JD.AllowDisAllow=0 then 'NO' when JD.AllowDisAllow=1 then 'YES' END AS [ALLOWABLE/DISALLOWABLE],JD.ClearingDate AS [Bank Clearing],J.ModeOfReceipt,J.ReversalDate,
					 case when J.IsBankReconcile=0 then 'NO' when J.IsBankReconcile=1 then 'YES' end as [Bank Reconcile],case when J.IsAutoReversalJournal in (1) then J.SystemReferenceNo  end as [Reversal Doc Ref],JD.ClearingStatus,J.UserCreated as [Created By],J.CreatedDate as [Created On],J.ModifiedBy as [Modified By],J.ModifiedDate as [Modified On],@COA_IS as COA_Parameter,
					 Case when COA.Class in('Assets','Asset') then 1 
									when COA.Class='Liabilities' then 2
									when COA.Class='Equity' then 3
									when COA.Class='Income' then 4
									when COA.Class='Expenses' then 5 end as classOrder,AT.RecOrder,JD.COAId,CCOA.Name as CorrAccount
		 From        Bean.JournalDetail JD 
		 Inner Join  Bean.Journal J on J.Id=JD.JournalId
		 Inner Join  Bean.ChartOfAccount COA on COA.Id=JD.COAId
		 Left  Join  Bean.ChartOfAccount CCOA on CCOA.Id=JD.CorrAccountId
		 Left  Join  Bean.AccountType AT ON AT.Id=COA.AccountTypeId AND AT.CompanyId=COA.CompanyId 
		 Inner Join  Common.Company as SC on SC.Id=J.ServiceCompanyId
		 Left  join  Bean.Entity as E on E.Id=J.EntityId and J.DocType<>'Journal'
		 Left  Join  Bean.Entity as EJ on EJ.Id=JD.EntityId and J.DocType='Journal' 
		 Left join   Bean.SegmentMaster as SM1 on SM1.Id=JD.SegmentMasterid1 and J.CompanyId=SM1.CompanyId
		 Left join   Bean.SegmentMaster as SM2 on SM2.Id=JD.SegmentMasterid1 and J.CompanyId=SM2.CompanyId
		 Left join   Bean.MultiCurrencySetting MCS on MCS.companyId=J.CompanyId
		 Left Join 
		  (
			  select distinct CompanyId,status
			  from
			  (
				select CompanyId, Status from bean.SegmentMaster where CompanyId=@CompanyId
			  ) as st1
		  ) SM3 on SM3.companyid=J.CompanyId 
		 Left join   Common.TermsOfPayment as TP on TP.Id=JD.CreditTermsId
		 LEFT JOIN
		  (
			 select   CompanyId,ISNULL(IsChecked,0) AS [NSD ISCHECKED]  
			 From     Common.CompanyFeatures where CompanyId=@CompanyId and FeatureId=(select distinct id from Common.Feature where Name='No Supporting Documents') 
		  ) AS NSD ON NSD.CompanyId=J.CompanyId
		 LEFT JOIN
		  (
			 select  CompanyId,ISNULL(IsChecked,0) AS [BRM ISCHECKED] 
			 From    Common.CompanyFeatures where CompanyId=@CompanyId and FeatureId=(select distinct id from Common.Feature where Name='Bank Reconciliation') 
		   ) AS BRM ON BRM.CompanyId=J.CompanyId

		 where COA.CompanyId=@CompanyId 
		 and COA.ModuleType='Bean' 
		 AND  COA.Name in(select items from dbo.SplitToTable(CONVERT(nvarchar(max), (SELECT @COA_IS FOR XML PATH('')), 1),','))
		AND  SC.Name in(select items from dbo.SplitToTable(CONVERT(nvarchar(max), (SELECT @ServiceCompany FOR XML PATH('')), 1),','))
		 and CONVERT(DATE,J.DocDate) between @ISFromDate and @ISToDate AND J.DocumentState NOT IN ('Void','Cancelled','Parked','Reset') 
		 AND JD.DocType='Journal' AND JD.DocSubType<>'Opening Balance'
		 
	 ) as MS1

	 /*********Ending of Step 6.2.3.1 *************************/

	/*********** Ending of step 6.2.3.2.a **************/
	
	/*********** Ending of step 6.2.3.3 **************/
	/*********** Ending of step 6.2.3 **************/
	--END OF STEP 6.2: GETTING RECORDS BETWEEN @ISFromDate AND @ISToDate

	Fetch next from IncomeSheet_cursor into @COA_IS,@COA_IS_CODE,@COA_IS_CORDER,@COA_IS_RECORDER
End
Close IncomeSheet_cursor
Deallocate IncomeSheet_cursor

                           /******  End of step 6: Data for Income Statement coa's **********/

                           /******  Start of step 7: Data for Balance Sheet coa's **********/

Declare @COA_BSheet nvarchar(max)-- Balance Sheet coa
Declare @COA_BSheet_CODE nvarchar(max)--Balance Sheet coa code
Declare @COA_BSheet_CORDER INT --Balance Sheet coa class order
Declare @COA_BSheet_RECORDER INT --Balance Sheet AccountType order
Declare @BSheet_BF_CNT Bigint --used to store no of distinct dates between @BSBroughtForwardFromDate and @BSBroughtForwardToDate 
Declare @BsheetDoccurrency table (DocCurr nvarchar(10))--used to store distinct doc currencies between @FromDate and @ToDate and Between @BSBroughtForwardFromDate and @BSBroughtForwardToDate
Declare @BSheetDoccurrency1 table (DocCurr nvarchar(10)) --used to get distinct doc currencies from @BsheetDoccurrency
Declare @DCurrency NVarchar(10)-- used to store Doc currency which is used in  Dcurrency cursor
Declare @BSheet_BFCurrencyCNT bigint --used to store sum of count of no of days between @BFFD and @BFTD for corresponding @Dcocurrency of Selected Bsheet COA & count of dates between @BSFromDate and @BSToDate for open balance doc subtype
Declare @BSheet_BF_INTCount bigint --used to store  distinct count of dates between @BSBroughtForwardFromDate and @BSBroughtForwardToDate
Declare @BSheet_BF_OB_CNT bigint --used to store distinct count of dates between @BSFromDate and @BSToDate for open balance doc subtype


Declare Balancesheet_cursor cursor for select * from @COA_BalanceSheet
Open Balancesheet_cursor
Fetch next from Balancesheet_cursor into @COA_BSheet,@COA_BSheet_CODE,@COA_BSheet_CORDER,@COA_BSheet_RECORDER
while @@FETCH_STATUS=0
Begin
  /*** Step 7.1: Retained Earning COA information Getting ****/

	IF @COA_BSheet='Retained earnings'
	BEGIN
		Insert Into @GLReport
		Select  @COA_BSheet_CODE+'  '+@COA_BSheet as [COA Name],@COA_BSheet_RecOrder AS RecOrder, 'Balance B/F' as DocType,'' as DocSubType,'' as DocumentDescription,DATEADD(DAY,1,@RetainedEarningsToDate) as DocDate,'' as DocNo,'' as SystemRefNo,@ServiceCompany as  ServiceCompany,''  as EntityName,null as BaseDebit,null as BaseCredit,Sum([Base Net Profit]) as BaseBalance,null as ExchangeRate,BaseCurrency as BaseCurrency, DocCurrency as DocCurrency, null as DocDebit,null as DocCredit,Sum([Doc Net Profit]) as DocBalance/*IsMultiCurrency,*/,null as SegmentCategory1,null as SegmentCategory2, @MCS_Status,@SegmentStatus as SegmentStatus,null as CorrAccount,null as [Entity Type],null as [Vendor Type],null as PONo,null as Nature,null as [CreditTerms(Days)],null as DueDate,@NSdISChecked as [NSD ISCHECKED],null as [NO SUPPORT DOC],null as ItemCode,null as ItemDescription,null as Qty,null as Unit,null as UnitPrice,null as DiscountType,null as Discount,@BRMIsChecked as [BRM ISCHECKED],null as [ALLOWABLE/DISALLOWABLE],null as [Bank Clearing],null as ModeOfReceipt,null as ReversalDate,NULL as [Bank Reconcile],null as [Reversal Doc Ref],null as ClearingStatus,null as [Created By],null as [Created On],null as [Modified By],null as [Modified On],@COA_BSheet COA_Parameter,3 as classOrder
		From
		(
        --Step M:
		Select Sum([Base Net Profit]) [Base Net Profit],Sum([Doc Net Profit]) [Doc Net Profit],[Service Company], BaseCurrency,DocCurrency  
		FROM
		(
			--Step I
			SELECT Rank as Id,Name,Date,SUM([Base Income]) as 'Income',CreatedDate,ChartOfAccount,[Service Company],
				   SUM([Base Expenses]) AS 'Expenses',(SUM([Base Income]) + SUM([Base Expenses])) as 'Base Net Profit',   
					SUM([Doc Expenses]) AS 'Expenses1',(SUM([Doc Income]) + SUM([Doc Expenses])) as 'Doc Net Profit', 
				   year,month,
				   BaseCurrency,DocCurrency 
			FROM  
			   (  
				--Step H
				SELECT DENSE_RANK() over(partition by name order by   year,month  ASC)Rank,Name,date,Year,MONTH,
					   SUM([Base Income]) as 'Base Income', 
					   SUM([Base Expenses]) AS 'Base Expenses',
					   SUM([Doc Income]) as 'Doc Income', 
					   SUM([Doc Expenses]) AS 'Doc Expenses',
					   CreatedDate,ChartOfAccount,[Service Company],
					   BaseCurrency,DocCurrency
				FROM   
					 ( 
					--Step G
					 SELECT Class as 'Name',RecOrder,MONTH(A.CreatedDate) as 'Month',Year(A.CreatedDate) as 'Year',  
						   Left(DateName(Month,A.CreatedDate),3)+'-'+ Right(year(A.CreatedDate),2)  --AS 'month'          
						   as Date,  
						   cast(SUM([Base Income]) as decimal(10,2)) as 'Base Income',
						   cast(SUM([Base Expenses]) as decimal(10,2)) as 'Base Expenses',
						   cast(SUM([Doc Income]) as decimal(10,2)) as 'Doc Income',
						   cast(SUM([Doc Expenses]) as decimal(10,2)) as 'Doc Expenses',
						   CreatedDate,ChartOfAccount,[Service Company],
						    BaseCurrency,DocCurrency 
					FROM  
					(  
						-- Step F
						SELECT  COMPANYID, Class,RecOrder,CreatedDate,ChartOfAccount,[Service Company],
								case when Date=CreatedDate then [Base Income] ELSE 0.00 END as 'Base Income',
								case when Date=CreatedDate then [Base Expenses] ELSE 0.00 END as 'Base Expenses',
								case when Date=CreatedDate then [Doc Income] ELSE 0.00 END as 'Doc Income',
							   case when Date=CreatedDate then [Doc Expenses] ELSE 0.00 END as 'Doc Expenses',  
							   BaseCurrency,DocCurrency 
						FROM 
						(
							--Step E
							select ss.COMPANYID ,Class,RecOrder,Date,Isnull(Sum([Base Income]),0) 'Base Income',ChartOfAccount,[Service Company],
								   Isnull(Sum([Base Expenses]),0) 'Base Expenses',
								   Isnull(Sum([Doc Income]),0) 'Doc Income',
								   Isnull(Sum([Doc Expenses]),0) 'Doc Expenses',
                                   BaseCurrency,DocCurrency
							From 
							(
								--Step D
								Select Isnull(Sum([Base Income]),0) 'Base Income',
									   Isnull(Sum([Base Expenses]),0) 'Base Expenses',
									   Isnull(Sum([Doc Income]),0) 'Doc Income',
									   Isnull(Sum([Doc Expenses]),0) 'Doc Expenses',
									   COMPANYID,CONVERT(Date,DocDate) as Date,Class,RecOrder,ChartOfAccount,[Service Company],BaseCurrency,DocCurrency
								From 
								(
									--Step C
									Select DocDate,COMPANYID,Class,RecOrder,ChartOfAccount,
										   Case when [Base Income] <0 then -[Base Income] else -[Base Income] end as 'Base Income',
										   Case when [Base Expenses] <0 then -[Base Expenses] else -[Base Expenses] end as 'Base Expenses',
										   Case when [Doc Income] <0 then -[Doc Income] else -[Doc Income] end as 'Doc Income',
										   Case when [Doc Expenses] <0 then -[Doc Expenses] else -[Doc Expenses] end as 'Doc Expenses',
										   [Service Company],BaseCurrency,DocCurrency
									From 
									(
										--Step B
										Select IsNull((Sum([CA Dbt]) -Sum([CA Crt])),0) 'Base Income',IsNull((Sum([NCA Dbt]) -Sum([NCA Crt])),0) 'Base Expenses',
											   IsNull((Sum([CA Dbt1]) -Sum([CA Crt1])),0) 'Doc Income',IsNull((Sum([NCA Dbt1]) -Sum([NCA Crt1])),0) 'Doc Expenses',
											   DocDate,DocNo,COMPANYID,Class,RecOrder,ChartOfAccount,[Service Company],BaseCurrency,DocCurrency
										From 
										(  --step A
											Select COA.Class,AT.RecOrder,JD.DocNo,J.DocDate,COA.COMPANYID,JD.DocumentDetailId,COA.Name 'ChartOfAccount',Comp.Name as 'Service Company',
												   Case COA.Class when 'Income'   then Case When JD.DocCurrency=JD.BaseCurrency Then Isnull(JD.DocDebit,0) Else  Isnull(JD.BaseDebit,0) END  else 0.00 end as 'CA Dbt',
												   Case COA.Class when 'Income'   then Case When JD.DocCurrency=JD.BaseCurrency Then Isnull(JD.DocCredit,0) Else Isnull(JD.BaseCredit,0) END else 0.00 end as 'CA Crt',
												   Case COA.Class when 'Expenses' then  Case When JD.DocCurrency=JD.BaseCurrency Then Isnull(JD.DocDebit,0) Else  Isnull(JD.BaseDebit,0) END  else 0.00 end as 'NCA Dbt',
												   Case COA.Class when 'Expenses' then Case When JD.DocCurrency=JD.BaseCurrency Then Isnull(JD.DocCredit,0) Else Isnull(JD.BaseCredit,0) END else 0.00 end as 'NCA Crt',
												   Case COA.Class when 'Income'   then Isnull(JD.DocDebit,0)   else 0.00 end as 'CA Dbt1',
												   Case COA.Class when 'Income'   then Isnull(JD.DocCredit,0)  else 0.00 end as 'CA Crt1',
												   Case COA.Class when 'Expenses' then Isnull(JD.DocDebit,0)   else 0.00 end as 'NCA Dbt1',
												   Case COA.Class when 'Expenses' then Isnull(JD.DocCredit,0)  else 0.00 end as 'NCA Crt1',
												   JD.BaseCurrency,isnull(JD.DocCurrency,'SGD') DocCurrency
											From   Bean.ChartOfAccount COA
											Left  Join  Bean.AccountType AT ON AT.Id=COA.AccountTypeId AND AT.CompanyId=COA.CompanyId 
											Join   Bean.JournalDetail As JD on JD.COAId=COA.Id
											Join   Common.Company as Comp on Comp.Id=JD.ServiceCompanyId
											Join   Bean.Journal J on J.Id=JD.JournalId
											where  COA.Companyid=@CompanyId
												AND    CONVERT(DATE,J.DocDate) between @RetainedEarningsFromDate and @RetainedEarningsToDate
												AND J.DocumentState NOT IN ('Void','Cancelled','Parked','Reset') 
												AND  COA.Class in ('Income','Expenses') 
												AND  Comp.Name in(select items from dbo.SplitToTable(CONVERT(nvarchar(max), (SELECT @ServiceCompany FOR XML PATH('')), 1),','))
											-- End of step A
										) as A
										Group By DocDate,DocNo,COMPANYID,Class,RecOrder,ChartOfAccount,[Service Company],BaseCurrency,DocCurrency
										--End of Step B
									) as BH
									Group By DocDate,COMPANYID,Class,RecOrder,BH.[Base Income],BH.[Base Expenses],BH.[Doc Income],BH.[Doc Expenses],
									ChartOfAccount,[Service Company],BaseCurrency,DocCurrency
									-- End of step C
								) as HB
								Group By Class,RecOrder,COMPANYID,DocDate,ChartOfAccount,[Service Company],BaseCurrency,DocCurrency
								-- End of Step D
							)ss
							Group By COMPANYID,Class,RecOrder,Date,ChartOfAccount,[Service Company],BaseCurrency,DocCurrency
							--End of Step E
						) AS P
						Cross JOIN  
						(  
							SELECT  TOP (DATEDIFF(DAY, @RetainedEarningsFromDate, @RetainedEarningsToDate) + 1)
									CreatedDate = convert(Date,DATEADD(DAY, ROW_NUMBER() OVER(ORDER BY a.object_id) - 1, @RetainedEarningsFromDate))
							FROM    sys.all_objects a
							CROSS JOIN sys.all_objects b
						) AS PP  
						--End of Step F
					) AS A  
					GROUP BY Class,RecOrder,MONTH(A.CreatedDate),Year(A.CreatedDate),  CreatedDate,ChartOfAccount,[Service Company],
							 Left(DateName(Month,A.CreatedDate),3)+'-'+ Right(year(A.CreatedDate),2),  --AS 'month'  
							 BaseCurrency,DocCurrency
					 --End of Step G
				) AS AA  
				Group BY name,RecOrder,date,Year,MONTH ,CreatedDate,ChartOfAccount,[Service Company],BaseCurrency,DocCurrency
				--End of Step H
			) AS P  
			GROUP BY Name,Date,Rank,Year,MONTH ,CreatedDate  ,ChartOfAccount,[Service Company],BaseCurrency,DocCurrency
			-- End of Step I
		) Hari
		Group By [Service Company],BaseCurrency,DocCurrency
		--End of Step J
		
		--STEP L: Performing union on step k with step M
		union all

		--STEP K: Grouping Basebalance and DocBalance by ServiceCompany,BaseCurrency,DocCurrency
		Select sum(BaseBalance) BaseBalance,sum(DocBalance) DocBalance,ServiceCompany,BaseCurrency,DocCurrency
		From
		(
		   --STEP J: Getting openbalance Doc and base amounts WRT to Sercice company
			SELECT isnull((isnull(Case when JD.BaseCurrency=JD.DocCurrency and JD.BaseDebit is null then JD.DocDebit else  JD.BaseDebit end ,0)-isnull(Case when JD.DocCurrency=JD.BaseCurrency and JD.BaseCredit is null then JD.DocCredit else JD.BaseCredit end,0)),0) as BaseBalance,			
					isnull((isnull(JD.DocDebit,0)-isnull(JD.DocCredit,0)),0) as DocBalance,isnull(JD.DocCurrency,'SGD') as DocCurrency,JD.BaseCurrency,SC.Name ServiceCompany			
			From    Bean.Journal J
			join    Bean.JournalDetail JD on JD.JournalId=J.Id
			Join    Bean.ChartOfAccount COA on COA.Id=JD.COAId
			Join  Common.Company as SC on SC.Id=J.ServiceCompanyId
			where  COA.Companyid=@CompanyId and COA.ModuleType='Bean' 
				   AND  CONVERT(DATE,J.DocDate) between @RetainedEarningsFromDate and @RetainedEarningsToDate
				   AND J.DocumentState NOT IN ('Void','Cancelled','Parked','Reset') 
			       AND JD.DocSubType = 'Opening Balance' 
				   AND  SC.Name in(select items from dbo.SplitToTable(CONVERT(nvarchar(max), (SELECT @ServiceCompany FOR XML PATH('')), 1),','))
			--and COA.Class in ('Income','Expenses')
		) RE1 
		Group By ServiceCompany,BaseCurrency,DocCurrency
	)RE2
	Group by [Service Company],BaseCurrency,DocCurrency
	-- )RE3
	End --rebegin
	
    /*** End of Step 7.1: Retained Earning COA information Getting ****/

	/*** Step 7.2: OTHER THAN Retained Earning COA information Getting ****/
	ELSE IF @COA_BSheet<>'Retained earnings'
	BEGIN
	/** Step 7.2.1: GETTING sum of  BROUGHT FORWARDED BALANCES BETWEEN @BSBroughtForwardFromDate AND @BSBroughtForwardToDate & between @BSFromDate and @BSToDate  for docsubtye=open balance****/

	/*** Step 7.2.1.a : getting Distinct Doc currencies between @BSFromDate and @BSToDate for corresponding @COA_BSheet ****/
	        IF EXISTS (SELECT * FROM @BsheetDoccurrency)
			BEGIN
				  DELETE   FROM @BsheetDoccurrency
			END

			IF EXISTS (SELECT * FROM @BSheetDoccurrency1)
			BEGIN
				  DELETE   FROM @BSheetDoccurrency1
			END

	        Insert Into @BsheetDoccurrency
			SELECT		Distinct isnull(JD.DocCurrency,'SGD') DocCurrency
			From        Bean.JournalDetail JD 
			Inner Join  Bean.Journal J on J.Id=JD.JournalId
			Inner Join  Bean.ChartOfAccount COA on COA.Id=JD.COAId
			Left Join   Bean.AccountType AT ON AT.Id=COA.AccountTypeId AND AT.CompanyId=COA.CompanyId
			Inner Join  Common.Company as SC on SC.Id=J.ServiceCompanyId
			WHERE       COA.CompanyId=@CompanyId
						AND  COA.Name in(select items from dbo.SplitToTable(CONVERT(nvarchar(max), (SELECT @COA_BSheet FOR XML PATH('')), 1),','))
						AND  SC.Name in(select items from dbo.SplitToTable(CONVERT(nvarchar(max), (SELECT @ServiceCompany FOR XML PATH('')), 1),','))
						AND CONVERT(DATE,J.DocDate) BETWEEN @BSFromDate AND @BSToDate
						AND COA.ModuleType='Bean'
						AND J.DocumentState NOT IN ('Void','Cancelled','Parked','Reset')
						
	/*** End of Step 7.2.1.a : getting Distinct Doc currencies between @BSFromDate and @BSToDate for corresponding @COA_BSheet ****/

	/*** Step 7.2.1.b : getting Distinct Doc currencies between @BSBroughtForwardFromDate and @BSBroughtForwardToDate for corresponding @COA_BSheet ****/
			--Insert Into @BsheetDoccurrency
			UNION ALL
			SELECT		Distinct isnull(JD.DocCurrency,'SGD') DocCurrency
			From        Bean.JournalDetail JD 
			Inner Join  Bean.Journal J on J.Id=JD.JournalId
			Inner Join  Bean.ChartOfAccount COA on COA.Id=JD.COAId
			Inner Join  Common.Company as SC on SC.Id=J.ServiceCompanyId
			WHERE       COA.CompanyId=@CompanyId
						AND  COA.Name in(select items from dbo.SplitToTable(CONVERT(nvarchar(max), (SELECT @COA_BSheet FOR XML PATH('')), 1),','))
						AND  SC.Name in(select items from dbo.SplitToTable(CONVERT(nvarchar(max), (SELECT @ServiceCompany FOR XML PATH('')), 1),','))
						AND CONVERT(DATE,J.DocDate) BETWEEN @BSBroughtForwardFromDate AND @BSBroughtForwardToDate
						AND COA.ModuleType='Bean'
						AND J.DocumentState NOT IN ('Void','Cancelled','Parked','Reset')
						
	/*** End of Step 7.2.1.b : getting Distinct Doc currencies between @BSBroughtForwardFromDate and @BSBroughtForwardToDate for corresponding @COA_BSheet ****/

	/***Step 7.2.1.c: Getting distinct doccurrencies from BSheetDoccurrency into BSheetDoccurrency1 ***/

	        Insert Into @BSheetDoccurrency1
		    Select Distinct DocCurr From @BsheetDoccurrency
			

			Declare DCurrency cursor for select * from @BSheetDoccurrency1
			Open DCurrency
			Fetch Next From DCurrency Into @DCurrency
			while @@FETCH_STATUS=0
			Begin
			/***Step 7.2.1.d: Getting count of distinct docdates for currosponding DocCurrency of selected BSheet COA between @BSBroughtForwardFromDate and @BSBroughtForwardToDate  & @BSFromDate and @BSToDate for docsubtype= open balance ***/
				
				--Step 7.2.1.d.1: Getting count of distinct docdates for currosponding DocCurrency of selected BSheet COA between @BSBroughtForwardFromDate and @BSBroughtForwardToDate 
				SELECT		@BSheet_BF_INTCount=COUNT(DISTINCT CONVERT(DATE,J.DocDate))		
			    From        Bean.JournalDetail JD 
				Inner Join  Bean.Journal J on J.Id=JD.JournalId
				Inner Join  Bean.ChartOfAccount COA on COA.Id=JD.COAId
				Inner Join  Common.Company as SC on SC.Id=J.ServiceCompanyId
				WHERE       COA.CompanyId=@CompanyId
							AND  COA.Name in(select items from dbo.SplitToTable(CONVERT(nvarchar(max), (SELECT @COA_BSheet FOR XML PATH('')), 1),','))
							AND  SC.Name in(select items from dbo.SplitToTable(CONVERT(nvarchar(max), (SELECT @ServiceCompany FOR XML PATH('')), 1),','))
							AND CONVERT(DATE,J.DocDate) BETWEEN @BSBroughtForwardFromDate AND @BSBroughtForwardToDate
							AND ISNULL(JD.DocCurrency,'SGD') = @DCurrency
							AND COA.ModuleType='Bean'
							AND J.DocumentState NOT IN ('Void','Cancelled','Parked','Reset')
							
				--print @BSheet_BFCurrencyCNT
                --End of Step 7.2.1.d.1: 

				--Step 7.2.1.d.2: Getting count of distinct docdates for currosponding DocCurrency of selected BSheet COA between @BSFromDate and @BSToDate for docsubtype= open balance
				SELECT		@BSheet_BF_OB_CNT=COUNT(DISTINCT CONVERT(DATE,J.DocDate))		
			    From        Bean.JournalDetail JD 
				Inner Join  Bean.Journal J on J.Id=JD.JournalId
				Inner Join  Bean.ChartOfAccount COA on COA.Id=JD.COAId
				Inner Join  Common.Company as SC on SC.Id=J.ServiceCompanyId
				WHERE       COA.CompanyId=@CompanyId
							AND  COA.Name in(select items from dbo.SplitToTable(CONVERT(nvarchar(max), (SELECT @COA_BSheet FOR XML PATH('')), 1),','))
							AND  SC.Name in(select items from dbo.SplitToTable(CONVERT(nvarchar(max), (SELECT @ServiceCompany FOR XML PATH('')), 1),','))
							AND CONVERT(DATE,J.DocDate) BETWEEN @BSFromDate AND @BSToDate
							AND ISNULL(JD.DocCurrency,'SGD') = @DCurrency
							AND COA.ModuleType='Bean'
							AND J.DocumentState NOT IN ('Void','Cancelled','Parked','Reset')
							AND J.DocType='Journal' and j.DocsubType='Opening Balance'
				--print @BSheet_BFCurrencyCNT
                --End of Step 7.2.1.d.2: 

				--Step 7.2.1.d.3:sum of --Step 7.2.1.d.1 and --Step 7.2.1.d.2 and restults assigned to @BSheet_BFCurrencyCNT
				SELECT @BSheet_BFCurrencyCNT=@BSheet_BF_INTCount+@BSheet_BF_OB_CNT

            /***End of Step 7.2.1.d: Getting count of distinct docdates for currosponding DocCurrency of selected BSheet COA between @BSBroughtForwardFromDate and @BSBroughtForwardToDate ***/

			/**** Step 7.2.1.e:@BSheet_BFCurrencyCNT=0 (i.e. there are no transactions in choosen doc currency for getting Brought forwarded balance. ***/
			--In this case We replace docbalance and basebalance as0.00 
				IF @BSheet_BFCurrencyCNT=0
				Begin
					Insert Into @GLReport
					select  @COA_BSheet_CODE+'  '+@COA_BSheet as [COA Name],@COA_BSheet_RecOrder AS RecOrder, 'Balance B/F' as DocType,'' as DocSubType,'' as DocumentDescription,@BSFromDate as DocDate,'' as DocNo,'' as SystemRefNo,@ServiceCompany as  ServiceCompany,''  as EntityName,null as BaseDebit,null as BaseCredit,0.00 as BaseBalance,null as ExchangeRate,'SGD' as BaseCurrency, @DCurrency as DocCurrency, null as DocDebit,null as DocCredit,0.00 as DocBalance/*IsMultiCurrency,*/,null as SegmentCategory1,null as SegmentCategory2, @MCS_Status,@SegmentStatus as SegmentStatus,null as CorrAccount,null as [Entity Type],null as [Vendor Type],null as PONo,null as Nature,null as [CreditTerms(Days)],null as DueDate,@NSdISChecked as [NSD ISCHECKED],null as [NO SUPPORT DOC],null as ItemCode,null as ItemDescription,null as Qty,null as Unit,null as UnitPrice,null as DiscountType,null as Discount,@BRMIsChecked as [BRM ISCHECKED],null as [ALLOWABLE/DISALLOWABLE],null as [Bank Clearing],null as ModeOfReceipt,null as ReversalDate,NULL as [Bank Reconcile],null as [Reversal Doc Ref],null as ClearingStatus,null as [Created By],null as [Created On],null as [Modified By],null as [Modified On],@COA_BSheet COA_Parameter,@COA_BSheet_CORDER as classOrder      
				End
			/**** Step End of 7.2.1.e: @BSheet_BFCurrencyCNT=0 (i.e. there are no transactions in choosen doc currency for getting Brought forwarded balance. ***/
			
			/**** Step 7.2.1.f:  @BSheet_BFCurrencyCNT<>0 (i.e. there are few transactions in choosen doc currency for getting Brought forwarded balance. ***/
				ELSE IF @BSheet_BFCurrencyCNT<>0 
				BEGIN
			      
					  INSERT INTO @GLReport
					  SELECT  @COA_BSheet_CODE+'  '+@COA_BSheet as [COA Name],@COA_BSheet_RecOrder AS RecOrder, 'Balance B/F' as DocType,'' as DocSubType,'' as DocumentDescription,@BSFromDate as DocDate,'' as DocNo,'' as SystemRefNo,@ServiceCompany as  ServiceCompany,''  as EntityName,null as BaseDebit,null as BaseCredit,SUM(BaseBalance) as BaseBalance,null as ExchangeRate,BaseCurrency/*null as BaseCurrency*/, DocCurrency/*null as DocCurrency*/, null as DocDebit,null as DocCredit,SUM(DocBalance) as DocBalance/*IsMultiCurrency,*/,null as SegmentCategory1,null as SegmentCategory2, @MCS_Status,@SegmentStatus as SegmentStatus,null as CorrAccount,null as [Entity Type],null as [Vendor Type],null as PONo,null as Nature,null as [CreditTerms(Days)],null as DueDate,@NSdISChecked as [NSD ISCHECKED],null as [NO SUPPORT DOC],null as ItemCode,null as ItemDescription,null as Qty,null as Unit,null as UnitPrice,null as DiscountType,null as Discount,@BRMIsChecked as [BRM ISCHECKED],null as [ALLOWABLE/DISALLOWABLE],null as [Bank Clearing],null as ModeOfReceipt,null as ReversalDate,NULL as [Bank Reconcile],null as [Reversal Doc Ref],null as ClearingStatus,null as [Created By],null as [Created On],null as [Modified By],null as [Modified On],@COA_BSheet COA_Parameter,@COA_BSheet_CORDER as classOrder
					  FROM
					  (
						  SELECT SUM(BaseBalance) as BaseBalance,SUM(DocBalance) as DocBalance,DocCurrency,BaseCurrency
						  FROM
						  (	
								SELECT		isnull((isnull(Case when JD.BaseCurrency=JD.DocCurrency and JD.BaseDebit is null then JD.DocDebit else  JD.BaseDebit end ,0)-isnull(Case when JD.DocCurrency=JD.BaseCurrency and JD.BaseCredit is null then JD.DocCredit else JD.BaseCredit end,0)),0) as BaseBalance,			
											isnull((isnull(JD.DocDebit,0)-isnull(JD.DocCredit,0)),0) as DocBalance,isnull(JD.DocCurrency,'SGD') as DocCurrency,JD.BaseCurrency			
								From        Bean.JournalDetail JD 
								Inner Join  Bean.Journal J on J.Id=JD.JournalId
								Inner Join  Bean.ChartOfAccount COA on COA.Id=JD.COAId
								Inner Join  Common.Company as SC on SC.Id=J.ServiceCompanyId
								WHERE       COA.CompanyId=@CompanyId
											AND  COA.Name in(select items from dbo.SplitToTable(CONVERT(nvarchar(max), (SELECT @COA_BSheet FOR XML PATH('')), 1),','))
											AND  SC.Name in(select items from dbo.SplitToTable(CONVERT(nvarchar(max), (SELECT @ServiceCompany FOR XML PATH('')), 1),','))
											AND CONVERT(DATE,J.DocDate) BETWEEN @BSBroughtForwardFromDate AND @BSBroughtForwardToDate
											AND ISNULL(JD.DocCurrency,'SGD') = @DCurrency
											AND COA.ModuleType='Bean'
											AND J.DocumentState NOT IN ('Void','Cancelled','Parked','Reset')
						  )DT1
						  Group By DocCurrency,BaseCurrency

						  union all

						  SELECT SUM(BaseBalance) as BaseBalance,SUM(DocBalance) as DocBalance,DocCurrency,BaseCurrency
						  FROM
						  (	
								SELECT		isnull((isnull(Case when JD.BaseCurrency=JD.DocCurrency and JD.BaseDebit is null then JD.DocDebit else  JD.BaseDebit end ,0)-isnull(Case when JD.DocCurrency=JD.BaseCurrency and JD.BaseCredit is null then JD.DocCredit else JD.BaseCredit end,0)),0) as BaseBalance,			
											isnull((isnull(JD.DocDebit,0)-isnull(JD.DocCredit,0)),0) as DocBalance,isnull(JD.DocCurrency,'SGD') as DocCurrency,JD.BaseCurrency			
								From        Bean.JournalDetail JD 
								Inner Join  Bean.Journal J on J.Id=JD.JournalId
								Inner Join  Bean.ChartOfAccount COA on COA.Id=JD.COAId
								Inner Join  Common.Company as SC on SC.Id=J.ServiceCompanyId
								WHERE       COA.CompanyId=@CompanyId
											AND  COA.Name in(select items from dbo.SplitToTable(CONVERT(nvarchar(max), (SELECT @COA_BSheet FOR XML PATH('')), 1),','))
											AND  SC.Name in(select items from dbo.SplitToTable(CONVERT(nvarchar(max), (SELECT @ServiceCompany FOR XML PATH('')), 1),','))
											AND CONVERT(DATE,J.DocDate) BETWEEN @BSFromDate AND @BSToDate
											AND ISNULL(JD.DocCurrency,'SGD') = @DCurrency
											AND COA.ModuleType='Bean'
											AND J.DocumentState NOT IN ('Void','Cancelled','Parked','Reset')
											AND J.DocType='Journal' and j.DocsubType='Opening Balance'
						  )DT1
						  Group By DocCurrency,BaseCurrency
				     )ext3
					 Group By DocCurrency,BaseCurrency
				END

			/**** End of Step 7.2.1.f:  @BSheet_BFCurrencyCNT<>0 (i.e. there are few transactions in choosen doc currency for getting Brought forwarded balance. ***/
			
				Fetch Next From DCurrency Into @DCurrency
			End
			Close DCurrency
			Deallocate DCurrency
		/** END OFStep 7.2.1: GETTING BROUGHT FORWARDED BALANCE BETWEEN @BSBroughtForwardFromDate AND @BSBroughtForwardToDate****/		

	--	 /** END OF Step 7.2.1.3: @BSheet_BF_CNT<>0 ******/

	--/** End Of Step 7.2.1: GETTING BROUGHT FORWARDED BALANCE BETWEEN @BSBroughtForwardFromDate AND @BSBroughtForwardToDate****/

	--STEP 7.2.2: GETTING RECORDS BETWEEN @BSFromDate AND @BSToDate

	 /********* Step 7.2.2.1 : Getting records when documentdetailid is 0  AND JD.DocType<>'Journal' *******************/
 
	 /*********** Step 7.2.2.1.3 : here we join MS1 (Step 7.2.2.1.1) and FCA (Step 7.2.2.1.2.a)  *****************/
	 /*********** Taking all columns from MS1 and corresponding Account column from FCA ****************/
	 Insert Into @GLReport
	 select [COA Name],RecOrder,DocType,DocSubType,DocumentDescription,DocDate,DocNo,SystemRefNo,ServiceCompany,EntityName,BaseDebit,BaseCredit,BaseBalance,ExchangeRate,BaseCurrency,DocCurrency,DocDebit,DocCredit,DocBalance,/*IsMultiCurrency,*/SegmentCategory1,SegmentCategory2,MCS_Status,Status,  /*FCA.CorrAccount*/  CorrAccount,[Entity Type],[Vendor Type],PONo,Nature,[CreditTerms(Days)],DueDate,[NSD ISCHECKED],[NO SUPPORT DOC],ItemCode,ItemDescription,Qty,Unit,UnitPrice,DiscountType,Discount,[BRM ISCHECKED],[ALLOWABLE/DISALLOWABLE],[Bank Clearing],ModeOfReceipt,ReversalDate,[Bank Reconcile],[Reversal Doc Ref],ClearingStatus,[Created By],[Created On],[Modified By],[Modified On],COA_Parameter,classOrder

	 from
	 (
		 /********* Step 7.2.2.1.1 : Getting records except coresponding account column ************************************/
		 Select      COA.Code+'  '+ COA.Name as 'COA Name', JD.DocType,JD.DocSubType,
					 case when J.DocType<>'Journal' then J.DocumentDescription
					      when J.DocType='Journal' then
						       Case when J.DocSubType='Opening Balance' then 
								   case when Jd.AccountDescription is null then J.DocumentDescription else Jd.AccountDescription  end
								 when J.DocSubType<>'Opening Balance' then J.DocumentDescription
							end
					  end as DocumentDescription, 
					 J.DocDate,case when J.DocType='Journal' and J.DocSubType='Opening Balance' then JD.SystemRefNo else JD.DocNo end as DocNo,J.ActualSysRefNo SystemRefNo, SC.Name ServiceCompany,case when J.DocType<>'Journal' then E.Name when J.DocType='Journal' then EJ.Name end as EntityName,case when JD.BaseCurrency=JD.DocCurrency and JD.BaseDebit is null then JD.DocDebit else JD.BaseDebit end BaseDebit,case when JD.BaseCurrency=JD.DocCurrency and JD.BaseCredit is null then JD.DocCredit else JD.BaseCredit end BaseCredit,isnull((isnull(Case when JD.BaseCurrency=JD.DocCurrency and JD.BaseDebit is null then JD.DocDebit else  JD.BaseDebit end ,0)-isnull(Case when JD.DocCurrency=JD.BaseCurrency and JD.BaseCredit is null then JD.DocCredit else JD.BaseCredit end,0)),0) as BaseBalance ,jd.ExchangeRate,jd.BaseCurrency,isnull(JD.DocCurrency,'SGD') DocCurrency,JD.DocDebit,JD.DocCredit,isnull((isnull(JD.DocDebit,0)-isnull(JD.DocCredit,0)),0) as DocBalance,/*IsMultiCurrency,*/jd.SegmentCategory1,JD.SegmentCategory2,Case when MCS.Status=1 then 1 else 0 end MCS_Status, SM3.Status,/*COA.Name as [Corr Account],*/
					 JD.JournalId,
					 case when J.DocType<>'Journal'
					      then
				             Case when E.IsCustomer=1 then 'Customer' when E.IsVendor=1 then 'Vendor' end 
			              when J.DocType='Journal'
                          then
                             Case when EJ.IsCustomer=1 then 'Customer' when EJ.IsVendor=1 then 'Vendor' end 
			              end 
			          as [Entity Type],
                     case when J.DocType<>'Journal' then E.VendorType 
			              when J.DocType='Journal' then EJ.VendorType
			         end
			         as [Vendor Type],
					 J.PONo,JD.Nature,TP.TOPValue as [CreditTerms(Days)],J.DueDate,NSD.[NSD ISCHECKED],CASE WHEN J.IsNoSupportingDocs=0 THEN 'NO' WHEN J.IsNoSupportingDocs=1 THEN 'YES' END AS [NO SUPPORT DOC],JD.ItemCode,JD.ItemDescription,JD.Qty,JD.Unit,JD.UnitPrice,JD.DiscountType,JD.Discount,[BRM ISCHECKED],case when JD.AllowDisAllow=0 then 'NO' when JD.AllowDisAllow=1 then 'YES' END AS [ALLOWABLE/DISALLOWABLE],JD.ClearingDate AS [Bank Clearing],J.ModeOfReceipt,J.ReversalDate,
					 case when J.IsBankReconcile=0 then 'NO' when J.IsBankReconcile=1 then 'YES' end as [Bank Reconcile],case when J.IsAutoReversalJournal in (1) then J.SystemReferenceNo  end as [Reversal Doc Ref],JD.ClearingStatus,J.UserCreated as [Created By],J.CreatedDate as [Created On],J.ModifiedBy as [Modified By],J.ModifiedDate as [Modified On],@COA_BSheet as COA_Parameter,
					 Case when COA.Class in('Assets','Asset') then 1 
									when COA.Class='Liabilities' then 2
									when COA.Class='Equity' then 3
									when COA.Class='Income' then 4
									when COA.Class='Expenses' then 5 end as classOrder,AT.RecOrder,CCOA.Name as CorrAccount
		 From        Bean.JournalDetail JD 
		 Inner Join  Bean.Journal J on J.Id=JD.JournalId
		 Inner Join  Bean.ChartOfAccount COA on COA.Id=JD.COAId
		 Left  Join  Bean.ChartOfAccount CCOA on CCOA.Id=JD.CorrAccountId
		 Left Join   Bean.AccountType AT ON AT.Id=COA.AccountTypeId AND AT.CompanyId=COA.CompanyId
		 Inner Join  Common.Company as SC on SC.Id=J.ServiceCompanyId
		 Left  join  Bean.Entity as E on E.Id=J.EntityId and J.DocType<>'Journal'
		 Left  Join  Bean.Entity as EJ on EJ.Id=JD.EntityId and J.DocType='Journal' 
		 Left join   Bean.SegmentMaster as SM1 on SM1.Id=JD.SegmentMasterid1 and J.CompanyId=SM1.CompanyId
		 Left join   Bean.SegmentMaster as SM2 on SM2.Id=JD.SegmentMasterid1 and J.CompanyId=SM2.CompanyId
		 Left join   Bean.MultiCurrencySetting MCS on MCS.companyId=J.CompanyId
		 Left Join 
		  (
			  select distinct CompanyId,status
			  from
			  (
				select CompanyId, Status from bean.SegmentMaster where CompanyId=@CompanyId
			  ) as st1
		  ) SM3 on SM3.companyid=J.CompanyId 
		 Left join   Common.TermsOfPayment as TP on TP.Id=JD.CreditTermsId
		 LEFT JOIN
		  (
			 select   CompanyId,ISNULL(IsChecked,0) AS [NSD ISCHECKED]  
			 From     Common.CompanyFeatures where CompanyId=@CompanyId and FeatureId=(select distinct id from Common.Feature where Name='No Supporting Documents') 
		  ) AS NSD ON NSD.CompanyId=J.CompanyId
		 LEFT JOIN
		  (
			 select  CompanyId,ISNULL(IsChecked,0) AS [BRM ISCHECKED] 
			 From    Common.CompanyFeatures where CompanyId=@CompanyId and FeatureId=(select distinct id from Common.Feature where Name='Bank Reconciliation') 
		   ) AS BRM ON BRM.CompanyId=J.CompanyId

		 where COA.CompanyId=@CompanyId and  JD.DocumentDetailId='00000000-0000-0000-0000-000000000000' and COA.ModuleType='Bean' 
		 AND  COA.Name in(select items from dbo.SplitToTable(CONVERT(nvarchar(max), (SELECT @COA_BSheet FOR XML PATH('')), 1),','))
		AND  SC.Name in(select items from dbo.SplitToTable(CONVERT(nvarchar(max), (SELECT @ServiceCompany FOR XML PATH('')), 1),','))
		 and CONVERT(DATE,J.DocDate) between @BSFromDate and @BSToDate AND J.DocumentState NOT IN ('Void','Cancelled','Parked','Reset') 
		 AND JD.DocType<>'Journal'
		 
	 ) as MS1
	 /*********Ending of Step 7.2.2.1.1 *************************/
	/*********** Ending of step 7.2.2.1.3 **************/
	/*********** Ending of step 7.2.2.1 **************/

	union all

/********* Step 7.2.2.2 : Getting records when documentdetailid is  not 0 AND JD.DocType<>'Journal' *******************/
 /*********** Step 7.2.2.2.3 : here we join MS1 (Step 7.2.2.2.1) and FCA (Step 7.2.2.2.2) *****************/
 /*********** Taking all columns from MS1 and corresponding Account column from FCA ****************/

	 select [COA Name],RecOrder,DocType,DocSubType,DocumentDescription,DocDate,DocNo,SystemRefNo,ServiceCompany,EntityName,BaseDebit,BaseCredit,BaseBalance,ExchangeRate,BaseCurrency,DocCurrency,DocDebit,DocCredit,DocBalance,/*IsMultiCurrency,*/SegmentCategory1,SegmentCategory2,MCS_Status,Status, /*FCA.CorrAccount*/ CorrAccount,[Entity Type],[Vendor Type],PONo,Nature,[CreditTerms(Days)],DueDate,[NSD ISCHECKED],[NO SUPPORT DOC],ItemCode,ItemDescription,Qty,Unit,UnitPrice,DiscountType,Discount,[BRM ISCHECKED],[ALLOWABLE/DISALLOWABLE],[Bank Clearing],ModeOfReceipt,ReversalDate,[Bank Reconcile],[Reversal Doc Ref],ClearingStatus,[Created By],[Created On],[Modified By],[Modified On],COA_Parameter,classOrder

	 from
	 (
		  /********* Step 7.2.2.2.1 : Getting records except coresponding account column ************************************/
		 select       COA.Code+'  '+ COA.Name as 'COA Name', JD.DocType,JD.DocSubType,
					  case when J.DocType<>'Journal' then J.DocumentDescription
					      when J.DocType='Journal'
						  then
						    Case when J.DocSubType='Opening Balance'
							     then 
								   case when Jd.AccountDescription is null then J.DocumentDescription else Jd.AccountDescription  end
								 when J.DocSubType<>'Opening Balance' then J.DocumentDescription
							end
					  end as DocumentDescription, 
					  J.DocDate,case when J.DocType='Journal' and J.DocSubType='Opening Balance' then JD.SystemRefNo else JD.DocNo end as DocNo,J.ActualSysRefNo SystemRefNo, SC.Name ServiceCompany,case when J.DocType<>'Journal' then E.Name when J.DocType='Journal' then EJ.Name end as EntityName,case when JD.BaseCurrency=JD.DocCurrency and JD.BaseDebit is null then JD.DocDebit else JD.BaseDebit end BaseDebit,case when JD.BaseCurrency=JD.DocCurrency and JD.BaseCredit is null then JD.DocCredit else JD.BaseCredit end BaseCredit,isnull((isnull(Case when JD.BaseCurrency=JD.DocCurrency and JD.BaseDebit is null then JD.DocDebit else  JD.BaseDebit end ,0)-isnull(Case when JD.DocCurrency=JD.BaseCurrency and JD.BaseCredit is null then JD.DocCredit else JD.BaseCredit end,0)),0) as BaseBalance ,jd.ExchangeRate,jd.BaseCurrency,isnull(JD.DocCurrency,'SGD') DocCurrency,JD.DocDebit,JD.DocCredit,isnull((isnull(JD.DocDebit,0)-isnull(JD.DocCredit,0)),0) as DocBalance,IsMultiCurrency,jd.SegmentCategory1,JD.SegmentCategory2,Case when MCS.Status=1 then 1 else 0 end MCS_Status, SM3.Status,/*COA.Name as [Corr Account],*/
					  JD.JournalId,
					  case when J.DocType<>'Journal'
					      then
				             Case when E.IsCustomer=1 then 'Customer' when E.IsVendor=1 then 'Vendor' end 
			              when J.DocType='Journal'
                          then
                             Case when EJ.IsCustomer=1 then 'Customer' when EJ.IsVendor=1 then 'Vendor' end 
			              end 
			          as [Entity Type],
                     case when J.DocType<>'Journal' then E.VendorType 
			              when J.DocType='Journal' then EJ.VendorType
			         end
			         as [Vendor Type],
					  J.PONo,JD.Nature,TP.TOPValue as [CreditTerms(Days)],J.DueDate,NSD.[NSD ISCHECKED],CASE WHEN J.IsNoSupportingDocs=0 THEN 'NO' WHEN J.IsNoSupportingDocs=1 THEN 'YES' END AS [NO SUPPORT DOC],JD.ItemCode,JD.ItemDescription,JD.Qty,JD.Unit,JD.UnitPrice,JD.DiscountType,JD.Discount,[BRM ISCHECKED],case when JD.AllowDisAllow=0 then 'NO' when JD.AllowDisAllow=1 then 'YES' END AS [ALLOWABLE/DISALLOWABLE],JD.ClearingDate AS [Bank Clearing],J.ModeOfReceipt,J.ReversalDate,
					  case when J.IsBankReconcile=0 then 'NO' when J.IsBankReconcile=1 then 'YES' end as [Bank Reconcile],case when J.IsAutoReversalJournal in (1) then J.SystemReferenceNo  end as [Reversal Doc Ref],JD.ClearingStatus,J.UserCreated as [Created By],J.CreatedDate as [Created On],J.ModifiedBy as [Modified By],J.ModifiedDate as [Modified On],@COA_BSheet as COA_Parameter,
					  Case when COA.Class in('Assets','Asset') then 1 
						   when COA.Class='Liabilities' then 2
						   when COA.Class='Equity' then 3
						   when COA.Class='Income' then 4
						   when COA.Class='Expenses' then 5 end as classOrder,AT.RecOrder,CCOA.Name as CorrAccount
		 From         Bean.JournalDetail JD 
		 Inner Join   Bean.Journal J on J.Id=JD.JournalId
		 Inner Join   Bean.ChartOfAccount COA on COA.Id=JD.COAId
		 Left  Join   Bean.ChartOfAccount CCOA on CCOA.Id=JD.CorrAccountId
		 Left Join   Bean.AccountType AT ON AT.Id=COA.AccountTypeId AND AT.CompanyId=COA.CompanyId
		 Inner Join   Common.Company as SC on SC.Id=J.ServiceCompanyId
		 Left  join  Bean.Entity as E on E.Id=J.EntityId and J.DocType<>'Journal'
		 Left  Join  Bean.Entity as EJ on EJ.Id=JD.EntityId and J.DocType='Journal' 
		 Left join    Bean.SegmentMaster as SM1 on SM1.Id=JD.SegmentMasterid1 and J.CompanyId=SM1.CompanyId
		 Left join    Bean.SegmentMaster as SM2 on SM2.Id=JD.SegmentMasterid1 and J.CompanyId=SM2.CompanyId
		 Left join    Bean.MultiCurrencySetting MCS on MCS.companyId=J.CompanyId
		 Left Join 
		  (
			  Select distinct CompanyId,status
			  From
			  (
				select CompanyId, Status from bean.SegmentMaster where CompanyId=@CompanyId
			  ) as st1
		  ) SM3 on SM3.companyid=J.CompanyId 
		 Left join Common.TermsOfPayment as TP on TP.Id=JD.CreditTermsId
		 LEFT JOIN
		  (
			 Select CompanyId,ISNULL(IsChecked,0) AS [NSD ISCHECKED]  
			 From   Common.CompanyFeatures where CompanyId=@CompanyId and FeatureId=(select distinct id from Common.Feature where Name='No Supporting Documents') 
		  ) AS NSD ON NSD.CompanyId=J.CompanyId
		 LEFT JOIN
		  (
			 Select  CompanyId,ISNULL(IsChecked,0) AS [BRM ISCHECKED] 
			 From    Common.CompanyFeatures where CompanyId=@CompanyId and FeatureId=(select distinct id from Common.Feature where Name='Bank Reconciliation') 
		   ) AS BRM ON BRM.CompanyId=J.CompanyId

		 where COA.CompanyId=@CompanyId and  JD.DocumentDetailId<>'00000000-0000-0000-0000-000000000000' and COA.ModuleType='Bean'
		AND  COA.Name in(select items from dbo.SplitToTable(CONVERT(nvarchar(max), (SELECT @COA_BSheet FOR XML PATH('')), 1),',')) 
		AND  SC.Name in(select items from dbo.SplitToTable(CONVERT(nvarchar(max), (SELECT @ServiceCompany FOR XML PATH('')), 1),','))
		 and CONVERT(DATE,J.DocDate) between @BSFromDate and @BSToDate AND J.DocumentState NOT IN ('Void','Cancelled','Parked','Reset')
		 AND JD.DocType<>'Journal'
	 ) as MS1
	 /*********Ending of Step Step 7.2.2.2.1 *************************/
	/*********** Ending of step Step 7.2.2.2.3 **************/
	/*********** Ending of step Step 7.2.2.2 **************/

	UNION ALL

		 /********* Step 7.2.2.3 : Getting records when documentdetailid is 0  JD.DocType='Journal' AND JD.DocSubType<>'Opening Balance' *******************/
 
	 /*********** Step 7.2.2.3.3 : here we join MS1 (Step 7.2.2.3.1) and FCA (Step 7.2.2.3.2.a)  *****************/
	 /*********** Taking all columns from MS1 and corresponding Account column from FCA ****************/
	
	 select [COA Name],RecOrder,DocType,DocSubType,DocumentDescription,DocDate,DocNo,SystemRefNo,ServiceCompany,EntityName,BaseDebit,BaseCredit,BaseBalance,ExchangeRate,BaseCurrency,DocCurrency,DocDebit,DocCredit,DocBalance,/*IsMultiCurrency,*/SegmentCategory1,SegmentCategory2,MCS_Status,Status,  /*FCA.CorrAccount*/  CorrAccount,[Entity Type],[Vendor Type],PONo,Nature,[CreditTerms(Days)],DueDate,[NSD ISCHECKED],[NO SUPPORT DOC],ItemCode,ItemDescription,Qty,Unit,UnitPrice,DiscountType,Discount,[BRM ISCHECKED],[ALLOWABLE/DISALLOWABLE],[Bank Clearing],ModeOfReceipt,ReversalDate,[Bank Reconcile],[Reversal Doc Ref],ClearingStatus,[Created By],[Created On],[Modified By],[Modified On],COA_Parameter,classOrder

	 from
	 (
		 /********* Step 7.2.2.3.1 : Getting records except coresponding account column ************************************/
		 Select      COA.Code+'  '+ COA.Name as 'COA Name', JD.DocType,JD.DocSubType,
					 case when J.DocType<>'Journal' then J.DocumentDescription
					      when J.DocType='Journal'
						  then
						    Case when J.DocSubType='Opening Balance'
							     then 
								   case when Jd.AccountDescription is null then J.DocumentDescription else Jd.AccountDescription  end
								 when J.DocSubType<>'Opening Balance' then J.DocumentDescription
							end
					  end as DocumentDescription, 
					 J.DocDate,case when J.DocType='Journal' and J.DocSubType='Opening Balance' then JD.SystemRefNo else JD.DocNo end as DocNo,J.ActualSysRefNo SystemRefNo, SC.Name ServiceCompany,case when J.DocType<>'Journal' then E.Name when J.DocType='Journal' then EJ.Name end as EntityName,case when JD.BaseCurrency=JD.DocCurrency and JD.BaseDebit is null then JD.DocDebit else JD.BaseDebit end BaseDebit,case when JD.BaseCurrency=JD.DocCurrency and JD.BaseCredit is null then JD.DocCredit else JD.BaseCredit end BaseCredit,isnull((isnull(Case when JD.BaseCurrency=JD.DocCurrency and JD.BaseDebit is null then JD.DocDebit else  JD.BaseDebit end ,0)-isnull(Case when JD.DocCurrency=JD.BaseCurrency and JD.BaseCredit is null then JD.DocCredit else JD.BaseCredit end,0)),0) as BaseBalance ,jd.ExchangeRate,jd.BaseCurrency,isnull(JD.DocCurrency,'SGD') DocCurrency,JD.DocDebit,JD.DocCredit,isnull((isnull(JD.DocDebit,0)-isnull(JD.DocCredit,0)),0) as DocBalance,/*IsMultiCurrency,*/jd.SegmentCategory1,JD.SegmentCategory2,Case when MCS.Status=1 then 1 else 0 end MCS_Status, SM3.Status,/*COA.Name as [Corr Account],*/
					 JD.JournalId,
					 case when J.DocType<>'Journal'
					      then
				             Case when E.IsCustomer=1 then 'Customer' when E.IsVendor=1 then 'Vendor' end 
			              when J.DocType='Journal'
                          then
                             Case when EJ.IsCustomer=1 then 'Customer' when EJ.IsVendor=1 then 'Vendor' end 
			              end 
			          as [Entity Type],
                     case when J.DocType<>'Journal' then E.VendorType 
			              when J.DocType='Journal' then EJ.VendorType
			         end
			         as [Vendor Type],
					 J.PONo,JD.Nature,TP.TOPValue as [CreditTerms(Days)],J.DueDate,NSD.[NSD ISCHECKED],CASE WHEN J.IsNoSupportingDocs=0 THEN 'NO' WHEN J.IsNoSupportingDocs=1 THEN 'YES' END AS [NO SUPPORT DOC],JD.ItemCode,JD.ItemDescription,JD.Qty,JD.Unit,JD.UnitPrice,JD.DiscountType,JD.Discount,[BRM ISCHECKED],case when JD.AllowDisAllow=0 then 'NO' when JD.AllowDisAllow=1 then 'YES' END AS [ALLOWABLE/DISALLOWABLE],JD.ClearingDate AS [Bank Clearing],J.ModeOfReceipt,J.ReversalDate,
					 case when J.IsBankReconcile=0 then 'NO' when J.IsBankReconcile=1 then 'YES' end as [Bank Reconcile],case when J.IsAutoReversalJournal in (1) then J.SystemReferenceNo  end as [Reversal Doc Ref],JD.ClearingStatus,J.UserCreated as [Created By],J.CreatedDate as [Created On],J.ModifiedBy as [Modified By],J.ModifiedDate as [Modified On],@COA_BSheet as COA_Parameter,
					 Case when COA.Class in('Assets','Asset') then 1 
									when COA.Class='Liabilities' then 2
									when COA.Class='Equity' then 3
									when COA.Class='Income' then 4
									when COA.Class='Expenses' then 5 end as classOrder,AT.RecOrder,JD.COAId,CCOA.Name as CorrAccount
		 From        Bean.JournalDetail JD 
		 Inner Join  Bean.Journal J on J.Id=JD.JournalId
		 Inner Join  Bean.ChartOfAccount COA on COA.Id=JD.COAId
		 Left  Join  Bean.ChartOfAccount CCOA on CCOA.Id=JD.CorrAccountId
		 Left Join   Bean.AccountType AT ON AT.Id=COA.AccountTypeId AND AT.CompanyId=COA.CompanyId
		 Inner Join  Common.Company as SC on SC.Id=J.ServiceCompanyId
		 Left  join  Bean.Entity as E on E.Id=J.EntityId and J.DocType<>'Journal'
		 Left  Join  Bean.Entity as EJ on EJ.Id=JD.EntityId and J.DocType='Journal' 
		 Left join   Bean.SegmentMaster as SM1 on SM1.Id=JD.SegmentMasterid1 and J.CompanyId=SM1.CompanyId
		 Left join   Bean.SegmentMaster as SM2 on SM2.Id=JD.SegmentMasterid1 and J.CompanyId=SM2.CompanyId
		 Left join   Bean.MultiCurrencySetting MCS on MCS.companyId=J.CompanyId
		 Left Join 
		  (
			  select distinct CompanyId,status
			  from
			  (
				select CompanyId, Status from bean.SegmentMaster where CompanyId=@CompanyId
			  ) as st1
		  ) SM3 on SM3.companyid=J.CompanyId 
		 Left join   Common.TermsOfPayment as TP on TP.Id=JD.CreditTermsId
		 LEFT JOIN
		  (
			 select   CompanyId,ISNULL(IsChecked,0) AS [NSD ISCHECKED]  
			 From     Common.CompanyFeatures where CompanyId=@CompanyId and FeatureId=(select distinct id from Common.Feature where Name='No Supporting Documents') 
		  ) AS NSD ON NSD.CompanyId=J.CompanyId
		 LEFT JOIN
		  (
			 select  CompanyId,ISNULL(IsChecked,0) AS [BRM ISCHECKED] 
			 From    Common.CompanyFeatures where CompanyId=@CompanyId and FeatureId=(select distinct id from Common.Feature where Name='Bank Reconciliation') 
		   ) AS BRM ON BRM.CompanyId=J.CompanyId

		 where COA.CompanyId=@CompanyId 
		 and COA.ModuleType='Bean' 
		 AND  COA.Name in(select items from dbo.SplitToTable(CONVERT(nvarchar(max), (SELECT @COA_BSheet FOR XML PATH('')), 1),','))
		AND  SC.Name in(select items from dbo.SplitToTable(CONVERT(nvarchar(max), (SELECT @ServiceCompany FOR XML PATH('')), 1),','))
		 and CONVERT(DATE,J.DocDate) between @BSFromDate and @BSToDate AND J.DocumentState NOT IN ('Void','Cancelled','Parked','Reset') 
		 AND JD.DocType='Journal' AND JD.DocSubType<>'Opening Balance'
	 ) as MS1

	 /*********Ending of Step 7.2.2.3.1 *************************/
	
	/*********** Ending of step 7.2.2.3.3 **************/
	/*********** Ending of step 7.2.2.3 **************/
	--END OF STEP 7.2.2: GETTING RECORDS BETWEEN @BSFromDate AND @BSToDate
	END
	/*** End of Step 7.2: OTHER THAN Retained Earning COA information Getting ****/
	
  Fetch next from Balancesheet_cursor into @COA_BSheet,@COA_BSheet_CODE,@COA_BSheet_CORDER,@COA_BSheet_RECORDER
End
Close Balancesheet_cursor
Deallocate Balancesheet_cursor


                           /******  End of step 7: Data for Balance Sheet coa's **********/

						   /******* Step 8: Final result *******************/

                          /***Step 8.1 : Inserting into @GLReport data into @GLReport1 by adding rownumbering by using identity(1,1) ***/
    Insert Into @GLReport1
	SELECT    * 
	FROM      @GLReport 
	order by RecOrder,classOrder,COA_Parameter ,DocDate

	--Select * from @GLReport1

	                      /***End of Step 8.1 : Inserting into @GLReport data into @GLReport1 by adding rownumbering ***/
	
	                      /*** Step 8.2: Calculating running total for DocBalance and BaseBalance columns ineach line  by doc currency wise and insert all records into @GLReport_AfterAdding_SubTotal***/

	/** To do this we get running total of DocBalance and BaseBalance by using over clause with partition by and order by clause in each record of @GLReport1. ****/

	/** Here we took all columns except column named as 'number'.BCZ it mismatched no of columns to be inserted into  @GLReport_AfterAdding_SubTotal**/
	
	/*** Here we set IsSubTotal  to 1 ***/

	Insert Into @GLReport_AfterAdding_SubTotal ([COA Name],RecOrder,DocType ,DocSubType ,DocumentDescription,DocDate ,DocNo ,SystemRefNo ,ServiceCompany ,EntityName ,BaseDebit ,BaseCredit ,BaseBalance ,ExchangeRate ,BaseCurrency ,DocCurrency ,DocDebit ,DocCredit ,DocBalance ,SegmentCategory1 ,SegmentCategory2 ,MCS_Status ,SegmentStatus ,CorrAccount ,[Entity Type] ,[Vendor Type] ,PONo ,Nature ,[CreditTerms(Days)] ,DueDate ,[NSD ISCHECKED] ,[NO SUPPORT DOC] ,ItemCode ,ItemDescription ,Qty ,Unit ,UnitPrice ,[DiscountType] ,Discount ,[BRM ISCHECKED] ,[ALLOWABLE/DISALLOWABLE] ,[Bank Clearing] ,ModeOfReceipt ,ReversalDate ,[Bank Reconcile] ,[Reversal Doc Ref] ,ClearingStatus ,[Created By] ,[Created On] ,[Modified By] ,[Modified On] ,COA_Parameter ,classOrder,IsSubTotal,ISBF)
	Select [COA Name],RecOrder,DocType,DocSubType,DocumentDescription,DocDate,DocNo,SystemRefNo,ServiceCompany,EntityName,BaseDebit,BaseCredit, sum(BaseBalance) over ( partition by [COA Name],DocCurrency order by number) BaseBalance,ExchangeRate,BaseCurrency,DocCurrency,DocDebit,DocCredit, sum(DocBalance)  over ( partition by [COA Name],DocCurrency order by number) DocBalance,/*IsMultiCurrency,*/SegmentCategory1,SegmentCategory2,MCS_Status,SegmentStatus, CorrAccount,[Entity Type],[Vendor Type],PONo,Nature,[CreditTerms(Days)],DueDate,[NSD ISCHECKED],[NO SUPPORT DOC],ItemCode,ItemDescription,Qty,Unit,UnitPrice,DiscountType,Discount,[BRM ISCHECKED],[ALLOWABLE/DISALLOWABLE],[Bank Clearing],ModeOfReceipt,ReversalDate,[Bank Reconcile],[Reversal Doc Ref],ClearingStatus,[Created By],[Created On],[Modified By],[Modified On],COA_Parameter,
	       classOrder,0 as IsSubTotal,case when DocType='Balance B/F' then 1 else 2 end as ISBF
		   From  @GLReport1
	order by RecOrder,classOrder,COA_Parameter ,DocDate


		Select [COA Name],RecOrder,DocType,DocSubType,DocumentDescription,DocDate,DocNo,SystemRefNo,ServiceCompany,EntityName,BaseDebit,BaseCredit, sum(BaseBalance) over ( partition by [COA Name],DocCurrency order by number) BaseBalance,ExchangeRate,BaseCurrency,DocCurrency,DocDebit,DocCredit, sum(DocBalance)  over ( partition by [COA Name],DocCurrency order by number) DocBalance,/*IsMultiCurrency,*/SegmentCategory1,SegmentCategory2,MCS_Status,SegmentStatus, CorrAccount,[Entity Type],[Vendor Type],PONo,Nature,[CreditTerms(Days)],DueDate,[NSD ISCHECKED],[NO SUPPORT DOC],ItemCode,ItemDescription,Qty,Unit,UnitPrice,DiscountType,Discount,[BRM ISCHECKED],[ALLOWABLE/DISALLOWABLE],[Bank Clearing],ModeOfReceipt,ReversalDate,[Bank Reconcile],[Reversal Doc Ref],ClearingStatus,[Created By],[Created On],[Modified By],[Modified On],COA_Parameter,
	       classOrder,0 as IsSubTotal,case when DocType='Balance B/F' then 1 else 2 end as ISBF
		   From  @GLReport1
	order by RecOrder,classOrder,COA_Parameter ,DocDate
	                    /*** End of Step 8.2: Calculating running total for DocBalance and BaseBalance columns ineach line  by doc currency wise and insert all records into @GLReport_AfterAdding_SubTotal***/
	
	                    /*** Step 8.3: Getting SubTotal by docCurrency for all COA's ***/

    /** Here we calculate SubTotals of DocDebit,DocCredit,DocBalance,BaseDebit,BaseCredit and BaseBalance by DocCurrency wise of each coa. We set IsSubTotal  to 1 **/
	Insert Into @GLReport_AfterAdding_SubTotal ([COA Name],RecOrder,DocType ,DocSubType ,DocumentDescription,DocDate ,DocNo ,SystemRefNo ,ServiceCompany ,EntityName ,BaseDebit ,BaseCredit ,BaseBalance ,ExchangeRate ,BaseCurrency ,DocCurrency ,DocDebit ,DocCredit ,DocBalance ,SegmentCategory1 ,SegmentCategory2 ,MCS_Status ,SegmentStatus ,CorrAccount ,[Entity Type] ,[Vendor Type] ,PONo ,Nature ,[CreditTerms(Days)] ,DueDate ,[NSD ISCHECKED] ,[NO SUPPORT DOC] ,ItemCode ,ItemDescription ,Qty ,Unit ,UnitPrice ,[DiscountType] ,Discount ,[BRM ISCHECKED] ,[ALLOWABLE/DISALLOWABLE] ,[Bank Clearing] ,ModeOfReceipt ,ReversalDate ,[Bank Reconcile] ,[Reversal Doc Ref] ,ClearingStatus ,[Created By] ,[Created On] ,[Modified By] ,[Modified On] ,COA_Parameter ,classOrder,IsSubTotal,ISBF)
    select   [COA Name],RecOrder,'' as DocType,'' as DocSubType,'' as DocumentDescription,null as  DocDate,'' as DocNo,'' as SystemRefNo, ServiceCompany,''  as EntityName,sum(isnull(BaseDebit,0.00)) as BaseDebit,sum(isnull(BaseCredit,0.00)) as BaseCredit,sum(BaseBalance) as BaseBalance,null as ExchangeRate, BaseCurrency, DocCurrency, sum(isnull(DocDebit,0.00)) as DocDebit,sum(isnull(DocCredit,0.00)) as DocCredit,sum(DocBalance) as DocBalance/*IsMultiCurrency,*/,null as SegmentCategory1,null as SegmentCategory2,@MCS_Status,@SegmentStatus as SegmentStatus,null as CorrAccount,null as [Entity Type],null as [Vendor Type],null as PONo,null as Nature,null as [CreditTerms(Days)],null as DueDate,@NSdISChecked as [NSD ISCHECKED],null as [NO SUPPORT DOC],null as ItemCode,null as ItemDescription,null as Qty,null as Unit,null as UnitPrice,null as DiscountType,null as Discount,@BRMIsChecked as [BRM ISCHECKED],null as [ALLOWABLE/DISALLOWABLE],null as [Bank Clearing],null as ModeOfReceipt,null as ReversalDate,NULL as [Bank Reconcile],null as [Reversal Doc Ref],null as ClearingStatus,null as [Created By],null as [Created On],null as [Modified By],null as [Modified On], COA_Parameter, classOrder,1 as IsSubTotal,3 as ISBF       
	FROM      @GLReport 
	Group By  [COA Name],RecOrder,ServiceCompany,BaseCurrency, DocCurrency,COA_Parameter, classOrder     
	order by classOrder,COA_Parameter,DocDate

	                    /*** Step 8.3: Getting SubTotal by docCurrency for all COA's ***/

						/** Step 8.4: Finally Displaying Result **/

	Select [COA Name] ,RecOrder,case when ISBF=1 and convert(date,DocDate)<=@UserStartDate then 'Opening Balance' 
	                                 when ISBF=1 and convert(date,DocDate)>@UserStartDate then 'Balance B/F'
									 else DocType 
								 end  as  DocType ,DocSubType ,DocumentDescription,DocDate ,DocNo ,SystemRefNo ,ServiceCompany ,EntityName ,BaseDebit ,BaseCredit ,BaseBalance ,ExchangeRate ,BaseCurrency ,DocCurrency ,DocDebit ,DocCredit ,DocBalance ,SegmentCategory1 ,SegmentCategory2 ,MCS_Status ,SegmentStatus ,CorrAccount ,[Entity Type] ,[Vendor Type] ,PONo ,Nature ,[CreditTerms(Days)] ,DueDate ,[NSD ISCHECKED] ,[NO SUPPORT DOC] ,ItemCode ,ItemDescription ,Qty ,Unit ,UnitPrice ,[DiscountType] ,Discount ,[BRM ISCHECKED] ,[ALLOWABLE/DISALLOWABLE] ,[Bank Clearing] ,ModeOfReceipt ,ReversalDate ,[Bank Reconcile] ,[Reversal Doc Ref] ,ClearingStatus ,[Created By] ,[Created On] ,[Modified By] ,[Modified On] ,COA_Parameter ,classOrder,IsSubTotal,ISBF From @GLReport_AfterAdding_SubTotal
	order by RecOrder,classOrder,COA_Parameter,IsSubTotal,ISBF,DocDate
	                 
	                   /** End of Step 8.4: Finally Displaying Result **/                 

                      /******* End of Step 8: Final result *******************/

END
GO
