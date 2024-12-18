USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[RptGSTReport]    Script Date: 16-12-2024 9.20.11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE PROCEDURE [dbo].[RptGSTReport]
 @CompanyValue VARCHAR(MAX),
@FromDate datetime,
@ToDate datetime,
@ServiceCompany varchar(max)
AS


--EXEC RptGSTReport @CompanyValue='1',@FromDate='2019-01-01 00:00:00',@ToDate='2019-07-22 00:00:00',@ServiceCompany='Precursor Corporate Services Pte. Ltd.'
-- Declare @CompanyValue VARCHAR(MAX)='1',
--@FromDate datetime='2019-01-01 11:02:06.643',
--@ToDate datetime='2019-07-22 11:02:06.643',
--@ServiceCompany varchar(max)='2'

BEGIN
Declare @CompanyId Int 
select @CompanyId = dbo.DecryptCompanyValue(@CompanyValue)  

DECLARE @FINAL_TABLE TABLE(GSTNO NVARCHAR(MAX),BOX1 MONEY,BOX2 MONEY,BOX3 MONEY,BOX4 MONEY,BOX5 MONEY,BOX6 MONEY,BOX7 MONEY,BOX8 MONEY,BOX9
 MONEY,BOX10 INT,BOX11 INT,BOX12 INT,BOX14 MONEY,BOX15 MONEY,BOX16 MONEY)
 DECLARE @GSTNO NVARCHAR(MAX)


 DECLARE @BOX1 MONEY,@BOX2 MONEY,@BOX3 MONEY,@BOX4 MONEY,@BOX5 MONEY,@BOX6 MONEY,@BOX7 MONEY,@BOX8 MONEY,@BOX9 MONEY,@BOX13 MONEY,@BOX10 INT,@BOX11 INT,@BOX12 INT,@BOX14 MONEY,@BOX15 MONEY,@BOX16 MONEY



SET @BOX1=(
 Select ISNULL(SUM(NET),0) From (
SELECT  ISNULL(JD.GSTTaxCredit,0)-ISNULL(JD.GSTTaxDebit,0) AS NET
										FROM Bean.JournalDetail AS JD (NOLOCK)
										INNER JOIN Bean.Journal AS J (NOLOCK) ON J.Id=JD.JournalId
										INNER JOIN Bean.ChartOfAccount AS COA (NOLOCK) ON COA.Id=JD.COAId
										INNER JOIN Bean.AccountType AS ACT (NOLOCK) ON ACT.Id=COA.AccountTypeId
										LEFT JOIN Bean.Entity AS E (NOLOCK) ON E.Id=JD.EntityId
										INNER JOIN Bean.TaxCode AS TC (NOLOCK) ON TC.Id=JD.TaxId
										INNER JOIN Common.Company AS SC (NOLOCK) ON SC.Id=JD.ServiceCompanyId
										WHERE COA.CompanyId=@CompanyId AND JD.PostingDate BETWEEN  @FromDate AND  @ToDate 
													 AND JD.DocType  NOT IN  ('Journal') 
													 AND JD.IsTax<>1 AND J.DocumentState <> 'Void' 
													 AND DocumentDetailId<>'00000000-0000-0000-0000-000000000000'
													 AND SC.Id=@ServiceCompany
													 AND TC.Code in ('DS','SR','SRCA-S','SRCA-C','SRRC','SROVR')--'SR-DSPS','SR-GMS'
													 And TC.TaxType='OutPut'
													-- And TC.Code in (Select Items From SplitToTable (@Tax_CodeList))
													 --And TC.TaxType=@Tax_Type 
									
									
								Union ALL


									SELECT  ISNULL(JD.GSTTaxCredit,0)-ISNULL(JD.GSTTaxDebit,0) AS NET
										
						FROM Bean.JournalDetail AS JD (NOLOCK)
						INNER JOIN Bean.Journal AS J (NOLOCK) ON J.Id=JD.JournalId
						INNER JOIN Bean.ChartOfAccount AS COA (NOLOCK) ON COA.Id=JD.COAId
						INNER JOIN Bean.AccountType AS ACT (NOLOCK) ON ACT.Id=COA.AccountTypeId
						LEFT JOIN Bean.Entity AS E (NOLOCK) ON E.Id=JD.EntityId
						INNER JOIN Bean.TaxCode AS TC (NOLOCK) ON TC.Id=JD.TaxId
						INNER JOIN Common.Company AS SC (NOLOCK) ON SC.Id=JD.ServiceCompanyId
						WHERE COA.CompanyId=@CompanyId AND JD.PostingDate BETWEEN  @FromDate AND @ToDate 
									 AND JD.DocType  IN  ('Journal') 
									 AND (JD.IsTax<>1 OR JD.IsTax IS NULL)
									 AND J.DocumentState <> 'Void' 
									 AND TC.Code in ('DS','SR','SRCA-S','SRCA-C','SRRC','SROVR')--'SR-DSPS','SR-GMS'
									 And TC.TaxType='OutPut'
									 AND DocumentDetailId='00000000-0000-0000-0000-000000000000'
									 AND SC.Id=@ServiceCompany
									 ) AS A )







