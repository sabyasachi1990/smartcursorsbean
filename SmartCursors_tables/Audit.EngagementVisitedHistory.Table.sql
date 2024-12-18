USE [SmartCursorSTG]
GO
/****** Object:  Table [Audit].[EngagementVisitedHistory]    Script Date: 16-12-2024 9.30.55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Audit].[EngagementVisitedHistory](
	[Id] [uniqueidentifier] NOT NULL,
	[CompanyId] [bigint] NOT NULL,
	[AuditCompanyId] [uniqueidentifier] NOT NULL,
	[EngagementId] [uniqueidentifier] NOT NULL,
	[UserName] [nvarchar](254) NULL,
	[LastVisited] [datetime2](7) NULL,
 CONSTRAINT [PK_EngagementVisitedHistory] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Audit].[EngagementVisitedHistory]  WITH CHECK ADD  CONSTRAINT [FK_EngagementVisitedHistory_AuditCompany] FOREIGN KEY([AuditCompanyId])
REFERENCES [Audit].[AuditCompany] ([Id])
GO
ALTER TABLE [Audit].[EngagementVisitedHistory] CHECK CONSTRAINT [FK_EngagementVisitedHistory_AuditCompany]
GO
ALTER TABLE [Audit].[EngagementVisitedHistory]  WITH CHECK ADD  CONSTRAINT [FK_EngagementVisitedHistory_AuditCompanyEngagement] FOREIGN KEY([EngagementId])
REFERENCES [Audit].[AuditCompanyEngagement] ([Id])
GO
ALTER TABLE [Audit].[EngagementVisitedHistory] CHECK CONSTRAINT [FK_EngagementVisitedHistory_AuditCompanyEngagement]
GO
ALTER TABLE [Audit].[EngagementVisitedHistory]  WITH CHECK ADD  CONSTRAINT [FK_EngagementVisitedHistory_Company] FOREIGN KEY([CompanyId])
REFERENCES [Common].[Company] ([Id])
GO
ALTER TABLE [Audit].[EngagementVisitedHistory] CHECK CONSTRAINT [FK_EngagementVisitedHistory_Company]
GO
