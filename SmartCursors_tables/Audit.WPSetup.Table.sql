USE [SmartCursorSTG]
GO
/****** Object:  Table [Audit].[WPSetup]    Script Date: 16-12-2024 9.30.55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Audit].[WPSetup](
	[Id] [uniqueidentifier] NOT NULL,
	[CompanyId] [bigint] NULL,
	[Code] [nvarchar](1024) NULL,
	[Description] [nvarchar](256) NULL,
	[Remarks] [nvarchar](256) NULL,
	[RecOrder] [int] NULL,
	[UserCreated] [nvarchar](256) NULL,
	[CreatedDate] [datetime2](7) NULL,
	[ModifiedBy] [nvarchar](256) NULL,
	[ModifiedDate] [datetime2](7) NULL,
	[Version] [smallint] NULL,
	[Status] [int] NULL,
	[ShortCode] [nvarchar](10) NULL,
	[IsPartner] [bit] NULL,
	[ReferenceId] [uniqueidentifier] NULL,
	[EngagementId] [uniqueidentifier] NULL,
	[EngagementTypeId] [uniqueidentifier] NULL,
	[AuditManualId] [uniqueidentifier] NULL,
	[WpsetupMasterId] [uniqueidentifier] NULL,
 CONSTRAINT [PK_WPSetup] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Audit].[WPSetup] ADD  DEFAULT ((1)) FOR [Status]
GO
ALTER TABLE [Audit].[WPSetup]  WITH CHECK ADD  CONSTRAINT [FK_Wpsetup_AuditCompanyEngagement] FOREIGN KEY([EngagementId])
REFERENCES [Audit].[AuditCompanyEngagement] ([Id])
GO
ALTER TABLE [Audit].[WPSetup] CHECK CONSTRAINT [FK_Wpsetup_AuditCompanyEngagement]
GO
ALTER TABLE [Audit].[WPSetup]  WITH CHECK ADD  CONSTRAINT [FK_WPSetup_Company] FOREIGN KEY([CompanyId])
REFERENCES [Common].[Company] ([Id])
GO
ALTER TABLE [Audit].[WPSetup] CHECK CONSTRAINT [FK_WPSetup_Company]
GO
ALTER TABLE [Audit].[WPSetup]  WITH CHECK ADD  CONSTRAINT [FK_WpSetup_WpsetupMaster] FOREIGN KEY([WpsetupMasterId])
REFERENCES [Audit].[WPSetupMaster] ([Id])
GO
ALTER TABLE [Audit].[WPSetup] CHECK CONSTRAINT [FK_WpSetup_WpsetupMaster]
GO
