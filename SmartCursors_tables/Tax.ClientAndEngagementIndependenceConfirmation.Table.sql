USE [SmartCursorSTG]
GO
/****** Object:  Table [Tax].[ClientAndEngagementIndependenceConfirmation]    Script Date: 16-12-2024 9.30.57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Tax].[ClientAndEngagementIndependenceConfirmation](
	[Id] [uniqueidentifier] NOT NULL,
	[EngagementId] [uniqueidentifier] NULL,
	[PlanningAndCompletionSetUpId] [uniqueidentifier] NULL,
	[TaxCompanyContactId] [uniqueidentifier] NULL,
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
ALTER TABLE [Tax].[ClientAndEngagementIndependenceConfirmation] ADD  DEFAULT ((1)) FOR [Status]
GO
ALTER TABLE [Tax].[ClientAndEngagementIndependenceConfirmation]  WITH CHECK ADD  CONSTRAINT [FK_ClientAndEngagementIndependenceConfirmation_PlanningAndCompletionSetUp] FOREIGN KEY([PlanningAndCompletionSetUpId])
REFERENCES [Tax].[PlanningAndCompletionSetUp] ([Id])
GO
ALTER TABLE [Tax].[ClientAndEngagementIndependenceConfirmation] CHECK CONSTRAINT [FK_ClientAndEngagementIndependenceConfirmation_PlanningAndCompletionSetUp]
GO
ALTER TABLE [Tax].[ClientAndEngagementIndependenceConfirmation]  WITH CHECK ADD  CONSTRAINT [FK_ClientAndEngagementIndependenceConfirmation_TaxCompanyContact] FOREIGN KEY([TaxCompanyContactId])
REFERENCES [Tax].[TaxCompanyContact] ([Id])
GO
ALTER TABLE [Tax].[ClientAndEngagementIndependenceConfirmation] CHECK CONSTRAINT [FK_ClientAndEngagementIndependenceConfirmation_TaxCompanyContact]
GO
ALTER TABLE [Tax].[ClientAndEngagementIndependenceConfirmation]  WITH CHECK ADD  CONSTRAINT [FK_ClientAndEngagementIndependenceConfirmation_TaxCompanyEngagement] FOREIGN KEY([EngagementId])
REFERENCES [Tax].[TaxCompanyEngagement] ([Id])
GO
ALTER TABLE [Tax].[ClientAndEngagementIndependenceConfirmation] CHECK CONSTRAINT [FK_ClientAndEngagementIndependenceConfirmation_TaxCompanyEngagement]
GO
