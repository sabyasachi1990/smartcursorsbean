USE [SmartCursorSTG]
GO
/****** Object:  Table [Tax].[SectionA]    Script Date: 16-12-2024 9.30.57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Tax].[SectionA](
	[Id] [uniqueidentifier] NOT NULL,
	[EngagementId] [uniqueidentifier] NOT NULL,
	[TaxCompanyId] [uniqueidentifier] NOT NULL,
	[CompanyId] [bigint] NOT NULL,
	[AssetDecription] [nvarchar](256) NULL,
	[YearOfPurchase] [int] NULL,
	[DateOfPurchase] [datetime2](7) NULL,
	[AssetClassification] [nvarchar](100) NULL,
	[TypeOfClaim] [nvarchar](100) NULL,
	[TypeOfPurchase] [nvarchar](100) NULL,
	[CostOfAsset] [decimal](17, 2) NULL,
	[OutStandingTaxLife] [int] NULL,
	[TWDVBroughtForward] [decimal](17, 2) NULL,
	[AutoComputeBySystem] [bit] NULL,
	[IsPartialdisposal] [bit] NULL,
	[IsExist] [bit] NULL,
	[IsPICQualified] [bit] NULL,
	[PICCashPayout] [nvarchar](20) NULL,
	[GrantAmount] [decimal](17, 2) NULL,
	[NetCostofAsset] [decimal](17, 2) NULL,
	[UserCreated] [nvarchar](100) NULL,
	[CreatedDate] [datetime2](7) NULL,
	[ModifiedBy] [nvarchar](100) NULL,
	[ModifiedDate] [datetime2](7) NULL,
	[Recorder] [int] NULL,
	[Status] [int] NOT NULL,
	[ClaimFormat] [nvarchar](20) NULL,
	[TWDVCarryForward] [decimal](17, 2) NULL,
	[CapitalAllowanceId] [uniqueidentifier] NULL,
	[PICUnder] [nvarchar](100) NULL,
	[PICId] [uniqueidentifier] NULL,
	[Years] [nvarchar](256) NULL,
	[EnhancedNetCostofAsset] [decimal](15, 0) NULL,
	[Enhancedpercentage] [int] NULL,
	[IsRollForward] [bit] NULL,
	[PandLId] [uniqueidentifier] NULL,
	[SplitId] [uniqueidentifier] NULL,
	[IntialAllowance] [decimal](17, 2) NULL,
 CONSTRAINT [PK_SECTIONA] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ADD SENSITIVITY CLASSIFICATION TO [Tax].[SectionA].[OutStandingTaxLife] WITH (label = 'Confidential', label_id = '281b9ab3-ecbb-4a57-8486-c702e44215d8', information_type = 'Financial', information_type_id = 'c44193e1-0e58-4b2a-9001-f7d6e7bc1373', rank = Medium);
GO
ADD SENSITIVITY CLASSIFICATION TO [Tax].[SectionA].[GrantAmount] WITH (label = 'Confidential', label_id = '281b9ab3-ecbb-4a57-8486-c702e44215d8', information_type = 'Financial', information_type_id = 'c44193e1-0e58-4b2a-9001-f7d6e7bc1373', rank = Medium);
GO
ALTER TABLE [Tax].[SectionA]  WITH CHECK ADD  CONSTRAINT [FK_SectionA_CapitalAllowanceId] FOREIGN KEY([CapitalAllowanceId])
REFERENCES [Tax].[CapitalAllowance] ([Id])
GO
ALTER TABLE [Tax].[SectionA] CHECK CONSTRAINT [FK_SectionA_CapitalAllowanceId]
GO
ALTER TABLE [Tax].[SectionA]  WITH CHECK ADD  CONSTRAINT [FK_SECTIONA_Company] FOREIGN KEY([CompanyId])
REFERENCES [Common].[Company] ([Id])
GO
ALTER TABLE [Tax].[SectionA] CHECK CONSTRAINT [FK_SECTIONA_Company]
GO
ALTER TABLE [Tax].[SectionA]  WITH CHECK ADD  CONSTRAINT [FK_SECTIONA_TaxCompany] FOREIGN KEY([TaxCompanyId])
REFERENCES [Tax].[TaxCompany] ([Id])
GO
ALTER TABLE [Tax].[SectionA] CHECK CONSTRAINT [FK_SECTIONA_TaxCompany]
GO
ALTER TABLE [Tax].[SectionA]  WITH CHECK ADD  CONSTRAINT [FK_SECTIONA_TaxCompanyEngagement] FOREIGN KEY([EngagementId])
REFERENCES [Tax].[TaxCompanyEngagement] ([Id])
GO
ALTER TABLE [Tax].[SectionA] CHECK CONSTRAINT [FK_SECTIONA_TaxCompanyEngagement]
GO
