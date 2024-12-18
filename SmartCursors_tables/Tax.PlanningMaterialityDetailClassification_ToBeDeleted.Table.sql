USE [SmartCursorSTG]
GO
/****** Object:  Table [Tax].[PlanningMaterialityDetailClassification_ToBeDeleted]    Script Date: 16-12-2024 9.30.57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Tax].[PlanningMaterialityDetailClassification_ToBeDeleted](
	[Id] [uniqueidentifier] NOT NULL,
	[PlanningMaterialityDetailId] [uniqueidentifier] NOT NULL,
	[TaxCompanyEngagementId] [uniqueidentifier] NOT NULL,
	[LeadSheetId] [uniqueidentifier] NOT NULL,
	[RecOrder] [int] NOT NULL,
 CONSTRAINT [PK_PlanningMaterialityDetailLeadSheet] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Tax].[PlanningMaterialityDetailClassification_ToBeDeleted]  WITH CHECK ADD  CONSTRAINT [FK_PlanningMaterialityDetailLeadSheet_AuditCompanyEngagement] FOREIGN KEY([TaxCompanyEngagementId])
REFERENCES [Tax].[TaxCompanyEngagement] ([Id])
GO
ALTER TABLE [Tax].[PlanningMaterialityDetailClassification_ToBeDeleted] CHECK CONSTRAINT [FK_PlanningMaterialityDetailLeadSheet_AuditCompanyEngagement]
GO
ALTER TABLE [Tax].[PlanningMaterialityDetailClassification_ToBeDeleted]  WITH CHECK ADD  CONSTRAINT [FK_PlanningMaterialityDetailLeadSheet_LeadSheet] FOREIGN KEY([LeadSheetId])
REFERENCES [Tax].[Classification] ([Id])
GO
ALTER TABLE [Tax].[PlanningMaterialityDetailClassification_ToBeDeleted] CHECK CONSTRAINT [FK_PlanningMaterialityDetailLeadSheet_LeadSheet]
GO
ALTER TABLE [Tax].[PlanningMaterialityDetailClassification_ToBeDeleted]  WITH CHECK ADD  CONSTRAINT [FK_PlanningMaterialityDetailLeadSheet_PlanningMaterialityDetail] FOREIGN KEY([PlanningMaterialityDetailId])
REFERENCES [Tax].[PlanningMaterialityDetail_ToBeDeleted] ([Id])
GO
ALTER TABLE [Tax].[PlanningMaterialityDetailClassification_ToBeDeleted] CHECK CONSTRAINT [FK_PlanningMaterialityDetailLeadSheet_PlanningMaterialityDetail]
GO
