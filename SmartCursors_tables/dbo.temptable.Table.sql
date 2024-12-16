USE [SmartCursorSTG]
GO
/****** Object:  Table [dbo].[temptable]    Script Date: 16-12-2024 9.30.56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[temptable](
	[ScheduleTaskId] [uniqueidentifier] NULL,
	[ScheduleDetailId] [uniqueidentifier] NULL,
	[EmployeeId] [uniqueidentifier] NULL,
	[CaseId] [uniqueidentifier] NULL,
	[CompanyId] [bigint] NULL
) ON [PRIMARY]
GO
