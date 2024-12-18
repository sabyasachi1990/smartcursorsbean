USE [SmartCursorSTG]
GO
/****** Object:  Table [Tax].[CategoryDetails]    Script Date: 16-12-2024 9.30.57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Tax].[CategoryDetails](
	[Id] [uniqueidentifier] NOT NULL,
	[EngagementId] [uniqueidentifier] NOT NULL,
	[ClassificationCategoryId] [uniqueidentifier] NOT NULL,
 CONSTRAINT [PK_CategoryDetail] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Tax].[CategoryDetails]  WITH CHECK ADD  CONSTRAINT [PK_CategoryDetail_ClassificationCategories] FOREIGN KEY([ClassificationCategoryId])
REFERENCES [Tax].[ClassificationCategories] ([Id])
GO
ALTER TABLE [Tax].[CategoryDetails] CHECK CONSTRAINT [PK_CategoryDetail_ClassificationCategories]
GO
