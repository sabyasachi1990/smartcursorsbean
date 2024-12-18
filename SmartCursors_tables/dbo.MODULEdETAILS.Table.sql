USE [SmartCursorSTG]
GO
/****** Object:  Table [dbo].[MODULEdETAILS]    Script Date: 16-12-2024 9.30.56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[MODULEdETAILS](
	[Id] [bigint] NULL,
	[ModuleMasterId] [bigint] NULL,
	[GroupName] [nvarchar](100) NULL,
	[Heading] [nvarchar](100) NOT NULL,
	[Description] [nvarchar](1000) NULL,
	[LogoId] [uniqueidentifier] NULL,
	[CssSprite] [nvarchar](50) NULL,
	[FontAwesome] [nvarchar](20) NULL,
	[Url] [nvarchar](1000) NULL,
	[RecOrder] [int] NULL,
	[Remarks] [nvarchar](256) NULL,
	[Status] [int] NULL,
	[PageUrl] [nvarchar](1000) NULL
) ON [PRIMARY]
GO
