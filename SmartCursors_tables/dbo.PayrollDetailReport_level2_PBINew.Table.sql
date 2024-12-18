USE [SmartCursorSTG]
GO
/****** Object:  Table [dbo].[PayrollDetailReport_level2_PBINew]    Script Date: 16-12-2024 9.30.56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[PayrollDetailReport_level2_PBINew](
	[id] [uniqueidentifier] NOT NULL,
	[ParentId] [bigint] NULL,
	[SubCompany] [bigint] NOT NULL,
	[SubCompanyName] [nvarchar](254) NOT NULL,
	[PayrollStatus] [nvarchar](15) NULL,
	[PayRoll Date] [date] NULL,
	[EmployeeId] [uniqueidentifier] NOT NULL,
	[Employee Name] [nvarchar](100) NULL,
	[Employee No] [nvarchar](50) NULL,
	[Department] [nvarchar](20) NULL,
	[Designation] [nvarchar](20) NULL,
	[PayType] [nvarchar](128) NULL,
	[PayComponent] [nvarchar](128) NULL,
	[Amount] [money] NULL,
	[Ordering] [int] NULL,
	[SubOrdering] [numeric](3, 1) NULL,
	[Year] [int] NULL,
	[Month] [nvarchar](3) NULL,
	[TenantId] [uniqueidentifier] NULL
) ON [PRIMARY]
GO
