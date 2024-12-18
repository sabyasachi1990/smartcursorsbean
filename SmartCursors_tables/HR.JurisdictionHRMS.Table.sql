USE [SmartCursorSTG]
GO
/****** Object:  Table [HR].[JurisdictionHRMS]    Script Date: 16-12-2024 9.30.57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [HR].[JurisdictionHRMS](
	[Id] [uniqueidentifier] NOT NULL,
	[Jurisdiction] [nvarchar](250) NOT NULL,
	[Configuration] [nvarchar](4000) NULL,
	[MonthlyBased] [bit] NULL,
	[CTCBased] [bit] NULL,
 CONSTRAINT [PK_CompanyUserDetail] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
