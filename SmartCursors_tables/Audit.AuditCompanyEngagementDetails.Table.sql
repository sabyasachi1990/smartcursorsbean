USE [SmartCursorSTG]
GO
/****** Object:  Table [Audit].[AuditCompanyEngagementDetails]    Script Date: 16-12-2024 9.30.55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Audit].[AuditCompanyEngagementDetails](
	[Id] [uniqueidentifier] NOT NULL,
	[AuditCompanyEngagementId] [uniqueidentifier] NOT NULL,
	[UserName] [nvarchar](254) NOT NULL,
	[Role] [nvarchar](50) NULL,
	[SignOffLevel] [nvarchar](500) NULL,
	[Status] [int] NULL,
 CONSTRAINT [PK_AuditCompanyEngagementDetails] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Audit].[AuditCompanyEngagementDetails] ADD  DEFAULT ((1)) FOR [Status]
GO
ALTER TABLE [Audit].[AuditCompanyEngagementDetails]  WITH CHECK ADD  CONSTRAINT [FK_AuditCompanyEngagementDetails_AuditCompanyEngagementEngagement] FOREIGN KEY([AuditCompanyEngagementId])
REFERENCES [Audit].[AuditCompanyEngagement] ([Id])
GO
ALTER TABLE [Audit].[AuditCompanyEngagementDetails] CHECK CONSTRAINT [FK_AuditCompanyEngagementDetails_AuditCompanyEngagementEngagement]
GO
