USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[SELECT_STMNT_SP_WITHOUTCOMPANYID]    Script Date: 16-12-2024 9.20.11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


-- Exec [dbo].[SELECT_STMNT_SP_WITHOUTCOMPANYID] 

CREATE Procedure [dbo].[SELECT_STMNT_SP_WITHOUTCOMPANYID] 
As
Begin

--//Audit

Select Count(*) As RecordCount,'Audit.AccountPolicyDetail' As TableName From Audit.AccountPolicyDetail As APD
Inner Join Audit.AccountPolicy As AP On AP.Id=APD.MasterId
Where AP.CompanyId In (Select ID From Common.Company Where Id NOT in (589,590,591,592,593,594)) 

Union All  

Select Count(*) As RecordCount,'Audit.Adjustment' As TableName From Audit.Adjustment As A 
Inner Join Audit.AuditCompanyEngagement As ACE On ACE.Id=A.EngagementID
Inner Join Audit.AuditCompany As AC On AC.id=ACE.AuditCompanyId
Where AC.CompanyId In (Select ID From Common.Company Where Id NOT in (589,590,591,592,593,594))

Union All 

Select Count(*) As RecordCount,'Audit.AdjustmentAccount' As TableName From Audit.AdjustmentAccount As AA
Inner Join Audit.Adjustment As A On A.Id=AA.AdjustmentID
Inner Join Audit.AuditCompanyEngagement As ACE On ACE.Id=A.EngagementID
Inner Join Audit.AuditCompany As AC1 On AC1.Id=ACE.AuditCompanyId
Where AC1.Companyid In (Select ID From Common.Company Where Id NOT in (589,590,591,592,593,594))

Union All

Select Count(*) As RecordCount,'Audit.AdjustmentAccountLeadsheet' As TableName From Audit.AdjustmentAccountLeadsheet As AAL
Inner Join Audit.AdjustmentAccount As AC On AC.ID=AAL.AccountID
Inner Join Audit.Adjustment As A On A.ID=AC.AdjustmentID
Inner Join Audit.AuditCompanyEngagement As ACE On ACE.Id=A.EngagementID
Inner Join Audit.AuditCompany As AC1 On AC1.ID=ACE.AuditCompanyId
Where AC1.Companyid In (Select ID From Common.Company Where Id NOT in (589,590,591,592,593,594)) 

Union All

Select Count(*) As RecordCount,'Audit.AdjustmentComment' As TableName From Audit.AdjustmentComment As AC
Inner Join Audit.Adjustment As A On A.Id=AC.AdjustmentID
Inner Join Audit.AuditCompanyEngagement As ACE On ACE.Id=A.EngagementID
Inner Join Audit.AuditCompany As AC1 On AC1.Id=ACE.AuditCompanyId
Where AC1.Companyid In (Select ID From Common.Company Where Id NOT in (589,590,591,592,593,594)) 

Union All

Select Count(*) As RecordCount,'Audit.AdjustmentDOCRepository' As TableName From Audit.AdjustmentDOCRepository As ADR
Inner Join Audit.AuditCompanyEngagement As ACE On ACE.Id=ADR.EngagementID
Inner Join Audit.AuditCompany As AC1 On AC1.ID=ACE.AuditCompanyId
Where AC1.Companyid In (Select ID From Common.Company Where Id NOT in (589,590,591,592,593,594)) 

Union All

Select Count(*) As RecordCount,'Audit.AdjustmentFileAttachment' As TableName From Audit.AdjustmentFileAttachment As AFA
Inner Join Audit.Adjustment As A On A.Id=AFA.AdjustmentID
Inner Join Audit.AuditCompanyEngagement As ACE On ACE.Id=A.EngagementID
Inner Join Audit.AuditCompany As AC1 On AC1.Id=ACE.AuditCompanyId
Where AC1.Companyid In (Select ID From Common.Company Where Id NOT in (589,590,591,592,593,594)) 

Union All

Select Count(*) As RecordCount,'Audit.AdjustmentStatusHistory' As TableName From Audit.AdjustmentStatusHistory As ASH
Inner Join Audit.Adjustment As A On A.Id=ASH.AdjustmentID
Inner Join Audit.AuditCompanyEngagement As ACE On ACE.Id=A.EngagementID
Inner Join Audit.AuditCompany As AC1 On AC1.Id=ACE.AuditCompanyId
Where AC1.Companyid In (Select ID From Common.Company Where Id NOT in (589,590,591,592,593,594)) 

Union All

Select Count(*) As RecordCount,'Audit.AuditCompanyContact' As TableName From Audit.AuditCompanyContact As ACC
Inner Join Audit.AuditCompany As AC1 On AC1.Id=ACC.AuditCompanyId
Where AC1.Companyid In (Select ID From Common.Company Where Id NOT in (589,590,591,592,593,594)) 

Union All

Select Count(*) As RecordCount,'Audit.AuditCompanyEngagement' As TableName From Audit.AuditCompanyEngagement As ACE
Inner Join Audit.AuditCompany As AC1 On AC1.Id=ACE.AuditCompanyId
Where AC1.Companyid In (Select ID From Common.Company Where Id NOT in (589,590,591,592,593,594)) 

Union All

Select Count(*) As RecordCount,'Audit.AuditCompanyEngagementDetails' As TableName From Audit.AuditCompanyEngagementDetails As ACED
Inner Join Audit.AuditCompanyEngagement As ACE On ACE.Id=ACED.AuditCompanyEngagementId
Inner Join Audit.AuditCompany As AC1 On AC1.Id=ACE.AuditCompanyId
Where AC1.Companyid In (Select ID From Common.Company Where Id NOT in (589,590,591,592,593,594)) 

Union All

Select Count(*) As RecordCount,'Audit.AuditMenuPermissions' As TableName From Audit.AuditMenuPermissions As AMP
Inner Join Audit.AuditCompanyMenuMaster As ACMM On ACMM.id=AMP.AuditCompanyMenuMasterId
Inner Join Audit.AuditCompanyEngagement As ACE On Ace.Id=ACMM.EngagementId
Inner Join Audit.AuditCompany As AC On AC.Id=ACE.AuditCompanyId
Where AC.CompanyId In (Select ID From Common.Company Where Id NOT in (589,590,591,592,593,594)) 

Union All

Select Count(*) As RecordCount,'Audit.AuditTypeAuditMenu' As TableName From Audit.AuditTypeAuditMenu As AAM
Inner Join Audit.AuditMenuMaster As AM On AM.id=AAM.AuditMenuMasterId
Inner Join Common.ModuleDetail As MD On MD.Id=AM.ModuleDetailId
Where MD.CompanyId In (Select ID From Common.Company Where Id NOT in (589,590,591,592,593,594)) 

Union All

Select Count(*) As RecordCount,'Audit.CashFlowDetail' As TableName From Audit.CashFlowDetail As CFD
Inner Join Audit.LeadSheet As LS On LS.Id=CFD.LeadSheetId
Where LS.CompanyId In (Select ID From Common.Company Where Id NOT in (589,590,591,592,593,594)) 

Union All

Select Count(*) As RecordCount,'Audit.CashFlowItem' As TableName From Audit.CashFlowItem As CFI
Inner Join Audit.CashFlow  As CF On CF.Id=CFI.CashFlowId
Where CF.CompanyId In (Select ID From Common.Company Where Id NOT in (589,590,591,592,593,594)) 

Union All

Select Count(*) As RecordCount,'Audit.CashFlowItemDetail' As TableName From Audit.CashFlowItemDetail As CFID
Inner Join Audit.LeadSheet As LS On LS.Id=CFID.LeadSheetId
Where LS.CompanyId In (Select ID From Common.Company Where Id NOT in (589,590,591,592,593,594)) 

Union All

Select Count(*) As RecordCount,'Audit.Category' As TableName From Audit.Category As C
Inner Join Audit.AuditCompanyEngagement As ACE On Ace.Id=C.EngagementId
Inner Join Audit.AuditCompany As AC On AC.Id=ACE.AuditCompanyId
Where AC.CompanyId In (Select ID From Common.Company Where Id NOT in (589,590,591,592,593,594)) 

Union All

Select Count(*) As RecordCount,'Audit.ClientAndEngagementIndependenceConfirmation' As TableName From Audit.ClientAndEngagementIndependenceConfirmation As CEIC
Inner Join Audit.AuditCompanyEngagement As ACE On Ace.Id=CEIC.EngagementId
Inner Join Audit.AuditCompany As AC On AC.Id=ACE.AuditCompanyId
Where AC.CompanyId In (Select ID From Common.Company Where Id NOT in (589,590,591,592,593,594)) 

Union All

Select Count(*) As RecordCount,'Audit.CommentReplyTable' As TableName From Audit.CommentReplyTable As CRT

Union All

Select Count(*) As RecordCount,'Audit.CommentTable' As TableName From Audit.CommentTable As CT

Union All

Select Count(*) As RecordCount,'Audit.DeclarationOfDirectors' As TableName From Audit.DeclarationOfDirectors As DOD
Inner Join Audit.AuditCompanyEngagement As ACE On Ace.Id=DOD.EngagementId
Inner Join Audit.AuditCompany As AC On AC.Id=ACE.AuditCompanyId
Where AC.CompanyId In (Select ID From Common.Company Where Id NOT in (589,590,591,592,593,594)) 

Union All

Select Count(*) As RecordCount,'Audit.DirectorRemuneration' As TableName From Audit.DirectorRemuneration As DR
Inner Join Audit.AuditCompanyEngagement As ACE On Ace.Id=DR.EngagementId
Inner Join Audit.AuditCompany As AC On AC.Id=ACE.AuditCompanyId
Where AC.CompanyId In (Select ID From Common.Company Where Id NOT in (589,590,591,592,593,594)) 

Union All

Select Count(*) As RecordCount,'Audit.DirectorRemunerationDetails' As TableName From Audit.DirectorRemunerationDetails As DRD
Inner Join Audit.DirectorRemuneration As DR On DR.Id=DRD.DirectorRemunerationId
Inner Join Audit.AuditCompanyEngagement As ACE On Ace.Id=DR.EngagementId
Inner Join Audit.AuditCompany As AC On AC.Id=ACE.AuditCompanyId
Where AC.CompanyId In (Select ID From Common.Company Where Id NOT in (589,590,591,592,593,594)) 

Union All

Select Count(*) As RecordCount,'Audit.DisclosureDetails' As TableName From Audit.DisclosureDetails As DD
Inner Join Audit.Disclosure As D On D.id=DD.DisclosureId
Where D.CompanyID In (Select ID From Common.Company Where Id NOT in (589,590,591,592,593,594)) 

Union All

Select Count(*) As RecordCount,'Audit.DisclosureSections' As TableName From Audit.DisclosureSections As DS
Inner Join Audit.Disclosure As D On D.id=DS.DisclosureId
Where D.CompanyID In (Select ID From Common.Company Where Id NOT in (589,590,591,592,593,594)) 

Union All

Select Count(*) As RecordCount,'Audit.Equity' As TableName From Audit.Equity As E
Inner Join Audit.AuditCompanyEngagement As ACE On Ace.Id=E.EngagementId
Inner Join Audit.AuditCompany As AC On AC.Id=ACE.AuditCompanyId
Where AC.CompanyId In (Select ID From Common.Company Where Id NOT in (589,590,591,592,593,594)) 

Union All

Select Count(*) As RecordCount,'Audit.FEAnalysis' As TableName From Audit.FEAnalysis As FE 
Inner Join Audit.ForeignExchange As FRE On FRE.Id=FE.ForeignExchangeID
Inner Join Audit.AuditCompanyEngagement As ACE On Ace.Id=FRE.EngagementId
Inner Join Audit.AuditCompany As AC On AC.Id=ACE.AuditCompanyId
Where AC.CompanyId In (Select ID From Common.Company Where Id NOT in (589,590,591,592,593,594)) 

Union All

Select Count(*) As RecordCount,'Audit.FEAnalysisComment' As TableName From Audit.FEAnalysisComment As FEC

Union All

--Select Count(*) As RecordCount As TableName From Audit.FEAnalysisCommentReply As FECR
--Inner Join Audit.FEAnalysisComment As FEC

Select Count(*) As RecordCount,'Audit.FEAnalysisCountryCurrency' As TableName From Audit.FEAnalysisCountryCurrency As FECC
Inner Join Audit.FEAnalysis As FEA On FEA.id=FECC.FEAnalysisID
Inner Join Audit.ForeignExchange As FRE On FRE.Id=FEA.ForeignExchangeID
Inner Join Audit.AuditCompanyEngagement As ACE On Ace.Id=FRE.EngagementId
Inner Join Audit.AuditCompany As AC On AC.Id=ACE.AuditCompanyId
Where AC.CompanyId In (Select ID From Common.Company Where Id NOT in (589,590,591,592,593,594)) 

Union All

Select Count(*) As RecordCount,'Audit.FEAnalysisCurrencyDetails' As TableName From Audit.FEAnalysisCurrencyDetails As FECD
Inner Join Audit.FEAnalysisCountryCurrency As FECC On FECC.Id=FECD.CuntryCurrencyID
Inner Join Audit.FEAnalysis As FEA On FEA.id=FECC.FEAnalysisID
Inner Join Audit.ForeignExchange As FRE On FRE.Id=FEA.ForeignExchangeID
Inner Join Audit.AuditCompanyEngagement As ACE On Ace.Id=FRE.EngagementId
Inner Join Audit.AuditCompany As AC On AC.Id=ACE.AuditCompanyId
Where AC.CompanyId In (Select ID From Common.Company Where Id NOT in (589,590,591,592,593,594)) 

Union All

Select Count(*) As RecordCount,'Audit.FEAnalysisLegend' As TableName From Audit.FEAnalysisLegend As FEL
Inner Join Audit.FEAnalysis As FEA On FEA.id=FEL.FEAnalysisID
Inner Join Audit.ForeignExchange As FRE On FRE.Id=FEA.ForeignExchangeID
Inner Join Audit.AuditCompanyEngagement As ACE On Ace.Id=FRE.EngagementId
Inner Join Audit.AuditCompany As AC On AC.Id=ACE.AuditCompanyId
Where AC.CompanyId In (Select ID From Common.Company Where Id NOT in (589,590,591,592,593,594)) 

Union All

Select Count(*) As RecordCount,'Audit.FEAnalysisNote' As TableName From Audit.FEAnalysisNote As FEN
Inner Join Audit.FEAnalysis As FEA On FEA.id=FEN.FEAnalysisID
Inner Join Audit.ForeignExchange As FRE On FRE.Id=FEA.ForeignExchangeID
Inner Join Audit.AuditCompanyEngagement As ACE On Ace.Id=FRE.EngagementId
Inner Join Audit.AuditCompany As AC On AC.Id=ACE.AuditCompanyId
Where AC.CompanyId In (Select ID From Common.Company Where Id NOT in (589,590,591,592,593,594)) 

Union All

Select Count(*) As RecordCount,'Audit.ForeignCurrencyAnalysis' As TableName From Audit.ForeignCurrencyAnalysis As FCA
Inner Join Audit.ForeignExchange As FRE On FRE.Id=FCA.ForeignExchangeID
Inner Join Audit.AuditCompanyEngagement As ACE On Ace.Id=FRE.EngagementId
Inner Join Audit.AuditCompany As AC On AC.Id=ACE.AuditCompanyId
Where AC.CompanyId In (Select ID From Common.Company Where Id NOT in (589,590,591,592,593,594))

Union All

Select Count(*) As RecordCount,'Audit.ForeignCurrencyAnalysisFactors' As TableName From Audit.ForeignCurrencyAnalysisFactors As FCAC
Inner Join Audit.ForeignCurrencyAnalysis As FCA On FCA.ID=FCAC.FCAnalysisID
Inner Join Audit.ForeignExchange As FRE On FRE.Id=FCA.ForeignExchangeID
Inner Join Audit.AuditCompanyEngagement As ACE On Ace.Id=FRE.EngagementId
Inner Join Audit.AuditCompany As AC On AC.Id=ACE.AuditCompanyId
Where AC.CompanyId In (Select ID From Common.Company Where Id NOT in (589,590,591,592,593,594)) 

Union All

Select Count(*) As RecordCount,'Audit.ForeignExchange' As TableName From Audit.ForeignExchange As FE
Inner Join Audit.AuditCompanyEngagement As ACE On Ace.Id=FE.EngagementId
Inner Join Audit.AuditCompany As AC On AC.Id=ACE.AuditCompanyId
Where AC.CompanyId In (Select ID From Common.Company Where Id NOT in (589,590,591,592,593,594)) 

Union All

Select Count(*) As RecordCount,'Audit.FormDetail' As TableName From Audit.FormDetail As FD
Inner Join Audit.FormMaster As FM On FM.ID=FD.FormMasterId
Where FM.CompanyId In (Select ID From Common.Company Where Id NOT in (589,590,591,592,593,594)) 

Union All

Select Count(*) As RecordCount,'Audit.GeneralLedgerDetail' As TableName From Audit.GeneralLedgerDetail As GLD
Inner Join Audit.GeneralLedgerImport As GLI On GLI.id=GLD.GeneralLedgerId
Where GLI.CompanyId In (Select ID From Common.Company Where Id NOT in (589,590,591,592,593,594)) 

Union All

Select Count(*) As RecordCount,'Audit.GeneralLedgerFileDetails' As TableName From Audit.GeneralLedgerFileDetails As GLFD
Inner Join Audit.AuditCompanyEngagement As ACE On ACE.Id=GLFD.EngagementId
Inner Join Audit.AuditCompany As AC On AC.Id=ACE.AuditCompanyId
Where AC.CompanyId In (Select ID From Common.Company Where Id NOT in (589,590,591,592,593,594)) 

Union All

Select Count(*) As RecordCount,'Audit.LeadSheetCategories' As TableName From Audit.LeadSheetCategories As LSC 
Inner Join Audit.LeadSheet As LS On LS.Id=LSC.LeadSheetId
Where LS.CompanyId In (Select ID From Common.Company Where Id NOT in (589,590,591,592,593,594)) 

Union All

--Select Count(*) As RecordCount As TableName From Audit.Note As N

Select Count(*) As RecordCount,'Audit.NoteAttachment' As TableName From Audit.NoteAttachment As AN
Inner Join Audit.Note As N On N.Id=AN.NoteId
Inner Join Audit.NoteAdjustment As NAT On NAT.NoteId=N.Id
Inner Join Audit.Adjustment As A On A.Id=NAT.AdjustmentID
Inner Join Audit.AuditCompanyEngagement As ACE On ACE.Id=A.EngagementID
Inner Join Audit.AuditCompany As AC1 On AC1.Id=ACE.AuditCompanyId
Where AC1.Companyid In (Select ID From Common.Company Where Id NOT in (589,590,591,592,593,594))
Union All
Select Count(*) As RecordCount,'Audit.Note' As TableName From Audit.Note As N
Inner Join Audit.NoteAdjustment As NAT On NAT.NoteId=N.Id
Inner Join Audit.Adjustment As A On A.Id=NAT.AdjustmentID
Inner Join Audit.AuditCompanyEngagement As ACE On ACE.Id=A.EngagementID
Inner Join Audit.AuditCompany As AC1 On AC1.Id=ACE.AuditCompanyId
Where AC1.Companyid In (Select ID From Common.Company Where Id NOT in (589,590,591,592,593,594))
Union All
Select Count(*) As RecordCount,'Audit.NoteAdjustment' As TableName From Audit.NoteAdjustment As NAT
Inner Join Audit.Adjustment As A On A.Id=NAT.AdjustmentID
Inner Join Audit.AuditCompanyEngagement As ACE On ACE.Id=A.EngagementID
Inner Join Audit.AuditCompany As AC1 On AC1.Id=ACE.AuditCompanyId
Where AC1.Companyid In (Select ID From Common.Company Where Id NOT in (589,590,591,592,593,594)) 

--Union All

--Select Count(*) As RecordCount,'Audit.NoteAttachment' As TableName From Audit.NoteAttachment

Union All

Select Count(*) As RecordCount,'Audit.[Order]' As TableName From Audit.[Order] As O
Inner Join Audit.AuditCompanyEngagement As ACE On ACE.Id=O.EngagementID
Inner Join Audit.AuditCompany As AC1 On AC1.Id=ACE.AuditCompanyId
Where AC1.Companyid In (Select ID From Common.Company Where Id NOT in (589,590,591,592,593,594)) 

Union All

Select Count(*) As RecordCount,'Audit.PAndCSectionQuestions' As TableName From Audit.PAndCSectionQuestions As PSQ
Inner Join Audit.PAndCSections As PS On PS.Id=PSQ.PAndCSectionId
Inner Join Audit.PlanningAndCompletionSetUp As PCS On PCS.Id=PS.PlanningAndCompletionSetUpId
Where PCS.CompanyId In (Select ID From Common.Company Where Id NOT in (589,590,591,592,593,594)) 

Union All

Select Count(*) As RecordCount,'Audit.PAndCSections' As TableName From Audit.PAndCSections As PS
Inner Join Audit.PlanningAndCompletionSetUp As PCS On PCS.Id=PS.PlanningAndCompletionSetUpId
Where PCS.CompanyId In (Select ID From Common.Company Where Id NOT in (589,590,591,592,593,594)) 

Union All

Select Count(*) As RecordCount,'Audit.PlanningMaterialityDetail' As TableName From Audit.PlanningMaterialityDetail As PMD
Inner Join Audit.PlanningMateriality As PM On PM.Id=PMD.PlanningMeterialityId
Where PM.CompanyId In (Select ID From Common.Company Where Id NOT in (589,590,591,592,593,594)) 

Union All

