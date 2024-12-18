USE [SmartCursorSTG]
GO
/****** Object:  Table [ClientCursor].[QuotationDetailTemplate]    Script Date: 16-12-2024 9.30.56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [ClientCursor].[QuotationDetailTemplate](
	[Id] [uniqueidentifier] NOT NULL,
	[QuotationDetailId] [uniqueidentifier] NOT NULL,
	[TemplateId] [uniqueidentifier] NOT NULL,
	[TemplateContent] [nvarchar](max) NULL,
	[RecOrder] [int] NULL,
 CONSTRAINT [PK_QuotationDetailTemplate] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [ClientCursor].[QuotationDetailTemplate]  WITH CHECK ADD  CONSTRAINT [FK_QuotationDetailTemplate_GenericTemplate] FOREIGN KEY([TemplateId])
REFERENCES [Common].[GenericTemplate] ([Id])
GO
ALTER TABLE [ClientCursor].[QuotationDetailTemplate] CHECK CONSTRAINT [FK_QuotationDetailTemplate_GenericTemplate]
GO
ALTER TABLE [ClientCursor].[QuotationDetailTemplate]  WITH CHECK ADD  CONSTRAINT [FK_QuotationDetailTemplate_QuotationDetail] FOREIGN KEY([QuotationDetailId])
REFERENCES [ClientCursor].[QuotationDetail] ([Id])
GO
ALTER TABLE [ClientCursor].[QuotationDetailTemplate] CHECK CONSTRAINT [FK_QuotationDetailTemplate_QuotationDetail]
GO
