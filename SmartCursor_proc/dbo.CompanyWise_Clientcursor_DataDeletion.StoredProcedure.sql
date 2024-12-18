USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[CompanyWise_Clientcursor_DataDeletion]    Script Date: 16-12-2024 9.20.10 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   PROCEDURE [dbo].[CompanyWise_Clientcursor_DataDeletion]
@CompanyId Int

AS
BEGIN

DECLARE @CompanyInfo TABLE (Id Int, RegistrationNo Nvarchar(150), Name Nvarchar(500))

INSERT INTO @CompanyInfo
SELECT Id,RegistrationNo,Name FROM Common.Company WHERE Id = @CompanyId
UNION ALL
SELECT Id,RegistrationNo,Name FROM Common.Company WHERE ParentId = @CompanyId


----------------------==================================================================================================================================================================================================
----------------------/////////////////////////////////////////////////////////////////////////////// CLIENT CURSOR \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
-----------------------==================================================================================================================================================================================================

--------------------//////////////////////////////////////////////////////////////////////// ClientCursor.Account \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

DELETE FROM ClientCursor.AccountIncharge WHERE AccountId IN
(
SELECT Id FROM ClientCursor.Account WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)

------------SELECT * FROM ClientCursor.AccountNote_ToBeDeleted ----> No Data in Table

DELETE FROM ClientCursor.AccountStatusChange WHERE AccountId IN
(
SELECT Id FROM ClientCursor.Account WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)

DELETE FROM ClientCursor.ManualAssociation WHERE FromAccountId IN
(
SELECT Id FROM ClientCursor.Account WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)


