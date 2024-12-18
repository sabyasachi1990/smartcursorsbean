USE [SmartCursorSTG]
GO
/****** Object:  Table [ClientCursor].[ReminderDetail]    Script Date: 16-12-2024 9.30.56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [ClientCursor].[ReminderDetail](
	[Id] [uniqueidentifier] NOT NULL,
	[ReminderMasterId] [uniqueidentifier] NOT NULL,
	[RecurranceType] [nvarchar](20) NOT NULL,
	[RemainderDate] [datetime] NULL,
	[OperatorSymbol] [char](1) NOT NULL,
	[Period] [nvarchar](20) NOT NULL,
	[PeriodValue] [int] NOT NULL,
	[Description] [nvarchar](250) NULL,
	[TemplateMode] [nvarchar](100) NULL,
	[UserCreated] [nvarchar](254) NULL,
	[CreatedDate] [datetime2](7) NULL,
	[ModifiedBy] [nvarchar](254) NULL,
	[ModifiedDate] [datetime2](7) NULL,
	[Status] [int] NULL,
	[Name] [nvarchar](50) NULL,
 CONSTRAINT [PK_ReminderDetail] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [ClientCursor].[ReminderDetail] ADD  DEFAULT ((1)) FOR [Status]
GO
ALTER TABLE [ClientCursor].[ReminderDetail]  WITH CHECK ADD  CONSTRAINT [FK_ReminderDetail_ReminderMaster] FOREIGN KEY([ReminderMasterId])
REFERENCES [ClientCursor].[ReminderMaster] ([Id])
ON DELETE CASCADE
GO
ALTER TABLE [ClientCursor].[ReminderDetail] CHECK CONSTRAINT [FK_ReminderDetail_ReminderMaster]
GO
