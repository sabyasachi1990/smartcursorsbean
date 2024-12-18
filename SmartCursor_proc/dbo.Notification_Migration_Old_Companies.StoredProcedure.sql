USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[Notification_Migration_Old_Companies]    Script Date: 16-12-2024 9.20.10 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[Notification_Migration_Old_Companies]
--Exec Notification_Migration_Old_Companies_1 1077

 @CompanyId bigint

 as
 begin

declare @IsPersonalSetting bigint = 0



If Not Exists (Select * From Notification.NotificationSettings WHere CompanyId=@CompanyId And CompanyUserId is null and CursorName='Client Cursor')
        BEGIN
Insert Into Notification.NotificationSettings (Id,CompanyId,CompanyUserId,CursorName,ScreenName,ScreenAction,Type,NotificationDescription,EmailDescription,FeatureName,    Recipient,OtherRecipients,ReminderPeriod,ReminderPeriodDuration,IsOn,CreatedDate,ModifiedBy,ModifiedDate,UserCreated,NotificationTemplate,
NotificationSubject,Status,Recorder,IsHidden,IsPersonalSetting,IsSelfNotification,EmailSubject,OtherEmailRecipient,EmailBodyTemplate)

 


        Select NEWID(),@CompanyId,CompanyUserId,CursorName,ScreenName,ScreenAction,Type,NotificationDescription,EmailDescription,FeatureName,Recipient,OtherRecipients,
		ReminderPeriod,ReminderPeriodDuration,IsOn,CreatedDate,ModifiedBy,ModifiedDate,UserCreated,NotificationTemplate,NotificationSubject,Status,Recorder,
		IsHidden,@IsPersonalSetting,IsSelfNotification,EmailSubject,OtherEmailRecipient,EmailBodyTemplate 
        From Notification.NotificationSettings Where CompanyId=0 and CompanyUserId is null and CursorName in (select Name from common.ModuleMaster where id in ( select ModuleId from Common.CompanyModule where CompanyId=@CompanyId and Status=1 and ModuleId in (1)))
		
END




If Not Exists (Select * From Notification.NotificationSettings WHere CompanyId=@CompanyId And CompanyUserId is null and CursorName='Common')
        BEGIN
Insert Into Notification.NotificationSettings (Id,CompanyId,CompanyUserId,CursorName,ScreenName,ScreenAction,Type,NotificationDescription,EmailDescription,FeatureName,    Recipient,OtherRecipients,ReminderPeriod,ReminderPeriodDuration,IsOn,CreatedDate,ModifiedBy,ModifiedDate,UserCreated,NotificationTemplate,
NotificationSubject,Status,Recorder,IsHidden,IsPersonalSetting,IsSelfNotification,EmailSubject,OtherEmailRecipient,EmailBodyTemplate)

 


        Select NEWID(),@CompanyId,CompanyUserId,CursorName,ScreenName,ScreenAction,Type,NotificationDescription,EmailDescription,FeatureName,Recipient,OtherRecipients,
		ReminderPeriod,ReminderPeriodDuration,IsOn,CreatedDate,ModifiedBy,ModifiedDate,UserCreated,NotificationTemplate,NotificationSubject,Status,Recorder,
		IsHidden,@IsPersonalSetting,IsSelfNotification,EmailSubject,OtherEmailRecipient,EmailBodyTemplate 
        From Notification.NotificationSettings Where CompanyId=0 and CompanyUserId is null  and CursorName='Common'
		
END



If Not Exists (Select * From Notification.NotificationSettings WHere CompanyId=@CompanyId And CompanyUserId is null and CursorName='HR Cursor')
        BEGIN
Insert Into Notification.NotificationSettings (Id,CompanyId,CompanyUserId,CursorName,ScreenName,ScreenAction,Type,NotificationDescription,EmailDescription,FeatureName,    Recipient,OtherRecipients,ReminderPeriod,ReminderPeriodDuration,IsOn,CreatedDate,ModifiedBy,ModifiedDate,UserCreated,NotificationTemplate,
NotificationSubject,Status,Recorder,IsHidden,IsPersonalSetting,IsSelfNotification,EmailSubject,OtherEmailRecipient,EmailBodyTemplate)

 


        Select NEWID(),@CompanyId,CompanyUserId,CursorName,ScreenName,ScreenAction,Type,NotificationDescription,EmailDescription,FeatureName,Recipient,OtherRecipients,
		ReminderPeriod,ReminderPeriodDuration,IsOn,CreatedDate,ModifiedBy,ModifiedDate,UserCreated,NotificationTemplate,NotificationSubject,Status,Recorder,
		IsHidden,@IsPersonalSetting,IsSelfNotification,EmailSubject,OtherEmailRecipient,EmailBodyTemplate 
        From Notification.NotificationSettings Where CompanyId=0 and CompanyUserId is null and CursorName in (select Name from common.ModuleMaster where id in ( select ModuleId from Common.CompanyModule where CompanyId=@CompanyId and Status=1 and ModuleId in (8)))
		
END




If Not Exists (Select * From Notification.NotificationSettings WHere CompanyId=@CompanyId And CompanyUserId is null and CursorName='Workflow Cursor')
        BEGIN
Insert Into Notification.NotificationSettings (Id,CompanyId,CompanyUserId,CursorName,ScreenName,ScreenAction,Type,NotificationDescription,EmailDescription,FeatureName,    Recipient,OtherRecipients,ReminderPeriod,ReminderPeriodDuration,IsOn,CreatedDate,ModifiedBy,ModifiedDate,UserCreated,NotificationTemplate,
NotificationSubject,Status,Recorder,IsHidden,IsPersonalSetting,IsSelfNotification,EmailSubject,OtherEmailRecipient,EmailBodyTemplate)

 


        Select NEWID(),@CompanyId,CompanyUserId,CursorName,ScreenName,ScreenAction,Type,NotificationDescription,EmailDescription,FeatureName,Recipient,OtherRecipients,
		ReminderPeriod,ReminderPeriodDuration,IsOn,CreatedDate,ModifiedBy,ModifiedDate,UserCreated,NotificationTemplate,NotificationSubject,Status,Recorder,
		IsHidden,@IsPersonalSetting,IsSelfNotification,EmailSubject,OtherEmailRecipient,EmailBodyTemplate 
        From Notification.NotificationSettings Where CompanyId=0 and CompanyUserId is null and CursorName in (select Name from common.ModuleMaster where id in ( select ModuleId from Common.CompanyModule where CompanyId=@CompanyId and Status=1 and ModuleId in (2)))
		
END



end

GO
