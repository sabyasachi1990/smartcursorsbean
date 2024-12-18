USE [SmartCursorSTG]
GO
/****** Object:  Table [Tax].[PlanningMaterialityClassification_ToBeDeleted]    Script Date: 16-12-2024 9.30.57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Tax].[PlanningMaterialityClassification_ToBeDeleted](
	[Id] [uniqueidentifier] NOT NULL,
	[PlanningMaterialitySetupDetailId] [uniqueidentifier] NOT NULL,
	[ClassificationId] [uniqueidentifier] NOT NULL,
	[RecOrder] [int] NOT NULL,
 CONSTRAINT [PK_PlanningMaterialityClassification] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Tax].[PlanningMaterialityClassification_ToBeDeleted]  WITH CHECK ADD  CONSTRAINT [FK_PlanningMaterialityClassification_Classification] FOREIGN KEY([ClassificationId])
REFERENCES [Tax].[Classification] ([Id])
GO
ALTER TABLE [Tax].[PlanningMaterialityClassification_ToBeDeleted] CHECK CONSTRAINT [FK_PlanningMaterialityClassification_Classification]
GO
ALTER TABLE [Tax].[PlanningMaterialityClassification_ToBeDeleted]  WITH CHECK ADD  CONSTRAINT [FK_PlanningMaterialityClassification_PlanningMaterialitySetupDetail] FOREIGN KEY([PlanningMaterialitySetupDetailId])
REFERENCES [Tax].[PlanningMaterialitySetupDetail_ToBeDeleted] ([Id])
GO
ALTER TABLE [Tax].[PlanningMaterialityClassification_ToBeDeleted] CHECK CONSTRAINT [FK_PlanningMaterialityClassification_PlanningMaterialitySetupDetail]
GO
