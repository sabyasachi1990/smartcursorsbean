USE [SmartCursorSTG]
GO
/****** Object:  Table [Import].[HRPayroll_35baa0cc_561e_4314_9a67_3f90c84240da]    Script Date: 16-12-2024 9.30.57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Import].[HRPayroll_35baa0cc_561e_4314_9a67_3f90c84240da](
	[CompanyName] [nvarchar](max) NULL,
	[ShortName] [nvarchar](max) NULL,
	[Year] [int] NULL,
	[Month] [nvarchar](max) NULL,
	[FirstName] [nvarchar](max) NULL,
	[EmployeeId] [nvarchar](max) NULL,
	[AWS] [money] NULL,
	[Backpay Allowance] [money] NULL,
	[Backpay Salary] [money] NULL,
	[Basic Pay] [money] NULL,
	[Bonus] [money] NULL,
	[Claim Deduction] [money] NULL,
	[Commission] [money] NULL,
	[Commission (Monthly)] [money] NULL,
	[Directors fees] [money] NULL,
	[Entertainment] [money] NULL,
	[Leave Deduction] [money] NULL,
	[Leave Encashment] [money] NULL,
	[MBMF Contribution] [money] NULL,
	[No Pay Leave] [money] NULL,
	[NS Deduction] [money] NULL,
	[OT allowance] [money] NULL,
	[OT allowance (Monthly)] [money] NULL,
	[Other Allowance] [money] NULL,
	[Reimbursement (-)] [money] NULL,
	[Reimbursement (+)] [money] NULL,
	[Transport] [money] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
