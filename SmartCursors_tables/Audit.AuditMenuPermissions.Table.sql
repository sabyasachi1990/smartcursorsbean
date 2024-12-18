USE [SmartCursorSTG]
GO
/****** Object:  Table [Audit].[AuditMenuPermissions]    Script Date: 16-12-2024 9.30.55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Audit].[AuditMenuPermissions](
	[Id] [uniqueidentifier] NOT NULL,
	[AuditCompanyMenuMasterId] [uniqueidentifier] NOT NULL,
	[Role] [nvarchar](100) NULL,
	[View] [bit] NULL,
	[Add] [bit] NULL,
	[Edit] [bit] NULL,
	[Disable] [bit] NULL,
	[Lock] [bit] NULL,
	[Prepared] [bit] NULL,
	[Reviewed] [bit] NULL,
	[DeleteDocument] [bit] NULL,
	[Actions] [nvarchar](2000) NULL,
	[RoleId] [uniqueidentifier] NULL,
 CONSTRAINT [PK_AuditMenuPermissions] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Audit].[AuditMenuPermissions]  WITH CHECK ADD  CONSTRAINT [FK_AuditMenuPermissions_AuditCompanyMenuMaster] FOREIGN KEY([AuditCompanyMenuMasterId])
REFERENCES [Audit].[AuditCompanyMenuMaster] ([Id])
GO
ALTER TABLE [Audit].[AuditMenuPermissions] CHECK CONSTRAINT [FK_AuditMenuPermissions_AuditCompanyMenuMaster]
GO
