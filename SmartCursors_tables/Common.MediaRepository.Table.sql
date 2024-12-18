USE [SmartCursorSTG]
GO
/****** Object:  Table [Common].[MediaRepository]    Script Date: 16-12-2024 9.30.56 PM ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Common].[MediaRepository](
	[Id] [uniqueidentifier] NOT NULL,
	[CompanyId] [int] NULL,
	[SourceType] [nvarchar](15) NOT NULL,
	[MediaType] [nvarchar](100) NOT NULL,
	[Original] [nvarchar](1000) NULL,
	[Small] [nvarchar](1000) NULL,
	[Medium] [nvarchar](1000) NULL,
	[Large] [nvarchar](1000) NULL,
	[CssSprite] [nvarchar](50) NULL,
	[Status] [int] NULL,
	[DocumentId] [uniqueidentifier] NULL,
 CONSTRAINT [PK_MediaRepository] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Common].[MediaRepository] ADD  DEFAULT ((1)) FOR [Status]
GO
