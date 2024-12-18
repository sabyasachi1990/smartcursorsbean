USE [SmartCursorSTG]
GO
/****** Object:  Table [Audit].[ClientAndEngagementIndependenceConfirmation]    Script Date: 16-12-2024 9.30.55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Audit].[ClientAndEngagementIndependenceConfirmation](
	[Id] [uniqueidentifier] NOT NULL,
	[EngagementId] [uniqueidentifier] NULL,
	[PlanningAndCompletionSetUpId] [uniqueidentifier] NULL,
	[AuditCompanyContactId] [uniqueidentifier] NULL,
	[Heading] [nvarchar](100) NULL,
	[Description] [nvarchar](max) NULL,
	[UserId] [uniqueidentifier] NULL,
	[Role] [nvarchar](20) NULL,
	[IsSigned] [bit] NULL,
	[SigtureDate] [datetime2](7) NULL,
	[Remarks] [nvarchar](4000) NULL,
	[UserCreated] [nvarchar](254) NULL,
	[CreatedDate] [datetime2](7) NULL,
	[ModifiedBy] [nvarchar](254) NULL,
	[ModifiedDate] [datetime2](7) NULL,
	[Status] [int] NULL,
	[Recorder] [int] NULL,
	[ConclusionLable] [nvarchar](max) NULL,
	[Conclusion] [nvarchar](4000) NULL,
 CONSTRAINT [PK_ClientAndEngagementIndependenceConfirmation] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [Audit].[ClientAndEngagementIndependenceConfirmation] ADD  DEFAULT ((1)) FOR [Status]
GO
ALTER TABLE [Audit].[ClientAndEngagementIndependenceConfirmation]  WITH CHECK ADD  CONSTRAINT [FK_ClientAndEngagementIndependenceConfirmation_AuditCompanyContact] FOREIGN KEY([AuditCompanyContactId])
REFERENCES [Audit].[AuditCompanyContact] ([Id])
GO
ALTER TABLE [Audit].[ClientAndEngagementIndependenceConfirmation] CHECK CONSTRAINT [FK_ClientAndEngagementIndependenceConfirmation_AuditCompanyContact]
GO
ALTER TABLE [Audit].[ClientAndEngagementIndependenceConfirmation]  WITH CHECK ADD  CONSTRAINT [FK_ClientAndEngagementIndependenceConfirmation_AuditCompanyEngagement] FOREIGN KEY([EngagementId])
REFERENCES [Audit].[AuditCompanyEngagement] ([Id])
GO
ALTER TABLE [Audit].[ClientAndEngagementIndependenceConfirmation] CHECK CONSTRAINT [FK_ClientAndEngagementIndependenceConfirmation_AuditCompanyEngagement]
GO
ALTER TABLE [Audit].[ClientAndEngagementIndependenceConfirmation]  WITH CHECK ADD  CONSTRAINT [FK_ClientAndEngagementIndependenceConfirmation_PlanningAndCompletionSetUp] FOREIGN KEY([PlanningAndCompletionSetUpId])
REFERENCES [Audit].[PlanningAndCompletionSetUp] ([Id])
GO
ALTER TABLE [Audit].[ClientAndEngagementIndependenceConfirmation] CHECK CONSTRAINT [FK_ClientAndEngagementIndependenceConfirmation_PlanningAndCompletionSetUp]
GO
