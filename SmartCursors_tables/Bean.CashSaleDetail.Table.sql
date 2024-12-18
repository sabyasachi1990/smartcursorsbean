USE [SmartCursorSTG]
GO
/****** Object:  Table [Bean].[CashSaleDetail]    Script Date: 16-12-2024 9.30.55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Bean].[CashSaleDetail](
	[Id] [uniqueidentifier] NOT NULL,
	[CashSaleId] [uniqueidentifier] NOT NULL,
	[ItemId] [uniqueidentifier] NULL,
	[ItemCode] [nvarchar](50) NULL,
	[ItemDescription] [nvarchar](200) NULL,
	[Qty] [float] NULL,
	[Unit] [nvarchar](20) NULL,
	[UnitPrice] [money] NULL,
	[DiscountType] [nvarchar](1) NULL,
	[Discount] [float] NULL,
	[COAId] [bigint] NOT NULL,
	[AllowDisAllow] [bit] NULL,
	[TaxId] [bigint] NULL,
	[TaxRate] [float] NULL,
	[DocTaxAmount] [money] NULL,
	[TaxCurrency] [nvarchar](10) NULL,
	[DocAmount] [money] NOT NULL,
	[AmtCurrency] [nvarchar](10) NOT NULL,
	[DocTotalAmount] [money] NOT NULL,
	[Remarks] [nvarchar](1000) NULL,
	[BaseAmount] [money] NULL,
	[BaseTaxAmount] [money] NULL,
	[BaseTotalAmount] [money] NULL,
	[RecOrder] [int] NULL,
	[IsPLAccount] [bit] NULL,
	[TaxIdCode] [nvarchar](20) NULL,
	[ClearingState] [nvarchar](200) NULL,
 CONSTRAINT [PK_CashSaleDetail] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ADD SENSITIVITY CLASSIFICATION TO [Bean].[CashSaleDetail].[TaxId] WITH (label = 'Confidential - GDPR', label_id = '6ceae8dd-fab8-4956-8764-b809b49281be', information_type = 'National ID', information_type_id = '6f5a11a7-08b1-19c3-59e5-8c89cf4f8444', rank = Medium);
GO
ADD SENSITIVITY CLASSIFICATION TO [Bean].[CashSaleDetail].[TaxRate] WITH (label = 'Confidential', label_id = '281b9ab3-ecbb-4a57-8486-c702e44215d8', information_type = 'Financial', information_type_id = 'c44193e1-0e58-4b2a-9001-f7d6e7bc1373', rank = Medium);
GO
ADD SENSITIVITY CLASSIFICATION TO [Bean].[CashSaleDetail].[DocTaxAmount] WITH (label = 'Confidential', label_id = '281b9ab3-ecbb-4a57-8486-c702e44215d8', information_type = 'Financial', information_type_id = 'c44193e1-0e58-4b2a-9001-f7d6e7bc1373', rank = Medium);
GO
ADD SENSITIVITY CLASSIFICATION TO [Bean].[CashSaleDetail].[TaxCurrency] WITH (label = 'Confidential', label_id = '281b9ab3-ecbb-4a57-8486-c702e44215d8', information_type = 'Financial', information_type_id = 'c44193e1-0e58-4b2a-9001-f7d6e7bc1373', rank = Medium);
GO
ADD SENSITIVITY CLASSIFICATION TO [Bean].[CashSaleDetail].[DocAmount] WITH (label = 'Confidential', label_id = '281b9ab3-ecbb-4a57-8486-c702e44215d8', information_type = 'Financial', information_type_id = 'c44193e1-0e58-4b2a-9001-f7d6e7bc1373', rank = Medium);
GO
ADD SENSITIVITY CLASSIFICATION TO [Bean].[CashSaleDetail].[AmtCurrency] WITH (label = 'Confidential', label_id = '281b9ab3-ecbb-4a57-8486-c702e44215d8', information_type = 'Financial', information_type_id = 'c44193e1-0e58-4b2a-9001-f7d6e7bc1373', rank = Medium);
GO
ADD SENSITIVITY CLASSIFICATION TO [Bean].[CashSaleDetail].[DocTotalAmount] WITH (label = 'Confidential', label_id = '281b9ab3-ecbb-4a57-8486-c702e44215d8', information_type = 'Financial', information_type_id = 'c44193e1-0e58-4b2a-9001-f7d6e7bc1373', rank = Medium);
GO
ADD SENSITIVITY CLASSIFICATION TO [Bean].[CashSaleDetail].[BaseAmount] WITH (label = 'Confidential', label_id = '281b9ab3-ecbb-4a57-8486-c702e44215d8', information_type = 'Financial', information_type_id = 'c44193e1-0e58-4b2a-9001-f7d6e7bc1373', rank = Medium);
GO
ADD SENSITIVITY CLASSIFICATION TO [Bean].[CashSaleDetail].[BaseTaxAmount] WITH (label = 'Confidential', label_id = '281b9ab3-ecbb-4a57-8486-c702e44215d8', information_type = 'Financial', information_type_id = 'c44193e1-0e58-4b2a-9001-f7d6e7bc1373', rank = Medium);
GO
ADD SENSITIVITY CLASSIFICATION TO [Bean].[CashSaleDetail].[BaseTotalAmount] WITH (label = 'Confidential', label_id = '281b9ab3-ecbb-4a57-8486-c702e44215d8', information_type = 'Financial', information_type_id = 'c44193e1-0e58-4b2a-9001-f7d6e7bc1373', rank = Medium);
GO
ADD SENSITIVITY CLASSIFICATION TO [Bean].[CashSaleDetail].[TaxIdCode] WITH (label = 'Confidential - GDPR', label_id = '6ceae8dd-fab8-4956-8764-b809b49281be', information_type = 'National ID', information_type_id = '6f5a11a7-08b1-19c3-59e5-8c89cf4f8444', rank = Medium);
GO
ALTER TABLE [Bean].[CashSaleDetail] ADD  DEFAULT (NULL) FOR [RecOrder]
GO
ALTER TABLE [Bean].[CashSaleDetail]  WITH CHECK ADD  CONSTRAINT [FK_CashSaleDetail_CashSale] FOREIGN KEY([CashSaleId])
REFERENCES [Bean].[CashSale] ([Id])
GO
ALTER TABLE [Bean].[CashSaleDetail] CHECK CONSTRAINT [FK_CashSaleDetail_CashSale]
GO
ALTER TABLE [Bean].[CashSaleDetail]  WITH CHECK ADD  CONSTRAINT [FK_CashSaleDetail_ChartOfAccount] FOREIGN KEY([COAId])
REFERENCES [Bean].[ChartOfAccount] ([Id])
GO
ALTER TABLE [Bean].[CashSaleDetail] CHECK CONSTRAINT [FK_CashSaleDetail_ChartOfAccount]
GO
ALTER TABLE [Bean].[CashSaleDetail]  WITH CHECK ADD  CONSTRAINT [FK_CashSaleDetail_Item] FOREIGN KEY([ItemId])
REFERENCES [Bean].[Item] ([Id])
GO
ALTER TABLE [Bean].[CashSaleDetail] CHECK CONSTRAINT [FK_CashSaleDetail_Item]
GO
ALTER TABLE [Bean].[CashSaleDetail]  WITH CHECK ADD  CONSTRAINT [fk_CashSaleDetail_TaxCode] FOREIGN KEY([TaxId])
REFERENCES [Bean].[TaxCode] ([Id])
GO
ALTER TABLE [Bean].[CashSaleDetail] CHECK CONSTRAINT [fk_CashSaleDetail_TaxCode]
GO