Select Count(*) As RecordCount,'Audit.PlanningMaterialityDetailLeadSheet' As TableName From Audit.PlanningMaterialityDetailLeadSheet As PMDL
Inner Join Audit.PlanningMaterialityDetail As PMD On PMD.Id=PMDL.PlanningMaterialityDetailId
Inner Join Audit.PlanningMateriality As PM On PM.Id=PMD.PlanningMeterialityId
Where PM.CompanyId In (Select ID From Common.Company Where Id NOT in (589,590,591,592,593,594)) 

Union All

Select Count(*) As RecordCount,'Audit.PlanningMaterialityLeadSheet' As TableName From Audit.PlanningMaterialityLeadSheet As PML
Inner Join Audit.LeadSheet As LS On LS.Id=PML.LeadSheetId
Where LS.CompanyId In (Select ID From Common.Company Where Id NOT in (589,590,591,592,593,594)) 

Union All
 
Select Count(*) As RecordCount,'Audit.PlanningMaterialitySetupDetail' As TableName From Audit.PlanningMaterialitySetupDetail As PMSD
Inner Join Audit.PlanningMaterialitySetup As PMS On PMS.ID=PMSD.PlanningMaterialitySetupId
Where PMS.CompanyId In (Select ID From Common.Company Where Id NOT in (589,590,591,592,593,594)) 

Union All

Select Count(*) As RecordCount,'Audit.Question' As TableName From Audit.Question As Q
Inner Join Audit.Questionnaire As QR On Q.Id=Q.QuestionnaireId
Where QR.CompanyId In (Select ID From Common.Company Where Id NOT in (589,590,591,592,593,594)) 

Union All

Select Count(*) As RecordCount,'Audit.SeriLog' As TableName From Audit.SeriLog As S

Union All

Select Count(*) As RecCount,'Audit.SubCategory' As TableName From Audit.SubCategory As SC
Inner Join Audit.AuditCompanyEngagement As ACE On ACE.Id=SC.EngagementId
Inner Join Audit.AuditCompany As AC On AC.Id=ACE.AuditCompanyId
Where Ac.CompanyId In (Select ID From Common.Company Where Id NOT in (589,590,591,592,593,594)) 


Union All

Select Count(*) As RecordCount,'Audit.TrialBalanceAuditTrail' As TableName From Audit.TrialBalanceAuditTrail As TBAT
Inner Join Audit.auditcompanyengagement As ACE On ACE.ID=TBAT.EngagementID
Inner Join Audit.AuditCompany As AC On AC.Id=ACE.AuditCompanyId
Where AC.CompanyId In (Select ID From Common.Company Where Id NOT in (589,590,591,592,593,594)) 

Union All

Select Count(*) As RecordCount,'Audit.TrialBalanceFileDetails' As TableName From Audit.TrialBalanceFileDetails As TFD
Inner Join Audit.auditcompanyengagement As ACE On ACE.ID=TFD.EngagementID
Inner Join Audit.AuditCompany As AC On AC.Id=ACE.AuditCompanyId
Where AC.CompanyId In (Select ID From Common.Company Where Id NOT in (589,590,591,592,593,594)) 

Union All

Select Count(*) As RecordCount,'Audit.TrialBalanceImport' As TableName From Audit.TrialBalanceImport As TI
Inner Join Audit.AuditCompany As AC On AC.Id=TI.AuditCompanyId
Where AC.CompanyId In (Select ID From Common.Company Where Id NOT in (589,590,591,592,593,594)) 

Union All

Select Count(*) As RecordCount,'Audit.TrialBalanceImportPreferences' As TableName From Audit.TrialBalanceImportPreferences

Union All

Select Count(*) As RecordCount,'Audit.TrialBalanceTickmark' As TableName From Audit.TrialBalanceTickmark As TBT
Inner Join Audit.auditcompanyengagement As ACE On ACE.ID=TBT.EngagementID
Inner Join Audit.AuditCompany As AC On AC.Id=ACE.AuditCompanyId
Where AC.CompanyId In (Select ID From Common.Company Where Id NOT in (589,590,591,592,593,594)) 

Union All

Select Count(*) As RecordCount,'Audit.UserApproval' As TableName From Audit.UserApproval As UA
Inner Join Audit.auditcompanyengagement As ACE On ACE.ID=UA.EngagementID
Inner Join Audit.AuditCompany As AC On AC.Id=ACE.AuditCompanyId
Where AC.CompanyId In (Select ID From Common.Company Where Id NOT in (589,590,591,592,593,594)) 

Union All

Select Count(*) As RecordCount,'Audit.WPComment' As TableName From Audit.WPComment

Union All

Select Count(*) As RecordCount,'Audit.WPCommentReply' As TableName From Audit.WPCommentReply As WCR
Inner Join Audit.WPComment As WC On WC.Id=WCR.WPCommentId
inner Join Audit.WPSetupDetail As WSD On WSD.Id=WC.WPCategoryId
Inner Join Audit.WPSetup As WS On WS.Id=WSD.WPSetupId
Where WS.CompanyId In (Select ID From Common.Company Where Id NOT in (589,590,591,592,593,594)) 

Union All

Select Count(*) As RecordCount,'Audit.WPImportFile' As TableName From Audit.WPImportFile As WF
inner Join Audit.WPSetupDetail As WSD On WSD.Id=WF.WPCategoryId
Inner Join Audit.WPSetup As WS On WS.Id=WSD.WPSetupId
Where WS.CompanyId In (Select ID From Common.Company Where Id NOT in (589,590,591,592,593,594)) 

Union All

Select Count(*) As RecordCount,'Audit.WPSetupDetail' As TableName From Audit.WPSetupDetail As WSD
Inner Join Audit.WPSetup As WS On WS.Id=WSD.WPSetupId
Where WS.CompanyId In (Select ID From Common.Company Where Id NOT in (589,590,591,592,593,594)) 

Union All

Select Count(*) As RecordCount,'Audit.WPSetupTickmark' As TableName From Audit.WPSetupTickmark As WST
Inner Join Audit.WPSetup As WS On WS.Id=WST.WPSetupId
Where WS.CompanyId In (Select ID From Common.Company Where Id NOT in (589,590,591,592,593,594)) 

Union All

Select Count(*) As RecordCount,'Audit.AuditCompanyMenuMaster' As TableName From Audit.AuditCompanyMenuMaster 
Where CompanyId In (Select ID From Common.Company Where Id NOT in (589,590,591,592,593,594)) 

Union All

Select Count(*) As RecordCount,'Audi.AuditRolePermission' As TableName From Audit.AuditRolePermission 
Where CompanyId In (Select ID From Common.Company Where Id NOT in (589,590,591,592,593,594)) 

Union All

Select Count(*) As RecordCount,'Audit.AuditRole' As TableName From Audit.AuditRole 
Where CompanyId In (Select ID From Common.Company Where Id NOT in (589,590,591,592,593,594)) 

Union All

Select Count(*) As RecordCount,'Audit.AuditPermission' As TableName From Audit.AuditPermission 
Where CompanyId In (Select ID From Common.Company Where Id NOT in (589,590,591,592,593,594))

Union All

Select Count(*) As RecordCount,'Audit.AuditMenuMaster' As TableName From Audit.AuditMenuMaster 
Where CompanyId In (Select ID From Common.Company Where Id NOT in (589,590,591,592,593,594)) 

Union All

Select Count(*) As RecordCount,'Audit.AccountAnnotation' As TableName From Audit.AccountAnnotation 
Where CompanyId In (Select ID From Common.Company Where Id NOT in (589,590,591,592,593,594)) 

Union All

Select Count(*) As RecordCount,'Audit.CashFlow' As TableName From Audit.CashFlow 
Where CompanyId In (Select ID From Common.Company Where Id NOT in (589,590,591,592,593,594))

 Union All

Select Count(*) As RecordCount,'Audit.Questionnaire' As TableName From Audit.Questionnaire 
Where CompanyId In (Select ID From Common.Company Where Id NOT in (589,590,591,592,593,594)) 

Union All

Select Count(*) As RecordCount,'Audit.AccountPolicy' As TableName From Audit.AccountPolicy 
Where CompanyId In (Select ID From Common.Company Where Id NOT in (589,590,591,592,593,594)) 

Union All

Select Count(*) As RecordCount,'Audit.CashFlowHeadings' As TableName From Audit.CashFlowHeadings 
Where CompanyId In (Select ID From Common.Company Where Id NOT in (589,590,591,592,593,594)) 

Union All

Select Count(*) As RecordCount,'Audit.FormMaster' As TableName From Audit.FormMaster
 Where CompanyId In (Select ID From Common.Company Where Id NOT in (589,590,591,592,593,594)) 
 
 Union All

Select Count(*) As RecordCount,'Audit.TemplateVariable' As TableName From Audit.TemplateVariable
Where CompanyId In (Select ID From Common.Company Where Id NOT in (589,590,591,592,593,594)) 

Union All

Select Count(*) As RecordCount,'Audit.LeadSheet' As TableName From Audit.LeadSheet 
Where CompanyId In (Select ID From Common.Company Where Id NOT in (589,590,591,592,593,594)) 

Union All

Select Count(*) As RecordCount,'Audit.Template' As TableName From Audit.Template 
Where CompanyId In (Select ID From Common.Company Where Id NOT in (589,590,591,592,593,594)) 

Union All

Select Count(*) As RecordCount,'Audit.AuditCompany' As TableName From Audit.AuditCompany 
Where CompanyId In (Select ID From Common.Company Where Id NOT in (589,590,591,592,593,594)) 

Union All

Select Count(*) As RecordCount,'Audit.GeneralLedgerImport' As TableName From Audit.GeneralLedgerImport 
Where CompanyId In (Select ID From Common.Company Where Id NOT in (589,590,591,592,593,594))

Union All

Select Count(*) As RecordCount,'Audit.PlanningAndCompletionSetUp' As TableName From Audit.PlanningAndCompletionSetUp 
Where CompanyId In (Select ID From Common.Company Where Id NOT in (589,590,591,592,593,594)) 

Union All

Select Count(*) As RecordCount,'Audit.Disclosure' As TableName From Audit.Disclosure 
Where CompanyId In (Select ID From Common.Company Where Id NOT in (589,590,591,592,593,594)) 

Union All

Select Count(*) As RecordCount,'Audit.WPSetup' As TableName From Audit.WPSetup 
Where CompanyId In (Select ID From Common.Company Where Id NOT in (589,590,591,592,593,594)) 

Union All

Select Count(*) As RecordCount,'Audit.PlanningMaterialitySetup' As TableName From Audit.PlanningMaterialitySetup 
Where CompanyId In (Select ID From Common.Company Where Id NOT in (589,590,591,592,593,594)) 

Union All

Select Count(*) As RecordCount,'Audit.PlanningMateriality' As TableName From Audit.PlanningMateriality 
Where CompanyId In (Select ID From Common.Company Where Id NOT in (589,590,591,592,593,594)) 

Union All

Select Count(*) As RecordCount,'Audit.TickMarkSetup' As TableName From Audit.TickMarkSetup 
Where CompanyId In (Select ID From Common.Company Where Id NOT in (589,590,591,592,593,594))

Union All

Select Count(*) As RecordCount,'Audit.EngagementVisitedHistory' As TableName From Audit.EngagementVisitedHistory 
Where CompanyId In (Select ID From Common.Company Where Id NOT in (589,590,591,592,593,594)) 

Union All

Select Count(*) As RecordCount,'Audit.EngagementTypeMenuMapping' As TableName From Audit.EngagementTypeMenuMapping 
Where CompanyId In (Select ID From Common.Company Where Id NOT in (589,590,591,592,593,594)) 

Union All

Select Count(*) As RecordCount,'Audit.AuditMenu' As TableName From Audit.AuditMenu 
Where CompanyId In (Select ID From Common.Company Where Id NOT in (589,590,591,592,593,594)) 

Union All

--//Auth

Select Count(*) As RecCount,'Auth.GridMetaData' As TableName from Auth.GridMetaData
Where CompanyId In (Select ID From Common.Company Where Id NOT in (589,590,591,592,593,594)) Union All 

--Select * from Auth.Permission

Select Count(*),'Auth.ModuleDetailPermission' As TableName from Auth.ModuleDetailPermission As MDP
Inner Join Common.ModuleDetail As MD On MD.Id=MDP.ModuleDetailId
Where CompanyId In (Select ID From Common.Company Where Id NOT in (589,590,591,592,593,594)) 

Union All 

Select Count(*) As RecCount,'Auth.PermissionsMapping' As TableName from Auth.PermissionsMapping
Where CompanyId In (Select ID From Common.Company Where Id NOT in (589,590,591,592,593,594)) Union All

Select Count(*) As RecCount,'Auth.Role' As TableName from Auth.Role
Where CompanyId In (Select ID From Common.Company Where Id NOT in (589,590,591,592,593,594)) Union All

Select Count(*) As RecCount,'Auth.RoleNew' As TableName from Auth.RoleNew
Where CompanyId In (Select ID From Common.Company Where Id NOT in (589,590,591,592,593,594)) Union All

Select Count(*) As RecCount,'Auth.RolePermissionsNew' from Auth.RolePermissionsNew RPN
Inner Join Auth.RoleNew RN on RN.Id=RPN.RoleId
Where CompanyId In (Select ID From Common.Company Where Id NOT in (589,590,591,592,593,594)) Union All

Select Count(*) As RecCount,'Auth.RolePermission' from Auth.RolePermission RP
Inner Join Auth.Role R on R.Id=RP.RoleId
Where CompanyId In (Select ID From Common.Company Where Id NOT in (589,590,591,592,593,594)) Union All

Select Count(*) As RecCount,'Auth.UserPermission' from Auth.UserPermission UP
Inner Join Auth.Role R on R.Id=UP.RoleId
Where CompanyId In (Select ID From Common.Company Where Id NOT in (589,590,591,592,593,594)) Union All

Select Count(*) As RecCount,'Auth.UserRole' from Auth.UserRole UR
Inner Join Auth.Role R on R.Id=UR.RoleId
Where CompanyId In (Select ID From Common.Company Where Id NOT in (589,590,591,592,593,594)) Union All

Select Count(*) As RecCount,'Auth.UserRoleNew' from Auth.UserRoleNew URN
Inner Join Auth.RoleNew RN on RN.Id=URN.RoleId
Where CompanyId In (Select ID From Common.Company Where Id NOT in (589,590,591,592,593,594)) Union All

Select Count(*) As RecCount,'Auth.UserPermissionNew' from Auth.UserPermissionNew UPN
Inner Join Auth.UserRoleNew URN on URN.Id=UPN.UserRoleId
Inner Join Auth.RoleNew RN on RN.Id=URN.RoleId
Where RN.CompanyId In (Select ID From Common.Company Where Id NOT in (589,590,591,592,593,594)) Union All

Select Count(*) As RecCount,'Auth.UserAccount' from Auth.UserAccount UA
Inner Join Common.CompanyUser CU on CU.UserId=UA.Id
Where CompanyId In (Select ID From Common.Company Where Id NOT in (589,590,591,592,593,594)) Union All


--//Bean

SELECT Count(*) As RecordCount ,'Bean.AccountType' As TableName From Bean.AccountType
WHERE CompanyId In (Select ID From Common.Company Where Id NOT in (589,590,591,592,593,594)) 

Union All

SELECT Count(*) As RecordCount ,'Bean.BankReconciliation' As TableName From Bean.BankReconciliation
WHERE CompanyId In (Select ID From Common.Company Where Id NOT in (589,590,591,592,593,594)) 

Union All

Select Count(*) As RecCount,'Bean.COALinkedAccounts' As TableName From Bean.COALinkedAccounts Where CompanyId in (589,590,591,592,593,594) Union All   


SELECT Count(*) As RecordCount ,'Bean.BankReconciliationDetail' As TableName From Bean.BankReconciliationDetail BRD
Inner JOin Bean.BankReconciliation BRC ON BRC.Id=BRD.BankReconciliationId
WHERE BRC.CompanyId In (Select ID From Common.Company Where Id NOT in (589,590,591,592,593,594)) 

Union All

select Count(*) As RecordCount ,'Bean.BankReconciliationSetting' As TableName From Bean.BankReconciliationSetting
WHERE CompanyId In (Select ID From Common.Company Where Id NOT in (589,590,591,592,593,594)) Union All

select  Count(*) As RecordCount ,'Bean.BankTransfer'  As TableName From Bean.BankTransfer
WHERE CompanyId In (Select ID From Common.Company Where Id NOT in (589,590,591,592,593,594)) Union All


select  Count(*) As RecordCount ,'Bean.BankTransferDetail' As TableName From Bean.BankTransferDetail BTD
INNER JOIN  Bean.BankTransfer  BT ON BT.id=BTD.BankTransferId
WHERE BT.CompanyId In (Select ID From Common.Company Where Id NOT in (589,590,591,592,593,594)) Union All

select  Count(*) As RecordCount ,'Bean.Bill' As TableName From Bean.Bill
WHERE CompanyId In (Select ID From Common.Company Where Id NOT in (589,590,591,592,593,594)) Union All

select  Count(*) As RecordCount ,'Bean.BillCreditMemo' As TableName From Bean.BillCreditMemo
WHERE CompanyId In (Select ID From Common.Company Where Id NOT in (589,590,591,592,593,594)) Union All

select  Count(*) As RecordCount ,'Bean.BillCreditMemoDetail' As TableName From Bean.BillCreditMemoDetail BCMD
INNER JOIN Bean.BillCreditMemo BCM ON BCM.id=BCMD.CreditMemoId
WHERE BCM.CompanyId In (Select ID From Common.Company Where Id NOT in (589,590,591,592,593,594)) Union All

select  Count(*) As RecordCount ,'Bean.BillCreditMemoGSTDetails' As TableName From Bean.BillCreditMemoGSTDetails BCMG
INNER JOIN Bean.BillCreditMemo BCM ON BCM.id=BCMG.CreditMemoId
WHERE BCM.CompanyId In (Select ID From Common.Company Where Id NOT in (589,590,591,592,593,594)) Union All

select  Count(*) As RecordCount ,'Bean.BillDetail' As TableName From Bean.BillDetail BD
INNER JOIN Bean.Bill B ON B.Id=BD.BillId
WHERE B.CompanyId In (Select ID From Common.Company Where Id NOT in (589,590,591,592,593,594)) Union All


select  Count(*) As RecordCount ,'Bean.BillGSTDetail' As TableName From Bean.BillGSTDetail  BGD
INNER JOIN Bean.Bill B ON B.Id=BGD.BillId
WHERE B.CompanyId In (Select ID From Common.Company Where Id NOT in (589,590,591,592,593,594)) Union All


select  Count(*) As RecordCount ,'Bean.CashSale' As TableName From Bean.CashSale CS
WHERE CS.CompanyId In (Select ID From Common.Company Where Id NOT in (589,590,591,592,593,594)) Union All


select  Count(*) As RecordCount ,'Bean.CashSaleDetail' As TableName From Bean.CashSaleDetail CSD
INNER JOIN Bean.CashSale CS ON CS.id=CSD.CashSaleId
WHERE CS.CompanyId In (Select ID From Common.Company Where Id NOT in (589,590,591,592,593,594)) Union All

select  Count(*) As RecordCount ,'Bean.Category' As TableName From Bean.Category C
WHERE C.CompanyId In (Select ID From Common.Company Where Id NOT in (589,590,591,592,593,594)) Union All

select  Count(*) As RecordCount ,'Bean.ChartOfAccount' As TableName From Bean.ChartOfAccount CA
WHERE CA.CompanyId In (Select ID From Common.Company Where Id NOT in (589,590,591,592,593,594)) Union All

select  Count(*) As RecordCount ,'Bean.CreditMemo' As TableName From Bean.CreditMemo CM
WHERE CM.CompanyId In (Select ID From Common.Company Where Id NOT in (589,590,591,592,593,594)) Union All

select  Count(*) As RecordCount ,'Bean.CreditMemoApplication' As TableName From Bean.CreditMemoApplication CMA
WHERE CMA.CompanyId In (Select ID From Common.Company Where Id NOT in (589,590,591,592,593,594)) Union All

select  Count(*) As RecordCount ,'Bean.CreditMemoApplicationDetail' As TableName From Bean.CreditMemoApplicationDetail CMAD
INNER JOIN Bean.CreditMemoApplication CMA ON CMA.Id=CMAD.CreditMemoApplicationId
WHERE CMA.CompanyId In (Select ID From Common.Company Where Id NOT in (589,590,591,592,593,594)) Union All

select  Count(*) As RecordCount ,'Bean.CreditMemoDetail' As TableName From Bean.CreditMemoDetail CMAD
INNER JOIN Bean.ChartOfAccount CA ON  CA.Id=CMAD.COAId
WHERE CA.CompanyId In (Select ID From Common.Company Where Id NOT in (589,590,591,592,593,594)) Union All

select  Count(*) As RecordCount ,'Bean.CreditNoteApplication' As TableName From Bean.CreditNoteApplication CNA
WHERE CNA.CompanyId In (Select ID From Common.Company Where Id NOT in (589,590,591,592,593,594)) Union All

select  Count(*) As RecordCount ,'Bean.CreditNoteApplicationDetail' As TableName From Bean.CreditNoteApplicationDetail CNAD
INNER JOIN Bean.CreditNoteApplication CNA ON CNA.id=CNAD.CreditNoteApplicationId
WHERE CNA.CompanyId In (Select ID From Common.Company Where Id NOT in (589,590,591,592,593,594)) Union All

select  Count(*) As RecordCount ,'Bean.Currency' As TableName From Bean.Currency C
WHERE C.CompanyId In (Select ID From Common.Company Where Id NOT in (589,590,591,592,593,594)) Union All

