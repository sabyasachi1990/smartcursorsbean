USE [SmartCursorSTG]
GO
/****** Object:  Table [dbo].[everest$]    Script Date: 16-12-2024 9.30.56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[everest$](
	[Date] [nvarchar](255) NULL,
	[Cursor] [nvarchar](255) NULL,
	[Feature] [nvarchar](255) NULL,
	[FeaturePath] [nvarchar](255) NULL,
	[UserName] [nvarchar](255) NULL,
	[Action] [nvarchar](255) NULL,
	[Remarks] [nvarchar](255) NULL,
	[datenew] [datetime] NULL
) ON [PRIMARY]
GO
