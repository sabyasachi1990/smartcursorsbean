USE [SmartCursorSTG]
GO
/****** Object:  Table [Bean].[SubCategory]    Script Date: 16-12-2024 9.30.55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Bean].[SubCategory](
	[Id] [uniqueidentifier] NOT NULL,
	[Name] [nvarchar](100) NULL,
	[CategoryId] [uniqueidentifier] NOT NULL,
	[Recorder] [int] NULL,
	[Type] [nvarchar](50) NULL,
	[CompanyId] [bigint] NULL,
	[TypeId] [uniqueidentifier] NULL,
	[SubCategoryOrder] [nvarchar](max) NULL,
	[ParentId] [uniqueidentifier] NULL,
	[IsIncomeStatement] [bit] NULL,
	[ColorCode] [nvarchar](100) NULL,
	[AccountClass] [nvarchar](20) NULL,
	[IsCollapse] [bit] NULL,
 CONSTRAINT [PK_SubCategory] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [Bean].[SubCategory] ADD  DEFAULT ((1)) FOR [Recorder]
GO
