USE [SmartCursorSTG]
GO
/****** Object:  Table [Bean].[AccountType]    Script Date: 16-12-2024 9.30.55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Bean].[AccountType](
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
	[XeroAccountTypeId] [bigint] NULL,
	[XeroAccountTypeName] [nvarchar](100) NULL,
	[XeroAccountTypeStatus] [int] NULL,
	[IsXero] [bit] NULL,
	[StandardRecOrder] [int] NULL,
 CONSTRAINT [PK_AccountType] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Bean].[AccountType] ADD  DEFAULT ('All') FOR [AppliesTo]
GO
ALTER TABLE [Bean].[AccountType] ADD  DEFAULT ((1)) FOR [ShowCurrency]
GO
ALTER TABLE [Bean].[AccountType] ADD  DEFAULT ((1)) FOR [Status]
GO
ALTER TABLE [Bean].[AccountType] ADD  DEFAULT ((1)) FOR [ShowCashflowType]
GO
ALTER TABLE [Bean].[AccountType] ADD  DEFAULT ((0)) FOR [ShowAllowable]
GO
ALTER TABLE [Bean].[AccountType] ADD  DEFAULT ((0)) FOR [ShowRevaluation]
GO
ALTER TABLE [Bean].[AccountType]  WITH CHECK ADD  CONSTRAINT [FK_AccountType_Company] FOREIGN KEY([CompanyId])
REFERENCES [Common].[Company] ([Id])
GO
ALTER TABLE [Bean].[AccountType] CHECK CONSTRAINT [FK_AccountType_Company]
GO
