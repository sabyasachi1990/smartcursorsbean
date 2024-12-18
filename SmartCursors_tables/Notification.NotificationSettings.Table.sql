USE [SmartCursorSTG]
GO
/****** Object:  Table [Notification].[NotificationSettings]    Script Date: 16-12-2024 9.30.57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Notification].[NotificationSettings](
	[Id] [uniqueidentifier] NOT NULL,
	[CompanyId] [bigint] NOT NULL,
	[CompanyUserId] [bigint] NULL,
	[CursorName] [nvarchar](50) NOT NULL,
	[ScreenName] [nvarchar](100) NOT NULL,
	[ScreenAction] [nvarchar](100) NOT NULL,
	[Type] [nvarchar](50) NULL,
	[NotificationDescription] [nvarchar](500) NULL,
	[EmailDescription] [nvarchar](500) NULL,
	[FeatureName] [nvarchar](100) NULL,
	[Recipient] [nvarchar](100) NULL,
	[OtherRecipients] [nvarchar](max) NULL,
	[ReminderPeriod] [nvarchar](100) NULL,
	[ReminderPeriodDuration] [nvarchar](100) NULL,
	[IsOn] [bit] NULL,
	[CreatedDate] [datetime2](4) NULL,
	[ModifiedBy] [nvarchar](204) NULL,
	[ModifiedDate] [datetime2](4) NULL,
	[UserCreated] [nvarchar](204) NULL,
	[NotificationTemplate] [nvarchar](500) NULL,
	[NotificationSubject] [nvarchar](100) NULL,
	[Status] [int] NULL,
	[Recorder] [int] NULL,
	[IsHidden] [bit] NULL,
	[IsPersonalSetting] [bit] NULL,
	[IsSelfNotification] [bit] NULL,
	[EmailSubject] [nvarchar](204) NULL,
	[OtherEmailRecipient] [nvarchar](524) NULL,
	[EmailBodyTemplate] [nvarchar](max) NULL,
	[TeamsGroupChannels] [nvarchar](max) NULL,
	[TeamsConnector] [nvarchar](max) NULL,
 CONSTRAINT [PK_NotificationSettings] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
