USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[CompanyWise_Tax_DataDeletion]    Script Date: 16-12-2024 9.20.10 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   PROCEDURE [dbo].[CompanyWise_Tax_DataDeletion]
@CompanyId Int

AS
BEGIN

DECLARE @CompanyInfo TABLE (Id Int, RegistrationNo Nvarchar(150), Name Nvarchar(500))

INSERT INTO @CompanyInfo
SELECT Id,RegistrationNo,Name FROM Common.Company WHERE Id = @CompanyId
UNION ALL
SELECT Id,RegistrationNo,Name FROM Common.Company WHERE ParentId = @CompanyId

----------------------==================================================================================================================================================================================================
----------------------/////////////////////////////////////////////////////////////////////////////// TAX \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
-----------------------==================================================================================================================================================================================================

-----------------------/////////////////////////////////////////////////////////////////////////////// Tax.AccountPolicy \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

DELETE FROM Tax.AccountPolicyDetail WHERE MasterId IN
(
SELECT Id FROM Tax.AccountPolicy WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)

DELETE FROM Tax.AccountPolicy WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)

-----------------------/////////////////////////////////////////////////////////////////////////////// Tax.CheckListMaster \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

DELETE FROM Tax.CheckListMaster WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)

-----------------------/////////////////////////////////////////////////////////////////////////////// Tax.Classification \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

DELETE FROM Tax.CategoryDetails WHERE ClassificationCategoryId IN
(
SELECT Id FROM Tax.ClassificationCategories WHERE ClassificationId IN
(
SELECT Id FROM Tax.Classification WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)

DELETE FROM Tax.ClassificationCategories WHERE ClassificationId IN
(
SELECT Id FROM Tax.Classification WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)

--------------------SELECT * FROM Tax.PlanningMaterialityClassification_ToBeDeleted -------> No Data in Table

--------------------SELECT * FROM Tax.PlanningMaterialityDetailClassification_ToBeDeleted -------> No Data in Table

DELETE FROM Tax.Classification WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)

-----------------------/////////////////////////////////////////////////////////////////////////////// Tax.Donation \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

DELETE FROM Tax.Donation WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)

-----------------------/////////////////////////////////////////////////////////////////////////////// Tax.EngagementTypeMenuMapping \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

--------------------SELECT * FROM Tax.EngagementTypeMenuMapping WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo) ------> No Data in Table

-----------------------/////////////////////////////////////////////////////////////////////////////// Tax.EngagementVisitedHistory \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

----------------------SELECT * FROM Tax.EngagementVisitedHistory WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo) ------> No Data in Table

----------------------/////////////////////////////////////////////////////////////////////////////// Tax.Exemption \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

DELETE FROM Tax.ExemptionDetails WHERE ExemptionId IN
(
SELECT Id FROM Tax.Exemption WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)

DELETE FROM Tax.Exemption WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)

----------------------/////////////////////////////////////////////////////////////////////////////// Tax.FormMaster \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

DELETE FROM Tax.FormDetail WHERE FormMasterId IN
(
SELECT Id FROM Tax.FormMaster WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)

DELETE FROM Tax.FormMaster WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)

----------------------/////////////////////////////////////////////////////////////////////////////// Tax.GeneralLedgerImport \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

--------------------SELECT * FROM Tax.GeneralLedgerImport WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo) ------> No Data in Table

----------------------/////////////////////////////////////////////////////////////////////////////// Tax.IPCMultipliers \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

DELETE FROM Tax.IPCMultipliers WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)

----------------------/////////////////////////////////////////////////////////////////////////////// Tax.MedicalExpenses \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

DELETE FROM Tax.MedicalExpenseDetails WHERE MedicalExpensesId IN
(
SELECT Id FROM Tax.MedicalExpenses WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)

DELETE FROM Tax.MedicalExpenses WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)

----------------------/////////////////////////////////////////////////////////////////////////////// Tax.MenuSetUpMaster \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

DELETE FROM Tax.MenuSetUpMaster WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)

----------------------/////////////////////////////////////////////////////////////////////////////// Tax.MonthlyForeignExchange \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

DELETE FROM Tax.MonthlyForeignExchange WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)

----------------------/////////////////////////////////////////////////////////////////////////////// Tax.Nature \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

DELETE FROM Tax.FurtherDeductionDetail WHERE NatureId IN
(
SELECT Id FROM Tax.Nature WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)

DELETE FROM Tax.NonTradeIncomeDetail WHERE NatureId IN
(
SELECT Id FROM Tax.Nature WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)

DELETE FROM Tax.Nature WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)

----------------------/////////////////////////////////////////////////////////////////////////////// Tax.PlanningAndCompletionSetUp \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

