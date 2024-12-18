USE [SmartCursorSTG]
GO
/****** Object:  Table [HR].[TrainingTrainers]    Script Date: 16-12-2024 9.30.57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [HR].[TrainingTrainers](
	[Id] [uniqueidentifier] NOT NULL,
	[TrainerId] [uniqueidentifier] NULL,
	[CompanyId] [bigint] NULL,
	[TrainingId] [uniqueidentifier] NULL,
 CONSTRAINT [PK_TrainingTrainers] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [HR].[TrainingTrainers]  WITH CHECK ADD  CONSTRAINT [FK_TrainingTrainers_Training] FOREIGN KEY([TrainingId])
REFERENCES [HR].[Training] ([Id])
GO
ALTER TABLE [HR].[TrainingTrainers] CHECK CONSTRAINT [FK_TrainingTrainers_Training]
GO
