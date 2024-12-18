USE [SmartCursorSTG]
GO
/****** Object:  Table [Import].[ImportGl]    Script Date: 16-12-2024 9.30.57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Import].[ImportGl](
	[AccountName] [nvarchar](1000) NULL,
	[Date] [nvarchar](4000) NULL,
	[Type] [nvarchar](4000) NULL,
	[SubType] [nvarchar](4000) NULL,
	[Entity] [nvarchar](4000) NULL,
	[Description] [nvarchar](4000) NULL,
	[Source] [nvarchar](4000) NULL,
	[DocNo] [nvarchar](4000) NULL,
	[Currency] [nvarchar](4000) NULL,
	[Amount] [nvarchar](400) NULL,
	[Debit] [nvarchar](400) NULL,
	[Credit] [nvarchar](400) NULL,
	[Balance] [nvarchar](400) NULL,
	[EngagementId] [uniqueidentifier] NULL,
	[GLType] [nvarchar](20) NULL,
	[Recorder] [bigint] NULL
) ON [PRIMARY]
GO
