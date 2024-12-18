USE [SmartCursorSTG]
GO
/****** Object:  Table [Notification].[TimeLogReport_ToBeDeleted]    Script Date: 16-12-2024 9.30.57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Notification].[TimeLogReport_ToBeDeleted](
	[Id] [uniqueidentifier] NOT NULL,
	[CompanyId] [bigint] NULL,
	[EmployeeId] [uniqueidentifier] NULL,
	[Subject] [nvarchar](256) NULL,
	[ScreenAction] [nvarchar](256) NULL,
	[Template] [nvarchar](max) NULL,
	[NotificationType] [nvarchar](50) NULL,
	[ToNotificationUser] [nvarchar](max) NULL,
	[ToEmailUser] [nvarchar](max) NULL,
	[Date] [datetime2](7) NULL,
	[UserCreated] [nvarchar](254) NULL,
	[CreatedDate] [datetime2](7) NULL,
	[Status] [int] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [Notification].[TimeLogReport_ToBeDeleted] ADD  DEFAULT (getdate()) FOR [CreatedDate]
GO
ALTER TABLE [Notification].[TimeLogReport_ToBeDeleted] ADD  DEFAULT ((1)) FOR [Status]
GO
