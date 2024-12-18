USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[FW_SEED_DATA_CC]    Script Date: 16-12-2024 9.20.10 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   PROC [dbo].[FW_SEED_DATA_CC] (@UNIQUE_COMPANY_ID bigint, @NEW_COMPANY_ID bigint, @UNIQUE_ID uniqueidentifier)
AS
BEGIN
BEGIN TRY
--BEGIN TRANSACTION
DECLARE @IN_PROGRESS nvarchar(20) = 'In-Progress'
DECLARE @COMPLETED nvarchar(20) = 'Completed'
DECLARE @MODULE_NAME varchar(20) = 'Client Cursor' 
DECLARE @MODULE_ID bigint =  (select Id from Common.ModuleMaster where Name = @MODULE_NAME)
--================================================================
--ControlCodeCategory, ControlCode and ControlCodeCategoryModule  Insertion
	DECLARE @ControlCode_Unique_Identifier uniqueidentifier = NEWID()
	INSERT INTO Common.DetailLog values(@ControlCode_Unique_Identifier, @UNIQUE_Id , 'FW_SEED_DATA_CC - ControlCodes Execution Started', GETUTCDATE() , '5.1' , NULL , @IN_PROGRESS )

		EXEC [dbo].[FW_CONTROL_CODE_INSERTION] @UNIQUE_COMPANY_ID, @NEW_COMPANY_ID, @MODULE_NAME

	Update Common.DetailLog set Status = @COMPLETED where Id = @ControlCode_Unique_Identifier
 --============================ ModuleDetail Insertion ===================================
	DECLARE @ModuleDetail_Unique_Identifier uniqueidentifier = NEWID()
	INSERT INTO Common.DetailLog values(@ModuleDetail_Unique_Identifier, @UNIQUE_Id , 'FW_SEED_DATA_CC - ModuleDetail Execution Started', GETUTCDATE() , '5.2' , NULL , @IN_PROGRESS )

		EXEC [dbo].[FW_MODULE_DETAIL_INSERTION] @UNIQUE_COMPANY_ID, @NEW_COMPANY_ID, @MODULE_ID

	Update Common.DetailLog set Status = @COMPLETED where Id = @ModuleDetail_Unique_Identifier
 --====================== InitialCursor Setup Insertion ==========================================
	DECLARE @InitialCursorSetup_Unique_Identifier uniqueidentifier = NEWID()
	INSERT INTO Common.DetailLog values(@InitialCursorSetup_Unique_Identifier, @UNIQUE_Id , 'FW_SEED_DATA_CC - InitialCursorSetup Execution Started', GETUTCDATE() , '5.3' , NULL , @IN_PROGRESS )

		EXEC [dbo].[FW_INITIAL_CURSOR_SETUP_SEED] @UNIQUE_COMPANY_ID, @NEW_COMPANY_ID, @MODULE_ID

	Update Common.DetailLog set Status = @COMPLETED where Id = @InitialCursorSetup_Unique_Identifier
 --============ Auto number insertion===============================================================
	DECLARE @autoNumber_Unique_Identifier uniqueidentifier = NEWID()
	INSERT INTO Common.DetailLog values(@autoNumber_Unique_Identifier, @UNIQUE_Id , 'FW_SEED_DATA_CC - AutoNumber Execution Started', GETUTCDATE() , '5.4' , NULL , @IN_PROGRESS )

		EXEC [dbo].[FW_AUTO_NUMBER_SEED_DATA] @UNIQUE_COMPANY_ID, @NEW_COMPANY_ID, @MODULE_ID

	Update Common.DetailLog set Status = @COMPLETED where Id = @autoNumber_Unique_Identifier
	--================================ GridMetaData =============================================
	DECLARE @gridmetadata_Unique_Identifier uniqueidentifier = NEWID()
	INSERT INTO Common.DetailLog values(@gridmetadata_Unique_Identifier, @UNIQUE_Id , 'FW_SEED_DATA_CC - GridMetaData Execution Started', GETUTCDATE() , '5.5' , NULL , @IN_PROGRESS )

		EXEC [dbo].[FW_GRIDMETADATA_SEED_INSERTION] @UNIQUE_COMPANY_ID, @NEW_COMPANY_ID, @MODULE_ID

	Update Common.DetailLog set Status = @COMPLETED where Id = @gridmetadata_Unique_Identifier
	--=================================================================================

 --- Templates
 DECLARE @genericTemplate_Unique_Identifier uniqueidentifier = NEWID()
	INSERT INTO Common.DetailLog values(@genericTemplate_Unique_Identifier, @UNIQUE_Id , 'FW_SEED_DATA_CC - Generic Template Execution Started', GETUTCDATE() , '5.6' , NULL , @IN_PROGRESS )