SET @BOX2=(
 Select ISNULL(SUM(NET),0) From (
SELECT  ISNULL(JD.GSTTaxCredit,0)-ISNULL(JD.GSTTaxDebit,0) AS NET
										FROM Bean.JournalDetail AS JD (NOLOCK)
										INNER JOIN Bean.Journal AS J (NOLOCK) ON J.Id=JD.JournalId
										INNER JOIN Bean.ChartOfAccount AS COA (NOLOCK) ON COA.Id=JD.COAId
										INNER JOIN Bean.AccountType AS ACT (NOLOCK) ON ACT.Id=COA.AccountTypeId
										LEFT JOIN Bean.Entity AS E (NOLOCK) ON E.Id=JD.EntityId
										INNER JOIN Bean.TaxCode AS TC (NOLOCK) ON TC.Id=JD.TaxId
										INNER JOIN Common.Company AS SC (NOLOCK) ON SC.Id=JD.ServiceCompanyId
										WHERE COA.CompanyId=@CompanyId AND JD.PostingDate BETWEEN  @FromDate AND  @ToDate 
													 AND JD.DocType  NOT IN  ('Journal') 
													 AND JD.IsTax<>1 AND J.DocumentState <> 'Void' 
													 AND DocumentDetailId<>'00000000-0000-0000-0000-000000000000'
													 AND SC.Id=@ServiceCompany
													 AND TC.Code in ('ZR')
													 And TC.TaxType='OutPut'
													-- And TC.Code in (Select Items From SplitToTable (@Tax_CodeList))
													 --And TC.TaxType=@Tax_Type 
									
									
								Union ALL


									SELECT  ISNULL(JD.GSTTaxCredit,0)-ISNULL(JD.GSTTaxDebit,0) AS NET
										
						FROM Bean.JournalDetail AS JD (NOLOCK)
						INNER JOIN Bean.Journal AS J (NOLOCK) ON J.Id=JD.JournalId
						INNER JOIN Bean.ChartOfAccount AS COA (NOLOCK) ON COA.Id=JD.COAId
						INNER JOIN Bean.AccountType AS ACT (NOLOCK) ON ACT.Id=COA.AccountTypeId
						LEFT JOIN Bean.Entity AS E (NOLOCK) ON E.Id=JD.EntityId
						INNER JOIN Bean.TaxCode AS TC (NOLOCK) ON TC.Id=JD.TaxId
						INNER JOIN Common.Company AS SC (NOLOCK) ON SC.Id=JD.ServiceCompanyId
						WHERE COA.CompanyId=@CompanyId AND JD.PostingDate BETWEEN  @FromDate AND @ToDate 
									 AND JD.DocType  IN  ('Journal') 
									 AND (JD.IsTax<>1 OR JD.IsTax IS NULL)
									 AND J.DocumentState <> 'Void' 
									 AND TC.Code in ('ZR')
									 And TC.TaxType='OutPut'
									 AND DocumentDetailId='00000000-0000-0000-0000-000000000000'
									 AND SC.Id=@ServiceCompany
									 ) AS A )


SET @BOX3=(
 Select  ISNULL(SUM(NET),0) From (
SELECT  ISNULL(JD.GSTTaxCredit,0)-ISNULL(JD.GSTTaxDebit,0) AS NET
										FROM Bean.JournalDetail AS JD (NOLOCK)
										INNER JOIN Bean.Journal AS J (NOLOCK) ON J.Id=JD.JournalId
										INNER JOIN Bean.ChartOfAccount AS COA (NOLOCK) ON COA.Id=JD.COAId
										INNER JOIN Bean.AccountType AS ACT (NOLOCK) ON ACT.Id=COA.AccountTypeId
										LEFT JOIN Bean.Entity AS E (NOLOCK) ON E.Id=JD.EntityId
										INNER JOIN Bean.TaxCode AS TC (NOLOCK) ON TC.Id=JD.TaxId
										INNER JOIN Common.Company AS SC (NOLOCK) ON SC.Id=JD.ServiceCompanyId
										WHERE COA.CompanyId=@CompanyId AND JD.PostingDate BETWEEN  @FromDate AND  @ToDate 
													 AND JD.DocType  NOT IN  ('Journal') 
													 AND JD.IsTax<>1 AND J.DocumentState <> 'Void' 
													 AND DocumentDetailId<>'00000000-0000-0000-0000-000000000000'
													 AND SC.Id=@ServiceCompany
													 AND TC.Code in ('ES33','ESN33')
													 And TC.TaxType='OutPut'
													-- And TC.Code in (Select Items From SplitToTable (@Tax_CodeList))
													 --And TC.TaxType=@Tax_Type 
									
									
								Union ALL


									SELECT  ISNULL(JD.GSTTaxCredit,0)-ISNULL(JD.GSTTaxDebit,0) AS NET
										
						FROM Bean.JournalDetail AS JD (NOLOCK)
						INNER JOIN Bean.Journal AS J (NOLOCK) ON J.Id=JD.JournalId
						INNER JOIN Bean.ChartOfAccount AS COA (NOLOCK) ON COA.Id=JD.COAId
						INNER JOIN Bean.AccountType AS ACT (NOLOCK) ON ACT.Id=COA.AccountTypeId
						LEFT JOIN Bean.Entity AS E (NOLOCK) ON E.Id=JD.EntityId
						INNER JOIN Bean.TaxCode AS TC (NOLOCK) ON TC.Id=JD.TaxId
						INNER JOIN Common.Company AS SC (NOLOCK) ON SC.Id=JD.ServiceCompanyId
						WHERE COA.CompanyId=@CompanyId AND JD.PostingDate BETWEEN  @FromDate AND @ToDate 
									 AND JD.DocType  IN  ('Journal') 
									 AND (JD.IsTax<>1 OR JD.IsTax IS NULL)
									 AND J.DocumentState <> 'Void' 
									 AND TC.Code in ('ES33','ESN33')
									 And TC.TaxType='OutPut'
									 AND DocumentDetailId='00000000-0000-0000-0000-000000000000'
									 AND SC.Id=@ServiceCompany
									 ) AS A )


