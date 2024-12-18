USE [SmartCursorSTG]
GO
/****** Object:  Table [Audit].[ReportingTemplates]    Script Date: 16-12-2024 9.30.55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Audit].[ReportingTemplates](
	[Id] [uniqueidentifier] NOT NULL,
	[PartnerCompanyId] [bigint] NOT NULL,
	[EngagementId] [uniqueidentifier] NULL,
	[TemplateName] [nvarchar](4000) NULL,
	[UserCreated] [varchar](254) NULL,
	[CreatedDate] [datetime2](7) NULL,
	[ModifiedBy] [nvarchar](254) NULL,
	[ModifiedDate] [datetime2](7) NULL,
	[Status] [int] NULL,
	[DisclosureId] [uniqueidentifier] NULL,
	[EffectiveFrom] [datetime2](7) NULL,
	[EffectiveTo] [datetime2](7) NULL,
	[TypeId] [uniqueidentifier] NULL,
	[TemplateStatus] [nvarchar](100) NULL,
	[FSTemplateId] [uniqueidentifier] NULL,
 CONSTRAINT [PK_ReportingTemplates] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Audit].[ReportingTemplates] ADD  DEFAULT (getdate()) FOR [CreatedDate]
GO
ALTER TABLE [Audit].[ReportingTemplates] ADD  DEFAULT ((1)) FOR [Status]
GO
ALTER TABLE [Audit].[ReportingTemplates]  WITH CHECK ADD  CONSTRAINT [FK_ReportingTemplates_AuditCompanyEngagement] FOREIGN KEY([EngagementId])
REFERENCES [Audit].[AuditCompanyEngagement] ([Id])
GO
ALTER TABLE [Audit].[ReportingTemplates] CHECK CONSTRAINT [FK_ReportingTemplates_AuditCompanyEngagement]
GO
ALTER TABLE [Audit].[ReportingTemplates]  WITH CHECK ADD  CONSTRAINT [FK_ReportingTemplates_Company] FOREIGN KEY([PartnerCompanyId])
REFERENCES [Common].[Company] ([Id])
GO
ALTER TABLE [Audit].[ReportingTemplates] CHECK CONSTRAINT [FK_ReportingTemplates_Company]
GO
