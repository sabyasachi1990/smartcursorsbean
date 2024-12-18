USE [SmartCursorSTG]
GO
/****** Object:  Table [Tax].[MedicalExpenseDetails]    Script Date: 16-12-2024 9.30.57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Tax].[MedicalExpenseDetails](
	[Id] [uniqueidentifier] NOT NULL,
	[MedicalExpensesId] [uniqueidentifier] NOT NULL,
	[ProfitAndLossImportId] [uniqueidentifier] NOT NULL,
	[FeatureName] [nvarchar](50) NULL,
	[SplitId] [uniqueidentifier] NULL,
	[AccountName] [nvarchar](200) NULL,
	[IsManual] [bit] NULL,
	[Amount] [money] NULL,
 CONSTRAINT [PK_MedicalExpenseDetails] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Tax].[MedicalExpenseDetails]  WITH CHECK ADD  CONSTRAINT [FK_MedicalExpenses_MedicalExpenseDetails] FOREIGN KEY([MedicalExpensesId])
REFERENCES [Tax].[MedicalExpenses] ([Id])
GO
ALTER TABLE [Tax].[MedicalExpenseDetails] CHECK CONSTRAINT [FK_MedicalExpenses_MedicalExpenseDetails]
GO
