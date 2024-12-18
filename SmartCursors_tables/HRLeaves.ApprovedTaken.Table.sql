USE [SmartCursorSTG]
GO
/****** Object:  Table [HRLeaves].[ApprovedTaken]    Script Date: 16-12-2024 9.30.57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [HRLeaves].[ApprovedTaken](
	[CompanyId] [bigint] NULL,
	[EmployeeId] [uniqueidentifier] NULL,
	[LeaveTypeId] [uniqueidentifier] NULL,
	[EmployeeName] [nvarchar](100) NULL,
	[TotalTaken] [float] NULL
) ON [PRIMARY]
GO
