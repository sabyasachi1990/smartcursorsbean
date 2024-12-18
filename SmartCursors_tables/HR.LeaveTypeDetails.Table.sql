USE [SmartCursorSTG]
GO
/****** Object:  Table [HR].[LeaveTypeDetails]    Script Date: 16-12-2024 9.30.57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [HR].[LeaveTypeDetails](
	[Id] [uniqueidentifier] NOT NULL,
	[LeaveTypeId] [uniqueidentifier] NOT NULL,
	[DepartmentId] [uniqueidentifier] NULL,
	[DesignationId] [uniqueidentifier] NULL,
	[Level] [nvarchar](50) NULL,
	[EmployeeId] [uniqueidentifier] NULL,
	[Status] [int] NULL,
	[CarryForwardDays] [float] NULL,
	[Entitlement] [float] NULL,
 CONSTRAINT [PK_LeaveTypeDetails] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [HR].[LeaveTypeDetails]  WITH CHECK ADD  CONSTRAINT [FK_LeaveTypeDetails_Department] FOREIGN KEY([DepartmentId])
REFERENCES [Common].[Department] ([Id])
GO
ALTER TABLE [HR].[LeaveTypeDetails] CHECK CONSTRAINT [FK_LeaveTypeDetails_Department]
GO
ALTER TABLE [HR].[LeaveTypeDetails]  WITH CHECK ADD  CONSTRAINT [FK_LeaveTypeDetails_DepartmentDesignation] FOREIGN KEY([DesignationId])
REFERENCES [Common].[DepartmentDesignation] ([Id])
GO
ALTER TABLE [HR].[LeaveTypeDetails] CHECK CONSTRAINT [FK_LeaveTypeDetails_DepartmentDesignation]
GO
ALTER TABLE [HR].[LeaveTypeDetails]  WITH CHECK ADD  CONSTRAINT [FK_LeaveTypeDetails_Employee] FOREIGN KEY([EmployeeId])
REFERENCES [Common].[Employee] ([Id])
GO
ALTER TABLE [HR].[LeaveTypeDetails] CHECK CONSTRAINT [FK_LeaveTypeDetails_Employee]
GO
ALTER TABLE [HR].[LeaveTypeDetails]  WITH CHECK ADD  CONSTRAINT [FK_LeaveTypeDetails_LeaveType] FOREIGN KEY([LeaveTypeId])
REFERENCES [HR].[LeaveType] ([Id])
GO
ALTER TABLE [HR].[LeaveTypeDetails] CHECK CONSTRAINT [FK_LeaveTypeDetails_LeaveType]
GO
