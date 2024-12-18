USE [SmartCursorSTG]
GO
/****** Object:  Table [Common].[Task]    Script Date: 16-12-2024 9.30.56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Common].[Task](
	[Id] [uniqueidentifier] NOT NULL,
	[ServiceGroupId] [bigint] NULL,
	[ServiceId] [bigint] NULL,
	[TaskDescription] [nvarchar](100) NULL,
	[RecOrder] [int] NULL,
	[Status] [int] NULL,
 CONSTRAINT [PK_Task] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Common].[Task]  WITH CHECK ADD  CONSTRAINT [FK_Task_Service] FOREIGN KEY([ServiceId])
REFERENCES [Common].[Service] ([Id])
GO
ALTER TABLE [Common].[Task] CHECK CONSTRAINT [FK_Task_Service]
GO
ALTER TABLE [Common].[Task]  WITH CHECK ADD  CONSTRAINT [FK_Task_ServiceGroup] FOREIGN KEY([ServiceGroupId])
REFERENCES [Common].[ServiceGroup] ([Id])
GO
ALTER TABLE [Common].[Task] CHECK CONSTRAINT [FK_Task_ServiceGroup]
GO
