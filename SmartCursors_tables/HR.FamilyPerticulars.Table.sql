USE [SmartCursorSTG]
GO
/****** Object:  Table [HR].[FamilyPerticulars]    Script Date: 16-12-2024 9.30.57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [HR].[FamilyPerticulars](
	[Id] [uniqueidentifier] NOT NULL,
	[ApplicationId] [uniqueidentifier] NOT NULL,
	[Name] [nvarchar](50) NULL,
	[Relation] [nvarchar](50) NULL,
	[DateOfBirth] [datetime2](7) NULL,
	[Age] [int] NULL,
	[Occupation] [nvarchar](30) NULL,
	[CompanyName] [nvarchar](100) NULL,
	[CreatedDate] [datetime2](7) NULL,
	[Recorder] [int] NULL,
 CONSTRAINT [PK_FamilyPerticulars] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [HR].[FamilyPerticulars]  WITH CHECK ADD  CONSTRAINT [FK_FamilyPerticulars_JobApplication] FOREIGN KEY([ApplicationId])
REFERENCES [HR].[JobApplication] ([Id])
GO
ALTER TABLE [HR].[FamilyPerticulars] CHECK CONSTRAINT [FK_FamilyPerticulars_JobApplication]
GO
