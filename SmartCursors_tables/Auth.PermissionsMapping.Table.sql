USE [SmartCursorSTG]
GO
/****** Object:  Table [Auth].[PermissionsMapping]    Script Date: 16-12-2024 9.30.55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Auth].[PermissionsMapping](
	[Id] [uniqueidentifier] NOT NULL,
	[ModuleMasterId] [bigint] NOT NULL,
	[CompanyId] [bigint] NOT NULL,
	[FromModuleDetailId] [bigint] NOT NULL,
	[ToModuleDetailId] [bigint] NOT NULL,
	[FromPermissionName] [nvarchar](20) NULL,
	[ToPermissionName] [nvarchar](100) NULL,
	[Status] [int] NULL,
 CONSTRAINT [PK_PermissionsMapping] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Auth].[PermissionsMapping]  WITH CHECK ADD  CONSTRAINT [FK_PermissionsMapping_Company] FOREIGN KEY([CompanyId])
REFERENCES [Common].[Company] ([Id])
GO
ALTER TABLE [Auth].[PermissionsMapping] CHECK CONSTRAINT [FK_PermissionsMapping_Company]
GO
ALTER TABLE [Auth].[PermissionsMapping]  WITH CHECK ADD  CONSTRAINT [FK_PermissionsMapping_ModuleDetail] FOREIGN KEY([ToModuleDetailId])
REFERENCES [Common].[ModuleDetail] ([Id])
GO
ALTER TABLE [Auth].[PermissionsMapping] CHECK CONSTRAINT [FK_PermissionsMapping_ModuleDetail]
GO
ALTER TABLE [Auth].[PermissionsMapping]  WITH CHECK ADD  CONSTRAINT [FK_PermissionsMapping_ModuleMaster] FOREIGN KEY([ModuleMasterId])
REFERENCES [Common].[ModuleMaster] ([Id])
GO
ALTER TABLE [Auth].[PermissionsMapping] CHECK CONSTRAINT [FK_PermissionsMapping_ModuleMaster]
GO
