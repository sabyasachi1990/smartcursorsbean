USE [SmartCursorSTG]
GO
/****** Object:  Table [Audit].[SubCategory]    Script Date: 16-12-2024 9.30.55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Audit].[SubCategory](
	[Id] [uniqueidentifier] NOT NULL,
	[Name] [nvarchar](200) NULL,
	[CategoryId] [uniqueidentifier] NOT NULL,
	[Recorder] [int] NULL,
	[Type] [nvarchar](50) NULL,
	[EngagementId] [uniqueidentifier] NULL,
	[TypeId] [uniqueidentifier] NULL,
	[LeadsheetGroup] [int] NULL,
	[SubCategoryOrder] [nvarchar](max) NULL,
	[ParentId] [uniqueidentifier] NULL,
	[IsIncomeStatement] [bit] NULL,
	[ColorCode] [nvarchar](100) NULL,
	[AccountClass] [nvarchar](100) NULL,
	[IsCollapse] [bit] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [Audit].[SubCategory] ADD  DEFAULT ((1)) FOR [Recorder]
GO
