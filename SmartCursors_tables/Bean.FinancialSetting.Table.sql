USE [SmartCursorSTG]
GO
/****** Object:  Table [Bean].[FinancialSetting]    Script Date: 16-12-2024 9.30.55 PM ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Bean].[FinancialSetting](
	[Id] [bigint] NOT NULL,
	[CompanyId] [bigint] NOT NULL,
	[FinancialYearEnd] [nvarchar](25) NULL,
	[TimeZone] [nvarchar](100) NOT NULL,
	[PeriodLockDate] [datetime2](7) NULL,
	[PeriodLockDatePassword] [nvarchar](50) NULL,
	[EndOfYearLockDate] [datetime2](7) NULL,
	[Status] [int] NULL,
	[UserCreated] [nvarchar](254) NULL,
	[CreatedDate] [datetime2](7) NULL,
	[ModifiedBy] [nvarchar](254) NULL,
	[ModifiedDate] [datetime2](7) NULL,
	[BaseCurrency] [nvarchar](50) NULL,
	[LongDateFormat] [nvarchar](50) NULL,
	[ShortDateFormat] [nvarchar](50) NULL,
	[TimeFormat] [nvarchar](50) NULL,
	[PeriodEndDate] [datetime2](7) NULL,
	[IsbaseCurrency] [bit] NULL,
	[IsPosted] [bit] NULL,
 CONSTRAINT [PK_FinancialSetting] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Bean].[FinancialSetting] ADD  DEFAULT ((1)) FOR [Status]
GO
ALTER TABLE [Bean].[FinancialSetting] ADD  DEFAULT ((0)) FOR [IsbaseCurrency]
GO
ALTER TABLE [Bean].[FinancialSetting]  WITH CHECK ADD  CONSTRAINT [FK_FinancialSetting_Company] FOREIGN KEY([CompanyId])
REFERENCES [Common].[Company] ([Id])
GO
ALTER TABLE [Bean].[FinancialSetting] CHECK CONSTRAINT [FK_FinancialSetting_Company]
GO