SET @BOX4=(
 Select ISNULL(SUM(NET),0) From (
SELECT  ISNULL(JD.GSTTaxCredit,0)-ISNULL(JD.GSTTaxDebit,0) AS NET
										FROM Bean.JournalDetail AS JD (NOLOCK)
										INNER JOIN Bean.Journal AS J (NOLOCK) ON J.Id=JD.JournalId
										INNER JOIN Bean.ChartOfAccount AS COA (NOLOCK) ON COA.Id=JD.COAId
										INNER JOIN Bean.AccountType AS ACT (NOLOCK) ON ACT.Id=COA.AccountTypeId
										LEFT JOIN Bean.Entity AS E (NOLOCK) ON E.Id=JD.EntityId
										INNER JOIN Bean.TaxCode AS TC (NOLOCK) ON TC.Id=JD.TaxId
										INNER JOIN Common.Company AS SC (NOLOCK) ON SC.Id=JD.ServiceCompanyId
										WHERE COA.CompanyId=@CompanyId AND JD.PostingDate BETWEEN  @FromDate AND  @ToDate 
													 AND JD.DocType  NOT IN  ('Journal') 
													 AND JD.IsTax<>1 AND J.DocumentState <> 'Void' 
													 AND DocumentDetailId<>'00000000-0000-0000-0000-000000000000'
													 AND SC.Id=@ServiceCompany
													 AND TC.Code in ('ZR','ES33','ESN33','DS','SR','SRCA-S','SRCA-C','SRRC','SROVR')--'SR-DSPS','SR-GMS'
													 And TC.TaxType='OutPut'
													-- And TC.Code in (Select Items From SplitToTable (@Tax_CodeList))
													 --And TC.TaxType=@Tax_Type 
									
									
								Union ALL


									SELECT  ISNULL(JD.GSTTaxCredit,0)-ISNULL(JD.GSTTaxDebit,0) AS NET
										
						FROM Bean.JournalDetail AS JD (NOLOCK)
						INNER JOIN Bean.Journal AS J (NOLOCK) ON J.Id=JD.JournalId
						INNER JOIN Bean.ChartOfAccount AS COA (NOLOCK) ON COA.Id=JD.COAId
						INNER JOIN Bean.AccountType AS ACT (NOLOCK) ON ACT.Id=COA.AccountTypeId
						LEFT JOIN Bean.Entity AS E (NOLOCK) ON E.Id=JD.EntityId
						INNER JOIN Bean.TaxCode AS TC (NOLOCK) ON TC.Id=JD.TaxId
						INNER JOIN Common.Company AS SC (NOLOCK) ON SC.Id=JD.ServiceCompanyId
						WHERE COA.CompanyId=@CompanyId AND JD.PostingDate BETWEEN  @FromDate AND @ToDate 
									 AND JD.DocType  IN  ('Journal') 
									 AND (JD.IsTax<>1 OR JD.IsTax IS NULL)
									 AND J.DocumentState <> 'Void' 
									 AND TC.Code in ('ZR','ES33','ESN33','DS','SR','SRCA-S','SRCA-C','SRRC','SROVR')--'SR-DSPS','SR-GMS'
									 And TC.TaxType='OutPut'
									 AND DocumentDetailId='00000000-0000-0000-0000-000000000000'
									 AND SC.Id=@ServiceCompany
									 ) AS A )



SET @BOX5=(
 Select ISNULL(SUM(NET),0) From (
SELECT  ISNULL(JD.GSTTaxDebit,0)-ISNULL(JD.GSTTaxCredit,0) AS NET
										FROM Bean.JournalDetail AS JD (NOLOCK)
										INNER JOIN Bean.Journal AS J (NOLOCK) ON J.Id=JD.JournalId
										INNER JOIN Bean.ChartOfAccount AS COA (NOLOCK) ON COA.Id=JD.COAId
										INNER JOIN Bean.AccountType AS ACT (NOLOCK) ON ACT.Id=COA.AccountTypeId
										LEFT JOIN Bean.Entity AS E (NOLOCK) ON E.Id=JD.EntityId
										INNER JOIN Bean.TaxCode AS TC (NOLOCK) ON TC.Id=JD.TaxId
										INNER JOIN Common.Company AS SC (NOLOCK) ON SC.Id=JD.ServiceCompanyId
										WHERE COA.CompanyId=@CompanyId AND JD.PostingDate BETWEEN  @FromDate AND  @ToDate 
													 AND JD.DocType  NOT IN  ('Journal') 
													 AND JD.IsTax<>1 AND J.DocumentState <> 'Void' 
													 AND DocumentDetailId<>'00000000-0000-0000-0000-000000000000'
													 AND SC.Id=@ServiceCompany
													 AND TC.Code in ('TX','TXCA','ZP','IM','ME','IGDS')--'TX-DSPS','TX-GMS',
													 And TC.TaxType='InPut'
													-- And TC.Code in (Select Items From SplitToTable (@Tax_CodeList))
													 --And TC.TaxType=@Tax_Type 
									
									
								Union ALL


									SELECT ISNULL(JD.GSTTaxDebit,0)-ISNULL(JD.GSTTaxCredit,0) AS NET
										
						FROM Bean.JournalDetail AS JD (NOLOCK)
						INNER JOIN Bean.Journal AS J (NOLOCK) ON J.Id=JD.JournalId
						INNER JOIN Bean.ChartOfAccount AS COA (NOLOCK) ON COA.Id=JD.COAId
						INNER JOIN Bean.AccountType AS ACT (NOLOCK) ON ACT.Id=COA.AccountTypeId
						LEFT JOIN Bean.Entity AS E (NOLOCK) ON E.Id=JD.EntityId
						INNER JOIN Bean.TaxCode AS TC (NOLOCK) ON TC.Id=JD.TaxId
						INNER JOIN Common.Company AS SC (NOLOCK) ON SC.Id=JD.ServiceCompanyId
						WHERE COA.CompanyId=@CompanyId AND JD.PostingDate BETWEEN  @FromDate AND @ToDate 
									 AND JD.DocType  IN  ('Journal') 
									 AND (JD.IsTax<>1 OR JD.IsTax IS NULL)
									 AND J.DocumentState <> 'Void' 
									 AND TC.Code in ('TX','TXCA','ZP','IM','ME','IGDS')--'TX-DSPS','TX-GMS',
									 And TC.TaxType='InPut'
									 AND DocumentDetailId='00000000-0000-0000-0000-000000000000'
									 AND SC.Id=@ServiceCompany
									 ) AS A )


