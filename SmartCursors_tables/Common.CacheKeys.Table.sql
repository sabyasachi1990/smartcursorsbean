USE [SmartCursorSTG]
GO
/****** Object:  Table [Common].[CacheKeys]    Script Date: 16-12-2024 9.30.56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Common].[CacheKeys](
	[Id] [uniqueidentifier] NOT NULL,
	[ModuleDetailId] [bigint] NULL,
	[Type] [nvarchar](50) NULL,
	[SubType] [nvarchar](100) NULL,
	[CacheKeys] [nvarchar](max) NULL,
	[CreatedDate] [datetime2](7) NULL,
 CONSTRAINT [PK_CacheKeys] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [Common].[CacheKeys] ADD  DEFAULT (getdate()) FOR [CreatedDate]
GO
ALTER TABLE [Common].[CacheKeys]  WITH CHECK ADD  CONSTRAINT [FK_CacheKeys_ModuleDetail] FOREIGN KEY([ModuleDetailId])
REFERENCES [Common].[ModuleDetail] ([Id])
GO
ALTER TABLE [Common].[CacheKeys] CHECK CONSTRAINT [FK_CacheKeys_ModuleDetail]
GO
