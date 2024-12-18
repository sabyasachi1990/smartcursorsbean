USE [SmartCursorSTG]
GO
/****** Object:  Table [HR].[TeamCalendarDetail]    Script Date: 16-12-2024 9.30.57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [HR].[TeamCalendarDetail](
	[Id] [uniqueidentifier] NOT NULL,
	[MasterId] [uniqueidentifier] NOT NULL,
	[EmployeeId] [uniqueidentifier] NOT NULL,
	[Order] [int] NULL,
	[Status] [int] NULL,
	[IsChecked] [bit] NULL,
 CONSTRAINT [PK_TeamCalendarDetail] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [HR].[TeamCalendarDetail]  WITH CHECK ADD  CONSTRAINT [FK_TeamCalendarDetail_Employee] FOREIGN KEY([EmployeeId])
REFERENCES [Common].[Employee] ([Id])
GO
ALTER TABLE [HR].[TeamCalendarDetail] CHECK CONSTRAINT [FK_TeamCalendarDetail_Employee]
GO
ALTER TABLE [HR].[TeamCalendarDetail]  WITH CHECK ADD  CONSTRAINT [FK_TeamCalendarDetail_TeamCalendar] FOREIGN KEY([MasterId])
REFERENCES [HR].[TeamCalendar] ([Id])
GO
ALTER TABLE [HR].[TeamCalendarDetail] CHECK CONSTRAINT [FK_TeamCalendarDetail_TeamCalendar]
GO
