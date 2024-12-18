USE [SmartCursorSTG]
GO
/****** Object:  Table [Bean].[Entity]    Script Date: 16-12-2024 9.30.55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Bean].[Entity](
	[Id] [uniqueidentifier] NOT NULL,
	[CompanyId] [bigint] NOT NULL,
	[Name] [nvarchar](100) NOT NULL,
	[TypeId] [bigint] NULL,
	[IdTypeId] [bigint] NULL,
	[IdNo] [nvarchar](50) NULL,
	[GSTRegNo] [nvarchar](50) NULL,
	[IsCustomer] [bit] NULL,
	[CustTOPId] [bigint] NULL,
	[CustTOP] [nvarchar](50) NULL,
	[CustTOPValue] [float] NULL,
	[CustCreditLimit] [money] NULL,
	[CustCurrency] [nvarchar](5) NULL,
	[CustNature] [nvarchar](25) NULL,
	[IsVendor] [bit] NULL,
	[VenTOPId] [bigint] NULL,
	[VenTOP] [nvarchar](50) NULL,
	[VenTOPValue] [float] NULL,
	[VenCurrency] [nvarchar](5) NULL,
	[VenNature] [nvarchar](25) NULL,
	[AddressBookId] [uniqueidentifier] NULL,
	[IsLocal] [bit] NULL,
	[ResBlockHouseNo] [nvarchar](100) NULL,
	[ResStreet] [nvarchar](100) NULL,
	[ResUnitNo] [nvarchar](100) NULL,
	[ResBuildingEstate] [nvarchar](100) NULL,
	[ResCity] [nvarchar](256) NULL,
	[ResPostalCode] [nvarchar](10) NULL,
	[ResState] [nvarchar](256) NULL,
	[ResCountry] [nvarchar](256) NULL,
	[RecOrder] [int] NULL,
	[Remarks] [nvarchar](1000) NULL,
	[UserCreated] [nvarchar](254) NULL,
	[CreatedDate] [datetime2](7) NULL,
	[ModifiedBy] [nvarchar](254) NULL,
	[ModifiedDate] [datetime2](7) NULL,
	[Version] [smallint] NULL,
	[Status] [int] NULL,
	[VenCreditLimit] [money] NULL,
	[Communication] [nvarchar](1000) NULL,
	[VendorType] [nvarchar](1000) NULL,
	[IsShowPayroll] [bit] NULL,
	[IsExternalData] [bit] NULL,
	[DocumentId] [uniqueidentifier] NULL,
	[COAId] [bigint] NULL,
	[TaxId] [bigint] NULL,
	[CreditLimitValue] [money] NULL,
	[ExternalEntityType] [nvarchar](50) NULL,
	[CustBal] [money] NULL,
	[VenBal] [money] NULL,
	[SyncClientId] [uniqueidentifier] NULL,
	[SyncClientStatus] [varchar](20) NULL,
	[SyncClientRemarks] [nvarchar](max) NULL,
	[SyncClientDate] [datetime2](7) NULL,
	[SyncAccountId] [uniqueidentifier] NULL,
	[SyncAccountStatus] [varchar](20) NULL,
	[SyncAccountRemarks] [nvarchar](max) NULL,
	[SyncAccountDate] [datetime2](7) NULL,
	[SyncEmployeeId] [uniqueidentifier] NULL,
	[SyncEmployeeStatus] [varchar](20) NULL,
	[SyncEmployeeDate] [datetime2](7) NULL,
	[SyncEmployeeRemarks] [nvarchar](max) NULL,
	[ServiceEntityId] [bigint] NULL,
	[PeppolDocumentId] [nvarchar](50) NULL,
	[Industry] [varchar](1000) NULL,
	[IndustryCode] [varchar](1000) NULL,
	[PrincipalActivities] [varchar](1000) NULL,
 CONSTRAINT [PK_Entity] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [Bean].[Entity] ADD  DEFAULT ((1)) FOR [IsLocal]
GO
ALTER TABLE [Bean].[Entity] ADD  DEFAULT ((1)) FOR [Status]
GO
ALTER TABLE [Bean].[Entity]  WITH CHECK ADD  CONSTRAINT [FK_Entity_AccountType] FOREIGN KEY([TypeId])
REFERENCES [Common].[AccountType] ([Id])
GO
ALTER TABLE [Bean].[Entity] CHECK CONSTRAINT [FK_Entity_AccountType]
GO
ALTER TABLE [Bean].[Entity]  WITH CHECK ADD  CONSTRAINT [FK_Entity_AddressBook] FOREIGN KEY([AddressBookId])
REFERENCES [Common].[AddressBook] ([Id])
GO
ALTER TABLE [Bean].[Entity] CHECK CONSTRAINT [FK_Entity_AddressBook]
GO
ALTER TABLE [Bean].[Entity]  WITH CHECK ADD  CONSTRAINT [FK_Entity_Company] FOREIGN KEY([CompanyId])
REFERENCES [Common].[Company] ([Id])
GO
ALTER TABLE [Bean].[Entity] CHECK CONSTRAINT [FK_Entity_Company]
GO
ALTER TABLE [Bean].[Entity]  WITH CHECK ADD  CONSTRAINT [FK_Entity_IdType] FOREIGN KEY([IdTypeId])
REFERENCES [Common].[IdType] ([Id])
GO
ALTER TABLE [Bean].[Entity] CHECK CONSTRAINT [FK_Entity_IdType]
GO
