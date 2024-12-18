USE [SmartCursorSTG]
GO
/****** Object:  Table [Common].[UserAccountCursors]    Script Date: 16-12-2024 9.30.56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Common].[UserAccountCursors](
	[Id] [uniqueidentifier] NOT NULL,
	[UserAccountId] [uniqueidentifier] NULL,
	[CompanyId] [bigint] NOT NULL,
	[ModuleMasterId] [bigint] NULL,
	[Name] [nvarchar](50) NULL,
	[RoleId] [uniqueidentifier] NULL,
	[Status] [int] NOT NULL,
 CONSTRAINT [PK_UserAccountCursors] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Common].[UserAccountCursors]  WITH CHECK ADD  CONSTRAINT [FK_UserAccountCursors_Company] FOREIGN KEY([CompanyId])
REFERENCES [Common].[Company] ([Id])
GO
ALTER TABLE [Common].[UserAccountCursors] CHECK CONSTRAINT [FK_UserAccountCursors_Company]
GO
ALTER TABLE [Common].[UserAccountCursors]  WITH CHECK ADD  CONSTRAINT [FK_UserAccountCursors_ModuleMaster] FOREIGN KEY([ModuleMasterId])
REFERENCES [Common].[ModuleMaster] ([Id])
GO
ALTER TABLE [Common].[UserAccountCursors] CHECK CONSTRAINT [FK_UserAccountCursors_ModuleMaster]
GO
ALTER TABLE [Common].[UserAccountCursors]  WITH CHECK ADD  CONSTRAINT [FK_UserAccountCursors_Role] FOREIGN KEY([RoleId])
REFERENCES [Auth].[Role] ([Id])
GO
ALTER TABLE [Common].[UserAccountCursors] CHECK CONSTRAINT [FK_UserAccountCursors_Role]
GO
ALTER TABLE [Common].[UserAccountCursors]  WITH CHECK ADD  CONSTRAINT [FK_UserAccountCursors_UserAccount] FOREIGN KEY([UserAccountId])
REFERENCES [Auth].[UserAccount] ([Id])
GO
ALTER TABLE [Common].[UserAccountCursors] CHECK CONSTRAINT [FK_UserAccountCursors_UserAccount]
GO
