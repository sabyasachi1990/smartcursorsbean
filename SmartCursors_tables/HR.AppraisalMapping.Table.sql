USE [SmartCursorSTG]
GO
/****** Object:  Table [HR].[AppraisalMapping]    Script Date: 16-12-2024 9.30.56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [HR].[AppraisalMapping](
	[Id] [uniqueidentifier] NOT NULL,
	[AppraisalId] [uniqueidentifier] NOT NULL,
	[Questionarie] [nvarchar](400) NOT NULL,
	[Question] [nvarchar](1000) NOT NULL,
	[CompetenceName] [nvarchar](400) NOT NULL,
	[ObjectiveName] [nvarchar](max) NULL,
	[QuestionWeightage] [decimal](17, 2) NULL,
	[QuestionnaireId] [uniqueidentifier] NOT NULL,
	[QuestionId] [uniqueidentifier] NOT NULL,
	[CompetenceId] [uniqueidentifier] NOT NULL,
	[ObjectiveId] [nvarchar](max) NULL,
	[QuestionType] [nvarchar](100) NULL,
	[QuestionOptions] [nvarchar](100) NULL,
	[QuestionRecOrder] [int] NULL,
	[CompetenceRecOrder] [int] NULL,
 CONSTRAINT [PK_ApprisalMapping] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [HR].[AppraisalMapping]  WITH CHECK ADD  CONSTRAINT [PK_ApprisalMapping_Appraisal] FOREIGN KEY([AppraisalId])
REFERENCES [HR].[Appraisal] ([Id])
GO
ALTER TABLE [HR].[AppraisalMapping] CHECK CONSTRAINT [PK_ApprisalMapping_Appraisal]
GO
