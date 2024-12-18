USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[SP_Delete_Override]    Script Date: 16-12-2024 9.20.11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
 



 CREATE PROCEDURE [dbo].[SP_Delete_Override](@engagementId UNIQUEIDENTIFIER,@companyId bigint)
 AS BEGIN
   BEGIN TRANSACTION
   BEGIN TRY 

  --Comment,Reply
       Delete r from Common.Reply as r JOIN Common.Comment as c on c.Id=r.CommentId WHERE c.GroupTypeId=@engagementId
       Delete Common.Comment WHERE GroupTypeId=@engagementId
  --DocumentRepository
       Delete Common.DocRepository WHERE TypeId=@engagementId
  --UserApproval
       Delete Audit.UserApproval where EngagementId=@engagementId
  --PlanningMateriality,PlanningMateriality
  --added anil newly
       Delete  PMDL from Audit.PlanningMateriality AS PM JOIN Audit.PlanningMaterialityDetail PMD ON PM.Id=PMD.PlanningMeterialityId JOIN  Audit.PlanningMaterialityDetailLeadSheet PMDL ON PMD.Id = PMDL.PlanningMaterialityDetailId WHERE PM.EngagementId=@engagementId
     
	   Delete PMD from Audit.PlanningMateriality AS PM JOIN Audit.PlanningMaterialityDetail PMD ON PM.Id=PMD.PlanningMeterialityId WHERE PM.EngagementId=@engagementId
       Delete Audit.PlanningMateriality where EngagementId=@engagementId
  --AccountAnnotation,NoteAdjustment,NoteAttachment
       Delete Audit.AccountAnnotation where EngagementID=@engagementId
       Delete NAd FROM Audit.NoteAdjustment As NAd JOIN Audit.Note AS N ON N.Id=NAd.NoteId WHERE N.EngagementId=@engagementId
       --Delete NAt FROM Audit.NoteAttachment As NAt JOIN Audit.Note AS N ON N.Id=NAt.NoteId WHERE N.EngagementId=@engagementId
       Delete Audit.Note WHERE EngagementId=@engagementId
  --AdjustmentAccount,AdjustmentFileAttachment,AdjustmentStatusHistory,Adjustment
       Delete ADJA FROM Audit.Adjustment AS AJD JOIN Audit.AdjustmentAccount  AS ADJA ON AJD.ID=ADJA.AdjustmentID WHERE AJD.EngagementID=@engagementId
       --Delete ADJFA FROM Audit.Adjustment AS AJD JOIN Audit.AdjustmentFileAttachment  AS ADJFA ON AJD.ID=ADJFA.AdjustmentID WHERE AJD.EngagementID=@engagementId
       Delete ADJH FROM Audit.Adjustment AS AJD JOIN Audit.AdjustmentStatusHistory  AS ADJH ON AJD.ID=ADJH.AdjustmentID WHERE AJD.EngagementID=@engagementId
       Delete FROM Audit.Adjustment where EngagementID=@engagementId

  --ForeignExchange,FEAnalysis
     Delete FEACD from Audit.FEAnalysisCurrencyDetails AS FEACD JOIN Audit.FEAnalysisCountryCurrency AS FEACC ON FEACC.ID=FEACD.CuntryCurrencyID 
     JOIN Audit.FEAnalysis AS FEA ON FEACC.FEAnalysisID=FEA.ID 
     JOIN Audit.ForeignExchange AS FE ON FE.ID=FEA.ForeignExchangeID where FE.EngagementID=@engagementId
     Delete FEACC from Audit.FEAnalysisCountryCurrency AS FEACC
     JOIN Audit.FEAnalysis AS FEA ON FEACC.FEAnalysisID=FEA.ID 
     JOIN Audit.ForeignExchange AS FE ON FE.ID=FEA.ForeignExchangeID where FE.EngagementID=@engagementId
     Delete FEAL from Audit.FEAnalysisLegend As FEAL JOIN Audit.FEAnalysis AS FEA ON FEA.ID=FEAL.FEAnalysisID 
     JOIN Audit.ForeignExchange AS FE ON FEA.ForeignExchangeID=FE.ID where FE.EngagementID=@engagementId
     Delete FEAN from Audit.FEAnalysisNote As FEAN JOIN Audit.FEAnalysis AS FEA ON FEA.ID=FEAN.FEAnalysisID 
     JOIN Audit.ForeignExchange AS FE ON FEA.ForeignExchangeID=FE.ID where FE.EngagementID=@engagementId
     Delete FCAF  from  Audit.ForeignCurrencyAnalysisFactors AS FCAF JOIN Audit.ForeignCurrencyAnalysis AS FECA ON FCAF.FCAnalysisID=FECA.ID
     JOIN Audit.ForeignExchange AS FE ON FE.ID=FECA.foreignexchangeid where FE.EngagementID=@engagementId

     Delete FECA  from  Audit.ForeignCurrencyAnalysis AS FECA JOIN Audit.ForeignExchange AS FE ON FE.ID=FECA.foreignexchangeid where FE.EngagementID=@engagementId
     Delete FEA from Audit.FEAnalysis AS FEA JOIN Audit.ForeignExchange AS FE ON FE.ID=FEA.ForeignExchangeID where EngagementID=@engagementId
     Delete from Audit.ForeignExchange where EngagementID=@engagementId
  --Trialbalance Audittrials,Trialbalance Tickmarks
     --Delete from Audit.TrialBalanceTickmark where EngagementID=@engagementId
     Delete from Audit.TrialBalanceAuditTrail where EngagementID=@engagementId
	 --Delete from Audit.TrialBalanceFileDetails where EngagementID=@engagementId
	 --Delete from Audit.TrialBalanceImport where EngagementID=@engagementId

  --GeneralLedger
       Delete gld from Audit.GeneralLedgerDetail as gld JOIN Audit.GeneralLedgerImport as gl ON gld.GeneralLedgerId=gl.Id
       where gl.EngagementId=@engagementId
       Delete from Audit.GeneralLedgerImport where EngagementID=@engagementId
       --Delete from Audit.GeneralLedgerFileDetails where EngagementID=@engagementId
 ----Disclosure	  
       DELETE Audit.DisclosureDetails where DisclosureId in(select id from audit.Disclosure  where EngagementId=@engagementId)
	   DELETE Audit.DisclosureSections where DisclosureId in(select id from audit.Disclosure  where EngagementId=@engagementId)
	   DELETE Audit.Disclosure  where EngagementId=@engagementId
   --Category
       DELETE Audit.Category  where EngagementId=@engagementId
	   DELETE Audit.SubCategory  where EngagementId=@engagementId
 ----Equity
         DELETE Audit.Equity  where EngagementId=@engagementId
		 ----Order
         DELETE Audit.[Order]  where EngagementId=@engagementId

		 ---------CashFlow-------------
		 delete Audit.CashFlowItemDetail where CashFlowItemId in (select id from Audit.CashFlowItem where CashFlowId in (select id from audit.CashFlow where EngagementId=@engagementId))
		 delete Audit.CashFlowItem where CashFlowId in (select id from audit.CashFlow where EngagementId=@engagementId)
		 delete audit.CashFlow where EngagementId=@engagementId

