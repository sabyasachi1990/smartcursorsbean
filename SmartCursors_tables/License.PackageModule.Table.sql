USE [SmartCursorSTG]
GO
/****** Object:  Table [License].[PackageModule]    Script Date: 16-12-2024 9.30.57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [License].[PackageModule](
	[Id] [uniqueidentifier] NOT NULL,
	[PackageId] [uniqueidentifier] NOT NULL,
	[Name] [nvarchar](300) NULL,
	[ModuleMasterId] [bigint] NULL,
 CONSTRAINT [PK_PackageModule] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [License].[PackageModule]  WITH CHECK ADD  CONSTRAINT [FK_PackageModule_ModuleMaster] FOREIGN KEY([ModuleMasterId])
REFERENCES [Common].[ModuleMaster] ([Id])
GO
ALTER TABLE [License].[PackageModule] CHECK CONSTRAINT [FK_PackageModule_ModuleMaster]
GO
ALTER TABLE [License].[PackageModule]  WITH CHECK ADD  CONSTRAINT [FK_PackageModule_Package] FOREIGN KEY([PackageId])
REFERENCES [License].[Package] ([Id])
GO
ALTER TABLE [License].[PackageModule] CHECK CONSTRAINT [FK_PackageModule_Package]
GO
