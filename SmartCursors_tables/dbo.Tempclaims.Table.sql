USE [SmartCursorSTG]
GO
/****** Object:  Table [dbo].[Tempclaims]    Script Date: 16-12-2024 9.30.56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Tempclaims](
	[Id] [uniqueidentifier] NOT NULL,
	[claimName] [nvarchar](100) NULL
) ON [PRIMARY]
GO
