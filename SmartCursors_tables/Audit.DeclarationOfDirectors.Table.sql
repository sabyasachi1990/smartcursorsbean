USE [SmartCursorSTG]
GO
/****** Object:  Table [Audit].[DeclarationOfDirectors]    Script Date: 16-12-2024 9.30.55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Audit].[DeclarationOfDirectors](
	[Id] [uniqueidentifier] NOT NULL,
	[PlanningAndCompletionSetUpId] [uniqueidentifier] NULL,
	[EngagementId] [uniqueidentifier] NOT NULL,
	[AuditCompanyContactId] [uniqueidentifier] NOT NULL,
	[Heading] [nvarchar](100) NULL,
	[Description] [nvarchar](max) NULL,
	[Declaration] [nvarchar](max) NULL,
	[UserCreated] [nvarchar](254) NULL,
	[CreatedDate] [datetime2](7) NULL,
	[ModifiedBy] [nvarchar](254) NULL,
	[ModifiedDate] [datetime2](7) NULL,
	[Status] [int] NULL,
	[Recorder] [int] NULL,
	[Conclusion] [nvarchar](4000) NULL,
	[ConclusionLable] [nvarchar](max) NULL,
 CONSTRAINT [PK_DeclarationOfDirectors] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [Audit].[DeclarationOfDirectors] ADD  DEFAULT ((1)) FOR [Status]
GO
ALTER TABLE [Audit].[DeclarationOfDirectors]  WITH CHECK ADD  CONSTRAINT [FK_DeclarationOfDirectors_AuditCompanyContact] FOREIGN KEY([AuditCompanyContactId])
REFERENCES [Audit].[AuditCompanyContact] ([Id])
GO
ALTER TABLE [Audit].[DeclarationOfDirectors] CHECK CONSTRAINT [FK_DeclarationOfDirectors_AuditCompanyContact]
GO
ALTER TABLE [Audit].[DeclarationOfDirectors]  WITH CHECK ADD  CONSTRAINT [FK_DeclarationOfDirectors_AuditCompanyEngagement] FOREIGN KEY([EngagementId])
REFERENCES [Audit].[AuditCompanyEngagement] ([Id])
GO
ALTER TABLE [Audit].[DeclarationOfDirectors] CHECK CONSTRAINT [FK_DeclarationOfDirectors_AuditCompanyEngagement]
GO
ALTER TABLE [Audit].[DeclarationOfDirectors]  WITH CHECK ADD  CONSTRAINT [FK_DeclarationOfDirectors_PlanningAndCompletionSetUp] FOREIGN KEY([PlanningAndCompletionSetUpId])
REFERENCES [Audit].[PlanningAndCompletionSetUp] ([Id])
GO
ALTER TABLE [Audit].[DeclarationOfDirectors] CHECK CONSTRAINT [FK_DeclarationOfDirectors_PlanningAndCompletionSetUp]
GO
