USE [SmartCursorSTG]
GO
/****** Object:  Table [Tax].[InterestExpenses]    Script Date: 16-12-2024 9.30.57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Tax].[InterestExpenses](
	[ID] [uniqueidentifier] NOT NULL,
	[InterestRestrictionId] [uniqueidentifier] NULL,
	[AnnotationId] [uniqueidentifier] NOT NULL,
	[ItemDescription] [nvarchar](200) NULL,
	[Amount] [decimal](20, 0) NULL,
	[RecOrder] [int] NULL,
	[AnnotationName] [nvarchar](50) NULL,
	[IsSystem] [bit] NULL,
	[ProfitAndLossImportId] [uniqueidentifier] NULL,
	[SplitId] [uniqueidentifier] NULL,
 CONSTRAINT [PK_InterestExpenses] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Tax].[InterestExpenses]  WITH CHECK ADD  CONSTRAINT [FK_InterestExpenses_InterestRestrictionId] FOREIGN KEY([InterestRestrictionId])
REFERENCES [Tax].[InterestRestriction] ([ID])
GO
ALTER TABLE [Tax].[InterestExpenses] CHECK CONSTRAINT [FK_InterestExpenses_InterestRestrictionId]
GO
