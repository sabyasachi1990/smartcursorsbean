USE [SmartCursorSTG]
GO
/****** Object:  Table [HR].[LeaveSetupEmployees]    Script Date: 16-12-2024 9.30.57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [HR].[LeaveSetupEmployees](
	[Id] [uniqueidentifier] NOT NULL,
	[LeaveSetupId] [uniqueidentifier] NOT NULL,
	[LeaveStatusChangedEmployeeId] [uniqueidentifier] NOT NULL,
	[Status] [int] NULL,
 CONSTRAINT [PK_LeaveSetupEmployees] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [HR].[LeaveSetupEmployees] ADD  DEFAULT ((1)) FOR [Status]
GO
ALTER TABLE [HR].[LeaveSetupEmployees]  WITH CHECK ADD  CONSTRAINT [FK_LeaveSetupEmployees_Employee] FOREIGN KEY([LeaveStatusChangedEmployeeId])
REFERENCES [Common].[Employee] ([Id])
GO
ALTER TABLE [HR].[LeaveSetupEmployees] CHECK CONSTRAINT [FK_LeaveSetupEmployees_Employee]
GO
