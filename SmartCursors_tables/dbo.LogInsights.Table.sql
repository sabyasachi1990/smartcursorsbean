USE [SmartCursorSTG]
GO
/****** Object:  Table [dbo].[LogInsights]    Script Date: 16-12-2024 9.30.56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[LogInsights](
	[Date] [datetime2](7) NULL,
	[Cursor] [nvarchar](100) NULL,
	[Feature] [nvarchar](1000) NULL,
	[FeaturePath] [nvarchar](1000) NULL,
	[UserName] [nvarchar](1000) NULL,
	[Action] [nvarchar](1000) NULL,
	[Remarks] [nvarchar](1000) NULL,
	[TenentId] [nvarchar](1000) NULL
) ON [PRIMARY]
GO
