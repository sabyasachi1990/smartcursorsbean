USE [SmartCursorSTG]
GO
/****** Object:  Table [dbo].[TimeLogHistory]    Script Date: 16-12-2024 9.30.56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[TimeLogHistory](
	[Id] [uniqueidentifier] NULL,
	[ExecutionTime] [datetime] NULL,
	[LineNumber] [int] NULL,
	[LineText] [nvarchar](max) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
