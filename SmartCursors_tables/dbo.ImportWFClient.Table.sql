USE [SmartCursorSTG]
GO
/****** Object:  Table [dbo].[ImportWFClient]    Script Date: 16-12-2024 9.30.56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ImportWFClient](
	[ID] [uniqueidentifier] NOT NULL,
	[TransactionId] [uniqueidentifier] NOT NULL,
	[ClientRefNumber] [nvarchar](2000) NULL,
	[Name] [nvarchar](2000) NULL,
	[ClientType] [nvarchar](2000) NULL,
	[Identificationtype] [nvarchar](2000) NULL,
	[IdentificationNumber] [nvarchar](2000) NULL,
	[CreditTerms] [nvarchar](2000) NULL,
	[IncorporationDate] [nvarchar](2000) NULL,
	[IncorporationCountry] [nvarchar](2000) NULL,
	[FinancialYearEnd] [nvarchar](2000) NULL,
	[Industry] [nvarchar](2000) NULL,
	[PrinicipalActivities] [nvarchar](2000) NULL,
	[Email] [nvarchar](2000) NULL,
	[Mobile] [nvarchar](2000) NULL,
	[LocalAddress] [nvarchar](max) NULL,
	[ForeignAddress] [nvarchar](max) NULL,
	[ErrorRemarks] [nvarchar](max) NULL,
	[ImportStatus] [bit] NULL,
 CONSTRAINT [pk_Client] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
