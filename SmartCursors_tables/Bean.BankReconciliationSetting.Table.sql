USE [SmartCursorSTG]
GO
/****** Object:  Table [Bean].[BankReconciliationSetting]    Script Date: 16-12-2024 9.30.55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Bean].[BankReconciliationSetting](
	[Id] [bigint] NOT NULL,
	[CompanyId] [bigint] NOT NULL,
	[BankClearingDate] [datetime2](7) NULL,
	[Status] [int] NULL,
	[UserCreated] [nvarchar](254) NULL,
	[CreatedDate] [datetime2](7) NULL,
	[ModifiedBy] [nvarchar](254) NULL,
	[ModifiedDate] [datetime2](7) NULL,
 CONSTRAINT [PK_BankReconciliationSetting] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Bean].[BankReconciliationSetting] ADD  DEFAULT ((1)) FOR [Status]
GO
ALTER TABLE [Bean].[BankReconciliationSetting]  WITH CHECK ADD  CONSTRAINT [FK_BankReconciliationSetting_Company] FOREIGN KEY([CompanyId])
REFERENCES [Common].[Company] ([Id])
GO
ALTER TABLE [Bean].[BankReconciliationSetting] CHECK CONSTRAINT [FK_BankReconciliationSetting_Company]
GO
