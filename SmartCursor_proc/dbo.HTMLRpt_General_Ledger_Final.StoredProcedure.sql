USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[HTMLRpt_General_Ledger_Final]    Script Date: 16-12-2024 9.20.10 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



--exec [dbo].[HTMLRpt_General_Ledger_Final] @CompanyId=1718,@FromDate='2022-01-01 00:00:00',@ToDate='2022-12-31 00:00:00',@COA=N'20683,26558,26559,26560,26633,26562,26563,26564,26556,26557,26561,26555,26565,26566,20686,20688,26567,20689,20691,26568,20692,44144,20684,26569,26570,28387,20694,31523,36085,42484,44309,44337,36967,26571,20697,20698,20701,20702,26627,26628,20703,20704,20700,20699,26629,26630,43941,43942,26572,26584,26631,26579,26573,3790,3789,3788,3787,3786,3785,3784,3783,41620,41719,41720,42494,42495,42496,42497,42498,41543,20711,26574,20713,26575,20715,26576,20717,20718,26580,26583,27306,36968,29871,39476,43943,26577,26581,25834,26582,43944,26578,20722,20721,20723,20724,20725,20726,26585,26586,26587,26588,26591,26592,26593,26594,20768,20769,20772,20773,25835,26632,26589,26590,31868,31869,42691,42611,43204,43205,43206,43207,43208,43209,20734,20728,20731,20735,26595,20740,20743,20745,20747,26602,26604,20749,20752,20758,37445,20765,20727,20761,20741,20744,20737,20738,26596,26597,26600,20742,20748,20754,20757,20756,20755,20759,38854,42692,44148,20771,20770,20730,20733,20736,26598,26603,26605,20764,20729,20732,20762,20746,26599,20739,26601,20763,31876,31877,20751,26606,26607,25830',@ServiceCompany=N'6',@ExcludeClearedItem=0,@DocType=N'null'

--Select * from Bean.ChartOfAccount  Where CompanyId=305
--Select * from Common.Company Where Name Like '%MICE@WORK PTE. LTD.%' ParentId=1

--exec [dbo].[HTMLRpt_General_Ledger_Final] @CompanyId =1718,@FromDate ='2022-01-01 00:00:00',@ToDate  Datetime='2022-12-31 00:00:00',@COA varchar(MAX)='44543',@ServiceCompany Varchar(MAX)='1719',@ExcludeClearedItem INT =0,@DocType NVARCHAR(MAX)=N'null'
CREATE Procedure [dbo].[HTMLRpt_General_Ledger_Final]
 @CompanyId BIGINT
,@FromDate Datetime
,@ToDate  Datetime
,@COA varchar(MAX)
,@ServiceCompany Varchar(MAX)
,@ExcludeClearedItem INT 
,@DocType NVARCHAR(MAX)
AS
BEGIN

 DECLARE @ExcludeItemChar NVARCHAR(50)= (CASE WHEN @ExcludeClearedItem = 1 THEN 'Cleared' ELSE '' END)

--Declare @CompanyId int
--SELECT @CompanyId = dbo.DecryptCompanyValue(@CompanyValue)
                      /*******step1: moving coa name and category of SELECTed coa's into @COA_Category table variable**********/
SET @DocType=(CASE WHEN @DocType='null'
					THEN 
					(SELECT STUFF(
					   (SELECT ',' + DocType
						  FROM 
						  (    SELECT DISTINCT JD.DocType--,SC.Id  
							   FROM Bean.JournalDetail as JD (NOLOCK)
							   INNER JOIN Bean.Journal as J (NOLOCK) on J.Id=JD.JournalId  
							   INNER JOIN Bean.ChartOfAccount COA (NOLOCK) on COA.Id=JD.COAId  
							   WHERE COA.CompanyId=@CompanyId 
						  )P
						  FOR XML PATH(''), TYPE
					   ).value('.', 'VARCHAR(MAX)'), 1, 1, '')
					) ELSE @DocType END)

					--select @DocType

SET @FromDate = CAST(@FromDate AS DATE)

Declare  @COA_Category TABLE (COAId BIGINT ,[COA Name] NVARCHAR(MAX),Category NVARCHAR(MAX),Code NVARCHAR(MAX),ClassOrder INT,RecOrder INT,AccTypeId BIGINT)

Insert Into @COA_Category
SELECT COAId,Name AS [COA Name],Category,Code,classOrder,RecOrder, AccountTypeId --INTO #COA_Category
FROM 
(
	SELECT C.Id AS COAId, C.Name,C.Category,C.Code,CASE WHEN C.Class in('Assets','Asset') THEN 1 
							WHEN C.Class='Liabilities' THEN 2
							WHEN C.Class='Equity' THEN 3
							WHEN C.Class='Income' THEN 4
							WHEN C.Class='Expenses' THEN 5 END AS classOrder, A.RecOrder , C.AccountTypeId
	FROM   Bean.ChartOfAccount C (NOLOCK)
	LEFT JOIN Bean.AccountType A (NOLOCK) ON A.ID=C.AccountTypeId AND A.CompanyId=C.CompanyId
	WHERE  C.CompanyId=@CompanyId AND C.ModuleType='Bean'
	--AND C.Name IN (SELECT REPLACE(items , 'amp;', '') from dbo.SplitToTable(CONVERT(nvarchar(max), (SELECT @COA FOR XML PATH('')), 1),','))
	 AND C.Id in (select items from dbo.SplitToTable(@COA,','))
) AS DT1
ORDER BY RecOrder,classOrder
 --SELECT * from @COA_Category
                     /*************END of step1*******************/

                     /********step2: moving coa names where category in balance sheet into @COA_BalanceSheet**********/

--Declare @COA_BalanceSheet table ([COA Name] nvarchar(max),Code Nvarchar(max),ClassOrder int,Recorder INT)

SELECT COAId , [COA Name],Code,ClassOrder,RecOrder,AccTypeId INTO #COA_BalanceSheet FROM @COA_Category WHERE Category='Balance Sheet' ORDER BY RecOrder,[COA Name]


--Insert Into @COA_BalanceSheet
--SELECT [COA Name],Code,ClassOrder,RecOrder from @COA_Category where Category='Balance Sheet' order by RecOrder,[COA Name]

--SELECT * from @COA_BalanceSheet

                       /********END of Step2**********/

                       /********step3: moving coa names where category in Income Statement into @COA_IncomeStatement**********/

Declare @COA_IncomeStatement table (COAId BIGINT, [COA Name] nvarchar(max),Code Nvarchar(max),ClassOrder int,RecOrder Int,AccTypeId BIGINT)

Insert Into @COA_IncomeStatement
SELECT COAId , [COA Name],Code,ClassOrder,RecOrder,AccTypeId from @COA_Category where Category='Income Statement' order by RecOrder,[COA Name]

--SELECT * from @COA_IncomeStatement

                      /********END of Step3**********/

            /******* Step 4: Declaring variables for RE,IS,BS and assigning values into currosponding variables based on FromDate and ToDate *********/ 

Declare @SystemStartDate Date -- i.e to get system start date for that service company. It gives the first transaction recorded date of the SELECTed service company.

Declare @FromDateYear Bigint --i.e to get year  of FromDate
Declare @ToDateYear Bigint --i.e to get year of ToDate

Declare @FYEFromDate Date --i.e to get Financial year END date for year of FromDate
Declare @FYEToDate Date --i.e to get Financial year END date for year of ToDate

Declare @PreviousFYEFromDate Date--i.e to get Financial year END date for (year-1) of FromDate
Declare @PreviousFYEToDate Date --i.e to get Financial year END date for (year-1) of ToDate

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

Declare @DaysBetweENDates Bigint -- i.e to get days between FromDate and ToDate

Declare @Bus_Year_END NVarchar(200) -- i.e to get businee year END  of the company
SELECT @Bus_Year_END= BusinessYearEND from Common.Localization (NOLOCK) where CompanyId=@CompanyId
--Print @Bus_Year_END

SELECT @FromDateYear= YEAR(@FromDate),

--Case When @FromDate>Cast(@Bus_Year_END+'-'+cast(YEAR(@FromDate) AS nvarchar) AS date) then Year(DATEADD(year,-1,Cast(@Bus_Year_END+'-'+cast(YEAR(@FromDate) AS nvarchar) AS date))) Else YEAR(@FromDate) END,

 @ToDateYear=YEAR(@ToDate)  --assigning values to @FromDateYear, @ToDateYear
--Print @FromDateYear, @ToDateYear

  --Assigning @FYEFromDate
SELECT @FYEFromDate=Cast(@Bus_Year_END+'-'+cast(@FromDateYear AS nvarchar) AS date) --casting @FromDateYear to nvarchar and resultant is concatinating to @Bus_Year_END.THEN the resultant is cast to date
--Print @FYEFromDate

  --Assigning @FYEToDate
SELECT @FYEToDate=Cast(@Bus_Year_END+'-'+cast(@ToDateYear AS nvarchar) AS date) --casting @ToDateYear to nvarchar and resultant is concatinating to @Bus_Year_END.THEN the resultant is cast to date
--Print @FYEToDate

  --Assigning @PreviousFYEFromDate
SELECT @PreviousFYEFromDate=DATEADD(year,-1,@FYEFromDate) --going 1 year back from @FYEFromDate
--print @PreviousFYEFromDate

  --Assigning @PreviousFYEToDate
SELECT @PreviousFYEToDate=DATEADD(year,-1,@FYEToDate) --going 1 year back from @FYEToDate
--print @PreviousFYEToDate

  --Assigning @SystemStartDate value
  SELECT @SystemStartDate='1900-01-01'

Declare @UserStartDate date --used to get system first transaction date which will be used in B/F balance date.

SELECT @UserStartDate = convert(date,Min(Jd.PostingDate))
From  Bean.Journal AS J (NOLOCK)
Inner Join Bean.JournalDetail JD (NOLOCK) ON J.Id=JD.JournalId
where J.CompanyId=@CompanyId AND J.DocumentState NOT IN ('Void','Cancelled','Parked','Reset','Recurring','Deleted')
--Print @UserStartDate

  --Assigning @DaysBetweENDates value
SELECT @DaysBetweENDates= DATEDIFF(DAY,@FromDate,@ToDate)
--Print @DaysBetweENDates

  --ASSIGNING BALANCE SHEET DATES VALUES
SELECT @BSBroughtForwardFromDate=@SystemStartDate
SELECT @BSBroughtForwardToDate=DATEADD(DAY,-1,@FromDate) --@FROMDATE-1
SELECT @BSFromDate=@FromDate
SELECT @BSToDate=@ToDate
 -- END OF ASSIGNING BALANCE SHEET DATES VALUES

/****** @Bus_Year_END='01-Jan' STARTING POINT *************/
IF @Bus_Year_END='01-Jan'
BEGIN
/**** START of @DaysBetweENDates>=366 Condition ***********/
	IF @DaysBetweENDates>=366 --1
	BEGIN
		IF (@FromDate=@FYEFromDate AND @ToDate=@FYEToDate) --1.1
		BEGIN
			SELECT @RetainedEarningsFromDate=@SystemStartDate
			--SELECT @RetainedEarningsToDate=@PreviousFYEToDate
			SELECT @RetainedEarningsToDate=@PreviousFYEFromDate --Modified By Saketh(Missing Transactions)

			--SELECT @ISBroughtForwardFromDate=@SystemStartDate
			SELECT @ISBroughtForwardFromDate=DATEADD(DAY,1,@PreviousFYEFromDate) --Modified By Saketh
			 SELECT @ISBroughtForwardToDate=DATEADD(DAY,-1,@FromDate) --Modified By Saketh
			--SELECT @ISFromDate=DATEADD(DAY,1,@PreviousFYEToDate) --i.e.@TDTY1+1
			SELECT @ISFromDate=@FromDate
			SELECT @ISToDate=@ToDate
		END -- END OF 1.1
		ELSE IF (@FromDate=@FYEFromDate AND @ToDate>@FYEToDate) --1.2
		BEGIN
			SELECT @RetainedEarningsFromDate=@SystemStartDate
			--SELECT @RetainedEarningsToDate=@FYEToDate
			SELECT @RetainedEarningsToDate=@PreviousFYEFromDate --Modified By Saketh

			--SELECT @ISBroughtForwardFromDate=@SystemStartDate
			SELECT @ISBroughtForwardFromDate=DATEADD(DAY,1,@PreviousFYEFromDate) --Modified By Saketh
			 SELECT @ISBroughtForwardToDate=DATEADD(DAY,-1,@FromDate) --Modified By Saketh
			--SELECT @ISFromDate=DATEADD(DAY,1,@FYEToDate) --i.e.@FYEToDate+1
			SELECT @ISFromDate=@FromDate --Modified By Saketh
			SELECT @ISToDate=@ToDate
		END -- END OF 1.2
		ELSE IF (@FromDate > @FYEFromDate AND @ToDate=@FYEToDate) --1.3
		BEGIN
			SELECT @RetainedEarningsFromDate=@SystemStartDate
			--SELECT @RetainedEarningsToDate=@PreviousFYEToDate
			SELECT @RetainedEarningsToDate=@FYEFromDate --Modified By Saketh

			--SELECT @ISBroughtForwardFromDate='1900-01-01'
             SELECT @ISBroughtForwardFromDate=DATEADD(DAY,1,@FYEFromDate) --Modified By Saketh
			 SELECT @ISBroughtForwardToDate=DATEADD(DAY,-1,@FromDate) --Modified By Saketh
			--SELECT @ISFromDate=DATEADD(DAY,1,@PreviousFYEToDate) --i.e.@TDTY1+1
			SELECT @ISFromDate=@FromDate --Modified By Saketh
			SELECT @ISToDate=@ToDate
		END -- END OF 1.3
		ELSE IF (@FromDate > @FYEFromDate AND @ToDate > @FYEToDate) --1.4
		BEGIN
			SELECT @RetainedEarningsFromDate=@SystemStartDate
			--SELECT @RetainedEarningsToDate=@FYEToDate
			SELECT @RetainedEarningsToDate=@FYEFromDate --Modified By Saketh

			--SELECT @ISBroughtForwardFromDate='1900-01-01'
			SELECT @ISBroughtForwardFromDate=DATEADD(DAY,1,@FYEFromDate) --Modified By Saketh
			-- SELECT @ISBroughtForwardToDate=@FYEToDate
			 SELECT @ISBroughtForwardToDate=DATEADD(DAY,-1,@FromDate) --Modified By Saketh
			--SELECT @ISFromDate=DATEADD(DAY,1,@FYEToDate) --i.e.@FYEToDate+1
			SELECT @ISFromDate=@FromDate --Modified By Saketh
			SELECT @ISToDate=@ToDate
		END -- END OF 1.4
	END -- END OF 1
	/**** END of @DaysBetweENDates>=366 Condition ***********/

	/**** starting of @DaysBetweENDates<366 *******/
	ELSE
	BEGIN
	/****** STARTING OF @FromDateYear<>@ToDateYear IN @DaysBetweENDates<366 CONDITION ********/ 
		IF @FromDateYear<>@ToDateYear --2
		BEGIN
			IF (@FromDate > @FYEFromDate AND @ToDate=@FYEToDate) --2.1
			BEGIN
				SELECT @RetainedEarningsFromDate=@SystemStartDate
				--SELECT @RetainedEarningsToDate=@FYEFromDate
				SELECT @RetainedEarningsToDate=@FYEFromDate --Modified By Saketh

				SELECT @ISBroughtForwardFromDate=DATEADD(DAY,1,@FYEFromDate) --i.e. @FYEFromDate+1
				SELECT @ISBroughtForwardToDate=DATEADD(DAY,-1,@FromDate) --i.e. @FD-1
				SELECT @ISFromDate=@FromDate
				SELECT @ISToDate=@ToDate
			END -- END OF 2.1
			ELSE IF (@FromDate > @FYEFromDate AND @ToDate > @FYEToDate) --2.2
			BEGIN
				SELECT @RetainedEarningsFromDate=@SystemStartDate
				--SELECT @RetainedEarningsToDate=@FYEToDate
				SELECT @RetainedEarningsToDate=@FYEFromDate --Modified By Saketh

				--SELECT @ISBroughtForwardFromDate='1900-01-01'
                SELECT @ISBroughtForwardFromDate=DATEADD(DAY,1,@FYEFromDate)--Modified By Saketh
				 SELECT @ISBroughtForwardToDate=DATEADD(DAY,-1,@FromDate) --Modified By Saketh
				--SELECT @ISFromDate=DATEADD(DAY,1,@FYEToDate) --i.e. @FYEToDate+1
				SELECT @ISFromDate=@FromDate --Modified By Saketh
				SELECT @ISToDate=@ToDate
			END -- END OF 2.2
		END -- END OF 2
	/****** ENDING OF @FromDateYear<>@ToDateYear IN @DaysBetweENDates<366 CONDITION ********/

	/****** STARTING OF @FromDateYear=@ToDateYear IN @DaysBetweENDates<366 CONDITION ********/
		ELSE IF @FromDateYear=@ToDateYear --3
		BEGIN
			IF(@FromDate=@FYEFromDate AND @ToDate=@FYEFromDate AND @FromDate=@ToDate) --3.1
			BEGIN
				SELECT @RetainedEarningsFromDate=@SystemStartDate
				--SELECT @RetainedEarningsToDate=@PreviousFYEFromDate
				SELECT @RetainedEarningsToDate=@PreviousFYEFromDate --Modified By Saketh

				SELECT @ISBroughtForwardFromDate=DATEADD(DAY,1,@PreviousFYEFromDate) --i.e. @PreviousFYEFromDate+1
				SELECT @ISBroughtForwardToDate=DATEADD(DAY,-1,@FromDate) -- i.e.@FROMDATE-1
				SELECT @ISFromDate=@FromDate
				SELECT @ISToDate=@ToDate
			END --END OF 3.1
			ELSE IF(@FromDate > @FYEFromDate AND @ToDate > @FYEFromDate AND @FromDate=@ToDate) --3.2
			BEGIN
				SELECT @RetainedEarningsFromDate=@SystemStartDate
				--SELECT @RetainedEarningsToDate=@FYEFromDate
				SELECT @RetainedEarningsToDate=@FYEFromDate --Modified By Saketh

				SELECT @ISBroughtForwardFromDate=DATEADD(DAY,1,@FYEFromDate) -- i.e. @FYEFromDate+1
				SELECT @ISBroughtForwardToDate=DATEADD(DAY,-1,@FromDate) -- i.e.@FromDate-1
				SELECT @ISFromDate=@FromDate
				SELECT @ISToDate=@ToDate
			END -- END OF 3.2
			ELSE IF(@FromDate=@FYEFromDate AND @ToDate > @FYEFromDate) --3.3
			BEGIN
				SELECT @RetainedEarningsFromDate=@SystemStartDate
				--SELECT @RetainedEarningsToDate=@FYEFromDate
				SELECT @RetainedEarningsToDate=@FYEFromDate --Modified By Saketh

				--SELECT @ISBroughtForwardFromDate='1900-01-01'
				SELECT @ISBroughtForwardFromDate=DATEADD(DAY,1,@PreviousFYEFromDate)--Modified By Saketh
				 SELECT @ISBroughtForwardToDate=DATEADD(DAY,-1,@FromDate) --Modified By Saketh
				--SELECT @ISFromDate=DATEADD(DAY,1,@FYEFromDate) --i.e. @FYEFromDate+1
				SELECT @ISFromDate=@FromDate --Modified By Saketh
				SELECT @ISToDate=@ToDate
			END -- END OF 3.3
			ELSE IF (@FromDate > @FYEFromDate AND @ToDate > @FYEFromDate) --3.4
			BEGIN
				SELECT @RetainedEarningsFromDate=@SystemStartDate
				--SELECT @RetainedEarningsToDate=@FYEFromDate
				SELECT @RetainedEarningsToDate=@FYEFromDate --Modified By Saketh

				SELECT @ISBroughtForwardFromDate=DATEADD(DAY,1,@FYEFromDate) --i.e. @FYEFromDate+1
				SELECT @ISBroughtForwardToDate=DATEADD(DAY,-1,@FromDate) --i.e. @FromDate-1
				SELECT @ISFromDate=@FromDate
				SELECT @ISToDate=@ToDate
			END -- END OF 3.4
		END -- END OF 3
	/****** ENDING OF @FromDateYear=@ToDateYear IN @DaysBetweENDates<366 CONDITION ********/
	END
	/**** ENDifing of @DaysBetweENDates<366 *******/
