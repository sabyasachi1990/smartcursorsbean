USE [SmartCursorSTG]
GO
/****** Object:  Table [dbo].[SharepointMigration]    Script Date: 16-12-2024 9.30.56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[SharepointMigration](
	[Id] [uniqueidentifier] NOT NULL,
	[ModuleName] [nvarchar](100) NULL,
	[CompanyId] [bigint] NULL,
	[ActionType] [nvarchar](50) NULL,
	[SubSite] [nvarchar](100) NULL,
	[SubSiteGroups] [nvarchar](1000) NULL,
	[FolderName] [nvarchar](100) NULL,
	[FolderGroups] [nvarchar](1000) NULL,
	[FolderPermissions] [nvarchar](1000) NULL,
	[SubfolderName] [nvarchar](100) NULL,
	[SubfolderGroups] [nvarchar](1000) NULL,
	[SubfolderPermissions] [nvarchar](1000) NULL,
	[SubfolderName1] [nvarchar](100) NULL,
	[SubfolderGroups1] [nvarchar](1000) NULL,
	[SubfolderPermissions1] [nvarchar](1000) NULL,
	[SubfolderName2] [nvarchar](100) NULL,
	[SubfolderGroups2] [nvarchar](1000) NULL,
	[SubfolderPermissions2] [nvarchar](1000) NULL,
	[Recorder] [int] NULL,
PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
