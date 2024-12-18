USE [SmartCursorSTG]
GO
/****** Object:  Table [Bean].[ChartOfAccount]    Script Date: 16-12-2024 9.30.55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Bean].[ChartOfAccount](
	[Id] [bigint] NOT NULL,
	[CompanyId] [bigint] NOT NULL,
	[Code] [nvarchar](100) NULL,
	[Name] [nvarchar](100) NOT NULL,
	[AccountTypeId] [bigint] NOT NULL,
	[SubCategory] [nvarchar](100) NOT NULL,
	[Category] [nvarchar](100) NULL,
	[Class] [nvarchar](100) NULL,
	[Nature] [nvarchar](100) NULL,
	[Currency] [nvarchar](5) NULL,
	[ShowRevaluation] [bit] NULL,
	[CashflowType] [nvarchar](50) NULL,
	[AppliesTo] [nvarchar](50) NULL,
	[IsSystem] [bit] NULL,
	[IsShowforCOA] [bit] NULL,
	[RecOrder] [int] NULL,
	[Remarks] [nvarchar](256) NULL,
	[UserCreated] [nvarchar](254) NULL,
	[CreatedDate] [datetime2](7) NULL,
	[ModifiedBy] [nvarchar](254) NULL,
	[ModifiedDate] [datetime2](7) NULL,
	[Version] [smallint] NULL,
	[Status] [int] NULL,
	[IsSubLedger] [bit] NULL,
	[IsCodeEditable] [bit] NULL,
	[ShowCurrency] [bit] NULL,
	[ShowCashFlow] [bit] NULL,
	[ShowAllowable] [bit] NULL,
	[IsRevaluation] [int] NULL,
	[Revaluation] [bit] NULL,
	[DisAllowable] [bit] NULL,
	[RealisedExchangeGainOrLoss] [bit] NULL,
	[UnrealisedExchangeGainOrLoss] [bit] NULL,
	[ModuleType] [nvarchar](50) NULL,
	[IsSeedData] [bit] NULL,
	[SubsidaryCompanyId] [bigint] NULL,
	[IsBank] [bit] NULL,
	[IsDebt] [bit] NULL,
	[IsAllowableNotAllowableActivated] [bit] NULL,
	[IsLinkedAccount] [bit] NULL,
	[IsRealCOA] [bit] NULL,
	[FRCoaId] [uniqueidentifier] NULL,
	[FRPATId] [uniqueidentifier] NULL,
	[FRRecOrder] [int] NULL,
	[CategoryId] [uniqueidentifier] NULL,
	[SubCategoryId] [uniqueidentifier] NULL,
	[TaxType] [nvarchar](50) NULL,
	[XeroCode] [nvarchar](100) NULL,
	[XeroName] [nvarchar](100) NULL,
	[XeroClass] [nvarchar](100) NULL,
	[XeroAccountTypeId] [nvarchar](100) NULL,
	[XeroAccountId] [nvarchar](100) NULL,
	[IsFromXero] [bit] NULL,
 CONSTRAINT [PK_ChartOfAccount] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Bean].[ChartOfAccount] ADD  DEFAULT ('All') FOR [AppliesTo]
GO
ALTER TABLE [Bean].[ChartOfAccount] ADD  DEFAULT ((1)) FOR [IsShowforCOA]
GO
ALTER TABLE [Bean].[ChartOfAccount] ADD  DEFAULT ((1)) FOR [Status]
GO
ALTER TABLE [Bean].[ChartOfAccount] ADD  DEFAULT ((1)) FOR [IsCodeEditable]
GO
ALTER TABLE [Bean].[ChartOfAccount] ADD  DEFAULT ((1)) FOR [ShowCurrency]
GO
ALTER TABLE [Bean].[ChartOfAccount] ADD  DEFAULT ((1)) FOR [ShowCashFlow]
GO
ALTER TABLE [Bean].[ChartOfAccount] ADD  DEFAULT ((1)) FOR [ShowAllowable]
GO
ALTER TABLE [Bean].[ChartOfAccount] ADD  DEFAULT ((0)) FOR [Revaluation]
GO
ALTER TABLE [Bean].[ChartOfAccount]  WITH CHECK ADD  CONSTRAINT [FK_ChartOfAccount_AccountType] FOREIGN KEY([AccountTypeId])
REFERENCES [Bean].[AccountType] ([Id])
GO
ALTER TABLE [Bean].[ChartOfAccount] CHECK CONSTRAINT [FK_ChartOfAccount_AccountType]
GO
ALTER TABLE [Bean].[ChartOfAccount]  WITH CHECK ADD  CONSTRAINT [FK_ChartOfAccount_Company] FOREIGN KEY([CompanyId])
REFERENCES [Common].[Company] ([Id])
GO
ALTER TABLE [Bean].[ChartOfAccount] CHECK CONSTRAINT [FK_ChartOfAccount_Company]
GO
