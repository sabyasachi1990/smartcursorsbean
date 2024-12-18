USE [SmartCursorSTG]
GO
/****** Object:  Table [ClientCursor].[EstimatedTimeCostQuestionnaire_ToBeDeleted]    Script Date: 16-12-2024 9.30.56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [ClientCursor].[EstimatedTimeCostQuestionnaire_ToBeDeleted](
	[Id] [uniqueidentifier] NOT NULL,
	[QuestionaireType] [nvarchar](20) NOT NULL,
	[Question] [nvarchar](2000) NOT NULL,
	[QuestionType] [nvarchar](20) NOT NULL,
	[YesValue] [decimal](18, 0) NULL,
	[NoValue] [decimal](18, 0) NULL,
	[Value] [decimal](18, 0) NULL,
	[CompanyId] [bigint] NOT NULL,
	[UserCreated] [nvarchar](254) NULL,
	[CreatedDate] [datetime2](7) NULL,
	[ModifiedBy] [nvarchar](254) NULL,
	[ModifiedDate] [datetime2](7) NULL,
	[Status] [int] NULL,
 CONSTRAINT [PK_EstimatedTimeCostQuestionnaire] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [ClientCursor].[EstimatedTimeCostQuestionnaire_ToBeDeleted] ADD  DEFAULT ((1)) FOR [Status]
GO
ALTER TABLE [ClientCursor].[EstimatedTimeCostQuestionnaire_ToBeDeleted]  WITH CHECK ADD  CONSTRAINT [FK_EstimatedTimeCostQuestionnaire_Company] FOREIGN KEY([CompanyId])
REFERENCES [Common].[Company] ([Id])
GO
ALTER TABLE [ClientCursor].[EstimatedTimeCostQuestionnaire_ToBeDeleted] CHECK CONSTRAINT [FK_EstimatedTimeCostQuestionnaire_Company]
GO
