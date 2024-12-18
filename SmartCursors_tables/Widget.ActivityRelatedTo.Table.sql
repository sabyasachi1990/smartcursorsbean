USE [SmartCursorSTG]
GO
/****** Object:  Table [Widget].[ActivityRelatedTo]    Script Date: 16-12-2024 9.30.57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Widget].[ActivityRelatedTo](
	[Id] [uniqueidentifier] NOT NULL,
	[ActivityId] [uniqueidentifier] NOT NULL,
	[EntityType] [nvarchar](200) NULL,
	[EntityId] [uniqueidentifier] NULL,
	[EntityIdInt] [bigint] NULL,
	[EntityName] [nvarchar](256) NULL,
	[Relation] [nvarchar](20) NULL,
 CONSTRAINT [PK_ActivityRelatedTo] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Widget].[ActivityRelatedTo]  WITH CHECK ADD  CONSTRAINT [FK_ActivityRelatedTo_Activity] FOREIGN KEY([ActivityId])
REFERENCES [Widget].[Activity] ([Id])
GO
ALTER TABLE [Widget].[ActivityRelatedTo] CHECK CONSTRAINT [FK_ActivityRelatedTo_Activity]
GO
