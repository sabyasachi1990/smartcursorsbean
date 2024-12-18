USE [SmartCursorSTG]
GO
/****** Object:  Table [Tax].[ForeignCurrencyAnalysisFactors]    Script Date: 16-12-2024 9.30.57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Tax].[ForeignCurrencyAnalysisFactors](
	[ID] [uniqueidentifier] NOT NULL,
	[FCAnalysisID] [uniqueidentifier] NULL,
	[FactorType] [nvarchar](50) NULL,
	[Currency] [nvarchar](50) NULL,
	[Particular] [nvarchar](50) NULL,
	[Percentage] [float] NULL,
	[RecOrder] [int] NULL,
	[Remarks] [nvarchar](256) NULL,
	[UserCreated] [nvarchar](254) NULL,
	[CreatedDate] [datetime2](7) NULL,
	[ModifiedBy] [nvarchar](254) NULL,
	[ModifiedDate] [datetime2](7) NULL,
	[Version] [smallint] NULL,
	[Status] [int] NULL,
 CONSTRAINT [PK_ForeignCurrencyAnalysisFactors] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Tax].[ForeignCurrencyAnalysisFactors] ADD  DEFAULT ((1)) FOR [Status]
GO
ALTER TABLE [Tax].[ForeignCurrencyAnalysisFactors]  WITH CHECK ADD  CONSTRAINT [FK_ForeignCurrencyAnalysisFactors_ForeignCurrencyAnalysis] FOREIGN KEY([FCAnalysisID])
REFERENCES [Tax].[ForeignCurrencyAnalysis] ([ID])
GO
ALTER TABLE [Tax].[ForeignCurrencyAnalysisFactors] CHECK CONSTRAINT [FK_ForeignCurrencyAnalysisFactors_ForeignCurrencyAnalysis]
GO
