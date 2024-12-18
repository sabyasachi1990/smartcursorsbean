USE [SmartCursorSTG]
GO
/****** Object:  Table [HR].[EmployeeDepartment]    Script Date: 16-12-2024 9.30.56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [HR].[EmployeeDepartment](
	[Id] [uniqueidentifier] NOT NULL,
	[EmployeeId] [uniqueidentifier] NOT NULL,
	[DepartmentId] [uniqueidentifier] NOT NULL,
	[DepartmentDesignationId] [uniqueidentifier] NOT NULL,
	[Comments] [nvarchar](1000) NULL,
	[EffectiveFrom] [datetime2](7) NOT NULL,
	[IsActive] [int] NULL,
	[ReportingManagerId] [uniqueidentifier] NULL,
	[Currency] [nvarchar](5) NULL,
	[BasicPay] [decimal](10, 2) NULL,
	[BasicPayInPercentage] [decimal](10, 2) NULL,
	[ChargeOutRate] [nvarchar](256) NULL,
	[EndDate] [datetime2](7) NULL,
	[Level] [nvarchar](20) NULL,
	[LevelRank] [int] NULL,
	[Remarks] [nvarchar](256) NULL,
	[RecOrder] [int] NULL,
	[UserCreated] [nvarchar](254) NULL,
	[CreatedDate] [datetime2](7) NULL,
	[ModifiedBy] [nvarchar](254) NULL,
	[ModifiedDate] [datetime2](7) NULL,
	[Status] [int] NULL,
	[EffectiveTo] [datetime2](7) NULL,
	[CompanyId] [bigint] NULL,
	[IsLocked] [bit] NULL,
	[IsPayrollRun] [bit] NULL,
	[IsWFCaseScheduled] [bit] NULL,
	[IsRejoined] [bit] NULL,
 CONSTRAINT [PK_EmployeeDepartment] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [HR].[EmployeeDepartment] ADD  DEFAULT (getdate()) FOR [CreatedDate]
GO
ALTER TABLE [HR].[EmployeeDepartment] ADD  DEFAULT ((1)) FOR [Status]
GO
ALTER TABLE [HR].[EmployeeDepartment]  WITH CHECK ADD  CONSTRAINT [FK_EmployeeDepartment_Company] FOREIGN KEY([CompanyId])
REFERENCES [Common].[Company] ([Id])
GO
ALTER TABLE [HR].[EmployeeDepartment] CHECK CONSTRAINT [FK_EmployeeDepartment_Company]
GO
ALTER TABLE [HR].[EmployeeDepartment]  WITH CHECK ADD  CONSTRAINT [FK_EmployeeDepartment_DepartmentDesignationId] FOREIGN KEY([DepartmentDesignationId])
REFERENCES [Common].[DepartmentDesignation] ([Id])
GO
ALTER TABLE [HR].[EmployeeDepartment] CHECK CONSTRAINT [FK_EmployeeDepartment_DepartmentDesignationId]
GO
ALTER TABLE [HR].[EmployeeDepartment]  WITH CHECK ADD  CONSTRAINT [FK_EmployeeDepartment_DepartmentId] FOREIGN KEY([DepartmentId])
REFERENCES [Common].[Department] ([Id])
GO
ALTER TABLE [HR].[EmployeeDepartment] CHECK CONSTRAINT [FK_EmployeeDepartment_DepartmentId]
GO
ALTER TABLE [HR].[EmployeeDepartment]  WITH CHECK ADD  CONSTRAINT [FK_EmployeeDepartment_EmployeeId] FOREIGN KEY([EmployeeId])
REFERENCES [Common].[Employee] ([Id])
GO
ALTER TABLE [HR].[EmployeeDepartment] CHECK CONSTRAINT [FK_EmployeeDepartment_EmployeeId]
GO
