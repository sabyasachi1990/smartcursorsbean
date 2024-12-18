USE [SmartCursorSTG]
GO
/****** Object:  Table [Import].[HRPayroll_d3275de6_24a3_4de0_b14e_af645a8e2e2d]    Script Date: 16-12-2024 9.30.57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Import].[HRPayroll_d3275de6_24a3_4de0_b14e_af645a8e2e2d](
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
	[Commission] [money] NULL,
	[Commission (Monthly)] [money] NULL,
	[Deduction] [money] NULL,
	[Directors fees] [money] NULL,
	[Entertainment] [money] NULL,
	[Ex-Gratia] [money] NULL,
	[Gratuity] [money] NULL,
	[Leave Deduction] [money] NULL,
	[Leave Encashment] [money] NULL,
	[MBMF Contribution] [money] NULL,
	[Notice Pay] [money] NULL,
	[NS Deduction] [money] NULL,
	[OT allowance] [money] NULL,
	[OT allowance (Monthly)] [money] NULL,
	[Other Allowance] [money] NULL,
	[Reimbursement (-)] [money] NULL,
	[Reimbursement (+)] [money] NULL,
	[Relocation Reimbursement] [money] NULL,
	[Retrenchment Pay] [money] NULL,
	[Severance Payment] [money] NULL,
	[Transport] [money] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
