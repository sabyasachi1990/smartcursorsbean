USE [SmartCursorSTG]
GO
/****** Object:  Table [Common].[TemplateTypeDetail]    Script Date: 16-12-2024 9.30.56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Common].[TemplateTypeDetail](
	[Id] [uniqueidentifier] NOT NULL,
	[TemplateTypeId] [uniqueidentifier] NOT NULL,
	[ViewModelName] [nvarchar](100) NOT NULL,
	[ViewModelJson] [nvarchar](4000) NOT NULL,
	[RecOrder] [int] NULL,
	[Status] [int] NULL,
	[IsShow] [bit] NULL,
	[NewViewModelName] [nvarchar](256) NULL,
 CONSTRAINT [PK_TemplateTypeDetail] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Common].[TemplateTypeDetail] ADD  DEFAULT ((1)) FOR [Status]
GO
ALTER TABLE [Common].[TemplateTypeDetail]  WITH CHECK ADD  CONSTRAINT [FK_TemplateTypeDetail_TemplateType] FOREIGN KEY([TemplateTypeId])
REFERENCES [Common].[TemplateType] ([Id])
GO
ALTER TABLE [Common].[TemplateTypeDetail] CHECK CONSTRAINT [FK_TemplateTypeDetail_TemplateType]
GO
