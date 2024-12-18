USE [SmartCursorSTG]
GO
/****** Object:  Table [Boardroom].[Remindersent]    Script Date: 16-12-2024 9.30.56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Boardroom].[Remindersent](
	[Id] [uniqueidentifier] NOT NULL,
	[EntityId] [uniqueidentifier] NOT NULL,
	[ReminderId] [uniqueidentifier] NOT NULL,
	[AGMId] [uniqueidentifier] NOT NULL,
	[ReminderDate] [datetime2](7) NOT NULL,
	[CompanyId] [bigint] NOT NULL,
	[ReminderType] [nvarchar](20) NULL,
	[SentBy] [nvarchar](250) NULL,
	[SentOn] [datetime2](7) NULL,
	[AGMDuedate] [datetime2](7) NULL,
	[ARDuedate] [datetime2](7) NULL,
	[FYEDate] [datetime2](7) NULL,
	[AGMDate] [datetime2](7) NULL,
	[ReminderReceipt] [nvarchar](500) NULL,
	[GenericTemplateId] [uniqueidentifier] NULL,
 CONSTRAINT [PK_ReminderSent] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Boardroom].[Remindersent]  WITH CHECK ADD  CONSTRAINT [FK_ARReminder_Remindersent] FOREIGN KEY([ReminderId])
REFERENCES [Boardroom].[AGMAndARReminders] ([Id])
GO
ALTER TABLE [Boardroom].[Remindersent] CHECK CONSTRAINT [FK_ARReminder_Remindersent]
GO
ALTER TABLE [Boardroom].[Remindersent]  WITH CHECK ADD  CONSTRAINT [FK_CompanyId_Remindersent] FOREIGN KEY([CompanyId])
REFERENCES [Common].[Company] ([Id])
GO
ALTER TABLE [Boardroom].[Remindersent] CHECK CONSTRAINT [FK_CompanyId_Remindersent]
GO
ALTER TABLE [Boardroom].[Remindersent]  WITH CHECK ADD  CONSTRAINT [FK_EntityDetail_Remindersent] FOREIGN KEY([EntityId])
REFERENCES [Common].[EntityDetail] ([Id])
GO
ALTER TABLE [Boardroom].[Remindersent] CHECK CONSTRAINT [FK_EntityDetail_Remindersent]
GO
ALTER TABLE [Boardroom].[Remindersent]  WITH CHECK ADD  CONSTRAINT [FK_ReminderSent_GenenricTemplate] FOREIGN KEY([GenericTemplateId])
REFERENCES [Common].[GenericTemplate] ([Id])
GO
ALTER TABLE [Boardroom].[Remindersent] CHECK CONSTRAINT [FK_ReminderSent_GenenricTemplate]
GO
