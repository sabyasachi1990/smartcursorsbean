USE [SmartCursorSTG]
GO
/****** Object:  Table [HR].[EmployeeBankDetails]    Script Date: 16-12-2024 9.30.56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [HR].[EmployeeBankDetails](
	[Id] [uniqueidentifier] NOT NULL,
	[EmployeeId] [uniqueidentifier] NULL,
	[CompanyId] [bigint] NOT NULL,
	[ShortCode] [nvarchar](50) NULL,
	[BankName] [nvarchar](500) NULL,
	[BranchName] [nvarchar](500) NULL,
	[BranchCode] [nvarchar](15) NULL,
	[BankAddress] [nvarchar](1000) NULL,
	[AccountNumber] [nvarchar](15) NULL,
	[AccountName] [nvarchar](50) NULL,
	[Currency] [nvarchar](5) NULL,
	[SwiftCode] [nvarchar](20) NULL,
	[Remarks] [nvarchar](256) NULL,
	[UserCreated] [nvarchar](254) NULL,
	[CreateDate] [datetime2](7) NULL,
	[ModifiedDate] [datetime2](7) NULL,
	[ModifiedBy] [nvarchar](254) NULL,
	[RecOrder] [int] NULL,
	[Status] [int] NULL,
	[Version] [smallint] NULL,
	[JobApplicationId] [uniqueidentifier] NULL,
 CONSTRAINT [PK_PayrollSettingBankDetails] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [HR].[EmployeeBankDetails]  WITH CHECK ADD  CONSTRAINT [FK_EmployeeBankDetails_Company] FOREIGN KEY([CompanyId])
REFERENCES [Common].[Company] ([Id])
GO
ALTER TABLE [HR].[EmployeeBankDetails] CHECK CONSTRAINT [FK_EmployeeBankDetails_Company]
GO
ALTER TABLE [HR].[EmployeeBankDetails]  WITH CHECK ADD  CONSTRAINT [FK_PayrollSetting_Employee] FOREIGN KEY([EmployeeId])
REFERENCES [Common].[Employee] ([Id])
GO
ALTER TABLE [HR].[EmployeeBankDetails] CHECK CONSTRAINT [FK_PayrollSetting_Employee]
GO
