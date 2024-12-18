USE [SmartCursorSTG]
GO
/****** Object:  Table [HR].[IR8AHRSetUp]    Script Date: 16-12-2024 9.30.57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [HR].[IR8AHRSetUp](
	[Id] [uniqueidentifier] NOT NULL,
	[IR8ACompanySetUpId] [uniqueidentifier] NOT NULL,
	[ParentCompanyId] [bigint] NOT NULL,
	[CompanyId] [bigint] NOT NULL,
	[EmployeeId] [uniqueidentifier] NOT NULL,
	[Year] [bigint] NULL,
	[Type] [nvarchar](50) NULL,
	[ApprovedatTheCompanyAgmEgm] [datetime2](7) NULL,
	[GrossCommissionPeriodFrom] [datetime2](7) NULL,
	[GrossCommissionPeriodTo] [datetime2](7) NULL,
	[RBIAmountAccuredFrom] [nvarchar](100) NULL,
	[RBIAmountAccuredTo] [nvarchar](100) NULL,
	[CompleteTheFormIR8A] [nvarchar](256) NULL,
	[CompleteTheAppendix8B] [nvarchar](256) NULL,
	[ValuesOfBenifits] [nvarchar](256) NULL,
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
	[Status] [int] NULL,
	[IncomeOthersbornebyemployer] [nvarchar](500) NULL,
	[IncomeOthersPaidbyemployee] [nvarchar](500) NULL,
	[GrossCommisisoAmount] [decimal](18, 0) NULL,
	[Grautity] [decimal](18, 0) NULL,
	[NoticePay] [decimal](18, 0) NULL,
	[ExGratiaPayment] [decimal](18, 0) NULL,
	[Others] [decimal](18, 0) NULL,
	[ReasonForPayment] [nvarchar](500) NULL,
	[LenghtOfService] [decimal](18, 0) NULL,
	[BasisOfArrivingatPayment] [nvarchar](256) NULL,
	[CompensationForLossOfOffice] [decimal](18, 0) NULL,
	[ApprovalObtainedForIRAS] [nvarchar](500) NULL,
	[NameOfTheFund] [nvarchar](500) NULL,
	[AmountOfIncome] [decimal](18, 0) NULL,
	[OverseasPosting] [decimal](18, 0) NULL,
	[ExemptIncome] [decimal](18, 0) NULL,
	[Donations] [decimal](18, 0) NULL,
	[MosqueBuildingFund] [decimal](18, 0) NULL,
	[LifeInsurence] [decimal](18, 0) NULL,
	[EmpsIncomeTaxBronebyTheEmployee] [bit] NULL,
	[IsEmployeeLock] [bit] NULL,
	[IsAppendix8a] [bit] NULL,
	[DateOfApproval] [datetime2](7) NULL,
	[NameOfOverseasPension] [nvarchar](500) NULL,
	[FullAmountOfContribution] [decimal](18, 0) NULL,
	[AreContributionsMandatory] [nvarchar](100) NULL,
	[WereContributionsChanged] [nvarchar](100) NULL,
	[IsIr8sEnabled] [bit] NULL,
	[IsAppendix8BEnabled] [bit] NULL,
	[GrossCommissionIndicator] [nvarchar](500) NULL,
	[AuthorisedPersonEmail] [nvarchar](100) NULL,
	[BonusDate] [datetime2](7) NULL,
	[StatusCode] [nvarchar](20) NULL,
	[GeneratedOn] [datetime] NULL,
	[StatusRemarks] [nvarchar](max) NULL,
	[TaxRefNo] [nvarchar](250) NULL,
	[PriorSubTotal] [decimal](13, 2) NULL,
	[LastSalaryPeriod] [nvarchar](250) NULL,
	[OutSideNameOfFund] [nvarchar](250) NULL,
	[PriorTotal] [decimal](13, 2) NULL,
	[PostalCode] [nvarchar](250) NULL,
	[StreetName] [nvarchar](250) NULL,
	[BlockHouseNo] [nvarchar](250) NULL,
	[AmountPendingTax] [decimal](13, 2) NULL,
	[FaxNo] [nvarchar](250) NULL,
	[IsDateOfResignationNotification] [bit] NULL,
	[GrossSalary] [decimal](13, 2) NULL,
	[PriorGrossSalary] [decimal](13, 2) NULL,
	[Bonous] [decimal](13, 2) NULL,
	[PriorBonous] [decimal](13, 2) NULL,
	[DirectorFees] [decimal](13, 2) NULL,
	[PriorDirectorFees] [decimal](13, 2) NULL,
	[GrossCommissionFee] [decimal](13, 2) NULL,
	[PriorGrossCommissionFee] [decimal](13, 2) NULL,
	[AllowancesFee] [decimal](13, 2) NULL,
	[PriorAllowancesFee] [decimal](13, 2) NULL,
	[PriorNoticePay] [decimal](13, 2) NULL,
	[PriorGrautity] [decimal](13, 2) NULL,
	[PriorCompensationForLossOfOffice] [decimal](13, 2) NULL,
	[PriorDeductedAmount] [decimal](13, 2) NULL,
	[DeductedAmount] [decimal](13, 2) NULL,
	[PriorDonations] [decimal](13, 2) NULL,
	[PriorNameOfFundCpfAmount] [decimal](13, 2) NULL,
	[NameOfFundCpfAmount] [decimal](13, 2) NULL,
	[NameOfFundCpf] [nvarchar](250) NULL,
	[Total] [decimal](13, 2) NULL,
	[SubTotal] [decimal](13, 2) NULL,
	[ESOPAmount] [decimal](13, 2) NULL,
	[PriorCPFAmount] [decimal](13, 2) NULL,
	[CPFAmount] [decimal](13, 2) NULL,
	[PriorOutSideNameOfFundAmount] [decimal](13, 2) NULL,
	[OutSideNameOfFundAmount] [decimal](13, 2) NULL,
	[PriorDateOfPayment] [datetime2](7) NULL,
	[DateOfPayment] [datetime2](7) NULL,
	[PriorFundAmount] [decimal](13, 2) NULL,
	[FundAmount] [decimal](13, 2) NULL,
	[PriorApprovedatTheCompanyAgmEgm] [datetime2](7) NULL,
	[UnitNo] [nvarchar](200) NULL,
	[PriorESOPAmount] [decimal](13, 2) NULL,
	[IsAbsconded] [bit] NULL,
	[IsImmediateResigned] [bit] NULL,
	[IsResignedWhlist] [bit] NULL,
	[IsOthers] [bit] NULL,
	[OthersDetails] [nvarchar](max) NULL,
	[LastSalaryPaidDate] [datetime2](7) NULL,
	[LastSalaryAmount] [decimal](13, 2) NULL,
	[FromYearofCessation] [datetime2](7) NULL,
	[ToYearofCessation] [datetime2](7) NULL,
	[PriorFromYearofCessation] [datetime2](7) NULL,
	[PriorToYearofCessation] [datetime2](7) NULL,
	[ContractualBonus] [decimal](13, 2) NULL,
	[PriorContractualBonus] [decimal](13, 2) NULL,
	[NonContractualBonus] [decimal](13, 2) NULL,
	[PriorNonContractualBonus] [decimal](13, 2) NULL,
	[LengthOfService] [nvarchar](200) NULL,
	[MonthlySalary] [decimal](13, 2) NULL,
	[NameOfSpouse] [nvarchar](250) NULL,
	[DateOfBirth] [datetime2](7) NULL,
	[IdentNo] [nvarchar](250) NULL,
	[DateOfMarriage] [datetime2](7) NULL,
	[Nationality] [nvarchar](250) NULL,
	[IsYearlyIncome] [bit] NULL,
	[SpouseCurrentEmployeeAdress] [nvarchar](max) NULL,
 CONSTRAINT [PK_IR8AHRSetUp] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [HR].[IR8AHRSetUp] ADD  DEFAULT (getdate()) FOR [CreatedDate]
GO
ALTER TABLE [HR].[IR8AHRSetUp] ADD  DEFAULT ((1)) FOR [Status]
GO
ALTER TABLE [HR].[IR8AHRSetUp]  WITH CHECK ADD  CONSTRAINT [FK_IR8AHRSetUp_Company] FOREIGN KEY([CompanyId])
REFERENCES [Common].[Company] ([Id])
GO
ALTER TABLE [HR].[IR8AHRSetUp] CHECK CONSTRAINT [FK_IR8AHRSetUp_Company]
GO
ALTER TABLE [HR].[IR8AHRSetUp]  WITH CHECK ADD  CONSTRAINT [FK_IR8AHRSetUp_Employee] FOREIGN KEY([EmployeeId])
REFERENCES [Common].[Employee] ([Id])
GO
ALTER TABLE [HR].[IR8AHRSetUp] CHECK CONSTRAINT [FK_IR8AHRSetUp_Employee]
GO
ALTER TABLE [HR].[IR8AHRSetUp]  WITH CHECK ADD  CONSTRAINT [FK_IR8AHRSetUp_IR8ACompanySetUp] FOREIGN KEY([IR8ACompanySetUpId])
REFERENCES [HR].[IR8ACompanySetUp] ([Id])
GO
ALTER TABLE [HR].[IR8AHRSetUp] CHECK CONSTRAINT [FK_IR8AHRSetUp_IR8ACompanySetUp]
GO
