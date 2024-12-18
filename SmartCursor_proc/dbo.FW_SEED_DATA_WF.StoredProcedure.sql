USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[FW_SEED_DATA_WF]    Script Date: 16-12-2024 9.20.10 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   PROC [dbo].[FW_SEED_DATA_WF] (@UNIQUE_COMPANY_ID bigint, @NEW_COMPANY_ID bigint, @UNIQUE_ID uniqueidentifier)
AS
BEGIN
BEGIN TRY
DECLARE @IN_PROGRESS nvarchar(20) = 'In-Progress'
DECLARE @COMPLETED nvarchar(20) = 'Completed'
--BEGIN TRANSACTION
DECLARE @MODULE_NAME varchar(20) = 'Workflow Cursor' 
DECLARE @MODULE_ID bigint =  (select Id from Common.ModuleMaster where Name = @MODULE_NAME)
--================================================================
--ControlCodeCategory, ControlCode and ControlCodeCategoryModule  Insertion
DECLARE @ControlCode_Unique_Identifier uniqueidentifier = NEWID()
INSERT INTO Common.DetailLog values(@ControlCode_Unique_Identifier, @UNIQUE_Id , 'FW_SEED_DATA_WF - ControlCodes Execution Started', GETUTCDATE() , '8.1' , NULL , @IN_PROGRESS )

 EXEC [dbo].[FW_CONTROL_CODE_INSERTION] @UNIQUE_COMPANY_ID, @NEW_COMPANY_ID, @MODULE_NAME

  Update Common.DetailLog set Status = @COMPLETED where Id = @ControlCode_Unique_Identifier
 --===============================================================
 --ModuleDetail Insertion
 DECLARE @ModuleDetail_Unique_Identifier uniqueidentifier = NEWID()
 INSERT INTO Common.DetailLog values(@ModuleDetail_Unique_Identifier, @UNIQUE_Id , 'FW_SEED_DATA_WF - ModuleDetail Execution Started', GETUTCDATE() , '8.2' , NULL , @IN_PROGRESS )

 EXEC [dbo].[FW_MODULE_DETAIL_INSERTION] @UNIQUE_COMPANY_ID, @NEW_COMPANY_ID, @MODULE_ID

 Update Common.DetailLog set Status = @COMPLETED where Id = @ModuleDetail_Unique_Identifier
 --================================================================
 --InitialCursor Setup Insertion
  DECLARE @InitialCursorSetup_Unique_Identifier uniqueidentifier = NEWID()
 INSERT INTO Common.DetailLog values(@InitialCursorSetup_Unique_Identifier, @UNIQUE_Id , 'FW_SEED_DATA_WF - InitialCursorSetup Execution Started', GETUTCDATE() , '8.3' , NULL , @IN_PROGRESS )

 EXEC [dbo].[FW_INITIAL_CURSOR_SETUP_SEED] @UNIQUE_COMPANY_ID, @NEW_COMPANY_ID, @MODULE_ID

 Update Common.DetailLog set Status = @COMPLETED where Id = @InitialCursorSetup_Unique_Identifier
