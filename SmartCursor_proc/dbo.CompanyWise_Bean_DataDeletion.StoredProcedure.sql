USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[CompanyWise_Bean_DataDeletion]    Script Date: 16-12-2024 9.20.10 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   PROCEDURE [dbo].[CompanyWise_Bean_DataDeletion]
@CompanyId Int

AS
BEGIN

DECLARE @CompanyInfo TABLE (Id Int, RegistrationNo Nvarchar(150), Name Nvarchar(500))

INSERT INTO @CompanyInfo
SELECT Id,RegistrationNo,Name FROM Common.Company WHERE Id = @CompanyId
UNION ALL
SELECT Id,RegistrationNo,Name FROM Common.Company WHERE ParentId = @CompanyId

-----------------==================================================================================================================================================================================================
---------------/////////////////////////////////////////////////////////////////////////////// BEAN \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
----------------==================================================================================================================================================================================================

-----------------//////////////////////////////////////////////////////////////////////// Bean.AccountType \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

DELETE FROM Bean.BankReconciliationDetail WHERE BankReconciliationId IN
(
SELECT Id FROM Bean.BankReconciliation WHERE COAId IN
(
SELECT Id FROM Bean.ChartOfAccount WHERE AccountTypeId IN
(SELECT Id FROM Bean.AccountType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo))
)
)

DELETE FROM Bean.BankReconciliation WHERE COAId IN
(
SELECT Id FROM Bean.ChartOfAccount WHERE AccountTypeId IN
(SELECT Id FROM Bean.AccountType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo))
)

DELETE FROM Bean.BankTransferDetail WHERE COAId IN
(
SELECT Id FROM Bean.ChartOfAccount WHERE AccountTypeId IN
(SELECT Id FROM Bean.AccountType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo))
)


----------DELETE FROM Bean.BillCreditMemoDetail WHERE BillDetailId IN---> No Data in Table
----------(
----------SELECT Id FROM Bean.BillDetail WHERE COAId IN 
----------(
----------SELECT Id FROM Bean.ChartOfAccount WHERE AccountTypeId IN
----------(SELECT Id FROM Bean.AccountType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo))
----------)
----------)

DELETE FROM Bean.BillDetail WHERE COAId IN 
(
SELECT Id FROM Bean.ChartOfAccount WHERE AccountTypeId IN
(SELECT Id FROM Bean.AccountType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo))
)

DELETE FROM Bean.CashSaleDetail WHERE CashSaleId IN
(
SELECT Id FROM Bean.CashSale WHERE COAId IN
(
SELECT Id FROM Bean.ChartOfAccount WHERE AccountTypeId IN
(SELECT Id FROM Bean.AccountType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo))
)
)

DELETE FROM Bean.CashSale WHERE COAId IN
(
SELECT Id FROM Bean.ChartOfAccount WHERE AccountTypeId IN
(SELECT Id FROM Bean.AccountType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo))
)

DELETE FROM Bean.CashSaleDetail WHERE COAId IN
(
SELECT Id FROM Bean.ChartOfAccount WHERE AccountTypeId IN
(SELECT Id FROM Bean.AccountType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo))
)

DELETE FROM Bean.COAMappingDetail WHERE CustCOAId IN
(
SELECT Id FROM Bean.ChartOfAccount WHERE AccountTypeId IN
(SELECT Id FROM Bean.AccountType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo))
)

DELETE FROM Bean.COAMappingDetail WHERE VenCOAId IN
(
SELECT Id FROM Bean.ChartOfAccount WHERE AccountTypeId IN
(SELECT Id FROM Bean.AccountType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo))
)

DELETE FROM Bean.CreditMemoDetail WHERE COAId IN
(
SELECT Id FROM Bean.ChartOfAccount WHERE AccountTypeId IN
(SELECT Id FROM Bean.AccountType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo))
)

DELETE FROM Bean.DebitNoteDetail WHERE COAId IN
(
SELECT Id FROM Bean.ChartOfAccount WHERE AccountTypeId IN
(SELECT Id FROM Bean.AccountType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo))
)

DELETE FROM Bean.GLClearingDetail WHERE GLClearingId IN
(
SELECT Id FROM Bean.GLClearing WHERE COAId IN
(
SELECT Id FROM Bean.ChartOfAccount WHERE AccountTypeId IN
(SELECT Id FROM Bean.AccountType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo))
)
)

DELETE FROM Bean.GLClearing WHERE COAId IN
(
SELECT Id FROM Bean.ChartOfAccount WHERE AccountTypeId IN
(SELECT Id FROM Bean.AccountType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo))
)

DELETE FROM Bean.InvoiceDetail WHERE COAId IN
(
SELECT Id FROM Bean.ChartOfAccount WHERE AccountTypeId IN
(SELECT Id FROM Bean.AccountType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo))
)

DELETE FROM Bean.CashSaleDetail WHERE ItemId IN
(
SELECT Id FROM Bean.Item WHERE COAId IN 
(
SELECT Id FROM Bean.ChartOfAccount WHERE AccountTypeId IN
(SELECT Id FROM Bean.AccountType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo))
)
)

DELETE FROM Bean.InvoiceDetail WHERE ItemId IN
(
SELECT Id FROM Bean.Item WHERE COAId IN 
(
SELECT Id FROM Bean.ChartOfAccount WHERE AccountTypeId IN
(SELECT Id FROM Bean.AccountType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo))
)
)

----------SELECT * FROM Bean.JournalLedger_ToBeDeleted ----> No Data in Table

DELETE FROM Bean.Item WHERE COAId IN 
(
SELECT Id FROM Bean.ChartOfAccount WHERE AccountTypeId IN
(SELECT Id FROM Bean.AccountType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo))
)


DELETE FROM Bean.OpeningBalanceDetailLineItem WHERE OpeningBalanceDetailId IN
(
SELECT Id FROM Bean.OpeningBalanceDetail WHERE COAId IN
(
SELECT Id FROM Bean.ChartOfAccount WHERE AccountTypeId IN
(SELECT Id FROM Bean.AccountType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo))
)
)

DELETE FROM Bean.OpeningBalanceDetail WHERE COAId IN
(
SELECT Id FROM Bean.ChartOfAccount WHERE AccountTypeId IN
(SELECT Id FROM Bean.AccountType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo))
)

DELETE FROM Bean.OpeningBalanceDetailLineItem WHERE COAId IN
(
SELECT Id FROM Bean.ChartOfAccount WHERE AccountTypeId IN
(SELECT Id FROM Bean.AccountType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo))
)

DELETE FROM Bean.PaymentDetail WHERE PaymentId IN
(
SELECT Id FROM Bean.Payment WHERE COAId IN
(
SELECT Id FROM Bean.ChartOfAccount WHERE AccountTypeId IN
(SELECT Id FROM Bean.AccountType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo))
)
)

DELETE FROM Bean.Payment WHERE COAId IN
(
SELECT Id FROM Bean.ChartOfAccount WHERE AccountTypeId IN
(SELECT Id FROM Bean.AccountType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo))
)

DELETE FROM Bean.ReceiptBalancingItem WHERE ReceiptId IN
(
SELECT Id FROM Bean.Receipt WHERE COAId IN 
(
SELECT Id FROM Bean.ChartOfAccount WHERE AccountTypeId IN
(SELECT Id FROM Bean.AccountType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo))
)
)

DELETE FROM Bean.ReceiptDetail WHERE ReceiptId IN
(
SELECT Id FROM Bean.Receipt WHERE COAId IN 
(
SELECT Id FROM Bean.ChartOfAccount WHERE AccountTypeId IN
(SELECT Id FROM Bean.AccountType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo))
)
)

DELETE FROM Bean.ReceiptGSTDetail WHERE ReceiptId IN 
(
SELECT Id FROM Bean.Receipt WHERE COAId IN 
(
SELECT Id FROM Bean.ChartOfAccount WHERE AccountTypeId IN
(SELECT Id FROM Bean.AccountType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo))
)
)

DELETE FROM Bean.Receipt WHERE COAId IN 
(
SELECT Id FROM Bean.ChartOfAccount WHERE AccountTypeId IN
(SELECT Id FROM Bean.AccountType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo))
)

DELETE FROM Bean.ReceiptBalancingItem WHERE COAId IN
(
SELECT Id FROM Bean.ChartOfAccount WHERE AccountTypeId IN
(SELECT Id FROM Bean.AccountType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo))
)

DELETE FROM Bean.WithDrawalDetail WHERE WithdrawalId IN
(
SELECT Id FROM Bean.WithDrawal WHERE COAId IN
(
SELECT Id FROM Bean.ChartOfAccount WHERE AccountTypeId IN
(SELECT Id FROM Bean.AccountType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo))
)
)

DELETE FROM Bean.WithDrawal WHERE COAId IN
(
SELECT Id FROM Bean.ChartOfAccount WHERE AccountTypeId IN
(SELECT Id FROM Bean.AccountType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo))
)

DELETE FROM Bean.WithDrawalDetail WHERE COAId IN
(
SELECT Id FROM Bean.ChartOfAccount WHERE AccountTypeId IN
(SELECT Id FROM Bean.AccountType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo))
)

DELETE FROM HR.CompanyPayrollSettingsDetail WHERE BankId IN
(
SELECT Id FROM Common.Bank WHERE COAId IN
(
SELECT Id FROM Bean.ChartOfAccount WHERE AccountTypeId IN
(SELECT Id FROM Bean.AccountType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo))
)
)

DELETE FROM Common.Bank WHERE COAId IN
(
SELECT Id FROM Bean.ChartOfAccount WHERE AccountTypeId IN
(SELECT Id FROM Bean.AccountType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo))
)


DELETE FROM ClientCursor.OpportunityDesignation WHERE OpportunityId IN
(
SELECT Id FROM ClientCursor.Opportunity WHERE ServiceId IN
(
SELECT Id FROM Common.Service WHERE CoaId IN
(
SELECT Id FROM Bean.ChartOfAccount WHERE AccountTypeId IN
(SELECT Id FROM Bean.AccountType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo))
)
)
)

------------SELECT * FROM ClientCursor.[OpportunityDoc] ----> No Data in Table

DELETE FROM ClientCursor.OpportunityHistory WHERE OpportunityId IN
(
SELECT Id FROM ClientCursor.Opportunity WHERE ServiceId IN
(
SELECT Id FROM Common.Service WHERE CoaId IN
(
SELECT Id FROM Bean.ChartOfAccount WHERE AccountTypeId IN
(SELECT Id FROM Bean.AccountType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo))
)
)
)

DELETE FROM ClientCursor.OpportunityIncharge WHERE OpportunityId IN
(
SELECT Id FROM ClientCursor.Opportunity WHERE ServiceId IN
(
SELECT Id FROM Common.Service WHERE CoaId IN
(
SELECT Id FROM Bean.ChartOfAccount WHERE AccountTypeId IN
(SELECT Id FROM Bean.AccountType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo))
)
)
)

DELETE FROM ClientCursor.OpportunityStatusChange WHERE OpportunityId IN
(
SELECT Id FROM ClientCursor.Opportunity WHERE ServiceId IN
(
SELECT Id FROM Common.Service WHERE CoaId IN
(
SELECT Id FROM Bean.ChartOfAccount WHERE AccountTypeId IN
(SELECT Id FROM Bean.AccountType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo))
)
)
)

----------SELECT * FROM ClientCursor.OpportunityTermsCondition_ToBeDeleted ---> No Data in Table

DELETE FROM ClientCursor.QuotationDetailTemplate WHERE QuotationDetailId IN
(
SELECT Id FROM ClientCursor.QuotationDetail WHERE OpportunityId IN
(
SELECT Id FROM ClientCursor.Opportunity WHERE ServiceId IN
(
SELECT Id FROM Common.Service WHERE CoaId IN
(
SELECT Id FROM Bean.ChartOfAccount WHERE AccountTypeId IN
(SELECT Id FROM Bean.AccountType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo))
)
)
)
)

DELETE FROM ClientCursor.QuotationDetail WHERE OpportunityId IN
(
SELECT Id FROM ClientCursor.Opportunity WHERE ServiceId IN
(
SELECT Id FROM Common.Service WHERE CoaId IN
(
SELECT Id FROM Bean.ChartOfAccount WHERE AccountTypeId IN
(SELECT Id FROM Bean.AccountType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo))
)
)
)

DELETE FROM Common.TimeLogDetailSplit WHERE TimelogDetailId IN
(
SELECT Id FROM Common.TimeLogDetail WHERE TimeLogScheduleId IN
(
SELECT Id FROM Common.TimeLogSchedule WHERE CaseId IN
(
SELECT Id FROM WorkFlow.CaseGroup WHERE OpportunityId IN
(
SELECT Id FROM ClientCursor.Opportunity WHERE ServiceId IN
(
SELECT Id FROM Common.Service WHERE CoaId IN
(
SELECT Id FROM Bean.ChartOfAccount WHERE AccountTypeId IN
(SELECT Id FROM Bean.AccountType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo))
)
)
)
)
)
)


DELETE FROM Common.TimeLogDetail WHERE TimeLogScheduleId IN
(
SELECT Id FROM Common.TimeLogSchedule WHERE CaseId IN
(
SELECT Id FROM WorkFlow.CaseGroup WHERE OpportunityId IN
(
SELECT Id FROM ClientCursor.Opportunity WHERE ServiceId IN
(
SELECT Id FROM Common.Service WHERE CoaId IN
(
SELECT Id FROM Bean.ChartOfAccount WHERE AccountTypeId IN
(SELECT Id FROM Bean.AccountType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo))
)
)
)
)
)

DELETE FROM Common.TimeLogSchedule WHERE CaseId IN
(
SELECT Id FROM WorkFlow.CaseGroup WHERE OpportunityId IN
(
SELECT Id FROM ClientCursor.Opportunity WHERE ServiceId IN
(
SELECT Id FROM Common.Service WHERE CoaId IN
(
SELECT Id FROM Bean.ChartOfAccount WHERE AccountTypeId IN
(SELECT Id FROM Bean.AccountType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo))
)
)
)
)

DELETE FROM HR.BankFileDetail WHERE TypeId IN
(
SELECT Id FROM HR.EmployeeClaim1 WHERE CaseGroupId IN
(
SELECT Id FROM WorkFlow.CaseGroup WHERE OpportunityId IN
(
SELECT Id FROM ClientCursor.Opportunity WHERE ServiceId IN
(
SELECT Id FROM Common.Service WHERE CoaId IN
(
SELECT Id FROM Bean.ChartOfAccount WHERE AccountTypeId IN
(SELECT Id FROM Bean.AccountType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo))
)
)
)
)
)

DELETE FROM HR.EmployeeClaimDetail WHERE EmployeeClaimId IN
(
SELECT Id FROM HR.EmployeeClaim1 WHERE CaseGroupId IN
(
SELECT Id FROM WorkFlow.CaseGroup WHERE OpportunityId IN
(
SELECT Id FROM ClientCursor.Opportunity WHERE ServiceId IN
(
SELECT Id FROM Common.Service WHERE CoaId IN
(
SELECT Id FROM Bean.ChartOfAccount WHERE AccountTypeId IN
(SELECT Id FROM Bean.AccountType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo))
)
)
)
)
)

DELETE FROM HR.EmployeeClaim1 WHERE CaseGroupId IN
(
SELECT Id FROM WorkFlow.CaseGroup WHERE OpportunityId IN
(
SELECT Id FROM ClientCursor.Opportunity WHERE ServiceId IN
(
SELECT Id FROM Common.Service WHERE CoaId IN
(
SELECT Id FROM Bean.ChartOfAccount WHERE AccountTypeId IN
(SELECT Id FROM Bean.AccountType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo))
)
)
)
)

DELETE FROM WorkFlow.CaseAmendDateOfCompletion WHERE CaseId IN
(
SELECT Id FROM WorkFlow.CaseGroup WHERE OpportunityId IN
(
SELECT Id FROM ClientCursor.Opportunity WHERE ServiceId IN
(
SELECT Id FROM Common.Service WHERE CoaId IN
(
SELECT Id FROM Bean.ChartOfAccount WHERE AccountTypeId IN
(SELECT Id FROM Bean.AccountType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo))
)
)
)
)

