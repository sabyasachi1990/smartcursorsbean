USE [SmartCursorSTG]
GO
/****** Object:  Table [Common].[DeleteTables]    Script Date: 16-12-2024 9.30.56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Common].[DeleteTables](
	[SchemaName] [nvarchar](524) NULL,
	[TableName] [nvarchar](524) NULL,
	[UsedIn] [nvarchar](4000) NULL
) ON [PRIMARY]
GO
