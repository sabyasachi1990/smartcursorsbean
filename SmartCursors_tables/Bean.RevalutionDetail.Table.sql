USE [SmartCursorSTG]
GO
/****** Object:  Table [Bean].[RevalutionDetail]    Script Date: 16-12-2024 9.30.55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Bean].[RevalutionDetail](
	[Id] [uniqueidentifier] NOT NULL,
	[RevalutionId] [uniqueidentifier] NOT NULL,
	[COAId] [bigint] NULL,
	[EntityId] [uniqueidentifier] NULL,
	[SystemReferenceNumber] [nvarchar](100) NULL,
	[DocumentType] [nvarchar](100) NULL,
	[DocumentSubType] [nvarchar](100) NULL,
	[DocumentNumber] [nvarchar](100) NULL,
	[DocumentDescription] [nvarchar](254) NULL,
	[SegmentCategory1] [nvarchar](100) NULL,
	[SegmentCategory2] [nvarchar](100) NULL,
	[DocumentDate] [datetime2](7) NULL,
	[DocId] [uniqueidentifier] NULL,
	[ExchangerateOld] [decimal](15, 10) NULL,
	[ExchangerateNew] [decimal](15, 10) NULL,
	[BaseCurrency] [nvarchar](5) NULL,
	[DocCurrency] [nvarchar](5) NULL,
	[DocCurrencyAmount] [money] NULL,
	[BaseCurrencyAmount1] [money] NULL,
	[BaseCurrencyAmount2] [money] NULL,
	[UnrealisedExchangegainorlose] [money] NULL,
	[UserCreated] [nvarchar](254) NULL,
	[CreatedDate] [datetime2](7) NULL,
	[PostingDate] [datetime2](7) NULL,
	[Status] [int] NULL,
	[DueDate] [datetime2](7) NULL,
	[DocBal] [money] NULL,
	[ServiceEntityId] [bigint] NULL,
	[IsChecked] [bit] NULL,
	[RecOrder] [int] NULL,
	[IsBankData] [bit] NULL,
 CONSTRAINT [PK_RevalutionDetail] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Bean].[RevalutionDetail]  WITH CHECK ADD  CONSTRAINT [FK_RevalutionDetail_Revalution] FOREIGN KEY([RevalutionId])
REFERENCES [Bean].[Revalution] ([Id])
GO
ALTER TABLE [Bean].[RevalutionDetail] CHECK CONSTRAINT [FK_RevalutionDetail_Revalution]
GO
