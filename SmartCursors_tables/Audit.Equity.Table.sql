USE [SmartCursorSTG]
GO
/****** Object:  Table [Audit].[Equity]    Script Date: 16-12-2024 9.30.55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Audit].[Equity](
	[Id] [uniqueidentifier] NOT NULL,
	[EngagementId] [uniqueidentifier] NULL,
	[LeadSheetId] [uniqueidentifier] NULL,
	[SOEPYAccountDescription] [nvarchar](256) NULL,
	[SOECYAccountDescription] [nvarchar](256) NULL,
	[CategoryName] [nvarchar](256) NULL,
	[IsStartEndDate] [bit] NULL,
 CONSTRAINT [PK_Equity] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Audit].[Equity]  WITH CHECK ADD  CONSTRAINT [FK_Equity_AuditCompanyEngagement] FOREIGN KEY([EngagementId])
REFERENCES [Audit].[AuditCompanyEngagement] ([Id])
GO
ALTER TABLE [Audit].[Equity] CHECK CONSTRAINT [FK_Equity_AuditCompanyEngagement]
GO
ALTER TABLE [Audit].[Equity]  WITH CHECK ADD  CONSTRAINT [FK_Equity_LeadSheet] FOREIGN KEY([LeadSheetId])
REFERENCES [Audit].[LeadSheet] ([Id])
GO
ALTER TABLE [Audit].[Equity] CHECK CONSTRAINT [FK_Equity_LeadSheet]
GO
