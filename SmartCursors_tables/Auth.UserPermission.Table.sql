USE [SmartCursorSTG]
GO
/****** Object:  Table [Auth].[UserPermission]    Script Date: 16-12-2024 9.30.55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Auth].[UserPermission](
	[Id] [uniqueidentifier] NOT NULL,
	[CompanyUserId] [bigint] NOT NULL,
	[Username] [nvarchar](254) NOT NULL,
	[ModuleDetailPermissionId] [bigint] NOT NULL,
	[RoleId] [uniqueidentifier] NOT NULL,
	[UserCreated] [nvarchar](254) NULL,
	[CreatedDate] [datetime2](7) NULL,
	[ModifiedBy] [nvarchar](254) NULL,
	[ModifiedDate] [datetime2](7) NULL,
	[Status] [int] NULL,
 CONSTRAINT [PK_UserPermission] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Auth].[UserPermission] ADD  DEFAULT (getdate()) FOR [CreatedDate]
GO
ALTER TABLE [Auth].[UserPermission]  WITH CHECK ADD  CONSTRAINT [FK_UserPermission_CompanyUser] FOREIGN KEY([CompanyUserId])
REFERENCES [Common].[CompanyUser] ([Id])
GO
ALTER TABLE [Auth].[UserPermission] CHECK CONSTRAINT [FK_UserPermission_CompanyUser]
GO
ALTER TABLE [Auth].[UserPermission]  WITH CHECK ADD  CONSTRAINT [FK_UserPermission_ModulePermission] FOREIGN KEY([ModuleDetailPermissionId])
REFERENCES [Auth].[ModuleDetailPermission] ([Id])
GO
ALTER TABLE [Auth].[UserPermission] CHECK CONSTRAINT [FK_UserPermission_ModulePermission]
GO
ALTER TABLE [Auth].[UserPermission]  WITH CHECK ADD  CONSTRAINT [FK_UserPermission_Role] FOREIGN KEY([RoleId])
REFERENCES [Auth].[Role] ([Id])
GO
ALTER TABLE [Auth].[UserPermission] CHECK CONSTRAINT [FK_UserPermission_Role]
GO
