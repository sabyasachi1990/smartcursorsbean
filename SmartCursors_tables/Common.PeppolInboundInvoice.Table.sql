USE [SmartCursorSTG]
GO
/****** Object:  Table [Common].[PeppolInboundInvoice]    Script Date: 16-12-2024 9.30.56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Common].[PeppolInboundInvoice](
	[Id] [uniqueidentifier] NOT NULL,
	[DocId] [uniqueidentifier] NULL,
	[SenderPeppolId] [nvarchar](50) NULL,
	[ReciverPeppolId] [nvarchar](50) NULL,
	[XmlFilepath] [nvarchar](max) NULL,
	[XMLFileData] [nvarchar](max) NULL,
	[UserCreated] [nvarchar](254) NULL,
	[CreatedDate] [datetime2](7) NULL,
	[Version] [smallint] NULL,
	[Status] [int] NULL,
	[IsBillGenerated] [bit] NULL,
	[ErrorMessage] [nvarchar](max) NULL,
 CONSTRAINT [PK_PeppolInboundInvoice] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [Common].[PeppolInboundInvoice] ADD  DEFAULT ((1)) FOR [Status]
GO