select  Count(*) As RecordCount ,'Bean.DebitNote' As TableName From Bean.DebitNote D
WHERE D.CompanyId In (Select ID From Common.Company Where Id NOT in (589,590,591,592,593,594)) Union All

select  Count(*) As RecordCount ,'Bean.DebitNoteDetail' As TableName From Bean.DebitNoteDetail DND
INNER JOIN Bean.DebitNote DN ON DN.Id=DND.DebitNoteId
WHERE DN.CompanyId In (Select ID From Common.Company Where Id NOT in (589,590,591,592,593,594)) Union All  

select  Count(*) As RecordCount ,'Bean.DebitNoteGSTDetail' As TableName From Bean.DebitNoteGSTDetail DND
INNER JOIN Bean.DebitNote DN ON DN.Id=DND.DebitNoteId
WHERE DN.CompanyId In (Select ID From Common.Company Where Id NOT in (589,590,591,592,593,594)) Union All  

select  Count(*) As RecordCount ,'Bean.DebitNoteNote' As TableName From Bean.DebitNoteNote DNN
INNER JOIN Bean.DebitNote DN ON DN.Id=DNN.DebitNoteId
WHERE DN.CompanyId In (Select ID From Common.Company Where Id NOT in (589,590,591,592,593,594)) Union All

select  Count(*) As RecordCount ,'Bean.DocumentRecurrence' As TableName From Bean.DocumentRecurrence 
WHERE CompanyId In (Select ID From Common.Company Where Id NOT in (589,590,591,592,593,594)) Union All  

select  Count(*) As RecordCount ,'Bean.DoubtfulDebtAllocation' As TableName From Bean.DoubtfulDebtAllocation 
WHERE CompanyId In (Select ID From Common.Company Where Id NOT in (589,590,591,592,593,594)) Union All


select  Count(*) As RecordCount ,'Bean.DoubtfulDebtAllocationDetail' As TableName From Bean.DoubtfulDebtAllocationDetail DDAD
INNER JOIN Bean.DoubtfulDebtAllocation DDA ON DDA.Id=DDAD.DoubtfulDebtAllocationId
WHERE DDA.CompanyId In (Select ID From Common.Company Where Id NOT in (589,590,591,592,593,594)) Union All  


select  Count(*) As RecordCount ,'Bean.Entity' As TableName From Bean.Entity E
WHERE E.CompanyId In (Select ID From Common.Company Where Id NOT in (589,590,591,592,593,594)) Union All   

select  Count(*) As RecordCount ,'Bean.FinancialSetting' As TableName From Bean.FinancialSetting FS
WHERE FS.CompanyId In (Select ID From Common.Company Where Id NOT in (589,590,591,592,593,594)) Union All 

select  Count(*) As RecordCount ,'Bean.Forex' As TableName From Bean.Forex F
WHERE F.CompanyId In (Select ID From Common.Company Where Id NOT in (589,590,591,592,593,594)) Union All    

select  Count(*) As RecordCount ,'Bean.GLClearing' As TableName From Bean.GLClearing GlC
WHERE GlC.CompanyId In (Select ID From Common.Company Where Id NOT in (589,590,591,592,593,594)) Union All 

select  Count(*) As RecordCount ,'Bean.GLClearingDetail' As TableName From Bean.GLClearingDetail GlCD
Inner join Bean.GLClearing GlC ON GlC.id=GlCD.GLClearingId
WHERE GlC.CompanyId In (Select ID From Common.Company Where Id NOT in (589,590,591,592,593,594)) Union All          

select  Count(*) As RecordCount ,'Bean.Invoice' As TableName From Bean.Invoice I
WHERE I.CompanyId In (Select ID From Common.Company Where Id NOT in (589,590,591,592,593,594)) Union All 

select  Count(*) As RecordCount ,'Bean.InvoiceDetail' As TableName From Bean.InvoiceDetail ID
INNER JOIN Bean.Invoice I ON I.id=id.InvoiceId
WHERE I.CompanyId In (Select ID From Common.Company Where Id NOT in (589,590,591,592,593,594)) Union All    

select  Count(*) As RecordCount ,'Bean.InvoiceGSTDetail' As TableName From Bean.InvoiceGSTDetail IGD
INNER JOIN Bean.Invoice I ON I.id=IGD.InvoiceId
WHERE I.CompanyId In (Select ID From Common.Company Where Id NOT in (589,590,591,592,593,594)) Union All

select  Count(*) As RecordCount ,'Bean.InvoiceNote' As TableName From Bean.InvoiceNote N
INNER JOIN Bean.Invoice I ON I.id=N.InvoiceId
WHERE I.CompanyId In (Select ID From Common.Company Where Id NOT in (589,590,591,592,593,594)) Union All

select  Count(*) As RecordCount ,'Bean.Item' As TableName From Bean.Item I
WHERE I.CompanyId In (Select ID From Common.Company Where Id NOT in (589,590,591,592,593,594)) Union All

select  Count(*) As RecordCount ,'Bean.Journal' As TableName From Bean.Journal J
WHERE J.CompanyId In (Select ID From Common.Company Where Id NOT in (589,590,591,592,593,594)) Union All

select  Count(*) As RecordCount ,'Bean.JournalDetail' As TableName From Bean.JournalDetail JD
INNER JOIN Bean.Journal J ON J.id=JD.JournalId
WHERE J.CompanyId In (Select ID From Common.Company Where Id NOT in (589,590,591,592,593,594)) Union All

select  Count(*) As RecordCount ,'Bean.JournalGSTDetail' As TableName From Bean.JournalGSTDetail JGD
INNER JOIN Bean.Journal J ON J.id=JGD.JournalId
WHERE J.CompanyId In (Select ID From Common.Company Where Id NOT in (589,590,591,592,593,594)) Union All

select  Count(*) As RecordCount ,'Bean.JournalHistory' As TableName From Bean.JournalHistory JH
INNER JOIN Bean.Journal J ON J.id=JH.JournalId
WHERE J.CompanyId In (Select ID From Common.Company Where Id NOT in (589,590,591,592,593,594)) Union All

select  Count(*) As RecordCount ,'Bean.JournalLedger' As TableName From Bean.JournalLedger JL
WHERE JL.CompanyId In (Select ID From Common.Company Where Id NOT in (589,590,591,592,593,594)) Union All

--select  Count(*) As RecordCount ,'Bean.JournalLedger' As TableName From Bean.JvActivityLog JL
--WHERE JL.CompanyId In (Select ID From Common.Company Where Id NOT in (589,590,591,592,593,594)) Union All

select  Count(*) As RecordCount ,'Bean.MultiCurrencySetting' As TableName From Bean.MultiCurrencySetting MCS
WHERE MCS.CompanyId In (Select ID From Common.Company Where Id NOT in (589,590,591,592,593,594)) Union All

select  Count(*) As RecordCount ,'Bean.OpeningBalance' As TableName From Bean.OpeningBalance OB
WHERE OB.CompanyId In (Select ID From Common.Company Where Id NOT in (589,590,591,592,593,594)) Union All

select  Count(*) As RecordCount ,'Bean.OpeningBalanceDetail' As TableName From Bean.OpeningBalanceDetail OBD
INNER JOIN Bean.OpeningBalance OB ON OB.id=OBD.OpeningBalanceId
WHERE OB.CompanyId In (Select ID From Common.Company Where Id NOT in (589,590,591,592,593,594)) Union All

select  Count(*) As RecordCount ,'Bean.OpeningBalanceDetailLineItem' As TableName From Bean.OpeningBalanceDetailLineItem OBDL
--Inner join Bean.ChartOfAccount A on A.Id=OBDL.COAId
INNER JOIN Bean.OpeningBalanceDetail OBD ON OBD.Id=OBDL.OpeningBalanceDetailId
INNER JOIN Bean.OpeningBalance OB ON OB.Id=OBD.OpeningBalanceId
WHERE OB.CompanyId In (Select ID From Common.Company Where Id NOT in (589,590,591,592,593,594)) Union All

select  Count(*) As RecordCount ,'Bean.Order' As TableName From Bean.[Order] 
WHERE CompanyId In (Select ID From Common.Company Where Id NOT in (589,590,591,592,593,594)) Union All


select  Count(*) As RecordCount ,'Bean.Payment' As TableName From Bean.Payment 
WHERE CompanyId In (Select ID From Common.Company Where Id NOT in (589,590,591,592,593,594)) Union All

select  Count(*) As RecordCount ,'Bean.PaymentDetail' As TableName From Bean.PaymentDetail  PD
INNER JOIN Bean.Payment P ON p.id=PD.PaymentId
WHERE p.CompanyId In (Select ID From Common.Company Where Id NOT in (589,590,591,592,593,594)) Union All

select  Count(*) As RecordCount ,'Bean.Provision' As TableName From Bean.Provision  
WHERE CompanyId In (Select ID From Common.Company Where Id NOT in (589,590,591,592,593,594)) Union All

select  Count(*) As RecordCount ,'Bean.Receipt' As TableName From Bean.Receipt  
WHERE CompanyId In (Select ID From Common.Company Where Id NOT in (589,590,591,592,593,594)) Union All


select  Count(*) As RecordCount ,'Bean.ReceiptBalancingItem' As TableName From Bean.ReceiptBalancingItem  RB
INNER JOIN Bean.Receipt  R ON R.id=RB.ReceiptId
WHERE R.CompanyId In (Select ID From Common.Company Where Id NOT in (589,590,591,592,593,594)) Union All

select  Count(*) As RecordCount ,'Bean.ReceiptDetail' As TableName From Bean.ReceiptDetail  RD
INNER JOIN Bean.Receipt  R ON R.id=RD.ReceiptId
WHERE R.CompanyId In (Select ID From Common.Company Where Id NOT in (589,590,591,592,593,594)) Union All

select  Count(*) As RecordCount ,'Bean.ReceiptGSTDetail' As TableName From Bean.ReceiptGSTDetail  RGD
INNER JOIN Bean.Receipt  R ON R.id=RGD.ReceiptId
WHERE R.CompanyId In (Select ID From Common.Company Where Id NOT in (589,590,591,592,593,594)) Union All

select  Count(*) As RecordCount ,'Bean.Revalution' As TableName From Bean.Revalution  R
WHERE R.CompanyId In (Select ID From Common.Company Where Id NOT in (589,590,591,592,593,594)) Union All

select  Count(*) As RecordCount ,'Bean.RevalutionDetail' As TableName From Bean.RevalutionDetail  RD
INNER JOIN Bean.Revalution  R on R.id=RD.RevalutionId
WHERE R.CompanyId In (Select ID From Common.Company Where Id NOT in (589,590,591,592,593,594)) Union All

select  Count(*) As RecordCount ,'Bean.SegmentDetail' As TableName From Bean.SegmentDetail  SD
INNER JOIN Bean.SegmentMaster SM ON SM.Id =SD.SegmentMasterId
WHERE SM.CompanyId In (Select ID From Common.Company Where Id NOT in (589,590,591,592,593,594)) Union All

select  Count(*) As RecordCount ,'Bean.SegmentMaster' As TableName From Bean.SegmentMaster  SM
WHERE SM.CompanyId In (Select ID From Common.Company Where Id NOT in (589,590,591,592,593,594)) Union All

select  Count(*) As RecordCount ,'Bean.SubCategory' As TableName From Bean.SubCategory  
WHERE CompanyId In (Select ID From Common.Company Where Id NOT in (589,590,591,592,593,594)) Union All

select  Count(*) As RecordCount ,'Bean.TaxCode' As TableName From Bean.TaxCode  
WHERE CompanyId In (Select ID From Common.Company Where Id NOT in (589,590,591,592,593,594)) Union All

select  Count(*) As RecordCount ,'Bean.WithDrawal' As TableName From Bean.WithDrawal  
WHERE CompanyId In (Select ID From Common.Company Where Id NOT in (589,590,591,592,593,594)) Union All

select  Count(*) As RecordCount ,'Bean.WithDrawalDetail' As TableName From Bean.WithDrawalDetail WD
 INNER JOIN  Bean.WithDrawal W ON W.id=WD.WithdrawalId
WHERE W.CompanyId In (Select ID From Common.Company Where Id NOT in (589,590,591,592,593,594)) Union All

--//BoardRoom

Select Count(*) As RecordCount,'Boardroom.AGM' As TableName From Boardroom.AGM --

Union All

Select Count(*) As RecordCount,'Boardroom.AGMDetail' As TableName From Boardroom.AGMDetail --
Union All

Select Count(*) As RecordCount,'Boardroom.ContactMapping' As TableName From Boardroom.ContactMapping --
Union All

Select Count(*) As RecordCount,'Boardroom.InPrincpialApproval' As TableName From Boardroom.InPrincpialApproval --
Union All

Select Count(*) As RecordCount,'Boardroom.Register' As TableName From Boardroom.Register --
Union All

Select Count(*) As RecordCount,'Boardroom.ShareholderAllotment' As TableName From Boardroom.ShareholderAllotment --
Union All 

Select Count(*) As RecordCount,'Boardroom.AGMAndARReminders' As TableName 
From Boardroom.AGMAndARReminders Where CompanyId In (Select ID From Common.Company Where Id NOT in (589,590,591,592,593,594)) Union All

Select Count(*) As RecordCount,'Boardroom.GenericContact' As TableName From Boardroom.GenericContact 
Where CompanyId In (Select ID From Common.Company Where Id NOT in (589,590,591,592,593,594)) Union All

Select Count(*) As RecordCount,'Boardroom.BRAGM' As TableName From Boardroom.BRAGM 
Where CompanyId In (Select ID From Common.Company Where Id NOT in (589,590,591,592,593,594)) Union All

Select Count(*) As RecordCount,'Boardroom.Changes' As TableName From Boardroom.Changes 
Where CompanyId In (Select ID From Common.Company Where Id NOT in (589,590,591,592,593,594)) Union All

Select Count(*) As RecordCount,'Boardroom.GenericShareholderContact' As TableName From Boardroom.GenericShareholderContact --
Union All
Select Count(*) As RecordCount,'Boardroom.Shares' As TableName From Boardroom.Shares 
Where CompanyId In (Select ID From Common.Company Where Id NOT in (589,590,591,592,593,594)) Union All

Select Count(*) As RecordCount,'Boardroom.Signatory' As TableName From Boardroom.Signatory 
Where CompanyId In (Select ID From Common.Company Where Id NOT in (589,590,591,592,593,594)) Union All
 
Select Count(*) As RecordCount,'Boardroom.AGMAndARRemindersTemplates' As TableName From Boardroom.AGMAndARRemindersTemplates As AGMTmp
Inner Join Boardroom.AGMAndARReminders As AGMR On AGMR.Id=AGMTmp.AGMAndARRemindersId
Where AGMR.CompanyId In (Select ID From Common.Company Where Id NOT in (589,590,591,592,593,594)) Union All

Select Count(*) As RecordCount,'Boardroom.Contacts' As TableName From Boardroom.Contacts Where CompanyId In (Select ID From Common.Company Where Id NOT in (589,590,591,592,593,594)) Union All

Select Count(*) As RecordCount,'Boardroom.EntityActivity' As TableName From Boardroom.EntityActivity Where CompanyId In (Select ID From Common.Company Where Id NOT in (589,590,591,592,593,594)) Union All

Select Count(*) As RecordCount,'Boardroom.AGMReminder' As TableName From Boardroom.AGMReminder Where CompanyId In (Select ID From Common.Company Where Id NOT in (589,590,591,592,593,594)) Union All

Select Count(*) As RecordCount,'Boardroom.AGMSignatory' As TableName From Boardroom.AGMSignatory As AGM
Inner Join Boardroom.GenericContact As GC On GC.Id=AGM.GenericContactId
Where GC.CompanyId In (Select ID From Common.Company Where Id NOT in (589,590,591,592,593,594)) Union All

Select Count(*) As RecordCount,'Boardroom.Allotment' As TableName From Boardroom.Allotment As A
Inner Join Common.EntityDetail As ED On ED.Id=A.EntityId
Where ED.CompanyId In (Select ID From Common.Company Where Id NOT in (589,590,591,592,593,594)) Union All

Select Count(*) As RecordCount,'Boardroom.AllotmentDetails' As TableName From Boardroom.AllotmentDetails As AD
Inner Join Boardroom.Allotment As A On A.id=AD.AllotmentId
Inner Join Common.EntityDetail As ED On ED.Id=A.EntityId
Where ED.CompanyId In (Select ID From Common.Company Where Id NOT in (589,590,591,592,593,594)) Union All

Select Count(*) As RecordCount,'Boardroom.EntityChanges' As TableName From Boardroom.EntityChanges As EC
Inner Join Boardroom.Changes As BC On BC.Id=EC.ChangesId
Where BC.CompanyId In (Select ID From Common.Company Where Id NOT in (589,590,591,592,593,594)) Union All

Select Count(*) As RecordCount,'Boardroom.FYEChanges' As TableName From Boardroom.FYEChanges As FC
Inner Join Boardroom.[Changes] As BC On BC.Id=FC.ChangesId
Where BC.CompanyId In (Select ID From Common.Company Where Id NOT in (589,590,591,592,593,594)) Union All

Select Count(*) As RecordCount,'Boardroom.GenerateTemplate' As TableName From Boardroom.GenerateTemplate As GT
Inner Join Boardroom.[Changes] As BC On BC.Id=GT.ChangesId
Where BC.CompanyId In (Select ID From Common.Company Where Id NOT in (589,590,591,592,593,594)) Union All

Select Count(*) As RecordCount,'Boardroom.AGMChanges' As TableName From Boardroom.AGMChanges As AC
Inner Join Boardroom.[Changes] As BC On BC.Id=AC.ChangesId
Where BC.CompanyId In (Select ID From Common.Company Where Id NOT in (589,590,591,592,593,594)) Union All

Select Count(*) As RecordCount,'Boardroom.AGMFillingChanges' As TableName From Boardroom.AGMFillingChanges As AC
Inner Join Boardroom.[Changes] As BC On BC.Id=AC.ChangesId
Where BC.CompanyId In (Select ID From Common.Company Where Id NOT in (589,590,591,592,593,594)) Union All

Select Count(*) As RecordCount,'Boardroom.ActivityChanges' As TableName From Boardroom.ActivityChanges As AC
Inner Join Boardroom.[Changes] As BC On BC.Id=AC.ChangesId
Where BC.CompanyId In (Select ID From Common.Company Where Id NOT in (589,590,591,592,593,594)) Union All

Select Count(*) As RecordCount,'Boardroom.ActivityHistory' As TableName From Boardroom.ActivityHistory where CompanyId In (Select ID From Common.Company Where Id NOT in (589,590,591,592,593,594)) Union All

Select Count(*) As RecordCount,'Boardroom.AdressesActivity' As TableName From Boardroom.AdressesActivity As AA
Inner Join Boardroom.[Changes] As BC On BC.Id=AA.ChangesId
Where BC.CompanyId In (Select ID From Common.Company Where Id NOT in (589,590,591,592,593,594)) Union All

Select Count(*) As RecordCount,'Boardroom.SubClass' As TableName From Boardroom.SubClass As SC
Inner Join Boardroom.Shares As S On S.Id=SC.SharesId
Where S.CompanyId In (Select ID From Common.Company Where Id NOT in (589,590,591,592,593,594)) Union All

Select Count(*) As RecordCount,'Boardroom.[Transaction]' As TableName From Boardroom.[Transaction] As T
Inner Join Common.EntityDetail As ED On ED.Id=T.EntityId
Where ED.CompanyId In (Select ID From Common.Company Where Id NOT in (589,590,591,592,593,594)) Union All


Select Count(*) As RecordCount,'Boardroom.SharesDetail' As TableName From Boardroom.SharesDetail As SD
Inner Join Boardroom.Shares As S On S.Id=SD.SharesId
Where s.CompanyId In (Select ID From Common.Company Where Id NOT in (589,590,591,592,593,594)) Union All

Select Count(*) As RecordCount,'Boardroom.Remindersent' As TableName From Boardroom.Remindersent Where CompanyId In (Select ID From Common.Company Where Id NOT in (589,590,591,592,593,594)) Union All

Select Count(*) As RecordCount,'Boardroom.InCharge' As TableName From Boardroom.InCharge As I
Inner Join Boardroom.[Changes] As S On S.Id=I.ChangesId
Where s.CompanyId In (Select ID From Common.Company Where Id NOT in (589,590,591,592,593,594)) Union All

Select Count(*) As RecordCount,'Boardroom.OfficerChanges' As TableName From Boardroom.OfficerChanges As OC
Inner Join Boardroom.[Changes] As S On S.Id=OC.ChangesId
Where s.CompanyId In (Select ID From Common.Company Where Id NOT in (589,590,591,592,593,594)) Union All

Select Count(*) As RecordCount,'Boardroom.PricipalApprovalDetail' As TableName From Boardroom.PricipalApprovalDetail As PAD
Inner Join Boardroom.EntityActivity As EA On EA.Id=PAD.EntityActivityId
Where EA.CompanyId In (Select ID From Common.Company Where Id NOT in (589,590,591,592,593,594)) Union All

Select Count(*) As RecordCount,'Boardroom.CompanyShareAllotment' As TableName From Boardroom.CompanyShareAllotment AS CSA
Inner Join Boardroom.Shares As S On S.Id=CSA.SharesId
Where s.CompanyId In (Select ID From Common.Company Where Id NOT in (589,590,591,592,593,594)) Union All

Select Count(*) As RecordCount,'Boardroom.GenericContactDesignation' As TableName From Boardroom.GenericContactDesignation Where CompanyId In (Select ID From Common.Company Where Id NOT in (589,590,591,592,593,594)) Union All

--//ClientCursor


Select Count(*) As RecordCount,'ClientCursor.Account' As TableName from ClientCursor.Account
Where CompanyId In (Select ID From Common.Company Where Id NOT in (589,590,591,592,593,594)) Union All

