USE [SmartCursorSTG]
GO
/****** Object:  Table [Tax].[FEAnalysisCountryCurrency]    Script Date: 16-12-2024 9.30.57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Tax].[FEAnalysisCountryCurrency](
	[ID] [uniqueidentifier] NOT NULL,
	[FEAnalysisID] [uniqueidentifier] NULL,
	[Currency] [nvarchar](50) NULL,
	[RecOrder] [int] NULL,
	[Remarks] [nvarchar](256) NULL,
	[UserCreated] [nvarchar](254) NULL,
	[CreatedDate] [datetime2](7) NULL,
	[ModifiedBy] [nvarchar](254) NULL,
	[ModifiedDate] [datetime2](7) NULL,
	[Version] [smallint] NULL,
	[Status] [int] NULL,
 CONSTRAINT [PK_FECountryCurrency] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Tax].[FEAnalysisCountryCurrency] ADD  DEFAULT ((1)) FOR [Status]
GO
ALTER TABLE [Tax].[FEAnalysisCountryCurrency]  WITH CHECK ADD  CONSTRAINT [FK_FECountryCurrency_FEAnalysis] FOREIGN KEY([FEAnalysisID])
REFERENCES [Tax].[FEAnalysis] ([ID])
GO
ALTER TABLE [Tax].[FEAnalysisCountryCurrency] CHECK CONSTRAINT [FK_FECountryCurrency_FEAnalysis]
GO
