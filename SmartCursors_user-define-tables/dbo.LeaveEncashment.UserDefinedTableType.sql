USE [SmartCursorSTG]
GO
/****** Object:  UserDefinedTableType [dbo].[LeaveEncashment]    Script Date: 16-12-2024 9.33.40 PM ******/
CREATE TYPE [dbo].[LeaveEncashment] AS TABLE(
	[EmployeeId] [uniqueidentifier] NULL,
	[Days] [float] NULL
)
GO
