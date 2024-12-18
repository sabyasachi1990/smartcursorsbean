USE [SmartCursorSTG]
GO
/****** Object:  Table [Tax].[CommentReplyTable_ToBeDeleted]    Script Date: 16-12-2024 9.30.57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Tax].[CommentReplyTable_ToBeDeleted](
	[ID] [uniqueidentifier] NOT NULL,
	[CommentID] [uniqueidentifier] NULL,
	[Description] [nvarchar](500) NULL,
	[RecOrder] [int] NULL,
	[Remarks] [nvarchar](256) NULL,
	[UserCreated] [nvarchar](254) NULL,
	[CreatedDate] [datetime2](7) NULL,
	[ModifiedBy] [nvarchar](254) NULL,
	[ModifiedDate] [datetime2](7) NULL,
	[Version] [smallint] NULL,
	[Status] [int] NULL,
 CONSTRAINT [PK_AdjustmentCommentReply] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Tax].[CommentReplyTable_ToBeDeleted] ADD  DEFAULT (newid()) FOR [ID]
GO
ALTER TABLE [Tax].[CommentReplyTable_ToBeDeleted] ADD  DEFAULT ((1)) FOR [Status]
GO
ALTER TABLE [Tax].[CommentReplyTable_ToBeDeleted]  WITH CHECK ADD  CONSTRAINT [FK_AdjustmentCommentReply_Comment] FOREIGN KEY([CommentID])
REFERENCES [Common].[Comment] ([Id])
GO
ALTER TABLE [Tax].[CommentReplyTable_ToBeDeleted] CHECK CONSTRAINT [FK_AdjustmentCommentReply_Comment]
GO
