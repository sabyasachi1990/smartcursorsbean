USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[Audit_SelectstmtSP]    Script Date: 16-12-2024 9.20.10 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE Procedure [dbo].[Audit_SelectstmtSP]
As 
BEgin

Select Count(*),'Audit.AccountPolicyDetail' From Audit.AccountPolicyDetail As APD
Inner Join Audit.AccountPolicy As AP On AP.Id=APD.MasterId
Where AP.CompanyId in (0,1,10,12,19,136,138,172,239,242,256,258,261)
 

Select Count(*),'Audit.Adjustment' From Audit.Adjustment As A 
Inner Join Audit.AuditCompanyEngagement As ACE On ACE.Id=A.EngagementID
Inner Join Audit.AuditCompany As AC On AC.id=ACE.AuditCompanyId
Where AC.CompanyId in (0,1,10,12,19,136,138,172,239,242,256,258,261)

Select Count(*) From Audit.AdjustmentAccount As AA
Inner Join Audit.Adjustment As A On A.Id=AA.AdjustmentID
Inner Join Audit.AuditCompanyEngagement As ACE On ACE.Id=A.EngagementID
Inner Join Audit.AuditCompany As AC1 On AC1.Id=ACE.AuditCompanyId
Where AC1.Companyid in (0,1,10,12,19,136,138,172,239,242,256,258,261)

Select Count(*),'Audit.AdjustmentAccountLeadsheet' From Audit.AdjustmentAccountLeadsheet As AAL
Inner Join Audit.AdjustmentAccount As AC On AC.ID=AAL.AccountID
Inner Join Audit.Adjustment As A On A.ID=AC.AdjustmentID
Inner Join Audit.AuditCompanyEngagement As ACE On ACE.Id=A.EngagementID
Inner Join Audit.AuditCompany As AC1 On AC1.ID=ACE.AuditCompanyId
Where AC1.Companyid in (0,1,10,12,19,136,138,172,239,242,256,258,261)

Select Count(*),'Audit.AdjustmentComment' From Audit.AdjustmentComment As AC
Inner Join Audit.Adjustment As A On A.Id=AC.AdjustmentID
Inner Join Audit.AuditCompanyEngagement As ACE On ACE.Id=A.EngagementID
Inner Join Audit.AuditCompany As AC1 On AC1.Id=ACE.AuditCompanyId
Where AC1.Companyid in (0,1,10,12,19,136,138,172,239,242,256,258,261)

Select Count(*),'Audit.AdjustmentDOCRepository' From Audit.AdjustmentDOCRepository As ADR
Inner Join Audit.AuditCompanyEngagement As ACE On ACE.Id=ADR.EngagementID
Inner Join Audit.AuditCompany As AC1 On AC1.ID=ACE.AuditCompanyId
Where AC1.Companyid in (0,1,10,12,19,136,138,172,239,242,256,258,261)

Select Count(*),'Audit.AdjustmentFileAttachment' From Audit.AdjustmentFileAttachment As AFA
Inner Join Audit.Adjustment As A On A.Id=AFA.AdjustmentID
Inner Join Audit.AuditCompanyEngagement As ACE On ACE.Id=A.EngagementID
Inner Join Audit.AuditCompany As AC1 On AC1.Id=ACE.AuditCompanyId
Where AC1.Companyid in (0,1,10,12,19,136,138,172,239,242,256,258,261)

Select Count(*),'Audit.AdjustmentStatusHistory' From Audit.AdjustmentStatusHistory As ASH
Inner Join Audit.Adjustment As A On A.Id=ASH.AdjustmentID
Inner Join Audit.AuditCompanyEngagement As ACE On ACE.Id=A.EngagementID
Inner Join Audit.AuditCompany As AC1 On AC1.Id=ACE.AuditCompanyId
Where AC1.Companyid in (0,1,10,12,19,136,138,172,239,242,256,258,261)

Select Count(*),'Audit.AuditCompanyContact' From Audit.AuditCompanyContact As ACC
Inner Join Audit.AuditCompany As AC1 On AC1.Id=ACC.AuditCompanyId
Where AC1.Companyid in (0,1,10,12,19,136,138,172,239,242,256,258,261)

