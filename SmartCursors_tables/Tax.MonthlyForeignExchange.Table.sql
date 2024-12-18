USE [SmartCursorSTG]
GO
/****** Object:  Table [Tax].[MonthlyForeignExchange]    Script Date: 16-12-2024 9.30.57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Tax].[MonthlyForeignExchange](
	[Id] [uniqueidentifier] NOT NULL,
	[CompanyId] [bigint] NOT NULL,
	[Month] [int] NOT NULL,
	[Year] [int] NOT NULL,
	[BaseCurrency] [nvarchar](20) NULL,
	[FunctionalCurrency] [nvarchar](20) NULL,
	[BaseToFunctionalCurrency] [decimal](17, 8) NULL,
	[FunctionalToBaseCurrency] [decimal](17, 8) NULL,
	[RecOrder] [int] NULL,
	[Remarks] [nvarchar](256) NULL,
	[UserCreated] [nvarchar](254) NULL,
	[CreatedDate] [datetime2](7) NULL,
	[ModifiedBy] [nvarchar](254) NULL,
	[ModifiedDate] [datetime2](7) NULL,
	[Version] [smallint] NULL,
	[Status] [int] NULL,
 CONSTRAINT [PK_MonthlyForeignExchange] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ADD SENSITIVITY CLASSIFICATION TO [Tax].[MonthlyForeignExchange].[BaseCurrency] WITH (label = 'Confidential', label_id = '281b9ab3-ecbb-4a57-8486-c702e44215d8', information_type = 'Financial', information_type_id = 'c44193e1-0e58-4b2a-9001-f7d6e7bc1373', rank = Medium);
GO
ADD SENSITIVITY CLASSIFICATION TO [Tax].[MonthlyForeignExchange].[FunctionalCurrency] WITH (label = 'Confidential', label_id = '281b9ab3-ecbb-4a57-8486-c702e44215d8', information_type = 'Financial', information_type_id = 'c44193e1-0e58-4b2a-9001-f7d6e7bc1373', rank = Medium);
GO
ADD SENSITIVITY CLASSIFICATION TO [Tax].[MonthlyForeignExchange].[BaseToFunctionalCurrency] WITH (label = 'Confidential', label_id = '281b9ab3-ecbb-4a57-8486-c702e44215d8', information_type = 'Financial', information_type_id = 'c44193e1-0e58-4b2a-9001-f7d6e7bc1373', rank = Medium);
GO
ADD SENSITIVITY CLASSIFICATION TO [Tax].[MonthlyForeignExchange].[FunctionalToBaseCurrency] WITH (label = 'Confidential', label_id = '281b9ab3-ecbb-4a57-8486-c702e44215d8', information_type = 'Financial', information_type_id = 'c44193e1-0e58-4b2a-9001-f7d6e7bc1373', rank = Medium);
GO
ALTER TABLE [Tax].[MonthlyForeignExchange] ADD  DEFAULT ((1)) FOR [Status]
GO
ALTER TABLE [Tax].[MonthlyForeignExchange]  WITH CHECK ADD  CONSTRAINT [Fk_MonthlyForeignExchange_CompanyId] FOREIGN KEY([CompanyId])
REFERENCES [Common].[Company] ([Id])
GO
ALTER TABLE [Tax].[MonthlyForeignExchange] CHECK CONSTRAINT [Fk_MonthlyForeignExchange_CompanyId]
GO
