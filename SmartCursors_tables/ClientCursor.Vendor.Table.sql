USE [SmartCursorSTG]
GO
/****** Object:  Table [ClientCursor].[Vendor]    Script Date: 16-12-2024 9.30.56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [ClientCursor].[Vendor](
	[Id] [uniqueidentifier] NOT NULL,
	[Name] [nvarchar](254) NOT NULL,
	[CompanyId] [bigint] NOT NULL,
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
	[Remarks] [nvarchar](256) NULL,
	[UserCreated] [nvarchar](254) NULL,
	[CreatedDate] [datetime2](7) NULL,
	[ModifiedBy] [nvarchar](254) NULL,
	[ModifiedDate] [datetime2](7) NULL,
	[Version] [smallint] NULL,
	[Status] [int] NULL,
	[VendorIdType] [bigint] NULL,
	[VendorNumber] [nvarchar](50) NULL,
	[IsSameAsAbove] [bit] NULL,
	[Communication] [nvarchar](1000) NULL,
 CONSTRAINT [PK_Vendor] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [ClientCursor].[Vendor] ADD  DEFAULT ((1)) FOR [IsLocal]
GO
ALTER TABLE [ClientCursor].[Vendor] ADD  DEFAULT ((1)) FOR [Status]
GO
ALTER TABLE [ClientCursor].[Vendor] ADD  DEFAULT ((0)) FOR [IsSameAsAbove]
GO
ALTER TABLE [ClientCursor].[Vendor]  WITH CHECK ADD  CONSTRAINT [FK_Vendor_AddressBook] FOREIGN KEY([AddressBookId])
REFERENCES [Common].[AddressBook] ([Id])
GO
ALTER TABLE [ClientCursor].[Vendor] CHECK CONSTRAINT [FK_Vendor_AddressBook]
GO
ALTER TABLE [ClientCursor].[Vendor]  WITH CHECK ADD  CONSTRAINT [FK_Vendor_Company] FOREIGN KEY([CompanyId])
REFERENCES [Common].[Company] ([Id])
GO
ALTER TABLE [ClientCursor].[Vendor] CHECK CONSTRAINT [FK_Vendor_Company]
GO
ALTER TABLE [ClientCursor].[Vendor]  WITH CHECK ADD  CONSTRAINT [FK_Vendor_IdType] FOREIGN KEY([VendorIdType])
REFERENCES [Common].[IdType] ([Id])
GO
ALTER TABLE [ClientCursor].[Vendor] CHECK CONSTRAINT [FK_Vendor_IdType]
GO
