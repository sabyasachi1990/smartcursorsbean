USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[Sp_AuditEngagementDelete]    Script Date: 16-12-2024 9.20.11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
 
 

CREATE PROCEDURE [dbo].[Sp_AuditEngagementDelete] (@engagementId UNIQUEIDENTIFIER)
	As Begin
		--Begin Transaction
		--BEGIN TRY
				Delete Audit.Roles where EngagementId=@engagementId
				
				print getdate();print '1';

				Delete from audit.wpsetuptickmark where tickmarkId in (select id from Audit.TickMarkSetup where EngagementId=@engagementId)

					print getdate();print '2';

				Delete Audit.TickMarkSetup where EngagementId=@engagementId

				
					print getdate();print '3';

				Delete from Audit.GeneralLedgerDetail where GeneralLedgerId in (select id  from Audit.GeneralLedgerImport where EngagementId=@engagementId)

				
					print getdate();print '4';

                Delete  from Audit.GeneralLedgerImport where EngagementId=@engagementId

				print getdate();print '5';

				Delete Common.[Suggestion ] where EngagementId=@engagementId

				print getdate();print '6';

				Delete Audit.AccountPolicyDetail where MasterId in (select id from Audit.AccountPolicy where EngagementId =@engagementId)

				print getdate();print '7';

				Delete Audit.AccountPolicy where EngagementId =@engagementId

				print getdate();print '8';

				Delete Audit.PlanningMaterialityLeadSheet where PlanningMaterialitySetupDetailId in (select Id from Audit.PlanningMaterialitySetupDetail where PlanningMaterialitySetupId in (select Id from Audit.PlanningMaterialitySetup where EngagementId=@engagementId))

				print getdate();print '9';

				Delete Audit.PlanningMaterialitySetupDetail where PlanningMaterialitySetupId in (select Id from Audit.PlanningMaterialitySetup where EngagementId=@engagementId)

				print getdate();print '10';

				Delete  Audit.PlanningMaterialityDetailLeadSheet where PlanningMaterialityDetailId in (select id from Audit.PlanningMaterialityDetail where PlanningMeterialityId in (select id from Audit.PlanningMateriality where EngagementId=@engagementId))

				print getdate();print '11';

                Delete  Audit.PlanningMaterialityDetail where PlanningMeterialityId in (select id from Audit.PlanningMateriality where EngagementId=@engagementId)

				print getdate();print '12';

                Delete   Audit.PlanningMateriality where EngagementId=@engagementId

				print getdate();print '13';

				Delete Audit.PlanningMaterialitySetup where EngagementId=@engagementId

				print getdate();print '14';
				

				delete q from Audit.PAndCSectionQuestions q join Audit.PAndCSections s on q.PAndCSectionId=s.id
                join Audit.PlanningAndCompletionSetUp  pl on s.PlanningAndCompletionSetUpId=pl.Id
                where pl.EngagementId=@engagementId

				print getdate();print '15';

				Delete Audit.PAndCSections where PlanningAndCompletionSetUpId in (select id from Audit.PlanningAndCompletionSetUp   where EngagementId=@engagementId)

				print getdate();print '16';

				Delete from Audit.DirectorRemunerationDetails where DirectorRemunerationId in (select id from Audit.DirectorRemuneration where PlanningAndCompletionSetUpId in(select id from Audit.PlanningAndCompletionSetUp   where EngagementId=@engagementId))

				print getdate();print '17';

				Delete Audit.DirectorRemuneration where PlanningAndCompletionSetUpId in(select id from Audit.PlanningAndCompletionSetUp   where EngagementId=@engagementId)

				print getdate();print '18';

				Delete Audit.ClientAndEngagementIndependenceConfirmation where PlanningAndCompletionSetUpId  in(select id from Audit.PlanningAndCompletionSetUp   where EngagementId=@engagementId)

				print getdate();print '19';

				Delete Audit.DeclarationOfDirectors  where EngagementId=@engagementId

				print getdate();print '20';

				Delete Audit.PlanningAndCompletionSetUp   where EngagementId=@engagementId

				print getdate();print '21';

				Delete Audit.ReportingTemplates where EngagementId=@engagementId

				print getdate();print '22';

				Delete Audit.Category where EngagementId=@engagementId

				print getdate();print '23';

				Delete Audit.SubCategory where EngagementId=@engagementId

				Delete Audit.AccountAnnotation where EngagementId=@engagementId
				

				Delete Audit.DisclosureSections where DisclosureId in (select Id from Audit.Disclosure where EngagementId=@engagementId)
   
				Delete Audit.DisclosureDetails where DisclosureId in (select Id from Audit.Disclosure where EngagementId=@engagementId)

				Delete Audit.Disclosure where EngagementId=@engagementId

				Delete Audit.CashFlowItemDetail  where CashFlowItemId in (select id from Audit.CashFlowItem where CashFlowId in (select Id from Audit.CashFlow where EngagementId=@engagementId))

				Delete Audit.CashFlowItem where CashFlowId in (select Id from Audit.CashFlow where EngagementId=@engagementId) 

				Delete Audit.CashFlow where EngagementId=@engagementId

				Delete Audit.AuditMenuPermissions where AuditCompanyMenuMasterId in (select Id from Audit.AuditCompanyMenuMaster where EngagementId=@engagementId) 

				Delete Audit.FEAnalysisCurrencyDetails where CuntryCurrencyID in (select id from Audit.FEAnalysisCountryCurrency where FEAnalysisID in (select id from Audit.FEAnalysis where ForeignExchangeID in (select id from Audit.ForeignExchange where EngagementID=@engagementId)))

				Delete Audit.FEAnalysisCountryCurrency where FEAnalysisID in (select id from Audit.FEAnalysis where ForeignExchangeID in (select id from Audit.ForeignExchange where EngagementID=@engagementId))

                Delete Audit.FEAnalysis where ForeignExchangeID in (select id from Audit.ForeignExchange where EngagementID=@engagementId)
				
				Delete from Audit.ForeignCurrencyAnalysis where ForeignExchangeID in (select id from Audit.ForeignExchange where EngagementID=@engagementId)

                Delete from Audit.ForeignExchange where EngagementID=@engagementId

								
			    Delete Audit.LeadSheetCategories where LeadsheetId in (select id from  Audit.LeadSheet where EngagementId=@engagementId)

				Delete Audit.CashFlowItemDetail where LeadSheetId in (select id from  Audit.LeadSheet where EngagementId=@engagementId)

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

				delete from Audit.TrialBalanceAuditTrail where engagementid=@engagementId

				Delete audit.AuditCompanyEngagement where Id=@engagementId

				


	--	Commit Transaction;
	--	END TRY
	--BEGIN CATCH
	--	RollBack Transaction;
	--	   DECLARE
	--	   @ErrorMessage NVARCHAR(4000),
	--	   @ErrorSeverity INT,
	--	   @ErrorState INT;
	--	   SELECT
	--	   @ErrorMessage = ERROR_MESSAGE(),
	--	   @ErrorSeverity = ERROR_SEVERITY(),
	--	   @ErrorState = ERROR_STATE();
	--	  RAISERROR (@ErrorMessage,@ErrorSeverity,@ErrorState);
	-- END CATCH
END
GO
