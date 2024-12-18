USE [SmartCursorSTG]
GO
/****** Object:  Table [HR].[Training]    Script Date: 16-12-2024 9.30.57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [HR].[Training](
	[Id] [uniqueidentifier] NOT NULL,
	[CompanyId] [bigint] NOT NULL,
	[CourseLibraryId] [uniqueidentifier] NOT NULL,
	[TrainerId] [uniqueidentifier] NULL,
	[CourseFee] [money] NULL,
	[IsInternal] [bit] NULL,
	[Venue] [nvarchar](100) NULL,
	[MinAttendees] [int] NULL,
	[EnrollUsers] [nvarchar](20) NULL,
	[RegistrationStartDate] [datetime2](7) NULL,
	[RegistrationClosingDate] [datetime2](7) NULL,
	[RegistrationReminder] [datetime2](7) NULL,
	[IsAssesmentRequired] [bit] NULL,
	[IsFeedbackRequired] [bit] NULL,
	[TrainingStatus] [nvarchar](20) NULL,
	[StartDate] [datetime2](7) NULL,
	[EndDate] [datetime2](7) NULL,
	[NoOfTrainees] [int] NULL,
	[CreatedDate] [datetime2](7) NULL,
	[Remarks] [nvarchar](256) NULL,
	[UserCreated] [nvarchar](254) NULL,
	[ModifiedDate] [datetime2](7) NULL,
	[ModifiedBy] [nvarchar](254) NULL,
	[RecOrder] [int] NULL,
	[Status] [int] NULL,
	[Version] [smallint] NULL,
	[TrainingNumber] [nvarchar](40) NULL,
	[TrainingMode] [nvarchar](200) NULL,
	[TrainerIds] [nvarchar](max) NULL,
	[TrainerNames] [nvarchar](max) NULL,
	[Totalhours] [nvarchar](20) NULL,
 CONSTRAINT [PK_Training] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [HR].[Training]  WITH CHECK ADD  CONSTRAINT [FK_Training_Company] FOREIGN KEY([CompanyId])
REFERENCES [Common].[Company] ([Id])
GO
ALTER TABLE [HR].[Training] CHECK CONSTRAINT [FK_Training_Company]
GO
ALTER TABLE [HR].[Training]  WITH CHECK ADD  CONSTRAINT [FK_Training_CourseLibrary] FOREIGN KEY([CourseLibraryId])
REFERENCES [HR].[CourseLibrary] ([Id])
GO
ALTER TABLE [HR].[Training] CHECK CONSTRAINT [FK_Training_CourseLibrary]
GO
