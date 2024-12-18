USE [SmartCursorSTG]
GO
/****** Object:  Table [HR].[JobPosting]    Script Date: 16-12-2024 9.30.57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [HR].[JobPosting](
	[Id] [uniqueidentifier] NOT NULL,
	[JobId] [nvarchar](30) NULL,
	[JobTitle] [nvarchar](50) NULL,
	[CompanyId] [bigint] NOT NULL,
	[DepartmentId] [uniqueidentifier] NULL,
	[DesignationId] [uniqueidentifier] NULL,
	[Level] [nvarchar](20) NULL,
	[NumberOfVacancies] [int] NULL,
	[StartDate] [datetime2](7) NULL,
	[EndDate] [datetime2](7) NULL,
	[PostedBy] [nvarchar](1500) NULL,
	[JobStatus] [nvarchar](20) NULL,
	[ApplicationLink] [nvarchar](4000) NULL,
	[Remarks] [nvarchar](max) NULL,
	[RecOrder] [int] NULL,
	[UserCreated] [nvarchar](254) NULL,
	[CreatedDate] [datetime2](7) NULL,
	[ModifiedBy] [nvarchar](254) NULL,
	[ModifiedDate] [datetime2](7) NULL,
	[Version] [smallint] NULL,
	[Status] [int] NULL,
	[ShortLink] [nvarchar](100) NULL,
 CONSTRAINT [PK_JobPosting] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [HR].[JobPosting] ADD  DEFAULT ((1)) FOR [Status]
GO
ALTER TABLE [HR].[JobPosting]  WITH CHECK ADD  CONSTRAINT [FK_JobPosting_Company] FOREIGN KEY([CompanyId])
REFERENCES [Common].[Company] ([Id])
GO
ALTER TABLE [HR].[JobPosting] CHECK CONSTRAINT [FK_JobPosting_Company]
GO
ALTER TABLE [HR].[JobPosting]  WITH CHECK ADD  CONSTRAINT [FK_JobPosting_Department] FOREIGN KEY([DepartmentId])
REFERENCES [Common].[Department] ([Id])
GO
ALTER TABLE [HR].[JobPosting] CHECK CONSTRAINT [FK_JobPosting_Department]
GO
ALTER TABLE [HR].[JobPosting]  WITH CHECK ADD  CONSTRAINT [FK_JobPosting_DepartmentDesignation] FOREIGN KEY([DesignationId])
REFERENCES [Common].[DepartmentDesignation] ([Id])
GO
ALTER TABLE [HR].[JobPosting] CHECK CONSTRAINT [FK_JobPosting_DepartmentDesignation]
GO