Select Count(*),'Audit.AuditCompanyEngagement' From Audit.AuditCompanyEngagement As ACE
Inner Join Audit.AuditCompany As AC1 On AC1.Id=ACE.AuditCompanyId
Where AC1.Companyid in (0,1,10,12,19,136,138,172,239,242,256,258,261)

Select Count(*),'Audit.AuditCompanyEngagementDetails' From Audit.AuditCompanyEngagementDetails As ACED
Inner Join Audit.AuditCompanyEngagement As ACE On ACE.Id=ACED.AuditCompanyEngagementId
Inner Join Audit.AuditCompany As AC1 On AC1.Id=ACE.AuditCompanyId
Where AC1.Companyid in (0,1,10,12,19,136,138,172,239,242,256,258,261)

Select Count(*),'Audit.AuditMenuPermissions' From Audit.AuditMenuPermissions As AMP
Inner Join Audit.AuditCompanyMenuMaster As ACMM On ACMM.id=AMP.AuditCompanyMenuMasterId
Inner Join Audit.AuditCompanyEngagement As ACE On Ace.Id=ACMM.EngagementId
Inner Join Audit.AuditCompany As AC On AC.Id=ACE.AuditCompanyId
Where AC.CompanyId In (0,1,10,12,19,136,138,172,239,242,256,258,261)

Select Count(*),'Audit.AuditTypeAuditMenu' From Audit.AuditTypeAuditMenu As AAM
Inner Join Audit.AuditMenuMaster As AM On AM.id=AAM.AuditMenuMasterId
Inner Join Common.ModuleDetail As MD On MD.Id=AM.ModuleDetailId
Where MD.CompanyId In (0,1,10,12,19,136,138,172,239,242,256,258,261)

Select Count(*),'Audit.CashFlowDetail' From Audit.CashFlowDetail As CFD
Inner Join Audit.LeadSheet As LS On LS.Id=CFD.LeadSheetId
Where LS.CompanyId In (0,1,10,12,19,136,138,172,239,242,256,258,261)

Select Count(*),'Audit.CashFlowItem' From Audit.CashFlowItem As CFI
Inner Join Audit.CashFlow  As CF On CF.Id=CFI.CashFlowId
Where CF.CompanyId In (0,1,10,12,19,136,138,172,239,242,256,258,261)

Select Count(*),'Audit.CashFlowItemDetail' From Audit.CashFlowItemDetail As CFID
Inner Join Audit.LeadSheet As LS On LS.Id=CFID.LeadSheetId
Where LS.CompanyId In (0,1,10,12,19,136,138,172,239,242,256,258,261)

Select Count(*),'Audit.Category' From Audit.Category As C
Inner Join Audit.AuditCompanyEngagement As ACE On Ace.Id=C.EngagementId
Inner Join Audit.AuditCompany As AC On AC.Id=ACE.AuditCompanyId
Where AC.CompanyId In (0,1,10,12,19,136,138,172,239,242,256,258,261)

Select Count(*),'Audit.ClientAndEngagementIndependenceConfirmation' From Audit.ClientAndEngagementIndependenceConfirmation As CEIC
Inner Join Audit.AuditCompanyEngagement As ACE On Ace.Id=CEIC.EngagementId
Inner Join Audit.AuditCompany As AC On AC.Id=ACE.AuditCompanyId
Where AC.CompanyId In (0,1,10,12,19,136,138,172,239,242,256,258,261)

Select Count(*),'Audit.CommentReplyTable' From Audit.CommentReplyTable As CRT

Select Count(*),'Audit.CommentTable' From Audit.CommentTable As CT

Select Count(*),'Audit.DeclarationOfDirectors' From Audit.DeclarationOfDirectors As DOD
Inner Join Audit.AuditCompanyEngagement As ACE On Ace.Id=DOD.EngagementId
Inner Join Audit.AuditCompany As AC On AC.Id=ACE.AuditCompanyId
Where AC.CompanyId In (0,1,10,12,19,136,138,172,239,242,256,258,261)

