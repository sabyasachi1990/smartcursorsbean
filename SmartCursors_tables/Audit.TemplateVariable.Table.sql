USE [SmartCursorSTG]
GO
/****** Object:  Table [Audit].[TemplateVariable]    Script Date: 16-12-2024 9.30.55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Audit].[TemplateVariable](
	[Id] [uniqueidentifier] NOT NULL,
	[EngagementId] [uniqueidentifier] NOT NULL,
	[CompanyId] [bigint] NOT NULL,
	[Name] [nvarchar](100) NULL,
	[PropertyName] [nvarchar](400) NULL,
	[PropertValue] [nvarchar](4000) NULL,
	[Status] [int] NULL,
	[PropertyDescription] [nvarchar](4000) NULL,
	[AuditCompanyId] [uniqueidentifier] NULL,
 CONSTRAINT [PK_TemplateVariable] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Audit].[TemplateVariable]  WITH CHECK ADD  CONSTRAINT [FK_TemplateVariable_AuditCompanyEngagement] FOREIGN KEY([EngagementId])
REFERENCES [Audit].[AuditCompanyEngagement] ([Id])
GO
ALTER TABLE [Audit].[TemplateVariable] CHECK CONSTRAINT [FK_TemplateVariable_AuditCompanyEngagement]
GO
ALTER TABLE [Audit].[TemplateVariable]  WITH CHECK ADD  CONSTRAINT [FK_TemplateVariable_Company] FOREIGN KEY([CompanyId])
REFERENCES [Common].[Company] ([Id])
GO
ALTER TABLE [Audit].[TemplateVariable] CHECK CONSTRAINT [FK_TemplateVariable_Company]
GO
