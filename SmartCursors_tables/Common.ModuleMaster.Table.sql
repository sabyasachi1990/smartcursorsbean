USE [SmartCursorSTG]
GO
/****** Object:  Table [Common].[ModuleMaster]    Script Date: 16-12-2024 9.30.56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Common].[ModuleMaster](
	[Id] [bigint] NOT NULL,
	[ParentId] [bigint] NULL,
	[Name] [nvarchar](100) NOT NULL,
	[CompanyId] [bigint] NOT NULL,
	[Description] [nvarchar](1000) NULL,
	[Heading] [nvarchar](100) NULL,
	[LogoId] [uniqueidentifier] NULL,
	[CssSprite] [nvarchar](50) NULL,
	[FontAwesome] [nvarchar](50) NULL,
	[Url] [nvarchar](1000) NULL,
	[IsMainCursor] [bit] NOT NULL,
	[RecOrder] [int] NULL,
	[Remarks] [nvarchar](256) NULL,
	[Status] [int] NULL,
	[IsModuleShow] [bit] NULL,
	[ShortCode] [nvarchar](20) NULL,
	[HelpLink] [nvarchar](256) NULL,
	[SmallIcon] [nvarchar](max) NULL,
	[ParentModuleId] [bigint] NULL,
	[IsRoleExists] [bit] NULL,
 CONSTRAINT [PK_ModuleMaster] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [Common].[ModuleMaster] ADD  DEFAULT ((1)) FOR [Status]
GO
ALTER TABLE [Common].[ModuleMaster]  WITH CHECK ADD  CONSTRAINT [FK_ModuleMaster_Company] FOREIGN KEY([CompanyId])
REFERENCES [Common].[Company] ([Id])
GO
ALTER TABLE [Common].[ModuleMaster] CHECK CONSTRAINT [FK_ModuleMaster_Company]
GO
ALTER TABLE [Common].[ModuleMaster]  WITH CHECK ADD  CONSTRAINT [FK_ModuleMaster_MediaRepository] FOREIGN KEY([LogoId])
REFERENCES [Common].[MediaRepository] ([Id])
GO
ALTER TABLE [Common].[ModuleMaster] CHECK CONSTRAINT [FK_ModuleMaster_MediaRepository]
GO