Select Count(*),'Audit.DirectorRemuneration' From Audit.DirectorRemuneration As DR
Inner Join Audit.AuditCompanyEngagement As ACE On Ace.Id=DR.EngagementId
Inner Join Audit.AuditCompany As AC On AC.Id=ACE.AuditCompanyId
Where AC.CompanyId In (0,1,10,12,19,136,138,172,239,242,256,258,261)

Select Count(*),'Audit.DirectorRemunerationDetails' From Audit.DirectorRemunerationDetails As DRD
Inner Join Audit.DirectorRemuneration As DR On DR.Id=DRD.DirectorRemunerationId
Inner Join Audit.AuditCompanyEngagement As ACE On Ace.Id=DR.EngagementId
Inner Join Audit.AuditCompany As AC On AC.Id=ACE.AuditCompanyId
Where AC.CompanyId In (0,1,10,12,19,136,138,172,239,242,256,258,261)

Select Count(*),'Audit.DisclosureDetails' From Audit.DisclosureDetails As DD
Inner Join Audit.Disclosure As D On D.id=DD.DisclosureId
Where D.CompanyID in (0,1,10,12,19,136,138,172,239,242,256,258,261)

Select Count(*),'Audit.DisclosureSections' From Audit.DisclosureSections As DS
Inner Join Audit.Disclosure As D On D.id=DS.DisclosureId
Where D.CompanyID in (0,1,10,12,19,136,138,172,239,242,256,258,261)

Select Count(*),'Audit.Equity' From Audit.Equity As E
Inner Join Audit.AuditCompanyEngagement As ACE On Ace.Id=E.EngagementId
Inner Join Audit.AuditCompany As AC On AC.Id=ACE.AuditCompanyId
Where AC.CompanyId In (0,1,10,12,19,136,138,172,239,242,256,258,261)

Select Count(*),'Audit.FEAnalysis' From Audit.FEAnalysis As FE 
Inner Join Audit.ForeignExchange As FRE On FRE.Id=FE.ForeignExchangeID
Inner Join Audit.AuditCompanyEngagement As ACE On Ace.Id=FRE.EngagementId
Inner Join Audit.AuditCompany As AC On AC.Id=ACE.AuditCompanyId
Where AC.CompanyId In (0,1,10,12,19,136,138,172,239,242,256,258,261)

Select Count(*),'Audit.FEAnalysisComment' From Audit.FEAnalysisComment As FEC

--Select Count(*) From Audit.FEAnalysisCommentReply As FECR
--Inner Join Audit.FEAnalysisComment As FEC

Select Count(*),'Audit.FEAnalysisCountryCurrency' From Audit.FEAnalysisCountryCurrency As FECC
Inner Join Audit.FEAnalysis As FEA On FEA.id=FECC.FEAnalysisID
Inner Join Audit.ForeignExchange As FRE On FRE.Id=FEA.ForeignExchangeID
Inner Join Audit.AuditCompanyEngagement As ACE On Ace.Id=FRE.EngagementId
Inner Join Audit.AuditCompany As AC On AC.Id=ACE.AuditCompanyId
Where AC.CompanyId In (0,1,10,12,19,136,138,172,239,242,256,258,261)

Select Count(*),'Audit.FEAnalysisCurrencyDetails' From Audit.FEAnalysisCurrencyDetails As FECD
Inner Join Audit.FEAnalysisCountryCurrency As FECC On FECC.Id=FECD.CuntryCurrencyID
Inner Join Audit.FEAnalysis As FEA On FEA.id=FECC.FEAnalysisID
Inner Join Audit.ForeignExchange As FRE On FRE.Id=FEA.ForeignExchangeID
Inner Join Audit.AuditCompanyEngagement As ACE On Ace.Id=FRE.EngagementId
Inner Join Audit.AuditCompany As AC On AC.Id=ACE.AuditCompanyId
Where AC.CompanyId In (0,1,10,12,19,136,138,172,239,242,256,258,261)

