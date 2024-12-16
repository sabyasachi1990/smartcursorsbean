USE SmartCursorSTG
GO

IF EXISTS ( Select 1 from sys.objects where name='WorkflowBeanSync_proc'AND type='P')
BEGIN
 Drop Proc WorkflowBeanSync_proc
END
GO
          
CREATE PROCEDURE [dbo].[WorkflowBeanSync_proc] (                
@Caseid UNIQUEIDENTIFIER,      
@ClientId UNIQUEIDENTIFIER,      
@InvoiceId UNIQUEIDENTIFIER,      
@CompanyId  INT                
 )                
AS                
BEGIN   
Declare @CreditTermId BIGINT      
Declare @EntityId UNIQUEIDENTIFIER      
Declare @CustNature NVARCHAR(50)      
Declare @DueDate DATETIME      
DEclare @Pono NVARCHAR(50)      
Declare @ServiceId BIGINT      
Declare @BeanInvId UNIQUEIDENTIFIER      
Declare @ItemId UNIQUEIDENTIFIER      
Declare @ItemCode NVARCHAR(400)      
Declare @Description NVARCHAR(2000)      
Declare @COAId BIGINT  
Declare @TaxRate FLOAT      
Declare @Taxcode NVARCHAR(100)  
Declare @MultiCurrency NVARCHAR(50)      
Declare @NoSupportingDocuments NVARCHAR(50)      
Declare @IsAllowableDisallowableActivated NVARCHAR(50)      
Declare @IsAllowableNonAllowable NVARCHAR(50)  
Declare @ScopeOfWork NVARCHAR(MAX)  
Declare @ScopeOfWork1 NVARCHAR(MAX)  
 BEGIN TRY                
  BEGIN TRAN                
 IF NOT  Exists  (Select Id from Bean.Invoice where CompanyId=@CompanyId and DocumentId=@InvoiceId and DocumentId is not null )      
 BEGIN  
   
 Select  f.Name into #FeatureSettings FROM Common.Feature f (nolock)     
       Inner join Common.CompanyFeatures cf (nolock) on f.Id=cf.FeatureId WHERE cf.CompanyId=@CompanyId and IsChecked=1 and f.Status=1  and Name in('Multi-Currency','No Supporting Documents','Allowable/Non Allowable','IsAllowableNonAllowable') 

 SET @ServiceId=(SELECT g.ServiceId    
   FROM WorkFlow.Invoice I (nolock)     
   Inner join WorkFlow.CaseGroup G (nolock) ON G.ID=I.CaseId    
    WHERE I.CompanyId=@CompanyId and g.ClientId=@ClientId and I.CaseId=@CaseId and I.ID=@InvoiceId)
  
 SET @MultiCurrency=ISNULL((select Case when Name='Multi-Currency' Then 1 else 0 end 'Multi-Currency' FROM #FeatureSettings where Name='Multi-Currency'),0)               
             
    SET @NoSupportingDocuments=ISNULL((select Case when Name='No Supporting Documents' Then 1 else 0 end 'No Supporting Documents' FROM #FeatureSettings where Name='No Supporting Documents'),0)      
      
    SET @IsAllowableDisallowableActivated=ISNULL((select Case when Name='Allowable/Non Allowable' Then 1 else 0 end 'Allowable/Non Allowable' FROM #FeatureSettings where Name='Allowable/Non Allowable'),0)       
      
    SET @IsAllowableNonAllowable=ISNULL((select Case when Name='IsAllowableNonAllowable' Then 1 else 0 end 'IsAllowableNonAllowable' FROM #FeatureSettings where Name='IsAllowableNonAllowable'),0)      
      
 SET @ScopeOfWork =(Select  [dbo].[udf_StripHTML_To_PlainText](ScopeOfWork)      
      from WorkFlow.CaseGroup where Id=@Caseid)  
  
    SET @ScopeOfWork1 =(select ISNULL(CAST( REPLACE(REPLACE(REPLACE(REPLACE(@ScopeOfWork,'{{FromDate}}',CONVERT(varchar,cg.fromdate,103)),'{{ToDate}}',CONVERT(varchar,cg.todate,103)),'{{FEE}}',cg.fee),'{{YA}}',Year(cg.todate)+1) AS varchar(MAX)),@ScopeOfWork)       
  from WorkFlow.CaseGroup cg (nolock) where id=@Caseid)  
  
 SET @DueDate=(Select DATEADD(DAY,ISNULL(tp.TOPValue,0),i.InvDate) as Duedate from WorkFlow.CaseGroup c (nolock)     
      inner join Bean.Entity E (nolock) on c.ClientId=E.SyncClientId      
      inner join WorkFlow.Invoice i (nolock) on i.CaseId=c.Id      
      inner join WorkFlow.Client wc (nolock) on wc.Id=c.ClientId      
      inner join Common.TermsOfPayment tp (nolock) on wc.TermsOfPaymentId=tp.Id      
      where i.Id=@InvoiceId and i.CompanyId=@Companyid and c.Id=@Caseid)  
  
 SET @Pono=(Select cg.CaseNumber + '/' + Left(InvType,1)from WorkFlow.CaseGroup cg (nolock) inner join WorkFlow.Invoice i (nolock) on i.CaseId=cg.Id  where i.CompanyId=@Companyid and cg.Id=@Caseid and  i.Id=@InvoiceId)
 SET @BeanInvId=NEWID();
   
 Select E.Id,E.CustTOPId,E.CustNature into #BeanEntityData from WorkFlow.CaseGroup c (nolock) 
 inner join Bean.Entity E (nolock) on c.ClientId=E.SyncClientId where  E.CompanyId=@Companyid and C.Id=@Caseid  
 IF Exists (Select 1 from #BeanEntityData)  
  Begin  
   SET @EntityId=(Select Id from #BeanEntityData)  
   SET @CreditTermId=(Select CustTOPId from #BeanEntityData)  
   SET @CustNature=(Select CustNature from #BeanEntityData)  
  End
  ----Insert into Bean.Invoice table
  INSERT INTO  Bean.Invoice( Id,CompanyId,DocSubType,DocDate,DueDate,DocNo,PONo,NoSupportingDocs,SegmentCategory1,SegmentCategory2,IsRepeatingInvoice,RepEveryPeriodNo,RepEveryPeriod,RepEndDate    
     ,EntityType,EntityId,CreditTermsId,Nature,DocCurrency,ExchangeRate,ExCurrency,ExDurationFrom,ExDurationTo,GSTExchangeRate,GSTExCurrency,GSTExDurationFrom,GSTExDurationTo    
     ,DocumentState,BalanceAmount,GSTTotalAmount,GrandTotal,IsGstSettings,IsSegmentReporting,UserCreated,CreatedDate,ModifiedBy,ModifiedDate,Version,Status,ParentInvoiceID,InvoiceNumber,    
     ServiceCompanyId,DocType,ReverseDate,ReverseIsSupportingDocument,ReverseRemarks,AllocatedAmount,SegmentMasterid1,SegmentMasterid2,SegmentDetailid1,SegmentDetailid2,IsBaseCurrencyRateChanged,    
     IsGSTCurrencyRateChanged,IsGSTApplied,ItemTotal,ExtensionType,IsWorkFlowInvoice,CursorType,DocumentId,InternalState,RecurInvId,IsPost,Counter,NextDue,LastPostedDate,IsOBInvoice,OpeningBalanceId,    
     SyncWFInvoiceId,SyncWFInvoiceStatus,SyncWFInvoiceDate,SyncWFInvoiceRemarks,IsMultiCurrency,IsAllowableNonAllowable,IsNoSupportingDocument,IsAllowableDisallowableActivated ,    
     DocDescription,Remarks)    
    
    SELECT @BeanInvId AS Invoiceid,i.CompanyId,InvType AS DocSubType,Convert(date,InvDate)InvDate,@DueDate AS DueDate,i.Number AS DocNo,@Pono AS PONo,Null AS NoSupportingDocs,NUll AS SegmentCategory1,NUll AS SegmentCategory2,0 AS IsRepeatingInvoice,NUll AS RepEveryPeriodNo,NUll AS RepEveryPeriod,NUll AS RepEndDate,'Customer' AS EntityType,@EntityId AS EntityId,@CreditTermId AS CreditTermsId,    
    @CustNature AS Nature,i.Currency AS DocCurrency,i.DocToBaseExhRate as ExchangeRate,i.BaseCurrency AS ExCurrency,NUll AS ExDurationFrom,NUll AS ExDurationTo,DocToJudExhRate AS GSTExchangeRate,C.GstCurrency AS GSTExCurrency,NUll AS GSTExDurationFrom,NUll AS GSTExDurationTo,i.State AS DocumentState,TotalFee AS BalanceAmount,NUll AS GSTTotalAmount,TotalFee AS GrandTotal,IsGst AS IsGstSettings,NUll AS IsSegmentReporting,i.ModifiedBy AS UserCreated,i.ModifiedDate AS CreatedDate,NUll AS ModifiedBy,NUll AS ModifiedDate,NUll AS Version,1 AS Status,null AS ParentInvoiceID,    
    Number AS InvoiceNumber,(Select ServiceCompanyId from WorkFlow.CaseGroup where CompanyId=@Companyid and Id=@Caseid),'Invoice' AS DocType,NUll AS ReverseDate,NUll AS ReverseIsSupportingDocument,    
    NUll AS ReverseRemarks,NUll AS AllocatedAmount,NUll AS SegmentMasterid1,NUll AS SegmentMasterid2,NUll AS SegmentDetailid1,NUll AS SegmentDetailid2,i.IsDocToBaseExhRateChanged AS IsBaseCurrencyRateChanged,   i.IsDocToJudExhRateChanged AS IsGSTCurrencyRateChanged,NUll AS IsGSTApplied,NUll AS ItemTotal,NUll AS ExtensionType,1 AS IsWorkFlowInvoice,NUll AS CursorType,i.Id AS DocumentId,'Posted' AS InternalState,  NUll AS RecurInvId,NUll AS IsPost,NUll AS Counter,NUll AS NextDue,NUll AS LastPostedDate,NUll AS IsOBInvoice,NUll AS OpeningBalanceId,i.Id AS SyncWFInvoiceId,'Completed' AS SyncWFInvoiceStatus,GETDATE(),NUll AS SyncWFInvoiceRemarks,@MultiCurrency,@IsAllowableNonAllowable,@NoSupportingDocuments,@IsAllowableDisallowableActivated,left(@ScopeOfWork1,250),@ScopeOfWork1     
    from WorkFlow.Invoice i (nolock)   
    Inner join WorkFlow.CaseGroup G (nolock) ON G.ID=I.CaseId    
    inner join Common.Company C (nolock) ON C.Id=G.CompanyId    
    WHERE I.CompanyId=@CompanyId and g.ClientId=@ClientId and I.CaseId=@CaseId and I.ID=@InvoiceId

	SELECT @COAId=I.COAId,@ItemId=I.Id,@ItemCode=I.Code,@Description=I.Description 
	from Bean.Item I 
	INNER JOIN Common.Service S (nolock) on I.DocumentId=S.Id 
	Where I.CompanyId=@CompanyId and DocumentId=@ServiceId
       
	SELECT @TaxRate=TaxRate,@Taxcode=Code FROM Bean.TaxCode (nolock) WHERE ID IN (SELECT TaxCodeId FROM WorkFlow.Invoice WHERE CompanyId=@CompanyId AND CaseId=@CaseId AND ID=@InvoiceId)
	--Insert record into Bean.InvoiceDetails table
	INSERT INTO  Bean.InvoiceDetail (ID,InvoiceId,ItemId,ItemCode,ItemDescription,Qty,Unit,UnitPrice,DiscountType,    
      Discount,COAId,TaxId,TaxRate,DocTaxAmount,DocAmount,TaxCurrency,AmtCurrency,DocTotalAmount,BaseAmount,BaseTaxAmount,BaseTotalAmount,    
      RecOrder,TaxIdCode )    
    
    SELECT NEWID() AS Id,@BeanInvId as InvoiceId,@ItemId as ItemId,@ItemCode as ItemCode,@Description as 'Description',1 as Qty,'' as Unit ,    
    I.Fee as UnitPrice,'$'AS DiscountType , 0 AS Discount,@COAId AS COAId,I.TaxCodeId AS TaxId, @TaxRate AS TaxRate  ,    
       ROUND((I.Fee *(IsNull(@TaxRate,0)/100)),2) AS DocTaxAmount, ROUND(I.Fee,2) AS DocAmount,    
    i.TaxCurrency AS TaxCurrency,i.Currency AS AmtCurrency,    
    I.Fee + ROUND((I.Fee * IsNull(CAST(@TaxRate as INT),0)/100),2) AS DocTotalAmount,     
    ROUND((I.Fee * I.DocToBaseExhRate),2) as BaseAmount,    
    ROUND( (ROUND((I.Fee *(IsNull(@TaxRate,0)/100)),2) * i.DocToBaseExhRate),2) as BaseTaxAmount,     
    (ROUND((I.Fee * I.DocToBaseExhRate),2) + ROUND( (ROUND((I.Fee *(IsNull(@TaxRate,0)/100)),2) * i.DocToBaseExhRate),2)) as BaseTotalAmount,     
     1 AS RecOrder,    
     cASE WHEN @Taxcode='NA' THEN 'NA'           
     ELSE ((@Taxcode + '-' + Case when @TaxRate is null then 'NA' Else CAST(@TaxRate as Nvarchar (50)) +'%' End)) END  as TaxIdCode     
    FROM WorkFlow.Invoice I (nolock)    
       Inner join WorkFlow.CaseGroup G (nolock) ON G.ID=I.CaseId    
       WHERE I.CompanyId=@CompanyId and g.ClientId=@ClientId and I.CaseId=@CaseId and I.ID=@InvoiceId
	IF  Exists(select Distinct InvoiceId from WorkFlow.Incidental where InvoiceId=@InvoiceId)
	BEGIN
		INSERT INTO Bean.InvoiceDetail (ID,InvoiceId,ItemId,ItemCode,ItemDescription,Qty,Unit,UnitPrice,DiscountType,    
		  Discount,COAId,TaxId,TaxRate,DocTaxAmount,DocAmount,TaxCurrency,AmtCurrency,DocTotalAmount,    
		  TaxIdCode     
		  )    
		Select NewId() as ID,@BeanInvId AS InvoiceId,    
		IT.Id as ItemId,    
		IT.Code as ItemCode,    
		IT.Description as ItemDescription,    
		1 AS Qty,'' AS Unit,SUM(IsNull(IC.GstAmount,0)) AS UnitPrice,'$' AS DiscountType,0 AS Discount,    
		IT.COAId as COAId,    
		TaxId AS TaxId,IsNull(TaxRate,0) AS TaxRate,    
		SUM(Round((IsNull(IC.GstAmount,0))*(IsNull(TaxRate,0)/100),2)) AS DocTaxAmount,    
		Round(SUM(IsNull(IC.GstAmount,0)),2) AS DocAmount,    
		NULL AS TaxCurrency,DocCurrency AS AmtCurrency,    
		Round(SUM(IsNull(GstAmount,0))+SUM(Round((IsNull(GstAmount,0))*(IsNull(TaxRate,0)/100),2)),2) AS DocTotalamount,    
		CASE WHEN TaxCode='NA' THEN 'NA' WHEN TaxCode LIKE'%-NA(I)%' THEN  REPLACE(TaxCode,'NA(I)','NA')    
		WHEN TaxCode LIKE'%-NA(O)%' THEN  REPLACE(TaxCode,'NA(O)','NA')    
		ELSE (Substring(TaxCode,1,CHARINDEX('%',TaxCode))) END as TaxIdCode    
		From WorkFlow.Incidental IC (nolock)
		join Bean.Item IT (nolock)
		on IT.IncidentalType=IC.IncidentalType
		Where IT.CompanyId=@CompanyId and IT.IsIncidental=1 and IT.IncidentalType IS NOT NULL and IC.InvoiceId=@InvoiceId   
		group by IC.TaxId,IC.TaxCode,IsNull(IC.TaxRate,0),IC.IncidentalType,IC.DocCurrency,IC.DocToBaseExhRate,IT.Id,IT.Code,IT.Description,IT.COAId
	END
	update InvD SET     
     --Select     
    InvD.Baseamount = CONVERT(decimal(28,2),(InvD.DocAmount * BInv.ExchangeRate) ),    
    Invd.BaseTaxAmount= CONVERT(decimal(28,2),(InvD.DocTaxAmount * BInv.ExchangeRate) ),    
	InvD.BaseTotalAmount=(CONVERT(decimal(28,2),(InvD.DocAmount * BInv.ExchangeRate)) + CONVERT(decimal(28,2),(InvD.DocTaxAmount * BInv.ExchangeRate)))    
    from Bean.Invoice as BInv     
    join Bean.InvoiceDetail as InvD on BInv.Id=InvD.InvoiceId  where InvD.InvoiceId in (select id from bean.Invoice where SyncWFInvoiceId=@InvoiceId)

	IF EXISTS ( Select 1 from sys.objects where name='Bean_Posting'AND type='P')
	BEGIN    
	EXEC [dbo].[Bean_Posting] @InvoiceId,'Invoice',@CompanyId    
	END

	IF OBJECT_ID('tempdb..#FeatureSettings') IS NOT NULL
		DROP TABLE #FeatureSettings
	IF OBJECT_ID('tempdb..#BeanEntityData') IS NOT NULL
		DROP TABLE #BeanEntityData
	 
 END  
  COMMIT TRAN                
 END TRY              
              
 BEGIN CATCH              
  SELECT ERROR_NUMBER() AS ErrorNumber              
   ,ERROR_SEVERITY() AS ErrorSeverity              
   ,ERROR_STATE() AS ErrorState              
   ,ERROR_PROCEDURE() AS ErrorProcedure              
   ,ERROR_LINE() AS ErrorLine              
   ,ERROR_MESSAGE() AS ErrorMessage;              
  ROLLBACK TRAN;              
 END CATCH;              
END