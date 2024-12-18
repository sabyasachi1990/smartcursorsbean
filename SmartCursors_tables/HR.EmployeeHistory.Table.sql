USE [SmartCursorSTG]
GO
/****** Object:  Table [HR].[EmployeeHistory]    Script Date: 16-12-2024 9.30.56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [HR].[EmployeeHistory](
	[Id] [uniqueidentifier] NOT NULL,
	[EmployeeId] [uniqueidentifier] NULL,
	[TypeOfEmployment] [nvarchar](20) NULL,
	[Employmentperiod] [nvarchar](20) NULL,
	[StartDate] [datetime2](7) NULL,
	[EndDate] [datetime2](7) NULL,
	[NoticePeriodStart] [datetime2](7) NULL,
	[NoticePeriodEnd] [datetime2](7) NULL,
 CONSTRAINT [PK_EmployeeHistory] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [HR].[EmployeeHistory]  WITH CHECK ADD  CONSTRAINT [PK_EmployeeHistory_Employee] FOREIGN KEY([EmployeeId])
REFERENCES [Common].[Employee] ([Id])
GO
ALTER TABLE [HR].[EmployeeHistory] CHECK CONSTRAINT [PK_EmployeeHistory_Employee]
GO