Select Count(*),'Audit.FEAnalysisLegend' From Audit.FEAnalysisLegend As FEL
Inner Join Audit.FEAnalysis As FEA On FEA.id=FEL.FEAnalysisID
Inner Join Audit.ForeignExchange As FRE On FRE.Id=FEA.ForeignExchangeID
Inner Join Audit.AuditCompanyEngagement As ACE On Ace.Id=FRE.EngagementId
Inner Join Audit.AuditCompany As AC On AC.Id=ACE.AuditCompanyId
Where AC.CompanyId In (0,1,10,12,19,136,138,172,239,242,256,258,261)

Select Count(*),'Audit.FEAnalysisNote' From Audit.FEAnalysisNote As FEN
Inner Join Audit.FEAnalysis As FEA On FEA.id=FEN.FEAnalysisID
Inner Join Audit.ForeignExchange As FRE On FRE.Id=FEA.ForeignExchangeID
Inner Join Audit.AuditCompanyEngagement As ACE On Ace.Id=FRE.EngagementId
Inner Join Audit.AuditCompany As AC On AC.Id=ACE.AuditCompanyId
Where AC.CompanyId In (0,1,10,12,19,136,138,172,239,242,256,258,261)

Select Count(*),'Audit.ForeignCurrencyAnalysis' From Audit.ForeignCurrencyAnalysis As FCA
Inner Join Audit.ForeignExchange As FRE On FRE.Id=FCA.ForeignExchangeID
Inner Join Audit.AuditCompanyEngagement As ACE On Ace.Id=FRE.EngagementId
Inner Join Audit.AuditCompany As AC On AC.Id=ACE.AuditCompanyId
Where AC.CompanyId In (0,1,10,12,19,136,138,172,239,242,256,258,261)

Select Count(*),'Audit.ForeignCurrencyAnalysisFactors' From Audit.ForeignCurrencyAnalysisFactors As FCAC
Inner Join Audit.ForeignCurrencyAnalysis As FCA On FCA.ID=FCAC.FCAnalysisID
Inner Join Audit.ForeignExchange As FRE On FRE.Id=FCA.ForeignExchangeID
Inner Join Audit.AuditCompanyEngagement As ACE On Ace.Id=FRE.EngagementId
Inner Join Audit.AuditCompany As AC On AC.Id=ACE.AuditCompanyId
Where AC.CompanyId In (0,1,10,12,19,136,138,172,239,242,256,258,261)

Select Count(*),'Audit.ForeignExchange' From Audit.ForeignExchange As FE
Inner Join Audit.AuditCompanyEngagement As ACE On Ace.Id=FE.EngagementId
Inner Join Audit.AuditCompany As AC On AC.Id=ACE.AuditCompanyId
Where AC.CompanyId In (0,1,10,12,19,136,138,172,239,242,256,258,261)

Select Count(*),'Audit.FormDetail' From Audit.FormDetail As FD
Inner Join Audit.FormMaster As FM On FM.ID=FD.FormMasterId
Where FM.CompanyId In (0,1,10,12,19,136,138,172,239,242,256,258,261)

Select Count(*),'Audit.GeneralLedgerDetail' From Audit.GeneralLedgerDetail As GLD
Inner Join Audit.GeneralLedgerImport As GLI On GLI.id=GLD.GeneralLedgerId
Where GLI.CompanyId In (0,1,10,12,19,136,138,172,239,242,256,258,261)

Select Count(*),'Audit.GeneralLedgerFileDetails' From Audit.GeneralLedgerFileDetails As GLFD
Inner Join Audit.AuditCompanyEngagement As ACE On ACE.Id=GLFD.EngagementId
Inner Join Audit.AuditCompany As AC On AC.Id=ACE.AuditCompanyId
Where AC.CompanyId In (0,1,10,12,19,136,138,172,239,242,256,258,261)

Select Count(*),'Audit.LeadSheetCategories' From Audit.LeadSheetCategories As LSC 
Inner Join Audit.LeadSheet As LS On LS.Id=LSC.LeadSheetId
Where LS.CompanyId In (0,1,10,12,19,136,138,172,239,242,256,258,261)

--Select Count(*) From Audit.Note As N

