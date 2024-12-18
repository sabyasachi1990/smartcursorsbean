USE [SmartCursorSTG]
GO
/****** Object:  Table [Boardroom].[GenericContact]    Script Date: 16-12-2024 9.30.56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Boardroom].[GenericContact](
	[Id] [uniqueidentifier] NOT NULL,
	[CompanyId] [bigint] NOT NULL,
	[Category] [nvarchar](50) NULL,
	[Salutation] [nvarchar](15) NULL,
	[Name] [nvarchar](254) NULL,
	[IDType] [nvarchar](50) NULL,
	[IDNumber] [nvarchar](20) NULL,
	[Nationality] [nvarchar](254) NULL,
	[Gender] [nvarchar](6) NULL,
	[DateOfBirth] [datetime2](7) NULL,
	[CountryOfBirth] [nvarchar](254) NULL,
	[CountryOfResidence] [nvarchar](254) NULL,
	[Communication] [nvarchar](4000) NULL,
	[Designation] [nvarchar](25) NULL,
	[CountryOfIncorporation] [nvarchar](204) NULL,
	[CompanyType] [nvarchar](254) NULL,
	[Suffix] [nvarchar](250) NULL,
	[CorporateEntityRegister] [nvarchar](125) NULL,
	[Remarks] [nvarchar](max) NULL,
	[RecOrder] [int] NULL,
	[UserCreated] [nvarchar](254) NULL,
	[CreatedDate] [datetime2](7) NULL,
	[ModifiedBy] [nvarchar](254) NULL,
	[ModifiedDate] [datetime2](7) NULL,
	[Version] [smallint] NULL,
	[Status] [int] NULL,
	[IsMainContact] [bit] NULL,
	[Type] [nvarchar](50) NULL,
	[TypeId] [uniqueidentifier] NULL,
	[ShortName] [nvarchar](30) NULL,
	[IsNoProfile] [bit] NULL,
	[FormerName] [nvarchar](250) NULL,
	[CompanyNo] [nvarchar](100) NULL,
	[LegalForm] [nvarchar](100) NULL,
	[GoverningJurisdiction] [nvarchar](100) NULL,
	[RegisterCompaniesJurisdiction] [nvarchar](100) NULL,
	[DateofCorporate] [datetime2](7) NULL,
	[PassportExpirydate] [datetime2](7) NULL,
 CONSTRAINT [PK_GenericContact] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [Boardroom].[GenericContact] ADD  DEFAULT (getdate()) FOR [CreatedDate]
GO
ALTER TABLE [Boardroom].[GenericContact] ADD  DEFAULT ((1)) FOR [Status]
GO
ALTER TABLE [Boardroom].[GenericContact]  WITH CHECK ADD  CONSTRAINT [FK_GenericContact_Company] FOREIGN KEY([CompanyId])
REFERENCES [Common].[Company] ([Id])
GO
ALTER TABLE [Boardroom].[GenericContact] CHECK CONSTRAINT [FK_GenericContact_Company]
GO
