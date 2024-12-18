USE [SmartCursorSTG]
GO
/****** Object:  Table [Tax].[TemplateVariable]    Script Date: 16-12-2024 9.30.57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Tax].[TemplateVariable](
	[Id] [uniqueidentifier] NOT NULL,
	[EngagementId] [uniqueidentifier] NOT NULL,
	[CompanyId] [bigint] NOT NULL,
	[Name] [nvarchar](100) NULL,
	[PropertyName] [nvarchar](400) NULL,
	[PropertValue] [nvarchar](4000) NULL,
	[IsCrossReport] [bit] NULL,
	[IsCrossReportAssign] [bit] NULL,
	[Status] [int] NULL,
	[PropertyDescription] [nvarchar](4000) NULL,
	[IsUsed] [bit] NOT NULL,
 CONSTRAINT [PK_TemplateVariable] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Tax].[TemplateVariable] ADD  DEFAULT ((0)) FOR [IsCrossReport]
GO
ALTER TABLE [Tax].[TemplateVariable] ADD  DEFAULT ((0)) FOR [IsCrossReportAssign]
GO
ALTER TABLE [Tax].[TemplateVariable] ADD  DEFAULT ((0)) FOR [IsUsed]
GO
ALTER TABLE [Tax].[TemplateVariable]  WITH CHECK ADD  CONSTRAINT [FK_TemplateVariable_Company] FOREIGN KEY([CompanyId])
REFERENCES [Common].[Company] ([Id])
GO
ALTER TABLE [Tax].[TemplateVariable] CHECK CONSTRAINT [FK_TemplateVariable_Company]
GO
ALTER TABLE [Tax].[TemplateVariable]  WITH CHECK ADD  CONSTRAINT [FK_TemplateVariable_TaxCompanyEngagement] FOREIGN KEY([EngagementId])
REFERENCES [Tax].[TaxCompanyEngagement] ([Id])
GO
ALTER TABLE [Tax].[TemplateVariable] CHECK CONSTRAINT [FK_TemplateVariable_TaxCompanyEngagement]
GO
