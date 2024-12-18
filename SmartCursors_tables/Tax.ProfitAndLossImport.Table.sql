USE [SmartCursorSTG]
GO
/****** Object:  Table [Tax].[ProfitAndLossImport]    Script Date: 16-12-2024 9.30.57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Tax].[ProfitAndLossImport](
	[Id] [uniqueidentifier] NOT NULL,
	[TaxCompanyId] [uniqueidentifier] NULL,
	[EngagementId] [uniqueidentifier] NULL,
	[AccountNumber] [nvarchar](100) NULL,
	[AccountName] [nvarchar](100) NULL,
	[AccountDesc] [nvarchar](200) NULL,
	[CYDebit] [money] NULL,
	[CYCredit] [money] NULL,
	[TransactionDate] [datetime] NULL,
	[IsActive] [bit] NULL,
	[CurrentBalance] [money] NULL,
	[PreviousYearBalance] [money] NULL,
	[PBCBalance] [money] NULL,
	[PYDebit] [money] NULL,
	[PYCredit] [money] NULL,
	[Balance] [money] NULL,
	[AmountChange] [money] NULL,
	[AJEs] [money] NULL,
	[Final] [money] NULL,
	[ReconcileId] [uniqueidentifier] NULL,
	[ClassificationId] [uniqueidentifier] NULL,
	[FileId] [uniqueidentifier] NULL,
	[ModifiedFlag] [int] NULL,
	[AccountType] [nvarchar](8) NULL,
	[Remarks] [nvarchar](256) NULL,
	[RecOrder] [int] NULL,
	[UserCreated] [nvarchar](254) NULL,
	[CreatedDate] [datetime2](7) NULL,
	[ModifiedBy] [nvarchar](254) NULL,
	[ModifiedDate] [datetime2](7) NULL,
	[Version] [smallint] NULL,
	[Status] [int] NULL,
	[IsRoundOff] [bit] NULL,
	[IsOverride] [bit] NULL,
	[CategoryId] [uniqueidentifier] NULL,
	[IsCyCurrent] [bit] NULL,
	[IsPyCurrent] [bit] NULL,
	[Difference] [decimal](15, 5) NULL,
	[SubCategoryId] [uniqueidentifier] NULL,
	[IsCollapse] [bit] NULL,
 CONSTRAINT [PK_ProfitAndLossImport] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Tax].[ProfitAndLossImport] ADD  DEFAULT ((1)) FOR [Status]
GO
ALTER TABLE [Tax].[ProfitAndLossImport]  WITH CHECK ADD  CONSTRAINT [FK_ProfitAndLossImport_TaxCompany] FOREIGN KEY([TaxCompanyId])
REFERENCES [Tax].[TaxCompany] ([Id])
GO
ALTER TABLE [Tax].[ProfitAndLossImport] CHECK CONSTRAINT [FK_ProfitAndLossImport_TaxCompany]
GO
ALTER TABLE [Tax].[ProfitAndLossImport]  WITH CHECK ADD  CONSTRAINT [FK_ProfitAndLossImport_TaxCompanyEngagement] FOREIGN KEY([EngagementId])
REFERENCES [Tax].[TaxCompanyEngagement] ([Id])
GO
ALTER TABLE [Tax].[ProfitAndLossImport] CHECK CONSTRAINT [FK_ProfitAndLossImport_TaxCompanyEngagement]
GO
