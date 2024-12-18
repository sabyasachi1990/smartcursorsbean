USE [SmartCursorSTG]
GO
/****** Object:  Table [dbo].[Audit_Culm_Blances]    Script Date: 16-12-2024 9.30.56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Audit_Culm_Blances](
	[EngagementId] [uniqueidentifier] NOT NULL,
	[AccountName] [nvarchar](100) NOT NULL,
	[Month_Year] [nvarchar](6) NULL,
	[PYBal] [decimal](38, 2) NULL,
	[CYBal] [decimal](38, 2) NULL,
	[Msd] [date] NULL,
	[Med] [date] NULL,
	[MonthOrder] [int] NULL,
	[PYMonthValue] [decimal](38, 2) NULL,
	[CYMonthValue] [decimal](38, 2) NULL
) ON [PRIMARY]
GO
