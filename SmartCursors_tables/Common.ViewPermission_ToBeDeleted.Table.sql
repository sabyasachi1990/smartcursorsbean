USE [SmartCursorSTG]
GO
/****** Object:  Table [Common].[ViewPermission_ToBeDeleted]    Script Date: 16-12-2024 9.30.56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Common].[ViewPermission_ToBeDeleted](
	[Id] [bigint] NOT NULL,
	[PermissionId] [bigint] NOT NULL,
	[ModuleDetailId] [bigint] NOT NULL,
	[Url] [nvarchar](1000) NOT NULL,
	[UrlParams] [nvarchar](1000) NULL,
	[RecOrder] [int] NOT NULL,
	[Remarks] [nvarchar](256) NULL,
	[Status] [int] NULL,
	[ToolTip] [nvarchar](25) NULL,
 CONSTRAINT [PK_ViewPermission] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Common].[ViewPermission_ToBeDeleted] ADD  DEFAULT ((1)) FOR [Status]
GO
ALTER TABLE [Common].[ViewPermission_ToBeDeleted]  WITH CHECK ADD  CONSTRAINT [FK_ViewPermission_Action] FOREIGN KEY([PermissionId])
REFERENCES [Auth].[Permission] ([Id])
GO
ALTER TABLE [Common].[ViewPermission_ToBeDeleted] CHECK CONSTRAINT [FK_ViewPermission_Action]
GO
ALTER TABLE [Common].[ViewPermission_ToBeDeleted]  WITH CHECK ADD  CONSTRAINT [FK_ViewPermission_ModuleDetail] FOREIGN KEY([ModuleDetailId])
REFERENCES [Common].[ModuleDetail] ([Id])
GO
ALTER TABLE [Common].[ViewPermission_ToBeDeleted] CHECK CONSTRAINT [FK_ViewPermission_ModuleDetail]
GO
