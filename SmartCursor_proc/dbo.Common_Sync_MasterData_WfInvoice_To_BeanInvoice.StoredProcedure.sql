USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[Common_Sync_MasterData_WfInvoice_To_BeanInvoice]    Script Date: 16-12-2024 9.20.10 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[Common_Sync_MasterData_WfInvoice_To_BeanInvoice]    
@Caseid uniqueidentifier,    
@ClientId uniqueidentifier,    
@InvoiceId uniqueidentifier,    
@CompanyId  Int    
       
AS    
BEGIN     
    
 --Exec  [dbo].[Common_Sync_MasterData_WfInvoice_To_BeanInvoice] '7f19cc1f-e655-ae1c-a293-95992edd9893' ,'9b528a25-da5a-401e-afda-6ee492e94382','393e43e4-479f-4a9e-90e4-73e114a25dd9',1007    
    
--Declare @ClientId uniqueidentifier='7C37F375-D09A-465A-B104-7D0DCC2DF67C'    
--Declare @CaseId uniqueidentifier='B71E7698-CCA5-C4AC-ABB1-15A0C08B0E6A'    
--Declare @InvoiceId uniqueidentifier='CCF2D392-D1D9-479A-B747-2DA7080120C3'    
--Declare @CompanyId  Int=239    
    
Declare @CreditTermId bigint    
Declare @EntityId uniqueidentifier    
Declare @CustNature nvarchar(50)    
Declare @DueDate datetime    
DEclare @Pono nvarchar(50)    
    
    
Declare @ServiceId bigint    
Declare @BeanInvId uniqueidentifier    
Declare @ItemId uniqueidentifier    
Declare @ItemCode nvarchar(400)    
Declare @Description nvarchar(2000)    
Declare @COAId bigint    
--Declare @TaxRate Decimal(10,2)    
Declare @TaxRate float    
Declare @Taxcode nvarchar(100)    
    
--Declare @Inc_ItemId uniqueidentifier    
--Declare @Inc_ItemCode nvarchar(400)    
--Declare @Inc_Description nvarchar(2000)    
--Declare @Inc_COAId bigint    
--Declare @Inc_Taxcode nvarchar(100)    
--Declare @Inc_TaxRate float    
--Declare @TaxId Bigint    
    
