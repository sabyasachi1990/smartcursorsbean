USE [SmartCursorSTG]
GO
/****** Object:  Table [Common].[NationalityCode]    Script Date: 16-12-2024 9.30.56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Common].[NationalityCode](
	[Id] [uniqueidentifier] NOT NULL,
	[Code] [int] NULL,
	[NationalityName] [nvarchar](256) NULL,
	[Remarks] [nvarchar](256) NULL,
	[Version] [int] NULL,
	[status] [int] NULL,
 CONSTRAINT [PK_NationalityCode] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
