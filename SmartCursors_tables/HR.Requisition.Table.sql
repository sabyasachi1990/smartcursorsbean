USE [SmartCursorSTG]
GO
/****** Object:  Table [HR].[Requisition]    Script Date: 16-12-2024 9.30.57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [HR].[Requisition](
	[Id] [uniqueidentifier] NOT NULL,
	[Code] [nvarchar](50) NULL,
	[CompanyId] [bigint] NOT NULL,
	[JobTitle] [nvarchar](256) NOT NULL,
	[DepartmentId] [uniqueidentifier] NULL,
	[OtherDepartment] [nvarchar](100) NULL,
	[DesignationId] [uniqueidentifier] NULL,
	[OtherDesignation] [nvarchar](100) NULL,
	[NoOfVacancies] [int] NULL,
	[HireReason] [nvarchar](256) NULL,
	[HireComment] [nvarchar](500) NULL,
	[PraposedHireDate] [datetime2](7) NULL,
	[TypeOfEmployment] [nvarchar](200) NULL,
	[IsInternal] [bit] NULL,
	[IsExternal] [bit] NULL,
	[Experience] [nvarchar](20) NULL,
	[Qualification] [nvarchar](1000) NULL,
	[JobDescription] [nvarchar](4000) NULL,
	[JobScope] [nvarchar](500) NULL,
	[Requirements] [nvarchar](500) NULL,
	[Skills] [nvarchar](500) NULL,
	[Qualities] [nvarchar](500) NULL,
	[ProposedSalaryMin] [decimal](10, 2) NULL,
	[ProposedSalaryMax] [decimal](10, 2) NULL,
	[ApproverId] [bigint] NOT NULL,
	[JobStatus] [nvarchar](10) NULL,
	[Remarks] [nvarchar](256) NULL,
	[RecOrder] [int] NULL,
	[UserCreated] [nvarchar](254) NULL,
	[CreatedDate] [datetime2](7) NULL,
	[ModifiedBy] [nvarchar](254) NULL,
	[ModifiedDate] [datetime2](7) NULL,
	[Version] [smallint] NULL,
	[Status] [int] NULL,
 CONSTRAINT [PK_Requisition] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [HR].[Requisition] ADD  DEFAULT ((0)) FOR [IsInternal]
GO
ALTER TABLE [HR].[Requisition] ADD  DEFAULT ((0)) FOR [IsExternal]
GO
ALTER TABLE [HR].[Requisition] ADD  DEFAULT ((1)) FOR [Status]
GO
ALTER TABLE [HR].[Requisition]  WITH CHECK ADD  CONSTRAINT [FK_Requisition_Company] FOREIGN KEY([CompanyId])
REFERENCES [Common].[Company] ([Id])
GO
ALTER TABLE [HR].[Requisition] CHECK CONSTRAINT [FK_Requisition_Company]
GO
ALTER TABLE [HR].[Requisition]  WITH CHECK ADD  CONSTRAINT [FK_Requisition_CompanyUser] FOREIGN KEY([ApproverId])
REFERENCES [Common].[CompanyUser] ([Id])
GO
ALTER TABLE [HR].[Requisition] CHECK CONSTRAINT [FK_Requisition_CompanyUser]
GO
ALTER TABLE [HR].[Requisition]  WITH CHECK ADD  CONSTRAINT [FK_Requisition_Department] FOREIGN KEY([DepartmentId])
REFERENCES [Common].[Department] ([Id])
GO
ALTER TABLE [HR].[Requisition] CHECK CONSTRAINT [FK_Requisition_Department]
GO
ALTER TABLE [HR].[Requisition]  WITH CHECK ADD  CONSTRAINT [FK_Requisition_DepartmentDesignation] FOREIGN KEY([DesignationId])
REFERENCES [Common].[DepartmentDesignation] ([Id])
GO
ALTER TABLE [HR].[Requisition] CHECK CONSTRAINT [FK_Requisition_DepartmentDesignation]
GO
