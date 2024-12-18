USE [SmartCursorSTG]
GO
/****** Object:  Table [Bean].[Category]    Script Date: 16-12-2024 9.30.55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Bean].[Category](
	[Id] [uniqueidentifier] NOT NULL,
	[CompanyId] [bigint] NULL,
	[Name] [nvarchar](100) NULL,
	[Type] [nvarchar](50) NULL,
	[Recorder] [int] NULL,
	[IsIncomeStatement] [bit] NULL,
	[LeadsheetId] [uniqueidentifier] NULL,
	[ColorCode] [nvarchar](100) NULL,
	[AccountClass] [nvarchar](20) NULL,
	[IsCollapse] [bit] NULL,
 CONSTRAINT [PK_Category] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
