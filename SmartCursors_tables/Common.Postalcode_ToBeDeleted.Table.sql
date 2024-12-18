USE [SmartCursorSTG]
GO
/****** Object:  Table [Common].[Postalcode_ToBeDeleted]    Script Date: 16-12-2024 9.30.56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Common].[Postalcode_ToBeDeleted](
	[Id] [bigint] NOT NULL,
	[PostalCode] [varchar](6) NULL,
	[AddressType] [varchar](1) NULL,
	[BuildingNumber] [varchar](7) NULL,
	[StreetKey] [varchar](7) NULL,
	[BuildingKey] [varchar](6) NULL,
 CONSTRAINT [PK_Postalcode] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
