USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[Bean_HTMLJournalListing]    Script Date: 16-12-2024 9.20.10 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

--exec [dbo].[Bean_HTMLJournalListing] @CompanyId=571,@ServiceEntity=N'BC+WF,Comp1',@FromDate='2019-01-01 00:00:00',@ToDate='2019-06-14 00:00:00',@DocType=NULL,@SubType=NULL,@DocNumber=NULL,@QueryOptions=NULL
--Select * from Common.Company Where ParentId=1
--Declare @CompanyId INT=1,@ServiceEntity Varchar(MAX)='6',@FromDate DateTime='1900-01-01 00:00:00',@ToDate DateTime='2019-09-21 00:00:00',
--@DocType Varchar(MAX)=NULL,@SubType Varchar(MAX)=NULL,@DocNumber Varchar(MAX)=NULL,@QueryOptions Varchar(MAX)=NULL
  --Select * From Common.Company Where ParentID=1
CREATE Procedure [dbo].[Bean_HTMLJournalListing]  
 @CompanyId INT,  
 @ServiceEntity Varchar(MAX),  
 @FromDate DateTime,  
 @ToDate DateTime,  
 @DocType Varchar(MAX),  
 @SubType Varchar(MAX),  
 @DocNumber nvarchar(MAX),  
 @QueryOptions Varchar(MAX)  
AS  
Begin  
 
Declare @SortField Varchar(100)  
Declare @SortField2 Varchar(100)  
Declare @SortField3 Varchar(100) 
Declare @SortField4 Varchar(100)
Declare @SortField5 Varchar(100) 
--Declare @SortField6 Varchar(100)

Declare @SQL varchar(MAX)    
Declare @Perameter varchar(MAX)  
Declare @PerameterDocType varchar(MAX)  
Declare @PerameterSubType varchar(MAX)  
Declare @PerameterServiceEntity varchar(MAX) 

