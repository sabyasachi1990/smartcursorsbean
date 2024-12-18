USE [SmartCursorSTG]
GO
/****** Object:  Table [Widget].[ActivityReplyAttachment]    Script Date: 16-12-2024 9.30.57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Widget].[ActivityReplyAttachment](
	[Id] [uniqueidentifier] NOT NULL,
	[ActivityReplyId] [uniqueidentifier] NOT NULL,
	[FileUploadId] [uniqueidentifier] NOT NULL,
	[FileName] [nvarchar](256) NULL,
	[FileFullPath] [nvarchar](1000) NULL,
 CONSTRAINT [PK_ActivityReplyAttachment] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Widget].[ActivityReplyAttachment]  WITH CHECK ADD  CONSTRAINT [FK_ActivityReplyAttachment_ActivityReply] FOREIGN KEY([ActivityReplyId])
REFERENCES [Widget].[ActivityReply] ([Id])
GO
ALTER TABLE [Widget].[ActivityReplyAttachment] CHECK CONSTRAINT [FK_ActivityReplyAttachment_ActivityReply]
GO
ALTER TABLE [Widget].[ActivityReplyAttachment]  WITH CHECK ADD  CONSTRAINT [FK_ActivityReplyAttachment_MediaRepository] FOREIGN KEY([FileUploadId])
REFERENCES [Common].[MediaRepository] ([Id])
GO
ALTER TABLE [Widget].[ActivityReplyAttachment] CHECK CONSTRAINT [FK_ActivityReplyAttachment_MediaRepository]
GO
