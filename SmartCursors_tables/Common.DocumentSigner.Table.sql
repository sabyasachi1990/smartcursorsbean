USE [SmartCursorSTG]
GO
/****** Object:  Table [Common].[DocumentSigner]    Script Date: 16-12-2024 9.30.56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Common].[DocumentSigner](
	[Id] [uniqueidentifier] NOT NULL,
	[DocumentId] [uniqueidentifier] NOT NULL,
	[Email] [nvarchar](50) NULL,
	[PageNo] [nvarchar](max) NULL,
	[Xvalue] [nvarchar](max) NULL,
	[Yvalue] [nvarchar](max) NULL,
	[SigningPosition] [nvarchar](max) NULL,
	[Name] [nvarchar](max) NULL,
	[CreatedDate] [datetime2](7) NULL,
	[RecOrder] [int] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [Common].[DocumentSigner] ADD  CONSTRAINT [df_Recconstraint]  DEFAULT ((0)) FOR [RecOrder]
GO
ALTER TABLE [Common].[DocumentSigner]  WITH CHECK ADD  CONSTRAINT [FK_SignedDocument_DocumentSigner] FOREIGN KEY([DocumentId])
REFERENCES [Common].[SignedDocument] ([Id])
GO
ALTER TABLE [Common].[DocumentSigner] CHECK CONSTRAINT [FK_SignedDocument_DocumentSigner]
GO
