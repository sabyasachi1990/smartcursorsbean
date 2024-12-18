USE [SmartCursorSTG]
GO
/****** Object:  Table [Audit].[AuditTypeAuditMenu]    Script Date: 16-12-2024 9.30.55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Audit].[AuditTypeAuditMenu](
	[Id] [uniqueidentifier] NOT NULL,
	[AuditType] [nvarchar](50) NULL,
	[AuditMenuMasterId] [uniqueidentifier] NOT NULL,
 CONSTRAINT [PK_AuditTypeAuditMenu] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Audit].[AuditTypeAuditMenu]  WITH CHECK ADD  CONSTRAINT [FK_AuditTypeAuditMenu_AuditMenuMaster] FOREIGN KEY([AuditMenuMasterId])
REFERENCES [Audit].[AuditMenuMaster] ([Id])
GO
ALTER TABLE [Audit].[AuditTypeAuditMenu] CHECK CONSTRAINT [FK_AuditTypeAuditMenu_AuditMenuMaster]
GO
