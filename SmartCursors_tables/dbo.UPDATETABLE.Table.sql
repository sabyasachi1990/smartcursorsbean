USE [SmartCursorSTG]
GO
/****** Object:  Table [dbo].[UPDATETABLE]    Script Date: 16-12-2024 9.30.56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[UPDATETABLE](
	[CaseNumber] [nvarchar](100) NULL,
	[EmpName] [nvarchar](100) NULL,
	[CompanyId] [int] NULL,
	[CaseId] [uniqueidentifier] NULL,
	[DepartmentId] [uniqueidentifier] NULL,
	[DesignationId] [uniqueidentifier] NULL,
	[Level] [int] NULL,
	[ChargeoutRate] [decimal](28, 9) NULL,
	[EmployeeId] [uniqueidentifier] NULL,
	[CreatedDate] [datetime2](7) NULL
) ON [PRIMARY]
GO
