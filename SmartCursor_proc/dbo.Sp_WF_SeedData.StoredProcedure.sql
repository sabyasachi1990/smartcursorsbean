USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[Sp_WF_SeedData]    Script Date: 16-12-2024 9.20.11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE Procedure [dbo].[Sp_WF_SeedData](@NEW_COMPANY_ID BIGINT,@UNIQUE_COMPANY_ID BIGINT,@STATUS BIGINT)
As
Declare @WorkWeekSetUp_Cnt int;
 DECLARE @CREATED_DATE DATETIME	 
    DECLARE @CONTROLCODECATEGORY_ID_MODULE_MASTER_ID BIGINT
	DECLARE @MODULE_MASTER_ID_CONTROLCODECATEGORY_ID BIGINT
	DECLARE @ACCOUNTYPE_ID_ID_TYPE_ID BIGINT
	DECLARE @ID_TYPE_ACCOUNTYPE_ID_ID BIGINT
--Select @WorkWeekSetUp_Cnt = count(*) from [Common].[WorkWeekSetUp] where CompanyId= @NEW_COMPANY_ID
--If @WorkWeekSetUp_Cnt=0
--Begin

--  ----------------------------------------------WorkWeekSetup-------------------------------------------------------------------------------------------------------------------------		
		
----INSERT INTO [Common].[WorkWeekSetUp](Id,CompanyId,WeekDay,AMFromTime,AMToTime,PMFromTime,PMToTime,WorkingHours,UserCreated,CreatedDate,ModifiedBy,ModifiedDate,Remarks,Status,IsWorkingDay,RecOrder)
----SELECT (NEWID()),@NEW_COMPANY_ID,WeekDay,AMFromTime,AMToTime,PMFromTime,PMToTime,WorkingHours,UserCreated,GETUTCDATE(),ModifiedBy,ModifiedDate,Remarks,Status,IsWorkingDay,RecOrder
----FROM [Common].[WorkWeekSetUp] WHERE COMPANYID=@UNIQUE_COMPANY_ID;	

--INSERT INTO [Common].[WorkWeekSetUp]([Id],[CompanyId],[WeekDay],[AMFromTime] ,[AMToTime],[PMFromTime],[PMToTime],[WorkingHours],[UserCreated],[CreatedDate],[ModifiedBy],[ModifiedDate],[Remarks],[Status],[IsWorkingDay],[RecOrder])
--VALUES(NEWID(),@NEW_COMPANY_ID,'Monday','09:00:00','13:00:00','14:00:00','18:00:00','08:00:00','madhu@kgtan.com',GETUTCDATE(),null,null,null,1,1,1)

--INSERT INTO [Common].[WorkWeekSetUp]([Id],[CompanyId],[WeekDay],[AMFromTime] ,[AMToTime],[PMFromTime],[PMToTime],[WorkingHours],[UserCreated],[CreatedDate],[ModifiedBy],[ModifiedDate],[Remarks],[Status],[IsWorkingDay],[RecOrder])
--VALUES(NEWID(),@NEW_COMPANY_ID,'Tuesday','09:00:00','13:00:00','14:00:00','18:00:00','08:00:00','madhu@kgtan.com',GETUTCDATE(),null,null,null,1,1,2)

--INSERT INTO [Common].[WorkWeekSetUp]([Id],[CompanyId],[WeekDay],[AMFromTime] ,[AMToTime],[PMFromTime],[PMToTime],[WorkingHours],[UserCreated],[CreatedDate],[ModifiedBy],[ModifiedDate],[Remarks],[Status],[IsWorkingDay],[RecOrder])
--VALUES(NEWID(),@NEW_COMPANY_ID,'Wednesday','09:00:00','13:00:00','14:00:00','18:00:00','08:00:00','madhu@kgtan.com',GETUTCDATE(),null,null,null,1,1,3)

