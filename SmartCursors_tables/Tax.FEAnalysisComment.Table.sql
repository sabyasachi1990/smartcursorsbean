USE [SmartCursorSTG]
GO
/****** Object:  Table [Tax].[FEAnalysisComment]    Script Date: 16-12-2024 9.30.57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Tax].[FEAnalysisComment](
	[ID] [uniqueidentifier] NOT NULL,
	[FEAnalysisID] [uniqueidentifier] NULL,
	[Description] [nvarchar](500) NULL,
	[Review] [bit] NULL,
	[CommentID] [uniqueidentifier] NULL,
	[RecOrder] [int] NULL,
	[Remarks] [nvarchar](256) NULL,
	[UserCreated] [nvarchar](254) NULL,
	[CreatedDate] [datetime2](7) NULL,
	[ModifiedBy] [nvarchar](254) NULL,
	[ModifiedDate] [datetime2](7) NULL,
	[Version] [smallint] NULL,
	[Status] [int] NULL,
 CONSTRAINT [PK_FEAnalysisComment] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Tax].[FEAnalysisComment] ADD  DEFAULT ((1)) FOR [Status]
GO
ALTER TABLE [Tax].[FEAnalysisComment]  WITH CHECK ADD  CONSTRAINT [FK_FEAnalysisComment_Comment] FOREIGN KEY([CommentID])
REFERENCES [Common].[Comment] ([Id])
GO
ALTER TABLE [Tax].[FEAnalysisComment] CHECK CONSTRAINT [FK_FEAnalysisComment_Comment]
GO
ALTER TABLE [Tax].[FEAnalysisComment]  WITH CHECK ADD  CONSTRAINT [FK_FEAnalysisComment_FEAnalysis] FOREIGN KEY([FEAnalysisID])
REFERENCES [Tax].[FEAnalysis] ([ID])
GO
ALTER TABLE [Tax].[FEAnalysisComment] CHECK CONSTRAINT [FK_FEAnalysisComment_FEAnalysis]
GO
