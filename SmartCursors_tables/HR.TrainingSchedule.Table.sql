USE [SmartCursorSTG]
GO
/****** Object:  Table [HR].[TrainingSchedule]    Script Date: 16-12-2024 9.30.57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [HR].[TrainingSchedule](
	[Id] [uniqueidentifier] NOT NULL,
	[TrainingId] [uniqueidentifier] NOT NULL,
	[TrainingDate] [datetime2](7) NOT NULL,
	[FirstHalfFromTime] [time](7) NULL,
	[FirstHalfToTime] [time](7) NULL,
	[FirstHalfTotalHours] [time](7) NULL,
	[SecondHalfFromTime] [time](7) NULL,
	[SecondHalfToTime] [time](7) NULL,
	[SecondHalfTotalHours] [time](7) NULL,
 CONSTRAINT [PK_TrainingSchedule] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [HR].[TrainingSchedule]  WITH CHECK ADD  CONSTRAINT [FK_TrainingSchedule_Training] FOREIGN KEY([TrainingId])
REFERENCES [HR].[Training] ([Id])
GO
ALTER TABLE [HR].[TrainingSchedule] CHECK CONSTRAINT [FK_TrainingSchedule_Training]
GO
