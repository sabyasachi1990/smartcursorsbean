USE [SmartCursorSTG]
GO
/****** Object:  Table [Auth].[RolePermission]    Script Date: 16-12-2024 9.30.55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Auth].[RolePermission](
	[Id] [uniqueidentifier] NOT NULL,
	[RoleId] [uniqueidentifier] NOT NULL,
	[ModuleDetailPermissionId] [bigint] NOT NULL,
	[UserCreated] [nvarchar](254) NULL,
	[CreatedDate] [datetime2](7) NULL,
	[ModifiedBy] [nvarchar](254) NULL,
	[ModifiedDate] [datetime2](7) NULL,
	[Status] [int] NULL,
 CONSTRAINT [PK_RolePermission] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Auth].[RolePermission]  WITH CHECK ADD  CONSTRAINT [FK_RolePermission_ModulePermission] FOREIGN KEY([ModuleDetailPermissionId])
REFERENCES [Auth].[ModuleDetailPermission] ([Id])
GO
ALTER TABLE [Auth].[RolePermission] CHECK CONSTRAINT [FK_RolePermission_ModulePermission]
GO
ALTER TABLE [Auth].[RolePermission]  WITH CHECK ADD  CONSTRAINT [FK_RolePermission_Role] FOREIGN KEY([RoleId])
REFERENCES [Auth].[Role] ([Id])
GO
ALTER TABLE [Auth].[RolePermission] CHECK CONSTRAINT [FK_RolePermission_Role]
GO
