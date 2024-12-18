USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[Rpt_General_Ledger_with_FinancialYear_Updated_API]    Script Date: 16-12-2024 9.20.11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--exec [dbo].[Rpt_General_Ledger_with_FinancialYear_Updated_API] @CompanyValue='134',@FromDate='2018-01-01',@ToDate='2018-12-31',
--@COA ='Accounts payable revaluation,Accounts payables,Accounts Receivables,Accounts receivables revaluation,Accruals,Accruals revaluation,Advertising,Agency Fund,Amt due from/to director:Director 1,Amt due from/to director:Director 2,Bank Charges,Cash and bank balances revaluation,Clearing,Clearing-Receipt,Closing stock,Commission,Courier and postages,Course fees,Deferred taxation,Deposit 1,Deposits and prepayments revaluation,Depreciation,Directors CPF,Directors fees,Directors remuneration,Dividend Appropriation,Donation,Doubtful Debt expense,Doubtful Debt Provision(AR),Doubtful Debt Provision(OR),Employer CPF,Entertainment and gifts,Exchange Gain/Loss - Realised,Exchange Gain/Loss - Unrealised,Fixed assets revaluation,Fixed deposit,Foreign worker levy,Freight & Handling charges,Furniture and Fittings - Accum Depn,Furniture and Fittings - Cost,I/C,Inf - Clearing(USD),Inf - OCBC23456(SGD),Inf - OCBC87654(USD),Insurance,Interest exp on bank overdraft,Interest exp on finance lease,Interest expense,Interest income,Inventory,Medical fees,Membership and Licence fees,Miscellaneous expenses,Motor Vehicle - Accum Depn,Motor Vehicle - Cost,Office Equipment - Accum Depn,Office Equipment - Cost,Office expenses,Opening stock,Operating lease,Other current assets revaluation,Other current liabilities revaluation,Other expenses,Other income,Other non-current assets revaluation,Other non-current liabilities revaluation,Other payable revaluation,Other payables,Other receivables,Other receivables revaluation,Penalty and fines,Permit fees,Petty Cash,Printing and stationery,Private vehicle expenses,Professional fees,Provision for taxation,Purchases,Renovation - Accum Depn,Renovation - Cost,Repair and Maintenance,Retained earnings,Revenue,Rounding,Rounding Account,SDL,Share Capital,Skill Development Levy,Staff accomodation,Staff CPF,Staff salary,Staff welfare,Storage Rental,Subcontractors/Outsourcing,Tax payable (GST),Telecommunication,Transportation,Travelling,Upkeep of motor vehicles,Utilities,Webhosting',
--@ServiceCompany ='InfoWeb Solutions',
--@ExcludeClearedItems=0

--exec [dbo].[Rpt_General_Ledger_with_FinancialYear_Updated_API] @CompanyValue='98',@FromDate='2018-01-01',@ToDate='2018-12-31',
--@COA ='Accounts payable revaluation,Accounts payables,Accounts Receivables,Accounts receivables revaluation,Accruals,Accruals revaluation,Advertising,Agency Fund,Amt due from/to director:Director 1,Amt due from/to director:Director 2,Bank Charges,Cash and bank balances revaluation,Clearing,Clearing-Receipt,Closing stock,Commission,Courier and postages,Course fees,Deferred taxation,Deposit 1,Deposits and prepayments revaluation,Depreciation,Directors CPF,Directors fees,Directors remuneration,Dividend Appropriation,Donation,Doubtful Debt expense,Doubtful Debt Provision(AR),Doubtful Debt Provision(OR),Employer CPF,Entertainment and gifts,Exchange Gain/Loss - Realised,Exchange Gain/Loss - Unrealised,Fixed assets revaluation,Fixed deposit,Foreign worker levy,Freight & Handling charges,Furniture and Fittings - Accum Depn,Furniture and Fittings - Cost,I/C,Inf - Clearing(USD),Inf - OCBC23456(SGD),Inf - OCBC87654(USD),Insurance,Interest exp on bank overdraft,Interest exp on finance lease,Interest expense,Interest income,Inventory,Medical fees,Membership and Licence fees,Miscellaneous expenses,Motor Vehicle - Accum Depn,Motor Vehicle - Cost,Office Equipment - Accum Depn,Office Equipment - Cost,Office expenses,Opening stock,Operating lease,Other current assets revaluation,Other current liabilities revaluation,Other expenses,Other income,Other non-current assets revaluation,Other non-current liabilities revaluation,Other payable revaluation,Other payables,Other receivables,Other receivables revaluation,Penalty and fines,Permit fees,Petty Cash,Printing and stationery,Private vehicle expenses,Professional fees,Provision for taxation,Purchases,Renovation - Accum Depn,Renovation - Cost,Repair and Maintenance,Retained earnings,Revenue,Rounding,Rounding Account,SDL,Share Capital,Skill Development Levy,Staff accomodation,Staff CPF,Staff salary,Staff welfare,Storage Rental,Subcontractors/Outsourcing,Tax payable (GST),Telecommunication,Transportation,Travelling,Upkeep of motor vehicles,Utilities,Webhosting',
--@ServiceCompany ='Axis pvt ltd',
--@ExcludeClearedItems=0

--Declare @CompanyValue Varchar(100)=N'98',@FromDate DateTime='2016-01-01',@ToDate DateTime='2018-12-31'
--,@COA varchar(MAX)=N'Accounts payable revaluation, Accounts payables,Accounts Receivables
--,Accounts receivables revaluation,Accruals,Accruals revaluation,Advertising,Agency Fund,
--Bank Charges,bea - CVDCVD(SGD),bea - dvddvd(USD),Cash and bank balances revaluation,Clearing,
--Clearing-Receipt,Commission,Courier and postages,Course fees,Deferred taxation,Deposit 1,
--Deposits and prepayments revaluation,Depreciation,Directors CPF,Directors fees,Directors remuneration,
--Dividend Appropriation,Donation,Doubtful Debt expense,Doubtful Debt Provision(AR),Doubtful Debt Provision(OR),
--Employer CPF,Entertainment and gifts,Exchange Gain/Loss - Realised,Exchange Gain/Loss - Unrealised,
--Fixed assets revaluation,Fixed deposit,Foreign worker levy,Furniture and Fittings - Accum Depn,
--Furniture and Fittings - Cost,I/C,Insurance,Interest exp on bank overdraft,Interest exp on finance lease,
--Interest expense,Interest income,Inventory,Inventory revaluation,JVC - DDTDDT(SGD),JVC - OCBCOCBC(USD),
--Medical fees,Membership and Licence fees,Miscellaneous expenses,Motor Vehicle - Accum Depn,
--Motor Vehicle - Cost,Office Equipment - Accum Depn,Office Equipment - Cost,Office expenses,
--Operating lease,Other current assets revaluation,Other current liabilities revaluation,Other expenses,
--Other income,Other non-current assets revaluation,Other non-current liabilities revaluation,
--Other payable revaluation,Other payables,Other receivables,Other receivables revaluation,Penalty and fines,
--Permit fees,Petty Cash,Printing and stationery,Private vehicle expenses,Professional fees,
--Provision for taxation,Purchases,Renovation - Accum Depn,Renovation - Cost,Repair and Maintenance,
--Retained earnings,Revenue,Rounding,Rounding Account,SDL,Share Capital,Soft - DBCDBC(SGD),Soft - hnjhnj(USD),
--Soft - sobsob(USD),Staff accomodation,Staff CPF,Staff salary,Staff welfare,STN - SGGSGG(USD),STN - VVCVVC(SGD),
--Subcontractors/Outsourcing,Tax payable (GST),Telecommunication,Transportation,Travelling,
--Upkeep of motor vehicles,Utilities,Webhosting',@ServiceCompany Varchar(MAX)=N'Axis pvt ltd',@ExcludeClearedItems INT=0


CREATE Procedure [dbo].[Rpt_General_Ledger_with_FinancialYear_Updated_API]
@CompanyValue Varchar(100),
@FromDate Datetime,
@ToDate  Datetime,
@COA varchar(MAX),
@ServiceCompany Varchar(MAX),
@ExcludeClearedItems int
As
Begin

Declare @CompanyId int
select @CompanyId = dbo.DecryptCompanyValue(@CompanyValue)
                      /*******step1: moving coa name and category of selected coa's into @COA_Category table variable**********/
Declare  @COA_Category TABLE ([COA Name] NVARCHAR(MAX),Code Nvarchar(max),ClassOrder int,AccountNature NVARCHAR(MAX),Class NVARCHAR(MAX),Category NVARCHAR(MAX),SubCategory NVARCHAR(MAX),AccountType NVARCHAR(MAX)
                              )

Insert Into @COA_Category
Select Name,Code,classOrder,AccountNature,Class,Category,SubCategory,AccountType
From
(
	Select COA.Name,COA.Nature As AccountNature,COA.Class,COA.Category,COA.SubCategory,COA.Code,AT.Name As AccountType,
	       Case when COA.Class in('Assets','Asset') then 1 
				when COA.Class='Liabilities' then 2
				when COA.Class='Equity' then 3
				when COA.Class='Income' then 4
				when COA.Class='Expenses' then 5 end as classOrder
	From   Bean.ChartOfAccount As COA
	       Inner Join Bean.AccountType As AT on AT.Id=COA.AccountTypeId 
	where  COA.CompanyId=@CompanyId and COA.ModuleType='Bean'
) as DT1
/*where Name in (SELECT items FROM dbo.SplitToTable(@COA,','))*/
Where Name  in(select items from dbo.SplitToTable(CONVERT(nvarchar(max), (SELECT @COA FOR XML PATH('')), 1),','))

--Select * from @COA_Category
                     /*************end of step1*******************/

                     /********step2: moving coa names where category in balance sheet into @COA_BalanceSheet**********/

Declare @COA_BalanceSheet table ([COA Name] nvarchar(max),Code Nvarchar(max),ClassOrder int,Category NVARCHAR(MAX),SubCategory NVARCHAR(MAX),
                                 AccountType NVARCHAR(MAX),Class NVARCHAR(MAX),AccountNature NVARCHAR(MAX))

Insert Into @COA_BalanceSheet
Select [COA Name],Code,ClassOrder,AccountNature ,Class,Category,SubCategory,AccountType from @COA_Category where Category='Balance Sheet' order by [COA Name]

--Select * from @COA_BalanceSheet

                       /********End of Step2**********/

                       /********step3: moving coa names where category in Income Statement into @COA_IncomeStatement**********/

Declare @COA_IncomeStatement table ([COA Name] nvarchar(max),Code Nvarchar(max),ClassOrder int,AccountNature NVARCHAR(MAX),Class NVARCHAR(MAX),Category NVARCHAR(MAX),SubCategory NVARCHAR(MAX),
                                 AccountType NVARCHAR(MAX))

Insert Into @COA_IncomeStatement
Select [COA Name],Code,ClassOrder,AccountNature,Class,Category,SubCategory,AccountType  from @COA_Category where Category='Income Statement' order by [COA Name]

--Select * from @COA_IncomeStatement

                      /********End of Step3**********/

            /******* Step 4: Declaring variables for RE,IS,BS and assigning values into currosponding variables based on FromDate and ToDate *********/ 

Declare @SSD Date -- i.e to get system start date for that service company. It gives the first transaction recorded date of the selected service company.

Declare @YFD Bigint --i.e to get year  of FromDate
Declare @YTD Bigint --i.e to get year of ToDate

Declare @FDFY Date --i.e to get Financial year end date for year of FromDate
Declare @TDFY Date --i.e to get Financial year end date for year of ToDate

Declare @FDFY1 Date--i.e to get Financial year end date for (year-1) of FromDate
Declare @TDFY1 Date --i.e to get Financial year end date for (year-1) of ToDate

Declare @REFD Date --i.e. to get Retained Earnings FromDate
Declare @RETD Date -- i.e to get Retained Earnings ToDate

Declare @BSBFFD Date-- i.e to get Balance Sheet Brought Forwarded From Date
Declare @BSBFTD Date-- i.e to get Balance Sheet Brought Forwarded To Date
Declare @BSFD Date-- i.e to get Balance Sheet From Date
Declare @BSTD Date-- i.e to get Balance Sheet To Date

Declare @ISBFFD Date -- i.e to get Income Statement Brought Forwarded From Date
Declare @ISBFTD Date --i.e. to get Income Statement Brought Forwarded To Date
Declare @ISFD Date --i.e to get Income Statement From Date
Declare @ISTD Date -- i.e to get Income Statement To Date

Declare @DaysBetweenDates Bigint -- i.e to get days between FromDate and ToDate

Declare @Bus_Year_End NVarchar(200) -- i.e to get businee year end  of the company
Select @Bus_Year_End= BusinessYearEnd from Common.Localization where CompanyId=@CompanyId
--Print @Bus_Year_End

Select @YFD= YEAR(@FromDate) --assigning values to @YFD
--Print @YFD
Select @YTD=YEAR(@ToDate)  --Assigning values to @YTD
--Print @YTD

  --Assigning @FDFY
Select @FDFY=Cast(@Bus_Year_End+'-'+cast(@YFD as nvarchar) as date) --casting @YFD to nvarchar and resultant is concatinating to @Bus_Year_End.Then the resultant is cast to date
--Print @FDFY

  --Assigning @TDFY
Select @TDFY=Cast(@Bus_Year_End+'-'+cast(@YTD as nvarchar) as date) --casting @YTD to nvarchar and resultant is concatinating to @Bus_Year_End.Then the resultant is cast to date
--Print @TDFY

  --Assigning @FDFY1
Select @FDFY1=DATEADD(year,-1,@FDFY) --going 1 year back from @FDFY
--print @FDFY1

  --Assigning @TDFY1
Select @TDFY1=DATEADD(year,-1,@TDFY) --going 1 year back from @TDFY
--print @TDFY1

  --Assigning @SSD value
  Select @SSD='1900-01-01'
/*Select @SSD=DocDate
From
(
	Select   DocDate,RANK()over (order by docdate) Ranking
	From
	(
		select       distinct J.DocDate DocDate
		from         Bean.JournalDetail as JD
		inner join   Bean.Journal as J on J.Id=JD.JournalId
		Inner Join   Bean.ChartOfAccount COA on COA.Id=JD.COAId
		Inner Join   Common.Company as SC on SC.Id=J.ServiceCompanyId
		left join    Common.TermsOfPayment as TP on TP.Id=JD.CreditTermsId
		where        COA.CompanyId=@CompanyId --and SC.Name=@ServiceCompany
		             and J.DocumentState<>'Void'
	) dt1
)dt2
where Ranking=1*/
--Print @SSD

  --Assigning @DaysBetweenDates value
Select @DaysBetweenDates= DATEDIFF(DAY,@FromDate,@ToDate)
--Print @DaysBetweenDates

  --ASSIGNING BALANCE SHEET DATES VALUES
SELECT @BSBFFD=@SSD
SELECT @BSBFTD=DATEADD(DAY,-1,@FromDate) --@FROMDATE-1
SELECT @BSFD=@FromDate
SELECT @BSTD=@ToDate
 -- END OF ASSIGNING BALANCE SHEET DATES VALUES

