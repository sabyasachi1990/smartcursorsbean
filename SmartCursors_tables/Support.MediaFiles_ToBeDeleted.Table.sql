USE [SmartCursorSTG]
GO
/****** Object:  Table [Support].[MediaFiles_ToBeDeleted]    Script Date: 16-12-2024 9.30.57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Support].[MediaFiles_ToBeDeleted](
	[Id] [uniqueidentifier] NOT NULL,
	[RefFrom] [nvarchar](1000) NOT NULL,
	[RefId] [uniqueidentifier] NOT NULL,
	[SourceType] [nvarchar](50) NOT NULL,
	[MediaType] [nvarchar](10) NOT NULL,
	[MediaPath] [nvarchar](1000) NOT NULL,
	[FileSize] [int] NOT NULL,
	[Remarks] [nvarchar](1000) NULL,
 CONSTRAINT [PK_MediaRepository] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
