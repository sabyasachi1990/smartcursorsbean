USE [SmartCursorSTG]
GO
/****** Object:  Table [Common].[Company]    Script Date: 16-12-2024 9.30.56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Common].[Company](
	[Id] [bigint] NOT NULL,
	[ParentId] [bigint] NULL,
	[RegistrationNo] [nvarchar](50) NULL,
	[Name] [nvarchar](254) NOT NULL,
	[LogoId] [uniqueidentifier] NULL,
	[CssSprite] [nvarchar](50) NULL,
	[BaseCurrency] [nvarchar](5) NULL,
	[AddressBookId] [uniqueidentifier] NULL,
	[RecOrder] [int] NULL,
	[Remarks] [nvarchar](254) NULL,
	[UserCreated] [nvarchar](254) NULL,
	[CreatedDate] [datetime2](7) NULL,
	[ModifiedBy] [nvarchar](254) NULL,
	[ModifiedDate] [datetime2](7) NULL,
	[Version] [smallint] NULL,
	[Status] [int] NULL,
	[ShortName] [nvarchar](5) NULL,
	[ExpiryDate] [datetime2](7) NULL,
	[Communication] [nvarchar](1000) NULL,
	[IsGstSetting] [bit] NULL,
	[GstCurrency] [nvarchar](5) NULL,
	[Country] [nvarchar](50) NULL,
	[IsPosting] [bit] NULL,
	[PayMode] [nvarchar](15) NULL,
	[Amount] [decimal](10, 2) NULL,
	[IsAccountingFirm] [bit] NULL,
	[AccountingFirmId] [bigint] NULL,
	[IdTypeId] [bigint] NULL,
	[ClientTypeId] [bigint] NULL,
	[Isregister] [bit] NULL,
	[PartnerId] [bigint] NULL,
	[Jurisdiction] [nvarchar](250) NULL,
	[TenantId] [uniqueidentifier] NULL,
	[ParentTenantId] [uniqueidentifier] NULL,
	[ParticipantPeppolId] [nvarchar](50) NULL,
	[IsTrial] [bit] NULL,
	[IsMultiCompany] [bit] NULL,
	[IsMultiCurrency] [bit] NULL,
	[PartnerInvoiceNumber] [nvarchar](50) NULL,
	[State] [nvarchar](50) NULL,
	[XeroState] [nvarchar](100) NULL,
	[IsClientCompany] [bit] NULL,
 CONSTRAINT [PK_Company] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Common].[Company] ADD  DEFAULT ((1)) FOR [Status]
GO
ALTER TABLE [Common].[Company] ADD  DEFAULT ((0)) FOR [Isregister]
GO
ALTER TABLE [Common].[Company]  WITH CHECK ADD  CONSTRAINT [FK_Company_AddressBook] FOREIGN KEY([AddressBookId])
REFERENCES [Common].[AddressBook] ([Id])
GO
ALTER TABLE [Common].[Company] CHECK CONSTRAINT [FK_Company_AddressBook]
GO
ALTER TABLE [Common].[Company]  WITH CHECK ADD  CONSTRAINT [FK_Company_MediaRepository] FOREIGN KEY([LogoId])
REFERENCES [Common].[MediaRepository] ([Id])
GO
ALTER TABLE [Common].[Company] CHECK CONSTRAINT [FK_Company_MediaRepository]
GO
