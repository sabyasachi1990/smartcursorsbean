USE [SmartCursorSTG]
GO
/****** Object:  Table [Common].[GenericTemplateDetail]    Script Date: 16-12-2024 9.30.56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Common].[GenericTemplateDetail](
	[Id] [uniqueidentifier] NOT NULL,
	[GenericTemplateId] [uniqueidentifier] NOT NULL,
	[Name] [nvarchar](100) NULL,
	[Activity] [nvarchar](1000) NULL,
	[MenuId] [uniqueidentifier] NULL,
	[SubMenuId] [uniqueidentifier] NULL,
 CONSTRAINT [Pk_GenericTemplateDetail] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Common].[GenericTemplateDetail]  WITH CHECK ADD  CONSTRAINT [FK_GenericTemplateDetail] FOREIGN KEY([GenericTemplateId])
REFERENCES [Common].[GenericTemplate] ([Id])
GO
ALTER TABLE [Common].[GenericTemplateDetail] CHECK CONSTRAINT [FK_GenericTemplateDetail]
GO
