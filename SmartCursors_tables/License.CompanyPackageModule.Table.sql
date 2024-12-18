USE [SmartCursorSTG]
GO
/****** Object:  Table [License].[CompanyPackageModule]    Script Date: 16-12-2024 9.30.57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [License].[CompanyPackageModule](
	[Id] [uniqueidentifier] NOT NULL,
	[CompanyId] [bigint] NOT NULL,
	[SubscriptionId] [uniqueidentifier] NULL,
	[ModuleMasterId] [bigint] NOT NULL,
	[LicensesReserved] [int] NOT NULL,
	[LicensesUsed] [int] NOT NULL,
	[ChargeUnit] [nvarchar](50) NULL,
 CONSTRAINT [PK_CompanyPackagemodule] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [License].[CompanyPackageModule]  WITH CHECK ADD  CONSTRAINT [FK_CompanyPackagemodule_Company] FOREIGN KEY([CompanyId])
REFERENCES [Common].[Company] ([Id])
GO
ALTER TABLE [License].[CompanyPackageModule] CHECK CONSTRAINT [FK_CompanyPackagemodule_Company]
GO
ALTER TABLE [License].[CompanyPackageModule]  WITH CHECK ADD  CONSTRAINT [FK_CompanyPackagemodule_ModuleMaster] FOREIGN KEY([ModuleMasterId])
REFERENCES [Common].[ModuleMaster] ([Id])
GO
ALTER TABLE [License].[CompanyPackageModule] CHECK CONSTRAINT [FK_CompanyPackagemodule_ModuleMaster]
GO
