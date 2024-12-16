USE [SmartCursorSTG]
GO
/****** Object:  UserDefinedTableType [dbo].[TempIncharges1]    Script Date: 16-12-2024 9.33.40 PM ******/
CREATE TYPE [dbo].[TempIncharges1] AS TABLE(
	[InchargeId] [nvarchar](max) NOT NULL,
	[AppraiseeId] [uniqueidentifier] NOT NULL,
	[InchargeRecordStatus] [nvarchar](25) NOT NULL
)
GO
