USE [SmartCursorSTG]
GO
/****** Object:  Table [DR].[FinanceCompany]    Script Date: 16-12-2024 9.30.56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [DR].[FinanceCompany](
	[Id] [uniqueidentifier] NOT NULL,
	[CompanyId] [bigint] NOT NULL,
	[CountryOfIncorporation] [nvarchar](100) NULL,
	[IncorporationDate] [datetime2](7) NULL,
	[IndustryType] [nvarchar](256) NULL,
	[RecOrder] [int] NULL,
	[Remarks] [nvarchar](256) NULL,
	[UserCreated] [nvarchar](254) NULL,
	[CreatedDate] [datetime2](7) NULL,
	[ModifiedBy] [nvarchar](254) NULL,
	[ModifiedDate] [datetime2](7) NULL,
	[Status] [int] NULL,
	[TermsOfPaymentId] [bigint] NULL,
	[ServiceCompanyId] [bigint] NULL,
 CONSTRAINT [PK_FinanceCompany] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [DR].[FinanceCompany] ADD  DEFAULT ((1)) FOR [Status]
GO
ALTER TABLE [DR].[FinanceCompany]  WITH CHECK ADD  CONSTRAINT [FK_FinanceCompany_Company] FOREIGN KEY([ServiceCompanyId])
REFERENCES [Common].[Company] ([Id])
GO
ALTER TABLE [DR].[FinanceCompany] CHECK CONSTRAINT [FK_FinanceCompany_Company]
GO
