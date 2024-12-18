USE [SmartCursorSTG]
GO
/****** Object:  Table [Common].[EntityDetail]    Script Date: 16-12-2024 9.30.56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Common].[EntityDetail](
	[Id] [uniqueidentifier] NOT NULL,
	[CompanyId] [bigint] NOT NULL,
	[RefNo] [nvarchar](15) NULL,
	[Register] [nvarchar](50) NOT NULL,
	[HandlingOfficer] [nvarchar](2000) NULL,
	[PraposedEntityName1] [nvarchar](100) NULL,
	[PraposedEntityName2] [nvarchar](100) NULL,
	[PraposedEntityName3] [nvarchar](100) NULL,
	[ChoosenEntityName] [nvarchar](100) NOT NULL,
	[CompanyType] [nvarchar](254) NULL,
	[Suffix] [nvarchar](250) NULL,
	[CorporateEntityRegister] [nvarchar](10) NULL,
	[PraposedFYE] [datetime2](7) NOT NULL,
	[IsFiveHours] [bit] NULL,
	[NoOfHours] [nvarchar](15) NULL,
	[ReasonforCancellation] [nvarchar](4000) NULL,
	[State] [nvarchar](15) NULL,
	[Remarks] [nvarchar](500) NULL,
	[RecOrder] [int] NULL,
	[UserCreated] [varchar](254) NULL,
	[CreatedDate] [datetime2](7) NULL,
	[ModifiedBy] [nvarchar](254) NULL,
	[ModifiedDate] [datetime2](7) NULL,
	[Version] [smallint] NULL,
	[Jurisdiction] [nvarchar](254) NULL,
	[Type] [nvarchar](100) NULL,
	[UEN] [nvarchar](50) NULL,
	[IncorporationDate] [datetime] NULL,
	[IsPrincipalApprovalReferalAuthorities] [bit] NULL,
	[CountryofIncorporation] [varchar](50) NULL,
	[Status] [int] NULL,
	[SubCompanyId] [bigint] NULL,
	[ExistingCompany] [varchar](50) NULL,
	[CompanyStatus] [nvarchar](50) NULL,
	[CeasedDate] [datetime2](7) NULL,
	[EntityName] [nvarchar](250) NULL,
	[TakeOverDate] [datetime2](7) NULL,
	[CurrentFYE] [nvarchar](20) NULL,
	[SubType] [nvarchar](50) NULL,
	[Communication] [nvarchar](4000) NULL,
	[PartnerCompanyId] [bigint] NULL,
	[Istemporary] [bit] NULL,
	[FormerName] [varchar](100) NULL,
	[IsContact] [bit] NULL,
	[IsCeassed] [bit] NULL,
	[IsNoOfHoursApplicable] [bit] NULL,
	[CompanyTypeId] [bigint] NULL,
	[SuffixId] [bigint] NULL,
	[FYEYear] [nvarchar](10) NULL,
	[IsBizTemp] [bit] NULL,
	[IsThreeHours] [bit] NULL,
 CONSTRAINT [PK_CompanyDetail] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Common].[EntityDetail] ADD  DEFAULT (getdate()) FOR [CreatedDate]
GO
ALTER TABLE [Common].[EntityDetail] ADD  DEFAULT ((1)) FOR [Status]
GO
ALTER TABLE [Common].[EntityDetail]  WITH CHECK ADD  CONSTRAINT [FK_CompanyDetail_Company] FOREIGN KEY([CompanyId])
REFERENCES [Common].[Company] ([Id])
GO
ALTER TABLE [Common].[EntityDetail] CHECK CONSTRAINT [FK_CompanyDetail_Company]
GO
