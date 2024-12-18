USE [SmartCursorSTG]
GO
/****** Object:  Table [HR].[QuestionnaireObjective]    Script Date: 16-12-2024 9.30.57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [HR].[QuestionnaireObjective](
	[Id] [uniqueidentifier] NOT NULL,
	[ObjectiveId] [uniqueidentifier] NOT NULL,
	[QuestionnaireId] [uniqueidentifier] NOT NULL,
	[RecOrder] [int] NULL,
	[ObjectiveName] [nvarchar](500) NULL,
 CONSTRAINT [PK_QuestionnaireObjective] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [HR].[QuestionnaireObjective]  WITH CHECK ADD  CONSTRAINT [FK_QuestionnaireObjective_Objective] FOREIGN KEY([ObjectiveId])
REFERENCES [HR].[Objective] ([Id])
GO
ALTER TABLE [HR].[QuestionnaireObjective] CHECK CONSTRAINT [FK_QuestionnaireObjective_Objective]
GO
ALTER TABLE [HR].[QuestionnaireObjective]  WITH CHECK ADD  CONSTRAINT [FK_QuestionnaireObjective_Questionnaire] FOREIGN KEY([QuestionnaireId])
REFERENCES [HR].[Questionnaire] ([Id])
GO
ALTER TABLE [HR].[QuestionnaireObjective] CHECK CONSTRAINT [FK_QuestionnaireObjective_Questionnaire]
GO
