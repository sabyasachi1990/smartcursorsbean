USE [SmartCursorSTG]
GO
/****** Object:  Table [Widget].[ActivityNotificationDetail]    Script Date: 16-12-2024 9.30.57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Widget].[ActivityNotificationDetail](
	[Id] [uniqueidentifier] NOT NULL,
	[ActivityNotificationId] [uniqueidentifier] NULL,
	[ParticipentId] [uniqueidentifier] NULL,
	[ToUser] [nvarchar](255) NULL,
	[Name] [nvarchar](100) NULL,
 CONSTRAINT [PK_ActivityNotificationDetail] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Widget].[ActivityNotificationDetail]  WITH CHECK ADD  CONSTRAINT [FK_ActivityNotificationDetail_ActivityNotification] FOREIGN KEY([ActivityNotificationId])
REFERENCES [Widget].[ActivityNotification] ([Id])
GO
ALTER TABLE [Widget].[ActivityNotificationDetail] CHECK CONSTRAINT [FK_ActivityNotificationDetail_ActivityNotification]
GO
ALTER TABLE [Widget].[ActivityNotificationDetail]  WITH CHECK ADD  CONSTRAINT [FK_ActivityNotificationDetail_UserAccount] FOREIGN KEY([ParticipentId])
REFERENCES [Auth].[UserAccount] ([Id])
GO
ALTER TABLE [Widget].[ActivityNotificationDetail] CHECK CONSTRAINT [FK_ActivityNotificationDetail_UserAccount]
GO
