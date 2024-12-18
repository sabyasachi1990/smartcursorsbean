USE [SmartCursorSTG]
GO
/****** Object:  Table [HR].[EmployeRecandApprovers]    Script Date: 16-12-2024 9.30.56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [HR].[EmployeRecandApprovers](
	[Id] [uniqueidentifier] NOT NULL,
	[EmployeeId] [uniqueidentifier] NULL,
	[Type] [nvarchar](100) NULL,
	[TypeId] [bigint] NULL,
	[ScreenName] [nvarchar](100) NULL,
	[CategoryName] [nvarchar](200) NULL,
	[HrSettingId] [uniqueidentifier] NULL,
 CONSTRAINT [PK_EmployeRecandApprovers] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [HR].[EmployeRecandApprovers]  WITH CHECK ADD  CONSTRAINT [FK_EmployeRecandApprovers_CompanyUser] FOREIGN KEY([TypeId])
REFERENCES [Common].[CompanyUser] ([Id])
GO
ALTER TABLE [HR].[EmployeRecandApprovers] CHECK CONSTRAINT [FK_EmployeRecandApprovers_CompanyUser]
GO
ALTER TABLE [HR].[EmployeRecandApprovers]  WITH CHECK ADD  CONSTRAINT [FK_EmployeRecandApprovers_Employee] FOREIGN KEY([EmployeeId])
REFERENCES [Common].[Employee] ([Id])
GO
ALTER TABLE [HR].[EmployeRecandApprovers] CHECK CONSTRAINT [FK_EmployeRecandApprovers_Employee]
GO
