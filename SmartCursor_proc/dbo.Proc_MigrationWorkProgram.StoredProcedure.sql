USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[Proc_MigrationWorkProgram]    Script Date: 16-12-2024 9.20.11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE Procedure [dbo].[Proc_MigrationWorkProgram] (@engagementId uniqueidentifier,@companyId bigint)
AS 
Begin

  BEGIN TRANSACTION
     BEGIN TRY
--select * from Audit.AccountAnnotation where EngagementId='672045cd-f93e-439f-9d51-9c004d929554'

update Audit.AccountAnnotation set ParentId=FeatureId where EngagementId=@engagementId


--select * from Audit.AccountAnnotation where EngagementId='32C45F68-6B0D-4298-82A9-B46265E659E0' and FeatureName !='Foreign Exchange' and FeatureName !='Analytical review' and FeatureName!='Notes' and FeatureName !='Income statement' and FeatureName!='Balance Sheet' and FeatureName!='Changes in Equity'

update  Audit.AccountAnnotation set FeatureId=(select Id from Audit.WPSetup where CompanyId=@companyId and Code=FeatureName) where EngagementId=@engagementId and FeatureName !='Foreign Exchange' and FeatureName !='Analytical review' and FeatureName!='Notes' and FeatureName !='Income statement' and FeatureName!='Balance Sheet' and FeatureName!='Changes in Equity'


--select * from Audit.AccountAnnotation where (FeatureName ='Income statement' or FeatureName='Balance Sheet' or FeatureName='Changes in Equity' or FeatureName='Notes' or FeatureName ='Analytical review') and EngagementId=@engagementId

update Audit.AccountAnnotation set FeatureId=EngagementId where (FeatureName ='Income statement' or FeatureName='Balance Sheet' or FeatureName='Changes in Equity' or FeatureName='Notes' or FeatureName ='Analytical review') and EngagementId=@engagementId


--select * from Audit.AccountAnnotation where FeatureName ='Foreign Exchange' and EngagementId=@engagementId

update Audit.AccountAnnotation set FeatureId=(select id from Audit.AuditCompanyMenuMaster where EngagementId =@engagementId and Heading='Foreign Exchange') where FeatureName ='Foreign Exchange' and EngagementId=@engagementId



--select * from Common.Comment where (pageurl='home.homeengagement.workprogram' or  PageUrl='Workprogram') and GroupTypeId=@engagementId

update Common.Comment set FeatureId=(select id from Audit.WPSetup where CompanyId=@companyId and Code=GroupType) where (pageurl='home.homeengagement.workprogram' or  PageUrl='Workprogram') and GroupTypeId=@engagementId


--select * from Common.Comment where (pageurl='home.homeengagement.planning' or  PageUrl='Planning') and GroupTypeId=@engagementId

update Common.Comment set FeatureId=(select id from Audit.AuditCompanyMenuMaster where EngagementId=@engagementId and Heading=GroupType) where (pageurl='home.homeengagement.planning' or  PageUrl='Planning') and GroupTypeId=@engagementId


--select * from Common.Comment where (pageurl='home.homeengagement.completion' or  PageUrl='completion') and GroupTypeId=@engagementId

update Common.Comment set FeatureId=(select id from Audit.AuditCompanyMenuMaster where EngagementId=@engagementId and Heading=GroupType) where (pageurl='home.homeengagement.completion' or  PageUrl='completion') and GroupTypeId=@engagementId



--select * from Common.Comment where pageurl!='home.homeengagement.completion' and   PageUrl!='completion' and  pageurl!='home.homeengagement.planning' and  PageUrl!='Planning' and pageurl!='home.homeengagement.workprogram' and  PageUrl!='Workprogram'

--select * from Common.Comment where (pageurl='AnalyticalReview' or   PageUrl='home.homeengagement.foreignexchange' or  pageurl='home.homeengagement.template' or  PageUrl='home.homeengagement.listofdirectors' or pageurl='home.homeengagement.signature') and GroupTypeId=@engagementId

update Common.Comment set FeatureId=(select id from Audit.AuditCompanyMenuMaster where EngagementId=@engagementId and Heading=GroupType) where (pageurl='AnalyticalReview' or   PageUrl='home.homeengagement.foreignexchange' or  pageurl='home.homeengagement.template' or  PageUrl='home.homeengagement.listofdirectors' or pageurl='home.homeengagement.signature')  and GroupTypeId=@engagementId


--select * from Common.Comment where (pageurl='home.homeengagement.tbcashflow' or   PageUrl='home.homeengagement.trailbalances' or  pageurl='Prje' or  PageUrl='Paje' or pageurl='Cje' or PageUrl='Trailbalances') and GroupTypeId=@engagementId

update Common.Comment set FeatureId=(select id from Audit.AuditCompanyMenuMaster where EngagementId=@engagementId and Heading=GroupType) where (pageurl='home.homeengagement.tbcashflow' or   PageUrl='home.homeengagement.trailbalances' or  pageurl='Prje' or  PageUrl='Paje' or pageurl='Cje' or PageUrl='Trailbalances') and GroupTypeId=@engagementId

--update acm set acm.TypeId=wp.id from  Audit.WPSetup as wp join Audit.AuditCompanyMenuMaster acm on wp.CompanyId=acm.CompanyId  
-- where acm.CompanyId=682 and wp.CompanyId=682  and 
-- wp.Code=acm.Heading

--select * from Audit.Note where EngagementId=@engagementId and FeatureName !='Foreign Exchange' and FeatureName !='Analytical review' and FeatureName!='Notes' and FeatureName !='Income statement' and FeatureName!='Balance Sheet' and FeatureName!='Changes in Equity'

update  Audit.Note set FeatureId=(select Id from Audit.WPSetup where CompanyId=@CompanyID and Code=FeatureName) where EngagementId=@engagementId and FeatureName !='Foreign Exchange' and FeatureName !='Analytical review' and FeatureName!='Notes' and FeatureName !='Income statement' and FeatureName!='Balance Sheet' and FeatureName!='Changes in Equity'

--select * from audit.WPSetup where id='945A754C-E6D3-450B-8BA5-64D7F9710FF4'
--select * from Audit.Note where FeatureName ='Foreign Exchange' and EngagementId=@engagementId

update Audit.Note set FeatureId=(select id from Audit.AuditCompanyMenuMaster where EngagementId =@engagementId and Heading='Foreign Exchange') where FeatureName ='Foreign Exchange' and EngagementId=@engagementId
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

END
GO
