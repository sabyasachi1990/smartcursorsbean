USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[Proc_AuditMaterialityPlanningReset]    Script Date: 16-12-2024 9.20.11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

Create Procedure [dbo].[Proc_AuditMaterialityPlanningReset](@companyId bigint,@engagementId uniqueidentifier,@pmsetupId uniqueidentifier)
AS Begin
 Declare @UpdatecompanyId bigint, 
		 @NewPlanningMaterialitySetupDetailId uniqueidentifier,
		 @secondId  uniqueidentifier, 
		 @thirdId uniqueidentifier,
		 @LeadSheetId uniqueidentifier,
		 @ShortCode nvarchar(50),
		 @status bit,
		 @description nvarchar(600),
         @RATIONALE NVARCHAR(400),
		 @RECORDER INT,
		 @Id uniqueidentifier,
		 @ReferenceId uniqueidentifier,
		 @templatestatus nvarchar(100);

  BEGIN TRANSACTION
  BEGIN TRY 

        Delete Audit.PlanningMaterialityDetailLeadSheet  where PlanningMaterialityDetailId in (select id from Audit.PlanningMaterialityDetail where PlanningMeterialityId in (select id from Audit.PlanningMateriality where PlanningMaterialitySetupId=@pmsetupId and EngagementId=@engagementId))
	   Delete Audit.PlanningMaterialityDetail where PlanningMeterialityId in (select id from Audit.PlanningMateriality where PlanningMaterialitySetupId=@pmsetupId and EngagementId=@engagementId)
	   Delete Audit.PlanningMateriality where PlanningMaterialitySetupId=@pmsetupId and EngagementId=@engagementId
       set @ReferenceId=(select ReferenceId from audit.PlanningMaterialitySetup where Id=@pmsetupId)
       select @ShortCode=shortcode,@Rationale=Rationale,@description=Decsription,@RECORDER=RecOrder,@status=Status,@templatestatus=Templatestatus from audit.PlanningMaterialitySetup where Id=@ReferenceId						
	     
				--DECLARE  UpdatePlanningMaterialitySetup CURSOR FOR select CompanyId,Id from Audit.PlanningMaterialitySetup where Id=@ReferenceId
				--OPEN UpdatePlanningMaterialitySetup
				--FETCH NEXT FROM UpdatePlanningMaterialitySetup INTO @UpdatecompanyId,@Id
				--WHILE @@FETCH_STATUS = 0
				--BEGIN																										
					--If Exists(select  Id from audit.leadsheet where companyid=@companyId and EngagementId=@engagementId)
						--Begin
							Update audit.PlanningMaterialitySetup set ShortCode=@ShortCode,Rationale=@Rationale,decsription=@description,RecOrder=@RECORDER,Status=@status,Templatestatus=@templatestatus 
							where Id=@pmsetupId

							--need to delete detail and child detail
							delete Audit.PlanningMaterialityLeadSheet where PlanningMaterialitySetupDetailId in (select Id from  Audit.PlanningMaterialitySetupDetail where PlanningMaterialitySetupId=@pmsetupId)
							delete Audit.PlanningMaterialitySetupDetail where PlanningMaterialitySetupId=@pmsetupId

							--inner cursor for update detail								
							DECLARE  SavePlanningMaterialitySetupDetail CURSOR FOR select Id from Audit.PlanningMaterialitySetupDetail where PlanningMaterialitySetupId=@ReferenceId
							OPEN SavePlanningMaterialitySetupDetail
							FETCH NEXT FROM SavePlanningMaterialitySetupDetail INTO @secondId
							WHILE @@FETCH_STATUS = 0
							BEGIN																										
						    
									select @NewPlanningMaterialitySetupDetailId = newid();

									insert into  AUDIT.[PlanningMaterialitySetupDetail] (Id,PlanningMaterialitySetupId,SystemType,IsNA,Type,Amount,LeadSheetShortCode,LeadSheeType,TypeName,Lowrange,HighRange,IsIncrementedByApplicable,IncrementedBy,IsAllowExceed,RecOrder)
									Select @NewPlanningMaterialitySetupDetailId as Id,@pmsetupId,SystemType,IsNA,Type,Amount,LeadSheetShortCode,LeadSheeType,TypeName,Lowrange,HighRange,IsIncrementedByApplicable,IncrementedBy,
									IsAllowExceed,RecOrder from Audit.[PlanningMaterialitySetupDetail] where Id=@secondId

											--inner cursor for detail child detail							
											DECLARE  PlanningMaterialityLeadSheet CURSOR FOR select Id,LeadSheetId from Audit.PlanningMaterialityLeadSheet
												where PlanningMaterialitySetupDetailId=@secondId
													OPEN PlanningMaterialityLeadSheet
													FETCH NEXT FROM PlanningMaterialityLeadSheet INTO @thirdId,@LeadSheetId
													WHILE @@FETCH_STATUS = 0
													BEGIN																								
														INSERT INTO AUDIT.[PlanningMaterialityLeadSheet] (Id,PlanningMaterialitySetupDetailId,LeadSheetId,Recorder)
														Select NewId(),@NewPlanningMaterialitySetupDetailId,
														(select Id from Audit.LeadSheet where CompanyId=@companyId and ReferenceId=@LeadSheetId and EngagementId=@engagementId),
														RecOrder from Audit.PlanningMaterialityLeadSheet where Id=@thirdId												
														
												FETCH NEXT FROM PlanningMaterialityLeadSheet INTO @thirdId,@LeadSheetId	
												END														
												CLOSE PlanningMaterialityLeadSheet
												DEALLOCATE PlanningMaterialityLeadSheet
							
							FETCH NEXT FROM SavePlanningMaterialitySetupDetail INTO @secondId
							END
							CLOSE SavePlanningMaterialitySetupDetail
							DEALLOCATE SavePlanningMaterialitySetupDetail
						--End
				--FETCH NEXT FROM UpdatePlanningMaterialitySetup INTO @UpdatecompanyId,@Id
				--END
				--CLOSE UpdatePlanningMaterialitySetup
				--DEALLOCATE UpdatePlanningMaterialitySetup

  COMMIT TRANSACTION
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

End
GO
