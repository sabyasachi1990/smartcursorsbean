USE [SmartCursorSTG]
GO
/****** Object:  Table [Import].[HRPayroll_a05920b1_0e62_4ab2_8fbd_cb73e131c701]    Script Date: 16-12-2024 9.30.57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Import].[HRPayroll_a05920b1_0e62_4ab2_8fbd_cb73e131c701](
	[CompanyName] [nvarchar](max) NULL,
	[ShortName] [nvarchar](max) NULL,
	[Year] [int] NULL,
	[Month] [nvarchar](max) NULL,
	[FirstName] [nvarchar](max) NULL,
	[EmployeeId] [nvarchar](max) NULL,
	[Leave Encashment] [money] NULL,
	[Transport] [money] NULL,
	[Directors fees] [money] NULL,
	[Retrenchment Pay] [money] NULL,
	[Commission] [money] NULL,
	[Other Allowance] [money] NULL,
	[Gratuity] [money] NULL,
	[Remote Work Perks] [money] NULL,
	[Wellness Deduction] [money] NULL,
	[Screening Deduction] [money] NULL,
	[Bonus] [money] NULL,
	[Dividends] [money] NULL,
	[Reimbursement (+)] [money] NULL,
	[OT allowance] [money] NULL,
	[Dental Deduction] [money] NULL,
	[Commission (Monthly)] [money] NULL,
	[Claim Deduction] [money] NULL,
	[Freelance Fees] [money] NULL,
	[Reimbursement (-)] [money] NULL,
	[Ex-Gratia] [money] NULL,
	[Referral Fees] [money] NULL,
	[Notice Pay] [money] NULL,
	[Basic Pay] [money] NULL,
	[Salary Deduction] [money] NULL,
	[AWS] [money] NULL,
	[Leave Deduction] [money] NULL,
	[Unpaid Leave] [money] NULL,
	[Training Allowance] [money] NULL,
	[Training Deduction] [money] NULL,
	[OT allowance (Monthly)] [money] NULL,
	[Expenses Reimburse] [money] NULL,
	[Deduction] [money] NULL,
	[Entertainment Allowance] [money] NULL,
	[Covid-19 Reimbursement Scheme] [money] NULL,
	[MBMF Contribution] [money] NULL,
	[Backpay] [money] NULL,
	[Severance Payment] [money] NULL,
	[Special "No MC" Allowance] [money] NULL,
	[Medical Deduction] [money] NULL,
	[Loan Deduction] [money] NULL,
	[NS Deduction] [money] NULL,
	[Data Reimbursement] [money] NULL,
	[Welfare Deduction] [money] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