-------order update 
      update Audit.AuditCompanyEngagement set StatementBOrder=NULL where id=@engagementId

	  
-------Menu Setup TemplateName Update
      --update  Audit.AuditCompanyMenuMaster  set TemplateName=null where EngagementId=@engagementId and Heading <> 'Revenue'



	  Delete from Audit.TrialBalanceImport where EngagementID=@engagementId

	  Begin 
	  declare @AuditCompanyId uniqueidentifier;
	  set @AuditCompanyId=(select AuditCompanyId from Audit.AuditCompanyEngagement where id=@engagementId)
	  exec [dbo].[SP_CreateCashFlow] @engagementId,@CompanyId ,@AuditCompanyId 
	  
	  End

   BEGIN 
      COMMIT TRANSACTION
    END
   END TRY

   BEGIN CATCH
        DECLARE
        @ErrorMessage NVARCHAR(4000),
        @ErrorSeverity INT,
        @ErrorState INT;
        SELECT
        @ErrorMessage = ERROR_MESSAGE(),
        @ErrorSeverity = ERROR_SEVERITY(),
        @ErrorState = ERROR_STATE();
        RAISERROR (@ErrorMessage,@ErrorSeverity,@ErrorState);
    ROLLBACK TRANSACTION
    END CATCH
 END
GO
