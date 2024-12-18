USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[Rpt_GLINPUT_TAX]    Script Date: 16-12-2024 9.20.11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

--Select * from Common.Company Where Name='ISLAND ASSET MANAGEMENT PTE. LTD.'

--Declare @CompanyValue nvarchar(50)=N'328',@FromDate DateTime='2018-11-01 00:00:00',@ToDate Datetime='2018-11-22 00:00:00',@ServiceCompany nvarchar(Max)=N'silicon Solutions'--,@GSTNO nvarchar(50)=N'44562'
	--EXEC [dbo].[Rpt_GLINPUT_TAX]  @CompanyValue =N'318',@FromDate ='2019-01-01 00:00:00',@ToDate ='2019-11-22 00:00:00',@ServiceCompany =N'ISLAND ASSET MANAGEMENT PTE. LTD.',@GSTNO =N'44562'	
--	Declare @CompanyValue Int =1,@FromDate datetime='2019-01-01 00:00:00.000' ,@ToDate datetime = '2019-06-23 00:00:00.000',
--@ServiceCompany varchar(max) = 'Precursor Corporate Services Pte. Ltd.',@GSTNO varchar(max)='44562'
CREATE PROCEDURE [dbo].[Rpt_GLINPUT_TAX]
@CompanyValue VARCHAR(MAX),
@FromDate datetime,
@ToDate datetime,
@ServiceCompany varchar(max),
@GSTNO varchar(max)
AS
BEGIN		
	
Declare @CompanyId Int 
select @CompanyId = dbo.DecryptCompanyValue(@CompanyValue)  

/***************STEP 1: CREATING RECORDS FOR BILL AND CASH PAYMENT IN TX','ZP','IM','ME','IGDS','TX-ESS','TX-N33','TX-RE' *********************/
-- STARTING POINT OF TX','ZP','IM','ME','IGDS','TX-ESS','TX-N33','TX-RE'

--STARTING OF DT10
--HERE WE REPLACE GST,NET RELATED AMOUNTS TO NULL EXCEPT TAXCODE ARE IN 'TX','ZP','IM','ME','IGDS','TX-ESS','TX-N33','TX-RE' EXCEPT MANUAL JV'S 

SELECT DT10.DocType,Convert(date,DT10.DocDate) AS DocDate,DT10.[Doc Ref No],DT10.DocNo,DT10.Entity,DT10.DocDescription,DT10.[Tax Code],DT10.[TAX RATE IN VAR],
       CASE WHEN DT10.[Tax Code]='TX' THEN Case When DT10.TX_NET<0 then DT10.TX_GST*(-1) Else  DT10.TX_GST END END AS TX_GST, --GST STARTING
	   CASE WHEN DT10.[Tax Code]='ZP' THEN Case When DT10.ZP_NET<0 Then DT10.ZP_GST*(-1) Else  DT10.ZP_GST END END AS ZP_GST,
	   CASE WHEN DT10.[Tax Code]='IM' THEN Case When DT10.IM_NET<0 Then DT10.IM_GST*(-1) ELSE  DT10.IM_GST END END AS IM_GST,
	   CASE WHEN DT10.[Tax Code]='ME' THEN Case When DT10.ME_NET<0 Then DT10.ME_GST*(-1) ELSE  DT10.ME_GST END END AS ME_GST,
	   CASE WHEN DT10.[Tax Code]='IGDS' THEN Case When DT10.IGDS_NET<0 Then DT10.IGDS_GST*(-1) ELSE DT10.IGDS_GST END END AS IGDS_GST,
	   CASE WHEN DT10.[Tax Code]='TX-ESS' THEN Case When DT10.TX_ESS_NET<0 Then  DT10.TX_ESS_GST*(-1) ELSE DT10.TX_ESS_GST END END AS TX_ESS_GST,
	   CASE WHEN DT10.[Tax Code]='TX-N33' THEN Case When DT10.TX_N33_NET<0 Then DT10.TX_N33_GST*(-1) ELSE DT10.TX_N33_GST END END AS TX_N33_GST,
	   CASE WHEN DT10.[Tax Code]='TX-RE' THEN Case When DT10.TX_RE_NET<0 Then DT10.TX_RE_GST*(-1) ELSE DT10.TX_RE_GST END END AS TX_RE_GST,
	   Case When DT10.TOTAL_NET<0 Then  DT10.TOTAL_GST*(-1) ELSE DT10.TOTAL_GST END AS TOTAL_GST,-- GST ENDING
	   CASE WHEN DT10.[Tax Code]='TX' THEN DT10.TX_NET END AS TX_NET, --NET STARTING
	   CASE WHEN DT10.[Tax Code]='ZP' THEN DT10.ZP_NET END AS ZP_NET,
	   CASE WHEN DT10.[Tax Code]='IM' THEN DT10.IM_NET END AS IM_NET,
	   CASE WHEN DT10.[Tax Code]='ME' THEN DT10.ME_NET END AS ME_NET,
	   CASE WHEN DT10.[Tax Code]='IGDS' THEN DT10.IGDS_NET END AS IGDS_NET,
	   CASE WHEN DT10.[Tax Code]='TX-ESS' THEN DT10.TX_ESS_NET END AS TX_ESS_NET,
	   CASE WHEN DT10.[Tax Code]='TX-N33' THEN DT10.TX_N33_NET END AS TX_N33_NET,
	   CASE WHEN DT10.[Tax Code]='TX-RE' THEN DT10.TX_RE_NET END AS TX_RE_NET, --NET ENDING
	   DT10.TOTAL_NET,DT10.[Gross Amount],DT10.COA,DT10.[Account Type],/*DT10.RECORDER,*/DT10.[Service Comapany],DocumentId,DT10.ServiceCompanyId,DT10.DocSubType
