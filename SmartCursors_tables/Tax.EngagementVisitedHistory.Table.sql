USE [SmartCursorSTG]
GO
/****** Object:  Table [Tax].[EngagementVisitedHistory]    Script Date: 16-12-2024 9.30.57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Tax].[EngagementVisitedHistory](
	[Id] [uniqueidentifier] NOT NULL,
	[CompanyId] [bigint] NOT NULL,
	[TaxCompanyId] [uniqueidentifier] NOT NULL,
	[EngagementId] [uniqueidentifier] NOT NULL,
	[UserName] [nvarchar](254) NULL,
	[LastVisited] [datetime2](7) NULL,
 CONSTRAINT [PK_EngagementVisitedHistory] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Tax].[EngagementVisitedHistory]  WITH CHECK ADD  CONSTRAINT [FK_EngagementVisitedHistory_Company] FOREIGN KEY([CompanyId])
REFERENCES [Common].[Company] ([Id])
GO
ALTER TABLE [Tax].[EngagementVisitedHistory] CHECK CONSTRAINT [FK_EngagementVisitedHistory_Company]
GO
ALTER TABLE [Tax].[EngagementVisitedHistory]  WITH CHECK ADD  CONSTRAINT [FK_EngagementVisitedHistory_TaxCompany] FOREIGN KEY([TaxCompanyId])
REFERENCES [Tax].[TaxCompany] ([Id])
GO
ALTER TABLE [Tax].[EngagementVisitedHistory] CHECK CONSTRAINT [FK_EngagementVisitedHistory_TaxCompany]
GO
ALTER TABLE [Tax].[EngagementVisitedHistory]  WITH CHECK ADD  CONSTRAINT [FK_EngagementVisitedHistory_TaxCompanyEngagement] FOREIGN KEY([EngagementId])
REFERENCES [Tax].[TaxCompanyEngagement] ([Id])
GO
ALTER TABLE [Tax].[EngagementVisitedHistory] CHECK CONSTRAINT [FK_EngagementVisitedHistory_TaxCompanyEngagement]
GO
