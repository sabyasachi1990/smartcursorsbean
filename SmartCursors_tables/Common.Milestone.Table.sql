USE [SmartCursorSTG]
GO
/****** Object:  Table [Common].[Milestone]    Script Date: 16-12-2024 9.30.56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Common].[Milestone](
	[Id] [bigint] NOT NULL,
	[ServiceGroupId] [bigint] NOT NULL,
	[ServiceId] [bigint] NULL,
	[MilestoneGroup] [nvarchar](100) NOT NULL,
	[RecOrder] [int] NULL,
	[Status] [int] NULL,
 CONSTRAINT [PK_Milestone] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Common].[Milestone] ADD  DEFAULT ((1)) FOR [Status]
GO
ALTER TABLE [Common].[Milestone]  WITH CHECK ADD  CONSTRAINT [FK_Milestone_Service] FOREIGN KEY([ServiceId])
REFERENCES [Common].[Service] ([Id])
GO
ALTER TABLE [Common].[Milestone] CHECK CONSTRAINT [FK_Milestone_Service]
GO
ALTER TABLE [Common].[Milestone]  WITH CHECK ADD  CONSTRAINT [FK_Milestone_ServiceGroup] FOREIGN KEY([ServiceGroupId])
REFERENCES [Common].[ServiceGroup] ([Id])
GO
ALTER TABLE [Common].[Milestone] CHECK CONSTRAINT [FK_Milestone_ServiceGroup]
GO
