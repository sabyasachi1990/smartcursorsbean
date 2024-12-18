USE [SmartCursorSTG]
GO
/****** Object:  Table [Common].[TemplateRelatedTo]    Script Date: 16-12-2024 9.30.56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Common].[TemplateRelatedTo](
	[Id] [uniqueidentifier] NOT NULL,
	[TemplateId] [uniqueidentifier] NOT NULL,
	[RelatedType] [nvarchar](256) NOT NULL,
	[RelatedId] [uniqueidentifier] NULL,
	[RelatedIdInt] [bigint] NULL,
	[Status] [int] NULL,
	[RelatedName] [nvarchar](256) NULL,
	[RecOrder] [int] NULL,
 CONSTRAINT [PK_TemplateRelatedTo] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Common].[TemplateRelatedTo] ADD  DEFAULT ((1)) FOR [Status]
GO
ALTER TABLE [Common].[TemplateRelatedTo]  WITH CHECK ADD  CONSTRAINT [FK_TemplateRelatedTo_Template] FOREIGN KEY([TemplateId])
REFERENCES [Common].[Template] ([Id])
GO
ALTER TABLE [Common].[TemplateRelatedTo] CHECK CONSTRAINT [FK_TemplateRelatedTo_Template]
GO
