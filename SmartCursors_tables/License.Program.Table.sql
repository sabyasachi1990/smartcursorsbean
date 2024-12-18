USE [SmartCursorSTG]
GO
/****** Object:  Table [License].[Program]    Script Date: 16-12-2024 9.30.57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [License].[Program](
	[Id] [uniqueidentifier] NOT NULL,
	[Category] [nvarchar](100) NOT NULL,
	[Name] [nvarchar](200) NOT NULL,
	[Logo] [nvarchar](500) NULL,
	[Description] [nvarchar](1000) NULL,
	[Status] [int] NULL,
 CONSTRAINT [PK_Program] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
