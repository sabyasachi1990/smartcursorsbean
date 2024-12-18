USE [SmartCursorSTG]
GO
/****** Object:  Table [Tax].[SplitDetail]    Script Date: 16-12-2024 9.30.57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Tax].[SplitDetail](
	[Id] [uniqueidentifier] NOT NULL,
	[SplitId] [uniqueidentifier] NOT NULL,
	[Type] [nvarchar](250) NULL,
	[TypeId] [uniqueidentifier] NULL,
	[ReferenceScreen] [nvarchar](250) NULL,
	[ReferScreenType] [nvarchar](100) NULL,
 CONSTRAINT [PK_SplitDetail] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Tax].[SplitDetail]  WITH CHECK ADD  CONSTRAINT [PK_SplitDetail_Split] FOREIGN KEY([SplitId])
REFERENCES [Tax].[Split] ([Id])
GO
ALTER TABLE [Tax].[SplitDetail] CHECK CONSTRAINT [PK_SplitDetail_Split]
GO
