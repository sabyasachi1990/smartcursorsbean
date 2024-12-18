USE [SmartCursorSTG]
GO
/****** Object:  Table [Audit].[PlanningMaterialitySetupDetail]    Script Date: 16-12-2024 9.30.55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Audit].[PlanningMaterialitySetupDetail](
	[Id] [uniqueidentifier] NOT NULL,
	[PlanningMaterialitySetupId] [uniqueidentifier] NOT NULL,
	[SystemType] [nvarchar](30) NULL,
	[IsNA] [bit] NOT NULL,
	[Type] [nvarchar](20) NULL,
	[Amount] [decimal](10, 2) NULL,
	[LeadSheetShortCode] [nvarchar](10) NULL,
	[LeadSheeType] [nvarchar](100) NULL,
	[TypeName] [nvarchar](30) NULL,
	[LowRange] [decimal](5, 2) NULL,
	[HighRange] [decimal](5, 2) NULL,
	[IsIncrementedByApplicable] [bit] NULL,
	[IncrementedBy] [nvarchar](100) NULL,
	[IsAllowExceed] [bit] NULL,
	[RecOrder] [int] NULL,
 CONSTRAINT [PK_PlanningMaterialitySetupDetail] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Audit].[PlanningMaterialitySetupDetail] ADD  DEFAULT ((0)) FOR [IsIncrementedByApplicable]
GO
ALTER TABLE [Audit].[PlanningMaterialitySetupDetail] ADD  DEFAULT ((0)) FOR [IsAllowExceed]
GO
ALTER TABLE [Audit].[PlanningMaterialitySetupDetail]  WITH CHECK ADD  CONSTRAINT [FK_PlanningMaterialitySetupDetail_PlanningMaterialitySetupDetail] FOREIGN KEY([PlanningMaterialitySetupId])
REFERENCES [Audit].[PlanningMaterialitySetup] ([Id])
GO
ALTER TABLE [Audit].[PlanningMaterialitySetupDetail] CHECK CONSTRAINT [FK_PlanningMaterialitySetupDetail_PlanningMaterialitySetupDetail]
GO
