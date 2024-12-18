USE [SmartCursorSTG]
GO
/****** Object:  Table [Tax].[ProfitAndLossAuditTrail]    Script Date: 16-12-2024 9.30.57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Tax].[ProfitAndLossAuditTrail](
	[ID] [uniqueidentifier] NOT NULL,
	[EngagementID] [uniqueidentifier] NULL,
	[User] [varchar](50) NULL,
	[Account] [varchar](50) NULL,
	[Amount] [money] NOT NULL,
	[Comment] [nvarchar](150) NULL,
	[Date] [datetime] NULL,
 CONSTRAINT [PK_ProfitAndLossAuditTrail] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Tax].[ProfitAndLossAuditTrail]  WITH CHECK ADD  CONSTRAINT [FK_ProfitAndLossAuditTrail_TaxCompanyEngagement] FOREIGN KEY([EngagementID])
REFERENCES [Tax].[TaxCompanyEngagement] ([Id])
GO
ALTER TABLE [Tax].[ProfitAndLossAuditTrail] CHECK CONSTRAINT [FK_ProfitAndLossAuditTrail_TaxCompanyEngagement]
GO
