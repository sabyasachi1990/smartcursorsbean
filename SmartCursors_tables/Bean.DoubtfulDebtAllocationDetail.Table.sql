USE [SmartCursorSTG]
GO
/****** Object:  Table [Bean].[DoubtfulDebtAllocationDetail]    Script Date: 16-12-2024 9.30.55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Bean].[DoubtfulDebtAllocationDetail](
	[Id] [uniqueidentifier] NOT NULL,
	[DoubtfulDebtAllocationId] [uniqueidentifier] NOT NULL,
	[DocumentId] [uniqueidentifier] NOT NULL,
	[DocumentType] [nvarchar](20) NOT NULL,
	[DocCurrency] [nvarchar](5) NOT NULL,
	[AllocateAmount] [money] NOT NULL,
	[DocNo] [nvarchar](20) NULL,
	[DocDate] [datetime2](7) NULL,
	[EntityId] [uniqueidentifier] NULL,
	[ExchangeRate] [decimal](15, 10) NULL,
 CONSTRAINT [PK_DoubtfulDebtAllocationDetail] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Bean].[DoubtfulDebtAllocationDetail]  WITH CHECK ADD  CONSTRAINT [FK_DoubtfulDebtAllocationDetail_DoubtfulDebtAllocation] FOREIGN KEY([DoubtfulDebtAllocationId])
REFERENCES [Bean].[DoubtfulDebtAllocation] ([Id])
GO
ALTER TABLE [Bean].[DoubtfulDebtAllocationDetail] CHECK CONSTRAINT [FK_DoubtfulDebtAllocationDetail_DoubtfulDebtAllocation]
GO
