USE [SmartCursorSTG]
GO
/****** Object:  Table [Common].[CalenderDetails]    Script Date: 16-12-2024 9.30.56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Common].[CalenderDetails](
	[Id] [uniqueidentifier] NOT NULL,
	[MasterId] [uniqueidentifier] NOT NULL,
	[DepartmentId] [uniqueidentifier] NULL,
	[DesignationId] [uniqueidentifier] NULL,
	[Level] [nvarchar](50) NULL,
	[EmployeeId] [uniqueidentifier] NOT NULL,
	[Status] [int] NULL,
 CONSTRAINT [PK_EmployeeDepartment] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Common].[CalenderDetails] ADD  DEFAULT ((1)) FOR [Status]
GO
ALTER TABLE [Common].[CalenderDetails]  WITH CHECK ADD  CONSTRAINT [FK_EmployeeDepartment_Calender] FOREIGN KEY([MasterId])
REFERENCES [Common].[Calender] ([Id])
GO
ALTER TABLE [Common].[CalenderDetails] CHECK CONSTRAINT [FK_EmployeeDepartment_Calender]
GO
ALTER TABLE [Common].[CalenderDetails]  WITH CHECK ADD  CONSTRAINT [FK_EmployeeDepartment_Department] FOREIGN KEY([DepartmentId])
REFERENCES [Common].[Department] ([Id])
GO
ALTER TABLE [Common].[CalenderDetails] CHECK CONSTRAINT [FK_EmployeeDepartment_Department]
GO
ALTER TABLE [Common].[CalenderDetails]  WITH CHECK ADD  CONSTRAINT [FK_EmployeeDepartment_DepartmentDesignation] FOREIGN KEY([DesignationId])
REFERENCES [Common].[DepartmentDesignation] ([Id])
GO
ALTER TABLE [Common].[CalenderDetails] CHECK CONSTRAINT [FK_EmployeeDepartment_DepartmentDesignation]
GO
ALTER TABLE [Common].[CalenderDetails]  WITH CHECK ADD  CONSTRAINT [FK_EmployeeDepartment_Employee] FOREIGN KEY([EmployeeId])
REFERENCES [Common].[Employee] ([Id])
GO
ALTER TABLE [Common].[CalenderDetails] CHECK CONSTRAINT [FK_EmployeeDepartment_Employee]
GO
