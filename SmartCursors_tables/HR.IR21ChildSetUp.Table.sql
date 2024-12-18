USE [SmartCursorSTG]
GO
/****** Object:  Table [HR].[IR21ChildSetUp]    Script Date: 16-12-2024 9.30.57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [HR].[IR21ChildSetUp](
	[id] [uniqueidentifier] NOT NULL,
	[Ir8aHrSetUpId] [uniqueidentifier] NULL,
	[CompanyId] [bigint] NULL,
	[ParentCompanyId] [bigint] NULL,
	[NameOfChild] [nvarchar](250) NULL,
	[Gender] [nvarchar](250) NULL,
	[ChildDateOfBirth] [datetime2](7) NULL,
	[NameOfSchoolState] [nvarchar](250) NULL,
	[UserCreated] [nvarchar](200) NULL,
	[ModifiedBy] [nvarchar](200) NULL,
	[ModifiedDate] [datetime2](7) NULL,
	[CreatedDate] [datetime2](7) NULL,
	[Recorder] [int] NULL,
	[Status] [int] NULL,
 CONSTRAINT [PK_IR21ChildSetUp] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [HR].[IR21ChildSetUp]  WITH CHECK ADD  CONSTRAINT [FK_IR21ChildSetUp_Ir8aHrSetUp] FOREIGN KEY([Ir8aHrSetUpId])
REFERENCES [HR].[IR8AHRSetUp] ([Id])
GO
ALTER TABLE [HR].[IR21ChildSetUp] CHECK CONSTRAINT [FK_IR21ChildSetUp_Ir8aHrSetUp]
GO