--INSERT INTO [Common].[WorkWeekSetUp]([Id],[CompanyId],[WeekDay],[AMFromTime] ,[AMToTime],[PMFromTime],[PMToTime],[WorkingHours],[UserCreated],[CreatedDate],[ModifiedBy],[ModifiedDate],[Remarks],[Status],[IsWorkingDay],[RecOrder])
--VALUES(NEWID(),@NEW_COMPANY_ID,'Thursday','09:00:00','13:00:00','14:00:00','18:00:00','08:00:00','madhu@kgtan.com',GETUTCDATE(),null,null,null,1,1,4)

--INSERT INTO [Common].[WorkWeekSetUp]([Id],[CompanyId],[WeekDay],[AMFromTime] ,[AMToTime],[PMFromTime],[PMToTime],[WorkingHours],[UserCreated],[CreatedDate],[ModifiedBy],[ModifiedDate],[Remarks],[Status],[IsWorkingDay],[RecOrder])
--VALUES(NEWID(),@NEW_COMPANY_ID,'Friday','09:00:00','13:00:00','14:00:00','18:00:00','08:00:00','madhu@kgtan.com',GETUTCDATE(),null,null,null,1,1,5)

--DECLARE @IDs UNIQUEIDENTIFIER
--SET @IDs=NEWID()
--INSERT INTO [Common].[WorkWeekSetUp]([Id],[CompanyId],[WeekDay],[AMFromTime] ,[AMToTime],[PMFromTime],[PMToTime],[WorkingHours],[UserCreated],[CreatedDate],[ModifiedBy],[ModifiedDate],[Remarks],[Status],[IsWorkingDay],[RecOrder])
--VALUES(@IDs,@NEW_COMPANY_ID,'Saturday','00:00:00','00:00:00','00:00:00','00:00:00','00:00:00','madhu@kgtan.com',GETUTCDATE(),null,null,null,1,0,6)


--DECLARE @NewID UNIQUEIDENTIFIER
--SET  @NewID = NEWID()
--INSERT INTO [Common].[WorkWeekSetUp]([Id],[CompanyId],[WeekDay],[AMFromTime] ,[AMToTime],[PMFromTime],[PMToTime],[WorkingHours],[UserCreated],[CreatedDate],[ModifiedBy],[ModifiedDate],[Remarks],[Status],[IsWorkingDay],[RecOrder])
--VALUES(@NewID,@NEW_COMPANY_ID,'Sunday','00:00:00','00:00:00','00:00:00','00:00:00','00:00:00','madhu@kgtan.com',GETUTCDATE(),null,null,null,1,0,7)
--    End 
----- Template 

--- Templates

Declare @GenericTemplate_Cnt int
select 	@GenericTemplate_Cnt=Count(*) from Common.GenericTemplate where companyid=@NEW_COMPANY_ID and CursorName='WorkFlow Cursor'	
If @GenericTemplate_Cnt =0
Begin
	--------------------------------Generic Template--------------------------------------

--	INSERT INTO Common.GenericTemplate ([Id],[CompanyId],[TemplateTypeId],[Name],[Code],[TempletContent],[IsSystem],[IsFooterExist],[IsHeaderExist],[RecOrder],[Remarks],[UserCreated],[CreatedDate],[ModifiedBy],[ModifiedDate],[Version],[Status])
--       SELECT  NEWID(),@NEW_COMPANY_ID,[TemplateTypeId],[Name],[Code],[TempletContent],[IsSystem],[IsFooterExist],[IsHeaderExist],[RecOrder],[Remarks],[UserCreated],GETUTCDATE(),null,null,[Version],1
--FROM Common.GenericTemplate WHERE CompanyId=@UNIQUE_COMPANY_ID
	
	declare @AuditFirmId bigint= (select AccountingFirmId from Common.Company where Id=@NEW_COMPANY_ID);
 if @AuditFirmId is null
  BEGIN
 INSERT INTO Common.GenericTemplate ([Id],[CompanyId],[TemplateTypeId],[Name],[Code],[TempletContent],[IsSystem],[IsFooterExist],[IsHeaderExist],[RecOrder],[Remarks],[UserCreated],[CreatedDate],[ModifiedBy],[ModifiedDate],[Version],[Status],[IsPartnerTemplate],[CursorName],[TemplateType])
       SELECT  NEWID(),@NEW_COMPANY_ID,[TemplateTypeId],[Name],[Code],[TempletContent],[IsSystem],[IsFooterExist],[IsHeaderExist],[RecOrder],[Remarks],[UserCreated],GETUTCDATE(),null,null,[Version],1,[IsPartnerTemplate],[CursorName],[TemplateType]
  FROM Common.GenericTemplate WHERE CompanyId=@UNIQUE_COMPANY_ID and CursorName='WorkFlow Cursor'
  END
