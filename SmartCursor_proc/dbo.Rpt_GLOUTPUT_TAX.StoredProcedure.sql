USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[Rpt_GLOUTPUT_TAX]    Script Date: 16-12-2024 9.20.11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

--select * From Bean.TaxCode

--EXEC Rpt_GLOUTPUT_TAX @CompanyValue=258,@FromDate='2017-04-14 11:02:06.643',@ToDate='2019-01-28 11:02:06.643',@ServiceCompany='Texas Instruments',@GSTNO='0417'
CREATE PROCEDURE [dbo].[Rpt_GLOUTPUT_TAX]
@CompanyValue VARCHAR(MAX),
@FromDate datetime,
@ToDate datetime,
@ServiceCompany varchar(max),
@GSTNO varchar(max)
AS
BEGIN
--Select * from Common.Company Where ParentId=1
--Declare @CompanyValue Int =1,@FromDate datetime='2019-01-01 00:00:00.000' ,@ToDate datetime = '2019-06-23 00:00:00.000',
--@ServiceCompany varchar(max) = 'Precursor Corporate Services Pte. Ltd.',@GSTNO varchar(max)='0417'
  

Declare @CompanyId Int 
select @CompanyId = dbo.DecryptCompanyValue(@CompanyValue)  

 /****************************STARTING OF STEP1********************************************/
 -- STARTING OF ES33,ESN33,OS
-- START OF DT5
-- HERE WE REPLACED ALL GST RELATED COLUMNS TO NULL AND ALSO NET AMOUNTS TO NULL WHERE TAXCODE IN OS,ES33,ESN33
SELECT DT5.DocType,DT5.DocDate,DT5.[Doc Ref No],DT5.DocNo,DT5.Entity,DT5.DocDescription,DT5.[Tax Code],NULL AS [TAX RATE IN VAR],
       NULL AS SR_GST,
	   NULL AS ZR_GST,
	   NULL AS ES33_GST,
	   NULL AS ESN33_GST,
	   NULL AS DS_GST,
	   NULL AS OS_GST,
	   NULL AS TOTAL_GST,
	   NULL AS SR_NET,
	   NULL AS ZR_NET,
	   CASE WHEN DT5.[Tax Code]='ES33' THEN DT5.ES33_NET END AS ES33_NET,
	   CASE WHEN DT5.[Tax Code]='ESN33' THEN DT5.ESN33_NET END AS ESN33_NET,
	   NULL AS DS_NET,
	   CASE WHEN DT5.[Tax Code]='OS' THEN DT5.OS_NET END AS OS_NET,
	   DT5.TOTAL_NET,DT5.[Gross Amount],DT5.COA,DT5.[Account Type],/*DT5.RECORDER,*/DT5.[Service Comapany],DocumentId,ServiceCompanyId,DocSubType
