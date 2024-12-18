USE [SmartCursorSTG]
GO
/****** Object:  Table [dbo].[Share_Contact_NEw_devbackup]    Script Date: 16-12-2024 9.30.56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Share_Contact_NEw_devbackup](
	[Registration No] [nvarchar](255) NULL,
	[Entity Name] [nvarchar](255) NULL,
	[Category] [nvarchar](255) NULL,
	[Position] [nvarchar](255) NULL,
	[Name] [nvarchar](255) NULL,
	[Local Address/ Foreign Address] [nvarchar](255) NULL,
	[Address Type] [nvarchar](255) NULL,
	[Block/House No] [nvarchar](255) NULL,
	[Level & Unit no] [nvarchar](255) NULL,
	[Street] [nvarchar](255) NULL,
	[Building] [nvarchar](255) NULL,
	[AddressLine1] [nvarchar](255) NULL,
	[AddressLine2] [nvarchar](255) NULL,
	[AddressLine3] [nvarchar](255) NULL,
	[AddressLine4] [nvarchar](255) NULL,
	[Country] [nvarchar](255) NULL,
	[Postal Code] [float] NULL,
	[Registrable Controller (Yes/No)] [nvarchar](255) NULL,
	[Notes] [nvarchar](255) NULL,
	[Date of becoming] [datetime] NULL,
	[Date of Entry] [datetime] NULL,
	[Legal Form] [nvarchar](255) NULL,
	[Governing Jurisdiction & Law] [nvarchar](255) NULL,
	[Registrar of Companies of the Jurisdiction] [nvarchar](255) NULL,
	[Place of Incorporation] [nvarchar](255) NULL,
	[Incorporation Date] [datetime] NULL,
	[UEN] [nvarchar](255) NULL,
	[Salutation] [nvarchar](255) NULL,
	[Gender] [nvarchar](255) NULL,
	[Nationality] [nvarchar](255) NULL,
	[ID Type] [nvarchar](255) NULL,
	[ID no] [nvarchar](255) NULL,
	[Country of Birth] [nvarchar](255) NULL,
	[Date of Birth] [datetime] NULL,
	[Email ] [nvarchar](255) NULL,
	[Country Code] [float] NULL,
	[Mobile Phone No#] [nvarchar](255) NULL,
	[Company No] [float] NULL
) ON [PRIMARY]
GO
