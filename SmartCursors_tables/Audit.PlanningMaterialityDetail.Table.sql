USE [SmartCursorSTG]
GO
/****** Object:  Table [Audit].[PlanningMaterialityDetail]    Script Date: 16-12-2024 9.30.55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Audit].[PlanningMaterialityDetail](
	[Id] [uniqueidentifier] NOT NULL,
	[PlanningMeterialityId] [uniqueidentifier] NOT NULL,
	[Benchmark] [nvarchar](20) NULL,
	[BenchmarkBasis] [decimal](12, 2) NULL,
	[BenchmarkAmount] [decimal](12, 2) NULL,
	[IsBenchmarkAmount] [bit] NOT NULL,
	[BenchmarkPercentage] [decimal](10, 2) NULL,
	[IsBenchmarkPercentage] [bit] NOT NULL,
	[SuggestedRangeFrom] [decimal](5, 2) NULL,
	[SuggestedRangeTo] [decimal](5, 2) NULL,
	[SuggestedAmountFrom] [decimal](12, 2) NULL,
	[SuggestedAmountTo] [decimal](12, 2) NULL,
	[Comments] [nvarchar](max) NULL,
	[RecOrder] [int] NULL,
	[SystemType] [varchar](200) NULL,
	[IsBenchMarkBasisChange] [bit] NULL,
	[IsIncrementedByApplicable] [bit] NULL,
	[IncrementedBy] [nvarchar](100) NULL,
	[IsAllowExceed] [bit] NULL,
	[PreDefineId] [uniqueidentifier] NULL,
	[PreDefine] [nvarchar](100) NULL,
 CONSTRAINT [PK_PlanningMaterialityDetail] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [Audit].[PlanningMaterialityDetail]  WITH CHECK ADD  CONSTRAINT [FK_PlanningMaterialityDetail_PlanningMateriality] FOREIGN KEY([PlanningMeterialityId])
REFERENCES [Audit].[PlanningMateriality] ([Id])
GO
ALTER TABLE [Audit].[PlanningMaterialityDetail] CHECK CONSTRAINT [FK_PlanningMaterialityDetail_PlanningMateriality]
GO
