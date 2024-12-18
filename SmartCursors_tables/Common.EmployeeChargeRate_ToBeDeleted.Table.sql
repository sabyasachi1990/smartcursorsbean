USE [SmartCursorSTG]
GO
/****** Object:  Table [Common].[EmployeeChargeRate_ToBeDeleted]    Script Date: 16-12-2024 9.30.56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Common].[EmployeeChargeRate_ToBeDeleted](
	[Id] [uniqueidentifier] NOT NULL,
	[EmployeeId] [uniqueidentifier] NOT NULL,
	[Designation] [nvarchar](100) NULL,
	[Rate] [money] NULL,
 CONSTRAINT [PK_EmployeeChargeRate] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Common].[EmployeeChargeRate_ToBeDeleted]  WITH CHECK ADD  CONSTRAINT [FK_EmployeeChargeRate_Employee] FOREIGN KEY([EmployeeId])
REFERENCES [Common].[Employee] ([Id])
GO
ALTER TABLE [Common].[EmployeeChargeRate_ToBeDeleted] CHECK CONSTRAINT [FK_EmployeeChargeRate_Employee]
GO