Select Count(*),'Audit.NoteAdjustment' From Audit.NoteAdjustment As NAT
Inner Join Audit.Adjustment As A On A.Id=NAT.AdjustmentID
Inner Join Audit.AuditCompanyEngagement As ACE On ACE.Id=A.EngagementID
Inner Join Audit.AuditCompany As AC1 On AC1.Id=ACE.AuditCompanyId
Where AC1.Companyid in (0,1,10,12,19,136,138,172,239,242,256,258,261)

Select Count(*),'Audit.NoteAttachment' From Audit.NoteAttachment

Select Count(*),'Audit.[Order]' From Audit.[Order] As O
Inner Join Audit.AuditCompanyEngagement As ACE On ACE.Id=O.EngagementID
Inner Join Audit.AuditCompany As AC1 On AC1.Id=ACE.AuditCompanyId
Where AC1.Companyid in (0,1,10,12,19,136,138,172,239,242,256,258,261)

Select Count(*),'Audit.PAndCSectionQuestions' From Audit.PAndCSectionQuestions As PSQ
Inner Join Audit.PAndCSections As PS On PS.Id=PSQ.PAndCSectionId
Inner Join Audit.PlanningAndCompletionSetUp As PCS On PCS.Id=PS.PlanningAndCompletionSetUpId
Where PCS.CompanyId in (0,1,10,12,19,136,138,172,239,242,256,258,261)

Select Count(*),'Audit.PAndCSections' From Audit.PAndCSections As PS
Inner Join Audit.PlanningAndCompletionSetUp As PCS On PCS.Id=PS.PlanningAndCompletionSetUpId
Where PCS.CompanyId in (0,1,10,12,19,136,138,172,239,242,256,258,261)

Select Count(*),'Audit.PlanningMaterialityDetail' From Audit.PlanningMaterialityDetail As PMD
Inner Join Audit.PlanningMateriality As PM On PM.Id=PMD.PlanningMeterialityId
Where PM.CompanyId in (0,1,10,12,19,136,138,172,239,242,256,258,261)

Select Count(*),'Audit.PlanningMaterialityDetailLeadSheet' From Audit.PlanningMaterialityDetailLeadSheet As PMDL
Inner Join Audit.PlanningMaterialityDetail As PMD On PMD.Id=PMDL.PlanningMaterialityDetailId
Inner Join Audit.PlanningMateriality As PM On PM.Id=PMD.PlanningMeterialityId
Where PM.CompanyId in (0,1,10,12,19,136,138,172,239,242,256,258,261)

Select Count(*),'Audit.PlanningMaterialityLeadSheet' From Audit.PlanningMaterialityLeadSheet As PML
Inner Join Audit.LeadSheet As LS On LS.Id=PML.LeadSheetId
Where LS.CompanyId In (0,1,10,12,19,136,138,172,239,242,256,258,261)
 
Select Count(*),'Audit.PlanningMaterialitySetupDetail' From Audit.PlanningMaterialitySetupDetail As PMSD
Inner Join Audit.PlanningMaterialitySetup As PMS On PMS.ID=PMSD.PlanningMaterialitySetupId
Where PMS.CompanyId In (0,1,10,12,19,136,138,172,239,242,256,258,261)

Select Count(*),'Audit.Question' From Audit.Question As Q
Inner Join Audit.Questionnaire As QR On Q.Id=Q.QuestionnaireId
Where QR.CompanyId In (0,1,10,12,19,136,138,172,239,242,256,258,261)

Select Count(*),'Audit.SeriLog' From Audit.SeriLog As S

Select Count(*),'Audit.SubCategory' From Audit.SubCategory As SC

Select Count(*),'Audit.TrialBalanceAuditTrail' From Audit.TrialBalanceAuditTrail As TBAT
Inner Join Audit.auditcompanyengagement As ACE On ACE.ID=TBAT.EngagementID
Inner Join Audit.AuditCompany As AC On AC.Id=ACE.AuditCompanyId
Where AC.CompanyId In (0,1,10,12,19,136,138,172,239,242,256,258,261)

