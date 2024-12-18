USE [SmartCursorSTG]
GO
/****** Object:  Table [Common].[Reply]    Script Date: 16-12-2024 9.30.56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Common].[Reply](
	[Id] [uniqueidentifier] NOT NULL,
	[CommentId] [uniqueidentifier] NOT NULL,
	[Description] [nvarchar](4000) NULL,
	[UserCreated] [nvarchar](254) NULL,
	[CreatedDate] [datetime2](7) NULL,
	[ModifiedBy] [nvarchar](254) NULL,
	[ModifiedDate] [datetime2](7) NULL,
	[Status] [int] NULL,
	[ShortName] [nvarchar](20) NULL,
	[UserName] [nvarchar](4000) NULL,
 CONSTRAINT [PK_Reply] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Common].[Reply]  WITH CHECK ADD  CONSTRAINT [FK_CommentReply_Comment] FOREIGN KEY([CommentId])
REFERENCES [Common].[Comment] ([Id])
GO
ALTER TABLE [Common].[Reply] CHECK CONSTRAINT [FK_CommentReply_Comment]
GO
ALTER TABLE [Common].[Reply]  WITH CHECK ADD  CONSTRAINT [Fk_Reply_CommentId] FOREIGN KEY([CommentId])
REFERENCES [Common].[Comment] ([Id])
GO
ALTER TABLE [Common].[Reply] CHECK CONSTRAINT [Fk_Reply_CommentId]
GO
