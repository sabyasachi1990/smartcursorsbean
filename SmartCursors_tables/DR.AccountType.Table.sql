USE [SmartCursorSTG]
GO
/****** Object:  Table [DR].[AccountType]    Script Date: 16-12-2024 9.30.56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [DR].[AccountType](
	[Id] [bigint] NOT NULL,
	[CompanyId] [bigint] NOT NULL,
	[Name] [nvarchar](100) NOT NULL,
	[SubCategory] [nvarchar](100) NOT NULL,
	[Category] [nvarchar](100) NULL,
	[Class] [nvarchar](100) NULL,
	[Nature] [nvarchar](100) NULL,
	[AppliesTo] [nvarchar](50) NULL,
	[IsSystem] [bit] NULL,
	[ShowCurrency] [bit] NULL,
	[RecOrder] [int] NULL,
	[Remarks] [nvarchar](256) NULL,
	[UserCreated] [nvarchar](254) NULL,
	[CreatedDate] [datetime2](7) NULL,
	[ModifiedBy] [nvarchar](254) NULL,
	[ModifiedDate] [datetime2](7) NULL,
	[Version] [smallint] NULL,
	[Status] [int] NULL,
	[ShowCashflowType] [bit] NULL,
	[ShowAllowable] [bit] NULL,
	[ShowRevaluation] [bit] NULL,
	[Indexs] [nvarchar](10) NULL,
	[ModuleType] [nvarchar](50) NULL,
	[CashflowType] [nvarchar](100) NULL,
	[FRATId] [uniqueidentifier] NULL,
	[QuickAssets] [bit] NULL,
	[NAForCreditorTurnOver] [bit] NULL,
	[COGS] [bit] NULL,
 CONSTRAINT [PK_AccountType] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [DR].[AccountType] ADD  DEFAULT ('All') FOR [AppliesTo]
GO
ALTER TABLE [DR].[AccountType] ADD  DEFAULT ((1)) FOR [ShowCurrency]
GO
ALTER TABLE [DR].[AccountType] ADD  DEFAULT ((1)) FOR [Status]
GO
ALTER TABLE [DR].[AccountType] ADD  DEFAULT ((1)) FOR [ShowCashflowType]
GO
ALTER TABLE [DR].[AccountType] ADD  DEFAULT ((0)) FOR [ShowAllowable]
GO
ALTER TABLE [DR].[AccountType] ADD  DEFAULT ((0)) FOR [ShowRevaluation]
GO
ALTER TABLE [DR].[AccountType] ADD  DEFAULT ((0)) FOR [QuickAssets]
GO
ALTER TABLE [DR].[AccountType] ADD  DEFAULT ((0)) FOR [NAForCreditorTurnOver]
GO
ALTER TABLE [DR].[AccountType] ADD  DEFAULT ((0)) FOR [COGS]
GO
ALTER TABLE [DR].[AccountType]  WITH CHECK ADD  CONSTRAINT [FK_AccountType_Company] FOREIGN KEY([CompanyId])
REFERENCES [Common].[Company] ([Id])
GO
ALTER TABLE [DR].[AccountType] CHECK CONSTRAINT [FK_AccountType_Company]
GO
