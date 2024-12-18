USE [SmartCursorSTG]
GO
/****** Object:  Table [HR].[AppraisalSummary]    Script Date: 16-12-2024 9.30.56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [HR].[AppraisalSummary](
	[Id] [uniqueidentifier] NOT NULL,
	[AppraisalId] [uniqueidentifier] NOT NULL,
	[Summary] [nvarchar](4000) NULL,
	[RecOrder] [int] NULL,
	[AppraiseeId] [uniqueidentifier] NULL,
 CONSTRAINT [PK_AppraisalSummary] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [HR].[AppraisalSummary]  WITH CHECK ADD  CONSTRAINT [FK_AppraisalSummary_Appraisal] FOREIGN KEY([AppraisalId])
REFERENCES [HR].[Appraisal] ([Id])
GO
ALTER TABLE [HR].[AppraisalSummary] CHECK CONSTRAINT [FK_AppraisalSummary_Appraisal]
GO
