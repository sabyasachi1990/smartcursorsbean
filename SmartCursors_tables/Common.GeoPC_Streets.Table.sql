USE [SmartCursorSTG]
GO
/****** Object:  Table [Common].[GeoPC_Streets]    Script Date: 16-12-2024 9.30.56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Common].[GeoPC_Streets](
	[ISO] [varchar](2) NOT NULL,
	[Country] [varchar](50) NOT NULL,
	[Language] [varchar](2) NOT NULL,
	[ID] [bigint] NOT NULL,
	[Region1] [varchar](80) NULL,
	[Region2] [varchar](80) NULL,
	[Region3] [varchar](80) NULL,
	[Region4] [varchar](80) NULL,
	[Locality] [varchar](80) NULL,
	[Postcode] [varchar](15) NULL,
	[Suburb] [varchar](80) NULL,
	[Street] [varchar](100) NULL,
	[Range] [varchar](50) NULL,
	[Building] [varchar](80) NULL,
	[Latitude] [decimal](10, 6) NULL,
	[Longitude] [decimal](10, 6) NULL,
	[Elevation] [int] NULL,
	[ISO2] [varchar](10) NULL,
	[FIPS] [varchar](10) NULL,
	[NUTS] [varchar](12) NULL,
	[HASC] [varchar](12) NULL,
	[STAT] [varchar](20) NULL,
	[Timezone] [varchar](30) NULL,
	[UTC] [varchar](10) NULL,
	[DST] [varchar](10) NULL,
 CONSTRAINT [GeoPC_Streets_pkey] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
