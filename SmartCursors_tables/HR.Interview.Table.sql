USE [SmartCursorSTG]
GO
/****** Object:  Table [HR].[Interview]    Script Date: 16-12-2024 9.30.57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [HR].[Interview](
	[Id] [uniqueidentifier] NOT NULL,
	[ApplicationId] [uniqueidentifier] NOT NULL,
	[InterviewDate] [nvarchar](50) NULL,
	[IntendedInterviewer] [nvarchar](500) NULL,
	[ActualInterviewer] [nvarchar](500) NULL,
	[RecOrder] [int] NULL,
	[UserCreated] [nvarchar](254) NULL,
	[CreatedDate] [datetime2](7) NULL,
	[ModifiedBy] [nvarchar](254) NULL,
	[ModifiedDate] [datetime2](7) NULL,
	[Status] [int] NULL,
	[IntendedInterviewers] [nvarchar](500) NULL,
	[ActualInterviewers] [nvarchar](500) NULL,
 CONSTRAINT [PK_Interview] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [HR].[Interview] ADD  DEFAULT ((1)) FOR [Status]
GO
ALTER TABLE [HR].[Interview]  WITH CHECK ADD  CONSTRAINT [FK_Interview_JobApplication] FOREIGN KEY([ApplicationId])
REFERENCES [HR].[JobApplication] ([Id])
GO
ALTER TABLE [HR].[Interview] CHECK CONSTRAINT [FK_Interview_JobApplication]
GO
