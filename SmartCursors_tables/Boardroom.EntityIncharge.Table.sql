USE [SmartCursorSTG]
GO
/****** Object:  Table [Boardroom].[EntityIncharge]    Script Date: 16-12-2024 9.30.56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Boardroom].[EntityIncharge](
	[Id] [uniqueidentifier] NOT NULL,
	[EntityId] [uniqueidentifier] NOT NULL,
	[UserAccountId] [uniqueidentifier] NOT NULL,
 CONSTRAINT [PK_EntityIncharge] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Boardroom].[EntityIncharge]  WITH CHECK ADD  CONSTRAINT [FK_EntityIncharge_EntityId] FOREIGN KEY([EntityId])
REFERENCES [Common].[EntityDetail] ([Id])
GO
ALTER TABLE [Boardroom].[EntityIncharge] CHECK CONSTRAINT [FK_EntityIncharge_EntityId]
GO
