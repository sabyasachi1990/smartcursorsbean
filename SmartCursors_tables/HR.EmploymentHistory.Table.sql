USE [SmartCursorSTG]
GO
/****** Object:  Table [HR].[EmploymentHistory]    Script Date: 16-12-2024 9.30.57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [HR].[EmploymentHistory](
	[Id] [uniqueidentifier] NOT NULL,
	[ApplicationId] [uniqueidentifier] NOT NULL,
	[FromDate] [datetime2](7) NULL,
	[ToDate] [datetime2](7) NULL,
	[Company] [nvarchar](100) NULL,
	[Salary] [nvarchar](50) NULL,
	[ReasonForLeaving] [nvarchar](500) NULL,
	[CreatedDate] [datetime2](7) NULL,
	[Recorder] [int] NULL,
	[Currency] [nvarchar](500) NULL,
	[NatureOfBusiness] [nvarchar](2000) NULL,
	[Designation] [nvarchar](2000) NULL,
	[StartingSalary] [nvarchar](100) NULL,
	[IsNationalService] [bit] NULL,
	[ExpectedCalledUpto] [nvarchar](100) NULL,
	[ExemptedAccountOf] [nvarchar](100) NULL,
	[ServiceStatus] [nvarchar](100) NULL,
 CONSTRAINT [PK_EmploymentHistory] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [HR].[EmploymentHistory]  WITH CHECK ADD  CONSTRAINT [FK_EmploymentHistory_JobApplication] FOREIGN KEY([ApplicationId])
REFERENCES [HR].[JobApplication] ([Id])
GO
ALTER TABLE [HR].[EmploymentHistory] CHECK CONSTRAINT [FK_EmploymentHistory_JobApplication]
GO
