USE [SmartCursorSTG]
GO
/****** Object:  Table [Bean].[BillGSTDetail]    Script Date: 16-12-2024 9.30.55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Bean].[BillGSTDetail](
	[Id] [uniqueidentifier] NOT NULL,
	[BillId] [uniqueidentifier] NOT NULL,
	[TaxId] [bigint] NOT NULL,
	[TaxCode] [nvarchar](20) NOT NULL,
	[Amount] [money] NOT NULL,
	[TaxAmount] [money] NOT NULL,
	[Total] [money] NOT NULL,
 CONSTRAINT [PK_BillGSTDetail] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ADD SENSITIVITY CLASSIFICATION TO [Bean].[BillGSTDetail].[TaxId] WITH (label = 'Confidential - GDPR', label_id = '6ceae8dd-fab8-4956-8764-b809b49281be', information_type = 'National ID', information_type_id = '6f5a11a7-08b1-19c3-59e5-8c89cf4f8444', rank = Medium);
GO
ADD SENSITIVITY CLASSIFICATION TO [Bean].[BillGSTDetail].[TaxCode] WITH (label = 'Confidential', label_id = '281b9ab3-ecbb-4a57-8486-c702e44215d8', information_type = 'Financial', information_type_id = 'c44193e1-0e58-4b2a-9001-f7d6e7bc1373', rank = Medium);
GO
ADD SENSITIVITY CLASSIFICATION TO [Bean].[BillGSTDetail].[Amount] WITH (label = 'Confidential', label_id = '281b9ab3-ecbb-4a57-8486-c702e44215d8', information_type = 'Financial', information_type_id = 'c44193e1-0e58-4b2a-9001-f7d6e7bc1373', rank = Medium);
GO
ADD SENSITIVITY CLASSIFICATION TO [Bean].[BillGSTDetail].[TaxAmount] WITH (label = 'Confidential', label_id = '281b9ab3-ecbb-4a57-8486-c702e44215d8', information_type = 'Financial', information_type_id = 'c44193e1-0e58-4b2a-9001-f7d6e7bc1373', rank = Medium);
GO
ALTER TABLE [Bean].[BillGSTDetail]  WITH CHECK ADD  CONSTRAINT [FK_BillGSTDetail_Bill] FOREIGN KEY([BillId])
REFERENCES [Bean].[Bill] ([Id])
GO
ALTER TABLE [Bean].[BillGSTDetail] CHECK CONSTRAINT [FK_BillGSTDetail_Bill]
GO
ALTER TABLE [Bean].[BillGSTDetail]  WITH CHECK ADD  CONSTRAINT [FK_BillGSTDetail_TaxCode] FOREIGN KEY([TaxId])
REFERENCES [Bean].[TaxCode] ([Id])
GO
ALTER TABLE [Bean].[BillGSTDetail] CHECK CONSTRAINT [FK_BillGSTDetail_TaxCode]
GO
