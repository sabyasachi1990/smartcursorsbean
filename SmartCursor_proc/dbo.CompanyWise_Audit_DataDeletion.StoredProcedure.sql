USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[CompanyWise_Audit_DataDeletion]    Script Date: 16-12-2024 9.20.10 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   PROCEDURE [dbo].[CompanyWise_Audit_DataDeletion]
@CompanyId Int

AS
BEGIN

DECLARE @CompanyInfo TABLE (Id Int, RegistrationNo Nvarchar(150), Name Nvarchar(500))

INSERT INTO @CompanyInfo
SELECT Id,RegistrationNo,Name FROM Common.Company WHERE Id = @CompanyId
UNION ALL
SELECT Id,RegistrationNo,Name FROM Common.Company WHERE ParentId = @CompanyId

----------------------==================================================================================================================================================================================================
----------------------/////////////////////////////////////////////////////////////////////////////// AUDIT \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
-----------------------==================================================================================================================================================================================================

--------------------//////////////////////////////////////////////////////////////////////// Audit.AccountPolicy \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
----------------------====== Audit.AccountPolicy =========

DELETE FROM Audit.AccountPolicyDetail WHERE MasterId IN (SELECT Id FROM Audit.AccountPolicy WHERE CompanyId IN (SELECT Id FROM @CompanyInfo))
DELETE FROM Audit.AccountPolicy WHERE CompanyId IN (SELECT Id FROM @CompanyInfo)

------------------------//////////////////////////////////////////////////////////////////////// Audit.AuditCompany \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

----------------------================= Audit.AuditCompanyContact ===============

DELETE FROM Audit.ClientAndEngagementIndependenceConfirmation WHERE
AuditCompanyContactId IN (SELECT Id FROM Audit.AuditCompanyContact WHERE AuditCompanyId IN (SELECT Id FROM Audit.AuditCompany WHERE CompanyId IN (SELECT Id FROM @CompanyInfo)))

DELETE FROM Audit.DeclarationOfDirectors WHERE 
AuditCompanyContactId IN (SELECT Id FROM Audit.AuditCompanyContact WHERE AuditCompanyId IN (SELECT Id FROM Audit.AuditCompany WHERE CompanyId IN (SELECT Id FROM @CompanyInfo)))

DELETE FROM Audit.DirectorRemunerationDetails WHERE 
DirectorRemunerationId IN (SELECT Id FROM Audit.DirectorRemuneration WHERE 
AuditCompanyContactId IN (SELECT Id FROM Audit.AuditCompanyContact WHERE AuditCompanyId IN (SELECT Id FROM Audit.AuditCompany WHERE CompanyId IN (SELECT Id FROM @CompanyInfo))))

DELETE FROM Audit.DirectorRemuneration WHERE 
AuditCompanyContactId IN (SELECT Id FROM Audit.AuditCompanyContact WHERE AuditCompanyId IN (SELECT Id FROM Audit.AuditCompany WHERE CompanyId IN (SELECT Id FROM @CompanyInfo)))

DELETE FROM Audit.AuditCompanyContact WHERE AuditCompanyId IN (SELECT Id FROM Audit.AuditCompany WHERE CompanyId IN (SELECT Id FROM @CompanyInfo))

--------------------================= Audit.AuditCompanyEngagement ===============


DELETE FROM Audit.NoteAdjustment WHERE AdjustmentId IN (SELECT Id FROM Audit.Adjustment WHERE EngagementID IN (SELECT Id FROM Audit.AuditCompanyEngagement WHERE AuditCompanyId IN (SELECT Id FROM Audit.AuditCompany WHERE CompanyId IN (SELECT Id FROM @CompanyInfo))))


--------------------DELETE FROM Audit.AdjustmentComment_ToBeDeleted WHERE AdjustmentID IN ---> No data in Table
--------------------(SELECT ID FROM Audit.Adjustment WHERE EngagementID IN (SELECT Id FROM Audit.AuditCompanyEngagement WHERE AuditCompanyId IN (SELECT Id FROM Audit.AuditCompany WHERE CompanyId IN (SELECT Id FROM @CompanyInfo))))

--------------------DELETE FROM Audit.AdjustmentAccountLeadsheet_ToBeDeleted ---> No data in Table

DELETE FROM Audit.AdjustmentAccount WHERE AdjustmentID IN
(SELECT Id FROM Audit.Adjustment WHERE EngagementID IN (SELECT Id FROM Audit.AuditCompanyEngagement WHERE AuditCompanyId IN (SELECT Id FROM Audit.AuditCompany WHERE CompanyId IN (SELECT Id FROM @CompanyInfo))))

--------------------SELECT * FROM [Audit].[AdjustmentFileAttachment_ToBeDeleted] --- Table not present in DB 

DELETE FROM Audit.Adjustment WHERE EngagementID IN (SELECT Id FROM Audit.AuditCompanyEngagement WHERE AuditCompanyId IN (SELECT Id FROM Audit.AuditCompany WHERE CompanyId IN (SELECT Id FROM @CompanyInfo)))

------------DELETE FROM Audit.AdjustmentDOCRepository_ToBeDeleted WHERE EngagementID IN ------> No Data In Table
------------(SELECT Id FROM Audit.AuditCompanyEngagement WHERE AuditCompanyId IN (SELECT Id FROM Audit.AuditCompany WHERE CompanyId IN (SELECT Id FROM @CompanyInfo)))

DELETE FROM Audit.AuditCompanyEngagementDetails WHERE AuditCompanyEngagementId IN
(SELECT Id FROM Audit.AuditCompanyEngagement WHERE AuditCompanyId IN (SELECT Id FROM Audit.AuditCompany WHERE CompanyId IN (SELECT Id FROM @CompanyInfo)))

DELETE FROM Audit.AuditMenuHelpLinks WHERE AuditCompanyMenuMasterId IN 
(
SELECT Id FROM Audit.AuditCompanyMenuMaster WHERE EngagementId IN 
(SELECT Id FROM Audit.AuditCompanyEngagement WHERE AuditCompanyId IN (SELECT Id FROM Audit.AuditCompany WHERE CompanyId IN (SELECT Id FROM @CompanyInfo)))
)

DELETE FROM Audit.AuditMenuPermissions WHERE AuditCompanyMenuMasterId IN 
(
SELECT Id FROM Audit.AuditCompanyMenuMaster WHERE EngagementId IN 
(SELECT Id FROM Audit.AuditCompanyEngagement WHERE AuditCompanyId IN (SELECT Id FROM Audit.AuditCompany WHERE CompanyId IN (SELECT Id FROM @CompanyInfo)))
)

DELETE FROM Audit.AuditCompanyMenuMaster WHERE EngagementId IN 
(SELECT Id FROM Audit.AuditCompanyEngagement WHERE AuditCompanyId IN (SELECT Id FROM Audit.AuditCompany WHERE CompanyId IN (SELECT Id FROM @CompanyInfo)))

--------------------------DELETE FROM Audit.AuditMenu_ToBeDeleted WHERE EngagementId IN ---> No Data in Table
--------------------------(SELECT Id FROM Audit.AuditCompanyEngagement WHERE AuditCompanyId IN (SELECT Id FROM Audit.AuditCompany WHERE CompanyId IN (SELECT Id FROM @CompanyInfo)))

--------------------------DELETE FROM Audit.CashFlowDetail_ToBeDeleted WHERE CashFlowItemId IN ---> No Data in Table
--------------------------(
--------------------------SELECT Id FROM Audit.CashFlowItem WHERE CashFlowId IN
--------------------------(
--------------------------SELECT Id FROM Audit.CashFlow WHERE EngagementId IN
--------------------------(SELECT Id FROM Audit.AuditCompanyEngagement WHERE AuditCompanyId IN (SELECT Id FROM Audit.AuditCompany WHERE CompanyId IN (SELECT Id FROM @CompanyInfo)))
--------------------------)
--------------------------)

DELETE FROM Audit.CashFlowItemDetail WHERE CashFlowItemId IN 
(
SELECT Id FROM Audit.CashFlowItem WHERE CashFlowId IN
(
SELECT Id FROM Audit.CashFlow WHERE EngagementId IN
(SELECT Id FROM Audit.AuditCompanyEngagement WHERE AuditCompanyId IN (SELECT Id FROM Audit.AuditCompany WHERE CompanyId IN (SELECT Id FROM @CompanyInfo)))
)
)

DELETE FROM Audit.CashFlowItem WHERE CashFlowId IN
(
SELECT Id FROM Audit.CashFlow WHERE EngagementId IN
(SELECT Id FROM Audit.AuditCompanyEngagement WHERE AuditCompanyId IN (SELECT Id FROM Audit.AuditCompany WHERE CompanyId IN (SELECT Id FROM @CompanyInfo)))
)

DELETE FROM Audit.CashFlow WHERE EngagementId IN
(SELECT Id FROM Audit.AuditCompanyEngagement WHERE AuditCompanyId IN (SELECT Id FROM Audit.AuditCompany WHERE CompanyId IN (SELECT Id FROM @CompanyInfo)))

DELETE FROM Audit.CashFlowDetail_ToBeDeleted WHERE CashFlowHeadingId IN
(
SELECT Id FROM Audit.CashFlowHeadings_ToBeDeleted WHERE EngagementId IN 
(SELECT Id FROM Audit.AuditCompanyEngagement WHERE AuditCompanyId IN (SELECT Id FROM Audit.AuditCompany WHERE CompanyId IN (SELECT Id FROM @CompanyInfo)))
)

DELETE FROM Audit.CashFlowHeadings_ToBeDeleted WHERE EngagementId IN 
(SELECT Id FROM Audit.AuditCompanyEngagement WHERE AuditCompanyId IN (SELECT Id FROM Audit.AuditCompany WHERE CompanyId IN (SELECT Id FROM @CompanyInfo)))

DELETE FROM Audit.ChangesInEquity WHERE EngagementId IN 
(SELECT Id FROM Audit.AuditCompanyEngagement WHERE AuditCompanyId IN (SELECT Id FROM Audit.AuditCompany WHERE CompanyId IN (SELECT Id FROM @CompanyInfo)))