FROM
(
 
		--STEP 5:
		-- START OF DT4.
		-- HERE, WE ARE GROUPING THE RECORDS BASED ON THE COLUMNS  DocType,DocDate,[Doc Ref No],DocNo,Entity,DocDescription,[Tax Code],[TAX RATE IN VAR],COA,[Account Type],RECORDER,[Service Comapany]
	
		SELECT DT4.DocType,DT4.DocDate,DT4.[Doc Ref No],DT4.DocNo,DT4.Entity,DT4.DocDescription,DT4.[Tax Code],DT4.[TAX RATE IN VAR],SUM(DT4.SR_GST) AS SR_GST,SUM(DT4.ZR_GST) AS ZR_GST,SUM(DT4.ES33_GST) AS ES33_GST,SUM(DT4.ESN33_GST) AS ESN33_GST,SUM(DT4.DS_GST) AS DS_GST,SUM(DT4.OS_GST) AS OS_GST,SUM(DT4.TOTAL_GST) AS TOTAL_GST,
			   SUM(DT4.SR_NET) AS SR_NET ,SUM(DT4.ZR_NET) AS ZR_NET,SUM(DT4.ES33_NET) AS ES33_NET,SUM(DT4.ESN33_NET) AS ESN33_NET,SUM(DT4.DS_NET) AS DS_NET,SUM(DT4.OS_NET) AS OS_NET,SUM(DT4.TOTAL_NET) AS TOTAL_NET,
			   SUM(DT4.[Gross Amount]) AS [Gross Amount],DT4.COA,DT4.[Account Type],/*DT4.RECORDER,*/DT4.[Service Comapany],DT4.DocumentId,DT4.ServiceCompanyId,DT4.DocSubType
		FROM
		(

		--STEP 4: STARTING OF DT3
		-- IF DOCDESCRIPTION IS NULL THEN REPLACE WITH'-'  AND [TAX RATE IN VAR] COLUMN IS NULL THEN REPLACED WITH 0%
		-- HERE SETTING GST,NET RELATED AMOUNTS TO 0.00 IN MONEY FORMAT EXCEPT FOR TAX CODE IN OS,ES33, AND ESN33

		SELECT DT3.DocType,DT3.DocDate,DT3.[Doc Ref No],DT3.DocNo,DT3.Entity,ISNULL(DT3.DocDescription,'-') AS DocDescription, DT3.[Tax Code],ISNULL(DT3.[TAX RATE IN VAR],'0%') AS [TAX RATE IN VAR],
							   CONVERT(MONEY,'0') AS [SR_GST],--SGT AMOUNTS STARTING
							   CONVERT(MONEY,'0') AS [ZR_GST],
							   CASE WHEN [Tax Code]='ES33' THEN BaseCredit ELSE CONVERT(MONEY,'0') END AS ES33_GST,
							   CASE WHEN [Tax Code]='ESN33' THEN BaseCredit ELSE CONVERT(MONEY,'0') END AS ESN33_GST,
							   CONVERT(MONEY,'0') AS [DS_GST],
							   CASE WHEN [Tax Code]='OS' THEN BaseCredit ELSE CONVERT(MONEY,'0') END AS OS_GST,
							   BaseCredit AS TOTAL_GST,-- GST AMOUNTS ENDING
							   CONVERT(MONEY,'0') AS [SR_NET],--NET AMOUNT STARTING
							   CONVERT(MONEY,'0') AS [ZR_NET],
							   CASE WHEN [Tax Code]='ES33' THEN [NET AMOUNT] ELSE CONVERT(MONEY,'0') END AS ES33_NET,
							   CASE WHEN [Tax Code]='ESN33' THEN [NET AMOUNT] ELSE CONVERT(MONEY,'0') END AS ESN33_NET,
							   CONVERT(MONEY,'0') AS [DS_NET],
							   CASE WHEN [Tax Code]='OS' THEN [NET AMOUNT] ELSE CONVERT(MONEY,'0') END AS OS_NET,
							   [NET AMOUNT] AS TOTAL_NET,-- NET AMOUNT ENDING
							   Case When [NET AMOUNT]<0 then BaseCredit*(-1) ELSE BaseCredit END +[NET AMOUNT] AS [Gross Amount],
							   COA,[Account Type],
							   --2 AS RECORDER,
							   [Service Comapany],DocumentId,DT3.ServiceCompanyId,DT3.DocSubType
		FROM
		(

			--STEP3-- JOINING DT1 AND DT2
			SELECT DT1.DocType,DT1.DocDate,DT1.[Doc Ref No],DT1.DocNo,DT1.Entity,DT1.DocDescription,DT1.[Tax Code],DT1.[TAX RATE IN VAR],DT1.COA,DT1.[Account Type],DT1.[Net Amount],DT1.[Service Comapany],DT2.BaseCredit
			       ,DT1.DocumentId,DT1.ServiceCompanyId,DT1.DocSubType
			FROM
			(

				 --STEP1:GETTING RECORDS FOR 'OS','ES33','ESN33' TAXCODES WITH ISTAX<>1 
				 -- HERE WE GET NETAMOUNT FROM BASECREDIT OF JOURNALDETAIL
				SELECT       JD.DocType,JD.DocDate,JD.SystemRefNo AS [Doc Ref No],JD.DocNo,E.Name AS Entity,
				Case when J.DocType<>'Journal' then J.DocumentDescription when J.DocType='Journal' then
						              Case when J.DocSubType IN ('Opening Balance','Opening Bal') then 
								      Case when Jd.AccountDescription is null then J.DocumentDescription 
									  Else Jd.AccountDescription  end
								      When J.DocSubType NOT IN ('Opening Balance','Opening Bal') then J.DocumentDescription
							          End end as DocDescription,
				      --       CASE WHEN JD.DocType='Debit note' THEN JD.AccountDescription
							   --   WHEN JD.DocType='Invoice' THEN JD.ItemDescription
								  --WHEN JD.DocType='Cash Sale' THEN JD.ItemDescription END AS DocDescription,
							 JD.TaxId,TC.Code AS [Tax Code],JD.TaxRate,CONVERT(VARCHAR(100),JD.TaxRate)+''+'%' AS [TAX RATE IN VAR],
							 COA.Name AS COA,ACT.Name AS [Account Type],
							 --Case When ACT.Class='Income' Then ISNULL(JD.BaseCredit,0)-ISNULL(JD.BaseDebit,0) Else ISNULL(JD.BaseDebit,0)-ISNULL(JD.BaseCredit,0) END 
							 ISNULL(JD.BaseCredit,0)-ISNULL(JD.BaseDebit,0) as [Net Amount],SC.Name AS [Service Comapany],jd.JournalId,JD.DocumentId,JD.DocumentDetailId
							 ,JD.ServiceCompanyId,JD.DocSubType
				FROM         Bean.JournalDetail AS JD
				INNER JOIN   Bean.Journal AS J ON J.Id=JD.JournalId
				INNER JOIN   Bean.ChartOfAccount AS COA ON COA.Id=JD.COAId
				INNER JOIN   Bean.AccountType AS ACT ON ACT.Id=COA.AccountTypeId
				LEFT JOIN   Bean.Entity AS E ON E.Id=JD.EntityId
				INNER JOIN   Bean.TaxCode AS TC ON TC.Id=JD.TaxId
				INNER JOIN   Common.Company AS SC ON SC.Id=JD.ServiceCompanyId
				WHERE        COA.CompanyId=@CompanyId AND JD.PostingDate BETWEEN @FromDate AND @ToDate
							 --AND JD.DocType IN ('Debit note','Invoice','Cash Sale') 
							 AND JD.DocType  NOT IN  ('Journal') 
							 AND JD.IsTax<>1 AND J.DocumentState <> 'Void' 
							 AND DocumentDetailId<>'00000000-0000-0000-0000-000000000000'
							 AND TC.Code in ('OS','ES33','ESN33')
			) AS DT1

			INNER JOIN
			(
				--STEP2: GETTING RECORDS  'OS','ES33','ESN33' TAXCODES WITH ISTAX=1 
				-- HERE WE GET BASEADEBIT
				SELECT       --Case When ACT.Class='Income' Then ISNULL(JD.BaseCredit,0)-ISNULL(JD.BaseDebit,0) Else ISNULL(JD.BaseDebit,0)-ISNULL(JD.BaseCredit,0) END 
				JD.BaseTaxAmount BaseCredit,jd.JournalId,JD.DocumentId,JD.DocumentDetailId,SC.Name AS [Service Comapany],JD.ServiceCompanyId,JD.DocSubType
				FROM         Bean.JournalDetail AS JD
				INNER JOIN   Bean.Journal AS J ON J.Id=JD.JournalId
				INNER JOIN   Bean.ChartOfAccount AS COA ON COA.Id=JD.COAId
				INNER JOIN   Bean.AccountType AS ACT ON ACT.Id=COA.AccountTypeId
				LEFT JOIN   Bean.Entity AS E ON E.Id=JD.EntityId
				INNER JOIN   Bean.TaxCode AS TC ON TC.Id=JD.TaxId
				INNER JOIN   Common.Company AS SC ON SC.Id=JD.ServiceCompanyId
				WHERE        COA.CompanyId=@CompanyId AND JD.PostingDate BETWEEN @FromDate AND @ToDate
				

							 --AND JD.DocType IN ('Debit note','Invoice','Cash Sale') 
							 AND JD.DocType  NOT IN  ('Journal') 
							 AND JD.IsTax<>1  AND J.DocumentState <> 'Void' 
							 AND DocumentDetailId<>'00000000-0000-0000-0000-000000000000'
							 AND TC.Code in ('OS','ES33','ESN33') AND JD.TaxId IS NOT NULL 
							 --Group By jd.JournalId,JD.DocumentId,JD.DocumentDetailId,SC.Name,JD.ServiceCompanyId,JD.DocSubType
			) AS DT2 ON DT1.JournalId=DT2.JournalId AND DT1.DocumentId=DT2.DocumentId AND DT1.DocumentDetailId=DT2.DocumentDetailId AND DT1.[Service Comapany]=DT2.[Service Comapany]
			-- END OF STEP3
		)AS DT3
		WHERE DT3.[Service Comapany]=@ServiceCompany
		) AS DT4
		GROUP BY DocType,DocDate,[Doc Ref No],DocNo,Entity,DocDescription,[Tax Code],[TAX RATE IN VAR],COA,[Account Type],/*RECORDER,*/[Service Comapany],DocumentId,ServiceCompanyId,DocSubType
	-- ENDING OF DT4
) AS DT5
-- ENDING OF ES33,ESN33,OS 

