USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[User_Notification_SeedData]    Script Date: 16-12-2024 9.20.11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

create procedure [dbo].[User_Notification_SeedData]
@CompanyId bigint,
@CompanyUserId bigint,
@RoleId nvarchar(max)
 AS 
 begin

 


--Declare @CompanyId bigint=19
--Declare @CompanyUserId int=201
--Declare @RoleId nvarchar(max)='4151E9C5-62BE-431F-BA58-00117E5D229A'
--Declare @Name nvarchar(max)='HR Admin'
   declare @Id Uniqueidentifier
 
    Declare IDSplit_CSR Cursor For
		Select items from dbo.SplitToTable(@RoleId,',')
	Open IDSplit_CSR
	Fetch Next From IDSplit_CSR Into @Id
	While @@FETCH_STATUS=0
	Begin


       If Not Exists (Select * From Notification.NotificationSettings WHere CompanyId=@CompanyId And CursorName=(select mm.Name from Auth.RoleNew rn inner join Common.ModuleMaster mm on rn.ModuleMasterId=mm.Id where rn.Id=@Id) and CompanyUserId=@CompanyUserId)
        begin
Insert Into Notification.NotificationSettings (Id,CompanyId,CompanyUserId,CursorName,ScreenName,ScreenAction,Type,NotificationDescription,EmailDescription,FeatureName,    Recipient,OtherRecipients,ReminderPeriod,ReminderPeriodDuration,IsOn,CreatedDate,ModifiedBy,ModifiedDate,UserCreated,NotificationTemplate,
NotificationSubject,Status,Recorder,IsHidden,IsPersonalSetting,IsSelfNotification,EmailSubject,OtherEmailRecipient,EmailBodyTemplate)

 


        Select NEWID(),@CompanyId,@CompanyUserId,CursorName,ScreenName,ScreenAction,Type,NotificationDescription,EmailDescription,FeatureName,Recipient,OtherRecipients,ReminderPeriod,ReminderPeriodDuration,
                IsOn,CreatedDate,ModifiedBy,ModifiedDate,UserCreated,NotificationTemplate,NotificationSubject,Status,Recorder,IsHidden,IsPersonalSetting,IsSelfNotification,EmailSubject,OtherEmailRecipient,EmailBodyTemplate 
        From Notification.NotificationSettings Where CompanyId=@CompanyId and CompanyUserId is null And CursorName= (select mm.Name from Auth.RoleNew rn inner join Common.ModuleMaster mm on rn.ModuleMasterId=mm.Id where rn.Id=@Id
)
end


       If Not Exists (Select * From Notification.NotificationSettings WHere CompanyId=@CompanyId And CursorName='Common' and CompanyUserId=@CompanyUserId)
       begin
Insert Into Notification.NotificationSettings (Id,CompanyId,CompanyUserId,CursorName,ScreenName,ScreenAction,Type,NotificationDescription,EmailDescription,FeatureName,    Recipient,OtherRecipients,ReminderPeriod,ReminderPeriodDuration,IsOn,CreatedDate,ModifiedBy,ModifiedDate,UserCreated,NotificationTemplate,
NotificationSubject,Status,Recorder,IsHidden,IsPersonalSetting,IsSelfNotification,EmailSubject,OtherEmailRecipient,EmailBodyTemplate)

 


        Select NEWID(),@CompanyId,@CompanyUserId,CursorName,ScreenName,ScreenAction,Type,NotificationDescription,EmailDescription,FeatureName,Recipient,OtherRecipients,ReminderPeriod,ReminderPeriodDuration,
                IsOn,CreatedDate,ModifiedBy,ModifiedDate,UserCreated,NotificationTemplate,NotificationSubject,Status,Recorder,IsHidden,IsPersonalSetting,IsSelfNotification,EmailSubject,OtherEmailRecipient,EmailBodyTemplate 
        From Notification.NotificationSettings Where CompanyId=@CompanyId and CompanyUserId is null And CursorName='Common'

end

 

    Fetch Next From IDSplit_CSR Into @Id
	End
	Close IDSplit_CSR
	Deallocate IDSplit_CSR
End

 
GO
