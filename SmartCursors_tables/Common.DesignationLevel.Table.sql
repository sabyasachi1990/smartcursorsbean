USE [SmartCursorSTG]
GO
/****** Object:  Table [Common].[DesignationLevel]    Script Date: 16-12-2024 9.30.56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Common].[DesignationLevel](
	[Id] [uniqueidentifier] NOT NULL,
	[CompanyId] [bigint] NOT NULL,
	[DesignationId] [uniqueidentifier] NOT NULL,
	[LevelId] [int] NULL,
 CONSTRAINT [PK_DesignationLevel] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Common].[DesignationLevel] ADD  DEFAULT ((1)) FOR [LevelId]
GO
ALTER TABLE [Common].[DesignationLevel]  WITH CHECK ADD  CONSTRAINT [FK_DesignationLevel_Company] FOREIGN KEY([CompanyId])
REFERENCES [Common].[Company] ([Id])
GO
ALTER TABLE [Common].[DesignationLevel] CHECK CONSTRAINT [FK_DesignationLevel_Company]
GO
ALTER TABLE [Common].[DesignationLevel]  WITH CHECK ADD  CONSTRAINT [FK_DesignationLevel_Level] FOREIGN KEY([LevelId])
REFERENCES [Common].[Level] ([Id])
GO
ALTER TABLE [Common].[DesignationLevel] CHECK CONSTRAINT [FK_DesignationLevel_Level]
GO
