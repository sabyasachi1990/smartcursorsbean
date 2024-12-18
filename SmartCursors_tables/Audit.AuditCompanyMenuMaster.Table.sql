USE [SmartCursorSTG]
GO
/****** Object:  Table [Audit].[AuditCompanyMenuMaster]    Script Date: 16-12-2024 9.30.55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Audit].[AuditCompanyMenuMaster](
	[Id] [uniqueidentifier] NOT NULL,
	[CompanyId] [bigint] NOT NULL,
	[EngagementId] [uniqueidentifier] NULL,
	[AuditMenuMasterId] [uniqueidentifier] NOT NULL,
	[Code] [nvarchar](100) NULL,
	[Heading] [nvarchar](100) NULL,
	[IsHide] [bit] NULL,
	[TemplateName] [nvarchar](100) NULL,
	[RecOrder] [int] NULL,
	[Remarks] [nvarchar](256) NULL,
	[UserCreated] [nvarchar](254) NULL,
	[CreatedDate] [datetime2](7) NULL,
	[ModifiedBy] [nvarchar](254) NULL,
	[ModifiedDate] [datetime2](7) NULL,
	[Version] [smallint] NULL,
	[Status] [int] NOT NULL,
	[AdditionalReview1] [nvarchar](20) NULL,
	[AdditionalReview2] [nvarchar](20) NULL,
	[IsCompilation] [bit] NOT NULL,
	[EngagementType] [nvarchar](50) NULL,
	[HelpLinkReferenceId] [uniqueidentifier] NULL,
	[IsFolderCreated] [bit] NULL,
	[TypeId] [uniqueidentifier] NULL,
	[EngagementTypeId] [uniqueidentifier] NULL,
	[AuditManualId] [uniqueidentifier] NULL,
	[MenuSetUpMasterId] [uniqueidentifier] NULL,
	[IsFsReport] [bit] NULL,
 CONSTRAINT [PK_AuditCompanyMenuMaster] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Audit].[AuditCompanyMenuMaster] ADD  DEFAULT ((0)) FOR [IsCompilation]
GO
ALTER TABLE [Audit].[AuditCompanyMenuMaster]  WITH CHECK ADD  CONSTRAINT [FK_AuditCompanyMenuMaster_AuditCompanyEngagement] FOREIGN KEY([EngagementId])
REFERENCES [Audit].[AuditCompanyEngagement] ([Id])
GO
ALTER TABLE [Audit].[AuditCompanyMenuMaster] CHECK CONSTRAINT [FK_AuditCompanyMenuMaster_AuditCompanyEngagement]
GO
ALTER TABLE [Audit].[AuditCompanyMenuMaster]  WITH CHECK ADD  CONSTRAINT [FK_AuditCompanyMenuMaster_AuditMenuMaster] FOREIGN KEY([AuditMenuMasterId])
REFERENCES [Audit].[AuditMenuMaster] ([Id])
GO
ALTER TABLE [Audit].[AuditCompanyMenuMaster] CHECK CONSTRAINT [FK_AuditCompanyMenuMaster_AuditMenuMaster]
GO
