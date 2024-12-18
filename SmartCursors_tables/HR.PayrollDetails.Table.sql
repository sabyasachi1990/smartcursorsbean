USE [SmartCursorSTG]
GO
/****** Object:  Table [HR].[PayrollDetails]    Script Date: 16-12-2024 9.30.57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [HR].[PayrollDetails](
	[Id] [uniqueidentifier] NOT NULL,
	[MasterId] [uniqueidentifier] NOT NULL,
	[EmployeeId] [uniqueidentifier] NOT NULL,
	[BasicPay] [money] NULL,
	[EmployeeCPF] [money] NULL,
	[EmployerCPF] [money] NULL,
	[SDL] [money] NULL,
	[AgencyFund] [money] NULL,
	[Earnings] [money] NULL,
	[Deduction] [money] NULL,
	[Reimbursement] [money] NULL,
	[GrossWage] [money] NULL,
	[NetWage] [money] NULL,
	[PaySlipRemarks] [nvarchar](254) NULL,
	[PaySlipFilePath] [nvarchar](1000) NULL,
	[Currency] [nvarchar](5) NULL,
	[DocCurrency] [nvarchar](5) NULL,
	[CreatedDate] [datetime2](7) NULL,
	[Status] [int] NULL,
	[OrdinaryWage] [money] NULL,
	[AdditionalWage] [money] NULL,
	[OrdinaryWageCap] [money] NULL,
	[IsLock] [bit] NULL,
	[PaySplitModifiedBy] [nvarchar](100) NULL,
	[PaySplitModifiedDate] [datetime2](7) NULL,
	[IsTemporary] [bit] NULL,
	[PayMode] [nvarchar](20) NULL,
	[BankName] [nvarchar](100) NULL,
	[BankAccNumber] [nvarchar](50) NULL,
	[ContributionFor] [nvarchar](50) NULL,
	[PayslipContent] [nvarchar](max) NULL,
	[AgencyFundId] [nvarchar](500) NULL,
	[EmployeeESI] [money] NULL,
	[EmployerESI] [money] NULL,
	[Gratuity] [money] NULL,
	[ProfessionalTax] [money] NULL,
	[pdfBytes] [varbinary](max) NULL,
	[OneDaySalary] [money] NULL,
	[EnacashmentDays] [float] NULL,
	[Age] [int] NULL,
	[IdType] [nvarchar](50) NULL,
	[SPRGranted] [datetime2](7) NULL,
	[SPRExpiry] [datetime2](7) NULL,
	[CPFExampted] [bit] NULL,
	[WorkProfileId] [uniqueidentifier] NULL,
	[SDLExampted] [bit] NULL,
	[EmploymentEndDate] [datetime2](7) NULL,
	[IsCPFContributionFull] [bit] NULL,
	[SDLWage] [money] NULL,
	[SPROWWage] [money] NULL,
	[ExcludeGrosswageEarningAmount] [money] NULL,
	[ExcludeGrosswageDeductionAmount] [money] NULL,
	[EffectiveFrom] [datetime2](7) NULL,
	[SPRBasicPay] [money] NULL,
	[CompanyContribution] [nvarchar](50) NULL,
	[EmploymentStartDate] [datetime2](7) NULL,
	[EncashmentOneDaySalary] [money] NULL,
	[ClaimIds] [nvarchar](max) NULL,
	[AgencyFundModel] [nvarchar](max) NULL,
	[NopayLeaveFee] [money] NULL,
 CONSTRAINT [PK_PayrollDetails] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [HR].[PayrollDetails]  WITH CHECK ADD  CONSTRAINT [FK_PayrollDetails_Employee] FOREIGN KEY([EmployeeId])
REFERENCES [Common].[Employee] ([Id])
GO
ALTER TABLE [HR].[PayrollDetails] CHECK CONSTRAINT [FK_PayrollDetails_Employee]
GO
ALTER TABLE [HR].[PayrollDetails]  WITH CHECK ADD  CONSTRAINT [FK_PayrollDetails_Payroll] FOREIGN KEY([MasterId])
REFERENCES [HR].[Payroll] ([Id])
GO
ALTER TABLE [HR].[PayrollDetails] CHECK CONSTRAINT [FK_PayrollDetails_Payroll]
GO
