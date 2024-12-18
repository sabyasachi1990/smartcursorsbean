USE [SmartCursorSTG]
GO
/****** Object:  Table [Common].[ModuleDetail]    Script Date: 16-12-2024 9.30.56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Common].[ModuleDetail](
	[Id] [bigint] NOT NULL,
	[ModuleMasterId] [bigint] NOT NULL,
	[GroupName] [nvarchar](100) NULL,
	[Heading] [nvarchar](100) NOT NULL,
	[Description] [nvarchar](1000) NULL,
	[LogoId] [uniqueidentifier] NULL,
	[CssSprite] [nvarchar](50) NULL,
	[FontAwesome] [nvarchar](50) NULL,
	[Url] [nvarchar](1000) NULL,
	[RecOrder] [int] NULL,
	[Remarks] [nvarchar](256) NULL,
	[Status] [int] NULL,
	[PageUrl] [nvarchar](1000) NOT NULL,
	[GroupUrl] [nvarchar](100) NULL,
	[CompanyId] [bigint] NOT NULL,
	[MasterUrl] [nvarchar](50) NULL,
	[ParentId] [bigint] NULL,
	[PermissionKey] [nvarchar](50) NULL,
	[ModuleName] [nvarchar](100) NULL,
	[IsPermissionInherited] [bit] NOT NULL,
	[IsHideTab] [bit] NOT NULL,
	[SecondryModuleId] [bigint] NULL,
	[GroupKey] [nvarchar](100) NULL,
	[IsDisable] [bit] NOT NULL,
	[IsPartner] [bit] NOT NULL,
	[IsMandatory] [int] NULL,
	[HelpLink] [nvarchar](256) NULL,
	[SetupOrder] [int] NULL,
	[Cachekeys] [nvarchar](max) NULL,
	[CursorName] [nvarchar](500) NULL,
	[IsAnalytics] [bit] NULL,
	[IsBot] [bit] NULL,
	[DashboardURL] [nvarchar](max) NULL,
	[SubGroupName] [nvarchar](100) NULL,
	[TabLevel] [int] NULL,
	[ModuleDetailId] [nvarchar](100) NULL,
	[IsHide] [bit] NULL,
	[MongoGroupName] [nvarchar](200) NULL,
	[IsTabHide] [bit] NULL,
	[IsMenuHide] [bit] NULL,
	[IsHome] [bit] NULL,
	[IsGridLevelBlade] [bit] NULL,
	[IsFormLevelBlade] [bit] NULL,
	[IsSideMenuHide] [bit] NULL,
 CONSTRAINT [PK_ModuleDetail] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [Common].[ModuleDetail] ADD  DEFAULT ((1)) FOR [Status]
GO
ALTER TABLE [Common].[ModuleDetail] ADD  DEFAULT ('#/app/dashboard') FOR [PageUrl]
GO
ALTER TABLE [Common].[ModuleDetail] ADD  DEFAULT ((0)) FOR [IsPermissionInherited]
GO
ALTER TABLE [Common].[ModuleDetail] ADD  DEFAULT ((0)) FOR [IsHideTab]
GO
ALTER TABLE [Common].[ModuleDetail] ADD  DEFAULT ((0)) FOR [IsDisable]
GO
ALTER TABLE [Common].[ModuleDetail] ADD  DEFAULT ((0)) FOR [IsPartner]
GO
ALTER TABLE [Common].[ModuleDetail]  WITH CHECK ADD  CONSTRAINT [FK_ModuleDetail_MediaRepository] FOREIGN KEY([LogoId])
REFERENCES [Common].[MediaRepository] ([Id])
GO
ALTER TABLE [Common].[ModuleDetail] CHECK CONSTRAINT [FK_ModuleDetail_MediaRepository]
GO
ALTER TABLE [Common].[ModuleDetail]  WITH CHECK ADD  CONSTRAINT [FK_ModuleDetail_ModuleMaster] FOREIGN KEY([ModuleMasterId])
REFERENCES [Common].[ModuleMaster] ([Id])
GO
ALTER TABLE [Common].[ModuleDetail] CHECK CONSTRAINT [FK_ModuleDetail_ModuleMaster]
GO
