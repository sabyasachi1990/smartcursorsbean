USE [SmartCursorSTG]
GO
/****** Object:  Table [Audit].[AuditCompany]    Script Date: 16-12-2024 9.30.55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Audit].[AuditCompany](
	[Id] [uniqueidentifier] NOT NULL,
	[CompanyId] [bigint] NOT NULL,
	[ServiceCompanyId] [bigint] NOT NULL,
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
 CONSTRAINT [PK_AuditCompany] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Audit].[AuditCompany] ADD  DEFAULT ((1)) FOR [Status]
GO
ALTER TABLE [Audit].[AuditCompany]  WITH CHECK ADD  CONSTRAINT [FK_AuditCompany_Company] FOREIGN KEY([ServiceCompanyId])
REFERENCES [Common].[Company] ([Id])
GO
ALTER TABLE [Audit].[AuditCompany] CHECK CONSTRAINT [FK_AuditCompany_Company]
GO
ALTER TABLE [Audit].[AuditCompany]  WITH CHECK ADD  CONSTRAINT [FK_AuditCompany_TermsOfPayment] FOREIGN KEY([TermsOfPaymentId])
REFERENCES [Common].[TermsOfPayment] ([Id])
GO
ALTER TABLE [Audit].[AuditCompany] CHECK CONSTRAINT [FK_AuditCompany_TermsOfPayment]
GO
