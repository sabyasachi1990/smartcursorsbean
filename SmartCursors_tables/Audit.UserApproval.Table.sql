USE [SmartCursorSTG]
GO
/****** Object:  Table [Audit].[UserApproval]    Script Date: 16-12-2024 9.30.55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Audit].[UserApproval](
	[ID] [uniqueidentifier] NOT NULL,
	[Type] [nvarchar](15) NULL,
	[Screen] [nvarchar](256) NULL,
	[EngagementId] [uniqueidentifier] NULL,
	[UserCode] [nvarchar](10) NULL,
	[DateCode] [nvarchar](10) NULL,
	[Remarks] [nvarchar](256) NULL,
	[RecOrder] [int] NULL,
	[UserCreated] [nvarchar](254) NULL,
	[CreatedDate] [datetime2](7) NULL,
	[ModifiedBy] [nvarchar](254) NULL,
	[ModifiedDate] [datetime2](7) NULL,
	[Version] [smallint] NULL,
	[Status] [int] NULL,
 CONSTRAINT [PK_UserApprovals] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Audit].[UserApproval] ADD  DEFAULT ((1)) FOR [Status]
GO
ALTER TABLE [Audit].[UserApproval]  WITH CHECK ADD  CONSTRAINT [FK_UserApproval_AuditCompanyEngagement] FOREIGN KEY([EngagementId])
REFERENCES [Audit].[AuditCompanyEngagement] ([Id])
GO
ALTER TABLE [Audit].[UserApproval] CHECK CONSTRAINT [FK_UserApproval_AuditCompanyEngagement]
GO
