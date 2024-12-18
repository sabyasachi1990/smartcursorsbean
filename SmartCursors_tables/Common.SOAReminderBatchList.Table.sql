USE [SmartCursorSTG]
GO
/****** Object:  Table [Common].[SOAReminderBatchList]    Script Date: 16-12-2024 9.30.56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Common].[SOAReminderBatchList](
	[Id] [uniqueidentifier] NOT NULL,
	[CompanyId] [bigint] NOT NULL,
	[DocumentId] [uniqueidentifier] NOT NULL,
	[TemplateId] [uniqueidentifier] NOT NULL,
	[ReminderType] [nvarchar](50) NULL,
	[Name] [nvarchar](max) NULL,
	[CaseFees] [money] NULL,
	[UnpaidAmount] [money] NULL,
	[Recipient] [nvarchar](max) NULL,
	[JobExecutedOn] [datetime] NULL,
	[JobStatus] [nvarchar](20) NULL,
	[isDismiss] [bit] NULL,
	[UserCreated] [nvarchar](254) NULL,
	[CreatedDate] [datetime2](7) NULL,
	[ModifiedBy] [nvarchar](254) NULL,
	[ModifiedDate] [datetime2](7) NULL,
	[Status] [int] NULL,
	[BaseCurrency] [nvarchar](10) NULL,
 CONSTRAINT [PK_SOAReminderBatchList] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [Common].[SOAReminderBatchList] ADD  DEFAULT ((1)) FOR [Status]
GO
ALTER TABLE [Common].[SOAReminderBatchList]  WITH CHECK ADD  CONSTRAINT [FK_Reminder_GenericTemplate] FOREIGN KEY([TemplateId])
REFERENCES [Common].[GenericTemplate] ([Id])
GO
ALTER TABLE [Common].[SOAReminderBatchList] CHECK CONSTRAINT [FK_Reminder_GenericTemplate]
GO
ALTER TABLE [Common].[SOAReminderBatchList]  WITH CHECK ADD  CONSTRAINT [FK_ReminderJobType_Company] FOREIGN KEY([CompanyId])
REFERENCES [Common].[Company] ([Id])
GO
ALTER TABLE [Common].[SOAReminderBatchList] CHECK CONSTRAINT [FK_ReminderJobType_Company]
GO
