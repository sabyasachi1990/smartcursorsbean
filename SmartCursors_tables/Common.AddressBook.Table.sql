USE [SmartCursorSTG]
GO
/****** Object:  Table [Common].[AddressBook]    Script Date: 16-12-2024 9.30.56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Common].[AddressBook](
	[Id] [uniqueidentifier] NOT NULL,
	[IsLocal] [bit] NULL,
	[BlockHouseNo] [nvarchar](256) NULL,
	[Street] [nvarchar](1000) NULL,
	[UnitNo] [nvarchar](256) NULL,
	[BuildingEstate] [nvarchar](256) NULL,
	[City] [nvarchar](256) NULL,
	[PostalCode] [nvarchar](10) NULL,
	[State] [nvarchar](256) NULL,
	[Country] [nvarchar](256) NULL,
	[Phone] [nvarchar](1000) NULL,
	[Email] [nvarchar](1000) NULL,
	[Website] [nvarchar](1000) NULL,
	[Latitude] [decimal](18, 6) NULL,
	[Longitude] [decimal](18, 6) NULL,
	[RecOrder] [int] NULL,
	[Remarks] [nvarchar](256) NULL,
	[UserCreated] [nvarchar](254) NULL,
	[CreatedDate] [datetime2](7) NULL,
	[ModifiedBy] [nvarchar](254) NULL,
	[ModifiedDate] [datetime2](7) NULL,
	[Version] [smallint] NULL,
	[Status] [int] NULL,
	[DocumentId] [uniqueidentifier] NULL,
 CONSTRAINT [Pk_AddressBook] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Common].[AddressBook] ADD  DEFAULT ((1)) FOR [IsLocal]
GO
ALTER TABLE [Common].[AddressBook] ADD  DEFAULT ((1)) FOR [Status]
GO
