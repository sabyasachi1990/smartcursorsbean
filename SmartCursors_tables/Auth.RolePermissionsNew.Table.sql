USE [SmartCursorSTG]
GO
/****** Object:  Table [Auth].[RolePermissionsNew]    Script Date: 16-12-2024 9.30.55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Auth].[RolePermissionsNew](
	[Id] [uniqueidentifier] NOT NULL,
	[RoleId] [uniqueidentifier] NOT NULL,
	[ModuleDetailId] [bigint] NOT NULL,
	[Permissions] [nvarchar](max) NOT NULL,
	[Status] [int] NULL,
	[IsSeedData] [bit] NULL,
 CONSTRAINT [PK_RolePermissionsNew] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [Auth].[RolePermissionsNew]  WITH CHECK ADD  CONSTRAINT [FK_RolePermissionsNew_ModuleDetail] FOREIGN KEY([ModuleDetailId])
REFERENCES [Common].[ModuleDetail] ([Id])
GO
ALTER TABLE [Auth].[RolePermissionsNew] CHECK CONSTRAINT [FK_RolePermissionsNew_ModuleDetail]
GO
ALTER TABLE [Auth].[RolePermissionsNew]  WITH CHECK ADD  CONSTRAINT [FK_RolePermissionsNew_Role] FOREIGN KEY([RoleId])
REFERENCES [Auth].[RoleNew] ([Id])
GO
ALTER TABLE [Auth].[RolePermissionsNew] CHECK CONSTRAINT [FK_RolePermissionsNew_Role]
GO
