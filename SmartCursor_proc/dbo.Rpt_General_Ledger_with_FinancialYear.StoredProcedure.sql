USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[Rpt_General_Ledger_with_FinancialYear]    Script Date: 16-12-2024 9.20.11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE Procedure [dbo].[Rpt_General_Ledger_with_FinancialYear]
@CompanyValue Varchar(100),
@FromDate Datetime,
@ToDate  Datetime,
@COA varchar(max),
@ServiceCompany Varchar(max)
As
Begin

Declare @CompanyId int
select @CompanyId = dbo.DecryptCompanyValue(@CompanyValue)


                      /*******step1: moving coa name and category of selected coa's into @COA_Category table variable**********/
Declare  @COA_Category TABLE ([COA Name] NVARCHAR(MAX),Category NVARCHAR(MAX))

Insert Into @COA_Category
Select Name,Category
From
(
	Select Name,Category 
	From   Bean.ChartOfAccount
	where  CompanyId=@CompanyId and ModuleType='Bean'
) as DT1
where Name in (SELECT items FROM dbo.SplitToTable(@COA,','))

--Select * from @COA_Category
                     /*************end of step1*******************/

                     /********step2: moving coa names where category in balance sheet into @COA_BalanceSheet**********/

Declare @COA_BalanceSheet table ([COA Name] nvarchar(max))

Insert Into @COA_BalanceSheet
Select [COA Name] from @COA_Category where Category='Balance Sheet' order by [COA Name]

--Select * from @COA_BalanceSheet

                       /********End of Step2**********/

                       /********step3: moving coa names where category in Income Statement into @COA_IncomeStatement**********/

Declare @COA_IncomeStatement table ([COA Name] nvarchar(max))

Insert Into @COA_IncomeStatement
Select [COA Name] from @COA_Category where Category='Income Statement' order by [COA Name]

--Select * from @COA_IncomeStatement

                      /********End of Step3**********/

Declare @GLReport Table( [COA Name] NVARCHAR(MAX),DocType NVARCHAR(MAX),DocSubType Nvarchar(max),DocumentDescription Nvarchar(max),DocDate datetime2,DocNo Nvarchar(max),SystemRefNo NVarchar(max),ServiceCompany Nvarchar(max),EntityName NVarchar(max),BaseDebit money,BaseCredit money,BaseBalance money,ExchangeRate decimal(15,10),BaseCurrency Nvarchar(max),DocCurrency NVarchar(max),DocDebit money,DocCredit money,DocBalance money,SegmentCategory1 Nvarchar(max),SegmentCategory2 NVarchar(max),MCS_Status int,SegmentStatus int,CorrAccount NVarchar(max),[Entity Type] Nvarchar(max),[Vendor Type] Nvarchar(max),PONo NVarchar(max),Nature Nvarchar(max),[CreditTerms(Days)] float,DueDate datetime2,[NSD ISCHECKED] int,[NO SUPPORT DOC] NVarchar(20),ItemCode NVarchar(max),ItemDescription NVarchar(max),Qty float,Unit NVarchar(100),UnitPrice money,[DiscountType] NVarchar(10),Discount float,[BRM ISCHECKED] int,[ALLOWABLE/DISALLOWABLE] NVarchar(max),[Bank Clearing] datetime2,ModeOfReceipt NVarchar(200),ReversalDate datetime2,[Bank Reconcile] NVarchar(20),[Reversal Doc Ref] NVarchar(max),ClearingStatus Nvarchar(100),[Created By] NVarchar(600),[Created On] datetime2,[Modified By] NVarchar(600),[Modified On] datetime2,COA_Parameter NVarchar(max))

                      /****** step 4: Data for Balance Sheet coa's **********/
Declare @COA_BSheet nvarchar(max)
Declare @count_BSheet int
Declare Balancesheet_cursor cursor for select * from @COA_BalanceSheet 
Open Balancesheet_cursor
Fetch next from Balancesheet_cursor into @COA_BSheet
while @@FETCH_STATUS=0
Begin
/*********step 4.1: counting how many no of days are there before the fromdate for a corresponding coa**********/
 Select @count_BSheet= Count(distinct DocDate)
 from
 (
	 select       JD.DocDate,COA.Name [COA Name],SC.Name as [SC Name]
	 from         Bean.JournalDetail as JD
	 inner join   Bean.Journal as J on J.Id=JD.JournalId
	 Inner Join   Bean.ChartOfAccount COA on COA.Id=JD.COAId
	 Inner Join   Common.Company as SC on SC.Id=JD.ServiceCompanyId
	 left join    Common.TermsOfPayment as TP on TP.Id=JD.CreditTermsId
	 where        COA.CompanyId=@CompanyId and J.DocumentState<>'Void'
 ) as dt1 
 where DocDate<@FromDate  and [SC Name] in (SELECT items FROM dbo.SplitToTable(@ServiceCompany,',')) and [COA Name] in(@COA_BSheet) 
 -- print @count_BSheet
 /******Ending of Step 4.1 ************************/

 /*********** Step 4.2 : This block is used to retriew report data if count_BSheet<>0 i.e. It is having Bal before fromdate ************/
   /*****We can retreive thata brought forward balance first, then we can get record information of perticular coa between FromDate and ToDate****/
 If @count_BSheet<>0
 Begin

 /**** Step 4.2.1 : Retrieving Broutght forward balance *******/
 -- Step 4.2.1.2  grouping done for step 4.2.1.1
 Insert Into @GLReport
 select  [COA Name], 'Balance B/F' as DocType,'' as DocSubType,'' as DocumentDescription, DocDate,'' as DocNo,'' as SystemRefNo,'' as  ServiceCompany,''  as EntityName,null as BaseDebit,null as BaseCredit,sum(BaseBalance) as BaseBalance,null as ExchangeRate,BaseCurrency, DocCurrency, null as DocDebit,null as DocCredit,sum(DocBalance) as DocBalance/*IsMultiCurrency,*/,SegmentCategory1,SegmentCategory2, MCS_Status,Status as SegmentStatus,CorrAccount,[Entity Type],[Vendor Type],PONo,Nature,[CreditTerms(Days)],DueDate,[NSD ISCHECKED],[NO SUPPORT DOC],ItemCode,ItemDescription,Qty,Unit,UnitPrice,DiscountType,Discount,[BRM ISCHECKED],[ALLOWABLE/DISALLOWABLE],[Bank Clearing],ModeOfReceipt,ReversalDate,[Bank Reconcile],[Reversal Doc Ref],ClearingStatus,[Created By],[Created On],[Modified By],[Modified On],COA_Parameter

 from
 (
 --step 4.2.1.1 starting
 select     COA.Code+'  '+ COA.Name as 'COA Name', 'Balance B/F' as DocType,'' as DocSubType,'' as DocumentDescription,DATEADD(day,-1,@FromDate) as DocDate,'' as DocNo,'' as SystemRefNo,'' as  ServiceCompany,''  as EntityName,null as BaseDebit,null as BaseCredit,isnull((isnull(JD.BaseDebit,0)-isnull(JD.BaseCredit,0)),0) as BaseBalance,null as ExchangeRate,null as BaseCurrency,null as DocCurrency,null as DocDebit,null as DocCredit,isnull((isnull(JD.DocDebit,0)-isnull(JD.DocCredit,0)),0) as DocBalance,/*IsMultiCurrency,*/null as SegmentCategory1,null as SegmentCategory2,Case when MCS.Status=1 then 1 else 0 end MCS_Status, SM3.Status,/*COA.Name as [Corr Account],*/null as CorrAccount,null as [Entity Type],null as [Vendor Type],null as PONo,null as Nature,null as [CreditTerms(Days)],null as DueDate, [NSD ISCHECKED],NULL AS [NO SUPPORT DOC],
            NULL AS ItemCode,NULL AS ItemDescription,NULL AS Qty,JD.Unit,NULL AS UnitPrice,NULL AS DiscountType,NULL AS Discount,[BRM ISCHECKED],NULL AS [ALLOWABLE/DISALLOWABLE],null as [Bank Clearing],NULL AS ModeOfReceipt,null as ReversalDate,null as [Bank Reconcile],null as [Reversal Doc Ref],null as ClearingStatus,null as [Created By],null as [Created On],null as [Modified By],null as [Modified On],@COA_BSheet as COA_Parameter
 from       Bean.JournalDetail JD 
 Inner Join Bean.Journal J on J.Id=JD.JournalId
 Inner Join Bean.ChartOfAccount COA on COA.Id=JD.COAId
 Inner Join Common.Company as SC on SC.Id=JD.ServiceCompanyId
 Inner join Bean.Entity as E on E.Id=JD.EntityId
 Left join  Bean.SegmentMaster as SM1 on SM1.Id=JD.SegmentMasterid1 and J.CompanyId=SM1.CompanyId
 Left join  Bean.SegmentMaster as SM2 on SM2.Id=JD.SegmentMasterid1 and J.CompanyId=SM2.CompanyId
 Left join  Bean.MultiCurrencySetting MCS on MCS.companyId=J.CompanyId
 Left Join 
  (
	  select distinct CompanyId,status
	  from
	  (
	   select CompanyId, Status from bean.SegmentMaster where CompanyId=@CompanyId
	  ) as st1
  ) SM3 on SM3.companyid=J.CompanyId
 Left join Common.TermsOfPayment as TP on TP.Id=JD.CreditTermsId
 LEFT JOIN
  (
     Select  CompanyId,ISNULL(IsChecked,0) AS [NSD ISCHECKED]  
     From    Common.CompanyFeatures where CompanyId=@CompanyId and FeatureId=(select distinct id from Common.Feature where Name='No Supporting Documents') 
  ) AS NSD ON NSD.CompanyId=J.CompanyId
 LEFT JOIN
  (
     Select  CompanyId,ISNULL(IsChecked,0) AS [BRM ISCHECKED] 
     From    Common.CompanyFeatures where CompanyId=@CompanyId and FeatureId=(select distinct id from Common.Feature where Name='Bank Reconciliation') 
   ) AS BRM ON BRM.CompanyId=J.CompanyId

 where COA.CompanyId=@CompanyId and  JD.DocumentDetailId='00000000-0000-0000-0000-000000000000' and COA.ModuleType='Bean' and JD.IsTax<>1
 and JD.DocType not in('Credit Memo','Credit Note') and JD.DocSubType not in('CreditNote','Credit Memo')
 and COA.Name in(@COA_BSheet) and SC.Name in (SELECT items FROM dbo.SplitToTable(@ServiceCompany,','))
 and JD.DocDate < @FromDate and J.DocumentState<>'Void'
 --order by [COA Name],DocDate

 union all
 Select     COA.Code+'  '+ COA.Name as 'COA Name', 'Balance B/F' as DocType,'' as DocSubType,'' as DocumentDescription,DATEADD(day,-1,@FromDate) as DocDate,'' as DocNo,'' as SystemRefNo,'' as  ServiceCompany,''  as EntityName,null as BaseDebit,null as BaseCredit,isnull((isnull(JD.BaseDebit,0)-isnull(JD.BaseCredit,0)),0) as BaseBalance,null as ExchangeRate,null as BaseCurrency,null as DocCurrency,null as DocDebit,null as DocCredit,isnull((isnull(JD.DocDebit,0)-isnull(JD.DocCredit,0)),0) as DocBalance,/*IsMultiCurrency,*/null as SegmentCategory1,null as SegmentCategory2,Case when MCS.Status=1 then 1 else 0 end MCS_Status, SM3.Status,/*COA.Name as [Corr Account],*/null as CorrAccount,null as [Entity Type],null as [Vendor Type],null as PONo,null as Nature,null as [CreditTerms(Days)],null as DueDate,[NSD ISCHECKED],NULL AS [NO SUPPORT DOC],
            NULL AS ItemCode,NULL AS ItemDescription,NULL AS Qty,JD.Unit,NULL AS UnitPrice,NULL AS DiscountType,NULL AS Discount,[BRM ISCHECKED],NULL AS [ALLOWABLE/DISALLOWABLE],NULL AS [Bank Clearing],NULL AS ModeOfReceipt,null as ReversalDate,null as [Bank Reconcile],null as [Reversal Doc Ref],null as ClearingStatus,null as [Created By],null as [Created On],null as [Modified By],null as [Modified On],@COA_BSheet as COA_Parameter

 From       Bean.JournalDetail JD 
 Inner Join Bean.Journal J on J.Id=JD.JournalId
 Inner Join Bean.ChartOfAccount COA on COA.Id=JD.COAId
 Inner Join Common.Company as SC on SC.Id=JD.ServiceCompanyId
 Inner join Bean.Entity as E on E.Id=JD.EntityId
 Left join  Bean.SegmentMaster as SM1 on SM1.Id=JD.SegmentMasterid1 and J.CompanyId=SM1.CompanyId
 Left join  Bean.SegmentMaster as SM2 on SM2.Id=JD.SegmentMasterid1 and J.CompanyId=SM2.CompanyId
 Left join  Bean.MultiCurrencySetting MCS on MCS.companyId=J.CompanyId 
 Left Join 
  (
	  select distinct CompanyId,status
	  from
	  (
	   select CompanyId, Status from bean.SegmentMaster where CompanyId=@CompanyId
	  ) as st1
  ) SM3 on SM3.companyid=J.CompanyId
 Left join Common.TermsOfPayment as TP on TP.Id=JD.CreditTermsId
  LEFT JOIN
  (
     select CompanyId,ISNULL(IsChecked,0) AS [NSD ISCHECKED]  
    from Common.CompanyFeatures where CompanyId=@CompanyId and FeatureId=(select distinct id from Common.Feature where Name='No Supporting Documents') 
  ) AS NSD ON NSD.CompanyId=J.CompanyId
  LEFT JOIN
  (
     select CompanyId,ISNULL(IsChecked,0) AS [BRM ISCHECKED] 
     from Common.CompanyFeatures where CompanyId=@CompanyId and FeatureId=(select distinct id from Common.Feature where Name='Bank Reconciliation') 
   ) AS BRM ON BRM.CompanyId=J.CompanyId

 where COA.CompanyId=@CompanyId and  JD.DocumentDetailId<>'00000000-0000-0000-0000-000000000000' and COA.ModuleType='Bean' and JD.IsTax<>1
 --and JD.DocType  in('Credit Memo','Credit Note') 
 and JD.DocSubType not in('CreditNote','Credit Memo')
 and COA.Name in(@COA_BSheet) and SC.Name in (SELECT items FROM dbo.SplitToTable(@ServiceCompany,','))
 and JD.DocDate < @FromDate and J.DocumentState<>'Void'
 --order by [COA Name],DocDate
 --step 4.2.1.1 ending
 ) as DT3
 group by [COA Name],DocType,DocDate,BaseCurrency,DocCurrency,/*IsMultiCurrency,*/SegmentCategory1,SegmentCategory2,MCS_Status,Status,/*[Corr Account],*/CorrAccount,[Entity Type],[Vendor Type],PONo,Nature,[CreditTerms(Days)],DueDate,[NSD ISCHECKED],[NO SUPPORT DOC],ItemCode,ItemDescription,Qty,Unit,UnitPrice,DiscountType,Discount,[BRM ISCHECKED],[ALLOWABLE/DISALLOWABLE],[Bank Clearing],ModeOfReceipt,ReversalDate,[Bank Reconcile],[Reversal Doc Ref],ClearingStatus,[Created By],[Created On],[Modified By],[Modified On],COA_Parameter
 --step4.2.1.2 ending
 /*******Ending of 4.2.1 ***********/
 union all
 /********* Step 4.2.2 : Getting records when documentdetailid is 0 and JD.DocType not in('Credit Memo','Credit Note') and JD.DocSubType not in('CreditNote','Credit Memo') *******************/
 
 /*********** Step 4.2.2.3 : here we join MS1 (Step 4.2.2.1) and FCA (Step 4.2.2.2) *****************/
 /*********** Taking all columns from MS1 and corresponding Account column from FCA ****************/
 select [COA Name],DocType,DocSubType,DocumentDescription,DocDate,DocNo,SystemRefNo,ServiceCompany,EntityName,BaseDebit,BaseCredit,BaseBalance,ExchangeRate,BaseCurrency,DocCurrency,DocDebit,DocCredit,DocBalance,/*IsMultiCurrency,*/SegmentCategory1,SegmentCategory2,MCS_Status,Status, FCA.CorrAccount,[Entity Type],[Vendor Type],PONo,Nature,[CreditTerms(Days)],DueDate,[NSD ISCHECKED],[NO SUPPORT DOC],ItemCode,ItemDescription,Qty,Unit,UnitPrice,DiscountType,Discount,[BRM ISCHECKED],[ALLOWABLE/DISALLOWABLE],[Bank Clearing],ModeOfReceipt,ReversalDate,[Bank Reconcile],[Reversal Doc Ref],ClearingStatus,[Created By],[Created On],[Modified By],[Modified On],COA_Parameter

 from
 (
 /********* Step 4.2.2.1 : Getting records except coresponding account column ************************************/
 Select      COA.Code+'  '+ COA.Name as 'COA Name', JD.DocType,JD.DocSubType,JD.docdescription as DocumentDescription,JD.DocDate,JD.DocNo,JD.SystemRefNo, SC.Name ServiceCompany,E.Name as EntityName,isnull(JD.BaseDebit,0) as BaseDebit,isnull(JD.BaseCredit,0) as BaseCredit,isnull((isnull(JD.BaseDebit,0)-isnull(JD.BaseCredit,0)),0) as BaseBalance,jd.ExchangeRate,jd.BaseCurrency,JD.DocCurrency,isnull(JD.DocDebit,0) as DocDebit,isnull(JD.DocCredit,0) as DocCredit ,isnull((isnull(JD.DocDebit,0)-isnull(JD.DocCredit,0)),0) as DocBalance,/*IsMultiCurrency,*/jd.SegmentCategory1,JD.SegmentCategory2,Case when MCS.Status=1 then 1 else 0 end MCS_Status, SM3.Status,/*COA.Name as [Corr Account],*/
             JD.JournalId,case when E.IsCustomer=1 then 'Customer' when E.IsVendor=1 then 'Vendor' end as [Entity Type],E.VendorType as [Vendor Type],JD.PONo,JD.Nature,TP.TOPValue as [CreditTerms(Days)],J.DueDate,NSD.[NSD ISCHECKED],CASE WHEN J.IsNoSupportingDocument=0 THEN 'NO' WHEN J.IsNoSupportingDocument=1 THEN 'YES' END AS [NO SUPPORT DOC],JD.ItemCode,JD.ItemDescription,JD.Qty,JD.Unit,JD.UnitPrice,JD.DiscountType,JD.Discount,[BRM ISCHECKED],case when IsAllowableNonAllowable=0 then 'NO' when IsAllowableNonAllowable=1 then 'YES' END AS [ALLOWABLE/DISALLOWABLE],JD.ClearingDate AS [Bank Clearing],J.ModeOfReceipt,J.ReversalDate,
		     case when J.IsBankReconcile=0 then 'NO' when J.IsBankReconcile=1 then 'YES' end as [Bank Reconcile],case when J.IsAutoReversalJournal in (0,1) then J.SystemReferenceNo  end as [Reversal Doc Ref],JD.ClearingStatus,J.UserCreated as [Created By],J.CreatedDate as [Created On],J.ModifiedBy as [Modified By],J.ModifiedDate as [Modified On],@COA_BSheet as COA_Parameter
 From        Bean.JournalDetail JD 
 Inner Join  Bean.Journal J on J.Id=JD.JournalId
 Inner Join  Bean.ChartOfAccount COA on COA.Id=JD.COAId
 Inner Join  Common.Company as SC on SC.Id=JD.ServiceCompanyId
 Inner join  Bean.Entity as E on E.Id=JD.EntityId
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

 where COA.CompanyId=@CompanyId and  JD.DocumentDetailId='00000000-0000-0000-0000-000000000000' and COA.ModuleType='Bean' and JD.IsTax<>1
 and JD.DocType not in('Credit Memo','Credit Note') and JD.DocSubType not in('CreditNote','Credit Memo')
 and COA.Name in(@COA_BSheet) and SC.Name in (SELECT items FROM dbo.SplitToTable(@ServiceCompany,','))
 and JD.DocDate between @FromDate and @ToDate and J.DocumentState<>'Void'
 --order by [COA Name],DocDate
 ) as MS1

 /*********Ending of Step 4.2.2.1 *************************/
 /*********** Step 4.2.2.2 : Getting corresponding account column. Here we joined to MS1 on  matching journalid condition ************/
 Left join-- for corraccount ** starting
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
			 where   J.CompanyId=@CompanyId and JD.DocumentDetailId<>'00000000-0000-0000-0000-000000000000' and COA.ModuleType='Bean' and J.DocumentState<>'Void' and JD.IsTax<>1 

		) as CA1
		group by JournalId--,Name
	) as CA2
	Inner join
	(
		 select  JD.JournalId,JD.COAId,COA.Name  
		 from    Bean.JournalDetail as JD
		 join    Bean.Journal as J on J.Id=JD.JournalId
		 join    Bean.ChartOfAccount as COA on COA.Id=JD.COAId
		 where   J.CompanyId=@CompanyId and JD.DocumentDetailId<>'00000000-0000-0000-0000-000000000000' and COA.ModuleType='Bean' and J.DocumentState<>'Void' and JD.IsTax<>1 

	) as CA3 on CA2.JournalId=CA3.JournalId
)as CA4 --ending
) as FCA on FCA.JournalId=MS1.JournalId
--order by [COA Name]

