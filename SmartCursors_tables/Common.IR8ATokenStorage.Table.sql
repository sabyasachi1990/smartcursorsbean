USE [SmartCursorSTG]
GO
/****** Object:  Table [Common].[IR8ATokenStorage]    Script Date: 16-12-2024 9.30.56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Common].[IR8ATokenStorage](
	[Id] [uniqueidentifier] NOT NULL,
	[CompanyId] [bigint] NOT NULL,
	[State] [nvarchar](2000) NULL,
	[Code] [nvarchar](2000) NULL,
	[Token] [nvarchar](max) NULL,
	[CreatedDate] [datetime2](7) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
