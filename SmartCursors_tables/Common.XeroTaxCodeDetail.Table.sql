USE [SmartCursorSTG]
GO
/****** Object:  Table [Common].[XeroTaxCodeDetail]    Script Date: 16-12-2024 9.30.56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Common].[XeroTaxCodeDetail](
	[Id] [uniqueidentifier] NOT NULL,
	[XeroTaxCodeId] [uniqueidentifier] NOT NULL,
	[BeanTaxCodeId] [bigint] NOT NULL,
 CONSTRAINT [PK_XeroTaxCodeDetail] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Common].[XeroTaxCodeDetail]  WITH CHECK ADD  CONSTRAINT [FK_XeroTaxCodeDetail_BeanTaxCodeId] FOREIGN KEY([BeanTaxCodeId])
REFERENCES [Bean].[TaxCode] ([Id])
GO
ALTER TABLE [Common].[XeroTaxCodeDetail] CHECK CONSTRAINT [FK_XeroTaxCodeDetail_BeanTaxCodeId]
GO
ALTER TABLE [Common].[XeroTaxCodeDetail]  WITH CHECK ADD  CONSTRAINT [FK_XeroTaxCodeDetail_XeroTaxCodeId] FOREIGN KEY([XeroTaxCodeId])
REFERENCES [Common].[XeroTaxCodes] ([Id])
GO
ALTER TABLE [Common].[XeroTaxCodeDetail] CHECK CONSTRAINT [FK_XeroTaxCodeDetail_XeroTaxCodeId]
GO
