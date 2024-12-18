USE [SmartCursorSTG]
GO
/****** Object:  Table [Audit].[FormMaster]    Script Date: 16-12-2024 9.30.55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Audit].[FormMaster](
	[Id] [uniqueidentifier] NOT NULL,
	[EngagementId] [uniqueidentifier] NULL,
	[CompanyId] [bigint] NOT NULL,
	[TemplateName] [nvarchar](100) NULL,
	[UserCreated] [nvarchar](256) NULL,
	[CreatedDate] [datetime2](7) NULL,
	[ModifiedBy] [nvarchar](256) NULL,
	[ModifiedDate] [datetime2](7) NULL,
	[Remarks] [nvarchar](256) NULL,
	[RecOrder] [int] NULL,
	[Version] [smallint] NULL,
	[Status] [int] NULL,
 CONSTRAINT [PK_FormMaster] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Audit].[FormMaster] ADD  DEFAULT ((1)) FOR [Status]
GO
ALTER TABLE [Audit].[FormMaster]  WITH CHECK ADD  CONSTRAINT [FK_FormMaster_AuditCompanyEngagement] FOREIGN KEY([EngagementId])
REFERENCES [Audit].[AuditCompanyEngagement] ([Id])
GO
ALTER TABLE [Audit].[FormMaster] CHECK CONSTRAINT [FK_FormMaster_AuditCompanyEngagement]
GO
ALTER TABLE [Audit].[FormMaster]  WITH CHECK ADD  CONSTRAINT [FK_FormMaster_Company] FOREIGN KEY([CompanyId])
REFERENCES [Common].[Company] ([Id])
GO
ALTER TABLE [Audit].[FormMaster] CHECK CONSTRAINT [FK_FormMaster_Company]
GO
