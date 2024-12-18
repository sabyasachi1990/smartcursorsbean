USE [SmartCursorSTG]
GO
/****** Object:  Table [Bean].[CreditMemo]    Script Date: 16-12-2024 9.30.55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Bean].[CreditMemo](
	[Id] [uniqueidentifier] NOT NULL,
	[CompanyId] [bigint] NOT NULL,
	[DocSubType] [nvarchar](20) NULL,
	[DocDate] [datetime] NOT NULL,
	[DueDate] [datetime] NULL,
	[DocNo] [nvarchar](25) NOT NULL,
	[PONo] [nvarchar](20) NULL,
	[NoSupportingDocs] [bit] NULL,
	[SegmentCategory1] [nvarchar](50) NULL,
	[SegmentCategory2] [nvarchar](50) NULL,
	[EntityType] [nvarchar](50) NOT NULL,
	[EntityId] [uniqueidentifier] NOT NULL,
	[CreditTermsId] [bigint] NULL,
	[Nature] [nvarchar](100) NULL,
	[DocCurrency] [nvarchar](5) NULL,
	[ExchangeRate] [decimal](15, 10) NULL,
	[ExCurrency] [nvarchar](5) NULL,
	[ExDurationFrom] [datetime2](7) NULL,
	[ExDurationTo] [datetime2](7) NULL,
	[PostingDate] [datetime2](2) NOT NULL,
	[GSTExchangeRate] [decimal](15, 10) NULL,
	[GSTExCurrency] [nvarchar](5) NULL,
	[GSTExDurationFrom] [datetime2](7) NULL,
	[GSTExDurationTo] [datetime2](7) NULL,
	[DocumentState] [nvarchar](20) NOT NULL,
	[BalanceAmount] [money] NOT NULL,
	[GSTTotalAmount] [money] NULL,
	[GrandTotal] [money] NOT NULL,
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
	[ParentInvoiceID] [uniqueidentifier] NULL,
	[CreditMemoNumber] [nvarchar](50) NULL,
	[IsNoSupportingDocument] [bit] NULL,
	[ServiceCompanyId] [bigint] NULL,
	[DocType] [nvarchar](50) NOT NULL,
	[IsAllowableDisallowableActivated] [bit] NULL,
	[ReverseDate] [datetime2](7) NULL,
	[ReverseIsSupportingDocument] [bit] NULL,
	[ReverseRemarks] [nvarchar](1000) NULL,
	[AllocatedAmount] [money] NULL,
	[SegmentMasterid1] [bigint] NULL,
	[SegmentMasterid2] [bigint] NULL,
	[SegmentDetailid1] [bigint] NULL,
	[SegmentDetailid2] [bigint] NULL,
	[IsBaseCurrencyRateChanged] [bit] NULL,
	[IsGSTCurrencyRateChanged] [bit] NULL,
	[IsGSTApplied] [bit] NULL,
	[ExtensionType] [nvarchar](20) NULL,
	[DocDescription] [nvarchar](256) NULL,
	[OpeningBalanceId] [uniqueidentifier] NULL,
	[Version] [timestamp] NOT NULL,
	[BaseGrandTotal] [money] NULL,
	[BaseBalanceAmount] [money] NULL,
	[RoundingAmount] [money] NULL,
	[ClearCount] [int] NULL,
	[IsLocked] [bit] NULL,
 CONSTRAINT [PK_CreditMemo] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Bean].[CreditMemo] ADD  DEFAULT ('Final') FOR [DocSubType]
GO
ALTER TABLE [Bean].[CreditMemo] ADD  DEFAULT ((1)) FOR [Status]
GO
ALTER TABLE [Bean].[CreditMemo]  WITH CHECK ADD  CONSTRAINT [FK_CreditMemo_Entity] FOREIGN KEY([EntityId])
REFERENCES [Bean].[Entity] ([Id])
GO
ALTER TABLE [Bean].[CreditMemo] CHECK CONSTRAINT [FK_CreditMemo_Entity]
GO
