USE [SmartCursorSTG]
GO
/****** Object:  Table [dbo].[Primary_TableNames]    Script Date: 16-12-2024 9.30.56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Primary_TableNames](
	[S_No] [int] IDENTITY(1,1) NOT NULL,
	[CursorName] [nvarchar](250) NULL,
	[TableName] [nvarchar](250) NULL,
	[Feature] [varchar](124) NULL,
	[ModuleMasterId] [int] NULL
) ON [PRIMARY]
GO
