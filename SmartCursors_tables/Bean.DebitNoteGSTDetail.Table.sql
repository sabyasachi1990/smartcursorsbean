USE [SmartCursorSTG]
GO
/****** Object:  Table [Bean].[DebitNoteGSTDetail]    Script Date: 16-12-2024 9.30.55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Bean].[DebitNoteGSTDetail](
	[Id] [uniqueidentifier] NOT NULL,
	[DebitNoteId] [uniqueidentifier] NOT NULL,
	[TaxId] [bigint] NOT NULL,
	[Amount] [money] NOT NULL,
	[TaxAmount] [money] NOT NULL,
	[TotalAmount] [money] NOT NULL,
 CONSTRAINT [PK_DebitNoteGSTDetail] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Bean].[DebitNoteGSTDetail]  WITH CHECK ADD  CONSTRAINT [FK_DebitNoteGSTDetail_DebitNote] FOREIGN KEY([DebitNoteId])
REFERENCES [Bean].[DebitNote] ([Id])
GO
ALTER TABLE [Bean].[DebitNoteGSTDetail] CHECK CONSTRAINT [FK_DebitNoteGSTDetail_DebitNote]
GO
ALTER TABLE [Bean].[DebitNoteGSTDetail]  WITH CHECK ADD  CONSTRAINT [FK_DebitNoteGSTDetail_TaxCode] FOREIGN KEY([TaxId])
REFERENCES [Bean].[TaxCode] ([Id])
GO
ALTER TABLE [Bean].[DebitNoteGSTDetail] CHECK CONSTRAINT [FK_DebitNoteGSTDetail_TaxCode]
GO
