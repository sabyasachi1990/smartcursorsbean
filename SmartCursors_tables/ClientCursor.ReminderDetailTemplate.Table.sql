USE [SmartCursorSTG]
GO
/****** Object:  Table [ClientCursor].[ReminderDetailTemplate]    Script Date: 16-12-2024 9.30.56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [ClientCursor].[ReminderDetailTemplate](
	[Id] [uniqueidentifier] NOT NULL,
	[ReminderDetailId] [uniqueidentifier] NOT NULL,
	[TemplateId] [uniqueidentifier] NOT NULL,
	[TemplateCode] [nvarchar](50) NULL,
	[RecOrder] [int] NULL,
 CONSTRAINT [PK_ReminderDetailTemplate] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [ClientCursor].[ReminderDetailTemplate]  WITH CHECK ADD  CONSTRAINT [FK_ReminderDetailTemplate_GenericTemplate] FOREIGN KEY([TemplateId])
REFERENCES [Common].[GenericTemplate] ([Id])
GO
ALTER TABLE [ClientCursor].[ReminderDetailTemplate] CHECK CONSTRAINT [FK_ReminderDetailTemplate_GenericTemplate]
GO
ALTER TABLE [ClientCursor].[ReminderDetailTemplate]  WITH CHECK ADD  CONSTRAINT [FK_ReminderDetailTemplate_RemainderDetail] FOREIGN KEY([ReminderDetailId])
REFERENCES [ClientCursor].[ReminderDetail] ([Id])
ON DELETE CASCADE
GO
ALTER TABLE [ClientCursor].[ReminderDetailTemplate] CHECK CONSTRAINT [FK_ReminderDetailTemplate_RemainderDetail]
GO
