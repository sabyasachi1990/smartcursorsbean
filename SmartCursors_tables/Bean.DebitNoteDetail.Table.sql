USE [SmartCursorSTG]
GO
/****** Object:  Table [Bean].[DebitNoteDetail]    Script Date: 16-12-2024 9.30.55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Bean].[DebitNoteDetail](
	[Id] [uniqueidentifier] NOT NULL,
	[DebitNoteId] [uniqueidentifier] NOT NULL,
	[COAId] [bigint] NOT NULL,
	[AllowDisAllow] [bit] NULL,
	[TaxId] [bigint] NULL,
	[TaxType] [nvarchar](20) NULL,
	[TaxRate] [float] NULL,
	[DocAmount] [money] NOT NULL,
	[DocTaxAmount] [money] NULL,
	[DocTotalAmount] [money] NOT NULL,
	[BaseAmount] [money] NULL,
	[BaseTaxAmount] [money] NULL,
	[BaseTotalAmount] [money] NULL,
	[RecOrder] [int] NULL,
	[AccountDescription] [nvarchar](256) NULL,
	[IsPLAccount] [bit] NULL,
	[TaxIdCode] [nvarchar](20) NULL,
	[ClearingState] [nvarchar](200) NULL,
 CONSTRAINT [PK_DebitNoteDetail] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Bean].[DebitNoteDetail]  WITH CHECK ADD  CONSTRAINT [FK_DebitNoteDetail_ChartOfAccount] FOREIGN KEY([COAId])
REFERENCES [Bean].[ChartOfAccount] ([Id])
GO
ALTER TABLE [Bean].[DebitNoteDetail] CHECK CONSTRAINT [FK_DebitNoteDetail_ChartOfAccount]
GO
ALTER TABLE [Bean].[DebitNoteDetail]  WITH CHECK ADD  CONSTRAINT [FK_DebitNoteDetail_DebitNote] FOREIGN KEY([DebitNoteId])
REFERENCES [Bean].[DebitNote] ([Id])
GO
ALTER TABLE [Bean].[DebitNoteDetail] CHECK CONSTRAINT [FK_DebitNoteDetail_DebitNote]
GO
ALTER TABLE [Bean].[DebitNoteDetail]  WITH CHECK ADD  CONSTRAINT [fk_DebitNoteDetail_TaxCode] FOREIGN KEY([TaxId])
REFERENCES [Bean].[TaxCode] ([Id])
GO
ALTER TABLE [Bean].[DebitNoteDetail] CHECK CONSTRAINT [fk_DebitNoteDetail_TaxCode]
GO
