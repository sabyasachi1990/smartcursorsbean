USE [SmartCursorSTG]
GO
/****** Object:  UserDefinedTableType [dbo].[CreditNoteApplicationDetail]    Script Date: 16-12-2024 9.33.40 PM ******/
CREATE TYPE [dbo].[CreditNoteApplicationDetail] AS TABLE(
	[Id] [uniqueidentifier] NULL,
	[CreditNoteApplicationId] [uniqueidentifier] NULL,
	[DocumentId] [uniqueidentifier] NULL,
	[DocumentType] [nvarchar](50) NULL,
	[DocCurrency] [nvarchar](20) NULL,
	[CreditAmount] [money] NULL,
	[BaseCurrencyExchangeRate] [decimal](15, 10) NULL,
	[DocDescription] [nvarchar](256) NULL,
	[COAId] [bigint] NULL,
	[TaxId] [bigint] NULL,
	[TaxRate] [float] NULL,
	[TaxIdCode] [nvarchar](50) NULL,
	[TaxAmount] [money] NULL,
	[TotalAmount] [money] NULL,
	[RecOrder] [int] NULL,
	[ServiceEntityId] [bigint] NULL,
	[DocNo] [nvarchar](50) NULL
)
GO
