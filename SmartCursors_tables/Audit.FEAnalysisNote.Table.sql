USE [SmartCursorSTG]
GO
/****** Object:  Table [Audit].[FEAnalysisNote]    Script Date: 16-12-2024 9.30.55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Audit].[FEAnalysisNote](
	[ID] [uniqueidentifier] NOT NULL,
	[FEAnalysisID] [uniqueidentifier] NULL,
	[Code] [nvarchar](50) NULL,
	[Description] [nvarchar](max) NULL,
	[AdjustmentID] [uniqueidentifier] NULL,
	[FELegendID] [uniqueidentifier] NULL,
	[RecOrder] [int] NULL,
	[Remarks] [nvarchar](256) NULL,
	[UserCreated] [nvarchar](254) NULL,
	[CreatedDate] [datetime2](7) NULL,
	[ModifiedBy] [nvarchar](254) NULL,
	[ModifiedDate] [datetime2](7) NULL,
	[Version] [smallint] NULL,
	[Status] [int] NULL,
 CONSTRAINT [PK_ForeignExchangeAnalysisNote] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [Audit].[FEAnalysisNote] ADD  DEFAULT ((1)) FOR [Status]
GO
ALTER TABLE [Audit].[FEAnalysisNote]  WITH CHECK ADD  CONSTRAINT [FK_FEAnalysisNote_FEAnalysis] FOREIGN KEY([FEAnalysisID])
REFERENCES [Audit].[FEAnalysis] ([ID])
GO
ALTER TABLE [Audit].[FEAnalysisNote] CHECK CONSTRAINT [FK_FEAnalysisNote_FEAnalysis]
GO
