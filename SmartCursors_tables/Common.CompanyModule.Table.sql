USE [SmartCursorSTG]
GO
/****** Object:  Table [Common].[CompanyModule]    Script Date: 16-12-2024 9.30.56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Common].[CompanyModule](
	[Id] [bigint] NOT NULL,
	[CompanyId] [bigint] NOT NULL,
	[ModuleId] [bigint] NOT NULL,
	[SetUpDone] [bit] NULL,
	[Status] [int] NULL,
	[LicensesReserved] [int] NULL,
	[Price] [money] NULL,
	[LicensesUsed] [bigint] NULL,
 CONSTRAINT [PK_CompanyModule] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Common].[CompanyModule] ADD  DEFAULT ((0)) FOR [SetUpDone]
GO
ALTER TABLE [Common].[CompanyModule] ADD  DEFAULT ((1)) FOR [Status]
GO
ALTER TABLE [Common].[CompanyModule]  WITH CHECK ADD  CONSTRAINT [FK_CompanyModule_Company] FOREIGN KEY([CompanyId])
REFERENCES [Common].[Company] ([Id])
GO
ALTER TABLE [Common].[CompanyModule] CHECK CONSTRAINT [FK_CompanyModule_Company]
GO
ALTER TABLE [Common].[CompanyModule]  WITH CHECK ADD  CONSTRAINT [FK_CompanyModule_ModuleMaster] FOREIGN KEY([ModuleId])
REFERENCES [Common].[ModuleMaster] ([Id])
GO
ALTER TABLE [Common].[CompanyModule] CHECK CONSTRAINT [FK_CompanyModule_ModuleMaster]
GO
