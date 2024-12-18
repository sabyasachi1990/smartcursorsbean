USE [SmartCursorSTG]
GO
/****** Object:  Table [Bean].[BankTransfer]    Script Date: 16-12-2024 9.30.55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Bean].[BankTransfer](
	[Id] [uniqueidentifier] NOT NULL,
	[CompanyId] [bigint] NOT NULL,
	[DocType] [nvarchar](20) NOT NULL,
	[SystemRefNo] [nvarchar](50) NOT NULL,
	[DocDescription] [nvarchar](253) NULL,
	[TransferDate] [datetime2](7) NOT NULL,
	[BankClearingDate] [datetime2](7) NULL,
	[DocNo] [nvarchar](25) NOT NULL,
	[IsNoSupportingDocument] [bit] NULL,
	[IsGstSetting] [bit] NOT NULL,
	[IsMultiCurrency] [bit] NOT NULL,
	[IsMultiCompany] [bit] NOT NULL,
	[NoSupportingDocument] [bit] NULL,
	[ModeOfTransfer] [nvarchar](20) NULL,
	[TransferRefNo] [nvarchar](50) NULL,
	[SystemCalculatedExchangeRate] [decimal](15, 10) NULL,
	[VarianceExchangeRate] [decimal](15, 10) NULL,
	[ExchangeRate] [decimal](15, 10) NULL,
	[ExCurrency] [nvarchar](5) NULL,
	[ExDurationFrom] [datetime2](7) NULL,
	[ExDurationTo] [datetime2](7) NULL,
	[DocumentState] [nvarchar](20) NULL,
	[Remarks] [nvarchar](1000) NULL,
	[UserCreated] [nvarchar](254) NULL,
	[CreatedDate] [datetime2](7) NULL,
	[ModifiedBy] [nvarchar](254) NULL,
	[ModifiedDate] [datetime2](7) NULL,
	[Status] [int] NULL,
	[IsInterCompany] [bit] NULL,
	[IsBaseCurrencyRateChanged] [bit] NULL,
	[Version] [timestamp] NOT NULL,
	[IsIntercoClearing] [bit] NULL,
	[IsIntercoBilling] [bit] NULL,
	[ClearCount] [int] NULL,
	[IsLocked] [bit] NULL,
 CONSTRAINT [PK_BankTransfer] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Bean].[BankTransfer] ADD  DEFAULT ((1)) FOR [Status]
GO
ALTER TABLE [Bean].[BankTransfer]  WITH CHECK ADD  CONSTRAINT [FK_BankTransfer_Company] FOREIGN KEY([CompanyId])
REFERENCES [Common].[Company] ([Id])
GO
ALTER TABLE [Bean].[BankTransfer] CHECK CONSTRAINT [FK_BankTransfer_Company]
GO
