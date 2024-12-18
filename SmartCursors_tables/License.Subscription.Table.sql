USE [SmartCursorSTG]
GO
/****** Object:  Table [License].[Subscription]    Script Date: 16-12-2024 9.30.57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [License].[Subscription](
	[Id] [uniqueidentifier] NOT NULL,
	[CompanyId] [bigint] NOT NULL,
	[PartnerId] [bigint] NULL,
	[ProgramId] [uniqueidentifier] NOT NULL,
	[SubscriptionName] [nvarchar](500) NOT NULL,
	[BillingFrequency] [nvarchar](20) NOT NULL,
	[NextBillingDate] [datetime2](7) NULL,
	[Price] [money] NOT NULL,
	[PartnerPrice] [money] NULL,
	[LicensesReserved] [int] NOT NULL,
	[LicensesUsed] [int] NOT NULL,
	[LicensesReduced] [int] NULL,
	[Status] [int] NULL,
	[UserCreated] [nvarchar](254) NULL,
	[CreatedDate] [datetime2](7) NULL,
	[ModifiedBy] [nvarchar](254) NULL,
	[ModifiedDate] [datetime2](7) NULL,
	[PackageId] [uniqueidentifier] NOT NULL,
	[PayTerm] [nvarchar](200) NOT NULL,
	[Emails] [nvarchar](max) NULL,
	[CurrencyCode] [nvarchar](200) NULL,
	[TotalAmount] [money] NOT NULL,
	[TaxCode] [nvarchar](20) NULL,
	[TaxId] [bigint] NOT NULL,
	[TaxRate] [real] NULL,
	[EffectiveTo] [datetime] NULL,
	[EffectiveFrom] [datetime2](7) NULL,
	[IsStopInvoiceSending] [bit] NULL,
 CONSTRAINT [PK_Subscription] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [License].[Subscription]  WITH CHECK ADD  CONSTRAINT [FK_Subscription_Package] FOREIGN KEY([PackageId])
REFERENCES [License].[Package] ([Id])
GO
ALTER TABLE [License].[Subscription] CHECK CONSTRAINT [FK_Subscription_Package]
GO
ALTER TABLE [License].[Subscription]  WITH CHECK ADD  CONSTRAINT [FK_Subscription_Program] FOREIGN KEY([ProgramId])
REFERENCES [License].[Program] ([Id])
GO
ALTER TABLE [License].[Subscription] CHECK CONSTRAINT [FK_Subscription_Program]
GO
