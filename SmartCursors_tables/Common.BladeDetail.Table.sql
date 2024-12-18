USE [SmartCursorSTG]
GO
/****** Object:  Table [Common].[BladeDetail]    Script Date: 16-12-2024 9.30.56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Common].[BladeDetail](
	[Id] [bigint] NOT NULL,
	[MasterId] [bigint] NOT NULL,
	[BladeTypeId] [uniqueidentifier] NOT NULL,
	[Title] [nvarchar](150) NULL,
	[CssSprite] [nvarchar](max) NULL,
	[XTitle] [nvarchar](150) NULL,
	[YTitle] [nvarchar](150) NULL,
	[SPName] [nvarchar](400) NULL,
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
	[IsPBI] [bit] NULL,
 CONSTRAINT [PK_BladeDetail] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [Common].[BladeDetail]  WITH CHECK ADD  CONSTRAINT [FK_BladeDetail_MasterId] FOREIGN KEY([MasterId])
REFERENCES [Common].[BladeMaster] ([Id ])
GO
ALTER TABLE [Common].[BladeDetail] CHECK CONSTRAINT [FK_BladeDetail_MasterId]
GO
