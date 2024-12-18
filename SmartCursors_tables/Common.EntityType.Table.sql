USE [SmartCursorSTG]
GO
/****** Object:  Table [Common].[EntityType]    Script Date: 16-12-2024 9.30.56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Common].[EntityType](
	[Id] [uniqueidentifier] NOT NULL,
	[CompanyId] [bigint] NOT NULL,
	[EntityName] [nvarchar](100) NOT NULL,
	[EntityQualifiedNameSpace] [nvarchar](255) NULL,
	[RelatedToData] [nvarchar](255) NULL,
	[IsTemplate] [bit] NULL,
	[Status] [int] NULL,
 CONSTRAINT [PK_EntityType] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Common].[EntityType] ADD  DEFAULT ((1)) FOR [Status]
GO
ALTER TABLE [Common].[EntityType]  WITH CHECK ADD  CONSTRAINT [FK_EntityType_Company] FOREIGN KEY([CompanyId])
REFERENCES [Common].[Company] ([Id])
GO
ALTER TABLE [Common].[EntityType] CHECK CONSTRAINT [FK_EntityType_Company]
GO
