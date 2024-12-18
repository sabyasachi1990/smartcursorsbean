USE [SmartCursorSTG]
GO
/****** Object:  Table [Common].[TemplateSent]    Script Date: 16-12-2024 9.30.56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Common].[TemplateSent](
	[Id] [uniqueidentifier] NOT NULL,
	[TemplateId] [uniqueidentifier] NOT NULL,
	[FromEmail] [nvarchar](100) NULL,
	[ToEmail] [nvarchar](100) NULL,
	[Subject] [nvarchar](1000) NULL,
	[RelationType] [nvarchar](50) NULL,
	[RelationId] [uniqueidentifier] NULL,
	[UserCreated] [nvarchar](100) NULL,
	[CreatedDate] [datetime2](7) NULL,
 CONSTRAINT [PK_TemplateSent] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Common].[TemplateSent]  WITH CHECK ADD  CONSTRAINT [FK_TemplateSent_GenericTemplate] FOREIGN KEY([TemplateId])
REFERENCES [Common].[GenericTemplate] ([Id])
GO
ALTER TABLE [Common].[TemplateSent] CHECK CONSTRAINT [FK_TemplateSent_GenericTemplate]
GO
