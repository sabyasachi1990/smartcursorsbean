USE [SmartCursorSTG]
GO
/****** Object:  Table [ClientCursor].[Account]    Script Date: 16-12-2024 9.30.56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [ClientCursor].[Account](
	[Id] [uniqueidentifier] NOT NULL,
	[IsAccount] [bit] NULL,
	[AccountId] [nvarchar](100) NULL,
	[Name] [nvarchar](100) NOT NULL,
	[CompanyId] [bigint] NOT NULL,
	[AccountTypeId] [bigint] NULL,
	[AccountIdTypeId] [bigint] NULL,
	[AccountIdNo] [nvarchar](50) NULL,
	[AddressBookId] [uniqueidentifier] NULL,
	[IsLocal] [bit] NULL,
	[ResBlockHouseNo] [nvarchar](100) NULL,
	[ResStreet] [nvarchar](100) NULL,
	[ResUnitNo] [nvarchar](100) NULL,
	[ResBuildingEstate] [nvarchar](100) NULL,
	[ResCity] [nvarchar](256) NULL,
	[ResPostalCode] [nvarchar](10) NULL,
	[ResState] [nvarchar](256) NULL,
	[ResCountry] [nvarchar](256) NULL,
	[TermsOfPaymentId] [bigint] NULL,
	[Industry] [nvarchar](100) NULL,
	[Source] [nvarchar](100) NULL,
	[SourceId] [nvarchar](100) NULL,
	[SourceName] [nvarchar](100) NULL,
	[SourceRemarks] [nvarchar](100) NULL,
	[IncorporationDate] [datetime2](7) NULL,
	[FinancialYearEnd] [datetime2](7) NULL,
	[AccountIncharge] [nvarchar](1000) NULL,
	[IsAGMDocsReminders] [bit] NULL,
	[IsAGMReminders] [bit] NULL,
	[IsCorporateTaxReminders] [bit] NULL,
	[IsAuditReminders] [bit] NULL,
	[CountryOfIncorporation] [nvarchar](100) NULL,
	[AccountStatus] [nvarchar](20) NULL,
	[PrincipalActivities] [nvarchar](1000) NULL,
	[CompanySecretaryId] [uniqueidentifier] NULL,
	[ProfileStatus] [int] NULL,
	[Like] [int] NULL,
	[Rating] [int] NULL,
	[RecOrder] [int] NULL,
	[Remarks] [nvarchar](256) NULL,
	[UserCreated] [nvarchar](254) NULL,
	[CreatedDate] [datetime2](7) NULL,
	[ModifiedBy] [nvarchar](254) NULL,
	[ModifiedDate] [datetime2](7) NULL,
	[Version] [smallint] NULL,
	[Status] [int] NULL,
	[IsSameAsAbove] [bit] NULL,
	[IsFinalTax] [bit] NULL,
	[Communication] [nvarchar](1000) NULL,
	[ShowBatchListing] [bit] NULL,
	[BatchListingStatus] [nvarchar](20) NULL,
	[BatchListingDate] [datetime2](7) NULL,
	[ClientId] [uniqueidentifier] NULL,
	[SystemRefNo] [nvarchar](50) NULL,
	[StandardTemplateContent] [nvarchar](max) NULL,
	[entityid] [int] NULL,
	[StandardTemplateName] [nvarchar](100) NULL,
	[SystemAssociationCount] [int] NULL,
	[SyncEntityId] [uniqueidentifier] NULL,
	[SyncEntityStatus] [varchar](50) NULL,
	[SyncEntityRemarks] [nvarchar](max) NULL,
	[SyncEntityDate] [datetime2](7) NULL,
	[SyncClientId] [uniqueidentifier] NULL,
	[SyncClientStatus] [varchar](50) NULL,
	[SyncClientRemarks] [nvarchar](max) NULL,
	[SyncClientDate] [datetime2](7) NULL,
	[Reminders] [nvarchar](max) NULL,
	[IsListedCompany] [bit] NULL,
	[ACRAReporting] [nvarchar](1000) NULL,
	[Exchanges] [nvarchar](1000) NULL,
	[MarketIdentifierCode] [nvarchar](1000) NULL,
	[IndustryCode] [nvarchar](1000) NULL,
	[GroupName] [nvarchar](1000) NULL,
	[Code] [nvarchar](1000) NULL,
	[ReferralDate] [datetime2](7) NULL,
	[IsNameOfHolding] [nvarchar](max) NULL,
 CONSTRAINT [PK_Account] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ADD SENSITIVITY CLASSIFICATION TO [ClientCursor].[Account].[AccountId] WITH (label = 'Confidential', label_id = '281b9ab3-ecbb-4a57-8486-c702e44215d8', information_type = 'Financial', information_type_id = 'c44193e1-0e58-4b2a-9001-f7d6e7bc1373', rank = Medium);
GO
ADD SENSITIVITY CLASSIFICATION TO [ClientCursor].[Account].[AccountTypeId] WITH (label = 'Confidential', label_id = '281b9ab3-ecbb-4a57-8486-c702e44215d8', information_type = 'Financial', information_type_id = 'c44193e1-0e58-4b2a-9001-f7d6e7bc1373', rank = Medium);
GO
ADD SENSITIVITY CLASSIFICATION TO [ClientCursor].[Account].[AccountIdTypeId] WITH (label = 'Confidential', label_id = '281b9ab3-ecbb-4a57-8486-c702e44215d8', information_type = 'Financial', information_type_id = 'c44193e1-0e58-4b2a-9001-f7d6e7bc1373', rank = Medium);
GO
ADD SENSITIVITY CLASSIFICATION TO [ClientCursor].[Account].[AccountIdNo] WITH (label = 'Confidential', label_id = '281b9ab3-ecbb-4a57-8486-c702e44215d8', information_type = 'Financial', information_type_id = 'c44193e1-0e58-4b2a-9001-f7d6e7bc1373', rank = Medium);
GO
ADD SENSITIVITY CLASSIFICATION TO [ClientCursor].[Account].[ResStreet] WITH (label = 'Confidential', label_id = '281b9ab3-ecbb-4a57-8486-c702e44215d8', information_type = 'Contact Info', information_type_id = '5c503e21-22c6-81fa-620b-f369b8ec38d1', rank = Medium);
GO
ADD SENSITIVITY CLASSIFICATION TO [ClientCursor].[Account].[ResCity] WITH (label = 'Confidential', label_id = '281b9ab3-ecbb-4a57-8486-c702e44215d8', information_type = 'Contact Info', information_type_id = '5c503e21-22c6-81fa-620b-f369b8ec38d1', rank = Medium);
GO
ADD SENSITIVITY CLASSIFICATION TO [ClientCursor].[Account].[ResPostalCode] WITH (label = 'Confidential', label_id = '281b9ab3-ecbb-4a57-8486-c702e44215d8', information_type = 'Contact Info', information_type_id = '5c503e21-22c6-81fa-620b-f369b8ec38d1', rank = Medium);
GO
ADD SENSITIVITY CLASSIFICATION TO [ClientCursor].[Account].[TermsOfPaymentId] WITH (label = 'Confidential', label_id = '281b9ab3-ecbb-4a57-8486-c702e44215d8', information_type = 'Financial', information_type_id = 'c44193e1-0e58-4b2a-9001-f7d6e7bc1373', rank = Medium);
GO
ADD SENSITIVITY CLASSIFICATION TO [ClientCursor].[Account].[AccountIncharge] WITH (label = 'Confidential', label_id = '281b9ab3-ecbb-4a57-8486-c702e44215d8', information_type = 'Financial', information_type_id = 'c44193e1-0e58-4b2a-9001-f7d6e7bc1373', rank = Medium);
GO
ADD SENSITIVITY CLASSIFICATION TO [ClientCursor].[Account].[AccountStatus] WITH (label = 'Confidential', label_id = '281b9ab3-ecbb-4a57-8486-c702e44215d8', information_type = 'Financial', information_type_id = 'c44193e1-0e58-4b2a-9001-f7d6e7bc1373', rank = Medium);
GO
ALTER TABLE [ClientCursor].[Account] ADD  DEFAULT ((0)) FOR [IsAccount]
GO
ALTER TABLE [ClientCursor].[Account] ADD  DEFAULT ((1)) FOR [IsLocal]
GO
ALTER TABLE [ClientCursor].[Account] ADD  DEFAULT ((10)) FOR [ProfileStatus]
GO
ALTER TABLE [ClientCursor].[Account] ADD  DEFAULT ((1)) FOR [Status]
GO
ALTER TABLE [ClientCursor].[Account] ADD  DEFAULT ((0)) FOR [IsSameAsAbove]
GO
ALTER TABLE [ClientCursor].[Account] ADD  DEFAULT ((0)) FOR [IsFinalTax]
GO
ALTER TABLE [ClientCursor].[Account]  WITH CHECK ADD  CONSTRAINT [FK_Account_AccountType] FOREIGN KEY([AccountTypeId])
REFERENCES [Common].[AccountType] ([Id])
GO
ALTER TABLE [ClientCursor].[Account] CHECK CONSTRAINT [FK_Account_AccountType]
GO
ALTER TABLE [ClientCursor].[Account]  WITH CHECK ADD  CONSTRAINT [FK_Account_AddressBook] FOREIGN KEY([AddressBookId])
REFERENCES [Common].[AddressBook] ([Id])
GO
ALTER TABLE [ClientCursor].[Account] CHECK CONSTRAINT [FK_Account_AddressBook]
GO
ALTER TABLE [ClientCursor].[Account]  WITH CHECK ADD  CONSTRAINT [FK_Account_Company] FOREIGN KEY([CompanyId])
REFERENCES [Common].[Company] ([Id])
GO
ALTER TABLE [ClientCursor].[Account] CHECK CONSTRAINT [FK_Account_Company]
GO
ALTER TABLE [ClientCursor].[Account]  WITH CHECK ADD  CONSTRAINT [FK_Account_IdType] FOREIGN KEY([AccountIdTypeId])
REFERENCES [Common].[IdType] ([Id])
GO
ALTER TABLE [ClientCursor].[Account] CHECK CONSTRAINT [FK_Account_IdType]
GO
ALTER TABLE [ClientCursor].[Account]  WITH CHECK ADD  CONSTRAINT [FK_Account_TermsOfPayment] FOREIGN KEY([TermsOfPaymentId])
REFERENCES [Common].[TermsOfPayment] ([Id])
GO
ALTER TABLE [ClientCursor].[Account] CHECK CONSTRAINT [FK_Account_TermsOfPayment]
GO
ALTER TABLE [ClientCursor].[Account]  WITH CHECK ADD  CONSTRAINT [FK_Account_Vendor] FOREIGN KEY([CompanySecretaryId])
REFERENCES [ClientCursor].[Vendor] ([Id])
GO
ALTER TABLE [ClientCursor].[Account] CHECK CONSTRAINT [FK_Account_Vendor]
GO
