USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[HTML_GLOUTPUTINPUT_GLTAX]    Script Date: 16-12-2024 9.20.10 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



--Exec [dbo].[HTML_GLOUTPUTINPUT_GLTAX]  244,'2019-01-04','2020-01-04','300','34w53','All','Input'

--Case when J.DocType<>''Journal'' then J.DocumentDescription when J.DocType=''Journal'' then
--												              Case when J.DocSubType IN (''Opening Balance'',''Opening Bal'') then 
--														      Case when Jd.AccountDescription is null then J.DocumentDescription 
--															  Else Jd.AccountDescription  end
--														      When J.DocSubType NOT IN (''Opening Balance'',''Opening Bal'') then J.DocumentDescription
--													          End end 

--Case When ' + '''' + @Tax_Type + '''' + '=''Output'' Then Round((ISNULL(JD.BaseCredit,0)-ISNULL(JD.BaseDebit,0))*Cast(JD.TaxRate AS Money)/100,2)
--													 When ' + '''' + @Tax_Type + '''' + '=''Input'' Then Round((ISNULL(JD.BaseDebit,0)-ISNULL(JD.BaseCredit,0))*Cast(JD.TaxRate AS Money)/100,2) End As BaseCredit

CREATE Procedure [dbo].[HTML_GLOUTPUTINPUT_GLTAX]
@CompanyValue VARCHAR(MAX),
@FromDate Nvarchar(500),
@ToDate Nvarchar(500),
@ServiceCompany varchar(max),
@GSTNO varchar(max),
@Tax_CodeList Nvarchar(500),
@Tax_Type Nvarchar(10)
--Select * from Common.Company Where ParentId=1
AS 
BEGIN

--Declare
--@CompanyValue VARCHAR(MAX)=1519,
--@FromDate Nvarchar(500)='2019-01-01 00:00:00',
--@ToDate Nvarchar(500)='2019-12-27 00:00:00',
--@ServiceCompany varchar(max)='1520',--'Precursor Group Pte. Ltd.',
----@GSTNO varchar(max)='201288674E',
--@Tax_CodeList Nvarchar(500)='All',
--@Tax_Type Nvarchar(10)='InPut' -- Output
Set @FromDate=cast(@FromDate AS Nvarchar(500))
Set @ToDate=cast(@ToDate AS Nvarchar(500))

