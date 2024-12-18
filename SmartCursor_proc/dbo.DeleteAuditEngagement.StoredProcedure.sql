USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[DeleteAuditEngagement]    Script Date: 16-12-2024 9.20.10 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
 
CREATE PROCEDURE [dbo].[DeleteAuditEngagement] (@engagementId UNIQUEIDENTIFIER)
	As Begin
 
				Delete Audit.Roles where EngagementId=@engagementId

				Delete from audit.wpsetuptickmark where tickmarkId in (select id from Audit.TickMarkSetup where EngagementId=@engagementId)

				Delete Audit.TickMarkSetup where EngagementId=@engagementId

				Delete from Audit.GeneralLedgerDetail where GeneralLedgerId in (select id  from Audit.GeneralLedgerImport where EngagementId=@engagementId)

                Delete  from Audit.GeneralLedgerImport where EngagementId=@engagementId

				Delete Common.[Suggestion ] where EngagementId=@engagementId

				Delete Audit.AccountPolicyDetail where MasterId in (select id from Audit.AccountPolicy where EngagementId =@engagementId)

				Delete Audit.AccountPolicy where EngagementId =@engagementId

				Delete Audit.PlanningMaterialityLeadSheet where PlanningMaterialitySetupDetailId in (select Id from Audit.PlanningMaterialitySetupDetail where PlanningMaterialitySetupId in (select Id from Audit.PlanningMaterialitySetup where EngagementId=@engagementId))

				Delete Audit.PlanningMaterialitySetupDetail where PlanningMaterialitySetupId in (select Id from Audit.PlanningMaterialitySetup where EngagementId=@engagementId)

				Delete  Audit.PlanningMaterialityDetailLeadSheet where PlanningMaterialityDetailId in (select id from Audit.PlanningMaterialityDetail where PlanningMeterialityId in (select id from Audit.PlanningMateriality where EngagementId=@engagementId))

                Delete  Audit.PlanningMaterialityDetail where PlanningMeterialityId in (select id from Audit.PlanningMateriality where EngagementId=@engagementId)

                Delete   Audit.PlanningMateriality where EngagementId=@engagementId

				Delete Audit.PlanningMaterialitySetup where EngagementId=@engagementId

				delete q from Audit.PAndCSectionQuestions q join Audit.PAndCSections s on q.PAndCSectionId=s.id
                join Audit.PlanningAndCompletionSetUp  pl on s.PlanningAndCompletionSetUpId=pl.Id
                where pl.EngagementId=@engagementId

				Delete Audit.PAndCSections where PlanningAndCompletionSetUpId in (select id from Audit.PlanningAndCompletionSetUp   where EngagementId=@engagementId)

				Delete from Audit.DirectorRemunerationDetails where DirectorRemunerationId in (select id from Audit.DirectorRemuneration where PlanningAndCompletionSetUpId in(select id from Audit.PlanningAndCompletionSetUp   where EngagementId=@engagementId))

				Delete Audit.DirectorRemuneration where PlanningAndCompletionSetUpId in(select id from Audit.PlanningAndCompletionSetUp   where EngagementId=@engagementId)

				Delete Audit.ClientAndEngagementIndependenceConfirmation where PlanningAndCompletionSetUpId  in(select id from Audit.PlanningAndCompletionSetUp   where EngagementId=@engagementId)

				Delete Audit.DeclarationOfDirectors  where EngagementId=@engagementId

				Delete Audit.PlanningAndCompletionSetUp   where EngagementId=@engagementId

				Delete Audit.ReportingTemplates where EngagementId=@engagementId

				Delete Audit.Category where EngagementId=@engagementId

				Delete Audit.SubCategory where EngagementId=@engagementId

				Delete Audit.AccountAnnotation where EngagementId=@engagementId

				Delete Audit.DisclosureSections where DisclosureId in (select Id from Audit.Disclosure where EngagementId=@engagementId)
   
				Delete Audit.DisclosureDetails where DisclosureId in (select Id from Audit.Disclosure where EngagementId=@engagementId)

				Delete Audit.Disclosure where EngagementId=@engagementId

				Delete Audit.CashFlowItemDetail  where CashFlowItemId in (select id from Audit.CashFlowItem where CashFlowId in (select Id from Audit.CashFlow where EngagementId=@engagementId))

				Delete Audit.CashFlowItemDetail where LeadSheetId in (select id from  Audit.LeadSheet where EngagementId=@engagementId)

				Delete Audit.CashFlowItem where CashFlowId in (select Id from Audit.CashFlow where EngagementId=@engagementId) 

				Delete Audit.CashFlow where EngagementId=@engagementId

				Delete Audit.AuditMenuPermissions where AuditCompanyMenuMasterId in (select Id from Audit.AuditCompanyMenuMaster where EngagementId=@engagementId) 
								
			    Delete Audit.LeadSheetCategories where LeadsheetId in (select id from  Audit.LeadSheet where EngagementId=@engagementId)

				Delete Audit.LeadSheet where EngagementId=@engagementId

		        Delete Audit.WPSetupTickmark where WPSetupId in (select id from Audit.WPSetup where EngagementId=@engagementId)

				Delete Audit.WPSetup where EngagementId=@engagementId

				Delete Audit.AuditCompanyMenuMaster where EngagementId=@engagementId

				Delete Audit.EngagementVisitedHistory where EngagementId =@engagementId

				Delete from Audit.EngagementPercentage where EngagementId=@engagementId

				Delete Audit.AuditCompanyEngagementDetails where AuditCompanyEngagementId=@engagementId

				Delete from Audit.FormDetail where FormMasterid  in (select id from Audit.FormMaster where engagementid=@engagementId)
				 
				Delete from Audit.FormMaster where engagementid=@engagementId

				delete from audit.trialbalancefiledetails where engagementid=@engagementId

				delete from common.reply where commentid in 
				(select id from common.comment where GroupTypeId=@engagementId)

				delete from common.comment where GroupTypeId=@engagementId

				delete from Audit.UserApproval where engagementid=@engagementId

				  delete from Audit.FEAnalysisCurrencyDetails where CuntryCurrencyID in 
				  (	select id  from Audit.FEAnalysisCountryCurrency where FEAnalysisID in 
				  ( select id  from Audit.FEAnalysis where ForeignExchangeid in 
				  (select id  from Audit.ForeignExchange where engagementid=@engagementId)))

				delete from Audit.FEAnalysisCountryCurrency where FEAnalysisID in 
				  ( select id  from Audit.FEAnalysis where ForeignExchangeid in 
				  (select id  from Audit.ForeignExchange where engagementid=@engagementId))


				  	  delete from Audit.ForeignCurrencyAnalysisFactors where FCAnalysisID in 
				  (select id  from Audit.ForeignCurrencyAnalysis where ForeignExchangeid in 
				  (select id  from Audit.ForeignExchange where engagementid=@engagementId))

				  		  delete from Audit.ForeignCurrencyAnalysis where ForeignExchangeid in 
				  (select id  from Audit.ForeignExchange where engagementid=@engagementId)
				  

				  	 delete from Audit.FEAnalysis where ForeignExchangeid in 
				  (select id  from Audit.ForeignExchange where engagementid=@engagementId)

				  delete from Audit.ForeignExchange where engagementid=@engagementId

				  delete from Audit.NoteAdjustment  where Adjustmentid in
					(select id from Audit.Adjustment where engagementid=@engagementId)

				  delete from Audit.AdjustmentAccount where Adjustmentid in
					(select id from Audit.Adjustment where engagementid=@engagementId)
  			  
			       delete from Audit.Adjustment where engagementid=@engagementId

				delete from audit.trialbalanceimport where engagementid=@engagementId

				delete from Audit.TrialBalanceAuditTrail where engagementid=@engagementId

				delete from Audit.TrialBalanceFileDetails where engagementid=@engagementId

				delete from Audit.AuditCompanyEngagementDetails where AuditCompanyEngagementId =@engagementId

				delete from Audit.ChangesInEquity where engagementid=@engagementId

				 delete from audit.samplingdetail where samplingid in 
				 (select id from audit.sampling where engagementid=@engagementId)

				  delete from audit.sampling where engagementid=@engagementId

				  delete common.docrepository where typeid =@engagementId

				  delete Audit.TemplateVariable where engagementid=@engagementId

				Delete audit.AuditCompanyEngagement where Id=@engagementId

				
			 
END
GO