DELETE FROM Tax.ClientAndEngagementIndependenceConfirmation WHERE PlanningAndCompletionSetUpId IN
(
SELECT Id FROM Tax.PlanningAndCompletionSetUp WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)

DELETE FROM Tax.DirectorRemunerationDetails WHERE DirectorRemunerationId IN
(
SELECT Id FROM Tax.DirectorRemuneration WHERE PlanningAndCompletionSetUpId IN
(
SELECT Id FROM Tax.PlanningAndCompletionSetUp WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)

DELETE FROM Tax.DirectorRemuneration WHERE PlanningAndCompletionSetUpId IN
(
SELECT Id FROM Tax.PlanningAndCompletionSetUp WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)

DELETE FROM Tax.PAndCSectionQuestions WHERE PAndCSectionId IN
(
SELECT Id FROM Tax.PAndCSections WHERE PlanningAndCompletionSetUpId IN
(
SELECT Id FROM Tax.PlanningAndCompletionSetUp WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)

DELETE FROM Tax.PAndCSections WHERE PlanningAndCompletionSetUpId IN
(
SELECT Id FROM Tax.PlanningAndCompletionSetUp WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)

DELETE FROM Tax.PlanningAndCompletionSetUp WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)

----------------------/////////////////////////////////////////////////////////////////////////////// Tax.PlanningAndCompletionSetUpMaster \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

DELETE FROM Tax.PlanningAndCompletionSetUp WHERE MasterId IN
(
SELECT Id FROM Tax.PlanningAndCompletionSetUpMaster WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)

DELETE FROM Tax.PlanningAndCompletionSetUpMaster WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)

----------------------/////////////////////////////////////////////////////////////////////////////// Tax.PlanningMateriality_ToBeDeleted \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

----------------------SELECT * FROM Tax.PlanningMateriality_ToBeDeleted WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo) ------> No Data in Table

----------------------/////////////////////////////////////////////////////////////////////////////// Tax.PlanningMaterialitySetup_ToBeDeleted \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

----------------------SELECT * FROM Tax.PlanningMaterialitySetup_ToBeDeleted WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo) ------> No Data in Table

----------------------/////////////////////////////////////////////////////////////////////////////// Tax.Rebates \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

DELETE FROM Tax.Rebates WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)

----------------------/////////////////////////////////////////////////////////////////////////////// Tax.Section14QSetUp \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

DELETE FROM Tax.Section14QSetUp WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)

----------------------/////////////////////////////////////////////////////////////////////////////// Tax.SectionA \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

DELETE FROM Tax.Disposal WHERE SectionAId IN
(
SELECT Id FROM Tax.SectionA WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)

DELETE FROM Tax.Section14QAdditions WHERE SectionAId IN
(
SELECT Id FROM Tax.SectionA WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)

DELETE FROM Tax.SectionADetail WHERE SECTIONAId IN
(
SELECT Id FROM Tax.SectionA WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)

DELETE FROM Tax.SectionB WHERE SECTIONAId IN
(
SELECT Id FROM Tax.SectionA WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)

DELETE FROM Tax.SectionA WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)

----------------------/////////////////////////////////////////////////////////////////////////////// Tax.TaxClassificationMaster \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

DELETE FROM Tax.TaxClassificationMaster WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)

----------------------/////////////////////////////////////////////////////////////////////////////// Tax.TaxCompany \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

DELETE FROM Tax.EngagementVisitedHistory WHERE TaxCompanyId IN
(
SELECT Id FROM Tax.TaxCompany WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)

