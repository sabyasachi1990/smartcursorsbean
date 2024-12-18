USE [SmartCursorSTG]
GO
/****** Object:  Table [Common].[GenericTemplateRelatedTo]    Script Date: 16-12-2024 9.30.56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Common].[GenericTemplateRelatedTo](
	[Id] [uniqueidentifier] NOT NULL,
	[TemplateId] [uniqueidentifier] NOT NULL,
	[RelatedType] [nvarchar](100) NULL,
	[RelatedId] [uniqueidentifier] NULL,
	[Commucation] [nvarchar](1500) NULL,
	[RelatedIdInt] [bigint] NULL,
	[Status] [int] NULL,
	[RelatedName] [nvarchar](512) NULL,
	[RecOrder] [int] NULL,
 CONSTRAINT [PK_GenericTemplateRelatedTo] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Common].[GenericTemplateRelatedTo]  WITH CHECK ADD  CONSTRAINT [FK_GenericTemplateRelatedTo_GenericTemplate] FOREIGN KEY([TemplateId])
REFERENCES [Common].[GenericTemplate] ([Id])
GO
ALTER TABLE [Common].[GenericTemplateRelatedTo] CHECK CONSTRAINT [FK_GenericTemplateRelatedTo_GenericTemplate]
GO