/****** @Bus_Year_End='01-Jan' STARTING POINT *************/
IF @Bus_Year_End='01-Jan'
BEGIN
/**** START of @DaysBetweenDates>=366 Condition ***********/
	IF @DaysBetweenDates>=366 --1
	BEGIN
		IF (@FromDate=@FDFY AND @ToDate=@TDFY) --1.1
		BEGIN
			SELECT @REFD=@SSD
			SELECT @RETD=@TDFY1

			SELECT @ISBFFD='1900-01-01'
			SELECT @ISBFTD=@TDFY1
			SELECT @ISFD=DATEADD(DAY,1,@TDFY1) --i.e.@TDTY1+1
			SELECT @ISTD=@ToDate
		END -- END OF 1.1
		ELSE IF (@FromDate=@FDFY AND @ToDate>@TDFY) --1.2
		BEGIN
			SELECT @REFD=@SSD
			SELECT @RETD=@TDFY

			SELECT @ISBFFD='1900-01-01'
			SELECT @ISBFTD=@TDFY
			SELECT @ISFD=DATEADD(DAY,1,@TDFY) --i.e.@TDFY+1
			SELECT @ISTD=@ToDate
		END -- END OF 1.2
		ELSE IF (@FromDate > @FDFY AND @ToDate=@TDFY) --1.3
		BEGIN
			SELECT @REFD=@SSD
			SELECT @RETD=@TDFY1

			SELECT @ISBFFD='1900-01-01'
			SELECT @ISBFTD=@TDFY1
			SELECT @ISFD=DATEADD(DAY,1,@TDFY1) --i.e.@TDTY1+1
			SELECT @ISTD=@ToDate
		END -- END OF 1.3
		ELSE IF (@FromDate > @FDFY AND @ToDate > @TDFY) --1.4
		BEGIN
			SELECT @REFD=@SSD
			SELECT @RETD=@TDFY

			SELECT @ISBFFD='1900-01-01'
			SELECT @ISBFTD=@TDFY
			SELECT @ISFD=DATEADD(DAY,1,@TDFY) --i.e.@TDFY+1
			SELECT @ISTD=@ToDate
		END -- END OF 1.4
	END -- END OF 1
	/**** End of @DaysBetweenDates>=366 Condition ***********/

	/**** starting of @DaysBetweenDates<366 *******/
	ELSE
	BEGIN
	/****** STARTING OF @YFD<>@YTD IN @DaysBetweenDates<366 CONDITION ********/ 
		IF @YFD<>@YTD --2
		BEGIN
			IF (@FromDate > @FDFY AND @ToDate=@TDFY) --2.1
			BEGIN
				SELECT @REFD=@SSD
				SELECT @RETD=@FDFY

				SELECT @ISBFFD=DATEADD(DAY,1,@FDFY) --i.e. @FDFY+1
				SELECT @ISBFTD=DATEADD(DAY,-1,@FromDate) --i.e. @FD-1
				SELECT @ISFD=@FromDate
				SELECT @ISTD=@ToDate
			END -- END OF 2.1
			ELSE IF (@FromDate > @FDFY AND @ToDate > @TDFY) --2.2
			BEGIN
				SELECT @REFD=@SSD
				SELECT @RETD=@TDFY

				SELECT @ISBFFD='1900-01-01'
				SELECT @ISBFTD=@TDFY
				SELECT @ISFD=DATEADD(DAY,1,@TDFY) --i.e. @TDFY+1
				SELECT @ISTD=@ToDate
			END -- END OF 2.2
		END -- END OF 2
	/****** ENDING OF @YFD<>@YTD IN @DaysBetweenDates<366 CONDITION ********/

	/****** STARTING OF @YFD=@YTD IN @DaysBetweenDates<366 CONDITION ********/
		ELSE IF @YFD=@YTD --3
		BEGIN
			IF(@FromDate=@FDFY AND @ToDate=@FDFY AND @FromDate=@ToDate) --3.1
			BEGIN
				SELECT @REFD=@SSD
				SELECT @RETD=@FDFY1

				SELECT @ISBFFD=DATEADD(DAY,1,@FDFY1) --i.e. @FDFY1+1
				SELECT @ISBFTD=DATEADD(DAY,-1,@FromDate) -- i.e.@FROMDATE-1
				SELECT @ISFD=@FromDate
				SELECT @ISTD=@ToDate
			END --END OF 3.1
			ELSE IF(@FromDate > @FDFY AND @ToDate > @FDFY AND @FromDate=@ToDate) --3.2
			BEGIN
				SELECT @REFD=@SSD
				SELECT @RETD=@FDFY

				SELECT @ISBFFD=DATEADD(DAY,1,@FDFY) -- i.e. @FDFY+1
				SELECT @ISBFTD=DATEADD(DAY,-1,@FromDate) -- i.e.@FromDate-1
				SELECT @ISFD=@FromDate
				SELECT @ISTD=@ToDate
			END -- END OF 3.2
			ELSE IF(@FromDate=@FDFY AND @ToDate > @FDFY) --3.3
			BEGIN
				SELECT @REFD=@SSD
				SELECT @RETD=@FDFY

				SELECT @ISBFFD='1900-01-01'
				SELECT @ISBFTD=@FDFY
				SELECT @ISFD=DATEADD(DAY,1,@FDFY) --i.e. @FDFY+1
				SELECT @ISTD=@ToDate
			END -- END OF 3.3
			ELSE IF (@FromDate > @FDFY AND @ToDate > @FDFY) --3.4
			BEGIN
				SELECT @REFD=@SSD
				SELECT @RETD=@FDFY

				SELECT @ISBFFD=DATEADD(DAY,1,@FDFY) --i.e. @FDFY+1
				SELECT @ISBFTD=DATEADD(DAY,-1,@FromDate) --i.e. @FromDate-1
				SELECT @ISFD=@FromDate
				SELECT @ISTD=@ToDate
			END -- END OF 3.4
		END -- END OF 3
	/****** ENDING OF @YFD=@YTD IN @DaysBetweenDates<366 CONDITION ********/
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
		IF(@FromDate < @FDFY AND @ToDate < @TDFY) --1.1
		BEGIN
			SELECT @REFD=@SSD
			SELECT @RETD=@TDFY1

			SELECT @ISBFFD='1900-01-01'
			SELECT @ISBFTD=@TDFY1
			SELECT @ISFD=DATEADD(DAY,1,@TDFY1) --i.e. @TDFY1+1
			SELECT @ISTD=@ToDate
		END -- END OF 1.1
		ELSE IF(@FromDate < @FDFY AND @ToDate=@TDFY) --1.2
		BEGIN
			SELECT @REFD=@SSD
			SELECT @RETD=@TDFY1

			SELECT @ISBFFD='1900-01-01'
			SELECT @ISBFTD=@TDFY1
			SELECT @ISFD=DATEADD(DAY,1,@TDFY1) --i.e. @TDFY1+1
			SELECT @ISTD=@ToDate
		END -- END OF 1.2
		ELSE IF(@FromDate=@FDFY AND @ToDate < @TDFY) --1.3
		BEGIN
			SELECT @REFD=@SSD
			SELECT @RETD=@TDFY1

			SELECT @ISBFFD='1900-01-01'
			SELECT @ISBFTD=@TDFY1
			SELECT @ISFD=DATEADD(DAY,1,@TDFY1) --i.e. @TDFY1+1
			SELECT @ISTD=@ToDate
		END -- END OF 1.3
		ELSE IF(@FromDate=@FDFY AND @ToDate=@TDFY) --1.4
		BEGIN
			SELECT @REFD=@SSD
			SELECT @RETD=@TDFY1

			SELECT @ISBFFD='1900-01-01'
			SELECT @ISBFTD=@TDFY1
			SELECT @ISFD=DATEADD(DAY,1,@TDFY1) --i.e. @TDFY1+1
			SELECT @ISTD=@ToDate
		END -- END OF 1.4
	END -- END OF 1
	/**** End of @DaysBetweenDates>=366 Condition ***********/

	/**** STARTING of @DaysBetweenDates<366 *******/
	ELSE
	BEGIN
	/****** STARTING OF @YFD<>@YTD CONDITION IN @DaysBetweenDates<366 CONDITION ********/
		IF(@YFD<>@YTD) --START OF 2
		BEGIN
			IF(@FromDate < @FDFY AND @ToDate < @TDFY) --2.1
			BEGIN
				SELECT @REFD=@SSD
				SELECT @RETD=@TDFY1

				SELECT @ISBFFD='1900-01-01'
				SELECT @ISBFTD=@TDFY1
				SELECT @ISFD=DATEADD(DAY,1,@TDFY1) --i.e. @TDFY1+1
				SELECT @ISTD=@ToDate
			END  --END OF 2.1
			ELSE IF(@FromDate=@FDFY AND @ToDate < @TDFY) --2.2
			BEGIN
				SELECT @REFD=@SSD
				SELECT @RETD=@TDFY1

				SELECT @ISBFFD='1900-01-01'
				SELECT @ISBFTD=@TDFY1
				SELECT @ISFD=DATEADD(DAY,1,@TDFY1) --i.e.@TDFY1+1
				SELECT @ISTD=@ToDate
			END -- END OF 2.2
		END --END OF 2
	/****** ENDING OF @YFD<>@YTD CONDITION IN @DaysBetweenDates<366 CONDITION ********/

	/****** STARTING OF @YFD=@YTD CONDITION IN @DaysBetweenDates<366 CONDITION ********/
		ELSE IF(@YFD=@YTD)  -- START 3
		BEGIN
			IF(@FromDate = @FDFY AND @ToDate=@FDFY AND @FromDate=@ToDate) --3.1
			BEGIN
				SELECT @REFD=@SSD
				SELECT @RETD=@TDFY1

				SELECT @ISBFFD=DATEADD(DAY,1,@FDFY1) --i.e. @FDFY1+1
				SELECT @ISBFTD=DATEADD(DAY,-1,@FromDate) --i.e. @FD-1
				SELECT @ISFD=@FromDate
				SELECT @ISTD=@ToDate
			END  --END  OF 3.1
			ELSE IF(@FromDate < @FDFY AND @ToDate < @FDFY AND @FromDate=@ToDate) --3.2
			BEGIN
				SELECT @REFD=@SSD
				SELECT @RETD=@TDFY1

				SELECT @ISBFFD=DATEADD(DAY,1,@TDFY1) --i.e. @TDFY1+1
				SELECT @ISBFTD=DATEADD(DAY,-1,@FromDate) --i.e. @FromDate-1
				SELECT @ISFD=@FromDate
				SELECT @ISTD=@ToDate
			END -- END OF 3.2
			ELSE IF(@FromDate < @FDFY AND @ToDate < @FDFY AND @FromDate<>DATEADD(DAY,1,@FDFY1)) --3.3
			BEGIN
				SELECT @REFD=@SSD
				SELECT @RETD=@TDFY1

				SELECT @ISBFFD=DATEADD(DAY,1,@TDFY1) --i.e. @TDFY1+1
				SELECT @ISBFTD=DATEADD(DAY,-1,@FromDate) --i.e @FromDate-1
				SELECT @ISFD=@FromDate
				SELECT @ISTD=@ToDate
			END --END OF 3.3 
			ELSE IF(@FromDate < @FDFY AND @ToDate=@FDFY AND @FromDate<>DATEADD(DAY,1,@FDFY1)) --3.4
			BEGIN
				SELECT @REFD=@SSD
				SELECT @RETD=@TDFY1

				SELECT @ISBFFD=DATEADD(DAY,1,@TDFY1) --i.e. @TDFY1+1
				SELECT @ISBFTD=DATEADD(DAY,-1,@FromDate) --i.e. @FromDate-1
				SELECT @ISFD=@FromDate
				SELECT @ISTD=@ToDate
			END --END OF 3.4
			ELSE IF(@FromDate < @FDFY AND @ToDate < @FDFY AND @FromDate=DATEADD(DAY,1,@FDFY1)) --3.5
			BEGIN
				SELECT @REFD=@SSD
				SELECT @RETD=@FDFY1

				SELECT @ISBFFD='1900-01-01'
				SELECT @ISBFTD=@FDFY1
				SELECT @ISFD=@FromDate
				SELECT @ISTD=@ToDate
			END --END OF 3.5 
			ELSE IF(@FromDate < @FDFY AND @ToDate=@FDFY AND @FromDate=DATEADD(DAY,1,@FDFY1)) --3.6
			BEGIN
				SELECT @REFD=@SSD
				SELECT @RETD=@FDFY1

				SELECT @ISBFFD='1900-01-01'
				SELECT @ISBFTD=@FDFY1
				SELECT @ISFD=@FromDate
				SELECT @ISTD=@ToDate
			END --END OF 3.6
		END -- END OF 3
	/****** ENDING OF @YFD=@YTD CONDITION IN @DaysBetweenDates<366 CONDITION ********/
	END
	/**** Endifing of @DaysBetweenDates<366 *******/
END

/****** @Bus_Year_End='31-Dec' ENDING POINT *************/	

/****** @Bus_Year_End NOT IN ('31-Dec','01-Jan') STARTING POINT *************/	

ELSE IF @Bus_Year_End NOT IN('31-Dec','01-Jan')
BEGIN
     /**** START of @DaysBetweenDates>=365 Condition ***********/
	IF @DaysBetweenDates >=365  --1
	BEGIN
		IF(@FromDate < @FDFY AND @ToDate < @TDFY) --1.1
		BEGIN
			SELECT @REFD=@SSD
			SELECT @RETD=@TDFY1

			SELECT @ISBFFD='1900-01-01'
			SELECT @ISBFTD=@TDFY1
			SELECT @ISFD=DATEADD(DAY,1,@TDFY1) --i.e. @TDFY1+1
			SELECT @ISTD=@ToDate
		END --END OF 1.1
		ELSE IF(@FromDate > @FDFY AND @ToDate >@TDFY) --1.2
		BEGIN
			SELECT @REFD=@SSD
			SELECT @RETD=@TDFY

			SELECT @ISBFFD='1900-01-01'
			SELECT @ISBFTD=@TDFY
			SELECT @ISFD=DATEADD(DAY,1,@TDFY) --i.e. @TDFY+1
			SELECT @ISTD=@ToDate
		END -- END OF 1.2
		ELSE IF (@FromDate < @FDFY AND @ToDate > @TDFY) --1.3.1
		BEGIN
			SELECT @REFD=@SSD
			SELECT @RETD=@TDFY

			SELECT @ISBFFD='1900-01-01'
			SELECT @ISBFTD=@TDFY
			SELECT @ISFD=DATEADD(DAY,1,@TDFY) --i.e. @TDFY+1
			SELECT @ISTD=@ToDate
		END --1.3.1
		ELSE IF(@FromDate > @FDFY AND @ToDate < @TDFY) --1.3.2
		BEGIN
			SELECT @REFD=@SSD
			SELECT @RETD=@TDFY1

			SELECT @ISBFFD='1900-01-01'
			SELECT @ISBFTD=@TDFY1
			SELECT @ISFD=DATEADD(DAY,1,@TDFY1) --i.e. @TDFY1+1
			SELECT @ISTD=@ToDate
		END -- END OF 1.3.2
		ELSE IF(@FromDate < @FDFY AND @ToDate= @TDFY) --1.4
		BEGIN
			SELECT @REFD=@SSD
			SELECT @RETD=@TDFY1

			SELECT @ISBFFD='1900-01-01'
			SELECT @ISBFTD=@TDFY1
			SELECT @ISFD=DATEADD(DAY,1,@TDFY1) --i.e. @TDFY1+1
			SELECT @ISTD=@ToDate
		END --END OF 1.4
		ELSE IF(@FromDate > @FDFY AND @ToDate=@TDFY) --1.5
		BEGIN
			SELECT @REFD=@SSD
			SELECT @RETD=@TDFY1

			SELECT @ISBFFD='1900-01-01'
			SELECT @ISBFTD=@TDFY1
			SELECT @ISFD=DATEADD(DAY,1,@TDFY1) -- i.e. @TDFY1+1
			SELECT @ISTD=@ToDate
		END -- END OF 1.5
		ELSE IF(@FromDate = @FDFY AND @ToDate = @TDFY) --1.6
		BEGIN
			SELECT @REFD=@SSD
			SELECT @RETD=@TDFY1

			SELECT @ISBFFD='1900-01-01'
			SELECT @ISBFTD=@TDFY1
			SELECT @ISFD=DATEADD(DAY,1,@TDFY1) --i.e. @TDFY1+1
			SELECT @ISTD=@ToDate
		END --END OF 1.6
		ELSE IF(@FromDate = @FDFY AND @ToDate < @TDFY) --1.7
		BEGIN
			SELECT @REFD=@SSD
			SELECT @RETD=@TDFY1

			SELECT @ISBFFD='1900-01-01'
			SELECT @ISBFTD=@TDFY1
			SELECT @ISFD=DATEADD(DAY,1,@TDFY1) --i.e. @TDFY1+1
			SELECT @ISTD=@ToDate
		END -- END OF 1.7
		ELSE IF(@FromDate = @FDFY AND @ToDate > @TDFY) --1.8
		BEGIN
			SELECT @REFD=@SSD
			SELECT @RETD=@TDFY

			SELECT @ISBFFD='1900-01-01'
			SELECT @ISBFTD=@TDFY
			SELECT @ISFD=DATEADD(DAY,1,@TDFY) --i.e.@TDFY+1
			SELECT @ISTD=@ToDate
		END --END OF 1.8
	END -- END OF 1
	/**** END of @DaysBetweenDates>=365 Condition ***********/

	/**** STARTING of @DaysBetweenDates<365 *******/
	ELSE
	BEGIN
	   /****** STARTING OF @YFD<>@YTD CONDITION IN @DaysBetweenDates<365 CONDITION ********/
		IF (@YFD<>@YTD) --2
		BEGIN
			IF(@FromDate < @FDFY AND @ToDate < @TDFY) --2.1
			BEGIN
				SELECT @REFD=@SSD
				SELECT @RETD=@TDFY1

				SELECT @ISBFFD='1900-01-01'
				SELECT @ISBFTD=@FDFY
				SELECT @ISFD=DATEADD(DAY,1,@FDFY) --i.e.@FDFY+1
				SELECT @ISTD=@ToDate
			END --END OF 2.1
			ELSE IF(@FromDate = @FDFY AND @ToDate < @TDFY) --2.2
			BEGIN
				SELECT @REFD=@SSD
				SELECT @RETD=@FromDate

				SELECT @ISBFFD='1900-01-01'
				SELECT @ISBFTD=@FDFY
				SELECT @ISFD=DATEADD(DAY,1,@FDFY) --i.e.@FDFY+1
				SELECT @ISTD=@ToDate
			END --END OF 2.2
			ELSE IF(@FromDate > @FDFY AND @ToDate < @TDFY) --2.3
			BEGIN
				SELECT @REFD=@SSD
				SELECT @RETD=@FDFY

				SELECT @ISBFFD=DATEADD(DAY,1,@FDFY) --i.e. @FDFY+1
				SELECT @ISBFTD=DATEADD(DAY,-1,@FromDate) --i.e. @FromDate-1
				SELECT @ISFD=@FromDate
				SELECT @ISTD=@ToDate
			END --END OF 2.3
			ELSE IF(@FromDate >@FDFY AND @ToDate=@TDFY) --2.4
			BEGIN
				SELECT @REFD=@SSD
				SELECT @RETD=@FDFY

				SELECT @ISBFFD=DATEADD(DAY,1,@FDFY) --i.e. @FDFY+1
				SELECT @ISBFTD=DATEADD(DAY,-1,@FromDate) --i.e.@FromDate-1
				SELECT @ISFD=@FromDate
				SELECT @ISTD=@ToDate
			END --END OF 2.4
			ELSE IF(@FromDate > @FDFY AND @ToDate > @TDFY) --2.5
			BEGIN
				SELECT @REFD=@SSD
				SELECT @RETD=@TDFY

				SELECT @ISBFFD='1900-01-01'
				SELECT @ISBFTD=@TDFY
				SELECT @ISFD=DATEADD(DAY,1,@TDFY) --i.e. @TDFY+1
				SELECT @ISTD=@ToDate
			END --END OF 2.5

		END -- END OF 2
		/****** ENDING OF @YFD<>@YTD CONDITION IN @DaysBetweenDates<365 CONDITION ********/

		/****** STARTING OF @YFD=@YTD CONDITION IN @DaysBetweenDates<365 CONDITION ********/
		ELSE IF(@YFD=@YTD) --3
		BEGIN
			IF(@FromDate < @FDFY AND @ToDate < @FDFY AND @FromDate<>@ToDate) --3.1
			BEGIN
				SELECT @REFD=@SSD
				SELECT @RETD=@FDFY1
				
				SELECT @ISBFFD=DATEADD(DAY,1,@FDFY1) -- i.e. @FDFY1+1
				SELECT @ISBFTD=DATEADD(DAY,-1,@FromDate) --i.e @FromDate-1
				SELECT @ISFD=@FromDate
				SELECT @ISTD=@ToDate
			END -- END OF 3.1
			ELSE IF(@FromDate < @FDFY AND @ToDate = @FDFY) --3.2
			BEGIN
				SELECT @REFD=@SSD
				SELECT @RETD=@FDFY1

				SELECT @ISBFFD=DATEADD(DAY,1,@FDFY1) --i.e. @FDFY1+1
				SELECT @ISBFTD=DATEADD(DAY,-1,@FromDate) --i.e @FromDate-1
				SELECT @ISFD=@FromDate
				SELECT @ISTD=@ToDate
			END --END OF 3.2
			ELSE IF(@FromDate < @FDFY AND @ToDate > @FDFY) -- 3.3
			BEGIN
				SELECT @REFD=@SSD
				SELECT @RETD=@FDFY

				SELECT @ISBFFD='1900-01-01'
				SELECT @ISBFTD=@FDFY
				SELECT @ISFD=DATEADD(DAY,1,@FDFY) --i.e.@FDFY+1
				SELECT @ISTD=@ToDate
			END --END OF 3.3
			ELSE IF(@FromDate = @FDFY AND @ToDate > @FDFY) --3.4
			BEGIN
				SELECT @REFD=@SSD
				SELECT @RETD=@FDFY

				SELECT @ISBFFD='1900-01-01'
				SELECT @ISBFTD=@FDFY
				SELECT @ISFD=DATEADD(DAY,1,@FDFY) --i.e. @FDFY+1
				SELECT @ISTD=@ToDate
			END -- END OF 3.4
			ELSE IF(@FromDate = @FDFY AND @ToDate=@FDFY AND @FromDate=@ToDate) --3.5
			BEGIN
				SELECT @REFD=@SSD
				SELECT @RETD=@FDFY1

				SELECT @ISBFFD=DATEADD(DAY,1,@FDFY1) --i.e. @FDFY1+1
				SELECT @ISBFTD=DATEADD(DAY,-1,@FromDate) --i.e. @FromDate-1
				SELECT @ISFD=@FromDate
				SELECT @ISTD=@ToDate
			END --END OF 3.5
			ELSE IF(@FromDate > @FDFY AND @ToDate > @TDFY AND @FromDate<>@ToDate) --3.6
			BEGIN
				SELECT @REFD=@SSD
				SELECT @RETD=@FDFY

				SELECT @ISBFFD=DATEADD(DAY,1,@FDFY) --i.e. @FDFY+1
				SELECT @ISBFTD=DATEADD(DAY,-1,@FromDate) --i.e. @FromDate-1
				SELECT @ISFD=@FromDate
				SELECT @ISTD=@ToDate
			END --END OF 3.6
			ELSE IF(@FromDate < @FDFY AND @ToDate < @FDFY AND @FromDate=@ToDate) --3.7
			BEGIN
				SELECT @REFD=@SSD
				SELECT @RETD=@FDFY1

				SELECT @ISBFFD=DATEADD(DAY,1,@FDFY1) --i.e. @FDFY1+1
				SELECT @ISBFTD=DATEADD(DAY,-1,@FromDate) --i.e. @FromDate-1
				SELECT @ISFD=@FromDate
				SELECT @ISTD=@ToDate
			END -- END OF 3.7
			ELSE IF(@FromDate > @FDFY AND @ToDate > @FDFY AND @FromDate=@ToDate) --3.8
			BEGIN
				SELECT @REFD=@SSD
				SELECT @RETD=@FDFY

				SELECT @ISBFFD=DATEADD(DAY,1,@FDFY) --i.e. @FDFY+1
				SELECT @ISBFTD=DATEADD(DAY,-1,@FromDate) --i.e. @FromDate-1
				SELECT @ISFD=@FromDate
				SELECT @ISTD=@ToDate
			END -- END OF 3.8
		END --END OF 3
		/****** ENDING OF @YFD=@YTD CONDITION IN @DaysBetweenDates<365 CONDITION ********/
	END
	/**** Endifing of @DaysBetweenDates<365 *******/
END

/****** @Bus_Year_End NOT IN ('31-Dec','01-Jan') ENDING POINT *************/	

--PRINT @REFD
--PRINT @RETD
--PRINT @ISBFFD
--PRINT @ISBFTD
--PRINT @ISFD
--PRINT @ISTD
--PRINT @BSBFFD
--PRINT @BSBFTD
--PRINT @BSFD
--PRINT @BSTD

                                                  /******* End of Step4 ***************/

                                     /*******Step 5 : Getting SegmentStatus,No Supporting Documents, Bank Reconciliation and MultiCurrencySetting**********/

--Here we declare the table variables to store intermediate and final resultant data

-- @GLReport intermediate table variable is used to store data after getting each coa data by applying cursor code and other conditions
Declare @GLReport Table( [COA Code] NVARCHAR(MAX),[COA Name] NVARCHAR(MAX),[Account Nature] NVARCHAR(MAX),DocType NVARCHAR(MAX),DocSubType Nvarchar(max),Class Nvarchar(max),Category Nvarchar(max),SubCategory Nvarchar(max),AccountType Nvarchar(max),DocumentDescription Nvarchar(max),DocDate datetime2,DocNo Nvarchar(max),SystemRefNo NVarchar(max),ServiceCompany Nvarchar(max),EntityName NVarchar(max),BaseDebit money,BaseCredit money,BaseBalance money,ExchangeRate decimal(15,10),BaseCurrency Nvarchar(max),DocCurrency NVarchar(max),DocDebit money,DocCredit money,DocBalance money,SegmentCategory1 Nvarchar(max),SegmentCategory2 NVarchar(max),MCS_Status int,SegmentStatus int,CorrAccount NVarchar(max),[Entity Type] Nvarchar(max),[Vendor Type] Nvarchar(max),PONo NVarchar(max),Nature Nvarchar(max),[CreditTerms(Days)] float,DueDate datetime2,[NSD ISCHECKED] int,[NO SUPPORT DOC] NVarchar(20),ItemCode NVarchar(max),ItemDescription NVarchar(max),Qty float,Unit NVarchar(100),UnitPrice money,[DiscountType] NVarchar(10),Discount float,[BRM ISCHECKED] int,[ALLOWABLE/DISALLOWABLE] NVarchar(max),[Bank Clearing] datetime2,ModeOfReceipt NVarchar(200),ReversalDate datetime2,[Bank Reconcile] NVarchar(20),[Reversal Doc Ref] NVarchar(max),ClearingStatus Nvarchar(100),[Created By] NVarchar(600),[Created On] datetime2,[Modified By] NVarchar(600),[Modified On] datetime2,COA_Parameter NVarchar(max),classOrder BIGINT)

