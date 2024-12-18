USE [SmartCursorSTG]
GO
/****** Object:  Table [Audit].[LeadSheetCategories]    Script Date: 16-12-2024 9.30.55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Audit].[LeadSheetCategories](
	[Id] [uniqueidentifier] NOT NULL,
	[LeadsheetId] [uniqueidentifier] NULL,
	[Name] [nvarchar](50) NULL,
	[RecOrder] [int] NOT NULL,
	[Status] [int] NULL,
	[IsHide] [bit] NULL,
	[SubCategoryId] [uniqueidentifier] NULL,
	[IsCategorised] [bit] NULL,
	[IsSystem] [bit] NULL,
 CONSTRAINT [PK_LeadSheetCategories] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Audit].[LeadSheetCategories]  WITH CHECK ADD  CONSTRAINT [FK_LeadSheetCategories_LeadSheet] FOREIGN KEY([LeadsheetId])
REFERENCES [Audit].[LeadSheet] ([Id])
GO
ALTER TABLE [Audit].[LeadSheetCategories] CHECK CONSTRAINT [FK_LeadSheetCategories_LeadSheet]
GO
