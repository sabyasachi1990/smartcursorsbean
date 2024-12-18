USE [SmartCursorSTG]
GO
/****** Object:  Table [Boardroom].[ContactMapping]    Script Date: 16-12-2024 9.30.56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Boardroom].[ContactMapping](
	[Id] [uniqueidentifier] NOT NULL,
	[Sort] [nvarchar](300) NULL,
	[Category] [nvarchar](300) NULL,
	[Type] [nvarchar](300) NULL,
	[Position] [nvarchar](300) NULL,
	[ShortCode] [nvarchar](20) NULL,
	[Status] [int] NULL
) ON [PRIMARY]
GO
