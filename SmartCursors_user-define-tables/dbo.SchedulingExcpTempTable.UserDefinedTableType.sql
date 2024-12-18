USE [SmartCursorSTG]
GO
/****** Object:  UserDefinedTableType [dbo].[SchedulingExcpTempTable]    Script Date: 16-12-2024 9.33.40 PM ******/
CREATE TYPE [dbo].[SchedulingExcpTempTable] AS TABLE(
	[CompanyId] [int] NULL,
	[EmployeeId] [uniqueidentifier] NULL,
	[hours] [int] NULL,
	[TaskDate] [datetime] NULL,
	[TaskId] [uniqueidentifier] NULL,
	[RecordStatus] [nvarchar](15) NULL
)
GO
