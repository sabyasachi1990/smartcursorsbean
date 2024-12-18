USE [SmartCursorSTG]
GO
/****** Object:  Table [WorkFlow].[CasesAssigned]    Script Date: 16-12-2024 9.30.57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [WorkFlow].[CasesAssigned](
	[Id] [uniqueidentifier] NOT NULL,
	[CompanyId] [uniqueidentifier] NOT NULL,
	[CaseId] [uniqueidentifier] NOT NULL,
	[EmployeeId] [uniqueidentifier] NOT NULL,
	[FromDate] [datetime2](7) NULL,
	[ToDate] [datetime2](7) NULL,
	[NumberOfHours] [bigint] NOT NULL,
 CONSTRAINT [PK_CasesAssigned] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [WorkFlow].[CasesAssigned]  WITH CHECK ADD  CONSTRAINT [FK_CasesAssigned_CaseGroup] FOREIGN KEY([CaseId])
REFERENCES [WorkFlow].[CaseGroup] ([Id])
GO
ALTER TABLE [WorkFlow].[CasesAssigned] CHECK CONSTRAINT [FK_CasesAssigned_CaseGroup]
GO
ALTER TABLE [WorkFlow].[CasesAssigned]  WITH CHECK ADD  CONSTRAINT [PK_CasesAssigned_Employee] FOREIGN KEY([EmployeeId])
REFERENCES [Common].[Employee] ([Id])
GO
ALTER TABLE [WorkFlow].[CasesAssigned] CHECK CONSTRAINT [PK_CasesAssigned_Employee]
GO