--============ Auto number insertion===============================================================
	DECLARE @autoNumber_Unique_Identifier uniqueidentifier = NEWID()
	 INSERT INTO Common.DetailLog values(@autoNumber_Unique_Identifier, @UNIQUE_Id , 'FW_SEED_DATA_WF - AutoNumber Execution Started', GETUTCDATE() , '8.4' , NULL , @IN_PROGRESS )

	EXEC [dbo].[FW_AUTO_NUMBER_SEED_DATA] @UNIQUE_COMPANY_ID, @NEW_COMPANY_ID, @MODULE_ID

	Update Common.DetailLog set Status = @COMPLETED where Id = @autoNumber_Unique_Identifier
	--========================================================================================
		DECLARE @gridmetadata_Unique_Identifier uniqueidentifier = NEWID()
		INSERT INTO Common.DetailLog values(@gridmetadata_Unique_Identifier, @UNIQUE_Id , 'FW_SEED_DATA_WF - GridMetaData Execution Started', GETUTCDATE() , '8.5' , NULL , @IN_PROGRESS )

		EXEC [dbo].[FW_GRIDMETADATA_SEED_INSERTION] @UNIQUE_COMPANY_ID, @NEW_COMPANY_ID, @MODULE_ID

		 Update Common.DetailLog set Status = @COMPLETED where Id = @gridmetadata_Unique_Identifier
		--====================================================================================
		DECLARE @genericTemplate_Unique_Identifier uniqueidentifier = NEWID()
		INSERT INTO Common.DetailLog values(@genericTemplate_Unique_Identifier, @UNIQUE_Id , 'FW_SEED_DATA_WF - GenericTemplate Execution Started', GETUTCDATE() , '8.6' , NULL , @IN_PROGRESS )

	 Declare @GenericTemplate_Cnt int
	select 	@GenericTemplate_Cnt=Count(*) from Common.GenericTemplate where companyid=@NEW_COMPANY_ID and CursorName=@MODULE_NAME
	If @GenericTemplate_Cnt =0
	BEGIN
	declare @AuditFirmId bigint= (select AccountingFirmId from Common.Company where Id=@NEW_COMPANY_ID);
	 if @AuditFirmId is null
	  BEGIN
	 INSERT INTO Common.GenericTemplate ([Id],[CompanyId],[TemplateTypeId],[Name],[Code],[TempletContent],[IsSystem],[IsFooterExist],[IsHeaderExist],[RecOrder],[Remarks],[UserCreated],[CreatedDate],[ModifiedBy],[ModifiedDate],[Version],[Status],[Category],[IsPartnerTemplate],[CursorName],[TemplateType])
		   SELECT  NEWID(),@NEW_COMPANY_ID,[TemplateTypeId],[Name],[Code],[TempletContent],[IsSystem],[IsFooterExist],[IsHeaderExist],[RecOrder],[Remarks],[UserCreated],GETUTCDATE(),null,null,[Version],1,[Category],[IsPartnerTemplate],[CursorName],[TemplateType]
	  FROM Common.GenericTemplate WHERE CompanyId=@UNIQUE_COMPANY_ID and CursorName=@MODULE_NAME
	  END
	else
	  BEGIN
		   INSERT INTO Common.GenericTemplate ([Id],[CompanyId],[TemplateTypeId],[Name],[Code],[TempletContent],[IsSystem],[IsFooterExist],[IsHeaderExist],[RecOrder],[Remarks],[UserCreated],[CreatedDate],[ModifiedBy],[ModifiedDate],[Version],[Status],[Category],[IsPartnerTemplate],[CursorName],[TemplateType])
				SELECT  NEWID(),@NEW_COMPANY_ID,[TemplateTypeId],[Name],[Code],[TempletContent],[IsSystem],[IsFooterExist],[IsHeaderExist],[RecOrder],[Remarks],[UserCreated],GETUTCDATE(),null,null,[Version],1,[Category],[IsPartnerTemplate],[CursorName],[TemplateType]
		   FROM Common.GenericTemplate WHERE CompanyId=@AuditFirmId and   CursorName=@MODULE_NAME
	 END
	 End

 Update Common.DetailLog set Status = @COMPLETED where Id = @genericTemplate_Unique_Identifier

 ----WF - setting Seed data
 DECLARE @feeRecoverySetting_Unique_Identifier uniqueidentifier = NEWID()
		INSERT INTO Common.DetailLog values(@feeRecoverySetting_Unique_Identifier, @UNIQUE_Id , 'FW_SEED_DATA_WF - FeeRecoverySetting Execution Started', GETUTCDATE() , '8.7' , NULL , @IN_PROGRESS )

If not Exists(select * from Common.FeeRecoverySetting where CompanyId=@NEW_COMPANY_ID)
 Begin
      Insert into Common.FeeRecoverySetting (Id,CompanyId,ProgressMin,ProgressMax,UserCreated,CreateDate,ModifiedBy,ModifiedDate,Status,Remarks)
      values(NEWID(),@NEW_COMPANY_ID,40,59,'System',GETUTCDATE(),null,null,1,null)
End

 Update Common.DetailLog set Status = @COMPLETED where Id = @feeRecoverySetting_Unique_Identifier

 -----NOTIFICATION SETTINGS

 DECLARE @notificationSettings_Unique_Identifier uniqueidentifier = NEWID()
		INSERT INTO Common.DetailLog values(@notificationSettings_Unique_Identifier, @UNIQUE_Id , 'FW_SEED_DATA_WF - NotificationSettings Execution Started', GETUTCDATE() , '8.8' , NULL , @IN_PROGRESS )
 Declare @Temp Table (S_no Int Identity(1,1),CompUserId Bigint)
Declare @Count Int
Declare @Total_Count Int
Declare @CompanyUserId BigInt
Set @Count=1
Begin
If Not Exists (Select Id From Notification.NotificationSettings WHere CompanyId=@NEW_COMPANY_ID And CursorName= 'Workflow Cursor')
Begin
Insert Into Notification.NotificationSettings (Id,CompanyId,CompanyUserId,CursorName,ScreenName,ScreenAction,Type,NotificationDescription,EmailDescription,FeatureName,
Recipient,OtherRecipients,ReminderPeriod,ReminderPeriodDuration,IsOn,CreatedDate,ModifiedBy,ModifiedDate,UserCreated,NotificationTemplate,
NotificationSubject,Status,Recorder,IsHidden,IsPersonalSetting,IsSelfNotification,EmailSubject,OtherEmailRecipient,EmailBodyTemplate)

Select NEWID(),@NEW_COMPANY_ID,Null as CompanyUserId,CursorName,ScreenName,ScreenAction,Type,NotificationDescription,EmailDescription,FeatureName,Recipient,OtherRecipients,ReminderPeriod,ReminderPeriodDuration,
IsOn,CreatedDate,null,null,UserCreated,NotificationTemplate,NotificationSubject,Status,Recorder,IsHidden,IsPersonalSetting,IsSelfNotification,EmailSubject,OtherEmailRecipient,EmailBodyTemplate
From Notification.NotificationSettings Where CompanyId=@UNIQUE_COMPANY_ID And CursorName= 'Workflow Cursor'
End