DELETE FROM Audit.ClientAndEngagementIndependenceConfirmation WHERE EngagementId IN 
(SELECT Id FROM Audit.AuditCompanyEngagement WHERE AuditCompanyId IN (SELECT Id FROM Audit.AuditCompany WHERE CompanyId IN (SELECT Id FROM @CompanyInfo)))

DELETE FROM Audit.DeclarationOfDirectors WHERE EngagementId IN 
(SELECT Id FROM Audit.AuditCompanyEngagement WHERE AuditCompanyId IN (SELECT Id FROM Audit.AuditCompany WHERE CompanyId IN (SELECT Id FROM @CompanyInfo)))

DELETE FROM Audit.DirectorRemunerationDetails WHERE DirectorRemunerationId IN
(
SELECT Id FROM Audit.DirectorRemuneration WHERE EngagementId IN 
(SELECT Id FROM Audit.AuditCompanyEngagement WHERE AuditCompanyId IN (SELECT Id FROM Audit.AuditCompany WHERE CompanyId IN (SELECT Id FROM @CompanyInfo)))
)

DELETE FROM Audit.DirectorRemuneration WHERE EngagementId IN 
(SELECT Id FROM Audit.AuditCompanyEngagement WHERE AuditCompanyId IN (SELECT Id FROM Audit.AuditCompany WHERE CompanyId IN (SELECT Id FROM @CompanyInfo)))

DELETE FROM Audit.EngagementPercentage WHERE EngagementId IN (SELECT Id FROM Audit.AuditCompanyEngagement WHERE AuditCompanyId IN (SELECT Id FROM Audit.AuditCompany WHERE CompanyId IN (SELECT Id FROM @CompanyInfo)))

DELETE FROM Audit.EngagementVisitedHistory WHERE EngagementId IN (SELECT Id FROM Audit.AuditCompanyEngagement WHERE AuditCompanyId IN (SELECT Id FROM Audit.AuditCompany WHERE CompanyId IN (SELECT Id FROM @CompanyInfo)))

DELETE FROM Audit.Equity WHERE EngagementId IN (SELECT Id FROM Audit.AuditCompanyEngagement WHERE AuditCompanyId IN (SELECT Id FROM Audit.AuditCompany WHERE CompanyId IN (SELECT Id FROM @CompanyInfo)))

DELETE FROM Audit.FEAnalysisCurrencyDetails WHERE CuntryCurrencyID IN 
(
SELECT ID FROM Audit.FEAnalysisCountryCurrency WHERE FEAnalysisID IN 
(
SELECT Id FROM Audit.FEAnalysis WHERE ForeignExchangeID IN 
(SELECT ID FROM Audit.ForeignExchange WHERE EngagementId IN (SELECT Id FROM Audit.AuditCompanyEngagement WHERE AuditCompanyId IN (SELECT Id FROM Audit.AuditCompany WHERE CompanyId IN (SELECT Id FROM @CompanyInfo))))
)
)

DELETE FROM Audit.FEAnalysisCountryCurrency WHERE FEAnalysisID IN 
(
SELECT Id FROM Audit.FEAnalysis WHERE ForeignExchangeID IN 
(SELECT ID FROM Audit.ForeignExchange WHERE EngagementId IN (SELECT Id FROM Audit.AuditCompanyEngagement WHERE AuditCompanyId IN (SELECT Id FROM Audit.AuditCompany WHERE CompanyId IN (SELECT Id FROM @CompanyInfo))))
)

--------------------------DELETE FROM Audit.FEAnalysisLegend WHERE FEAnalysisID IN ---> No Data in Table
--------------------------(
--------------------------SELECT Id FROM Audit.FEAnalysis WHERE ForeignExchangeID IN 
--------------------------(SELECT Id FROM Audit.ForeignExchange WHERE EngagementId IN (SELECT Id FROM Audit.AuditCompanyEngagement WHERE AuditCompanyId IN (SELECT Id FROM Audit.AuditCompany WHERE CompanyId IN (SELECT Id FROM @CompanyInfo))))
--------------------------)

DELETE FROM Audit.FEAnalysisNote WHERE FEAnalysisID IN
(
SELECT ID FROM Audit.FEAnalysis WHERE ForeignExchangeID IN 
(SELECT Id FROM Audit.ForeignExchange WHERE EngagementId IN (SELECT Id FROM Audit.AuditCompanyEngagement WHERE AuditCompanyId IN (SELECT Id FROM Audit.AuditCompany WHERE CompanyId IN (SELECT Id FROM @CompanyInfo))))
)

DELETE FROM Audit.FEAnalysis WHERE ForeignExchangeID IN 
(SELECT Id FROM Audit.ForeignExchange WHERE EngagementId IN (SELECT Id FROM Audit.AuditCompanyEngagement WHERE AuditCompanyId IN (SELECT Id FROM Audit.AuditCompany WHERE CompanyId IN (SELECT Id FROM @CompanyInfo))))

DELETE FROM Audit.ForeignCurrencyAnalysisFactors WHERE FCAnalysisID IN
(
SELECT ID FROM Audit.ForeignCurrencyAnalysis WHERE ForeignExchangeID IN 
(SELECT ID FROM Audit.ForeignExchange WHERE EngagementId IN (SELECT Id FROM Audit.AuditCompanyEngagement WHERE AuditCompanyId IN (SELECT Id FROM Audit.AuditCompany WHERE CompanyId IN (SELECT Id FROM @CompanyInfo))))
)

DELETE FROM Audit.ForeignCurrencyAnalysis WHERE ForeignExchangeID IN 
(SELECT ID FROM Audit.ForeignExchange WHERE EngagementId IN (SELECT Id FROM Audit.AuditCompanyEngagement WHERE AuditCompanyId IN (SELECT Id FROM Audit.AuditCompany WHERE CompanyId IN (SELECT Id FROM @CompanyInfo))))

DELETE FROM Audit.ForeignExchange WHERE EngagementId IN (SELECT Id FROM Audit.AuditCompanyEngagement WHERE AuditCompanyId IN (SELECT Id FROM Audit.AuditCompany WHERE CompanyId IN (SELECT Id FROM @CompanyInfo)))

DELETE FROM Audit.FormDetail WHERE FormMasterId IN
(
SELECT Id FROM Audit.FormMaster WHERE EngagementId IN 
(SELECT Id FROM Audit.AuditCompanyEngagement WHERE AuditCompanyId IN (SELECT Id FROM Audit.AuditCompany WHERE CompanyId IN (SELECT Id FROM @CompanyInfo)))
)

DELETE FROM Audit.FormMaster WHERE EngagementId IN 
(SELECT Id FROM Audit.AuditCompanyEngagement WHERE AuditCompanyId IN (SELECT Id FROM Audit.AuditCompany WHERE CompanyId IN (SELECT Id FROM @CompanyInfo)))

--------------------------DELETE FROM Audit.GeneralLedgerFileDetails_ToBeDeleted WHERE EngagementId IN ---> No Data in Table
--------------------------(SELECT Id FROM Audit.AuditCompanyEngagement WHERE AuditCompanyId IN (SELECT Id FROM Audit.AuditCompany WHERE CompanyId IN (SELECT Id FROM @CompanyInfo)))

DELETE FROM Audit.GeneralLedgerDetail WHERE GeneralLedgerId IN
(
SELECT Id FROM Audit.GeneralLedgerImport WHERE EngagementId IN 
(SELECT Id FROM Audit.AuditCompanyEngagement WHERE AuditCompanyId IN (SELECT Id FROM Audit.AuditCompany WHERE CompanyId IN (SELECT Id FROM @CompanyInfo)))
)

DELETE FROM Audit.GeneralLedgerImport WHERE EngagementId IN 
(SELECT Id FROM Audit.AuditCompanyEngagement WHERE AuditCompanyId IN (SELECT Id FROM Audit.AuditCompany WHERE CompanyId IN (SELECT Id FROM @CompanyInfo)))

--------------------------DELETE FROM Audit.CashFlowDetail_ToBeDeleted WHERE LeadSheetId IN ---> No Data in Table
--------------------------(
--------------------------SELECT Id FROM Audit.LeadSheet WHERE EngagementId IN 
--------------------------(SELECT Id FROM Audit.AuditCompanyEngagement WHERE AuditCompanyId IN (SELECT Id FROM Audit.AuditCompany WHERE CompanyId IN (SELECT Id FROM @CompanyInfo)))
--------------------------)

DELETE FROM Audit.CashFlowItemDetail WHERE LeadSheetId IN
(
SELECT Id FROM Audit.LeadSheet WHERE EngagementId IN 
(SELECT Id FROM Audit.AuditCompanyEngagement WHERE AuditCompanyId IN (SELECT Id FROM Audit.AuditCompany WHERE CompanyId IN (SELECT Id FROM @CompanyInfo)))
)

DELETE FROM Audit.Equity WHERE LeadSheetId IN
(
SELECT Id FROM Audit.LeadSheet WHERE EngagementId IN 
(SELECT Id FROM Audit.AuditCompanyEngagement WHERE AuditCompanyId IN (SELECT Id FROM Audit.AuditCompany WHERE CompanyId IN (SELECT Id FROM @CompanyInfo)))
)

DELETE FROM Audit.LeadSheetCategories WHERE LeadsheetId IN
(
SELECT Id FROM Audit.LeadSheet WHERE EngagementId IN 
(SELECT Id FROM Audit.AuditCompanyEngagement WHERE AuditCompanyId IN (SELECT Id FROM Audit.AuditCompany WHERE CompanyId IN (SELECT Id FROM @CompanyInfo)))
)

DELETE FROM Audit.PlanningMaterialityDetailLeadSheet WHERE LeadSheetId IN
(
SELECT Id FROM Audit.LeadSheet WHERE EngagementId IN 
(SELECT Id FROM Audit.AuditCompanyEngagement WHERE AuditCompanyId IN (SELECT Id FROM Audit.AuditCompany WHERE CompanyId IN (SELECT Id FROM @CompanyInfo)))
)

DELETE FROM Audit.PlanningMaterialityLeadSheet WHERE LeadSheetId IN 
(
SELECT Id FROM Audit.LeadSheet WHERE EngagementId IN 
(SELECT Id FROM Audit.AuditCompanyEngagement WHERE AuditCompanyId IN (SELECT Id FROM Audit.AuditCompany WHERE CompanyId IN (SELECT Id FROM @CompanyInfo)))
)