/****************************ENDING OF STEP1********************************************/

UNION ALL

 
 /****************************STARTING OF STEP2********************************************/
 -- STARTING OF 'SR','ZR','DS' FOR DEBIT NOTE
-- START OF DT10
-- HERE WE REPLACED ALL GST RELATED COLUMNS TO NULL AND ALSO NET AMOUNTS TO NULL WHERE TAXCODE IN 'SR','ZR','DS'
SELECT DT10.DocType,DT10.DocDate,DT10.[Doc Ref No],DT10.DocNo,DT10.Entity,DT10.DocDescription,DT10.[Tax Code],DT10.[TAX RATE IN VAR],
       CASE WHEN DT10.[Tax Code]='SR' THEN Case When DT10.SR_NET<0 then DT10.SR_GST*(-1) Else DT10.SR_GST END END AS SR_GST,
	   CASE WHEN DT10.[Tax Code]='ZR' THEN Case When DT10.ZR_NET<0 then DT10.ZR_GST*(-1) Else DT10.ZR_GST END END AS ZR_GST,
	   NULL AS ES33_GST,
	   NULL AS ESN33_GST,
	   CASE WHEN DT10.[Tax Code]='DS' THEN Case When DT10.DS_NET<0 Then DT10.DS_GST*(-1) Else DT10.DS_GST END END AS DS_GST,
	   NULL AS OS_GST,
	   Case When TOTAL_NET<0 then TOTAL_GST*(-1) Else TOTAL_GST END AS TOTAL_GST,
	   CASE WHEN DT10.[Tax Code]='SR' THEN DT10.SR_NET END AS SR_NET,
	   CASE WHEN DT10.[Tax Code]='ZR' THEN DT10.ZR_NET END AS ZR_NET,
	   NULL AS ES33_NET,
	   NULL AS ESN33_NET,
	   CASE WHEN DT10.[Tax Code]='DS' THEN DT10.DS_NET END AS DS_NET,
	   NULL AS OS_NET,
	   TOTAL_NET,[Gross Amount],COA,[Account Type],/*RECORDER,*/[Service Comapany],DocumentId,DT10.ServiceCompanyId,DT10.DocSubType
