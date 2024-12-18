USE [SmartCursorSTG]
GO
/****** Object:  Table [Common].[TemplateSetUpDetail]    Script Date: 16-12-2024 9.30.56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Common].[TemplateSetUpDetail](
	[Id] [uniqueidentifier] NOT NULL,
	[TemplateSetUpId] [uniqueidentifier] NOT NULL,
	[GenericTemplateId] [uniqueidentifier] NULL,
 CONSTRAINT [PK_TemplateSetUpDetail] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Common].[TemplateSetUpDetail]  WITH CHECK ADD  CONSTRAINT [FK_TemplateSetUpDetail_TemplateSetUp] FOREIGN KEY([TemplateSetUpId])
REFERENCES [Common].[TemplateSetUp] ([Id])
GO
ALTER TABLE [Common].[TemplateSetUpDetail] CHECK CONSTRAINT [FK_TemplateSetUpDetail_TemplateSetUp]
GO
