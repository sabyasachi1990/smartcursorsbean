USE [SmartCursorSTG]
GO
/****** Object:  Table [Audit].[Question_ToBeDeleted]    Script Date: 16-12-2024 9.30.55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Audit].[Question_ToBeDeleted](
	[Id] [uniqueidentifier] NOT NULL,
	[QuestionnaireId] [uniqueidentifier] NOT NULL,
	[GroupName] [nvarchar](4000) NULL,
	[Questionname] [nvarchar](4000) NULL,
	[Answer] [nvarchar](4000) NULL,
	[Text] [nvarchar](4000) NULL,
	[Comment1] [nvarchar](4000) NULL,
	[Comment2] [nvarchar](4000) NULL,
	[Recorder] [int] NULL,
	[GroupRecorder] [int] NULL,
 CONSTRAINT [PK_Question] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Audit].[Question_ToBeDeleted]  WITH CHECK ADD  CONSTRAINT [FK_Question_Questionnaire] FOREIGN KEY([QuestionnaireId])
REFERENCES [Audit].[Questionnaire_ToBeDeleted] ([Id])
GO
ALTER TABLE [Audit].[Question_ToBeDeleted] CHECK CONSTRAINT [FK_Question_Questionnaire]
GO
