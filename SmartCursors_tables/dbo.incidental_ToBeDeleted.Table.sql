USE [SmartCursorSTG]
GO
/****** Object:  Table [dbo].[incidental_ToBeDeleted]    Script Date: 16-12-2024 9.30.56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[incidental_ToBeDeleted](
	[Category] [nvarchar](255) NULL,
	[Item] [nvarchar](255) NULL,
	[NewCategory] [nvarchar](255) NULL
) ON [PRIMARY]
GO
