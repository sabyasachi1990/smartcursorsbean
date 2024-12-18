USE [SmartCursorSTG]
GO
/****** Object:  Table [HR].[LeaveRuleEngine]    Script Date: 16-12-2024 9.30.57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [HR].[LeaveRuleEngine](
	[Id] [uniqueidentifier] NOT NULL,
	[LeaveTypeId] [uniqueidentifier] NOT NULL,
	[Condition] [nvarchar](100) NULL,
	[Value] [nvarchar](100) NULL,
	[NoOfDays] [float] NULL,
	[EmpCount] [int] NULL,
	[MaxLimit] [float] NULL,
 CONSTRAINT [PK_LeaveRuleEngine] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [HR].[LeaveRuleEngine]  WITH CHECK ADD  CONSTRAINT [FK_LeaveRuleEngine_LeaveType] FOREIGN KEY([LeaveTypeId])
REFERENCES [HR].[LeaveType] ([Id])
GO
ALTER TABLE [HR].[LeaveRuleEngine] CHECK CONSTRAINT [FK_LeaveRuleEngine_LeaveType]
GO
