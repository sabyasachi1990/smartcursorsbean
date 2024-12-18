USE [SmartCursorSTG]
GO
/****** Object:  Table [Bean].[TaxCode]    Script Date: 16-12-2024 9.30.55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Bean].[TaxCode](
	[Id] [bigint] NOT NULL,
	[CompanyId] [bigint] NOT NULL,
	[Code] [nvarchar](20) NOT NULL,
	[Name] [nvarchar](1000) NOT NULL,
	[Description] [nvarchar](1000) NOT NULL,
	[AppliesTo] [nvarchar](20) NULL,
	[TaxType] [nvarchar](20) NOT NULL,
	[TaxRate] [float] NULL,
	[EffectiveFrom] [datetime2](7) NOT NULL,
	[IsSystem] [bit] NOT NULL,
	[RecOrder] [int] NULL,
	[Remarks] [nvarchar](256) NULL,
	[UserCreated] [nvarchar](254) NULL,
	[CreatedDate] [datetime2](7) NULL,
	[ModifiedBy] [nvarchar](254) NULL,
	[ModifiedDate] [datetime2](7) NULL,
	[Version] [smallint] NULL,
	[Status] [int] NULL,
	[TaxRateFormula] [nvarchar](20) NULL,
	[IsApplicable] [bit] NULL,
	[EffectiveTo] [datetime2](7) NULL,
	[XeroTaxName] [nvarchar](500) NULL,
	[XeroTaxType] [nvarchar](500) NULL,
	[XeroTaxComponentName] [nvarchar](500) NULL,
	[XeroTaxRate] [nvarchar](500) NULL,
	[IsFromXero] [bit] NULL,
	[IsSeedData] [bit] NULL,
	[Jurisdiction] [nvarchar](200) NULL,
 CONSTRAINT [PK_TaxCode] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Bean].[TaxCode] ADD  DEFAULT ((1)) FOR [Status]
GO
ALTER TABLE [Bean].[TaxCode] ADD  DEFAULT ((1)) FOR [IsApplicable]
GO
ALTER TABLE [Bean].[TaxCode]  WITH CHECK ADD  CONSTRAINT [FK_TaxCode_Company] FOREIGN KEY([CompanyId])
REFERENCES [Common].[Company] ([Id])
GO
ALTER TABLE [Bean].[TaxCode] CHECK CONSTRAINT [FK_TaxCode_Company]
GO
