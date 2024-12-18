USE [SmartCursorSTG]
GO
/****** Object:  Table [dbo].[ImportEntities]    Script Date: 16-12-2024 9.30.56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ImportEntities](
	[ID] [uniqueidentifier] NOT NULL,
	[TransactionId] [uniqueidentifier] NOT NULL,
	[EntityName] [nvarchar](2000) NOT NULL,
	[EntityType] [nvarchar](2000) NULL,
	[EntityIdentificationType] [nvarchar](2000) NULL,
	[EntityIdentificationNumber] [nvarchar](2000) NULL,
	[GSTRegistrationNumber] [nvarchar](2000) NULL,
	[Customer] [bit] NULL,
	[CreditTerms] [nvarchar](2000) NULL,
	[CreditLimit] [nvarchar](2000) NULL,
	[CustNature] [nvarchar](2000) NULL,
	[CustCurrency] [nvarchar](2000) NULL,
	[Vendor] [bit] NULL,
	[PaymentTerms] [nvarchar](2000) NULL,
	[VendorType] [nvarchar](2000) NULL,
	[VenNature] [nvarchar](2000) NULL,
	[VenCurrency] [nvarchar](2000) NULL,
	[DefaultCOA] [nvarchar](2000) NULL,
	[DefaultTaxCode] [nvarchar](2000) NULL,
	[Email] [nvarchar](2000) NULL,
	[Phone] [nvarchar](2000) NULL,
	[LocalAddress] [nvarchar](4000) NULL,
	[ForeignAddress] [nvarchar](4000) NULL,
	[ErrorRemarks] [nvarchar](max) NULL,
	[ImportStatus] [bit] NULL,
 CONSTRAINT [Pk_Entities] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
