USE [SmartCursorSTG]
GO
/****** Object:  Table [Auth].[ModuleDetailPermission]    Script Date: 16-12-2024 9.30.55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Auth].[ModuleDetailPermission](
	[Id] [bigint] NOT NULL,
	[ModuleDetailId] [bigint] NOT NULL,
	[Heading] [nvarchar](100) NOT NULL,
	[Url] [nvarchar](1000) NULL,
	[PermissionId] [bigint] NOT NULL,
	[PermissionName] [nvarchar](100) NULL,
	[FontAwesomeClass] [nvarchar](50) NOT NULL,
	[IsApplicable] [bit] NOT NULL,
	[IsMainActions] [bit] NOT NULL,
	[RecOrder] [int] NULL,
 CONSTRAINT [PK_ModuleDetailPermission] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Auth].[ModuleDetailPermission] ADD  DEFAULT ((1)) FOR [IsApplicable]
GO
ALTER TABLE [Auth].[ModuleDetailPermission]  WITH CHECK ADD  CONSTRAINT [FK_ModuleDetailPermission_ModuleDetail] FOREIGN KEY([ModuleDetailId])
REFERENCES [Common].[ModuleDetail] ([Id])
GO
ALTER TABLE [Auth].[ModuleDetailPermission] CHECK CONSTRAINT [FK_ModuleDetailPermission_ModuleDetail]
GO
ALTER TABLE [Auth].[ModuleDetailPermission]  WITH CHECK ADD  CONSTRAINT [FK_ModuleDetailPermission_Permission] FOREIGN KEY([PermissionId])
REFERENCES [Auth].[Permission] ([Id])
GO
ALTER TABLE [Auth].[ModuleDetailPermission] CHECK CONSTRAINT [FK_ModuleDetailPermission_Permission]
GO
