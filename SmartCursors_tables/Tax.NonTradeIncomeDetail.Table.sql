USE [SmartCursorSTG]
GO
/****** Object:  Table [Tax].[NonTradeIncomeDetail]    Script Date: 16-12-2024 9.30.57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Tax].[NonTradeIncomeDetail](
	[Id] [uniqueidentifier] NOT NULL,
	[NonTradeIncomeId] [uniqueidentifier] NOT NULL,
	[NatureId] [uniqueidentifier] NOT NULL,
	[ItemDescription] [nvarchar](500) NULL,
	[Amount] [decimal](15, 0) NULL,
	[NatureOfIncome] [nvarchar](50) NULL,
	[ProfitAndLossImportId] [uniqueidentifier] NULL,
	[SplitId] [uniqueidentifier] NULL,
	[Recorder] [int] NULL,
	[IsManual] [bit] NULL,
	[AnnotationName] [nvarchar](250) NULL,
 CONSTRAINT [PK_NonTradeIncomeDetail] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Tax].[NonTradeIncomeDetail]  WITH CHECK ADD  CONSTRAINT [FK_Nature_NonTradeIncomeDetail] FOREIGN KEY([NatureId])
REFERENCES [Tax].[Nature] ([Id])
GO
ALTER TABLE [Tax].[NonTradeIncomeDetail] CHECK CONSTRAINT [FK_Nature_NonTradeIncomeDetail]
GO
ALTER TABLE [Tax].[NonTradeIncomeDetail]  WITH CHECK ADD  CONSTRAINT [FK_NonTradeIncomeDetail_NonTradeIncome] FOREIGN KEY([NonTradeIncomeId])
REFERENCES [Tax].[NonTradeIncome] ([Id])
GO
ALTER TABLE [Tax].[NonTradeIncomeDetail] CHECK CONSTRAINT [FK_NonTradeIncomeDetail_NonTradeIncome]
GO
ALTER TABLE [Tax].[NonTradeIncomeDetail]  WITH CHECK ADD  CONSTRAINT [FK_ProfitAndLossImport_NonTradeIncomeDetail] FOREIGN KEY([ProfitAndLossImportId])
REFERENCES [Tax].[ProfitAndLossImport] ([Id])
GO
ALTER TABLE [Tax].[NonTradeIncomeDetail] CHECK CONSTRAINT [FK_ProfitAndLossImport_NonTradeIncomeDetail]
GO
ALTER TABLE [Tax].[NonTradeIncomeDetail]  WITH CHECK ADD  CONSTRAINT [FK_SplitDetail_NonTradeIncomeDetail] FOREIGN KEY([SplitId])
REFERENCES [Tax].[SplitDetail] ([Id])
GO
ALTER TABLE [Tax].[NonTradeIncomeDetail] CHECK CONSTRAINT [FK_SplitDetail_NonTradeIncomeDetail]
GO
