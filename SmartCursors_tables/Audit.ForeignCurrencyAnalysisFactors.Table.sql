USE [SmartCursorSTG]
GO
/****** Object:  Table [Audit].[ForeignCurrencyAnalysisFactors]    Script Date: 16-12-2024 9.30.55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Audit].[ForeignCurrencyAnalysisFactors](
	[ID] [uniqueidentifier] NOT NULL,
	[FCAnalysisID] [uniqueidentifier] NULL,
	[FactorType] [nvarchar](50) NULL,
	[Currency] [nvarchar](50) NULL,
	[Particular] [nvarchar](200) NULL,
	[Percentage] [float] NULL,
	[RecOrder] [int] NULL,
	[Remarks] [nvarchar](256) NULL,
	[UserCreated] [nvarchar](254) NULL,
	[CreatedDate] [datetime2](7) NULL,
	[ModifiedBy] [nvarchar](254) NULL,
	[ModifiedDate] [datetime2](7) NULL,
	[Version] [smallint] NULL,
	[Status] [int] NULL,
 CONSTRAINT [PK_FEFunctionalCurrencyFactors] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Audit].[ForeignCurrencyAnalysisFactors] ADD  DEFAULT (newid()) FOR [ID]
GO
ALTER TABLE [Audit].[ForeignCurrencyAnalysisFactors] ADD  DEFAULT ((1)) FOR [Status]
GO
ALTER TABLE [Audit].[ForeignCurrencyAnalysisFactors]  WITH CHECK ADD  CONSTRAINT [FK_FEFunctionalCurrencyFactors_ForeignCurrencyAnalysis] FOREIGN KEY([FCAnalysisID])
REFERENCES [Audit].[ForeignCurrencyAnalysis] ([ID])
GO
ALTER TABLE [Audit].[ForeignCurrencyAnalysisFactors] CHECK CONSTRAINT [FK_FEFunctionalCurrencyFactors_ForeignCurrencyAnalysis]
GO