DELETE FROM WorkFlow.CaseDesignation WHERE CaseId IN
(
SELECT Id FROM WorkFlow.CaseGroup WHERE OpportunityId IN
(
SELECT Id FROM ClientCursor.Opportunity WHERE ServiceId IN
(
SELECT Id FROM Common.Service WHERE CoaId IN
(
SELECT Id FROM Bean.ChartOfAccount WHERE AccountTypeId IN
(SELECT Id FROM Bean.AccountType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo))
)
)
)
)

------------SELECT * FROM WorkFlow.CaseDoc ----> No Data in Table

DELETE FROM Common.TimeLogDetailSplit WHERE CaseFeatureId IN
(
SELECT Id FROM WorkFlow.CaseFeature WHERE CaseId IN
(
SELECT Id FROM WorkFlow.CaseGroup WHERE OpportunityId IN
(
SELECT Id FROM ClientCursor.Opportunity WHERE ServiceId IN
(
SELECT Id FROM Common.Service WHERE CoaId IN
(
SELECT Id FROM Bean.ChartOfAccount WHERE AccountTypeId IN
(SELECT Id FROM Bean.AccountType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo))
)
)
)
)
)

DELETE FROM WorkFlow.ScheduleTaskDetail WHERE CaseFeatureId IN
(
SELECT Id FROM WorkFlow.CaseFeature WHERE CaseId IN
(
SELECT Id FROM WorkFlow.CaseGroup WHERE OpportunityId IN
(
SELECT Id FROM ClientCursor.Opportunity WHERE ServiceId IN
(
SELECT Id FROM Common.Service WHERE CoaId IN
(
SELECT Id FROM Bean.ChartOfAccount WHERE AccountTypeId IN
(SELECT Id FROM Bean.AccountType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo))
)
)
)
)
)

DELETE FROM WorkFlow.CaseFeature WHERE CaseId IN
(
SELECT Id FROM WorkFlow.CaseGroup WHERE OpportunityId IN
(
SELECT Id FROM ClientCursor.Opportunity WHERE ServiceId IN
(
SELECT Id FROM Common.Service WHERE CoaId IN
(
SELECT Id FROM Bean.ChartOfAccount WHERE AccountTypeId IN
(SELECT Id FROM Bean.AccountType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo))
)
)
)
)

DELETE FROM WorkFlow.CaseIncharge WHERE CaseId IN
(
SELECT Id FROM WorkFlow.CaseGroup WHERE OpportunityId IN
(
SELECT Id FROM ClientCursor.Opportunity WHERE ServiceId IN
(
SELECT Id FROM Common.Service WHERE CoaId IN
(
SELECT Id FROM Bean.ChartOfAccount WHERE AccountTypeId IN
(SELECT Id FROM Bean.AccountType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo))
)
)
)
)

DELETE FROM WorkFlow.CaseMileStone WHERE CaseId IN
(
SELECT Id FROM WorkFlow.CaseGroup WHERE OpportunityId IN
(
SELECT Id FROM ClientCursor.Opportunity WHERE ServiceId IN
(
SELECT Id FROM Common.Service WHERE CoaId IN
(
SELECT Id FROM Bean.ChartOfAccount WHERE AccountTypeId IN
(SELECT Id FROM Bean.AccountType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo))
)
)
)
)

-----------SELECT * FROM WorkFlow.CasesAssigned ----> No Data in Table

DELETE FROM WorkFlow.CaseStatusChange WHERE CaseId IN
(
SELECT Id FROM WorkFlow.CaseGroup WHERE OpportunityId IN
(
SELECT Id FROM ClientCursor.Opportunity WHERE ServiceId IN
(
SELECT Id FROM Common.Service WHERE CoaId IN
(
SELECT Id FROM Bean.ChartOfAccount WHERE AccountTypeId IN
(SELECT Id FROM Bean.AccountType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo))
)
)
)
)

DELETE FROM WorkFlow.Claim WHERE CaseId IN
(
SELECT Id FROM WorkFlow.CaseGroup WHERE OpportunityId IN
(
SELECT Id FROM ClientCursor.Opportunity WHERE ServiceId IN
(
SELECT Id FROM Common.Service WHERE CoaId IN
(
SELECT Id FROM Bean.ChartOfAccount WHERE AccountTypeId IN
(SELECT Id FROM Bean.AccountType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo))
)
)
)
)

DELETE FROM WorkFlow.Incidental WHERE InvoiceId IN
(
SELECT Id FROM WorkFlow.Invoice WHERE CaseId IN
(
SELECT Id FROM WorkFlow.CaseGroup WHERE OpportunityId IN
(
SELECT Id FROM ClientCursor.Opportunity WHERE ServiceId IN
(
SELECT Id FROM Common.Service WHERE CoaId IN
(
SELECT Id FROM Bean.ChartOfAccount WHERE AccountTypeId IN
(SELECT Id FROM Bean.AccountType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo))
)
)
)
)
)

DELETE FROM WorkFlow.InvoiceDesignation WHERE InvoiceId IN
(
SELECT Id FROM WorkFlow.Invoice WHERE CaseId IN
(
SELECT Id FROM WorkFlow.CaseGroup WHERE OpportunityId IN
(
SELECT Id FROM ClientCursor.Opportunity WHERE ServiceId IN
(
SELECT Id FROM Common.Service WHERE CoaId IN
(
SELECT Id FROM Bean.ChartOfAccount WHERE AccountTypeId IN
(SELECT Id FROM Bean.AccountType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo))
)
)
)
)
)

----------SELECT * FROM WorkFlow.InvoiceState ----> No Data in Table

DELETE FROM WorkFlow.Invoice WHERE CaseId IN
(
SELECT Id FROM WorkFlow.CaseGroup WHERE OpportunityId IN
(
SELECT Id FROM ClientCursor.Opportunity WHERE ServiceId IN
(
SELECT Id FROM Common.Service WHERE CoaId IN
(
SELECT Id FROM Bean.ChartOfAccount WHERE AccountTypeId IN
(SELECT Id FROM Bean.AccountType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo))
)
)
)
)

DELETE FROM WorkFlow.InvoiceDesignation WHERE CaseId IN
(
SELECT Id FROM WorkFlow.CaseGroup WHERE OpportunityId IN
(
SELECT Id FROM ClientCursor.Opportunity WHERE ServiceId IN
(
SELECT Id FROM Common.Service WHERE CoaId IN
(
SELECT Id FROM Bean.ChartOfAccount WHERE AccountTypeId IN
(SELECT Id FROM Bean.AccountType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo))
)
)
)
)

DELETE FROM WorkFlow.ScheduleTaskDetail WHERE ScheduleTaskId IN
(
SELECT Id FROM WorkFlow.ScheduleTask WHERE ScheduleDetailId IN
(
SELECT Id FROM WorkFlow.ScheduleDetail WHERE MasterId IN
(
SELECT Id FROM WorkFlow.Schedule WHERE CaseId IN
(
SELECT Id FROM WorkFlow.CaseGroup WHERE OpportunityId IN
(
SELECT Id FROM ClientCursor.Opportunity WHERE ServiceId IN
(
SELECT Id FROM Common.Service WHERE CoaId IN
(
SELECT Id FROM Bean.ChartOfAccount WHERE AccountTypeId IN
(SELECT Id FROM Bean.AccountType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo))
)
)
)
)
)
)
)

DELETE FROM WorkFlow.ScheduleTask WHERE ScheduleDetailId IN
(
SELECT Id FROM WorkFlow.ScheduleDetail WHERE MasterId IN
(
SELECT Id FROM WorkFlow.Schedule WHERE CaseId IN
(
SELECT Id FROM WorkFlow.CaseGroup WHERE OpportunityId IN
(
SELECT Id FROM ClientCursor.Opportunity WHERE ServiceId IN
(
SELECT Id FROM Common.Service WHERE CoaId IN
(
SELECT Id FROM Bean.ChartOfAccount WHERE AccountTypeId IN
(SELECT Id FROM Bean.AccountType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo))
)
)
)
)
)
)

DELETE FROM WorkFlow.ScheduleDetail WHERE MasterId IN
(
SELECT Id FROM WorkFlow.Schedule WHERE CaseId IN
(
SELECT Id FROM WorkFlow.CaseGroup WHERE OpportunityId IN
(
SELECT Id FROM ClientCursor.Opportunity WHERE ServiceId IN
(
SELECT Id FROM Common.Service WHERE CoaId IN
(
SELECT Id FROM Bean.ChartOfAccount WHERE AccountTypeId IN
(SELECT Id FROM Bean.AccountType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo))
)
)
)
)
)

DELETE FROM WorkFlow.Schedule WHERE CaseId IN
(
SELECT Id FROM WorkFlow.CaseGroup WHERE OpportunityId IN
(
SELECT Id FROM ClientCursor.Opportunity WHERE ServiceId IN
(
SELECT Id FROM Common.Service WHERE CoaId IN
(
SELECT Id FROM Bean.ChartOfAccount WHERE AccountTypeId IN
(SELECT Id FROM Bean.AccountType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo))
)
)
)
)

DELETE FROM WorkFlow.ScheduleTaskNew WHERE ScheduleDetailId IN
(
SELECT Id FROM WorkFlow.ScheduleDetailNew WHERE MasterId IN
(
SELECT Id FROM WorkFlow.ScheduleNew WHERE CaseId IN
(
SELECT Id FROM WorkFlow.CaseGroup WHERE OpportunityId IN
(
SELECT Id FROM ClientCursor.Opportunity WHERE ServiceId IN
(
SELECT Id FROM Common.Service WHERE CoaId IN
(
SELECT Id FROM Bean.ChartOfAccount WHERE AccountTypeId IN
(SELECT Id FROM Bean.AccountType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo))
)
)
)
)
)
)

DELETE FROM WorkFlow.ScheduleDetailNew WHERE MasterId IN
(
SELECT Id FROM WorkFlow.ScheduleNew WHERE CaseId IN
(
SELECT Id FROM WorkFlow.CaseGroup WHERE OpportunityId IN
(
SELECT Id FROM ClientCursor.Opportunity WHERE ServiceId IN
(
SELECT Id FROM Common.Service WHERE CoaId IN
(
SELECT Id FROM Bean.ChartOfAccount WHERE AccountTypeId IN
(SELECT Id FROM Bean.AccountType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo))
)
)
)
)
)

DELETE FROM WorkFlow.ScheduleNew WHERE CaseId IN
(
SELECT Id FROM WorkFlow.CaseGroup WHERE OpportunityId IN
(
SELECT Id FROM ClientCursor.Opportunity WHERE ServiceId IN
(
SELECT Id FROM Common.Service WHERE CoaId IN
(
SELECT Id FROM Bean.ChartOfAccount WHERE AccountTypeId IN
(SELECT Id FROM Bean.AccountType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo))
)
)
)
)

DELETE FROM WorkFlow.ScheduleTaskDetail WHERE ScheduleTaskId IN
(
SELECT Id FROM WorkFlow.ScheduleTask WHERE CaseId IN
(
SELECT Id FROM WorkFlow.CaseGroup WHERE OpportunityId IN
(
SELECT Id FROM ClientCursor.Opportunity WHERE ServiceId IN
(
SELECT Id FROM Common.Service WHERE CoaId IN
(
SELECT Id FROM Bean.ChartOfAccount WHERE AccountTypeId IN
(SELECT Id FROM Bean.AccountType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo))
)
)
)
)
)

DELETE FROM WorkFlow.ScheduleTask WHERE CaseId IN
(
SELECT Id FROM WorkFlow.CaseGroup WHERE OpportunityId IN
(
SELECT Id FROM ClientCursor.Opportunity WHERE ServiceId IN
(
SELECT Id FROM Common.Service WHERE CoaId IN
(
SELECT Id FROM Bean.ChartOfAccount WHERE AccountTypeId IN
(SELECT Id FROM Bean.AccountType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo))
)
)
)
)

DELETE FROM WorkFlow.ScheduleTaskNew WHERE CaseId IN
(
SELECT Id FROM WorkFlow.CaseGroup WHERE OpportunityId IN
(
SELECT Id FROM ClientCursor.Opportunity WHERE ServiceId IN
(
SELECT Id FROM Common.Service WHERE CoaId IN
(
SELECT Id FROM Bean.ChartOfAccount WHERE AccountTypeId IN
(SELECT Id FROM Bean.AccountType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo))
)
)
)
)
-----------============ CASEGROUP ==================
DELETE FROM WorkFlow.CaseGroup WHERE OpportunityId IN
(
SELECT Id FROM ClientCursor.Opportunity WHERE ServiceId IN
(
SELECT Id FROM Common.Service WHERE CoaId IN
(
SELECT Id FROM Bean.ChartOfAccount WHERE AccountTypeId IN
(SELECT Id FROM Bean.AccountType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo))
)
)
)

DELETE FROM ClientCursor.Opportunity WHERE ServiceId IN
(
SELECT Id FROM Common.Service WHERE CoaId IN
(
SELECT Id FROM Bean.ChartOfAccount WHERE AccountTypeId IN
(SELECT Id FROM Bean.AccountType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo))
)
)

DELETE FROM Common.CompanyService WHERE ServiceId IN
(
SELECT Id FROM Common.Service WHERE CoaId IN
(
SELECT Id FROM Bean.ChartOfAccount WHERE AccountTypeId IN
(SELECT Id FROM Bean.AccountType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo))
)
)

DELETE FROM Common.DesignationHourlyRate WHERE ServiceId IN
(
SELECT Id FROM Common.Service WHERE CoaId IN
(
SELECT Id FROM Bean.ChartOfAccount WHERE AccountTypeId IN
(SELECT Id FROM Bean.AccountType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo))
)
)

DELETE FROM Common.Milestone WHERE ServiceId IN
(
SELECT Id FROM Common.Service WHERE CoaId IN
(
SELECT Id FROM Bean.ChartOfAccount WHERE AccountTypeId IN
(SELECT Id FROM Bean.AccountType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo))
)
)

---------SELECT * FROM Common.ServiceRate_ToBeDeleted ---> No Data in Table

DELETE FROM Common.ServiceRecuringSettings WHERE ServiceId IN
(
SELECT Id FROM Common.Service WHERE CoaId IN
(
SELECT Id FROM Bean.ChartOfAccount WHERE AccountTypeId IN
(SELECT Id FROM Bean.AccountType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo))
)
)

-------SELECT * FROM Common.ServiceTemplate_ToBeDeleted ---> No Data in Table

DELETE FROM Common.Task WHERE ServiceId IN
(
SELECT Id FROM Common.Service WHERE CoaId IN
(
SELECT Id FROM Bean.ChartOfAccount WHERE AccountTypeId IN
(SELECT Id FROM Bean.AccountType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo))
)
)

------------============================================================ CASE GROUP =================================================================

DELETE FROM Common.TimeLogDetailSplit WHERE TimelogDetailId IN
(
SELECT Id FROM Common.TimeLogDetail WHERE TimeLogScheduleId IN
(
SELECT Id FROM Common.TimeLogSchedule WHERE CaseId IN
(
SELECT Id FROM WorkFlow.CaseGroup WHERE ServiceId IN
(
SELECT Id FROM Common.Service WHERE CoaId IN
(
SELECT Id FROM Bean.ChartOfAccount WHERE AccountTypeId IN
(SELECT Id FROM Bean.AccountType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo))
)
)
)
)
)

DELETE FROM Common.TimeLogDetail WHERE TimeLogScheduleId IN
(
SELECT Id FROM Common.TimeLogSchedule WHERE CaseId IN
(
SELECT Id FROM WorkFlow.CaseGroup WHERE ServiceId IN
(
SELECT Id FROM Common.Service WHERE CoaId IN
(
SELECT Id FROM Bean.ChartOfAccount WHERE AccountTypeId IN
(SELECT Id FROM Bean.AccountType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo))
)
)
)
)

