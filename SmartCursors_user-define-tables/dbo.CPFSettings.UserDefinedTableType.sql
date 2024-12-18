USE [SmartCursorSTG]
GO
/****** Object:  UserDefinedTableType [dbo].[CPFSettings]    Script Date: 16-12-2024 9.33.40 PM ******/
CREATE TYPE [dbo].[CPFSettings] AS TABLE(
	[Id] [uniqueidentifier] NULL,
	[CompanyId] [bigint] NULL,
	[ContributionFor] [nvarchar](256) NULL,
	[AgeFrom] [int] NULL,
	[AgeTo] [int] NULL,
	[TotalWageFrom] [money] NULL,
	[TotalWageTo] [money] NULL,
	[EmprTotalWageRate] [money] NULL,
	[EmpDifferentialsWageAmt] [money] NULL,
	[EmprDifferentialsWageAmt] [money] NULL,
	[EmpDifferentialsWageRate] [money] NULL,
	[EmprDifferentialsWageRate] [money] NULL,
	[EmpOrdinaryWageRate] [money] NULL,
	[EmprOrdinaryWageRate] [money] NULL,
	[OrdinaryWageCap] [money] NULL,
	[OrdinaryWageCapInMonths] [int] NULL,
	[EmpAdditionalWageRate] [money] NULL,
	[EmprAdditionalWageRate] [money] NULL,
	[EffectiveFrom] [datetime2](7) NULL,
	[EffectiveTo] [datetime2](7) NULL,
	[CountryCode] [nvarchar](10) NULL
)
GO