--@GLReport1 intermediate table variable is used to get data from @GLReport. It is having same columns from @GLReport with same data type.
--And at starting point we declare a column with name 'Number' with identity.
Declare @GLReport1 Table(Number Bigint identity(1,1),[COA Code] NVARCHAR(MAX), [COA Name] NVARCHAR(MAX),[Account Nature] NVARCHAR(MAX),DocType NVARCHAR(MAX),DocSubType Nvarchar(max),Class Nvarchar(max),Category Nvarchar(max),SubCategory Nvarchar(max),AccountType Nvarchar(max),DocumentDescription Nvarchar(max),DocDate datetime2,DocNo Nvarchar(max),SystemRefNo NVarchar(max),ServiceCompany Nvarchar(max),EntityName NVarchar(max),BaseDebit money,BaseCredit money,BaseBalance money,ExchangeRate decimal(15,10),BaseCurrency Nvarchar(max),DocCurrency NVarchar(max),DocDebit money,DocCredit money,DocBalance money,SegmentCategory1 Nvarchar(max),SegmentCategory2 NVarchar(max),MCS_Status int,SegmentStatus int,CorrAccount NVarchar(max),[Entity Type] Nvarchar(max),[Vendor Type] Nvarchar(max),PONo NVarchar(max),Nature Nvarchar(max),[CreditTerms(Days)] float,DueDate datetime2,[NSD ISCHECKED] int,[NO SUPPORT DOC] NVarchar(20),ItemCode NVarchar(max),ItemDescription NVarchar(max),Qty float,Unit NVarchar(100),UnitPrice money,[DiscountType] NVarchar(10),Discount float,[BRM ISCHECKED] int,[ALLOWABLE/DISALLOWABLE] NVarchar(max),[Bank Clearing] datetime2,ModeOfReceipt NVarchar(200),ReversalDate datetime2,[Bank Reconcile] NVarchar(20),[Reversal Doc Ref] NVarchar(max),ClearingStatus Nvarchar(100),[Created By] NVarchar(600),[Created On] datetime2,[Modified By] NVarchar(600),[Modified On] datetime2,COA_Parameter NVarchar(max),classOrder BIGINT)

--@GLReport_AfterAdding_SubTotal is store final result.It is having same columns from @GLReport with same data type.
--And finally it is having a column  named as IsSubTotal which is identify to whether the record is belongs to subtotal or not.
Declare @GLReport_AfterAdding_SubTotal Table([COA Code] NVARCHAR(MAX),[COA Name] NVARCHAR(MAX),[Account Nature] NVARCHAR(MAX),DocType NVARCHAR(MAX),DocSubType Nvarchar(max),Class Nvarchar(max),Category Nvarchar(max),SubCategory Nvarchar(max),AccountType Nvarchar(max),DocumentDescription Nvarchar(max),DocDate datetime2,DocNo Nvarchar(max),SystemRefNo NVarchar(max),ServiceCompany Nvarchar(max),EntityName NVarchar(max),BaseDebit money,BaseCredit money,BaseBalance money,ExchangeRate decimal(15,10),BaseCurrency Nvarchar(max),DocCurrency NVarchar(max),DocDebit money,DocCredit money,DocBalance money,SegmentCategory1 Nvarchar(max),SegmentCategory2 NVarchar(max),MCS_Status int,SegmentStatus int,CorrAccount NVarchar(max),[Entity Type] Nvarchar(max),[Vendor Type] Nvarchar(max),PONo NVarchar(max),Nature Nvarchar(max),[CreditTerms(Days)] float,DueDate datetime2,[NSD ISCHECKED] int,[NO SUPPORT DOC] NVarchar(20),ItemCode NVarchar(max),ItemDescription NVarchar(max),Qty float,Unit NVarchar(100),UnitPrice money,[DiscountType] NVarchar(10),Discount float,[BRM ISCHECKED] int,[ALLOWABLE/DISALLOWABLE] NVarchar(max),[Bank Clearing] datetime2,ModeOfReceipt NVarchar(200),ReversalDate datetime2,[Bank Reconcile] NVarchar(20),[Reversal Doc Ref] NVarchar(max),ClearingStatus Nvarchar(100),[Created By] NVarchar(600),[Created On] datetime2,[Modified By] NVarchar(600),[Modified On] datetime2,COA_Parameter NVarchar(max),classOrder BIGINT,IsSubTotal INt,ISBF int)


Declare @SegmentStatus int
Select @SegmentStatus=Status
From
(
	select distinct CompanyId,status
	from
	(
		select CompanyId, Status from bean.SegmentMaster where CompanyId=@CompanyId
	) as st1
)as st2
--Print @SegmentStatus

Declare @NSdISChecked int
Select @NSdISChecked=[NSD ISCHECKED] 
From
(
	Select  CompanyId,ISNULL(IsChecked,0) AS [NSD ISCHECKED]  
	From    Common.CompanyFeatures where CompanyId=@CompanyId and FeatureId=(select distinct id from Common.Feature where Name='No Supporting Documents') 

)dt1
--Print @NSdISChecked

Declare @BRMIsChecked int
Select @BRMIsChecked= [BRM ISCHECKED]
From
(
    Select  CompanyId,ISNULL(IsChecked,0) AS [BRM ISCHECKED] 
     From    Common.CompanyFeatures where CompanyId=@CompanyId and FeatureId=(select distinct id from Common.Feature where Name='Bank Reconciliation') 
)dt2
--Print @BRMIsChecked

Declare @MCS_Status int
Select @MCS_Status=Status from Bean.MultiCurrencySetting where CompanyId=@CompanyId
--Print @MCS_Status

                               /*******END of Step 5 : Getting SegmentStatus,No Supporting Documents, Bank Reconciliation and MultiCurrencySetting**********/

                                /****** step 6: Data for Income Statement coa's **********/

Declare @COA_IS nvarchar(max)-- Income statement coa
Declare @COA_IS_CODE nvarchar(max)--Income statement coa code
Declare @COA_IS_CORDER INT --Income Statement coa class order
Declare @COA_IS_AccNature nvarchar(max)
Declare @COA_IS_AccClass nvarchar(max)

Declare @COA_IS_Category nvarchar(max)
Declare @COA_IS_SubCategory nvarchar(max)
Declare @COA_IS_AccType nvarchar(max)
Declare @IS_BF_CNT Bigint --used to store no of distinct dates between @ISBFFD and @ISBFTD when @ISBFFD<>='1900-01-01' condition becomes true
Declare @IS_DC_FOR_ZERO table (DocCurrency NVarchar(10))-- used to store distinct Doc currencies when @ISBFFD='1900-01-01' condition satisfied
Declare @DocCur_Zero NVarchar(10) --used in IS_FOR_ZERO cursor 

--Declare @BSheet_BF_CNT Bigint --used to store no of distinct dates between @BSBFFD and @BSBFTD 
Declare @ISDoccurrency table (DocCurr nvarchar(10))--used to store distinct doc currencies between @FromDate and @ToDate and Between @BSBFFD and @BSBFTD
Declare @ISDoccurrency1 table (DocCurr nvarchar(10)) --used to get distinct doc currencies from @ISDoccurrency
Declare @ISCurrency_FOR_NOTZERO NVarchar(10)-- used to store Doc currency which is used in  IS_FOR_NOTZERO_currency cursor
Declare @IS_BFCurrencyCNT bigint --used to store count of no of days between @BFFD and @BFTD for corresponding @Dcocurrency of Selected INCOME STATEMENT COA

Declare IncomeSheet_cursor cursor for select * from @COA_IncomeStatement
Open IncomeSheet_cursor
Fetch next from IncomeSheet_cursor into @COA_IS,@COA_IS_CODE,@COA_IS_CORDER,@COA_IS_AccNature,@COA_IS_AccClass,@COA_IS_Category,@COA_IS_SubCategory,@COA_IS_AccType
                                        
