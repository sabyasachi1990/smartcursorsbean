USE [SmartCursorSTG]
GO
/****** Object:  Table [Common].[ControlCodeCategoryModule]    Script Date: 16-12-2024 9.30.56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Common].[ControlCodeCategoryModule](
	[Id] [bigint] NOT NULL,
	[CompanyId] [bigint] NOT NULL,
	[ControlCategoryId] [bigint] NOT NULL,
	[ModuleMasterId] [bigint] NOT NULL,
 CONSTRAINT [PK_ControlCodeCategoryModule] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Common].[ControlCodeCategoryModule]  WITH CHECK ADD  CONSTRAINT [FK_ControlCodeCategoryModule_Company] FOREIGN KEY([CompanyId])
REFERENCES [Common].[Company] ([Id])
GO
ALTER TABLE [Common].[ControlCodeCategoryModule] CHECK CONSTRAINT [FK_ControlCodeCategoryModule_Company]
GO
ALTER TABLE [Common].[ControlCodeCategoryModule]  WITH CHECK ADD  CONSTRAINT [FK_ControlCodeCategoryModule_ControlCategory] FOREIGN KEY([ControlCategoryId])
REFERENCES [Common].[ControlCodeCategory] ([Id])
GO
ALTER TABLE [Common].[ControlCodeCategoryModule] CHECK CONSTRAINT [FK_ControlCodeCategoryModule_ControlCategory]
GO
ALTER TABLE [Common].[ControlCodeCategoryModule]  WITH CHECK ADD  CONSTRAINT [FK_ControlCodeCategoryModule_ModuleMaster] FOREIGN KEY([ModuleMasterId])
REFERENCES [Common].[ModuleMaster] ([Id])
GO
ALTER TABLE [Common].[ControlCodeCategoryModule] CHECK CONSTRAINT [FK_ControlCodeCategoryModule_ModuleMaster]
GO