/*********** Ending of step 4.2.2.2 **************/
/*********** Ending of step 4.2.2.3 **************/
/*********** Ending of step 4.2.2 **************/
union all

/********* Step 4.2.3 : Getting records when documentdetailid is  not 0 and JD.DocSubType not in('CreditNote','Credit Memo') *******************/
 /*********** Step 4.2.3.3 : here we join MS1 (Step 4.2.3.1) and FCA (Step 4.2.3.2) *****************/
 /*********** Taking all columns from MS1 and corresponding Account column from FCA ****************/

 select [COA Name],DocType,DocSubType,DocumentDescription,DocDate,DocNo,SystemRefNo,ServiceCompany,EntityName,BaseDebit,BaseCredit,BaseBalance,ExchangeRate,BaseCurrency,DocCurrency,DocDebit,DocCredit,DocBalance,/*IsMultiCurrency,*/SegmentCategory1,SegmentCategory2,MCS_Status,Status, FCA.CorrAccount,[Entity Type],[Vendor Type],PONo,Nature,[CreditTerms(Days)],DueDate,[NSD ISCHECKED],[NO SUPPORT DOC],ItemCode,ItemDescription,Qty,Unit,UnitPrice,DiscountType,Discount,[BRM ISCHECKED],[ALLOWABLE/DISALLOWABLE],[Bank Clearing],ModeOfReceipt,ReversalDate,[Bank Reconcile],[Reversal Doc Ref],ClearingStatus,[Created By],[Created On],[Modified By],[Modified On],COA_Parameter

 from
 (
  /********* Step 4.2.3.1 : Getting records except coresponding account column ************************************/
 select       COA.Code+'  '+ COA.Name as 'COA Name', JD.DocType,JD.DocSubType,JD.docdescription as DocumentDescription,JD.DocDate,JD.DocNo,JD.SystemRefNo, SC.Name ServiceCompany,E.Name as EntityName,isnull(JD.BaseDebit,0) as BaseDebit,isnull(JD.BaseCredit,0) as BaseCredit,isnull((isnull(JD.BaseDebit,0)-isnull(JD.BaseCredit,0)),0) as BaseBalance,jd.ExchangeRate,jd.BaseCurrency,JD.DocCurrency,isnull(JD.DocDebit,0) as DocDebit,isnull(JD.DocCredit,0) as DocCredit,isnull((isnull(JD.DocDebit,0)-isnull(JD.DocCredit,0)),0) as DocBalance,IsMultiCurrency,jd.SegmentCategory1,JD.SegmentCategory2,Case when MCS.Status=1 then 1 else 0 end MCS_Status, SM3.Status,/*COA.Name as [Corr Account],*/
              JD.JournalId,case when E.IsCustomer=1 then 'Customer' when E.IsVendor=1 then 'Vendor' end as [Entity Type],E.VendorType as [Vendor Type],JD.PONo,JD.Nature,TP.TOPValue as [CreditTerms(Days)],J.DueDate,NSD.[NSD ISCHECKED],CASE WHEN J.IsNoSupportingDocument=0 THEN 'NO' WHEN J.IsNoSupportingDocument=1 THEN 'YES' END AS [NO SUPPORT DOC],JD.ItemCode,JD.ItemDescription,JD.Qty,JD.Unit,JD.UnitPrice,JD.DiscountType,JD.Discount,[BRM ISCHECKED],case when IsAllowableNonAllowable=0 then 'NO' when IsAllowableNonAllowable=1 then 'YES' END AS [ALLOWABLE/DISALLOWABLE],JD.ClearingDate AS [Bank Clearing],J.ModeOfReceipt,J.ReversalDate,
		      case when J.IsBankReconcile=0 then 'NO' when J.IsBankReconcile=1 then 'YES' end as [Bank Reconcile],case when J.IsAutoReversalJournal in (0,1) then J.SystemReferenceNo  end as [Reversal Doc Ref],JD.ClearingStatus,J.UserCreated as [Created By],J.CreatedDate as [Created On],J.ModifiedBy as [Modified By],J.ModifiedDate as [Modified On],@COA_BSheet as COA_Parameter
 From         Bean.JournalDetail JD 
 Inner Join   Bean.Journal J on J.Id=JD.JournalId
 Inner Join   Bean.ChartOfAccount COA on COA.Id=JD.COAId
 Inner Join   Common.Company as SC on SC.Id=JD.ServiceCompanyId
 Inner join   Bean.Entity as E on E.Id=JD.EntityId
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

 where COA.CompanyId=@CompanyId and  JD.DocumentDetailId<>'00000000-0000-0000-0000-000000000000' and COA.ModuleType='Bean' and JD.IsTax<>1
-- and JD.DocType  in('Credit Memo','Credit Note') 
and JD.DocSubType not in('CreditNote','Credit Memo')
 and COA.Name in(@COA_BSheet) and SC.Name in (SELECT items FROM dbo.SplitToTable(@ServiceCompany,','))
 and JD.DocDate between @FromDate and @ToDate and J.DocumentState<>'Void'
 --order by [COA Name],DocDate
 ) as MS1

 /*********Ending of Step 4.2.3.1 *************************/
 /*********** Step 4.2.3.2 : Getting corresponding account column. Here we joined to MS1 on  matching journalid condition ************/
 Left join-- for corraccount ** starting
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
			Where    J.CompanyId=@CompanyId and JD.DocumentDetailId='00000000-0000-0000-0000-000000000000' and COA.ModuleType='Bean' and J.DocumentState<>'Void' and JD.IsTax<>1

		) as CA1
		group by JournalId--,Name
	) as CA2
	Inner join
	(
		 select JD.JournalId,JD.COAId,COA.Name  
		 from   Bean.JournalDetail as JD
		join    Bean.Journal as J on J.Id=JD.JournalId
		join    Bean.ChartOfAccount as COA on COA.Id=JD.COAId
		where   J.CompanyId=@CompanyId and JD.DocumentDetailId='00000000-0000-0000-0000-000000000000' and COA.ModuleType='Bean' and J.DocumentState<>'Void' and JD.IsTax<>1

	) as CA3 on CA2.JournalId=CA3.JournalId
)as CA4 --ending
) as FCA on FCA.JournalId=MS1.JournalId
 order by [COA Name],DocDate