FROM
(
	-- START OF DT9.
	-- HERE, WE ARE GROUPING THE RECORDS BASED ON THE COLUMNS  DocType,DocDate,[Doc Ref No],DocNo,Entity,DocDescription,[Tax Code],[TAX RATE IN VAR],COA,[Account Type],RECORDER,[Service Comapany]
	SELECT DT9.DocType,DT9.DocDate,DT9.[Doc Ref No],DT9.DocNo,DT9.Entity,DT9.DocDescription,DT9.[Tax Code],DT9.[TAX RATE IN VAR],
		   SUM(DT9.TX_GST) AS TX_GST,SUM(DT9.ZP_GST) AS ZP_GST,SUM(DT9.IM_GST) AS IM_GST,SUM(DT9.ME_GST) AS ME_GST,SUM(DT9.IGDS_GST) AS IGDS_GST,SUM(DT9.TX_ESS_GST) AS TX_ESS_GST,SUM(DT9.TX_N33_GST) AS TX_N33_GST,SUM(DT9.TX_RE_GST) AS TX_RE_GST,SUM(DT9.TOTAL_GST) AS TOTAL_GST,
		   SUM(DT9.TX_NET) AS TX_NET,SUM(DT9.ZP_NET) AS ZP_NET,SUM(DT9.IM_NET) AS IM_NET,SUM(DT9.ME_NET) AS ME_NET,SUM(DT9.IGDS_NET) AS IGDS_NET,SUM(DT9.TX_ESS_NET) AS TX_ESS_NET,SUM(DT9.TX_N33_NET) AS TX_N33_NET,SUM(DT9.TX_RE_NET) AS TX_RE_NET,SUM(DT9.TOTAL_NET) AS TOTAL_NET, SUM(DT9.[Gross Amount]) AS [Gross Amount],
		   DT9.COA,DT9.[Account Type],/*DT9.RECORDER,*/DT9.[Service Comapany],DocumentId,DT9.ServiceCompanyId,DT9.DocSubType
	FROM
	(
		--STEP 4: STARTING OF DT8
		-- IF DOCDESCRIPTION IS NULL THEN REPLACE WITH'-'  AND [TAX RATE IN VAR] COLUMN IS NULL THEN REPLACED WITH 0%
		 SELECT DT8.DocType,DT8.DocDate,DT8.[Doc Ref No],DT8.DocNo,DT8.Entity,ISNULL(DT8.DocDescription,'-') AS DocDescription,DT8.[Tax Code],DT8.[TAX RATE IN VAR],
					   CASE WHEN [Tax Code]='TX' THEN BaseDebit ELSE CONVERT(MONEY,'0') END AS [TX_GST],--GST AMOUNTS STARTING
					   CASE WHEN [Tax Code]='ZP' THEN BaseDebit ELSE CONVERT(MONEY,'0') END AS [ZP_GST],
					   CASE WHEN [Tax Code]='IM' THEN BaseDebit ELSE CONVERT(MONEY,'0') END AS [IM_GST],
					   CASE WHEN [Tax Code]='ME' THEN BaseDebit ELSE CONVERT(MONEY,'0') END AS [ME_GST],
					   CASE WHEN [Tax Code]='IGDS' THEN BaseDebit ELSE CONVERT(MONEY,'0') END AS [IGDS_GST],
					   CASE WHEN [Tax Code]='TX-ESS' THEN BaseDebit ELSE CONVERT(MONEY,'0') END AS [TX_ESS_GST],
					   CASE WHEN [Tax Code]='TX-N33' THEN BaseDebit ELSE CONVERT(MONEY,'0') END AS [TX_N33_GST],
					   CASE WHEN [Tax Code]='TX-RE' THEN BaseDebit ELSE CONVERT(MONEY,'0') END AS [TX_RE_GST],
					   BaseDebit AS TOTAL_GST,-- GST AMOUNTS ENDING
					   CASE WHEN [Tax Code]='TX' THEN [NET AMOUNT] ELSE CONVERT(MONEY,'0') END  AS [TX_NET],--NET AMOUNT STARTING
					   CASE WHEN [Tax Code]='ZP' THEN [NET AMOUNT] ELSE CONVERT(MONEY,'0') END AS [ZP_NET],
					   CASE WHEN [Tax Code]='IM' THEN [NET AMOUNT] ELSE CONVERT(MONEY,'0') END  AS [IM_NET],
					   CASE WHEN [Tax Code]='ME' THEN [NET AMOUNT] ELSE CONVERT(MONEY,'0') END AS [ME_NET],
					   CASE WHEN [Tax Code]='IGDS' THEN [NET AMOUNT] ELSE CONVERT(MONEY,'0') END  AS [IGDS_NET],
					   CASE WHEN [Tax Code]='TX-ESS' THEN [NET AMOUNT] ELSE CONVERT(MONEY,'0') END  AS [TX_ESS_NET],
					   CASE WHEN [Tax Code]='TX-N33' THEN [NET AMOUNT] ELSE CONVERT(MONEY,'0') END  AS [TX_N33_NET],
					   CASE WHEN [Tax Code]='TX-RE' THEN [NET AMOUNT] ELSE CONVERT(MONEY,'0') END  AS [TX_RE_NET],
					   [NET AMOUNT] AS TOTAL_NET,-- NET AMOUNT ENDING
					   Case When [NET AMOUNT]<0 THEN BaseDebit*(-1) ELSE BaseDebit END +[NET AMOUNT] AS [Gross Amount],
					   COA,[Account Type],
					   /*1 AS RECORDER,*/
					   [Service Comapany],DocumentId,ServiceCompanyId,DocSubType
		FROM
		(   
	
					--STEP3-- JOINING DT6 AND DT9
					SELECT DT6.DocType,DT6.DocDate,DT6.[Doc Ref No],DT6.DocNo,DT6.Entity,DT6.DocDescription,DT6.[Tax Code],DT6.[TAX RATE IN VAR],DT6.COA,DT6.[Account Type],DT6.[Net Amount],DT6.[Service Comapany],DT9.BaseDebit,DT9.DocumentId,DT6.ServiceCompanyId,DT6.DocSubType
					FROM
					(

						 --STEP1:GETTING RECORDS FOR 'TX','ZP','IM','ME','IGDS','TX-ESS','TX-N33','TX-RE' TAXCODES WITH ISTAX<>1 
						 -- HERE WE GET NETAMOUNT FROM BASECREDIT OF JOURNALDETAIL
						SELECT       JD.DocType,JD.DocDate,JD.SystemRefNo AS [Doc Ref No],JD.DocNo,E.Name AS Entity,
						         --    CASE WHEN JD.DocType='Bill' THEN JD.DocDescription
									      --WHEN  JD.DocType='Cash Payment' THEN JD.AccountDescription END AS DocDescription,
									  Case when J.DocType<>'Journal' then J.DocumentDescription when J.DocType='Journal' then
						              Case when J.DocSubType IN ('Opening Balance','Opening Bal') then 
								      Case when Jd.AccountDescription is null then J.DocumentDescription 
									  Else Jd.AccountDescription  end
								      When J.DocSubType NOT IN ('Opening Balance','Opening Bal') then J.DocumentDescription
							          End end as DocDescription,
									 JD.TaxId,TC.Code AS [Tax Code],JD.TaxRate,CONVERT(VARCHAR(100),JD.TaxRate)+''+'%' AS [TAX RATE IN VAR],
									 COA.Name AS COA,ACT.Name AS [Account Type],IsNull(JD.BaseDebit,0)-IsNull(JD.BaseCredit,0) as [Net Amount],SC.Name AS [Service Comapany],jd.JournalId,JD.DocumentId,JD.DocumentDetailId,JD.ServiceCompanyId,JD.DocSubType
						FROM         Bean.JournalDetail AS JD
						INNER JOIN   Bean.Journal AS J ON J.Id=JD.JournalId
						INNER JOIN   Bean.ChartOfAccount AS COA ON COA.Id=JD.COAId
						INNER JOIN   Bean.AccountType AS ACT ON ACT.Id=COA.AccountTypeId
						Left JOIN    Bean.Entity AS E ON E.Id=JD.EntityId
						INNER JOIN   Bean.TaxCode AS TC ON TC.Id=JD.TaxId
						INNER JOIN   Common.Company AS SC ON SC.Id=JD.ServiceCompanyId
						WHERE        COA.CompanyId=@CompanyId AND JD.PostingDate BETWEEN @FromDate AND @ToDate
									 --AND JD.DocType IN ('Bill','Cash Payment') 
									 AND JD.DocType  NOT IN  ('Journal') 
									 AND JD.IsTax<>1 AND J.DocumentState <> 'Void' 
									 AND DocumentDetailId<>'00000000-0000-0000-0000-000000000000'
									 AND TC.Code in ('TX','ZP','IM','ME','IGDS','TX-ESS','TX-N33','TX-RE')
					) AS DT6

					INNER JOIN
					(
						--STEP2: GETTING RECORDS  'TX','ZP','IM','ME','IGDS','TX-ESS','TX-N33','TX-RE' TAXCODES WITH ISTAX=1  EXCEPT MANUAL JV'S
						-- HERE WE GET BASEADEBIT
						SELECT       --IsNull(JD.BaseDebit,0)-IsNull(JD.BaseCredit,0) 
						JD.BaseTaxAmount AS BaseDebit,jd.JournalId,JD.DocumentId,JD.DocumentDetailId,SC.Name AS [Service Comapany],Jd.ServiceCompanyId,JD.DocSubType
						FROM         Bean.JournalDetail AS JD
						INNER JOIN   Bean.Journal AS J ON J.Id=JD.JournalId
						INNER JOIN   Bean.ChartOfAccount AS COA ON COA.Id=JD.COAId
						INNER JOIN   Bean.AccountType AS ACT ON ACT.Id=COA.AccountTypeId
						Left JOIN    Bean.Entity AS E ON E.Id=JD.EntityId
						INNER JOIN   Bean.TaxCode AS TC ON TC.Id=JD.TaxId
						INNER JOIN   Common.Company AS SC ON SC.Id=JD.ServiceCompanyId
						WHERE        COA.CompanyId=@CompanyId AND JD.PostingDate BETWEEN @FromDate AND @ToDate
									 --AND JD.DocType IN ('Bill','Cash Payment') 
									 AND JD.DocType  NOT IN  ('Journal')  AND JD.TaxId IS NOT NULL
									AND JD.IsTax<>1 AND J.DocumentState <> 'Void' 
									 AND DocumentDetailId<>'00000000-0000-0000-0000-000000000000'
									 AND TC.Code in ('TX','ZP','IM','ME','IGDS','TX-ESS','TX-N33','TX-RE')
					) AS DT9 ON DT6.JournalId=DT9.JournalId AND DT6.DocumentId=DT9.DocumentId AND DT6.DocumentDetailId=DT9.DocumentDetailId AND DT6.[Service Comapany]=DT9.[Service Comapany]
					-- END OF STEP3
		)AS DT8
		WHERE DT8.[Service Comapany]=@ServiceCompany
	)
	AS DT9
	GROUP BY DocType,DocDate,[Doc Ref No],DocNo,Entity,DocDescription,[Tax Code],[TAX RATE IN VAR],COA,[Account Type],/*RECORDER,*/[Service Comapany],DocumentId,ServiceCompanyId,DocSubType
) AS DT10
--ENDING POINT OF 'TX','ZP','IM','ME','IGDS','TX-ESS','TX-N33','TX-RE' EXCEPT MANUAL JV'S

