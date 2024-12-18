USE [SmartCursorSTG]
GO
/****** Object:  Table [Bean].[DocumentHistory]    Script Date: 16-12-2024 9.30.55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Bean].[DocumentHistory](
	[Id] [uniqueidentifier] NOT NULL,
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
	[StateChangedDate] [datetime2](7) NULL,
	[Remarks] [nvarchar](500) NULL,
	[PostingDate] [datetime2](7) NULL,
	[DocAppliedAmount] [money] NULL,
	[BaseAppliedAmount] [money] NULL,
	[AgingState] [nvarchar](50) NULL
) ON [PRIMARY]
GO
ALTER TABLE [Bean].[DocumentHistory]  WITH CHECK ADD  CONSTRAINT [FK_DocHistory_Company] FOREIGN KEY([CompanyId])
REFERENCES [Common].[Company] ([Id])
GO
ALTER TABLE [Bean].[DocumentHistory] CHECK CONSTRAINT [FK_DocHistory_Company]
GO
