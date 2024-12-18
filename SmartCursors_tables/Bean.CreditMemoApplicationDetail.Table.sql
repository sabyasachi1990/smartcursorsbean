USE [SmartCursorSTG]
GO
/****** Object:  Table [Bean].[CreditMemoApplicationDetail]    Script Date: 16-12-2024 9.30.55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Bean].[CreditMemoApplicationDetail](
	[Id] [uniqueidentifier] NOT NULL,
	[CreditMemoApplicationId] [uniqueidentifier] NOT NULL,
	[DocumentId] [uniqueidentifier] NULL,
	[DocumentType] [nvarchar](30) NULL,
	[DocCurrency] [nvarchar](5) NOT NULL,
	[CreditAmount] [money] NOT NULL,
	[BaseCurrencyExchangeRate] [decimal](15, 10) NULL,
	[SegmentCategory1] [nvarchar](100) NULL,
	[SegmentCategory2] [nvarchar](100) NULL,
	[COAId] [bigint] NULL,
	[DocDescription] [nvarchar](256) NULL,
	[TaxId] [bigint] NULL,
	[TaxRate] [float] NULL,
	[TaxIdCode] [nvarchar](20) NULL,
	[TaxAmount] [money] NULL,
	[TotalAmount] [money] NULL,
	[RecOrder] [int] NULL,
	[DocNo] [nvarchar](50) NULL,
	[RoundingAmount] [money] NULL,
 CONSTRAINT [PK_CreditMemoApplicationDetail] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Bean].[CreditMemoApplicationDetail]  WITH CHECK ADD  CONSTRAINT [FK_CreditMemoApplicationDetail_CreditMemoApplication] FOREIGN KEY([CreditMemoApplicationId])
REFERENCES [Bean].[CreditMemoApplication] ([Id])
GO
ALTER TABLE [Bean].[CreditMemoApplicationDetail] CHECK CONSTRAINT [FK_CreditMemoApplicationDetail_CreditMemoApplication]
GO
