USE [SmartCursorSTG]
GO
/****** Object:  Table [Bean].[TaxCodeMappingDetail]    Script Date: 16-12-2024 9.30.55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Bean].[TaxCodeMappingDetail](
	[Id] [uniqueidentifier] NOT NULL,
	[TaxCodeMappingId] [uniqueidentifier] NULL,
	[CustTaxId] [bigint] NOT NULL,
	[VenTaxId] [bigint] NOT NULL,
	[CustTaxCode] [nvarchar](30) NULL,
	[VenTaxCode] [nvarchar](30) NULL,
	[Status] [int] NULL,
	[RecOrder] [int] NULL,
PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Bean].[TaxCodeMappingDetail]  WITH CHECK ADD  CONSTRAINT [Bean_COAMapping_TaxCode_CustTaxId] FOREIGN KEY([CustTaxId])
REFERENCES [Bean].[TaxCode] ([Id])
GO
ALTER TABLE [Bean].[TaxCodeMappingDetail] CHECK CONSTRAINT [Bean_COAMapping_TaxCode_CustTaxId]
GO
ALTER TABLE [Bean].[TaxCodeMappingDetail]  WITH CHECK ADD  CONSTRAINT [Bean_COAMapping_TaxCode_VenTaxId] FOREIGN KEY([VenTaxId])
REFERENCES [Bean].[TaxCode] ([Id])
GO
ALTER TABLE [Bean].[TaxCodeMappingDetail] CHECK CONSTRAINT [Bean_COAMapping_TaxCode_VenTaxId]
GO
