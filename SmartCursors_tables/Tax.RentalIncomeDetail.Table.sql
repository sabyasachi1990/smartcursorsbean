USE [SmartCursorSTG]
GO
/****** Object:  Table [Tax].[RentalIncomeDetail]    Script Date: 16-12-2024 9.30.57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Tax].[RentalIncomeDetail](
	[Id] [uniqueidentifier] NOT NULL,
	[RentalIncomeId] [uniqueidentifier] NOT NULL,
	[ItemDescription] [nvarchar](500) NULL,
	[Amount] [decimal](15, 0) NULL,
	[Type] [nvarchar](20) NULL,
	[ProfitAndLossImportId] [uniqueidentifier] NULL,
	[SplitId] [uniqueidentifier] NULL,
	[Recorder] [int] NULL,
	[IsManual] [bit] NULL,
 CONSTRAINT [PK_RentalIncomeDetail] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Tax].[RentalIncomeDetail]  WITH CHECK ADD  CONSTRAINT [FK_ProfitAndLossImport_RentalIncomeDetail] FOREIGN KEY([ProfitAndLossImportId])
REFERENCES [Tax].[ProfitAndLossImport] ([Id])
GO
ALTER TABLE [Tax].[RentalIncomeDetail] CHECK CONSTRAINT [FK_ProfitAndLossImport_RentalIncomeDetail]
GO
ALTER TABLE [Tax].[RentalIncomeDetail]  WITH CHECK ADD  CONSTRAINT [FK_RentalIncomeDetail_RentalIncome] FOREIGN KEY([RentalIncomeId])
REFERENCES [Tax].[RentalIncome] ([Id])
GO
ALTER TABLE [Tax].[RentalIncomeDetail] CHECK CONSTRAINT [FK_RentalIncomeDetail_RentalIncome]
GO
ALTER TABLE [Tax].[RentalIncomeDetail]  WITH CHECK ADD  CONSTRAINT [FK_SplitDetail_RentalIncomeDetail] FOREIGN KEY([SplitId])
REFERENCES [Tax].[SplitDetail] ([Id])
GO
ALTER TABLE [Tax].[RentalIncomeDetail] CHECK CONSTRAINT [FK_SplitDetail_RentalIncomeDetail]
GO
