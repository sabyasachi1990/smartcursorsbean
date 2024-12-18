USE [SmartCursorSTG]
GO
/****** Object:  Table [dbo].[DuplicateScheuleDetail_ToBeDeleted]    Script Date: 16-12-2024 9.30.56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[DuplicateScheuleDetail_ToBeDeleted](
	[Id] [uniqueidentifier] NOT NULL,
	[MasterId] [uniqueidentifier] NOT NULL,
	[DepartmentId] [uniqueidentifier] NULL,
	[DesignationId] [uniqueidentifier] NOT NULL,
	[EmployeeId] [uniqueidentifier] NOT NULL,
	[Level] [int] NULL,
	[StartDate] [datetime2](7) NULL,
	[EndDate] [datetime2](7) NULL,
	[PlanedHours] [bigint] NULL,
	[ChargeoutRate] [decimal](10, 2) NULL,
	[FeeAllocationPercentage] [float] NULL,
	[FeeAllocation] [decimal](10, 2) NULL,
	[Fee RecoveryPercentage] [float] NULL,
	[ActualStartDate] [datetime2](7) NULL,
	[ActualEndDate] [datetime2](7) NULL,
	[ActualHours] [bigint] NULL,
	[Remarks] [nvarchar](4000) NULL,
	[RecOrder] [int] NULL,
	[UserCreated] [nvarchar](254) NULL,
	[CreatedDate] [datetime2](7) NULL,
	[ModifiedBy] [nvarchar](254) NULL,
	[ModifiedDate] [datetime2](7) NULL,
	[Version] [smallint] NULL,
	[Status] [int] NULL,
	[IsLocked] [bit] NULL,
	[ActualDepartmentId] [uniqueidentifier] NULL,
	[ActualDesignationId] [uniqueidentifier] NULL,
	[ActualLevel] [int] NULL,
	[ActualChargeOutRate] [decimal](10, 2) NULL,
	[IsPrimaryIncharge] [bit] NULL,
	[PlannedCost] [decimal](18, 7) NULL,
	[ActualCost] [decimal](18, 7) NULL,
	[IsSystem] [bit] NULL
) ON [PRIMARY]
GO
