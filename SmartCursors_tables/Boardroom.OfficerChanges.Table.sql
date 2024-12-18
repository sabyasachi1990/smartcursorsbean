USE [SmartCursorSTG]
GO
/****** Object:  Table [Boardroom].[OfficerChanges]    Script Date: 16-12-2024 9.30.56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Boardroom].[OfficerChanges](
	[Id] [uniqueidentifier] NOT NULL,
	[ChangesId] [uniqueidentifier] NOT NULL,
	[DateOfCessation] [datetime2](7) NULL,
	[ReasonForCessation] [nvarchar](max) NULL,
	[CurrentName] [nvarchar](100) NULL,
	[CurrentIDType] [nvarchar](100) NULL,
	[CurrentIDNumber] [nvarchar](100) NULL,
	[CurrentPositionheld] [nvarchar](100) NULL,
	[CurrentDateofAppointment] [datetime2](7) NULL,
	[ProposedName] [nvarchar](100) NULL,
	[ProposedIDType] [nvarchar](100) NULL,
	[ProposedIDNumber] [nvarchar](100) NULL,
	[ProposedPositionheld] [nvarchar](100) NULL,
	[ProposedDateofAppointment] [datetime2](7) NULL,
	[ContactsId] [uniqueidentifier] NULL,
	[CurrentCommunication] [nvarchar](4000) NULL,
	[ProposedCommunication] [nvarchar](4000) NULL,
	[CurrentGender] [nvarchar](6) NULL,
	[CurrentNationality] [nvarchar](254) NULL,
	[CurrentDateOfBirth] [datetime2](7) NULL,
	[CurrentCountryOfBirth] [nvarchar](254) NULL,
	[CurrentCountryOfResidence] [nvarchar](254) NULL,
	[ProposedGender] [nvarchar](6) NULL,
	[ProposedNationality] [nvarchar](254) NULL,
	[ProposedDateOfBirth] [datetime2](7) NULL,
	[ProposedCountryOfBirth] [nvarchar](254) NULL,
	[ProposedCountryOfResidence] [nvarchar](254) NULL,
	[DisqualifiedReasons] [nvarchar](max) NULL,
	[DisqualifiedReasonsSubsection] [nvarchar](max) NULL,
	[CurrentSuffix] [nvarchar](250) NULL,
	[CurrentCountryofIncorporation] [nvarchar](250) NULL,
	[CurrentCompanyType] [nvarchar](250) NULL,
	[ProposedSuffix] [nvarchar](250) NULL,
	[ProposedCountryofIncorporation] [nvarchar](250) NULL,
	[ProposedCompanyType] [nvarchar](250) NULL,
	[Reason] [nvarchar](max) NULL,
	[GCDesinationId] [uniqueidentifier] NULL,
	[ProposedFormerName] [nvarchar](200) NULL,
	[ProposedLegalForm] [nvarchar](200) NULL,
	[ProposedGoverningJurisdiction] [nvarchar](200) NULL,
	[ProposedRegisterCompaniesJurisdiction] [nvarchar](200) NULL,
	[ProposedDateofCorporate] [datetime2](7) NULL,
	[CurrentFormerName] [nvarchar](200) NULL,
	[CurrentLegalForm] [nvarchar](200) NULL,
	[CurrentGoverningJurisdiction] [nvarchar](200) NULL,
	[CurrentRegisterCompaniesJurisdiction] [nvarchar](200) NULL,
	[CurrentDateofCorporate] [datetime2](7) NULL,
	[IsChange] [bit] NULL,
	[CurrentCompanyNo] [nvarchar](200) NULL,
	[ProposedCompanyNumber] [nvarchar](200) NULL,
	[ActionType] [nvarchar](30) NULL,
	[CreatedDate] [datetime2](7) NULL,
	[Recorder] [int] NULL,
	[GenericContactId] [uniqueidentifier] NULL,
	[CurrentSalutation] [nvarchar](10) NULL,
	[PraposedSalutation] [nvarchar](10) NULL,
	[CurrentPassportExpiryDate] [datetime2](7) NULL,
	[ProposedExpirydate] [datetime2](7) NULL,
 CONSTRAINT [PK_OfficerChanges] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [Boardroom].[OfficerChanges]  WITH CHECK ADD FOREIGN KEY([GenericContactId])
REFERENCES [Boardroom].[GenericContact] ([Id])
GO
ALTER TABLE [Boardroom].[OfficerChanges]  WITH CHECK ADD  CONSTRAINT [FK_OfficerChanges_Changes] FOREIGN KEY([ChangesId])
REFERENCES [Boardroom].[Changes] ([Id])
GO
ALTER TABLE [Boardroom].[OfficerChanges] CHECK CONSTRAINT [FK_OfficerChanges_Changes]
GO
