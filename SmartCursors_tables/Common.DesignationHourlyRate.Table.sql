USE [SmartCursorSTG]
GO
/****** Object:  Table [Common].[DesignationHourlyRate]    Script Date: 16-12-2024 9.30.56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Common].[DesignationHourlyRate](
	[Id] [bigint] NOT NULL,
	[ServiceGroupId] [bigint] NOT NULL,
	[ServiceId] [bigint] NULL,
	[Designation] [nvarchar](100) NOT NULL,
	[Rate] [money] NOT NULL,
	[RecOrder] [int] NULL,
	[Status] [int] NULL,
	[count] [int] NULL,
	[FeeAllocation] [int] NULL,
	[Department] [nvarchar](100) NULL,
	[DepartmentId] [uniqueidentifier] NULL,
	[DesignationId] [uniqueidentifier] NULL,
 CONSTRAINT [PK_DesignationHourlyRate] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Common].[DesignationHourlyRate] ADD  DEFAULT ((1)) FOR [Status]
GO
ALTER TABLE [Common].[DesignationHourlyRate]  WITH CHECK ADD  CONSTRAINT [FK_DesignationHourlyRate_Department] FOREIGN KEY([DepartmentId])
REFERENCES [Common].[Department] ([Id])
GO
ALTER TABLE [Common].[DesignationHourlyRate] CHECK CONSTRAINT [FK_DesignationHourlyRate_Department]
GO
ALTER TABLE [Common].[DesignationHourlyRate]  WITH CHECK ADD  CONSTRAINT [FK_DesignationHourlyRate_Designation] FOREIGN KEY([DesignationId])
REFERENCES [Common].[DepartmentDesignation] ([Id])
GO
ALTER TABLE [Common].[DesignationHourlyRate] CHECK CONSTRAINT [FK_DesignationHourlyRate_Designation]
GO
ALTER TABLE [Common].[DesignationHourlyRate]  WITH CHECK ADD  CONSTRAINT [FK_DesignationHourlyRate_Service] FOREIGN KEY([ServiceId])
REFERENCES [Common].[Service] ([Id])
GO
ALTER TABLE [Common].[DesignationHourlyRate] CHECK CONSTRAINT [FK_DesignationHourlyRate_Service]
GO
ALTER TABLE [Common].[DesignationHourlyRate]  WITH CHECK ADD  CONSTRAINT [FK_DesignationHourlyRate_ServiceGroup] FOREIGN KEY([ServiceGroupId])
REFERENCES [Common].[ServiceGroup] ([Id])
GO
ALTER TABLE [Common].[DesignationHourlyRate] CHECK CONSTRAINT [FK_DesignationHourlyRate_ServiceGroup]
GO
