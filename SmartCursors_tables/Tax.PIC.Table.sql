USE [SmartCursorSTG]
GO
/****** Object:  Table [Tax].[PIC]    Script Date: 16-12-2024 9.30.57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Tax].[PIC](
	[ID] [uniqueidentifier] NOT NULL,
	[EngagementID] [uniqueidentifier] NULL,
	[AccountName] [nvarchar](100) NULL,
	[AnnotationId] [uniqueidentifier] NULL,
	[Cost] [decimal](15, 0) NULL,
	[GrantAmount] [decimal](15, 0) NULL,
	[NetQualifyingCost] [decimal](15, 0) NULL,
	[IsCashOutExecuted] [bit] NULL,
	[EnhanceBaseAmount] [decimal](15, 0) NULL,
	[EnhanceMultiplier1] [int] NULL,
	[EnhancedAllowanceOrDeduction] [decimal](15, 0) NULL,
	[QualifyingAllowanceOrDeduction] [decimal](15, 0) NULL,
	[PayoutBaseAmount] [decimal](15, 0) NULL,
	[PayoutMultiplier2] [int] NULL,
	[CashPayout] [decimal](15, 0) NULL,
	[PICCategory] [nvarchar](100) NULL,
	[ProfitAndLossImportId] [uniqueidentifier] NULL,
	[SplitId] [uniqueidentifier] NULL,
	[RecOrder] [int] NULL,
	[ReferScreeName] [nvarchar](100) NULL,
	[IsReference] [bit] NULL,
	[CommonId] [uniqueidentifier] NULL,
 CONSTRAINT [PK_PIC] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Tax].[PIC]  WITH CHECK ADD  CONSTRAINT [FK_PIC_TaxCompanyEngagement] FOREIGN KEY([EngagementID])
REFERENCES [Tax].[TaxCompanyEngagement] ([Id])
GO
ALTER TABLE [Tax].[PIC] CHECK CONSTRAINT [FK_PIC_TaxCompanyEngagement]
GO
