USE [SmartCursorSTG]
GO
/****** Object:  Table [dbo].[BDetail]    Script Date: 16-12-2024 9.30.56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[BDetail](
	[Id] [bigint] NOT NULL,
	[MasterId] [bigint] NOT NULL,
	[BladeTypeId] [uniqueidentifier] NOT NULL,
	[Title] [nvarchar](150) NULL,
	[CssSprite] [nvarchar](max) NULL,
	[XTitle] [nvarchar](150) NULL,
	[YTitle] [nvarchar](150) NULL,
	[SPName] [nvarchar](100) NULL,
	[DataSetName] [nvarchar](100) NULL,
	[Parameters] [nvarchar](200) NULL,
	[ToolTip] [bit] NULL,
	[ReportName] [varchar](max) NULL,
	[IsReport] [bit] NULL,
	[ReportPath] [varchar](max) NULL,
	[Report] [varchar](max) NULL,
	[DashBoardName] [varchar](max) NULL,
	[DashBoardURL] [varchar](max) NULL,
	[IsExtension] [bit] NULL,
	[Heading] [varchar](max) NULL,
	[BladeSet] [varchar](max) NULL,
	[IsFilter] [bit] NULL,
	[IsPBI] [bit] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
