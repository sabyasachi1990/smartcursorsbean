USE [SmartCursorSTG]
GO
/****** Object:  Table [Notification].[Recovery]    Script Date: 16-12-2024 9.30.57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Notification].[Recovery](
	[Id] [uniqueidentifier] NOT NULL,
	[CaseId] [uniqueidentifier] NULL,
	[CaseNumber] [nvarchar](256) NULL,
	[ClientName] [nvarchar](256) NULL,
	[CompanyId] [bigint] NULL,
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
ADD SENSITIVITY CLASSIFICATION TO [Notification].[Recovery].[ToEmailUser] WITH (label = 'Confidential', label_id = '281b9ab3-ecbb-4a57-8486-c702e44215d8', information_type = 'Contact Info', information_type_id = '5c503e21-22c6-81fa-620b-f369b8ec38d1', rank = Medium);
GO
ALTER TABLE [Notification].[Recovery] ADD  DEFAULT (getdate()) FOR [CreatedDate]
GO
ALTER TABLE [Notification].[Recovery] ADD  DEFAULT ((1)) FOR [Status]
GO
