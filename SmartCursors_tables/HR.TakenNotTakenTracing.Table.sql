USE [SmartCursorSTG]
GO
/****** Object:  Table [HR].[TakenNotTakenTracing]    Script Date: 16-12-2024 9.30.57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [HR].[TakenNotTakenTracing](
	[Sno] [int] IDENTITY(1,1) NOT NULL,
	[CompanyId] [bigint] NULL,
	[EmployeeId] [uniqueidentifier] NULL,
	[leaveTypeId] [uniqueidentifier] NULL,
	[entitlementType] [nvarchar](200) NULL,
	[startdate] [datetime2](7) NULL,
	[todaydate] [datetime2](7) NULL,
	[Days] [decimal](10, 2) NULL,
	[Hours] [float] NULL,
	[approvedDate] [datetime2](7) NULL,
	[CurrentApprovedAndTaken] [float] NULL,
	[CurrentApprovedAndNotTaken] [float] NULL,
	[TakenNotTakenDate] [datetime2](7) NULL,
	[UpdateApprovedAndTaken] [float] NULL,
	[UpdateApprovedAndNotTaken] [float] NULL,
	[CreatedDate] [datetime2](7) NULL
) ON [PRIMARY]
GO
