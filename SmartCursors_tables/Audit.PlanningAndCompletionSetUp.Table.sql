USE [SmartCursorSTG]
GO
/****** Object:  Table [Audit].[PlanningAndCompletionSetUp]    Script Date: 16-12-2024 9.30.55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Audit].[PlanningAndCompletionSetUp](
	[Id] [uniqueidentifier] NOT NULL,
	[CompanyId] [bigint] NOT NULL,
	[AuditCompanyId] [uniqueidentifier] NULL,
	[EngagementId] [uniqueidentifier] NULL,
	[ModuleDetailId] [bigint] NULL,
	[Type] [nvarchar](20) NULL,
	[MenuCode] [nvarchar](50) NULL,
	[MenuName] [nvarchar](400) NULL,
	[Description] [nvarchar](max) NULL,
	[FormType] [nvarchar](20) NULL,
	[Remarks] [nvarchar](max) NULL,
	[UserCreated] [nvarchar](254) NULL,
	[CreatedDate] [datetime2](7) NULL,
	[ModifiedBy] [nvarchar](254) NULL,
	[ModifiedDate] [datetime2](7) NULL,
	[Status] [int] NULL,
	[Recorder] [int] NULL,
	[EngagementType] [nvarchar](50) NULL,
	[Conclusion] [nvarchar](4000) NULL,
	[IsMigrated] [bit] NULL,
	[ConclusionLable] [nvarchar](max) NULL,
	[SelectedDirectors] [nvarchar](max) NULL,
	[TypeId] [uniqueidentifier] NULL,
	[EngagementTypeId] [uniqueidentifier] NULL,
	[IsSignPartner] [bit] NULL,
	[AuditManualId] [uniqueidentifier] NULL,
	[MasterId] [uniqueidentifier] NULL,
	[Title] [nvarchar](4000) NULL,
	[EnableDescription] [bit] NULL,
 CONSTRAINT [PK_PlanningAndCompletionSetUp] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [Audit].[PlanningAndCompletionSetUp] ADD  DEFAULT ((1)) FOR [Status]
GO
ALTER TABLE [Audit].[PlanningAndCompletionSetUp]  WITH CHECK ADD  CONSTRAINT [FK_PlanningAndCompletionSetUp_AuditCompany] FOREIGN KEY([AuditCompanyId])
REFERENCES [Audit].[AuditCompany] ([Id])
GO
ALTER TABLE [Audit].[PlanningAndCompletionSetUp] CHECK CONSTRAINT [FK_PlanningAndCompletionSetUp_AuditCompany]
GO
ALTER TABLE [Audit].[PlanningAndCompletionSetUp]  WITH CHECK ADD  CONSTRAINT [FK_PlanningAndCompletionSetUp_AuditCompanyEngagement] FOREIGN KEY([EngagementId])
REFERENCES [Audit].[AuditCompanyEngagement] ([Id])
GO
ALTER TABLE [Audit].[PlanningAndCompletionSetUp] CHECK CONSTRAINT [FK_PlanningAndCompletionSetUp_AuditCompanyEngagement]
GO
ALTER TABLE [Audit].[PlanningAndCompletionSetUp]  WITH CHECK ADD  CONSTRAINT [FK_PlanningAndCompletionSetUp_Company] FOREIGN KEY([CompanyId])
REFERENCES [Common].[Company] ([Id])
GO
ALTER TABLE [Audit].[PlanningAndCompletionSetUp] CHECK CONSTRAINT [FK_PlanningAndCompletionSetUp_Company]
GO
ALTER TABLE [Audit].[PlanningAndCompletionSetUp]  WITH CHECK ADD  CONSTRAINT [FK_PlanningAndCompletionSetUp_ModuleDetail] FOREIGN KEY([ModuleDetailId])
REFERENCES [Common].[ModuleDetail] ([Id])
GO
ALTER TABLE [Audit].[PlanningAndCompletionSetUp] CHECK CONSTRAINT [FK_PlanningAndCompletionSetUp_ModuleDetail]
GO
ALTER TABLE [Audit].[PlanningAndCompletionSetUp]  WITH CHECK ADD  CONSTRAINT [FK_planningandcompletionsetup_planningandcompletionsetupMaster] FOREIGN KEY([MasterId])
REFERENCES [Audit].[PlanningAndCompletionSetUpMaster] ([Id])
GO
ALTER TABLE [Audit].[PlanningAndCompletionSetUp] CHECK CONSTRAINT [FK_planningandcompletionsetup_planningandcompletionsetupMaster]
GO