Select Count(*) As RecordCount,'ClientCursor.AccountStatusChange' As TableName from ClientCursor.AccountStatusChange
Where CompanyId In (Select ID From Common.Company Where Id NOT in (589,590,591,592,593,594)) Union All

Select Count(*) As RecordCount,'ClientCursor.AccountContact' 
from ClientCursor.AccountContact AC
Inner Join ClientCursor.Account A on A.Id =AC.AccountId
Where CompanyId In (Select ID From Common.Company Where Id NOT in (589,590,591,592,593,594)) Union All


Select Count(*) As RecordCount,'ClientCursor.AccountIncharge'  
from ClientCursor.AccountIncharge AI
Inner Join ClientCursor.Account A on A.Id =AI.AccountId
Where CompanyId In (Select ID From Common.Company Where Id NOT in (589,590,591,592,593,594)) Union All


Select Count(*) As RecordCount,'ClientCursor.AccountNote'   
from ClientCursor.AccountNote AN
Inner Join ClientCursor.Account A on A.Id =AN.AccountId
Where CompanyId In (Select ID From Common.Company Where Id NOT in (589,590,591,592,593,594)) Union All


Select Count(*) As RecordCount,'ClientCursor.Campaign'  from ClientCursor.Campaign
Where CompanyId In (Select ID From Common.Company Where Id NOT in (589,590,591,592,593,594)) Union All

Select Count(*) As RecordCount,'ClientCursor.CampaignDetail' 
from ClientCursor.CampaignDetail CD
Inner Join ClientCursor.Campaign C on C.Id=CD.CampaignId
Where CompanyId In (Select ID From Common.Company Where Id NOT in (589,590,591,592,593,594)) Union All

Select Count(*) As RecordCount,'ClientCursor.Employee Rank'  from ClientCursor.EmployeeRank
Where CompanyId In (Select ID From Common.Company Where Id NOT in (589,590,591,592,593,594)) Union All

Select Count(*) As RecordCount,'ClientCursor.EstimatedTimeCostQuestionnaire' As TableName from ClientCursor.EstimatedTimeCostQuestionnaire
Where CompanyId In (Select ID From Common.Company Where Id NOT in (589,590,591,592,593,594)) Union All

Select Count(*) As RecordCount,'ClientCursor.JobType'  from ClientCursor.JobType
Where CompanyId In (Select ID From Common.Company Where Id NOT in (589,590,591,592,593,594)) Union All

Select Count(*) As RecordCount,'ClientCursor.JobRisk' 
from ClientCursor.JobRisk JR
Inner Join ClientCursor.JobType JT on JT.Id=JR.JobTypeId 
Where CompanyId In (Select ID From Common.Company Where Id NOT in (589,590,591,592,593,594)) Union All

Select Count(*) As RecordCount,'ClientCursor.JobHoursLevel'  
from ClientCursor.JobHoursLevel JHL
Inner Join ClientCursor.JobType JT on JT.Id=JHL.JobTypeId 
Where CompanyId In (Select ID From Common.Company Where Id NOT in (589,590,591,592,593,594)) Union All


Select Count(*) As RecordCount,'ClientCursor.ManualAssociation'  
from ClientCursor.ManualAssociation MA

Inner Join ClientCursor.Account A on A.Id =MA.FromAccountId
Where CompanyId In (Select ID From Common.Company Where Id NOT in (589,590,591,592,593,594)) Union All


Select Count(*) As RecordCount,'ClientCursor.Opportunity'   from ClientCursor.Opportunity
Where CompanyId In (Select ID From Common.Company Where Id NOT in (589,590,591,592,593,594)) Union All

Select Count(*) As RecordCount,'ClientCursor.Opportunity History' As TableName from ClientCursor.OpportunityStatusChange
Where CompanyId In (Select ID From Common.Company Where Id NOT in (589,590,591,592,593,594)) Union All

Select Count(*) As RecordCount,'ClientCursor.Opportunity Incharge' 
from ClientCursor.OpportunityIncharge OI

Inner Join ClientCursor.Opportunity O on O.Id=OI.OpportunityId
Where CompanyId In (Select ID From Common.Company Where Id NOT in (589,590,591,592,593,594)) Union All

Select Count(*) As RecordCount,'ClientCursor.Opportunity Designation'  
from ClientCursor.OpportunityDesignation OD

Inner Join ClientCursor.Opportunity O on O.Id=OD.OpportunityId
Where CompanyId In (Select ID From Common.Company Where Id NOT in (589,590,591,592,593,594)) Union All

Select Count(*) As RecordCount,'ClientCursor.Opportunity Doc'   from ClientCursor.OpportunityDoc
Where CompanyId In (Select ID From Common.Company Where Id NOT in (589,590,591,592,593,594)) Union All

Select Count(*) As RecordCount,'ClientCursor.OpportunityHistory' As TableName from ClientCursor.OpportunityHistory
Where CompanyId In (Select ID From Common.Company Where Id NOT in (589,590,591,592,593,594)) Union All

Select Count(*) As RecordCount,'ClientCursor.OpportunityTermsCondition'  
from ClientCursor.OpportunityTermsCondition OTD

Inner Join ClientCursor.Opportunity O on O.Id=OTD.OpportunityId
Where CompanyId In (Select ID From Common.Company Where Id NOT in (589,590,591,592,593,594)) Union All

Select Count(*) As RecordCount,'ClientCursor.Quotation' As TableName from ClientCursor.Quotation
Where CompanyId In (Select ID From Common.Company Where Id NOT in (589,590,591,592,593,594)) Union All

Select Count(*) As RecordCount,'ClientCursor.Quotation Detail' 
from ClientCursor.QuotationDetail QD

Inner Join ClientCursor.Quotation Q on Q.Id=QD.MasterId
Where CompanyId In (Select ID From Common.Company Where Id NOT in (589,590,591,592,593,594)) Union All

Select Count(*) As RecordCount,'ClientCursor.QuotationDetailTemplate' 
from ClientCursor.QuotationDetailTemplate QDT
Inner Join ClientCursor.QuotationDetail QD on QD.Id=QDT.QuotationDetailId
Inner Join ClientCursor.Quotation Q on Q.Id=QD.MasterId
Where CompanyId In (Select ID From Common.Company Where Id NOT in (589,590,591,592,593,594)) Union All


Select Count(*) As RecordCount,'ClientCursor.QuotationHistory'  from ClientCursor.QuotationHistory
Where CompanyId In (Select ID From Common.Company Where Id NOT in (589,590,591,592,593,594)) Union All

Select Count(*) As RecordCount,'ClientCursor.QuotationSummaryDetails' 
from ClientCursor.QuotationSummaryDetails QSD
Inner Join ClientCursor.Quotation Q on Q.Id=QSD.QuotationId
Where CompanyId In (Select ID From Common.Company Where Id NOT in (589,590,591,592,593,594)) Union All

Select Count(*) As RecordCount,'ClientCursor.ReminderMaster' As TableName from ClientCursor.ReminderMaster
Where CompanyId In (Select ID From Common.Company Where Id NOT in (589,590,591,592,593,594)) Union All

Select Count(*) As RecordCount,'ClientCursor.ReminderDetail'  
from ClientCursor.ReminderDetail RD
Inner Join ClientCursor.ReminderMaster RM on RM.Id=RD.ReminderMasterId
Where CompanyId In (Select ID From Common.Company Where Id NOT in (589,590,591,592,593,594)) Union All

Select  Count(*) As RecordCount,'ClientCursor.ReminderDetailTemplate' 
from ClientCursor.ReminderDetailTemplate RDT
Inner Join ClientCursor.ReminderDetail RD on RD.Id=ReminderDetailId
Inner Join ClientCursor.ReminderMaster RM on RM.Id=RD.ReminderMasterId
Where RM.CompanyId In (Select ID From Common.Company Where Id NOT in (589,590,591,592,593,594)) Union All

Select Count(*) As RecordCount,'ClientCursor.Vendor' As TableName from ClientCursor.Vendor
Where CompanyId In (Select ID From Common.Company Where Id NOT in (589,590,591,592,593,594)) Union All

Select Count(*) As RecordCount,'ClientCursor.VendorContact' 
from ClientCursor.VendorContact VC
Inner Join ClientCursor.Vendor V on V.Id=VC.VendorId
Where CompanyId In (Select ID From Common.Company Where Id NOT in (589,590,591,592,593,594)) Union All

Select Count(*) As RecordCount,'ClientCursor.VendorNote'
from ClientCursor.VendorNote VN
Inner Join ClientCursor.Vendor V on V.Id=VN.VendorId
Where CompanyId In (Select ID From Common.Company Where Id NOT in (589,590,591,592,593,594)) Union All

Select Count(*) As RecordCount,'ClientCursor.VendorService' 
from ClientCursor.VendorService VS
Inner Join ClientCursor.Vendor V on V.Id=VS.VendorId
Where CompanyId In (Select ID From Common.Company Where Id NOT in (589,590,591,592,593,594)) Union All

Select Count(*) As RecordCount,'ClientCursor.VendorTypeVendor'  
from ClientCursor.VendorTypeVendor VTV
Inner Join ClientCursor.Vendor V on V.Id=VTV.VendorId
Where CompanyId In (Select ID From Common.Company Where Id NOT in (589,590,591,592,593,594))
Union All

--//Common

--Select * As TableName From Common.AccountBatch

Select Count(*) As RecordCount,'Common.AccountSource' As TableName From Common.AccountSource
Where CompanyId In (Select ID From Common.Company Where Id NOT in (589,590,591,592,593,594)) Union All

Select Count(*) As RecordCount,'Common.AccountType' As TableName From Common.AccountType
Where CompanyId In (Select ID From Common.Company Where Id NOT in (589,590,591,592,593,594)) Union All

Select Count(*) As RecordCount,'Common.AccountTypeIdType' As TableName From Common.AccountTypeIdType ATIT
Inner Join Common.AccountType AT on AT.Id=ATIT.AccountTypeId
Where CompanyId In (Select ID From Common.Company Where Id NOT in (589,590,591,592,593,594)) Union All

Select Count(*) As RecordCount,'Common.ActivityHistory'  As TableName From Common.ActivityHistory
Where CompanyId In (Select ID From Common.Company Where Id NOT in (589,590,591,592,593,594)) Union All

--Select * As TableName From Common.ActivityRelatedTo

--Select * As TableName From Common.AddressBook

--Select * As TableName From Common.Addresses

--Select * As TableName From Common.AddressHistory

Select Count(*) As RecordCount,'Common.AGMSetting' As TableName From Common.AGMSetting
Where CompanyId In (Select ID From Common.Company Where Id NOT in (589,590,591,592,593,594)) Union All

--Select * As TableName From Common.AppsWorldPostalCode

Select Count(*) As RecordCount,'Common.Attendance' As TableName From Common.Attendance
Where CompanyId In (Select ID From Common.Company Where Id NOT in (589,590,591,592,593,594)) Union All

Select Count(*) As RecordCount,'Common.AttendanceAttachments' As TableName From Common.AttendanceAttachments
Where CompanyId In (Select ID From Common.Company Where Id NOT in (589,590,591,592,593,594)) Union All

Select Count(*) As RecordCount,'Common.AttendanceDetails'  
As TableName From Common.AttendanceDetails AD

Inner Join Common.Attendance A on A.Id=AD.AttendenceId
Where CompanyId In (Select ID From Common.Company Where Id NOT in (589,590,591,592,593,594)) Union All

Select Count(*) As RecordCount,'Common.AttendanceRules' As TableName From Common.AttendanceRules
Where CompanyId In (Select ID From Common.Company Where Id NOT in (589,590,591,592,593,594)) Union All

Select Count(*) As RecordCount,'Common.AuditFirm' As TableName From Common.AuditFirm
Where CompanyId In (Select ID From Common.Company Where Id NOT in (589,590,591,592,593,594)) Union All

Select Count(*) As RecordCount,'Common.AutoNumber' As TableName From Common.AutoNumber
Where CompanyId In (Select ID From Common.Company Where Id NOT in (589,590,591,592,593,594)) Union All

Select Count(*) As RecordCount,'Common.AutoNumberCompany' As TableName From Common.AutoNumberCompany ANC
Inner Join Common.AutoNumber AN on AN.Id=ANC.AutonumberId
Where CompanyId In (Select ID From Common.Company Where Id NOT in (589,590,591,592,593,594)) Union All

Select Count(*) As RecordCount,'Common.AutoNumberDetail'  
As TableName From Common.AutoNumberDetail ANDL
Inner Join Common.AutoNumber AN on AN.Id=ANDL.MasterId
Where CompanyId In (Select ID From Common.Company Where Id NOT in (589,590,591,592,593,594)) Union All

Select Count(*) As RecordCount,'Common.Bank'  As TableName From Common.Bank
Where CompanyId In (Select ID From Common.Company Where Id NOT in (589,590,591,592,593,594)) Union All

Select Count(*) As RecordCount,'Common.Blade'As TableName From Common.Blade B
Inner Join Common.ModuleDetail MD on MD.Id=B.ModuleDetailId
Where MD.CompanyId In (Select ID From Common.Company Where Id NOT in (589,590,591,592,593,594)) Union All



--Select * As TableName From Common.BladeDetail

--Select * As TableName From Common.BladeMaster

--Select * As TableName From Common.BladeType

--Select * As TableName From Common.Building

Select Count(*) As RecordCount,'Common.ModuleDetail' As TableName From Common.ModuleDetail
Where CompanyId In (Select ID From Common.Company Where Id NOT in (589,590,591,592,593,594)) Union All

--Select * As TableName From Common.ModuleMaster

Select Count(*) As RecordCount,'Common.CacheKeys' As TableName From Common.CacheKeys CK
Inner Join Common.ModuleDetail MD on MD.Id=CK.ModuleDetailId
Where MD.CompanyId In (Select ID From Common.Company Where Id NOT in (589,590,591,592,593,594)) Union All

Select Count(*) As RecordCount,'Common.Calender'  As TableName From Common.Calender
Where CompanyId In (Select ID From Common.Company Where Id NOT in (589,590,591,592,593,594)) Union All

Select Count(*) As RecordCount,'Common.CalenderDetails'  As TableName From Common.CalenderDetails CD
Inner Join Common.Calender C on C.Id=CD.MasterId
Where CompanyId In (Select ID From Common.Company Where Id NOT in (589,590,591,592,593,594)) Union All


Select Count(*) As RecordCount,'Common.ChangesHistory' As TableName From Common.ChangesHistory
Where CompanyId In (Select ID From Common.Company Where Id NOT in (589,590,591,592,593,594)) Union All

--Select * As TableName From Common.Comment

--Select * As TableName From Common.Communication

Select Count(*) As RecordCount,'Common.Company' As TableName From Common.Company
Where Id In (Select ID From Common.Company Where Id NOT in (589,590,591,592,593,594)) Union All

Select Count(*) As RecordCount,'Common.CompanyFeatures' As TableName From Common.CompanyFeatures
Where CompanyId In (Select ID From Common.Company Where Id NOT in (589,590,591,592,593,594)) Union All

Select Count(*) As RecordCount,'Common.CompanyGlobalSettings' As TableName From Common.CompanyGlobalSettings
Where CompanyId In (Select ID From Common.Company Where Id NOT in (589,590,591,592,593,594)) Union All

Select Count(*) As RecordCount,'Common.CompanyModule' As TableName From Common.CompanyModule
Where CompanyId In (Select ID From Common.Company Where Id NOT in (589,590,591,592,593,594)) Union All

Select Count(*) As RecordCount,'Common.CompanyModuleSetUp' As TableName From Common.CompanyModuleSetUp
Where CompanyId In (Select ID From Common.Company Where Id NOT in (589,590,591,592,593,594)) Union All

--Select * As TableName From Common.CompanyNameHistory -- Common.EntityDetail (Id)

Select Count(*) As RecordCount,'Common.CompanyService' As TableName From Common.CompanyService CS
Inner Join Common.Service S on S.Id=CS.ServiceId
Where S.CompanyId In (Select ID From Common.Company Where Id NOT in (589,590,591,592,593,594)) Union All

Select Count(*) As RecordCount,'Common.CompanySetting'  As TableName From Common.CompanySetting
Where CompanyId In (Select ID From Common.Company Where Id NOT in (589,590,591,592,593,594)) Union All

--Select * As TableName From Common.CompanyStatus

Select Count(*) As RecordCount,'Common.CompanyTemplateSettings'  As TableName From Common.CompanyTemplateSettings
Where CompanyId In (Select ID From Common.Company Where Id NOT in (589,590,591,592,593,594)) Union All

Select Count(*) As RecordCount,'Common.CompanyUser' As TableName From Common.CompanyUser
Where CompanyId In (Select ID From Common.Company Where Id NOT in (589,590,591,592,593,594)) Union All

Select Count(*) As RecordCount,'Common.Configuration' As TableName From Common.Configuration
Where CompanyId In (Select ID From Common.Company Where Id NOT in (589,590,591,592,593,594)) Union All

Select Count(*) As RecordCount,'Common.Contact' As TableName From Common.Contact
Where CompanyId In (Select ID From Common.Company Where Id NOT in (589,590,591,592,593,594)) Union All

Select Count(*) As RecordCount,'Common.ContactDetails' As TableName From Common.ContactDetails CD
Inner Join Common.Contact C on C.Id=CD.ContactId
Where CompanyId In (Select ID From Common.Company Where Id NOT in (589,590,591,592,593,594)) Union All

Select Count(*) As RecordCount,'Common.ControlCodeCategory' As TableName From Common.ControlCodeCategory
Where CompanyId In (Select ID From Common.Company Where Id NOT in (589,590,591,592,593,594)) Union All

Select Count(*) As RecordCount,'Common.ControlCodeCategoryModule' As TableName From Common.ControlCodeCategoryModule
Where CompanyId In (Select ID From Common.Company Where Id NOT in (589,590,591,592,593,594)) Union All

Select Count(*) As RecordCount,'Common.ControlCode' As TableName From Common.ControlCode CC
Inner Join Common.ControlCodeCategory CCC on CCC.Id=CC.ControlCategoryId
Where CompanyId In (Select ID From Common.Company Where Id NOT in (589,590,591,592,593,594)) Union All

Select Count(*) As RecordCount,'Common.Currency' As TableName From Common.Currency
Where CompanyId In (Select ID From Common.Company Where Id NOT in (589,590,591,592,593,594)) Union All

Select Count(*) As RecordCount,'Common.Department' As TableName From Common.Department 
WHERE CompanyId In (Select ID From Common.Company Where Id NOT in (589,590,591,592,593,594)) Union All

Select Count(*) As RecordCount,'Common.DepartmentDesignation' As TableName From Common.DepartmentDesignation DD
Inner JOin Common.Department D on D.id=DD.DepartmentId
WHERE D.CompanyId In (Select ID From Common.Company Where Id NOT in (589,590,591,592,593,594)) Union All

Select Count(*) As RecordCount,'Common.Designation' As TableName From Common.Designation 
WHERE CompanyId In (Select ID From Common.Company Where Id NOT in (589,590,591,592,593,594)) Union All

Select Count(*) As RecordCount,'Common.DesignationHourlyRate' As TableName From Common.DesignationHourlyRate DH
Inner join  Common.Department  D ON D.id=DH.DepartmentId
WHERE D.CompanyId In (Select ID From Common.Company Where Id NOT in (589,590,591,592,593,594)) Union All

Select Count(*) As RecordCount,'Common.DesignationLevel' As TableName From Common.DesignationLevel 
WHERE CompanyId In (Select ID From Common.Company Where Id NOT in (589,590,591,592,593,594)) Union All


Select Count(*) As RecordCount,'Common.DesignationLevelChargeoutRate' As TableName From Common.DesignationLevelChargeoutRate DLC
INNER JOIN Common.DesignationLevel DL ON DL.id=DLC.DesignationLevelId
WHERE DL.CompanyId In (Select ID From Common.Company Where Id NOT in (589,590,591,592,593,594)) Union All


Select Count(*) As RecordCount,'Common.DocRepository' As TableName From Common.DocRepository 
WHERE CompanyId In (Select ID From Common.Company Where Id NOT in (589,590,591,592,593,594)) Union All

Select Count(*) As RecordCount,'Common.Employee' As TableName From Common.Employee 
WHERE CompanyId In (Select ID From Common.Company Where Id NOT in (589,590,591,592,593,594)) Union All

Select Count(*) As RecordCount,'Common.EmployeeChargeRate' As TableName From Common.EmployeeChargeRate EC
INNER JOIN Common.Employee e ON e.id=EC.EmployeeId
WHERE e.CompanyId In (Select ID From Common.Company Where Id NOT in (589,590,591,592,593,594)) Union All

Select Count(*) As RecordCount,'Common.EmployeeQualification' As TableName From Common.EmployeeQualification EQ
INNER JOIN Common.Employee e ON e.id=Eq.EmployeeId
WHERE e.CompanyId In (Select ID From Common.Company Where Id NOT in (589,590,591,592,593,594)) Union All


Select Count(*) As RecordCount,'Common.EmployeeServiceGroup' As TableName From Common.EmployeeServiceGroup ESG
INNER JOIN Common.Employee e ON e.id=ESG.EmployeeId
WHERE e.CompanyId In (Select ID From Common.Company Where Id NOT in (589,590,591,592,593,594)) Union All


Select Count(*) As RecordCount,'Common.EmployeeSkill' As TableName From Common.EmployeeSkill EK
INNER JOIN Common.Employee e ON e.id=EK.EmployeeId
WHERE e.CompanyId In (Select ID From Common.Company Where Id NOT in (589,590,591,592,593,594)) Union All

