USE [SmartCursorSTG]
GO
/****** Object:  Table [Bean].[BillDetail]    Script Date: 16-12-2024 9.30.55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Bean].[BillDetail](
	[Id] [uniqueidentifier] NOT NULL,
	[BillId] [uniqueidentifier] NOT NULL,
	[Description] [nvarchar](256) NULL,
	[COAId] [bigint] NOT NULL,
	[IsDisallow] [bit] NOT NULL,
	[TaxId] [bigint] NULL,
	[TaxCode] [nvarchar](20) NULL,
	[TaxType] [nvarchar](20) NULL,
	[TaxRate] [float] NULL,
	[DocAmount] [money] NOT NULL,
	[DocTaxAmount] [money] NOT NULL,
	[DocTotalAmount] [money] NOT NULL,
	[BaseAmount] [money] NULL,
	[BaseTaxAmount] [money] NULL,
	[BaseTotalAmount] [money] NULL,
	[RecOrder] [int] NULL,
	[IsPLAccount] [bit] NULL,
	[TaxIdCode] [nvarchar](20) NULL,
	[ClearingState] [nvarchar](200) NULL,
 CONSTRAINT [PK_BillDetail] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Bean].[BillDetail]  WITH CHECK ADD  CONSTRAINT [FK_BillDetail_Bill] FOREIGN KEY([BillId])
REFERENCES [Bean].[Bill] ([Id])
GO
ALTER TABLE [Bean].[BillDetail] CHECK CONSTRAINT [FK_BillDetail_Bill]
GO
ALTER TABLE [Bean].[BillDetail]  WITH CHECK ADD  CONSTRAINT [FK_BillDetail_ChartOfAccount] FOREIGN KEY([COAId])
REFERENCES [Bean].[ChartOfAccount] ([Id])
GO
ALTER TABLE [Bean].[BillDetail] CHECK CONSTRAINT [FK_BillDetail_ChartOfAccount]
GO
ALTER TABLE [Bean].[BillDetail]  WITH CHECK ADD  CONSTRAINT [FK_BillDetail_TaxCode] FOREIGN KEY([TaxId])
REFERENCES [Bean].[TaxCode] ([Id])
GO
ALTER TABLE [Bean].[BillDetail] CHECK CONSTRAINT [FK_BillDetail_TaxCode]
GO
