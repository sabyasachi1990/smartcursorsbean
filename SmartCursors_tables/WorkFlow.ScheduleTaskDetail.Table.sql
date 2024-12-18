USE [SmartCursorSTG]
GO
/****** Object:  Table [WorkFlow].[ScheduleTaskDetail]    Script Date: 16-12-2024 9.30.57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [WorkFlow].[ScheduleTaskDetail](
	[Id] [uniqueidentifier] NOT NULL,
	[ScheduleTaskId] [uniqueidentifier] NOT NULL,
	[CaseFeatureId] [uniqueidentifier] NOT NULL,
	[CreatedDate] [datetime2](7) NULL,
	[UserCreated] [nvarchar](254) NULL,
	[ModifiedDate] [datetime2](7) NULL,
	[ModifiedBy] [nvarchar](254) NULL,
	[Hours] [decimal](7, 2) NULL,
 CONSTRAINT [PK_ScheduleTaskDetail] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [WorkFlow].[ScheduleTaskDetail]  WITH CHECK ADD  CONSTRAINT [PK_ScheduleTaskDetail_CaseFeature] FOREIGN KEY([CaseFeatureId])
REFERENCES [WorkFlow].[CaseFeature] ([Id])
GO
ALTER TABLE [WorkFlow].[ScheduleTaskDetail] CHECK CONSTRAINT [PK_ScheduleTaskDetail_CaseFeature]
GO
ALTER TABLE [WorkFlow].[ScheduleTaskDetail]  WITH CHECK ADD  CONSTRAINT [PK_ScheduleTaskDetail_ScheduleTask] FOREIGN KEY([ScheduleTaskId])
REFERENCES [WorkFlow].[ScheduleTask] ([Id])
GO
ALTER TABLE [WorkFlow].[ScheduleTaskDetail] CHECK CONSTRAINT [PK_ScheduleTaskDetail_ScheduleTask]
GO
