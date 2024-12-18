USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[Sp_Audit_ReportingSeedData]    Script Date: 16-12-2024 9.20.11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
 

-----------------
CREATE Procedure [dbo].[Sp_Audit_ReportingSeedData](@companyId bigint,@engagemenId uniqueidentifier,@fsTemplateId uniqueidentifier,@screenName nvarchar(100))
As begin 
BEGIN TRANSACTION
BEGIN TRY

DECLARE @PARTNER_COMPANYID BIGINT      
Set @PARTNER_COMPANYID=(select AccountingFirmId from Common.Company where Id=@CompanyId)

	IF @PARTNER_COMPANYID IS NULL 
	BEGIN 
		SET @PARTNER_COMPANYID=@CompanyId
	END

	IF @screenName is null
		BEGIN
			IF NOT EXISTS (select * from Audit.Template  where CompanyId=@companyId AND EngagementId=@engagemenId AND FSTemplateId=@fsTemplateId)
			Begin 
				Insert  Into Audit.Template (Id,Name,Code,CompanyId,EngagementId,FromEmailId,CcEmailIds,BccEmailIds,ToEmailId,Subject,TempletContent,Remarks,UserCreated,CreatedDate,ModifiedBy,ModifiedDate,RecOrder,Version,Status,ScreenName,GenericTemplateId,IsTemplate,IsMaster,IsRollForward,AuditCompanyId,EngagementType,EngagementName,EffectiveFrom,EffectiveTo,SectionName,ReferenceId,IsFinancialsTemplate,FSTemplateId,PartnerId)
				select NewID(),Name,Code,@companyId,@engagemenId,FromEmailId,CcEmailIds,BccEmailIds,ToEmailId,Subject,TempletContent,Remarks,[UserCreated],GETUTCDATE() as [CreatedDate],NULL as    [ModifiedBy],NULL as [ModifiedDate],RecOrder,Version,Status,ScreenName,GenericTemplateId,IsTemplate,IsMaster,IsRollForward,AuditCompanyId,EngagementType,EngagementName,EffectiveFrom,EffectiveTo,SectionName,ReferenceId,IsFinancialsTemplate,FSTemplateId,Id
				From [Audit].Template Where CompanyId = @PARTNER_COMPANYID AND FSTemplateId =@fsTemplateId  AND Status=1 AND EngagementId IS NULL AND ScreenName in('Directors Statement','Auditors');
			End
		End
	ELSE
		BEGIN
			SET @fsTemplateId=(select FSTemplateId from audit.AuditCompanyEngagement where Id=@engagemenId)
			--IF NOT EXISTS (select * from Audit.Template  where CompanyId=@companyId AND EngagementId=@engagemenId AND FSTemplateId=@fsTemplateId AND ScreenName=@screenName)
			Begin 
				Insert  Into Audit.Template (Id,Name,Code,CompanyId,EngagementId,FromEmailId,CcEmailIds,BccEmailIds,ToEmailId,Subject,TempletContent,Remarks,UserCreated,CreatedDate,ModifiedBy,ModifiedDate,RecOrder,Version,Status,ScreenName,GenericTemplateId,IsTemplate,IsMaster,IsRollForward,AuditCompanyId,EngagementType,EngagementName,EffectiveFrom,EffectiveTo,SectionName,ReferenceId,IsFinancialsTemplate,FSTemplateId,PartnerId)
				select NewID(),Name,Code,@companyId,@engagemenId,FromEmailId,CcEmailIds,BccEmailIds,ToEmailId,Subject,TempletContent,Remarks,[UserCreated],GETUTCDATE() as [CreatedDate],NULL as    [ModifiedBy],NULL as [ModifiedDate],RecOrder,Version,Status,ScreenName,GenericTemplateId,IsTemplate,IsMaster,IsRollForward,AuditCompanyId,EngagementType,EngagementName,EffectiveFrom,EffectiveTo,SectionName,ReferenceId,IsFinancialsTemplate,FSTemplateId,Id
				From [Audit].Template Where CompanyId = @PARTNER_COMPANYID AND FSTemplateId =@fsTemplateId  AND Status=1 AND EngagementId IS NULL AND ScreenName=@screenName AND id not in (select PartnerId from audit .Template where EngagementId=@engagemenId and ScreenName=@screenName and PartnerId is not null);
			End
		End

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
