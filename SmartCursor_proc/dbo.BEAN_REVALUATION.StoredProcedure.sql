USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[BEAN_REVALUATION]    Script Date: 16-12-2024 9.20.10 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

--exec [dbo].[BEAN_REVALUATION] 1632,'1633','2019-08-17'

CREATE PROCEDURE [dbo].[BEAN_REVALUATION]
(
@CompanyId int,
@ServiceCompanyId nvarchar(max),
@DocDate datetime2(7)
)
AS
BEGIN

Declare @SerEntity Table(Ids int)
Insert into @SerEntity
Select CAST(items as int) from dbo.SplitToTable(@ServiceCompanyId,',')

SELECT 'BANK' as TABLENAME,NULL as DocDate,c.ShortName as SevEntitity,'' as DocNo,Jd.DocCurrency as Currency,'' as DocType,NULL as OrgRate,SUM(ISNULL(JD.DocDebit,0))-SUM(ISNULL(JD.DocCredit,0)) as DocBal,0 as OrgRate,SUM(ISNULL(JD.BaseDebit,0))-SUM(ISNULL(JD.BaseCredit,0)) as BaseBal,COA.Name as EntName,COA.Name as COAName,'00000000-0000-0000-0000-000000000000' as EntityId,JD.COAId as COAID,JD.ServiceCompanyId as ServiceEntityId,'' as Nature,'00000000-0000-0000-0000-000000000000' as DocumentId,'' as COAClass
		FROM Bean.Journal(nolock) J INNER JOIN 
		Bean.JournalDetail(nolock) JD on JD.JournalId = J.Id INNER JOIN 
		Bean.ChartOfAccount(nolock) COA on JD.COAId = COA.Id LEFT JOIN 
		Bean.Entity(nolock) E on J.EntityId = E.Id INNER JOIN 
		Common.Company(nolock) c on J.ServiceCompanyId = c.Id 
		where JD.DocDate <= @DocDate 
		AND J.CompanyId = @CompanyId 
		AND J.DocumentState NOT IN('Fully Paid', 'Fully Applied', 'Void', 'Parked', 'Recurring') 
		AND JD.ServiceCompanyId in (Select Ids from @SerEntity) 
		--AND(JD.ClearingStatus <> 'Cleared' OR JD.ClearingDate is NULL) 
		AND J.DocSubType NOT IN('Revaluation', 'CM Application', 'Application')
		AND (JD.IsTax is NULL OR JD.IsTax=0) 
		AND JD.DocCurrency<> JD.BaseCurrency 
		AND COA.Revaluation = 1 AND COA.IsBank=1 
		--AND JD.DocumentDetailId<>'00000000-0000-0000-0000-000000000000' 
		group by c.ShortName,JD.DocCurrency,JD.COAId,COA.Name,JD.ServiceCompanyId,COA.Nature

	---New Code for other Than Bank Account
    SELECT 'OTHER' as TABLENAME,NULL as DocDate,c.ShortName as SevEntitity,'' as DocNo,'' as DocType,Jd.DocCurrency as Currency,
	--J.BalanceAmount as DocBal,
	
	 CASE WHEN COA.Nature='Credit' THEN ABS(SUM(ISNULL(JD.DocDebit,0))-SUM(ISNULL(JD.DocCredit,0))) ELSE SUM(ISNULL(JD.DocDebit,0))-SUM(ISNULL(JD.DocCredit,0)) END as DocBal,
	--J.ExchangeRate as OrgRate,
	NULL as OrgRate,
	CASE WHEN COA.Nature='Credit' THEN ABS(SUM(ISNULL(JD.BaseDebit,0))-SUM(ISNULL(JD.BaseCredit,0))) ELSE SUM(ISNULL(JD.BaseDebit,0))-SUM(ISNULL(JD.BaseCredit,0)) END as BaseBal,
	--SUM(ISNULL(J.BalanceAmount,0)*J.ExchangeRate) as BaseBal,
	--E.Name as EntName,
	COA.Name as EntName,
	COA.Name as COAName,
	--JD.EntityId as EntityId,
	 '00000000-0000-0000-0000-000000000000' AS EntityId,
	JD.COAId as COAID,
	JD.ServiceCompanyId as ServiceEntityId,
	COA.Nature as Nature,
	'00000000-0000-0000-0000-000000000000' as DocumentId,
	COA.Class as COAClass
	FROM Bean.Journal(nolock) J 
	INNER JOIN Bean.JournalDetail(nolock) JD on JD.JournalId=J.Id 
	INNER JOIN Bean.ChartOfAccount(nolock) COA on JD.COAId=COA.Id 
	INNER JOIN Bean.AccountType(nolock) ACC On ACC.Id=COA.AccountTypeId
	LEFT JOIN Bean.Entity(nolock) E on J.EntityId=E.Id	
	INNER JOIN Common.Company(nolock) c on J.ServiceCompanyId=c.Id  
	where JD.DocDate<=@DocDate 
	AND J.CompanyId=@CompanyId 
	--AND J.DocumentState NOT IN ('Fully Paid','Fully Applied','Void','Parked','Recurring') 
	AND J.DocumentState NOT IN ('Void','Parked','Recurring')
	AND J.ServiceCompanyId in (Select Ids from @SerEntity) 
	AND (JD.ClearingStatus<>'Cleared' OR JD.ClearingDate is NULL) 
	AND J.DocSubType NOT IN ('Reval','CM Application','Application')
	--AND J.DocType NOT IN ('Receipt','Bill Payment')
	--AND (JD.DocSubType NOT IN ('Opening Bal') AND JD.COAId NOT IN (Select Id from Bean.ChartOfAccount where Name in ('Trade receivables','Trade payables','Other receivables','Other payables') and CompanyId=@CompanyId))
	AND (JD.IsTax is NULL OR JD.IsTax=0)
	AND JD.DocCurrency<>JD.BaseCurrency 
	AND COA.Revaluation=1 AND (COA.IsBank is Null OR COA.IsBank=0) AND COA.Name NOT in ('Trade receivables','Trade payables','Other receivables','Other payables')
	AND ACC.Name<>'Intercompany billing'
	--group by JD.DocDate,c.ShortName,JD.DocNo,JD.DocType,Jd.DocCurrency,J.BalanceAmount,Case When j.ExchangeRate is null then JD.ExchangeRate else j.ExchangeRate End,E.Name,COA.Name,JD.EntityId,JD.COAId,JD.ServiceCompanyId,COA.Nature,J.DocumentId,JD.DocCredit,JD.DocDebit,J.DocType,J.DocSubType,JD.BaseDebit,JD.BaseCredit
	group by c.ShortName,JD.DocCurrency,JD.COAId,COA.Name,JD.ServiceCompanyId,COA.Nature,COA.Class



