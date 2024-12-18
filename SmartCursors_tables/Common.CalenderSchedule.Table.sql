USE [SmartCursorSTG]
GO
/****** Object:  Table [Common].[CalenderSchedule]    Script Date: 16-12-2024 9.30.56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Common].[CalenderSchedule](
	[Id] [uniqueidentifier] NOT NULL,
	[Name] [nvarchar](400) NOT NULL,
	[CompanyId] [bigint] NOT NULL,
	[CalenderId] [uniqueidentifier] NULL,
	[ApplyToAll] [bit] NULL,
	[StartDate] [datetime2](7) NULL,
	[EndDate] [datetime2](7) NULL,
	[Hours] [decimal](17, 2) NOT NULL,
	[FirstHalfFromTime] [time](7) NULL,
	[FirstHalfToTime] [time](7) NULL,
	[FirstHalfTotalHours] [time](7) NULL,
	[SecondHalfFromTime] [time](7) NULL,
	[SecondHalfToTime] [time](7) NULL,
	[SecondHalfTotalHours] [time](7) NULL,
	[TimeType] [nvarchar](50) NULL,
 CONSTRAINT [CalenderSchedule_PK] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Common].[CalenderSchedule]  WITH CHECK ADD  CONSTRAINT [CalenderId_FK] FOREIGN KEY([CalenderId])
REFERENCES [Common].[Calender] ([Id])
GO
ALTER TABLE [Common].[CalenderSchedule] CHECK CONSTRAINT [CalenderId_FK]
GO
