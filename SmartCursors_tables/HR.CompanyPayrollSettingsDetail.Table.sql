USE [SmartCursorSTG]
GO
/****** Object:  Table [HR].[CompanyPayrollSettingsDetail]    Script Date: 16-12-2024 9.30.56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [HR].[CompanyPayrollSettingsDetail](
	[Id] [uniqueidentifier] NOT NULL,
	[MasterId] [uniqueidentifier] NULL,
	[CurrencyCode] [nvarchar](50) NULL,
	[BankId] [uniqueidentifier] NOT NULL,
	[Status] [int] NULL,
	[AccountNumber] [nvarchar](50) NULL,
 CONSTRAINT [PK_CompanyPayrollSettingsDetail] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ADD SENSITIVITY CLASSIFICATION TO [HR].[CompanyPayrollSettingsDetail].[CurrencyCode] WITH (label = 'Confidential', label_id = '281b9ab3-ecbb-4a57-8486-c702e44215d8', information_type = 'Financial', information_type_id = 'c44193e1-0e58-4b2a-9001-f7d6e7bc1373', rank = Medium);
GO
ADD SENSITIVITY CLASSIFICATION TO [HR].[CompanyPayrollSettingsDetail].[AccountNumber] WITH (label = 'Confidential', label_id = '281b9ab3-ecbb-4a57-8486-c702e44215d8', information_type = 'Financial', information_type_id = 'c44193e1-0e58-4b2a-9001-f7d6e7bc1373', rank = Medium);
GO
ALTER TABLE [HR].[CompanyPayrollSettingsDetail] ADD  DEFAULT ((1)) FOR [Status]
GO
ALTER TABLE [HR].[CompanyPayrollSettingsDetail]  WITH CHECK ADD  CONSTRAINT [FK_CompanyPayrollSettingsDetail_Bank] FOREIGN KEY([BankId])
REFERENCES [Common].[Bank] ([Id])
GO
ALTER TABLE [HR].[CompanyPayrollSettingsDetail] CHECK CONSTRAINT [FK_CompanyPayrollSettingsDetail_Bank]
GO
ALTER TABLE [HR].[CompanyPayrollSettingsDetail]  WITH CHECK ADD  CONSTRAINT [FK_CompanyPayrollSettingsDetail_CompanyPayrollSettings] FOREIGN KEY([MasterId])
REFERENCES [HR].[CompanyPayrollSettings] ([Id])
GO
ALTER TABLE [HR].[CompanyPayrollSettingsDetail] CHECK CONSTRAINT [FK_CompanyPayrollSettingsDetail_CompanyPayrollSettings]
GO
