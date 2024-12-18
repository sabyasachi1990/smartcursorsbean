USE [SmartCursorSTG]
GO
/****** Object:  Table [dbo].[Sheet1$]    Script Date: 16-12-2024 9.30.56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Sheet1$](
	[DocDate] [datetime] NULL,
	[SC Ref No] [nvarchar](255) NULL,
	[EntityName] [nvarchar](255) NULL,
	[ServiceCompany] [nvarchar](255) NULL,
	[DocTotal] [float] NULL,
	[DocBalance] [float] NULL,
	[CaseServiceRefNo] [nvarchar](255) NULL,
	[StateCode] [nvarchar](255) NULL
) ON [PRIMARY]
GO
