USE [SmartCursorSTG]
GO
/****** Object:  Table [Tax].[TaxRolePermission]    Script Date: 16-12-2024 9.30.57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Tax].[TaxRolePermission](
	[Id] [uniqueidentifier] NOT NULL,
	[CompanyId] [bigint] NOT NULL,
	[TaxRoleId] [uniqueidentifier] NOT NULL,
	[TaxPermissionId] [uniqueidentifier] NOT NULL,
 CONSTRAINT [PK_TaxRolePermission] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Tax].[TaxRolePermission]  WITH CHECK ADD  CONSTRAINT [FK_TaxRolePermission_Company] FOREIGN KEY([CompanyId])
REFERENCES [Common].[Company] ([Id])
GO
ALTER TABLE [Tax].[TaxRolePermission] CHECK CONSTRAINT [FK_TaxRolePermission_Company]
GO
ALTER TABLE [Tax].[TaxRolePermission]  WITH CHECK ADD  CONSTRAINT [FK_TaxRolePermission_TaxPermission] FOREIGN KEY([TaxPermissionId])
REFERENCES [Tax].[TaxPermission] ([Id])
GO
ALTER TABLE [Tax].[TaxRolePermission] CHECK CONSTRAINT [FK_TaxRolePermission_TaxPermission]
GO
ALTER TABLE [Tax].[TaxRolePermission]  WITH CHECK ADD  CONSTRAINT [FK_TaxRolePermission_TaxRole] FOREIGN KEY([TaxRoleId])
REFERENCES [Tax].[TaxRole] ([Id])
GO
ALTER TABLE [Tax].[TaxRolePermission] CHECK CONSTRAINT [FK_TaxRolePermission_TaxRole]
GO
