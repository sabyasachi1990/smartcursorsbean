USE [SmartCursorSTG]
GO
/****** Object:  Table [Audit].[PlanningMaterialitySetup]    Script Date: 16-12-2024 9.30.55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Audit].[PlanningMaterialitySetup](
	[Id] [uniqueidentifier] NOT NULL,
	[CompanyId] [bigint] NOT NULL,
	[ShortCode] [nvarchar](10) NULL,
	[Decsription] [nvarchar](256) NULL,
	[Rationale] [nvarchar](1000) NULL,
	[RecOrder] [int] NULL,
	[UserCreated] [nvarchar](256) NULL,
	[CreatedDate] [datetime2](7) NULL,
	[ModifiedBy] [nvarchar](256) NULL,
	[ModifiedDate] [datetime2](7) NULL,
	[Status] [int] NULL,
	[ReferenceId] [uniqueidentifier] NULL,
	[EngagementId] [uniqueidentifier] NULL,
	[TemplateStatus] [nvarchar](100) NULL,
	[AuditManual] [nvarchar](150) NULL,
	[AuditManualId] [uniqueidentifier] NULL,
 CONSTRAINT [PK_PlanningMaterialitySetup] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Audit].[PlanningMaterialitySetup] ADD  DEFAULT ((1)) FOR [Status]
GO
ALTER TABLE [Audit].[PlanningMaterialitySetup]  WITH CHECK ADD  CONSTRAINT [FK_PlanningMateriality_AuditCompanyEngagement] FOREIGN KEY([EngagementId])
REFERENCES [Audit].[AuditCompanyEngagement] ([Id])
GO
ALTER TABLE [Audit].[PlanningMaterialitySetup] CHECK CONSTRAINT [FK_PlanningMateriality_AuditCompanyEngagement]
GO
ALTER TABLE [Audit].[PlanningMaterialitySetup]  WITH CHECK ADD  CONSTRAINT [FK_PlanningMaterialitySetup_Company] FOREIGN KEY([CompanyId])
REFERENCES [Common].[Company] ([Id])
GO
ALTER TABLE [Audit].[PlanningMaterialitySetup] CHECK CONSTRAINT [FK_PlanningMaterialitySetup_Company]
GO
