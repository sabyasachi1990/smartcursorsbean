USE [SmartCursorSTG]
GO
/****** Object:  Table [Bean].[InvoiceGSTDetail]    Script Date: 16-12-2024 9.30.55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Bean].[InvoiceGSTDetail](
	[Id] [uniqueidentifier] NOT NULL,
	[InvoiceId] [uniqueidentifier] NOT NULL,
	[Amount] [money] NOT NULL,
	[TaxAmount] [money] NOT NULL,
	[TotalAmount] [money] NOT NULL,
	[TaxId] [bigint] NULL,
 CONSTRAINT [PK_InvoiceGSTDetail] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Bean].[InvoiceGSTDetail]  WITH CHECK ADD  CONSTRAINT [FK_InvoiceGSTDetail_Invoice] FOREIGN KEY([InvoiceId])
REFERENCES [Bean].[Invoice] ([Id])
GO
ALTER TABLE [Bean].[InvoiceGSTDetail] CHECK CONSTRAINT [FK_InvoiceGSTDetail_Invoice]
GO
ALTER TABLE [Bean].[InvoiceGSTDetail]  WITH CHECK ADD  CONSTRAINT [FK_InvoiceGSTDetail_TaxCode] FOREIGN KEY([TaxId])
REFERENCES [Bean].[TaxCode] ([Id])
GO
ALTER TABLE [Bean].[InvoiceGSTDetail] CHECK CONSTRAINT [FK_InvoiceGSTDetail_TaxCode]
GO
