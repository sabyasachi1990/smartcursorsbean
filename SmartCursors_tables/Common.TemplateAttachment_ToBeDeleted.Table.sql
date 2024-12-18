USE [SmartCursorSTG]
GO
/****** Object:  Table [Common].[TemplateAttachment_ToBeDeleted]    Script Date: 16-12-2024 9.30.56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Common].[TemplateAttachment_ToBeDeleted](
	[Id] [uniqueidentifier] NOT NULL,
	[TemplateId] [uniqueidentifier] NOT NULL,
	[MediaRepositoryId] [uniqueidentifier] NOT NULL,
	[FileName] [nvarchar](max) NULL,
	[FilePathUrl] [nvarchar](max) NULL,
	[Status] [int] NULL,
 CONSTRAINT [PK_TemplateAttachment] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [Common].[TemplateAttachment_ToBeDeleted] ADD  DEFAULT ((1)) FOR [Status]
GO
ALTER TABLE [Common].[TemplateAttachment_ToBeDeleted]  WITH CHECK ADD  CONSTRAINT [FK_TemplateAttachment_GenericTemplate] FOREIGN KEY([TemplateId])
REFERENCES [Common].[GenericTemplate] ([Id])
GO
ALTER TABLE [Common].[TemplateAttachment_ToBeDeleted] CHECK CONSTRAINT [FK_TemplateAttachment_GenericTemplate]
GO
ALTER TABLE [Common].[TemplateAttachment_ToBeDeleted]  WITH CHECK ADD  CONSTRAINT [FK_TemplateAttachment_MediaRepository] FOREIGN KEY([MediaRepositoryId])
REFERENCES [Common].[MediaRepository] ([Id])
GO
ALTER TABLE [Common].[TemplateAttachment_ToBeDeleted] CHECK CONSTRAINT [FK_TemplateAttachment_MediaRepository]
GO
