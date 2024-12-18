USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[BC_SOA_Template12]    Script Date: 16-12-2024 9.20.10 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

--Exec [dbo].[BC_SOA_Template] 1,'2020-06-12','2D1D7F55-0335-4802-9513-6BFDEEBD1844'


Create     PROCEDURE [dbo].[BC_SOA_Template12]

@Tenantid bigint,
@AsOf DateTime,
@EntitiId Uniqueidentifier	

AS
Begin

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
        ,[GrandTotal]
    From
    (
Select de.Id 'EntityId',JD.DocDate,j.DocNo,JD.DocCurrency AS Currency,j.DocType,j.DocumentState,JD.DocumentId,
             Case When J.DocType IN ('Credit Note') Then 
            SUM(ISNULL(K.BaseAppliedAmount,0))*(-1) Else SUM(ISNULL(K.BaseAppliedAmount,0)) End  'BaseBalanceAmount', Case When JD.DocType IN ('Credit Note') Then SUM(ISNULL(K.DocAppliedAmount,0))*(-1) Else SUM(ISNULL(K.DocAppliedAmount,0)) End DocBalanceAmount,
            Jd.ServiceCompanyId,Jd.DocSubType--,J.DueDate
            ,ISNULL(Jd.DocDebit,JD.DocCredit) as 'GrandTotal'

 

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

    
        Group By  de.Id,JD.DocDate,j.DocNo,JD.DocCurrency,J.DueDate, JD.DocType,DocumentState,JD.DocSubType, j.DocNo, JD.BaseCurrency, j.DocType, JD.DocumentId,J.DocType,Jd.ServiceCompanyId,JD.DocSubType--,J.DueDate--,CNA.InvoiceId
        ,Jd.DocDebit,JD.DocCredit

		Union All

        Select de.Id 'EntityId'
        , I.DocDate,I.DocNo,I.DocCurrency AS Currency,I.DocType,DocumentState,I.Id As DocumentId,Case When I.DocType IN ('Credit Note') Then 
            Sum(ISNULL(K.BaseAppliedAmount,0))*(-1) Else SUM(ISNULL(K.BaseAppliedAmount,0)) End  'BalanceAmount',Case When I.DocType IN ('Credit Note') Then 
            SUM(ISNULL(K.DocAppliedAmount,0))*(-1) Else SUM(ISNULL(K.DocAppliedAmount,0)) End DocBalanceAmount, 
            I.ServiceCompanyId,I.DocSubType,I.GrandTotal 'Grand Total'
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
          AND I.DocumentState NOT in ('Void') And I.DocType in ('Invoice','Credit Note') AND I.DocSubType IN ('Opening Bal') AND I.IsOBInvoice = 1 AND EntityId=@EntitiId
        
        Group By  de.Id,  I.DocDate,I.DocNo,I.DocCurrency,I.DueDate, I.DocType,i.DocumentState, I.DocNo,I.ExCurrency,
         I.DocType,I.Id,I.DocType,I.ServiceCompanyId,I.DocSubType,I.GrandTotal
        ) AS a
    WHERE ISNULL(BaseBalanceAmount,0) <>0 AND ISNULL(DocBalanceAmount,0) <>0  AND EntityId=@EntitiId
    Group By EntityId,DocDate,DocNo,Currency,DocType,DocumentState,DocumentId,BaseBalanceAmount,DocBalanceAmount,ServiceCompanyId,DocSubType,[GrandTotal]
    ORDER BY DocDate
   END
END
GO
