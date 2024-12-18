USE [SmartCursorSTG]
GO
/****** Object:  Table [dbo].[Licenses_Migrations]    Script Date: 16-12-2024 9.30.56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Licenses_Migrations](
	[CompanyId] [varchar](50) NULL,
	[Company Name] [varchar](500) NULL,
	[PartnerId] [varchar](50) NULL,
	[SubscriptionName] [varchar](50) NULL,
	[Quantity] [varchar](50) NULL,
	[BillingFrequency] [varchar](50) NULL,
	[Price] [varchar](50) NULL,
	[LicensesUsed] [varchar](50) NULL,
	[EffectiveFrom] [varchar](50) NULL,
	[EffectiveTo] [varchar](50) NULL,
	[NextBillingDate] [varchar](50) NULL,
	[TotalAmount] [varchar](50) NULL,
	[TaxCode] [varchar](50) NULL,
	[TaxRate] [varchar](50) NULL,
	[LicensesReduced] [varchar](50) NULL,
	[Status] [varchar](50) NULL,
	[PayTerm] [varchar](50) NULL,
	[LicensesReserved] [varchar](50) NULL,
	[PartnerPrice] [varchar](50) NULL
) ON [PRIMARY]
GO
