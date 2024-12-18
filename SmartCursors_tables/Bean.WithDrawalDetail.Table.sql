USE [SmartCursorSTG]
GO
/****** Object:  Table [Bean].[WithDrawalDetail]    Script Date: 16-12-2024 9.30.55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Bean].[WithDrawalDetail](
	[Id] [uniqueidentifier] NOT NULL,
	[WithdrawalId] [uniqueidentifier] NOT NULL,
	[COAId] [bigint] NOT NULL,
	[AllowDisAllow] [bit] NULL,
	[TaxId] [bigint] NULL,
	[TaxRate] [float] NULL,
	[DocAmount] [money] NOT NULL,
	[DocTaxAmount] [money] NULL,
	[DocTotalAmount] [money] NOT NULL,
	[BaseAmount] [money] NULL,
	[BaseTaxAmount] [money] NULL,
	[BaseTotalAmount] [money] NULL,
	[RecOrder] [int] NULL,
	[Currency] [nvarchar](5) NULL,
	[Description] [nvarchar](254) NULL,
	[IsPLAccount] [bit] NULL,
	[TaxIdCode] [nvarchar](20) NULL,
	[ClearingState] [nvarchar](50) NULL,
 CONSTRAINT [PK_WithDrawalDetail] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ADD SENSITIVITY CLASSIFICATION TO [Bean].[WithDrawalDetail].[TaxId] WITH (label = 'Confidential - GDPR', label_id = '6ceae8dd-fab8-4956-8764-b809b49281be', information_type = 'National ID', information_type_id = '6f5a11a7-08b1-19c3-59e5-8c89cf4f8444', rank = Medium);
GO
ADD SENSITIVITY CLASSIFICATION TO [Bean].[WithDrawalDetail].[TaxRate] WITH (label = 'Confidential', label_id = '281b9ab3-ecbb-4a57-8486-c702e44215d8', information_type = 'Financial', information_type_id = 'c44193e1-0e58-4b2a-9001-f7d6e7bc1373', rank = Medium);
GO
ADD SENSITIVITY CLASSIFICATION TO [Bean].[WithDrawalDetail].[DocAmount] WITH (label = 'Confidential', label_id = '281b9ab3-ecbb-4a57-8486-c702e44215d8', information_type = 'Financial', information_type_id = 'c44193e1-0e58-4b2a-9001-f7d6e7bc1373', rank = Medium);
GO
ADD SENSITIVITY CLASSIFICATION TO [Bean].[WithDrawalDetail].[DocTaxAmount] WITH (label = 'Confidential', label_id = '281b9ab3-ecbb-4a57-8486-c702e44215d8', information_type = 'Financial', information_type_id = 'c44193e1-0e58-4b2a-9001-f7d6e7bc1373', rank = Medium);
GO
ADD SENSITIVITY CLASSIFICATION TO [Bean].[WithDrawalDetail].[DocTotalAmount] WITH (label = 'Confidential', label_id = '281b9ab3-ecbb-4a57-8486-c702e44215d8', information_type = 'Financial', information_type_id = 'c44193e1-0e58-4b2a-9001-f7d6e7bc1373', rank = Medium);
GO
ADD SENSITIVITY CLASSIFICATION TO [Bean].[WithDrawalDetail].[BaseAmount] WITH (label = 'Confidential', label_id = '281b9ab3-ecbb-4a57-8486-c702e44215d8', information_type = 'Financial', information_type_id = 'c44193e1-0e58-4b2a-9001-f7d6e7bc1373', rank = Medium);
GO
ADD SENSITIVITY CLASSIFICATION TO [Bean].[WithDrawalDetail].[BaseTaxAmount] WITH (label = 'Confidential', label_id = '281b9ab3-ecbb-4a57-8486-c702e44215d8', information_type = 'Financial', information_type_id = 'c44193e1-0e58-4b2a-9001-f7d6e7bc1373', rank = Medium);
GO
ADD SENSITIVITY CLASSIFICATION TO [Bean].[WithDrawalDetail].[BaseTotalAmount] WITH (label = 'Confidential', label_id = '281b9ab3-ecbb-4a57-8486-c702e44215d8', information_type = 'Financial', information_type_id = 'c44193e1-0e58-4b2a-9001-f7d6e7bc1373', rank = Medium);
GO
ADD SENSITIVITY CLASSIFICATION TO [Bean].[WithDrawalDetail].[Currency] WITH (label = 'Confidential', label_id = '281b9ab3-ecbb-4a57-8486-c702e44215d8', information_type = 'Financial', information_type_id = 'c44193e1-0e58-4b2a-9001-f7d6e7bc1373', rank = Medium);
GO
ADD SENSITIVITY CLASSIFICATION TO [Bean].[WithDrawalDetail].[TaxIdCode] WITH (label = 'Confidential - GDPR', label_id = '6ceae8dd-fab8-4956-8764-b809b49281be', information_type = 'National ID', information_type_id = '6f5a11a7-08b1-19c3-59e5-8c89cf4f8444', rank = Medium);
GO
ALTER TABLE [Bean].[WithDrawalDetail] ADD  DEFAULT (NULL) FOR [RecOrder]
GO
ALTER TABLE [Bean].[WithDrawalDetail]  WITH CHECK ADD  CONSTRAINT [FK_WithDrawalDetail_ChartOfAccount] FOREIGN KEY([COAId])
REFERENCES [Bean].[ChartOfAccount] ([Id])
GO
ALTER TABLE [Bean].[WithDrawalDetail] CHECK CONSTRAINT [FK_WithDrawalDetail_ChartOfAccount]
GO
ALTER TABLE [Bean].[WithDrawalDetail]  WITH CHECK ADD  CONSTRAINT [fk_WithDrawalDetail_TaxCode] FOREIGN KEY([TaxId])
REFERENCES [Bean].[TaxCode] ([Id])
GO
ALTER TABLE [Bean].[WithDrawalDetail] CHECK CONSTRAINT [fk_WithDrawalDetail_TaxCode]
GO
ALTER TABLE [Bean].[WithDrawalDetail]  WITH CHECK ADD  CONSTRAINT [FK_WithDrawalDetail_WithDrawal] FOREIGN KEY([WithdrawalId])
REFERENCES [Bean].[WithDrawal] ([Id])
GO
ALTER TABLE [Bean].[WithDrawalDetail] CHECK CONSTRAINT [FK_WithDrawalDetail_WithDrawal]
GO
