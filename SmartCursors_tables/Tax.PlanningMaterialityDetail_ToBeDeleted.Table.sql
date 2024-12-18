USE [SmartCursorSTG]
GO
/****** Object:  Table [Tax].[PlanningMaterialityDetail_ToBeDeleted]    Script Date: 16-12-2024 9.30.57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Tax].[PlanningMaterialityDetail_ToBeDeleted](
	[Id] [uniqueidentifier] NOT NULL,
	[PlanningMeterialityId] [uniqueidentifier] NOT NULL,
	[Benchmark] [nvarchar](20) NULL,
	[BenchmarkBasis] [decimal](10, 2) NULL,
	[BenchmarkAmount] [decimal](10, 2) NULL,
	[IsBenchmarkAmount] [bit] NOT NULL,
	[BenchmarkPercentage] [decimal](5, 2) NULL,
	[IsBenchmarkPercentage] [bit] NOT NULL,
	[SuggestedRangeFrom] [decimal](5, 2) NULL,
	[SuggestedRangeTo] [decimal](5, 2) NULL,
	[SuggestedAmountFrom] [decimal](10, 2) NULL,
	[SuggestedAmountTo] [decimal](10, 2) NULL,
	[Comments] [nvarchar](254) NULL,
	[RecOrder] [int] NULL,
	[SystemType] [varchar](200) NULL,
 CONSTRAINT [PK_PlanningMaterialityDetail] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Tax].[PlanningMaterialityDetail_ToBeDeleted]  WITH CHECK ADD  CONSTRAINT [FK_PlanningMaterialityDetail_PlanningMateriality] FOREIGN KEY([PlanningMeterialityId])
REFERENCES [Tax].[PlanningMateriality_ToBeDeleted] ([Id])
GO
ALTER TABLE [Tax].[PlanningMaterialityDetail_ToBeDeleted] CHECK CONSTRAINT [FK_PlanningMaterialityDetail_PlanningMateriality]
GO