SET @BOX6
=(
 Select ISNULL(SUM(NET),0) From (
SELECT  (ISNULL(JD.GSTCredit,0)-ISNULL(JD.GSTDebit,0)) AS NET
										FROM Bean.JournalDetail AS JD (NOLOCK)
										INNER JOIN Bean.Journal AS J (NOLOCK) ON J.Id=JD.JournalId
										INNER JOIN Bean.ChartOfAccount AS COA (NOLOCK) ON COA.Id=JD.COAId
										INNER JOIN Bean.AccountType AS ACT (NOLOCK) ON ACT.Id=COA.AccountTypeId
										LEFT JOIN Bean.Entity AS E (NOLOCK) ON E.Id=JD.EntityId
										INNER JOIN Bean.TaxCode AS TC (NOLOCK) ON TC.Id=JD.TaxId
										INNER JOIN Common.Company AS SC (NOLOCK) ON SC.Id=JD.ServiceCompanyId
										WHERE COA.CompanyId=@CompanyId AND JD.PostingDate BETWEEN  @FromDate AND  @ToDate 
													 AND JD.DocType  NOT IN  ('Journal') 
													 AND JD.IsTax<>1 AND J.DocumentState <> 'Void' 
													 AND DocumentDetailId<>'00000000-0000-0000-0000-000000000000'
													 AND SC.Id=@ServiceCompany AND JD.TaxId IS NOT NULL 
													 AND TC.Code in ('SR','SRCA-C','DS','SRRC','SROVR')--'SRCA-S','SR-DSPS','SR-GMS',
													 And TC.TaxType='OutPut'
													-- And TC.Code in (Select Items From SplitToTable (@Tax_CodeList))
													 --And TC.TaxType=@Tax_Type 
									
									
								Union ALL


									SELECT  (ISNULL(JD.GSTCredit,0)-ISNULL(JD.GSTDebit,0)) AS NET
										
						FROM Bean.JournalDetail AS JD (NOLOCK)
						INNER JOIN Bean.Journal AS J (NOLOCK) ON J.Id=JD.JournalId
						INNER JOIN Bean.ChartOfAccount AS COA (NOLOCK) ON COA.Id=JD.COAId
						INNER JOIN Bean.AccountType AS ACT (NOLOCK) ON ACT.Id=COA.AccountTypeId
						LEFT JOIN Bean.Entity AS E (NOLOCK) ON E.Id=JD.EntityId
						INNER JOIN Bean.TaxCode AS TC (NOLOCK) ON TC.Id=JD.TaxId
						INNER JOIN Common.Company AS SC (NOLOCK) ON SC.Id=JD.ServiceCompanyId
						WHERE COA.CompanyId=@CompanyId AND JD.PostingDate BETWEEN  @FromDate AND @ToDate 
									 AND JD.DocType  IN  ('Journal') 
									 AND (JD.IsTax<>1 OR JD.IsTax IS NULL)
									 AND J.DocumentState <> 'Void' 
									 AND TC.Code in ('SR','SRCA-C','DS','SRRC','SROVR')--'SRCA-S','SR-DSPS','SR-GMS',
									 And TC.TaxType='OutPut'
									 AND DocumentDetailId='00000000-0000-0000-0000-000000000000'
									 AND SC.Id=@ServiceCompany
									 ) AS A )


