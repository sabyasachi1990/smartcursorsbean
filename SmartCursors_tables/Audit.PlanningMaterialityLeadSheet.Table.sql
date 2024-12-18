USE [SmartCursorSTG]
GO
/****** Object:  Table [Audit].[PlanningMaterialityLeadSheet]    Script Date: 16-12-2024 9.30.55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Audit].[PlanningMaterialityLeadSheet](
	[Id] [uniqueidentifier] NOT NULL,
	[PlanningMaterialitySetupDetailId] [uniqueidentifier] NOT NULL,
	[LeadSheetId] [uniqueidentifier] NOT NULL,
	[RecOrder] [int] NOT NULL,
 CONSTRAINT [PK_PlanningMaterialityLeadSheet] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Audit].[PlanningMaterialityLeadSheet]  WITH CHECK ADD  CONSTRAINT [FK_PlanningMaterialityLeadSheet_LeadSheet] FOREIGN KEY([LeadSheetId])
REFERENCES [Audit].[LeadSheet] ([Id])
GO
ALTER TABLE [Audit].[PlanningMaterialityLeadSheet] CHECK CONSTRAINT [FK_PlanningMaterialityLeadSheet_LeadSheet]
GO
ALTER TABLE [Audit].[PlanningMaterialityLeadSheet]  WITH CHECK ADD  CONSTRAINT [FK_PlanningMaterialityLeadSheet_PlanningMaterialitySetupDetail] FOREIGN KEY([PlanningMaterialitySetupDetailId])
REFERENCES [Audit].[PlanningMaterialitySetupDetail] ([Id])
GO
ALTER TABLE [Audit].[PlanningMaterialityLeadSheet] CHECK CONSTRAINT [FK_PlanningMaterialityLeadSheet_PlanningMaterialitySetupDetail]
GO
