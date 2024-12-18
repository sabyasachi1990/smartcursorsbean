USE [SmartCursorSTG]
GO
/****** Object:  Table [HR].[FamilyDetails]    Script Date: 16-12-2024 9.30.57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [HR].[FamilyDetails](
	[Id] [uniqueidentifier] NOT NULL,
	[EmployeeId] [uniqueidentifier] NULL,
	[RelationShip] [nvarchar](100) NULL,
	[Title] [nvarchar](10) NULL,
	[FirstName] [nvarchar](200) NULL,
	[LastName] [nvarchar](100) NULL,
	[Gender] [nvarchar](6) NULL,
	[DateOfBirth] [datetime] NULL,
	[AdditionalInfo] [nvarchar](1000) NULL,
	[Remarks] [nvarchar](256) NULL,
	[UserCreated] [nvarchar](254) NULL,
	[CreatedDate] [datetime2](7) NULL,
	[ModifiedBy] [nvarchar](254) NULL,
	[ModifiedDate] [datetime2](7) NULL,
	[Status] [int] NULL,
	[ContactNo] [nvarchar](20) NULL,
	[Nationality] [nvarchar](30) NULL,
	[IdType] [nvarchar](20) NULL,
	[IdNumber] [nvarchar](20) NULL,
	[IsEmergencyContact] [bit] NULL,
	[NameOfEmployerOrSchool] [nvarchar](254) NULL,
	[Recorder] [int] NULL,
	[IdExpiryDate] [datetime2](7) NULL,
	[IDTypeNew] [nvarchar](50) NULL,
 CONSTRAINT [PK_FamilyDetails] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [HR].[FamilyDetails] ADD  DEFAULT (getdate()) FOR [CreatedDate]
GO
ALTER TABLE [HR].[FamilyDetails] ADD  DEFAULT ((1)) FOR [Status]
GO
ALTER TABLE [HR].[FamilyDetails]  WITH CHECK ADD  CONSTRAINT [FK_FamilyDetails_Employee] FOREIGN KEY([EmployeeId])
REFERENCES [Common].[Employee] ([Id])
GO
ALTER TABLE [HR].[FamilyDetails] CHECK CONSTRAINT [FK_FamilyDetails_Employee]
GO
