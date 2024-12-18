USE [SmartCursorSTG]
GO
/****** Object:  Table [Bean].[InvoiceDetail]    Script Date: 16-12-2024 9.30.55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Bean].[InvoiceDetail](
	[Id] [uniqueidentifier] NOT NULL,
	[InvoiceId] [uniqueidentifier] NOT NULL,
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
 CONSTRAINT [PK_InvoiceDetail] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Bean].[InvoiceDetail]  WITH CHECK ADD  CONSTRAINT [FK_InvoiceDetail_ChartOfAccount] FOREIGN KEY([COAId])
REFERENCES [Bean].[ChartOfAccount] ([Id])
GO
ALTER TABLE [Bean].[InvoiceDetail] CHECK CONSTRAINT [FK_InvoiceDetail_ChartOfAccount]
GO
ALTER TABLE [Bean].[InvoiceDetail]  WITH CHECK ADD  CONSTRAINT [FK_InvoiceDetail_Invoice] FOREIGN KEY([InvoiceId])
REFERENCES [Bean].[Invoice] ([Id])
GO
ALTER TABLE [Bean].[InvoiceDetail] CHECK CONSTRAINT [FK_InvoiceDetail_Invoice]
GO
ALTER TABLE [Bean].[InvoiceDetail]  WITH CHECK ADD  CONSTRAINT [FK_InvoiceDetail_Item] FOREIGN KEY([ItemId])
REFERENCES [Bean].[Item] ([Id])
GO
ALTER TABLE [Bean].[InvoiceDetail] CHECK CONSTRAINT [FK_InvoiceDetail_Item]
GO
ALTER TABLE [Bean].[InvoiceDetail]  WITH CHECK ADD  CONSTRAINT [fk_InvoiceDetail_TaxCode] FOREIGN KEY([TaxId])
REFERENCES [Bean].[TaxCode] ([Id])
GO
ALTER TABLE [Bean].[InvoiceDetail] CHECK CONSTRAINT [fk_InvoiceDetail_TaxCode]
GO