FROM
(
 
		--STEP 5:
		-- START OF DT9.
		-- HERE, WE ARE GROUPING THE RECORDS BASED ON THE COLUMNS  DocType,DocDate,[Doc Ref No],DocNo,Entity,DocDescription,[Tax Code],[TAX RATE IN VAR],COA,[Account Type],RECORDER,[Service Comapany]
	
		SELECT DT9.DocType,DT9.DocDate,DT9.[Doc Ref No],DT9.DocNo,DT9.Entity,DT9.DocDescription,DT9.[Tax Code],DT9.[TAX RATE IN VAR],SUM(DT9.SR_GST) AS SR_GST,SUM(DT9.ZR_GST) AS ZR_GST,SUM(DT9.ES33_GST) AS ES33_GST,SUM(DT9.ESN33_GST) AS ESN33_GST,SUM(DT9.DS_GST) AS DS_GST,SUM(DT9.OS_GST) AS OS_GST,SUM(DT9.TOTAL_GST) AS TOTAL_GST,
			   SUM(DT9.SR_NET) AS SR_NET ,SUM(DT9.ZR_NET) AS ZR_NET,SUM(DT9.ES33_NET) AS ES33_NET,SUM(DT9.ESN33_NET) AS ESN33_NET,SUM(DT9.DS_NET) AS DS_NET,SUM(DT9.OS_NET) AS OS_NET,SUM(DT9.TOTAL_NET) AS TOTAL_NET,
			   SUM(DT9.[Gross Amount]) AS [Gross Amount],DT9.COA,DT9.[Account Type],/*DT9.RECORDER,*/DT9.[Service Comapany],DT9.DocumentId,DT9.ServiceCompanyId,DT9.DocSubType
		FROM
		(

		--STEP 4: STARTING OF DT8
		-- IF DOCDESCRIPTION IS NULL THEN REPLACE WITH'-'  AND [TAX RATE IN VAR] COLUMN IS NULL THEN REPLACED WITH 0%
		-- HERE SETTING GST,NET RELATED AMOUNTS TO 0.00 IN MONEY FORMAT EXCEPT FOR TAX CODE IN 'SR','ZR','DS'

		SELECT DT8.DocType,DT8.DocDate,DT8.[Doc Ref No],DT8.DocNo,DT8.Entity,ISNULL(DT8.DocDescription,'-') AS DocDescription, DT8.[Tax Code],ISNULL(DT8.[TAX RATE IN VAR],'0%') AS [TAX RATE IN VAR],
			   CASE WHEN [Tax Code]='SR' THEN BaseCredit ELSE CONVERT(MONEY,'0') END AS [SR_GST],--SGT AMOUNTS STARTING
			   CASE WHEN [Tax Code]='ZR' THEN BaseCredit ELSE CONVERT(MONEY,'0') END AS [ZR_GST],
			   CONVERT(MONEY,'0') AS ES33_GST,
			   CONVERT(MONEY,'0') AS ESN33_GST,
			   CASE WHEN [Tax Code]='DS' THEN BaseCredit ELSE CONVERT(MONEY,'0') END AS [DS_GST],
			   CONVERT(MONEY,'0') AS OS_GST,
			   BaseCredit AS TOTAL_GST,-- GST AMOUNTS ENDING
			   CASE WHEN [Tax Code]='SR' THEN [NET AMOUNT] ELSE CONVERT(MONEY,'0') END  AS [SR_NET],--NET AMOUNT STARTING
			   CASE WHEN [Tax Code]='ZR' THEN [NET AMOUNT] ELSE CONVERT(MONEY,'0') END AS [ZR_NET],
			   CONVERT(MONEY,'0') AS ES33_NET,
			   CONVERT(MONEY,'0') AS ESN33_NET,
			   CASE WHEN [Tax Code]='DS' THEN [NET AMOUNT] ELSE CONVERT(MONEY,'0') END AS [DS_NET],
			   CONVERT(MONEY,'0') AS OS_NET,
			   [NET AMOUNT] AS TOTAL_NET,-- NET AMOUNT ENDING
			   Case When [NET AMOUNT]<0 then BaseCredit*(-1) ELSE BaseCredit END+[NET AMOUNT] AS [Gross Amount],
			   COA,[Account Type],
			   /*2 AS RECORDER,*/[Service Comapany],DocumentId,DT8.ServiceCompanyId,DT8.DocSubType
		FROM
		(

			--STEP3-- JOINING DT6 AND DT7
			SELECT DT6.DocType,DT6.DocDate,DT6.[Doc Ref No],DT6.DocNo,DT6.Entity,DT6.DocDescription,DT6.[Tax Code],DT6.[TAX RATE IN VAR],DT6.COA,DT6.[Account Type],DT6.[Net Amount],DT6.[Service Comapany],DT7.BaseCredit
			      ,DT6.DocumentId,DT6.ServiceCompanyId,DT6.DocSubType
			FROM
			(

				 --STEP1:GETTING RECORDS FOR 'SR','ZR','DS' TAXCODES WITH ISTAX<>1 
				 -- HERE WE GET NETAMOUNT FROM BASECREDIT OF JOURNALDETAIL
				SELECT       JD.DocType,JD.DocDate,JD.SystemRefNo AS [Doc Ref No],JD.DocNo,E.Name AS Entity,
				Case when J.DocType<>'Journal' then J.DocumentDescription when J.DocType='Journal' then
						              Case when J.DocSubType IN ('Opening Balance','Opening Bal') then 
								      Case when Jd.AccountDescription is null then J.DocumentDescription 
									  Else Jd.AccountDescription  end
								      When J.DocSubType NOT IN ('Opening Balance','Opening Bal') then J.DocumentDescription
							          End end as DocDescription,
				      --       CASE WHEN JD.DocType='Debit note' THEN JD.AccountDescription
							   --   WHEN JD.DocType='Invoice' THEN JD.ItemDescription
								  --WHEN JD.DocType='Cash Sale' THEN JD.ItemDescription END AS DocDescription,
							 JD.TaxId,TC.Code AS [Tax Code],JD.TaxRate,CONVERT(VARCHAR(100),JD.TaxRate)+''+'%' AS [TAX RATE IN VAR],
							 COA.Name AS COA,ACT.Name AS [Account Type],
							-- Case When ACT.Class='Income' Then ISNULL(JD.BaseCredit,0)-ISNULL(JD.BaseDebit,0) Else ISNULL(JD.BaseDebit,0)-ISNULL(JD.BaseCredit,0) END 
							 
							 ISNULL(JD.BaseCredit,0)-ISNULL(JD.BaseDebit,0) as [Net Amount],SC.Name AS [Service Comapany],jd.JournalId,JD.DocumentId,JD.DocumentDetailId,JD.ServiceCompanyId,JD.DocSubType
				FROM         Bean.JournalDetail AS JD
				INNER JOIN   Bean.Journal AS J ON J.Id=JD.JournalId
				INNER JOIN   Bean.ChartOfAccount AS COA ON COA.Id=JD.COAId
				INNER JOIN   Bean.AccountType AS ACT ON ACT.Id=COA.AccountTypeId
				Left JOIN   Bean.Entity AS E ON E.Id=JD.EntityId
				INNER JOIN   Bean.TaxCode AS TC ON TC.Id=JD.TaxId
				INNER JOIN   Common.Company AS SC ON SC.Id=JD.ServiceCompanyId
				WHERE        COA.CompanyId=@CompanyId AND JD.PostingDate BETWEEN @FromDate AND @ToDate
							 --AND JD.DocType IN ('Debit note','Invoice','Cash Sale') 
							 AND JD.DocType  NOT IN  ('Journal') 
							 AND JD.IsTax<>1 AND J.DocumentState <> 'Void' 
							 AND DocumentDetailId<>'00000000-0000-0000-0000-000000000000'
							 AND TC.Code in ('SR','ZR','DS')
			) AS DT6

			INNER JOIN
			(
				--STEP2: GETTING RECORDS  'SR','ZR','DS' TAXCODES WITH ISTAX=1 
				-- HERE WE GET BASEADEBIT
				SELECT       --Case When ACT.Class='Income' Then ISNULL(JD.BaseCredit,0)-ISNULL(JD.BaseDebit,0) Else ISNULL(JD.BaseDebit,0)-ISNULL(JD.BaseCredit,0) END 
				JD.BaseTaxAmount BaseCredit,jd.JournalId,JD.DocumentId,JD.DocumentDetailId,SC.Name AS [Service Comapany],JD.ServiceCompanyId,JD.DocSubType
				FROM         Bean.JournalDetail AS JD
				INNER JOIN   Bean.Journal AS J ON J.Id=JD.JournalId
				INNER JOIN   Bean.ChartOfAccount AS COA ON COA.Id=JD.COAId
				INNER JOIN   Bean.AccountType AS ACT ON ACT.Id=COA.AccountTypeId
				Left JOIN   Bean.Entity AS E ON E.Id=JD.EntityId
				INNER JOIN   Bean.TaxCode AS TC ON TC.Id=JD.TaxId
				INNER JOIN   Common.Company AS SC ON SC.Id=JD.ServiceCompanyId
				WHERE        COA.CompanyId=@CompanyId AND JD.PostingDate BETWEEN @FromDate AND @ToDate
				

							-- AND JD.DocType IN ('Debit note','Invoice','Cash Sale') 
							AND JD.DocType  NOT IN  ('Journal') 
							 AND JD.IsTax<>1 AND J.DocumentState <> 'Void' 
							 AND DocumentDetailId<>'00000000-0000-0000-0000-000000000000'
							 AND TC.Code in ('SR','ZR','DS') AND JD.TaxId IS NOT NULL
							 --Group By jd.JournalId,JD.DocumentId,JD.DocumentDetailId,SC.Name,JD.ServiceCompanyId,JD.DocSubType
			) AS DT7 ON DT6.JournalId=DT7.JournalId AND DT6.DocumentId=DT7.DocumentId AND DT6.DocumentDetailId=DT7.DocumentDetailId AND DT6.[Service Comapany]=DT7.[Service Comapany]
			-- END OF STEP3
		)AS DT8
		WHERE DT8.[Service Comapany]=@ServiceCompany
		) AS DT9
		GROUP BY DocType,DocDate,[Doc Ref No],DocNo,Entity,DocDescription,[Tax Code],[TAX RATE IN VAR],COA,[Account Type],/*RECORDER,*/[Service Comapany],DocumentId,ServiceCompanyId,DocSubType
	-- ENDING OF DT9
) AS DT10
-- ENDING OF 'SR','ZR','DS' FOR DEBIT NOTE

/****************************ENDING OF STEP2********************************************/

/*** ORDERING OF FINAL RESULT SET ***/
--ORDER BY RECORDER,[Account Type],COA,DocDate

UNION ALL
/****************************STARTNG OF STEP3********************************************/