Select Count(*) As RecordCount,'Common.EntityDetail' As TableName From Common.EntityDetail 
WHERE CompanyId In (Select ID From Common.Company Where Id NOT in (589,590,591,592,593,594)) Union All

Select Count(*) As RecordCount,'Common.EntityType' As TableName From Common.EntityType 
WHERE CompanyId In (Select ID From Common.Company Where Id NOT in (589,590,591,592,593,594)) Union All

Select Count(*) As RecordCount,'Common.EntityTypeVariables' As TableName From Common.EntityTypeVariables ETV
INNER JOIN Common.EntityType  ET ON ET.id=ETV.EntityTypeId
WHERE ET.CompanyId In (Select ID From Common.Company Where Id NOT in (589,590,591,592,593,594)) Union All


Select Count(*) As RecordCount,'Common.Feature' As TableName From Common.Feature F
INNER JOIN  Common.ModuleMaster MM On MM.Id=F.ModuleId
WHERE MM.CompanyId In (Select ID From Common.Company Where Id NOT in (589,590,591,592,593,594)) Union All

Select Count(*) As RecordCount,'Common.FeeRecoverySetting' As TableName From Common.FeeRecoverySetting 
WHERE CompanyId In (Select ID From Common.Company Where Id NOT in (589,590,591,592,593,594)) Union All


Select Count(*) As RecordCount,'Common.GenericTemplate' As TableName From Common.GenericTemplate 
WHERE CompanyId In (Select ID From Common.Company Where Id NOT in (589,590,591,592,593,594)) Union All


Select Count(*) As RecordCount,'Common.GenericTemplateDetail' As TableName From Common.GenericTemplateDetail GTD
INNER JOIN Common.GenericTemplate  GT ON GT.id=GTD.GenericTemplateId
WHERE GT.CompanyId In (Select ID From Common.Company Where Id NOT in (589,590,591,592,593,594)) Union All

Select Count(*) As RecordCount,'Common.GenericTemplateRelatedTo' As TableName From Common.GenericTemplateRelatedTo GTR
INNER JOIN Common.GenericTemplate  GT ON GT.id=GTR.TemplateId
WHERE GT.CompanyId In (Select ID From Common.Company Where Id NOT in (589,590,591,592,593,594)) Union All

Select Count(*) As RecordCount,'Common.GeoPC_Business' As TableName From Common.GeoPC_Business  --No Relation
Union All

Select Count(*) As RecordCount,'Common.GeoPC_Places' As TableName From Common.GeoPC_Places --No Relation
Union All

Select Count(*) As RecordCount,'Common.GeoPC_Regions' As TableName From Common.GeoPC_Regions --No Relation
Union All

Select Count(*) As RecordCount,'Common.Common.GeoPC_Streets' As TableName From Common.GeoPC_Streets --No Relation
Union All

Select Count(*) As RecordCount,'Common.GSTDetail' As TableName From Common.GSTDetail GD
INNER JOIN Common.ModuleMaster MM ON MM.Id =GD.ModuleMasterId
WHERE MM.CompanyId In (Select ID From Common.Company Where Id NOT in (589,590,591,592,593,594)) Union All

Select Count(*) As RecordCount,'Common.GSTSetting' As TableName From Common.GSTSetting 
WHERE CompanyId In (Select ID From Common.Company Where Id NOT in (589,590,591,592,593,594)) Union All

Select Count(*) As RecordCount,'Common.Holiday' As TableName From Common.Holiday 
WHERE CompanyId In (Select ID From Common.Company Where Id NOT in (589,590,591,592,593,594)) Union All

Select Count(*) As RecordCount,'Common.HRSettingdetails' As TableName From Common.HRSettingdetails HSD
INNER JOIN Common.HRSettings H ON H.Id=HSD.MasterId
WHERE H.CompanyId In (Select ID From Common.Company Where Id NOT in (589,590,591,592,593,594)) Union All

Select Count(*) As RecordCount,'Common.HRSettings' As TableName From Common.HRSettings 
WHERE CompanyId In (Select ID From Common.Company Where Id NOT in (589,590,591,592,593,594)) Union All

Select Count(*) As RecordCount,'Common.IdType' As TableName From Common.IdType 
WHERE CompanyId In (Select ID From Common.Company Where Id NOT in (589,590,591,592,593,594)) Union All

Select Count(*) As RecordCount,'Common.Industry' As TableName From Common.Industry 
WHERE CompanyId In (Select ID From Common.Company Where Id NOT in (589,590,591,592,593,594)) Union All


Select Count(*) As RecordCount,'Common.InitialCursorSetup' As TableName From Common.InitialCursorSetup 
WHERE CompanyId In (Select ID From Common.Company Where Id NOT in (589,590,591,592,593,594)) Union All

Select Count(*) As RecordCount,'Common.LeadBatch' As TableName From Common.LeadBatch -- No Relations
Union All

Select Count(*) As RecordCount,'Common.Level' As TableName From Common.Level  l
Inner join Common.DesignationLevel DL ON Dl.levelid=l.id
WHERE Dl.CompanyId In (Select ID From Common.Company Where Id NOT in (589,590,591,592,593,594)) Union All

Select Count(*) As RecordCount,'Common.Localization' As TableName From Common.Localization  
WHERE CompanyId In (Select ID From Common.Company Where Id NOT in (589,590,591,592,593,594)) Union All

Select Count(*) As RecordCount,'Common.MediaRepositories' As TableName From Common.MediaRepositories MR
Inner join Common.MediaRepository M on M.Id=MR.MediaRepositoryId
WHERE M.CompanyId In (Select ID From Common.Company Where Id NOT in (589,590,591,592,593,594)) Union All

Select Count(*) As RecCount ,'Common.AddressBook' As TableName From Common.AddressBook As AB
Inner Join Common.Addresses As A On A.AddressBookId=Ab.Id
Where A.CompanyId in (589,590,591,592,593,594) Union All


Select Count(*) As RecordCount,'Common.MediaRepository' As TableName From Common.MediaRepository 
WHERE CompanyId In (Select ID From Common.Company Where Id NOT in (589,590,591,592,593,594)) Union All

Select Count(*) As RecordCount,'Common.MessageDetail' As TableName From Common.MessageDetail MD
Inner join Common.MessageMaster MM ON MM.Id=MD.MasterId
WHERE MM.CompanyId In (Select ID From Common.Company Where Id NOT in (589,590,591,592,593,594)) Union All


Select Count(*) As RecordCount,'Common.MessageMaster' As TableName From Common.MessageMaster 
WHERE CompanyId In (Select ID From Common.Company Where Id NOT in (589,590,591,592,593,594)) Union All

Select Count(*) As RecordCount,'Common.Milestone' As TableName From Common.Milestone M
Inner Join Common.ServiceGroup SG ON SG.Id=M.ServiceGroupId
WHERE SG.CompanyId In (Select ID From Common.Company Where Id NOT in (589,590,591,592,593,594)) Union All

Select Count(*) As RecordCount,'Common.ModuleDetail_MdlMaster' As TableName From Common.ModuleDetail MD
Inner Join Common.ModuleMaster MM ON MM.id=MD.ModuleMasterId
WHERE MM.CompanyId In (Select ID From Common.Company Where Id NOT in (589,590,591,592,593,594)) Union All

Select Count(*) As RecordCount,'Common.ModuleMaster' As TableName From Common.ModuleMaster 
WHERE CompanyId In (Select ID From Common.Company Where Id NOT in (589,590,591,592,593,594)) Union All

Select Count(*) As RecordCount,'Common.Postalcode' As TableName From Common.Postalcode  -- Preference
Union All

Select Count(*) As RecordCount,'Common.Preference' As TableName From Common.Preference  --Preference
Union All

Select Count(*) As RecordCount,'Common.ReminderBatchList' As TableName From Common.ReminderBatchList 
WHERE CompanyId In (Select ID From Common.Company Where Id NOT in (589,590,591,592,593,594)) Union All


Select Count(*) As RecordCount,'Common.ReminderSetting' As TableName From Common.ReminderSetting 
WHERE CompanyId In (Select ID From Common.Company Where Id NOT in (589,590,591,592,593,594)) Union All


--Select Count(*) As RecordCount,'Common.Reply' As TableName From Common.Reply R 
--Inner join Common.Comment C On C.id=R.CommentId
--WHERE C.CompanyId In (Select ID From Common.Company Where Id NOT in (589,590,591,592,593,594)) Union All -- NoRElation

Select Count(*) As RecordCount,'Common.Service' As TableName From Common.Service S
Inner join Common.ServiceGroup SG ON SG.Id=S.ServiceGroupId
WHERE SG.CompanyId In (Select ID From Common.Company Where Id NOT in (589,590,591,592,593,594)) Union All 

Select Count(*) As RecordCount,'Common.ServiceGroup' As TableName From Common.ServiceGroup 
WHERE CompanyId In (Select ID From Common.Company Where Id NOT in (589,590,591,592,593,594)) Union All 

Select Count(*) As RecordCount,'Common.ServiceRate' As TableName From Common.ServiceRate SR
Inner join Common.ServiceGroup SG ON SG.Id=SR.ServiceGroupId
WHERE SG.CompanyId In (Select ID From Common.Company Where Id NOT in (589,590,591,592,593,594)) Union All 


Select Count(*) As RecordCount,'Common.ServiceRateDetail' As TableName From Common.ServiceRateDetail SRD
Inner join Common.Designation D ON D.Id=SRD.DesignationId
WHERE D.CompanyId In (Select ID From Common.Company Where Id NOT in (589,590,591,592,593,594)) Union All

Select Count(*) As RecordCount,'Common.ServiceRecuringSettings' As TableName From Common.ServiceRecuringSettings SRS
Inner join  Common.Service S on s.id=SRS.ServiceId
Inner join Common.ServiceGroup SG ON SG.id=S.ServiceGroupId
WHERE SG.CompanyId In (Select ID From Common.Company Where Id NOT in (589,590,591,592,593,594)) Union All  

Select Count(*) As RecordCount,'Common.ServiceTemplate' As TableName From Common.ServiceTemplate SRS
Inner join  Common.Service S on s.id=SRS.ServiceId
Inner join Common.ServiceGroup SG ON SG.id=S.ServiceGroupId
WHERE SG.CompanyId In (Select ID From Common.Company Where Id NOT in (589,590,591,592,593,594)) Union All  

Select Count(*) As RecordCount,'Common.StateChange' As TableName From Common.StateChange 
WHERE CompanyId In (Select ID From Common.Company Where Id NOT in (589,590,591,592,593,594)) Union All  



Select Count(*) As RecordCount,'Common.Streets' As TableName From Common.Streets --No Relationa
Union All

Select Count(*) As RecordCount,'Common.Suggestion' As TableName From Common.Suggestion 
WHERE CompanyId In (Select ID From Common.Company Where Id NOT in (589,590,591,592,593,594)) Union All  


Select Count(*) As RecordCount,'Common.Task' As TableName From Common.Task T
Inner JOIN Common.ServiceGroup SG ON SG.Id=T.ServiceGroupId
WHERE SG.CompanyId In (Select ID From Common.Company Where Id NOT in (589,590,591,592,593,594)) Union All  

Select Count(*) As RecordCount,'Common.Template' As TableName From Common.Template 
WHERE CompanyId In (Select ID From Common.Company Where Id NOT in (589,590,591,592,593,594)) Union All  

Select Count(*) As RecordCount,'Common.TemplateAttachment' As TableName From Common.TemplateAttachment TA
Inner join Common.Template T ON T.ID=TA.TemplateId
WHERE T.CompanyId In (Select ID From Common.Company Where Id NOT in (589,590,591,592,593,594)) Union All  

Select Count(*) As RecordCount,'Common.TemplateDetail' As TableName From Common.TemplateDetail TA
Inner join Common.TemplateMaster TM ON TM.ID=TA.MasterId
WHERE TM.CompanyId In (Select ID From Common.Company Where Id NOT in (589,590,591,592,593,594)) Union All  


Select Count(*) As RecordCount,'Common.TemplateMaster' As TableName From Common.TemplateMaster 
WHERE CompanyId In (Select ID From Common.Company Where Id NOT in (589,590,591,592,593,594)) Union All  


Select Count(*) As RecordCount,'Common.TemplateRelatedTo' As TableName From Common.TemplateRelatedTo TA
Inner join Common.Template T ON T.ID=TA.TemplateId
WHERE T.CompanyId In (Select ID From Common.Company Where Id NOT in (589,590,591,592,593,594)) Union All  



Select Count(*) As RecordCount,'Common.TemplateSent' As TableName From Common.TemplateSent TS
Inner join Common.Template T ON T.ID=TS.TemplateId
WHERE T.CompanyId In (Select ID From Common.Company Where Id NOT in (589,590,591,592,593,594)) Union All  

Select Count(*) As RecordCount,'Common.TemplateSetUp' As TableName From Common.TemplateSetUp 
WHERE CompanyId In (Select ID From Common.Company Where Id NOT in (589,590,591,592,593,594)) Union All  

Select Count(*) As RecordCount,'Common.TemplateSetUpDetail' As TableName From Common.TemplateSetUpDetail TSD
Inner join Common.TemplateSetUp TS ON TS.Id= TSD.TemplateSetUpId
WHERE TS.CompanyId In (Select ID From Common.Company Where Id NOT in (589,590,591,592,593,594)) Union All  

Select Count(*) As RecordCount,'Common.TemplateType' As TableName From Common.TemplateType 
WHERE CompanyId In (Select ID From Common.Company Where Id NOT in (589,590,591,592,593,594)) Union All  

Select Count(*) As RecordCount,'Common.TemplateTypeDetail' As TableName From Common.TemplateTypeDetail  TT
Inner join Common.TemplateType T ON T.Id=TT.TemplateTypeId
WHERE T.CompanyId In (Select ID From Common.Company Where Id NOT in (589,590,591,592,593,594)) Union All  

Select Count(*) As RecordCount,'Common.TermsOfPayment' As TableName From Common.TermsOfPayment  
WHERE CompanyId In (Select ID From Common.Company Where Id NOT in (589,590,591,592,593,594)) Union All


Select Count(*) As RecordCount,'Common.TimeLog' As TableName From Common.TimeLog  
WHERE CompanyId In (Select ID From Common.Company Where Id NOT in (589,590,591,592,593,594)) Union All  


Select Count(*) As RecordCount,'Common.TimeLogDetail' As TableName From Common.TimeLogDetail TD
Inner join  Common.TimeLog  T on T.id=TD.MasterId
WHERE T.CompanyId In (Select ID From Common.Company Where Id NOT in (589,590,591,592,593,594)) Union All 


Select Count(*) As RecordCount,'Common.TimeLogDetailSplit' As TableName From Common.TimeLogDetailSplit TDS
Inner join Common.TimeLogDetail TD on TD.id=TDS.TimelogDetailId
Inner join  Common.TimeLog  T on T.id=TD.MasterId
WHERE T.CompanyId In (Select ID From Common.Company Where Id NOT in (589,590,591,592,593,594)) Union All   


Select Count(*) As RecordCount,'Common.TimeLogItem' As TableName From Common.TimeLogItem 
WHERE CompanyId In (Select ID From Common.Company Where Id NOT in (589,590,591,592,593,594)) Union All   


Select Count(*) As RecordCount,'Common.TimeLogItemDetail' As TableName From Common.TimeLogItemDetail TID
Inner join Common.TimeLogItem T ON T.Id=TID.TimeLogItemId
WHERE T.CompanyId In (Select ID From Common.Company Where Id NOT in (589,590,591,592,593,594)) Union All 

Select Count(*) As RecordCount,'Common.TimeLogSchedule' As TableName From Common.TimeLogSchedule TID
Inner join Common.Employee e ON e.Id=TID.EmployeeId
WHERE e.CompanyId In (Select ID From Common.Company Where Id NOT in (589,590,591,592,593,594)) Union All 

Select Count(*) As RecordCount,'Common.TimeLogSettings' As TableName From Common.TimeLogSettings 
WHERE CompanyId In (Select ID From Common.Company Where Id NOT in (589,590,591,592,593,594)) Union All 

Select Count(*) As RecordCount,'Common.UserAccountCursors' As TableName From Common.UserAccountCursors uac
Inner join Common.ModuleMaster mm on mm.id=uac.ModuleMasterId
WHERE mm.CompanyId In (Select ID From Common.Company Where Id NOT in (589,590,591,592,593,594)) Union All 

Select Count(*) As RecordCount,'Common.ViewPermission' As TableName From Common.ViewPermission VP
Inner join Common.ModuleMaster mm on mm.id=VP.ModuleDetailId
WHERE mm.CompanyId In (Select ID From Common.Company Where Id NOT in (589,590,591,592,593,594)) Union All

Select Count(*) As RecordCount,'Common.Walkup' As TableName From Common.Walkup -- No Relations
Union All


Select Count(*) As RecordCount,'Common.Widget' As TableName From Common.Widget 
WHERE CompanyId In (Select ID From Common.Company Where Id NOT in (589,590,591,592,593,594)) Union All


Select Count(*) As RecordCount,'Common.WorkWeekSetUp' As TableName From Common.WorkWeekSetUp 
WHERE CompanyId In (Select ID From Common.Company Where Id NOT in (589,590,591,592,593,594)) Union All


--//HR

select Count(*) As RecordCount,'HR.AdditionalFormMetadata' As TableName From HR.AdditionalFormMetadata 
Where CompanyId In (Select ID From Common.Company Where Id NOT in (589,590,591,592,593,594)) Union All

select Count(*) As RecordCount,'HR.AgencyFund' As TableName From HR.AgencyFund 
where CompanyId In (Select ID From Common.Company Where Id NOT in (589,590,591,592,593,594)) Union All

select Count(*) As RecordCount,'HR.AgencyFundDetail' As TableName From HR.AgencyFundDetail AFD inner join HR.AgencyFund AF on AFD.AgencyFundId=AF.Id 
where AF.companyid In (Select ID From Common.Company Where Id NOT in (589,590,591,592,593,594)) Union All

select Count(*) As RecordCount,'HR.Appraisal' As TableName From HR.Appraisal  
where CompanyId In (Select ID From Common.Company Where Id NOT in (589,590,591,592,593,594)) Union All

select Count(*) As RecordCount,'HR.AppraisalAppraiseeDetails'  As TableName From HR.AppraisalAppraiseeDetails  AAD 
Inner join HR.Appraisal A on  AAD.AppraisalId=A.Id
where A.CompanyId In (Select ID From Common.Company Where Id NOT in (589,590,591,592,593,594)) Union All

select Count(*) As RecordCount,'HR.AppraisalAppraiserDetails' As TableName From HR.AppraisalAppraiserDetails AAD
Inner Join HR.Appraisal A on AAD.AppraisalId=A.Id 
where A.CompanyId In (Select ID From Common.Company Where Id NOT in (589,590,591,592,593,594)) Union All

select Count(*) As RecordCount,'HR.AppraisalDetail' As TableName From HR.AppraisalDetail AD 
Inner Join HR.Appraisal A on AD.AppraisalId=A.Id
where A.CompanyId In (Select ID From Common.Company Where Id NOT in (589,590,591,592,593,594)) Union All

select Count(*) As RecordCount,'HR.AppraisalDevelopmentPlan' As TableName From HR.AppraisalDevelopmentPlan ADP 
Inner Join HR.Appraisal A on ADP.AppraisalId=A.Id 
where A.CompanyId In (Select ID From Common.Company Where Id NOT in (589,590,591,592,593,594)) Union All

select Count(*) As RecordCount,'HR.AppraisalResult' As TableName From HR.AppraisalResult AR 
Inner Join HR.Appraisal A on AR.AppraisalId=A.Id
where A.CompanyId In (Select ID From Common.Company Where Id NOT in (589,590,591,592,593,594)) Union All

select Count(*) As RecordCount,'HR.AppraisalSummary' As TableName From HR.AppraisalSummary APS
Inner Join HR.Appraisal A on APS.AppraisalId=A.Id
where A.CompanyId In (Select ID From Common.Company Where Id NOT in (589,590,591,592,593,594)) Union All



select Count(*) As RecordCount,'HR.Asset' As TableName From HR.Asset 
where CompanyId In (Select ID From Common.Company Where Id NOT in (589,590,591,592,593,594)) Union All

select Count(*) As RecordCount,'HR.ClaimItem' As TableName From HR.ClaimItem
where CompanyId In (Select ID From Common.Company Where Id NOT in (589,590,591,592,593,594)) Union All

select Count(*) As RecordCount,'HR.ClaimsEntitlement' As TableName From HR.ClaimsEntitlement
where CompanyId In (Select ID From Common.Company Where Id NOT in (589,590,591,592,593,594)) Union All

select Count(*) As RecordCount,'HR.ClaimSetup' As TableName From HR.ClaimSetup 
where CompanyId In (Select ID From Common.Company Where Id NOT in (589,590,591,592,593,594)) Union All

select Count(*) As RecordCount,'HR.ClaimSetupDetail' As TableName From HR.ClaimSetupDetail CSD
Inner Join HR.ClaimItem CI on CSD.ClaimItemId=CI.Id
Where CI.companyId In (Select ID From Common.Company Where Id NOT in (589,590,591,592,593,594)) Union All

select Count(*) As RecordCount,'HR.CompanyPayrollSettings' As TableName From HR.CompanyPayrollSettings 
where CompanyId In (Select ID From Common.Company Where Id NOT in (589,590,591,592,593,594)) Union All

select Count(*) As RecordCount,'HR.CompanyPayrollSettingsDetail' As TableName From HR.CompanyPayrollSettingsDetail CPSD
Inner Join HR.CompanyPayrollSettings CPS on CPSD.MasterId=CPS.Id
where CPS.CompanyId In (Select ID From Common.Company Where Id NOT in (589,590,591,592,593,594)) Union All

