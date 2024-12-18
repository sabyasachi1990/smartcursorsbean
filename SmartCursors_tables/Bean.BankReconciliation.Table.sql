USE [SmartCursorSTG]
GO
/****** Object:  Table [Bean].[BankReconciliation]    Script Date: 16-12-2024 9.30.55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Bean].[BankReconciliation](
	[Id] [uniqueidentifier] NOT NULL,
	[CompanyId] [bigint] NOT NULL,
	[COAId] [bigint] NOT NULL,
	[ServiceCompanyId] [bigint] NOT NULL,
	[BankReconciliationDate] [datetime2](7) NOT NULL,
	[Currency] [nvarchar](5) NOT NULL,
	[BankAccount] [nvarchar](50) NOT NULL,
	[StatementAmount] [money] NOT NULL,
	[SubTotal] [money] NOT NULL,
	[StatementExpectedAmount] [money] NOT NULL,
	[GLAmount] [money] NOT NULL,
	[State] [nvarchar](50) NOT NULL,
	[UserCreated] [nvarchar](254) NULL,
	[CreatedDate] [datetime2](7) NULL,
	[ModifiedBy] [nvarchar](254) NULL,
	[ModifiedDate] [datetime2](7) NULL,
	[Status] [int] NULL,
	[StatementDate] [datetime2](7) NULL,
	[IsDraft] [bit] NULL,
	[IsReRunBR] [bit] NULL,
	[Version] [timestamp] NOT NULL,
	[IsLocked] [bit] NULL,
 CONSTRAINT [PK_BankReconciliation] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Bean].[BankReconciliation]  WITH CHECK ADD  CONSTRAINT [FK_BankReconciliation_ChartOfAccount] FOREIGN KEY([COAId])
REFERENCES [Bean].[ChartOfAccount] ([Id])
GO
ALTER TABLE [Bean].[BankReconciliation] CHECK CONSTRAINT [FK_BankReconciliation_ChartOfAccount]
GO
ALTER TABLE [Bean].[BankReconciliation]  WITH CHECK ADD  CONSTRAINT [FK_BankReconciliation_Company] FOREIGN KEY([CompanyId])
REFERENCES [Common].[Company] ([Id])
GO
ALTER TABLE [Bean].[BankReconciliation] CHECK CONSTRAINT [FK_BankReconciliation_Company]
GO