while @@FETCH_STATUS=0
Begin
   --STEP 6.1: GETTING BROUGHT FORWARDED BALANCE FOR INCOME STATEMENT COA TYPE
   --STARTING POINT OF STEP 6.1

   /*** STEP 6.1.1: @ISBFFD='1900-01-01' means the Brought forwarded balance should be zero ************/
   /*** IN THIS SCENARIO WE DONT CONSIDER DOC CURRENCIES BETWEEN @ISBFFD AND @ISBFTD.***/
   /*** START OF 6.1.1: @ISBFFD='1900-01-01' ***/
	IF @ISBFFD='1900-01-01'
	BEGIN

	     /**** STEP 6.1.1.A : GETTING DISTINCT DOC CURRENCIES FOR SELECTED IC_COA BETWEEN @ISFD AND @ISTD.AND RESULT IS INSERTED INTO @IS_DC_FOR_ZERO TABLE VARIABLE *******/
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
						AND CONVERT(DATE,J.DocDate) BETWEEN @ISFD AND @ISTD
						AND COA.ModuleType='Bean'
						AND J.DocumentState<>'Void'

	     /**** ENDING OF STEP 6.1.1.A : GETTING DISTINCT DOC CURRENCIES FOR SELECTED IC_COA BETWEEN @ISFD AND @ISTD.AND RESULT IS INSERTED INTO @IS_DC_FOR_ZERO TABLE VARIABLE *******/

			Declare IS_FOR_ZERO cursor for select * from @IS_DC_FOR_ZERO
			Open IS_FOR_ZERO
			Fetch Next From IS_FOR_ZERO Into @DocCur_Zero
			while @@FETCH_STATUS=0
			BEGIN
			/* STEP 6.1.1.B: SET TO TO DOCBALANCE,BASEBALANCE TO 0.00 AND ASSIGNED SOME OTHER FIELDS BASED ON REQUIREMENT */
				Insert Into @GLReport
		        select  @COA_IS_CODE [COA Code],@COA_IS as [COA Name],@COA_IS_AccNature AS [Account Nature], 'Balance B/F' as DocType,'' as DocSubType,
				                     @COA_IS_AccClass AS Class,@COA_IS_Category AS Category,@COA_IS_SubCategory AS SubCategory,@COA_IS_AccType AS AccountType,'' as DocumentDescription,@ISFD as DocDate,'' as DocNo,'' as SystemRefNo,@ServiceCompany as  ServiceCompany,''  as EntityName,null as BaseDebit,null as BaseCredit,0.00 as BaseBalance,null as ExchangeRate,'SGD' as BaseCurrency, @DocCur_Zero as DocCurrency, null as DocDebit,null as DocCredit,0.00 as DocBalance/*IsMultiCurrency,*/,null as SegmentCategory1,null as SegmentCategory2, @MCS_Status,@SegmentStatus as SegmentStatus,null as CorrAccount,null as [Entity Type],null as [Vendor Type],null as PONo,null as Nature,null as [CreditTerms(Days)],null as DueDate,@NSdISChecked as [NSD ISCHECKED],null as [NO SUPPORT DOC],null as ItemCode,null as ItemDescription,null as Qty,null as Unit,null as UnitPrice,null as DiscountType,null as Discount,@BRMIsChecked as [BRM ISCHECKED],null as [ALLOWABLE/DISALLOWABLE],null as [Bank Clearing],null as ModeOfReceipt,null as ReversalDate,NULL as [Bank Reconcile],null as [Reversal Doc Ref],null as ClearingStatus,null as [Created By],null as [Created On],null as [Modified By],null as [Modified On],@COA_IS COA_Parameter,@COA_IS_CORDER as classOrder
		   
		   /* END OF STEP 6.1.1.B: SET TO TO DOCBALANCE,BASEBALANCE TO 0.00 AND ASSIGNED SOME OTHER FIELDS BASED ON REQUIREMENT */	
			    
				Fetch Next From IS_FOR_ZERO Into @DocCur_Zero
			END
			CLOSE IS_FOR_ZERO
			DEALLOCATE IS_FOR_ZERO
			
			/* OLD CODE
		--Insert Into @GLReport
		--select  @COA_IS_CODE+'  '+@COA_IS as [COA Name], 'Balance B/F' as DocType,'' as DocSubType,'' as DocumentDescription,@ISFD as DocDate,'' as DocNo,'' as SystemRefNo,'' as  ServiceCompany,''  as EntityName,null as BaseDebit,null as BaseCredit,0.00 as BaseBalance,null as ExchangeRate,null as BaseCurrency, null as DocCurrency, null as DocDebit,null as DocCredit,0.00 as DocBalance/*IsMultiCurrency,*/,null as SegmentCategory1,null as SegmentCategory2, @MCS_Status,@SegmentStatus as SegmentStatus,null as CorrAccount,null as [Entity Type],null as [Vendor Type],null as PONo,null as Nature,null as [CreditTerms(Days)],null as DueDate,@NSdISChecked as [NSD ISCHECKED],null as [NO SUPPORT DOC],null as ItemCode,null as ItemDescription,null as Qty,null as Unit,null as UnitPrice,null as DiscountType,null as Discount,@BRMIsChecked as [BRM ISCHECKED],null as [ALLOWABLE/DISALLOWABLE],null as [Bank Clearing],null as ModeOfReceipt,null as ReversalDate,NULL as [Bank Reconcile],null as [Reversal Doc Ref],null as ClearingStatus,null as [Created By],null as [Created On],null as [Modified By],null as [Modified On],@COA_IS COA_Parameter,@COA_IS_CORDER as classOrder
            *** END OF OLD CODE **/
	END
				/*** END OF STEP 6.1.1: @ISBFFD='1900-01-01' means the Brought forwarded balance should be zero ************/

	           /** STEP 6.1.2: @ISBFFD<>'1900-01-01' i.e. THERE MIGHT BE SOME VALUE FOR BALANCE BROUGHT FORWARD ***/
	ELSE
	BEGIN
	/*** Step 6.1.2.a : getting Distinct Doc currencies between @BSFD and @BSTD for corresponding @COA_IS ****/
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
						AND CONVERT(DATE,J.DocDate) BETWEEN @ISFD AND @ISTD
						AND COA.ModuleType='Bean'
						AND J.DocumentState<>'Void'
	/*** End of Step 6.1.2.a : getting Distinct Doc currencies between @BSFD and @BSTD for corresponding @COA_IS ****/

	/*** Step 6.1.2.b : getting Distinct Doc currencies between @ISBFFD and @ISBFTD for corresponding @COA_IS ****/
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
						AND CONVERT(DATE,J.DocDate) BETWEEN @ISBFFD AND @ISBFTD
						AND COA.ModuleType='Bean'
						AND J.DocumentState<>'Void'
	/*** End of Step 6.1.2.b : getting Distinct Doc currencies between @ISBFFD and @ISBFTD for corresponding @COA_IS ****/

	/***Step 6.1.2.c: Getting distinct doccurrencies from @ISDoccurrency TABLE VARIABLE into @ISDoccurrency1 ***/

	        Insert Into @ISDoccurrency1
		    Select Distinct DocCurr From @ISDoccurrency
			

			Declare IS_FOR_NOTZERO_currency cursor for select * from @ISDoccurrency1
			Open IS_FOR_NOTZERO_currency
			Fetch Next From IS_FOR_NOTZERO_currency Into @ISCurrency_FOR_NOTZERO
			while @@FETCH_STATUS=0
			Begin
			/***Step 6.1.2.d: Getting count of distinct docdates for currosponding DocCurrency of selected INCONME STATEMENT COA between @ISBFFD and @IDBFTD ***/
				
				SELECT		@IS_BFCurrencyCNT=COUNT(DISTINCT CONVERT(DATE,J.DocDate))		
			    From        Bean.JournalDetail JD 
				Inner Join  Bean.Journal J on J.Id=JD.JournalId
				Inner Join  Bean.ChartOfAccount COA on COA.Id=JD.COAId
				Inner Join  Common.Company as SC on SC.Id=J.ServiceCompanyId
				WHERE       COA.CompanyId=@CompanyId
							AND  COA.Name in(select items from dbo.SplitToTable(CONVERT(nvarchar(max), (SELECT @COA_IS FOR XML PATH('')), 1),','))
							AND  SC.Name in(select items from dbo.SplitToTable(CONVERT(nvarchar(max), (SELECT @ServiceCompany FOR XML PATH('')), 1),','))
							AND CONVERT(DATE,J.DocDate) BETWEEN @ISBFFD AND @ISBFTD
							AND ISNULL(JD.DocCurrency,'SGD') = @ISCurrency_FOR_NOTZERO
							AND COA.ModuleType='Bean'
							AND J.DocumentState<>'Void'
				--print @IS_BFCurrencyCNT

            /***End of Step 6.1.2.d: Getting count of distinct docdates for currosponding DocCurrency of selected INCOME STATEMENT COA between @ISBFFD and @ISBFTD ***/

			/**** Step 6.1.2.e:@IS_BFCurrencyCNT=0 (i.e. there are no transactions in choosen doc currency for getting Brought forwarded balance. ***/
			--In this case We replace docbalance and basebalance as0.00 
				IF @IS_BFCurrencyCNT=0
				Begin
					Insert Into @GLReport
					select  @COA_IS_CODE [COA Code],@COA_IS as [COA Name],@COA_IS_AccNature AS [Account Nature], 'Balance B/F' as DocType,
					'' as DocSubType,@COA_IS_AccClass AS Class,@COA_IS_Category AS Category,@COA_IS_SubCategory AS SubCategory,@COA_IS_AccType AS AccountType,'' as DocumentDescription,
					@ISFD as DocDate,'' as DocNo,'' as SystemRefNo,@ServiceCompany as  ServiceCompany,''  as EntityName,null as BaseDebit,null as BaseCredit,0.00 as BaseBalance,null as ExchangeRate,'SGD' as BaseCurrency, @ISCurrency_FOR_NOTZERO as DocCurrency, null as DocDebit,null as DocCredit,0.00 as DocBalance/*IsMultiCurrency,*/,null as SegmentCategory1,null as SegmentCategory2, @MCS_Status,@SegmentStatus as SegmentStatus,null as CorrAccount,null as [Entity Type],null as [Vendor Type],null as PONo,null as Nature,null as [CreditTerms(Days)],null as DueDate,@NSdISChecked as [NSD ISCHECKED],null as [NO SUPPORT DOC],null as ItemCode,null as ItemDescription,null as Qty,null as Unit,null as UnitPrice,null as DiscountType,null as Discount,@BRMIsChecked as [BRM ISCHECKED],null as [ALLOWABLE/DISALLOWABLE],null as [Bank Clearing],null as ModeOfReceipt,null as ReversalDate,NULL as [Bank Reconcile],null as [Reversal Doc Ref],null as ClearingStatus,null as [Created By],null as [Created On],null as [Modified By],null as [Modified On],@COA_IS COA_Parameter,@COA_IS_CORDER as classOrder      
				End
			/**** Step End of 6.1.2.e: @IS_BFCurrencyCNT=0 (i.e. there are no transactions in choosen doc currency for getting Brought forwarded balance. ***/
			
			/**** Step 6.1.2.f:  @IS_BFCurrencyCNT<>0 (i.e. there are few transactions in choosen doc currency for getting Brought forwarded balance. ***/
				ELSE IF @IS_BFCurrencyCNT<>0 
				BEGIN
			      
					  INSERT INTO @GLReport
					  SELECT  @COA_IS_CODE [COA Code],@COA_IS as [COA Name],@COA_IS_AccNature AS [Account Nature], 'Balance B/F' as DocType,'' as DocSubType,
					          @COA_IS_AccClass AS Class,@COA_IS_Category AS Category,@COA_IS_SubCategory AS SubCategory,@COA_IS_AccType AS AccountType,
							  '' as DocumentDescription,@ISFD as DocDate,'' as DocNo,'' as SystemRefNo,@ServiceCompany as  ServiceCompany,''  as EntityName,
							  null as BaseDebit,null as BaseCredit,SUM(BaseBalance) as BaseBalance,null as ExchangeRate, BaseCurrency/*null as BaseCurrency*/, DocCurrency/*null as DocCurrency*/, null as DocDebit,null as DocCredit,SUM(DocBalance) as DocBalance/*IsMultiCurrency,*/,null as SegmentCategory1,null as SegmentCategory2, @MCS_Status,@SegmentStatus as SegmentStatus,null as CorrAccount,null as [Entity Type],null as [Vendor Type],null as PONo,null as Nature,null as [CreditTerms(Days)],null as DueDate,@NSdISChecked as [NSD ISCHECKED],null as [NO SUPPORT DOC],null as ItemCode,null as ItemDescription,null as Qty,null as Unit,null as UnitPrice,null as DiscountType,null as Discount,@BRMIsChecked as [BRM ISCHECKED],null as [ALLOWABLE/DISALLOWABLE],null as [Bank Clearing],null as ModeOfReceipt,null as ReversalDate,NULL as [Bank Reconcile],null as [Reversal Doc Ref],null as ClearingStatus,null as [Created By],null as [Created On],null as [Modified By],null as [Modified On],@COA_IS COA_Parameter,@COA_IS_CORDER as classOrder
					  --SELECT SUM(BaseBalance) as BaseBalance,SUM(DocBalance) as DocBalance,DocCurrency,BaseCurrency
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
										AND CONVERT(DATE,J.DocDate) BETWEEN @ISBFFD AND @ISBFTD
										AND ISNULL(JD.DocCurrency,'SGD') = @ISCurrency_FOR_NOTZERO
										AND COA.ModuleType='Bean'
										AND J.DocumentState<>'Void'
					  )DT1
					  Group By DocCurrency,BaseCurrency
				END

			/**** End of Step 6.1.2.f:  @IS_BFCurrencyCNT<>0 (i.e. there are few transactions in choosen doc currency for getting Brought forwarded balance. ***/
			
				Fetch Next From IS_FOR_NOTZERO_currency Into @ISCurrency_FOR_NOTZERO
			End
			Close IS_FOR_NOTZERO_currency
			Deallocate IS_FOR_NOTZERO_currency
	END
	 /** END OF STEP 6.1.2: @ISBFFD<>'1900-01-01' i.e. THERE MIGHT BE SOME VALUE FOR BALANCE BROUGHT FORWARD ***/

	--END OF STEP 6.1: GETTING BROUGHT FORWARDED BALANCE FOR INCOME STATEMENT COA TYPE

	/*---PREVIOUS CODE
	/*** STEP 6.1.2: START OF @ISBFFD<>'1900-01-01' i.e ELSE CONDITION ***/
	ELSE
	BEGIN
	  /** Step 6.1.2.A: Counting no of distinct dates between @ISBFFD and @ISBFTD ******/
		SELECT		@IS_BF_CNT=COUNT(DISTINCT CONVERT(DATE,J.DocDate))		
		From        Bean.JournalDetail JD 
		Inner Join  Bean.Journal J on J.Id=JD.JournalId
		Inner Join  Bean.ChartOfAccount COA on COA.Id=JD.COAId
		Inner Join  Common.Company as SC on SC.Id=J.ServiceCompanyId
		WHERE       COA.CompanyId=@CompanyId
			        AND  COA.Name in(select items from dbo.SplitToTable(CONVERT(nvarchar(max), (SELECT @COA_IS FOR XML PATH('')), 1),','))
				    AND  SC.Name in(select items from dbo.SplitToTable(CONVERT(nvarchar(max), (SELECT @ServiceCompany FOR XML PATH('')), 1),','))
					AND CONVERT(DATE,J.DocDate) BETWEEN @ISBFFD AND @ISBFTD
					AND COA.ModuleType='Bean'
					AND J.DocumentState<>'Void'

     /** END of Step 6.1.2.A: Counting no of distinct dates between @ISBFFD and @ISBFTD ******/
	   --STEP 6.1.2.B: @IS_BF_CNT=0
	   --STARTING POINT OF @IS_BF_CNT=0
	   IF @IS_BF_CNT=0 
	   BEGIN
		  Insert Into @GLReport
		  select  @COA_IS_CODE+'  '+@COA_IS as [COA Name], 'Balance B/F' as DocType,'' as DocSubType,'' as DocumentDescription,@ISFD as DocDate,'' as DocNo,'' as SystemRefNo,'' as  ServiceCompany,''  as EntityName,null as BaseDebit,null as BaseCredit,0.00 as BaseBalance,null as ExchangeRate,null as BaseCurrency, null as DocCurrency, null as DocDebit,null as DocCredit,0.00 as DocBalance/*IsMultiCurrency,*/,null as SegmentCategory1,null as SegmentCategory2, @MCS_Status,@SegmentStatus as SegmentStatus,null as CorrAccount,null as [Entity Type],null as [Vendor Type],null as PONo,null as Nature,null as [CreditTerms(Days)],null as DueDate,@NSdISChecked as [NSD ISCHECKED],null as [NO SUPPORT DOC],null as ItemCode,null as ItemDescription,null as Qty,null as Unit,null as UnitPrice,null as DiscountType,null as Discount,@BRMIsChecked as [BRM ISCHECKED],null as [ALLOWABLE/DISALLOWABLE],null as [Bank Clearing],null as ModeOfReceipt,null as ReversalDate,NULL as [Bank Reconcile],null as [Reversal Doc Ref],null as ClearingStatus,null as [Created By],null as [Created On],null as [Modified By],null as [Modified On],@COA_IS COA_Parameter,@COA_IS_CORDER as classOrder
       END
	   --END OF STEP 6.1.2.B.  i.e ENDING POINT OF @IS_BF_CNT=0

	   --STEP 6.1.2.C: @IS_BF_CNT<>0
	   --STARTING POINT OF @IS_BF_CNT<>0
	   ELSE IF @IS_BF_CNT<>0
	   BEGIN
	      Insert Into @GLReport 
	      SELECT  @COA_IS_CODE+'  '+@COA_IS as [COA Name], 'Balance B/F' as DocType,'' as DocSubType,'' as DocumentDescription,@ISFD as DocDate,'' as DocNo,'' as SystemRefNo,'' as  ServiceCompany,''  as EntityName,null as BaseDebit,null as BaseCredit,SUM(BaseBalance) as BaseBalance,null as ExchangeRate,null as BaseCurrency, null as DocCurrency, null as DocDebit,null as DocCredit,SUM(DocBalance) as DocBalance/*IsMultiCurrency,*/,null as SegmentCategory1,null as SegmentCategory2, @MCS_Status,@SegmentStatus as SegmentStatus,null as CorrAccount,null as [Entity Type],null as [Vendor Type],null as PONo,null as Nature,null as [CreditTerms(Days)],null as DueDate,@NSdISChecked as [NSD ISCHECKED],null as [NO SUPPORT DOC],null as ItemCode,null as ItemDescription,null as Qty,null as Unit,null as UnitPrice,null as DiscountType,null as Discount,@BRMIsChecked as [BRM ISCHECKED],null as [ALLOWABLE/DISALLOWABLE],null as [Bank Clearing],null as ModeOfReceipt,null as ReversalDate,NULL as [Bank Reconcile],null as [Reversal Doc Ref],null as ClearingStatus,null as [Created By],null as [Created On],null as [Modified By],null as [Modified On],@COA_IS COA_Parameter,@COA_IS_CORDER as classOrder
          FROM
		  (	
				SELECT		isnull((isnull(Case when JD.BaseCurrency=JD.DocCurrency and JD.BaseDebit is null then JD.DocDebit else  JD.BaseDebit end ,0)-isnull(Case when JD.DocCurrency=JD.BaseCurrency and JD.BaseCredit is null then JD.DocCredit else JD.BaseCredit end,0)),0) as BaseBalance,			
							isnull((isnull(JD.DocDebit,0)-isnull(JD.DocCredit,0)),0) as DocBalance			
				From        Bean.JournalDetail JD 
				Inner Join  Bean.Journal J on J.Id=JD.JournalId
				Inner Join  Bean.ChartOfAccount COA on COA.Id=JD.COAId
				Inner Join  Common.Company as SC on SC.Id=J.ServiceCompanyId
				WHERE       COA.CompanyId=@CompanyId
							AND  COA.Name in(select items from dbo.SplitToTable(CONVERT(nvarchar(max), (SELECT @COA_IS FOR XML PATH('')), 1),','))
							AND  SC.Name in(select items from dbo.SplitToTable(CONVERT(nvarchar(max), (SELECT @ServiceCompany FOR XML PATH('')), 1),','))
							AND CONVERT(DATE,J.DocDate) BETWEEN @ISBFFD AND @ISBFTD
							AND COA.ModuleType='Bean'
							AND J.DocumentState<>'Void'
		  )DT1
	   END
	   --ENDING POINT OF 6.1.2.C.  i.e.@IS_BF_CNT<>0
	END
	/*** END OF STEP 6.1.2: @ISBFFD<>'1900-01-01' i.e ELSE CONDITION ***/

	--END OF PREVIOUS CODE********/

	--ENDING OF STEP 6.1: GETTING BROUGHT FORWARDED BALANCE FOR INCOME STATEMENT COA TYPE
	
	--STEP 6.2: GETTING RECORDS BETWEEN @ISFD AND @ISTD
	 /********* Step 6.2.1 : Getting records when documentdetailid is 0 AND JD.DocType<>'Journal' *******************/
 
	 /*********** Step 6.2.1.3 : here we join MS1 (Step 6.2.1.1) and FCA (Step 6.2.1.2.a) *****************/
	 /*********** Taking all columns from MS1 and corresponding Account column from FCA ****************/
	 Insert Into @GLReport
	 select  [COA Code],[COA Name],[Account Nature],DocType,DocSubType,Class,Category,SubCategory,AccountType,DocumentDescription,DocDate,DocNo,SystemRefNo,ServiceCompany,EntityName,BaseDebit,BaseCredit,BaseBalance,ExchangeRate,BaseCurrency,DocCurrency,DocDebit,DocCredit,DocBalance,/*IsMultiCurrency,*/SegmentCategory1,SegmentCategory2,MCS_Status,Status,  /*FCA.CorrAccount*/  CorrAccount,[Entity Type],[Vendor Type],PONo,Nature,[CreditTerms(Days)],DueDate,[NSD ISCHECKED],[NO SUPPORT DOC],ItemCode,ItemDescription,Qty,Unit,UnitPrice,DiscountType,Discount,[BRM ISCHECKED],[ALLOWABLE/DISALLOWABLE],[Bank Clearing],ModeOfReceipt,ReversalDate,[Bank Reconcile],[Reversal Doc Ref],ClearingStatus,[Created By],[Created On],[Modified By],[Modified On],COA_Parameter,classOrder

	 from
	 (
		 /********* Step 6.2.1.1 : Getting records except coresponding account column ************************************/
		 Select      COA.Code [COA Code], COA.Name as 'COA Name',COA.Nature AS [Account Nature], JD.DocType,JD.DocSubType,COA.Class,COA.Category,COA.SubCategory,A.Name As AccountType,
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
					 J.PONo,JD.Nature,TP.TOPValue as [CreditTerms(Days)],J.DueDate,NSD.[NSD ISCHECKED],CASE WHEN J.IsNoSupportingDocs=0 THEN 'NO' WHEN J.IsNoSupportingDocs=1 THEN 'YES' END AS [NO SUPPORT DOC],JD.ItemCode,JD.ItemDescription,JD.Qty,JD.Unit,JD.UnitPrice,JD.DiscountType,JD.Discount,[BRM ISCHECKED],case when IsAllowableNonAllowable=0 then 'NO' when IsAllowableNonAllowable=1 then 'YES' END AS [ALLOWABLE/DISALLOWABLE],JD.ClearingDate AS [Bank Clearing],J.ModeOfReceipt,J.ReversalDate,
					 case when J.IsBankReconcile=0 then 'NO' when J.IsBankReconcile=1 then 'YES' end as [Bank Reconcile],case when J.IsAutoReversalJournal in (1) then J.SystemReferenceNo  end as [Reversal Doc Ref],JD.ClearingStatus,J.UserCreated as [Created By],J.CreatedDate as [Created On],J.ModifiedBy as [Modified By],J.ModifiedDate as [Modified On],@COA_IS as COA_Parameter,
					 Case when COA.Class in('Assets','Asset') then 1 
									when COA.Class='Liabilities' then 2
									when COA.Class='Equity' then 3
									when COA.Class='Income' then 4
									when COA.Class='Expenses' then 5 end as classOrder,CCOA.Name as CorrAccount
		 From        Bean.JournalDetail JD 
		 Inner Join  Bean.Journal J on J.Id=JD.JournalId
		 Inner Join  Bean.ChartOfAccount COA on COA.Id=JD.COAId
		 Left  Join  Bean.ChartOfAccount CCOA on CCOA.Id=JD.CorrAccountId
		 Left  Join  Bean.AccountType A On A.Id=COA.AccountTypeId
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
		 and CONVERT(DATE,J.DocDate) between @ISFD and @ISTD and J.DocumentState<>'Void'
		 AND JD.DocType<>'Journal'
		 --order by [COA Name],DocDate
	 ) as MS1

	 /*********Ending of Step 6.2.1.1 *************************/
	 /*********** Step 6.2.1.2.a : Getting corresponding account column. Here we joined to MS1 on  matching journalid condition ************/
/*	 Left join-- for corraccount ** starting
	 (
		  select distinct JournalId,CorrAccount
		 from
		 (
			 select CA2.JournalId,case when CA2.DistCount<>1 then 'Multiple' else CA3.Name end as CorrAccount
			 from
			 (
				 select JournalId,/*case when count(distinct CA1.COAId)=1 then Name else 'multiple' end corrname*/count(distinct CA1.COAId) as DistCount--,Name
				 from
				 (
					 select  JD.JournalId,JD.COAId,COA.Name  
					 from    Bean.JournalDetail as JD
					 join    Bean.Journal as J on J.Id=JD.JournalId
					 join    Bean.ChartOfAccount as COA on COA.Id=JD.COAId
					 where   J.CompanyId=@CompanyId and JD.DocumentDetailId<>'00000000-0000-0000-0000-000000000000' and COA.ModuleType='Bean' and J.DocumentState<>'Void' --and JD.IsTax<>1 
					         and JD.DocType<>'Journal'
				) as CA1
				group by JournalId--,Name
			) as CA2
			Inner join
			(
				 select  JD.JournalId,JD.COAId,COA.Name  
				 from    Bean.JournalDetail as JD
				 join    Bean.Journal as J on J.Id=JD.JournalId
				 join    Bean.ChartOfAccount as COA on COA.Id=JD.COAId
				 where   J.CompanyId=@CompanyId and JD.DocumentDetailId<>'00000000-0000-0000-0000-000000000000' and COA.ModuleType='Bean' and J.DocumentState<>'Void' --and JD.IsTax<>1 
				         and JD.DocType<>'Journal'
			) as CA3 on CA2.JournalId=CA3.JournalId
		)as CA4 --ending
	 ) as FCA on FCA.JournalId=MS1.JournalId --and MS1.DocType<>'Journal'
	--order by [COA Name]
*/
	/*********** Ending of step 6.2.1.2.a **************/
	
	/*********** Ending of step 6.2.1.3 **************/
	/*********** Ending of step 6.2.1 **************/

	union all

/********* Step 6.2.2 : Getting records when documentdetailid is  not 0 AND JD.DocType<>'Journal' *******************/
 /*********** Step 6.2.2.3 : here we join MS1 (Step 6.2.2.1) and FCA (Step 6.2.2.2) *****************/
 /*********** Taking all columns from MS1 and corresponding Account column from FCA ****************/

	 select  [COA Code],[COA Name],[Account Nature],DocType,DocSubType,Class,Category,SubCategory,AccountType,DocumentDescription,DocDate,DocNo,SystemRefNo,ServiceCompany,EntityName,BaseDebit,BaseCredit,BaseBalance,ExchangeRate,BaseCurrency,DocCurrency,DocDebit,DocCredit,DocBalance,/*IsMultiCurrency,*/SegmentCategory1,SegmentCategory2,MCS_Status,Status, /*FCA.CorrAccount*/CorrAccount,[Entity Type],[Vendor Type],PONo,Nature,[CreditTerms(Days)],DueDate,[NSD ISCHECKED],[NO SUPPORT DOC],ItemCode,ItemDescription,Qty,Unit,UnitPrice,DiscountType,Discount,[BRM ISCHECKED],[ALLOWABLE/DISALLOWABLE],[Bank Clearing],ModeOfReceipt,ReversalDate,[Bank Reconcile],[Reversal Doc Ref],ClearingStatus,[Created By],[Created On],[Modified By],[Modified On],COA_Parameter,classOrder

	 from
	 (
		  /********* Step 6.2.2.1 : Getting records except coresponding account column ************************************/
		 select       COA.Code [COA Code], COA.Name as 'COA Name',COA.Nature AS [Account Nature], JD.DocType,JD.DocSubType,COA.Class,COA.Category,COA.SubCategory,A.Name As AccountType,
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
					  J.PONo,JD.Nature,TP.TOPValue as [CreditTerms(Days)],J.DueDate,NSD.[NSD ISCHECKED],CASE WHEN J.IsNoSupportingDocs=0 THEN 'NO' WHEN J.IsNoSupportingDocs=1 THEN 'YES' END AS [NO SUPPORT DOC],JD.ItemCode,JD.ItemDescription,JD.Qty,JD.Unit,JD.UnitPrice,JD.DiscountType,JD.Discount,[BRM ISCHECKED],case when IsAllowableNonAllowable=0 then 'NO' when IsAllowableNonAllowable=1 then 'YES' END AS [ALLOWABLE/DISALLOWABLE],JD.ClearingDate AS [Bank Clearing],J.ModeOfReceipt,J.ReversalDate,
					  case when J.IsBankReconcile=0 then 'NO' when J.IsBankReconcile=1 then 'YES' end as [Bank Reconcile],case when J.IsAutoReversalJournal in (1) then J.SystemReferenceNo  end as [Reversal Doc Ref],JD.ClearingStatus,J.UserCreated as [Created By],J.CreatedDate as [Created On],J.ModifiedBy as [Modified By],J.ModifiedDate as [Modified On],@COA_IS as COA_Parameter,
					  Case when COA.Class in('Assets','Asset') then 1 
									when COA.Class='Liabilities' then 2
									when COA.Class='Equity' then 3
									when COA.Class='Income' then 4
									when COA.Class='Expenses' then 5 end as classOrder,CCOA.Name as CorrAccount
		 From         Bean.JournalDetail JD 
		 Inner Join   Bean.Journal J on J.Id=JD.JournalId
		 Inner Join   Bean.ChartOfAccount COA on COA.Id=JD.COAId
		 Left  Join   Bean.ChartOfAccount CCOA on CCOA.Id=JD.CorrAccountId
		 Left  Join  Bean.AccountType A On A.Id=COA.AccountTypeId
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

		 where COA.CompanyId=@CompanyId and  JD.DocumentDetailId<>'00000000-0000-0000-0000-000000000000' and COA.ModuleType='Bean' --and JD.IsTax<>1
		-- and JD.DocType  in('Credit Memo','Credit Note') 
		/*and JD.DocSubType not in('CreditNote','Credit Memo')*/
		/* and COA.Name in(@COA_IS)*/
		AND  COA.Name in(select items from dbo.SplitToTable(CONVERT(nvarchar(max), (SELECT @COA_IS FOR XML PATH('')), 1),',')) 
		/* and SC.Name in (SELECT items FROM dbo.SplitToTable(@ServiceCompany,','))*/
		AND  SC.Name in(select items from dbo.SplitToTable(CONVERT(nvarchar(max), (SELECT @ServiceCompany FOR XML PATH('')), 1),','))
		 and CONVERT(DATE,J.DocDate) between @ISFD and @ISTD and J.DocumentState<>'Void'
		 AND JD.DocType<>'Journal'
		 --order by [COA Name],DocDate
	 ) as MS1

	 /*********Ending of Step Step 6.2.2.1 *************************/
	 /*********** Step Step 6.2.2.2 : Getting corresponding account column. Here we joined to MS1 on  matching journalid condition ************/
/*	 Left join-- for corraccount ** starting
	 (
		  Select distinct JournalId,CorrAccount
		  From
		 (
			 Select CA2.JournalId,case when CA2.DistCount<>1 then 'Multiple' else CA3.Name end as CorrAccount
			 From
			 (
				 Select JournalId,/*case when count(distinct CA1.COAId)=1 then Name else 'multiple' end corrname*/count(distinct CA1.COAId) as DistCount--,Name
				 From
				 (
					 Select  JD.JournalId,JD.COAId,COA.Name  
					 From    Bean.JournalDetail as JD
					Join     Bean.Journal as J on J.Id=JD.JournalId
					Join     Bean.ChartOfAccount as COA on COA.Id=JD.COAId
					Where    J.CompanyId=@CompanyId and JD.DocumentDetailId='00000000-0000-0000-0000-000000000000' and COA.ModuleType='Bean' and J.DocumentState<>'Void'-- and JD.IsTax<>1
					AND JD.DocType<>'Journal'
				) as CA1
				group by JournalId--,Name
			) as CA2
			Inner join
			(
				 select JD.JournalId,JD.COAId,COA.Name  
				 from   Bean.JournalDetail as JD
				join    Bean.Journal as J on J.Id=JD.JournalId
				join    Bean.ChartOfAccount as COA on COA.Id=JD.COAId
				where   J.CompanyId=@CompanyId and JD.DocumentDetailId='00000000-0000-0000-0000-000000000000' and COA.ModuleType='Bean' and J.DocumentState<>'Void'-- and JD.IsTax<>1
				AND JD.DocType<>'Journal'
			) as CA3 on CA2.JournalId=CA3.JournalId
		)as CA4 --ending
	  ) as FCA on FCA.JournalId=MS1.JournalId