Declare @MultiCurrency nvarchar(50)    
Declare @NoSupportingDocuments nvarchar(50)    
Declare @IsAllowableDisallowableActivated nvarchar(50)    
Declare @IsAllowableNonAllowable nvarchar(50)    
    
 BEGIN Transaction     
   BEGIN Try    
   Declare InvoiceId_Csr Cursor For    
    
   SELECT g.ClientId,I.CaseId,I.ID AS InvoiceId,g.ServiceId    
   FROM WorkFlow.Invoice I     
   Inner join WorkFlow.CaseGroup G ON G.ID=I.CaseId    
    WHERE I.CompanyId=@CompanyId and g.ClientId=@ClientId and I.CaseId=@CaseId and I.ID=@InvoiceId    
    
   Open InvoiceId_Csr;    
   Fetch Next From InvoiceId_Csr Into  @ClientId,@CaseId,@InvoiceId,@ServiceId    
   While @@FETCH_STATUS=0    
   Begin    
    
     IF NOT  Exists  ( select Id from bean.Invoice where CompanyId=@CompanyId and DocumentId=@InvoiceId and DocumentId is not null )    
    BEGIN     
    
          
       set @MultiCurrency=(select Case when Name='Multi-Currency' Then 1 else 0 end 'Multi-Currency' FROM Common.Feature f    
       Inner join Common.CompanyFeatures cf on f.Id=cf.FeatureId WHERE cf.CompanyId=@CompanyId and IsChecked=1 and f.Status=1  and Name='Multi-Currency')    
            
           
                   set @NoSupportingDocuments=(select Case when Name='No Supporting Documents' Then 1 else 0 end 'No Supporting Documents' FROM Common.Feature f    
       Inner join Common.CompanyFeatures cf on f.Id=cf.FeatureId WHERE cf.CompanyId=@CompanyId and IsChecked=1 and f.Status=1   and Name='No Supporting Documents')    
    
       set @IsAllowableDisallowableActivated=(select Case when Name='Allowable/Non Allowable' Then 1 else 0 end 'Allowable/Non Allowable' FROM Common.Feature f    
       Inner join Common.CompanyFeatures cf on f.Id=cf.FeatureId WHERE cf.CompanyId=@CompanyId and IsChecked=1 and f.Status=1 and Name='Allowable/Non Allowable' )    
    
    
       set @IsAllowableNonAllowable=(select Case when Name='IsAllowableNonAllowable' Then 1 else 0 end 'IsAllowableNonAllowable' FROM Common.Feature f    
       Inner join Common.CompanyFeatures cf on f.Id=cf.FeatureId WHERE cf.CompanyId=@CompanyId and IsChecked=1 and f.Status=1 and Name='IsAllowableNonAllowable' )    
    
    
       set @MultiCurrency=ISNULL(@MultiCurrency,0)    
       set @NoSupportingDocuments=ISNULL(@NoSupportingDocuments,0)    
       set @IsAllowableDisallowableActivated=ISNULL(@IsAllowableDisallowableActivated,0)    
       set @IsAllowableNonAllowable=ISNULL(@IsAllowableNonAllowable,0)    
    
       DEclare @ScopeOfWork nvarchar(max)    
       Declare @ScopeOfWork1 nvarchar(max)    
    
       --- using the funcation in [udf_StripHTML_To_PlainText]---------------    
    
               set @ScopeOfWork =(select  [dbo].[udf_StripHTML_To_PlainText](ScopeOfWork)    
      from WorkFlow.CaseGroup where Id=@Caseid)    
          
      -----------------------------------------------------------------------------    
      ---select @ScopeOfWork    
          
          
      set @ScopeOfWork1 =(select Isnull(CAST( Replace(Replace(REPLACE(REPLACE(@ScopeOfWork,'{{FromDate}}',Convert(varchar,cg.fromdate,103)),'{{ToDate}}',COnvert(varchar,cg.todate,103)),'{{FEE}}',cg.fee),'{{YA}}',Year(cg.todate)+1) AS varchar(max)),  
   @ScopeOfWork)     
         from WorkFlow.CaseGroup cg where id=@Caseid)    
    
    
    
            SET @DueDate=(select DATEADD(DAY,isnull(tp.TOPValue,0),i.InvDate  )Duedate from WorkFlow.CaseGroup c    
      inner join Bean.Entity E on c.ClientId=E.SyncClientId    
      inner join WorkFlow.Invoice i on i.CaseId=c.Id    
      inner join WorkFlow.Client  wc on wc.Id=c.ClientId    
      inner join Common.TermsOfPayment  tp on wc.TermsOfPaymentId=tp.Id    
      where i.Id=@InvoiceId and i.CompanyId=@Companyid and c.Id=@Caseid)    
    
               SET @Pono=(select cg.CaseNumber + '/' + Left(InvType,1)from WorkFlow.CaseGroup cg inner join WorkFlow.Invoice i on i.CaseId=cg.Id  where i.CompanyId=@Companyid and cg.Id=@Caseid and  i.Id=@InvoiceId)    
               SET @EntityId=(select E.Id from WorkFlow.CaseGroup c inner join Bean.Entity E on c.ClientId=E.SyncClientId where  E.CompanyId=@Companyid and C.Id=@Caseid)    
              SET @CreditTermId=(select E.CustTOPId from WorkFlow.CaseGroup c inner join Bean.Entity E on c.ClientId=E.SyncClientId where  E.CompanyId=@Companyid and C.Id=@Caseid)    
              SET @CustNature=(select E.CustNature from WorkFlow.CaseGroup c inner join Bean.Entity E on c.ClientId=E.SyncClientId where  E.CompanyId=@Companyid and C.Id=@Caseid)    
         
        insert into  bean.invoice( Id,CompanyId,DocSubType,DocDate,DueDate,DocNo,PONo,NoSupportingDocs,SegmentCategory1,SegmentCategory2,IsRepeatingInvoice,RepEveryPeriodNo,RepEveryPeriod,RepEndDate    
     ,EntityType,EntityId,CreditTermsId,Nature,DocCurrency,ExchangeRate,ExCurrency,ExDurationFrom,ExDurationTo,GSTExchangeRate,GSTExCurrency,GSTExDurationFrom,GSTExDurationTo    
     ,DocumentState,BalanceAmount,GSTTotalAmount,GrandTotal,IsGstSettings,IsSegmentReporting,UserCreated,CreatedDate,ModifiedBy,ModifiedDate,Version,Status,ParentInvoiceID,InvoiceNumber,    
     --IsMultiCurrency,IsAllowableNonAllowable,Remarks,IsNoSupportingDocument,IsAllowableDisallowableActivated,DocDescription,    
     ServiceCompanyId,DocType,ReverseDate,ReverseIsSupportingDocument,ReverseRemarks,AllocatedAmount,SegmentMasterid1,SegmentMasterid2,SegmentDetailid1,SegmentDetailid2,IsBaseCurrencyRateChanged,    
     IsGSTCurrencyRateChanged,IsGSTApplied,ItemTotal,ExtensionType,IsWorkFlowInvoice,CursorType,DocumentId,InternalState,RecurInvId,IsPost,Counter,NextDue,LastPostedDate,IsOBInvoice,OpeningBalanceId,    
     SyncWFInvoiceId,SyncWFInvoiceStatus,SyncWFInvoiceDate,SyncWFInvoiceRemarks,IsMultiCurrency,IsAllowableNonAllowable,IsNoSupportingDocument,IsAllowableDisallowableActivated ,    
     DocDescription,Remarks)    
    
    select NEWID() AS Invoiceid ,    
    i.CompanyId,InvType AS DocSubType,Convert(date,InvDate)InvDate,@DueDate AS DueDate,i.Number AS DocNo,@Pono AS PONo,Null AS NoSupportingDocs,NUll AS SegmentCategory1,NUll AS SegmentCategory2,    
    0 AS IsRepeatingInvoice,NUll AS RepEveryPeriodNo,NUll AS RepEveryPeriod,NUll AS RepEndDate,'Customer' AS EntityType,@EntityId AS EntityId,@CreditTermId AS CreditTermsId,    
    @CustNature AS Nature,i.Currency AS DocCurrency,i.DocToBaseExhRate as ExchangeRate,i.BaseCurrency AS ExCurrency,NUll AS ExDurationFrom,NUll AS ExDurationTo,DocToJudExhRate AS GSTExchangeRate,C.GstCurrency AS GSTExCurrency,    
    NUll AS GSTExDurationFrom,NUll AS GSTExDurationTo,i.State AS DocumentState,TotalFee AS BalanceAmount,NUll AS GSTTotalAmount,TotalFee AS GrandTotal,IsGst AS IsGstSettings,    
        
    NUll AS IsSegmentReporting,i.ModifiedBy AS UserCreated,i.ModifiedDate AS CreatedDate,NUll AS ModifiedBy,NUll AS ModifiedDate,NUll AS Version,1 AS Status,null AS ParentInvoiceID,    
    Number AS InvoiceNumber,(Select ServiceCompanyId from WorkFlow.CaseGroup where CompanyId=@Companyid and Id=@Caseid),'Invoice' AS DocType,NUll AS ReverseDate,NUll AS ReverseIsSupportingDocument,    
    NUll AS ReverseRemarks,NUll AS AllocatedAmount,NUll AS SegmentMasterid1,NUll AS SegmentMasterid2,NUll AS SegmentDetailid1,NUll AS SegmentDetailid2,i.IsDocToBaseExhRateChanged AS IsBaseCurrencyRateChanged,    
    i.IsDocToJudExhRateChanged AS IsGSTCurrencyRateChanged,NUll AS IsGSTApplied,NUll AS ItemTotal,NUll AS ExtensionType,1 AS IsWorkFlowInvoice,NUll AS CursorType,i.Id AS DocumentId,'Posted' AS InternalState,    
    NUll AS RecurInvId,NUll AS IsPost,NUll AS Counter,NUll AS NextDue,NUll AS LastPostedDate,NUll AS IsOBInvoice,NUll AS OpeningBalanceId,i.Id AS SyncWFInvoiceId,    
    'Completed' AS SyncWFInvoiceStatus,GETDATE(),NUll AS SyncWFInvoiceRemarks,@MultiCurrency,@IsAllowableNonAllowable,@NoSupportingDocuments,@IsAllowableDisallowableActivated,left(@ScopeOfWork1,250),@ScopeOfWork1     
    from WorkFlow.Invoice i    
       Inner join WorkFlow.CaseGroup G ON G.ID=I.CaseId    
       inner join Common.Company C ON C.Id=G.CompanyId    
       WHERE I.CompanyId=@CompanyId and g.ClientId=@ClientId and I.CaseId=@CaseId and I.ID=@InvoiceId    
    
    
        
    
    --Update iv set      
    --iv.IsMultiCurrency=@MultiCurrency,IsNoSupportingDocument=@NoSupportingDocuments,    
    --IsAllowableDisallowableActivated=@IsAllowableDisallowableActivated,IsAllowableNonAllowable=@IsAllowableNonAllowable    
    --from  Bean.Invoice iv    
    --where iv.CompanyId=@Companyid and iv.Id=@BeanInvId    
         
     END     
        
     IF  Exists  ( select Id from bean.Invoice where CompanyId=@CompanyId and DocumentId=@InvoiceId and DocumentId is not null )    
    BEGIN     
       SET @BeanInvId= ( select Id from bean.Invoice where CompanyId=@CompanyId and DocumentId=@InvoiceId and DocumentId is not null )    
         IF   NOT Exists ( SELECT Id FROM  Bean.InvoiceDetail where InvoiceId=@BeanInvId)    
          BEGIN     
    
    
      SET @ItemId = (  select Id from Bean.Item where CompanyId=@CompanyId and DocumentId=@ServiceId )    
      SET @ItemCode = (  select Code from Bean.Item where CompanyId=@CompanyId and DocumentId=@ServiceId )    
      SET @Description = (  select [Description] from Bean.Item where CompanyId=@CompanyId and DocumentId=@ServiceId )    
      SET @COAId = (  select i.COAId from Bean.Item i inner join Common.Service s on i.DocumentId=s.id where i.CompanyId=@CompanyId and DocumentId=@ServiceId )    
       --================================== new change suresh ==============================    
      SET @TaxRate=( SELECT TaxRate FROM Bean.TaxCode WHERE ID IN (SELECT TaxCodeId FROM WorkFlow.Invoice WHERE CompanyId=@CompanyId AND CaseId=@CaseId AND ID=@InvoiceId))    
    
      --SET @TaxRate=( SELECT isnull(TaxRate,0) FROM Bean.TaxCode WHERE ID IN (SELECT TaxCodeId FROM WorkFlow.Invoice WHERE CompanyId=@CompanyId AND CaseId=@CaseId AND ID=@InvoiceId))    
      --set @TaxRate=ISNULL(@TaxRate,0)    
    
      SET @Taxcode=(  SELECT Code FROM Bean.TaxCode WHERE ID IN (SELECT TaxCodeId FROM WorkFlow.Invoice WHERE CompanyId=@CompanyId AND CaseId=@CaseId AND ID=@InvoiceId))    
    
      -- SET @Inc_ItemId = (  select Id from Bean.Item where CompanyId=@CompanyId and IsIncidental=1 )    
      --SET @Inc_ItemCode = (  select Code from Bean.Item where CompanyId=@CompanyId and IsIncidental=1   )    
      --SET @Inc_Description = (  select [Description] from Bean.Item where CompanyId=@CompanyId  and IsIncidental=1   )    
      --SET @Inc_COAId = (  select i.COAId from Bean.Item i where i.CompanyId=@CompanyId and IsIncidental=1)    
    
      --SET @Inc_TaxRate=( SELECT isnull(TaxRate,0) FROM Bean.TaxCode WHERE ID IN (SELECT i.TaxCodeId FROM WorkFlow.Invoice i    
      --    inner join WorkFlow.Incidental ic on  i.Id=ic.InvoiceId    
      --    WHERE CompanyId=@CompanyId AND CaseId=@CaseId AND i.Id=@InvoiceId))    
         
      --     SET @Inc_Taxcode=( SELECT code FROM Bean.TaxCode WHERE ID IN (SELECT i.TaxCodeId FROM WorkFlow.Invoice i    
      --    inner join WorkFlow.Incidental ic on  i.Id=ic.InvoiceId    
      --    WHERE CompanyId=@CompanyId AND CaseId=@CaseId AND i.Id=@InvoiceId))    
              
    
               --SET @TaxId=( SELECT TaxCodeId FROM WorkFlow.Invoice I     
               --               Inner join WorkFlow.CaseGroup G ON G.ID=I.CaseId    
               --              WHERE I.CompanyId=@CompanyId and g.ClientId=@ClientId and I.CaseId=@CaseId and I.ID=@InvoiceId)    
 ------------------------------------------------------------------------------------------------------------------------    
    
      INSERT INTO  bean.InvoiceDetail (ID,InvoiceId,ItemId,ItemCode,ItemDescription,Qty,Unit,UnitPrice,DiscountType,    
      Discount,COAId,TaxId,TaxRate,DocTaxAmount,DocAmount,TaxCurrency,AmtCurrency,DocTotalAmount,BaseAmount,BaseTaxAmount,BaseTotalAmount,    
      RecOrder,TaxIdCode )    
    
       SELECT NewId() AS ID,@BeanInvId as InvoiceId,@ItemId as ItemId,@ItemCode as ItemCode,@Description as 'Description',1 as Qty,'' as Unit ,    
    I.Fee as UnitPrice,'$'AS DiscountType , 0 AS Discount,@COAId AS COAId,I.TaxCodeId AS TaxId, @TaxRate AS TaxRate  ,    
       Round((I.Fee *(isnull(@TaxRate,0)/100)),2) AS DocTaxAmount, Round(I.Fee,2) AS DocAmount,    
    i.TaxCurrency AS TaxCurrency,i.Currency AS AmtCurrency,    
    I.Fee + Round((I.Fee * IsNull(CAST(@TaxRate as INT),0)/100),2) AS DocTotalAmount,     
    Round((I.Fee * I.DocToBaseExhRate),2) as BaseAmount,    
    Round( (round((I.Fee *(isnull(@TaxRate,0)/100)),2) * i.DocToBaseExhRate),2) as BaseTaxAmount,     
    (Round((I.Fee * I.DocToBaseExhRate),2) + Round( (round((I.Fee *(isnull(@TaxRate,0)/100)),2) * i.DocToBaseExhRate),2)) as BaseTotalAmount,     
     1 AS RecOrder,    
     cASE WHEN @Taxcode='NA' THEN 'NA'           
     ELSE ((@Taxcode + '-' + Case when @TaxRate is null then 'NA' Else cast(@TaxRate as Nvarchar (50)) +'%' End)) END  as TaxIdCode     
    FROM WorkFlow.Invoice I     
       Inner join WorkFlow.CaseGroup G ON G.ID=I.CaseId    
       WHERE I.CompanyId=@CompanyId and g.ClientId=@ClientId and I.CaseId=@CaseId and I.ID=@InvoiceId    
