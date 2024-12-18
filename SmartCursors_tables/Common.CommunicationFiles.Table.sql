USE [SmartCursorSTG]
GO
/****** Object:  Table [Common].[CommunicationFiles]    Script Date: 16-12-2024 9.30.56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Common].[CommunicationFiles](
	[Id] [uniqueidentifier] NOT NULL,
	[CommunicationId] [uniqueidentifier] NOT NULL,
	[FilePath] [nvarchar](1000) NULL,
	[FileName] [nvarchar](1000) NULL,
	[AzurePath] [nvarchar](1000) NULL,
	[IsSystem] [bit] NULL,
	[TemplateContent] [nvarchar](max) NULL,
	[IsDocusignSetup] [bit] NULL,
 CONSTRAINT [PK_common.CommunicationDetail] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [Common].[CommunicationFiles]  WITH CHECK ADD  CONSTRAINT [PK_Common.CommunicationDetail_Package] FOREIGN KEY([CommunicationId])
REFERENCES [Common].[Communication] ([Id])
GO
ALTER TABLE [Common].[CommunicationFiles] CHECK CONSTRAINT [PK_Common.CommunicationDetail_Package]
GO