Declare @GenericTemplate_Cnt int
select 	@GenericTemplate_Cnt=Count(*) from Common.GenericTemplate where companyid=@NEW_COMPANY_ID and CursorName= @MODULE_NAME	
If @GenericTemplate_Cnt =0
BEGIN
	--------------------------------Generic Template--------------------------------------

	declare @AuditFirmId bigint= (select AccountingFirmId from Common.Company where Id=@NEW_COMPANY_ID);
 if @AuditFirmId is null
  BEGIN
 INSERT INTO Common.GenericTemplate ([Id],[CompanyId],[TemplateTypeId],[Name],[Code],[TempletContent],[IsSystem],[IsFooterExist],[IsHeaderExist],[RecOrder],[Remarks],[UserCreated],[CreatedDate],[ModifiedBy],[ModifiedDate],[Version],[Status],[IsPartnerTemplate],[CursorName],[TemplateType])
       SELECT  NEWID(),@NEW_COMPANY_ID,[TemplateTypeId],[Name],[Code],[TempletContent],[IsSystem],[IsFooterExist],[IsHeaderExist],[RecOrder],[Remarks],[UserCreated],GETUTCDATE(),null,null,[Version],1,[IsPartnerTemplate],[CursorName],[TemplateType]
  FROM Common.GenericTemplate WHERE CompanyId=@UNIQUE_COMPANY_ID and CursorName='Client Cursor'
  END
else
  BEGIN
       INSERT INTO Common.GenericTemplate ([Id],[CompanyId],[TemplateTypeId],[Name],[Code],[TempletContent],[IsSystem],[IsFooterExist],[IsHeaderExist],[RecOrder],[Remarks],[UserCreated],[CreatedDate],[ModifiedBy],[ModifiedDate],[Version],[Status],[IsPartnerTemplate],[CursorName],[TemplateType])
            SELECT  NEWID(),@NEW_COMPANY_ID,[TemplateTypeId],[Name],[Code],[TempletContent],[IsSystem],[IsFooterExist],[IsHeaderExist],[RecOrder],[Remarks],[UserCreated],GETUTCDATE(),null,null,[Version],1,[IsPartnerTemplate],[CursorName],[TemplateType]
       FROM Common.GenericTemplate WHERE CompanyId=@AuditFirmId and CursorName='Client Cursor'
 END
 End
 Update Common.DetailLog set Status = @COMPLETED where Id = @genericTemplate_Unique_Identifier
 --Notification seed data



 DECLARE @notificationSettings_Unique_Identifier uniqueidentifier = NEWID()
	INSERT INTO Common.DetailLog values(@notificationSettings_Unique_Identifier, @UNIQUE_Id , 'FW_SEED_DATA_CC - Notification Settings Execution Started', GETUTCDATE() , '5.7' , NULL , @IN_PROGRESS )
BEGIN
	If Not Exists (Select Id From Notification.NotificationSettings WHere CompanyId=@NEW_COMPANY_ID And CursorName= @MODULE_NAME)
	BEGIN
		Insert Into Notification.NotificationSettings (Id,CompanyId,CompanyUserId,CursorName,ScreenName,ScreenAction,Type,NotificationDescription,EmailDescription,FeatureName,
														Recipient,OtherRecipients,ReminderPeriod,ReminderPeriodDuration,IsOn,CreatedDate,ModifiedBy,ModifiedDate,UserCreated,NotificationTemplate,
														NotificationSubject,Status,Recorder,IsHidden,IsPersonalSetting,IsSelfNotification,EmailSubject,OtherEmailRecipient,EmailBodyTemplate)

		Select NEWID(),@NEW_COMPANY_ID,Null as CompanyUserId,CursorName,ScreenName,ScreenAction,Type,NotificationDescription,EmailDescription,FeatureName,Recipient,OtherRecipients,ReminderPeriod,ReminderPeriodDuration,
				IsOn,CreatedDate,null,null,UserCreated,NotificationTemplate,NotificationSubject,Status,Recorder,IsHidden,IsPersonalSetting,IsSelfNotification,EmailSubject,OtherEmailRecipient,EmailBodyTemplate 
		From Notification.NotificationSettings Where CompanyId=@UNIQUE_COMPANY_ID And CursorName= @MODULE_NAME
	END
	END
	Update Common.DetailLog set Status = @COMPLETED where Id = @notificationSettings_Unique_Identifier
	--COMMIT TRANSACTION
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
  --ROLLBACK TRANSACTION 
END CATCH
END

GO