SET @BOX7
=(
 Select ISNULL(SUM(NET),0) From (
SELECT  (ISNULL(JD.GSTDebit,0)-ISNULL(JD.GSTCredit,0)) AS NET
										FROM Bean.JournalDetail AS JD (NOLOCK)
										INNER JOIN Bean.Journal AS J (NOLOCK) ON J.Id=JD.JournalId
										INNER JOIN Bean.ChartOfAccount AS COA (NOLOCK) ON COA.Id=JD.COAId
										INNER JOIN Bean.AccountType AS ACT (NOLOCK) ON ACT.Id=COA.AccountTypeId
										LEFT JOIN Bean.Entity AS E (NOLOCK) ON E.Id=JD.EntityId
										INNER JOIN Bean.TaxCode AS TC (NOLOCK) ON TC.Id=JD.TaxId
										INNER JOIN Common.Company AS SC (NOLOCK) ON SC.Id=JD.ServiceCompanyId
										WHERE COA.CompanyId=@CompanyId AND JD.PostingDate BETWEEN  @FromDate AND  @ToDate 
													 AND JD.DocType  NOT IN  ('Journal') 
													 AND JD.IsTax<>1 AND J.DocumentState <> 'Void' 
													 AND DocumentDetailId<>'00000000-0000-0000-0000-000000000000'
													 AND SC.Id=@ServiceCompany AND JD.TaxId IS NOT NULL 
													 AND TC.Code in ('TX', 'TXCA','IM','IGDS')--'TX-DSPS','TX-GMS','ZP','ME',
													 And TC.TaxType='InPut'
													-- And TC.Code in (Select Items From SplitToTable (@Tax_CodeList))
													 --And TC.TaxType=@Tax_Type 
									
									
								Union ALL


									SELECT  (ISNULL(JD.GSTDebit,0)-ISNULL(JD.GSTCredit,0)) AS NET
										
						FROM Bean.JournalDetail AS JD (NOLOCK)
						INNER JOIN Bean.Journal AS J (NOLOCK) ON J.Id=JD.JournalId
						INNER JOIN Bean.ChartOfAccount AS COA (NOLOCK) ON COA.Id=JD.COAId
						INNER JOIN Bean.AccountType AS ACT (NOLOCK) ON ACT.Id=COA.AccountTypeId
						LEFT JOIN Bean.Entity AS E (NOLOCK) ON E.Id=JD.EntityId
						INNER JOIN Bean.TaxCode AS TC (NOLOCK) ON TC.Id=JD.TaxId
						INNER JOIN Common.Company AS SC (NOLOCK) ON SC.Id=JD.ServiceCompanyId
						WHERE COA.CompanyId=@CompanyId AND JD.PostingDate BETWEEN  @FromDate AND @ToDate 
									 AND JD.DocType  IN  ('Journal') 
									 AND (JD.IsTax<>1 OR JD.IsTax IS NULL)
									 AND J.DocumentState <> 'Void' 
									 AND TC.Code in ('TX', 'TXCA','IM','IGDS')--'TX-DSPS','TX-GMS','ZP','ME',
									 And TC.TaxType='InPut'
									 AND DocumentDetailId='00000000-0000-0000-0000-000000000000'
									 AND SC.Id=@ServiceCompany
									 ) AS A )


