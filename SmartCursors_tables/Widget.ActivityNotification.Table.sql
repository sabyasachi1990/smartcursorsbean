USE [SmartCursorSTG]
GO
/****** Object:  Table [Widget].[ActivityNotification]    Script Date: 16-12-2024 9.30.57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Widget].[ActivityNotification](
	[Id] [uniqueidentifier] NOT NULL,
	[ActivityId] [uniqueidentifier] NOT NULL,
	[CompanyId] [bigint] NOT NULL,
	[Datetime] [datetime2](7) NULL,
	[NotificationDate] [datetime2](7) NULL,
	[Subject] [nvarchar](255) NULL,
	[Description] [nvarchar](1000) NULL,
	[FromUser] [nvarchar](100) NULL,
	[ToUser] [nvarchar](255) NULL,
	[UrlLink] [nvarchar](100) NULL,
	[Type] [nvarchar](100) NULL,
 CONSTRAINT [PK_ActivityNotification] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Widget].[ActivityNotification]  WITH CHECK ADD  CONSTRAINT [FK_ActivityNotification_Activity] FOREIGN KEY([ActivityId])
REFERENCES [Widget].[Activity] ([Id])
GO
ALTER TABLE [Widget].[ActivityNotification] CHECK CONSTRAINT [FK_ActivityNotification_Activity]
GO
