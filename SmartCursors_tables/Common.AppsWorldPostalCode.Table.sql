USE [SmartCursorSTG]
GO
/****** Object:  Table [Common].[AppsWorldPostalCode]    Script Date: 16-12-2024 9.30.56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Common].[AppsWorldPostalCode](
	[Id] [bigint] NOT NULL,
	[PostalCode] [nvarchar](10) NULL,
	[AddressType] [nvarchar](1) NULL,
	[ServiceNumber] [nvarchar](6) NULL,
	[BuildingNumber] [nvarchar](7) NULL,
	[Streetkey] [nvarchar](7) NULL,
	[BuildingKey] [nvarchar](6) NULL,
	[WalkupIndicator] [nvarchar](1) NULL,
	[BuildingName] [nvarchar](45) NULL,
	[StreetName] [nvarchar](32) NULL,
	[Filler] [nvarchar](6) NULL,
	[TypeFlag] [nvarchar](1) NULL,
	[Country] [nvarchar](50) NULL,
	[State] [nvarchar](50) NULL,
	[RecOrder] [int] NULL,
 CONSTRAINT [PK_AppsWorldPostalCode] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Common].[AppsWorldPostalCode] ADD  DEFAULT ('Singapore') FOR [Country]
GO
ALTER TABLE [Common].[AppsWorldPostalCode] ADD  DEFAULT ('Singapore') FOR [State]
GO