DELETE FROM Audit.LeadSheet WHERE EngagementId IN 
(SELECT Id FROM Audit.AuditCompanyEngagement WHERE AuditCompanyId IN (SELECT Id FROM Audit.AuditCompany WHERE CompanyId IN (SELECT Id FROM @CompanyInfo)))

DELETE FROM Audit.ClientAndEngagementIndependenceConfirmation WHERE PlanningAndCompletionSetUpId IN
(
SELECT Id FROM Audit.PlanningAndCompletionSetUp WHERE EngagementId IN (SELECT Id FROM Audit.AuditCompanyEngagement WHERE AuditCompanyId IN (SELECT Id FROM Audit.AuditCompany WHERE CompanyId IN (SELECT Id FROM @CompanyInfo)))
)

DELETE FROM Audit.DeclarationOfDirectors WHERE PlanningAndCompletionSetUpId IN 
(
SELECT Id FROM Audit.PlanningAndCompletionSetUp WHERE EngagementId IN (SELECT Id FROM Audit.AuditCompanyEngagement WHERE AuditCompanyId IN (SELECT Id FROM Audit.AuditCompany WHERE CompanyId IN (SELECT Id FROM @CompanyInfo)))
)

DELETE FROM Audit.DirectorRemunerationDetails WHERE DirectorRemunerationId IN
(
SELECT Id FROM Audit.DirectorRemuneration WHERE PlanningAndCompletionSetUpId IN 
(
SELECT Id FROM Audit.PlanningAndCompletionSetUp WHERE EngagementId IN (SELECT Id FROM Audit.AuditCompanyEngagement WHERE AuditCompanyId IN (SELECT Id FROM Audit.AuditCompany WHERE CompanyId IN (SELECT Id FROM @CompanyInfo)))
)
)

DELETE FROM Audit.DirectorRemuneration WHERE PlanningAndCompletionSetUpId IN 
(
SELECT Id FROM Audit.PlanningAndCompletionSetUp WHERE EngagementId IN (SELECT Id FROM Audit.AuditCompanyEngagement WHERE AuditCompanyId IN (SELECT Id FROM Audit.AuditCompany WHERE CompanyId IN (SELECT Id FROM @CompanyInfo)))
)

DELETE FROM Audit.PAndCSectionQuestions WHERE PAndCSectionId IN 
(
SELECT Id FROM Audit.PAndCSections WHERE PlanningAndCompletionSetUpId IN 
(
SELECT Id FROM Audit.PlanningAndCompletionSetUp WHERE EngagementId IN (SELECT Id FROM Audit.AuditCompanyEngagement WHERE AuditCompanyId IN (SELECT Id FROM Audit.AuditCompany WHERE CompanyId IN (SELECT Id FROM @CompanyInfo)))
)
)

DELETE FROM Audit.PAndCSections WHERE PlanningAndCompletionSetUpId IN 
(
SELECT Id FROM Audit.PlanningAndCompletionSetUp WHERE EngagementId IN (SELECT Id FROM Audit.AuditCompanyEngagement WHERE AuditCompanyId IN (SELECT Id FROM Audit.AuditCompany WHERE CompanyId IN (SELECT Id FROM @CompanyInfo)))
)

DELETE FROM Audit.PlanningAndCompletionSetUp WHERE EngagementId IN (SELECT Id FROM Audit.AuditCompanyEngagement WHERE AuditCompanyId IN (SELECT Id FROM Audit.AuditCompany WHERE CompanyId IN (SELECT Id FROM @CompanyInfo)))

DELETE FROM Audit.PlanningMaterialityDetailLeadSheet WHERE PlanningMaterialityDetailId IN
(
SELECT Id FROM Audit.PlanningMaterialityDetail WHERE PlanningMeterialityId IN
(
SELECT Id FROM Audit.PlanningMateriality WHERE EngagementId IN 
(SELECT Id FROM Audit.AuditCompanyEngagement WHERE AuditCompanyId IN (SELECT Id FROM Audit.AuditCompany WHERE CompanyId IN (SELECT Id FROM @CompanyInfo)))
)
)

DELETE FROM Audit.PlanningMaterialityDetail WHERE PlanningMeterialityId IN
(
SELECT Id FROM Audit.PlanningMateriality WHERE EngagementId IN 
(SELECT Id FROM Audit.AuditCompanyEngagement WHERE AuditCompanyId IN (SELECT Id FROM Audit.AuditCompany WHERE CompanyId IN (SELECT Id FROM @CompanyInfo)))
)

DELETE FROM Audit.PlanningMateriality WHERE EngagementId IN 
(SELECT Id FROM Audit.AuditCompanyEngagement WHERE AuditCompanyId IN (SELECT Id FROM Audit.AuditCompany WHERE CompanyId IN (SELECT Id FROM @CompanyInfo)))

DELETE FROM Audit.PlanningMaterialityDetailLeadSheet WHERE AuditCompanyEngagementId IN 
(SELECT Id FROM Audit.AuditCompanyEngagement WHERE AuditCompanyId IN (SELECT Id FROM Audit.AuditCompany WHERE CompanyId IN (SELECT Id FROM @CompanyInfo)))

DELETE FROM Audit.PlanningMaterialityDetailLeadSheet WHERE PlanningMaterialityDetailId IN 
(
SELECT Id FROM Audit.PlanningMaterialityDetail WHERE PlanningMeterialityId IN
(
SELECT Id FROM Audit.PlanningMateriality WHERE PlanningMaterialitySetupId IN 
(
SELECT Id FROM Audit.PlanningMaterialitySetup WHERE EngagementId IN 
(SELECT Id FROM Audit.AuditCompanyEngagement WHERE AuditCompanyId IN (SELECT Id FROM Audit.AuditCompany WHERE CompanyId IN (SELECT Id FROM @CompanyInfo)))
)
)
)

DELETE FROM Audit.PlanningMaterialityDetail WHERE PlanningMeterialityId IN
(
SELECT Id FROM Audit.PlanningMateriality WHERE PlanningMaterialitySetupId IN 
(
SELECT Id FROM Audit.PlanningMaterialitySetup WHERE EngagementId IN 
(SELECT Id FROM Audit.AuditCompanyEngagement WHERE AuditCompanyId IN (SELECT Id FROM Audit.AuditCompany WHERE CompanyId IN (SELECT Id FROM @CompanyInfo)))
)
)

DELETE FROM Audit.PlanningMateriality WHERE PlanningMaterialitySetupId IN 
(
SELECT Id FROM Audit.PlanningMaterialitySetup WHERE EngagementId IN 
(SELECT Id FROM Audit.AuditCompanyEngagement WHERE AuditCompanyId IN (SELECT Id FROM Audit.AuditCompany WHERE CompanyId IN (SELECT Id FROM @CompanyInfo)))
)

DELETE FROM Audit.PlanningMaterialityLeadSheet WHERE PlanningMaterialitySetupDetailId IN
(
SELECT Id FROM Audit.PlanningMaterialitySetupDetail WHERE PlanningMaterialitySetupId IN 
(
SELECT Id FROM Audit.PlanningMaterialitySetup WHERE EngagementId IN 
(SELECT Id FROM Audit.AuditCompanyEngagement WHERE AuditCompanyId IN (SELECT Id FROM Audit.AuditCompany WHERE CompanyId IN (SELECT Id FROM @CompanyInfo)))
)
)

DELETE FROM Audit.PlanningMaterialitySetupDetail WHERE PlanningMaterialitySetupId IN 
(
SELECT Id FROM Audit.PlanningMaterialitySetup WHERE EngagementId IN 
(SELECT Id FROM Audit.AuditCompanyEngagement WHERE AuditCompanyId IN (SELECT Id FROM Audit.AuditCompany WHERE CompanyId IN (SELECT Id FROM @CompanyInfo)))
)

DELETE FROM Audit.PlanningMaterialitySetup WHERE EngagementId IN 
(SELECT Id FROM Audit.AuditCompanyEngagement WHERE AuditCompanyId IN (SELECT Id FROM Audit.AuditCompany WHERE CompanyId IN (SELECT Id FROM @CompanyInfo)))

DELETE FROM Audit.Questionnaire_ToBeDeleted WHERE AuditCompanyEngagementId IN
(SELECT Id FROM Audit.AuditCompanyEngagement WHERE AuditCompanyId IN (SELECT Id FROM Audit.AuditCompany WHERE CompanyId IN (SELECT Id FROM @CompanyInfo)))

DELETE FROM Audit.ReportingTemplates WHERE EngagementId IN
(SELECT Id FROM Audit.AuditCompanyEngagement WHERE AuditCompanyId IN (SELECT Id FROM Audit.AuditCompany WHERE CompanyId IN (SELECT Id FROM @CompanyInfo)))

DELETE FROM Audit.Roles WHERE EngagementId IN 
(SELECT Id FROM Audit.AuditCompanyEngagement WHERE AuditCompanyId IN (SELECT Id FROM Audit.AuditCompany WHERE CompanyId IN (SELECT Id FROM @CompanyInfo)))

DELETE FROM Audit.SamplingDetail WHERE SamplingId IN 
(
SELECT Id FROM Audit.Sampling WHERE EngagementId IN 
(SELECT Id FROM Audit.AuditCompanyEngagement WHERE AuditCompanyId IN (SELECT Id FROM Audit.AuditCompany WHERE CompanyId IN (SELECT Id FROM @CompanyInfo)))
)

DELETE FROM Audit.Sampling WHERE EngagementId IN 
(SELECT Id FROM Audit.AuditCompanyEngagement WHERE AuditCompanyId IN (SELECT Id FROM Audit.AuditCompany WHERE CompanyId IN (SELECT Id FROM @CompanyInfo)))

DELETE FROM Audit.SamplingDetail WHERE EngagementId IN 
(SELECT Id FROM Audit.AuditCompanyEngagement WHERE AuditCompanyId IN (SELECT Id FROM Audit.AuditCompany WHERE CompanyId IN (SELECT Id FROM @CompanyInfo)))

DELETE FROM Audit.TemplateVariable WHERE EngagementId IN 
(SELECT Id FROM Audit.AuditCompanyEngagement WHERE AuditCompanyId IN (SELECT Id FROM Audit.AuditCompany WHERE CompanyId IN (SELECT Id FROM @CompanyInfo)))

