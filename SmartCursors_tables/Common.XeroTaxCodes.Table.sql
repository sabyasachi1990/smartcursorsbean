USE [SmartCursorSTG]
GO
/****** Object:  Table [Common].[XeroTaxCodes]    Script Date: 16-12-2024 9.30.56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Common].[XeroTaxCodes](
	[Id] [uniqueidentifier] NOT NULL,
	[CompanyId] [bigint] NOT NULL,
	[XeroTaxName] [nvarchar](500) NULL,
	[XeroTaxType] [nvarchar](100) NULL,
	[XeroTaxComponentName] [nvarchar](500) NULL,
	[XeroTaxRate] [nvarchar](100) NULL,
	[OrganisationId] [uniqueidentifier] NULL,
	[BeanTaxCodeId] [bigint] NULL,
	[UserCreated] [nvarchar](512) NULL,
	[CreatedDate] [datetime2](7) NULL,
	[ModifiedBy] [nvarchar](512) NULL,
	[ModifiedDate] [datetime2](7) NULL,
 CONSTRAINT [PK_XeroTaxCode] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Common].[XeroTaxCodes]  WITH CHECK ADD  CONSTRAINT [FK_XeroTaxCodeCompany] FOREIGN KEY([CompanyId])
REFERENCES [Common].[Company] ([Id])
GO
ALTER TABLE [Common].[XeroTaxCodes] CHECK CONSTRAINT [FK_XeroTaxCodeCompany]
GO
