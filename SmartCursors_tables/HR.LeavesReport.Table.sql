USE [SmartCursorSTG]
GO
/****** Object:  Table [HR].[LeavesReport]    Script Date: 16-12-2024 9.30.57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [HR].[LeavesReport](
	[Id] [uniqueidentifier] NOT NULL,
	[LeaveTypeId] [uniqueidentifier] NOT NULL,
	[EmployeeId] [uniqueidentifier] NOT NULL,
	[CompanyId] [bigint] NOT NULL,
	[LeaveEntitlement] [float] NULL,
	[ProratedLeaveEntitlement] [float] NULL,
	[BroughtForward] [float] NULL,
	[ApproveAndTaken] [float] NULL,
	[ApproveAndNotTaken] [float] NULL,
	[Status] [int] NOT NULL,
 CONSTRAINT [PK_LeavesReport] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [HR].[LeavesReport] ADD  DEFAULT ((0)) FOR [Status]
GO
ALTER TABLE [HR].[LeavesReport]  WITH CHECK ADD  CONSTRAINT [FK_LeavesReport_Company] FOREIGN KEY([CompanyId])
REFERENCES [Common].[Company] ([Id])
GO
ALTER TABLE [HR].[LeavesReport] CHECK CONSTRAINT [FK_LeavesReport_Company]
GO
ALTER TABLE [HR].[LeavesReport]  WITH CHECK ADD  CONSTRAINT [FK_LeavesReport_Employee] FOREIGN KEY([EmployeeId])
REFERENCES [Common].[Employee] ([Id])
GO
ALTER TABLE [HR].[LeavesReport] CHECK CONSTRAINT [FK_LeavesReport_Employee]
GO
ALTER TABLE [HR].[LeavesReport]  WITH CHECK ADD  CONSTRAINT [FK_LeavesReport_LeaveType] FOREIGN KEY([LeaveTypeId])
REFERENCES [HR].[LeaveType] ([Id])
GO
ALTER TABLE [HR].[LeavesReport] CHECK CONSTRAINT [FK_LeavesReport_LeaveType]
GO