DELETE FROM Common.TimeLogSchedule WHERE CaseId IN
(
SELECT Id FROM WorkFlow.CaseGroup WHERE ServiceId IN
(
SELECT Id FROM Common.Service WHERE CoaId IN
(
SELECT Id FROM Bean.ChartOfAccount WHERE AccountTypeId IN
(SELECT Id FROM Bean.AccountType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo))
)
)
)

DELETE FROM HR.BankFileDetail WHERE TypeId IN
(
SELECT Id FROM HR.EmployeeClaim1 WHERE CaseGroupId IN
(
SELECT Id FROM WorkFlow.CaseGroup WHERE ServiceId IN
(
SELECT Id FROM Common.Service WHERE CoaId IN
(
SELECT Id FROM Bean.ChartOfAccount WHERE AccountTypeId IN
(SELECT Id FROM Bean.AccountType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo))
)
)
)
)

DELETE FROM HR.EmployeeClaimDetail WHERE EmployeeClaimId IN
(
SELECT Id FROM HR.EmployeeClaim1 WHERE CaseGroupId IN
(
SELECT Id FROM WorkFlow.CaseGroup WHERE ServiceId IN
(
SELECT Id FROM Common.Service WHERE CoaId IN
(
SELECT Id FROM Bean.ChartOfAccount WHERE AccountTypeId IN
(SELECT Id FROM Bean.AccountType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo))
)
)
)
)

DELETE FROM HR.EmployeeClaim1 WHERE CaseGroupId IN
(
SELECT Id FROM WorkFlow.CaseGroup WHERE ServiceId IN
(
SELECT Id FROM Common.Service WHERE CoaId IN
(
SELECT Id FROM Bean.ChartOfAccount WHERE AccountTypeId IN
(SELECT Id FROM Bean.AccountType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo))
)
)
)

DELETE FROM WorkFlow.CaseAmendDateOfCompletion WHERE CaseId IN
(
SELECT Id FROM WorkFlow.CaseGroup WHERE ServiceId IN
(
SELECT Id FROM Common.Service WHERE CoaId IN
(
SELECT Id FROM Bean.ChartOfAccount WHERE AccountTypeId IN
(SELECT Id FROM Bean.AccountType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo))
)
)
)

DELETE FROM WorkFlow.CaseDesignation WHERE CaseId IN
(
SELECT Id FROM WorkFlow.CaseGroup WHERE ServiceId IN
(
SELECT Id FROM Common.Service WHERE CoaId IN
(
SELECT Id FROM Bean.ChartOfAccount WHERE AccountTypeId IN
(SELECT Id FROM Bean.AccountType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo))
)
)
)

-------SELECT * FROM WorkFlow.CaseDoc ----> No Data in Table

DELETE FROM Common.TimeLogDetailSplit WHERE CaseFeatureId IN
(
SELECT Id FROM WorkFlow.CaseFeature WHERE CaseId IN
(
SELECT Id FROM WorkFlow.CaseGroup WHERE ServiceId IN
(
SELECT Id FROM Common.Service WHERE CoaId IN
(
SELECT Id FROM Bean.ChartOfAccount WHERE AccountTypeId IN
(SELECT Id FROM Bean.AccountType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo))
)
)
)
)

DELETE FROM WorkFlow.ScheduleTaskDetail WHERE CaseFeatureId IN
(
SELECT Id FROM WorkFlow.CaseFeature WHERE CaseId IN
(
SELECT Id FROM WorkFlow.CaseGroup WHERE ServiceId IN
(
SELECT Id FROM Common.Service WHERE CoaId IN
(
SELECT Id FROM Bean.ChartOfAccount WHERE AccountTypeId IN
(SELECT Id FROM Bean.AccountType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo))
)
)
)
)

DELETE FROM WorkFlow.CaseFeature WHERE CaseId IN
(
SELECT Id FROM WorkFlow.CaseGroup WHERE ServiceId IN
(
SELECT Id FROM Common.Service WHERE CoaId IN
(
SELECT Id FROM Bean.ChartOfAccount WHERE AccountTypeId IN
(SELECT Id FROM Bean.AccountType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo))
)
)
)

DELETE FROM WorkFlow.CaseIncharge WHERE CaseId IN
(
SELECT Id FROM WorkFlow.CaseGroup WHERE ServiceId IN
(
SELECT Id FROM Common.Service WHERE CoaId IN
(
SELECT Id FROM Bean.ChartOfAccount WHERE AccountTypeId IN
(SELECT Id FROM Bean.AccountType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo))
)
)
)

DELETE FROM WorkFlow.CaseMileStone WHERE CaseId IN
(
SELECT Id FROM WorkFlow.CaseGroup WHERE ServiceId IN
(
SELECT Id FROM Common.Service WHERE CoaId IN
(
SELECT Id FROM Bean.ChartOfAccount WHERE AccountTypeId IN
(SELECT Id FROM Bean.AccountType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo))
)
)
)

----------SELECT * FROM WorkFlow.CasesAssigned ----> No Data in Table

DELETE FROM WorkFlow.CaseStatusChange WHERE CaseId IN
(
SELECT Id FROM WorkFlow.CaseGroup WHERE ServiceId IN
(
SELECT Id FROM Common.Service WHERE CoaId IN
(
SELECT Id FROM Bean.ChartOfAccount WHERE AccountTypeId IN
(SELECT Id FROM Bean.AccountType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo))
)
)
)

DELETE FROM WorkFlow.Claim WHERE CaseId IN
(
SELECT Id FROM WorkFlow.CaseGroup WHERE ServiceId IN
(
SELECT Id FROM Common.Service WHERE CoaId IN
(
SELECT Id FROM Bean.ChartOfAccount WHERE AccountTypeId IN
(SELECT Id FROM Bean.AccountType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo))
)
)
)

DELETE FROM WorkFlow.Incidental WHERE InvoiceId IN
(
SELECT Id FROM WorkFlow.Invoice WHERE CaseId IN
(
SELECT Id FROM WorkFlow.CaseGroup WHERE ServiceId IN
(
SELECT Id FROM Common.Service WHERE CoaId IN
(
SELECT Id FROM Bean.ChartOfAccount WHERE AccountTypeId IN
(SELECT Id FROM Bean.AccountType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo))
)
)
)
)

DELETE FROM WorkFlow.InvoiceDesignation WHERE InvoiceId IN
(
SELECT Id FROM WorkFlow.Invoice WHERE CaseId IN
(
SELECT Id FROM WorkFlow.CaseGroup WHERE ServiceId IN
(
SELECT Id FROM Common.Service WHERE CoaId IN
(
SELECT Id FROM Bean.ChartOfAccount WHERE AccountTypeId IN
(SELECT Id FROM Bean.AccountType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo))
)
)
)
)

-------SELECT * FROM WorkFlow.InvoiceState ----> No Data in Table

DELETE FROM WorkFlow.Invoice WHERE CaseId IN
(
SELECT Id FROM WorkFlow.CaseGroup WHERE ServiceId IN
(
SELECT Id FROM Common.Service WHERE CoaId IN
(
SELECT Id FROM Bean.ChartOfAccount WHERE AccountTypeId IN
(SELECT Id FROM Bean.AccountType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo))
)
)
)

DELETE FROM WorkFlow.InvoiceDesignation WHERE CaseId IN
(
SELECT Id FROM WorkFlow.CaseGroup WHERE ServiceId IN
(
SELECT Id FROM Common.Service WHERE CoaId IN
(
SELECT Id FROM Bean.ChartOfAccount WHERE AccountTypeId IN
(SELECT Id FROM Bean.AccountType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo))
)
)
)

DELETE FROM WorkFlow.ScheduleTaskDetail WHERE ScheduleTaskId IN
(
SELECT Id FROM WorkFlow.ScheduleTask WHERE ScheduleDetailId IN
(
SELECT Id FROM WorkFlow.ScheduleDetail WHERE MasterId IN
(
SELECT Id FROM WorkFlow.Schedule WHERE CaseId IN
(
SELECT Id FROM WorkFlow.CaseGroup WHERE ServiceId IN
(
SELECT Id FROM Common.Service WHERE CoaId IN
(
SELECT Id FROM Bean.ChartOfAccount WHERE AccountTypeId IN
(SELECT Id FROM Bean.AccountType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo))
)
)
)
)
)
)

DELETE FROM WorkFlow.ScheduleTask WHERE ScheduleDetailId IN
(
SELECT Id FROM WorkFlow.ScheduleDetail WHERE MasterId IN
(
SELECT Id FROM WorkFlow.Schedule WHERE CaseId IN
(
SELECT Id FROM WorkFlow.CaseGroup WHERE ServiceId IN
(
SELECT Id FROM Common.Service WHERE CoaId IN
(
SELECT Id FROM Bean.ChartOfAccount WHERE AccountTypeId IN
(SELECT Id FROM Bean.AccountType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo))
)
)
)
)
)

DELETE FROM WorkFlow.ScheduleDetail WHERE MasterId IN
(
SELECT Id FROM WorkFlow.Schedule WHERE CaseId IN
(
SELECT Id FROM WorkFlow.CaseGroup WHERE ServiceId IN
(
SELECT Id FROM Common.Service WHERE CoaId IN
(
SELECT Id FROM Bean.ChartOfAccount WHERE AccountTypeId IN
(SELECT Id FROM Bean.AccountType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo))
)
)
)
)

DELETE FROM WorkFlow.Schedule WHERE CaseId IN
(
SELECT Id FROM WorkFlow.CaseGroup WHERE ServiceId IN
(
SELECT Id FROM Common.Service WHERE CoaId IN
(
SELECT Id FROM Bean.ChartOfAccount WHERE AccountTypeId IN
(SELECT Id FROM Bean.AccountType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo))
)
)
)


DELETE FROM WorkFlow.ScheduleTaskNew WHERE ScheduleDetailId IN
(
SELECT Id FROM WorkFlow.ScheduleDetailNew WHERE MasterId IN
(
SELECT Id FROM WorkFlow.ScheduleNew WHERE CaseId IN
(
SELECT Id FROM WorkFlow.CaseGroup WHERE ServiceId IN
(
SELECT Id FROM Common.Service WHERE CoaId IN
(
SELECT Id FROM Bean.ChartOfAccount WHERE AccountTypeId IN
(SELECT Id FROM Bean.AccountType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo))
)
)
)
)
)


DELETE FROM WorkFlow.ScheduleDetailNew WHERE MasterId IN
(
SELECT Id FROM WorkFlow.ScheduleNew WHERE CaseId IN
(
SELECT Id FROM WorkFlow.CaseGroup WHERE ServiceId IN
(
SELECT Id FROM Common.Service WHERE CoaId IN
(
SELECT Id FROM Bean.ChartOfAccount WHERE AccountTypeId IN
(SELECT Id FROM Bean.AccountType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo))
)
)
)
)

DELETE FROM WorkFlow.ScheduleNew WHERE CaseId IN
(
SELECT Id FROM WorkFlow.CaseGroup WHERE ServiceId IN
(
SELECT Id FROM Common.Service WHERE CoaId IN
(
SELECT Id FROM Bean.ChartOfAccount WHERE AccountTypeId IN
(SELECT Id FROM Bean.AccountType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo))
)
)
)


DELETE FROM WorkFlow.ScheduleTaskDetail WHERE ScheduleTaskId IN
(
SELECT Id FROM WorkFlow.ScheduleTask WHERE CaseId IN
(
SELECT Id FROM WorkFlow.CaseGroup WHERE ServiceId IN
(
SELECT Id FROM Common.Service WHERE CoaId IN
(
SELECT Id FROM Bean.ChartOfAccount WHERE AccountTypeId IN
(SELECT Id FROM Bean.AccountType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo))
)
)
)
)


DELETE FROM WorkFlow.ScheduleTask WHERE CaseId IN
(
SELECT Id FROM WorkFlow.CaseGroup WHERE ServiceId IN
(
SELECT Id FROM Common.Service WHERE CoaId IN
(
SELECT Id FROM Bean.ChartOfAccount WHERE AccountTypeId IN
(SELECT Id FROM Bean.AccountType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo))
)
)
)


DELETE FROM WorkFlow.ScheduleTaskNew WHERE CaseId IN
(
SELECT Id FROM WorkFlow.CaseGroup WHERE ServiceId IN
(
SELECT Id FROM Common.Service WHERE CoaId IN
(
SELECT Id FROM Bean.ChartOfAccount WHERE AccountTypeId IN
(SELECT Id FROM Bean.AccountType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo))
)
)
)


DELETE FROM WorkFlow.CaseGroup WHERE ServiceId IN
(
SELECT Id FROM Common.Service WHERE CoaId IN
(
SELECT Id FROM Bean.ChartOfAccount WHERE AccountTypeId IN
(SELECT Id FROM Bean.AccountType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo))
)
)

-------------============================================================== CASE GROUP ==================================================================


DELETE FROM Common.Service WHERE CoaId IN
(
SELECT Id FROM Bean.ChartOfAccount WHERE AccountTypeId IN
(SELECT Id FROM Bean.AccountType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo))
)

DELETE FROM Common.XeroCOADetail WHERE BeanCOAId IN
(
SELECT Id FROM Bean.ChartOfAccount WHERE AccountTypeId IN
(SELECT Id FROM Bean.AccountType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo))
)

DELETE FROM Bean.ChartOfAccount WHERE AccountTypeId IN
(SELECT Id FROM Bean.AccountType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo))

------SELECT * FROM Common.XeroAccountTypeDetail -----> No Data in Table

DELETE FROM Bean.AccountType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)

----------------//////////////////////////////////////////////////////////////////////// Bean.BankReconciliation \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

DELETE FROM Bean.BankReconciliationDetail WHERE BankReconciliationId IN
(
SELECT Id FROM Bean.BankReconciliation WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)

DELETE FROM Bean.BankReconciliation WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)

--------------------//////////////////////////////////////////////////////////////////////// Bean.BankReconciliationSetting \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

------------------SELECT * FROM Bean.BankReconciliationSetting WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo) ----> No Data in Table

--------------------//////////////////////////////////////////////////////////////////////// Bean.BankTransfer \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

DELETE FROM Bean.BankTransferDetail WHERE BankTransferId IN
(
SELECT Id FROM Bean.BankTransfer WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)

DELETE FROM Bean.SettlementDetail WHERE BankTransferId IN
(
SELECT Id FROM Bean.BankTransfer WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)

DELETE FROM Bean.BankTransfer WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)

--------------------//////////////////////////////////////////////////////////////////////// Bean.Bill \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

DELETE FROM Bean.BillCreditMemoDetail WHERE CreditMemoId IN
(
SELECT Id FROM Bean.BillCreditMemo WHERE BillId IN
(
SELECT Id FROM Bean.Bill WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)

----------------SELECT * FROM Bean.BillCreditMemoGSTDetails  ----> No Data in Table

DELETE FROM Bean.BillCreditMemo WHERE BillId IN
(
SELECT Id FROM Bean.Bill WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)

------------DELETE FROM Bean.BillCreditMemoDetail WHERE BillDetailId IN  ----> No Data in Table
------------(
------------SELECT Id FROM Bean.BillDetail WHERE BillId IN
------------(
------------SELECT Id FROM Bean.Bill WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
------------)
------------)

DELETE FROM Bean.BillDetail WHERE BillId IN
(
SELECT Id FROM Bean.Bill WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)

----------DELETE FROM Bean.BillGSTDetail WHERE BillId IN ----> No Data in Table
----------(
----------SELECT Id FROM Bean.Bill WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
----------)

DELETE FROM Bean.Bill WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)

--------------------//////////////////////////////////////////////////////////////////////// Bean.BillCreditMemo \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

------------------SELECT * FROM Bean.BillCreditMemo WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo) ----> No Data in Table

--------------------//////////////////////////////////////////////////////////////////////// Bean.CashSale \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

DELETE FROM Bean.CashSaleDetail WHERE CashSaleId IN
(
SELECT Id FROM Bean.CashSale WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)

