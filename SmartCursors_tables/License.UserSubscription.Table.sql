USE [SmartCursorSTG]
GO
/****** Object:  Table [License].[UserSubscription]    Script Date: 16-12-2024 9.30.57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [License].[UserSubscription](
	[Id] [uniqueidentifier] NOT NULL,
	[CompanyUserId] [bigint] NOT NULL,
	[SubscriptionId] [uniqueidentifier] NOT NULL,
	[Status] [int] NULL,
	[CompanyId] [bigint] NULL,
 CONSTRAINT [PK_UserSubscription] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [License].[UserSubscription]  WITH CHECK ADD  CONSTRAINT [FK_UserSubscription_CompanyUser] FOREIGN KEY([CompanyUserId])
REFERENCES [Common].[CompanyUser] ([Id])
GO
ALTER TABLE [License].[UserSubscription] CHECK CONSTRAINT [FK_UserSubscription_CompanyUser]
GO
ALTER TABLE [License].[UserSubscription]  WITH CHECK ADD  CONSTRAINT [FK_UserSubscription_Subscription] FOREIGN KEY([SubscriptionId])
REFERENCES [License].[Subscription] ([Id])
GO
ALTER TABLE [License].[UserSubscription] CHECK CONSTRAINT [FK_UserSubscription_Subscription]
GO
