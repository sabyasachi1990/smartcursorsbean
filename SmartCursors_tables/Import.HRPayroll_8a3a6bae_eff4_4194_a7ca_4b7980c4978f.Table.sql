USE [SmartCursorSTG]
GO
/****** Object:  Table [Import].[HRPayroll_8a3a6bae_eff4_4194_a7ca_4b7980c4978f]    Script Date: 16-12-2024 9.30.57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Import].[HRPayroll_8a3a6bae_eff4_4194_a7ca_4b7980c4978f](
	[CompanyName] [nvarchar](max) NULL,
	[ShortName] [nvarchar](max) NULL,
	[Year] [int] NULL,
	[Month] [nvarchar](max) NULL,
	[FirstName] [nvarchar](max) NULL,
	[EmployeeId] [nvarchar](max) NULL,
	[AWS] [money] NULL,
	[Backpay] [money] NULL,
	[Basic Pay] [money] NULL,
	[Bonus] [money] NULL,
	[Claim Deduction] [money] NULL,
	[Claim Reimbursements] [money] NULL,
	[Commission] [money] NULL,
	[Commission (Monthly)] [money] NULL,
	[Deduction] [money] NULL,
	[Directors fees] [money] NULL,
	[Entertainment] [money] NULL,
	[Ex-Gratia] [money] NULL,
	[Expenses Reimburse] [money] NULL,
	[Gratuity] [money] NULL,
	[Inter Allowance] [money] NULL,
	[Intern Allowance] [money] NULL,
	[Leave Deduction] [money] NULL,
	[Leave Encashment] [money] NULL,
	[Loan Deduction] [money] NULL,
	[MBMF Contribution] [money] NULL,
	[Monthly Allowancce] [money] NULL,
	[No Pay Leave] [money] NULL,
	[Notice Pay] [money] NULL,
	[NS Deduction] [money] NULL,
	[OT allowance] [money] NULL,
	[OT allowance (Monthly)] [money] NULL,
	[Pay Comp - Test] [money] NULL,
	[Reimbursement (-)] [money] NULL,
	[Reimbursement (+)] [money] NULL,
	[Retrenchment Pay] [money] NULL,
	[Severance Payment] [money] NULL,
	[Transport] [money] NULL,
	[Unpaid Leave] [money] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
