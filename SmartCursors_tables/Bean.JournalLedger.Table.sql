USE [SmartCursorSTG]
GO
/****** Object:  Table [Bean].[JournalLedger]    Script Date: 16-12-2024 9.30.55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Bean].[JournalLedger](
	[Id] [uniqueidentifier] NOT NULL,
	[CompanyId] [bigint] NOT NULL,
	[PostingDate] [datetime] NULL,
	[SystemReferenceNumber] [nvarchar](50) NULL,
	[DocType] [nvarchar](50) NULL,
	[DocSubType] [nvarchar](20) NULL,
	[ServiceCompany] [nvarchar](5) NULL,
	[ServiceId] [bigint] NULL,
	[Nature] [nvarchar](100) NULL,
	[DocNo] [nvarchar](25) NULL,
	[DocDate] [datetime] NULL,
	[PONo] [nvarchar](20) NULL,
	[CreditTerms] [int] NULL,
	[DueDate] [datetime] NULL,
	[SegmentCategory1] [nvarchar](50) NULL,
	[SegmentCategory2] [nvarchar](50) NULL,
	[NoSupportingDocs] [bit] NULL,
	[EntityType] [nvarchar](50) NULL,
	[EntityId] [uniqueidentifier] NULL,
	[EntityRefNo] [nvarchar](25) NULL,
	[EntityName] [nvarchar](100) NULL,
	[AccountCode] [nvarchar](100) NULL,
	[AccountName] [nvarchar](100) NULL,
	[ItemCode] [nvarchar](30) NULL,
	[ItemDescription] [nvarchar](200) NULL,
	[Qty] [float] NULL,
	[ItemId] [uniqueidentifier] NULL,
	[Unit] [nvarchar](20) NULL,
	[UnitPrice] [money] NULL,
	[DiscountType] [nvarchar](1) NULL,
	[Discount] [float] NULL,
	[AllowDisAllow] [bit] NULL,
	[COAId] [bigint] NULL,
	[TaxCode] [nvarchar](20) NULL,
	[TaxRate] [float] NULL,
	[TaxType] [nvarchar](20) NULL,
	[DocCurrency] [nvarchar](5) NULL,
	[DebitDC] [money] NULL,
	[CreditDC] [money] NULL,
	[TaxableamountDC] [money] NULL,
	[TaxAmountDC] [money] NULL,
	[BaseCurrency] [nvarchar](5) NULL,
	[ExchangeRateBc] [money] NULL,
	[DebitBC] [money] NULL,
	[CreditBC] [money] NULL,
	[TaxableamountBC] [money] NULL,
	[TaxAmountBC] [money] NULL,
	[GSTReportingCurrency] [nvarchar](5) NULL,
	[ExchangeRateGSTR] [money] NULL,
	[DebitGSTR] [money] NULL,
	[CreditGSTR] [money] NULL,
	[TaxableamountGSTR] [money] NULL,
	[TaxAmountGSTR] [money] NULL,
	[Subledgerrequired] [bit] NULL,
	[SettlementMode] [nvarchar](20) NULL,
	[SettlementRefNO] [int] NULL,
	[SettlementDate] [datetime2](7) NULL,
	[OffsetDocument] [nvarchar](25) NULL,
	[Cleared] [bit] NULL,
	[ClearingDate] [datetime2](7) NULL,
	[BankRecon] [bit] NULL,
	[Reversed] [nvarchar](5) NULL,
	[ReversalDocRef] [nvarchar](25) NULL,
	[ReversalDate] [datetime2](7) NULL,
	[DocumentState] [nvarchar](25) NULL,
	[DocumentStateDT] [datetime2](7) NULL,
	[Remarks] [nvarchar](1000) NULL,
	[UserCreated] [nvarchar](254) NULL,
	[CreatedDate] [datetime2](7) NULL,
	[ModifiedBy] [nvarchar](254) NULL,
	[ModifiedDate] [datetime2](7) NULL,
	[Version] [smallint] NULL,
	[Status] [int] NULL,
	[ServiceCompanyId] [bigint] NULL,
	[RecOrder] [int] NULL,
 CONSTRAINT [PK_JournalEntry] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Bean].[JournalLedger] ADD  DEFAULT ((1)) FOR [Status]
GO
ALTER TABLE [Bean].[JournalLedger]  WITH CHECK ADD  CONSTRAINT [FK_JournalEntry_ChartOfAccount] FOREIGN KEY([COAId])
REFERENCES [Bean].[ChartOfAccount] ([Id])
GO
ALTER TABLE [Bean].[JournalLedger] CHECK CONSTRAINT [FK_JournalEntry_ChartOfAccount]
GO
ALTER TABLE [Bean].[JournalLedger]  WITH CHECK ADD  CONSTRAINT [FK_JournalEntry_Company] FOREIGN KEY([CompanyId])
REFERENCES [Common].[Company] ([Id])
GO
ALTER TABLE [Bean].[JournalLedger] CHECK CONSTRAINT [FK_JournalEntry_Company]
GO
ALTER TABLE [Bean].[JournalLedger]  WITH CHECK ADD  CONSTRAINT [FK_JournalEntry_Entity] FOREIGN KEY([EntityId])
REFERENCES [Bean].[Entity] ([Id])
GO
ALTER TABLE [Bean].[JournalLedger] CHECK CONSTRAINT [FK_JournalEntry_Entity]
GO
ALTER TABLE [Bean].[JournalLedger]  WITH CHECK ADD  CONSTRAINT [FK_JournalEntry_Item] FOREIGN KEY([ItemId])
REFERENCES [Bean].[Item] ([Id])
GO
ALTER TABLE [Bean].[JournalLedger] CHECK CONSTRAINT [FK_JournalEntry_Item]
GO
ALTER TABLE [Bean].[JournalLedger]  WITH CHECK ADD  CONSTRAINT [FK_JournalEntry_Service] FOREIGN KEY([ServiceId])
REFERENCES [Common].[Service] ([Id])
GO
ALTER TABLE [Bean].[JournalLedger] CHECK CONSTRAINT [FK_JournalEntry_Service]
GO
