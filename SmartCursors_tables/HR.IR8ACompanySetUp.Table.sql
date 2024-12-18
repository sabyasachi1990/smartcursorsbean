USE [SmartCursorSTG]
GO
/****** Object:  Table [HR].[IR8ACompanySetUp]    Script Date: 16-12-2024 9.30.57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [HR].[IR8ACompanySetUp](
	[Id] [uniqueidentifier] NOT NULL,
	[ParentCompanyId] [bigint] NOT NULL,
	[CompanyId] [bigint] NOT NULL,
	[Year] [bigint] NULL,
	[Type] [nvarchar](50) NULL,
	[ApprovedatTheCompanyAgmEgm] [datetime2](7) NULL,
	[GrossCommissionPeriodFrom] [datetime2](7) NULL,
	[GrossCommissionPeriodTo] [datetime2](7) NULL,
	[NameOfTheFund] [nvarchar](256) NULL,
	[LSPReasonForPayment] [nvarchar](256) NULL,
	[LSPBasisOfArrivingatThePayment] [nvarchar](256) NULL,
	[RBIAmountAccuredFrom] [nvarchar](100) NULL,
	[RBIAmountAccuredTo] [nvarchar](100) NULL,
	[ContributionsMadeByEmployerToAnyPerson] [nvarchar](256) NULL,
	[CompleteTheFormIR8A] [nvarchar](256) NULL,
	[DeductionsName] [nvarchar](256) NULL,
	[NameOfTheEmployeer] [nvarchar](256) NULL,
	[AddressOfTheEmployeer] [nvarchar](4000) NULL,
	[AuthorisedPersonMakingDeclaration] [nvarchar](4000) NULL,
	[Designation] [nvarchar](100) NULL,
	[TelNO] [nvarchar](100) NULL,
	[Signature] [nvarchar](100) NULL,
	[Date] [datetime2](7) NULL,
	[Remarks] [nvarchar](256) NULL,
	[RecOrder] [int] NULL,
	[UserCreated] [varchar](254) NULL,
	[CreatedDate] [datetime2](7) NULL,
	[ModifiedBy] [nvarchar](254) NULL,
	[ModifiedDate] [datetime2](7) NULL,
	[Version] [smallint] NULL,
	[Status] [int] NULL,
	[IncomeOthersbornebyemployer] [nvarchar](500) NULL,
	[IncomeOthersPaidbyemployee] [nvarchar](500) NULL,
	[IsCompanyLock] [bit] NULL,
	[RemissionAmountOfIncome] [decimal](18, 0) NULL,
	[GrossCommissionIndicator] [nvarchar](500) NULL,
	[AuthorisedPersonEmail] [nvarchar](100) NULL,
	[StatusCode] [nvarchar](20) NULL,
	[GeneratedOn] [datetime] NULL,
	[StatusRemarks] [nvarchar](max) NULL,
	[BonusDate] [datetime2](7) NULL,
	[FaxNo] [nvarchar](250) NULL,
	[EmployeeIds] [nvarchar](max) NULL,
 CONSTRAINT [PK_IR8ACompanySetUp] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [HR].[IR8ACompanySetUp] ADD  DEFAULT (getdate()) FOR [CreatedDate]
GO
ALTER TABLE [HR].[IR8ACompanySetUp] ADD  DEFAULT ((1)) FOR [Status]
GO
ALTER TABLE [HR].[IR8ACompanySetUp]  WITH CHECK ADD  CONSTRAINT [FK_IR8ACompanySetUp_Company] FOREIGN KEY([CompanyId])
REFERENCES [Common].[Company] ([Id])
GO
ALTER TABLE [HR].[IR8ACompanySetUp] CHECK CONSTRAINT [FK_IR8ACompanySetUp_Company]
GO
