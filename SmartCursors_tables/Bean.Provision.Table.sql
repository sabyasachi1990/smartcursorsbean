USE [SmartCursorSTG]
GO
/****** Object:  Table [Bean].[Provision]    Script Date: 16-12-2024 9.30.55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Bean].[Provision](
	[Id] [uniqueidentifier] NOT NULL,
	[RefDocumentId] [uniqueidentifier] NOT NULL,
	[CompanyId] [bigint] NOT NULL,
	[DocumentType] [nvarchar](20) NOT NULL,
	[DocumentDate] [datetime] NOT NULL,
	[DocNo] [nvarchar](25) NOT NULL,
	[Remarks] [nvarchar](1000) NULL,
	[IsNoSupportingDocument] [bit] NOT NULL,
	[NoSupportingDocument] [bit] NULL,
	[Currency] [nvarchar](5) NOT NULL,
	[Provisionamount] [money] NOT NULL,
	[IsAllowableDisallowable] [bit] NOT NULL,
	[IsDisAllow] [bit] NULL,
	[SystemRefNo] [nvarchar](25) NOT NULL,
	[UserCreated] [nvarchar](254) NULL,
	[CreatedDate] [datetime2](7) NULL,
	[ModifiedBy] [nvarchar](254) NULL,
	[ModifiedDate] [datetime2](7) NULL,
	[Status] [int] NULL,
	[RefDocType] [nvarchar](50) NULL,
 CONSTRAINT [PK_Provision] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Bean].[Provision]  WITH CHECK ADD  CONSTRAINT [FK_Provision_Company] FOREIGN KEY([CompanyId])
REFERENCES [Common].[Company] ([Id])
GO
ALTER TABLE [Bean].[Provision] CHECK CONSTRAINT [FK_Provision_Company]
GO
