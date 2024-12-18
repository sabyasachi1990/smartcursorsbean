USE [SmartCursorSTG]
GO
/****** Object:  Table [Common].[Suggestion ]    Script Date: 16-12-2024 9.30.56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Common].[Suggestion ](
	[Id] [uniqueidentifier] NOT NULL,
	[CompanyId] [bigint] NULL,
	[ScreenName] [nvarchar](254) NULL,
	[Section] [nvarchar](254) NULL,
	[Title] [nvarchar](50) NULL,
	[Description] [nvarchar](max) NULL,
	[Remarks] [nvarchar](256) NULL,
	[RecOrder] [int] NULL,
	[UserCreated] [varchar](254) NULL,
	[CreatedDate] [datetime2](7) NULL,
	[ModifiedBy] [nvarchar](254) NULL,
	[ModifiedDate] [datetime2](7) NULL,
	[Version] [smallint] NULL,
	[Status] [int] NULL,
	[ReferenceId] [uniqueidentifier] NULL,
	[EngagementId] [uniqueidentifier] NULL,
	[AuditManualId] [uniqueidentifier] NULL,
	[MasterId] [uniqueidentifier] NULL,
 CONSTRAINT [PK_Suggestion] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [Common].[Suggestion ] ADD  DEFAULT (getdate()) FOR [CreatedDate]
GO
ALTER TABLE [Common].[Suggestion ] ADD  DEFAULT ((1)) FOR [Status]
GO
ALTER TABLE [Common].[Suggestion ]  WITH CHECK ADD  CONSTRAINT [FK_Suggestion_AuditCompanyEngagement] FOREIGN KEY([EngagementId])
REFERENCES [Audit].[AuditCompanyEngagement] ([Id])
GO
ALTER TABLE [Common].[Suggestion ] CHECK CONSTRAINT [FK_Suggestion_AuditCompanyEngagement]
GO
ALTER TABLE [Common].[Suggestion ]  WITH CHECK ADD  CONSTRAINT [FK_Suggestion_Company] FOREIGN KEY([CompanyId])
REFERENCES [Common].[Company] ([Id])
GO
ALTER TABLE [Common].[Suggestion ] CHECK CONSTRAINT [FK_Suggestion_Company]
GO
ALTER TABLE [Common].[Suggestion ]  WITH CHECK ADD  CONSTRAINT [FK_Suggestion_SuggestionSetUpmasterId] FOREIGN KEY([MasterId])
REFERENCES [Audit].[SuggestionSetUpMaster] ([Id])
GO
ALTER TABLE [Common].[Suggestion ] CHECK CONSTRAINT [FK_Suggestion_SuggestionSetUpmasterId]
GO
