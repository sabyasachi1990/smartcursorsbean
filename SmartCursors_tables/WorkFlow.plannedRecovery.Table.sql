USE [SmartCursorSTG]
GO
/****** Object:  Table [WorkFlow].[plannedRecovery]    Script Date: 16-12-2024 9.30.57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [WorkFlow].[plannedRecovery](
	[Id] [uniqueidentifier] NULL,
	[CaseId] [uniqueidentifier] NULL,
	[EmployeeId] [uniqueidentifier] NULL,
	[Department] [nvarchar](200) NULL,
	[Designation] [nvarchar](300) NULL,
	[ChargeoutRate] [decimal](28, 9) NULL,
	[FeeAllocationdollar] [decimal](28, 9) NULL,
	[Feeallocationpercentage] [decimal](28, 9) NULL,
	[StartDate] [datetime2](7) NULL,
	[EndDate] [datetime2](7) NULL
) ON [PRIMARY]
GO
