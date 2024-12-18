USE [SmartCursorSTG]
GO
/****** Object:  Table [HR].[TrainingAttendance]    Script Date: 16-12-2024 9.30.57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [HR].[TrainingAttendance](
	[Id] [uniqueidentifier] NOT NULL,
	[EmployeeId] [uniqueidentifier] NOT NULL,
	[TrainingScheduleId] [uniqueidentifier] NOT NULL,
	[TrainingId] [uniqueidentifier] NOT NULL,
	[AttendanceDate] [datetime2](7) NULL,
	[AMAttended] [bit] NULL,
	[PMAttended] [bit] NULL,
	[IsAMRequried] [bit] NULL,
	[IsPMRequired] [bit] NULL,
	[IsDisabled] [bit] NULL,
 CONSTRAINT [PK_TrainingAttendance] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [HR].[TrainingAttendance] ADD  DEFAULT ((0)) FOR [AMAttended]
GO
ALTER TABLE [HR].[TrainingAttendance] ADD  DEFAULT ((0)) FOR [PMAttended]
GO
ALTER TABLE [HR].[TrainingAttendance] ADD  DEFAULT ((0)) FOR [IsAMRequried]
GO
ALTER TABLE [HR].[TrainingAttendance] ADD  DEFAULT ((0)) FOR [IsPMRequired]
GO
ALTER TABLE [HR].[TrainingAttendance] ADD  DEFAULT ((0)) FOR [IsDisabled]
GO
ALTER TABLE [HR].[TrainingAttendance]  WITH CHECK ADD  CONSTRAINT [FK_TrainingAttendance_Employee] FOREIGN KEY([EmployeeId])
REFERENCES [Common].[Employee] ([Id])
GO
ALTER TABLE [HR].[TrainingAttendance] CHECK CONSTRAINT [FK_TrainingAttendance_Employee]
GO
ALTER TABLE [HR].[TrainingAttendance]  WITH CHECK ADD  CONSTRAINT [FK_TrainingAttendance_Training] FOREIGN KEY([TrainingId])
REFERENCES [HR].[Training] ([Id])
GO
ALTER TABLE [HR].[TrainingAttendance] CHECK CONSTRAINT [FK_TrainingAttendance_Training]
GO
ALTER TABLE [HR].[TrainingAttendance]  WITH CHECK ADD  CONSTRAINT [FK_TrainingAttendance_TrainingSchedule] FOREIGN KEY([TrainingScheduleId])
REFERENCES [HR].[TrainingSchedule] ([Id])
GO
ALTER TABLE [HR].[TrainingAttendance] CHECK CONSTRAINT [FK_TrainingAttendance_TrainingSchedule]
GO
