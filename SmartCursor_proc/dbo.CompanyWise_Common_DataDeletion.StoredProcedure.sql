USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[CompanyWise_Common_DataDeletion]    Script Date: 16-12-2024 9.20.10 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   PROCEDURE [dbo].[CompanyWise_Common_DataDeletion]
@CompanyId Int

AS
BEGIN

DECLARE @CompanyInfo TABLE (Id Int, RegistrationNo Nvarchar(150), Name Nvarchar(500))

INSERT INTO @CompanyInfo
SELECT Id,RegistrationNo,Name FROM Common.Company WHERE Id = @CompanyId
UNION ALL
SELECT Id,RegistrationNo,Name FROM Common.Company WHERE ParentId = @CompanyId


----------------------==================================================================================================================================================================================================
----------------------/////////////////////////////////////////////////////////////////////////////// COMMON \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
-----------------------==================================================================================================================================================================================================

----------------------/////////////////////////////////////////////////////////////////////////////// Common.AccountSource_ToBeDeleted \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

----------------SELECT * FROM Common.AccountSource_ToBeDeleted ----> No Data in Table

----------------------/////////////////////////////////////////////////////////////////////////////// Common.AccountType \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

------------========================= Bean.Entity: FK_Entity_AccountType =========================

DELETE FROM Bean.BankReconciliationDetail WHERE EntityId IN
(
SELECT Id FROM Bean.Entity WHERE TypeId IN
(
SELECT Id FROM Common.AccountType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)

DELETE FROM Bean.BillCreditMemoDetail WHERE CreditMemoId IN
(
SELECT Id FROM Bean.BillCreditMemo WHERE BillId IN
(
SELECT Id FROM Bean.Bill WHERE EntityId IN
(
SELECT Id FROM Bean.Entity WHERE TypeId IN
(
SELECT Id FROM Common.AccountType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)
)

------------------SELECT * FROM Bean.BillCreditMemoGSTDetails  ----> No Data in Table

DELETE FROM Bean.BillCreditMemo WHERE BillId IN
(
SELECT Id FROM Bean.Bill WHERE EntityId IN
(
SELECT Id FROM Bean.Entity WHERE TypeId IN
(
SELECT Id FROM Common.AccountType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)

DELETE FROM Bean.BillDetail WHERE BillId IN
(
SELECT Id FROM Bean.Bill WHERE EntityId IN
(
SELECT Id FROM Bean.Entity WHERE TypeId IN
(
SELECT Id FROM Common.AccountType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)

DELETE FROM Bean.Bill WHERE EntityId IN
(
SELECT Id FROM Bean.Entity WHERE TypeId IN
(
SELECT Id FROM Common.AccountType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)

DELETE FROM Bean.CashSaleDetail WHERE CashSaleId IN
(
SELECT Id FROM Bean.CashSale WHERE EntityId IN
(
SELECT Id FROM Bean.Entity WHERE TypeId IN
(
SELECT Id FROM Common.AccountType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)

DELETE FROM Bean.CashSale WHERE EntityId IN
(
SELECT Id FROM Bean.Entity WHERE TypeId IN
(
SELECT Id FROM Common.AccountType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)

DELETE FROM Bean.CreditMemoApplicationDetail WHERE CreditMemoApplicationId IN 
(
SELECT Id FROM Bean.CreditMemoApplication WHERE CreditMemoId IN
(
SELECT Id FROM Bean.CreditMemo WHERE EntityId IN
(
SELECT Id FROM Bean.Entity WHERE TypeId IN
(
SELECT Id FROM Common.AccountType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)
)

DELETE FROM Bean.CreditMemoApplication WHERE CreditMemoId IN
(
SELECT Id FROM Bean.CreditMemo WHERE EntityId IN
(
SELECT Id FROM Bean.Entity WHERE TypeId IN
(
SELECT Id FROM Common.AccountType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)

DELETE FROM Bean.CreditMemoDetail WHERE CreditMemoId IN
(
SELECT Id FROM Bean.CreditMemo WHERE EntityId IN
(
SELECT Id FROM Bean.Entity WHERE TypeId IN
(
SELECT Id FROM Common.AccountType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)

DELETE FROM Bean.CreditMemo WHERE EntityId IN
(
SELECT Id FROM Bean.Entity WHERE TypeId IN
(
SELECT Id FROM Common.AccountType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)

DELETE FROM Bean.OpeningBalanceDetailLineItem WHERE EntityId IN
(
SELECT Id FROM Bean.Entity WHERE TypeId IN
(
SELECT Id FROM Common.AccountType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)

DELETE FROM Bean.PaymentDetail WHERE PaymentId IN
(
SELECT Id FROM Bean.Payment WHERE EntityId IN
(
SELECT Id FROM Bean.Entity WHERE TypeId IN
(
SELECT Id FROM Common.AccountType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)

DELETE FROM Bean.Payment WHERE EntityId IN
(
SELECT Id FROM Bean.Entity WHERE TypeId IN
(
SELECT Id FROM Common.AccountType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)

DELETE FROM Bean.ReceiptBalancingItem WHERE ReceiptId IN
(
SELECT Id FROM Bean.Receipt WHERE EntityId IN
(
SELECT Id FROM Bean.Entity WHERE TypeId IN
(
SELECT Id FROM Common.AccountType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
) 
)

DELETE FROM Bean.ReceiptDetail WHERE ReceiptId IN
(
SELECT Id FROM Bean.Receipt WHERE EntityId IN
(
SELECT Id FROM Bean.Entity WHERE TypeId IN
(
SELECT Id FROM Common.AccountType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
) 
)

DELETE FROM Bean.ReceiptGSTDetail WHERE ReceiptId IN
(
SELECT Id FROM Bean.Receipt WHERE EntityId IN
(
SELECT Id FROM Bean.Entity WHERE TypeId IN
(
SELECT Id FROM Common.AccountType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
) 
)

DELETE FROM Bean.Receipt WHERE EntityId IN
(
SELECT Id FROM Bean.Entity WHERE TypeId IN
(
SELECT Id FROM Common.AccountType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
) 

DELETE FROM Bean.Entity WHERE TypeId IN
(
SELECT Id FROM Common.AccountType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)

--------------========================= ClientCursor.Account: FK_Account_AccountType =========================

DELETE FROM ClientCursor.AccountIncharge WHERE AccountId IN
(
SELECT Id FROM ClientCursor.Account WHERE AccountIdTypeId IN
(
SELECT Id FROM Common.AccountType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)

------------SELECT * FROM ClientCursor.AccountNote_ToBeDeleted ----> No Data in Table

DELETE FROM ClientCursor.AccountStatusChange WHERE AccountId IN
(
SELECT Id FROM ClientCursor.Account WHERE AccountIdTypeId IN
(
SELECT Id FROM Common.AccountType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)

DELETE FROM ClientCursor.ManualAssociation WHERE FromAccountId IN
(
SELECT Id FROM ClientCursor.Account WHERE AccountIdTypeId IN
(
SELECT Id FROM Common.AccountType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)


DELETE FROM ClientCursor.OpportunityDesignation WHERE OpportunityId IN
(
SELECT Id FROM ClientCursor.Opportunity WHERE AccountId IN
(
SELECT Id FROM ClientCursor.Account WHERE AccountIdTypeId IN
(
SELECT Id FROM Common.AccountType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)

------------SELECT * FROM ClientCursor.[OpportunityDoc] ----> No Data in Table

DELETE FROM ClientCursor.OpportunityHistory WHERE OpportunityId IN
(
SELECT Id FROM ClientCursor.Opportunity WHERE AccountId IN
(
SELECT Id FROM ClientCursor.Account WHERE AccountIdTypeId IN
(
SELECT Id FROM Common.AccountType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)

DELETE FROM ClientCursor.OpportunityIncharge WHERE OpportunityId IN
(
SELECT Id FROM ClientCursor.Opportunity WHERE AccountId IN
(
SELECT Id FROM ClientCursor.Account WHERE AccountIdTypeId IN
(
SELECT Id FROM Common.AccountType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)

DELETE FROM ClientCursor.OpportunityStatusChange WHERE OpportunityId IN
(
SELECT Id FROM ClientCursor.Opportunity WHERE AccountId IN
(
SELECT Id FROM ClientCursor.Account WHERE AccountIdTypeId IN
(
SELECT Id FROM Common.AccountType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)

----------SELECT * FROM ClientCursor.OpportunityTermsCondition_ToBeDeleted ---> No Data in Table

DELETE FROM ClientCursor.QuotationDetailTemplate WHERE QuotationDetailId IN
(
SELECT Id FROM ClientCursor.QuotationDetail WHERE OpportunityId IN
(
SELECT Id FROM ClientCursor.Opportunity WHERE AccountId IN
(
SELECT Id FROM ClientCursor.Account WHERE AccountIdTypeId IN
(
SELECT Id FROM Common.AccountType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)
)

DELETE FROM ClientCursor.QuotationDetail WHERE OpportunityId IN
(
SELECT Id FROM ClientCursor.Opportunity WHERE AccountId IN
(
SELECT Id FROM ClientCursor.Account WHERE AccountIdTypeId IN
(
SELECT Id FROM Common.AccountType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
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
SELECT Id FROM ClientCursor.Opportunity WHERE AccountId IN
(
SELECT Id FROM ClientCursor.Account WHERE AccountIdTypeId IN
(
SELECT Id FROM Common.AccountType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
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
SELECT Id FROM ClientCursor.Opportunity WHERE AccountId IN
(
SELECT Id FROM ClientCursor.Account WHERE AccountIdTypeId IN
(
SELECT Id FROM Common.AccountType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)
)
)

DELETE FROM Common.TimeLogSchedule WHERE CaseId IN
(
SELECT Id FROM WorkFlow.CaseGroup WHERE OpportunityId IN
(
SELECT Id FROM ClientCursor.Opportunity WHERE AccountId IN
(
SELECT Id FROM ClientCursor.Account WHERE AccountIdTypeId IN
(
SELECT Id FROM Common.AccountType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
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
SELECT Id FROM ClientCursor.Opportunity WHERE AccountId IN
(
SELECT Id FROM ClientCursor.Account WHERE AccountIdTypeId IN
(
SELECT Id FROM Common.AccountType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
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
SELECT Id FROM ClientCursor.Opportunity WHERE AccountId IN
(
SELECT Id FROM ClientCursor.Account WHERE AccountIdTypeId IN
(
SELECT Id FROM Common.AccountType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)
)
)

DELETE FROM HR.EmployeeClaim1 WHERE CaseGroupId IN
(
SELECT Id FROM WorkFlow.CaseGroup WHERE OpportunityId IN
(
SELECT Id FROM ClientCursor.Opportunity WHERE AccountId IN
(
SELECT Id FROM ClientCursor.Account WHERE AccountIdTypeId IN
(
SELECT Id FROM Common.AccountType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)
)

DELETE FROM WorkFlow.CaseAmendDateOfCompletion WHERE CaseId IN
(
SELECT Id FROM WorkFlow.CaseGroup WHERE OpportunityId IN
(
SELECT Id FROM ClientCursor.Opportunity WHERE AccountId IN
(
SELECT Id FROM ClientCursor.Account WHERE AccountIdTypeId IN
(
SELECT Id FROM Common.AccountType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)
)

DELETE FROM WorkFlow.CaseDesignation WHERE CaseId IN
(
SELECT Id FROM WorkFlow.CaseGroup WHERE OpportunityId IN
(
SELECT Id FROM ClientCursor.Opportunity WHERE AccountId IN
(
SELECT Id FROM ClientCursor.Account WHERE AccountIdTypeId IN
(
SELECT Id FROM Common.AccountType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
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
SELECT Id FROM ClientCursor.Opportunity WHERE AccountId IN
(
SELECT Id FROM ClientCursor.Account WHERE AccountIdTypeId IN
(
SELECT Id FROM Common.AccountType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
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
SELECT Id FROM ClientCursor.Opportunity WHERE AccountId IN
(
SELECT Id FROM ClientCursor.Account WHERE AccountIdTypeId IN
(
SELECT Id FROM Common.AccountType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)
)
)

DELETE FROM WorkFlow.CaseFeature WHERE CaseId IN
(
SELECT Id FROM WorkFlow.CaseGroup WHERE OpportunityId IN
(
SELECT Id FROM ClientCursor.Opportunity WHERE AccountId IN
(
SELECT Id FROM ClientCursor.Account WHERE AccountIdTypeId IN
(
SELECT Id FROM Common.AccountType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)
)

DELETE FROM WorkFlow.CaseIncharge WHERE CaseId IN
(
SELECT Id FROM WorkFlow.CaseGroup WHERE OpportunityId IN
(
SELECT Id FROM ClientCursor.Opportunity WHERE AccountId IN
(
SELECT Id FROM ClientCursor.Account WHERE AccountIdTypeId IN
(
SELECT Id FROM Common.AccountType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)
)

DELETE FROM WorkFlow.CaseMileStone WHERE CaseId IN
(
SELECT Id FROM WorkFlow.CaseGroup WHERE OpportunityId IN
(
SELECT Id FROM ClientCursor.Opportunity WHERE AccountId IN
(
SELECT Id FROM ClientCursor.Account WHERE AccountIdTypeId IN
(
SELECT Id FROM Common.AccountType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)
)

-----------SELECT * FROM WorkFlow.CasesAssigned ----> No Data in Table

DELETE FROM WorkFlow.CaseStatusChange WHERE CaseId IN
(
SELECT Id FROM WorkFlow.CaseGroup WHERE OpportunityId IN
(
SELECT Id FROM ClientCursor.Opportunity WHERE AccountId IN
(
SELECT Id FROM ClientCursor.Account WHERE AccountIdTypeId IN
(
SELECT Id FROM Common.AccountType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)
)

DELETE FROM WorkFlow.Claim WHERE CaseId IN
(
SELECT Id FROM WorkFlow.CaseGroup WHERE OpportunityId IN
(
SELECT Id FROM ClientCursor.Opportunity WHERE AccountId IN
(
SELECT Id FROM ClientCursor.Account WHERE AccountIdTypeId IN
(
SELECT Id FROM Common.AccountType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
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
SELECT Id FROM ClientCursor.Opportunity WHERE AccountId IN
(
SELECT Id FROM ClientCursor.Account WHERE AccountIdTypeId IN
(
SELECT Id FROM Common.AccountType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
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
SELECT Id FROM ClientCursor.Opportunity WHERE AccountId IN
(
SELECT Id FROM ClientCursor.Account WHERE AccountIdTypeId IN
(
SELECT Id FROM Common.AccountType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
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
SELECT Id FROM ClientCursor.Opportunity WHERE AccountId IN
(
SELECT Id FROM ClientCursor.Account WHERE AccountIdTypeId IN
(
SELECT Id FROM Common.AccountType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)
)

DELETE FROM WorkFlow.InvoiceDesignation WHERE CaseId IN
(
SELECT Id FROM WorkFlow.CaseGroup WHERE OpportunityId IN
(
SELECT Id FROM ClientCursor.Opportunity WHERE AccountId IN
(
SELECT Id FROM ClientCursor.Account WHERE AccountIdTypeId IN
(
SELECT Id FROM Common.AccountType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
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
SELECT Id FROM ClientCursor.Opportunity WHERE AccountId IN
(
SELECT Id FROM ClientCursor.Account WHERE AccountIdTypeId IN
(
SELECT Id FROM Common.AccountType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
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
SELECT Id FROM ClientCursor.Opportunity WHERE AccountId IN
(
SELECT Id FROM ClientCursor.Account WHERE AccountIdTypeId IN
(
SELECT Id FROM Common.AccountType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
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
SELECT Id FROM ClientCursor.Opportunity WHERE AccountId IN
(
SELECT Id FROM ClientCursor.Account WHERE AccountIdTypeId IN
(
SELECT Id FROM Common.AccountType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)
)
)

DELETE FROM WorkFlow.Schedule WHERE CaseId IN
(
SELECT Id FROM WorkFlow.CaseGroup WHERE OpportunityId IN
(
SELECT Id FROM ClientCursor.Opportunity WHERE AccountId IN
(
SELECT Id FROM ClientCursor.Account WHERE AccountIdTypeId IN
(
SELECT Id FROM Common.AccountType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
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
SELECT Id FROM ClientCursor.Opportunity WHERE AccountId IN
(
SELECT Id FROM ClientCursor.Account WHERE AccountIdTypeId IN
(
SELECT Id FROM Common.AccountType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
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
SELECT Id FROM ClientCursor.Opportunity WHERE AccountId IN
(
SELECT Id FROM ClientCursor.Account WHERE AccountIdTypeId IN
(
SELECT Id FROM Common.AccountType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)
)
)

DELETE FROM WorkFlow.ScheduleNew WHERE CaseId IN
(
SELECT Id FROM WorkFlow.CaseGroup WHERE OpportunityId IN
(
SELECT Id FROM ClientCursor.Opportunity WHERE AccountId IN
(
SELECT Id FROM ClientCursor.Account WHERE AccountIdTypeId IN
(
SELECT Id FROM Common.AccountType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
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
SELECT Id FROM ClientCursor.Opportunity WHERE AccountId IN
(
SELECT Id FROM ClientCursor.Account WHERE AccountIdTypeId IN
(
SELECT Id FROM Common.AccountType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)
)
)

DELETE FROM WorkFlow.ScheduleTask WHERE CaseId IN
(
SELECT Id FROM WorkFlow.CaseGroup WHERE OpportunityId IN
(
SELECT Id FROM ClientCursor.Opportunity WHERE AccountId IN
(
SELECT Id FROM ClientCursor.Account WHERE AccountIdTypeId IN
(
SELECT Id FROM Common.AccountType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)
)

DELETE FROM WorkFlow.ScheduleTaskNew WHERE CaseId IN
(
SELECT Id FROM WorkFlow.CaseGroup WHERE OpportunityId IN
(
SELECT Id FROM ClientCursor.Opportunity WHERE AccountId IN
(
SELECT Id FROM ClientCursor.Account WHERE AccountIdTypeId IN
(
SELECT Id FROM Common.AccountType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)
)
-----------============ CASEGROUP ==================
DELETE FROM WorkFlow.CaseGroup WHERE OpportunityId IN
(
SELECT Id FROM ClientCursor.Opportunity WHERE AccountId IN
(
SELECT Id FROM ClientCursor.Account WHERE AccountIdTypeId IN
(
SELECT Id FROM Common.AccountType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)

DELETE FROM ClientCursor.Opportunity WHERE AccountId IN
(
SELECT Id FROM ClientCursor.Account WHERE AccountIdTypeId IN
(
SELECT Id FROM Common.AccountType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)

DELETE FROM ClientCursor.QuotationDetailTemplate WHERE QuotationDetailId IN
(
SELECT Id FROM ClientCursor.QuotationDetail WHERE MasterId IN
(
SELECT Id FROM ClientCursor.Quotation WHERE AccountId IN
(
SELECT Id FROM ClientCursor.Account WHERE AccountIdTypeId IN
(
SELECT Id FROM Common.AccountType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)
)

DELETE FROM ClientCursor.QuotationDetail WHERE MasterId IN
(
SELECT Id FROM ClientCursor.Quotation WHERE AccountId IN
(
SELECT Id FROM ClientCursor.Account WHERE AccountIdTypeId IN
(
SELECT Id FROM Common.AccountType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)

DELETE FROM ClientCursor.QuotationHistory WHERE QuotationId IN
(
SELECT Id FROM ClientCursor.Quotation WHERE AccountId IN
(
SELECT Id FROM ClientCursor.Account WHERE AccountIdTypeId IN
(
SELECT Id FROM Common.AccountType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)

DELETE FROM ClientCursor.QuotationSummaryDetails WHERE QuotationId IN
(
SELECT Id FROM ClientCursor.Quotation WHERE AccountId IN
(
SELECT Id FROM ClientCursor.Account WHERE AccountIdTypeId IN
(
SELECT Id FROM Common.AccountType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)

DELETE FROM ClientCursor.Quotation WHERE AccountId IN
(
SELECT Id FROM ClientCursor.Account WHERE AccountIdTypeId IN
(
SELECT Id FROM Common.AccountType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)

DELETE FROM Common.ReminderBatchList WHERE AccountId IN
(
SELECT Id FROM ClientCursor.Account WHERE AccountIdTypeId IN
(
SELECT Id FROM Common.AccountType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)

DELETE FROM ClientCursor.Account WHERE AccountIdTypeId IN
(
SELECT Id FROM Common.AccountType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)

-------========================================= Common.AccountTypeIdType: FK_AccountTypeIdType_AccountType ===========================

DELETE FROM Common.AccountTypeIdType WHERE AccountTypeId IN
(
SELECT Id FROM Common.AccountType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)

-------========================================= Tax.TaxCompany: FK_TaxCompany_AccountType ===========================

DELETE FROM Tax.EngagementVisitedHistory WHERE TaxCompanyId IN
(
SELECT Id FROM Tax.TaxCompany WHERE TaxCompanyTypeId IN
(
SELECT Id FROM Common.AccountType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)

DELETE FROM Tax.ClientAndEngagementIndependenceConfirmation WHERE PlanningAndCompletionSetUpId IN
(
SELECT Id FROM Tax.PlanningAndCompletionSetUp WHERE TaxCompanyId IN
(
SELECT Id FROM Tax.TaxCompany WHERE TaxCompanyTypeId IN
(
SELECT Id FROM Common.AccountType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)

DELETE FROM Tax.DirectorRemunerationDetails WHERE DirectorRemunerationId IN
(
SELECT Id FROM Tax.DirectorRemuneration WHERE PlanningAndCompletionSetUpId IN
(
SELECT Id FROM Tax.PlanningAndCompletionSetUp WHERE TaxCompanyId IN
(
SELECT Id FROM Tax.TaxCompany WHERE TaxCompanyTypeId IN
(
SELECT Id FROM Common.AccountType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)
)

DELETE FROM Tax.DirectorRemuneration WHERE PlanningAndCompletionSetUpId IN
(
SELECT Id FROM Tax.PlanningAndCompletionSetUp WHERE TaxCompanyId IN
(
SELECT Id FROM Tax.TaxCompany WHERE TaxCompanyTypeId IN
(
SELECT Id FROM Common.AccountType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)

DELETE FROM Tax.PAndCSectionQuestions WHERE PAndCSectionId IN
(
SELECT Id FROM Tax.PAndCSections WHERE PlanningAndCompletionSetUpId IN
(
SELECT Id FROM Tax.PlanningAndCompletionSetUp WHERE TaxCompanyId IN
(
SELECT Id FROM Tax.TaxCompany WHERE TaxCompanyTypeId IN
(
SELECT Id FROM Common.AccountType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)
)

DELETE FROM Tax.PAndCSections WHERE PlanningAndCompletionSetUpId IN
(
SELECT Id FROM Tax.PlanningAndCompletionSetUp WHERE TaxCompanyId IN
(
SELECT Id FROM Tax.TaxCompany WHERE TaxCompanyTypeId IN
(
SELECT Id FROM Common.AccountType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)

DELETE FROM Tax.PlanningAndCompletionSetUp WHERE TaxCompanyId IN
(
SELECT Id FROM Tax.TaxCompany WHERE TaxCompanyTypeId IN
(
SELECT Id FROM Common.AccountType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)

------------------SELECT * FROM Tax.PlanningMateriality_ToBeDeleted -----> No Data in Table 

DELETE FROM Tax.DonationReference WHERE ProfitAndLossImportId IN
(
SELECT Id FROM Tax.ProfitAndLossImport WHERE TaxCompanyId IN
(
SELECT Id FROM Tax.TaxCompany WHERE TaxCompanyTypeId IN
(
SELECT Id FROM Common.AccountType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)

DELETE FROM Tax.FurtherDeductionDetail WHERE ProfitAndLossImportId IN
(
SELECT Id FROM Tax.ProfitAndLossImport WHERE TaxCompanyId IN
(
SELECT Id FROM Tax.TaxCompany WHERE TaxCompanyTypeId IN
(
SELECT Id FROM Common.AccountType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)

DELETE FROM Tax.NonTradeIncomeDetail WHERE ProfitAndLossImportId IN
(
SELECT Id FROM Tax.ProfitAndLossImport WHERE TaxCompanyId IN
(
SELECT Id FROM Tax.TaxCompany WHERE TaxCompanyTypeId IN
(
SELECT Id FROM Common.AccountType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)

DELETE FROM Tax.RentalIncomeDetail WHERE ProfitAndLossImportId IN
(
SELECT Id FROM Tax.ProfitAndLossImport WHERE TaxCompanyId IN
(
SELECT Id FROM Tax.TaxCompany WHERE TaxCompanyTypeId IN
(
SELECT Id FROM Common.AccountType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)

DELETE FROM Tax.Section14QAdditions WHERE ProfitAndLossImportId IN
(
SELECT Id FROM Tax.ProfitAndLossImport WHERE TaxCompanyId IN
(
SELECT Id FROM Tax.TaxCompany WHERE TaxCompanyTypeId IN
(
SELECT Id FROM Common.AccountType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)

DELETE FROM Tax.StatementA WHERE PandLId IN
(
SELECT Id FROM Tax.ProfitAndLossImport WHERE TaxCompanyId IN
(
SELECT Id FROM Tax.TaxCompany WHERE TaxCompanyTypeId IN
(
SELECT Id FROM Common.AccountType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)

DELETE FROM Tax.ProfitAndLossImport WHERE TaxCompanyId IN
(
SELECT Id FROM Tax.TaxCompany WHERE TaxCompanyTypeId IN
(
SELECT Id FROM Common.AccountType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)

DELETE FROM Tax.Disposal WHERE SectionAId IN
(
SELECT Id FROM Tax.SectionA WHERE TaxCompanyId IN
(
SELECT Id FROM Tax.TaxCompany WHERE TaxCompanyTypeId IN
(
SELECT Id FROM Common.AccountType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)

DELETE FROM Tax.Section14QAdditions WHERE SectionAId IN
(
SELECT Id FROM Tax.SectionA WHERE TaxCompanyId IN
(
SELECT Id FROM Tax.TaxCompany WHERE TaxCompanyTypeId IN
(
SELECT Id FROM Common.AccountType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)

DELETE FROM Tax.SectionADetail WHERE SECTIONAId IN
(
SELECT Id FROM Tax.SectionA WHERE TaxCompanyId IN
(
SELECT Id FROM Tax.TaxCompany WHERE TaxCompanyTypeId IN
(
SELECT Id FROM Common.AccountType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)

DELETE FROM Tax.SectionB WHERE SECTIONAId IN
(
SELECT Id FROM Tax.SectionA WHERE TaxCompanyId IN
(
SELECT Id FROM Tax.TaxCompany WHERE TaxCompanyTypeId IN
(
SELECT Id FROM Common.AccountType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)

DELETE FROM Tax.SectionA WHERE TaxCompanyId IN
(
SELECT Id FROM Tax.TaxCompany WHERE TaxCompanyTypeId IN
(
SELECT Id FROM Common.AccountType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)

DELETE FROM Tax.ClientAndEngagementIndependenceConfirmation WHERE TaxCompanyContactId IN
(
SELECT Id FROM Tax.TaxCompanyContact WHERE TaxCompanyId IN
(
SELECT Id FROM Tax.TaxCompany WHERE TaxCompanyTypeId IN
(
SELECT Id FROM Common.AccountType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)

DELETE FROM Tax.DirectorRemunerationDetails WHERE DirectorRemunerationId IN
(
SELECT Id FROM Tax.DirectorRemuneration WHERE TaxCompanyContactId IN
(
SELECT Id FROM Tax.TaxCompanyContact WHERE TaxCompanyId IN
(
SELECT Id FROM Tax.TaxCompany WHERE TaxCompanyTypeId IN
(
SELECT Id FROM Common.AccountType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)
)

DELETE FROM Tax.DirectorRemuneration WHERE TaxCompanyContactId IN
(
SELECT Id FROM Tax.TaxCompanyContact WHERE TaxCompanyId IN
(
SELECT Id FROM Tax.TaxCompany WHERE TaxCompanyTypeId IN
(
SELECT Id FROM Common.AccountType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)

DELETE FROM Tax.TaxCompanyContact WHERE TaxCompanyId IN
(
SELECT Id FROM Tax.TaxCompany WHERE TaxCompanyTypeId IN
(
SELECT Id FROM Common.AccountType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)

DELETE FROM Tax.AccountAnnotation WHERE EngagementId IN
(
SELECT Id FROM Tax.TaxCompanyEngagement WHERE TaxCompanyId IN
(
SELECT Id FROM Tax.TaxCompany WHERE TaxCompanyTypeId IN
(
SELECT Id FROM Common.AccountType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)

DELETE FROM Tax.AccountPolicyDetail WHERE MasterId IN
(
SELECT Id FROM Tax.AccountPolicy WHERE EngagementId IN
(
SELECT Id FROM Tax.TaxCompanyEngagement WHERE TaxCompanyId IN
(
SELECT Id FROM Tax.TaxCompany WHERE TaxCompanyTypeId IN
(
SELECT Id FROM Common.AccountType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)
)

DELETE FROM Tax.AccountPolicy WHERE EngagementId IN
(
SELECT Id FROM Tax.TaxCompanyEngagement WHERE TaxCompanyId IN
(
SELECT Id FROM Tax.TaxCompany WHERE TaxCompanyTypeId IN
(
SELECT Id FROM Common.AccountType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)

--------------SELECT * FROM Tax.AdjustmentComment_ToBeDeleted ------> No Data in Table 

DELETE FROM Tax.AdjustmentFileAttachment WHERE AdjustmentID IN
(
SELECT ID FROM Tax.Adjustment WHERE EngagementID IN
(
SELECT Id FROM Tax.TaxCompanyEngagement WHERE TaxCompanyId IN
(
SELECT Id FROM Tax.TaxCompany WHERE TaxCompanyTypeId IN
(
SELECT Id FROM Common.AccountType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)
)

DELETE FROM Tax.AdjustmentStatusHistory WHERE AdjustmentID IN
(
SELECT ID FROM Tax.Adjustment WHERE EngagementID IN
(
SELECT Id FROM Tax.TaxCompanyEngagement WHERE TaxCompanyId IN
(
SELECT Id FROM Tax.TaxCompany WHERE TaxCompanyTypeId IN
(
SELECT Id FROM Common.AccountType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)
)

DELETE FROM Tax.FEAnalysisNote WHERE AdjustmentID IN
(
SELECT ID FROM Tax.Adjustment WHERE EngagementID IN
(
SELECT Id FROM Tax.TaxCompanyEngagement WHERE TaxCompanyId IN
(
SELECT Id FROM Tax.TaxCompany WHERE TaxCompanyTypeId IN
(
SELECT Id FROM Common.AccountType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)
)

--------------------SELECT * FROM Tax.NoteAdjustment_ToBeDeleted ----> No Data in Table

DELETE FROM Tax.Adjustment WHERE EngagementID IN
(
SELECT Id FROM Tax.TaxCompanyEngagement WHERE TaxCompanyId IN
(
SELECT Id FROM Tax.TaxCompany WHERE TaxCompanyTypeId IN
(
SELECT Id FROM Common.AccountType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)

DELETE FROM Tax.AdjustmentDOCRepository WHERE EngagementID IN
(
SELECT Id FROM Tax.TaxCompanyEngagement WHERE TaxCompanyId IN
(
SELECT Id FROM Tax.TaxCompany WHERE TaxCompanyTypeId IN
(
SELECT Id FROM Common.AccountType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)

DELETE FROM Tax.CarryForwardDetail WHERE CarryForwardId IN
(
SELECT Id FROM Tax.CarryForward WHERE EngagementId IN
(
SELECT Id FROM Tax.TaxCompanyEngagement WHERE TaxCompanyId IN
(
SELECT Id FROM Tax.TaxCompany WHERE TaxCompanyTypeId IN
(
SELECT Id FROM Common.AccountType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)
)

DELETE FROM Tax.CarryForward WHERE EngagementId IN
(
SELECT Id FROM Tax.TaxCompanyEngagement WHERE TaxCompanyId IN
(
SELECT Id FROM Tax.TaxCompany WHERE TaxCompanyTypeId IN
(
SELECT Id FROM Common.AccountType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)

DELETE FROM Tax.ClientAndEngagementIndependenceConfirmation WHERE EngagementId IN
(
SELECT Id FROM Tax.TaxCompanyEngagement WHERE TaxCompanyId IN
(
SELECT Id FROM Tax.TaxCompany WHERE TaxCompanyTypeId IN
(
SELECT Id FROM Common.AccountType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)

DELETE FROM Tax.DirectorRemunerationDetails WHERE DirectorRemunerationId IN
(
SELECT Id FROM Tax.DirectorRemuneration WHERE EngagementId IN
(
SELECT Id FROM Tax.TaxCompanyEngagement WHERE TaxCompanyId IN
(
SELECT Id FROM Tax.TaxCompany WHERE TaxCompanyTypeId IN
(
SELECT Id FROM Common.AccountType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)
)

DELETE FROM Tax.DirectorRemuneration WHERE EngagementId IN
(
SELECT Id FROM Tax.TaxCompanyEngagement WHERE TaxCompanyId IN
(
SELECT Id FROM Tax.TaxCompany WHERE TaxCompanyTypeId IN
(
SELECT Id FROM Common.AccountType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)

DELETE FROM Tax.Donation WHERE EngagementId IN
(
SELECT Id FROM Tax.TaxCompanyEngagement WHERE TaxCompanyId IN
(
SELECT Id FROM Tax.TaxCompany WHERE TaxCompanyTypeId IN
(
SELECT Id FROM Common.AccountType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)

DELETE FROM Tax.DonationReference WHERE EngagementId IN
(
SELECT Id FROM Tax.TaxCompanyEngagement WHERE TaxCompanyId IN
(
SELECT Id FROM Tax.TaxCompany WHERE TaxCompanyTypeId IN
(
SELECT Id FROM Common.AccountType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)

DELETE FROM Tax.EngagementPercentage WHERE EngagementId IN
(
SELECT Id FROM Tax.TaxCompanyEngagement WHERE TaxCompanyId IN
(
SELECT Id FROM Tax.TaxCompany WHERE TaxCompanyTypeId IN
(
SELECT Id FROM Common.AccountType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)

DELETE FROM Tax.EngagementVisitedHistory WHERE EngagementId IN
(
SELECT Id FROM Tax.TaxCompanyEngagement WHERE TaxCompanyId IN
(
SELECT Id FROM Tax.TaxCompany WHERE TaxCompanyTypeId IN
(
SELECT Id FROM Common.AccountType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)

DELETE FROM Tax.FEAnalysisCommentReply WHERE FECommentID IN
(
SELECT ID FROM Tax.FEAnalysisComment WHERE FEAnalysisID IN
(
SELECT ID FROM Tax.FEAnalysis WHERE ForeignExchangeID IN
(
SELECT ID FROM Tax.ForeignExchange WHERE EngagementID IN
(
SELECT Id FROM Tax.TaxCompanyEngagement WHERE TaxCompanyId IN
(
SELECT Id FROM Tax.TaxCompany WHERE TaxCompanyTypeId IN
(
SELECT Id FROM Common.AccountType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)
)
)
)

DELETE FROM Tax.FEAnalysisComment WHERE FEAnalysisID IN
(
SELECT ID FROM Tax.FEAnalysis WHERE ForeignExchangeID IN
(
SELECT ID FROM Tax.ForeignExchange WHERE EngagementID IN
(
SELECT Id FROM Tax.TaxCompanyEngagement WHERE TaxCompanyId IN
(
SELECT Id FROM Tax.TaxCompany WHERE TaxCompanyTypeId IN
(
SELECT Id FROM Common.AccountType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)
)
)

DELETE FROM Tax.FEAnalysisCurrencyDetails WHERE CuntryCurrencyID IN
(
SELECT ID FROM Tax.FEAnalysisCountryCurrency WHERE FEAnalysisID IN
(
SELECT ID FROM Tax.FEAnalysis WHERE ForeignExchangeID IN
(
SELECT ID FROM Tax.ForeignExchange WHERE EngagementID IN
(
SELECT Id FROM Tax.TaxCompanyEngagement WHERE TaxCompanyId IN
(
SELECT Id FROM Tax.TaxCompany WHERE TaxCompanyTypeId IN
(
SELECT Id FROM Common.AccountType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)
)
)
)

DELETE FROM Tax.FEAnalysisCountryCurrency WHERE FEAnalysisID IN
(
SELECT ID FROM Tax.FEAnalysis WHERE ForeignExchangeID IN
(
SELECT ID FROM Tax.ForeignExchange WHERE EngagementID IN
(
SELECT Id FROM Tax.TaxCompanyEngagement WHERE TaxCompanyId IN
(
SELECT Id FROM Tax.TaxCompany WHERE TaxCompanyTypeId IN
(
SELECT Id FROM Common.AccountType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)
)
)

DELETE FROM Tax.FEAnalysisNote WHERE FELegendID IN
(
SELECT ID FROM Tax.FEAnalysisLegend WHERE FEAnalysisID IN
(
SELECT ID FROM Tax.FEAnalysis WHERE ForeignExchangeID IN
(
SELECT ID FROM Tax.ForeignExchange WHERE EngagementID IN
(
SELECT Id FROM Tax.TaxCompanyEngagement WHERE TaxCompanyId IN
(
SELECT Id FROM Tax.TaxCompany WHERE TaxCompanyTypeId IN
(
SELECT Id FROM Common.AccountType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)
)
)
)

DELETE FROM Tax.FEAnalysisLegend WHERE FEAnalysisID IN
(
SELECT ID FROM Tax.FEAnalysis WHERE ForeignExchangeID IN
(
SELECT ID FROM Tax.ForeignExchange WHERE EngagementID IN
(
SELECT Id FROM Tax.TaxCompanyEngagement WHERE TaxCompanyId IN
(
SELECT Id FROM Tax.TaxCompany WHERE TaxCompanyTypeId IN
(
SELECT Id FROM Common.AccountType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)
)
)

DELETE FROM Tax.FEAnalysisNote WHERE FEAnalysisID IN
(
SELECT ID FROM Tax.FEAnalysis WHERE ForeignExchangeID IN
(
SELECT ID FROM Tax.ForeignExchange WHERE EngagementID IN
(
SELECT Id FROM Tax.TaxCompanyEngagement WHERE TaxCompanyId IN
(
SELECT Id FROM Tax.TaxCompany WHERE TaxCompanyTypeId IN
(
SELECT Id FROM Common.AccountType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)
)
)

DELETE FROM Tax.FEAnalysis WHERE ForeignExchangeID IN
(
SELECT ID FROM Tax.ForeignExchange WHERE EngagementID IN
(
SELECT Id FROM Tax.TaxCompanyEngagement WHERE TaxCompanyId IN
(
SELECT Id FROM Tax.TaxCompany WHERE TaxCompanyTypeId IN
(
SELECT Id FROM Common.AccountType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)
)

DELETE FROM Tax.ForeignCurrencyAnalysisFactors WHERE FCAnalysisID IN
(
SELECT ID FROM Tax.ForeignCurrencyAnalysis WHERE ForeignExchangeID IN
(
SELECT ID FROM Tax.ForeignExchange WHERE EngagementID IN
(
SELECT Id FROM Tax.TaxCompanyEngagement WHERE TaxCompanyId IN
(
SELECT Id FROM Tax.TaxCompany WHERE TaxCompanyTypeId IN
(
SELECT Id FROM Common.AccountType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)
)
)

DELETE FROM Tax.ForeignCurrencyAnalysis WHERE ForeignExchangeID IN
(
SELECT ID FROM Tax.ForeignExchange WHERE EngagementID IN
(
SELECT Id FROM Tax.TaxCompanyEngagement WHERE TaxCompanyId IN
(
SELECT Id FROM Tax.TaxCompany WHERE TaxCompanyTypeId IN
(
SELECT Id FROM Common.AccountType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)
)

DELETE FROM Tax.ForeignExchange WHERE EngagementID IN
(
SELECT Id FROM Tax.TaxCompanyEngagement WHERE TaxCompanyId IN
(
SELECT Id FROM Tax.TaxCompany WHERE TaxCompanyTypeId IN
(
SELECT Id FROM Common.AccountType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)

DELETE FROM Tax.FormDetail WHERE FormMasterId IN
(
SELECT Id FROM Tax.FormMaster WHERE EngagementId IN
(
SELECT Id FROM Tax.TaxCompanyEngagement WHERE TaxCompanyId IN
(
SELECT Id FROM Tax.TaxCompany WHERE TaxCompanyTypeId IN
(
SELECT Id FROM Common.AccountType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)
)

DELETE FROM Tax.FormMaster WHERE EngagementId IN
(
SELECT Id FROM Tax.TaxCompanyEngagement WHERE TaxCompanyId IN
(
SELECT Id FROM Tax.TaxCompany WHERE TaxCompanyTypeId IN
(
SELECT Id FROM Common.AccountType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)

DELETE FROM Tax.FurtherDeductionDetail WHERE FurtherDeductionId IN
(
SELECT Id FROM Tax.FurtherDeduction WHERE EngagementId IN
(
SELECT Id FROM Tax.TaxCompanyEngagement WHERE TaxCompanyId IN
(
SELECT Id FROM Tax.TaxCompany WHERE TaxCompanyTypeId IN
(
SELECT Id FROM Common.AccountType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)
)

DELETE FROM Tax.FurtherDeduction WHERE EngagementId IN
(
SELECT Id FROM Tax.TaxCompanyEngagement WHERE TaxCompanyId IN
(
SELECT Id FROM Tax.TaxCompany WHERE TaxCompanyTypeId IN
(
SELECT Id FROM Common.AccountType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)

DELETE FROM Tax.GeneralLedgerDetail WHERE GeneralLedgerId IN
(
SELECT Id FROM Tax.GeneralLedgerImport WHERE FileId IN
(
SELECT Id FROM Tax.GeneralLedgerFileDetails WHERE EngagementId IN
(
SELECT Id FROM Tax.TaxCompanyEngagement WHERE TaxCompanyId IN
(
SELECT Id FROM Tax.TaxCompany WHERE TaxCompanyTypeId IN
(
SELECT Id FROM Common.AccountType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)
)
)

DELETE FROM Tax.GeneralLedgerImport WHERE FileId IN
(
SELECT Id FROM Tax.GeneralLedgerFileDetails WHERE EngagementId IN
(
SELECT Id FROM Tax.TaxCompanyEngagement WHERE TaxCompanyId IN
(
SELECT Id FROM Tax.TaxCompany WHERE TaxCompanyTypeId IN
(
SELECT Id FROM Common.AccountType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)
)

DELETE FROM Tax.GeneralLedgerFileDetails WHERE EngagementId IN
(
SELECT Id FROM Tax.TaxCompanyEngagement WHERE TaxCompanyId IN
(
SELECT Id FROM Tax.TaxCompany WHERE TaxCompanyTypeId IN
(
SELECT Id FROM Common.AccountType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)

DELETE FROM Tax.GeneralLedgerDetail WHERE GeneralLedgerId IN
(
SELECT Id FROM Tax.GeneralLedgerImport WHERE EngagementId IN
(
SELECT Id FROM Tax.TaxCompanyEngagement WHERE TaxCompanyId IN
(
SELECT Id FROM Tax.TaxCompany WHERE TaxCompanyTypeId IN
(
SELECT Id FROM Common.AccountType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)
)

DELETE FROM Tax.GeneralLedgerImport WHERE EngagementId IN
(
SELECT Id FROM Tax.TaxCompanyEngagement WHERE TaxCompanyId IN
(
SELECT Id FROM Tax.TaxCompany WHERE TaxCompanyTypeId IN
(
SELECT Id FROM Common.AccountType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)

DELETE FROM Tax.InterestExpenses WHERE InterestRestrictionId IN
(
SELECT ID FROM Tax.InterestRestriction WHERE EngagementId IN
(
SELECT Id FROM Tax.TaxCompanyEngagement WHERE TaxCompanyId IN
(
SELECT Id FROM Tax.TaxCompany WHERE TaxCompanyTypeId IN
(
SELECT Id FROM Common.AccountType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)
)

DELETE FROM Tax.InvestmentSchedule WHERE InterestRestrictionId IN
(
SELECT ID FROM Tax.InterestRestriction WHERE EngagementId IN
(
SELECT Id FROM Tax.TaxCompanyEngagement WHERE TaxCompanyId IN
(
SELECT Id FROM Tax.TaxCompany WHERE TaxCompanyTypeId IN
(
SELECT Id FROM Common.AccountType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)
)

DELETE FROM Tax.InterestRestriction WHERE EngagementId IN
(
SELECT Id FROM Tax.TaxCompanyEngagement WHERE TaxCompanyId IN
(
SELECT Id FROM Tax.TaxCompany WHERE TaxCompanyTypeId IN
(
SELECT Id FROM Common.AccountType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)

DELETE FROM Tax.MedicalExpenseDetails WHERE MedicalExpensesId IN
(
SELECT Id FROM Tax.MedicalExpenses WHERE EngagementId IN
(
SELECT Id FROM Tax.TaxCompanyEngagement WHERE TaxCompanyId IN
(
SELECT Id FROM Tax.TaxCompany WHERE TaxCompanyTypeId IN
(
SELECT Id FROM Common.AccountType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)
)

DELETE FROM Tax.MedicalExpenses WHERE EngagementId IN
(
SELECT Id FROM Tax.TaxCompanyEngagement WHERE TaxCompanyId IN
(
SELECT Id FROM Tax.TaxCompany WHERE TaxCompanyTypeId IN
(
SELECT Id FROM Common.AccountType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)

DELETE FROM Tax.NonTradeIncomeDetail WHERE NonTradeIncomeId IN
(
SELECT Id FROM Tax.NonTradeIncome WHERE EngagementId IN
(
SELECT Id FROM Tax.TaxCompanyEngagement WHERE TaxCompanyId IN
(
SELECT Id FROM Tax.TaxCompany WHERE TaxCompanyTypeId IN
(
SELECT Id FROM Common.AccountType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)
)

DELETE FROM Tax.NonTradeIncome WHERE EngagementId IN
(
SELECT Id FROM Tax.TaxCompanyEngagement WHERE TaxCompanyId IN
(
SELECT Id FROM Tax.TaxCompany WHERE TaxCompanyTypeId IN
(
SELECT Id FROM Common.AccountType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)

DELETE FROM Tax.PIC WHERE EngagementID IN
(
SELECT Id FROM Tax.TaxCompanyEngagement WHERE TaxCompanyId IN
(
SELECT Id FROM Tax.TaxCompany WHERE TaxCompanyTypeId IN
(
SELECT Id FROM Common.AccountType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)

DELETE FROM Tax.ClientAndEngagementIndependenceConfirmation WHERE PlanningAndCompletionSetUpId IN
(
SELECT Id FROM Tax.PlanningAndCompletionSetUp WHERE EngagementId IN
(
SELECT Id FROM Tax.TaxCompanyEngagement WHERE TaxCompanyId IN
(
SELECT Id FROM Tax.TaxCompany WHERE TaxCompanyTypeId IN
(
SELECT Id FROM Common.AccountType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)
)

DELETE FROM Tax.DirectorRemunerationDetails WHERE DirectorRemunerationId IN
(
SELECT Id FROM Tax.DirectorRemuneration WHERE PlanningAndCompletionSetUpId IN
(
SELECT Id FROM Tax.PlanningAndCompletionSetUp WHERE EngagementId IN
(
SELECT Id FROM Tax.TaxCompanyEngagement WHERE TaxCompanyId IN
(
SELECT Id FROM Tax.TaxCompany WHERE TaxCompanyTypeId IN
(
SELECT Id FROM Common.AccountType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)
)
)

DELETE FROM Tax.DirectorRemuneration WHERE PlanningAndCompletionSetUpId IN
(
SELECT Id FROM Tax.PlanningAndCompletionSetUp WHERE EngagementId IN
(
SELECT Id FROM Tax.TaxCompanyEngagement WHERE TaxCompanyId IN
(
SELECT Id FROM Tax.TaxCompany WHERE TaxCompanyTypeId IN
(
SELECT Id FROM Common.AccountType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)
)

DELETE FROM Tax.PAndCSectionQuestions WHERE PAndCSectionId IN
(
SELECT Id FROM Tax.PAndCSections WHERE PlanningAndCompletionSetUpId IN
(
SELECT Id FROM Tax.PlanningAndCompletionSetUp WHERE EngagementId IN
(
SELECT Id FROM Tax.TaxCompanyEngagement WHERE TaxCompanyId IN
(
SELECT Id FROM Tax.TaxCompany WHERE TaxCompanyTypeId IN
(
SELECT Id FROM Common.AccountType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)
)
)

DELETE FROM Tax.PAndCSections WHERE PlanningAndCompletionSetUpId IN
(
SELECT Id FROM Tax.PlanningAndCompletionSetUp WHERE EngagementId IN
(
SELECT Id FROM Tax.TaxCompanyEngagement WHERE TaxCompanyId IN
(
SELECT Id FROM Tax.TaxCompany WHERE TaxCompanyTypeId IN
(
SELECT Id FROM Common.AccountType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)
)

DELETE FROM Tax.PlanningAndCompletionSetUp WHERE EngagementId IN
(
SELECT Id FROM Tax.TaxCompanyEngagement WHERE TaxCompanyId IN
(
SELECT Id FROM Tax.TaxCompany WHERE TaxCompanyTypeId IN
(
SELECT Id FROM Common.AccountType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)

--------------------SELECT * FROM Tax.PlanningMateriality_ToBeDeleted ----> No Data in Table

--------------------SELECT * FROM Tax.PlanningMaterialityDetailClassification_ToBeDeleted ----> No Data in Table

DELETE FROM Tax.ProfitAndLossAuditTrail WHERE EngagementID IN
(
SELECT Id FROM Tax.TaxCompanyEngagement WHERE TaxCompanyId IN
(
SELECT Id FROM Tax.TaxCompany WHERE TaxCompanyTypeId IN
(
SELECT Id FROM Common.AccountType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)

DELETE FROM Tax.ProfitAndLossFileDetails WHERE EngagementId IN
(
SELECT Id FROM Tax.TaxCompanyEngagement WHERE TaxCompanyId IN
(
SELECT Id FROM Tax.TaxCompany WHERE TaxCompanyTypeId IN
(
SELECT Id FROM Common.AccountType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)

DELETE FROM Tax.DonationReference WHERE ProfitAndLossImportId IN
(
SELECT Id FROM Tax.ProfitAndLossImport WHERE EngagementId IN
(
SELECT Id FROM Tax.TaxCompanyEngagement WHERE TaxCompanyId IN
(
SELECT Id FROM Tax.TaxCompany WHERE TaxCompanyTypeId IN
(
SELECT Id FROM Common.AccountType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)
)

DELETE FROM Tax.FurtherDeductionDetail WHERE ProfitAndLossImportId IN
(
SELECT Id FROM Tax.ProfitAndLossImport WHERE EngagementId IN
(
SELECT Id FROM Tax.TaxCompanyEngagement WHERE TaxCompanyId IN
(
SELECT Id FROM Tax.TaxCompany WHERE TaxCompanyTypeId IN
(
SELECT Id FROM Common.AccountType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)
)

DELETE FROM Tax.NonTradeIncomeDetail WHERE ProfitAndLossImportId IN
(
SELECT Id FROM Tax.ProfitAndLossImport WHERE EngagementId IN
(
SELECT Id FROM Tax.TaxCompanyEngagement WHERE TaxCompanyId IN
(
SELECT Id FROM Tax.TaxCompany WHERE TaxCompanyTypeId IN
(
SELECT Id FROM Common.AccountType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)
)

DELETE FROM Tax.RentalIncomeDetail WHERE ProfitAndLossImportId IN
(
SELECT Id FROM Tax.ProfitAndLossImport WHERE EngagementId IN
(
SELECT Id FROM Tax.TaxCompanyEngagement WHERE TaxCompanyId IN
(
SELECT Id FROM Tax.TaxCompany WHERE TaxCompanyTypeId IN
(
SELECT Id FROM Common.AccountType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)
)

DELETE FROM Tax.Section14QAdditions WHERE ProfitAndLossImportId IN
(
SELECT Id FROM Tax.ProfitAndLossImport WHERE EngagementId IN
(
SELECT Id FROM Tax.TaxCompanyEngagement WHERE TaxCompanyId IN
(
SELECT Id FROM Tax.TaxCompany WHERE TaxCompanyTypeId IN
(
SELECT Id FROM Common.AccountType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)
)

DELETE FROM Tax.StatementA WHERE PandLId IN
(
SELECT Id FROM Tax.ProfitAndLossImport WHERE EngagementId IN
(
SELECT Id FROM Tax.TaxCompanyEngagement WHERE TaxCompanyId IN
(
SELECT Id FROM Tax.TaxCompany WHERE TaxCompanyTypeId IN
(
SELECT Id FROM Common.AccountType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)
)

DELETE FROM Tax.ProfitAndLossImport WHERE EngagementId IN
(
SELECT Id FROM Tax.TaxCompanyEngagement WHERE TaxCompanyId IN
(
SELECT Id FROM Tax.TaxCompany WHERE TaxCompanyTypeId IN
(
SELECT Id FROM Common.AccountType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)

DELETE FROM Tax.ProfitAndLossTickmark WHERE EngagementID IN
(
SELECT Id FROM Tax.TaxCompanyEngagement WHERE TaxCompanyId IN
(
SELECT Id FROM Tax.TaxCompany WHERE TaxCompanyTypeId IN
(
SELECT Id FROM Common.AccountType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)

DELETE FROM Tax.RentalIncomeDetail WHERE RentalIncomeId IN
(
SELECT Id FROM Tax.RentalIncome WHERE EngagementID IN
(
SELECT Id FROM Tax.TaxCompanyEngagement WHERE TaxCompanyId IN
(
SELECT Id FROM Tax.TaxCompany WHERE TaxCompanyTypeId IN
(
SELECT Id FROM Common.AccountType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)
)

DELETE FROM Tax.RentalIncome WHERE EngagementID IN
(
SELECT Id FROM Tax.TaxCompanyEngagement WHERE TaxCompanyId IN
(
SELECT Id FROM Tax.TaxCompany WHERE TaxCompanyTypeId IN
(
SELECT Id FROM Common.AccountType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)

DELETE FROM Tax.RollForward WHERE OldEngagementId IN
(
SELECT Id FROM Tax.TaxCompanyEngagement WHERE TaxCompanyId IN
(
SELECT Id FROM Tax.TaxCompany WHERE TaxCompanyTypeId IN
(
SELECT Id FROM Common.AccountType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)

----------------SELECT * FROM Tax.Schedule_ToBeDeleted ----> No data in Table

DELETE FROM Tax.Section14QAdditions WHERE Section14QId IN
(
SELECT Id FROM Tax.Section14Q WHERE EngagementId IN
(
SELECT Id FROM Tax.TaxCompanyEngagement WHERE TaxCompanyId IN
(
SELECT Id FROM Tax.TaxCompany WHERE TaxCompanyTypeId IN
(
SELECT Id FROM Common.AccountType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)
)

DELETE FROM Tax.Section14QDetails WHERE Section14QId IN
(
SELECT Id FROM Tax.Section14Q WHERE EngagementId IN
(
SELECT Id FROM Tax.TaxCompanyEngagement WHERE TaxCompanyId IN
(
SELECT Id FROM Tax.TaxCompany WHERE TaxCompanyTypeId IN
(
SELECT Id FROM Common.AccountType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)
)

DELETE FROM Tax.Section14QEligibleExp WHERE Section14QId IN
(
SELECT Id FROM Tax.Section14Q WHERE EngagementId IN
(
SELECT Id FROM Tax.TaxCompanyEngagement WHERE TaxCompanyId IN
(
SELECT Id FROM Tax.TaxCompany WHERE TaxCompanyTypeId IN
(
SELECT Id FROM Common.AccountType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)
)

DELETE FROM Tax.Section14Q WHERE EngagementId IN
(
SELECT Id FROM Tax.TaxCompanyEngagement WHERE TaxCompanyId IN
(
SELECT Id FROM Tax.TaxCompany WHERE TaxCompanyTypeId IN
(
SELECT Id FROM Common.AccountType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)

DELETE FROM Tax.Disposal WHERE SectionAId IN
(
SELECT Id FROM Tax.SectionA WHERE EngagementId IN
(
SELECT Id FROM Tax.TaxCompanyEngagement WHERE TaxCompanyId IN
(
SELECT Id FROM Tax.TaxCompany WHERE TaxCompanyTypeId IN
(
SELECT Id FROM Common.AccountType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)
)

DELETE FROM Tax.Section14QAdditions WHERE SectionAId IN
(
SELECT Id FROM Tax.SectionA WHERE EngagementId IN
(
SELECT Id FROM Tax.TaxCompanyEngagement WHERE TaxCompanyId IN
(
SELECT Id FROM Tax.TaxCompany WHERE TaxCompanyTypeId IN
(
SELECT Id FROM Common.AccountType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)
)

DELETE FROM Tax.SectionADetail WHERE SECTIONAId IN
(
SELECT Id FROM Tax.SectionA WHERE EngagementId IN
(
SELECT Id FROM Tax.TaxCompanyEngagement WHERE TaxCompanyId IN
(
SELECT Id FROM Tax.TaxCompany WHERE TaxCompanyTypeId IN
(
SELECT Id FROM Common.AccountType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)
)

DELETE FROM Tax.SectionB WHERE SECTIONAId IN
(
SELECT Id FROM Tax.SectionA WHERE EngagementId IN
(
SELECT Id FROM Tax.TaxCompanyEngagement WHERE TaxCompanyId IN
(
SELECT Id FROM Tax.TaxCompany WHERE TaxCompanyTypeId IN
(
SELECT Id FROM Common.AccountType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)
)

DELETE FROM Tax.SectionA WHERE EngagementId IN
(
SELECT Id FROM Tax.TaxCompanyEngagement WHERE TaxCompanyId IN
(
SELECT Id FROM Tax.TaxCompany WHERE TaxCompanyTypeId IN
(
SELECT Id FROM Common.AccountType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)

DELETE FROM Tax.StatementA WHERE EngagementId IN
(
SELECT Id FROM Tax.TaxCompanyEngagement WHERE TaxCompanyId IN
(
SELECT Id FROM Tax.TaxCompany WHERE TaxCompanyTypeId IN
(
SELECT Id FROM Common.AccountType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)

DELETE FROM Tax.SubCategory WHERE EngagementId IN
(
SELECT Id FROM Tax.TaxCompanyEngagement WHERE TaxCompanyId IN
(
SELECT Id FROM Tax.TaxCompany WHERE TaxCompanyTypeId IN
(
SELECT Id FROM Common.AccountType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)

DELETE FROM Tax.TaxAuditTrail WHERE EngagementId IN
(
SELECT Id FROM Tax.TaxCompanyEngagement WHERE TaxCompanyId IN
(
SELECT Id FROM Tax.TaxCompany WHERE TaxCompanyTypeId IN
(
SELECT Id FROM Common.AccountType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)

DELETE FROM Tax.TaxCompanyEngagementDetails WHERE TaxCompanyEngagementId IN
(
SELECT Id FROM Tax.TaxCompanyEngagement WHERE TaxCompanyId IN
(
SELECT Id FROM Tax.TaxCompany WHERE TaxCompanyTypeId IN
(
SELECT Id FROM Common.AccountType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)

DELETE FROM Tax.TaxMenuPermissions WHERE TaxCompanyMenuMasterId IN
(
SELECT Id FROM Tax.TaxCompanyMenuMaster WHERE EngagementId IN
(
SELECT Id FROM Tax.TaxCompanyEngagement WHERE TaxCompanyId IN
(
SELECT Id FROM Tax.TaxCompany WHERE TaxCompanyTypeId IN
(
SELECT Id FROM Common.AccountType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)
)

DELETE FROM Tax.TaxCompanyMenuMaster WHERE EngagementId IN
(
SELECT Id FROM Tax.TaxCompanyEngagement WHERE TaxCompanyId IN
(
SELECT Id FROM Tax.TaxCompany WHERE TaxCompanyTypeId IN
(
SELECT Id FROM Common.AccountType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)

DELETE FROM Tax.TaxMenu WHERE EngagementId IN
(
SELECT Id FROM Tax.TaxCompanyEngagement WHERE TaxCompanyId IN
(
SELECT Id FROM Tax.TaxCompany WHERE TaxCompanyTypeId IN
(
SELECT Id FROM Common.AccountType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)

DELETE FROM Tax.TemplateVariable WHERE EngagementId IN
(
SELECT Id FROM Tax.TaxCompanyEngagement WHERE TaxCompanyId IN
(
SELECT Id FROM Tax.TaxCompany WHERE TaxCompanyTypeId IN
(
SELECT Id FROM Common.AccountType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)

DELETE FROM Tax.UserApproval WHERE EngagementId IN
(
SELECT Id FROM Tax.TaxCompanyEngagement WHERE TaxCompanyId IN
(
SELECT Id FROM Tax.TaxCompany WHERE TaxCompanyTypeId IN
(
SELECT Id FROM Common.AccountType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)

DELETE FROM Tax.TaxCompanyEngagement WHERE TaxCompanyId IN
(
SELECT Id FROM Tax.TaxCompany WHERE TaxCompanyTypeId IN
(
SELECT Id FROM Common.AccountType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)

DELETE FROM Tax.TaxMenu WHERE TaxCompanyId  IN
(
SELECT Id FROM Tax.TaxCompany WHERE TaxCompanyTypeId IN
(
SELECT Id FROM Common.AccountType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)

DELETE FROM Tax.TaxCompany WHERE TaxCompanyTypeId IN
(
SELECT Id FROM Common.AccountType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)

DELETE FROM HR.BankFileDetail WHERE TypeId IN
(
SELECT Id FROM HR.EmployeeClaim1 WHERE ClientId IN
(
SELECT Id FROM WorkFlow.Client WHERE ClientTypeId IN
(
SELECT Id FROM Common.AccountType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)

DELETE FROM HR.EmployeeClaimDetail WHERE EmployeeClaimId IN
(
SELECT Id FROM HR.EmployeeClaim1 WHERE ClientId IN
(
SELECT Id FROM WorkFlow.Client WHERE ClientTypeId IN
(
SELECT Id FROM Common.AccountType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)

DELETE FROM HR.EmployeeClaim1 WHERE ClientId IN
(
SELECT Id FROM WorkFlow.Client WHERE ClientTypeId IN
(
SELECT Id FROM Common.AccountType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)

DELETE FROM Common.TimeLogDetailSplit WHERE TimelogDetailId IN
(
SELECT Id FROM Common.TimeLogDetail WHERE TimeLogScheduleId IN
(
SELECT Id FROM Common.TimeLogSchedule WHERE CaseId IN
(
SELECT Id FROM WorkFlow.CaseGroup WHERE ClientId IN
(
SELECT Id FROM WorkFlow.Client WHERE ClientTypeId IN
(
SELECT Id FROM Common.AccountType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)
)
)

DELETE FROM Common.TimeLogDetail WHERE TimeLogScheduleId IN
(
SELECT Id FROM Common.TimeLogSchedule WHERE CaseId IN
(
SELECT Id FROM WorkFlow.CaseGroup WHERE ClientId IN
(
SELECT Id FROM WorkFlow.Client WHERE ClientTypeId IN
(
SELECT Id FROM Common.AccountType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)
)

DELETE FROM Common.TimeLogSchedule WHERE CaseId IN
(
SELECT Id FROM WorkFlow.CaseGroup WHERE ClientId IN
(
SELECT Id FROM WorkFlow.Client WHERE ClientTypeId IN
(
SELECT Id FROM Common.AccountType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)

DELETE FROM HR.BankFileDetail WHERE TypeId IN
(
SELECT Id FROM HR.EmployeeClaim1 WHERE CaseGroupId IN
(
SELECT Id FROM WorkFlow.CaseGroup WHERE ClientId IN
(
SELECT Id FROM WorkFlow.Client WHERE ClientTypeId IN
(
SELECT Id FROM Common.AccountType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)
)

DELETE FROM HR.EmployeeClaimDetail WHERE EmployeeClaimId IN
(
SELECT Id FROM HR.EmployeeClaim1 WHERE CaseGroupId IN
(
SELECT Id FROM WorkFlow.CaseGroup WHERE ClientId IN
(
SELECT Id FROM WorkFlow.Client WHERE ClientTypeId IN
(
SELECT Id FROM Common.AccountType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)
)

DELETE FROM HR.EmployeeClaim1 WHERE CaseGroupId IN
(
SELECT Id FROM WorkFlow.CaseGroup WHERE ClientId IN
(
SELECT Id FROM WorkFlow.Client WHERE ClientTypeId IN
(
SELECT Id FROM Common.AccountType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)

DELETE FROM WorkFlow.CaseAmendDateOfCompletion WHERE CaseId IN
(
SELECT Id FROM WorkFlow.CaseGroup WHERE ClientId IN
(
SELECT Id FROM WorkFlow.Client WHERE ClientTypeId IN
(
SELECT Id FROM Common.AccountType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)

DELETE FROM WorkFlow.CaseDesignation WHERE CaseId IN
(
SELECT Id FROM WorkFlow.CaseGroup WHERE ClientId IN
(
SELECT Id FROM WorkFlow.Client WHERE ClientTypeId IN
(
SELECT Id FROM Common.AccountType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)

-------SELECT * FROM WorkFlow.CaseDoc ----> No Data in Table

DELETE FROM Common.TimeLogDetailSplit WHERE CaseFeatureId IN
(
SELECT Id FROM WorkFlow.CaseFeature WHERE CaseId IN
(
SELECT Id FROM WorkFlow.CaseGroup WHERE ClientId IN
(
SELECT Id FROM WorkFlow.Client WHERE ClientTypeId IN
(
SELECT Id FROM Common.AccountType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)
)

DELETE FROM WorkFlow.ScheduleTaskDetail WHERE CaseFeatureId IN
(
SELECT Id FROM WorkFlow.CaseFeature WHERE CaseId IN
(
SELECT Id FROM WorkFlow.CaseGroup WHERE ClientId IN
(
SELECT Id FROM WorkFlow.Client WHERE ClientTypeId IN
(
SELECT Id FROM Common.AccountType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)
)

DELETE FROM WorkFlow.CaseFeature WHERE CaseId IN
(
SELECT Id FROM WorkFlow.CaseGroup WHERE ClientId IN
(
SELECT Id FROM WorkFlow.Client WHERE ClientTypeId IN
(
SELECT Id FROM Common.AccountType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)

DELETE FROM WorkFlow.CaseIncharge WHERE CaseId IN
(
SELECT Id FROM WorkFlow.CaseGroup WHERE ClientId IN
(
SELECT Id FROM WorkFlow.Client WHERE ClientTypeId IN
(
SELECT Id FROM Common.AccountType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)

DELETE FROM WorkFlow.CaseMileStone WHERE CaseId IN
(
SELECT Id FROM WorkFlow.CaseGroup WHERE ClientId IN
(
SELECT Id FROM WorkFlow.Client WHERE ClientTypeId IN
(
SELECT Id FROM Common.AccountType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)

----------SELECT * FROM WorkFlow.CasesAssigned ----> No Data in Table

DELETE FROM WorkFlow.CaseStatusChange WHERE CaseId IN
(
SELECT Id FROM WorkFlow.CaseGroup WHERE ClientId IN
(
SELECT Id FROM WorkFlow.Client WHERE ClientTypeId IN
(
SELECT Id FROM Common.AccountType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)

DELETE FROM WorkFlow.Claim WHERE CaseId IN
(
SELECT Id FROM WorkFlow.CaseGroup WHERE ClientId IN
(
SELECT Id FROM WorkFlow.Client WHERE ClientTypeId IN
(
SELECT Id FROM Common.AccountType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)

DELETE FROM WorkFlow.Incidental WHERE InvoiceId IN
(
SELECT Id FROM WorkFlow.Invoice WHERE CaseId IN
(
SELECT Id FROM WorkFlow.CaseGroup WHERE ClientId IN
(
SELECT Id FROM WorkFlow.Client WHERE ClientTypeId IN
(
SELECT Id FROM Common.AccountType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)
)

DELETE FROM WorkFlow.InvoiceDesignation WHERE InvoiceId IN
(
SELECT Id FROM WorkFlow.Invoice WHERE CaseId IN
(
SELECT Id FROM WorkFlow.CaseGroup WHERE ClientId IN
(
SELECT Id FROM WorkFlow.Client WHERE ClientTypeId IN
(
SELECT Id FROM Common.AccountType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)
)

-------SELECT * FROM WorkFlow.InvoiceState ----> No Data in Table

DELETE FROM WorkFlow.Invoice WHERE CaseId IN
(
SELECT Id FROM WorkFlow.CaseGroup WHERE ClientId IN
(
SELECT Id FROM WorkFlow.Client WHERE ClientTypeId IN
(
SELECT Id FROM Common.AccountType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)

DELETE FROM WorkFlow.InvoiceDesignation WHERE CaseId IN
(
SELECT Id FROM WorkFlow.CaseGroup WHERE ClientId IN
(
SELECT Id FROM WorkFlow.Client WHERE ClientTypeId IN
(
SELECT Id FROM Common.AccountType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
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
SELECT Id FROM WorkFlow.CaseGroup WHERE ClientId IN
(
SELECT Id FROM WorkFlow.Client WHERE ClientTypeId IN
(
SELECT Id FROM Common.AccountType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
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
SELECT Id FROM WorkFlow.CaseGroup WHERE ClientId IN
(
SELECT Id FROM WorkFlow.Client WHERE ClientTypeId IN
(
SELECT Id FROM Common.AccountType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)
)
)

DELETE FROM WorkFlow.ScheduleDetail WHERE MasterId IN
(
SELECT Id FROM WorkFlow.Schedule WHERE CaseId IN
(
SELECT Id FROM WorkFlow.CaseGroup WHERE ClientId IN
(
SELECT Id FROM WorkFlow.Client WHERE ClientTypeId IN
(
SELECT Id FROM Common.AccountType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)
)

DELETE FROM WorkFlow.Schedule WHERE CaseId IN
(
SELECT Id FROM WorkFlow.CaseGroup WHERE ClientId IN
(
SELECT Id FROM WorkFlow.Client WHERE ClientTypeId IN
(
SELECT Id FROM Common.AccountType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)


DELETE FROM WorkFlow.ScheduleTaskNew WHERE ScheduleDetailId IN
(
SELECT Id FROM WorkFlow.ScheduleDetailNew WHERE MasterId IN
(
SELECT Id FROM WorkFlow.ScheduleNew WHERE CaseId IN
(
SELECT Id FROM WorkFlow.CaseGroup WHERE ClientId IN
(
SELECT Id FROM WorkFlow.Client WHERE ClientTypeId IN
(
SELECT Id FROM Common.AccountType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)
)
)


DELETE FROM WorkFlow.ScheduleDetailNew WHERE MasterId IN
(
SELECT Id FROM WorkFlow.ScheduleNew WHERE CaseId IN
(
SELECT Id FROM WorkFlow.CaseGroup WHERE ClientId IN
(
SELECT Id FROM WorkFlow.Client WHERE ClientTypeId IN
(
SELECT Id FROM Common.AccountType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)
)

DELETE FROM WorkFlow.ScheduleNew WHERE CaseId IN
(
SELECT Id FROM WorkFlow.CaseGroup WHERE ClientId IN
(
SELECT Id FROM WorkFlow.Client WHERE ClientTypeId IN
(
SELECT Id FROM Common.AccountType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)


DELETE FROM WorkFlow.ScheduleTaskDetail WHERE ScheduleTaskId IN
(
SELECT Id FROM WorkFlow.ScheduleTask WHERE CaseId IN
(
SELECT Id FROM WorkFlow.CaseGroup WHERE ClientId IN
(
SELECT Id FROM WorkFlow.Client WHERE ClientTypeId IN
(
SELECT Id FROM Common.AccountType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)
)


DELETE FROM WorkFlow.ScheduleTask WHERE CaseId IN
(
SELECT Id FROM WorkFlow.CaseGroup WHERE ClientId IN
(
SELECT Id FROM WorkFlow.Client WHERE ClientTypeId IN
(
SELECT Id FROM Common.AccountType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)


DELETE FROM WorkFlow.ScheduleTaskNew WHERE CaseId IN
(
SELECT Id FROM WorkFlow.CaseGroup WHERE ClientId IN
(
SELECT Id FROM WorkFlow.Client WHERE ClientTypeId IN
(
SELECT Id FROM Common.AccountType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)


DELETE FROM WorkFlow.CaseGroup WHERE ClientId IN
(
SELECT Id FROM WorkFlow.Client WHERE ClientTypeId IN
(
SELECT Id FROM Common.AccountType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)

DELETE FROM WorkFlow.ClientContact WHERE ClientId IN
(
SELECT Id FROM WorkFlow.Client WHERE ClientTypeId IN
(
SELECT Id FROM Common.AccountType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)

DELETE FROM WorkFlow.ClientStatusChange WHERE ClientId IN
(
SELECT Id FROM WorkFlow.Client WHERE ClientTypeId IN
(
SELECT Id FROM Common.AccountType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)

DELETE FROM WorkFlow.Client WHERE ClientTypeId IN
(
SELECT Id FROM Common.AccountType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)

DELETE FROM Common.AccountType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)

----------------------/////////////////////////////////////////////////////////////////////////////// Common.ActivityHistory \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

DELETE FROM Common.ActivityHistory WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)

----------------------/////////////////////////////////////////////////////////////////////////////// Common.Addresses \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

DELETE FROM Common.Addresses WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)

----------------------/////////////////////////////////////////////////////////////////////////////// Common.AGMSetting \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

DELETE FROM Common.AGMSetting WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)

----------------------/////////////////////////////////////////////////////////////////////////////// Common.Attendance \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

DELETE FROM Common.AttendanceDetails WHERE AttendenceId IN
(
SELECT Id FROM Common.Attendance WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)

DELETE FROM Common.Attendance WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)

----------------------/////////////////////////////////////////////////////////////////////////////// Common.AttendanceAttachments \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

DELETE FROM Common.AttendanceAttachments WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)

----------------------/////////////////////////////////////////////////////////////////////////////// Common.AttendanceRules \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

DELETE FROM Common.AttendanceRules WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)

----------------------/////////////////////////////////////////////////////////////////////////////// Common.AuditFirm \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

----------------------SELECT * FROM Common.AuditFirm WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo) ------> No Data in Table

----------------------/////////////////////////////////////////////////////////////////////////////// Common.AutoNumber \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

DELETE FROM Common.AutoNumberCompany WHERE AutonumberId IN
(
SELECT Id FROM Common.AutoNumber WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)

DELETE FROM Common.AutoNumberDetail WHERE MasterId IN
(
SELECT Id FROM Common.AutoNumber WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)

DELETE FROM Common.AutoNumber WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)

----------------------/////////////////////////////////////////////////////////////////////////////// Common.AutoNumberCompany \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

DELETE FROM Common.AutoNumberCompany WHERE SubsideryCompanyId  IN (SELECT Id FROM @CompanyInfo)

----------------------/////////////////////////////////////////////////////////////////////////////// Common.Bank \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

DELETE FROM HR.CompanyPayrollSettingsDetail WHERE BankId IN
(
SELECT Id FROM Common.Bank WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)

DELETE FROM Common.Bank WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)

----------------------/////////////////////////////////////////////////////////////////////////////// Common.BeanSOAReminderBatchList \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

DELETE FROM Common.BeanSOAReminderBatchListDetails WHERE MasterId IN
(
SELECT Id FROM Common.BeanSOAReminderBatchList WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)

DELETE FROM Common.BeanSOAReminderBatchList WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)

----------------------/////////////////////////////////////////////////////////////////////////////// Common.BladeType \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

DELETE FROM Common.BladeType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)

----------------------/////////////////////////////////////////////////////////////////////////////// Common.Calender \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

DELETE FROM Common.CalenderDetails WHERE MasterId IN
(
SELECT Id FROM Common.Calender WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)

DELETE FROM Common.CalenderSchedule WHERE CalenderId IN
(
SELECT Id FROM Common.Calender WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)

DELETE FROM Common.Calender WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)

----------------------/////////////////////////////////////////////////////////////////////////////// Common.ChangesHistory \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

DELETE FROM Common.ChangesHistory WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)

----------------------/////////////////////////////////////////////////////////////////////////////// Common.CompanyFeatures \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

DELETE FROM Common.CompanyFeatures WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)

----------------------/////////////////////////////////////////////////////////////////////////////// Common.CompanyGlobalSettings \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

DELETE FROM Common.CompanyGlobalSettings WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)

----------------------/////////////////////////////////////////////////////////////////////////////// Common.CompanyModule \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

DELETE FROM Common.CompanyModule WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)

----------------------/////////////////////////////////////////////////////////////////////////////// Common.CompanyModuleSetUp \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

DELETE FROM Common.CompanyModuleSetUp WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)

----------------------/////////////////////////////////////////////////////////////////////////////// Common.CompanyService \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

DELETE FROM Common.CompanyService WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)

----------------------/////////////////////////////////////////////////////////////////////////////// Common.CompanySetting \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

DELETE FROM Common.CompanySetting WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)

----------------------/////////////////////////////////////////////////////////////////////////////// Common.CompanyTemplateSettings \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

DELETE FROM Common.CompanyTemplateSettings WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)

----------------------/////////////////////////////////////////////////////////////////////////////// Common.CompanyUser \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

DELETE FROM Auth.UserPermission WHERE CompanyUserId IN
(
SELECT Id FROM Common.CompanyUser WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)

DELETE FROM Auth.UserPermissionNew WHERE CompanyUserId IN
(
SELECT Id FROM Common.CompanyUser WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)

DELETE FROM Auth.UserRole WHERE CompanyUserId IN
(
SELECT Id FROM Common.CompanyUser WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)

DELETE FROM Auth.UserPermissionNew WHERE UserRoleId IN
(
SELECT Id FROM Auth.UserRoleNew WHERE CompanyUserId IN
(
SELECT Id FROM Common.CompanyUser WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)

DELETE FROM Auth.UserRoleNew WHERE CompanyUserId IN
(
SELECT Id FROM Common.CompanyUser WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)

DELETE FROM ClientCursor.AccountIncharge WHERE CompanyUserId IN
(
SELECT Id FROM Common.CompanyUser WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)

DELETE FROM ClientCursor.OpportunityIncharge WHERE CompanyUserId IN
(
SELECT Id FROM Common.CompanyUser WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)

DELETE FROM Common.CompanyUserDetail WHERE CompanyUserId IN
(
SELECT Id FROM Common.CompanyUser WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)

DELETE FROM Common.CompanyUserSubscription WHERE CompanyUserId IN
(
SELECT Id FROM Common.CompanyUser WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)

DELETE FROM Common.EngagementUsers WHERE CompanyUserId IN
(
SELECT Id FROM Common.CompanyUser WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)

DELETE FROM HR.EmployeRecandApprovers WHERE TypeId IN
(
SELECT Id FROM Common.CompanyUser WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)

DELETE FROM HR.Evaluation WHERE CompanyUserId IN
(
SELECT Id FROM Common.CompanyUser WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)

DELETE FROM HR.Requisition WHERE ApproverId IN
(
SELECT Id FROM Common.CompanyUser WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)

DELETE FROM HR.TeamCalendarDetail WHERE MasterId IN
(
SELECT Id FROM HR.TeamCalendar WHERE CompanyUserId IN
(
SELECT Id FROM Common.CompanyUser WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)

DELETE FROM HR.TeamCalendar WHERE CompanyUserId IN
(
SELECT Id FROM Common.CompanyUser WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)

DELETE FROM HR.TrainerCourse WHERE TrainerId IN
(
SELECT Id FROM HR.Trainer WHERE CompanyUserId IN
(
SELECT Id FROM Common.CompanyUser WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)

DELETE FROM HR.Trainer WHERE CompanyUserId IN
(
SELECT Id FROM Common.CompanyUser WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)

DELETE FROM License.UserSubscription WHERE CompanyUserId IN
(
SELECT Id FROM Common.CompanyUser WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)

DELETE FROM WorkFlow.CaseIncharge WHERE CompanyUserId IN
(
SELECT Id FROM Common.CompanyUser WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)

DELETE FROM Common.CompanyUser WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)

----------------------/////////////////////////////////////////////////////////////////////////////// Common.CompanyUserDetail \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

DELETE FROM Common.CompanyUserDetail WHERE ServiceEntityId  IN (SELECT Id FROM @CompanyInfo)

----------------------/////////////////////////////////////////////////////////////////////////////// Common.CompanyUserSubscription \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

DELETE FROM Common.CompanyUserSubscription WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)

----------------------/////////////////////////////////////////////////////////////////////////////// Common.Configuration \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

DELETE FROM Common.Configuration WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)

----------------------/////////////////////////////////////////////////////////////////////////////// Common.Contact \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

DELETE FROM Audit.ClientAndEngagementIndependenceConfirmation WHERE AuditCompanyContactId IN 
(
SELECT Id FROM Audit.AuditCompanyContact WHERE ContactId IN
(
SELECT Id FROM Common.Contact WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)

DELETE FROM Audit.DeclarationOfDirectors WHERE AuditCompanyContactId IN 
(
SELECT Id FROM Audit.AuditCompanyContact WHERE ContactId IN
(
SELECT Id FROM Common.Contact WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)

DELETE FROM Audit.DirectorRemunerationDetails WHERE DirectorRemunerationId IN 
(
SELECT Id FROM Audit.DirectorRemuneration WHERE AuditCompanyContactId IN 
(
SELECT Id FROM Audit.AuditCompanyContact WHERE ContactId IN
(
SELECT Id FROM Common.Contact WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)

DELETE FROM Audit.DirectorRemuneration WHERE AuditCompanyContactId IN 
(
SELECT Id FROM Audit.AuditCompanyContact WHERE ContactId IN
(
SELECT Id FROM Common.Contact WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)

DELETE FROM Audit.AuditCompanyContact WHERE ContactId IN
(
SELECT Id FROM Common.Contact WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)

DELETE FROM ClientCursor.VendorContact WHERE ContactId IN
(
SELECT Id FROM Common.Contact WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)

DELETE FROM Common.ContactDetails WHERE ContactId IN
(
SELECT Id FROM Common.Contact WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)

DELETE FROM Tax.ClientAndEngagementIndependenceConfirmation WHERE TaxCompanyContactId IN
(
SELECT Id FROM Tax.TaxCompanyContact WHERE ContactId IN
(
SELECT Id FROM Common.Contact WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)

DELETE FROM Tax.DirectorRemunerationDetails WHERE DirectorRemunerationId IN
(
SELECT Id FROM Tax.DirectorRemuneration WHERE TaxCompanyContactId IN
(
SELECT Id FROM Tax.TaxCompanyContact WHERE ContactId IN
(
SELECT Id FROM Common.Contact WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)

DELETE FROM Tax.DirectorRemuneration WHERE TaxCompanyContactId IN
(
SELECT Id FROM Tax.TaxCompanyContact WHERE ContactId IN
(
SELECT Id FROM Common.Contact WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)

DELETE FROM Tax.TaxCompanyContact WHERE ContactId IN
(
SELECT Id FROM Common.Contact WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)

DELETE FROM WorkFlow.ClientContact WHERE ContactId IN
(
SELECT Id FROM Common.Contact WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)

DELETE FROM Common.Contact WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)

----------------------/////////////////////////////////////////////////////////////////////////////// Common.ControlCodeCategory \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

DELETE FROM Common.ControlCode WHERE ControlCategoryId IN
(
SELECT Id FROM Common.ControlCodeCategory WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)

DELETE FROM Common.ControlCodeCategoryModule WHERE ControlCategoryId IN
(
SELECT Id FROM Common.ControlCodeCategory WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)

DELETE FROM Common.ControlCodeCategory WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)

----------------------/////////////////////////////////////////////////////////////////////////////// Common.ControlCodeCategoryModule \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

DELETE FROM Common.ControlCodeCategoryModule WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)

----------------------/////////////////////////////////////////////////////////////////////////////// Common.DeleteLog \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

DELETE FROM Common.DeleteLog WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)

----------------------/////////////////////////////////////////////////////////////////////////////// Common.Department \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

DELETE FROM Common.CalenderDetails WHERE DepartmentId IN
(
SELECT Id FROM Common.Department WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)

DELETE FROM ClientCursor.OpportunityDesignation WHERE DepartmentDesignationId IN
(
SELECT Id FROM Common.DepartmentDesignation WHERE DepartmentId IN
(
SELECT Id FROM Common.Department WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)

DELETE FROM Common.CalenderDetails WHERE DesignationId IN
(
SELECT Id FROM Common.DepartmentDesignation WHERE DepartmentId IN
(
SELECT Id FROM Common.Department WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)

DELETE FROM Common.DesignationHourlyRate WHERE DesignationId IN
(
SELECT Id FROM Common.DepartmentDesignation WHERE DepartmentId IN
(
SELECT Id FROM Common.Department WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)

DELETE FROM Common.DesignationLevelChargeoutRate WHERE DesignationId IN
(
SELECT Id FROM Common.DepartmentDesignation WHERE DepartmentId IN
(
SELECT Id FROM Common.Department WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)

DELETE FROM Common.TimeLogDetailSplit WHERE TimelogDetailId IN
(
SELECT Id FROM Common.TimeLogDetail WHERE TimeLogScheduleId IN
(
SELECT Id FROM Common.TimeLogSchedule WHERE DesignationId IN
(
SELECT Id FROM Common.DepartmentDesignation WHERE DepartmentId IN
(
SELECT Id FROM Common.Department WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)
)

DELETE FROM Common.TimeLogDetail WHERE TimeLogScheduleId IN
(
SELECT Id FROM Common.TimeLogSchedule WHERE DesignationId IN
(
SELECT Id FROM Common.DepartmentDesignation WHERE DepartmentId IN
(
SELECT Id FROM Common.Department WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)

DELETE FROM Common.TimeLogSchedule WHERE DesignationId IN
(
SELECT Id FROM Common.DepartmentDesignation WHERE DepartmentId IN
(
SELECT Id FROM Common.Department WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)

DELETE FROM HR.AppraiseAppraisers WHERE AppraisalDetailId IN
(
SELECT Id FROM HR.AppraisalAppraiseeDetails WHERE DesignationId IN
(
SELECT Id FROM Common.DepartmentDesignation WHERE DepartmentId IN
(
SELECT Id FROM Common.Department WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)

DELETE FROM HR.AppraiserIncharge WHERE AppraisalDetailId IN
(
SELECT Id FROM HR.AppraisalAppraiseeDetails WHERE DesignationId IN
(
SELECT Id FROM Common.DepartmentDesignation WHERE DepartmentId IN
(
SELECT Id FROM Common.Department WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)

DELETE FROM HR.AppraisalAppraiseeDetails WHERE DesignationId IN
(
SELECT Id FROM Common.DepartmentDesignation WHERE DepartmentId IN
(
SELECT Id FROM Common.Department WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)

DELETE FROM HR.AppraisalAppraiserDetails WHERE DesignationId IN
(
SELECT Id FROM Common.DepartmentDesignation WHERE DepartmentId IN
(
SELECT Id FROM Common.Department WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)

DELETE FROM HR.AppraisalDetail WHERE DesignationId IN
(
SELECT Id FROM Common.DepartmentDesignation WHERE DepartmentId IN
(
SELECT Id FROM Common.Department WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)

DELETE FROM HR.BankFileDetail WHERE TypeId IN
(
SELECT Id FROM HR.EmployeeClaim1 WHERE DesignationId IN
(
SELECT Id FROM Common.DepartmentDesignation WHERE DepartmentId IN
(
SELECT Id FROM Common.Department WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)

DELETE FROM HR.EmployeeClaimDetail WHERE EmployeeClaimId IN
(
SELECT Id FROM HR.EmployeeClaim1 WHERE DesignationId IN
(
SELECT Id FROM Common.DepartmentDesignation WHERE DepartmentId IN
(
SELECT Id FROM Common.Department WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)

DELETE FROM HR.EmployeeClaim1 WHERE DesignationId IN
(
SELECT Id FROM Common.DepartmentDesignation WHERE DepartmentId IN
(
SELECT Id FROM Common.Department WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)

DELETE FROM HR.EmployeeDepartmentHistory WHERE EmployeeDepartmentId IN
(
SELECT Id FROM HR.EmployeeDepartment WHERE DepartmentDesignationId IN
(
SELECT Id FROM Common.DepartmentDesignation WHERE DepartmentId IN
(
SELECT Id FROM Common.Department WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)

DELETE FROM HR.EmployeeDepartment WHERE DepartmentDesignationId IN
(
SELECT Id FROM Common.DepartmentDesignation WHERE DepartmentId IN
(
SELECT Id FROM Common.Department WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)

DELETE FROM HR.ApplicantHistory WHERE JobApplicationId IN
(
SELECT Id FROM HR.JobApplication WHERE JobPostingId IN
(
SELECT Id FROM HR.JobPosting WHERE DesignationId IN
(
SELECT Id FROM Common.DepartmentDesignation WHERE DepartmentId IN
(
SELECT Id FROM Common.Department WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)
)

DELETE FROM HR.CompanyReferals WHERE JobApplicationId IN
(
SELECT Id FROM HR.JobApplication WHERE JobPostingId IN
(
SELECT Id FROM HR.JobPosting WHERE DesignationId IN
(
SELECT Id FROM Common.DepartmentDesignation WHERE DepartmentId IN
(
SELECT Id FROM Common.Department WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)
)

DELETE FROM HR.Education WHERE ApplicationId IN
(
SELECT Id FROM HR.JobApplication WHERE JobPostingId IN
(
SELECT Id FROM HR.JobPosting WHERE DesignationId IN
(
SELECT Id FROM Common.DepartmentDesignation WHERE DepartmentId IN
(
SELECT Id FROM Common.Department WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)
)

DELETE FROM HR.EmploymentHistory WHERE ApplicationId IN
(
SELECT Id FROM HR.JobApplication WHERE JobPostingId IN
(
SELECT Id FROM HR.JobPosting WHERE DesignationId IN
(
SELECT Id FROM Common.DepartmentDesignation WHERE DepartmentId IN
(
SELECT Id FROM Common.Department WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)
)

DELETE FROM HR.Evaluation WHERE ApplicationId IN
(
SELECT Id FROM HR.JobApplication WHERE JobPostingId IN
(
SELECT Id FROM HR.JobPosting WHERE DesignationId IN
(
SELECT Id FROM Common.DepartmentDesignation WHERE DepartmentId IN
(
SELECT Id FROM Common.Department WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)
)

DELETE FROM HR.FamilyPerticulars WHERE ApplicationId IN
(
SELECT Id FROM HR.JobApplication WHERE JobPostingId IN
(
SELECT Id FROM HR.JobPosting WHERE DesignationId IN
(
SELECT Id FROM Common.DepartmentDesignation WHERE DepartmentId IN
(
SELECT Id FROM Common.Department WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)
)

DELETE FROM HR.Hobbies WHERE JobApplicationId IN
(
SELECT Id FROM HR.JobApplication WHERE JobPostingId IN
(
SELECT Id FROM HR.JobPosting WHERE DesignationId IN
(
SELECT Id FROM Common.DepartmentDesignation WHERE DepartmentId IN
(
SELECT Id FROM Common.Department WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)
)

DELETE FROM HR.Evaluation WHERE InterviewId IN
(
SELECT Id FROM HR.Interview WHERE ApplicationId IN
(
SELECT Id FROM HR.JobApplication WHERE JobPostingId IN
(
SELECT Id FROM HR.JobPosting WHERE DesignationId IN
(
SELECT Id FROM Common.DepartmentDesignation WHERE DepartmentId IN
(
SELECT Id FROM Common.Department WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)
)
)

DELETE FROM HR.Interview WHERE ApplicationId IN
(
SELECT Id FROM HR.JobApplication WHERE JobPostingId IN
(
SELECT Id FROM HR.JobPosting WHERE DesignationId IN
(
SELECT Id FROM Common.DepartmentDesignation WHERE DepartmentId IN
(
SELECT Id FROM Common.Department WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)
)

DELETE FROM HR.JobApplication WHERE JobPostingId IN
(
SELECT Id FROM HR.JobPosting WHERE DesignationId IN
(
SELECT Id FROM Common.DepartmentDesignation WHERE DepartmentId IN
(
SELECT Id FROM Common.Department WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)

DELETE FROM HR.JobPosting WHERE DesignationId IN
(
SELECT Id FROM Common.DepartmentDesignation WHERE DepartmentId IN
(
SELECT Id FROM Common.Department WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)

DELETE FROM HR.LeaveTypeDetails WHERE DesignationId IN
(
SELECT Id FROM Common.DepartmentDesignation WHERE DepartmentId IN
(
SELECT Id FROM Common.Department WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)

DELETE FROM HR.PayComponentDetail WHERE DesignationId IN
(
SELECT Id FROM Common.DepartmentDesignation WHERE DepartmentId IN
(
SELECT Id FROM Common.Department WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)

DELETE FROM HR.Requisition WHERE DesignationId IN
(
SELECT Id FROM Common.DepartmentDesignation WHERE DepartmentId IN
(
SELECT Id FROM Common.Department WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)

DELETE FROM HR.TrainingAttendee WHERE DesignationId IN
(
SELECT Id FROM Common.DepartmentDesignation WHERE DepartmentId IN
(
SELECT Id FROM Common.Department WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)

DELETE FROM WorkFlow.CaseDesignation WHERE DepartmentDesignationId IN
(
SELECT Id FROM Common.DepartmentDesignation WHERE DepartmentId IN
(
SELECT Id FROM Common.Department WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)

DELETE FROM WorkFlow.ScheduleTaskDetail WHERE ScheduleTaskId IN
(
SELECT Id FROM WorkFlow.ScheduleTask WHERE ScheduleDetailId IN
(
SELECT Id FROM WorkFlow.ScheduleDetail WHERE DesignationId IN
(
SELECT Id FROM Common.DepartmentDesignation WHERE DepartmentId IN
(
SELECT Id FROM Common.Department WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)
)

DELETE FROM WorkFlow.ScheduleTask WHERE ScheduleDetailId IN
(
SELECT Id FROM WorkFlow.ScheduleDetail WHERE DesignationId IN
(
SELECT Id FROM Common.DepartmentDesignation WHERE DepartmentId IN
(
SELECT Id FROM Common.Department WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)

DELETE FROM WorkFlow.ScheduleDetail WHERE DesignationId IN
(
SELECT Id FROM Common.DepartmentDesignation WHERE DepartmentId IN
(
SELECT Id FROM Common.Department WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)

DELETE FROM WorkFlow.ScheduleTaskNew WHERE ScheduleDetailId IN
(
SELECT Id FROM WorkFlow.ScheduleDetailNew WHERE DesignationId IN
(
SELECT Id FROM Common.DepartmentDesignation WHERE DepartmentId IN
(
SELECT Id FROM Common.Department WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)

DELETE FROM WorkFlow.ScheduleDetailNew WHERE DesignationId IN
(
SELECT Id FROM Common.DepartmentDesignation WHERE DepartmentId IN
(
SELECT Id FROM Common.Department WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)

DELETE FROM WorkFlow.ScheduleTaskNew WHERE DesignationId IN
(
SELECT Id FROM Common.DepartmentDesignation WHERE DepartmentId IN
(
SELECT Id FROM Common.Department WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)

DELETE FROM Common.DepartmentDesignation WHERE DepartmentId IN
(
SELECT Id FROM Common.Department WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)

DELETE FROM HR.LeaveTypeDetails WHERE DepartmentId IN
(
SELECT Id FROM Common.Department WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)


DELETE FROM HR.JobPosting WHERE DepartmentId IN
(
SELECT Id FROM Common.Department WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)

DELETE FROM Common.Department WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo) ----> All details tables data was deleted when deleted data from DepartmentDesignation

----------------------/////////////////////////////////////////////////////////////////////////////// Common.Designation \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

DELETE FROM Common.Designation WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)

----------------------/////////////////////////////////////////////////////////////////////////////// Common.DesignationLevel \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

DELETE FROM Common.DesignationLevelChargeoutRate WHERE DesignationLevelId IN
(
SELECT Id FROM Common.DesignationLevel WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)

DELETE FROM Common.DesignationLevel WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)

----------------------/////////////////////////////////////////////////////////////////////////////// Common.DocRepository \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

DELETE FROM Common.DocRepository WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)

----------------------/////////////////////////////////////////////////////////////////////////////// Common.Employee \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

--------------------SELECT Id FROM Common.EmployeeChargeRate_ToBeDeleted ----> No Data in Table
--------------------SELECT Id FROM Common.EmployeeQualification ----> No Data in Table
--------------------SELECT Id FROM Common.EmployeeSkill ----> No Data in Table

DELETE FROM Common.AttendanceDetails WHERE EmployeeId IN
(
SELECT Id FROM Common.Employee WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)

DELETE FROM Common.CalenderDetails WHERE EmployeeId IN
(
SELECT Id FROM Common.Employee WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)

DELETE FROM Common.EmployeeServiceGroup WHERE EmployeeId IN
(
SELECT Id FROM Common.Employee WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)

--------------SELECT Id FROM Common.EmployeeSkill -----> No Data in Table

DELETE FROM Common.TimeLogDetailSplit WHERE TimelogDetailId IN
(
SELECT Id FROM Common.TimeLogDetail WHERE MasterId IN
(
SELECT Id FROM Common.TimeLog WHERE EmployeeId IN
(
SELECT Id FROM Common.Employee WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)

DELETE FROM Common.TimeLogDetail WHERE MasterId IN
(
SELECT Id FROM Common.TimeLog WHERE EmployeeId IN
(
SELECT Id FROM Common.Employee WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)

DELETE FROM WorkFlow.TimeLogTaskDetails WHERE TimeLogTaskId IN
(
SELECT Id FROM WorkFlow.TimeLogTasks WHERE TimeLogId IN
(
SELECT Id FROM Common.TimeLog WHERE EmployeeId IN
(
SELECT Id FROM Common.Employee WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)

DELETE FROM WorkFlow.TimeLogTasks WHERE TimeLogId IN
(
SELECT Id FROM Common.TimeLog WHERE EmployeeId IN
(
SELECT Id FROM Common.Employee WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)

DELETE FROM Common.TimeLog WHERE EmployeeId IN
(
SELECT Id FROM Common.Employee WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)

DELETE FROM Common.TimeLogItemDetail WHERE EmployeeId IN
(
SELECT Id FROM Common.Employee WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)

DELETE FROM Common.TimeLogDetailSplit WHERE TimelogDetailId IN
(
SELECT Id FROM Common.TimeLogDetail WHERE TimeLogScheduleId IN
(
SELECT Id FROM Common.TimeLogSchedule WHERE EmployeeId IN
(
SELECT Id FROM Common.Employee WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)

DELETE FROM Common.TimeLogDetail WHERE TimeLogScheduleId IN
(
SELECT Id FROM Common.TimeLogSchedule WHERE EmployeeId IN
(
SELECT Id FROM Common.Employee WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)

DELETE FROM Common.TimeLogSchedule WHERE EmployeeId IN
(
SELECT Id FROM Common.Employee WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)

DELETE FROM Common.TimeLogSetup WHERE EmployeeId IN
(
SELECT Id FROM Common.Employee WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)

DELETE FROM Common.WorkWeekSetUp WHERE EmployeeId IN
(
SELECT Id FROM Common.Employee WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)

DELETE FROM HR.Appendix8A WHERE EmployeeId IN
(
SELECT Id FROM Common.Employee WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)

DELETE FROM HR.Appendix8BSectionA WHERE Appendix8BId IN
(
SELECT Id FROM HR.Appendix8B WHERE EmployeeId IN
(
SELECT Id FROM Common.Employee WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)

DELETE FROM HR.Appendix8BSectionB WHERE Appendix8BId IN
(
SELECT Id FROM HR.Appendix8B WHERE EmployeeId IN
(
SELECT Id FROM Common.Employee WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)

DELETE FROM HR.Appendix8BSectionC WHERE Appendix8BId IN
(
SELECT Id FROM HR.Appendix8B WHERE EmployeeId IN
(
SELECT Id FROM Common.Employee WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)

DELETE FROM HR.Appendix8BSectionD WHERE Appendix8BId IN
(
SELECT Id FROM HR.Appendix8B WHERE EmployeeId IN
(
SELECT Id FROM Common.Employee WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)

DELETE FROM HR.Appendix8B WHERE EmployeeId IN
(
SELECT Id FROM Common.Employee WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)

DELETE FROM HR.AppraiseAppraisers WHERE AppraisalDetailId IN
(
SELECT Id FROM HR.AppraisalAppraiseeDetails WHERE AppraisalId IN
(
SELECT Id FROM HR.Appraisal WHERE AppraiseId IN
(
SELECT Id FROM Common.Employee WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)

DELETE FROM HR.AppraiserIncharge WHERE AppraisalDetailId IN
(
SELECT Id FROM HR.AppraisalAppraiseeDetails WHERE AppraisalId IN
(
SELECT Id FROM HR.Appraisal WHERE AppraiseId IN
(
SELECT Id FROM Common.Employee WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)

DELETE FROM HR.AppraisalAppraiseeDetails WHERE AppraisalId IN
(
SELECT Id FROM HR.Appraisal WHERE AppraiseId IN
(
SELECT Id FROM Common.Employee WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)

DELETE FROM HR.AppraisalAppraiseeWeightage WHERE AppraisalId IN
(
SELECT Id FROM HR.Appraisal WHERE AppraiseId IN
(
SELECT Id FROM Common.Employee WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)

DELETE FROM HR.AppraisalAppraiserDetails WHERE AppraisalId IN
(
SELECT Id FROM HR.Appraisal WHERE AppraiseId IN
(
SELECT Id FROM Common.Employee WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)

DELETE FROM HR.AppraisalDetail WHERE AppraisalId IN
(
SELECT Id FROM HR.Appraisal WHERE AppraiseId IN
(
SELECT Id FROM Common.Employee WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)

DELETE FROM HR.AppraisalDevelopmentPlan WHERE AppraisalId IN
(
SELECT Id FROM HR.Appraisal WHERE AppraiseId IN
(
SELECT Id FROM Common.Employee WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)

DELETE FROM HR.AppraisalAppraiseeWeightage WHERE AppraisalMappingId IN
(
SELECT Id FROM HR.AppraisalMapping WHERE AppraisalId IN
(
SELECT Id FROM HR.Appraisal WHERE AppraiseId IN
(
SELECT Id FROM Common.Employee WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)

DELETE FROM HR.AppraisalMapping WHERE AppraisalId IN
(
SELECT Id FROM HR.Appraisal WHERE AppraiseId IN
(
SELECT Id FROM Common.Employee WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)

DELETE FROM HR.AppraisalResult WHERE AppraisalId IN
(
SELECT Id FROM HR.Appraisal WHERE AppraiseId IN
(
SELECT Id FROM Common.Employee WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)

DELETE FROM HR.AppraisalSummary WHERE AppraisalId IN
(
SELECT Id FROM HR.Appraisal WHERE AppraiseId IN
(
SELECT Id FROM Common.Employee WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)

DELETE FROM HR.Appraisal WHERE AppraiseId IN
(
SELECT Id FROM Common.Employee WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)

DELETE FROM HR.AppraiseAppraisers WHERE AppraisalDetailId IN
(
SELECT Id FROM HR.AppraisalAppraiseeDetails WHERE EmployeeId IN
(
SELECT Id FROM Common.Employee WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)

DELETE FROM HR.AppraiserIncharge WHERE AppraisalDetailId IN
(
SELECT Id FROM HR.AppraisalAppraiseeDetails WHERE EmployeeId IN
(
SELECT Id FROM Common.Employee WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)

DELETE FROM HR.AppraisalAppraiseeDetails WHERE EmployeeId IN
(
SELECT Id FROM Common.Employee WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)

--DELETE FROM HR.AppraisalAppraiserDetails WHERE EmployeeId IN
--(
--SELECT Id FROM Common.Employee WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
--)

DELETE FROM HR.AppraisalResult WHERE AppraiserId IN
(
SELECT Id FROM Common.Employee WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)

DELETE FROM HR.AppraiseAppraisers WHERE AppraiserId IN
(
SELECT Id FROM Common.Employee WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)

DELETE FROM HR.AppraiserIncharge WHERE InchargeId IN
(
SELECT Id FROM Common.Employee WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)

DELETE FROM HR.Asset WHERE EmployeeId IN
(
SELECT Id FROM Common.Employee WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)

DELETE FROM HR.Asset WHERE AssetSetupDetailsId IN
(
SELECT Id FROM HR.AssetSetupDetails WHERE EmployeeId IN
(
SELECT Id FROM Common.Employee WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)

DELETE FROM HR.AssetSetupDetails WHERE EmployeeId IN
(
SELECT Id FROM Common.Employee WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)

DELETE FROM HR.BankFileDetail WHERE EmployeeId IN
(
SELECT Id FROM Common.Employee WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)

DELETE FROM HR.ClaimsEntitlement WHERE EmployeeId IN
(
SELECT Id FROM Common.Employee WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)

DELETE FROM HR.EmployeeBankDetails WHERE EmployeeId IN
(
SELECT Id FROM Common.Employee WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)

DELETE FROM HR.BankFileDetail WHERE TypeId IN
(
SELECT Id FROM HR.EmployeeClaim1 WHERE EmployeId IN
(
SELECT Id FROM Common.Employee WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)

DELETE FROM HR.EmployeeClaimDetail WHERE EmployeeClaimId IN
(
SELECT Id FROM HR.EmployeeClaim1 WHERE EmployeId IN
(
SELECT Id FROM Common.Employee WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)

DELETE FROM HR.EmployeeClaim1 WHERE EmployeId IN
(
SELECT Id FROM Common.Employee WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)

DELETE FROM HR.BankFileDetail WHERE TypeId IN
(
SELECT Id FROM HR.EmployeeClaim1 WHERE ClaimEntitlementId IN
(
SELECT Id FROM HR.EmployeeClaimsEntitlement WHERE EmployeeId IN
(
SELECT Id FROM Common.Employee WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)

DELETE FROM HR.EmployeeClaimDetail WHERE EmployeeClaimId IN
(
SELECT Id FROM HR.EmployeeClaim1 WHERE ClaimEntitlementId IN
(
SELECT Id FROM HR.EmployeeClaimsEntitlement WHERE EmployeeId IN
(
SELECT Id FROM Common.Employee WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)

DELETE FROM HR.EmployeeClaim1 WHERE ClaimEntitlementId IN
(
SELECT Id FROM HR.EmployeeClaimsEntitlement WHERE EmployeeId IN
(
SELECT Id FROM Common.Employee WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)

DELETE FROM HR.EmployeeClaimsEntitlementDetail WHERE EmployeeClaimsEntitlementId IN
(
SELECT Id FROM HR.EmployeeClaimsEntitlement WHERE EmployeeId IN
(
SELECT Id FROM Common.Employee WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)

DELETE FROM HR.EmployeeClaimsEntitlement WHERE EmployeeId IN
(
SELECT Id FROM Common.Employee WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)

DELETE FROM HR.EmployeeDepartmentHistory WHERE EmployeeDepartmentId IN
(
SELECT Id FROM HR.EmployeeDepartment WHERE EmployeeId IN
(
SELECT Id FROM Common.Employee WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)

DELETE FROM HR.EmployeeDepartment WHERE EmployeeId IN
(
SELECT Id FROM Common.Employee WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)

DELETE FROM HR.EmployeeHistory WHERE EmployeeId IN
(
SELECT Id FROM Common.Employee WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)

DELETE FROM HR.EmployeePayrollSetting WHERE EmployeeId IN
(
SELECT Id FROM Common.Employee WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)

DELETE FROM HR.EmployeeProjects WHERE EmployeeId IN
(
SELECT Id FROM Common.Employee WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)

DELETE FROM HR.EmployeRecandApprovers WHERE EmployeeId IN
(
SELECT Id FROM Common.Employee WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)

DELETE FROM HR.Employment WHERE EmployeeId IN
(
SELECT Id FROM Common.Employee WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)

DELETE FROM HR.Evaluation WHERE EmployeeId IN
(
SELECT Id FROM Common.Employee WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)

DELETE FROM HR.FamilyDetails WHERE EmployeeId IN
(
SELECT Id FROM Common.Employee WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)

DELETE FROM HR.Hobbies WHERE EmployeeId IN
(
SELECT Id FROM Common.Employee WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)

DELETE FROM HR.Appendix8A WHERE IR8AHRSetUpId IN
(
SELECT Id FROM HR.IR8AHRSetUp WHERE EmployeeId IN
(
SELECT Id FROM Common.Employee WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)

DELETE FROM HR.Appendix8BSectionA WHERE Appendix8BId IN
(
SELECT Id FROM HR.Appendix8B WHERE IR8AHRSetUpId  IN
(
SELECT Id FROM HR.IR8AHRSetUp WHERE EmployeeId IN
(
SELECT Id FROM Common.Employee WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)

DELETE FROM HR.Appendix8BSectionB WHERE Appendix8BId IN
(
SELECT Id FROM HR.Appendix8B WHERE IR8AHRSetUpId  IN
(
SELECT Id FROM HR.IR8AHRSetUp WHERE EmployeeId IN
(
SELECT Id FROM Common.Employee WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)

DELETE FROM HR.Appendix8BSectionC WHERE Appendix8BId IN
(
SELECT Id FROM HR.Appendix8B WHERE IR8AHRSetUpId  IN
(
SELECT Id FROM HR.IR8AHRSetUp WHERE EmployeeId IN
(
SELECT Id FROM Common.Employee WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)

DELETE FROM HR.Appendix8BSectionD WHERE Appendix8BId IN
(
SELECT Id FROM HR.Appendix8B WHERE IR8AHRSetUpId  IN
(
SELECT Id FROM HR.IR8AHRSetUp WHERE EmployeeId IN
(
SELECT Id FROM Common.Employee WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)

DELETE FROM HR.Appendix8B WHERE IR8AHRSetUpId  IN
(
SELECT Id FROM HR.IR8AHRSetUp WHERE EmployeeId IN
(
SELECT Id FROM Common.Employee WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)

DELETE FROM HR.FileHistory WHERE IR8AHRSetupId IN
(
SELECT Id FROM HR.IR8AHRSetUp WHERE EmployeeId IN
(
SELECT Id FROM Common.Employee WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)

DELETE FROM HR.IR21ChildSetUp WHERE Ir8aHrSetUpId IN
(
SELECT Id FROM HR.IR8AHRSetUp WHERE EmployeeId IN
(
SELECT Id FROM Common.Employee WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)

DELETE FROM HR.IR8SSectionA WHERE IR8SId IN
(
SELECT Id FROM HR.IR8S WHERE IR8AHRSetUpId IN
(
SELECT Id FROM HR.IR8AHRSetUp WHERE EmployeeId IN
(
SELECT Id FROM Common.Employee WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)

DELETE FROM HR.IR8SSectionC WHERE IR8SId IN
(
SELECT Id FROM HR.IR8S WHERE IR8AHRSetUpId IN
(
SELECT Id FROM HR.IR8AHRSetUp WHERE EmployeeId IN
(
SELECT Id FROM Common.Employee WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)

DELETE FROM HR.IR8S WHERE IR8AHRSetUpId IN
(
SELECT Id FROM HR.IR8AHRSetUp WHERE EmployeeId IN
(
SELECT Id FROM Common.Employee WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)

DELETE FROM HR.IR8AHRSetUp WHERE EmployeeId IN
(
SELECT Id FROM Common.Employee WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)

DELETE FROM HR.IR8SSectionA WHERE IR8SId IN
(
SELECT Id FROM HR.IR8S WHERE EmployeeId IN
(
SELECT Id FROM Common.Employee WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)

DELETE FROM HR.IR8SSectionC WHERE IR8SId IN
(
SELECT Id FROM HR.IR8S WHERE EmployeeId IN
(
SELECT Id FROM Common.Employee WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)

DELETE FROM HR.IR8S WHERE EmployeeId IN
(
SELECT Id FROM Common.Employee WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)

DELETE FROM HR.LeaveApplicationHistory WHERE LeaveApplicationId IN
(
SELECT Id FROM HR.LeaveApplication WHERE EmployeeId IN
(
SELECT Id FROM Common.Employee WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)

DELETE FROM HR.LeaveApplication WHERE EmployeeId IN
(
SELECT Id FROM Common.Employee WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)

DELETE FROM HR.LeaveApplicationHistory WHERE StatusChangedEmployeeId IN
(
SELECT Id FROM Common.Employee WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)

DELETE FROM HR.LeaveEntitlementAdjustment WHERE LeaveEntitlementId IN
(
SELECT Id FROM HR.LeaveEntitlement WHERE EmployeeId IN
(
SELECT Id FROM Common.Employee WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)

DELETE FROM HR.LeaveEntitlement WHERE EmployeeId IN
(
SELECT Id FROM Common.Employee WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)

------------------------DELETE FROM HR.LeaveRequest WHERE EmployeeId IN -----> No Data in Table
------------------------(
------------------------SELECT Id FROM Common.Employee WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
------------------------)

------------------------SELECT * FROM HR.LeaveRequestHistory -----> No Data in Table

DELETE FROM HR.LeaveRuleEngineEmployee WHERE EmployeeId IN
(
SELECT Id FROM Common.Employee WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
) 

------------------------SELECT * FROM HR.LeaveSetupEmployees  -----> No Data in Table

------------------------SELECT * FROM HR.LeavesReport -----> No Data in Table

DELETE FROM HR.LeaveTypeDetails WHERE EmployeeId IN
(
SELECT Id FROM Common.Employee WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
) 

DELETE FROM HR.PayComponentDetail WHERE EmployeeId  IN
(
SELECT Id FROM Common.Employee WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
) 

DELETE FROM HR.PayrollSplit WHERE PayrollDetailId IN
(
SELECT Id FROM HR.PayrollDetails WHERE EmployeeId IN
(
SELECT Id FROM Common.Employee WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
) 
)

DELETE FROM HR.PayrollDetails WHERE EmployeeId IN
(
SELECT Id FROM Common.Employee WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)  

----------------------SELECT * FROM HR.Project -----> No Data in Table

DELETE FROM HR.Qualification WHERE EmployeeId IN
(
SELECT Id FROM Common.Employee WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)  

DELETE FROM HR.TeamCalendarDetail WHERE EmployeeId IN
(
SELECT Id FROM Common.Employee WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)  

DELETE FROM HR.TrainerCourse WHERE TrainerId IN
(
SELECT Id FROM HR.Trainer WHERE EmployeeId IN
(
SELECT Id FROM Common.Employee WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
) 
)

DELETE FROM HR.Trainer WHERE EmployeeId IN
(
SELECT Id FROM Common.Employee WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)  

DELETE FROM HR.TrainingAttendance WHERE EmployeeId IN
(
SELECT Id FROM Common.Employee WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)  

DELETE FROM HR.TrainingAttendee WHERE EmployeeId IN
(
SELECT Id FROM Common.Employee WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
) 

DELETE FROM WorkFlow.CaseAmendDateOfCompletion WHERE EmployeeId IN
(
SELECT Id FROM Common.Employee WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)

------------------SELECT * FROM WorkFlow.CasesAssigned -----> No Data in Table

DELETE FROM WorkFlow.ScheduleTaskDetail WHERE ScheduleTaskId IN
(
SELECT Id FROM WorkFlow.ScheduleTask WHERE ScheduleDetailId IN
(
SELECT Id FROM WorkFlow.ScheduleDetail WHERE EmployeeId IN
(
SELECT Id FROM Common.Employee WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)

DELETE FROM WorkFlow.ScheduleTask WHERE ScheduleDetailId IN
(
SELECT Id FROM WorkFlow.ScheduleDetail WHERE EmployeeId IN
(
SELECT Id FROM Common.Employee WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)

DELETE FROM WorkFlow.ScheduleDetail WHERE EmployeeId IN
(
SELECT Id FROM Common.Employee WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)

DELETE FROM WorkFlow.ScheduleTaskNew WHERE ScheduleDetailId IN
(
SELECT Id FROM WorkFlow.ScheduleDetailNew WHERE EmployeeId IN
(
SELECT Id FROM Common.Employee WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)

DELETE FROM WorkFlow.ScheduleDetailNew WHERE EmployeeId IN
(
SELECT Id FROM Common.Employee WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)

DELETE FROM WorkFlow.ScheduleTaskDetail WHERE ScheduleTaskId IN
(
SELECT Id FROM WorkFlow.ScheduleTask WHERE EmployeeId IN
(
SELECT Id FROM Common.Employee WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)

DELETE FROM WorkFlow.ScheduleTask WHERE EmployeeId IN
(
SELECT Id FROM Common.Employee WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)

DELETE FROM WorkFlow.ScheduleTaskNew WHERE EmployeeId IN
(
SELECT Id FROM Common.Employee WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)

DELETE FROM Common.Employee WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)

----------------------/////////////////////////////////////////////////////////////////////////////// Common.EngagementUsers \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

DELETE FROM Common.EngagementUsers WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)

----------------------/////////////////////////////////////////////////////////////////////////////// Common.EntityDetail \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

DELETE FROM Boardroom.ActivityHistory WHERE EntityId IN
(
SELECT Id FROM Common.EntityDetail WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)

------DELETE FROM Boardroom.AGMReminder WHERE EntityId IN ----> No data in Table
------(
------SELECT Id FROM Common.EntityDetail WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
------)

DELETE FROM Boardroom.AllotmentDetails WHERE AllotmentId IN
(
SELECT Id FROM Boardroom.Allotment WHERE EntityId IN
(
SELECT Id FROM Common.EntityDetail WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)

DELETE FROM Boardroom.SharesCurrentDetails WHERE TransactionId IN
(
SELECT Id FROM Boardroom.[Transaction] WHERE AllotmentId IN
(
SELECT Id FROM Boardroom.Allotment WHERE EntityId IN
(
SELECT Id FROM Common.EntityDetail WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)

DELETE FROM Boardroom.TransactionLog WHERE TransactionId IN
(
SELECT Id FROM Boardroom.[Transaction] WHERE AllotmentId IN
(
SELECT Id FROM Boardroom.Allotment WHERE EntityId IN
(
SELECT Id FROM Common.EntityDetail WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)

DELETE FROM Boardroom.[Transaction] WHERE AllotmentId IN
(
SELECT Id FROM Boardroom.Allotment WHERE EntityId IN
(
SELECT Id FROM Common.EntityDetail WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)

DELETE FROM Boardroom.TransactionLog WHERE AllotmentId IN
(
SELECT Id FROM Boardroom.Allotment WHERE EntityId IN
(
SELECT Id FROM Common.EntityDetail WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)

DELETE FROM Boardroom.Allotment WHERE EntityId IN
(
SELECT Id FROM Common.EntityDetail WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)

DELETE FROM Boardroom.BRAGM WHERE EntityId IN
(
SELECT Id FROM Common.EntityDetail WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)

DELETE FROM Boardroom.ActivityChanges WHERE ChangesId IN
(
SELECT Id FROM Boardroom.Changes WHERE EntityId IN
(
SELECT Id FROM Common.EntityDetail WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)

DELETE FROM Boardroom.AdressesActivity WHERE ChangesId IN
(
SELECT Id FROM Boardroom.Changes WHERE EntityId IN
(
SELECT Id FROM Common.EntityDetail WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)

DELETE FROM Boardroom.AGMChanges WHERE ChangesId IN
(
SELECT Id FROM Boardroom.Changes WHERE EntityId IN
(
SELECT Id FROM Common.EntityDetail WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)

DELETE FROM Boardroom.AGMFillingChanges WHERE ChangesId IN
(
SELECT Id FROM Boardroom.Changes WHERE EntityId IN
(
SELECT Id FROM Common.EntityDetail WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)

DELETE FROM Boardroom.EntityChanges WHERE ChangesId IN
(
SELECT Id FROM Boardroom.Changes WHERE EntityId IN
(
SELECT Id FROM Common.EntityDetail WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)

DELETE FROM Boardroom.FYEChanges WHERE ChangesId IN
(
SELECT Id FROM Boardroom.Changes WHERE EntityId IN
(
SELECT Id FROM Common.EntityDetail WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)

DELETE FROM Boardroom.GenerateTemplate WHERE ChangesId IN
(
SELECT Id FROM Boardroom.Changes WHERE EntityId IN
(
SELECT Id FROM Common.EntityDetail WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)

DELETE FROM Boardroom.InCharge WHERE ChangesId IN
(
SELECT Id FROM Boardroom.Changes WHERE EntityId IN
(
SELECT Id FROM Common.EntityDetail WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)

DELETE FROM Boardroom.ChangesAppointmentDetails WHERE OfficerChangesId IN
(
SELECT Id FROM Boardroom.OfficerChanges WHERE ChangesId IN
(
SELECT Id FROM Boardroom.Changes WHERE EntityId IN
(
SELECT Id FROM Common.EntityDetail WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)

DELETE FROM Boardroom.OfficerChanges WHERE ChangesId IN
(
SELECT Id FROM Boardroom.Changes WHERE EntityId IN
(
SELECT Id FROM Common.EntityDetail WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)

DELETE FROM Boardroom.SharesCurrentDetails WHERE TransactionId IN
(
SELECT Id FROM Boardroom.[Transaction] WHERE ChangesId IN
(
SELECT Id FROM Boardroom.Changes WHERE EntityId IN
(
SELECT Id FROM Common.EntityDetail WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)

DELETE FROM Boardroom.TransactionLog WHERE TransactionId IN
(
SELECT Id FROM Boardroom.[Transaction] WHERE ChangesId IN
(
SELECT Id FROM Boardroom.Changes WHERE EntityId IN
(
SELECT Id FROM Common.EntityDetail WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)

DELETE FROM Boardroom.[Transaction] WHERE ChangesId IN
(
SELECT Id FROM Boardroom.Changes WHERE EntityId IN
(
SELECT Id FROM Common.EntityDetail WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)

DELETE FROM Boardroom.Changes WHERE EntityId IN
(
SELECT Id FROM Common.EntityDetail WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)

DELETE FROM Boardroom.Charge WHERE EntityId IN
(
SELECT Id FROM Common.EntityDetail WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)

----------------DELETE FROM Boardroom.CompanyShareAllotment WHERE EntityId IN ----> No Data in Table
----------------(
----------------SELECT Id FROM Common.EntityDetail WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
----------------)

DELETE FROM Boardroom.AllotmentDetails WHERE ContactId IN
(
SELECT Id FROM Boardroom.Contacts WHERE EntityId IN
(
SELECT Id FROM Common.EntityDetail WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)

DELETE FROM Boardroom.ChangesAppointmentDetails WHERE ContactId IN
(
SELECT Id FROM Boardroom.Contacts WHERE EntityId IN
(
SELECT Id FROM Common.EntityDetail WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)

DELETE FROM Boardroom.GenericContactDesignation WHERE ContactId IN
(
SELECT Id FROM Boardroom.Contacts WHERE EntityId IN
(
SELECT Id FROM Common.EntityDetail WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)

DELETE FROM Boardroom.SharesCurrentDetails WHERE TransactionId IN
(
SELECT Id FROM Boardroom.[Transaction] WHERE ContactId IN
(
SELECT Id FROM Boardroom.Contacts WHERE EntityId IN
(
SELECT Id FROM Common.EntityDetail WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)

DELETE FROM Boardroom.TransactionLog WHERE TransactionId IN
(
SELECT Id FROM Boardroom.[Transaction] WHERE ContactId IN
(
SELECT Id FROM Boardroom.Contacts WHERE EntityId IN
(
SELECT Id FROM Common.EntityDetail WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)

DELETE FROM Boardroom.[Transaction] WHERE ContactId IN
(
SELECT Id FROM Boardroom.Contacts WHERE EntityId IN
(
SELECT Id FROM Common.EntityDetail WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)

DELETE FROM Boardroom.TransactionLog WHERE ContactId IN
(
SELECT Id FROM Boardroom.Contacts WHERE EntityId IN
(
SELECT Id FROM Common.EntityDetail WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)

DELETE FROM Boardroom.Contacts WHERE EntityId IN
(
SELECT Id FROM Common.EntityDetail WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)

DELETE FROM Boardroom.DynamicTemplatesDetail WHERE DynamicTemplateId IN
(
SELECT Id FROM Boardroom.DynamicTemplates WHERE EntityId IN
(
SELECT Id FROM Common.EntityDetail WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)

DELETE FROM Boardroom.GenerateTemplate WHERE DynamicTemplateId IN
(
SELECT Id FROM Boardroom.DynamicTemplates WHERE EntityId IN
(
SELECT Id FROM Common.EntityDetail WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)

DELETE FROM Boardroom.InCharge WHERE DynamicTemplateId IN
(
SELECT Id FROM Boardroom.DynamicTemplates WHERE EntityId IN
(
SELECT Id FROM Common.EntityDetail WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
) 

DELETE FROM Common.ChangesHistory WHERE DynamicTemplateId IN
(
SELECT Id FROM Boardroom.DynamicTemplates WHERE EntityId IN
(
SELECT Id FROM Common.EntityDetail WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
) 

DELETE FROM Common.ChangesHistory WHERE DynamictemplatesId IN
(
SELECT Id FROM Boardroom.DynamicTemplates WHERE EntityId IN
(
SELECT Id FROM Common.EntityDetail WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)

DELETE FROM Boardroom.DynamicTemplates WHERE EntityId IN
(
SELECT Id FROM Common.EntityDetail WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)

DELETE FROM Boardroom.ActivityChanges WHERE EntityActivityId IN
(
SELECT Id FROM Boardroom.EntityActivity WHERE EntityId IN
(
SELECT Id FROM Common.EntityDetail WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)

DELETE FROM Boardroom.ActivityHistory WHERE EntityActivityId IN
(
SELECT Id FROM Boardroom.EntityActivity WHERE EntityId IN
(
SELECT Id FROM Common.EntityDetail WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)

--------------DELETE FROM Boardroom.PricipalApprovalDetail WHERE EntityActivityId IN ------> No Data in Table
--------------(
--------------SELECT Id FROM Boardroom.EntityActivity WHERE EntityId IN
--------------(
--------------SELECT Id FROM Common.EntityDetail WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
--------------)
--------------)

DELETE FROM Boardroom.EntityActivity WHERE EntityId IN
(
SELECT Id FROM Common.EntityDetail WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)

DELETE FROM Boardroom.EntityIncharge WHERE EntityId IN
(
SELECT Id FROM Common.EntityDetail WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)

DELETE FROM Boardroom.FYEChanges WHERE EntityId IN
(
SELECT Id FROM Common.EntityDetail WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)

DELETE FROM Boardroom.ContactCommencementDetails WHERE DesignationId IN
(
SELECT Id FROM Boardroom.GenericContactDesignation WHERE EntityId IN
(
SELECT Id FROM Common.EntityDetail WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)

DELETE FROM Boardroom.GenericContactDesignation WHERE EntityId IN
(
SELECT Id FROM Common.EntityDetail WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)

------------SELECT * FROM Boardroom.PricipalApprovalDetail ----> No Data in Table

DELETE FROM Boardroom.Remindersent WHERE EntityId IN
(
SELECT Id FROM Common.EntityDetail WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)

----------------SELECT * FROM Boardroom.Shares ----> No Data in Table

----------------SELECT * FROM Boardroom.Signatory ----> No Data in Table

DELETE FROM Boardroom.TemplateSent WHERE EntityId IN
(
SELECT Id FROM Common.EntityDetail WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)

DELETE FROM Boardroom.SharesCurrentDetails WHERE TransactionId IN
(
SELECT Id FROM Boardroom.[Transaction] WHERE EntityId IN
(
SELECT Id FROM Common.EntityDetail WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)

DELETE FROM Boardroom.TransactionLog WHERE TransactionId IN
(
SELECT Id FROM Boardroom.[Transaction] WHERE EntityId IN
(
SELECT Id FROM Common.EntityDetail WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)

DELETE FROM Boardroom.[Transaction] WHERE EntityId IN
(
SELECT Id FROM Common.EntityDetail WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)

DELETE FROM Common.Addresses WHERE EntityId IN
(
SELECT Id FROM Common.EntityDetail WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)

DELETE FROM Common.AddressHistory WHERE EntityId IN
(
SELECT Id FROM Common.EntityDetail WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)

DELETE FROM Common.CompanyNameHistory WHERE EntityId IN
(
SELECT Id FROM Common.EntityDetail WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)

DELETE FROM Common.EntityDetail WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)

----------------------/////////////////////////////////////////////////////////////////////////////// Common.EntityType \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

DELETE FROM Common.EntityType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)

----------------------/////////////////////////////////////////////////////////////////////////////// Common.FeeRecoverySetting \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

DELETE FROM Common.FeeRecoverySetting WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)

----------------------/////////////////////////////////////////////////////////////////////////////// Common.Forex \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

--------------SELECT * FROM Common.Forex WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo) ----> No need to delete this data

----------------------/////////////////////////////////////////////////////////////////////////////// Common.GenericTemplate \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

DELETE FROM Boardroom.DocumentsMaster WHERE GenericTemplateId IN
(
SELECT Id FROM Common.GenericTemplate WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)

DELETE FROM Boardroom.Remindersent WHERE GenericTemplateId IN
(
SELECT Id FROM Common.GenericTemplate WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)

DELETE FROM ClientCursor.QuotationDetailTemplate WHERE TemplateId IN
(
SELECT Id FROM Common.GenericTemplate WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)

DELETE FROM ClientCursor.ReminderDetailTemplate WHERE TemplateId IN
(
SELECT Id FROM Common.GenericTemplate WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)

DELETE FROM Common.BeanSOAReminderBatchListDetails WHERE MasterId IN
(
SELECT Id FROM Common.BeanSOAReminderBatchList WHERE TemplateId IN
(
SELECT Id FROM Common.GenericTemplate WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)

DELETE FROM Common.BeanSOAReminderBatchList WHERE TemplateId IN
(
SELECT Id FROM Common.GenericTemplate WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)

DELETE FROM Boardroom.GenerateTemplate WHERE GenericTemplateDetailId IN
(
SELECT Id FROM Common.GenericTemplateDetail WHERE GenericTemplateId IN
(
SELECT Id FROM Common.GenericTemplate WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
 
DELETE FROM Common.GenericTemplateDetail WHERE GenericTemplateId IN
(
SELECT Id FROM Common.GenericTemplate WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)

DELETE FROM Common.GenericTemplateRelatedTo WHERE TemplateId IN
(
SELECT Id FROM Common.GenericTemplate WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)

DELETE FROM Common.ReminderBatchList WHERE TemplateId IN
(
SELECT Id FROM Common.GenericTemplate WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)

DELETE FROM Common.ReminderDetailTemplate WHERE TemplateId IN
(
SELECT Id FROM Common.GenericTemplate WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)

DELETE FROM Common.SOAReminderBatchListDetails WHERE MasterId IN
(
SELECT Id FROM Common.SOAReminderBatchList WHERE TemplateId IN
(
SELECT Id FROM Common.GenericTemplate WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)

DELETE FROM Common.SOAReminderBatchList WHERE TemplateId IN
(
SELECT Id FROM Common.GenericTemplate WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)

------------------SELECT * FROM Common.TemplateAttachment_ToBeDeleted -----> No Data in Table

DELETE FROM Common.TemplateSent WHERE TemplateId IN
(
SELECT Id FROM Common.GenericTemplate WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)

DELETE FROM Common.GenericTemplate WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo) 

----------------------/////////////////////////////////////////////////////////////////////////////// Common.GSTSetting \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

DELETE FROM Common.GSTSetting WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo) 

----------------------/////////////////////////////////////////////////////////////////////////////// Common.Holiday_ToBeDeletedg \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

----------------------SELECT * FROM Common.Holiday_ToBeDeleted WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo) -----> No Data in Table

----------------------/////////////////////////////////////////////////////////////////////////////// Common.HRSettings \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

DELETE FROM Common.HRSettingdetails WHERE MasterId IN
(
SELECT Id FROM Common.HRSettings WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)

DELETE FROM Common.HRSettings WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo) 

----------------------/////////////////////////////////////////////////////////////////////////////// Common.IdType \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

DELETE FROM Bean.BankReconciliationDetail WHERE EntityId IN
(
SELECT Id FROM Bean.Entity WHERE IdTypeId IN
(
SELECT Id FROM Common.IdType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)

DELETE FROM Bean.BillCreditMemoDetail WHERE CreditMemoId IN
(
SELECT Id FROM Bean.BillCreditMemo WHERE BillId IN 
(
SELECT Id FROM Bean.Bill WHERE EntityId IN
(
SELECT Id FROM Bean.Entity WHERE IdTypeId IN
(
SELECT Id FROM Common.IdType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)
)

DELETE FROM Bean.BillCreditMemo WHERE BillId IN
(
SELECT Id FROM Bean.Bill WHERE EntityId IN
(
SELECT Id FROM Bean.Entity WHERE IdTypeId IN
(
SELECT Id FROM Common.IdType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)

DELETE FROM Bean.BillDetail WHERE BillId IN
(
SELECT Id FROM Bean.Bill WHERE EntityId IN
(
SELECT Id FROM Bean.Entity WHERE IdTypeId IN
(
SELECT Id FROM Common.IdType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)

DELETE FROM Bean.Bill WHERE EntityId IN
(
SELECT Id FROM Bean.Entity WHERE IdTypeId IN
(
SELECT Id FROM Common.IdType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)

DELETE FROM Bean.CashSaleDetail WHERE CashSaleId IN
(
SELECT Id FROM Bean.CashSale WHERE EntityId IN
(
SELECT Id FROM Bean.Entity WHERE IdTypeId IN
(
SELECT Id FROM Common.IdType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)

DELETE FROM Bean.CashSale WHERE EntityId IN
(
SELECT Id FROM Bean.Entity WHERE IdTypeId IN
(
SELECT Id FROM Common.IdType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)

DELETE FROM Bean.CreditMemoApplicationDetail WHERE CreditMemoApplicationId IN 
(
SELECT Id FROM Bean.CreditMemoApplication WHERE CreditMemoId IN
(
SELECT Id FROM Bean.CreditMemo WHERE EntityId IN
(
SELECT Id FROM Bean.Entity WHERE IdTypeId IN
(
SELECT Id FROM Common.IdType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)
)

DELETE FROM Bean.CreditMemoApplication WHERE CreditMemoId IN
(
SELECT Id FROM Bean.CreditMemo WHERE EntityId IN
(
SELECT Id FROM Bean.Entity WHERE IdTypeId IN
(
SELECT Id FROM Common.IdType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)

DELETE FROM Bean.CreditMemoDetail WHERE CreditMemoId IN
(
SELECT Id FROM Bean.CreditMemo WHERE EntityId IN
(
SELECT Id FROM Bean.Entity WHERE IdTypeId IN
(
SELECT Id FROM Common.IdType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)

DELETE FROM Bean.CreditMemo WHERE EntityId IN
(
SELECT Id FROM Bean.Entity WHERE IdTypeId IN
(
SELECT Id FROM Common.IdType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)

DELETE FROM Bean.OpeningBalanceDetailLineItem WHERE EntityId IN
(
SELECT Id FROM Bean.Entity WHERE IdTypeId IN
(
SELECT Id FROM Common.IdType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)

DELETE FROM Bean.PaymentDetail WHERE PaymentId IN
(
SELECT Id FROM Bean.Payment WHERE EntityId IN
(
SELECT Id FROM Bean.Entity WHERE IdTypeId IN
(
SELECT Id FROM Common.IdType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)

DELETE FROM Bean.Payment WHERE EntityId IN
(
SELECT Id FROM Bean.Entity WHERE IdTypeId IN
(
SELECT Id FROM Common.IdType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)

DELETE FROM Bean.ReceiptBalancingItem WHERE ReceiptId IN
(
SELECT Id FROM Bean.Receipt WHERE EntityId IN
(
SELECT Id FROM Bean.Entity WHERE IdTypeId IN
(
SELECT Id FROM Common.IdType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
) 
)

DELETE FROM Bean.ReceiptDetail WHERE ReceiptId IN
(
SELECT Id FROM Bean.Receipt WHERE EntityId IN
(
SELECT Id FROM Bean.Entity WHERE IdTypeId IN
(
SELECT Id FROM Common.IdType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
) 
)

DELETE FROM Bean.ReceiptGSTDetail WHERE ReceiptId IN
(
SELECT Id FROM Bean.Receipt WHERE EntityId IN
(
SELECT Id FROM Bean.Entity WHERE IdTypeId IN
(
SELECT Id FROM Common.IdType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
) 
)

DELETE FROM Bean.Receipt WHERE EntityId IN
(
SELECT Id FROM Bean.Entity WHERE IdTypeId IN
(
SELECT Id FROM Common.IdType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
) 

DELETE FROM Bean.Entity WHERE IdTypeId IN
(
SELECT Id FROM Common.IdType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)

DELETE FROM ClientCursor.AccountIncharge WHERE AccountId IN
(
SELECT Id FROM ClientCursor.Account WHERE AccountIdTypeId IN
(
SELECT Id FROM Common.IdType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)


DELETE FROM ClientCursor.AccountStatusChange WHERE AccountId IN
(
SELECT Id FROM ClientCursor.Account WHERE AccountIdTypeId IN
(
SELECT Id FROM Common.IdType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)

DELETE FROM ClientCursor.ManualAssociation WHERE FromAccountId IN
(
SELECT Id FROM ClientCursor.Account WHERE AccountIdTypeId IN
(
SELECT Id FROM Common.IdType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)


DELETE FROM ClientCursor.OpportunityDesignation WHERE OpportunityId IN
(
SELECT Id FROM ClientCursor.Opportunity WHERE AccountId IN
(
SELECT Id FROM ClientCursor.Account WHERE AccountIdTypeId IN
(
SELECT Id FROM Common.IdType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)

------------SELECT * FROM ClientCursor.[OpportunityDoc] ----> No Data in Table

DELETE FROM ClientCursor.OpportunityHistory WHERE OpportunityId IN
(
SELECT Id FROM ClientCursor.Opportunity WHERE AccountId IN
(
SELECT Id FROM ClientCursor.Account WHERE AccountIdTypeId IN
(
SELECT Id FROM Common.IdType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)

DELETE FROM ClientCursor.OpportunityIncharge WHERE OpportunityId IN
(
SELECT Id FROM ClientCursor.Opportunity WHERE AccountId IN
(
SELECT Id FROM ClientCursor.Account WHERE AccountIdTypeId IN
(
SELECT Id FROM Common.IdType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)

DELETE FROM ClientCursor.OpportunityStatusChange WHERE OpportunityId IN
(
SELECT Id FROM ClientCursor.Opportunity WHERE AccountId IN
(
SELECT Id FROM ClientCursor.Account WHERE AccountIdTypeId IN
(
SELECT Id FROM Common.IdType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)

----------SELECT * FROM ClientCursor.OpportunityTermsCondition_ToBeDeleted ---> No Data in Table

DELETE FROM ClientCursor.QuotationDetailTemplate WHERE QuotationDetailId IN
(
SELECT Id FROM ClientCursor.QuotationDetail WHERE OpportunityId IN
(
SELECT Id FROM ClientCursor.Opportunity WHERE AccountId IN
(
SELECT Id FROM ClientCursor.Account WHERE AccountIdTypeId IN
(
SELECT Id FROM Common.IdType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)
)

DELETE FROM ClientCursor.QuotationDetail WHERE OpportunityId IN
(
SELECT Id FROM ClientCursor.Opportunity WHERE AccountId IN
(
SELECT Id FROM ClientCursor.Account WHERE AccountIdTypeId IN
(
SELECT Id FROM Common.IdType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
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
SELECT Id FROM ClientCursor.Opportunity WHERE AccountId IN
(
SELECT Id FROM ClientCursor.Account WHERE AccountIdTypeId IN
(
SELECT Id FROM Common.IdType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
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
SELECT Id FROM ClientCursor.Opportunity WHERE AccountId IN
(
SELECT Id FROM ClientCursor.Account WHERE AccountIdTypeId IN
(
SELECT Id FROM Common.IdType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)
)
)

DELETE FROM Common.TimeLogSchedule WHERE CaseId IN
(
SELECT Id FROM WorkFlow.CaseGroup WHERE OpportunityId IN
(
SELECT Id FROM ClientCursor.Opportunity WHERE AccountId IN
(
SELECT Id FROM ClientCursor.Account WHERE AccountIdTypeId IN
(
SELECT Id FROM Common.IdType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
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
SELECT Id FROM ClientCursor.Opportunity WHERE AccountId IN
(
SELECT Id FROM ClientCursor.Account WHERE AccountIdTypeId IN
(
SELECT Id FROM Common.IdType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
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
SELECT Id FROM ClientCursor.Opportunity WHERE AccountId IN
(
SELECT Id FROM ClientCursor.Account WHERE AccountIdTypeId IN
(
SELECT Id FROM Common.IdType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)
)
)

DELETE FROM HR.EmployeeClaim1 WHERE CaseGroupId IN
(
SELECT Id FROM WorkFlow.CaseGroup WHERE OpportunityId IN
(
SELECT Id FROM ClientCursor.Opportunity WHERE AccountId IN
(
SELECT Id FROM ClientCursor.Account WHERE AccountIdTypeId IN
(
SELECT Id FROM Common.IdType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)
)

DELETE FROM WorkFlow.CaseAmendDateOfCompletion WHERE CaseId IN
(
SELECT Id FROM WorkFlow.CaseGroup WHERE OpportunityId IN
(
SELECT Id FROM ClientCursor.Opportunity WHERE AccountId IN
(
SELECT Id FROM ClientCursor.Account WHERE AccountIdTypeId IN
(
SELECT Id FROM Common.IdType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)
)

DELETE FROM WorkFlow.CaseDesignation WHERE CaseId IN
(
SELECT Id FROM WorkFlow.CaseGroup WHERE OpportunityId IN
(
SELECT Id FROM ClientCursor.Opportunity WHERE AccountId IN
(
SELECT Id FROM ClientCursor.Account WHERE AccountIdTypeId IN
(
SELECT Id FROM Common.IdType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
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
SELECT Id FROM ClientCursor.Opportunity WHERE AccountId IN
(
SELECT Id FROM ClientCursor.Account WHERE AccountIdTypeId IN
(
SELECT Id FROM Common.IdType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
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
SELECT Id FROM ClientCursor.Opportunity WHERE AccountId IN
(
SELECT Id FROM ClientCursor.Account WHERE AccountIdTypeId IN
(
SELECT Id FROM Common.IdType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)
)
)

DELETE FROM WorkFlow.CaseFeature WHERE CaseId IN
(
SELECT Id FROM WorkFlow.CaseGroup WHERE OpportunityId IN
(
SELECT Id FROM ClientCursor.Opportunity WHERE AccountId IN
(
SELECT Id FROM ClientCursor.Account WHERE AccountIdTypeId IN
(
SELECT Id FROM Common.IdType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)
)

DELETE FROM WorkFlow.CaseIncharge WHERE CaseId IN
(
SELECT Id FROM WorkFlow.CaseGroup WHERE OpportunityId IN
(
SELECT Id FROM ClientCursor.Opportunity WHERE AccountId IN
(
SELECT Id FROM ClientCursor.Account WHERE AccountIdTypeId IN
(
SELECT Id FROM Common.IdType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)
)

DELETE FROM WorkFlow.CaseMileStone WHERE CaseId IN
(
SELECT Id FROM WorkFlow.CaseGroup WHERE OpportunityId IN
(
SELECT Id FROM ClientCursor.Opportunity WHERE AccountId IN
(
SELECT Id FROM ClientCursor.Account WHERE AccountIdTypeId IN
(
SELECT Id FROM Common.IdType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)
)

-----------SELECT * FROM WorkFlow.CasesAssigned ----> No Data in Table

DELETE FROM WorkFlow.CaseStatusChange WHERE CaseId IN
(
SELECT Id FROM WorkFlow.CaseGroup WHERE OpportunityId IN
(
SELECT Id FROM ClientCursor.Opportunity WHERE AccountId IN
(
SELECT Id FROM ClientCursor.Account WHERE AccountIdTypeId IN
(
SELECT Id FROM Common.IdType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)
)

DELETE FROM WorkFlow.Claim WHERE CaseId IN
(
SELECT Id FROM WorkFlow.CaseGroup WHERE OpportunityId IN
(
SELECT Id FROM ClientCursor.Opportunity WHERE AccountId IN
(
SELECT Id FROM ClientCursor.Account WHERE AccountIdTypeId IN
(
SELECT Id FROM Common.IdType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
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
SELECT Id FROM ClientCursor.Opportunity WHERE AccountId IN
(
SELECT Id FROM ClientCursor.Account WHERE AccountIdTypeId IN
(
SELECT Id FROM Common.IdType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
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
SELECT Id FROM ClientCursor.Opportunity WHERE AccountId IN
(
SELECT Id FROM ClientCursor.Account WHERE AccountIdTypeId IN
(
SELECT Id FROM Common.IdType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
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
SELECT Id FROM ClientCursor.Opportunity WHERE AccountId IN
(
SELECT Id FROM ClientCursor.Account WHERE AccountIdTypeId IN
(
SELECT Id FROM Common.IdType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)
)

DELETE FROM WorkFlow.InvoiceDesignation WHERE CaseId IN
(
SELECT Id FROM WorkFlow.CaseGroup WHERE OpportunityId IN
(
SELECT Id FROM ClientCursor.Opportunity WHERE AccountId IN
(
SELECT Id FROM ClientCursor.Account WHERE AccountIdTypeId IN
(
SELECT Id FROM Common.IdType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
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
SELECT Id FROM ClientCursor.Opportunity WHERE AccountId IN
(
SELECT Id FROM ClientCursor.Account WHERE AccountIdTypeId IN
(
SELECT Id FROM Common.IdType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
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
SELECT Id FROM ClientCursor.Opportunity WHERE AccountId IN
(
SELECT Id FROM ClientCursor.Account WHERE AccountIdTypeId IN
(
SELECT Id FROM Common.IdType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
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
SELECT Id FROM ClientCursor.Opportunity WHERE AccountId IN
(
SELECT Id FROM ClientCursor.Account WHERE AccountIdTypeId IN
(
SELECT Id FROM Common.IdType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)
)
)

DELETE FROM WorkFlow.Schedule WHERE CaseId IN
(
SELECT Id FROM WorkFlow.CaseGroup WHERE OpportunityId IN
(
SELECT Id FROM ClientCursor.Opportunity WHERE AccountId IN
(
SELECT Id FROM ClientCursor.Account WHERE AccountIdTypeId IN
(
SELECT Id FROM Common.IdType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
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
SELECT Id FROM ClientCursor.Opportunity WHERE AccountId IN
(
SELECT Id FROM ClientCursor.Account WHERE AccountIdTypeId IN
(
SELECT Id FROM Common.IdType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
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
SELECT Id FROM ClientCursor.Opportunity WHERE AccountId IN
(
SELECT Id FROM ClientCursor.Account WHERE AccountIdTypeId IN
(
SELECT Id FROM Common.IdType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)
)
)

DELETE FROM WorkFlow.ScheduleNew WHERE CaseId IN
(
SELECT Id FROM WorkFlow.CaseGroup WHERE OpportunityId IN
(
SELECT Id FROM ClientCursor.Opportunity WHERE AccountId IN
(
SELECT Id FROM ClientCursor.Account WHERE AccountIdTypeId IN
(
SELECT Id FROM Common.IdType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
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
SELECT Id FROM ClientCursor.Opportunity WHERE AccountId IN
(
SELECT Id FROM ClientCursor.Account WHERE AccountIdTypeId IN
(
SELECT Id FROM Common.IdType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)
)
)

DELETE FROM WorkFlow.ScheduleTask WHERE CaseId IN
(
SELECT Id FROM WorkFlow.CaseGroup WHERE OpportunityId IN
(
SELECT Id FROM ClientCursor.Opportunity WHERE AccountId IN
(
SELECT Id FROM ClientCursor.Account WHERE AccountIdTypeId IN
(
SELECT Id FROM Common.IdType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)
)

DELETE FROM WorkFlow.ScheduleTaskNew WHERE CaseId IN
(
SELECT Id FROM WorkFlow.CaseGroup WHERE OpportunityId IN
(
SELECT Id FROM ClientCursor.Opportunity WHERE AccountId IN
(
SELECT Id FROM ClientCursor.Account WHERE AccountIdTypeId IN
(
SELECT Id FROM Common.IdType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)
)
-----------============ CASEGROUP ==================
DELETE FROM WorkFlow.CaseGroup WHERE OpportunityId IN
(
SELECT Id FROM ClientCursor.Opportunity WHERE AccountId IN
(
SELECT Id FROM ClientCursor.Account WHERE AccountIdTypeId IN
(
SELECT Id FROM Common.IdType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)

DELETE FROM ClientCursor.Opportunity WHERE AccountId IN
(
SELECT Id FROM ClientCursor.Account WHERE AccountIdTypeId IN
(
SELECT Id FROM Common.IdType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)

DELETE FROM ClientCursor.QuotationDetailTemplate WHERE QuotationDetailId IN
(
SELECT Id FROM ClientCursor.QuotationDetail WHERE MasterId IN
(
SELECT Id FROM ClientCursor.Quotation WHERE AccountId IN
(
SELECT Id FROM ClientCursor.Account WHERE AccountIdTypeId IN
(
SELECT Id FROM Common.IdType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)
)

DELETE FROM ClientCursor.QuotationDetail WHERE MasterId IN
(
SELECT Id FROM ClientCursor.Quotation WHERE AccountId IN
(
SELECT Id FROM ClientCursor.Account WHERE AccountIdTypeId IN
(
SELECT Id FROM Common.IdType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)

DELETE FROM ClientCursor.QuotationHistory WHERE QuotationId IN
(
SELECT Id FROM ClientCursor.Quotation WHERE AccountId IN
(
SELECT Id FROM ClientCursor.Account WHERE AccountIdTypeId IN
(
SELECT Id FROM Common.IdType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)

DELETE FROM ClientCursor.QuotationSummaryDetails WHERE QuotationId IN
(
SELECT Id FROM ClientCursor.Quotation WHERE AccountId IN
(
SELECT Id FROM ClientCursor.Account WHERE AccountIdTypeId IN
(
SELECT Id FROM Common.IdType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)

DELETE FROM ClientCursor.Quotation WHERE AccountId IN
(
SELECT Id FROM ClientCursor.Account WHERE AccountIdTypeId IN
(
SELECT Id FROM Common.IdType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)

DELETE FROM Common.ReminderBatchList WHERE AccountId IN
(
SELECT Id FROM ClientCursor.Account WHERE AccountIdTypeId IN
(
SELECT Id FROM Common.IdType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)

DELETE FROM ClientCursor.Account WHERE AccountIdTypeId IN
(
SELECT Id FROM Common.IdType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)

-----==

DELETE FROM ClientCursor.AccountIncharge WHERE AccountId IN
(
SELECT Id FROM ClientCursor.Account WHERE CompanySecretaryId IN
(
SELECT Id FROM ClientCursor.Vendor WHERE VendorIdType IN
(
SELECT Id FROM Common.IdType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)

------------SELECT * FROM ClientCursor.AccountNote_ToBeDeleted ----> No Data in Table

DELETE FROM ClientCursor.AccountStatusChange WHERE AccountId IN
(
SELECT Id FROM ClientCursor.Account WHERE CompanySecretaryId IN
(
SELECT Id FROM ClientCursor.Vendor WHERE VendorIdType IN
(
SELECT Id FROM Common.IdType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)

DELETE FROM ClientCursor.ManualAssociation WHERE FromAccountId IN
(
SELECT Id FROM ClientCursor.Account WHERE CompanySecretaryId IN
(
SELECT Id FROM ClientCursor.Vendor WHERE VendorIdType IN
(
SELECT Id FROM Common.IdType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)


DELETE FROM ClientCursor.OpportunityDesignation WHERE OpportunityId IN
(
SELECT Id FROM ClientCursor.Opportunity WHERE AccountId IN
(
SELECT Id FROM ClientCursor.Account WHERE CompanySecretaryId IN
(
SELECT Id FROM ClientCursor.Vendor WHERE VendorIdType IN
(
SELECT Id FROM Common.IdType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)
)

------------SELECT * FROM ClientCursor.[OpportunityDoc] ----> No Data in Table

DELETE FROM ClientCursor.OpportunityHistory WHERE OpportunityId IN
(
SELECT Id FROM ClientCursor.Opportunity WHERE AccountId IN
(
SELECT Id FROM ClientCursor.Account WHERE CompanySecretaryId IN
(
SELECT Id FROM ClientCursor.Vendor WHERE VendorIdType IN
(
SELECT Id FROM Common.IdType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)
)

DELETE FROM ClientCursor.OpportunityIncharge WHERE OpportunityId IN
(
SELECT Id FROM ClientCursor.Opportunity WHERE AccountId IN
(
SELECT Id FROM ClientCursor.Account WHERE CompanySecretaryId IN
(
SELECT Id FROM ClientCursor.Vendor WHERE VendorIdType IN
(
SELECT Id FROM Common.IdType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)
)

DELETE FROM ClientCursor.OpportunityStatusChange WHERE OpportunityId IN
(
SELECT Id FROM ClientCursor.Opportunity WHERE AccountId IN
(
SELECT Id FROM ClientCursor.Account WHERE CompanySecretaryId IN
(
SELECT Id FROM ClientCursor.Vendor WHERE VendorIdType IN
(
SELECT Id FROM Common.IdType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)
)

----------SELECT * FROM ClientCursor.OpportunityTermsCondition_ToBeDeleted ---> No Data in Table

DELETE FROM ClientCursor.QuotationDetailTemplate WHERE QuotationDetailId IN
(
SELECT Id FROM ClientCursor.QuotationDetail WHERE OpportunityId IN
(
SELECT Id FROM ClientCursor.Opportunity WHERE AccountId IN
(
SELECT Id FROM ClientCursor.Account WHERE CompanySecretaryId IN
(
SELECT Id FROM ClientCursor.Vendor WHERE VendorIdType IN
(
SELECT Id FROM Common.IdType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)
)
)

DELETE FROM ClientCursor.QuotationDetail WHERE OpportunityId IN
(
SELECT Id FROM ClientCursor.Opportunity WHERE AccountId IN
(
SELECT Id FROM ClientCursor.Account WHERE CompanySecretaryId IN
(
SELECT Id FROM ClientCursor.Vendor WHERE VendorIdType IN
(
SELECT Id FROM Common.IdType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
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
SELECT Id FROM ClientCursor.Opportunity WHERE AccountId IN
(
SELECT Id FROM ClientCursor.Account WHERE CompanySecretaryId IN
(
SELECT Id FROM ClientCursor.Vendor WHERE VendorIdType IN
(
SELECT Id FROM Common.IdType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
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
SELECT Id FROM ClientCursor.Opportunity WHERE AccountId IN
(
SELECT Id FROM ClientCursor.Account WHERE CompanySecretaryId IN
(
SELECT Id FROM ClientCursor.Vendor WHERE VendorIdType IN
(
SELECT Id FROM Common.IdType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)
)
)
)

DELETE FROM Common.TimeLogSchedule WHERE CaseId IN
(
SELECT Id FROM WorkFlow.CaseGroup WHERE OpportunityId IN
(
SELECT Id FROM ClientCursor.Opportunity WHERE AccountId IN
(
SELECT Id FROM ClientCursor.Account WHERE CompanySecretaryId IN
(
SELECT Id FROM ClientCursor.Vendor WHERE VendorIdType IN
(
SELECT Id FROM Common.IdType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
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
SELECT Id FROM ClientCursor.Opportunity WHERE AccountId IN
(
SELECT Id FROM ClientCursor.Account WHERE CompanySecretaryId IN
(
SELECT Id FROM ClientCursor.Vendor WHERE VendorIdType IN
(
SELECT Id FROM Common.IdType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
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
SELECT Id FROM ClientCursor.Opportunity WHERE AccountId IN
(
SELECT Id FROM ClientCursor.Account WHERE CompanySecretaryId IN
(
SELECT Id FROM ClientCursor.Vendor WHERE VendorIdType IN
(
SELECT Id FROM Common.IdType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)
)
)
)

DELETE FROM HR.EmployeeClaim1 WHERE CaseGroupId IN
(
SELECT Id FROM WorkFlow.CaseGroup WHERE OpportunityId IN
(
SELECT Id FROM ClientCursor.Opportunity WHERE AccountId IN
(
SELECT Id FROM ClientCursor.Account WHERE CompanySecretaryId IN
(
SELECT Id FROM ClientCursor.Vendor WHERE VendorIdType IN
(
SELECT Id FROM Common.IdType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)
)
)

DELETE FROM WorkFlow.CaseAmendDateOfCompletion WHERE CaseId IN
(
SELECT Id FROM WorkFlow.CaseGroup WHERE OpportunityId IN
(
SELECT Id FROM ClientCursor.Opportunity WHERE AccountId IN
(
SELECT Id FROM ClientCursor.Account WHERE CompanySecretaryId IN
(
SELECT Id FROM ClientCursor.Vendor WHERE VendorIdType IN
(
SELECT Id FROM Common.IdType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)
)
)

DELETE FROM WorkFlow.CaseDesignation WHERE CaseId IN
(
SELECT Id FROM WorkFlow.CaseGroup WHERE OpportunityId IN
(
SELECT Id FROM ClientCursor.Opportunity WHERE AccountId IN
(
SELECT Id FROM ClientCursor.Account WHERE CompanySecretaryId IN
(
SELECT Id FROM ClientCursor.Vendor WHERE VendorIdType IN
(
SELECT Id FROM Common.IdType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
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
SELECT Id FROM ClientCursor.Opportunity WHERE AccountId IN
(
SELECT Id FROM ClientCursor.Account WHERE CompanySecretaryId IN
(
SELECT Id FROM ClientCursor.Vendor WHERE VendorIdType IN
(
SELECT Id FROM Common.IdType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
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
SELECT Id FROM ClientCursor.Opportunity WHERE AccountId IN
(
SELECT Id FROM ClientCursor.Account WHERE CompanySecretaryId IN
(
SELECT Id FROM ClientCursor.Vendor WHERE VendorIdType IN
(
SELECT Id FROM Common.IdType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)
)
)
)

DELETE FROM WorkFlow.CaseFeature WHERE CaseId IN
(
SELECT Id FROM WorkFlow.CaseGroup WHERE OpportunityId IN
(
SELECT Id FROM ClientCursor.Opportunity WHERE AccountId IN
(
SELECT Id FROM ClientCursor.Account WHERE CompanySecretaryId IN
(
SELECT Id FROM ClientCursor.Vendor WHERE VendorIdType IN
(
SELECT Id FROM Common.IdType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)
)
)

DELETE FROM WorkFlow.CaseIncharge WHERE CaseId IN
(
SELECT Id FROM WorkFlow.CaseGroup WHERE OpportunityId IN
(
SELECT Id FROM ClientCursor.Opportunity WHERE AccountId IN
(
SELECT Id FROM ClientCursor.Account WHERE CompanySecretaryId IN
(
SELECT Id FROM ClientCursor.Vendor WHERE VendorIdType IN
(
SELECT Id FROM Common.IdType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)
)
)

DELETE FROM WorkFlow.CaseMileStone WHERE CaseId IN
(
SELECT Id FROM WorkFlow.CaseGroup WHERE OpportunityId IN
(
SELECT Id FROM ClientCursor.Opportunity WHERE AccountId IN
(
SELECT Id FROM ClientCursor.Account WHERE CompanySecretaryId IN
(
SELECT Id FROM ClientCursor.Vendor WHERE VendorIdType IN
(
SELECT Id FROM Common.IdType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)
)
)

-----------SELECT * FROM WorkFlow.CasesAssigned ----> No Data in Table

DELETE FROM WorkFlow.CaseStatusChange WHERE CaseId IN
(
SELECT Id FROM WorkFlow.CaseGroup WHERE OpportunityId IN
(
SELECT Id FROM ClientCursor.Opportunity WHERE AccountId IN
(
SELECT Id FROM ClientCursor.Account WHERE CompanySecretaryId IN
(
SELECT Id FROM ClientCursor.Vendor WHERE VendorIdType IN
(
SELECT Id FROM Common.IdType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)
)
)

DELETE FROM WorkFlow.Claim WHERE CaseId IN
(
SELECT Id FROM WorkFlow.CaseGroup WHERE OpportunityId IN
(
SELECT Id FROM ClientCursor.Opportunity WHERE AccountId IN
(
SELECT Id FROM ClientCursor.Account WHERE CompanySecretaryId IN
(
SELECT Id FROM ClientCursor.Vendor WHERE VendorIdType IN
(
SELECT Id FROM Common.IdType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
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
SELECT Id FROM ClientCursor.Opportunity WHERE AccountId IN
(
SELECT Id FROM ClientCursor.Account WHERE CompanySecretaryId IN
(
SELECT Id FROM ClientCursor.Vendor WHERE VendorIdType IN
(
SELECT Id FROM Common.IdType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
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
SELECT Id FROM ClientCursor.Opportunity WHERE AccountId IN
(
SELECT Id FROM ClientCursor.Account WHERE CompanySecretaryId IN
(
SELECT Id FROM ClientCursor.Vendor WHERE VendorIdType IN
(
SELECT Id FROM Common.IdType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
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
SELECT Id FROM ClientCursor.Opportunity WHERE AccountId IN
(
SELECT Id FROM ClientCursor.Account WHERE CompanySecretaryId IN
(
SELECT Id FROM ClientCursor.Vendor WHERE VendorIdType IN
(
SELECT Id FROM Common.IdType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)
)
)

DELETE FROM WorkFlow.InvoiceDesignation WHERE CaseId IN
(
SELECT Id FROM WorkFlow.CaseGroup WHERE OpportunityId IN
(
SELECT Id FROM ClientCursor.Opportunity WHERE AccountId IN
(
SELECT Id FROM ClientCursor.Account WHERE CompanySecretaryId IN
(
SELECT Id FROM ClientCursor.Vendor WHERE VendorIdType IN
(
SELECT Id FROM Common.IdType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
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
SELECT Id FROM ClientCursor.Opportunity WHERE AccountId IN
(
SELECT Id FROM ClientCursor.Account WHERE CompanySecretaryId IN
(
SELECT Id FROM ClientCursor.Vendor WHERE VendorIdType IN
(
SELECT Id FROM Common.IdType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
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
SELECT Id FROM ClientCursor.Opportunity WHERE AccountId IN
(
SELECT Id FROM ClientCursor.Account WHERE CompanySecretaryId IN
(
SELECT Id FROM ClientCursor.Vendor WHERE VendorIdType IN
(
SELECT Id FROM Common.IdType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
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
SELECT Id FROM ClientCursor.Opportunity WHERE AccountId IN
(
SELECT Id FROM ClientCursor.Account WHERE CompanySecretaryId IN
(
SELECT Id FROM ClientCursor.Vendor WHERE VendorIdType IN
(
SELECT Id FROM Common.IdType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)
)
)
)

DELETE FROM WorkFlow.Schedule WHERE CaseId IN
(
SELECT Id FROM WorkFlow.CaseGroup WHERE OpportunityId IN
(
SELECT Id FROM ClientCursor.Opportunity WHERE AccountId IN
(
SELECT Id FROM ClientCursor.Account WHERE CompanySecretaryId IN
(
SELECT Id FROM ClientCursor.Vendor WHERE VendorIdType IN
(
SELECT Id FROM Common.IdType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
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
SELECT Id FROM ClientCursor.Opportunity WHERE AccountId IN
(
SELECT Id FROM ClientCursor.Account WHERE CompanySecretaryId IN
(
SELECT Id FROM ClientCursor.Vendor WHERE VendorIdType IN
(
SELECT Id FROM Common.IdType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
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
SELECT Id FROM ClientCursor.Opportunity WHERE AccountId IN
(
SELECT Id FROM ClientCursor.Account WHERE CompanySecretaryId IN
(
SELECT Id FROM ClientCursor.Vendor WHERE VendorIdType IN
(
SELECT Id FROM Common.IdType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)
)
)
)

DELETE FROM WorkFlow.ScheduleNew WHERE CaseId IN
(
SELECT Id FROM WorkFlow.CaseGroup WHERE OpportunityId IN
(
SELECT Id FROM ClientCursor.Opportunity WHERE AccountId IN
(
SELECT Id FROM ClientCursor.Account WHERE CompanySecretaryId IN
(
SELECT Id FROM ClientCursor.Vendor WHERE VendorIdType IN
(
SELECT Id FROM Common.IdType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
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
SELECT Id FROM ClientCursor.Opportunity WHERE AccountId IN
(
SELECT Id FROM ClientCursor.Account WHERE CompanySecretaryId IN
(
SELECT Id FROM ClientCursor.Vendor WHERE VendorIdType IN
(
SELECT Id FROM Common.IdType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)
)
)
)

DELETE FROM WorkFlow.ScheduleTask WHERE CaseId IN
(
SELECT Id FROM WorkFlow.CaseGroup WHERE OpportunityId IN
(
SELECT Id FROM ClientCursor.Opportunity WHERE AccountId IN
(
SELECT Id FROM ClientCursor.Account WHERE CompanySecretaryId IN
(
SELECT Id FROM ClientCursor.Vendor WHERE VendorIdType IN
(
SELECT Id FROM Common.IdType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)
)
)

DELETE FROM WorkFlow.ScheduleTaskNew WHERE CaseId IN
(
SELECT Id FROM WorkFlow.CaseGroup WHERE OpportunityId IN
(
SELECT Id FROM ClientCursor.Opportunity WHERE AccountId IN
(
SELECT Id FROM ClientCursor.Account WHERE CompanySecretaryId IN
(
SELECT Id FROM ClientCursor.Vendor WHERE VendorIdType IN
(
SELECT Id FROM Common.IdType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)
)
)
-----------============ CASEGROUP ==================
DELETE FROM WorkFlow.CaseGroup WHERE OpportunityId IN
(
SELECT Id FROM ClientCursor.Opportunity WHERE AccountId IN
(
SELECT Id FROM ClientCursor.Account WHERE CompanySecretaryId IN
(
SELECT Id FROM ClientCursor.Vendor WHERE VendorIdType IN
(
SELECT Id FROM Common.IdType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)
)

DELETE FROM ClientCursor.Opportunity WHERE AccountId IN
(
SELECT Id FROM ClientCursor.Account WHERE CompanySecretaryId IN
(
SELECT Id FROM ClientCursor.Vendor WHERE VendorIdType IN
(
SELECT Id FROM Common.IdType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)

DELETE FROM ClientCursor.QuotationDetailTemplate WHERE QuotationDetailId IN
(
SELECT Id FROM ClientCursor.QuotationDetail WHERE MasterId IN
(
SELECT Id FROM ClientCursor.Quotation WHERE AccountId IN
(
SELECT Id FROM ClientCursor.Account WHERE CompanySecretaryId IN
(
SELECT Id FROM ClientCursor.Vendor WHERE VendorIdType IN
(
SELECT Id FROM Common.IdType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)
)
)

DELETE FROM ClientCursor.QuotationDetail WHERE MasterId IN
(
SELECT Id FROM ClientCursor.Quotation WHERE AccountId IN
(
SELECT Id FROM ClientCursor.Account WHERE CompanySecretaryId IN
(
SELECT Id FROM ClientCursor.Vendor WHERE VendorIdType IN
(
SELECT Id FROM Common.IdType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)
)

DELETE FROM ClientCursor.QuotationHistory WHERE QuotationId IN
(
SELECT Id FROM ClientCursor.Quotation WHERE AccountId IN
(
SELECT Id FROM ClientCursor.Account WHERE CompanySecretaryId IN
(
SELECT Id FROM ClientCursor.Vendor WHERE VendorIdType IN
(
SELECT Id FROM Common.IdType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)
)

DELETE FROM ClientCursor.QuotationSummaryDetails WHERE QuotationId IN
(
SELECT Id FROM ClientCursor.Quotation WHERE AccountId IN
(
SELECT Id FROM ClientCursor.Account WHERE CompanySecretaryId IN
(
SELECT Id FROM ClientCursor.Vendor WHERE VendorIdType IN
(
SELECT Id FROM Common.IdType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)
)

DELETE FROM ClientCursor.Quotation WHERE AccountId IN
(
SELECT Id FROM ClientCursor.Account WHERE CompanySecretaryId IN
(
SELECT Id FROM ClientCursor.Vendor WHERE VendorIdType IN
(
SELECT Id FROM Common.IdType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)

DELETE FROM Common.ReminderBatchList WHERE AccountId IN
(
SELECT Id FROM ClientCursor.Account WHERE CompanySecretaryId IN
(
SELECT Id FROM ClientCursor.Vendor WHERE VendorIdType IN
(
SELECT Id FROM Common.IdType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)

DELETE FROM ClientCursor.Account WHERE CompanySecretaryId IN
(
SELECT Id FROM ClientCursor.Vendor WHERE VendorIdType IN
(
SELECT Id FROM Common.IdType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)

DELETE FROM ClientCursor.VendorContact WHERE VendorId IN 
(
SELECT Id FROM ClientCursor.Vendor WHERE VendorIdType IN
(
SELECT Id FROM Common.IdType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)

DELETE FROM ClientCursor.VendorNote WHERE VendorId IN 
(
SELECT Id FROM ClientCursor.Vendor WHERE VendorIdType IN
(
SELECT Id FROM Common.IdType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)

DELETE FROM ClientCursor.VendorService WHERE VendorId IN
(
SELECT Id FROM ClientCursor.Vendor WHERE VendorIdType IN
(
SELECT Id FROM Common.IdType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)

DELETE FROM ClientCursor.VendorTypeVendor WHERE VendorId IN
(
SELECT Id FROM ClientCursor.Vendor WHERE VendorIdType IN
(
SELECT Id FROM Common.IdType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)

DELETE FROM ClientCursor.Vendor WHERE VendorIdType IN
(
SELECT Id FROM Common.IdType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)

DELETE FROM Common.AccountTypeIdType WHERE IdTypeId IN
(
SELECT Id FROM Common.IdType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)


DELETE FROM Tax.EngagementVisitedHistory WHERE TaxCompanyId IN
(
SELECT Id FROM Tax.TaxCompany WHERE IdtypeId IN
(
SELECT Id FROM Common.IdType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)

DELETE FROM Tax.ClientAndEngagementIndependenceConfirmation WHERE PlanningAndCompletionSetUpId IN
(
SELECT Id FROM Tax.PlanningAndCompletionSetUp WHERE TaxCompanyId IN
(
SELECT Id FROM Tax.TaxCompany WHERE IdtypeId IN
(
SELECT Id FROM Common.IdType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)

DELETE FROM Tax.DirectorRemunerationDetails WHERE DirectorRemunerationId IN
(
SELECT Id FROM Tax.DirectorRemuneration WHERE PlanningAndCompletionSetUpId IN
(
SELECT Id FROM Tax.PlanningAndCompletionSetUp WHERE TaxCompanyId IN
(
SELECT Id FROM Tax.TaxCompany WHERE IdtypeId IN
(
SELECT Id FROM Common.IdType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)
)

DELETE FROM Tax.DirectorRemuneration WHERE PlanningAndCompletionSetUpId IN
(
SELECT Id FROM Tax.PlanningAndCompletionSetUp WHERE TaxCompanyId IN
(
SELECT Id FROM Tax.TaxCompany WHERE IdtypeId IN
(
SELECT Id FROM Common.IdType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)

DELETE FROM Tax.PAndCSectionQuestions WHERE PAndCSectionId IN
(
SELECT Id FROM Tax.PAndCSections WHERE PlanningAndCompletionSetUpId IN
(
SELECT Id FROM Tax.PlanningAndCompletionSetUp WHERE TaxCompanyId IN
(
SELECT Id FROM Tax.TaxCompany WHERE IdtypeId IN
(
SELECT Id FROM Common.IdType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)
)

DELETE FROM Tax.PAndCSections WHERE PlanningAndCompletionSetUpId IN
(
SELECT Id FROM Tax.PlanningAndCompletionSetUp WHERE TaxCompanyId IN
(
SELECT Id FROM Tax.TaxCompany WHERE IdtypeId IN
(
SELECT Id FROM Common.IdType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)

DELETE FROM Tax.PlanningAndCompletionSetUp WHERE TaxCompanyId IN
(
SELECT Id FROM Tax.TaxCompany WHERE IdtypeId IN
(
SELECT Id FROM Common.IdType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)

----------------SELECT * FROM Tax.PlanningMateriality_ToBeDeleted -----> No Data in Table 

DELETE FROM Tax.DonationReference WHERE ProfitAndLossImportId IN
(
SELECT Id FROM Tax.ProfitAndLossImport WHERE TaxCompanyId IN
(
SELECT Id FROM Tax.TaxCompany WHERE IdtypeId IN
(
SELECT Id FROM Common.IdType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)

DELETE FROM Tax.FurtherDeductionDetail WHERE ProfitAndLossImportId IN
(
SELECT Id FROM Tax.ProfitAndLossImport WHERE TaxCompanyId IN
(
SELECT Id FROM Tax.TaxCompany WHERE IdtypeId IN
(
SELECT Id FROM Common.IdType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)

DELETE FROM Tax.NonTradeIncomeDetail WHERE ProfitAndLossImportId IN
(
SELECT Id FROM Tax.ProfitAndLossImport WHERE TaxCompanyId IN
(
SELECT Id FROM Tax.TaxCompany WHERE IdtypeId IN
(
SELECT Id FROM Common.IdType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)

DELETE FROM Tax.RentalIncomeDetail WHERE ProfitAndLossImportId IN
(
SELECT Id FROM Tax.ProfitAndLossImport WHERE TaxCompanyId IN
(
SELECT Id FROM Tax.TaxCompany WHERE IdtypeId IN
(
SELECT Id FROM Common.IdType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)

DELETE FROM Tax.Section14QAdditions WHERE ProfitAndLossImportId IN
(
SELECT Id FROM Tax.ProfitAndLossImport WHERE TaxCompanyId IN
(
SELECT Id FROM Tax.TaxCompany WHERE IdtypeId IN
(
SELECT Id FROM Common.IdType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)

DELETE FROM Tax.StatementA WHERE PandLId IN
(
SELECT Id FROM Tax.ProfitAndLossImport WHERE TaxCompanyId IN
(
SELECT Id FROM Tax.TaxCompany WHERE IdtypeId IN
(
SELECT Id FROM Common.IdType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)

DELETE FROM Tax.ProfitAndLossImport WHERE TaxCompanyId IN
(
SELECT Id FROM Tax.TaxCompany WHERE IdtypeId IN
(
SELECT Id FROM Common.IdType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)

DELETE FROM Tax.Disposal WHERE SectionAId IN
(
SELECT Id FROM Tax.SectionA WHERE TaxCompanyId IN
(
SELECT Id FROM Tax.TaxCompany WHERE IdtypeId IN
(
SELECT Id FROM Common.IdType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)

DELETE FROM Tax.Section14QAdditions WHERE SectionAId IN
(
SELECT Id FROM Tax.SectionA WHERE TaxCompanyId IN
(
SELECT Id FROM Tax.TaxCompany WHERE IdtypeId IN
(
SELECT Id FROM Common.IdType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)

DELETE FROM Tax.SectionADetail WHERE SECTIONAId IN
(
SELECT Id FROM Tax.SectionA WHERE TaxCompanyId IN
(
SELECT Id FROM Tax.TaxCompany WHERE IdtypeId IN
(
SELECT Id FROM Common.IdType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)

DELETE FROM Tax.SectionB WHERE SECTIONAId IN
(
SELECT Id FROM Tax.SectionA WHERE TaxCompanyId IN
(
SELECT Id FROM Tax.TaxCompany WHERE IdtypeId IN
(
SELECT Id FROM Common.IdType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)

DELETE FROM Tax.SectionA WHERE TaxCompanyId IN
(
SELECT Id FROM Tax.TaxCompany WHERE IdtypeId IN
(
SELECT Id FROM Common.IdType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)

DELETE FROM Tax.ClientAndEngagementIndependenceConfirmation WHERE TaxCompanyContactId IN
(
SELECT Id FROM Tax.TaxCompanyContact WHERE TaxCompanyId IN
(
SELECT Id FROM Tax.TaxCompany WHERE IdtypeId IN
(
SELECT Id FROM Common.IdType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)

DELETE FROM Tax.DirectorRemunerationDetails WHERE DirectorRemunerationId IN
(
SELECT Id FROM Tax.DirectorRemuneration WHERE TaxCompanyContactId IN
(
SELECT Id FROM Tax.TaxCompanyContact WHERE TaxCompanyId IN
(
SELECT Id FROM Tax.TaxCompany WHERE IdtypeId IN
(
SELECT Id FROM Common.IdType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)
)

DELETE FROM Tax.DirectorRemuneration WHERE TaxCompanyContactId IN
(
SELECT Id FROM Tax.TaxCompanyContact WHERE TaxCompanyId IN
(
SELECT Id FROM Tax.TaxCompany WHERE IdtypeId IN
(
SELECT Id FROM Common.IdType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)

DELETE FROM Tax.TaxCompanyContact WHERE TaxCompanyId IN
(
SELECT Id FROM Tax.TaxCompany WHERE IdtypeId IN
(
SELECT Id FROM Common.IdType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)

DELETE FROM Tax.AccountAnnotation WHERE EngagementId IN
(
SELECT Id FROM Tax.TaxCompanyEngagement WHERE TaxCompanyId IN
(
SELECT Id FROM Tax.TaxCompany WHERE IdtypeId IN
(
SELECT Id FROM Common.IdType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)

DELETE FROM Tax.AccountPolicyDetail WHERE MasterId IN
(
SELECT Id FROM Tax.AccountPolicy WHERE EngagementId IN
(
SELECT Id FROM Tax.TaxCompanyEngagement WHERE TaxCompanyId IN
(
SELECT Id FROM Tax.TaxCompany WHERE IdtypeId IN
(
SELECT Id FROM Common.IdType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)
)

DELETE FROM Tax.AccountPolicy WHERE EngagementId IN
(
SELECT Id FROM Tax.TaxCompanyEngagement WHERE TaxCompanyId IN
(
SELECT Id FROM Tax.TaxCompany WHERE IdtypeId IN
(
SELECT Id FROM Common.IdType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)

------------SELECT * FROM Tax.AdjustmentComment_ToBeDeleted ------> No Data in Table 

DELETE FROM Tax.AdjustmentFileAttachment WHERE AdjustmentID IN
(
SELECT ID FROM Tax.Adjustment WHERE EngagementID IN
(
SELECT Id FROM Tax.TaxCompanyEngagement WHERE TaxCompanyId IN
(
SELECT Id FROM Tax.TaxCompany WHERE IdtypeId IN
(
SELECT Id FROM Common.IdType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)
)

DELETE FROM Tax.AdjustmentStatusHistory WHERE AdjustmentID IN
(
SELECT ID FROM Tax.Adjustment WHERE EngagementID IN
(
SELECT Id FROM Tax.TaxCompanyEngagement WHERE TaxCompanyId IN
(
SELECT Id FROM Tax.TaxCompany WHERE IdtypeId IN
(
SELECT Id FROM Common.IdType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)
)

DELETE FROM Tax.FEAnalysisNote WHERE AdjustmentID IN
(
SELECT ID FROM Tax.Adjustment WHERE EngagementID IN
(
SELECT Id FROM Tax.TaxCompanyEngagement WHERE TaxCompanyId IN
(
SELECT Id FROM Tax.TaxCompany WHERE IdtypeId IN
(
SELECT Id FROM Common.IdType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)
)

----------------SELECT * FROM Tax.NoteAdjustment_ToBeDeleted ----> No Data in Table

DELETE FROM Tax.Adjustment WHERE EngagementID IN
(
SELECT Id FROM Tax.TaxCompanyEngagement WHERE TaxCompanyId IN
(
SELECT Id FROM Tax.TaxCompany WHERE IdtypeId IN
(
SELECT Id FROM Common.IdType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)

DELETE FROM Tax.AdjustmentDOCRepository WHERE EngagementID IN
(
SELECT Id FROM Tax.TaxCompanyEngagement WHERE TaxCompanyId IN
(
SELECT Id FROM Tax.TaxCompany WHERE IdtypeId IN
(
SELECT Id FROM Common.IdType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)

DELETE FROM Tax.CarryForwardDetail WHERE CarryForwardId IN
(
SELECT Id FROM Tax.CarryForward WHERE EngagementId IN
(
SELECT Id FROM Tax.TaxCompanyEngagement WHERE TaxCompanyId IN
(
SELECT Id FROM Tax.TaxCompany WHERE IdtypeId IN
(
SELECT Id FROM Common.IdType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)
)

DELETE FROM Tax.CarryForward WHERE EngagementId IN
(
SELECT Id FROM Tax.TaxCompanyEngagement WHERE TaxCompanyId IN
(
SELECT Id FROM Tax.TaxCompany WHERE IdtypeId IN
(
SELECT Id FROM Common.IdType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)

DELETE FROM Tax.ClientAndEngagementIndependenceConfirmation WHERE EngagementId IN
(
SELECT Id FROM Tax.TaxCompanyEngagement WHERE TaxCompanyId IN
(
SELECT Id FROM Tax.TaxCompany WHERE IdtypeId IN
(
SELECT Id FROM Common.IdType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)

DELETE FROM Tax.DirectorRemunerationDetails WHERE DirectorRemunerationId IN
(
SELECT Id FROM Tax.DirectorRemuneration WHERE EngagementId IN
(
SELECT Id FROM Tax.TaxCompanyEngagement WHERE TaxCompanyId IN
(
SELECT Id FROM Tax.TaxCompany WHERE IdtypeId IN
(
SELECT Id FROM Common.IdType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)
)

DELETE FROM Tax.DirectorRemuneration WHERE EngagementId IN
(
SELECT Id FROM Tax.TaxCompanyEngagement WHERE TaxCompanyId IN
(
SELECT Id FROM Tax.TaxCompany WHERE IdtypeId IN
(
SELECT Id FROM Common.IdType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)

DELETE FROM Tax.Donation WHERE EngagementId IN
(
SELECT Id FROM Tax.TaxCompanyEngagement WHERE TaxCompanyId IN
(
SELECT Id FROM Tax.TaxCompany WHERE IdtypeId IN
(
SELECT Id FROM Common.IdType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)

DELETE FROM Tax.DonationReference WHERE EngagementId IN
(
SELECT Id FROM Tax.TaxCompanyEngagement WHERE TaxCompanyId IN
(
SELECT Id FROM Tax.TaxCompany WHERE IdtypeId IN
(
SELECT Id FROM Common.IdType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)

DELETE FROM Tax.EngagementPercentage WHERE EngagementId IN
(
SELECT Id FROM Tax.TaxCompanyEngagement WHERE TaxCompanyId IN
(
SELECT Id FROM Tax.TaxCompany WHERE IdtypeId IN
(
SELECT Id FROM Common.IdType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)

DELETE FROM Tax.EngagementVisitedHistory WHERE EngagementId IN
(
SELECT Id FROM Tax.TaxCompanyEngagement WHERE TaxCompanyId IN
(
SELECT Id FROM Tax.TaxCompany WHERE IdtypeId IN
(
SELECT Id FROM Common.IdType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)

DELETE FROM Tax.FEAnalysisCommentReply WHERE FECommentID IN
(
SELECT ID FROM Tax.FEAnalysisComment WHERE FEAnalysisID IN
(
SELECT ID FROM Tax.FEAnalysis WHERE ForeignExchangeID IN
(
SELECT ID FROM Tax.ForeignExchange WHERE EngagementID IN
(
SELECT Id FROM Tax.TaxCompanyEngagement WHERE TaxCompanyId IN
(
SELECT Id FROM Tax.TaxCompany WHERE IdtypeId IN
(
SELECT Id FROM Common.IdType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)
)
)
)

DELETE FROM Tax.FEAnalysisComment WHERE FEAnalysisID IN
(
SELECT ID FROM Tax.FEAnalysis WHERE ForeignExchangeID IN
(
SELECT ID FROM Tax.ForeignExchange WHERE EngagementID IN
(
SELECT Id FROM Tax.TaxCompanyEngagement WHERE TaxCompanyId IN
(
SELECT Id FROM Tax.TaxCompany WHERE IdtypeId IN
(
SELECT Id FROM Common.IdType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)
)
)

DELETE FROM Tax.FEAnalysisCurrencyDetails WHERE CuntryCurrencyID IN
(
SELECT ID FROM Tax.FEAnalysisCountryCurrency WHERE FEAnalysisID IN
(
SELECT ID FROM Tax.FEAnalysis WHERE ForeignExchangeID IN
(
SELECT ID FROM Tax.ForeignExchange WHERE EngagementID IN
(
SELECT Id FROM Tax.TaxCompanyEngagement WHERE TaxCompanyId IN
(
SELECT Id FROM Tax.TaxCompany WHERE IdtypeId IN
(
SELECT Id FROM Common.IdType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)
)
)
)

DELETE FROM Tax.FEAnalysisCountryCurrency WHERE FEAnalysisID IN
(
SELECT ID FROM Tax.FEAnalysis WHERE ForeignExchangeID IN
(
SELECT ID FROM Tax.ForeignExchange WHERE EngagementID IN
(
SELECT Id FROM Tax.TaxCompanyEngagement WHERE TaxCompanyId IN
(
SELECT Id FROM Tax.TaxCompany WHERE IdtypeId IN
(
SELECT Id FROM Common.IdType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)
)
)

DELETE FROM Tax.FEAnalysisNote WHERE FELegendID IN
(
SELECT ID FROM Tax.FEAnalysisLegend WHERE FEAnalysisID IN
(
SELECT ID FROM Tax.FEAnalysis WHERE ForeignExchangeID IN
(
SELECT ID FROM Tax.ForeignExchange WHERE EngagementID IN
(
SELECT Id FROM Tax.TaxCompanyEngagement WHERE TaxCompanyId IN
(
SELECT Id FROM Tax.TaxCompany WHERE IdtypeId IN
(
SELECT Id FROM Common.IdType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)
)
)
)

DELETE FROM Tax.FEAnalysisLegend WHERE FEAnalysisID IN
(
SELECT ID FROM Tax.FEAnalysis WHERE ForeignExchangeID IN
(
SELECT ID FROM Tax.ForeignExchange WHERE EngagementID IN
(
SELECT Id FROM Tax.TaxCompanyEngagement WHERE TaxCompanyId IN
(
SELECT Id FROM Tax.TaxCompany WHERE IdtypeId IN
(
SELECT Id FROM Common.IdType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)
)
)

DELETE FROM Tax.FEAnalysisNote WHERE FEAnalysisID IN
(
SELECT ID FROM Tax.FEAnalysis WHERE ForeignExchangeID IN
(
SELECT ID FROM Tax.ForeignExchange WHERE EngagementID IN
(
SELECT Id FROM Tax.TaxCompanyEngagement WHERE TaxCompanyId IN
(
SELECT Id FROM Tax.TaxCompany WHERE IdtypeId IN
(
SELECT Id FROM Common.IdType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)
)
)

DELETE FROM Tax.FEAnalysis WHERE ForeignExchangeID IN
(
SELECT ID FROM Tax.ForeignExchange WHERE EngagementID IN
(
SELECT Id FROM Tax.TaxCompanyEngagement WHERE TaxCompanyId IN
(
SELECT Id FROM Tax.TaxCompany WHERE IdtypeId IN
(
SELECT Id FROM Common.IdType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)
)

DELETE FROM Tax.ForeignCurrencyAnalysisFactors WHERE FCAnalysisID IN
(
SELECT ID FROM Tax.ForeignCurrencyAnalysis WHERE ForeignExchangeID IN
(
SELECT ID FROM Tax.ForeignExchange WHERE EngagementID IN
(
SELECT Id FROM Tax.TaxCompanyEngagement WHERE TaxCompanyId IN
(
SELECT Id FROM Tax.TaxCompany WHERE IdtypeId IN
(
SELECT Id FROM Common.IdType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)
)
)

DELETE FROM Tax.ForeignCurrencyAnalysis WHERE ForeignExchangeID IN
(
SELECT ID FROM Tax.ForeignExchange WHERE EngagementID IN
(
SELECT Id FROM Tax.TaxCompanyEngagement WHERE TaxCompanyId IN
(
SELECT Id FROM Tax.TaxCompany WHERE IdtypeId IN
(
SELECT Id FROM Common.IdType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)
)

DELETE FROM Tax.ForeignExchange WHERE EngagementID IN
(
SELECT Id FROM Tax.TaxCompanyEngagement WHERE TaxCompanyId IN
(
SELECT Id FROM Tax.TaxCompany WHERE IdtypeId IN
(
SELECT Id FROM Common.IdType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)

DELETE FROM Tax.FormDetail WHERE FormMasterId IN
(
SELECT Id FROM Tax.FormMaster WHERE EngagementId IN
(
SELECT Id FROM Tax.TaxCompanyEngagement WHERE TaxCompanyId IN
(
SELECT Id FROM Tax.TaxCompany WHERE IdtypeId IN
(
SELECT Id FROM Common.IdType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)
)

DELETE FROM Tax.FormMaster WHERE EngagementId IN
(
SELECT Id FROM Tax.TaxCompanyEngagement WHERE TaxCompanyId IN
(
SELECT Id FROM Tax.TaxCompany WHERE IdtypeId IN
(
SELECT Id FROM Common.IdType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)

DELETE FROM Tax.FurtherDeductionDetail WHERE FurtherDeductionId IN
(
SELECT Id FROM Tax.FurtherDeduction WHERE EngagementId IN
(
SELECT Id FROM Tax.TaxCompanyEngagement WHERE TaxCompanyId IN
(
SELECT Id FROM Tax.TaxCompany WHERE IdtypeId IN
(
SELECT Id FROM Common.IdType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)
)

DELETE FROM Tax.FurtherDeduction WHERE EngagementId IN
(
SELECT Id FROM Tax.TaxCompanyEngagement WHERE TaxCompanyId IN
(
SELECT Id FROM Tax.TaxCompany WHERE IdtypeId IN
(
SELECT Id FROM Common.IdType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)

DELETE FROM Tax.GeneralLedgerDetail WHERE GeneralLedgerId IN
(
SELECT Id FROM Tax.GeneralLedgerImport WHERE FileId IN
(
SELECT Id FROM Tax.GeneralLedgerFileDetails WHERE EngagementId IN
(
SELECT Id FROM Tax.TaxCompanyEngagement WHERE TaxCompanyId IN
(
SELECT Id FROM Tax.TaxCompany WHERE IdtypeId IN
(
SELECT Id FROM Common.IdType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)
)
)

DELETE FROM Tax.GeneralLedgerImport WHERE FileId IN
(
SELECT Id FROM Tax.GeneralLedgerFileDetails WHERE EngagementId IN
(
SELECT Id FROM Tax.TaxCompanyEngagement WHERE TaxCompanyId IN
(
SELECT Id FROM Tax.TaxCompany WHERE IdtypeId IN
(
SELECT Id FROM Common.IdType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)
)

DELETE FROM Tax.GeneralLedgerFileDetails WHERE EngagementId IN
(
SELECT Id FROM Tax.TaxCompanyEngagement WHERE TaxCompanyId IN
(
SELECT Id FROM Tax.TaxCompany WHERE IdtypeId IN
(
SELECT Id FROM Common.IdType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)

DELETE FROM Tax.GeneralLedgerDetail WHERE GeneralLedgerId IN
(
SELECT Id FROM Tax.GeneralLedgerImport WHERE EngagementId IN
(
SELECT Id FROM Tax.TaxCompanyEngagement WHERE TaxCompanyId IN
(
SELECT Id FROM Tax.TaxCompany WHERE IdtypeId IN
(
SELECT Id FROM Common.IdType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)
)

DELETE FROM Tax.GeneralLedgerImport WHERE EngagementId IN
(
SELECT Id FROM Tax.TaxCompanyEngagement WHERE TaxCompanyId IN
(
SELECT Id FROM Tax.TaxCompany WHERE IdtypeId IN
(
SELECT Id FROM Common.IdType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)

DELETE FROM Tax.InterestExpenses WHERE InterestRestrictionId IN
(
SELECT ID FROM Tax.InterestRestriction WHERE EngagementId IN
(
SELECT Id FROM Tax.TaxCompanyEngagement WHERE TaxCompanyId IN
(
SELECT Id FROM Tax.TaxCompany WHERE IdtypeId IN
(
SELECT Id FROM Common.IdType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)
)

DELETE FROM Tax.InvestmentSchedule WHERE InterestRestrictionId IN
(
SELECT ID FROM Tax.InterestRestriction WHERE EngagementId IN
(
SELECT Id FROM Tax.TaxCompanyEngagement WHERE TaxCompanyId IN
(
SELECT Id FROM Tax.TaxCompany WHERE IdtypeId IN
(
SELECT Id FROM Common.IdType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)
)

DELETE FROM Tax.InterestRestriction WHERE EngagementId IN
(
SELECT Id FROM Tax.TaxCompanyEngagement WHERE TaxCompanyId IN
(
SELECT Id FROM Tax.TaxCompany WHERE IdtypeId IN
(
SELECT Id FROM Common.IdType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)

DELETE FROM Tax.MedicalExpenseDetails WHERE MedicalExpensesId IN
(
SELECT Id FROM Tax.MedicalExpenses WHERE EngagementId IN
(
SELECT Id FROM Tax.TaxCompanyEngagement WHERE TaxCompanyId IN
(
SELECT Id FROM Tax.TaxCompany WHERE IdtypeId IN
(
SELECT Id FROM Common.IdType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)
)

DELETE FROM Tax.MedicalExpenses WHERE EngagementId IN
(
SELECT Id FROM Tax.TaxCompanyEngagement WHERE TaxCompanyId IN
(
SELECT Id FROM Tax.TaxCompany WHERE IdtypeId IN
(
SELECT Id FROM Common.IdType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)

DELETE FROM Tax.NonTradeIncomeDetail WHERE NonTradeIncomeId IN
(
SELECT Id FROM Tax.NonTradeIncome WHERE EngagementId IN
(
SELECT Id FROM Tax.TaxCompanyEngagement WHERE TaxCompanyId IN
(
SELECT Id FROM Tax.TaxCompany WHERE IdtypeId IN
(
SELECT Id FROM Common.IdType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)
)

DELETE FROM Tax.NonTradeIncome WHERE EngagementId IN
(
SELECT Id FROM Tax.TaxCompanyEngagement WHERE TaxCompanyId IN
(
SELECT Id FROM Tax.TaxCompany WHERE IdtypeId IN
(
SELECT Id FROM Common.IdType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)

DELETE FROM Tax.PIC WHERE EngagementID IN
(
SELECT Id FROM Tax.TaxCompanyEngagement WHERE TaxCompanyId IN
(
SELECT Id FROM Tax.TaxCompany WHERE IdtypeId IN
(
SELECT Id FROM Common.IdType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)

DELETE FROM Tax.ClientAndEngagementIndependenceConfirmation WHERE PlanningAndCompletionSetUpId IN
(
SELECT Id FROM Tax.PlanningAndCompletionSetUp WHERE EngagementId IN
(
SELECT Id FROM Tax.TaxCompanyEngagement WHERE TaxCompanyId IN
(
SELECT Id FROM Tax.TaxCompany WHERE IdtypeId IN
(
SELECT Id FROM Common.IdType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)
)

DELETE FROM Tax.DirectorRemunerationDetails WHERE DirectorRemunerationId IN
(
SELECT Id FROM Tax.DirectorRemuneration WHERE PlanningAndCompletionSetUpId IN
(
SELECT Id FROM Tax.PlanningAndCompletionSetUp WHERE EngagementId IN
(
SELECT Id FROM Tax.TaxCompanyEngagement WHERE TaxCompanyId IN
(
SELECT Id FROM Tax.TaxCompany WHERE IdtypeId IN
(
SELECT Id FROM Common.IdType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)
)
)

DELETE FROM Tax.DirectorRemuneration WHERE PlanningAndCompletionSetUpId IN
(
SELECT Id FROM Tax.PlanningAndCompletionSetUp WHERE EngagementId IN
(
SELECT Id FROM Tax.TaxCompanyEngagement WHERE TaxCompanyId IN
(
SELECT Id FROM Tax.TaxCompany WHERE IdtypeId IN
(
SELECT Id FROM Common.IdType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)
)

DELETE FROM Tax.PAndCSectionQuestions WHERE PAndCSectionId IN
(
SELECT Id FROM Tax.PAndCSections WHERE PlanningAndCompletionSetUpId IN
(
SELECT Id FROM Tax.PlanningAndCompletionSetUp WHERE EngagementId IN
(
SELECT Id FROM Tax.TaxCompanyEngagement WHERE TaxCompanyId IN
(
SELECT Id FROM Tax.TaxCompany WHERE IdtypeId IN
(
SELECT Id FROM Common.IdType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)
)
)

DELETE FROM Tax.PAndCSections WHERE PlanningAndCompletionSetUpId IN
(
SELECT Id FROM Tax.PlanningAndCompletionSetUp WHERE EngagementId IN
(
SELECT Id FROM Tax.TaxCompanyEngagement WHERE TaxCompanyId IN
(
SELECT Id FROM Tax.TaxCompany WHERE IdtypeId IN
(
SELECT Id FROM Common.IdType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)
)

DELETE FROM Tax.PlanningAndCompletionSetUp WHERE EngagementId IN
(
SELECT Id FROM Tax.TaxCompanyEngagement WHERE TaxCompanyId IN
(
SELECT Id FROM Tax.TaxCompany WHERE IdtypeId IN
(
SELECT Id FROM Common.IdType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)

------------------SELECT * FROM Tax.PlanningMateriality_ToBeDeleted ----> No Data in Table

------------------SELECT * FROM Tax.PlanningMaterialityDetailClassification_ToBeDeleted ----> No Data in Table

DELETE FROM Tax.ProfitAndLossAuditTrail WHERE EngagementID IN
(
SELECT Id FROM Tax.TaxCompanyEngagement WHERE TaxCompanyId IN
(
SELECT Id FROM Tax.TaxCompany WHERE IdtypeId IN
(
SELECT Id FROM Common.IdType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)

DELETE FROM Tax.ProfitAndLossFileDetails WHERE EngagementId IN
(
SELECT Id FROM Tax.TaxCompanyEngagement WHERE TaxCompanyId IN
(
SELECT Id FROM Tax.TaxCompany WHERE IdtypeId IN
(
SELECT Id FROM Common.IdType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)

DELETE FROM Tax.DonationReference WHERE ProfitAndLossImportId IN
(
SELECT Id FROM Tax.ProfitAndLossImport WHERE EngagementId IN
(
SELECT Id FROM Tax.TaxCompanyEngagement WHERE TaxCompanyId IN
(
SELECT Id FROM Tax.TaxCompany WHERE IdtypeId IN
(
SELECT Id FROM Common.IdType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)
)

DELETE FROM Tax.FurtherDeductionDetail WHERE ProfitAndLossImportId IN
(
SELECT Id FROM Tax.ProfitAndLossImport WHERE EngagementId IN
(
SELECT Id FROM Tax.TaxCompanyEngagement WHERE TaxCompanyId IN
(
SELECT Id FROM Tax.TaxCompany WHERE IdtypeId IN
(
SELECT Id FROM Common.IdType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)
)

DELETE FROM Tax.NonTradeIncomeDetail WHERE ProfitAndLossImportId IN
(
SELECT Id FROM Tax.ProfitAndLossImport WHERE EngagementId IN
(
SELECT Id FROM Tax.TaxCompanyEngagement WHERE TaxCompanyId IN
(
SELECT Id FROM Tax.TaxCompany WHERE IdtypeId IN
(
SELECT Id FROM Common.IdType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)
)

DELETE FROM Tax.RentalIncomeDetail WHERE ProfitAndLossImportId IN
(
SELECT Id FROM Tax.ProfitAndLossImport WHERE EngagementId IN
(
SELECT Id FROM Tax.TaxCompanyEngagement WHERE TaxCompanyId IN
(
SELECT Id FROM Tax.TaxCompany WHERE IdtypeId IN
(
SELECT Id FROM Common.IdType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)
)

DELETE FROM Tax.Section14QAdditions WHERE ProfitAndLossImportId IN
(
SELECT Id FROM Tax.ProfitAndLossImport WHERE EngagementId IN
(
SELECT Id FROM Tax.TaxCompanyEngagement WHERE TaxCompanyId IN
(
SELECT Id FROM Tax.TaxCompany WHERE IdtypeId IN
(
SELECT Id FROM Common.IdType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)
)

DELETE FROM Tax.StatementA WHERE PandLId IN
(
SELECT Id FROM Tax.ProfitAndLossImport WHERE EngagementId IN
(
SELECT Id FROM Tax.TaxCompanyEngagement WHERE TaxCompanyId IN
(
SELECT Id FROM Tax.TaxCompany WHERE IdtypeId IN
(
SELECT Id FROM Common.IdType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)
)

DELETE FROM Tax.ProfitAndLossImport WHERE EngagementId IN
(
SELECT Id FROM Tax.TaxCompanyEngagement WHERE TaxCompanyId IN
(
SELECT Id FROM Tax.TaxCompany WHERE IdtypeId IN
(
SELECT Id FROM Common.IdType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)

DELETE FROM Tax.ProfitAndLossTickmark WHERE EngagementID IN
(
SELECT Id FROM Tax.TaxCompanyEngagement WHERE TaxCompanyId IN
(
SELECT Id FROM Tax.TaxCompany WHERE IdtypeId IN
(
SELECT Id FROM Common.IdType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)

DELETE FROM Tax.RentalIncomeDetail WHERE RentalIncomeId IN
(
SELECT Id FROM Tax.RentalIncome WHERE EngagementID IN
(
SELECT Id FROM Tax.TaxCompanyEngagement WHERE TaxCompanyId IN
(
SELECT Id FROM Tax.TaxCompany WHERE IdtypeId IN
(
SELECT Id FROM Common.IdType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)
)

DELETE FROM Tax.RentalIncome WHERE EngagementID IN
(
SELECT Id FROM Tax.TaxCompanyEngagement WHERE TaxCompanyId IN
(
SELECT Id FROM Tax.TaxCompany WHERE IdtypeId IN
(
SELECT Id FROM Common.IdType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)

DELETE FROM Tax.RollForward WHERE OldEngagementId IN
(
SELECT Id FROM Tax.TaxCompanyEngagement WHERE TaxCompanyId IN
(
SELECT Id FROM Tax.TaxCompany WHERE IdtypeId IN
(
SELECT Id FROM Common.IdType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)

--------------SELECT * FROM Tax.Schedule_ToBeDeleted ----> No data in Table

DELETE FROM Tax.Section14QAdditions WHERE Section14QId IN
(
SELECT Id FROM Tax.Section14Q WHERE EngagementId IN
(
SELECT Id FROM Tax.TaxCompanyEngagement WHERE TaxCompanyId IN
(
SELECT Id FROM Tax.TaxCompany WHERE IdtypeId IN
(
SELECT Id FROM Common.IdType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)
)

DELETE FROM Tax.Section14QDetails WHERE Section14QId IN
(
SELECT Id FROM Tax.Section14Q WHERE EngagementId IN
(
SELECT Id FROM Tax.TaxCompanyEngagement WHERE TaxCompanyId IN
(
SELECT Id FROM Tax.TaxCompany WHERE IdtypeId IN
(
SELECT Id FROM Common.IdType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)
)

DELETE FROM Tax.Section14QEligibleExp WHERE Section14QId IN
(
SELECT Id FROM Tax.Section14Q WHERE EngagementId IN
(
SELECT Id FROM Tax.TaxCompanyEngagement WHERE TaxCompanyId IN
(
SELECT Id FROM Tax.TaxCompany WHERE IdtypeId IN
(
SELECT Id FROM Common.IdType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)
)

DELETE FROM Tax.Section14Q WHERE EngagementId IN
(
SELECT Id FROM Tax.TaxCompanyEngagement WHERE TaxCompanyId IN
(
SELECT Id FROM Tax.TaxCompany WHERE IdtypeId IN
(
SELECT Id FROM Common.IdType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)

DELETE FROM Tax.Disposal WHERE SectionAId IN
(
SELECT Id FROM Tax.SectionA WHERE EngagementId IN
(
SELECT Id FROM Tax.TaxCompanyEngagement WHERE TaxCompanyId IN
(
SELECT Id FROM Tax.TaxCompany WHERE IdtypeId IN
(
SELECT Id FROM Common.IdType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)
)

DELETE FROM Tax.Section14QAdditions WHERE SectionAId IN
(
SELECT Id FROM Tax.SectionA WHERE EngagementId IN
(
SELECT Id FROM Tax.TaxCompanyEngagement WHERE TaxCompanyId IN
(
SELECT Id FROM Tax.TaxCompany WHERE IdtypeId IN
(
SELECT Id FROM Common.IdType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)
)

DELETE FROM Tax.SectionADetail WHERE SECTIONAId IN
(
SELECT Id FROM Tax.SectionA WHERE EngagementId IN
(
SELECT Id FROM Tax.TaxCompanyEngagement WHERE TaxCompanyId IN
(
SELECT Id FROM Tax.TaxCompany WHERE IdtypeId IN
(
SELECT Id FROM Common.IdType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)
)

DELETE FROM Tax.SectionB WHERE SECTIONAId IN
(
SELECT Id FROM Tax.SectionA WHERE EngagementId IN
(
SELECT Id FROM Tax.TaxCompanyEngagement WHERE TaxCompanyId IN
(
SELECT Id FROM Tax.TaxCompany WHERE IdtypeId IN
(
SELECT Id FROM Common.IdType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)
)

DELETE FROM Tax.SectionA WHERE EngagementId IN
(
SELECT Id FROM Tax.TaxCompanyEngagement WHERE TaxCompanyId IN
(
SELECT Id FROM Tax.TaxCompany WHERE IdtypeId IN
(
SELECT Id FROM Common.IdType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)

DELETE FROM Tax.StatementA WHERE EngagementId IN
(
SELECT Id FROM Tax.TaxCompanyEngagement WHERE TaxCompanyId IN
(
SELECT Id FROM Tax.TaxCompany WHERE IdtypeId IN
(
SELECT Id FROM Common.IdType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)

DELETE FROM Tax.SubCategory WHERE EngagementId IN
(
SELECT Id FROM Tax.TaxCompanyEngagement WHERE TaxCompanyId IN
(
SELECT Id FROM Tax.TaxCompany WHERE IdtypeId IN
(
SELECT Id FROM Common.IdType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)

DELETE FROM Tax.TaxAuditTrail WHERE EngagementId IN
(
SELECT Id FROM Tax.TaxCompanyEngagement WHERE TaxCompanyId IN
(
SELECT Id FROM Tax.TaxCompany WHERE IdtypeId IN
(
SELECT Id FROM Common.IdType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)

DELETE FROM Tax.TaxCompanyEngagementDetails WHERE TaxCompanyEngagementId IN
(
SELECT Id FROM Tax.TaxCompanyEngagement WHERE TaxCompanyId IN
(
SELECT Id FROM Tax.TaxCompany WHERE IdtypeId IN
(
SELECT Id FROM Common.IdType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)

DELETE FROM Tax.TaxMenuPermissions WHERE TaxCompanyMenuMasterId IN
(
SELECT Id FROM Tax.TaxCompanyMenuMaster WHERE EngagementId IN
(
SELECT Id FROM Tax.TaxCompanyEngagement WHERE TaxCompanyId IN
(
SELECT Id FROM Tax.TaxCompany WHERE IdtypeId IN
(
SELECT Id FROM Common.IdType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)
)

DELETE FROM Tax.TaxCompanyMenuMaster WHERE EngagementId IN
(
SELECT Id FROM Tax.TaxCompanyEngagement WHERE TaxCompanyId IN
(
SELECT Id FROM Tax.TaxCompany WHERE IdtypeId IN
(
SELECT Id FROM Common.IdType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)

DELETE FROM Tax.TaxMenu WHERE EngagementId IN
(
SELECT Id FROM Tax.TaxCompanyEngagement WHERE TaxCompanyId IN
(
SELECT Id FROM Tax.TaxCompany WHERE IdtypeId IN
(
SELECT Id FROM Common.IdType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)

DELETE FROM Tax.TemplateVariable WHERE EngagementId IN
(
SELECT Id FROM Tax.TaxCompanyEngagement WHERE TaxCompanyId IN
(
SELECT Id FROM Tax.TaxCompany WHERE IdtypeId IN
(
SELECT Id FROM Common.IdType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)

DELETE FROM Tax.UserApproval WHERE EngagementId IN
(
SELECT Id FROM Tax.TaxCompanyEngagement WHERE TaxCompanyId IN
(
SELECT Id FROM Tax.TaxCompany WHERE IdtypeId IN
(
SELECT Id FROM Common.IdType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)

DELETE FROM Tax.TaxCompanyEngagement WHERE TaxCompanyId IN
(
SELECT Id FROM Tax.TaxCompany WHERE IdtypeId IN
(
SELECT Id FROM Common.IdType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)

DELETE FROM Tax.TaxMenu WHERE TaxCompanyId  IN
(
SELECT Id FROM Tax.TaxCompany WHERE IdtypeId IN
(
SELECT Id FROM Common.IdType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)

DELETE FROM Tax.TaxCompany WHERE IdtypeId IN
(
SELECT Id FROM Common.IdType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)

DELETE FROM HR.BankFileDetail WHERE TypeId IN
(
SELECT Id FROM HR.EmployeeClaim1 WHERE ClientId IN
(
SELECT Id FROM WorkFlow.Client WHERE IdtypeId IN
(
SELECT Id FROM Common.IdType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)

DELETE FROM HR.EmployeeClaimDetail WHERE EmployeeClaimId IN
(
SELECT Id FROM HR.EmployeeClaim1 WHERE ClientId IN
(
SELECT Id FROM WorkFlow.Client WHERE IdtypeId IN
(
SELECT Id FROM Common.IdType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)

DELETE FROM HR.EmployeeClaim1 WHERE ClientId IN
(
SELECT Id FROM WorkFlow.Client WHERE IdtypeId IN
(
SELECT Id FROM Common.IdType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)

DELETE FROM Common.TimeLogDetailSplit WHERE TimelogDetailId IN
(
SELECT Id FROM Common.TimeLogDetail WHERE TimeLogScheduleId IN
(
SELECT Id FROM Common.TimeLogSchedule WHERE CaseId IN
(
SELECT Id FROM WorkFlow.CaseGroup WHERE ClientId IN
(
SELECT Id FROM WorkFlow.Client WHERE IdtypeId IN
(
SELECT Id FROM Common.IdType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)
)
)

DELETE FROM Common.TimeLogDetail WHERE TimeLogScheduleId IN
(
SELECT Id FROM Common.TimeLogSchedule WHERE CaseId IN
(
SELECT Id FROM WorkFlow.CaseGroup WHERE ClientId IN
(
SELECT Id FROM WorkFlow.Client WHERE IdtypeId IN
(
SELECT Id FROM Common.IdType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)
)

DELETE FROM Common.TimeLogSchedule WHERE CaseId IN
(
SELECT Id FROM WorkFlow.CaseGroup WHERE ClientId IN
(
SELECT Id FROM WorkFlow.Client WHERE IdtypeId IN
(
SELECT Id FROM Common.IdType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)

DELETE FROM HR.BankFileDetail WHERE TypeId IN
(
SELECT Id FROM HR.EmployeeClaim1 WHERE CaseGroupId IN
(
SELECT Id FROM WorkFlow.CaseGroup WHERE ClientId IN
(
SELECT Id FROM WorkFlow.Client WHERE IdtypeId IN
(
SELECT Id FROM Common.IdType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)
)

DELETE FROM HR.EmployeeClaimDetail WHERE EmployeeClaimId IN
(
SELECT Id FROM HR.EmployeeClaim1 WHERE CaseGroupId IN
(
SELECT Id FROM WorkFlow.CaseGroup WHERE ClientId IN
(
SELECT Id FROM WorkFlow.Client WHERE IdtypeId IN
(
SELECT Id FROM Common.IdType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)
)

DELETE FROM HR.EmployeeClaim1 WHERE CaseGroupId IN
(
SELECT Id FROM WorkFlow.CaseGroup WHERE ClientId IN
(
SELECT Id FROM WorkFlow.Client WHERE IdtypeId IN
(
SELECT Id FROM Common.IdType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)

DELETE FROM WorkFlow.CaseAmendDateOfCompletion WHERE CaseId IN
(
SELECT Id FROM WorkFlow.CaseGroup WHERE ClientId IN
(
SELECT Id FROM WorkFlow.Client WHERE IdtypeId IN
(
SELECT Id FROM Common.IdType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)

DELETE FROM WorkFlow.CaseDesignation WHERE CaseId IN
(
SELECT Id FROM WorkFlow.CaseGroup WHERE ClientId IN
(
SELECT Id FROM WorkFlow.Client WHERE IdtypeId IN
(
SELECT Id FROM Common.IdType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)

-------SELECT * FROM WorkFlow.CaseDoc ----> No Data in Table

DELETE FROM Common.TimeLogDetailSplit WHERE CaseFeatureId IN
(
SELECT Id FROM WorkFlow.CaseFeature WHERE CaseId IN
(
SELECT Id FROM WorkFlow.CaseGroup WHERE ClientId IN
(
SELECT Id FROM WorkFlow.Client WHERE IdtypeId IN
(
SELECT Id FROM Common.IdType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)
)

DELETE FROM WorkFlow.ScheduleTaskDetail WHERE CaseFeatureId IN
(
SELECT Id FROM WorkFlow.CaseFeature WHERE CaseId IN
(
SELECT Id FROM WorkFlow.CaseGroup WHERE ClientId IN
(
SELECT Id FROM WorkFlow.Client WHERE IdtypeId IN
(
SELECT Id FROM Common.IdType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)
)

DELETE FROM WorkFlow.CaseFeature WHERE CaseId IN
(
SELECT Id FROM WorkFlow.CaseGroup WHERE ClientId IN
(
SELECT Id FROM WorkFlow.Client WHERE IdtypeId IN
(
SELECT Id FROM Common.IdType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)

DELETE FROM WorkFlow.CaseIncharge WHERE CaseId IN
(
SELECT Id FROM WorkFlow.CaseGroup WHERE ClientId IN
(
SELECT Id FROM WorkFlow.Client WHERE IdtypeId IN
(
SELECT Id FROM Common.IdType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)

DELETE FROM WorkFlow.CaseMileStone WHERE CaseId IN
(
SELECT Id FROM WorkFlow.CaseGroup WHERE ClientId IN
(
SELECT Id FROM WorkFlow.Client WHERE IdtypeId IN
(
SELECT Id FROM Common.IdType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)

----------SELECT * FROM WorkFlow.CasesAssigned ----> No Data in Table

DELETE FROM WorkFlow.CaseStatusChange WHERE CaseId IN
(
SELECT Id FROM WorkFlow.CaseGroup WHERE ClientId IN
(
SELECT Id FROM WorkFlow.Client WHERE IdtypeId IN
(
SELECT Id FROM Common.IdType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)

DELETE FROM WorkFlow.Claim WHERE CaseId IN
(
SELECT Id FROM WorkFlow.CaseGroup WHERE ClientId IN
(
SELECT Id FROM WorkFlow.Client WHERE IdtypeId IN
(
SELECT Id FROM Common.IdType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)

DELETE FROM WorkFlow.Incidental WHERE InvoiceId IN
(
SELECT Id FROM WorkFlow.Invoice WHERE CaseId IN
(
SELECT Id FROM WorkFlow.CaseGroup WHERE ClientId IN
(
SELECT Id FROM WorkFlow.Client WHERE IdtypeId IN
(
SELECT Id FROM Common.IdType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)
)

DELETE FROM WorkFlow.InvoiceDesignation WHERE InvoiceId IN
(
SELECT Id FROM WorkFlow.Invoice WHERE CaseId IN
(
SELECT Id FROM WorkFlow.CaseGroup WHERE ClientId IN
(
SELECT Id FROM WorkFlow.Client WHERE IdtypeId IN
(
SELECT Id FROM Common.IdType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)
)

-------SELECT * FROM WorkFlow.InvoiceState ----> No Data in Table

DELETE FROM WorkFlow.Invoice WHERE CaseId IN
(
SELECT Id FROM WorkFlow.CaseGroup WHERE ClientId IN
(
SELECT Id FROM WorkFlow.Client WHERE IdtypeId IN
(
SELECT Id FROM Common.IdType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)

DELETE FROM WorkFlow.InvoiceDesignation WHERE CaseId IN
(
SELECT Id FROM WorkFlow.CaseGroup WHERE ClientId IN
(
SELECT Id FROM WorkFlow.Client WHERE IdtypeId IN
(
SELECT Id FROM Common.IdType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
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
SELECT Id FROM WorkFlow.CaseGroup WHERE ClientId IN
(
SELECT Id FROM WorkFlow.Client WHERE IdtypeId IN
(
SELECT Id FROM Common.IdType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
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
SELECT Id FROM WorkFlow.CaseGroup WHERE ClientId IN
(
SELECT Id FROM WorkFlow.Client WHERE IdtypeId IN
(
SELECT Id FROM Common.IdType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)
)
)

DELETE FROM WorkFlow.ScheduleDetail WHERE MasterId IN
(
SELECT Id FROM WorkFlow.Schedule WHERE CaseId IN
(
SELECT Id FROM WorkFlow.CaseGroup WHERE ClientId IN
(
SELECT Id FROM WorkFlow.Client WHERE IdtypeId IN
(
SELECT Id FROM Common.IdType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)
)

DELETE FROM WorkFlow.Schedule WHERE CaseId IN
(
SELECT Id FROM WorkFlow.CaseGroup WHERE ClientId IN
(
SELECT Id FROM WorkFlow.Client WHERE IdtypeId IN
(
SELECT Id FROM Common.IdType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)


DELETE FROM WorkFlow.ScheduleTaskNew WHERE ScheduleDetailId IN
(
SELECT Id FROM WorkFlow.ScheduleDetailNew WHERE MasterId IN
(
SELECT Id FROM WorkFlow.ScheduleNew WHERE CaseId IN
(
SELECT Id FROM WorkFlow.CaseGroup WHERE ClientId IN
(
SELECT Id FROM WorkFlow.Client WHERE IdtypeId IN
(
SELECT Id FROM Common.IdType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)
)
)


DELETE FROM WorkFlow.ScheduleDetailNew WHERE MasterId IN
(
SELECT Id FROM WorkFlow.ScheduleNew WHERE CaseId IN
(
SELECT Id FROM WorkFlow.CaseGroup WHERE ClientId IN
(
SELECT Id FROM WorkFlow.Client WHERE IdtypeId IN
(
SELECT Id FROM Common.IdType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)
)

DELETE FROM WorkFlow.ScheduleNew WHERE CaseId IN
(
SELECT Id FROM WorkFlow.CaseGroup WHERE ClientId IN
(
SELECT Id FROM WorkFlow.Client WHERE IdtypeId IN
(
SELECT Id FROM Common.IdType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)


DELETE FROM WorkFlow.ScheduleTaskDetail WHERE ScheduleTaskId IN
(
SELECT Id FROM WorkFlow.ScheduleTask WHERE CaseId IN
(
SELECT Id FROM WorkFlow.CaseGroup WHERE ClientId IN
(
SELECT Id FROM WorkFlow.Client WHERE IdtypeId IN
(
SELECT Id FROM Common.IdType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)
)


DELETE FROM WorkFlow.ScheduleTask WHERE CaseId IN
(
SELECT Id FROM WorkFlow.CaseGroup WHERE ClientId IN
(
SELECT Id FROM WorkFlow.Client WHERE IdtypeId IN
(
SELECT Id FROM Common.IdType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)


DELETE FROM WorkFlow.ScheduleTaskNew WHERE CaseId IN
(
SELECT Id FROM WorkFlow.CaseGroup WHERE ClientId IN
(
SELECT Id FROM WorkFlow.Client WHERE IdtypeId IN
(
SELECT Id FROM Common.IdType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)


DELETE FROM WorkFlow.CaseGroup WHERE ClientId IN
(
SELECT Id FROM WorkFlow.Client WHERE IdtypeId IN
(
SELECT Id FROM Common.IdType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)

DELETE FROM WorkFlow.ClientContact WHERE ClientId IN
(
SELECT Id FROM WorkFlow.Client WHERE IdtypeId IN
(
SELECT Id FROM Common.IdType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)

DELETE FROM WorkFlow.ClientStatusChange WHERE ClientId IN
(
SELECT Id FROM WorkFlow.Client WHERE IdtypeId IN
(
SELECT Id FROM Common.IdType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)

DELETE FROM WorkFlow.Client WHERE IdtypeId IN
(
SELECT Id FROM Common.IdType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)

DELETE FROM Common.IdType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo) 

----------------------/////////////////////////////////////////////////////////////////////////////// Common.Industry \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

--------------------SELECT * FROM Common.Industry WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo) -----> No Data in Table

----------------------/////////////////////////////////////////////////////////////////////////////// Common.InitialCursorSetup \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

DELETE FROM Common.InitialCursorSetup WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)

----------------------/////////////////////////////////////////////////////////////////////////////// Common.MasterLog \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

DELETE FROM Common.DetailLog WHERE MasterId IN
(
SELECT Id FROM Common.MasterLog WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)

DELETE FROM Common.MasterLog WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)

----------------------/////////////////////////////////////////////////////////////////////////////// Common.Matters \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

----------------SELECT * FROM Common.Matters WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo) ----> No Data in Table

----------------------/////////////////////////////////////////////////////////////////////////////// Common.MessageMaster \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

----------------SELECT * FROM Common.MessageMaster_ToBeDeleted WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo) ----> No Data in Table

----------------------/////////////////////////////////////////////////////////////////////////////// Common.ModuleMaster \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

------------------SELECT * FROM Common.ModuleMaster WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo) -----> Seed Data table no need to delete

----------------------/////////////////////////////////////////////////////////////////////////////// Common.ReminderBatchList \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

DELETE FROM Common.ReminderBatchList WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)

----------------------/////////////////////////////////////////////////////////////////////////////// Common.ReminderMaster \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

DELETE FROM Common.ReminderDetailTemplate WHERE ReminderDetailId IN
(
SELECT Id FROM Common.ReminderDetail WHERE ReminderMasterId IN
(
SELECT Id FROM Common.ReminderMaster WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)

DELETE FROM Common.ReminderDetail WHERE ReminderMasterId IN
(
SELECT Id FROM Common.ReminderMaster WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)

DELETE FROM Common.ReminderMaster WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)

----------------------/////////////////////////////////////////////////////////////////////////////// Common.ReminderSetting \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

DELETE FROM Common.ReminderSetting WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)

----------------------/////////////////////////////////////////////////////////////////////////////// Common.Service \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

DELETE FROM ClientCursor.OpportunityDesignation WHERE OpportunityId IN
(
SELECT Id FROM ClientCursor.Opportunity WHERE ServiceId IN
(
SELECT Id FROM Common.Service WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)

------------SELECT * FROM ClientCursor.[OpportunityDoc] ----> No Data in Table

DELETE FROM ClientCursor.OpportunityHistory WHERE OpportunityId IN
(
SELECT Id FROM ClientCursor.Opportunity WHERE ServiceId IN
(
SELECT Id FROM Common.Service WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)

DELETE FROM ClientCursor.OpportunityIncharge WHERE OpportunityId IN
(
SELECT Id FROM ClientCursor.Opportunity WHERE ServiceId IN
(
SELECT Id FROM Common.Service WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)

DELETE FROM ClientCursor.OpportunityStatusChange WHERE OpportunityId IN
(
SELECT Id FROM ClientCursor.Opportunity WHERE ServiceId IN
(
SELECT Id FROM Common.Service WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)

----------SELECT * FROM ClientCursor.OpportunityTermsCondition_ToBeDeleted ---> No Data in Table

DELETE FROM ClientCursor.QuotationDetailTemplate WHERE QuotationDetailId IN
(
SELECT Id FROM ClientCursor.QuotationDetail WHERE OpportunityId IN
(
SELECT Id FROM ClientCursor.Opportunity WHERE ServiceId IN
(
SELECT Id FROM Common.Service WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)

DELETE FROM ClientCursor.QuotationDetail WHERE OpportunityId IN
(
SELECT Id FROM ClientCursor.Opportunity WHERE ServiceId IN
(
SELECT Id FROM Common.Service WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
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
SELECT Id FROM Common.Service WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
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
SELECT Id FROM Common.Service WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
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
SELECT Id FROM Common.Service WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
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
SELECT Id FROM Common.Service WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
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
SELECT Id FROM Common.Service WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
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
SELECT Id FROM Common.Service WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)

DELETE FROM WorkFlow.CaseAmendDateOfCompletion WHERE CaseId IN
(
SELECT Id FROM WorkFlow.CaseGroup WHERE OpportunityId IN
(
SELECT Id FROM ClientCursor.Opportunity WHERE ServiceId IN
(
SELECT Id FROM Common.Service WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)

DELETE FROM WorkFlow.CaseDesignation WHERE CaseId IN
(
SELECT Id FROM WorkFlow.CaseGroup WHERE OpportunityId IN
(
SELECT Id FROM ClientCursor.Opportunity WHERE ServiceId IN
(
SELECT Id FROM Common.Service WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
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
SELECT Id FROM Common.Service WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
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
SELECT Id FROM Common.Service WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
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
SELECT Id FROM Common.Service WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)

DELETE FROM WorkFlow.CaseIncharge WHERE CaseId IN
(
SELECT Id FROM WorkFlow.CaseGroup WHERE OpportunityId IN
(
SELECT Id FROM ClientCursor.Opportunity WHERE ServiceId IN
(
SELECT Id FROM Common.Service WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)

DELETE FROM WorkFlow.CaseMileStone WHERE CaseId IN
(
SELECT Id FROM WorkFlow.CaseGroup WHERE OpportunityId IN
(
SELECT Id FROM ClientCursor.Opportunity WHERE ServiceId IN
(
SELECT Id FROM Common.Service WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
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
SELECT Id FROM Common.Service WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)

DELETE FROM WorkFlow.Claim WHERE CaseId IN
(
SELECT Id FROM WorkFlow.CaseGroup WHERE OpportunityId IN
(
SELECT Id FROM ClientCursor.Opportunity WHERE ServiceId IN
(
SELECT Id FROM Common.Service WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
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
SELECT Id FROM Common.Service WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
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
SELECT Id FROM Common.Service WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
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
SELECT Id FROM Common.Service WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)

DELETE FROM WorkFlow.InvoiceDesignation WHERE CaseId IN
(
SELECT Id FROM WorkFlow.CaseGroup WHERE OpportunityId IN
(
SELECT Id FROM ClientCursor.Opportunity WHERE ServiceId IN
(
SELECT Id FROM Common.Service WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
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
SELECT Id FROM Common.Service WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
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
SELECT Id FROM Common.Service WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
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
SELECT Id FROM Common.Service WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
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
SELECT Id FROM Common.Service WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
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
SELECT Id FROM Common.Service WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
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
SELECT Id FROM Common.Service WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
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
SELECT Id FROM Common.Service WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
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
SELECT Id FROM Common.Service WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
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
SELECT Id FROM Common.Service WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)

DELETE FROM WorkFlow.ScheduleTaskNew WHERE CaseId IN
(
SELECT Id FROM WorkFlow.CaseGroup WHERE OpportunityId IN
(
SELECT Id FROM ClientCursor.Opportunity WHERE ServiceId IN
(
SELECT Id FROM Common.Service WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)
-----------============ CASEGROUP ==================
DELETE FROM WorkFlow.CaseGroup WHERE OpportunityId IN
(
SELECT Id FROM ClientCursor.Opportunity WHERE ServiceId IN
(
SELECT Id FROM Common.Service WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)

DELETE FROM ClientCursor.Opportunity WHERE ServiceId IN
(
SELECT Id FROM Common.Service WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)

DELETE FROM Common.CompanyService WHERE ServiceId IN
(
SELECT Id FROM Common.Service WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)

DELETE FROM Common.DesignationHourlyRate WHERE ServiceId IN
(
SELECT Id FROM Common.Service WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)

DELETE FROM Common.Milestone WHERE ServiceId IN
(
SELECT Id FROM Common.Service WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)

---------SELECT * FROM Common.ServiceRate_ToBeDeleted ---> No Data in Table

DELETE FROM Common.ServiceRecuringSettings WHERE ServiceId IN
(
SELECT Id FROM Common.Service WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)

-------SELECT * FROM Common.ServiceTemplate_ToBeDeleted ---> No Data in Table

DELETE FROM Common.Task WHERE ServiceId IN
(
SELECT Id FROM Common.Service WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
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
SELECT Id FROM Common.Service WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
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
SELECT Id FROM Common.Service WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)

DELETE FROM Common.TimeLogSchedule WHERE CaseId IN
(
SELECT Id FROM WorkFlow.CaseGroup WHERE ServiceId IN
(
SELECT Id FROM Common.Service WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)

DELETE FROM HR.BankFileDetail WHERE TypeId IN
(
SELECT Id FROM HR.EmployeeClaim1 WHERE CaseGroupId IN
(
SELECT Id FROM WorkFlow.CaseGroup WHERE ServiceId IN
(
SELECT Id FROM Common.Service WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)

DELETE FROM HR.EmployeeClaimDetail WHERE EmployeeClaimId IN
(
SELECT Id FROM HR.EmployeeClaim1 WHERE CaseGroupId IN
(
SELECT Id FROM WorkFlow.CaseGroup WHERE ServiceId IN
(
SELECT Id FROM Common.Service WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)

DELETE FROM HR.EmployeeClaim1 WHERE CaseGroupId IN
(
SELECT Id FROM WorkFlow.CaseGroup WHERE ServiceId IN
(
SELECT Id FROM Common.Service WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)

DELETE FROM WorkFlow.CaseAmendDateOfCompletion WHERE CaseId IN
(
SELECT Id FROM WorkFlow.CaseGroup WHERE ServiceId IN
(
SELECT Id FROM Common.Service WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)

DELETE FROM WorkFlow.CaseDesignation WHERE CaseId IN
(
SELECT Id FROM WorkFlow.CaseGroup WHERE ServiceId IN
(
SELECT Id FROM Common.Service WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)

-------SELECT * FROM WorkFlow.CaseDoc ----> No Data in Table

DELETE FROM Common.TimeLogDetailSplit WHERE CaseFeatureId IN
(
SELECT Id FROM WorkFlow.CaseFeature WHERE CaseId IN
(
SELECT Id FROM WorkFlow.CaseGroup WHERE ServiceId IN
(
SELECT Id FROM Common.Service WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)

DELETE FROM WorkFlow.ScheduleTaskDetail WHERE CaseFeatureId IN
(
SELECT Id FROM WorkFlow.CaseFeature WHERE CaseId IN
(
SELECT Id FROM WorkFlow.CaseGroup WHERE ServiceId IN
(
SELECT Id FROM Common.Service WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)

DELETE FROM WorkFlow.CaseFeature WHERE CaseId IN
(
SELECT Id FROM WorkFlow.CaseGroup WHERE ServiceId IN
(
SELECT Id FROM Common.Service WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)

DELETE FROM WorkFlow.CaseIncharge WHERE CaseId IN
(
SELECT Id FROM WorkFlow.CaseGroup WHERE ServiceId IN
(
SELECT Id FROM Common.Service WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)

DELETE FROM WorkFlow.CaseMileStone WHERE CaseId IN
(
SELECT Id FROM WorkFlow.CaseGroup WHERE ServiceId IN
(
SELECT Id FROM Common.Service WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)

----------SELECT * FROM WorkFlow.CasesAssigned ----> No Data in Table

DELETE FROM WorkFlow.CaseStatusChange WHERE CaseId IN
(
SELECT Id FROM WorkFlow.CaseGroup WHERE ServiceId IN
(
SELECT Id FROM Common.Service WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)

DELETE FROM WorkFlow.Claim WHERE CaseId IN
(
SELECT Id FROM WorkFlow.CaseGroup WHERE ServiceId IN
(
SELECT Id FROM Common.Service WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)

DELETE FROM WorkFlow.Incidental WHERE InvoiceId IN
(
SELECT Id FROM WorkFlow.Invoice WHERE CaseId IN
(
SELECT Id FROM WorkFlow.CaseGroup WHERE ServiceId IN
(
SELECT Id FROM Common.Service WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)

DELETE FROM WorkFlow.InvoiceDesignation WHERE InvoiceId IN
(
SELECT Id FROM WorkFlow.Invoice WHERE CaseId IN
(
SELECT Id FROM WorkFlow.CaseGroup WHERE ServiceId IN
(
SELECT Id FROM Common.Service WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)

-------SELECT * FROM WorkFlow.InvoiceState ----> No Data in Table

DELETE FROM WorkFlow.Invoice WHERE CaseId IN
(
SELECT Id FROM WorkFlow.CaseGroup WHERE ServiceId IN
(
SELECT Id FROM Common.Service WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)

DELETE FROM WorkFlow.InvoiceDesignation WHERE CaseId IN
(
SELECT Id FROM WorkFlow.CaseGroup WHERE ServiceId IN
(
SELECT Id FROM Common.Service WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
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
SELECT Id FROM Common.Service WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
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
SELECT Id FROM Common.Service WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
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
SELECT Id FROM Common.Service WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)

DELETE FROM WorkFlow.Schedule WHERE CaseId IN
(
SELECT Id FROM WorkFlow.CaseGroup WHERE ServiceId IN
(
SELECT Id FROM Common.Service WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
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
SELECT Id FROM Common.Service WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
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
SELECT Id FROM Common.Service WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)

DELETE FROM WorkFlow.ScheduleNew WHERE CaseId IN
(
SELECT Id FROM WorkFlow.CaseGroup WHERE ServiceId IN
(
SELECT Id FROM Common.Service WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)


DELETE FROM WorkFlow.ScheduleTaskDetail WHERE ScheduleTaskId IN
(
SELECT Id FROM WorkFlow.ScheduleTask WHERE CaseId IN
(
SELECT Id FROM WorkFlow.CaseGroup WHERE ServiceId IN
(
SELECT Id FROM Common.Service WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)


DELETE FROM WorkFlow.ScheduleTask WHERE CaseId IN
(
SELECT Id FROM WorkFlow.CaseGroup WHERE ServiceId IN
(
SELECT Id FROM Common.Service WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)


DELETE FROM WorkFlow.ScheduleTaskNew WHERE CaseId IN
(
SELECT Id FROM WorkFlow.CaseGroup WHERE ServiceId IN
(
SELECT Id FROM Common.Service WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)


DELETE FROM WorkFlow.CaseGroup WHERE ServiceId IN
(
SELECT Id FROM Common.Service WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)

DELETE FROM Common.Service WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)

----------------------/////////////////////////////////////////////////////////////////////////////// Common.ServiceGroup \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

DELETE FROM Common.Milestone WHERE ServiceGroupId IN
(
SELECT Id FROM Common.ServiceGroup WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)

DELETE FROM ClientCursor.VendorService WHERE ServiceGroupId IN
(
SELECT Id FROM Common.ServiceGroup WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)

DELETE FROM Common.Task WHERE ServiceGroupId IN
(
SELECT Id FROM Common.ServiceGroup WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)

DELETE FROM Common.DesignationHourlyRate WHERE ServiceGroupId IN
(
SELECT Id FROM Common.ServiceGroup WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)

DELETE FROM Common.ServiceGroup WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)

----------------------/////////////////////////////////////////////////////////////////////////////// Common.SOAReminderBatchList \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

DELETE FROM Common.SOAReminderBatchListDetails WHERE MasterId IN
(
SELECT Id FROM Common.SOAReminderBatchList WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)

DELETE FROM Common.SOAReminderBatchList WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)

----------------------/////////////////////////////////////////////////////////////////////////////// Common.StateChange \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

--------------SELECT * FROM Common.StateChange WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo) ------> Only seed data present in table

----------------------/////////////////////////////////////////////////////////////////////////////// Common.Suggestion  \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

DELETE FROM Common.[Suggestion ]  WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo) 

----------------------/////////////////////////////////////////////////////////////////////////////// Common.Template \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

DELETE FROM Common.TemplateRelatedTo WHERE TemplateId IN
(
SELECT Id FROM Common.Template WHERE CompanyId IN (SELECT Id FROM @CompanyInfo) 
)

DELETE FROM Common.Template WHERE CompanyId IN (SELECT Id FROM @CompanyInfo) 

----------------------/////////////////////////////////////////////////////////////////////////////// Common.TemplateMaster_ToBeDeleted \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

--------------------SELECT * FROM Common.TemplateMaster_ToBeDeleted ----> No Data in table

----------------------/////////////////////////////////////////////////////////////////////////////// Common.TemplateSetUp \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

--------------------SELECT * FROM Common.TemplateSetUp WHERE CompanyId IN (SELECT Id FROM @CompanyInfo) ----> No Data in table

----------------------/////////////////////////////////////////////////////////////////////////////// Common.TemplateType \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

DELETE FROM Boardroom.GenerateTemplate WHERE MenuId IN
(
SELECT Id FROM Common.TemplateType WHERE CompanyId IN (SELECT Id FROM @CompanyInfo)
)

DELETE FROM Common.TemplateTypeDetail WHERE TemplateTypeId IN
(
SELECT Id FROM Common.TemplateType WHERE CompanyId IN (SELECT Id FROM @CompanyInfo)
)

DELETE FROM Common.GenericTemplateDetail WHERE GenericTemplateId IN
(
SELECT Id FROM Common.GenericTemplate WHERE TemplateTypeId IN
(
SELECT Id FROM Common.TemplateType WHERE CompanyId IN (SELECT Id FROM @CompanyInfo)
)
)

DELETE FROM Common.GenericTemplate WHERE TemplateTypeId IN
(
SELECT Id FROM Common.TemplateType WHERE CompanyId IN (SELECT Id FROM @CompanyInfo)
)

DELETE FROM Common.TemplateType WHERE CompanyId IN (SELECT Id FROM @CompanyInfo) 

----------------------/////////////////////////////////////////////////////////////////////////////// Common.TermsOfPayment \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

DELETE FROM WorkFlow.ClientStatusChange WHERE ClientId IN
(
SELECT Id FROM WorkFlow.Client WHERE TermsOfPaymentId IN
(
SELECT Id FROM Common.TermsOfPayment WHERE CompanyId IN (SELECT Id FROM @CompanyInfo) 
)
)

DELETE FROM WorkFlow.Client WHERE TermsOfPaymentId IN
(
SELECT Id FROM Common.TermsOfPayment WHERE CompanyId IN (SELECT Id FROM @CompanyInfo) 
)

DELETE FROM Common.TermsOfPayment WHERE CompanyId IN (SELECT Id FROM @CompanyInfo) 

----------------------/////////////////////////////////////////////////////////////////////////////// Common.TimeLog \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

DELETE FROM Common.TimeLog WHERE CompanyId IN (SELECT Id FROM @CompanyInfo)

---------------------/////////////////////////////////////////////////////////////////////////////// Common.TimeLogItem \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

DELETE FROM Common.TimeLogItemDetail WHERE TimeLogItemId IN
(
SELECT Id FROM Common.TimeLogItem WHERE CompanyId IN (SELECT Id FROM @CompanyInfo)
)

DELETE FROM Common.TimeLogItem WHERE CompanyId IN (SELECT Id FROM @CompanyInfo)

---------------------/////////////////////////////////////////////////////////////////////////////// Common.TimeLogSettings \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

DELETE FROM Common.TimeLogSettings WHERE CompanyId IN (SELECT Id FROM @CompanyInfo)

---------------------/////////////////////////////////////////////////////////////////////////////// Common.TimeLogSetup \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

DELETE FROM Common.TimeLogSetup WHERE CompanyId IN (SELECT Id FROM @CompanyInfo)

---------------------/////////////////////////////////////////////////////////////////////////////// Common.[Transaction] \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

DELETE FROM Common.[Transaction] WHERE CompanyId IN (SELECT Id FROM @CompanyInfo)

---------------------/////////////////////////////////////////////////////////////////////////////// Common.UserAccountCursors \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

--------------------SELECT * FROM Common.UserAccountCursors WHERE CompanyId IN (SELECT Id FROM @CompanyInfo) -----> No Data in Table

---------------------/////////////////////////////////////////////////////////////////////////////// Common.Widget \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

------------------------SELECT * FROM Common.Widget WHERE CompanyId IN (SELECT Id FROM @CompanyInfo)  -----> No Data in Table

---------------------/////////////////////////////////////////////////////////////////////////////// Common.WorkWeekSetUp \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

DELETE FROM Common.WorkWeekSetUp WHERE CompanyId IN (SELECT Id FROM @CompanyInfo)  

---------------------/////////////////////////////////////////////////////////////////////////////// Common.XeroAccountType \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

----------------------SELECT * FROM Common.XeroAccountType WHERE CompanyId IN (SELECT Id FROM @CompanyInfo)  -----> Seed Data only

---------------------/////////////////////////////////////////////////////////////////////////////// Common.XeroCOA \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

DELETE FROM Common.XeroCOADetail WHERE XeroCOAId IN
(
SELECT Id FROM Common.XeroCOA WHERE CompanyId IN (SELECT Id FROM @CompanyInfo)
)

DELETE FROM Common.XeroCOA WHERE CompanyId IN (SELECT Id FROM @CompanyInfo)

---------------------/////////////////////////////////////////////////////////////////////////////// Common.XeroOrganisation \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

DELETE FROM Common.XeroOrganisation WHERE CompanyId IN (SELECT Id FROM @CompanyInfo)

---------------------/////////////////////////////////////////////////////////////////////////////// Common.XeroTaxCodes \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

DELETE FROM Common.XeroTaxCodeDetail WHERE XeroTaxCodeId IN
(
SELECT Id FROM Common.XeroTaxCodes WHERE CompanyId IN (SELECT Id FROM @CompanyInfo)
)

DELETE FROM Common.XeroTaxCodes WHERE CompanyId IN (SELECT Id FROM @CompanyInfo)

---------------------/////////////////////////////////////////////////////////////////////////////// Common.XeroTaxCodes \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

------------------SELECT * FROM dbo.TempAttendence WHERE CompanyId IN (SELECT Id FROM @CompanyInfo) -----> No Data in Table
 
-----------------------/////////////////////////////////////////////////////////////////////////////// dbo.Users \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

--------------SELECT * FROM dbo.Users WHERE CompanyId IN (SELECT Id FROM @CompanyInfo)  ----> Seed data only

-----------------------/////////////////////////////////////////////////////////////////////////////// DR.AccountType \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

------------------SELECT * FROM DR.AccountType WHERE CompanyId IN (SELECT Id FROM @CompanyInfo) ----> Seed data only

-----------------------/////////////////////////////////////////////////////////////////////////////// DR.FinanceCompany \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

DELETE FROM DR.GeneralLedgerDetail WHERE GeneralLedgerId IN
(
SELECT Id FROM DR.GeneralLedgerHeader WHERE EngagementId IN 
(
SELECT Id FROM DR.FinanceCompanyEngagement WHERE FinanceCompanyId IN
(
SELECT Id FROM DR.FinanceCompany WHERE CompanyId IN (SELECT Id FROM @CompanyInfo)
)
)
)

DELETE FROM DR.GeneralLedgerHeader WHERE EngagementId IN 
(
SELECT Id FROM DR.FinanceCompanyEngagement WHERE FinanceCompanyId IN
(
SELECT Id FROM DR.FinanceCompany WHERE CompanyId IN (SELECT Id FROM @CompanyInfo)
)
)

DELETE FROM DR.FinanceCompanyEngagement WHERE FinanceCompanyId IN
(
SELECT Id FROM DR.FinanceCompany WHERE CompanyId IN (SELECT Id FROM @CompanyInfo)
)

DELETE FROM DR.FinanceCompany WHERE CompanyId IN (SELECT Id FROM @CompanyInfo)

DELETE FROM DR.FinanceCompany WHERE ServiceCompanyId IN (SELECT Id FROM @CompanyInfo)


-----------------------/////////////////////////////////////////////////////////////////////////////// DR.GeneralLedgerHeader \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

DELETE FROM DR.GeneralLedgerDetail WHERE GeneralLedgerId IN (SELECT Id FROM DR.GeneralLedgerHeader WHERE CompanyId = @CompanyId)

DELETE FROM DR.GeneralLedgerHeader WHERE CompanyId IN (SELECT Id FROM @CompanyInfo)

-----------------------/////////////////////////////////////////////////////////////////////////////// DR.KPITarget \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

DELETE FROM DR.KPITarget WHERE CompanyId IN (SELECT Id FROM @CompanyInfo)

-----------------------/////////////////////////////////////////////////////////////////////////////// DR.Localization \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

DELETE FROM DR.Localization WHERE CompanyId IN (SELECT Id FROM @CompanyInfo)

END

GO
