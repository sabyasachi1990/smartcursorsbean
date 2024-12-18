USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[Sp_CaseFinancialscalculations]    Script Date: 16-12-2024 9.20.11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[Sp_CaseFinancialscalculations](@CaseId uniqueidentifier)
as 
 begin
 DECLARE  @CaseFinancials  TABLE (CasesFee decimal(20,2) null, CasesInvoicesFeeWithoutTax decimal(20,2) null,
 CasesInvoicesFeeWithTax decimal(20,2) null,CasesInvoicesNotPaidAndPartiallyPaidFee decimal(20,2) null)
 Insert into @CaseFinancials
 SELECT IsNULL( (SELECT SUM(Fee)  FROM WorkFlow.CaseGroup WHERE id =@CaseId AND Stage <> 'Cancelled' ),0.0) as CaseFee,

 IsNULL( (SELECT SUM(i.Fee)  FROM WorkFlow.CaseGroup cs 
 join   WorkFlow.Invoice i on cs.Id = i.CaseId 
  WHERE cs.Id = @CaseId  and ( State = 'Partially paid' or State = 'Not Paid' or State = 'Fully Paid')),0.0) as InvoiceFee,

  IsNULL( (SELECT SUM(i.TotalFee)  FROM WorkFlow.CaseGroup cs 
 join   WorkFlow.Invoice i on cs.Id = i.CaseId 
  WHERE cs.Id = @CaseId  and ( State = 'Partially paid' or State = 'Not Paid' or State = 'Fully Paid')),0.0) as TotalFee,

 
  (IsNULL((SELECT SUM(i.TotalFee)  FROM WorkFlow.CaseGroup cs 
 JOIN   WorkFlow.Invoice i on cs.Id = i.CaseId 
  WHERE cs.Id = @CaseId  and ( State = 'Not Paid')),0.0)
  +
  IsNULL( (SELECT SUM(i.OutStandingBalanceFee)  FROM WorkFlow.CaseGroup cs 
 JOIN   WorkFlow.Invoice i on cs.Id = i.CaseId 
  WHERE cs.Id = @CaseId  and ( State = 'Partially paid')),0.0) ) as Outstandingfee
select * from @CaseFinancials
End
GO
