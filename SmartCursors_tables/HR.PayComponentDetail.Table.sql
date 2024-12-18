USE [SmartCursorSTG]
GO
/****** Object:  Table [HR].[PayComponentDetail]    Script Date: 16-12-2024 9.30.57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [HR].[PayComponentDetail](
	[Id] [uniqueidentifier] NOT NULL,
	[MasterId] [uniqueidentifier] NOT NULL,
	[DepartmentId] [uniqueidentifier] NULL,
	[DesignationId] [uniqueidentifier] NULL,
	[Level] [nvarchar](50) NULL,
	[EmployeeId] [uniqueidentifier] NOT NULL,
	[Formula] [nvarchar](254) NULL,
	[PercentageComponent] [nvarchar](100) NULL,
	[PayMethod] [nvarchar](50) NULL,
	[Amount] [money] NULL,
	[Percentage] [money] NULL,
	[ComponentAmount] [money] NULL,
	[EffectiveFrom] [datetime2](7) NULL,
	[IsSystem] [bit] NULL,
	[Recorder] [int] NULL,
	[UserCreated] [nvarchar](50) NULL,
	[CreatedDate] [datetime2](7) NULL,
	[ModifiedDate] [datetime2](7) NULL,
	[ModifiedBy] [nvarchar](50) NULL,
	[Status] [int] NULL,
	[EffectiveTo] [datetime2](7) NULL,
 CONSTRAINT [PK_PayComponentDetail] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [HR].[PayComponentDetail] ADD  DEFAULT ((1)) FOR [Status]
GO
ALTER TABLE [HR].[PayComponentDetail]  WITH CHECK ADD  CONSTRAINT [FK_PayComponentDetail_Department] FOREIGN KEY([DepartmentId])
REFERENCES [Common].[Department] ([Id])
GO
ALTER TABLE [HR].[PayComponentDetail] CHECK CONSTRAINT [FK_PayComponentDetail_Department]
GO
ALTER TABLE [HR].[PayComponentDetail]  WITH CHECK ADD  CONSTRAINT [FK_PayComponentDetail_DepartmentDesignation] FOREIGN KEY([DesignationId])
REFERENCES [Common].[DepartmentDesignation] ([Id])
GO
ALTER TABLE [HR].[PayComponentDetail] CHECK CONSTRAINT [FK_PayComponentDetail_DepartmentDesignation]
GO
ALTER TABLE [HR].[PayComponentDetail]  WITH CHECK ADD  CONSTRAINT [FK_PayComponentDetail_Employee] FOREIGN KEY([EmployeeId])
REFERENCES [Common].[Employee] ([Id])
GO
ALTER TABLE [HR].[PayComponentDetail] CHECK CONSTRAINT [FK_PayComponentDetail_Employee]
GO
ALTER TABLE [HR].[PayComponentDetail]  WITH CHECK ADD  CONSTRAINT [FK_PayComponentDetail_PayComponent] FOREIGN KEY([MasterId])
REFERENCES [HR].[PayComponent] ([Id])
GO
ALTER TABLE [HR].[PayComponentDetail] CHECK CONSTRAINT [FK_PayComponentDetail_PayComponent]
GO
