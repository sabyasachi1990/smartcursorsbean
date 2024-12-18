USE [SmartCursorSTG]
GO
/****** Object:  Table [Bean].[Bill]    Script Date: 16-12-2024 9.30.55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Bean].[Bill](
	[Id] [uniqueidentifier] NOT NULL,
	[CompanyId] [bigint] NOT NULL,
	[DocSubType] [nvarchar](20) NOT NULL,
	[SystemReferenceNumber] [nvarchar](50) NOT NULL,
	[PostingDate] [datetime] NOT NULL,
	[DocumentDate] [datetime] NOT NULL,
	[DueDate] [datetime] NOT NULL,
	[DocNo] [nvarchar](25) NOT NULL,
	[ServiceCompanyId] [bigint] NOT NULL,
	[NoSupportingDocument] [bit] NULL,
	[DocumentState] [nvarchar](20) NOT NULL,
	[EntityId] [uniqueidentifier] NOT NULL,
	[EntityType] [nvarchar](50) NOT NULL,
	[CreditTermsId] [bigint] NULL,
	[CreditTermValue] [int] NOT NULL,
	[Nature] [nvarchar](10) NOT NULL,
	[DocCurrency] [nvarchar](5) NOT NULL,
	[ExchangeRate] [decimal](15, 10) NULL,
	[BaseCurrency] [nvarchar](5) NULL,
	[ExDurationFrom] [datetime2](7) NULL,
	[ExDurationTo] [datetime2](7) NULL,
	[SegmentCategory1] [nvarchar](50) NULL,
	[SegmentCategory2] [nvarchar](50) NULL,
	[SegmentMasterid1] [bigint] NULL,
	[SegmentMasterid2] [bigint] NULL,
	[SegmentDetailid1] [bigint] NULL,
	[SegmentDetailid2] [bigint] NULL,
	[GSTExchangeRate] [decimal](15, 10) NULL,
	[GSTExCurrency] [nvarchar](5) NULL,
	[GSTExDurationFrom] [datetime2](7) NULL,
	[GSTExDurationTo] [datetime2](7) NULL,
	[GSTTotalAmount] [money] NOT NULL,
	[GrandTotal] [money] NOT NULL,
	[IsNoSupportingDocument] [bit] NOT NULL,
	[IsGstSettings] [bit] NOT NULL,
	[IsMultiCurrency] [bit] NOT NULL,
	[IsSegmentReporting] [bit] NOT NULL,
	[IsAllowableDisallowable] [bit] NOT NULL,
	[IsGSTCurrencyRateChanged] [bit] NOT NULL,
	[IsBaseCurrencyRateChanged] [bit] NULL,
	[Remarks] [nvarchar](1000) NULL,
	[UserCreated] [nvarchar](254) NULL,
	[CreatedDate] [datetime2](7) NULL,
	[ModifiedBy] [nvarchar](254) NULL,
	[ModifiedDate] [datetime2](7) NULL,
	[Status] [int] NULL,
	[Vendortype] [nvarchar](20) NULL,
	[IsGSTApplied] [bit] NULL,
	[IsGSTDeRegistration] [bit] NULL,
	[GSTDeRegistrationDate] [datetime2](7) NULL,
	[BalanceAmount] [money] NULL,
	[DocDescription] [nvarchar](256) NULL,
	[PayrollId] [uniqueidentifier] NULL,
	[IsExternal] [bit] NULL,
	[DocType] [nvarchar](15) NULL,
	[OpeningBalanceId] [uniqueidentifier] NULL,
	[SyncHRPayrollId] [uniqueidentifier] NULL,
	[SyncHRPayrollStatus] [nvarchar](200) NULL,
	[SyncHRPayrollDate] [datetime2](7) NULL,
	[SyncHRPayrollRemarks] [nvarchar](max) NULL,
	[Version] [timestamp] NOT NULL,
	[BaseGrandTotal] [money] NULL,
	[BaseBalanceAmount] [money] NULL,
	[RoundingAmount] [money] NULL,
	[ClearCount] [int] NULL,
	[IsLocked] [bit] NULL,
	[PeppolDocumentId] [uniqueidentifier] NULL,
 CONSTRAINT [PK_Bill] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [Bean].[Bill] ADD  DEFAULT ((1)) FOR [Status]
GO
ALTER TABLE [Bean].[Bill] ADD  DEFAULT ((0)) FOR [IsGSTDeRegistration]
GO
ALTER TABLE [Bean].[Bill]  WITH CHECK ADD  CONSTRAINT [FK_Bill_Company] FOREIGN KEY([CompanyId])
REFERENCES [Common].[Company] ([Id])
GO
ALTER TABLE [Bean].[Bill] CHECK CONSTRAINT [FK_Bill_Company]
GO
ALTER TABLE [Bean].[Bill]  WITH CHECK ADD  CONSTRAINT [FK_Bill_CreditTerm] FOREIGN KEY([CreditTermsId])
REFERENCES [Common].[TermsOfPayment] ([Id])
GO
ALTER TABLE [Bean].[Bill] CHECK CONSTRAINT [FK_Bill_CreditTerm]
GO
ALTER TABLE [Bean].[Bill]  WITH CHECK ADD  CONSTRAINT [FK_Bill_Entity] FOREIGN KEY([EntityId])
REFERENCES [Bean].[Entity] ([Id])
GO
ALTER TABLE [Bean].[Bill] CHECK CONSTRAINT [FK_Bill_Entity]
GO
