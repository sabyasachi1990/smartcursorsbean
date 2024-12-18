USE [SmartCursorSTG]
GO
/****** Object:  Table [Tax].[PlanningMateriality_ToBeDeleted]    Script Date: 16-12-2024 9.30.57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Tax].[PlanningMateriality_ToBeDeleted](
	[Id] [uniqueidentifier] NOT NULL,
	[CompanyId] [bigint] NOT NULL,
	[TaxCompanyId] [uniqueidentifier] NULL,
	[EngagementId] [uniqueidentifier] NOT NULL,
	[PlanningMaterialitySetupId] [uniqueidentifier] NOT NULL,
	[Rationale] [nvarchar](1000) NULL,
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
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Tax].[PlanningMateriality_ToBeDeleted] ADD  DEFAULT ((1)) FOR [Status]
GO
ALTER TABLE [Tax].[PlanningMateriality_ToBeDeleted]  WITH CHECK ADD  CONSTRAINT [FK_PlanningMateriality_Company] FOREIGN KEY([CompanyId])
REFERENCES [Common].[Company] ([Id])
GO
ALTER TABLE [Tax].[PlanningMateriality_ToBeDeleted] CHECK CONSTRAINT [FK_PlanningMateriality_Company]
GO
ALTER TABLE [Tax].[PlanningMateriality_ToBeDeleted]  WITH CHECK ADD  CONSTRAINT [FK_PlanningMateriality_PlanningMaterialitySetup] FOREIGN KEY([PlanningMaterialitySetupId])
REFERENCES [Tax].[PlanningMaterialitySetup_ToBeDeleted] ([Id])
GO
ALTER TABLE [Tax].[PlanningMateriality_ToBeDeleted] CHECK CONSTRAINT [FK_PlanningMateriality_PlanningMaterialitySetup]
GO
ALTER TABLE [Tax].[PlanningMateriality_ToBeDeleted]  WITH CHECK ADD  CONSTRAINT [FK_PlanningMateriality_TaxCompany] FOREIGN KEY([TaxCompanyId])
REFERENCES [Tax].[TaxCompany] ([Id])
GO
ALTER TABLE [Tax].[PlanningMateriality_ToBeDeleted] CHECK CONSTRAINT [FK_PlanningMateriality_TaxCompany]
GO
ALTER TABLE [Tax].[PlanningMateriality_ToBeDeleted]  WITH CHECK ADD  CONSTRAINT [FK_PlanningMateriality_TaxCompanyEngagement] FOREIGN KEY([EngagementId])
REFERENCES [Tax].[TaxCompanyEngagement] ([Id])
GO
ALTER TABLE [Tax].[PlanningMateriality_ToBeDeleted] CHECK CONSTRAINT [FK_PlanningMateriality_TaxCompanyEngagement]
GO
