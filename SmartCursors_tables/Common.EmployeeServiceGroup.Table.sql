USE [SmartCursorSTG]
GO
/****** Object:  Table [Common].[EmployeeServiceGroup]    Script Date: 16-12-2024 9.30.56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Common].[EmployeeServiceGroup](
	[Id] [uniqueidentifier] NOT NULL,
	[EmployeeId] [uniqueidentifier] NOT NULL,
	[ServiceGroupId] [bigint] NOT NULL,
	[IsDefault] [bit] NOT NULL,
	[RecOrder] [int] NULL,
	[Status] [int] NULL,
	[UserCreated] [nvarchar](250) NULL,
	[ModifiedBy] [nvarchar](250) NULL,
	[CreatedDate] [datetime2](7) NULL,
	[Modifieddate] [datetime2](7) NULL,
 CONSTRAINT [PK_EmployeeServiceGroup] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Common].[EmployeeServiceGroup]  WITH CHECK ADD  CONSTRAINT [FK_EmployeeServiceGroup_Employee] FOREIGN KEY([EmployeeId])
REFERENCES [Common].[Employee] ([Id])
GO
ALTER TABLE [Common].[EmployeeServiceGroup] CHECK CONSTRAINT [FK_EmployeeServiceGroup_Employee]
GO
ALTER TABLE [Common].[EmployeeServiceGroup]  WITH CHECK ADD  CONSTRAINT [FK_EmployeeServiceGroup_ServiceGroup] FOREIGN KEY([ServiceGroupId])
REFERENCES [Common].[ServiceGroup] ([Id])
GO
ALTER TABLE [Common].[EmployeeServiceGroup] CHECK CONSTRAINT [FK_EmployeeServiceGroup_ServiceGroup]
GO
