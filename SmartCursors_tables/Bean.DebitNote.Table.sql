USE [SmartCursorSTG]
GO
/****** Object:  Table [Bean].[DebitNote]    Script Date: 16-12-2024 9.30.55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Bean].[DebitNote](
	[Id] [uniqueidentifier] NOT NULL,
	[CompanyId] [bigint] NOT NULL,
	[EntityType] [nvarchar](50) NOT NULL,
	[EntityId] [uniqueidentifier] NOT NULL,
	[Nature] [nvarchar](10) NOT NULL,
	[DocDate] [datetime] NOT NULL,
	[CreditTermsId] [bigint] NOT NULL,
	[DueDate] [datetime] NOT NULL,
	[DocNo] [nvarchar](25) NOT NULL,
	[PONo] [nvarchar](20) NULL,
	[NoSupportingDocs] [bit] NULL,
	[DocCurrency] [nvarchar](5) NULL,
	[ExchangeRate] [decimal](15, 10) NULL,
	[ExCurrency] [nvarchar](5) NULL,
	[ExDurationFrom] [datetime2](7) NULL,
	[ExDurationTo] [datetime2](7) NULL,
	[SegmentCategory1] [nvarchar](50) NULL,
	[SegmentCategory2] [nvarchar](50) NULL,
	[GSTExchangeRate] [decimal](15, 10) NULL,
	[GSTExCurrency] [nvarchar](5) NULL,
	[GSTExDurationFrom] [datetime2](7) NULL,
	[GSTExDurationTo] [datetime2](7) NULL,
	[DocumentState] [nvarchar](20) NOT NULL,
	[GSTTotalAmount] [money] NOT NULL,
	[GrandTotal] [money] NOT NULL,
	[IsNoSupportingDocument] [bit] NOT NULL,
	[IsGstSettings] [bit] NOT NULL,
	[IsMultiCurrency] [bit] NOT NULL,
	[IsSegmentReporting] [bit] NOT NULL,
	[IsAllowableNonAllowable] [bit] NOT NULL,
	[Remarks] [nvarchar](1000) NULL,
	[UserCreated] [nvarchar](254) NULL,
	[CreatedDate] [datetime2](7) NULL,
	[ModifiedBy] [nvarchar](254) NULL,
	[ModifiedDate] [datetime2](7) NULL,
	[Status] [int] NULL,
	[ServiceCompanyId] [bigint] NULL,
	[DebitNoteNumber] [nvarchar](50) NULL,
	[DocSubType] [nvarchar](20) NULL,
	[NoSupportingDocument] [bit] NULL,
	[BalanceAmount] [money] NOT NULL,
	[AllocatedAmount] [decimal](18, 0) NULL,
	[SegmentMasterid1] [bigint] NULL,
	[SegmentMasterid2] [bigint] NULL,
	[SegmentDetailid1] [bigint] NULL,
	[SegmentDetailid2] [bigint] NULL,
	[IsBaseCurrencyRateChanged] [bit] NULL,
	[IsGSTCurrencyRateChanged] [bit] NULL,
	[IsGSTApplied] [bit] NULL,
	[Version] [timestamp] NOT NULL,
	[BaseGrandTotal] [money] NULL,
	[BaseBalanceAmount] [money] NULL,
	[RoundingAmount] [money] NULL,
	[IsLocked] [bit] NULL,
 CONSTRAINT [PK_DebitNote] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Bean].[DebitNote] ADD  DEFAULT ((1)) FOR [Status]
GO
ALTER TABLE [Bean].[DebitNote] ADD  DEFAULT ((0)) FOR [BalanceAmount]
GO
ALTER TABLE [Bean].[DebitNote] ADD  DEFAULT ((0)) FOR [AllocatedAmount]
GO
ALTER TABLE [Bean].[DebitNote]  WITH CHECK ADD  CONSTRAINT [FK_DebitNote_Company] FOREIGN KEY([CompanyId])
REFERENCES [Common].[Company] ([Id])
GO
ALTER TABLE [Bean].[DebitNote] CHECK CONSTRAINT [FK_DebitNote_Company]
GO
ALTER TABLE [Bean].[DebitNote]  WITH CHECK ADD  CONSTRAINT [FK_DebitNote_CreditTerm] FOREIGN KEY([CreditTermsId])
REFERENCES [Common].[TermsOfPayment] ([Id])
GO
ALTER TABLE [Bean].[DebitNote] CHECK CONSTRAINT [FK_DebitNote_CreditTerm]
GO
