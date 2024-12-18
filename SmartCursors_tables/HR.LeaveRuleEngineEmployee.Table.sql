USE [SmartCursorSTG]
GO
/****** Object:  Table [HR].[LeaveRuleEngineEmployee]    Script Date: 16-12-2024 9.30.57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [HR].[LeaveRuleEngineEmployee](
	[Id] [uniqueidentifier] NOT NULL,
	[EmployeeId] [uniqueidentifier] NOT NULL,
	[LeaveRuleEngineId] [uniqueidentifier] NOT NULL,
	[NoOfDays] [float] NULL,
 CONSTRAINT [PK_LeaveRuleEngineEmployee] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [HR].[LeaveRuleEngineEmployee]  WITH CHECK ADD  CONSTRAINT [FK_LeaveRuleEngineEmployee_Employee] FOREIGN KEY([EmployeeId])
REFERENCES [Common].[Employee] ([Id])
GO
ALTER TABLE [HR].[LeaveRuleEngineEmployee] CHECK CONSTRAINT [FK_LeaveRuleEngineEmployee_Employee]
GO
ALTER TABLE [HR].[LeaveRuleEngineEmployee]  WITH CHECK ADD  CONSTRAINT [FK_LeaveRuleEngineEmployee_LeaveRuleEngine] FOREIGN KEY([LeaveRuleEngineId])
REFERENCES [HR].[LeaveRuleEngine] ([Id])
GO
ALTER TABLE [HR].[LeaveRuleEngineEmployee] CHECK CONSTRAINT [FK_LeaveRuleEngineEmployee_LeaveRuleEngine]
GO
