USE [SmartCursorSTG]
GO
/****** Object:  Table [Tax].[CommentTable_ToBeDeleted]    Script Date: 16-12-2024 9.30.57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Tax].[CommentTable_ToBeDeleted](
	[ID] [uniqueidentifier] NOT NULL,
	[Description] [nvarchar](500) NULL,
	[AdjustmentComment_ID] [uniqueidentifier] NULL,
	[Review] [bit] NULL,
	[UserCreated] [nvarchar](254) NULL,
	[CreatedDate] [datetime] NULL,
	[ModifiedBy] [nvarchar](254) NULL,
	[ModifiedDate] [datetime] NULL,
	[Status] [int] NULL,
	[IsResolve] [bit] NULL,
 CONSTRAINT [PK_Comments] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Tax].[CommentTable_ToBeDeleted]  WITH CHECK ADD  CONSTRAINT [FK_CommentTable_AdjustmentComment] FOREIGN KEY([AdjustmentComment_ID])
REFERENCES [Tax].[AdjustmentComment_ToBeDeleted] ([ID])
GO
ALTER TABLE [Tax].[CommentTable_ToBeDeleted] CHECK CONSTRAINT [FK_CommentTable_AdjustmentComment]
GO