END
/****** @Bus_Year_END='01-Jan' ENDING POINT *************/	

/****** @Bus_Year_END='31-Dec' STARTING POINT *************/
ELSE IF @Bus_Year_END='31-Dec'
BEGIN
  /**** START of @DaysBetweENDates>=366 Condition ***********/
	IF @DaysBetweENDates >=366  --1
	BEGIN
		IF(@FromDate < @FYEFromDate AND @ToDate < @FYEToDate) --1.1
		BEGIN
			SELECT @RetainedEarningsFromDate=@SystemStartDate
			--SELECT @RetainedEarningsToDate=@PreviousFYEToDate

			SELECT @RetainedEarningsToDate=@PreviousFYEFromDate --Modified By Saketh


			--SELECT @ISBroughtForwardFromDate='1900-01-01'
			SELECT @ISBroughtForwardFromDate=DATEADD(DAY,1,@PreviousFYEFromDate)--Modified By Saketh
			--SELECT @ISBroughtForwardToDate=@PreviousFYEToDate
			 SELECT @ISBroughtForwardToDate=DATEADD(DAY,-1,@FromDate) --Modified By Saketh
			--SELECT @ISFromDate=DATEADD(DAY,1,@PreviousFYEToDate) --i.e. @PreviousFYEToDate+1
			SELECT @ISFromDate=@FromDate --Modified By Saketh
			SELECT @ISToDate=@ToDate
		END -- END OF 1.1
		ELSE IF(@FromDate < @FYEFromDate AND @ToDate=@FYEToDate) --1.2
		BEGIN
			SELECT @RetainedEarningsFromDate=@SystemStartDate
			--SELECT @RetainedEarningsToDate=@PreviousFYEToDate
			SELECT @RetainedEarningsToDate=@PreviousFYEFromDate --Modified By Saketh

			--SELECT @ISBroughtForwardFromDate='1900-01-01'
			SELECT @ISBroughtForwardFromDate=DATEADD(DAY,1,@PreviousFYEFromDate)--Modified By Saketh
			 SELECT @ISBroughtForwardToDate=DATEADD(DAY,-1,@FromDate) --Modified By Saketh
			--SELECT @ISFromDate=DATEADD(DAY,1,@PreviousFYEToDate) --i.e. @PreviousFYEToDate+1
			SELECT @ISFromDate=@FromDate --Modified By Saketh
			SELECT @ISToDate=@ToDate
		END -- END OF 1.2
		ELSE IF(@FromDate=@FYEFromDate AND @ToDate < @FYEToDate) --1.3
		BEGIN
			SELECT @RetainedEarningsFromDate=@SystemStartDate
			--SELECT @RetainedEarningsToDate=@PreviousFYEToDate
			SELECT @RetainedEarningsToDate=@PreviousFYEFromDate --Modified By Saketh

			--SELECT @ISBroughtForwardFromDate='1900-01-01'
			SELECT @ISBroughtForwardFromDate=DATEADD(DAY,1,@PreviousFYEFromDate) --Modified By Saketh
			 SELECT @ISBroughtForwardToDate=DATEADD(DAY,-1,@FromDate) --Modified By Saketh
			--SELECT @ISFromDate=DATEADD(DAY,1,@PreviousFYEToDate) --i.e. @PreviousFYEToDate+1
			SELECT @ISFromDate=@FromDate --Modified By Saketh
			SELECT @ISToDate=@ToDate
		END -- END OF 1.3
		ELSE IF(@FromDate=@FYEFromDate AND @ToDate=@FYEToDate) --1.4
		BEGIN
			SELECT @RetainedEarningsFromDate=@SystemStartDate
			--SELECT @RetainedEarningsToDate=@PreviousFYEToDate
			SELECT @RetainedEarningsToDate=@PreviousFYEFromDate --Modified By Saketh



			--SELECT @ISBroughtForwardFromDate='1900-01-01'
			SELECT @ISBroughtForwardFromDate=DATEADD(DAY,1,@PreviousFYEFromDate) --Modified By Saketh
			 SELECT @ISBroughtForwardToDate=DATEADD(DAY,-1,@FromDate) --Modified By Saketh
			--SELECT @ISFromDate=DATEADD(DAY,1,@PreviousFYEToDate) --i.e. @PreviousFYEToDate+1
			SELECT @ISFromDate=@FromDate --Modified By Saketh
			SELECT @ISToDate=@ToDate
		END -- END OF 1.4
	END -- END OF 1
	/**** END of @DaysBetweENDates>=366 Condition ***********/

	/**** STARTING of @DaysBetweENDates<366 *******/
	ELSE
	BEGIN
	/****** STARTING OF @FromDateYear<>@ToDateYear CONDITION IN @DaysBetweENDates<366 CONDITION ********/
		IF(@FromDateYear<>@ToDateYear) --START OF 2
		BEGIN
			IF(@FromDate < @FYEFromDate AND @ToDate < @FYEToDate) --2.1
			BEGIN
				SELECT @RetainedEarningsFromDate=@SystemStartDate
				--SELECT @RetainedEarningsToDate=@PreviousFYEToDate
				SELECT @RetainedEarningsToDate=@PreviousFYEFromDate --Modified By Saketh

				--SELECT @ISBroughtForwardFromDate='1900-01-01'
				SELECT @ISBroughtForwardFromDate=DATEADD(DAY,1,@PreviousFYEFromDate) --Modified By Saketh
				 SELECT @ISBroughtForwardToDate=DATEADD(DAY,-1,@FromDate) --Modified By Saketh
				--SELECT @ISFromDate=DATEADD(DAY,1,@PreviousFYEToDate) --i.e. @PreviousFYEToDate+1
				SELECT @ISFromDate=@FromDate --Modified By Saketh
				SELECT @ISToDate=@ToDate
			END  --END OF 2.1
			ELSE IF(@FromDate=@FYEFromDate AND @ToDate < @FYEToDate) --2.2
			BEGIN
				SELECT @RetainedEarningsFromDate=@SystemStartDate
				--SELECT @RetainedEarningsToDate=@PreviousFYEToDate
				SELECT @RetainedEarningsToDate=@PreviousFYEFromDate --Modified By Saketh---------------------------



				--SELECT @ISBroughtForwardFromDate='1900-01-01'
				SELECT @ISBroughtForwardFromDate=DATEADD(DAY,1,@PreviousFYEFromDate) --Modified By Saketh
				 SELECT @ISBroughtForwardToDate=DATEADD(DAY,-1,@FromDate) --Modified By Saketh
				--SELECT @ISFromDate=DATEADD(DAY,1,@PreviousFYEToDate) --i.e.@PreviousFYEToDate+1
				SELECT @ISFromDate=@FromDate --Modified By Saketh
				SELECT @ISToDate=@ToDate
			END -- END OF 2.2

			IF(@FromDate = @FYEFromDate AND @ToDate = @FYEToDate) --2.3
			BEGIN
				SELECT @RetainedEarningsFromDate=@SystemStartDate
				--SELECT @RetainedEarningsToDate=@PreviousFYEToDate
				SELECT @RetainedEarningsToDate=@PreviousFYEFromDate --Modified By Saketh

				--SELECT @ISBroughtForwardFromDate='1900-01-01'
				SELECT @ISBroughtForwardFromDate=DATEADD(DAY,1,@PreviousFYEFromDate) --Modified By Saketh
				 SELECT @ISBroughtForwardToDate=DATEADD(DAY,-1,@FromDate) --Modified By Saketh
				--SELECT @ISFromDate=DATEADD(DAY,1,@PreviousFYEToDate) --i.e. @PreviousFYEToDate+1
				SELECT @ISFromDate=@FromDate --Modified By Saketh
				SELECT @ISToDate=@ToDate
			END  --END OF 2.3
		END --END OF 2
	/****** ENDING OF @FromDateYear<>@ToDateYear CONDITION IN @DaysBetweENDates<366 CONDITION ********/

	/****** STARTING OF @FromDateYear=@ToDateYear CONDITION IN @DaysBetweENDates<366 CONDITION ********/
		ELSE IF(@FromDateYear=@ToDateYear)  -- START 3
		BEGIN
			IF(@FromDate = @FYEFromDate AND @ToDate=@FYEFromDate AND @FromDate=@ToDate) --3.1
			BEGIN
				SELECT @RetainedEarningsFromDate=@SystemStartDate
				--SELECT @RetainedEarningsToDate=@PreviousFYEToDate
				SELECT @RetainedEarningsToDate=@PreviousFYEFromDate --Modified By Saketh

				SELECT @ISBroughtForwardFromDate=DATEADD(DAY,1,@PreviousFYEFromDate) --i.e. @PreviousFYEFromDate+1
				SELECT @ISBroughtForwardToDate=DATEADD(DAY,-1,@FromDate) --i.e. @FD-1
				SELECT @ISFromDate=@FromDate
				SELECT @ISToDate=@ToDate
			END  --END  OF 3.1
			ELSE IF(@FromDate < @FYEFromDate AND @ToDate < @FYEFromDate AND @FromDate=@ToDate) --3.2
			BEGIN
				SELECT @RetainedEarningsFromDate=@SystemStartDate
				--SELECT @RetainedEarningsToDate=@PreviousFYEToDate
				SELECT @RetainedEarningsToDate=@PreviousFYEFromDate --Modified By Saketh

				--SELECT @ISBroughtForwardFromDate=DATEADD(DAY,1,@PreviousFYEToDate) --i.e. @PreviousFYEToDate+1
				SELECT @ISBroughtForwardFromDate=DATEADD(DAY,1,@PreviousFYEFromDate) --Modified By Saketh
				SELECT @ISBroughtForwardToDate=DATEADD(DAY,-1,@FromDate) --i.e. @FromDate-1
				SELECT @ISFromDate=@FromDate
				SELECT @ISToDate=@ToDate
			END -- END OF 3.2
			ELSE IF(@FromDate < @FYEFromDate AND @ToDate < @FYEFromDate AND @FromDate<>DATEADD(DAY,1,@PreviousFYEFromDate)) --3.3
			BEGIN
				SELECT @RetainedEarningsFromDate=@SystemStartDate
				--SELECT @RetainedEarningsToDate=@PreviousFYEToDate
				SELECT @RetainedEarningsToDate=@PreviousFYEFromDate --Modified By Saketh


				--SELECT @ISBroughtForwardFromDate=DATEADD(DAY,1,@PreviousFYEToDate) --i.e. @PreviousFYEToDate+1
				SELECT @ISBroughtForwardFromDate=DATEADD(DAY,1,@PreviousFYEFromDate) --Modified By Saketh
				SELECT @ISBroughtForwardToDate=DATEADD(DAY,-1,@FromDate) --i.e @FromDate-1
				SELECT @ISFromDate=@FromDate
				SELECT @ISToDate=@ToDate
			END --END OF 3.3 
			ELSE IF(@FromDate < @FYEFromDate AND @ToDate=@FYEFromDate AND @FromDate<>DATEADD(DAY,1,@PreviousFYEFromDate)) --3.4
			BEGIN
				SELECT @RetainedEarningsFromDate=@SystemStartDate
				--SELECT @RetainedEarningsToDate=@PreviousFYEToDate
				SELECT @RetainedEarningsToDate=@PreviousFYEFromDate --Modified By Saketh

				--SELECT @ISBroughtForwardFromDate=DATEADD(DAY,1,@PreviousFYEToDate) --i.e. @PreviousFYEToDate+1
				SELECT @ISBroughtForwardFromDate=DATEADD(DAY,1,@PreviousFYEFromDate) --Modified By Saketh
				SELECT @ISBroughtForwardToDate=DATEADD(DAY,-1,@FromDate) --i.e. @FromDate-1
				SELECT @ISFromDate=@FromDate
				SELECT @ISToDate=@ToDate
			END --END OF 3.4
			ELSE IF(@FromDate < @FYEFromDate AND @ToDate < @FYEFromDate AND @FromDate=DATEADD(DAY,1,@PreviousFYEFromDate)) --3.5
			BEGIN
				SELECT @RetainedEarningsFromDate=@SystemStartDate
				--SELECT @RetainedEarningsToDate=@PreviousFYEFromDate
				SELECT @RetainedEarningsToDate=@PreviousFYEFromDate --Modified By Saketh

				--SELECT @ISBroughtForwardFromDate='1900-01-01'
				SELECT @ISBroughtForwardFromDate=DATEADD(DAY,1,@PreviousFYEFromDate) --Modified By Saketh
				 SELECT @ISBroughtForwardToDate=DATEADD(DAY,-1,@FromDate) --Modified By Saketh
				SELECT @ISFromDate=@FromDate
				SELECT @ISToDate=@ToDate
			END --END OF 3.5 


			ELSE IF(@FromDate < @FYEFromDate AND @ToDate=@FYEFromDate AND @FromDate=DATEADD(DAY,1,@PreviousFYEFromDate)) --3.6
			BEGIN
				SELECT @RetainedEarningsFromDate=@SystemStartDate
				--SELECT @RetainedEarningsToDate=@PreviousFYEFromDate

				SELECT @RetainedEarningsToDate=@PreviousFYEFromDate --Modified By Saketh

				--SELECT @ISBroughtForwardFromDate='1900-01-01'
				SELECT @ISBroughtForwardFromDate=DATEADD(DAY,1,@PreviousFYEFromDate) --Modified By Saketh
				 SELECT @ISBroughtForwardToDate=DATEADD(DAY,-1,@FromDate) --Modified By Saketh
				SELECT @ISFromDate=@FromDate
				SELECT @ISToDate=@ToDate
			END --END OF 3.6
		END -- END OF 3
	/****** ENDING OF @FromDateYear=@ToDateYear CONDITION IN @DaysBetweENDates<366 CONDITION ********/
	END
	/**** ENDifing of @DaysBetweENDates<366 *******/
END

/****** @Bus_Year_END='31-Dec' ENDING POINT *************/	

/****** @Bus_Year_END NOT IN ('31-Dec','01-Jan') STARTING POINT *************/	