else
  BEGIN
       INSERT INTO Common.GenericTemplate ([Id],[CompanyId],[TemplateTypeId],[Name],[Code],[TempletContent],[IsSystem],[IsFooterExist],[IsHeaderExist],[RecOrder],[Remarks],[UserCreated],[CreatedDate],[ModifiedBy],[ModifiedDate],[Version],[Status],[IsPartnerTemplate],[CursorName],[TemplateType])
            SELECT  NEWID(),@NEW_COMPANY_ID,[TemplateTypeId],[Name],[Code],[TempletContent],[IsSystem],[IsFooterExist],[IsHeaderExist],[RecOrder],[Remarks],[UserCreated],GETUTCDATE(),null,null,[Version],1,[IsPartnerTemplate],[CursorName],[TemplateType]
       FROM Common.GenericTemplate WHERE CompanyId=@AuditFirmId and   CursorName='WorkFlow Cursor'
 END
 End

------ Template 
		--Type
--		 Declare @ControlCodeCategoryModule_Type_Cnt bigint
--	     Select @ControlCodeCategoryModule_Type_Cnt =count(*) from [Common].[ControlCodeCategoryModule] WHERE COMPANYID=@NEW_COMPANY_ID
--	     AND controlcategoryId  in (SELECT  ID FROM [Common].[ControlCodeCategory] WHERE COMPANYID=@NEW_COMPANY_ID AND CONTROLCODECATEGORYCODE='Time Log Item Type')--Change By Nagendra Type to Time Log Item Type Client Requirement
--	     If @ControlCodeCategoryModule_Type_Cnt =0
--		  Begin
--		  SET @CONTROLCODECATEGORY_ID_MODULE_MASTER_ID = (SELECT top 1 ID FROM [Common].[ControlCodeCategory] WHERE COMPANYID=@NEW_COMPANY_ID AND CONTROLCODECATEGORYCODE='Time Log Item Type')
--		  SET @MODULE_MASTER_ID_CONTROLCODECATEGORY_ID = (SELECT Id FROM [Common].[ModuleMaster]  WHERE COMPANYID=@UNIQUE_COMPANY_ID AND NAME='Workflow Cursor')
--		  INSERT INTO [Common].[ControlCodeCategoryModule] (Id, CompanyId, ControlCategoryId, ModuleMasterId) VALUES ((SELECT MAX(Id) + 1 FROM [Common].[ControlCodeCategoryModule]),
--		  @NEW_COMPANY_ID,@CONTROLCODECATEGORY_ID_MODULE_MASTER_ID,@MODULE_MASTER_ID_CONTROLCODECATEGORY_ID);
--		  End

--		  --Reason
--		 Declare @ControlCodeCategoryModule_Reason_Cnt bigint
--	     Select @ControlCodeCategoryModule_Reason_Cnt =count(*) from [Common].[ControlCodeCategoryModule] WHERE COMPANYID=@NEW_COMPANY_ID
--	     AND controlcategoryId  in (SELECT  ID FROM [Common].[ControlCodeCategory] WHERE COMPANYID=@NEW_COMPANY_ID AND CONTROLCODECATEGORYCODE='Reason')
--	     If @ControlCodeCategoryModule_Reason_Cnt =0
--		  Begin
--		 SET @CONTROLCODECATEGORY_ID_MODULE_MASTER_ID = (SELECT top 1 ID FROM [Common].[ControlCodeCategory] WHERE COMPANYID=@NEW_COMPANY_ID AND CONTROLCODECATEGORYCODE='Reason')
--		  SET @MODULE_MASTER_ID_CONTROLCODECATEGORY_ID = (SELECT Id FROM [Common].[ModuleMaster]  WHERE COMPANYID=@UNIQUE_COMPANY_ID AND NAME='Workflow Cursor')
--		  INSERT INTO [Common].[ControlCodeCategoryModule] (Id, CompanyId, ControlCategoryId, ModuleMasterId) VALUES ((SELECT MAX(Id) + 1 FROM [Common].[ControlCodeCategoryModule]),
--		  @NEW_COMPANY_ID,@CONTROLCODECATEGORY_ID_MODULE_MASTER_ID,@MODULE_MASTER_ID_CONTROLCODECATEGORY_ID);
--		  End