DELETE FROM Audit.FEAnalysisLegend WHERE TickMarkId IN
(
SELECT Id FROM Audit.TickMarkSetup WHERE EngagementId IN
(SELECT Id FROM Audit.AuditCompanyEngagement WHERE AuditCompanyId IN (SELECT Id FROM Audit.AuditCompany WHERE CompanyId IN (SELECT Id FROM @CompanyInfo)))
)

--------------------------DELETE FROM Audit.TrialBalanceTickmark_ToBeDeleted WHERE TickMarkId IN ---> No Data in table
--------------------------(
--------------------------SELECT Id FROM Audit.TickMarkSetup WHERE EngagementId IN
--------------------------(SELECT Id FROM Audit.AuditCompanyEngagement WHERE AuditCompanyId IN (SELECT Id FROM Audit.AuditCompany WHERE CompanyId IN (SELECT Id FROM @CompanyInfo)))
--------------------------)

DELETE Audit.WPSetupTickmark WHERE TickMarkId IN
(
SELECT Id FROM Audit.TickMarkSetup WHERE EngagementId IN
(SELECT Id FROM Audit.AuditCompanyEngagement WHERE AuditCompanyId IN (SELECT Id FROM Audit.AuditCompany WHERE CompanyId IN (SELECT Id FROM @CompanyInfo)))
)

DELETE FROM Audit.TickMarkSetup WHERE EngagementId IN
(SELECT Id FROM Audit.AuditCompanyEngagement WHERE AuditCompanyId IN (SELECT Id FROM Audit.AuditCompany WHERE CompanyId IN (SELECT Id FROM @CompanyInfo)))

DELETE FROM Audit.TrialBalanceAuditTrail WHERE EngagementID IN 
(SELECT Id FROM Audit.AuditCompanyEngagement WHERE AuditCompanyId IN (SELECT Id FROM Audit.AuditCompany WHERE CompanyId IN (SELECT Id FROM @CompanyInfo)))

DELETE FROM Audit.TrialBalanceFileDetails WHERE EngagementId IN
(SELECT Id FROM Audit.AuditCompanyEngagement WHERE AuditCompanyId IN (SELECT Id FROM Audit.AuditCompany WHERE CompanyId IN (SELECT Id FROM @CompanyInfo)))

DELETE FROM Audit.TrialBalanceImport WHERE EngagementId IN 
(SELECT Id FROM Audit.AuditCompanyEngagement WHERE AuditCompanyId IN (SELECT Id FROM Audit.AuditCompany WHERE CompanyId IN (SELECT Id FROM @CompanyInfo)))

DELETE FROM Audit.UserApproval WHERE EngagementId IN
(SELECT Id FROM Audit.AuditCompanyEngagement WHERE AuditCompanyId IN (SELECT Id FROM Audit.AuditCompany WHERE CompanyId IN (SELECT Id FROM @CompanyInfo)))

DELETE FROM Audit.CashFlowDetail_ToBeDeleted WHERE LeadSheetId IN
(
SELECT Id FROM Audit.LeadSheet WHERE WorkProgramId IN
(
SELECT Id FROM Audit.WPSetup WHERE EngagementId IN
(SELECT Id FROM Audit.AuditCompanyEngagement WHERE AuditCompanyId IN (SELECT Id FROM Audit.AuditCompany WHERE CompanyId IN (SELECT Id FROM @CompanyInfo)))
)
)

DELETE FROM Audit.CashFlowItemDetail WHERE LeadSheetId IN
(
SELECT Id FROM Audit.LeadSheet WHERE WorkProgramId IN
(
SELECT Id FROM Audit.WPSetup WHERE EngagementId IN
(SELECT Id FROM Audit.AuditCompanyEngagement WHERE AuditCompanyId IN (SELECT Id FROM Audit.AuditCompany WHERE CompanyId IN (SELECT Id FROM @CompanyInfo)))
)
)

DELETE FROM Audit.Equity WHERE LeadSheetId IN
(
SELECT Id FROM Audit.LeadSheet WHERE WorkProgramId IN
(
SELECT Id FROM Audit.WPSetup WHERE EngagementId IN
(SELECT Id FROM Audit.AuditCompanyEngagement WHERE AuditCompanyId IN (SELECT Id FROM Audit.AuditCompany WHERE CompanyId IN (SELECT Id FROM @CompanyInfo)))
)
)

DELETE FROM Audit.LeadSheetCategories WHERE LeadsheetId IN
(
SELECT Id FROM Audit.LeadSheet WHERE WorkProgramId IN
(
SELECT Id FROM Audit.WPSetup WHERE EngagementId IN
(SELECT Id FROM Audit.AuditCompanyEngagement WHERE AuditCompanyId IN (SELECT Id FROM Audit.AuditCompany WHERE CompanyId IN (SELECT Id FROM @CompanyInfo)))
)
)

DELETE FROM Audit.PlanningMaterialityDetailLeadSheet WHERE LeadsheetId IN
(
SELECT Id FROM Audit.LeadSheet WHERE WorkProgramId IN
(
SELECT Id FROM Audit.WPSetup WHERE EngagementId IN
(SELECT Id FROM Audit.AuditCompanyEngagement WHERE AuditCompanyId IN (SELECT Id FROM Audit.AuditCompany WHERE CompanyId IN (SELECT Id FROM @CompanyInfo)))
)
)

DELETE FROM Audit.PlanningMaterialityLeadSheet WHERE LeadsheetId IN
(
SELECT Id FROM Audit.LeadSheet WHERE WorkProgramId IN
(
SELECT Id FROM Audit.WPSetup WHERE EngagementId IN
(SELECT Id FROM Audit.AuditCompanyEngagement WHERE AuditCompanyId IN (SELECT Id FROM Audit.AuditCompany WHERE CompanyId IN (SELECT Id FROM @CompanyInfo)))
)
)

DELETE FROM Audit.LeadSheet WHERE WorkProgramId IN
(
SELECT Id FROM Audit.WPSetup WHERE EngagementId IN
(SELECT Id FROM Audit.AuditCompanyEngagement WHERE AuditCompanyId IN (SELECT Id FROM Audit.AuditCompany WHERE CompanyId IN (SELECT Id FROM @CompanyInfo)))
)

------------------------DELETE FROM Audit.WPCommentReply_ToBeDeleted WHERE WPCommentId IN  ---> No data in Table
------------------------(
------------------------SELECT Id FROM Audit.WPComment_ToBeDeleted WHERE WPCategoryId IN
------------------------(
------------------------SELECT Id FROM Audit.WPSetupDetail_ToBeDeleted WHERE WPSetupId IN
------------------------(
------------------------SELECT Id FROM Audit.WPSetup WHERE EngagementId IN
------------------------(SELECT Id FROM Audit.AuditCompanyEngagement WHERE AuditCompanyId IN (SELECT Id FROM Audit.AuditCompany WHERE CompanyId IN (SELECT Id FROM @CompanyInfo)))
------------------------)
------------------------)
------------------------)

------------------------DELETE FROM Audit.WPComment_ToBeDeleted WHERE WPCategoryId IN ---> No data in Table
------------------------(
------------------------SELECT Id FROM Audit.WPSetupDetail_ToBeDeleted WHERE WPSetupId IN
------------------------(
------------------------SELECT Id FROM Audit.WPSetup WHERE EngagementId IN
------------------------(SELECT Id FROM Audit.AuditCompanyEngagement WHERE AuditCompanyId IN (SELECT Id FROM Audit.AuditCompany WHERE CompanyId IN (SELECT Id FROM @CompanyInfo)))
------------------------)
------------------------)

------------------------DELETE FROM Audit.WPImportFile_ToBeDeleted WHERE WPCategoryId IN ---> No data in Table
------------------------(
------------------------SELECT Id FROM Audit.WPSetupDetail_ToBeDeleted WHERE WPSetupId IN
------------------------(
------------------------SELECT Id FROM Audit.WPSetup WHERE EngagementId IN
------------------------(SELECT Id FROM Audit.AuditCompanyEngagement WHERE AuditCompanyId IN (SELECT Id FROM Audit.AuditCompany WHERE CompanyId IN (SELECT Id FROM @CompanyInfo)))
------------------------)
------------------------)

DELETE FROM Audit.WPSetupDetail_ToBeDeleted WHERE WPSetupId IN
(
SELECT Id FROM Audit.WPSetup WHERE EngagementId IN
(SELECT Id FROM Audit.AuditCompanyEngagement WHERE AuditCompanyId IN (SELECT Id FROM Audit.AuditCompany WHERE CompanyId IN (SELECT Id FROM @CompanyInfo)))
)

DELETE FROM Audit.WPSetupTickmark WHERE WPSetupId IN
(
SELECT Id FROM Audit.WPSetup WHERE EngagementId IN
(SELECT Id FROM Audit.AuditCompanyEngagement WHERE AuditCompanyId IN (SELECT Id FROM Audit.AuditCompany WHERE CompanyId IN (SELECT Id FROM @CompanyInfo)))
)

DELETE FROM Audit.WPSetup WHERE EngagementId IN
(SELECT Id FROM Audit.AuditCompanyEngagement WHERE AuditCompanyId IN (SELECT Id FROM Audit.AuditCompany WHERE CompanyId IN (SELECT Id FROM @CompanyInfo)))

DELETE FROM Common.Suggestion WHERE EngagementId IN
(SELECT Id FROM Audit.AuditCompanyEngagement WHERE AuditCompanyId IN (SELECT Id FROM Audit.AuditCompany WHERE CompanyId IN (SELECT Id FROM @CompanyInfo)))

DELETE FROM Audit.AuditCompanyEngagement WHERE AuditCompanyId IN (SELECT Id FROM Audit.AuditCompany WHERE CompanyId IN (SELECT Id FROM @CompanyInfo))

--------------------------================================= Audit.AuditMenu_ToBeDeleted ===========================

----------------------------DELETE FROM Audit.AuditMenu_ToBeDeleted WHERE AuditCompanyId IN ---> No Data in Table
----------------------------(SELECT Id FROM Audit.AuditCompany WHERE CompanyId IN (SELECT Id FROM @CompanyInfo))

--------------------------================================= Audit.CashFlow ===========================

