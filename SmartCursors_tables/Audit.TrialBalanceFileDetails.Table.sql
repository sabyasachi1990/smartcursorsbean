USE [SmartCursorSTG]
GO
/****** Object:  Table [Audit].[TrialBalanceFileDetails]    Script Date: 16-12-2024 9.30.55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Audit].[TrialBalanceFileDetails](
	[Id] [uniqueidentifier] NOT NULL,
	[EngagementId] [uniqueidentifier] NULL,
	[FileName] [nvarchar](275) NULL,
	[FilePath] [nvarchar](500) NULL,
	[FileSize] [int] NULL,
	[IsReconcile] [bit] NULL,
	[AccountType] [nvarchar](8) NULL,
	[UserCreated] [nvarchar](254) NULL,
	[CreatedDate] [datetime] NULL,
	[Status] [int] NULL,
 CONSTRAINT [PK_TrialBalanceFileDetails] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Audit].[TrialBalanceFileDetails]  WITH CHECK ADD  CONSTRAINT [FK_TrialBalanceFileDetails_AuditCompanyEngagement] FOREIGN KEY([EngagementId])
REFERENCES [Audit].[AuditCompanyEngagement] ([Id])
GO
ALTER TABLE [Audit].[TrialBalanceFileDetails] CHECK CONSTRAINT [FK_TrialBalanceFileDetails_AuditCompanyEngagement]
GO