*/	 -- order by [COA Name],DocDate
	/*********** Ending of step Step 6.2.2.2 **************/
	/*********** Ending of step Step 6.2.2.3 **************/
	/*********** Ending of step Step 6.2.2 **************/

   UNION ALL

   	 /********* Step 6.2.3 : Getting records when documentdetailid is 0 AND JD.DocType='Journal' AND JD.DocSubType<>'Opening Balance' *******************/
 
	 /*********** Step 6.2.3.3 : here we join MS1 (Step 6.2.3.1) and FCA (Step 6.2.3.2.a) *****************/
	 /*********** Taking all columns from MS1 and corresponding Account column from FCA ****************/
	
	 select  [COA Code],[COA Name],[Account Nature],DocType,DocSubType,Class,Category,SubCategory,AccountType,DocumentDescription,DocDate,DocNo,SystemRefNo,ServiceCompany,EntityName,BaseDebit,BaseCredit,BaseBalance,ExchangeRate,BaseCurrency,DocCurrency,DocDebit,DocCredit,DocBalance,/*IsMultiCurrency,*/SegmentCategory1,SegmentCategory2,MCS_Status,Status,  /*FCA.CorrAccount*/  CorrAccount,[Entity Type],[Vendor Type],PONo,Nature,[CreditTerms(Days)],DueDate,[NSD ISCHECKED],[NO SUPPORT DOC],ItemCode,ItemDescription,Qty,Unit,UnitPrice,DiscountType,Discount,[BRM ISCHECKED],[ALLOWABLE/DISALLOWABLE],[Bank Clearing],ModeOfReceipt,ReversalDate,[Bank Reconcile],[Reversal Doc Ref],ClearingStatus,[Created By],[Created On],[Modified By],[Modified On],COA_Parameter,classOrder

	 from
	 (
		 /********* Step 6.2.3.1 : Getting records except coresponding account column ************************************/
		 Select      COA.Code [COA Code], COA.Name as 'COA Name',COA.Nature AS [Account Nature], JD.DocType,JD.DocSubType,COA.Class,COA.Category,COA.SubCategory,A.Name As AccountType,
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
					 J.PONo,JD.Nature,TP.TOPValue as [CreditTerms(Days)],J.DueDate,NSD.[NSD ISCHECKED],CASE WHEN J.IsNoSupportingDocs=0 THEN 'NO' WHEN J.IsNoSupportingDocs=1 THEN 'YES' END AS [NO SUPPORT DOC],JD.ItemCode,JD.ItemDescription,JD.Qty,JD.Unit,JD.UnitPrice,JD.DiscountType,JD.Discount,[BRM ISCHECKED],case when IsAllowableNonAllowable=0 then 'NO' when IsAllowableNonAllowable=1 then 'YES' END AS [ALLOWABLE/DISALLOWABLE],JD.ClearingDate AS [Bank Clearing],J.ModeOfReceipt,J.ReversalDate,
					 case when J.IsBankReconcile=0 then 'NO' when J.IsBankReconcile=1 then 'YES' end as [Bank Reconcile],case when J.IsAutoReversalJournal in (1) then J.SystemReferenceNo  end as [Reversal Doc Ref],JD.ClearingStatus,J.UserCreated as [Created By],J.CreatedDate as [Created On],J.ModifiedBy as [Modified By],J.ModifiedDate as [Modified On],@COA_IS as COA_Parameter,
					 Case when COA.Class in('Assets','Asset') then 1 
									when COA.Class='Liabilities' then 2
									when COA.Class='Equity' then 3
									when COA.Class='Income' then 4
									when COA.Class='Expenses' then 5 end as classOrder,JD.COAId,CCOA.Name as CorrAccount
		 From        Bean.JournalDetail JD 
		 Inner Join  Bean.Journal J on J.Id=JD.JournalId
		 Inner Join  Bean.ChartOfAccount COA on COA.Id=JD.COAId
		 Left  Join  Bean.ChartOfAccount CCOA on CCOA.Id=JD.CorrAccountId
		 Left  Join  Bean.AccountType A On A.Id=COA.AccountTypeId
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

		 where COA.CompanyId=@CompanyId --and  JD.DocumentDetailId='00000000-0000-0000-0000-000000000000' 
		 and COA.ModuleType='Bean' --and JD.IsTax<>1
		 /*and JD.DocType not in('Credit Memo','Credit Note') and JD.DocSubType not in('CreditNote','Credit Memo')*/
		 /*and COA.Name in(@COA_IS) */
		 AND  COA.Name in(select items from dbo.SplitToTable(CONVERT(nvarchar(max), (SELECT @COA_IS FOR XML PATH('')), 1),','))
		/* and SC.Name in (SELECT items FROM dbo.SplitToTable(@ServiceCompany,','))*/
		AND  SC.Name in(select items from dbo.SplitToTable(CONVERT(nvarchar(max), (SELECT @ServiceCompany FOR XML PATH('')), 1),','))
		 and CONVERT(DATE,J.DocDate) between @ISFD and @ISTD and J.DocumentState<>'Void'
		 AND JD.DocType='Journal' AND JD.DocSubType<>'Opening Balance'
		 --order by [COA Name],DocDate
	 ) as MS1

	 /*********Ending of Step 6.2.3.1 *************************/
	 /*********** Step 6.2.3.2.a : Getting corresponding account column. Here we joined to MS1 on  matching journalid condition ************/
/*	 Left join-- for corraccount ** starting
	 (
			--Step6:
			Select JCA4.JournalId,JCA4.COAId,JCA4.Name,JCA4.DistCount,case when JCA4.DistCount>2 then 'Multiple'  else JCA5.Name end as CorrAccount
			From
			(   --Step 4
				Select JCA1.JournalId,JCA1.COAId,JCA1.Name,JCA3.DistCount
				From
				(   --step 1:
					select JD.JournalId,JD.COAId,COA.Name  
					from   Bean.JournalDetail as JD
					join    Bean.Journal as J on J.Id=JD.JournalId
					join    Bean.ChartOfAccount as COA on COA.Id=JD.COAId
					where   J.CompanyId=@CompanyId and JD.DocumentDetailId='00000000-0000-0000-0000-000000000000' and COA.ModuleType='Bean' and J.DocumentState<>'Void'-- and JD.IsTax<>1
					--and     J.SystemReferenceNo='JV-2018-00006'
					and     JD.DocType='Journal' AND JD.DocSubType<>'Opening Balance'
					--end of step1
				)JCA1
				Inner JOIN
				(--step 3:
					Select JournalId,/*case when count(distinct CA1.COAId)=1 then Name else 'multiple' end corrname*/count(/*distinct*/ JCA2.COAId) as DistCount--,Name
					 From
					(  --step 2:
						Select  JD.JournalId,JD.COAId,COA.Name  
						From    Bean.JournalDetail as JD
						Join     Bean.Journal as J on J.Id=JD.JournalId
						Join     Bean.ChartOfAccount as COA on COA.Id=JD.COAId
						Where    J.CompanyId=@CompanyId and JD.DocumentDetailId='00000000-0000-0000-0000-000000000000' and COA.ModuleType='Bean' and J.DocumentState<>'Void'-- and JD.IsTax<>1
						--and      j.SystemReferenceNo='JV-2018-00006'
						and     JD.DocType='Journal' AND JD.DocSubType<>'Opening Balance'
						-- end of step2:
					) as JCA2
					group by JournalId--,Name
					--end of step3
				)JCA3 on JCA1.JournalId=JCA3.JournalId
				--end of step4
			)JCA4
			Left JoIN
			(
				   --step5:
					Select  JD.JournalId,JD.COAId,COA.Name  
					From    Bean.JournalDetail as JD
					Join    Bean.Journal as J on J.Id=JD.JournalId
					Join    Bean.ChartOfAccount as COA on COA.Id=JD.COAId
					Where   J.CompanyId=@CompanyId and JD.DocumentDetailId='00000000-0000-0000-0000-000000000000' and COA.ModuleType='Bean' and J.DocumentState<>'Void'-- and JD.IsTax<>1
					--and     j.SystemReferenceNo='JV-2018-00006'
					and     JD.DocType='Journal' AND JD.DocSubType<>'Opening Balance'
					-- end of step5
			)JCA5 on JCA4.JournalId=JCA5.JournalId and JCA4.DistCount<=2  and JCA4.COAId<>JCA5.COAId 
			--End of step6

	 ) as FCA on FCA.JournalId=MS1.JournalId and FCA.COAId=MS1.COAId and MS1.DocType='Journal' AND MS1.DocSubType<>'Opening Balance'
	--order by [COA Name]
*/
	/*********** Ending of step 6.2.3.2.a **************/
	
	/*********** Ending of step 6.2.3.3 **************/
	/*********** Ending of step 6.2.3 **************/

	UNION ALL
	/**** STEP step 6.2.4:  Getting records when documentdetailid is 0 AND JD.DocType='Journal' AND JD.DocSubType='Opening Balance' *******************/
		 
	/**** step 6.2.4.2:Getting all records from Step 6.2.4.1 and added the column CorrAccount by assigning null as default value ***/
	select  [COA Code],[COA Name],[Account Nature],DocType,DocSubType,Class,Category,SubCategory,AccountType,DocumentDescription,DocDate,DocNo,SystemRefNo,ServiceCompany,EntityName,BaseDebit,BaseCredit,BaseBalance,ExchangeRate,BaseCurrency,DocCurrency,DocDebit,DocCredit,DocBalance,/*IsMultiCurrency,*/SegmentCategory1,SegmentCategory2,MCS_Status,Status,  /*FCA.CorrAccount*/null as CorrAccount,[Entity Type],[Vendor Type],PONo,Nature,[CreditTerms(Days)],DueDate,[NSD ISCHECKED],[NO SUPPORT DOC],ItemCode,ItemDescription,Qty,Unit,UnitPrice,DiscountType,Discount,[BRM ISCHECKED],[ALLOWABLE/DISALLOWABLE],[Bank Clearing],ModeOfReceipt,ReversalDate,[Bank Reconcile],[Reversal Doc Ref],ClearingStatus,[Created By],[Created On],[Modified By],[Modified On],COA_Parameter,classOrder

	 from
	 (
		 /********* Step 6.2.4.1 : Getting records except coresponding account column ************************************/
		 Select      COA.Code [COA Code], COA.Name as 'COA Name',COA.Nature AS [Account Nature], JD.DocType,JD.DocSubType,COA.Class,COA.Category,COA.SubCategory,A.Name As AccountType,
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
					 J.PONo,JD.Nature,TP.TOPValue as [CreditTerms(Days)],J.DueDate,NSD.[NSD ISCHECKED],CASE WHEN J.IsNoSupportingDocs=0 THEN 'NO' WHEN J.IsNoSupportingDocs=1 THEN 'YES' END AS [NO SUPPORT DOC],JD.ItemCode,JD.ItemDescription,JD.Qty,JD.Unit,JD.UnitPrice,JD.DiscountType,JD.Discount,[BRM ISCHECKED],case when IsAllowableNonAllowable=0 then 'NO' when IsAllowableNonAllowable=1 then 'YES' END AS [ALLOWABLE/DISALLOWABLE],JD.ClearingDate AS [Bank Clearing],J.ModeOfReceipt,J.ReversalDate,
					 case when J.IsBankReconcile=0 then 'NO' when J.IsBankReconcile=1 then 'YES' end as [Bank Reconcile],case when J.IsAutoReversalJournal in (1) then J.SystemReferenceNo  end as [Reversal Doc Ref],JD.ClearingStatus,J.UserCreated as [Created By],J.CreatedDate as [Created On],J.ModifiedBy as [Modified By],J.ModifiedDate as [Modified On],@COA_IS as COA_Parameter,
					 Case when COA.Class in('Assets','Asset') then 1 
									when COA.Class='Liabilities' then 2
									when COA.Class='Equity' then 3
									when COA.Class='Income' then 4
									when COA.Class='Expenses' then 5 end as classOrder
		 From        Bean.JournalDetail JD 
		 Inner Join  Bean.Journal J on J.Id=JD.JournalId
		 Inner Join  Bean.ChartOfAccount COA on COA.Id=JD.COAId
		 Left  Join  Bean.ChartOfAccount CCOA on CCOA.Id=JD.CorrAccountId
		 Left  Join  Bean.AccountType A On A.Id=COA.AccountTypeId
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
		 and CONVERT(DATE,J.DocDate) between @ISFD and @ISTD and J.DocumentState<>'Void'
		 and JD.DocType='Journal' AND JD.DocSubType='Opening Balance'
		 --order by [COA Name],DocDate
	 ) as MS1

	 /*** End of step 6.2.4.1 ****/
	 /*** End of step 6.2.4.2 ****/

	/*** End of step 6.2.4 ****/

	--END OF STEP 6.2: GETTING RECORDS BETWEEN @ISFD AND @ISTD

	Fetch next from IncomeSheet_cursor into @COA_IS,@COA_IS_CODE,@COA_IS_CORDER,@COA_IS_AccNature,@COA_IS_AccClass,@COA_IS_Category,@COA_IS_SubCategory,@COA_IS_AccType
                                        
End
Close IncomeSheet_cursor
Deallocate IncomeSheet_cursor

                           /******  End of step 6: Data for Income Statement coa's **********/

                           /******  Start of step 7: Data for Balance Sheet coa's **********/

Declare @COA_BSheet nvarchar(max)-- Balance Sheet coa
Declare @COA_BSheet_CODE nvarchar(max)--Balance Sheet coa code
Declare @COA_BSheet_CORDER INT --Balance Sheet coa class order
Declare @COA_BSheet_Category nvarchar(max)
Declare @COA_BSheet_SubCategory nvarchar(max)
Declare @COA_BSheet_AccType nvarchar(max)
Declare @COA_BSheet_AccNature nvarchar(max)
Declare @COA_BSheet_Class nvarchar(max)
Declare @BSheet_BF_CNT Bigint --used to store no of distinct dates between @BSBFFD and @BSBFTD 
Declare @BsheetDoccurrency table (DocCurr nvarchar(10))--used to store distinct doc currencies between @FromDate and @ToDate and Between @BSBFFD and @BSBFTD
Declare @BSheetDoccurrency1 table (DocCurr nvarchar(10)) --used to get distinct doc currencies from @BsheetDoccurrency
Declare @DCurrency NVarchar(10)-- used to store Doc currency which is used in  Dcurrency cursor
Declare @BSheet_BFCurrencyCNT bigint --used to store count of no of days between @BFFD and @BFTD for corresponding @Dcocurrency of Selected Bsheet COA

Declare Balancesheet_cursor cursor for select * from @COA_BalanceSheet
Open Balancesheet_cursor
Fetch next from Balancesheet_cursor into @COA_BSheet,@COA_BSheet_CODE,@COA_BSheet_CORDER,@COA_BSheet_AccNature,@COA_BSheet_Class,@COA_BSheet_Category,@COA_BSheet_SubCategory,
                                         @COA_BSheet_AccType