Select Count(*),'Audit.TrialBalanceFileDetails' From Audit.TrialBalanceFileDetails As TFD
Inner Join Audit.auditcompanyengagement As ACE On ACE.ID=TFD.EngagementID
Inner Join Audit.AuditCompany As AC On AC.Id=ACE.AuditCompanyId
Where AC.CompanyId In (0,1,10,12,19,136,138,172,239,242,256,258,261)

Select Count(*),'Audit.TrialBalanceImport' From Audit.TrialBalanceImport As TI
Inner Join Audit.AuditCompany As AC On AC.Id=TI.AuditCompanyId
Where AC.CompanyId In (0,1,10,12,19,136,138,172,239,242,256,258,261)

Select Count(*),'Audit.TrialBalanceImportPreferences' From Audit.TrialBalanceImportPreferences

Select Count(*),'Audit.TrialBalanceTickmark' From Audit.TrialBalanceTickmark As TBT
Inner Join Audit.auditcompanyengagement As ACE On ACE.ID=TBT.EngagementID
Inner Join Audit.AuditCompany As AC On AC.Id=ACE.AuditCompanyId
Where AC.CompanyId In (0,1,10,12,19,136,138,172,239,242,256,258,261)

Select Count(*),'Audit.UserApproval' From Audit.UserApproval As UA
Inner Join Audit.auditcompanyengagement As ACE On ACE.ID=UA.EngagementID
Inner Join Audit.AuditCompany As AC On AC.Id=ACE.AuditCompanyId
Where AC.CompanyId In (0,1,10,12,19,136,138,172,239,242,256,258,261)

Select Count(*) From Audit.WPComment

Select Count(*),'Audit.WPCommentReply' From Audit.WPCommentReply As WCR
Inner Join Audit.WPComment As WC On WC.Id=WCR.WPCommentId
inner Join Audit.WPSetupDetail As WSD On WSD.Id=WC.WPCategoryId
Inner Join Audit.WPSetup As WS On WS.Id=WSD.WPSetupId
Where WS.CompanyId In (0,1,10,12,19,136,138,172,239,242,256,258,261)

Select Count(*),'Audit.WPImportFile' From Audit.WPImportFile As WF
inner Join Audit.WPSetupDetail As WSD On WSD.Id=WF.WPCategoryId
Inner Join Audit.WPSetup As WS On WS.Id=WSD.WPSetupId
Where WS.CompanyId In (0,1,10,12,19,136,138,172,239,242,256,258,261)

Select Count(*),'Audit.WPSetupDetail' From Audit.WPSetupDetail As WSD
Inner Join Audit.WPSetup As WS On WS.Id=WSD.WPSetupId
Where WS.CompanyId In (0,1,10,12,19,136,138,172,239,242,256,258,261)

Select Count(*),'Audit.WPSetupTickmark' From Audit.WPSetupTickmark As WST
Inner Join Audit.WPSetup As WS On WS.Id=WST.WPSetupId
Where WS.CompanyId In (0,1,10,12,19,136,138,172,239,242,256,258,261)
Select Count(*),'Audit','AuditCompanyMenuMaster' From Audit.AuditCompanyMenuMaster 
Where CompanyId In (0,1,10,12,19,136,138,172,239,242,256,258,261)

Select Count(*),'Audit','AuditRolePermission' From Audit.AuditRolePermission 
Where CompanyId In (0,1,10,12,19,136,138,172,239,242,256,258,261)

Select Count(*),'Audit','AuditRole' From Audit.AuditRole 
Where CompanyId In (0,1,10,12,19,136,138,172,239,242,256,258,261)

Select Count(*),'Audit','AuditPermission' From Audit.AuditPermission 
Where CompanyId In (0,1,10,12,19,136,138,172,239,242,256,258,261)

Select Count(*),'Audit','AuditMenuMaster' From Audit.AuditMenuMaster 
Where CompanyId In (0,1,10,12,19,136,138,172,239,242,256,258,261)

Select Count(*),'Audit','AccountAnnotation' From Audit.AccountAnnotation 
Where CompanyId In (0,1,10,12,19,136,138,172,239,242,256,258,261)

