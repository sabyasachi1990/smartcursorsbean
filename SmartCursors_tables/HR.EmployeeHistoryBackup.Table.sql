USE [SmartCursorSTG]
GO
/****** Object:  Table [HR].[EmployeeHistoryBackup]    Script Date: 16-12-2024 9.30.56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [HR].[EmployeeHistoryBackup](
	[Id] [uniqueidentifier] NOT NULL,
	[EmployeeId] [uniqueidentifier] NULL,
	[TypeOfEmployment] [nvarchar](20) NULL,
	[Employmentperiod] [nvarchar](20) NULL,
	[StartDate] [datetime2](7) NULL,
	[EndDate] [datetime2](7) NULL,
	[NoticePeriodStart] [datetime2](7) NULL,
	[NoticePeriodEnd] [datetime2](7) NULL
) ON [PRIMARY]
GO