SELECT DT13.DocType,DT13.DocDate,DT13.[Doc Ref No],DT13.DocNo,DT13.Entity,DT13.DocDescription,DT13.[Tax Code],NULL AS [TAX RATE IN VAR],
       NULL AS SR_GST,
	   NULL AS ZR_GST,
	   NULL AS ES33_GST,
	   NULL AS ESN33_GST,
	   NULL AS DS_GST,
	   NULL AS OS_GST,
	   NULL AS TOTAL_GST,
	   NULL AS SR_NET,
	   NULL AS ZR_NET,
	   CASE WHEN DT13.[Tax Code]='ES33' THEN DT13.ES33_NET END AS ES33_NET,
	   CASE WHEN DT13.[Tax Code]='ESN33' THEN DT13.ESN33_NET END AS ESN33_NET,
	   NULL AS DS_NET,
	   CASE WHEN DT13.[Tax Code]='OS' THEN DT13.OS_NET END AS OS_NET,
	   DT13.TOTAL_NET,DT13.[Gross Amount],DT13.COA,DT13.[Account Type],/*DT13.RECORDER,*/DT13.[Service Comapany],DT13.DocumentId,DT13.ServiceCompanyId,DT13.DocSubType
FROM
(
 
		--STEP 5:
		-- START OF DT12.
		-- HERE, WE ARE GROUPING THE RECORDS BASED ON THE COLUMNS  DocType,DocDate,[Doc Ref No],DocNo,Entity,DocDescription,[Tax Code],[TAX RATE IN VAR],COA,[Account Type],RECORDER,[Service Comapany]
	
		SELECT DT12.DocType,DT12.DocDate,DT12.[Doc Ref No],DT12.DocNo,DT12.Entity,DT12.DocDescription,DT12.[Tax Code],DT12.[TAX RATE IN VAR],SUM(DT12.SR_GST) AS SR_GST,SUM(DT12.ZR_GST) AS ZR_GST,SUM(DT12.ES33_GST) AS ES33_GST,SUM(DT12.ESN33_GST) AS ESN33_GST,SUM(DT12.DS_GST) AS DS_GST,SUM(DT12.OS_GST) AS OS_GST,SUM(DT12.TOTAL_GST) AS TOTAL_GST,
			   SUM(DT12.SR_NET) AS SR_NET ,SUM(DT12.ZR_NET) AS ZR_NET,SUM(DT12.ES33_NET) AS ES33_NET,SUM(DT12.ESN33_NET) AS ESN33_NET,SUM(DT12.DS_NET) AS DS_NET,SUM(DT12.OS_NET) AS OS_NET,SUM(DT12.TOTAL_NET) AS TOTAL_NET,
			   SUM(DT12.[Gross Amount]) AS [Gross Amount],DT12.COA,DT12.[Account Type],/*DT12.RECORDER,*/DT12.[Service Comapany],DT12.DocumentId,DT12.ServiceCompanyId,DT12.DocSubType
		FROM
		(

		--STEP 4: STARTING OF DT11
		-- IF DOCDESCRIPTION IS NULL THEN REPLACE WITH'-'  AND [TAX RATE IN VAR] COLUMN IS NULL THEN REPLACED WITH 0%
		-- HERE SETTING GST,NET RELATED AMOUNTS TO 0.00 IN MONEY FORMAT EXCEPT FOR TAX CODE IN OS,ES33, AND ESN33

		SELECT DT11.DocType,DT11.DocDate,DT11.[Doc Ref No],DT11.DocNo,DT11.Entity,ISNULL(DT11.DocDescription,'-') AS DocDescription, DT11.[Tax Code],ISNULL(DT11.[TAX RATE IN VAR],'0%') AS [TAX RATE IN VAR],
							   CONVERT(MONEY,'0') AS [SR_GST],--SGT AMOUNTS STARTING
							   CONVERT(MONEY,'0') AS [ZR_GST],
							   CASE WHEN [Tax Code]='ES33' THEN BaseCredit ELSE CONVERT(MONEY,'0') END AS ES33_GST,
							   CASE WHEN [Tax Code]='ESN33' THEN BaseCredit ELSE CONVERT(MONEY,'0') END AS ESN33_GST,
							   CONVERT(MONEY,'0') AS [DS_GST],
							   CASE WHEN [Tax Code]='OS' THEN BaseCredit ELSE CONVERT(MONEY,'0') END AS OS_GST,
							   BaseCredit AS TOTAL_GST,-- GST AMOUNTS ENDING
							   CONVERT(MONEY,'0') AS [SR_NET],--NET AMOUNT STARTING
							   CONVERT(MONEY,'0') AS [ZR_NET],
							   CASE WHEN [Tax Code]='ES33' THEN [NET AMOUNT] ELSE CONVERT(MONEY,'0') END AS ES33_NET,
							   CASE WHEN [Tax Code]='ESN33' THEN [NET AMOUNT] ELSE CONVERT(MONEY,'0') END AS ESN33_NET,
							   CONVERT(MONEY,'0') AS [DS_NET],
							   CASE WHEN [Tax Code]='OS' THEN [NET AMOUNT] ELSE CONVERT(MONEY,'0') END AS OS_NET,
							   [NET AMOUNT] AS TOTAL_NET,-- NET AMOUNT ENDING
							   Case When [NET AMOUNT]<0 then BaseCredit*(-1) ELSE BaseCredit END+[NET AMOUNT] AS [Gross Amount],
							   COA,[Account Type],
							   --2 AS RECORDER,
							   [Service Comapany],DocumentId,DT11.ServiceCompanyId,DT11.DocSubType
		FROM
		(

			--STEP3-- JOINING DT20 AND DT19
			SELECT DT20.DocType,DT20.DocDate,DT20.[Doc Ref No],DT20.DocNo,DT20.Entity,DT20.DocDescription,DT20.[Tax Code],DT20.[TAX RATE IN VAR],DT20.COA,DT20.[Account Type],DT20.[Net Amount],DT20.[Service Comapany],DT19.BaseCredit
			,DT20.DocumentId,DT20.ServiceCompanyId,DT20.DocSubType
			FROM
			(

				 --STEP1:GETTING RECORDS FOR 'OS','ES33','ESN33' TAXCODES WITH ISTAX<>1 
				 -- HERE WE GET NETAMOUNT FROM BASECREDIT OF JOURNALDETAIL
				SELECT       JD.DocType,JD.DocDate,JD.SystemRefNo AS [Doc Ref No],JD.DocNo,E.Name AS Entity,
				Case when J.DocType<>'Journal' then J.DocumentDescription when J.DocType='Journal' then
						              Case when J.DocSubType IN ('Opening Balance','Opening Bal') then 
								      Case when Jd.AccountDescription is null then J.DocumentDescription 
									  Else Jd.AccountDescription  end
								      When J.DocSubType NOT IN ('Opening Balance','Opening Bal') then J.DocumentDescription
							          End end as DocDescription,
				      --       CASE WHEN JD.DocType='Debit note' THEN JD.AccountDescription
							   --   WHEN JD.DocType='Invoice' THEN JD.ItemDescription
								  --WHEN JD.DocType='Cash Sale' THEN JD.ItemDescription END AS DocDescription,
							 JD.TaxId,TC.Code AS [Tax Code],JD.TaxRate,CONVERT(VARCHAR(100),JD.TaxRate)+''+'%' AS [TAX RATE IN VAR],
							 COA.Name AS COA,ACT.Name AS [Account Type],
							 
							-- Case When  ACT.Class='Income' Then Coalesce(JD.BaseCredit,JD.DocCredit,0)- Coalesce(JD.BaseDebit,JD.DocDebit,0) Else Coalesce(JD.BaseDebit,JD.DocDebit,0) - Coalesce(JD.BaseCredit,JD.DocCredit,0) END
ISNULL(JD.BaseCredit,0)-ISNULL(JD.BaseDebit,0)
							 --case when JD.BaseCurrency=JD.DocCurrency 
        --                                  and JD.BaseDebit is null then IsNull(JD.DocDebit,0) else ISNUll(JD.BaseDebit,0) end- case when JD.BaseCurrency=JD.DocCurrency 
        --                                  and JD.BaseCredit is null then ISNULL(JD.DocCredit,0) else ISNULL(JD.BaseCredit,0) END
							 --ISNULL(JD.BaseDebit,0)-ISNULL(JD.BaseCredit,0) 
							 as [Net Amount],SC.Name AS [Service Comapany],jd.JournalId,JD.DocumentId,JD.DocumentDetailId,JD.ServiceCompanyId,Jd.DocSubType
				FROM         Bean.JournalDetail AS JD
				INNER JOIN   Bean.Journal AS J ON J.Id=JD.JournalId
				INNER JOIN   Bean.ChartOfAccount AS COA ON COA.Id=JD.COAId
				INNER JOIN   Bean.AccountType AS ACT ON ACT.Id=COA.AccountTypeId
				LEFT JOIN   Bean.Entity AS E ON E.Id=JD.EntityId
				INNER JOIN   Bean.TaxCode AS TC ON TC.Id=JD.TaxId
				INNER JOIN   Common.Company AS SC ON SC.Id=JD.ServiceCompanyId
				WHERE        COA.CompanyId=@CompanyId AND JD.PostingDate BETWEEN @FromDate AND @ToDate
							 --AND JD.DocType IN ('Debit note','Invoice','Cash Sale') 
							 AND JD.DocType  IN  ('Journal') 
							 --AND JD.IsTax<>1 
							 AND (JD.IsTax<>1 OR JD.IsTax IS NULL)
							 AND J.DocumentState <> 'Void' 
							 AND DocumentDetailId='00000000-0000-0000-0000-000000000000'
							 AND TC.Code in ('OS','ES33','ESN33')
			) AS DT20

			INNER JOIN
			(
				--STEP2: GETTING RECORDS  'OS','ES33','ESN33' TAXCODES WITH ISTAX=1 
				-- HERE WE GET BASEADEBIT
				SELECT       --Case When ACT.Class='Income' Then ISNULL(JD.BaseCredit,0)-ISNULL(JD.BaseDebit,0) Else ISNULL(JD.BaseDebit,0)-ISNULL(JD.BaseCredit,0) END 
				--JD.BaseTaxAmount
				Isnull(jd.BaseTaxCredit,0)-Isnull(JD.BaseTaxDebit,0) AS BaseCredit,jd.JournalId,
				JD.DocumentId,JD.DocumentDetailId,SC.Name AS [Service Comapany],JD.Id JournalDetailId,JD.ServiceCompanyId,Jd.DocSubType
				FROM         Bean.JournalDetail AS JD
				INNER JOIN   Bean.Journal AS J ON J.Id=JD.JournalId
				INNER JOIN   Bean.ChartOfAccount AS COA ON COA.Id=JD.COAId
				INNER JOIN   Bean.AccountType AS ACT ON ACT.Id=COA.AccountTypeId
				LEFT JOIN   Bean.Entity AS E ON E.Id=JD.EntityId
				INNER JOIN   Bean.TaxCode AS TC ON TC.Id=JD.TaxId
				INNER JOIN   Common.Company AS SC ON SC.Id=JD.ServiceCompanyId
				WHERE        COA.CompanyId=@CompanyId AND JD.PostingDate BETWEEN @FromDate AND @ToDate

							 --AND JD.DocType IN ('Debit note','Invoice','Cash Sale') 
							 AND JD.DocType  IN  ('Journal') 
							 --AND JD.IsTax<>1 
							 AND (JD.IsTax<>1 OR JD.IsTax IS NULL)
							 AND J.DocumentState <> 'Void' 
							 --AND DocumentDetailId<>'00000000-0000-0000-0000-000000000000'
							 AND DocumentDetailId='00000000-0000-0000-0000-000000000000'
							 AND TC.Code in ('OS','ES33','ESN33')  --AND JD.TaxId IS NOT NULL
							-- Group By jd.JournalId,JD.DocumentId,JD.DocumentDetailId,SC.Name,JD.Id,JD.ServiceCompanyId,Jd.DocSubType
			) AS DT19 ON DT20.JournalId=DT19.JournalId --AND DT1.DocumentId=DT19.DocumentId 
			AND 
			--DT19.JournalDetailId=DT20.DocumentDetailId 
			DT19.JournalId=DT20.DocumentId
			AND DT20.[Service Comapany]=DT19.[Service Comapany]
			-- END OF STEP3
		)AS DT11
		WHERE DT11.[Service Comapany]=@ServiceCompany
		) AS DT12
		GROUP BY DocType,DocDate,[Doc Ref No],DocNo,Entity,DocDescription,[Tax Code],[TAX RATE IN VAR],COA,[Account Type],/*RECORDER,*/[Service Comapany],DocumentId,ServiceCompanyId,DocSubType
	-- ENDING OF DT12
) AS DT13
-- ENDING OF ES33,ESN33,OS 

