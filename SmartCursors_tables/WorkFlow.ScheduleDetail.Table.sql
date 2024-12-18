USE [SmartCursorSTG]
GO
/****** Object:  Table [WorkFlow].[ScheduleDetail]    Script Date: 16-12-2024 9.30.57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [WorkFlow].[ScheduleDetail](
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
	[IsSystem] [bit] NULL,
	[WithoutOverrunCost] [decimal](28, 7) NULL,
	[OldPlannedCost] [decimal](18, 7) NULL,
 CONSTRAINT [PK_ScheduleDetail] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [WorkFlow].[ScheduleDetail] ADD  DEFAULT ((1)) FOR [Status]
GO
ALTER TABLE [WorkFlow].[ScheduleDetail]  WITH CHECK ADD  CONSTRAINT [FK_ScheduleDetail_Department] FOREIGN KEY([DepartmentId])
REFERENCES [Common].[Department] ([Id])
GO
ALTER TABLE [WorkFlow].[ScheduleDetail] CHECK CONSTRAINT [FK_ScheduleDetail_Department]
GO
ALTER TABLE [WorkFlow].[ScheduleDetail]  WITH CHECK ADD  CONSTRAINT [FK_ScheduleDetail_DepartmentDesignation] FOREIGN KEY([DesignationId])
REFERENCES [Common].[DepartmentDesignation] ([Id])
GO
ALTER TABLE [WorkFlow].[ScheduleDetail] CHECK CONSTRAINT [FK_ScheduleDetail_DepartmentDesignation]
GO
ALTER TABLE [WorkFlow].[ScheduleDetail]  WITH CHECK ADD  CONSTRAINT [FK_ScheduleDetail_Employee] FOREIGN KEY([EmployeeId])
REFERENCES [Common].[Employee] ([Id])
GO
ALTER TABLE [WorkFlow].[ScheduleDetail] CHECK CONSTRAINT [FK_ScheduleDetail_Employee]
GO
ALTER TABLE [WorkFlow].[ScheduleDetail]  WITH CHECK ADD  CONSTRAINT [FK_ScheduleDetail_Schedule] FOREIGN KEY([MasterId])
REFERENCES [WorkFlow].[Schedule] ([Id])
GO
ALTER TABLE [WorkFlow].[ScheduleDetail] CHECK CONSTRAINT [FK_ScheduleDetail_Schedule]
GO
