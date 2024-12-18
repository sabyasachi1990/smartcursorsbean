USE [SmartCursorSTG]
GO
/****** Object:  Table [Audit].[TrialBalanceAuditTrail]    Script Date: 16-12-2024 9.30.55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Audit].[TrialBalanceAuditTrail](
	[ID] [uniqueidentifier] NOT NULL,
	[EngagementID] [uniqueidentifier] NULL,
	[User] [varchar](50) NULL,
	[Account] [varchar](100) NULL,
	[Amount] [money] NOT NULL,
	[Comment] [nvarchar](1000) NULL,
	[Date] [datetime] NULL,
 CONSTRAINT [PK_AuditTrail] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Audit].[TrialBalanceAuditTrail]  WITH CHECK ADD  CONSTRAINT [FK_TrialBalanceAuditTrail_AuditCompanyEngagement] FOREIGN KEY([EngagementID])
REFERENCES [Audit].[AuditCompanyEngagement] ([Id])
GO
ALTER TABLE [Audit].[TrialBalanceAuditTrail] CHECK CONSTRAINT [FK_TrialBalanceAuditTrail_AuditCompanyEngagement]
GO
