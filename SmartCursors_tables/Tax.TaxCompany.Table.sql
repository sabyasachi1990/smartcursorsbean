USE [SmartCursorSTG]
GO
/****** Object:  Table [Tax].[TaxCompany]    Script Date: 16-12-2024 9.30.57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Tax].[TaxCompany](
	[Id] [uniqueidentifier] NOT NULL,
	[CompanyId] [bigint] NOT NULL,
	[ServiceCompanyId] [bigint] NOT NULL,
	[TaxCompanyTypeId] [bigint] NULL,
	[TaxCompanyIdTypeId] [bigint] NULL,
	[IdtypeId] [bigint] NULL,
	[TaxCompanyIdNo] [nvarchar](50) NULL,
	[TaxCompanySourceId] [bigint] NULL,
	[TermsOfPaymentId] [bigint] NULL,
	[CountryOfIncorporation] [nvarchar](100) NULL,
	[FinancialYearEnd] [datetime2](7) NULL,
	[IncorporationDate] [datetime2](7) NULL,
	[RecOrder] [int] NULL,
	[Remarks] [nvarchar](256) NULL,
	[UserCreated] [nvarchar](254) NULL,
	[CreatedDate] [datetime2](7) NULL,
	[ModifiedBy] [nvarchar](254) NULL,
	[ModifiedDate] [datetime2](7) NULL,
	[Version] [smallint] NULL,
	[Status] [int] NULL,
	[TypeOfEntity] [bigint] NULL,
 CONSTRAINT [PK_TaxCompany] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ADD SENSITIVITY CLASSIFICATION TO [Tax].[TaxCompany].[TaxCompanyTypeId] WITH (label = 'Confidential - GDPR', label_id = '6ceae8dd-fab8-4956-8764-b809b49281be', information_type = 'National ID', information_type_id = '6f5a11a7-08b1-19c3-59e5-8c89cf4f8444', rank = Medium);
GO
ADD SENSITIVITY CLASSIFICATION TO [Tax].[TaxCompany].[TaxCompanyIdTypeId] WITH (label = 'Confidential - GDPR', label_id = '6ceae8dd-fab8-4956-8764-b809b49281be', information_type = 'National ID', information_type_id = '6f5a11a7-08b1-19c3-59e5-8c89cf4f8444', rank = Medium);
GO
ADD SENSITIVITY CLASSIFICATION TO [Tax].[TaxCompany].[TaxCompanyIdNo] WITH (label = 'Confidential - GDPR', label_id = '6ceae8dd-fab8-4956-8764-b809b49281be', information_type = 'National ID', information_type_id = '6f5a11a7-08b1-19c3-59e5-8c89cf4f8444', rank = Medium);
GO
ADD SENSITIVITY CLASSIFICATION TO [Tax].[TaxCompany].[TaxCompanySourceId] WITH (label = 'Confidential - GDPR', label_id = '6ceae8dd-fab8-4956-8764-b809b49281be', information_type = 'National ID', information_type_id = '6f5a11a7-08b1-19c3-59e5-8c89cf4f8444', rank = Medium);
GO
ADD SENSITIVITY CLASSIFICATION TO [Tax].[TaxCompany].[TermsOfPaymentId] WITH (label = 'Confidential', label_id = '281b9ab3-ecbb-4a57-8486-c702e44215d8', information_type = 'Financial', information_type_id = 'c44193e1-0e58-4b2a-9001-f7d6e7bc1373', rank = Medium);
GO
ALTER TABLE [Tax].[TaxCompany] ADD  DEFAULT ((1)) FOR [Status]
GO
ALTER TABLE [Tax].[TaxCompany]  WITH CHECK ADD  CONSTRAINT [FK_TaxCompany_AccountSource] FOREIGN KEY([TaxCompanySourceId])
REFERENCES [Common].[AccountSource_ToBeDeleted] ([Id])
GO
ALTER TABLE [Tax].[TaxCompany] CHECK CONSTRAINT [FK_TaxCompany_AccountSource]
GO
ALTER TABLE [Tax].[TaxCompany]  WITH CHECK ADD  CONSTRAINT [FK_TaxCompany_AccountType] FOREIGN KEY([TaxCompanyTypeId])
REFERENCES [Common].[AccountType] ([Id])
GO
ALTER TABLE [Tax].[TaxCompany] CHECK CONSTRAINT [FK_TaxCompany_AccountType]
GO
ALTER TABLE [Tax].[TaxCompany]  WITH CHECK ADD  CONSTRAINT [FK_TaxCompany_Company] FOREIGN KEY([ServiceCompanyId])
REFERENCES [Common].[Company] ([Id])
GO
ALTER TABLE [Tax].[TaxCompany] CHECK CONSTRAINT [FK_TaxCompany_Company]
GO
ALTER TABLE [Tax].[TaxCompany]  WITH CHECK ADD  CONSTRAINT [FK_TaxCompany_IdType] FOREIGN KEY([IdtypeId])
REFERENCES [Common].[IdType] ([Id])
GO
ALTER TABLE [Tax].[TaxCompany] CHECK CONSTRAINT [FK_TaxCompany_IdType]
GO
ALTER TABLE [Tax].[TaxCompany]  WITH CHECK ADD  CONSTRAINT [FK_TaxCompany_TermsOfPayment] FOREIGN KEY([TermsOfPaymentId])
REFERENCES [Common].[TermsOfPayment] ([Id])
GO
ALTER TABLE [Tax].[TaxCompany] CHECK CONSTRAINT [FK_TaxCompany_TermsOfPayment]
GO
