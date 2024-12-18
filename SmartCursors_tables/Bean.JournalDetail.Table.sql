USE [SmartCursorSTG]
GO
/****** Object:  Table [Bean].[JournalDetail]    Script Date: 16-12-2024 9.30.55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Bean].[JournalDetail](
	[Id] [uniqueidentifier] NOT NULL,
	[JournalId] [uniqueidentifier] NOT NULL,
	[COAId] [bigint] NOT NULL,
	[AccountDescription] [nvarchar](254) NULL,
	[AllowDisAllow] [bit] NULL,
	[TaxId] [bigint] NULL,
	[TaxType] [nvarchar](20) NULL,
	[TaxRate] [float] NULL,
	[DocDebit] [money] NULL,
	[DocCredit] [money] NULL,
	[DocTaxDebit] [money] NULL,
	[DocTaxCredit] [money] NULL,
	[BaseDebit] [money] NULL,
	[BaseCredit] [money] NULL,
	[BaseTaxDebit] [money] NULL,
	[BaseTaxCredit] [money] NULL,
	[DocDebitTotal] [money] NOT NULL,
	[DocCreditTotal] [money] NOT NULL,
	[BaseDebitTotal] [money] NULL,
	[BaseCreditTotal] [money] NULL,
	[DocumentId] [uniqueidentifier] NULL,
	[DocumentDetailId] [uniqueidentifier] NULL,
	[ItemId] [uniqueidentifier] NULL,
	[ItemCode] [nvarchar](30) NULL,
	[ItemDescription] [nvarchar](200) NULL,
	[Qty] [float] NULL,
	[Unit] [nvarchar](20) NULL,
	[UnitPrice] [money] NULL,
	[DiscountType] [nvarchar](1) NULL,
	[Discount] [float] NULL,
	[DueDate] [datetime2](7) NULL,
	[DocumentAmount] [money] NULL,
	[AmountDue] [money] NULL,
	[Currency] [nvarchar](5) NULL,
	[AmountToAllocate] [money] NULL,
	[DocTaxableAmount] [money] NULL,
	[DocTaxAmount] [money] NULL,
	[BaseTaxableAmount] [money] NULL,
	[BaseTaxAmount] [money] NULL,
	[BaseCurrency] [nvarchar](5) NULL,
	[ExchangeRate] [decimal](15, 10) NULL,
	[GSTExCurrency] [nvarchar](5) NULL,
	[GSTExchangeRate] [decimal](15, 10) NULL,
	[DocType] [nvarchar](50) NULL,
	[DocSubType] [nvarchar](20) NULL,
	[ServiceCompanyId] [bigint] NULL,
	[DocNo] [nvarchar](25) NULL,
	[Nature] [nvarchar](100) NULL,
	[OffsetDocument] [nvarchar](25) NULL,
	[IsTax] [bit] NULL,
	[EntityId] [uniqueidentifier] NULL,
	[SettlementMode] [nvarchar](25) NULL,
	[SettlementRefNo] [nvarchar](25) NULL,
	[SettlementDate] [datetime2](7) NULL,
	[SystemRefNo] [nvarchar](50) NULL,
	[Remarks] [nvarchar](1000) NULL,
	[PONo] [nvarchar](50) NULL,
	[CreditTermsId] [bigint] NULL,
	[SegmentMasterid1] [bigint] NULL,
	[SegmentMasterid2] [bigint] NULL,
	[SegmentDetailid1] [bigint] NULL,
	[SegmentDetailid2] [bigint] NULL,
	[NoSupportingDocs] [bit] NULL,
	[SegmentCategory1] [nvarchar](50) NULL,
	[SegmentCategory2] [nvarchar](50) NULL,
	[BaseAmount] [money] NULL,
	[DocCurrency] [nvarchar](5) NULL,
	[DocDate] [datetime2](7) NULL,
	[DocDescription] [nvarchar](254) NULL,
	[PostingDate] [datetime2](7) NULL,
	[RecieptType] [nvarchar](100) NULL,
	[GSTDebit] [money] NULL,
	[GSTCredit] [money] NULL,
	[GSTTaxableAmount] [decimal](18, 0) NULL,
	[GSTTaxAmount] [decimal](18, 0) NULL,
	[RecOrder] [int] NULL,
	[Type] [nvarchar](25) NULL,
	[ClearingDate] [datetime2](7) NULL,
	[ClearingStatus] [nvarchar](20) NULL,
	[IsBankReconcile] [bit] NULL,
	[IsPLAccount] [bit] NULL,
	[CorrAccountId] [bigint] NULL,
	[ClearingState] [nvarchar](50) NULL,
	[ReconciliationId] [uniqueidentifier] NULL,
	[ReconciliationDate] [datetime2](7) NULL,
	[GSTTaxDebit] [money] NULL,
	[GSTTaxCredit] [money] NULL,
 CONSTRAINT [PK_JournalDetail] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Bean].[JournalDetail]  WITH CHECK ADD  CONSTRAINT [FK_JournalDetail_Journal] FOREIGN KEY([JournalId])
REFERENCES [Bean].[Journal] ([Id])
GO
ALTER TABLE [Bean].[JournalDetail] CHECK CONSTRAINT [FK_JournalDetail_Journal]
GO
ALTER TABLE [Bean].[JournalDetail]  WITH CHECK ADD  CONSTRAINT [FK_JournalDetail_TaxCode] FOREIGN KEY([TaxId])
REFERENCES [Bean].[TaxCode] ([Id])
GO
ALTER TABLE [Bean].[JournalDetail] CHECK CONSTRAINT [FK_JournalDetail_TaxCode]
GO