/*********** Ending of step 4.2.3.2 **************/
/*********** Ending of step 4.2.3.3 **************/
/*********** Ending of step 4.2.3 **************/
 End

 /******* End of step 4.2 (i.e Count<>0 condition ending) ***************/

  /*********** Step 4.3 : This block is used to retriew report data if count_BSheet = 0 i.e. It does not having Bal before fromdate ************/
   /*****First,We can assign brought forward balance as 0.00 , then we can get record information of perticular coa between FromDate and ToDate****/
 Else If @count_BSheet=0
 Begin

 /**** Step 4.3.1 : Retrieving Broutght forward balance *******/
 -- Step 4.3.1.2  grouping done for step 4.3.1.1
 Insert Into @GLReport
 select  [COA Name], 'Balance B/F' as DocType,'' as DocSubType,'' as DocumentDescription, DocDate,'' as DocNo,'' as SystemRefNo,'' as  ServiceCompany,''  as EntityName,null as BaseDebit,null as BaseCredit,sum(BaseBalance) as BaseBalance,null as ExchangeRate,BaseCurrency, DocCurrency, null as DocDebit,null as DocCredit,sum(DocBalance) as DocBalance/*IsMultiCurrency,*/,SegmentCategory1,SegmentCategory2, MCS_Status,Status as SegmentStatus,CorrAccount,[Entity Type],[Vendor Type],PONo,Nature,[CreditTerms(Days)],DueDate,[NSD ISCHECKED],[NO SUPPORT DOC],ItemCode,ItemDescription,Qty,Unit,UnitPrice,DiscountType,Discount,[BRM ISCHECKED],[ALLOWABLE/DISALLOWABLE],[Bank Clearing],ModeOfReceipt,ReversalDate,[Bank Reconcile],[Reversal Doc Ref],ClearingStatus,[Created By],[Created On],[Modified By],[Modified On],COA_Parameter

 from
 (
 --step 4.3.1.1 starting
 select     COA.Code+'  '+ COA.Name as 'COA Name', 'Balance B/F' as DocType,'' as DocumentDescription,DATEADD(day,-1,@FromDate) as DocDate,'' as DocNo,'' as SystemRefNo,'' as  ServiceCompany,''  as EntityName,null as BaseDebit,null as BaseCredit,0.00 as BaseBalance,null as ExchangeRate,null as BaseCurrency,null as DocCurrency,null as DocDebit,null as DocCredit,0.00 as DocBalance,/*IsMultiCurrency,*/null as SegmentCategory1,null as SegmentCategory2,Case when MCS.Status=1 then 1 else 0 end MCS_Status, SM3.Status,/*COA.Name as [Corr Account],*/null as CorrAccount,null as [Entity Type],null as [Vendor Type],null as PONo,null as Nature,null as [CreditTerms(Days)],null as DueDate,[NSD ISCHECKED],NULL AS [NO SUPPORT DOC],
            NULL AS ItemCode,NULL AS ItemDescription,NULL AS Qty,NULL AS Unit,NULL AS UnitPrice,NULL AS DiscountType,NULL AS Discount,[BRM ISCHECKED],NULL AS [ALLOWABLE/DISALLOWABLE],NULL AS [Bank Clearing],NULL AS ModeOfReceipt,NULL AS ReversalDate,null as [Bank Reconcile],null as [Reversal Doc Ref],null as ClearingStatus,null as [Created By],null as [Created On],null as [Modified By],null as [Modified On],@COA_BSheet as COA_Parameter
 from       Bean.JournalDetail JD 
 Inner Join Bean.Journal J on J.Id=JD.JournalId
 Inner Join Bean.ChartOfAccount COA on COA.Id=JD.COAId
 Inner Join Common.Company as SC on SC.Id=JD.ServiceCompanyId
 Inner join Bean.Entity as E on E.Id=JD.EntityId
 Left join  Bean.SegmentMaster as SM1 on SM1.Id=JD.SegmentMasterid1 and J.CompanyId=SM1.CompanyId
 Left join  Bean.SegmentMaster as SM2 on SM2.Id=JD.SegmentMasterid1 and J.CompanyId=SM2.CompanyId
 Left join  Bean.MultiCurrencySetting MCS on MCS.companyId=J.CompanyId
 Left Join 
  (
	  select distinct CompanyId,status
	  from
	  (
	   select CompanyId, Status from bean.SegmentMaster where CompanyId=@CompanyId
	  ) as st1
  ) SM3 on SM3.companyid=J.CompanyId
 Left join Common.TermsOfPayment as TP on TP.Id=JD.CreditTermsId
 LEFT JOIN
  (
     Select  CompanyId,ISNULL(IsChecked,0) AS [NSD ISCHECKED]  
     From    Common.CompanyFeatures where CompanyId=@CompanyId and FeatureId=(select distinct id from Common.Feature where Name='No Supporting Documents') 
  ) AS NSD ON NSD.CompanyId=J.CompanyId
 LEFT JOIN
  (
     Select  CompanyId,ISNULL(IsChecked,0) AS [BRM ISCHECKED] 
     From    Common.CompanyFeatures where CompanyId=@CompanyId and FeatureId=(select distinct id from Common.Feature where Name='Bank Reconciliation') 
   ) AS BRM ON BRM.CompanyId=J.CompanyId

 where COA.CompanyId=@CompanyId and  JD.DocumentDetailId='00000000-0000-0000-0000-000000000000' and COA.ModuleType='Bean' and JD.IsTax<>1
 and JD.DocType not in('Credit Memo','Credit Note') and JD.DocSubType not in('CreditNote','Credit Memo')
 and COA.Name in(@COA_BSheet) and SC.Name in (SELECT items FROM dbo.SplitToTable(@ServiceCompany,','))
 /*and JD.DocDate between @FromDate and @ToDate*/ and J.DocumentState<>'Void'
 --order by [COA Name],DocDate

 union all
 Select     COA.Code+'  '+ COA.Name as 'COA Name', 'Balance B/F' as DocType,'' as DocumentDescription,DATEADD(day,-1,@FromDate) as DocDate,'' as DocNo,'' as SystemRefNo,'' as  ServiceCompany,''  as EntityName,null as BaseDebit,null as BaseCredit,0.00 as BaseBalance,null as ExchangeRate,null as BaseCurrency,null as DocCurrency,null as DocDebit,null as DocCredit,0.00 as DocBalance,/*IsMultiCurrency,*/null as SegmentCategory1,null as SegmentCategory2,Case when MCS.Status=1 then 1 else 0 end MCS_Status, SM3.Status,/*COA.Name as [Corr Account],*/null as CorrAccount,null as [Entity Type],null as [Vendor Type],null as PONo,null as Nature,null as [CreditTerms(Days)],null as DueDate,[NSD ISCHECKED],NULL AS [NO SUPPORT DOC],
            NULL AS ItemCode,NULL AS ItemDescription,NULL AS Qty,NULL AS Unit,NULL AS UnitPrice,NULL AS DiscountType,NULL AS Discount,[BRM ISCHECKED],NULL AS [ALLOWABLE/DISALLOWABLE],NULL AS [Bank Clearing],NULL AS ModeOfReceipt,NULL AS ReversalDate,null as [Bank Reconcile],null as [Reversal Doc Ref],null as ClearingStatus,null as [Created By],null as [Created On],null as [Modified By],null as [Modified On],@COA_BSheet as COA_Parameter
 from       Bean.JournalDetail JD 
 Inner Join Bean.Journal J on J.Id=JD.JournalId
 Inner Join Bean.ChartOfAccount COA on COA.Id=JD.COAId
 Inner Join Common.Company as SC on SC.Id=JD.ServiceCompanyId
 Inner join Bean.Entity as E on E.Id=JD.EntityId
 Left join  Bean.SegmentMaster as SM1 on SM1.Id=JD.SegmentMasterid1 and J.CompanyId=SM1.CompanyId
 Left join  Bean.SegmentMaster as SM2 on SM2.Id=JD.SegmentMasterid1 and J.CompanyId=SM2.CompanyId
 Left join  Bean.MultiCurrencySetting MCS on MCS.companyId=J.CompanyId 
 Left Join 
  (
	  select distinct CompanyId,status
	  from
	  (
	   select CompanyId, Status from bean.SegmentMaster where CompanyId=@CompanyId
	  ) as st1
  ) SM3 on SM3.companyid=J.CompanyId
 Left join Common.TermsOfPayment as TP on TP.Id=JD.CreditTermsId
  LEFT JOIN
  (
     select CompanyId,ISNULL(IsChecked,0) AS [NSD ISCHECKED]  
    from Common.CompanyFeatures where CompanyId=@CompanyId and FeatureId=(select distinct id from Common.Feature where Name='No Supporting Documents') 
  ) AS NSD ON NSD.CompanyId=J.CompanyId
  LEFT JOIN
  (
     select CompanyId,ISNULL(IsChecked,0) AS [BRM ISCHECKED] 
     from Common.CompanyFeatures where CompanyId=@CompanyId and FeatureId=(select distinct id from Common.Feature where Name='Bank Reconciliation') 
   ) AS BRM ON BRM.CompanyId=J.CompanyId

 where COA.CompanyId=@CompanyId and  JD.DocumentDetailId<>'00000000-0000-0000-0000-000000000000' and COA.ModuleType='Bean' and JD.IsTax<>1
 --and JD.DocType  in('Credit Memo','Credit Note') 
 and JD.DocSubType not in('CreditNote','Credit Memo')
 and COA.Name in(@COA_BSheet) and SC.Name in (SELECT items FROM dbo.SplitToTable(@ServiceCompany,','))
 /*and JD.DocDate between @FromDate and @ToDate*/ and J.DocumentState<>'Void'
 --order by [COA Name],DocDate
 --step 4.3.1.1 ending
 ) as DT3
 group by [COA Name],DocType,DocDate,BaseCurrency,DocCurrency,/*IsMultiCurrency,*/SegmentCategory1,SegmentCategory2,MCS_Status,Status,/*[Corr Account],*/CorrAccount,[Entity Type],[Vendor Type],PONo,Nature,[CreditTerms(Days)],DueDate,[NSD ISCHECKED],[NO SUPPORT DOC],ItemCode,ItemDescription,Qty,Unit,UnitPrice,DiscountType,Discount,[BRM ISCHECKED],[ALLOWABLE/DISALLOWABLE],[Bank Clearing],ModeOfReceipt,ReversalDate,[Bank Reconcile],[Reversal Doc Ref],ClearingStatus,[Created By],[Created On],[Modified By],[Modified On],COA_Parameter
 --step4.3.1.2 ending
 /*******Ending of 4.3.1 ***********/
 union all
 /********* Step 4.3.2 : Getting records when documentdetailid is 0 and JD.DocType not in('Credit Memo','Credit Note') and JD.DocSubType not in('CreditNote','Credit Memo') *******************/
 
 /*********** Step 4.3.2.3 : here we join MS1 (Step 4.2.2.1) and FCA (Step 4.2.2.2) *****************/
 /*********** Taking all columns from MS1 and corresponding Account column from FCA ****************/
 select [COA Name],DocType,DocSubType,DocumentDescription,DocDate,DocNo,SystemRefNo,ServiceCompany,EntityName,BaseDebit,BaseCredit,BaseBalance,ExchangeRate,BaseCurrency,DocCurrency,DocDebit,DocCredit,DocBalance,/*IsMultiCurrency,*/SegmentCategory1,SegmentCategory2,MCS_Status,Status, FCA.CorrAccount,[Entity Type],[Vendor Type],PONo,Nature,[CreditTerms(Days)],DueDate,[NSD ISCHECKED],[NO SUPPORT DOC],ItemCode,ItemDescription,Qty,Unit,UnitPrice,DiscountType,Discount,[BRM ISCHECKED],[ALLOWABLE/DISALLOWABLE],[Bank Clearing],ModeOfReceipt,ReversalDate,[Bank Reconcile],[Reversal Doc Ref],ClearingStatus,[Created By],[Created On],[Modified By],[Modified On],COA_Parameter

 from
 (
 /********* Step 4.3.2.1 : Getting records except coresponding account column ************************************/
 Select      COA.Code+'  '+ COA.Name as 'COA Name', JD.DocType,JD.DocSubType,JD.docdescription as DocumentDescription,JD.DocDate,JD.DocNo,JD.SystemRefNo, SC.Name ServiceCompany,E.Name as EntityName,isnull(JD.BaseDebit,0) as BaseDebit,isnull(JD.BaseCredit,0) as BaseCredit,isnull((isnull(JD.BaseDebit,0)-isnull(JD.BaseCredit,0)),0) as BaseBalance,jd.ExchangeRate,jd.BaseCurrency,JD.DocCurrency,isnull(JD.DocDebit,0) as DocDebit,isnull(JD.DocCredit,0) as DocCredit ,isnull((isnull(JD.DocDebit,0)-isnull(JD.DocCredit,0)),0) as DocBalance,/*IsMultiCurrency,*/jd.SegmentCategory1,JD.SegmentCategory2,Case when MCS.Status=1 then 1 else 0 end MCS_Status, SM3.Status,/*COA.Name as [Corr Account],*/
             JD.JournalId,case when E.IsCustomer=1 then 'Customer' when E.IsVendor=1 then 'Vendor' end as [Entity Type],E.VendorType as [Vendor Type],JD.PONo,JD.Nature,TP.TOPValue as [CreditTerms(Days)],J.DueDate,NSD.[NSD ISCHECKED],CASE WHEN J.IsNoSupportingDocument=0 THEN 'NO' WHEN J.IsNoSupportingDocument=1 THEN 'YES' END AS [NO SUPPORT DOC],JD.ItemCode,JD.ItemDescription,JD.Qty,JD.Unit,JD.UnitPrice,JD.DiscountType,JD.Discount,[BRM ISCHECKED],case when IsAllowableNonAllowable=0 then 'NO' when IsAllowableNonAllowable=1 then 'YES' END AS [ALLOWABLE/DISALLOWABLE],JD.ClearingDate AS [Bank Clearing],J.ModeOfReceipt,J.ReversalDate,
		     case when J.IsBankReconcile=0 then 'NO' when J.IsBankReconcile=1 then 'YES' end as [Bank Reconcile],case when J.IsAutoReversalJournal in (0,1) then J.SystemReferenceNo  end as [Reversal Doc Ref],JD.ClearingStatus,J.UserCreated as [Created By],J.CreatedDate as [Created On],J.ModifiedBy as [Modified By],J.ModifiedDate as [Modified On],@COA_BSheet as COA_Parameter
 From        Bean.JournalDetail JD 
 Inner Join  Bean.Journal J on J.Id=JD.JournalId
 Inner Join  Bean.ChartOfAccount COA on COA.Id=JD.COAId
 Inner Join  Common.Company as SC on SC.Id=JD.ServiceCompanyId
 Inner join  Bean.Entity as E on E.Id=JD.EntityId
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

 where COA.CompanyId=@CompanyId and  JD.DocumentDetailId='00000000-0000-0000-0000-000000000000' and COA.ModuleType='Bean' and JD.IsTax<>1
 and JD.DocType not in('Credit Memo','Credit Note') and JD.DocSubType not in('CreditNote','Credit Memo')
 and COA.Name in(@COA_BSheet) and SC.Name in (SELECT items FROM dbo.SplitToTable(@ServiceCompany,','))
 and JD.DocDate between @FromDate and @ToDate and J.DocumentState<>'Void'
 --order by [COA Name],DocDate
 ) as MS1

 /*********Ending of Step 4.3.2.1 *************************/
 /*********** Step 4.3.2.2 : Getting corresponding account column. Here we joined to MS1 on  matching journalid condition ************/
 Left join-- for corraccount ** starting
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
			 where   J.CompanyId=@CompanyId and JD.DocumentDetailId<>'00000000-0000-0000-0000-000000000000' and COA.ModuleType='Bean' and J.DocumentState<>'Void' and JD.IsTax<>1 

		) as CA1
		group by JournalId--,Name
	) as CA2
	Inner join
	(
		 select  JD.JournalId,JD.COAId,COA.Name  
		 from    Bean.JournalDetail as JD
		 join    Bean.Journal as J on J.Id=JD.JournalId
		 join    Bean.ChartOfAccount as COA on COA.Id=JD.COAId
		 where   J.CompanyId=@CompanyId and JD.DocumentDetailId<>'00000000-0000-0000-0000-000000000000' and COA.ModuleType='Bean' and J.DocumentState<>'Void' and JD.IsTax<>1 

	) as CA3 on CA2.JournalId=CA3.JournalId
)as CA4 --ending
) as FCA on FCA.JournalId=MS1.JournalId
--order by [COA Name]

/*********** Ending of step 4.3.2.2 **************/
/*********** Ending of step 4.3.2.3 **************/
/*********** Ending of step 4.3.2 **************/
union all

