USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[Tax_EngagementDelete]    Script Date: 16-12-2024 9.20.11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


--------------------------------
Create PROCEDURE [dbo].[Tax_EngagementDelete] (@engagementId UNIQUEIDENTIFIER)
	As Begin

		Begin Transaction
		BEGIN TRY
			Delete Tax.Roles where EngagementId=@engagementId					

			Delete Common.[Suggestion ] where EngagementId=@engagementId
			
			Delete tax.AccountPolicyDetail where MasterId in (select id from Audit.AccountPolicy where EngagementId =@engagementId)

			Delete Tax.AccountPolicy where EngagementId =@engagementId

			delete q from Tax.PAndCSectionQuestions q join Tax.PAndCSections s on q.PAndCSectionId=s.id
            join Tax.PlanningAndCompletionSetUp  pl on s.PlanningAndCompletionSetUpId=pl.Id
            where pl.EngagementId=@engagementId				

			Delete Tax.PAndCSections where PlanningAndCompletionSetUpId in (select id from Tax.PlanningAndCompletionSetUp   where EngagementId=@engagementId)
				
			Delete from Tax.DirectorRemunerationDetails where DirectorRemunerationId in (select id from Tax.DirectorRemuneration where PlanningAndCompletionSetUpId in(select id from Tax.PlanningAndCompletionSetUp   where EngagementId=@engagementId))
				
			Delete Tax.DirectorRemuneration where PlanningAndCompletionSetUpId in(select id from Tax.PlanningAndCompletionSetUp   where EngagementId=@engagementId)
				
			Delete Tax.ClientAndEngagementIndependenceConfirmation where PlanningAndCompletionSetUpId  in(select id from Tax.PlanningAndCompletionSetUp   where EngagementId=@engagementId)

			Delete Tax.PlanningAndCompletionSetUp   where EngagementId=@engagementId

			Delete Tax.Category where EngagementId=@engagementId				

			Delete Tax.SubCategory where EngagementId=@engagementId

			Delete Tax.TaxMenuPermissions where TaxCompanyMenuMasterId in (select Id from tax.TaxCompanyMenuMaster where EngagementId=@engagementId) 
													
			Delete Tax.ClassificationCategories where ClassificationId in (select id from  Tax.Classification where EngagementId=@engagementId)

			Delete Tax.Classification where EngagementId=@engagementId

			Delete Tax.TaxCompanyMenuMaster where EngagementId=@engagementId

			Delete Tax.EngagementVisitedHistory where EngagementId =@engagementId

			Delete tax.TaxCompanyEngagementDetails where TaxCompanyEngagementId=@engagementId

			Delete from Tax.FormDetail where FormMasterid  in (select id from Tax.FormMaster where engagementid=@engagementId)
				 
			Delete from Tax.FormMaster where engagementid=@engagementId
			--Comment,Reply
					  Delete R from Common.Reply as R JOIN Common.Comment as C on C.Id=R.CommentId WHERE C.GroupTypeId=@engagementId
					  Delete Common.Comment WHERE GroupTypeId=@engagementId
		--DocumentRepository
					  Delete Common.DocRepository WHERE TypeId=@engagementId
		--AccountAnnotation,NoteAttachment,Split
					  Delete Tax.AccountAnnotation where EngagementID=@engagementId
					  Delete NAt FROM Tax.NoteAttachment As NAt JOIN Tax.Note AS N ON N.Id=NAt.NoteId WHERE N.EngagementId=@engagementId
		--UserApproval
					  Delete Tax.UserApproval where EngagementId=@engagementId					  
					
					  		 
	   --MedicalExpenses,MedicalExpenseDetails
					  Delete MED FROM Tax.MedicalExpenseDetails As MED JOIN Tax.MedicalExpenses AS ME ON MED.MedicalExpensesId=ME.Id WHERE ME.EngagementId=@engagementId
                      Delete ME FROM Tax.MedicalExpenses As ME where ME.EngagementID=@engagementId
	   ---ProfitAndLossAuditTrail
	   Delete TAT FROM Tax.ProfitAndLossAuditTrail AS TAT WHERE TAT.EngagementId=@engagementId 
	   ---StatementA
	   Delete SA FROM Tax.StatementA AS SA  WHERE SA.EngagementId=@engagementId 

	  ---Tax.InterestRestriction & Tax.InterestExpenses  & Tax.InvestmentSchedule

 		delete IE from Tax.InterestRestriction IR
         join tax.InterestExpenses IE on IE.InterestRestrictionId = IR.ID
           where IR.EngagementId=@engagementId

		   delete ins from Tax.InterestRestriction IR
              join Tax.InvestmentSchedule INS on INS.InterestRestrictionId = IR.ID
              where IR.EngagementId=@engagementId

          delete IR from Tax.InterestRestriction IR where IR.EngagementId=@engagementId
		 

		 -----Tax.Tax.RentalIncomeDetail &Tax.RentalIncome
	   	   
		  delete rd from Tax.RentalIncomeDetail rd join Tax.RentalIncome r on rd.RentalIncomeId = r.Id where r.EngagementId=@engagementId
		  delete r from Tax.RentalIncome r where r.EngagementId=@engagementId

		   -----Tax.Tax.FurtherDeductionDetail &Tax.FurtherDeduction
	   	   
		  delete fd from Tax.FurtherDeductionDetail fd join Tax.FurtherDeduction f on fd.FurtherDeductionId = f.id where f.EngagementId=@engagementId
		  delete f from Tax.FurtherDeduction f where f.EngagementId=@engagementId
		   
		    -----Tax.Section14QDetails & Tax.Section14QAdditions & Tax.Section14QEligibleExp & Tax.Section14Q
	   	   
		  delete sd from Tax.Section14Q s join Tax.Section14QDetails sd on sd.Section14QId = s.Id where s.EngagementId=@engagementId
		  delete sa from Tax.Section14Q s join Tax.Section14QAdditions sa on sa.Section14QId = s.Id where s.EngagementId=@engagementId
          delete se from Tax.Section14Q s join Tax.Section14QEligibleExp se on se.Section14QId = s.Id where s.EngagementId=@engagementId
		  delete s  from Tax.Section14Q s where s.EngagementId=@engagementId

		    ---Tax.Disposal & Tax.SectionB & Tax.SectionADetail & Tax.SectionA
	      
		  delete D from Tax.Disposal D join Tax.SectionA SA on D.SectionAId = SA.Id where SA.EngagementId=@engagementId
		  delete SB from Tax.SectionB SB join Tax.SectionA SA on SB.SectionAId = SA.Id where SA.EngagementId=@engagementId
		  delete SAD from Tax.SectionADetail SAD join Tax.SectionA SA on SAD.SectionAId = SA.Id where SA.EngagementId=@engagementId
		  delete SA from Tax.SectionA SA where SA.EngagementId=@engagementId



		   -----Tax.NonTradeIncomeDetail &Tax.NonTradeIncome
	   	   
		  delete ntd from Tax.NonTradeIncomeDetail ntd join Tax.NonTradeIncome nt on ntd.NonTradeIncomeId = nt.Id where nt.EngagementId=@engagementId
		  delete nt from Tax.NonTradeIncome nt where nt.EngagementId=@engagementId

		  ---Tax.Donation
		  delete dr from Tax.DonationReference dr where dr.EngagementId=@engagementId
		  delete d from Tax.Donation d where d.EngagementId=@engagementId

		  --carry forward and detail

		  delete cfd from Tax.CarryForwardDetail cfd join Tax.CarryForward cf on cfd.CarryForwardId = cf.Id where cf.EngagementId=@engagementId
		  delete cf from Tax.CarryForward cf where cf.EngagementId=@engagementId

		  --split and note

		   Delete SD from Tax.SplitDetail as SD JOIN Tax.Split AS S ON s.Id=SD.SplitId JOIN Tax.Note AS N ON S.NoteId=N.Id where N.EngagementId=@engagementId
		   Delete S from Tax.Split AS S JOIN Tax.Note AS N ON S.NoteId=N.Id where N.EngagementId=@engagementId
		   --note
		   Delete Tax.Note WHERE EngagementId=@engagementId
		    --RollForward
		   Delete Tax.RollForward WHERE NewEngagementId=@engagementId
		   delete tax.TaxAuditTrail where EngagementId=@engagementId
		   delete tax.EngagementPercentage where EngagementId=@engagementId
		   --SubCategory
		   Delete Tax.SubCategory WHERE EngagementId=@engagementId
		   --CategoryDetails
		   Delete Tax.CategoryDetails  WHERE EngagementId=@engagementId	
	       --UserApproval
		   Delete Tax.UserApproval  WHERE EngagementId=@engagementId

			Delete tax.TaxCompanyEngagement where Id=@engagementId			


	Commit Transaction;
END TRY

BEGIN CATCH
	RollBack Transaction;

	DECLARE
	   @ErrorMessage NVARCHAR(4000),
	   @ErrorSeverity INT,
	   @ErrorState INT;
	   SELECT
	   @ErrorMessage = ERROR_MESSAGE(),
	   @ErrorSeverity = ERROR_SEVERITY(),
	   @ErrorState = ERROR_STATE();
	  RAISERROR (@ErrorMessage,@ErrorSeverity,@ErrorState);
END CATCH

end

GO
