USE [SmartCursorSTG]
GO
/****** Object:  Table [dbo].[Migrationfails]    Script Date: 16-12-2024 9.30.56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Migrationfails](
	[Type] [nvarchar](100) NULL,
	[Query] [nvarchar](max) NULL,
	[Message] [nvarchar](100) NULL,
	[Number] [nvarchar](100) NULL,
	[companyid] [bigint] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
