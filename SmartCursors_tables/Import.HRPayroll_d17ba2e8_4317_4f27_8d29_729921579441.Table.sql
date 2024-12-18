USE [SmartCursorSTG]
GO
/****** Object:  Table [Import].[HRPayroll_d17ba2e8_4317_4f27_8d29_729921579441]    Script Date: 16-12-2024 9.30.57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Import].[HRPayroll_d17ba2e8_4317_4f27_8d29_729921579441](
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
	[Commission] [money] NULL,
	[Commission (Monthly)] [money] NULL,
	[Deduction] [money] NULL,
	[Directors fees] [money] NULL,
	[Entertainment] [money] NULL,
	[Ex-Gratia] [money] NULL,
	[Expenses Reimburse] [money] NULL,
	[Gratuity] [money] NULL,
	[Leave Deduction] [money] NULL,
	[Leave Encashment] [money] NULL,
	[MBMF Contribution] [money] NULL,
	[No Pay Leave] [money] NULL,
	[Notice Pay] [money] NULL,
	[NS Deduction] [money] NULL,
	[OT allowance] [money] NULL,
	[OT allowance (Monthly)] [money] NULL,
	[Other Allowance] [money] NULL,
	[Reimbursement (-)] [money] NULL,
	[Reimbursement (+)] [money] NULL,
	[Retrenchment Pay] [money] NULL,
	[Severance Payment] [money] NULL,
	[Transport] [money] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
