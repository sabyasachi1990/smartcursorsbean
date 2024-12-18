USE [SmartCursorSTG]
GO
/****** Object:  Table [Audit].[WPSetupTickmark]    Script Date: 16-12-2024 9.30.55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Audit].[WPSetupTickmark](
	[Id] [uniqueidentifier] NOT NULL,
	[WPSetupId] [uniqueidentifier] NULL,
	[TickMarkId] [uniqueidentifier] NULL,
	[Status] [int] NULL,
 CONSTRAINT [PK_WPSetupTickmark] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Audit].[WPSetupTickmark] ADD  DEFAULT ((1)) FOR [Status]
GO
ALTER TABLE [Audit].[WPSetupTickmark]  WITH CHECK ADD  CONSTRAINT [FK_WPSetupTickmark_TickMarkSetup] FOREIGN KEY([TickMarkId])
REFERENCES [Audit].[TickMarkSetup] ([Id])
GO
ALTER TABLE [Audit].[WPSetupTickmark] CHECK CONSTRAINT [FK_WPSetupTickmark_TickMarkSetup]
GO
ALTER TABLE [Audit].[WPSetupTickmark]  WITH CHECK ADD  CONSTRAINT [FK_WPSetupTickmark_WPSetup] FOREIGN KEY([WPSetupId])
REFERENCES [Audit].[WPSetup] ([Id])
GO
ALTER TABLE [Audit].[WPSetupTickmark] CHECK CONSTRAINT [FK_WPSetupTickmark_WPSetup]
GO
