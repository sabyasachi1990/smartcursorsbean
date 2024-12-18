USE [SmartCursorSTG]
GO
/****** Object:  Table [Import].[GLImportFromCSV]    Script Date: 16-12-2024 9.30.57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Import].[GLImportFromCSV](
	[Account] [nvarchar](1024) NULL,
	[Date] [nvarchar](1024) NULL,
	[Type] [nvarchar](1024) NULL,
	[Sub Type] [nvarchar](1024) NULL,
	[Doc No] [nvarchar](1024) NULL,
	[Entity] [nvarchar](1024) NULL,
	[Description] [nvarchar](1024) NULL,
	[Curr] [nvarchar](1024) NULL,
	[Debit] [nvarchar](1024) NULL,
	[Credit] [nvarchar](1024) NULL,
	[Balance] [nvarchar](1024) NULL
) ON [PRIMARY]
GO