Select Count(*),'Audit','CashFlow' From Audit.CashFlow 
Where CompanyId In (0,1,10,12,19,136,138,172,239,242,256,258,261)

Select Count(*),'Audit','Questionnaire' From Audit.Questionnaire 
Where CompanyId In (0,1,10,12,19,136,138,172,239,242,256,258,261)

Select Count(*),'Audit','AccountPolicy' From Audit.AccountPolicy 
Where CompanyId In (0,1,10,12,19,136,138,172,239,242,256,258,261)

Select Count(*),'Audit','CashFlowHeadings' From Audit.CashFlowHeadings 
Where CompanyId In (0,1,10,12,19,136,138,172,239,242,256,258,261)

Select Count(*),'Audit','FormMaster' From Audit.FormMaster
 Where CompanyId In (0,1,10,12,19,136,138,172,239,242,256,258,261)

Select Count(*),'Audit','TemplateVariable' From Audit.TemplateVariable
Where CompanyId In (0,1,10,12,19,136,138,172,239,242,256,258,261)

Select Count(*),'Audit','LeadSheet' From Audit.LeadSheet 
Where CompanyId In (0,1,10,12,19,136,138,172,239,242,256,258,261)

Select Count(*),'Audit','Template' From Audit.Template 
Where CompanyId In (0,1,10,12,19,136,138,172,239,242,256,258,261)

Select Count(*),'Audit','AuditCompany' From Audit.AuditCompany 
Where CompanyId In (0,1,10,12,19,136,138,172,239,242,256,258,261)

Select Count(*),'Audit','GeneralLedgerImport' From Audit.GeneralLedgerImport 
Where CompanyId In (0,1,10,12,19,136,138,172,239,242,256,258,261)

Select Count(*),'Audit','PlanningAndCompletionSetUp' From Audit.PlanningAndCompletionSetUp 
Where CompanyId In (0,1,10,12,19,136,138,172,239,242,256,258,261)

Select Count(*),'Audit','Disclosure' From Audit.Disclosure 
Where CompanyId In (0,1,10,12,19,136,138,172,239,242,256,258,261)

Select Count(*),'Audit','WPSetup' From Audit.WPSetup 
Where CompanyId In (0,1,10,12,19,136,138,172,239,242,256,258,261)

Select Count(*),'Audit','PlanningMaterialitySetup' From Audit.PlanningMaterialitySetup 
Where CompanyId In (0,1,10,12,19,136,138,172,239,242,256,258,261)

Select Count(*),'Audit','PlanningMateriality' From Audit.PlanningMateriality 
Where CompanyId In (0,1,10,12,19,136,138,172,239,242,256,258,261)

Select Count(*),'Audit','TickMarkSetup' From Audit.TickMarkSetup 
Where CompanyId In (0,1,10,12,19,136,138,172,239,242,256,258,261)

Select Count(*),'Audit','EngagementVisitedHistory' From Audit.EngagementVisitedHistory 
Where CompanyId In (0,1,10,12,19,136,138,172,239,242,256,258,261)

Select Count(*),'Audit','EngagementTypeMenuMapping' From Audit.EngagementTypeMenuMapping 
Where CompanyId In (0,1,10,12,19,136,138,172,239,242,256,258,261)

Select Count(*),'Audit','AuditMenu' From Audit.AuditMenu 
Where CompanyId In (0,1,10,12,19,136,138,172,239,242,256,258,261)


--SELECT 'Select * From'+' '+TABLE_SCHEMA+'.'+Table_Name+' '+ 'Where' + ' '+ Column_Name +' '+ 'In'+' ' +'(0,1,10,12,19,136,138,172,239,242,256,258,261)' 
--FROM  INFORMATION_SCHEMA.COLUMNS
--WHERE TABLE_SCHEMA = 'Audit'
--AND   COLUMN_NAME = 'CompanyID'

--SELECT TABLE_SCHEMA+'.'+Table_Name
--FROM  INFORMATION_SCHEMA.COLUMNS
--WHERE TABLE_SCHEMA = 'Audit'
--AND   COLUMN_NAME = 'CompanyID'  group by TABLE_SCHEMA+'.'+Table_Name


End


















GO
