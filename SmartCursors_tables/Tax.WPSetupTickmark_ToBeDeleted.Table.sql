USE [SmartCursorSTG]
GO
/****** Object:  Table [Tax].[WPSetupTickmark_ToBeDeleted]    Script Date: 16-12-2024 9.30.57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Tax].[WPSetupTickmark_ToBeDeleted](
	[Id] [uniqueidentifier] NOT NULL,
	[WPSetupId] [uniqueidentifier] NULL,
	[TickMarkId] [uniqueidentifier] NULL,
	[Status] [int] NULL,
 CONSTRAINT [PK_WPSetupTickmark] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Tax].[WPSetupTickmark_ToBeDeleted] ADD  DEFAULT ((1)) FOR [Status]
GO
ALTER TABLE [Tax].[WPSetupTickmark_ToBeDeleted]  WITH CHECK ADD  CONSTRAINT [FK_WPSetupTickmark_TickMarkSetup] FOREIGN KEY([TickMarkId])
REFERENCES [Tax].[TickMarkSetup] ([Id])
GO
ALTER TABLE [Tax].[WPSetupTickmark_ToBeDeleted] CHECK CONSTRAINT [FK_WPSetupTickmark_TickMarkSetup]
GO
ALTER TABLE [Tax].[WPSetupTickmark_ToBeDeleted]  WITH CHECK ADD  CONSTRAINT [FK_WPSetupTickmark_WPSetup] FOREIGN KEY([WPSetupId])
REFERENCES [Tax].[WPSetup] ([Id])
GO
ALTER TABLE [Tax].[WPSetupTickmark_ToBeDeleted] CHECK CONSTRAINT [FK_WPSetupTickmark_WPSetup]
GO