/********* Step 4.3.3 : Getting records when documentdetailid is  not 0 and JD.DocSubType not in('CreditNote','Credit Memo') *******************/
 /*********** Step 4.3.3.3 : here we join MS1 (Step 4.2.3.1) and FCA (Step 4.2.3.2) *****************/
 /*********** Taking all columns from MS1 and corresponding Account column from FCA ****************/

 select [COA Name],DocType,DocSubType,DocumentDescription,DocDate,DocNo,SystemRefNo,ServiceCompany,EntityName,BaseDebit,BaseCredit,BaseBalance,ExchangeRate,BaseCurrency,DocCurrency,DocDebit,DocCredit,DocBalance,/*IsMultiCurrency,*/SegmentCategory1,SegmentCategory2,MCS_Status,Status, FCA.CorrAccount,[Entity Type],[Vendor Type],PONo,Nature,[CreditTerms(Days)],DueDate,[NSD ISCHECKED],[NO SUPPORT DOC],ItemCode,ItemDescription,Qty,Unit,UnitPrice,DiscountType,Discount,[BRM ISCHECKED],[ALLOWABLE/DISALLOWABLE],[Bank Clearing],ModeOfReceipt,ReversalDate,[Bank Reconcile],[Reversal Doc Ref],ClearingStatus,[Created By],[Created On],[Modified By],[Modified On],COA_Parameter

 from
 (
  /********* Step 4.3.3.1 : Getting records except coresponding account column ************************************/
 select       COA.Code+'  '+ COA.Name as 'COA Name', JD.DocType,JD.DocSubType,JD.docdescription as DocumentDescription,JD.DocDate,JD.DocNo,JD.SystemRefNo, SC.Name ServiceCompany,E.Name as EntityName,isnull(JD.BaseDebit,0) as BaseDebit,isnull(JD.BaseCredit,0) as BaseCredit,isnull((isnull(JD.BaseDebit,0)-isnull(JD.BaseCredit,0)),0) as BaseBalance,jd.ExchangeRate,jd.BaseCurrency,JD.DocCurrency,isnull(JD.DocDebit,0) as DocDebit,isnull(JD.DocCredit,0) as DocCredit,isnull((isnull(JD.DocDebit,0)-isnull(JD.DocCredit,0)),0) as DocBalance,IsMultiCurrency,jd.SegmentCategory1,JD.SegmentCategory2,Case when MCS.Status=1 then 1 else 0 end MCS_Status, SM3.Status,/*COA.Name as [Corr Account],*/
              JD.JournalId,case when E.IsCustomer=1 then 'Customer' when E.IsVendor=1 then 'Vendor' end as [Entity Type],E.VendorType as [Vendor Type],JD.PONo,JD.Nature,TP.TOPValue as [CreditTerms(Days)],J.DueDate,NSD.[NSD ISCHECKED],CASE WHEN J.IsNoSupportingDocument=0 THEN 'NO' WHEN J.IsNoSupportingDocument=1 THEN 'YES' END AS [NO SUPPORT DOC],JD.ItemCode,JD.ItemDescription,JD.Qty,JD.Unit,JD.UnitPrice,JD.DiscountType,JD.Discount,[BRM ISCHECKED],case when IsAllowableNonAllowable=0 then 'NO' when IsAllowableNonAllowable=1 then 'YES' END AS [ALLOWABLE/DISALLOWABLE],JD.ClearingDate AS [Bank Clearing],J.ModeOfReceipt,J.ReversalDate,
		      case when J.IsBankReconcile=0 then 'NO' when J.IsBankReconcile=1 then 'YES' end as [Bank Reconcile],case when J.IsAutoReversalJournal in (0,1) then J.SystemReferenceNo  end as [Reversal Doc Ref],JD.ClearingStatus,J.UserCreated as [Created By],J.CreatedDate as [Created On],J.ModifiedBy as [Modified By],J.ModifiedDate as [Modified On],@COA_BSheet as COA_Parameter
 From         Bean.JournalDetail JD 
 Inner Join   Bean.Journal J on J.Id=JD.JournalId
 Inner Join   Bean.ChartOfAccount COA on COA.Id=JD.COAId
 Inner Join   Common.Company as SC on SC.Id=JD.ServiceCompanyId
 Inner join   Bean.Entity as E on E.Id=JD.EntityId
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

 where COA.CompanyId=@CompanyId and  JD.DocumentDetailId<>'00000000-0000-0000-0000-000000000000' and COA.ModuleType='Bean' and JD.IsTax<>1
-- and JD.DocType  in('Credit Memo','Credit Note') 
and JD.DocSubType not in('CreditNote','Credit Memo')
 and COA.Name in(@COA_BSheet) and SC.Name in (SELECT items FROM dbo.SplitToTable(@ServiceCompany,','))
 and JD.DocDate between @FromDate and @ToDate and J.DocumentState<>'Void'
 --order by [COA Name],DocDate
 ) as MS1

 /*********Ending of Step 4.3.3.1 *************************/
 /*********** Step 4.3.3.2 : Getting corresponding account column. Here we joined to MS1 on  matching journalid condition ************/
 Left join-- for corraccount ** starting
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
			Where    J.CompanyId=@CompanyId and JD.DocumentDetailId='00000000-0000-0000-0000-000000000000' and COA.ModuleType='Bean' and J.DocumentState<>'Void' and JD.IsTax<>1

		) as CA1
		group by JournalId--,Name
	) as CA2
	Inner join
	(
		 select JD.JournalId,JD.COAId,COA.Name  
		 from   Bean.JournalDetail as JD
		join    Bean.Journal as J on J.Id=JD.JournalId
		join    Bean.ChartOfAccount as COA on COA.Id=JD.COAId
		where   J.CompanyId=@CompanyId and JD.DocumentDetailId='00000000-0000-0000-0000-000000000000' and COA.ModuleType='Bean' and J.DocumentState<>'Void' and JD.IsTax<>1

	) as CA3 on CA2.JournalId=CA3.JournalId
)as CA4 --ending
) as FCA on FCA.JournalId=MS1.JournalId
 order by [COA Name],DocDate
/*********** Ending of step 4.3.3.2 **************/
/*********** Ending of step 4.3.3.3 **************/
/*********** Ending of step 4.3.3 **************/
 End

 /******* End of step 4.3 (i.e Count = 0 condition ending) ***************/
Fetch next from Balancesheet_cursor into @COA_BSheet
end
Close Balancesheet_cursor
Deallocate Balancesheet_cursor

                                         /****** Ending step 4: Data for Balance Sheet coa's ending **********/

                                         /****** step 5: Data for Income Statement coa's **********/

Declare @COA_IS nvarchar(max)-- Income statement coa
Declare @count_IS int --count of docdate for broughtforward balance
Declare @Bus_Year_End NVarchar(200)
Declare @ToDate_Year NVarchar(200) 
Declare @BFFD date
Select @Bus_Year_End=BusinessYearEnd from Common.Localization Where CompanyId=@CompanyId
--print @Bus_Year_End
Select @ToDate_Year=CAST(Year(@ToDate) as nvarchar) --Here converting year of todate to nvarchar
--print @ToDate_Year

/***** Step 5.1 : Getting BFFD ***********/
If @Bus_Year_End <> '31-Dec'
Begin
Select @BFFD=DATEADD(day,1,CAST(@Bus_Year_End+'-'+@ToDate_Year as date))-- Here,we are concating @Bus_Year_End,@ToDate_Year and result is casting to date  and finally add 1 day to result and assign this result to @BFFD
--Print @BFFD
End

If @Bus_Year_End = '31-Dec'
Begin
Select @BFFD=DATEADD(yy, DATEDIFF(yy, 0, @ToDate), 0)-- Here, We are getting starting date of year of the todate and assigning to @BFFD
End
/********** Ending step 5.1 *******/

Declare IncomeSheet_cursor cursor for select * from @COA_IncomeStatement
Open IncomeSheet_cursor
Fetch next from IncomeSheet_cursor into @COA_IS
while @@FETCH_STATUS=0
Begin
 /*********** Step 5.2 : This block is used to retriew report data if @BFFD<@FromDate  ************/
   /*****We can retreive the brought forward balance first,then we can get record information of perticular coa ****/
