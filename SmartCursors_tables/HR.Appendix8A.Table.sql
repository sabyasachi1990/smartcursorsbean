USE [SmartCursorSTG]
GO
/****** Object:  Table [HR].[Appendix8A]    Script Date: 16-12-2024 9.30.56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [HR].[Appendix8A](
	[Id] [uniqueidentifier] NOT NULL,
	[EmployeeId] [uniqueidentifier] NOT NULL,
	[IR8AHRSetUpId] [uniqueidentifier] NOT NULL,
	[CompanyId] [bigint] NOT NULL,
	[Year] [bigint] NULL,
	[Type] [nvarchar](50) NULL,
	[TaxRefNo] [nvarchar](50) NULL,
	[AnnualValue] [nvarchar](50) NULL,
	[ValueOfAssets] [nvarchar](50) NULL,
	[Rent] [nvarchar](50) NULL,
	[ValueOfResidence] [nvarchar](50) NULL,
	[TotalPaidToResidence] [nvarchar](50) NULL,
	[TotalTaxableValueOfResidence] [nvarchar](50) NULL,
	[UtilitiesAmount] [nvarchar](50) NULL,
	[DriverAmount] [nvarchar](50) NULL,
	[ServentAmount] [nvarchar](50) NULL,
	[TotalAnnualValue] [nvarchar](50) NULL,
	[Accommondation] [nvarchar](50) NULL,
	[AountPaidByEmployee] [nvarchar](50) NULL,
	[TaxableValueforAccommodation] [nvarchar](50) NULL,
	[CostOfHomeLeavingPassengers] [nvarchar](50) NULL,
	[Interestmadebyemployer] [nvarchar](50) NULL,
	[Insurence] [nvarchar](50) NULL,
	[Holidays] [nvarchar](50) NULL,
	[Education] [nvarchar](50) NULL,
	[TransFerFee] [nvarchar](50) NULL,
	[GainFromAssets] [nvarchar](50) NULL,
	[FullCostOfMotor] [nvarchar](50) NULL,
	[CarBenifits] [nvarchar](50) NULL,
	[NonMandatoryAwards] [nvarchar](50) NULL,
	[ValuesOfBenifitsToBeInIR8A] [nvarchar](50) NULL,
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
	[NoOfDays] [int] NULL,
	[NoOfEmployees] [int] NULL,
	[StatusCode] [nvarchar](20) NULL,
	[GeneratedOn] [datetime] NULL,
	[StatusRemarks] [nvarchar](max) NULL,
 CONSTRAINT [PK_Appendix8A] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [HR].[Appendix8A] ADD  DEFAULT (getdate()) FOR [CreatedDate]
GO
ALTER TABLE [HR].[Appendix8A] ADD  DEFAULT ((1)) FOR [Status]
GO
ALTER TABLE [HR].[Appendix8A]  WITH CHECK ADD  CONSTRAINT [FK_Appendix8A_Company] FOREIGN KEY([CompanyId])
REFERENCES [Common].[Company] ([Id])
GO
ALTER TABLE [HR].[Appendix8A] CHECK CONSTRAINT [FK_Appendix8A_Company]
GO
ALTER TABLE [HR].[Appendix8A]  WITH CHECK ADD  CONSTRAINT [FK_Appendix8A_Employee] FOREIGN KEY([EmployeeId])
REFERENCES [Common].[Employee] ([Id])
GO
ALTER TABLE [HR].[Appendix8A] CHECK CONSTRAINT [FK_Appendix8A_Employee]
GO
ALTER TABLE [HR].[Appendix8A]  WITH CHECK ADD  CONSTRAINT [FK_Appendix8A_IR8AHRSetUp] FOREIGN KEY([IR8AHRSetUpId])
REFERENCES [HR].[IR8AHRSetUp] ([Id])
GO
ALTER TABLE [HR].[Appendix8A] CHECK CONSTRAINT [FK_Appendix8A_IR8AHRSetUp]
GO
