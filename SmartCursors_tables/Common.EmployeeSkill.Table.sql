USE [SmartCursorSTG]
GO
/****** Object:  Table [Common].[EmployeeSkill]    Script Date: 16-12-2024 9.30.56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Common].[EmployeeSkill](
	[Id] [uniqueidentifier] NOT NULL,
	[EmployeeId] [uniqueidentifier] NOT NULL,
	[YearsOfExperiance] [float] NULL,
	[ServiceGroupId] [bigint] NOT NULL,
 CONSTRAINT [PK_EmployeeSkill] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Common].[EmployeeSkill]  WITH CHECK ADD  CONSTRAINT [FK_EmployeeSkill_Employee] FOREIGN KEY([EmployeeId])
REFERENCES [Common].[Employee] ([Id])
GO
ALTER TABLE [Common].[EmployeeSkill] CHECK CONSTRAINT [FK_EmployeeSkill_Employee]
GO
ALTER TABLE [Common].[EmployeeSkill]  WITH CHECK ADD  CONSTRAINT [FK_EmployeeSkill_ServiceGroup] FOREIGN KEY([ServiceGroupId])
REFERENCES [Common].[ServiceGroup] ([Id])
GO
ALTER TABLE [Common].[EmployeeSkill] CHECK CONSTRAINT [FK_EmployeeSkill_ServiceGroup]
GO