If @BFFD<@FromDate 
Begin
Select @count_IS= Count(distinct DocDate) 
from
 (
	 select       JD.DocDate,COA.Name [COA Name],SC.Name as [SC Name]
	 from         Bean.JournalDetail as JD
	 inner join   Bean.Journal as J on J.Id=JD.JournalId
	 Inner Join   Bean.ChartOfAccount COA on COA.Id=JD.COAId
	 Inner Join   Common.Company as SC on SC.Id=JD.ServiceCompanyId
	 left join    Common.TermsOfPayment as TP on TP.Id=JD.CreditTermsId
	 where        COA.CompanyId=@CompanyId and J.DocumentState<>'Void'
 ) as dt1 
 where            DocDate between @BFFD and DATEADD(day,-1,@FromDate)  and [SC Name] in (SELECT items FROM dbo.SplitToTable(@ServiceCompany,',')) and [COA Name] in(@COA_IS) 
  --print @count_IS

 /*********** Step 5.2.a : This block is used to retriew report data if @BFFD<@FromDate and @count_IS<>0i.e. It is having Bal between BFFD and fromdate-1  ************/
   /*****We can retreive the brought forward balance first, then we can get record information of perticular coa between FromDate and ToDate****/
 If @count_IS<>0
 Begin

 /**** Step 5.2.a.1 : Retrieving Broutght forward balance *******/
 -- Step 5.2.a.1.2  grouping done for step 5.2.a.1.1
 Insert Into @GLReport
 select  [COA Name], 'Balance B/F' as DocType,'' as DocSubType,'' as DocumentDescription, DocDate,'' as DocNo,'' as SystemRefNo,'' as  ServiceCompany,''  as EntityName,null as BaseDebit,null as BaseCredit,sum(BaseBalance) as BaseBalance,null as ExchangeRate,BaseCurrency, DocCurrency, null as DocDebit,null as DocCredit,sum(DocBalance) as DocBalance/*IsMultiCurrency,*/,SegmentCategory1,SegmentCategory2, MCS_Status,Status as SegmentStatus,CorrAccount,[Entity Type],[Vendor Type],PONo,Nature,[CreditTerms(Days)],DueDate,[NSD ISCHECKED],[NO SUPPORT DOC],ItemCode,ItemDescription,Qty,Unit,UnitPrice,DiscountType,Discount,[BRM ISCHECKED],[ALLOWABLE/DISALLOWABLE],[Bank Clearing],ModeOfReceipt,ReversalDate,[Bank Reconcile],[Reversal Doc Ref],ClearingStatus,[Created By],[Created On],[Modified By],[Modified On],COA_Parameter

 from
 (
 --step 5.2.a.1.1 starting
 select     COA.Code+'  '+ COA.Name as 'COA Name', 'Balance B/F' as DocType,'' as DocSubType,'' as DocumentDescription,DATEADD(day,-1,@FromDate) as DocDate,'' as DocNo,'' as SystemRefNo,'' as  ServiceCompany,''  as EntityName,null as BaseDebit,null as BaseCredit,isnull((isnull(JD.BaseDebit,0)-isnull(JD.BaseCredit,0)),0) as BaseBalance,null as ExchangeRate,null as BaseCurrency,null as DocCurrency,null as DocDebit,null as DocCredit,isnull((isnull(JD.DocDebit,0)-isnull(JD.DocCredit,0)),0) as DocBalance,/*IsMultiCurrency,*/null as SegmentCategory1,null as SegmentCategory2,Case when MCS.Status=1 then 1 else 0 end MCS_Status, SM3.Status,/*COA.Name as [Corr Account],*/null as CorrAccount,null as [Entity Type],null as [Vendor Type],null as PONo,null as Nature,null as [CreditTerms(Days)],null as DueDate, [NSD ISCHECKED],NULL AS [NO SUPPORT DOC],
            NULL AS ItemCode,NULL AS ItemDescription,NULL AS Qty,JD.Unit,NULL AS UnitPrice,NULL AS DiscountType,NULL AS Discount,[BRM ISCHECKED],NULL AS [ALLOWABLE/DISALLOWABLE],null as [Bank Clearing],NULL AS ModeOfReceipt,null as ReversalDate,null as [Bank Reconcile],null as [Reversal Doc Ref],null as ClearingStatus,null as [Created By],null as [Created On],null as [Modified By],null as [Modified On],@COA_IS as COA_Parameter
 from       Bean.JournalDetail JD 
 Inner Join Bean.Journal J on J.Id=JD.JournalId
 Inner Join Bean.ChartOfAccount COA on COA.Id=JD.COAId
 Inner Join Common.Company as SC on SC.Id=JD.ServiceCompanyId
 Inner join Bean.Entity as E on E.Id=JD.EntityId
 Left join  Bean.SegmentMaster as SM1 on SM1.Id=JD.SegmentMasterid1 and J.CompanyId=SM1.CompanyId
 Left join  Bean.SegmentMaster as SM2 on SM2.Id=JD.SegmentMasterid1 and J.CompanyId=SM2.CompanyId
 Left join  Bean.MultiCurrencySetting MCS on MCS.companyId=J.CompanyId
 Left Join 
  (
	  select distinct CompanyId,status
	  from
	  (
	   select CompanyId, Status from bean.SegmentMaster where CompanyId=@CompanyId
	  ) as st1
  ) SM3 on SM3.companyid=J.CompanyId
 Left join Common.TermsOfPayment as TP on TP.Id=JD.CreditTermsId
 LEFT JOIN
  (
     Select  CompanyId,ISNULL(IsChecked,0) AS [NSD ISCHECKED]  
     From    Common.CompanyFeatures where CompanyId=@CompanyId and FeatureId=(select distinct id from Common.Feature where Name='No Supporting Documents') 
  ) AS NSD ON NSD.CompanyId=J.CompanyId
 LEFT JOIN
  (
     Select  CompanyId,ISNULL(IsChecked,0) AS [BRM ISCHECKED] 
     From    Common.CompanyFeatures where CompanyId=@CompanyId and FeatureId=(select distinct id from Common.Feature where Name='Bank Reconciliation') 
   ) AS BRM ON BRM.CompanyId=J.CompanyId

 where COA.CompanyId=@CompanyId and  JD.DocumentDetailId='00000000-0000-0000-0000-000000000000' and COA.ModuleType='Bean' and JD.IsTax<>1
 and JD.DocType not in('Credit Memo','Credit Note') and JD.DocSubType not in('CreditNote','Credit Memo')
 and COA.Name in(@COA_IS) and SC.Name in (SELECT items FROM dbo.SplitToTable(@ServiceCompany,','))
 and JD.DocDate between @BFFD and DATEADD(day,-1,@FromDate) and J.DocumentState<>'Void'
 --order by [COA Name],DocDate

 union all
 Select     COA.Code+'  '+ COA.Name as 'COA Name', 'Balance B/F' as DocType,'' as DocSubType,'' as DocumentDescription,DATEADD(day,-1,@FromDate) as DocDate,'' as DocNo,'' as SystemRefNo,'' as  ServiceCompany,''  as EntityName,null as BaseDebit,null as BaseCredit,isnull((isnull(JD.BaseDebit,0)-isnull(JD.BaseCredit,0)),0) as BaseBalance,null as ExchangeRate,null as BaseCurrency,null as DocCurrency,null as DocDebit,null as DocCredit,isnull((isnull(JD.DocDebit,0)-isnull(JD.DocCredit,0)),0) as DocBalance,/*IsMultiCurrency,*/null as SegmentCategory1,null as SegmentCategory2,Case when MCS.Status=1 then 1 else 0 end MCS_Status, SM3.Status,/*COA.Name as [Corr Account],*/null as CorrAccount,null as [Entity Type],null as [Vendor Type],null as PONo,null as Nature,null as [CreditTerms(Days)],null as DueDate,[NSD ISCHECKED],NULL AS [NO SUPPORT DOC],
            NULL AS ItemCode,NULL AS ItemDescription,NULL AS Qty,JD.Unit,NULL AS UnitPrice,NULL AS DiscountType,NULL AS Discount,[BRM ISCHECKED],NULL AS [ALLOWABLE/DISALLOWABLE],NULL AS [Bank Clearing],NULL AS ModeOfReceipt,null as ReversalDate,null as [Bank Reconcile],null as [Reversal Doc Ref],null as ClearingStatus,null as [Created By],null as [Created On],null as [Modified By],null as [Modified On],@COA_IS as COA_Parameter

 From       Bean.JournalDetail JD 
 Inner Join Bean.Journal J on J.Id=JD.JournalId
 Inner Join Bean.ChartOfAccount COA on COA.Id=JD.COAId
 Inner Join Common.Company as SC on SC.Id=JD.ServiceCompanyId
 Inner join Bean.Entity as E on E.Id=JD.EntityId
 Left join  Bean.SegmentMaster as SM1 on SM1.Id=JD.SegmentMasterid1 and J.CompanyId=SM1.CompanyId
 Left join  Bean.SegmentMaster as SM2 on SM2.Id=JD.SegmentMasterid1 and J.CompanyId=SM2.CompanyId
 Left join  Bean.MultiCurrencySetting MCS on MCS.companyId=J.CompanyId 
 Left Join 
  (
	  select distinct CompanyId,status
	  from
	  (
	   select CompanyId, Status from bean.SegmentMaster where CompanyId=@CompanyId
	  ) as st1
  ) SM3 on SM3.companyid=J.CompanyId
 Left join Common.TermsOfPayment as TP on TP.Id=JD.CreditTermsId
  LEFT JOIN
  (
     select CompanyId,ISNULL(IsChecked,0) AS [NSD ISCHECKED]  
    from Common.CompanyFeatures where CompanyId=@CompanyId and FeatureId=(select distinct id from Common.Feature where Name='No Supporting Documents') 
  ) AS NSD ON NSD.CompanyId=J.CompanyId
  LEFT JOIN
  (
     select CompanyId,ISNULL(IsChecked,0) AS [BRM ISCHECKED] 
     from Common.CompanyFeatures where CompanyId=@CompanyId and FeatureId=(select distinct id from Common.Feature where Name='Bank Reconciliation') 
   ) AS BRM ON BRM.CompanyId=J.CompanyId

 where COA.CompanyId=@CompanyId and  JD.DocumentDetailId<>'00000000-0000-0000-0000-000000000000' and COA.ModuleType='Bean' and JD.IsTax<>1
 --and JD.DocType  in('Credit Memo','Credit Note') 
 and JD.DocSubType not in('CreditNote','Credit Memo')
 and COA.Name in(@COA_IS) and SC.Name in (SELECT items FROM dbo.SplitToTable(@ServiceCompany,','))
 and JD.DocDate between @BFFD and DATEADD(day,-1,@FromDate) and J.DocumentState<>'Void'
 --order by [COA Name],DocDate
 --step 5.2.a.1.1 ending
 ) as DT3
 group by [COA Name],DocType,DocDate,BaseCurrency,DocCurrency,/*IsMultiCurrency,*/SegmentCategory1,SegmentCategory2,MCS_Status,Status,/*[Corr Account],*/CorrAccount,[Entity Type],[Vendor Type],PONo,Nature,[CreditTerms(Days)],DueDate,[NSD ISCHECKED],[NO SUPPORT DOC],ItemCode,ItemDescription,Qty,Unit,UnitPrice,DiscountType,Discount,[BRM ISCHECKED],[ALLOWABLE/DISALLOWABLE],[Bank Clearing],ModeOfReceipt,ReversalDate,[Bank Reconcile],[Reversal Doc Ref],ClearingStatus,[Created By],[Created On],[Modified By],[Modified On],COA_Parameter
 --step5.2.a.1.2 ending
 /*******Ending of 5.2.a.1 ***********/
 union all
 /********* Step 5.2.a.2 : Getting records when documentdetailid is 0 and JD.DocType not in('Credit Memo','Credit Note') and JD.DocSubType not in('CreditNote','Credit Memo') *******************/
 
 /*********** Step 5.2.a.2.3 : here we join MS1 (Step 5.2.a.2.1) and FCA (Step 5.2.a.2.2) *****************/
 /*********** Taking all columns from MS1 and corresponding Account column from FCA ****************/
 select [COA Name],DocType,DocSubType,DocumentDescription,DocDate,DocNo,SystemRefNo,ServiceCompany,EntityName,BaseDebit,BaseCredit,BaseBalance,ExchangeRate,BaseCurrency,DocCurrency,DocDebit,DocCredit,DocBalance,/*IsMultiCurrency,*/SegmentCategory1,SegmentCategory2,MCS_Status,Status, FCA.CorrAccount,[Entity Type],[Vendor Type],PONo,Nature,[CreditTerms(Days)],DueDate,[NSD ISCHECKED],[NO SUPPORT DOC],ItemCode,ItemDescription,Qty,Unit,UnitPrice,DiscountType,Discount,[BRM ISCHECKED],[ALLOWABLE/DISALLOWABLE],[Bank Clearing],ModeOfReceipt,ReversalDate,[Bank Reconcile],[Reversal Doc Ref],ClearingStatus,[Created By],[Created On],[Modified By],[Modified On],COA_Parameter

 from
 (
 /********* Step 5.2.a.2.1 : Getting records except coresponding account column ************************************/
 Select      COA.Code+'  '+ COA.Name as 'COA Name', JD.DocType,JD.DocSubType,JD.docdescription as DocumentDescription,JD.DocDate,JD.DocNo,JD.SystemRefNo, SC.Name ServiceCompany,E.Name as EntityName,isnull(JD.BaseDebit,0) as BaseDebit,isnull(JD.BaseCredit,0) as BaseCredit,isnull((isnull(JD.BaseDebit,0)-isnull(JD.BaseCredit,0)),0) as BaseBalance,jd.ExchangeRate,jd.BaseCurrency,JD.DocCurrency,isnull(JD.DocDebit,0) as DocDebit,isnull(JD.DocCredit,0) as DocCredit ,isnull((isnull(JD.DocDebit,0)-isnull(JD.DocCredit,0)),0) as DocBalance,/*IsMultiCurrency,*/jd.SegmentCategory1,JD.SegmentCategory2,Case when MCS.Status=1 then 1 else 0 end MCS_Status, SM3.Status,/*COA.Name as [Corr Account],*/
             JD.JournalId,case when E.IsCustomer=1 then 'Customer' when E.IsVendor=1 then 'Vendor' end as [Entity Type],E.VendorType as [Vendor Type],JD.PONo,JD.Nature,TP.TOPValue as [CreditTerms(Days)],J.DueDate,NSD.[NSD ISCHECKED],CASE WHEN J.IsNoSupportingDocument=0 THEN 'NO' WHEN J.IsNoSupportingDocument=1 THEN 'YES' END AS [NO SUPPORT DOC],JD.ItemCode,JD.ItemDescription,JD.Qty,JD.Unit,JD.UnitPrice,JD.DiscountType,JD.Discount,[BRM ISCHECKED],case when IsAllowableNonAllowable=0 then 'NO' when IsAllowableNonAllowable=1 then 'YES' END AS [ALLOWABLE/DISALLOWABLE],JD.ClearingDate AS [Bank Clearing],J.ModeOfReceipt,J.ReversalDate,
		     case when J.IsBankReconcile=0 then 'NO' when J.IsBankReconcile=1 then 'YES' end as [Bank Reconcile],case when J.IsAutoReversalJournal in (0,1) then J.SystemReferenceNo  end as [Reversal Doc Ref],JD.ClearingStatus,J.UserCreated as [Created By],J.CreatedDate as [Created On],J.ModifiedBy as [Modified By],J.ModifiedDate as [Modified On],@COA_IS as COA_Parameter
 From        Bean.JournalDetail JD 
 Inner Join  Bean.Journal J on J.Id=JD.JournalId
 Inner Join  Bean.ChartOfAccount COA on COA.Id=JD.COAId
 Inner Join  Common.Company as SC on SC.Id=JD.ServiceCompanyId
 Inner join  Bean.Entity as E on E.Id=JD.EntityId
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

 where COA.CompanyId=@CompanyId and  JD.DocumentDetailId='00000000-0000-0000-0000-000000000000' and COA.ModuleType='Bean' and JD.IsTax<>1
 and JD.DocType not in('Credit Memo','Credit Note') and JD.DocSubType not in('CreditNote','Credit Memo')
 and COA.Name in(@COA_IS) and SC.Name in (SELECT items FROM dbo.SplitToTable(@ServiceCompany,','))
 and JD.DocDate between @FromDate and @ToDate and J.DocumentState<>'Void'
 --order by [COA Name],DocDate
 ) as MS1

 /*********Ending of Step 5.2.a.2.1 *************************/
 /*********** Step 5.2.a.2.2 : Getting corresponding account column. Here we joined to MS1 on  matching journalid condition ************/
 Left join-- for corraccount ** starting
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
			 where   J.CompanyId=@CompanyId and JD.DocumentDetailId<>'00000000-0000-0000-0000-000000000000' and COA.ModuleType='Bean' and J.DocumentState<>'Void' and JD.IsTax<>1 

		) as CA1
		group by JournalId--,Name
	) as CA2
	Inner join
	(
		 select  JD.JournalId,JD.COAId,COA.Name  
		 from    Bean.JournalDetail as JD
		 join    Bean.Journal as J on J.Id=JD.JournalId
		 join    Bean.ChartOfAccount as COA on COA.Id=JD.COAId
		 where   J.CompanyId=@CompanyId and JD.DocumentDetailId<>'00000000-0000-0000-0000-000000000000' and COA.ModuleType='Bean' and J.DocumentState<>'Void' and JD.IsTax<>1 

	) as CA3 on CA2.JournalId=CA3.JournalId
)as CA4 --ending
) as FCA on FCA.JournalId=MS1.JournalId
--order by [COA Name]

/*********** Ending of step 5.2.a.2.2 **************/
/*********** Ending of step 5.2.a.2.3 **************/
/*********** Ending of step 5.2.a.2 **************/
union all

/********* Step 5.2.a.3 : Getting records when documentdetailid is  not 0 and JD.DocSubType not in('CreditNote','Credit Memo') *******************/
 /*********** Step 5.2.a.3.3 : here we join MS1 (Step 5.2.a.3.1) and FCA (Step 5.2.a.3.2) *****************/
 /*********** Taking all columns from MS1 and corresponding Account column from FCA ****************/

 select [COA Name],DocType,DocSubType,DocumentDescription,DocDate,DocNo,SystemRefNo,ServiceCompany,EntityName,BaseDebit,BaseCredit,BaseBalance,ExchangeRate,BaseCurrency,DocCurrency,DocDebit,DocCredit,DocBalance,/*IsMultiCurrency,*/SegmentCategory1,SegmentCategory2,MCS_Status,Status, FCA.CorrAccount,[Entity Type],[Vendor Type],PONo,Nature,[CreditTerms(Days)],DueDate,[NSD ISCHECKED],[NO SUPPORT DOC],ItemCode,ItemDescription,Qty,Unit,UnitPrice,DiscountType,Discount,[BRM ISCHECKED],[ALLOWABLE/DISALLOWABLE],[Bank Clearing],ModeOfReceipt,ReversalDate,[Bank Reconcile],[Reversal Doc Ref],ClearingStatus,[Created By],[Created On],[Modified By],[Modified On],COA_Parameter

 from
 (
  /********* Step 5.2.a.3.1 : Getting records except coresponding account column ************************************/
 select       COA.Code+'  '+ COA.Name as 'COA Name', JD.DocType,JD.DocSubType,JD.docdescription as DocumentDescription,JD.DocDate,JD.DocNo,JD.SystemRefNo, SC.Name ServiceCompany,E.Name as EntityName,isnull(JD.BaseDebit,0) as BaseDebit,isnull(JD.BaseCredit,0) as BaseCredit,isnull((isnull(JD.BaseDebit,0)-isnull(JD.BaseCredit,0)),0) as BaseBalance,jd.ExchangeRate,jd.BaseCurrency,JD.DocCurrency,isnull(JD.DocDebit,0) as DocDebit,isnull(JD.DocCredit,0) as DocCredit,isnull((isnull(JD.DocDebit,0)-isnull(JD.DocCredit,0)),0) as DocBalance,IsMultiCurrency,jd.SegmentCategory1,JD.SegmentCategory2,Case when MCS.Status=1 then 1 else 0 end MCS_Status, SM3.Status,/*COA.Name as [Corr Account],*/
              JD.JournalId,case when E.IsCustomer=1 then 'Customer' when E.IsVendor=1 then 'Vendor' end as [Entity Type],E.VendorType as [Vendor Type],JD.PONo,JD.Nature,TP.TOPValue as [CreditTerms(Days)],J.DueDate,NSD.[NSD ISCHECKED],CASE WHEN J.IsNoSupportingDocument=0 THEN 'NO' WHEN J.IsNoSupportingDocument=1 THEN 'YES' END AS [NO SUPPORT DOC],JD.ItemCode,JD.ItemDescription,JD.Qty,JD.Unit,JD.UnitPrice,JD.DiscountType,JD.Discount,[BRM ISCHECKED],case when IsAllowableNonAllowable=0 then 'NO' when IsAllowableNonAllowable=1 then 'YES' END AS [ALLOWABLE/DISALLOWABLE],JD.ClearingDate AS [Bank Clearing],J.ModeOfReceipt,J.ReversalDate,
		      case when J.IsBankReconcile=0 then 'NO' when J.IsBankReconcile=1 then 'YES' end as [Bank Reconcile],case when J.IsAutoReversalJournal in (0,1) then J.SystemReferenceNo  end as [Reversal Doc Ref],JD.ClearingStatus,J.UserCreated as [Created By],J.CreatedDate as [Created On],J.ModifiedBy as [Modified By],J.ModifiedDate as [Modified On],@COA_IS as COA_Parameter
 From         Bean.JournalDetail JD 
 Inner Join   Bean.Journal J on J.Id=JD.JournalId
 Inner Join   Bean.ChartOfAccount COA on COA.Id=JD.COAId
 Inner Join   Common.Company as SC on SC.Id=JD.ServiceCompanyId
 Inner join   Bean.Entity as E on E.Id=JD.EntityId
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

 where COA.CompanyId=@CompanyId and  JD.DocumentDetailId<>'00000000-0000-0000-0000-000000000000' and COA.ModuleType='Bean' and JD.IsTax<>1
-- and JD.DocType  in('Credit Memo','Credit Note') 
and JD.DocSubType not in('CreditNote','Credit Memo')
 and COA.Name in(@COA_IS) and SC.Name in (SELECT items FROM dbo.SplitToTable(@ServiceCompany,','))
 and JD.DocDate between @FromDate and @ToDate and J.DocumentState<>'Void'
 --order by [COA Name],DocDate
 ) as MS1

 /*********Ending of Step 5.2.a.3.1 *************************/
 /*********** Step 5.2.a.3.2 : Getting corresponding account column. Here we joined to MS1 on  matching journalid condition ************/
 Left join-- for corraccount ** starting
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
			Where    J.CompanyId=@CompanyId and JD.DocumentDetailId='00000000-0000-0000-0000-000000000000' and COA.ModuleType='Bean' and J.DocumentState<>'Void' and JD.IsTax<>1

		) as CA1
		group by JournalId--,Name
	) as CA2
	Inner join
	(
		 select JD.JournalId,JD.COAId,COA.Name  
		 from   Bean.JournalDetail as JD
		join    Bean.Journal as J on J.Id=JD.JournalId
		join    Bean.ChartOfAccount as COA on COA.Id=JD.COAId
		where   J.CompanyId=@CompanyId and JD.DocumentDetailId='00000000-0000-0000-0000-000000000000' and COA.ModuleType='Bean' and J.DocumentState<>'Void' and JD.IsTax<>1

	) as CA3 on CA2.JournalId=CA3.JournalId
)as CA4 --ending
) as FCA on FCA.JournalId=MS1.JournalId
 order by [COA Name],DocDate