If Not Exists (Select Id From Notification.NotificationSettings WHere CompanyId=@NEW_COMPANY_ID And CursorName = 'Common')
Begin
Insert Into Notification.NotificationSettings (Id,CompanyId,CompanyUserId,CursorName,ScreenName,ScreenAction,Type,NotificationDescription,EmailDescription,FeatureName,
Recipient,OtherRecipients,ReminderPeriod,ReminderPeriodDuration,IsOn,CreatedDate,ModifiedBy,ModifiedDate,UserCreated,NotificationTemplate,
NotificationSubject,Status,Recorder,IsHidden,IsPersonalSetting,IsSelfNotification,EmailSubject,OtherEmailRecipient,EmailBodyTemplate)

Select NEWID(),@NEW_COMPANY_ID,Null as CompanyUserId,CursorName,ScreenName,ScreenAction,Type,NotificationDescription,EmailDescription,FeatureName,Recipient,OtherRecipients,ReminderPeriod,ReminderPeriodDuration,
IsOn,CreatedDate,null,null,UserCreated,NotificationTemplate,NotificationSubject,Status,Recorder,IsHidden,IsPersonalSetting,IsSelfNotification,EmailSubject,OtherEmailRecipient,EmailBodyTemplate
From Notification.NotificationSettings Where CompanyId=@UNIQUE_COMPANY_ID And CursorName = 'Common'
End


Insert into @Temp (CompUserId)
Select Id From Common.CompanyUser Where CompanyId=@NEW_COMPANY_ID

Select @Total_Count=Count(*) From @Temp
While @Count<=@Total_Count
Begin
Select @CompanyUserId=CompUserId From @Temp Where S_no=@Count
If Not Exists (Select Id From Notification.NotificationSettings Where CompanyId=@NEW_COMPANY_ID ANd CompanyUserId=@CompanyUserId And CursorName = 'Workflow Cursor')
Begin
Insert Into Notification.NotificationSettings (Id,CompanyId,CompanyUserId,CursorName,ScreenName,ScreenAction,Type,NotificationDescription,EmailDescription,FeatureName,
Recipient,OtherRecipients,ReminderPeriod,ReminderPeriodDuration,IsOn,CreatedDate,ModifiedBy,ModifiedDate,UserCreated,NotificationTemplate,
NotificationSubject,Status,Recorder,IsHidden,IsPersonalSetting,IsSelfNotification,EmailSubject,OtherEmailRecipient,EmailBodyTemplate)

Select NEWID(),@NEW_COMPANY_ID,@CompanyUserId,CursorName,ScreenName,ScreenAction,Type,NotificationDescription,EmailDescription,FeatureName,Recipient,OtherRecipients,ReminderPeriod,ReminderPeriodDuration,
IsOn,CreatedDate,null,null,UserCreated,NotificationTemplate,NotificationSubject,Status,Recorder,IsHidden,IsPersonalSetting,IsSelfNotification,EmailSubject,OtherEmailRecipient,EmailBodyTemplate
From Notification.NotificationSettings Where CompanyId=@UNIQUE_COMPANY_ID And CursorName = 'Workflow Cursor'
End

Begin
Select @CompanyUserId=CompUserId From @Temp Where S_no=@Count
If Not Exists (Select Id From Notification.NotificationSettings Where CompanyId=@NEW_COMPANY_ID ANd CompanyUserId=@CompanyUserId And CursorName = 'Common')
Begin
Insert Into Notification.NotificationSettings (Id,CompanyId,CompanyUserId,CursorName,ScreenName,ScreenAction,Type,NotificationDescription,EmailDescription,FeatureName,
Recipient,OtherRecipients,ReminderPeriod,ReminderPeriodDuration,IsOn,CreatedDate,ModifiedBy,ModifiedDate,UserCreated,NotificationTemplate,
NotificationSubject,Status,Recorder,IsHidden,IsPersonalSetting,IsSelfNotification,EmailSubject,OtherEmailRecipient,EmailBodyTemplate)

Select NEWID(),@NEW_COMPANY_ID,@CompanyUserId,CursorName,ScreenName,ScreenAction,Type,NotificationDescription,EmailDescription,FeatureName,Recipient,OtherRecipients,ReminderPeriod,ReminderPeriodDuration,
IsOn,CreatedDate,null,null,UserCreated,NotificationTemplate,NotificationSubject,Status,Recorder,IsHidden,IsPersonalSetting,IsSelfNotification,EmailSubject,OtherEmailRecipient,EmailBodyTemplate
From Notification.NotificationSettings Where CompanyId=@UNIQUE_COMPANY_ID And CursorName = 'Common'
End
End
Set @Count=@Count+1
End
End
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