UNION ALL

--STARTING OF DT14
--HERE WE REPLACE GST,NET RELATED AMOUNTS TO NULL EXCEPT TAXCODE ARE IN 'TX','ZP','IM','ME','IGDS','TX-ESS','TX-N33','TX-RE'  FOR MANUAL JV'S

	SELECT DT14.DocType,DT14.DocDate,DT14.[Doc Ref No],DT14.DocNo,DT14.Entity,DT14.DocDescription,DT14.[Tax Code],DT14.[TAX RATE IN VAR],
       CASE WHEN DT14.[Tax Code]='TX' THEN Case When DT14.TX_NET<0 then DT14.TX_GST*(-1) Else  DT14.TX_GST END END AS TX_GST, --GST STARTING
	   CASE WHEN DT14.[Tax Code]='ZP' THEN Case When DT14.ZP_NET<0 Then DT14.ZP_GST*(-1) Else  DT14.ZP_GST END END AS ZP_GST,
	   CASE WHEN DT14.[Tax Code]='IM' THEN Case When DT14.IM_NET<0 Then DT14.IM_GST*(-1) ELSE  DT14.IM_GST END END AS IM_GST,
	   CASE WHEN DT14.[Tax Code]='ME' THEN Case When DT14.ME_NET<0 Then DT14.ME_GST*(-1) ELSE  DT14.ME_GST END END AS ME_GST,
	   CASE WHEN DT14.[Tax Code]='IGDS' THEN Case When DT14.IGDS_NET<0 Then DT14.IGDS_GST*(-1) ELSE DT14.IGDS_GST END END AS IGDS_GST,
	   CASE WHEN DT14.[Tax Code]='TX-ESS' THEN Case When DT14.TX_ESS_NET<0 Then  DT14.TX_ESS_GST*(-1) ELSE DT14.TX_ESS_GST END END AS TX_ESS_GST,
	   CASE WHEN DT14.[Tax Code]='TX-N33' THEN Case When DT14.TX_N33_NET<0 Then DT14.TX_N33_GST*(-1) ELSE DT14.TX_N33_GST END END AS TX_N33_GST,
	   CASE WHEN DT14.[Tax Code]='TX-RE' THEN Case When DT14.TX_RE_NET<0 Then DT14.TX_RE_GST*(-1) ELSE DT14.TX_RE_GST END END AS TX_RE_GST,
	   Case When DT14.TOTAL_NET<0 Then  DT14.TOTAL_GST*(-1) ELSE DT14.TOTAL_GST END AS TOTAL_GST,-- GST ENDING
	   CASE WHEN DT14.[Tax Code]='TX' THEN DT14.TX_NET END AS TX_NET, --NET STARTING
	   CASE WHEN DT14.[Tax Code]='ZP' THEN DT14.ZP_NET END AS ZP_NET,
	   CASE WHEN DT14.[Tax Code]='IM' THEN DT14.IM_NET END AS IM_NET,
	   CASE WHEN DT14.[Tax Code]='ME' THEN DT14.ME_NET END AS ME_NET,
	   CASE WHEN DT14.[Tax Code]='IGDS' THEN DT14.IGDS_NET END AS IGDS_NET,
	   CASE WHEN DT14.[Tax Code]='TX-ESS' THEN DT14.TX_ESS_NET END AS TX_ESS_NET,
	   CASE WHEN DT14.[Tax Code]='TX-N33' THEN DT14.TX_N33_NET END AS TX_N33_NET,
	   CASE WHEN DT14.[Tax Code]='TX-RE' THEN DT14.TX_RE_NET END AS TX_RE_NET, --NET ENDING
	   DT14.TOTAL_NET,DT14.[Gross Amount],DT14.COA,DT14.[Account Type],/*DT14.RECORDER,*/DT14.[Service Comapany],DT14.DocumentId,DT14.ServiceCompanyId,DT14.DocSubType
