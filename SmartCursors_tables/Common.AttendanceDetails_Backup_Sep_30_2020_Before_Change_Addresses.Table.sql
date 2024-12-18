USE [SmartCursorSTG]
GO
/****** Object:  Table [Common].[AttendanceDetails_Backup_Sep_30_2020_Before_Change_Addresses]    Script Date: 16-12-2024 9.30.56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Common].[AttendanceDetails_Backup_Sep_30_2020_Before_Change_Addresses](
	[CompanyId] [bigint] NULL,
	[FirstName] [nvarchar](500) NULL,
	[Username] [nvarchar](500) NULL,
	[Date] [datetime2](7) NULL,
	[AttendanceId] [uniqueidentifier] NULL,
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
	[CheckOutLongitude] [nvarchar](50) NULL
) ON [PRIMARY]
GO
