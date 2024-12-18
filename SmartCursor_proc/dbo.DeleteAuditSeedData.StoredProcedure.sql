USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[DeleteAuditSeedData]    Script Date: 16-12-2024 9.20.10 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
 
CREATE PROCEDURE [dbo].[DeleteAuditSeedData] (@EngagementId uniqueidentifier)
 AS Begin

 
delete from Audit.DisclosureSections where DisclosureId in ((select id from Audit.Disclosure where id in (select DisclosureId from Audit.ReportingTemplates where EngagementId=@EngagementId )))
delete from Audit.DisclosureDetails where DisclosureId in (select id from Audit.Disclosure where id in
 (select DisclosureId from Audit.ReportingTemplates where EngagementId=@EngagementId ))
delete from  Audit.ReportingTemplates where EngagementId=@EngagementId
delete from Audit.Disclosure where id in (select DisclosureId from Audit.ReportingTemplates where EngagementId=@EngagementId )

 print 'Disclosure'

delete from Audit.SubCategory where parentid in (select id from Audit.Category where EngagementId =@EngagementId)
delete from Audit.Category where EngagementId =@EngagementId

 print 'Income statement'
 
  delete from Audit.PlanningMaterialityDetailLeadSheet where  PlanningMaterialityDetailId in
 ( select id from Audit.PlanningMaterialityDetail where PlanningMeterialityId in   (select id from  audit.PlanningMateriality where engagementid=@EngagementId))
  delete from Audit.PlanningMaterialityDetail where PlanningMeterialityId in   (select id from  audit.PlanningMateriality where engagementid=@EngagementId)

   print 'PlanningMaterialityDetail'

  delete from  Audit.PlanningMaterialityLeadSheet where PlanningMaterialitySetupDetailId in 
 (select Id from  Audit.PlanningMaterialitySetupDetail where PlanningMaterialitySetupId in (select id from   audit.PlanningMaterialitySetup where engagementid=@EngagementId))
 delete from  Audit.PlanningMaterialitySetupDetail where PlanningMaterialitySetupId in (select id from   audit.PlanningMaterialitySetup where engagementid=@EngagementId)
delete from  audit.PlanningMaterialitySetup where engagementid=@EngagementId

 print 'PlanningMaterialitySetup'
  
delete audit.Template where EngagementId=@EngagementId
delete from Audit.AccountPolicyDetail where MasterId in (select id from Audit.AccountPolicy where EngagementId=@EngagementId )
delete from Audit.AccountPolicy  where EngagementId=@EngagementId


 print 'Template'
 print 'AccountPolicy'

 print @EngagementId


End
GO
