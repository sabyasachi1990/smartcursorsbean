USE [SmartCursorSTG]
GO
/****** Object:  Table [Audit].[PlanningMaterialityDetailLeadSheet]    Script Date: 16-12-2024 9.30.55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Audit].[PlanningMaterialityDetailLeadSheet](
	[Id] [uniqueidentifier] NOT NULL,
	[PlanningMaterialityDetailId] [uniqueidentifier] NOT NULL,
	[AuditCompanyEngagementId] [uniqueidentifier] NOT NULL,
	[LeadSheetId] [uniqueidentifier] NOT NULL,
	[RecOrder] [int] NOT NULL,
 CONSTRAINT [PK_PlanningMaterialityDetailLeadSheet] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Audit].[PlanningMaterialityDetailLeadSheet]  WITH CHECK ADD  CONSTRAINT [FK_PlanningMaterialityDetailLeadSheet_AuditCompanyEngagement] FOREIGN KEY([AuditCompanyEngagementId])
REFERENCES [Audit].[AuditCompanyEngagement] ([Id])
GO
ALTER TABLE [Audit].[PlanningMaterialityDetailLeadSheet] CHECK CONSTRAINT [FK_PlanningMaterialityDetailLeadSheet_AuditCompanyEngagement]
GO
ALTER TABLE [Audit].[PlanningMaterialityDetailLeadSheet]  WITH CHECK ADD  CONSTRAINT [FK_PlanningMaterialityDetailLeadSheet_LeadSheet] FOREIGN KEY([LeadSheetId])
REFERENCES [Audit].[LeadSheet] ([Id])
GO
ALTER TABLE [Audit].[PlanningMaterialityDetailLeadSheet] CHECK CONSTRAINT [FK_PlanningMaterialityDetailLeadSheet_LeadSheet]
GO
ALTER TABLE [Audit].[PlanningMaterialityDetailLeadSheet]  WITH CHECK ADD  CONSTRAINT [FK_PlanningMaterialityDetailLeadSheet_PlanningMaterialityDetail] FOREIGN KEY([PlanningMaterialityDetailId])
REFERENCES [Audit].[PlanningMaterialityDetail] ([Id])
GO
ALTER TABLE [Audit].[PlanningMaterialityDetailLeadSheet] CHECK CONSTRAINT [FK_PlanningMaterialityDetailLeadSheet_PlanningMaterialityDetail]
GO