while @@FETCH_STATUS=0
Begin
  /*** Step 7.1: Retained Earning COA information Getting ****/

	IF @COA_BSheet='Retained earnings'
	BEGIN
	Declare @RECount Bigint
	    Select @RECount=count(J.DocDate)
		From   Bean.ChartOfAccount COA
		Join   Bean.journalDetail JD on JD.Coaid=COA.Id
		Join   Bean.journal J On J.Id=Jd.JournalId
		where  COA.CompanyId=@CompanyId
		and     COA.[Name]=@COA_BSheet
		and     convert(date,J.Docdate) between @FromDate and @Todate
		IF(@RECount=0)
		Begin
		Insert Into @GLReport
		 select  @COA_BSheet_CODE [COA Code],@COA_BSheet as [COA Name],@COA_BSheet_AccNature AS [Account Nature], 'Balance B/F' as DocType,'' as DocSubType,@COA_BSheet_Class AS Class,
		         @COA_BSheet_Category AS Category,@COA_BSheet_SubCategory AS SubCategory,@COA_BSheet_AccType AS AccountType,'' as DocumentDescription,DATEADD(DAY,1,@RETD) as DocDate,'' as DocNo,'' as SystemRefNo,'' as  ServiceCompany,''  as EntityName,null as BaseDebit,null as BaseCredit,Sum([Base Net Profit]) as BaseBalance,null as ExchangeRate,BaseCurrency as BaseCurrency, DocCurrency as DocCurrency, null as DocDebit,null as DocCredit,Sum([Doc Net Profit]) as DocBalance/*IsMultiCurrency,*/,null as SegmentCategory1,null as SegmentCategory2, @MCS_Status,@SegmentStatus as SegmentStatus,null as CorrAccount,null as [Entity Type],null as [Vendor Type],null as PONo,null as Nature,null as [CreditTerms(Days)],null as DueDate,@NSdISChecked as [NSD ISCHECKED],null as [NO SUPPORT DOC],null as ItemCode,null as ItemDescription,null as Qty,null as Unit,null as UnitPrice,null as DiscountType,null as Discount,@BRMIsChecked as [BRM ISCHECKED],null as [ALLOWABLE/DISALLOWABLE],null as [Bank Clearing],null as ModeOfReceipt,null as ReversalDate,NULL as [Bank Reconcile],null as [Reversal Doc Ref],null as ClearingStatus,null as [Created By],null as [Created On],null as [Modified By],null as [Modified On],@COA_BSheet COA_Parameter,3 as classOrder

		--Select /*@COA_BSheet,*/Sum([Base Net Profit]) [Base Net Profit],Sum([Doc Net Profit]) [Doc Net Profit],[Service Company],
		       --BaseCurrency,DocCurrency  
		from
		(
			--Step I
			SELECT Rank as Id,[Account Nature],Class,Category,SubCategory,AccountType,Date,SUM([Base Income]) as 'Income',CreatedDate,ChartOfAccount,[Service Company],
				   SUM([Base Expenses]) AS 'Expenses',(SUM([Base Income]) + SUM([Base Expenses])) as 'Base Net Profit',   
					SUM([Doc Expenses]) AS 'Expenses1',(SUM([Doc Income]) + SUM([Doc Expenses])) as 'Doc Net Profit', 
				   year,month,
				   BaseCurrency,DocCurrency 
			FROM  
			   (  
				--Step H
				SELECT DENSE_RANK() over(partition by Class order by   year,month  ASC)Rank,[Account Nature],Class,Category,SubCategory,AccountType,date,Year,MONTH,
					   SUM([Base Income]) as 'Base Income', 
					   SUM([Base Expenses]) AS 'Base Expenses',
					   SUM([Doc Income]) as 'Doc Income', 
					   SUM([Doc Expenses]) AS 'Doc Expenses',
					   CreatedDate,ChartOfAccount,[Service Company],
					   BaseCurrency,DocCurrency
				FROM   
					 ( 
					--Step G
					 SELECT [Account Nature],Class as Class,Category,SubCategory,AccountType,MONTH(A.CreatedDate) as 'Month',Year(A.CreatedDate) as 'Year',  
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
						SELECT  COMPANYID, [Account Nature],Class,Category,SubCategory,AccountType,CreatedDate,ChartOfAccount,[Service Company],
								case when Date=CreatedDate then [Base Income] ELSE 0.00 END as 'Base Income',
								case when Date=CreatedDate then [Base Expenses] ELSE 0.00 END as 'Base Expenses',
								case when Date=CreatedDate then [Doc Income] ELSE 0.00 END as 'Doc Income',
							   case when Date=CreatedDate then [Doc Expenses] ELSE 0.00 END as 'Doc Expenses',  
							   BaseCurrency,DocCurrency 
						FROM 
						(
							--Step E
							select ss.COMPANYID ,[Account Nature],Class,Category,SubCategory,AccountType,Date,Isnull(Sum([Base Income]),0) 'Base Income',ChartOfAccount,[Service Company],
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
									   COMPANYID,CONVERT(Date,DocDate) as Date,[Account Nature],Class,Category,SubCategory,AccountType,ChartOfAccount,[Service Company],BaseCurrency,DocCurrency
								From 
								(
									--Step C
									Select DocDate,COMPANYID,[Account Nature],Class,Category,SubCategory,AccountType,ChartOfAccount,
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
											   DocDate,DocNo,COMPANYID,[Account Nature],Class,Category,SubCategory,AccountType,ChartOfAccount,[Service Company],BaseCurrency,DocCurrency

									From 
										(  --step A
											Select COA.Nature AS [Account Nature],COA.Class,COA.Category,COA.SubCategory,A.Name As AccountType,JD.DocNo,J.DocDate,COA.COMPANYID,JD.DocumentDetailId,COA.Name 'ChartOfAccount',Comp.Name as 'Service Company',
												   Case COA.Class when 'Income' then Isnull(BaseDebit,0) else 0.00 end as 'CA Dbt',
												   Case COA.Class when 'Income' then  Isnull(BaseCredit,0) else 0.00 end as 'CA Crt',
												   Case COA.Class when 'Expenses' then Isnull(BaseDebit,0) else 0.00 end as 'NCA Dbt',
												   Case COA.Class when 'Expenses' then Isnull(BaseCredit,0) else 0.00 end as 'NCA Crt',
												   Case COA.Class when 'Income' then Isnull(DocDebit,0) else 0.00 end as 'CA Dbt1',
												   Case COA.Class when 'Income' then  Isnull(DocCredit,0) else 0.00 end as 'CA Crt1',
												   Case COA.Class when 'Expenses' then Isnull(DocDebit,0) else 0.00 end as 'NCA Dbt1',
												   Case COA.Class when 'Expenses' then Isnull(DocCredit,0) else 0.00 end as 'NCA Crt1',
												   JD.BaseCurrency,isnull(JD.DocCurrency,'SGD') DocCurrency
											From   Bean.ChartOfAccount COA
											
											Left  Join  Bean.AccountType A On A.Id=COA.AccountTypeId
											join   Bean.JournalDetail As JD on JD.COAId=COA.Id
											Join   Common.Company as Comp on Comp.Id=JD.ServiceCompanyId
											Join   Bean.Journal J on J.Id=JD.JournalId
											where  COA.Companyid=@CompanyId and COA.ModuleType='Bean' 
											and    CONVERT(DATE,J.DocDate) between @REFD and @RETD 
											and J.DocumentState<>'Void'
											and    COA.Class in ('Income','Expenses') -- and  COA.Name='BommiReddy'
											/*and    Comp.Name in (select items from dbo.SplitToTable(@ServiceCompany,',')) */
											AND  Comp.Name in(select items from dbo.SplitToTable(CONVERT(nvarchar(max), (SELECT @ServiceCompany FOR XML PATH('')), 1),','))
											-- End of step A
										 ) as A
										Group By DocDate,DocNo,COMPANYID,Class,Category,SubCategory,[Account Nature],AccountType,ChartOfAccount,[Service Company],BaseCurrency,DocCurrency
										--End of Step B
									) as BH
									Group By DocDate,COMPANYID,Class,Category,SubCategory,[Account Nature],AccountType,BH.[Base Income],BH.[Base Expenses],BH.[Doc Income],BH.[Doc Expenses],
									ChartOfAccount,[Service Company],BaseCurrency,DocCurrency
									-- End of step C
								) as HB
								Group By Class,Category,SubCategory,[Account Nature],AccountType,COMPANYID,DocDate,ChartOfAccount,[Service Company],BaseCurrency,DocCurrency
								-- End of Step D
							  )ss
							Group By COMPANYID,Class,Category,SubCategory,[Account Nature],AccountType,Date,ChartOfAccount,[Service Company],BaseCurrency,DocCurrency
							--End of Step E
						) AS P

						Cross JOIN  
						(  
	  
						 SELECT  TOP (DATEDIFF(DAY, @REFD, @RETD) + 1)
								CreatedDate = convert(Date,DATEADD(DAY, ROW_NUMBER() OVER(ORDER BY a.object_id) - 1, @REFD))
						  FROM    sys.all_objects a
								CROSS JOIN sys.all_objects b
						) AS PP  
						--End of Step F
					) AS A  
					GROUP BY Class,Category,SubCategory,[Account Nature],AccountType,MONTH(A.CreatedDate),Year(A.CreatedDate),  CreatedDate,ChartOfAccount,[Service Company],
							 Left(DateName(Month,A.CreatedDate),3)+'-'+ Right(year(A.CreatedDate),2),  --AS 'month'  
							 BaseCurrency,DocCurrency
					 --End of Step G
				 ) AS AA  
				Group BY Class,Category,SubCategory,[Account Nature],AccountType,date,Year,MONTH ,CreatedDate,ChartOfAccount,[Service Company],BaseCurrency,DocCurrency
				--End of Step H
			) AS P  
			GROUP BY Class,Category,SubCategory,[Account Nature],AccountType,Date,Rank,Year,MONTH ,CreatedDate  ,ChartOfAccount,[Service Company],BaseCurrency,DocCurrency
			-- End of Step I
		) Hari
		Group By [Service Company],BaseCurrency,DocCurrency 
		--End of Step J
	END
	Else if @RECount<>0
	Begin
	 Declare @BSFD1 date,@BSTD1 date
	 Select @BSFD1=@FromDate
	 Select @BSTD1=@ToDate
		Insert Into @GLReport
		select  [COA Code],[COA Name],DocType,DocSubType,[Account Nature],Class,Category,SubCategory,AccountType,DocumentDescription,DocDate,DocNo,SystemRefNo,ServiceCompany,EntityName,BaseDebit,BaseCredit,BaseBalance,ExchangeRate,BaseCurrency,DocCurrency,DocDebit,DocCredit,DocBalance,/*IsMultiCurrency,*/SegmentCategory1,SegmentCategory2,MCS_Status,Status,  /*FCA.CorrAccount*/null AS CorrAccount,[Entity Type],[Vendor Type],PONo,Nature,[CreditTerms(Days)],DueDate,[NSD ISCHECKED],[NO SUPPORT DOC],ItemCode,ItemDescription,Qty,Unit,UnitPrice,DiscountType,Discount,[BRM ISCHECKED],[ALLOWABLE/DISALLOWABLE],[Bank Clearing],ModeOfReceipt,ReversalDate,[Bank Reconcile],[Reversal Doc Ref],ClearingStatus,[Created By],[Created On],[Modified By],[Modified On],COA_Parameter,classOrder

	 from
	 (
		 /********* Step 7.2.2.4.1 : Getting records except coresponding account column ************************************/
		 Select      COA.Code [COA Code], COA.Name as 'COA Name',COA.Nature [Account Nature], JD.DocType,JD.DocSubType,COA.Class,COA.Category,COA.SubCategory,A.Name As AccountType,
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
					 J.PONo,JD.Nature,TP.TOPValue as [CreditTerms(Days)],J.DueDate,NSD.[NSD ISCHECKED],CASE WHEN J.IsNoSupportingDocs=0 THEN 'NO' WHEN J.IsNoSupportingDocs=1 THEN 'YES' END AS [NO SUPPORT DOC],JD.ItemCode,JD.ItemDescription,JD.Qty,JD.Unit,JD.UnitPrice,JD.DiscountType,JD.Discount,[BRM ISCHECKED],case when IsAllowableNonAllowable=0 then 'NO' when IsAllowableNonAllowable=1 then 'YES' END AS [ALLOWABLE/DISALLOWABLE],JD.ClearingDate AS [Bank Clearing],J.ModeOfReceipt,J.ReversalDate,
					 case when J.IsBankReconcile=0 then 'NO' when J.IsBankReconcile=1 then 'YES' end as [Bank Reconcile],case when J.IsAutoReversalJournal in (1) then J.SystemReferenceNo  end as [Reversal Doc Ref],JD.ClearingStatus,J.UserCreated as [Created By],J.CreatedDate as [Created On],J.ModifiedBy as [Modified By],J.ModifiedDate as [Modified On],@COA_BSheet as COA_Parameter,
					 Case when COA.Class in('Assets','Asset') then 1 
									when COA.Class='Liabilities' then 2
									when COA.Class='Equity' then 3
									when COA.Class='Income' then 4
									when COA.Class='Expenses' then 5 end as classOrder,JD.COAId
		 From        Bean.JournalDetail JD 
		 Inner Join  Bean.Journal J on J.Id=JD.JournalId
		 Inner Join  Bean.ChartOfAccount COA on COA.Id=JD.COAId
		 Left  Join  Bean.ChartOfAccount CCOA on CCOA.Id=JD.CorrAccountId
		 Left  Join  Bean.AccountType A On A.Id=COA.AccountTypeId
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
		 AND  COA.Name in(select items from dbo.SplitToTable(CONVERT(nvarchar(max), (SELECT @COA_BSheet FOR XML PATH('')), 1),','))
		/* and SC.Name in (SELECT items FROM dbo.SplitToTable(@ServiceCompany,','))*/
		AND  SC.Name in(select items from dbo.SplitToTable(CONVERT(nvarchar(max), (SELECT @ServiceCompany FOR XML PATH('')), 1),','))
		 and CONVERT(DATE,J.DocDate) between @BSFD1 and @BSTD1 and J.DocumentState<>'Void'
		-- and CONVERT(DATE,J.DocDate) between @fromdate and @Todate and J.DocumentState<>'Void'
		 AND JD.DocType='Journal' AND JD.DocSubType='Opening Balance'
		 --order by [COA Name],DocDate
	 ) as MS1

	End
	End --rebegin
	
    /*** End of Step 7.1: Retained Earning COA information Getting ****/

	/*** Step 7.2: OTHER THAN Retained Earning COA information Getting ****/
	ELSE IF @COA_BSheet<>'Retained earnings'
	BEGIN
	/** Step 7.2.1: GETTING BROUGHT FORWARDED BALANCE BETWEEN @BSBFFD AND @BSBFTD****/

	/*** Step 7.2.1.a : getting Distinct Doc currencies between @BSFD and @BSTD for corresponding @COA_BSheet ****/
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
			Inner Join  Common.Company as SC on SC.Id=J.ServiceCompanyId
			WHERE       COA.CompanyId=@CompanyId
						AND  COA.Name in(select items from dbo.SplitToTable(CONVERT(nvarchar(max), (SELECT @COA_BSheet FOR XML PATH('')), 1),','))
						AND  SC.Name in(select items from dbo.SplitToTable(CONVERT(nvarchar(max), (SELECT @ServiceCompany FOR XML PATH('')), 1),','))
						AND CONVERT(DATE,J.DocDate) BETWEEN @BSFD AND @BSTD
						AND COA.ModuleType='Bean'
						AND J.DocumentState<>'Void'
	/*** End of Step 7.2.1.a : getting Distinct Doc currencies between @BSFD and @BSTD for corresponding @COA_BSheet ****/

	/*** Step 7.2.1.b : getting Distinct Doc currencies between @BSBFFD and @BSBFTD for corresponding @COA_BSheet ****/
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
						AND CONVERT(DATE,J.DocDate) BETWEEN @BSBFFD AND @BSBFTD
						AND COA.ModuleType='Bean'
						AND J.DocumentState<>'Void'
	/*** End of Step 7.2.1.b : getting Distinct Doc currencies between @BSBFFD and @BSBFTD for corresponding @COA_BSheet ****/

	/***Step 7.2.1.c: Getting distinct doccurrencies from BSheetDoccurrency into BSheetDoccurrency1 ***/

	        Insert Into @BSheetDoccurrency1
		    Select Distinct DocCurr From @BsheetDoccurrency
			

			Declare DCurrency cursor for select * from @BSheetDoccurrency1
			Open DCurrency
			Fetch Next From DCurrency Into @DCurrency
			while @@FETCH_STATUS=0
			Begin
			/***Step 7.2.1.d: Getting count of distinct docdates for currosponding DocCurrency of selected BSheet COA between @BSBFFD and @BSBFTD ***/
				
				SELECT		@BSheet_BFCurrencyCNT=COUNT(DISTINCT CONVERT(DATE,J.DocDate))		
			    From        Bean.JournalDetail JD 
				Inner Join  Bean.Journal J on J.Id=JD.JournalId
				Inner Join  Bean.ChartOfAccount COA on COA.Id=JD.COAId
				Inner Join  Common.Company as SC on SC.Id=J.ServiceCompanyId
				WHERE       COA.CompanyId=@CompanyId
							AND  COA.Name in(select items from dbo.SplitToTable(CONVERT(nvarchar(max), (SELECT @COA_BSheet FOR XML PATH('')), 1),','))
							AND  SC.Name in(select items from dbo.SplitToTable(CONVERT(nvarchar(max), (SELECT @ServiceCompany FOR XML PATH('')), 1),','))
							AND CONVERT(DATE,J.DocDate) BETWEEN @BSBFFD AND @BSBFTD
							AND ISNULL(JD.DocCurrency,'SGD') = @DCurrency
							AND COA.ModuleType='Bean'
							AND J.DocumentState<>'Void'
				--print @BSheet_BFCurrencyCNT

            /***End of Step 7.2.1.d: Getting count of distinct docdates for currosponding DocCurrency of selected BSheet COA between @BSBFFD and @BSBFTD ***/

			/**** Step 7.2.1.e:@BSheet_BFCurrencyCNT=0 (i.e. there are no transactions in choosen doc currency for getting Brought forwarded balance. ***/
			--In this case We replace docbalance and basebalance as0.00 
				IF @BSheet_BFCurrencyCNT=0
				Begin
					Insert Into @GLReport
					select  @COA_BSheet_CODE [COA Code],@COA_BSheet as [COA Name],@COA_BSheet_AccNature AS [Account Nature], 'Balance B/F' as DocType,'' as DocSubType,
					        @COA_BSheet_Class AS Class,@COA_BSheet_Category AS Category,@COA_BSheet_SubCategory AS SubCategory,@COA_BSheet_AccType AS AccountType,'' as DocumentDescription,
							@BSFD as DocDate,'' as DocNo,'' as SystemRefNo,@ServiceCompany as  ServiceCompany,''  as EntityName,null as BaseDebit,null as BaseCredit,0.00 as BaseBalance,null as ExchangeRate,'SGD' as BaseCurrency, @DCurrency as DocCurrency, null as DocDebit,null as DocCredit,0.00 as DocBalance/*IsMultiCurrency,*/,null as SegmentCategory1,null as SegmentCategory2, @MCS_Status,@SegmentStatus as SegmentStatus,null as CorrAccount,null as [Entity Type],null as [Vendor Type],null as PONo,null as Nature,null as [CreditTerms(Days)],null as DueDate,@NSdISChecked as [NSD ISCHECKED],null as [NO SUPPORT DOC],null as ItemCode,null as ItemDescription,null as Qty,null as Unit,null as UnitPrice,null as DiscountType,null as Discount,@BRMIsChecked as [BRM ISCHECKED],null as [ALLOWABLE/DISALLOWABLE],null as [Bank Clearing],null as ModeOfReceipt,null as ReversalDate,NULL as [Bank Reconcile],null as [Reversal Doc Ref],null as ClearingStatus,null as [Created By],null as [Created On],null as [Modified By],null as [Modified On],@COA_BSheet COA_Parameter,@COA_BSheet_CORDER as classOrder      
				End
			/**** Step End of 7.2.1.e: @BSheet_BFCurrencyCNT=0 (i.e. there are no transactions in choosen doc currency for getting Brought forwarded balance. ***/
			
			/**** Step 7.2.1.f:  @BSheet_BFCurrencyCNT<>0 (i.e. there are few transactions in choosen doc currency for getting Brought forwarded balance. ***/
				ELSE IF @BSheet_BFCurrencyCNT<>0 
				BEGIN
			      
					  INSERT INTO @GLReport
					  SELECT  @COA_BSheet_CODE [COA Code],@COA_BSheet as [COA Name],@COA_BSheet_AccNature AS [Account Nature], 'Balance B/F' as DocType,'' as DocSubType,
					          @COA_BSheet_Class AS Class,@COA_BSheet_Category AS Category,@COA_BSheet_SubCategory AS SubCategory,@COA_BSheet_AccType AS AccountType,'' as DocumentDescription,
							  @BSFD as DocDate,'' as DocNo,'' as SystemRefNo,@ServiceCompany as  ServiceCompany,''  as EntityName,null as BaseDebit,null as BaseCredit,SUM(BaseBalance) as BaseBalance,null as ExchangeRate,BaseCurrency/*null as BaseCurrency*/, DocCurrency/*null as DocCurrency*/, null as DocDebit,null as DocCredit,SUM(DocBalance) as DocBalance/*IsMultiCurrency,*/,null as SegmentCategory1,null as SegmentCategory2, @MCS_Status,@SegmentStatus as SegmentStatus,null as CorrAccount,null as [Entity Type],null as [Vendor Type],null as PONo,null as Nature,null as [CreditTerms(Days)],null as DueDate,@NSdISChecked as [NSD ISCHECKED],null as [NO SUPPORT DOC],null as ItemCode,null as ItemDescription,null as Qty,null as Unit,null as UnitPrice,null as DiscountType,null as Discount,@BRMIsChecked as [BRM ISCHECKED],null as [ALLOWABLE/DISALLOWABLE],null as [Bank Clearing],null as ModeOfReceipt,null as ReversalDate,NULL as [Bank Reconcile],null as [Reversal Doc Ref],null as ClearingStatus,null as [Created By],null as [Created On],null as [Modified By],null as [Modified On],@COA_BSheet COA_Parameter,@COA_BSheet_CORDER as classOrder
					  --SELECT SUM(BaseBalance) as BaseBalance,SUM(DocBalance) as DocBalance,DocCurrency,BaseCurrency
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
										AND CONVERT(DATE,J.DocDate) BETWEEN @BSBFFD AND @BSBFTD
										AND ISNULL(JD.DocCurrency,'SGD') = @DCurrency
										AND COA.ModuleType='Bean'
										AND J.DocumentState<>'Void'
					  )DT1
					  Group By DocCurrency,BaseCurrency
				END

			/**** End of Step 7.2.1.f:  @BSheet_BFCurrencyCNT<>0 (i.e. there are few transactions in choosen doc currency for getting Brought forwarded balance. ***/
			
				Fetch Next From DCurrency Into @DCurrency
			End
			Close DCurrency
			Deallocate DCurrency
		/** END OFStep 7.2.1: GETTING BROUGHT FORWARDED BALANCE BETWEEN @BSBFFD AND @BSBFTD****/		

	--/** Step 7.2.1.1: Counting no of distinct dates between @BSBFFD AND @BSBFTD ******/

	--	SELECT		@BSheet_BF_CNT=COUNT(DISTINCT CONVERT(DATE,J.DocDate))		
	--	From        Bean.JournalDetail JD 
	--	Inner Join  Bean.Journal J on J.Id=JD.JournalId
	--	Inner Join  Bean.ChartOfAccount COA on COA.Id=JD.COAId
	--	Inner Join  Common.Company as SC on SC.Id=J.ServiceCompanyId
	--	WHERE       COA.CompanyId=@CompanyId
	--		        AND  COA.Name in(select items from dbo.SplitToTable(CONVERT(nvarchar(max), (SELECT @COA_BSheet FOR XML PATH('')), 1),','))
	--			    AND  SC.Name in(select items from dbo.SplitToTable(CONVERT(nvarchar(max), (SELECT @ServiceCompany FOR XML PATH('')), 1),','))
	--				AND CONVERT(DATE,J.DocDate) BETWEEN @BSBFFD AND @BSBFTD
	--				AND COA.ModuleType='Bean'
	--				AND J.DocumentState<>'Void'
 --   /** END OF Step 7.2.1.1: Counting no of distinct dates between @BSBFFD AND @BSBFTD ******/

	--    /** Step 7.2.1.2: @BSheet_BF_CNT=0 ******/
	--    IF @BSheet_BF_CNT=0
	--	BEGIN
	--		Insert Into @GLReport
	--		select  @COA_BSheet_CODE+'  '+@COA_BSheet as [COA Name], 'Balance B/F' as DocType,'' as DocSubType,'' as DocumentDescription,@BSFD as DocDate,'' as DocNo,'' as SystemRefNo,'' as  ServiceCompany,''  as EntityName,null as BaseDebit,null as BaseCredit,0.00 as BaseBalance,null as ExchangeRate,null as BaseCurrency, null as DocCurrency, null as DocDebit,null as DocCredit,0.00 as DocBalance/*IsMultiCurrency,*/,null as SegmentCategory1,null as SegmentCategory2, @MCS_Status,@SegmentStatus as SegmentStatus,null as CorrAccount,null as [Entity Type],null as [Vendor Type],null as PONo,null as Nature,null as [CreditTerms(Days)],null as DueDate,@NSdISChecked as [NSD ISCHECKED],null as [NO SUPPORT DOC],null as ItemCode,null as ItemDescription,null as Qty,null as Unit,null as UnitPrice,null as DiscountType,null as Discount,@BRMIsChecked as [BRM ISCHECKED],null as [ALLOWABLE/DISALLOWABLE],null as [Bank Clearing],null as ModeOfReceipt,null as ReversalDate,NULL as [Bank Reconcile],null as [Reversal Doc Ref],null as ClearingStatus,null as [Created By],null as [Created On],null as [Modified By],null as [Modified On],@COA_BSheet COA_Parameter,@COA_BSheet_CORDER as classOrder      
	--	END
	--    /** END OF Step 7.2.1.2: @BSheet_BF_CNT=0 ******/

	--	 /** Step 7.2.1.2: @BSheet_BF_CNT<>0 ******/
	--	ELSE IF @BSheet_BF_CNT<>0
	--	BEGIN
 --         Insert Into @GLReport
	--      SELECT  @COA_BSheet_CODE+'  '+@COA_BSheet as [COA Name], 'Balance B/F' as DocType,'' as DocSubType,'' as DocumentDescription,@BSFD as DocDate,'' as DocNo,'' as SystemRefNo,'' as  ServiceCompany,''  as EntityName,null as BaseDebit,null as BaseCredit,SUM(BaseBalance) as BaseBalance,null as ExchangeRate,null as BaseCurrency, null as DocCurrency, null as DocDebit,null as DocCredit,SUM(DocBalance) as DocBalance/*IsMultiCurrency,*/,null as SegmentCategory1,null as SegmentCategory2, @MCS_Status,@SegmentStatus as SegmentStatus,null as CorrAccount,null as [Entity Type],null as [Vendor Type],null as PONo,null as Nature,null as [CreditTerms(Days)],null as DueDate,@NSdISChecked as [NSD ISCHECKED],null as [NO SUPPORT DOC],null as ItemCode,null as ItemDescription,null as Qty,null as Unit,null as UnitPrice,null as DiscountType,null as Discount,@BRMIsChecked as [BRM ISCHECKED],null as [ALLOWABLE/DISALLOWABLE],null as [Bank Clearing],null as ModeOfReceipt,null as ReversalDate,NULL as [Bank Reconcile],null as [Reversal Doc Ref],null as ClearingStatus,null as [Created By],null as [Created On],null as [Modified By],null as [Modified On],@COA_BSheet COA_Parameter,@COA_BSheet_CORDER as classOrder
 --         FROM
	--	  (	
	--			SELECT		isnull((isnull(Case when JD.BaseCurrency=JD.DocCurrency and JD.BaseDebit is null then JD.DocDebit else  JD.BaseDebit end ,0)-isnull(Case when JD.DocCurrency=JD.BaseCurrency and JD.BaseCredit is null then JD.DocCredit else JD.BaseCredit end,0)),0) as BaseBalance,			
	--						isnull((isnull(JD.DocDebit,0)-isnull(JD.DocCredit,0)),0) as DocBalance			
	--			From        Bean.JournalDetail JD 
	--			Inner Join  Bean.Journal J on J.Id=JD.JournalId
	--			Inner Join  Bean.ChartOfAccount COA on COA.Id=JD.COAId
	--			Inner Join  Common.Company as SC on SC.Id=J.ServiceCompanyId
	--			WHERE       COA.CompanyId=@CompanyId
	--						AND  COA.Name in(select items from dbo.SplitToTable(CONVERT(nvarchar(max), (SELECT @COA_BSheet FOR XML PATH('')), 1),','))
	--						AND  SC.Name in(select items from dbo.SplitToTable(CONVERT(nvarchar(max), (SELECT @ServiceCompany FOR XML PATH('')), 1),','))
	--						AND CONVERT(DATE,J.DocDate) BETWEEN @BSBFFD AND @BSBFTD
	--						AND COA.ModuleType='Bean'
	--						AND J.DocumentState<>'Void'
	--	  )DT1

	--	END
	--	 /** END OF Step 7.2.1.3: @BSheet_BF_CNT<>0 ******/

	--/** End Of Step 7.2.1: GETTING BROUGHT FORWARDED BALANCE BETWEEN @BSBFFD AND @BSBFTD****/

	--STEP 7.2.2: GETTING RECORDS BETWEEN @BSFD AND @BSTD

	 /********* Step 7.2.2.1 : Getting records when documentdetailid is 0  AND JD.DocType<>'Journal' *******************/
 
	 /*********** Step 7.2.2.1.3 : here we join MS1 (Step 7.2.2.1.1) and FCA (Step 7.2.2.1.2.a)  *****************/
	 /*********** Taking all columns from MS1 and corresponding Account column from FCA ****************/
	 Insert Into @GLReport
	 select  [COA Code],[COA Name],[Account Nature],DocType,DocSubType,Class,Category,SubCategory,AccountType,DocumentDescription,DocDate,DocNo,SystemRefNo,ServiceCompany,EntityName,BaseDebit,BaseCredit,BaseBalance,ExchangeRate,BaseCurrency,DocCurrency,DocDebit,DocCredit,DocBalance,/*IsMultiCurrency,*/SegmentCategory1,SegmentCategory2,MCS_Status,Status,  /*FCA.CorrAccount*/  CorrAccount,[Entity Type],[Vendor Type],PONo,Nature,[CreditTerms(Days)],DueDate,[NSD ISCHECKED],[NO SUPPORT DOC],ItemCode,ItemDescription,Qty,Unit,UnitPrice,DiscountType,Discount,[BRM ISCHECKED],[ALLOWABLE/DISALLOWABLE],[Bank Clearing],ModeOfReceipt,ReversalDate,[Bank Reconcile],[Reversal Doc Ref],ClearingStatus,[Created By],[Created On],[Modified By],[Modified On],COA_Parameter,classOrder

	 from
	 (
		 /********* Step 7.2.2.1.1 : Getting records except coresponding account column ************************************/
		 Select      COA.Code [COA Code], COA.Name as 'COA Name',COA.Nature AS [Account Nature], JD.DocType,JD.DocSubType,COA.Class,COA.Category,COA.SubCategory,A.Name As AccountType,
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
					 J.PONo,JD.Nature,TP.TOPValue as [CreditTerms(Days)],J.DueDate,NSD.[NSD ISCHECKED],CASE WHEN J.IsNoSupportingDocs=0 THEN 'NO' WHEN J.IsNoSupportingDocs=1 THEN 'YES' END AS [NO SUPPORT DOC],JD.ItemCode,JD.ItemDescription,JD.Qty,JD.Unit,JD.UnitPrice,JD.DiscountType,JD.Discount,[BRM ISCHECKED],case when IsAllowableNonAllowable=0 then 'NO' when IsAllowableNonAllowable=1 then 'YES' END AS [ALLOWABLE/DISALLOWABLE],JD.ClearingDate AS [Bank Clearing],J.ModeOfReceipt,J.ReversalDate,
					 case when J.IsBankReconcile=0 then 'NO' when J.IsBankReconcile=1 then 'YES' end as [Bank Reconcile],case when J.IsAutoReversalJournal in (1) then J.SystemReferenceNo  end as [Reversal Doc Ref],JD.ClearingStatus,J.UserCreated as [Created By],J.CreatedDate as [Created On],J.ModifiedBy as [Modified By],J.ModifiedDate as [Modified On],@COA_BSheet as COA_Parameter,
					 Case when COA.Class in('Assets','Asset') then 1 
									when COA.Class='Liabilities' then 2
									when COA.Class='Equity' then 3
									when COA.Class='Income' then 4
									when COA.Class='Expenses' then 5 end as classOrder,CCOA.Name as CorrAccount
		 From        Bean.JournalDetail JD 
		 Inner Join  Bean.Journal J on J.Id=JD.JournalId
		 Inner Join  Bean.ChartOfAccount COA on COA.Id=JD.COAId
		 Left  Join  Bean.ChartOfAccount CCOA on CCOA.Id=JD.CorrAccountId
		 Left  Join  Bean.AccountType A On A.Id=COA.AccountTypeId
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
		 AND  COA.Name in(select items from dbo.SplitToTable(CONVERT(nvarchar(max), (SELECT @COA_BSheet FOR XML PATH('')), 1),','))
		/* and SC.Name in (SELECT items FROM dbo.SplitToTable(@ServiceCompany,','))*/
		AND  SC.Name in(select items from dbo.SplitToTable(CONVERT(nvarchar(max), (SELECT @ServiceCompany FOR XML PATH('')), 1),','))
		 and CONVERT(DATE,J.DocDate) between @BSFD and @BSTD and J.DocumentState<>'Void'
		 AND JD.DocType<>'Journal'
		 --order by [COA Name],DocDate
	 ) as MS1

	 /*********Ending of Step 7.2.2.1.1 *************************/
	 /*********** Step 7.2.2.1.2.a : Getting corresponding account column. Here we joined to MS1 on  matching journalid condition ************/
