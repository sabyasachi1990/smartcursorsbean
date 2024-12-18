USE [SmartCursorSTG]
GO
/****** Object:  Table [Common].[ANACalendarTimeLogItemDetail]    Script Date: 16-12-2024 9.30.56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Common].[ANACalendarTimeLogItemDetail](
	[Id] [uniqueidentifier] NOT NULL,
	[TimeLogItemId] [uniqueidentifier] NOT NULL,
	[EmployeeId] [uniqueidentifier] NOT NULL,
	[IsNew] [bit] NULL
) ON [PRIMARY]
GO
ALTER TABLE [Common].[ANACalendarTimeLogItemDetail]  WITH CHECK ADD  CONSTRAINT [FK_TimeLogItemDetail_ANACalendarTimeLogItem] FOREIGN KEY([TimeLogItemId])
REFERENCES [Common].[ANACalendarTimeLogItem] ([Id])
GO
ALTER TABLE [Common].[ANACalendarTimeLogItemDetail] CHECK CONSTRAINT [FK_TimeLogItemDetail_ANACalendarTimeLogItem]
GO
