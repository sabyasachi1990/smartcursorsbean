USE [SmartCursorSTG]
GO
/****** Object:  Table [Tax].[PAndCSectionQuestions]    Script Date: 16-12-2024 9.30.57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Tax].[PAndCSectionQuestions](
	[Id] [uniqueidentifier] NOT NULL,
	[PAndCSectionId] [uniqueidentifier] NOT NULL,
	[Question] [nvarchar](4000) NULL,
	[QuestionOptions] [nvarchar](50) NULL,
	[Answer] [nvarchar](20) NULL,
	[IsComment] [bit] NULL,
	[Comment] [nvarchar](4000) NULL,
	[IsAttachement] [bit] NULL,
	[AttachmentsCount] [int] NULL,
	[Remarks] [nvarchar](4000) NULL,
	[UserCreated] [nvarchar](254) NULL,
	[CreatedDate] [datetime2](7) NULL,
	[ModifiedBy] [nvarchar](254) NULL,
	[ModifiedDate] [datetime2](7) NULL,
	[Status] [int] NULL,
	[Recorder] [int] NULL,
	[AttachmentName] [nvarchar](4000) NULL,
	[PreviousQuestionId] [uniqueidentifier] NULL,
 CONSTRAINT [PK_PAndCSectionQuestions] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Tax].[PAndCSectionQuestions] ADD  DEFAULT ((0)) FOR [IsComment]
GO
ALTER TABLE [Tax].[PAndCSectionQuestions] ADD  DEFAULT ((0)) FOR [IsAttachement]
GO
ALTER TABLE [Tax].[PAndCSectionQuestions] ADD  DEFAULT ((0)) FOR [AttachmentsCount]
GO
ALTER TABLE [Tax].[PAndCSectionQuestions] ADD  DEFAULT ((1)) FOR [Status]
GO
ALTER TABLE [Tax].[PAndCSectionQuestions]  WITH CHECK ADD  CONSTRAINT [FK_PAndCSectionQuestions_PAndCSections] FOREIGN KEY([PAndCSectionId])
REFERENCES [Tax].[PAndCSections] ([Id])
GO
ALTER TABLE [Tax].[PAndCSectionQuestions] CHECK CONSTRAINT [FK_PAndCSectionQuestions_PAndCSections]
GO
