USE [SmartCursorSTG]
GO
/****** Object:  Table [Tax].[DirectorRemuneration]    Script Date: 16-12-2024 9.30.57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Tax].[DirectorRemuneration](
	[Id] [uniqueidentifier] NOT NULL,
	[PlanningAndCompletionSetUpId] [uniqueidentifier] NULL,
	[TaxCompanyContactId] [uniqueidentifier] NULL,
	[EngagementId] [uniqueidentifier] NULL,
	[UserCreated] [nvarchar](254) NULL,
	[CreatedDate] [datetime2](7) NULL,
	[ModifiedBy] [nvarchar](254) NULL,
	[ModifiedDate] [datetime2](7) NULL,
	[Status] [int] NULL,
	[Recorder] [int] NULL,
	[Description] [nvarchar](max) NULL,
 CONSTRAINT [PK_DirectorRemuneration] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [Tax].[DirectorRemuneration] ADD  DEFAULT ((1)) FOR [Status]
GO
ALTER TABLE [Tax].[DirectorRemuneration]  WITH CHECK ADD  CONSTRAINT [FK_DirectorRemuneration_PlanningAndCompletionSetUp] FOREIGN KEY([PlanningAndCompletionSetUpId])
REFERENCES [Tax].[PlanningAndCompletionSetUp] ([Id])
GO
ALTER TABLE [Tax].[DirectorRemuneration] CHECK CONSTRAINT [FK_DirectorRemuneration_PlanningAndCompletionSetUp]
GO
ALTER TABLE [Tax].[DirectorRemuneration]  WITH CHECK ADD  CONSTRAINT [FK_DirectorRemuneration_TaxCompanyContact] FOREIGN KEY([TaxCompanyContactId])
REFERENCES [Tax].[TaxCompanyContact] ([Id])
GO
ALTER TABLE [Tax].[DirectorRemuneration] CHECK CONSTRAINT [FK_DirectorRemuneration_TaxCompanyContact]
GO
ALTER TABLE [Tax].[DirectorRemuneration]  WITH CHECK ADD  CONSTRAINT [FK_DirectorRemuneration_TaxCompanyEngagement] FOREIGN KEY([EngagementId])
REFERENCES [Tax].[TaxCompanyEngagement] ([Id])
GO
ALTER TABLE [Tax].[DirectorRemuneration] CHECK CONSTRAINT [FK_DirectorRemuneration_TaxCompanyEngagement]
GO
