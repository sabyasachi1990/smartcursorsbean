USE [SmartCursorSTG]
GO
/****** Object:  Table [Common].[WorkWeekSetUp]    Script Date: 16-12-2024 9.30.56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Common].[WorkWeekSetUp](
	[Id] [uniqueidentifier] NOT NULL,
	[CompanyId] [bigint] NULL,
	[WeekDay] [nvarchar](20) NULL,
	[AMFromTime] [time](7) NOT NULL,
	[AMToTime] [time](7) NOT NULL,
	[PMFromTime] [time](7) NOT NULL,
	[PMToTime] [time](7) NOT NULL,
	[WorkingHours] [time](7) NULL,
	[EmployeeId] [uniqueidentifier] NULL,
	[UserCreated] [nvarchar](254) NULL,
	[CreatedDate] [datetime2](7) NULL,
	[ModifiedBy] [nvarchar](254) NULL,
	[ModifiedDate] [datetime2](7) NULL,
	[Remarks] [nvarchar](1000) NULL,
	[Status] [int] NULL,
	[IsWorkingDay] [bit] NULL,
	[RecOrder] [int] NULL,
 CONSTRAINT [PK_WorkWeekSetUp] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Common].[WorkWeekSetUp] ADD  DEFAULT ('00:00:00') FOR [WorkingHours]
GO
ALTER TABLE [Common].[WorkWeekSetUp]  WITH CHECK ADD  CONSTRAINT [FK_WorkWeekSetUp_Company] FOREIGN KEY([CompanyId])
REFERENCES [Common].[Company] ([Id])
GO
ALTER TABLE [Common].[WorkWeekSetUp] CHECK CONSTRAINT [FK_WorkWeekSetUp_Company]
GO
ALTER TABLE [Common].[WorkWeekSetUp]  WITH CHECK ADD  CONSTRAINT [FK_WorkWeekSetUp_Employee] FOREIGN KEY([EmployeeId])
REFERENCES [Common].[Employee] ([Id])
GO
ALTER TABLE [Common].[WorkWeekSetUp] CHECK CONSTRAINT [FK_WorkWeekSetUp_Employee]
GO
