USE [SmartCursorSTG]
GO
/****** Object:  Table [dbo].[ImportWFContacts]    Script Date: 16-12-2024 9.30.56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ImportWFContacts](
	[ID] [uniqueidentifier] NOT NULL,
	[TransactionId] [uniqueidentifier] NOT NULL,
	[ClientRefNumber] [nvarchar](2000) NULL,
	[Salutation] [nvarchar](2000) NULL,
	[Name] [nvarchar](2000) NULL,
	[DateofBirth] [nvarchar](2000) NULL,
	[IdentificationType] [nvarchar](2000) NULL,
	[IdentificationNumber] [nvarchar](2000) NULL,
	[CountryOfResidence] [nvarchar](2000) NULL,
	[PersonalEmail] [nvarchar](2000) NULL,
	[PersonalMobile] [nvarchar](2000) NULL,
	[PersonalLocalAddress] [nvarchar](4000) NULL,
	[PersonalForeignAddress] [nvarchar](4000) NULL,
	[EntityDesignation] [nvarchar](2000) NULL,
	[PrimaryContact] [bit] NULL,
	[EntityEmail] [nvarchar](2000) NULL,
	[EntityMobile] [nvarchar](2000) NULL,
	[EntityLocalAddress] [nvarchar](2000) NULL,
	[EntityForeignAddress] [nvarchar](2000) NULL,
	[CopycommunicationandAddress] [bit] NULL,
	[Remarks] [nvarchar](2000) NULL,
	[ErrorRemarks] [nvarchar](max) NULL,
	[ImportStatus] [bit] NULL,
 CONSTRAINT [Pk_ImportwfContact] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
