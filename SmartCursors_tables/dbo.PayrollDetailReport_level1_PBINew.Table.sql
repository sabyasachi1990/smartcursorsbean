USE [SmartCursorSTG]
GO
/****** Object:  Table [dbo].[PayrollDetailReport_level1_PBINew]    Script Date: 16-12-2024 9.30.56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[PayrollDetailReport_level1_PBINew](
	[id] [uniqueidentifier] NOT NULL,
	[Entity] [nvarchar](254) NOT NULL,
	[Year-Month] [nvarchar](21) NULL,
	[Total] [int] NOT NULL,
	[Count] [int] NULL,
	[Left] [int] NULL,
	[State] [nvarchar](15) NULL,
	[Created Date] [date] NULL,
	[Created By] [nvarchar](254) NULL,
	[Modified Date] [date] NULL,
	[Modified By] [nvarchar](254) NULL,
	[TenantId] [uniqueidentifier] NULL,
	[SubCompanyName] [nvarchar](254) NOT NULL,
	[Department] [nvarchar](20) NULL,
	[Employee Name] [nvarchar](100) NULL,
	[Year] [int] NULL,
	[Month] [nvarchar](3) NULL
) ON [PRIMARY]
GO
