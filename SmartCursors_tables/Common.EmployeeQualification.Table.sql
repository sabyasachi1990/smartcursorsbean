USE [SmartCursorSTG]
GO
/****** Object:  Table [Common].[EmployeeQualification]    Script Date: 16-12-2024 9.30.56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Common].[EmployeeQualification](
	[Id] [uniqueidentifier] NOT NULL,
	[EmployeeId] [uniqueidentifier] NOT NULL,
	[Qualification] [nvarchar](100) NULL,
	[Rate] [money] NULL,
 CONSTRAINT [PK_EmployeeQualification] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Common].[EmployeeQualification]  WITH CHECK ADD  CONSTRAINT [FK_EmployeeQualification_Employee] FOREIGN KEY([EmployeeId])
REFERENCES [Common].[Employee] ([Id])
GO
ALTER TABLE [Common].[EmployeeQualification] CHECK CONSTRAINT [FK_EmployeeQualification_Employee]
GO
