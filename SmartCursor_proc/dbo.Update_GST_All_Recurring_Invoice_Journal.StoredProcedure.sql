USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[Update_GST_All_Recurring_Invoice_Journal]    Script Date: 16-12-2024 9.20.11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[Update_GST_All_Recurring_Invoice_Journal](@companyId bigint,@serviceEntityId bigint)
As
Begin
Declare @TaxId bigint;
Select @TaxId=T.Id from Bean.TaxCode as T where Code='NA' and CompanyId=0
Declare @InvoiceId table(Id uniqueidentifier)
Insert into @InvoiceId
Select Id from Bean.Invoice where  CompanyId=@companyId and ServiceCompanyId=@serviceEntityId and InternalState='Recurring' 
Declare @JournalId table(Id uniqueidentifier) 
Insert into @JournalId
Select Id from Bean.Journal where  CompanyId=@companyId and ServiceCompanyId=@serviceEntityId and DocumentState='Recurring'
 
 if exists (Select Id from Bean.Invoice where  CompanyId=@companyId and ServiceCompanyId=@serviceEntityId and InternalState='Recurring') 
 Begin
  Update Bean.Invoice set IsGstSettings=1 where Id in ( Select Id from @InvoiceId)
  update Bean.InvoiceDetail set TaxId=@TaxId,TaxRate=Null,DocTaxAmount=0,BaseTaxAmount=0 where InvoiceId in ( Select Id from @InvoiceId)
 End
 if exists (Select Id from Bean.Journal where  CompanyId=@companyId and ServiceCompanyId=@serviceEntityId and DocumentState='Recurring')
 Begin
  update Bean.Journal set IsGstSettings=1 where Id in (Select Id from @JournalId)
  Update Bean.JournalDetail set TaxId=@TaxId,TaxRate=Null,DocTaxDebit=0,DocTaxCredit=0,BaseTaxDebit=0,BaseTaxCredit=0 where JournalId in (Select Id from @JournalId)
 End
End
GO
