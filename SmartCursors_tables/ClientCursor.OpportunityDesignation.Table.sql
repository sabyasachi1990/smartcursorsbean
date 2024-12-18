USE [SmartCursorSTG]
GO
/****** Object:  Table [ClientCursor].[OpportunityDesignation]    Script Date: 16-12-2024 9.30.56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [ClientCursor].[OpportunityDesignation](
	[Id] [uniqueidentifier] NOT NULL,
	[OpportunityId] [uniqueidentifier] NOT NULL,
	[DefaultRate] [money] NOT NULL,
	[Currency] [nvarchar](5) NOT NULL,
	[BillingRate] [money] NOT NULL,
	[BillCurrency] [nvarchar](5) NOT NULL,
	[EstdHours] [varchar](500) NULL,
	[RecOrder] [int] NULL,
	[Status] [int] NULL,
	[Designation] [nvarchar](100) NULL,
	[Rate] [money] NULL,
	[DepartmentId] [uniqueidentifier] NULL,
	[DepartmentDesignationId] [uniqueidentifier] NULL,
 CONSTRAINT [PK_OpportunityDesignation] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [ClientCursor].[OpportunityDesignation] ADD  DEFAULT ((1)) FOR [Status]
GO
ALTER TABLE [ClientCursor].[OpportunityDesignation]  WITH CHECK ADD  CONSTRAINT [FK_DeptDesignation_Id] FOREIGN KEY([DepartmentDesignationId])
REFERENCES [Common].[DepartmentDesignation] ([Id])
GO
ALTER TABLE [ClientCursor].[OpportunityDesignation] CHECK CONSTRAINT [FK_DeptDesignation_Id]
GO
ALTER TABLE [ClientCursor].[OpportunityDesignation]  WITH CHECK ADD  CONSTRAINT [FK_OpportunityDesignation_Opportunity] FOREIGN KEY([OpportunityId])
REFERENCES [ClientCursor].[Opportunity] ([Id])
GO
ALTER TABLE [ClientCursor].[OpportunityDesignation] CHECK CONSTRAINT [FK_OpportunityDesignation_Opportunity]
GO
