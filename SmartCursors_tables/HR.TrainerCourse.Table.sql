USE [SmartCursorSTG]
GO
/****** Object:  Table [HR].[TrainerCourse]    Script Date: 16-12-2024 9.30.57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [HR].[TrainerCourse](
	[Id] [uniqueidentifier] NOT NULL,
	[TrainerId] [uniqueidentifier] NOT NULL,
	[CourseLibraryId] [uniqueidentifier] NULL,
	[RecOrder] [int] NULL,
 CONSTRAINT [PK_TrainerCourse] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [HR].[TrainerCourse]  WITH CHECK ADD  CONSTRAINT [FK_TrainerCourse_CourseLibrary] FOREIGN KEY([CourseLibraryId])
REFERENCES [HR].[CourseLibrary] ([Id])
GO
ALTER TABLE [HR].[TrainerCourse] CHECK CONSTRAINT [FK_TrainerCourse_CourseLibrary]
GO
ALTER TABLE [HR].[TrainerCourse]  WITH CHECK ADD  CONSTRAINT [FK_TrainerCourse_Trainer] FOREIGN KEY([TrainerId])
REFERENCES [HR].[Trainer] ([Id])
GO
ALTER TABLE [HR].[TrainerCourse] CHECK CONSTRAINT [FK_TrainerCourse_Trainer]
GO
