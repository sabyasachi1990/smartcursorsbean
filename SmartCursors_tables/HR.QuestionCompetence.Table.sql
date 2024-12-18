USE [SmartCursorSTG]
GO
/****** Object:  Table [HR].[QuestionCompetence]    Script Date: 16-12-2024 9.30.57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [HR].[QuestionCompetence](
	[Id] [uniqueidentifier] NOT NULL,
	[QuestionId] [uniqueidentifier] NOT NULL,
	[CompetenceId] [uniqueidentifier] NOT NULL,
	[RecOrder] [int] NULL,
	[CompetenceName] [nvarchar](200) NULL,
 CONSTRAINT [PK_QuestionCompetence] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [HR].[QuestionCompetence]  WITH CHECK ADD  CONSTRAINT [FK_QuestionCompetence_Competence] FOREIGN KEY([CompetenceId])
REFERENCES [HR].[Competence] ([Id])
GO
ALTER TABLE [HR].[QuestionCompetence] CHECK CONSTRAINT [FK_QuestionCompetence_Competence]
GO
ALTER TABLE [HR].[QuestionCompetence]  WITH CHECK ADD  CONSTRAINT [FK_QuestionCompetence_Question] FOREIGN KEY([QuestionId])
REFERENCES [HR].[Question] ([Id])
GO
ALTER TABLE [HR].[QuestionCompetence] CHECK CONSTRAINT [FK_QuestionCompetence_Question]
GO
