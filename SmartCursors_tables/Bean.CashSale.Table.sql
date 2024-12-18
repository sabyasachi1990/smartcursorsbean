USE [SmartCursorSTG]
GO
/****** Object:  Table [Bean].[CashSale]    Script Date: 16-12-2024 9.30.55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Bean].[CashSale](
	[Id] [uniqueidentifier] NOT NULL,
	[CompanyId] [bigint] NOT NULL,
	[DocSubType] [nvarchar](20) NULL,
	[DocDate] [datetime2](7) NOT NULL,
	[DocNo] [nvarchar](25) NOT NULL,
	[PONo] [nvarchar](20) NULL,
	[NoSupportingDocs] [bit] NULL,
	[SegmentCategory1] [nvarchar](50) NULL,
	[SegmentCategory2] [nvarchar](50) NULL,
	[EntityType] [nvarchar](50) NULL,
	[EntityId] [uniqueidentifier] NULL,
	[ModeOfReceipt] [nvarchar](100) NULL,
	[BankClearingDate] [datetime2](7) NULL,
	[ReceiptrefNo] [nvarchar](50) NULL,
	[DocCurrency] [nvarchar](5) NULL,
	[ExchangeRate] [decimal](15, 10) NULL,
	[ExCurrency] [nvarchar](5) NULL,
	[ExDurationFrom] [datetime2](7) NULL,
	[ExDurationTo] [datetime2](7) NULL,
	[GSTExchangeRate] [decimal](15, 10) NULL,
	[GSTExCurrency] [nvarchar](5) NULL,
	[GSTExDurationFrom] [datetime2](7) NULL,
	[GSTExDurationTo] [datetime2](7) NULL,
	[DocumentState] [nvarchar](20) NOT NULL,
	[BalanceAmount] [money] NOT NULL,
	[GSTTotalAmount] [money] NULL,
	[GrandTotal] [money] NOT NULL,
	[IsGstSettings] [bit] NOT NULL,
	[IsMultiCurrency] [bit] NOT NULL,
	[IsSegmentReporting] [bit] NOT NULL,
	[IsAllowableNonAllowable] [bit] NOT NULL,
	[Remarks] [nvarchar](1000) NULL,
	[UserCreated] [nvarchar](254) NULL,
	[CreatedDate] [datetime2](7) NULL,
	[ModifiedBy] [nvarchar](254) NULL,
	[ModifiedDate] [datetime2](7) NULL,
	[Status] [int] NULL,
	[CashSaleNumber] [nvarchar](50) NULL,
	[IsNoSupportingDocument] [bit] NULL,
	[ServiceCompanyId] [bigint] NULL,
	[DocType] [nvarchar](50) NULL,
	[IsAllowableDisallowableActivated] [bit] NULL,
	[ReverseDate] [datetime2](7) NULL,
	[ReverseIsSupportingDocument] [bit] NULL,
	[ReverseRemarks] [nvarchar](1000) NULL,
	[AllocatedAmount] [decimal](18, 0) NULL,
	[SegmentMasterid1] [bigint] NULL,
	[SegmentMasterid2] [bigint] NULL,
	[SegmentDetailid1] [bigint] NULL,
	[SegmentDetailid2] [bigint] NULL,
	[IsBaseCurrencyRateChanged] [bit] NULL,
	[IsGSTCurrencyRateChanged] [bit] NULL,
	[IsGSTApplied] [bit] NULL,
	[ItemTotal] [money] NULL,
	[ExtensionType] [nvarchar](20) NULL,
	[RecOrder] [int] NULL,
	[COAId] [bigint] NOT NULL,
	[DocDescription] [varchar](256) NULL,
	[Version] [timestamp] NOT NULL,
	[IsLocked] [bit] NULL,
 CONSTRAINT [PK_CashSale] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ADD SENSITIVITY CLASSIFICATION TO [Bean].[CashSale].[DocCurrency] WITH (label = 'Confidential', label_id = '281b9ab3-ecbb-4a57-8486-c702e44215d8', information_type = 'Financial', information_type_id = 'c44193e1-0e58-4b2a-9001-f7d6e7bc1373', rank = Medium);
GO
ADD SENSITIVITY CLASSIFICATION TO [Bean].[CashSale].[ExCurrency] WITH (label = 'Confidential', label_id = '281b9ab3-ecbb-4a57-8486-c702e44215d8', information_type = 'Financial', information_type_id = 'c44193e1-0e58-4b2a-9001-f7d6e7bc1373', rank = Medium);
GO
ADD SENSITIVITY CLASSIFICATION TO [Bean].[CashSale].[GSTExCurrency] WITH (label = 'Confidential', label_id = '281b9ab3-ecbb-4a57-8486-c702e44215d8', information_type = 'Financial', information_type_id = 'c44193e1-0e58-4b2a-9001-f7d6e7bc1373', rank = Medium);
GO
ADD SENSITIVITY CLASSIFICATION TO [Bean].[CashSale].[BalanceAmount] WITH (label = 'Confidential', label_id = '281b9ab3-ecbb-4a57-8486-c702e44215d8', information_type = 'Financial', information_type_id = 'c44193e1-0e58-4b2a-9001-f7d6e7bc1373', rank = Medium);
GO
ADD SENSITIVITY CLASSIFICATION TO [Bean].[CashSale].[GSTTotalAmount] WITH (label = 'Confidential', label_id = '281b9ab3-ecbb-4a57-8486-c702e44215d8', information_type = 'Financial', information_type_id = 'c44193e1-0e58-4b2a-9001-f7d6e7bc1373', rank = Medium);
GO
ADD SENSITIVITY CLASSIFICATION TO [Bean].[CashSale].[AllocatedAmount] WITH (label = 'Confidential', label_id = '281b9ab3-ecbb-4a57-8486-c702e44215d8', information_type = 'Financial', information_type_id = 'c44193e1-0e58-4b2a-9001-f7d6e7bc1373', rank = Medium);
GO
ALTER TABLE [Bean].[CashSale] ADD  DEFAULT ('Final') FOR [DocSubType]
GO
ALTER TABLE [Bean].[CashSale] ADD  DEFAULT ((1)) FOR [Status]
GO
ALTER TABLE [Bean].[CashSale] ADD  DEFAULT (NULL) FOR [RecOrder]
GO
ALTER TABLE [Bean].[CashSale]  WITH CHECK ADD  CONSTRAINT [FK_CashSale_ChartOfAccount] FOREIGN KEY([COAId])
REFERENCES [Bean].[ChartOfAccount] ([Id])
GO
ALTER TABLE [Bean].[CashSale] CHECK CONSTRAINT [FK_CashSale_ChartOfAccount]
GO
ALTER TABLE [Bean].[CashSale]  WITH CHECK ADD  CONSTRAINT [FK_CashSale_Company] FOREIGN KEY([CompanyId])
REFERENCES [Common].[Company] ([Id])
GO
ALTER TABLE [Bean].[CashSale] CHECK CONSTRAINT [FK_CashSale_Company]
GO
ALTER TABLE [Bean].[CashSale]  WITH CHECK ADD  CONSTRAINT [FK_CashSale_Entity] FOREIGN KEY([EntityId])
REFERENCES [Bean].[Entity] ([Id])
GO
ALTER TABLE [Bean].[CashSale] CHECK CONSTRAINT [FK_CashSale_Entity]
GO
