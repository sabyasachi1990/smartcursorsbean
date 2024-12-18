USE [SmartCursorSTG]
GO
/****** Object:  Table [Audit].[AuditRolePermission_ToBeDeleted]    Script Date: 16-12-2024 9.30.55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Audit].[AuditRolePermission_ToBeDeleted](
	[Id] [uniqueidentifier] NOT NULL,
	[CompanyId] [bigint] NOT NULL,
	[AuditRoleId] [uniqueidentifier] NOT NULL,
	[AuditPermissionId] [uniqueidentifier] NOT NULL,
 CONSTRAINT [PK_AuditRolePermission] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Audit].[AuditRolePermission_ToBeDeleted]  WITH CHECK ADD  CONSTRAINT [FK_AuditRolePermission_AuditPermission] FOREIGN KEY([AuditPermissionId])
REFERENCES [Audit].[AuditPermission_ToBeDeleted] ([Id])
GO
ALTER TABLE [Audit].[AuditRolePermission_ToBeDeleted] CHECK CONSTRAINT [FK_AuditRolePermission_AuditPermission]
GO
ALTER TABLE [Audit].[AuditRolePermission_ToBeDeleted]  WITH CHECK ADD  CONSTRAINT [FK_AuditRolePermission_AuditRole] FOREIGN KEY([AuditRoleId])
REFERENCES [Audit].[AuditRole_ToBeDeleted] ([Id])
GO
ALTER TABLE [Audit].[AuditRolePermission_ToBeDeleted] CHECK CONSTRAINT [FK_AuditRolePermission_AuditRole]
GO
ALTER TABLE [Audit].[AuditRolePermission_ToBeDeleted]  WITH CHECK ADD  CONSTRAINT [FK_AuditRolePermission_Company] FOREIGN KEY([CompanyId])
REFERENCES [Common].[Company] ([Id])
GO
ALTER TABLE [Audit].[AuditRolePermission_ToBeDeleted] CHECK CONSTRAINT [FK_AuditRolePermission_Company]
GO