DECLARE @Pivot_GST_Column [nvarchar](max); 
DECLARE @Pivot_NET_Column [nvarchar](max); 
DECLARE @Pivot_GSTBase_Column [nvarchar](max); 
DECLARE @Pivot_NETBase_Column [nvarchar](max);
Declare @Tax_OP_Dync_SQL Nvarchar(Max)
Declare @Tax_IP_Dync_SQL Nvarchar(Max)

	If @Tax_CodeList<>'All'
	Begin
		SELECT @Pivot_GST_Column= COALESCE(@Pivot_GST_Column+',','')+ QUOTENAME(Code) FROM
		(Select Distinct Concat(Code,'_','GST') As Code From Bean.TaxCode (NOLOCK) Where Code in (Select Items From SplitToTable (@Tax_CodeList,','))) As A
	
		SELECT @Pivot_NET_Column= COALESCE(@Pivot_NET_Column+',','')+ QUOTENAME(Code) FROM
		(Select Distinct Concat(Code,'_','NET') As Code From Bean.TaxCode (NOLOCK) Where Code in (Select Items From SplitToTable (@Tax_CodeList,','))) As A

		--SELECT @Pivot_GSTBase_Column= COALESCE(@Pivot_GSTBase_Column+',','')+ QUOTENAME(Code) FROM
		--(Select Distinct Concat(Code,'_','GSTBase') As Code From Bean.TaxCode Where Code in (Select Items From SplitToTable (@Tax_CodeList,','))) As A
	
		--SELECT @Pivot_NETBase_Column= COALESCE(@Pivot_NETBase_Column+',','')+ QUOTENAME(Code) FROM
		--(Select Distinct Concat(Code,'_','NETBase') As Code From Bean.TaxCode Where Code in (Select Items From SplitToTable (@Tax_CodeList,','))) As A
	End
	If @Tax_CodeList='All'
	Begin
		SELECT @Pivot_GST_Column= COALESCE(@Pivot_GST_Column+',','')+ QUOTENAME(Code) FROM
		(Select Distinct Concat(Code,'_','GST') As Code From Bean.TaxCode (NOLOCK) Where Code<>'NA' And Code Is Not Null) As A
	
		SELECT @Pivot_NET_Column= COALESCE(@Pivot_NET_Column+',','')+ QUOTENAME(Code) FROM
		(Select Distinct Concat(Code,'_','NET') As Code From Bean.TaxCode (NOLOCK) Where Code<>'NA' And Code Is Not Null) As A

		--SELECT @Pivot_GSTBase_Column= COALESCE(@Pivot_GSTBase_Column+',','')+ QUOTENAME(Code) FROM
		--(Select Distinct Concat(Code,'_','GSTBase') As Code From Bean.TaxCode Where Code<>'NA' And Code Is Not Null) As A
	
		--SELECT @Pivot_NETBase_Column= COALESCE(@Pivot_NETBase_Column+',','')+ QUOTENAME(Code) FROM
		--(Select Distinct Concat(Code,'_','NETBase') As Code From Bean.TaxCode Where Code<>'NA' And Code Is Not Null) As A
	End

	Declare @CompanyId NVarchar(Max) 
	select @CompanyId = dbo.DecryptCompanyValue(@CompanyValue) 
	If @Tax_CodeList<>'All'
	Begin
		Set @Tax_OP_Dync_SQL='Select  DocType,DocDate,[Doc Ref No],DocNo,Entity,ISNULL(DocDescription,''-'') AS DocDescription,[Tax Code],[TAX RATE IN VAR],' + @Pivot_GST_Column + ',TOTAL_GST,TOTAL_GSTBase,' + @Pivot_NET_Column + ',TOTAL_NET,TOTAL_NETBase, IsNull(TOTAL_GST,0) + TOTAL_NET AS [Gross Amount],IsNull(TOTAL_GSTBase,0) + TOTAL_NETBase AS [BaseGross Amount],
						COA,[Account Type],[Service Comapany],DocumentId,ServiceCompanyId,DocSubType From
						(
							SELECT DT1.DocType,DT1.DocDate,DT1.[Doc Ref No],DT1.DocNo,DT1.Entity,DT1.DocDescription,DT1.[Tax Code],Concat(DT1.[Tax Code],''_'',''GST'') As Tax_GST,Concat(DT1.[Tax Code],''_'',''NET'') As Tax_NET,ISNULL(DT1.[TAX RATE IN VAR],''0%'') AS [TAX RATE IN VAR],DT1.COA,DT1.[Account Type],SUM(DT1.[Net Amount]) [Net Amount],SUM(DT1.[BaseNet Amount]) [BaseNet Amount],DT1.[Service Comapany],Sum(DT2.BaseCredit)  BaseCredit,Sum(DT2.BaseCreditTax)  BaseCreditTax,Sum(DT2.BaseCredit) As TOTAL_GST,Sum(DT2.BaseCreditTax) As TOTAL_GSTBase
							   ,DT1.DocumentId,DT1.ServiceCompanyId,DT1.DocSubType,Sum(DT1.[Net Amount]) As TOTAL_NET,Sum(DT1.[BaseNet Amount]) As TOTAL_NETBase
							FROM
									(
										SELECT JD.DocType,JD.DocDate,JD.SystemRefNo AS [Doc Ref No],JD.DocNo,E.Name AS Entity,
										Jd.AccountDescription DocDescription,
													 JD.TaxId,TC.Code AS [Tax Code],JD.TaxRate,CONVERT(VARCHAR(100),JD.TaxRate)+''''+''%'' AS [TAX RATE IN VAR],
													 COA.Name AS COA,ACT.Name AS [Account Type],
													 Case When ' + '''' + @Tax_Type + '''' + '=''Output'' Then ISNULL(JD.GSTTaxCredit,0)-ISNULL(JD.GSTTaxDebit,0)
														  When ' + '''' + @Tax_Type + '''' + '=''Input'' Then ISNULL(JD.GSTTaxDebit,0)-ISNULL(JD.GSTTaxCredit,0) End as [Net Amount],
														  Case When ' + '''' + @Tax_Type + '''' + '=''Output'' Then ISNULL(JD.BaseCredit,0)-ISNULL(JD.BaseDebit,0)
														  When ' + '''' + @Tax_Type + '''' + '=''Input'' Then ISNULL(JD.BaseDebit,0)-ISNULL(JD.BaseCredit,0) End as [BaseNet Amount],
														  SC.Name AS [Service Comapany],jd.JournalId,
													 Case When (JD.DocType=''Credit Note'' And JD.DocSubType=''Application'') Then CNA.InvoiceId 
														  When (JD.DocType=''Credit Memo'' And JD.DocSubType=''Application'') Then CMA.CreditMemoId
														  When (JD.DocType=''Debt Provision'' And JD.DocSubType=''Allocation'') Then DBA.InvoiceId Else JD.DocumentId End as DocumentId,
														  JD.DocumentDetailId,JD.ServiceCompanyId,JD.DocSubType,JD.Id AS JournalDetailId
										FROM Bean.JournalDetail AS JD (NOLOCK)
										INNER JOIN Bean.Journal AS J (NOLOCK) ON J.Id=JD.JournalId
										INNER JOIN Bean.ChartOfAccount AS COA (NOLOCK) ON COA.Id=JD.COAId
										INNER JOIN Bean.AccountType AS ACT (NOLOCK) ON ACT.Id=COA.AccountTypeId
										LEFT JOIN Bean.Entity AS E (NOLOCK) ON E.Id=JD.EntityId
										INNER JOIN Bean.TaxCode AS TC (NOLOCK) ON TC.Id=JD.TaxId
										INNER JOIN Common.Company AS SC (NOLOCK) ON SC.Id=JD.ServiceCompanyId
										Left Join Bean.CreditNoteApplication CNA (NOLOCK) On CNA.Id = JD.DocumentId
										Left Join Bean.CreditMemoApplication CMA (NOLOCK) On CMA.Id = JD.DocumentId
										Left Join Bean.DoubtfulDebtAllocation DBA (NOLOCK) on DBA.Id=JD.DocumentId
										WHERE COA.CompanyId=' + @CompanyId + ' AND JD.PostingDate BETWEEN '+ '''' + @FromDate +''''+' AND ' + '''' + @ToDate + '''' +'
													 AND JD.DocType  NOT IN  (''Journal'') 
													 AND JD.IsTax<>1 AND J.DocumentState <> ''Void'' 
													 AND DocumentDetailId<>''00000000-0000-0000-0000-000000000000''
													 And TC.Code in (Select Items From SplitToTable (' + '''' + @Tax_CodeList + '''' + ','',''))
													 And TC.TaxType=' + '''' + @Tax_Type + '''' + '
									) AS DT1
									
									INNER JOIN
									(
										SELECT  Case When ' + '''' + @Tax_Type + '''' + '=''Output'' Then (ISNULL(JD.GSTCredit,0)-ISNULL(JD.GSTDebit,0))
													 When ' + '''' + @Tax_Type + '''' + '=''Input'' Then (ISNULL(JD.GSTDebit,0)-ISNULL(JD.GSTCredit,0)) End As BaseCredit,
													 Case When ' + '''' + @Tax_Type + '''' + '=''Output'' Then (ISNULL(JD.BaseTaxCredit,0)-ISNULL(JD.BaseTaxDebit,0))
													 When ' + '''' + @Tax_Type + '''' + '=''Input'' Then (ISNULL(JD.BaseTaxDebit,0)-ISNULL(JD.BaseTaxCredit,0)) End As BaseCreditTax,
													 jd.JournalId,Case When (JD.DocType=''Credit Note'' And JD.DocSubType=''Application'') Then CNA.InvoiceId 
														  When (JD.DocType=''Credit Memo'' And JD.DocSubType=''Application'') Then CMA.CreditMemoId
														  When (JD.DocType=''Debt Provision'' And JD.DocSubType=''Allocation'') Then DBA.InvoiceId Else JD.DocumentId End as DocumentId,JD.DocumentDetailId,SC.Name AS [Service Comapany],JD.ServiceCompanyId,JD.DocSubType,JD.Id AS JournalDetailId
										FROM Bean.JournalDetail AS JD (NOLOCK)
										INNER JOIN Bean.Journal AS J (NOLOCK) ON J.Id=JD.JournalId
										INNER JOIN Bean.ChartOfAccount AS COA (NOLOCK) ON COA.Id=JD.COAId
										INNER JOIN Bean.AccountType AS ACT (NOLOCK) ON ACT.Id=COA.AccountTypeId
										LEFT JOIN Bean.Entity AS E (NOLOCK) ON E.Id=JD.EntityId
										INNER JOIN Bean.TaxCode AS TC (NOLOCK) ON TC.Id=JD.TaxId
										INNER JOIN Common.Company AS SC (NOLOCK) ON SC.Id=JD.ServiceCompanyId
										Left Join Bean.CreditNoteApplication CNA (NOLOCK) On CNA.Id = JD.DocumentId
										Left Join Bean.CreditMemoApplication CMA (NOLOCK) On CMA.Id = JD.DocumentId
										Left Join Bean.DoubtfulDebtAllocation DBA (NOLOCK) on DBA.Id=JD.DocumentId
										WHERE COA.CompanyId= ' + @CompanyId + ' AND JD.PostingDate BETWEEN ' + '''' + @FromDate + '''' +' AND ' + ''''+ @ToDate + '''' + '
													 AND JD.DocType  NOT IN  (''Journal'') 
													 AND JD.IsTax<>1  AND J.DocumentState <> ''Void'' 
													 AND DocumentDetailId<>''00000000-0000-0000-0000-000000000000''
													 AND JD.TaxId IS NOT NULL 
													 And TC.TaxType=' + '''' + @Tax_Type + '''' + '
													 And TC.Code In (Select Items From SplitToTable (' + '''' + @Tax_CodeList + '''' + ','',''))
									) AS DT2 ON DT1.JournalId=DT2.JournalId AND DT1.DocumentId=DT2.DocumentId AND DT1.JournalDetailId=DT2.JournalDetailId AND DT1.[Service Comapany]=DT2.[Service Comapany] AND DT1.JournalId=DT2.JournalId
									WHERE DT1.ServiceCompanyId=' + ''''+ @ServiceCompany +''''+ ' 
									Group By DT1.DocType,DT1.DocDate,DT1.[Doc Ref No],DT1.DocNo,DT1.Entity,DT1.DocDescription,DT1.[Tax Code],Concat(DT1.[Tax Code],''_'',''GST''),Concat(DT1.[Tax Code],''_'',''NET''),Concat(DT1.[Tax Code],''_'',''GSTBase''),Concat(DT1.[Tax Code],''_'',''NETBase''),ISNULL(DT1.[TAX RATE IN VAR],''0%''),DT1.COA,DT1.[Account Type],DT1.[Service Comapany],
									DT1.DocumentId,DT1.ServiceCompanyId,DT1.DocSubType
				Union all
					SELECT DT20.DocType,DT20.DocDate,DT20.[Doc Ref No],DT20.DocNo,DT20.Entity,DT20.DocDescription,DT20.[Tax Code],Concat(DT20.[Tax Code],''_'',''GST'') As Tax_GST,Concat(DT20.[Tax Code],''_'',''NET'') As Tax_NET,ISNULL(DT20.[TAX RATE IN VAR],''0%'') AS [TAX RATE IN VAR],DT20.COA,DT20.[Account Type],
					SUM(DT20.[Net Amount]) [Net Amount],SUM(DT20.[BaseNet Amount]) [BaseNet Amount],DT20.[Service Comapany],SUM(DT19.BaseCredit) BaseCredit,SUM(DT19.BaseCreditTax) BaseCreditTax,SUM(DT19.BaseCredit)  As TOTAL_GST,SUM(DT19.BaseCreditTax)  As TOTAL_GSTBase
							   ,DT20.DocumentId,DT20.ServiceCompanyId,DT20.DocSubType,SUM(DT20.[Net Amount]) As TOTAL_NET,SUM(DT20.[BaseNet Amount]) As TOTAL_NETBase
					FROM
					(
						SELECT JD.DocType,JD.DocDate,JD.SystemRefNo AS [Doc Ref No],JD.DocNo,E.Name AS Entity,
						Jd.AccountDescription  as DocDescription,
									 JD.TaxId,TC.Code AS [Tax Code],JD.TaxRate,CONVERT(VARCHAR(100),JD.TaxRate)+''''+''%'' AS [TAX RATE IN VAR],
									 COA.Name AS COA,ACT.Name AS [Account Type],
									 Case When ' + '''' + @Tax_Type + '''' + '=''Output'' Then ISNULL(JD.GSTTaxCredit,0)-ISNULL(JD.GSTTaxDebit,0)
										When ' + '''' + @Tax_Type + '''' + '=''Input'' Then ISNULL(JD.GSTTaxDebit,0)-ISNULL(JD.GSTTaxCredit,0) End as [Net Amount], Case When ' + '''' + @Tax_Type + '''' + '=''Output'' Then ISNULL(JD.BaseCredit,0)-ISNULL(JD.BaseDebit,0)
										When ' + '''' + @Tax_Type + '''' + '=''Input'' Then ISNULL(JD.BaseDebit,0)-ISNULL(JD.BaseCredit,0) End as [BaseNet Amount],SC.Name AS [Service Comapany],jd.JournalId,
									Case When (JD.DocType=''Credit Note'' And JD.DocSubType=''Application'') Then CNA.InvoiceId 
										  When (JD.DocType=''Credit Memo'' And JD.DocSubType=''Application'') Then CMA.CreditMemoId
										  When (JD.DocType=''Debt Provision'' And JD.DocSubType=''Allocation'') Then DBA.InvoiceId Else JD.DocumentId End as DocumentId,
									JD.DocumentDetailId,JD.ServiceCompanyId,Jd.DocSubType,JD.Id AS JournalDetailId
						FROM Bean.JournalDetail AS JD (NOLOCK)
						INNER JOIN Bean.Journal AS J (NOLOCK) ON J.Id=JD.JournalId
						INNER JOIN Bean.ChartOfAccount AS COA (NOLOCK) ON COA.Id=JD.COAId
						INNER JOIN Bean.AccountType AS ACT (NOLOCK) ON ACT.Id=COA.AccountTypeId
						LEFT JOIN Bean.Entity AS E (NOLOCK) ON E.Id=JD.EntityId
						INNER JOIN Bean.TaxCode AS TC (NOLOCK) ON TC.Id=JD.TaxId
						INNER JOIN Common.Company AS SC (NOLOCK) ON SC.Id=JD.ServiceCompanyId
						Left Join Bean.CreditNoteApplication CNA (NOLOCK) On CNA.Id = JD.DocumentId
						Left Join Bean.CreditMemoApplication CMA (NOLOCK) On CMA.Id = JD.DocumentId
						Left Join Bean.DoubtfulDebtAllocation DBA (NOLOCK) on DBA.Id=JD.DocumentId
						WHERE COA.CompanyId=' + @CompanyId + ' AND JD.PostingDate BETWEEN ' + '''' + @FromDate + '''' + ' AND ' + '''' + @ToDate + '''' + '
									 AND JD.DocType  IN  (''Journal'') 
									 AND (JD.IsTax<>1 OR JD.IsTax IS NULL)
									 AND J.DocumentState <> ''Void'' 
									 And TC.TaxType=' + '''' + @Tax_Type + '''' + '
									 And TC.Code In (Select Items From SplitToTable (' + '''' + @Tax_CodeList + '''' + ','',''))
									 AND DocumentDetailId=''00000000-0000-0000-0000-000000000000''
					) AS DT20
		
					INNER JOIN
					(
						SELECT Case When ' + '''' + @Tax_Type + '''' + '=''Output'' Then (ISNULL(JD.GSTCredit,0)-ISNULL(JD.GSTDebit,0))
													 When ' + '''' + @Tax_Type + '''' + '=''Input'' Then (ISNULL(JD.GSTDebit,0)-ISNULL(JD.GSTCredit,0)) End As BaseCredit,Case When ' + '''' + @Tax_Type + '''' + '=''Output'' Then (ISNULL(JD.BaseTaxCredit,0)-ISNULL(JD.BaseTaxDebit,0))
													 When ' + '''' + @Tax_Type + '''' + '=''Input'' Then (ISNULL(JD.BaseTaxDebit,0)-ISNULL(JD.BaseTaxCredit,0)) End As BaseCreditTax,jd.JournalId,
						Case When (JD.DocType=''Credit Note'' And JD.DocSubType=''Application'') Then CNA.InvoiceId 
										  When (JD.DocType=''Credit Memo'' And JD.DocSubType=''Application'') Then CMA.CreditMemoId
										  When (JD.DocType=''Debt Provision'' And JD.DocSubType=''Allocation'') Then DBA.InvoiceId Else JD.DocumentId End as DocumentId,JD.DocumentDetailId,SC.Name AS [Service Comapany],JD.Id JournalDetailId,JD.ServiceCompanyId,Jd.DocSubType
						FROM Bean.JournalDetail AS JD (NOLOCK)
						INNER JOIN Bean.Journal AS J (NOLOCK) ON J.Id=JD.JournalId
						INNER JOIN Bean.ChartOfAccount AS COA (NOLOCK) ON COA.Id=JD.COAId
						INNER JOIN Bean.AccountType AS ACT (NOLOCK) ON ACT.Id=COA.AccountTypeId
						LEFT JOIN Bean.Entity AS E (NOLOCK) ON E.Id=JD.EntityId
						INNER JOIN Bean.TaxCode AS TC (NOLOCK) ON TC.Id=JD.TaxId
						INNER JOIN Common.Company AS SC (NOLOCK) ON SC.Id=JD.ServiceCompanyId
						Left Join Bean.CreditNoteApplication CNA (NOLOCK) On CNA.Id = JD.DocumentId
										Left Join Bean.CreditMemoApplication CMA (NOLOCK) On CMA.Id = JD.DocumentId
										Left Join Bean.DoubtfulDebtAllocation DBA (NOLOCK) on DBA.Id=JD.DocumentId
						WHERE COA.CompanyId=' + @CompanyId + ' AND JD.PostingDate BETWEEN ' + '''' + @FromDate + '''' + ' AND ' + '''' + @ToDate + '''' + '
									 AND JD.DocType  IN  (''Journal'') 
									 AND (JD.IsTax<>1 OR JD.IsTax IS NULL)
									 AND J.DocumentState <> ''Void''
									 And TC.TaxType=' + '''' + @Tax_Type + '''' + '
									 AND DocumentDetailId=''00000000-0000-0000-0000-000000000000''
									 And TC.Code In (Select Items From SplitToTable (' + '''' + @Tax_CodeList + '''' + ','',''))
					) AS DT19 ON DT20.JournalId=DT19.JournalId
					AND DT19.JournalId=DT20.DocumentId AND DT19.JournalDetailId=DT20.JournalDetailId
					AND DT20.[Service Comapany]=DT19.[Service Comapany]
					Where DT19.ServiceCompanyId=' + '''' + @ServiceCompany + '''' + '
					Group By DT20.DocType,DT20.DocDate,DT20.[Doc Ref No],DT20.DocNo,DT20.Entity,DT20.DocDescription,DT20.[Tax Code],Concat(DT20.[Tax Code],''_'',''GST'') ,Concat(DT20.[Tax Code],''_'',''NET''),Concat(DT20.[Tax Code],''_'',''GSTBase''),Concat(DT20.[Tax Code],''_'',''NETBase''),ISNULL(DT20.[TAX RATE IN VAR],''0%''),DT20.COA,DT20.[Account Type],DT20.[Service Comapany],
							   DT20.DocumentId,DT20.ServiceCompanyId,DT20.DocSubType
				) As Tax
				PIVOT  
				(  
				SUM(BaseCredit) FOR [Tax_GST] IN (' + @Pivot_GST_Column + ')
				) AS Tab2  
				PIVOT  
				(  
				SUM([Net Amount]) FOR [Tax_NET] IN (' + @Pivot_NET_Column + ')
				) AS Tab3 
				ORDER BY Tab3.DocType,Tab3.DocDate'
		End
		Else
		Begin
			Set @Tax_OP_Dync_SQL='Select  DocType,DocDate,[Doc Ref No],DocNo,Entity,ISNULL(DocDescription,''-'') AS DocDescription,[Tax Code],[TAX RATE IN VAR],' + @Pivot_GST_Column + ',TOTAL_GST,TOTAL_GSTBase,' + @Pivot_NET_Column + ',TOTAL_NET,TOTAL_NETBase,ISNULL(TOTAL_GST,0) + TOTAL_NET AS [Gross Amount],IsNull(TOTAL_GSTBase,0) + TOTAL_NETBase AS [BaseGross Amount],
						COA,[Account Type],[Service Comapany],DocumentId,ServiceCompanyId,DocSubType From
						(
							SELECT DT1.DocType,DT1.DocDate,DT1.[Doc Ref No],DT1.DocNo,DT1.Entity,DT1.DocDescription,DT1.[Tax Code],Concat(DT1.[Tax Code],''_'',''GST'') As Tax_GST,Concat(DT1.[Tax Code],''_'',''NET'') As Tax_NET,ISNULL(DT1.[TAX RATE IN VAR],''0%'') AS [TAX RATE IN VAR],DT1.COA,DT1.[Account Type],SUM(DT1.[Net Amount]) AS [Net Amount],SUM(DT1.[BaseNet Amount]) AS [BaseNet Amount],DT1.[Service Comapany],SUM(DT2.BaseCredit) AS BaseCredit,SUM(DT2.BaseCreditTax) AS BaseCreditTax,SUM(DT2.BaseCredit) As TOTAL_GST,SUM(DT2.BaseCreditTax) As TOTAL_GSTBase
							   ,DT1.DocumentId,DT1.ServiceCompanyId,DT1.DocSubType,SUM(DT1.[Net Amount]) As TOTAL_NET,SUM(DT1.[BaseNet Amount]) As TOTAL_NETBase
							FROM
								(
									SELECT JD.DocType,JD.DocDate,JD.SystemRefNo AS [Doc Ref No],JD.DocNo,E.Name AS Entity,
									Jd.AccountDescription as DocDescription,
												 JD.TaxId,TC.Code AS [Tax Code],JD.TaxRate,CONVERT(VARCHAR(100),JD.TaxRate)+''''+''%'' AS [TAX RATE IN VAR],
												 COA.Name AS COA,ACT.Name AS [Account Type],
												 Case When ' + '''' + @Tax_Type + '''' + '=''Output'' Then ISNULL(JD.GSTTaxCredit,0)-ISNULL(JD.GSTTaxDebit,0)
													  When ' + '''' + @Tax_Type + '''' + '=''Input'' Then ISNULL(JD.GSTTaxDebit,0)-ISNULL(JD.GSTTaxCredit,0) End as [Net Amount],Case When ' + '''' + @Tax_Type + '''' + '=''Output'' Then ISNULL(JD.BaseCredit,0)-ISNULL(JD.BaseDebit,0)
													  When ' + '''' + @Tax_Type + '''' + '=''Input'' Then ISNULL(JD.BaseDebit,0)-ISNULL(JD.BaseCredit,0) End as [BaseNet Amount],SC.Name AS [Service Comapany],jd.JournalId,
												 Case When (JD.DocType=''Credit Note'' And JD.DocSubType=''Application'') Then CNA.InvoiceId 
													  When (JD.DocType=''Credit Memo'' And JD.DocSubType=''Application'') Then CMA.CreditMemoId
													  When (JD.DocType=''Debt Provision'' And JD.DocSubType=''Allocation'') Then DBA.InvoiceId Else JD.DocumentId End as DocumentId,
												JD.DocumentDetailId,JD.ServiceCompanyId,JD.DocSubType,JD.Id JournalDetailId
									FROM Bean.JournalDetail AS JD (NOLOCK)
									INNER JOIN Bean.Journal AS J (NOLOCK) ON J.Id=JD.JournalId
									INNER JOIN Bean.ChartOfAccount AS COA (NOLOCK) ON COA.Id=JD.COAId
									INNER JOIN Bean.AccountType AS ACT (NOLOCK) ON ACT.Id=COA.AccountTypeId
									LEFT JOIN Bean.Entity AS E (NOLOCK) ON E.Id=JD.EntityId
									INNER JOIN Bean.TaxCode AS TC (NOLOCK) ON TC.Id=JD.TaxId
									INNER JOIN Common.Company AS SC (NOLOCK) ON SC.Id=JD.ServiceCompanyId
									Left Join Bean.CreditNoteApplication CNA (NOLOCK) On CNA.Id = JD.DocumentId
									Left Join Bean.CreditMemoApplication CMA (NOLOCK) On CMA.Id = JD.DocumentId
									Left Join Bean.DoubtfulDebtAllocation DBA (NOLOCK) on DBA.Id=JD.DocumentId
									WHERE COA.CompanyId=' + @CompanyId + ' AND JD.PostingDate BETWEEN '+ '''' + @FromDate +''''+' AND ' + '''' + @ToDate + '''' +'
												 AND JD.DocType  NOT IN  (''Journal'') 
												 AND JD.IsTax<>1 AND J.DocumentState <> ''Void'' 
												 And TC.TaxType=' + '''' + @Tax_Type + '''' + '
												 AND DocumentDetailId<>''00000000-0000-0000-0000-000000000000''
								) AS DT1
								
								INNER JOIN
								(
									SELECT  Case When ' + '''' + @Tax_Type + '''' + '=''Output'' Then (ISNULL(JD.GSTCredit,0)-ISNULL(JD.GSTDebit,0))
												 When ' + '''' + @Tax_Type + '''' + '=''Input'' Then (ISNULL(JD.GSTDebit,0)-ISNULL(JD.GSTCredit,0)) End As BaseCredit,Case When ' + '''' + @Tax_Type + '''' + '=''Output'' Then (ISNULL(JD.BaseTaxCredit,0)-ISNULL(JD.BaseTaxDebit,0))
												 When ' + '''' + @Tax_Type + '''' + '=''Input'' Then (ISNULL(JD.BaseTaxDebit,0)-ISNULL(JD.BaseTaxCredit,0)) End As BaseCreditTax,jd.JournalId,Case When (JD.DocType=''Credit Note'' And JD.DocSubType=''Application'') Then CNA.InvoiceId 
													  When (JD.DocType=''Credit Memo'' And JD.DocSubType=''Application'') Then CMA.CreditMemoId
													  When (JD.DocType=''Debt Provision'' And JD.DocSubType=''Allocation'') Then DBA.InvoiceId Else JD.DocumentId End as DocumentId,JD.DocumentDetailId,SC.Name AS [Service Comapany],JD.ServiceCompanyId,JD.DocSubType,JD.Id JournalDetailId
									FROM Bean.JournalDetail AS JD (NOLOCK)
									INNER JOIN Bean.Journal AS J (NOLOCK) ON J.Id=JD.JournalId
									INNER JOIN Bean.ChartOfAccount AS COA (NOLOCK) ON COA.Id=JD.COAId
									INNER JOIN Bean.AccountType AS ACT (NOLOCK) ON ACT.Id=COA.AccountTypeId
									LEFT JOIN Bean.Entity AS E (NOLOCK) ON E.Id=JD.EntityId
									INNER JOIN Bean.TaxCode AS TC (NOLOCK) ON TC.Id=JD.TaxId
									INNER JOIN Common.Company AS SC (NOLOCK) ON SC.Id=JD.ServiceCompanyId
									Left Join Bean.CreditNoteApplication CNA (NOLOCK) On CNA.Id = JD.DocumentId
									Left Join Bean.CreditMemoApplication CMA (NOLOCK) On CMA.Id = JD.DocumentId
									Left Join Bean.DoubtfulDebtAllocation DBA (NOLOCK) on DBA.Id=JD.DocumentId
									WHERE COA.CompanyId= ' + @CompanyId + ' AND JD.PostingDate BETWEEN ' + '''' + @FromDate + '''' +' AND ' + ''''+ @ToDate + '''' + '
												 AND JD.DocType  NOT IN  (''Journal'') 
												 AND JD.IsTax<>1  AND J.DocumentState <> ''Void'' 
												 AND DocumentDetailId<>''00000000-0000-0000-0000-000000000000''
												 AND JD.TaxId IS NOT NULL 
												 And TC.TaxType=' + '''' + @Tax_Type + '''' + '
								) AS DT2 ON DT1.JournalId=DT2.JournalId AND DT1.DocumentId=DT2.DocumentId 
								AND DT1.JournalDetailId=DT2.JournalDetailId
								AND DT1.DocumentDetailId=DT2.DocumentDetailId AND DT1.[Service Comapany]=DT2.[Service Comapany]
								WHERE DT1.ServiceCompanyId=' + ''''+ @ServiceCompany +''''+ ' 
								Group By DT1.DocType,DT1.DocDate,DT1.[Doc Ref No],DT1.DocNo,DT1.Entity,DT1.DocDescription,DT1.[Tax Code],Concat(DT1.[Tax Code],''_'',''GST''),Concat(DT1.[Tax Code],''_'',''NET''),Concat(DT1.[Tax Code],''_'',''GSTBase''),Concat(DT1.[Tax Code],''_'',''NETBase''),ISNULL(DT1.[TAX RATE IN VAR],''0%''),DT1.COA,DT1.[Account Type],DT1.[Service Comapany],
									DT1.DocumentId,DT1.ServiceCompanyId,DT1.DocSubType
			Union all
				SELECT DT20.DocType,DT20.DocDate,DT20.[Doc Ref No],DT20.DocNo,DT20.Entity,DT20.DocDescription,DT20.[Tax Code],Concat(DT20.[Tax Code],''_'',''GST'') As Tax_GST,Concat(DT20.[Tax Code],''_'',''NET'') As Tax_NET,ISNULL(DT20.[TAX RATE IN VAR],''0%'') AS [TAX RATE IN VAR],DT20.COA,DT20.[Account Type],SUM(DT20.[Net Amount]) AS [Net Amount],SUM(DT20.[BaseNet Amount]) AS [BaseNet Amount],DT20.[Service Comapany],SUM(DT19.BaseCredit) AS BaseCredit,SUM(DT19.BaseCreditTax) AS BaseCreditTax,SUM(DT19.BaseCredit)  As TOTAL_GST,SUM(DT19.BaseCreditTax) As TOTAL_GSTBase
						   ,DT20.DocumentId,DT20.ServiceCompanyId,DT20.DocSubType,SUM(DT20.[Net Amount]) As TOTAL_NET,SUM(DT20.[BaseNet Amount]) As TOTAL_NETBase
				FROM
				(
					SELECT JD.DocType,JD.DocDate,JD.SystemRefNo AS [Doc Ref No],JD.DocNo,E.Name AS Entity,
					Jd.AccountDescription as DocDescription,
								 JD.TaxId,TC.Code AS [Tax Code],JD.TaxRate,CONVERT(VARCHAR(100),JD.TaxRate)+''''+''%'' AS [TAX RATE IN VAR],
								 COA.Name AS COA,ACT.Name AS [Account Type],
								 Case When ' + '''' + @Tax_Type + '''' + '=''Output'' Then ISNULL(JD.GSTTaxCredit,0)-ISNULL(JD.GSTTaxDebit,0)
									When ' + '''' + @Tax_Type + '''' + '=''Input'' Then ISNULL(JD.GSTTaxDebit,0)-ISNULL(JD.GSTTaxCredit,0) End as [Net Amount],Case When ' + '''' + @Tax_Type + '''' + '=''Output'' Then ISNULL(JD.BaseCredit,0)-ISNULL(JD.BaseDebit,0)
									When ' + '''' + @Tax_Type + '''' + '=''Input'' Then ISNULL(JD.BaseDebit,0)-ISNULL(JD.BaseCredit,0) End as [BaseNet Amount],SC.Name AS [Service Comapany],jd.JournalId,
								Case When (JD.DocType=''Credit Note'' And JD.DocSubType=''Application'') Then CNA.InvoiceId 
								When (JD.DocType=''Credit Memo'' And JD.DocSubType=''Application'') Then CMA.CreditMemoId
								When (JD.DocType=''Debt Provision'' And JD.DocSubType=''Allocation'') Then DBA.InvoiceId Else JD.DocumentId End as DocumentId,
								JD.DocumentDetailId,JD.ServiceCompanyId,Jd.DocSubType,JD.Id JournalDetailId
					FROM Bean.JournalDetail AS JD (NOLOCK)
					INNER JOIN Bean.Journal AS J (NOLOCK) ON J.Id=JD.JournalId
					INNER JOIN Bean.ChartOfAccount AS COA (NOLOCK) ON COA.Id=JD.COAId
					INNER JOIN Bean.AccountType AS ACT (NOLOCK) ON ACT.Id=COA.AccountTypeId
					LEFT JOIN Bean.Entity AS E (NOLOCK) ON E.Id=JD.EntityId
					INNER JOIN Bean.TaxCode AS TC (NOLOCK) ON TC.Id=JD.TaxId
					INNER JOIN Common.Company AS SC (NOLOCK) ON SC.Id=JD.ServiceCompanyId
					Left Join Bean.CreditNoteApplication CNA (NOLOCK) On CNA.Id = JD.DocumentId
					Left Join Bean.CreditMemoApplication CMA (NOLOCK) On CMA.Id = JD.DocumentId
					Left Join Bean.DoubtfulDebtAllocation DBA (NOLOCK) on DBA.Id=JD.DocumentId
					WHERE COA.CompanyId=' + @CompanyId + ' AND JD.PostingDate BETWEEN ' + '''' + @FromDate + '''' + ' AND ' + '''' + @ToDate + '''' + '
								 AND JD.DocType  IN  (''Journal'') 
								 AND (JD.IsTax<>1 OR JD.IsTax IS NULL)
								 AND J.DocumentState <> ''Void'' 
								 And TC.TaxType=' + '''' + @Tax_Type + '''' + '
								 
								 AND DocumentDetailId=''00000000-0000-0000-0000-000000000000''
				) AS DT20
		
				INNER JOIN
				(
					SELECT Case When ' + '''' + @Tax_Type + '''' + '=''Output'' Then (ISNULL(JD.GSTCredit,0)-ISNULL(JD.GSTDebit,0))
												 When ' + '''' + @Tax_Type + '''' + '=''Input'' Then (ISNULL(JD.GSTDebit,0)-ISNULL(JD.GSTCredit,0)) End As BaseCredit,Case When ' + '''' + @Tax_Type + '''' + '=''Output'' Then (ISNULL(JD.BaseTaxCredit,0)-ISNULL(JD.BaseTaxDebit,0))
												 When ' + '''' + @Tax_Type + '''' + '=''Input'' Then (ISNULL(JD.BaseTaxDebit,0)-ISNULL(JD.BaseTaxCredit,0)) End As BaseCreditTax,jd.JournalId,
					Case When (JD.DocType=''Credit Note'' And JD.DocSubType=''Application'') Then CNA.InvoiceId 
								When (JD.DocType=''Credit Memo'' And JD.DocSubType=''Application'') Then CMA.CreditMemoId
								When (JD.DocType=''Debt Provision'' And JD.DocSubType=''Allocation'') Then DBA.InvoiceId Else JD.DocumentId End as DocumentId,JD.DocumentDetailId,SC.Name AS [Service Comapany],JD.Id JournalDetailId,JD.ServiceCompanyId,Jd.DocSubType
					FROM Bean.JournalDetail AS JD (NOLOCK)
					INNER JOIN Bean.Journal AS J (NOLOCK) ON J.Id=JD.JournalId
					INNER JOIN Bean.ChartOfAccount AS COA (NOLOCK) ON COA.Id=JD.COAId
					INNER JOIN Bean.AccountType AS ACT (NOLOCK) ON ACT.Id=COA.AccountTypeId
					LEFT JOIN Bean.Entity AS E (NOLOCK) ON E.Id=JD.EntityId
					INNER JOIN Bean.TaxCode AS TC (NOLOCK) ON TC.Id=JD.TaxId
					INNER JOIN Common.Company AS SC (NOLOCK) ON SC.Id=JD.ServiceCompanyId
					Left Join Bean.CreditNoteApplication CNA (NOLOCK) On CNA.Id = JD.DocumentId
					Left Join Bean.CreditMemoApplication CMA (NOLOCK) On CMA.Id = JD.DocumentId
					Left Join Bean.DoubtfulDebtAllocation DBA (NOLOCK) on DBA.Id=JD.DocumentId
					WHERE COA.CompanyId=' + @CompanyId + ' AND JD.PostingDate BETWEEN ' + '''' + @FromDate + '''' + ' AND ' + '''' + @ToDate + '''' + '
								 AND JD.DocType  IN  (''Journal'') 
								 AND (JD.IsTax<>1 OR JD.IsTax IS NULL)
								 AND J.DocumentState <> ''Void''
								 AND DocumentDetailId=''00000000-0000-0000-0000-000000000000''
								 And TC.TaxType=' + '''' + @Tax_Type + '''' + '
				) AS DT19 ON DT20.JournalId=DT19.JournalId
				AND DT19.JournalId=DT20.DocumentId AND DT19.JournalDetailId=DT20.JournalDetailId
				AND DT20.[Service Comapany]=DT19.[Service Comapany]
				Where DT19.ServiceCompanyId=' + '''' + @ServiceCompany + '''' + '
				Group By DT20.DocType,DT20.DocDate,DT20.[Doc Ref No],DT20.DocNo,DT20.Entity,DT20.DocDescription,DT20.[Tax Code],Concat(DT20.[Tax Code],''_'',''GST'') ,Concat(DT20.[Tax Code],''_'',''NET''),Concat(DT20.[Tax Code],''_'',''GSTBase'') ,Concat(DT20.[Tax Code],''_'',''NETBase''),ISNULL(DT20.[TAX RATE IN VAR],''0%''),DT20.COA,DT20.[Account Type],DT20.[Service Comapany],
							   DT20.DocumentId,DT20.ServiceCompanyId,DT20.DocSubType
			) As Tax
			PIVOT  
			(  
			SUM(BaseCredit) FOR [Tax_GST] IN (' + @Pivot_GST_Column + ')
			) AS Tab2  
			PIVOT  
			(  
			SUM([Net Amount]) FOR [Tax_NET] IN (' + @Pivot_NET_Column + ')
			) AS Tab3 

			ORDER BY Tab3.DocType,Tab3.DocDate'
		End

		Exec (@Tax_OP_Dync_SQL)

		--Select @Tax_OP_Dync_SQL
END
GO
