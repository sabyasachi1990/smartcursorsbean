USE [SmartCursorSTG]
GO
/****** Object:  Table [Audit].[PlanningMateriality]    Script Date: 16-12-2024 9.30.55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Audit].[PlanningMateriality](
	[Id] [uniqueidentifier] NOT NULL,
	[CompanyId] [bigint] NOT NULL,
	[AuditCompanyId] [uniqueidentifier] NULL,
	[EngagementId] [uniqueidentifier] NOT NULL,
	[PlanningMaterialitySetupId] [uniqueidentifier] NOT NULL,
	[Rationale] [nvarchar](max) NULL,
	[RecOrder] [int] NULL,
	[Remarks] [nvarchar](256) NULL,
	[UserCreated] [nvarchar](254) NULL,
	[CreatedDate] [datetime2](7) NULL,
	[ModifiedBy] [nvarchar](254) NULL,
	[ModifiedDate] [datetime2](7) NULL,
	[Version] [smallint] NULL,
	[Status] [int] NULL,
 CONSTRAINT [PK_PlanningMateriality] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [Audit].[PlanningMateriality] ADD  DEFAULT ((1)) FOR [Status]
GO
ALTER TABLE [Audit].[PlanningMateriality]  WITH CHECK ADD  CONSTRAINT [FK_PlanningMateriality_AuditCompany] FOREIGN KEY([AuditCompanyId])
REFERENCES [Audit].[AuditCompany] ([Id])
GO
ALTER TABLE [Audit].[PlanningMateriality] CHECK CONSTRAINT [FK_PlanningMateriality_AuditCompany]
GO
ALTER TABLE [Audit].[PlanningMateriality]  WITH CHECK ADD  CONSTRAINT [FK_PlanningMateriality_ClientEngagement] FOREIGN KEY([EngagementId])
REFERENCES [Audit].[AuditCompanyEngagement] ([Id])
GO
ALTER TABLE [Audit].[PlanningMateriality] CHECK CONSTRAINT [FK_PlanningMateriality_ClientEngagement]
GO
ALTER TABLE [Audit].[PlanningMateriality]  WITH CHECK ADD  CONSTRAINT [FK_PlanningMateriality_Company] FOREIGN KEY([CompanyId])
REFERENCES [Common].[Company] ([Id])
GO
ALTER TABLE [Audit].[PlanningMateriality] CHECK CONSTRAINT [FK_PlanningMateriality_Company]
GO
ALTER TABLE [Audit].[PlanningMateriality]  WITH CHECK ADD  CONSTRAINT [FK_PlanningMateriality_PlanningMaterialitySetup] FOREIGN KEY([PlanningMaterialitySetupId])
REFERENCES [Audit].[PlanningMaterialitySetup] ([Id])
GO
ALTER TABLE [Audit].[PlanningMateriality] CHECK CONSTRAINT [FK_PlanningMateriality_PlanningMaterialitySetup]
GO
