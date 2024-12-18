USE [SmartCursorSTG]
GO
/****** Object:  Table [ClientCursor].[QuotationSummaryDetails]    Script Date: 16-12-2024 9.30.56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [ClientCursor].[QuotationSummaryDetails](
	[Id] [uniqueidentifier] NOT NULL,
	[QuotationId] [uniqueidentifier] NOT NULL,
	[TemplateName] [nvarchar](max) NULL,
	[TemplateCode] [nvarchar](max) NULL,
	[TemplateContent] [nvarchar](max) NULL,
	[IsLandscape] [bit] NULL,
 CONSTRAINT [PK_QuotaionSummeryDetails] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [ClientCursor].[QuotationSummaryDetails] ADD  DEFAULT ((0)) FOR [IsLandscape]
GO
ALTER TABLE [ClientCursor].[QuotationSummaryDetails]  WITH CHECK ADD  CONSTRAINT [FK_QuotationSummeryDetail_Quotation] FOREIGN KEY([QuotationId])
REFERENCES [ClientCursor].[Quotation] ([Id])
GO
ALTER TABLE [ClientCursor].[QuotationSummaryDetails] CHECK CONSTRAINT [FK_QuotationSummeryDetail_Quotation]
GO