/*********** Ending of step 5.2.a.3.2 **************/
/*********** Ending of step 5.2.a.3.3 **************/
/*********** Ending of step 5.2.a.3 **************/
 End

 /******* End of step 5.2.a (i.e Count<>0 condition  when @BFFD<@FromDate  is ending) ***************/


 --End

   /*********** Step 5.2.b : This block is used to retriew report data if @count_IS = 0 i.e. It does not having Bal before fromdate ************/
   /*****First,We can assign brought forward balance as 0.00 , then we can get record information of perticular coa between FromDate and ToDate****/
 Else If @count_IS=0
 Begin

 /**** Step 5.2.b.1 : Retrieving Broutght forward balance *******/
 -- Step 5.2.b.1.2  grouping done for step  5.2.b.1.1
 Insert Into @GLReport
 select  [COA Name], 'Balance B/F' as DocType,'' as DocSubType,'' as DocumentDescription, DocDate,'' as DocNo,'' as SystemRefNo,'' as  ServiceCompany,''  as EntityName,null as BaseDebit,null as BaseCredit,sum(BaseBalance) as BaseBalance,null as ExchangeRate,BaseCurrency, DocCurrency, null as DocDebit,null as DocCredit,sum(DocBalance) as DocBalance/*IsMultiCurrency,*/,SegmentCategory1,SegmentCategory2, MCS_Status,Status as SegmentStatus,CorrAccount,[Entity Type],[Vendor Type],PONo,Nature,[CreditTerms(Days)],DueDate,[NSD ISCHECKED],[NO SUPPORT DOC],ItemCode,ItemDescription,Qty,Unit,UnitPrice,DiscountType,Discount,[BRM ISCHECKED],[ALLOWABLE/DISALLOWABLE],[Bank Clearing],ModeOfReceipt,ReversalDate,[Bank Reconcile],[Reversal Doc Ref],ClearingStatus,[Created By],[Created On],[Modified By],[Modified On],COA_Parameter

 from
 (
 --step 5.2.b.1.1 starting
 select     COA.Code+'  '+ COA.Name as 'COA Name', 'Balance B/F' as DocType,'' as DocumentDescription,DATEADD(day,-1,@FromDate) as DocDate,'' as DocNo,'' as SystemRefNo,'' as  ServiceCompany,''  as EntityName,null as BaseDebit,null as BaseCredit,0.00 as BaseBalance,null as ExchangeRate,null as BaseCurrency,null as DocCurrency,null as DocDebit,null as DocCredit,0.00 as DocBalance,/*IsMultiCurrency,*/null as SegmentCategory1,null as SegmentCategory2,Case when MCS.Status=1 then 1 else 0 end MCS_Status, SM3.Status,/*COA.Name as [Corr Account],*/null as CorrAccount,null as [Entity Type],null as [Vendor Type],null as PONo,null as Nature,null as [CreditTerms(Days)],null as DueDate,[NSD ISCHECKED],NULL AS [NO SUPPORT DOC],
            NULL AS ItemCode,NULL AS ItemDescription,NULL AS Qty,NULL AS Unit,NULL AS UnitPrice,NULL AS DiscountType,NULL AS Discount,[BRM ISCHECKED],NULL AS [ALLOWABLE/DISALLOWABLE],NULL AS [Bank Clearing],NULL AS ModeOfReceipt,NULL AS ReversalDate,null as [Bank Reconcile],null as [Reversal Doc Ref],null as ClearingStatus,null as [Created By],null as [Created On],null as [Modified By],null as [Modified On],@COA_IS as COA_Parameter
 from       Bean.JournalDetail JD 
 Inner Join Bean.Journal J on J.Id=JD.JournalId
 Inner Join Bean.ChartOfAccount COA on COA.Id=JD.COAId
 Inner Join Common.Company as SC on SC.Id=JD.ServiceCompanyId
 Inner join Bean.Entity as E on E.Id=JD.EntityId
 Left join  Bean.SegmentMaster as SM1 on SM1.Id=JD.SegmentMasterid1 and J.CompanyId=SM1.CompanyId
 Left join  Bean.SegmentMaster as SM2 on SM2.Id=JD.SegmentMasterid1 and J.CompanyId=SM2.CompanyId
 Left join  Bean.MultiCurrencySetting MCS on MCS.companyId=J.CompanyId
 Left Join 
  (
	  select distinct CompanyId,status
	  from
	  (
	   select CompanyId, Status from bean.SegmentMaster where CompanyId=@CompanyId
	  ) as st1
  ) SM3 on SM3.companyid=J.CompanyId
 Left join Common.TermsOfPayment as TP on TP.Id=JD.CreditTermsId
 LEFT JOIN
  (
     Select  CompanyId,ISNULL(IsChecked,0) AS [NSD ISCHECKED]  
     From    Common.CompanyFeatures where CompanyId=@CompanyId and FeatureId=(select distinct id from Common.Feature where Name='No Supporting Documents') 
  ) AS NSD ON NSD.CompanyId=J.CompanyId
 LEFT JOIN
  (
     Select  CompanyId,ISNULL(IsChecked,0) AS [BRM ISCHECKED] 
     From    Common.CompanyFeatures where CompanyId=@CompanyId and FeatureId=(select distinct id from Common.Feature where Name='Bank Reconciliation') 
   ) AS BRM ON BRM.CompanyId=J.CompanyId

 where COA.CompanyId=@CompanyId and  JD.DocumentDetailId='00000000-0000-0000-0000-000000000000' and COA.ModuleType='Bean' and JD.IsTax<>1
 and JD.DocType not in('Credit Memo','Credit Note') and JD.DocSubType not in('CreditNote','Credit Memo')
 and COA.Name in(@COA_IS) and SC.Name in (SELECT items FROM dbo.SplitToTable(@ServiceCompany,','))
 /*and JD.DocDate between @BFFD and DATEADD(day,-1,@FromDate)*/ and J.DocumentState<>'Void'
 --order by [COA Name],DocDate

 union all
 Select     COA.Code+'  '+ COA.Name as 'COA Name', 'Balance B/F' as DocType,'' as DocumentDescription,DATEADD(day,-1,@FromDate) as DocDate,'' as DocNo,'' as SystemRefNo,'' as  ServiceCompany,''  as EntityName,null as BaseDebit,null as BaseCredit,0.00 as BaseBalance,null as ExchangeRate,null as BaseCurrency,null as DocCurrency,null as DocDebit,null as DocCredit,0.00 as DocBalance,/*IsMultiCurrency,*/null as SegmentCategory1,null as SegmentCategory2,Case when MCS.Status=1 then 1 else 0 end MCS_Status, SM3.Status,/*COA.Name as [Corr Account],*/null as CorrAccount,null as [Entity Type],null as [Vendor Type],null as PONo,null as Nature,null as [CreditTerms(Days)],null as DueDate,[NSD ISCHECKED],NULL AS [NO SUPPORT DOC],
            NULL AS ItemCode,NULL AS ItemDescription,NULL AS Qty,NULL AS Unit,NULL AS UnitPrice,NULL AS DiscountType,NULL AS Discount,[BRM ISCHECKED],NULL AS [ALLOWABLE/DISALLOWABLE],NULL AS [Bank Clearing],NULL AS ModeOfReceipt,NULL AS ReversalDate,null as [Bank Reconcile],null as [Reversal Doc Ref],null as ClearingStatus,null as [Created By],null as [Created On],null as [Modified By],null as [Modified On],@COA_IS as COA_Parameter
 from       Bean.JournalDetail JD 
 Inner Join Bean.Journal J on J.Id=JD.JournalId
 Inner Join Bean.ChartOfAccount COA on COA.Id=JD.COAId
 Inner Join Common.Company as SC on SC.Id=JD.ServiceCompanyId
 Inner join Bean.Entity as E on E.Id=JD.EntityId
 Left join  Bean.SegmentMaster as SM1 on SM1.Id=JD.SegmentMasterid1 and J.CompanyId=SM1.CompanyId
 Left join  Bean.SegmentMaster as SM2 on SM2.Id=JD.SegmentMasterid1 and J.CompanyId=SM2.CompanyId
 Left join  Bean.MultiCurrencySetting MCS on MCS.companyId=J.CompanyId 
 Left Join 
  (
	  select distinct CompanyId,status
	  from
	  (
	   select CompanyId, Status from bean.SegmentMaster where CompanyId=@CompanyId
	  ) as st1
  ) SM3 on SM3.companyid=J.CompanyId
 Left join Common.TermsOfPayment as TP on TP.Id=JD.CreditTermsId
  LEFT JOIN
  (
     select CompanyId,ISNULL(IsChecked,0) AS [NSD ISCHECKED]  
    from Common.CompanyFeatures where CompanyId=@CompanyId and FeatureId=(select distinct id from Common.Feature where Name='No Supporting Documents') 
  ) AS NSD ON NSD.CompanyId=J.CompanyId
  LEFT JOIN
  (
     select CompanyId,ISNULL(IsChecked,0) AS [BRM ISCHECKED] 
     from Common.CompanyFeatures where CompanyId=@CompanyId and FeatureId=(select distinct id from Common.Feature where Name='Bank Reconciliation') 
   ) AS BRM ON BRM.CompanyId=J.CompanyId

 where COA.CompanyId=@CompanyId and  JD.DocumentDetailId<>'00000000-0000-0000-0000-000000000000' and COA.ModuleType='Bean' and JD.IsTax<>1
 --and JD.DocType  in('Credit Memo','Credit Note') 
 and JD.DocSubType not in('CreditNote','Credit Memo')
 and COA.Name in(@COA_IS) and SC.Name in (SELECT items FROM dbo.SplitToTable(@ServiceCompany,','))
 /*and JD.DocDate between @BFFD and DATEADD(day,-1,@FromDate)*/ and J.DocumentState<>'Void'
 --order by [COA Name],DocDate
 --step 5.2.b.1.1 ending
 ) as DT3
 group by [COA Name],DocType,DocDate,BaseCurrency,DocCurrency,/*IsMultiCurrency,*/SegmentCategory1,SegmentCategory2,MCS_Status,Status,/*[Corr Account],*/CorrAccount,[Entity Type],[Vendor Type],PONo,Nature,[CreditTerms(Days)],DueDate,[NSD ISCHECKED],[NO SUPPORT DOC],ItemCode,ItemDescription,Qty,Unit,UnitPrice,DiscountType,Discount,[BRM ISCHECKED],[ALLOWABLE/DISALLOWABLE],[Bank Clearing],ModeOfReceipt,ReversalDate,[Bank Reconcile],[Reversal Doc Ref],ClearingStatus,[Created By],[Created On],[Modified By],[Modified On],COA_Parameter
 --step5.2.b.1.2 ending
 /*******Ending of 5.2.b.1 ***********/
 union all
 /********* Step 5.2.b.2 : Getting records when documentdetailid is 0 and JD.DocType not in('Credit Memo','Credit Note') and JD.DocSubType not in('CreditNote','Credit Memo') *******************/
 
 /*********** Step 5.2.b.2.3 : here we join MS1 (Step 5.2.b.2.1) and FCA (Step 5.2.b.2.2) *****************/
 /*********** Taking all columns from MS1 and corresponding Account column from FCA ****************/
 select [COA Name],DocType,DocSubType,DocumentDescription,DocDate,DocNo,SystemRefNo,ServiceCompany,EntityName,BaseDebit,BaseCredit,BaseBalance,ExchangeRate,BaseCurrency,DocCurrency,DocDebit,DocCredit,DocBalance,/*IsMultiCurrency,*/SegmentCategory1,SegmentCategory2,MCS_Status,Status, FCA.CorrAccount,[Entity Type],[Vendor Type],PONo,Nature,[CreditTerms(Days)],DueDate,[NSD ISCHECKED],[NO SUPPORT DOC],ItemCode,ItemDescription,Qty,Unit,UnitPrice,DiscountType,Discount,[BRM ISCHECKED],[ALLOWABLE/DISALLOWABLE],[Bank Clearing],ModeOfReceipt,ReversalDate,[Bank Reconcile],[Reversal Doc Ref],ClearingStatus,[Created By],[Created On],[Modified By],[Modified On],COA_Parameter

 from
 (
 /********* Step 5.2.b.2.1 : Getting records except coresponding account column ************************************/
 Select      COA.Code+'  '+ COA.Name as 'COA Name', JD.DocType,JD.DocSubType,JD.docdescription as DocumentDescription,JD.DocDate,JD.DocNo,JD.SystemRefNo, SC.Name ServiceCompany,E.Name as EntityName,isnull(JD.BaseDebit,0) as BaseDebit,isnull(JD.BaseCredit,0) as BaseCredit,isnull((isnull(JD.BaseDebit,0)-isnull(JD.BaseCredit,0)),0) as BaseBalance,jd.ExchangeRate,jd.BaseCurrency,JD.DocCurrency,isnull(JD.DocDebit,0) as DocDebit,isnull(JD.DocCredit,0) as DocCredit ,isnull((isnull(JD.DocDebit,0)-isnull(JD.DocCredit,0)),0) as DocBalance,/*IsMultiCurrency,*/jd.SegmentCategory1,JD.SegmentCategory2,Case when MCS.Status=1 then 1 else 0 end MCS_Status, SM3.Status,/*COA.Name as [Corr Account],*/
             JD.JournalId,case when E.IsCustomer=1 then 'Customer' when E.IsVendor=1 then 'Vendor' end as [Entity Type],E.VendorType as [Vendor Type],JD.PONo,JD.Nature,TP.TOPValue as [CreditTerms(Days)],J.DueDate,NSD.[NSD ISCHECKED],CASE WHEN J.IsNoSupportingDocument=0 THEN 'NO' WHEN J.IsNoSupportingDocument=1 THEN 'YES' END AS [NO SUPPORT DOC],JD.ItemCode,JD.ItemDescription,JD.Qty,JD.Unit,JD.UnitPrice,JD.DiscountType,JD.Discount,[BRM ISCHECKED],case when IsAllowableNonAllowable=0 then 'NO' when IsAllowableNonAllowable=1 then 'YES' END AS [ALLOWABLE/DISALLOWABLE],JD.ClearingDate AS [Bank Clearing],J.ModeOfReceipt,J.ReversalDate,
		     case when J.IsBankReconcile=0 then 'NO' when J.IsBankReconcile=1 then 'YES' end as [Bank Reconcile],case when J.IsAutoReversalJournal in (0,1) then J.SystemReferenceNo  end as [Reversal Doc Ref],JD.ClearingStatus,J.UserCreated as [Created By],J.CreatedDate as [Created On],J.ModifiedBy as [Modified By],J.ModifiedDate as [Modified On],@COA_IS as COA_Parameter
 From        Bean.JournalDetail JD 
 Inner Join  Bean.Journal J on J.Id=JD.JournalId
 Inner Join  Bean.ChartOfAccount COA on COA.Id=JD.COAId
 Inner Join  Common.Company as SC on SC.Id=JD.ServiceCompanyId
 Inner join  Bean.Entity as E on E.Id=JD.EntityId
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

 where COA.CompanyId=@CompanyId and  JD.DocumentDetailId='00000000-0000-0000-0000-000000000000' and COA.ModuleType='Bean' and JD.IsTax<>1
 and JD.DocType not in('Credit Memo','Credit Note') and JD.DocSubType not in('CreditNote','Credit Memo')
 and COA.Name in(@COA_IS) and SC.Name in (SELECT items FROM dbo.SplitToTable(@ServiceCompany,','))
 and JD.DocDate between @FromDate and @ToDate and J.DocumentState<>'Void'
 --order by [COA Name],DocDate
 ) as MS1

 /*********Ending of Step 5.2.b.2.1 *************************/
 /*********** Step 5.2.b.2.2 : Getting corresponding account column. Here we joined to MS1 on  matching journalid condition ************/
 Left join-- for corraccount ** starting
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
			 where   J.CompanyId=@CompanyId and JD.DocumentDetailId<>'00000000-0000-0000-0000-000000000000' and COA.ModuleType='Bean' and J.DocumentState<>'Void' and JD.IsTax<>1 

		) as CA1
		group by JournalId--,Name
	) as CA2
	Inner join
	(
		 select  JD.JournalId,JD.COAId,COA.Name  
		 from    Bean.JournalDetail as JD
		 join    Bean.Journal as J on J.Id=JD.JournalId
		 join    Bean.ChartOfAccount as COA on COA.Id=JD.COAId
		 where   J.CompanyId=@CompanyId and JD.DocumentDetailId<>'00000000-0000-0000-0000-000000000000' and COA.ModuleType='Bean' and J.DocumentState<>'Void' and JD.IsTax<>1 

	) as CA3 on CA2.JournalId=CA3.JournalId
)as CA4 --ending
) as FCA on FCA.JournalId=MS1.JournalId
--order by [COA Name]

