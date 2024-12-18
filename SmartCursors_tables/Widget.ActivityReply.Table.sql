USE [SmartCursorSTG]
GO
/****** Object:  Table [Widget].[ActivityReply]    Script Date: 16-12-2024 9.30.57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Widget].[ActivityReply](
	[Id] [uniqueidentifier] NOT NULL,
	[ActivityId] [uniqueidentifier] NOT NULL,
	[Reply] [nvarchar](4000) NOT NULL,
	[AttachmentId] [uniqueidentifier] NULL,
	[FileName] [nvarchar](256) NULL,
	[FromUser] [nvarchar](254) NULL,
	[ReplyDateTime] [datetime2](7) NOT NULL,
	[CreatedDate] [datetime2](7) NULL,
	[FileFullPath] [nvarchar](1000) NULL,
	[ReplyById] [uniqueidentifier] NULL,
 CONSTRAINT [PK_ActivityReply] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Widget].[ActivityReply]  WITH CHECK ADD  CONSTRAINT [FK_ActivityReply_Activity] FOREIGN KEY([ActivityId])
REFERENCES [Widget].[Activity] ([Id])
GO
ALTER TABLE [Widget].[ActivityReply] CHECK CONSTRAINT [FK_ActivityReply_Activity]
GO
ALTER TABLE [Widget].[ActivityReply]  WITH CHECK ADD  CONSTRAINT [FK_ActivityReply_MediaRepository] FOREIGN KEY([AttachmentId])
REFERENCES [Common].[MediaRepository] ([Id])
GO
ALTER TABLE [Widget].[ActivityReply] CHECK CONSTRAINT [FK_ActivityReply_MediaRepository]
GO
ALTER TABLE [Widget].[ActivityReply]  WITH CHECK ADD  CONSTRAINT [FK_ActivityReply_UserAccount] FOREIGN KEY([ReplyById])
REFERENCES [Auth].[UserAccount] ([Id])
GO
ALTER TABLE [Widget].[ActivityReply] CHECK CONSTRAINT [FK_ActivityReply_UserAccount]
GO