SET @SortField = 'Date'    
SET @SortField2 = 'A.DocNo'  
SET @SortField3 = 'A.Type' 
SET @SortField4 = 'A.SystemReferenceNo' 
SET @SortField5 = 'A.RecOrder'
--SET @SortField6 = 'A.CreatedDate' 


  
SET @Perameter=  'AND J.DocNo in (select items from dbo.SplitToTable('''+@DocNumber+''','',''))'  
  
SET @Perameter = Case When @DocNumber IS NULL Then '' Else @Perameter END   

SET @PerameterDocType=  'AND JD.DocType in (select items from dbo.SplitToTable('''+@DocType+''','',''))'  
  
SET @PerameterDocType = Case When @DocType IS NULL Then '' Else @PerameterDocType END

SET @PerameterSubType=  'AND JD.DocSubType in (select items from dbo.SplitToTable('''+@SubType+''','',''))'  
  
SET @PerameterSubType = Case When @SubType IS NULL Then '' Else @PerameterSubType END

SET @PerameterServiceEntity=  'AND SC.Id in (select items from dbo.SplitToTable('''+@ServiceEntity+''','',''))'  
  
SET @PerameterServiceEntity = Case When @ServiceEntity IS NULL Then '' Else @PerameterServiceEntity END
  
  
  Set @SQL = '
  
  Select * From (
  

    Select  Jd.DocType Type,JD.DocSubType AS SuvType,SC.ShortName AS [Svc Entity],   
                      JD.PostingDate AS Date,J.DocNo,E.Name As Entity,  
                      JD.AccountDescription As Description,COA.Name AS Account,JD.DocCurrency As Curr,  
                      JD.DocDebit AS DocDebit,JD.DocCredit AS DocCredit,JD.BaseDebit As Debit,
					  JD.BaseCredit AS Credit ,J.Id AS JournalId ,Case When (J.DocType=''Credit Note'' And J.DocSubType=''Application'') Then CNA.InvoiceId 
				           When (J.DocType=''Credit Memo'' And J.DocSubType=''Application'') Then CMA.CreditMemoId
						   When (J.DocType=''Debt Provision'' And J.DocSubType=''Allocation'') Then DBA.InvoiceId Else J.DocumentId End as DocumentId,JD.ServiceCompanyId,JD.RecOrder,J.SystemReferenceNo
  
					 From Bean.JournalDetail JD (NOLOCK)
					 Inner Join Bean.Journal J (NOLOCK) ON J.Id=JD.JournalId  
					 Left Join Bean.Entity E (NOLOCK) ON E.Id=JD.EntityId  
					 Inner Join Bean.ChartOfAccount COA (NOLOCK) ON COA.Id=JD.COAId  
					 Inner join Common.Company As SC (NOLOCK) on SC.Id=J.ServiceCompanyId  
                     Left Join Bean.TaxCode T (NOLOCK) ON T.Id=JD.TaxId
					 Left Join Bean.CreditNoteApplication CNA (NOLOCK) On CNA.Id = J.DocumentId
	                 Left Join Bean.CreditMemoApplication CMA (NOLOCK) On CMA.Id = J.DocumentId
					 Left Join Bean.DoubtfulDebtAllocation DBA (NOLOCK) on DBA.Id=J.DocumentId
					 Where COA.CompanyId='+CONVERT(VARCHAR,@CompanyId)+'   AND (JD.BaseDebit <>0 Or JD.BaseCredit <>0)  
					 AND JD.PostingDate Between '''+CONVERT(VARCHAR(19), @FromDate, 120)+''' And '''+CONVERT(VARCHAR(19), @ToDate, 120)+'''  
					 '+@PerameterServiceEntity+'
					 AND J.DocumentState NOT IN (''Void'',''Cancelled'',''Parked'',''Reset'',''Recurring'')  AND (JD.IsTax Is NULL OR JD.IsTax=0)
					 '+@PerameterDocType+'
					 '+@PerameterSubType+'
					 '+@Perameter+'  
					

  Union All

                    Select  B.Type,B. SuvType,B.[Svc Entity],   
                      B.Date,B.DocNo,B.Entity,  
                      B.Description,B.Account,B.Curr,  
                      B.DocDebit AS DocDebit,B.DocCredit AS DocCredit,B.Debit As Debit,
					  Credit AS  Credit,B.JournalId ,B.DocumentId,B.ServiceCompanyId,B.RecOrder,B.SystemReferenceNo from 
  (
  Select  Jd.DocType Type,JD.DocSubType AS SuvType,SC.ShortName AS [Svc Entity],   
                      JD.PostingDate AS Date,J.DocNo,E.Name As Entity,  
                      JD.AccountDescription As Description,COA.Name AS Account,JD.DocCurrency As Curr,  
                      SUM(JD.DocDebit) AS DocDebit,NULL AS DocCredit,SUM(JD.BaseDebit) As Debit,
					  NULL AS Credit ,J.Id AS JournalId ,J.DocumentId,JD.ServiceCompanyId,100000000000000 AS RecOrder,J.SystemReferenceNo
  
					 From Bean.JournalDetail JD (NOLOCK) 
					 Inner Join Bean.Journal J (NOLOCK) ON J.Id=JD.JournalId  
					 Left Join Bean.Entity E (NOLOCK) ON E.Id=JD.EntityId  
					 Inner Join Bean.ChartOfAccount COA (NOLOCK) ON COA.Id=JD.COAId  
					 Inner join Common.Company As SC (NOLOCK) on SC.Id=J.ServiceCompanyId  
                     Left Join Bean.TaxCode T (NOLOCK) ON T.Id=JD.TaxId
					 Where COA.CompanyId='+CONVERT(VARCHAR,@CompanyId)+'   AND (JD.BaseDebit <>0 Or JD.BaseCredit <>0)  
					 AND JD.PostingDate Between '''+CONVERT(VARCHAR(19), @FromDate, 120)+''' And '''+CONVERT(VARCHAR(19), @ToDate, 120)+'''  
					 '+@PerameterServiceEntity+'
					 AND J.DocumentState NOT IN (''Void'',''Cancelled'',''Parked'',''Reset'',''Recurring'')  AND JD.IsTax=1
					 '+@PerameterDocType+'
					 '+@PerameterSubType+'
					 '+@Perameter+'  
					 Group By Jd.DocType ,JD.DocSubType,SC.ShortName ,   
                      JD.PostingDate ,J.DocNo,E.Name ,  
                      JD.AccountDescription ,COA.Name,JD.DocCurrency,  
                      J.Id ,J.DocumentId,JD.ServiceCompanyId,J.SystemReferenceNo
	  Union All

  Select  Jd.DocType Type,JD.DocSubType AS SuvType,SC.ShortName AS [Svc Entity],   
                      JD.PostingDate AS Date,J.DocNo,E.Name As Entity,  
                      JD.AccountDescription As Description,COA.Name AS Account,JD.DocCurrency As Curr,  
                      NULL AS DocDebit,SUM(JD.DocCredit) AS DocCredit,NULL As Debit,
					  SUM(JD.BaseCredit) AS Credit ,J.Id AS JournalId ,J.DocumentId,JD.ServiceCompanyId,100000000000000 AS RecOrder,J.SystemReferenceNo
  
					 From Bean.JournalDetail JD (NOLOCK)
					 Inner Join Bean.Journal J (NOLOCK) ON J.Id=JD.JournalId  
					 Left Join Bean.Entity E (NOLOCK) ON E.Id=JD.EntityId  
					 Inner Join Bean.ChartOfAccount COA (NOLOCK) ON COA.Id=JD.COAId  
					 Inner join Common.Company As SC (NOLOCK) on SC.Id=J.ServiceCompanyId  
                     Left Join Bean.TaxCode T (NOLOCK) ON T.Id=JD.TaxId
					 Where COA.CompanyId='+CONVERT(VARCHAR,@CompanyId)+'   AND (JD.BaseDebit <>0 Or JD.BaseCredit <>0)  
					 AND JD.PostingDate Between '''+CONVERT(VARCHAR(19), @FromDate, 120)+''' And '''+CONVERT(VARCHAR(19), @ToDate, 120)+'''  
					 '+@PerameterServiceEntity+'
					 AND J.DocumentState NOT IN (''Void'',''Cancelled'',''Parked'',''Reset'',''Recurring'')  AND JD.IsTax=1
					 '+@PerameterDocType+'
					 '+@PerameterSubType+'
					 '+@Perameter+'  
					 Group By Jd.DocType ,JD.DocSubType,SC.ShortName ,   
                      JD.PostingDate ,J.DocNo,E.Name ,  
                      JD.AccountDescription ,COA.Name,JD.DocCurrency,  
                      J.Id ,J.DocumentId,JD.ServiceCompanyId,J.SystemReferenceNo

					  ) AS B
					  Where (Debit IS NOT NULL Or Credit IS NOT NULL)  

					  ) AS A
					 
					 Order By '+@SortField+','+@SortField2+','+@SortField3+','+@SortField4+','+@SortField5+''  
  
   --select @SQL  
   Execute (@SQL)  
END  
 

 
  
GO