ELSE 
BEGIN
     /**** START of @DaysBetweENDates>=365 Condition ***********/
	IF @DaysBetweENDates >=365  --1
	BEGIN
		IF(@FromDate < @FYEFromDate AND @ToDate < @FYEToDate) --1.1
		BEGIN
			SELECT @RetainedEarningsFromDate=@SystemStartDate
			--SELECT @RetainedEarningsToDate=@PreviousFYEToDate
			SELECT @RetainedEarningsToDate=@PreviousFYEFromDate --Modified By Saketh

			--SELECT @ISBroughtForwardFromDate='1900-01-01'
			SELECT @ISBroughtForwardFromDate=DATEADD(DAY,1,@PreviousFYEFromDate) --Modified By Saketh
			 SELECT @ISBroughtForwardToDate=DATEADD(DAY,-1,@FromDate) --Modified By Saketh
			--SELECT @ISFromDate=DATEADD(DAY,1,@PreviousFYEToDate) --i.e. @PreviousFYEToDate+1
			SELECT @ISFromDate=@FromDate --Modified By Saketh
			SELECT @ISToDate=@ToDate
		END --END OF 1.1
		ELSE IF(@FromDate > @FYEFromDate AND @ToDate >@FYEToDate) --1.2
		BEGIN
			SELECT @RetainedEarningsFromDate=@SystemStartDate
			--SELECT @RetainedEarningsToDate=@FYEToDate
			SELECT @RetainedEarningsToDate=@FYEFromDate --Modified By Saketh


			--SELECT @ISBroughtForwardFromDate='1900-01-01'
			SELECT @ISBroughtForwardFromDate=DATEADD(DAY,1,@FYEFromDate)--Modified By Saketh
			 SELECT @ISBroughtForwardToDate=DATEADD(DAY,-1,@FromDate) --Modified By Saketh
			--SELECT @ISFromDate=DATEADD(DAY,1,@FYEToDate) --i.e. @FYEToDate+1
			SELECT @ISFromDate=@FromDate --Modified By Saketh
			SELECT @ISToDate=@ToDate
		END -- END OF 1.2
		ELSE IF (@FromDate < @FYEFromDate AND @ToDate > @FYEToDate) --1.3.1
		BEGIN
			SELECT @RetainedEarningsFromDate=@SystemStartDate
			--SELECT @RetainedEarningsToDate=@FYEToDate
			SELECT @RetainedEarningsToDate=@PreviousFYEFromDate --Modified By Saketh---------------------------------

			--SELECT @ISBroughtForwardFromDate='1900-01-01'
			SELECT @ISBroughtForwardFromDate=DATEADD(DAY,1,@PreviousFYEFromDate)--Modified By Saketh
			 SELECT @ISBroughtForwardToDate=DATEADD(DAY,-1,@FromDate) --Modified By Saketh
			--SELECT @ISFromDate=DATEADD(DAY,1,@FYEToDate) --i.e. @FYEToDate+1
			SELECT @ISFromDate=@FromDate --Modified By Saketh
			SELECT @ISToDate=@ToDate
		END --1.3.1
		ELSE IF(@FromDate > @FYEFromDate AND @ToDate < @FYEToDate) --1.3.2
		BEGIN
			SELECT @RetainedEarningsFromDate=@SystemStartDate
			--SELECT @RetainedEarningsToDate=@PreviousFYEToDate
			SELECT @RetainedEarningsToDate=@FYEFromDate --Modified By Saketh

			--SELECT @ISBroughtForwardFromDate='1900-01-01'
			SELECT @ISBroughtForwardFromDate=DATEADD(DAY,1,@FYEFromDate)--Modified By Saketh
			 SELECT @ISBroughtForwardToDate=DATEADD(DAY,-1,@FromDate) --Modified By Saketh
			--SELECT @ISFromDate=DATEADD(DAY,1,@PreviousFYEToDate) --i.e. @PreviousFYEToDate+1
			SELECT @ISFromDate=@FromDate --Modified By Saketh
			SELECT @ISToDate=@ToDate
		END -- END OF 1.3.2
		ELSE IF(@FromDate < @FYEFromDate AND @ToDate= @FYEToDate) --1.4
		BEGIN
			SELECT @RetainedEarningsFromDate=@SystemStartDate
			--SELECT @RetainedEarningsToDate=@PreviousFYEToDate
			SELECT @RetainedEarningsToDate=@PreviousFYEFromDate --Modified By Saketh

			--SELECT @ISBroughtForwardFromDate='1900-01-01'
			SELECT @ISBroughtForwardFromDate=DATEADD(DAY,1,@PreviousFYEFromDate)--Modified By Saketh
			 SELECT @ISBroughtForwardToDate=DATEADD(DAY,-1,@FromDate) --Modified By Saketh
			--SELECT @ISFromDate=DATEADD(DAY,1,@PreviousFYEToDate) --i.e. @PreviousFYEToDate+1
			SELECT @ISFromDate=@FromDate --Modified By Saketh
			SELECT @ISToDate=@ToDate
		END --END OF 1.4
		ELSE IF(@FromDate > @FYEFromDate AND @ToDate=@FYEToDate) --1.5
		BEGIN
			SELECT @RetainedEarningsFromDate=@SystemStartDate
			--SELECT @RetainedEarningsToDate=@PreviousFYEToDate
			SELECT @RetainedEarningsToDate=@FYEFromDate --Modified By Saketh

			--SELECT @ISBroughtForwardFromDate='1900-01-01'
			SELECT @ISBroughtForwardFromDate=DATEADD(DAY,1,@FYEFromDate)--Modified By Saketh
			 SELECT @ISBroughtForwardToDate=DATEADD(DAY,-1,@FromDate) --Modified By Saketh
			--SELECT @ISFromDate=DATEADD(DAY,1,@PreviousFYEToDate) -- i.e. @PreviousFYEToDate+1
			SELECT @ISFromDate=@FromDate --Modified By Saketh
			SELECT @ISToDate=@ToDate
		END -- END OF 1.5
		ELSE IF(@FromDate = @FYEFromDate AND @ToDate = @FYEToDate) --1.6
		BEGIN
			SELECT @RetainedEarningsFromDate=@SystemStartDate
			--SELECT @RetainedEarningsToDate=@PreviousFYEToDate
			SELECT @RetainedEarningsToDate=@PreviousFYEFromDate --Modified By Saketh--------vvvvvvvvv

			--SELECT @ISBroughtForwardFromDate='1900-01-01'
			SELECT @ISBroughtForwardFromDate=DATEADD(DAY,1,@PreviousFYEFromDate)--Modified By Saketh
			 SELECT @ISBroughtForwardToDate=DATEADD(DAY,-1,@FromDate) --Modified By Saketh
			--SELECT @ISFromDate=DATEADD(DAY,1,@PreviousFYEToDate) --i.e. @PreviousFYEToDate+1
			SELECT @ISFromDate=@FromDate --Modified By Saketh
			SELECT @ISToDate=@ToDate
		END --END OF 1.6
		ELSE IF(@FromDate = @FYEFromDate AND @ToDate < @FYEToDate) --1.7
		BEGIN
			SELECT @RetainedEarningsFromDate=@SystemStartDate
			--SELECT @RetainedEarningsToDate=@PreviousFYEToDate
			SELECT @RetainedEarningsToDate=@FYEFromDate --Modified By Saketh

			--SELECT @ISBroughtForwardFromDate='1900-01-01'
			SELECT @ISBroughtForwardFromDate=DATEADD(DAY,1,@PreviousFYEFromDate)--Modified By Saketh
			 SELECT @ISBroughtForwardToDate=DATEADD(DAY,-1,@FromDate) --Modified By Saketh
			--SELECT @ISFromDate=DATEADD(DAY,1,@PreviousFYEToDate) --i.e. @PreviousFYEToDate+1
			SELECT @ISFromDate=@FromDate --Modified By Saketh
			SELECT @ISToDate=@ToDate
		END -- END OF 1.7
		ELSE IF(@FromDate = @FYEFromDate AND @ToDate > @FYEToDate) --1.8
		BEGIN
			SELECT @RetainedEarningsFromDate=@SystemStartDate
			--SELECT @RetainedEarningsToDate=@FYEToDate
			SELECT @RetainedEarningsToDate=@FYEFromDate --Modified By Saketh

			--SELECT @ISBroughtForwardFromDate='1900-01-01'
			SELECT @ISBroughtForwardFromDate=DATEADD(DAY,1,@PreviousFYEFromDate)--Modified By Saketh
			 SELECT @ISBroughtForwardToDate=DATEADD(DAY,-1,@FromDate) --Modified By Saketh
			--SELECT @ISFromDate=DATEADD(DAY,1,@FYEToDate) --i.e.@FYEToDate+1
			SELECT @ISFromDate=@FromDate --Modified By Saketh
			SELECT @ISToDate=@ToDate
		END --END OF 1.8
	END -- END OF 1
	/**** END of @DaysBetweENDates>=365 Condition ***********/

	/**** STARTING of @DaysBetweENDates<365 *******/
	ELSE
	BEGIN
	   /****** STARTING OF @FromDateYear<>@ToDateYear CONDITION IN @DaysBetweENDates<365 CONDITION ********/
		IF (@FromDateYear<>@ToDateYear) --2
		BEGIN
			IF(@FromDate < @FYEFromDate AND @ToDate < @FYEToDate) --2.1
			BEGIN
				SELECT @RetainedEarningsFromDate=@SystemStartDate
				--SELECT @RetainedEarningsToDate=@PreviousFYEToDate
				SELECT @RetainedEarningsToDate=@PreviousFYEFromDate --Modified By Saketh

				--SELECT @ISBroughtForwardFromDate='1900-01-01'
				SELECT @ISBroughtForwardFromDate=DATEADD(DAY,1,@PreviousFYEFromDate)--Modified By Saketh
				 SELECT @ISBroughtForwardToDate=DATEADD(DAY,-1,@FromDate) --Modified By Saketh
				--SELECT @ISFromDate=DATEADD(DAY,1,@FYEFromDate) --i.e.@FYEFromDate+1
				SELECT @ISFromDate=@FromDate --Modified By Saketh
				SELECT @ISToDate=@ToDate
			END --END OF 2.1
			ELSE IF(@FromDate = @FYEFromDate AND @ToDate < @FYEToDate) --2.2
			BEGIN
				SELECT @RetainedEarningsFromDate=@SystemStartDate
				--SELECT @RetainedEarningsToDate=@FromDate
				SELECT @RetainedEarningsToDate=@PreviousFYEFromDate --Modified By Saketh

				--SELECT @ISBroughtForwardFromDate='1900-01-01'
				SELECT @ISBroughtForwardFromDate=DATEADD(DAY,1,@PreviousFYEFromDate)--Modified By Saketh
				 SELECT @ISBroughtForwardToDate=DATEADD(DAY,-1,@FromDate) --Modified By Saketh
				--SELECT @ISFromDate=DATEADD(DAY,1,@FYEFromDate) --i.e.@FYEFromDate+1
				SELECT @ISFromDate=@FromDate --Modified By Saketh
				SELECT @ISToDate=@ToDate
			END --END OF 2.2
			ELSE IF(@FromDate > @FYEFromDate AND @ToDate < @FYEToDate) --2.3
			BEGIN
				SELECT @RetainedEarningsFromDate=@SystemStartDate
				--SELECT @RetainedEarningsToDate=@FYEFromDate
				SELECT @RetainedEarningsToDate=@FYEFromDate --Modified By Saketh

				SELECT @ISBroughtForwardFromDate=DATEADD(DAY,1,@FYEFromDate) --i.e. @FYEFromDate+1
				SELECT @ISBroughtForwardToDate=DATEADD(DAY,-1,@FromDate) --i.e. @FromDate-1
				SELECT @ISFromDate=@FromDate
				SELECT @ISToDate=@ToDate
			END --END OF 2.3
			ELSE IF(@FromDate >@FYEFromDate AND @ToDate=@FYEToDate) --2.4
			BEGIN
				SELECT @RetainedEarningsFromDate=@SystemStartDate
				--SELECT @RetainedEarningsToDate=@FYEFromDate
				SELECT @RetainedEarningsToDate=@FYEFromDate --Modified By Saketh

				SELECT @ISBroughtForwardFromDate=DATEADD(DAY,1,@FYEFromDate) --i.e. @FYEFromDate+1
				SELECT @ISBroughtForwardToDate=DATEADD(DAY,-1,@FromDate) --i.e.@FromDate-1
				SELECT @ISFromDate=@FromDate
				SELECT @ISToDate=@ToDate
			END --END OF 2.4
			ELSE IF(@FromDate > @FYEFromDate AND @ToDate > @FYEToDate) --2.5
			BEGIN
				SELECT @RetainedEarningsFromDate=@SystemStartDate
				--SELECT @RetainedEarningsToDate=@FYEToDate
				SELECT @RetainedEarningsToDate=@FYEFromDate --Modified By Saketh---------------------------------

				--SELECT @ISBroughtForwardFromDate='1900-01-01'
				SELECT @ISBroughtForwardFromDate=DATEADD(DAY,1,@FYEFromDate)--Modified By Saketh

				 SELECT @ISBroughtForwardToDate=DATEADD(DAY,-1,@FromDate) --Modified By Saketh
				--SELECT @ISFromDate=DATEADD(DAY,1,@FYEToDate) --i.e. @FYEToDate+1
				SELECT @ISFromDate=@FromDate --Modified By Saketh
				SELECT @ISToDate=@ToDate
			END --END OF 2.5

		END -- END OF 2
		/****** ENDING OF @FromDateYear<>@ToDateYear CONDITION IN @DaysBetweENDates<365 CONDITION ********/

		/****** STARTING OF @FromDateYear=@ToDateYear CONDITION IN @DaysBetweENDates<365 CONDITION ********/
		ELSE IF(@FromDateYear=@ToDateYear) --3
		BEGIN
			IF(@FromDate < @FYEFromDate AND @ToDate < @FYEFromDate AND @FromDate<>@ToDate) --3.1
			BEGIN
				SELECT @RetainedEarningsFromDate=@SystemStartDate
				--SELECT @RetainedEarningsToDate=@PreviousFYEFromDate
				SELECT @RetainedEarningsToDate=@FYEFromDate --Modified By Saketh


				SELECT @ISBroughtForwardFromDate=DATEADD(DAY,1,@PreviousFYEFromDate) -- i.e. @PreviousFYEFromDate+1
				SELECT @ISBroughtForwardToDate=DATEADD(DAY,-1,@FromDate) --i.e @FromDate-1
				SELECT @ISFromDate=@FromDate
				SELECT @ISToDate=@ToDate
			END -- END OF 3.1
			ELSE IF(@FromDate < @FYEFromDate AND @ToDate = @FYEFromDate) --3.2
			BEGIN
				SELECT @RetainedEarningsFromDate=@SystemStartDate
				--SELECT @RetainedEarningsToDate=@PreviousFYEFromDate
				SELECT @RetainedEarningsToDate=@FYEFromDate --Modified By Saketh

				SELECT @ISBroughtForwardFromDate=DATEADD(DAY,1,@PreviousFYEFromDate) --i.e. @PreviousFYEFromDate+1
				SELECT @ISBroughtForwardToDate=DATEADD(DAY,-1,@FromDate) --i.e @FromDate-1
				SELECT @ISFromDate=@FromDate
				SELECT @ISToDate=@ToDate
			END --END OF 3.2
			ELSE IF(@FromDate < @FYEFromDate AND @ToDate > @FYEFromDate) -- 3.3
			BEGIN
				SELECT @RetainedEarningsFromDate=@SystemStartDate
				--SELECT @RetainedEarningsToDate=@FYEFromDate
				--SELECT @RetainedEarningsToDate=@FYEFromDate --Modified By Saketh
				SELECT @RetainedEarningsToDate=@PreviousFYEFromDate--------------------------Modified By Saketh For 31-Jan------------------------------

				--SELECT @ISBroughtForwardFromDate='1900-01-01'
				SELECT @ISBroughtForwardFromDate=DATEADD(DAY,1,@PreviousFYEFromDate)--Modified By Saketh
				 SELECT @ISBroughtForwardToDate=DATEADD(DAY,-1,@FromDate) --Modified By Saketh
				--SELECT @ISFromDate=DATEADD(DAY,1,@FYEFromDate) --i.e.@FYEFromDate+1
				SELECT @ISFromDate=@FromDate --Modified By Saketh
				SELECT @ISToDate=@ToDate
			END --END OF 3.3
			ELSE IF(@FromDate = @FYEFromDate AND @ToDate > @FYEFromDate) --3.4
			BEGIN
				SELECT @RetainedEarningsFromDate=@SystemStartDate
				--SELECT @RetainedEarningsToDate=@FYEFromDate
				SELECT @RetainedEarningsToDate=@FYEFromDate --Modified By Saketh

				--SELECT @ISBroughtForwardFromDate='1900-01-01'
				SELECT @ISBroughtForwardFromDate=DATEADD(DAY,1,@PreviousFYEFromDate)--Modified By Saketh
				 SELECT @ISBroughtForwardToDate=DATEADD(DAY,-1,@FromDate) --Modified By Saketh
				--SELECT @ISFromDate=DATEADD(DAY,1,@FYEFromDate) --i.e. @FYEFromDate+1
				SELECT @ISFromDate=@FromDate --Modified By Saketh
				SELECT @ISToDate=@ToDate
			END -- END OF 3.4
			ELSE IF(@FromDate = @FYEFromDate AND @ToDate=@FYEFromDate AND @FromDate=@ToDate) --3.5
			BEGIN
				SELECT @RetainedEarningsFromDate=@SystemStartDate
				--SELECT @RetainedEarningsToDate=@PreviousFYEFromDate
				SELECT @RetainedEarningsToDate=@FYEFromDate --Modified By Saketh


				SELECT @ISBroughtForwardFromDate=DATEADD(DAY,1,@PreviousFYEFromDate) --i.e. @PreviousFYEFromDate+1
				SELECT @ISBroughtForwardToDate=DATEADD(DAY,-1,@FromDate) --i.e. @FromDate-1
				SELECT @ISFromDate=@FromDate
				SELECT @ISToDate=@ToDate
			END --END OF 3.5
			ELSE IF(@FromDate > @FYEFromDate AND @ToDate > @FYEToDate AND @FromDate<>@ToDate) --3.6
			BEGIN
				SELECT @RetainedEarningsFromDate=@SystemStartDate
				--SELECT @RetainedEarningsToDate=@FYEFromDate
				SELECT @RetainedEarningsToDate=@FYEFromDate --Modified By Saketh

				SELECT @ISBroughtForwardFromDate=DATEADD(DAY,1,@FYEFromDate) --i.e. @FYEFromDate+1
				SELECT @ISBroughtForwardToDate=DATEADD(DAY,-1,@FromDate) --i.e. @FromDate-1
				SELECT @ISFromDate=@FromDate
				SELECT @ISToDate=@ToDate
			END --END OF 3.6
			ELSE IF(@FromDate < @FYEFromDate AND @ToDate < @FYEFromDate AND @FromDate=@ToDate) --3.7
			BEGIN
				SELECT @RetainedEarningsFromDate=@SystemStartDate
				--SELECT @RetainedEarningsToDate=@PreviousFYEFromDate
				SELECT @RetainedEarningsToDate=@FYEFromDate --Modified By Saketh


				SELECT @ISBroughtForwardFromDate=DATEADD(DAY,1,@PreviousFYEFromDate) --i.e. @PreviousFYEFromDate+1
				SELECT @ISBroughtForwardToDate=DATEADD(DAY,-1,@FromDate) --i.e. @FromDate-1
				SELECT @ISFromDate=@FromDate
				SELECT @ISToDate=@ToDate
			END -- END OF 3.7
			ELSE IF(@FromDate > @FYEFromDate AND @ToDate > @FYEFromDate AND @FromDate=@ToDate) --3.8
			BEGIN
				SELECT @RetainedEarningsFromDate=@SystemStartDate
				--SELECT @RetainedEarningsToDate=@FYEFromDate
				SELECT @RetainedEarningsToDate=@FYEFromDate --Modified By Saketh

				SELECT @ISBroughtForwardFromDate=DATEADD(DAY,1,@FYEFromDate) --i.e. @FYEFromDate+1
				SELECT @ISBroughtForwardToDate=DATEADD(DAY,-1,@FromDate) --i.e. @FromDate-1
				SELECT @ISFromDate=@FromDate
				SELECT @ISToDate=@ToDate
			END -- END OF 3.8
		END --END OF 3
		/****** ENDING OF @FromDateYear=@ToDateYear CONDITION IN @DaysBetweENDates<365 CONDITION ********/
	END
	/**** ENDifing of @DaysBetweENDates<365 *******/
END

--Select @Bus_Year_END AS Bus_Year_END
--Select @ISFromDate AS ISFromDate
--Select @ISToDate AS ISToDate
--SELECT @ISBroughtForwardFromDate AS ISBroughtForwardFromDate
--SELECT @ISBroughtForwardToDate AS ISBroughtForwardToDate
--SELECT @RetainedEarningsFromDate AS RetainedEarningsFromDate
--SELECT @RetainedEarningsToDate AS RetainedEarningsToDate
--SELECT @BSBroughtForwardFromDate AS BSBroughtForwardFromDate
--SELECT @BSBroughtForwardToDate AS BSBroughtForwardToDate
/****** @Bus_Year_END NOT IN ('31-Dec','01-Jan') ENDING POINT *************/	
                                                  /******* END of Step4 ***************/

                                     /*******Step 5 : Getting SegmentStatus,No Supporting Documents, Bank Reconciliation and MultiCurrencySetting**********/

--Here we declare the table variables to store intermediate and final resultant data

