USE [SmartCursorSTG]
GO
/****** Object:  Table [Widget].[ActivityReplyParticipent]    Script Date: 16-12-2024 9.30.57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Widget].[ActivityReplyParticipent](
	[Id] [uniqueidentifier] NOT NULL,
	[ActivityReplyId] [uniqueidentifier] NOT NULL,
	[ParticipentId] [uniqueidentifier] NOT NULL,
	[Username] [nvarchar](254) NULL,
	[Name] [nvarchar](100) NULL,
	[Status] [int] NULL,
 CONSTRAINT [PK_ActivityReplyParticipent] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Widget].[ActivityReplyParticipent]  WITH CHECK ADD  CONSTRAINT [FK_ActivityReplyParticipent_ActivityReply] FOREIGN KEY([ActivityReplyId])
REFERENCES [Widget].[ActivityReply] ([Id])
GO
ALTER TABLE [Widget].[ActivityReplyParticipent] CHECK CONSTRAINT [FK_ActivityReplyParticipent_ActivityReply]
GO
ALTER TABLE [Widget].[ActivityReplyParticipent]  WITH CHECK ADD  CONSTRAINT [FK_ActivityReplyParticipent_UserAccount] FOREIGN KEY([ParticipentId])
REFERENCES [Auth].[UserAccount] ([Id])
GO
ALTER TABLE [Widget].[ActivityReplyParticipent] CHECK CONSTRAINT [FK_ActivityReplyParticipent_UserAccount]
GO
