USE [SmartCursorSTG]
GO
/****** Object:  Table [Boardroom].[AGMAndARRemindersTemplates]    Script Date: 16-12-2024 9.30.55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Boardroom].[AGMAndARRemindersTemplates](
	[Id] [uniqueidentifier] NOT NULL,
	[AGMAndARRemindersId] [uniqueidentifier] NOT NULL,
	[Type] [nvarchar](50) NULL,
	[TemplateId] [uniqueidentifier] NOT NULL,
 CONSTRAINT [Pk_AGMAndARRemindersTemplates] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Boardroom].[AGMAndARRemindersTemplates]  WITH CHECK ADD  CONSTRAINT [FK_AGMAndARReminders_AGMAndARRemindersTemplates] FOREIGN KEY([AGMAndARRemindersId])
REFERENCES [Boardroom].[AGMAndARReminders] ([Id])
GO
ALTER TABLE [Boardroom].[AGMAndARRemindersTemplates] CHECK CONSTRAINT [FK_AGMAndARReminders_AGMAndARRemindersTemplates]
GO
