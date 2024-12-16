USE [SmartCursorSTG]
GO
/****** Object:  Table [HR].[IR8A]    Script Date: 16-12-2024 9.30.57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [HR].[IR8A](
	[Id] [uniqueidentifier] NOT NULL,
	[Name] [nvarchar](100) NULL,
	[Location] [nvarchar](100) NULL,
	[ScreenName] [nvarchar](50) NULL
) ON [PRIMARY]
GO