SET @BOX8=(
 Select ISNULL(SUM(NET),0) From (
SELECT  (ISNULL(JD.GSTCredit,0)-ISNULL(JD.GSTDebit,0)) AS NET
										FROM Bean.JournalDetail AS JD (NOLOCK)
										INNER JOIN Bean.Journal AS J (NOLOCK) ON J.Id=JD.JournalId
										INNER JOIN Bean.ChartOfAccount AS COA (NOLOCK) ON COA.Id=JD.COAId
										INNER JOIN Bean.AccountType AS ACT (NOLOCK) ON ACT.Id=COA.AccountTypeId
										LEFT JOIN Bean.Entity AS E (NOLOCK) ON E.Id=JD.EntityId
										INNER JOIN Bean.TaxCode AS TC (NOLOCK) ON TC.Id=JD.TaxId
										INNER JOIN Common.Company AS SC (NOLOCK) ON SC.Id=JD.ServiceCompanyId
										WHERE COA.CompanyId=@CompanyId AND JD.PostingDate BETWEEN  @FromDate AND  @ToDate 
													 AND JD.DocType  NOT IN  ('Journal') 
													 AND JD.IsTax<>1 AND J.DocumentState <> 'Void' 
													 AND DocumentDetailId<>'00000000-0000-0000-0000-000000000000'
													 AND SC.Id=@ServiceCompany AND JD.TaxId IS NOT NULL 
													 AND TC.Code in ('SR','SRCA-C','DS','SRRC','SROVR')--'SRCA-S','SR-DSPS','SR-GMS',
													 And TC.TaxType='OutPut'
													-- And TC.Code in (Select Items From SplitToTable (@Tax_CodeList))
													 --And TC.TaxType=@Tax_Type 
									
									
								Union ALL


									SELECT  (ISNULL(JD.GSTCredit,0)-ISNULL(JD.GSTDebit,0)) AS NET
										
						FROM Bean.JournalDetail AS JD (NOLOCK)
						INNER JOIN Bean.Journal AS J (NOLOCK) ON J.Id=JD.JournalId
						INNER JOIN Bean.ChartOfAccount AS COA (NOLOCK) ON COA.Id=JD.COAId
						INNER JOIN Bean.AccountType AS ACT (NOLOCK) ON ACT.Id=COA.AccountTypeId
						LEFT JOIN Bean.Entity AS E (NOLOCK) ON E.Id=JD.EntityId
						INNER JOIN Bean.TaxCode AS TC (NOLOCK) ON TC.Id=JD.TaxId
						INNER JOIN Common.Company AS SC (NOLOCK) ON SC.Id=JD.ServiceCompanyId
						WHERE COA.CompanyId=@CompanyId AND JD.PostingDate BETWEEN  @FromDate AND @ToDate 
									 AND JD.DocType  IN  ('Journal') 
									 AND (JD.IsTax<>1 OR JD.IsTax IS NULL)
									 AND J.DocumentState <> 'Void' 
									 AND TC.Code in ('SR','SRCA-C','DS','SRRC','SROVR')--'SRCA-S','SR-DSPS','SR-GMS',
									 And TC.TaxType='OutPut'
									 AND DocumentDetailId='00000000-0000-0000-0000-000000000000'
									 AND SC.Id=@ServiceCompany
									 ) AS A )-(
 Select ISNULL(SUM(NET),0) From (
SELECT  (ISNULL(JD.GSTDebit,0)-ISNULL(JD.GSTCredit,0)) AS NET
										FROM Bean.JournalDetail AS JD (NOLOCK)
										INNER JOIN Bean.Journal AS J (NOLOCK) ON J.Id=JD.JournalId
										INNER JOIN Bean.ChartOfAccount AS COA (NOLOCK) ON COA.Id=JD.COAId
										INNER JOIN Bean.AccountType AS ACT (NOLOCK) ON ACT.Id=COA.AccountTypeId
										LEFT JOIN Bean.Entity AS E (NOLOCK) ON E.Id=JD.EntityId
										INNER JOIN Bean.TaxCode AS TC (NOLOCK) ON TC.Id=JD.TaxId
										INNER JOIN Common.Company AS SC (NOLOCK) ON SC.Id=JD.ServiceCompanyId
										WHERE COA.CompanyId=@CompanyId AND JD.PostingDate BETWEEN  @FromDate AND  @ToDate 
													 AND JD.DocType  NOT IN  ('Journal') 
													 AND JD.IsTax<>1 AND J.DocumentState <> 'Void' 
													 AND DocumentDetailId<>'00000000-0000-0000-0000-000000000000'
													 AND SC.Id=@ServiceCompany AND JD.TaxId IS NOT NULL 
													 AND TC.Code in ('TX', 'TXCA','IM','IGDS')--'TX-DSPS','TX-GMS','ZP','ME',
													 And TC.TaxType='InPut'
													-- And TC.Code in (Select Items From SplitToTable (@Tax_CodeList))
													 --And TC.TaxType=@Tax_Type 
									
									
								Union ALL


									SELECT  (ISNULL(JD.GSTDebit,0)-ISNULL(JD.GSTCredit,0)) AS NET
										
						FROM Bean.JournalDetail AS JD (NOLOCK)
						INNER JOIN Bean.Journal AS J (NOLOCK) ON J.Id=JD.JournalId
						INNER JOIN Bean.ChartOfAccount AS COA (NOLOCK) ON COA.Id=JD.COAId
						INNER JOIN Bean.AccountType AS ACT (NOLOCK) ON ACT.Id=COA.AccountTypeId
						LEFT JOIN Bean.Entity AS E (NOLOCK) ON E.Id=JD.EntityId
						INNER JOIN Bean.TaxCode AS TC (NOLOCK) ON TC.Id=JD.TaxId
						INNER JOIN Common.Company AS SC (NOLOCK) ON SC.Id=JD.ServiceCompanyId
						WHERE COA.CompanyId=@CompanyId AND JD.PostingDate BETWEEN  @FromDate AND @ToDate 
									 AND JD.DocType  IN  ('Journal') 
									 AND (JD.IsTax<>1 OR JD.IsTax IS NULL)
									 AND J.DocumentState <> 'Void' 
									 AND TC.Code in ('TX', 'TXCA','IM','IGDS')--'TX-DSPS','TX-GMS','ZP','ME',
									 And TC.TaxType='InPut'
									 AND DocumentDetailId='00000000-0000-0000-0000-000000000000'
									 AND SC.Id=@ServiceCompany
									 ) AS A )

