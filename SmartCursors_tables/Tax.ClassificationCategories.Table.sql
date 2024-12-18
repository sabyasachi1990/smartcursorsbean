USE [SmartCursorSTG]
GO
/****** Object:  Table [Tax].[ClassificationCategories]    Script Date: 16-12-2024 9.30.57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Tax].[ClassificationCategories](
	[Id] [uniqueidentifier] NOT NULL,
	[ClassificationId] [uniqueidentifier] NULL,
	[Name] [nvarchar](50) NULL,
	[RecOrder] [int] NOT NULL,
	[Status] [int] NULL,
	[IsHide] [bit] NULL,
	[SubCategoryId] [uniqueidentifier] NULL,
	[IsCategorised] [bit] NULL,
 CONSTRAINT [PK_ClassificationCategories] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Tax].[ClassificationCategories]  WITH CHECK ADD  CONSTRAINT [FK_ClassificationCategories_Classification] FOREIGN KEY([ClassificationId])
REFERENCES [Tax].[Classification] ([Id])
GO
ALTER TABLE [Tax].[ClassificationCategories] CHECK CONSTRAINT [FK_ClassificationCategories_Classification]
GO
