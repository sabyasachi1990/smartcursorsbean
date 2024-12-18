USE [SmartCursorSTG]
GO
/****** Object:  Table [Bean].[DoubtfulDebtAllocation]    Script Date: 16-12-2024 9.30.55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Bean].[DoubtfulDebtAllocation](
	[Id] [uniqueidentifier] NOT NULL,
	[InvoiceId] [uniqueidentifier] NOT NULL,
	[CompanyId] [bigint] NOT NULL,
	[DoubtfulDebtAllocationDate] [datetime2](7) NOT NULL,
	[DoubtfulDebtAllocationResetDate] [datetime2](7) NULL,
	[IsNoSupportingDocumentActivated] [bit] NOT NULL,
	[IsNoSupportingDocument] [bit] NULL,
	[AllocateAmount] [money] NOT NULL,
	[Remarks] [nvarchar](1000) NULL,
	[UserCreated] [nvarchar](254) NULL,
	[CreatedDate] [datetime2](7) NULL,
	[ModifiedBy] [nvarchar](254) NULL,
	[ModifiedDate] [datetime2](7) NULL,
	[Status] [int] NOT NULL,
	[DoubtfulDebtAllocationNumber] [nvarchar](50) NULL,
	[IsRevExcess] [bit] NULL,
	[Version] [timestamp] NOT NULL,
	[IsLocked] [bit] NULL,
 CONSTRAINT [PK_DoubtfulDebtAllocation] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Bean].[DoubtfulDebtAllocation] ADD  DEFAULT ((1)) FOR [Status]
GO
ALTER TABLE [Bean].[DoubtfulDebtAllocation]  WITH CHECK ADD  CONSTRAINT [FK_DoubtfulDebtAllocation_Company] FOREIGN KEY([CompanyId])
REFERENCES [Common].[Company] ([Id])
GO
ALTER TABLE [Bean].[DoubtfulDebtAllocation] CHECK CONSTRAINT [FK_DoubtfulDebtAllocation_Company]
GO
ALTER TABLE [Bean].[DoubtfulDebtAllocation]  WITH CHECK ADD  CONSTRAINT [FK_DoubtfulDebtAllocation_Invoice] FOREIGN KEY([InvoiceId])
REFERENCES [Bean].[Invoice] ([Id])
GO
ALTER TABLE [Bean].[DoubtfulDebtAllocation] CHECK CONSTRAINT [FK_DoubtfulDebtAllocation_Invoice]
GO
