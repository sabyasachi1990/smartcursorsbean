USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[BC_SOA_Template]    Script Date: 16-12-2024 9.20.10 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--Exec [dbo].[BC_SOA_Template] 244,'2021-03-30','e65eb019-0982-442c-b438-e1936e755ff2','mphasis@smartcursors.org'


CREATE PROCEDURE [dbo].[BC_SOA_Template]

@Tenantid bigint,
@AsOf DateTime,
@EntitiId Uniqueidentifier,
@username nvarchar(200)
AS
Begin

--//To Get the permission service Entity the user is having
	Declare @serviceEntityIds nvarchar(1000)

	select @serviceEntityIds=COALESCE(@serviceEntityIds + ',', '') + CAST(CUD.ServiceEntityId AS VARCHAR(100)) from Common.Company(nolock) Comp 
	Join Common.CompanyUser(nolock) CU on Comp.ParentId=cu.CompanyId 
	Join Common.CompanyUserDetail(nolock) CUD on CUD.CompanyUserId = CU.Id and CUD.ServiceEntityId=Comp.Id
	Where Comp.ParentId=@Tenantid and cu.Username=@userName

Declare  @Transaction Table (DocumentId uniqueidentifier)
Insert INTO @Transaction 

select Distinct DocumentId from Bean.DocumentHistory(NoLock) where CompanyId=@Tenantid AND DocType='Debt Provision' 

Declare  @Transaction_DP Table (DocumentId uniqueidentifier)
Insert INTO @Transaction_DP 

Select Distinct DocumentId from Bean.DocumentHistory(NoLock) Where CompanyId=@Tenantid And DocType='Debt Provision' And DocSubType='Allocation'


Set @AsOf = DATEADD(day, DATEDIFF(day, 0, @AsOf), '23:59:59') 

