USE [SmartCursorSTG]
GO
/****** Object:  Table [Tax].[Section14QAdditions]    Script Date: 16-12-2024 9.30.57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Tax].[Section14QAdditions](
	[Id] [uniqueidentifier] NOT NULL,
	[Section14QId] [uniqueidentifier] NOT NULL,
	[SectionAId] [uniqueidentifier] NULL,
	[SplitId] [uniqueidentifier] NULL,
	[ProfitAndLossImportId] [uniqueidentifier] NULL,
	[ItemDescription] [nvarchar](100) NULL,
	[Amount] [decimal](15, 0) NULL,
	[FeatureName] [nvarchar](50) NULL,
	[IsManual] [bit] NULL,
	[Annotation] [nvarchar](100) NULL,
	[DateOfPurchase] [datetime] NULL,
	[Recorder] [int] NULL,
 CONSTRAINT [PK_Section14QAdditions] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Tax].[Section14QAdditions]  WITH CHECK ADD  CONSTRAINT [FK_Section14QAdditions_ProfitAndLossImport] FOREIGN KEY([ProfitAndLossImportId])
REFERENCES [Tax].[ProfitAndLossImport] ([Id])
GO
ALTER TABLE [Tax].[Section14QAdditions] CHECK CONSTRAINT [FK_Section14QAdditions_ProfitAndLossImport]
GO
ALTER TABLE [Tax].[Section14QAdditions]  WITH CHECK ADD  CONSTRAINT [FK_Section14QAdditions_Section14Q] FOREIGN KEY([Section14QId])
REFERENCES [Tax].[Section14Q] ([Id])
GO
ALTER TABLE [Tax].[Section14QAdditions] CHECK CONSTRAINT [FK_Section14QAdditions_Section14Q]
GO
ALTER TABLE [Tax].[Section14QAdditions]  WITH CHECK ADD  CONSTRAINT [FK_Section14QAdditions_SectionA] FOREIGN KEY([SectionAId])
REFERENCES [Tax].[SectionA] ([Id])
GO
ALTER TABLE [Tax].[Section14QAdditions] CHECK CONSTRAINT [FK_Section14QAdditions_SectionA]
GO
ALTER TABLE [Tax].[Section14QAdditions]  WITH CHECK ADD  CONSTRAINT [FK_Section14QAdditions_SplitDetail] FOREIGN KEY([SplitId])
REFERENCES [Tax].[SplitDetail] ([Id])
GO
ALTER TABLE [Tax].[Section14QAdditions] CHECK CONSTRAINT [FK_Section14QAdditions_SplitDetail]
GO
