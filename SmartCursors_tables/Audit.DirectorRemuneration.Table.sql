USE [SmartCursorSTG]
GO
/****** Object:  Table [Audit].[DirectorRemuneration]    Script Date: 16-12-2024 9.30.55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Audit].[DirectorRemuneration](
	[Id] [uniqueidentifier] NOT NULL,
	[PlanningAndCompletionSetUpId] [uniqueidentifier] NULL,
	[AuditCompanyContactId] [uniqueidentifier] NULL,
	[EngagementId] [uniqueidentifier] NULL,
	[UserCreated] [nvarchar](254) NULL,
	[CreatedDate] [datetime2](7) NULL,
	[ModifiedBy] [nvarchar](254) NULL,
	[ModifiedDate] [datetime2](7) NULL,
	[Status] [int] NULL,
	[Recorder] [int] NULL,
	[Description] [nvarchar](max) NULL,
	[Conclusion] [nvarchar](max) NULL,
 CONSTRAINT [PK_DirectorRemuneration] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [Audit].[DirectorRemuneration] ADD  DEFAULT ((1)) FOR [Status]
GO
ALTER TABLE [Audit].[DirectorRemuneration]  WITH CHECK ADD  CONSTRAINT [FK_DirectorRemuneration_AuditCompanyContact] FOREIGN KEY([AuditCompanyContactId])
REFERENCES [Audit].[AuditCompanyContact] ([Id])
GO
ALTER TABLE [Audit].[DirectorRemuneration] CHECK CONSTRAINT [FK_DirectorRemuneration_AuditCompanyContact]
GO
ALTER TABLE [Audit].[DirectorRemuneration]  WITH CHECK ADD  CONSTRAINT [FK_DirectorRemuneration_AuditCompanyEngagement] FOREIGN KEY([EngagementId])
REFERENCES [Audit].[AuditCompanyEngagement] ([Id])
GO
ALTER TABLE [Audit].[DirectorRemuneration] CHECK CONSTRAINT [FK_DirectorRemuneration_AuditCompanyEngagement]
GO
ALTER TABLE [Audit].[DirectorRemuneration]  WITH CHECK ADD  CONSTRAINT [FK_DirectorRemuneration_PlanningAndCompletionSetUp] FOREIGN KEY([PlanningAndCompletionSetUpId])
REFERENCES [Audit].[PlanningAndCompletionSetUp] ([Id])
GO
ALTER TABLE [Audit].[DirectorRemuneration] CHECK CONSTRAINT [FK_DirectorRemuneration_PlanningAndCompletionSetUp]
GO
