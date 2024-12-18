USE [SmartCursorSTG]
GO
/****** Object:  Table [HR].[JobApplication]    Script Date: 16-12-2024 9.30.57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [HR].[JobApplication](
	[Id] [uniqueidentifier] NOT NULL,
	[JobPostingId] [uniqueidentifier] NOT NULL,
	[JobId] [nvarchar](30) NULL,
	[JobTitle] [nvarchar](50) NULL,
	[CompanyId] [bigint] NOT NULL,
	[Name] [nvarchar](50) NULL,
	[ChineseCharacters] [nvarchar](254) NULL,
	[Address] [nvarchar](254) NULL,
	[EmailAddress] [nvarchar](254) NULL,
	[MobileNumber] [nvarchar](max) NULL,
	[HomeNumber] [nvarchar](100) NULL,
	[ExpectedSalary] [decimal](17, 2) NULL,
	[LastDrawn] [decimal](17, 2) NULL,
	[AvailableDate] [datetime2](7) NULL,
	[Nationality] [nvarchar](30) NULL,
	[IDType] [nvarchar](100) NULL,
	[IDNumber] [nvarchar](20) NULL,
	[DateOfBirth] [datetime2](7) NULL,
	[Gender] [nvarchar](8) NULL,
	[MaritalStatus] [nvarchar](20) NULL,
	[Race] [nvarchar](20) NULL,
	[Dialect] [nvarchar](100) NULL,
	[LanguagesSpoken] [nvarchar](300) NULL,
	[LanguagesWritten] [nvarchar](300) NULL,
	[ComputerSkills] [nvarchar](300) NULL,
	[ApplicationStatus] [nvarchar](30) NULL,
	[ReferenceCheck] [nvarchar](500) NULL,
	[SalaryDetails] [decimal](17, 2) NULL,
	[Source] [nvarchar](50) NULL,
	[ApplicationLink] [nvarchar](4000) NULL,
	[EmployeeId] [uniqueidentifier] NULL,
	[RecOrder] [int] NULL,
	[Remarks] [nvarchar](4000) NULL,
	[UserCreated] [nvarchar](254) NULL,
	[CreatedDate] [datetime2](7) NULL,
	[ModifiedBy] [nvarchar](254) NULL,
	[ModifiedDate] [datetime2](7) NULL,
	[Version] [smallint] NULL,
	[Status] [int] NULL,
	[InterviewUserCreated] [nvarchar](200) NULL,
	[InterviewCreatedDate] [datetime2](7) NULL,
	[InterviewModifiedBy] [nvarchar](200) NULL,
	[InterviewModifiedDate] [datetime2](7) NULL,
	[JobApplicationId] [nvarchar](40) NULL,
	[PhotoId] [uniqueidentifier] NULL,
	[Currency] [nvarchar](500) NULL,
	[LastDrawnCurrency] [nvarchar](500) NULL,
	[VoluntaryInternship] [bit] NULL,
	[PermanentInternship] [bit] NULL,
	[AvailabilityStartDate] [datetime2](7) NULL,
	[AvailabilityEndDate] [datetime2](7) NULL,
	[NoBankrupt] [bit] NULL,
	[NoCriminalRecord] [bit] NULL,
	[NoCourtCase] [bit] NULL,
	[NotBeenCharged] [bit] NULL,
	[NoInInvestigation] [bit] NULL,
	[WorkPassType] [nvarchar](100) NULL,
	[WorkPassNumber] [nvarchar](20) NULL,
	[WorkPassDateofApplication] [datetime2](7) NULL,
	[WorkPassDateofIssue] [datetime2](7) NULL,
	[WorkPassDateofExpiry] [datetime2](7) NULL,
	[DateOfSPRGranted] [datetime2](7) NULL,
	[Communication] [nvarchar](1000) NULL,
	[DateOfSPRExpiry] [datetime2](7) NULL,
	[PassportExpiry] [datetime2](7) NULL,
	[PassportNumber] [nvarchar](50) NULL,
	[SupplimentoryFormLink] [nvarchar](max) NULL,
	[NoEmploymentFirm] [bit] NULL,
	[NoEmploymentKnowledge] [bit] NULL,
	[NoEmploymentDismissal] [bit] NULL,
 CONSTRAINT [PK_JobApplication] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [HR].[JobApplication] ADD  DEFAULT ((1)) FOR [Status]
GO
ALTER TABLE [HR].[JobApplication]  WITH CHECK ADD  CONSTRAINT [FK_JobApplication_Company] FOREIGN KEY([CompanyId])
REFERENCES [Common].[Company] ([Id])
GO
ALTER TABLE [HR].[JobApplication] CHECK CONSTRAINT [FK_JobApplication_Company]
GO
ALTER TABLE [HR].[JobApplication]  WITH CHECK ADD  CONSTRAINT [FK_JobApplication_JobPosting] FOREIGN KEY([JobPostingId])
REFERENCES [HR].[JobPosting] ([Id])
GO
ALTER TABLE [HR].[JobApplication] CHECK CONSTRAINT [FK_JobApplication_JobPosting]
GO
