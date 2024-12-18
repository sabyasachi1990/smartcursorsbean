USE [SmartCursorSTG]
GO
/****** Object:  Table [Tax].[Disposal]    Script Date: 16-12-2024 9.30.57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Tax].[Disposal](
	[Id] [uniqueidentifier] NOT NULL,
	[SectionAId] [uniqueidentifier] NOT NULL,
	[Dateofdisposal] [datetime2](7) NULL,
	[Cost] [decimal](17, 2) NULL,
	[TaxWDV] [decimal](17, 2) NULL,
	[SalesPeoceeds] [decimal](17, 2) NULL,
	[BalAllowance] [decimal](17, 2) NULL,
	[Recorder] [int] NULL,
	[AssetDescription] [nvarchar](256) NULL,
	[SalesProceeds] [decimal](17, 2) NULL,
	[IsRollForward] [bit] NULL,
 CONSTRAINT [PK_Disposal] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Tax].[Disposal]  WITH CHECK ADD  CONSTRAINT [FK_Disposal_SECTIONA] FOREIGN KEY([SectionAId])
REFERENCES [Tax].[SectionA] ([Id])
GO
ALTER TABLE [Tax].[Disposal] CHECK CONSTRAINT [FK_Disposal_SECTIONA]
GO
