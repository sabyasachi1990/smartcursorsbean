USE [SmartCursorSTG]
GO
/****** Object:  Table [Bean].[WithDrawal]    Script Date: 16-12-2024 9.30.55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Bean].[WithDrawal](
	[Id] [uniqueidentifier] NOT NULL,
	[CompanyId] [bigint] NOT NULL,
	[DocType] [nvarchar](20) NOT NULL,
	[SystemRefNo] [nvarchar](50) NOT NULL,
	[DocDate] [datetime2](7) NULL,
	[BankClearingDate] [datetime2](7) NULL,
	[DocNo] [nvarchar](25) NULL,
	[EntityType] [nvarchar](25) NULL,
	[EntityId] [uniqueidentifier] NULL,
	[COAId] [bigint] NOT NULL,
	[DocCurrency] [nvarchar](5) NOT NULL,
	[ServiceCompanyId] [bigint] NOT NULL,
	[SegmentCategory1] [nvarchar](50) NULL,
	[SegmentCategory2] [nvarchar](50) NULL,
	[IsNoSupportingDocumentActivated] [bit] NULL,
	[NoSupportingDocs] [bit] NULL,
	[ModeOfWithDrawal] [nvarchar](20) NOT NULL,
	[WithDrawalRefNo] [nvarchar](50) NULL,
	[BankWithDrawalAmmount] [money] NOT NULL,
	[BankCharges] [money] NULL,
	[ExchangeRate] [decimal](15, 10) NULL,
	[ExCurrency] [nvarchar](5) NULL,
	[ExDurationFrom] [datetime2](7) NULL,
	[ExDurationTo] [datetime2](7) NULL,
	[IsGstSettingsActivated] [bit] NOT NULL,
	[IsMultiCurrencyActivated] [bit] NOT NULL,
	[IsAllowableNonAllowableActivated] [bit] NOT NULL,
	[IsSegmentReportingActivated] [bit] NOT NULL,
	[SegmentMasterid1] [bigint] NULL,
	[SegmentMasterid2] [bigint] NULL,
	[SegmentDetailid1] [bigint] NULL,
	[SegmentDetailid2] [bigint] NULL,
	[GSTExchangeRate] [decimal](15, 10) NULL,
	[GSTExCurrency] [nvarchar](5) NULL,
	[GSTExDurationFrom] [datetime2](7) NULL,
	[GSTExDurationTo] [datetime2](7) NULL,
	[GSTTotalAmount] [money] NULL,
	[GrandTotal] [money] NOT NULL,
	[DocumentState] [nvarchar](20) NULL,
	[Remarks] [nvarchar](1000) NULL,
	[UserCreated] [nvarchar](254) NULL,
	[CreatedDate] [datetime2](7) NULL,
	[ModifiedBy] [nvarchar](254) NULL,
	[ModifiedDate] [datetime2](7) NULL,
	[Status] [int] NULL,
	[IsDisAllow] [bit] NULL,
	[RecOrder] [int] NULL,
	[DocDescription] [nvarchar](253) NULL,
	[IsBaseCurrencyRateChanged] [bit] NULL,
	[IsGSTCurrencyRateChanged] [bit] NULL,
	[Version] [timestamp] NOT NULL,
	[IsLocked] [bit] NULL,
 CONSTRAINT [PK_WithDrawal] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ADD SENSITIVITY CLASSIFICATION TO [Bean].[WithDrawal].[DocCurrency] WITH (label = 'Confidential', label_id = '281b9ab3-ecbb-4a57-8486-c702e44215d8', information_type = 'Financial', information_type_id = 'c44193e1-0e58-4b2a-9001-f7d6e7bc1373', rank = Medium);
GO
ADD SENSITIVITY CLASSIFICATION TO [Bean].[WithDrawal].[ExCurrency] WITH (label = 'Confidential', label_id = '281b9ab3-ecbb-4a57-8486-c702e44215d8', information_type = 'Financial', information_type_id = 'c44193e1-0e58-4b2a-9001-f7d6e7bc1373', rank = Medium);
GO
ADD SENSITIVITY CLASSIFICATION TO [Bean].[WithDrawal].[GSTExCurrency] WITH (label = 'Confidential', label_id = '281b9ab3-ecbb-4a57-8486-c702e44215d8', information_type = 'Financial', information_type_id = 'c44193e1-0e58-4b2a-9001-f7d6e7bc1373', rank = Medium);
GO
ADD SENSITIVITY CLASSIFICATION TO [Bean].[WithDrawal].[GSTTotalAmount] WITH (label = 'Confidential', label_id = '281b9ab3-ecbb-4a57-8486-c702e44215d8', information_type = 'Financial', information_type_id = 'c44193e1-0e58-4b2a-9001-f7d6e7bc1373', rank = Medium);
GO
ALTER TABLE [Bean].[WithDrawal] ADD  DEFAULT ((1)) FOR [Status]
GO
ALTER TABLE [Bean].[WithDrawal] ADD  DEFAULT (NULL) FOR [RecOrder]
GO
ALTER TABLE [Bean].[WithDrawal]  WITH CHECK ADD  CONSTRAINT [FK_WithDrawal_ChartOfAccount] FOREIGN KEY([COAId])
REFERENCES [Bean].[ChartOfAccount] ([Id])
GO
ALTER TABLE [Bean].[WithDrawal] CHECK CONSTRAINT [FK_WithDrawal_ChartOfAccount]
GO
ALTER TABLE [Bean].[WithDrawal]  WITH CHECK ADD  CONSTRAINT [FK_WithDrawal_Company] FOREIGN KEY([CompanyId])
REFERENCES [Common].[Company] ([Id])
GO
ALTER TABLE [Bean].[WithDrawal] CHECK CONSTRAINT [FK_WithDrawal_Company]
GO
