USE [SmartCursorSTG]
GO
/****** Object:  Table [Common].[DesignationLevelChargeoutRate]    Script Date: 16-12-2024 9.30.56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Common].[DesignationLevelChargeoutRate](
	[Id] [uniqueidentifier] NOT NULL,
	[DesignationId] [uniqueidentifier] NOT NULL,
	[DesignationLevelId] [uniqueidentifier] NULL,
	[Rate] [decimal](10, 2) NULL,
	[EffectiveFrom] [datetime2](7) NULL,
	[EffectiveTo] [datetime2](7) NULL,
	[Status] [int] NULL,
	[RecOrder] [int] NULL,
	[CreatedDate] [datetime2](7) NULL,
 CONSTRAINT [PK_DesignationLevelChargeoutRate] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Common].[DesignationLevelChargeoutRate] ADD  DEFAULT ((1)) FOR [Status]
GO
ALTER TABLE [Common].[DesignationLevelChargeoutRate]  WITH CHECK ADD  CONSTRAINT [FK_DesignationLevelChargeoutRate_DepartmentDesignation] FOREIGN KEY([DesignationId])
REFERENCES [Common].[DepartmentDesignation] ([Id])
GO
ALTER TABLE [Common].[DesignationLevelChargeoutRate] CHECK CONSTRAINT [FK_DesignationLevelChargeoutRate_DepartmentDesignation]
GO
ALTER TABLE [Common].[DesignationLevelChargeoutRate]  WITH CHECK ADD  CONSTRAINT [FK_DesignationLevelChargeoutRate_DesignationLevel] FOREIGN KEY([DesignationLevelId])
REFERENCES [Common].[DesignationLevel] ([Id])
GO
ALTER TABLE [Common].[DesignationLevelChargeoutRate] CHECK CONSTRAINT [FK_DesignationLevelChargeoutRate_DesignationLevel]
GO