/*	 Left join-- for corraccount ** starting
	 (
		  select distinct JournalId,CorrAccount
		 from
		 (
			 select CA2.JournalId,case when CA2.DistCount<>1 then 'Multiple' else CA3.Name end as CorrAccount
			 from
			 (
				 select JournalId,/*case when count(distinct CA1.COAId)=1 then Name else 'multiple' end corrname*/count(distinct CA1.COAId) as DistCount--,Name
				 from
				 (
					 select  JD.JournalId,JD.COAId,COA.Name  
					 from    Bean.JournalDetail as JD
					 join    Bean.Journal as J on J.Id=JD.JournalId
					 join    Bean.ChartOfAccount as COA on COA.Id=JD.COAId
					 where   J.CompanyId=@CompanyId and JD.DocumentDetailId<>'00000000-0000-0000-0000-000000000000' and COA.ModuleType='Bean' and J.DocumentState<>'Void' --and JD.IsTax<>1 
					         and JD.DocType<>'Journal'
				) as CA1
				group by JournalId--,Name
			) as CA2
			Inner join
			(
				 select  JD.JournalId,JD.COAId,COA.Name  
				 from    Bean.JournalDetail as JD
				 join    Bean.Journal as J on J.Id=JD.JournalId
				 join    Bean.ChartOfAccount as COA on COA.Id=JD.COAId
				 where   J.CompanyId=@CompanyId and JD.DocumentDetailId<>'00000000-0000-0000-0000-000000000000' and COA.ModuleType='Bean' and J.DocumentState<>'Void' --and JD.IsTax<>1 
				         and JD.DocType<>'Journal'
			) as CA3 on CA2.JournalId=CA3.JournalId
		)as CA4 --ending
	 ) as FCA on FCA.JournalId=MS1.JournalId -- and MS1.DocType='Journal'
*/	--order by [COA Name]

	/*********** Ending of step 7.2.2.1.2.a **************/
	
	/*********** Ending of step 7.2.2.1.3 **************/
	/*********** Ending of step 7.2.2.1 **************/

	union all

/********* Step 7.2.2.2 : Getting records when documentdetailid is  not 0 AND JD.DocType<>'Journal' *******************/
 /*********** Step 7.2.2.2.3 : here we join MS1 (Step 7.2.2.2.1) and FCA (Step 7.2.2.2.2) *****************/
 /*********** Taking all columns from MS1 and corresponding Account column from FCA ****************/

	 select  [COA Code],[COA Name],[Account Nature],DocType,DocSubType,Class,Category,SubCategory,AccountType,DocumentDescription,DocDate,DocNo,SystemRefNo,ServiceCompany,EntityName,BaseDebit,BaseCredit,BaseBalance,ExchangeRate,BaseCurrency,DocCurrency,DocDebit,DocCredit,DocBalance,/*IsMultiCurrency,*/SegmentCategory1,SegmentCategory2,MCS_Status,Status, /*FCA.CorrAccount*/ CorrAccount,[Entity Type],[Vendor Type],PONo,Nature,[CreditTerms(Days)],DueDate,[NSD ISCHECKED],[NO SUPPORT DOC],ItemCode,ItemDescription,Qty,Unit,UnitPrice,DiscountType,Discount,[BRM ISCHECKED],[ALLOWABLE/DISALLOWABLE],[Bank Clearing],ModeOfReceipt,ReversalDate,[Bank Reconcile],[Reversal Doc Ref],ClearingStatus,[Created By],[Created On],[Modified By],[Modified On],COA_Parameter,classOrder

	 from
	 (
		  /********* Step 7.2.2.2.1 : Getting records except coresponding account column ************************************/
		 select       COA.Code [COA Code], COA.Name as 'COA Name',COA.Nature AS [Account Nature], JD.DocType,JD.DocSubType,COA.Class,COA.Category,COA.SubCategory,A.Name As AccountType,
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
					  J.PONo,JD.Nature,TP.TOPValue as [CreditTerms(Days)],J.DueDate,NSD.[NSD ISCHECKED],CASE WHEN J.IsNoSupportingDocs=0 THEN 'NO' WHEN J.IsNoSupportingDocs=1 THEN 'YES' END AS [NO SUPPORT DOC],JD.ItemCode,JD.ItemDescription,JD.Qty,JD.Unit,JD.UnitPrice,JD.DiscountType,JD.Discount,[BRM ISCHECKED],case when IsAllowableNonAllowable=0 then 'NO' when IsAllowableNonAllowable=1 then 'YES' END AS [ALLOWABLE/DISALLOWABLE],JD.ClearingDate AS [Bank Clearing],J.ModeOfReceipt,J.ReversalDate,
					  case when J.IsBankReconcile=0 then 'NO' when J.IsBankReconcile=1 then 'YES' end as [Bank Reconcile],case when J.IsAutoReversalJournal in (1) then J.SystemReferenceNo  end as [Reversal Doc Ref],JD.ClearingStatus,J.UserCreated as [Created By],J.CreatedDate as [Created On],J.ModifiedBy as [Modified By],J.ModifiedDate as [Modified On],@COA_BSheet as COA_Parameter,
					  Case when COA.Class in('Assets','Asset') then 1 
									when COA.Class='Liabilities' then 2
									when COA.Class='Equity' then 3
									when COA.Class='Income' then 4
									when COA.Class='Expenses' then 5 end as classOrder,CCOA.Name as CorrAccount
		 From         Bean.JournalDetail JD 
		 Inner Join   Bean.Journal J on J.Id=JD.JournalId
		 Inner Join   Bean.ChartOfAccount COA on COA.Id=JD.COAId
		 Left  Join   Bean.ChartOfAccount CCOA on CCOA.Id=JD.CorrAccountId
		 Left  Join  Bean.AccountType A On A.Id=COA.AccountTypeId
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

		 where COA.CompanyId=@CompanyId and  JD.DocumentDetailId<>'00000000-0000-0000-0000-000000000000' and COA.ModuleType='Bean' --and JD.IsTax<>1
		-- and JD.DocType  in('Credit Memo','Credit Note') 
		/*and JD.DocSubType not in('CreditNote','Credit Memo')*/
		/* and COA.Name in(@COA_IS)*/
		AND  COA.Name in(select items from dbo.SplitToTable(CONVERT(nvarchar(max), (SELECT @COA_BSheet FOR XML PATH('')), 1),',')) 
		/* and SC.Name in (SELECT items FROM dbo.SplitToTable(@ServiceCompany,','))*/
		AND  SC.Name in(select items from dbo.SplitToTable(CONVERT(nvarchar(max), (SELECT @ServiceCompany FOR XML PATH('')), 1),','))
		 and CONVERT(DATE,J.DocDate) between @BSFD and @BSTD and J.DocumentState<>'Void'
		 AND JD.DocType<>'Journal'
		 --order by [COA Name],DocDate
	 ) as MS1

	 /*********Ending of Step Step 7.2.2.2.1 *************************/
	 /*********** Step Step 7.2.2.2.2 : Getting corresponding account column. Here we joined to MS1 on  matching journalid condition ************/
/*	 Left join-- for corraccount ** starting
	 (
		  Select distinct JournalId,CorrAccount
		  From
		 (
			 Select CA2.JournalId,case when CA2.DistCount<>1 then 'Multiple' else CA3.Name end as CorrAccount
			 From
			 (
				 Select JournalId,/*case when count(distinct CA1.COAId)=1 then Name else 'multiple' end corrname*/count(distinct CA1.COAId) as DistCount--,Name
				 From
				 (
					 Select  JD.JournalId,JD.COAId,COA.Name  
					 From    Bean.JournalDetail as JD
					Join     Bean.Journal as J on J.Id=JD.JournalId
					Join     Bean.ChartOfAccount as COA on COA.Id=JD.COAId
					Where    J.CompanyId=@CompanyId and JD.DocumentDetailId='00000000-0000-0000-0000-000000000000' and COA.ModuleType='Bean' and J.DocumentState<>'Void'-- and JD.IsTax<>1
					AND      JD.DocType<>'Journal'
				) as CA1
				group by JournalId--,Name
			) as CA2
			Inner join
			(
				 select JD.JournalId,JD.COAId,COA.Name  
				 from   Bean.JournalDetail as JD
				join    Bean.Journal as J on J.Id=JD.JournalId
				join    Bean.ChartOfAccount as COA on COA.Id=JD.COAId
				where   J.CompanyId=@CompanyId and JD.DocumentDetailId='00000000-0000-0000-0000-000000000000' and COA.ModuleType='Bean' and J.DocumentState<>'Void'-- and JD.IsTax<>1
				AND     JD.DocType<>'Journal'
			) as CA3 on CA2.JournalId=CA3.JournalId
		)as CA4 --ending
	  ) as FCA on FCA.JournalId=MS1.JournalId
*/	  --order by [COA Name],DocDate
	/*********** Ending of step Step 7.2.2.2.2 **************/
	/*********** Ending of step Step 7.2.2.2.3 **************/
	/*********** Ending of step Step 7.2.2.2 **************/

	UNION ALL

		 /********* Step 7.2.2.3 : Getting records when documentdetailid is 0  JD.DocType='Journal' AND JD.DocSubType<>'Opening Balance' *******************/
 
	 /*********** Step 7.2.2.3.3 : here we join MS1 (Step 7.2.2.3.1) and FCA (Step 7.2.2.3.2.a)  *****************/
	 /*********** Taking all columns from MS1 and corresponding Account column from FCA ****************/
	
	 select  [COA Code],[COA Name],[Account Nature],DocType,DocSubType,Class,Category,SubCategory,AccountType,DocumentDescription,DocDate,DocNo,SystemRefNo,ServiceCompany,EntityName,BaseDebit,BaseCredit,BaseBalance,ExchangeRate,BaseCurrency,DocCurrency,DocDebit,DocCredit,DocBalance,/*IsMultiCurrency,*/SegmentCategory1,SegmentCategory2,MCS_Status,Status,  /*FCA.CorrAccount*/  CorrAccount,[Entity Type],[Vendor Type],PONo,Nature,[CreditTerms(Days)],DueDate,[NSD ISCHECKED],[NO SUPPORT DOC],ItemCode,ItemDescription,Qty,Unit,UnitPrice,DiscountType,Discount,[BRM ISCHECKED],[ALLOWABLE/DISALLOWABLE],[Bank Clearing],ModeOfReceipt,ReversalDate,[Bank Reconcile],[Reversal Doc Ref],ClearingStatus,[Created By],[Created On],[Modified By],[Modified On],COA_Parameter,classOrder

	 from
	 (
		 /********* Step 7.2.2.3.1 : Getting records except coresponding account column ************************************/
		 Select      COA.Code [COA Code], COA.Name as 'COA Name',COA.Nature AS [Account Nature], JD.DocType,JD.DocSubType,COA.Class,COA.Category,COA.SubCategory,A.Name As AccountType,
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
					 J.PONo,JD.Nature,TP.TOPValue as [CreditTerms(Days)],J.DueDate,NSD.[NSD ISCHECKED],CASE WHEN J.IsNoSupportingDocs=0 THEN 'NO' WHEN J.IsNoSupportingDocs=1 THEN 'YES' END AS [NO SUPPORT DOC],JD.ItemCode,JD.ItemDescription,JD.Qty,JD.Unit,JD.UnitPrice,JD.DiscountType,JD.Discount,[BRM ISCHECKED],case when IsAllowableNonAllowable=0 then 'NO' when IsAllowableNonAllowable=1 then 'YES' END AS [ALLOWABLE/DISALLOWABLE],JD.ClearingDate AS [Bank Clearing],J.ModeOfReceipt,J.ReversalDate,
					 case when J.IsBankReconcile=0 then 'NO' when J.IsBankReconcile=1 then 'YES' end as [Bank Reconcile],case when J.IsAutoReversalJournal in (1) then J.SystemReferenceNo  end as [Reversal Doc Ref],JD.ClearingStatus,J.UserCreated as [Created By],J.CreatedDate as [Created On],J.ModifiedBy as [Modified By],J.ModifiedDate as [Modified On],@COA_BSheet as COA_Parameter,
					 Case when COA.Class in('Assets','Asset') then 1 
									when COA.Class='Liabilities' then 2
									when COA.Class='Equity' then 3
									when COA.Class='Income' then 4
									when COA.Class='Expenses' then 5 end as classOrder,JD.COAId,CCOA.Name as CorrAccount
		 From        Bean.JournalDetail JD 
		 Inner Join  Bean.Journal J on J.Id=JD.JournalId
		 Inner Join  Bean.ChartOfAccount COA on COA.Id=JD.COAId
		 Left  Join  Bean.ChartOfAccount CCOA on CCOA.Id=JD.CorrAccountId
		 Left  Join  Bean.AccountType A On A.Id=COA.AccountTypeId
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

		 where COA.CompanyId=@CompanyId --and  JD.DocumentDetailId='00000000-0000-0000-0000-000000000000' 
		 and COA.ModuleType='Bean' --and JD.IsTax<>1
		 /*and JD.DocType not in('Credit Memo','Credit Note') and JD.DocSubType not in('CreditNote','Credit Memo')*/
		 /*and COA.Name in(@COA_IS) */
		 AND  COA.Name in(select items from dbo.SplitToTable(CONVERT(nvarchar(max), (SELECT @COA_BSheet FOR XML PATH('')), 1),','))
		/* and SC.Name in (SELECT items FROM dbo.SplitToTable(@ServiceCompany,','))*/
		AND  SC.Name in(select items from dbo.SplitToTable(CONVERT(nvarchar(max), (SELECT @ServiceCompany FOR XML PATH('')), 1),','))
		 and CONVERT(DATE,J.DocDate) between @BSFD and @BSTD and J.DocumentState<>'Void'
		 AND JD.DocType='Journal' AND JD.DocSubType<>'Opening Balance'
		 --order by [COA Name],DocDate
	 ) as MS1

	 /*********Ending of Step 7.2.2.3.1 *************************/
	 /*********** Step 7.2.2.3.2.a : Getting corresponding account column. Here we joined to MS1 on  matching journalid condition ************/