/****************************ENDING OF STEP3********************************************/

UNION ALL

 
 /****************************STARTING OF STEP4********************************************/
 -- STARTING OF 'SR','ZR','DS' FOR DEBIT NOTE
-- START OF DT18
-- HERE WE REPLACED ALL GST RELATED COLUMNS TO NULL AND ALSO NET AMOUNTS TO NULL WHERE TAXCODE IN 'SR','ZR','DS'
SELECT DT18.DocType,DT18.DocDate,DT18.[Doc Ref No],DT18.DocNo,DT18.Entity,DT18.DocDescription,DT18.[Tax Code],DT18.[TAX RATE IN VAR],
       CASE WHEN DT18.[Tax Code]='SR' THEN Case When DT18.SR_NET<0 then DT18.SR_GST*(-1) ELSE DT18.SR_GST END END AS SR_GST,
	   CASE WHEN DT18.[Tax Code]='ZR' THEN Case When DT18.ZR_NET<0 then DT18.ZR_GST*(-1) ELSE DT18.ZR_GST END END AS ZR_GST,
	   NULL AS ES33_GST,
	   NULL AS ESN33_GST,
	   CASE WHEN DT18.[Tax Code]='DS' THEN CASE WHEN DT18.DS_NET<0 then DT18.DS_GST*(-1) ELSE DT18.DS_GST END END AS DS_GST,
	   NULL AS OS_GST,
	   Case When TOTAL_NET<0 then TOTAL_GST*(-1) Else TOTAL_GST END AS TOTAL_GST,
	   CASE WHEN DT18.[Tax Code]='SR' THEN DT18.SR_NET END AS SR_NET,
	   CASE WHEN DT18.[Tax Code]='ZR' THEN DT18.ZR_NET END AS ZR_NET,
	   NULL AS ES33_NET,
	   NULL AS ESN33_NET,
	   CASE WHEN DT18.[Tax Code]='DS' THEN DT18.DS_NET END AS DS_NET,
	   NULL AS OS_NET,
	   TOTAL_NET,[Gross Amount],COA,[Account Type],/*RECORDER,*/[Service Comapany],DocumentId,DT18.ServiceCompanyId,DT18.DocSubType
