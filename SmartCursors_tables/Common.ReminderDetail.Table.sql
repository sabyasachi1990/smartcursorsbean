USE [SmartCursorSTG]
GO
/****** Object:  Table [Common].[ReminderDetail]    Script Date: 16-12-2024 9.30.56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Common].[ReminderDetail](
	[Id] [uniqueidentifier] NOT NULL,
	[ReminderMasterId] [uniqueidentifier] NOT NULL,
	[Name] [nvarchar](50) NULL,
	[RecurranceType] [nvarchar](20) NOT NULL,
	[WeekDay] [nvarchar](100) NULL,
	[Month] [nvarchar](20) NULL,
	[Date] [nvarchar](20) NULL,
	[Description] [nvarchar](250) NULL,
	[TemplateMode] [nvarchar](100) NULL,
	[UserCreated] [nvarchar](254) NULL,
	[CreatedDate] [datetime2](7) NULL,
	[ModifiedBy] [nvarchar](254) NULL,
	[ModifiedDate] [datetime2](7) NULL,
	[Status] [int] NULL,
 CONSTRAINT [PK_ReminderDetail] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Common].[ReminderDetail] ADD  DEFAULT ((1)) FOR [Status]
GO
ALTER TABLE [Common].[ReminderDetail]  WITH CHECK ADD  CONSTRAINT [FK_ReminderDetail_ReminderMaster] FOREIGN KEY([ReminderMasterId])
REFERENCES [Common].[ReminderMaster] ([Id])
ON DELETE CASCADE
GO
ALTER TABLE [Common].[ReminderDetail] CHECK CONSTRAINT [FK_ReminderDetail_ReminderMaster]
GO
