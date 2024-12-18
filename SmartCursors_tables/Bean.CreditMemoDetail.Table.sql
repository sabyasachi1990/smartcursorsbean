USE [SmartCursorSTG]
GO
/****** Object:  Table [Bean].[CreditMemoDetail]    Script Date: 16-12-2024 9.30.55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Bean].[CreditMemoDetail](
	[Id] [uniqueidentifier] NOT NULL,
	[CreditMemoId] [uniqueidentifier] NOT NULL,
	[COAId] [bigint] NOT NULL,
	[AllowDisAllow] [bit] NULL,
	[TaxId] [bigint] NULL,
	[TaxRate] [float] NULL,
	[DocTaxAmount] [money] NULL,
	[TaxCurrency] [nvarchar](10) NULL,
	[DocAmount] [money] NOT NULL,
	[DocTotalAmount] [money] NOT NULL,
	[BaseAmount] [money] NULL,
	[BaseTaxAmount] [money] NULL,
	[BaseTotalAmount] [money] NULL,
	[RecOrder] [int] NULL,
	[Description] [nvarchar](254) NULL,
	[IsPLAccount] [bit] NULL,
	[TaxIdCode] [nvarchar](20) NULL,
	[ClearingState] [nvarchar](200) NULL,
 CONSTRAINT [PK_CreditMemoDetail] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Bean].[CreditMemoDetail]  WITH CHECK ADD  CONSTRAINT [FK_CreditMemoDetail_ChartOfAccount] FOREIGN KEY([COAId])
REFERENCES [Bean].[ChartOfAccount] ([Id])
GO
ALTER TABLE [Bean].[CreditMemoDetail] CHECK CONSTRAINT [FK_CreditMemoDetail_ChartOfAccount]
GO
ALTER TABLE [Bean].[CreditMemoDetail]  WITH CHECK ADD  CONSTRAINT [FK_CreditMemoDetail_CreditMemo] FOREIGN KEY([CreditMemoId])
REFERENCES [Bean].[CreditMemo] ([Id])
GO
ALTER TABLE [Bean].[CreditMemoDetail] CHECK CONSTRAINT [FK_CreditMemoDetail_CreditMemo]
GO
ALTER TABLE [Bean].[CreditMemoDetail]  WITH CHECK ADD  CONSTRAINT [FK_CreditMemoDetail_TaxCode] FOREIGN KEY([TaxId])
REFERENCES [Bean].[TaxCode] ([Id])
GO
ALTER TABLE [Bean].[CreditMemoDetail] CHECK CONSTRAINT [FK_CreditMemoDetail_TaxCode]
GO
