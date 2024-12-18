USE [SmartCursorSTG]
GO
/****** Object:  Table [Widget].[ActivityAttachment]    Script Date: 16-12-2024 9.30.57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Widget].[ActivityAttachment](
	[Id] [uniqueidentifier] NOT NULL,
	[ActivityId] [uniqueidentifier] NOT NULL,
	[FileUploadId] [uniqueidentifier] NOT NULL,
	[FileName] [nvarchar](256) NULL,
	[FileFullPath] [nvarchar](1000) NULL,
 CONSTRAINT [PK_ActivityAttachment] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Widget].[ActivityAttachment]  WITH CHECK ADD  CONSTRAINT [FK_ActivityAttachment_Activity] FOREIGN KEY([ActivityId])
REFERENCES [Widget].[Activity] ([Id])
GO
ALTER TABLE [Widget].[ActivityAttachment] CHECK CONSTRAINT [FK_ActivityAttachment_Activity]
GO
ALTER TABLE [Widget].[ActivityAttachment]  WITH CHECK ADD  CONSTRAINT [FK_ActivityAttachment_MediaRepository] FOREIGN KEY([FileUploadId])
REFERENCES [Common].[MediaRepository] ([Id])
GO
ALTER TABLE [Widget].[ActivityAttachment] CHECK CONSTRAINT [FK_ActivityAttachment_MediaRepository]
GO
