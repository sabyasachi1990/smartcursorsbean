USE [SmartCursorSTG]
GO
/****** Object:  Table [HR].[EmployeeDepartmentHistory]    Script Date: 16-12-2024 9.30.56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [HR].[EmployeeDepartmentHistory](
	[Id] [uniqueidentifier] NOT NULL,
	[EmployeeDepartmentId] [uniqueidentifier] NOT NULL,
	[ModifiedBy] [nvarchar](200) NULL,
	[ModifiedDate] [datetime] NULL,
	[UserCreated] [nvarchar](200) NULL,
	[EntityName] [nvarchar](200) NULL,
	[CreatedDate] [datetime] NULL,
 CONSTRAINT [PK_EmployeeDepartmentHistory] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [HR].[EmployeeDepartmentHistory]  WITH CHECK ADD  CONSTRAINT [FK_EmployeeDepartmentHistory_EmployeeDepartment] FOREIGN KEY([EmployeeDepartmentId])
REFERENCES [HR].[EmployeeDepartment] ([Id])
GO
ALTER TABLE [HR].[EmployeeDepartmentHistory] CHECK CONSTRAINT [FK_EmployeeDepartmentHistory_EmployeeDepartment]
GO