DELETE FROM Tax.ClientAndEngagementIndependenceConfirmation WHERE PlanningAndCompletionSetUpId IN
(
SELECT Id FROM Tax.PlanningAndCompletionSetUp WHERE TaxCompanyId IN
(
SELECT Id FROM Tax.TaxCompany WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)

DELETE FROM Tax.DirectorRemunerationDetails WHERE DirectorRemunerationId IN
(
SELECT Id FROM Tax.DirectorRemuneration WHERE PlanningAndCompletionSetUpId IN
(
SELECT Id FROM Tax.PlanningAndCompletionSetUp WHERE TaxCompanyId IN
(
SELECT Id FROM Tax.TaxCompany WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)

DELETE FROM Tax.DirectorRemuneration WHERE PlanningAndCompletionSetUpId IN
(
SELECT Id FROM Tax.PlanningAndCompletionSetUp WHERE TaxCompanyId IN
(
SELECT Id FROM Tax.TaxCompany WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)

DELETE FROM Tax.PAndCSectionQuestions WHERE PAndCSectionId IN
(
SELECT Id FROM Tax.PAndCSections WHERE PlanningAndCompletionSetUpId IN
(
SELECT Id FROM Tax.PlanningAndCompletionSetUp WHERE TaxCompanyId IN
(
SELECT Id FROM Tax.TaxCompany WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)

DELETE FROM Tax.PAndCSections WHERE PlanningAndCompletionSetUpId IN
(
SELECT Id FROM Tax.PlanningAndCompletionSetUp WHERE TaxCompanyId IN
(
SELECT Id FROM Tax.TaxCompany WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)

DELETE FROM Tax.PlanningAndCompletionSetUp WHERE TaxCompanyId IN
(
SELECT Id FROM Tax.TaxCompany WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)

------------------SELECT * FROM Tax.PlanningMateriality_ToBeDeleted -----> No Data in Table 

DELETE FROM Tax.DonationReference WHERE ProfitAndLossImportId IN
(
SELECT Id FROM Tax.ProfitAndLossImport WHERE TaxCompanyId IN
(
SELECT Id FROM Tax.TaxCompany WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)

DELETE FROM Tax.FurtherDeductionDetail WHERE ProfitAndLossImportId IN
(
SELECT Id FROM Tax.ProfitAndLossImport WHERE TaxCompanyId IN
(
SELECT Id FROM Tax.TaxCompany WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)

DELETE FROM Tax.NonTradeIncomeDetail WHERE ProfitAndLossImportId IN
(
SELECT Id FROM Tax.ProfitAndLossImport WHERE TaxCompanyId IN
(
SELECT Id FROM Tax.TaxCompany WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)

DELETE FROM Tax.RentalIncomeDetail WHERE ProfitAndLossImportId IN
(
SELECT Id FROM Tax.ProfitAndLossImport WHERE TaxCompanyId IN
(
SELECT Id FROM Tax.TaxCompany WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)

DELETE FROM Tax.Section14QAdditions WHERE ProfitAndLossImportId IN
(
SELECT Id FROM Tax.ProfitAndLossImport WHERE TaxCompanyId IN
(
SELECT Id FROM Tax.TaxCompany WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)

DELETE FROM Tax.StatementA WHERE PandLId IN
(
SELECT Id FROM Tax.ProfitAndLossImport WHERE TaxCompanyId IN
(
SELECT Id FROM Tax.TaxCompany WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)

DELETE FROM Tax.ProfitAndLossImport WHERE TaxCompanyId IN
(
SELECT Id FROM Tax.TaxCompany WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)

DELETE FROM Tax.Disposal WHERE SectionAId IN
(
SELECT Id FROM Tax.SectionA WHERE TaxCompanyId IN
(
SELECT Id FROM Tax.TaxCompany WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)

DELETE FROM Tax.Section14QAdditions WHERE SectionAId IN
(
SELECT Id FROM Tax.SectionA WHERE TaxCompanyId IN
(
SELECT Id FROM Tax.TaxCompany WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)

DELETE FROM Tax.SectionADetail WHERE SECTIONAId IN
(
SELECT Id FROM Tax.SectionA WHERE TaxCompanyId IN
(
SELECT Id FROM Tax.TaxCompany WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)

DELETE FROM Tax.SectionB WHERE SECTIONAId IN
(
SELECT Id FROM Tax.SectionA WHERE TaxCompanyId IN
(
SELECT Id FROM Tax.TaxCompany WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)

DELETE FROM Tax.SectionA WHERE TaxCompanyId IN
(
SELECT Id FROM Tax.TaxCompany WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)

DELETE FROM Tax.ClientAndEngagementIndependenceConfirmation WHERE TaxCompanyContactId IN
(
SELECT Id FROM Tax.TaxCompanyContact WHERE TaxCompanyId IN
(
SELECT Id FROM Tax.TaxCompany WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)

DELETE FROM Tax.DirectorRemunerationDetails WHERE DirectorRemunerationId IN
(
SELECT Id FROM Tax.DirectorRemuneration WHERE TaxCompanyContactId IN
(
SELECT Id FROM Tax.TaxCompanyContact WHERE TaxCompanyId IN
(
SELECT Id FROM Tax.TaxCompany WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)

DELETE FROM Tax.DirectorRemuneration WHERE TaxCompanyContactId IN
(
SELECT Id FROM Tax.TaxCompanyContact WHERE TaxCompanyId IN
(
SELECT Id FROM Tax.TaxCompany WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)

DELETE FROM Tax.TaxCompanyContact WHERE TaxCompanyId IN
(
SELECT Id FROM Tax.TaxCompany WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)

DELETE FROM Tax.AccountAnnotation WHERE EngagementId IN
(
SELECT Id FROM Tax.TaxCompanyEngagement WHERE TaxCompanyId IN
(
SELECT Id FROM Tax.TaxCompany WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)

DELETE FROM Tax.AccountPolicyDetail WHERE MasterId IN
(
SELECT Id FROM Tax.AccountPolicy WHERE EngagementId IN
(
SELECT Id FROM Tax.TaxCompanyEngagement WHERE TaxCompanyId IN
(
SELECT Id FROM Tax.TaxCompany WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)

DELETE FROM Tax.AccountPolicy WHERE EngagementId IN
(
SELECT Id FROM Tax.TaxCompanyEngagement WHERE TaxCompanyId IN
(
SELECT Id FROM Tax.TaxCompany WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)

--------------SELECT * FROM Tax.AdjustmentComment_ToBeDeleted ------> No Data in Table 

DELETE FROM Tax.AdjustmentFileAttachment WHERE AdjustmentID IN
(
SELECT ID FROM Tax.Adjustment WHERE EngagementID IN
(
SELECT Id FROM Tax.TaxCompanyEngagement WHERE TaxCompanyId IN
(
SELECT Id FROM Tax.TaxCompany WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)

DELETE FROM Tax.AdjustmentStatusHistory WHERE AdjustmentID IN
(
SELECT ID FROM Tax.Adjustment WHERE EngagementID IN
(
SELECT Id FROM Tax.TaxCompanyEngagement WHERE TaxCompanyId IN
(
SELECT Id FROM Tax.TaxCompany WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)

DELETE FROM Tax.FEAnalysisNote WHERE AdjustmentID IN
(
SELECT ID FROM Tax.Adjustment WHERE EngagementID IN
(
SELECT Id FROM Tax.TaxCompanyEngagement WHERE TaxCompanyId IN
(
SELECT Id FROM Tax.TaxCompany WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)

--------------------SELECT * FROM Tax.NoteAdjustment_ToBeDeleted ----> No Data in Table

DELETE FROM Tax.Adjustment WHERE EngagementID IN
(
SELECT Id FROM Tax.TaxCompanyEngagement WHERE TaxCompanyId IN
(
SELECT Id FROM Tax.TaxCompany WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)

DELETE FROM Tax.AdjustmentDOCRepository WHERE EngagementID IN
(
SELECT Id FROM Tax.TaxCompanyEngagement WHERE TaxCompanyId IN
(
SELECT Id FROM Tax.TaxCompany WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)

DELETE FROM Tax.CarryForwardDetail WHERE CarryForwardId IN
(
SELECT Id FROM Tax.CarryForward WHERE EngagementId IN
(
SELECT Id FROM Tax.TaxCompanyEngagement WHERE TaxCompanyId IN
(
SELECT Id FROM Tax.TaxCompany WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)

DELETE FROM Tax.CarryForward WHERE EngagementId IN
(
SELECT Id FROM Tax.TaxCompanyEngagement WHERE TaxCompanyId IN
(
SELECT Id FROM Tax.TaxCompany WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)

DELETE FROM Tax.ClientAndEngagementIndependenceConfirmation WHERE EngagementId IN
(
SELECT Id FROM Tax.TaxCompanyEngagement WHERE TaxCompanyId IN
(
SELECT Id FROM Tax.TaxCompany WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)

DELETE FROM Tax.DirectorRemunerationDetails WHERE DirectorRemunerationId IN
(
SELECT Id FROM Tax.DirectorRemuneration WHERE EngagementId IN
(
SELECT Id FROM Tax.TaxCompanyEngagement WHERE TaxCompanyId IN
(
SELECT Id FROM Tax.TaxCompany WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)

DELETE FROM Tax.DirectorRemuneration WHERE EngagementId IN
(
SELECT Id FROM Tax.TaxCompanyEngagement WHERE TaxCompanyId IN
(
SELECT Id FROM Tax.TaxCompany WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)

DELETE FROM Tax.Donation WHERE EngagementId IN
(
SELECT Id FROM Tax.TaxCompanyEngagement WHERE TaxCompanyId IN
(
SELECT Id FROM Tax.TaxCompany WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)

DELETE FROM Tax.DonationReference WHERE EngagementId IN
(
SELECT Id FROM Tax.TaxCompanyEngagement WHERE TaxCompanyId IN
(
SELECT Id FROM Tax.TaxCompany WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)

DELETE FROM Tax.EngagementPercentage WHERE EngagementId IN
(
SELECT Id FROM Tax.TaxCompanyEngagement WHERE TaxCompanyId IN
(
SELECT Id FROM Tax.TaxCompany WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)

DELETE FROM Tax.EngagementVisitedHistory WHERE EngagementId IN
(
SELECT Id FROM Tax.TaxCompanyEngagement WHERE TaxCompanyId IN
(
SELECT Id FROM Tax.TaxCompany WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
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
SELECT Id FROM Tax.TaxCompany WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
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
SELECT Id FROM Tax.TaxCompany WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
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
SELECT Id FROM Tax.TaxCompany WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
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
SELECT Id FROM Tax.TaxCompany WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
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
SELECT Id FROM Tax.TaxCompany WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
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
SELECT Id FROM Tax.TaxCompany WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
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
SELECT Id FROM Tax.TaxCompany WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
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
SELECT Id FROM Tax.TaxCompany WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
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
SELECT Id FROM Tax.TaxCompany WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
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
SELECT Id FROM Tax.TaxCompany WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)

DELETE FROM Tax.ForeignExchange WHERE EngagementID IN
(
SELECT Id FROM Tax.TaxCompanyEngagement WHERE TaxCompanyId IN
(
SELECT Id FROM Tax.TaxCompany WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)

DELETE FROM Tax.FormDetail WHERE FormMasterId IN
(
SELECT Id FROM Tax.FormMaster WHERE EngagementId IN
(
SELECT Id FROM Tax.TaxCompanyEngagement WHERE TaxCompanyId IN
(
SELECT Id FROM Tax.TaxCompany WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)

DELETE FROM Tax.FormMaster WHERE EngagementId IN
(
SELECT Id FROM Tax.TaxCompanyEngagement WHERE TaxCompanyId IN
(
SELECT Id FROM Tax.TaxCompany WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)

DELETE FROM Tax.FurtherDeductionDetail WHERE FurtherDeductionId IN
(
SELECT Id FROM Tax.FurtherDeduction WHERE EngagementId IN
(
SELECT Id FROM Tax.TaxCompanyEngagement WHERE TaxCompanyId IN
(
SELECT Id FROM Tax.TaxCompany WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)

DELETE FROM Tax.FurtherDeduction WHERE EngagementId IN
(
SELECT Id FROM Tax.TaxCompanyEngagement WHERE TaxCompanyId IN
(
SELECT Id FROM Tax.TaxCompany WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
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
SELECT Id FROM Tax.TaxCompany WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
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
SELECT Id FROM Tax.TaxCompany WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)

DELETE FROM Tax.GeneralLedgerFileDetails WHERE EngagementId IN
(
SELECT Id FROM Tax.TaxCompanyEngagement WHERE TaxCompanyId IN
(
SELECT Id FROM Tax.TaxCompany WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)

DELETE FROM Tax.GeneralLedgerDetail WHERE GeneralLedgerId IN
(
SELECT Id FROM Tax.GeneralLedgerImport WHERE EngagementId IN
(
SELECT Id FROM Tax.TaxCompanyEngagement WHERE TaxCompanyId IN
(
SELECT Id FROM Tax.TaxCompany WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)

DELETE FROM Tax.GeneralLedgerImport WHERE EngagementId IN
(
SELECT Id FROM Tax.TaxCompanyEngagement WHERE TaxCompanyId IN
(
SELECT Id FROM Tax.TaxCompany WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)

DELETE FROM Tax.InterestExpenses WHERE InterestRestrictionId IN
(
SELECT ID FROM Tax.InterestRestriction WHERE EngagementId IN
(
SELECT Id FROM Tax.TaxCompanyEngagement WHERE TaxCompanyId IN
(
SELECT Id FROM Tax.TaxCompany WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)

DELETE FROM Tax.InvestmentSchedule WHERE InterestRestrictionId IN
(
SELECT ID FROM Tax.InterestRestriction WHERE EngagementId IN
(
SELECT Id FROM Tax.TaxCompanyEngagement WHERE TaxCompanyId IN
(
SELECT Id FROM Tax.TaxCompany WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)

DELETE FROM Tax.InterestRestriction WHERE EngagementId IN
(
SELECT Id FROM Tax.TaxCompanyEngagement WHERE TaxCompanyId IN
(
SELECT Id FROM Tax.TaxCompany WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)

DELETE FROM Tax.MedicalExpenseDetails WHERE MedicalExpensesId IN
(
SELECT Id FROM Tax.MedicalExpenses WHERE EngagementId IN
(
SELECT Id FROM Tax.TaxCompanyEngagement WHERE TaxCompanyId IN
(
SELECT Id FROM Tax.TaxCompany WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)

DELETE FROM Tax.MedicalExpenses WHERE EngagementId IN
(
SELECT Id FROM Tax.TaxCompanyEngagement WHERE TaxCompanyId IN
(
SELECT Id FROM Tax.TaxCompany WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)

DELETE FROM Tax.NonTradeIncomeDetail WHERE NonTradeIncomeId IN
(
SELECT Id FROM Tax.NonTradeIncome WHERE EngagementId IN
(
SELECT Id FROM Tax.TaxCompanyEngagement WHERE TaxCompanyId IN
(
SELECT Id FROM Tax.TaxCompany WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)

DELETE FROM Tax.NonTradeIncome WHERE EngagementId IN
(
SELECT Id FROM Tax.TaxCompanyEngagement WHERE TaxCompanyId IN
(
SELECT Id FROM Tax.TaxCompany WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)

DELETE FROM Tax.PIC WHERE EngagementID IN
(
SELECT Id FROM Tax.TaxCompanyEngagement WHERE TaxCompanyId IN
(
SELECT Id FROM Tax.TaxCompany WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)

DELETE FROM Tax.ClientAndEngagementIndependenceConfirmation WHERE PlanningAndCompletionSetUpId IN
(
SELECT Id FROM Tax.PlanningAndCompletionSetUp WHERE EngagementId IN
(
SELECT Id FROM Tax.TaxCompanyEngagement WHERE TaxCompanyId IN
(
SELECT Id FROM Tax.TaxCompany WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
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
SELECT Id FROM Tax.TaxCompany WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
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
SELECT Id FROM Tax.TaxCompany WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
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
SELECT Id FROM Tax.TaxCompany WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
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
SELECT Id FROM Tax.TaxCompany WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)

DELETE FROM Tax.PlanningAndCompletionSetUp WHERE EngagementId IN
(
SELECT Id FROM Tax.TaxCompanyEngagement WHERE TaxCompanyId IN
(
SELECT Id FROM Tax.TaxCompany WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
--------------------SELECT * FROM Tax.PlanningMateriality_ToBeDeleted ----> No Data in Table

--------------------SELECT * FROM Tax.PlanningMaterialityDetailClassification_ToBeDeleted ----> No Data in Table

DELETE FROM Tax.ProfitAndLossAuditTrail WHERE EngagementID IN
(
SELECT Id FROM Tax.TaxCompanyEngagement WHERE TaxCompanyId IN
(
SELECT Id FROM Tax.TaxCompany WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)

DELETE FROM Tax.ProfitAndLossFileDetails WHERE EngagementId IN
(
SELECT Id FROM Tax.TaxCompanyEngagement WHERE TaxCompanyId IN
(
SELECT Id FROM Tax.TaxCompany WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)

DELETE FROM Tax.DonationReference WHERE ProfitAndLossImportId IN
(
SELECT Id FROM Tax.ProfitAndLossImport WHERE EngagementId IN
(
SELECT Id FROM Tax.TaxCompanyEngagement WHERE TaxCompanyId IN
(
SELECT Id FROM Tax.TaxCompany WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)

DELETE FROM Tax.FurtherDeductionDetail WHERE ProfitAndLossImportId IN
(
SELECT Id FROM Tax.ProfitAndLossImport WHERE EngagementId IN
(
SELECT Id FROM Tax.TaxCompanyEngagement WHERE TaxCompanyId IN
(
SELECT Id FROM Tax.TaxCompany WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)

DELETE FROM Tax.NonTradeIncomeDetail WHERE ProfitAndLossImportId IN
(
SELECT Id FROM Tax.ProfitAndLossImport WHERE EngagementId IN
(
SELECT Id FROM Tax.TaxCompanyEngagement WHERE TaxCompanyId IN
(
SELECT Id FROM Tax.TaxCompany WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)

DELETE FROM Tax.RentalIncomeDetail WHERE ProfitAndLossImportId IN
(
SELECT Id FROM Tax.ProfitAndLossImport WHERE EngagementId IN
(
SELECT Id FROM Tax.TaxCompanyEngagement WHERE TaxCompanyId IN
(
SELECT Id FROM Tax.TaxCompany WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)

DELETE FROM Tax.Section14QAdditions WHERE ProfitAndLossImportId IN
(
SELECT Id FROM Tax.ProfitAndLossImport WHERE EngagementId IN
(
SELECT Id FROM Tax.TaxCompanyEngagement WHERE TaxCompanyId IN
(
SELECT Id FROM Tax.TaxCompany WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)

DELETE FROM Tax.StatementA WHERE PandLId IN
(
SELECT Id FROM Tax.ProfitAndLossImport WHERE EngagementId IN
(
SELECT Id FROM Tax.TaxCompanyEngagement WHERE TaxCompanyId IN
(
SELECT Id FROM Tax.TaxCompany WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)

DELETE FROM Tax.ProfitAndLossImport WHERE EngagementId IN
(
SELECT Id FROM Tax.TaxCompanyEngagement WHERE TaxCompanyId IN
(
SELECT Id FROM Tax.TaxCompany WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)

DELETE FROM Tax.ProfitAndLossTickmark WHERE EngagementID IN
(
SELECT Id FROM Tax.TaxCompanyEngagement WHERE TaxCompanyId IN
(
SELECT Id FROM Tax.TaxCompany WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)

DELETE FROM Tax.RentalIncomeDetail WHERE RentalIncomeId IN
(
SELECT Id FROM Tax.RentalIncome WHERE EngagementID IN
(
SELECT Id FROM Tax.TaxCompanyEngagement WHERE TaxCompanyId IN
(
SELECT Id FROM Tax.TaxCompany WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)

DELETE FROM Tax.RentalIncome WHERE EngagementID IN
(
SELECT Id FROM Tax.TaxCompanyEngagement WHERE TaxCompanyId IN
(
SELECT Id FROM Tax.TaxCompany WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)

DELETE FROM Tax.RollForward WHERE OldEngagementId IN
(
SELECT Id FROM Tax.TaxCompanyEngagement WHERE TaxCompanyId IN
(
SELECT Id FROM Tax.TaxCompany WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)

----------------SELECT * FROM Tax.Schedule_ToBeDeleted ----> No data in Table

DELETE FROM Tax.Section14QAdditions WHERE Section14QId IN
(
SELECT Id FROM Tax.Section14Q WHERE EngagementId IN
(
SELECT Id FROM Tax.TaxCompanyEngagement WHERE TaxCompanyId IN
(
SELECT Id FROM Tax.TaxCompany WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)

DELETE FROM Tax.Section14QDetails WHERE Section14QId IN
(
SELECT Id FROM Tax.Section14Q WHERE EngagementId IN
(
SELECT Id FROM Tax.TaxCompanyEngagement WHERE TaxCompanyId IN
(
SELECT Id FROM Tax.TaxCompany WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)

DELETE FROM Tax.Section14QEligibleExp WHERE Section14QId IN
(
SELECT Id FROM Tax.Section14Q WHERE EngagementId IN
(
SELECT Id FROM Tax.TaxCompanyEngagement WHERE TaxCompanyId IN
(
SELECT Id FROM Tax.TaxCompany WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)

DELETE FROM Tax.Section14Q WHERE EngagementId IN
(
SELECT Id FROM Tax.TaxCompanyEngagement WHERE TaxCompanyId IN
(
SELECT Id FROM Tax.TaxCompany WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)

DELETE FROM Tax.Disposal WHERE SectionAId IN
(
SELECT Id FROM Tax.SectionA WHERE EngagementId IN
(
SELECT Id FROM Tax.TaxCompanyEngagement WHERE TaxCompanyId IN
(
SELECT Id FROM Tax.TaxCompany WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)

DELETE FROM Tax.Section14QAdditions WHERE SectionAId IN
(
SELECT Id FROM Tax.SectionA WHERE EngagementId IN
(
SELECT Id FROM Tax.TaxCompanyEngagement WHERE TaxCompanyId IN
(
SELECT Id FROM Tax.TaxCompany WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)

DELETE FROM Tax.SectionADetail WHERE SECTIONAId IN
(
SELECT Id FROM Tax.SectionA WHERE EngagementId IN
(
SELECT Id FROM Tax.TaxCompanyEngagement WHERE TaxCompanyId IN
(
SELECT Id FROM Tax.TaxCompany WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)

DELETE FROM Tax.SectionB WHERE SECTIONAId IN
(
SELECT Id FROM Tax.SectionA WHERE EngagementId IN
(
SELECT Id FROM Tax.TaxCompanyEngagement WHERE TaxCompanyId IN
(
SELECT Id FROM Tax.TaxCompany WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)

DELETE FROM Tax.SectionA WHERE EngagementId IN
(
SELECT Id FROM Tax.TaxCompanyEngagement WHERE TaxCompanyId IN
(
SELECT Id FROM Tax.TaxCompany WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)

DELETE FROM Tax.StatementA WHERE EngagementId IN
(
SELECT Id FROM Tax.TaxCompanyEngagement WHERE TaxCompanyId IN
(
SELECT Id FROM Tax.TaxCompany WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)

DELETE FROM Tax.SubCategory WHERE EngagementId IN
(
SELECT Id FROM Tax.TaxCompanyEngagement WHERE TaxCompanyId IN
(
SELECT Id FROM Tax.TaxCompany WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)

DELETE FROM Tax.TaxAuditTrail WHERE EngagementId IN
(
SELECT Id FROM Tax.TaxCompanyEngagement WHERE TaxCompanyId IN
(
SELECT Id FROM Tax.TaxCompany WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)

DELETE FROM Tax.TaxCompanyEngagementDetails WHERE TaxCompanyEngagementId IN
(
SELECT Id FROM Tax.TaxCompanyEngagement WHERE TaxCompanyId IN
(
SELECT Id FROM Tax.TaxCompany WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)

DELETE FROM Tax.TaxMenuPermissions WHERE TaxCompanyMenuMasterId IN
(
SELECT Id FROM Tax.TaxCompanyMenuMaster WHERE EngagementId IN
(
SELECT Id FROM Tax.TaxCompanyEngagement WHERE TaxCompanyId IN
(
SELECT Id FROM Tax.TaxCompany WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)

DELETE FROM Tax.TaxCompanyMenuMaster WHERE EngagementId IN
(
SELECT Id FROM Tax.TaxCompanyEngagement WHERE TaxCompanyId IN
(
SELECT Id FROM Tax.TaxCompany WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)

DELETE FROM Tax.TaxMenu WHERE EngagementId IN
(
SELECT Id FROM Tax.TaxCompanyEngagement WHERE TaxCompanyId IN
(
SELECT Id FROM Tax.TaxCompany WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)

DELETE FROM Tax.TemplateVariable WHERE EngagementId IN
(
SELECT Id FROM Tax.TaxCompanyEngagement WHERE TaxCompanyId IN
(
SELECT Id FROM Tax.TaxCompany WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)

DELETE FROM Tax.UserApproval WHERE EngagementId IN
(
SELECT Id FROM Tax.TaxCompanyEngagement WHERE TaxCompanyId IN
(
SELECT Id FROM Tax.TaxCompany WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)

DELETE FROM Tax.TaxCompanyEngagement WHERE TaxCompanyId IN
(
SELECT Id FROM Tax.TaxCompany WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)

DELETE FROM Tax.TaxMenu WHERE TaxCompanyId  IN
(
SELECT Id FROM Tax.TaxCompany WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)

DELETE FROM Tax.TaxCompany WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)

----------------------/////////////////////////////////////////////////////////////////////////////// Tax.TaxManual \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

DELETE FROM Tax.MenuSetUpMaster WHERE TaxManualId IN
(
SELECT Id FROM Tax.TaxManual WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)

DELETE FROM Tax.PlanningAndCompletionSetUpMaster WHERE TaxManualId IN
(
SELECT Id FROM Tax.TaxManual WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)

DELETE FROM Tax.TaxClassificationMaster WHERE TaxManualId IN
(
SELECT Id FROM Tax.TaxManual WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
) 

DELETE FROM Tax.TaxManual WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)

----------------------/////////////////////////////////////////////////////////////////////////////// Tax.TaxMenu \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

----------------------SELECT * FROM Tax.TaxMenu WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo) ------> No Data in Table

----------------------/////////////////////////////////////////////////////////////////////////////// Tax.TaxPermission \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

------------------------SELECT * FROM Tax.TaxPermission WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo) ------> No Data in Table

----------------------/////////////////////////////////////////////////////////////////////////////// Tax.TaxRole \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

------------------------SELECT * FROM Tax.TaxRole WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo) ------> No Data in Table

----------------------/////////////////////////////////////////////////////////////////////////////// Tax.TaxRolePermission \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

------------------------SELECT * FROM Tax.TaxRolePermission WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo) ------> No Data in Table

----------------------/////////////////////////////////////////////////////////////////////////////// Tax.Template \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

DELETE FROM Tax.Template WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)

----------------------/////////////////////////////////////////////////////////////////////////////// Tax.TemplateVariable \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

DELETE FROM Tax.TemplateVariable WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)

----------------------/////////////////////////////////////////////////////////////////////////////// Tax.TickMarkSetup \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

------------------------SELECT * FROM Tax.TickMarkSetup WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo) ------> No Data in Table

----------------------/////////////////////////////////////////////////////////////////////////////// Tax.WPSetup \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

------------------------SELECT * FROM Tax.WPSetup WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo) ------> No Data in Table
 
----------------------/////////////////////////////////////////////////////////////////////////////// Widget.Activity \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

----------------------SELECT * FROM Widget.Activity WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo) ------> No Data in Table

----------------------/////////////////////////////////////////////////////////////////////////////// Widget.ActivityRelatedToMetadata \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

----------------------SELECT * FROM Widget.ActivityRelatedToMetadata WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo) ------> No Data in Table

----------------------/////////////////////////////////////////////////////////////////////////////// Widget.ActivityTypea \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

----------------------SELECT * FROM Widget.ActivityType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo) ------> No Data in Table

----------------------/////////////////////////////////////////////////////////////////////////////// Widget.GridLayout \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

----------------------SELECT * FROM Widget.GridLayout WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo) ------> No Data in Table

----------------------/////////////////////////////////////////////////////////////////////////////// Widget.NotesMaster \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

----------------------SELECT * FROM Widget.NotesMaster WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo) ------> No Data in Table

----------------------/////////////////////////////////////////////////////////////////////////////// Widget.RelatedLinksMaster \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

DELETE FROM Widget.RelatedLinksDetail WHERE MasterId IN
(
SELECT Id FROM Widget.RelatedLinksMaster WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)

DELETE FROM Widget.RelatedLinksMaster WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)

----------------------/////////////////////////////////////////////////////////////////////////////// Widget.RelatedLinksMaster \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

----------------------SELECT * FROM Widget.TodoMaster ------> No Data in Table

END
GO