DELETE FROM Audit.CashFlowDetail_ToBeDeleted WHERE CashFlowItemId IN
(
SELECT Id FROM Audit.CashFlowItem WHERE CashFlowId IN
(SELECT Id FROM Audit.CashFlow WHERE AuditCompanyId IN (SELECT Id FROM Audit.AuditCompany WHERE CompanyId IN (SELECT Id FROM @CompanyInfo)))
)

DELETE FROM Audit.CashFlowItemDetail WHERE CashFlowItemId IN
(
SELECT Id FROM Audit.CashFlowItem WHERE CashFlowId IN
(SELECT Id FROM Audit.CashFlow WHERE AuditCompanyId IN (SELECT Id FROM Audit.AuditCompany WHERE CompanyId IN (SELECT Id FROM @CompanyInfo)))
)

DELETE FROM Audit.CashFlowItem WHERE CashFlowId IN
(SELECT Id FROM Audit.CashFlow WHERE AuditCompanyId IN (SELECT Id FROM Audit.AuditCompany WHERE CompanyId IN (SELECT Id FROM @CompanyInfo)))

DELETE FROM Audit.CashFlow WHERE AuditCompanyId IN (SELECT Id FROM Audit.AuditCompany WHERE CompanyId IN (SELECT Id FROM @CompanyInfo))

-----------------------================================= Audit.CashFlowHeadings_ToBeDeleted ===========================

DELETE FROM Audit.CashFlowDetail_ToBeDeleted WHERE CashflowHeadingId IN
(
SELECT Id FROM Audit.CashFlowHeadings_ToBeDeleted WHERE AuditCompanyId IN
(SELECT Id FROM Audit.AuditCompany WHERE CompanyId IN (SELECT Id FROM @CompanyInfo))
)

DELETE FROM Audit.CashFlowHeadings_ToBeDeleted WHERE AuditCompanyId IN
(SELECT Id FROM Audit.AuditCompany WHERE CompanyId IN (SELECT Id FROM @CompanyInfo))

------------------------================================= Audit.EngagementVisitedHistory ===========================

DELETE FROM Audit.EngagementVisitedHistory WHERE AuditCompanyId IN
(
SELECT Id FROM Audit.AuditCompany WHERE CompanyId IN (SELECT Id FROM @CompanyInfo)
)

-------------------------================================= Audit.PlanningAndCompletionSetUp ===========================


DELETE FROM Audit.ClientAndEngagementIndependenceConfirmation WHERE PlanningAndCompletionSetUpId IN
(
SELECT Id FROM Audit.PlanningAndCompletionSetUp WHERE AuditCompanyId IN
(SELECT Id FROM Audit.AuditCompany WHERE CompanyId IN (SELECT Id FROM @CompanyInfo))
)

DELETE FROM Audit.DeclarationOfDirectors WHERE PlanningAndCompletionSetUpId IN 
(
SELECT Id FROM Audit.PlanningAndCompletionSetUp WHERE AuditCompanyId IN
(SELECT Id FROM Audit.AuditCompany WHERE CompanyId IN (SELECT Id FROM @CompanyInfo))
)

DELETE FROM Audit.DirectorRemunerationDetails WHERE DirectorRemunerationId IN
(
SELECT Id FROM Audit.DirectorRemuneration WHERE PlanningAndCompletionSetUpId IN 
(
SELECT Id FROM Audit.PlanningAndCompletionSetUp WHERE AuditCompanyId IN
(SELECT Id FROM Audit.AuditCompany WHERE CompanyId IN (SELECT Id FROM @CompanyInfo))
)
)

DELETE FROM Audit.DirectorRemuneration WHERE PlanningAndCompletionSetUpId IN 
(
SELECT Id FROM Audit.PlanningAndCompletionSetUp WHERE AuditCompanyId IN
(SELECT Id FROM Audit.AuditCompany WHERE CompanyId IN (SELECT Id FROM @CompanyInfo))
)

DELETE FROM Audit.PAndCSectionQuestions WHERE PAndCSectionId IN
(
SELECT Id FROM Audit.PAndCSections WHERE PlanningAndCompletionSetUpId IN
(
SELECT Id FROM Audit.PlanningAndCompletionSetUp WHERE AuditCompanyId IN
(SELECT Id FROM Audit.AuditCompany WHERE CompanyId IN (SELECT Id FROM @CompanyInfo))
)
)

DELETE FROM Audit.PAndCSections WHERE PlanningAndCompletionSetUpId IN
(
SELECT Id FROM Audit.PlanningAndCompletionSetUp WHERE AuditCompanyId IN
(SELECT Id FROM Audit.AuditCompany WHERE CompanyId IN (SELECT Id FROM @CompanyInfo))
)

DELETE FROM Audit.PlanningAndCompletionSetUp WHERE AuditCompanyId IN
(SELECT Id FROM Audit.AuditCompany WHERE CompanyId IN (SELECT Id FROM @CompanyInfo))

-----------------------================================= Audit.PlanningMateriality ===========================

DELETE FROM Audit.PlanningMaterialityDetailLeadSheet WHERE PlanningMaterialityDetailId IN
(
SELECT Id FROM Audit.PlanningMaterialityDetail WHERE PlanningMeterialityId IN
(
SELECT Id FROM Audit.PlanningMateriality WHERE AuditCompanyId IN
(SELECT Id FROM Audit.AuditCompany WHERE CompanyId IN (SELECT Id FROM @CompanyInfo))
)
)

DELETE FROM Audit.PlanningMaterialityDetail WHERE PlanningMeterialityId IN
(
SELECT Id FROM Audit.PlanningMateriality WHERE AuditCompanyId IN
(SELECT Id FROM Audit.AuditCompany WHERE CompanyId IN (SELECT Id FROM @CompanyInfo))
)

DELETE FROM Audit.PlanningMateriality WHERE AuditCompanyId IN
(SELECT Id FROM Audit.AuditCompany WHERE CompanyId IN (SELECT Id FROM @CompanyInfo))

--------------------------================================= Audit.Questionnaire_ToBeDeleted ===========================

DELETE FROM Audit.Question_ToBeDeleted WHERE QuestionnaireId IN
(
SELECT Id FROM Audit.Questionnaire_ToBeDeleted WHERE AuditCompanyId IN
(
SELECT Id FROM Audit.AuditCompany WHERE CompanyId IN (SELECT Id FROM @CompanyInfo)
)
)

DELETE FROM Audit.Questionnaire_ToBeDeleted WHERE AuditCompanyId IN
(
SELECT Id FROM Audit.AuditCompany WHERE CompanyId IN (SELECT Id FROM @CompanyInfo)
)


--------------------------================================= Audit.TrialBalanceImport ===========================

DELETE FROM Audit.TrialBalanceImport WHERE AuditCompanyId IN
(
SELECT Id FROM Audit.AuditCompany WHERE CompanyId IN (SELECT Id FROM @CompanyInfo)
)

-----------------------================================= Audit.AuditCompany ===========================

DELETE FROM Audit.AuditCompany WHERE CompanyId IN (SELECT Id FROM @CompanyInfo)

----------------------------//////////////////////////////////////////////////////////////////////// Audit.AuditManual \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

--------------------------------================================= Audit.MenuSetUpMaster ===========================

DELETE FROM Audit.MenuSetUpMaster WHERE AuditManualId IN 
(SELECT Id FROM Audit.AuditManual WHERE CompanyId IN (SELECT Id FROM @CompanyInfo))

---------------------------================================= Audit.PlanningAndCompletionSetUpMaster ===========================

DELETE FROM Audit.ClientAndEngagementIndependenceConfirmation WHERE PlanningAndCompletionSetUpId IN
(
SELECT Id FROM Audit.PlanningAndCompletionSetUp WHERE MasterId IN 
(
SELECT Id FROM Audit.PlanningAndCompletionSetUpMaster WHERE AuditManualId IN 
(SELECT Id FROM Audit.AuditManual WHERE CompanyId IN (SELECT Id FROM @CompanyInfo))
)
)

DELETE FROM Audit.DeclarationOfDirectors WHERE PlanningAndCompletionSetUpId IN
(
SELECT Id FROM Audit.PlanningAndCompletionSetUp WHERE MasterId IN 
(
SELECT Id FROM Audit.PlanningAndCompletionSetUpMaster WHERE AuditManualId IN 
(SELECT Id FROM Audit.AuditManual WHERE CompanyId IN (SELECT Id FROM @CompanyInfo))
)
)

DELETE FROM Audit.DirectorRemunerationDetails WHERE DirectorRemunerationId IN
(
SELECT Id FROM Audit.DirectorRemuneration WHERE PlanningAndCompletionSetUpId IN
(
SELECT Id FROM Audit.PlanningAndCompletionSetUp WHERE MasterId IN 
(
SELECT Id FROM Audit.PlanningAndCompletionSetUpMaster WHERE AuditManualId IN 
(SELECT Id FROM Audit.AuditManual WHERE CompanyId IN (SELECT Id FROM @CompanyInfo))
)
)
)

DELETE FROM Audit.DirectorRemuneration WHERE PlanningAndCompletionSetUpId IN
(
SELECT Id FROM Audit.PlanningAndCompletionSetUp WHERE MasterId IN 
(
SELECT Id FROM Audit.PlanningAndCompletionSetUpMaster WHERE AuditManualId IN 
(SELECT Id FROM Audit.AuditManual WHERE CompanyId IN (SELECT Id FROM @CompanyInfo))
)
)

DELETE FROM Audit.PAndCSectionQuestions WHERE PAndCSectionId IN
(
SELECT Id FROM Audit.PAndCSections WHERE PlanningAndCompletionSetUpId IN
(
SELECT Id FROM Audit.PlanningAndCompletionSetUp WHERE MasterId IN 
(
SELECT Id FROM Audit.PlanningAndCompletionSetUpMaster WHERE AuditManualId IN 
(SELECT Id FROM Audit.AuditManual WHERE CompanyId IN (SELECT Id FROM @CompanyInfo))
)
)
)

DELETE FROM Audit.PAndCSections WHERE PlanningAndCompletionSetUpId IN
(
SELECT Id FROM Audit.PlanningAndCompletionSetUp WHERE MasterId IN 
(
SELECT Id FROM Audit.PlanningAndCompletionSetUpMaster WHERE AuditManualId IN 
(SELECT Id FROM Audit.AuditManual WHERE CompanyId IN (SELECT Id FROM @CompanyInfo))
)
)

