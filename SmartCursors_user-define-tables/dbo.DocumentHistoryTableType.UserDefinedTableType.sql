USE [SmartCursorSTG]
GO
/****** Object:  UserDefinedTableType [dbo].[DocumentHistoryTableType]    Script Date: 16-12-2024 9.33.40 PM ******/
CREATE TYPE [dbo].[DocumentHistoryTableType] AS TABLE(
	[TransactionId] [uniqueidentifier] NOT NULL,
	[CompanyId] [bigint] NOT NULL,
	[DocumentId] [uniqueidentifier] NULL,
	[DocType] [nvarchar](50) NULL,
	[DocSubType] [nvarchar](20) NULL,
	[DocState] [nvarchar](20) NULL,
	[DocCurrency] [nvarchar](10) NOT NULL,
	[DocAmount] [money] NOT NULL,
	[DocBalanaceAmount] [money] NOT NULL,
	[ExchangeRate] [decimal](15, 10) NULL,
	[BaseAmount] [money] NOT NULL,
	[BaseBalanaceAmount] [money] NOT NULL,
	[StateChangedBy] [nvarchar](508) NULL,
	[Remarks] [nvarchar](500) NULL,
	[PostingDate] [datetime2](7) NULL,
	[DocAppliedAmount] [money] NULL,
	[BaseAppliedAmount] [money] NULL,
	[AgingState] [bit] NULL
)
GO
