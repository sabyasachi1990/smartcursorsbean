USE [SmartCursorSTG]
GO
/****** Object:  Table [Widget].[RelatedLinksDetail]    Script Date: 16-12-2024 9.30.57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Widget].[RelatedLinksDetail](
	[Id] [bigint] NOT NULL,
	[MasterId] [bigint] NOT NULL,
	[Icon] [nvarchar](1000) NULL,
	[Text] [nvarchar](100) NOT NULL,
	[Url] [nvarchar](1000) NOT NULL,
	[Order] [int] NOT NULL,
	[RecOrder] [int] NULL,
	[UserCreated] [nvarchar](128) NULL,
	[CreatedDate] [datetime2](7) NULL,
	[Status] [int] NULL,
	[ModuleDetailId] [bigint] NULL,
 CONSTRAINT [PK_RelatedLinksDetail] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Widget].[RelatedLinksDetail] ADD  DEFAULT ((1)) FOR [Status]
GO
ALTER TABLE [Widget].[RelatedLinksDetail]  WITH CHECK ADD  CONSTRAINT [FK_RelatedLinksDetail_RelatedLinksMaster] FOREIGN KEY([MasterId])
REFERENCES [Widget].[RelatedLinksMaster] ([Id])
GO
ALTER TABLE [Widget].[RelatedLinksDetail] CHECK CONSTRAINT [FK_RelatedLinksDetail_RelatedLinksMaster]
GO