FROM
(
	-- START OF DT13.
	-- HERE, WE ARE GROUPING THE RECORDS BASED ON THE COLUMNS  DocType,DocDate,[Doc Ref No],DocNo,Entity,DocDescription,[Tax Code],[TAX RATE IN VAR],COA,[Account Type],RECORDER,[Service Comapany]
	SELECT DT13.DocType,DT13.DocDate,DT13.[Doc Ref No],DT13.DocNo,DT13.Entity,DT13.DocDescription,DT13.[Tax Code],DT13.[TAX RATE IN VAR],
		   SUM(DT13.TX_GST) AS TX_GST,SUM(DT13.ZP_GST) AS ZP_GST,SUM(DT13.IM_GST) AS IM_GST,SUM(DT13.ME_GST) AS ME_GST,SUM(DT13.IGDS_GST) AS IGDS_GST,SUM(DT13.TX_ESS_GST) AS TX_ESS_GST,SUM(DT13.TX_N33_GST) AS TX_N33_GST,SUM(DT13.TX_RE_GST) AS TX_RE_GST,SUM(DT13.TOTAL_GST) AS TOTAL_GST,
		   SUM(DT13.TX_NET) AS TX_NET,SUM(DT13.ZP_NET) AS ZP_NET,SUM(DT13.IM_NET) AS IM_NET,SUM(DT13.ME_NET) AS ME_NET,SUM(DT13.IGDS_NET) AS IGDS_NET,SUM(DT13.TX_ESS_NET) AS TX_ESS_NET,SUM(DT13.TX_N33_NET) AS TX_N33_NET,SUM(DT13.TX_RE_NET) AS TX_RE_NET,SUM(DT13.TOTAL_NET) AS TOTAL_NET, SUM(DT13.[Gross Amount]) AS [Gross Amount],
		   DT13.COA,DT13.[Account Type],/*DT13.RECORDER,*/DT13.[Service Comapany],DT13.DocumentId,DT13.ServiceCompanyId,DT13.DocSubType
	FROM
	(
		--STEP 4: STARTING OF DT12
		-- IF DOCDESCRIPTION IS NULL THEN REPLACE WITH'-'  AND [TAX RATE IN VAR] COLUMN IS NULL THEN REPLACED WITH 0%
		 SELECT DT12.DocType,DT12.DocDate,DT12.[Doc Ref No],DT12.DocNo,DT12.Entity,ISNULL(DT12.DocDescription,'-') AS DocDescription,DT12.[Tax Code],DT12.[TAX RATE IN VAR],
					   CASE WHEN [Tax Code]='TX' THEN BaseDebit ELSE CONVERT(MONEY,'0') END AS [TX_GST],--GST AMOUNTS STARTING
					   CASE WHEN [Tax Code]='ZP' THEN BaseDebit ELSE CONVERT(MONEY,'0') END AS [ZP_GST],
					   CASE WHEN [Tax Code]='IM' THEN BaseDebit ELSE CONVERT(MONEY,'0') END AS [IM_GST],
					   CASE WHEN [Tax Code]='ME' THEN BaseDebit ELSE CONVERT(MONEY,'0') END AS [ME_GST],
					   CASE WHEN [Tax Code]='IGDS' THEN BaseDebit ELSE CONVERT(MONEY,'0') END AS [IGDS_GST],
					   CASE WHEN [Tax Code]='TX-ESS' THEN BaseDebit ELSE CONVERT(MONEY,'0') END AS [TX_ESS_GST],
					   CASE WHEN [Tax Code]='TX-N33' THEN BaseDebit ELSE CONVERT(MONEY,'0') END AS [TX_N33_GST],
					   CASE WHEN [Tax Code]='TX-RE' THEN BaseDebit ELSE CONVERT(MONEY,'0') END AS [TX_RE_GST],
					   BaseDebit AS TOTAL_GST,-- GST AMOUNTS ENDING
					   CASE WHEN [Tax Code]='TX' THEN [NET AMOUNT] ELSE CONVERT(MONEY,'0') END  AS [TX_NET],--NET AMOUNT STARTING
					   CASE WHEN [Tax Code]='ZP' THEN [NET AMOUNT] ELSE CONVERT(MONEY,'0') END AS [ZP_NET],
					   CASE WHEN [Tax Code]='IM' THEN [NET AMOUNT] ELSE CONVERT(MONEY,'0') END  AS [IM_NET],
					   CASE WHEN [Tax Code]='ME' THEN [NET AMOUNT] ELSE CONVERT(MONEY,'0') END AS [ME_NET],
					   CASE WHEN [Tax Code]='IGDS' THEN [NET AMOUNT] ELSE CONVERT(MONEY,'0') END  AS [IGDS_NET],
					   CASE WHEN [Tax Code]='TX-ESS' THEN [NET AMOUNT] ELSE CONVERT(MONEY,'0') END  AS [TX_ESS_NET],
					   CASE WHEN [Tax Code]='TX-N33' THEN [NET AMOUNT] ELSE CONVERT(MONEY,'0') END  AS [TX_N33_NET],
					   CASE WHEN [Tax Code]='TX-RE' THEN [NET AMOUNT] ELSE CONVERT(MONEY,'0') END  AS [TX_RE_NET],
					   [NET AMOUNT] AS TOTAL_NET,-- NET AMOUNT ENDING
					   Case When [NET AMOUNT]<0 THEN BaseDebit*(-1) ELSE BaseDebit END+[NET AMOUNT] AS [Gross Amount],
					   COA,[Account Type],
					   /*1 AS RECORDER,*/
					   [Service Comapany],DocumentId,DT12.ServiceCompanyId,DT12.DocSubType
		FROM
		(   
	
		--STEP3-- JOINING DT11 AND DT13
					SELECT DT11.DocType,DT11.DocDate,DT11.[Doc Ref No],DT11.DocNo,DT11.Entity,DT11.DocDescription,DT11.[Tax Code],DT11.[TAX RATE IN VAR],DT11.COA,DT11.[Account Type],DT11.[Net Amount],DT11.[Service Comapany],DT13.BaseDebit
					,DT11.DocumentId,DT11.ServiceCompanyId,DT11.DocSubType
					FROM
					(

						 --STEP1:GETTING RECORDS FOR 'TX','ZP','IM','ME','IGDS','TX-ESS','TX-N33','TX-RE' TAXCODES WITH ISTAX<>1 FOR MANUAL JV's
						 -- HERE WE GET NETAMOUNT FROM BASECREDIT OF JOURNALDETAIL
		
		SELECT      JD.DocType,JD.DocDate,JD.SystemRefNo AS [Doc Ref No],JD.DocNo,E.Name AS Entity,
						         --    CASE WHEN JD.DocType='Bill' THEN JD.DocDescription
									      --WHEN  JD.DocType='Cash Payment' THEN JD.AccountDescription END AS DocDescription
									  Case when J.DocType<>'Journal' then J.DocumentDescription when J.DocType='Journal' then
						              Case when J.DocSubType IN ('Opening Balance','Opening Bal') then 
								      Case when Jd.AccountDescription is null then J.DocumentDescription 
									  Else Jd.AccountDescription  end
								      When J.DocSubType NOT IN ('Opening Balance','Opening Bal') then J.DocumentDescription
							          End end as DocDescription,
									 JD.TaxId,TC.Code AS [Tax Code],JD.TaxRate,CONVERT(VARCHAR(100),JD.TaxRate)+''+'%' AS [TAX RATE IN VAR],
									 COA.Name AS COA,ACT.Name AS [Account Type],
									 case when JD.BaseCurrency=JD.DocCurrency 
                                          and JD.BaseDebit is null then IsNull(JD.DocDebit,0) else ISNUll(JD.BaseDebit,0) end- case when JD.BaseCurrency=JD.DocCurrency 
                                          and JD.BaseCredit is null then ISNULL(JD.DocCredit,0) else ISNULL(JD.BaseCredit,0) END
									 --Isnull(JD.BaseDebit,0)-Isnull(JD.BaseCredit,0) 
									 as [Net Amount],SC.Name AS [Service Comapany],jd.JournalId,JD.DocumentId,JD.DocumentDetailId,JD.Id AS JournalDetailId,JD.ServiceCompanyId,JD.DocSubType
						FROM         Bean.JournalDetail AS JD
						INNER JOIN   Bean.Journal AS J ON J.Id=JD.JournalId
						INNER JOIN   Bean.ChartOfAccount AS COA ON COA.Id=JD.COAId
						INNER JOIN   Bean.AccountType AS ACT ON ACT.Id=COA.AccountTypeId
					    LEFT  JOIN   Bean.Entity AS E ON E.Id=JD.EntityId
						INNER JOIN   Bean.TaxCode AS TC ON TC.Id=JD.TaxId
						INNER JOIN   Common.Company AS SC ON SC.Id=JD.ServiceCompanyId
						WHERE        COA.CompanyId=@CompanyValue AND JD.PostingDate BETWEEN @FromDate AND @ToDate
									 AND JD.DocType IN ('Journal')  
									 AND JD.IsTax is null AND J.DocumentState <> 'Void' 
									 AND DocumentDetailId='00000000-0000-0000-0000-000000000000'
									 AND TC.Code in ('TX','ZP','IM','ME','IGDS','TX-ESS','TX-N33','TX-RE')
) AS DT11

					INNER JOIN
					(
						--STEP2: GETTING RECORDS  'TX','ZP','IM','ME','IGDS','TX-ESS','TX-N33','TX-RE' TAXCODES WITH ISTAX=1 FOR MANUAL JV's 
						-- HERE WE GET BASEADEBIT




			SELECT      --Isnull(JD.BaseDebit,0)-Isnull(jd.BaseCredit,0) 
			--JD.BaseTaxAmount 
			Isnull(JD.BaseTaxDebit,0)-Isnull(jd.BaseTaxCredit,0)  as BaseDebit,jd.JournalId,JD.DocumentId,JD.DocumentDetailId,SC.Name AS [Service Comapany],Jd.ServiceCompanyId,JD.DocSubType
						FROM         Bean.JournalDetail AS JD
						INNER JOIN   Bean.Journal AS J ON J.Id=JD.JournalId

						INNER JOIN   Bean.ChartOfAccount AS COA ON COA.Id=JD.COAId
						--INNER JOIN   Bean.AccountType AS ACT ON ACT.Id=COA.AccountTypeId
						Left JOIN   Bean.Entity AS E ON E.Id=JD.EntityId
						INNER JOIN   Bean.TaxCode AS TC ON TC.Id=JD.TaxId
						INNER JOIN   Common.Company AS SC ON SC.Id=JD.ServiceCompanyId
						WHERE        COA.CompanyId=@CompanyValue AND JD.PostingDate BETWEEN @FromDate AND @ToDate
									 --AND JD.DocType IN ('Journal') 
									 --AND JD.IsTax<>1 AND J.DocumentState <> 'Void' AND JD.TaxId IS NOT NULL
									 --AND DocumentDetailId<>'00000000-0000-0000-0000-000000000000'
								  --   AND TC.Code in ('TX','ZP','IM','ME','IGDS','TX-ESS','TX-N33','TX-RE')
								  AND JD.DocType IN ('Journal') 
									 AND (JD.IsTax<>1 OR JD.IsTax IS NULL) AND J.DocumentState <> 'Void' --AND JD.TaxId IS NOT NULL
									 AND DocumentDetailId='00000000-0000-0000-0000-000000000000'
								     AND TC.Code in ('TX','ZP','IM','ME','IGDS','TX-ESS','TX-N33','TX-RE')

) AS DT13 ON DT11.JournalId=DT13.JournalId AND --DT11.DocumentId=DT13.DocumentId AND
 --DT11.JournalDetailId=DT13.DocumentDetailId 
 DT11.JournalId=DT13.DocumentId 
 AND DT11.[Service Comapany]=DT13.[Service Comapany]
					-- END OF STEP3
		)AS DT12
		WHERE DT12.[Service Comapany]=@ServiceCompany
	)
	AS DT13
	GROUP BY DocType,DocDate,[Doc Ref No],DocNo,Entity,DocDescription,[Tax Code],[TAX RATE IN VAR],COA,[Account Type],/*RECORDER,*/[Service Comapany],DocumentId,ServiceCompanyid,DocSubType
) AS DT14
--ENDING POINT OF 'TX','ZP','IM','ME','IGDS','TX-ESS','TX-N33','TX-RE' FOR MANUAL JV'S

/****************************ENDING OF STEP1********************************************/

/*** ORDERING OF FINAL RESULT SET ***/

ORDER BY /*RECORDER,*/[Account Type],COA,DocDate


END
GO
