USE [SmartCursorSTG]
GO
/****** Object:  UserDefinedTableType [dbo].[TempCopyEmployees]    Script Date: 16-12-2024 9.33.40 PM ******/
CREATE TYPE [dbo].[TempCopyEmployees] AS TABLE(
	[FromEmployeeId] [uniqueidentifier] NOT NULL,
	[ToEmployeeId] [uniqueidentifier] NOT NULL,
	[ToEmpStartDate] [datetime] NOT NULL
)
GO
