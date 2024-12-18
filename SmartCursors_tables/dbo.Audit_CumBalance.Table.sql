USE [SmartCursorSTG]
GO
/****** Object:  Table [dbo].[Audit_CumBalance]    Script Date: 16-12-2024 9.30.56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Audit_CumBalance](
	[SourceGeneralLedgerId] [uniqueidentifier] NOT NULL,
	[EngagementId] [uniqueidentifier] NOT NULL,
	[AccountName] [nvarchar](100) NOT NULL,
	[GLType] [nvarchar](50) NULL,
	[Debit] [decimal](17, 2) NULL,
	[Credit] [decimal](17, 2) NULL,
	[PYBal] [decimal](38, 2) NULL,
	[CYBal] [decimal](38, 2) NULL,
	[MSD] [date] NULL,
	[MED] [date] NULL,
	[Month_Year] [nvarchar](6) NULL,
	[MonthOrder] [int] NULL,
	[Description] [nvarchar](max) NULL,
	[Account Category] [nvarchar](50) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