-----NEW QUERY

SELECT  'GENERAL' as TABLENAME,JD.PostingDate as DocDate,c.ShortName as SevEntitity,JD.DocNo as DocNo,JD.DocType as			DocType,Jd.DocCurrency as Currency,
	--J.BalanceAmount as DocBal,
	 CASE
		WHEN JD.DocType In ('Credit Memo' , 'Credit Note') 
			THEN -SUM(ISNULL(Doc.DocAppliedAmount,0)) 
		ELSE SUM(ISNULL(Doc.DocAppliedAmount,0)) 
	END
	as DocBal,
		--J.ExchangeRate as OrgRate,
		Case When j.ExchangeRate is null then JD.ExchangeRate else j.ExchangeRate End as OrgRate,
		CASE
				WHEN 
					JD.DocType In ('Credit Memo' , 'Credit Note') 
				THEN
					-SUM(ISNULL(Doc.BaseAppliedAmount,0)) 
					
				ELSE
					SUM(ISNULL(Doc.BaseAppliedAmount,0))
				END
		
	
	as BaseBal,
	--SUM(ISNULL(J.BalanceAmount,0)*J.ExchangeRate) as BaseBal,
	--E.Name as EntName,

	--Commented on 21/05/2020 for I/B reval changes.
	--CASE WHEN ((E.Name <> NULL OR E.Name <> '') AND COA.Name IN ('Trade receivables','Trade payables','Other receivables','Other payables')) THEN E.Name ELSE COA.Name END as EntName,
	E.Name as EntName,

	COA.Name as COAName,
	--JD.EntityId as EntityId,
	CASE WHEN JD.EntityId<>NULL OR JD.EntityId <> '00000000-0000-0000-0000-000000000000' THEN JD.EntityId ELSE '00000000-0000-0000-0000-000000000000' END AS EntityId,
	JD.COAId as COAID,JD.ServiceCompanyId as ServiceEntityId,COA.Nature as Nature,J.DocumentId as DocumentId,COA.Class as COAClass
	FROM Bean.Journal(nolock) J 
	INNER JOIN Bean.DocumentHistory(nolock) Doc on Doc.DocumentId=J.DocumentId and Doc.AgingState is null and Doc.PostingDate IS NOT NULL 
	INNER JOIN Bean.JournalDetail(nolock) JD on JD.JournalId=J.Id AND (JD.IsTax is NULL OR JD.IsTax=0) 
	
	INNER JOIN Bean.ChartOfAccount(nolock) COA on JD.COAId=COA.Id 

	INNER JOIN Bean.AccountType(nolock) ACC On ACC.Id=COA.AccountTypeId

	LEFT JOIN Bean.Entity(nolock) E on J.EntityId=E.Id	
	INNER JOIN Common.Company(nolock) c on J.ServiceCompanyId=c.Id 
	--New join query based on Document History
	where --JD.PostingDate<=@DocDate --commented because of New Approch
	Doc.PostingDate<=@DocDate--Insted of fetching the record from JD we are fetching from Doc
	AND J.CompanyId=@CompanyId 
	--AND J.DocumentState NOT IN ('Fully Paid','Fully Applied','Void','Parked','Recurring') 
	AND J.DocumentState NOT IN ('Void','Parked','Recurring')
	AND J.ServiceCompanyId in (Select Ids from @SerEntity) 
	AND (JD.ClearingStatus<>'Cleared' OR JD.ClearingDate is NULL) 
	AND J.DocSubType NOT IN ('Reval','CM Application','Application')
	AND J.DocType NOT IN ('Receipt','Bill Payment','Journal')
	--AND (JD.DocSubType NOT IN ('Opening Bal') AND JD.COAId NOT IN (Select Id from Bean.ChartOfAccount where Name in ('Trade receivables','Trade payables','Other receivables','Other payables') and CompanyId=@CompanyId))
	AND (JD.IsTax is NULL OR JD.IsTax=0)
	AND J.DocCurrency<>J.ExCurrency 
	AND COA.Revaluation=1 AND (COA.IsBank is Null OR COA.IsBank=0) AND (COA.Name in ('Trade receivables','Trade payables','Other receivables','Other payables') OR Acc.Name='Intercompany billing')
	AND (Doc.AgingState <>'Deleted' OR Doc.AgingState IS NULL)
	--and Doc.AgingState is null and Doc.PostingDate IS NOT NULL 
	group by JD.PostingDate,c.ShortName,JD.DocNo,JD.DocType,Jd.DocCurrency,Case When j.ExchangeRate is null then JD.ExchangeRate else j.ExchangeRate End,E.Name,COA.Name,JD.EntityId,JD.COAId,JD.ServiceCompanyId,COA.Nature,J.DocumentId,J.DocType,J.DocSubType,COA.Class

	---For OB--TR/OR/TP/OP records

	SELECT 'INVOICE' as TABLENAME,INV.DocDate as DocDate,c.ShortName as SevEntitity,INV.DocNo as DocNo,INV.DocType as			DocType,Jd.DocCurrency as Currency,
	Case When INV.DocType='Credit Note' Then -SUM(ISNULL(Doc.DocAppliedAmount,0)) ELSE SUM(ISNULL(Doc.DocAppliedAmount,0)) END as DocBal,
	INV.ExchangeRate as OrgRate,
	 Case When INV.DocType='Credit Note' Then -SUM(ISNULL(Doc.BaseAppliedAmount,0)) Else SUM(ISNULL(Doc.BaseAppliedAmount,0)) END as BaseBal,
	E.Name as EntName,
	COA.Name as COAName,
	JD.EntityId as EntityId,
	JD.COAId as COAID,JD.ServiceCompanyId as ServiceEntityId,COA.Nature as Nature,INV.Id as DocumentId,COA.Class as COAClass
	FROM Bean.JournalDetail(nolock) JD 
	INNER JOIN Bean.Invoice(nolock) INV on JD.DocumentDetailId=INV.Id
	INNER JOIN Bean.DocumentHistory(nolock) Doc on Doc.DocumentId=INV.Id and INV.DocSubType='Opening Bal'
	INNER JOIN Bean.ChartOfAccount(nolock) COA on JD.COAId=COA.Id 
	LEFT JOIN Bean.Entity(nolock) E on INV.EntityId=E.Id
	INNER JOIN Common.Company(nolock) c on INV.ServiceCompanyId=c.Id  
	where Doc.PostingDate<=@DocDate 
	AND INV.CompanyId=@CompanyId 
	--AND INV.DocumentState NOT IN ('Fully Paid','Fully Applied','Void','Parked','Recurring') 
	AND INV.DocumentState NOT IN ('Void','Parked','Recurring')
	AND JD.ServiceCompanyId in (Select Ids from @SerEntity) 
	AND (JD.ClearingStatus<>'Cleared' OR JD.ClearingDate is NULL) 
	AND JD.DocSubType NOT IN ('Reval','CM Application','Application')
	--AND JD.DocType NOT IN ('Receipt','Bill Payment')
	AND (JD.IsTax is NULL OR JD.IsTax=0)
	AND INV.DocCurrency<>INV.ExCurrency 
	AND COA.Revaluation=1 AND (COA.IsBank is Null OR COA.IsBank=0)
	AND INV.DocType in ('Invoice','Credit Note') 
	AND (Doc.AgingState <>'Deleted' OR Doc.AgingState IS NULL)
	group by INV.DocDate,c.ShortName,JD.DocNo,JD.DocType,Jd.DocCurrency,INV.ExchangeRate,E.Name,COA.Name,JD.EntityId,JD.COAId,JD.ServiceCompanyId,COA.Nature,INV.Id,COA.Class,INV.DocType,INV.DocSubType,INV.DocNo




	SELECT 'BILL' as TABLENAME,B.PostingDate as DocDate,c.ShortName as SevEntitity,B.DocNo as DocNo,B.DocType as			DocType,JD.DocCurrency as Currency,
	SUM(ISNULL(Doc.DocAppliedAmount,0)) as DocBal,
	B.ExchangeRate as OrgRate,
	 SUM(ISNULL(Doc.BaseAppliedAmount,0)) as BaseBal,
	E.Name as EntName,
	COA.Name as COAName,
	JD.EntityId as EntityId,
	JD.COAId as COAID,JD.ServiceCompanyId as ServiceEntityId,COA.Nature as Nature,B.Id as DocumentId,COA.Class as COAClass
	FROM Bean.JournalDetail(nolock) JD 
	INNER JOIN Bean.Bill(nolock) B on JD.DocumentDetailId=B.Id
	INNER JOIN Bean.DocumentHistory(nolock) DOC on DOC.DocumentId=B.Id and B.DocSubType='Opening Bal'
	INNER JOIN Bean.ChartOfAccount(nolock) COA on JD.COAId=COA.Id 
	LEFT JOIN Bean.Entity(nolock) E on B.EntityId=E.Id
	INNER JOIN Common.Company(nolock) c on B.ServiceCompanyId=c.Id  
	where DOC.PostingDate<=@DocDate 
	AND B.CompanyId=@CompanyId AND B.DocumentState NOT IN ('Fully Paid','Fully Applied','Void','Parked','Recurring') 
	AND JD.ServiceCompanyId in (Select Ids from @SerEntity) 
	AND (JD.ClearingStatus<>'Cleared' OR JD.ClearingDate is NULL) 
	AND JD.DocSubType NOT IN ('Reval','CM Application','Application')
	--AND JD.DocType NOT IN ('Receipt','Bill Payment')
	AND (JD.IsTax is NULL OR JD.IsTax=0)
	AND JD.DocCurrency<>JD.BaseCurrency 
	AND COA.Revaluation=1 AND (COA.IsBank is Null OR COA.IsBank=0)
	AND B.DocType='Bill'
	AND (Doc.AgingState <>'Deleted' OR Doc.AgingState IS NULL)
	group by B.PostingDate,c.ShortName,JD.DocNo,JD.DocType,Jd.DocCurrency,B.ExchangeRate,E.Name,COA.Name,JD.EntityId,JD.COAId,JD.ServiceCompanyId,COA.Nature,B.Id,COA.Class,B.DocType,B.DocSubType,B.DocNo

	SELECT 'CREDITMEMO' as TABLENAME,Memo.PostingDate as DocDate,c.ShortName as SevEntitity,Memo.DocNo as DocNo,Memo.DocType as			DocType,JD.DocCurrency as Currency,
	-SUM(ISNULL(Doc.DocAppliedAmount,0)) as DocBal,
	Memo.ExchangeRate as OrgRate,
	 -SUM(ISNULL(Doc.BaseAppliedAmount,0)) as BaseBal,
	E.Name as EntName,
	COA.Name as COAName,
	JD.EntityId as EntityId,
	JD.COAId as COAID,JD.ServiceCompanyId as ServiceEntityId,COA.Nature as Nature,Memo.Id as DocumentId,COA.Class as COAClass
	FROM Bean.JournalDetail(nolock) JD 
	INNER JOIN Bean.CreditMemo(nolock) Memo on JD.DocumentDetailId=Memo.Id
	INNER JOIN Bean.DocumentHistory(nolock) DOC on DOC.DocumentId=Memo.Id and Memo.DocSubType='Opening Bal'
	INNER JOIN Bean.ChartOfAccount(nolock) COA on JD.COAId=COA.Id 
	LEFT JOIN Bean.Entity(nolock) E on Memo.EntityId=E.Id
	INNER JOIN Common.Company(nolock) c on Memo.ServiceCompanyId=c.Id  
	where DOC.PostingDate<=@DocDate 
	AND Memo.CompanyId=@CompanyId AND Memo.DocumentState NOT IN ('Fully Paid','Fully Applied','Void','Parked','Recurring') 
	AND JD.ServiceCompanyId in (Select Ids from @SerEntity)
	AND (JD.ClearingStatus<>'Cleared' OR JD.ClearingDate is NULL) 
	AND JD.DocSubType NOT IN ('Reval','CM Application','Application')
	--AND JD.DocType NOT IN ('Receipt','Bill Payment')
	AND (JD.IsTax is NULL OR JD.IsTax=0)
	AND JD.DocCurrency<>JD.BaseCurrency 
	AND COA.Revaluation=1 AND (COA.IsBank is Null OR COA.IsBank=0)
	AND Memo.DocType='Credit Memo'
	AND (Doc.AgingState <>'Deleted' OR Doc.AgingState IS NULL)
	group by Memo.PostingDate,c.ShortName,JD.DocNo,JD.DocType,Jd.DocCurrency,Memo.ExchangeRate,E.Name,COA.Name,JD.EntityId,JD.COAId,JD.ServiceCompanyId,COA.Nature,Memo.Id,COA.Class,Memo.DocType,Memo.DocSubType,Memo.DocNo
	
END
GO
