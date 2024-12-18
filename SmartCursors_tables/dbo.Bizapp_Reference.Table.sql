USE [SmartCursorSTG]
GO
/****** Object:  Table [dbo].[Bizapp_Reference]    Script Date: 16-12-2024 9.30.56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Bizapp_Reference](
	[Inv_Date] [datetime] NULL,
	[Svc_Ent_From] [nvarchar](5) NULL,
	[Svc_Ent_To] [nvarchar](4) NULL,
	[SC_Inv] [nvarchar](16) NULL,
	[Client_Name] [nvarchar](85) NULL,
	[SC_Doc_Amt] [numeric](7, 2) NULL,
	[SC_Incidentals] [numeric](6, 2) NULL,
	[SC_Total] [numeric](7, 2) NULL,
	[BizApp_Inv] [nvarchar](23) NULL
) ON [PRIMARY]
GO