select Count(*) As RecordCount,'HR.Competence' As TableName From HR.Competence 
where CompanyId In (Select ID From Common.Company Where Id NOT in (589,590,591,592,593,594)) Union All

select Count(*) As RecordCount,'HR.CompetenceDetail' As TableName From HR.CompetenceDetail CD
Inner Join HR.Competence C On CD.MasterId=C.Id
where C.CompanyId In (Select ID From Common.Company Where Id NOT in (589,590,591,592,593,594)) Union All

select Count(*) As RecordCount,'HR.CourseLibrary' As TableName From HR.CourseLibrary
where CompanyId In (Select ID From Common.Company Where Id NOT in (589,590,591,592,593,594)) Union All

select Count(*) As RecordCount,'HR.CPFSettings' As TableName From HR.CPFSettings 
where CompanyId In (Select ID From Common.Company Where Id NOT in (589,590,591,592,593,594)) Union All

select Count(*) As RecordCount,'HR.DevelopmentPlan' As TableName From HR.DevelopmentPlan
where CompanyId In (Select ID From Common.Company Where Id NOT in (589,590,591,592,593,594)) Union All

select Count(*) As RecordCount,'HR.Education' As TableName From HR.Education E
Inner Join HR.JobApplication JA on E.ApplicationId=JA.Id
where CompanyId In (Select ID From Common.Company Where Id NOT in (589,590,591,592,593,594)) Union All

select Count(*) As RecordCount,'HR.EmployeeBankDetails' As TableName From HR.EmployeeBankDetails
where CompanyId In (Select ID From Common.Company Where Id NOT in (589,590,591,592,593,594)) Union All


select Count(*) As RecordCount,'HR.EmployeeClaim1' As TableName From HR.EmployeeClaim1
where CompanyId In (Select ID From Common.Company Where Id NOT in (589,590,591,592,593,594)) Union All

select Count(*) As RecordCount,'HR.EmployeeClaimDetail' As TableName From HR.EmployeeClaimDetail ECD
Inner Join HR.ClaimItem CI on ECD.ClaimItemId=CI.Id 
where CI.CompanyId In (Select ID From Common.Company Where Id NOT in (589,590,591,592,593,594)) Union All

select Count(*) As RecordCount,'HR.EmployeeClaimsEntitlement' As TableName From HR.EmployeeClaimsEntitlement 
where CompanyId In (Select ID From Common.Company Where Id NOT in (589,590,591,592,593,594)) Union All

select Count(*) As RecordCount,'HR.EmployeeClaimsEntitlementDetail' As TableName From HR.EmployeeClaimsEntitlementDetail ECE
inner join HR.ClaimItem CI on ECE.ClaimItemId=CI.Id
where CI.CompanyId In (Select ID From Common.Company Where Id NOT in (589,590,591,592,593,594)) Union All


select Count(*) As RecordCount,'HR.EmployeeDepartment' As TableName From HR.EmployeeDepartment
where CompanyId In (Select ID From Common.Company Where Id NOT in (589,590,591,592,593,594)) Union All

select Count(*) As RecordCount,'HR.EmployeePayrollSetting' As TableName From HR.EmployeePayrollSetting
where CompanyId In (Select ID From Common.Company Where Id NOT in (589,590,591,592,593,594)) Union All

select Count(*) As RecordCount,'HR.EmployeeProjects' As TableName From HR.EmployeeProjects 
where CompanyId In (Select ID From Common.Company Where Id NOT in (589,590,591,592,593,594)) Union All

select Count(*) As RecordCount,'HR.Employment' As TableName From HR.Employment 
where CompanyId In (Select ID From Common.Company Where Id NOT in (589,590,591,592,593,594)) Union All

select Count(*) As RecordCount,'HR.EmploymentHistory' As TableName From HR.EmploymentHistory EH
Inner JOin HR.JobApplication JA on EH.ApplicationId=JA.Id
where JA.CompanyId In (Select ID From Common.Company Where Id NOT in (589,590,591,592,593,594)) Union All

select Count(*) As RecordCount,'HR.Evaluation'  As TableName From HR.Evaluation E
Inner join HR.JobApplication JA on E.ApplicationId=JA.Id
where JA.CompanyId In (Select ID From Common.Company Where Id NOT in (589,590,591,592,593,594)) Union All

select Count(*) As RecordCount,'HR.EvaluationDetails' As TableName From HR.EvaluationDetails 
where CompanyId In (Select ID From Common.Company Where Id NOT in (589,590,591,592,593,594)) Union All
 
select Count(*) As RecordCount,'HR.FamilyDetails' As TableName From HR.FamilyDetails FD
Inner Join Common.Employee E on FD.EmployeeId=E.Id
where E.CompanyId In (Select ID From Common.Company Where Id NOT in (589,590,591,592,593,594)) Union All

select Count(*) As RecordCount,'HR.FamilyPerticulars' As TableName From HR.FamilyPerticulars FP
Inner Join HR.JobApplication JA on FP.ApplicationId =JA.Id
where JA.CompanyId In (Select ID From Common.Company Where Id NOT in (589,590,591,592,593,594)) Union All


--NO Relation
select Count(*) As RecordCount,'HR.HrAuditTrails' As TableName From HR.HrAuditTrails
Union All

select Count(*) As RecordCount,'HR.Interview' As TableName From HR.Interview I
Inner Join HR.JobApplication JA On I.ApplicationId=JA.Id
Where JA.CompanyId In (Select ID From Common.Company Where Id NOT in (589,590,591,592,593,594)) Union All

select Count(*) As RecordCount,'HR.JobApplication' As TableName From HR.JobApplication 
where CompanyId In (Select ID From Common.Company Where Id NOT in (589,590,591,592,593,594)) Union All

select Count(*) As RecordCount,'HR.JobPosting' As TableName From HR.JobPosting 
where CompanyId In (Select ID From Common.Company Where Id NOT in (589,590,591,592,593,594)) Union All

select Count(*) As RecordCount,'HR.LeaveApplication' As TableName From HR.LeaveApplication
where CompanyId In (Select ID From Common.Company Where Id NOT in (589,590,591,592,593,594)) Union All

select Count(*) As RecordCount,'HR.LeaveApplicationHistory' As TableName From HR.LeaveApplicationHistory LAH
Inner Join HR.LeaveApplication LA on LAH.LeaveApplicationId=LA.Id
where LA.CompanyId In (Select ID From Common.Company Where Id NOT in (589,590,591,592,593,594)) Union All

select Count(*) As RecordCount,'HR.LeaveEntitlement' As TableName From HR.LeaveEntitlement LE
Inner Join HR.LeaveType LT on LE.LeaveTypeId=LT.Id
Where LT.CompanyId In (Select ID From Common.Company Where Id NOT in (589,590,591,592,593,594)) Union All

select Count(*) As RecordCount,'HR.LeaveEntitlementAdjustment' As TableName From HR.LeaveEntitlementAdjustment LEA
Inner join  HR.LeaveEntitlement LE on LEA.LeaveEntitlementId=LE.Id inner Join HR.LeaveType LT on LE.LeaveTypeId=LT.Id
where LT.CompanyId In (Select ID From Common.Company Where Id NOT in (589,590,591,592,593,594)) Union All

select Count(*) As RecordCount,'HR.LeaveRequest' As TableName From HR.LeaveRequest
where CompanyId In (Select ID From Common.Company Where Id NOT in (589,590,591,592,593,594)) Union All

select Count(*) As RecordCount,'HR.LeaveRequestHistory' As TableName From HR.LeaveRequestHistory LRH
Inner Join HR.LeaveRequest LR on LRH.LeaveRequestId=LR.Id 
where LR.CompanyId In (Select ID From Common.Company Where Id NOT in (589,590,591,592,593,594)) Union All

select Count(*) As RecordCount,'HR.LeaveSetup' As TableName From HR.LeaveSetup 
where CompanyId In (Select ID From Common.Company Where Id NOT in (589,590,591,592,593,594)) Union All

select Count(*) As RecordCount,'HR.LeaveSetupEmployees' As TableName From HR.LeaveSetupEmployees LSE
Inner Join Common.Employee E on LSE.LeaveStatusChangedEmployeeId=E.Id
where E.CompanyId nOT in (589,590,591,592,593,594) Union All

select Count(*) As RecordCount,'HR.LeavesReport' As TableName From HR.LeavesReport 
where CompanyId In (Select ID From Common.Company Where Id NOT in (589,590,591,592,593,594)) Union All

select Count(*) As RecordCount,'HR.LeaveType' As TableName From HR.LeaveType 
where CompanyId In (Select ID From Common.Company Where Id NOT in (589,590,591,592,593,594)) Union All

select Count(*) As RecordCount,'HR.LeaveTypeDetails' As TableName From HR.LeaveTypeDetails LTD
Inner Join HR.LeaveType LT on LTD.LeaveTypeId=LT.Id
where LT.CompanyId NOT in(589,590,591,592,593,594) Union All

select Count(*) As RecordCount,'HR.Objective' As TableName From HR.Objective
where CompanyId In (Select ID From Common.Company Where Id NOT in (589,590,591,592,593,594)) Union All

select Count(*) As RecordCount,'HR.PayComponent' As TableName From HR.PayComponent
where CompanyId In (Select ID From Common.Company Where Id NOT in (589,590,591,592,593,594)) Union All

select Count(*) As RecordCount,'HR.PayComponentDetail' As TableName From HR.PayComponentDetail PCD
Inner Join HR.PayComponent PC On PCD.MasterId=PC.Id
Where PC.CompanyId In (Select ID From Common.Company Where Id NOT in (589,590,591,592,593,594)) Union All

select Count(*) As RecordCount,'HR.Payroll' As TableName From HR.Payroll 
where CompanyId In (Select ID From Common.Company Where Id NOT in (589,590,591,592,593,594)) Union All

select Count(*) As RecordCount,'HR.PayrollDetails' As TableName From HR.PayrollDetails PD
Inner Join HR.Payroll P On PD.MasterId=P.Id
where P.CompanyId In (Select ID From Common.Company Where Id NOT in (589,590,591,592,593,594)) Union All

select Count(*) As RecordCount,'HR.PayrollSplit' As TableName From HR.PayrollSplit PS
Inner Join HR.PayComponent PC On PS.PayComponentId=PC.Id
where PC.CompanyId In (Select ID From Common.Company Where Id NOT in (589,590,591,592,593,594)) Union All

select Count(*) As RecordCount,'HR.Project' As TableName From HR.Project
where CompanyId In (Select ID From Common.Company Where Id NOT in (589,590,591,592,593,594)) Union All

select Count(*) As RecordCount,'HR.Qualification' As TableName From HR.Qualification Q
Inner Join Common.Employee E on Q.EmployeeId=E.Id
where E.CompanyId NOT in (589,590,591,592,593,594) Union All

select Count(*) As RecordCount,'HR.Question' As TableName From HR.Question
where CompanyId In (Select ID From Common.Company Where Id NOT in (589,590,591,592,593,594)) Union All

select Count(*) As RecordCount,'HR.QuestionCompetence' As TableName From HR.QuestionCompetence QC
Inner Join HR.Question Q on QC.QuestionId=Q.Id
where Q.CompanyId In (Select ID From Common.Company Where Id NOT in (589,590,591,592,593,594)) Union All

select Count(*) As RecordCount,'HR.Questionnaire' As TableName From HR.Questionnaire
where CompanyId In (Select ID From Common.Company Where Id NOT in (589,590,591,592,593,594)) Union All

select Count(*) As RecordCount,'HR.QuestionnaireDetail' As TableName From HR.QuestionnaireDetail QD
Inner Join HR.Question Q on QD.QuestionId=Q.Id
where Q.CompanyId In (Select ID From Common.Company Where Id NOT in (589,590,591,592,593,594)) Union All

select Count(*) As RecordCount,'HR.QuestionnaireObjective' As TableName From HR.QuestionnaireObjective QO
Inner Join HR.Questionnaire Q on QO.QuestionnaireId=Q.Id
where Q.CompanyId In (Select ID From Common.Company Where Id NOT in (589,590,591,592,593,594)) Union All

select Count(*) As RecordCount,'HR.Requisition' As TableName From HR.Requisition
where CompanyId In (Select ID From Common.Company Where Id NOT in (589,590,591,592,593,594)) Union All

select Count(*) As RecordCount,'HR.SDL' As TableName From HR.SDL
where CompanyId In (Select ID From Common.Company Where Id NOT in (589,590,591,592,593,594)) Union All

select Count(*) As RecordCount,'HR.Trainer' As TableName From HR.Trainer
where CompanyId In (Select ID From Common.Company Where Id NOT in (589,590,591,592,593,594)) Union All

select Count(*) As RecordCount,'HR.TrainerCourse' As TableName From HR.TrainerCourse TC
inner join HR.Trainer T on TC.TrainerId=T.Id
where T.CompanyId In (Select ID From Common.Company Where Id NOT in (589,590,591,592,593,594)) Union All

select Count(*) As RecordCount,'HR.Training' As TableName From HR.Training
where CompanyId In (Select ID From Common.Company Where Id NOT in (589,590,591,592,593,594)) Union All

select Count(*) As RecordCount,'HR.TrainingAttendance' As TableName From HR.TrainingAttendance TA
Inner Join HR.Training T on TA.TrainingId=T.Id
where T.CompanyId In (Select ID From Common.Company Where Id NOT in (589,590,591,592,593,594)) Union All

select Count(*) As RecordCount,'HR.TrainingAttendee' As TableName From HR.TrainingAttendee TA
Inner Join HR.Training T on TA.TrainingId=T.Id
where T.CompanyId In (Select ID From Common.Company Where Id NOT in (589,590,591,592,593,594)) Union All

select Count(*) As RecordCount,'HR.TrainingSchedule' As TableName From HR.TrainingSchedule TS
Inner Join HR.Training T On TS.TrainingId=T.Id
where T.CompanyId In (Select ID From Common.Company Where Id NOT in (589,590,591,592,593,594)) Union All

select Count(*) As RecordCount,'HR.WorkProfile' As TableName From HR.WorkProfile
where CompanyId In (Select ID From Common.Company Where Id NOT in (589,590,591,592,593,594)) Union All

select Count(*) As RecordCount,'HR.WorkProfileDetails' As TableName From HR.WorkProfileDetails WPD
Inner Join HR.WorkProfile WP on WPD.MasterId=WP.Id
where WP.CompanyId In (Select ID From Common.Company Where Id NOT in (589,590,591,592,593,594)) Union All

--//Tax

Select Count(*) As RecordCount,'Tax.SectionA' As TableName From Tax.SectionA 
Where CompanyId In (Select ID From Common.Company Where Id NOT in (589,590,591,592,593,594)) Union All

Select Count(*) As RecordCount,'Tax.TaxCompany' As TableName From Tax.TaxCompany 
Where CompanyId In (Select ID From Common.Company Where Id NOT in (589,590,591,592,593,594)) Union All

Select Count(*) As RecordCount,'Tax.MonthlyForeignExchange' As TableName From Tax.MonthlyForeignExchange 
Where CompanyId In (Select ID From Common.Company Where Id NOT in (589,590,591,592,593,594)) Union All

Select Count(*) As RecordCount,'Tax.TaxRolePermission' As TableName From Tax.TaxRolePermission 
Where CompanyId In (Select ID From Common.Company Where Id NOT in (589,590,591,592,593,594)) Union All

Select Count(*) As RecordCount,'Tax.TaxRole' As TableName From Tax.TaxRole 
Where CompanyId In (Select ID From Common.Company Where Id NOT in (589,590,591,592,593,594)) Union All

Select Count(*) As RecordCount,'Tax.TaxPermission' As TableName From Tax.TaxPermission 
Where CompanyId In (Select ID From Common.Company Where Id NOT in (589,590,591,592,593,594)) Union All

Select Count(*) As RecordCount,'Tax.TaxMenuMaster' As TableName From Tax.TaxMenuMaster 
Where CompanyId In (Select ID From Common.Company Where Id NOT in (589,590,591,592,593,594)) Union All

Select Count(*) As RecordCount,'Tax.TaxMenu' As TableName From Tax.TaxMenu 
Where CompanyId In (Select ID From Common.Company Where Id NOT in (589,590,591,592,593,594)) Union All

Select Count(*) As RecordCount,'Tax.CapitalAllowance' As TableName From Tax.CapitalAllowance 
Where CompanyId In (Select ID From Common.Company Where Id NOT in (589,590,591,592,593,594)) Union All

Select Count(*) As RecordCount,'Tax.TaxCompanyMenuMaster' As TableName From Tax.TaxCompanyMenuMaster 
Where CompanyId In (Select ID From Common.Company Where Id NOT in (589,590,591,592,593,594)) Union All

Select Count(*) As RecordCount,'Tax.Classification' As TableName From Tax.Classification 
Where CompanyId In (Select ID From Common.Company Where Id NOT in (589,590,591,592,593,594)) Union All

Select Count(*) As RecordCount,'Tax.AccountAnnotation' As TableName From Tax.AccountAnnotation 
Where CompanyId In (Select ID From Common.Company Where Id NOT in (589,590,591,592,593,594)) Union All

Select Count(*) As RecordCount,'Tax.PlanningMateriality' As TableName From Tax.PlanningMateriality 
Where CompanyId In (Select ID From Common.Company Where Id NOT in (589,590,591,592,593,594)) Union All

Select Count(*) As RecordCount,'Tax.GeneralLedgerImport' As TableName From Tax.GeneralLedgerImport 
Where CompanyId In (Select ID From Common.Company Where Id NOT in (589,590,591,592,593,594)) Union All

Select Count(*) As RecordCount,'Tax.Section14QSetUp' As TableName From Tax.Section14QSetUp 
Where CompanyId In (Select ID From Common.Company Where Id NOT in (589,590,591,592,593,594)) Union All

Select Count(*) As RecordCount,'Tax.Nature' As TableName From Tax.Nature 
Where CompanyId In (Select ID From Common.Company Where Id NOT in (589,590,591,592,593,594)) Union All

Select Count(*) As RecordCount,'Tax.EngagementVisitedHistory' As TableName From Tax.EngagementVisitedHistory 
Where CompanyId In (Select ID From Common.Company Where Id NOT in (589,590,591,592,593,594)) Union All

Select Count(*) As RecordCount,'Tax.EngagementTypeMenuMapping' As TableName From Tax.EngagementTypeMenuMapping 
Where CompanyId In (Select ID From Common.Company Where Id NOT in (589,590,591,592,593,594)) Union All

Select Count(*) As RecordCount,'Tax.MedicalExpenses' As TableName From Tax.MedicalExpenses
 Where CompanyId In (Select ID From Common.Company Where Id NOT in (589,590,591,592,593,594)) Union All

Select Count(*) As RecordCount,'Tax.IPCMultipliers' As TableName From Tax.IPCMultipliers 
Where CompanyId In (Select ID From Common.Company Where Id NOT in (589,590,591,592,593,594)) Union All

Select Count(*) As RecordCount,'Tax.Donation' As TableName From Tax.Donation 
Where CompanyId In (Select ID From Common.Company Where Id NOT in (589,590,591,592,593,594)) Union All

Select Count(*) As RecordCount,'Tax.WPSetup' As TableName From Tax.WPSetup 
Where CompanyId In (Select ID From Common.Company Where Id NOT in (589,590,591,592,593,594)) Union All

Select Count(*) As RecordCount,'Tax.FormMaster' As TableName From Tax.FormMaster 
Where CompanyId In (Select ID From Common.Company Where Id NOT in (589,590,591,592,593,594)) Union All

Select Count(*) As RecordCount,'Tax.AccountPolicy' As TableName From Tax.AccountPolicy 
Where CompanyId In (Select ID From Common.Company Where Id NOT in (589,590,591,592,593,594)) Union All

Select Count(*) As RecordCount,'Tax.TemplateVariable' As TableName From Tax.TemplateVariable 
Where CompanyId In (Select ID From Common.Company Where Id NOT in (589,590,591,592,593,594)) Union All

Select Count(*) As RecordCount,'Tax.TickMarkSetup' As TableName From Tax.TickMarkSetup 
Where CompanyId In (Select ID From Common.Company Where Id NOT in (589,590,591,592,593,594)) Union All

Select Count(*) As RecordCount,'Tax.Template' As TableName From Tax.Template 
Where CompanyId In (Select ID From Common.Company Where Id NOT in (589,590,591,592,593,594)) Union All

Select Count(*) As RecordCount,'Tax.PlanningMaterialitySetup' As TableName From Tax.PlanningMaterialitySetup 
Where CompanyId In (Select ID From Common.Company Where Id NOT in (589,590,591,592,593,594)) Union All

Select Count(*) As RecordCount,'Tax.Exemption' As TableName From Tax.Exemption 
Where CompanyId In (Select ID From Common.Company Where Id NOT in (589,590,591,592,593,594)) Union All

Select Count(*) As RecordCount,'Tax.PlanningAndCompletionSetUp' As TableName From Tax.PlanningAndCompletionSetUp 
Where CompanyId In (Select ID From Common.Company Where Id NOT in (589,590,591,592,593,594)) Union All

Select Count(*) As RecordCount,'Tax.Rebates' As TableName From Tax.Rebates 
Where CompanyId In (Select ID From Common.Company Where Id NOT in (589,590,591,592,593,594)) Union All


Select Count(*) As RecordCount,'Tax.AccountPolicyDetail' As TableName From Tax.AccountPolicyDetail As APD
Inner Join Tax.AccountPolicy As AP On AP.Id=APD.MasterId
Where AP.CompanyId In (Select ID From Common.Company Where Id NOT in (589,590,591,592,593,594)) Union All

