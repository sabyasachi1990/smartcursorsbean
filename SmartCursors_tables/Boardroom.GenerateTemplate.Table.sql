USE [SmartCursorSTG]
GO
/****** Object:  Table [Boardroom].[GenerateTemplate]    Script Date: 16-12-2024 9.30.56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Boardroom].[GenerateTemplate](
	[Id] [uniqueidentifier] NOT NULL,
	[ChangesId] [uniqueidentifier] NULL,
	[DocId] [uniqueidentifier] NULL,
	[FollowUp] [datetime2](7) NULL,
	[Count] [int] NULL,
	[TemplateContent] [nvarchar](max) NOT NULL,
	[TemplateName] [nvarchar](100) NOT NULL,
	[Description] [nvarchar](max) NULL,
	[UserCreated] [nvarchar](250) NULL,
	[ModifiedBy] [nvarchar](250) NULL,
	[ModifiedDate] [datetime2](7) NULL,
	[CreatedDate] [datetime2](7) NULL,
	[TemplateStatus] [nvarchar](50) NULL,
	[Status] [int] NULL,
	[GenericTemplateId] [uniqueidentifier] NULL,
	[FilePath] [nvarchar](max) NULL,
	[FileName] [nvarchar](max) NULL,
	[TemplateGroup] [nvarchar](200) NULL,
	[GenericTemplateDetailId] [uniqueidentifier] NULL,
	[AzurePath] [nvarchar](max) NULL,
	[IsTemp] [bit] NULL,
	[MenuId] [uniqueidentifier] NULL,
	[SubMenuId] [uniqueidentifier] NULL,
	[DynamicTemplateId] [uniqueidentifier] NULL,
 CONSTRAINT [PK_GenerateTemplate] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [Boardroom].[GenerateTemplate] ADD  DEFAULT ((1)) FOR [Status]
GO
ALTER TABLE [Boardroom].[GenerateTemplate]  WITH CHECK ADD FOREIGN KEY([DynamicTemplateId])
REFERENCES [Boardroom].[DynamicTemplates] ([Id])
GO
ALTER TABLE [Boardroom].[GenerateTemplate]  WITH CHECK ADD FOREIGN KEY([GenericTemplateDetailId])
REFERENCES [Common].[GenericTemplateDetail] ([Id])
GO
ALTER TABLE [Boardroom].[GenerateTemplate]  WITH CHECK ADD FOREIGN KEY([MenuId])
REFERENCES [Common].[TemplateType] ([Id])
GO
ALTER TABLE [Boardroom].[GenerateTemplate]  WITH CHECK ADD FOREIGN KEY([MenuId])
REFERENCES [Common].[TemplateType] ([Id])
GO
ALTER TABLE [Boardroom].[GenerateTemplate]  WITH CHECK ADD FOREIGN KEY([SubMenuId])
REFERENCES [Common].[TemplateTypeDetail] ([Id])
GO
ALTER TABLE [Boardroom].[GenerateTemplate]  WITH CHECK ADD FOREIGN KEY([SubMenuId])
REFERENCES [Common].[TemplateTypeDetail] ([Id])
GO
ALTER TABLE [Boardroom].[GenerateTemplate]  WITH CHECK ADD  CONSTRAINT [FK_GenerateTemplate_Changes] FOREIGN KEY([ChangesId])
REFERENCES [Boardroom].[Changes] ([Id])
GO
ALTER TABLE [Boardroom].[GenerateTemplate] CHECK CONSTRAINT [FK_GenerateTemplate_Changes]
GO
