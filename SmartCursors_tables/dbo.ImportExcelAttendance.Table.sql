USE [SmartCursorSTG]
GO
/****** Object:  Table [dbo].[ImportExcelAttendance]    Script Date: 16-12-2024 9.30.56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ImportExcelAttendance](
	[CommonId] [uniqueidentifier] NOT NULL,
	[DateAndTime] [datetime2](7) NULL,
	[EmployeeName] [nvarchar](100) NULL,
	[AttendanceAttachmentId] [uniqueidentifier] NULL
) ON [PRIMARY]
GO
