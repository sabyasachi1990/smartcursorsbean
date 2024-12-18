USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[Sp_Audit_EngagementSeedDataWorkProgram]    Script Date: 16-12-2024 9.20.11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE Procedure [dbo].[Sp_Audit_EngagementSeedDataWorkProgram](@companyId bigint,@engagemenId uniqueidentifier,@auditManualId uniqueidentifier,@engagementTypeId uniqueidentifier)
As begin 

  BEGIN TRANSACTION
  BEGIN TRY
          DECLARE @EngagementType Nvarchar(100);
		  Set @EngagementType=(select EngagementType from Audit.Auditcompanyengagement where Id=@engagemenId);
          DECLARE @PARTNER_COMPANYID BIGINT      
          Set @PARTNER_COMPANYID=(select AccountingFirmId from Common.Company where Id=@CompanyId)
	IF @PARTNER_COMPANYID IS NULL 
	BEGIN 
			SET @PARTNER_COMPANYID=@CompanyId
	END

	---------- Tick Mark SetUp--------------
   IF @PARTNER_COMPANYID IS NOT NULL      
    Begin       
      INSERT INTO [Audit].[TickMarkSetup] (Id,CompanyId,Code,[Description],IsSystem,Remarks,RecOrder,UserCreated,CreatedDate,ModifiedBy,ModifiedDate,[Version],   [Status],IsPlanning,IsCompletion,IsPartner,ReferenceId,EngagementId)      
      select NEWID(),@companyId as CompanyId,[Code],[Description],[IsSystem],[Remarks],[RecOrder],[UserCreated],GETUTCDATE() as [CreatedDate],NULL AS    [ModifiedBy],NULL AS [ModifiedDate],[Version],[Status],[IsPlanning],[IsCompletion],0,Id,@engagemenId      
      From [Audit].[TickMarkSetup] Where CompanyId = @PARTNER_COMPANYID AND Status=1 AND EngagementId IS NULL;      
    End   

	insert into Audit.EngagementHistory (Id,EngagementId,SeedDataType,SeedDataStatus,Recorder)  Values (NewId(),@engagemenId,'TickMarkInserted','Success',3)

   IF @EngagementType!='Compilation'
   Begin
	---------- WPSetUp -------------------------------
   IF @PARTNER_COMPANYID IS Not NULL      
      Begin       
          INSERT INTO [Audit].[WPSetup] (Id,CompanyId,Code,[Description],Remarks,RecOrder,UserCreated,CreatedDate,ModifiedBy,ModifiedDate,[Version],   [Status],ShortCode,IsPartner,ReferenceId,EngagementId,AuditManualId,EngagementTypeId)      
             select NewID(),@companyId as CompanyId,[Code],[Description],[Remarks],[RecOrder],[UserCreated],GETUTCDATE() as [CreatedDate],NULL as    [ModifiedBy],NULL as [ModifiedDate],[Version],[Status],[ShortCode],0,Id,@engagemenId,@auditManualId,@engagementTypeId
             From [Audit].[WPSetup] Where CompanyId = @PARTNER_COMPANYID AND Status=1 AND EngagementId IS NULL and AuditManualId=@auditManualId and EngagementTypeId=@engagementTypeId;      
             
          declare @ID uniqueidentifier,@WPSetupId uniqueidentifier,@TickMark_Id uniqueidentifier;      
          DECLARE WPSETUPCSR CURSOR FOR SELECT ID,WPSetupId,TickMarkId FROM AUDIT.WPSETUPTICKMARK WHERE WPSetupId in(select Id from Audit.WPSetup where    CompanyId=@PARTNER_COMPANYID and EngagementId is null)      
          OPEN WPSETUPCSR;      
          FETCH NEXT FROM WPSETUPCSR INTO @ID,@WPSetupId,@TickMark_Id      
          WHILE (@@FETCH_STATUS=0)      
          BEGIN      
          INSERT INTO AUDIT.WPSETUPTICKMARK (ID,WPSETUPID,TICKMARKID,STATUS)      
          SELECT NEWID(),(select id from Audit.WPSetup where ReferenceId=@WPSetupId and CompanyId=@companyId and EngagementId =@engagemenId),(select Id from audit.TickMarkSetup where    companyid=@companyId and referenceid=@TickMark_Id and EngagementId=@engagemenId),STATUS FROM  AUDIT.WPSETUPTICKMARK WHERE Id=@ID 
      
          FETCH NEXT FROM WPSETUPCSR INTO @ID,@WPSetupId,@TickMark_Id      
          END      
          CLOSE WPSETUPCSR      
          DEALLOCATE WPSETUPCSR      
         
       End      

	 Insert into Audit.EngagementHistory (Id,EngagementId,SeedDataType,SeedDataStatus,Recorder)  Values (NewId(),@engagemenId,'WPSetUpInserted','Success',4)
	 End
 --------------------------------------Roles -----------------------------
 
      Insert  Into Audit.Roles (Id,CompanyId,Role,UserCreated,CreatedDate,ModifiedBy,ModifiedDate,Status,IsSystem,IsStautory,IsCompilation,EngagementId,TypeId,EngagementTypeId,AuditManualId)
	  select NEWID(),@companyId,Role,UserCreated,CreatedDate,ModifiedBy,ModifiedDate,Status,IsSystem,IsStautory,IsCompilation,@engagemenId,Id,EngagementTypeId,AuditManualId   from Audit.Roles where CompanyId =@PARTNER_COMPANYID and auditManualid=@auditManualId and EngagementId is null and Status=1

     Insert into Audit.EngagementHistory (Id,EngagementId,SeedDataType,SeedDataStatus,Recorder)  Values (NewId(),@engagemenId,'RolesInserted','Success',5)
-----------------------
    
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
