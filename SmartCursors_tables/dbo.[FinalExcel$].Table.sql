USE [SmartCursorSTG]
GO
/****** Object:  Table [dbo].[[FinalExcel$]]]    Script Date: 16-12-2024 9.30.56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[[FinalExcel$]]](
	[Date] [datetime] NULL,
	[Cursor] [nvarchar](300) NULL,
	[Feature] [nvarchar](300) NULL,
	[FeaturePath] [nvarchar](300) NULL,
	[UserName] [nvarchar](300) NULL,
	[Action] [nvarchar](300) NULL,
	[Remarks] [nvarchar](300) NULL
) ON [PRIMARY]
GO
