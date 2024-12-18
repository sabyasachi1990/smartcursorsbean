USE [SmartCursorSTG]
GO
/****** Object:  Table [Bean].[BillCreditMemoDetail]    Script Date: 16-12-2024 9.30.55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Bean].[BillCreditMemoDetail](
	[Id] [uniqueidentifier] NOT NULL,
	[CreditMemoId] [uniqueidentifier] NOT NULL,
	[BillDetailId] [uniqueidentifier] NOT NULL,
	[DocCreditMemoAmount] [money] NOT NULL,
	[DocCreditMemoTaxAmount] [money] NULL,
	[DocTotal] [money] NOT NULL,
	[BaseCreditMemoAmount] [money] NULL,
	[BaseCreditMemoTaxAmount] [money] NULL,
	[BaseTotal] [money] NULL,
 CONSTRAINT [PK_BillCreditMemoDetail] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Bean].[BillCreditMemoDetail]  WITH CHECK ADD  CONSTRAINT [FK_BillCreditMemoDetail_Bill] FOREIGN KEY([CreditMemoId])
REFERENCES [Bean].[BillCreditMemo] ([Id])
GO
ALTER TABLE [Bean].[BillCreditMemoDetail] CHECK CONSTRAINT [FK_BillCreditMemoDetail_Bill]
GO
ALTER TABLE [Bean].[BillCreditMemoDetail]  WITH CHECK ADD  CONSTRAINT [FK_BillCreditMemoDetail_BillDetail] FOREIGN KEY([BillDetailId])
REFERENCES [Bean].[BillDetail] ([Id])
GO
ALTER TABLE [Bean].[BillCreditMemoDetail] CHECK CONSTRAINT [FK_BillCreditMemoDetail_BillDetail]
GO
