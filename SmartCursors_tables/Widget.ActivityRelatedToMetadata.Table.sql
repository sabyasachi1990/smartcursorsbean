USE [SmartCursorSTG]
GO
/****** Object:  Table [Widget].[ActivityRelatedToMetadata]    Script Date: 16-12-2024 9.30.57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Widget].[ActivityRelatedToMetadata](
	[Id] [uniqueidentifier] NOT NULL,
	[CompanyId] [bigint] NOT NULL,
	[Cursor] [nvarchar](20) NULL,
	[Page] [nvarchar](100) NULL,
	[RelatedToValuesJSON] [nvarchar](1000) NULL,
 CONSTRAINT [PK_ActivityRelatedToMetadata] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Widget].[ActivityRelatedToMetadata]  WITH CHECK ADD  CONSTRAINT [FK_ActivityRelatedToMetadata_Company] FOREIGN KEY([CompanyId])
REFERENCES [Common].[Company] ([Id])
GO
ALTER TABLE [Widget].[ActivityRelatedToMetadata] CHECK CONSTRAINT [FK_ActivityRelatedToMetadata_Company]
GO
