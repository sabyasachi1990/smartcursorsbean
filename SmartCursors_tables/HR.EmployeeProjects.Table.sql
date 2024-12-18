USE [SmartCursorSTG]
GO
/****** Object:  Table [HR].[EmployeeProjects]    Script Date: 16-12-2024 9.30.56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [HR].[EmployeeProjects](
	[Id] [uniqueidentifier] NOT NULL,
	[EmployeeId] [uniqueidentifier] NULL,
	[ProjectId] [uniqueidentifier] NULL,
	[CompanyId] [bigint] NULL,
	[EffectiveDateFrom] [datetime2](7) NULL,
	[EffectiveDateTo] [datetime2](7) NULL,
	[ReportingManagerId] [uniqueidentifier] NULL,
	[Remarks] [nvarchar](256) NULL,
	[UserCreated] [nvarchar](254) NULL,
	[CreatedDate] [datetime2](7) NULL,
	[ModifiedBy] [nvarchar](254) NULL,
	[ModifiedDate] [datetime2](7) NULL,
	[Status] [int] NULL,
 CONSTRAINT [PK_EmployeeProjects] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [HR].[EmployeeProjects] ADD  DEFAULT (getdate()) FOR [CreatedDate]
GO
ALTER TABLE [HR].[EmployeeProjects] ADD  DEFAULT ((1)) FOR [Status]
GO
ALTER TABLE [HR].[EmployeeProjects]  WITH CHECK ADD  CONSTRAINT [FK_EmployeeProjects_Company] FOREIGN KEY([CompanyId])
REFERENCES [Common].[Company] ([Id])
GO
ALTER TABLE [HR].[EmployeeProjects] CHECK CONSTRAINT [FK_EmployeeProjects_Company]
GO
ALTER TABLE [HR].[EmployeeProjects]  WITH CHECK ADD  CONSTRAINT [FK_EmployeeProjects_Employee] FOREIGN KEY([EmployeeId])
REFERENCES [Common].[Employee] ([Id])
GO
ALTER TABLE [HR].[EmployeeProjects] CHECK CONSTRAINT [FK_EmployeeProjects_Employee]
GO
ALTER TABLE [HR].[EmployeeProjects]  WITH CHECK ADD  CONSTRAINT [FK_EmployeeProjects_Project] FOREIGN KEY([ProjectId])
REFERENCES [HR].[Project] ([Id])
GO
ALTER TABLE [HR].[EmployeeProjects] CHECK CONSTRAINT [FK_EmployeeProjects_Project]
GO