SET @BOX9
=(
 Select ISNULL(SUM(NET),0) From (
SELECT  ISNULL(JD.GSTTaxDebit,0)-ISNULL(JD.GSTTaxCredit,0) AS NET
										FROM Bean.JournalDetail AS JD (NOLOCK)
										INNER JOIN Bean.Journal AS J (NOLOCK) ON J.Id=JD.JournalId
										INNER JOIN Bean.ChartOfAccount AS COA (NOLOCK) ON COA.Id=JD.COAId
										INNER JOIN Bean.AccountType AS ACT (NOLOCK) ON ACT.Id=COA.AccountTypeId
										LEFT JOIN Bean.Entity AS E (NOLOCK) ON E.Id=JD.EntityId
										INNER JOIN Bean.TaxCode AS TC (NOLOCK) ON TC.Id=JD.TaxId
										INNER JOIN Common.Company AS SC (NOLOCK) ON SC.Id=JD.ServiceCompanyId
										WHERE COA.CompanyId=@CompanyId AND JD.PostingDate BETWEEN  @FromDate AND  @ToDate 
													 AND JD.DocType  NOT IN  ('Journal') 
													 AND JD.IsTax<>1 AND J.DocumentState <> 'Void' 
													 AND DocumentDetailId<>'00000000-0000-0000-0000-000000000000'
													 AND SC.Id=@ServiceCompany
													 AND TC.Code in ('ME')
													 And TC.TaxType='Input'
													-- And TC.Code in (Select Items From SplitToTable (@Tax_CodeList))
													 --And TC.TaxType=@Tax_Type 
									
									
								Union ALL


									SELECT  ISNULL(JD.GSTTaxDebit,0)-ISNULL(JD.GSTTaxCredit,0) AS NET
										
						FROM Bean.JournalDetail AS JD (NOLOCK)
						INNER JOIN Bean.Journal AS J (NOLOCK) ON J.Id=JD.JournalId
						INNER JOIN Bean.ChartOfAccount AS COA (NOLOCK) ON COA.Id=JD.COAId
						INNER JOIN Bean.AccountType AS ACT (NOLOCK) ON ACT.Id=COA.AccountTypeId
						LEFT JOIN Bean.Entity AS E (NOLOCK) ON E.Id=JD.EntityId
						INNER JOIN Bean.TaxCode AS TC (NOLOCK) ON TC.Id=JD.TaxId
						INNER JOIN Common.Company AS SC (NOLOCK) ON SC.Id=JD.ServiceCompanyId
						WHERE COA.CompanyId=@CompanyId AND JD.PostingDate BETWEEN  @FromDate AND @ToDate 
									 AND JD.DocType  IN  ('Journal') 
									 AND (JD.IsTax<>1 OR JD.IsTax IS NULL)
									 AND J.DocumentState <> 'Void' 
									 AND TC.Code in ('ME')
									 And TC.TaxType='Input'
									 AND DocumentDetailId='00000000-0000-0000-0000-000000000000'
									 AND SC.Id=@ServiceCompany
									 ) AS A )



 SET @BOX14=( Select ISNULL(SUM(Credit),0)-ISNULL(Sum(Debit),0)  from (
	 SELECT [COA Name],[COA COde],Class,classOrder,Recorder,Case when BaseTotal >= 0 then BaseTotal end as Debit,
            case when BaseTotal < 0 then -BaseTotal end as Credit,DocDate
     FROM 
        (
	Select [COA Name],[COA COde],Class,sum(isnull(BaseDebit,0)) BaseDebit,sum(Isnull(BaseCredit,0)) BaseCredit,
		 	    sum(isnull(BaseDebit,0))-sum(Isnull(BaseCredit,0)) as BaseTotal,classOrder,Recorder,DocDate
	From
		(
		 select COa.Name [COA Name],JD.PostingDate As DocDate,COA.Code AS [COA COde],COA.Class,'1' AS classOrder,AT.RecOrder,
				case when JD.BaseCurrency=JD.DocCurrency and JD.BaseDebit is null then JD.DocDebit else JD.BaseDebit end  BaseDebit,
				Case when JD.BaseCurrency=JD.DocCurrency and JD.BaseCredit is null then JD.DocCredit else JD.BaseCredit end  BaseCredit
		 from   Bean.JournalDetail as JD (NOLOCK)
				join  Bean.Journal as J (NOLOCK) on J.Id=JD.journalId
				join  Bean.chartOfAccount as COA (NOLOCK) on COA.Id=JD.COAID
				Left Join Bean.AccountType As AT (NOLOCK) On AT.Id=COA.AccountTypeId And AT.CompanyId=COA.CompanyId
				join  Common.Company As SC on SC.Id=J.ServiceCompanyId
		 WHERE COA.companyId=@CompanyId and COA.ModuleType='Bean' 
			   and SC.Id =@ServiceCompany--in (select items from dbo.SplitToTable(,','))
			  and J.DocumentState NOT IN ('Void','Cancelled','Parked','Reset','Recurring')
			  AND AT.Name  IN ('Revenue')--COA.Class IN ('Income','Expenses')
			  and   convert(date,JD.PostingDate) Between  @FromDate And @Todate--@ToDate/*getdate()*/
		 ) BS1
		  GROUP BY [COA Name],[COA COde],classOrder,Recorder,Class,DocDate
		) AS P
		) AS A)


SET @BOX15=(
 Select ISNULL(SUM(NET),0) From (
SELECT  ISNULL(JD.GSTTaxCredit,0)-ISNULL(JD.GSTTaxDebit,0) AS NET
										FROM Bean.JournalDetail AS JD (NOLOCK)
										INNER JOIN Bean.Journal AS J (NOLOCK) ON J.Id=JD.JournalId
										INNER JOIN Bean.ChartOfAccount AS COA (NOLOCK) ON COA.Id=JD.COAId
										INNER JOIN Bean.AccountType AS ACT (NOLOCK) ON ACT.Id=COA.AccountTypeId
										LEFT JOIN Bean.Entity AS E (NOLOCK) ON E.Id=JD.EntityId
										INNER JOIN Bean.TaxCode AS TC (NOLOCK) ON TC.Id=JD.TaxId
										INNER JOIN Common.Company AS SC (NOLOCK) ON SC.Id=JD.ServiceCompanyId
										WHERE COA.CompanyId=@CompanyId AND JD.PostingDate BETWEEN  @FromDate AND  @ToDate 
													 AND JD.DocType  NOT IN  ('Journal') 
													 AND JD.IsTax<>1 AND J.DocumentState <> 'Void' 
													 AND DocumentDetailId<>'00000000-0000-0000-0000-000000000000'
													 AND SC.Id=@ServiceCompany
													 AND TC.Code in ('SRRC')--'SR-DSPS','SR-GMS'
													 And TC.TaxType='OutPut'
													-- And TC.Code in (Select Items From SplitToTable (@Tax_CodeList))
													 --And TC.TaxType=@Tax_Type 
									
									
								Union ALL


									SELECT  ISNULL(JD.GSTTaxCredit,0)-ISNULL(JD.GSTTaxDebit,0) AS NET
										
						FROM Bean.JournalDetail AS JD (NOLOCK)
						INNER JOIN Bean.Journal AS J (NOLOCK) ON J.Id=JD.JournalId
						INNER JOIN Bean.ChartOfAccount AS COA (NOLOCK) ON COA.Id=JD.COAId
						INNER JOIN Bean.AccountType AS ACT (NOLOCK) ON ACT.Id=COA.AccountTypeId
						LEFT JOIN Bean.Entity AS E (NOLOCK) ON E.Id=JD.EntityId
						INNER JOIN Bean.TaxCode AS TC (NOLOCK) ON TC.Id=JD.TaxId
						INNER JOIN Common.Company AS SC (NOLOCK) ON SC.Id=JD.ServiceCompanyId
						WHERE COA.CompanyId=@CompanyId AND JD.PostingDate BETWEEN  @FromDate AND @ToDate 
									 AND JD.DocType  IN  ('Journal') 
									 AND (JD.IsTax<>1 OR JD.IsTax IS NULL)
									 AND J.DocumentState <> 'Void' 
									 AND TC.Code in ('SRRC')--'SR-DSPS','SR-GMS'
									 And TC.TaxType='OutPut'
									 AND DocumentDetailId='00000000-0000-0000-0000-000000000000'
									 AND SC.Id=@ServiceCompany
									 ) AS A )


