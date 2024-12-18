USE [SmartCursorSTG]
GO
/****** Object:  Table [HR].[LeaveApplicationHistory]    Script Date: 16-12-2024 9.30.57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [HR].[LeaveApplicationHistory](
	[Id] [uniqueidentifier] NOT NULL,
	[StatusChangedEmployeeId] [uniqueidentifier] NOT NULL,
	[LeaveTypeId] [uniqueidentifier] NOT NULL,
	[LeaveApplicationId] [uniqueidentifier] NOT NULL,
	[LeaveStatus] [nvarchar](50) NULL,
	[Remarks] [nvarchar](254) NULL,
	[CreatedDate] [datetime2](7) NULL,
	[StatusChangesUserId] [uniqueidentifier] NULL,
 CONSTRAINT [PK_LeaveApplicationHistory] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [HR].[LeaveApplicationHistory] ADD  DEFAULT (getdate()) FOR [CreatedDate]
GO
ALTER TABLE [HR].[LeaveApplicationHistory]  WITH CHECK ADD  CONSTRAINT [FK_LeaveApplicationHistory_Employee] FOREIGN KEY([StatusChangedEmployeeId])
REFERENCES [Common].[Employee] ([Id])
GO
ALTER TABLE [HR].[LeaveApplicationHistory] CHECK CONSTRAINT [FK_LeaveApplicationHistory_Employee]
GO
ALTER TABLE [HR].[LeaveApplicationHistory]  WITH CHECK ADD  CONSTRAINT [FK_LeaveApplicationHistory_LeaveApplication] FOREIGN KEY([LeaveApplicationId])
REFERENCES [HR].[LeaveApplication] ([Id])
GO
ALTER TABLE [HR].[LeaveApplicationHistory] CHECK CONSTRAINT [FK_LeaveApplicationHistory_LeaveApplication]
GO
ALTER TABLE [HR].[LeaveApplicationHistory]  WITH CHECK ADD  CONSTRAINT [FK_LeaveApplicationHistory_LeaveType] FOREIGN KEY([LeaveTypeId])
REFERENCES [HR].[LeaveType] ([Id])
GO
ALTER TABLE [HR].[LeaveApplicationHistory] CHECK CONSTRAINT [FK_LeaveApplicationHistory_LeaveType]
GO
