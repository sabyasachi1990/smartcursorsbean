USE [SmartCursorSTG]
GO
/****** Object:  Table [dbo].[PowerAppEmployeeLog]    Script Date: 16-12-2024 9.30.56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[PowerAppEmployeeLog](
	[EmployeeUserNmae] [nvarchar](256) NULL,
	[DateTime] [datetime] NULL,
	[EmployeeFirstName] [nvarchar](256) NULL
) ON [PRIMARY]
GO
