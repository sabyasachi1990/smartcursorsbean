USE [SmartCursorSTG]
GO
/****** Object:  Table [WorkFlow].[ScheduleTaskNew]    Script Date: 16-12-2024 9.30.57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [WorkFlow].[ScheduleTaskNew](
	[Id] [uniqueidentifier] NOT NULL,
	[CompanyId] [bigint] NOT NULL,
	[CaseId] [uniqueidentifier] NOT NULL,
	[ScheduleDetailId] [uniqueidentifier] NOT NULL,
	[DepartmentId] [uniqueidentifier] NOT NULL,
	[DesignationId] [uniqueidentifier] NOT NULL,
	[EmployeeId] [uniqueidentifier] NOT NULL,
	[Level] [int] NULL,
	[ChargeoutRate] [decimal](28, 9) NULL,
	[StartDate] [datetime2](7) NOT NULL,
	[EndDate] [datetime2](7) NOT NULL,
	[IsOverRun] [bit] NULL,
	[PlannedHours] [int] NOT NULL,
	[OverRunHours] [int] NULL,
	[Task] [nvarchar](500) NOT NULL,
	[Remarks] [nvarchar](300) NULL,
	[Status] [int] NOT NULL,
	[WeekNumber] [int] NULL,
 CONSTRAINT [PK_ScheduleTaskNew] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [WorkFlow].[ScheduleTaskNew] ADD  DEFAULT ((1)) FOR [Status]
GO
ALTER TABLE [WorkFlow].[ScheduleTaskNew]  WITH CHECK ADD  CONSTRAINT [FK_ScheduleTaskNew_CaseGroup] FOREIGN KEY([CaseId])
REFERENCES [WorkFlow].[CaseGroup] ([Id])
GO
ALTER TABLE [WorkFlow].[ScheduleTaskNew] CHECK CONSTRAINT [FK_ScheduleTaskNew_CaseGroup]
GO
ALTER TABLE [WorkFlow].[ScheduleTaskNew]  WITH CHECK ADD  CONSTRAINT [FK_ScheduleTaskNew_Company] FOREIGN KEY([CompanyId])
REFERENCES [Common].[Company] ([Id])
GO
ALTER TABLE [WorkFlow].[ScheduleTaskNew] CHECK CONSTRAINT [FK_ScheduleTaskNew_Company]
GO
ALTER TABLE [WorkFlow].[ScheduleTaskNew]  WITH CHECK ADD  CONSTRAINT [FK_ScheduleTaskNew_Department] FOREIGN KEY([DepartmentId])
REFERENCES [Common].[Department] ([Id])
GO
ALTER TABLE [WorkFlow].[ScheduleTaskNew] CHECK CONSTRAINT [FK_ScheduleTaskNew_Department]
GO
ALTER TABLE [WorkFlow].[ScheduleTaskNew]  WITH CHECK ADD  CONSTRAINT [FK_ScheduleTaskNew_DepartmentDesignation] FOREIGN KEY([DesignationId])
REFERENCES [Common].[DepartmentDesignation] ([Id])
GO
ALTER TABLE [WorkFlow].[ScheduleTaskNew] CHECK CONSTRAINT [FK_ScheduleTaskNew_DepartmentDesignation]
GO
ALTER TABLE [WorkFlow].[ScheduleTaskNew]  WITH CHECK ADD  CONSTRAINT [FK_ScheduleTaskNew_Employee] FOREIGN KEY([EmployeeId])
REFERENCES [Common].[Employee] ([Id])
GO
ALTER TABLE [WorkFlow].[ScheduleTaskNew] CHECK CONSTRAINT [FK_ScheduleTaskNew_Employee]
GO
ALTER TABLE [WorkFlow].[ScheduleTaskNew]  WITH CHECK ADD  CONSTRAINT [FK_ScheduleTaskNew_ScheduleDetailNew] FOREIGN KEY([ScheduleDetailId])
REFERENCES [WorkFlow].[ScheduleDetailNew] ([Id])
GO
ALTER TABLE [WorkFlow].[ScheduleTaskNew] CHECK CONSTRAINT [FK_ScheduleTaskNew_ScheduleDetailNew]
GO
