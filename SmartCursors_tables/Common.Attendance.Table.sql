USE [SmartCursorSTG]
GO
/****** Object:  Table [Common].[Attendance]    Script Date: 16-12-2024 9.30.56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Common].[Attendance](
	[Id] [uniqueidentifier] NOT NULL,
	[CompanyId] [bigint] NOT NULL,
	[Date] [datetime2](7) NOT NULL,
	[AmFrom] [time](7) NULL,
	[AmTo] [time](7) NULL,
	[PmFrom] [time](7) NULL,
	[PmTo] [time](7) NULL,
	[AttendanceType] [nvarchar](50) NULL,
	[Remarks] [nvarchar](254) NULL,
	[Status] [int] NULL,
 CONSTRAINT [PK_Attendance] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Common].[Attendance] ADD  DEFAULT ((1)) FOR [Status]
GO
ALTER TABLE [Common].[Attendance]  WITH CHECK ADD  CONSTRAINT [FK_Attendance_Company] FOREIGN KEY([CompanyId])
REFERENCES [Common].[Company] ([Id])
GO
ALTER TABLE [Common].[Attendance] CHECK CONSTRAINT [FK_Attendance_Company]
GO
