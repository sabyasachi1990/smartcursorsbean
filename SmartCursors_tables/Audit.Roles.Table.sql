USE [SmartCursorSTG]
GO
/****** Object:  Table [Audit].[Roles]    Script Date: 16-12-2024 9.30.55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Audit].[Roles](
	[Id] [uniqueidentifier] NOT NULL,
	[CompanyId] [bigint] NOT NULL,
	[Role] [nvarchar](400) NULL,
	[UserCreated] [varchar](254) NULL,
	[CreatedDate] [datetime2](7) NULL,
	[ModifiedBy] [nvarchar](254) NULL,
	[ModifiedDate] [datetime2](7) NULL,
	[Status] [int] NULL,
	[IsSystem] [bit] NULL,
	[IsStautory] [bit] NULL,
	[IsCompilation] [bit] NULL,
	[EngagementId] [uniqueidentifier] NULL,
	[TypeId] [uniqueidentifier] NULL,
	[EngagementTypeId] [uniqueidentifier] NULL,
	[AuditManualId] [uniqueidentifier] NULL
) ON [PRIMARY]
GO
ALTER TABLE [Audit].[Roles] ADD  DEFAULT ((1)) FOR [Status]
GO
ALTER TABLE [Audit].[Roles]  WITH CHECK ADD  CONSTRAINT [FK_Roles_AuditCompanyEngagement] FOREIGN KEY([EngagementId])
REFERENCES [Audit].[AuditCompanyEngagement] ([Id])
GO
ALTER TABLE [Audit].[Roles] CHECK CONSTRAINT [FK_Roles_AuditCompanyEngagement]
GO