/*********** Ending of step 5.2.b.2.2 **************/
/*********** Ending of step 5.2.b.2.3 **************/
/*********** Ending of step 5.2.b.2 **************/
union all

/********* Step 5.2.b.3 : Getting records when documentdetailid is  not 0 and JD.DocSubType not in('CreditNote','Credit Memo') *******************/
 /*********** Step 5.2.b.3.3 : here we join MS1 (Step 5.2.b.3.1) and FCA (Step 5.2.b.3.2) *****************/
 /*********** Taking all columns from MS1 and corresponding Account column from FCA ****************/

 select [COA Name],DocType,DocSubType,DocumentDescription,DocDate,DocNo,SystemRefNo,ServiceCompany,EntityName,BaseDebit,BaseCredit,BaseBalance,ExchangeRate,BaseCurrency,DocCurrency,DocDebit,DocCredit,DocBalance,/*IsMultiCurrency,*/SegmentCategory1,SegmentCategory2,MCS_Status,Status, FCA.CorrAccount,[Entity Type],[Vendor Type],PONo,Nature,[CreditTerms(Days)],DueDate,[NSD ISCHECKED],[NO SUPPORT DOC],ItemCode,ItemDescription,Qty,Unit,UnitPrice,DiscountType,Discount,[BRM ISCHECKED],[ALLOWABLE/DISALLOWABLE],[Bank Clearing],ModeOfReceipt,ReversalDate,[Bank Reconcile],[Reversal Doc Ref],ClearingStatus,[Created By],[Created On],[Modified By],[Modified On],COA_Parameter

 from
 (
  /********* Step 5.2.b.3.1 : Getting records except coresponding account column ************************************/
 select       COA.Code+'  '+ COA.Name as 'COA Name', JD.DocType,JD.DocSubType,JD.docdescription as DocumentDescription,JD.DocDate,JD.DocNo,JD.SystemRefNo, SC.Name ServiceCompany,E.Name as EntityName,isnull(JD.BaseDebit,0) as BaseDebit,isnull(JD.BaseCredit,0) as BaseCredit,isnull((isnull(JD.BaseDebit,0)-isnull(JD.BaseCredit,0)),0) as BaseBalance,jd.ExchangeRate,jd.BaseCurrency,JD.DocCurrency,isnull(JD.DocDebit,0) as DocDebit,isnull(JD.DocCredit,0) as DocCredit,isnull((isnull(JD.DocDebit,0)-isnull(JD.DocCredit,0)),0) as DocBalance,IsMultiCurrency,jd.SegmentCategory1,JD.SegmentCategory2,Case when MCS.Status=1 then 1 else 0 end MCS_Status, SM3.Status,/*COA.Name as [Corr Account],*/
              JD.JournalId,case when E.IsCustomer=1 then 'Customer' when E.IsVendor=1 then 'Vendor' end as [Entity Type],E.VendorType as [Vendor Type],JD.PONo,JD.Nature,TP.TOPValue as [CreditTerms(Days)],J.DueDate,NSD.[NSD ISCHECKED],CASE WHEN J.IsNoSupportingDocument=0 THEN 'NO' WHEN J.IsNoSupportingDocument=1 THEN 'YES' END AS [NO SUPPORT DOC],JD.ItemCode,JD.ItemDescription,JD.Qty,JD.Unit,JD.UnitPrice,JD.DiscountType,JD.Discount,[BRM ISCHECKED],case when IsAllowableNonAllowable=0 then 'NO' when IsAllowableNonAllowable=1 then 'YES' END AS [ALLOWABLE/DISALLOWABLE],JD.ClearingDate AS [Bank Clearing],J.ModeOfReceipt,J.ReversalDate,
		      case when J.IsBankReconcile=0 then 'NO' when J.IsBankReconcile=1 then 'YES' end as [Bank Reconcile],case when J.IsAutoReversalJournal in (0,1) then J.SystemReferenceNo  end as [Reversal Doc Ref],JD.ClearingStatus,J.UserCreated as [Created By],J.CreatedDate as [Created On],J.ModifiedBy as [Modified By],J.ModifiedDate as [Modified On],@COA_IS as COA_Parameter
 From         Bean.JournalDetail JD 
 Inner Join   Bean.Journal J on J.Id=JD.JournalId
 Inner Join   Bean.ChartOfAccount COA on COA.Id=JD.COAId
 Inner Join   Common.Company as SC on SC.Id=JD.ServiceCompanyId
 Inner join   Bean.Entity as E on E.Id=JD.EntityId
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

 where COA.CompanyId=@CompanyId and  JD.DocumentDetailId<>'00000000-0000-0000-0000-000000000000' and COA.ModuleType='Bean' and JD.IsTax<>1
-- and JD.DocType  in('Credit Memo','Credit Note') 
and JD.DocSubType not in('CreditNote','Credit Memo')
 and COA.Name in(@COA_IS) and SC.Name in (SELECT items FROM dbo.SplitToTable(@ServiceCompany,','))
 and JD.DocDate between @FromDate and @ToDate and J.DocumentState<>'Void'
 --order by [COA Name],DocDate
 ) as MS1

 /*********Ending of Step 5.2.b.3.1 *************************/
 /*********** Step 5.2.b.3.2 : Getting corresponding account column. Here we joined to MS1 on  matching journalid condition ************/
 Left join-- for corraccount ** starting
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
			Where    J.CompanyId=@CompanyId and JD.DocumentDetailId='00000000-0000-0000-0000-000000000000' and COA.ModuleType='Bean' and J.DocumentState<>'Void' and JD.IsTax<>1

		) as CA1
		group by JournalId--,Name
	) as CA2
	Inner join
	(
		 select JD.JournalId,JD.COAId,COA.Name  
		 from   Bean.JournalDetail as JD
		join    Bean.Journal as J on J.Id=JD.JournalId
		join    Bean.ChartOfAccount as COA on COA.Id=JD.COAId
		where   J.CompanyId=@CompanyId and JD.DocumentDetailId='00000000-0000-0000-0000-000000000000' and COA.ModuleType='Bean' and J.DocumentState<>'Void' and JD.IsTax<>1

	) as CA3 on CA2.JournalId=CA3.JournalId
)as CA4 --ending
) as FCA on FCA.JournalId=MS1.JournalId
 order by [COA Name],DocDate
/*********** Ending of step 5.2.b.3.2 **************/
/*********** Ending of step 5.2.b.3.3 **************/
/*********** Ending of step 5.2.b.3 **************/
 End

 /******* End of step 5.2.b (i.e Count = 0 condition ending) ***************/


 End

  /******* End of step 5.2 (i.e @BFFD<@FromDate condition ending) ***************/

Else 
 /*********** Step 5.3 : This block is used to retriew report data other than @BFFD<@FromDate condition is true ************/
   /*****We can retreive the brought forward balance first,then we can get record information of perticular coa ****/
