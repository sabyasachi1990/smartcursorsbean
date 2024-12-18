USE [SmartCursorSTG]
GO
/****** Object:  Table [Tax].[EngagementPercentage]    Script Date: 16-12-2024 9.30.57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Tax].[EngagementPercentage](
	[ID] [uniqueidentifier] NOT NULL,
	[EngagementId] [uniqueidentifier] NOT NULL,
	[GroupName] [nvarchar](100) NULL,
	[PercentageType] [nvarchar](100) NULL,
	[Percentage] [int] NULL,
 CONSTRAINT [PK_EngagementPercentage] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Tax].[EngagementPercentage]  WITH CHECK ADD  CONSTRAINT [FK_TaxCompanyEngagement] FOREIGN KEY([EngagementId])
REFERENCES [Tax].[TaxCompanyEngagement] ([Id])
GO
ALTER TABLE [Tax].[EngagementPercentage] CHECK CONSTRAINT [FK_TaxCompanyEngagement]
GO
