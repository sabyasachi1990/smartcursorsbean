USE [SmartCursorSTG]
GO
/****** Object:  Table [Auth].[GridMetaData]    Script Date: 16-12-2024 9.30.55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Auth].[GridMetaData](
	[Id] [uniqueidentifier] NOT NULL,
	[ModuleDetailId] [bigint] NULL,
	[UserName] [nvarchar](254) NULL,
	[Url] [nvarchar](1000) NULL,
	[GridMetaData] [nvarchar](max) NOT NULL,
	[CompanyId] [bigint] NOT NULL,
	[APIMethod] [nvarchar](100) NULL,
	[ActionURL] [nvarchar](256) NULL,
	[TableName] [nvarchar](100) NULL,
	[Class] [nvarchar](20) NULL,
	[Title] [nvarchar](100) NULL,
	[Params] [nvarchar](1500) NULL,
	[Options] [nvarchar](max) NULL,
	[StreamName] [nvarchar](50) NULL,
	[ViewModelName] [nvarchar](100) NULL,
	[IsModified] [bit] NULL,
	[GridParams] [nvarchar](1000) NULL,
	[PopupOptions] [nvarchar](max) NULL,
	[ActionType] [nvarchar](10) NULL,
	[ModuleMasterId] [bigint] NULL,
 CONSTRAINT [PK_GridMetaData] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [Auth].[GridMetaData] ADD  DEFAULT ((0)) FOR [CompanyId]
GO
ALTER TABLE [Auth].[GridMetaData]  WITH CHECK ADD FOREIGN KEY([CompanyId])
REFERENCES [Common].[Company] ([Id])
GO
ALTER TABLE [Auth].[GridMetaData]  WITH CHECK ADD  CONSTRAINT [FK_GridMetaData_ModuleDetail] FOREIGN KEY([ModuleDetailId])
REFERENCES [Common].[ModuleDetail] ([Id])
GO
ALTER TABLE [Auth].[GridMetaData] CHECK CONSTRAINT [FK_GridMetaData_ModuleDetail]
GO
