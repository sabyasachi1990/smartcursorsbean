USE [SmartCursorSTG]
GO
/****** Object:  Table [WorkFlow].[CaseDesignation]    Script Date: 16-12-2024 9.30.57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [WorkFlow].[CaseDesignation](
	[Id] [uniqueidentifier] NOT NULL,
	[CaseId] [uniqueidentifier] NOT NULL,
	[DefaultRate] [money] NOT NULL,
	[Currency] [nvarchar](5) NOT NULL,
	[BillingRate] [money] NOT NULL,
	[BillCurrency] [nvarchar](5) NOT NULL,
	[EstdHours] [nvarchar](10) NULL,
	[Designation] [nvarchar](100) NULL,
	[RecOrder] [int] NULL,
	[Status] [int] NULL,
	[DepartmentDesignationId] [uniqueidentifier] NULL,
 CONSTRAINT [PK_CaseDesignation] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [WorkFlow].[CaseDesignation] ADD  DEFAULT ((1)) FOR [Status]
GO
ALTER TABLE [WorkFlow].[CaseDesignation]  WITH CHECK ADD  CONSTRAINT [FK_CaseDesignation_Case] FOREIGN KEY([CaseId])
REFERENCES [WorkFlow].[CaseGroup] ([Id])
ON DELETE CASCADE
GO
ALTER TABLE [WorkFlow].[CaseDesignation] CHECK CONSTRAINT [FK_CaseDesignation_Case]
GO
ALTER TABLE [WorkFlow].[CaseDesignation]  WITH CHECK ADD  CONSTRAINT [FK_DeptDesignation_Id] FOREIGN KEY([DepartmentDesignationId])
REFERENCES [Common].[DepartmentDesignation] ([Id])
GO
ALTER TABLE [WorkFlow].[CaseDesignation] CHECK CONSTRAINT [FK_DeptDesignation_Id]
GO
