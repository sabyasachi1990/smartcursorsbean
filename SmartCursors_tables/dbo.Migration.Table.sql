USE [SmartCursorSTG]
GO
/****** Object:  Table [dbo].[Migration]    Script Date: 16-12-2024 9.30.56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Migration](
	[Type] [nvarchar](100) NULL,
	[Query] [nvarchar](max) NULL,
	[Message] [nvarchar](100) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
