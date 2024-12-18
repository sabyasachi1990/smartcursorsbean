USE [SmartCursorSTG]
GO
/****** Object:  Table [Common].[EntityTypeVariables_ToBeDeleted]    Script Date: 16-12-2024 9.30.56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Common].[EntityTypeVariables_ToBeDeleted](
	[Id] [uniqueidentifier] NOT NULL,
	[ObjectName] [nvarchar](100) NULL,
	[PropertyName] [nvarchar](20) NOT NULL,
	[EntityTypeId] [uniqueidentifier] NOT NULL,
	[Status] [int] NULL,
 CONSTRAINT [PK_EntityTypeVariables] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Common].[EntityTypeVariables_ToBeDeleted] ADD  DEFAULT ((1)) FOR [Status]
GO
ALTER TABLE [Common].[EntityTypeVariables_ToBeDeleted]  WITH CHECK ADD  CONSTRAINT [FK_TemplateVariableDetail_EntityType] FOREIGN KEY([EntityTypeId])
REFERENCES [Common].[EntityType] ([Id])
ON DELETE CASCADE
GO
ALTER TABLE [Common].[EntityTypeVariables_ToBeDeleted] CHECK CONSTRAINT [FK_TemplateVariableDetail_EntityType]
GO
