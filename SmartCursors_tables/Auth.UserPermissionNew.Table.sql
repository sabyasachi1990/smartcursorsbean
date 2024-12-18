USE [SmartCursorSTG]
GO
/****** Object:  Table [Auth].[UserPermissionNew]    Script Date: 16-12-2024 9.30.55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Auth].[UserPermissionNew](
	[Id] [uniqueidentifier] NOT NULL,
	[UserRoleId] [uniqueidentifier] NULL,
	[CompanyUserId] [bigint] NOT NULL,
	[ModuleDetailId] [bigint] NOT NULL,
	[Permissions] [nvarchar](max) NOT NULL,
	[UserCreated] [nvarchar](254) NULL,
	[CreatedDate] [datetime2](7) NULL,
	[ModifiedBy] [nvarchar](254) NULL,
	[ModifiedDate] [datetime2](7) NULL,
	[Status] [int] NULL,
	[IsView] [bit] NULL,
 CONSTRAINT [PK_UserPermissionNew] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [Auth].[UserPermissionNew]  WITH CHECK ADD  CONSTRAINT [FK_UserPermissionNew_CompanyUser] FOREIGN KEY([CompanyUserId])
REFERENCES [Common].[CompanyUser] ([Id])
GO
ALTER TABLE [Auth].[UserPermissionNew] CHECK CONSTRAINT [FK_UserPermissionNew_CompanyUser]
GO
ALTER TABLE [Auth].[UserPermissionNew]  WITH CHECK ADD  CONSTRAINT [FK_UserPermissionNew_ModuleDetail] FOREIGN KEY([ModuleDetailId])
REFERENCES [Common].[ModuleDetail] ([Id])
GO
ALTER TABLE [Auth].[UserPermissionNew] CHECK CONSTRAINT [FK_UserPermissionNew_ModuleDetail]
GO
ALTER TABLE [Auth].[UserPermissionNew]  WITH NOCHECK ADD  CONSTRAINT [FK_UserPermissionNew_UserRoleNew] FOREIGN KEY([UserRoleId])
REFERENCES [Auth].[UserRoleNew] ([Id])
GO
ALTER TABLE [Auth].[UserPermissionNew] NOCHECK CONSTRAINT [FK_UserPermissionNew_UserRoleNew]
GO
