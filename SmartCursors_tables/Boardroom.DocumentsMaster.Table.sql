USE [SmartCursorSTG]
GO
/****** Object:  Table [Boardroom].[DocumentsMaster]    Script Date: 16-12-2024 9.30.56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Boardroom].[DocumentsMaster](
	[Id] [uniqueidentifier] NOT NULL,
	[EntityId] [uniqueidentifier] NOT NULL,
	[CompanyId] [bigint] NOT NULL,
	[Type] [nvarchar](50) NOT NULL,
	[Status] [nvarchar](15) NULL,
	[UserCreated] [nvarchar](254) NULL,
	[CreatedDate] [datetime2](7) NULL,
	[NoofDocuments] [bigint] NULL,
	[TemplateAction] [nvarchar](1000) NULL,
	[Description] [nvarchar](max) NULL,
	[GenericTemplateId] [uniqueidentifier] NULL,
	[DocId] [uniqueidentifier] NULL,
	[TemplateContent] [nvarchar](max) NULL,
 CONSTRAINT [PK_DcumentsMaster] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [Boardroom].[DocumentsMaster]  WITH CHECK ADD FOREIGN KEY([GenericTemplateId])
REFERENCES [Common].[GenericTemplate] ([Id])
GO