--		  ---Group By
--		 Declare @ControlCodeCategoryModule_Group_By_Cnt bigint
--	     Select @ControlCodeCategoryModule_Group_By_Cnt =count(*) from [Common].[ControlCodeCategoryModule] WHERE COMPANYID=@NEW_COMPANY_ID
--	     AND controlcategoryId  in (SELECT  ID FROM [Common].[ControlCodeCategory] WHERE COMPANYID=@NEW_COMPANY_ID AND CONTROLCODECATEGORYCODE='Incidental Type')
--	     If @ControlCodeCategoryModule_Group_By_Cnt =0
--		  Begin
--		 SET @CONTROLCODECATEGORY_ID_MODULE_MASTER_ID = (SELECT top 1 ID FROM [Common].[ControlCodeCategory] WHERE COMPANYID=@NEW_COMPANY_ID AND CONTROLCODECATEGORYCODE='Incidental Type')
--		  SET @MODULE_MASTER_ID_CONTROLCODECATEGORY_ID = (SELECT Id FROM [Common].[ModuleMaster]  WHERE COMPANYID=@UNIQUE_COMPANY_ID AND NAME='Workflow Cursor')
--		  INSERT INTO [Common].[ControlCodeCategoryModule] (Id, CompanyId, ControlCategoryId, ModuleMasterId) VALUES ((SELECT MAX(Id) + 1 FROM [Common].[ControlCodeCategoryModule]),
--		  @NEW_COMPANY_ID,@CONTROLCODECATEGORY_ID_MODULE_MASTER_ID,@MODULE_MASTER_ID_CONTROLCODECATEGORY_ID);
--		  End


--		   --EntityAddress
--			Declare @ControlCodeCategoryModule_EntityAddress_Cnt bigint
--			Select @ControlCodeCategoryModule_EntityAddress_Cnt =count(*) from [Common].[ControlCodeCategoryModule] WHERE COMPANYID=@NEW_COMPANY_ID
--			AND controlcategoryId  in (SELECT  ID FROM [Common].[ControlCodeCategory] WHERE COMPANYID=@NEW_COMPANY_ID AND CONTROLCODECATEGORYCODE='EntityAddress')
--			If @ControlCodeCategoryModule_EntityAddress_Cnt =0
--		  Begin
--			  SET @CONTROLCODECATEGORY_ID_MODULE_MASTER_ID = (SELECT top 1 ID FROM [Common].[ControlCodeCategory] WHERE COMPANYID=@NEW_COMPANY_ID AND CONTROLCODECATEGORYCODE='EntityAddress')
--			  SET @MODULE_MASTER_ID_CONTROLCODECATEGORY_ID = (SELECT Id FROM [Common].[ModuleMaster]  WHERE COMPANYID=@UNIQUE_COMPANY_ID AND NAME='Workflow Cursor')
--			  INSERT INTO [Common].[ControlCodeCategoryModule] (Id, CompanyId, ControlCategoryId, ModuleMasterId) VALUES ((SELECT MAX(Id) + 1 FROM [Common].[ControlCodeCategoryModule]),
--			  @NEW_COMPANY_ID,@CONTROLCODECATEGORY_ID_MODULE_MASTER_ID,@MODULE_MASTER_ID_CONTROLCODECATEGORY_ID);
--	      End