Select Count(*) As RecordCount,'Tax.Adjustment' As TableName From Tax.Adjustment As AD 
Inner Join Tax.TaxCompanyEngagement As TCE On TCE.Id=AD.EngagementID
Inner Join Tax.TaxCompany As TC On TC.Id=TCE.TaxCompanyId
Where TC.CompanyId In (Select ID From Common.Company Where Id NOT in (589,590,591,592,593,594)) Union All

Select Count(*) As RecordCount,'Tax.AdjustmentComment' As TableName From Tax.AdjustmentComment As AC
Inner Join Tax.Adjustment As TA On TA.ID=AC.AdjustmentID
Inner Join Tax.TaxCompanyEngagement As TCE On TCE.Id=TA.EngagementID
Inner Join Tax.TaxCompany As TC On TC.Id=TCE.TaxCompanyId
Where TC.CompanyId In (Select ID From Common.Company Where Id NOT in (589,590,591,592,593,594)) Union All

Select Count(*) As RecordCount,'Tax.AdjustmentDOCRepository' As TableName From Tax.AdjustmentDOCRepository As ADR
Inner Join Tax.TaxCompanyEngagement As TCE On TCE.Id=ADR.EngagementID
Inner Join Tax.TaxCompany As TC On TC.Id=TCE.TaxCompanyId
Where TC.CompanyId In (Select ID From Common.Company Where Id NOT in (589,590,591,592,593,594)) Union All

Select Count(*) As RecordCount,'Tax.AdjustmentFileAttachment' As TableName From Tax.AdjustmentFileAttachment As AFA
Inner Join Tax.Adjustment As TA On TA.ID=AFA.AdjustmentID
Inner Join Tax.TaxCompanyEngagement As TCE On TCE.Id=TA.EngagementID
Inner Join Tax.TaxCompany As TC On TC.Id=TCE.TaxCompanyId
Where TC.CompanyId In (Select ID From Common.Company Where Id NOT in (589,590,591,592,593,594)) Union All

Select Count(*) As RecordCount,'Tax.AdjustmentStatusHistory' As TableName From Tax.AdjustmentStatusHistory As ASH
Inner Join Tax.Adjustment As TA On TA.ID=ASH.AdjustmentID
Inner Join Tax.TaxCompanyEngagement As TCE On TCE.Id=TA.EngagementID
Inner Join Tax.TaxCompany As TC On TC.Id=TCE.TaxCompanyId
Where TC.CompanyId In (Select ID From Common.Company Where Id NOT in (589,590,591,592,593,594)) Union All

Select Count(*) As RecordCount,'Tax.CarryForward' As TableName From Tax.CarryForward As CF
Inner Join Tax.TaxCompanyEngagement As TCE On TCE.Id=CF.EngagementID
Inner Join Tax.TaxCompany As TC On TC.Id=TCE.TaxCompanyId
Where TC.CompanyId In (Select ID From Common.Company Where Id NOT in (589,590,591,592,593,594)) Union All

Select Count(*) As RecordCount,'Tax.CarryForwardDetail' As TableName From Tax.CarryForwardDetail As CFD
Inner Join Tax.CarryForward As CF On CF.Id=CFD.CarryForwardId
Inner Join Tax.TaxCompanyEngagement As TCE On TCE.Id=CF.EngagementID
Inner Join Tax.TaxCompany As TC On TC.Id=TCE.TaxCompanyId
Where TC.CompanyId In (Select ID From Common.Company Where Id NOT in (589,590,591,592,593,594)) Union All

Select Count(*) As RecordCount,'Tax.CategoryDetails' As TableName From Tax.CategoryDetails As CD
Inner Join Tax.ClassificationCategories As CC On CC.Id=CD.ClassificationCategoryId
Inner Join Tax.Classification As C On C.Id=CC.ClassificationId
Where C.CompanyId In (Select ID From Common.Company Where Id NOT in (589,590,591,592,593,594)) Union All

Select Count(*) As RecordCount,'Tax.ClassificationCategories' As TableName From Tax.ClassificationCategories As CC
Inner Join Tax.Classification As C On C.Id=CC.ClassificationId
Where C.CompanyId In (Select ID From Common.Company Where Id NOT in (589,590,591,592,593,594)) Union All

Select Count(*) As RecordCount,'Tax.ClientAndEngagementIndependenceConfirmation' As TableName From Tax.ClientAndEngagementIndependenceConfirmation As CAEIC
Inner Join Tax.TaxCompanyEngagement As TCE On TCE.Id=CAEIC.EngagementID
Inner Join Tax.TaxCompany As TC On TC.Id=TCE.TaxCompanyId
Where TC.CompanyId In (Select ID From Common.Company Where Id NOT in (589,590,591,592,593,594)) Union All


Select Count(*) As RecordCount,'Tax.CommentReplyTable' As TableName From Tax.CommentReplyTable As CRT
Inner Join Common.Comment As C On C.Id=CRT.CommentID

Union All

Select Count(*) As RecordCount,'Tax.CommentTable' As TableName From Tax.CommentTable As CT
Inner Join Tax.AdjustmentComment As AC On AC.ID=CT.AdjustmentComment_ID
Inner Join Tax.Adjustment As TA On TA.ID=AC.AdjustmentID
Inner Join Tax.TaxCompanyEngagement As TCE On TCE.Id=TA.EngagementID
Inner Join Tax.TaxCompany As TC On TC.Id=TCE.TaxCompanyId
Where TC.CompanyId In (Select ID From Common.Company Where Id NOT in (589,590,591,592,593,594)) Union All

Select Count(*) As RecordCount,'Tax.DirectorRemuneration' As TableName From Tax.DirectorRemuneration As DR 
Inner Join Tax.TaxCompanyEngagement As TCE On TCE.Id=DR.EngagementID
Inner Join Tax.TaxCompany As TC On TC.Id=TCE.TaxCompanyId
Where TC.CompanyId In (Select ID From Common.Company Where Id NOT in (589,590,591,592,593,594)) Union All

Select Count(*) As RecordCount,'Tax.DirectorRemunerationDetails' As TableName From Tax.DirectorRemunerationDetails As DRD
Inner Join Tax.DirectorRemuneration As DR On DR.Id=DRD.DirectorRemunerationId
Inner Join Tax.TaxCompanyEngagement As TCE On TCE.Id=DR.EngagementID
Inner Join Tax.TaxCompany As TC On TC.Id=TCE.TaxCompanyId
Where TC.CompanyId In (Select ID From Common.Company Where Id NOT in (589,590,591,592,593,594)) Union All

Select Count(*) As RecordCount,'Tax.Disposal' As TableName From Tax.Disposal As D
Inner Join Tax.SectionA As SA On SA.Id=D.SectionAId
Inner Join Tax.TaxCompany As TC On TC.Id=SA.TaxCompanyId
Where TC.CompanyId In (Select ID From Common.Company Where Id NOT in (589,590,591,592,593,594)) Union All

Select Count(*) As RecordCount,'Tax.DonationReference' As TableName From Tax.DonationReference As DR
Inner Join Tax.TaxCompanyEngagement As TCE On TCE.Id=DR.EngagementID
Inner Join Tax.TaxCompany As TC On TC.Id=TCE.TaxCompanyId
Where TC.CompanyId In (Select ID From Common.Company Where Id NOT in (589,590,591,592,593,594)) Union All

Select Count(*) As RecordCount,'Tax.ExemptionDetails' As TableName From Tax.ExemptionDetails As ED
Inner Join Tax.Exemption As E On E.Id=ED.ExemptionId
Where E.CompanyId In (Select ID From Common.Company Where Id NOT in (589,590,591,592,593,594)) Union All

Select Count(*) As RecordCount,'Tax.FEAnalysis' As TableName From Tax.FEAnalysis As FA
Inner Join Tax.ForeignExchange As FE On FE.ID=FA.ForeignExchangeID
Inner Join Tax.TaxCompanyEngagement As TCE On TCE.Id=FE.EngagementID
Inner Join Tax.TaxCompany As TC On TC.Id=TCE.TaxCompanyId
Where TC.CompanyId In (Select ID From Common.Company Where Id NOT in (589,590,591,592,593,594)) Union All

Select Count(*) As RecordCount,'Tax.FEAnalysisComment' As TableName From Tax.FEAnalysisComment As FEC
Inner Join Tax.FEAnalysis As FEA On FEA.ID=FEC.FEAnalysisID
Inner Join Tax.ForeignExchange As FE On FE.ID=FEA.ForeignExchangeID
Inner Join Tax.TaxCompanyEngagement As TCE On TCE.Id=FE.EngagementID
Inner Join Tax.TaxCompany As TC On TC.Id=TCE.TaxCompanyId
Where TC.CompanyId In (Select ID From Common.Company Where Id NOT in (589,590,591,592,593,594)) Union All

Select Count(*) As RecordCount,'Tax.FEAnalysisCommentReply' As TableName From Tax.FEAnalysisCommentReply As FECR
Inner Join Tax.FEAnalysisComment As FEC On FEC.ID=FECR.FECommentID
Inner Join Tax.FEAnalysis As FEA On FEA.ID=FEC.FEAnalysisID
Inner Join Tax.ForeignExchange As FE On FE.ID=FEA.ForeignExchangeID
Inner Join Tax.TaxCompanyEngagement As TCE On TCE.Id=FE.EngagementID
Inner Join Tax.TaxCompany As TC On TC.Id=TCE.TaxCompanyId
Where TC.CompanyId In (Select ID From Common.Company Where Id NOT in (589,590,591,592,593,594)) Union All

Select Count(*) As RecordCount,'Tax.FEAnalysisCountryCurrency' As TableName From Tax.FEAnalysisCountryCurrency As FECC
Inner Join Tax.FEAnalysis As FEA On FEA.ID=FECC.FEAnalysisID
Inner Join Tax.ForeignExchange As FE On FE.ID=FEA.ForeignExchangeID
Inner Join Tax.TaxCompanyEngagement As TCE On TCE.Id=FE.EngagementID
Inner Join Tax.TaxCompany As TC On TC.Id=TCE.TaxCompanyId
Where TC.CompanyId In (Select ID From Common.Company Where Id NOT in (589,590,591,592,593,594)) Union All

Select Count(*) As RecordCount,'Tax.FEAnalysisCurrencyDetails' As TableName From Tax.FEAnalysisCurrencyDetails As FECD
Inner Join Tax.FEAnalysisCountryCurrency As FECC On FECC.ID=FECD.CuntryCurrencyID
Inner Join Tax.FEAnalysis As FEA On FEA.ID=FECC.FEAnalysisID
Inner Join Tax.ForeignExchange As FE On FE.ID=FEA.ForeignExchangeID
Inner Join Tax.TaxCompanyEngagement As TCE On TCE.Id=FE.EngagementID
Inner Join Tax.TaxCompany As TC On TC.Id=TCE.TaxCompanyId
Where TC.CompanyId In (Select ID From Common.Company Where Id NOT in (589,590,591,592,593,594)) Union All

Select Count(*) As RecordCount,'Tax.FEAnalysisLegend' As TableName From Tax.FEAnalysisLegend As FEAL
Inner Join Tax.FEAnalysis As FEA On FEA.ID=FEAL.FEAnalysisID
Inner Join Tax.ForeignExchange As FE On FE.ID=FEA.ForeignExchangeID
Inner Join Tax.TaxCompanyEngagement As TCE On TCE.Id=FE.EngagementID
Inner Join Tax.TaxCompany As TC On TC.Id=TCE.TaxCompanyId
Where TC.CompanyId In (Select ID From Common.Company Where Id NOT in (589,590,591,592,593,594)) Union All

Select Count(*) As RecordCount,'Tax.FEAnalysisNote' As TableName From Tax.FEAnalysisNote As FEAN
Inner Join Tax.FEAnalysis As FEA On FEA.ID=FEAN.FEAnalysisID
Inner Join Tax.ForeignExchange As FE On FE.ID=FEA.ForeignExchangeID
Inner Join Tax.TaxCompanyEngagement As TCE On TCE.Id=FE.EngagementID
Inner Join Tax.TaxCompany As TC On TC.Id=TCE.TaxCompanyId
Where TC.CompanyId In (Select ID From Common.Company Where Id NOT in (589,590,591,592,593,594)) Union All

Select Count(*) As RecordCount,'Tax.ForeignCurrencyAnalysis' As TableName From Tax.ForeignCurrencyAnalysis As FCA
Inner Join Tax.ForeignExchange As FE On FE.ID=FCA.ForeignExchangeID
Inner Join Tax.TaxCompanyEngagement As TCE On TCE.Id=FE.EngagementID
Inner Join Tax.TaxCompany As TC On TC.Id=TCE.TaxCompanyId
Where TC.CompanyId In (Select ID From Common.Company Where Id NOT in (589,590,591,592,593,594)) Union All

Select Count(*) As RecordCount,'Tax.ForeignCurrencyAnalysisFactors' As TableName From Tax.ForeignCurrencyAnalysisFactors As FCAF
Inner Join Tax.ForeignCurrencyAnalysis As FCA On FCA.Id=FCAF.FCAnalysisID
Inner Join Tax.ForeignExchange As FE On FE.ID=FCA.ForeignExchangeID
Inner Join Tax.TaxCompanyEngagement As TCE On TCE.Id=FE.EngagementID
Inner Join Tax.TaxCompany As TC On TC.Id=TCE.TaxCompanyId
Where TC.CompanyId In (Select ID From Common.Company Where Id NOT in (589,590,591,592,593,594)) Union All

Select Count(*) As RecordCount,'Tax.ForeignExchange' As TableName From Tax.ForeignExchange As FE
Inner Join Tax.TaxCompanyEngagement As TCE On TCE.Id=FE.EngagementID
Inner Join Tax.TaxCompany As TC On TC.Id=TCE.TaxCompanyId
Where TC.CompanyId In (Select ID From Common.Company Where Id NOT in (589,590,591,592,593,594)) Union All

Select Count(*) As RecordCount,'Tax.FormDetail' As TableName From Tax.FormDetail As FD
Inner Join Tax.FormMaster As FM On FM.Id=FD.FormMasterId
Where FM.CompanyId In (Select ID From Common.Company Where Id NOT in (589,590,591,592,593,594)) Union All

Select Count(*) As RecordCount,'Tax.FurtherDeduction' As TableName From Tax.FurtherDeduction As FD
Inner Join Tax.TaxCompanyEngagement As TCE On TCE.Id=FD.EngagementID
Inner Join Tax.TaxCompany As TC On TC.Id=TCE.TaxCompanyId
Where TC.CompanyId In (Select ID From Common.Company Where Id NOT in (589,590,591,592,593,594)) Union All

Select Count(*) As RecordCount,'Tax.FurtherDeductionDetail' As TableName From Tax.FurtherDeductionDetail As FDD
Inner Join Tax.FurtherDeduction As FD On FD.Id=FDD.FurtherDeductionId
Inner Join Tax.TaxCompanyEngagement As TCE On TCE.Id=FD.EngagementID
Inner Join Tax.TaxCompany As TC On TC.Id=TCE.TaxCompanyId
Where TC.CompanyId In (Select ID From Common.Company Where Id NOT in (589,590,591,592,593,594)) Union All

Select Count(*) As RecordCount,'Tax.GeneralLedgerDetail' As TableName From Tax.GeneralLedgerDetail As GLD
Inner Join Tax.GeneralLedgerImport As GLI On GLI.Id=GLD.GeneralLedgerId
Inner Join Tax.TaxCompanyEngagement As TCE On TCE.Id=GLI.EngagementID
Inner Join Tax.TaxCompany As TC On TC.Id=TCE.TaxCompanyId
Where TC.CompanyId In (Select ID From Common.Company Where Id NOT in (589,590,591,592,593,594)) Union All

Select Count(*) As RecordCount,'Tax.GeneralLedgerFileDetails' As TableName From Tax.GeneralLedgerFileDetails As GLFD
Inner Join Tax.TaxCompanyEngagement As TCE On TCE.Id=GLFD.EngagementId
Inner Join Tax.TaxCompany As TC On TC.Id=TCE.TaxCompanyId
Where TC.CompanyId In (Select ID From Common.Company Where Id NOT in (589,590,591,592,593,594)) Union All

Select Count(*) As RecordCount,'Tax.InterestExpenses' As TableName From Tax.InterestExpenses As IE
Inner Join Tax.InterestRestriction As IR On IR.ID=IE.InterestRestrictionId
Inner Join Tax.TaxCompanyEngagement As TCE On TCE.Id=IR.EngagementId
Inner Join Tax.TaxCompany As TC On TC.Id=TCE.TaxCompanyId
Where TC.CompanyId In (Select ID From Common.Company Where Id NOT in (589,590,591,592,593,594)) Union All

Select Count(*) As RecordCount,'Tax.InterestRestriction' As TableName From Tax.InterestRestriction As IR
Inner Join Tax.TaxCompanyEngagement As TCE On TCE.Id=IR.EngagementId
Inner Join Tax.TaxCompany As TC On TC.Id=TCE.TaxCompanyId
Where TC.CompanyId In (Select ID From Common.Company Where Id NOT in (589,590,591,592,593,594)) Union All

Select Count(*) As RecordCount,'Tax.InvestmentSchedule' As TableName From Tax.InvestmentSchedule As ISTS
Inner Join Tax.InterestRestriction As IR On IR.ID=ISTS.InterestRestrictionId
Inner Join Tax.TaxCompanyEngagement As TCE On TCE.Id=IR.EngagementId
Inner Join Tax.TaxCompany As TC On TC.Id=TCE.TaxCompanyId
Where TC.CompanyId In (Select ID From Common.Company Where Id NOT in (589,590,591,592,593,594)) Union All

Select Count(*) As RecordCount,'Tax.MedicalExpenseDetails' As TableName From Tax.MedicalExpenseDetails As MED
Inner Join Tax.MedicalExpenses As ME On ME.Id=MED.MedicalExpensesId
Inner Join Tax.TaxCompanyEngagement As TCE On TCE.Id=ME.EngagementId
Inner Join Tax.TaxCompany As TC On TC.Id=TCE.TaxCompanyId
Where TC.CompanyId In (Select ID From Common.Company Where Id NOT in (589,590,591,592,593,594)) Union All

Select Count(*) As RecordCount,'Tax.NonTradeIncome' As TableName From Tax.NonTradeIncome As NTI 
Inner Join Tax.TaxCompanyEngagement As TCE On TCE.Id=NTI.EngagementId
Inner Join Tax.TaxCompany As TC On TC.Id=TCE.TaxCompanyId
Where TC.CompanyId In (Select ID From Common.Company Where Id NOT in (589,590,591,592,593,594)) Union All

Select Count(*) As RecordCount,'Tax.NonTradeIncomeDetail' As TableName From Tax.NonTradeIncomeDetail As NTID
Inner Join Tax.Nature As N On N.Id=NTID.NatureId
Where N.CompanyId In (Select ID From Common.Company Where Id NOT in (589,590,591,592,593,594)) Union All

Select Count(*) As RecordCount,'Tax.Note' As TableName From Tax.Note As N
Inner Join Tax.TaxCompanyEngagement As TCE On TCE.Id=N.EngagementId
Inner Join Tax.TaxCompany As TC On TC.Id=TCE.TaxCompanyId
Where TC.CompanyId In (Select ID From Common.Company Where Id NOT in (589,590,591,592,593,594)) Union All

Select Count(*) As RecordCount,'Tax.NoteAdjustment' As TableName From Tax.NoteAdjustment As NA 
Inner Join Tax.Adjustment As A On A.ID=NA.AdjustmentId
Inner Join Tax.TaxCompanyEngagement As TCE On TCE.Id=A.EngagementID
Inner Join Tax.TaxCompany As TC On TC.Id=TCE.TaxCompanyId
Where TC.CompanyId In (Select ID From Common.Company Where Id NOT in (589,590,591,592,593,594)) Union All

Select Count(*) As RecordCount,'Tax.NoteAttachment' As TableName From Tax.NoteAttachment As NA
Inner Join Tax.Note As N On N.Id=NA.NoteId
Inner Join Tax.TaxCompanyEngagement As TCE On TCE.Id=N.EngagementId
Inner Join Tax.TaxCompany As TC On TC.Id=TCE.TaxCompanyId
Where TC.CompanyId In (Select ID From Common.Company Where Id NOT in (589,590,591,592,593,594)) Union All

Select Count(*) As RecordCount,'Tax.PAndCSectionQuestions' As TableName From Tax.PAndCSectionQuestions As PSQ
Inner Join Tax.PAndCSections As PS On PS.Id=PSQ.PAndCSectionId
Inner Join Tax.PlanningAndCompletionSetUp As PCS On PCS.Id=PS.PlanningAndCompletionSetUpId
Where PCS.CompanyId In (Select ID From Common.Company Where Id NOT in (589,590,591,592,593,594)) Union All

Select Count(*) As RecordCount,'Tax.PAndCSections' As TableName From Tax.PAndCSections As PS 
Inner Join Tax.PlanningAndCompletionSetUp As PCS On PCS.Id=PS.PlanningAndCompletionSetUpId
Where PCS.CompanyId In (Select ID From Common.Company Where Id NOT in (589,590,591,592,593,594)) Union All

Select Count(*) As RecordCount,'Tax.PIC' As TableName From Tax.PIC As P
Inner Join Tax.TaxCompanyEngagement As TCE On TCE.Id=P.EngagementId
Inner Join Tax.TaxCompany As TC On TC.Id=TCE.TaxCompanyId
Where TC.CompanyId In (Select ID From Common.Company Where Id NOT in (589,590,591,592,593,594)) Union All


