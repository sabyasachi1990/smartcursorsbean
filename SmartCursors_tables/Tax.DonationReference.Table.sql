USE [SmartCursorSTG]
GO
/****** Object:  Table [Tax].[DonationReference]    Script Date: 16-12-2024 9.30.57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Tax].[DonationReference](
	[Id] [uniqueidentifier] NOT NULL,
	[EngagementId] [uniqueidentifier] NOT NULL,
	[ProfitAndLossImportId] [uniqueidentifier] NULL,
	[SplitId] [uniqueidentifier] NULL,
	[AccountName] [nvarchar](500) NULL,
	[Amount] [decimal](15, 0) NULL,
	[ExpensesDescription] [nvarchar](500) NULL,
	[IsManual] [bit] NULL,
	[Recorder] [int] NULL,
 CONSTRAINT [PK_DonationReference] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Tax].[DonationReference]  WITH CHECK ADD  CONSTRAINT [FK_DonationReference_TaxCompanyEngagement] FOREIGN KEY([EngagementId])
REFERENCES [Tax].[TaxCompanyEngagement] ([Id])
GO
ALTER TABLE [Tax].[DonationReference] CHECK CONSTRAINT [FK_DonationReference_TaxCompanyEngagement]
GO
ALTER TABLE [Tax].[DonationReference]  WITH CHECK ADD  CONSTRAINT [FK_ProfitAndLossImport_DonationReference] FOREIGN KEY([ProfitAndLossImportId])
REFERENCES [Tax].[ProfitAndLossImport] ([Id])
GO
ALTER TABLE [Tax].[DonationReference] CHECK CONSTRAINT [FK_ProfitAndLossImport_DonationReference]
GO
ALTER TABLE [Tax].[DonationReference]  WITH CHECK ADD  CONSTRAINT [FK_SplitDetail_DonationReference] FOREIGN KEY([SplitId])
REFERENCES [Tax].[SplitDetail] ([Id])
GO
ALTER TABLE [Tax].[DonationReference] CHECK CONSTRAINT [FK_SplitDetail_DonationReference]
GO
