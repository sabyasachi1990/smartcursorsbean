USE [SmartCursorSTG]
GO
/****** Object:  Table [Bean].[Receipt]    Script Date: 16-12-2024 9.30.55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Bean].[Receipt](
	[Id] [uniqueidentifier] NOT NULL,
	[CompanyId] [bigint] NOT NULL,
	[DocSubType] [nvarchar](20) NOT NULL,
	[SystemRefNo] [nvarchar](50) NOT NULL,
	[EntityType] [nvarchar](50) NOT NULL,
	[EntityId] [uniqueidentifier] NOT NULL,
	[BankClearingDate] [datetime2](7) NULL,
	[DocDate] [datetime2](7) NULL,
	[DueDate] [datetime2](7) NULL,
	[DocNo] [nvarchar](25) NOT NULL,
	[ServiceCompanyId] [bigint] NOT NULL,
	[IsNoSupportingDocument] [bit] NULL,
	[NoSupportingDocs] [bit] NULL,
	[COAId] [bigint] NOT NULL,
	[ModeOfReceipt] [nvarchar](20) NOT NULL,
	[ReceiptRefNo] [nvarchar](50) NULL,
	[BankReceiptAmmountCurrency] [nvarchar](5) NOT NULL,
	[BankReceiptAmmount] [money] NOT NULL,
	[BankChargesCurrency] [nvarchar](5) NOT NULL,
	[BankCharges] [money] NULL,
	[ExcessPaidByClient] [nvarchar](50) NULL,
	[ExcessPaidByClientCurrency] [nvarchar](5) NULL,
	[ExcessPaidByClientAmmount] [money] NULL,
	[BalancingItemReciveCRCurrency] [nvarchar](5) NULL,
	[BalancingItemReciveCRAmount] [money] NULL,
	[BalancingItemPayDRCurrency] [nvarchar](5) NULL,
	[BalancingItemPayDRAmount] [money] NULL,
	[ReceiptApplicationCurrency] [nvarchar](5) NULL,
	[ReceiptApplicationAmmount] [money] NULL,
	[ExchangeRate] [decimal](15, 10) NULL,
	[ExCurrency] [nvarchar](5) NULL,
	[ExDurationFrom] [datetime2](7) NULL,
	[ExDurationTo] [datetime2](7) NULL,
	[IsGstSettings] [bit] NOT NULL,
	[IsMultiCurrency] [bit] NOT NULL,
	[IsAllowableDisallowable] [bit] NOT NULL,
	[IsDisAllow] [bit] NOT NULL,
	[GSTExchangeRate] [decimal](15, 10) NULL,
	[GSTExCurrency] [nvarchar](5) NULL,
	[GSTExDurationFrom] [datetime2](7) NULL,
	[GSTExDurationTo] [datetime2](7) NULL,
	[GSTTotalAmount] [money] NULL,
	[GrandTotal] [money] NOT NULL,
	[Remarks] [nvarchar](1000) NULL,
	[UserCreated] [nvarchar](254) NULL,
	[CreatedDate] [datetime2](7) NULL,
	[ModifiedBy] [nvarchar](254) NULL,
	[ModifiedDate] [datetime2](7) NULL,
	[Status] [int] NULL,
	[DocCurrency] [nvarchar](5) NOT NULL,
	[BaseCurrency] [nvarchar](5) NOT NULL,
	[IsGSTCurrencyRateChanged] [bit] NULL,
	[IsBaseCurrencyRateChanged] [bit] NULL,
	[DocumentState] [nvarchar](20) NULL,
	[SystemCalculatedExchangeRate] [decimal](15, 10) NULL,
	[VarianceExchangeRate] [decimal](15, 10) NULL,
	[IsGSTApplied] [bit] NULL,
	[IsExchangeRateLabel] [bit] NULL,
	[IsInterCompanyActive] [bit] NULL,
	[IsVendor] [bit] NULL,
	[Version] [timestamp] NOT NULL,
	[ClearCount] [int] NULL,
	[IsLocked] [bit] NULL,
 CONSTRAINT [PK_Receipt] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Bean].[Receipt] ADD  DEFAULT ((1)) FOR [Status]
GO
ALTER TABLE [Bean].[Receipt] ADD  DEFAULT ('SGD') FOR [DocCurrency]
GO
ALTER TABLE [Bean].[Receipt] ADD  DEFAULT ('SGD') FOR [BaseCurrency]
GO
ALTER TABLE [Bean].[Receipt]  WITH CHECK ADD  CONSTRAINT [FK_Receipt_ChartOfAccount] FOREIGN KEY([COAId])
REFERENCES [Bean].[ChartOfAccount] ([Id])
GO
ALTER TABLE [Bean].[Receipt] CHECK CONSTRAINT [FK_Receipt_ChartOfAccount]
GO
ALTER TABLE [Bean].[Receipt]  WITH CHECK ADD  CONSTRAINT [FK_Receipt_Company] FOREIGN KEY([CompanyId])
REFERENCES [Common].[Company] ([Id])
GO
ALTER TABLE [Bean].[Receipt] CHECK CONSTRAINT [FK_Receipt_Company]
GO
ALTER TABLE [Bean].[Receipt]  WITH CHECK ADD  CONSTRAINT [FK_Receipt_Entity] FOREIGN KEY([EntityId])
REFERENCES [Bean].[Entity] ([Id])
GO
ALTER TABLE [Bean].[Receipt] CHECK CONSTRAINT [FK_Receipt_Entity]
GO
