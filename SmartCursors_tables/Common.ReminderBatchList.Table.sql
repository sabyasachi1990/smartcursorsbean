USE [SmartCursorSTG]
GO
/****** Object:  Table [Common].[ReminderBatchList]    Script Date: 16-12-2024 9.30.56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Common].[ReminderBatchList](
	[Id] [uniqueidentifier] NOT NULL,
	[CompanyId] [bigint] NOT NULL,
	[AccountId] [uniqueidentifier] NOT NULL,
	[ReminderType] [nvarchar](50) NULL,
	[Recipient] [nvarchar](max) NULL,
	[JobExecutedOn] [datetime] NULL,
	[TemplateId] [uniqueidentifier] NOT NULL,
	[Description] [nvarchar](100) NULL,
	[JobStatus] [nvarchar](20) NULL,
	[UserCreated] [nvarchar](254) NULL,
	[CreatedDate] [datetime2](7) NULL,
	[ModifiedBy] [nvarchar](254) NULL,
	[ModifiedDate] [datetime2](7) NULL,
	[Status] [int] NULL,
	[isDismiss] [bit] NULL,
	[Name] [nvarchar](max) NULL,
 CONSTRAINT [PK_ReminderBatchList] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [Common].[ReminderBatchList] ADD  DEFAULT ((1)) FOR [Status]
GO
ALTER TABLE [Common].[ReminderBatchList]  WITH CHECK ADD  CONSTRAINT [FK_Account_AccountId] FOREIGN KEY([AccountId])
REFERENCES [ClientCursor].[Account] ([Id])
GO
ALTER TABLE [Common].[ReminderBatchList] CHECK CONSTRAINT [FK_Account_AccountId]
GO
ALTER TABLE [Common].[ReminderBatchList]  WITH CHECK ADD  CONSTRAINT [FK_JobType_Company] FOREIGN KEY([CompanyId])
REFERENCES [Common].[Company] ([Id])
GO
ALTER TABLE [Common].[ReminderBatchList] CHECK CONSTRAINT [FK_JobType_Company]
GO
ALTER TABLE [Common].[ReminderBatchList]  WITH CHECK ADD  CONSTRAINT [FK_ReminderBatchList_GenericTemplate] FOREIGN KEY([TemplateId])
REFERENCES [Common].[GenericTemplate] ([Id])
GO
ALTER TABLE [Common].[ReminderBatchList] CHECK CONSTRAINT [FK_ReminderBatchList_GenericTemplate]
GO
