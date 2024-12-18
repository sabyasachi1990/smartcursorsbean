USE [SmartCursorSTG]
GO
/****** Object:  Table [Common].[GeoPC_Regions]    Script Date: 16-12-2024 9.30.56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Common].[GeoPC_Regions](
	[Id] [uniqueidentifier] NOT NULL,
	[ISO] [varchar](2) NOT NULL,
	[Language] [varchar](2) NOT NULL,
	[Level] [smallint] NOT NULL,
	[Type] [varchar](50) NOT NULL,
	[Name] [varchar](80) NOT NULL,
	[Country] [varchar](50) NOT NULL,
	[Region1] [varchar](80) NULL,
	[Region2] [varchar](80) NULL,
	[Region3] [varchar](80) NULL,
	[Region4] [varchar](80) NULL,
	[ISO2] [varchar](10) NULL,
	[FIPS] [varchar](10) NULL,
	[NUTS] [varchar](12) NULL,
	[HASC] [varchar](12) NULL,
	[STAT] [varchar](20) NULL,
 CONSTRAINT [PK_GeoPC_Regions] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Common].[GeoPC_Regions] ADD  CONSTRAINT [DF_GeoPC_Regions_Id]  DEFAULT (newid()) FOR [Id]
GO
