USE [SmartCursorSTG]
GO
/****** Object:  Table [HR].[Education]    Script Date: 16-12-2024 9.30.56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [HR].[Education](
	[Id] [uniqueidentifier] NOT NULL,
	[ApplicationId] [uniqueidentifier] NOT NULL,
	[EducationLevel] [nvarchar](2000) NULL,
	[Qualification] [nvarchar](254) NULL,
	[Institution] [nvarchar](254) NULL,
	[StartDate] [datetime2](7) NULL,
	[EndDate] [datetime2](7) NULL,
	[RecOrder] [int] NULL,
	[CreatedDate] [datetime2](7) NULL,
	[Remarks] [nvarchar](2000) NULL,
	[IsOtherQualification] [bit] NULL,
	[IsScholarship] [bit] NULL,
	[IsCurrentlyStudying] [bit] NULL,
 CONSTRAINT [PK_Education] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [HR].[Education]  WITH CHECK ADD  CONSTRAINT [FK_Education_JobApplication] FOREIGN KEY([ApplicationId])
REFERENCES [HR].[JobApplication] ([Id])
GO
ALTER TABLE [HR].[Education] CHECK CONSTRAINT [FK_Education_JobApplication]
GO