FROM
(
 
		--STEP 5:
		-- START OF DT17.
		-- HERE, WE ARE GROUPING THE RECORDS BASED ON THE COLUMNS  DocType,DocDate,[Doc Ref No],DocNo,Entity,DocDescription,[Tax Code],[TAX RATE IN VAR],COA,[Account Type],RECORDER,[Service Comapany]
	
		SELECT DT17.DocType,DT17.DocDate,DT17.[Doc Ref No],DT17.DocNo,DT17.Entity,DT17.DocDescription,DT17.[Tax Code],DT17.[TAX RATE IN VAR],SUM(DT17.SR_GST) AS SR_GST,SUM(DT17.ZR_GST) AS ZR_GST,SUM(DT17.ES33_GST) AS ES33_GST,SUM(DT17.ESN33_GST) AS ESN33_GST,SUM(DT17.DS_GST) AS DS_GST,SUM(DT17.OS_GST) AS OS_GST,SUM(DT17.TOTAL_GST) AS TOTAL_GST,
			   SUM(DT17.SR_NET) AS SR_NET ,SUM(DT17.ZR_NET) AS ZR_NET,SUM(DT17.ES33_NET) AS ES33_NET,SUM(DT17.ESN33_NET) AS ESN33_NET,SUM(DT17.DS_NET) AS DS_NET,SUM(DT17.OS_NET) AS OS_NET,SUM(DT17.TOTAL_NET) AS TOTAL_NET,
			   SUM(DT17.[Gross Amount]) AS [Gross Amount],DT17.COA,DT17.[Account Type],/*DT17.RECORDER,*/DT17.[Service Comapany],DocumentId,DT17.ServiceCompanyId,DT17.DocSubType
		FROM
		(

		--STEP 4: STARTING OF DT16
		-- IF DOCDESCRIPTION IS NULL THEN REPLACE WITH'-'  AND [TAX RATE IN VAR] COLUMN IS NULL THEN REPLACED WITH 0%
		-- HERE SETTING GST,NET RELATED AMOUNTS TO 0.00 IN MONEY FORMAT EXCEPT FOR TAX CODE IN 'SR','ZR','DS'

		SELECT DT16.DocType,DT16.DocDate,DT16.[Doc Ref No],DT16.DocNo,DT16.Entity,ISNULL(DT16.DocDescription,'-') AS DocDescription, DT16.[Tax Code],ISNULL(DT16.[TAX RATE IN VAR],'0%') AS [TAX RATE IN VAR],
			   CASE WHEN [Tax Code]='SR' THEN BaseCredit ELSE CONVERT(MONEY,'0') END AS [SR_GST],--SGT AMOUNTS STARTING
			   CASE WHEN [Tax Code]='ZR' THEN BaseCredit ELSE CONVERT(MONEY,'0') END AS [ZR_GST],
			   CONVERT(MONEY,'0') AS ES33_GST,
			   CONVERT(MONEY,'0') AS ESN33_GST,
			   CASE WHEN [Tax Code]='DS' THEN BaseCredit ELSE CONVERT(MONEY,'0') END AS [DS_GST],
			   CONVERT(MONEY,'0') AS OS_GST,
			   BaseCredit AS TOTAL_GST,-- GST AMOUNTS ENDING
			   CASE WHEN [Tax Code]='SR' THEN [NET AMOUNT] ELSE CONVERT(MONEY,'0') END  AS [SR_NET],--NET AMOUNT STARTING
			   CASE WHEN [Tax Code]='ZR' THEN [NET AMOUNT] ELSE CONVERT(MONEY,'0') END AS [ZR_NET],
			   CONVERT(MONEY,'0') AS ES33_NET,
			   CONVERT(MONEY,'0') AS ESN33_NET,
			   CASE WHEN [Tax Code]='DS' THEN [NET AMOUNT] ELSE CONVERT(MONEY,'0') END AS [DS_NET],
			   CONVERT(MONEY,'0') AS OS_NET,
			   [NET AMOUNT] AS TOTAL_NET,-- NET AMOUNT ENDING
			   Case When [NET AMOUNT]<0 then BaseCredit*(-1) ELSE BaseCredit END+[NET AMOUNT] AS [Gross Amount],
			   COA,[Account Type],
			   /*2 AS RECORDER,*/[Service Comapany],DocumentId,DT16.ServiceCompanyId,DT16.DocSubType
		FROM
		(

			--STEP3-- JOINING DT14 AND DT15
			SELECT DT14.DocType,DT14.DocDate,DT14.[Doc Ref No],DT14.DocNo,DT14.Entity,DT14.DocDescription,DT14.[Tax Code],DT14.[TAX RATE IN VAR],DT14.COA,DT14.[Account Type],DT14.[Net Amount],DT14.[Service Comapany],DT15.BaseCredit
			      ,DT14.DocumentId,DT14.ServiceCompanyId,DT14.DocSubType
			FROM
			(

				 --STEP1:GETTING RECORDS FOR 'SR','ZR','DS' TAXCODES WITH ISTAX<>1 
				 -- HERE WE GET NETAMOUNT FROM BASECREDIT OF JOURNALDETAIL
				SELECT       JD.DocType,JD.DocDate,JD.SystemRefNo AS [Doc Ref No],JD.DocNo,E.Name AS Entity,
				Case when J.DocType<>'Journal' then J.DocumentDescription when J.DocType='Journal' then
						              Case when J.DocSubType IN ('Opening Balance','Opening Bal') then 
								      Case when Jd.AccountDescription is null then J.DocumentDescription 
									  Else Jd.AccountDescription  end
								      When J.DocSubType NOT IN ('Opening Balance','Opening Bal') then J.DocumentDescription
							          End end as DocDescription,
				      --       CASE WHEN JD.DocType='Debit note' THEN JD.AccountDescription
							   --   WHEN JD.DocType='Invoice' THEN JD.ItemDescription
								  --WHEN JD.DocType='Cash Sale' THEN JD.ItemDescription END AS DocDescription,
							 JD.TaxId,TC.Code AS [Tax Code],JD.TaxRate,CONVERT(VARCHAR(100),JD.TaxRate)+''+'%' AS [TAX RATE IN VAR],
							 COA.Name AS COA,ACT.Name AS [Account Type],
							 --Case When  ACT.Class='Income' Then Coalesce(JD.BaseCredit,JD.DocCredit,0)- Coalesce(JD.BaseDebit,JD.DocDebit,0) Else Coalesce(JD.BaseDebit,JD.DocDebit,0) - Coalesce(JD.BaseCredit,JD.DocCredit,0) END
							 ISNULL(JD.BaseCredit,0)-ISNULL(JD.BaseDebit,0)
							 --case when JD.BaseCurrency=JD.DocCurrency 
        --                                  and JD.BaseDebit is null then IsNull(JD.DocDebit,0) else ISNUll(JD.BaseDebit,0) end- case when JD.BaseCurrency=JD.DocCurrency 
        --                                  and JD.BaseCredit is null then ISNULL(JD.DocCredit,0) else ISNULL(JD.BaseCredit,0) END
							 --ISNULL(JD.BaseDebit,0)-ISNULL(JD.BaseCredit,0) 
							 as [Net Amount],SC.Name AS [Service Comapany],jd.JournalId,JD.DocumentId,JD.DocumentDetailId,Jd.ServiceCompanyId,JD.DocSubType
				FROM         Bean.JournalDetail AS JD
				INNER JOIN   Bean.Journal AS J ON J.Id=JD.JournalId
				INNER JOIN   Bean.ChartOfAccount AS COA ON COA.Id=JD.COAId
				INNER JOIN   Bean.AccountType AS ACT ON ACT.Id=COA.AccountTypeId
				Left JOIN   Bean.Entity AS E ON E.Id=JD.EntityId
				INNER JOIN   Bean.TaxCode AS TC ON TC.Id=JD.TaxId
				INNER JOIN   Common.Company AS SC ON SC.Id=JD.ServiceCompanyId
				WHERE        COA.CompanyId=@CompanyId AND JD.PostingDate BETWEEN @FromDate AND @ToDate
							 --AND JD.DocType IN ('Debit note','Invoice','Cash Sale') 
							 AND JD.DocType  IN  ('Journal') 
							 --AND JD.IsTax<>1 
							 AND (JD.IsTax<>1 OR JD.IsTax IS NULL)
							 AND J.DocumentState <> 'Void' 
							 AND DocumentDetailId='00000000-0000-0000-0000-000000000000'
							 AND TC.Code in ('SR','ZR','DS')
			) AS DT14

			INNER JOIN
			(
				--STEP2: GETTING RECORDS  'SR','ZR','DS' TAXCODES WITH ISTAX=1 
				-- HERE WE GET BASEADEBIT
				SELECT       --Case When ACT.Class='Income' Then ISNULL(JD.BaseCredit,0)-ISNULL(JD.BaseDebit,0) Else ISNULL(JD.BaseDebit,0)-ISNULL(JD.BaseCredit,0) END    
				--JD.BaseTaxAmount 
				Isnull(jd.BaseTaxCredit,0)-Isnull(JD.BaseTaxDebit,0) AS BaseCredit,jd.JournalId,JD.DocumentId,JD.DocumentDetailId,SC.Name AS [Service Comapany],JD.ID JournalDetailId
				,Jd.ServiceCompanyId,JD.DocSubType
				FROM         Bean.JournalDetail AS JD
				INNER JOIN   Bean.Journal AS J ON J.Id=JD.JournalId
				INNER JOIN   Bean.ChartOfAccount AS COA ON COA.Id=JD.COAId
				INNER JOIN   Bean.AccountType AS ACT ON ACT.Id=COA.AccountTypeId
				Left JOIN   Bean.Entity AS E ON E.Id=JD.EntityId
				INNER JOIN   Bean.TaxCode AS TC ON TC.Id=JD.TaxId
				INNER JOIN   Common.Company AS SC ON SC.Id=JD.ServiceCompanyId
				WHERE        COA.CompanyId=@CompanyId AND JD.PostingDate BETWEEN @FromDate AND @ToDate

							-- AND JD.DocType IN ('Debit note','Invoice','Cash Sale') 
							 AND JD.DocType  IN  ('Journal') 
							 --AND  JD.IsTax<>1 
							 AND (JD.IsTax<>1 OR JD.IsTax IS NULL)
							 AND J.DocumentState <> 'Void' 
							-- AND DocumentDetailId<>'00000000-0000-0000-0000-000000000000'
							 AND DocumentDetailId='00000000-0000-0000-0000-000000000000'
							 AND TC.Code in ('SR','ZR','DS') --AND JD.TaxId IS NOT NULL
							-- Group By jd.JournalId,JD.DocumentId,JD.DocumentDetailId,SC.Name ,JD.ID ,Jd.ServiceCompanyId,JD.DocSubType
			) AS DT15 ON DT14.JournalId=DT15.JournalId AND DT14.DocumentId=DT15.DocumentId  AND 
			--DT15.JournalDetailId=DT14.DocumentDetailId 
			DT15.JournalId=DT14.DocumentId
			AND DT14.[Service Comapany]=DT15.[Service Comapany]
			-- END OF STEP3
		)AS DT16
		WHERE DT16.[Service Comapany]=@ServiceCompany
		) AS DT17
		GROUP BY DocType,DocDate,[Doc Ref No],DocNo,Entity,DocDescription,[Tax Code],[TAX RATE IN VAR],COA,[Account Type],/*RECORDER,*/[Service Comapany],DocumentId,ServiceCompanyId,DocSubType
	-- ENDING OF DT17
) AS DT18
-- ENDING OF 'SR','ZR','DS' FOR DEBIT NOTE

/****************************ENDING OF STEP4********************************************/




ORDER BY /*RECORDER,*/[Account Type],COA,DocDate



END
GO
