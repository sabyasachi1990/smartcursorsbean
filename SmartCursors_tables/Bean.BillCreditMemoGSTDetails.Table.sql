USE [SmartCursorSTG]
GO
/****** Object:  Table [Bean].[BillCreditMemoGSTDetails]    Script Date: 16-12-2024 9.30.55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Bean].[BillCreditMemoGSTDetails](
	[Id] [uniqueidentifier] NOT NULL,
	[CreditMemoId] [uniqueidentifier] NOT NULL,
	[TaxId] [bigint] NOT NULL,
	[TaxCode] [nvarchar](20) NOT NULL,
	[Amount] [money] NOT NULL,
	[TaxAmount] [money] NOT NULL,
	[Total] [money] NOT NULL,
 CONSTRAINT [PK_BillCreditMemoGSTDetails] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Bean].[BillCreditMemoGSTDetails]  WITH CHECK ADD  CONSTRAINT [FK_BillCreditMemoGSTDetails_BillCreditMemo] FOREIGN KEY([CreditMemoId])
REFERENCES [Bean].[BillCreditMemo] ([Id])
GO
ALTER TABLE [Bean].[BillCreditMemoGSTDetails] CHECK CONSTRAINT [FK_BillCreditMemoGSTDetails_BillCreditMemo]
GO
ALTER TABLE [Bean].[BillCreditMemoGSTDetails]  WITH CHECK ADD  CONSTRAINT [FK_BillCreditMemoGSTDetails_TaxCode] FOREIGN KEY([TaxId])
REFERENCES [Bean].[TaxCode] ([Id])
GO
ALTER TABLE [Bean].[BillCreditMemoGSTDetails] CHECK CONSTRAINT [FK_BillCreditMemoGSTDetails_TaxCode]
GO