/*	 Left join-- for corraccount ** starting
	 (
			--Step6:
			Select JCA4.JournalId,JCA4.COAId,JCA4.Name,JCA4.DistCount,case when JCA4.DistCount>2 then 'Multiple'  else JCA5.Name end as CorrAccount
			From
			(   --Step 4
				Select JCA1.JournalId,JCA1.COAId,JCA1.Name,JCA3.DistCount
				From
				(   --step 1:
					select JD.JournalId,JD.COAId,COA.Name  
					from   Bean.JournalDetail as JD
					join    Bean.Journal as J on J.Id=JD.JournalId
					join    Bean.ChartOfAccount as COA on COA.Id=JD.COAId
					where   J.CompanyId=@CompanyId and JD.DocumentDetailId='00000000-0000-0000-0000-000000000000' and COA.ModuleType='Bean' and J.DocumentState<>'Void'-- and JD.IsTax<>1
					--and     J.SystemReferenceNo='JV-2018-00006'
					and     JD.DocType='Journal' AND JD.DocSubType<>'Opening Balance'
					--end of step1
				)JCA1
				Inner JOIN
				(--step 3:
					Select JournalId,/*case when count(distinct CA1.COAId)=1 then Name else 'multiple' end corrname*/count(/*distinct*/ JCA2.COAId) as DistCount--,Name
					 From
					(  --step 2:
						Select  JD.JournalId,JD.COAId,COA.Name  
						From    Bean.JournalDetail as JD
						Join     Bean.Journal as J on J.Id=JD.JournalId
						Join     Bean.ChartOfAccount as COA on COA.Id=JD.COAId
						Where    J.CompanyId=@CompanyId and JD.DocumentDetailId='00000000-0000-0000-0000-000000000000' and COA.ModuleType='Bean' and J.DocumentState<>'Void'-- and JD.IsTax<>1
						--and      j.SystemReferenceNo='JV-2018-00006'
						and     JD.DocType='Journal' AND JD.DocSubType<>'Opening Balance'
						-- end of step2:
					) as JCA2
					group by JournalId--,Name
					--end of step3
				)JCA3 on JCA1.JournalId=JCA3.JournalId
				--end of step4
			)JCA4
			Left JoIN
			(
				   --step5:
					Select  JD.JournalId,JD.COAId,COA.Name  
					From    Bean.JournalDetail as JD
					Join    Bean.Journal as J on J.Id=JD.JournalId
					Join    Bean.ChartOfAccount as COA on COA.Id=JD.COAId
					Where   J.CompanyId=@CompanyId and JD.DocumentDetailId='00000000-0000-0000-0000-000000000000' and COA.ModuleType='Bean' and J.DocumentState<>'Void'-- and JD.IsTax<>1
					--and     j.SystemReferenceNo='JV-2018-00006'
					and     JD.DocType='Journal' AND JD.DocSubType<>'Opening Balance'
					-- end of step5
			)JCA5 on JCA4.JournalId=JCA5.JournalId and JCA4.DistCount<=2  and JCA4.COAId<>JCA5.COAId 
			--End of step6

	 ) as FCA on FCA.JournalId=MS1.JournalId and FCA.COAId=MS1.COAId and MS1.DocType='Journal' AND MS1.DocSubType<>'Opening Balance'
*/	--order by [COA Name]

	/*********** Ending of step 7.2.2.3.2.a **************/
	
	/*********** Ending of step 7.2.2.3.3 **************/
	/*********** Ending of step 7.2.2.3 **************/

	UNION ALL
		 /********* Step 7.2.2.4 : Getting records when documentdetailid is 0  JD.DocType='Journal' AND JD.DocSubType='Opening Balance' *******************/
		 
		 /***STEP:7.2.2.4.2 : GETTING ALL RECORDS FROM STEP:7.2.2.4.1 AND  ADDING CorrAccount COLUMN BY ASSIGNEED null AS DEFAULT VALUE ****/
		  
	select  [COA Code],[COA Name],[Account Nature],DocType,DocSubType,Class,Category,SubCategory,AccountType,DocumentDescription,DocDate,DocNo,SystemRefNo,ServiceCompany,EntityName,BaseDebit,BaseCredit,BaseBalance,ExchangeRate,BaseCurrency,DocCurrency,DocDebit,DocCredit,DocBalance,/*IsMultiCurrency,*/SegmentCategory1,SegmentCategory2,MCS_Status,Status,  /*FCA.CorrAccount*/null AS CorrAccount,[Entity Type],[Vendor Type],PONo,Nature,[CreditTerms(Days)],DueDate,[NSD ISCHECKED],[NO SUPPORT DOC],ItemCode,ItemDescription,Qty,Unit,UnitPrice,DiscountType,Discount,[BRM ISCHECKED],[ALLOWABLE/DISALLOWABLE],[Bank Clearing],ModeOfReceipt,ReversalDate,[Bank Reconcile],[Reversal Doc Ref],ClearingStatus,[Created By],[Created On],[Modified By],[Modified On],COA_Parameter,classOrder

	 from
	 (
		 /********* Step 7.2.2.4.1 : Getting records except coresponding account column ************************************/
		 Select      COA.Code [COA Code], COA.Name as 'COA Name',COA.Nature AS [Account Nature], JD.DocType,JD.DocSubType,COA.Class,COA.Category,COA.SubCategory,A.Name As AccountType,
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
					 J.PONo,JD.Nature,TP.TOPValue as [CreditTerms(Days)],J.DueDate,NSD.[NSD ISCHECKED],CASE WHEN J.IsNoSupportingDocs=0 THEN 'NO' WHEN J.IsNoSupportingDocs=1 THEN 'YES' END AS [NO SUPPORT DOC],JD.ItemCode,JD.ItemDescription,JD.Qty,JD.Unit,JD.UnitPrice,JD.DiscountType,JD.Discount,[BRM ISCHECKED],case when IsAllowableNonAllowable=0 then 'NO' when IsAllowableNonAllowable=1 then 'YES' END AS [ALLOWABLE/DISALLOWABLE],JD.ClearingDate AS [Bank Clearing],J.ModeOfReceipt,J.ReversalDate,
					 case when J.IsBankReconcile=0 then 'NO' when J.IsBankReconcile=1 then 'YES' end as [Bank Reconcile],case when J.IsAutoReversalJournal in (1) then J.SystemReferenceNo  end as [Reversal Doc Ref],JD.ClearingStatus,J.UserCreated as [Created By],J.CreatedDate as [Created On],J.ModifiedBy as [Modified By],J.ModifiedDate as [Modified On],@COA_BSheet as COA_Parameter,
					 Case when COA.Class in('Assets','Asset') then 1 
									when COA.Class='Liabilities' then 2
									when COA.Class='Equity' then 3
									when COA.Class='Income' then 4
									when COA.Class='Expenses' then 5 end as classOrder,JD.COAId
		 From        Bean.JournalDetail JD 
		 Inner Join  Bean.Journal J on J.Id=JD.JournalId
		 Inner Join  Bean.ChartOfAccount COA on COA.Id=JD.COAId
		 Left  Join  Bean.ChartOfAccount CCOA on CCOA.Id=JD.CorrAccountId
		 Left  Join  Bean.AccountType A On A.Id=COA.AccountTypeId
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
		 AND  COA.Name in(select items from dbo.SplitToTable(CONVERT(nvarchar(max), (SELECT @COA_BSheet FOR XML PATH('')), 1),','))
		/* and SC.Name in (SELECT items FROM dbo.SplitToTable(@ServiceCompany,','))*/
		AND  SC.Name in(select items from dbo.SplitToTable(CONVERT(nvarchar(max), (SELECT @ServiceCompany FOR XML PATH('')), 1),','))
		 and CONVERT(DATE,J.DocDate) between @BSFD and @BSTD and J.DocumentState<>'Void'
		 AND JD.DocType='Journal' AND JD.DocSubType='Opening Balance'
		 --order by [COA Name],DocDate
	 ) as MS1

	 /********END OF STEP:7.2.2.4.1  *******/
	 /********END OF STEP:7.2.2.4.2  *******/

	  /********END OF STEP:7.2.2.4 *******/

	--END OF STEP 7.2.2: GETTING RECORDS BETWEEN @BSFD AND @BSTD
	END
	/*** End of Step 7.2: OTHER THAN Retained Earning COA information Getting ****/

  Fetch next from Balancesheet_cursor into @COA_BSheet,@COA_BSheet_CODE,@COA_BSheet_CORDER,@COA_BSheet_AccNature,@COA_BSheet_Class,@COA_BSheet_Category,@COA_BSheet_SubCategory,
                                         @COA_BSheet_AccType
End
Close Balancesheet_cursor
Deallocate Balancesheet_cursor


                           /******  End of step 7: Data for Balance Sheet coa's **********/

						   /******* Step 8: Final result *******************/
IF @ExcludeClearedItems=0 
BEGIN
                          /***Step 8.1 : Inserting into @GLReport data into @GLReport1 by adding rownumbering by using identity(1,1) ***/
    Insert Into @GLReport1
	SELECT    * 
	FROM      @GLReport 
	order by classOrder,COA_Parameter ,DocDate

	--Select * from @GLReport1

	                      /***End of Step 8.1 : Inserting into @GLReport data into @GLReport1 by adding rownumbering ***/
	
	                      /*** Step 8.2: Calculating running total for DocBalance and BaseBalance columns ineach line  by doc currency wise and insert all records into @GLReport_AfterAdding_SubTotal***/

	/** To do this we get running total of DocBalance and BaseBalance by using over clause with partition by and order by clause in each record of @GLReport1. ****/

	/** Here we took all columns except column named as 'number'.BCZ it mismatched no of columns to be inserted into  @GLReport_AfterAdding_SubTotal**/
	
	/*** Here we set IsSubTotal  to 1 ***/

	Insert Into @GLReport_AfterAdding_SubTotal
	Select  [COA Code],[COA Name],[Account Nature],DocType,DocSubType,Class,Category,SubCategory,AccountType,DocumentDescription,DocDate,DocNo,SystemRefNo,ServiceCompany,EntityName,BaseDebit,BaseCredit, /*sum(BaseBalance) over ( partition by [COA Name],DocCurrency order by number)*/sum(BaseBalance) over ( partition by [COA Name] order by number) BaseBalance,ExchangeRate,BaseCurrency,DocCurrency,DocDebit,DocCredit, sum(DocBalance)  over ( partition by [COA Name],DocCurrency order by number) DocBalance,/*IsMultiCurrency,*/SegmentCategory1,SegmentCategory2,MCS_Status,SegmentStatus, CorrAccount,[Entity Type],[Vendor Type],PONo,Nature,[CreditTerms(Days)],DueDate,[NSD ISCHECKED],[NO SUPPORT DOC],ItemCode,ItemDescription,Qty,Unit,UnitPrice,DiscountType,Discount,[BRM ISCHECKED],[ALLOWABLE/DISALLOWABLE],[Bank Clearing],ModeOfReceipt,ReversalDate,[Bank Reconcile],[Reversal Doc Ref],ClearingStatus,[Created By],[Created On],[Modified By],[Modified On],COA_Parameter,classOrder,0 as IsSubTotal,case when DocType='Balance B/F' then 1 else 2 end as ISBF
	From  @GLReport1
	order by classOrder,COA_Parameter ,DocDate

	                    /*** End of Step 8.2: Calculating running total for DocBalance and BaseBalance columns ineach line  by doc currency wise and insert all records into @GLReport_AfterAdding_SubTotal***/
	
	                    /*** Step 8.3: Getting SubTotal by docCurrency for all COA's ***/

 --   /** Here we calculate SubTotals of DocDebit,DocCredit,DocBalance,BaseDebit,BaseCredit and BaseBalance by DocCurrency wise of each coa. We set IsSubTotal  to 1 **/
	--Insert Into @GLReport_AfterAdding_SubTotal
 --   select    [COA Code],[COA Name],'' AS [Account Nature],'' as DocType,'' as DocSubType,'' AS Class,'' AS Category,'' AS SubCategory,'' As AccountType,'' as DocumentDescription,null as  DocDate,'' as DocNo,'' as SystemRefNo, ServiceCompany,''  as EntityName,sum(isnull(BaseDebit,0.00)) as BaseDebit,sum(isnull(BaseCredit,0.00)) as BaseCredit,sum(BaseBalance) as BaseBalance,null as ExchangeRate, BaseCurrency, DocCurrency, sum(isnull(DocDebit,0.00)) as DocDebit,sum(isnull(DocCredit,0.00)) as DocCredit,sum(DocBalance) as DocBalance/*IsMultiCurrency,*/,null as SegmentCategory1,null as SegmentCategory2,@MCS_Status,@SegmentStatus as SegmentStatus,null as CorrAccount,null as [Entity Type],null as [Vendor Type],null as PONo,null as Nature,null as [CreditTerms(Days)],null as DueDate,@NSdISChecked as [NSD ISCHECKED],null as [NO SUPPORT DOC],null as ItemCode,null as ItemDescription,null as Qty,null as Unit,null as UnitPrice,null as DiscountType,null as Discount,@BRMIsChecked as [BRM ISCHECKED],null as [ALLOWABLE/DISALLOWABLE],null as [Bank Clearing],null as ModeOfReceipt,null as ReversalDate,NULL as [Bank Reconcile],null as [Reversal Doc Ref],null as ClearingStatus,null as [Created By],null as [Created On],null as [Modified By],null as [Modified On], COA_Parameter, classOrder,1 as IsSubTotal,3 as ISBF       
	--FROM      @GLReport 
	--Group By   [COA Code],[COA Name],ServiceCompany,BaseCurrency, DocCurrency,COA_Parameter, classOrder     
	--order by classOrder,COA_Parameter,DocDate

	                    /*** Step 8.3: Getting SubTotal by docCurrency for all COA's ***/

						/** Step 8.4: Finally Displaying Result **/

	Select * From @GLReport_AfterAdding_SubTotal
	order by classOrder,COA_Parameter,IsSubTotal,ISBF,DocDate,DocCurrency
	                 
	                   /** End of Step 8.4: Finally Displaying Result **/                 

End
Else IF @ExcludeClearedItems=1 -- Applying ClearingStatus is null in Where Clause of @GLReport table variable
BEGIN
                          /***Step 8.5 : Inserting into @GLReport data into @GLReport1 by adding rownumbering by using identity(1,1) ***/
    Insert Into @GLReport1
	SELECT    * 
	FROM      @GLReport 
	WHERE     ClearingStatus is null
	order by classOrder,COA_Parameter ,DocDate

	--Select * from @GLReport1

	                      /***End of Step 8.5 : Inserting into @GLReport data into @GLReport1 by adding rownumbering ***/
	
	                      /*** Step 8.6: Calculating running total for DocBalance and BaseBalance columns ineach line  by doc currency wise and insert all records into @GLReport_AfterAdding_SubTotal***/

	/** To do this we get running total of DocBalance and BaseBalance by using over clause with partition by and order by clause in each record of @GLReport1. ****/

	/** Here we took all columns except column named as 'number'.BCZ it mismatched no of columns to be inserted into  @GLReport_AfterAdding_SubTotal**/
	
	/*** Here we set IsSubTotal  to 1 ***/

	Insert Into @GLReport_AfterAdding_SubTotal
	Select  [COA Code],[COA Name],[Account Nature],DocType,DocSubType,Class,Category,SubCategory,AccountType,DocumentDescription,DocDate,DocNo,SystemRefNo,ServiceCompany,EntityName,BaseDebit,BaseCredit, /*sum(BaseBalance) over ( partition by [COA Name],DocCurrency order by number)*/ sum(BaseBalance) over ( partition by [COA Name] order by number)BaseBalance,ExchangeRate,BaseCurrency,DocCurrency,DocDebit,DocCredit, sum(DocBalance)  over ( partition by [COA Name],DocCurrency order by number) DocBalance,/*IsMultiCurrency,*/SegmentCategory1,SegmentCategory2,MCS_Status,SegmentStatus, CorrAccount,[Entity Type],[Vendor Type],PONo,Nature,[CreditTerms(Days)],DueDate,[NSD ISCHECKED],[NO SUPPORT DOC],ItemCode,ItemDescription,Qty,Unit,UnitPrice,DiscountType,Discount,[BRM ISCHECKED],[ALLOWABLE/DISALLOWABLE],[Bank Clearing],ModeOfReceipt,ReversalDate,[Bank Reconcile],[Reversal Doc Ref],ClearingStatus,[Created By],[Created On],[Modified By],[Modified On],COA_Parameter,classOrder,0 as IsSubTotal,case when DocType='Balance B/F' then 1 else 2 end as ISBF 
	From  @GLReport1	
	order by classOrder,COA_Parameter ,DocDate

	                    /*** End of Step 8.6: Calculating running total for DocBalance and BaseBalance columns ineach line  by doc currency wise and insert all records into @GLReport_AfterAdding_SubTotal***/
	
	                    /*** Step 8.7: Getting SubTotal by docCurrency for all COA's ***/

    /** Here we calculate SubTotals of DocDebit,DocCredit,DocBalance,BaseDebit,BaseCredit and BaseBalance by DocCurrency wise of each coa. We set IsSubTotal  to 1 **/
	--Insert Into @GLReport_AfterAdding_SubTotal
 --   select    [COA Code],[COA Name],[Account Nature],'' as DocType,'' as DocSubType,Class,Category,SubCategory,AccountType,'' as DocumentDescription,null as  DocDate,'' as DocNo,'' as SystemRefNo, ServiceCompany,''  as EntityName,sum(isnull(BaseDebit,0.00)) as BaseDebit,sum(isnull(BaseCredit,0.00)) as BaseCredit,sum(BaseBalance) as BaseBalance,null as ExchangeRate, BaseCurrency, DocCurrency, sum(isnull(DocDebit,0.00)) as DocDebit,sum(isnull(DocCredit,0.00)) as DocCredit,sum(DocBalance) as DocBalance/*IsMultiCurrency,*/,null as SegmentCategory1,null as SegmentCategory2,@MCS_Status,@SegmentStatus as SegmentStatus,null as CorrAccount,null as [Entity Type],null as [Vendor Type],null as PONo,null as Nature,null as [CreditTerms(Days)],null as DueDate,@NSdISChecked as [NSD ISCHECKED],null as [NO SUPPORT DOC],null as ItemCode,null as ItemDescription,null as Qty,null as Unit,null as UnitPrice,null as DiscountType,null as Discount,@BRMIsChecked as [BRM ISCHECKED],null as [ALLOWABLE/DISALLOWABLE],null as [Bank Clearing],null as ModeOfReceipt,null as ReversalDate,NULL as [Bank Reconcile],null as [Reversal Doc Ref],null as ClearingStatus,null as [Created By],null as [Created On],null as [Modified By],null as [Modified On], COA_Parameter, classOrder,1 as IsSubTotal,3 as ISBF      
	--FROM      @GLReport 
	--WHERE     ClearingStatus is null
	--Group By   [COA Code],[COA Name],ServiceCompany,BaseCurrency, DocCurrency,COA_Parameter, classOrder,[Account Nature],
	--           AccountType,Class,Category,SubCategory     
	--order by classOrder,COA_Parameter,DocDate

	                    /*** Step 8.7: Getting SubTotal by docCurrency for all COA's ***/

						/** Step 8.8: Finally Displaying Result **/

	Select * From @GLReport_AfterAdding_SubTotal
	order by classOrder,COA_Parameter,IsSubTotal,ISBF,DocDate,DocCurrency
	                 
	                   /** End of Step 8.8: Finally Displaying Result **/                 

	--SELECT    * 
	--FROM      @GLReport  
	--WHERE     ClearingStatus is null
	--order by classOrder,COA_Parameter ,DocDate
END

                           /******* End of Step 8: Final result *******************/

END
GO
