USE [SmartCursorSTG]
GO
/****** Object:  Table [WorkFlow].[TimeLogTasks]    Script Date: 16-12-2024 9.30.57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [WorkFlow].[TimeLogTasks](
	[Id] [uniqueidentifier] NOT NULL,
	[CompanyId] [bigint] NULL,
	[TimeLogId] [uniqueidentifier] NOT NULL,
	[TaskName] [nvarchar](250) NULL,
 CONSTRAINT [PK_TimeLogTasks] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [WorkFlow].[TimeLogTasks]  WITH CHECK ADD  CONSTRAINT [FK_TimeLogTasks_TimeLog] FOREIGN KEY([TimeLogId])
REFERENCES [Common].[TimeLog] ([Id])
GO
ALTER TABLE [WorkFlow].[TimeLogTasks] CHECK CONSTRAINT [FK_TimeLogTasks_TimeLog]
GO
