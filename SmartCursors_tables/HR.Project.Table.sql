USE [SmartCursorSTG]
GO
/****** Object:  Table [HR].[Project]    Script Date: 16-12-2024 9.30.57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [HR].[Project](
	[Id] [uniqueidentifier] NOT NULL,
	[ShortCode] [nvarchar](20) NULL,
	[Name] [nvarchar](100) NULL,
	[ManagerId] [uniqueidentifier] NULL,
	[Description] [nvarchar](1000) NULL,
	[StartDate] [datetime2](7) NULL,
	[EndDate] [datetime2](7) NULL,
	[ProjectStatus] [int] NULL,
	[CompanyId] [bigint] NULL,
	[Remarks] [nvarchar](256) NULL,
	[UserCreated] [nvarchar](254) NULL,
	[CreatedDate] [datetime2](7) NULL,
	[ModifiedBy] [nvarchar](254) NULL,
	[ModifiedDate] [datetime2](7) NULL,
	[Status] [int] NULL,
 CONSTRAINT [PK_Project] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [HR].[Project] ADD  DEFAULT (getdate()) FOR [CreatedDate]
GO
ALTER TABLE [HR].[Project] ADD  DEFAULT ((1)) FOR [Status]
GO
ALTER TABLE [HR].[Project]  WITH CHECK ADD  CONSTRAINT [FK_Project_Company] FOREIGN KEY([CompanyId])
REFERENCES [Common].[Company] ([Id])
GO
ALTER TABLE [HR].[Project] CHECK CONSTRAINT [FK_Project_Company]
GO
ALTER TABLE [HR].[Project]  WITH CHECK ADD  CONSTRAINT [FK_Project_Employee] FOREIGN KEY([ManagerId])
REFERENCES [Common].[Employee] ([Id])
GO
ALTER TABLE [HR].[Project] CHECK CONSTRAINT [FK_Project_Employee]
GO
