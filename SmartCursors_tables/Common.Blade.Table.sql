USE [SmartCursorSTG]
GO
/****** Object:  Table [Common].[Blade]    Script Date: 16-12-2024 9.30.56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Common].[Blade](
	[Id] [uniqueidentifier] NOT NULL,
	[CompanyId] [bigint] NOT NULL,
	[ModuleDetailId] [bigint] NOT NULL,
	[BladeTypeId] [uniqueidentifier] NOT NULL,
	[Status] [int] NULL,
	[RecOrder] [int] NULL,
 CONSTRAINT [PK_Blade] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Common].[Blade] ADD  DEFAULT ((1)) FOR [Status]
GO
ALTER TABLE [Common].[Blade]  WITH CHECK ADD  CONSTRAINT [FK_Blade_ModuleDetail] FOREIGN KEY([ModuleDetailId])
REFERENCES [Common].[ModuleDetail] ([Id])
GO
ALTER TABLE [Common].[Blade] CHECK CONSTRAINT [FK_Blade_ModuleDetail]
GO
