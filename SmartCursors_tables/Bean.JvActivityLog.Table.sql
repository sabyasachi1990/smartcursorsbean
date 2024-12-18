USE [SmartCursorSTG]
GO
/****** Object:  Table [Bean].[JvActivityLog]    Script Date: 16-12-2024 9.30.55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Bean].[JvActivityLog](
	[Id] [uniqueidentifier] NOT NULL,
	[JvId] [uniqueidentifier] NOT NULL,
	[Status] [nvarchar](50) NULL,
	[CreatedBy] [nvarchar](254) NULL,
	[CreatedDate] [datetime2](7) NULL,
 CONSTRAINT [PK_JvActivityLog] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
