USE [SmartCursorSTG]
GO
/****** Object:  Table [WorkFlow].[ScheduleDetailNew]    Script Date: 16-12-2024 9.30.57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [WorkFlow].[ScheduleDetailNew](
	[Id] [uniqueidentifier] NOT NULL,
	[CompanyId] [bigint] NOT NULL,
	[MasterId] [uniqueidentifier] NOT NULL,
	[DepartmentId] [uniqueidentifier] NOT NULL,
	[DesignationId] [uniqueidentifier] NOT NULL,
	[Level] [int] NULL,
	[EmployeeId] [uniqueidentifier] NOT NULL,
	[StartDate] [datetime2](7) NULL,
	[EndDate] [datetime2](7) NULL,
	[IsPrimaryIncharge] [bit] NULL,
	[Status] [int] NOT NULL,
	[IsLocked] [bit] NULL,
	[IsTimeLocked] [bit] NULL,
	[CreatedDate] [datetime2](7) NULL,
	[ChargeoutRate] [decimal](28, 9) NULL,
	[IsQIIncharge] [bit] NULL,
	[IsMicIncharge] [bit] NULL,
 CONSTRAINT [PK_ScheduleDetailNew] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [WorkFlow].[ScheduleDetailNew] ADD  DEFAULT ((1)) FOR [Status]
GO
ALTER TABLE [WorkFlow].[ScheduleDetailNew]  WITH CHECK ADD  CONSTRAINT [FK_ScheduleDetailNew_Department] FOREIGN KEY([DepartmentId])
REFERENCES [Common].[Department] ([Id])
GO
ALTER TABLE [WorkFlow].[ScheduleDetailNew] CHECK CONSTRAINT [FK_ScheduleDetailNew_Department]
GO
ALTER TABLE [WorkFlow].[ScheduleDetailNew]  WITH CHECK ADD  CONSTRAINT [FK_ScheduleDetailNew_DepartmentDesignation] FOREIGN KEY([DesignationId])
REFERENCES [Common].[DepartmentDesignation] ([Id])
GO
ALTER TABLE [WorkFlow].[ScheduleDetailNew] CHECK CONSTRAINT [FK_ScheduleDetailNew_DepartmentDesignation]
GO
ALTER TABLE [WorkFlow].[ScheduleDetailNew]  WITH CHECK ADD  CONSTRAINT [FK_ScheduleDetailNew_Employee] FOREIGN KEY([EmployeeId])
REFERENCES [Common].[Employee] ([Id])
GO
ALTER TABLE [WorkFlow].[ScheduleDetailNew] CHECK CONSTRAINT [FK_ScheduleDetailNew_Employee]
GO
ALTER TABLE [WorkFlow].[ScheduleDetailNew]  WITH CHECK ADD  CONSTRAINT [FK_ScheduleDetailNew_ScheduleNew] FOREIGN KEY([MasterId])
REFERENCES [WorkFlow].[ScheduleNew] ([Id])
GO
ALTER TABLE [WorkFlow].[ScheduleDetailNew] CHECK CONSTRAINT [FK_ScheduleDetailNew_ScheduleNew]
GO
