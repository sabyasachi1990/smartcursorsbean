USE [SmartCursorSTG]
GO
/****** Object:  Table [HR].[CompanyPayrollSettings]    Script Date: 16-12-2024 9.30.56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [HR].[CompanyPayrollSettings](
	[Id] [uniqueidentifier] NOT NULL,
	[CompanyId] [bigint] NOT NULL,
	[ParentCompanyId] [bigint] NOT NULL,
	[CPFSubmissionNumber] [nvarchar](100) NULL,
	[TaxReferenceNumber] [nvarchar](100) NULL,
	[DefaultPayDayoftheMonth] [int] NULL,
	[DefaultPayFrequency] [nvarchar](50) NOT NULL,
	[SPRFirstYear] [nvarchar](30) NULL,
	[SPRSecondYear] [nvarchar](30) NULL,
	[Remarks] [nvarchar](254) NULL,
	[RecOrder] [int] NULL,
	[UserCreated] [nvarchar](254) NULL,
	[CreatedDate] [datetime2](7) NULL,
	[ModifiedBy] [nvarchar](254) NULL,
	[ModifiedDate] [datetime2](7) NULL,
	[Version] [smallint] NULL,
	[Status] [int] NULL,
	[EmployeeCPFContribution] [nvarchar](100) NULL,
 CONSTRAINT [PK_CompanyPayrollSettings] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ADD SENSITIVITY CLASSIFICATION TO [HR].[CompanyPayrollSettings].[TaxReferenceNumber] WITH (label = 'Confidential', label_id = '281b9ab3-ecbb-4a57-8486-c702e44215d8', information_type = 'Financial', information_type_id = 'c44193e1-0e58-4b2a-9001-f7d6e7bc1373', rank = Medium);
GO
ALTER TABLE [HR].[CompanyPayrollSettings] ADD  DEFAULT ('Monthly') FOR [DefaultPayFrequency]
GO
ALTER TABLE [HR].[CompanyPayrollSettings] ADD  DEFAULT ((1)) FOR [Status]
GO
ALTER TABLE [HR].[CompanyPayrollSettings]  WITH CHECK ADD  CONSTRAINT [FK_CompanyPayrollSettings_Company] FOREIGN KEY([CompanyId])
REFERENCES [Common].[Company] ([Id])
GO
ALTER TABLE [HR].[CompanyPayrollSettings] CHECK CONSTRAINT [FK_CompanyPayrollSettings_Company]
GO
