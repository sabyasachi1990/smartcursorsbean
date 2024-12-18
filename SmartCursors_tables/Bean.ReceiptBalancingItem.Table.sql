USE [SmartCursorSTG]
GO
/****** Object:  Table [Bean].[ReceiptBalancingItem]    Script Date: 16-12-2024 9.30.55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Bean].[ReceiptBalancingItem](
	[Id] [uniqueidentifier] NOT NULL,
	[ReceiptId] [uniqueidentifier] NOT NULL,
	[ReciveORPay] [nvarchar](15) NOT NULL,
	[COAId] [bigint] NOT NULL,
	[Account] [nvarchar](100) NULL,
	[IsDisAllow] [bit] NULL,
	[TaxId] [bigint] NULL,
	[TaxCode] [nvarchar](20) NULL,
	[TaxRate] [float] NULL,
	[TaxType] [nvarchar](20) NULL,
	[Currency] [nvarchar](5) NULL,
	[DocAmount] [money] NOT NULL,
	[DocTaxAmount] [money] NULL,
	[DocTotalAmount] [money] NOT NULL,
	[Remarks] [nvarchar](1000) NULL,
	[UserCreated] [nvarchar](254) NULL,
	[CreatedDate] [datetime2](7) NULL,
	[ModifiedBy] [nvarchar](254) NULL,
	[ModifiedDate] [datetime2](7) NULL,
	[RecOrder] [int] NULL,
	[Status] [int] NOT NULL,
	[IsPLAccount] [bit] NULL,
	[TaxIdCode] [nvarchar](40) NULL,
	[ClearingState] [nvarchar](200) NULL,
 CONSTRAINT [PK_ReceiptBalancingItem] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Bean].[ReceiptBalancingItem] ADD  DEFAULT ((1)) FOR [Status]
GO
ALTER TABLE [Bean].[ReceiptBalancingItem]  WITH CHECK ADD  CONSTRAINT [fk_ReceiptBalancingItem_ChartOfAccount] FOREIGN KEY([COAId])
REFERENCES [Bean].[ChartOfAccount] ([Id])
GO
ALTER TABLE [Bean].[ReceiptBalancingItem] CHECK CONSTRAINT [fk_ReceiptBalancingItem_ChartOfAccount]
GO
ALTER TABLE [Bean].[ReceiptBalancingItem]  WITH CHECK ADD  CONSTRAINT [FK_ReceiptBalancingItem_Receipt] FOREIGN KEY([ReceiptId])
REFERENCES [Bean].[Receipt] ([Id])
GO
ALTER TABLE [Bean].[ReceiptBalancingItem] CHECK CONSTRAINT [FK_ReceiptBalancingItem_Receipt]
GO
ALTER TABLE [Bean].[ReceiptBalancingItem]  WITH CHECK ADD  CONSTRAINT [fk_ReceiptBalancingItem_TaxCode] FOREIGN KEY([TaxId])
REFERENCES [Bean].[TaxCode] ([Id])
GO
ALTER TABLE [Bean].[ReceiptBalancingItem] CHECK CONSTRAINT [fk_ReceiptBalancingItem_TaxCode]
GO