--		  --IndividualAddress
--			Declare @ControlCodeCategoryModule_IndividualAddress_Cnt bigint
--			Select @ControlCodeCategoryModule_IndividualAddress_Cnt =count(*) from [Common].[ControlCodeCategoryModule] WHERE COMPANYID=@NEW_COMPANY_ID
--			AND controlcategoryId  in (SELECT  ID FROM [Common].[ControlCodeCategory] WHERE COMPANYID=@NEW_COMPANY_ID AND CONTROLCODECATEGORYCODE='IndividualAddress')
--			If @ControlCodeCategoryModule_IndividualAddress_Cnt =0
--		  Begin
--   SET @CONTROLCODECATEGORY_ID_MODULE_MASTER_ID = (SELECT top 1 ID FROM [Common].[ControlCodeCategory] WHERE COMPANYID=@NEW_COMPANY_ID AND CONTROLCODECATEGORYCODE='IndividualAddress')
--  SET @MODULE_MASTER_ID_CONTROLCODECATEGORY_ID = (SELECT Id FROM [Common].[ModuleMaster]  WHERE COMPANYID=@UNIQUE_COMPANY_ID AND NAME='Workflow Cursor')
--  INSERT INTO [Common].[ControlCodeCategoryModule] (Id, CompanyId, ControlCategoryId, ModuleMasterId) VALUES ((SELECT MAX(Id) + 1 FROM [Common].[ControlCodeCategoryModule]),
--  @NEW_COMPANY_ID,@CONTROLCODECATEGORY_ID_MODULE_MASTER_ID,@MODULE_MASTER_ID_CONTROLCODECATEGORY_ID);
--  End
--    --ReasonForCancel
--  Declare @ControlCodeCategoryModule_ReasonForCancel_Cnt bigint
--			Select @ControlCodeCategoryModule_ReasonForCancel_Cnt =count(*) from [Common].[ControlCodeCategoryModule] WHERE COMPANYID=@NEW_COMPANY_ID
--			AND controlcategoryId  in (SELECT  ID FROM [Common].[ControlCodeCategory] WHERE COMPANYID=@NEW_COMPANY_ID AND CONTROLCODECATEGORYCODE='ReasonForCancel')
--			If @ControlCodeCategoryModule_ReasonForCancel_Cnt =0
--		  Begin
--     SET @CONTROLCODECATEGORY_ID_MODULE_MASTER_ID = (SELECT top 1 ID FROM [Common].[ControlCodeCategory] WHERE COMPANYID=@NEW_COMPANY_ID AND CONTROLCODECATEGORYCODE='ReasonForCancel')
--  SET @MODULE_MASTER_ID_CONTROLCODECATEGORY_ID = (SELECT Id FROM [Common].[ModuleMaster]  WHERE COMPANYID=@UNIQUE_COMPANY_ID AND NAME='Workflow Cursor')
--  INSERT INTO [Common].[ControlCodeCategoryModule] (Id, CompanyId, ControlCategoryId, ModuleMasterId) VALUES ((SELECT MAX(Id) + 1 FROM [Common].[ControlCodeCategoryModule]),
--  @NEW_COMPANY_ID,@CONTROLCODECATEGORY_ID_MODULE_MASTER_ID,@MODULE_MASTER_ID_CONTROLCODECATEGORY_ID);
--  End

  
--  --Designation
--   Declare @ControlCodeCategoryModule_Designation_Cnt bigint
--			Select @ControlCodeCategoryModule_Designation_Cnt =count(*) from [Common].[ControlCodeCategoryModule] WHERE COMPANYID=@NEW_COMPANY_ID
--			AND controlcategoryId  in (SELECT  ID FROM [Common].[ControlCodeCategory] WHERE COMPANYID=@NEW_COMPANY_ID AND CONTROLCODECATEGORYCODE='Designation')
--			If @ControlCodeCategoryModule_Designation_Cnt =0
--		  Begin
--   	SET @CONTROLCODECATEGORY_ID_MODULE_MASTER_ID = (SELECT top 1 ID FROM [Common].[ControlCodeCategory] WHERE COMPANYID=@NEW_COMPANY_ID AND CONTROLCODECATEGORYCODE='Designation')
--		SET @MODULE_MASTER_ID_CONTROLCODECATEGORY_ID = (SELECT Id FROM [Common].[ModuleMaster]  WHERE COMPANYID=@UNIQUE_COMPANY_ID AND NAME='Workflow Cursor')
--		INSERT INTO [Common].[ControlCodeCategoryModule] (Id, CompanyId, ControlCategoryId, ModuleMasterId) VALUES ((SELECT MAX(Id) + 1 FROM [Common].[ControlCodeCategoryModule]),
--		@NEW_COMPANY_ID,@CONTROLCODECATEGORY_ID_MODULE_MASTER_ID,@MODULE_MASTER_ID_CONTROLCODECATEGORY_ID);
--		End
		
		
--		--'Service Nature'
--		 Declare @ControlCodeCategory_ServiceNature_Cnt bigint
--		 select @ControlCodeCategory_ServiceNature_Cnt=Count(*)  from [Common].[ControlCodeCategoryModule] where companyid=@NEW_COMPANY_ID 
--		and controlcategoryId in(SELECT  ID FROM [Common].[ControlCodeCategory] WHERE COMPANYID=@NEW_COMPANY_ID AND CONTROLCODECATEGORYCODE='Service Nature') 
         