begin
/**** Step 5.3.1 : Retrieving Broutght forward balance. In this scenario brought forwarded balance is set to 0 *******/
 -- Step 5.3.1.2:  grouping done for step  5.3.1.1
 Insert Into @GLReport
 select  [COA Name], 'Balance B/F' as DocType,'' as DocSubType,'' as DocumentDescription, DocDate,'' as DocNo,'' as SystemRefNo,'' as  ServiceCompany,''  as EntityName,null as BaseDebit,null as BaseCredit,sum(BaseBalance) as BaseBalance,null as ExchangeRate,BaseCurrency, DocCurrency, null as DocDebit,null as DocCredit,sum(DocBalance) as DocBalance/*IsMultiCurrency,*/,SegmentCategory1,SegmentCategory2, MCS_Status,Status as SegmentStatus,CorrAccount,[Entity Type],[Vendor Type],PONo,Nature,[CreditTerms(Days)],DueDate,[NSD ISCHECKED],[NO SUPPORT DOC],ItemCode,ItemDescription,Qty,Unit,UnitPrice,DiscountType,Discount,[BRM ISCHECKED],[ALLOWABLE/DISALLOWABLE],[Bank Clearing],ModeOfReceipt,ReversalDate,[Bank Reconcile],[Reversal Doc Ref],ClearingStatus,[Created By],[Created On],[Modified By],[Modified On],COA_Parameter

 from
 (
 --step 5.3.1.1 starting
 select     COA.Code+'  '+ COA.Name as 'COA Name', 'Balance B/F' as DocType,'' as DocumentDescription,DATEADD(day,-1,@FromDate) as DocDate,'' as DocNo,'' as SystemRefNo,'' as  ServiceCompany,''  as EntityName,null as BaseDebit,null as BaseCredit,0.00 as BaseBalance,null as ExchangeRate,null as BaseCurrency,null as DocCurrency,null as DocDebit,null as DocCredit,0.00 as DocBalance,/*IsMultiCurrency,*/null as SegmentCategory1,null as SegmentCategory2,Case when MCS.Status=1 then 1 else 0 end MCS_Status, SM3.Status,/*COA.Name as [Corr Account],*/null as CorrAccount,null as [Entity Type],null as [Vendor Type],null as PONo,null as Nature,null as [CreditTerms(Days)],null as DueDate,[NSD ISCHECKED],NULL AS [NO SUPPORT DOC],
            NULL AS ItemCode,NULL AS ItemDescription,NULL AS Qty,NULL AS Unit,NULL AS UnitPrice,NULL AS DiscountType,NULL AS Discount,[BRM ISCHECKED],NULL AS [ALLOWABLE/DISALLOWABLE],NULL AS [Bank Clearing],NULL AS ModeOfReceipt,NULL AS ReversalDate,null as [Bank Reconcile],null as [Reversal Doc Ref],null as ClearingStatus,null as [Created By],null as [Created On],null as [Modified By],null as [Modified On],@COA_IS as COA_Parameter
 from       Bean.JournalDetail JD 
 Inner Join Bean.Journal J on J.Id=JD.JournalId
 Inner Join Bean.ChartOfAccount COA on COA.Id=JD.COAId
 Inner Join Common.Company as SC on SC.Id=JD.ServiceCompanyId
 Inner join Bean.Entity as E on E.Id=JD.EntityId
 Left join  Bean.SegmentMaster as SM1 on SM1.Id=JD.SegmentMasterid1 and J.CompanyId=SM1.CompanyId
 Left join  Bean.SegmentMaster as SM2 on SM2.Id=JD.SegmentMasterid1 and J.CompanyId=SM2.CompanyId
 Left join  Bean.MultiCurrencySetting MCS on MCS.companyId=J.CompanyId
 Left Join 
  (
	  select distinct CompanyId,status
	  from
	  (
	   select CompanyId, Status from bean.SegmentMaster where CompanyId=@CompanyId
	  ) as st1
  ) SM3 on SM3.companyid=J.CompanyId
 Left join Common.TermsOfPayment as TP on TP.Id=JD.CreditTermsId
 LEFT JOIN
  (
     Select  CompanyId,ISNULL(IsChecked,0) AS [NSD ISCHECKED]  
     From    Common.CompanyFeatures where CompanyId=@CompanyId and FeatureId=(select distinct id from Common.Feature where Name='No Supporting Documents') 
  ) AS NSD ON NSD.CompanyId=J.CompanyId
 LEFT JOIN
  (
     Select  CompanyId,ISNULL(IsChecked,0) AS [BRM ISCHECKED] 
     From    Common.CompanyFeatures where CompanyId=@CompanyId and FeatureId=(select distinct id from Common.Feature where Name='Bank Reconciliation') 
   ) AS BRM ON BRM.CompanyId=J.CompanyId

 where COA.CompanyId=@CompanyId and  JD.DocumentDetailId='00000000-0000-0000-0000-000000000000' and COA.ModuleType='Bean' and JD.IsTax<>1
 and JD.DocType not in('Credit Memo','Credit Note') and JD.DocSubType not in('CreditNote','Credit Memo')
 and COA.Name in(@COA_IS) and SC.Name in (SELECT items FROM dbo.SplitToTable(@ServiceCompany,','))
 /*and JD.DocDate between @BFFD and DATEADD(day,-1,@FromDate)*/ and J.DocumentState<>'Void'
 --order by [COA Name],DocDate

 union all
 Select     COA.Code+'  '+ COA.Name as 'COA Name', 'Balance B/F' as DocType,'' as DocumentDescription,DATEADD(day,-1,@FromDate) as DocDate,'' as DocNo,'' as SystemRefNo,'' as  ServiceCompany,''  as EntityName,null as BaseDebit,null as BaseCredit,0.00 as BaseBalance,null as ExchangeRate,null as BaseCurrency,null as DocCurrency,null as DocDebit,null as DocCredit,0.00 as DocBalance,/*IsMultiCurrency,*/null as SegmentCategory1,null as SegmentCategory2,Case when MCS.Status=1 then 1 else 0 end MCS_Status, SM3.Status,/*COA.Name as [Corr Account],*/null as CorrAccount,null as [Entity Type],null as [Vendor Type],null as PONo,null as Nature,null as [CreditTerms(Days)],null as DueDate,[NSD ISCHECKED],NULL AS [NO SUPPORT DOC],
            NULL AS ItemCode,NULL AS ItemDescription,NULL AS Qty,NULL AS Unit,NULL AS UnitPrice,NULL AS DiscountType,NULL AS Discount,[BRM ISCHECKED],NULL AS [ALLOWABLE/DISALLOWABLE],NULL AS [Bank Clearing],NULL AS ModeOfReceipt,NULL AS ReversalDate,null as [Bank Reconcile],null as [Reversal Doc Ref],null as ClearingStatus,null as [Created By],null as [Created On],null as [Modified By],null as [Modified On],@COA_IS as COA_Parameter
 from       Bean.JournalDetail JD 
 Inner Join Bean.Journal J on J.Id=JD.JournalId
 Inner Join Bean.ChartOfAccount COA on COA.Id=JD.COAId
 Inner Join Common.Company as SC on SC.Id=JD.ServiceCompanyId
 Inner join Bean.Entity as E on E.Id=JD.EntityId
 Left join  Bean.SegmentMaster as SM1 on SM1.Id=JD.SegmentMasterid1 and J.CompanyId=SM1.CompanyId
 Left join  Bean.SegmentMaster as SM2 on SM2.Id=JD.SegmentMasterid1 and J.CompanyId=SM2.CompanyId
 Left join  Bean.MultiCurrencySetting MCS on MCS.companyId=J.CompanyId 
 Left Join 
  (
	  select distinct CompanyId,status
	  from
	  (
	   select CompanyId, Status from bean.SegmentMaster where CompanyId=@CompanyId
	  ) as st1
  ) SM3 on SM3.companyid=J.CompanyId
 Left join Common.TermsOfPayment as TP on TP.Id=JD.CreditTermsId
  LEFT JOIN
  (
     select CompanyId,ISNULL(IsChecked,0) AS [NSD ISCHECKED]  
    from Common.CompanyFeatures where CompanyId=@CompanyId and FeatureId=(select distinct id from Common.Feature where Name='No Supporting Documents') 
  ) AS NSD ON NSD.CompanyId=J.CompanyId
  LEFT JOIN
  (
     select CompanyId,ISNULL(IsChecked,0) AS [BRM ISCHECKED] 
     from Common.CompanyFeatures where CompanyId=@CompanyId and FeatureId=(select distinct id from Common.Feature where Name='Bank Reconciliation') 
   ) AS BRM ON BRM.CompanyId=J.CompanyId

 where COA.CompanyId=@CompanyId and  JD.DocumentDetailId<>'00000000-0000-0000-0000-000000000000' and COA.ModuleType='Bean' and JD.IsTax<>1
 --and JD.DocType  in('Credit Memo','Credit Note') 
 and JD.DocSubType not in('CreditNote','Credit Memo')
 and COA.Name in(@COA_IS) and SC.Name in (SELECT items FROM dbo.SplitToTable(@ServiceCompany,','))
 /*and JD.DocDate between @BFFD and DATEADD(day,-1,@FromDate)*/ and J.DocumentState<>'Void'
 --order by [COA Name],DocDate
 --step 5.3.1.1 ending
 ) as DT3
 group by [COA Name],DocType,DocDate,BaseCurrency,DocCurrency,/*IsMultiCurrency,*/SegmentCategory1,SegmentCategory2,MCS_Status,Status,/*[Corr Account],*/CorrAccount,[Entity Type],[Vendor Type],PONo,Nature,[CreditTerms(Days)],DueDate,[NSD ISCHECKED],[NO SUPPORT DOC],ItemCode,ItemDescription,Qty,Unit,UnitPrice,DiscountType,Discount,[BRM ISCHECKED],[ALLOWABLE/DISALLOWABLE],[Bank Clearing],ModeOfReceipt,ReversalDate,[Bank Reconcile],[Reversal Doc Ref],ClearingStatus,[Created By],[Created On],[Modified By],[Modified On],COA_Parameter
 --step 5.3.1.2 ending
 /*******Ending of 5.3.1 ***********/
 union all
 /********* Step 5.3.2 : Getting records when documentdetailid is 0 and JD.DocType not in('Credit Memo','Credit Note') and JD.DocSubType not in('CreditNote','Credit Memo') *******************/
 
 /*********** Step 5.3.2.3 : here we join MS1 (Step 5.3.2.1) and FCA (Step 5.3.2.2) *****************/
 /*********** Taking all columns from MS1 and corresponding Account column from FCA ****************/
 select [COA Name],DocType,DocSubType,DocumentDescription,DocDate,DocNo,SystemRefNo,ServiceCompany,EntityName,BaseDebit,BaseCredit,BaseBalance,ExchangeRate,BaseCurrency,DocCurrency,DocDebit,DocCredit,DocBalance,/*IsMultiCurrency,*/SegmentCategory1,SegmentCategory2,MCS_Status,Status, FCA.CorrAccount,[Entity Type],[Vendor Type],PONo,Nature,[CreditTerms(Days)],DueDate,[NSD ISCHECKED],[NO SUPPORT DOC],ItemCode,ItemDescription,Qty,Unit,UnitPrice,DiscountType,Discount,[BRM ISCHECKED],[ALLOWABLE/DISALLOWABLE],[Bank Clearing],ModeOfReceipt,ReversalDate,[Bank Reconcile],[Reversal Doc Ref],ClearingStatus,[Created By],[Created On],[Modified By],[Modified On],COA_Parameter

 from
 (
 /********* Step 5.3.2.1 : Getting records except coresponding account column ************************************/
 Select      COA.Code+'  '+ COA.Name as 'COA Name', JD.DocType,JD.DocSubType,JD.docdescription as DocumentDescription,JD.DocDate,JD.DocNo,JD.SystemRefNo, SC.Name ServiceCompany,E.Name as EntityName,isnull(JD.BaseDebit,0) as BaseDebit,isnull(JD.BaseCredit,0) as BaseCredit,isnull((isnull(JD.BaseDebit,0)-isnull(JD.BaseCredit,0)),0) as BaseBalance,jd.ExchangeRate,jd.BaseCurrency,JD.DocCurrency,isnull(JD.DocDebit,0) as DocDebit,isnull(JD.DocCredit,0) as DocCredit ,isnull((isnull(JD.DocDebit,0)-isnull(JD.DocCredit,0)),0) as DocBalance,/*IsMultiCurrency,*/jd.SegmentCategory1,JD.SegmentCategory2,Case when MCS.Status=1 then 1 else 0 end MCS_Status, SM3.Status,/*COA.Name as [Corr Account],*/
             JD.JournalId,case when E.IsCustomer=1 then 'Customer' when E.IsVendor=1 then 'Vendor' end as [Entity Type],E.VendorType as [Vendor Type],JD.PONo,JD.Nature,TP.TOPValue as [CreditTerms(Days)],J.DueDate,NSD.[NSD ISCHECKED],CASE WHEN J.IsNoSupportingDocument=0 THEN 'NO' WHEN J.IsNoSupportingDocument=1 THEN 'YES' END AS [NO SUPPORT DOC],JD.ItemCode,JD.ItemDescription,JD.Qty,JD.Unit,JD.UnitPrice,JD.DiscountType,JD.Discount,[BRM ISCHECKED],case when IsAllowableNonAllowable=0 then 'NO' when IsAllowableNonAllowable=1 then 'YES' END AS [ALLOWABLE/DISALLOWABLE],JD.ClearingDate AS [Bank Clearing],J.ModeOfReceipt,J.ReversalDate,
		     case when J.IsBankReconcile=0 then 'NO' when J.IsBankReconcile=1 then 'YES' end as [Bank Reconcile],case when J.IsAutoReversalJournal in (0,1) then J.SystemReferenceNo  end as [Reversal Doc Ref],JD.ClearingStatus,J.UserCreated as [Created By],J.CreatedDate as [Created On],J.ModifiedBy as [Modified By],J.ModifiedDate as [Modified On],@COA_IS as COA_Parameter
 From        Bean.JournalDetail JD 
 Inner Join  Bean.Journal J on J.Id=JD.JournalId
 Inner Join  Bean.ChartOfAccount COA on COA.Id=JD.COAId
 Inner Join  Common.Company as SC on SC.Id=JD.ServiceCompanyId
 Inner join  Bean.Entity as E on E.Id=JD.EntityId
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

 where COA.CompanyId=@CompanyId and  JD.DocumentDetailId='00000000-0000-0000-0000-000000000000' and COA.ModuleType='Bean' and JD.IsTax<>1
 and JD.DocType not in('Credit Memo','Credit Note') and JD.DocSubType not in('CreditNote','Credit Memo')
 and COA.Name in(@COA_IS) and SC.Name in (SELECT items FROM dbo.SplitToTable(@ServiceCompany,','))
 and JD.DocDate between @BFFD and @ToDate and J.DocumentState<>'Void'
 --order by [COA Name],DocDate
 ) as MS1

 /*********Ending of Step 5.3.2.1 *************************/
 /*********** Step 5.3.2.2 : Getting corresponding account column. Here we joined to MS1 on  matching journalid condition ************/
 Left join-- for corraccount ** starting
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
			 where   J.CompanyId=@CompanyId and JD.DocumentDetailId<>'00000000-0000-0000-0000-000000000000' and COA.ModuleType='Bean' and J.DocumentState<>'Void' and JD.IsTax<>1 

		) as CA1
		group by JournalId--,Name
	) as CA2
	Inner join
	(
		 select  JD.JournalId,JD.COAId,COA.Name  
		 from    Bean.JournalDetail as JD
		 join    Bean.Journal as J on J.Id=JD.JournalId
		 join    Bean.ChartOfAccount as COA on COA.Id=JD.COAId
		 where   J.CompanyId=@CompanyId and JD.DocumentDetailId<>'00000000-0000-0000-0000-000000000000' and COA.ModuleType='Bean' and J.DocumentState<>'Void' and JD.IsTax<>1 

	) as CA3 on CA2.JournalId=CA3.JournalId
)as CA4 --ending
) as FCA on FCA.JournalId=MS1.JournalId
--order by [COA Name]

/*********** Ending of step 5.3.2.2 **************/
/*********** Ending of step 5.3.2.3 **************/
/*********** Ending of step 5.3.2 **************/
union all

/********* Step 5.3.3 : Getting records when documentdetailid is  not 0 and JD.DocSubType not in('CreditNote','Credit Memo') *******************/
 /*********** Step 5.3.3.3 : here we join MS1 (Step 5.3.3.1) and FCA (Step 5.3.3.2) *****************/
 /*********** Taking all columns from MS1 and corresponding Account column from FCA ****************/

 select [COA Name],DocType,DocSubType,DocumentDescription,DocDate,DocNo,SystemRefNo,ServiceCompany,EntityName,BaseDebit,BaseCredit,BaseBalance,ExchangeRate,BaseCurrency,DocCurrency,DocDebit,DocCredit,DocBalance,/*IsMultiCurrency,*/SegmentCategory1,SegmentCategory2,MCS_Status,Status, FCA.CorrAccount,[Entity Type],[Vendor Type],PONo,Nature,[CreditTerms(Days)],DueDate,[NSD ISCHECKED],[NO SUPPORT DOC],ItemCode,ItemDescription,Qty,Unit,UnitPrice,DiscountType,Discount,[BRM ISCHECKED],[ALLOWABLE/DISALLOWABLE],[Bank Clearing],ModeOfReceipt,ReversalDate,[Bank Reconcile],[Reversal Doc Ref],ClearingStatus,[Created By],[Created On],[Modified By],[Modified On],COA_Parameter

 from
 (
  /********* Step 5.3.3.1 : Getting records except coresponding account column ************************************/
 select       COA.Code+'  '+ COA.Name as 'COA Name', JD.DocType,JD.DocSubType,JD.docdescription as DocumentDescription,JD.DocDate,JD.DocNo,JD.SystemRefNo, SC.Name ServiceCompany,E.Name as EntityName,isnull(JD.BaseDebit,0) as BaseDebit,isnull(JD.BaseCredit,0) as BaseCredit,isnull((isnull(JD.BaseDebit,0)-isnull(JD.BaseCredit,0)),0) as BaseBalance,jd.ExchangeRate,jd.BaseCurrency,JD.DocCurrency,isnull(JD.DocDebit,0) as DocDebit,isnull(JD.DocCredit,0) as DocCredit,isnull((isnull(JD.DocDebit,0)-isnull(JD.DocCredit,0)),0) as DocBalance,IsMultiCurrency,jd.SegmentCategory1,JD.SegmentCategory2,Case when MCS.Status=1 then 1 else 0 end MCS_Status, SM3.Status,/*COA.Name as [Corr Account],*/
              JD.JournalId,case when E.IsCustomer=1 then 'Customer' when E.IsVendor=1 then 'Vendor' end as [Entity Type],E.VendorType as [Vendor Type],JD.PONo,JD.Nature,TP.TOPValue as [CreditTerms(Days)],J.DueDate,NSD.[NSD ISCHECKED],CASE WHEN J.IsNoSupportingDocument=0 THEN 'NO' WHEN J.IsNoSupportingDocument=1 THEN 'YES' END AS [NO SUPPORT DOC],JD.ItemCode,JD.ItemDescription,JD.Qty,JD.Unit,JD.UnitPrice,JD.DiscountType,JD.Discount,[BRM ISCHECKED],case when IsAllowableNonAllowable=0 then 'NO' when IsAllowableNonAllowable=1 then 'YES' END AS [ALLOWABLE/DISALLOWABLE],JD.ClearingDate AS [Bank Clearing],J.ModeOfReceipt,J.ReversalDate,
		      case when J.IsBankReconcile=0 then 'NO' when J.IsBankReconcile=1 then 'YES' end as [Bank Reconcile],case when J.IsAutoReversalJournal in (0,1) then J.SystemReferenceNo  end as [Reversal Doc Ref],JD.ClearingStatus,J.UserCreated as [Created By],J.CreatedDate as [Created On],J.ModifiedBy as [Modified By],J.ModifiedDate as [Modified On],@COA_IS as COA_Parameter
 From         Bean.JournalDetail JD 
 Inner Join   Bean.Journal J on J.Id=JD.JournalId
 Inner Join   Bean.ChartOfAccount COA on COA.Id=JD.COAId
 Inner Join   Common.Company as SC on SC.Id=JD.ServiceCompanyId
 Inner join   Bean.Entity as E on E.Id=JD.EntityId
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

 where COA.CompanyId=@CompanyId and  JD.DocumentDetailId<>'00000000-0000-0000-0000-000000000000' and COA.ModuleType='Bean' and JD.IsTax<>1
-- and JD.DocType  in('Credit Memo','Credit Note') 
and JD.DocSubType not in('CreditNote','Credit Memo')
 and COA.Name in(@COA_IS) and SC.Name in (SELECT items FROM dbo.SplitToTable(@ServiceCompany,','))
 and JD.DocDate between @BFFD and @ToDate and J.DocumentState<>'Void'
 --order by [COA Name],DocDate
 ) as MS1

 /*********Ending of Step 5.3.3.1 *************************/
 /*********** Step 5.3.3.2 : Getting corresponding account column. Here we joined to MS1 on  matching journalid condition ************/
 Left join-- for corraccount ** starting
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
			Where    J.CompanyId=@CompanyId and JD.DocumentDetailId='00000000-0000-0000-0000-000000000000' and COA.ModuleType='Bean' and J.DocumentState<>'Void' and JD.IsTax<>1

		) as CA1
		group by JournalId--,Name
	) as CA2
	Inner join
	(
		 select JD.JournalId,JD.COAId,COA.Name  
		 from   Bean.JournalDetail as JD
		join    Bean.Journal as J on J.Id=JD.JournalId
		join    Bean.ChartOfAccount as COA on COA.Id=JD.COAId
		where   J.CompanyId=@CompanyId and JD.DocumentDetailId='00000000-0000-0000-0000-000000000000' and COA.ModuleType='Bean' and J.DocumentState<>'Void' and JD.IsTax<>1

	) as CA3 on CA2.JournalId=CA3.JournalId
)as CA4 --ending
) as FCA on FCA.JournalId=MS1.JournalId
 order by [COA Name],DocDate
/*********** Ending of step 5.3.3.2 **************/
/*********** Ending of step 5.3.3.3 **************/
/*********** Ending of step 5.3.3 **************/
end

/******* End of step 5.3 (i.e other than @BFFD<@FromDate condition ending) ***************/

Fetch next from IncomeSheet_cursor into @COA_IS
end
Close IncomeSheet_cursor
Deallocate IncomeSheet_cursor

                                  /****** step 5 ending :i.e Data for Income Statement coa's ending **********/
Select * from @GLReport order by COA_Parameter ,DocDate

End
GO
