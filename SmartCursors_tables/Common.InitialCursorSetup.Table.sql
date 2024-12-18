USE [SmartCursorSTG]
GO
/****** Object:  Table [Common].[InitialCursorSetup]    Script Date: 16-12-2024 9.30.56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Common].[InitialCursorSetup](
	[Id] [bigint] NOT NULL,
	[CompanyId] [bigint] NOT NULL,
	[ModuleId] [bigint] NOT NULL,
	[ModuleDetailId] [bigint] NOT NULL,
	[IsSetUpDone] [bit] NULL,
	[MainModuleId] [int] NULL,
	[Status] [int] NULL,
	[MasterModuleId] [int] NULL,
	[IsCommonModule] [bit] NULL,
	[Description] [nvarchar](2000) NULL,
 CONSTRAINT [PK_InitialCursorSetup] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Common].[InitialCursorSetup] ADD  DEFAULT ((0)) FOR [IsSetUpDone]
GO
ALTER TABLE [Common].[InitialCursorSetup]  WITH CHECK ADD  CONSTRAINT [FK_InitialCursorSetup_Company] FOREIGN KEY([CompanyId])
REFERENCES [Common].[Company] ([Id])
GO
ALTER TABLE [Common].[InitialCursorSetup] CHECK CONSTRAINT [FK_InitialCursorSetup_Company]
GO
ALTER TABLE [Common].[InitialCursorSetup]  WITH CHECK ADD  CONSTRAINT [FK_InitialCursorSetup_ModuleDetail] FOREIGN KEY([ModuleDetailId])
REFERENCES [Common].[ModuleDetail] ([Id])
GO
ALTER TABLE [Common].[InitialCursorSetup] CHECK CONSTRAINT [FK_InitialCursorSetup_ModuleDetail]
GO
ALTER TABLE [Common].[InitialCursorSetup]  WITH CHECK ADD  CONSTRAINT [FK_InitialCursorSetup_ModuleMaster] FOREIGN KEY([ModuleId])
REFERENCES [Common].[ModuleMaster] ([Id])
GO
ALTER TABLE [Common].[InitialCursorSetup] CHECK CONSTRAINT [FK_InitialCursorSetup_ModuleMaster]
GO
