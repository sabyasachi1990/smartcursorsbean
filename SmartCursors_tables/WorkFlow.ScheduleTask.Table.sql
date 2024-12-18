USE [SmartCursorSTG]
GO
/****** Object:  Table [WorkFlow].[ScheduleTask]    Script Date: 16-12-2024 9.30.57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [WorkFlow].[ScheduleTask](
	[Id] [uniqueidentifier] NOT NULL,
	[CompanyId] [bigint] NOT NULL,
	[EmployeeId] [uniqueidentifier] NOT NULL,
	[CaseId] [uniqueidentifier] NOT NULL,
	[Title] [nvarchar](1000) NULL,
	[StartDate] [datetime2](7) NULL,
	[EndDate] [datetime2](7) NULL,
	[Hours] [time](7) NULL,
	[IsOverRun] [bit] NULL,
	[Remarks] [nvarchar](256) NULL,
	[RecOrder] [int] NULL,
	[UserCreated] [nvarchar](254) NULL,
	[CreatedDate] [datetime2](7) NULL,
	[ModifiedBy] [nvarchar](254) NULL,
	[ModifiedDate] [datetime2](7) NULL,
	[Status] [int] NULL,
	[IsOverRunHours] [time](7) NULL,
	[PBIName] [nvarchar](max) NULL,
	[SystemId] [uniqueidentifier] NULL,
	[SystemType] [nvarchar](50) NULL,
	[ScheduleDetailId] [uniqueidentifier] NULL,
	[IsNew] [bit] NULL,
	[OldId] [uniqueidentifier] NULL,
	[PlanedHours] [bigint] NULL,
	[OverRunHours] [bigint] NULL,
 CONSTRAINT [PK_ScheduleTask] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [WorkFlow].[ScheduleTask] ADD  DEFAULT ((1)) FOR [Status]
GO
ALTER TABLE [WorkFlow].[ScheduleTask]  WITH CHECK ADD FOREIGN KEY([ScheduleDetailId])
REFERENCES [WorkFlow].[ScheduleDetail] ([Id])
GO
ALTER TABLE [WorkFlow].[ScheduleTask]  WITH CHECK ADD  CONSTRAINT [FK_ScheduleTask_CaseGroup] FOREIGN KEY([CaseId])
REFERENCES [WorkFlow].[CaseGroup] ([Id])
GO
ALTER TABLE [WorkFlow].[ScheduleTask] CHECK CONSTRAINT [FK_ScheduleTask_CaseGroup]
GO
ALTER TABLE [WorkFlow].[ScheduleTask]  WITH CHECK ADD  CONSTRAINT [FK_ScheduleTask_Company] FOREIGN KEY([CompanyId])
REFERENCES [Common].[Company] ([Id])
GO
ALTER TABLE [WorkFlow].[ScheduleTask] CHECK CONSTRAINT [FK_ScheduleTask_Company]
GO
ALTER TABLE [WorkFlow].[ScheduleTask]  WITH CHECK ADD  CONSTRAINT [FK_ScheduleTask_Employee] FOREIGN KEY([EmployeeId])
REFERENCES [Common].[Employee] ([Id])
GO
ALTER TABLE [WorkFlow].[ScheduleTask] CHECK CONSTRAINT [FK_ScheduleTask_Employee]
GO