----  -------------------------------------------------------------------------------------------------------------------------------------    
             if  Exists(select Distinct InvoiceId from WorkFlow.Incidental where InvoiceId=@InvoiceId)    
               BEGIN    
    
    DEclare @Record int=(select Max(RecOrder) AS Recorder from Bean.InvoiceDetail where InvoiceId=@BeanInvId )    
     INSERT INTO  bean.InvoiceDetail (ID,InvoiceId,ItemId,ItemCode,ItemDescription,Qty,Unit,UnitPrice,DiscountType,    
      Discount,COAId,TaxId,TaxRate,DocTaxAmount,DocAmount,TaxCurrency,AmtCurrency,DocTotalAmount,    
      TaxIdCode     
      )    
    
    
     select NewId() as ID,@BeanInvId AS InvoiceId,    
    (select distinct Id from Bean.Item i where i.CompanyId=@CompanyId and i.IsIncidental=1 and i.IncidentalType=ic.IncidentalType),    
    (select distinct code from Bean.Item i where i.CompanyId=@CompanyId and i.IsIncidental=1 and i.IncidentalType=Ic.IncidentalType) ,    
    (select distinct Description from Bean.Item I where i.CompanyId=@CompanyId and i.IsIncidental=1 and i.incidentalType =Ic.IncidentalType),    
    1 AS Qty,'' AS Unit,SUM(isnull(GstAmount,0)) AS UnitPrice,'$' AS DiscountType,0 AS Discount,    
    (select i.COAId from Bean.Item i where i.CompanyId=@CompanyId and i.IsIncidental=1 and i.incidentalType =Ic.IncidentalType),    
    TaxId AS TaxId,isnull(TaxRate,0) AS TaxRate,    
   -- ROund(SUM(isnull(GstAmount,0))*(ISNULL(TaxRate,0)/100),2) AS DocTaxAmount,    
       Round(Sum((isnull(GstAmount,0))*(ISNULL(TaxRate,0)/100)),2) AS DocTaxAmount,    
    Round(SUM(isnull(GstAmount,0)),2) AS DocAmount,    
    NULL AS TaxCurrency,DocCurrency AS AmtCurrency,    
    --ROund(SUM(isnull(GstAmount,0))+Round((SUM(isnull(GstAmount,0))*(isnull(TaxRate,0)/100)),2),2) AS DocTotalamount,    
    ROund(SUM(isnull(GstAmount,0))+SUM(Round((isnull(GstAmount,0))*(ISNULL(TaxRate,0)/100),2)),2) AS DocTotalamount,    
    --Round(SUM(isnull(GstAmount,0)) * isnull(Ic.DocToBaseExhRate,0),2) AS BaseAmount,    
    --isnull(ROund((SUM(GstAmount*(ISNULL(TaxRate,0)/100))*1),2),0) AS BaseTaxAmount,    
    --ROund(SUM(isnull(GstAmount,0))*(ISNULL(TaxRate,0)/100),2) As BaseTaxAmount,    
      ---SUM(Round((round((isnull(GstAmount,0)*(ISNULL(TaxRate,0)/100)),2) * (Isnull(Ic.DocToBaseExhRate,0))),2)) As BaseTaxAmount,    
    --ROund((SUM(isnull(GstAmount,0))*1)+Round((SUM(isnull(GstAmount,0))*(isnull(TaxRate,0)/100)*1),2),2) AS BaseTotalAmount,    
      ---ROund((SUM(isnull(GstAmount,0))* isnull(Ic.DocToBaseExhRate,0))+SUM(Round((Round((isnull(GstAmount,0)*(ISNULL(TaxRate,0)/100)),2) * (Isnull(Ic.DocToBaseExhRate,0))),2)),2) AS BaseTotalAmount,    
    --ROW_NUMBER () Over (Order By Taxid)+1 AS Recorder,    
     --Ic.RecOrder,    
    
     --case when TaxCode='NA' THEN 'NA' ELSE     
     --(substring(TaxCode,1,charindex('%',TaxCode))) END as TaxIdCode     
     case when TaxCode='NA' THEN 'NA' when TaxCode LIKE'%-NA(I)%' THEN  REPLACE(TaxCode,'NA(I)','NA')    
           when TaxCode LIKE'%-NA(O)%' THEN  REPLACE(TaxCode,'NA(O)','NA')    
            ELSE (substring(TaxCode,1,charindex('%',TaxCode))) END as TaxIdCode    
    
     from WorkFlow.Incidental as Ic    
    where InvoiceId=@invoiceid     
    group by TaxId,TaxCode,isnull(TaxRate,0),IncidentalType,DocCurrency,DocToBaseExhRate--,--Ic.RecOrder    
    
    
    
    
    END     
    END    
    END    
    
    
    Fetch Next From InvoiceId_Csr Into  @ClientId,@CaseId,@InvoiceId,@ServiceId    
   End    
   Close InvoiceId_Csr    
   Deallocate InvoiceId_Csr    
    
    
 update InvD set     
     --Select     
    InvD.Baseamount = CONVERT(decimal(28,2),(InvD.DocAmount * BInv.ExchangeRate) ),    
    Invd.BaseTaxAmount= CONVERT(decimal(28,2),(InvD.DocTaxAmount * BInv.ExchangeRate) ),    
 --Invd.BaseTotalAmount= CONVERT(decimal(28,2),(InvD.DocTotalAmount * BInv.ExchangeRate) )    
 invd.BaseTotalAmount=(CONVERT(decimal(28,2),(InvD.DocAmount * BInv.ExchangeRate)) + CONVERT(decimal(28,2),(InvD.DocTaxAmount * BInv.ExchangeRate)))    
    from bean.Invoice as BInv     
    join Bean.InvoiceDetail as InvD on BInv.Id=InvD.InvoiceId  where InvD.InvoiceId in (select id from bean.Invoice where SyncWFInvoiceId=@InvoiceId)    
    
    
    
   BEGIN    
   EXEC [dbo].[Bean_Posting] @InvoiceId,'Invoice',@CompanyId    
   END    
    
     
    
    
    
    
    
    
    Commit Transaction;    
  End Try    
  Begin Catch    
   Rollback;    
   --if @Item_Incdtl_Count <>@WF_Incdtl_Count Or @WF_Incdtl_Count IS null    
   --BEGIN    
   -- RaisError ('selected category related type not exist in bean cursor setup',16,1)    
   --END    
   --ELse     
   --         BEGIN    
    Declare @Error_Message nvarchar(4000)    
    Select @Error_Message=ERROR_MESSAGE();    
    RaisError (@Error_Message,16,1)    
   --END    
  End Catch    
       END 
GO
