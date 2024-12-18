USE [SmartCursorSTG]
GO
/****** Object:  Table [Boardroom].[TemplateSent]    Script Date: 16-12-2024 9.30.56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Boardroom].[TemplateSent](
	[Id] [uniqueidentifier] NOT NULL,
	[EntityId] [uniqueidentifier] NOT NULL,
	[CompanyId] [bigint] NOT NULL,
	[Type] [nvarchar](100) NULL,
	[FromEmail] [nvarchar](100) NULL,
	[ToEmail] [nvarchar](100) NULL,
	[CC] [nvarchar](100) NULL,
	[Bcc] [nvarchar](100) NULL,
	[Subject] [nvarchar](1000) NULL,
	[Emailbody] [nvarchar](max) NULL,
	[FileName] [nvarchar](500) NULL,
	[FilePath] [nvarchar](500) NULL,
	[AzurePath] [nvarchar](500) NULL,
	[TemplateCode] [nvarchar](200) NULL,
	[TemplateName] [nvarchar](200) NULL,
	[UserCreated] [nvarchar](100) NULL,
	[CreatedDate] [datetime2](7) NULL,
 CONSTRAINT [PK_Boardroom.TemplateSent] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [Boardroom].[TemplateSent]  WITH CHECK ADD  CONSTRAINT [PK_Common.TemplateSent_EntityDetail] FOREIGN KEY([EntityId])
REFERENCES [Common].[EntityDetail] ([Id])
GO
ALTER TABLE [Boardroom].[TemplateSent] CHECK CONSTRAINT [PK_Common.TemplateSent_EntityDetail]
GO
