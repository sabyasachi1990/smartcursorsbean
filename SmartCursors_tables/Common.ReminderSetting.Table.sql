USE [SmartCursorSTG]
GO
/****** Object:  Table [Common].[ReminderSetting]    Script Date: 16-12-2024 9.30.56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Common].[ReminderSetting](
	[Id] [uniqueidentifier] NOT NULL,
	[CompanyId] [bigint] NOT NULL,
	[NoOfDays] [int] NULL,
	[Type] [nvarchar](50) NOT NULL,
	[Period] [nvarchar](50) NOT NULL,
	[AGMName] [nvarchar](50) NOT NULL,
	[CreatedDate] [datetime2](7) NULL,
	[UserCreated] [nvarchar](254) NULL,
	[ModifiedBy] [nvarchar](254) NULL,
	[ModifiedDate] [datetime2](7) NULL,
	[ReminderDate] [datetime2](7) NULL,
	[Version] [smallint] NULL,
	[Status] [int] NULL,
 CONSTRAINT [PK_ReminderSetting] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Common].[ReminderSetting] ADD  DEFAULT ((1)) FOR [Status]
GO
ALTER TABLE [Common].[ReminderSetting]  WITH CHECK ADD  CONSTRAINT [FK_ReminderSetting_Company] FOREIGN KEY([CompanyId])
REFERENCES [Common].[Company] ([Id])
GO
ALTER TABLE [Common].[ReminderSetting] CHECK CONSTRAINT [FK_ReminderSetting_Company]
GO
