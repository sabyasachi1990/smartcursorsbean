USE [SmartCursorSTG]
GO
/****** Object:  Table [Audit].[Questionnaire_ToBeDeleted]    Script Date: 16-12-2024 9.30.55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Audit].[Questionnaire_ToBeDeleted](
	[Id] [uniqueidentifier] NOT NULL,
	[CompanyId] [bigint] NOT NULL,
	[AuditCompanyId] [uniqueidentifier] NULL,
	[AuditCompanyEngagementId] [uniqueidentifier] NULL,
	[Name] [nvarchar](4000) NOT NULL,
	[Type] [nvarchar](4000) NULL,
	[Description] [nvarchar](4000) NULL,
	[MetaData] [nvarchar](4000) NULL,
	[AdditionalText] [nvarchar](max) NULL,
	[UserCreated] [nvarchar](254) NULL,
	[CreatedDate] [datetime2](7) NULL,
	[ModifiedBy] [nvarchar](254) NULL,
	[ModifiedDate] [datetime2](7) NULL,
	[Version] [smallint] NULL,
	[Status] [int] NULL,
 CONSTRAINT [PK_Questionnaire] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [Audit].[Questionnaire_ToBeDeleted] ADD  DEFAULT (getdate()) FOR [CreatedDate]
GO
ALTER TABLE [Audit].[Questionnaire_ToBeDeleted] ADD  DEFAULT ((1)) FOR [Status]
GO
ALTER TABLE [Audit].[Questionnaire_ToBeDeleted]  WITH CHECK ADD  CONSTRAINT [FK_Questionnaire_AuditCompany] FOREIGN KEY([AuditCompanyId])
REFERENCES [Audit].[AuditCompany] ([Id])
GO
ALTER TABLE [Audit].[Questionnaire_ToBeDeleted] CHECK CONSTRAINT [FK_Questionnaire_AuditCompany]
GO
ALTER TABLE [Audit].[Questionnaire_ToBeDeleted]  WITH CHECK ADD  CONSTRAINT [FK_Questionnaire_AuditCompanyEngagement] FOREIGN KEY([AuditCompanyEngagementId])
REFERENCES [Audit].[AuditCompanyEngagement] ([Id])
GO
ALTER TABLE [Audit].[Questionnaire_ToBeDeleted] CHECK CONSTRAINT [FK_Questionnaire_AuditCompanyEngagement]
GO
