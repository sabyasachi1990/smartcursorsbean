USE [SmartCursorSTG]
GO
/****** Object:  Table [dbo].[ChartOfAccount_ToBeDeleted]    Script Date: 16-12-2024 9.30.56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ChartOfAccount_ToBeDeleted](
	[Id] [bigint] NOT NULL,
	[CompanyId] [bigint] NOT NULL,
	[Code] [nvarchar](100) NULL,
	[Name] [nvarchar](100) NOT NULL,
	[AccountTypeId] [bigint] NOT NULL,
	[Class] [nvarchar](100) NOT NULL,
	[Category] [nvarchar](100) NULL,
	[SubCategory] [nvarchar](100) NULL,
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
	[ModuleType] [nvarchar](50) NULL
) ON [PRIMARY]
GO
