USE [SmartCursorSTG]
GO
/****** Object:  Table [Widget].[RelatedLinksMaster]    Script Date: 16-12-2024 9.30.57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Widget].[RelatedLinksMaster](
	[Id] [bigint] NOT NULL,
	[UrlContext] [nvarchar](1000) NULL,
	[Parameter] [nvarchar](1000) NULL,
	[HashTag] [nvarchar](256) NOT NULL,
	[CompanyId] [bigint] NOT NULL,
	[Icon] [nvarchar](2000) NULL,
	[FontAwesome] [nvarchar](100) NULL,
	[Heading] [nvarchar](100) NULL,
	[ModuleName] [nvarchar](50) NULL,
	[RecOrder] [int] NULL,
	[Remarks] [nvarchar](256) NULL,
	[Status] [int] NULL,
	[ModuleDetailId] [bigint] NULL,
 CONSTRAINT [PK_RelatedLinksMaster] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Widget].[RelatedLinksMaster] ADD  DEFAULT ((1)) FOR [Status]
GO
ALTER TABLE [Widget].[RelatedLinksMaster]  WITH CHECK ADD  CONSTRAINT [FK_RelatedLinksMaster_Company] FOREIGN KEY([CompanyId])
REFERENCES [Common].[Company] ([Id])
GO
ALTER TABLE [Widget].[RelatedLinksMaster] CHECK CONSTRAINT [FK_RelatedLinksMaster_Company]
GO
