USE [SmartCursorSTG]
GO
/****** Object:  Table [Bean].[Journal]    Script Date: 16-12-2024 9.30.55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Bean].[Journal](
	[Id] [uniqueidentifier] NOT NULL,
	[CompanyId] [bigint] NOT NULL,
	[DocDate] [datetime2](7) NULL,
	[DocType] [nvarchar](50) NULL,
	[DocSubType] [nvarchar](20) NULL,
	[DocNo] [nvarchar](100) NULL,
	[ServiceCompanyId] [bigint] NULL,
	[SystemReferenceNo] [nvarchar](50) NULL,
	[IsNoSupportingDocs] [bit] NULL,
	[NoSupportingDocument] [bit] NULL,
	[DocCurrency] [nvarchar](5) NULL,
	[SegmentCategory1] [nvarchar](50) NULL,
	[SegmentCategory2] [nvarchar](50) NULL,
	[IsSegmentReporting] [bit] NULL,
	[SegmentMasterid1] [bigint] NULL,
	[SegmentMasterid2] [bigint] NULL,
	[SegmentDetailid1] [bigint] NULL,
	[SegmentDetailid2] [bigint] NULL,
	[ExchangeRate] [decimal](15, 10) NULL,
	[ExCurrency] [nvarchar](5) NULL,
	[ExDurationFrom] [datetime2](7) NULL,
	[ExDurationTo] [datetime2](7) NULL,
	[GSTExchangeRate] [decimal](15, 10) NULL,
	[GSTExCurrency] [nvarchar](5) NULL,
	[GSTExDurationFrom] [datetime2](7) NULL,
	[GSTExDurationTo] [datetime2](7) NULL,
	[GSTTotalAmount] [money] NULL,
	[DocumentState] [nvarchar](20) NULL,
	[IsNoSupportingDocument] [bit] NULL,
	[IsGstSettings] [bit] NULL,
	[IsMultiCurrency] [bit] NULL,
	[IsAllowableNonAllowable] [bit] NULL,
	[IsBaseCurrencyRateChanged] [bit] NULL,
	[IsGSTCurrencyRateChanged] [bit] NULL,
	[Remarks] [nvarchar](1000) NULL,
	[UserCreated] [nvarchar](254) NULL,
	[CreatedDate] [datetime2](7) NULL,
	[ModifiedBy] [nvarchar](254) NULL,
	[ModifiedDate] [datetime2](7) NULL,
	[Status] [int] NULL,
	[DocumentDescription] [nvarchar](250) NULL,
	[IsRecurringJournal] [bit] NULL,
	[RecurringJournalName] [nvarchar](30) NULL,
	[FrequencyValue] [int] NULL,
	[FrequencyType] [nvarchar](15) NULL,
	[FrequencyEndDate] [datetime2](7) NULL,
	[IsAutoReversalJournal] [bit] NULL,
	[ReversalDate] [datetime2](7) NULL,
	[ReverseParentRefId] [uniqueidentifier] NULL,
	[ReverseChildRefId] [uniqueidentifier] NULL,
	[CreationType] [nvarchar](20) NULL,
	[GrandDocDebitTotal] [money] NULL,
	[GrandDocCreditTotal] [money] NULL,
	[GrandBaseDebitTotal] [money] NULL,
	[GrandBaseCreditTotal] [money] NULL,
	[IsCopy] [bit] NULL,
	[DueDate] [datetime2](7) NULL,
	[EntityId] [uniqueidentifier] NULL,
	[EntityType] [nvarchar](50) NULL,
	[PoNo] [nvarchar](50) NULL,
	[PostingDate] [datetime2](7) NULL,
	[IsGSTApplied] [bit] NULL,
	[IsGSTDeRegistration] [bit] NULL,
	[GSTDeRegistrationDate] [datetime2](7) NULL,
	[COAId] [bigint] NULL,
	[ModeOfReceipt] [nvarchar](20) NULL,
	[BankReceiptAmmountCurrency] [nvarchar](5) NULL,
	[BankReceiptAmmount] [money] NULL,
	[BankChargesCurrency] [nvarchar](5) NULL,
	[BankCharges] [money] NULL,
	[ExcessPaidByClient] [nvarchar](50) NULL,
	[ExcessPaidByClientCurrency] [nvarchar](5) NULL,
	[ExcessPaidByClientAmmount] [money] NULL,
	[BalancingItemReciveCRCurrency] [nvarchar](5) NULL,
	[BalancingItemReciveCRAmount] [money] NULL,
	[BalancingItemPayDRCurrency] [nvarchar](5) NULL,
	[BalancingItemPayDRAmount] [money] NULL,
	[ReceiptApplicationCurrency] [nvarchar](5) NULL,
	[ReceiptApplicationAmmount] [money] NULL,
	[DocumentId] [uniqueidentifier] NULL,
	[ClearingDate] [datetime2](7) NULL,
	[IsRepeatingInvoice] [bit] NULL,
	[RepEveryPeriodNo] [int] NULL,
	[RepEveryPeriod] [nvarchar](10) NULL,
	[EndDate] [datetime2](7) NULL,
	[CreditTermsId] [bigint] NULL,
	[Nature] [nvarchar](100) NULL,
	[BankClearingDate] [datetime2](7) NULL,
	[BalanceAmount] [money] NULL,
	[IsBalancing] [bit] NULL,
	[ISAllowDisAllow] [bit] NULL,
	[ReverseParentId] [uniqueidentifier] NULL,
	[LastPosted] [datetime2](7) NULL,
	[NextDue] [datetime2](7) NULL,
	[ClearingStatus] [nvarchar](20) NULL,
	[TransferRefNo] [nvarchar](50) NULL,
	[AllocatedAmount] [money] NULL,
	[IsWithdrawal] [bit] NULL,
	[IsShow] [bit] NULL,
	[IsBankReconcile] [bit] NULL,
	[ActualSysRefNo] [nvarchar](50) NULL,
	[RecurringJournalId] [uniqueidentifier] NULL,
	[Counter] [int] NULL,
	[IsPostChecked] [bit] NULL,
	[InternalState] [nvarchar](20) NULL,
	[RefNo] [nvarchar](100) NULL,
	[Version] [timestamp] NOT NULL,
	[IsAddNote] [bit] NULL,
	[IsLocked] [bit] NULL,
	[IsBaseCurrencyJV] [bit] NULL,
 CONSTRAINT [PK_Journal] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ADD SENSITIVITY CLASSIFICATION TO [Bean].[Journal].[DocCurrency] WITH (label = 'Confidential', label_id = '281b9ab3-ecbb-4a57-8486-c702e44215d8', information_type = 'Financial', information_type_id = 'c44193e1-0e58-4b2a-9001-f7d6e7bc1373', rank = Medium);
GO
ADD SENSITIVITY CLASSIFICATION TO [Bean].[Journal].[ExCurrency] WITH (label = 'Confidential', label_id = '281b9ab3-ecbb-4a57-8486-c702e44215d8', information_type = 'Financial', information_type_id = 'c44193e1-0e58-4b2a-9001-f7d6e7bc1373', rank = Medium);
GO
ADD SENSITIVITY CLASSIFICATION TO [Bean].[Journal].[GSTExCurrency] WITH (label = 'Confidential', label_id = '281b9ab3-ecbb-4a57-8486-c702e44215d8', information_type = 'Financial', information_type_id = 'c44193e1-0e58-4b2a-9001-f7d6e7bc1373', rank = Medium);
GO
ADD SENSITIVITY CLASSIFICATION TO [Bean].[Journal].[GSTTotalAmount] WITH (label = 'Confidential', label_id = '281b9ab3-ecbb-4a57-8486-c702e44215d8', information_type = 'Financial', information_type_id = 'c44193e1-0e58-4b2a-9001-f7d6e7bc1373', rank = Medium);
GO
ADD SENSITIVITY CLASSIFICATION TO [Bean].[Journal].[GrandDocDebitTotal] WITH (label = 'Confidential', label_id = '281b9ab3-ecbb-4a57-8486-c702e44215d8', information_type = 'Credit Card', information_type_id = 'd22fa6e9-5ee4-3bde-4c2b-a409604c4646', rank = Medium);
GO
ADD SENSITIVITY CLASSIFICATION TO [Bean].[Journal].[GrandDocCreditTotal] WITH (label = 'Confidential', label_id = '281b9ab3-ecbb-4a57-8486-c702e44215d8', information_type = 'Credit Card', information_type_id = 'd22fa6e9-5ee4-3bde-4c2b-a409604c4646', rank = Medium);
GO
ADD SENSITIVITY CLASSIFICATION TO [Bean].[Journal].[GrandBaseDebitTotal] WITH (label = 'Confidential', label_id = '281b9ab3-ecbb-4a57-8486-c702e44215d8', information_type = 'Credit Card', information_type_id = 'd22fa6e9-5ee4-3bde-4c2b-a409604c4646', rank = Medium);
GO
ADD SENSITIVITY CLASSIFICATION TO [Bean].[Journal].[GrandBaseCreditTotal] WITH (label = 'Confidential', label_id = '281b9ab3-ecbb-4a57-8486-c702e44215d8', information_type = 'Credit Card', information_type_id = 'd22fa6e9-5ee4-3bde-4c2b-a409604c4646', rank = Medium);
GO
ADD SENSITIVITY CLASSIFICATION TO [Bean].[Journal].[BankReceiptAmmountCurrency] WITH (label = 'Confidential', label_id = '281b9ab3-ecbb-4a57-8486-c702e44215d8', information_type = 'Financial', information_type_id = 'c44193e1-0e58-4b2a-9001-f7d6e7bc1373', rank = Medium);
GO
ADD SENSITIVITY CLASSIFICATION TO [Bean].[Journal].[BankChargesCurrency] WITH (label = 'Confidential', label_id = '281b9ab3-ecbb-4a57-8486-c702e44215d8', information_type = 'Financial', information_type_id = 'c44193e1-0e58-4b2a-9001-f7d6e7bc1373', rank = Medium);
GO
ADD SENSITIVITY CLASSIFICATION TO [Bean].[Journal].[ExcessPaidByClientCurrency] WITH (label = 'Confidential', label_id = '281b9ab3-ecbb-4a57-8486-c702e44215d8', information_type = 'Financial', information_type_id = 'c44193e1-0e58-4b2a-9001-f7d6e7bc1373', rank = Medium);
GO
ADD SENSITIVITY CLASSIFICATION TO [Bean].[Journal].[BalancingItemReciveCRCurrency] WITH (label = 'Confidential', label_id = '281b9ab3-ecbb-4a57-8486-c702e44215d8', information_type = 'Financial', information_type_id = 'c44193e1-0e58-4b2a-9001-f7d6e7bc1373', rank = Medium);
GO
ADD SENSITIVITY CLASSIFICATION TO [Bean].[Journal].[BalancingItemReciveCRAmount] WITH (label = 'Confidential', label_id = '281b9ab3-ecbb-4a57-8486-c702e44215d8', information_type = 'Financial', information_type_id = 'c44193e1-0e58-4b2a-9001-f7d6e7bc1373', rank = Medium);
GO
ADD SENSITIVITY CLASSIFICATION TO [Bean].[Journal].[BalancingItemPayDRCurrency] WITH (label = 'Confidential', label_id = '281b9ab3-ecbb-4a57-8486-c702e44215d8', information_type = 'Financial', information_type_id = 'c44193e1-0e58-4b2a-9001-f7d6e7bc1373', rank = Medium);
GO
ADD SENSITIVITY CLASSIFICATION TO [Bean].[Journal].[BalancingItemPayDRAmount] WITH (label = 'Confidential', label_id = '281b9ab3-ecbb-4a57-8486-c702e44215d8', information_type = 'Financial', information_type_id = 'c44193e1-0e58-4b2a-9001-f7d6e7bc1373', rank = Medium);
GO
ADD SENSITIVITY CLASSIFICATION TO [Bean].[Journal].[ReceiptApplicationCurrency] WITH (label = 'Confidential', label_id = '281b9ab3-ecbb-4a57-8486-c702e44215d8', information_type = 'Financial', information_type_id = 'c44193e1-0e58-4b2a-9001-f7d6e7bc1373', rank = Medium);
GO
ADD SENSITIVITY CLASSIFICATION TO [Bean].[Journal].[CreditTermsId] WITH (label = 'Confidential', label_id = '281b9ab3-ecbb-4a57-8486-c702e44215d8', information_type = 'Credit Card', information_type_id = 'd22fa6e9-5ee4-3bde-4c2b-a409604c4646', rank = Medium);
GO
ADD SENSITIVITY CLASSIFICATION TO [Bean].[Journal].[BalanceAmount] WITH (label = 'Confidential', label_id = '281b9ab3-ecbb-4a57-8486-c702e44215d8', information_type = 'Financial', information_type_id = 'c44193e1-0e58-4b2a-9001-f7d6e7bc1373', rank = Medium);
GO
ADD SENSITIVITY CLASSIFICATION TO [Bean].[Journal].[AllocatedAmount] WITH (label = 'Confidential', label_id = '281b9ab3-ecbb-4a57-8486-c702e44215d8', information_type = 'Financial', information_type_id = 'c44193e1-0e58-4b2a-9001-f7d6e7bc1373', rank = Medium);
GO
ALTER TABLE [Bean].[Journal] ADD  DEFAULT ('Manual') FOR [CreationType]
GO
ALTER TABLE [Bean].[Journal] ADD  DEFAULT ((0)) FOR [GrandDocDebitTotal]
GO
ALTER TABLE [Bean].[Journal] ADD  DEFAULT ((0)) FOR [GrandDocCreditTotal]
GO
ALTER TABLE [Bean].[Journal] ADD  DEFAULT ((0)) FOR [GrandBaseDebitTotal]
GO
ALTER TABLE [Bean].[Journal] ADD  DEFAULT ((0)) FOR [GrandBaseCreditTotal]
GO
ALTER TABLE [Bean].[Journal] ADD  DEFAULT ('FALSE') FOR [IsAddNote]
GO
ALTER TABLE [Bean].[Journal]  WITH CHECK ADD  CONSTRAINT [FK_Journal_Company] FOREIGN KEY([CompanyId])
REFERENCES [Common].[Company] ([Id])
GO
ALTER TABLE [Bean].[Journal] CHECK CONSTRAINT [FK_Journal_Company]
GO
