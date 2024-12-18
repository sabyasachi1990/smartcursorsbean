USE [SmartCursorSTG]
GO
/****** Object:  Table [Audit].[AuditTemplateReset]    Script Date: 16-12-2024 9.30.55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Audit].[AuditTemplateReset](
	[Id] [uniqueidentifier] NULL,
	[TemplateId] [nvarchar](400) NULL,
	[EngagementId] [uniqueidentifier] NULL,
	[FilePath] [nvarchar](max) NULL,
	[FileName] [nvarchar](400) NULL,
	[FeatureName] [nvarchar](400) NULL,
	[NoteCode] [nvarchar](50) NULL,
	[DynamicGridTemplateName] [nvarchar](400) NULL,
	[Issection] [bit] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
