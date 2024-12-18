USE [SmartCursorSTG]
GO
/****** Object:  Table [dbo].[ImportEmployeeDepartment]    Script Date: 16-12-2024 9.30.56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ImportEmployeeDepartment](
	[ID] [uniqueidentifier] NOT NULL,
	[TransactionId] [uniqueidentifier] NOT NULL,
	[EmployeeId] [nvarchar](2000) NOT NULL,
	[EntityName] [nvarchar](2000) NULL,
	[Department] [nvarchar](2000) NULL,
	[Designation] [nvarchar](2000) NULL,
	[Level] [int] NULL,
	[ReportingTo] [nvarchar](2000) NULL,
	[EffectiveFrom] [nvarchar](2000) NULL,
	[Currency] [nvarchar](2000) NULL,
	[MonthlyBasicPay] [decimal](18, 0) NULL,
	[ChargeOutRate] [nvarchar](2000) NULL,
	[ErrorRemarks] [nvarchar](max) NULL,
	[ImportStatus] [bit] NULL,
 CONSTRAINT [Pk_ImportEmployeeDepartment] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
