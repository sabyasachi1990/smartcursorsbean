USE [SmartCursorSTG]
GO
/****** Object:  Table [Tax].[StatementA]    Script Date: 16-12-2024 9.30.57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Tax].[StatementA](
	[Id] [uniqueidentifier] NOT NULL,
	[Particular] [nvarchar](250) NULL,
	[Amount] [decimal](17, 2) NULL,
	[PandLId] [uniqueidentifier] NOT NULL,
	[TypeId] [uniqueidentifier] NOT NULL,
	[FeatureSection] [nvarchar](50) NULL,
	[EngagementId] [uniqueidentifier] NULL,
	[SplitDetailId] [uniqueidentifier] NULL,
 CONSTRAINT [PK_StatementA] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ADD SENSITIVITY CLASSIFICATION TO [Tax].[StatementA].[Amount] WITH (label = 'Confidential', label_id = '281b9ab3-ecbb-4a57-8486-c702e44215d8', information_type = 'Financial', information_type_id = 'c44193e1-0e58-4b2a-9001-f7d6e7bc1373', rank = Medium);
GO
ALTER TABLE [Tax].[StatementA]  WITH CHECK ADD  CONSTRAINT [FK_StatementA_TaxCompanyEngagement] FOREIGN KEY([EngagementId])
REFERENCES [Tax].[TaxCompanyEngagement] ([Id])
GO
ALTER TABLE [Tax].[StatementA] CHECK CONSTRAINT [FK_StatementA_TaxCompanyEngagement]
GO
ALTER TABLE [Tax].[StatementA]  WITH CHECK ADD  CONSTRAINT [PK_StatementA_PandL] FOREIGN KEY([PandLId])
REFERENCES [Tax].[ProfitAndLossImport] ([Id])
GO
ALTER TABLE [Tax].[StatementA] CHECK CONSTRAINT [PK_StatementA_PandL]
GO
