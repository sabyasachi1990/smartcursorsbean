USE [SmartCursorSTG]
GO
/****** Object:  Table [Common].[GeoPC_Business]    Script Date: 16-12-2024 9.30.56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Common].[GeoPC_Business](
	[ISO] [varchar](2) NOT NULL,
	[Country] [varchar](50) NOT NULL,
	[Language] [varchar](2) NOT NULL,
	[ID] [bigint] NOT NULL,
	[Region1] [varchar](80) NULL,
	[Region2] [varchar](80) NULL,
	[Region3] [varchar](80) NULL,
	[Region4] [varchar](80) NULL,
	[Entity] [varchar](100) NULL,
	[Postcode] [varchar](15) NULL,
	[Info] [varchar](100) NULL,
 CONSTRAINT [GeoPC_Business_pkey] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
