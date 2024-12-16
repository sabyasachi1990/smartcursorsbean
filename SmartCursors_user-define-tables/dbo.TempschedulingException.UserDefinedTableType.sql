USE [SmartCursorSTG]
GO
/****** Object:  UserDefinedTableType [dbo].[TempschedulingException]    Script Date: 16-12-2024 9.33.40 PM ******/
CREATE TYPE [dbo].[TempschedulingException] AS TABLE(
	[FromEmpId] [uniqueidentifier] NOT NULL,
	[ToEmpId] [uniqueidentifier] NOT NULL,
	[ToEmployeeStartDate] [datetime] NOT NULL
)
GO