SET @BOX16=(
 Select ISNULL(SUM(NET),0) From (
SELECT  ISNULL(JD.GSTTaxCredit,0)-ISNULL(JD.GSTTaxDebit,0) AS NET
										FROM Bean.JournalDetail AS JD (NOLOCK)
										INNER JOIN Bean.Journal AS J (NOLOCK) ON J.Id=JD.JournalId
										INNER JOIN Bean.ChartOfAccount AS COA (NOLOCK) ON COA.Id=JD.COAId
										INNER JOIN Bean.AccountType AS ACT (NOLOCK) ON ACT.Id=COA.AccountTypeId
										LEFT JOIN Bean.Entity AS E (NOLOCK) ON E.Id=JD.EntityId
										INNER JOIN Bean.TaxCode AS TC (NOLOCK) ON TC.Id=JD.TaxId
										INNER JOIN Common.Company AS SC (NOLOCK) ON SC.Id=JD.ServiceCompanyId
										WHERE COA.CompanyId=@CompanyId AND JD.PostingDate BETWEEN  @FromDate AND  @ToDate 
													 AND JD.DocType  NOT IN  ('Journal') 
													 AND JD.IsTax<>1 AND J.DocumentState <> 'Void' 
													 AND DocumentDetailId<>'00000000-0000-0000-0000-000000000000'
													 AND SC.Id=@ServiceCompany
													 AND TC.Code in ('SROVR')--'SR-DSPS','SR-GMS'
													 And TC.TaxType='OutPut'
													-- And TC.Code in (Select Items From SplitToTable (@Tax_CodeList))
													 --And TC.TaxType=@Tax_Type 
									
									
								Union ALL


									SELECT  ISNULL(JD.GSTTaxCredit,0)-ISNULL(JD.GSTTaxDebit,0) AS NET
										
						FROM Bean.JournalDetail AS JD (NOLOCK)
						INNER JOIN Bean.Journal AS J (NOLOCK) ON J.Id=JD.JournalId
						INNER JOIN Bean.ChartOfAccount AS COA (NOLOCK) ON COA.Id=JD.COAId
						INNER JOIN Bean.AccountType AS ACT (NOLOCK) ON ACT.Id=COA.AccountTypeId
						LEFT JOIN Bean.Entity AS E (NOLOCK) ON E.Id=JD.EntityId
						INNER JOIN Bean.TaxCode AS TC (NOLOCK) ON TC.Id=JD.TaxId
						INNER JOIN Common.Company AS SC (NOLOCK) ON SC.Id=JD.ServiceCompanyId
						WHERE COA.CompanyId=@CompanyId AND JD.PostingDate BETWEEN  @FromDate AND @ToDate 
									 AND JD.DocType  IN  ('Journal') 
									 AND (JD.IsTax<>1 OR JD.IsTax IS NULL)
									 AND J.DocumentState <> 'Void' 
									 AND TC.Code in ('SROVR')--'SR-DSPS','SR-GMS'
									 And TC.TaxType='OutPut'
									 AND DocumentDetailId='00000000-0000-0000-0000-000000000000'
									 AND SC.Id=@ServiceCompany
									 ) AS A )



/* GETTING GST NUMBER */
select @GSTNO=GST.Number
from
(
  select CompanyId,Number,ServiceCompanyId from Common.GSTSetting (NOLOCK) where CompanyId=@CompanyId
) as GST

inner join
(
  select id,ParentId,Name from Common.Company (NOLOCK) where parentid=@CompanyId and Id=@ServiceCompany
) as common on common.Id=GST.ServiceCompanyId and common.ParentId=GST.CompanyId

/* ENDING OF GST NUMBER */

		INSERT INTO @FINAL_TABLE
SELECT @GSTNO,@BOX1,@BOX2,@BOX3,@BOX4,@BOX5,@BOX6,@BOX7,@BOX6-@BOX7,@BOX9,@BOX10,@BOX11,@BOX12,@BOX14,@BOX15,@BOX16

SELECT * FROM @FINAL_TABLE

END
GO