--		 IF @ControlCodeCategory_ServiceNature_Cnt=0
--		 Begin


--		SET @CONTROLCODECATEGORY_ID_MODULE_MASTER_ID = (SELECT top 1 ID FROM [Common].[ControlCodeCategory] WHERE COMPANYID=@NEW_COMPANY_ID AND CONTROLCODECATEGORYCODE='Service Nature')
--		SET @MODULE_MASTER_ID_CONTROLCODECATEGORY_ID = (SELECT Id FROM [Common].[ModuleMaster]  WHERE COMPANYID=@UNIQUE_COMPANY_ID AND NAME='Client Cursor')
--		INSERT INTO [Common].[ControlCodeCategoryModule] (Id, CompanyId, ControlCategoryId, ModuleMasterId) VALUES ((SELECT MAX(Id) + 1 FROM [Common].[ControlCodeCategoryModule]),
--		@NEW_COMPANY_ID,@CONTROLCODECATEGORY_ID_MODULE_MASTER_ID,@MODULE_MASTER_ID_CONTROLCODECATEGORY_ID);

--		End

--		--------ReasonForCancel
--		 Declare @ControlCodeCategory_ReasonForCancel_Cnt bigint
-- select @ControlCodeCategory_ReasonForCancel_Cnt=Count(*)  from [Common].[ControlCodeCategoryModule] where companyid=@NEW_COMPANY_ID 
--and controlcategoryId in(SELECT  ID FROM [Common].[ControlCodeCategory] WHERE COMPANYID=@NEW_COMPANY_ID AND CONTROLCODECATEGORYCODE='ReasonForCancel') 
         
-- IF @ControlCodeCategory_ReasonForCancel_Cnt=0
-- Begin
		
--		 SET @CONTROLCODECATEGORY_ID_MODULE_MASTER_ID = (SELECT top 1 ID FROM [Common].[ControlCodeCategory] WHERE COMPANYID=@NEW_COMPANY_ID AND CONTROLCODECATEGORYCODE='ReasonForCancel')
--  SET @MODULE_MASTER_ID_CONTROLCODECATEGORY_ID = (SELECT Id FROM [Common].[ModuleMaster]  WHERE COMPANYID=@UNIQUE_COMPANY_ID AND NAME='Client Cursor')
--  INSERT INTO [Common].[ControlCodeCategoryModule] (Id, CompanyId, ControlCategoryId, ModuleMasterId) VALUES ((SELECT MAX(Id) + 1 FROM [Common].[ControlCodeCategoryModule]),
--  @NEW_COMPANY_ID,@CONTROLCODECATEGORY_ID_MODULE_MASTER_ID,@MODULE_MASTER_ID_CONTROLCODECATEGORY_ID);
--  End

Exec [dbo].[ControlCodeCategoryModule_SP_New] @NEW_COMPANY_ID,2



  --Notification seed data

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
GO