DELETE FROM Audit.PlanningAndCompletionSetUp WHERE MasterId IN 
(
SELECT Id FROM Audit.PlanningAndCompletionSetUpMaster WHERE AuditManualId IN 
(SELECT Id FROM Audit.AuditManual WHERE CompanyId IN (SELECT Id FROM @CompanyInfo))
)

DELETE FROM Audit.PlanningAndCompletionSetUpMaster WHERE AuditManualId IN 
(SELECT Id FROM Audit.AuditManual WHERE CompanyId IN (SELECT Id FROM @CompanyInfo))

---------------------------------================================= Audit.SuggestionSetUpMaster ===========================

DELETE FROM Common.Suggestion WHERE MasterId IN
(
SELECT Id FROM Audit.SuggestionSetUpMaster WHERE AuditManualId IN
(SELECT Id FROM Audit.AuditManual WHERE CompanyId IN (SELECT Id FROM @CompanyInfo))
)

DELETE FROM Audit.SuggestionSetUpMaster WHERE AuditManualId IN
(SELECT Id FROM Audit.AuditManual WHERE CompanyId IN (SELECT Id FROM @CompanyInfo))

-----------------------------------================================= Audit.WPSetupMaster ===========================

DELETE FROM Audit.CashFlowDetail_ToBeDeleted WHERE LeadSheetId IN
(
SELECT Id FROM Audit.LeadSheet WHERE WorkProgramId IN
(
SELECT Id FROM Audit.WPSetup WHERE WpsetupMasterId IN
(
SELECT Id FROM Audit.WPSetupMaster WHERE AuditManualId IN
(SELECT Id FROM Audit.AuditManual WHERE CompanyId IN (SELECT Id FROM @CompanyInfo))
)
)
)

DELETE FROM Audit.CashFlowItemDetail WHERE LeadSheetId IN
(
SELECT Id FROM Audit.LeadSheet WHERE WorkProgramId IN
(
SELECT Id FROM Audit.WPSetup WHERE WpsetupMasterId IN
(
SELECT Id FROM Audit.WPSetupMaster WHERE AuditManualId IN
(SELECT Id FROM Audit.AuditManual WHERE CompanyId IN (SELECT Id FROM @CompanyInfo))
)
)
)

DELETE FROM Audit.Equity WHERE LeadSheetId IN
(
SELECT Id FROM Audit.LeadSheet WHERE WorkProgramId IN
(
SELECT Id FROM Audit.WPSetup WHERE WpsetupMasterId IN
(
SELECT Id FROM Audit.WPSetupMaster WHERE AuditManualId IN
(SELECT Id FROM Audit.AuditManual WHERE CompanyId IN (SELECT Id FROM @CompanyInfo))
)
)
)


DELETE FROM Audit.LeadSheetCategories WHERE LeadsheetId IN
(
SELECT Id FROM Audit.LeadSheet WHERE WorkProgramId IN
(
SELECT Id FROM Audit.WPSetup WHERE WpsetupMasterId IN
(
SELECT Id FROM Audit.WPSetupMaster WHERE AuditManualId IN
(SELECT Id FROM Audit.AuditManual WHERE CompanyId IN (SELECT Id FROM @CompanyInfo))
)
)
)

DELETE FROM Audit.PlanningMaterialityDetailLeadSheet WHERE LeadSheetId IN
(
SELECT Id FROM Audit.LeadSheet WHERE WorkProgramId IN
(
SELECT Id FROM Audit.WPSetup WHERE WpsetupMasterId IN
(
SELECT Id FROM Audit.WPSetupMaster WHERE AuditManualId IN
(SELECT Id FROM Audit.AuditManual WHERE CompanyId IN (SELECT Id FROM @CompanyInfo))
)
)
)

DELETE FROM Audit.PlanningMaterialityLeadSheet WHERE LeadSheetId IN
(
SELECT Id FROM Audit.LeadSheet WHERE WorkProgramId IN
(
SELECT Id FROM Audit.WPSetup WHERE WpsetupMasterId IN
(
SELECT Id FROM Audit.WPSetupMaster WHERE AuditManualId IN
(SELECT Id FROM Audit.AuditManual WHERE CompanyId IN (SELECT Id FROM @CompanyInfo))
)
)
)

DELETE FROM Audit.LeadSheet WHERE WorkProgramId IN
(
SELECT Id FROM Audit.WPSetup WHERE WpsetupMasterId IN
(
SELECT Id FROM Audit.WPSetupMaster WHERE AuditManualId IN
(SELECT Id FROM Audit.AuditManual WHERE CompanyId IN (SELECT Id FROM @CompanyInfo))
)
)

------------------DELETE FROM Audit.WPSetupDetail_ToBeDeleted WHERE WPSetupId IN ---> No Data in Table
------------------(
------------------SELECT Id FROM Audit.WPSetup WHERE WpsetupMasterId IN
------------------(
------------------SELECT Id FROM Audit.WPSetupMaster WHERE AuditManualId IN
------------------(SELECT Id FROM Audit.AuditManual WHERE CompanyId IN (SELECT Id FROM @CompanyInfo))
------------------)
------------------)

DELETE FROM Audit.WPSetupTickmark WHERE WPSetupId IN
(
SELECT Id FROM Audit.WPSetup WHERE WpsetupMasterId IN
(
SELECT Id FROM Audit.WPSetupMaster WHERE AuditManualId IN
(SELECT Id FROM Audit.AuditManual WHERE CompanyId IN (SELECT Id FROM @CompanyInfo))
)
)

DELETE FROM Audit.WPSetup WHERE WpsetupMasterId IN
(
SELECT Id FROM Audit.WPSetupMaster WHERE AuditManualId IN
(SELECT Id FROM Audit.AuditManual WHERE CompanyId IN (SELECT Id FROM @CompanyInfo))
)

DELETE FROM Audit.WPSetupMaster WHERE AuditManualId IN
(SELECT Id FROM Audit.AuditManual WHERE CompanyId IN (SELECT Id FROM @CompanyInfo))

----------------=============================== Audit.AuditManual =============================

DELETE FROM Audit.AuditManual WHERE CompanyId IN (SELECT Id FROM @CompanyInfo)

-------------------//////////////////////////////////////////////////////////////////////// Audit.AuditMenu_ToBeDeleted \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

-------------------DELETE FROM Audit.AuditMenu_ToBeDeleted WHERE CompanyId IN (SELECT Id FROM @CompanyInfo) ---> No data in Table

--------------------//////////////////////////////////////////////////////////////////////// Audit.AuditPermission_ToBeDeleted \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

-------------------DELETE FROM Audit.AuditPermission_ToBeDeleted WHERE CompanyId IN (SELECT Id FROM @CompanyInfo) ---> No data in Table

---------------------//////////////////////////////////////////////////////////////////////// Audit.AuditRole_ToBeDeleted \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

------------------------DELETE FROM Audit.AuditRole_ToBeDeleted WHERE CompanyId IN (SELECT Id FROM @CompanyInfo) ---> No data in Table

-------------------//////////////////////////////////////////////////////////////////////// Audit.AuditRolePermission_ToBeDeleted \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

----------------DELETE FROM Audit.AuditRolePermission_ToBeDeleted WHERE CompanyId IN (SELECT Id FROM @CompanyInfo) ---> No data in Table

---------------------------//////////////////////////////////////////////////////////////////////// Audit.CashFlow \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

-----------------=============================== Audit.CashFlowItem ====================================


--------------DELETE FROM Audit.CashFlowDetail_ToBeDeleted WHERE CashFlowItemId IN  ---> No data in Table
--------------(
--------------SELECT Id FROM Audit.CashFlowItem WHERE CashFlowId IN
--------------(SELECT Id FROM Audit.CashFlow WHERE CompanyId IN (SELECT Id FROM @CompanyInfo))
--------------)

DELETE FROM Audit.CashFlowItemDetail WHERE CashFlowItemId IN
(
SELECT Id FROM Audit.CashFlowItem WHERE CashFlowId IN
(SELECT Id FROM Audit.CashFlow WHERE CompanyId IN (SELECT Id FROM @CompanyInfo))
)

DELETE FROM Audit.CashFlowItem WHERE CashFlowId IN
(SELECT Id FROM Audit.CashFlow WHERE CompanyId IN (SELECT Id FROM @CompanyInfo))

-----------------=============================== Audit.CashFlow ====================================

DELETE FROM Audit.CashFlow WHERE CompanyId IN (SELECT Id FROM @CompanyInfo)

-----------------//////////////////////////////////////////////////////////////////////// Audit.CashFlowHeadings_ToBeDeleted \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\


----------------DELETE FROM Audit.CashFlowDetail_ToBeDeleted WHERE CashFlowHeadingId IN ---> No data in Table
----------------(SELECT Id FROM Audit.CashFlowHeadings_ToBeDeleted WHERE CompanyId IN (SELECT Id FROM @CompanyInfo))

DELETE FROM Audit.CashFlowHeadings_ToBeDeleted WHERE CompanyId IN (SELECT Id FROM @CompanyInfo)

------------------//////////////////////////////////////////////////////////////////////// Audit.Disclosure \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\


DELETE FROM Audit.DisclosureDetails WHERE DisclosureId IN
(SELECT Id FROM Audit.Disclosure WHERE CompanyId IN (SELECT Id FROM @CompanyInfo))

DELETE FROM Audit.DisclosureSections WHERE DisclosureId IN
(SELECT Id FROM Audit.Disclosure WHERE CompanyId IN (SELECT Id FROM @CompanyInfo))

DELETE FROM Audit.Disclosure WHERE CompanyId IN (SELECT Id FROM @CompanyInfo)

-------------------//////////////////////////////////////////////////////////////////////// Audit.EngagementTypeMenuMapping \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

----------------DELETE FROM Audit.EngagementTypeMenuMapping WHERE CompanyId IN (SELECT Id FROM @CompanyInfo) ---> No Data in Table

------------------//////////////////////////////////////////////////////////////////////// Audit.EngagementVisitedHistory \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

DELETE FROM Audit.EngagementVisitedHistory WHERE CompanyId IN (SELECT Id FROM @CompanyInfo)

