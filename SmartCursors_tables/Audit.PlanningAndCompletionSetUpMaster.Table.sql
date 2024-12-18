USE [SmartCursorSTG]
GO
/****** Object:  Table [Audit].[PlanningAndCompletionSetUpMaster]    Script Date: 16-12-2024 9.30.55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Audit].[PlanningAndCompletionSetUpMaster](
	[Id] [uniqueidentifier] NOT NULL,
	[CompanyId] [bigint] NOT NULL,
	[AuditManualId] [uniqueidentifier] NULL,
	[EngagementTypeId] [uniqueidentifier] NULL,
	[UserCreated] [nvarchar](256) NULL,
	[CreatedDate] [datetime2](7) NULL,
	[ModifiedBy] [nvarchar](256) NULL,
	[ModifiedDate] [datetime2](7) NULL,
	[Status] [int] NULL,
 CONSTRAINT [PK_planningandcompletionsetupMaster] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Audit].[PlanningAndCompletionSetUpMaster]  WITH CHECK ADD  CONSTRAINT [FK_planningandcompletionsetupMaster_AuditManual] FOREIGN KEY([AuditManualId])
REFERENCES [Audit].[AuditManual] ([Id])
GO
ALTER TABLE [Audit].[PlanningAndCompletionSetUpMaster] CHECK CONSTRAINT [FK_planningandcompletionsetupMaster_AuditManual]
GO
ALTER TABLE [Audit].[PlanningAndCompletionSetUpMaster]  WITH CHECK ADD  CONSTRAINT [FK_planningandcompletionsetupMaster_Company] FOREIGN KEY([CompanyId])
REFERENCES [Common].[Company] ([Id])
GO
ALTER TABLE [Audit].[PlanningAndCompletionSetUpMaster] CHECK CONSTRAINT [FK_planningandcompletionsetupMaster_Company]
GO
ALTER TABLE [Audit].[PlanningAndCompletionSetUpMaster]  WITH CHECK ADD  CONSTRAINT [FK_planningandcompletionsetupMaster_EngagementType] FOREIGN KEY([EngagementTypeId])
REFERENCES [Audit].[EngagementType] ([Id])
GO
ALTER TABLE [Audit].[PlanningAndCompletionSetUpMaster] CHECK CONSTRAINT [FK_planningandcompletionsetupMaster_EngagementType]
GO
