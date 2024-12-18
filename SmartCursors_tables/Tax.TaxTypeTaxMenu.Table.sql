USE [SmartCursorSTG]
GO
/****** Object:  Table [Tax].[TaxTypeTaxMenu]    Script Date: 16-12-2024 9.30.57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Tax].[TaxTypeTaxMenu](
	[Id] [uniqueidentifier] NOT NULL,
	[TaxType] [nvarchar](50) NULL,
	[TaxMenuMasterId] [uniqueidentifier] NOT NULL,
 CONSTRAINT [PK_TaxTypeTaxMenu] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ADD SENSITIVITY CLASSIFICATION TO [Tax].[TaxTypeTaxMenu].[TaxType] WITH (label = 'Confidential', label_id = '281b9ab3-ecbb-4a57-8486-c702e44215d8', information_type = 'Financial', information_type_id = 'c44193e1-0e58-4b2a-9001-f7d6e7bc1373', rank = Medium);
GO
ALTER TABLE [Tax].[TaxTypeTaxMenu]  WITH CHECK ADD  CONSTRAINT [FK_TaxTypeTaxMenu_TaxMenuMaster] FOREIGN KEY([TaxMenuMasterId])
REFERENCES [Tax].[TaxMenuMaster] ([Id])
GO
ALTER TABLE [Tax].[TaxTypeTaxMenu] CHECK CONSTRAINT [FK_TaxTypeTaxMenu_TaxMenuMaster]
GO
