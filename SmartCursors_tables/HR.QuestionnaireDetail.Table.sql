USE [SmartCursorSTG]
GO
/****** Object:  Table [HR].[QuestionnaireDetail]    Script Date: 16-12-2024 9.30.57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [HR].[QuestionnaireDetail](
	[Id] [uniqueidentifier] NOT NULL,
	[CompetenceId] [uniqueidentifier] NOT NULL,
	[QuestionnaireId] [uniqueidentifier] NOT NULL,
	[QuestionId] [uniqueidentifier] NOT NULL,
	[Weightage] [decimal](17, 2) NULL,
	[RecOrder] [int] NULL,
	[status] [int] NULL,
	[QuestionName] [nvarchar](4000) NULL,
	[CompetenceName] [nvarchar](200) NULL,
	[Category] [nvarchar](100) NULL,
	[Questiontype] [nvarchar](200) NULL,
	[QuestionRecOrder] [int] NULL,
	[CompetenceRecOrder] [int] NULL,
 CONSTRAINT [PK_QuestionnaireDetail] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [HR].[QuestionnaireDetail]  WITH CHECK ADD  CONSTRAINT [FK_QuestionnaireDetail_Competence] FOREIGN KEY([CompetenceId])
REFERENCES [HR].[Competence] ([Id])
GO
ALTER TABLE [HR].[QuestionnaireDetail] CHECK CONSTRAINT [FK_QuestionnaireDetail_Competence]
GO
ALTER TABLE [HR].[QuestionnaireDetail]  WITH CHECK ADD  CONSTRAINT [FK_QuestionnaireDetail_Question] FOREIGN KEY([QuestionId])
REFERENCES [HR].[Question] ([Id])
GO
ALTER TABLE [HR].[QuestionnaireDetail] CHECK CONSTRAINT [FK_QuestionnaireDetail_Question]
GO
ALTER TABLE [HR].[QuestionnaireDetail]  WITH CHECK ADD  CONSTRAINT [FK_QuestionnaireDetail_Questionnaire] FOREIGN KEY([QuestionnaireId])
REFERENCES [HR].[Questionnaire] ([Id])
GO
ALTER TABLE [HR].[QuestionnaireDetail] CHECK CONSTRAINT [FK_QuestionnaireDetail_Questionnaire]
GO
