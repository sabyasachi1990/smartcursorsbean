USE [SmartCursorSTG]
GO
/****** Object:  Table [Common].[CompanyModuleSetUp]    Script Date: 16-12-2024 9.30.56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Common].[CompanyModuleSetUp](
	[Id] [uniqueidentifier] NOT NULL,
	[CompanyId] [bigint] NOT NULL,
	[ModuleId] [bigint] NOT NULL,
	[ModuleDetailUrl] [nvarchar](1000) NOT NULL,
	[Heading] [nvarchar](100) NOT NULL,
	[SetUpOrder] [int] NOT NULL,
	[IsMandatory] [bit] NULL,
	[IsSetUpDone] [bit] NULL,
 CONSTRAINT [PK_CompanyModuleSetUp] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Common].[CompanyModuleSetUp] ADD  DEFAULT ((1)) FOR [IsMandatory]
GO
ALTER TABLE [Common].[CompanyModuleSetUp] ADD  DEFAULT ((0)) FOR [IsSetUpDone]
GO
ALTER TABLE [Common].[CompanyModuleSetUp]  WITH CHECK ADD  CONSTRAINT [FK_CompanyModuleSetUp_Company] FOREIGN KEY([CompanyId])
REFERENCES [Common].[Company] ([Id])
GO
ALTER TABLE [Common].[CompanyModuleSetUp] CHECK CONSTRAINT [FK_CompanyModuleSetUp_Company]
GO
ALTER TABLE [Common].[CompanyModuleSetUp]  WITH CHECK ADD  CONSTRAINT [FK_CompanyModuleSetUp_ModuleMaster] FOREIGN KEY([ModuleId])
REFERENCES [Common].[ModuleMaster] ([Id])
GO
ALTER TABLE [Common].[CompanyModuleSetUp] CHECK CONSTRAINT [FK_CompanyModuleSetUp_ModuleMaster]
GO