DELETE FROM Bean.CashSale WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)

--------------------//////////////////////////////////////////////////////////////////////// Bean.ChartOfAccount \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

DELETE FROM Bean.BankReconciliationDetail WHERE BankReconciliationId IN
(
SELECT Id FROM Bean.BankReconciliation WHERE COAId IN
(
SELECT Id FROM Bean.ChartOfAccount WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)

DELETE FROM Bean.BankReconciliation WHERE COAId IN
(
SELECT Id FROM Bean.ChartOfAccount WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)

DELETE FROM Bean.BankTransferDetail WHERE COAId IN
(
SELECT Id FROM Bean.ChartOfAccount WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)


----------DELETE FROM Bean.BillCreditMemoDetail WHERE BillDetailId IN---> No Data in Table
----------(
----------SELECT Id FROM Bean.BillDetail WHERE COAId IN 
----------(
----------SELECT Id FROM Bean.ChartOfAccount WHERE AccountTypeId IN
----------(SELECT Id FROM Bean.AccountType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo))
----------)
----------)

DELETE FROM Bean.BillDetail WHERE COAId IN 
(
SELECT Id FROM Bean.ChartOfAccount WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)

DELETE FROM Bean.CashSaleDetail WHERE CashSaleId IN
(
SELECT Id FROM Bean.CashSale WHERE COAId IN
(
SELECT Id FROM Bean.ChartOfAccount WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)

DELETE FROM Bean.CashSale WHERE COAId IN
(
SELECT Id FROM Bean.ChartOfAccount WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)

DELETE FROM Bean.CashSaleDetail WHERE COAId IN
(
SELECT Id FROM Bean.ChartOfAccount WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)

DELETE FROM Bean.COAMappingDetail WHERE CustCOAId IN
(
SELECT Id FROM Bean.ChartOfAccount WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)

DELETE FROM Bean.COAMappingDetail WHERE VenCOAId IN
(
SELECT Id FROM Bean.ChartOfAccount WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)

DELETE FROM Bean.CreditMemoDetail WHERE COAId IN
(
SELECT Id FROM Bean.ChartOfAccount WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)

DELETE FROM Bean.DebitNoteDetail WHERE COAId IN
(
SELECT Id FROM Bean.ChartOfAccount WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)

DELETE FROM Bean.GLClearingDetail WHERE GLClearingId IN
(
SELECT Id FROM Bean.GLClearing WHERE COAId IN
(
SELECT Id FROM Bean.ChartOfAccount WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)

DELETE FROM Bean.GLClearing WHERE COAId IN
(
SELECT Id FROM Bean.ChartOfAccount WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)

DELETE FROM Bean.InvoiceDetail WHERE COAId IN
(
SELECT Id FROM Bean.ChartOfAccount WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)

DELETE FROM Bean.CashSaleDetail WHERE ItemId IN
(
SELECT Id FROM Bean.Item WHERE COAId IN 
(
SELECT Id FROM Bean.ChartOfAccount WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)

DELETE FROM Bean.InvoiceDetail WHERE ItemId IN
(
SELECT Id FROM Bean.Item WHERE COAId IN 
(
SELECT Id FROM Bean.ChartOfAccount WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)

----------SELECT * FROM Bean.JournalLedger_ToBeDeleted ----> No Data in Table

DELETE FROM Bean.Item WHERE COAId IN 
(
SELECT Id FROM Bean.ChartOfAccount WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)


DELETE FROM Bean.OpeningBalanceDetailLineItem WHERE OpeningBalanceDetailId IN
(
SELECT Id FROM Bean.OpeningBalanceDetail WHERE COAId IN
(
SELECT Id FROM Bean.ChartOfAccount WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)

DELETE FROM Bean.OpeningBalanceDetail WHERE COAId IN
(
SELECT Id FROM Bean.ChartOfAccount WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)

DELETE FROM Bean.OpeningBalanceDetailLineItem WHERE COAId IN
(
SELECT Id FROM Bean.ChartOfAccount WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)

DELETE FROM Bean.PaymentDetail WHERE PaymentId IN
(
SELECT Id FROM Bean.Payment WHERE COAId IN
(
SELECT Id FROM Bean.ChartOfAccount WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)

DELETE FROM Bean.Payment WHERE COAId IN
(
SELECT Id FROM Bean.ChartOfAccount WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)

DELETE FROM Bean.ReceiptBalancingItem WHERE ReceiptId IN
(
SELECT Id FROM Bean.Receipt WHERE COAId IN 
(
SELECT Id FROM Bean.ChartOfAccount WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)

DELETE FROM Bean.ReceiptDetail WHERE ReceiptId IN
(
SELECT Id FROM Bean.Receipt WHERE COAId IN 
(
SELECT Id FROM Bean.ChartOfAccount WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)

DELETE FROM Bean.ReceiptGSTDetail WHERE ReceiptId IN 
(
SELECT Id FROM Bean.Receipt WHERE COAId IN 
(
SELECT Id FROM Bean.ChartOfAccount WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)

DELETE FROM Bean.Receipt WHERE COAId IN 
(
SELECT Id FROM Bean.ChartOfAccount WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)

DELETE FROM Bean.ReceiptBalancingItem WHERE COAId IN
(
SELECT Id FROM Bean.ChartOfAccount WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)

DELETE FROM Bean.WithDrawalDetail WHERE WithdrawalId IN
(
SELECT Id FROM Bean.WithDrawal WHERE COAId IN
(
SELECT Id FROM Bean.ChartOfAccount WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)

DELETE FROM Bean.WithDrawal WHERE COAId IN
(
SELECT Id FROM Bean.ChartOfAccount WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)

DELETE FROM Bean.WithDrawalDetail WHERE COAId IN
(
SELECT Id FROM Bean.ChartOfAccount WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)

DELETE FROM HR.CompanyPayrollSettingsDetail WHERE BankId IN
(
SELECT Id FROM Common.Bank WHERE COAId IN
(
SELECT Id FROM Bean.ChartOfAccount WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)

DELETE FROM Common.Bank WHERE COAId IN
(
SELECT Id FROM Bean.ChartOfAccount WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)


DELETE FROM ClientCursor.OpportunityDesignation WHERE OpportunityId IN
(
SELECT Id FROM ClientCursor.Opportunity WHERE ServiceId IN
(
SELECT Id FROM Common.Service WHERE CoaId IN
(
SELECT Id FROM Bean.ChartOfAccount WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)

------------SELECT * FROM ClientCursor.[OpportunityDoc] ----> No Data in Table

DELETE FROM ClientCursor.OpportunityHistory WHERE OpportunityId IN
(
SELECT Id FROM ClientCursor.Opportunity WHERE ServiceId IN
(
SELECT Id FROM Common.Service WHERE CoaId IN
(
SELECT Id FROM Bean.ChartOfAccount WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)

DELETE FROM ClientCursor.OpportunityIncharge WHERE OpportunityId IN
(
SELECT Id FROM ClientCursor.Opportunity WHERE ServiceId IN
(
SELECT Id FROM Common.Service WHERE CoaId IN
(
SELECT Id FROM Bean.ChartOfAccount WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)

DELETE FROM ClientCursor.OpportunityStatusChange WHERE OpportunityId IN
(
SELECT Id FROM ClientCursor.Opportunity WHERE ServiceId IN
(
SELECT Id FROM Common.Service WHERE CoaId IN
(
SELECT Id FROM Bean.ChartOfAccount WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)

----------SELECT * FROM ClientCursor.OpportunityTermsCondition_ToBeDeleted ---> No Data in Table

DELETE FROM ClientCursor.QuotationDetailTemplate WHERE QuotationDetailId IN
(
SELECT Id FROM ClientCursor.QuotationDetail WHERE OpportunityId IN
(
SELECT Id FROM ClientCursor.Opportunity WHERE ServiceId IN
(
SELECT Id FROM Common.Service WHERE CoaId IN
(
SELECT Id FROM Bean.ChartOfAccount WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)
)

DELETE FROM ClientCursor.QuotationDetail WHERE OpportunityId IN
(
SELECT Id FROM ClientCursor.Opportunity WHERE ServiceId IN
(
SELECT Id FROM Common.Service WHERE CoaId IN
(
SELECT Id FROM Bean.ChartOfAccount WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)

DELETE FROM Common.TimeLogDetailSplit WHERE TimelogDetailId IN
(
SELECT Id FROM Common.TimeLogDetail WHERE TimeLogScheduleId IN
(
SELECT Id FROM Common.TimeLogSchedule WHERE CaseId IN
(
SELECT Id FROM WorkFlow.CaseGroup WHERE OpportunityId IN
(
SELECT Id FROM ClientCursor.Opportunity WHERE ServiceId IN
(
SELECT Id FROM Common.Service WHERE CoaId IN
(
SELECT Id FROM Bean.ChartOfAccount WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)
)
)
)


DELETE FROM Common.TimeLogDetail WHERE TimeLogScheduleId IN
(
SELECT Id FROM Common.TimeLogSchedule WHERE CaseId IN
(
SELECT Id FROM WorkFlow.CaseGroup WHERE OpportunityId IN
(
SELECT Id FROM ClientCursor.Opportunity WHERE ServiceId IN
(
SELECT Id FROM Common.Service WHERE CoaId IN
(
SELECT Id FROM Bean.ChartOfAccount WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)
)
)

DELETE FROM Common.TimeLogSchedule WHERE CaseId IN
(
SELECT Id FROM WorkFlow.CaseGroup WHERE OpportunityId IN
(
SELECT Id FROM ClientCursor.Opportunity WHERE ServiceId IN
(
SELECT Id FROM Common.Service WHERE CoaId IN
(
SELECT Id FROM Bean.ChartOfAccount WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)
)

DELETE FROM HR.BankFileDetail WHERE TypeId IN
(
SELECT Id FROM HR.EmployeeClaim1 WHERE CaseGroupId IN
(
SELECT Id FROM WorkFlow.CaseGroup WHERE OpportunityId IN
(
SELECT Id FROM ClientCursor.Opportunity WHERE ServiceId IN
(
SELECT Id FROM Common.Service WHERE CoaId IN
(
SELECT Id FROM Bean.ChartOfAccount WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)
)
)

DELETE FROM HR.EmployeeClaimDetail WHERE EmployeeClaimId IN
(
SELECT Id FROM HR.EmployeeClaim1 WHERE CaseGroupId IN
(
SELECT Id FROM WorkFlow.CaseGroup WHERE OpportunityId IN
(
SELECT Id FROM ClientCursor.Opportunity WHERE ServiceId IN
(
SELECT Id FROM Common.Service WHERE CoaId IN
(
SELECT Id FROM Bean.ChartOfAccount WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)
)
)

DELETE FROM HR.EmployeeClaim1 WHERE CaseGroupId IN
(
SELECT Id FROM WorkFlow.CaseGroup WHERE OpportunityId IN
(
SELECT Id FROM ClientCursor.Opportunity WHERE ServiceId IN
(
SELECT Id FROM Common.Service WHERE CoaId IN
(
SELECT Id FROM Bean.ChartOfAccount WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)
)

DELETE FROM WorkFlow.CaseAmendDateOfCompletion WHERE CaseId IN
(
SELECT Id FROM WorkFlow.CaseGroup WHERE OpportunityId IN
(
SELECT Id FROM ClientCursor.Opportunity WHERE ServiceId IN
(
SELECT Id FROM Common.Service WHERE CoaId IN
(
SELECT Id FROM Bean.ChartOfAccount WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)
)

DELETE FROM WorkFlow.CaseDesignation WHERE CaseId IN
(
SELECT Id FROM WorkFlow.CaseGroup WHERE OpportunityId IN
(
SELECT Id FROM ClientCursor.Opportunity WHERE ServiceId IN
(
SELECT Id FROM Common.Service WHERE CoaId IN
(
SELECT Id FROM Bean.ChartOfAccount WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)
)

------------SELECT * FROM WorkFlow.CaseDoc ----> No Data in Table

DELETE FROM Common.TimeLogDetailSplit WHERE CaseFeatureId IN
(
SELECT Id FROM WorkFlow.CaseFeature WHERE CaseId IN
(
SELECT Id FROM WorkFlow.CaseGroup WHERE OpportunityId IN
(
SELECT Id FROM ClientCursor.Opportunity WHERE ServiceId IN
(
SELECT Id FROM Common.Service WHERE CoaId IN
(
SELECT Id FROM Bean.ChartOfAccount WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)
)
)

DELETE FROM WorkFlow.ScheduleTaskDetail WHERE CaseFeatureId IN
(
SELECT Id FROM WorkFlow.CaseFeature WHERE CaseId IN
(
SELECT Id FROM WorkFlow.CaseGroup WHERE OpportunityId IN
(
SELECT Id FROM ClientCursor.Opportunity WHERE ServiceId IN
(
SELECT Id FROM Common.Service WHERE CoaId IN
(
SELECT Id FROM Bean.ChartOfAccount WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)
)
)

DELETE FROM WorkFlow.CaseFeature WHERE CaseId IN
(
SELECT Id FROM WorkFlow.CaseGroup WHERE OpportunityId IN
(
SELECT Id FROM ClientCursor.Opportunity WHERE ServiceId IN
(
SELECT Id FROM Common.Service WHERE CoaId IN
(
SELECT Id FROM Bean.ChartOfAccount WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)
)

DELETE FROM WorkFlow.CaseIncharge WHERE CaseId IN
(
SELECT Id FROM WorkFlow.CaseGroup WHERE OpportunityId IN
(
SELECT Id FROM ClientCursor.Opportunity WHERE ServiceId IN
(
SELECT Id FROM Common.Service WHERE CoaId IN
(
SELECT Id FROM Bean.ChartOfAccount WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)
)

DELETE FROM WorkFlow.CaseMileStone WHERE CaseId IN
(
SELECT Id FROM WorkFlow.CaseGroup WHERE OpportunityId IN
(
SELECT Id FROM ClientCursor.Opportunity WHERE ServiceId IN
(
SELECT Id FROM Common.Service WHERE CoaId IN
(
SELECT Id FROM Bean.ChartOfAccount WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)
)

-----------SELECT * FROM WorkFlow.CasesAssigned ----> No Data in Table

DELETE FROM WorkFlow.CaseStatusChange WHERE CaseId IN
(
SELECT Id FROM WorkFlow.CaseGroup WHERE OpportunityId IN
(
SELECT Id FROM ClientCursor.Opportunity WHERE ServiceId IN
(
SELECT Id FROM Common.Service WHERE CoaId IN
(
SELECT Id FROM Bean.ChartOfAccount WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)
)

DELETE FROM WorkFlow.Claim WHERE CaseId IN
(
SELECT Id FROM WorkFlow.CaseGroup WHERE OpportunityId IN
(
SELECT Id FROM ClientCursor.Opportunity WHERE ServiceId IN
(
SELECT Id FROM Common.Service WHERE CoaId IN
(
SELECT Id FROM Bean.ChartOfAccount WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)
)

DELETE FROM WorkFlow.Incidental WHERE InvoiceId IN
(
SELECT Id FROM WorkFlow.Invoice WHERE CaseId IN
(
SELECT Id FROM WorkFlow.CaseGroup WHERE OpportunityId IN
(
SELECT Id FROM ClientCursor.Opportunity WHERE ServiceId IN
(
SELECT Id FROM Common.Service WHERE CoaId IN
(
SELECT Id FROM Bean.ChartOfAccount WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)
)
)

DELETE FROM WorkFlow.InvoiceDesignation WHERE InvoiceId IN
(
SELECT Id FROM WorkFlow.Invoice WHERE CaseId IN
(
SELECT Id FROM WorkFlow.CaseGroup WHERE OpportunityId IN
(
SELECT Id FROM ClientCursor.Opportunity WHERE ServiceId IN
(
SELECT Id FROM Common.Service WHERE CoaId IN
(
SELECT Id FROM Bean.ChartOfAccount WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)
)
)

----------SELECT * FROM WorkFlow.InvoiceState ----> No Data in Table

DELETE FROM WorkFlow.Invoice WHERE CaseId IN
(
SELECT Id FROM WorkFlow.CaseGroup WHERE OpportunityId IN
(
SELECT Id FROM ClientCursor.Opportunity WHERE ServiceId IN
(
SELECT Id FROM Common.Service WHERE CoaId IN
(
SELECT Id FROM Bean.ChartOfAccount WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)
)

DELETE FROM WorkFlow.InvoiceDesignation WHERE CaseId IN
(
SELECT Id FROM WorkFlow.CaseGroup WHERE OpportunityId IN
(
SELECT Id FROM ClientCursor.Opportunity WHERE ServiceId IN
(
SELECT Id FROM Common.Service WHERE CoaId IN
(
SELECT Id FROM Bean.ChartOfAccount WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)
)

DELETE FROM WorkFlow.ScheduleTaskDetail WHERE ScheduleTaskId IN
(
SELECT Id FROM WorkFlow.ScheduleTask WHERE ScheduleDetailId IN
(
SELECT Id FROM WorkFlow.ScheduleDetail WHERE MasterId IN
(
SELECT Id FROM WorkFlow.Schedule WHERE CaseId IN
(
SELECT Id FROM WorkFlow.CaseGroup WHERE OpportunityId IN
(
SELECT Id FROM ClientCursor.Opportunity WHERE ServiceId IN
(
SELECT Id FROM Common.Service WHERE CoaId IN
(
SELECT Id FROM Bean.ChartOfAccount WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)
)
)
)
)

DELETE FROM WorkFlow.ScheduleTask WHERE ScheduleDetailId IN
(
SELECT Id FROM WorkFlow.ScheduleDetail WHERE MasterId IN
(
SELECT Id FROM WorkFlow.Schedule WHERE CaseId IN
(
SELECT Id FROM WorkFlow.CaseGroup WHERE OpportunityId IN
(
SELECT Id FROM ClientCursor.Opportunity WHERE ServiceId IN
(
SELECT Id FROM Common.Service WHERE CoaId IN
(
SELECT Id FROM Bean.ChartOfAccount WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)
)
)
)

DELETE FROM WorkFlow.ScheduleDetail WHERE MasterId IN
(
SELECT Id FROM WorkFlow.Schedule WHERE CaseId IN
(
SELECT Id FROM WorkFlow.CaseGroup WHERE OpportunityId IN
(
SELECT Id FROM ClientCursor.Opportunity WHERE ServiceId IN
(
SELECT Id FROM Common.Service WHERE CoaId IN
(
SELECT Id FROM Bean.ChartOfAccount WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)
)
)

DELETE FROM WorkFlow.Schedule WHERE CaseId IN
(
SELECT Id FROM WorkFlow.CaseGroup WHERE OpportunityId IN
(
SELECT Id FROM ClientCursor.Opportunity WHERE ServiceId IN
(
SELECT Id FROM Common.Service WHERE CoaId IN
(
SELECT Id FROM Bean.ChartOfAccount WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)
)

DELETE FROM WorkFlow.ScheduleTaskNew WHERE ScheduleDetailId IN
(
SELECT Id FROM WorkFlow.ScheduleDetailNew WHERE MasterId IN
(
SELECT Id FROM WorkFlow.ScheduleNew WHERE CaseId IN
(
SELECT Id FROM WorkFlow.CaseGroup WHERE OpportunityId IN
(
SELECT Id FROM ClientCursor.Opportunity WHERE ServiceId IN
(
SELECT Id FROM Common.Service WHERE CoaId IN
(
SELECT Id FROM Bean.ChartOfAccount WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)
)
)
)

DELETE FROM WorkFlow.ScheduleDetailNew WHERE MasterId IN
(
SELECT Id FROM WorkFlow.ScheduleNew WHERE CaseId IN
(
SELECT Id FROM WorkFlow.CaseGroup WHERE OpportunityId IN
(
SELECT Id FROM ClientCursor.Opportunity WHERE ServiceId IN
(
SELECT Id FROM Common.Service WHERE CoaId IN
(
SELECT Id FROM Bean.ChartOfAccount WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)
)
)

DELETE FROM WorkFlow.ScheduleNew WHERE CaseId IN
(
SELECT Id FROM WorkFlow.CaseGroup WHERE OpportunityId IN
(
SELECT Id FROM ClientCursor.Opportunity WHERE ServiceId IN
(
SELECT Id FROM Common.Service WHERE CoaId IN
(
SELECT Id FROM Bean.ChartOfAccount WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)
)

DELETE FROM WorkFlow.ScheduleTaskDetail WHERE ScheduleTaskId IN
(
SELECT Id FROM WorkFlow.ScheduleTask WHERE CaseId IN
(
SELECT Id FROM WorkFlow.CaseGroup WHERE OpportunityId IN
(
SELECT Id FROM ClientCursor.Opportunity WHERE ServiceId IN
(
SELECT Id FROM Common.Service WHERE CoaId IN
(
SELECT Id FROM Bean.ChartOfAccount WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)
)
)

DELETE FROM WorkFlow.ScheduleTask WHERE CaseId IN
(
SELECT Id FROM WorkFlow.CaseGroup WHERE OpportunityId IN
(
SELECT Id FROM ClientCursor.Opportunity WHERE ServiceId IN
(
SELECT Id FROM Common.Service WHERE CoaId IN
(
SELECT Id FROM Bean.ChartOfAccount WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)
)

DELETE FROM WorkFlow.ScheduleTaskNew WHERE CaseId IN
(
SELECT Id FROM WorkFlow.CaseGroup WHERE OpportunityId IN
(
SELECT Id FROM ClientCursor.Opportunity WHERE ServiceId IN
(
SELECT Id FROM Common.Service WHERE CoaId IN
(
SELECT Id FROM Bean.ChartOfAccount WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)
)
-----------============ CASEGROUP ==================
DELETE FROM WorkFlow.CaseGroup WHERE OpportunityId IN
(
SELECT Id FROM ClientCursor.Opportunity WHERE ServiceId IN
(
SELECT Id FROM Common.Service WHERE CoaId IN
(
SELECT Id FROM Bean.ChartOfAccount WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)

DELETE FROM ClientCursor.Opportunity WHERE ServiceId IN
(
SELECT Id FROM Common.Service WHERE CoaId IN
(
SELECT Id FROM Bean.ChartOfAccount WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)

DELETE FROM Common.CompanyService WHERE ServiceId IN
(
SELECT Id FROM Common.Service WHERE CoaId IN
(
SELECT Id FROM Bean.ChartOfAccount WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)

DELETE FROM Common.DesignationHourlyRate WHERE ServiceId IN
(
SELECT Id FROM Common.Service WHERE CoaId IN
(
SELECT Id FROM Bean.ChartOfAccount WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)

DELETE FROM Common.Milestone WHERE ServiceId IN
(
SELECT Id FROM Common.Service WHERE CoaId IN
(
SELECT Id FROM Bean.ChartOfAccount WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)

---------SELECT * FROM Common.ServiceRate_ToBeDeleted ---> No Data in Table

DELETE FROM Common.ServiceRecuringSettings WHERE ServiceId IN
(
SELECT Id FROM Common.Service WHERE CoaId IN
(
SELECT Id FROM Bean.ChartOfAccount WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)

-------SELECT * FROM Common.ServiceTemplate_ToBeDeleted ---> No Data in Table

DELETE FROM Common.Task WHERE ServiceId IN
(
SELECT Id FROM Common.Service WHERE CoaId IN
(
SELECT Id FROM Bean.ChartOfAccount WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)

------------============================================================ CASE GROUP =================================================================

DELETE FROM Common.TimeLogDetailSplit WHERE TimelogDetailId IN
(
SELECT Id FROM Common.TimeLogDetail WHERE TimeLogScheduleId IN
(
SELECT Id FROM Common.TimeLogSchedule WHERE CaseId IN
(
SELECT Id FROM WorkFlow.CaseGroup WHERE ServiceId IN
(
SELECT Id FROM Common.Service WHERE CoaId IN
(
SELECT Id FROM Bean.ChartOfAccount WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)
)
)

DELETE FROM Common.TimeLogDetail WHERE TimeLogScheduleId IN
(
SELECT Id FROM Common.TimeLogSchedule WHERE CaseId IN
(
SELECT Id FROM WorkFlow.CaseGroup WHERE ServiceId IN
(
SELECT Id FROM Common.Service WHERE CoaId IN
(
SELECT Id FROM Bean.ChartOfAccount WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)
)

DELETE FROM Common.TimeLogSchedule WHERE CaseId IN
(
SELECT Id FROM WorkFlow.CaseGroup WHERE ServiceId IN
(
SELECT Id FROM Common.Service WHERE CoaId IN
(
SELECT Id FROM Bean.ChartOfAccount WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)

DELETE FROM HR.BankFileDetail WHERE TypeId IN
(
SELECT Id FROM HR.EmployeeClaim1 WHERE CaseGroupId IN
(
SELECT Id FROM WorkFlow.CaseGroup WHERE ServiceId IN
(
SELECT Id FROM Common.Service WHERE CoaId IN
(
SELECT Id FROM Bean.ChartOfAccount WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)
)

DELETE FROM HR.EmployeeClaimDetail WHERE EmployeeClaimId IN
(
SELECT Id FROM HR.EmployeeClaim1 WHERE CaseGroupId IN
(
SELECT Id FROM WorkFlow.CaseGroup WHERE ServiceId IN
(
SELECT Id FROM Common.Service WHERE CoaId IN
(
SELECT Id FROM Bean.ChartOfAccount WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)
)

DELETE FROM HR.EmployeeClaim1 WHERE CaseGroupId IN
(
SELECT Id FROM WorkFlow.CaseGroup WHERE ServiceId IN
(
SELECT Id FROM Common.Service WHERE CoaId IN
(
SELECT Id FROM Bean.ChartOfAccount WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)

DELETE FROM WorkFlow.CaseAmendDateOfCompletion WHERE CaseId IN
(
SELECT Id FROM WorkFlow.CaseGroup WHERE ServiceId IN
(
SELECT Id FROM Common.Service WHERE CoaId IN
(
SELECT Id FROM Bean.ChartOfAccount WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)

DELETE FROM WorkFlow.CaseDesignation WHERE CaseId IN
(
SELECT Id FROM WorkFlow.CaseGroup WHERE ServiceId IN
(
SELECT Id FROM Common.Service WHERE CoaId IN
(
SELECT Id FROM Bean.ChartOfAccount WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)

-------SELECT * FROM WorkFlow.CaseDoc ----> No Data in Table

DELETE FROM Common.TimeLogDetailSplit WHERE CaseFeatureId IN
(
SELECT Id FROM WorkFlow.CaseFeature WHERE CaseId IN
(
SELECT Id FROM WorkFlow.CaseGroup WHERE ServiceId IN
(
SELECT Id FROM Common.Service WHERE CoaId IN
(
SELECT Id FROM Bean.ChartOfAccount WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)
)

DELETE FROM WorkFlow.ScheduleTaskDetail WHERE CaseFeatureId IN
(
SELECT Id FROM WorkFlow.CaseFeature WHERE CaseId IN
(
SELECT Id FROM WorkFlow.CaseGroup WHERE ServiceId IN
(
SELECT Id FROM Common.Service WHERE CoaId IN
(
SELECT Id FROM Bean.ChartOfAccount WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)
)

DELETE FROM WorkFlow.CaseFeature WHERE CaseId IN
(
SELECT Id FROM WorkFlow.CaseGroup WHERE ServiceId IN
(
SELECT Id FROM Common.Service WHERE CoaId IN
(
SELECT Id FROM Bean.ChartOfAccount WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)

DELETE FROM WorkFlow.CaseIncharge WHERE CaseId IN
(
SELECT Id FROM WorkFlow.CaseGroup WHERE ServiceId IN
(
SELECT Id FROM Common.Service WHERE CoaId IN
(
SELECT Id FROM Bean.ChartOfAccount WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)

DELETE FROM WorkFlow.CaseMileStone WHERE CaseId IN
(
SELECT Id FROM WorkFlow.CaseGroup WHERE ServiceId IN
(
SELECT Id FROM Common.Service WHERE CoaId IN
(
SELECT Id FROM Bean.ChartOfAccount WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)

----------SELECT * FROM WorkFlow.CasesAssigned ----> No Data in Table

DELETE FROM WorkFlow.CaseStatusChange WHERE CaseId IN
(
SELECT Id FROM WorkFlow.CaseGroup WHERE ServiceId IN
(
SELECT Id FROM Common.Service WHERE CoaId IN
(
SELECT Id FROM Bean.ChartOfAccount WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)

DELETE FROM WorkFlow.Claim WHERE CaseId IN
(
SELECT Id FROM WorkFlow.CaseGroup WHERE ServiceId IN
(
SELECT Id FROM Common.Service WHERE CoaId IN
(
SELECT Id FROM Bean.ChartOfAccount WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)

DELETE FROM WorkFlow.Incidental WHERE InvoiceId IN
(
SELECT Id FROM WorkFlow.Invoice WHERE CaseId IN
(
SELECT Id FROM WorkFlow.CaseGroup WHERE ServiceId IN
(
SELECT Id FROM Common.Service WHERE CoaId IN
(
SELECT Id FROM Bean.ChartOfAccount WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)
)

DELETE FROM WorkFlow.InvoiceDesignation WHERE InvoiceId IN
(
SELECT Id FROM WorkFlow.Invoice WHERE CaseId IN
(
SELECT Id FROM WorkFlow.CaseGroup WHERE ServiceId IN
(
SELECT Id FROM Common.Service WHERE CoaId IN
(
SELECT Id FROM Bean.ChartOfAccount WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)
)

-------SELECT * FROM WorkFlow.InvoiceState ----> No Data in Table

DELETE FROM WorkFlow.Invoice WHERE CaseId IN
(
SELECT Id FROM WorkFlow.CaseGroup WHERE ServiceId IN
(
SELECT Id FROM Common.Service WHERE CoaId IN
(
SELECT Id FROM Bean.ChartOfAccount WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)

DELETE FROM WorkFlow.InvoiceDesignation WHERE CaseId IN
(
SELECT Id FROM WorkFlow.CaseGroup WHERE ServiceId IN
(
SELECT Id FROM Common.Service WHERE CoaId IN
(
SELECT Id FROM Bean.ChartOfAccount WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)

DELETE FROM WorkFlow.ScheduleTaskDetail WHERE ScheduleTaskId IN
(
SELECT Id FROM WorkFlow.ScheduleTask WHERE ScheduleDetailId IN
(
SELECT Id FROM WorkFlow.ScheduleDetail WHERE MasterId IN
(
SELECT Id FROM WorkFlow.Schedule WHERE CaseId IN
(
SELECT Id FROM WorkFlow.CaseGroup WHERE ServiceId IN
(
SELECT Id FROM Common.Service WHERE CoaId IN
(
SELECT Id FROM Bean.ChartOfAccount WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)
)
)
)

DELETE FROM WorkFlow.ScheduleTask WHERE ScheduleDetailId IN
(
SELECT Id FROM WorkFlow.ScheduleDetail WHERE MasterId IN
(
SELECT Id FROM WorkFlow.Schedule WHERE CaseId IN
(
SELECT Id FROM WorkFlow.CaseGroup WHERE ServiceId IN
(
SELECT Id FROM Common.Service WHERE CoaId IN
(
SELECT Id FROM Bean.ChartOfAccount WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)
)
)

DELETE FROM WorkFlow.ScheduleDetail WHERE MasterId IN
(
SELECT Id FROM WorkFlow.Schedule WHERE CaseId IN
(
SELECT Id FROM WorkFlow.CaseGroup WHERE ServiceId IN
(
SELECT Id FROM Common.Service WHERE CoaId IN
(
SELECT Id FROM Bean.ChartOfAccount WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)
)

DELETE FROM WorkFlow.Schedule WHERE CaseId IN
(
SELECT Id FROM WorkFlow.CaseGroup WHERE ServiceId IN
(
SELECT Id FROM Common.Service WHERE CoaId IN
(
SELECT Id FROM Bean.ChartOfAccount WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)


DELETE FROM WorkFlow.ScheduleTaskNew WHERE ScheduleDetailId IN
(
SELECT Id FROM WorkFlow.ScheduleDetailNew WHERE MasterId IN
(
SELECT Id FROM WorkFlow.ScheduleNew WHERE CaseId IN
(
SELECT Id FROM WorkFlow.CaseGroup WHERE ServiceId IN
(
SELECT Id FROM Common.Service WHERE CoaId IN
(
SELECT Id FROM Bean.ChartOfAccount WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)
)
)


DELETE FROM WorkFlow.ScheduleDetailNew WHERE MasterId IN
(
SELECT Id FROM WorkFlow.ScheduleNew WHERE CaseId IN
(
SELECT Id FROM WorkFlow.CaseGroup WHERE ServiceId IN
(
SELECT Id FROM Common.Service WHERE CoaId IN
(
SELECT Id FROM Bean.ChartOfAccount WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)
)

DELETE FROM WorkFlow.ScheduleNew WHERE CaseId IN
(
SELECT Id FROM WorkFlow.CaseGroup WHERE ServiceId IN
(
SELECT Id FROM Common.Service WHERE CoaId IN
(
SELECT Id FROM Bean.ChartOfAccount WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)


DELETE FROM WorkFlow.ScheduleTaskDetail WHERE ScheduleTaskId IN
(
SELECT Id FROM WorkFlow.ScheduleTask WHERE CaseId IN
(
SELECT Id FROM WorkFlow.CaseGroup WHERE ServiceId IN
(
SELECT Id FROM Common.Service WHERE CoaId IN
(
SELECT Id FROM Bean.ChartOfAccount WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)
)


DELETE FROM WorkFlow.ScheduleTask WHERE CaseId IN
(
SELECT Id FROM WorkFlow.CaseGroup WHERE ServiceId IN
(
SELECT Id FROM Common.Service WHERE CoaId IN
(
SELECT Id FROM Bean.ChartOfAccount WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)


DELETE FROM WorkFlow.ScheduleTaskNew WHERE CaseId IN
(
SELECT Id FROM WorkFlow.CaseGroup WHERE ServiceId IN
(
SELECT Id FROM Common.Service WHERE CoaId IN
(
SELECT Id FROM Bean.ChartOfAccount WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)


DELETE FROM WorkFlow.CaseGroup WHERE ServiceId IN
(
SELECT Id FROM Common.Service WHERE CoaId IN
(
SELECT Id FROM Bean.ChartOfAccount WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)

-------------============================================================== CASE GROUP ==================================================================


DELETE FROM Common.Service WHERE CoaId IN
(
SELECT Id FROM Bean.ChartOfAccount WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)

DELETE FROM Common.XeroCOADetail WHERE BeanCOAId IN
(
SELECT Id FROM Bean.ChartOfAccount WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)

DELETE FROM Bean.ChartOfAccount WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)


--------------------//////////////////////////////////////////////////////////////////////// Bean.COAMapping \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

DELETE FROM Bean.COAMapping WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)

--------------------//////////////////////////////////////////////////////////////////////// Bean.CreditMemoApplication \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\


DELETE FROM Bean.CreditMemoApplicationDetail WHERE CreditMemoApplicationId IN 
(
SELECT Id FROM Bean.CreditMemoApplication WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)

DELETE FROM Bean.CreditMemoApplication WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)

--------------------//////////////////////////////////////////////////////////////////////// Bean.CreditNoteApplication \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

DELETE FROM Bean.CreditNoteApplicationDetail WHERE CreditNoteApplicationId IN
(
SELECT Id FROM Bean.CreditNoteApplication WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)

DELETE FROM Bean.CreditNoteApplication WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)

--------------------//////////////////////////////////////////////////////////////////////// Bean.Currency \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

DELETE FROM Bean.Currency WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)

--------------------//////////////////////////////////////////////////////////////////////// Bean.DebitNote \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

DELETE FROM Bean.DebitNoteDetail WHERE DebitNoteId IN
(
SELECT Id FROM Bean.DebitNote WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)

DELETE FROM Bean.DebitNoteGSTDetail WHERE DebitNoteId IN
(
SELECT Id FROM Bean.DebitNote WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)

DELETE FROM Bean.DebitNoteNote WHERE DebitNoteId IN
(
SELECT Id FROM Bean.DebitNote WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)

DELETE FROM Bean.DebitNote WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)

--------------------//////////////////////////////////////////////////////////////////////// Bean.DocumentHistory \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

DELETE FROM Bean.DocumentHistory WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)

--------------------//////////////////////////////////////////////////////////////////////// Bean.DocumentRecurrence_ToBeDeleted \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

------------SELECT * FROM Bean.DocumentRecurrence_ToBeDeleted WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo) -----> No Data in Table

--------------------//////////////////////////////////////////////////////////////////////// Bean.DoubtfulDebtAllocation \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

DELETE FROM Bean.DoubtfulDebtAllocationDetail WHERE DoubtfulDebtAllocationId IN
(
SELECT Id FROM Bean.DoubtfulDebtAllocation WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)

DELETE FROM Bean.DoubtfulDebtAllocation WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)

--------------------//////////////////////////////////////////////////////////////////////// Bean.Entity \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

DELETE FROM Bean.BankReconciliationDetail WHERE EntityId IN
(
SELECT Id FROM Bean.Entity WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)

DELETE FROM Bean.BillCreditMemoDetail WHERE CreditMemoId IN
(
SELECT Id FROM Bean.BillCreditMemo WHERE BillId IN
(
SELECT Id FROM Bean.Bill WHERE EntityId IN
(
SELECT Id FROM Bean.Entity WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)

------------------SELECT * FROM Bean.BillCreditMemoGSTDetails  ----> No Data in Table

DELETE FROM Bean.BillCreditMemo WHERE BillId IN
(
SELECT Id FROM Bean.Bill WHERE EntityId IN
(
SELECT Id FROM Bean.Entity WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)

--------------DELETE FROM Bean.BillCreditMemoDetail WHERE BillDetailId IN  ----> No Data in Table
--------------(
--------------SELECT Id FROM Bean.BillDetail WHERE BillId IN
--------------(
--------------SELECT Id FROM Bean.Bill WHERE EntityId IN
--------------(
--------------SELECT Id FROM Bean.Entity WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
--------------)
--------------)
--------------)

DELETE FROM Bean.BillDetail WHERE BillId IN
(
SELECT Id FROM Bean.Bill WHERE EntityId IN
(
SELECT Id FROM Bean.Entity WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)

------------DELETE FROM Bean.BillGSTDetail WHERE BillId IN ----> No Data in Table
------------(
------------SELECT Id FROM Bean.Bill WHERE EntityId IN
------------(
------------SELECT Id FROM Bean.Entity WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
------------)
------------)


DELETE FROM Bean.Bill WHERE EntityId IN
(
SELECT Id FROM Bean.Entity WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)

DELETE FROM Bean.CashSaleDetail WHERE CashSaleId IN
(
SELECT Id FROM Bean.CashSale WHERE EntityId IN
(
SELECT Id FROM Bean.Entity WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)

DELETE FROM Bean.CashSale WHERE EntityId IN
(
SELECT Id FROM Bean.Entity WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)

DELETE FROM Bean.CreditMemoApplicationDetail WHERE CreditMemoApplicationId IN 
(
SELECT Id FROM Bean.CreditMemoApplication WHERE CreditMemoId IN
(
SELECT Id FROM Bean.CreditMemo WHERE EntityId IN
(
SELECT Id FROM Bean.Entity WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)

DELETE FROM Bean.CreditMemoApplication WHERE CreditMemoId IN
(
SELECT Id FROM Bean.CreditMemo WHERE EntityId IN
(
SELECT Id FROM Bean.Entity WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)

DELETE FROM Bean.CreditMemoDetail WHERE CreditMemoId IN
(
SELECT Id FROM Bean.CreditMemo WHERE EntityId IN
(
SELECT Id FROM Bean.Entity WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)

DELETE FROM Bean.CreditMemo WHERE EntityId IN
(
SELECT Id FROM Bean.Entity WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)

------------------DELETE FROM Bean.JournalLedger WHERE EntityId IN ----> No Data in Table
------------------(
------------------SELECT Id FROM Bean.Entity WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
------------------)

DELETE FROM Bean.OpeningBalanceDetailLineItem WHERE EntityId IN
(
SELECT Id FROM Bean.Entity WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)

DELETE FROM Bean.PaymentDetail WHERE PaymentId IN
(
SELECT Id FROM Bean.Payment WHERE EntityId IN
(
SELECT Id FROM Bean.Entity WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)

DELETE FROM Bean.Payment WHERE EntityId IN
(
SELECT Id FROM Bean.Entity WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)

DELETE FROM Bean.ReceiptBalancingItem WHERE ReceiptId IN
(
SELECT Id FROM Bean.Receipt WHERE EntityId IN
(
SELECT Id FROM Bean.Entity WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
) 
)

DELETE FROM Bean.ReceiptDetail WHERE ReceiptId IN
(
SELECT Id FROM Bean.Receipt WHERE EntityId IN
(
SELECT Id FROM Bean.Entity WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
) 
)

DELETE FROM Bean.ReceiptGSTDetail WHERE ReceiptId IN
(
SELECT Id FROM Bean.Receipt WHERE EntityId IN
(
SELECT Id FROM Bean.Entity WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
) 
)

DELETE FROM Bean.Receipt WHERE EntityId IN
(
SELECT Id FROM Bean.Entity WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
) 

DELETE FROM Bean.Entity WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)

--------------------//////////////////////////////////////////////////////////////////////// Bean.FinancialSetting \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

DELETE FROM Bean.FinancialSetting WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)

--------------------//////////////////////////////////////////////////////////////////////// Bean.Forex \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

DELETE FROM Bean.Forex WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)

--------------------//////////////////////////////////////////////////////////////////////// Bean.GLClearing \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

DELETE FROM Bean.GLClearingDetail WHERE GLClearingId IN
(
SELECT Id FROM Bean.GLClearing WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)

DELETE FROM Bean.GLClearing WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)

--------------------//////////////////////////////////////////////////////////////////////// Bean.InterCompanySetting \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

DELETE FROM Bean.InterCompanySettingDetail WHERE InterCompanySettingId IN
(
SELECT Id FROM Bean.InterCompanySetting WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)

DELETE FROM Bean.InterCompanySetting WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)

--------------------//////////////////////////////////////////////////////////////////////// Bean.InterCompanySettingDetail \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

DELETE FROM Bean.InterCompanySettingDetail WHERE ServiceEntityId  IN (SELECT Id FROM @CompanyInfo)
 
--------------------//////////////////////////////////////////////////////////////////////// Bean.Item \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

DELETE FROM Bean.CashSaleDetail WHERE ItemId IN
(
SELECT Id FROM Bean.Item WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)

DELETE FROM Bean.InvoiceDetail WHERE ItemId IN
(
SELECT Id FROM Bean.Item WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)

DELETE FROM Bean.Item WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)

--------------------//////////////////////////////////////////////////////////////////////// Bean.Journal \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

DELETE FROM Bean.JournalDetail WHERE JournalId IN
(
SELECT Id FROM Bean.Journal WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)

DELETE FROM Bean.JournalGSTDetail WHERE JournalId IN
(
SELECT Id FROM Bean.Journal WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)

DELETE FROM Bean.JournalHistory WHERE JournalId IN
(
SELECT Id FROM Bean.Journal WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)

DELETE FROM Bean.Journal WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)

--------------------//////////////////////////////////////////////////////////////////////// Bean.JournalLedger \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

DELETE FROM Bean.JournalLedger WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)

--------------------//////////////////////////////////////////////////////////////////////// Bean.MultiCurrencySetting \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

DELETE FROM Bean.MultiCurrencySetting WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)

--------------------//////////////////////////////////////////////////////////////////////// Bean.OpeningBalance \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

DELETE FROM Bean.OpeningBalanceDetailLineItem WHERE OpeningBalanceDetailId IN
(
SELECT Id FROM Bean.OpeningBalanceDetail WHERE OpeningBalanceId IN
(
SELECT Id FROM Bean.OpeningBalance WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)

DELETE FROM Bean.OpeningBalanceDetail WHERE OpeningBalanceId IN
(
SELECT Id FROM Bean.OpeningBalance WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)

DELETE FROM Bean.OpeningBalance WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)

--------------------//////////////////////////////////////////////////////////////////////// Bean.Payment \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

DELETE FROM Bean.PaymentDetail WHERE PaymentId IN
(
SELECT Id FROM Bean.Payment WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)

DELETE FROM Bean.Payment WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)

--------------------//////////////////////////////////////////////////////////////////////// Bean.Provision \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

----------------DELETE FROM Bean.Provision WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo) ----> No Data in Table

--------------------//////////////////////////////////////////////////////////////////////// Bean.Receipt \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

DELETE FROM Bean.ReceiptBalancingItem WHERE ReceiptId IN
(
SELECT Id FROM Bean.Receipt WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
) 

DELETE FROM Bean.ReceiptDetail WHERE ReceiptId IN
(
SELECT Id FROM Bean.Receipt WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
) 

DELETE FROM Bean.ReceiptGSTDetail WHERE ReceiptId IN
(
SELECT Id FROM Bean.Receipt WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
) 

DELETE FROM Bean.Receipt WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)

--------------------//////////////////////////////////////////////////////////////////////// Bean.Revalution \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

DELETE FROM Bean.RevalutionDetail WHERE RevalutionId IN
(
SELECT Id FROM Bean.Revalution WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)

DELETE FROM Bean.Revalution WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)

--------------------//////////////////////////////////////////////////////////////////////// Bean.SegmentMaster \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

DELETE FROM Bean.SegmentDetail WHERE SegmentMasterId IN
(
SELECT Id FROM Bean.SegmentMaster WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)

DELETE FROM Bean.SegmentMaster WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)

--------------------//////////////////////////////////////////////////////////////////////// Bean.TaxCode \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\


---------------- SELECT * FROM Bean.BillCreditMemoGSTDetails ----> No Data in Table

------------------SELECT * FROM Bean.BillCreditMemoDetail WHERE BillDetailId IN  ----> No Data in Table
------------------(
------------------SELECT Id FROM Bean.BillDetail WHERE TaxId IN
------------------(
------------------SELECT Id FROM Bean.TaxCode WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
------------------)
------------------)

DELETE FROM Bean.BillDetail WHERE TaxId IN
(
SELECT Id FROM Bean.TaxCode WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)

--------------SELECT * FROM Bean.BillGSTDetail ----> No Data in Table

DELETE FROM Bean.CashSaleDetail WHERE TaxId IN
(
SELECT Id FROM Bean.TaxCode WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)

DELETE FROM Bean.CreditMemoDetail WHERE TaxId IN
(
SELECT Id FROM Bean.TaxCode WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)

DELETE FROM Bean.DebitNoteDetail WHERE TaxId IN
(
SELECT Id FROM Bean.TaxCode WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)

DELETE FROM Bean.DebitNoteGSTDetail WHERE TaxId IN
(
SELECT Id FROM Bean.TaxCode WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)

DELETE FROM Bean.InvoiceDetail WHERE TaxId IN
(
SELECT Id FROM Bean.TaxCode WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)

DELETE FROM Bean.InvoiceGSTDetail WHERE TaxId IN
(
SELECT Id FROM Bean.TaxCode WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)

DELETE FROM Bean.CashSaleDetail WHERE ItemId IN
(
SELECT Id FROM Bean.Item WHERE DefaultTaxcodeId IN
(
SELECT Id FROM Bean.TaxCode WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)

DELETE FROM Bean.InvoiceDetail WHERE ItemId IN
(
SELECT Id FROM Bean.Item WHERE DefaultTaxcodeId IN
(
SELECT Id FROM Bean.TaxCode WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)

DELETE FROM Bean.Item WHERE DefaultTaxcodeId IN
(
SELECT Id FROM Bean.TaxCode WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)

DELETE FROM Bean.JournalDetail WHERE TaxId IN
(
SELECT Id FROM Bean.TaxCode WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)

DELETE FROM Bean.JournalGSTDetail WHERE TaxId IN
(
SELECT Id FROM Bean.TaxCode WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)

DELETE FROM Bean.ReceiptBalancingItem WHERE TaxId IN
(
SELECT Id FROM Bean.TaxCode WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)

DELETE FROM Bean.ReceiptGSTDetail WHERE TaxId IN
(
SELECT Id FROM Bean.TaxCode WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)

DELETE FROM Bean.TaxCodeMappingDetail WHERE CustTaxId IN
(
SELECT Id FROM Bean.TaxCode WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)

DELETE FROM Bean.TaxCodeMappingDetail WHERE VenTaxId IN
(
SELECT Id FROM Bean.TaxCode WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)

DELETE FROM Bean.WithDrawalDetail WHERE TaxId IN
(
SELECT Id FROM Bean.TaxCode WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)

------------------DELETE FROM Common.GSTDetail WHERE TaxId IN -----> No Data in Table
------------------(
------------------SELECT Id FROM Bean.TaxCode WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
------------------)

--------------------------=================== Bean.TaxCode ========================================

DELETE FROM ClientCursor.OpportunityDesignation WHERE OpportunityId IN
(
SELECT Id FROM ClientCursor.Opportunity WHERE ServiceId IN
(
SELECT Id FROM Common.Service WHERE TaxCodeId IN
(
SELECT Id FROM Bean.TaxCode WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)

------------SELECT * FROM ClientCursor.[OpportunityDoc] ----> No Data in Table

DELETE FROM ClientCursor.OpportunityHistory WHERE OpportunityId IN
(
SELECT Id FROM ClientCursor.Opportunity WHERE ServiceId IN
(
SELECT Id FROM Common.Service WHERE TaxCodeId IN
(
SELECT Id FROM Bean.TaxCode WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)

DELETE FROM ClientCursor.OpportunityIncharge WHERE OpportunityId IN
(
SELECT Id FROM ClientCursor.Opportunity WHERE ServiceId IN
(
SELECT Id FROM Common.Service WHERE TaxCodeId IN
(
SELECT Id FROM Bean.TaxCode WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)

DELETE FROM ClientCursor.OpportunityStatusChange WHERE OpportunityId IN
(
SELECT Id FROM ClientCursor.Opportunity WHERE ServiceId IN
(
SELECT Id FROM Common.Service WHERE TaxCodeId IN
(
SELECT Id FROM Bean.TaxCode WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)

----------SELECT * FROM ClientCursor.OpportunityTermsCondition_ToBeDeleted ---> No Data in Table

DELETE FROM ClientCursor.QuotationDetailTemplate WHERE QuotationDetailId IN
(
SELECT Id FROM ClientCursor.QuotationDetail WHERE OpportunityId IN
(
SELECT Id FROM ClientCursor.Opportunity WHERE ServiceId IN
(
SELECT Id FROM Common.Service WHERE TaxCodeId IN
(
SELECT Id FROM Bean.TaxCode WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)
)

DELETE FROM ClientCursor.QuotationDetail WHERE OpportunityId IN
(
SELECT Id FROM ClientCursor.Opportunity WHERE ServiceId IN
(
SELECT Id FROM Common.Service WHERE TaxCodeId IN
(
SELECT Id FROM Bean.TaxCode WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)

DELETE FROM Common.TimeLogDetailSplit WHERE TimelogDetailId IN
(
SELECT Id FROM Common.TimeLogDetail WHERE TimeLogScheduleId IN
(
SELECT Id FROM Common.TimeLogSchedule WHERE CaseId IN
(
SELECT Id FROM WorkFlow.CaseGroup WHERE OpportunityId IN
(
SELECT Id FROM ClientCursor.Opportunity WHERE ServiceId IN
(
SELECT Id FROM Common.Service WHERE TaxCodeId IN
(
SELECT Id FROM Bean.TaxCode WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)
)
)
)


DELETE FROM Common.TimeLogDetail WHERE TimeLogScheduleId IN
(
SELECT Id FROM Common.TimeLogSchedule WHERE CaseId IN
(
SELECT Id FROM WorkFlow.CaseGroup WHERE OpportunityId IN
(
SELECT Id FROM ClientCursor.Opportunity WHERE ServiceId IN
(
SELECT Id FROM Common.Service WHERE TaxCodeId IN
(
SELECT Id FROM Bean.TaxCode WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)
)
)

DELETE FROM Common.TimeLogSchedule WHERE CaseId IN
(
SELECT Id FROM WorkFlow.CaseGroup WHERE OpportunityId IN
(
SELECT Id FROM ClientCursor.Opportunity WHERE ServiceId IN
(
SELECT Id FROM Common.Service WHERE TaxCodeId IN
(
SELECT Id FROM Bean.TaxCode WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)
)

DELETE FROM HR.BankFileDetail WHERE TypeId IN
(
SELECT Id FROM HR.EmployeeClaim1 WHERE CaseGroupId IN
(
SELECT Id FROM WorkFlow.CaseGroup WHERE OpportunityId IN
(
SELECT Id FROM ClientCursor.Opportunity WHERE ServiceId IN
(
SELECT Id FROM Common.Service WHERE TaxCodeId IN
(
SELECT Id FROM Bean.TaxCode WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)
)
)

DELETE FROM HR.EmployeeClaimDetail WHERE EmployeeClaimId IN
(
SELECT Id FROM HR.EmployeeClaim1 WHERE CaseGroupId IN
(
SELECT Id FROM WorkFlow.CaseGroup WHERE OpportunityId IN
(
SELECT Id FROM ClientCursor.Opportunity WHERE ServiceId IN
(
SELECT Id FROM Common.Service WHERE TaxCodeId IN
(
SELECT Id FROM Bean.TaxCode WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)
)
)

DELETE FROM HR.EmployeeClaim1 WHERE CaseGroupId IN
(
SELECT Id FROM WorkFlow.CaseGroup WHERE OpportunityId IN
(
SELECT Id FROM ClientCursor.Opportunity WHERE ServiceId IN
(
SELECT Id FROM Common.Service WHERE TaxCodeId IN
(
SELECT Id FROM Bean.TaxCode WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)
)

DELETE FROM WorkFlow.CaseAmendDateOfCompletion WHERE CaseId IN
(
SELECT Id FROM WorkFlow.CaseGroup WHERE OpportunityId IN
(
SELECT Id FROM ClientCursor.Opportunity WHERE ServiceId IN
(
SELECT Id FROM Common.Service WHERE TaxCodeId IN
(
SELECT Id FROM Bean.TaxCode WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)
)

DELETE FROM WorkFlow.CaseDesignation WHERE CaseId IN
(
SELECT Id FROM WorkFlow.CaseGroup WHERE OpportunityId IN
(
SELECT Id FROM ClientCursor.Opportunity WHERE ServiceId IN
(
SELECT Id FROM Common.Service WHERE TaxCodeId IN
(
SELECT Id FROM Bean.TaxCode WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)
)

------------SELECT * FROM WorkFlow.CaseDoc ----> No Data in Table

DELETE FROM Common.TimeLogDetailSplit WHERE CaseFeatureId IN
(
SELECT Id FROM WorkFlow.CaseFeature WHERE CaseId IN
(
SELECT Id FROM WorkFlow.CaseGroup WHERE OpportunityId IN
(
SELECT Id FROM ClientCursor.Opportunity WHERE ServiceId IN
(
SELECT Id FROM Common.Service WHERE TaxCodeId IN
(
SELECT Id FROM Bean.TaxCode WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)
)
)

DELETE FROM WorkFlow.ScheduleTaskDetail WHERE CaseFeatureId IN
(
SELECT Id FROM WorkFlow.CaseFeature WHERE CaseId IN
(
SELECT Id FROM WorkFlow.CaseGroup WHERE OpportunityId IN
(
SELECT Id FROM ClientCursor.Opportunity WHERE ServiceId IN
(
SELECT Id FROM Common.Service WHERE TaxCodeId IN
(
SELECT Id FROM Bean.TaxCode WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)
)
)

DELETE FROM WorkFlow.CaseFeature WHERE CaseId IN
(
SELECT Id FROM WorkFlow.CaseGroup WHERE OpportunityId IN
(
SELECT Id FROM ClientCursor.Opportunity WHERE ServiceId IN
(
SELECT Id FROM Common.Service WHERE TaxCodeId IN
(
SELECT Id FROM Bean.TaxCode WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)
)

DELETE FROM WorkFlow.CaseIncharge WHERE CaseId IN
(
SELECT Id FROM WorkFlow.CaseGroup WHERE OpportunityId IN
(
SELECT Id FROM ClientCursor.Opportunity WHERE ServiceId IN
(
SELECT Id FROM Common.Service WHERE TaxCodeId IN
(
SELECT Id FROM Bean.TaxCode WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)
)

DELETE FROM WorkFlow.CaseMileStone WHERE CaseId IN
(
SELECT Id FROM WorkFlow.CaseGroup WHERE OpportunityId IN
(
SELECT Id FROM ClientCursor.Opportunity WHERE ServiceId IN
(
SELECT Id FROM Common.Service WHERE TaxCodeId IN
(
SELECT Id FROM Bean.TaxCode WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)
)

-----------SELECT * FROM WorkFlow.CasesAssigned ----> No Data in Table

DELETE FROM WorkFlow.CaseStatusChange WHERE CaseId IN
(
SELECT Id FROM WorkFlow.CaseGroup WHERE OpportunityId IN
(
SELECT Id FROM ClientCursor.Opportunity WHERE ServiceId IN
(
SELECT Id FROM Common.Service WHERE TaxCodeId IN
(
SELECT Id FROM Bean.TaxCode WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)
)

DELETE FROM WorkFlow.Claim WHERE CaseId IN
(
SELECT Id FROM WorkFlow.CaseGroup WHERE OpportunityId IN
(
SELECT Id FROM ClientCursor.Opportunity WHERE ServiceId IN
(
SELECT Id FROM Common.Service WHERE TaxCodeId IN
(
SELECT Id FROM Bean.TaxCode WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)
)

DELETE FROM WorkFlow.Incidental WHERE InvoiceId IN
(
SELECT Id FROM WorkFlow.Invoice WHERE CaseId IN
(
SELECT Id FROM WorkFlow.CaseGroup WHERE OpportunityId IN
(
SELECT Id FROM ClientCursor.Opportunity WHERE ServiceId IN
(
SELECT Id FROM Common.Service WHERE TaxCodeId IN
(
SELECT Id FROM Bean.TaxCode WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)
)
)

DELETE FROM WorkFlow.InvoiceDesignation WHERE InvoiceId IN
(
SELECT Id FROM WorkFlow.Invoice WHERE CaseId IN
(
SELECT Id FROM WorkFlow.CaseGroup WHERE OpportunityId IN
(
SELECT Id FROM ClientCursor.Opportunity WHERE ServiceId IN
(
SELECT Id FROM Common.Service WHERE TaxCodeId IN
(
SELECT Id FROM Bean.TaxCode WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)
)
)

----------SELECT * FROM WorkFlow.InvoiceState ----> No Data in Table

DELETE FROM WorkFlow.Invoice WHERE CaseId IN
(
SELECT Id FROM WorkFlow.CaseGroup WHERE OpportunityId IN
(
SELECT Id FROM ClientCursor.Opportunity WHERE ServiceId IN
(
SELECT Id FROM Common.Service WHERE TaxCodeId IN
(
SELECT Id FROM Bean.TaxCode WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)
)

DELETE FROM WorkFlow.InvoiceDesignation WHERE CaseId IN
(
SELECT Id FROM WorkFlow.CaseGroup WHERE OpportunityId IN
(
SELECT Id FROM ClientCursor.Opportunity WHERE ServiceId IN
(
SELECT Id FROM Common.Service WHERE TaxCodeId IN
(
SELECT Id FROM Bean.TaxCode WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)
)

DELETE FROM WorkFlow.ScheduleTaskDetail WHERE ScheduleTaskId IN
(
SELECT Id FROM WorkFlow.ScheduleTask WHERE ScheduleDetailId IN
(
SELECT Id FROM WorkFlow.ScheduleDetail WHERE MasterId IN
(
SELECT Id FROM WorkFlow.Schedule WHERE CaseId IN
(
SELECT Id FROM WorkFlow.CaseGroup WHERE OpportunityId IN
(
SELECT Id FROM ClientCursor.Opportunity WHERE ServiceId IN
(
SELECT Id FROM Common.Service WHERE TaxCodeId IN
(
SELECT Id FROM Bean.TaxCode WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)
)
)
)
)

DELETE FROM WorkFlow.ScheduleTask WHERE ScheduleDetailId IN
(
SELECT Id FROM WorkFlow.ScheduleDetail WHERE MasterId IN
(
SELECT Id FROM WorkFlow.Schedule WHERE CaseId IN
(
SELECT Id FROM WorkFlow.CaseGroup WHERE OpportunityId IN
(
SELECT Id FROM ClientCursor.Opportunity WHERE ServiceId IN
(
SELECT Id FROM Common.Service WHERE TaxCodeId IN
(
SELECT Id FROM Bean.TaxCode WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)
)
)
)

DELETE FROM WorkFlow.ScheduleDetail WHERE MasterId IN
(
SELECT Id FROM WorkFlow.Schedule WHERE CaseId IN
(
SELECT Id FROM WorkFlow.CaseGroup WHERE OpportunityId IN
(
SELECT Id FROM ClientCursor.Opportunity WHERE ServiceId IN
(
SELECT Id FROM Common.Service WHERE TaxCodeId IN
(
SELECT Id FROM Bean.TaxCode WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)
)
)

DELETE FROM WorkFlow.Schedule WHERE CaseId IN
(
SELECT Id FROM WorkFlow.CaseGroup WHERE OpportunityId IN
(
SELECT Id FROM ClientCursor.Opportunity WHERE ServiceId IN
(
SELECT Id FROM Common.Service WHERE TaxCodeId IN
(
SELECT Id FROM Bean.TaxCode WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)
)

DELETE FROM WorkFlow.ScheduleTaskNew WHERE ScheduleDetailId IN
(
SELECT Id FROM WorkFlow.ScheduleDetailNew WHERE MasterId IN
(
SELECT Id FROM WorkFlow.ScheduleNew WHERE CaseId IN
(
SELECT Id FROM WorkFlow.CaseGroup WHERE OpportunityId IN
(
SELECT Id FROM ClientCursor.Opportunity WHERE ServiceId IN
(
SELECT Id FROM Common.Service WHERE TaxCodeId IN
(
SELECT Id FROM Bean.TaxCode WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)
)
)
)

DELETE FROM WorkFlow.ScheduleDetailNew WHERE MasterId IN
(
SELECT Id FROM WorkFlow.ScheduleNew WHERE CaseId IN
(
SELECT Id FROM WorkFlow.CaseGroup WHERE OpportunityId IN
(
SELECT Id FROM ClientCursor.Opportunity WHERE ServiceId IN
(
SELECT Id FROM Common.Service WHERE TaxCodeId IN
(
SELECT Id FROM Bean.TaxCode WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)
)
)

DELETE FROM WorkFlow.ScheduleNew WHERE CaseId IN
(
SELECT Id FROM WorkFlow.CaseGroup WHERE OpportunityId IN
(
SELECT Id FROM ClientCursor.Opportunity WHERE ServiceId IN
(
SELECT Id FROM Common.Service WHERE TaxCodeId IN
(
SELECT Id FROM Bean.TaxCode WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)
)

DELETE FROM WorkFlow.ScheduleTaskDetail WHERE ScheduleTaskId IN
(
SELECT Id FROM WorkFlow.ScheduleTask WHERE CaseId IN
(
SELECT Id FROM WorkFlow.CaseGroup WHERE OpportunityId IN
(
SELECT Id FROM ClientCursor.Opportunity WHERE ServiceId IN
(
SELECT Id FROM Common.Service WHERE TaxCodeId IN
(
SELECT Id FROM Bean.TaxCode WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)
)
)

DELETE FROM WorkFlow.ScheduleTask WHERE CaseId IN
(
SELECT Id FROM WorkFlow.CaseGroup WHERE OpportunityId IN
(
SELECT Id FROM ClientCursor.Opportunity WHERE ServiceId IN
(
SELECT Id FROM Common.Service WHERE TaxCodeId IN
(
SELECT Id FROM Bean.TaxCode WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)
)

DELETE FROM WorkFlow.ScheduleTaskNew WHERE CaseId IN
(
SELECT Id FROM WorkFlow.CaseGroup WHERE OpportunityId IN
(
SELECT Id FROM ClientCursor.Opportunity WHERE ServiceId IN
(
SELECT Id FROM Common.Service WHERE TaxCodeId IN
(
SELECT Id FROM Bean.TaxCode WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)
)
-----------============ CASEGROUP ==================
DELETE FROM WorkFlow.CaseGroup WHERE OpportunityId IN
(
SELECT Id FROM ClientCursor.Opportunity WHERE ServiceId IN
(
SELECT Id FROM Common.Service WHERE TaxCodeId IN
(
SELECT Id FROM Bean.TaxCode WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)

DELETE FROM ClientCursor.Opportunity WHERE ServiceId IN
(
SELECT Id FROM Common.Service WHERE TaxCodeId IN
(
SELECT Id FROM Bean.TaxCode WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)

DELETE FROM Common.CompanyService WHERE ServiceId IN
(
SELECT Id FROM Common.Service WHERE TaxCodeId IN
(
SELECT Id FROM Bean.TaxCode WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)

DELETE FROM Common.DesignationHourlyRate WHERE ServiceId IN
(
SELECT Id FROM Common.Service WHERE TaxCodeId IN
(
SELECT Id FROM Bean.TaxCode WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)

DELETE FROM Common.Milestone WHERE ServiceId IN
(
SELECT Id FROM Common.Service WHERE TaxCodeId IN
(
SELECT Id FROM Bean.TaxCode WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)

---------SELECT * FROM Common.ServiceRate_ToBeDeleted ---> No Data in Table

DELETE FROM Common.ServiceRecuringSettings WHERE ServiceId IN
(
SELECT Id FROM Common.Service WHERE TaxCodeId IN
(
SELECT Id FROM Bean.TaxCode WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)

-------SELECT * FROM Common.ServiceTemplate_ToBeDeleted ---> No Data in Table

DELETE FROM Common.Task WHERE ServiceId IN
(
SELECT Id FROM Common.Service WHERE TaxCodeId IN
(
SELECT Id FROM Bean.TaxCode WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)

------------============================================================ CASE GROUP =================================================================

DELETE FROM Common.TimeLogDetailSplit WHERE TimelogDetailId IN
(
SELECT Id FROM Common.TimeLogDetail WHERE TimeLogScheduleId IN
(
SELECT Id FROM Common.TimeLogSchedule WHERE CaseId IN
(
SELECT Id FROM WorkFlow.CaseGroup WHERE ServiceId IN
(
SELECT Id FROM Common.Service WHERE TaxCodeId IN
(
SELECT Id FROM Bean.TaxCode WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)
)
)

DELETE FROM Common.TimeLogDetail WHERE TimeLogScheduleId IN
(
SELECT Id FROM Common.TimeLogSchedule WHERE CaseId IN
(
SELECT Id FROM WorkFlow.CaseGroup WHERE ServiceId IN
(
SELECT Id FROM Common.Service WHERE TaxCodeId IN
(
SELECT Id FROM Bean.TaxCode WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)
)

DELETE FROM Common.TimeLogSchedule WHERE CaseId IN
(
SELECT Id FROM WorkFlow.CaseGroup WHERE ServiceId IN
(
SELECT Id FROM Common.Service WHERE TaxCodeId IN
(
SELECT Id FROM Bean.TaxCode WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)

DELETE FROM HR.BankFileDetail WHERE TypeId IN
(
SELECT Id FROM HR.EmployeeClaim1 WHERE CaseGroupId IN
(
SELECT Id FROM WorkFlow.CaseGroup WHERE ServiceId IN
(
SELECT Id FROM Common.Service WHERE TaxCodeId IN
(
SELECT Id FROM Bean.TaxCode WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)
)

DELETE FROM HR.EmployeeClaimDetail WHERE EmployeeClaimId IN
(
SELECT Id FROM HR.EmployeeClaim1 WHERE CaseGroupId IN
(
SELECT Id FROM WorkFlow.CaseGroup WHERE ServiceId IN
(
SELECT Id FROM Common.Service WHERE TaxCodeId IN
(
SELECT Id FROM Bean.TaxCode WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)
)

DELETE FROM HR.EmployeeClaim1 WHERE CaseGroupId IN
(
SELECT Id FROM WorkFlow.CaseGroup WHERE ServiceId IN
(
SELECT Id FROM Common.Service WHERE TaxCodeId IN
(
SELECT Id FROM Bean.TaxCode WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)

DELETE FROM WorkFlow.CaseAmendDateOfCompletion WHERE CaseId IN
(
SELECT Id FROM WorkFlow.CaseGroup WHERE ServiceId IN
(
SELECT Id FROM Common.Service WHERE TaxCodeId IN
(
SELECT Id FROM Bean.TaxCode WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)

DELETE FROM WorkFlow.CaseDesignation WHERE CaseId IN
(
SELECT Id FROM WorkFlow.CaseGroup WHERE ServiceId IN
(
SELECT Id FROM Common.Service WHERE TaxCodeId IN
(
SELECT Id FROM Bean.TaxCode WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)

-------SELECT * FROM WorkFlow.CaseDoc ----> No Data in Table

DELETE FROM Common.TimeLogDetailSplit WHERE CaseFeatureId IN
(
SELECT Id FROM WorkFlow.CaseFeature WHERE CaseId IN
(
SELECT Id FROM WorkFlow.CaseGroup WHERE ServiceId IN
(
SELECT Id FROM Common.Service WHERE TaxCodeId IN
(
SELECT Id FROM Bean.TaxCode WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)
)

DELETE FROM WorkFlow.ScheduleTaskDetail WHERE CaseFeatureId IN
(
SELECT Id FROM WorkFlow.CaseFeature WHERE CaseId IN
(
SELECT Id FROM WorkFlow.CaseGroup WHERE ServiceId IN
(
SELECT Id FROM Common.Service WHERE TaxCodeId IN
(
SELECT Id FROM Bean.TaxCode WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)
)

DELETE FROM WorkFlow.CaseFeature WHERE CaseId IN
(
SELECT Id FROM WorkFlow.CaseGroup WHERE ServiceId IN
(
SELECT Id FROM Common.Service WHERE TaxCodeId IN
(
SELECT Id FROM Bean.TaxCode WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)

DELETE FROM WorkFlow.CaseIncharge WHERE CaseId IN
(
SELECT Id FROM WorkFlow.CaseGroup WHERE ServiceId IN
(
SELECT Id FROM Common.Service WHERE TaxCodeId IN
(
SELECT Id FROM Bean.TaxCode WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)

DELETE FROM WorkFlow.CaseMileStone WHERE CaseId IN
(
SELECT Id FROM WorkFlow.CaseGroup WHERE ServiceId IN
(
SELECT Id FROM Common.Service WHERE TaxCodeId IN
(
SELECT Id FROM Bean.TaxCode WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)

----------SELECT * FROM WorkFlow.CasesAssigned ----> No Data in Table

DELETE FROM WorkFlow.CaseStatusChange WHERE CaseId IN
(
SELECT Id FROM WorkFlow.CaseGroup WHERE ServiceId IN
(
SELECT Id FROM Common.Service WHERE TaxCodeId IN
(
SELECT Id FROM Bean.TaxCode WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)

DELETE FROM WorkFlow.Claim WHERE CaseId IN
(
SELECT Id FROM WorkFlow.CaseGroup WHERE ServiceId IN
(
SELECT Id FROM Common.Service WHERE TaxCodeId IN
(
SELECT Id FROM Bean.TaxCode WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)

DELETE FROM WorkFlow.Incidental WHERE InvoiceId IN
(
SELECT Id FROM WorkFlow.Invoice WHERE CaseId IN
(
SELECT Id FROM WorkFlow.CaseGroup WHERE ServiceId IN
(
SELECT Id FROM Common.Service WHERE TaxCodeId IN
(
SELECT Id FROM Bean.TaxCode WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)
)

DELETE FROM WorkFlow.InvoiceDesignation WHERE InvoiceId IN
(
SELECT Id FROM WorkFlow.Invoice WHERE CaseId IN
(
SELECT Id FROM WorkFlow.CaseGroup WHERE ServiceId IN
(
SELECT Id FROM Common.Service WHERE TaxCodeId IN
(
SELECT Id FROM Bean.TaxCode WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)
)

-------SELECT * FROM WorkFlow.InvoiceState ----> No Data in Table

DELETE FROM WorkFlow.Invoice WHERE CaseId IN
(
SELECT Id FROM WorkFlow.CaseGroup WHERE ServiceId IN
(
SELECT Id FROM Common.Service WHERE TaxCodeId IN
(
SELECT Id FROM Bean.TaxCode WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)

DELETE FROM WorkFlow.InvoiceDesignation WHERE CaseId IN
(
SELECT Id FROM WorkFlow.CaseGroup WHERE ServiceId IN
(
SELECT Id FROM Common.Service WHERE TaxCodeId IN
(
SELECT Id FROM Bean.TaxCode WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)

DELETE FROM WorkFlow.ScheduleTaskDetail WHERE ScheduleTaskId IN
(
SELECT Id FROM WorkFlow.ScheduleTask WHERE ScheduleDetailId IN
(
SELECT Id FROM WorkFlow.ScheduleDetail WHERE MasterId IN
(
SELECT Id FROM WorkFlow.Schedule WHERE CaseId IN
(
SELECT Id FROM WorkFlow.CaseGroup WHERE ServiceId IN
(
SELECT Id FROM Common.Service WHERE TaxCodeId IN
(
SELECT Id FROM Bean.TaxCode WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)
)
)
)

DELETE FROM WorkFlow.ScheduleTask WHERE ScheduleDetailId IN
(
SELECT Id FROM WorkFlow.ScheduleDetail WHERE MasterId IN
(
SELECT Id FROM WorkFlow.Schedule WHERE CaseId IN
(
SELECT Id FROM WorkFlow.CaseGroup WHERE ServiceId IN
(
SELECT Id FROM Common.Service WHERE TaxCodeId IN
(
SELECT Id FROM Bean.TaxCode WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)
)
)

DELETE FROM WorkFlow.ScheduleDetail WHERE MasterId IN
(
SELECT Id FROM WorkFlow.Schedule WHERE CaseId IN
(
SELECT Id FROM WorkFlow.CaseGroup WHERE ServiceId IN
(
SELECT Id FROM Common.Service WHERE TaxCodeId IN
(
SELECT Id FROM Bean.TaxCode WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)
)

DELETE FROM WorkFlow.Schedule WHERE CaseId IN
(
SELECT Id FROM WorkFlow.CaseGroup WHERE ServiceId IN
(
SELECT Id FROM Common.Service WHERE TaxCodeId IN
(
SELECT Id FROM Bean.TaxCode WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)


DELETE FROM WorkFlow.ScheduleTaskNew WHERE ScheduleDetailId IN
(
SELECT Id FROM WorkFlow.ScheduleDetailNew WHERE MasterId IN
(
SELECT Id FROM WorkFlow.ScheduleNew WHERE CaseId IN
(
SELECT Id FROM WorkFlow.CaseGroup WHERE ServiceId IN
(
SELECT Id FROM Common.Service WHERE TaxCodeId IN
(
SELECT Id FROM Bean.TaxCode WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)
)
)


DELETE FROM WorkFlow.ScheduleDetailNew WHERE MasterId IN
(
SELECT Id FROM WorkFlow.ScheduleNew WHERE CaseId IN
(
SELECT Id FROM WorkFlow.CaseGroup WHERE ServiceId IN
(
SELECT Id FROM Common.Service WHERE TaxCodeId IN
(
SELECT Id FROM Bean.TaxCode WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)
)

DELETE FROM WorkFlow.ScheduleNew WHERE CaseId IN
(
SELECT Id FROM WorkFlow.CaseGroup WHERE ServiceId IN
(
SELECT Id FROM Common.Service WHERE TaxCodeId IN
(
SELECT Id FROM Bean.TaxCode WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)


DELETE FROM WorkFlow.ScheduleTaskDetail WHERE ScheduleTaskId IN
(
SELECT Id FROM WorkFlow.ScheduleTask WHERE CaseId IN
(
SELECT Id FROM WorkFlow.CaseGroup WHERE ServiceId IN
(
SELECT Id FROM Common.Service WHERE TaxCodeId IN
(
SELECT Id FROM Bean.TaxCode WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)
)


DELETE FROM WorkFlow.ScheduleTask WHERE CaseId IN
(
SELECT Id FROM WorkFlow.CaseGroup WHERE ServiceId IN
(
SELECT Id FROM Common.Service WHERE TaxCodeId IN
(
SELECT Id FROM Bean.TaxCode WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)


DELETE FROM WorkFlow.ScheduleTaskNew WHERE CaseId IN
(
SELECT Id FROM WorkFlow.CaseGroup WHERE ServiceId IN
(
SELECT Id FROM Common.Service WHERE TaxCodeId IN
(
SELECT Id FROM Bean.TaxCode WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)


DELETE FROM WorkFlow.CaseGroup WHERE ServiceId IN
(
SELECT Id FROM Common.Service WHERE TaxCodeId IN
(
SELECT Id FROM Bean.TaxCode WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)

-------------============================================================== CASE GROUP ==================================================================

DELETE FROM Common.Service WHERE TaxCodeId IN
(
SELECT Id FROM Bean.TaxCode WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)

DELETE FROM Common.XeroTaxCodeDetail WHERE BeanTaxCodeId IN
(
SELECT Id FROM Bean.TaxCode WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)

DELETE FROM HR.EmployeeClaimDetail WHERE TaxId IN
(
SELECT Id FROM Bean.TaxCode WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)

DELETE FROM WorkFlow.Incidental WHERE ClaimItemId IN
(
SELECT Id FROM WorkFlow.IncidentalClaimItem WHERE TaxCodeId IN
(
SELECT Id FROM Bean.TaxCode WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)

DELETE FROM WorkFlow.IncidentalClaimItem WHERE TaxCodeId IN
(
SELECT Id FROM Bean.TaxCode WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)


DELETE FROM WorkFlow.Incidental WHERE InvoiceId IN
(
SELECT Id FROM WorkFlow.Invoice WHERE TaxCodeId IN
(
SELECT Id FROM Bean.TaxCode WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)

DELETE FROM WorkFlow.InvoiceDesignation WHERE InvoiceId IN
(
SELECT Id FROM WorkFlow.Invoice WHERE TaxCodeId IN
(
SELECT Id FROM Bean.TaxCode WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)

)

----------SELECT * FROM WorkFlow.InvoiceState ----> No Data in Table

DELETE FROM WorkFlow.Invoice WHERE TaxCodeId IN
(
SELECT Id FROM Bean.TaxCode WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)

DELETE FROM Bean.TaxCode WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)

--------------------//////////////////////////////////////////////////////////////////////// Bean.TaxCodeMapping \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

DELETE FROM Bean.TaxCodeMapping WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)

--------------------//////////////////////////////////////////////////////////////////////// Bean.WithDrawal \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

DELETE FROM Bean.WithDrawalDetail WHERE WithdrawalId IN
(
SELECT Id FROM Bean.WithDrawal WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)

DELETE FROM Bean.WithDrawal WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)

END
GO
