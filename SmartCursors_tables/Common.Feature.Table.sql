USE [SmartCursorSTG]
GO
/****** Object:  Table [Common].[Feature]    Script Date: 16-12-2024 9.30.56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Common].[Feature](
	[Id] [uniqueidentifier] NOT NULL,
	[ModuleId] [bigint] NULL,
	[Name] [nvarchar](254) NULL,
	[VisibleStyle] [nvarchar](20) NOT NULL,
	[Status] [int] NULL,
	[IsTab] [bit] NULL,
	[IsReversible] [bit] NULL,
	[GroupKey] [nvarchar](100) NULL,
	[IsOnetimeSave] [bit] NULL,
	[FeatureType] [nvarchar](max) NULL,
	[RecOrder] [int] NULL,
 CONSTRAINT [PK_Feaure] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [Common].[Feature] ADD  DEFAULT ((1)) FOR [Status]
GO
ALTER TABLE [Common].[Feature]  WITH CHECK ADD  CONSTRAINT [FK_Feature_ModuleMaster] FOREIGN KEY([ModuleId])
REFERENCES [Common].[ModuleMaster] ([Id])
GO
ALTER TABLE [Common].[Feature] CHECK CONSTRAINT [FK_Feature_ModuleMaster]
GO
