USE [SmartCursorSTG]
GO
/****** Object:  Table [dbo].[EmployeesbankdetailsBTSGnew$]    Script Date: 16-12-2024 9.30.56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[EmployeesbankdetailsBTSGnew$](
	[EMP NO] [nvarchar](255) NULL,
	[Name] [nvarchar](255) NULL,
	[EMAIL AC NO] [nvarchar](255) NULL,
	[BANKNAME] [nvarchar](255) NULL,
	[BANK AC NO] [float] NULL,
	[BANK ID] [float] NULL,
	[BANK BRANCH CODE] [float] NULL,
	[FUND LEVY] [nvarchar](255) NULL,
	[INCOME TAX AC NO] [nvarchar](255) NULL,
	[EMPLOYER CPF REF] [nvarchar](255) NULL,
	[AccountNumber] [nvarchar](200) NULL,
	[BankId] [nvarchar](200) NULL,
	[BranchCode] [nvarchar](200) NULL
) ON [PRIMARY]
GO
