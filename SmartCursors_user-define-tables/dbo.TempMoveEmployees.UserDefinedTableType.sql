USE [SmartCursorSTG]
GO
/****** Object:  UserDefinedTableType [dbo].[TempMoveEmployees]    Script Date: 16-12-2024 9.33.40 PM ******/
CREATE TYPE [dbo].[TempMoveEmployees] AS TABLE(
	[FromEmployeeId] [uniqueidentifier] NOT NULL,
	[ToEmpStartDate] [datetime] NOT NULL
)
GO
