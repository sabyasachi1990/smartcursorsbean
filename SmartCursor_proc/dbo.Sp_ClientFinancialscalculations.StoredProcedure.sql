USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[Sp_ClientFinancialscalculations]    Script Date: 16-12-2024 9.20.11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[Sp_ClientFinancialscalculations](@ClientId uniqueidentifier,@UserId uniqueidentifier)
AS
BEGIN

--DECLARE
--@ClientId UNIQUEIDENTIFIER = '834ee94c-42f0-4027-b31c-40eb24fdb079',
--@UserId UNIQUEIDENTIFIER = 'F043ADC7-B1B9-40BC-9B8B-A2E86088FA38'
 
 
DECLARE  @ClientFinancials  TABLE (CasesFee decimal(20,2) NULL, CasesInvoicesFeeWithoutTax decimal(20,2) NULL, CasesInvoicesFeeWithTax decimal(20,2) NULL,CasesInvoicesNotPaidAndPartiallyPaidFee decimal(20,2) NULL)
DECLARE @CaseFee decimal(20, 2), @InvoiceFee decimal(20, 2), @TotalFee decimal(20, 2), @OutstandingFee decimal(20, 2)
 
SELECT * INTO #CaseGroup
FROM (
	SELECT CG.Id, cg.BaseFee, cg.ClientId, cg.Stage
	FROM WorkFlow.CaseGroup AS cg
	JOIN Common.CompanyUser AS cu ON cg.CompanyId = cu.CompanyId
	JOIN Common.CompanyUserDetail AS cud ON cu.Id = cud.CompanyUserId
	WHERE cg.Stage <> 'Cancelled' AND cud.ServiceEntityId = cg.ServiceCompanyId  AND cu.UserId = @UserId AND ClientId = @ClientId
) AS A
 
SELECT @CaseFee = ISNULL(SUM(BaseFee), 0.0)
FROM #CaseGroup
WHERE ClientId = @ClientId
SELECT @InvoiceFee = ISNULL(SUM(i.BaseFee), 0.0),
       @TotalFee = ISNULL(SUM(i.BaseTotalFee), 0.0),
       @OutstandingFee = ISNULL(SUM(ISNULL((CASE WHEN i.State = 'Not Paid' THEN ISNULL(i.BaseTotalFee,0) END),0.00) + ISNULL((CASE WHEN i.State = 'Partially paid' THEN ISNULL(i.BaseOutStandingBalanceFee,0) END),0.00)), 0.0)
FROM  WorkFlow.Invoice AS i 
INNER JOIN #CaseGroup as cs ON cs.Id = i.CaseId
WHERE i.ClientId = @ClientId AND i.State IN ('Partially paid', 'Not Paid', 'Fully Paid')
 
 
INSERT INTO @ClientFinancials
SELECT @CaseFee ,@InvoiceFee,@TotalFee,@OutstandingFee
 
SELECT * FROM @ClientFinancials
 
DROP TABLE #CaseGroup

END







------>>>>> Do Not DELETE the below code
---- DECLARE  @ClientFinancials  TABLE (CasesFee decimal(20,2) null, CasesInvoicesFeeWithoutTax decimal(20,2) null,
---- CasesInvoicesFeeWithTax decimal(20,2) null,CasesInvoicesNotPaidAndPartiallyPaidFee decimal(20,2) null)
---- Insert into @ClientFinancials
---- SELECT IsNULL( (SELECT SUM(BaseFee)  FROM WorkFlow.CaseGroup as cg
---- join Common.CompanyUser as cu on cg.CompanyId= cu.CompanyId
---- join Common.CompanyUserDetail as cud on cu.Id=cud.CompanyUserId
---- WHERE ClientId =@ClientId AND Stage <> 'Cancelled' and cud.ServiceEntityId=cg.ServiceCompanyId and cu.UserId=@UserId ),0.0) as CaseFee,

 

---- IsNULL( (SELECT SUM(i.BaseFee)  FROM WorkFlow.CaseGroup cs 
---- join   WorkFlow.Invoice i on cs.Id = i.CaseId 
---- join Common.CompanyUser as cu on cs.CompanyId= cu.CompanyId
---- join Common.CompanyUserDetail as cud on cu.Id=cud.CompanyUserId
----  WHERE i.ClientId = @ClientId  and ( State = 'Partially paid' or State = 'Not Paid' or State = 'Fully Paid')
----   and cud.ServiceEntityId=cs.ServiceCompanyId and cu.UserId=@UserId),0.0) as InvoiceFee,

 

----  IsNULL( (SELECT SUM(i.BaseTotalFee)  FROM WorkFlow.CaseGroup cs 
---- join   WorkFlow.Invoice i on cs.Id = i.CaseId 
---- join Common.CompanyUser as cu on cs.CompanyId= cu.CompanyId
---- join Common.CompanyUserDetail as cud on cu.Id=cud.CompanyUserId
----  WHERE i.ClientId = @ClientId  and ( State = 'Partially paid' or State = 'Not Paid' or State = 'Fully Paid')
----  and cud.ServiceEntityId=cs.ServiceCompanyId and cu.UserId=@UserId),0.0) as TotalFee,

 

 
----  (IsNULL((SELECT SUM(i.BaseTotalFee)  FROM WorkFlow.CaseGroup cs 
---- JOIN   WorkFlow.Invoice i on cs.Id = i.CaseId 
---- join Common.CompanyUser as cu on cs.CompanyId= cu.CompanyId
---- join Common.CompanyUserDetail as cud on cu.Id=cud.CompanyUserId
----  WHERE i.ClientId = @ClientId  and ( State = 'Not Paid') and cud.ServiceEntityId=cs.ServiceCompanyId 
----  and cu.UserId=@UserId),0.0)
----  +
----  IsNULL( (SELECT SUM(i.BaseOutStandingBalanceFee)  FROM WorkFlow.CaseGroup cs 
---- JOIN   WorkFlow.Invoice i on cs.Id = i.CaseId 
---- join Common.CompanyUser as cu on cs.CompanyId= cu.CompanyId
---- join Common.CompanyUserDetail as cud on cu.Id=cud.CompanyUserId
----  WHERE i.ClientId = @ClientId  and ( State = 'Partially paid')
----  and cud.ServiceEntityId=cs.ServiceCompanyId and cu.UserId=@UserId),0.0) ) as Outstandingfee
----select * from @ClientFinancials
GO
