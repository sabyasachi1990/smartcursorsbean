USE [SmartCursorSTG]
GO
/****** Object:  Table [License].[Package]    Script Date: 16-12-2024 9.30.57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [License].[Package](
	[Id] [uniqueidentifier] NOT NULL,
	[ProgramId] [uniqueidentifier] NOT NULL,
	[Name] [nvarchar](128) NOT NULL,
	[ChargeUnit] [nvarchar](50) NULL,
	[MonthlyPrice] [money] NOT NULL,
	[AnnualPrice] [money] NOT NULL,
	[PartnerMonthlyPrice] [money] NOT NULL,
	[PartnerAnnualPrice] [money] NOT NULL,
	[Status] [int] NOT NULL,
	[CssSprite] [nvarchar](500) NULL,
	[IsExternal] [bit] NOT NULL,
	[ExternalUrl] [nvarchar](2000) NULL,
	[Recorder] [int] NULL,
	[TooltipInfo] [nvarchar](max) NULL,
	[BillingFrequency] [nvarchar](max) NULL,
	[OneTimePrice] [money] NOT NULL,
	[QuantityValues] [nvarchar](200) NULL,
	[Country] [nvarchar](200) NULL,
	[CurrencyCode] [nvarchar](100) NULL,
	[price] [money] NULL,
	[MinValue] [int] NULL,
	[MaxValue] [int] NULL,
	[PartnerOnetimePrice] [money] NULL,
	[CreatedBy] [nvarchar](254) NULL,
	[CreatedDate] [datetime2](7) NULL,
	[ModifiedBy] [nvarchar](254) NULL,
	[ModifiedDate] [datetime2](7) NULL,
	[ExcludePackageIds] [nvarchar](1000) NULL,
	[DependantPackageIds] [nvarchar](1000) NULL,
	[IsDependantMasterCount] [bit] NULL,
	[IsAllowDuplicates] [bit] NULL,
	[IsMultiEntity] [bit] NULL,
	[IsRolesExits] [bit] NULL,
	[MonthlyPricePerAdditionalUser] [decimal](18, 2) NULL,
	[PartnerMonthlyPricePerAdditionalUser] [decimal](18, 0) NULL,
	[AnnualPricePerAdditionalUser] [decimal](18, 0) NULL,
	[PartnerAnnualPricePerAdditionalUser] [decimal](18, 0) NULL,
 CONSTRAINT [PK_Package] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [License].[Package]  WITH CHECK ADD  CONSTRAINT [FK_Package_Program] FOREIGN KEY([ProgramId])
REFERENCES [License].[Program] ([Id])
GO
ALTER TABLE [License].[Package] CHECK CONSTRAINT [FK_Package_Program]
GO
