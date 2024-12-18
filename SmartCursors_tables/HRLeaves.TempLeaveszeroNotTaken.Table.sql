USE [SmartCursorSTG]
GO
/****** Object:  Table [HRLeaves].[TempLeaveszeroNotTaken]    Script Date: 16-12-2024 9.30.57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [HRLeaves].[TempLeaveszeroNotTaken](
	[CompanyId] [bigint] NULL,
	[CompanyName] [nvarchar](100) NULL,
	[EmployeeName] [nvarchar](250) NULL,
	[EmployeeId] [uniqueidentifier] NULL,
	[LeaveTypeId] [uniqueidentifier] NULL,
	[EntitlementLeaves] [float] NULL,
	[NottakenLeaves] [float] NULL,
	[Remarks] [nvarchar](100) NULL
) ON [PRIMARY]
GO
