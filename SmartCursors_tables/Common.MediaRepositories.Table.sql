USE [SmartCursorSTG]
GO
/****** Object:  Table [Common].[MediaRepositories]    Script Date: 16-12-2024 9.30.56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Common].[MediaRepositories](
	[Id] [uniqueidentifier] NOT NULL,
	[MediaRepositoryId] [uniqueidentifier] NOT NULL,
	[RefType] [nvarchar](20) NULL,
	[RefTypeId] [uniqueidentifier] NOT NULL,
	[RefTypeIdInt] [bigint] NULL,
	[FileName] [nvarchar](500) NULL,
	[Status] [int] NULL,
 CONSTRAINT [PK_MediaRepositories] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Common].[MediaRepositories]  WITH CHECK ADD  CONSTRAINT [FK_MediaRepositories_MediaRepository] FOREIGN KEY([MediaRepositoryId])
REFERENCES [Common].[MediaRepository] ([Id])
GO
ALTER TABLE [Common].[MediaRepositories] CHECK CONSTRAINT [FK_MediaRepositories_MediaRepository]
GO
