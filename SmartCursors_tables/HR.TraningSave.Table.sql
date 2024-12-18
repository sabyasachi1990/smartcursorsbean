USE [SmartCursorSTG]
GO
/****** Object:  Table [HR].[TraningSave]    Script Date: 16-12-2024 9.30.57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [HR].[TraningSave](
	[Id] [uniqueidentifier] NOT NULL,
	[DateTime] [datetime2](7) NOT NULL,
	[Remarks] [nvarchar](200) NULL,
	[docId] [nvarchar](100) NULL
) ON [PRIMARY]
GO
