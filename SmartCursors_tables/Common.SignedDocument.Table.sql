USE [SmartCursorSTG]
GO
/****** Object:  Table [Common].[SignedDocument]    Script Date: 16-12-2024 9.30.56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Common].[SignedDocument](
	[Id] [uniqueidentifier] NOT NULL,
	[CompanyUserId] [bigint] NULL,
	[ModuleId] [bigint] NULL,
	[DocumentURL] [nvarchar](max) NULL,
	[DocumentName] [nvarchar](max) NULL,
	[EnvelopId] [uniqueidentifier] NULL,
	[EmailSubject] [nvarchar](max) NULL,
	[CompanyId] [bigint] NULL,
	[CreatedDate] [datetime2](7) NULL,
	[ModifiedDate] [datetime2](7) NULL,
	[FileSize] [nvarchar](max) NULL,
	[CommunicationId] [uniqueidentifier] NULL,
 CONSTRAINT [PK_SignedDocument] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
