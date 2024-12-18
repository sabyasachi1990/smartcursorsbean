USE [SmartCursorSTG]
GO
/****** Object:  UserDefinedTableType [dbo].[CreditNoteApplication]    Script Date: 16-12-2024 9.33.40 PM ******/
CREATE TYPE [dbo].[CreditNoteApplication] AS TABLE(
	[Id] [uniqueidentifier] NULL,
	[InvoiceId] [uniqueidentifier] NULL,
	[CompanyId] [bigint] NULL,
	[CreditNoteApplicationDate] [datetime2](7) NULL,
	[CreditNoteApplicationResetDate] [datetime2](7) NULL,
	[CreditAmount] [money] NULL,
	[Remarks] [nvarchar](256) NULL,
	[CreditNoteApplicationNumber] [nvarchar](100) NULL,
	[UserCreated] [nvarchar](256) NULL,
	[CreatedDate] [datetime2](7) NULL,
	[ModifiedBy] [nvarchar](256) NULL,
	[ModifiedDate] [datetime2](7) NULL,
	[Status] [int] NULL,
	[ExchangeRate] [decimal](15, 10) NULL,
	[IsRevExcess] [bit] NULL,
	[DocumentId] [uniqueidentifier] NULL
)
GO
