USE [SmartCursorSTG]
GO
/****** Object:  UserDefinedTableType [dbo].[DocumentDetailType]    Script Date: 16-12-2024 9.33.40 PM ******/
CREATE TYPE [dbo].[DocumentDetailType] AS TABLE(
	[Id] [uniqueidentifier] NULL,
	[ItemId] [uniqueidentifier] NULL,
	[ItemCode] [nvarchar](200) NULL,
	[ItemDescription] [nvarchar](400) NULL,
	[Qty] [float] NULL,
	[Unit] [nvarchar](20) NULL,
	[UnitPrice] [money] NULL,
	[DiscountType] [nvarchar](4) NULL,
	[Discount] [float] NULL,
	[COAId] [bigint] NULL,
	[TaxId] [bigint] NULL,
	[TaxRate] [float] NULL,
	[DocTaxAmount] [money] NULL,
	[DocAmount] [money] NULL,
	[DocTotalAmount] [money] NULL,
	[BaseTaxAmount] [money] NULL,
	[BaseAmount] [money] NULL,
	[BaseTotalAmount] [money] NULL,
	[AmtCurrency] [nvarchar](20) NULL,
	[RecOrder] [int] NULL,
	[TaxIdCode] [nvarchar](40) NULL,
	[RecordStatus] [nvarchar](20) NULL
)
GO
