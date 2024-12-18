USE [SmartCursorSTG]
GO
/****** Object:  Table [dbo].[ImportLeads]    Script Date: 16-12-2024 9.30.56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ImportLeads](
	[Id] [uniqueidentifier] NOT NULL,
	[TransactionId] [uniqueidentifier] NOT NULL,
	[AccountId] [nvarchar](2000) NULL,
	[Type] [nvarchar](2000) NULL,
	[Name] [nvarchar](2000) NULL,
	[SourceType] [nvarchar](2000) NULL,
	[Source/Remarks] [nvarchar](2000) NULL,
	[AccountType] [nvarchar](2000) NULL,
	[IdentificationType] [nvarchar](2000) NULL,
	[IdentificationNumber] [nvarchar](2000) NULL,
	[CreditTerms] [nvarchar](2000) NULL,
	[Industry] [nvarchar](2000) NULL,
	[IncorporationDate] [nvarchar](100) NULL,
	[IncorporationCountry] [nvarchar](2000) NULL,
	[FinancialYearEnd] [nvarchar](100) NULL,
	[CompanySecretary] [nvarchar](2000) NULL,
	[InchargesinClientCursor] [nvarchar](2000) NULL,
	[PrincipalActivities] [nvarchar](max) NULL,
	[RemindersAGM] [bit] NULL,
	[RemindersECI] [bit] NULL,
	[RemindersAudit] [bit] NULL,
	[RemindersFinalTax] [bit] NULL,
	[Email] [nvarchar](2000) NULL,
	[Phone] [nvarchar](2000) NULL,
	[LocalAddress] [nvarchar](2000) NULL,
	[Foreignaddress] [nvarchar](2000) NULL,
	[AccountErrorRemarks] [nvarchar](max) NULL,
	[AccountImportStatus] [bit] NULL,
	[InchargeErrorRemarks] [nvarchar](max) NULL,
	[InchargeImportStatus] [bit] NULL,
 CONSTRAINT [Pk_Accounts] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
