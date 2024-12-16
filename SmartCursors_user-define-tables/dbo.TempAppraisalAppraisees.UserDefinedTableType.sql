USE [SmartCursorSTG]
GO
/****** Object:  UserDefinedTableType [dbo].[TempAppraisalAppraisees]    Script Date: 16-12-2024 9.33.40 PM ******/
CREATE TYPE [dbo].[TempAppraisalAppraisees] AS TABLE(
	[EmployeeId] [uniqueidentifier] NOT NULL,
	[RecordStatus] [nvarchar](20) NOT NULL,
	[IsChecked] [bit] NOT NULL
)
GO