------------------//////////////////////////////////////////////////////////////////////// Audit.FormMaster \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

DELETE FROM Audit.FormDetail WHERE FormMasterId IN
(SELECT Id FROM Audit.FormMaster WHERE CompanyId IN (SELECT Id FROM @CompanyInfo))

DELETE FROM Audit.FormMaster WHERE CompanyId IN (SELECT Id FROM @CompanyInfo)

-------------------//////////////////////////////////////////////////////////////////////// Audit.FSTemplates \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

DELETE FROM Audit.FSTemplates WHERE CompanyId IN (SELECT Id FROM @CompanyInfo)

-------------------//////////////////////////////////////////////////////////////////////// Audit.GeneralLedgerImport \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\


DELETE FROM Audit.GeneralLedgerDetail WHERE GeneralLedgerId IN
(SELECT Id FROM Audit.GeneralLedgerImport WHERE CompanyId IN (SELECT Id FROM @CompanyInfo))

DELETE FROM Audit.GeneralLedgerImport WHERE CompanyId IN (SELECT Id FROM @CompanyInfo)

-------------------//////////////////////////////////////////////////////////////////////// Audit.LeadSheet \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
 
------------------DELETE FROM Audit.CashFlowDetail_ToBeDeleted WHERE LeadSheetId IN ----> No Data in Table
------------------(SELECT Id FROM Audit.LeadSheet WHERE CompanyId IN (SELECT Id FROM @CompanyInfo))


DELETE FROM Audit.CashFlowItemDetail WHERE LeadSheetId IN
(SELECT Id FROM Audit.LeadSheet WHERE CompanyId IN (SELECT Id FROM @CompanyInfo))


DELETE FROM Audit.Equity WHERE LeadSheetId IN
(SELECT Id FROM Audit.LeadSheet WHERE CompanyId IN (SELECT Id FROM @CompanyInfo))


DELETE FROM Audit.LeadSheetCategories WHERE LeadsheetId IN
(SELECT Id FROM Audit.LeadSheet WHERE CompanyId IN (SELECT Id FROM @CompanyInfo))


DELETE FROM Audit.PlanningMaterialityDetailLeadSheet WHERE LeadSheetId IN
(SELECT Id FROM Audit.LeadSheet WHERE CompanyId IN (SELECT Id FROM @CompanyInfo))


DELETE FROM Audit.PlanningMaterialityLeadSheet WHERE LeadSheetId IN
(SELECT Id FROM Audit.LeadSheet WHERE CompanyId IN (SELECT Id FROM @CompanyInfo))

DELETE FROM Audit.LeadSheet WHERE CompanyId IN (SELECT Id FROM @CompanyInfo)

--------------------//////////////////////////////////////////////////////////////////////// Audit.LeadSheetSetupMaster \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

----------------DELETE FROM Audit.CashFlowDetail_ToBeDeleted WHERE LeadSheetId IN ----> No Data in Table
----------------(SELECT Id FROM Audit.LeadSheet WHERE MasterId IN (SELECT Id FROM Audit.LeadSheetSetupMaster WHERE CompanyId IN (SELECT Id FROM @CompanyInfo)))


DELETE FROM Audit.CashFlowItemDetail WHERE LeadSheetId IN
(SELECT Id FROM Audit.LeadSheet WHERE MasterId IN (SELECT Id FROM Audit.LeadSheetSetupMaster WHERE CompanyId IN (SELECT Id FROM @CompanyInfo)))


DELETE FROM Audit.Equity WHERE LeadSheetId IN
(SELECT Id FROM Audit.LeadSheet WHERE MasterId IN (SELECT Id FROM Audit.LeadSheetSetupMaster WHERE CompanyId IN (SELECT Id FROM @CompanyInfo)))


DELETE FROM Audit.LeadSheetCategories WHERE LeadsheetId IN
(SELECT Id FROM Audit.LeadSheet WHERE MasterId IN (SELECT Id FROM Audit.LeadSheetSetupMaster WHERE CompanyId IN (SELECT Id FROM @CompanyInfo)))


DELETE FROM Audit.PlanningMaterialityDetailLeadSheet WHERE LeadSheetId IN
(SELECT Id FROM Audit.LeadSheet WHERE MasterId IN (SELECT Id FROM Audit.LeadSheetSetupMaster WHERE CompanyId IN (SELECT Id FROM @CompanyInfo)))


DELETE FROM Audit.PlanningMaterialityLeadSheet WHERE LeadSheetId IN
(SELECT Id FROM Audit.LeadSheet WHERE MasterId IN (SELECT Id FROM Audit.LeadSheetSetupMaster WHERE CompanyId IN (SELECT Id FROM @CompanyInfo)))

DELETE FROM Audit.LeadSheet WHERE MasterId IN
(SELECT Id FROM Audit.LeadSheetSetupMaster WHERE CompanyId IN (SELECT Id FROM @CompanyInfo))

DELETE FROM Audit.LeadSheetSetupMaster WHERE CompanyId IN (SELECT Id FROM @CompanyInfo)

-------------------//////////////////////////////////////////////////////////////////////// Audit.MenuSetUpMaster \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

DELETE FROM Audit.MenuSetUpMaster WHERE CompanyId IN (SELECT Id FROM @CompanyInfo)

------------------//////////////////////////////////////////////////////////////////////// Audit.PlanningAndCompletionSetUp \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

DELETE FROM Audit.ClientAndEngagementIndependenceConfirmation WHERE PlanningAndCompletionSetUpId IN
(
SELECT Id FROM Audit.PlanningAndCompletionSetUp WHERE CompanyId IN (SELECT Id FROM @CompanyInfo)
)

DELETE FROM Audit.DeclarationOfDirectors WHERE PlanningAndCompletionSetUpId IN
(
SELECT Id FROM Audit.PlanningAndCompletionSetUp WHERE CompanyId IN (SELECT Id FROM @CompanyInfo)
)

DELETE FROM Audit.DirectorRemunerationDetails WHERE DirectorRemunerationId IN
(
SELECT Id FROM Audit.DirectorRemuneration WHERE PlanningAndCompletionSetUpId IN
(
SELECT Id FROM Audit.PlanningAndCompletionSetUp WHERE CompanyId IN (SELECT Id FROM @CompanyInfo)
)
)

DELETE FROM Audit.DirectorRemuneration WHERE PlanningAndCompletionSetUpId IN
(
SELECT Id FROM Audit.PlanningAndCompletionSetUp WHERE CompanyId IN (SELECT Id FROM @CompanyInfo)
)

DELETE FROM Audit.PAndCSectionQuestions WHERE PAndCSectionId IN
(
SELECT Id FROM Audit.PAndCSections WHERE PlanningAndCompletionSetUpId IN
(
SELECT Id FROM Audit.PlanningAndCompletionSetUp WHERE CompanyId IN (SELECT Id FROM @CompanyInfo)
)
)

DELETE FROM Audit.PAndCSections WHERE PlanningAndCompletionSetUpId IN
(
SELECT Id FROM Audit.PlanningAndCompletionSetUp WHERE CompanyId IN (SELECT Id FROM @CompanyInfo)
)

DELETE FROM Audit.PlanningAndCompletionSetUp WHERE CompanyId IN (SELECT Id FROM @CompanyInfo)

-----------------------//////////////////////////////////////////////////////////////////////// Audit.PlanningAndCompletionSetUpMaster \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\


DELETE FROM Audit.ClientAndEngagementIndependenceConfirmation WHERE PlanningAndCompletionSetUpId IN
(
SELECT Id FROM Audit.PlanningAndCompletionSetUp WHERE MasterId IN
(
SELECT Id FROM Audit.PlanningAndCompletionSetUpMaster WHERE CompanyId IN (SELECT Id FROM @CompanyInfo)
)
)

DELETE FROM Audit.DeclarationOfDirectors WHERE PlanningAndCompletionSetUpId IN
(
SELECT Id FROM Audit.PlanningAndCompletionSetUp WHERE MasterId IN
(
SELECT Id FROM Audit.PlanningAndCompletionSetUpMaster WHERE CompanyId IN (SELECT Id FROM @CompanyInfo)
)
)

DELETE FROM Audit.DirectorRemunerationDetails WHERE DirectorRemunerationId IN
(
SELECT Id FROM Audit.DirectorRemuneration WHERE PlanningAndCompletionSetUpId IN
(
SELECT Id FROM Audit.PlanningAndCompletionSetUp WHERE MasterId IN
(
SELECT Id FROM Audit.PlanningAndCompletionSetUpMaster WHERE CompanyId IN (SELECT Id FROM @CompanyInfo)
)
)
)

DELETE FROM Audit.DirectorRemuneration WHERE PlanningAndCompletionSetUpId IN
(
SELECT Id FROM Audit.PlanningAndCompletionSetUp WHERE MasterId IN
(
SELECT Id FROM Audit.PlanningAndCompletionSetUpMaster WHERE CompanyId IN (SELECT Id FROM @CompanyInfo)
)
)

DELETE FROM Audit.PAndCSectionQuestions WHERE PAndCSectionId IN
(
SELECT Id FROM Audit.PAndCSections WHERE PlanningAndCompletionSetUpId IN
(
SELECT Id FROM Audit.PlanningAndCompletionSetUp WHERE MasterId IN
(
SELECT Id FROM Audit.PlanningAndCompletionSetUpMaster WHERE CompanyId IN (SELECT Id FROM @CompanyInfo)
)
)
)

DELETE FROM Audit.PAndCSections WHERE PlanningAndCompletionSetUpId IN
(
SELECT Id FROM Audit.PlanningAndCompletionSetUp WHERE MasterId IN
(
SELECT Id FROM Audit.PlanningAndCompletionSetUpMaster WHERE CompanyId IN (SELECT Id FROM @CompanyInfo)
)
)

DELETE FROM Audit.PlanningAndCompletionSetUp WHERE MasterId IN
(
SELECT Id FROM Audit.PlanningAndCompletionSetUpMaster WHERE CompanyId IN (SELECT Id FROM @CompanyInfo)
)

DELETE FROM Audit.PlanningAndCompletionSetUpMaster WHERE CompanyId IN (SELECT Id FROM @CompanyInfo)

----------------//////////////////////////////////////////////////////////////////////// Audit.PlanningMateriality \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