-- @GLReport intermediate table variable is used to store data after getting each coa data by applying cursor code and other conditions
Declare @GLReport Table( [COA Name] NVARCHAR(MAX),RecOrder INT,DocType NVARCHAR(MAX),DocSubType Nvarchar(max),DocumentDescription Nvarchar(max),DocDate datetime2(7),DocNo Nvarchar(max),SystemRefNo NVarchar(max),ServiceCompany Nvarchar(max),EntityName NVarchar(max),BaseDebit money,BaseCredit money,BaseBalance money,ExchangeRate decimal(15,10),BaseCurrency Nvarchar(max),DocCurrency NVarchar(max),DocDebit money,DocCredit money,DocBalance money,SegmentCategory1 Nvarchar(max),SegmentCategory2 NVarchar(max),MCS_Status int,SegmentStatus int,CorrAccount NVarchar(max),[Entity Type] Nvarchar(max),[VENDor Type] Nvarchar(max),PONo NVarchar(max),Nature Nvarchar(max),[CreditTerms(Days)] float,DueDate datetime2,[NSD ISCHECKED] int,[NO SUPPORT DOC] NVarchar(20),ItemCode NVarchar(max),ItemDescription NVarchar(max),Qty float,Unit NVarchar(100),UnitPrice money,[DiscountType] NVarchar(10),Discount float,[BRM ISCHECKED] int,[ALLOWABLE/DISALLOWABLE] NVarchar(max),[Bank Clearing] datetime2,ModeOfReceipt NVarchar(200),ReversalDate datetime2,[Bank Reconcile] NVarchar(20),[Reversal Doc Ref] NVarchar(max),ClearingStatus Nvarchar(100),[Created By] NVarchar(600),[Created On] datetime2,[Modified By] NVarchar(600),[Modified On] datetime2,COA_Parameter NVarchar(max),classOrder BIGINT,DocumentId UNIQUEIDENTIFIER,OrderDate DATETIME2,ServiceCompanyId bigint,AccTypeId BIGINT,ServiceEntity NVarchar(250),[Tax Code] Nvarchar(200))


--@GLReport1 intermediate table variable is used to get data from @GLReport. It is having same columns from @GLReport with same data type.
--And at starting point we declare a column with name 'Number' with identity.
Declare @GLReport1 Table(Number Bigint IDENTITY(1,1), [COA Name] NVARCHAR(MAX),RecOrder INT,DocType NVARCHAR(MAX),DocSubType Nvarchar(max),DocumentDescription Nvarchar(max),DocDate datetime2(7),DocNo Nvarchar(max),SystemRefNo NVarchar(max),ServiceCompany Nvarchar(max),EntityName NVarchar(max),BaseDebit money,BaseCredit money,BaseBalance money,ExchangeRate decimal(15,10),BaseCurrency Nvarchar(max),DocCurrency NVarchar(max),DocDebit money,DocCredit money,DocBalance money,SegmentCategory1 Nvarchar(max),SegmentCategory2 NVarchar(max),MCS_Status int,SegmentStatus int,CorrAccount NVarchar(max),[Entity Type] Nvarchar(max),[VENDor Type] Nvarchar(max),PONo NVarchar(max),Nature Nvarchar(max),[CreditTerms(Days)] float,DueDate datetime2,[NSD ISCHECKED] int,[NO SUPPORT DOC] NVarchar(20),ItemCode NVarchar(max),ItemDescription NVarchar(max),Qty float,Unit NVarchar(100),UnitPrice money,[DiscountType] NVarchar(10),Discount float,[BRM ISCHECKED] int,[ALLOWABLE/DISALLOWABLE] NVarchar(max),[Bank Clearing] datetime2,ModeOfReceipt NVarchar(200),ReversalDate datetime2,[Bank Reconcile] NVarchar(20),[Reversal Doc Ref] NVarchar(max),ClearingStatus Nvarchar(100),[Created By] NVarchar(600),[Created On] datetime2,[Modified By] NVarchar(600),[Modified On] datetime2,COA_Parameter NVarchar(max),classOrder BIGINT,DocumentId UNIQUEIDENTIFIER,OrderDate DATETIME2,ServiceCompanyId bigint,AccTypeId BIGINT,ServiceEntity NVarchar(250),[Tax Code] Nvarchar(200))

Declare @GLReport2 Table(Number Bigint,Number2  Bigint, [COA Name] NVARCHAR(MAX),RecOrder INT,DocType NVARCHAR(MAX),DocSubType Nvarchar(max),DocumentDescription Nvarchar(max),DocDate datetime2(7),DocNo Nvarchar(max),SystemRefNo NVarchar(max),ServiceCompany Nvarchar(max),EntityName NVarchar(max),BaseDebit money,BaseCredit money,BaseBalance money,ExchangeRate decimal(15,10),BaseCurrency Nvarchar(max),DocCurrency NVarchar(max),DocDebit money,DocCredit money,DocBalance money,SegmentCategory1 Nvarchar(max),SegmentCategory2 NVarchar(max),MCS_Status int,SegmentStatus int,CorrAccount NVarchar(max),[Entity Type] Nvarchar(max),[VENDor Type] Nvarchar(max),PONo NVarchar(max),Nature Nvarchar(max),[CreditTerms(Days)] float,DueDate datetime2,[NSD ISCHECKED] int,[NO SUPPORT DOC] NVarchar(20),ItemCode NVarchar(max),ItemDescription NVarchar(max),Qty float,Unit NVarchar(100),UnitPrice money,[DiscountType] NVarchar(10),Discount float,[BRM ISCHECKED] int,[ALLOWABLE/DISALLOWABLE] NVarchar(max),[Bank Clearing] datetime2,ModeOfReceipt NVarchar(200),ReversalDate datetime2,[Bank Reconcile] NVarchar(20),[Reversal Doc Ref] NVarchar(max),ClearingStatus Nvarchar(100),[Created By] NVarchar(600),[Created On] datetime2,[Modified By] NVarchar(600),[Modified On] datetime2,COA_Parameter NVarchar(max),classOrder BIGINT,DocumentId UNIQUEIDENTIFIER,OrderDate DATETIME2,ServiceCompanyId bigint,AccTypeId BIGINT,ServiceEntity NVarchar(250),[Tax Code] Nvarchar(200))

--@GLReport_AfterAdding_SubTotal is store final result.It is having same columns from @GLReport with same data type.
--And finally it is having a column  named AS IsSubTotal which is identify to whether the record is belongs to subtotal or not.
Declare @GLReport_AfterAdding_SubTotal Table(Id BIGINT IDENTITY(1,1), [COA Name] NVARCHAR(MAX),RecOrder INT,DocType NVARCHAR(MAX),DocSubType Nvarchar(max),DocumentDescription Nvarchar(max),DocDate datetime2(7),DocNo Nvarchar(max),SystemRefNo NVarchar(max),ServiceCompany Nvarchar(max),EntityName NVarchar(max),BaseDebit money,BaseCredit money,BaseBalance money,ExchangeRate decimal(15,10),BaseCurrency Nvarchar(max),DocCurrency NVarchar(max),DocDebit money,DocCredit money,DocBalance money,SegmentCategory1 Nvarchar(max),SegmentCategory2 NVarchar(max),MCS_Status int,SegmentStatus int,CorrAccount NVarchar(max),[Entity Type] Nvarchar(max),[VENDor Type] Nvarchar(max),PONo NVarchar(max),Nature Nvarchar(max),[CreditTerms(Days)] float,DueDate datetime2,[NSD ISCHECKED] int,[NO SUPPORT DOC] NVarchar(20),ItemCode NVarchar(max),ItemDescription NVarchar(max),Qty float,Unit NVarchar(100),UnitPrice money,[DiscountType] NVarchar(10),Discount float,[BRM ISCHECKED] int,[ALLOWABLE/DISALLOWABLE] NVarchar(max),[Bank Clearing] datetime2,ModeOfReceipt NVarchar(200),ReversalDate datetime2,[Bank Reconcile] NVarchar(20),[Reversal Doc Ref] NVarchar(max),ClearingStatus Nvarchar(100),[Created By] NVarchar(600),[Created On] datetime2,[Modified By] NVarchar(600),[Modified On] datetime2,COA_Parameter NVarchar(max),classOrder BIGINT,IsSubTotal INt,ISBF int,DocumentId UNIQUEIDENTIFIER,OrderDate DATETIME2,ServiceCompanyId bigint,BaseBalanceReal money,AccTypeId BIGINT,Number BIGINT,ServiceEntity NVarchar(250),[Tax Code] Nvarchar(200))


Declare @SegmentStatus int
Declare @NSdISChecked int
Declare @BRMIsChecked int
SELECT @SegmentStatus=SegmentReporting, @BRMIsChecked=[Bank Reconciliation],@NSdISChecked=[No Supporting Documents]
From
(
	SELECT F.Name, CASE WHEN CF.Status=1 THEN 1  ELSE 0 END Status
	From [common].[companyfeatures] CF (NOLOCK)
	Inner join [Common].[Feature] F (NOLOCK) On F.Id = CF.FeatureId
	Where F.Name in ('SegmentReporting', 'Bank Reconciliation', 'No Supporting Documents') And CF.CompanyId=@CompanyId
) Tab1
PIVOT
(
	Sum(Status) For Name IN (SegmentReporting, [Bank Reconciliation],[No Supporting Documents])  
) Tab2
Declare @MCS_Status int
SELECT @MCS_Status=Status from Bean.MultiCurrencySetting (NOLOCK) where CompanyId=@CompanyId


