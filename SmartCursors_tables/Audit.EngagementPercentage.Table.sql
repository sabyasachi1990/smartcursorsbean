USE [SmartCursorSTG]
GO
/****** Object:  Table [Audit].[EngagementPercentage]    Script Date: 16-12-2024 9.30.55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Audit].[EngagementPercentage](
	[Id] [uniqueidentifier] NOT NULL,
	[EngagementId] [uniqueidentifier] NOT NULL,
	[GroupName] [nvarchar](150) NULL,
	[PercentageType] [nvarchar](50) NULL,
	[Percentage] [int] NULL,
 CONSTRAINT [PK_EngagementPercentage] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Audit].[EngagementPercentage]  WITH CHECK ADD  CONSTRAINT [FK_EngagementPercentage_AuditCompanyEngagement] FOREIGN KEY([EngagementId])
REFERENCES [Audit].[AuditCompanyEngagement] ([Id])
GO
ALTER TABLE [Audit].[EngagementPercentage] CHECK CONSTRAINT [FK_EngagementPercentage_AuditCompanyEngagement]
GO
