USE [SmartCursorSTG]
GO
/****** Object:  Table [HR].[ApplicantHistory]    Script Date: 16-12-2024 9.30.56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [HR].[ApplicantHistory](
	[Id] [uniqueidentifier] NOT NULL,
	[JobPostingId] [uniqueidentifier] NULL,
	[JobApplicationId] [uniqueidentifier] NULL,
	[JobId] [nvarchar](30) NULL,
	[Name] [nvarchar](50) NULL,
	[State] [nvarchar](30) NULL,
	[Date] [datetime2](7) NULL,
	[Remarks] [nvarchar](4000) NULL,
	[EmailAddress] [nvarchar](254) NULL
) ON [PRIMARY]
GO
ALTER TABLE [HR].[ApplicantHistory]  WITH CHECK ADD  CONSTRAINT [FK_ApplicantHistory_JobApplication] FOREIGN KEY([JobApplicationId])
REFERENCES [HR].[JobApplication] ([Id])
GO
ALTER TABLE [HR].[ApplicantHistory] CHECK CONSTRAINT [FK_ApplicantHistory_JobApplication]
GO
