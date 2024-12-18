USE [SmartCursorSTG]
GO
/****** Object:  UserDefinedTableType [dbo].[AgencyFundDetails]    Script Date: 16-12-2024 9.33.40 PM ******/
CREATE TYPE [dbo].[AgencyFundDetails] AS TABLE(
	[Id] [uniqueidentifier] NULL,
	[AgencyFundId] [uniqueidentifier] NULL,
	[CompanyId] [bigint] NULL,
	[WageFrom] [money] NULL,
	[WageTo] [money] NULL,
	[Contribution] [money] NULL,
	[EffectiveFrom] [datetime2](7) NULL,
	[EffectiveTo] [datetime2](7) NULL,
	[STATUS] [int] NULL,
	[AgencyFundName] [nvarchar](500) NULL,
	[AgencyFundCode] [nvarchar](100) NULL
)
GO
