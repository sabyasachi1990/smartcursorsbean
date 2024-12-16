USE [SmartCursorSTG]
GO
/****** Object:  Table [dbo].[Migrationfail]    Script Date: 16-12-2024 9.30.56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Migrationfail](
	[Type] [nvarchar](100) NULL,
	[Query] [nvarchar](max) NULL,
	[Message] [nvarchar](100) NULL,
	[number] [nvarchar](100) NULL,
	[id] [uniqueidentifier] NULL,
	[companyid] [bigint] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
