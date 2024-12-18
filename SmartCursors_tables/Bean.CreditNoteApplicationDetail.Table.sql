USE [SmartCursorSTG]
GO
/****** Object:  Table [Bean].[CreditNoteApplicationDetail]    Script Date: 16-12-2024 9.30.55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Bean].[CreditNoteApplicationDetail](
	[Id] [uniqueidentifier] NOT NULL,
	[CreditNoteApplicationId] [uniqueidentifier] NOT NULL,
	[DocumentId] [uniqueidentifier] NULL,
	[DocumentType] [nvarchar](20) NULL,
	[DocCurrency] [nvarchar](5) NOT NULL,
	[CreditAmount] [money] NOT NULL,
	[BaseCurrencyExchangeRate] [decimal](15, 10) NULL,
	[SegmentCategory1] [nvarchar](100) NULL,
	[SegmentCategory2] [nvarchar](100) NULL,
	[DocDescription] [nvarchar](150) NULL,
	[COAId] [bigint] NULL,
	[TaxId] [bigint] NULL,
	[TaxRate] [float] NULL,
	[TaxIdCode] [nvarchar](15) NULL,
	[TaxAmount] [money] NULL,
	[TotalAmount] [money] NULL,
	[RecOrder] [int] NULL,
	[ServiceEntityId] [bigint] NULL,
	[DocNo] [nvarchar](50) NULL,
	[RoundingAmount] [money] NULL,
 CONSTRAINT [PK_CreditNoteApplicationDetail] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Bean].[CreditNoteApplicationDetail]  WITH CHECK ADD  CONSTRAINT [FK_CreditNoteApplicationDetail_CreditNoteApplication] FOREIGN KEY([CreditNoteApplicationId])
REFERENCES [Bean].[CreditNoteApplication] ([Id])
GO
ALTER TABLE [Bean].[CreditNoteApplicationDetail] CHECK CONSTRAINT [FK_CreditNoteApplicationDetail_CreditNoteApplication]
GO
