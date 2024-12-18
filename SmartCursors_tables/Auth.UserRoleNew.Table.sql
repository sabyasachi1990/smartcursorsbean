USE [SmartCursorSTG]
GO
/****** Object:  Table [Auth].[UserRoleNew]    Script Date: 16-12-2024 9.30.55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Auth].[UserRoleNew](
	[Id] [uniqueidentifier] NOT NULL,
	[CompanyUserId] [bigint] NOT NULL,
	[RoleId] [uniqueidentifier] NOT NULL,
	[RoleName] [nvarchar](100) NOT NULL,
	[Username] [nvarchar](254) NOT NULL,
	[UserCreated] [nvarchar](254) NULL,
	[CreatedDate] [datetime2](7) NULL,
	[ModifiedBy] [nvarchar](254) NULL,
	[ModifiedDate] [datetime2](7) NULL,
	[Status] [int] NULL,
 CONSTRAINT [PK_UserRoleNew] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Auth].[UserRoleNew]  WITH NOCHECK ADD  CONSTRAINT [FK_UserRoleNew_CompanyUserId] FOREIGN KEY([CompanyUserId])
REFERENCES [Common].[CompanyUser] ([Id])
GO
ALTER TABLE [Auth].[UserRoleNew] NOCHECK CONSTRAINT [FK_UserRoleNew_CompanyUserId]
GO
ALTER TABLE [Auth].[UserRoleNew]  WITH NOCHECK ADD  CONSTRAINT [FK_UserRoleNew_Role] FOREIGN KEY([RoleId])
REFERENCES [Auth].[RoleNew] ([Id])
GO
ALTER TABLE [Auth].[UserRoleNew] NOCHECK CONSTRAINT [FK_UserRoleNew_Role]
GO