DELETE FROM ClientCursor.OpportunityDesignation WHERE OpportunityId IN
(
SELECT Id FROM ClientCursor.Opportunity WHERE AccountId IN
(
SELECT Id FROM ClientCursor.Account WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)

------------SELECT * FROM ClientCursor.[OpportunityDoc] ----> No Data in Table

DELETE FROM ClientCursor.OpportunityHistory WHERE OpportunityId IN
(
SELECT Id FROM ClientCursor.Opportunity WHERE AccountId IN
(
SELECT Id FROM ClientCursor.Account WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)

DELETE FROM ClientCursor.OpportunityIncharge WHERE OpportunityId IN
(
SELECT Id FROM ClientCursor.Opportunity WHERE AccountId IN
(
SELECT Id FROM ClientCursor.Account WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)

DELETE FROM ClientCursor.OpportunityStatusChange WHERE OpportunityId IN
(
SELECT Id FROM ClientCursor.Opportunity WHERE AccountId IN
(
SELECT Id FROM ClientCursor.Account WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)

----------SELECT * FROM ClientCursor.OpportunityTermsCondition_ToBeDeleted ---> No Data in Table

DELETE FROM ClientCursor.QuotationDetailTemplate WHERE QuotationDetailId IN
(
SELECT Id FROM ClientCursor.QuotationDetail WHERE OpportunityId IN
(
SELECT Id FROM ClientCursor.Opportunity WHERE AccountId IN
(
SELECT Id FROM ClientCursor.Account WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)

DELETE FROM ClientCursor.QuotationDetail WHERE OpportunityId IN
(
SELECT Id FROM ClientCursor.Opportunity WHERE AccountId IN
(
SELECT Id FROM ClientCursor.Account WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
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
SELECT Id FROM ClientCursor.Account WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
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
SELECT Id FROM ClientCursor.Account WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
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
SELECT Id FROM ClientCursor.Account WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
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
SELECT Id FROM ClientCursor.Account WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
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
SELECT Id FROM ClientCursor.Account WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
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
SELECT Id FROM ClientCursor.Account WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)

DELETE FROM WorkFlow.CaseAmendDateOfCompletion WHERE CaseId IN
(
SELECT Id FROM WorkFlow.CaseGroup WHERE OpportunityId IN
(
SELECT Id FROM ClientCursor.Opportunity WHERE AccountId IN
(
SELECT Id FROM ClientCursor.Account WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)

DELETE FROM WorkFlow.CaseDesignation WHERE CaseId IN
(
SELECT Id FROM WorkFlow.CaseGroup WHERE OpportunityId IN
(
SELECT Id FROM ClientCursor.Opportunity WHERE AccountId IN
(
SELECT Id FROM ClientCursor.Account WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
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
SELECT Id FROM ClientCursor.Account WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
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
SELECT Id FROM ClientCursor.Account WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
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
SELECT Id FROM ClientCursor.Account WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)

DELETE FROM WorkFlow.CaseIncharge WHERE CaseId IN
(
SELECT Id FROM WorkFlow.CaseGroup WHERE OpportunityId IN
(
SELECT Id FROM ClientCursor.Opportunity WHERE AccountId IN
(
SELECT Id FROM ClientCursor.Account WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)

DELETE FROM WorkFlow.CaseMileStone WHERE CaseId IN
(
SELECT Id FROM WorkFlow.CaseGroup WHERE OpportunityId IN
(
SELECT Id FROM ClientCursor.Opportunity WHERE AccountId IN
(
SELECT Id FROM ClientCursor.Account WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
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
SELECT Id FROM ClientCursor.Account WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)

DELETE FROM WorkFlow.Claim WHERE CaseId IN
(
SELECT Id FROM WorkFlow.CaseGroup WHERE OpportunityId IN
(
SELECT Id FROM ClientCursor.Opportunity WHERE AccountId IN
(
SELECT Id FROM ClientCursor.Account WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
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
SELECT Id FROM ClientCursor.Account WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
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
SELECT Id FROM ClientCursor.Account WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
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
SELECT Id FROM ClientCursor.Account WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)

DELETE FROM WorkFlow.InvoiceDesignation WHERE CaseId IN
(
SELECT Id FROM WorkFlow.CaseGroup WHERE OpportunityId IN
(
SELECT Id FROM ClientCursor.Opportunity WHERE AccountId IN
(
SELECT Id FROM ClientCursor.Account WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
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
SELECT Id FROM ClientCursor.Account WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
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
SELECT Id FROM ClientCursor.Account WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
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
SELECT Id FROM ClientCursor.Account WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
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
SELECT Id FROM ClientCursor.Account WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
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
SELECT Id FROM ClientCursor.Account WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
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
SELECT Id FROM ClientCursor.Account WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
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
SELECT Id FROM ClientCursor.Account WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
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
SELECT Id FROM ClientCursor.Account WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
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
SELECT Id FROM ClientCursor.Account WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)

DELETE FROM WorkFlow.ScheduleTaskNew WHERE CaseId IN
(
SELECT Id FROM WorkFlow.CaseGroup WHERE OpportunityId IN
(
SELECT Id FROM ClientCursor.Opportunity WHERE AccountId IN
(
SELECT Id FROM ClientCursor.Account WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)
-----------============ CASEGROUP ==================
DELETE FROM WorkFlow.CaseGroup WHERE OpportunityId IN
(
SELECT Id FROM ClientCursor.Opportunity WHERE AccountId IN
(
SELECT Id FROM ClientCursor.Account WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)

DELETE FROM ClientCursor.Opportunity WHERE AccountId IN
(
SELECT Id FROM ClientCursor.Account WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)

DELETE FROM ClientCursor.QuotationDetailTemplate WHERE QuotationDetailId IN
(
SELECT Id FROM ClientCursor.QuotationDetail WHERE MasterId IN
(
SELECT Id FROM ClientCursor.Quotation WHERE AccountId IN
(
SELECT Id FROM ClientCursor.Account WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)

DELETE FROM ClientCursor.QuotationDetail WHERE MasterId IN
(
SELECT Id FROM ClientCursor.Quotation WHERE AccountId IN
(
SELECT Id FROM ClientCursor.Account WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)

DELETE FROM ClientCursor.QuotationHistory WHERE QuotationId IN
(
SELECT Id FROM ClientCursor.Quotation WHERE AccountId IN
(
SELECT Id FROM ClientCursor.Account WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)

DELETE FROM ClientCursor.QuotationSummaryDetails WHERE QuotationId IN
(
SELECT Id FROM ClientCursor.Quotation WHERE AccountId IN
(
SELECT Id FROM ClientCursor.Account WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)

DELETE FROM ClientCursor.Quotation WHERE AccountId IN
(
SELECT Id FROM ClientCursor.Account WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)

DELETE FROM Common.ReminderBatchList WHERE AccountId IN
(
SELECT Id FROM ClientCursor.Account WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)

DELETE FROM ClientCursor.Account WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)

--------------------//////////////////////////////////////////////////////////////////////// ClientCursor.AccountStatusChange \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

DELETE FROM ClientCursor.AccountStatusChange WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)

--------------------//////////////////////////////////////////////////////////////////////// ClientCursor.Campaign \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

DELETE FROM ClientCursor.CampaignDetail WHERE CampaignId IN
(
SELECT Id FROM ClientCursor.Campaign WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)

DELETE FROM ClientCursor.Campaign WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)

--------------------//////////////////////////////////////////////////////////////////////// ClientCursor.EmployeeRank_ToBeDeleted \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

DELETE FROM ClientCursor.EmployeeRank_ToBeDeleted WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)

--------------------//////////////////////////////////////////////////////////////////////// ClientCursor.EstimatedTimeCostQuestionnaire_ToBeDeleted \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

------------SELECT * FROM ClientCursor.EstimatedTimeCostQuestionnaire_ToBeDeleted WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo) ----> No Data in Table

--------------------//////////////////////////////////////////////////////////////////////// ClientCursor.JobType_ToBeDeleted \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

DELETE FROM ClientCursor.JobHoursLevel_ToBeDeleted WHERE JobTypeId IN
(
SELECT Id FROM ClientCursor.JobType_ToBeDeleted WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)

DELETE FROM ClientCursor.JobRisk_ToBeDeleted WHERE JobTypeId IN
(
SELECT Id FROM ClientCursor.JobType_ToBeDeleted WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)

DELETE FROM ClientCursor.JobType_ToBeDeleted WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)

--------------------//////////////////////////////////////////////////////////////////////// ClientCursor.Opportunity \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

DELETE FROM ClientCursor.OpportunityDesignation WHERE OpportunityId IN
(
SELECT Id FROM ClientCursor.Opportunity WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)

------------SELECT * FROM ClientCursor.[OpportunityDoc] ----> No Data in Table

DELETE FROM ClientCursor.OpportunityHistory WHERE OpportunityId IN
(
SELECT Id FROM ClientCursor.Opportunity WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)

DELETE FROM ClientCursor.OpportunityIncharge WHERE OpportunityId IN
(
SELECT Id FROM ClientCursor.Opportunity WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)

DELETE FROM ClientCursor.OpportunityStatusChange WHERE OpportunityId IN
(
SELECT Id FROM ClientCursor.Opportunity WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)

----------SELECT * FROM ClientCursor.OpportunityTermsCondition_ToBeDeleted ---> No Data in Table

DELETE FROM ClientCursor.QuotationDetailTemplate WHERE QuotationDetailId IN
(
SELECT Id FROM ClientCursor.QuotationDetail WHERE OpportunityId IN
(
SELECT Id FROM ClientCursor.Opportunity WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)

DELETE FROM ClientCursor.QuotationDetail WHERE OpportunityId IN
(
SELECT Id FROM ClientCursor.Opportunity WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)

DELETE FROM Common.TimeLogDetailSplit WHERE TimelogDetailId IN
(
SELECT Id FROM Common.TimeLogDetail WHERE TimeLogScheduleId IN
(
SELECT Id FROM Common.TimeLogSchedule WHERE CaseId IN
(
SELECT Id FROM WorkFlow.CaseGroup WHERE OpportunityId IN
(
SELECT Id FROM ClientCursor.Opportunity WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
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
SELECT Id FROM ClientCursor.Opportunity WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)

DELETE FROM Common.TimeLogSchedule WHERE CaseId IN
(
SELECT Id FROM WorkFlow.CaseGroup WHERE OpportunityId IN
(
SELECT Id FROM ClientCursor.Opportunity WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)

DELETE FROM HR.BankFileDetail WHERE TypeId IN
(
SELECT Id FROM HR.EmployeeClaim1 WHERE CaseGroupId IN
(
SELECT Id FROM WorkFlow.CaseGroup WHERE OpportunityId IN
(
SELECT Id FROM ClientCursor.Opportunity WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)

DELETE FROM HR.EmployeeClaimDetail WHERE EmployeeClaimId IN
(
SELECT Id FROM HR.EmployeeClaim1 WHERE CaseGroupId IN
(
SELECT Id FROM WorkFlow.CaseGroup WHERE OpportunityId IN
(
SELECT Id FROM ClientCursor.Opportunity WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)

DELETE FROM HR.EmployeeClaim1 WHERE CaseGroupId IN
(
SELECT Id FROM WorkFlow.CaseGroup WHERE OpportunityId IN
(
SELECT Id FROM ClientCursor.Opportunity WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)

DELETE FROM WorkFlow.CaseAmendDateOfCompletion WHERE CaseId IN
(
SELECT Id FROM WorkFlow.CaseGroup WHERE OpportunityId IN
(
SELECT Id FROM ClientCursor.Opportunity WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)

DELETE FROM WorkFlow.CaseDesignation WHERE CaseId IN
(
SELECT Id FROM WorkFlow.CaseGroup WHERE OpportunityId IN
(
SELECT Id FROM ClientCursor.Opportunity WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)

------------SELECT * FROM WorkFlow.CaseDoc ----> No Data in Table

DELETE FROM Common.TimeLogDetailSplit WHERE CaseFeatureId IN
(
SELECT Id FROM WorkFlow.CaseFeature WHERE CaseId IN
(
SELECT Id FROM WorkFlow.CaseGroup WHERE OpportunityId IN
(
SELECT Id FROM ClientCursor.Opportunity WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)

DELETE FROM WorkFlow.ScheduleTaskDetail WHERE CaseFeatureId IN
(
SELECT Id FROM WorkFlow.CaseFeature WHERE CaseId IN
(
SELECT Id FROM WorkFlow.CaseGroup WHERE OpportunityId IN
(
SELECT Id FROM ClientCursor.Opportunity WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)

DELETE FROM WorkFlow.CaseFeature WHERE CaseId IN
(
SELECT Id FROM WorkFlow.CaseGroup WHERE OpportunityId IN
(
SELECT Id FROM ClientCursor.Opportunity WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)

DELETE FROM WorkFlow.CaseIncharge WHERE CaseId IN
(
SELECT Id FROM WorkFlow.CaseGroup WHERE OpportunityId IN
(
SELECT Id FROM ClientCursor.Opportunity WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)

DELETE FROM WorkFlow.CaseMileStone WHERE CaseId IN
(
SELECT Id FROM WorkFlow.CaseGroup WHERE OpportunityId IN
(
SELECT Id FROM ClientCursor.Opportunity WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)

-----------SELECT * FROM WorkFlow.CasesAssigned ----> No Data in Table

DELETE FROM WorkFlow.CaseStatusChange WHERE CaseId IN
(
SELECT Id FROM WorkFlow.CaseGroup WHERE OpportunityId IN
(
SELECT Id FROM ClientCursor.Opportunity WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)

DELETE FROM WorkFlow.Claim WHERE CaseId IN
(
SELECT Id FROM WorkFlow.CaseGroup WHERE OpportunityId IN
(
SELECT Id FROM ClientCursor.Opportunity WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)

DELETE FROM WorkFlow.Incidental WHERE InvoiceId IN
(
SELECT Id FROM WorkFlow.Invoice WHERE CaseId IN
(
SELECT Id FROM WorkFlow.CaseGroup WHERE OpportunityId IN
(
SELECT Id FROM ClientCursor.Opportunity WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)

DELETE FROM WorkFlow.InvoiceDesignation WHERE InvoiceId IN
(
SELECT Id FROM WorkFlow.Invoice WHERE CaseId IN
(
SELECT Id FROM WorkFlow.CaseGroup WHERE OpportunityId IN
(
SELECT Id FROM ClientCursor.Opportunity WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)

----------SELECT * FROM WorkFlow.InvoiceState ----> No Data in Table

DELETE FROM WorkFlow.Invoice WHERE CaseId IN
(
SELECT Id FROM WorkFlow.CaseGroup WHERE OpportunityId IN
(
SELECT Id FROM ClientCursor.Opportunity WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)

DELETE FROM WorkFlow.InvoiceDesignation WHERE CaseId IN
(
SELECT Id FROM WorkFlow.CaseGroup WHERE OpportunityId IN
(
SELECT Id FROM ClientCursor.Opportunity WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
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
SELECT Id FROM ClientCursor.Opportunity WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
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
SELECT Id FROM ClientCursor.Opportunity WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
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
SELECT Id FROM ClientCursor.Opportunity WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)

DELETE FROM WorkFlow.Schedule WHERE CaseId IN
(
SELECT Id FROM WorkFlow.CaseGroup WHERE OpportunityId IN
(
SELECT Id FROM ClientCursor.Opportunity WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
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
SELECT Id FROM ClientCursor.Opportunity WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
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
SELECT Id FROM ClientCursor.Opportunity WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)

DELETE FROM WorkFlow.ScheduleNew WHERE CaseId IN
(
SELECT Id FROM WorkFlow.CaseGroup WHERE OpportunityId IN
(
SELECT Id FROM ClientCursor.Opportunity WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)

DELETE FROM WorkFlow.ScheduleTaskDetail WHERE ScheduleTaskId IN
(
SELECT Id FROM WorkFlow.ScheduleTask WHERE CaseId IN
(
SELECT Id FROM WorkFlow.CaseGroup WHERE OpportunityId IN
(
SELECT Id FROM ClientCursor.Opportunity WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)

DELETE FROM WorkFlow.ScheduleTask WHERE CaseId IN
(
SELECT Id FROM WorkFlow.CaseGroup WHERE OpportunityId IN
(
SELECT Id FROM ClientCursor.Opportunity WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)

DELETE FROM WorkFlow.ScheduleTaskNew WHERE CaseId IN
(
SELECT Id FROM WorkFlow.CaseGroup WHERE OpportunityId IN
(
SELECT Id FROM ClientCursor.Opportunity WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)

-----------============ CASEGROUP ==================

DELETE FROM WorkFlow.CaseGroup WHERE OpportunityId IN
(
SELECT Id FROM ClientCursor.Opportunity WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)

DELETE FROM ClientCursor.Opportunity WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)

--------------------//////////////////////////////////////////////////////////////////////// ClientCursor.OpportunityDoc \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

--------SELECT * FROM ClientCursor.OpportunityDoc WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo) ----> No Data in Table

--------------------//////////////////////////////////////////////////////////////////////// ClientCursor.OpportunityHistory \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

DELETE FROM ClientCursor.OpportunityHistory WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)

--------------------//////////////////////////////////////////////////////////////////////// ClientCursor.OpportunityStatusChange \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

DELETE FROM ClientCursor.OpportunityStatusChange WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)

--------------------//////////////////////////////////////////////////////////////////////// ClientCursor.Quotation \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

DELETE FROM ClientCursor.QuotationDetailTemplate WHERE QuotationDetailId IN
(
SELECT Id FROM ClientCursor.QuotationDetail WHERE OpportunityId IN
(
SELECT Id FROM ClientCursor.Quotation WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)

DELETE FROM ClientCursor.QuotationDetail WHERE MasterId IN
(
SELECT Id FROM ClientCursor.Quotation WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)

DELETE FROM ClientCursor.QuotationHistory WHERE QuotationId IN
(
SELECT Id FROM ClientCursor.Quotation WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)

DELETE FROM ClientCursor.QuotationSummaryDetails WHERE QuotationId IN
(
SELECT Id FROM ClientCursor.Quotation WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)

DELETE FROM ClientCursor.Quotation WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)

--------------------//////////////////////////////////////////////////////////////////////// ClientCursor.ReminderMaster \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

DELETE FROM ClientCursor.ReminderDetailTemplate WHERE ReminderDetailId IN
(
SELECT Id FROM ClientCursor.ReminderDetail WHERE ReminderMasterId IN
(
SELECT Id FROM ClientCursor.ReminderMaster WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)

DELETE FROM ClientCursor.ReminderDetail WHERE ReminderMasterId IN
(
SELECT Id FROM ClientCursor.ReminderMaster WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)

DELETE FROM ClientCursor.ReminderMaster WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)

--------------------//////////////////////////////////////////////////////////////////////// ClientCursor.Vendor \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\


DELETE FROM ClientCursor.AccountIncharge WHERE AccountId IN
(
SELECT Id FROM ClientCursor.Account WHERE CompanySecretaryId IN
(
SELECT Id FROM ClientCursor.Vendor WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)

------------SELECT * FROM ClientCursor.AccountNote_ToBeDeleted ----> No Data in Table

DELETE FROM ClientCursor.AccountStatusChange WHERE AccountId IN
(
SELECT Id FROM ClientCursor.Account WHERE CompanySecretaryId IN
(
SELECT Id FROM ClientCursor.Vendor WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)

DELETE FROM ClientCursor.ManualAssociation WHERE FromAccountId IN
(
SELECT Id FROM ClientCursor.Account WHERE CompanySecretaryId IN
(
SELECT Id FROM ClientCursor.Vendor WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)


DELETE FROM ClientCursor.OpportunityDesignation WHERE OpportunityId IN
(
SELECT Id FROM ClientCursor.Opportunity WHERE AccountId IN
(
SELECT Id FROM ClientCursor.Account WHERE CompanySecretaryId IN
(
SELECT Id FROM ClientCursor.Vendor WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
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
SELECT Id FROM ClientCursor.Vendor WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)

DELETE FROM ClientCursor.OpportunityIncharge WHERE OpportunityId IN
(
SELECT Id FROM ClientCursor.Opportunity WHERE AccountId IN
(
SELECT Id FROM ClientCursor.Account WHERE CompanySecretaryId IN
(
SELECT Id FROM ClientCursor.Vendor WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)

DELETE FROM ClientCursor.OpportunityStatusChange WHERE OpportunityId IN
(
SELECT Id FROM ClientCursor.Opportunity WHERE AccountId IN
(
SELECT Id FROM ClientCursor.Account WHERE CompanySecretaryId IN
(
SELECT Id FROM ClientCursor.Vendor WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
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
SELECT Id FROM ClientCursor.Vendor WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
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
SELECT Id FROM ClientCursor.Vendor WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
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
SELECT Id FROM ClientCursor.Vendor WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
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
SELECT Id FROM ClientCursor.Vendor WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
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
SELECT Id FROM ClientCursor.Vendor WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
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
SELECT Id FROM ClientCursor.Vendor WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
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
SELECT Id FROM ClientCursor.Vendor WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
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
SELECT Id FROM ClientCursor.Vendor WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
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
SELECT Id FROM ClientCursor.Vendor WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
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
SELECT Id FROM ClientCursor.Vendor WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
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
SELECT Id FROM ClientCursor.Vendor WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
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
SELECT Id FROM ClientCursor.Vendor WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
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
SELECT Id FROM ClientCursor.Vendor WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
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
SELECT Id FROM ClientCursor.Vendor WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
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
SELECT Id FROM ClientCursor.Vendor WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
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
SELECT Id FROM ClientCursor.Vendor WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
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
SELECT Id FROM ClientCursor.Vendor WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
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
SELECT Id FROM ClientCursor.Vendor WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
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
SELECT Id FROM ClientCursor.Vendor WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
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
SELECT Id FROM ClientCursor.Vendor WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
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
SELECT Id FROM ClientCursor.Vendor WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
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
SELECT Id FROM ClientCursor.Vendor WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
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
SELECT Id FROM ClientCursor.Vendor WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
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
SELECT Id FROM ClientCursor.Vendor WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
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
SELECT Id FROM ClientCursor.Vendor WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
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
SELECT Id FROM ClientCursor.Vendor WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
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
SELECT Id FROM ClientCursor.Vendor WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
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
SELECT Id FROM ClientCursor.Vendor WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
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
SELECT Id FROM ClientCursor.Vendor WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
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
SELECT Id FROM ClientCursor.Vendor WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
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
SELECT Id FROM ClientCursor.Vendor WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
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
SELECT Id FROM ClientCursor.Vendor WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)

DELETE FROM ClientCursor.Opportunity WHERE AccountId IN
(
SELECT Id FROM ClientCursor.Account WHERE CompanySecretaryId IN
(
SELECT Id FROM ClientCursor.Vendor WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
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
SELECT Id FROM ClientCursor.Vendor WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
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
SELECT Id FROM ClientCursor.Vendor WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)

DELETE FROM ClientCursor.QuotationHistory WHERE QuotationId IN
(
SELECT Id FROM ClientCursor.Quotation WHERE AccountId IN
(
SELECT Id FROM ClientCursor.Account WHERE CompanySecretaryId IN
(
SELECT Id FROM ClientCursor.Vendor WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)

DELETE FROM ClientCursor.QuotationSummaryDetails WHERE QuotationId IN
(
SELECT Id FROM ClientCursor.Quotation WHERE AccountId IN
(
SELECT Id FROM ClientCursor.Account WHERE CompanySecretaryId IN
(
SELECT Id FROM ClientCursor.Vendor WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)

DELETE FROM ClientCursor.Quotation WHERE AccountId IN
(
SELECT Id FROM ClientCursor.Account WHERE CompanySecretaryId IN
(
SELECT Id FROM ClientCursor.Vendor WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)

DELETE FROM Common.ReminderBatchList WHERE AccountId IN
(
SELECT Id FROM ClientCursor.Account WHERE CompanySecretaryId IN
(
SELECT Id FROM ClientCursor.Vendor WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)

DELETE FROM ClientCursor.Account WHERE CompanySecretaryId IN
(
SELECT Id FROM ClientCursor.Vendor WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)

DELETE FROM ClientCursor.VendorContact WHERE VendorId IN
(
SELECT Id FROM ClientCursor.Vendor WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)

DELETE FROM ClientCursor.VendorNote WHERE VendorId IN
(
SELECT Id FROM ClientCursor.Vendor WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)

DELETE FROM ClientCursor.VendorService WHERE VendorId IN
(
SELECT Id FROM ClientCursor.Vendor WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)

DELETE FROM ClientCursor.VendorTypeVendor WHERE VendorId IN
(
SELECT Id FROM ClientCursor.Vendor WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)

DELETE FROM ClientCursor.Vendor WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)

END

GO
