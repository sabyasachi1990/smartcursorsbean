USE [SmartCursorSTG]
GO
/****** Object:  Table [dbo].[Excel_Dept_Mod]    Script Date: 16-12-2024 9.30.56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Excel_Dept_Mod](
	[Empid] [uniqueidentifier] NULL,
	[EmpName] [nvarchar](250) NULL,
	[CurrentDept] [nvarchar](50) NULL,
	[OldDeptid] [uniqueidentifier] NULL,
	[NewDept] [nvarchar](50) NULL,
	[NewDeptId] [uniqueidentifier] NULL
) ON [PRIMARY]
GO
