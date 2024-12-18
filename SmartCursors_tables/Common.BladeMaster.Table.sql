USE [SmartCursorSTG]
GO
/****** Object:  Table [Common].[BladeMaster]    Script Date: 16-12-2024 9.30.56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Common].[BladeMaster](
	[Id ] [bigint] NOT NULL,
	[CompanyId] [bigint] NOT NULL,
	[ModuleId] [bigint] NOT NULL,
	[PermissionKey] [nvarchar](300) NULL,
	[ModuleDetailId] [bigint] NULL,
	[IsGrid] [bit] NULL,
 CONSTRAINT [PK_BladeMaster] PRIMARY KEY CLUSTERED 
(
	[Id ] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Common].[BladeMaster]  WITH CHECK ADD  CONSTRAINT [FK_BladeMaster_ModuleId] FOREIGN KEY([ModuleId])
REFERENCES [Common].[ModuleMaster] ([Id])
GO
ALTER TABLE [Common].[BladeMaster] CHECK CONSTRAINT [FK_BladeMaster_ModuleId]
GO
