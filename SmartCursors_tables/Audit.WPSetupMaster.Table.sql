USE [SmartCursorSTG]
GO
/****** Object:  Table [Audit].[WPSetupMaster]    Script Date: 16-12-2024 9.30.55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Audit].[WPSetupMaster](
	[Id] [uniqueidentifier] NOT NULL,
	[CompanyId] [bigint] NULL,
	[AuditManualId] [uniqueidentifier] NULL,
	[EngagementTypeId] [uniqueidentifier] NULL,
	[UserCreated] [nvarchar](256) NULL,
	[CreatedDate] [datetime2](7) NULL,
	[ModifiedBy] [nvarchar](256) NULL,
	[ModifiedDate] [datetime2](7) NULL,
	[Status] [int] NULL,
	[UseWorkProgramcode] [bit] NULL,
 CONSTRAINT [PK_WPSetupMaster] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Audit].[WPSetupMaster] ADD  DEFAULT ((1)) FOR [Status]
GO
ALTER TABLE [Audit].[WPSetupMaster]  WITH CHECK ADD  CONSTRAINT [FK_WPSetupMaster_AuditManual] FOREIGN KEY([AuditManualId])
REFERENCES [Audit].[AuditManual] ([Id])
GO
ALTER TABLE [Audit].[WPSetupMaster] CHECK CONSTRAINT [FK_WPSetupMaster_AuditManual]
GO
ALTER TABLE [Audit].[WPSetupMaster]  WITH CHECK ADD  CONSTRAINT [FK_WPSetupMaster_Company] FOREIGN KEY([CompanyId])
REFERENCES [Common].[Company] ([Id])
GO
ALTER TABLE [Audit].[WPSetupMaster] CHECK CONSTRAINT [FK_WPSetupMaster_Company]
GO
ALTER TABLE [Audit].[WPSetupMaster]  WITH CHECK ADD  CONSTRAINT [FK_WPSetupMaster_EngagementType] FOREIGN KEY([EngagementTypeId])
REFERENCES [Audit].[EngagementType] ([Id])
GO
ALTER TABLE [Audit].[WPSetupMaster] CHECK CONSTRAINT [FK_WPSetupMaster_EngagementType]
GO