DELETE FROM Audit.PlanningMaterialityDetailLeadSheet WHERE PlanningMaterialityDetailId IN
(
SELECT Id FROM Audit.PlanningMaterialityDetail WHERE PlanningMeterialityId IN
(SELECT Id FROM Audit.PlanningMateriality WHERE CompanyId IN (SELECT Id FROM @CompanyInfo))
)

DELETE FROM Audit.PlanningMaterialityDetail WHERE PlanningMeterialityId IN
(SELECT Id FROM Audit.PlanningMateriality WHERE CompanyId IN (SELECT Id FROM @CompanyInfo))

DELETE FROM Audit.PlanningMateriality WHERE CompanyId IN (SELECT Id FROM @CompanyInfo)

----------------//////////////////////////////////////////////////////////////////////// Audit.PlanningMaterialitySetup \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

DELETE FROM Audit.PlanningMaterialityDetailLeadSheet WHERE PlanningMaterialityDetailId IN
(
SELECT Id FROM Audit.PlanningMaterialityDetail WHERE PlanningMeterialityId IN
(
SELECT Id FROM Audit.PlanningMateriality WHERE PlanningMaterialitySetupId IN
(
SELECT Id FROM Audit.PlanningMaterialitySetup WHERE CompanyId IN (SELECT Id FROM @CompanyInfo)
)
)
)

DELETE FROM Audit.PlanningMaterialityDetail WHERE PlanningMeterialityId IN
(
SELECT Id FROM Audit.PlanningMateriality WHERE PlanningMaterialitySetupId IN
(
SELECT Id FROM Audit.PlanningMaterialitySetup WHERE CompanyId IN (SELECT Id FROM @CompanyInfo)
)
)

DELETE FROM Audit.PlanningMateriality WHERE PlanningMaterialitySetupId IN
(
SELECT Id FROM Audit.PlanningMaterialitySetup WHERE CompanyId IN (SELECT Id FROM @CompanyInfo)
)

DELETE FROM Audit.PlanningMaterialityLeadSheet WHERE PlanningMaterialitySetupDetailId IN
(
SELECT Id FROM Audit.PlanningMaterialitySetupDetail WHERE PlanningMaterialitySetupId IN
(
SELECT Id FROM Audit.PlanningMaterialitySetup WHERE CompanyId IN (SELECT Id FROM @CompanyInfo)
)
)

DELETE FROM Audit.PlanningMaterialitySetupDetail WHERE PlanningMaterialitySetupId IN
(
SELECT Id FROM Audit.PlanningMaterialitySetup WHERE CompanyId IN (SELECT Id FROM @CompanyInfo)
)

DELETE FROM Audit.PlanningMaterialitySetup WHERE CompanyId IN (SELECT Id FROM @CompanyInfo)

---------------//////////////////////////////////////////////////////////////////////// Audit.ReportingTemplates \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

DELETE FROM Audit.ReportingTemplates WHERE PartnerCompanyId IN (SELECT Id FROM @CompanyInfo)

---------------//////////////////////////////////////////////////////////////////////// Audit.SuggestionSetUpMaster \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

DELETE FROM Common.Suggestion WHERE MasterId IN 
(SELECT Id FROM Audit.SuggestionSetUpMaster WHERE CompanyId IN (SELECT Id FROM @CompanyInfo))

DELETE FROM Audit.SuggestionSetUpMaster WHERE CompanyId IN (SELECT Id FROM @CompanyInfo)

----------------//////////////////////////////////////////////////////////////////////// Audit.Template \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

DELETE FROM Audit.Template WHERE CompanyId IN (SELECT Id FROM @CompanyInfo)

---------------//////////////////////////////////////////////////////////////////////// Audit.TemplateVariable \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

DELETE FROM Audit.TemplateVariable WHERE CompanyId IN (SELECT Id FROM @CompanyInfo)

---------------//////////////////////////////////////////////////////////////////////// Audit.WPSetup \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

DELETE FROM Audit.CashFlowDetail_ToBeDeleted WHERE LeadSheetId IN ----> No Data in Table
(SELECT Id FROM Audit.LeadSheet WHERE WorkProgramId IN
(SELECT Id FROM Audit.WPSetup WHERE CompanyId IN (SELECT Id FROM @CompanyInfo)))

DELETE FROM Audit.CashFlowItemDetail WHERE LeadSheetId IN
(SELECT Id FROM Audit.LeadSheet WHERE WorkProgramId IN
(SELECT Id FROM Audit.WPSetup WHERE CompanyId IN (SELECT Id FROM @CompanyInfo)))

DELETE FROM Audit.Equity WHERE LeadSheetId IN
(SELECT Id FROM Audit.LeadSheet WHERE WorkProgramId IN
(SELECT Id FROM Audit.WPSetup WHERE CompanyId IN (SELECT Id FROM @CompanyInfo)))

DELETE FROM Audit.LeadSheetCategories WHERE LeadsheetId IN
(SELECT Id FROM Audit.LeadSheet WHERE WorkProgramId IN
(SELECT Id FROM Audit.WPSetup WHERE CompanyId IN (SELECT Id FROM @CompanyInfo)))

DELETE FROM Audit.PlanningMaterialityDetailLeadSheet WHERE LeadSheetId IN
(SELECT Id FROM Audit.LeadSheet WHERE WorkProgramId IN
(SELECT Id FROM Audit.WPSetup WHERE CompanyId IN (SELECT Id FROM @CompanyInfo)))

DELETE FROM Audit.PlanningMaterialityLeadSheet WHERE LeadSheetId IN
(SELECT Id FROM Audit.LeadSheet WHERE WorkProgramId IN
(SELECT Id FROM Audit.WPSetup WHERE CompanyId IN (SELECT Id FROM @CompanyInfo)))

DELETE FROM Audit.LeadSheet WHERE WorkProgramId IN
(SELECT Id FROM Audit.WPSetup WHERE CompanyId IN (SELECT Id FROM @CompanyInfo))

DELETE FROM Audit.WPSetupDetail_ToBeDeleted WHERE WPSetupId IN ----> No Data in Table
(SELECT Id FROM Audit.WPSetup WHERE CompanyId IN (SELECT Id FROM @CompanyInfo))

DELETE FROM Audit.WPSetupTickmark WHERE WPSetupId IN
(SELECT Id FROM Audit.WPSetup WHERE CompanyId IN (SELECT Id FROM @CompanyInfo))

DELETE FROM Audit.WPSetup WHERE CompanyId IN (SELECT Id FROM @CompanyInfo)

-------------------//////////////////////////////////////////////////////////////////////// Audit.WPSetupMaster \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

DELETE FROM Audit.CashFlowDetail_ToBeDeleted WHERE LeadSheetId IN ----> No Data in Table
(SELECT Id FROM Audit.LeadSheet WHERE WorkProgramId IN
(SELECT Id FROM Audit.WPSetup WHERE WpsetupMasterId IN
(SELECT Id FROM Audit.WPSetupMaster WHERE CompanyId IN (SELECT Id FROM @CompanyInfo))))

DELETE FROM Audit.CashFlowItemDetail WHERE LeadSheetId IN
(SELECT Id FROM Audit.LeadSheet WHERE WorkProgramId IN
(SELECT Id FROM Audit.WPSetup WHERE WpsetupMasterId IN
(SELECT Id FROM Audit.WPSetupMaster WHERE CompanyId IN (SELECT Id FROM @CompanyInfo))))

DELETE FROM Audit.Equity WHERE LeadSheetId IN
(SELECT Id FROM Audit.LeadSheet WHERE WorkProgramId IN
(SELECT Id FROM Audit.WPSetup WHERE WpsetupMasterId IN
(SELECT Id FROM Audit.WPSetupMaster WHERE CompanyId IN (SELECT Id FROM @CompanyInfo))))

DELETE FROM Audit.LeadSheetCategories WHERE LeadsheetId IN
(SELECT Id FROM Audit.LeadSheet WHERE WorkProgramId IN
(SELECT Id FROM Audit.WPSetup WHERE WpsetupMasterId IN
(SELECT Id FROM Audit.WPSetupMaster WHERE CompanyId IN (SELECT Id FROM @CompanyInfo))))

DELETE FROM Audit.PlanningMaterialityDetailLeadSheet WHERE LeadSheetId IN
(SELECT Id FROM Audit.LeadSheet WHERE WorkProgramId IN
(SELECT Id FROM Audit.WPSetup WHERE WpsetupMasterId IN
(SELECT Id FROM Audit.WPSetupMaster WHERE CompanyId IN (SELECT Id FROM @CompanyInfo))))

DELETE FROM Audit.PlanningMaterialityLeadSheet WHERE LeadSheetId IN
(SELECT Id FROM Audit.LeadSheet WHERE WorkProgramId IN
(SELECT Id FROM Audit.WPSetup WHERE WpsetupMasterId IN
(SELECT Id FROM Audit.WPSetupMaster WHERE CompanyId IN (SELECT Id FROM @CompanyInfo))))

DELETE FROM Audit.LeadSheet WHERE WorkProgramId IN
(SELECT Id FROM Audit.WPSetup WHERE WpsetupMasterId IN
(SELECT Id FROM Audit.WPSetupMaster WHERE CompanyId IN (SELECT Id FROM @CompanyInfo)))

DELETE FROM Audit.WPSetupDetail_ToBeDeleted WHERE WPSetupId IN ----> No Data in Table
(SELECT Id FROM Audit.WPSetup WHERE WpsetupMasterId IN
(SELECT Id FROM Audit.WPSetupMaster WHERE CompanyId IN (SELECT Id FROM @CompanyInfo)))

DELETE FROM Audit.WPSetupTickmark WHERE WPSetupId IN
(SELECT Id FROM Audit.WPSetup WHERE WpsetupMasterId IN
(SELECT Id FROM Audit.WPSetupMaster WHERE CompanyId IN (SELECT Id FROM @CompanyInfo)))

DELETE FROM Audit.WPSetup WHERE WpsetupMasterId IN
(SELECT Id FROM Audit.WPSetupMaster WHERE CompanyId IN (SELECT Id FROM @CompanyInfo))

DELETE FROM Audit.WPSetupMaster WHERE CompanyId IN (SELECT Id FROM @CompanyInfo)

END
GO
