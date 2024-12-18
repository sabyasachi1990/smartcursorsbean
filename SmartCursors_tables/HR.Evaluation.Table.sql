USE [SmartCursorSTG]
GO
/****** Object:  Table [HR].[Evaluation]    Script Date: 16-12-2024 9.30.57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [HR].[Evaluation](
	[Id] [uniqueidentifier] NOT NULL,
	[InterviewId] [uniqueidentifier] NOT NULL,
	[ApplicationId] [uniqueidentifier] NOT NULL,
	[EmployeeId] [uniqueidentifier] NULL,
	[EvalutionId] [uniqueidentifier] NULL,
	[Value] [nvarchar](1000) NULL,
	[UserCreated] [nvarchar](254) NULL,
	[CreatedDate] [datetime2](7) NULL,
	[ModifiedBy] [nvarchar](254) NULL,
	[ModifiedDate] [datetime2](7) NULL,
	[Status] [int] NULL,
	[CompanyUserId] [bigint] NULL,
	[Question] [nvarchar](1000) NULL,
	[RecOrder] [int] NULL,
	[ControlCodeid] [bigint] NULL,
	[IsSystem] [bit] NULL,
 CONSTRAINT [PK_Evaluation] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [HR].[Evaluation] ADD  DEFAULT ((1)) FOR [Status]
GO
ALTER TABLE [HR].[Evaluation]  WITH CHECK ADD  CONSTRAINT [FK_Evaluation_CompanyUser] FOREIGN KEY([CompanyUserId])
REFERENCES [Common].[CompanyUser] ([Id])
GO
ALTER TABLE [HR].[Evaluation] CHECK CONSTRAINT [FK_Evaluation_CompanyUser]
GO
ALTER TABLE [HR].[Evaluation]  WITH CHECK ADD  CONSTRAINT [FK_Evaluation_Employee] FOREIGN KEY([EmployeeId])
REFERENCES [Common].[Employee] ([Id])
GO
ALTER TABLE [HR].[Evaluation] CHECK CONSTRAINT [FK_Evaluation_Employee]
GO
ALTER TABLE [HR].[Evaluation]  WITH CHECK ADD  CONSTRAINT [FK_Evaluation_EvaluationDetails] FOREIGN KEY([EvalutionId])
REFERENCES [HR].[EvaluationDetails] ([Id])
GO
ALTER TABLE [HR].[Evaluation] CHECK CONSTRAINT [FK_Evaluation_EvaluationDetails]
GO
ALTER TABLE [HR].[Evaluation]  WITH CHECK ADD  CONSTRAINT [FK_Evaluation_Interview] FOREIGN KEY([InterviewId])
REFERENCES [HR].[Interview] ([Id])
GO
ALTER TABLE [HR].[Evaluation] CHECK CONSTRAINT [FK_Evaluation_Interview]
GO
ALTER TABLE [HR].[Evaluation]  WITH CHECK ADD  CONSTRAINT [FK_Evaluation_JobApplication] FOREIGN KEY([ApplicationId])
REFERENCES [HR].[JobApplication] ([Id])
GO
ALTER TABLE [HR].[Evaluation] CHECK CONSTRAINT [FK_Evaluation_JobApplication]
GO
