USE [SmartCursorSTG]
GO
/****** Object:  Table [License].[PackageModuleFeatures]    Script Date: 16-12-2024 9.30.57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [License].[PackageModuleFeatures](
	[Id] [uniqueidentifier] NOT NULL,
	[PackageModuleId] [uniqueidentifier] NOT NULL,
	[Name] [nvarchar](300) NULL,
	[FeatureId] [uniqueidentifier] NULL,
 CONSTRAINT [PK_PackageModuleFeatures] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [License].[PackageModuleFeatures]  WITH CHECK ADD  CONSTRAINT [FK_PackageModuleFeatures_Feature] FOREIGN KEY([FeatureId])
REFERENCES [Common].[Feature] ([Id])
GO
ALTER TABLE [License].[PackageModuleFeatures] CHECK CONSTRAINT [FK_PackageModuleFeatures_Feature]
GO
ALTER TABLE [License].[PackageModuleFeatures]  WITH CHECK ADD  CONSTRAINT [FK_PackageModuleFeatures_Package] FOREIGN KEY([PackageModuleId])
REFERENCES [License].[PackageModule] ([Id])
GO
ALTER TABLE [License].[PackageModuleFeatures] CHECK CONSTRAINT [FK_PackageModuleFeatures_Package]
GO
