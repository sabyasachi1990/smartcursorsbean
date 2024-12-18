USE [SmartCursorSTG]
GO
/****** Object:  Table [WorkFlow].[TimeLogTaskDetails]    Script Date: 16-12-2024 9.30.57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [WorkFlow].[TimeLogTaskDetails](
	[Id] [uniqueidentifier] NOT NULL,
	[TimeLogTaskId] [uniqueidentifier] NOT NULL,
	[Date] [datetime2](7) NULL,
	[Hours] [time](7) NOT NULL,
	[IsTasksColHours] [time](7) NULL,
	[Remarks] [nvarchar](max) NULL,
 CONSTRAINT [PK_TimeLogTaskDetails] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [WorkFlow].[TimeLogTaskDetails]  WITH CHECK ADD  CONSTRAINT [FK_TimeLogTaskId] FOREIGN KEY([TimeLogTaskId])
REFERENCES [WorkFlow].[TimeLogTasks] ([Id])
GO
ALTER TABLE [WorkFlow].[TimeLogTaskDetails] CHECK CONSTRAINT [FK_TimeLogTaskId]
GO
