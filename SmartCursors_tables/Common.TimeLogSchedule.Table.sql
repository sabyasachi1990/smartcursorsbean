USE [SmartCursorSTG]
GO
/****** Object:  Table [Common].[TimeLogSchedule]    Script Date: 16-12-2024 9.30.56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Common].[TimeLogSchedule](
	[Id] [uniqueidentifier] NOT NULL,
	[CaseId] [uniqueidentifier] NOT NULL,
	[DepartmentId] [uniqueidentifier] NULL,
	[DesignationId] [uniqueidentifier] NOT NULL,
	[EmployeeId] [uniqueidentifier] NOT NULL,
	[Level] [int] NULL,
	[ChargeoutRate] [decimal](10, 2) NULL,
	[StartDate] [datetime2](7) NULL,
	[EndDate] [datetime2](7) NULL,
	[ActualHours] [bigint] NULL,
	[ActualCost] [decimal](18, 7) NULL,
	[Remarks] [nvarchar](4000) NULL,
	[RecOrder] [int] NULL,
	[UserCreated] [nvarchar](254) NULL,
	[CreatedDate] [datetime2](7) NULL,
	[ModifiedBy] [nvarchar](254) NULL,
	[ModifiedDate] [datetime2](7) NULL,
	[Version] [smallint] NULL,
	[Status] [int] NULL,
	[FeeAllocationPercentage] [float] NULL,
	[FeeAllocation] [decimal](10, 2) NULL,
	[FeeRecoveryPercentage] [float] NULL,
 CONSTRAINT [PK_TimeLogSchedule] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Common].[TimeLogSchedule] ADD  DEFAULT ((1)) FOR [Status]
GO
ALTER TABLE [Common].[TimeLogSchedule]  WITH CHECK ADD  CONSTRAINT [FK_TimeLogSchedule_CaseGroup] FOREIGN KEY([CaseId])
REFERENCES [WorkFlow].[CaseGroup] ([Id])
GO
ALTER TABLE [Common].[TimeLogSchedule] CHECK CONSTRAINT [FK_TimeLogSchedule_CaseGroup]
GO
ALTER TABLE [Common].[TimeLogSchedule]  WITH CHECK ADD  CONSTRAINT [FK_TimeLogSchedule_Department] FOREIGN KEY([DepartmentId])
REFERENCES [Common].[Department] ([Id])
GO
ALTER TABLE [Common].[TimeLogSchedule] CHECK CONSTRAINT [FK_TimeLogSchedule_Department]
GO
ALTER TABLE [Common].[TimeLogSchedule]  WITH CHECK ADD  CONSTRAINT [FK_TimeLogSchedule_DepartmentDesignation] FOREIGN KEY([DesignationId])
REFERENCES [Common].[DepartmentDesignation] ([Id])
GO
ALTER TABLE [Common].[TimeLogSchedule] CHECK CONSTRAINT [FK_TimeLogSchedule_DepartmentDesignation]
GO
ALTER TABLE [Common].[TimeLogSchedule]  WITH CHECK ADD  CONSTRAINT [FK_TimeLogSchedule_Employee] FOREIGN KEY([EmployeeId])
REFERENCES [Common].[Employee] ([Id])
GO
ALTER TABLE [Common].[TimeLogSchedule] CHECK CONSTRAINT [FK_TimeLogSchedule_Employee]
GO
