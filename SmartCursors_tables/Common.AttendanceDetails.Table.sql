USE [SmartCursorSTG]
GO
/****** Object:  Table [Common].[AttendanceDetails]    Script Date: 16-12-2024 9.30.56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Common].[AttendanceDetails](
	[Id] [uniqueidentifier] NOT NULL,
	[EmployeeId] [uniqueidentifier] NOT NULL,
	[AttendenceId] [uniqueidentifier] NOT NULL,
	[TimeFrom] [time](7) NULL,
	[TimeTo] [time](7) NULL,
	[LateIn] [bit] NULL,
	[LateOut] [bit] NULL,
	[AttendanceType] [nvarchar](50) NULL,
	[AdminLateIn] [bit] NULL,
	[AdminLateOut] [bit] NULL,
	[AdminRemarks] [nvarchar](254) NULL,
	[IsWorkingDay] [float] NULL,
	[Remarks] [nvarchar](254) NULL,
	[RecOrder] [int] NULL,
	[UserCreated] [nvarchar](254) NULL,
	[CreatedDate] [datetime2](7) NULL,
	[ModifiedBy] [nvarchar](254) NULL,
	[ModifiedDate] [datetime2](7) NULL,
	[Version] [smallint] NULL,
	[Status] [int] NULL,
	[IsLateInChanged] [bit] NULL,
	[IsLateoutChanged] [bit] NULL,
	[CheckInLocation] [nvarchar](1000) NULL,
	[CheckOutLocation] [nvarchar](1000) NULL,
	[CheckInRemarks] [nvarchar](600) NULL,
	[CheckOutRemarks] [nvarchar](600) NULL,
	[CheckInPhotoURL] [nvarchar](3000) NULL,
	[CheckOutPhotoURL] [nvarchar](3000) NULL,
	[Latitude] [nvarchar](100) NULL,
	[Longitude] [nvarchar](100) NULL,
	[CheckOutLatitude] [nvarchar](50) NULL,
	[CheckOutLongitude] [nvarchar](50) NULL,
	[EmployeeName] [nvarchar](1000) NULL,
	[DepartmentId] [uniqueidentifier] NULL,
	[DesignationId] [uniqueidentifier] NULL,
	[ServiceEntityId] [bigint] NULL,
	[LeaveApplicationId] [uniqueidentifier] NULL,
	[CalanderId] [uniqueidentifier] NULL,
	[TimeFromString] [nvarchar](50) NULL,
	[TimeToString] [nvarchar](50) NULL,
	[TotalHours] [time](7) NULL,
	[IsCheckInImage] [bit] NULL,
	[IsCheckOutImage] [bit] NULL,
	[TrainingId] [uniqueidentifier] NULL,
	[AttendanceDate] [datetime2](7) NULL,
	[CompanyId] [bigint] NULL,
	[DateValue] [bigint] NULL,
 CONSTRAINT [PK_AttendanceDetails] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Common].[AttendanceDetails] ADD  DEFAULT ((1)) FOR [Status]
GO
ALTER TABLE [Common].[AttendanceDetails] ADD  DEFAULT ((0)) FOR [IsLateInChanged]
GO
ALTER TABLE [Common].[AttendanceDetails] ADD  DEFAULT ((0)) FOR [IsLateoutChanged]
GO
ALTER TABLE [Common].[AttendanceDetails]  WITH CHECK ADD  CONSTRAINT [FK_Attendance_Attendance] FOREIGN KEY([AttendenceId])
REFERENCES [Common].[Attendance] ([Id])
GO
ALTER TABLE [Common].[AttendanceDetails] CHECK CONSTRAINT [FK_Attendance_Attendance]
GO
ALTER TABLE [Common].[AttendanceDetails]  WITH CHECK ADD  CONSTRAINT [FK_Attendance_Employee] FOREIGN KEY([EmployeeId])
REFERENCES [Common].[Employee] ([Id])
GO
ALTER TABLE [Common].[AttendanceDetails] CHECK CONSTRAINT [FK_Attendance_Employee]
GO
