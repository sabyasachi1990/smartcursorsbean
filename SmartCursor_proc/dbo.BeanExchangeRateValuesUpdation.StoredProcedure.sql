USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[BeanExchangeRateValuesUpdation]    Script Date: 16-12-2024 9.20.10 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE Procedure [dbo].[BeanExchangeRateValuesUpdation]
@InvoiceId uniqueidentifier,
@CompanyId  Int
as
Begin

Declare @BeanInvoiceId uniqueidentifier

    update  BInv set 
   -- select
     ExchangeRate = WFinv.DocToBaseExhRate,IsBaseCurrencyRateChanged = WFinv.IsDocToBaseExhRateChanged,GSTExchangeRate = WFinv.DocToJudExhRate,
	  IsGSTCurrencyRateChanged = WFinv.IsDocToJudExhRateChanged, BaseBalanceAmount=WFinv.BaseOutStandingBalanceFee,BaseGrandTotal=WFinv.BaseTotalFee,BInv.DocDate=WFinv.InvDate,BInv.DueDate=WFinv.InvDate,BInv.ModifiedDate = WFinv.ModifiedDate,BInv.ModifiedBy =WFinv.ModifiedBy
     from WorkFlow.Invoice as WFinv
     join bean.Invoice as BInv on BInv.DocumentId=WFinv.Id   where BInv.DocumentId=@InvoiceId and BInv.CompanyId=@CompanyId


    set @BeanInvoiceId=(Select Id from Bean.Invoice where DocumentId in (Select Id from WorkFlow.Invoice where Id=@InvoiceId))

     update InvD set 
     --Select 
    InvD.Baseamount = CONVERT(decimal(28,2),(InvD.DocAmount * BInv.ExchangeRate) ),
    Invd.BaseTaxAmount= CONVERT(decimal(28,2),(InvD.DocTaxAmount * BInv.ExchangeRate) ),
	Invd.BaseTotalAmount= CONVERT(decimal(28,2),(InvD.DocTotalAmount * BInv.ExchangeRate) )
    from bean.Invoice as BInv 
    join Bean.InvoiceDetail as InvD on BInv.Id=InvD.InvoiceId  where InvD.InvoiceId=@BeanInvoiceId



    BEGIN
	     EXEC [dbo].[Bean_InvoicePosting]  @InvoiceId,'Invoice',@CompanyId
	END

End
GO
