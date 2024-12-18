USE [SmartCursorSTG]
GO
/****** Object:  UserDefinedTableType [dbo].[DocumentType]    Script Date: 16-12-2024 9.33.40 PM ******/
CREATE TYPE [dbo].[DocumentType] AS TABLE(
	[Id] [uniqueidentifier] NULL,
	[CompanyId] [bigint] NOT NULL,
	[EntityId] [uniqueidentifier] NULL,
	[ServiceCompanyId] [bigint] NULL,
	[DocType] [nvarchar](50) NULL,
	[DocSubType] [nvarchar](20) NULL,
	[DocNo] [nvarchar](100) NULL,
	[DocumentState] [nvarchar](20) NULL,
	[DocCurrency] [nvarchar](10) NULL,
	[BaseCurrency] [nvarchar](10) NULL,
	[GSTCurrency] [nvarchar](10) NULL,
	[PostingDate] [datetime2](7) NULL,
	[DocDate] [datetime2](7) NULL,
	[DueDate] [datetime2](7) NULL,
	[BalanaceAmount] [money] NULL,
	[ExchangeRate] [decimal](15, 10) NULL,
	[GSTExchangeRate] [decimal](15, 10) NULL,
	[CreditTermsId] [bigint] NULL,
	[DocDescription] [nvarchar](512) NULL,
	[PONo] [nvarchar](100) NULL,
	[NoSupportingDocs] [bit] NULL,
	[Nature] [nvarchar](20) NULL,
	[GSTTotalAmount] [money] NULL,
	[GrandTotal] [money] NULL,
	[IsGstSettings] [bit] NULL,
	[IsGSTApplied] [bit] NULL,
	[IsMultiCurrency] [bit] NULL,
	[IsAllowableNonAllowable] [bit] NULL,
	[IsNoSupportingDocument] [bit] NULL,
	[IsAllowableDisallowableActivated] [bit] NULL,
	[Status] [bit] NULL,
	[UserCreated] [nvarchar](200) NULL,
	[CreatedDate] [datetime2](7) NULL,
	[ModifiedBy] [nvarchar](200) NULL,
	[ModifiedDate] [datetime2](7) NULL,
	[IsBaseCurrencyRateChanged] [bit] NULL,
	[IsGSTCurrencyRateChanged] [bit] NULL
)
GO
