USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[Sp_Audit_CopyWorkProgram]    Script Date: 16-12-2024 9.20.11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-------------==============Sp_Audit_CopyWorkProgram=======================---------------------------

create Procedure [dbo].[Sp_Audit_CopyWorkProgram](@companyId bigint,@OldauditManualId uniqueidentifier,@OldengagementTypeId uniqueidentifier,@auditManualId uniqueidentifier,@engagementTypeId uniqueidentifier,@wpMasterId uniqueidentifier)
As begin 

  BEGIN TRANSACTION
  BEGIN TRY

		---------- WPSetUp -------------------------------
    
      Begin       
          INSERT INTO [Audit].[WPSetup] (Id,CompanyId,Code,[Description],Remarks,RecOrder,UserCreated,CreatedDate,ModifiedBy,ModifiedDate,[Version],   [Status],ShortCode,IsPartner,ReferenceId,EngagementId,AuditManualId,EngagementTypeId,WpsetupMasterId)      
             select NewID(),@companyId as CompanyId,[Code],[Description],[Remarks],[RecOrder],[UserCreated],GETUTCDATE() as [CreatedDate],NULL as    [ModifiedBy],NULL as [ModifiedDate],[Version],[Status],[ShortCode],0,ReferenceId,EngagementId,@auditManualId,@engagementTypeId,@wpMasterId
             From [Audit].[WPSetup] Where CompanyId = @companyId AND Status=1 AND EngagementId IS NULL and AuditManualId=@OldauditManualId and EngagementTypeId=@OldengagementTypeId;      
             
          declare @ID uniqueidentifier,@WPSetupId uniqueidentifier,@TickMark_Id uniqueidentifier;      
          DECLARE WPSETUPCSR CURSOR FOR SELECT ID,WPSetupId,TickMarkId FROM AUDIT.WPSETUPTICKMARK WHERE WPSetupId in(select Id from Audit.WPSetup where CompanyId = @companyId AND Status=1 AND EngagementId IS NULL and AuditManualId=@OldauditManualId and EngagementTypeId=@OldengagementTypeId)      
          OPEN WPSETUPCSR;      
          FETCH NEXT FROM WPSETUPCSR INTO @ID,@WPSetupId,@TickMark_Id      
          WHILE (@@FETCH_STATUS=0)      
          BEGIN      
          INSERT INTO AUDIT.WPSETUPTICKMARK (ID,WPSETUPID,TICKMARKID,STATUS)      
          SELECT NEWID(),(select id from Audit.WPSetup where ReferenceId=@WPSetupId and CompanyId=@companyId and EngagementId is null),(select Id from audit.TickMarkSetup where    companyid=@companyId and referenceid=@TickMark_Id and EngagementId is null),STATUS FROM  AUDIT.WPSETUPTICKMARK WHERE Id=@ID 
      
          FETCH NEXT FROM WPSETUPCSR INTO @ID,@WPSetupId,@TickMark_Id      
          END      
          CLOSE WPSETUPCSR      
          DEALLOCATE WPSETUPCSR      
         
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