Select Count(*) As RecordCount,'Tax.PlanningMaterialityClassification' As TableName From Tax.PlanningMaterialityClassification As PMC
Inner Join Tax.PlanningMaterialitySetupDetail As PMSD On PMSD.Id=PMC.PlanningMaterialitySetupDetailId
Inner Join Tax.PlanningMaterialitySetup As PMS On PMS.Id=PMSD.PlanningMaterialitySetupId
Where PMS.CompanyId In (Select ID From Common.Company Where Id NOT in (589,590,591,592,593,594)) Union All
 
Select Count(*) As RecordCount,'Tax.PlanningMaterialityDetail' As TableName From Tax.PlanningMaterialityDetail As PMD
Inner Join Tax.PlanningMateriality As PM On PM.Id=PMD.PlanningMeterialityId
Where PM.CompanyId In (Select ID From Common.Company Where Id NOT in (589,590,591,592,593,594)) Union All

Select Count(*) As RecordCount,'Tax.PlanningMaterialityDetailClassification' As TableName From Tax.PlanningMaterialityDetailClassification As PMDC
Inner Join Tax.TaxCompanyEngagement As TCE On TCE.Id=PMDC.TaxCompanyEngagementId
Inner Join Tax.TaxCompany As TC On TC.Id=TCE.TaxCompanyId
Where TC.CompanyId In (Select ID From Common.Company Where Id NOT in (589,590,591,592,593,594)) Union All

Select Count(*) As RecordCount,'Tax.PlanningMaterialitySetupDetail' As TableName From Tax.PlanningMaterialitySetupDetail As PMSD 
Inner Join Tax.PlanningMaterialitySetup As PMS On PMS.Id=PMSD.PlanningMaterialitySetupId
Where PMS.CompanyId In (Select ID From Common.Company Where Id NOT in (589,590,591,592,593,594)) Union All

Select Count(*) As RecordCount,'Tax.ProfitAndLossAuditTrail' As TableName From Tax.ProfitAndLossAuditTrail As PLA
Inner Join Tax.TaxCompanyEngagement As TCE On TCE.Id=PLA.EngagementID
Inner Join Tax.TaxCompany As TC On TC.Id=TCE.TaxCompanyId
Where TC.CompanyId In (Select ID From Common.Company Where Id NOT in (589,590,591,592,593,594)) Union All

Select Count(*) As RecordCount,'Tax.ProfitAndLossFileDetails' As TableName From Tax.ProfitAndLossFileDetails As PLD
Inner Join Tax.TaxCompanyEngagement As TCE On TCE.Id=PLD.EngagementID
Inner Join Tax.TaxCompany As TC On TC.Id=TCE.TaxCompanyId
Where TC.CompanyId In (Select ID From Common.Company Where Id NOT in (589,590,591,592,593,594)) Union All

Select Count(*) As RecordCount,'Tax.ProfitAndLossImport' As TableName From Tax.ProfitAndLossImport As PLI
Inner Join Tax.TaxCompanyEngagement As TCE On TCE.Id=PLI.EngagementID
Inner Join Tax.TaxCompany As TC On TC.Id=TCE.TaxCompanyId
Where TC.CompanyId In (Select ID From Common.Company Where Id NOT in (589,590,591,592,593,594)) Union All

--Select Count(*) As RecordCount As TableName From Tax.ProfitAndLossImportPreferences As PLIP

Select Count(*) As RecordCount,'Tax.ProfitAndLossTickmark' As TableName From Tax.ProfitAndLossTickmark As PLT
Inner Join Tax.TaxCompanyEngagement As TCE On TCE.Id=PLT.EngagementID
Inner Join Tax.TaxCompany As TC On TC.Id=TCE.TaxCompanyId
Where TC.CompanyId In (Select ID From Common.Company Where Id NOT in (589,590,591,592,593,594)) Union All

Select Count(*) As RecordCount,'Tax.RentalIncome' As TableName From Tax.RentalIncome As RI 
Inner Join Tax.TaxCompanyEngagement As TCE On TCE.Id=RI.EngagementID
Inner Join Tax.TaxCompany As TC On TC.Id=TCE.TaxCompanyId
Where TC.CompanyId In (Select ID From Common.Company Where Id NOT in (589,590,591,592,593,594)) Union All

Select Count(*) As RecordCount,'Tax.RentalIncomeDetail' As TableName From Tax.RentalIncomeDetail As RID
Inner Join Tax.ProfitAndLossImport As PLI On PLI.Id=RID.ProfitAndLossImportId
Inner Join Tax.TaxCompanyEngagement As TCE On TCE.Id=PLI.EngagementID
Inner Join Tax.TaxCompany As TC On TC.Id=TCE.TaxCompanyId
Where TC.CompanyId In (Select ID From Common.Company Where Id NOT in (589,590,591,592,593,594)) Union All

--Select Count(*) As RecordCount As TableName From Tax.RollForward As RF

Select Count(*) As RecordCount,'Tax.Schedule' As TableName From Tax.Schedule As S
Inner Join Tax.TaxCompanyEngagement As TCE On TCE.Id=S.EngagementID
Inner Join Tax.TaxCompany As TC On TC.Id=TCE.TaxCompanyId
Where TC.CompanyId In (Select ID From Common.Company Where Id NOT in (589,590,591,592,593,594)) Union All

Select Count(*) As RecordCount,'Tax.ScheduleAttachment' As TableName From Tax.ScheduleAttachment As SA
Inner join Tax.Schedule As S On S.Id=SA.ScheduleId
Inner Join Tax.TaxCompanyEngagement As TCE On TCE.Id=S.EngagementID
Inner Join Tax.TaxCompany As TC On TC.Id=TCE.TaxCompanyId
Where TC.CompanyId In (Select ID From Common.Company Where Id NOT in (589,590,591,592,593,594)) Union All

Select Count(*) As RecordCount,'Tax.Section14Q' As TableName From Tax.Section14Q As S
Inner Join Tax.TaxCompanyEngagement As TCE On TCE.Id=S.EngagementID
Inner Join Tax.TaxCompany As TC On TC.Id=TCE.TaxCompanyId
Where TC.CompanyId In (Select ID From Common.Company Where Id NOT in (589,590,591,592,593,594)) Union All

Select Count(*) As RecordCount,'Tax.Section14QAdditions' As TableName From Tax.Section14QAdditions As SA 
Inner Join Tax.Section14Q As S On S.Id=SA.Section14QId
Inner Join Tax.TaxCompanyEngagement As TCE On TCE.Id=S.EngagementID
Inner Join Tax.TaxCompany As TC On TC.Id=TCE.TaxCompanyId
Where TC.CompanyId In (Select ID From Common.Company Where Id NOT in (589,590,591,592,593,594)) Union All

Select Count(*) As RecordCount,'Tax.Section14QDetails' As TableName From Tax.Section14QDetails As SD
Inner Join Tax.Section14Q As S On S.Id=SD.Section14QId
Inner Join Tax.TaxCompanyEngagement As TCE On TCE.Id=S.EngagementID
Inner Join Tax.TaxCompany As TC On TC.Id=TCE.TaxCompanyId
Where TC.CompanyId In (Select ID From Common.Company Where Id NOT in (589,590,591,592,593,594)) Union All

Select Count(*) As RecordCount,'Tax.Section14QEligibleExp' As TableName From Tax.Section14QEligibleExp As SE
Inner Join Tax.Section14Q As S On S.Id=SE.Section14QId
Inner Join Tax.TaxCompanyEngagement As TCE On TCE.Id=S.EngagementID
Inner Join Tax.TaxCompany As TC On TC.Id=TCE.TaxCompanyId
Where TC.CompanyId In (Select ID From Common.Company Where Id NOT in (589,590,591,592,593,594)) Union All

Select Count(*) As RecordCount,'Tax.SectionADetail' As TableName From Tax.SectionADetail As SAD
Inner Join Tax.SectionA As SA On SA.id=SAD.SECTIONAId
Inner Join Tax.TaxCompanyEngagement As TCE On TCE.Id=SA.EngagementID
Inner Join Tax.TaxCompany As TC On TC.Id=TCE.TaxCompanyId
Where TC.CompanyId In (Select ID From Common.Company Where Id NOT in (589,590,591,592,593,594)) Union All

Select Count(*) As RecordCount,'Tax.SectionB' As TableName From Tax.SectionB As SB
Inner Join Tax.SectionA As SA On SA.id=SB.SECTIONAId
Inner Join Tax.TaxCompanyEngagement As TCE On TCE.Id=SA.EngagementID
Inner Join Tax.TaxCompany As TC On TC.Id=TCE.TaxCompanyId
Where TC.CompanyId In (Select ID From Common.Company Where Id NOT in (589,590,591,592,593,594)) Union All

--Select Count(*) As RecordCount As TableName From Tax.SeriLog As SL

Select Count(*) As RecordCount,'Tax.Split' As TableName From Tax.Split As S
Inner Join Tax.Note As N On N.Id=S.NoteId
Inner Join Tax.TaxCompanyEngagement As TCE On TCE.Id=N.EngagementId
Inner Join Tax.TaxCompany As TC On TC.Id=TCE.TaxCompanyId
Where TC.CompanyId In (Select ID From Common.Company Where Id NOT in (589,590,591,592,593,594)) Union All

Select Count(*) As RecordCount,'Tax.SplitDetail' As TableName From Tax.SplitDetail As SD
Inner Join Tax.Split As S On S.Id=SD.SplitId
Inner Join Tax.Note As N On N.Id=S.NoteId
Inner Join Tax.TaxCompanyEngagement As TCE On TCE.Id=N.EngagementId
Inner Join Tax.TaxCompany As TC On TC.Id=TCE.TaxCompanyId
Where TC.CompanyId In (Select ID From Common.Company Where Id NOT in (589,590,591,592,593,594)) Union All

Select Count(*) As RecordCount,'Tax.StatementA' As TableName From Tax.StatementA As SA
Inner Join Tax.TaxCompanyEngagement As TCE On TCE.Id=SA.EngagementId
Inner Join Tax.TaxCompany As TC On TC.Id=TCE.TaxCompanyId
Where TC.CompanyId In (Select ID From Common.Company Where Id NOT in (589,590,591,592,593,594)) Union All


--Select Count(*) As RecordCount As TableName From Tax.StatementAPerticular As SAP

Select Count(*) As RecordCount,'Tax.SubCategory' As TableName From Tax.SubCategory As SC
Inner Join Tax.TaxCompanyEngagement As TCE On TCE.Id=SC.EngagementId
Inner Join Tax.TaxCompany As TC On TC.Id=TCE.TaxCompanyId
Where TC.CompanyId In (Select ID From Common.Company Where Id NOT in (589,590,591,592,593,594)) Union All

Select Count(*) As RecordCount,'Tax.TaxAuditTrail' As TableName From Tax.TaxAuditTrail As TAT
Inner Join Tax.TaxCompanyEngagement As TCE On TCE.Id=TAT.EngagementId
Inner Join Tax.TaxCompany As TC On TC.Id=TCE.TaxCompanyId
Where TC.CompanyId In (Select ID From Common.Company Where Id NOT in (589,590,591,592,593,594)) Union All

Select Count(*) As RecordCount,'Tax.TaxCompanyContact' As TableName From Tax.TaxCompanyContact As TCC
Inner Join Tax.TaxCompany As TC On TC.Id=TCC.TaxCompanyId
Where TC.CompanyId In (Select ID From Common.Company Where Id NOT in (589,590,591,592,593,594)) Union All

Select Count(*) As RecordCount,'Tax.TaxCompanyEngagement' As TableName From Tax.TaxCompanyEngagement As TCE
Inner Join Tax.TaxCompany As TC On TC.Id=TCE.TaxCompanyId
Where TC.CompanyId In (Select ID From Common.Company Where Id NOT in (589,590,591,592,593,594)) Union All

Select Count(*) As RecordCount,'Tax.TaxCompanyEngagementDetails' As TableName From Tax.TaxCompanyEngagementDetails As TCED
Inner Join Tax.TaxCompanyEngagement As TCE On TCE.Id=TCED.TaxCompanyEngagementId
Inner Join Tax.TaxCompany As TC On TC.Id=TCE.TaxCompanyId
Where TC.CompanyId In (Select ID From Common.Company Where Id NOT in (589,590,591,592,593,594)) Union All

Select Count(*) As RecordCount,'Tax.TaxMenuPermissions' As TableName From Tax.TaxMenuPermissions As TMP
Inner Join Tax.TaxCompanyMenuMaster As TCM On TCM.Id=TMP.TaxCompanyMenuMasterId
Where TCM.CompanyId In (Select ID From Common.Company Where Id NOT in (589,590,591,592,593,594)) Union All

Select Count(*) As RecordCount,'Tax.TaxTypeTaxMenu' As TableName From Tax.TaxTypeTaxMenu As TTM
Inner Join Tax.TaxMenuMaster As TMM On TMM.Id=TTM.TaxMenuMasterId
Where TMM.CompanyId In (Select ID From Common.Company Where Id NOT in (589,590,591,592,593,594)) Union All

Select Count(*) As RecordCount,'Tax.UserApproval' As TableName From Tax.UserApproval As UA 
Inner Join Tax.TaxCompanyEngagement As TCE On TCE.Id=UA.EngagementId
Inner Join Tax.TaxCompany As TC On TC.Id=TCE.TaxCompanyId
Where TC.CompanyId In (Select ID From Common.Company Where Id NOT in (589,590,591,592,593,594)) Union All

Select Count(*) As RecordCount,'Tax.WPComment' As TableName From Tax.WPComment As WC
Inner Join Tax.WPSetupDetail As WSD On WSD.Id=WC.WPCategoryId
Inner Join Tax.WPSetup As WS On WS.Id=WSD.WPSetupId
Where WS.CompanyId In (Select ID From Common.Company Where Id NOT in (589,590,591,592,593,594)) Union All

Select Count(*) As RecordCount,'Tax.WPCommentReply' As TableName From Tax.WPCommentReply As WCR
Inner Join Tax.WPComment As WC On WC.Id=WCR.WPCommentId
Inner Join Tax.WPSetupDetail As WSD On WSD.Id=WC.WPCategoryId
Inner Join Tax.WPSetup As WS On WS.Id=WSD.WPSetupId
Where WS.CompanyId In (Select ID From Common.Company Where Id NOT in (589,590,591,592,593,594)) Union All

Select Count(*) As RecordCount,'Tax.WPImportFile' As TableName From Tax.WPImportFile As WIF
Inner Join Tax.WPSetupDetail As WSD On WSD.Id=WIF.WPCategoryId
Inner Join Tax.WPSetup As WS On WS.Id=WSD.WPSetupId
Where WS.CompanyId In (Select ID From Common.Company Where Id NOT in (589,590,591,592,593,594)) Union All

Select Count(*) As RecordCount,'Tax.WPSetupDetail' As TableName From Tax.WPSetupDetail As WSD
Inner Join Tax.WPSetup As WS On WS.Id=WSD.WPSetupId
Where WS.CompanyId In (Select ID From Common.Company Where Id NOT in (589,590,591,592,593,594)) Union All

Select Count(*) As RecordCount,'Tax.WPSetupTickmark' As TableName From Tax.WPSetupTickmark As WST
Inner Join Tax.WPSetup As WS On WS.Id=WST.WPSetupId
Where WS.CompanyId In (Select ID From Common.Company Where Id NOT in (589,590,591,592,593,594))

Union All

--//WorkFlow

Select Count(*) As RecordCount,'Workflow.Client' As TableName from WorkFlow.Client
Where CompanyId In (Select ID From Common.Company Where Id NOT in (589,590,591,592,593,594))
Union All

Select Count(*) As RecordCount,'Workflow.Client History' As TableName from WorkFlow.ClientStatusChange 
Where CompanyId In (Select ID From Common.Company Where Id NOT in (589,590,591,592,593,594))
Union All

Select Count(*) As RecordCount,'Workflow.Client Contact' As TableName
from WorkFlow.ClientContact CC
Inner Join Workflow.Client C on C.Id=CC.ClientId
Where CompanyId In (Select ID From Common.Company Where Id NOT in (589,590,591,592,593,594))
Union All

Select  Count(*) As RecordCount,'Workflow.Contact' As TableName from WorkFlow.Contact
Where CompanyId In (Select ID From Common.Company Where Id NOT in (589,590,591,592,593,594))
Union All

Select Count(*) As RecordCount,'Workflow.Incidental Claim' As TableName from WorkFlow.IncidentalClaimItem
Where CompanyId In (Select ID From Common.Company Where Id NOT in (589,590,591,592,593,594))
Union All

Select Count(*) As RecordCount,'Workflow.Incidental' As TableName
from WorkFlow.Incidental INC
Inner Join WorkFlow.IncidentalClaimItem INCI on INCI.Id=INC.ClaimItemId
Where CompanyId In (Select ID From Common.Company Where Id NOT in (589,590,591,592,593,594))
Union All

Select Count(*) As RecordCount,'Workflow.Claim' As TableName from WorkFlow.Claim 
Where CompanyId In (Select ID From Common.Company Where Id NOT in (589,590,591,592,593,594))
Union All

Select Count(*) As RecordCount,'Workflow.Invoice' As TableName from WorkFlow.Invoice
Where CompanyId In (Select ID From Common.Company Where Id NOT in (589,590,591,592,593,594))
Union All

Select Count(*) As RecordCount,'Workflow.Invoice Designation' As TableName
from WorkFlow.InvoiceDesignation InvD
Inner Join WorkFlow.Invoice I on I.Id=InvD.InvoiceId
Where CompanyId In (Select ID From Common.Company Where Id NOT in (589,590,591,592,593,594))
Union All

Select Count(*) As RecordCount,'Workflow.Invoice State' As TableName
from WorkFlow.InvoiceState as InvS
Inner Join WorkFlow.Invoice I on I.Id=InvS.InvoiceId
Where CompanyId In (Select ID From Common.Company Where Id NOT in (589,590,591,592,593,594))
Union All

Select Count(*) As RecordCount,'Workflow.Schedule' As TableName from WorkFlow.Schedule 
Where CompanyId In (Select ID From Common.Company Where Id NOT in (589,590,591,592,593,594))
Union All

Select Count(*) As RecordCount,'Workflow.Schedule Detail' As TableName
from WorkFlow.ScheduleDetail SCD
Inner Join WorkFlow.Schedule S on S.Id=SCD.MasterId
Where CompanyId In (Select ID From Common.Company Where Id NOT in (589,590,591,592,593,594))
Union All

Select Count(*) As RecordCount,'Workflow.Schedule Task' As TableName from WorkFlow.ScheduleTask 
Where CompanyId In (Select ID From Common.Company Where Id NOT in (589,590,591,592,593,594))
Union All

Select Count(*) As RecordCount,'Workflow.Schedule Task Detail' As TableName
from WorkFlow.ScheduleTaskDetail SCTD
Inner Join  WorkFlow.ScheduleTask SCT on SCT.Id=SCTD.ScheduleTaskId
Where CompanyId In (Select ID From Common.Company Where Id NOT in (589,590,591,592,593,594))
Union All

Select Count(*) As RecordCount,'Workflow.Cases' As TableName from WorkFlow.CaseGroup
Where CompanyId In (Select ID From Common.Company Where Id NOT in (589,590,591,592,593,594))
Union All

Select Count(*) As RecordCount,'Workflow.Cases History' As TableName from WorkFlow.CaseStatusChange
Where CompanyId In (Select ID From Common.Company Where Id NOT in (589,590,591,592,593,594))
Union All

Select Count(*) As RecordCount,'Workflow.Cases Incharges' As TableName
from WorkFlow.CaseIncharge CI
Inner Join WorkFlow.CaseGroup CG on CG.Id=CI.CaseId
Where CompanyId In (Select ID From Common.Company Where Id NOT in (589,590,591,592,593,594))
Union All

Select Count(*) As RecordCount,'Workflow.Cases Amend Date' As TableName 
from WorkFlow.CaseAmendDateOfCompletion CDC
Inner Join WorkFlow.CaseGroup CG on CG.Id=CDC.CaseId
Where CompanyId In (Select ID From Common.Company Where Id NOT in (589,590,591,592,593,594))
Union All

--Select Count(*) As RecordCount,'Workflow.Cases Assigned'  from WorkFlow.CasesAssigned

--Where CompanyId In (Select ID From Common.Company Where Id NOT in (589,590,591,592,593,594))

Select Count(*) As RecordCount,'Workflow.Cases Designation' As TableName
from WorkFlow.CaseDesignation CD
Inner Join WorkFlow.CaseGroup CG on CG.Id=CD.CaseId
Where CompanyId In (Select ID From Common.Company Where Id NOT in (589,590,591,592,593,594))
Union All

Select Count(*) As RecordCount,'Workflow.Cases Doc' As TableName from WorkFlow.CaseDoc
Where CompanyId In (Select ID From Common.Company Where Id NOT in (589,590,591,592,593,594))
Union All

Select Count(*) As RecordCount,'Workflow.Cases Feature' As TableName
from WorkFlow.CaseFeature CF
Inner Join WorkFlow.CaseGroup CG on CG.Id=CF.CaseId
Where CompanyId In (Select ID From Common.Company Where Id NOT in (589,590,591,592,593,594))
Union All

Select Count(*) As RecordCount,'Workflow.Cases Likeli Hood '  As TableName
from WorkFlow.CaseLikelihoodHistory CLH
Inner Join WorkFlow.CaseGroup CG on CG.Id=CLH.CaseId
Where CompanyId In (Select ID From Common.Company Where Id NOT in (589,590,591,592,593,594))
Union All

Select Count(*) As RecordCount,'Workflow.Cases MileStone '  As TableName
from WorkFlow.CaseMileStone CMS
Inner Join WorkFlow.CaseGroup CG on CG.Id=CMS.CaseId
Where CompanyId In (Select ID From Common.Company Where Id NOT in (589,590,591,592,593,594)) 

End
GO
