USE [SmartCursorSTG]
GO
/****** Object:  Table [Tax].[SubCategory]    Script Date: 16-12-2024 9.30.57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Tax].[SubCategory](
	[Id] [uniqueidentifier] NOT NULL,
	[Name] [nvarchar](100) NULL,
	[CategoryId] [uniqueidentifier] NOT NULL,
	[Recorder] [int] NULL,
	[Type] [nvarchar](50) NULL,
	[TypeId] [uniqueidentifier] NULL,
	[EngagementId] [uniqueidentifier] NULL,
	[LeadsheetGroup] [int] NULL,
	[StatementBOrder] [nvarchar](max) NULL,
	[SubCategoryOrder] [nvarchar](max) NULL,
	[IsSubTotal] [bit] NULL,
	[ParentId] [uniqueidentifier] NULL,
	[IsIncomeStatement] [bit] NULL,
	[ColorCode] [nvarchar](100) NULL,
	[AccountClass] [nvarchar](100) NULL,
	[IsCollapse] [bit] NULL,
 CONSTRAINT [PK_SubCategory] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [Tax].[SubCategory] ADD  DEFAULT ((1)) FOR [Recorder]
GO
ALTER TABLE [Tax].[SubCategory]  WITH CHECK ADD  CONSTRAINT [Fk_SubCategory_EngagementId] FOREIGN KEY([EngagementId])
REFERENCES [Tax].[TaxCompanyEngagement] ([Id])
GO
ALTER TABLE [Tax].[SubCategory] CHECK CONSTRAINT [Fk_SubCategory_EngagementId]
GO
