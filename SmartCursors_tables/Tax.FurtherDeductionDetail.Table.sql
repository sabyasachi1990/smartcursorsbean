USE [SmartCursorSTG]
GO
/****** Object:  Table [Tax].[FurtherDeductionDetail]    Script Date: 16-12-2024 9.30.57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Tax].[FurtherDeductionDetail](
	[Id] [uniqueidentifier] NOT NULL,
	[FurtherDeductionId] [uniqueidentifier] NOT NULL,
	[NatureId] [uniqueidentifier] NOT NULL,
	[AccountName] [nvarchar](256) NULL,
	[Amount] [decimal](15, 0) NULL,
	[NatureofDeduction] [nvarchar](100) NULL,
	[ProfitAndLossImportId] [uniqueidentifier] NULL,
	[SplitId] [uniqueidentifier] NULL,
	[Recorder] [int] NULL,
	[EnhancedAmount] [decimal](15, 0) NULL,
	[EnhancedPercentage] [int] NULL,
	[Annotation] [nvarchar](100) NULL,
	[IsManual] [bit] NULL,
 CONSTRAINT [PK_FurtherDeductionDetail] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Tax].[FurtherDeductionDetail]  WITH CHECK ADD  CONSTRAINT [FK_FurtherDeductionDetail_FurtherDeduction] FOREIGN KEY([FurtherDeductionId])
REFERENCES [Tax].[FurtherDeduction] ([Id])
GO
ALTER TABLE [Tax].[FurtherDeductionDetail] CHECK CONSTRAINT [FK_FurtherDeductionDetail_FurtherDeduction]
GO
ALTER TABLE [Tax].[FurtherDeductionDetail]  WITH CHECK ADD  CONSTRAINT [FK_Nature_FurtherDeductionDetail] FOREIGN KEY([NatureId])
REFERENCES [Tax].[Nature] ([Id])
GO
ALTER TABLE [Tax].[FurtherDeductionDetail] CHECK CONSTRAINT [FK_Nature_FurtherDeductionDetail]
GO
ALTER TABLE [Tax].[FurtherDeductionDetail]  WITH CHECK ADD  CONSTRAINT [FK_ProfitAndLossImport_FurtherDeductionDetail] FOREIGN KEY([ProfitAndLossImportId])
REFERENCES [Tax].[ProfitAndLossImport] ([Id])
GO
ALTER TABLE [Tax].[FurtherDeductionDetail] CHECK CONSTRAINT [FK_ProfitAndLossImport_FurtherDeductionDetail]
GO
ALTER TABLE [Tax].[FurtherDeductionDetail]  WITH CHECK ADD  CONSTRAINT [FK_SplitDetail_FurtherDeductionDetail] FOREIGN KEY([SplitId])
REFERENCES [Tax].[SplitDetail] ([Id])
GO
ALTER TABLE [Tax].[FurtherDeductionDetail] CHECK CONSTRAINT [FK_SplitDetail_FurtherDeductionDetail]
GO
