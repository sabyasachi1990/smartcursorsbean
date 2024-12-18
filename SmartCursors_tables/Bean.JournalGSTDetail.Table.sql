USE [SmartCursorSTG]
GO
/****** Object:  Table [Bean].[JournalGSTDetail]    Script Date: 16-12-2024 9.30.55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Bean].[JournalGSTDetail](
	[Id] [uniqueidentifier] NOT NULL,
	[JournalId] [uniqueidentifier] NOT NULL,
	[TaxId] [bigint] NULL,
	[Amount] [money] NOT NULL,
	[TaxAmount] [money] NOT NULL,
	[TotalAmount] [money] NOT NULL,
 CONSTRAINT [PK_JournalGSTDetail] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Bean].[JournalGSTDetail]  WITH CHECK ADD  CONSTRAINT [FK_JournalGSTDetail_Journal] FOREIGN KEY([JournalId])
REFERENCES [Bean].[Journal] ([Id])
GO
ALTER TABLE [Bean].[JournalGSTDetail] CHECK CONSTRAINT [FK_JournalGSTDetail_Journal]
GO
ALTER TABLE [Bean].[JournalGSTDetail]  WITH CHECK ADD  CONSTRAINT [FK_JournalGSTDetail_TaxCode] FOREIGN KEY([TaxId])
REFERENCES [Bean].[TaxCode] ([Id])
GO
ALTER TABLE [Bean].[JournalGSTDetail] CHECK CONSTRAINT [FK_JournalGSTDetail_TaxCode]
GO
