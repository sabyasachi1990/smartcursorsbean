USE [SmartCursorSTG]
GO
/****** Object:  Table [Audit].[DisclosureSections]    Script Date: 16-12-2024 9.30.55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Audit].[DisclosureSections](
	[Id] [uniqueidentifier] NOT NULL,
	[DisclosureId] [uniqueidentifier] NOT NULL,
	[IsGrandTotal] [bit] NULL,
	[IsContainColumns] [bit] NULL,
	[ColumnNames] [nvarchar](max) NULL,
	[GrandTotalName] [nvarchar](max) NULL,
	[Type] [nvarchar](max) NULL,
	[PriorYear] [nvarchar](100) NULL,
	[CurrentYear] [nvarchar](100) NULL,
	[IsChanged] [bit] NULL,
	[ScreenName] [nvarchar](256) NULL,
	[PriorYearTotalName] [nvarchar](256) NULL,
	[CurrentYearTotalName] [nvarchar](256) NULL,
	[Recorder] [int] NULL,
	[CurrentYearCurrency] [nvarchar](15) NULL,
	[PriorYearCurrency] [nvarchar](15) NULL,
 CONSTRAINT [PK_DisclosureSections] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [Audit].[DisclosureSections]  WITH CHECK ADD  CONSTRAINT [FK_DisclosureSections_Disclosure] FOREIGN KEY([DisclosureId])
REFERENCES [Audit].[Disclosure] ([Id])
GO
ALTER TABLE [Audit].[DisclosureSections] CHECK CONSTRAINT [FK_DisclosureSections_Disclosure]
GO