BEGIN
	Select EntityId,  DocDate, DocNo, Currency, DocType,DocumentState,DocumentId,CAST( ISNULL(BaseBalanceAmount,0)as decimal(18,2)) BaseBalanceAmount,CAST( ISNULL(DocBalanceAmount,0)as decimal(18,2)) DocBalanceAmount,
        ServiceCompanyId,DocSubType
        ,[GrandTotal],[BaseGrandTotal]
    From
    (
Select de.Id 'EntityId',JD.DocDate,j.DocNo,JD.DocCurrency AS Currency,j.DocType,j.DocumentState,JD.DocumentId,
             Case When J.DocType IN ('Credit Note') Then 
            SUM(ISNULL(K.BaseAppliedAmount,0))*(-1) Else SUM(ISNULL(K.BaseAppliedAmount,0)) End  'BaseBalanceAmount', Case When JD.DocType IN ('Credit Note') Then SUM(ISNULL(K.DocAppliedAmount,0))*(-1) Else SUM(ISNULL(K.DocAppliedAmount,0)) End DocBalanceAmount,
            Jd.ServiceCompanyId,Jd.DocSubType--,J.DueDate
            ,ISNULL(Jd.DocDebit,JD.DocCredit) as 'GrandTotal',ISNULL(Jd.BaseDebit,JD.BaseCredit) as 'BaseGrandTotal'

 

        From Bean.Journal(NoLock) J
        Join Bean.JournalDetail(NoLock) JD on  J.Id=JD.JournalId 
        Join Bean.Entity(NoLock) de on J.EntityId=de.Id
        join Common.Company(NoLock) com on J.ServiceCompanyId=com.Id
        Inner Join
   (
     SELECT 
     Companyid,DocAppliedAmount,BaseAppliedAmount,TransactionId,
     DocumentId,DocState,PostingDate
     FROM Bean.DocumentHistory(NoLock)
     where  companyid =@Tenantid AND DocState is not null AND (AgingState <>'Deleted' OR AgingState IS NULL) 
     AND PostingDate <= @AsOf 
     And  TransactionId NOT IN (select DocumentId from @Transaction)
   ) as K on K.DocumentId = J.DocumentId 
   
       Where J.CompanyId=@Tenantid  AND K.PostingDate  <= @AsOf 
         AND (JD.ClearingStatus <> ('Cleared') or JD.ClearingStatus IS NULL)
         AND K.DocState in ('Partial Applied','Fully Applied','Not Applied','Not Paid','Partial Paid','Fully Paid')
         AND  J.DocumentState Not in ('Void')
         And JD.DocType in ('Invoice','Debit Note','Credit Note') 
         AND JD.DocumentDetailId='00000000-0000-0000-0000-000000000000'
         AND JD.EntityId=@EntitiId
		 AND Jd.ServiceCompanyId in (Select items From dbo.SplitToTable (@serviceEntityIds,','))
    
        Group By  de.Id,JD.DocDate,j.DocNo,JD.DocCurrency,J.DueDate, JD.DocType,DocumentState,JD.DocSubType, j.DocNo, JD.BaseCurrency, j.DocType, JD.DocumentId,J.DocType,Jd.ServiceCompanyId,JD.DocSubType--,J.DueDate--,CNA.InvoiceId
        ,Jd.DocDebit,JD.DocCredit,JD.BaseDebit,JD.BaseCredit

		Union All

        Select de.Id 'EntityId'
        , I.DocDate,I.DocNo,I.DocCurrency AS Currency,I.DocType,DocumentState,I.Id As DocumentId,Case When I.DocType IN ('Credit Note') Then 
            Sum(ISNULL(K.BaseAppliedAmount,0))*(-1) Else SUM(ISNULL(K.BaseAppliedAmount,0)) End  'BalanceAmount',Case When I.DocType IN ('Credit Note') Then 
            SUM(ISNULL(K.DocAppliedAmount,0))*(-1) Else SUM(ISNULL(K.DocAppliedAmount,0)) End DocBalanceAmount, 
            I.ServiceCompanyId,I.DocSubType,I.GrandTotal 'Grand Total',I.BaseGrandTotal
        From Bean.Invoice(NoLock) I
        Inner Join Bean.InvoiceDetail(NoLock) ID ON ID.InvoiceId=I.Id
        Join Bean.Entity(NoLock) de on I.EntityId=de.Id
        join Common.Company(NoLock) com on I.ServiceCompanyId=com.Id
        
        Inner Join
   (
     SELECT 
     Companyid,DocAppliedAmount,BaseAppliedAmount,TransactionId,
     DocumentId,DocState,PostingDate 
     FROM Bean.DocumentHistory(NoLock)
     where  companyid In(@Tenantid) AND DocState is not null AND (AgingState <>'Deleted' OR AgingState IS NULL) 
     AND PostingDate <= @AsOf 
     And  TransactionId NOT IN (select DocumentId from @Transaction)
     
   ) as K on K.DocumentId = I.Id 
   
        Where I.CompanyId=@Tenantid  
        AND K.PostingDate <= @AsOf 
         AND K.DocState in ('Partial Applied','Fully Applied','Not Applied','Not Paid','Partial Paid','Fully Paid')
          AND I.DocumentState NOT in ('Void') And I.DocType in ('Invoice','Credit Note') AND I.DocSubType IN ('Opening Bal') AND I.IsOBInvoice = 1 AND EntityId=@EntitiId AND I.ServiceCompanyId in (Select items From dbo.SplitToTable (@serviceEntityIds,','))
        
        Group By  de.Id,  I.DocDate,I.DocNo,I.DocCurrency,I.DueDate, I.DocType,i.DocumentState, I.DocNo,I.ExCurrency,
         I.DocType,I.Id,I.DocType,I.ServiceCompanyId,I.DocSubType,I.GrandTotal,I.BaseGrandTotal
        ) AS a
    WHERE ISNULL(BaseBalanceAmount,0) <>0 AND ISNULL(DocBalanceAmount,0) <>0  AND EntityId=@EntitiId
    Group By EntityId,DocDate,DocNo,Currency,DocType,DocumentState,DocumentId,BaseBalanceAmount,DocBalanceAmount,ServiceCompanyId,DocSubType,[GrandTotal],[BaseGrandTotal]
    ORDER BY DocDate
   END
END
GO