Declare @COA_IS nvarchar(max)-- Income statement coa
Declare @COA_IS_CODE nvarchar(max)--Income statement coa code
Declare @COA_IS_CORDER INT --Income Statement coa class order
Declare @COA_IS_RECORDER INT --Income Statement AccountType order
DECLARE @COAId BIGINT
Declare @IS_BF_CNT Bigint --used to store no of distinct dates between @ISBroughtForwardFromDate and @ISBroughtForwardToDate WHEN @ISBroughtForwardFromDate<>='1900-01-01' condition becomes true
--Declare @IS_DC_FOR_ZERO table (DocCurrency NVarchar(10))-- used to store distinct Doc currencies WHEN @ISBroughtForwardFromDate='1900-01-01' condition satisfied
Declare @DocCur_Zero NVarchar(10) --used in IS_FOR_ZERO cursor 
Declare @ISCurrency_FOR_NOTZERO NVarchar(10)-- used to store Doc currency which is used in  IS_FOR_NOTZERO_currency cursor
Declare @IS_BFCurrencyCNT bigint --used to store count of no of days between @BFFD and @BFTD for corresponding @Dcocurrency of SELECTed INCOME STATEMENT COA
Declare @IS_BF_OB_CNT_forZero bigint --used to store count of days between @ISFromDate and @ISToDate for Opening balance doc type
Declare @IS_BF_IntCount_forNOTZero bigint --used to calculate distinct date counts between @ISBroughtForwardFromDate and @ISBroughtForwardToDate 
Declare @IS_BF_OBCount_forNOTZero bigint -- used to calculate disctinct date counts between @ISFromDate and @ISToDate for opening balance docsubtype
Declare @IS_DC_Coa table (DocCurrency NVarchar(10),Coa nvarchar(200))


		
	DECLARE @IS_DC_FOR_ZERO TABLE (DocCurrency NVARCHAR(5) ,BaseCurrency NVARCHAR(5) , [COA Name] NVARCHAR(100) , COAId BIGINT , DocDateCount INT ,ServiceEntity Nvarchar(250))
	IF @ISBroughtForwardFromDate='1900-01-01'
		BEGIN
				;WITH DC AS
				(
					SELECT DISTINCT  ISNULL(JD.DocCurrency,'SGD') DocCurrency,JD.BaseCurrency , COA.[COA Name], JD.COAId --, SC.Id AS ServiceCompanyId
					/*,SC.ShortName As ServiceEntity*/
					From        Bean.JournalDetail JD (NOLOCK) 
					INNER JOIN  Bean.Journal J (NOLOCK) ON J.Id=JD.JournalId
					INNER JOIN  @COA_IncomeStatement COA ON COA.COAId=JD.COAId
					--LEFT JOIN   Bean.AccountType AT ON AT.Id=COA.AccountTypeId AND AT.CompanyId=COA.CompanyId
					INNER JOIN  Common.Company AS SC (NOLOCK) ON SC.Id=J.ServiceCompanyId
					WHERE       J.CompanyId=@CompanyId
								--AND  SC.Name IN (SELECT items FROM dbo.SplitToTable(CONVERT(NVARCHAR(MAX), (SELECT @ServiceCompany FOR XML PATH('')), 1),','))
								AND SC.Id in (select items from dbo.SplitToTable(@ServiceCompany,','))
								--AND (Jd.PostingDate BETWEEN @ISFromDate AND @ISToDate)/*Nandu*/
								AND J.DocumentState NOT IN ('Void','Cancelled','Parked','Reset','Recurring','Deleted')
								 And (JD.ClearingStatus NOT IN (@ExcludeItemChar) OR JD.ClearingStatus IS NULL)/*Nandu*/
				),
				DCA AS
				(
					SELECT  DISTINCT ISNULL(JD.DocCurrency,'SGD') AS DocCurrency ,JD.BaseCurrency , DC.[COA Name] AS [COA Name] , JD.PostingDate As DocDate /*Docadte replaced with PostingDate*/ , DC.COAId /*,DC.ServiceEntity*/
					FROM        DC  
					INNER JOIN  Bean.JournalDetail JD (NOLOCK) ON DC.COAId=JD.COAId
					INNER JOIN  Bean.Journal J (NOLOCK) ON J.Id=JD.JournalId
					INNER JOIN  Common.Company AS SC (NOLOCK) ON SC.Id=J.ServiceCompanyId
					WHERE       J.CompanyId = @CompanyId
								--AND  SC.Name IN (SELECT items FROM dbo.SplitToTable(CONVERT(NVARCHAR(MAX), (SELECT @ServiceCompany FOR XML PATH('')), 1),','))
								AND SC.Id in (select items from dbo.SplitToTable(@ServiceCompany,','))
								AND J.DocumentState NOT IN ('Void','Cancelled','Parked','Reset','Recurring','Deleted')
								AND (J.DocType='Journal' AND J.DocsubType IN ('Opening Balance','Opening Bal') )
								 And (JD.ClearingStatus NOT IN (@ExcludeItemChar) OR JD.ClearingStatus IS NULL)/*Nandu*/
								--AND Jd.PostingDate BETWEEN @ISFromDate AND @ISToDate)/*Nandu*/
				),
				DCAA AS 
				(
					SELECT DocCurrency ,BaseCurrency , [COA Name] , COAId , COUNT(DocDate)DocDateCount/*,ServiceEntity*/ FROM DCA
					GROUP BY DocCurrency  ,BaseCurrency, [COA Name] , COAId /*,ServiceEntity*/
					UNION ALL
					SELECT DocCurrency ,BaseCurrency, [COA Name] , COAId ,0 AS DocDateCount FROM DC
				)
				INSERT INTO @IS_DC_FOR_ZERO
				SELECT DocCurrency ,BaseCurrency, [COA Name] , COAId , SUM(DocDateCount),Null As ServiceEntity FROM DCAA
				GROUP BY DocCurrency  ,BaseCurrency, [COA Name] , COAId

				INSERT INTO @GLReport
				SELECT  I.Code+'  '+I.[COA Name] AS [COA Name], I.Recorder AS RecOrder, '' AS DocType,'' AS DocSubType,'Balance B/F' AS DocumentDescription,@FromDate AS DocDate,'' AS DocNo,'' AS SystemRefNo,@ServiceCompany AS  ServiceCompany,''  AS EntityName,NULL AS BaseDebit,NULL AS BaseCredit,I.BaseBalance AS 'BaseBalance',NULL AS ExchangeRate,/*I.BaseCurrency*/'' AS BaseCurrency, /*I.DocCurrency*/''  AS 'DocCurrency', NULL AS DocDebit,NULL AS DocCredit,I.DocBalance AS 'DocBalance'/*IsMultiCurrency,*/,NULL AS SegmentCategory1,NULL AS SegmentCategory2, @MCS_Status,@SegmentStatus AS SegmentStatus,NULL AS CorrAccount,NULL AS [Entity Type],NULL AS [VENDor Type],NULL AS PONo,NULL AS Nature,NULL AS [CreditTerms(Days)],NULL AS DueDate,@NSdISChecked AS [NSD ISCHECKED],NULL AS [NO SUPPORT DOC],NULL AS ItemCode,NULL AS ItemDescription,NULL AS Qty,NULL AS Unit,NULL AS UnitPrice,NULL AS DiscountType,NULL AS Discount,@BRMIsChecked AS [BRM ISCHECKED],NULL AS [ALLOWABLE/DISALLOWABLE],NULL AS [Bank Clearing],NULL AS ModeOfReceipt,NULL AS ReversalDate,NULL AS [Bank Reconcile],NULL AS [Reversal Doc Ref],NULL AS ClearingStatus,NULL AS [Created By],NULL AS [Created On],NULL AS [Modified By],NULL AS [Modified On],I.[COA Name] COA_Parameter,I.ClassOrder AS classOrder,NULL AS DocumentId ,CONVERT(DATETIME,'1900-01-01') AS OrderDate,NULL AS ServiceCompanyId,AccTypeId ,Null As ServiceEntity,Null As [Tax Code]
				FROM 
				(
				SELECT Sum(BaseBalance) As BaseBalance, Sum(DocBalance) As DocBalance, DocCurrency,BaseCurrency, [COA Name], COAId, Code, Recorder, ClassOrder, AccTypeId
				From
				(
					SELECT SUM(COALESCE(JD.BaseDebit ,JD.DocDebit , 0) - COALESCE(JD.BaseCredit,JD.DocCredit , 0))AS BaseBalance
							,SUM(ISNULL(JD.DocDebit , 0) - ISNULL(JD.DocCredit , 0)) AS DocBalance ,
							/*JD.*/ '' As DocCurrency , /*JD.*/'' As BaseCurrency , COA.[COA Name], COA.COAId ,COA.Code , COA.Recorder,COA.ClassOrder,COA.AccTypeId/*,SC.ShortName As ServiceEntity*/
					FROM        Bean.JournalDetail JD (NOLOCK)
					INNER JOIN  Bean.Journal J (NOLOCK) ON J.Id=JD.JournalId
					INNER JOIN  @COA_IncomeStatement COA ON COA.COAId=JD.COAId
					INNER JOIN  Common.Company AS SC (NOLOCK) ON SC.Id=J.ServiceCompanyId
					WHERE J.CompanyId = @CompanyId
							--AND  SC.Name IN(SELECT items FROM dbo.SplitToTable(CONVERT(NVARCHAR(MAX), (SELECT @ServiceCompany FOR XML PATH('')), 1),','))
							AND SC.Id in (select items from dbo.SplitToTable(@ServiceCompany,','))
							AND ISNULL(JD.DocCurrency,'SGD') IN  (SELECT DocCurrency FROM @IS_DC_FOR_ZERO)
							AND J.DocumentState NOT IN ('Void','Cancelled','Parked','Reset','Recurring','Deleted')
							--AND Jd.PostingDate BETWEEN @ISFromDate AND @ISToDate/*Nandu*/
							And Jd.PostingDate BETWEEN @ISBroughtForwardFromDate AND @ISBroughtForwardToDate/*Nandu*/
							 And (JD.ClearingStatus NOT IN (@ExcludeItemChar) OR JD.ClearingStatus IS NULL)/*Nandu*/
							AND J.DocType='Journal' and J.DocsubType IN ('Opening Balance','Opening Bal')
					GROUP BY /*JD.DocCurrency , JD.BaseCurrency ,*/ COA.[COA Name], COA.COAId ,COA.Code , COA.Recorder,COA.ClassOrder,COA.AccTypeId/*,SC.ShortName*/

					UNION ALL
					SELECT 0 AS BaseBalance, 0 AS DocBalance ,/*,JD.DocCurrency , JD.BaseCurrency*/'' As DocCurrency,'' As BaseCurrency , COA.[COA Name], COA.COAId ,COA.Code , COA.Recorder,COA.ClassOrder,COA.AccTypeId/*,SC.ShortName As ServiceEntity*/
					/*FROM Bean.JournalDetail JD 
					INNER JOIN  Bean.Journal J ON J.Id=JD.JournalId*/
					From @COA_IncomeStatement COA 
					/*INNER JOIN  Common.Company AS SC ON SC.Id=J.ServiceCompanyId
					WHERE J.CompanyId = @CompanyId
							AND  SC.Name IN(SELECT items FROM dbo.SplitToTable(CONVERT(NVARCHAR(MAX), (SELECT @ServiceCompany FOR XML PATH('')), 1),','))
							--AND ISNULL(JD.DocCurrency,'SGD') IN  (SELECT DocCurrency FROM @IS_DC_FOR_ZERO)
							AND J.DocumentState NOT IN ('Void','Cancelled','Parked','Reset','Recurring')
							--AND Jd.PostingDate BETWEEN @ISBroughtForwardFromDate AND @ISBroughtForwardToDate
							 And (JD.ClearingStatus NOT IN (@ExcludeItemChar) OR JD.ClearingStatus IS NULL)*/
							 Where COA.COAId Not In
							(
							SELECT COA.COAId FROM Bean.JournalDetail JD (NOLOCK) 
							INNER JOIN  Bean.Journal J (NOLOCK) ON J.Id=JD.JournalId
							INNER JOIN  @COA_IncomeStatement COA ON COA.COAId=JD.COAId
							INNER JOIN  Common.Company AS SC (NOLOCK) ON SC.Id=J.ServiceCompanyId
							WHERE J.CompanyId = @CompanyId
									--AND  SC.Name IN(SELECT items FROM dbo.SplitToTable(CONVERT(NVARCHAR(MAX), (SELECT @ServiceCompany FOR XML PATH('')), 1),','))
									AND SC.Id in (select items from dbo.SplitToTable(@ServiceCompany,','))
									--AND ISNULL(JD.DocCurrency,'SGD') IN  (SELECT DocCurrency FROM @IS_DC_FOR_ZERO)
									AND J.DocumentState NOT IN ('Void','Cancelled','Parked','Reset','Recurring','Deleted')
									AND Jd.PostingDate BETWEEN @ISBroughtForwardFromDate AND @ISBroughtForwardToDate
									 And (JD.ClearingStatus NOT IN (@ExcludeItemChar) OR JD.ClearingStatus IS NULL)/*Nandu*/
									/*AND ((Jd.PostingDate BETWEEN @ISBroughtForwardFromDate AND @ISBroughtForwardToDate)
											OR(Jd.PostingDate BETWEEN @ISFromDate AND @ISToDate AND J.DocType = 'Journal' and J.DocsubType IN ('Opening Balance','Opening Bal'))*/
										
							GROUP BY /*JD.DocCurrency , JD.BaseCurrency ,*/ COA.[COA Name], COA.COAId ,COA.Code , COA.Recorder,COA.ClassOrder,COA.AccTypeId /*,SC.ShortName*/
							Union All
							SELECT  COA.COAId
							FROM @IS_DC_FOR_ZERO AS IDZ INNER JOIN @COA_IncomeStatement COA ON COA.COAId=IDZ.COAId WHERE DocDateCount = 0
							)
						
							GROUP BY /*JD.DocCurrency , JD.BaseCurrency ,*/ COA.[COA Name], COA.COAId ,COA.Code , COA.Recorder,COA.ClassOrder,COA.AccTypeId
					UNION ALL

					SELECT  0.0 AS BaseBalance , 0.0 AS DocBalance ,'' As DocCurrency , /*IDZ.BaseCurrency*/'' AS BaseCurrency, COA.[COA Name] , COA.COAId ,COA.Code , COA.Recorder,COA.ClassOrder,COA.AccTypeId/*,ServiceEntity*/
					FROM @IS_DC_FOR_ZERO AS IDZ INNER JOIN @COA_IncomeStatement COA ON COA.COAId=IDZ.COAId WHERE DocDateCount = 0
				) AS TS  Group By DocCurrency,BaseCurrency, [COA Name], COAId, Code, Recorder, ClassOrder, AccTypeId
				) As I
				DELETE @IS_DC_FOR_ZERO;
				
		END
		
	ELSE
		BEGIN
		--SELECT 'ELSE'
				;WITH DC AS
				(
					SELECT DISTINCT  ISNULL(JD.DocCurrency,'SGD') DocCurrency,JD.BaseCurrency , COA.[COA Name], JD.COAId --, SC.Id AS ServiceCompanyId
						,SC.ShortName As ServiceEntity
					From        Bean.JournalDetail JD (NOLOCK) 
					INNER JOIN  Bean.Journal J (NOLOCK) ON J.Id=JD.JournalId
					INNER JOIN  @COA_IncomeStatement COA ON COA.COAId=JD.COAId
					--LEFT JOIN   Bean.AccountType AT ON AT.Id=COA.AccountTypeId AND AT.CompanyId=COA.CompanyId
					INNER JOIN  Common.Company AS SC (NOLOCK) ON SC.Id=J.ServiceCompanyId
					WHERE       J.CompanyId=@CompanyId
								--AND  SC.Name IN (SELECT items FROM dbo.SplitToTable(CONVERT(NVARCHAR(MAX), (SELECT @ServiceCompany FOR XML PATH('')), 1),','))
								AND SC.Id in (select items from dbo.SplitToTable(@ServiceCompany,','))
								--AND ((Jd.PostingDate BETWEEN @ISFromDate AND @ISToDate) /*Nandu*/
								And (Jd.PostingDate BETWEEN @ISBroughtForwardFromDate AND @ISBroughtForwardToDate)--)
								 And (JD.ClearingStatus NOT IN (@ExcludeItemChar) OR JD.ClearingStatus IS NULL)/*Nandu*/
								AND J.DocumentState NOT IN ('Void','Cancelled','Parked','Reset','Recurring','Deleted')
				),
				DCA AS
				(
					SELECT  DISTINCT ISNULL(JD.DocCurrency,'SGD') AS DocCurrency ,JD.BaseCurrency , DC.[COA Name] AS [COA Name] , JD.PostingDate As DocDate /*Docadte replaced with PostingDate*/, DC.COAId ,DC.ServiceEntity
					FROM        DC  
					INNER JOIN  Bean.JournalDetail JD (NOLOCK) ON DC.COAId=JD.COAId
					INNER JOIN  Bean.Journal J (NOLOCK) ON J.Id=JD.JournalId
					INNER JOIN  Common.Company AS SC (NOLOCK) ON SC.Id=J.ServiceCompanyId
					WHERE       J.CompanyId = @CompanyId
								--AND  SC.Name IN (SELECT items FROM dbo.SplitToTable(CONVERT(NVARCHAR(MAX), (SELECT @ServiceCompany FOR XML PATH('')), 1),','))
								AND SC.Id in (select items from dbo.SplitToTable(@ServiceCompany,','))
								AND J.DocumentState NOT IN ('Void','Cancelled','Parked','Reset','Recurring','Deleted')
								AND Jd.PostingDate BETWEEN @ISBroughtForwardFromDate AND @ISBroughtForwardToDate
								 And (JD.ClearingStatus NOT IN (@ExcludeItemChar) OR JD.ClearingStatus IS NULL)/*Nandu*/
								/*AND ((Jd.PostingDate BETWEEN @ISBroughtForwardFromDate AND @ISBroughtForwardToDate)
										OR(Jd.PostingDate BETWEEN @ISFromDate AND @ISToDate AND J.DocType='Journal' and J.DocsubType IN ('Opening Balance','Opening Bal')) ---------------------------*/ /*Nandu*/
									--)
				),
				DCAA AS 
				(
					SELECT DocCurrency ,BaseCurrency , [COA Name] , COAId , COUNT(DocDate)DocDateCount,ServiceEntity FROM DCA
					GROUP BY DocCurrency  ,BaseCurrency, [COA Name] , COAId ,ServiceEntity
					UNION ALL
					SELECT DocCurrency ,BaseCurrency, [COA Name] , COAId ,0 AS DocDateCount,ServiceEntity FROM DC
				)
				INSERT INTO @IS_DC_FOR_ZERO
				SELECT DocCurrency ,BaseCurrency, [COA Name] , COAId , SUM(DocDateCount),ServiceEntity FROM DCAA
				GROUP BY DocCurrency  ,BaseCurrency, [COA Name] , COAId , ServiceEntity

				INSERT INTO @GLReport
				SELECT  I.Code+'  '+I.[COA Name] AS [COA Name],I.Recorder AS Recorder, '' AS DocType,'' AS DocSubType,'Balance B/F' AS DocumentDescription,@FromDate AS DocDate,'' AS DocNo,'' AS SystemRefNo,@ServiceCompany AS  ServiceCompany,''  AS EntityName,null AS BaseDebit,null AS BaseCredit,BaseBalance AS BaseBalance,null AS ExchangeRate, '' As /*I.*/BaseCurrency/*null AS BaseCurrency*/, '' As /*I.*/DocCurrency/*null AS DocCurrency*/, null AS DocDebit,null AS DocCredit,DocBalance AS DocBalance/*IsMultiCurrency,*/,null AS SegmentCategory1,null AS SegmentCategory2, @MCS_Status,@SegmentStatus AS SegmentStatus,null AS CorrAccount,null AS [Entity Type],null AS [VENDor Type],null AS PONo,null AS Nature,null AS [CreditTerms(Days)],null AS DueDate,@NSdISChecked AS [NSD ISCHECKED],null AS [NO SUPPORT DOC],null AS ItemCode,null AS ItemDescription,null AS Qty,null AS Unit,null AS UnitPrice,null AS DiscountType,null AS Discount,@BRMIsChecked AS [BRM ISCHECKED],null AS [ALLOWABLE/DISALLOWABLE],null AS [Bank Clearing],null AS ModeOfReceipt,null AS ReversalDate,NULL AS [Bank Reconcile],null AS [Reversal Doc Ref],null AS ClearingStatus,null AS [Created By],null AS [Created On],null AS [Modified By],null AS [Modified On],@COA_IS COA_Parameter,ClassOrder AS classOrder,NULL AS DocumentId,'1900-01-01' AS OrderDate,NULL As ServiceCompanyId,AccTypeId,NULL aS ServiceEntity,Null As [Tax Code]
				FROM
				(
				Select Sum(BaseBalance) As BaseBalance ,Sum(DocBalance) As DocBalance,DocCurrency,BaseCurrency,[COA Name],COAId,Code,Recorder,ClassOrder,AccTypeId From 
				(
					SELECT SUM(COALESCE(JD.BaseDebit ,JD.DocDebit , 0) - COALESCE(JD.BaseCredit,JD.DocCredit , 0))AS BaseBalance
									,SUM(ISNULL(JD.DocDebit , 0) - ISNULL(JD.DocCredit , 0)) AS DocBalance ,
									/*,JD.DocCurrency , JD.BaseCurrency*/'' As DocCurrency,'' As BaseCurrency , COA.[COA Name], COA.COAId ,COA.Code , COA.Recorder,COA.ClassOrder,COA.AccTypeId/*,SC.ShortName As ServiceEntity*/
					FROM        Bean.JournalDetail JD (NOLOCK)
					INNER JOIN  Bean.Journal J (NOLOCK) ON J.Id=JD.JournalId
					INNER JOIN  @COA_IncomeStatement COA ON COA.COAId=JD.COAId
					INNER JOIN  Common.Company AS SC (NOLOCK) ON SC.Id=J.ServiceCompanyId
					WHERE J.CompanyId = @CompanyId
							--AND  SC.Name IN(SELECT items FROM dbo.SplitToTable(CONVERT(NVARCHAR(MAX), (SELECT @ServiceCompany FOR XML PATH('')), 1),','))
							AND SC.Id in (select items from dbo.SplitToTable(@ServiceCompany,','))
							AND ISNULL(JD.DocCurrency,'SGD') IN  (SELECT DocCurrency FROM @IS_DC_FOR_ZERO)
							AND J.DocumentState NOT IN ('Void','Cancelled','Parked','Reset','Recurring','Deleted')
							AND Jd.PostingDate BETWEEN @ISBroughtForwardFromDate AND @ISBroughtForwardToDate
							 And (JD.ClearingStatus NOT IN (@ExcludeItemChar) OR JD.ClearingStatus IS NULL)/*Nandu*/
							/*AND ((Jd.PostingDate BETWEEN @ISBroughtForwardFromDate AND @ISBroughtForwardToDate)
									OR(Jd.PostingDate BETWEEN @ISFromDate AND @ISToDate AND J.DocType = 'Journal' and J.DocsubType IN ('Opening Balance','Opening Bal'))*/
								
					GROUP BY /*JD.DocCurrency , JD.BaseCurrency ,*/ COA.[COA Name], COA.COAId ,COA.Code , COA.Recorder,COA.ClassOrder,COA.AccTypeId /*,SC.ShortName*/

					UNION ALL

					SELECT 0 AS BaseBalance, 0 AS DocBalance ,/*,JD.DocCurrency , JD.BaseCurrency*/'' As DocCurrency,'' As BaseCurrency , COA.[COA Name], COA.COAId ,COA.Code , COA.Recorder,COA.ClassOrder,COA.AccTypeId/*,SC.ShortName As ServiceEntity*/
					/*FROM Bean.JournalDetail JD 
					INNER JOIN  Bean.Journal J ON J.Id=JD.JournalId*/
					From @COA_IncomeStatement COA --ON COA.COAId=JD.COAId
					/*INNER JOIN  Common.Company AS SC ON SC.Id=J.ServiceCompanyId
					WHERE J.CompanyId = @CompanyId
							AND  SC.Name IN(SELECT items FROM dbo.SplitToTable(CONVERT(NVARCHAR(MAX), (SELECT @ServiceCompany FOR XML PATH('')), 1),','))
							--AND ISNULL(JD.DocCurrency,'SGD') IN  (SELECT DocCurrency FROM @IS_DC_FOR_ZERO)
							AND J.DocumentState NOT IN ('Void','Cancelled','Parked','Reset','Recurring')
							--AND Jd.PostingDate BETWEEN @ISBroughtForwardFromDate AND @ISBroughtForwardToDate
							 And (JD.ClearingStatus NOT IN (@ExcludeItemChar) OR JD.ClearingStatus IS NULL)*/
							 Where COA.COAId Not In
							(
							SELECT COA.COAId FROM Bean.JournalDetail JD (NOLOCK)
							INNER JOIN  Bean.Journal J (NOLOCK) ON J.Id=JD.JournalId
							INNER JOIN  @COA_IncomeStatement COA ON COA.COAId=JD.COAId
							INNER JOIN  Common.Company AS SC (NOLOCK) ON SC.Id=J.ServiceCompanyId
							WHERE J.CompanyId = @CompanyId
									--AND  SC.Name IN(SELECT items FROM dbo.SplitToTable(CONVERT(NVARCHAR(MAX), (SELECT @ServiceCompany FOR XML PATH('')), 1),','))
									AND SC.Id in (select items from dbo.SplitToTable(@ServiceCompany,','))
									--AND ISNULL(JD.DocCurrency,'SGD') IN  (SELECT DocCurrency FROM @IS_DC_FOR_ZERO)
									AND J.DocumentState NOT IN ('Void','Cancelled','Parked','Reset','Recurring','Deleted')
									AND Jd.PostingDate BETWEEN @ISBroughtForwardFromDate AND @ISBroughtForwardToDate
									 And (JD.ClearingStatus NOT IN (@ExcludeItemChar) OR JD.ClearingStatus IS NULL)/*Nandu*/
									/*AND ((Jd.PostingDate BETWEEN @ISBroughtForwardFromDate AND @ISBroughtForwardToDate)
											OR(Jd.PostingDate BETWEEN @ISFromDate AND @ISToDate AND J.DocType = 'Journal' and J.DocsubType IN ('Opening Balance','Opening Bal'))*/
										
							GROUP BY /*JD.DocCurrency , JD.BaseCurrency ,*/ COA.[COA Name], COA.COAId ,COA.Code , COA.Recorder,COA.ClassOrder,COA.AccTypeId /*,SC.ShortName*/
							Union All
							SELECT COA.COAId
							FROM @IS_DC_FOR_ZERO AS IDZ INNER JOIN @COA_IncomeStatement COA ON COA.COAId=IDZ.COAId WHERE DocDateCount = 0
							)
							GROUP BY /*JD.DocCurrency , JD.BaseCurrency ,*/ COA.[COA Name], COA.COAId ,COA.Code , COA.Recorder,COA.ClassOrder,COA.AccTypeId
					
					UNION ALL

					SELECT  0.0 AS BaseBalance , 0.0 AS DocBalance ,'' As DocCurrency , /*IDZ.BaseCurrency*/ '' AS BaseCurrency, COA.[COA Name] , COA.COAId ,COA.Code , COA.Recorder,COA.ClassOrder,COA.AccTypeId/*,null As ServiceEntity*/
					FROM @IS_DC_FOR_ZERO AS IDZ INNER JOIN @COA_IncomeStatement COA ON COA.COAId=IDZ.COAId WHERE DocDateCount = 0
				) As TS Group By DocCurrency,BaseCurrency,[COA Name],COAId,Code,Recorder,ClassOrder,AccTypeId
				) AS I
		END
	 INSERT INTO @GLReport
	 SELECT [COA Name],RecOrder,DocType,DocSubType,DocumentDescription,DocDate,DocNo,SystemRefNo,ServiceCompany,EntityName,BaseDebit,BaseCredit,BaseBalance,ExchangeRate,BaseCurrency,DocCurrency,DocDebit,DocCredit,DocBalance,/*IsMultiCurrency,*/SegmentCategory1,SegmentCategory2,MCS_Status,Status,  /*FCA.CorrAccount*/  CorrAccount,[Entity Type],[VENDor Type],PONo,Nature,[CreditTerms(Days)],DueDate,[NSD ISCHECKED],[NO SUPPORT DOC],ItemCode,ItemDescription,Qty,Unit,UnitPrice,DiscountType,Discount,[BRM ISCHECKED],[ALLOWABLE/DISALLOWABLE],[Bank Clearing],ModeOfReceipt,ReversalDate,[Bank Reconcile],[Reversal Doc Ref],ClearingStatus,[Created By],[Created On],[Modified By],[Modified On],COA_Parameter,classOrder,DocumentId,DocDate AS OrderDate,ServiceCompanyId ,AccountTypeId,ServiceEntity,[Tax Code]

	 FROM
	 (
		 SELECT      COA.Code+'  '+ COA.Name as 'COA Name', JD.DocType,JD.DocSubType,
		             --J.DocumentDescription as DocumentDescription,
					 --CASE WHEN J.DocType<>'Journal' THEN J.DocumentDescription
					 --     WHEN J.DocType='Journal'
						--  THEN
						--    CASE WHEN J.DocSubType IN ('Opening Balance','Opening Bal')
						--	     THEN 
						--		   CASE WHEN Jd.AccountDescription is null THEN J.DocumentDescription ELSE Jd.AccountDescription  END
						--		 WHEN J.DocSubType NOT IN ('Opening Balance','Opening Bal') THEN J.DocumentDescription
						--	END
					 -- END 
					 Jd.AccountDescription as DocumentDescription,  
					 JD.PostingDate As DocDate /*J.DocDate Replace With PostingDate*/,CASE WHEN J.DocType='Journal' and J.DocSubType IN ('Opening Balance','Opening Bal') THEN /* JD.SystemRefNo ELSE*/ J.DocNo Else J.DocNo/*Nandu*/ END as DocNo,j.TransferRefNo As SystemRefNo,/*J.ActualSysRefNo SystemRefNo,*/ SC.Name ServiceCompany,CASE WHEN J.DocType<>'Journal' THEN E.Name WHEN J.DocType='Journal' THEN EJ.Name END as EntityName,CASE WHEN JD.BaseCurrency=JD.DocCurrency and JD.BaseDebit is null THEN JD.DocDebit ELSE JD.BaseDebit END BaseDebit,CASE WHEN JD.BaseCurrency=JD.DocCurrency and JD.BaseCredit is null THEN JD.DocCredit ELSE JD.BaseCredit END BaseCredit,ISNULL((ISNULL(CASE WHEN JD.BaseCurrency=JD.DocCurrency and JD.BaseDebit is null THEN JD.DocDebit ELSE  JD.BaseDebit END ,0)-ISNULL(CASE WHEN JD.DocCurrency=JD.BaseCurrency and JD.BaseCredit is null THEN JD.DocCredit ELSE JD.BaseCredit END,0)),0) as BaseBalance ,jd.ExchangeRate,jd.BaseCurrency,ISNULL(JD.DocCurrency,'SGD') DocCurrency,JD.DocDebit,JD.DocCredit,ISNULL((ISNULL(JD.DocDebit,0)-ISNULL(JD.DocCredit,0)),0) as DocBalance,/*IsMultiCurrency,*/jd.SegmentCategory1,JD.SegmentCategory2,CASE WHEN MCS.Status=1 THEN 1 ELSE 0 END MCS_Status, NULL AS Status,/*COA.Name as [Corr Account],*/
					 JD.JournalId,
					 --CASE WHEN J.DocType<>'Journal'and E.IsCustomer=1 THEN 'Customer' WHEN E.IsVENDor=1 THEN 'VENDor' END as [Entity Type],E.VENDorType as [VENDor Type],
					 CASE WHEN J.DocType<>'Journal'
					      THEN
				             CASE WHEN E.IsCustomer=1 THEN 'Customer' WHEN E.IsVENDor=1 THEN 'VENDor' END 
			              WHEN J.DocType='Journal'
                          THEN
                             CASE WHEN EJ.IsCustomer=1 THEN 'Customer' WHEN EJ.IsVENDor=1 THEN 'VENDor' END 
			              END 
			          as [Entity Type],
                     CASE WHEN J.DocType<>'Journal' THEN E.VENDorType 
			              WHEN J.DocType='Journal' THEN EJ.VENDorType 
			         END
			         as [VENDor Type],
					 J.PONo,JD.Nature,TP.TOPValue as [CreditTerms(Days)],J.DueDate,NSD.[NSD ISCHECKED],CASE WHEN J.IsNoSupportingDocs=0 THEN 'NO' WHEN J.IsNoSupportingDocs=1 THEN 'YES' END AS [NO SUPPORT DOC],JD.ItemCode,JD.ItemDescription,JD.Qty,JD.Unit,JD.UnitPrice,JD.DiscountType,JD.Discount,[BRM ISCHECKED],CASE WHEN JD.AllowDisAllow=0 THEN 'NO' WHEN JD.AllowDisAllow=1 THEN 'YES' END AS [ALLOWABLE/DISALLOWABLE],JD.ClearingDate AS [Bank Clearing],J.ModeOfReceipt,J.ReversalDate,
					 CASE WHEN J.IsBankReconcile=0 THEN 'NO' WHEN J.IsBankReconcile=1 THEN 'YES' END as [Bank Reconcile],CASE WHEN J.IsAutoReversalJournal in (1) THEN J.SystemReferenceNo  END as [Reversal Doc Ref],JD.ClearingStatus,J.UserCreated as [Created By],J.CreatedDate as [Created On],J.ModifiedBy as [Modified By],J.ModifiedDate as [Modified On],COA.Name as COA_Parameter,
					 CASE WHEN COA.Class in('Assets','Asset') THEN 1 
									WHEN COA.Class='Liabilities' THEN 2
									WHEN COA.Class='Equity' THEN 3
									WHEN COA.Class='Income' THEN 4
									WHEN COA.Class='Expenses' THEN 5 END as classOrder,AT.RecOrder,CCOA.Name as CorrAccount,
									Case When JD.DocType='Credit Note' And JD.DocSubType='Application' Then CNA.InvoiceId 
										When JD.DocType='Credit Memo' And JD.DocSubType='Application' Then CMA.CreditMemoId 
										When JD.DocType='Debt Provision' And JD.DocSubType='Allocation' Then DDA.InvoiceId Else JD.DocumentId End As DocumentId /*JD.DocumentId*/,JD.ServiceCompanyId,COA.AccountTypeId,SC.ShortName As ServiceEntity,TC.Code As [Tax Code]
		 From Bean.JournalDetail JD (NOLOCK) 
		 Inner Join  Bean.Journal J (NOLOCK) on J.Id=JD.JournalId
		 Left Join Bean.TaxCode As TC (NOLOCK) On TC.Id=JD.TaxId
		 Inner Join  Bean.ChartOfAccount COA (NOLOCK) on COA.Id=JD.COAId
		 Left  Join  Bean.ChartOfAccount CCOA (NOLOCK) on CCOA.Id=JD.CorrAccountId
		 Left  Join  Bean.AccountType AT (NOLOCK) ON AT.Id=COA.AccountTypeId AND AT.CompanyId=COA.CompanyId 
		 Inner Join  Common.Company as SC (NOLOCK) on SC.Id=J.ServiceCompanyId
		 Left  join  Bean.Entity as E (NOLOCK) on E.Id=J.EntityId and J.DocType<>'Journal'
		 Left  Join  Bean.Entity as EJ (NOLOCK) on EJ.Id=JD.EntityId and J.DocType='Journal' 
		 --Left join   Bean.SegmentMaster as SM1 on SM1.Id=JD.SegmentMasterid1 and J.CompanyId=SM1.CompanyId
		 --Left join   Bean.SegmentMaster as SM2 on SM2.Id=JD.SegmentMasterid1 and J.CompanyId=SM2.CompanyId
		 Left join   Bean.MultiCurrencySetting MCS (NOLOCK) on MCS.companyId=J.CompanyId
		 --Left Join 
		 -- (
			--  SELECT distinct CompanyId,status
			--  from
			--  (
			--	SELECT CompanyId, Status from bean.SegmentMaster where CompanyId=@CompanyId
			--  ) as st1
		 -- ) SM3 on SM3.companyid=J.CompanyId 
		 Left join   Common.TermsOfPayment as TP (NOLOCK) on TP.Id=JD.CreditTermsId
		 LEFT JOIN
		  (
			 SELECT   CompanyId,ISNULL(IsChecked,0) AS [NSD ISCHECKED]  
			 From     Common.CompanyFeatures (NOLOCK) where CompanyId=@CompanyId and FeatureId=(SELECT distinct id from Common.Feature (NOLOCK) where Name='No Supporting Documents') 
		  ) AS NSD ON NSD.CompanyId=J.CompanyId
		 LEFT JOIN
		  (
			 SELECT  CompanyId,ISNULL(IsChecked,0) AS [BRM ISCHECKED] 
			 From    Common.CompanyFeatures (NOLOCK) where CompanyId=@CompanyId and FeatureId=(SELECT distinct id from Common.Feature (NOLOCK) where Name='Bank Reconciliation') 
		   ) AS BRM ON BRM.CompanyId=J.CompanyId
		Left Join Bean.CreditNoteApplication As CNA (NOLOCK) On CNA.Id=JD.DocumentId
		Left Join Bean.CreditMemoApplication As CMA (NOLOCK) On CMA.Id=JD.DocumentId
		Left Join Bean.DoubtfulDebtAllocation As DDA (NOLOCK) On DDA.Id=JD.DocumentId
		 WHERE COA.CompanyId=@CompanyId  and COA.ModuleType='Bean' --and JD.IsTax<>1
		 And (JD.ClearingStatus NOT IN (@ExcludeItemChar) OR JD.ClearingStatus IS NULL)/*Nandu*/
		 AND  COA.Name in(SELECT [COA Name] from @COA_IncomeStatement)
		-- AND  SC.Name in(SELECT items from dbo.SplitToTable(CONVERT(nvarchar(max), (SELECT @ServiceCompany FOR XML PATH('')), 1),','))
		 AND SC.Id in (select items from dbo.SplitToTable(@ServiceCompany,','))
		 AND  JD.DocType IN (SELECT items from dbo.SplitToTable(CONVERT(nvarchar(max), (SELECT @DocType FOR XML PATH('')), 1),','))
		 AND Jd.PostingDate BETWEEN @ISFromDate AND @ISToDate AND J.DocumentState NOT IN ('Void','Cancelled','Parked','Reset','Recurring','Deleted') -- And J.DocumentState<>'Void'
		 AND ((JD.DocType <> 'Journal' AND JD.DocumentDetailId = '00000000-0000-0000-0000-000000000000') 
						OR (JD.DocumentDetailId <> '00000000-0000-0000-0000-000000000000' AND JD.DocType<>'Journal')
						OR (JD.DocType='Journal' AND JD.DocSubType  IN ('Opening Balance','Opening Bal','General','Reversal','Revaluation','Reval','Recurring','Claim')) /* Not In Replaced With IN By Nandu*/
			 )
	 ) AS IST

		 /********* Step 6.2.1.1 : Getting records except coresponding account column ************************************/
	 /*********ENDing of Step 6.2.3.1 *************************/
      /******  Start of step 7: Data for Balance Sheet coa's **********/

		DECLARE @COA_RE NVARCHAR(MAX)
				,@COA_RE_CODE NVARCHAR(MAX)
				,@COA_RE_CORDER INT
				,@COA_RE_RECORDER INT
				,@COA_RE_ACCTYPEID BIGINT

		SELECT @COA_RE = [COA Name] ,@COA_RE_CODE = Code , @COA_RE_CORDER = ClassOrder , @COA_RE_RECORDER = Recorder,@COA_RE_ACCTYPEID=AccTypeId   FROM #COA_BalanceSheet
		WHERE [COA Name] = 'Retained earnings'

		
	
		IF EXISTS(SELECT 1 FROM #COA_BalanceSheet WHERE [COA Name] = 'Retained earnings')
		BEGIN
		INSERT INTO @GLReport
			SELECT  @COA_RE_CODE+'  '+@COA_RE AS [COA Name],@COA_RE_RECORDER AS RecOrder, '' AS DocType,'' AS DocSubType,'Balance B/F' AS DocumentDescription,/*DATEADD(DAY,1,@RetainedEarningsToDate)*/ @FromDate AS DocDate,'' AS DocNo,'' AS SystemRefNo,@ServiceCompany AS  ServiceCompany,''  AS EntityName,null AS BaseDebit,null AS BaseCredit,BaseValue AS BaseBalance,null AS ExchangeRate,/*BaseCurrency*/ '' AS BaseCurrency, /*DocCurrency*/ '' AS DocCurrency, null AS DocDebit,null AS DocCredit,DocValue AS DocBalance/*IsMultiCurrency,*/,null AS SegmentCategory1,null AS SegmentCategory2, @MCS_Status,@SegmentStatus AS SegmentStatus,null AS CorrAccount,null AS [Entity Type],null AS [VENDor Type],null AS PONo,null AS Nature,null AS [CreditTerms(Days)],null AS DueDate,@NSdISChecked AS [NSD ISCHECKED],null AS [NO SUPPORT DOC],null AS ItemCode,null AS ItemDescription,null AS Qty,null AS Unit,null AS UnitPrice,null AS DiscountType,null AS Discount,@BRMIsChecked AS [BRM ISCHECKED],null AS [ALLOWABLE/DISALLOWABLE],null AS [Bank Clearing],null AS ModeOfReceipt,null AS ReversalDate,NULL AS [Bank Reconcile],null AS [Reversal Doc Ref],null AS ClearingStatus,null AS [Created By],null AS [Created On],null AS [Modified By],null AS [Modified On],@COA_RE COA_Parameter,3 AS classOrder, NULL AS  DocumentId,CONVERT(DATETIME,'1900-01-01') AS OrderDate,NULL AS ServiceCompanyId ,@COA_RE_ACCTYPEID,NULL As ServiceEntity,Null As [Tax code]
			FROM
			(
				Select BaseCurrency,DocCurrency,Sum(BaseValue) As BaseValue,Sum(DocValue) As DocValue From 

				(
				/*SELECT --C.Name AS 'Service Company',
						 JD.BaseCurrency,ISNULL(JD.DocCurrency, 'SGD') AS DocCurrency 
					   ,SUM(CASE COA.Class WHEN 'Income'
							THEN CASE WHEN JD.DocCurrency = JD.BaseCurrency
							THEN ISNULL(JD.DocCredit, 0) - ISNULL(JD.DocDebit, 0)
							ELSE ISNULL(JD.BaseCredit, 0) - ISNULL(JD.BaseDebit, 0) END ELSE 0.00 END--) --AS [Base Income] = [All Base Credit] - [All Base Debit] WHEN class is income
							+(CASE COA.Class WHEN 'Expenses' 
								  THEN CASE WHEN JD.DocCurrency = JD.BaseCurrency 
								  THEN ISNULL(JD.DocCredit, 0) - ISNULL(JD.DocDebit, 0)
								  ELSE ISNULL(JD.BaseCredit, 0) - ISNULL(JD.BaseDebit, 0) END ELSE 0.00 END)  --AS [Base Expenses] = [All Base Credit] - [All Base Debit] WHEN Class is Expenses 
								  +(CASE WHEN JD.DocSubType IN ('Opening Balance','Opening Bal') 
										THEN CASE WHEN JD.BaseCurrency = JD.DocCurrency 
										THEN ISNULL(JD.DocDebit, 0) - ISNULL(JD.DocCredit, 0)
										ELSE ISNULL(JD.BaseDebit, 0) - ISNULL(JD.BaseCredit, 0) END ELSE 0.0 END)) AS BaseValue, --[Base Balanace] = [All Base Debit] - [All Base Credit] WHEN SubType is	'Opening  	Balance' & [Base Net Profit] = [Base Income] + [Base Expenses] & [BaseValue] = [Base Net Profit] + [Base Balanace]
					   SUM(CASE COA.Class WHEN 'Income'
							THEN ISNULL(JD.DocCredit, 0) - ISNULL(JD.DocDebit, 0) ELSE 0.00 END
							+(CASE COA.Class WHEN 'Expenses'
								  THEN ISNULL(JD.DocCredit, 0) - ISNULL(JD.DocDebit, 0) ELSE 0.00 END)
								  +(CASE WHEN JD.DocSubType IN ('Opening Balance','Opening Bal')
										THEN ISNULL(JD.DocDebit, 0) - ISNULL(JD.DocCredit, 0) ELSE 0.0 END)) AS DocValue /*,C.ShortName As ServiceEntity */--  aBOVE bASE vALUES cOMMENTS rEPLACE bASE wITH dOC 
				FROM   Bean.ChartOfAccount COA
				LEFT  JOIN  Bean.AccountType AT ON AT.Id=COA.AccountTypeId AND AT.CompanyId=COA.CompanyId 
				JOIN   Bean.JournalDetail AS JD ON JD.COAId=COA.Id
				JOIN   Common.Company AS C ON C.Id=JD.ServiceCompanyId
				JOIN   Bean.Journal J ON J.Id=JD.JournalId
				WHERE  COA.Companyid=@CompanyId
						AND Jd.PostingDate BETWEEN @RetainedEarningsFROMDate and @RetainedEarningsToDate
						AND J.DocumentState NOT IN ('Void','Cancelled','Parked','Reset','Recurring') 
						AND ( COA.Class in ('Income','Expenses') OR JD.DocSubType IN ('Opening Balance','Opening Bal') )
						AND  C.Name in(SELECT items FROM dbo.SplitToTable(CONVERT(NVARCHAR(MAX), (SELECT @ServiceCompany FOR XML PATH('')), 1),','))	
				GROUP BY JD.BaseCurrency ,ISNULL(JD.DocCurrency,'SGD')--,C.Name/*,C.ShortName*/*/--Removed By Saketh

				Select '' As BaseCurrency,'' As DocCurrency,IsNULL(SUM(BaseDebit),0) - ISNULL(Sum(BaseCredit),0) AS BaseValue,ISNULL(Sum(DocDebit),0)-ISNULL(Sum(DocCredit),0) AS DocValue from (

				Select  '' As /*JD.*/BaseCurrency,/*ISNULL(JD.DocCurrency,'SGD')*/ '' As DocCurrency,case when JD.BaseCurrency=JD.DocCurrency and JD.BaseDebit is null then JD.DocDebit else JD.BaseDebit end  BaseDebit,
        Case when JD.BaseCurrency=JD.DocCurrency and JD.BaseCredit is null then JD.DocCredit else JD.BaseCredit end  BaseCredit,JD.DocDebit,JD.DocCredit
						FROM   Bean.ChartOfAccount COA (NOLOCK)
				LEFT  JOIN  Bean.AccountType AT (NOLOCK) ON AT.Id=COA.AccountTypeId AND AT.CompanyId=COA.CompanyId 
				JOIN   Bean.JournalDetail AS JD (NOLOCK) ON JD.COAId=COA.Id
				JOIN   Common.Company AS C (NOLOCK) ON C.Id=JD.ServiceCompanyId
				JOIN   Bean.Journal J (NOLOCK) ON J.Id=JD.JournalId
				WHERE  COA.Companyid=@CompanyId
						AND J.PostingDate BETWEEN @RetainedEarningsFROMDate and @RetainedEarningsToDate--'2017-11-16' AND '2018-12-31'
						AND J.DocumentState NOT IN ('Void','Cancelled','Parked','Reset','Recurring','Deleted') 
						AND ( COA.Class in ('Income','Expenses')) --OR JD.DocSubType IN ('Opening Balance','Opening Bal') )
						--AND  C.Name in(SELECT items FROM dbo.SplitToTable(CONVERT(NVARCHAR(MAX), (SELECT @ServiceCompany FOR XML PATH('')), 1),','))
						AND C.Id in (select items from dbo.SplitToTable(@ServiceCompany,','))	
						And (Jd.ClearingStatus NOT IN (@ExcludeItemChar) OR Jd.ClearingStatus IS NULL) /*Nandu*/
				) AS A
				--Group By --BaseCurrency,DocCurrency /*Modified By Saketh*/

				Union All

				Select '' As /*Jd.*/BaseCurrency,/*ISNULL(JD.DocCurrency, 'SGD')*/ '' AS DocCurrency,
						SUM(Isnull(JD.BaseDebit,0))-SUM(Isnull(JD.BaseCredit,0)) As BaseValue 
						,Sum(Isnull(JD.DocDebit,0))-SUM(Isnull(JD.DocCredit,0)) As DocValue 
				From Bean.Journal J (NOLOCK)
				Inner join Bean.JournalDetail JD (NOLOCK) ON JD.JournalId=J.Id
				Inner Join Bean.ChartOfAccount C (NOLOCK) On C.Id=JD.COAId
				JOIN   Common.Company AS SC (NOLOCK) ON SC.Id=JD.ServiceCompanyId
				Where J.CompanyId=@CompanyId AND ((J.PostingDate BETWEEN @BSBroughtForwardFromDate AND @BSBroughtForwardToDate) And 
								 (J.DocType='Journal' AND J.DocsubType IN ('Opening Balance','Opening Bal','General'))) --->> Added General by Ali on 06 May 24
								 AND SC.Id in (select items from dbo.SplitToTable(@ServiceCompany,','))
								 AND J.DocumentState NOT IN ('Void') --->> Condition Added by Ali on 06 May 24
								 --And Jd.PostingDate BETWEEN @BSFromDate AND @BSToDate)) 
								  And C.Name='Retained earnings' 
								  And (Jd.ClearingStatus NOT IN (@ExcludeItemChar) OR Jd.ClearingStatus IS NULL) /*Nandu*/
				Group by J.PostingDate--,Jd.BaseCurrency,JD.DocCurrency


				) As A Group by BaseCurrency,DocCurrency


			) AS RE

		END

		--End

		--Select * From @GLReport
		
		DECLARE @BSheetDoccurrency TABLE (DocCurrency NVARCHAR(5) , [COA Name] NVARCHAR(100) , COAId BIGINT , DocDateCount INT)

       /***START Getting distinct doccurrencies AND UNIQUE DOCDATE COUNT FOR CHART OF ACCOUNT FOR COMPANY ***/
			;WITH DC AS
		(
			SELECT		DISTINCT  ISNULL(JD.DocCurrency,'SGD') DocCurrency , COA.[COA Name], JD.COAId --, SC.Id AS ServiceCompanyId
			From        Bean.JournalDetail JD (NOLOCK) 
			INNER JOIN  Bean.Journal J (NOLOCK) ON J.Id=JD.JournalId
			INNER JOIN  #COA_BalanceSheet COA ON COA.COAId=JD.COAId
			--LEFT JOIN   Bean.AccountType AT ON AT.Id=COA.AccountTypeId AND AT.CompanyId=COA.CompanyId
			INNER JOIN  Common.Company AS SC (NOLOCK) ON SC.Id=J.ServiceCompanyId
			WHERE       J.CompanyId=@CompanyId
						--AND  COA.Name IN (SELECT [COA Name] FROM #COA_BalanceSheet WHERE [COA Name] <> 'Retained earnings')
						AND COA.[COA Name] <> 'Retained earnings'
						--AND  SC.Name IN (SELECT items FROM dbo.SplitToTable(CONVERT(NVARCHAR(MAX), (SELECT @ServiceCompany FOR XML PATH('')), 1),','))
						AND SC.Id in (select items from dbo.SplitToTable(@ServiceCompany,','))
						AND ((Jd.PostingDate BETWEEN @BSFromDate AND @BSToDate) OR (Jd.PostingDate BETWEEN @BSBroughtForwardFromDate AND @BSBroughtForwardToDate))
						--AND COA.ModuleType='Bean'
						AND J.DocumentState NOT IN ('Void','Cancelled','Parked','Reset','Recurring','Deleted')
						And (Jd.ClearingStatus NOT IN (@ExcludeItemChar) OR Jd.ClearingStatus IS NULL) /*Nandu*/
		),
		DCA AS
		(
			SELECT  DISTINCT ISNULL(JD.DocCurrency,'SGD') AS DocCurrency , DC.[COA Name] AS [COA Name] , JD.PostingDate As DocDate , DC.COAId /*Docadte replaced with PostingDate*/
			FROM        DC  
			INNER JOIN  Bean.JournalDetail JD (NOLOCK) ON DC.COAId=JD.COAId
			INNER JOIN  Bean.Journal J (NOLOCK) ON J.Id=JD.JournalId
			INNER JOIN  Common.Company AS SC (NOLOCK) ON SC.Id=J.ServiceCompanyId
			WHERE       J.CompanyId = @CompanyId
						--AND  SC.Name IN (SELECT items FROM dbo.SplitToTable(CONVERT(NVARCHAR(MAX), (SELECT @ServiceCompany FOR XML PATH('')), 1),','))
						AND SC.Id in (select items from dbo.SplitToTable(@ServiceCompany,','))
						AND J.DocumentState NOT IN ('Void','Cancelled','Parked','Reset','Recurring','Deleted')
						AND ((Jd.PostingDate BETWEEN @BSBroughtForwardFromDate AND @BSBroughtForwardToDate) OR 
								 (J.DocType='Journal' AND J.DocsubType IN ('Opening Balance','Opening Bal') AND Jd.PostingDate BETWEEN @BSFromDate AND @BSToDate))
								 And (Jd.ClearingStatus NOT IN (@ExcludeItemChar) OR Jd.ClearingStatus IS NULL) /*Nandu*/
		),
		DCAA AS 
		(
			SELECT DocCurrency , [COA Name] , COAId , COUNT(DocDate)DocDateCount FROM DCA
			GROUP BY DocCurrency  , [COA Name] , COAId 
			UNION ALL
			SELECT DocCurrency , [COA Name] , COAId ,0 AS DocDateCount FROM DC
		)
		INSERT INTO @BSheetDoccurrency
		SELECT DocCurrency , [COA Name] , COAId , SUM(DocDateCount) FROM DCAA
		GROUP BY DocCurrency  , [COA Name] , COAId


		 /***END Getting distinct doccurrencies AND UNIQUE DOCDATE COUNT FOR CHART OF ACCOUNT FOR COMPANY ***/

		 	/**** DocDateCount = 0 (i.e. there are no transactions in choosen doc currency for getting Brought forwarded balance. ***/
			--In this CASE We replace docbalance and basebalance as0.00 

				--In this CASE We replace docbalance and basebalance as0.00 
		INSERT INTO @GLReport
		SELECT  CBS.Code+'  '+CBS.[COA Name] AS [COA Name] , CBS.Recorder AS RecOrder , '' AS DocType ,'' AS DocSubType ,'Balance B/F' AS DocumentDescription , @FromDate AS DocDate , '' AS DocNo , '' AS SystemRefNo , @ServiceCompany AS  ServiceCompany ,''  AS EntityName,NULL AS BaseDebit,NULL AS BaseCredit,BB.BaseBalance AS 'BaseBalance',NULL AS ExchangeRate,BB.BaseCurrency AS 'BaseCurrency', BB.DocCurrency AS 'DocCurrency', NULL AS DocDebit,NULL AS DocCredit,BB.DocBalance AS 'DocBalance',NULL AS SegmentCategory1,NULL AS SegmentCategory2, @MCS_Status,@SegmentStatus AS SegmentStatus,NULL AS CorrAccount,NULL AS [Entity Type],NULL AS [VENDor Type],NULL AS PONo,NULL AS Nature,NULL AS [CreditTerms(Days)],NULL AS DueDate,@NSdISChecked AS [NSD ISCHECKED],NULL AS [NO SUPPORT DOC],NULL AS ItemCode,NULL AS ItemDescription,NULL AS Qty,NULL AS Unit,NULL AS UnitPrice,NULL AS DiscountType,NULL AS Discount,@BRMIsChecked AS [BRM ISCHECKED],NULL AS [ALLOWABLE/DISALLOWABLE],NULL AS [Bank Clearing],NULL AS ModeOfReceipt,NULL AS ReversalDate,NULL AS [Bank Reconcile],NULL AS [Reversal Doc Ref],NULL AS ClearingStatus,NULL AS [Created By],NULL AS [Created On],NULL AS [Modified By],NULL AS [Modified On],CBS.[COA Name] COA_Parameter,CBS.ClassOrder AS classOrder,NULL AS DocumentId,CONVERT(DATETIME,'1900-01-01') AS OrderDate,NULL AS ServiceCompanyId,CBS.AccTypeId ,Null As ServiceEntity,Null As [Tax Code]
		FROM #COA_BalanceSheet AS CBS  INNER JOIN
		(
			
			SELECT DocCurrency ,BaseCurrency ,[COA Name],sum(BaseBalance) As BaseBalance,sum(DocBalance) As DocBalance,COAId From
			(
			Select /*JD.*/'' As DocCurrency , /*JD.*/ '' As BaseCurrency , COA.Name [COA Name],
					CASE WHEN JD.DocCurrency = JD.BaseCurrency
							Then Sum(Coalesce(JD.BaseDebit,JD.DocDebit,0)-Coalesce(JD.BaseCredit,JD.DocCredit,0))  
							Else SUM(ISNULL(JD.BaseDebit,0)-ISNULL(JD.BaseCredit,0)) END AS BaseBalance , /*nandu*/
					/*SUM(CASE WHEN JD.DocCurrency = JD.BaseCurrency
							 THEN ISNULL(JD.DocDebit , 0) - ISNULL(JD.DocCredit , 0)
							 ELSE  ISNULL(JD.BaseDebit , 0) - ISNULL(JD.BaseCredit , 0) END ) AS BaseBalance , */
					SUM(ISNULL(JD.DocDebit , 0) - ISNULL(JD.DocCredit , 0)) AS DocBalance , COA.Id AS COAId/* , SC.ShortName As ServiceEntity*//*Nandu*/
			FROM        Bean.JournalDetail JD (NOLOCK)
			INNER JOIN  Bean.Journal J (NOLOCK) on J.Id=JD.JournalId
			INNER JOIN  Bean.ChartOfAccount COA (NOLOCK) on COA.Id=JD.COAId
			--INNER JOIN @BSheetDoccurrency BSDC ON BSDC.COAId = JD.COAId AND JD.DocCurrency = BSDC.DocCurrency
			INNER JOIN  Common.Company AS SC (NOLOCK) on SC.Id=J.ServiceCompanyId
			WHERE J.CompanyId = @CompanyId
					AND COA.Name in(SELECT [COA Name] FROM @BSheetDoccurrency)
					--AND  SC.Name IN(SELECT items FROM dbo.SplitToTable(CONVERT(NVARCHAR(MAX), (SELECT @ServiceCompany FOR XML PATH('')), 1),','))
					AND SC.Id in (select items from dbo.SplitToTable(@ServiceCompany,','))
					AND ISNULL(JD.DocCurrency,'SGD') IN  (SELECT DocCurrency FROM @BSheetDoccurrency)
					--AND COA.ModuleType='Bean'
					AND J.DocumentState NOT IN ('Void','Cancelled','Parked','Reset','Recurring','Deleted')
					AND Jd.PostingDate BETWEEN @BSBroughtForwardFromDate AND @BSBroughtForwardToDate
					/*AND ((Jd.PostingDate BETWEEN @BSBroughtForwardFromDate AND @BSBroughtForwardToDate)
							OR (Jd.PostingDate BETWEEN @BSFromDate AND @BSToDate AND J.DocType='Journal' AND J.DocsubType IN ('Opening Balance','Opening Bal')))*/
			GROUP BY JD.DocCurrency,JD.BaseCurrency , COA.Name 	, COA.Id /*, SC.ShortName*/
			--) As A Group by [COA Name],COAId
			Union ALL

			Select '' As DocCurrency , '' As BaseCurrency , COA.[COA Name] [COA Name],
					0.00 AS BaseBalance ,
					0.00 AS DocBalance , COA.COAId AS COAId
			/*FROM Bean.JournalDetail JD 
			INNER JOIN  Bean.Journal J on J.Id=JD.JournalId
			INNER JOIN  Bean.ChartOfAccount COA on COA.Id=JD.COAId*/
			From #COA_BalanceSheet As COA where COA.[COA Name]<>'Retained earnings'
			/*INNER JOIN  Common.Company AS SC on SC.Id=J.ServiceCompanyId
			WHERE J.CompanyId = @CompanyId
					AND COA.Name in(SELECT [COA Name] FROM @BSheetDoccurrency)
					AND  SC.Name IN(SELECT items FROM dbo.SplitToTable(CONVERT(NVARCHAR(MAX), (SELECT @ServiceCompany FOR XML PATH('')), 1),','))
					AND J.DocumentState NOT IN ('Void','Cancelled','Parked','Reset','Recurring')*/
					And COA.COAId Not In 
					(
					Select COA.Id AS COAId
					FROM Bean.JournalDetail JD (NOLOCK)
					INNER JOIN  Bean.Journal J (NOLOCK) on J.Id=JD.JournalId
					INNER JOIN  Bean.ChartOfAccount COA (NOLOCK) on COA.Id=JD.COAId
					--INNER JOIN @BSheetDoccurrency BSDC ON BSDC.COAId = JD.COAId AND JD.DocCurrency = BSDC.DocCurrency
					INNER JOIN  Common.Company AS SC (NOLOCK) on SC.Id=J.ServiceCompanyId
					WHERE J.CompanyId = @CompanyId
					AND COA.Name in(SELECT [COA Name] FROM @BSheetDoccurrency)
					--AND  SC.Name IN(SELECT items FROM dbo.SplitToTable(CONVERT(NVARCHAR(MAX), (SELECT @ServiceCompany FOR XML PATH('')), 1),','))
					AND SC.Id in (select items from dbo.SplitToTable(@ServiceCompany,','))
					AND ISNULL(JD.DocCurrency,'SGD') IN  (SELECT DocCurrency FROM @BSheetDoccurrency)
					--AND COA.ModuleType='Bean'
					AND J.DocumentState NOT IN ('Void','Cancelled','Parked','Reset','Recurring','Deleted')
					AND Jd.PostingDate BETWEEN @BSBroughtForwardFromDate AND @BSBroughtForwardToDate
					GROUP BY JD.DocCurrency,JD.BaseCurrency , COA.Name 	, COA.Id /*, SC.ShortName*/

					Union All

					SELECT COAId FROM @BSheetDoccurrency WHERE DocDateCount = 0


					)
			GROUP BY /*JD.DocCurrency,JD.BaseCurrency , */COA.[COA Name], COA.COAId /*, SC.ShortName*/
			
			UNION ALL

			SELECT '' As DocCurrency , /*'SGD'*/ '' As BaseCurrency, [COA Name] , 0.0 AS BaseBalance , 0.0 AS DocBalance,COAId /*,'' As ServiceEntity*/ /*Nandu*/ FROM @BSheetDoccurrency WHERE DocDateCount = 0
			) As A Group by DocCurrency, BaseCurrency, [COA Name], COAId
		) BB ON BB.COAId = CBS.COAId

		 INSERT INTO  @GLReport
		 SELECT [COA Name],RecOrder,DocType,DocSubType,DocumentDescription,DocDate,DocNo,SystemRefNo,ServiceCompany,EntityName,BaseDebit,BaseCredit,BaseBalance,ExchangeRate,BaseCurrency,DocCurrency,DocDebit,DocCredit,DocBalance,/*IsMultiCurrency,*/SegmentCategory1,SegmentCategory2,MCS_Status,Status,  /*FCA.CorrAccount*/  CorrAccount,[Entity Type],[VENDor Type],PONo,Nature,[CreditTerms(Days)],DueDate,[NSD ISCHECKED],[NO SUPPORT DOC],ItemCode,ItemDescription,Qty,Unit,UnitPrice,DiscountType,Discount,[BRM ISCHECKED],[ALLOWABLE/DISALLOWABLE],[Bank Clearing],ModeOfReceipt,ReversalDate,[Bank Reconcile],[Reversal Doc Ref],ClearingStatus,[Created By],[Created On],[Modified By],[Modified On],COA_Parameter,classOrder,DocumentId,DocDate  AS OrderDate,ServiceCompanyId ,AccTypeId,ServiceEntity,[Tax Code]
		 FROM 
		 (
			 SELECT COA.Code+'  '+ COA.[COA Name] AS 'COA Name', JD.DocType,JD.DocSubType,
						  --J.DocumentDescription 
						  JD.AccountDescription AS DocumentDescription
						  , Jd.AccountDescription ,JD.PostingDate As DocDate /*J.Docdate Replace With Posting Date*/, J.DocNo /*Nandu*/,J.TransferRefNo SystemRefNo--, J.ActualSysRefNo SystemRefNo 
						  , SC.Name ServiceCompany , EJ.Name AS EntityName
						 ,ISNULL(JD.BaseDebit , JD.DocDebit) AS BaseDebit
						 ,ISNULL(JD.BaseCredit , JD.DocCredit) AS BaseCredit
						 ,COALESCE(JD.BaseDebit , JD.DocDebit ,0) - COALESCE(JD.BaseCredit , JD.DocCredit ,0) AS BaseBalance
						  ,JD.ExchangeRate,JD.BaseCurrency,ISNULL(JD.DocCurrency,'SGD') DocCurrency,JD.DocDebit,JD.DocCredit
						  ,ISNULL(JD.DocDebit,0) - ISNULL(JD.DocCredit,0) AS DocBalance,/*IsMultiCurrency,*/JD.SegmentCategory1,JD.SegmentCategory2,CASE WHEN MCS.Status=1 THEN 1 ELSE 0 END MCS_Status, NULL Status,
						 JD.JournalId,
						   CASE WHEN EJ.IsCustomer=1 THEN 'Customer' WHEN EJ.IsVENDor=1 THEN 'Vendor' END AS [Entity Type],
						 EJ.VENDorType AS [VENDor Type],
						 J.PONo,JD.Nature,TP.TOPValue AS [CreditTerms(Days)],J.DueDate,NSD.[NSD ISCHECKED]
						 ,CASE WHEN J.IsNoSupportingDocs=0 THEN 'NO' WHEN J.IsNoSupportingDocs=1 THEN 'YES' END
						  AS [NO SUPPORT DOC]
						 ,JD.ItemCode,JD.ItemDescription,JD.Qty,JD.Unit,JD.UnitPrice,JD.DiscountType,JD.Discount,[BRM ISCHECKED]
						 ,CASE WHEN JD.AllowDisAllow=0 THEN 'NO' WHEN JD.AllowDisAllow=1 THEN 'YES' END AS [ALLOWABLE/DISALLOWABLE],JD.ClearingDate AS [Bank Clearing],J.ModeOfReceipt,J.ReversalDate,
						 CASE WHEN J.IsBankReconcile=0 THEN 'NO' WHEN J.IsBankReconcile=1 THEN 'YES' END AS [Bank Reconcile],CASE WHEN J.IsAutoReversalJournal in (1) THEN J.SystemReferenceNo  END AS [Reversal Doc Ref],JD.ClearingStatus,J.UserCreated AS [Created By],J.CreatedDate AS [Created On],J.ModifiedBy AS [Modified By],J.ModifiedDate AS [Modified On],COA.[COA Name] AS COA_Parameter
						,COA.ClassOrder
						,COA.RecOrder,CCOA.Name AS CorrAccount,
						Case When JD.DocType='Credit Note' And JD.DocSubType='Application' Then CNA.InvoiceId 
										When JD.DocType='Credit Memo' And JD.DocSubType='Application' Then CMA.CreditMemoId 
										When JD.DocType='Debt Provision' And JD.DocSubType='Allocation' Then DDA.InvoiceId Else JD.DocumentId End As DocumentId/*JD.DocumentId*/,JD.ServiceCompanyId,COA.AccTypeId,SC.ShortName As ServiceEntity/*Nandu*/,TC.Code As [Tax Code]
			 FROM        Bean.JournalDetail JD (NOLOCK)
			 INNER JOIN  Bean.Journal J (NOLOCK) ON J.Id = JD.JournalId
			 Left Join Bean.TaxCode As TC (NOLOCK) On Tc.Id=JD.TaxId
			 INNER JOIN  #COA_BalanceSheet COA ON COA.COAId = JD.COAId
			 LEFT  JOIN  Bean.ChartOfAccount CCOA (NOLOCK) ON CCOA.Id = JD.CorrAccountId
			 INNER JOIN  Common.Company AS SC (NOLOCK) ON SC.Id = J.ServiceCompanyId
			 LEFT  JOIN  Bean.Entity AS EJ (NOLOCK) ON EJ.Id=JD.EntityId --and J.DocType='Journal' 
			 LEFT JOIN   Bean.MultiCurrencySetting MCS (NOLOCK) ON MCS.companyId=J.CompanyId
			 --LEFT JOIN 
			 -- (
				--	SELECT DISTINCT CompanyId, Status FROM Bean.SegmentMaster WHERE CompanyId = @CompanyId
			 -- ) SM3 ON SM3.companyid=J.CompanyId 
			 LEFT JOIN   Common.TermsOfPayment AS TP (NOLOCK) ON TP.Id = JD.CreditTermsId
			 LEFT JOIN
			  (
				 SELECT   CompanyId , ISNULL(IsChecked,0) AS [NSD ISCHECKED]  
				 FROM     Common.CompanyFeatures (NOLOCK) where CompanyId = @CompanyId and FeatureId = (SELECT DISTINCT Id FROM Common.Feature (NOLOCK) WHERE Name = 'No Supporting Documents') 
			  ) AS NSD ON NSD.CompanyId=J.CompanyId
			 LEFT JOIN
			  (
				 SELECT  CompanyId,ISNULL(IsChecked,0) AS [BRM ISCHECKED] 
				 FROM    Common.CompanyFeatures (NOLOCK) WHERE CompanyId = @CompanyId and FeatureId = (SELECT DISTINCT Id FROM Common.Feature (NOLOCK) WHERE Name='Bank Reconciliation') 
			   ) AS BRM ON BRM.CompanyId=J.CompanyId
			Left Join Bean.CreditNoteApplication As CNA (NOLOCK) On CNA.Id=JD.DocumentId
			Left Join Bean.CreditMemoDetail As CMA (NOLOCK) On CMA.Id=JD.DocumentId
			Left Join Bean.DoubtfulDebtAllocation As DDA (NOLOCK) On DDA.Id=JD.DocumentId
			 WHERE J.CompanyId = @CompanyId  
			 And (Jd.ClearingStatus NOT IN (@ExcludeItemChar) OR Jd.ClearingStatus IS NULL) /*Nandu*/
			-- AND  SC.Name IN (SELECT items FROM dbo.SplitToTable(CONVERT(NVARCHAR(MAX), (SELECT @ServiceCompany FOR XML PATH('')), 1),','))
			 AND SC.Id in (select items from dbo.SplitToTable(@ServiceCompany,','))
			 AND  JD.DocType IN (SELECT items from dbo.SplitToTable(CONVERT(nvarchar(max), (SELECT @DocType FOR XML PATH('')), 1),','))
			 and Jd.PostingDate BETWEEN @BSFromDate AND @BSToDate AND J.DocumentState NOT IN ('Void','Cancelled','Parked','Reset','Recurring','Deleted') 
			 AND ((JD.DocType <> 'Journal' AND JD.DocumentDetailId = '00000000-0000-0000-0000-000000000000') 
					OR (JD.DocumentDetailId <> '00000000-0000-0000-0000-000000000000' AND JD.DocType<>'Journal')
					OR (JD.DocType='Journal' AND JD.DocSubType IN ('Opening Balance','Opening Bal','General','Reversal','Revaluation','Reval','Recurring','Claim')) /*Nandu*/
				 )
		 )P
			  
    Insert Into @GLReport1
	SELECT    * 
	FROM      @GLReport 
	WHERE (ClearingStatus NOT IN (@ExcludeItemChar) OR ClearingStatus IS NULL) /*Nandu*/
	order by RecOrder,classOrder,[COA Name]/*,COA_Parameter */,DocDate,DocNo --// DocNum Added

	INSERT INTO @GLReport2
	SELECT ROW_NUMBER() over(order by RecOrder,classOrder,[COA Name],CASE WHEN DocumentDescription='Balance B/F' THEN 1 When DocSubType IN ('Opening Balance','Opening Bal') Then 2  ELSE 3 END,DocDate ) Number, * FROM @GLReport1
	DROP TABLE #COA_BalanceSheet


	                      /***END of Step 8.1 : Inserting into @GLReport data into @GLReport1 by adding rownumbering ***/
	
	                      /*** Step 8.2: Calculating running total for DocBalance and BaseBalance columns ineach line  by doc currency wise and insert all records into @GLReport_AfterAdding_SubTotal***/

	/** To do this we get running total of DocBalance and BaseBalance by using over clause with partition by and order by clause in each record of @GLReport1. ****/

	/** Here we took all columns except column named AS 'number'.BCZ it mismatched no of columns to be inserted into  @GLReport_AfterAdding_SubTotal**/
	
	/*** Here we set IsSubTotal  to 1 ***/

	Insert Into @GLReport_AfterAdding_SubTotal ([COA Name],RecOrder,DocType ,DocSubType ,DocumentDescription,DocDate ,DocNo ,SystemRefNo ,ServiceCompany ,EntityName ,BaseDebit ,BaseCredit ,BaseBalance ,ExchangeRate ,BaseCurrency ,DocCurrency ,DocDebit ,DocCredit ,DocBalance ,SegmentCategory1 ,SegmentCategory2 ,MCS_Status ,SegmentStatus ,CorrAccount ,[Entity Type] ,[VENDor Type] ,PONo ,Nature ,[CreditTerms(Days)] ,DueDate ,[NSD ISCHECKED] ,[NO SUPPORT DOC] ,ItemCode ,ItemDescription ,Qty ,Unit ,UnitPrice ,[DiscountType] ,Discount ,[BRM ISCHECKED] ,[ALLOWABLE/DISALLOWABLE] ,[Bank Clearing] ,ModeOfReceipt ,ReversalDate ,[Bank Reconcile] ,[Reversal Doc Ref] ,ClearingStatus ,[Created By] ,[Created On] ,[Modified By] ,[Modified On] ,COA_Parameter ,classOrder,IsSubTotal,ISBF,DocumentId,OrderDate,ServiceCompanyId,BaseBalanceReal,AccTypeId,number,ServiceEntity,[Tax Code])
	SELECT [COA Name],RecOrder,DocType,DocSubType,DocumentDescription,DocDate,DocNo,SystemRefNo,ServiceCompany,EntityName,BaseDebit,BaseCredit, sum(BaseBalance) over ( partition by [COA Name] order by number) BaseBalance,ExchangeRate,BaseCurrency,DocCurrency,DocDebit,DocCredit, sum(DocBalance)  over ( partition by [COA Name] order by number) DocBalance,/*IsMultiCurrency,*/SegmentCategory1,SegmentCategory2,MCS_Status,SegmentStatus, CorrAccount,[Entity Type],[VENDor Type],PONo,Nature,[CreditTerms(Days)],DueDate,[NSD ISCHECKED],[NO SUPPORT DOC],ItemCode,ItemDescription,Qty,Unit,UnitPrice,DiscountType,Discount,[BRM ISCHECKED],[ALLOWABLE/DISALLOWABLE],[Bank Clearing],ModeOfReceipt,ReversalDate,[Bank Reconcile],[Reversal Doc Ref],ClearingStatus,[Created By],[Created On],[Modified By],[Modified On],COA_Parameter,
	       classOrder,0 AS IsSubTotal,CASE WHEN DocumentDescription='Balance B/F' THEN 1 ELSE 2 END AS ISBF,DocumentId,OrderDate,ServiceCompanyId ,BaseBalance,AccTypeId,number,ServiceEntity,[Tax Code]
		   From  @GLReport2
		   WHERE (ClearingStatus NOT IN (@ExcludeItemChar) OR ClearingStatus IS NULL) /*Nandu*/
	order by RecOrder,classOrder,[COA Name]/*,DocCurrency*/,CASE WHEN DocumentDescription='Balance B/F' THEN 1 When DocSubType IN ('Opening Balance','Opening Bal') Then 2  ELSE 3 END ,Number ,OrderDate


	                    /*** END of Step 8.2: Calculating running total for DocBalance and BaseBalance columns ineach line  by doc currency wise and insert all records into @GLReport_AfterAdding_SubTotal***/--RecOrder,classOrder,
	
	                    /*** Step 8.3: Getting SubTotal by docCurrency for all COA's ***/

    /** Here we calculate SubTotals of DocDebit,DocCredit,DocBalance,BaseDebit,BaseCredit and BaseBalance by DocCurrency wise of each coa. We set IsSubTotal  to 1 **/
	--Insert Into @GLReport_AfterAdding_SubTotal ([COA Name],RecOrder,DocType ,DocSubType ,DocumentDescription,DocDate ,DocNo ,SystemRefNo ,ServiceCompany ,EntityName ,BaseDebit ,BaseCredit ,BaseBalance ,ExchangeRate ,BaseCurrency ,DocCurrency ,DocDebit ,DocCredit ,DocBalance ,SegmentCategory1 ,SegmentCategory2 ,MCS_Status ,SegmentStatus ,CorrAccount ,[Entity Type] ,[VENDor Type] ,PONo ,Nature ,[CreditTerms(Days)] ,DueDate ,[NSD ISCHECKED] ,[NO SUPPORT DOC] ,ItemCode ,ItemDescription ,Qty ,Unit ,UnitPrice ,[DiscountType] ,Discount ,[BRM ISCHECKED] ,[ALLOWABLE/DISALLOWABLE] ,[Bank Clearing] ,ModeOfReceipt ,ReversalDate ,[Bank Reconcile] ,[Reversal Doc Ref] ,ClearingStatus ,[Created By] ,[Created On] ,[Modified By] ,[Modified On] ,COA_Parameter ,classOrder,IsSubTotal,ISBF)
 --   SELECT   [COA Name],RecOrder,'' AS DocType,'' AS DocSubType,'' AS DocumentDescription,null AS  DocDate,'' AS DocNo,'' AS SystemRefNo, ServiceCompany,''  AS EntityName,sum(ISNULL(BaseDebit,0.00)) AS BaseDebit,sum(ISNULL(BaseCredit,0.00)) AS BaseCredit,sum(BaseBalance) AS BaseBalance,null AS ExchangeRate, BaseCurrency, DocCurrency, sum(ISNULL(DocDebit,0.00)) AS DocDebit,sum(ISNULL(DocCredit,0.00)) AS DocCredit,sum(DocBalance) AS DocBalance/*IsMultiCurrency,*/,null AS SegmentCategory1,null AS SegmentCategory2,@MCS_Status,@SegmentStatus AS SegmentStatus,null AS CorrAccount,null AS [Entity Type],null AS [VENDor Type],null AS PONo,null AS Nature,null AS [CreditTerms(Days)],null AS DueDate,@NSdISChecked AS [NSD ISCHECKED],null AS [NO SUPPORT DOC],null AS ItemCode,null AS ItemDescription,null AS Qty,null AS Unit,null AS UnitPrice,null AS DiscountType,null AS Discount,@BRMIsChecked AS [BRM ISCHECKED],null AS [ALLOWABLE/DISALLOWABLE],null AS [Bank Clearing],null AS ModeOfReceipt,null AS ReversalDate,NULL AS [Bank Reconcile],null AS [Reversal Doc Ref],null AS ClearingStatus,null AS [Created By],null AS [Created On],null AS [Modified By],null AS [Modified On], COA_Parameter, classOrder,1 AS IsSubTotal,3 AS ISBF       
	--FROM      @GLReport 
	--Group By  [COA Name],RecOrder,ServiceCompany,BaseCurrency, DocCurrency,COA_Parameter, classOrder     
	--order by classOrder,COA_Parameter,DocDate

	                    /*** Step 8.3: Getting SubTotal by docCurrency for all COA's ***/

						/** Step 8.4: Finally Displaying Result **/
  --DECLARE @ExcludeItemChar NVARCHAR(50)= (CASE WHEN @ExcludeClearedItem = 1 THEN 'Cleared' ELSE '' END)
					
						--IF(@ExcludeClearedItem=0)
						--BEGIN
						--SELECT [COA Name] ,RecOrder
						--	--CASE WHEN ISBF=1 and DocDate<=@UserStartDate THEN 'Opening Balance' 
						--	--                                 WHEN ISBF=1 and DocDate>@UserStartDate THEN 'Balance B/F'
						--	--								 ELSE DocType 
						--	--							 END  AS 'Type'
						--	,DocType AS 'Type'
						--			,DocSubType AS 'Sub Type'
						--			,DocNo,EntityName 'Entity',CASE WHEN ISBF=1 and CONVERT(DATE, @FromDate)=@UserStartDate THEN 'Opening Balance' 
						--							   WHEN ISBF=1 and CONVERT(DATE, DocDate) <> @UserStartDate THEN 'Balance B/F'
						--							 ELSE DocumentDescription END AS 'Description'
						--			,DocCurrency AS 'Curr'
						--			,BaseDebit 'Debit',BaseCredit 'Credit',
						--			CASE WHEN ISBF=1  then BaseBalanceReal  ELSE  BaseBalance END AS 'Balance'
						--			,DocDebit 
						--			,DocCredit ,DocBalance
						--			 ,ExchangeRate AS 'Exch Rate'
						--			 ,DueDate 
						--			 ,[Bank Clearing]
						--			 ,ItemCode 'Item'
						--			 ,Qty 'Quantity'
						--			  ,UnitPrice 'Unit Price' 
						--			  , NULL AS 'Tax Code'  --nEED tO aDD 
						--			  , NULL AS 'Mode'      -- nEED tO aDD
						--			  ,SystemRefNo 'Ref No'
						--			  ,ClearingStatus AS 'Cleared'    -- nEED tO aDD
						--			  --,FORMAT(DocDate, 'dd-MM-yyyy') AS 'Date',
						--			  ,DocDate AS 'Date'
						--			  ,DocumentId AS DocumentId --INTO GL_Khadar
						--			  --,ID AS 'RowId'
						--			  , number RowId
						--			  --,Row_Number() OVER(ORDER BY AccTypeId,COA_Parameter,DocDate) RowId
						--			  ,ServiceCompanyId,COA_Parameter ,AccTypeId
									  
						-- From @GLReport_AfterAdding_SubTotal
						-- --ORDER BY RecOrder,,COA_Parameter,DocCurrency,ISBF,OrderDate
						-- ORDER BY number--/*classOrder*/AccTypeId,COA_Parameter,DocDate
						--END
						--ELSE 
						--BEGIN
			
							SELECT [COA Name] ,RecOrder
								--CASE WHEN ISBF=1 and DocDate<=@UserStartDate THEN 'Opening Balance' 
								--                                 WHEN ISBF=1 and DocDate>@UserStartDate THEN 'Balance B/F'
								--								 ELSE DocType 
								--							 END  AS 'Type'
								,DocType AS 'Type'
										,DocSubType AS 'Sub Type'
										,DocNo,EntityName 'Entity',
										CASE WHEN [COA Name] LIKE '%Retained earnings%' AND  ISBF=1 
				--and CONVERT(DATE, @FromDate)=@UserStartDate AND CONVERT(DATE, DocDate) <> @UserStartDate 
				Then 'Balance B/F'  
				
				 When [COA Name] NOT LIKE '%Retained earnings%' AND ISBF=1 and CONVERT(DATE, @FromDate)=@UserStartDate THEN 'Opening Balance' 
					WHEN [COA Name] NOT LIKE '%Retained earnings%' AND ISBF=1 and CONVERT(DATE, DocDate) <> @UserStartDate THEN 'Balance B/F'
						ELSE DocumentDescription 
						 END  AS 'Description'
										--CASE WHEN ISBF=1 and CONVERT(DATE, @FromDate)=@UserStartDate THEN 'Opening Balance' 
										--			   WHEN ISBF=1 and CONVERT(DATE, DocDate) <> @UserStartDate THEN 'Balance B/F'
										--			 ELSE DocumentDescription END AS 'Description'
										,DocCurrency AS 'Curr'
										,BaseDebit 'Debit',BaseCredit 'Credit',
										CASE WHEN ISBF=1  then BaseBalanceReal  ELSE  BaseBalance END AS 'Balance'
										,DocDebit 
										,DocCredit ,DocBalance
										 ,ExchangeRate AS 'Exch Rate'
										 ,DueDate 
										 ,[Bank Clearing]
										 ,ItemCode 'Item'
										 ,Qty 'Quantity'
										  ,UnitPrice 'Unit Price' 
										  , [Tax Code]
										  , ModeOfReceipt AS 'Mode' 
										  ,SystemRefNo 'Ref No'
										  ,ClearingStatus AS 'Cleared'    -- NEED tO aDD
										  --,FORMAT(DocDate, 'dd-MM-yyyy') AS 'Date',
										  ,DocDate AS 'Date'
										  ,DocumentId AS DocumentId --INTO GL_Khadar
										 --,Id 'RowId'
										  --,Row_Number() OVER(ORDER BY AccTypeId,COA_Parameter,DocDate) RowId
										  , number RowId
										  ,ServiceCompanyId ,COA_Parameter,AccTypeId,ServiceEntity
							
							 From @GLReport_AfterAdding_SubTotal
							 WHERE (ClearingStatus NOT IN (@ExcludeItemChar) OR ClearingStatus IS NULL)--IS NOT NULL
							 
							 	 ORDER BY number--/*classOrder*/AccTypeId,COA_Parameter,DocDate
								
						 --ORDER BY RecOrder,classOrder,COA_Parameter,DocCurrency,ISBF,OrderDate
							 --ORDER BY [COA Name],OrderDate
						--END
	
	                 
	                   /** END of Step 8.4: Finally Displaying Result **/                 

                      /******* END of Step 8: Final result *******************/

END
GO
