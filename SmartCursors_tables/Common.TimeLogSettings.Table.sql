USE [SmartCursorSTG]
GO
/****** Object:  Table [Common].[TimeLogSettings]    Script Date: 16-12-2024 9.30.56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Common].[TimeLogSettings](
	[Id] [uniqueidentifier] NOT NULL,
	[CompanyId] [bigint] NOT NULL,
	[TimeLockOpenPeriod] [datetime2](7) NULL,
	[TimeLockClosePeriod] [datetime2](7) NULL,
	[AllowLogOperator] [nvarchar](3) NULL,
	[AllowLogValue] [int] NULL,
	[AllowLogPeriod] [nvarchar](10) NULL,
	[UserCreated] [nvarchar](254) NULL,
	[CreatedDate] [datetime2](7) NULL,
	[ModifiedBy] [nvarchar](254) NULL,
	[ModifiedDate] [datetime2](7) NULL,
	[Version] [smallint] NULL,
	[Status] [int] NULL,
	[AllowCaseType] [nvarchar](250) NULL,
 CONSTRAINT [PK_TimeLogSettings] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Common].[TimeLogSettings] ADD  DEFAULT ((1)) FOR [Status]
GO
ALTER TABLE [Common].[TimeLogSettings]  WITH CHECK ADD  CONSTRAINT [FK_TimeLogSettings_Company] FOREIGN KEY([CompanyId])
REFERENCES [Common].[Company] ([Id])
GO
ALTER TABLE [Common].[TimeLogSettings] CHECK CONSTRAINT [FK_TimeLogSettings_Company]
GO
