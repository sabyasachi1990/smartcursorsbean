USE [SmartCursorSTG]
GO
/****** Object:  UserDefinedTableType [dbo].[Employees]    Script Date: 16-12-2024 9.33.40 PM ******/
CREATE TYPE [dbo].[Employees] AS TABLE(
	[EmployeeId] [uniqueidentifier] NULL,
	[RecordStatus] [nvarchar](20) NULL
)
GO
