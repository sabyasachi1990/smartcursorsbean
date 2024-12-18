USE [SmartCursorSTG]
GO
/****** Object:  Table [HR].[AppraisalResult]    Script Date: 16-12-2024 9.30.56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [HR].[AppraisalResult](
	[Id] [uniqueidentifier] NOT NULL,
	[AppraisalId] [uniqueidentifier] NOT NULL,
	[AppraiserId] [uniqueidentifier] NOT NULL,
	[QuestionnaireId] [uniqueidentifier] NOT NULL,
	[QuestionId] [uniqueidentifier] NOT NULL,
	[CompetenceId] [uniqueidentifier] NOT NULL,
	[Rating] [int] NOT NULL,
	[Comment] [nvarchar](4000) NULL,
	[RecOrder] [int] NULL,
	[QuestionnaireName] [nvarchar](100) NULL,
	[CompetenceName] [nvarchar](200) NULL,
	[QuestionName] [nvarchar](4000) NULL,
	[AppraiseeId] [uniqueidentifier] NULL,
 CONSTRAINT [PK_AppraisalResult] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [HR].[AppraisalResult]  WITH CHECK ADD  CONSTRAINT [FK_AppraisalResult_Appraisal] FOREIGN KEY([AppraisalId])
REFERENCES [HR].[Appraisal] ([Id])
GO
ALTER TABLE [HR].[AppraisalResult] CHECK CONSTRAINT [FK_AppraisalResult_Appraisal]
GO
ALTER TABLE [HR].[AppraisalResult]  WITH CHECK ADD  CONSTRAINT [FK_AppraisalResult_Employee] FOREIGN KEY([AppraiserId])
REFERENCES [Common].[Employee] ([Id])
GO
ALTER TABLE [HR].[AppraisalResult] CHECK CONSTRAINT [FK_AppraisalResult_Employee]
GO
