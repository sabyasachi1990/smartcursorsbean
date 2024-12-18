USE [SmartCursorSTG]
GO
/****** Object:  Table [Boardroom].[DynamicTemplates]    Script Date: 16-12-2024 9.30.56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Boardroom].[DynamicTemplates](
	[Id] [uniqueidentifier] NOT NULL,
	[RefNo] [nvarchar](100) NOT NULL,
	[EntityId] [uniqueidentifier] NOT NULL,
	[MenuId] [uniqueidentifier] NULL,
	[MenuName] [nvarchar](500) NULL,
	[State] [nvarchar](200) NOT NULL,
	[Status] [int] NOT NULL,
	[UserCreated] [nvarchar](256) NULL,
	[CreatedDate] [datetime2](7) NULL,
	[ModifiedBy] [nvarchar](256) NULL,
	[ModifiedDate] [datetime2](7) NULL,
	[IncorporationDate] [datetime2](7) NULL,
	[TemplateType] [nvarchar](30) NULL,
	[EntityName] [nvarchar](30) NULL,
	[DocStatus] [nvarchar](30) NULL,
	[RedirectURL] [nvarchar](500) NULL,
	[RedirectURLParams] [nvarchar](250) NULL,
	[Remarks] [nvarchar](250) NULL,
	[EffectiveDateOfChange] [datetime2](7) NULL,
 CONSTRAINT [PK_DynamicTemplates] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Boardroom].[DynamicTemplates]  WITH CHECK ADD  CONSTRAINT [FK_DynamicTemplates_EntityDetail] FOREIGN KEY([EntityId])
REFERENCES [Common].[EntityDetail] ([Id])
GO
ALTER TABLE [Boardroom].[DynamicTemplates] CHECK CONSTRAINT [FK_DynamicTemplates_EntityDetail]
GO
