USE [SmartCursorSTG]
GO
/****** Object:  Table [HR].[LevaesNotUpdatedtoWF1]    Script Date: 16-12-2024 9.30.57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [HR].[LevaesNotUpdatedtoWF1](
	[Id] [uniqueidentifier] NOT NULL,
	[Companyid] [int] NULL,
	[LeaveId] [uniqueidentifier] NULL,
	[LeaveName] [nvarchar](250) NULL,
	[CompanyName] [nvarchar](250) NULL,
	[EmployeeName] [nvarchar](250) NULL,
	[LeaveStartDate] [datetime2](7) NULL,
	[LeaveEndDate] [datetime2](7) NULL,
	[LeaveStatus] [nvarchar](250) NULL,
	[IsNotSynctoWorkflow] [bit] NULL,
	[startDatetype] [nvarchar](10) NULL,
	[EndDateType] [nvarchar](10) NULL
) ON [PRIMARY]
GO
