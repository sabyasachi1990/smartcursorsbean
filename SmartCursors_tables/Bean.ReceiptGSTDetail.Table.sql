USE [SmartCursorSTG]
GO
/****** Object:  Table [Bean].[ReceiptGSTDetail]    Script Date: 16-12-2024 9.30.55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Bean].[ReceiptGSTDetail](
	[Id] [uniqueidentifier] NOT NULL,
	[ReceiptId] [uniqueidentifier] NOT NULL,
	[TaxId] [bigint] NOT NULL,
	[TaxCode] [nvarchar](20) NOT NULL,
	[Amount] [money] NOT NULL,
	[TaxAmount] [money] NOT NULL,
	[TotalAmount] [money] NOT NULL,
 CONSTRAINT [PK_ReceiptGSTDetail] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Bean].[ReceiptGSTDetail]  WITH CHECK ADD  CONSTRAINT [FK_ReceiptGSTDetail_Receipt] FOREIGN KEY([ReceiptId])
REFERENCES [Bean].[Receipt] ([Id])
GO
ALTER TABLE [Bean].[ReceiptGSTDetail] CHECK CONSTRAINT [FK_ReceiptGSTDetail_Receipt]
GO
ALTER TABLE [Bean].[ReceiptGSTDetail]  WITH CHECK ADD  CONSTRAINT [FK_ReceiptGSTDetail_TaxCode] FOREIGN KEY([TaxId])
REFERENCES [Bean].[TaxCode] ([Id])
GO
ALTER TABLE [Bean].[ReceiptGSTDetail] CHECK CONSTRAINT [FK_ReceiptGSTDetail_TaxCode]
GO
